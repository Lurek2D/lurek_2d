#!/usr/bin/env python3
"""Expose Lurek2D RAG and repo quality audits as a minimal stdio MCP server."""

from __future__ import annotations

import json
import time
import subprocess
import sys
import tempfile
import traceback
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Callable


REPO_ROOT = Path(__file__).resolve().parents[2]
PYTHON = sys.executable
SERVER_NAME = "lurek-tools"
SERVER_VERSION = "0.2.0"
RAG_MIN_LIMIT = 1
RAG_MAX_LIMIT = 25


@dataclass(frozen=True)
class ToolSpec:
    name: str
    description: str
    input_schema: dict[str, Any]
    handler: Callable[[dict[str, Any]], dict[str, Any]]


def _json_rpc_result(request_id: Any, result: dict[str, Any]) -> dict[str, Any]:
    return {"jsonrpc": "2.0", "id": request_id, "result": result}


def _json_rpc_error(request_id: Any, code: int, message: str) -> dict[str, Any]:
    return {"jsonrpc": "2.0", "id": request_id, "error": {"code": code, "message": message}}


def _read_message() -> dict[str, Any] | None:
    headers: dict[str, str] = {}
    while True:
        line = sys.stdin.buffer.readline()
        if not line:
            return None
        if line in (b"\r\n", b"\n"):
            break
        decoded = line.decode("utf-8").strip()
        if ":" not in decoded:
            continue
        name, value = decoded.split(":", 1)
        headers[name.strip().lower()] = value.strip()

    length = int(headers.get("content-length", "0"))
    if length <= 0:
        return None
    payload = sys.stdin.buffer.read(length)
    return json.loads(payload.decode("utf-8"))


def _write_message(payload: dict[str, Any]) -> None:
    body = json.dumps(payload, ensure_ascii=False).encode("utf-8")
    header = f"Content-Length: {len(body)}\r\n\r\n".encode("ascii")
    sys.stdout.buffer.write(header)
    sys.stdout.buffer.write(body)
    sys.stdout.buffer.flush()


def _run_python_tool(
    rel_script: str,
    args: list[str] | None = None,
    *,
    timeout_sec: int = 180,
    json_mode: str | None = None,
) -> dict[str, Any]:
    cmd = [PYTHON, str(REPO_ROOT / rel_script)]
    if args:
        cmd.extend(args)

    with tempfile.NamedTemporaryFile(suffix=".json", delete=False) as tmp:
        tmp_path = Path(tmp.name)

    start = time.perf_counter()
    try:
        if json_mode == "flag":
            cmd.append("--json")
        elif json_mode == "format":
            cmd.extend(["--format", "json"])

        if json_mode in {"output", "flag_output"}:
            cmd.extend(["--output", str(tmp_path)])
            if json_mode == "flag_output":
                cmd.append("--json")

        proc = subprocess.run(
            cmd,
            cwd=REPO_ROOT,
            capture_output=True,
            text=True,
            encoding="utf-8",
            timeout=timeout_sec,
        )
        parsed: Any = None
        parse_error: str | None = None
        if json_mode in {"flag", "format"} and proc.stdout.strip():
            try:
                parsed = json.loads(proc.stdout)
            except json.JSONDecodeError:
                parse_error = "Unable to parse JSON from stdout."
        elif json_mode in {"output", "flag_output"} and tmp_path.exists() and tmp_path.stat().st_size > 0:
            try:
                parsed = json.loads(tmp_path.read_text(encoding="utf-8"))
            except json.JSONDecodeError:
                parse_error = "Unable to parse JSON from output file."
        elif json_mode in {"output", "flag_output"}:
            parse_error = "Expected JSON output file was not produced."

        duration_ms = round((time.perf_counter() - start) * 1000, 2)
        return {
            "ok": proc.returncode == 0,
            "exit_code": proc.returncode,
            "elapsed_ms": duration_ms,
            "command": cmd,
            "stdout": proc.stdout,
            "stderr": proc.stderr,
            "parse_error": parse_error,
            "parsed": parsed,
        }
    finally:
        tmp_path.unlink(missing_ok=True)


def _coerce_int_in_range(value: Any, name: str, *, minimum: int, maximum: int) -> int:
    try:
        parsed = int(value)
    except (TypeError, ValueError) as exc:
        raise ValueError(f"`{name}` must be an integer.") from exc
    if parsed < minimum or parsed > maximum:
        raise ValueError(f"`{name}` must be between {minimum} and {maximum}.")
    return parsed


def _text_result(summary: str, data: dict[str, Any], *, is_error: bool | None = None) -> dict[str, Any]:
    error_state = (not data.get("ok", False)) if is_error is None else is_error
    if "payload" not in data and "parsed" in data:
        data = {**data, "payload": data.get("parsed")}
    result = {
        "content": [{"type": "text", "text": summary}],
        "structuredContent": data,
    }
    if error_state:
        result["isError"] = True
    return result


def _top_module_lines(modules: dict[str, Any], field: str, *, descending: bool = True, limit: int = 5) -> list[str]:
    ranked = sorted(
        modules.items(),
        key=lambda item: item[1].get(field, 0),
        reverse=descending,
    )
    lines: list[str] = []
    for name, payload in ranked[:limit]:
        lines.append(f"- {name}: {payload.get(field, 0)}")
    return lines


def _count_nested_list_issues(value: Any) -> int:
    if isinstance(value, list):
        return len(value)
    if isinstance(value, dict):
        return sum(_count_nested_list_issues(item) for item in value.values())
    return 0


def _parse_json_stdout(data: dict[str, Any]) -> Any:
    stdout = data.get("stdout", "").strip()
    if not stdout:
        return None
    try:
        return json.loads(stdout)
    except json.JSONDecodeError:
        return None


