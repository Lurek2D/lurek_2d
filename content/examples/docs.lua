-- content/examples/docs.lua
-- Auto-generated from content/examples2/docs_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/docs.lua

--- Docs Module Part 1: Scanning, Catalog, Schema, DocEntry, Validation, Quality, Export

local docs_example_cat = lurek.docs.scanModule("math")
local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
local docs_example_validate = lurek.docs.validate(docs_example_cat)
local docs_example_quality = lurek.docs.quality(docs_example_cat)

--@api: lurek.docs.scan
do
    local cat = lurek.docs.scan()
    print("scanned entries = " .. cat:entryCount())
    print("lua type = " .. type(cat))
end

--@api: lurek.docs.scanModule
do
    local cat = lurek.docs.scanModule("math")
    print("math entries = " .. cat:entryCount())
    print("lua type = " .. type(cat))
end

--@api: lurek.docs.loadToml
do
    local path = "save/_fs_tests/docs_load_toml_example.toml"
    lurek.filesystem.write(path, '[[entries]]\nname = "play"\nqualifiedName = "lurek.audio.play"\nmodule = "audio"\nkind = "function"\ndescription = "Plays a sound"')
    local cat = lurek.docs.loadToml(path)
    print("loaded entries = " .. cat:entryCount())
end

--@api: lurek.docs.loadAll
do
    lurek.filesystem.write("save/_fs_tests/docs_load_all_a.toml", '[[entries]]\nname = "one"\nqualifiedName = "lurek.test.one"\nmodule = "test"\nkind = "function"\ndescription = "First entry"')
    lurek.filesystem.write("save/_fs_tests/docs_load_all_b.toml", '[[entries]]\nname = "two"\nqualifiedName = "lurek.test.two"\nmodule = "test"\nkind = "function"\ndescription = "Second entry"')
    local cat = lurek.docs.loadAll("save/_fs_tests/")
    print("all entries = " .. cat:entryCount())
end

--@api: lurek.docs.describe
do
    lurek.docs.describe("lurek.math.lerp", "Linearly interpolates between a and b.")
    print("description set")
    print("catalog type = " .. type(lurek.docs.getCatalog()))
end

