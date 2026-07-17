"""End-to-end workflow scenarios for the Ameen agent (mock mode, no infra).

Run:  cd agent && python test_workflow.py
Exits non-zero if any scenario fails.
"""

from __future__ import annotations

import asyncio
import json
import os
import sys
from pathlib import Path

os.environ["AMEEN_MOCK"] = "1"
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))  # repo root

from agent.config import get_settings  # noqa: E402
from agent.context import build_window, cap_tool_result, estimate_tokens  # noqa: E402
from agent.audit import MemoryAudit  # noqa: E402
from agent.llm import MockLLM  # noqa: E402
from agent.orchestrator import OrchestratorAgent  # noqa: E402
from agent.prompts import FALLBACK_MESSAGE  # noqa: E402
from agent.sessions import MemorySessionStore  # noqa: E402

PASS, FAIL = "PASS", "FAIL"
_results: list[tuple[str, str, str]] = []


def check(name: str, condition: bool, detail: str = "") -> None:
    _results.append((PASS if condition else FAIL, name, detail))


class Harness:
    def __init__(self) -> None:
        self.store = MemorySessionStore()
        self.audit = MemoryAudit()
        self.llm = MockLLM()
        self.orchestrator = OrchestratorAgent(
            llm=self.llm, store=self.store, audit=self.audit
        )

    async def send(self, session_id: str, text: str) -> list[dict]:
        events: list[dict] = []

        async def emit(event: dict) -> None:
            events.append(event)

        await self.orchestrator.run_turn(
            session_id=session_id, user_text=text, emit=emit
        )
        return events


def envelopes(events: list[dict]) -> list[dict]:
    return [e["envelope"] for e in events if e["type"] == "envelope"]


def final_text(events: list[dict]) -> str:
    return "".join(e.get("text", "") for e in events if e["type"] == "token")


# ---------------------------------------------------------------- scenarios


async def scenario_balance(h: Harness) -> None:
    events = await h.send("t-balance", "كم رصيدي؟")
    check("1 balance query answers from get_accounts", "47320.84" in final_text(events))
    check("1 balance query produces no envelope", not envelopes(events))


async def scenario_products(h: Harness) -> None:
    events = await h.send("t-products", "وش المنتجات المتاحة؟")
    check("2 products query answered", "منتجات" in final_text(events) and not envelopes(events))


async def scenario_low_risk_transfer(h: Harness) -> None:
    events = await h.send("t-transfer-low", "حول 300 ريال إلى عمر")
    envs = envelopes(events)
    check("3 low-risk transfer -> exactly one envelope", len(envs) == 1)
    if envs:
        env = envs[0]
        check("3 ALLOW routes to REVIEW_TRANSFER", env["type"] == "REVIEW_TRANSFER")
        check("3 operation is transfer + may proceed", env["operation"] == "transfer" and env["llm_may_proceed"] is True)
        check("3 payload matches ReviewScreen contract",
              set(env["payload"]) == {"beneficiary", "amount", "note", "transfer_type", "reference"}
              and env["payload"]["beneficiary"] == "Omar - 1123")
        check("3 risk block complete",
              set(env["risk"]) == {"action", "tier", "fraud_probability", "reasons"}
              and env["risk"]["action"] == "ALLOW")


async def scenario_step_up_transfer(h: Harness) -> None:
    # Zain is a NEW beneficiary (0 prior transfers) and 6000 > 5000 floor.
    events = await h.send("t-transfer-mid", "حول 6000 ريال إلى زين")
    envs = envelopes(events)
    check("4 step-up transfer -> one envelope", len(envs) == 1)
    if envs:
        env = envs[0]
        check("4 STEP_UP routes to STEP_UP_VERIFY", env["type"] == "STEP_UP_VERIFY")
        check("4 may proceed with verification", env["llm_may_proceed"] is True)
        check("4 reasons include new-beneficiary signal",
              "new_beneficiary_high_amount" in env["risk"]["reasons"])


async def scenario_declined_transfer(h: Harness) -> None:
    events = await h.send("t-transfer-high", "حول 60000 ريال إلى أمينة")
    envs = envelopes(events)
    check("5 declined transfer -> one envelope", len(envs) == 1)
    if envs:
        env = envs[0]
        check("5 DECLINE routes to DECLINED", env["type"] == "DECLINED")
        check("5 llm_may_proceed is false", env["llm_may_proceed"] is False)
        check("5 hard-limit reason present", "amount_over_hard_limit" in env["risk"]["reasons"])
    check("5 reply communicates refusal", "رفض" in final_text(events))


