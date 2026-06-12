# dataframe

## TL;DR

- Manages DataFrames, databases, SQL query execution, and lazy pipelines.
- Employs parallel vectorized column operations and background query threads.
- Computes rolling statistics, pivot tables, and CSV/JSON/LVDF serialization.

## General Info

- Module group: `Foundations`
- Source path: `src/dataframe/`
- Binding: `src/lua_api/dataframe_api.rs`
- Namespace: `lurek.dataframe`
- Lua API surface: `15` functions, `6` types, `145` methods
- Rust test path(s): tests/rust/unit/dataframe_tests.rs
- Lua test path(s): tests/lua_reorg/unit/test_dataframe.lua; tests/lua_reorg/stress/test_dataframe_stress.lua; tests/lua_reorg/integration/test_compute_dataframe.lua; tests/lua_reorg/golden/test_dataframe_golden.lua

## Summary

- This module gives users an in-engine data workspace for tables, analytics, and report-style processing.
- You can load, build, and transform tabular datasets without moving data into external tools.
- It supports both DataFrame-style column operations and multi-table database-style organization.
- SQL-like query support enables joins, filters, grouping, and projections in a familiar declarative form.
- Lazy query pipelines allow staging transformations before collecting results, which helps control runtime cost.
- Vectorized execution accelerates numeric-heavy column operations for larger datasets.
- Background task APIs keep expensive parsing or query work off the frame-critical path.
- Window functions support rolling metrics, ranking, cumulative totals, and percent-change analysis.
- Pivot and grouping features make it practical to reshape gameplay telemetry into decision-ready views.
- Statistical helpers like correlation, percentile, and normalization support balancing and anomaly detection.
- Duplicate and missing-value diagnostics help validate imported content before it drives gameplay systems.
- The module can serialize and parse common formats, including CSV and JSON, for workflow interoperability.
- LVDF binary support gives teams a compact storage format for faster load and smaller disk footprint.
- Text-table rendering helps users inspect results quickly in logs and debug consoles.
- Database containers allow related tables to be queried together instead of manually merged in script code.
- Typed value handling reduces brittle parsing and conversion logic in downstream gameplay scripts.
- This module is useful for economy simulation, quest metrics, AI telemetry, and content QA pipelines.
- It supports both exploratory analysis during development and deterministic processing in shipped logic.
- Users can move from raw records to actionable summaries without leaving the runtime.
- The practical value is fewer custom table utilities and more consistent data operations across teams.
- It also shortens iteration loops by keeping ingest, transform, validate, and export in one namespace.
- For performance-sensitive projects, parallel/vectorized paths reduce pressure on plain Lua loops.
- For tool-facing scripts, async handles provide predictable status polling and error capture.
- In short, the module turns tabular data work into a first-class gameplay and tooling capability.
- It bridges content pipelines and runtime behavior with one coherent API model.
- This makes data-driven development easier to maintain as project complexity grows.
- Users gain both expressiveness and operational control for serious in-engine analytics workloads.
- The outcome is better observability, cleaner pipelines, and faster balancing decisions.

This module is mostly self-contained inside the Foundations group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Files

### file_io.rs

- Implements storage-agnostic persistence helpers for DataFrame and Database payload workflows.
- Defines narrow read and write abstraction traits decoupled from concrete filesystem backends.
- Bridges CSV, JSON, and binary serializers with caller-provided storage transport operations.
- Preserves distinct error domains for storage, parsing, and format conversion failure handling.
- Serves as the persistence integration layer for runtime and binding-side dataframe file operations.

### frame.rs

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

### lazy.rs

- Implements deferred dataframe query planning through composable step-chain descriptions.
- Stores filter, sort, select, window, and limit operations without immediate execution.
- Materializes lazy plans on collect by applying steps over cloned source-frame state.
- Preserves deterministic step order and transformation semantics during pipeline realization.
- Serves as the lazy-query orchestration layer for staged dataframe processing.

### mod.rs

- Defines the dataframe module boundary for typed tabular storage, query execution, and serialization flows.
- Groups core frame models, lazy operations, SQL parsing, threaded tasks, and vectorized processing layers.
- Serves as the composition entry for all engine-side dataframe capabilities and integrations.

### query/analytics.rs

- Implements statistical analytics helpers over dataframe columns and derived numeric distributions.
- Provides percentile extraction through interpolation on ordered numeric sample sequences.
- Supports z-score and min-max normalization for consistent feature scaling workflows.
- Includes outlier detection, mode estimation, and entropy-style spread characterization helpers.
- Serves as the compact statistics layer used by higher query and reporting operations.

### query/filter.rs

- Implements primary row and column query transforms for dataframe selection and restructuring.
- Applies predicate-based filtering with comparison and text containment operator semantics.
- Provides ordering, slicing, projection, and uniqueness extraction over tabular datasets.
- Supports grouping and join composition for cross-frame and keyed relational-style operations.
- Includes deterministic sampling, nil handling, and batch append utilities for data preparation.
- Computes common aggregate statistics and descriptive summary frames across numeric columns.
- Exposes import and export helpers for numeric column vectors and merged frame workflows.
- Serves as the high-utility query manipulation layer for core dataframe use cases.

### query/grouping.rs

- Implements grouping-oriented dataframe operations for keyed aggregation and cross-tab reshaping.
- Aggregates grouped values with selectable reducers such as mean, sum, min, max, and count.
- Builds pivoted result frames from row, column, and value key combinations.
- Computes pairwise Pearson correlation between selected numeric columns.
- Generates full numeric correlation matrices for multivariate relationship inspection.
- Preserves deterministic group output construction and explicit missing-value handling paths.
- Serves as the grouping and correlation analytics layer for dataframe query pipelines.

### query/mod.rs

- Defines the dataframe query module boundary for filtering, grouping, processing, analytics, and window logic.
- Groups query submodules under one cohesive extension surface over core frame structures.
- Serves as the composition entry for staged dataframe query operations.

### query/processing.rs

- Implements dataframe processing helpers for frequency summaries and table-quality diagnostics.
- Builds value-count tables with optional percentage columns for distribution inspection.
- Produces missing-value reports and duplicate-row extraction over full-row or keyed comparisons.
- Appends parsed ISO date parts into structured year, month, and day output columns.
- Serves as a reusable cleanup and profiling layer for downstream dataframe query workflows.

### query/window.rs

- Implements window-style dataframe computations over ordered row sequences and bounded spans.
- Provides rolling mean, sum, min, and max evaluation with configurable window lengths.
- Computes dense-style ranking with stable tie handling across repeated numeric values.
- Supports row-over-row percent-change derivation for trend and momentum analysis.
- Builds cumulative running totals across ordered rows for progressive metric inspection.
- Serves as the window-function layer for time-like and sequence-aware dataframe analytics.

