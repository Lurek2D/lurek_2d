-- content/examples/docs.lua
-- Auto-generated from content/examples2/docs_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/docs.lua

--- Docs Module Part 1: Scanning, Catalog, Schema, DocEntry, Validation, Quality, Export


--@api-stub: lurek.docs.scan
do
    local cat = lurek.docs.scan()
    print("scanned entries = " .. cat:entryCount())
end

--@api-stub: lurek.docs.scanModule
do
    local cat = lurek.docs.scanModule("math")
    print("math entries = " .. cat:entryCount())
end

--@api-stub: lurek.docs.loadToml
do
    local path = "save/_fs_tests/docs_load_toml_example.toml"
    lurek.filesystem.write(path, '[[entries]]\nname = "play"\nqualifiedName = "lurek.audio.play"\nmodule = "audio"\nkind = "function"\ndescription = "Plays a sound"')
    local cat = lurek.docs.loadToml(path)
    print("loaded entries = " .. cat:entryCount())
end

--@api-stub: lurek.docs.loadAll
do
    lurek.filesystem.write("save/_fs_tests/docs_load_all_a.toml", '[[entries]]\nname = "one"\nqualifiedName = "lurek.test.one"\nmodule = "test"\nkind = "function"\ndescription = "First entry"')
    lurek.filesystem.write("save/_fs_tests/docs_load_all_b.toml", '[[entries]]\nname = "two"\nqualifiedName = "lurek.test.two"\nmodule = "test"\nkind = "function"\ndescription = "Second entry"')
    local cat = lurek.docs.loadAll("save/_fs_tests/")
    print("all entries = " .. cat:entryCount())
end

--@api-stub: lurek.docs.describe
do
    lurek.docs.describe("lurek.math.lerp", "Linearly interpolates between a and b.")
    print("description set")
end

--@api-stub: lurek.docs.setParamInfo
do
    lurek.docs.setParamInfo("lurek.math.lerp", {{name = "t", type = "number", description = "Interpolation factor", optional = false}})
    print("params set")
end

--@api-stub: lurek.docs.setReturnInfo
do
    lurek.docs.setReturnInfo("lurek.math.lerp", {
        {type = "number", description = "Interpolated value"},
    })
    print("returns set")
end

--@api-stub: lurek.docs.getCatalog
do
    local cat = lurek.docs.getCatalog()
    print("catalog entries = " .. cat:entryCount())
end

--@api-stub: lurek.docs.resetCatalog
do
    lurek.docs.resetCatalog()
    local cat = lurek.docs.getCatalog()
    print("after reset entries = " .. cat:entryCount())
end

--@api-stub: lurek.docs.validate
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    print("valid = " .. tostring(report:isValid()))
end

--@api-stub: lurek.docs.validateModule
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validateModule("math", cat)
    print("math missing = " .. report:missingCount())
end