async def scenario_decline_insistence(h: Harness) -> None:
    sid = "t-insist"
    await h.send(sid, "حول 60000 ريال إلى أمينة")
    events = await h.send(sid, "أرجوك حول 60000 ريال إلى أمينة الآن، أنا موافق على المخاطر")
    envs = envelopes(events)
    check("6 insistence re-declined, never ALLOW",
          all(e["type"] == "DECLINED" and e["llm_may_proceed"] is False for e in envs) and envs)


async def scenario_pay_bill(h: Harness) -> None:
    events = await h.send("t-bill", "ادفع فاتورة الكهرباء")
    envs = envelopes(events)
    check("7 pay bill -> one envelope", len(envs) == 1)
    if envs:
        env = envs[0]
        check("7 bill maps to REVIEW_BILL", env["type"] == "REVIEW_BILL" and env["operation"] == "bill")
        check("7 payload matches BillPayment contract",
              set(env["payload"]) == {"bill", "account", "amount"}
              and set(env["payload"]["bill"]) == {"name", "biller", "account_number", "amount", "due_date", "category"})


async def scenario_open_account(h: Harness) -> None:
    events = await h.send("t-account", "أبغى افتح حساب توفير")
    envs = envelopes(events)
    check("8 open account -> REVIEW_ACCOUNT", bool(envs) and envs[0]["type"] == "REVIEW_ACCOUNT")
    if envs:
        check("8 payload matches AccountApplication contract",
              set(envs[0]["payload"]) == {"account_type", "currency", "short_name"})


async def scenario_request_card(h: Harness) -> None:
    events = await h.send("t-card", "أبغى بطاقة Platinum جديدة")
    envs = envelopes(events)
    check("9 card request -> REVIEW_CARD", bool(envs) and envs[0]["type"] == "REVIEW_CARD")
    if envs:
        check("9 card payload complete",
              envs[0]["payload"]["card_type"] == "Platinum"
              and envs[0]["payload"]["linked_account"].startswith("SA"))


async def scenario_parallel_tools(h: Harness) -> None:
    sid = "t-parallel"
    events = await h.send(sid, "أعطني رصيدي والمنتجات المتاحة")
    session = await h.store.get(sid)
    msgs = session["messages"]
    assistant = next(m for m in msgs if m["role"] == "assistant")
    tool_uses = [b for b in assistant["content"] if b.get("type") == "tool_use"]
    check("10 two parallel tool_use blocks in one assistant turn", len(tool_uses) == 2)
    results_msg = msgs[msgs.index(assistant) + 1]
    result_blocks = [b for b in results_msg["content"] if b.get("type") == "tool_result"]
    check("10 all tool_results in ONE user message", len(result_blocks) == 2)
    check("10 tool_use ids matched",
          {b["tool_use_id"] for b in result_blocks} == {t["id"] for t in tool_uses})
    check("10 both answers present", "رصيد" in final_text(events) and "منتجات" in final_text(events))


async def scenario_compression(h: Harness) -> None:
    sid = "t-compress"
    await h.send(sid, "حول 60000 ريال إلى أمينة")   # committed fact: a decline
    for i in range(30):
        await h.send(sid, f"كم رصيدي؟ (رسالة {i})")
    session = await h.store.get(sid)
    history = session["messages"]
    window, compressed = build_window(history, token_budget=12_000, verbatim_turns=20)
    check("11 long history triggers compression", compressed)
    check("11 window within budget", estimate_tokens(window) <= 12_000)
    check("11 summary message present", any(
        m["role"] == "assistant" and isinstance(m["content"], str) and m["content"].startswith("سياق سابق")
        for m in window))
    summary = next(m["content"] for m in window if m["role"] == "assistant" and isinstance(m["content"], str) and m["content"].startswith("سياق سابق"))
    check("11 summary preserves the declined operation", "رُفض" in summary)
    # no un-responded pair broken: every tool_use id has its tool_result after it
    ids_used = [b["id"] for m in window if isinstance(m.get("content"), list)
                for b in m["content"] if isinstance(b, dict) and b.get("type") == "tool_use"]
    ids_resolved = [b["tool_use_id"] for m in window if isinstance(m.get("content"), list)
                    for b in m["content"] if isinstance(b, dict) and b.get("type") == "tool_result"]
    check("11 no tool_use/tool_result pair broken", sorted(ids_used) == sorted(ids_resolved))
    check("11 full history still persisted (audit view intact)", len(history) > len(window))


