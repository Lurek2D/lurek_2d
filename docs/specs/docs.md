# docs

## TL;DR

- The `docs` module is the documentation pipeline core: collect API entries, validate quality, and export editor-ready artifacts like completions, hover, and signatures.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/docs/`
- Binding: `src/lua_api/docs_api.rs`
- Namespace: `lurek.docs`
- Lua API surface: `26` functions, `13` types, `60` methods
- Rust test path(s): tests/rust/unit/docs_tests.rs
- Lua test path(s): tests/lua/unit/test_docs.lua

## Summary

The `docs` module is the internal documentation pipeline for engine-facing metadata. It transforms raw API records into validated outputs that editor tooling and reporting workflows can consume directly.

Its main value is one shared data model from start to finish. Catalog collection, schema checks, quality scoring, and export generation all operate on the same normalized entry shape. This keeps completions, hover content, signatures, and reports aligned instead of drifting between separate tools.

Quality control is built into the workflow. The module can detect missing entries, thin descriptions, and catalog inconsistencies before artifacts are published. That gives maintainers a clear feedback loop and helps catch documentation debt early.

Export builders produce deterministic output structures for downstream consumers. Stable payload shapes improve reliability for extension integration, local development tasks, and CI validation because readers can depend on predictable contract formats.

The module supports both full-catalog and scoped operations, so teams can process one module or the entire API surface as needed. This is useful for incremental updates, focused audits, and release preparation workflows.

In practice, `lurek.docs` is the backbone that turns source metadata into consistent documentation assets: collect entries, validate quality, generate artifacts, and publish tooling-ready outputs through one coherent module boundary.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### catalog.rs

- Provides the in-memory documentation catalog used to collect and organize normalized API entries.
- Preserves insertion order while supporting grouping, filtering, and lookup across module boundaries.
- Enables merge and dedup workflows for combining multiple documentation sources into one view.
- Delivers the central container that feeds both export generation and quality analysis stages.

### entry.rs

- Provides normalized documentation record types that represent public API symbols and their metadata.
- Models parameter and return descriptors so downstream export and reporting stages share one data shape.
- Includes completeness checks that help quality tooling detect thin or malformed documentation entries.
- Delivers the common in-memory contract used across collection, transformation, and reporting flows.

### export.rs

- Provides export builders that transform normalized doc entries into IDE-oriented JSON payloads.
- Produces completion, hover, and signature datasets in shapes tailored to extension and tooling consumers.
- Supports compact or rich payload modes to match different integration and footprint constraints.
- Writes single or bundled artifacts through stable serialization paths for predictable output handling.
- Delivers the final packaging stage that turns in-memory documentation into distributable files.

### mod.rs

- Provides the top-level documentation module surface that connects collection, schema, export, and reporting stages.
- Centralizes re-exports so tooling callers can consume doc pipeline capabilities from one stable integration point.
- Delivers a coherent module boundary for transforming source metadata into validated documentation artifacts.

### report.rs

- Provides documentation quality evaluation logic that scores completeness and classifies report grades.
- Validates catalog integrity by tracking missing, phantom, and incomplete documentation records.
- Aggregates per-entry and per-module metrics into actionable quality snapshots for maintainers.
- Supports both full-catalog analysis and direct entry-based reporting for flexible pipeline usage.
- Delivers consistent quality signals that guide doc cleanup and release readiness checks.

### schema.rs

- Provides the schema bridge that exposes shared validation contracts used by the docs pipeline.
- Connects documentation tooling with canonical field and type rules defined in the schema crate.
- Delivers one access point that keeps schema usage consistent across docs modules.

## Lua API Ref

### Functions

- `lurek.docs.checkStaleness`: Lists source files in a directory for simple documentation staleness checks.
- `lurek.docs.coverage`: Returns documented and live API counts for the full `lurek` table.
- `lurek.docs.coverageModule`: Returns documented and live API counts for one module.
- `lurek.docs.describe`: Adds or updates the description for one editable catalog entry.
- `lurek.docs.exportAll`: Exports all editor documentation artifacts for a catalog into a directory.
- `lurek.docs.exportCheatsheet`: Writes a compact text cheatsheet from catalog entries.
- `lurek.docs.exportCompletions`: Exports catalog completion metadata to a file.
- `lurek.docs.exportHover`: Exports catalog hover metadata to a file.
- `lurek.docs.exportMarkdown`: Writes a Markdown API reference from catalog entries.
- `lurek.docs.exportSignatures`: Exports catalog signature metadata to a file.
- `lurek.docs.getCatalog`: Returns the editable in-memory documentation catalog.
- `lurek.docs.loadAll`: Loads all TOML documentation catalog files from a directory and combines their entries.
- `lurek.docs.loadToml`: Loads a TOML documentation catalog file and converts its entries into an API catalog.
- `lurek.docs.quality`: Computes documentation quality for a supplied catalog or the editable in-memory catalog.
- `lurek.docs.qualityModule`: Computes documentation quality for entries belonging to one module.
- `lurek.docs.reflectLive`: Reflects live `lurek` module tables into plain name and type rows.
- `lurek.docs.reflectTable`: Reflects an arbitrary Lua table into name, qualifiedName, and type rows.
- `lurek.docs.resetCatalog`: Clears the editable in-memory documentation catalog.
- `lurek.docs.scan`: Reflects the live `lurek` table and builds a catalog of callable APIs.
- `lurek.docs.scanModule`: Reflects one live `lurek.<module>` table and builds a catalog for that module.
- `lurek.docs.schema`: Builds a schema validator from Lua table rules.
- `lurek.docs.schemaFromToml`: Builds a schema validator from TOML schema text.
- `lurek.docs.setParamInfo`: Replaces parameter metadata for one editable catalog entry.
- `lurek.docs.setReturnInfo`: Replaces return-value metadata for one editable catalog entry.
- `lurek.docs.validate`: Compares a documentation catalog with the live reflected `lurek` API table.
- `lurek.docs.validateModule`: Compares one module's documentation catalog entries with the live reflected module table.

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

- `LApiCatalog:entryCount`: Counts entries in the catalog, optionally for one module.
- `LApiCatalog:filter`: Builds a new catalog containing entries accepted by a Lua predicate.
- `LApiCatalog:getEntries`: Returns catalog entries, optionally limited to one module.
- `LApiCatalog:getEntry`: Returns one catalog entry by qualified API name.
- `LApiCatalog:getModules`: Returns every module represented in this catalog.
- `LApiCatalog:getTypeMethods`: Returns method entries associated with a qualified type name.
- `LApiCatalog:getTypes`: Returns type names documented for one module.
- `LApiCatalog:merge`: Merges another catalog into this catalog and returns a new catalog value.
- `LApiCatalog:search`: Searches names, qualified names, and descriptions with a case-insensitive substring query.
- `LApiCatalog:toJSON`: Serializes this catalog to formatted JSON.
- `LApiCatalog:toTable`: Converts this catalog into plain Lua tables for lightweight inspection.
- `LApiCatalog:type`: Returns the Lua-visible type name for this API catalog handle.
- `LApiCatalog:typeOf`: Returns whether this API catalog handle matches a supported type name.

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

- `LDocEntry:getDeprecated`: Returns this entry's deprecation text when one was recorded.
- `LDocEntry:getDescription`: Returns the prose description recorded for this entry.
- `LDocEntry:getExample`: Returns this entry's example text when one was recorded.
- `LDocEntry:getKind`: Returns the documentation kind recorded for this entry.
- `LDocEntry:getModule`: Returns the module name associated with this documentation entry.
- `LDocEntry:getName`: Returns the short API name stored by this documentation entry.
- `LDocEntry:getParameters`: Returns parameter metadata recorded for this entry.
- `LDocEntry:getQualifiedName`: Returns the full dotted API name stored by this documentation entry.
- `LDocEntry:getReturns`: Returns return-value metadata recorded for this entry.
- `LDocEntry:getScore`: Returns the documentation quality score calculated for this entry.
- `LDocEntry:getSince`: Returns this entry's since-version text when one was recorded.
- `LDocEntry:hasDescription`: Returns whether this entry has non-empty description text.
- `LDocEntry:hasExample`: Returns whether this entry has example text.
- `LDocEntry:hasParameters`: Returns whether this entry has parameter metadata.
- `LDocEntry:hasReturnType`: Returns whether this entry has return-value metadata.
- `LDocEntry:type`: Returns the Lua-visible type name for this documentation entry handle.
- `LDocEntry:typeOf`: Returns whether this documentation entry handle matches a supported type name.

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

- `LQualityReport:getBest`: Returns the highest-scoring documentation entries.
- `LQualityReport:getByGrade`: Returns documentation entries whose calculated grade matches a grade string.
- `LQualityReport:getGrade`: Returns the letter grade derived from the aggregate documentation score.
- `LQualityReport:getModuleScores`: Returns per-module documentation quality scores.
- `LQualityReport:getOverallScore`: Returns the aggregate documentation quality score.
- `LQualityReport:getSummary`: Returns a human-readable summary of overall and per-module quality scores.
- `LQualityReport:getWorst`: Returns the lowest-scoring documentation entries.
- `LQualityReport:toJSON`: Serializes this quality report to formatted JSON.
- `LQualityReport:toTable`: Converts this quality report into a plain Lua table.
- `LQualityReport:type`: Returns the Lua-visible type name for this quality report handle.
- `LQualityReport:typeOf`: Returns whether this quality report handle matches a supported type name.

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

- `LSchema:assert`: Validates a Lua table and raises a Lua error when schema checks fail.
- `LSchema:check`: Validates a Lua table and returns only the boolean result.
- `LSchema:getFields`: Returns the field names declared by this schema.
- `LSchema:getName`: Returns this schema's display name.
- `LSchema:type`: Returns the Lua-visible type name for this schema handle.
- `LSchema:typeOf`: Returns whether this schema handle matches a supported type name.
- `LSchema:validate`: Validates a Lua table and returns a success flag plus structured error rows.

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

- `LValidationReport:getIncomplete`: Returns catalog APIs whose documentation was incomplete.
- `LValidationReport:getMissing`: Returns live APIs that were missing from the checked catalog.
- `LValidationReport:getPhantom`: Returns catalog APIs that were not present in the live Lua table.
- `LValidationReport:getSummary`: Returns a compact text summary of missing, phantom, and incomplete counts.
- `LValidationReport:incompleteCount`: Returns the number of catalog APIs with incomplete documentation.
- `LValidationReport:isValid`: Returns whether the validation report has no missing live APIs.
- `LValidationReport:missingCount`: Returns the number of live APIs missing from the catalog.
- `LValidationReport:phantomCount`: Returns the number of catalog APIs absent from live reflection.
- `LValidationReport:toJSON`: Serializes this validation report to formatted JSON.
- `LValidationReport:toTable`: Converts this validation report into a plain Lua table.
- `LValidationReport:type`: Returns the Lua-visible type name for this validation report handle.
- `LValidationReport:typeOf`: Returns whether this validation report handle matches a supported type name.

#### LValidationReportToTableResult Type

- Generated result shape from @field tags.

##### Fields

- `incomplete` (`string[]`): Incomplete symbols.
- `missing` (`string[]`): Missing symbols.
- `phantom` (`string[]`): Phantom symbols.

##### Methods

- No documented methods.

