-- content/examples/docs.lua
-- Auto-generated from content/examples2/docs_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/docs.lua

--- Docs Module Part 1: Scanning, Catalog, Schema, DocEntry, Validation, Quality, Export

local docs_example_cat = lurek.docs.scanModule("math")
local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
local docs_example_validate = lurek.docs.validate(docs_example_cat)
local docs_example_quality = lurek.docs.quality(docs_example_cat)

local function docs_log(message)
    lurek.log.info("[docs.example] " .. tostring(message))
end

--@api: lurek.docs.scan
do
    local cat = lurek.docs.scan()
    local modules = cat:getModules()
    docs_log("scanned entries = " .. cat:entryCount())
    docs_log("catalog entries = " .. tostring(cat:entryCount()))
    docs_log("first module = " .. tostring(modules[1]))
end

--@api: lurek.docs.scanModule
do
    local cat = lurek.docs.scanModule("math")
    local entries = cat:getEntries("math")
    docs_log("math entries = " .. cat:entryCount())
    docs_log("math catalog type = " .. cat:type())
    docs_log("first math entry = " .. tostring(entries[1] and entries[1]:getQualifiedName()))
end

--@api: lurek.docs.loadToml
do
    local path = "save/_fs_tests/docs_load_toml_example.toml"
    lurek.filesystem.write(path, '[[entries]]\nname = "play"\nqualifiedName = "lurek.audio.play"\nmodule = "audio"\nkind = "function"\ndescription = "Plays a sound"')
    local cat = lurek.docs.loadToml(path)
    local entry = cat:getEntry("lurek.audio.play")
    docs_log("loaded entries = " .. cat:entryCount())
    docs_log("loaded type = " .. cat:type())
    docs_log("loaded qualified name = " .. tostring(entry and entry:getQualifiedName()))
end

--@api: lurek.docs.loadAll
do
    local dir = "save/_fs_tests/docs_load_all/"
    lurek.filesystem.write(dir .. "a.toml", '[[entries]]\nname = "one"\nqualifiedName = "lurek.test.one"\nmodule = "test"\nkind = "function"\ndescription = "First entry"')
    lurek.filesystem.write(dir .. "b.toml", '[[entries]]\nname = "two"\nqualifiedName = "lurek.test.two"\nmodule = "test"\nkind = "function"\ndescription = "Second entry"')
    local cat = lurek.docs.loadAll(dir)
    docs_log("all entries = " .. cat:entryCount())
    docs_log("loadAll type = " .. cat:type())
    docs_log("has lurek.test.one = " .. tostring(cat:getEntry("lurek.test.one") ~= nil))
end

