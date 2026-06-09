# Audit Contract

This file adds local rules for work under `tools/audit/`.

## Mission
- Own repository audit scripts, coverage reports, log parsers, and quality or profiling evidence tooling.

## Local rules
- Keep audit outputs actionable: findings should identify the phase or gate, the file or module, and the specific failing condition.
- `audit_module.py` is the authoritative module audit entry point. If its expectations change, keep the phase model, downstream docs, and coverage helpers aligned.
- Module audits should keep checking structural boundaries, spec presence, Lua API coverage, example or wiki coverage, dependency direction, and banned patterns such as `println!` in engine modules.
- Coverage tools and quality reports are evidence generators, not replacements for the governing spec or test contract.
- Prefer reproducible scripts over manual interpretation when aggregating logs, coverage, or stress data.
- Stress and performance helpers should point users to a baseline-first workflow rather than ad hoc profiling guesses.
- Parser changes must preserve compatibility with the harness or log format they consume, or explicitly update the paired producer in the same task.
- Primary analysis sources are `logs/data/` for telemetry, `logs/quality/` for quality outputs, and audit script outputs for coverage gaps. Keep source-specific assumptions explicit in the report.
- Check schema shape before aggregating telemetry across sessions; older data may not match newer fields.
- Statistical claims need enough comparable samples and a single engine-version basis. Do not present cross-version mixed data as one clean trend.
- Performance gates should assume release-mode measurements, not debug builds.
- Use `stress_report.py` or the existing perf gate before ad hoc profiling so the first read is comparable to prior runs.
- Keep performance reports attributable: do not mix correctness fixes and optimization claims in one measurement summary.

## Workflow
- Read the audit script entry point before changing helper modules or report formats.
- Validate the narrowest script or report path first, then rerun the broader gate that depends on it.

## References
- `tools/audit/audit_module.py`
- `tools/audit/doc_coverage.py`
- `tools/audit/test_coverage.py`
- `tools/audit/parse_test_log.py`
- `tools/audit/stress_report.py`
