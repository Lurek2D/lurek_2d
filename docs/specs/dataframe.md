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

The `dataframe` module provides columnar table storage and query tooling for structured data workflows. Its core table abstractions are backed by typed operations and serialization paths, then extended with lazy query building, SQL-like execution, and asynchronous task helpers.

Core responsibilities are separated across modules: `frame` for base dataframe/database structures, `query` for transform and aggregation logic, `lazy` for deferred execution pipelines, `sql` for tokenizer/parser/executor behavior, `serial` for CSV/JSON/binary conversion, and `file_io` for persistence helpers. `rng` supports deterministic sampling and related operations.

This design allows callers to use only the depth they need, from simple table manipulation to SQL-style extraction and async loading workflows. It also keeps parse/IO concerns decoupled from in-memory table behavior.

As a foundations component, `dataframe` should keep deterministic semantics for query results and type handling. Higher-level domain policy should compose on top of these stable primitives rather than fork table logic.

Implementation detail and boundary guarantees for dataframe: this module keeps responsibilities explicit across source files so behavior remains inspectable during refactors. The current source map is: file_io.rs: Provides storage-agnostic DataFrame and Database file persistence helpers.; frame.rs: Core dataframe cell type and typed value representation - Columnar storage with named columns and row-major access - Column resolution by name or one-based index - Row and column CRUD operations including add, remove, and rename - DataFrame cloning, slicing, and row iteration - D; lazy.rs: Deferred query step representation for filter, sort, select, head, tail, slice, and limit - Lazy query builder that chains steps without executing until collect - Materialization via sequential step application over a cloned source frame; mod.rs: Columnar DataFrame type and Database container - Lazy query builder and deferred execution pipeline - Query-time transforms: filtering, grouping, analytics, processing, and window functions - CSV, JSON, and binary serialization and parsing - Storage-agnostic file persistence help; query/analytics.rs: Percentile computation by linear interpolation over sorted values - Z-score standardization for numeric columns - Min-max normalization to arbitrary output range - Outlier detection via z-score threshold - Mode value computation across non-nil cells - Shannon entropy calculation; query/filter.rs: Row filtering by column predicate with comparison and contains operators - Column sorting in ascending or descending order - Head, tail, and inclusive slice row selection - Column projection and unique value extraction - Group-by partitioning and inner/left join merging - Frame m; query/grouping.rs: Grouped aggregation by key column with mean, sum, min, max, count, first, last - Pivot transformation from row/column/value keys into cross-tabulated frame - Pearson correlation between two numeric columns - Full numeric-column correlation matrix generation; query/mod.rs: Statistical and distribution-oriented analytics helpers - Row filtering, sorting, joins, and sampling operations - Grouped aggregation, pivoting, and correlation computations - Reusable processing helpers for counts, missingness, duplicates, and dates - Rolling and ranking window; query/processing.rs: Frequency tables with optional percentage output - Column-level missing-value reports - Duplicate row extraction by full-row or selected-column keys - ISO date part extraction into appended year, month, and day columns; query/window.rs: Rolling mean, sum, min, and max over configurable window size - Dense rank computation with average-rank tie-breaking - Row-to-row percent change calculation - Cumulative sum across ordered rows; rng.rs: Xorshift64 pseudo-random number generator for deterministic dataframe sampling - Float, integer, and index generation from 64-bit state - Zero-seed remap to avoid degenerate all-zero output; serial.rs: CSV parsing with quote escaping and type auto-detection - CSV serialization with field escaping rules - JSON array-of-objects parsing into DataFrame - JSON serialization with proper string escaping - Compact binary LVDF format encoding and decoding - Padded string-table rendering; sql.rs: SQL text tokenizer producing typed token stream - Recursive-descent parser for SELECT statements - WHERE clause expression tree with AND, OR, NOT, LIKE, and IN - Aggregate function support: COUNT, SUM, AVG, MIN, MAX - SELECT arithmetic expressions with explicit AS aliases - GRO; task.rs: One-shot threaded dataframe jobs for file loading and SQL queries.; vectorized.rs: Typed columnar storage (Float64, Int64, Bool, Text) with optional validity masks - Element-wise scalar operations: add, sub, mul, div, abs, sqrt, floor, ceil, neg - Element-wise binary operations between two numeric columns - Column reduction: sum, mean, min, max, std, var, count. This split is part of the contract: orchestration stays in composition points, data models stay in type-centric files, and adapters stay in bridge files. That separation reduces hidden coupling, improves testability, and keeps Lua API surfaces aligned with Rust runtime semantics. For maintainers, the key guarantee is that high-level APIs should keep delegating into scoped internals instead of collapsing into a single large entry point. Future extensions should preserve explicit dependency direction and documented invariants near owning types and functions.