def _normalize_rag_targets(args: dict[str, Any]) -> list[str]:
    candidates: list[str] = []
    seen: set[str] = set()

    if isinstance(args.get("targets"), list):
        for item in args["targets"]:
            if not isinstance(item, str):
                raise ValueError("`targets` must be an array of strings.")
            trimmed = item.strip()
            if trimmed:
                normalized = trimmed.replace("\\", "/").lstrip("/")
                if normalized not in seen:
                    candidates.append(normalized)
                    seen.add(normalized)
    if isinstance(args.get("directories"), list):
        for item in args["directories"]:
            if not isinstance(item, str):
                raise ValueError("`directories` must be an array of strings.")
            trimmed = item.strip()
            if trimmed:
                normalized = trimmed.replace("\\", "/").lstrip("/")
                if normalized not in seen:
                    candidates.append(normalized)
                    seen.add(normalized)
    return candidates


def handle_rag_search(args: dict[str, Any]) -> dict[str, Any]:
    query = str(args.get("query", "")).strip()
    if not query:
        return _text_result("`query` is required.", {"ok": False}, is_error=True)

    profile = str(args.get("profile", "all"))
    if profile not in {"all", "engine", "game"}:
        return _text_result("`profile` must be one of: all, engine, game.", {"ok": False}, is_error=True)
    try:
        limit = _coerce_int_in_range(
            args.get("limit", 8),
            "limit",
            minimum=RAG_MIN_LIMIT,
            maximum=RAG_MAX_LIMIT,
        )
    except ValueError as exc:
        return _text_result(str(exc), {"ok": False}, is_error=True)

    data = _run_python_tool(
        "tools/rag/query.py",
        [query, "--profile", profile, "--limit", str(limit)],
        timeout_sec=60,
        json_mode="flag_output",
    )
    parsed = data.get("parsed") or {}
    data["parsed"] = parsed
    results = parsed.get("results", [])
    lines = [f"RAG search returned {len(results)} result(s) for `{query}` under `{profile}`."]
    for item in results[:5]:
        lines.append(f"- {item.get('path')}: {item.get('title')}")
    if parsed.get("error"):
        lines.append(parsed["error"])
    return _text_result("\n".join(lines), data, is_error=bool(parsed.get("error")))


def handle_rag_rebuild(args: dict[str, Any]) -> dict[str, Any]:
    try:
        targets = _normalize_rag_targets(args)
    except ValueError as exc:
        return _text_result(str(exc), {"ok": False, "targets": args.get("targets")}, is_error=True)

    data = _run_python_tool(
        "tools/rag/build_index.py",
        targets,
        timeout_sec=900,
        json_mode="flag_output",
    )
    parsed = data.get("parsed") or {}
    if parsed:
        return _text_result(str(parsed), data)
    stdout = data.get("stdout", "").strip()
    summary = stdout or "RAG index build finished."
    return _text_result(summary, data)


def handle_rag_read(args: dict[str, Any]) -> dict[str, Any]:
    chunk_id = str(args.get("id", "")).strip()
    if not chunk_id:
        return _text_result("`id` is required.", {"ok": False}, is_error=True)

    try:
        neighbors = int(args.get("neighbors", 1))
    except (TypeError, ValueError):
        return _text_result("`neighbors` must be an integer.", {"ok": False}, is_error=True)
    if neighbors < 0:
        return _text_result("`neighbors` must be >= 0.", {"ok": False}, is_error=True)

    cmd = [chunk_id, "--neighbors", str(neighbors)]
    content_chars = args.get("content_chars")
    if content_chars is not None:
        try:
            content_chars = _coerce_int_in_range(
                content_chars,
                "content_chars",
                minimum=500,
                maximum=100_000,
            )
        except ValueError as exc:
            return _text_result(str(exc), {"ok": False}, is_error=True)
        cmd.extend(["--content-chars", str(content_chars)])
    data = _run_python_tool("tools/rag/read.py", cmd, timeout_sec=60, json_mode="flag_output")
    parsed = data.get("parsed") or {}
    data["parsed"] = parsed
    chunk = parsed.get("chunk", {})
    if parsed.get("error"):
        return _text_result(parsed["error"], data, is_error=True)
    text = (
        f"RAG chunk `{chunk.get('id')}` from {chunk.get('path')}:"
        f"{chunk.get('line_start')}-{chunk.get('line_end')}."
    )
    return _text_result(text, data)


def handle_rag_context(args: dict[str, Any]) -> dict[str, Any]:
    prompt = str(args.get("prompt", "")).strip()
    if not prompt:
        return _text_result("`prompt` is required.", {"ok": False}, is_error=True)
    profile = str(args.get("profile", "all"))
    if profile not in {"all", "engine", "game"}:
        return _text_result("`profile` must be one of: all, engine, game.", {"ok": False}, is_error=True)
    try:
        limit = _coerce_int_in_range(
            args.get("limit", 8),
            "limit",
            minimum=RAG_MIN_LIMIT,
            maximum=RAG_MAX_LIMIT,
        )
    except ValueError as exc:
        return _text_result(str(exc), {"ok": False}, is_error=True)
    try:
        neighbors = int(args.get("neighbors", 1))
    except (TypeError, ValueError):
        return _text_result("`limit` and `neighbors` must be integers.", {"ok": False}, is_error=True)
    if neighbors < 0:
        return _text_result("`neighbors` must be >= 0.", {"ok": False}, is_error=True)
    content_chars = args.get("content_chars")
    if content_chars is not None:
        try:
            content_chars = _coerce_int_in_range(
                content_chars,
                "content_chars",
                minimum=500,
                maximum=100_000,
            )
        except ValueError as exc:
            return _text_result(str(exc), {"ok": False}, is_error=True)

    cmd = [
        prompt,
        "--profile",
        profile,
        "--limit",
        str(limit),
        "--neighbors",
        str(neighbors),
    ]
    if content_chars:
        cmd.extend(["--content-chars", str(content_chars)])
    data = _run_python_tool("tools/rag/context.py", cmd, timeout_sec=90, json_mode="flag_output")
    parsed = data.get("parsed") or {}
    data["parsed"] = parsed
    results = parsed.get("results", [])
    lines = [f"RAG context bundle returned {len(results)} chunk(s) for `{prompt}`."]
    for item in results[:8]:
        lines.append(f"- {item.get('path')}:{item.get('line_start')}-{item.get('line_end')} {item.get('title')}")
    if parsed.get("error"):
        lines.append(parsed["error"])
    return _text_result("\n".join(lines), data, is_error=bool(parsed.get("error")))


