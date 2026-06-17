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
- Lua test path(s): tests/lua/unit/test_dataframe.lua; tests/lua/stress/test_dataframe_stress.lua; tests/lua/integration/test_compute_dataframe.lua; tests/lua/golden/test_dataframe_golden.lua

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

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### file_io.rs

- Implements storage-agnostic persistence helpers for DataFrame and Database payload workflows. `dataframe/file_io` delivers the file io implementation for the dataframe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Defines narrow read and write abstraction traits decoupled from concrete filesystem backends. The file owns or coordinates data contracts including `DataFrameFileStore`, `DataFrameFileError`, `DataFrameFileResult`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Bridges CSV, JSON, and binary serializers with caller-provided storage transport operations. Public callable behavior is centered on `read_csv_dataframe`, `read_json_dataframe`, `write_csv_dataframe`, `write_json_dataframe`, `write_binary_dataframe`, and 2 more, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Preserves distinct error domains for storage, parsing, and format conversion failure handling. Runtime integration reaches sibling engine areas through crate modules `dataframe`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### frame.rs

- Implements the core DataFrame and Database runtime models with typed cell-value representation. `dataframe/frame` delivers the frame implementation for the dataframe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Stores table data in named column structures with stable row-wise access semantics. The file owns or coordinates data contracts including `CellValue`, `ColRef`, `ColumnSchema`, `DataFrame`, `DataFrameRowIter`, and 2 more, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supports column resolution by name or index for flexible scripting and API integration paths. Public callable behavior is centered on no named public items, while method-level behavior such as `is_nil`, `as_number`, `as_text`, `as_bool`, `cmp_for_sort`, `new`, and 39 more stays attached to the local data model and invariants.
- Provides row and column lifecycle operations including add, remove, rename, and mutation workflows. Runtime integration reaches sibling engine areas through crate modules `dataframe`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Exposes slicing, cloning, iteration, and structural transformation helpers for table processing. External integration uses `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Maintains multi-table database containers that group frames under stable logical identifiers. The file boundary separates dataframe implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.
- Includes random-data generation and expression-evaluation helpers for synthetic and derived columns. State changes, validation paths, and helper routines in `src/dataframe/frame.rs` should be reviewed together because they collectively define the safe operational surface for this feature.
- Supports pivot-style reshaping with configurable aggregation behavior across grouping dimensions. Agents reading this file should use the module docs to understand provided functionality first, then inspect item docs and tests only where the behavior is being changed.

### lazy.rs

- Implements deferred dataframe query planning through composable step-chain descriptions. `dataframe/lazy` delivers the lazy implementation for the dataframe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Stores filter, sort, select, window, and limit operations without immediate execution. The file owns or coordinates data contracts including `LazyQuery`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Materializes lazy plans on collect by applying steps over cloned source-frame state. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `tombstone`, `filter`, `sort`, `select`, `head`, and 6 more stays attached to the local data model and invariants.
- Preserves deterministic step order and transformation semantics during pipeline realization. Runtime integration reaches sibling engine areas through crate modules `dataframe`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### mod.rs

- Defines the dataframe module boundary for typed tabular storage, query execution, and serialization flows. `dataframe/mod` is the dataframe module index, declaring `file_io`, `frame`, `lazy`, `query`, `rng`, and 4 more so agents can identify which files own each feature slice before opening implementation code.
- Groups core frame models, lazy operations, SQL parsing, threaded tasks, and vectorized processing layers. `src/dataframe/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `frame::{CellValue, ColRef, ColumnSchema, DataFrame, DataFrameRowIter, Database}`, `lazy::LazyQuery`, `task::DataFrameTask`, `vectorized::{BinaryOp, CmpOp, ColumnStore, ReduceOp, ScalarOp, VecFrame}` centralized for the dataframe subsystem.

### query/analytics.rs

- Implements statistical analytics helpers over dataframe columns and derived numeric distributions. `dataframe/query/analytics` delivers the analytics implementation for the dataframe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Provides percentile extraction through interpolation on ordered numeric sample sequences. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supports z-score and min-max normalization for consistent feature scaling workflows. Public callable behavior is centered on `percentile`, while method-level behavior such as `zscore_col`, `normalize_col`, `outliers`, `mode_val`, `entropy` stays attached to the local data model and invariants.
- Includes outlier detection, mode estimation, and entropy-style spread characterization helpers. Runtime integration reaches sibling engine areas through crate modules `dataframe`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### query/filter.rs

