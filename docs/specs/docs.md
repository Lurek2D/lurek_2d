# docs

## TL;DR

- Builds an API catalog to generate editor files and Markdown reference.
- Analyzes docs-general coverage and quality using live table reflection.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/docs/`
- Binding: `src/lua_api/docs_api.rs`
- Namespace: `lurek.docs`
- Lua API surface: `26` functions, `13` types, `60` methods
- Rust test path(s): tests/rust/unit/docs_tests.rs
- Lua test path(s): tests/lua/unit/test_docs.lua

## Summary

- This module gives users a documentation pipeline that can discover, validate, score, and export API knowledge.
- It builds a catalog of API entries that serves as a single source for docs and editor tooling outputs.
- Live reflection checks help detect drift between documented symbols and what the runtime actually exposes.
- Validation reports highlight missing, phantom, and incomplete entries so cleanup work is explicit.
- Quality scoring provides per-module and global signals for documentation health tracking.
- Exporters generate completion, hover, signature, and markdown artifacts for IDE and reference workflows.
- Catalog editing APIs allow targeted improvements without rebuilding the entire pipeline.
- Module-focused scanning supports incremental documentation work on large codebases.
- Schema support adds structured validation for doc-linked configuration and table contracts.
- This module helps teams keep docs useful as APIs evolve across frequent engine changes.
- It reduces stale references by tying documentation checks to runtime reflection.
- For extension authors, it provides machine-readable outputs ready for integration.
- For maintainers, it centralizes quality evidence instead of scattered manual checks.
- Users can automate doc freshness and coverage checks directly in scripting workflows.
- The practical value is higher confidence that docs match runtime behavior.
- It also shortens the path from API change to updated editor assistance.
- In short, this module treats documentation as a maintained system, not static prose.
- That improves onboarding, discoverability, and long-term maintainability.
- Teams gain repeatable documentation governance with actionable diagnostics.
- The result is clearer API communication with less manual coordination overhead.

This module is mostly self-contained inside the Edge/Integration group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### catalog.rs

- Provides the in-memory documentation catalog used to collect and organize normalized API entries. `docs/catalog` delivers the catalog implementation for the docs subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Preserves insertion order while supporting grouping, filtering, and lookup across module boundaries. The file owns or coordinates data contracts including `Catalog`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Enables merge and dedup workflows for combining multiple documentation sources into one view. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `from_entries`, `add`, `modules`, `all_entries`, `entries_for_module`, and 6 more stays attached to the local data model and invariants.
- Delivers the central container that feeds both export generation and quality analysis stages. Runtime integration reaches sibling engine areas through crate modules `docs`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### entry.rs

- Provides normalized documentation record types that represent public API symbols and their metadata. `docs/entry` delivers the entry implementation for the docs subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Models parameter and return descriptors so downstream export and reporting stages share one data shape. The file owns or coordinates data contracts including `ParamInfo`, `ReturnInfo`, `DocEntry`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Includes completeness checks that help quality tooling detect thin or malformed documentation entries. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `is_complete`, `missing_fields` stays attached to the local data model and invariants.
- Delivers the common in-memory contract used across collection, transformation, and reporting flows. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### export.rs

- Provides export builders that transform normalized doc entries into IDE-oriented JSON payloads. `docs/export` delivers the export implementation for the docs subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Produces completion, hover, and signature datasets in shapes tailored to extension and tooling consumers. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supports compact or rich payload modes to match different integration and footprint constraints. Public callable behavior is centered on `export_completions`, `export_hover`, `export_signatures`, `export_all`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Writes single or bundled artifacts through stable serialization paths for predictable output handling. Runtime integration reaches sibling engine areas through crate modules `docs`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### mod.rs

- Provides the top-level documentation module surface that connects collection, schema, export, and reporting stages. `docs/mod` is the docs module index, declaring `catalog`, `entry`, `export`, `report`, `schema` so agents can identify which files own each feature slice before opening implementation code.
- Centralizes re-exports so tooling callers can consume doc pipeline capabilities from one stable integration point. `src/docs/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `catalog::Catalog`, `entry::{DocEntry, ParamInfo, ReturnInfo}`, `export::{export_all, export_completions, export_hover, export_signatures}`, `report::{quality_grade, quality_score, QualityReport, ValidationReport}`, and 1 more centralized for the docs subsystem.

### report.rs