### rng.rs

- Implements lightweight xorshift64 random generation used by dataframe-local sampling utilities.
- Produces deterministic integer, float, and index outputs from a compact 64-bit state.
- Remaps zero seed values to prevent degenerate all-zero generator behavior.

### serial.rs

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

### sql.rs

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

### task.rs

- Implements one-shot threaded dataframe jobs for file loading and SQL query execution.
- Captures worker-side data snapshots to avoid large payload transfer through script boundaries.
- Provides poll, wait, progress, result, and error lifecycle helpers for async task management.
- Executes dataframe and database operations on worker threads with bounded state handoff.
- Serves as the asynchronous execution layer used by Lua-facing dataframe task APIs.

### vectorized.rs

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

## Types

- `DataFrameFileStore` (`trait`, `file_io.rs`): Minimal storage operations required by dataframe file persistence.
- `DataFrameFileError` (`enum`, `file_io.rs`): Error category for dataframe persistence over an external storage layer. Details: variants: Storage, Format
- `DataFrameFileResult` (`type`, `file_io.rs`): Result type used by dataframe file persistence helpers.
- `CellValue` (`enum`, `frame.rs`): Hold typed value stored in one dataframe cell. Details: variants: Nil, Number, Text, Bool | methods: as_bool (Return bool value when cell stores boolean.); as_number (Return numeric value when cell stores number.); as_text (Return text slice when cell stores text.); cmp_for_sort (Compare values for deterministic sort ordering.); is_nil (Return true when cell is nil.)
- `ColRef` (`enum`, `frame.rs`): Select column by name or one-based index. Details: variants: Name, Index
- `ColumnSchema` (`struct`, `frame.rs`): Describe one dataframe column for schema/introspection APIs. Details: fields: name: String, dtype: String, nullable: bool, count: usize
- `DataFrame` (`struct`, `frame.rs`): Hold columnar dataframe storage. Details: fields: column_names: Vec<String>, data: Vec<Vec<CellValue>> | methods: add_column (Add new column filled with default values.); add_row (Append row from sparse key-value input and return row index.); add_row_batch (Append batch of rows to frame and return error on width mismatch.); clone_df (Clone dataframe deeply.); collect_numbers (Collect numeric values from selected column.); column_data_mut (Return mutable column vector for selected column.); columns (Return ordered column names.); corr (Compute Pearson correlation between two numeric columns.); correlation_matrix (Build numeric-column correlation matrix frame.); count (Return row count alias.); count_by (Count occurrences by key column and return two-column frame.); date_parts (Return a new dataframe with ISO date year, month, and day columns appended.); describe (Build descriptive statistics frame for numeric columns.); drop_nil (Drop rows where selected column is nil.); duplicate_rows (Return rows whose full-row or selected-column key appears more than once.); entropy (Compute Shannon entropy over rendered cell values.); explain (Return a compact textual dataframe or SQL query plan summary.); extract_rows (Extract rows by indices and return new frame.); fill_nil (Replace nil values in selected column with provided value.); filter (Filter rows by column predicate and return matching frame.); from_raw (Build dataframe from raw column names and data vectors.); from_rows (Build dataframe from row-major data.); get_column (Return selected column slice.); get_column_as_f64 (Export selected column as f64 vector with nil as NaN.); get_row (Return cloned row values by index.); get_value (Return cloned cell value at row and column.); group_agg (Aggregate values by group key and return grouped result frame.); group_by (Group rows by key column and return grouped frames.); head (Return first n rows as new frame.); iter_rows (Return iterator over row views.); join (Join two frames by key columns and return merged frame.); lazy (Create lazy query from cloned current frame.); max_val (Return maximum numeric value from selected column.); mean (Compute mean of numeric values from selected column.); median (Compute median of numeric values from selected column.); merge (Append columns and rows from other frame into self.); min_val (Return minimum numeric value from selected column.); missing_report (Build a per-column missing-value report.); mode_val (Return most frequent non-nil value in selected column.); ncols (Return number of columns.); new (Create empty dataframe.); normalize_col (Normalize numeric column to output range and write result column.); nrows (Return number of rows.); outliers (Return rows where absolute z-score exceeds threshold.); par_apply_column (Parallel element-wise transform on a column.); par_filter (Parallel filter — uses rayon to scan rows when frame exceeds threshold.); par_group_agg (Parallel group-by aggregation — partitions by group column, aggregates each partition in parallel.); pivot (Pivot row and column keys into cross-tabulated frame.); pivot_table (Build pivot table from row key, column key, and value key.); random (Generate random dataframe from typed column definitions.); rank_column (Compute rank for numeric column and return dataframe with rank column.); raw_data (Return raw column storage reference.); remove_column (Remove selected column.); remove_row (Remove row by index.); rename_column (Rename selected column.); resolve_col (Resolve column selector to zero-based index.); rolling_mean (Compute rolling mean and return dataframe with appended column.); rolling_sum (Compute rolling sum and return dataframe with appended column.); sample (Sample up to n rows using deterministic optional seed.); schema (Return inferred schema metadata for every column.); select_columns (Select subset of columns and return new frame.); set_column_from_f64 (Set selected column from f64 vector with NaN mapped to nil.); set_value (Set cell value at row and column.); slice (Return inclusive row slice as new frame.); sort (Sort rows by column and return sorted frame.); stddev (Compute standard deviation of numeric values from column.); sum (Sum numeric values from selected column.); tail (Return last n rows as new frame.); to_binary (Serialize DataFrame to compact binary format bytes.); to_csv (Serialize DataFrame to CSV string.); to_json (Serialize DataFrame to JSON table string.); to_string_table (Render DataFrame as padded string table.); unique (Return unique values from selected column.); value_counts (Count occurrences of values in one column with optional percentage output.); variance (Compute variance of numeric values from column.); with_cumsum (Compute cumulative sum and append output column.); with_eval (Evaluate arithmetic expression per row and append result column.); with_pct_change (Compute row-to-row percent change and append output column.); with_rank (Compute rank over numeric column and append output column.); with_rolling_max (Compute rolling maximum and append output column.); with_rolling_mean (Compute rolling mean and append output column.); with_rolling_min (Compute rolling minimum and append output column.); with_rolling_sum (Compute rolling sum and append output column.); zscore_col (Compute z-score for numeric column and write result column.)
- `DataFrameRowIter` (`struct`, `frame.rs`): Iterate rows as vectors of column-name and cell references.
- `Database` (`struct`, `frame.rs`): Hold named tables for SQL-like database queries. Details: methods: add_table (Insert or replace table by name.); clear (Remove all tables.); clone_db (Clone database deeply.); get_table (Return immutable table reference by name.); get_table_mut (Return mutable table reference by name.); has_table (Return true when table exists.); list_tables (Return sorted list of table names.); merge (Merge another database into self by table name.); new (Create empty database.); remove_table (Remove table by name.); table_count (Return number of tables.); to_json (Serialize Database tables to JSON string.)
- `AggFn` (`enum`, `frame.rs`): Select aggregation mode for grouped operations. Details: variants: Mean, Sum, Min, Max, Count, First, Last | methods: parse (Parse aggregation label and return mode or error.)
- `LazyQuery` (`struct`, `lazy.rs`): Hold deferred query source frame and queued steps. Details: methods: collect (Execute deferred steps and return materialized frame.); drop_nil (Append drop-nil step and return updated query.); filter (Append filter step and return updated query.); head (Append head step and return updated query.); limit (Append row limit step and return updated query.); new (Create lazy query from source frame.); select (Append column selection step and return updated query.); slice (Append slice step and return updated query.); sort (Append sort step and return updated query.); tail (Append tail step and return updated query.); tombstone (Create empty sentinel lazy query.)
- `Xorshift64` (`struct`, `rng.rs`): Hold xorshift64 state used by dataframe-local random helpers. Details: methods: new (Create generator from seed and remap zero seed to one.); next_f64 (Return pseudo-random float in the half-open range [0, 1).); next_u64 (Advance generator and return next 64-bit pseudo-random value.); next_usize (Return pseudo-random index in the half-open range [0, max).)
- `DataFrameTask` (`struct`, `task.rs`): Owns one background dataframe job and its eventual result. Details: methods: get_error (Return the task error message when the task has failed.); is_done (Return true when the task has completed with success or failure.); progress (Return a coarse completion estimate from 0.0 to 1.0.); result (Return a cloned dataframe result after successful completion.); spawn_csv_file (Spawn a CSV file load task over a worker-owned storage snapshot.); spawn_database_query (Spawn a SQL query task over a database snapshot.); spawn_database_query_params (Spawn a parameterized SQL query task over a database snapshot.); spawn_dataframe_query (Spawn a SQL query task over a dataframe snapshot.); spawn_json_file (Spawn a JSON file load task over a worker-owned storage snapshot.); wait (Block until the task completes and return true only for a successful dataframe result.)
- `ColumnStore` (`enum`, `vectorized.rs`): Hold typed columnar storage with optional validity mask. Details: variants: Float64, Int64, Bool, Text | methods: dtype_name (Return static type name for this column variant.); filter (Filter rows by boolean mask and return new column.); is_empty (Return true when this column has no rows.); is_valid (Return true when row at index is valid according to validity mask.); len (Return number of rows in this column.); valid_f64s (Return valid f64 values for Float64 columns, skipping nil rows.)
- `ScalarOp` (`enum`, `vectorized.rs`): Select element-wise scalar operation applied to a column. Details: variants: Add, Sub, Mul, Div, Abs, Sqrt, Floor, Ceil, Neg | methods: parse (Parse operation label and return variant or error.)
- `BinaryOp` (`enum`, `vectorized.rs`): Select element-wise binary operation between two columns. Details: variants: Add, Sub, Mul, Div, Min, Max | methods: parse (Parse operation label and return variant or error.)
- `ReduceOp` (`enum`, `vectorized.rs`): Select aggregation operation over a column. Details: variants: Sum, Mean, Min, Max, Std, Var, Count | methods: parse (Parse operation label and return variant or error.)
- `CmpOp` (`enum`, `vectorized.rs`): Select comparison operation for mask generation. Details: variants: Lt, Le, Gt, Ge, Eq, Ne | methods: parse (Parse comparison operator string and return variant or error.)
- `VecFrame` (`struct`, `vectorized.rs`): Hold typed columnar frame used for vectorized and parallel operations. Details: methods: apply_mask (Filter all columns by boolean mask and return new VecFrame.); col_binary_op (Compute element-wise binary operation between two numeric columns and write result column.); col_cast (Cast named column to target type in place.); col_clamp (Clamp Float64 column values to inclusive range in place.); col_reduce (Reduce numeric column to single value using selected aggregation.); col_scalar_op (Apply scalar operation to Float64 column in place.); col_type (Return type name for named column.); columns (Return ordered column names.); filter_mask (Build boolean mask by comparing numeric column against scalar value.); from_dataframe (Convert DataFrame to VecFrame by inferring column types.); ncols (Return number of columns.); new (Create empty VecFrame.); nrows (Return number of rows.); par_reduce (Reduce multiple columns in parallel and return name-to-result map.); par_scalar_op (Apply scalar operation across multiple Float64 columns in parallel.); to_dataframe (Convert VecFrame back to DataFrame.)