- Implements primary row and column query transforms for dataframe selection and restructuring. `dataframe/query/filter` delivers the filter implementation for the dataframe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Applies predicate-based filtering with comparison and text containment operator semantics. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Provides ordering, slicing, projection, and uniqueness extraction over tabular datasets. Public callable behavior is centered on no named public items, while method-level behavior such as `filter`, `par_filter`, `sort`, `head`, `tail`, `slice`, and 22 more stays attached to the local data model and invariants.
- Supports grouping and join composition for cross-frame and keyed relational-style operations. Runtime integration reaches sibling engine areas through crate modules `dataframe`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Includes deterministic sampling, nil handling, and batch append utilities for data preparation. External integration uses no named public items, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Computes common aggregate statistics and descriptive summary frames across numeric columns. The file boundary separates dataframe implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

### query/grouping.rs

- Implements grouping-oriented dataframe operations for keyed aggregation and cross-tab reshaping. `dataframe/query/grouping` delivers the grouping implementation for the dataframe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Aggregates grouped values with selectable reducers such as mean, sum, min, max, and count. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Builds pivoted result frames from row, column, and value key combinations. Public callable behavior is centered on no named public items, while method-level behavior such as `group_agg`, `par_group_agg`, `pivot`, `corr`, `correlation_matrix` stays attached to the local data model and invariants.
- Computes pairwise Pearson correlation between selected numeric columns. Runtime integration reaches sibling engine areas through crate modules `dataframe`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Generates full numeric correlation matrices for multivariate relationship inspection. External integration uses no named public items, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### query/mod.rs

