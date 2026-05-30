# docs

## General Info

- Module group: `Edge/Integration`
- Source path: `src/docs/`
- Binding: `src/lua_api/docs_api.rs`
- Namespace: `lurek.docs`
- Lua API surface: `26` functions, `13` types, `60` methods
- Rust test path(s): tests/rust/unit/docs_tests.rs
- Lua test path(s): tests/lua/unit/test_docs.lua

## Summary

The `docs` module is the internal documentation infrastructure used by generation and tooling flows. It gives one structured place for doc entries, catalog operations, export output, and quality checks.

Its functional coverage spans the whole documentation path. Data can be collected into a catalog, validated against schema contracts, scored for quality, and exported into formats consumed by editor integrations.

By centralizing these responsibilities, the project reduces drift between source metadata and generated artifacts. This keeps completion, hover, and signature outputs aligned with the same underlying record model.

The module is designed for stable integration. Deterministic output shapes and explicit validation criteria make downstream tools more reliable in local workflows and automated checks.

In practice, `lurek.docs` provides one dependable pipeline core for transforming API metadata into consistent, verifiable documentation artifacts.

## Files

### [catalog.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/docs/catalog.rs)

- Provides the in-memory documentation catalog used to collect and organize normalized API entries.
- Preserves insertion order while supporting grouping, filtering, and lookup across module boundaries.
- Enables merge and dedup workflows for combining multiple documentation sources into one view.
- Delivers the central container that feeds both export generation and quality analysis stages.

### [entry.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/docs/entry.rs)

- Provides normalized documentation record types that represent public API symbols and their metadata.
- Models parameter and return descriptors so downstream export and reporting stages share one data shape.
- Includes completeness checks that help quality tooling detect thin or malformed documentation entries.
- Delivers the common in-memory contract used across collection, transformation, and reporting flows.

### [export.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/docs/export.rs)

- Provides export builders that transform normalized doc entries into IDE-oriented JSON payloads.
- Produces completion, hover, and signature datasets in shapes tailored to extension and tooling consumers.
- Supports compact or rich payload modes to match different integration and footprint constraints.
- Writes single or bundled artifacts through stable serialization paths for predictable output handling.
- Delivers the final packaging stage that turns in-memory documentation into distributable files.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/docs/mod.rs)

- Provides the top-level documentation module surface that connects collection, schema, export, and reporting stages.
- Centralizes re-exports so tooling callers can consume doc pipeline capabilities from one stable integration point.
- Delivers a coherent module boundary for transforming source metadata into validated documentation artifacts.

### [report.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/docs/report.rs)

- Provides documentation quality evaluation logic that scores completeness and classifies report grades.
- Validates catalog integrity by tracking missing, phantom, and incomplete documentation records.
- Aggregates per-entry and per-module metrics into actionable quality snapshots for maintainers.
- Supports both full-catalog analysis and direct entry-based reporting for flexible pipeline usage.
- Delivers consistent quality signals that guide doc cleanup and release readiness checks.

### [schema.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/docs/schema.rs)

- Provides the schema bridge that exposes shared validation contracts used by the docs pipeline.
- Connects documentation tooling with canonical field and type rules defined in the schema crate.
- Delivers one access point that keeps schema usage consistent across docs modules.
