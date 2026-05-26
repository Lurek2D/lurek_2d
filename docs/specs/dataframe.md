# dataframe

## TL;DR

- The `dataframe` module provides a powerful in-memory, column-major tabular data engine that brings lightweight SQL-style querying and advanced data manipulation to Lurek2D.

## General Info

- Module group: `Foundations`
- Source path: `src/dataframe/`
- Lua API path(s): `src/lua_api/dataframe_api.rs`
- Primary Lua namespace: `lurek.dataframe`
- Rust test path(s): tests/rust/unit/dataframe_tests.rs
- Lua test path(s): tests/lua/unit/test_dataframe.lua; tests/lua/stress/test_dataframe_stress.lua; tests/lua/integration/test_compute_dataframe.lua; tests/lua/golden/test_dataframe_golden.lua

## Summary

 Positioned within the Foundations tier, it offers robust data analytics capabilities completely decoupled from engine-specific state. The core data structure is the `DataFrame`, which stores named columns containing `CellValue` variants (Nil, Bool, Int, Float, String). It provides a comprehensive set of operations including adding or removing columns and rows, cell access, sorting, and filtering via predicates. The module also supports advanced tabular functions like inner, left, right, and full joins, grouping, and aggregations (sum, mean, min, max, count).

For analytical workloads, the module includes an extensive suite of window functions (rank, row_number, lag, lead, running totals) and processing helpers such as value counts, missing value reports, duplicate row extraction, and ISO date part extraction. A lazy query builder (`LazyQuery`) is available to chain sequential query steps (filter, sort, select, slice) before materializing the final frame, improving efficiency for complex data pipelines. Additionally, for highly performant bulk numeric operations, a vectorized variant called `VecFrame` leverages parallel operations and typed storage.

A standout feature is the `Database` container, which holds multiple named `DataFrame` instances and acts as a localized query catalog. The module features a bespoke, built-in SQL engine complete with a tokenizer and recursive-descent parser. This engine natively executes SQL queries across the database, supporting full SELECT statements with WHERE clauses, GROUP BY, ORDER BY, LIMIT, subqueries, and table JOINs. It robustly handles explicit `AS` aliases, aggregate calls, and complex arithmetic expressions, including parameterized queries with positional `?` placeholders.

To facilitate seamless data interchange, the module implements native serialization and deserialization for CSV, JSON, and compact binary (LVDF) formats. Recognizing the performance impact of parsing large datasets, these operations—alongside SQL queries—can be executed asynchronously on Rust worker threads using `DataFrameTask`. These tasks operate on storage snapshots, ensuring that heavy I/O and SQL processing do not block the main Lua thread. The entire robust feature set is exposed to script authors through the `lurek.dataframe.*` API, enabling sophisticated data engineering and analytics within game scripts.

## Registration

The `dataframe` module is registered as **always-on** and requires no configuration gate.
As a Foundations tier library, it is available unconditionally in all VM contexts.
No `modules.dataframe` config field exists — this is intentional.

## Source Documentation

### `file_io.rs`
- Provides storage-agnostic DataFrame and Database file persistence helpers.
- Defines a narrow trait for reading and writing text, JSON, and binary payloads without importing GameFS.
- Combines existing CSV, JSON, LVDF, and database serializers with caller-provided storage operations.
- Keeps storage failures separate from parse and format failures so Lua bindings can preserve error surfaces.

### `frame.rs`
- Core dataframe cell type and typed value representation
- Columnar storage with named columns and row-major access
- Column resolution by name or one-based index
- Row and column CRUD operations including add, remove, and rename
- DataFrame cloning, slicing, and row iteration
- Database container for named table collections
- Random data generation from typed column definitions
- Arithmetic expression evaluation per row via `with_eval`
- Pivot table construction with configurable aggregation
- Rolling mean, rolling sum, and rank computations
- Aggregation function enumeration and parsing

### `lazy.rs`
- Deferred query step representation for filter, sort, select, head, tail, slice, and limit
- Lazy query builder that chains steps without executing until `collect`
- Materialization via sequential step application over a cloned source frame

### `mod.rs`
- Columnar DataFrame type and Database container
- Lazy query builder and deferred execution pipeline
- Query-time transforms: filtering, grouping, analytics, processing, and window functions
- CSV, JSON, and binary serialization and parsing
- Storage-agnostic file persistence helpers for dataframe and database payloads
- One-shot threaded dataframe tasks for file loading and SQL queries
- SQL-like SELECT executor with tokenizer and recursive-descent parser
- Typed vectorized column storage with parallel reduce and scalar operations

