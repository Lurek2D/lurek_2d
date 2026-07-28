#!/usr/bin/env python3
"""Run deterministic release-mode render scenarios against a checked-in baseline."""
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_BASELINE = ROOT / "tests" / "artifacts" / "baselines" / "render_perf_baseline.json"
RECORD = re.compile(r"^RENDER_PERF:(\{.*\})$", re.MULTILINE)


def measure() -> dict[str, dict]:
    """Run the registered release test target and parse its stable records."""
    run = subprocess.run(
        ["cargo", "test", "--release", "--test", "render_perf_tests", "--", "--nocapture"],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=False,
    )
    output = run.stdout + "\n" + run.stderr
    if run.returncode:
        print(output, file=sys.stderr)
        raise RuntimeError("render release performance scenarios failed")
    return {record["scenario"]: record for record in map(json.loads, RECORD.findall(output))}


def main() -> int:
    """Compare workload shape and p95/p99 frame time to a reviewed baseline."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--baseline", type=Path, default=DEFAULT_BASELINE)
    parser.add_argument("--update-baseline", action="store_true")
    args = parser.parse_args()
    records = measure()
    if args.update_baseline:
        payload = {
            "backend": "software",
            "required_scenarios": sorted(records),
            "max_slowdown_ratio": 1.75,
            "scenarios": {name: records[name] for name in sorted(records)},
        }
        args.baseline.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
        return 0
    baseline = json.loads(args.baseline.read_text(encoding="utf-8"))
    required = baseline["required_scenarios"]
    missing = set(required) - set(records)
    if missing:
        print(f"[FAIL] missing render scenarios: {', '.join(sorted(missing))}")
        return 1
    failures: list[str] = []
    for name in required:
        old, new = baseline["scenarios"][name], records[name]
        for field in ("backend", "samples", "command_count", "draw_count"):
            if old[field] != new[field]:
                failures.append(f"{name}: workload field `{field}` changed")
        for field in ("p95_ns", "p99_ns"):
            if new[field] > old[field] * baseline["max_slowdown_ratio"]:
                failures.append(f"{name}: {field} timing regression")
    for failure in failures:
        print(f"[FAIL] {failure}")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
