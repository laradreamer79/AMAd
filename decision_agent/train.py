"""Train the Ameen risk models: XGBoost fraud classifier + IsolationForest anomaly detector.

Generates synthetic transaction data whose fraud/legit feature distributions
deliberately overlap (plus label noise), so the resulting AUC is realistic
(0.90-0.95). An AUC of ~1.0 means the synthetic data leaks the label — the
script fails loudly in that case.

Run:  cd decision_agent && python train.py
"""

import sys
from pathlib import Path

import joblib
import numpy as np
from sklearn.ensemble import IsolationForest
from sklearn.metrics import roc_auc_score
from sklearn.model_selection import train_test_split
from xgboost import XGBClassifier

from features import FEATURE_NAMES

MODELS_DIR = Path(__file__).parent / "models"
SEED = 42
N_LEGIT = 40_000
N_FRAUD = 4_000
LABEL_NOISE = 0.01  # fraction of flipped labels: keeps AUC out of the ~1.0 leak zone


def _clip_hours(h: np.ndarray) -> np.ndarray:
    return np.clip(np.round(h), 0, 23)


def generate_legit(rng: np.random.Generator, n: int) -> np.ndarray:
    balance = rng.lognormal(mean=10.2, sigma=0.9, size=n)          # ~27k SAR median
    amount = rng.lognormal(mean=6.0, sigma=1.1, size=n)            # ~400 SAR median
    amount = np.minimum(amount, balance * rng.uniform(0.05, 0.9, n))
    hour = _clip_hours(rng.normal(14, 5, n))                       # daytime-centred
    is_new_beneficiary = (rng.random(n) < 0.18).astype(float)
    txn_count_24h = rng.poisson(1.6, n).astype(float)
    amount_vs_avg = rng.lognormal(mean=0.0, sigma=0.55, size=n)    # around 1x average
    beneficiary_txn_count = np.where(
        is_new_beneficiary > 0, 0.0, rng.poisson(7, n).astype(float)
    )
    account_age_days = rng.uniform(60, 3600, n)
    return np.column_stack([
        amount,
        amount / np.maximum(balance, 1.0),
        hour,
        is_new_beneficiary,
        txn_count_24h,
        amount_vs_avg,
        beneficiary_txn_count,
        account_age_days,
    ])


def generate_fraud(rng: np.random.Generator, n: int) -> np.ndarray:
    balance = rng.lognormal(mean=10.0, sigma=0.9, size=n)
    # Fraud amounts skew higher but overlap with the legit tail.
    amount = rng.lognormal(mean=7.9, sigma=1.1, size=n)            # ~2.7k SAR median
    amount = np.minimum(amount, balance * rng.uniform(0.25, 1.0, n))
    # Mixture: most night-time, the rest blends in with daytime traffic.
    night = rng.random(n) < 0.68
    hour = np.where(night, _clip_hours(rng.normal(3, 3, n)), _clip_hours(rng.normal(14, 5, n)))
    is_new_beneficiary = (rng.random(n) < 0.78).astype(float)
    txn_count_24h = rng.poisson(4.8, n).astype(float)
    amount_vs_avg = rng.lognormal(mean=1.6, sigma=0.75, size=n)    # bigger than usual, noisy
    beneficiary_txn_count = np.where(
        is_new_beneficiary > 0, 0.0, rng.poisson(2, n).astype(float)
    )
    account_age_days = rng.uniform(10, 3600, n)                    # slight skew to newer
    return np.column_stack([
        amount,
        amount / np.maximum(balance, 1.0),
        hour,
        is_new_beneficiary,
        txn_count_24h,
        amount_vs_avg,
        beneficiary_txn_count,
        account_age_days,
    ])


def main() -> int:
    rng = np.random.default_rng(SEED)

    x = np.vstack([generate_legit(rng, N_LEGIT), generate_fraud(rng, N_FRAUD)])
    y = np.concatenate([np.zeros(N_LEGIT), np.ones(N_FRAUD)])

    # Label noise: real fraud labels are imperfect; also prevents a leaky AUC of 1.0.
    flip = rng.random(len(y)) < LABEL_NOISE
    y_noisy = np.where(flip, 1 - y, y)

    x_train, x_test, y_train, y_test = train_test_split(
        x, y_noisy, test_size=0.25, random_state=SEED, stratify=y_noisy
    )

    clf = XGBClassifier(
        n_estimators=300,
        max_depth=4,
        learning_rate=0.08,
        subsample=0.8,
        colsample_bytree=0.8,
        scale_pos_weight=(y_train == 0).sum() / max((y_train == 1).sum(), 1),
        eval_metric="auc",
        random_state=SEED,
        n_jobs=-1,
    )
    clf.fit(x_train, y_train)
    auc = roc_auc_score(y_test, clf.predict_proba(x_test)[:, 1])

    iso = IsolationForest(
        n_estimators=200, contamination=0.03, random_state=SEED, n_jobs=-1
    )
    iso.fit(x_train[y_train == 0])  # learn "normal" from legit transactions only

    print(f"features: {FEATURE_NAMES}")
    print(f"train={len(x_train)} test={len(x_test)} fraud_rate={y_noisy.mean():.3f}")
    print(f"XGBoost test AUC = {auc:.4f}")

    if auc >= 0.96:
        print("FAIL: AUC is unrealistically high — synthetic data leaks the label.")
        return 1
    if auc < 0.90:
        print("FAIL: AUC too low — model is not learning the signal.")
        return 1

    MODELS_DIR.mkdir(exist_ok=True)
    joblib.dump(clf, MODELS_DIR / "xgb_fraud.joblib")
    joblib.dump(iso, MODELS_DIR / "isolation_forest.joblib")
    joblib.dump({"feature_names": FEATURE_NAMES, "auc": auc}, MODELS_DIR / "meta.joblib")
    print(f"saved models to {MODELS_DIR}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
