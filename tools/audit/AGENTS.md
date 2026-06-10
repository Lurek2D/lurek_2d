# Audit Contract

Adds local rules for `tools/audit/`.

## Mission & Scope
- Own code quality audits, doc coverage analyzers, and static analysis checkers.
- Maintain tools that inspect boundaries, verify spec alignment, and parse test logs.
- Provide objective script-driven reports on profiling, stress, and code health.

## Files
- `audit_module.py`: Main module-auditing entry point verifying specifications and test presence.
- `cag_link_check.py`: Static analysis tool validating Markdown link target existence.
- `doc_coverage.py`: Script checking API doc coverage in Rust and Lua source.
- `test_coverage.py`: Script calculating test-to-module coverage.

## Rules
- Audits must print precise, actionable diagnostics, detailing the target file, line number, and exact policy violation.
- Flag banned code patterns only when the repository defines a clear, enforceable replacement or exception policy.
- All profiling/stress audit reports must be calculated based on release-mode binary builds.
- Parsers must be tested to ensure backward compatibility with historical test log files.

## Workflow
- Run individual checks (e.g., `tools/python.cmd tools/audit/cag_link_check.py --strict`) to trace links.
- Audit a specific engine module using `tools/python.cmd tools/audit/audit_module.py --module <name>`.

## References
- tools/audit/audit_module.py
- tools/audit/cag_link_check.py
- tools/audit/doc_coverage.py

