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

- Lua-side dataframe handle for tabular data with named columns and typed cells.

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

- Lua-side handle for a threaded dataframe job.

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

- Lua-side in-memory database containing named dataframes.

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

- Lua-side grouped dataframe object containing group keys and subframes.

##### Fields

- No documented fields.

##### Methods

- `LGroupedFrame:aggregate`: Aggregates one numeric column in every group by calling a Lua function with that group's numeric values.
- `LGroupedFrame:type`: Returns the Lua-visible type name for this grouped frame handle.
- `LGroupedFrame:typeOf`: Returns whether this grouped frame handle matches a supported type name.

#### LLazyQuery Type

- Lua-side lazy dataframe query pipeline.

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

- Lua-side vectorized dataframe handle for numeric column operations.

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
