#!/usr/bin/env python3
"""Run release-mode sprite scenarios and enforce their checked-in performance baseline.

The gate measures the sprite module's bounded sheet, atlas, packing, and
animator paths. It requires all scenarios from the baseline, records operation
metadata emitted by Rust, and rejects a per-scenario regression beyond the
configured slowdown ratio. Use --update-baseline only after reviewing a
release-mode measurement on the reference machine.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_BASELINE = ROOT / "tests" / "artifacts" / "baselines" / "sprite_perf_baseline.json"
RECORD = re.compile(r"^SPRITE_PERF:(\{.*\})$", re.MULTILINE)


def measure() -> dict[str, dict[str, int | str]]:
    result = subprocess.run(
        ["cargo", "test", "--release", "--test", "sprite_perf_tests", "--", "--nocapture"],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=False,
    )
    output = result.stdout + "\n" + result.stderr
    if result.returncode:
        print(output, file=sys.stderr)
        raise RuntimeError("release sprite performance scenarios failed")
    records: dict[str, dict[str, int | str]] = {}
    for raw in RECORD.findall(output):
        record = json.loads(raw)
        scenario = record.get("scenario")
        if not isinstance(scenario, str) or not isinstance(record.get("elapsed_ns"), int):
            raise RuntimeError("malformed SPRITE_PERF record")
        records[scenario] = record
    return records


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--baseline", type=Path, default=DEFAULT_BASELINE)
    parser.add_argument("--update-baseline", action="store_true")
    args = parser.parse_args()
    baseline = json.loads(args.baseline.read_text(encoding="utf-8"))
    records = measure()
    required = baseline.get("required_scenarios", [])
    missing = sorted(set(required) - set(records))
    if missing:
        print(f"[FAIL] missing sprite performance scenarios: {', '.join(missing)}")
        return 1

    for scenario in required:
        record = records[scenario]
        print(
            f"[INFO] {scenario}: elapsed_ns={record['elapsed_ns']} "
            f"iterations={record['iterations']} units={record['units']} json_bytes={record['json_bytes']}"
        )

    if args.update_baseline:
        baseline["scenarios"] = {scenario: records[scenario] for scenario in required}
        args.baseline.write_text(json.dumps(baseline, indent=2) + "\n", encoding="utf-8")
        print(f"[OK] updated {args.baseline.relative_to(ROOT)}")
        return 0

    expected = baseline.get("scenarios")
    if not isinstance(expected, dict):
        print("[FAIL] baseline has no measurements; rerun with --update-baseline")
        return 1
    ratio = float(baseline.get("max_slowdown_ratio", 1.0))
    failures: list[str] = []
    for scenario in required:
        old = expected.get(scenario, {})
        new = records[scenario]
        if old.get("iterations") != new["iterations"] or old.get("units") != new["units"] or old.get("json_bytes") != new["json_bytes"]:
            failures.append(f"{scenario}: workload metadata changed")
            continue
        limit = int(old["elapsed_ns"]) * ratio
        if int(new["elapsed_ns"]) > limit:
            failures.append(f"{scenario}: {new['elapsed_ns']}ns exceeds {limit:.0f}ns")
    if failures:
        for failure in failures:
            print(f"[FAIL] {failure}")
        return 1
    print("[OK] sprite release performance gate passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
