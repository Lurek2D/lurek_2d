-- content/examples/docs.lua
-- Auto-generated from content/examples2/docs_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/docs.lua

--- Docs Module Part 1: Scanning, Catalog, Schema, DocEntry, Validation, Quality, Export



--@api: lurek.docs.scan
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = lurek.docs.scan()
    local modules = cat:getModules()
    lurek.log.info("scanned entries = " .. cat:entryCount())
    lurek.log.info("catalog entries = " .. tostring(cat:entryCount()))
    lurek.log.info("first module = " .. tostring(modules[1]))
end

--@api: lurek.docs.scanModule
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = lurek.docs.scanModule("math")
    local entries = cat:getEntries("math")
    lurek.log.info("math entries = " .. cat:entryCount())
    lurek.log.info("math catalog type = " .. cat:type())
    lurek.log.info("first math entry = " .. tostring(entries[1] and entries[1]:getQualifiedName()))
end

--@api: lurek.docs.loadToml
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local path = "save/_fs_tests/docs_load_toml_example.toml"
    lurek.filesystem.write(path, '[[entries]]\nname = "play"\nqualifiedName = "lurek.audio.play"\nmodule = "audio"\nkind = "function"\ndescription = "Plays a sound"')
    local cat = lurek.docs.loadToml(path)
    local entry = cat:getEntry("lurek.audio.play")
    lurek.log.info("loaded entries = " .. cat:entryCount())
    lurek.log.info("loaded type = " .. cat:type())
    lurek.log.info("loaded qualified name = " .. tostring(entry and entry:getQualifiedName()))
end

--@api: lurek.docs.loadAll
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local dir = "save/_fs_tests/docs_load_all/"
    lurek.filesystem.write(dir .. "a.toml", '[[entries]]\nname = "one"\nqualifiedName = "lurek.test.one"\nmodule = "test"\nkind = "function"\ndescription = "First entry"')
    lurek.filesystem.write(dir .. "b.toml", '[[entries]]\nname = "two"\nqualifiedName = "lurek.test.two"\nmodule = "test"\nkind = "function"\ndescription = "Second entry"')
    local cat = lurek.docs.loadAll(dir)
    lurek.log.info("all entries = " .. cat:entryCount())
    lurek.log.info("loadAll type = " .. cat:type())
    lurek.log.info("has lurek.test.one = " .. tostring(cat:getEntry("lurek.test.one") ~= nil))
end