## Files

### file_io.rs

- Provides storage-agnostic DataFrame and Database file persistence helpers.
- Defines a narrow trait for reading and writing text, JSON, and binary payloads without importing GameFS.
- Combines existing CSV, JSON, LVDF, and database serializers with caller-provided storage operations.
- Keeps storage failures separate from parse and format failures so Lua bindings can preserve error surfaces.

### frame.rs

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

### lazy.rs

- Deferred query step representation for filter, sort, select, head, tail, slice, and limit
- Lazy query builder that chains steps without executing until `collect`
- Materialization via sequential step application over a cloned source frame

### mod.rs

- Columnar DataFrame type and Database container
- Lazy query builder and deferred execution pipeline
- Query-time transforms: filtering, grouping, analytics, processing, and window functions
- CSV, JSON, and binary serialization and parsing
- Storage-agnostic file persistence helpers for dataframe and database payloads
- One-shot threaded dataframe tasks for file loading and SQL queries
- SQL-like SELECT executor with tokenizer and recursive-descent parser
- Typed vectorized column storage with parallel reduce and scalar operations

### query/analytics.rs

- Percentile computation by linear interpolation over sorted values
- Z-score standardization for numeric columns
- Min-max normalization to arbitrary output range
- Outlier detection via z-score threshold
- Mode value computation across non-nil cells
- Shannon entropy calculation over rendered cell distributions

### query/filter.rs

- Row filtering by column predicate with comparison and contains operators
- Column sorting in ascending or descending order
- Head, tail, and inclusive slice row selection
- Column projection and unique value extraction
- Group-by partitioning and inner/left join merging
- Frame merge, count-by, drop-nil, and deterministic sampling
- Aggregate statistics: sum, mean, min, max, median, stddev, variance
- Descriptive statistics frame generation
- Nil fill, batch row append, and column f64 import/export

### query/grouping.rs

- Grouped aggregation by key column with mean, sum, min, max, count, first, last
- Pivot transformation from row/column/value keys into cross-tabulated frame
- Pearson correlation between two numeric columns
- Full numeric-column correlation matrix generation

### query/mod.rs

- Statistical and distribution-oriented analytics helpers
- Row filtering, sorting, joins, and sampling operations
- Grouped aggregation, pivoting, and correlation computations
- Reusable processing helpers for counts, missingness, duplicates, and dates
- Rolling and ranking window functions

### query/processing.rs

- Frequency tables with optional percentage output
- Column-level missing-value reports
- Duplicate row extraction by full-row or selected-column keys
- ISO date part extraction into appended year, month, and day columns

### query/window.rs

- Rolling mean, sum, min, and max over configurable window size
- Dense rank computation with average-rank tie-breaking
- Row-to-row percent change calculation
- Cumulative sum across ordered rows

### rng.rs

- Xorshift64 pseudo-random number generator for deterministic dataframe sampling
- Float, integer, and index generation from 64-bit state
- Zero-seed remap to avoid degenerate all-zero output

### serial.rs