## Functions

- `read_csv_dataframe` (`file_io.rs`): Read CSV text from storage, parse it, and return a dataframe.
- `read_json_dataframe` (`file_io.rs`): Read JSON text from storage, parse it, and return a dataframe.
- `write_csv_dataframe` (`file_io.rs`): Serialize a dataframe to CSV and write it through storage.
- `write_json_dataframe` (`file_io.rs`): Serialize a dataframe to JSON and write it through storage.
- `write_binary_dataframe` (`file_io.rs`): Serialize a dataframe to LVDF bytes and write them through storage.
- `load_json_database` (`file_io.rs`): Read JSON database text from storage, parse it, and return a database.
- `save_json_database` (`file_io.rs`): Serialize a database to JSON and write it through storage.
- `CellValue::is_nil` (`frame.rs`): Return true when cell is nil.
- `CellValue::as_number` (`frame.rs`): Return numeric value when cell stores number.
- `CellValue::as_text` (`frame.rs`): Return text slice when cell stores text.
- `CellValue::as_bool` (`frame.rs`): Return bool value when cell stores boolean.
- `CellValue::cmp_for_sort` (`frame.rs`): Compare values for deterministic sort ordering.
- `DataFrame::new` (`frame.rs`): Create empty dataframe.
- `DataFrame::nrows` (`frame.rs`): Return number of rows.
- `DataFrame::ncols` (`frame.rs`): Return number of columns.
- `DataFrame::columns` (`frame.rs`): Return ordered column names.
- `DataFrame::count` (`frame.rs`): Return row count alias.
- `DataFrame::schema` (`frame.rs`): Return inferred schema metadata for every column.
- `DataFrame::explain` (`frame.rs`): Return a compact textual dataframe or SQL query plan summary.
- `DataFrame::resolve_col` (`frame.rs`): Resolve column selector to zero-based index.
- `DataFrame::add_column` (`frame.rs`): Add new column filled with default values.
- `DataFrame::remove_column` (`frame.rs`): Remove selected column.
- `DataFrame::rename_column` (`frame.rs`): Rename selected column.
- `DataFrame::get_column` (`frame.rs`): Return selected column slice.
- `DataFrame::add_row` (`frame.rs`): Append row from sparse key-value input and return row index.
- `DataFrame::remove_row` (`frame.rs`): Remove row by index.
- `DataFrame::get_row` (`frame.rs`): Return cloned row values by index.
- `DataFrame::iter_rows` (`frame.rs`): Return iterator over row views.
- `DataFrame::get_value` (`frame.rs`): Return cloned cell value at row and column.
- `DataFrame::set_value` (`frame.rs`): Set cell value at row and column.
- `DataFrame::clone_df` (`frame.rs`): Clone dataframe deeply.
- `DataFrame::column_data_mut` (`frame.rs`): Return mutable column vector for selected column.
- `DataFrame::from_raw` (`frame.rs`): Build dataframe from raw column names and data vectors.
- `DataFrame::from_rows` (`frame.rs`): Build dataframe from row-major data.
- `DataFrame::raw_data` (`frame.rs`): Return raw column storage reference.
- `DataFrame::random` (`frame.rs`): Generate random dataframe from typed column definitions.
- `DataFrame::with_eval` (`frame.rs`): Evaluate arithmetic expression per row and append result column.
- `DataFrame::pivot_table` (`frame.rs`): Build pivot table from row key, column key, and value key.
- `DataFrame::rolling_mean` (`frame.rs`): Compute rolling mean and return dataframe with appended column.
- `DataFrame::rolling_sum` (`frame.rs`): Compute rolling sum and return dataframe with appended column.
- `DataFrame::rank_column` (`frame.rs`): Compute rank for numeric column and return dataframe with rank column.
- `Database::new` (`frame.rs`): Create empty database.
- `Database::add_table` (`frame.rs`): Insert or replace table by name.
- `Database::get_table` (`frame.rs`): Return immutable table reference by name.
- `Database::get_table_mut` (`frame.rs`): Return mutable table reference by name.
- `Database::remove_table` (`frame.rs`): Remove table by name.
- `Database::has_table` (`frame.rs`): Return true when table exists.
- `Database::list_tables` (`frame.rs`): Return sorted list of table names.
- `Database::table_count` (`frame.rs`): Return number of tables.
- `Database::clear` (`frame.rs`): Remove all tables.
- `Database::merge` (`frame.rs`): Merge another database into self by table name.
- `Database::clone_db` (`frame.rs`): Clone database deeply.
- `AggFn::parse` (`frame.rs`): Parse aggregation label and return mode or error.
- `LazyQuery::new` (`lazy.rs`): Create lazy query from source frame.
- `LazyQuery::tombstone` (`lazy.rs`): Create empty sentinel lazy query.
- `LazyQuery::filter` (`lazy.rs`): Append filter step and return updated query.
- `LazyQuery::sort` (`lazy.rs`): Append sort step and return updated query.
- `LazyQuery::select` (`lazy.rs`): Append column selection step and return updated query.
- `LazyQuery::head` (`lazy.rs`): Append head step and return updated query.
- `LazyQuery::tail` (`lazy.rs`): Append tail step and return updated query.
- `LazyQuery::slice` (`lazy.rs`): Append slice step and return updated query.
- `LazyQuery::drop_nil` (`lazy.rs`): Append drop-nil step and return updated query.
- `LazyQuery::limit` (`lazy.rs`): Append row limit step and return updated query.
- `LazyQuery::collect` (`lazy.rs`): Execute deferred steps and return materialized frame.
- `DataFrame::lazy` (`lazy.rs`): Create lazy query from cloned current frame.
- `percentile` (`query/analytics.rs`): Compute percentile by linear interpolation over sorted values.
- `DataFrame::zscore_col` (`query/analytics.rs`): Compute z-score for numeric column and write result column.
- `DataFrame::normalize_col` (`query/analytics.rs`): Normalize numeric column to output range and write result column.
- `DataFrame::outliers` (`query/analytics.rs`): Return rows where absolute z-score exceeds threshold.
- `DataFrame::mode_val` (`query/analytics.rs`): Return most frequent non-nil value in selected column.
- `DataFrame::entropy` (`query/analytics.rs`): Compute Shannon entropy over rendered cell values.
- `DataFrame::filter` (`query/filter.rs`): Filter rows by column predicate and return matching frame.
- `DataFrame::par_filter` (`query/filter.rs`): Parallel filter — uses rayon to scan rows when frame exceeds threshold.
- `DataFrame::sort` (`query/filter.rs`): Sort rows by column and return sorted frame.
- `DataFrame::head` (`query/filter.rs`): Return first n rows as new frame.
- `DataFrame::tail` (`query/filter.rs`): Return last n rows as new frame.
- `DataFrame::slice` (`query/filter.rs`): Return inclusive row slice as new frame.
- `DataFrame::select_columns` (`query/filter.rs`): Select subset of columns and return new frame.
- `DataFrame::unique` (`query/filter.rs`): Return unique values from selected column.
- `DataFrame::group_by` (`query/filter.rs`): Group rows by key column and return grouped frames.
- `DataFrame::join` (`query/filter.rs`): Join two frames by key columns and return merged frame.
- `DataFrame::merge` (`query/filter.rs`): Append columns and rows from other frame into self.
- `DataFrame::count_by` (`query/filter.rs`): Count occurrences by key column and return two-column frame.
- `DataFrame::drop_nil` (`query/filter.rs`): Drop rows where selected column is nil.
- `DataFrame::sample` (`query/filter.rs`): Sample up to n rows using deterministic optional seed.
- `DataFrame::sum` (`query/filter.rs`): Sum numeric values from selected column.
- `DataFrame::mean` (`query/filter.rs`): Compute mean of numeric values from selected column.
- `DataFrame::min_val` (`query/filter.rs`): Return minimum numeric value from selected column.
- `DataFrame::max_val` (`query/filter.rs`): Return maximum numeric value from selected column.
- `DataFrame::median` (`query/filter.rs`): Compute median of numeric values from selected column.
- `DataFrame::stddev` (`query/filter.rs`): Compute standard deviation of numeric values from column.
- `DataFrame::variance` (`query/filter.rs`): Compute variance of numeric values from column.
- `DataFrame::describe` (`query/filter.rs`): Build descriptive statistics frame for numeric columns.
- `DataFrame::fill_nil` (`query/filter.rs`): Replace nil values in selected column with provided value.
- `DataFrame::extract_rows` (`query/filter.rs`): Extract rows by indices and return new frame.
- `DataFrame::collect_numbers` (`query/filter.rs`): Collect numeric values from selected column.
- `DataFrame::add_row_batch` (`query/filter.rs`): Append batch of rows to frame and return error on width mismatch.
- `DataFrame::get_column_as_f64` (`query/filter.rs`): Export selected column as f64 vector with nil as NaN.
- `DataFrame::set_column_from_f64` (`query/filter.rs`): Set selected column from f64 vector with NaN mapped to nil.
- `DataFrame::group_agg` (`query/grouping.rs`): Aggregate values by group key and return grouped result frame.
- `DataFrame::par_group_agg` (`query/grouping.rs`): Parallel group-by aggregation — partitions by group column, aggregates each partition in parallel.
- `DataFrame::pivot` (`query/grouping.rs`): Pivot row and column keys into cross-tabulated frame.
- `DataFrame::corr` (`query/grouping.rs`): Compute Pearson correlation between two numeric columns.
- `DataFrame::correlation_matrix` (`query/grouping.rs`): Build numeric-column correlation matrix frame.
- `DataFrame::value_counts` (`query/processing.rs`): Count occurrences of values in one column with optional percentage output.
- `DataFrame::missing_report` (`query/processing.rs`): Build a per-column missing-value report.
- `DataFrame::duplicate_rows` (`query/processing.rs`): Return rows whose full-row or selected-column key appears more than once.
- `DataFrame::date_parts` (`query/processing.rs`): Return a new dataframe with ISO date year, month, and day columns appended.
- `DataFrame::with_rolling_mean` (`query/window.rs`): Compute rolling mean and append output column.
- `DataFrame::with_rolling_sum` (`query/window.rs`): Compute rolling sum and append output column.
- `DataFrame::with_rolling_min` (`query/window.rs`): Compute rolling minimum and append output column.
- `DataFrame::with_rolling_max` (`query/window.rs`): Compute rolling maximum and append output column.
- `DataFrame::with_rank` (`query/window.rs`): Compute rank over numeric column and append output column.
- `DataFrame::with_pct_change` (`query/window.rs`): Compute row-to-row percent change and append output column.
- `DataFrame::with_cumsum` (`query/window.rs`): Compute cumulative sum and append output column.
- `Xorshift64::new` (`rng.rs`): Create generator from seed and remap zero seed to one.
- `Xorshift64::next_u64` (`rng.rs`): Advance generator and return next 64-bit pseudo-random value.
- `Xorshift64::next_f64` (`rng.rs`): Return pseudo-random float in the half-open range [0, 1).
- `Xorshift64::next_usize` (`rng.rs`): Return pseudo-random index in the half-open range [0, max).
- `from_csv` (`serial.rs`): Parse CSV text and return DataFrame or validation error.
- `DataFrame::to_csv` (`serial.rs`): Serialize DataFrame to CSV string.
- `from_json` (`serial.rs`): Parse JSON table payload and return DataFrame.
- `DataFrame::to_json` (`serial.rs`): Serialize DataFrame to JSON table string.
- `DataFrame::to_binary` (`serial.rs`): Serialize DataFrame to compact binary format bytes.
- `from_binary` (`serial.rs`): Parse compact binary payload and return DataFrame.
- `DataFrame::to_string_table` (`serial.rs`): Render DataFrame as padded string table.
- `database_from_json` (`serial.rs`): Parse Database JSON produced by `Database::to_json`.
- `Database::to_json` (`serial.rs`): Serialize Database tables to JSON string.
- `query_sql` (`sql.rs`): Execute SQL-like query over one DataFrame and return result frame.
- `explain_sql` (`sql.rs`): Parse SQL-like query and return a compact execution-plan summary.
- `query_sql_database` (`sql.rs`): Execute SQL-like query against Database table references.
- `query_sql_database_params` (`sql.rs`): Execute SQL-like database query after binding positional parameters.
- `DataFrameTask::spawn_csv_file` (`task.rs`): Spawn a CSV file load task over a worker-owned storage snapshot.
- `DataFrameTask::spawn_json_file` (`task.rs`): Spawn a JSON file load task over a worker-owned storage snapshot.
- `DataFrameTask::spawn_dataframe_query` (`task.rs`): Spawn a SQL query task over a dataframe snapshot.
- `DataFrameTask::spawn_database_query` (`task.rs`): Spawn a SQL query task over a database snapshot.
- `DataFrameTask::spawn_database_query_params` (`task.rs`): Spawn a parameterized SQL query task over a database snapshot.
- `DataFrameTask::is_done` (`task.rs`): Return true when the task has completed with success or failure.
- `DataFrameTask::wait` (`task.rs`): Block until the task completes and return true only for a successful dataframe result.
- `DataFrameTask::result` (`task.rs`): Return a cloned dataframe result after successful completion.
- `DataFrameTask::get_error` (`task.rs`): Return the task error message when the task has failed.
- `DataFrameTask::progress` (`task.rs`): Return a coarse completion estimate from 0.0 to 1.0.
- `ColumnStore::dtype_name` (`vectorized.rs`): Return static type name for this column variant.
- `ColumnStore::len` (`vectorized.rs`): Return number of rows in this column.
- `ColumnStore::is_empty` (`vectorized.rs`): Return true when this column has no rows.
- `ColumnStore::is_valid` (`vectorized.rs`): Return true when row at index is valid according to validity mask.
- `ColumnStore::valid_f64s` (`vectorized.rs`): Return valid f64 values for Float64 columns, skipping nil rows.
- `ColumnStore::filter` (`vectorized.rs`): Filter rows by boolean mask and return new column.
- `ScalarOp::parse` (`vectorized.rs`): Parse operation label and return variant or error.
- `BinaryOp::parse` (`vectorized.rs`): Parse operation label and return variant or error.
- `ReduceOp::parse` (`vectorized.rs`): Parse operation label and return variant or error.
- `CmpOp::parse` (`vectorized.rs`): Parse comparison operator string and return variant or error.
- `VecFrame::new` (`vectorized.rs`): Create empty VecFrame.
- `VecFrame::nrows` (`vectorized.rs`): Return number of rows.
- `VecFrame::ncols` (`vectorized.rs`): Return number of columns.
- `VecFrame::columns` (`vectorized.rs`): Return ordered column names.
- `VecFrame::col_type` (`vectorized.rs`): Return type name for named column.
- `VecFrame::from_dataframe` (`vectorized.rs`): Convert DataFrame to VecFrame by inferring column types.
- `VecFrame::to_dataframe` (`vectorized.rs`): Convert VecFrame back to DataFrame.
- `VecFrame::col_scalar_op` (`vectorized.rs`): Apply scalar operation to Float64 column in place.
- `VecFrame::col_clamp` (`vectorized.rs`): Clamp Float64 column values to inclusive range in place.
- `VecFrame::col_binary_op` (`vectorized.rs`): Compute element-wise binary operation between two numeric columns and write result column.
- `VecFrame::col_reduce` (`vectorized.rs`): Reduce numeric column to single value using selected aggregation.
- `VecFrame::filter_mask` (`vectorized.rs`): Build boolean mask by comparing numeric column against scalar value.
- `VecFrame::apply_mask` (`vectorized.rs`): Filter all columns by boolean mask and return new VecFrame.
- `VecFrame::col_cast` (`vectorized.rs`): Cast named column to target type in place.
- `VecFrame::par_reduce` (`vectorized.rs`): Reduce multiple columns in parallel and return name-to-result map.
- `VecFrame::par_scalar_op` (`vectorized.rs`): Apply scalar operation across multiple Float64 columns in parallel.
- `DataFrame::par_apply_column` (`vectorized.rs`): Parallel element-wise transform on a column.

