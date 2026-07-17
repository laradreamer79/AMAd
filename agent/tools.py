"""Runtime agent tools: JSON schemas + handlers + HANDLERS registry.

Discipline:
- Every tool is a complete set: schema, handler, registry entry, envelope
  mapping (where applicable), and a scenario in test_workflow.py.
- Handlers return (result_dict, envelope | None). They only PREPARE operations;
  execution always happens in the Flutter Review -> OTP flow.
- Money ops (initiate_transfer, pay_bill) go through DecisionAgent and map via
  envelope.route_from_decision — ALLOW is never hardcoded.
- Errors are structured results {"error": {...}}, never exceptions.
"""

from __future__ import annotations

from datetime import datetime

from decision_agent.decision_agent import get_decision_agent

from agent import mock_bank
from agent.envelope import non_monetary_envelope, route_from_decision

# --------------------------------------------------------------------------
# Tool schemas (Anthropic Messages API format)
# --------------------------------------------------------------------------

TOOLS: list[dict] = [
    {
        "name": "get_accounts",
        "description": (
            "Get the customer's accounts with masked IBANs and current balances. "
            "Call whenever the user asks about balances or which accounts they have. "
            "Read-only; never guess a balance."
        ),
        "input_schema": {"type": "object", "properties": {}, "required": []},
    },
    {
        "name": "get_beneficiaries",
        "description": (
            "List the customer's saved transfer beneficiaries. Call before a transfer "
            "when the recipient is ambiguous or the user asks who they can send to. Read-only."
        ),
        "input_schema": {"type": "object", "properties": {}, "required": []},
    },
    {
        "name": "get_bills",
        "description": (
            "List the customer's saved bills with amounts and due dates. Call when the "
            "user asks about bills or before paying one. Read-only."
        ),
        "input_schema": {"type": "object", "properties": {}, "required": []},
    },
    {
        "name": "get_products",
        "description": (
            "List bank products (cards, finance, account types). Call when the user asks "
            "what cards/products/financing are available. Read-only."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "category": {
                    "type": "string",
                    "enum": ["cards", "bank_products", "accounts", "all"],
                    "description": "Product category to list; 'all' for everything.",
                }
            },
            "required": [],
        },
    },
    {
        "name": "get_transactions",
        "description": (
            "Get recent account transactions (most recent first). Call when the user asks "
            "about spending or transaction history. Read-only."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "limit": {
                    "type": "integer",
                    "description": "Max transactions to return (default 10).",
                }
            },
            "required": [],
        },
    },
    {
        "name": "initiate_transfer",
        "description": (
            "PREPARE a money transfer for the user to review. Call when the user asks to "
            "send/transfer money. Works for a saved beneficiary (pass just 'beneficiary') "
            "or a brand-new one Ameen has never seen before (also pass "
            "'new_beneficiary_account' with the IBAN/account number they give you — Ameen "
            "has no separate 'add beneficiary' screen, so a new beneficiary is simply "
            "confirmed the first time a transfer is sent to them). This does NOT execute "
            "the transfer — it runs the risk gate and returns a prepared operation that "
            "the user must confirm in the app's Review + OTP flow."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "beneficiary": {
                    "type": "string",
                    "description": "Beneficiary name (English or Arabic), e.g. 'Omar' or 'عمر'.",
                },
                "new_beneficiary_account": {
                    "type": "string",
                    "description": (
                        "IBAN/account number, only when 'beneficiary' is NOT one of Ameen's "
                        "saved names — treats them as a new beneficiary (higher scrutiny)."
                    ),
                },
                "amount": {"type": "number", "description": "Amount in SAR, > 0."},
                "note": {"type": "string", "description": "Optional note for the transfer."},
                "reason": {
                    "type": "string",
                    "enum": mock_bank.TRANSFER_REASONS,
                    "description": "Reason for the transfer (default 'Other').",
                },
            },
            "required": ["beneficiary", "amount"],
        },
    },
    {
        "name": "pay_bill",
        "description": (
            "PREPARE payment of a saved bill for the user to review. Call when the user "
            "asks to pay a bill (electricity, mobile, traffic violation, passport). This "
            "does NOT execute the payment — it runs the risk gate and returns a prepared "
            "operation confirmed later in the Review + OTP flow."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "bill_name": {
                    "type": "string",
                    "description": "Saved bill to pay, e.g. 'Electricity Bill' or 'كهرباء'.",
                },
                "account": {
                    "type": "string",
                    "description": "Account to pay from (default: Main Account).",
                },
            },
            "required": ["bill_name"],
        },
    },
    {
        "name": "open_account",
        "description": (
            "PREPARE a new bank account application for the user to review. Call when the "
            "user wants to open an account. Does NOT create the account — the user confirms "
            "in the Review + OTP flow."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "account_type": {"type": "string", "enum": mock_bank.ACCOUNT_TYPES},
                "currency": {"type": "string", "enum": mock_bank.CURRENCIES},
                "short_name": {
                    "type": "string",
                    "description": "Short display name the user wants for the account.",
                },
            },
            "required": ["account_type", "currency", "short_name"],
        },
    },
    {
        "name": "request_card",
        "description": (
            "PREPARE a new card application for the user to review. Call when the "
            "user wants a new credit/debit card. Does NOT issue the card — the user "
            "confirms in the Review + OTP flow."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "card_type": {"type": "string", "enum": mock_bank.CARD_TYPES},
                "linked_account": {
                    "type": "string",
                    "description": "Account to link the card to (default: Main Account).",
                },
            },
            "required": ["card_type"],
        },
    },
    {
        "name": "apply_for_product",
        "description": (
            "PREPARE an application for one of Ameen's bank products (financing, "
            "savings, or insurance — shown on the app's Products page) for the user "
            "to review. Call when the user wants financing (personal/home/auto), a "
            "savings certificate, an investment portfolio, or travel insurance. Does "
            "NOT submit the application — the user confirms in the Review + OTP flow."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "product_name": {
                    "type": "string",
                    "description": (
                        "One of: 'Personal Finance', 'Home Finance', 'Auto Finance', "
                        "'Saving Certificate', 'Investment Portfolio', 'Travel Insurance' "
                        "(English or Arabic name)."
                    ),
                },
                "amount": {
                    "type": "number",
                    "description": "Requested amount in SAR, > 0.",
                },
                "duration_months": {
                    "type": "integer",
                    "enum": [12, 24, 36, 60],
                    "description": "Term length in months.",
                },
            },
            "required": ["product_name", "amount", "duration_months"],
        },
    },
]