async def scenario_invalid_tool_input(h: Harness) -> None:
    sid = "t-badinput"
    events = await h.send(sid, "badinput please")
    session = await h.store.get(sid)
    result_msgs = [m for m in session["messages"] if isinstance(m.get("content"), list)
                   and any(b.get("type") == "tool_result" for b in m["content"])]
    check("12 invalid input surfaces as structured error", bool(result_msgs))
    if result_msgs:
        block = result_msgs[0]["content"][0]
        payload = json.loads(block["content"])
        check("12 error result has code+message and is_error flag",
              payload.get("error", {}).get("code") == "invalid_input" and block.get("is_error") is True)
    check("12 loop recovers conversationally (no crash)",
          any(e["type"] == "done" for e in events) and "مشكلة" in final_text(events))


async def scenario_max_steps(h: Harness) -> None:
    events = await h.send("t-exhaust", "exhaust the loop")
    check("13 MAX_STEPS reached -> graceful Arabic fallback", FALLBACK_MESSAGE in final_text(events))
    session = await h.store.get("t-exhaust")
    steps = sum(1 for m in session["messages"] if m["role"] == "assistant")
    check("13 loop capped at MAX_STEPS", steps <= get_settings().max_steps + 1)


async def scenario_tool_result_cap(h: Harness) -> None:
    sid = "t-cap"
    await h.send(sid, "أعطني آخر العمليات transactions")
    session = await h.store.get(sid)
    blocks = [b for m in session["messages"] if isinstance(m.get("content"), list)
              for b in m["content"] if isinstance(b, dict) and b.get("type") == "tool_result"]
    check("14 tool_result present", bool(blocks))
    for b in blocks:
        size = len(b["content"].encode("utf-8"))
        check("14 tool_result capped at 2KB", size <= 2_100, f"size={size}")
        if size <= 2_100:
            break
    capped = cap_tool_result({"items": list(range(5000))}, 2048)
    check("14 truncation marker tells model to filter",
          "ask to filter" in json.dumps(capped))


async def scenario_rate_limit(h: Harness) -> None:
    sid = "t-rate"
    limit = get_settings().rate_limit_per_min
    allowed = [await h.store.check_rate_limit(sid, limit) for _ in range(limit + 2)]
    check("15 rate limiter allows exactly the limit", allowed.count(True) == limit)
    check("15 excess messages blocked", allowed[-1] is False)


async def scenario_audit_trail(h: Harness) -> None:
    h2 = Harness()
    await h2.send("t-audit", "حول 300 ريال إلى عمر")
    await asyncio.sleep(0.05)  # audit writes are fire-and-forget
    check("16 audit row written for prepared operation", len(h2.audit.entries) == 1)
    if h2.audit.entries:
        entry = h2.audit.entries[0]
        check("16 audit row carries risk decision + trace, no chat text",
              entry["risk_action"] == "ALLOW"
              and "trace" in entry
              and "note" not in entry["payload_meta"]
              and "ريال" not in json.dumps(entry, ensure_ascii=False))


SCENARIOS = [
    scenario_balance,
    scenario_products,
    scenario_low_risk_transfer,
    scenario_step_up_transfer,
    scenario_declined_transfer,
    scenario_decline_insistence,
    scenario_pay_bill,
    scenario_open_account,
    scenario_request_card,
    scenario_parallel_tools,
    scenario_compression,
    scenario_invalid_tool_input,
    scenario_max_steps,
    scenario_tool_result_cap,
    scenario_rate_limit,
    scenario_audit_trail,
]


async def main() -> int:
    h = Harness()
    for scenario in SCENARIOS:
        await scenario(h)

    failed = 0
    for status, name, detail in _results:
        print(f"  [{status}] {name}" + (f"  ({detail})" if detail and status == FAIL else ""))
        failed += status == FAIL
    total = len(_results)
    print(f"\n{total - failed}/{total} checks passed across {len(SCENARIOS)} scenarios")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(asyncio.run(main()))