## Lua API Reference

### Functions

- `lurek.dataframe.fromBinary(s) -> LDataFrame`: Parses a dataframe from binary data.
- `lurek.dataframe.fromCSV(s) -> LDataFrame`: Parses a dataframe from CSV text. This function is exposed to Lua scripts.
- `lurek.dataframe.fromCSVFile(path, opts?) -> LDataFrame`: Reads CSV text from GameFS and parses it into a dataframe.
- `lurek.dataframe.fromCSVFileAsync(path, opts?) -> LDataFrameTask`: Starts a Rust worker task that reads CSV text from GameFS and parses it into a dataframe.
- `lurek.dataframe.fromJSON(s) -> LDataFrame`: Parses a dataframe from JSON text. This function is exposed to Lua scripts.
- `lurek.dataframe.fromJSONFile(path, opts?) -> LDataFrame`: Reads JSON text from GameFS and parses it into a dataframe.
- `lurek.dataframe.fromJSONFileAsync(path, opts?) -> LDataFrameTask`: Starts a Rust worker task that reads JSON text from GameFS and parses it into a dataframe.
- `lurek.dataframe.fromRows(columns_tbl, rows_tbl) -> LDataFrame`: Creates a dataframe from column names and array-style rows.
- `lurek.dataframe.fromTable(rows) -> LDataFrame`: Creates a dataframe from an array table of row tables.
- `lurek.dataframe.fromVec(vf) -> LDataFrame`: Converts a vectorized frame to a dataframe.
- `lurek.dataframe.loadDatabase(path, opts?) -> LDatabase`: Reads a JSON database file from GameFS and parses it into a database.
- `lurek.dataframe.newDataFrame() -> LDataFrame`: Creates an empty dataframe. This function is exposed to Lua scripts.
- `lurek.dataframe.newDatabase() -> LDatabase`: Creates an empty dataframe database.
- `lurek.dataframe.random(defs_tbl, n, seed?) -> LDataFrame`: Creates a random dataframe from column definitions.
- `lurek.dataframe.toVec(df) -> LVecFrame`: Converts a dataframe to a vectorized frame.

