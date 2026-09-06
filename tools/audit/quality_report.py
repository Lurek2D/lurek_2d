#!/usr/bin/env python3
"""
quality_report.py — Lurek2D master quality report.

Aggregates docs-general audit, test coverage, API validation, and module
audit into a single quality dashboard. This is the one-stop script for
assessing overall project health.

Usage:
    python tools/quality_report.py                 # full report
    python tools/quality_report.py --json          # JSON output
    python tools/quality_report.py --output FILE   # save to file
    python tools/quality_report.py --help

Exit codes:
    0  - all gates pass
    1  - one or more gates fail
    2  - fatal error
"""

import argparse
import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent.parent
TOOLS_DIR = WORKSPACE_ROOT / "tools"
MODULE_AUDIT_CANDIDATES = (
    "audit/audit_module.py",
    "audit/module_audit.py",
)

FOCUSED_GATE_SPECS = (
    (
        "lua_api_validator",
        "validate/validate_lua_api.py",
        ["src/lua_api"],
        "Lua API validator",
    ),
    (
        "unit_api_coverage",
        "audit/unit_test_api_coverage.py",
        ["--json", "--strict", "--threshold", "100"],
        "Lua unit ownership",
    ),
    (
        "example_coverage",
        "audit/example_coverage.py",
        ["--report", "--no-stubs", "--no-partials"],
        "Example coverage and structure",
    ),
    (
        "docstring_audit",
        "audit/docstring_audit.py",
        ["--json", "--check"],
        "Lua API docstrings",
    ),
)


def _run_tool(script: str, extra_args: list = None) -> dict:
    """Run a tools/ script with --json and return parsed output."""
    with tempfile.NamedTemporaryFile(suffix=".json", delete=False, mode="w") as f:
        tmp = Path(f.name)

    cmd = [sys.executable, str(TOOLS_DIR / script), "--json", "--output", str(tmp)]
    if extra_args:
        cmd.extend(extra_args)

    result = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8")

    try:
        data = json.loads(tmp.read_text(encoding="utf-8"))
    except Exception:
        snippet = (result.stderr or result.stdout or "").strip()[:400]
        data = {"error": f"{script} failed: {snippet}"}
    finally:
        tmp.unlink(missing_ok=True)

    if result.returncode not in (0, 1) and "error" not in data:
        snippet = (result.stderr or result.stdout or "").strip()[:400]
        data = {"error": f"{script} exited with {result.returncode}: {snippet}"}

    return data


def _tool_failed(payload: dict) -> bool:
    return isinstance(payload, dict) and isinstance(payload.get("error"), str)


