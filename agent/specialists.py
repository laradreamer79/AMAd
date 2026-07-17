"""Specialist registry: a specialist is a CONFIG for the shared loop, not a new loop.

Each specialist filters TOOLS/HANDLERS from agent/tools.py down to its subset
and pairs it with a focused system prompt (shared guardrail preamble + its own
section). Guardrails are structural, not just prompt-level:

- tool subset: a specialist physically cannot call a tool it doesn't carry
  (the engine rejects it as unknown_tool);
- envelope allowlist: even if a handler produced an envelope outside the
  specialist's mandate, the engine drops it (allowed_envelopes).

Prompt caching: the preamble block is byte-identical across specialists and
carries its own cache_control breakpoint; the specialist section and the tool
array carry breakpoints of their own — identical across requests per specialist.
"""

from __future__ import annotations

import copy
from dataclasses import dataclass

from agent.prompts import (
    INQUIRY_SECTION,
    SERVICING_SECTION,
    SHARED_PREAMBLE,
    TRANSACTIONS_SECTION,
)
from agent.tools import HANDLERS, TOOLS


@dataclass(frozen=True)
class Specialist:
    name: str
    system_blocks: list
    tools: list           # Anthropic tool schemas, last one cache-marked
    handlers: dict        # name -> handler, strict subset of tools.HANDLERS
    allowed_envelopes: frozenset


def _build(name: str, section: str, tool_names: list[str], allowed: set[str]) -> Specialist:
    tools = [copy.deepcopy(t) for t in TOOLS if t["name"] in tool_names]
    assert len(tools) == len(tool_names), f"unknown tool in '{name}' subset"
    tools[-1]["cache_control"] = {"type": "ephemeral"}
    system_blocks = [
        {"type": "text", "text": SHARED_PREAMBLE, "cache_control": {"type": "ephemeral"}},
        {"type": "text", "text": section, "cache_control": {"type": "ephemeral"}},
    ]
    return Specialist(
        name=name,
        system_blocks=system_blocks,
        tools=tools,
        handlers={n: HANDLERS[n] for n in tool_names},
        allowed_envelopes=frozenset(allowed),
    )


SPECIALISTS: dict[str, Specialist] = {
    "inquiry": _build(
        "inquiry",
        INQUIRY_SECTION,
        ["get_accounts", "get_beneficiaries", "get_bills", "get_products", "get_transactions"],
        allowed=set(),  # read-only: never emits an envelope
    ),
    "transactions": _build(
        "transactions",
        TRANSACTIONS_SECTION,
        ["get_accounts", "get_beneficiaries", "get_bills", "initiate_transfer", "pay_bill"],
        allowed={"REVIEW_TRANSFER", "REVIEW_BILL", "STEP_UP_VERIFY", "DECLINED"},
    ),
    "servicing": _build(
        "servicing",
        SERVICING_SECTION,
        ["get_accounts", "get_products", "open_account", "request_card"],
        allowed={"REVIEW_CARD", "REVIEW_ACCOUNT"},
    ),
}

# Money movement and DECLINE are the transactions specialist's mandate alone.
_MONEY_ENVELOPES = {"REVIEW_TRANSFER", "REVIEW_BILL", "STEP_UP_VERIFY", "DECLINED"}
for _name, _s in SPECIALISTS.items():
    if _name != "transactions":
        assert not (_s.allowed_envelopes & _MONEY_ENVELOPES), f"{_name} may not emit money envelopes"
        assert not ({"initiate_transfer", "pay_bill"} & set(_s.handlers)), f"{_name} may not carry money tools"
