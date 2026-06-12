#!/usr/bin/env python3
"""Shared lock for Lua artifact maintenance tools.

Serializes operations that read or rewrite `tests/artifacts/baselines/` so
audits do not observe a half-reseeded tree while `reseed_lua_artifacts.py
--clean` is rebuilding the baselines.
"""

from __future__ import annotations

import json
import os
import time
from contextlib import contextmanager
from pathlib import Path
from typing import Iterator


ROOT = Path(__file__).resolve().parents[2]
LOCK_PATH = ROOT / "tests" / "artifacts" / ".lua_artifacts.lock"


@contextmanager
def lua_artifact_lock(
    holder: str, timeout_s: float = 180.0, poll_s: float = 0.1
) -> Iterator[None]:
    """Acquire an exclusive lock for Lua artifact baseline operations."""
    LOCK_PATH.parent.mkdir(parents=True, exist_ok=True)
    deadline = time.monotonic() + timeout_s
    payload = {
        "holder": holder,
        "pid": os.getpid(),
        "created_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    }

    while True:
        try:
            fd = os.open(str(LOCK_PATH), os.O_CREAT | os.O_EXCL | os.O_WRONLY)
            break
        except FileExistsError:
            if time.monotonic() >= deadline:
                try:
                    existing = LOCK_PATH.read_text(encoding="utf-8").strip()
                except OSError:
                    existing = "<unreadable>"
                raise TimeoutError(
                    f"timed out waiting for Lua artifact lock at {LOCK_PATH} "
                    f"held by {existing}"
                )
            time.sleep(poll_s)

    try:
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
            json.dump(payload, handle)
            handle.write("\n")
        yield
    finally:
        try:
            LOCK_PATH.unlink()
        except FileNotFoundError:
            pass
