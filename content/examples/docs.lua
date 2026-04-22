-- content/examples/docs.lua
-- love2d-style usage snippets for the lurek.docs API (75 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/docs.lua

-- ── lurek.docs.* functions ──

--@api-stub: lurek.docs.scan
-- Scan the lurek.* namespace to build an API catalog from live bindings.
-- See the module spec for detailed semantics.
local result = lurek.docs.scan({ x = 0, y = 0 })
print("scan:", result)
return result

--@api-stub: lurek.docs.scanModule
-- Scan a single module's bindings.
-- See the module spec for detailed semantics.
local result = lurek.docs.scanModule("main")
print("scanModule:", result)
return result

--@api-stub: lurek.docs.loadToml
-- Load a TOML doc file into an ApiCatalog.
-- May block — call from a worker thread for large payloads.
local result = lurek.docs.loadToml("data/file.txt")
-- may block; consider lurek.thread for large payloads
print("loadToml:", result)
print("ok")

--@api-stub: lurek.docs.loadAll
-- Load all .toml files in a directory and merge into a single ApiCatalog.
-- May block — call from a worker thread for large payloads.
local result = lurek.docs.loadAll("data/file.txt")
-- may block; consider lurek.thread for large payloads
print("loadAll:", result)
print("ok")

--@api-stub: lurek.docs.describe
-- Inject or update a description for a named API entry.
-- See the module spec for detailed semantics.
local result = lurek.docs.describe("main", description)
print("describe:", result)
return result

--@api-stub: lurek.docs.setParamInfo
-- Set the parameter metadata for a catalog entry.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.docs.setParamInfo("main", { x = 0, y = 0 })
print("setParamInfo applied")
print("ok")

--@api-stub: lurek.docs.setReturnInfo
-- Set the return type metadata for a catalog entry.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.docs.setReturnInfo("main", returns)
print("setReturnInfo applied")
print("ok")

--@api-stub: lurek.docs.getCatalog
-- Return the current internal catalog as an ApiCatalog userdata.
-- Cheap to call; safe inside callbacks.
local value = lurek.docs.getCatalog()
print("getCatalog:", value)
return value

--@api-stub: lurek.docs.resetCatalog
-- Clear all entries from the internal catalog.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.docs.resetCatalog()
print("resetCatalog done")
print("ok")

--@api-stub: lurek.docs.validate
-- Validate catalog completeness against the live lurek.* bindings.
-- See the module spec for detailed semantics.
local result = lurek.docs.validate(catalog_ud)
print("validate:", result)
return result

--@api-stub: lurek.docs.validateModule
-- Validate a single module against the live lurek.<module>.* bindings.
-- See the module spec for detailed semantics.
local result = lurek.docs.validateModule("main", catalog_ud)
print("validateModule:", result)
return result

--@api-stub: lurek.docs.checkStaleness
-- Compare catalog entries against source files in a directory for staleness.
-- See the module spec for detailed semantics.
local result = lurek.docs.checkStaleness(catalog_ud, "data/file.txt")
print("checkStaleness:", result)
return result

--@api-stub: lurek.docs.quality
-- Calculate quality metrics for a catalog or the internal catalog.
-- See the module spec for detailed semantics.
local result = lurek.docs.quality(catalog_ud)
print("quality:", result)
return result

--@api-stub: lurek.docs.qualityModule
-- Calculate quality metrics for a single module.
-- See the module spec for detailed semantics.
local result = lurek.docs.qualityModule("main", catalog_ud)
print("qualityModule:", result)
return result

--@api-stub: lurek.docs.coverage
-- Return (documented_count, total_live_count) coverage tuple.
-- See the module spec for detailed semantics.
local result = lurek.docs.coverage(catalog_ud)
print("coverage:", result)
return result

--@api-stub: lurek.docs.coverageModule
-- Return (documented_count, total_live_count) for a single module.
-- See the module spec for detailed semantics.
local result = lurek.docs.coverageModule("main", catalog_ud)
print("coverageModule:", result)
return result

--@api-stub: lurek.docs.exportCompletions
-- Export VS Code IntelliSense completions JSON to a file.
-- May block — call from a worker thread for large payloads.
local result = lurek.docs.exportCompletions(catalog_ud, "data/file.txt")
-- may block; consider lurek.thread for large payloads
print("exportCompletions:", result)
print("ok")

--@api-stub: lurek.docs.exportHover
-- Export VS Code hover JSON to a file.
-- May block — call from a worker thread for large payloads.
local result = lurek.docs.exportHover(catalog_ud, "data/file.txt")
-- may block; consider lurek.thread for large payloads
print("exportHover:", result)
print("ok")

--@api-stub: lurek.docs.exportSignatures
-- Export VS Code signature-help JSON to a file.
-- May block — call from a worker thread for large payloads.
local result = lurek.docs.exportSignatures(catalog_ud, "data/file.txt")
-- may block; consider lurek.thread for large payloads
print("exportSignatures:", result)
print("ok")

--@api-stub: lurek.docs.exportAll
-- Export completions.json, hover.json, and signatures.json to a directory.
-- May block — call from a worker thread for large payloads.
local result = lurek.docs.exportAll(catalog_ud, "data/file.txt")
-- may block; consider lurek.thread for large payloads
print("exportAll:", result)
print("ok")

--@api-stub: lurek.docs.exportMarkdown
-- Export a Markdown API reference file.
-- May block — call from a worker thread for large payloads.
local result = lurek.docs.exportMarkdown(catalog_ud, "data/file.txt")
-- may block; consider lurek.thread for large payloads
print("exportMarkdown:", result)
print("ok")

--@api-stub: lurek.docs.exportCheatsheet
-- Export a one-line-per-function plain-text cheatsheet.
-- May block — call from a worker thread for large payloads.
local result = lurek.docs.exportCheatsheet(catalog_ud, "data/file.txt")
-- may block; consider lurek.thread for large payloads
print("exportCheatsheet:", result)
print("ok")

--@api-stub: lurek.docs.schema
-- Creates a Schema validator from a rules table.
-- See the module spec for detailed semantics.
local result = lurek.docs.schema(rules, "main")
print("schema:", result)
return result

--@api-stub: lurek.docs.reflectLive
-- Walks the live lurek.* Lua table and returns a structured reflection of all.
-- See the module spec for detailed semantics.
local result = lurek.docs.reflectLive(ns)
print("reflectLive:", result)
return result

--@api-stub: lurek.docs.reflectTable
-- Reflects any Lua table, returning a structure describing its keys,.
-- See the module spec for detailed semantics.
local result = lurek.docs.reflectTable(tbl, "main")
print("reflectTable:", result)
return result

-- ── Schema methods ──

--@api-stub: Schema:validate
-- Validates a Lua table against the schema.
-- See the module spec for detailed semantics.
local schema = lurek.docs.newSchema()
schema:validate({ x = 0, y = 0 })
print("Schema:validate done")

--@api-stub: Schema:check
-- Returns true when the data passes all schema rules.
-- See the module spec for detailed semantics.
local schema = lurek.docs.newSchema()
schema:check({ x = 0, y = 0 })
print("Schema:check done")

--@api-stub: Schema:assert
-- Validates data and throws a Lua error on failure with all error messages joined.
-- See the module spec for detailed semantics.
local schema = lurek.docs.newSchema()
schema:assert({ x = 0, y = 0 })
print("Schema:assert done")

--@api-stub: Schema:getName
-- Returns the name identifier of this API schema group.
-- Cheap to call; safe inside callbacks.
local schema = lurek.docs.newSchema()  -- or your existing handle
local value = schema:getName()
print("Schema:getName ->", value)

--@api-stub: Schema:getFields
-- Returns a table of declared field names.
-- Cheap to call; safe inside callbacks.
local schema = lurek.docs.newSchema()  -- or your existing handle
local value = schema:getFields()
print("Schema:getFields ->", value)

-- ── DocEntry methods ──

--@api-stub: DocEntry:getName
-- Returns the symbol name for this documentation entry.
-- Cheap to call; safe inside callbacks.
local docEntry = lurek.docs.newDocEntry()  -- or your existing handle
local value = docEntry:getName()
print("DocEntry:getName ->", value)

--@api-stub: DocEntry:getQualifiedName
-- Returns the qualified name.
-- Cheap to call; safe inside callbacks.
local docEntry = lurek.docs.newDocEntry()  -- or your existing handle
local value = docEntry:getQualifiedName()
print("DocEntry:getQualifiedName ->", value)

--@api-stub: DocEntry:getModule
-- Returns the Lua module name this entry belongs to (e.g.
-- Cheap to call; safe inside callbacks.
local docEntry = lurek.docs.newDocEntry()  -- or your existing handle
local value = docEntry:getModule()
print("DocEntry:getModule ->", value)

--@api-stub: DocEntry:getKind
-- Returns the kind tag for this entry (e.g.
-- Cheap to call; safe inside callbacks.
local docEntry = lurek.docs.newDocEntry()  -- or your existing handle
local value = docEntry:getKind()
print("DocEntry:getKind ->", value)

--@api-stub: DocEntry:getDescription
-- Returns the human-readable description text for this documentation entry.
-- Cheap to call; safe inside callbacks.
local docEntry = lurek.docs.newDocEntry()  -- or your existing handle
local value = docEntry:getDescription()
print("DocEntry:getDescription ->", value)

--@api-stub: DocEntry:getParameters
-- Returns the parameters as a table of `{name, type, description, optional, default?}` records.
-- Cheap to call; safe inside callbacks.
local docEntry = lurek.docs.newDocEntry()  -- or your existing handle
local value = docEntry:getParameters()
print("DocEntry:getParameters ->", value)

--@api-stub: DocEntry:getReturns
-- Returns the return values as a table of `{type, description}` records.
-- Cheap to call; safe inside callbacks.
local docEntry = lurek.docs.newDocEntry()  -- or your existing handle
local value = docEntry:getReturns()
print("DocEntry:getReturns ->", value)

--@api-stub: DocEntry:getExample
-- Returns the example snippet, or nil.
-- Cheap to call; safe inside callbacks.
local docEntry = lurek.docs.newDocEntry()  -- or your existing handle
local value = docEntry:getExample()
print("DocEntry:getExample ->", value)

--@api-stub: DocEntry:getSince
-- Returns the since version string, or nil.
-- Cheap to call; safe inside callbacks.
local docEntry = lurek.docs.newDocEntry()  -- or your existing handle
local value = docEntry:getSince()
print("DocEntry:getSince ->", value)

--@api-stub: DocEntry:getDeprecated
-- Returns the deprecation message, or nil.
-- Cheap to call; safe inside callbacks.
local docEntry = lurek.docs.newDocEntry()  -- or your existing handle
local value = docEntry:getDeprecated()
print("DocEntry:getDeprecated ->", value)

--@api-stub: DocEntry:getScore
-- Returns the quality score in [0,1].
-- Cheap to call; safe inside callbacks.
local docEntry = lurek.docs.newDocEntry()  -- or your existing handle
local value = docEntry:getScore()
print("DocEntry:getScore ->", value)

--@api-stub: DocEntry:hasDescription
-- Returns true when the entry has a non-empty description.
-- Use as a guard inside lurek.update or event handlers.
local docEntry = lurek.docs.newDocEntry()
if docEntry:hasDescription() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: DocEntry:hasParameters
-- Returns true when the entry has at least one parameter.
-- Use as a guard inside lurek.update or event handlers.
local docEntry = lurek.docs.newDocEntry()
if docEntry:hasParameters() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: DocEntry:hasReturnType
-- Returns true when the entry declares at least one return type.
-- Use as a guard inside lurek.update or event handlers.
local docEntry = lurek.docs.newDocEntry()
if docEntry:hasReturnType() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: DocEntry:hasExample
-- Returns true when the entry has an example snippet.
-- Use as a guard inside lurek.update or event handlers.
local docEntry = lurek.docs.newDocEntry()
if docEntry:hasExample() then print("yes") end
-- swap the constructor for your real handle
print("ok")

-- ── ApiCatalog methods ──

--@api-stub: ApiCatalog:getModules
-- Returns a sorted list of module names present in the catalog.
-- Cheap to call; safe inside callbacks.
local apiCatalog = lurek.docs.newApiCatalog()  -- or your existing handle
local value = apiCatalog:getModules()
print("ApiCatalog:getModules ->", value)

--@api-stub: ApiCatalog:getEntries
-- Returns all entries, optionally filtered to a single module.
-- Cheap to call; safe inside callbacks.
local apiCatalog = lurek.docs.newApiCatalog()  -- or your existing handle
local value = apiCatalog:getEntries(module)
print("ApiCatalog:getEntries ->", value)

--@api-stub: ApiCatalog:getEntry
-- Returns a single entry by qualified name, or nil.
-- Cheap to call; safe inside callbacks.
local apiCatalog = lurek.docs.newApiCatalog()  -- or your existing handle
local value = apiCatalog:getEntry("main")
print("ApiCatalog:getEntry ->", value)

--@api-stub: ApiCatalog:getTypes
-- Returns the names of all entries with kind "type" in the given module.
-- Cheap to call; safe inside callbacks.
local apiCatalog = lurek.docs.newApiCatalog()  -- or your existing handle
local value = apiCatalog:getTypes("main")
print("ApiCatalog:getTypes ->", value)

--@api-stub: ApiCatalog:getTypeMethods
-- Returns entries that are methods of the given type qualified name.
-- Cheap to call; safe inside callbacks.
local apiCatalog = lurek.docs.newApiCatalog()  -- or your existing handle
local value = apiCatalog:getTypeMethods("main")
print("ApiCatalog:getTypeMethods ->", value)

--@api-stub: ApiCatalog:entryCount
-- Returns the number of entries, optionally scoped to a module.
-- See the module spec for detailed semantics.
local apiCatalog = lurek.docs.newApiCatalog()
apiCatalog:entryCount(module)
print("ApiCatalog:entryCount done")

--@api-stub: ApiCatalog:merge
-- Returns a new catalog that is the union of this and another catalog, with other overriding duplicates.
-- See the module spec for detailed semantics.
local apiCatalog = lurek.docs.newApiCatalog()
apiCatalog:merge(other)
print("ApiCatalog:merge done")

--@api-stub: ApiCatalog:filter
-- Returns a new catalog containing only entries for which predicate returns true.
-- See the module spec for detailed semantics.
local apiCatalog = lurek.docs.newApiCatalog()
apiCatalog:filter(predicate)
print("ApiCatalog:filter done")

--@api-stub: ApiCatalog:search
-- Returns a table of entries whose name, qualified name, or description contains query.
-- See the module spec for detailed semantics.
local apiCatalog = lurek.docs.newApiCatalog()
apiCatalog:search(query)
print("ApiCatalog:search done")

--@api-stub: ApiCatalog:toTable
-- Converts the catalog to a plain Lua table array.
-- See the module spec for detailed semantics.
local apiCatalog = lurek.docs.newApiCatalog()
apiCatalog:toTable()
print("ApiCatalog:toTable done")

--@api-stub: ApiCatalog:toJSON
-- Serialises the catalog to a pretty-printed JSON string.
-- See the module spec for detailed semantics.
local apiCatalog = lurek.docs.newApiCatalog()
apiCatalog:toJSON()
print("ApiCatalog:toJSON done")

-- ── ValidationReport methods ──

--@api-stub: ValidationReport:isValid
-- Returns true when the report has no missing entries.
-- Use as a guard inside lurek.update or event handlers.
local validationReport = lurek.docs.newValidationReport()
if validationReport:isValid() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: ValidationReport:getMissing
-- Returns the list of qualified names present in the live API but missing from the catalog.
-- Cheap to call; safe inside callbacks.
local validationReport = lurek.docs.newValidationReport()  -- or your existing handle
local value = validationReport:getMissing()
print("ValidationReport:getMissing ->", value)

--@api-stub: ValidationReport:getPhantom
-- Returns the list of qualified names in the catalog that are not present in the live API.
-- Cheap to call; safe inside callbacks.
local validationReport = lurek.docs.newValidationReport()  -- or your existing handle
local value = validationReport:getPhantom()
print("ValidationReport:getPhantom ->", value)

--@api-stub: ValidationReport:getIncomplete
-- Returns the list of qualified names whose catalog entry is incomplete.
-- Cheap to call; safe inside callbacks.
local validationReport = lurek.docs.newValidationReport()  -- or your existing handle
local value = validationReport:getIncomplete()
print("ValidationReport:getIncomplete ->", value)

--@api-stub: ValidationReport:missingCount
-- Returns the count of missing entries.
-- See the module spec for detailed semantics.
local validationReport = lurek.docs.newValidationReport()
validationReport:missingCount()
print("ValidationReport:missingCount done")

--@api-stub: ValidationReport:phantomCount
-- Returns the count of phantom entries.
-- See the module spec for detailed semantics.
local validationReport = lurek.docs.newValidationReport()
validationReport:phantomCount()
print("ValidationReport:phantomCount done")

--@api-stub: ValidationReport:incompleteCount
-- Returns the count of incomplete entries.
-- See the module spec for detailed semantics.
local validationReport = lurek.docs.newValidationReport()
validationReport:incompleteCount()
print("ValidationReport:incompleteCount done")

--@api-stub: ValidationReport:getSummary
-- Returns a single-line summary of the validation results.
-- Cheap to call; safe inside callbacks.
local validationReport = lurek.docs.newValidationReport()  -- or your existing handle
local value = validationReport:getSummary()
print("ValidationReport:getSummary ->", value)

--@api-stub: ValidationReport:toTable
-- Converts the report to a plain Lua table.
-- See the module spec for detailed semantics.
local validationReport = lurek.docs.newValidationReport()
validationReport:toTable()
print("ValidationReport:toTable done")

--@api-stub: ValidationReport:toJSON
-- Serialises the report to a pretty-printed JSON string.
-- See the module spec for detailed semantics.
local validationReport = lurek.docs.newValidationReport()
validationReport:toJSON()
print("ValidationReport:toJSON done")

-- ── QualityReport methods ──

--@api-stub: QualityReport:getOverallScore
-- Returns the overall quality score in [0,1].
-- Cheap to call; safe inside callbacks.
local qualityReport = lurek.docs.newQualityReport()  -- or your existing handle
local value = qualityReport:getOverallScore()
print("QualityReport:getOverallScore ->", value)

--@api-stub: QualityReport:getGrade
-- Returns the letter grade for the overall score.
-- Cheap to call; safe inside callbacks.
local qualityReport = lurek.docs.newQualityReport()  -- or your existing handle
local value = qualityReport:getGrade()
print("QualityReport:getGrade ->", value)

--@api-stub: QualityReport:getModuleScores
-- Returns a table mapping module name to its average quality score.
-- Cheap to call; safe inside callbacks.
local qualityReport = lurek.docs.newQualityReport()  -- or your existing handle
local value = qualityReport:getModuleScores()
print("QualityReport:getModuleScores ->", value)

--@api-stub: QualityReport:getWorst
-- Returns up to count entries with the lowest quality scores.
-- Cheap to call; safe inside callbacks.
local qualityReport = lurek.docs.newQualityReport()  -- or your existing handle
local value = qualityReport:getWorst(10)
print("QualityReport:getWorst ->", value)

--@api-stub: QualityReport:getBest
-- Returns up to count entries with the highest quality scores.
-- Cheap to call; safe inside callbacks.
local qualityReport = lurek.docs.newQualityReport()  -- or your existing handle
local value = qualityReport:getBest(10)
print("QualityReport:getBest ->", value)

--@api-stub: QualityReport:getByGrade
-- Returns entries whose grade exactly matches the given letter grade.
-- Cheap to call; safe inside callbacks.
local qualityReport = lurek.docs.newQualityReport()  -- or your existing handle
local value = qualityReport:getByGrade(grade)
print("QualityReport:getByGrade ->", value)

--@api-stub: QualityReport:getSummary
-- Returns a multi-line human-readable summary of quality by module.
-- Cheap to call; safe inside callbacks.
local qualityReport = lurek.docs.newQualityReport()  -- or your existing handle
local value = qualityReport:getSummary()
print("QualityReport:getSummary ->", value)

--@api-stub: QualityReport:toTable
-- Converts the quality report to a plain Lua table.
-- See the module spec for detailed semantics.
local qualityReport = lurek.docs.newQualityReport()
qualityReport:toTable()
print("QualityReport:toTable done")

--@api-stub: QualityReport:toJSON
-- Serialises the quality report to a pretty-printed JSON string.
-- See the module spec for detailed semantics.
local qualityReport = lurek.docs.newQualityReport()
qualityReport:toJSON()
print("QualityReport:toJSON done")