def handle_rag_stats(args: dict[str, Any]) -> dict[str, Any]:
    data = _run_python_tool("tools/rag/query.py", ["--stats"], timeout_sec=60, json_mode="flag_output")
    parsed = data.get("parsed") or {}
    data["parsed"] = parsed
    if parsed.get("error"):
        return _text_result(parsed["error"], data, is_error=True)
    lines = [f"RAG index contains {parsed.get('total_chunks', 0)} chunk(s)."]
    for row in parsed.get("by_kind", [])[:8]:
        lines.append(f"- {row.get('source_kind')}: {row.get('chunks')}")
    return _text_result("\n".join(lines), data)


def handle_rag_eval(args: dict[str, Any]) -> dict[str, Any]:
    try:
        limit = _coerce_int_in_range(
            args.get("limit", 10),
            "limit",
            minimum=1,
            maximum=RAG_MAX_LIMIT,
        )
    except ValueError as exc:
        return _text_result(str(exc), {"ok": False}, is_error=True)

    cmd = ["--json", "--limit", str(limit)]
    data = _run_python_tool("tools/rag/eval.py", cmd, timeout_sec=180, json_mode="flag_output")
    parsed = data.get("parsed") or {}
    data["parsed"] = parsed
    lines = [f"RAG recall: {parsed.get('passed', 0)}/{parsed.get('total', 0)} ({parsed.get('pass_rate', 0)}%)."]
    for item in parsed.get("results", []):
        if not item.get("ok"):
            lines.append(f"- FAIL {item.get('query')}: {', '.join(item.get('top_paths', [])[:3])}")
    return _text_result("\n".join(lines), data, is_error=not bool(parsed.get("ok")))


def handle_quality_report(args: dict[str, Any]) -> dict[str, Any]:
    data = _run_python_tool(
        "tools/audit/quality_report.py",
        [],
        timeout_sec=900,
        json_mode="flag",
    )
    report = data.get("parsed") or {}
    docs = report.get("docs-general", {})
    test = report.get("test_coverage", {})
    modules = report.get("modules", {})
    validation = report.get("validation", {})
    lines = [
        f"Docs-general: Rust {docs.get('rust', {}).get('coverage_pct', 0)}%, Lua {docs.get('lua_api', {}).get('coverage_pct', 0)}%.",
        f"Test coverage: Rust {test.get('rust', {}).get('coverage_pct', 0)}%, Lua {test.get('lua', {}).get('coverage_pct', 0)}%.",
        f"Validation issues: {_count_nested_list_issues(validation)}.",
        f"Modules audited: {len(modules) if isinstance(modules, dict) else 0}.",
    ]
    return _text_result("\n".join(lines), data)


def handle_doc_audit(args: dict[str, Any]) -> dict[str, Any]:
    data = _run_python_tool(
        "tools/audit/doc_audit.py",
        [],
        timeout_sec=900,
        json_mode="flag",
    )
    report = data.get("parsed") or {}
    rust = report.get("rust", {})
    lua = report.get("lua_api", {})
    lines = [
        f"Rust docs: {rust.get('coverage_pct', 0)}% ({rust.get('documented', 0)}/{rust.get('total_items', 0)}).",
        f"Lua docs: {lua.get('coverage_pct', 0)}% ({lua.get('documented', 0)}/{lua.get('total_functions', 0)}).",
        f"Lua missing items: {len(lua.get('missing_items', []))}.",
    ]
    return _text_result("\n".join(lines), data)


def handle_doc_coverage(args: dict[str, Any]) -> dict[str, Any]:
    cmd = []
    module = args.get("module")
    if module:
        cmd.extend(["--module", str(module)])
    if args.get("lua_only"):
        cmd.append("--lua-only")
    if args.get("rust_only"):
        cmd.append("--rust-only")
    if args.get("report_missing"):
        cmd.append("--report-missing")

    data = _run_python_tool(
        "tools/audit/doc_coverage.py",
        cmd,
        timeout_sec=900,
        json_mode="flag",
    )
    report = data.get("parsed") or {}
    summary = report.get("summary", {})
    lines = [
        f"Rust docs: {summary.get('rust', {}).get('pct', 0)}% ({summary.get('rust', {}).get('covered', 0)}/{summary.get('rust', {}).get('total', 0)}).",
        f"Lua docs: {summary.get('lua_api', {}).get('pct', 0)}% ({summary.get('lua_api', {}).get('covered', 0)}/{summary.get('lua_api', {}).get('total', 0)}).",
        f"Missing items: {len(report.get('missing', []))}.",
    ]
    return _text_result("\n".join(lines), data)


