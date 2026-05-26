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

 By scanning and reflecting Lua API metadata upon startup, it provides robust, programmatic access to function signatures, parameter descriptions, return types, and usage examples. The foundational structure of this module is the `DocEntry`, which securely encapsulates the canonical details of one documented API item—from its prose description to structured parameter and return metadata. These entries are efficiently stored and aggregated within an in-memory `Catalog`, fully searchable and indexable by namespace path.

A key capability of the module is its rigorous validation and quality-reporting system. By comparing the populated catalog against the live, reflected `lurek` API surface, it accurately generates `ValidationReport` and `QualityReport` structures. These tools score documentation completeness, assign letter grades, and identify missing, phantom, or incomplete entries, ensuring that the engine's documentation quality remains consistently high.

Beyond in-engine diagnostics, the `docs` module drives Lurek2D's IDE integration capabilities. It features specialized export functions capable of generating structured JSON payloads for code completions, hover information, and signature help, ready to be consumed directly by editors like VS Code. Furthermore, the module facilitates schema validation by generating typed config documentation from TOML definitions, serving as an access bridge for the `lurek_schema` crate. The entirety of this robust toolset is accessible via the `lurek.docs.*` namespace, allowing scripts and CI pipelines to autonomously validate API coverage, export artifacts, and maintain documentation hygiene.

## Source Documentation

### `catalog.rs`
- Provide in-memory catalog storage for documentation entries collected from Rust source.
- Support insertion-order preservation, module grouping, and text search.
- Offer merge, filter, and deduplication for multi-source doc aggregation.

### `entry.rs`
- Define normalized documentation record types for lurek API symbols.
- Model parameter, return, and metadata fields used by export and report stages.
- Provide completeness validation helpers for entry quality checks.

### `export.rs`
- Build JSON payloads for IDE completion, hover, and signature help from doc entries.
- Support compact and rich output modes for different consumer needs.
- Write individual or bundled JSON files to an output directory.
- Serialize via buffered writers with human-readable pretty formatting.
- Separate public export entry points from internal payload builders.

### `mod.rs`
- Aggregate documentation infrastructure: catalog, entry models, export, reporting, and schema.
- Re-export primary types so callers can import from the top-level docs module.
- Support the doc generation pipeline and IDE tooling data flow.

### `report.rs`
- Compute per-entry quality scores from completeness of description, params, and metadata.
- Convert scores to letter grades for human-readable reporting.
- Validate catalogs for missing, phantom, and incomplete entries.
- Aggregate module-level and overall quality metrics from a catalog snapshot.
- Support both catalog-based and standalone entry-based report construction.

### `schema.rs`
- Re-export schema validation types from the lurek_schema crate.
- Provide field rules, type definitions, and error types to docs modules.
- Keep schema source of truth external; this file is an access bridge.

## Types

- `Catalog` (`struct`, `catalog.rs`): In-memory store for DocEntry values with search and filtering helpers. It is the first place to inspect when tools cannot find entries they expect.
- `ParamInfo` (`struct`, `entry.rs`): Structured parameter metadata attached to a DocEntry. It keeps function signatures machine-readable instead of burying argument details in prose.
- `ReturnInfo` (`struct`, `entry.rs`): Structured return-value metadata attached to a DocEntry. It exists for the same reason as ParamInfo, but for outputs.
- `DocEntry` (`struct`, `entry.rs`): Canonical description of one documented API item, including identity, module, kind, prose, parameters, returns, examples, and metadata. It is the most important type in the module because nearly every other piece of functionality builds on it.
- `ValidationReport` (`struct`, `report.rs`): Comparison result between the catalog and some observed or expected API surface. It is useful when auditing missing, phantom, or incomplete docs.
- `QualityReport` (`struct`, `report.rs`): Aggregate scoring output for doc quality at entry and module level. It exists so tooling can quantify documentation quality instead of only reporting raw missing fields.

## Functions