def _run_focused_gate(name: str, script: str, args: list, label: str) -> dict:
    """Run one exact contract gate and retain only deterministic diagnostics."""
    command = [sys.executable, str(TOOLS_DIR / script), *args]
    result = subprocess.run(
        command,
        cwd=WORKSPACE_ROOT,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    output = "\n".join(part for part in (result.stdout, result.stderr) if part)
    status = "pass" if result.returncode == 0 else "fail" if result.returncode == 1 else "error"
    details: dict = {"label": label, "command": [script, *args], "exit_code": result.returncode}

    if name == "lua_api_validator":
        details.update(
            {
                "failed_files": len(re.findall(r"^\s*\[FAIL\]", output, re.MULTILINE)),
                "errors": len(re.findall(r"\[ERROR\]", output)),
                "warnings": len(re.findall(r"\[WARN\]", output)),
            }
        )
    elif name == "unit_api_coverage":
        try:
            payload = _parse_json_prefix(result.stdout)
            summary = payload.get("summary", {})
            structure = payload.get("structure", {})
            details.update(
                {
                    "total_apis": summary.get("total_apis", 0),
                    "covered_explicit": summary.get("covered_explicit", 0),
                    "coverage_pct": summary.get("pct_explicit", 0),
                    "missing_owners": summary.get("uncovered", 0),
                    "duplicate_markers": structure.get("duplicate_api_markers", 0),
                    "structure_violations": structure.get("invalid_it_blocks", 0),
                }
            )
        except (json.JSONDecodeError, TypeError, AttributeError):
            status = "error"
            details["error"] = "unit coverage did not emit valid JSON"
    elif name == "example_coverage":
        details["lint_issues"] = len(re.findall(r"^\s*\d+: \[E\d+\]", output, re.MULTILINE))
        details["e10_oversized_blocks"] = len(re.findall(r"\[E10\]", output))
        details["e4_thin_blocks"] = len(re.findall(r"\[E4\]", output))
    elif name == "docstring_audit":
        try:
            payload = _parse_json_prefix(result.stdout)
            violations = payload.get("violations", [])
            details["violations"] = len(violations) if isinstance(violations, list) else 0
        except (json.JSONDecodeError, TypeError, AttributeError):
            status = "error"
            details["error"] = "docstring audit did not emit valid JSON"

    if status == "error" and "error" not in details:
        details["error"] = output.strip()[-400:]
    details["status"] = status
    return {name: details}


def _run_focused_gates() -> dict:
    """Run the exact focused audits that the aggregate dashboard must enforce."""
    focused: dict = {}
    for name, script, args, label in FOCUSED_GATE_SPECS:
        focused.update(_run_focused_gate(name, script, args, label))
    return focused


def _focused_has_errors(focused: dict) -> bool:
    return any(item.get("status") in {"fail", "error"} for item in focused.values())


def _focused_has_tool_errors(focused: dict) -> bool:
    return any(item.get("status") == "error" for item in focused.values())


def _parse_json_prefix(text: str) -> dict:
    """Parse a JSON document followed by an optional human gate message."""
    decoder = json.JSONDecoder()
    value, _ = decoder.raw_decode(text.lstrip())
    if not isinstance(value, dict):
        raise json.JSONDecodeError("expected JSON object", text, 0)
    return value


def _module_count(module_data: dict) -> int:
    """Return the number of audited modules from the module-audit payload."""
    if isinstance(module_data, list):
        return sum(1 for item in module_data if isinstance(item, dict))
    if not isinstance(module_data, dict):
        return 0
    if isinstance(module_data.get("modules"), dict):
        return len(module_data["modules"])
    if isinstance(module_data.get("luna_modules"), dict):
        return len(module_data["luna_modules"])
    if isinstance(module_data.get("results"), dict):
        return len(module_data["results"])
    if isinstance(module_data.get("results"), list):
        return len(module_data["results"])
    return 0


def _resolve_existing_tool(candidates: tuple[str, ...]) -> str:
    """Return the first existing tools/ script from a candidate list."""
    for script in candidates:
        if (TOOLS_DIR / script).exists():
            return script
    return candidates[0]


def generate_report(
    doc_data: dict,
    test_data: dict,
    module_data: dict,
    validation_data: dict,
    focused_data: dict | None = None,
) -> str:
    """Generate the master quality Markdown report."""
    lines = [
        "# Lurek2D Quality Report",
        "",
        "## Dashboard",
        "",
        "| Metric | Value | Gate |",
        "|--------|-------|------|",
    ]

    # Doc coverage
    rust_doc = doc_data.get("rust", {})
    lua_doc = doc_data.get("lua_api", {})
    rust_doc_pct = rust_doc.get("coverage_pct", 0)
    lua_doc_pct = lua_doc.get("coverage_pct", 0)
    lines.append(f"| Rust doc coverage | {rust_doc_pct}% | {'PASS' if rust_doc_pct >= 90 else 'FAIL'} |")
    lines.append(f"| Lua API doc coverage | {lua_doc_pct}% | {'PASS' if lua_doc_pct >= 50 else 'FAIL'} |")

    # Test coverage
    rust_test = test_data.get("rust", {})
    lua_test = test_data.get("lua", {})
    rust_test_pct = rust_test.get("coverage_pct", 0)
    lua_test_pct = lua_test.get("coverage_pct", 0)
    lines.append(f"| Rust test coverage | {rust_test_pct}% | {'PASS' if rust_test_pct >= 50 else 'FAIL'} |")
    lines.append(f"| Lua test coverage | {lua_test_pct}% | {'PASS' if lua_test_pct >= 30 else 'FAIL'} |")

    # API validation
    total_issues = 0
    if isinstance(validation_data, dict):
        for game_results in validation_data.values():
            if isinstance(game_results, dict):
                for issues in game_results.values():
                    if isinstance(issues, list):
                        total_issues += len(issues)
    lines.append(f"| API validation issues | {total_issues} | {'PASS' if total_issues == 0 else 'FAIL'} |")

    if focused_data is not None:
        for key in (name for name, _, _, _ in FOCUSED_GATE_SPECS):
            item = focused_data.get(key, {"status": "error", "error": "gate result missing"})
            status = item.get("status", "error").upper()
            label = item.get("label", key)
            lines.append(f"| Focused: {label} | {status.lower()} | {status} |")

    # Module count
    luna_count = _module_count(module_data)
    lines.append(f"| Lurek2D modules | {luna_count} | — |")

    # Total items
    rust_items = rust_doc.get("total_items", 0)
    lua_fns = lua_doc.get("total_functions", 0)
    lines.append(f"| Total public Rust items | {rust_items} | — |")
    lines.append(f"| Total Lua API functions | {lua_fns} | — |")

    lines.append("")

    # Detailed sections
    lines.extend([
        "## Documentation",
        "",
        f"- **Rust**: {rust_doc.get('documented', 0)}/{rust_items} items documented ({rust_doc_pct}%)",
        f"- **Lua API**: {lua_doc.get('documented', 0)}/{lua_fns} functions documented ({lua_doc_pct}%)",
        f"- **Missing Rust docs**: {rust_doc.get('missing', 0)} items",
        f"- **Missing Lua docs**: {lua_doc.get('missing_count', 0)} functions",
        "",
    ])

    lines.extend([
        "## Test Coverage",
        "",
        f"- **Rust**: {rust_test.get('covered', 0)}/{rust_test.get('total', 0)} functions covered ({rust_test_pct}%)",
        f"- **Lua**: {lua_test.get('covered', 0)}/{lua_test.get('total', 0)} functions covered ({lua_test_pct}%)",
        "",
    ])

    lines.extend([
        "## API Validation",
        "",
        f"- **Issues found**: {total_issues}",
        "",
    ])

    if focused_data is not None:
        lines.extend(["## Focused Gates", ""])
        for key, _, _, _ in FOCUSED_GATE_SPECS:
            item = focused_data.get(key, {"status": "error", "error": "gate result missing"})
            status = item.get("status", "error").upper()
            label = item.get("label", key)
            details = []
            for detail_key in (
                "failed_files",
                "errors",
                "warnings",
                "coverage_pct",
                "missing_owners",
                "duplicate_markers",
                "structure_violations",
                "lint_issues",
                "e10_oversized_blocks",
                "e4_thin_blocks",
                "violations",
            ):
                if detail_key in item:
                    details.append(f"{detail_key}={item[detail_key]}")
            if item.get("error"):
                details.append(str(item["error"]))
            suffix = f" ({', '.join(details)})" if details else ""
            lines.append(f"- **{label}**: {status}{suffix}")
        lines.append("")

    if total_issues > 0 and isinstance(validation_data, dict):
        for game_name, game_results in sorted(validation_data.items()):
            if isinstance(game_results, dict):
                game_issues = sum(
                    len(issues) for issues in game_results.values()
                    if isinstance(issues, list)
                )
                if game_issues > 0:
                    lines.append(f"  - **{game_name}**: {game_issues} issues")
        lines.append("")

    if _tool_failed(doc_data) or _tool_failed(test_data) or _tool_failed(module_data) or _tool_failed(validation_data):
        lines.extend([
            "## Tool Errors",
            "",
        ])
        for label, payload in (
            ("docs-general audit", doc_data),
            ("test coverage", test_data),
            ("module audit", module_data),
            ("API validation", validation_data),
        ):
            if _tool_failed(payload):
                lines.append(f"- **{label}**: {payload['error']}")
        lines.append("")

    # Overall verdict
    all_pass = (
        not _tool_failed(doc_data)
        and not _tool_failed(test_data)
        and not _tool_failed(module_data)
        and not _tool_failed(validation_data)
        and rust_doc_pct >= 90
        and lua_doc_pct >= 50
        and rust_test_pct >= 50
        and lua_test_pct >= 30
        and total_issues == 0
        and (focused_data is None or not _focused_has_errors(focused_data))
    )
    lines.extend([
        "## Overall Verdict",
        "",
        f"**{'PASS' if all_pass else 'FAIL'}**",
        "",
    ])

    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Lurek2D master quality report",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument("--json", action="store_true",
                        help="Output structured JSON")
    parser.add_argument("--output", metavar="FILE",
                        help="Save report to file")
    args = parser.parse_args()

    print("[1/4] Running docs-general audit...", file=sys.stderr)
    doc_data = _run_tool("audit/doc_audit.py")

    print("[2/4] Running test coverage analysis...", file=sys.stderr)
    test_data = _run_tool("audit/test_coverage.py")

    print("[3/4] Running module audit...", file=sys.stderr)
    module_data = _run_tool(_resolve_existing_tool(MODULE_AUDIT_CANDIDATES), ["--all"])

    print("[4/4] Running API validation...", file=sys.stderr)
    validation_data = _run_tool("validate/validate_game.py", ["--all-examples"])

    print("[focused] Running exact contract gates...", file=sys.stderr)
    focused_data = _run_focused_gates()

    if args.json:
        report = json.dumps({
            "docs-general": doc_data,
            "test_coverage": test_data,
            "modules": module_data,
            "validation": validation_data,
            "focused_gates": focused_data,
        }, indent=2, ensure_ascii=False)
    else:
        report = generate_report(doc_data, test_data, module_data, validation_data, focused_data)

    if args.output:
        Path(args.output).parent.mkdir(parents=True, exist_ok=True)
        Path(args.output).write_text(report, encoding="utf-8")
        print(f"[OK] Report saved to {args.output}", file=sys.stderr)
    else:
        print(report)

    if any(_tool_failed(payload) for payload in (doc_data, test_data, module_data, validation_data)):
        return 2
    if _focused_has_tool_errors(focused_data):
        return 2
    if _focused_has_errors(focused_data):
        return 1
    return 0


if __name__ == "__main__":
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")  # type: ignore[attr-defined]
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")  # type: ignore[attr-defined]
    except AttributeError:
        pass
    sys.exit(main())
