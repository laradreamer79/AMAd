"""Ameen risk gate: deterministic Rule Engine -> XGBoost + IsolationForest -> action.

Runs BEFORE the LLM is allowed to prepare any money operation. The output is
final: the LLM cannot override a DECLINE.

    from decision_agent.decision_agent import get_decision_agent
    decision = get_decision_agent().decide({...features...})
    # {"action": "ALLOW"|"STEP_UP"|"DECLINE", "tier": ..., "fraud_probability": ...,
    #  "reasons": [...], "anomaly": bool}

Models are loaded ONCE per process (module-level singleton); decide() is pure
CPU (<5ms) and safe to call from async request handlers.
"""

from __future__ import annotations

import logging
import threading
from pathlib import Path

log = logging.getLogger("ameen.decision")

try:  # package import (from repo root) or flat import (from decision_agent/)
    from .features import to_vector
except ImportError:
    from features import to_vector

MODELS_DIR = Path(__file__).parent / "models"

ALLOW = "ALLOW"
STEP_UP = "STEP_UP"
DECLINE = "DECLINE"

# Deterministic limits — these are policy, not statistics.
HARD_LIMIT_SAR = 50_000.0
NEW_BENEFICIARY_STEP_UP_SAR = 5_000.0
NIGHT_STEP_UP_SAR = 10_000.0
MAX_TXN_24H = 15

FRAUD_DECLINE_THRESHOLD = 0.70
FRAUD_STEP_UP_THRESHOLD = 0.30

_TIER_BY_ACTION = {ALLOW: "LOW", STEP_UP: "MEDIUM", DECLINE: "CRITICAL"}


class _FastIsolationForest:
    """Numpy re-implementation of IsolationForest scoring for single rows.

    sklearn's predict() carries ~30ms of per-call overhead (validation + joblib
    dispatch per tree), which blows the <5ms budget for decide(). Extracting the
    fitted trees into flat arrays once at load time makes a single-row score
    ~0.2ms while producing the exact same anomaly verdict (validated in
    test_workflow.py against sklearn on random inputs).
    """

    def __init__(self, iso) -> None:
        self.offset_ = float(iso.offset_)
        self.max_samples_ = int(iso.max_samples_)
        self._trees = []
        for est in iso.estimators_:
            t = est.tree_
            # plain lists: python scalar indexing is ~5x faster than numpy here;
            # per-leaf average path length is constant, so precompute it
            leaf_apl = [self._avg_path_length(float(n)) for n in t.n_node_samples]
            self._trees.append((
                t.children_left.tolist(),
                t.children_right.tolist(),
                t.feature.tolist(),
                t.threshold.tolist(),
                leaf_apl,
            ))
        self._denom = len(self._trees) * self._avg_path_length(float(self.max_samples_))

    @staticmethod
    def _avg_path_length(n: float) -> float:
        import math

        if n <= 1:
            return 0.0
        if n == 2:
            return 1.0
        return 2.0 * (math.log(n - 1.0) + 0.5772156649) - 2.0 * (n - 1.0) / n

    def is_anomaly(self, vec: list) -> bool:
        depths = 0.0
        for left, right, feature, threshold, leaf_apl in self._trees:
            node, path_nodes = 0, 1
            while left[node] != -1:  # -1 marks a leaf
                node = left[node] if vec[feature[node]] <= threshold[node] else right[node]
                path_nodes += 1
            depths += path_nodes + leaf_apl[node] - 1.0
        score = -(2.0 ** (-depths / self._denom))  # sklearn's score_samples convention
        return (score - self.offset_) < 0