- CSV parsing with quote escaping and type auto-detection
- CSV serialization with field escaping rules
- JSON array-of-objects parsing into DataFrame
- JSON serialization with proper string escaping
- Compact binary LVDF format encoding and decoding
- Padded string-table rendering for debug and display
- Database-level JSON serialization across all tables
- Database-level JSON parsing from named table arrays
- Nested JSON value and array handling during parse

### sql.rs

- SQL text tokenizer producing typed token stream
- Recursive-descent parser for SELECT statements
- WHERE clause expression tree with AND, OR, NOT, LIKE, and IN
- Aggregate function support: COUNT, SUM, AVG, MIN, MAX
- SELECT arithmetic expressions with explicit `AS` aliases
- GROUP BY with HAVING filter and ORDER BY with LIMIT/OFFSET
- JOIN clause parsing and inner-join execution
- SQL LIKE pattern matching with `%` and `_` wildcards
- Single-frame and multi-table Database query entry points

### task.rs

- One-shot threaded dataframe jobs for file loading and SQL queries.
- Worker-owned storage snapshots so large CSV/JSON reads do not pass through Lua strings.
- Poll, wait, result, error, and progress lifecycle helpers shared by Lua bindings.
- Snapshot-based DataFrame and Database query execution on Rust worker threads.

### vectorized.rs

- Typed columnar storage (Float64, Int64, Bool, Text) with optional validity masks
- Element-wise scalar operations: add, sub, mul, div, abs, sqrt, floor, ceil, neg
- Element-wise binary operations between two numeric columns
- Column reduction: sum, mean, min, max, std, var, count
- Comparison mask generation for filter predicates
- VecFrame ↔ DataFrame bidirectional conversion with type inference
- Parallel multi-column reduce and scalar operations via rayon
- Column type casting between float64, int64, and text
- Boolean mask filtering across all column types

## Lua API Ref

- Binding: `src/lua_api/dataframe_api.rs`
- Namespace: `lurek.dataframe`

### Functions

- `lurek.dataframe.fromBinary`: Parses a dataframe from binary data.
- `lurek.dataframe.fromCSV`: Parses a dataframe from CSV text. This function is exposed to Lua scripts.
- `lurek.dataframe.fromCSVFile`: Reads CSV text from GameFS and parses it into a dataframe.
- `lurek.dataframe.fromCSVFileAsync`: Starts a Rust worker task that reads CSV text from GameFS and parses it into a dataframe.
- `lurek.dataframe.fromJSON`: Parses a dataframe from JSON text. This function is exposed to Lua scripts.
- `lurek.dataframe.fromJSONFile`: Reads JSON text from GameFS and parses it into a dataframe.
- `lurek.dataframe.fromJSONFileAsync`: Starts a Rust worker task that reads JSON text from GameFS and parses it into a dataframe.
- `lurek.dataframe.fromRows`: Creates a dataframe from column names and array-style rows.
- `lurek.dataframe.fromTable`: Creates a dataframe from an array table of row tables.
- `lurek.dataframe.fromVec`: Converts a vectorized frame to a dataframe.
- `lurek.dataframe.loadDatabase`: Reads a JSON database file from GameFS and parses it into a database.
- `lurek.dataframe.newDataFrame`: Creates an empty dataframe. This function is exposed to Lua scripts.
- `lurek.dataframe.newDatabase`: Creates an empty dataframe database.
- `lurek.dataframe.random`: Creates a random dataframe from column definitions.
- `lurek.dataframe.toVec`: Converts a dataframe to a vectorized frame.

### Enums

- No documented module-level enums/constants.

### Types


#### LDataFrame Type


##### Fields

- No documented fields.

##### Methods