### `query/analytics.rs`
- Percentile computation by linear interpolation over sorted values
- Z-score standardization for numeric columns
- Min-max normalization to arbitrary output range
- Outlier detection via z-score threshold
- Mode value computation across non-nil cells
- Shannon entropy calculation over rendered cell distributions

### `query/filter.rs`
- Row filtering by column predicate with comparison and contains operators
- Column sorting in ascending or descending order
- Head, tail, and inclusive slice row selection
- Column projection and unique value extraction
- Group-by partitioning and inner/left join merging
- Frame merge, count-by, drop-nil, and deterministic sampling
- Aggregate statistics: sum, mean, min, max, median, stddev, variance
- Descriptive statistics frame generation
- Nil fill, batch row append, and column f64 import/export

### `query/grouping.rs`
- Grouped aggregation by key column with mean, sum, min, max, count, first, last
- Pivot transformation from row/column/value keys into cross-tabulated frame
- Pearson correlation between two numeric columns
- Full numeric-column correlation matrix generation

### `query/mod.rs`
- Statistical and distribution-oriented analytics helpers
- Row filtering, sorting, joins, and sampling operations
- Grouped aggregation, pivoting, and correlation computations
- Reusable processing helpers for counts, missingness, duplicates, and dates
- Rolling and ranking window functions

### `query/processing.rs`
- Frequency tables with optional percentage output
- Column-level missing-value reports
- Duplicate row extraction by full-row or selected-column keys
- ISO date part extraction into appended year, month, and day columns

### `query/window.rs`
- Rolling mean, sum, min, and max over configurable window size; mean and sum use O(N) sliding-window algorithms
- Rolling operations ignore nil cells; result is Nil when current window contains no numeric cells
- Dense rank computation with average-rank tie-breaking
- Row-to-row percent change calculation
- Cumulative sum across ordered rows

### `rng.rs`
- Xorshift64 pseudo-random number generator for deterministic dataframe sampling
- Float, integer, and index generation from 64-bit state
- Zero-seed remap to avoid degenerate all-zero output

### `serial.rs`
- CSV parsing with quote escaping and type auto-detection
- CSV serialization with field escaping rules
- JSON array-of-objects parsing into DataFrame
- JSON serialization with proper string escaping
- Compact binary LVDF format encoding and decoding
- Padded string-table rendering for debug and display
- Database-level JSON serialization across all tables
- Database-level JSON parsing from named table arrays
- Nested JSON value and array handling during parse

### `sql.rs`
- SQL text tokenizer producing typed token stream
- Recursive-descent parser for SELECT statements
- WHERE clause expression tree with AND, OR, NOT, LIKE, and IN
- Aggregate function support: COUNT, SUM, AVG, MIN, MAX
- SELECT arithmetic expressions with explicit `AS` aliases
- GROUP BY with HAVING filter and ORDER BY with LIMIT/OFFSET
- JOIN clause parsing and inner-join execution
- SQL LIKE pattern matching with `%` and `_` wildcards
- Single-frame and multi-table Database query entry points

### `task.rs`
- One-shot threaded dataframe jobs for file loading and SQL queries.
- Worker-owned storage snapshots so large CSV/JSON reads do not pass through Lua strings.
- Poll, wait, result, error, and progress lifecycle helpers shared by Lua bindings.
- Snapshot-based DataFrame and Database query execution on Rust worker threads.

### `vectorized.rs`
- Typed columnar storage (Float64, Int64, Bool, Text) with optional validity masks
- Element-wise scalar operations: add, sub, mul, div, abs, sqrt, floor, ceil, neg
- Element-wise binary operations between two numeric columns
- Column reduction: sum, mean, min, max, std, var, count
- Comparison mask generation for filter predicates
- VecFrame ↔ DataFrame bidirectional conversion with type inference
- Parallel multi-column reduce and scalar operations via rayon
- Column type casting between float64, int64, and text
- Boolean mask filtering across all column types

## Types