### Callbacks

- `LDataFrame:apply` param `func` (`function`): Function called with each cell value and returning a replacement value.
- `LGroupedFrame:aggregate` param `func` (`function`): Function called with an array table of numeric values and returning a number.

### Enums

- No documented module-level enums/constants.

### Types

#### LDataFrame Type

- Lua-side dataframe handle for tabular data with named columns and typed cells.

##### Fields

- No documented fields.

##### Methods

- `LDataFrame:addColumn(name, default?) -> nil`: Adds a column with an optional default value.
- `LDataFrame:addRow(row_tbl?) -> integer`: Adds a row from an optional map table and returns its one-based row index.
- `LDataFrame:addRowBatch(rows) -> nil`: Appends multiple rows from array-style row tables.
- `LDataFrame:apply(col_val, func) -> nil`: Applies a Lua function to each value in a column in place.
- `LDataFrame:clone() -> LDataFrame`: Returns a deep copy of this dataframe.
- `LDataFrame:columns() -> string[]`: Returns all column names in order. This method is available to Lua scripts.
- `LDataFrame:corr(col_a, col_b) -> number`: Returns correlation between two numeric columns.
- `LDataFrame:correlationMatrix() -> LDataFrame`: Returns a correlation matrix for numeric columns.
- `LDataFrame:count() -> integer`: Returns the row count for this dataframe.
- `LDataFrame:countBy(col) -> LDataFrame`: Counts occurrences of each value in a column.
- `LDataFrame:dateParts(date_col, prefix?) -> LDataFrame`: Returns a new dataframe with year, month, and day columns extracted from ISO `yyyy-mm-dd` text.
- `LDataFrame:describe() -> LDataFrame`: Returns summary statistics for numeric columns.
- `LDataFrame:dropNil(col) -> LDataFrame`: Returns rows where the chosen column is not nil.
- `LDataFrame:duplicateRows(cols?) -> LDataFrame`: Returns rows whose full-row key or selected-column key appears more than once.
- `LDataFrame:entropy(col) -> number`: Returns entropy for a column. This method is available to Lua scripts.
- `LDataFrame:explain(sql_str?) -> string`: Returns a compact dataframe or SQL query execution plan summary.
- `LDataFrame:fillNil(col, val) -> nil`: Replaces nil cells in a column with a value.
- `LDataFrame:filter(col, op, val) -> LDataFrame`: Returns rows whose column value matches a comparison.
- `LDataFrame:getColumn(col) -> number[]`: Returns a column as an array table. This method is available to Lua scripts.
- `LDataFrame:getColumnAsF64(col) -> number[]`: Returns a numeric column as an array of numbers.
- `LDataFrame:getRow(row) -> table`: Returns a row as a table keyed by column name.
- `LDataFrame:getValue(row, col) -> number|string|boolean|nil`: Returns one cell value by one-based row and column reference.
- `LDataFrame:groupAgg(group_col, agg_col, fn_name) -> LDataFrame`: Groups by one column and aggregates another column.
- `LDataFrame:groupBy(col) -> table`: Groups rows by a column and returns a table from group key to dataframe.
- `LDataFrame:groupByObj(col) -> LGroupedFrame`: Groups rows by a column and returns a grouped-frame object.
- `LDataFrame:head(n?) -> LDataFrame`: Returns the first rows of this dataframe.
- `LDataFrame:join(other, this_col, other_col, jtype?) -> LDataFrame`: Joins this dataframe with another dataframe by column references.
- `LDataFrame:lazy() -> LLazyQuery`: Starts a lazy query pipeline from this dataframe.
- `LDataFrame:max(col) -> number|string|boolean|nil`: Returns the maximum value of a column.
- `LDataFrame:mean(col) -> number`: Returns the numeric mean of a column.
- `LDataFrame:median(col) -> number`: Returns the numeric median of a column.
- `LDataFrame:merge(other) -> nil`: Appends another dataframe into this dataframe in place.
- `LDataFrame:min(col) -> number|string|boolean|nil`: Returns the minimum value of a column.
- `LDataFrame:missingReport(opts?) -> LDataFrame`: Reports missing and non-missing cell counts for every column.
- `LDataFrame:modeVal(col) -> number|string|boolean|nil`: Returns the mode value of a column. This method is available to Lua scripts.
- `LDataFrame:ncols() -> integer`: Returns the number of columns in this dataframe.
- `LDataFrame:normalizeCol(col, out_min, out_max, name) -> nil`: Adds a range-normalized column in place.
- `LDataFrame:nrows() -> integer`: Returns the number of rows in this dataframe.
- `LDataFrame:outliers(col, threshold?) -> LDataFrame`: Returns rows considered outliers for a numeric column.
- `LDataFrame:parFilter(col, op, val) -> LDataFrame`: Parallel filter â€” automatically parallelizes when frame has 10,000+ rows.
- `LDataFrame:parGroupAgg(group_col, agg_col, fn_name) -> LDataFrame`: Parallel group-by aggregation â€” partitions and aggregates in parallel.
- `LDataFrame:pivot(row_col, col_col, val_col) -> LDataFrame`: Pivots rows into columns using row, column, and value fields.
- `LDataFrame:pivotTable(row_key, col_key, value_key, agg?) -> LDataFrame`: Builds a pivot table using row key, column key, value column, and aggregate function.
- `LDataFrame:query(sql_str) -> LDataFrame`: Runs a SQL-style query against this dataframe.
- `LDataFrame:queryAsync(sql_str) -> LDataFrameTask`: Runs a SQL-style query against this dataframe on a Rust worker thread.
- `LDataFrame:rank(col, order?, result_col?) -> LDataFrame`: Returns a dataframe with a rank column.
- `LDataFrame:removeColumn(col) -> nil`: Removes a column by name or one-based index.
- `LDataFrame:removeRow(row) -> nil`: Removes a row by one-based index. This method is available to Lua scripts.
- `LDataFrame:rename(col, new_name) -> nil`: Renames a column by name or one-based index.
- `LDataFrame:rollingMean(col, window, result_col?) -> LDataFrame`: Returns a dataframe with a rolling mean column.
- `LDataFrame:rollingSum(col, window, result_col?) -> LDataFrame`: Returns a dataframe with a rolling sum column.
- `LDataFrame:rows() -> function`: Returns an iterator function over one-based row index and row table pairs.
- `LDataFrame:sample(n, seed?) -> LDataFrame`: Returns a sampled dataframe. This method is available to Lua scripts.
- `LDataFrame:schema() -> table`: Returns inferred column schema metadata.
- `LDataFrame:select(...) -> LDataFrame`: Returns a dataframe with selected columns.
- `LDataFrame:setColumnFromF64(col, values) -> nil`: Replaces a numeric column from an array table of numbers.
- `LDataFrame:setValue(row, col, val) -> nil`: Sets one cell value by one-based row and column reference.
- `LDataFrame:slice(start, end) -> LDataFrame`: Returns a one-based inclusive row slice.
- `LDataFrame:sort(col, ascending?) -> LDataFrame`: Returns rows sorted by a column. This method is available to Lua scripts.
- `LDataFrame:stddev(col) -> number`: Returns the numeric standard deviation of a column.
- `LDataFrame:sum(col) -> number`: Returns the numeric sum of a column.
- `LDataFrame:tail(n?) -> LDataFrame`: Returns the last rows of this dataframe.
- `LDataFrame:toBinary() -> string`: Serializes this dataframe to binary data.
- `LDataFrame:toBinaryFile(path, opts?) -> boolean`: Serializes this dataframe to LVDF binary data and writes it through GameFS.
- `LDataFrame:toCSV() -> string`: Serializes this dataframe to CSV text.
- `LDataFrame:toCSVFile(path, opts?) -> boolean`: Serializes this dataframe to CSV text and writes it through GameFS.
- `LDataFrame:toJSON() -> string`: Serializes this dataframe to JSON text.
- `LDataFrame:toJSONFile(path, opts?) -> boolean`: Serializes this dataframe to JSON text and writes it through GameFS.
- `LDataFrame:toString() -> string`: Formats this dataframe as a human-readable text table.
- `LDataFrame:toTable() -> table`: Converts this dataframe to an array table of row tables.
- `LDataFrame:type() -> string`: Returns the Lua-visible type name for this dataframe handle.
- `LDataFrame:typeOf(name) -> boolean`: Returns whether this dataframe handle matches a supported type name.
- `LDataFrame:unique(col) -> number[]`: Returns unique values from a column.
- `LDataFrame:valueCounts(col, opts?) -> LDataFrame`: Counts occurrences of each value in a column with optional percentage output.
- `LDataFrame:variance(col) -> number`: Returns the numeric variance of a column.
- `LDataFrame:withCumsum(col, name) -> nil`: Adds a cumulative-sum column in place.
- `LDataFrame:withEval(col_name, expr) -> LDataFrame`: Returns a dataframe with a column computed from an expression.
- `LDataFrame:withPctChange(col, name) -> nil`: Adds a percent-change column in place.
- `LDataFrame:withRank(col, asc?, name) -> nil`: Adds a rank column in place. This method is available to Lua scripts.
- `LDataFrame:withRollingMax(col, window, name) -> nil`: Adds a rolling maximum column in place.
- `LDataFrame:withRollingMean(col, window, name) -> nil`: Adds a rolling mean column in place.
- `LDataFrame:withRollingMin(col, window, name) -> nil`: Adds a rolling minimum column in place.
- `LDataFrame:withRollingSum(col, window, name) -> nil`: Adds a rolling sum column in place. This method is available to Lua scripts.
- `LDataFrame:zscoreCol(col, name) -> nil`: Adds a z-score normalized column in place.

