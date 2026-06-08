#!/usr/bin/env python3
"""Expose Lurek2D RAG and Lua API quality audits as a minimal stdio MCP server."""

from __future__ import annotations

import json
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
SERVER_VERSION = "0.1.0"


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
        if json_mode in {"flag", "format"} and proc.stdout.strip():
            try:
                parsed = json.loads(proc.stdout)
            except json.JSONDecodeError:
                parsed = None
        elif json_mode in {"output", "flag_output"} and tmp_path.exists() and tmp_path.stat().st_size > 0:
            try:
                parsed = json.loads(tmp_path.read_text(encoding="utf-8"))
            except json.JSONDecodeError:
                parsed = None

        return {
            "ok": proc.returncode == 0,
            "exit_code": proc.returncode,
            "command": cmd,
            "stdout": proc.stdout,
            "stderr": proc.stderr,
            "parsed": parsed,
        }
    finally:
        tmp_path.unlink(missing_ok=True)


def _text_result(summary: str, data: dict[str, Any], *, is_error: bool | None = None) -> dict[str, Any]:
    error_state = (not data.get("ok", False)) if is_error is None else is_error
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


def _parse_json_stdout(data: dict[str, Any]) -> Any:
    stdout = data.get("stdout", "").strip()
    if not stdout:
        return None
    try:
        return json.loads(stdout)
    except json.JSONDecodeError:
        return None


def handle_rag_search(args: dict[str, Any]) -> dict[str, Any]:
    query = str(args.get("query", "")).strip()
    if not query:
        return _text_result("`query` is required.", {"ok": False}, is_error=True)

    profile = str(args.get("profile", "all"))
    limit = int(args.get("limit", 8))
    data = _run_python_tool(
        "tools/rag/query.py",
        [query, "--profile", profile, "--limit", str(limit)],
        timeout_sec=60,
    )
    parsed = _parse_json_stdout(data) or {}
    data["parsed"] = parsed
    results = parsed.get("results", [])
    lines = [f"RAG search returned {len(results)} result(s) for `{query}` under `{profile}`."]
    for item in results[:5]:
        lines.append(f"- {item.get('path')}: {item.get('title')}")
    if parsed.get("error"):
        lines.append(parsed["error"])
    return _text_result("\n".join(lines), data, is_error=bool(parsed.get("error")))


def handle_rag_rebuild(args: dict[str, Any]) -> dict[str, Any]:
    targets = [str(item) for item in args.get("targets", [])]
    data = _run_python_tool("tools/rag/build_index.py", targets, timeout_sec=900)
    stdout = data.get("stdout", "").strip()
    summary = stdout or "RAG index build finished."
    return _text_result(summary, data)


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
                }
            },
            "additionalProperties": False,
        },
        handler=handle_rag_rebuild,
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
