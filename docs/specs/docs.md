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

- The `docs` module treats documentation as an active engine-managed system rather than as a pile of disconnected markdown files.
- It builds and maintains a structured catalog of API knowledge, compares that catalog against what the engine actually exposes, and turns the result into actionable reports about missing, stale, or incomplete documentation.
- This matters because documentation quality drifts quickly in evolving codebases. Without a module like this, docs become passive artifacts that are only corrected sporadically instead of being continuously checked against source reality.
- The module acts as a bridge between implementation and publication by discovering what exists, validating whether it is described, and preparing that knowledge for several downstream consumers.
- Export paths are a major part of the feature. The same curated knowledge can be shaped into wiki-style outputs, editor hover text, completion data, machine-readable references, and other formats aimed at different readers and tools.
- Quality scoring, schema-oriented checks, and module-focused audits make the system practical for ongoing maintenance instead of occasional cleanup passes.
- This makes the module useful not only for publishing, but also for governance. Teams can spot undocumented APIs, stale wording, or inconsistent coverage before those gaps spread across several outputs.
- Other modules own behavior and signatures, but `docs` owns how that behavior is discovered, checked, cataloged, and published.
- Read `docs` as the coordination layer between engine reality and documentation output.


## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### catalog.rs

- `src/docs/catalog.rs` owns the in-memory catalog that stores, groups, searches, merges, and clears doc entries.
- It provides the collection boundary over `DocEntry`, preserving insertion order while exposing module and kind queries.
- Merge and lookup behavior live here so export and reporting stages can share one consistent documentation container.
- Read it when catalog search, deduplication, module grouping, or entry aggregation behavior needs to change.

### entry.rs

- `src/docs/entry.rs` defines normalized documentation records for API symbols, parameters, returns, and metadata.
- It owns `DocEntry`, `ParamInfo`, and `ReturnInfo`, plus completeness helpers used by docs quality checks and exports.
- This file is the in-memory record contract for the docs pipeline; it does not own catalogs, export, or scoring logic.
- Read it when docs field requirements, entry completeness rules, or symbol metadata shape needs to change.

### export.rs

- `src/docs/export.rs` transforms normalized doc entries into JSON payloads for completions, hovers, and signatures.
- It owns completion-kind mapping, hover and signature builders, pretty JSON writing, and bundled export directory output.
- Compact and richer payload variants are assembled here so IDE-facing consumers can choose size versus detail tradeoffs.
- This file is the serialization boundary for docs artifacts; it does not own entry collection or quality scoring.
- Read it when docs JSON shape, file output behavior, or editor integration payload rules need to change.

### mod.rs

- `src/docs/mod.rs` is the module index for documentation entries, catalogs, exports, reports, and schema reexports.
- It declares storage, record, export, validation, and schema files while keeping docs pipeline ownership explicit.
- This file reexports the main types and functions so tooling can consume the docs subsystem from one stable boundary.
- No catalog state or export logic lives here; it only defines visibility and the public module surface.
- Read this index first when tracing docs flow, because it shows where entry models end and output stages begin.
- Changes here affect reachability and API shape, not schema rules, quality scoring, or JSON export behavior.

### report.rs

- `src/docs/report.rs` evaluates documentation quality by scoring entries and aggregating validation-style issue reports.
- It owns per-entry score calculation, letter grades, validation buckets, module averages, and overall report synthesis.
- `ValidationReport` and `QualityReport` live here because issue tracking and score aggregation are linked outputs.
- This file analyzes existing `DocEntry` and `Catalog` data; it does not own entry storage or export serialization.
- Read it when docs grading policy, validation totals, or module quality rollup behavior needs to change.

### schema.rs

- `src/docs/schema.rs` reexports shared `lurek_schema` contracts used by the documentation pipeline and validators.
- It owns the docs-facing schema boundary so catalog, export, and report code depend on one stable import location.
- Read it when schema types, validator wiring, or docs-tool contracts need to change without touching downstream modules.



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
