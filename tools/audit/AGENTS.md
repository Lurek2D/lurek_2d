# Audit Contract

Covers work under `tools/audit/`.

## Mission
- Own repository audit scripts, coverage reports, log parsers, and quality or profiling evidence tooling.

## Scope
- `tools/audit/` audit scripts, reports, and parsers.

## Local map
- `audit_module.py` is the module audit entry point.
- `doc_coverage.py`, `test_coverage.py`, `parse_test_log.py`, and `stress_report.py` are the main helpers.
- `logs/data/` and `logs/quality/` are primary analysis sources.

## Rules
- Keep audit outputs actionable: name the phase or gate, file or module, and failing condition.
- Keep module audits checking boundaries, spec presence, Lua API coverage, example or wiki coverage, dependency direction, and banned patterns such as `println!` in engine modules.
- Coverage tools and quality reports are evidence generators, not replacements for the governing spec or test contract.
- Prefer reproducible scripts over manual interpretation.
- Stress and performance helpers should point to a baseline-first workflow.
- Parser changes must preserve compatibility with the harness or log format, or update the paired producer in the same task.
- Check schema shape before aggregating telemetry.
- Statistical claims need enough comparable samples and a single engine version.
- Performance gates should assume release-mode measurements.
- Use `stress_report.py` or the existing perf gate before ad hoc profiling.
- Keep performance reports attributable.

## Workflow
- Read the audit script entry point before changing helper modules or report formats.
- Validate the narrowest script or report path first, then rerun the broader gate that depends on it.

## References
- `tools/audit/audit_module.py`
- `tools/audit/doc_coverage.py`
- `tools/audit/test_coverage.py`
- `tools/audit/parse_test_log.py`
- `tools/audit/stress_report.py`