- `DataFrameFileStore` (`trait`, `file_io.rs`): Minimal storage contract required by dataframe file persistence helpers.
- `DataFrameFileError` (`enum`, `file_io.rs`): Persistence error category that keeps storage failures distinct from payload format failures.
- `DataFrameFileResult` (`type`, `file_io.rs`): Result type used by dataframe file persistence helpers.
- `CellValue` (`enum`, `frame.rs`): Per-cell tagged value used throughout the module. It keeps nil, number, text, and boolean data explicit without forcing every column to share one type.
- `ColRef` (`enum`, `frame.rs`): Column selector that can resolve either a name or a 1-based index. It gives the Lua bridge and Rust helpers one shared way to address columns.
- `DataFrame` (`struct`, `frame.rs`): Core column-major table type with named columns and query methods. Most module behavior is expressed as methods on this type.
- `DataFrameRowIter` (`struct`, `frame.rs`): Iterate rows as vectors of column-name and cell references.
- `Database` (`struct`, `frame.rs`): Named collection of DataFrames used for multi-table workflows and SQL joins. It is deliberately small and acts as a query catalog rather than a storage engine.
- `AggFn` (`enum`, `frame.rs`): Aggregation function variants for group-by and pivot operations.
- `LazyQuery` (`struct`, `lazy.rs`): Hold deferred query source frame and queued steps.
- `Xorshift64` (`struct`, `rng.rs`): Hold xorshift64 state used by dataframe-local random helpers.
- `DataFrameTask` (`struct`, `task.rs`): Owns one background dataframe job and its eventual result.
- `ColumnStore` (`enum`, `vectorized.rs`): Typed flat-buffer column with an optional null/validity bitmap.
- `ScalarOp` (`enum`, `vectorized.rs`): Scalar arithmetic operation applied element-wise to an entire column.
- `BinaryOp` (`enum`, `vectorized.rs`): Element-wise binary operation between two Float64 columns.
- `ReduceOp` (`enum`, `vectorized.rs`): Column-level reduction operations.
- `CmpOp` (`enum`, `vectorized.rs`): Comparison operator used in `VecFrame::filter_mask`.
- `VecFrame` (`struct`, `vectorized.rs`): Typed-column vectorized DataFrame.

## Functions

- `read_csv_dataframe` (`file_io.rs`): Read CSV text from storage, parse it, and return a dataframe.
- `read_json_dataframe` (`file_io.rs`): Read JSON text from storage, parse it, and return a dataframe.
- `read_binary_dataframe` (`file_io.rs`): Read LVDF bytes from storage, parse them, and return a dataframe.
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
- `from_csv` (`serial.rs`): Parse a CSV string into a DataFrame.
- `DataFrame::to_csv` (`serial.rs`): Serialize DataFrame to CSV string.
- `from_json` (`serial.rs`): Parse JSON (array-of-objects) into a DataFrame.
- `DataFrame::to_json` (`serial.rs`): Serialize DataFrame to JSON table string.
- `DataFrame::to_binary` (`serial.rs`): Serialize DataFrame to compact binary format bytes.
- `from_binary` (`serial.rs`): Deserialize a DataFrame from LVDF binary format.
- `DataFrame::to_string_table` (`serial.rs`): Render DataFrame as padded string table.
- `database_from_json` (`serial.rs`): Parse a JSON database object whose table names map to DataFrame JSON arrays.
- `Database::to_json` (`serial.rs`): Serialize Database tables to JSON string.
- `query_sql` (`sql.rs`): Execute a SQL query on a single DataFrame.
- `query_sql_database` (`sql.rs`): Execute a SQL query on a Database (supports FROM and JOIN).
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

## Lua API Reference

- Binding path(s): `src/lua_api/dataframe_api.rs`
- Namespace: `lurek.dataframe`