- Provides documentation quality evaluation logic that scores completeness and classifies report grades. `docs/report` delivers the report implementation for the docs subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Validates catalog integrity by tracking missing, phantom, and incomplete documentation records. The file owns or coordinates data contracts including `ValidationReport`, `QualityReport`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Aggregates per-entry and per-module metrics into actionable quality snapshots for maintainers. Public callable behavior is centered on `quality_score`, `quality_grade`, while method-level behavior such as `new`, `is_clean`, `total_issues`, `compute`, `module_grade`, `from_entries` stays attached to the local data model and invariants.
- Supports both full-catalog analysis and direct entry-based reporting for flexible pipeline usage. Runtime integration reaches sibling engine areas through crate modules `docs`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### schema.rs

- Provides the schema bridge that exposes shared validation contracts used by the docs pipeline. `docs/schema` delivers the schema implementation for the docs subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.



## Lua API Ref

### Functions

- `lurek.docs.checkStaleness(catalog_ud, source_dir) -> table`: Lists source files in a directory for simple documentation staleness checks.
- `lurek.docs.coverage(catalog_ud?) -> integer`: Returns documented and live API counts for the full `lurek` table.
- `lurek.docs.coverageModule(module_name, catalog_ud?) -> integer`: Returns documented and live API counts for one module.
- `lurek.docs.describe(qualified_name, description) -> nil`: Adds or updates the description for one editable catalog entry.
- `lurek.docs.exportAll(catalog_ud, output_dir) -> nil`: Exports all editor documentation artifacts for a catalog into a directory.
- `lurek.docs.exportCheatsheet(catalog_ud, path) -> nil`: Writes a compact text cheatsheet from catalog entries.
- `lurek.docs.exportCompletions(catalog_ud, path) -> nil`: Exports catalog completion metadata to a file.
- `lurek.docs.exportHover(catalog_ud, path) -> nil`: Exports catalog hover metadata to a file.
- `lurek.docs.exportMarkdown(catalog_ud, path) -> nil`: Writes a Markdown API reference from catalog entries.
- `lurek.docs.exportSignatures(catalog_ud, path) -> nil`: Exports catalog signature metadata to a file.
- `lurek.docs.getCatalog() -> LApiCatalog`: Returns the editable in-memory documentation catalog.
- `lurek.docs.loadAll(directory) -> LApiCatalog`: Loads all TOML documentation catalog files from a directory and combines their entries.
- `lurek.docs.loadToml(path) -> LApiCatalog`: Loads a TOML documentation catalog file and converts its entries into an API catalog.
- `lurek.docs.quality(catalog_ud?) -> LQualityReport`: Computes documentation quality for a supplied catalog or the editable in-memory catalog.
- `lurek.docs.qualityModule(module_name, catalog_ud?) -> LQualityReport`: Computes documentation quality for entries belonging to one module.
- `lurek.docs.reflectLive(ns?) -> table`: Reflects live `lurek` module tables into plain name and type rows.
- `lurek.docs.reflectTable(tbl, name?) -> table`: Reflects an arbitrary Lua table into name, qualifiedName, and type rows.
- `lurek.docs.resetCatalog() -> nil`: Clears the editable in-memory documentation catalog.
- `lurek.docs.scan(opts?) -> LApiCatalog`: Reflects the live `lurek` table and builds a catalog of callable APIs.
- `lurek.docs.scanModule(module_name) -> LApiCatalog`: Reflects one live `lurek.<module>` table and builds a catalog for that module.
- `lurek.docs.schema(rules, name?) -> LSchema`: Builds a schema validator from Lua table rules.
- `lurek.docs.schemaFromToml(toml_text) -> LSchema`: Builds a schema validator from TOML schema text.
- `lurek.docs.setParamInfo(qualified_name, params) -> nil`: Replaces parameter metadata for one editable catalog entry.
- `lurek.docs.setReturnInfo(qualified_name, returns) -> nil`: Replaces return-value metadata for one editable catalog entry.
- `lurek.docs.validate(catalog_ud?) -> LValidationReport`: Compares a documentation catalog with the live reflected `lurek` API table.
- `lurek.docs.validateModule(module_name, catalog_ud?) -> LValidationReport`: Compares one module's documentation catalog entries with the live reflected module table.

### Callbacks

- `LApiCatalog:filter` param `predicate` (`function`): Callback called with each `LDocEntry`; truthy return keeps the entry.

### Enums

- No documented module-level enums/constants.

### Types

#### LApiCatalog Type

- Provides Lua methods for querying, merging, filtering, and exporting catalog data.

##### Fields

- No documented fields.

