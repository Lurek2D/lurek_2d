-- content/examples/docs.lua
-- lurek.docs API examples.
-- Run: cargo run -- content/examples/docs.lua

--@api-stub: lurek.docs.scan -- Reflects the live `lurek` table and builds a catalog of callable APIs
do -- lurek.docs.scan
  local catalog = lurek.docs.scan()
  local count = catalog:entryCount()
  lurek.log.info("docs", "scanned " .. count .. " live API entries")
end

--@api-stub: lurek.docs.scanModule -- Reflects one live `lurek
do -- lurek.docs.scanModule
  local audio_cat = lurek.docs.scanModule("audio")
  for _, entry in ipairs(audio_cat:getEntries()) do
    lurek.log.debug("audio-api", entry:getQualifiedName())
  end
end

--@api-stub: lurek.docs.loadToml -- Loads a TOML documentation catalog file and converts its entries into an API catalog
do -- lurek.docs.loadToml
  local ok, catalog = pcall(lurek.docs.loadToml, "docs/api/audio.toml")
  if ok and catalog:entryCount() == 0 then
    lurek.log.warn("docs", "audio.toml had no entries")
  end
end

--@api-stub: lurek.docs.loadAll -- Loads all TOML documentation catalog files from a directory and combines their entries
do -- lurek.docs.loadAll
  local ok, catalog = pcall(lurek.docs.loadAll, "docs/api")
  if ok then
    local mods = catalog:getModules()
    lurek.log.info("docs", "loaded " .. #mods .. " documented modules")
  end
end

--@api-stub: lurek.docs.describe -- Adds or updates the description for one editable catalog entry
do -- lurek.docs.describe
  lurek.docs.scan()
  lurek.docs.describe("lurek.audio.play", "Play a sound source by name.")
  lurek.docs.describe("lurek.audio.stop", "Stop a currently playing source.")
end

--@api-stub: lurek.docs.setParamInfo -- Replaces parameter metadata for one editable catalog entry
do -- lurek.docs.setParamInfo
  lurek.docs.scan()
  lurek.docs.setParamInfo("lurek.audio.play", {
    { name = "name", type = "string", description = "source id", optional = false },
    { name = "loop", type = "boolean", description = "loop on end", optional = true, default = false },
  })
end

--@api-stub: lurek.docs.setReturnInfo -- Replaces return-value metadata for one editable catalog entry
do -- lurek.docs.setReturnInfo
  lurek.docs.scan()
  lurek.docs.setReturnInfo("lurek.audio.play", {
    { type = "Source", description = "the playing audio source" },
  })
end

--@api-stub: lurek.docs.getCatalog -- Returns the editable in-memory documentation catalog
do -- lurek.docs.getCatalog
  lurek.docs.scan()
  local cat = lurek.docs.getCatalog()
  lurek.log.info("docs", "internal catalog has " .. cat:entryCount() .. " entries")
end

--@api-stub: lurek.docs.resetCatalog -- Clears the editable in-memory documentation catalog
do -- lurek.docs.resetCatalog
  lurek.docs.scan()
  lurek.docs.resetCatalog()
  assert(lurek.docs.getCatalog():entryCount() == 0, "catalog should be empty")
end

--@api-stub: lurek.docs.validate -- Compares a documentation catalog with the live reflected `lurek` API table
do -- lurek.docs.validate
  local catalog = lurek.docs.loadAll("docs/api")
  local report = lurek.docs.validate(catalog)
  if not report:isValid() then
    lurek.log.error("docs", "missing " .. report:missingCount() .. " entries")
  end
end

--@api-stub: lurek.docs.validateModule -- Compares one module's documentation catalog entries with the live reflected module table
do -- lurek.docs.validateModule
  local ok, catalog = pcall(lurek.docs.loadToml, "docs/api/audio.toml")
  if ok then
    local report = lurek.docs.validateModule("audio", catalog)
    for _, name in ipairs(report:getMissing()) do
      lurek.log.warn("audio-docs", "undocumented: " .. name)
    end
  end
end

--@api-stub: lurek.docs.checkStaleness -- Lists source files in a directory for simple documentation staleness checks
do -- lurek.docs.checkStaleness
  local catalog = lurek.docs.loadAll("docs/api")
  local result = lurek.docs.checkStaleness(catalog, "src/lua_api")
  lurek.log.info("docs", "scanned " .. #result.current .. " source files")
end

--@api-stub: lurek.docs.quality -- Computes documentation quality for a supplied catalog or the editable in-memory catalog
do -- lurek.docs.quality
  local catalog = lurek.docs.loadAll("docs/api")
  local q = lurek.docs.quality(catalog)
  lurek.log.info("docs", string.format("overall %.2f (%s)", q:getOverallScore(), q:getGrade()))
end

--@api-stub: lurek.docs.qualityModule -- Computes documentation quality for entries belonging to one module
do -- lurek.docs.qualityModule
  local catalog = lurek.docs.loadAll("docs/api")
  local q = lurek.docs.qualityModule("audio", catalog)
  lurek.log.info("audio-docs", "audio module grade: " .. q:getGrade())
end

--@api-stub: lurek.docs.coverage -- Returns documented and live API counts for the full `lurek` table
do -- lurek.docs.coverage
  local catalog = lurek.docs.loadAll("docs/api")
  local documented, total = lurek.docs.coverage(catalog)
  lurek.log.info("docs", string.format("coverage %d/%d", documented, total))
end

--@api-stub: lurek.docs.coverageModule -- Returns documented and live API counts for one module
do -- lurek.docs.coverageModule
  local ok, catalog = pcall(lurek.docs.loadToml, "docs/api/audio.toml")
  if ok then
    local documented, total = lurek.docs.coverageModule("audio", catalog)
    lurek.log.info("audio-docs", string.format("audio %d/%d", documented, total))
  end
end

--@api-stub: lurek.docs.exportCompletions -- Exports catalog completion metadata to a file
do -- lurek.docs.exportCompletions
  local catalog = lurek.docs.scan()
  pcall(lurek.docs.exportCompletions, catalog, "build/vscode/completions.json")
  lurek.log.info("docs", "wrote completions.json")
end

--@api-stub: lurek.docs.exportHover -- Exports catalog hover metadata to a file
do -- lurek.docs.exportHover
  local catalog = lurek.docs.scan()
  pcall(lurek.docs.exportHover, catalog, "build/vscode/hover.json")
  lurek.log.info("docs", "wrote hover.json")
end

--@api-stub: lurek.docs.exportSignatures -- Exports catalog signature metadata to a file
do -- lurek.docs.exportSignatures
  local catalog = lurek.docs.scan()
  pcall(lurek.docs.exportSignatures, catalog, "build/vscode/signatures.json")
  lurek.log.info("docs", "wrote signatures.json")
end

--@api-stub: lurek.docs.exportAll -- Exports all editor documentation artifacts for a catalog into a directory
do -- lurek.docs.exportAll
  local catalog = lurek.docs.scan()
  pcall(lurek.docs.exportAll, catalog, "build/vscode")
  lurek.log.info("docs", "wrote full editor bundle")
end

--@api-stub: lurek.docs.exportMarkdown -- Writes a Markdown API reference from catalog entries
do -- lurek.docs.exportMarkdown
  local catalog = lurek.docs.loadAll("docs/api")
  pcall(lurek.docs.exportMarkdown, catalog, "build/lua-api.md")
  lurek.log.info("docs", "regenerated lua-api.md")
end

--@api-stub: lurek.docs.exportCheatsheet -- Writes a compact text cheatsheet from catalog entries
do -- lurek.docs.exportCheatsheet
  local catalog = lurek.docs.scan()
  pcall(lurek.docs.exportCheatsheet, catalog, "build/cheatsheet.txt")
  lurek.log.info("docs", "wrote cheatsheet.txt")
end

--@api-stub: lurek.docs.schema -- Builds a schema validator from Lua table rules
do -- lurek.docs.schema
  local schema = lurek.docs.schema({
    name  = { type = "string", required = true, minLen = 1 },
    level = { type = "integer", required = true, min = 1, max = 99 },
    class = { type = "string", enum = { "warrior", "mage", "rogue" } },
  }, "PlayerSave")
  schema:assert({ name = "Hero", level = 1, class = "warrior" })
end

--@api-stub: lurek.docs.schemaFromToml -- Builds a schema validator from TOML schema text
do -- lurek.docs.schemaFromToml
  local schema_toml = [[
name = "PlayerSave"
strict = true

[rules.level]
type = "integer"
required = true
min = 1
max = 99
  ]]
  local schema = lurek.docs.schemaFromToml(schema_toml)
  schema:assert({ level = 10 })
end

--@api-stub: lurek.docs.reflectLive -- Reflects live `lurek` module tables into plain name and type rows
do -- lurek.docs.reflectLive
  local audio_only = lurek.docs.reflectLive("audio")
  for _, item in ipairs(audio_only.audio or {}) do
    lurek.log.debug("reflect", item.name .. " (" .. item.type .. ")")
  end
end

--@api-stub: lurek.docs.reflectTable -- Reflects an arbitrary Lua table into name, qualifiedName, and type rows
do -- lurek.docs.reflectTable
  local mod = { greet = function(_) end, version = "1.0", count = 3 }
  local items = lurek.docs.reflectTable(mod, "mymod")
  for _, it in ipairs(items) do
    lurek.log.debug("reflect", it.qualifiedName .. " : " .. it.type)
  end
end

-- â”€â”€ Schema methods â”€â”€

--@api-stub: Schema:validate
do -- Schema:validate
  local schema = lurek.docs.schema({ hp = { type = "integer", required = true, min = 0 } }, "Stats")
  local result = schema:validate({ hp = -5 })
  local count = (type(result) == "table") and #result or (result and 0 or 1)
  if count > 0 then
    lurek.log.warn("schema", "got " .. count .. " validation errors")
  end
end

--@api-stub: Schema:check
do -- Schema:check
  local schema = lurek.docs.schema({ port = { type = "integer", min = 1, max = 65535 } }, "Net")
  if not schema:check({ port = 8080 }) then
    lurek.log.error("net", "invalid network config")
  end
end

--@api-stub: Schema:assert
do -- Schema:assert
  local schema = lurek.docs.schema({ width = { type = "integer", required = true, min = 1 } }, "Window")
  schema:assert({ width = 1280 })
  lurek.log.info("config", "window config validated")
end

--@api-stub: Schema:getName
do -- Schema:getName
  local schema = lurek.docs.schema({ x = { type = "number" } }, "Point")
  local label = schema:getName()
  lurek.log.debug("schema", "loaded schema: " .. label)
end

--@api-stub: Schema:getFields
do -- Schema:getFields
  local schema = lurek.docs.schema({ a = { type = "string" }, b = { type = "number" } }, "AB")
  for _, field in ipairs(schema:getFields()) do
    lurek.log.debug("schema", "field: " .. field)
  end
end

-- â”€â”€ DocEntry methods â”€â”€

--@api-stub: DocEntry:getName
do -- DocEntry:getName
  local catalog = lurek.docs.scanModule("audio")
  local entry = catalog:getEntries()[1]
  if entry then lurek.log.debug("docs", "first audio entry: " .. entry:getName()) end
end

--@api-stub: DocEntry:getQualifiedName
do -- DocEntry:getQualifiedName
  local catalog = lurek.docs.scan()
  for _, e in ipairs(catalog:getEntries()) do
    if e:getName() == "info" then lurek.log.debug("docs", e:getQualifiedName()) end
  end
end

--@api-stub: DocEntry:getModule
do -- DocEntry:getModule
  local catalog = lurek.docs.scan()
  local first = catalog:getEntries()[1]
  if first then lurek.log.debug("docs", "module: " .. first:getModule()) end
end

--@api-stub: DocEntry:getKind
do -- DocEntry:getKind
  local catalog = lurek.docs.scan()
  for _, e in ipairs(catalog:getEntries()) do
    if e:getKind() == "type" then lurek.log.debug("docs", "type: " .. e:getQualifiedName()) end
  end
end

--@api-stub: DocEntry:getDescription
do -- DocEntry:getDescription
  local ok, catalog = pcall(lurek.docs.loadToml, "docs/api/audio.toml")
  if ok then
    local entry = catalog:getEntry("lurek.audio.play")
    if entry then lurek.log.info("docs", entry:getDescription()) end
  end
end

--@api-stub: DocEntry:getParameters
do -- DocEntry:getParameters
  local ok, catalog = pcall(lurek.docs.loadToml, "docs/api/audio.toml")
  if ok then
    local entry = catalog:getEntry("lurek.audio.play")
    if entry then
      for _, p in ipairs(entry:getParameters()) do
        lurek.log.debug("docs", p.name .. " : " .. p.type)
      end
    end
  end
end

--@api-stub: DocEntry:getReturns
do -- DocEntry:getReturns
  local ok, catalog = pcall(lurek.docs.loadToml, "docs/api/audio.toml")
  if ok then
    local entry = catalog:getEntry("lurek.audio.play")
    if entry then
      for _, r in ipairs(entry:getReturns()) do
        lurek.log.debug("docs", "returns " .. r.type)
      end
    end
  end
end

--@api-stub: DocEntry:getExample
do -- DocEntry:getExample
  local catalog = lurek.docs.loadAll("docs/api")
  local entry = catalog:getEntry("lurek.audio.play")
  local snippet = entry and entry:getExample()
  if snippet then lurek.log.info("docs", "example:\n" .. snippet) end
end

--@api-stub: DocEntry:getSince
do -- DocEntry:getSince
  local catalog = lurek.docs.loadAll("docs/api")
  for _, e in ipairs(catalog:getEntries()) do
    local v = e:getSince()
    if v == "0.6.0" then lurek.log.info("docs", "new in 0.6: " .. e:getQualifiedName()) end
  end
end

--@api-stub: DocEntry:getDeprecated
do -- DocEntry:getDeprecated
  local catalog = lurek.docs.loadAll("docs/api")
  for _, e in ipairs(catalog:getEntries()) do
    local msg = e:getDeprecated()
    if msg then lurek.log.warn("deprecated", e:getQualifiedName() .. " â€” " .. msg) end
  end
end

--@api-stub: DocEntry:getScore
do -- DocEntry:getScore
  local catalog = lurek.docs.loadAll("docs/api")
  for _, e in ipairs(catalog:getEntries()) do
    if e:getScore() < 0.5 then lurek.log.warn("docs", "low score: " .. e:getQualifiedName()) end
  end
end

--@api-stub: DocEntry:hasDescription
do -- DocEntry:hasDescription
  local catalog = lurek.docs.scan()
  local missing = 0
  for _, e in ipairs(catalog:getEntries()) do
    if not e:hasDescription() then missing = missing + 1 end
  end
  lurek.log.info("docs", missing .. " entries missing descriptions")
end

--@api-stub: DocEntry:hasParameters
do -- DocEntry:hasParameters
  local catalog = lurek.docs.loadAll("docs/api")
  for _, e in ipairs(catalog:getEntries()) do
    if e:getKind() == "function" and not e:hasParameters() then
      lurek.log.debug("docs", "no params: " .. e:getQualifiedName())
    end
  end
end

--@api-stub: DocEntry:hasReturnType
do -- DocEntry:hasReturnType
  local catalog = lurek.docs.loadAll("docs/api")
  for _, e in ipairs(catalog:getEntries()) do
    if e:getKind() == "function" and not e:hasReturnType() then
      lurek.log.debug("docs", "no return info: " .. e:getQualifiedName())
    end
  end
end

--@api-stub: DocEntry:hasExample
do -- DocEntry:hasExample
  local catalog = lurek.docs.loadAll("docs/api")
  local without = 0
  for _, e in ipairs(catalog:getEntries()) do
    if not e:hasExample() then without = without + 1 end
  end
  lurek.log.info("docs", without .. " entries lack examples")
end

-- â”€â”€ ApiCatalog methods â”€â”€

--@api-stub: ApiCatalog:getModules
do -- ApiCatalog:getModules
  local catalog = lurek.docs.scan()
  for _, name in ipairs(catalog:getModules()) do
    lurek.log.debug("docs", "module: " .. name)
  end
end

--@api-stub: ApiCatalog:getEntries
do -- ApiCatalog:getEntries
  local catalog = lurek.docs.scan()
  local audio_entries = catalog:getEntries("audio")
  lurek.log.info("docs", "audio has " .. #audio_entries .. " entries")
end

--@api-stub: ApiCatalog:getEntry
do -- ApiCatalog:getEntry
  local catalog = lurek.docs.scan()
  local entry = catalog:getEntry("lurek.audio.play")
  if entry then lurek.log.info("docs", "found: " .. entry:getQualifiedName()) end
end

--@api-stub: ApiCatalog:getTypes
do -- ApiCatalog:getTypes
  local catalog = lurek.docs.loadAll("docs/api")
  for _, t in ipairs(catalog:getTypes("audio")) do
    lurek.log.debug("docs", "audio type: " .. t)
  end
end

--@api-stub: ApiCatalog:getTypeMethods
do -- ApiCatalog:getTypeMethods
  local catalog = lurek.docs.loadAll("docs/api")
  for _, m in ipairs(catalog:getTypeMethods("lurek.audio.Source")) do
    lurek.log.debug("docs", "Source method: " .. m:getName())
  end
end

--@api-stub: ApiCatalog:entryCount
do -- ApiCatalog:entryCount
  local catalog = lurek.docs.scan()
  local total = catalog:entryCount()
  local audio = catalog:entryCount("audio")
  lurek.log.info("docs", string.format("total %d, audio %d", total, audio))
end

--@api-stub: ApiCatalog:merge
do -- ApiCatalog:merge
  local live = lurek.docs.scan()
  local toml = lurek.docs.loadAll("docs/api")
  local merged = live:merge(toml)
  lurek.log.info("docs", "merged " .. merged:entryCount() .. " entries")
end

--@api-stub: ApiCatalog:filter
do -- ApiCatalog:filter
  local catalog = lurek.docs.loadAll("docs/api")
  local deprecated = catalog:filter(function(e) return e:getDeprecated() ~= nil end)
  lurek.log.info("docs", deprecated:entryCount() .. " deprecated entries")
end

--@api-stub: ApiCatalog:search
do -- ApiCatalog:search
  local catalog = lurek.docs.scan()
  for _, e in ipairs(catalog:search("play")) do
    lurek.log.debug("docs", "match: " .. e:getQualifiedName())
  end
end

--@api-stub: ApiCatalog:toTable
do -- ApiCatalog:toTable
  local catalog = lurek.docs.scan()
  local raw = catalog:toTable()
  lurek.log.info("docs", "raw catalog has " .. #raw .. " rows")
end

--@api-stub: ApiCatalog:toJSON
do -- ApiCatalog:toJSON
  local catalog = lurek.docs.scan()
  local json = catalog:toJSON()
  pcall(function() lurek.fs.write("build/api-catalog.json", json) end)
end

-- â”€â”€ ValidationReport methods â”€â”€

--@api-stub: ValidationReport:isValid
do -- ValidationReport:isValid
  local catalog = lurek.docs.loadAll("docs/api")
  local report = lurek.docs.validate(catalog)
  if not report:isValid() then lurek.log.error("docs", "validation failed") end
end

--@api-stub: ValidationReport:getMissing
do -- ValidationReport:getMissing
  local report = lurek.docs.validate(lurek.docs.loadAll("docs/api"))
  for _, name in ipairs(report:getMissing()) do
    lurek.log.warn("docs", "missing docs: " .. name)
  end
end

--@api-stub: ValidationReport:getPhantom
do -- ValidationReport:getPhantom
  local report = lurek.docs.validate(lurek.docs.loadAll("docs/api"))
  for _, name in ipairs(report:getPhantom()) do
    lurek.log.warn("docs", "remove stale doc: " .. name)
  end
end

--@api-stub: ValidationReport:getIncomplete
do -- ValidationReport:getIncomplete
  local report = lurek.docs.validate(lurek.docs.loadAll("docs/api"))
  for _, name in ipairs(report:getIncomplete()) do
    lurek.log.info("docs", "needs more detail: " .. name)
  end
end

--@api-stub: ValidationReport:missingCount
do -- ValidationReport:missingCount
  local report = lurek.docs.validate(lurek.docs.loadAll("docs/api"))
  if report:missingCount() > 0 then
    lurek.log.error("docs", "missing " .. report:missingCount() .. " doc entries")
  end
end

--@api-stub: ValidationReport:phantomCount
do -- ValidationReport:phantomCount
  local report = lurek.docs.validate(lurek.docs.loadAll("docs/api"))
  lurek.log.info("docs", report:phantomCount() .. " phantom doc entries")
end

--@api-stub: ValidationReport:incompleteCount
do -- ValidationReport:incompleteCount
  local report = lurek.docs.validate(lurek.docs.loadAll("docs/api"))
  lurek.log.info("docs", report:incompleteCount() .. " incomplete doc entries")
end

--@api-stub: ValidationReport:getSummary
do -- ValidationReport:getSummary
  local report = lurek.docs.validate(lurek.docs.loadAll("docs/api"))
  lurek.log.info("docs", report:getSummary())
end

--@api-stub: ValidationReport:toTable
do -- ValidationReport:toTable
  local report = lurek.docs.validate(lurek.docs.loadAll("docs/api"))
  local data = report:toTable()
  lurek.log.info("docs", "missing rows: " .. #(data.missing or {}))
end

--@api-stub: ValidationReport:toJSON
do -- ValidationReport:toJSON
  local report = lurek.docs.validate(lurek.docs.loadAll("docs/api"))
  pcall(function() lurek.fs.write("build/docs-validation.json", report:toJSON()) end)
end

-- â”€â”€ QualityReport methods â”€â”€

--@api-stub: QualityReport:getOverallScore
do -- QualityReport:getOverallScore
  local q = lurek.docs.quality(lurek.docs.loadAll("docs/api"))
  if q:getOverallScore() < 0.8 then lurek.log.warn("docs", "quality below threshold") end
end

--@api-stub: QualityReport:getGrade
do -- QualityReport:getGrade
  local q = lurek.docs.quality(lurek.docs.loadAll("docs/api"))
  lurek.log.info("docs", "docs grade: " .. q:getGrade())
end

--@api-stub: QualityReport:getModuleScores
do -- QualityReport:getModuleScores
  local q = lurek.docs.quality(lurek.docs.loadAll("docs/api"))
  for module, score in pairs(q:getModuleScores()) do
    lurek.log.debug("docs", string.format("%s : %.2f", module, score))
  end
end

--@api-stub: QualityReport:getWorst
do -- QualityReport:getWorst
  local q = lurek.docs.quality(lurek.docs.loadAll("docs/api"))
  for _, e in ipairs(q:getWorst(10)) do
    lurek.log.warn("docs", "worst: " .. e:getQualifiedName())
  end
end

--@api-stub: QualityReport:getBest
do -- QualityReport:getBest
  local q = lurek.docs.quality(lurek.docs.loadAll("docs/api"))
  for _, e in ipairs(q:getBest(5)) do
    lurek.log.info("docs", "exemplar: " .. e:getQualifiedName())
  end
end

--@api-stub: QualityReport:getByGrade
do -- QualityReport:getByGrade
  local q = lurek.docs.quality(lurek.docs.loadAll("docs/api"))
  for _, e in ipairs(q:getByGrade("C")) do
    lurek.log.info("docs", "grade C: " .. e:getQualifiedName())
  end
end

--@api-stub: QualityReport:getSummary
do -- QualityReport:getSummary
  local q = lurek.docs.quality(lurek.docs.loadAll("docs/api"))
  lurek.log.info("docs", q:getSummary())
end

--@api-stub: QualityReport:toTable
do -- QualityReport:toTable
  local q = lurek.docs.quality(lurek.docs.loadAll("docs/api"))
  local data = q:toTable()
  lurek.log.info("docs", "table overall: " .. tostring(data.overall_score))
end

--@api-stub: QualityReport:toJSON
do -- QualityReport:toJSON
  local q = lurek.docs.quality(lurek.docs.loadAll("docs/api"))
  pcall(function() lurek.fs.write("build/docs-quality.json", q:toJSON()) end)
end

-- =============================================================================
-- COVERAGE: 7 uncovered lurek.docs API item(s)
-- Generated by tools/audit/example_add_missing.py
-- REQUIRED: replace every --@api-stub: block below with a real scenario.
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- The final committed file must contain ZERO --@api-stub: lines.
-- =============================================================================

--@api-stub: lurek.docs.loadToml -- Loads a TOML documentation catalog file and converts its entries into an API catalog
do -- lurek.docs.loadToml
  local ok, cat = pcall(lurek.docs.loadToml, "docs/api/lurek.md")
  -- ok=false if file schema doesn't match; that's fine for headless testing
end

--@api-stub: lurek.docs.exportCompletions -- Exports catalog completion metadata to a file
do -- lurek.docs.exportCompletions
  local cat = lurek.docs.loadAll("docs/api")
  pcall(lurek.docs.exportCompletions, cat, "build/tmp/completions.json")
end

--@api-stub: lurek.docs.exportHover -- Exports catalog hover metadata to a file
do -- lurek.docs.exportHover
  local cat = lurek.docs.loadAll("docs/api")
  pcall(lurek.docs.exportHover, cat, "build/tmp/hover.json")
end

--@api-stub: lurek.docs.exportSignatures -- Exports catalog signature metadata to a file
do -- lurek.docs.exportSignatures
  local cat = lurek.docs.loadAll("docs/api")
  pcall(lurek.docs.exportSignatures, cat, "build/tmp/signatures.json")
end

--@api-stub: lurek.docs.exportAll -- Exports all editor documentation artifacts for a catalog into a directory
do -- lurek.docs.exportAll
  local cat = lurek.docs.loadAll("docs/api")
  pcall(lurek.docs.exportAll, cat, "build/tmp")
end

--@api-stub: lurek.docs.exportMarkdown -- Writes a Markdown API reference from catalog entries
do -- lurek.docs.exportMarkdown
  local cat = lurek.docs.loadAll("docs/api")
  pcall(lurek.docs.exportMarkdown, cat, "build/tmp/api.md")
end

--@api-stub: lurek.docs.exportCheatsheet -- Writes a compact text cheatsheet from catalog entries
do -- lurek.docs.exportCheatsheet
  local cat = lurek.docs.loadAll("docs/api")
  pcall(lurek.docs.exportCheatsheet, cat, "build/tmp/cheatsheet.txt")
end

-- =============================================================================
-- COVERAGE: 17 uncovered lurek.docs API item(s)
-- Generated by tools/audit/example_add_missing.py
-- REQUIRED: replace every --@api-stub: block below with a real scenario.
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- The final committed file must contain ZERO --@api-stub: lines.
-- =============================================================================

--@api-stub: LApiCatalog:type -- Returns the Lua-visible type name for this API catalog handle
do -- LApiCatalog:type
  local api_catalog_obj = lurek.docs.scan(nil)
  local t = api_catalog_obj:type()
  lurek.log.info("LApiCatalog:type = " .. t, "docs")
end
--@api-stub: LApiCatalog:typeOf -- Returns whether this API catalog handle matches a supported type name
do -- LApiCatalog:typeOf
  local api_catalog_obj = lurek.docs.scan(nil)
  lurek.log.info("is LApiCatalog: " .. tostring(api_catalog_obj:typeOf("LApiCatalog")), "docs")
  lurek.log.info("is wrong: " .. tostring(api_catalog_obj:typeOf("Unknown")), "docs")
end
--@api-stub: LDocEntry:type -- Returns the Lua-visible type name for this documentation entry handle
do -- LDocEntry:type
  local catalog = lurek.docs.scanModule("audio")
    local entry = catalog:getEntries()[1]
  local t = catalog:type()
  lurek.log.info("LDocEntry:type = " .. t, "docs")
end
--@api-stub: LDocEntry:typeOf -- Returns whether this documentation entry handle matches a supported type name
do -- LDocEntry:typeOf
  local catalog = lurek.docs.scanModule("audio")
    local entry = catalog:getEntries()[1]
  lurek.log.info("is LDocEntry: " .. tostring(catalog:typeOf("LDocEntry")), "docs")
  lurek.log.info("is wrong: " .. tostring(catalog:typeOf("Unknown")), "docs")
end
--@api-stub: LQualityReport:type -- Returns the Lua-visible type name for this quality report handle
do -- LQualityReport:type
  local q = lurek.docs.quality(lurek.docs.loadAll("docs/api"))
  local t = q:type()
  lurek.log.info("LQualityReport:type = " .. t, "docs")
end
--@api-stub: LQualityReport:typeOf -- Returns whether this quality report handle matches a supported type name
do -- LQualityReport:typeOf
  local q = lurek.docs.quality(lurek.docs.loadAll("docs/api"))
  lurek.log.info("is LQualityReport: " .. tostring(q:typeOf("LQualityReport")), "docs")
  lurek.log.info("is wrong: " .. tostring(q:typeOf("Unknown")), "docs")
end
--@api-stub: LSchema:type -- Returns the Lua-visible type name for this schema handle
do -- LSchema:type
  local schema = lurek.docs.schema({ hp = { type = "integer", required = true, min = 0 } }, "Stats")
  local result = schema:validate({ hp = -5 })
  local count = (type(result) == "table") and #result or (result and 0 or 1)
  if count > 0 then
    lurek.log.info("validation errors: " .. count, "docs")
  end
  local t = schema:type()
  lurek.log.info("LSchema:type = " .. t, "docs")
end
--@api-stub: LSchema:typeOf -- Returns whether this schema handle matches a supported type name
do -- LSchema:typeOf
  local schema = lurek.docs.schema({ hp = { type = "integer", required = true, min = 0 } }, "Stats")
  local result = schema:validate({ hp = -5 })
  local count = (type(result) == "table") and #result or (result and 0 or 1)
  if count > 0 then
    lurek.log.info("validation errors: " .. count, "docs")
  end
  lurek.log.info("is LSchema: " .. tostring(schema:typeOf("LSchema")), "docs")
  lurek.log.info("is wrong: " .. tostring(schema:typeOf("Unknown")), "docs")
end
--@api-stub: LValidationReport:type -- Returns the Lua-visible type name for this validation report handle
do -- LValidationReport:type
  local validation_report_obj = lurek.docs.validate(nil)
  local t = validation_report_obj:type()
  lurek.log.info("LValidationReport:type = " .. t, "docs")
end
--@api-stub: LValidationReport:typeOf -- Returns whether this validation report handle matches a supported type name
do -- LValidationReport:typeOf
  local validation_report_obj = lurek.docs.validate(nil)
  lurek.log.info("is LValidationReport: " .. tostring(validation_report_obj:typeOf("LValidationReport")), "docs")
  lurek.log.info("is wrong: " .. tostring(validation_report_obj:typeOf("Unknown")), "docs")
end


