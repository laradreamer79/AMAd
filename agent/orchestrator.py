"""OrchestratorAgent: owns the session, the context window and routing.

Routing is hybrid, cheapest first:
1. keyword/regex pre-filter for unambiguous intents (transfer/bill -> transactions,
   card/open-account -> servicing, balance/products/history -> inquiry);
2. greeting-only messages answered directly by the orchestrator (no specialist hop);
3. sticky specialist from the session, so keyword-less follow-ups
   ("نعم أكد", "خله 300 بدال") stay with the specialist already engaged;
4. ONE small LLM classification call only for genuinely ambiguous messages
   (with MockLLM this yields nothing parseable and falls back to a greeting).

The trace records the routing decision + which specialist ran + that
specialist's step trace — router -> specialist -> tool_use -> risk -> envelope
stays observable end to end. Per PDPL the trace never contains chat text.
"""

from __future__ import annotations

import asyncio
import logging
import re
import time

from agent.agent import run_specialist
from agent.metrics import metrics
from agent.prompts import CLASSIFIER_PROMPT, GREETING_REPLY
from agent.specialists import SPECIALISTS

log = logging.getLogger("ameen.orchestrator")

# Checked in order: money movement first, then servicing, then read-only.
# 'badinput' / 'exhaust' are MockLLM test hooks (see agent/llm.py).
_INTENT_RULES: list[tuple[str, re.Pattern]] = [
    ("transactions", re.compile(
        r"حوّ?ل|تحويل|ارسل|أرسل|ابعث|سدّ?د|ادفع|دفع|فاتورة|فواتير"
        r"|transfer|send\b|\bpay\b|\bbills?\b|badinput"
    )),
    ("servicing", re.compile(
        r"بطاقة|بطاقتي|[أا]فتح حساب|فتح حساب|حساب جديد"
        r"|\bcards?\b|open (?:an? )?account|new account"
    )),
    ("inquiry", re.compile(
        r"رصيد|حساباتي|منتجات|عمليات|مصاريف|مستفيد|كشف"
        r"|balance|\baccounts\b|products|transactions|spending|beneficiar"
        r"|exhaust|استنزف"
    )),
]

_GREETING_RE = re.compile(
    r"^\s*(?:مرحبا|مرحباً|هلا|أهلا|أهلاً|اهلين|السلام عليكم|صباح الخير|مساء الخير"
    r"|شكرا|شكراً|تسلم|hi|hello|hey|thanks|thank you)[\s!.،؟?]*$"
)

_CLASSIFIER_BLOCKS = [
    {"type": "text", "text": CLASSIFIER_PROMPT, "cache_control": {"type": "ephemeral"}}
]

_ROUTE_TARGETS = (*SPECIALISTS, "smalltalk")


async def _silent(_: str) -> None:  # classifier output never streams to the user
    return None


class OrchestratorAgent:
    """Public contract (used by main.py and the tests):

    await orchestrator.run_turn(session_id=..., user_text=..., emit=...)
    emitting {"type": "status"|"token"|"envelope"|"done"|"error", ...} events.
    """

    def __init__(self, *, llm, store, audit, llm_semaphore: asyncio.Semaphore | None = None) -> None:
        self._llm = llm
        self._store = store
        self._audit = audit
        self._sem = llm_semaphore

    # ------------------------------------------------------------- routing
    @staticmethod
    def _route(text: str, session: dict) -> tuple[str | None, dict]:
        t = text.strip().lower()
        for name, rx in _INTENT_RULES:
            if rx.search(t):
                return name, {"method": "keyword", "matched": name}
        if _GREETING_RE.match(t):
            return "smalltalk", {"method": "keyword", "matched": "greeting"}
        sticky = session.get("active_specialist")
        if sticky in SPECIALISTS:
            return sticky, {"method": "sticky", "matched": sticky}
        return None, {"method": "unmatched"}

    async def _classify(self, text: str) -> str | None:
        """One small LLM call for ambiguous messages; None if unparseable."""
        try:
            assistant = await self._llm.complete(
                _CLASSIFIER_BLOCKS, [], [{"role": "user", "content": text}], _silent
            )
        except Exception:  # noqa: BLE001
            log.exception("intent classification failed")
            return None
        reply = " ".join(
            b.get("text", "") for b in assistant.get("content", [])
            if isinstance(b, dict) and b.get("type") == "text"
        ).strip().lower()
        return next((n for n in _ROUTE_TARGETS if n in reply[:60]), None)

    # ------------------------------------------------------------ the turn
    async def run_turn(self, *, session_id: str, user_text: str, emit) -> None:
        started = time.perf_counter()
        metrics.inc("requests_total")

        session = await self._store.get(session_id) or {"messages": []}
        history: list[dict] = session["messages"]

        target, decision = self._route(user_text, session)
        if target is None:
            target = await self._classify(user_text)
            decision = {"method": "llm_classifier", "matched": target or "unresolved"}
            if target is None:
                target = "smalltalk"  # ask-to-clarify greeting, no specialist hop
        metrics.inc(f"route_{target}_total")

        if target == "smalltalk":
            history.append({"role": "user", "content": user_text})
            history.append({"role": "assistant", "content": GREETING_REPLY})
            await emit({"type": "token", "text": GREETING_REPLY})
            await self._store.put(session_id, session)
            metrics.record_turn_ms((time.perf_counter() - started) * 1000)
            await emit({"type": "done"})
            return

        specialist = SPECIALISTS[target]
        session["active_specialist"] = target  # sticky for keyword-less follow-ups
        history.append({"role": "user", "content": user_text})
        trace = {"router": {**decision, "specialist": target}, "steps": []}

        ok = await run_specialist(
            specialist=specialist,
            session_id=session_id,
            history=history,
            llm=self._llm,
            audit=self._audit,
            emit=emit,
            trace=trace,
            llm_semaphore=self._sem,
        )
        if not ok:
            history.pop()  # drop the un-answered user turn to keep history valid
            await self._store.put(session_id, session)
            return

        # Persist FULL history (the API window the specialist saw is only a view).
        await self._store.put(session_id, session)
        metrics.record_turn_ms((time.perf_counter() - started) * 1000)
        await emit({"type": "done"})
