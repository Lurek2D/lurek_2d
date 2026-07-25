# Audit Contract

## Mission & Scope
- Own scripts that report quality, docs, specs, tests, links, profiling, and stress findings.
- Keep audit output precise, actionable, and policy-backed.

## Files
- `audit_module.py`: Module audit entry point.
- `cag_link_check.py`: CAG contract and tool reference checker.
- `doc_coverage.py`: API doc coverage checker.
- `test_coverage.py`: Test-to-module coverage report.

## Rules
- Diagnostics must include precise target files, line numbers when available, and actionable violations.
- Ban patterns only when the repo defines a clear replacement or exception.
- Profiling and stress reports must use release-mode builds.
- Parsers must stay compatible with historical test logs.

## Workflow
- Run focused checks, e.g. `tools/python.cmd tools/audit/cag_link_check.py --strict`.
- Audit one module with `tools/python.cmd tools/audit/audit_module.py <name>`.
- Use real parser flags. Examples: `lua_spec_coverage.py --module <name>` and `docstring_audit.py --file <path> --check`.
