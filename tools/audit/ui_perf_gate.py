#!/usr/bin/env python3
"""Run release-mode UI scenarios and compare them to a reviewed baseline."""
from __future__ import annotations
import argparse, json, re, subprocess, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_BASELINE = ROOT / "tests" / "artifacts" / "baselines" / "ui_perf_baseline.json"
RECORD = re.compile(r"^UI_PERF:(\{.*\})$", re.MULTILINE)

def measure() -> dict[str, dict]:
    run = subprocess.run(["cargo", "test", "--release", "--test", "ui_perf_tests", "--", "--nocapture"], cwd=ROOT, text=True, capture_output=True)
    output = run.stdout + "\n" + run.stderr
    if run.returncode:
        print(output, file=sys.stderr); raise RuntimeError("UI release performance scenarios failed")
    return {record["scenario"]: record for record in map(json.loads, RECORD.findall(output))}

def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--baseline", type=Path, default=DEFAULT_BASELINE)
    parser.add_argument("--update-baseline", action="store_true")
    args = parser.parse_args(); baseline = json.loads(args.baseline.read_text(encoding="utf-8")); records = measure()
    required = baseline["required_scenarios"]; missing = set(required) - set(records)
    if missing: print(f"[FAIL] missing UI scenarios: {', '.join(sorted(missing))}"); return 1
    if args.update_baseline:
        baseline["scenarios"] = {name: records[name] for name in required}; args.baseline.write_text(json.dumps(baseline, indent=2) + "\n", encoding="utf-8"); return 0
    failures = []
    for name in required:
        old, new = baseline["scenarios"][name], records[name]
        if old["iterations"] != new["iterations"] or old["widgets"] != new["widgets"]: failures.append(f"{name}: workload changed")
        elif new["elapsed_ns"] > old["elapsed_ns"] * baseline["max_slowdown_ratio"]: failures.append(f"{name}: timing regression")
    for failure in failures: print(f"[FAIL] {failure}")
    return 1 if failures else 0
if __name__ == "__main__": raise SystemExit(main())
