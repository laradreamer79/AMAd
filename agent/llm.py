"""LLM access: Anthropic Messages API (async, streaming, prompt-cached) and a
deterministic MockLLM (AMEEN_MOCK=1) that drives tests and load runs offline.

Both expose:  await llm.complete(system, tools, messages, on_text) -> assistant
message dict {"role": "assistant", "content": [blocks], "stop_reason": ...}.
"""

from __future__ import annotations

import asyncio
import json
import logging
import re
import uuid

log = logging.getLogger("ameen.llm")


class AnthropicLLM:
    def __init__(self, api_key: str, model: str) -> None:
        from anthropic import AsyncAnthropic

        self._client = AsyncAnthropic(api_key=api_key)
        self._model = model

    async def complete(self, system, tools, messages, on_text) -> dict:
        async with self._client.messages.stream(
            model=self._model,
            max_tokens=1500,
            system=system,      # blocks carry cache_control breakpoints
            tools=tools,        # last tool carries a cache_control breakpoint
            messages=messages,
        ) as stream:
            async for text in stream.text_stream:
                await on_text(text)
            final = await stream.get_final_message()
        content = []
        for block in final.content:
            if block.type == "text":
                content.append({"type": "text", "text": block.text})
            elif block.type == "tool_use":
                content.append(
                    {"type": "tool_use", "id": block.id, "name": block.name, "input": block.input}
                )
        return {"role": "assistant", "content": content, "stop_reason": final.stop_reason}


class OpenRouterLLM:
    """OpenAI-compatible chat.completions adapter for openrouter.ai.

    Translates the Anthropic-shaped contract the engine speaks (system blocks,
    tool schemas, tool_use/tool_result messages) to/from the OpenAI format.
    Non-streaming: the reply text is emitted once via on_text.
    """

    URL = "https://openrouter.ai/api/v1/chat/completions"

    def __init__(self, api_key: str, model: str) -> None:
        import httpx

        self._client = httpx.AsyncClient(
            timeout=90, headers={"Authorization": f"Bearer {api_key}"}
        )
        self._model = model

    @staticmethod
    def _to_openai_tools(tools) -> list[dict]:
        return [
            {
                "type": "function",
                "function": {
                    "name": t["name"],
                    "description": t.get("description", ""),
                    "parameters": t["input_schema"],
                },
            }
            for t in tools
        ]

    @staticmethod
    def _to_openai_messages(system, messages) -> list[dict]:
        system_text = "\n\n".join(b["text"] for b in system if b.get("type") == "text")
        out: list[dict] = [{"role": "system", "content": system_text}]
        for msg in messages:
            content = msg.get("content")
            if isinstance(content, str):
                out.append({"role": msg["role"], "content": content})
                continue
            if msg["role"] == "assistant":
                text = " ".join(
                    b.get("text", "") for b in content if b.get("type") == "text"
                ).strip()
                tool_calls = [
                    {
                        "id": b["id"],
                        "type": "function",
                        "function": {
                            "name": b["name"],
                            "arguments": json.dumps(b.get("input") or {}, ensure_ascii=False),
                        },
                    }
                    for b in content if b.get("type") == "tool_use"
                ]
                entry: dict = {"role": "assistant", "content": text or None}
                if tool_calls:
                    entry["tool_calls"] = tool_calls
                out.append(entry)
            else:  # user: plain text blocks and/or tool_results
                for b in content:
                    if b.get("type") == "tool_result":
                        out.append({
                            "role": "tool",
                            "tool_call_id": b["tool_use_id"],
                            "content": b.get("content") or "",
                        })
                    elif b.get("type") == "text":
                        out.append({"role": "user", "content": b.get("text", "")})
        return out

    async def complete(self, system, tools, messages, on_text) -> dict:
        payload: dict = {
            "model": self._model,
            "max_tokens": 1500,
            "messages": self._to_openai_messages(system, messages),
        }
        if tools:
            payload["tools"] = self._to_openai_tools(tools)
        resp = await self._client.post(self.URL, json=payload)
        resp.raise_for_status()
        choice = resp.json()["choices"][0]
        msg = choice["message"]

        content: list[dict] = []
        text = msg.get("content") or ""
        if text:
            await on_text(text)
            content.append({"type": "text", "text": text})
        for call in msg.get("tool_calls") or []:
            try:
                args = json.loads(call["function"].get("arguments") or "{}")
            except ValueError:
                args = {}
            content.append({
                "type": "tool_use",
                "id": call.get("id") or f"toolu_{uuid.uuid4().hex[:12]}",
                "name": call["function"]["name"],
                "input": args,
            })
        stop_reason = "tool_use" if any(
            b["type"] == "tool_use" for b in content
        ) else "end_turn"
        return {"role": "assistant", "content": content, "stop_reason": stop_reason}