--@api: lurek.docs.describe
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    lurek.docs.describe("lurek.math.lerp", "Linearly interpolates between a and b.")
    local cat = lurek.docs.getCatalog()
    local entry = cat:getEntry("lurek.math.lerp")
    lurek.log.info("description set")
    lurek.log.info("catalog entries = " .. tostring(cat:entryCount()))
    lurek.log.info("description length = " .. tostring(entry and #entry:getDescription() or 0))
end

--@api: lurek.docs.setParamInfo
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.test.blend", "Blend two values.")
    lurek.docs.setParamInfo("lurek.test.blend", {
        { name = "t", type = "number", description = "Interpolation factor", optional = false },
    })
    local entry = lurek.docs.getCatalog():getEntry("lurek.test.blend")
    local params = entry:getParameters()
    lurek.log.info("params set = " .. #params)
    lurek.log.info("first param name = " .. tostring(params[1] and params[1].name))
end

--@api: lurek.docs.setReturnInfo
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.test.blend", "Blend two values.")
    lurek.docs.setReturnInfo("lurek.test.blend", {
        {type = "number", description = "Interpolated value"},
    })
    local entry = lurek.docs.getCatalog():getEntry("lurek.test.blend")
    local returns = entry:getReturns()
    lurek.log.info("returns set = " .. #returns)
    lurek.log.info("first return type = " .. tostring(returns[1] and returns[1].type))
end

--@api: lurek.docs.getCatalog
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = lurek.docs.getCatalog()
    local modules = cat:getModules()
    lurek.log.info("catalog entries = " .. cat:entryCount())
    lurek.log.info("catalog userdata type = " .. cat:type())
    lurek.log.info("module count = " .. #modules)
end

--@api: lurek.docs.resetCatalog
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    lurek.docs.describe("lurek.test.temp", "Temporary entry")
    lurek.docs.resetCatalog()
    local cat = lurek.docs.getCatalog()
    lurek.log.info("after reset entries = " .. cat:entryCount())
    lurek.log.info("after reset type = " .. cat:type())
end

--@api: lurek.docs.validate
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = docs_example_validate
    lurek.log.info("valid = " .. tostring(report:isValid()))
    lurek.log.info("missing count = " .. tostring(report:missingCount()))
    lurek.log.info("report type = " .. report:type())
end

--@api: lurek.docs.validateModule
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = lurek.docs.validateModule("math", cat)
    lurek.log.info("math missing = " .. report:missingCount())
    lurek.log.info("math phantom = " .. report:phantomCount())
    lurek.log.info("report type = " .. report:type())
end

--@api: lurek.docs.checkStaleness
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local result = lurek.docs.checkStaleness(cat, "src/math/")
    lurek.log.info("stale = " .. #result.stale .. " current = " .. #result.current)
    lurek.log.info("missing = " .. #result.missing)
    lurek.log.info("first current path = " .. tostring(result.current[1]))
end

--@api: lurek.docs.quality
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local qr = docs_example_quality
    lurek.log.info("quality score = " .. qr:getOverallScore())
    lurek.log.info("quality grade = " .. tostring(qr:getGrade()))
    lurek.log.info("report type = " .. qr:type())
end

--@api: lurek.docs.qualityModule
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local qr = lurek.docs.qualityModule("math", cat)
    lurek.log.info("math quality = " .. qr:getOverallScore())
    lurek.log.info("math grade = " .. tostring(qr:getGrade()))
    lurek.log.info("report type = " .. qr:type())
end

--@api: lurek.docs.coverage
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local documented, live = lurek.docs.coverage(cat)
    lurek.log.info("documented=" .. documented .. " live=" .. live)
    lurek.log.info("coverage gap=" .. tostring(live - documented))
    lurek.log.info("catalog entries=" .. cat:entryCount())
end

--@api: lurek.docs.coverageModule
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local documented, live = lurek.docs.coverageModule("math", cat)
    lurek.log.info("math documented=" .. documented .. " live=" .. live)
    lurek.log.info("math coverage gap=" .. tostring(live - documented))
    lurek.log.info("math entry count=" .. cat:entryCount("math"))
end

--@api: lurek.docs.exportCompletions
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local path = "save/docs_completions.json"
    lurek.docs.exportCompletions(cat, path)
    lurek.log.info("completions exported")
    lurek.log.info("completions target = " .. path)
    lurek.log.info("catalog entries exported = " .. cat:entryCount())
end

--@api: lurek.docs.exportHover
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local path = "save/docs_hover.json"
    lurek.docs.exportHover(cat, path)
    lurek.log.info("hover exported")
    lurek.log.info("hover target = " .. path)
    lurek.log.info("catalog entries exported = " .. cat:entryCount())
end

--@api: lurek.docs.exportSignatures
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local path = "save/docs_signatures.json"
    lurek.docs.exportSignatures(cat, path)
    lurek.log.info("signatures exported")
    lurek.log.info("signatures target = " .. path)
    lurek.log.info("catalog entries exported = " .. cat:entryCount())
end

--@api: lurek.docs.exportAll
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local dir = "save/"
    lurek.docs.exportAll(cat, dir)
    lurek.log.info("all docs exported")
    lurek.log.info("export root = " .. dir)
    lurek.log.info("catalog entries exported = " .. cat:entryCount())
end

--@api: lurek.docs.exportMarkdown
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local path = "save/docs_api.md"
    lurek.docs.exportMarkdown(cat, path)
    lurek.log.info("markdown exported")
    lurek.log.info("markdown target = " .. path)
    lurek.log.info("catalog entries exported = " .. cat:entryCount())
end

--@api: lurek.docs.exportCheatsheet
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local path = "save/docs_cheatsheet.txt"
    lurek.docs.exportCheatsheet(cat, path)
    lurek.log.info("cheatsheet exported")
    lurek.log.info("cheatsheet target = " .. path)
    lurek.log.info("catalog entries exported = " .. cat:entryCount())
end

--@api: lurek.docs.schema
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local s = lurek.docs.schema({ name = { type = "string", required = true }, age = { type = "number" } }, "PlayerSchema")
    local fields = s:getFields()
    lurek.log.info("schema name = " .. s:getName())
    lurek.log.info("schema type = " .. s:type())
    lurek.log.info("field count = " .. #fields)
end

--@api: lurek.docs.schemaFromToml
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local toml = [[
name = "PlayerSchema"
strict = true

    [rules.name]
type = "string"
required = true
]]
    local s = lurek.docs.schemaFromToml(toml)
    lurek.log.info("schema from toml, name = " .. s:getName())
    lurek.log.info("schema field count = " .. #s:getFields())
    lurek.log.info("schema type = " .. s:type())
end

--@api: lurek.docs.reflectLive
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local data = lurek.docs.reflectLive("math")
    lurek.log.info("reflect math type = " .. type(data))
    lurek.log.info("reflected rows = " .. #data)
    lurek.log.info("first reflected name = " .. tostring(data[1] and data[1].name))
    lurek.log.info("second reflected type = " .. tostring(data[2] and data[2].type))
end

--@api: lurek.docs.reflectTable
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local t = {foo = 1, bar = "hello"}
    local rows = lurek.docs.reflectTable(t, "mymod")
    lurek.log.info("reflected rows = " .. #rows)
    lurek.log.info("first reflected name = " .. tostring(rows[1] and rows[1].name))
    lurek.log.info("first reflected type = " .. tostring(rows[1] and rows[1].type))
end

--@api: LSchema:validate
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local s = lurek.docs.schema({name = {type = "string", required = true}})
    local ok, errors = s:validate({name = "test"})
    lurek.log.info("valid = " .. tostring(ok) .. " errors = " .. #errors)
    lurek.log.info("schema type = " .. s:type())
    lurek.log.info("field count = " .. #s:getFields())
end

--@api: LSchema:check
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local s = lurek.docs.schema({x = {type = "number"}})
    lurek.log.info("check = " .. tostring(s:check({x = 42})))
    lurek.log.info("schema name = " .. tostring(s:getName()))
    lurek.log.info("is schema = " .. tostring(s:typeOf("LSchema")))
    lurek.log.info("field count = " .. #s:getFields())
end

--@api: LSchema:assert
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local s = lurek.docs.schema({v = {type = "number"}})
    local ok = pcall(function() s["assert"](s, {v = 10}) end)
    lurek.log.info("assert passed = " .. tostring(ok))
    lurek.log.info("schema field count = " .. #s:getFields())
    lurek.log.info("schema type = " .. s:type())
end

--@api: LSchema:getName
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local s = lurek.docs.schema({}, "TestSchema")
    lurek.log.info("name = " .. s:getName())
    lurek.log.info("schema name = " .. tostring(s:getName()))
    lurek.log.info("field count = " .. #s:getFields())
    lurek.log.info("is schema = " .. tostring(s:typeOf("LSchema")))
end

--@api: LSchema:getFields
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local s = lurek.docs.schema({a = {type = "number"}, b = {type = "string"}})
    local fields = s:getFields()
    lurek.log.info("fields = " .. #fields)
    lurek.log.info("first field = " .. tostring(fields[1]))
    lurek.log.info("schema type = " .. s:type())
end

--@api: LSchema:type
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local s = lurek.docs.schema({})
    lurek.log.info("type = " .. s:type())
    lurek.log.info("schema fields = " .. tostring(#s:getFields()))
    lurek.log.info("typeOf LSchema = " .. tostring(s:typeOf("LSchema")))
    lurek.log.info("field count = " .. #s:getFields())
end

--@api: LSchema:typeOf
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local s = lurek.docs.schema({})
    lurek.log.info("is LSchema = " .. tostring(s:typeOf("LSchema")))
    lurek.log.info("type = " .. tostring(s:type()))
    lurek.log.info("first field = " .. tostring(s:getFields()[1]))
    lurek.log.info("field count = " .. #s:getFields())
end

--@api: LDocEntry:getName
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local entry = docs_example_entry
    lurek.log.info("name = " .. entry:getName())
    lurek.log.info("qualified chars = " .. #entry:getQualifiedName())
    lurek.log.info("qualified = " .. tostring(entry:getQualifiedName()))
    lurek.log.info("module = " .. tostring(entry:getModule()))
end

--@api: LDocEntry:getQualifiedName
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local entry = docs_example_entry
    lurek.log.info("qualified = " .. entry:getQualifiedName())
    lurek.log.info("qualified chars = " .. #entry:getQualifiedName())
    lurek.log.info("module = " .. tostring(entry:getModule()))
    lurek.log.info("kind = " .. tostring(entry:getKind()))
end

--@api: LDocEntry:getModule
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local entry = docs_example_entry
    lurek.log.info("module = " .. entry:getModule())
    lurek.log.info("qualified chars = " .. #entry:getQualifiedName())
    lurek.log.info("kind = " .. tostring(entry:getKind()))
    lurek.log.info("name = " .. tostring(entry:getName()))
end

--@api: LDocEntry:getKind
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local entry = docs_example_entry
    lurek.log.info("kind = " .. entry:getKind())
    lurek.log.info("qualified chars = " .. #entry:getQualifiedName())
    lurek.log.info("name = " .. tostring(entry:getName()))
    lurek.log.info("qualified = " .. tostring(entry:getQualifiedName()))
end

--@api: LDocEntry:getDescription
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local entry = docs_example_entry
    lurek.log.info("desc len = " .. #entry:getDescription())
    lurek.log.info("qualified chars = " .. #entry:getQualifiedName())
    lurek.log.info("has description = " .. tostring(entry:hasDescription()))
    lurek.log.info("name = " .. tostring(entry:getName()))
end

--@api: LDocEntry:getParameters
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local params = docs_example_entry:getParameters()
    lurek.log.info("params = " .. #params)
    lurek.log.info("params count = " .. tostring(#params))
    lurek.log.info("first param name = " .. tostring(params[1] and params[1].name))
    lurek.log.info("entry name = " .. tostring(docs_example_entry:getName()))
end

--@api: LDocEntry:getReturns
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local returns = docs_example_entry:getReturns()
    lurek.log.info("returns = " .. #returns)
    lurek.log.info("returns count = " .. tostring(#returns))
    lurek.log.info("first return type = " .. tostring(returns[1] and returns[1].type))
    lurek.log.info("entry name = " .. tostring(docs_example_entry:getName()))
end

--@api: LDocEntry:getExample
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local example = docs_example_entry:getExample()
    lurek.log.info("example = " .. type(example))
    lurek.log.info("example length = " .. tostring(example and #example or 0))
    lurek.log.info("has example = " .. tostring(docs_example_entry:hasExample()))
    lurek.log.info("entry kind = " .. tostring(docs_example_entry:getKind()))
end

--@api: LDocEntry:getSince
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local since = docs_example_entry:getSince()
    lurek.log.info("since = " .. type(since))
    lurek.log.info("since value = " .. tostring(since))
    lurek.log.info("entry name = " .. tostring(docs_example_entry:getName()))
    lurek.log.info("entry module = " .. tostring(docs_example_entry:getModule()))
end

--@api: LDocEntry:getDeprecated
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local deprecated = docs_example_entry:getDeprecated()
    lurek.log.info("deprecated = " .. type(deprecated))
    lurek.log.info("deprecated value = " .. tostring(deprecated))
    lurek.log.info("entry qualified = " .. tostring(docs_example_entry:getQualifiedName()))
    lurek.log.info("entry module = " .. tostring(docs_example_entry:getModule()))
end

--@api: LDocEntry:getScore
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local entry = docs_example_entry
    lurek.log.info("score = " .. entry:getScore())
    lurek.log.info("qualified chars = " .. #entry:getQualifiedName())
    lurek.log.info("module = " .. tostring(entry:getModule()))
    lurek.log.info("kind = " .. tostring(entry:getKind()))
end

--@api: LDocEntry:hasDescription
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local entry = docs_example_entry
    lurek.log.info("hasDesc = " .. tostring(entry:hasDescription()))
    lurek.log.info("qualified chars = " .. #entry:getQualifiedName())
    lurek.log.info("description length = " .. tostring(#entry:getDescription()))
    lurek.log.info("entry kind = " .. tostring(entry:getKind()))
end

--@api: LDocEntry:hasParameters
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local entry = docs_example_entry
    lurek.log.info("hasParams = " .. tostring(entry:hasParameters()))
    lurek.log.info("qualified chars = " .. #entry:getQualifiedName())
    lurek.log.info("param count = " .. tostring(#entry:getParameters()))
    lurek.log.info("entry name = " .. tostring(entry:getName()))
end

--@api: LDocEntry:hasReturnType
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local entry = docs_example_entry
    lurek.log.info("hasReturn = " .. tostring(entry:hasReturnType()))
    lurek.log.info("qualified chars = " .. #entry:getQualifiedName())
    lurek.log.info("return count = " .. tostring(#entry:getReturns()))
    lurek.log.info("entry name = " .. tostring(entry:getName()))
end

--@api: LDocEntry:hasExample
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local entry = docs_example_entry
    lurek.log.info("hasExample = " .. tostring(entry:hasExample()))
    lurek.log.info("qualified chars = " .. #entry:getQualifiedName())
    lurek.log.info("example text type = " .. type(entry:getExample()))
    lurek.log.info("entry qualified = " .. tostring(entry:getQualifiedName()))
end

--@api: LDocEntry:type
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local entry = docs_example_entry
    lurek.log.info("type = " .. entry:type())
    lurek.log.info("qualified chars = " .. #entry:getQualifiedName())
    lurek.log.info("typeOf LDocEntry = " .. tostring(entry:typeOf("LDocEntry")))
    lurek.log.info("entry module = " .. tostring(entry:getModule()))
end

--@api: LDocEntry:typeOf
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local entry = docs_example_entry
    lurek.log.info("is LDocEntry = " .. tostring(entry:typeOf("LDocEntry")))
    lurek.log.info("type = " .. tostring(entry:type()))
    lurek.log.info("entry module = " .. tostring(entry:getModule()))
    lurek.log.info("entry kind = " .. tostring(entry:getKind()))
end

--- Docs Module Part 2: LApiCatalog, LValidationReport, LQualityReport

--@api: LApiCatalog:getModules
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local modules = cat:getModules()
    lurek.log.info("modules = " .. #modules)
    lurek.log.info("first module = " .. tostring(modules[1]))
    lurek.log.info("catalog entries = " .. tostring(cat:entryCount()))
end

--@api: LApiCatalog:getEntries
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local all = cat:getEntries()
    local math_entries = cat:getEntries("math")
    lurek.log.info("all=" .. #all .. " math=" .. #math_entries)
    lurek.log.info("first global entry = " .. tostring(all[1] and all[1]:getQualifiedName()))
end

--@api: LApiCatalog:getEntry
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local entry = cat:getEntry("lurek.math.lerp")
    lurek.log.info("found entry = " .. tostring(entry ~= nil))
    lurek.log.info("catalog modules = " .. tostring(#cat:getModules()))
    lurek.log.info("entry kind = " .. tostring(entry and entry:getKind()))
end

--@api: LApiCatalog:getTypes
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local types = cat:getTypes("math")
    lurek.log.info("math types = " .. #types)
    lurek.log.info("first type = " .. tostring(types[1]))
    lurek.log.info("catalog entries = " .. tostring(cat:entryCount()))
end

--@api: LApiCatalog:getTypeMethods
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local methods = cat:getTypeMethods("LVec2")
    lurek.log.info("LVec2 methods = " .. #methods)
    lurek.log.info("first method = " .. tostring(methods[1] and methods[1]:getQualifiedName()))
    lurek.log.info("catalog entries = " .. tostring(cat:entryCount()))
end

--@api: LApiCatalog:entryCount
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local total = cat:entryCount()
    local math_count = cat:entryCount("math")
    lurek.log.info("total=" .. total .. " math=" .. math_count)
    lurek.log.info("module count = " .. #cat:getModules())
end

--@api: LApiCatalog:merge
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local a = lurek.docs.scanModule("math")
    local b = lurek.docs.scanModule("timer")
    local merged = a:merge(b)
    lurek.log.info("merged = " .. merged:entryCount())
    lurek.log.info("merged module count = " .. #merged:getModules())
end

--@api: LApiCatalog:filter
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local fns = cat:filter(function(entry) return entry:getKind() == "function" end)
    lurek.log.info("functions = " .. fns:entryCount())
    lurek.log.info("filtered type = " .. fns:type())
    lurek.log.info("first filtered entry = " .. tostring(fns:getEntries()[1] and fns:getEntries()[1]:getQualifiedName()))
end

--@api: LApiCatalog:search
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local results = cat:search("lerp")
    lurek.log.info("search results = " .. #results)
    lurek.log.info("first search hit = " .. tostring(results[1] and results[1]:getQualifiedName()))
    lurek.log.info("catalog entries = " .. tostring(cat:entryCount()))
end

--@api: LApiCatalog:toTable
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = lurek.docs.scanModule("math")
    local rows = cat:toTable()
    lurek.log.info("rows = " .. #rows)
    lurek.log.info("first row name = " .. tostring(rows[1] and rows[1].name))
    lurek.log.info("first row module = " .. tostring(rows[1] and rows[1].module))
end

--@api: LApiCatalog:toJSON
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = lurek.docs.scanModule("timer")
    local json = cat:toJSON()
    lurek.log.info("json length = " .. #json)
    lurek.log.info("json has timer = " .. tostring(string.find(json, "timer", 1, true) ~= nil))
    lurek.log.info("catalog entries = " .. tostring(cat:entryCount()))
end

--@api: LApiCatalog:type
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    lurek.log.info("type = " .. cat:type())
    lurek.log.info("catalog modules = " .. tostring(#cat:getModules()))
    lurek.log.info("typeOf LApiCatalog = " .. tostring(cat:typeOf("LApiCatalog")))
    lurek.log.info("module count = " .. tostring(#cat:getModules()))
end

--@api: LApiCatalog:typeOf
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    lurek.log.info("is LApiCatalog = " .. tostring(cat:typeOf("LApiCatalog")))
    lurek.log.info("type = " .. tostring(cat:type()))
    lurek.log.info("catalog entries = " .. tostring(cat:entryCount()))
    lurek.log.info("entry count = " .. tostring(cat:entryCount()))
end

--@api: LValidationReport:isValid
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = docs_example_validate
    lurek.log.info("valid = " .. tostring(report:isValid()))
    lurek.log.info("missing count = " .. tostring(report:missingCount()))
    lurek.log.info("report type = " .. report:type())
end

--@api: LValidationReport:getMissing
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = docs_example_validate
    local missing = report:getMissing()
    lurek.log.info("missing = " .. #missing)
    lurek.log.info("first missing = " .. tostring(missing[1] and missing[1].qualifiedName))
end

--@api: LValidationReport:getPhantom
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = docs_example_validate
    local phantom = report:getPhantom()
    lurek.log.info("phantom = " .. #phantom)
    lurek.log.info("first phantom = " .. tostring(phantom[1] and phantom[1].qualifiedName))
end

--@api: LValidationReport:getIncomplete
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = docs_example_validate
    local incomplete = report:getIncomplete()
    lurek.log.info("incomplete = " .. #incomplete)
    lurek.log.info("first incomplete = " .. tostring(incomplete[1] and incomplete[1].qualifiedName))
end

--@api: LValidationReport:getIssues
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = docs_example_validate
    local issues = report:getIssues()
    lurek.log.info("issues = " .. #issues)
    lurek.log.info("first issue severity = " .. tostring(issues[1] and issues[1].severity))
    lurek.log.info("first issue module = " .. tostring(issues[1] and issues[1].module))
end

--@api: LValidationReport:missingCount
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = docs_example_validate
    lurek.log.info("missing count = " .. report:missingCount())
    lurek.log.info("is valid = " .. tostring(report:isValid()))
    lurek.log.info("report type = " .. report:type())
end

--@api: LValidationReport:phantomCount
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = docs_example_validate
    lurek.log.info("phantom count = " .. report:phantomCount())
    lurek.log.info("missing count = " .. report:missingCount())
    lurek.log.info("report type = " .. report:type())
end

--@api: LValidationReport:incompleteCount
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = docs_example_validate
    lurek.log.info("incomplete count = " .. report:incompleteCount())
    lurek.log.info("phantom count = " .. report:phantomCount())
    lurek.log.info("report type = " .. report:type())
end

--@api: LValidationReport:issueCount
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = docs_example_validate
    local issues = report:getIssues()
    lurek.log.info("issue count = " .. report:issueCount())
    lurek.log.info("issues table size = " .. #issues)
    lurek.log.info("is valid = " .. tostring(report:isValid()))
end

--@api: LValidationReport:getSummary
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = docs_example_validate
    local summary = report:getSummary()
    lurek.log.info("summary = " .. summary)
    lurek.log.info("summary length = " .. #summary)
    lurek.log.info("report type = " .. report:type())
end

--@api: LValidationReport:toTable
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = docs_example_validate
    local t = report:toTable()
    lurek.log.info("table keys: missing=" .. #t.missing .. " phantom=" .. #t.phantom)
    lurek.log.info("incomplete=" .. #t.incomplete)
end

--@api: LValidationReport:toJSON
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = docs_example_validate
    local json = report:toJSON()
    lurek.log.info("json length = " .. #json)
    lurek.log.info("json has missing key = " .. tostring(string.find(json, "missing", 1, true) ~= nil))
end

--@api: LValidationReport:type
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = docs_example_validate
    lurek.log.info("type = " .. report:type())
    lurek.log.info("missing count = " .. tostring(report:missingCount()))
    lurek.log.info("typeOf LValidationReport = " .. tostring(report:typeOf("LValidationReport")))
end

--@api: LValidationReport:typeOf
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = docs_example_validate
    lurek.log.info("is report = " .. tostring(report:typeOf("LValidationReport")))
    lurek.log.info("type = " .. tostring(report:type()))
    lurek.log.info("valid = " .. tostring(report:isValid()))
end

--@api: LQualityReport:getOverallScore
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local qr = docs_example_quality
    lurek.log.info("score = " .. qr:getOverallScore())
    lurek.log.info("grade = " .. tostring(qr:getGrade()))
    lurek.log.info("type = " .. qr:type())
end

--@api: LQualityReport:getGrade
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local qr = docs_example_quality
    lurek.log.info("grade = " .. qr:getGrade())
    lurek.log.info("overall score = " .. tostring(qr:getOverallScore()))
    lurek.log.info("type = " .. qr:type())
end

--@api: LQualityReport:getModuleScores
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local qr = docs_example_quality
    local scores = qr:getModuleScores()
    lurek.log.info("module scores type = " .. type(scores))
    lurek.log.info("math score = " .. tostring(scores.math))
end

--@api: LQualityReport:getWorst
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local qr = docs_example_quality
    local worst = qr:getWorst(5)
    lurek.log.info("worst 5 = " .. #worst)
    lurek.log.info("first worst = " .. tostring(worst[1] and worst[1]:getQualifiedName()))
end

--@api: LQualityReport:getBest
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local qr = docs_example_quality
    local best = qr:getBest(5)
    lurek.log.info("best 5 = " .. #best)
    lurek.log.info("first best = " .. tostring(best[1] and best[1]:getQualifiedName()))
end

--@api: LQualityReport:getByGrade
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local qr = docs_example_quality
    local a_entries = qr:getByGrade("A")
    lurek.log.info("grade A entries = " .. #a_entries)
    lurek.log.info("first A entry = " .. tostring(a_entries[1] and a_entries[1]:getQualifiedName()))
end

--@api: LQualityReport:getIssues
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local qr = docs_example_quality
    local issues = qr:getIssues()
    lurek.log.info("quality issues = " .. #issues)
    lurek.log.info("first issue kind = " .. tostring(issues[1] and issues[1].kind))
    lurek.log.info("first issue message = " .. tostring(issues[1] and issues[1].message))
end

--@api: LQualityReport:issueCount
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local qr = docs_example_quality
    local issues = qr:getIssues()
    lurek.log.info("quality issue count = " .. qr:issueCount())
    lurek.log.info("issues table size = " .. #issues)
    lurek.log.info("quality grade = " .. tostring(qr:getGrade()))
end

--@api: LQualityReport:getSummary
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local qr = docs_example_quality
    local summary = qr:getSummary()
    lurek.log.info("summary = " .. summary)
    lurek.log.info("summary length = " .. #summary)
    lurek.log.info("type = " .. qr:type())
end

--@api: LQualityReport:toTable
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local qr = docs_example_quality
    local t = qr:toTable()
    lurek.log.info("overall = " .. t.overallScore .. " grade = " .. t.grade)
    lurek.log.info("module score count = " .. tostring(type(t.moduleScores)))
end

--@api: LQualityReport:toJSON
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local qr = docs_example_quality
    local json = qr:toJSON()
    lurek.log.info("json length = " .. #json)
    lurek.log.info("json has grade = " .. tostring(string.find(json, "grade", 1, true) ~= nil))
end

--@api: LQualityReport:type
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local qr = docs_example_quality
    lurek.log.info("type = " .. qr:type())
    lurek.log.info("summary length = " .. #qr:getSummary())
    lurek.log.info("typeOf LQualityReport = " .. tostring(qr:typeOf("LQualityReport")))
end

--@api: LQualityReport:typeOf
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local qr = docs_example_quality
    lurek.log.info("is report = " .. tostring(qr:typeOf("LQualityReport")))
    lurek.log.info("type = " .. tostring(qr:type()))
    lurek.log.info("grade = " .. tostring(qr:getGrade()))
end
