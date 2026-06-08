---
name: quality-pipeline
description: "Load this skill when running quality checks, audits, coverage tools, or doc generation. Skip it for writing code, tests, or doc content."
---
# quality-pipeline

## Use when
- Run pre-commit checks.
- Pick the right audit or validator.
- Read tool output.
- Run the full doc pipeline.

## Avoid when
- Writing Rust code.
- Writing tests.
- Writing docs.

## Repo rules
- Quality gate order: `python tools/dev/parallel_cargo.py fmt check` â€” formatting, `python tools/dev/parallel_cargo.py clippy --deny-warnings` â€” zero-warning lint, `python tools/dev/parallel_cargo.py test rust` â€” Rust tests, `python tools/dev/parallel_cargo.py test lua` â€” Lua harness, `python tools/gen_all_docs.py` â€” docs freshness. Running them out of order wastes time â€” fmt and clippy failures are cheap to fix early.
- Use the correct entry point for the change type: Lua API change â†’ `python tools/validate/validate_generated_lua_stubs.py`. Module structure change â†’ `python tools/validate/validate_module_coverage.py`.
- `python tools/audit/quality_report.py` outputs a module-by-module quality score. Interpret it as a routing signal: modules with score < 70 are candidates for an audit task.
- Clippy with `-D warnings` is a hard gate. Every warning is a blocker.
- Generated files must be committed in the same PR as the source changes that produced them. CI catches stale generated files by running the generator and diffing.
- `parallel_cargo.py` handles workspace-level parallelism and output formatting. Prefer it over raw `cargo` commands for test, clippy, and fmt so output format stays stable and CI/local behavior is identical.
- When a quality check fails intermittently in CI but passes locally, the most common causes are: non-deterministic Lua tests due to missing fixed seed, generated docs that differ by line ending, a test that reads wall-clock time.
- `python tools/audit/doc_coverage.py` and `python tools/audit/test_coverage.py` are health indicators, not gates. Run them before major releases or module audits to identify where quality investment is needed.
- Test the full Quality Gate task before any commit that touches multiple files. The task sequence aborts at the first failure, so early failures are found first.

## Checks
- `python tools/dev/parallel_cargo.py fmt check`
- `python tools/validate/validate_generated_lua_stubs.py`
- `python tools/audit/quality_report.py`
- `python tools/audit/doc_coverage.py`

## References
- `tools/README.md`
- `tools/gen_all_docs.py`
- `tools/audit/quality_report.py`
- `tools/validate/`