def handle_module_docstring_audit(args: dict[str, Any]) -> dict[str, Any]:
    cmd = []
    src_dir = args.get("src")
    if src_dir:
        cmd.extend(["--src", str(src_dir)])
    if args.get("check"):
        cmd.append("--check")

    data = _run_python_tool(
        "tools/audit/module_docstring_audit.py",
        cmd,
        timeout_sec=300,
        json_mode="flag",
    )
    violations = data.get("parsed") or []
    top = sorted(violations, key=lambda item: (item.get("deficit", 0), item.get("loc", 0)), reverse=True)[:5]
    lines = [
        f"Module docstring violations: {len(violations)}.",
    ]
    for item in top:
        lines.append(
            f"- {item.get('file')}: deficit {item.get('deficit', 0)} "
            f"(actual {item.get('actual_doc_lines', 0)}/{item.get('required_doc_lines', 0)})"
        )
    return _text_result("\n".join(lines), data)


def handle_unit_test_api_coverage(args: dict[str, Any]) -> dict[str, Any]:
    cmd = []
    module = args.get("module")
    if module:
        cmd.extend(["--module", str(module)])
    if args.get("strict"):
        cmd.append("--strict")
    threshold = args.get("threshold")
    if threshold is not None:
        cmd.extend(["--threshold", str(threshold)])

    data = _run_python_tool(
        "tools/audit/unit_test_api_coverage.py",
        cmd,
        timeout_sec=600,
        json_mode="flag",
    )
    report = data.get("parsed") or {}
    summary = report.get("summary", {})
    structure = report.get("structure", {})
    modules = report.get("modules", {})
    worst = sorted(modules.items(), key=lambda item: item[1].get("pct_explicit", 0))[:5]
    lines = [
        f"Explicit coverage: {summary.get('pct_explicit', 0)}% ({summary.get('covered_explicit', 0)}/{summary.get('total_apis', 0)}).",
        f"Any-coverage: {summary.get('pct_any', 0)}% ({summary.get('covered_heuristic', 0)} heuristic hits).",
        f"Unit test structure violations: {len(structure.get('violations', []))} across {structure.get('total_it_blocks', 0)} it() blocks.",
        f"Duplicate API markers: {structure.get('duplicate_api_markers', 0)}.",
        f"Modules inspected: {summary.get('total_modules', len(modules))}.",
    ]
    if worst:
        lines.append("Lowest modules:")
        for name, payload in worst:
            lines.append(
                f"- {name}: explicit {payload.get('pct_explicit', 0)}%, "
                f"any {payload.get('pct_any', 0)}%, uncovered {payload.get('uncovered', 0)}"
            )
    return _text_result("\n".join(lines), data)


def handle_library_coverage(args: dict[str, Any]) -> dict[str, Any]:
    cmd = []
    library = args.get("library")
    if library:
        cmd.extend(["--library", str(library)])
    threshold = args.get("threshold")
    if threshold is not None:
        cmd.extend(["--threshold", str(threshold)])

    data = _run_python_tool(
        "tools/audit/library_coverage.py",
        cmd,
        timeout_sec=600,
        json_mode="flag",
    )
    report = data.get("parsed") or []
    avg_doc = round(sum(item.get("doc_pct", 0) for item in report) / len(report), 1) if report else 0.0
    avg_test = round(sum(item.get("test_pct", 0) for item in report) / len(report), 1) if report else 0.0
    worst = sorted(report, key=lambda item: item.get("test_pct", 0))[:5]
    lines = [
        f"Libraries inspected: {len(report)}.",
        f"Average doc coverage: {avg_doc}%.",
        f"Average test coverage: {avg_test}%.",
    ]
    if worst:
        lines.append("Lowest libraries:")
        for item in worst:
            lines.append(
                f"- {item.get('library')}: doc {item.get('doc_pct', 0)}%, "
                f"API {item.get('api_md_pct', 0)}%, test {item.get('test_pct', 0)}%"
            )
    return _text_result("\n".join(lines), data)


def handle_validate_example_coverage(args: dict[str, Any]) -> dict[str, Any]:
    cmd = ["--report", "--no-stubs"]
    data = _run_python_tool(
        "tools/validate/validate_example_coverage.py",
        cmd,
        timeout_sec=300,
    )
    stdout = data.get("stdout", "").strip()
    return _text_result(stdout or "Example coverage validation finished.", data)


def handle_validate_module_coverage(args: dict[str, Any]) -> dict[str, Any]:
    cmd = []
    if args.get("fix_readme"):
        cmd.append("--fix-readme")
    data = _run_python_tool(
        "tools/validate/validate_module_coverage.py",
        cmd,
        timeout_sec=300,
    )
    stdout = data.get("stdout", "").strip()
    return _text_result(stdout or "Module/spec coverage validation finished.", data)


def handle_tool_registry_audit(args: dict[str, Any]) -> dict[str, Any]:
    cmd = ["--format", "json"]
    if args.get("strict"):
        cmd.append("--strict")
    data = _run_python_tool(
        "tools/audit/tool_registry_audit.py",
        cmd,
        timeout_sec=300,
        json_mode="format",
    )
    report = data.get("parsed") or {}
    findings = report.get("findings", [])
    errors = sum(1 for item in findings if item.get("level") == "ERROR")
    warns = sum(1 for item in findings if item.get("level") == "WARN")
    lines = [
        f"Tool registry audit: {errors} error(s), {warns} warning(s).",
        f"Scripts audited: {report.get('total_scripts', 0)}.",
    ]
    return _text_result("\n".join(lines), data)