#### LDataFrameTask Type

- Lua-side handle for a threaded dataframe job.

##### Fields

- No documented fields.

##### Methods

- `LDataFrameTask:getError() -> string`: Returns the task error message after failure.
- `LDataFrameTask:isDone() -> boolean`: Returns whether this dataframe task has completed with success or failure.
- `LDataFrameTask:progress() -> number`: Returns a coarse task progress estimate.
- `LDataFrameTask:result() -> LDataFrame`: Returns the completed dataframe result.
- `LDataFrameTask:type() -> string`: Returns the Lua-visible type name for this dataframe task handle.
- `LDataFrameTask:typeOf(name) -> boolean`: Returns whether this dataframe task handle matches a supported type name.
- `LDataFrameTask:wait() -> boolean`: Blocks until this dataframe task completes.

#### LDatabase Type

- Lua-side in-memory database containing named dataframes.

##### Fields

- No documented fields.

##### Methods

- `LDatabase:addTable(name, df_ud) -> nil`: Adds or replaces a named dataframe table in the database.
- `LDatabase:clear() -> nil`: Removes every table from the database.
- `LDatabase:getTable(name) -> LDataFrame`: Returns a copy of a named table when it exists.
- `LDatabase:hasTable(name) -> boolean`: Returns whether a named table exists.
- `LDatabase:listTables() -> string[]`: Returns all table names in the database.
- `LDatabase:merge(other) -> nil`: Merges another database into this database.
- `LDatabase:query(sql_str) -> LDataFrame`: Runs a SQL-style query against the database tables.
- `LDatabase:queryAsync(sql_str) -> LDataFrameTask`: Runs a SQL-style query against a snapshot of the database tables on a Rust worker thread.
- `LDatabase:queryParams(sql_str, params) -> LDataFrame`: Runs a SQL-style query against the database tables with positional parameters.
- `LDatabase:queryParamsAsync(sql_str, params) -> LDataFrameTask`: Runs a parameterized SQL query against a snapshot of the database tables on a Rust worker thread.
- `LDatabase:removeTable(name) -> nil`: Removes a named table from the database.
- `LDatabase:save(path, opts?) -> boolean`: Serializes the database to the JSON database file format and writes it through GameFS.
- `LDatabase:tableCount() -> integer`: Returns the number of tables in the database.
- `LDatabase:toJSON() -> string`: Serializes the database to JSON text.
- `LDatabase:type() -> string`: Returns the Lua-visible type name for this database handle.
- `LDatabase:typeOf(name) -> boolean`: Returns whether this database handle matches a supported type name.