TOOL_SCHEMAS = {t["name"]: t["input_schema"] for t in TOOLS}

_JSON_TYPES = {
    "string": str,
    "integer": int,
    "number": (int, float),
    "boolean": bool,
    "object": dict,
    "array": list,
}


def validate_input(name: str, tool_input: dict) -> list[str]:
    """Server-side validation of the model's tool input — it is untrusted JSON."""
    schema = TOOL_SCHEMAS.get(name)
    if schema is None:
        return [f"unknown tool: {name}"]
    errors: list[str] = []
    if not isinstance(tool_input, dict):
        return ["input must be a JSON object"]
    props = schema.get("properties", {})
    for req in schema.get("required", []):
        if req not in tool_input or tool_input[req] in (None, ""):
            errors.append(f"missing required field: {req}")
    for key, value in tool_input.items():
        spec = props.get(key)
        if spec is None:
            errors.append(f"unexpected field: {key}")
            continue
        expected = _JSON_TYPES.get(spec.get("type"))
        if expected and not isinstance(value, expected):
            errors.append(f"field '{key}' must be of type {spec['type']}")
            continue
        if isinstance(value, bool) and spec.get("type") in ("integer", "number"):
            errors.append(f"field '{key}' must be of type {spec['type']}")
            continue
        enum = spec.get("enum")
        if enum and value not in enum:
            errors.append(f"field '{key}' must be one of {enum}")
    return errors


# --------------------------------------------------------------------------
# Handlers — (result_dict, envelope | None)
# --------------------------------------------------------------------------


def _error(code: str, message: str, **extra) -> tuple[dict, None]:
    return {"error": {"code": code, "message": message, **extra}}, None