def handle_cag_validate(args: dict[str, Any]) -> dict[str, Any]:
    cmd = ["--format", "json"]
    if args.get("type"):
        cmd.extend(["--type", str(args["type"])])
    if args.get("file"):
        cmd.extend(["--file", str(args["file"])])
    if args.get("baseline"):
        cmd.append("--baseline")
    if args.get("write_baseline"):
        cmd.append("--write-baseline")

    data = _run_python_tool(
        "tools/validate/cag_validate.py",
        cmd,
        timeout_sec=300,
        json_mode="format",
    )
    report = data.get("parsed") or {}
    summary = report.get("summary", {})
    scanned = report.get("scanned", {})
    lines = [
        f"CAG validation: {summary.get('errors', 0)} error(s), {summary.get('warnings', 0)} warning(s).",
        f"Scanned files: {sum(scanned.values()) if isinstance(scanned, dict) else 0}.",
    ]
    return _text_result("\n".join(lines), data)


def handle_cag_link_check(args: dict[str, Any]) -> dict[str, Any]:
    cmd = ["--format", "json"]
    if args.get("strict"):
        cmd.append("--strict")
    data = _run_python_tool(
        "tools/audit/cag_link_check.py",
        cmd,
        timeout_sec=300,
        json_mode="format",
    )
    report = data.get("parsed") or {}
    lines = [
        f"CAG link check: {report.get('broken_total', 0)} broken link(s) in {report.get('files_scanned', 0)} file(s).",
    ]
    return _text_result("\n".join(lines), data)


def handle_strict_api_check(args: dict[str, Any]) -> dict[str, Any]:
    data = _run_python_tool(
        "tools/audit/strict_api_check.py",
        [],
        timeout_sec=300,
    )
    stdout = data.get("stdout", "").strip()
    return _text_result(stdout or "Strict API check finished.", data)


def handle_strict_api_check_math(args: dict[str, Any]) -> dict[str, Any]:
    data = _run_python_tool(
        "tools/audit/strict_api_check_math.py",
        [],
        timeout_sec=300,
    )
    stdout = data.get("stdout", "").strip()
    return _text_result(stdout or "Math strict API check finished.", data)


def handle_lua_api_test_coverage(args: dict[str, Any]) -> dict[str, Any]:
    cmd = []
    module = args.get("module")
    if module:
        cmd.extend(["--module", str(module)])
    if args.get("strict"):
        cmd.append("--strict")
    threshold = args.get("threshold")
    if threshold is not None:
        cmd.extend(["--threshold", str(threshold)])
    describe_threshold = args.get("describe_threshold")
    if describe_threshold is not None:
        cmd.extend(["--describe-threshold", str(describe_threshold)])

    data = _run_python_tool(
        "tools/audit/lua_api_test_coverage.py",
        cmd,
        timeout_sec=300,
        json_mode="flag",
    )
    report = data.get("parsed") or {}
    meta = report.get("meta", {})
    modules = report.get("modules", {})
    lines = [
        f"Lua API test coverage: {meta.get('coverage_pct', 0)}% ({meta.get('total_covered', 0)}/{meta.get('total_api_functions', 0)}).",
        f"Describe coverage: {meta.get('describe_coverage_pct', 0)}%.",
        f"Orphaned markers: {len(report.get('orphaned_markers', []))}.",
    ]
    worst = sorted(modules.items(), key=lambda item: item[1].get("coverage_pct", 0))[:5]
    if worst:
        lines.append("Lowest modules:")
        for name, payload in worst:
            lines.append(f"- {name}: {payload.get('coverage_pct', 0)}% ({payload.get('covered', 0)}/{payload.get('total', 0)})")
    return _text_result("\n".join(lines), data)


def handle_docstring_audit(args: dict[str, Any]) -> dict[str, Any]:
    cmd = []
    file_path = args.get("file")
    if file_path:
        cmd.extend(["--file", str(file_path)])
    if args.get("check"):
        cmd.append("--check")

    data = _run_python_tool(
        "tools/audit/docstring_audit.py",
        cmd,
        timeout_sec=300,
        json_mode="flag",
    )
    report = data.get("parsed") or {}
    by_type = report.get("by_type", {})
    lines = [
        f"Lua API docstring violations: {report.get('total_violations', 0)} across {report.get('files_with_violations', 0)} file(s).",
    ]
    for name, count in sorted(by_type.items(), key=lambda item: (-item[1], item[0])):
        lines.append(f"- {name}: {count}")
    return _text_result("\n".join(lines), data)


def handle_example_coverage(args: dict[str, Any]) -> dict[str, Any]:
    cmd = []
    module = args.get("module")
    if module:
        cmd.extend(["--module", str(module)])
    if args.get("report"):
        cmd.append("--report")
    if args.get("no_stubs"):
        cmd.append("--no-stubs")

    data = _run_python_tool(
        "tools/audit/example_coverage.py",
        cmd,
        timeout_sec=300,
        json_mode="flag",
    )
    report = data.get("parsed") or {}
    total_modules = len(report)
    miss_modules = sum(1 for item in report.values() if item.get("miss", 0))
    todo_modules = sum(1 for item in report.values() if item.get("todo", 0))
    worst = sorted(report.items(), key=lambda item: item[1].get("pct", 100))[:5]
    lines = [
        f"Example coverage inspected {total_modules} module(s).",
        f"Modules with missing example stubs: {miss_modules}.",
        f"Modules with TODO-only stubs: {todo_modules}.",
    ]
    if worst:
        lines.append("Lowest modules:")
        for name, payload in worst:
            lines.append(f"- {name}: {payload.get('pct', 0)}% tracked, miss={payload.get('miss', 0)}, todo={payload.get('todo', 0)}")
    return _text_result("\n".join(lines), data)