- Defines the dataframe query module boundary for filtering, grouping, processing, analytics, and window logic. `dataframe/query/mod` is the dataframe module index, declaring `analytics`, `filter`, `grouping`, `processing`, `window` so agents can identify which files own each feature slice before opening implementation code.
- Groups query submodules under one cohesive extension surface over core frame structures. `src/dataframe/query/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `analytics::percentile` centralized for the dataframe subsystem.

### query/processing.rs

- Implements dataframe processing helpers for frequency summaries and table-quality diagnostics. `dataframe/query/processing` delivers the processing implementation for the dataframe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Builds value-count tables with optional percentage columns for distribution inspection. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Produces missing-value reports and duplicate-row extraction over full-row or keyed comparisons. Public callable behavior is centered on no named public items, while method-level behavior such as `value_counts`, `missing_report`, `duplicate_rows`, `date_parts` stays attached to the local data model and invariants.
- Appends parsed ISO date parts into structured year, month, and day output columns. Runtime integration reaches sibling engine areas through crate modules `dataframe`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### query/window.rs

- Implements window-style dataframe computations over ordered row sequences and bounded spans. `dataframe/query/window` delivers the window implementation for the dataframe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Provides rolling mean, sum, min, and max evaluation with configurable window lengths. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Computes dense-style ranking with stable tie handling across repeated numeric values. Public callable behavior is centered on no named public items, while method-level behavior such as `with_rolling_mean`, `with_rolling_sum`, `with_rolling_min`, `with_rolling_max`, `with_rank`, `with_pct_change`, and 1 more stays attached to the local data model and invariants.
- Supports row-over-row percent-change derivation for trend and momentum analysis. Runtime integration reaches sibling engine areas through crate modules `dataframe`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Builds cumulative running totals across ordered rows for progressive metric inspection. External integration uses no named public items, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### rng.rs

- Implements lightweight xorshift64 random generation used by dataframe-local sampling utilities. `dataframe/rng` delivers the rng implementation for the dataframe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Produces deterministic integer, float, and index outputs from a compact 64-bit state. The file owns or coordinates data contracts including `Xorshift64`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Remaps zero seed values to prevent degenerate all-zero generator behavior. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `next_u64`, `next_f64`, `next_usize` stays attached to the local data model and invariants.

### serial.rs

- Implements serialization and parsing for dataframe and database payloads across multiple formats. `dataframe/serial` delivers the serial implementation for the dataframe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Supports CSV decode and encode with quoting, escaping, and type-inference behavior. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Provides JSON array-object conversion between textual payloads and dataframe structures. Public callable behavior is centered on `from_csv`, `from_json`, `from_binary`, `database_from_json`, while method-level behavior such as `to_csv`, `to_json`, `to_binary`, `to_string_table` stays attached to the local data model and invariants.
- Handles nested JSON values and arrays during parser traversal and value coercion. Runtime integration reaches sibling engine areas through crate modules `dataframe`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Encodes and decodes compact LVDF binary format for efficient dataframe transport storage. External integration uses no named public items, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Supplies text-table rendering helpers for debugging and readable frame inspection outputs. The file boundary separates dataframe implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

### sql.rs

- Implements SQL-like query execution over dataframe and database table structures. `dataframe/sql` delivers the sql implementation for the dataframe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Tokenizes input query text into typed lexical units for downstream parser consumption. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Parses SELECT statements through recursive-descent grammar with explicit clause ordering. Public callable behavior is centered on `query_sql`, `explain_sql`, `query_sql_database`, `query_sql_database_params`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Builds expression trees for WHERE and HAVING filters including boolean and pattern operators. Runtime integration reaches sibling engine areas through crate modules `dataframe`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Supports projection arithmetic with aliasing and function-call style aggregate expressions. External integration uses no named public items, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Executes grouping, aggregation, ordering, limits, and offsets over intermediate query results. The file boundary separates dataframe implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.
- Parses and applies join clauses for multi-table query paths within database containers. State changes, validation paths, and helper routines in `src/dataframe/sql.rs` should be reviewed together because they collectively define the safe operational surface for this feature.
- Implements LIKE-style wildcard matching semantics compatible with SQL-style pattern tokens. Agents reading this file should use the module docs to understand provided functionality first, then inspect item docs and tests only where the behavior is being changed.

### task.rs

- Implements one-shot threaded dataframe jobs for file loading and SQL query execution. `dataframe/task` delivers the task implementation for the dataframe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Captures worker-side data snapshots to avoid large payload transfer through script boundaries. The file owns or coordinates data contracts including `DataFrameTask`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Provides poll, wait, progress, result, and error lifecycle helpers for async task management. Public callable behavior is centered on no named public items, while method-level behavior such as `spawn_csv_file`, `spawn_json_file`, `spawn_dataframe_query`, `spawn_database_query`, `spawn_database_query_params`, `is_done`, and 4 more stays attached to the local data model and invariants.
- Executes dataframe and database operations on worker threads with bounded state handoff. Runtime integration reaches sibling engine areas through crate modules `dataframe`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Serves as the asynchronous execution layer used by Lua-facing dataframe task APIs. External integration uses `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### vectorized.rs

- Implements typed vectorized column storage for high-throughput dataframe-style numeric processing. `dataframe/vectorized` delivers the vectorized implementation for the dataframe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Supports float, integer, boolean, and text columns with optional validity-mask semantics. The file owns or coordinates data contracts including `ColumnStore`, `ScalarOp`, `BinaryOp`, `ReduceOp`, `CmpOp`, and 1 more, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Provides scalar element-wise transforms across arithmetic and unary operation families. Public callable behavior is centered on no named public items, while method-level behavior such as `dtype_name`, `len`, `is_empty`, `is_valid`, `valid_f64s`, `filter`, and 18 more stays attached to the local data model and invariants.
- Executes binary column operations with dtype-aware coercion and compatibility checks. Runtime integration reaches sibling engine areas through crate modules `dataframe`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Computes reductions including sum, mean, min, max, variance, and related aggregate metrics. External integration uses `rayon`, `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Generates comparison masks for predicate-style filtering over typed column values. The file boundary separates dataframe implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.
- Supports bidirectional conversion between vectorized frames and generic dataframe representations. State changes, validation paths, and helper routines in `src/dataframe/vectorized.rs` should be reviewed together because they collectively define the safe operational surface for this feature.
- Applies parallelized multi-column operations and reductions via rayon-backed execution paths. Agents reading this file should use the module docs to understand provided functionality first, then inspect item docs and tests only where the behavior is being changed.



## Lua API Ref

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
