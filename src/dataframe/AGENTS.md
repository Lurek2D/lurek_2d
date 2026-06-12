# Dataframe Module Contract

## Mission & Scope
- Own table data, SQL-like queries, lazy pipelines, and dataframe transforms.
- Keep query behavior deterministic and schema-aware.

## Files
- `frame.rs`, `query.rs`, `database.rs`: Data, query, and multi-table logic.
- `schema.rs`, `csv.rs`: Type inference and import parsing.

## Rules
- Preserve row order unless an operation explicitly sorts or groups.
- Report schema/query errors with column or expression context.
- Keep lazy pipelines side-effect free until collection.

## Workflow
- Validate with `cargo test --test dataframe_tests`.