def handle_spec_coverage(args: dict[str, Any]) -> dict[str, Any]:
    cmd = []
    module = args.get("module")
    if module:
        cmd.extend(["--module", str(module)])
    threshold = args.get("threshold")
    if threshold is not None:
        cmd.extend(["--threshold", str(threshold)])

    data = _run_python_tool(
        "tools/audit/lua_spec_coverage.py",
        cmd,
        timeout_sec=300,
        json_mode="flag",
    )
    report = data.get("parsed") or []
    covered = [item for item in report if item.get("status") != "no_spec_file" and item.get("bound_total", 0) > 0]
    total_bound = sum(item.get("bound_total", 0) for item in covered)
    total_in_spec = sum(item.get("in_spec", 0) for item in covered)
    overall = round((total_in_spec / total_bound) * 100, 1) if total_bound else 100.0
    worst = sorted(covered, key=lambda item: item.get("coverage_pct", 100))[:5]
    lines = [
        f"Lua spec coverage: {overall}% ({total_in_spec}/{total_bound}).",
        f"Modules inspected: {len(report)}.",
    ]
    if worst:
        lines.append("Lowest modules:")
        for item in worst:
            lines.append(f"- {item.get('module')}: {item.get('coverage_pct', 0)}%, missing={len(item.get('missing', []))}, stale={len(item.get('stale', []))}")
    return _text_result("\n".join(lines), data)


def handle_binding_validation(args: dict[str, Any]) -> dict[str, Any]:
    data = _run_python_tool(
        "tools/validate/validate_lua_binding_reports.py",
        [],
        timeout_sec=300,
        json_mode="format",
    )
    report = data.get("parsed") or {}
    summary = report.get("summary", {})
    lines = [
        f"Lua binding validation blocking issues: {summary.get('blocking_issue_count', 0)}.",
        f"Confirmed doc bugs: {summary.get('confirmed_doc_bug_count', 0)}.",
        f"Missing doc entries: {len(report.get('missing_doc_entries', []))}.",
        f"Phantom doc entries: {len(report.get('phantom_doc_entries', []))}.",
        f"Parameter type mismatches: {len(report.get('parameter_type_mismatches', []))}.",
    ]
    return _text_result("\n".join(lines), data)


def handle_test_coverage(args: dict[str, Any]) -> dict[str, Any]:
    cmd = []
    module = args.get("module")
    if module:
        cmd.extend(["--module", str(module)])
    threshold = args.get("threshold")
    if threshold is not None:
        cmd.extend(["--threshold", str(threshold)])

    data = _run_python_tool(
        "tools/audit/test_coverage.py",
        cmd,
        timeout_sec=300,
        json_mode="flag",
    )
    report = data.get("parsed") or {}
    rust = report.get("rust", {})
    lua = report.get("lua", {})
    lines = [
        f"Rust test coverage: {rust.get('coverage_pct', 0)}% ({rust.get('covered', 0)}/{rust.get('total', 0)}).",
        f"Lua test coverage: {lua.get('coverage_pct', 0)}% ({lua.get('covered', 0)}/{lua.get('total', 0)}).",
        f"Rust uncovered items: {rust.get('uncovered', 0)}.",
        f"Lua uncovered items: {lua.get('uncovered', 0)}.",
    ]
    return _text_result("\n".join(lines), data)


def handle_lua_api_health_suite(args: dict[str, Any]) -> dict[str, Any]:
    module = args.get("module")

    suite = {
        "docstrings": handle_docstring_audit({"file": None}),
        "examples": handle_example_coverage({"module": module}),
        "specs": handle_spec_coverage({"module": module}),
        "lua_api_tests": handle_lua_api_test_coverage({"module": module, "strict": args.get("strict_tests", False)}),
        "bindings": handle_binding_validation({}),
        "test_coverage": handle_test_coverage({"module": module}),
    }

    error_count = sum(1 for item in suite.values() if item.get("isError"))
    lines = [f"Lua API health suite completed with {error_count} failing check(s)."]
    for name, payload in suite.items():
        marker = "FAIL" if payload.get("isError") else "OK"
        text = payload.get("content", [{}])[0].get("text", "")
        first_line = text.splitlines()[0] if text else name
        lines.append(f"- {marker} {name}: {first_line}")

    return {
        "content": [{"type": "text", "text": "\n".join(lines)}],
        "structuredContent": {"ok": error_count == 0, "suite": suite},
        "isError": error_count > 0,
    }


