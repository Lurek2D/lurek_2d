# dataframe

## General Info

- Module group: `Foundations`
- Source path: `src/dataframe/`
- Binding: `src/lua_api/dataframe_api.rs`
- Namespace: `lurek.dataframe`
- Lua API surface: `15` functions, `6` types, `143` methods
- Rust test path(s): tests/rust/unit/dataframe_tests.rs
- Lua test path(s): tests/lua/unit/test_dataframe.lua; tests/lua/stress/test_dataframe_stress.lua; tests/lua/integration/test_compute_dataframe.lua; tests/lua/golden/test_dataframe_golden.lua

## Summary

The dataframe module delivers a complete tabular data workspace and in-memory relational database framework for Lurek2D. Its core purpose is to provide scripts and engine subsystems with high-performance table management, enabling tabular gameplay data, analytics, and diagnostic reporting. It centers around a dual model: DataFrames storing structured columns and typed cell values, and Databases grouping multiple tables under one logical schema boundary for relational queries and frame joins.

To retrieve and transform tabular datasets efficiently, the module supports declarative and pipeline-based query designs. It incorporates a SQL-style parsing engine that executes structured query text—including table joins, multi-column filters, having clauses, projection arithmetic with aliasing, and aggregate groupings—over database tables. Alternatively, developers can chain sorting, slicing, and column selections into lazy query pipelines that defer execution, optimizing resources by only materializing data when collected.

For heavy statistical calculations over large tables, the module integrates a vectorized column storage layer. It stores raw column vectors with validity masks, executing mathematical reductions and binary operations in parallel using a Rayon thread pool. To keep gameplay loops responsive and frame rates stable, it provides background task managers that run file parsing and complex SQL queries on asynchronous worker threads, returning results through pollable handles and thread-safe snapshots.

Tabular analysis is bolstered by advanced statistical windowing and reshaping operations. The engine computes rolling aggregates like rolling means, sums, minimums, and maximums across chronological rows, along with dense rankings, cumulative running totals, and percentage changes for trend analysis. This is complemented by pivot-table reshaping, min-max normalizations, z-score transformations, Pearson correlation matrices, and duplicate-row diagnostic reports for data validation.

Data persistence and interchange are handled through a robust serialization system. The module parses and encodes tables across multiple standard formats, offering CSV file loading with automatic type inference, JSON data mapping for nested database structures, and a compact proprietary binary format (LVDF) for optimized storage on disk. It also includes automatic text-table formatting utilities that render data tables into highly legible diagnostic logs for session debugging.

## Files

### [file_io.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/dataframe/file_io.rs)

- Implements storage-agnostic persistence helpers for DataFrame and Database payload workflows.
- Defines narrow read and write abstraction traits decoupled from concrete filesystem backends.
- Bridges CSV, JSON, and binary serializers with caller-provided storage transport operations.
- Preserves distinct error domains for storage, parsing, and format conversion failure handling.
- Serves as the persistence integration layer for runtime and binding-side dataframe file operations.

### [frame.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/dataframe/frame.rs)

- Implements the core DataFrame and Database runtime models with typed cell-value representation.
- Stores table data in named column structures with stable row-wise access semantics.
- Supports column resolution by name or index for flexible scripting and API integration paths.
- Provides row and column lifecycle operations including add, remove, rename, and mutation workflows.
- Exposes slicing, cloning, iteration, and structural transformation helpers for table processing.
- Maintains multi-table database containers that group frames under stable logical identifiers.
- Includes random-data generation and expression-evaluation helpers for synthetic and derived columns.
- Supports pivot-style reshaping with configurable aggregation behavior across grouping dimensions.
- Implements rolling and rank-oriented analytics over sequential data windows.
- Defines aggregation enum contracts and parsing behavior for consistent operation selection.
- Preserves deterministic data-shape handling and explicit error reporting on invalid operations.
- Serves as the foundational dataframe domain layer consumed by SQL, lazy, and vectorized modules.

### [lazy.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/dataframe/lazy.rs)

- Implements deferred dataframe query planning through composable step-chain descriptions.
- Stores filter, sort, select, window, and limit operations without immediate execution.
- Materializes lazy plans on collect by applying steps over cloned source-frame state.
- Preserves deterministic step order and transformation semantics during pipeline realization.
- Serves as the lazy-query orchestration layer for staged dataframe processing.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/dataframe/mod.rs)

- Defines the dataframe module boundary for typed tabular storage, query execution, and serialization flows.
- Groups core frame models, lazy operations, SQL parsing, threaded tasks, and vectorized processing layers.
- Serves as the composition entry for all engine-side dataframe capabilities and integrations.

### [query/analytics.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/dataframe/query/analytics.rs)

- Implements statistical analytics helpers over dataframe columns and derived numeric distributions.
- Provides percentile extraction through interpolation on ordered numeric sample sequences.
- Supports z-score and min-max normalization for consistent feature scaling workflows.
- Includes outlier detection, mode estimation, and entropy-style spread characterization helpers.
- Serves as the compact statistics layer used by higher query and reporting operations.

### [query/filter.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/dataframe/query/filter.rs)

- Implements primary row and column query transforms for dataframe selection and restructuring.
- Applies predicate-based filtering with comparison and text containment operator semantics.
- Provides ordering, slicing, projection, and uniqueness extraction over tabular datasets.
- Supports grouping and join composition for cross-frame and keyed relational-style operations.
- Includes deterministic sampling, nil handling, and batch append utilities for data preparation.
- Computes common aggregate statistics and descriptive summary frames across numeric columns.
- Exposes import and export helpers for numeric column vectors and merged frame workflows.
- Serves as the high-utility query manipulation layer for core dataframe use cases.

