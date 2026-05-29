# docs

## TL;DR

- The `docs` module is an Edge/Integration tier component responsible for maintaining the engine's runtime documentation catalog.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/docs/`
- Lua API path(s): `src/lua_api/docs_api.rs`
- Primary Lua namespace: `lurek.docs`
- Rust test path(s): tests/rust/unit/docs_tests.rs
- Lua test path(s): tests/lua/unit/test_docs.lua

## Summary

The `docs` module is the structured documentation infrastructure layer used by generation and tooling pipelines. It defines normalized doc entry models, catalog/query behavior, export builders, validation reporting, and schema contracts, then re-exports these surfaces for higher-level tooling commands.

`catalog` manages storage and lookup of documentation records, `entry` defines item-level metadata (including params/returns), `export` produces completion/hover/signature payloads, `report` evaluates quality and validation status, and `schema` stabilizes shared type contracts. This separation keeps ingestion, storage, emission, and grading concerns independent.

The module's value is consistency between source metadata and generated artifacts. By centralizing these models and exporters, the project avoids drift between docs outputs consumed by IDE tooling and validation/audit scripts.

As an integration-facing subsystem, it should prioritize deterministic output formats and explicit quality criteria so downstream generators and validators can rely on stable contracts over time.

Implementation detail and boundary guarantees for docs: this module keeps responsibilities explicit across source files so behavior remains inspectable during refactors. The current source map is: catalog.rs: Provide in-memory catalog storage for documentation entries collected from Rust source.; entry.rs: Define normalized documentation record types for lurek API symbols.; export.rs: Build JSON payloads for IDE completion, hover, and signature help from doc entries.; mod.rs: Aggregate documentation infrastructure: catalog, entry models, export, reporting, and schema.; report.rs: Compute per-entry quality scores from completeness of description, params, and metadata.; schema.rs: Re-export schema validation types from the lurek_schema crate.. This split is part of the contract: orchestration stays in composition points, data models stay in type-centric files, and adapters stay in bridge files. That separation reduces hidden coupling, improves testability, and keeps Lua API surfaces aligned with Rust runtime semantics. For maintainers, the key guarantee is that high-level APIs should keep delegating into scoped internals instead of collapsing into a single large entry point. Future extensions should preserve explicit dependency direction and documented invariants near owning types and functions.

## Files

### catalog.rs

- Provide in-memory catalog storage for documentation entries collected from Rust source.
- Support insertion-order preservation, module grouping, and text search.
- Offer merge, filter, and deduplication for multi-source doc aggregation.

### entry.rs

- Define normalized documentation record types for lurek API symbols.
- Model parameter, return, and metadata fields used by export and report stages.
- Provide completeness validation helpers for entry quality checks.

### export.rs

- Build JSON payloads for IDE completion, hover, and signature help from doc entries.
- Support compact and rich output modes for different consumer needs.
- Write individual or bundled JSON files to an output directory.
- Serialize via buffered writers with human-readable pretty formatting.
- Separate public export entry points from internal payload builders.

### mod.rs

- Aggregate documentation infrastructure: catalog, entry models, export, reporting, and schema.
- Re-export primary types so callers can import from the top-level docs module.
- Support the doc generation pipeline and IDE tooling data flow.

### report.rs

- Compute per-entry quality scores from completeness of description, params, and metadata.
- Convert scores to letter grades for human-readable reporting.
- Validate catalogs for missing, phantom, and incomplete entries.
- Aggregate module-level and overall quality metrics from a catalog snapshot.
- Support both catalog-based and standalone entry-based report construction.

### schema.rs

- Re-export schema validation types from the lurek_schema crate.
- Provide field rules, type definitions, and error types to docs modules.
- Keep schema source of truth external; this file is an access bridge.

## Lua API Ref

- Binding: `src/lua_api/docs_api.rs`
- Namespace: `lurek.docs`

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

### Enums

- No documented module-level enums/constants.

### Types


#### LApiCatalog Type


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


#### LDocEntry Type


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


#### LQualityReport Type


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


#### LSchema Type


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


#### LValidationReport Type


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

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.
