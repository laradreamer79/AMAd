"""Shared feature definition for training and inference.

The order of FEATURE_NAMES is the model input contract — train.py and
DecisionAgent.decide() must both build vectors in this exact order.
"""

FEATURE_NAMES = [
    "amount",                 # transaction amount in SAR
    "amount_to_balance",      # amount / current balance (0..inf)
    "hour",                   # local hour of day 0-23
    "is_new_beneficiary",     # 1 if beneficiary has no prior transfers
    "txn_count_24h",          # transactions in the last 24h
    "amount_vs_avg",          # amount / user's 90-day average amount
    "beneficiary_txn_count",  # prior transfers to this beneficiary
    "account_age_days",       # age of the customer relationship
]


def to_vector(f: dict) -> list:
    """Build the model input vector from a feature dict (missing -> sane default)."""
    defaults = {
        "amount": 0.0,
        "amount_to_balance": 0.0,
        "hour": 12,
        "is_new_beneficiary": 0,
        "txn_count_24h": 1,
        "amount_vs_avg": 1.0,
        "beneficiary_txn_count": 3,
        "account_age_days": 720,
    }
    return [float(f.get(name, defaults[name])) for name in FEATURE_NAMES]