### Module Functions
- `lurek.dataframe.newDataFrame`: Creates an empty dataframe. This function is exposed to Lua scripts.
- `lurek.dataframe.newDatabase`: Creates an empty dataframe database.
- `lurek.dataframe.fromTable`: Creates a dataframe from an array table of row tables.
- `lurek.dataframe.fromRows`: Creates a dataframe from column names and array-style rows.
- `lurek.dataframe.fromCSV`: Parses a dataframe from CSV text. This function is exposed to Lua scripts.
- `lurek.dataframe.fromCSVFile`: Reads CSV text from GameFS and parses it into a dataframe.
- `lurek.dataframe.fromCSVFileAsync`: Starts a Rust worker task that reads CSV text from GameFS and parses it into a dataframe.
- `lurek.dataframe.fromJSON`: Parses a dataframe from JSON text. This function is exposed to Lua scripts.
- `lurek.dataframe.fromJSONFile`: Reads JSON text from GameFS and parses it into a dataframe.
- `lurek.dataframe.fromJSONFileAsync`: Starts a Rust worker task that reads JSON text from GameFS and parses it into a dataframe.
- `lurek.dataframe.fromBinary`: Parses a dataframe from binary data.
- `lurek.dataframe.loadDatabase`: Reads a JSON database file from GameFS and parses it into a database.
- `lurek.dataframe.random`: Creates a random dataframe from column definitions.
- `lurek.dataframe.toVec`: Converts a dataframe to a vectorized frame.
- `lurek.dataframe.fromVec`: Converts a vectorized frame to a dataframe.

### `LDataFrame` Methods
- `LDataFrame:nrows`: Returns the number of rows in this dataframe.
- `LDataFrame:ncols`: Returns the number of columns in this dataframe.
- `LDataFrame:columns`: Returns all column names in order. This method is available to Lua scripts.
- `LDataFrame:count`: Returns the row count for this dataframe.
- `LDataFrame:addColumn`: Adds a column with an optional default value.
- `LDataFrame:removeColumn`: Removes a column by name or one-based index.
- `LDataFrame:rename`: Renames a column by name or one-based index.
- `LDataFrame:getColumn`: Returns a column as an array table. This method is available to Lua scripts.
- `LDataFrame:addRow`: Adds a row from an optional map table and returns its one-based row index.
- `LDataFrame:removeRow`: Removes a row by one-based index. This method is available to Lua scripts.
- `LDataFrame:getRow`: Returns a row as a table keyed by column name.
- `LDataFrame:getValue`: Returns one cell value by one-based row and column reference.
- `LDataFrame:setValue`: Sets one cell value by one-based row and column reference.
- `LDataFrame:filter`: Returns rows whose column value matches a comparison.
- `LDataFrame:sort`: Returns rows sorted by a column. This method is available to Lua scripts.
- `LDataFrame:head`: Returns the first rows of this dataframe.
- `LDataFrame:tail`: Returns the last rows of this dataframe.
- `LDataFrame:slice`: Returns a one-based inclusive row slice.
- `LDataFrame:select`: Returns a dataframe with selected columns.
- `LDataFrame:unique`: Returns unique values from a column.
- `LDataFrame:groupBy`: Groups rows by a column and returns a table from group key to dataframe.
- `LDataFrame:groupByObj`: Groups rows by a column and returns a grouped-frame object.
- `LDataFrame:join`: Joins this dataframe with another dataframe by column references.
- `LDataFrame:merge`: Appends another dataframe into this dataframe in place.
- `LDataFrame:countBy`: Counts occurrences of each value in a column.
- `LDataFrame:valueCounts`: Counts occurrences of each value in a column with optional percentage output.
- `LDataFrame:missingReport`: Reports missing and non-missing cell counts for every column.
- `LDataFrame:duplicateRows`: Returns rows whose full-row key or selected-column key appears more than once.
- `LDataFrame:dateParts`: Returns a new dataframe with year, month, and day columns extracted from ISO `yyyy-mm-dd` text.
- `LDataFrame:dropNil`: Returns rows where the chosen column is not nil.
- `LDataFrame:sample`: Returns a sampled dataframe. This method is available to Lua scripts.
- `LDataFrame:describe`: Returns summary statistics for numeric columns.
- `LDataFrame:sum`: Returns the numeric sum of a column.
- `LDataFrame:mean`: Returns the numeric mean of a column.
- `LDataFrame:min`: Returns the minimum value of a column.
- `LDataFrame:max`: Returns the maximum value of a column.
- `LDataFrame:median`: Returns the numeric median of a column.
- `LDataFrame:stddev`: Returns the numeric standard deviation of a column.
- `LDataFrame:variance`: Returns the numeric variance of a column.
- `LDataFrame:fillNil`: Replaces nil cells in a column with a value.
- `LDataFrame:apply`: Applies a Lua function to each value in a column in place.
- `LDataFrame:toCSV`: Serializes this dataframe to CSV text.
- `LDataFrame:toJSON`: Serializes this dataframe to JSON text.
- `LDataFrame:toBinary`: Serializes this dataframe to binary data.
- `LDataFrame:toCSVFile`: Serializes this dataframe to CSV text and writes it through GameFS.
- `LDataFrame:toJSONFile`: Serializes this dataframe to JSON text and writes it through GameFS.
- `LDataFrame:toBinaryFile`: Serializes this dataframe to LVDF binary data and writes it through GameFS.
- `LDataFrame:toTable`: Converts this dataframe to an array table of row tables.
- `LDataFrame:rows`: Returns an iterator function over one-based row index and row table pairs.
- `LDataFrame:toString`: Formats this dataframe as a human-readable text table.
- `LDataFrame:query`: Runs a SQL-style query against this dataframe.
- `LDataFrame:queryAsync`: Runs a SQL-style query against this dataframe on a Rust worker thread.
- `LDataFrame:clone`: Returns a deep copy of this dataframe.
- `LDataFrame:withRollingMean`: Adds a rolling mean column in place.
- `LDataFrame:withRollingSum`: Adds a rolling sum column in place. This method is available to Lua scripts.
- `LDataFrame:withRollingMin`: Adds a rolling minimum column in place.
- `LDataFrame:withRollingMax`: Adds a rolling maximum column in place.
- `LDataFrame:withRank`: Adds a rank column in place. This method is available to Lua scripts.
- `LDataFrame:withPctChange`: Adds a percent-change column in place.
- `LDataFrame:withCumsum`: Adds a cumulative-sum column in place.
- `LDataFrame:groupAgg`: Groups by one column and aggregates another column.
- `LDataFrame:pivot`: Pivots rows into columns using row, column, and value fields.
- `LDataFrame:corr`: Returns correlation between two numeric columns.
- `LDataFrame:correlationMatrix`: Returns a correlation matrix for numeric columns.
- `LDataFrame:zscoreCol`: Adds a z-score normalized column in place.
- `LDataFrame:normalizeCol`: Adds a range-normalized column in place.
- `LDataFrame:outliers`: Returns rows considered outliers for a numeric column.
- `LDataFrame:modeVal`: Returns the mode value of a column. This method is available to Lua scripts.
- `LDataFrame:entropy`: Returns entropy for a column. This method is available to Lua scripts.
- `LDataFrame:addRowBatch`: Appends multiple rows from array-style row tables.
- `LDataFrame:getColumnAsF64`: Returns a numeric column as an array of numbers.
- `LDataFrame:setColumnFromF64`: Replaces a numeric column from an array table of numbers.
- `LDataFrame:type`: Returns the Lua-visible type name for this dataframe handle.
- `LDataFrame:typeOf`: Returns whether this dataframe handle matches a supported type name.
- `LDataFrame:withEval`: Returns a dataframe with a column computed from an expression.
- `LDataFrame:pivotTable`: Builds a pivot table using row key, column key, value column, and aggregate function.
- `LDataFrame:rollingMean`: Returns a dataframe with a rolling mean column.
- `LDataFrame:rollingSum`: Returns a dataframe with a rolling sum column.
- `LDataFrame:rank`: Returns a dataframe with a rank column.
- `LDataFrame:lazy`: Starts a lazy query pipeline from this dataframe.