- `LDataFrame:addColumn`: Adds a column with an optional default value.
- `LDataFrame:addRow`: Adds a row from an optional map table and returns its one-based row index.
- `LDataFrame:addRowBatch`: Appends multiple rows from array-style row tables.
- `LDataFrame:apply`: Applies a Lua function to each value in a column in place.
- `LDataFrame:clone`: Returns a deep copy of this dataframe.
- `LDataFrame:columns`: Returns all column names in order. This method is available to Lua scripts.
- `LDataFrame:corr`: Returns correlation between two numeric columns.
- `LDataFrame:correlationMatrix`: Returns a correlation matrix for numeric columns.
- `LDataFrame:count`: Returns the row count for this dataframe.
- `LDataFrame:countBy`: Counts occurrences of each value in a column.
- `LDataFrame:dateParts`: Returns a new dataframe with year, month, and day columns extracted from ISO `yyyy-mm-dd` text.
- `LDataFrame:describe`: Returns summary statistics for numeric columns.
- `LDataFrame:dropNil`: Returns rows where the chosen column is not nil.
- `LDataFrame:duplicateRows`: Returns rows whose full-row key or selected-column key appears more than once.
- `LDataFrame:entropy`: Returns entropy for a column. This method is available to Lua scripts.
- `LDataFrame:fillNil`: Replaces nil cells in a column with a value.
- `LDataFrame:filter`: Returns rows whose column value matches a comparison.
- `LDataFrame:getColumn`: Returns a column as an array table. This method is available to Lua scripts.
- `LDataFrame:getColumnAsF64`: Returns a numeric column as an array of numbers.
- `LDataFrame:getRow`: Returns a row as a table keyed by column name.
- `LDataFrame:getValue`: Returns one cell value by one-based row and column reference.
- `LDataFrame:groupAgg`: Groups by one column and aggregates another column.
- `LDataFrame:groupBy`: Groups rows by a column and returns a table from group key to dataframe.
- `LDataFrame:groupByObj`: Groups rows by a column and returns a grouped-frame object.
- `LDataFrame:head`: Returns the first rows of this dataframe.
- `LDataFrame:join`: Joins this dataframe with another dataframe by column references.
- `LDataFrame:lazy`: Starts a lazy query pipeline from this dataframe.
- `LDataFrame:max`: Returns the maximum value of a column.
- `LDataFrame:mean`: Returns the numeric mean of a column.
- `LDataFrame:median`: Returns the numeric median of a column.
- `LDataFrame:merge`: Appends another dataframe into this dataframe in place.
- `LDataFrame:min`: Returns the minimum value of a column.
- `LDataFrame:missingReport`: Reports missing and non-missing cell counts for every column.
- `LDataFrame:modeVal`: Returns the mode value of a column. This method is available to Lua scripts.
- `LDataFrame:ncols`: Returns the number of columns in this dataframe.
- `LDataFrame:normalizeCol`: Adds a range-normalized column in place.
- `LDataFrame:nrows`: Returns the number of rows in this dataframe.
- `LDataFrame:outliers`: Returns rows considered outliers for a numeric column.
- `LDataFrame:parFilter`: Parallel filter — automatically parallelizes when frame has 10,000+ rows.
- `LDataFrame:parGroupAgg`: Parallel group-by aggregation — partitions and aggregates in parallel.
- `LDataFrame:pivot`: Pivots rows into columns using row, column, and value fields.
- `LDataFrame:pivotTable`: Builds a pivot table using row key, column key, value column, and aggregate function.
- `LDataFrame:query`: Runs a SQL-style query against this dataframe.
- `LDataFrame:queryAsync`: Runs a SQL-style query against this dataframe on a Rust worker thread.
- `LDataFrame:rank`: Returns a dataframe with a rank column.
- `LDataFrame:removeColumn`: Removes a column by name or one-based index.
- `LDataFrame:removeRow`: Removes a row by one-based index. This method is available to Lua scripts.
- `LDataFrame:rename`: Renames a column by name or one-based index.
- `LDataFrame:rollingMean`: Returns a dataframe with a rolling mean column.
- `LDataFrame:rollingSum`: Returns a dataframe with a rolling sum column.
- `LDataFrame:rows`: Returns an iterator function over one-based row index and row table pairs.
- `LDataFrame:sample`: Returns a sampled dataframe. This method is available to Lua scripts.
- `LDataFrame:select`: Returns a dataframe with selected columns.
- `LDataFrame:setColumnFromF64`: Replaces a numeric column from an array table of numbers.
- `LDataFrame:setValue`: Sets one cell value by one-based row and column reference.
- `LDataFrame:slice`: Returns a one-based inclusive row slice.
- `LDataFrame:sort`: Returns rows sorted by a column. This method is available to Lua scripts.
- `LDataFrame:stddev`: Returns the numeric standard deviation of a column.
- `LDataFrame:sum`: Returns the numeric sum of a column.
- `LDataFrame:tail`: Returns the last rows of this dataframe.
- `LDataFrame:toBinary`: Serializes this dataframe to binary data.
- `LDataFrame:toBinaryFile`: Serializes this dataframe to LVDF binary data and writes it through GameFS.
- `LDataFrame:toCSV`: Serializes this dataframe to CSV text.
- `LDataFrame:toCSVFile`: Serializes this dataframe to CSV text and writes it through GameFS.
- `LDataFrame:toJSON`: Serializes this dataframe to JSON text.
- `LDataFrame:toJSONFile`: Serializes this dataframe to JSON text and writes it through GameFS.
- `LDataFrame:toString`: Formats this dataframe as a human-readable text table.
- `LDataFrame:toTable`: Converts this dataframe to an array table of row tables.
- `LDataFrame:type`: Returns the Lua-visible type name for this dataframe handle.
- `LDataFrame:typeOf`: Returns whether this dataframe handle matches a supported type name.
- `LDataFrame:unique`: Returns unique values from a column.
- `LDataFrame:valueCounts`: Counts occurrences of each value in a column with optional percentage output.
- `LDataFrame:variance`: Returns the numeric variance of a column.
- `LDataFrame:withCumsum`: Adds a cumulative-sum column in place.
- `LDataFrame:withEval`: Returns a dataframe with a column computed from an expression.
- `LDataFrame:withPctChange`: Adds a percent-change column in place.
- `LDataFrame:withRank`: Adds a rank column in place. This method is available to Lua scripts.
- `LDataFrame:withRollingMax`: Adds a rolling maximum column in place.
- `LDataFrame:withRollingMean`: Adds a rolling mean column in place.
- `LDataFrame:withRollingMin`: Adds a rolling minimum column in place.
- `LDataFrame:withRollingSum`: Adds a rolling sum column in place. This method is available to Lua scripts.
- `LDataFrame:zscoreCol`: Adds a z-score normalized column in place.


