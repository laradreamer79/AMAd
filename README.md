# Ameen

Ameen is an Arabic-first digital banking platform that combines a modern Flutter mobile experience with an intelligent backend agent service. It is designed to help customers manage accounts, pay bills, review products, and interact with a secure AI banking assistant while protecting money flows with a risk-gated decision engine.

## Product Overview

Ameen includes two main components:

- **Flutter mobile app** (`lib/`): a polished banking UI offering home, bills, cards, products, services, transfers, and an AI assistant screen.
- **AI agent backend** (`agent/`): a WebSocket-powered assistant service that interprets user requests, prepares banking operations, and emits structured envelopes for the Flutter app to review.

A third component protects transaction integrity:

- **Decision agent** (`decision_agent/`): a non-LLM risk gate that combines deterministic rules with machine learning models (XGBoost fraud classifier and IsolationForest anomaly detector) to decide whether a transfer or bill should be allowed, stepped up for verification, or declined.

## Core Capabilities

- Arabic-first UI with RTL support and localized text styling
- Bank account overview, cards, bills, and product discovery
- Natural language AI assistant for transfers, bill payments, and banking questions
- Risk-aware money flow: the LLM prepares actions, but execution happens through a review + OTP flow in Flutter
- Secure envelope contract between backend and frontend for safe tool routing
- Mock banking backend for local development and testing

## Example Use Cases

Ameen is trained to handle convenient banking requests in Arabic, such as:

- حول 300 ريال لعمر
- حول 500 ريال لفاطمة بسبب فاتورة
- حول 200 ريال لسارة، رقم حسابها SA1234 ← مستفيد جديد (مو محفوظ)
- ادفع فاتورة الكهرباء
- ادفع فاتورة الجوال
- ادفع مخالفة المرور
- ادفع فاتورة الجوازات
- أبي بطاقة Visa Signature
- أبي بطاقة mada
- أصدِر لي بطاقة Visa Platinum مربوطة بحسابي
- أبي أفتح حساب توفير
- افتح لي حساب جاري باسم "حساب الطوارئ"
- وش رصيدي؟
- ورّيني حساباتي
- وش المستفيدين المحفوظين عندي؟
- وش فواتيري؟
- ورّيني آخر معاملاتي
- وش المنتجات المتوفرة؟ (بطاقات/تمويل/حسابات)

Use these prompts to test the AI assistant flow and verify how the backend routes transfers, bill payments, product requests, and account inquiries.

## Architecture

- `lib/`: Flutter application and UI screens
- `lib/features/ai`: AI chat client and envelope routing logic
- `agent/`: backend agent service with routing, specialists, prompts, tool handlers, and WebSocket API
- `decision_agent/`: risk models, feature generation, and decision logic
- `docs/AGENT_HANDOVER.md`: product and architecture handover notes
- `scripts/load_test.py`: concurrent WebSocket load testing

## How It Works

1. The user interacts with the mobile app or AI assistant.
2. The AI backend receives text via WebSocket and routes it to a focused specialist.
3. The specialist uses tools and prompts to prepare bank operations.
4. Transaction operations are sent through `DecisionAgent` for risk scoring.
5. The backend emits a structured envelope to Flutter.
6. The Flutter app shows a review flow and finalizes execution with OTP, ensuring the assistant never executes money directly.

## Run Locally

Start the backend agent service in mock mode:

```bash
cd /Users/macbook/Desktop/ameen
AMEEN_MOCK=1 uvicorn agent.main:app --port 8000
```

Run the Flutter app:

```bash
flutter pub get
flutter run
```

## Tests

- Flutter widget tests: `flutter test`
- Python agent tests: `python agent/test_workflow.py` and `python agent/test_routing.py`
- Decision model training: `python decision_agent/train.py`

## Configuration

The backend can run with mock mode or real provider services.

Supported environment variables:

- `AMEEN_MOCK=1`
- `AMEEN_PROVIDER=anthropic|openrouter|mock`
- `AMEEN_MODEL`
- `ANTHROPIC_API_KEY`
- `OPENROUTER_API_KEY`
- `REDIS_URL`
- `DATABASE_URL`

If Redis or database settings are absent, the service falls back to in-memory defaults for development.

## Notes

- The app is intentionally designed so the AI assistant can prepare operations but not complete them without user review.
- Risk decisions are made in the backend before any transfer or bill can proceed.
- Audit logging stores metadata and risk decisions but avoids persisting full chat text.

## Useful Links

- `docs/AGENT_HANDOVER.md` for backend architecture and operational details
- `agent/main.py` for the WebSocket service entrypoint
- `lib/features/ai` for AI chat integration in the Flutter app
