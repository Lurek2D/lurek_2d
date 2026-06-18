//! This module is the dataframe index, exposing frame storage, query helpers, serializers, SQL, tasks, and vectors.
//! It reexports `DataFrame`, `Database`, `LazyQuery`, `DataFrameTask`, and vectorized enums as the public surface.
//! `frame.rs` owns typed cells and table state, while `query/` extends that state with filtering and analytics flows.
//! `serial.rs` and `file_io.rs` cover payload conversion and caller-supplied transport, not table mutation semantics.
//! `sql.rs`, `lazy.rs`, and `task.rs` add planning and execution layers over the same tabular core contracts.
//! Open this file to navigate module boundaries and exports; actual data behavior, parsing, and math live in siblings.

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
