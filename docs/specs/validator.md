# validator

## TL;DR

- The `validator` module is a parallel, rule-based static analysis engine for Lua game scripts with built-in checks for asset existence, import resolution, and API compliance.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/validator/`
- Lua API path(s): `src/lua_api/validator_api.rs`
- Primary Lua namespace: `lurek.validator`
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

The `validator` module equips developers and CI pipelines with a structured static analysis engine for Lua game scripts. The central `ValidationEngine` is configured via `ValidatorConfig` (deserialized from a `[validator]` TOML block) and orchestrates a set of `ValidationRule` implementations over a file tree in parallel using a Rayon worker pool. Thread count defaults to the configured value; 0 forces synchronous single-threaded mode.

Three built-in rule types cover the most common correctness checks. The `ApiComplianceRule` inspects each `lurek.*` call site against an `ApiRegistry` loaded at startup, flagging unknown function names as `Severity::Error` and wrong argument counts as `Severity::Warning`. The `AssetExistenceRule` pattern-matches `lurek.asset.load("path")` calls and verifies each path via `GameFS::exists` without decoding the asset — missing files produce errors, likely typos produce warnings. The `ImportResolutionRule` scans for `require("path")` calls via regex, resolving each against the game's configured `lua_paths` to catch missing module files before runtime.

Beyond built-in rules, the engine supports extensibility in two directions. TOML rule files (loaded via `load_rules_from_file`) specify `[[rule]]` arrays with pattern, severity, message, and optional file-extension filter — ideal for project-specific naming conventions or forbidden API patterns. Lua callbacks registered via `lurek.validator.add_rule` inject `LuaPatternRule` adapters, letting game teams write script-side rules without recompiling. Results are collected into a `ValidationReport` containing `Vec<Violation>` with file path, line number, severity, and an optional suggestion string. The `lurek.validator.*` API exposes engine creation, rule registration, single-file and tree-wide validation runs, and report display.

## Files

### api_check.rs

- Mod API compliance checker: validates Lua scripts against registered type schemas.
- `ApiComplianceRule` inspects each `lurek.*` call site and checks argument types.
- Unknown function names produce a `Severity::Error`; wrong arg count is a `Warning`.
- Schema is loaded from `ApiRegistry` at engine startup; rules are stateless.
- Returns `Vec<Violation>` per file; violations include file path and line number.

### asset_check.rs

- Asset existence checker: validates that image, sound, and font paths in scripts exist.
- `AssetExistenceRule` pattern-matches `lurek.asset.load("path")` call sites.
- For each matched path string, checks presence via `GameFS::exists` (no I/O decode).
- Missing assets are reported as `Severity::Error`; path typos as `Warning`.
- Runs during `lurek.validator.run()` and the CI quality gate.

### config.rs

- Validator engine configuration: search paths, rule sets, and extension filters.
- `ValidatorConfig` is deserialized from `[validator]` TOML or constructed from Lua.
- `rules` is a list of rule module names; `"all"` enables every built-in rule.
- `include_paths` and `exclude_paths` scope which files are checked.
- `severity_threshold` controls which violations are returned (ignore Info, etc.).

### engine.rs

- Validation engine: orchestrates rule execution across file trees with parallel workers.
- `ValidationEngine` loads config, builds the rule set, and calls `parallel::validate_parallel`.
- Returns a `ValidationReport` aggregating all violations from all rules and files.
- Custom Lua rules registered via `lurek.validator.add_rule` are injected here.
- Used by `lurek.validator.run()` and the `python tools/validate/` quality gate.

### import_check.rs

- Lua import resolver: validates that all `require()` call targets exist on disk.
- `ImportCheckRule` scans Lua files for `require("path")` calls via regex.
- Each required path is resolved against the game's `lua_paths` config list.
- Missing modules produce a `Severity::Error`; conditional requires a `Warning`.
- Does not execute Lua; purely textual scan for safety and speed.

### mod.rs

- Asset and content validation engine.
- Asset existence checking (images, sounds, fonts referenced in scripts).
- Lua import resolution validation.
- Mod API compliance checking.
- Custom validation rules from Lua callbacks or TOML rule files.
- Parallel execution across file trees.
- Structured violation reports with severity and suggestions.

### parallel.rs

- Parallel file-tree runner: distributes validation rules across worker threads.
- `validate_parallel(files, rules, config)` runs rules concurrently via Rayon.
- `collect_lua_files` and `collect_files_with_ext` enumerate files before dispatch.
- Each worker applies all rules to its file slice; results are merged with no locks.
- Thread count is sourced from `ValidatorConfig`; 0 forces single-threaded mode.

### report.rs

- Structured violation report: aggregates, formats, and summarises validation results.
- `Violation` carries file path, line number, `Severity`, rule name, and message.
- `ValidationReport` holds `Vec<Violation>` and provides filter/sort helpers.
- `Severity` enum: `Info`, `Warning`, `Error` — ordered by increasing severity.
- `ValidationReport::display_summary()` prints a compact human-readable table.

### rule.rs

- Validation rule trait and standard built-in rule implementations.
- `ValidationRule` trait: `fn check(path, content) -> Vec<Violation>`.
- All built-in rules implement this trait; Lua custom rules are adapter-wrapped.
- Rules are stateless and `Send + Sync` so they can be used from any thread.
- The engine constructs the rule set once from config and reuses it across files.

### rules_lua.rs

- Lua-defined custom validation rules registered via pattern and callback config.
- `LuaPatternRule` wraps a Lua callback and a file-extension filter.
- Called from `validation_engine` with `(path, content)` as string arguments.
- Lua callback must return a table of `{line, severity, message}` entries.
- Custom rules run in the same validator pass as built-in rules; no ordering guarantee.

### rules_toml.rs

- TOML-file-defined validation rules: loaded and compiled from disk at engine startup.
- `load_rules_from_file` reads a `.toml` rule file and returns `Vec<Box<dyn ValidationRule>>`.
- `load_rules_from_toml` parses the TOML `[[rule]]` array directly from a string.
- Each rule entry specifies `pattern`, `severity`, `message`, and optional `extensions`.
- Loaded rules are appended to the engine rule set before the first validation run.

## Lua API Ref

- Binding: `src/lua_api/validator_api.rs`
- Namespace: `lurek.validator`

### Functions

- `lurek.validator.newEngine`: Creates a new validation engine rooted at the given filesystem path.
- `lurek.validator.validate`: Runs all validation rules against a project root directory and returns a report table.
- `lurek.validator.validateFile`: Runs API validation rules against a single Lua file and returns a report table.

### Enums

- No documented module-level enums/constants.

### Types


#### LValidationEngine Type


##### Fields

- No documented fields.

##### Methods

- `LValidationEngine:addApiRule`: Add the built-in API compliance rule.
- `LValidationEngine:addAssetRule`: Add the built-in asset existence rule.
- `LValidationEngine:addImportRule`: Add the built-in import resolution rule.
- `LValidationEngine:addPatternRule`: Add a custom regex pattern rule to the validation engine.
- `LValidationEngine:addRequiredRule`: Add a required pattern rule (violation if pattern NOT found).
- `LValidationEngine:loadTomlRules`: Load validation rules from a TOML-formatted rule file.
- `LValidationEngine:ruleCount`: Get number of loaded rules for this object.
- `LValidationEngine:run`: Run validation against all Lua files under root.
- `LValidationEngine:runFile`: Run validation against a single file.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.
