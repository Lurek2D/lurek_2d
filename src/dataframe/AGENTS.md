# Dataframe Module Contract

## Mission & Scope
- Own table data, SQL-like queries, lazy pipelines, and dataframe transforms.
- Keep query behavior deterministic and schema-aware.

## Files
- `frame.rs`, `vectorized.rs`: Table storage and transforms.
- `query/`, `sql.rs`, `lazy.rs`: Queries, analytics, and lazy pipelines.
- `file_io.rs`, `serial.rs`: File import and serialization.
- `rng.rs`, `task.rs`: Random operations and background tasks.

## Rules
- Preserve row order unless an operation explicitly sorts or groups.
- Report schema/query errors with column or expression context.
- Keep lazy pipelines side-effect free until collection.

## Workflow
- Validate with `cargo test --test dataframe_tests`.