def _risk_features(amount: float, source: dict, beneficiary_txn_count: int) -> dict:
    profile = mock_bank.USER_PROFILE
    now = datetime.now()
    return {
        "amount": amount,
        "balance": source["balance"],
        "amount_to_balance": amount / max(source["balance"], 1.0),
        "hour": now.hour,
        "is_new_beneficiary": 1 if beneficiary_txn_count == 0 else 0,
        "txn_count_24h": profile["txn_count_24h"],
        "amount_vs_avg": amount / max(profile["avg_txn_amount_90d"], 1.0),
        "beneficiary_txn_count": beneficiary_txn_count,
        "account_age_days": profile["account_age_days"],
    }


def _prepared_result(envelope: dict) -> dict:
    """What the model sees about a prepared/declined operation."""
    declined = envelope["type"] == "DECLINED"
    amount = envelope["payload"].get("amount")
    return {
        "prepared": not declined,
        "declined": declined,
        # committed amount, kept so history compression can preserve it
        **({"amount": amount} if amount is not None else {}),
        "envelope_type": envelope["type"],
        "operation": envelope["operation"],
        "risk": envelope["risk"],
        "llm_may_proceed": envelope["llm_may_proceed"],
        "next": (
            "operation_blocked_by_risk_gate_no_override_possible"
            if declined
            else "user_confirms_in_review_and_otp_flow"
        ),
    }


def handle_get_accounts(tool_input: dict, ctx: dict) -> tuple[dict, None]:
    return {"accounts": mock_bank.ACCOUNTS}, None


def handle_get_beneficiaries(tool_input: dict, ctx: dict) -> tuple[dict, None]:
    items = [
        {"name": b["name"], "arabic": b["arabic"], "account": b["account"]}
        for b in mock_bank.BENEFICIARIES
    ]
    return {"beneficiaries": items}, None


def handle_get_bills(tool_input: dict, ctx: dict) -> tuple[dict, None]:
    items = [
        {k: b[k] for k in ("name", "arabic", "biller", "amount_display", "due_date")}
        for b in mock_bank.BILLS
    ]
    return {"bills": items}, None


def handle_get_products(tool_input: dict, ctx: dict) -> tuple[dict, None]:
    category = tool_input.get("category", "all")
    if category == "all":
        return {"products": mock_bank.PRODUCTS}, None
    return {"products": {category: mock_bank.PRODUCTS[category]}}, None


def handle_get_transactions(tool_input: dict, ctx: dict) -> tuple[dict, None]:
    limit = tool_input.get("limit") or 10
    limit = max(1, min(int(limit), len(mock_bank.TRANSACTIONS)))
    return {
        "transactions": mock_bank.TRANSACTIONS[:limit],
        "total_available": len(mock_bank.TRANSACTIONS),
    }, None


def handle_initiate_transfer(tool_input: dict, ctx: dict) -> tuple[dict, dict | None]:
    beneficiary = mock_bank.find_beneficiary(str(tool_input["beneficiary"]))
    if beneficiary is None:
        new_account = tool_input.get("new_beneficiary_account")
        if new_account:
            # No dedicated "add beneficiary" screen exists in the app — the first
            # transfer to a not-yet-saved name/account IS how they get added.
            # txn_count=0 is what makes the risk gate treat this as a new
            # beneficiary (see decision_agent/features.py: is_new_beneficiary).
            beneficiary = {
                "name": str(tool_input["beneficiary"]).strip(),
                "account": str(new_account).strip(),
                "txn_count": 0,
            }
        else:
            return _error(
                "unknown_beneficiary",
                f"'{tool_input['beneficiary']}' is not a saved beneficiary. "
                "Ask the user for their IBAN/account number to send to them anyway.",
                known=[b["name"] for b in mock_bank.BENEFICIARIES],
            )
    amount = float(tool_input["amount"])
    source = mock_bank.find_account(None)

    decision = get_decision_agent().decide(
        _risk_features(amount, source, beneficiary["txn_count"])
    )
    # Payload matches ReviewScreen(beneficiary, amount, note, transferType, reference)
    payload = {
        "beneficiary": f"{beneficiary['name']} - {beneficiary['account']}",
        "amount": f"{amount:g}",
        "note": str(tool_input.get("note", "")),
        "transfer_type": "Local Transfer",
        "reference": tool_input.get("reason") or "Other",
    }
    envelope = route_from_decision("transfer", payload, decision)
    return _prepared_result(envelope), envelope