#### LDataFrameTask Type


##### Fields

- No documented fields.

##### Methods

- `LDataFrameTask:getError`: Returns the task error message after failure.
- `LDataFrameTask:isDone`: Returns whether this dataframe task has completed with success or failure.
- `LDataFrameTask:progress`: Returns a coarse task progress estimate.
- `LDataFrameTask:result`: Returns the completed dataframe result.
- `LDataFrameTask:type`: Returns the Lua-visible type name for this dataframe task handle.
- `LDataFrameTask:typeOf`: Returns whether this dataframe task handle matches a supported type name.
- `LDataFrameTask:wait`: Blocks until this dataframe task completes.


#### LDatabase Type


##### Fields

- No documented fields.

##### Methods

- `LDatabase:addTable`: Adds or replaces a named dataframe table in the database.
- `LDatabase:clear`: Removes every table from the database.
- `LDatabase:getTable`: Returns a copy of a named table when it exists.
- `LDatabase:hasTable`: Returns whether a named table exists.
- `LDatabase:listTables`: Returns all table names in the database.
- `LDatabase:merge`: Merges another database into this database.
- `LDatabase:query`: Runs a SQL-style query against the database tables.
- `LDatabase:queryAsync`: Runs a SQL-style query against a snapshot of the database tables on a Rust worker thread.
- `LDatabase:queryParams`: Runs a SQL-style query against the database tables with positional parameters.
- `LDatabase:queryParamsAsync`: Runs a parameterized SQL query against a snapshot of the database tables on a Rust worker thread.
- `LDatabase:removeTable`: Removes a named table from the database.
- `LDatabase:save`: Serializes the database to the JSON database file format and writes it through GameFS.
- `LDatabase:tableCount`: Returns the number of tables in the database.
- `LDatabase:toJSON`: Serializes the database to JSON text.
- `LDatabase:type`: Returns the Lua-visible type name for this database handle.
- `LDatabase:typeOf`: Returns whether this database handle matches a supported type name.