### [query/grouping.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/dataframe/query/grouping.rs)

- Implements grouping-oriented dataframe operations for keyed aggregation and cross-tab reshaping.
- Aggregates grouped values with selectable reducers such as mean, sum, min, max, and count.
- Builds pivoted result frames from row, column, and value key combinations.
- Computes pairwise Pearson correlation between selected numeric columns.
- Generates full numeric correlation matrices for multivariate relationship inspection.
- Preserves deterministic group output construction and explicit missing-value handling paths.
- Serves as the grouping and correlation analytics layer for dataframe query pipelines.

### [query/mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/dataframe/query/mod.rs)

- Defines the dataframe query module boundary for filtering, grouping, processing, analytics, and window logic.
- Groups query submodules under one cohesive extension surface over core frame structures.
- Serves as the composition entry for staged dataframe query operations.

### [query/processing.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/dataframe/query/processing.rs)

- Implements dataframe processing helpers for frequency summaries and table-quality diagnostics.
- Builds value-count tables with optional percentage columns for distribution inspection.
- Produces missing-value reports and duplicate-row extraction over full-row or keyed comparisons.
- Appends parsed ISO date parts into structured year, month, and day output columns.
- Serves as a reusable cleanup and profiling layer for downstream dataframe query workflows.

### [query/window.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/dataframe/query/window.rs)

- Implements window-style dataframe computations over ordered row sequences and bounded spans.
- Provides rolling mean, sum, min, and max evaluation with configurable window lengths.
- Computes dense-style ranking with stable tie handling across repeated numeric values.
- Supports row-over-row percent-change derivation for trend and momentum analysis.
- Builds cumulative running totals across ordered rows for progressive metric inspection.
- Serves as the window-function layer for time-like and sequence-aware dataframe analytics.

### [rng.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/dataframe/rng.rs)

- Implements lightweight xorshift64 random generation used by dataframe-local sampling utilities.
- Produces deterministic integer, float, and index outputs from a compact 64-bit state.
- Remaps zero seed values to prevent degenerate all-zero generator behavior.

### [serial.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/dataframe/serial.rs)

- Implements serialization and parsing for dataframe and database payloads across multiple formats.
- Supports CSV decode and encode with quoting, escaping, and type-inference behavior.
- Provides JSON array-object conversion between textual payloads and dataframe structures.
- Handles nested JSON values and arrays during parser traversal and value coercion.
- Encodes and decodes compact LVDF binary format for efficient dataframe transport storage.
- Supplies text-table rendering helpers for debugging and readable frame inspection outputs.
- Serializes complete database table collections into JSON with stable named table mapping.
- Parses database-level JSON payloads back into structured table collections.
- Preserves explicit parse and conversion failure reporting across supported format paths.
- Serves as the format-conversion backbone for dataframe persistence and interchange.

### [sql.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/dataframe/sql.rs)

- Implements SQL-like query execution over dataframe and database table structures.
- Tokenizes input query text into typed lexical units for downstream parser consumption.
- Parses SELECT statements through recursive-descent grammar with explicit clause ordering.
- Builds expression trees for WHERE and HAVING filters including boolean and pattern operators.
- Supports projection arithmetic with aliasing and function-call style aggregate expressions.
- Executes grouping, aggregation, ordering, limits, and offsets over intermediate query results.
- Parses and applies join clauses for multi-table query paths within database containers.
- Implements LIKE-style wildcard matching semantics compatible with SQL-style pattern tokens.
- Validates column and table references with structured error reporting on unresolved names.
- Exposes query entry points for both single-frame and multi-table execution contexts.
- Preserves deterministic clause semantics and result-shape construction behavior.
- Balances expressiveness with bounded parser and evaluator complexity for runtime safety.
- Serves as the declarative query layer on top of core dataframe manipulation primitives.
- Integrates tightly with frame and value contracts for consistent type handling outcomes.
- Anchors script-facing tabular querying with predictable parser and execution behavior.

### [task.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/dataframe/task.rs)

- Implements one-shot threaded dataframe jobs for file loading and SQL query execution.
- Captures worker-side data snapshots to avoid large payload transfer through script boundaries.
- Provides poll, wait, progress, result, and error lifecycle helpers for async task management.
- Executes dataframe and database operations on worker threads with bounded state handoff.
- Serves as the asynchronous execution layer used by Lua-facing dataframe task APIs.

### [vectorized.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/dataframe/vectorized.rs)

- Implements typed vectorized column storage for high-throughput dataframe-style numeric processing.
- Supports float, integer, boolean, and text columns with optional validity-mask semantics.
- Provides scalar element-wise transforms across arithmetic and unary operation families.
- Executes binary column operations with dtype-aware coercion and compatibility checks.
- Computes reductions including sum, mean, min, max, variance, and related aggregate metrics.
- Generates comparison masks for predicate-style filtering over typed column values.
- Supports bidirectional conversion between vectorized frames and generic dataframe representations.
- Applies parallelized multi-column operations and reductions via rayon-backed execution paths.
- Handles explicit column casting between numeric and textual type domains.
- Preserves boolean-mask filtering behavior consistently across all supported column types.
- Balances performance-oriented storage layout with conversion interoperability requirements.
- Serves as the vectorized acceleration layer above core dataframe contracts.