def handle_pay_bill(tool_input: dict, ctx: dict) -> tuple[dict, dict | None]:
    bill = mock_bank.find_bill(str(tool_input["bill_name"]))
    if bill is None:
        return _error(
            "unknown_bill",
            f"'{tool_input['bill_name']}' is not a saved bill.",
            known=[b["name"] for b in mock_bank.BILLS],
        )
    source = mock_bank.find_account(tool_input.get("account"))
    decision = get_decision_agent().decide(
        _risk_features(bill["amount"], source, beneficiary_txn_count=6)
    )
    # Payload matches BillReviewScreen(BillPayment{bill, account, amount})
    payload = {
        "bill": {
            "name": bill["name"],
            "biller": bill["biller"],
            "account_number": bill["account_number"],
            "amount": bill["amount_display"],
            "due_date": bill["due_date"],
            "category": bill["category"],
        },
        "account": source["iban_masked"],
        "amount": bill["amount_display"],
    }
    envelope = route_from_decision("bill", payload, decision)
    return _prepared_result(envelope), envelope


def handle_open_account(tool_input: dict, ctx: dict) -> tuple[dict, dict]:
    # Payload matches ReviewAccountScreen(AccountApplication{accountType, currency, shortName})
    payload = {
        "account_type": tool_input["account_type"],
        "currency": tool_input["currency"],
        "short_name": str(tool_input["short_name"]).strip(),
    }
    envelope = non_monetary_envelope("account", payload)
    return _prepared_result(envelope), envelope


def handle_request_card(tool_input: dict, ctx: dict) -> tuple[dict, dict]:
    linked = mock_bank.find_account(tool_input.get("linked_account"))
    card_type = tool_input["card_type"]
    product = next((c for c in mock_bank.PRODUCTS["cards"] if c["type"] == card_type), None)
    payload = {
        "card_type": card_type,
        "network": product["network"] if product else card_type,
        "linked_account": linked["iban_masked"],
    }
    envelope = non_monetary_envelope("card", payload)
    return _prepared_result(envelope), envelope


def handle_apply_for_product(tool_input: dict, ctx: dict) -> tuple[dict, dict | None]:
    product = mock_bank.find_product(str(tool_input["product_name"]))
    if product is None:
        return _error(
            "unknown_product",
            f"'{tool_input['product_name']}' is not one of Ameen's bank products.",
            known=[p["name"] for p in mock_bank.PRODUCTS["bank_products"]],
        )
    amount = float(tool_input["amount"])
    if amount <= 0:
        return _error("invalid_amount", "Amount must be greater than 0.")
    if product["max_amount"] and amount > product["max_amount"]:
        return _error(
            "amount_over_hard_limit",
            f"{product['name']} allows at most {product['max_amount']:,.0f} SAR.",
        )
    duration = int(tool_input["duration_months"])
    # Payload matches ProductReviewScreen(product: findProductByTitle(name),
    # application: ProductApplication(amount, duration))
    payload = {
        "product_name": product["name"],
        "amount": f"{amount:g} SAR",
        "duration_months": str(duration),
    }
    envelope = non_monetary_envelope("product", payload)
    return _prepared_result(envelope), envelope


HANDLERS = {
    "get_accounts": handle_get_accounts,
    "get_beneficiaries": handle_get_beneficiaries,
    "get_bills": handle_get_bills,
    "get_products": handle_get_products,
    "get_transactions": handle_get_transactions,
    "initiate_transfer": handle_initiate_transfer,
    "pay_bill": handle_pay_bill,
    "open_account": handle_open_account,
    "request_card": handle_request_card,
    "apply_for_product": handle_apply_for_product,
}

assert set(HANDLERS) == {t["name"] for t in TOOLS}, "orphan tool or handler"
