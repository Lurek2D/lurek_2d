# Audit Contract

Covers work under `tools/audit/`.

## Mission & Scope
- Own code quality audits, documentation coverage analyzers, and static analysis checkers.
- Maintain tools that inspect code boundaries, verify spec alignment, and parse test logs.
- Provide objective, script-driven reports on performance profiling, stress testing, and code health.

## Files
- `audit_module.py`: Main module-auditing entry point verifying specifications and test presence.
- `cag_link_check.py`: Static analysis tool validating Markdown link target existence.
- `doc_coverage.py`: Script evaluating complete API doc coverage in Rust and Lua source files.
- `test_coverage.py`: Script calculating test-to-module coverage ratios.

## Rules
- Audits must print precise, actionable diagnostics, detailing the target file, line number, and exact policy violation.
- Flag banned code patterns such as using `println!` or `eprintln!` directly within core engine modules (use `lurek.log` channels instead).
- All profiling/stress audit reports must be calculated based on release-mode binary builds.
- Parsers must be tested to ensure backward compatibility with historical test log files.

## Workflow
- Run individual checks (e.g., `python tools/audit/cag_link_check.py --strict`) to trace links.
- Audit a specific engine module using `python tools/audit/audit_module.py --module <name>`.

## References
- tools/audit/audit_module.py
- tools/audit/cag_link_check.py
- tools/audit/doc_coverage.py
