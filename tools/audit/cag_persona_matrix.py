#!/usr/bin/env python3
"""Report the active registered role matrix from .codex/config.toml."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "validate"))

from _cag_common import discover_role_configs, parse_role_config, relpath

def scan() -> dict[str, object]:
    roles: dict[str, dict[str, object]] = {}
    for path in discover_role_configs():
        data = parse_role_config(path)
        name = data.get("name")
        if isinstance(name, str):
            roles[name] = {
                "file": relpath(path),
                "model": data.get("model"),
                "reasoning": data.get("model_reasoning_effort"),
                "sandbox": data.get("sandbox_mode"),
                "approval": data.get("approval_policy"),
            }

    errors: list[str] = []
    if not roles:
        errors.append("no active registered roles discovered")
    return {"roles": roles, "count": len(roles), "errors": errors}


def format_text(report: dict[str, object]) -> str:
    roles: dict[str, dict[str, object]] = report["roles"]  # type: ignore[assignment]
    lines = ["Active agent roles:"]
    for name in sorted(roles):
        role = roles[name]
        lines.append(
            f"  {name:<14} model={role['model']} reasoning={role['reasoning']} "
            f"sandbox={role['sandbox']} approval={role['approval']}"
        )
    for error in report["errors"]:  # type: ignore[index]
        lines.append("ERROR: " + error)
    return "\n".join(lines)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--format", choices=("text", "json"), default="text")
    args = parser.parse_args(argv)
    report = scan()
    if args.format == "json":
        print(json.dumps(report, indent=2, sort_keys=True))
    else:
        print(format_text(report))
    return 1 if report["errors"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
