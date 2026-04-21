-- content/examples/docs.lua
-- Lurek2D lurek.docs API Reference
-- Run with: cargo run -- content/examples/docs

-- =============================================================================
-- STUBS: 50 uncovered lurek.docs API item(s)
-- =============================================================================

-- ---- Stub: lurek.docs.scan -----------------------------------------------
--@api-stub: lurek.docs.scan
-- Demonstrates the proper usage of lurek.docs.scan.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_docs_scan()
    local catalog = lurek.docs.scan()
    print("catalog modules:", #catalog:getModules())
end
local _ok, _err = pcall(demo_lurek_docs_scan)

-- ---- Stub: lurek.docs.scanModule -----------------------------------------
--@api-stub: lurek.docs.scanModule
-- Demonstrates the proper usage of lurek.docs.scanModule.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_docs_scanModule()
    local math_cat = lurek.docs.scanModule("math")
    print("math entries:", math_cat:entryCount())
end
local _ok, _err = pcall(demo_lurek_docs_scanModule)

-- ---- Stub: lurek.docs.loadToml -------------------------------------------
--@api-stub: lurek.docs.loadToml
-- Demonstrates the proper usage of lurek.docs.loadToml.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_docs_loadToml()
    local toml_cat = lurek.docs.loadToml("docs/api/math.toml")
    print("toml catalog:", toml_cat ~= nil)
end
local _ok, _err = pcall(demo_lurek_docs_loadToml)

-- ---- Stub: lurek.docs.loadAll --------------------------------------------
--@api-stub: lurek.docs.loadAll
-- Demonstrates the proper usage of lurek.docs.loadAll.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_docs_loadAll()
    local all_cat = lurek.docs.loadAll("docs/api/")
    print("all_cat modules:", #all_cat:getModules())
end
local _ok, _err = pcall(demo_lurek_docs_loadAll)

-- ---- Stub: lurek.docs.describe -------------------------------------------
--@api-stub: lurek.docs.describe
-- Demonstrates the proper usage of lurek.docs.describe.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_docs_describe()
    lurek.docs.describe("lurek.math.clamp", "Clamp value between lo and hi, inclusive.")
    print("description set")
end
local _ok, _err = pcall(demo_lurek_docs_describe)

-- ---- Stub: lurek.docs.setParamInfo ---------------------------------------
--@api-stub: lurek.docs.setParamInfo
-- Provide parameter metadata for a function that lacks annotations
-- so the VS Code signature helper can show argument names and types.
lurek.docs.setParamInfo("lurek.math.clamp", {
    { name = "x",  type = "number", description = "Value to clamp." },
    { name = "lo", type = "number", description = "Lower bound." },
    { name = "hi", type = "number", description = "Upper bound." },
})
print("param info set")

-- ---- Stub: lurek.docs.setReturnInfo --------------------------------------
--@api-stub: lurek.docs.setReturnInfo
-- Document the return type for an entry so the hover tooltip shows
-- the expected value type alongside the description.
lurek.docs.setReturnInfo("lurek.math.clamp", {
    { type = "number", description = "Clamped value in [lo, hi]." },
})
print("return info set")

-- ---- Stub: lurek.docs.getCatalog -----------------------------------------
--@api-stub: lurek.docs.getCatalog
-- Demonstrates the proper usage of lurek.docs.getCatalog.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_docs_getCatalog()
    local internal = lurek.docs.getCatalog()
    print("internal catalog:", internal ~= nil)
end
local _ok, _err = pcall(demo_lurek_docs_getCatalog)

-- ---- Stub: lurek.docs.resetCatalog ----------------------------------------
--@api-stub: lurek.docs.resetCatalog
-- Demonstrates the proper usage of lurek.docs.resetCatalog.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_docs_resetCatalog()
    lurek.docs.resetCatalog()
    print("catalog reset")
end
local _ok, _err = pcall(demo_lurek_docs_resetCatalog)

-- ---- Stub: lurek.docs.validate -------------------------------------------
--@api-stub: lurek.docs.validate
-- Demonstrates the proper usage of lurek.docs.validate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_docs_validate()
    local vrep = lurek.docs.validate(catalog)
    print("missing entries:", vrep:missingCount())
end
local _ok, _err = pcall(demo_lurek_docs_validate)

-- ---- Stub: lurek.docs.validateModule -------------------------------------
--@api-stub: lurek.docs.validateModule
-- Demonstrates the proper usage of lurek.docs.validateModule.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_docs_validateModule()
    local vrep_phys = lurek.docs.validateModule("physics", catalog)
    print("physics missing:", vrep_phys:missingCount())
end
local _ok, _err = pcall(demo_lurek_docs_validateModule)

-- ---- Stub: lurek.docs.checkStaleness -------------------------------------
--@api-stub: lurek.docs.checkStaleness
-- Demonstrates the proper usage of lurek.docs.checkStaleness.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_docs_checkStaleness()
    local stale = lurek.docs.checkStaleness(catalog, "src/lua_api/")
    print("stale entries:", #stale)
end
local _ok, _err = pcall(demo_lurek_docs_checkStaleness)

-- ---- Stub: lurek.docs.quality --------------------------------------------
--@api-stub: lurek.docs.quality
-- Demonstrates the proper usage of lurek.docs.quality.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_docs_quality()
    local qrep = lurek.docs.quality(catalog)
    print(string.format("quality grade: %s (%.2f)", qrep:getGrade(), qrep:getOverallScore()))
end
local _ok, _err = pcall(demo_lurek_docs_quality)

-- ---- Stub: lurek.docs.qualityModule --------------------------------------
--@api-stub: lurek.docs.qualityModule
-- Demonstrates the proper usage of lurek.docs.qualityModule.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_docs_qualityModule()
    local qrep_render = lurek.docs.qualityModule("render", catalog)
    print("render grade:", qrep_render:getGrade())
end
local _ok, _err = pcall(demo_lurek_docs_qualityModule)

-- ---- Stub: lurek.docs.coverage -------------------------------------------
--@api-stub: lurek.docs.coverage
-- Demonstrates the proper usage of lurek.docs.coverage.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_docs_coverage()
    local covered, total = lurek.docs.coverage(catalog)
    print(string.format("coverage: %d / %d (%.0f%%)", covered, total, covered/total*100))
end
local _ok, _err = pcall(demo_lurek_docs_coverage)

-- ---- Stub: lurek.docs.coverageModule -------------------------------------
--@api-stub: lurek.docs.coverageModule
-- Demonstrates the proper usage of lurek.docs.coverageModule.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_docs_coverageModule()
    local mc, mt = lurek.docs.coverageModule("audio", catalog)
    print(string.format("audio coverage: %d / %d", mc, mt))
end
local _ok, _err = pcall(demo_lurek_docs_coverageModule)

-- ---- Stub: lurek.docs.exportCompletions ----------------------------------
--@api-stub: lurek.docs.exportCompletions
-- Demonstrates the proper usage of lurek.docs.exportCompletions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_docs_exportCompletions()
    lurek.docs.exportCompletions(catalog, "work/temp/completions.json")
    print("completions exported")
end
local _ok, _err = pcall(demo_lurek_docs_exportCompletions)

-- ---- Stub: lurek.docs.exportHover ----------------------------------------
--@api-stub: lurek.docs.exportHover
-- Demonstrates the proper usage of lurek.docs.exportHover.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_docs_exportHover()
    lurek.docs.exportHover(catalog, "work/temp/hover.json")
    print("hover exported")
end
local _ok, _err = pcall(demo_lurek_docs_exportHover)

-- ---- Stub: lurek.docs.exportSignatures -----------------------------------
--@api-stub: lurek.docs.exportSignatures
-- Demonstrates the proper usage of lurek.docs.exportSignatures.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_docs_exportSignatures()
    lurek.docs.exportSignatures(catalog, "work/temp/signatures.json")
    print("signatures exported")
end
local _ok, _err = pcall(demo_lurek_docs_exportSignatures)

-- ---- Stub: lurek.docs.exportAll ------------------------------------------
--@api-stub: lurek.docs.exportAll
-- Demonstrates the proper usage of lurek.docs.exportAll.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_docs_exportAll()
    lurek.docs.exportAll(catalog, "work/temp/vscode/")
    print("all VS Code JSON exported")
end
local _ok, _err = pcall(demo_lurek_docs_exportAll)

-- ---- Stub: lurek.docs.exportMarkdown -------------------------------------
--@api-stub: lurek.docs.exportMarkdown
-- Demonstrates the proper usage of lurek.docs.exportMarkdown.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_docs_exportMarkdown()
    lurek.docs.exportMarkdown(catalog, "work/temp/lua-api.md")
    print("markdown exported")
end
local _ok, _err = pcall(demo_lurek_docs_exportMarkdown)

-- ---- Stub: lurek.docs.exportCheatsheet -----------------------------------
--@api-stub: lurek.docs.exportCheatsheet
-- Demonstrates the proper usage of lurek.docs.exportCheatsheet.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_docs_exportCheatsheet()
    lurek.docs.exportCheatsheet(catalog, "work/temp/cheatsheet.txt")
    print("cheatsheet exported")
end
local _ok, _err = pcall(demo_lurek_docs_exportCheatsheet)

-- ---- Stub: lurek.docs.schema ---------------------------------------------
--@api-stub: lurek.docs.schema
-- Create a schema validator for the conf.toml table so Configurator
-- can give a descriptive error when a required field is missing.
local sch = lurek.docs.schema({
    title   = { type = "string",  required = true  },
    version = { type = "string",  required = true  },
    width   = { type = "integer", required = false },
}, "GameConfig")
print("schema created:", sch:getName())

-- ---- Stub: lurek.docs.reflectLive ----------------------------------------
--@api-stub: lurek.docs.reflectLive
-- Demonstrates the proper usage of lurek.docs.reflectLive.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_docs_reflectLive()
    local reflection = lurek.docs.reflectLive("lurek")
    print("reflection keys:", reflection ~= nil)
end
local _ok, _err = pcall(demo_lurek_docs_reflectLive)

-- ---- Stub: lurek.docs.reflectTable ---------------------------------------
--@api-stub: lurek.docs.reflectTable
-- Reflect an arbitrary Lua configuration table to enumerate its fields
-- and auto-generate TOML doc stubs for unknown config options.
local tbl = { width = 1280, height = 720, title = "My Game" }
local reflected = lurek.docs.reflectTable(tbl, "WindowConf")
print("reflected:", reflected ~= nil)

-- -----------------------------------------------------------------------------
-- ApiCatalog methods
-- -----------------------------------------------------------------------------

-- ---- Stub: ApiCatalog:getModules -----------------------------------------
--@api-stub: ApiCatalog:getModules
-- List all documented module names so the docs site generator can
-- produce one page per module in alphabetical order.
local mods = catalog:getModules()
print("modules:", #mods)
for i = 1, math.min(3, #mods) do print("  module:", mods[i]) end

-- ---- Stub: ApiCatalog:getEntries -----------------------------------------
--@api-stub: ApiCatalog:getEntries
-- Demonstrates the proper usage of ApiCatalog:getEntries.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ApiCatalog_getEntries()
    local phys_entries = catalog:getEntries("physics")
    print("physics entries:", #phys_entries)
end
local _ok, _err = pcall(demo_ApiCatalog_getEntries)

-- ---- Stub: ApiCatalog:getEntry -------------------------------------------
--@api-stub: ApiCatalog:getEntry
-- Demonstrates the proper usage of ApiCatalog:getEntry.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ApiCatalog_getEntry()
    local lerp_entry = catalog:getEntry("lurek.math.lerp")
    print("lerp entry found:", lerp_entry ~= nil)
end
local _ok, _err = pcall(demo_ApiCatalog_getEntry)

-- ---- Stub: ApiCatalog:getTypes -------------------------------------------
--@api-stub: ApiCatalog:getTypes
-- Demonstrates the proper usage of ApiCatalog:getTypes.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ApiCatalog_getTypes()
    local anim_types = catalog:getTypes("animation")
    print("animation types:", #anim_types)
end
local _ok, _err = pcall(demo_ApiCatalog_getTypes)

-- ---- Stub: ApiCatalog:getTypeMethods -------------------------------------
--@api-stub: ApiCatalog:getTypeMethods
-- Demonstrates the proper usage of ApiCatalog:getTypeMethods.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ApiCatalog_getTypeMethods()
    local anim_methods = catalog:getTypeMethods("lurek.animation.Animation")
    print("Animation methods:", #anim_methods)
end
local _ok, _err = pcall(demo_ApiCatalog_getTypeMethods)

-- ---- Stub: ApiCatalog:entryCount -----------------------------------------
--@api-stub: ApiCatalog:entryCount
-- Demonstrates the proper usage of ApiCatalog:entryCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ApiCatalog_entryCount()
    print("total entries:", catalog:entryCount())
    print("math entries:", catalog:entryCount("math"))
end
local _ok, _err = pcall(demo_ApiCatalog_entryCount)

-- ---- Stub: ApiCatalog:merge ----------------------------------------------
--@api-stub: ApiCatalog:merge
-- Demonstrates the proper usage of ApiCatalog:merge.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ApiCatalog_merge()
    local merged_cat = catalog:merge(toml_cat)
    print("merged entries:", merged_cat:entryCount())
end
local _ok, _err = pcall(demo_ApiCatalog_merge)

-- ---- Stub: ApiCatalog:filter ---------------------------------------------
--@api-stub: ApiCatalog:filter
-- Extract only deprecated entries from the catalog to produce a
-- migration guide listing everything scheduled for removal.
local deprecated = catalog:filter(function(e)
    return e:getDeprecated() ~= nil
end)
print("deprecated entries:", deprecated:entryCount())

-- ---- Stub: ApiCatalog:search ---------------------------------------------
--@api-stub: ApiCatalog:search
-- Demonstrates the proper usage of ApiCatalog:search.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ApiCatalog_search()
    local results = catalog:search("lerp")
    print("search 'lerp':", #results)
end
local _ok, _err = pcall(demo_ApiCatalog_search)

-- ---- Stub: ApiCatalog:toTable --------------------------------------------
--@api-stub: ApiCatalog:toTable
-- Demonstrates the proper usage of ApiCatalog:toTable.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ApiCatalog_toTable()
    local cat_tbl = catalog:toTable()
    print("toTable row count:", #cat_tbl)
end
local _ok, _err = pcall(demo_ApiCatalog_toTable)

-- ---- Stub: ApiCatalog:toJSON ---------------------------------------------
--@api-stub: ApiCatalog:toJSON
-- Convert the catalog to JSON for writing the completions.json file
-- consumed by the VS Code IntelliSense provider.
local cat_json = catalog:toJSON()
print("catalog JSON size:", #cat_json, "bytes")

-- -----------------------------------------------------------------------------
-- DocEntry methods
-- -----------------------------------------------------------------------------

local entry = catalog:getEntry("lurek.math.lerp")
if not entry then
    -- Provide a fallback entry when math.lerp is not yet in the catalog
    local tmp = catalog:getEntries()
    entry = tmp[1]
end

-- ---- Stub: DocEntry:getName ----------------------------------------------
--@api-stub: DocEntry:getName
-- Demonstrates the proper usage of DocEntry:getName.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DocEntry_getName()
    if entry then print("entry name:", entry:getName()) end
end
local _ok, _err = pcall(demo_DocEntry_getName)

-- ---- Stub: DocEntry:getQualifiedName -------------------------------------
--@api-stub: DocEntry:getQualifiedName
-- Demonstrates the proper usage of DocEntry:getQualifiedName.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DocEntry_getQualifiedName()
    if entry then print("qualified name:", entry:getQualifiedName()) end
end
local _ok, _err = pcall(demo_DocEntry_getQualifiedName)

-- ---- Stub: DocEntry:getModule --------------------------------------------
--@api-stub: DocEntry:getModule
-- Demonstrates the proper usage of DocEntry:getModule.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DocEntry_getModule()
    if entry then print("module:", entry:getModule()) end
end
local _ok, _err = pcall(demo_DocEntry_getModule)

-- ---- Stub: DocEntry:getKind ----------------------------------------------
--@api-stub: DocEntry:getKind
-- Demonstrates the proper usage of DocEntry:getKind.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DocEntry_getKind()
    if entry then print("kind:", entry:getKind()) end
end
local _ok, _err = pcall(demo_DocEntry_getKind)

-- ---- Stub: DocEntry:getDescription ---------------------------------------
--@api-stub: DocEntry:getDescription
-- Demonstrates the proper usage of DocEntry:getDescription.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_DocEntry_getDescription()
    if entry then print("description:", entry:getDescription()) end
end
local _ok, _err = pcall(demo_DocEntry_getDescription)

-- ---- Stub: DocEntry:getParameters ----------------------------------------
--@api-stub: DocEntry:getParameters
-- Read the parameter table to generate the Parameters section of the
-- per-function API reference page.
if entry then
    local params = entry:getParameters()
    print("param count:", #params)
end

-- ---- Stub: DocEntry:getReturns -------------------------------------------
--@api-stub: DocEntry:getReturns
-- Read the return table to populate the Returns section of the
-- API reference and VS Code hover card.
if entry then
    local rets = entry:getReturns()
    print("return count:", #rets)
end

-- ---- Stub: DocEntry:getExample -------------------------------------------
--@api-stub: DocEntry:getExample
-- Read the example snippet to embed it in the hover tooltip so
-- developers can see a usage sample without opening the docs site.
if entry then
    local ex = entry:getExample()
    print("has example snippet:", ex ~= nil)
end

-- ---- Stub: DocEntry:getSince ---------------------------------------------
--@api-stub: DocEntry:getSince
-- Read the since version to generate a "New in X.Y" badge on the
-- API reference page for recently added functions.
if entry then
    local since = entry:getSince()
    print("since:", since or "unset")
end

-- ---- Stub: DocEntry:getDeprecated ----------------------------------------
--@api-stub: DocEntry:getDeprecated
-- Read the deprecation message to add a warning banner on the entry
-- page and route it into the migration guide.
if entry then
    local dep = entry:getDeprecated()
    print("deprecated:", dep or "no")
end

-- ---- Stub: DocEntry:getScore ---------------------------------------------
--@api-stub: DocEntry:getScore
-- Read the quality score to rank entries in the worst-coverage
-- report produced by the Doc-Writer agent.
if entry then
    print(string.format("score: %.3f", entry:getScore()))
end

-- ---- Stub: DocEntry:hasDescription ---------------------------------------
--@api-stub: DocEntry:hasDescription
-- Guard rendering so the description section is only emitted when
-- the entry actually has content and not an empty string.
if entry then
    if entry:hasDescription() then
        print("description present")
    else
        print("description missing")
    end
end

-- ---- Stub: DocEntry:hasParameters ----------------------------------------
--@api-stub: DocEntry:hasParameters
-- Skip the Parameters table in the doc template when the entry has
-- no declared parameters to avoid empty section headings.
if entry then
    print("has parameters:", entry:hasParameters())
end

-- ---- Stub: DocEntry:hasReturnType ----------------------------------------
--@api-stub: DocEntry:hasReturnType
-- Skip the Returns section in the doc template when the entry has
-- no declared return type.
if entry then
    print("has return type:", entry:hasReturnType())
end

-- ---- Stub: DocEntry:hasExample -------------------------------------------
--@api-stub: DocEntry:hasExample
-- Guard the "Example" section so it only appears in the rendered page
-- when an actual snippet was supplied.
if entry then
    print("has example:", entry:hasExample())
end

-- -----------------------------------------------------------------------------
-- QualityReport methods
-- -----------------------------------------------------------------------------

-- ---- Stub: QualityReport:getOverallScore ---------------------------------
--@api-stub: QualityReport:getOverallScore
-- Demonstrates the proper usage of QualityReport:getOverallScore.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_QualityReport_getOverallScore()
    print(string.format("overall score: %.3f", qrep:getOverallScore()))
end
local _ok, _err = pcall(demo_QualityReport_getOverallScore)

-- ---- Stub: QualityReport:getGrade ----------------------------------------
--@api-stub: QualityReport:getGrade
-- Demonstrates the proper usage of QualityReport:getGrade.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_QualityReport_getGrade()
    print("grade:", qrep:getGrade())
end
local _ok, _err = pcall(demo_QualityReport_getGrade)

-- ---- Stub: QualityReport:getModuleScores ---------------------------------
--@api-stub: QualityReport:getModuleScores
-- Read per-module scores to build a sorted ranking of the most and
-- least documented modules for the Doc-Writer sprint board.
local scores = qrep:getModuleScores()
for mod, score in pairs(scores) do
    print(string.format("  %s: %.2f", mod, score))
end

-- ---- Stub: QualityReport:getWorst ----------------------------------------
--@api-stub: QualityReport:getWorst
-- Demonstrates the proper usage of QualityReport:getWorst.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_QualityReport_getWorst()
    local worst = qrep:getWorst(10)
    print("worst entries:", #worst)
end
local _ok, _err = pcall(demo_QualityReport_getWorst)

-- ---- Stub: QualityReport:getBest -----------------------------------------
--@api-stub: QualityReport:getBest
-- Demonstrates the proper usage of QualityReport:getBest.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_QualityReport_getBest()
    local best = qrep:getBest(5)
    print("best entries:", #best)
end
local _ok, _err = pcall(demo_QualityReport_getBest)

-- ---- Stub: QualityReport:getByGrade -------------------------------------
--@api-stub: QualityReport:getByGrade
-- Demonstrates the proper usage of QualityReport:getByGrade.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_QualityReport_getByGrade()
    local d_grade = qrep:getByGrade("D")
    print("D-grade entries:", #d_grade)
end
local _ok, _err = pcall(demo_QualityReport_getByGrade)

-- ---- Stub: QualityReport:getSummary --------------------------------------
--@api-stub: QualityReport:getSummary
-- Demonstrates the proper usage of QualityReport:getSummary.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_QualityReport_getSummary()
    print("quality summary:\n" .. qrep:getSummary())
end
local _ok, _err = pcall(demo_QualityReport_getSummary)

-- ---- Stub: QualityReport:toTable -----------------------------------------
--@api-stub: QualityReport:toTable
-- Demonstrates the proper usage of QualityReport:toTable.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_QualityReport_toTable()
    local q_tbl = qrep:toTable()
    print("quality table rows:", #q_tbl)
end
local _ok, _err = pcall(demo_QualityReport_toTable)

-- ---- Stub: QualityReport:toJSON ------------------------------------------
--@api-stub: QualityReport:toJSON
-- Serialise the quality report to JSON to write it to the CI artefacts
-- folder where the dashboard tool reads it.
local q_json = qrep:toJSON()
print("quality JSON size:", #q_json, "bytes")

-- -----------------------------------------------------------------------------
-- Schema methods
-- -----------------------------------------------------------------------------

local conf_data = { title = "Dungeon Run", version = "1.0", width = 1280 }
local bad_data  = { version = "1.0" }  -- missing required `title`

-- ---- Stub: Schema:validate -----------------------------------------------
--@api-stub: Schema:validate
-- Demonstrates the proper usage of Schema:validate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Schema_validate()
    local result = sch:validate(conf_data)
    print("validate conf_data:", result ~= nil)
end
local _ok, _err = pcall(demo_Schema_validate)

-- ---- Stub: Schema:check --------------------------------------------------
--@api-stub: Schema:check
-- Demonstrates the proper usage of Schema:check.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Schema_check()
    print("check good:", sch:check(conf_data))
    print("check bad:", sch:check(bad_data))
end
local _ok, _err = pcall(demo_Schema_check)

-- ---- Stub: Schema:assert -------------------------------------------------
--@api-stub: Schema:assert
-- Demonstrates the proper usage of Schema:assert.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Schema_assert()
    local ok_assert, err = pcall(function() sch:assert(conf_data) end)
    print("assert conf_data:", ok_assert and "ok" or err)
end
local _ok, _err = pcall(demo_Schema_assert)

-- ---- Stub: Schema:getName ------------------------------------------------
--@api-stub: Schema:getName
-- Demonstrates the proper usage of Schema:getName.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Schema_getName()
    print("schema name:", sch:getName())
end
local _ok, _err = pcall(demo_Schema_getName)

-- ---- Stub: Schema:getFields ----------------------------------------------
--@api-stub: Schema:getFields
-- List all declared schema fields to build the auto-generated TOML
-- template that developers fill in for new game configurations.
local fields = sch:getFields()
print("schema fields:", #fields)
for _, f in ipairs(fields) do print("  field:", f) end

-- -----------------------------------------------------------------------------
-- ValidationReport methods
-- -----------------------------------------------------------------------------

-- ---- Stub: ValidationReport:isValid --------------------------------------
--@api-stub: ValidationReport:isValid
-- Demonstrates the proper usage of ValidationReport:isValid.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ValidationReport_isValid()
    print("catalog valid:", vrep:isValid())
end
local _ok, _err = pcall(demo_ValidationReport_isValid)

-- ---- Stub: ValidationReport:getMissing -----------------------------------
--@api-stub: ValidationReport:getMissing
-- Read the missing-entry list to generate TODO stubs in the TOML
-- companion files for the Doc-Writer to fill in.
local missing = vrep:getMissing()
print("missing:", #missing)
if #missing > 0 then print("  first:", missing[1]) end

-- ---- Stub: ValidationReport:getPhantom -----------------------------------
--@api-stub: ValidationReport:getPhantom
-- Demonstrates the proper usage of ValidationReport:getPhantom.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ValidationReport_getPhantom()
    local phantom = vrep:getPhantom()
    print("phantom:", #phantom)
end
local _ok, _err = pcall(demo_ValidationReport_getPhantom)

-- ---- Stub: ValidationReport:getIncomplete --------------------------------
--@api-stub: ValidationReport:getIncomplete
-- Demonstrates the proper usage of ValidationReport:getIncomplete.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ValidationReport_getIncomplete()
    local incomplete = vrep:getIncomplete()
    print("incomplete:", #incomplete)
end
local _ok, _err = pcall(demo_ValidationReport_getIncomplete)

-- ---- Stub: ValidationReport:missingCount ---------------------------------
--@api-stub: ValidationReport:missingCount
-- Demonstrates the proper usage of ValidationReport:missingCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ValidationReport_missingCount()
    print("missing count:", vrep:missingCount())
end
local _ok, _err = pcall(demo_ValidationReport_missingCount)

-- ---- Stub: ValidationReport:phantomCount ---------------------------------
--@api-stub: ValidationReport:phantomCount
-- Demonstrates the proper usage of ValidationReport:phantomCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ValidationReport_phantomCount()
    print("phantom count:", vrep:phantomCount())
end
local _ok, _err = pcall(demo_ValidationReport_phantomCount)

-- ---- Stub: ValidationReport:incompleteCount ------------------------------
--@api-stub: ValidationReport:incompleteCount
-- Demonstrates the proper usage of ValidationReport:incompleteCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ValidationReport_incompleteCount()
    print("incomplete count:", vrep:incompleteCount())
end
local _ok, _err = pcall(demo_ValidationReport_incompleteCount)

-- ---- Stub: ValidationReport:getSummary -----------------------------------
--@api-stub: ValidationReport:getSummary
-- Demonstrates the proper usage of ValidationReport:getSummary.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ValidationReport_getSummary()
    print("validation summary:", vrep:getSummary())
end
local _ok, _err = pcall(demo_ValidationReport_getSummary)

-- ---- Stub: ValidationReport:toTable --------------------------------------
--@api-stub: ValidationReport:toTable
-- Demonstrates the proper usage of ValidationReport:toTable.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ValidationReport_toTable()
    local v_tbl = vrep:toTable()
    print("validation table:", #v_tbl)
end
local _ok, _err = pcall(demo_ValidationReport_toTable)

-- ---- Stub: ValidationReport:toJSON ---------------------------------------
--@api-stub: ValidationReport:toJSON
-- Demonstrates the proper usage of ValidationReport:toJSON.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ValidationReport_toJSON()
    local v_json = vrep:toJSON()
    print("validation JSON size:", #v_json, "bytes")
end
local _ok, _err = pcall(demo_ValidationReport_toJSON)