#### LGroupedFrame Type


##### Fields

- No documented fields.

##### Methods

- `LGroupedFrame:aggregate`: Aggregates one numeric column in every group by calling a Lua function with that group's numeric values.
- `LGroupedFrame:type`: Returns the Lua-visible type name for this grouped frame handle.
- `LGroupedFrame:typeOf`: Returns whether this grouped frame handle matches a supported type name.


#### LLazyQuery Type


##### Fields

- No documented fields.

##### Methods

- `LLazyQuery:collect`: Executes the lazy query and returns a dataframe.
- `LLazyQuery:dropNil`: Adds a step that drops rows with nil values in a column.
- `LLazyQuery:filter`: Adds a filter step to the lazy query.
- `LLazyQuery:head`: Adds a head limit step to the lazy query.
- `LLazyQuery:limit`: Adds a row limit step to the lazy query.
- `LLazyQuery:select`: Adds a column selection step to the lazy query.
- `LLazyQuery:slice`: Adds a one-based row slice step to the lazy query.
- `LLazyQuery:sort`: Adds a sort step to the lazy query. This method is available to Lua scripts.
- `LLazyQuery:tail`: Adds a tail limit step to the lazy query.
- `LLazyQuery:type`: Returns the Lua-visible type name for this lazy query handle.
- `LLazyQuery:typeOf`: Returns whether this lazy query handle matches a supported type name.


#### LVecFrame Type


##### Fields

- No documented fields.

##### Methods

- `LVecFrame:applyMask`: Returns a vectorized frame filtered by a boolean mask table.
- `LVecFrame:colAbs`: Applies absolute value to a numeric column in place.
- `LVecFrame:colAdd`: Adds a scalar to a numeric column in place.
- `LVecFrame:colCast`: Casts a vectorized column to another data type in place.
- `LVecFrame:colCeil`: Applies ceil to a numeric column in place.
- `LVecFrame:colClamp`: Clamps a numeric column in place. This method is available to Lua scripts.
- `LVecFrame:colDiv`: Divides a numeric column by a scalar in place.
- `LVecFrame:colFloor`: Applies floor to a numeric column in place.
- `LVecFrame:colMul`: Multiplies a numeric column by a scalar in place.
- `LVecFrame:colNeg`: Negates a numeric column in place. This method is available to Lua scripts.
- `LVecFrame:colOp`: Applies a binary column operation into an output column.
- `LVecFrame:colSqrt`: Applies square root to a numeric column in place.
- `LVecFrame:colSub`: Subtracts a scalar from a numeric column in place.
- `LVecFrame:colType`: Returns the data type name for a vectorized column.
- `LVecFrame:columns`: Returns all vectorized column names in order.
- `LVecFrame:filterMask`: Builds a boolean mask for a numeric column comparison.
- `LVecFrame:ncols`: Returns the number of columns in this vectorized frame.
- `LVecFrame:nrows`: Returns the number of rows in this vectorized frame.
- `LVecFrame:parReduce`: Reduces multiple numeric columns in parallel.
- `LVecFrame:parScalarOp`: Applies a scalar operation to multiple numeric columns in parallel.
- `LVecFrame:reduce`: Reduces a numeric column with a named operation.
- `LVecFrame:toDataFrame`: Converts this vectorized frame to a dataframe.
- `LVecFrame:type`: Returns the Lua-visible type name for this vectorized frame handle.
- `LVecFrame:typeOf`: Returns whether this vectorized frame handle matches a supported type name.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.
