# dataframe manual spec overlay

## TL;DR

- Manages DataFrames, databases, SQL query execution, and lazy pipelines.
- Employs parallel vectorized column operations and background query threads.
- Computes rolling statistics, pivot tables, and CSV/JSON/LVDF serialization.

## Summary

- The `dataframe` module is the engine's tabular-data workspace for users who want table-shaped information to be loaded, queried, transformed, summarized, and exported without leaving the runtime.
- At its core are `DataFrame` and `Database` concepts that let a project work with both standalone tables and related multi-table collections, which is important because some workflows are local column operations while others look more like lightweight analytics databases.
- Query behavior is deliberately broad. Filtering, sorting, slicing, grouping, joining, pivoting, window calculations, ranking, cumulative metrics, and percent-change analysis all live under the same module family so data processing can stay close to the game or tool using it.
- SQL-like execution makes the feature practical for users who think declaratively, while direct frame methods keep it approachable for scripts that prefer explicit programmatic transformation.
- Lazy pipelines are a major functional category because they let callers stage a sequence of operations and materialize only when needed, which helps organize larger data workflows without immediately paying every computation cost.
- Vectorized execution extends the module from convenient table manipulation into more serious numeric workloads. Typed column stores and parallel operations make the same data model useful for both exploratory and performance-sensitive processing.
- Import and export paths such as CSV, JSON, and LVDF matter because real projects move data between authoring tools, analytics views, gameplay state, and regression artifacts. The module is designed to sit in the middle of that movement rather than only at one endpoint.
- Background task support is important from the user perspective because parsing and querying tables can become expensive; off-thread execution lets a project keep the same conceptual API while moving heavier work away from the frame-critical path.
- Diagnostics such as missing-value reports, duplicate analysis, and descriptive statistics turn the module into a quality and validation aid, not only a storage surface. That is useful for telemetry, balancing, content audits, and data-heavy debugging.
- Because joins, windows, grouping, and summary statistics live beside import/export, the module can support full analysis loops inside the engine: ingest data, clean it, compare it, visualize it elsewhere, and persist the refined result.
- That makes the same table model useful for both exploratory inspection and repeatable reporting workflows.
- This makes `dataframe` a natural backbone for reporting-oriented tools and live dashboards where structured content and metrics need to be manipulated with more discipline than generic Lua tables provide.
- That shared table model keeps ingest, analysis, export, and visualization steps connected.
- Read `dataframe` as the engine feature that turns structured tables into a first-class runtime capability. Other systems provide the data or consume the results, but this module owns how tabular information is modeled, queried, transformed, analyzed, and persisted.

This module is mostly self-contained inside the Foundations group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