--@api: lurek.docs.setParamInfo
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.test.blend", "Blend two values.")
    lurek.docs.setParamInfo("lurek.test.blend", {
        { name = "t", type = "number", description = "Interpolation factor", optional = false },
    })
    local entry = lurek.docs.getCatalog():getEntry("lurek.test.blend")
    print("params set = " .. #entry:getParameters())
end

--@api: lurek.docs.setReturnInfo
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.test.blend", "Blend two values.")
    lurek.docs.setReturnInfo("lurek.test.blend", {
        {type = "number", description = "Interpolated value"},
    })
    local entry = lurek.docs.getCatalog():getEntry("lurek.test.blend")
    print("returns set = " .. #entry:getReturns())
end

--@api: lurek.docs.getCatalog
do
    local cat = lurek.docs.getCatalog()
    print("catalog entries = " .. cat:entryCount())
    print("lua type = " .. type(cat))
end

--@api: lurek.docs.resetCatalog
do
    lurek.docs.describe("lurek.test.temp", "Temporary entry")
    lurek.docs.resetCatalog()
    local cat = lurek.docs.getCatalog()
    print("after reset entries = " .. cat:entryCount())
end

--@api: lurek.docs.validate
do
    local cat = docs_example_cat
    local report = docs_example_validate
    print("valid = " .. tostring(report:isValid()))
end

--@api: lurek.docs.validateModule
do
    local cat = docs_example_cat
    local report = lurek.docs.validateModule("math", cat)
    print("math missing = " .. report:missingCount())
end

--@api: lurek.docs.checkStaleness
do
    local cat = docs_example_cat
    local result = lurek.docs.checkStaleness(cat, "src/math/")
    print("stale = " .. #result.stale .. " current = " .. #result.current)
end

--@api: lurek.docs.quality
do
    local cat = docs_example_cat
    local qr = docs_example_quality
    print("quality score = " .. qr:getOverallScore())
end

--@api: lurek.docs.qualityModule
do
    local cat = docs_example_cat
    local qr = lurek.docs.qualityModule("math", cat)
    print("math quality = " .. qr:getOverallScore())
end

--@api: lurek.docs.coverage
do
    local cat = docs_example_cat
    local documented, live = lurek.docs.coverage(cat)
    print("documented=" .. documented .. " live=" .. live)
end

--@api: lurek.docs.coverageModule
do
    local cat = docs_example_cat
    local documented, live = lurek.docs.coverageModule("math", cat)
    print("math documented=" .. documented .. " live=" .. live)
end

--@api: lurek.docs.exportCompletions
do
    local cat = docs_example_cat
    lurek.docs.exportCompletions(cat, "build/completions.json")
    print("completions exported")
end

--@api: lurek.docs.exportHover
do
    local cat = docs_example_cat
    lurek.docs.exportHover(cat, "build/hover.json")
    print("hover exported")
end

--@api: lurek.docs.exportSignatures
do
    local cat = docs_example_cat
    lurek.docs.exportSignatures(cat, "build/signatures.json")
    print("signatures exported")
end

--@api: lurek.docs.exportAll
do
    local cat = docs_example_cat
    lurek.docs.exportAll(cat, "build/docs/")
    print("all docs exported")
end

--@api: lurek.docs.exportMarkdown
do
    local cat = docs_example_cat
    lurek.docs.exportMarkdown(cat, "build/api.md")
    print("markdown exported")
end

--@api: lurek.docs.exportCheatsheet
do
    local cat = docs_example_cat
    lurek.docs.exportCheatsheet(cat, "build/cheatsheet.txt")
    print("cheatsheet exported")
end

--@api: lurek.docs.schema
do
    local s = lurek.docs.schema({ name = { type = "string", required = true }, age = { type = "number" } }, "PlayerSchema")
    print("schema name = " .. s:getName())
    print("lua type = " .. type(s))
end

--@api: lurek.docs.schemaFromToml
do
    local toml = [[
name = "PlayerSchema"
strict = true

[rules.name]
type = "string"
required = true
]]
    local s = lurek.docs.schemaFromToml(toml)
    print("schema from toml, name = " .. s:getName())
end

--@api: lurek.docs.reflectLive
do
    local data = lurek.docs.reflectLive("math")
    print("reflect math type = " .. type(data))
    print("lua type = " .. type(data))
end

--@api: lurek.docs.reflectTable
do
    local t = {foo = 1, bar = "hello"}
    local rows = lurek.docs.reflectTable(t, "mymod")
    print("reflected rows = " .. #rows)
end

--@api: LSchema:validate
do
    local s = lurek.docs.schema({name = {type = "string", required = true}})
    local ok, errors = s:validate({name = "test"})
    print("valid = " .. tostring(ok) .. " errors = " .. #errors)
end

--@api: LSchema:check
do
    local s = lurek.docs.schema({x = {type = "number"}})
    print("check = " .. tostring(s:check({x = 42})))
    print("owner type = " .. tostring(s:type()))
end

--@api: LSchema:assert
do
    local s = lurek.docs.schema({v = {type = "number"}})
    local ok = pcall(function() s["assert"](s, {v = 10}) end)
    print("assert passed = " .. tostring(ok))
end

--@api: LSchema:getName
do
    local s = lurek.docs.schema({}, "TestSchema")
    print("name = " .. s:getName())
    print("owner type = " .. tostring(s:type()))
end

--@api: LSchema:getFields
do
    local s = lurek.docs.schema({a = {type = "number"}, b = {type = "string"}})
    local fields = s:getFields()
    print("fields = " .. #fields)
end

--@api: LSchema:type
do
    local s = lurek.docs.schema({})
    print("type = " .. s:type())
    print("typeOf LObject = " .. tostring(s:typeOf("LObject")))
end

--@api: LSchema:typeOf
do
    local s = lurek.docs.schema({})
    print("is LSchema = " .. tostring(s:typeOf("LSchema")))
    print("type = " .. tostring(s:type()))
end

--@api: LDocEntry:getName
do
    local entry = docs_example_entry
    print("name = " .. entry:getName())
    print("owner type = " .. tostring(entry:type()))
end

--@api: LDocEntry:getQualifiedName
do
    local entry = docs_example_entry
    print("qualified = " .. entry:getQualifiedName())
    print("owner type = " .. tostring(entry:type()))
end

--@api: LDocEntry:getModule
do
    local entry = docs_example_entry
    print("module = " .. entry:getModule())
    print("owner type = " .. tostring(entry:type()))
end

--@api: LDocEntry:getKind
do
    local entry = docs_example_entry
    print("kind = " .. entry:getKind())
    print("owner type = " .. tostring(entry:type()))
end

--@api: LDocEntry:getDescription
do
    local entry = docs_example_entry
    print("desc len = " .. #entry:getDescription())
    print("owner type = " .. tostring(entry:type()))
end

--@api: LDocEntry:getParameters
do
    local params = docs_example_entry:getParameters()
    print("params = " .. #params)
    print("params lua type = " .. type(params))
end

--@api: LDocEntry:getReturns
do
    local returns = docs_example_entry:getReturns()
    print("returns = " .. #returns)
    print("returns lua type = " .. type(returns))
end

--@api: LDocEntry:getExample
do
    local example = docs_example_entry:getExample()
    print("example = " .. type(example))
    print("example length = " .. tostring(example and #example or 0))
end

--@api: LDocEntry:getSince
do
    local since = docs_example_entry:getSince()
    print("since = " .. type(since))
    print("since value = " .. tostring(since))
end

--@api: LDocEntry:getDeprecated
do
    local deprecated = docs_example_entry:getDeprecated()
    print("deprecated = " .. type(deprecated))
    print("deprecated value = " .. tostring(deprecated))
end

--@api: LDocEntry:getScore
do
    local entry = docs_example_entry
    print("score = " .. entry:getScore())
    print("owner type = " .. tostring(entry:type()))
end

--@api: LDocEntry:hasDescription
do
    local entry = docs_example_entry
    print("hasDesc = " .. tostring(entry:hasDescription()))
    print("owner type = " .. tostring(entry:type()))
end

--@api: LDocEntry:hasParameters
do
    local entry = docs_example_entry
    print("hasParams = " .. tostring(entry:hasParameters()))
    print("owner type = " .. tostring(entry:type()))
end

--@api: LDocEntry:hasReturnType
do
    local entry = docs_example_entry
    print("hasReturn = " .. tostring(entry:hasReturnType()))
    print("owner type = " .. tostring(entry:type()))
end

--@api: LDocEntry:hasExample
do
    local entry = docs_example_entry
    print("hasExample = " .. tostring(entry:hasExample()))
    print("owner type = " .. tostring(entry:type()))
end

--@api: LDocEntry:type
do
    local entry = docs_example_entry
    print("type = " .. entry:type())
    print("typeOf LObject = " .. tostring(entry:typeOf("LObject")))
end

--@api: LDocEntry:typeOf
do
    local entry = docs_example_entry
    print("is LDocEntry = " .. tostring(entry:typeOf("LDocEntry")))
    print("type = " .. tostring(entry:type()))
end

--- Docs Module Part 2: LApiCatalog, LValidationReport, LQualityReport

--@api: LApiCatalog:getModules
do
    local cat = docs_example_cat
    local modules = cat:getModules()
    print("modules = " .. #modules)
end

--@api: LApiCatalog:getEntries
do
    local cat = docs_example_cat
    local all = cat:getEntries()
    local math_entries = cat:getEntries("math")
    print("all=" .. #all .. " math=" .. #math_entries)
end

--@api: LApiCatalog:getEntry
do
    local cat = docs_example_cat
    print("found entry = " .. tostring(cat:getEntry("lurek.math.lerp") ~= nil))
    print("owner type = " .. tostring(cat:type()))
end

--@api: LApiCatalog:getTypes
do
    local cat = docs_example_cat
    local types = cat:getTypes("math")
    print("math types = " .. #types)
end

--@api: LApiCatalog:getTypeMethods
do
    local cat = docs_example_cat
    local methods = cat:getTypeMethods("LVec2")
    print("LVec2 methods = " .. #methods)
end

--@api: LApiCatalog:entryCount
do
    local cat = docs_example_cat
    local total = cat:entryCount()
    local math_count = cat:entryCount("math")
    print("total=" .. total .. " math=" .. math_count)
end

--@api: LApiCatalog:merge
do
    local a = lurek.docs.scanModule("math")
    local b = lurek.docs.scanModule("timer")
    local merged = a:merge(b)
    print("merged = " .. merged:entryCount())
end

--@api: LApiCatalog:filter
do
    local cat = docs_example_cat
    local fns = cat:filter(function(entry) return entry:getKind() == "function" end)
    print("functions = " .. fns:entryCount())
end

--@api: LApiCatalog:search
do
    local cat = docs_example_cat
    local results = cat:search("lerp")
    print("search results = " .. #results)
end

--@api: LApiCatalog:toTable
do
    local cat = lurek.docs.scanModule("math")
    local rows = cat:toTable()
    print("rows = " .. #rows)
end

--@api: LApiCatalog:toJSON
do
    local cat = lurek.docs.scanModule("timer")
    local json = cat:toJSON()
    print("json length = " .. #json)
end

--@api: LApiCatalog:type
do
    local cat = docs_example_cat
    print("type = " .. cat:type())
    print("typeOf LObject = " .. tostring(cat:typeOf("LObject")))
end

--@api: LApiCatalog:typeOf
do
    local cat = docs_example_cat
    print("is LApiCatalog = " .. tostring(cat:typeOf("LApiCatalog")))
    print("type = " .. tostring(cat:type()))
end

--@api: LValidationReport:isValid
do
    local cat = docs_example_cat
    local report = docs_example_validate
    print("valid = " .. tostring(report:isValid()))
end

--@api: LValidationReport:getMissing
do
    local cat = docs_example_cat
    local report = docs_example_validate
    local missing = report:getMissing()
    print("missing = " .. #missing)
end

--@api: LValidationReport:getPhantom
do
    local cat = docs_example_cat
    local report = docs_example_validate
    local phantom = report:getPhantom()
    print("phantom = " .. #phantom)
end

--@api: LValidationReport:getIncomplete
do
    local cat = docs_example_cat
    local report = docs_example_validate
    local incomplete = report:getIncomplete()
    print("incomplete = " .. #incomplete)
end

--@api: LValidationReport:missingCount
do
    local cat = docs_example_cat
    local report = docs_example_validate
    print("missing count = " .. report:missingCount())
end

--@api: LValidationReport:phantomCount
do
    local cat = docs_example_cat
    local report = docs_example_validate
    print("phantom count = " .. report:phantomCount())
end

--@api: LValidationReport:incompleteCount
do
    local cat = docs_example_cat
    local report = docs_example_validate
    print("incomplete count = " .. report:incompleteCount())
end

--@api: LValidationReport:getSummary
do
    local cat = docs_example_cat
    local report = docs_example_validate
    print("summary = " .. report:getSummary())
end

--@api: LValidationReport:toTable
do
    local cat = docs_example_cat
    local report = docs_example_validate
    local t = report:toTable()
    print("table keys: missing=" .. #t.missing .. " phantom=" .. #t.phantom)
end

--@api: LValidationReport:toJSON
do
    local cat = docs_example_cat
    local report = docs_example_validate
    local json = report:toJSON()
    print("json length = " .. #json)
end

--@api: LValidationReport:type
do
    local cat = docs_example_cat
    local report = docs_example_validate
    print("type = " .. report:type())
end

--@api: LValidationReport:typeOf
do
    local cat = docs_example_cat
    local report = docs_example_validate
    print("is report = " .. tostring(report:typeOf("LValidationReport")))
end

--@api: LQualityReport:getOverallScore
do
    local cat = docs_example_cat
    local qr = docs_example_quality
    print("score = " .. qr:getOverallScore())
end

--@api: LQualityReport:getGrade
do
    local cat = docs_example_cat
    local qr = docs_example_quality
    print("grade = " .. qr:getGrade())
end

--@api: LQualityReport:getModuleScores
do
    local cat = docs_example_cat
    local qr = docs_example_quality
    local scores = qr:getModuleScores()
    print("module scores type = " .. type(scores))
end

--@api: LQualityReport:getWorst
do
    local cat = docs_example_cat
    local qr = docs_example_quality
    local worst = qr:getWorst(5)
    print("worst 5 = " .. #worst)
end

--@api: LQualityReport:getBest
do
    local cat = docs_example_cat
    local qr = docs_example_quality
    local best = qr:getBest(5)
    print("best 5 = " .. #best)
end

--@api: LQualityReport:getByGrade
do
    local cat = docs_example_cat
    local qr = docs_example_quality
    local a_entries = qr:getByGrade("A")
    print("grade A entries = " .. #a_entries)
end

--@api: LQualityReport:getSummary
do
    local cat = docs_example_cat
    local qr = docs_example_quality
    print("summary = " .. qr:getSummary())
end

--@api: LQualityReport:toTable
do
    local cat = docs_example_cat
    local qr = docs_example_quality
    local t = qr:toTable()
    print("overall = " .. t.overallScore .. " grade = " .. t.grade)
end

--@api: LQualityReport:toJSON
do
    local cat = docs_example_cat
    local qr = docs_example_quality
    local json = qr:toJSON()
    print("json length = " .. #json)
end

--@api: LQualityReport:type
do
    local cat = docs_example_cat
    local qr = docs_example_quality
    print("type = " .. qr:type())
end

--@api: LQualityReport:typeOf
do
    local cat = docs_example_cat
    local qr = docs_example_quality
    print("is report = " .. tostring(qr:typeOf("LQualityReport")))
end
