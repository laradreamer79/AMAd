"""Load test: 200 concurrent WebSocket sessions x 10 messages against AMEEN_MOCK=1.

Run:  python scripts/load_test.py            (spawns its own mock server)
      python scripts/load_test.py --url ws://host:port/ws   (test a running one)

Passing = 0 errors and p95 < 500 ms per message (send -> done).
"""

from __future__ import annotations

import argparse
import asyncio
import json
import os
import subprocess
import sys
import time
import urllib.request
from pathlib import Path

import websockets

REPO_ROOT = Path(__file__).resolve().parent.parent
SESSIONS = 200
MESSAGES_PER_SESSION = 10
P95_TARGET_MS = 500.0
WORKERS = 4  # the service is stateless — scale exactly like production would

# 10 distinct messages -> exactly the per-minute rate limit, never beyond it.
SCRIPT = [
    "كم رصيدي؟",
    "وش المنتجات المتاحة؟",
    "أعطني آخر العمليات",
    "حول 300 ريال إلى عمر",
    "من هم المستفيدين؟",
    "ادفع فاتورة الكهرباء",
    "حول 6000 ريال إلى زين",
    "أبغى بطاقة Gold جديدة",
    "أبغى افتح حساب توفير",
    "شكراً لك",
]


async def run_session(url: str, idx: int, latencies: list[float], errors: list[str]) -> None:
    try:
        async with websockets.connect(url, open_timeout=30, close_timeout=5) as ws:
            hello = json.loads(await ws.recv())
            if hello.get("type") != "session":
                errors.append(f"s{idx}: no session handshake")
                return
            for m, text in enumerate(SCRIPT):
                start = time.perf_counter()
                await ws.send(json.dumps({"type": "message", "text": text}))
                while True:
                    event = json.loads(await asyncio.wait_for(ws.recv(), timeout=30))
                    if event["type"] == "error":
                        errors.append(f"s{idx} m{m}: {event.get('code')} {event.get('message')}")
                    if event["type"] == "done":
                        break
                latencies.append((time.perf_counter() - start) * 1000)
    except Exception as exc:  # noqa: BLE001
        errors.append(f"s{idx}: {type(exc).__name__}: {exc}")


def percentile(values: list[float], pct: float) -> float:
    if not values:
        return 0.0
    values = sorted(values)
    return values[min(len(values) - 1, int(round(pct / 100 * (len(values) - 1))))]


def wait_for_health(base: str, timeout_s: float = 60.0) -> None:
    deadline = time.time() + timeout_s
    while time.time() < deadline:
        try:
            with urllib.request.urlopen(f"{base}/health", timeout=2) as resp:
                if resp.status == 200:
                    return
        except Exception:  # noqa: BLE001
            time.sleep(0.5)
    raise RuntimeError("server did not become healthy in time")


async def warm_up(ws_url: str) -> None:
    """One full message round-trip so the worker is hot before measuring."""
    async with websockets.connect(ws_url, open_timeout=10) as ws:
        await ws.recv()  # session handshake
        await ws.send(json.dumps({"type": "message", "text": "كم رصيدي؟"}))
        while json.loads(await asyncio.wait_for(ws.recv(), timeout=15))["type"] != "done":
            pass


def _kill(proc: subprocess.Popen) -> None:
    if os.name == "nt":  # kill the whole tree on Windows
        subprocess.run(["taskkill", "/PID", str(proc.pid), "/T", "/F"],
                       capture_output=True, check=False)
    else:
        proc.terminate()
    proc.wait(timeout=10)


async def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--url", default=None, help="ws URL of a running server")
    parser.add_argument("--port", type=int, default=8100)
    args = parser.parse_args()

    # The service is stateless (sessions in Redis/in-memory per sticky WS), so
    # production runs N workers behind a load balancer. This script models
    # exactly that: N single-worker servers, sessions sharded round-robin.
    servers: list[subprocess.Popen] = []
    if args.url:
        ws_urls = [args.url]
    else:
        env = {**os.environ, "AMEEN_MOCK": "1"}
        ports = [args.port + i for i in range(WORKERS)]
        for port in ports:
            servers.append(subprocess.Popen(
                [sys.executable, "-m", "uvicorn", "agent.main:app",
                 "--port", str(port), "--log-level", "warning"],
                cwd=REPO_ROOT, env=env,
            ))
        try:
            for port in ports:
                wait_for_health(f"http://127.0.0.1:{port}", timeout_s=120)
            ws_urls = [f"ws://127.0.0.1:{port}/ws" for port in ports]
            await asyncio.gather(*(warm_up(u) for u in ws_urls))
        except Exception:
            for proc in servers:
                _kill(proc)
            raise

    latencies: list[float] = []
    errors: list[str] = []
    started = time.perf_counter()
    try:
        await asyncio.gather(
            *(run_session(ws_urls[i % len(ws_urls)], i, latencies, errors)
              for i in range(SESSIONS))
        )
    finally:
        for proc in servers:
            _kill(proc)

    elapsed = time.perf_counter() - started
    expected = SESSIONS * MESSAGES_PER_SESSION
    p50, p95 = percentile(latencies, 50), percentile(latencies, 95)
    print(f"sessions={SESSIONS} messages={len(latencies)}/{expected} elapsed={elapsed:.1f}s")
    print(f"p50={p50:.1f}ms  p95={p95:.1f}ms  max={max(latencies or [0]):.1f}ms")
    print(f"errors={len(errors)}")
    for err in errors[:10]:
        print("  ", err)

    ok = not errors and len(latencies) == expected and p95 < P95_TARGET_MS
    print("RESULT:", "PASS" if ok else f"FAIL (targets: 0 errors, p95 < {P95_TARGET_MS:.0f}ms)")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(asyncio.run(main()))