#### LGroupedFrame Type

- Lua-side grouped dataframe object containing group keys and subframes.

##### Fields

- No documented fields.

##### Methods

- `LGroupedFrame:aggregate(col_name, func) -> LDataFrame`: Aggregates one numeric column in every group by calling a Lua function with that group's numeric values.
- `LGroupedFrame:type() -> string`: Returns the Lua-visible type name for this grouped frame handle.
- `LGroupedFrame:typeOf(name) -> boolean`: Returns whether this grouped frame handle matches a supported type name.

#### LLazyQuery Type

- Lua-side lazy dataframe query pipeline.

##### Fields

- No documented fields.

##### Methods

- `LLazyQuery:collect() -> LDataFrame`: Executes the lazy query and returns a dataframe.
- `LLazyQuery:dropNil(col) -> LLazyQuery`: Adds a step that drops rows with nil values in a column.
- `LLazyQuery:filter(col, op, val) -> LLazyQuery`: Adds a filter step to the lazy query.
- `LLazyQuery:head(n) -> LLazyQuery`: Adds a head limit step to the lazy query.
- `LLazyQuery:limit(n) -> LLazyQuery`: Adds a row limit step to the lazy query.
- `LLazyQuery:select(cols) -> LLazyQuery`: Adds a column selection step to the lazy query.
- `LLazyQuery:slice(start, end) -> LLazyQuery`: Adds a one-based row slice step to the lazy query.
- `LLazyQuery:sort(col, ascending?) -> LLazyQuery`: Adds a sort step to the lazy query. This method is available to Lua scripts.
- `LLazyQuery:tail(n) -> LLazyQuery`: Adds a tail limit step to the lazy query.
- `LLazyQuery:type() -> string`: Returns the Lua-visible type name for this lazy query handle.
- `LLazyQuery:typeOf(name) -> boolean`: Returns whether this lazy query handle matches a supported type name.

