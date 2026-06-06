---
inclusion: manual
---

# analytics

## Mission
Own offline analysis of logs, telemetry, and session records.

## When To Use
- Reading engine logs for trends.
- Analyzing saved telemetry or session events.
- Summarizing crash or warning patterns.
- Comparing measurements across runs.

## When To Skip
- Live bug debugging, adding or tuning log output.

## Rules

### Primary Evidence Sources
- Frame/perf telemetry → `logs/data/frame_stats_*.jsonl`
- Test results → `logs/quality/`
- Coverage → output of `tools/audit/test_coverage.py` and `tools/audit/doc_coverage.py`
- Game session data → `save/` (runtime state, not a formal analytics store)

### Dataframe API
`src/dataframe/` implements an in-engine columnar table with SQL-like query support. Query surface is `src/dataframe/query/mod.rs` and `src/dataframe/sql.rs`.

### Separation of Concerns
- Frame-time regression analysis = "did a code change hurt performance?"
- Gameplay balance analysis = "is a content design fair?"
- Coverage analysis = "where are the gaps?"
These are different workflows with different data sources. Do not blend them in a single report.

### Sample Validity Checklist
Before drawing a conclusion: (1) sample size ≥ 30 for statistical claims, (2) all samples from the same engine version, (3) data from release mode, not debug, (4) outliers (GC pauses, first-frame warm-up) excluded. A conclusion failing any of these is SUSPECT.

### Reproducible Queries
Write analysis as a Python script in `tools/audit/` or `work/{session}/scripts/` with a fixed input path and deterministic output. Ad hoc manual counts cannot be verified when data changes.

### Missing Metrics
When a metric is missing from the data source, report the missing field, the query that would produce it, and what instrumentation would be needed. Do not interpolate or proxy a missing metric without labeling it as estimated.

### Schema Evolution
`logs/data/` files may have inconsistent schemas across sessions. Always inspect the schema before aggregating across sessions. Use `pandas.DataFrame.dropna()` to handle missing fields, not silent zero-fill.

## References
- `logs/data/`
- `logs/reports/`
- `src/dataframe/`
- `docs/specs/dataframe.md`
- `tools/audit/test_analytics.py`