##### Methods

- `LApiCatalog:entryCount(module?) -> integer`: Counts entries in the catalog, optionally for one module.
- `LApiCatalog:filter(predicate) -> LApiCatalog`: Builds a new catalog containing entries accepted by a Lua predicate.
- `LApiCatalog:getEntries(module?) -> LDocEntry[]`: Returns catalog entries, optionally limited to one module.
- `LApiCatalog:getEntry(qualified_name) -> LDocEntry`: Returns one catalog entry by qualified API name.
- `LApiCatalog:getModules() -> string[]`: Returns every module represented in this catalog.
- `LApiCatalog:getTypeMethods(qualified_name) -> LDocEntry[]`: Returns method entries associated with a qualified type name.
- `LApiCatalog:getTypes(module_name) -> string[]`: Returns type names documented for one module.
- `LApiCatalog:merge(other) -> LApiCatalog`: Merges another catalog into this catalog and returns a new catalog value.
- `LApiCatalog:search(query) -> LDocEntry[]`: Searches names, qualified names, and descriptions with a case-insensitive substring query.
- `LApiCatalog:toJSON() -> string`: Serializes this catalog to formatted JSON.
- `LApiCatalog:toTable() -> table`: Converts this catalog into plain Lua tables for lightweight inspection.
- `LApiCatalog:type() -> string`: Returns the Lua-visible type name for this API catalog handle.
- `LApiCatalog:typeOf(name) -> boolean`: Returns whether this API catalog handle matches a supported type name.

#### LApiCatalogToTableResult Type

- Generated result shape from @field tags.

##### Fields

- `description` (`string`): Symbol description.
- `kind` (`string`): Symbol kind.
- `module` (`string`): Module name.
- `name` (`string`): Symbol name.
- `qualifiedName` (`string`): Fully qualified name.
- `score` (`number`): Relevance score.

##### Methods

- No documented methods.

#### LDocEntry Type

- Provides Lua accessors for documentation entry metadata.

##### Fields

- No documented fields.

##### Methods

- `LDocEntry:getDeprecated() -> LuaValue`: Returns this entry's deprecation text when one was recorded.
- `LDocEntry:getDescription() -> string`: Returns the prose description recorded for this entry.
- `LDocEntry:getExample() -> LuaValue`: Returns this entry's example text when one was recorded.
- `LDocEntry:getKind() -> string`: Returns the documentation kind recorded for this entry.
- `LDocEntry:getModule() -> string`: Returns the module name associated with this documentation entry.
- `LDocEntry:getName() -> string`: Returns the short API name stored by this documentation entry.
- `LDocEntry:getParameters() -> table`: Returns parameter metadata recorded for this entry.
- `LDocEntry:getQualifiedName() -> string`: Returns the full dotted API name stored by this documentation entry.
- `LDocEntry:getReturns() -> table`: Returns return-value metadata recorded for this entry.
- `LDocEntry:getScore() -> number`: Returns the documentation quality score calculated for this entry.
- `LDocEntry:getSince() -> LuaValue`: Returns this entry's since-version text when one was recorded.
- `LDocEntry:hasDescription() -> boolean`: Returns whether this entry has non-empty description text.
- `LDocEntry:hasExample() -> boolean`: Returns whether this entry has example text.
- `LDocEntry:hasParameters() -> boolean`: Returns whether this entry has parameter metadata.
- `LDocEntry:hasReturnType() -> boolean`: Returns whether this entry has return-value metadata.
- `LDocEntry:type() -> string`: Returns the Lua-visible type name for this documentation entry handle.
- `LDocEntry:typeOf(name) -> boolean`: Returns whether this documentation entry handle matches a supported type name.

#### LDocEntryGetParametersResult Type

- Generated result shape from @field tags.

##### Fields

- `default` (`string?`): Default value when present.
- `description` (`string`): Parameter description.
- `name` (`string`): Parameter name.
- `optional` (`boolean`): Whether the parameter is optional.
- `type` (`string`): Parameter type.

##### Methods

- No documented methods.

#### LDocEntryGetReturnsResult Type

- Generated result shape from @field tags.

##### Fields

- `description` (`string`): Return description.
- `type` (`string`): Return type.

##### Methods

- No documented methods.

#### LDocsCheckStalenessResult Type

- Generated result shape from @field tags.

##### Fields

- `current` (`string[]`): Current file paths.
- `missing` (`string[]`): Missing file paths.
- `stale` (`string[]`): Stale file paths.

##### Methods