#### LVecFrame Type

- Lua-side vectorized dataframe handle for numeric column operations.

##### Fields

- No documented fields.

##### Methods

- `LVecFrame:applyMask(mask_tbl) -> LVecFrame`: Returns a vectorized frame filtered by a boolean mask table.
- `LVecFrame:colAbs(col) -> nil`: Applies absolute value to a numeric column in place.
- `LVecFrame:colAdd(col, val) -> nil`: Adds a scalar to a numeric column in place.
- `LVecFrame:colCast(col, dtype) -> nil`: Casts a vectorized column to another data type in place.
- `LVecFrame:colCeil(col) -> nil`: Applies ceil to a numeric column in place.
- `LVecFrame:colClamp(col, min_val, max_val) -> nil`: Clamps a numeric column in place. This method is available to Lua scripts.
- `LVecFrame:colDiv(col, val) -> nil`: Divides a numeric column by a scalar in place.
- `LVecFrame:colFloor(col) -> nil`: Applies floor to a numeric column in place.
- `LVecFrame:colMul(col, val) -> nil`: Multiplies a numeric column by a scalar in place.
- `LVecFrame:colNeg(col) -> nil`: Negates a numeric column in place. This method is available to Lua scripts.
- `LVecFrame:colOp(out_col, left_col, op, right_col) -> nil`: Applies a binary column operation into an output column.
- `LVecFrame:colSqrt(col) -> nil`: Applies square root to a numeric column in place.
- `LVecFrame:colSub(col, val) -> nil`: Subtracts a scalar from a numeric column in place.
- `LVecFrame:colType(col) -> string`: Returns the data type name for a vectorized column.
- `LVecFrame:columns() -> string[]`: Returns all vectorized column names in order.
- `LVecFrame:filterMask(col, cmp_op, val) -> number[]`: Builds a boolean mask for a numeric column comparison.
- `LVecFrame:ncols() -> integer`: Returns the number of columns in this vectorized frame.
- `LVecFrame:nrows() -> integer`: Returns the number of rows in this vectorized frame.
- `LVecFrame:parReduce(cols_tbl, op) -> table`: Reduces multiple numeric columns in parallel.
- `LVecFrame:parScalarOp(cols_tbl, op, val) -> nil`: Applies a scalar operation to multiple numeric columns in parallel.
- `LVecFrame:reduce(col, op) -> number`: Reduces a numeric column with a named operation.
- `LVecFrame:toDataFrame() -> LDataFrame`: Converts this vectorized frame to a dataframe.
- `LVecFrame:type() -> string`: Returns the Lua-visible type name for this vectorized frame handle.
- `LVecFrame:typeOf(name) -> boolean`: Returns whether this vectorized frame handle matches a supported type name.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- No additional module-specific notes.
