//! - Columnar DataFrame type and Database container
//! - Lazy query builder and deferred execution pipeline
//! - Query-time transforms: filtering, grouping, analytics, processing, and window functions
//! - CSV, JSON, and binary serialization and parsing
//! - Storage-agnostic file persistence helpers for dataframe and database payloads
//! - One-shot threaded dataframe tasks for file loading and SQL queries
//! - SQL-like SELECT executor with tokenizer and recursive-descent parser
//! - Typed vectorized column storage with parallel reduce and scalar operations

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
pub use frame::{CellValue, ColRef, DataFrame, DataFrameRowIter, Database};
pub use lazy::LazyQuery;
pub use task::DataFrameTask;
pub use vectorized::{BinaryOp, CmpOp, ColumnStore, ReduceOp, ScalarOp, VecFrame};