--@api: lurek.docs.describe
do
    lurek.docs.describe("lurek.math.lerp", "Linearly interpolates between a and b.")
    local cat = lurek.docs.getCatalog()
    local entry = cat:getEntry("lurek.math.lerp")
    docs_log("description set")
    docs_log("catalog entries = " .. tostring(cat:entryCount()))
    docs_log("description length = " .. tostring(entry and #entry:getDescription() or 0))
end

--@api: lurek.docs.setParamInfo
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.test.blend", "Blend two values.")
    lurek.docs.setParamInfo("lurek.test.blend", {
        { name = "t", type = "number", description = "Interpolation factor", optional = false },
    })
    local entry = lurek.docs.getCatalog():getEntry("lurek.test.blend")
    local params = entry:getParameters()
    docs_log("params set = " .. #params)
    docs_log("first param name = " .. tostring(params[1] and params[1].name))
end

--@api: lurek.docs.setReturnInfo
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.test.blend", "Blend two values.")
    lurek.docs.setReturnInfo("lurek.test.blend", {
        {type = "number", description = "Interpolated value"},
    })
    local entry = lurek.docs.getCatalog():getEntry("lurek.test.blend")
    local returns = entry:getReturns()
    docs_log("returns set = " .. #returns)
    docs_log("first return type = " .. tostring(returns[1] and returns[1].type))
end

--@api: lurek.docs.getCatalog
do
    local cat = lurek.docs.getCatalog()
    local modules = cat:getModules()
    docs_log("catalog entries = " .. cat:entryCount())
    docs_log("catalog userdata type = " .. cat:type())
    docs_log("module count = " .. #modules)
end

--@api: lurek.docs.resetCatalog
do
    lurek.docs.describe("lurek.test.temp", "Temporary entry")
    lurek.docs.resetCatalog()
    local cat = lurek.docs.getCatalog()
    docs_log("after reset entries = " .. cat:entryCount())
    docs_log("after reset type = " .. cat:type())
end

--@api: lurek.docs.validate
do
    local cat = docs_example_cat
    local report = docs_example_validate
    docs_log("valid = " .. tostring(report:isValid()))
    docs_log("missing count = " .. tostring(report:missingCount()))
    docs_log("report type = " .. report:type())
end

--@api: lurek.docs.validateModule
do
    local cat = docs_example_cat
    local report = lurek.docs.validateModule("math", cat)
    docs_log("math missing = " .. report:missingCount())
    docs_log("math phantom = " .. report:phantomCount())
    docs_log("report type = " .. report:type())
end

--@api: lurek.docs.checkStaleness
do
    local cat = docs_example_cat
    local result = lurek.docs.checkStaleness(cat, "src/math/")
    docs_log("stale = " .. #result.stale .. " current = " .. #result.current)
    docs_log("missing = " .. #result.missing)
    docs_log("first current path = " .. tostring(result.current[1]))
end

--@api: lurek.docs.quality
do
    local cat = docs_example_cat
    local qr = docs_example_quality
    docs_log("quality score = " .. qr:getOverallScore())
    docs_log("quality grade = " .. tostring(qr:getGrade()))
    docs_log("report type = " .. qr:type())
end

--@api: lurek.docs.qualityModule
do
    local cat = docs_example_cat
    local qr = lurek.docs.qualityModule("math", cat)
    docs_log("math quality = " .. qr:getOverallScore())
    docs_log("math grade = " .. tostring(qr:getGrade()))
    docs_log("report type = " .. qr:type())
end

--@api: lurek.docs.coverage
do
    local cat = docs_example_cat
    local documented, live = lurek.docs.coverage(cat)
    docs_log("documented=" .. documented .. " live=" .. live)
    docs_log("coverage gap=" .. tostring(live - documented))
    docs_log("catalog entries=" .. cat:entryCount())
end

--@api: lurek.docs.coverageModule
do
    local cat = docs_example_cat
    local documented, live = lurek.docs.coverageModule("math", cat)
    docs_log("math documented=" .. documented .. " live=" .. live)
    docs_log("math coverage gap=" .. tostring(live - documented))
    docs_log("math entry count=" .. cat:entryCount("math"))
end

--@api: lurek.docs.exportCompletions
do
    local cat = docs_example_cat
    local path = "save/docs_completions.json"
    lurek.docs.exportCompletions(cat, path)
    docs_log("completions exported")
    docs_log("completions target = " .. path)
    docs_log("catalog entries exported = " .. cat:entryCount())
end

--@api: lurek.docs.exportHover
do
    local cat = docs_example_cat
    local path = "save/docs_hover.json"
    lurek.docs.exportHover(cat, path)
    docs_log("hover exported")
    docs_log("hover target = " .. path)
    docs_log("catalog entries exported = " .. cat:entryCount())
end

--@api: lurek.docs.exportSignatures
do
    local cat = docs_example_cat
    local path = "save/docs_signatures.json"
    lurek.docs.exportSignatures(cat, path)
    docs_log("signatures exported")
    docs_log("signatures target = " .. path)
    docs_log("catalog entries exported = " .. cat:entryCount())
end

--@api: lurek.docs.exportAll
do
    local cat = docs_example_cat
    local dir = "save/"
    lurek.docs.exportAll(cat, dir)
    docs_log("all docs exported")
    docs_log("export root = " .. dir)
    docs_log("catalog entries exported = " .. cat:entryCount())
end

--@api: lurek.docs.exportMarkdown
do
    local cat = docs_example_cat
    local path = "save/docs_api.md"
    lurek.docs.exportMarkdown(cat, path)
    docs_log("markdown exported")
    docs_log("markdown target = " .. path)
    docs_log("catalog entries exported = " .. cat:entryCount())
end

--@api: lurek.docs.exportCheatsheet
do
    local cat = docs_example_cat
    local path = "save/docs_cheatsheet.txt"
    lurek.docs.exportCheatsheet(cat, path)
    docs_log("cheatsheet exported")
    docs_log("cheatsheet target = " .. path)
    docs_log("catalog entries exported = " .. cat:entryCount())
end

--@api: lurek.docs.schema
do
    local s = lurek.docs.schema({ name = { type = "string", required = true }, age = { type = "number" } }, "PlayerSchema")
    local fields = s:getFields()
    docs_log("schema name = " .. s:getName())
    docs_log("schema type = " .. s:type())
    docs_log("field count = " .. #fields)
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
    docs_log("schema from toml, name = " .. s:getName())
    docs_log("schema field count = " .. #s:getFields())
    docs_log("schema type = " .. s:type())
end

--@api: lurek.docs.reflectLive
do
    local data = lurek.docs.reflectLive("math")
    docs_log("reflect math type = " .. type(data))
    docs_log("reflected rows = " .. #data)
    docs_log("first reflected name = " .. tostring(data[1] and data[1].name))
    docs_log("second reflected type = " .. tostring(data[2] and data[2].type))
end

--@api: lurek.docs.reflectTable
do
    local t = {foo = 1, bar = "hello"}
    local rows = lurek.docs.reflectTable(t, "mymod")
    docs_log("reflected rows = " .. #rows)
    docs_log("first reflected name = " .. tostring(rows[1] and rows[1].name))
    docs_log("first reflected type = " .. tostring(rows[1] and rows[1].type))
end

--@api: LSchema:validate
do
    local s = lurek.docs.schema({name = {type = "string", required = true}})
    local ok, errors = s:validate({name = "test"})
    docs_log("valid = " .. tostring(ok) .. " errors = " .. #errors)
    docs_log("schema type = " .. s:type())
    docs_log("field count = " .. #s:getFields())
end

--@api: LSchema:check
do
    local s = lurek.docs.schema({x = {type = "number"}})
    docs_log("check = " .. tostring(s:check({x = 42})))
    docs_log("schema name = " .. tostring(s:getName()))
    docs_log("is schema = " .. tostring(s:typeOf("LSchema")))
    docs_log("field count = " .. #s:getFields())
end

--@api: LSchema:assert
do
    local s = lurek.docs.schema({v = {type = "number"}})
    local ok = pcall(function() s["assert"](s, {v = 10}) end)
    docs_log("assert passed = " .. tostring(ok))
    docs_log("schema field count = " .. #s:getFields())
    docs_log("schema type = " .. s:type())
end

--@api: LSchema:getName
do
    local s = lurek.docs.schema({}, "TestSchema")
    docs_log("name = " .. s:getName())
    docs_log("schema name = " .. tostring(s:getName()))
    docs_log("field count = " .. #s:getFields())
    docs_log("is schema = " .. tostring(s:typeOf("LSchema")))
end

--@api: LSchema:getFields
do
    local s = lurek.docs.schema({a = {type = "number"}, b = {type = "string"}})
    local fields = s:getFields()
    docs_log("fields = " .. #fields)
    docs_log("first field = " .. tostring(fields[1]))
    docs_log("schema type = " .. s:type())
end

--@api: LSchema:type
do
    local s = lurek.docs.schema({})
    docs_log("type = " .. s:type())
    docs_log("schema fields = " .. tostring(#s:getFields()))
    docs_log("typeOf LSchema = " .. tostring(s:typeOf("LSchema")))
    docs_log("field count = " .. #s:getFields())
end

--@api: LSchema:typeOf
do
    local s = lurek.docs.schema({})
    docs_log("is LSchema = " .. tostring(s:typeOf("LSchema")))
    docs_log("type = " .. tostring(s:type()))
    docs_log("first field = " .. tostring(s:getFields()[1]))
    docs_log("field count = " .. #s:getFields())
end

--@api: LDocEntry:getName
do
    local entry = docs_example_entry
    docs_log("name = " .. entry:getName())
    docs_log("qualified chars = " .. #entry:getQualifiedName())
    docs_log("qualified = " .. tostring(entry:getQualifiedName()))
    docs_log("module = " .. tostring(entry:getModule()))
end

--@api: LDocEntry:getQualifiedName
do
    local entry = docs_example_entry
    docs_log("qualified = " .. entry:getQualifiedName())
    docs_log("qualified chars = " .. #entry:getQualifiedName())
    docs_log("module = " .. tostring(entry:getModule()))
    docs_log("kind = " .. tostring(entry:getKind()))
end

--@api: LDocEntry:getModule
do
    local entry = docs_example_entry
    docs_log("module = " .. entry:getModule())
    docs_log("qualified chars = " .. #entry:getQualifiedName())
    docs_log("kind = " .. tostring(entry:getKind()))
    docs_log("name = " .. tostring(entry:getName()))
end

--@api: LDocEntry:getKind
do
    local entry = docs_example_entry
    docs_log("kind = " .. entry:getKind())
    docs_log("qualified chars = " .. #entry:getQualifiedName())
    docs_log("name = " .. tostring(entry:getName()))
    docs_log("qualified = " .. tostring(entry:getQualifiedName()))
end

--@api: LDocEntry:getDescription
do
    local entry = docs_example_entry
    docs_log("desc len = " .. #entry:getDescription())
    docs_log("qualified chars = " .. #entry:getQualifiedName())
    docs_log("has description = " .. tostring(entry:hasDescription()))
    docs_log("name = " .. tostring(entry:getName()))
end

--@api: LDocEntry:getParameters
do
    local params = docs_example_entry:getParameters()
    docs_log("params = " .. #params)
    docs_log("params count = " .. tostring(#params))
    docs_log("first param name = " .. tostring(params[1] and params[1].name))
    docs_log("entry name = " .. tostring(docs_example_entry:getName()))
end

--@api: LDocEntry:getReturns
do
    local returns = docs_example_entry:getReturns()
    docs_log("returns = " .. #returns)
    docs_log("returns count = " .. tostring(#returns))
    docs_log("first return type = " .. tostring(returns[1] and returns[1].type))
    docs_log("entry name = " .. tostring(docs_example_entry:getName()))
end

--@api: LDocEntry:getExample
do
    local example = docs_example_entry:getExample()
    docs_log("example = " .. type(example))
    docs_log("example length = " .. tostring(example and #example or 0))
    docs_log("has example = " .. tostring(docs_example_entry:hasExample()))
    docs_log("entry kind = " .. tostring(docs_example_entry:getKind()))
end

--@api: LDocEntry:getSince
do
    local since = docs_example_entry:getSince()
    docs_log("since = " .. type(since))
    docs_log("since value = " .. tostring(since))
    docs_log("entry name = " .. tostring(docs_example_entry:getName()))
    docs_log("entry module = " .. tostring(docs_example_entry:getModule()))
end

--@api: LDocEntry:getDeprecated
do
    local deprecated = docs_example_entry:getDeprecated()
    docs_log("deprecated = " .. type(deprecated))
    docs_log("deprecated value = " .. tostring(deprecated))
    docs_log("entry qualified = " .. tostring(docs_example_entry:getQualifiedName()))
    docs_log("entry module = " .. tostring(docs_example_entry:getModule()))
end

--@api: LDocEntry:getScore
do
    local entry = docs_example_entry
    docs_log("score = " .. entry:getScore())
    docs_log("qualified chars = " .. #entry:getQualifiedName())
    docs_log("module = " .. tostring(entry:getModule()))
    docs_log("kind = " .. tostring(entry:getKind()))
end

--@api: LDocEntry:hasDescription
do
    local entry = docs_example_entry
    docs_log("hasDesc = " .. tostring(entry:hasDescription()))
    docs_log("qualified chars = " .. #entry:getQualifiedName())
    docs_log("description length = " .. tostring(#entry:getDescription()))
    docs_log("entry kind = " .. tostring(entry:getKind()))
end

--@api: LDocEntry:hasParameters
do
    local entry = docs_example_entry
    docs_log("hasParams = " .. tostring(entry:hasParameters()))
    docs_log("qualified chars = " .. #entry:getQualifiedName())
    docs_log("param count = " .. tostring(#entry:getParameters()))
    docs_log("entry name = " .. tostring(entry:getName()))
end

--@api: LDocEntry:hasReturnType
do
    local entry = docs_example_entry
    docs_log("hasReturn = " .. tostring(entry:hasReturnType()))
    docs_log("qualified chars = " .. #entry:getQualifiedName())
    docs_log("return count = " .. tostring(#entry:getReturns()))
    docs_log("entry name = " .. tostring(entry:getName()))
end

--@api: LDocEntry:hasExample
do
    local entry = docs_example_entry
    docs_log("hasExample = " .. tostring(entry:hasExample()))
    docs_log("qualified chars = " .. #entry:getQualifiedName())
    docs_log("example text type = " .. type(entry:getExample()))
    docs_log("entry qualified = " .. tostring(entry:getQualifiedName()))
end

--@api: LDocEntry:type
do
    local entry = docs_example_entry
    docs_log("type = " .. entry:type())
    docs_log("qualified chars = " .. #entry:getQualifiedName())
    docs_log("typeOf LDocEntry = " .. tostring(entry:typeOf("LDocEntry")))
    docs_log("entry module = " .. tostring(entry:getModule()))
end

--@api: LDocEntry:typeOf
do
    local entry = docs_example_entry
    docs_log("is LDocEntry = " .. tostring(entry:typeOf("LDocEntry")))
    docs_log("type = " .. tostring(entry:type()))
    docs_log("entry module = " .. tostring(entry:getModule()))
    docs_log("entry kind = " .. tostring(entry:getKind()))
end

--- Docs Module Part 2: LApiCatalog, LValidationReport, LQualityReport

--@api: LApiCatalog:getModules
do
    local cat = docs_example_cat
    local modules = cat:getModules()
    docs_log("modules = " .. #modules)
    docs_log("first module = " .. tostring(modules[1]))
    docs_log("catalog entries = " .. tostring(cat:entryCount()))
end

--@api: LApiCatalog:getEntries
do
    local cat = docs_example_cat
    local all = cat:getEntries()
    local math_entries = cat:getEntries("math")
    docs_log("all=" .. #all .. " math=" .. #math_entries)
    docs_log("first global entry = " .. tostring(all[1] and all[1]:getQualifiedName()))
end

--@api: LApiCatalog:getEntry
do
    local cat = docs_example_cat
    local entry = cat:getEntry("lurek.math.lerp")
    docs_log("found entry = " .. tostring(entry ~= nil))
    docs_log("catalog modules = " .. tostring(#cat:getModules()))
    docs_log("entry kind = " .. tostring(entry and entry:getKind()))
end

--@api: LApiCatalog:getTypes
do
    local cat = docs_example_cat
    local types = cat:getTypes("math")
    docs_log("math types = " .. #types)
    docs_log("first type = " .. tostring(types[1]))
    docs_log("catalog entries = " .. tostring(cat:entryCount()))
end

--@api: LApiCatalog:getTypeMethods
do
    local cat = docs_example_cat
    local methods = cat:getTypeMethods("LVec2")
    docs_log("LVec2 methods = " .. #methods)
    docs_log("first method = " .. tostring(methods[1] and methods[1]:getQualifiedName()))
    docs_log("catalog entries = " .. tostring(cat:entryCount()))
end

--@api: LApiCatalog:entryCount
do
    local cat = docs_example_cat
    local total = cat:entryCount()
    local math_count = cat:entryCount("math")
    docs_log("total=" .. total .. " math=" .. math_count)
    docs_log("module count = " .. #cat:getModules())
end

--@api: LApiCatalog:merge
do
    local a = lurek.docs.scanModule("math")
    local b = lurek.docs.scanModule("timer")
    local merged = a:merge(b)
    docs_log("merged = " .. merged:entryCount())
    docs_log("merged module count = " .. #merged:getModules())
end

--@api: LApiCatalog:filter
do
    local cat = docs_example_cat
    local fns = cat:filter(function(entry) return entry:getKind() == "function" end)
    docs_log("functions = " .. fns:entryCount())
    docs_log("filtered type = " .. fns:type())
    docs_log("first filtered entry = " .. tostring(fns:getEntries()[1] and fns:getEntries()[1]:getQualifiedName()))
end

--@api: LApiCatalog:search
do
    local cat = docs_example_cat
    local results = cat:search("lerp")
    docs_log("search results = " .. #results)
    docs_log("first search hit = " .. tostring(results[1] and results[1]:getQualifiedName()))
    docs_log("catalog entries = " .. tostring(cat:entryCount()))
end

--@api: LApiCatalog:toTable
do
    local cat = lurek.docs.scanModule("math")
    local rows = cat:toTable()
    docs_log("rows = " .. #rows)
    docs_log("first row name = " .. tostring(rows[1] and rows[1].name))
    docs_log("first row module = " .. tostring(rows[1] and rows[1].module))
end

--@api: LApiCatalog:toJSON
do
    local cat = lurek.docs.scanModule("timer")
    local json = cat:toJSON()
    docs_log("json length = " .. #json)
    docs_log("json has timer = " .. tostring(string.find(json, "timer", 1, true) ~= nil))
    docs_log("catalog entries = " .. tostring(cat:entryCount()))
end

--@api: LApiCatalog:type
do
    local cat = docs_example_cat
    docs_log("type = " .. cat:type())
    docs_log("catalog modules = " .. tostring(#cat:getModules()))
    docs_log("typeOf LApiCatalog = " .. tostring(cat:typeOf("LApiCatalog")))
    docs_log("module count = " .. tostring(#cat:getModules()))
end

--@api: LApiCatalog:typeOf
do
    local cat = docs_example_cat
    docs_log("is LApiCatalog = " .. tostring(cat:typeOf("LApiCatalog")))
    docs_log("type = " .. tostring(cat:type()))
    docs_log("catalog entries = " .. tostring(cat:entryCount()))
    docs_log("entry count = " .. tostring(cat:entryCount()))
end

--@api: LValidationReport:isValid
do
    local cat = docs_example_cat
    local report = docs_example_validate
    docs_log("valid = " .. tostring(report:isValid()))
    docs_log("missing count = " .. tostring(report:missingCount()))
    docs_log("report type = " .. report:type())
end

--@api: LValidationReport:getMissing
do
    local cat = docs_example_cat
    local report = docs_example_validate
    local missing = report:getMissing()
    docs_log("missing = " .. #missing)
    docs_log("first missing = " .. tostring(missing[1] and missing[1].qualifiedName))
end

--@api: LValidationReport:getPhantom
do
    local cat = docs_example_cat
    local report = docs_example_validate
    local phantom = report:getPhantom()
    docs_log("phantom = " .. #phantom)
    docs_log("first phantom = " .. tostring(phantom[1] and phantom[1].qualifiedName))
end

--@api: LValidationReport:getIncomplete
do
    local cat = docs_example_cat
    local report = docs_example_validate
    local incomplete = report:getIncomplete()
    docs_log("incomplete = " .. #incomplete)
    docs_log("first incomplete = " .. tostring(incomplete[1] and incomplete[1].qualifiedName))
end

--@api: LValidationReport:missingCount
do
    local cat = docs_example_cat
    local report = docs_example_validate
    docs_log("missing count = " .. report:missingCount())
    docs_log("is valid = " .. tostring(report:isValid()))
    docs_log("report type = " .. report:type())
end

--@api: LValidationReport:phantomCount
do
    local cat = docs_example_cat
    local report = docs_example_validate
    docs_log("phantom count = " .. report:phantomCount())
    docs_log("missing count = " .. report:missingCount())
    docs_log("report type = " .. report:type())
end

--@api: LValidationReport:incompleteCount
do
    local cat = docs_example_cat
    local report = docs_example_validate
    docs_log("incomplete count = " .. report:incompleteCount())
    docs_log("phantom count = " .. report:phantomCount())
    docs_log("report type = " .. report:type())
end

--@api: LValidationReport:getSummary
do
    local cat = docs_example_cat
    local report = docs_example_validate
    local summary = report:getSummary()
    docs_log("summary = " .. summary)
    docs_log("summary length = " .. #summary)
    docs_log("report type = " .. report:type())
end

--@api: LValidationReport:toTable
do
    local cat = docs_example_cat
    local report = docs_example_validate
    local t = report:toTable()
    docs_log("table keys: missing=" .. #t.missing .. " phantom=" .. #t.phantom)
    docs_log("incomplete=" .. #t.incomplete)
end

--@api: LValidationReport:toJSON
do
    local cat = docs_example_cat
    local report = docs_example_validate
    local json = report:toJSON()
    docs_log("json length = " .. #json)
    docs_log("json has missing key = " .. tostring(string.find(json, "missing", 1, true) ~= nil))
end

--@api: LValidationReport:type
do
    local cat = docs_example_cat
    local report = docs_example_validate
    docs_log("type = " .. report:type())
    docs_log("missing count = " .. tostring(report:missingCount()))
    docs_log("typeOf LValidationReport = " .. tostring(report:typeOf("LValidationReport")))
end

--@api: LValidationReport:typeOf
do
    local cat = docs_example_cat
    local report = docs_example_validate
    docs_log("is report = " .. tostring(report:typeOf("LValidationReport")))
    docs_log("type = " .. tostring(report:type()))
    docs_log("valid = " .. tostring(report:isValid()))
end

--@api: LQualityReport:getOverallScore
do
    local cat = docs_example_cat
    local qr = docs_example_quality
    docs_log("score = " .. qr:getOverallScore())
    docs_log("grade = " .. tostring(qr:getGrade()))
    docs_log("type = " .. qr:type())
end

--@api: LQualityReport:getGrade
do
    local cat = docs_example_cat
    local qr = docs_example_quality
    docs_log("grade = " .. qr:getGrade())
    docs_log("overall score = " .. tostring(qr:getOverallScore()))
    docs_log("type = " .. qr:type())
end

--@api: LQualityReport:getModuleScores
do
    local cat = docs_example_cat
    local qr = docs_example_quality
    local scores = qr:getModuleScores()
    docs_log("module scores type = " .. type(scores))
    docs_log("math score = " .. tostring(scores.math))
end

--@api: LQualityReport:getWorst
do
    local cat = docs_example_cat
    local qr = docs_example_quality
    local worst = qr:getWorst(5)
    docs_log("worst 5 = " .. #worst)
    docs_log("first worst = " .. tostring(worst[1] and worst[1]:getQualifiedName()))
end

--@api: LQualityReport:getBest
do
    local cat = docs_example_cat
    local qr = docs_example_quality
    local best = qr:getBest(5)
    docs_log("best 5 = " .. #best)
    docs_log("first best = " .. tostring(best[1] and best[1]:getQualifiedName()))
end

--@api: LQualityReport:getByGrade
do
    local cat = docs_example_cat
    local qr = docs_example_quality
    local a_entries = qr:getByGrade("A")
    docs_log("grade A entries = " .. #a_entries)
    docs_log("first A entry = " .. tostring(a_entries[1] and a_entries[1]:getQualifiedName()))
end

--@api: LQualityReport:getSummary
do
    local cat = docs_example_cat
    local qr = docs_example_quality
    local summary = qr:getSummary()
    docs_log("summary = " .. summary)
    docs_log("summary length = " .. #summary)
    docs_log("type = " .. qr:type())
end

--@api: LQualityReport:toTable
do
    local cat = docs_example_cat
    local qr = docs_example_quality
    local t = qr:toTable()
    docs_log("overall = " .. t.overallScore .. " grade = " .. t.grade)
    docs_log("module score count = " .. tostring(type(t.moduleScores)))
end

--@api: LQualityReport:toJSON
do
    local cat = docs_example_cat
    local qr = docs_example_quality
    local json = qr:toJSON()
    docs_log("json length = " .. #json)
    docs_log("json has grade = " .. tostring(string.find(json, "grade", 1, true) ~= nil))
end

--@api: LQualityReport:type
do
    local cat = docs_example_cat
    local qr = docs_example_quality
    docs_log("type = " .. qr:type())
    docs_log("summary length = " .. #qr:getSummary())
    docs_log("typeOf LQualityReport = " .. tostring(qr:typeOf("LQualityReport")))
end

--@api: LQualityReport:typeOf
do
    local cat = docs_example_cat
    local qr = docs_example_quality
    docs_log("is report = " .. tostring(qr:typeOf("LQualityReport")))
    docs_log("type = " .. tostring(qr:type()))
    docs_log("grade = " .. tostring(qr:getGrade()))
end