- `Catalog::new` (`catalog.rs`): Create an empty catalog and return it for entry aggregation.
- `Catalog::from_entries` (`catalog.rs`): Build a catalog from a slice and return a cloned copy of each entry.
- `Catalog::add` (`catalog.rs`): Append one entry to the catalog and return unit.
- `Catalog::modules` (`catalog.rs`): Return sorted unique module names referenced by all stored entries.
- `Catalog::all_entries` (`catalog.rs`): Return an immutable slice of all entries in insertion order.
- `Catalog::entries_for_module` (`catalog.rs`): Return all entries that belong to the requested module name.
- `Catalog::get_entry` (`catalog.rs`): Return the entry matching a fully qualified name or None when missing.
- `Catalog::entry_count` (`catalog.rs`): Return the number of stored entries.
- `Catalog::search` (`catalog.rs`): Return entries whose lowercase name or description contains the query.
- `Catalog::filter_by_kind` (`catalog.rs`): Return entries with a kind exactly equal to the provided value.
- `Catalog::merge` (`catalog.rs`): Merge this catalog with another and return de-duplicated entries by qualified name.
- `Catalog::clear` (`catalog.rs`): Remove all stored entries and return unit.
- `DocEntry::new` (`entry.rs`): Create an entry shell and return it with a computed qualified name.
- `DocEntry::is_complete` (`entry.rs`): Return true when required fields are present for this kind, else false.
- `DocEntry::missing_fields` (`entry.rs`): Return symbolic names of missing required fields for this entry.
- `export_completions` (`export.rs`): Writes a VS Code completions JSON array to `path`.
- `export_hover` (`export.rs`): Writes a VS Code hover JSON map to `path`.
- `export_signatures` (`export.rs`): Writes a VS Code signature-help JSON map to `path`.
- `export_all` (`export.rs`): Writes `completions.json`, `hover.json`, and `signatures.json` to `output_dir`.
- `quality_score` (`report.rs`): Computes a quality score in `[0.0, 1.0]` for a single doc entry.
- `quality_grade` (`report.rs`): Converts a quality score into a letter grade.
- `ValidationReport::new` (`report.rs`): Create an empty validation report and return it.
- `ValidationReport::is_clean` (`report.rs`): Return true when no issue buckets contain any item.
- `ValidationReport::total_issues` (`report.rs`): Return the total number of aggregated issues across all buckets.
- `QualityReport::compute` (`report.rs`): Compute report metrics from a catalog and return the report.
- `QualityReport::module_grade` (`report.rs`): Return the letter grade for one module score or F when missing.
- `QualityReport::from_entries` (`report.rs`): Build a temporary catalog from entries and return a computed report.

## Lua API Reference

- Binding path(s): `src/lua_api/docs_api.rs`
- Namespace: `lurek.docs`

### Module Functions
- `lurek.docs.scan`: Reflects the live `lurek` table and builds a catalog of callable APIs.
- `lurek.docs.scanModule`: Reflects one live `lurek.<module>` table and builds a catalog for that module.
- `lurek.docs.loadToml`: Loads a TOML documentation catalog file and converts its entries into an API catalog.
- `lurek.docs.loadAll`: Loads all TOML documentation catalog files from a directory and combines their entries.
- `lurek.docs.describe`: Adds or updates the description for one editable catalog entry.
- `lurek.docs.setParamInfo`: Replaces parameter metadata for one editable catalog entry.
- `lurek.docs.setReturnInfo`: Replaces return-value metadata for one editable catalog entry.
- `lurek.docs.getCatalog`: Returns the editable in-memory documentation catalog.
- `lurek.docs.resetCatalog`: Clears the editable in-memory documentation catalog.
- `lurek.docs.validate`: Compares a documentation catalog with the live reflected `lurek` API table.
- `lurek.docs.validateModule`: Compares one module's documentation catalog entries with the live reflected module table.
- `lurek.docs.checkStaleness`: Lists source files in a directory for simple documentation staleness checks.
- `lurek.docs.quality`: Computes documentation quality for a supplied catalog or the editable in-memory catalog.
- `lurek.docs.qualityModule`: Computes documentation quality for entries belonging to one module.
- `lurek.docs.coverage`: Returns documented and live API counts for the full `lurek` table.
- `lurek.docs.coverageModule`: Returns documented and live API counts for one module.
- `lurek.docs.exportCompletions`: Exports catalog completion metadata to a file.
- `lurek.docs.exportHover`: Exports catalog hover metadata to a file.
- `lurek.docs.exportSignatures`: Exports catalog signature metadata to a file.
- `lurek.docs.exportAll`: Exports all editor documentation artifacts for a catalog into a directory.
- `lurek.docs.exportMarkdown`: Writes a Markdown API reference from catalog entries.
- `lurek.docs.exportCheatsheet`: Writes a compact text cheatsheet from catalog entries.
- `lurek.docs.schema`: Builds a schema validator from Lua table rules.
- `lurek.docs.schemaFromToml`: Builds a schema validator from TOML schema text.
- `lurek.docs.reflectLive`: Reflects live `lurek` module tables into plain name and type rows.
- `lurek.docs.reflectTable`: Reflects an arbitrary Lua table into name, qualifiedName, and type rows.