TOOLS: dict[str, ToolSpec] = {
    "lurek2d.ragSearch": ToolSpec(
        name="lurek2d.ragSearch",
        description="Search the local Lurek2D RAG index across docs, code, tests, and Codex workspace files.",
        input_schema={
            "type": "object",
            "properties": {
                "query": {"type": "string"},
                "profile": {"type": "string", "enum": ["all", "engine", "game"], "default": "all"},
                "limit": {"type": "integer", "minimum": 1, "maximum": 25, "default": 8},
            },
            "required": ["query"],
            "additionalProperties": False,
        },
        handler=handle_rag_search,
    ),
    "rag_search": ToolSpec(
        name="rag_search",
        description="Search the local Lurek2D RAG index across docs, code, tests, and Codex workspace files.",
        input_schema={
            "type": "object",
            "properties": {
                "query": {"type": "string"},
                "profile": {"type": "string", "enum": ["all", "engine", "game"], "default": "all"},
                "limit": {"type": "integer", "minimum": 1, "maximum": 25, "default": 8},
            },
            "required": ["query"],
            "additionalProperties": False,
        },
        handler=handle_rag_search,
    ),
    "lurek2d.ragBuildIndex": ToolSpec(
        name="lurek2d.ragBuildIndex",
        description="Rebuild or incrementally refresh the local RAG index after changing indexed sources.",
        input_schema={
            "type": "object",
            "properties": {
                "directories": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Optional repo-relative directories or files to re-index.",
                },
                "targets": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Alias for directories.",
                },
            },
            "additionalProperties": False,
        },
        handler=handle_rag_rebuild,
    ),
    "rag_rebuild_index": ToolSpec(
        name="rag_rebuild_index",
        description="Rebuild or incrementally refresh the local RAG index after changing indexed sources.",
        input_schema={
            "type": "object",
            "properties": {
                "targets": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Optional repo-relative directories or files to re-index.",
                },
                "directories": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Alias for targets.",
                },
            },
            "additionalProperties": False,
        },
        handler=handle_rag_rebuild,
    ),
    "rag_read": ToolSpec(
        name="rag_read",
        description="Read full content for a RAG chunk id, optionally including adjacent chunks from the same file.",
        input_schema={
            "type": "object",
            "properties": {
                "id": {"type": "string"},
                "neighbors": {"type": "integer", "minimum": 0, "maximum": 3, "default": 1},
                "content_chars": {"type": "integer", "minimum": 1000, "maximum": 40000, "default": 12000},
            },
            "required": ["id"],
            "additionalProperties": False,
        },
        handler=handle_rag_read,
    ),
    "rag_context_bundle": ToolSpec(
        name="rag_context_bundle",
        description="Build an agent-readable RAG context bundle with full chunks for a task prompt.",
        input_schema={
            "type": "object",
            "properties": {
                "prompt": {"type": "string"},
                "profile": {"type": "string", "enum": ["all", "engine", "game"], "default": "all"},
                "limit": {"type": "integer", "minimum": 1, "maximum": 20, "default": 8},
                "neighbors": {"type": "integer", "minimum": 0, "maximum": 3, "default": 1},
                "content_chars": {"type": "integer", "minimum": 1000, "maximum": 40000, "default": 8000},
            },
            "required": ["prompt"],
            "additionalProperties": False,
        },
        handler=handle_rag_context,
    ),
    "rag_stats": ToolSpec(
        name="rag_stats",
        description="Return local RAG index stats by source kind, type, and largest paths.",
        input_schema={
            "type": "object",
            "properties": {},
            "additionalProperties": False,
        },
        handler=handle_rag_stats,
    ),
    "rag_eval": ToolSpec(
        name="rag_eval",
        description="Run the local RAG recall baseline prompt suite.",
        input_schema={
            "type": "object",
            "properties": {
                "limit": {"type": "integer", "minimum": 3, "maximum": 25, "default": 10},
            },
            "additionalProperties": False,
        },
        handler=handle_rag_eval,
    ),
    "quality_report": ToolSpec(
        name="quality_report",
        description="Run the repository-wide quality dashboard that combines docs, tests, module checks, and validation.",
        input_schema={
            "type": "object",
            "properties": {},
            "additionalProperties": False,
        },
        handler=handle_quality_report,
    ),
    "doc_audit": ToolSpec(
        name="doc_audit",
        description="Run the unified docs-general audit for Rust source docs and Lua API docs.",
        input_schema={
            "type": "object",
            "properties": {},
            "additionalProperties": False,
        },
        handler=handle_doc_audit,
    ),
    "doc_coverage": ToolSpec(
        name="doc_coverage",
        description="Measure Rust and Lua API docstring coverage across `src/`.",
        input_schema={
            "type": "object",
            "properties": {
                "module": {"type": "string"},
                "lua_only": {"type": "boolean", "default": False},
                "rust_only": {"type": "boolean", "default": False},
                "report_missing": {"type": "boolean", "default": False},
            },
            "additionalProperties": False,
        },
        handler=handle_doc_coverage,
    ),
    "module_docstring_audit": ToolSpec(
        name="module_docstring_audit",
        description="Audit Rust module-level //! docstrings for size and completeness.",
        input_schema={
            "type": "object",
            "properties": {
                "src": {"type": "string"},
                "check": {"type": "boolean", "default": False},
            },
            "additionalProperties": False,
        },
        handler=handle_module_docstring_audit,
    ),
    "unit_test_api_coverage": ToolSpec(
        name="unit_test_api_coverage",
        description="Measure explicit Lua unit-test coverage for APIs and methods.",
        input_schema={
            "type": "object",
            "properties": {
                "module": {"type": "string"},
                "strict": {"type": "boolean", "default": False},
                "threshold": {"type": "number"},
            },
            "additionalProperties": False,
        },
        handler=handle_unit_test_api_coverage,
    ),
    "library_coverage": ToolSpec(
        name="library_coverage",
        description="Audit Lua library coverage across docs, docstrings, and tests.",
        input_schema={
            "type": "object",
            "properties": {
                "library": {"type": "string"},
                "threshold": {"type": "number"},
            },
            "additionalProperties": False,
        },
        handler=handle_library_coverage,
    ),
    "lua_api_test_coverage": ToolSpec(
        name="lua_api_test_coverage",
        description="Measure Lua API coverage in `tests/lua/unit` using explicit `@covers` markers, describe() targets, and optional heuristic fallback.",
        input_schema={
            "type": "object",
            "properties": {
                "module": {"type": "string"},
                "strict": {"type": "boolean", "default": False},
                "threshold": {"type": "number"},
                "describe_threshold": {"type": "number"},
            },
            "additionalProperties": False,
        },
        handler=handle_lua_api_test_coverage,
    ),
    "lua_api_docstring_audit": ToolSpec(
        name="lua_api_docstring_audit",
        description="Audit `src/lua_api/*.rs` docstrings for missing descriptions, param tags, and return tags.",
        input_schema={
            "type": "object",
            "properties": {
                "file": {"type": "string"},
                "check": {"type": "boolean", "default": False},
            },
            "additionalProperties": False,
        },
        handler=handle_docstring_audit,
    ),
    "lua_example_coverage": ToolSpec(
        name="lua_example_coverage",
        description="Check how well `content/examples/*.lua` covers the Lua API, including TODO-only stubs and structural lint.",
        input_schema={
            "type": "object",
            "properties": {
                "module": {"type": "string"},
                "report": {"type": "boolean", "default": False},
                "no_stubs": {"type": "boolean", "default": False},
            },
            "additionalProperties": False,
        },
        handler=handle_example_coverage,
    ),
    "lua_spec_coverage": ToolSpec(
        name="lua_spec_coverage",
        description="Measure how completely `docs/specs/<module>.md` covers the callable Lua API.",
        input_schema={
            "type": "object",
            "properties": {
                "module": {"type": "string"},
                "threshold": {"type": "number"},
            },
            "additionalProperties": False,
        },
        handler=handle_spec_coverage,
    ),
    "lua_binding_validation": ToolSpec(
        name="lua_binding_validation",
        description="Validate Lua binding docstrings against code-derived binding snapshots and report mismatches.",
        input_schema={
            "type": "object",
            "properties": {},
            "additionalProperties": False,
        },
        handler=handle_binding_validation,
    ),
    "repo_test_coverage": ToolSpec(
        name="repo_test_coverage",
        description="Measure heuristic Rust and Lua test coverage across the repository.",
        input_schema={
            "type": "object",
            "properties": {
                "module": {"type": "string"},
                "threshold": {"type": "number"},
            },
            "additionalProperties": False,
        },
        handler=handle_test_coverage,
    ),
    "cag_validate": ToolSpec(
        name="cag_validate",
        description="Validate Codex agent, skill, and prompt files against the CAG contract.",
        input_schema={
            "type": "object",
            "properties": {
                "type": {"type": "string", "enum": ["system_prompt", "agent", "skill", "prompt"]},
                "file": {"type": "string"},
                "baseline": {"type": "boolean", "default": False},
                "write_baseline": {"type": "boolean", "default": False},
            },
            "additionalProperties": False,
        },
        handler=handle_cag_validate,
    ),
    "cag_link_check": ToolSpec(
        name="cag_link_check",
        description="Check .github markdown files for broken links and stale references.",
        input_schema={
            "type": "object",
            "properties": {
                "strict": {"type": "boolean", "default": False},
            },
            "additionalProperties": False,
        },
        handler=handle_cag_link_check,
    ),
    "tool_registry_audit": ToolSpec(
        name="tool_registry_audit",
        description="Audit the checked-in tools registry for missing or phantom entries.",
        input_schema={
            "type": "object",
            "properties": {
                "strict": {"type": "boolean", "default": False},
            },
            "additionalProperties": False,
        },
        handler=handle_tool_registry_audit,
    ),
    "strict_api_check": ToolSpec(
        name="strict_api_check",
        description="Validate that example stubs actually reference the Lua APIs they claim to cover.",
        input_schema={
            "type": "object",
            "properties": {},
            "additionalProperties": False,
        },
        handler=handle_strict_api_check,
    ),
    "strict_api_check_math": ToolSpec(
        name="strict_api_check_math",
        description="Validate the math example stubs against the math API contract.",
        input_schema={
            "type": "object",
            "properties": {},
            "additionalProperties": False,
        },
        handler=handle_strict_api_check_math,
    ),
    "lua_api_health_suite": ToolSpec(
        name="lua_api_health_suite",
        description="Run the main Lua API audits together: docstrings, examples, specs, binding validation, and test coverage.",
        input_schema={
            "type": "object",
            "properties": {
                "module": {"type": "string"},
                "strict_tests": {"type": "boolean", "default": False},
            },
            "additionalProperties": False,
        },
        handler=handle_lua_api_health_suite,
    ),
}