class DecisionAgent:
    def __init__(self) -> None:
        self._booster = None
        self._iso = None
        self.ml_available = False
        try:
            import joblib

            clf = joblib.load(MODELS_DIR / "xgb_fraud.joblib")
            self._booster = clf.get_booster()  # raw booster, single thread:
            self._booster.set_param("nthread", 1)  # no per-call thread spin-up
            self._iso = _FastIsolationForest(joblib.load(MODELS_DIR / "isolation_forest.joblib"))
            self.ml_available = True
            log.info("decision models loaded from %s", MODELS_DIR)
        except Exception as exc:  # noqa: BLE001 - degrade to rules-only, never crash startup
            log.warning("ML models unavailable (%s) — running rules-only risk gate", exc)

    # ---------------------------------------------------------------- rules
    def _apply_rules(self, f: dict) -> tuple[str | None, str | None, list[str]]:
        """Returns (forced_action, floor_action, reasons). forced_action is final."""
        reasons: list[str] = []
        amount = float(f.get("amount", 0))
        balance = float(f.get("balance", 0))

        if amount <= 0:
            return DECLINE, None, ["invalid_amount"]
        if amount > HARD_LIMIT_SAR:
            return DECLINE, None, ["amount_over_hard_limit"]
        if balance and amount > balance:
            return DECLINE, None, ["insufficient_funds"]
        if float(f.get("txn_count_24h", 0)) > MAX_TXN_24H:
            return DECLINE, None, ["velocity_limit_exceeded"]

        floor: str | None = None
        if f.get("is_new_beneficiary") and amount > NEW_BENEFICIARY_STEP_UP_SAR:
            floor = STEP_UP
            reasons.append("new_beneficiary_high_amount")
        hour = int(f.get("hour", 12))
        if (hour >= 23 or hour < 5) and amount > NIGHT_STEP_UP_SAR:
            floor = STEP_UP
            reasons.append("night_time_high_amount")
        return None, floor, reasons

    # ------------------------------------------------------------------ ml
    def _score(self, f: dict) -> tuple[float, bool]:
        if not self.ml_available:
            # Heuristic fallback so the gate still orders risk sensibly.
            amount = float(f.get("amount", 0))
            p = min(0.95, amount / HARD_LIMIT_SAR)
            if f.get("is_new_beneficiary"):
                p = min(0.95, p + 0.2)
            return p, False
        import numpy as np

        vec = to_vector(f)
        fraud_prob = float(self._booster.inplace_predict(np.array([vec], dtype=np.float32))[0])
        anomaly = self._iso.is_anomaly(vec)
        return fraud_prob, anomaly

    # -------------------------------------------------------------- decide
    def decide(self, features: dict) -> dict:
        forced, floor, reasons = self._apply_rules(features)
        if forced is not None:
            return {
                "action": forced,
                "tier": _TIER_BY_ACTION[forced],
                "fraud_probability": 1.0 if forced == DECLINE else 0.0,
                "reasons": reasons,
                "anomaly": False,
                "source": "rules",
            }

        fraud_prob, anomaly = self._score(features)

        if fraud_prob >= FRAUD_DECLINE_THRESHOLD:
            action, tier = DECLINE, "CRITICAL"
            reasons.append("high_fraud_probability")
        elif fraud_prob >= FRAUD_STEP_UP_THRESHOLD:
            action, tier = STEP_UP, "HIGH" if fraud_prob >= 0.5 else "MEDIUM"
            reasons.append("elevated_fraud_probability")
        else:
            action, tier = ALLOW, "LOW"

        if anomaly:
            reasons.append("behavioral_anomaly")
            if action == ALLOW:  # anomaly bumps the tier one level up
                action, tier = STEP_UP, "MEDIUM"
            elif action == STEP_UP:
                tier = "HIGH"

        if floor == STEP_UP and action == ALLOW:
            action, tier = STEP_UP, "MEDIUM"

        return {
            "action": action,
            "tier": tier,
            "fraud_probability": round(fraud_prob, 4),
            "reasons": reasons,
            "anomaly": bool(anomaly),
            "source": "ml" if self.ml_available else "heuristic",
        }


_singleton: DecisionAgent | None = None
_lock = threading.Lock()


def get_decision_agent() -> DecisionAgent:
    """Process-wide singleton — models load once, decide() is then pure CPU."""
    global _singleton
    if _singleton is None:
        with _lock:
            if _singleton is None:
                _singleton = DecisionAgent()
    return _singleton
