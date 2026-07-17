# Ameen Agent — Handover

Backend agent layer for the Ameen banking app: an Arabic-first assistant that
**prepares** banking operations behind an ML risk gate. Execution never happens
in the agent — it always happens in the Flutter Review → OTP flow. This document
is the fast path for the next engineer/agent picking up the service.

## Architecture (current)

One **OrchestratorAgent** owns the session, the context window, and routing. It
delegates each turn to one of three **LLM specialists**, which all run the SAME
tool-use loop (a specialist is a config, not a new loop). A deterministic
**DecisionAgent** (non-LLM) is the risk gate, consulted inside the transactions
specialist's money handlers only.

```
OrchestratorAgent (agent/orchestrator.py)   routing + session + context window
  ├─ inquiry       read-only tools            → never emits an envelope
  ├─ transactions  transfer/bill (risk-gated) → REVIEW_TRANSFER|REVIEW_BILL|STEP_UP_VERIFY|DECLINED
  └─ servicing     card/account lifecycle     → REVIEW_CARD|REVIEW_ACCOUNT
DecisionAgent (decision_agent/)  Rule Engine → XGBoost fraud + IsolationForest anomaly
```

Routing is hybrid, cheapest first: keyword/regex → sticky specialist (session
remembers the active one for follow-ups like "نعم أكد") → one small LLM classify
for ambiguous messages → greetings answered inline with no specialist hop.

## Key files

| Path | Responsibility |
|------|----------------|
| `agent/orchestrator.py` | Routing, session load/persist, per-turn trace, context window ownership. Public entry: `OrchestratorAgent.run_turn(session_id, user_text, emit)`. |
| `agent/agent.py` | The shared engine: `run_specialist(...)` — one Anthropic tool-use loop parameterized by a `Specialist`. Enforces the envelope allowlist. |
| `agent/specialists.py` | `SPECIALISTS` registry. Each `Specialist` = focused prompt + tool subset (filtered from `tools.py`) + `allowed_envelopes`. |
| `agent/prompts.py` | Shared guardrail preamble + per-specialist sections + classifier prompt + canned greeting/fallback. |
| `agent/tools.py` | Tool schemas + handlers + `HANDLERS` registry. Handlers return `(result_dict, envelope|None)`; money ops go through `DecisionAgent` via `route_from_decision`. |
| `agent/llm.py` | `AnthropicLLM`, `OpenRouterLLM`, `MockLLM`; `make_llm(settings)` picks by `AMEEN_PROVIDER`. |
| `agent/context.py` | Sliding window + compression + `cap_tool_result`. |
| `agent/main.py` | FastAPI app: `/ws`, `/health`, `/metrics`; wires the orchestrator in `lifespan`. |
| `decision_agent/` | `features.py`, `train.py` (synthetic data + models), `decision_agent.py` (rules + ML gate, process singleton). |

## Hard guardrails (do not regress)

- Only the **transactions** specialist can move toward a money envelope, and only
  after `DecisionAgent.decide()` via `route_from_decision`. ALLOW is never hardcoded.
- `inquiry`/`servicing` **physically cannot** emit `REVIEW_TRANSFER`/`REVIEW_BILL`/
  `DECLINED` — enforced by tool subset AND the engine's per-specialist envelope
  allowlist, not by prompt text.
- The LLM never executes money; handlers only prepare. Execution is Flutter Review → OTP.
- A DECLINE is final — never overridden by insistence or by re-routing.
- No fabricated balances/accounts — every fact comes from a tool.
- PDPL: no server-side persistence of chat content beyond the Redis session TTL;
  audit rows store operation metadata + risk decision + trace only, never chat text.

## Run / test

```bash
# local, no infra:
AMEEN_MOCK=1 uvicorn agent.main:app --port 8000

# tests (mock mode, offline):
python decision_agent/train.py          # regenerates decision_agent/models/ (gitignored)
python agent/test_workflow.py           # 47 checks, 16 scenarios
python agent/test_routing.py            # 32 checks: routing + structural guardrails + compression
python scripts/load_test.py             # 200 sessions x 10 msgs; pass = 0 errors & p95 < 500ms

# Docker (build trains models + runs BOTH suites; a broken image fails to build):
AMEEN_MOCK=1 docker compose up --build
curl localhost:8000/health              # -> {"status":"ok",...}
```

## Config / env

`AMEEN_PROVIDER=anthropic|openrouter|mock`, `AMEEN_MODEL`, `ANTHROPIC_API_KEY`
or `OPENROUTER_API_KEY`, `REDIS_URL`, `DATABASE_URL`, `AMEEN_MOCK=1`. Missing
Redis/DB degrade to in-memory with a warning (fine for dev). See `agent/config.py`.

## Known issues / follow-ups

1. **Docker image bloat/flakiness.** xgboost pulls `nvidia-*-cu12` CUDA wheels
   (~1 GB, incl. a 303 MB nccl download that intermittently fails the pip hash
   check) on Linux. CPU inference doesn't need them — pin a CPU-only xgboost or
   exclude the CUDA wheels to shrink the image and stabilize builds.
2. **Mid-loop LLM-error rollback (pre-existing).** On a transient LLM failure
   *after* a tool round, `OrchestratorAgent.run_turn`'s `history.pop()` drops the
   trailing tool_result message and can leave a dangling `tool_use`, which would
   make the *next* turn's API call invalid. Identical to the original `run_turn`;
   not introduced by the specialist split. Fix: roll back to (and including) the
   user-text turn on failure, not just the last message.

## External contract (unchanged — Flutter depends on it)

WS `/ws` event stream: `session → status → token* → envelope? → done` (or `error`).
Envelope shape: `{type, operation, payload, risk:{action,tier,fraud_probability,reasons}, llm_may_proceed}`.
`flutter analyze` is clean against this; no Flutter change was needed for the refactor.
