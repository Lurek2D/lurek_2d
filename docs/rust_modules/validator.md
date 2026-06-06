# validator

## General Info

- Module group: `Edge/Integration`
- Source path: `src/validator/`
- Binding: `src/lua_api/validator_api.rs`
- Namespace: `lurek.validator`
- Lua API surface: `3` functions, `1` types, `9` methods
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

This module provides a static analysis engine designed to inspect Lua projects before runtime. By scanning source files statically, it identifies API compliance issues, broken module imports, and missing asset references early. The validation orchestrator lets teams enforce clean code standards by combining built-in checks with customizable rules.

To handle large projects, the system runs checks across parallel threads and aggregates findings into structured diagnostic reports. These reports capture the location, severity, and context of each violation, feeding directly into local workflows and automated quality pipelines. Extensible rules can be loaded from TOML files or custom scripts.

## Files

### [api_check.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/validator/api_check.rs)

- This file provides API compliance validation for Lua calls targeting the lurek namespace.
- It scans call sites against registered signatures to catch unknown endpoints early.
- It detects argument-shape mismatches that often signal migration or integration drift.
- It emits structured violations with location data for actionable feedback in pipelines.
- It anchors API contract enforcement within the broader validation engine workflow.

### [asset_check.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/validator/asset_check.rs)

- This file provides static asset path validation for script references to game resources.
- It finds load-site path strings and checks their existence against the configured root.
- It reports missing files before runtime so broken builds fail early and clearly.
- It integrates with validator runs used by both local checks and CI quality gates.

### [config.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/validator/config.rs)

- This file provides configuration structures that shape validator execution policy.
- It defines thread usage, file limits, and behavior toggles for analysis runs.
- It gives the engine one coherent source of operational constraints.

### [engine.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/validator/engine.rs)

- This file provides the validation orchestrator that runs rule sets over project content.
- It composes built-in and custom rules into one execution plan shaped by config.
- It dispatches checks across files and aggregates findings into structured reports.
- It serves as the main engine entry used by runtime tooling and validation commands.
- It keeps rule execution boundaries explicit so validation behavior remains auditable.

### [import_check.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/validator/import_check.rs)

- This file provides import resolution checks for Lua require targets in project scripts.
- It scans textual require patterns and resolves module paths against configured lookup roots.
- It surfaces missing dependencies before runtime to reduce integration surprises.
- It keeps the check static and safe by avoiding script execution during analysis.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/validator/mod.rs)

- This module delivers the validation surface for script content, assets, imports, and API usage.
- It combines built-in and custom rule paths into one extensible quality-check pipeline.
- It outputs structured findings that guide fixes in development and continuous integration.

### [parallel.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/validator/parallel.rs)

- This file provides parallel execution plumbing for validator rule application across files.
- It enumerates candidate inputs and partitions work over worker threads efficiently.
- It merges per-file violations into unified reports without unstable ordering surprises.
- It supports configurable thread control, including single-thread fallback execution.

### [report.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/validator/report.rs)

- This file provides typed report models for storing and presenting validation outcomes.
- It defines violation records with severity, location, identity, and human-readable message.
- It supports filtering and summary views so large result sets remain actionable.
- It standardizes severity ordering for consistent thresholding and pipeline behavior.
- It anchors validator output contracts consumed by tools and user-facing diagnostics.

### [rule.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/validator/rule.rs)

- This file provides the rule trait contract that all validator checks implement.
- It defines the required identity, severity, and check interface for rule execution.
- It keeps rules composable across built-in logic and externally supplied adapters.

### [rules_lua.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/validator/rules_lua.rs)

- This file provides Lua-backed custom rule adapters for extending validator coverage.
- It stores pattern and callback metadata that bridges script-defined checks into Rust flow.
- It converts callback outputs into typed violations compatible with native reporting.
- It lets teams add project-specific rules without recompiling engine validator code.

### [rules_toml.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/validator/rules_toml.rs)

- This file provides TOML-driven rule loading for data-defined validation extensions.
- It parses rule entries into runtime rule objects used by the validation engine.
- It supports loading from files and raw TOML text for flexible integration points.
- It enables configurable policy checks without adding new compiled rule types.
- It keeps external rule definitions deterministic so CI behavior remains reproducible.
