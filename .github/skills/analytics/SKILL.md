---
name: analytics
description: "Load this skill when collecting or reading logs, telemetry, SQL results, DataFrame tables, perf counters, or session records for analysis. Skip it for live bug debugging or for adding log output."
---
# analytics

## Mission
- Own offline analysis of logs, telemetry, and session records.

## When To Load
- Read engine logs for trends.
- Analyze saved telemetry or session events.
- Summarize crash or warning patterns.
- Compare measurements across runs.

## When To Skip
- Live bug debugging.
- Adding or tuning log output.

## Domain Knowledge
- Primary evidence sources by type: frame/perf telemetry → `logs/data/frame_stats_*.jsonl`; test results → `logs/quality/`; coverage → output of `tools/audit/test_coverage.py` and `tools/audit/doc_coverage.py`; game session data → `save/`.
- `src/dataframe/` implements an in-engine columnar table with SQL-like query support. The query surface is `src/dataframe/query/mod.rs` and `src/dataframe/sql.rs`.
- Separation of concerns: frame-time regression analysis answers "did a code change hurt performance?"; gameplay balance analysis answers "is a content design fair?"; coverage analysis answers "where are the gaps?". These are different workflows with different data sources.
- Sample validity checklist before drawing a conclusion: Is sample size ≥ 30 for statistical claims? (2) Are all samples from the same engine version?
- Reproducible queries: write analysis as a Python script in `tools/audit/` or `work/{session}/scripts/` with a fixed input path and deterministic output. Ad hoc manual counts cannot be verified or re-run when data changes.
- When a metric is missing from the data source, report the missing field, the query that would produce it, and what instrumentation would be needed to fill the gap. Do not interpolate or proxy a missing metric without labeling it as estimated.
- Telemetry schema evolution: `logs/data/` files may have inconsistent schemas across sessions. Always inspect the schema before aggregating across sessions.
- Engine quality metrics are in `logs/quality/` and are produced by `python tools/audit/quality_report.py`. These are module-level, not per-commit.
- Balance analysis for library modules: check `library/<name>/example.lua` and `tests/lua/library/test_library_<name>.lua` for the baseline scenario. If a balance question cannot be answered from existing test fixtures, recommend adding a parameterized scenario test rather than inventing simulation data.
## Companion File Index
- None.

## References
- logs/data/
- logs/reports/
- src/dataframe/
- docs/specs/dataframe.md
- tools/audit/test_analytics.py