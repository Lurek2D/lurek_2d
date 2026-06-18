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
- This makes `dataframe` a natural backbone for reporting-oriented tools and live dashboards where structured content and metrics need to be manipulated with more discipline than generic Lua tables provide.
- That shared table model keeps ingest, analysis, export, and visualization steps connected.
- Read `dataframe` as the engine feature that turns structured tables into a first-class runtime capability. Other systems provide the data or consume the results, but this module owns how tabular information is modeled, queried, transformed, analyzed, and persisted.


## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### file_io.rs

- This file owns storage-agnostic persistence adapters for reading and writing dataframe and database payloads.
- `DataFrameFileStore` defines the read and write contract, while `DataFrameFileError` preserves storage vs format errors.
- CSV, JSON, and LVDF helpers live here because they bridge caller transport with `serial.rs` parsing and encoding.
- Database JSON load and save also stay here so external persistence boundaries remain outside core table ownership.
- Open it when IO error mapping or storage contracts change; schema, SQL, and row operations live in siblings.

### frame.rs

- This file owns the tabular runtime core: `CellValue`, column selectors, schema metadata, `DataFrame`, and `Database`.
- It stores column-major cell buffers plus ordered names, then exposes row reads, writes, adds, deletes, and cloning.
- Column resolution by name or one-based index lives here because every dataframe extension depends on that contract.
- Schema inspection and textual `explain` output also stay here so table shape and diagnostics share one owner.
- Synthetic table generation is implemented here because typed sample cells and row assembly depend on core storage.
- `with_eval` and its token parser live here because derived-column arithmetic reads direct row data from the table core.
- Pivot-table assembly also belongs here because it rewrites row, column, and value keys into new frame structures.
- Rolling mean, rolling sum, and rank-returning variants live here as pure table transforms that produce new frames.
- `Database` ownership stays here because named table containers are the storage boundary used later by SQL execution.
- `AggFn` is defined here so grouping, pivoting, and SQL summaries share one aggregation vocabulary across siblings.
- Open it when table invariants change; serializers, query extras, lazy plans, and vectorized paths build on this file.

### lazy.rs

- This file owns deferred dataframe pipelines, storing query steps until a caller materializes them with `collect`.
- `LazyQuery` keeps a cloned source frame plus ordered filter, sort, select, slice, nil-drop, and limit operations.
- Execution stays here because lazy semantics are defined by step ordering, cloning rules, and collect-time dispatch.
- The file also adds `DataFrame::lazy()` so eager tables can hand off into deferred planning without Lua involvement.
- Open it when pipeline semantics change; concrete row transforms, SQL parsing, and async jobs live in siblings.

### mod.rs

- This module is the dataframe index, exposing frame storage, query helpers, serializers, SQL, tasks, and vectors.
- It reexports `DataFrame`, `Database`, `LazyQuery`, `DataFrameTask`, and vectorized enums as the public surface.
- `frame.rs` owns typed cells and table state, while `query/` extends that state with filtering and analytics flows.
- `serial.rs` and `file_io.rs` cover payload conversion and caller-supplied transport, not table mutation semantics.
- `sql.rs`, `lazy.rs`, and `task.rs` add planning and execution layers over the same tabular core contracts.
- Open this file to navigate module boundaries and exports; actual data behavior, parsing, and math live in siblings.

### query/analytics.rs

- This file owns statistical dataframe helpers for percentiles, scaling, outlier scans, mode lookup, and entropy.
- `percentile` is the standalone export, while `DataFrame` methods add z-score, min-max normalization, and outliers.
- These transforms stay here because they operate on numeric distributions rather than on structural table rewrites.
- Mode and entropy also belong here as descriptive analytics over column value frequencies and rendered cell labels.
- Open it when statistical helpers change; joins, grouping, rolling windows, and SQL parsing live in siblings.

### query/filter.rs

- This file owns primary row and column transforms such as filter, sort, slice, select, join, sample, and describe.
- Predicate filtering lives here, including comparison operators and text `contains`, plus rayon-backed row scanning.
- Grouping and joins also stay here because they reshape row sets before higher-level SQL or analytics layers run.
- Sampling, nil dropping, batch row append, and numeric column extraction belong here as practical table utilities.
- Descriptive stats and basic reducers live here because they summarize generic numeric columns without SQL grammar.
- `extract_rows` and `collect_numbers` are local shared seams because most query helpers need direct row reuse.
- The file is the main structural transform owner, not the payload codec or typed vectorized execution boundary.
- Open it when core query behavior changes; windows, grouped correlation, and SQL parsing live in sibling files.

### query/grouping.rs

- This file owns keyed aggregation and reshaping helpers such as `group_agg`, `par_group_agg`, `pivot`, and `corr`.
- It groups rows by one key, then applies shared `AggFn` reducers while preserving deterministic key output order.
- Parallel grouped aggregation lives here because partitioning and per-group reduction are grouping-layer semantics.
- Pivot construction also stays here because row and column key expansion is a reshape built on grouped identities.
- Pearson correlation and correlation matrices belong here as cross-column relationship summaries over numeric groups.
- This file extends query behavior after basic filtering, not storage ownership, payload parsing, or SQL tokenization.
- Open it when keyed summaries change; rolling windows, row filters, and dataframe core state live in siblings.

### query/mod.rs