--@api-stub: lurek.docs.checkStaleness
do
    local cat = lurek.docs.scan()
    local result = lurek.docs.checkStaleness(cat, "src/math/")
    print("stale = " .. #result.stale .. " current = " .. #result.current)
end

--@api-stub: lurek.docs.quality
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    print("quality score = " .. qr:getOverallScore())
end

--@api-stub: lurek.docs.qualityModule
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.qualityModule("math", cat)
    print("math quality = " .. qr:getOverallScore())
end

--@api-stub: lurek.docs.coverage
do
    local cat = lurek.docs.scan()
    local documented, live = lurek.docs.coverage(cat)
    print("documented=" .. documented .. " live=" .. live)
end

--@api-stub: lurek.docs.coverageModule
do
    local cat = lurek.docs.scan()
    local documented, live = lurek.docs.coverageModule("math", cat)
    print("math documented=" .. documented .. " live=" .. live)
end

--@api-stub: lurek.docs.exportCompletions
do
    local cat = lurek.docs.scan()
    lurek.docs.exportCompletions(cat, "build/completions.json")
    print("completions exported")
end

--@api-stub: lurek.docs.exportHover
do
    local cat = lurek.docs.scan()
    lurek.docs.exportHover(cat, "build/hover.json")
    print("hover exported")
end

--@api-stub: lurek.docs.exportSignatures
do
    local cat = lurek.docs.scan()
    lurek.docs.exportSignatures(cat, "build/signatures.json")
    print("signatures exported")
end

--@api-stub: lurek.docs.exportAll
do
    local cat = lurek.docs.scan()
    lurek.docs.exportAll(cat, "build/docs/")
    print("all docs exported")
end

--@api-stub: lurek.docs.exportMarkdown
do
    local cat = lurek.docs.scan()
    lurek.docs.exportMarkdown(cat, "build/api.md")
    print("markdown exported")
end

--@api-stub: lurek.docs.exportCheatsheet
do
    local cat = lurek.docs.scan()
    lurek.docs.exportCheatsheet(cat, "build/cheatsheet.txt")
    print("cheatsheet exported")
end

--@api-stub: lurek.docs.schema
do
    local s = lurek.docs.schema({ name = { type = "string", required = true }, age = { type = "number" } }, "PlayerSchema")
    print("schema name = " .. s:getName())
end

--@api-stub: lurek.docs.schemaFromToml
do
    local toml = "[fields.name]\ntype = \"string\"\nrequired = true"
    local s = lurek.docs.schemaFromToml(toml)
    print("schema from toml, name = " .. s:getName())
end

--@api-stub: lurek.docs.reflectLive
do
    local data = lurek.docs.reflectLive("math")
    print("reflect math type = " .. type(data))
end

--@api-stub: lurek.docs.reflectTable
do
    local t = {foo = 1, bar = "hello"}
    local rows = lurek.docs.reflectTable(t, "mymod")
    print("reflected rows = " .. #rows)
end

--@api-stub: LSchema:validate
do
    local s = lurek.docs.schema({name = {type = "string", required = true}})
    local ok, errors = s:validate({name = "test"})
    print("valid = " .. tostring(ok) .. " errors = " .. #errors)
end

--@api-stub: LSchema:check
do
    local s = lurek.docs.schema({x = {type = "number"}})
    print("check = " .. tostring(s:check({x = 42})))
end

--@api-stub: LSchema:assert
do
    local s = lurek.docs.schema({v = {type = "number"}})
    local ok = pcall(function() s["assert"](s, {v = 10}) end)
    print("assert passed = " .. tostring(ok))
end

--@api-stub: LSchema:getName
do
    local s = lurek.docs.schema({}, "TestSchema")
    print("name = " .. s:getName())
end

--@api-stub: LSchema:getFields
do
    local s = lurek.docs.schema({a = {type = "number"}, b = {type = "string"}})
    local fields = s:getFields()
    print("fields = " .. #fields)
end

--@api-stub: LSchema:type
do
    local s = lurek.docs.schema({})
    print("type = " .. s:type())
end

--@api-stub: LSchema:typeOf
do
    local s = lurek.docs.schema({})
    print("is LSchema = " .. tostring(s:typeOf("LSchema")))
end

--@api-stub: LDocEntry:getName
do
    local entry = lurek.docs.scan():getEntries("math")[1]
    print("name = " .. entry:getName())
end

--@api-stub: LDocEntry:getQualifiedName
do
    local entry = lurek.docs.scan():getEntries("math")[1]
    print("qualified = " .. entry:getQualifiedName())
end

--@api-stub: LDocEntry:getModule
do
    local entry = lurek.docs.scan():getEntries("math")[1]
    print("module = " .. entry:getModule())
end

--@api-stub: LDocEntry:getKind
do
    local entry = lurek.docs.scan():getEntries("math")[1]
    print("kind = " .. entry:getKind())
end

--@api-stub: LDocEntry:getDescription
do
    local entry = lurek.docs.scan():getEntries()[1]
    print("desc len = " .. #entry:getDescription())
end

--@api-stub: LDocEntry:getParameters
do
    local params = lurek.docs.scan():getEntries("math")[1]:getParameters()
    print("params = " .. #params)
end

--@api-stub: LDocEntry:getReturns
do
    local returns = lurek.docs.scan():getEntries("math")[1]:getReturns()
    print("returns = " .. #returns)
end

--@api-stub: LDocEntry:getExample
do
    local example = lurek.docs.scan():getEntries()[1]:getExample()
    print("example = " .. type(example))
end

--@api-stub: LDocEntry:getSince
do
    local since = lurek.docs.scan():getEntries()[1]:getSince()
    print("since = " .. type(since))
end

--@api-stub: LDocEntry:getDeprecated
do
    local deprecated = lurek.docs.scan():getEntries()[1]:getDeprecated()
    print("deprecated = " .. type(deprecated))
end

--@api-stub: LDocEntry:getScore
do
    local entry = lurek.docs.scan():getEntries()[1]
    print("score = " .. entry:getScore())
end

--@api-stub: LDocEntry:hasDescription
do
    local entry = lurek.docs.scan():getEntries()[1]
    print("hasDesc = " .. tostring(entry:hasDescription()))
end

--@api-stub: LDocEntry:hasParameters
do
    local entry = lurek.docs.scan():getEntries()[1]
    print("hasParams = " .. tostring(entry:hasParameters()))
end

--@api-stub: LDocEntry:hasReturnType
do
    local entry = lurek.docs.scan():getEntries()[1]
    print("hasReturn = " .. tostring(entry:hasReturnType()))
end

--@api-stub: LDocEntry:hasExample
do
    local entry = lurek.docs.scan():getEntries()[1]
    print("hasExample = " .. tostring(entry:hasExample()))
end

--@api-stub: LDocEntry:type
do
    local entry = lurek.docs.scan():getEntries()[1]
    print("type = " .. entry:type())
end

--@api-stub: LDocEntry:typeOf
do
    local entry = lurek.docs.scan():getEntries()[1]
    print("is LDocEntry = " .. tostring(entry:typeOf("LDocEntry")))
end

--- Docs Module Part 2: LApiCatalog, LValidationReport, LQualityReport


--@api-stub: LApiCatalog:getModules
do
    local cat = lurek.docs.scan()
    local modules = cat:getModules()
    print("modules = " .. #modules)
end

--@api-stub: LApiCatalog:getEntries
do
    local cat = lurek.docs.scan()
    local all = cat:getEntries()
    local math_entries = cat:getEntries("math")
    print("all=" .. #all .. " math=" .. #math_entries)
end

--@api-stub: LApiCatalog:getEntry
do
    local cat = lurek.docs.scan()
    print("found entry = " .. tostring(cat:getEntry("lurek.math.lerp") ~= nil))
end

--@api-stub: LApiCatalog:getTypes
do
    local cat = lurek.docs.scan()
    local types = cat:getTypes("math")
    print("math types = " .. #types)
end

--@api-stub: LApiCatalog:getTypeMethods
do
    local cat = lurek.docs.scan()
    local methods = cat:getTypeMethods("LVec2")
    print("LVec2 methods = " .. #methods)
end

--@api-stub: LApiCatalog:entryCount
do
    local cat = lurek.docs.scan()
    local total = cat:entryCount()
    local math_count = cat:entryCount("math")
    print("total=" .. total .. " math=" .. math_count)
end

--@api-stub: LApiCatalog:merge
do
    local a = lurek.docs.scanModule("math")
    local b = lurek.docs.scanModule("timer")
    local merged = a:merge(b)
    print("merged = " .. merged:entryCount())
end

--@api-stub: LApiCatalog:filter
do
    local cat = lurek.docs.scan()
    local fns = cat:filter(function(entry) return entry:getKind() == "function" end)
    print("functions = " .. fns:entryCount())
end

--@api-stub: LApiCatalog:search
do
    local cat = lurek.docs.scan()
    local results = cat:search("lerp")
    print("search results = " .. #results)
end

--@api-stub: LApiCatalog:toTable
do
    local cat = lurek.docs.scanModule("math")
    local rows = cat:toTable()
    print("rows = " .. #rows)
end

--@api-stub: LApiCatalog:toJSON
do
    local cat = lurek.docs.scanModule("timer")
    local json = cat:toJSON()
    print("json length = " .. #json)
end

--@api-stub: LApiCatalog:type
do
    local cat = lurek.docs.scan()
    print("type = " .. cat:type())
end

--@api-stub: LApiCatalog:typeOf
do
    local cat = lurek.docs.scan()
    print("is LApiCatalog = " .. tostring(cat:typeOf("LApiCatalog")))
end

--@api-stub: LValidationReport:isValid
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    print("valid = " .. tostring(report:isValid()))
end

--@api-stub: LValidationReport:getMissing
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    local missing = report:getMissing()
    print("missing = " .. #missing)
end

--@api-stub: LValidationReport:getPhantom
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    local phantom = report:getPhantom()
    print("phantom = " .. #phantom)
end

--@api-stub: LValidationReport:getIncomplete
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    local incomplete = report:getIncomplete()
    print("incomplete = " .. #incomplete)
end

--@api-stub: LValidationReport:missingCount
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    print("missing count = " .. report:missingCount())
end

--@api-stub: LValidationReport:phantomCount
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    print("phantom count = " .. report:phantomCount())
end

--@api-stub: LValidationReport:incompleteCount
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    print("incomplete count = " .. report:incompleteCount())
end

--@api-stub: LValidationReport:getSummary
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    print("summary = " .. report:getSummary())
end

--@api-stub: LValidationReport:toTable
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    local t = report:toTable()
    print("table keys: missing=" .. #t.missing .. " phantom=" .. #t.phantom)
end

--@api-stub: LValidationReport:toJSON
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    local json = report:toJSON()
    print("json length = " .. #json)
end

--@api-stub: LValidationReport:type
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    print("type = " .. report:type())
end

--@api-stub: LValidationReport:typeOf
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    print("is report = " .. tostring(report:typeOf("LValidationReport")))
end

--@api-stub: LQualityReport:getOverallScore
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    print("score = " .. qr:getOverallScore())
end

--@api-stub: LQualityReport:getGrade
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    print("grade = " .. qr:getGrade())
end

--@api-stub: LQualityReport:getModuleScores
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    local scores = qr:getModuleScores()
    print("module scores type = " .. type(scores))
end

--@api-stub: LQualityReport:getWorst
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    local worst = qr:getWorst(5)
    print("worst 5 = " .. #worst)
end

--@api-stub: LQualityReport:getBest
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    local best = qr:getBest(5)
    print("best 5 = " .. #best)
end

--@api-stub: LQualityReport:getByGrade
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    local a_entries = qr:getByGrade("A")
    print("grade A entries = " .. #a_entries)
end

--@api-stub: LQualityReport:getSummary
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    print("summary = " .. qr:getSummary())
end

--@api-stub: LQualityReport:toTable
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    local t = qr:toTable()
    print("overall = " .. t.overallScore .. " grade = " .. t.grade)
end

--@api-stub: LQualityReport:toJSON
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    local json = qr:toJSON()
    print("json length = " .. #json)
end

--@api-stub: LQualityReport:type
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    print("type = " .. qr:type())
end

--@api-stub: LQualityReport:typeOf
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    print("is report = " .. tostring(qr:typeOf("LQualityReport")))
end

print("content/examples/docs.lua")
