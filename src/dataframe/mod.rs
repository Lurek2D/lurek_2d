//! Defines the dataframe module boundary for typed tabular storage, query execution, and serialization flows. `dataframe/mod` is the dataframe module index, declaring `file_io`, `frame`, `lazy`, `query`, `rng`, and 4 more so agents can identify which files own each feature slice before opening implementation code.
//! Groups core frame models, lazy operations, SQL parsing, threaded tasks, and vectorized processing layers. `src/dataframe/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `frame::{CellValue, ColRef, ColumnSchema, DataFrame, DataFrameRowIter, Database}`, `lazy::LazyQuery`, `task::DataFrameTask`, `vectorized::{BinaryOp, CmpOp, ColumnStore, ReduceOp, ScalarOp, VecFrame}` centralized for the dataframe subsystem.

/// Storage-agnostic dataframe and database file persistence helpers.
pub mod file_io;
/// Core table types and base dataframe operations.
pub mod frame;
/// Deferred query builder and lazy execution pipeline.
pub mod lazy;
/// Query-time transforms including filter, grouping, and window ops.
pub mod query;
/// Internal pseudo-random generator for deterministic sampling.
pub mod rng;
/// CSV, JSON, and binary serializers and parsers.
pub mod serial;
/// SQL-like tokenizer, parser, and SELECT executor.
pub mod sql;
/// One-shot threaded dataframe tasks.
pub mod task;
/// Columnar vectorized execution helpers and parallel operators.
pub mod vectorized;
pub use frame::{CellValue, ColRef, ColumnSchema, DataFrame, DataFrameRowIter, Database};
pub use lazy::LazyQuery;
pub use task::DataFrameTask;
pub use vectorized::{BinaryOp, CmpOp, ColumnStore, ReduceOp, ScalarOp, VecFrame};