- This module is the query index, grouping filter, processing, analytics, and window extensions over `DataFrame`.
- It exposes `analytics`, `filter`, `grouping`, `processing`, and `window` from one focused table-transform surface.
- `filter.rs` owns row selection and joins, `grouping.rs` owns keyed reshaping, and `window.rs` owns ordered spans.
- `processing.rs` covers diagnostics and date helpers, while `analytics.rs` adds scaling, mode, and entropy utilities.
- Only `percentile` is reexported here; all other behavior stays attached to `DataFrame` impl blocks in sibling files.
- Open this file to navigate query ownership quickly; storage, codecs, and SQL grammar live outside this submodule.

### query/processing.rs

- This file owns practical dataframe diagnostics such as value counts, missingness reports, duplicate rows, and dates.
- `value_counts` and `missing_report` summarize column quality, while `duplicate_rows` surfaces repeated row keys.
- `date_parts` also lives here because ISO date expansion is a cleanup step used before richer analytics and SQL.
- Private duplicate-key and row-key helpers stay local because they serve only this file's duplicate detection flow.
- Open it when data quality helpers change; grouping math, rolling windows, and storage contracts live in siblings.

### query/window.rs

- This file owns ordered window helpers that append rolling, ranking, percent-change, and cumulative output columns.
- Rolling mean, sum, min, and max stay here because bounded span semantics depend on row order and window width.
- `with_rank` also belongs here because tie handling and sort direction define ordered analytic behavior on a column.
- `with_pct_change` and `with_cumsum` are local because both derive each row from earlier rows in sequence order.
- These methods mutate the receiver by appending output columns, rather than returning detached summary frames.
- Open it when row-order analytics change; grouping, SQL execution, and serialization live in sibling owners.

### rng.rs

- This file owns the local xorshift64 generator used by dataframe sampling and synthetic row generation helpers.
- `Xorshift64` stores one 64-bit state word and exposes deterministic integer, float, and bounded index draws.
- Open it when reproducible dataframe randomness changes; filtering, SQL, and typed storage live in sibling files.

### serial.rs

- This file owns dataframe payload codecs for CSV, JSON, LVDF binary bytes, debug tables, and database JSON maps.
- `from_csv`, `from_json`, and `from_binary` rebuild `DataFrame` state, while methods serialize the same state back out.
- CSV parsing and quoting live here because field escaping and type inference are payload concerns, not storage policy.
- The JSON parser also stays here, including object walking, string escapes, nested value coercion, and array skipping.
- LVDF encoding belongs here because binary tags, version bytes, and truncation checks define the wire representation.
- `to_string_table` is local because readable inspection output depends on column widths but not on query semantics.
- `database_from_json` and `Database::to_json` live here to keep table-map payload structure beside frame JSON codecs.
- Open it when interchange formats change; caller transport, SQL planning, and row mutation live in sibling files.
- This file is about conversion boundaries only, not lazy execution, grouping math, or background dataframe workers.

### sql.rs

- This file owns the SQL-like execution layer that tokenizes, parses, plans, and runs SELECT queries over dataframes.
- Its lexer and parser store tokens, select expressions, joins, arithmetic nodes, and boolean expression trees.
- `query_sql` executes against one `DataFrame`, while database variants resolve `FROM` and `JOIN` tables from `Database`.
- Parameter binding also lives here because `?` replacement and SQL literal escaping are part of query boundary safety.
- Projection evaluation stays here because aliases, arithmetic columns, and aggregate calls are SELECT semantics.
- WHERE, LIKE, IN, HAVING, ORDER BY, LIMIT, and OFFSET execution also belong here as statement-level behavior.
- Group execution is implemented here because grouped SELECT lists and HAVING filters depend on parsed SQL structure.
- Join application stays here because database queries must merge tables before the rest of statement execution runs.
- `explain_sql` is local because the plan summary reflects parser state, clause presence, and selected projections.
- Aggregate helpers also stay here so COUNT, SUM, AVG, MIN, and MAX reuse one evaluation path for grouped summaries.
- LIKE wildcard matching and expression evaluation are local internals because they serve SQL semantics only.
- Open it when query grammar changes; frame storage, payload codecs, and deferred pipelines live in sibling owners.

### task.rs

- This file owns one-shot background dataframe jobs for file loading and SQL execution over cloned snapshots.
- `DataFrameTask` stores the receiver, cached outcome, and coarse progress shared between the caller and worker thread.
- Spawn helpers live here because progress updates, thread naming, and result wrapping are task-lifecycle concerns.
- The file bridges `file_io.rs` and `sql.rs` into async work without moving engine-facing polling into those owners.
- Error formatting also stays here so task callers always get stable strings regardless of storage backend details.
- Open it when async dataframe execution changes; table mutation, parsing, and lazy planning live in siblings.

### vectorized.rs

- This file owns typed column stores and vectorized execution paths used for faster numeric dataframe workloads.
- `ColumnStore` models float, int, bool, and text buffers with optional validity masks for nil-aware processing.
- `VecFrame` stores ordered typed columns, converts to and from `DataFrame`, and resolves names for later operators.
- Scalar, binary, reduction, and comparison enums live here because they define the operation vocabulary on typed data.
- In-place scalar ops and clamps belong here because they mutate raw numeric buffers without going through cell wrappers.
- Binary ops and reductions also stay here so numeric coercion, validity propagation, and dtype checks share one owner.
- Mask construction and application are local because predicate filtering over typed buffers is a vectorized concern.
- Column casting remains here because representation changes between float, int, and text are storage-level decisions.
- Rayon-backed `par_reduce`, `par_scalar_op`, and `par_apply_column` live here as the parallel execution boundary.
- Open it when typed execution changes; SQL parsing, generic frame semantics, and file codecs live in siblings.



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