- No documented methods.

#### LDocsReflectTableResult Type

- Generated result shape from @field tags.

##### Fields

- `name` (`string`): Item name.
- `qualifiedName` (`string`): Fully qualified name.
- `type` (`string`): Item type.

##### Methods

- No documented methods.

#### LQualityReport Type

- Provides Lua accessors for documentation quality scoring results.

##### Fields

- No documented fields.

##### Methods

- `LQualityReport:getBest(count?) -> LDocEntry[]`: Returns the highest-scoring documentation entries.
- `LQualityReport:getByGrade(grade) -> LDocEntry[]`: Returns documentation entries whose calculated grade matches a grade string.
- `LQualityReport:getGrade() -> string`: Returns the letter grade derived from the aggregate documentation score.
- `LQualityReport:getModuleScores() -> table`: Returns per-module documentation quality scores.
- `LQualityReport:getOverallScore() -> number`: Returns the aggregate documentation quality score.
- `LQualityReport:getSummary() -> string`: Returns a human-readable summary of overall and per-module quality scores.
- `LQualityReport:getWorst(count?) -> LDocEntry[]`: Returns the lowest-scoring documentation entries.
- `LQualityReport:toJSON() -> string`: Serializes this quality report to formatted JSON.
- `LQualityReport:toTable() -> table`: Converts this quality report into a plain Lua table.
- `LQualityReport:type() -> string`: Returns the Lua-visible type name for this quality report handle.
- `LQualityReport:typeOf(name) -> boolean`: Returns whether this quality report handle matches a supported type name.

#### LQualityReportToTableResult Type

- Generated result shape from @field tags.

##### Fields

- `grade` (`string`): Quality grade letter.
- `moduleScores` (`table`): Per-module score table.
- `overallScore` (`number`): Overall quality score.

##### Methods

- No documented methods.

#### LSchema Type

- Lua-side schema validator built from docs field rules.

##### Fields

- No documented fields.

##### Methods

- `LSchema:assert(data) -> nil`: Validates a Lua table and raises a Lua error when schema checks fail.
- `LSchema:check(data) -> boolean`: Validates a Lua table and returns only the boolean result.
- `LSchema:getFields() -> string[]`: Returns the field names declared by this schema.
- `LSchema:getName() -> string`: Returns this schema's display name.
- `LSchema:type() -> string`: Returns the Lua-visible type name for this schema handle.
- `LSchema:typeOf(name) -> boolean`: Returns whether this schema handle matches a supported type name.
- `LSchema:validate(data) -> boolean`: Validates a Lua table and returns a success flag plus structured error rows.

#### LSchemaValidateResult Type

- Generated result shape from @field tags.

##### Fields

- `field` (`string`): Field name that failed validation.
- `message` (`string`): Validation error message.

##### Methods

- No documented methods.

#### LValidationReport Type

- Provides Lua accessors for documentation validation results.

##### Fields

- No documented fields.

##### Methods

- `LValidationReport:getIncomplete() -> string[]`: Returns catalog APIs whose documentation was incomplete.
- `LValidationReport:getMissing() -> string[]`: Returns live APIs that were missing from the checked catalog.
- `LValidationReport:getPhantom() -> string[]`: Returns catalog APIs that were not present in the live Lua table.
- `LValidationReport:getSummary() -> string`: Returns a compact text summary of missing, phantom, and incomplete counts.
- `LValidationReport:incompleteCount() -> integer`: Returns the number of catalog APIs with incomplete documentation.
- `LValidationReport:isValid() -> boolean`: Returns whether the validation report has no missing live APIs.
- `LValidationReport:missingCount() -> integer`: Returns the number of live APIs missing from the catalog.
- `LValidationReport:phantomCount() -> integer`: Returns the number of catalog APIs absent from live reflection.
- `LValidationReport:toJSON() -> string`: Serializes this validation report to formatted JSON.
- `LValidationReport:toTable() -> table`: Converts this validation report into a plain Lua table.
- `LValidationReport:type() -> string`: Returns the Lua-visible type name for this validation report handle.
- `LValidationReport:typeOf(name) -> boolean`: Returns whether this validation report handle matches a supported type name.

#### LValidationReportToTableResult Type

- Generated result shape from @field tags.

##### Fields

- `incomplete` (`string[]`): Incomplete symbols.
- `missing` (`string[]`): Missing symbols.
- `phantom` (`string[]`): Phantom symbols.

##### Methods

- No documented methods.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- No additional module-specific notes.