# ---------------------------------------------------------------------------
# Mock LLM — deterministic intent router over the same tool contract
# ---------------------------------------------------------------------------

_AMOUNT_RE = re.compile(r"(\d+(?:[.,]\d+)?)")
_NAME_HINTS = ["عمر", "فاطمة", "نورة", "حسن", "زين",
               "omar", "fatima", "noura", "hassan", "zain"]
_PRODUCT_HINTS = {
    "شخصي": "Personal Finance", "personal": "Personal Finance",
    "مسكن": "Home Finance", "منزل": "Home Finance", "home": "Home Finance",
    "سيار": "Auto Finance", "auto": "Auto Finance", "car": "Auto Finance",
    "ادخار": "Saving Certificate", "saving certificate": "Saving Certificate",
    "استثمار": "Investment Portfolio", "investment": "Investment Portfolio",
    "تأمين": "Travel Insurance", "insurance": "Travel Insurance",
}


def _tool_use(name: str, tool_input: dict) -> dict:
    return {"type": "tool_use", "id": f"toolu_{uuid.uuid4().hex[:12]}", "name": name, "input": tool_input}


class MockLLM:
    """Pattern-matches user intent to the same tools the real model would call.

    Recognised triggers (Arabic/English): balance, products, bills, transfer
    <amount> to <name>, pay <bill>, open account, new card, and test hooks
    'badinput' (malformed tool input) and 'exhaust' (never stops calling tools).
    """

    async def complete(self, system, tools, messages, on_text) -> dict:
        user_text = self._last_user_text(messages).lower()
        if "exhaust" in user_text or "استنزف" in user_text:
            # never stops calling tools — exercises the MAX_STEPS fallback
            return {
                "role": "assistant",
                "content": [_tool_use("get_accounts", {})],
                "stop_reason": "tool_use",
            }
        last = messages[-1]
        if self._is_tool_result_msg(last):
            text = self._summarize_results(last, messages)
            await on_text(text)
            return {"role": "assistant", "content": [{"type": "text", "text": text}], "stop_reason": "end_turn"}

        blocks = self._route(user_text)
        if blocks:
            return {"role": "assistant", "content": blocks, "stop_reason": "tool_use"}
        reply = "أهلاً بك! أنا أمين، مساعدك المصرفي. كيف أقدر أخدمك اليوم؟"
        await on_text(reply)
        return {"role": "assistant", "content": [{"type": "text", "text": reply}], "stop_reason": "end_turn"}

    # ------------------------------------------------------------- routing
    def _route(self, text: str) -> list[dict]:
        if "badinput" in text:
            # malformed on purpose: wrong type + missing required 'beneficiary'
            return [_tool_use("initiate_transfer", {"amount": "abc"})]
        if "exhaust" in text or "استنزف" in text:
            return [_tool_use("get_accounts", {})]

        wants_balance = any(k in text for k in ["رصيد", "balance", "حساباتي", "accounts"])
        wants_products = any(k in text for k in ["منتجات", "products", "بطاقات متاحة", "cards available"])
        if wants_balance and wants_products:
            # independent read-only calls -> one assistant turn, parallel blocks
            return [_tool_use("get_accounts", {}), _tool_use("get_products", {"category": "all"})]
        if wants_balance:
            return [_tool_use("get_accounts", {})]
        if wants_products:
            return [_tool_use("get_products", {"category": "all"})]
        if any(k in text for k in ["عمليات", "transactions", "spending", "مصاريف"]):
            return [_tool_use("get_transactions", {"limit": 30})]
        if any(k in text for k in ["مستفيد", "beneficiaries"]):
            return [_tool_use("get_beneficiaries", {})]

        if any(k in text for k in ["ادفع", "دفع", "pay"]):
            bill = "كهرباء" if "كهرباء" in text or "electricity" in text else text
            return [_tool_use("pay_bill", {"bill_name": bill})]
        if any(k in text for k in ["فواتير", "فاتورة", "bills", "bill"]):
            return [_tool_use("get_bills", {})]

        if any(k in text for k in ["حول", "حوّل", "transfer", "ارسل", "أرسل", "send"]):
            m = _AMOUNT_RE.search(text.replace(",", ""))
            amount = float(m.group(1)) if m else 0.0
            name = next((n for n in _NAME_HINTS if n in text), "")
            return [_tool_use("initiate_transfer", {"beneficiary": name or text, "amount": amount})]

        if any(k in text for k in ["افتح حساب", "فتح حساب", "open account", "حساب جديد"]):
            acc_type = "Saving" if ("توفير" in text or "saving" in text) else "Active"
            return [_tool_use("open_account", {"account_type": acc_type, "currency": "SAR", "short_name": "حسابي الجديد"})]

        wants_finance = any(
            k in text for k in ["تمويل", "finance", "financing", "ادخار", "saving certificate",
                                 "استثمار", "investment", "تأمين", "insurance"]
        )
        if wants_finance:
            text_lower = text.lower()
            product = "Personal Finance"  # default
            for hint, name in _PRODUCT_HINTS.items():
                if hint in text or hint in text_lower:
                    product = name
                    break
            m = _AMOUNT_RE.search(text.replace(",", ""))
            amount = float(m.group(1)) if m else 0.0
            duration = 24
            for d in (12, 24, 36, 60):
                if str(d) in text:
                    duration = d
                    break
            return [_tool_use(
                "apply_for_product",
                {"product_name": product, "amount": amount, "duration_months": duration},
            )]

        if any(k in text for k in ["بطاقة", "card"]):
            text_lower = text.lower()
            card = "Visa Signature"  # default
            if "mada" in text_lower or "مدى" in text:
                card = "mada"
            elif "platinum" in text_lower or "بلاتينيوم" in text or "بلاتينيم" in text:
                card = "Visa Platinum"
            elif "signature" in text_lower or "سيجنتشر" in text:
                card = "Visa Signature"
            return [_tool_use("request_card", {"card_type": card})]
        return []

    # ------------------------------------------------------- summarization
    @staticmethod
    def _is_tool_result_msg(msg: dict) -> bool:
        content = msg.get("content")
        return isinstance(content, list) and any(
            isinstance(b, dict) and b.get("type") == "tool_result" for b in content
        )

    @staticmethod
    def _last_user_text(messages: list[dict]) -> str:
        for msg in reversed(messages):
            if msg.get("role") == "user":
                content = msg.get("content")
                if isinstance(content, str):
                    return content
                for b in content or []:
                    if isinstance(b, dict) and b.get("type") == "text":
                        return b.get("text", "")
        return ""

    def _summarize_results(self, msg: dict, messages: list[dict]) -> str:
        import json

        parts: list[str] = []
        for block in msg["content"]:
            if block.get("type") != "tool_result":
                continue
            try:
                result = json.loads(block.get("content") or "{}")
            except ValueError:
                result = {}
            if "error" in result:
                err = result["error"]
                parts.append(f"واجهت مشكلة: {err.get('message', err.get('code', 'خطأ'))}. ممكن توضح طلبك أكثر؟")
            elif result.get("declined"):
                parts.append("عذراً، لا يمكنني إتمام هذه العملية — تم رفضها من نظام الحماية ولا يمكن تجاوز هذا القرار.")
            elif result.get("prepared"):
                if result.get("envelope_type") == "STEP_UP_VERIFY":
                    parts.append("جهزت العملية، لكنها تحتاج تحققاً إضافياً منك قبل المتابعة.")
                else:
                    parts.append("جهزت العملية لك — راجعها واعتمدها من شاشة المراجعة ثم رمز التحقق.")
            elif "accounts" in result:
                acc = result["accounts"][0]
                parts.append(f"رصيد حسابك الرئيسي {acc['balance']:.2f} {acc['currency']}.")
            elif "products" in result:
                parts.append("هذه منتجاتنا المتاحة: بطاقات فيزا، تمويل السيارات والعقار، وحسابات التوفير.")
            elif "bills" in result:
                parts.append(f"لديك {len(result['bills'])} فواتير محفوظة.")
            elif "transactions" in result:
                parts.append("هذه آخر عملياتك.")
            elif "beneficiaries" in result:
                parts.append(f"لديك {len(result['beneficiaries'])} مستفيدين محفوظين.")
            else:
                parts.append("تم.")
        return " ".join(parts) if parts else "تم."


def make_llm(settings):
    provider = settings.ameen_provider.lower()
    if settings.ameen_mock or provider == "mock":
        log.info("AMEEN_MOCK/provider=mock — using deterministic MockLLM")
        return MockLLM()
    if provider == "openrouter":
        if not settings.openrouter_api_key:
            log.warning("OPENROUTER_API_KEY not set — falling back to MockLLM")
            return MockLLM()
        return OpenRouterLLM(settings.openrouter_api_key, settings.ameen_model)
    if not settings.anthropic_api_key:
        log.warning("ANTHROPIC_API_KEY not set — falling back to MockLLM")
        return MockLLM()
    return AnthropicLLM(settings.anthropic_api_key, settings.ameen_model)


async def _noop(_: str) -> None:
    await asyncio.sleep(0)