### `LDataFrameTask` Methods
- `LDataFrameTask:isDone`: Returns whether this dataframe task has completed with success or failure.
- `LDataFrameTask:wait`: Blocks until this dataframe task completes.
- `LDataFrameTask:result`: Returns the completed dataframe result.
- `LDataFrameTask:getError`: Returns the task error message after failure.
- `LDataFrameTask:progress`: Returns a coarse task progress estimate.
- `LDataFrameTask:type`: Returns the Lua-visible type name for this dataframe task handle.
- `LDataFrameTask:typeOf`: Returns whether this dataframe task handle matches a supported type name.

### `LDatabase` Methods
- `LDatabase:addTable`: Adds or replaces a named dataframe table in the database.
- `LDatabase:getTable`: Returns a copy of a named table when it exists.
- `LDatabase:removeTable`: Removes a named table from the database.
- `LDatabase:hasTable`: Returns whether a named table exists.
- `LDatabase:listTables`: Returns all table names in the database.
- `LDatabase:tableCount`: Returns the number of tables in the database.
- `LDatabase:clear`: Removes every table from the database.
- `LDatabase:merge`: Merges another database into this database.
- `LDatabase:toJSON`: Serializes the database to JSON text.
- `LDatabase:save`: Serializes the database to the JSON database file format and writes it through GameFS.
- `LDatabase:query`: Runs a SQL-style query against the database tables.
- `LDatabase:queryAsync`: Runs a SQL-style query against a snapshot of the database tables on a Rust worker thread.
- `LDatabase:queryParams`: Runs a SQL-style query against the database tables with positional parameters.
- `LDatabase:queryParamsAsync`: Runs a parameterized SQL query against a snapshot of the database tables on a Rust worker thread.
- `LDatabase:type`: Returns the Lua-visible type name for this database handle.
- `LDatabase:typeOf`: Returns whether this database handle matches a supported type name.

