-- content/examples/docs.lua
-- lurek.docs API examples: reflection, catalogs, validation, quality, schema, and export.
-- Run: cargo run -- content/examples/docs.lua

--@api-stub: lurek.docs.scan
-- Reflects the live lurek table and builds a catalog of callable APIs.
do
  -- Use scan() for a runtime help screen that adapts to registered modules.
  local catalog = lurek.docs.scan()
  print("docs.scan", catalog:entryCount())
end

--@api-stub: lurek.docs.scanModule
-- Reflects one live lurek module and builds a catalog for that module.
do
  -- scanModule() is faster when a help panel only needs one namespace.
  local catalog = lurek.docs.scanModule("docs")
  print("docs.scanModule", catalog:entryCount("docs"))
end

--@api-stub: lurek.docs.loadToml
-- Loads a TOML documentation catalog file into an API catalog.
do
  -- Use pcall because authored TOML catalogs may not exist in stripped builds.
  local ok, catalog = pcall(lurek.docs.loadToml, "docs/api/audio.toml")
  print("docs.loadToml", ok, ok and catalog:entryCount() or 0)
end

--@api-stub: lurek.docs.loadAll
-- Loads every TOML documentation catalog file from a directory.
do
  -- loadAll() is useful for build tools that combine authored docs.
  local ok, catalog = pcall(lurek.docs.loadAll, "docs/api")
  print("docs.loadAll", ok, ok and #catalog:getModules() or 0)
end

--@api-stub: lurek.docs.describe
-- Adds or updates the description for one editable catalog entry.
do
  -- describe() creates an editable entry when it does not already exist.
  lurek.docs.resetCatalog()
  lurek.docs.describe("lurek.example.spawn", "Spawns a documented example entity.")
  local entry = lurek.docs.getCatalog():getEntry("lurek.example.spawn")
  print("docs.describe", entry and entry:getDescription() or "missing")
end

--@api-stub: lurek.docs.setParamInfo
-- Replaces parameter metadata for one editable catalog entry.
do
  -- Parameter rows contain name, type, description, optional, and default fields.
  lurek.docs.resetCatalog()
  lurek.docs.describe("lurek.example.spawn", "Spawns a documented example entity.")
  lurek.docs.setParamInfo("lurek.example.spawn", {
    {name = "kind", type = "string", description = "Entity kind", optional = false},
    {name = "x", type = "number", description = "World x", optional = true, default = "0"},
  })
  local entry = lurek.docs.getCatalog():getEntry("lurek.example.spawn")
  print("docs.setParamInfo", entry and #entry:getParameters() or 0)
end

--@api-stub: lurek.docs.setReturnInfo
-- Replaces return metadata for one editable catalog entry.
do
  -- Return rows contain type and description fields.
  lurek.docs.resetCatalog()
  lurek.docs.describe("lurek.example.spawn", "Spawns a documented example entity.")
  lurek.docs.setReturnInfo("lurek.example.spawn", {
    {type = "integer", description = "Spawned entity id"},
  })
  local entry = lurek.docs.getCatalog():getEntry("lurek.example.spawn")
  print("docs.setReturnInfo", entry and #entry:getReturns() or 0)
end

--@api-stub: lurek.docs.getCatalog
-- Returns the editable in-memory documentation catalog.
do
  -- getCatalog() reads entries created by describe and metadata setters.
  lurek.docs.resetCatalog()
  lurek.docs.describe("lurek.example.help", "Opens a help panel.")
  local catalog = lurek.docs.getCatalog()
  print("docs.getCatalog", catalog:entryCount())
end

--@api-stub: lurek.docs.resetCatalog
-- Clears the editable in-memory documentation catalog.
do
  -- Reset before rebuilding generated annotations.
  lurek.docs.describe("lurek.example.temp", "Temporary entry.")
  lurek.docs.resetCatalog()
  print("docs.resetCatalog", lurek.docs.getCatalog():entryCount())
end

--@api-stub: lurek.docs.validate
-- Compares a documentation catalog with the live reflected lurek API table.
do
  -- validate() reports missing, phantom, and incomplete entries.
  local report = lurek.docs.validate(lurek.docs.getCatalog())
  print("docs.validate", report:missingCount(), report:phantomCount())
end

--@api-stub: lurek.docs.validateModule
-- Compares one module catalog with the live reflected module table.
do
  -- Use validateModule() for focused module documentation checks.
  local report = lurek.docs.validateModule("docs", lurek.docs.scanModule("docs"))
  print("docs.validateModule", report:isValid(), report:incompleteCount())
end

--@api-stub: lurek.docs.checkStaleness
-- Lists source files for simple documentation staleness checks.
do
  -- The result has stale, current, and missing arrays.
  local result = lurek.docs.checkStaleness(lurek.docs.scan(), "src/lua_api")
  print("docs.checkStaleness", #result.current, #result.stale, #result.missing)
end

--@api-stub: lurek.docs.quality
-- Computes documentation quality for a catalog.
do
  -- quality() returns aggregate and per-module scores.
  local report = lurek.docs.quality(lurek.docs.scanModule("docs"))
  print("docs.quality", report:getGrade(), report:getOverallScore())
end

--@api-stub: lurek.docs.qualityModule
-- Computes documentation quality for one module.
do
  -- Module quality is useful for targeted quality gates.
  local report = lurek.docs.qualityModule("docs", lurek.docs.scanModule("docs"))
  print("docs.qualityModule", report:getGrade())
end

--@api-stub: lurek.docs.coverage
-- Returns documented and live API counts for the full lurek table.
do
  -- coverage() returns documented count, then live count.
  local documented, total = lurek.docs.coverage(lurek.docs.getCatalog())
  print("docs.coverage", documented, total)
end

--@api-stub: lurek.docs.coverageModule
-- Returns documented and live API counts for one module.
do
  -- Scoped coverage avoids scanning unrelated module docs in a module task.
  local documented, total = lurek.docs.coverageModule("docs", lurek.docs.scanModule("docs"))
  print("docs.coverageModule", documented, total)
end

--@api-stub: lurek.docs.exportCompletions
-- Exports catalog completion metadata to a file.
do
  -- Export helpers write files and should be protected in examples.
  local ok = pcall(lurek.docs.exportCompletions, lurek.docs.scanModule("docs"), "build/vscode/docs-completions.json")
  print("docs.exportCompletions", ok)
end

--@api-stub: lurek.docs.exportHover
-- Exports catalog hover metadata to a file.
do
  -- Hover data stores descriptions and metadata for editor integrations.
  local ok = pcall(lurek.docs.exportHover, lurek.docs.scanModule("docs"), "build/vscode/docs-hover.json")
  print("docs.exportHover", ok)
end

--@api-stub: lurek.docs.exportSignatures
-- Exports catalog signature metadata to a file.
do
  -- Signature data powers parameter help in editor tools.
  local ok = pcall(lurek.docs.exportSignatures, lurek.docs.scanModule("docs"), "build/vscode/docs-signatures.json")
  print("docs.exportSignatures", ok)
end

--@api-stub: lurek.docs.exportAll
-- Exports all editor documentation artifacts for a catalog into a directory.
do
  -- exportAll writes completions, hover, and signatures together.
  local ok = pcall(lurek.docs.exportAll, lurek.docs.scanModule("docs"), "build/vscode")
  print("docs.exportAll", ok)
end

--@api-stub: lurek.docs.exportMarkdown
-- Writes a Markdown API reference from catalog entries.
do
  -- Markdown export is useful for a generated reference snapshot.
  local ok = pcall(lurek.docs.exportMarkdown, lurek.docs.scanModule("docs"), "build/docs-api.md")
  print("docs.exportMarkdown", ok)
end

--@api-stub: lurek.docs.exportCheatsheet
-- Writes a compact text cheatsheet from catalog entries.
do
  -- Cheatsheets are short enough for terminal quick reference.
  local ok = pcall(lurek.docs.exportCheatsheet, lurek.docs.scanModule("docs"), "build/docs-cheatsheet.txt")
  print("docs.exportCheatsheet", ok)
end

--@api-stub: lurek.docs.schema
-- Builds a schema validator from Lua table rules.
do
  -- Schema rules can enforce types, required fields, bounds, and enums.
  local schema = lurek.docs.schema({
    name = {type = "string", required = true, minLen = 1},
    level = {type = "integer", required = true, min = 1, max = 99},
  }, "PlayerSave")
  print("docs.schema", schema:check({name = "Hero", level = 3}))
end

--@api-stub: lurek.docs.schemaFromToml
-- Builds a schema validator from TOML schema text.
do
  -- TOML schemas keep validation rules outside Lua scripts.
  local text = [[
name = "PlayerSave"
strict = true

[rules.level]
type = "integer"
required = true
min = 1
max = 99
]]
  local ok, schema = pcall(lurek.docs.schemaFromToml, text)
  print("docs.schemaFromToml", ok, ok and schema:check({level = 10}) or false)
end

--@api-stub: lurek.docs.reflectLive
-- Reflects live lurek module tables into plain name and type rows.
do
  -- reflectLive() returns raw rows, not catalog userdata.
  local reflected = lurek.docs.reflectLive("docs")
  print("docs.reflectLive", #(reflected.docs or {}))
end

--@api-stub: lurek.docs.reflectTable
-- Reflects an arbitrary Lua table into name, qualifiedName, and type rows.
do
  -- This can document game-local tables or plugin tables.
  local items = lurek.docs.reflectTable({run = function() end, version = "1.0"}, "plugin.sample")
  print("docs.reflectTable", #items, items[1] and items[1].qualifiedName or "none")
end

--@api-stub: LSchema:validate
-- Validates a table and returns success plus structured error rows.
do
  -- Use validate() when UI should display individual field errors.
  local schema = lurek.docs.schema({hp = {type = "integer", required = true, min = 0}}, "Stats")
  local ok, errors = schema:validate({hp = -5})
  print("LSchema:validate", ok, #errors)
end

--@api-stub: LSchema:check
-- Validates a table and returns only the boolean result.
do
  -- check() is a compact pass/fail gate.
  local schema = lurek.docs.schema({port = {type = "integer", min = 1, max = 65535}}, "Net")
  print("LSchema:check", schema:check({port = 8080}))
end

--@api-stub: LSchema:assert
-- Validates a table and raises a Lua error when schema checks fail.
do
  -- assert() is strict and is best for config load gates.
  local schema = lurek.docs.schema({width = {type = "integer", required = true, min = 1}}, "Window")
  schema:assert({width = 1280})
  print("LSchema:assert", true)
end

--@api-stub: LSchema:getName
-- Returns this schema's display name.
do
  -- Use the schema name in validation reports.
  local schema = lurek.docs.schema({x = {type = "number"}}, "Point")
  print("LSchema:getName", schema:getName())
end

--@api-stub: LSchema:getFields
-- Returns the field names declared by this schema.
do
  -- Field lists can drive config templates.
  local schema = lurek.docs.schema({a = {type = "string"}, b = {type = "number"}}, "AB")
  print("LSchema:getFields", table.concat(schema:getFields(), ","))
end

--@api-stub: LSchema:type
-- Returns the Lua-visible type name for this schema handle.
do
  -- Type names help generic inspectors label userdata.
  local schema = lurek.docs.schema({hp = {type = "integer"}}, "Stats")
  print("LSchema:type", schema:type())
end

--@api-stub: LSchema:typeOf
-- Checks whether this handle is a schema.
do
  -- Schemas match LSchema and Object.
  local schema = lurek.docs.schema({hp = {type = "integer"}}, "Stats")
  print("LSchema:typeOf", schema:typeOf("LSchema"), schema:typeOf("Object"))
end

--@api-stub: LDocEntry:getName
-- Returns the short API name stored by this documentation entry.
do
  -- Live scan entries have names without the full module prefix.
  local entry = lurek.docs.scanModule("docs"):getEntries()[1]
  print("LDocEntry:getName", entry and entry:getName() or "none")
end

--@api-stub: LDocEntry:getQualifiedName
-- Returns the full dotted API name stored by this documentation entry.
do
  -- Qualified names are stable keys for lookup and export.
  local entry = lurek.docs.scanModule("docs"):getEntries()[1]
  print("LDocEntry:getQualifiedName", entry and entry:getQualifiedName() or "none")
end

--@api-stub: LDocEntry:getModule
-- Returns the module name associated with this documentation entry.
do
  -- Module names are used for navigation and filtering.
  local entry = lurek.docs.scanModule("docs"):getEntries()[1]
  print("LDocEntry:getModule", entry and entry:getModule() or "none")
end

--@api-stub: LDocEntry:getKind
-- Returns the documentation kind recorded for this entry.
do
  -- Kinds include function, method, type, or value.
  local entry = lurek.docs.scanModule("docs"):getEntries()[1]
  print("LDocEntry:getKind", entry and entry:getKind() or "none")
end

--@api-stub: LDocEntry:getDescription
-- Returns the prose description recorded for this entry.
do
  -- Editable entries can carry descriptions set at runtime.
  lurek.docs.resetCatalog()
  lurek.docs.describe("lurek.example.help", "Shows the help panel.")
  local entry = lurek.docs.getCatalog():getEntry("lurek.example.help")
  print("LDocEntry:getDescription", entry and entry:getDescription() or "none")
end

--@api-stub: LDocEntry:getParameters
-- Returns parameter metadata recorded for this entry.
do
  -- Parameters come from setParamInfo or authored docs.
  lurek.docs.resetCatalog()
  lurek.docs.describe("lurek.example.help", "Shows the help panel.")
  lurek.docs.setParamInfo("lurek.example.help", {{name = "topic", type = "string", description = "Help topic"}})
  local entry = lurek.docs.getCatalog():getEntry("lurek.example.help")
  print("LDocEntry:getParameters", entry and #entry:getParameters() or 0)
end

--@api-stub: LDocEntry:getReturns
-- Returns return-value metadata recorded for this entry.
do
  -- Returns come from setReturnInfo or authored docs.
  lurek.docs.resetCatalog()
  lurek.docs.describe("lurek.example.help", "Shows the help panel.")
  lurek.docs.setReturnInfo("lurek.example.help", {{type = "boolean", description = "True if opened"}})
  local entry = lurek.docs.getCatalog():getEntry("lurek.example.help")
  print("LDocEntry:getReturns", entry and #entry:getReturns() or 0)
end

--@api-stub: LDocEntry:getExample
-- Returns this entry's example text when one was recorded.
do
  -- Live scanned entries usually do not include authored examples.
  local entry = lurek.docs.scanModule("docs"):getEntries()[1]
  print("LDocEntry:getExample", entry and tostring(entry:getExample()) or "none")
end

--@api-stub: LDocEntry:getSince
-- Returns this entry's since-version text when one was recorded.
do
  -- Since metadata is present only in authored catalogs.
  local entry = lurek.docs.scanModule("docs"):getEntries()[1]
  print("LDocEntry:getSince", entry and tostring(entry:getSince()) or "none")
end

--@api-stub: LDocEntry:getDeprecated
-- Returns this entry's deprecation text when one was recorded.
do
  -- Deprecated metadata lets tools warn users about old APIs.
  local entry = lurek.docs.scanModule("docs"):getEntries()[1]
  print("LDocEntry:getDeprecated", entry and tostring(entry:getDeprecated()) or "none")
end

--@api-stub: LDocEntry:getScore
-- Returns the documentation quality score calculated for this entry.
do
  -- Live reflected entries have low scores until authored metadata is merged.
  local entry = lurek.docs.scanModule("docs"):getEntries()[1]
  print("LDocEntry:getScore", entry and entry:getScore() or 0)
end

--@api-stub: LDocEntry:hasDescription
-- Returns whether this entry has non-empty description text.
do
  -- Use this for coverage dashboards.
  local entry = lurek.docs.scanModule("docs"):getEntries()[1]
  print("LDocEntry:hasDescription", entry and entry:hasDescription() or false)
end

--@api-stub: LDocEntry:hasParameters
-- Returns whether this entry has parameter metadata.
do
  -- Parameter coverage is one part of docs quality scoring.
  local entry = lurek.docs.scanModule("docs"):getEntries()[1]
  print("LDocEntry:hasParameters", entry and entry:hasParameters() or false)
end

--@api-stub: LDocEntry:hasReturnType
-- Returns whether this entry has return-value metadata.
do
  -- Return metadata helps editor hovers and generated references.
  local entry = lurek.docs.scanModule("docs"):getEntries()[1]
  print("LDocEntry:hasReturnType", entry and entry:hasReturnType() or false)
end

--@api-stub: LDocEntry:hasExample
-- Returns whether this entry has example text.
do
  -- Examples are optional metadata on catalog entries.
  local entry = lurek.docs.scanModule("docs"):getEntries()[1]
  print("LDocEntry:hasExample", entry and entry:hasExample() or false)
end

--@api-stub: LDocEntry:type
-- Returns the Lua-visible type name for this documentation entry handle.
do
  -- Entry handles report LDocEntry.
  local entry = lurek.docs.scanModule("docs"):getEntries()[1]
  print("LDocEntry:type", entry and entry:type() or "none")
end

--@api-stub: LDocEntry:typeOf
-- Checks whether this handle is a documentation entry.
do
  -- Entries match LDocEntry and Object.
  local entry = lurek.docs.scanModule("docs"):getEntries()[1]
  print("LDocEntry:typeOf", entry and entry:typeOf("LDocEntry") or false)
end

--@api-stub: LApiCatalog:getModules
-- Returns every module represented in this catalog.
do
  -- Module names are sorted for stable navigation lists.
  local modules = lurek.docs.scan():getModules()
  print("LApiCatalog:getModules", #modules)
end

--@api-stub: LApiCatalog:getEntries
-- Returns catalog entries, optionally limited to one module.
do
  -- Pass a module name to filter entries.
  local entries = lurek.docs.scan():getEntries("docs")
  print("LApiCatalog:getEntries", #entries)
end

--@api-stub: LApiCatalog:getEntry
-- Returns one catalog entry by qualified API name.
do
  -- Exact lookup is useful for hover and help pages.
  local catalog = lurek.docs.scanModule("docs")
  local entry = catalog:getEntry("lurek.docs.scan")
  print("LApiCatalog:getEntry", entry and entry:getName() or "none")
end

--@api-stub: LApiCatalog:getTypes
-- Returns type names documented for one module.
do
  -- Live reflection may return no type rows; authored catalogs can add them.
  local types = lurek.docs.getCatalog():getTypes("docs")
  print("LApiCatalog:getTypes", #types)
end

--@api-stub: LApiCatalog:getTypeMethods
-- Returns method entries associated with a qualified type name.
do
  -- This powers per-type method pages.
  local methods = lurek.docs.getCatalog():getTypeMethods("LApiCatalog")
  print("LApiCatalog:getTypeMethods", #methods)
end

--@api-stub: LApiCatalog:entryCount
-- Counts entries in the catalog, optionally for one module.
do
  -- Use entryCount() for quick coverage summaries.
  local catalog = lurek.docs.scan()
  print("LApiCatalog:entryCount", catalog:entryCount(), catalog:entryCount("docs"))
end

--@api-stub: LApiCatalog:merge
-- Merges another catalog into this catalog and returns a new catalog.
do
  -- Later matching entries replace earlier entries by qualified name.
  local live = lurek.docs.scanModule("docs")
  local authored = lurek.docs.getCatalog()
  local merged = live:merge(authored)
  print("LApiCatalog:merge", merged:entryCount())
end

--@api-stub: LApiCatalog:filter
-- Builds a new catalog containing entries accepted by a Lua predicate.
do
  -- Predicates receive LDocEntry handles.
  local functions = lurek.docs.scanModule("docs"):filter(function(entry)
    return entry:getKind() == "function"
  end)
  print("LApiCatalog:filter", functions:entryCount())
end

--@api-stub: LApiCatalog:search
-- Searches names, qualified names, and descriptions.
do
  -- Search is case-insensitive and returns entry handles.
  local results = lurek.docs.scanModule("docs"):search("scan")
  print("LApiCatalog:search", #results)
end

--@api-stub: LApiCatalog:toTable
-- Converts this catalog into plain Lua tables for lightweight inspection.
do
  -- Plain rows are easy to serialize or inspect in a debug panel.
  local rows = lurek.docs.scanModule("docs"):toTable()
  print("LApiCatalog:toTable", #rows, rows[1] and rows[1].qualifiedName or "none")
end

--@api-stub: LApiCatalog:toJSON
-- Serializes this catalog to formatted JSON.
do
  -- JSON export is useful for external tools.
  local json = lurek.docs.scanModule("docs"):toJSON()
  print("LApiCatalog:toJSON", #json)
end

--@api-stub: LApiCatalog:type
-- Returns the Lua-visible type name for this API catalog handle.
do
  -- Catalog handles report LApiCatalog.
  local catalog = lurek.docs.scanModule("docs")
  print("LApiCatalog:type", catalog:type())
end

--@api-stub: LApiCatalog:typeOf
-- Checks whether this handle is an API catalog.
do
  -- Catalogs match LApiCatalog and Object.
  local catalog = lurek.docs.scanModule("docs")
  print("LApiCatalog:typeOf", catalog:typeOf("LApiCatalog"), catalog:typeOf("Object"))
end

--@api-stub: LValidationReport:isValid
-- Returns whether the validation report has no missing live APIs.
do
  -- A valid report has no missing live API entries.
  local report = lurek.docs.validate(lurek.docs.scan())
  print("LValidationReport:isValid", report:isValid())
end

--@api-stub: LValidationReport:getMissing
-- Returns live APIs that were missing from the checked catalog.
do
  -- Missing names exist live but not in the catalog.
  local report = lurek.docs.validate(lurek.docs.getCatalog())
  print("LValidationReport:getMissing", #report:getMissing())
end

--@api-stub: LValidationReport:getPhantom
-- Returns catalog APIs that were not present in live reflection.
do
  -- Phantom names are documented but no longer live.
  lurek.docs.resetCatalog()
  lurek.docs.describe("lurek.missing.fake", "A removed API.")
  local report = lurek.docs.validate(lurek.docs.getCatalog())
  print("LValidationReport:getPhantom", #report:getPhantom())
end

--@api-stub: LValidationReport:getIncomplete
-- Returns catalog APIs whose documentation was incomplete.
do
  -- Incomplete entries exist but lack description, params, or returns.
  local report = lurek.docs.validate(lurek.docs.getCatalog())
  print("LValidationReport:getIncomplete", #report:getIncomplete())
end

--@api-stub: LValidationReport:missingCount
-- Returns the number of live APIs missing from the catalog.
do
  -- Counts are cheaper to display than full name arrays.
  local report = lurek.docs.validate(lurek.docs.getCatalog())
  print("LValidationReport:missingCount", report:missingCount())
end

--@api-stub: LValidationReport:phantomCount
-- Returns the number of catalog APIs absent from live reflection.
do
  -- Phantom counts detect stale docs.
  local report = lurek.docs.validate(lurek.docs.getCatalog())
  print("LValidationReport:phantomCount", report:phantomCount())
end

--@api-stub: LValidationReport:incompleteCount
-- Returns the number of catalog APIs with incomplete documentation.
do
  -- Incomplete counts drive docs quality tasks.
  local report = lurek.docs.validate(lurek.docs.getCatalog())
  print("LValidationReport:incompleteCount", report:incompleteCount())
end

--@api-stub: LValidationReport:getSummary
-- Returns a compact text summary of validation counts.
do
  -- The summary is formatted for logs or CI output.
  local report = lurek.docs.validate(lurek.docs.getCatalog())
  print("LValidationReport:getSummary", report:getSummary())
end

--@api-stub: LValidationReport:toTable
-- Converts this validation report into a plain Lua table.
do
  -- Plain table form is useful for custom dashboards.
  local data = lurek.docs.validate(lurek.docs.getCatalog()):toTable()
  print("LValidationReport:toTable", #(data.missing or {}), #(data.phantom or {}))
end

--@api-stub: LValidationReport:toJSON
-- Serializes this validation report to formatted JSON.
do
  -- JSON form can be written by external build scripts.
  local json = lurek.docs.validate(lurek.docs.getCatalog()):toJSON()
  print("LValidationReport:toJSON", #json)
end

--@api-stub: LValidationReport:type
-- Returns the Lua-visible type name for this validation report handle.
do
  -- Validation reports report LValidationReport.
  local report = lurek.docs.validate(lurek.docs.getCatalog())
  print("LValidationReport:type", report:type())
end

--@api-stub: LValidationReport:typeOf
-- Checks whether this handle is a validation report.
do
  -- Reports match LValidationReport and Object.
  local report = lurek.docs.validate(lurek.docs.getCatalog())
  print("LValidationReport:typeOf", report:typeOf("LValidationReport"), report:typeOf("Object"))
end

--@api-stub: LQualityReport:getOverallScore
-- Returns the aggregate documentation quality score.
do
  -- Overall score ranges from 0 to 1.
  local report = lurek.docs.quality(lurek.docs.scanModule("docs"))
  print("LQualityReport:getOverallScore", report:getOverallScore())
end

--@api-stub: LQualityReport:getGrade
-- Returns the letter grade derived from the aggregate score.
do
  -- Grades are useful for readable quality gates.
  local report = lurek.docs.quality(lurek.docs.scanModule("docs"))
  print("LQualityReport:getGrade", report:getGrade())
end

--@api-stub: LQualityReport:getModuleScores
-- Returns per-module documentation quality scores.
do
  -- The returned table maps module name to score.
  local scores = lurek.docs.quality(lurek.docs.scan()):getModuleScores()
  print("LQualityReport:getModuleScores", scores.docs or 0)
end

--@api-stub: LQualityReport:getWorst
-- Returns the lowest-scoring documentation entries.
do
  -- Use getWorst() to prioritize docs improvements.
  local rows = lurek.docs.quality(lurek.docs.scanModule("docs")):getWorst(3)
  print("LQualityReport:getWorst", #rows)
end

--@api-stub: LQualityReport:getBest
-- Returns the highest-scoring documentation entries.
do
  -- Use getBest() to find examples of complete docs.
  local rows = lurek.docs.quality(lurek.docs.scanModule("docs")):getBest(3)
  print("LQualityReport:getBest", #rows)
end

--@api-stub: LQualityReport:getByGrade
-- Returns entries whose calculated grade matches a grade string.
do
  -- This helps batch lower-grade entries.
  local rows = lurek.docs.quality(lurek.docs.scanModule("docs")):getByGrade("F")
  print("LQualityReport:getByGrade", #rows)
end

--@api-stub: LQualityReport:getSummary
-- Returns a human-readable summary of quality scores.
do
  -- The summary is formatted for log or terminal output.
  local summary = lurek.docs.quality(lurek.docs.scanModule("docs")):getSummary()
  print("LQualityReport:getSummary", summary:sub(1, 20))
end

--@api-stub: LQualityReport:toTable
-- Converts this quality report into a plain Lua table.
do
  -- Plain table form is useful for custom dashboards.
  local data = lurek.docs.quality(lurek.docs.scanModule("docs")):toTable()
  print("LQualityReport:toTable", data.grade, data.overallScore)
end

--@api-stub: LQualityReport:toJSON
-- Serializes this quality report to formatted JSON.
do
  -- JSON form can be saved by build tools.
  local json = lurek.docs.quality(lurek.docs.scanModule("docs")):toJSON()
  print("LQualityReport:toJSON", #json)
end

--@api-stub: LQualityReport:type
-- Returns the Lua-visible type name for this quality report handle.
do
  -- Quality reports report LQualityReport.
  local report = lurek.docs.quality(lurek.docs.scanModule("docs"))
  print("LQualityReport:type", report:type())
end

--@api-stub: LQualityReport:typeOf
-- Checks whether this handle is a quality report.
do
  -- Quality reports match LQualityReport and Object.
  local report = lurek.docs.quality(lurek.docs.scanModule("docs"))
  print("LQualityReport:typeOf", report:typeOf("LQualityReport"), report:typeOf("Object"))
end

print("content/examples/docs.lua")
