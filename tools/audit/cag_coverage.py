#!/usr/bin/env python3
"""Report active Codex CAG coverage for roles, skills, contracts, and domains."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "validate"))
from _cag_common import WORKSPACE_ROOT, discover_repo_agents, discover_skills, load_coverage, registered_roles  # noqa: E402


def scan(require_workspace: bool = False) -> dict[str, object]:
    skills = {path.parent.name for path in discover_skills()}
    domains = load_coverage().get("domains", {})
    rows: list[dict[str, object]] = []
    if isinstance(domains, dict):
        for name, item in sorted(domains.items()):
            item = item if isinstance(item, dict) else {}
            optional = item.get("optional_checkout") is True
            roots = [str(value) for value in item.get("roots", [])]
            contracts = [str(value) for value in item.get("contracts", [])]
            required = roots + contracts
            missing = [value for value in required if not (WORKSPACE_ROOT / value).exists()]
            state = "pass" if not missing else ("n/a" if optional and not require_workspace else "missing")
            rows.append({"domain": name, "status": state, "missing": missing, "skills": item.get("skills", [])})
    complete = sum(1 for row in rows if row["status"] == "pass")
    return {
        "roles": {"count": len(registered_roles()), "registered": sorted(registered_roles())},
        "skills": {"count": len(skills), "names": sorted(skills)},
        "contracts": {"count": len(discover_repo_agents())},
        "domains": {"count": len(rows), "complete": complete, "rows": rows},
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--require-workspace", action="store_true")
    parser.add_argument("--format", choices=["text", "json"], default="text")
    args = parser.parse_args()
    report = scan(args.require_workspace)
    if args.format == "json":
        print(json.dumps(report, indent=2))
    else:
        print(f"roles={report['roles']['count']} skills={report['skills']['count']} contracts={report['contracts']['count']}")
        for row in report["domains"]["rows"]:
            suffix = "" if not row["missing"] else " missing=" + ",".join(row["missing"])
            print(f"{row['status']:7} {row['domain']}{suffix}")
    return 0 if all(row["status"] == "pass" for row in report["domains"]["rows"]) else 1


if __name__ == "__main__":
    raise SystemExit(main())