### `LGroupedFrame` Methods
- `LGroupedFrame:aggregate`: Aggregates one numeric column in every group by calling a Lua function with that group's numeric values.
- `LGroupedFrame:type`: Returns the Lua-visible type name for this grouped frame handle.
- `LGroupedFrame:typeOf`: Returns whether this grouped frame handle matches a supported type name.

### `LLazyQuery` Methods
- `LLazyQuery:filter`: Adds a filter step to the lazy query.
- `LLazyQuery:sort`: Adds a sort step to the lazy query. This method is available to Lua scripts.
- `LLazyQuery:head`: Adds a head limit step to the lazy query.
- `LLazyQuery:tail`: Adds a tail limit step to the lazy query.
- `LLazyQuery:limit`: Adds a row limit step to the lazy query.
- `LLazyQuery:slice`: Adds a one-based row slice step to the lazy query.
- `LLazyQuery:dropNil`: Adds a step that drops rows with nil values in a column.
- `LLazyQuery:select`: Adds a column selection step to the lazy query.
- `LLazyQuery:collect`: Executes the lazy query and returns a dataframe.
- `LLazyQuery:type`: Returns the Lua-visible type name for this lazy query handle.
- `LLazyQuery:typeOf`: Returns whether this lazy query handle matches a supported type name.

### `LVecFrame` Methods
- `LVecFrame:colAdd`: Adds a scalar to a numeric column in place.
- `LVecFrame:colSub`: Subtracts a scalar from a numeric column in place.
- `LVecFrame:colMul`: Multiplies a numeric column by a scalar in place.
- `LVecFrame:colDiv`: Divides a numeric column by a scalar in place.
- `LVecFrame:colAbs`: Applies absolute value to a numeric column in place.
- `LVecFrame:colSqrt`: Applies square root to a numeric column in place.
- `LVecFrame:colFloor`: Applies floor to a numeric column in place.
- `LVecFrame:colCeil`: Applies ceil to a numeric column in place.
- `LVecFrame:colNeg`: Negates a numeric column in place. This method is available to Lua scripts.
- `LVecFrame:colClamp`: Clamps a numeric column in place. This method is available to Lua scripts.
- `LVecFrame:colOp`: Applies a binary column operation into an output column.
- `LVecFrame:reduce`: Reduces a numeric column with a named operation.
- `LVecFrame:filterMask`: Builds a boolean mask for a numeric column comparison.
- `LVecFrame:applyMask`: Returns a vectorized frame filtered by a boolean mask table.
- `LVecFrame:colType`: Returns the data type name for a vectorized column.
- `LVecFrame:colCast`: Casts a vectorized column to another data type in place.
- `LVecFrame:nrows`: Returns the number of rows in this vectorized frame.
- `LVecFrame:ncols`: Returns the number of columns in this vectorized frame.
- `LVecFrame:columns`: Returns all vectorized column names in order.
- `LVecFrame:parReduce`: Reduces multiple numeric columns in parallel.
- `LVecFrame:parScalarOp`: Applies a scalar operation to multiple numeric columns in parallel.
- `LVecFrame:toDataFrame`: Converts this vectorized frame to a dataframe.
- `LVecFrame:type`: Returns the Lua-visible type name for this vectorized frame handle.
- `LVecFrame:typeOf`: Returns whether this vectorized frame handle matches a supported type name.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- Keep this module reference synchronized with `src/dataframe/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
- SQL SELECT arithmetic returns `nil` for non-numeric operands, non-finite results, and division by zero.