def _handle_request(message: dict[str, Any]) -> dict[str, Any] | None:
    method = message.get("method")
    request_id = message.get("id")
    params = message.get("params", {})

    if method == "initialize":
        return _json_rpc_result(
            request_id,
            {
                "protocolVersion": "2024-11-05",
                "capabilities": {"tools": {}},
                "serverInfo": {"name": SERVER_NAME, "version": SERVER_VERSION},
            },
        )

    if method == "notifications/initialized":
        return None

    if method == "ping":
        return _json_rpc_result(request_id, {})

    if method == "tools/list":
        tools = [
            {
                "name": spec.name,
                "description": spec.description,
                "inputSchema": spec.input_schema,
            }
            for spec in TOOLS.values()
        ]
        return _json_rpc_result(request_id, {"tools": tools})

    if method == "tools/call":
        name = params.get("name")
        spec = TOOLS.get(name)
        if spec is None:
            return _json_rpc_error(request_id, -32602, f"Unknown tool: {name}")
        try:
            result = spec.handler(params.get("arguments") or {})
            return _json_rpc_result(request_id, result)
        except subprocess.TimeoutExpired as exc:
            return _json_rpc_result(
                request_id,
                {
                    "content": [{"type": "text", "text": f"Tool timed out after {exc.timeout} seconds."}],
                    "structuredContent": {"ok": False, "timeout": exc.timeout},
                    "isError": True,
                },
            )
        except Exception as exc:  # pragma: no cover - defensive server boundary
            return _json_rpc_result(
                request_id,
                {
                    "content": [{"type": "text", "text": f"Internal server error: {exc}"}],
                    "structuredContent": {
                        "ok": False,
                        "error": str(exc),
                        "traceback": traceback.format_exc(),
                    },
                    "isError": True,
                },
            )

    return _json_rpc_error(request_id, -32601, f"Method not found: {method}")


def main() -> int:
    while True:
        message = _read_message()
        if message is None:
            return 0
        response = _handle_request(message)
        if response is not None:
            _write_message(response)


if __name__ == "__main__":
    raise SystemExit(main())
