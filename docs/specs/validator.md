# validator

## TL;DR

- Static validator verifying APIs, assets, and imports.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/validator/`
- Binding: `src/lua_api/validator_api.rs`
- Namespace: `lurek.validator`
- Lua API surface: `3` functions, `1` types, `9` methods
- Rust test path(s): None found in the workspace
- Lua test path(s): tests/lua/unit/test_validator_unit.lua

## Summary

- The validator module provides static pre-runtime checks for Lua project quality.
- It runs composable rules through a central validation engine.
- Built-in checks cover API usage, import resolution, and asset path existence.
- Violations include severity, location, identifier, and human-readable message.
- Report models support filtering and summary views for large result sets.
- Parallel execution support improves throughput on large script sets.
- Single-thread fallback preserves predictable behavior in constrained environments.
- TOML-defined rules support data-driven policy extension.
- Lua-backed rule adapters support project-specific checks without engine rebuild.
- The module performs static analysis only and does not execute scripts.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### api_check.rs

- This file provides API compliance validation for Lua calls targeting the lurek namespace. `validator/api_check` delivers the api check implementation for the validator subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- It scans call sites against registered signatures to catch unknown endpoints early. The file owns or coordinates data contracts including `ApiComplianceRule`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- It detects argument-shape mismatches that often signal migration or integration drift. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `with_defaults` stays attached to the local data model and invariants.
- It emits structured violations with location data for actionable feedback in pipelines. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### asset_check.rs

- This file provides static asset path validation for script references to game resources. `validator/asset_check` delivers the asset check implementation for the validator subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- It finds load-site path strings and checks their existence against the configured root. The file owns or coordinates data contracts including `AssetExistenceRule`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- It reports missing files before runtime so broken builds fail early and clearly. Public callable behavior is centered on no named public items, while method-level behavior such as `new` stays attached to the local data model and invariants.
- It integrates with validator runs used by both local checks and CI quality gates. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### config.rs

- This file provides configuration structures that shape validator execution policy. `validator/config` delivers the configuration schema and defaults for the validator subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

### engine.rs

- This file provides the validation orchestrator that runs rule sets over project content. `validator/engine` delivers the engine implementation for the validator subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- It composes built-in and custom rules into one execution plan shaped by config. The file owns or coordinates data contracts including `ValidationEngine`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- It dispatches checks across files and aggregates findings into structured reports. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `add_asset_rule`, `add_import_rule`, `add_api_rule`, `add_pattern_rule`, `load_toml_rules`, and 5 more stays attached to the local data model and invariants.
- It serves as the main engine entry used by runtime tooling and validation commands. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### import_check.rs

- This file provides import resolution checks for Lua require targets in project scripts. `validator/import_check` delivers the import check implementation for the validator subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- It scans textual require patterns and resolves module paths against configured lookup roots. The file owns or coordinates data contracts including `ImportResolutionRule`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- It surfaces missing dependencies before runtime to reduce integration surprises. Public callable behavior is centered on no named public items, while method-level behavior such as `new` stays attached to the local data model and invariants.
- It keeps the check static and safe by avoiding script execution during analysis. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### mod.rs

- This module delivers the validation surface for script content, assets, imports, and API usage. `validator/mod` is the validator module index, declaring `api_check`, `asset_check`, `config`, `engine`, `import_check`, and 5 more so agents can identify which files own each feature slice before opening implementation code.
- It combines built-in and custom rule paths into one extensible quality-check pipeline. `src/validator/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `config::ValidatorConfig`, `engine::ValidationEngine`, `report::{Severity, ValidationReport, Violation}`, `rule::ValidationRule` centralized for the validator subsystem.

### parallel.rs

- This file provides parallel execution plumbing for validator rule application across files. `validator/parallel` delivers the parallel implementation for the validator subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- It enumerates candidate inputs and partitions work over worker threads efficiently. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- It merges per-file violations into unified reports without unstable ordering surprises. Public callable behavior is centered on `validate_parallel`, `collect_lua_files`, `collect_files_with_ext`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- It supports configurable thread control, including single-thread fallback execution. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### report.rs

- This file provides typed report models for storing and presenting validation outcomes. `validator/report` delivers the report implementation for the validator subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- It defines violation records with severity, location, identity, and human-readable message. The file owns or coordinates data contracts including `Severity`, `Violation`, `ValidationReport`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- It supports filtering and summary views so large result sets remain actionable. Public callable behavior is centered on no named public items, while method-level behavior such as `from_name`, `as_str`, `new`, `with_line`, `with_column`, `with_suggestion`, and 7 more stays attached to the local data model and invariants.
- It standardizes severity ordering for consistent thresholding and pipeline behavior. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### rule.rs

- This file provides the rule trait contract that all validator checks implement. `validator/rule` delivers the rule implementation for the validator subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

### rules_lua.rs

- This file provides Lua-backed custom rule adapters for extending validator coverage. `validator/rules_lua` delivers the rules lua implementation for the validator subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- It stores pattern and callback metadata that bridges script-defined checks into Rust flow. The file owns or coordinates data contracts including `LuaPatternRule`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- It converts callback outputs into typed violations compatible with native reporting. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `set_invert` stays attached to the local data model and invariants.
- It lets teams add project-specific rules without recompiling engine validator code. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### rules_toml.rs

- This file provides TOML-driven rule loading for data-defined validation extensions. `validator/rules_toml` delivers the rules toml implementation for the validator subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- It parses rule entries into runtime rule objects used by the validation engine. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- It supports loading from files and raw TOML text for flexible integration points. Public callable behavior is centered on `load_rules_from_toml`, `load_rules_from_file`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- It enables configurable policy checks without adding new compiled rule types. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.



## Lua API Ref

### Functions

- `lurek.validator.newEngine(root) -> LValidationEngine`: Creates a new validation engine rooted at the given filesystem path.
- `lurek.validator.validate(path) -> table`: Runs all validation rules against a project root directory and returns a report table.
- `lurek.validator.validateFile(path) -> table`: Runs API validation rules against a single Lua file and returns a report table.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LValidationEngine Type

- Lua userdata that runs schema and constraint validation on data tables and files.

##### Fields

- No documented fields.

##### Methods

- `LValidationEngine:addApiRule() -> nil`: Add the built-in API compliance rule.
- `LValidationEngine:addAssetRule(asset_root) -> nil`: Add the built-in asset existence rule.
- `LValidationEngine:addImportRule(paths) -> nil`: Add the built-in import resolution rule.
- `LValidationEngine:addPatternRule(id, pattern, message, severity) -> nil`: Add a custom regex pattern rule to the validation engine.
- `LValidationEngine:addRequiredRule(id, pattern, message) -> nil`: Add a required pattern rule (violation if pattern NOT found).
- `LValidationEngine:loadTomlRules(path) -> nil`: Load validation rules from a TOML-formatted rule file.
- `LValidationEngine:ruleCount() -> integer`: Get number of loaded rules for this object.
- `LValidationEngine:run() -> table`: Run validation against all Lua files under root.
- `LValidationEngine:runFile(path) -> table`: Run validation against a single file.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- No additional module-specific notes.
