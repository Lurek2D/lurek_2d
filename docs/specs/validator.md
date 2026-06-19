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

- The `validator` module is the content-checking surface for users who want assets, imports, and API usage to be verified as a structured workflow instead of informal manual review.
- Rule types, execution policy, engine orchestration, and report structures work together so several validation checks can be run through one reusable framework.
- That matters because a project often needs to catch different classes of mistakes, such as missing assets or invalid `lurek.*` usage, before those problems become runtime failures.
- It is therefore useful for CI, local authoring passes, and package or mod checks.
- Read it as the engine's validation coordinator. Individual rules know what they are checking, but `validator` owns how those rules are configured, executed, and reported.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### api_check.rs

- This file owns `ApiComplianceRule`, the validator check that scans Lua content for known `lurek.*` calls.
- It stores the allowlist of supported API prefixes and uses it to flag unknown namespaces at source lines.
- Default construction seeds built-in engine module names so projects get API drift detection without setup.
- The validate path searches textual call sites, extracts module segments, and emits structured warnings.
- Open this file when accepted public API names change; asset, import, and custom rule logic live in siblings.

### asset_check.rs

- This file owns `AssetExistenceRule`, the validator check that verifies referenced asset paths exist on disk.
- It stores the asset root and extracts string arguments from sprite, audio, font, and image load patterns.
- Validation joins discovered paths against the root, then emits error violations with concrete fix suggestions.
- Open this file when asset-reference patterns or path resolution policy changes; orchestration stays elsewhere.

### config.rs

- This file owns `ValidatorConfig`, the execution policy record that shapes how validator scans should run.
- It stores worker count, maximum file size, early-stop behavior, and hint inclusion defaults in one place.
- Open this file when validator runtime policy changes; rule logic and report formatting belong to siblings.

### engine.rs

- This file owns `ValidationEngine`, the orchestrator that assembles rule sets and runs them over Lua files.
- It stores root path, execution config, and registered rules, then delegates walking and parallel work to siblings.
- Builder-style helpers install built-in asset, import, API, Lua-pattern, and TOML-defined rule sources.
- Run methods cover whole-root scans, explicit file lists, and single-file checks while returning uniform reports.
- Open this file when validator orchestration changes; rules, reports, and file walking belong to siblings.

### import_check.rs

- This file owns `ImportResolutionRule`, the validator check that resolves Lua `require` targets against roots.
- It stores configured module paths and extracts import names from common `require(...)` and quoted shorthands.
- Resolution converts dotted module names into filesystem paths and accepts both file and init module layouts.
- Validation skips engine-provided `lurek.*` imports, then emits warnings for unresolved project dependencies.
- Open this file when module resolution policy changes; API checks and asset existence rules live in siblings.

### mod.rs

- This module re-exports the validator subsystem surface for rules, reports, config, execution, and extensions.
- It keeps navigation explicit by mapping which sibling files own API checks, asset checks, imports, and walkers.
- Public exports here route callers toward `ValidationEngine` for orchestration and `ValidatorConfig` for policy.
- `report.rs` owns severities and violation records, while `rule.rs` defines the trait every checker implements.
- `rules_lua.rs` and `rules_toml.rs` extend the subsystem with data-defined checks without engine call-site churn.
- Change this file when the validator symbol map moves; change siblings when scan behavior or rule logic changes.

### parallel.rs

- This file owns parallel validator helpers that collect candidate files and apply registered rules across them.
- It chunks file lists, runs worker threads with shared violation aggregation, and records elapsed report time.
- Directory walkers gather Lua files or arbitrary extensions while skipping hidden folders during recursion.
- Open this file when scan concurrency or file enumeration changes; rule semantics and report types live elsewhere.

### report.rs

- This file owns `Severity`, `Violation`, and `ValidationReport`, the typed result model for validator output.
- It stores rule identity, location, message, suggestion, aggregate counts, and elapsed time in stable records.
- Helper methods parse severity names, attach line or column metadata, and slice violations by file or level.
- The ordering on `Severity` defines how higher-level code decides whether a run is warning-only or errorful.
- Open this file when validator result semantics change; scan orchestration and concrete checks belong to siblings.

### rule.rs

- This file owns `ValidationRule`, the trait contract every validator check implements against file content.
- It defines the required rule identity, human description, default severity, and validation entrypoint shape.
- Open this file when rule plugin boundaries change; concrete checks, configs, and reports live in siblings.

### rules_lua.rs

- This file owns `LuaPatternRule`, the data-backed validator rule that turns simple patterns into violations.
- It stores rule id, description, search pattern, message, severity, and inversion mode for required checks.
- Validation either flags matching lines or emits one file-level violation when an expected pattern is absent.
- Open this file when custom rule behavior changes; TOML loading and engine registration live in siblings.

### rules_toml.rs

- This file owns TOML rule loading helpers that decode declarative validator rules into `LuaPatternRule` values.
- It parses `[[rule]]` sections, carries severity and invert flags forward, and builds rules without compilation.
- Loaders support both raw TOML text and on-disk files so validator setup can reuse one parsing path.
- The parser handles a narrow key syntax, keeping validation policy simple and predictable for project authors.
- Open this file when TOML rule schema changes; runtime pattern execution and report models live in siblings.



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
