"""
Evaluate local RAG recall against a prompt baseline for agent workflows.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

from query import search_index

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")


WORKSPACE_ROOT = Path(__file__).resolve().parent.parent.parent
BASELINE_PATH = Path(__file__).resolve().with_name("recall_baseline.json")


def _matches(path: str, expected: str) -> bool:
    if expected.endswith("/"):
        return path.startswith(expected)
    return path == expected or path.startswith(expected.rstrip("*"))


def evaluate(
    baseline_path: Path = BASELINE_PATH,
    *,
    limit: int = 10,
    db_path: Path | None = None,
) -> dict[str, Any]:
    cases = json.loads(baseline_path.read_text(encoding="utf-8"))
    results: list[dict[str, Any]] = []
    passed = 0

    for case in cases:
        query = case["query"]
        profile = case.get("profile", "all")
        expected = case.get("must_match_any", [])
        report = search_index(query, profile=profile, limit=limit, db_path_override=db_path)
        paths = [item["path"] for item in report.get("results", [])]
        ok = any(any(_matches(path, item) for path in paths) for item in expected)
        passed += int(ok)
        results.append(
            {
                "query": query,
                "profile": profile,
                "ok": ok,
                "expected_any": expected,
                "top_paths": paths[:limit],
                "error": report.get("error"),
            }
        )

    total = len(results)
    return {
        "ok": passed == total,
        "passed": passed,
        "total": total,
        "pass_rate": round((passed / total * 100.0) if total else 100.0, 2),
        "results": results,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Evaluate Lurek2D RAG recall baseline")
    parser.add_argument("--baseline", default=str(BASELINE_PATH), help="Recall baseline JSON path")
    parser.add_argument("--limit", type=int, default=10, help="Search result limit per case")
    parser.add_argument("--db", help="Override DB path for tests")
    parser.add_argument("--json", action="store_true", help="Emit JSON report")
    parser.add_argument("--output", help="Write JSON output to file")
    args = parser.parse_args()

    report = evaluate(Path(args.baseline), limit=args.limit, db_path=Path(args.db) if args.db else None)
    if args.output:
        Path(args.output).write_text(json.dumps(report, ensure_ascii=False), encoding="utf-8")
    elif args.json:
        print(json.dumps(report, ensure_ascii=False))
    else:
        print(f"RAG recall: {report['passed']}/{report['total']} ({report['pass_rate']}%)")
        for item in report["results"]:
            marker = "OK" if item["ok"] else "FAIL"
            print(f"- {marker} [{item['profile']}] {item['query']}")
            if not item["ok"]:
                print(f"  expected any: {', '.join(item['expected_any'])}")
                print(f"  top paths: {', '.join(item['top_paths'][:5])}")
    sys.exit(0 if report["ok"] else 1)


if __name__ == "__main__":
    main()