### `LApiCatalog` Methods
- `LApiCatalog:getModules`: Returns every module represented in this catalog.
- `LApiCatalog:getEntries`: Returns catalog entries, optionally limited to one module.
- `LApiCatalog:getEntry`: Returns one catalog entry by qualified API name.
- `LApiCatalog:getTypes`: Returns type names documented for one module.
- `LApiCatalog:getTypeMethods`: Returns method entries associated with a qualified type name.
- `LApiCatalog:entryCount`: Counts entries in the catalog, optionally for one module.
- `LApiCatalog:merge`: Merges another catalog into this catalog and returns a new catalog value.
- `LApiCatalog:filter`: Builds a new catalog containing entries accepted by a Lua predicate.
- `LApiCatalog:search`: Searches names, qualified names, and descriptions with a case-insensitive substring query.
- `LApiCatalog:toTable`: Converts this catalog into plain Lua tables for lightweight inspection.
- `LApiCatalog:toJSON`: Serializes this catalog to formatted JSON.
- `LApiCatalog:type`: Returns the Lua-visible type name for this API catalog handle.
- `LApiCatalog:typeOf`: Returns whether this API catalog handle matches a supported type name.

### `LDocEntry` Methods
- `LDocEntry:getName`: Returns the short API name stored by this documentation entry.
- `LDocEntry:getQualifiedName`: Returns the full dotted API name stored by this documentation entry.
- `LDocEntry:getModule`: Returns the module name associated with this documentation entry.
- `LDocEntry:getKind`: Returns the documentation kind recorded for this entry.
- `LDocEntry:getDescription`: Returns the prose description recorded for this entry.
- `LDocEntry:getParameters`: Returns parameter metadata recorded for this entry.
- `LDocEntry:getReturns`: Returns return-value metadata recorded for this entry.
- `LDocEntry:getExample`: Returns this entry's example text when one was recorded.
- `LDocEntry:getSince`: Returns this entry's since-version text when one was recorded.
- `LDocEntry:getDeprecated`: Returns this entry's deprecation text when one was recorded.
- `LDocEntry:getScore`: Returns the documentation quality score calculated for this entry.
- `LDocEntry:hasDescription`: Returns whether this entry has non-empty description text.
- `LDocEntry:hasParameters`: Returns whether this entry has parameter metadata.
- `LDocEntry:hasReturnType`: Returns whether this entry has return-value metadata.
- `LDocEntry:hasExample`: Returns whether this entry has example text.
- `LDocEntry:type`: Returns the Lua-visible type name for this documentation entry handle.
- `LDocEntry:typeOf`: Returns whether this documentation entry handle matches a supported type name.

### `LQualityReport` Methods
- `LQualityReport:getOverallScore`: Returns the aggregate documentation quality score.
- `LQualityReport:getGrade`: Returns the letter grade derived from the aggregate documentation score.
- `LQualityReport:getModuleScores`: Returns per-module documentation quality scores.
- `LQualityReport:getWorst`: Returns the lowest-scoring documentation entries.
- `LQualityReport:getBest`: Returns the highest-scoring documentation entries.
- `LQualityReport:getByGrade`: Returns documentation entries whose calculated grade matches a grade string.
- `LQualityReport:getSummary`: Returns a human-readable summary of overall and per-module quality scores.
- `LQualityReport:toTable`: Converts this quality report into a plain Lua table.
- `LQualityReport:toJSON`: Serializes this quality report to formatted JSON.
- `LQualityReport:type`: Returns the Lua-visible type name for this quality report handle.
- `LQualityReport:typeOf`: Returns whether this quality report handle matches a supported type name.

### `LSchema` Methods
- `LSchema:validate`: Validates a Lua table and returns a success flag plus structured error rows.
- `LSchema:check`: Validates a Lua table and returns only the boolean result.
- `LSchema:assert`: Validates a Lua table and raises a Lua error when schema checks fail.
- `LSchema:getName`: Returns this schema's display name.
- `LSchema:getFields`: Returns the field names declared by this schema.
- `LSchema:type`: Returns the Lua-visible type name for this schema handle.
- `LSchema:typeOf`: Returns whether this schema handle matches a supported type name.

### `LValidationReport` Methods
- `LValidationReport:isValid`: Returns whether the validation report has no missing live APIs.
- `LValidationReport:getMissing`: Returns live APIs that were missing from the checked catalog.
- `LValidationReport:getPhantom`: Returns catalog APIs that were not present in the live Lua table.
- `LValidationReport:getIncomplete`: Returns catalog APIs whose documentation was incomplete.
- `LValidationReport:missingCount`: Returns the number of live APIs missing from the catalog.
- `LValidationReport:phantomCount`: Returns the number of catalog APIs absent from live reflection.
- `LValidationReport:incompleteCount`: Returns the number of catalog APIs with incomplete documentation.
- `LValidationReport:getSummary`: Returns a compact text summary of missing, phantom, and incomplete counts.
- `LValidationReport:toTable`: Converts this validation report into a plain Lua table.
- `LValidationReport:toJSON`: Serializes this validation report to formatted JSON.
- `LValidationReport:type`: Returns the Lua-visible type name for this validation report handle.
- `LValidationReport:typeOf`: Returns whether this validation report handle matches a supported type name.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- Keep this module reference synchronized with `src/docs/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
