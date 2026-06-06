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

This module acts as the documentation workflow and quality assurance core, managing the generation, validation, and export of the engine's public interface data. It handles the parsing of API metadata into a unified in-memory documentation catalog. This central catalog groups and organizes symbols across modules, maintaining their entry definitions to provide a single, consistent source of truth for the entire scripting framework.

To verify the accuracy and completeness of API references, the module supplies detailed reporting and validation tools. It cross-references the catalog against live runtime tables to identify undocumented, missing, or outdated symbols. Additionally, the quality analyzer scores individual documentation records based on detail, generating overall and per-module grades that highlight areas needing expansion or cleanup.

For external tool integration, the system includes export builders that transform documentation entries into files. These builders output rich autocomplete catalogs, hover details, and signature definitions formatted specifically for text editors and development extensions. This bridges the runtime's documentation directly with the editor workspace, improving the developer experience.

Additionally, a schema validation layer provides structured data checks. It connects documentation workflows with unified type rules, allowing runtime systems to validate tables against schemas and generate detailed reports. This ensures all configuration and API data structures remain correct, providing reliable validation errors when data checks fail.

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
