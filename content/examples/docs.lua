-- content/examples/docs.lua
-- Smoke-optimized docs examples with lightweight per-block setups.

--@api: lurek.docs.scan
do
    local cat = lurek.docs.scan({
        table = {
            start = function() end,
            state = "idle",
        },
        namespace = "game.quest",
        module = "quest",
    })
    local entry = cat:getEntry("game.quest.start")
    lurek.log.info("scanned entries = " .. cat:entryCount())
    lurek.log.info("custom entry = " .. tostring(entry and entry:getQualifiedName()))
    lurek.log.info("custom module = " .. tostring(entry and entry:getModule()))
end

--@api: lurek.docs.scanModule
do
    local cat = lurek.docs.scanModule("repl")
    local entries = cat:getEntries("repl")
    lurek.log.info("repl entries = " .. cat:entryCount())
    lurek.log.info("catalog type = " .. cat:type())
    lurek.log.info("first repl entry = " .. tostring(entries[1] and entries[1]:getQualifiedName()))
end

--@api: lurek.docs.loadToml
do
    local rel_path = "save/_docs_example_load_toml.toml"
    local abs_path = lurek.filesystem.getSaveDirectory() .. "/_docs_example_load_toml.toml"
    lurek.filesystem.write(rel_path, [=[[[entries]]
name = "play"
qualifiedName = "lurek.audio.play"
module = "audio"
kind = "function"
description = "Plays a sound"
]=])
    local cat = lurek.docs.loadToml(abs_path)
    local entry = cat:getEntry("lurek.audio.play")
    lurek.log.info("loaded entries = " .. cat:entryCount())
    lurek.log.info("loaded type = " .. cat:type())
    lurek.log.info("loaded qualified name = " .. tostring(entry and entry:getQualifiedName()))
end

--@api: lurek.docs.loadAll
do
local rel_dir = "save/_docs_example_load_all"
local abs_dir = lurek.filesystem.getSaveDirectory() .. "/_docs_example_load_all"
lurek.filesystem.createDirectory(rel_dir)
lurek.filesystem.write(rel_dir .. "/a.toml", [=[[[entries]]
name = "one"
qualifiedName = "lurek.test.one"
module = "test"
kind = "function"
description = "First entry"
]=])
lurek.filesystem.write(rel_dir .. "/b.toml", [=[[[entries]]
name = "two"
qualifiedName = "lurek.test.two"
module = "test"
kind = "function"
description = "Second entry"
]=])
local cat = lurek.docs.loadAll(abs_dir)
lurek.log.info("all entries = " .. cat:entryCount())
lurek.log.info("loadAll type = " .. cat:type())
lurek.log.info("has lurek.test.one = " .. tostring(cat:getEntry("lurek.test.one") ~= nil))
end

--@api: lurek.docs.describe
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.spawn", "Spawn a demo entity.")
    local entry = lurek.docs.getCatalog():getEntry("lurek.demo.spawn")
    lurek.log.info("description set")
    lurek.log.info("description length = " .. tostring(entry and #entry:getDescription() or 0))
    lurek.docs.resetCatalog()
end

--@api: lurek.docs.setParamInfo
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.blend", "Blend two demo values.")
    lurek.docs.setParamInfo("lurek.demo.blend", {
        { name = "t", type = "number", description = "Interpolation factor", optional = false },
    })
    local params = lurek.docs.getCatalog():getEntry("lurek.demo.blend"):getParameters()
    lurek.log.info("params set = " .. #params)
    lurek.log.info("first param name = " .. tostring(params[1] and params[1].name))
    lurek.docs.resetCatalog()
end

--@api: lurek.docs.setReturnInfo
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.blend", "Blend two demo values.")
    lurek.docs.setReturnInfo("lurek.demo.blend", {
        { type = "number", description = "Interpolated value" },
    })
    local returns = lurek.docs.getCatalog():getEntry("lurek.demo.blend"):getReturns()
    lurek.log.info("returns set = " .. #returns)
    lurek.log.info("first return type = " .. tostring(returns[1] and returns[1].type))
    lurek.docs.resetCatalog()
end

--@api: lurek.docs.getCatalog
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.catalog", "Catalog example entry.")
    local cat = lurek.docs.getCatalog()
    local modules = cat:getModules()
    lurek.log.info("catalog entries = " .. cat:entryCount())
    lurek.log.info("catalog userdata type = " .. cat:type())
    lurek.log.info("module count = " .. #modules)
    lurek.docs.resetCatalog()
end

--@api: lurek.docs.resetCatalog
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.temp", "Temporary entry")
    lurek.docs.resetCatalog()
    local cat = lurek.docs.getCatalog()
    lurek.log.info("after reset entries = " .. cat:entryCount())
    lurek.log.info("after reset type = " .. cat:type())
end

--@api: lurek.docs.validate
do
    local cat = lurek.docs.scan({
        table = { fake = function() end },
        namespace = "lurek.repl",
        module = "repl",
    })
    local report = lurek.docs.validate(cat)
    lurek.log.info("valid = " .. tostring(report:isValid()))
    lurek.log.info("missing count = " .. tostring(report:missingCount()))
    lurek.log.info("report type = " .. report:type())
end

--@api: lurek.docs.validateModule
do
    local cat = lurek.docs.scan({
        table = { fake = function() end },
        namespace = "lurek.repl",
        module = "repl",
    })
    local report = lurek.docs.validateModule("repl", cat)
    lurek.log.info("repl missing = " .. report:missingCount())
    lurek.log.info("repl phantom = " .. report:phantomCount())
    lurek.log.info("report type = " .. report:type())
end

--@api: lurek.docs.checkStaleness
do
    local cat = lurek.docs.scanModule("repl")
    local result = lurek.docs.checkStaleness(cat, "src")
    lurek.log.info("stale = " .. #result.stale .. " current = " .. #result.current)
    lurek.log.info("missing = " .. #result.missing)
    lurek.log.info("first current path = " .. tostring(result.current[1]))
end

--@api: lurek.docs.quality
do
    local cat = lurek.docs.scan({
        table = { spawn = function() end },
        namespace = "demo.batch",
        module = "demo.batch",
    })
    local qr = lurek.docs.quality(cat)
    lurek.log.info("quality score = " .. qr:getOverallScore())
    lurek.log.info("quality grade = " .. tostring(qr:getGrade()))
    lurek.log.info("report type = " .. qr:type())
end

--@api: lurek.docs.qualityModule
do
    local cat = lurek.docs.scan({
        table = { spawn = function() end },
        namespace = "demo.batch",
        module = "demo.batch",
    })
    local qr = lurek.docs.qualityModule("demo.batch", cat)
    lurek.log.info("module quality = " .. qr:getOverallScore())
    lurek.log.info("module grade = " .. tostring(qr:getGrade()))
    lurek.log.info("report type = " .. qr:type())
end

--@api: lurek.docs.coverage
do
    local cat = lurek.docs.scan({
        table = { fake = function() end },
        namespace = "lurek.repl",
        module = "repl",
    })
    local documented, live = lurek.docs.coverage(cat)
    lurek.log.info("documented=" .. documented .. " live=" .. live)
    lurek.log.info("coverage gap=" .. tostring(live - documented))
    lurek.log.info("catalog entries=" .. cat:entryCount())
end

--@api: lurek.docs.coverageModule
do
    local cat = lurek.docs.scan({
        table = { fake = function() end },
        namespace = "lurek.repl",
        module = "repl",
    })
    local documented, live = lurek.docs.coverageModule("repl", cat)
    lurek.log.info("repl documented=" .. documented .. " live=" .. live)
    lurek.log.info("repl coverage gap=" .. tostring(live - documented))
    lurek.log.info("repl entry count=" .. cat:entryCount())
end

--@api: lurek.docs.exportCompletions
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("game.quest.start", "Start a quest step.")
    lurek.docs.setParamInfo("game.quest.start", {
        { name = "value", type = "number", description = "Quest stage", optional = false },
    })
    lurek.docs.setReturnInfo("game.quest.start", {
        { type = "boolean", description = "True when the step can begin" },
    })
    local cat = lurek.docs.getCatalog()
    local rel_path = "save/_docs_example_completions.json"
    local abs_path = lurek.filesystem.getSaveDirectory() .. "/_docs_example_completions.json"
    lurek.docs.exportCompletions(cat, abs_path)
    local payload = lurek.filesystem.read(rel_path)
    lurek.log.info("completions exported = " .. tostring(string.find(payload, "game.quest.start", 1, true) ~= nil))
    lurek.docs.resetCatalog()
end

--@api: lurek.docs.exportHover
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("game.quest.hover", "Hover text for a quest action.")
    lurek.docs.setParamInfo("game.quest.hover", {
        { name = "value", type = "string", description = "Quest id", optional = false },
    })
    lurek.docs.setReturnInfo("game.quest.hover", {
        { type = "string", description = "Rendered hover text" },
    })
    local cat = lurek.docs.getCatalog()
    local rel_path = "save/_docs_example_hover.json"
    local abs_path = lurek.filesystem.getSaveDirectory() .. "/_docs_example_hover.json"
    lurek.docs.exportHover(cat, abs_path)
    local payload = lurek.filesystem.read(rel_path)
    lurek.log.info("hover exported = " .. tostring(string.find(payload, "game.quest.hover", 1, true) ~= nil))
    lurek.docs.resetCatalog()
end

--@api: lurek.docs.exportSignatures
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("game.quest.signature", "Signature payload for a quest action.")
    lurek.docs.setParamInfo("game.quest.signature", {
        { name = "value", type = "number", description = "Quest stage", optional = false },
    })
    local cat = lurek.docs.getCatalog()
    local rel_path = "save/_docs_example_signatures.json"
    local abs_path = lurek.filesystem.getSaveDirectory() .. "/_docs_example_signatures.json"
    lurek.docs.exportSignatures(cat, abs_path)
    local payload = lurek.filesystem.read(rel_path)
    lurek.log.info("signatures exported = " .. tostring(string.find(payload, "game.quest.signature", 1, true) ~= nil))
    lurek.docs.resetCatalog()
end

--@api: lurek.docs.exportAll
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.test.exportAll", "Export all entry")
    local cat = lurek.docs.getCatalog()
    local rel_dir = "save/_docs_example_export_all"
    local abs_dir = lurek.filesystem.getSaveDirectory() .. "/_docs_example_export_all"
    lurek.docs.exportAll(cat, abs_dir)
    lurek.log.info("all docs exported")
    lurek.log.info("has completions = " .. tostring(lurek.filesystem.exists(rel_dir .. "/completions.json")))
    lurek.log.info("has hover = " .. tostring(lurek.filesystem.exists(rel_dir .. "/hover.json")))
    lurek.docs.resetCatalog()
end

--@api: lurek.docs.exportMarkdown
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.test.exportMarkdown", "Markdown entry")
    local cat = lurek.docs.getCatalog()
    local rel_path = "save/_docs_example_api.md"
    local abs_path = lurek.filesystem.getSaveDirectory() .. "/_docs_example_api.md"
    lurek.docs.exportMarkdown(cat, abs_path)
    local payload = lurek.filesystem.read(rel_path)
    lurek.log.info("markdown exported")
    lurek.log.info("has heading = " .. tostring(string.find(payload, "# API Reference", 1, true) ~= nil))
    lurek.docs.resetCatalog()
end

--@api: lurek.docs.exportCheatsheet
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.test.exportCheatsheet", "Cheatsheet entry")
    local cat = lurek.docs.getCatalog()
    local rel_path = "save/_docs_example_cheatsheet.txt"
    local abs_path = lurek.filesystem.getSaveDirectory() .. "/_docs_example_cheatsheet.txt"
    lurek.docs.exportCheatsheet(cat, abs_path)
    local payload = lurek.filesystem.read(rel_path)
    lurek.log.info("cheatsheet exported")
    lurek.log.info("has signature = " .. tostring(string.find(payload, "lurek.test.exportCheatsheet", 1, true) ~= nil))
    lurek.docs.resetCatalog()
end

--@api: lurek.docs.schema
do
    local schema = lurek.docs.schema({
        name = { type = "string", required = true },
        age = { type = "number" },
    }, "PlayerSchema")
    local fields = schema:getFields()
    lurek.log.info("schema name = " .. schema:getName())
    lurek.log.info("schema type = " .. schema:type())
    lurek.log.info("field count = " .. #fields)
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
    local schema = lurek.docs.schemaFromToml(toml)
    lurek.log.info("schema from toml, name = " .. schema:getName())
    lurek.log.info("schema field count = " .. #schema:getFields())
    lurek.log.info("schema type = " .. schema:type())
end

--@api: lurek.docs.reflectLive
do
    local data = lurek.docs.reflectLive("repl")
    local rows = data.repl or {}
    lurek.log.info("reflect repl type = " .. type(data))
    lurek.log.info("reflected rows = " .. #rows)
    lurek.log.info("first reflected name = " .. tostring(rows[1] and rows[1].name))
end

--@api: lurek.docs.reflectTable
do
    local rows = lurek.docs.reflectTable({ foo = 1, bar = "hello" }, "game.quest")
    lurek.log.info("reflected rows = " .. #rows)
    lurek.log.info("first reflected name = " .. tostring(rows[1] and rows[1].name))
    lurek.log.info("first reflected qualified name = " .. tostring(rows[1] and rows[1].qualifiedName))
    lurek.log.info("first reflected type = " .. tostring(rows[1] and rows[1].type))
end

--@api: LSchema:validate
do
    local schema = lurek.docs.schema({ name = { type = "string", required = true } }, "ValidateSchema")
    local ok, errors = schema:validate({ name = "test" })
    lurek.log.info("valid = " .. tostring(ok) .. " errors = " .. #errors)
    lurek.log.info("schema type = " .. schema:type())
    lurek.log.info("field count = " .. #schema:getFields())
end

--@api: LSchema:check
do
    local schema = lurek.docs.schema({ x = { type = "number" } }, "CheckSchema")
    lurek.log.info("check = " .. tostring(schema:check({ x = 42 })))
    lurek.log.info("schema name = " .. tostring(schema:getName()))
    lurek.log.info("is schema = " .. tostring(schema:typeOf("LSchema")))
    lurek.log.info("field count = " .. #schema:getFields())
end

--@api: LSchema:assert
do
    local schema = lurek.docs.schema({ v = { type = "number" } }, "AssertSchema")
    local ok = pcall(function() schema["assert"](schema, { v = 10 }) end)
    lurek.log.info("assert passed = " .. tostring(ok))
    lurek.log.info("schema field count = " .. #schema:getFields())
    lurek.log.info("schema type = " .. schema:type())
end

--@api: LSchema:getName
do
    local schema = lurek.docs.schema({ hp = "number" }, "HeroSchema")
    lurek.log.info("schema name = " .. schema:getName())
    lurek.log.info("schema type = " .. schema:type())
    lurek.log.info("is schema = " .. tostring(schema:typeOf("LSchema")))
    lurek.log.info("field count = " .. #schema:getFields())
end

--@api: LSchema:getFields
do
    local schema = lurek.docs.schema({ zeta = "string", alpha = { type = "number", required = true } }, "FieldSchema")
    local fields = schema:getFields()
    lurek.log.info("field count = " .. #fields)
    lurek.log.info("first field = " .. tostring(fields[1]))
    lurek.log.info("second field = " .. tostring(fields[2]))
end

--@api: LSchema:type
do
    local schema = lurek.docs.schema({ hp = "number" }, "TypeSchema")
    lurek.log.info("schema type = " .. schema:type())
    lurek.log.info("schema name = " .. schema:getName())
    lurek.log.info("field count = " .. #schema:getFields())
    lurek.log.info("is schema = " .. tostring(schema:typeOf("LSchema")))
end

--@api: LSchema:typeOf
do
    local schema = lurek.docs.schema({ hp = "number" }, "TypeOfSchema")
    lurek.log.info("is schema = " .. tostring(schema:typeOf("LSchema")))
    lurek.log.info("is entry = " .. tostring(schema:typeOf("LDocEntry")))
    lurek.log.info("schema type = " .. schema:type())
    lurek.log.info("schema name = " .. schema:getName())
end

--@api: LDocEntry:getName
do
    local cat = lurek.docs.scan({
        table = { spawn = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    local entry = cat:getEntry("lurek.demo.spawn")
    lurek.log.info("entry name = " .. tostring(entry and entry:getName()))
    lurek.log.info("entry type = " .. tostring(entry and entry:type()))
    lurek.log.info("entry module = " .. tostring(entry and entry:getModule()))
end

--@api: LDocEntry:getQualifiedName
do
    local cat = lurek.docs.scan({
        table = { spawn = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    local entry = cat:getEntry("lurek.demo.spawn")
    lurek.log.info("qualified name = " .. tostring(entry and entry:getQualifiedName()))
    lurek.log.info("entry name = " .. tostring(entry and entry:getName()))
    lurek.log.info("entry module = " .. tostring(entry and entry:getModule()))
end

--@api: LDocEntry:getModule
do
    local cat = lurek.docs.scan({
        table = { spawn = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    local entry = cat:getEntry("lurek.demo.spawn")
    lurek.log.info("entry module = " .. tostring(entry and entry:getModule()))
    lurek.log.info("entry kind = " .. tostring(entry and entry:getKind()))
    lurek.log.info("entry type = " .. tostring(entry and entry:type()))
end

--@api: LDocEntry:getKind
do
    local cat = lurek.docs.scan({
        table = { spawn = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    local entry = cat:getEntry("lurek.demo.spawn")
    lurek.log.info("entry kind = " .. tostring(entry and entry:getKind()))
    lurek.log.info("entry name = " .. tostring(entry and entry:getName()))
    lurek.log.info("entry type = " .. tostring(entry and entry:type()))
end

--@api: LDocEntry:getDescription
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.spawn", "Spawn demo entity")
    local entry = lurek.docs.getCatalog():getEntry("lurek.demo.spawn")
    lurek.log.info("description = " .. tostring(entry and entry:getDescription()))
    lurek.log.info("has description = " .. tostring(entry and entry:hasDescription()))
    lurek.docs.resetCatalog()
end

--@api: LDocEntry:getParameters
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.spawn", "Spawn demo entity")
    lurek.docs.setParamInfo("lurek.demo.spawn", {
        { name = "value", type = "number", description = "Spawn count", optional = false },
    })
    local params = lurek.docs.getCatalog():getEntry("lurek.demo.spawn"):getParameters()
    lurek.log.info("param count = " .. #params)
    lurek.log.info("first param = " .. tostring(params[1] and params[1].name))
    lurek.docs.resetCatalog()
end

--@api: LDocEntry:getReturns
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.spawn", "Spawn demo entity")
    lurek.docs.setReturnInfo("lurek.demo.spawn", {
        { type = "boolean", description = "True when spawned" },
    })
    local returns = lurek.docs.getCatalog():getEntry("lurek.demo.spawn"):getReturns()
    lurek.log.info("return count = " .. #returns)
    lurek.log.info("first return = " .. tostring(returns[1] and returns[1].type))
    lurek.docs.resetCatalog()
end

--@api: LDocEntry:getExample
do
    local rel_path = "save/_docs_entry_meta.toml"
    local abs_path = lurek.filesystem.getSaveDirectory() .. "/_docs_entry_meta.toml"
    lurek.filesystem.write(rel_path, [=[[[entries]]
name = "spawn"
qualifiedName = "lurek.demo.spawn"
module = "demo"
kind = "function"
description = "Spawn demo entity"
example = "lurek.demo.spawn()"
since = "0.1.0"
deprecated = "use lurek.demo.spawnEx"
]=])
    local entry = lurek.docs.loadToml(abs_path):getEntry("lurek.demo.spawn")
    lurek.log.info("entry example = " .. tostring(entry and entry:getExample()))
    lurek.log.info("entry since = " .. tostring(entry and entry:getSince()))
    lurek.log.info("entry deprecated = " .. tostring(entry and entry:getDeprecated()))
end

--@api: LDocEntry:getSince
do
    local rel_path = "save/_docs_entry_since.toml"
    local abs_path = lurek.filesystem.getSaveDirectory() .. "/_docs_entry_since.toml"
    lurek.filesystem.write(rel_path, [=[[[entries]]
name = "spawn"
qualifiedName = "lurek.demo.spawn"
module = "demo"
kind = "function"
description = "Spawn demo entity"
example = "lurek.demo.spawn()"
since = "0.1.0"
deprecated = "use lurek.demo.spawnEx"
]=])
    local entry = lurek.docs.loadToml(abs_path):getEntry("lurek.demo.spawn")
    lurek.log.info("entry since = " .. tostring(entry and entry:getSince()))
    lurek.log.info("entry example = " .. tostring(entry and entry:getExample()))
    lurek.log.info("entry deprecated = " .. tostring(entry and entry:getDeprecated()))
end

--@api: LDocEntry:getDeprecated
do
    local rel_path = "save/_docs_entry_deprecated.toml"
    local abs_path = lurek.filesystem.getSaveDirectory() .. "/_docs_entry_deprecated.toml"
    lurek.filesystem.write(rel_path, [=[[[entries]]
name = "spawn"
qualifiedName = "lurek.demo.spawn"
module = "demo"
kind = "function"
description = "Spawn demo entity"
example = "lurek.demo.spawn()"
since = "0.1.0"
deprecated = "use lurek.demo.spawnEx"
]=])
    local entry = lurek.docs.loadToml(abs_path):getEntry("lurek.demo.spawn")
    lurek.log.info("entry deprecated = " .. tostring(entry and entry:getDeprecated()))
    lurek.log.info("entry example = " .. tostring(entry and entry:getExample()))
    lurek.log.info("entry since = " .. tostring(entry and entry:getSince()))
end

--@api: LDocEntry:getScore
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.scored", "Has description")
    local entry = lurek.docs.getCatalog():getEntry("lurek.demo.scored")
    lurek.log.info("entry score = " .. tostring(entry and entry:getScore()))
    lurek.log.info("has description = " .. tostring(entry and entry:hasDescription()))
    lurek.docs.resetCatalog()
end

--@api: LDocEntry:hasDescription
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.described", "Described entry")
    local entry = lurek.docs.getCatalog():getEntry("lurek.demo.described")
    lurek.log.info("has description = " .. tostring(entry and entry:hasDescription()))
    lurek.log.info("description = " .. tostring(entry and entry:getDescription()))
    lurek.docs.resetCatalog()
end

--@api: LDocEntry:hasParameters
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.params", "Entry with params")
    lurek.docs.setParamInfo("lurek.demo.params", {
        { name = "value", type = "number", description = "Input value", optional = false },
    })
    local entry = lurek.docs.getCatalog():getEntry("lurek.demo.params")
    lurek.log.info("has parameters = " .. tostring(entry and entry:hasParameters()))
    lurek.log.info("param count = " .. tostring(entry and #entry:getParameters() or 0))
    lurek.docs.resetCatalog()
end

--@api: LDocEntry:hasReturnType
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.returns", "Entry with returns")
    lurek.docs.setReturnInfo("lurek.demo.returns", {
        { type = "boolean", description = "True when complete" },
    })
    local entry = lurek.docs.getCatalog():getEntry("lurek.demo.returns")
    lurek.log.info("has return type = " .. tostring(entry and entry:hasReturnType()))
    lurek.log.info("return count = " .. tostring(entry and #entry:getReturns() or 0))
    lurek.docs.resetCatalog()
end

--@api: LDocEntry:hasExample
do
    local rel_path = "save/_docs_entry_has_example.toml"
    local abs_path = lurek.filesystem.getSaveDirectory() .. "/_docs_entry_has_example.toml"
    lurek.filesystem.write(rel_path, [=[[[entries]]
name = "spawn"
qualifiedName = "lurek.demo.spawn"
module = "demo"
kind = "function"
description = "Spawn demo entity"
example = "lurek.demo.spawn()"
]=])
    local entry = lurek.docs.loadToml(abs_path):getEntry("lurek.demo.spawn")
    lurek.log.info("has example = " .. tostring(entry and entry:hasExample()))
    lurek.log.info("example text = " .. tostring(entry and entry:getExample()))
end

--@api: LDocEntry:type
do
    local cat = lurek.docs.scan({
        table = { spawn = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    local entry = cat:getEntry("lurek.demo.spawn")
    lurek.log.info("entry type = " .. tostring(entry and entry:type()))
    lurek.log.info("entry kind = " .. tostring(entry and entry:getKind()))
    lurek.log.info("entry name = " .. tostring(entry and entry:getName()))
end

--@api: LDocEntry:typeOf
do
    local cat = lurek.docs.scan({
        table = { spawn = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    local entry = cat:getEntry("lurek.demo.spawn")
    lurek.log.info("is entry = " .. tostring(entry and entry:typeOf("LDocEntry")))
    lurek.log.info("is catalog = " .. tostring(entry and entry:typeOf("LApiCatalog")))
    lurek.log.info("entry type = " .. tostring(entry and entry:type()))
end

--@api: LApiCatalog:getModules
do
    local cat = lurek.docs.scan({
        table = { spawn = function() end, stop = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    local modules = cat:getModules()
    lurek.log.info("module count = " .. #modules)
    lurek.log.info("first module = " .. tostring(modules[1]))
    lurek.log.info("catalog entries = " .. cat:entryCount())
end

--@api: LApiCatalog:getEntries
do
    local cat = lurek.docs.scan({
        table = { spawn = function() end, stop = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    local entries = cat:getEntries()
    lurek.log.info("entries count = " .. #entries)
    lurek.log.info("first entry = " .. tostring(entries[1] and entries[1]:getQualifiedName()))
    lurek.log.info("catalog type = " .. cat:type())
end

--@api: LApiCatalog:getEntry
do
    local cat = lurek.docs.scan({
        table = { spawn = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    local entry = cat:getEntry("lurek.demo.spawn")
    lurek.log.info("entry exists = " .. tostring(entry ~= nil))
    lurek.log.info("entry name = " .. tostring(entry and entry:getName()))
    lurek.log.info("entry module = " .. tostring(entry and entry:getModule()))
end

--@api: LApiCatalog:getTypes
do
local rel_path = "save/_docs_catalog_types.toml"
local abs_path = lurek.filesystem.getSaveDirectory() .. "/_docs_catalog_types.toml"
lurek.filesystem.write(rel_path, [=[[[entries]]
name = "spawn"
qualifiedName = "lurek.demo.spawn"
module = "demo"
kind = "function"
description = "Spawn demo entity"

[[entries]]
name = "Thing"
qualifiedName = "lurek.demo.Thing"
module = "demo"
kind = "type"
description = "Demo type"

[[entries]]
name = "tick"
qualifiedName = "lurek.demo.Thing:tick"
module = "demo"
kind = "method"
description = "Tick method"
]=])
local types = lurek.docs.loadToml(abs_path):getTypes("demo")
lurek.log.info("type count = " .. #types)
lurek.log.info("first type = " .. tostring(types[1]))
lurek.log.info("second type = " .. tostring(types[2]))
end

--@api: LApiCatalog:getTypeMethods
do
local rel_path = "save/_docs_catalog_type_methods.toml"
local abs_path = lurek.filesystem.getSaveDirectory() .. "/_docs_catalog_type_methods.toml"
lurek.filesystem.write(rel_path, [=[[[entries]]
name = "Thing"
qualifiedName = "lurek.demo.Thing"
module = "demo"
kind = "type"
description = "Demo type"

[[entries]]
name = "tick"
qualifiedName = "lurek.demo.Thing:tick"
module = "demo"
kind = "method"
description = "Tick method"
]=])
local cat = lurek.docs.loadToml(abs_path)
end

--@api: LApiCatalog:entryCount
do
    local cat = lurek.docs.scan({
        table = { spawn = function() end, stop = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    lurek.log.info("entry count = " .. cat:entryCount())
    lurek.log.info("module count = " .. #cat:getModules())
    lurek.log.info("catalog type = " .. cat:type())
end

--@api: LApiCatalog:merge
do
    local a = lurek.docs.scan({ table = { spawn = function() end }, namespace = "lurek.demo", module = "demo" })
    local b = lurek.docs.scan({ table = { tick = function() end }, namespace = "lurek.timer", module = "timer" })
    local merged = a:merge(b)
    lurek.log.info("merged entries = " .. merged:entryCount())
    lurek.log.info("merged module count = " .. #merged:getModules())
    lurek.log.info("first merged entry = " .. tostring(merged:getEntries()[1] and merged:getEntries()[1]:getQualifiedName()))
end

--@api: LApiCatalog:filter
do
    local cat = lurek.docs.scan({
        table = { spawn = function() end, stop = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    local filtered = cat:filter(function(entry)
        return entry:getName() == "spawn"
    end)
    lurek.log.info("filtered entries = " .. filtered:entryCount())
    lurek.log.info("first filtered entry = " .. tostring(filtered:getEntries()[1] and filtered:getEntries()[1]:getQualifiedName()))
end

--@api: LApiCatalog:search
do
    local cat = lurek.docs.scan({
        table = { spawn = function() end, stop = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    local results = cat:search("spawn")
    lurek.log.info("search results = " .. #results)
    lurek.log.info("first result = " .. tostring(results[1] and results[1]:getQualifiedName()))
    lurek.log.info("catalog entries = " .. cat:entryCount())
end

--@api: LApiCatalog:toTable
do
    local cat = lurek.docs.scan({
        table = { spawn = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    local rows = cat:toTable()
    lurek.log.info("row count = " .. #rows)
    lurek.log.info("first row name = " .. tostring(rows[1] and rows[1].name))
    lurek.log.info("first row module = " .. tostring(rows[1] and rows[1].module))
end

--@api: LApiCatalog:toJSON
do
    local cat = lurek.docs.scan({
        table = { spawn = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    local json = cat:toJSON()
    lurek.log.info("json length = " .. #json)
    lurek.log.info("json has spawn = " .. tostring(string.find(json, "spawn", 1, true) ~= nil))
    lurek.log.info("catalog entries = " .. cat:entryCount())
end

--@api: LApiCatalog:type
do
    local cat = lurek.docs.scan({
        table = { spawn = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    lurek.log.info("catalog type = " .. cat:type())
    lurek.log.info("catalog modules = " .. tostring(#cat:getModules()))
    lurek.log.info("is catalog = " .. tostring(cat:typeOf("LApiCatalog")))
end

--@api: LApiCatalog:typeOf
do
    local cat = lurek.docs.scan({
        table = { spawn = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    lurek.log.info("is catalog = " .. tostring(cat:typeOf("LApiCatalog")))
    lurek.log.info("is entry = " .. tostring(cat:typeOf("LDocEntry")))
    lurek.log.info("catalog type = " .. tostring(cat:type()))
end

--@api: LValidationReport:isValid
do
    local cat = lurek.docs.scan({ table = { fake = function() end }, namespace = "lurek.repl", module = "repl" })
    local report = lurek.docs.validateModule("repl", cat)
    lurek.log.info("is valid = " .. tostring(report:isValid()))
    lurek.log.info("missing count = " .. tostring(report:missingCount()))
    lurek.log.info("report type = " .. report:type())
end

--@api: LValidationReport:getMissing
do
    local cat = lurek.docs.scan({ table = { fake = function() end }, namespace = "lurek.repl", module = "repl" })
    local report = lurek.docs.validateModule("repl", cat)
    local missing = report:getMissing()
    lurek.log.info("missing entries = " .. #missing)
    lurek.log.info("first missing = " .. tostring(missing[1] and missing[1].qualifiedName))
    lurek.log.info("report valid = " .. tostring(report:isValid()))
end

--@api: LValidationReport:getPhantom
do
    local cat = lurek.docs.scan({ table = { fake = function() end }, namespace = "lurek.repl", module = "repl" })
    local report = lurek.docs.validateModule("repl", cat)
    local phantom = report:getPhantom()
    lurek.log.info("phantom entries = " .. #phantom)
    lurek.log.info("first phantom = " .. tostring(phantom[1] and phantom[1].qualifiedName))
    lurek.log.info("report type = " .. report:type())
end

--@api: LValidationReport:getIncomplete
do
    local cat = lurek.docs.scan({ table = { fake = function() end }, namespace = "lurek.repl", module = "repl" })
    local report = lurek.docs.validateModule("repl", cat)
    local incomplete = report:getIncomplete()
    lurek.log.info("incomplete entries = " .. #incomplete)
    lurek.log.info("first incomplete = " .. tostring(incomplete[1] and incomplete[1].qualifiedName))
    lurek.log.info("report type = " .. report:type())
end

--@api: LValidationReport:getIssues
do
    local cat = lurek.docs.scan({ table = { fake = function() end }, namespace = "lurek.repl", module = "repl" })
    local report = lurek.docs.validateModule("repl", cat)
    local issues = report:getIssues()
    lurek.log.info("issues = " .. #issues)
    lurek.log.info("first issue severity = " .. tostring(issues[1] and issues[1].severity))
    lurek.log.info("first issue module = " .. tostring(issues[1] and issues[1].module))
end

--@api: LValidationReport:missingCount
do
    local cat = lurek.docs.scan({ table = { fake = function() end }, namespace = "lurek.repl", module = "repl" })
    local report = lurek.docs.validateModule("repl", cat)
    lurek.log.info("missing count = " .. report:missingCount())
    lurek.log.info("is valid = " .. tostring(report:isValid()))
    lurek.log.info("report type = " .. report:type())
end

--@api: LValidationReport:phantomCount
do
    local cat = lurek.docs.scan({ table = { fake = function() end }, namespace = "lurek.repl", module = "repl" })
    local report = lurek.docs.validateModule("repl", cat)
    lurek.log.info("phantom count = " .. report:phantomCount())
    lurek.log.info("missing count = " .. report:missingCount())
    lurek.log.info("report type = " .. report:type())
end

--@api: LValidationReport:incompleteCount
do
    local cat = lurek.docs.scan({ table = { fake = function() end }, namespace = "lurek.repl", module = "repl" })
    local report = lurek.docs.validateModule("repl", cat)
    lurek.log.info("incomplete count = " .. report:incompleteCount())
    lurek.log.info("phantom count = " .. report:phantomCount())
    lurek.log.info("report type = " .. report:type())
end

--@api: LValidationReport:issueCount
do
    local cat = lurek.docs.scan({ table = { fake = function() end }, namespace = "lurek.repl", module = "repl" })
    local report = lurek.docs.validateModule("repl", cat)
    local issues = report:getIssues()
    lurek.log.info("issue count = " .. report:issueCount())
    lurek.log.info("issues table size = " .. #issues)
    lurek.log.info("is valid = " .. tostring(report:isValid()))
end

--@api: LValidationReport:getSummary
do
    local cat = lurek.docs.scan({ table = { fake = function() end }, namespace = "lurek.repl", module = "repl" })
    local report = lurek.docs.validateModule("repl", cat)
    local summary = report:getSummary()
    lurek.log.info("summary = " .. summary)
    lurek.log.info("summary length = " .. #summary)
    lurek.log.info("report type = " .. report:type())
end

--@api: LValidationReport:toTable
do
    local cat = lurek.docs.scan({ table = { fake = function() end }, namespace = "lurek.repl", module = "repl" })
    local report = lurek.docs.validateModule("repl", cat)
    local t = report:toTable()
    lurek.log.info("table keys: missing=" .. #t.missing .. " phantom=" .. #t.phantom)
    lurek.log.info("incomplete=" .. #t.incomplete)
    lurek.log.info("report type = " .. report:type())
end

--@api: LValidationReport:toJSON
do
    local cat = lurek.docs.scan({ table = { fake = function() end }, namespace = "lurek.repl", module = "repl" })
    local report = lurek.docs.validateModule("repl", cat)
    local json = report:toJSON()
    lurek.log.info("json length = " .. #json)
    lurek.log.info("json has missing key = " .. tostring(string.find(json, "missing", 1, true) ~= nil))
    lurek.log.info("report type = " .. report:type())
end

--@api: LValidationReport:type
do
    local cat = lurek.docs.scan({ table = { fake = function() end }, namespace = "lurek.repl", module = "repl" })
    local report = lurek.docs.validateModule("repl", cat)
    lurek.log.info("report type = " .. report:type())
    lurek.log.info("missing count = " .. tostring(report:missingCount()))
    lurek.log.info("is validation report = " .. tostring(report:typeOf("LValidationReport")))
end

--@api: LValidationReport:typeOf
do
    local cat = lurek.docs.scan({ table = { fake = function() end }, namespace = "lurek.repl", module = "repl" })
    local report = lurek.docs.validateModule("repl", cat)
    lurek.log.info("is validation report = " .. tostring(report:typeOf("LValidationReport")))
    lurek.log.info("is quality report = " .. tostring(report:typeOf("LQualityReport")))
    lurek.log.info("report type = " .. tostring(report:type()))
end

--@api: LQualityReport:getOverallScore
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.alpha", "Alpha entry")
    local qr = lurek.docs.quality(lurek.docs.getCatalog())
    lurek.log.info("score = " .. qr:getOverallScore())
    lurek.log.info("grade = " .. tostring(qr:getGrade()))
    lurek.docs.resetCatalog()
end

--@api: LQualityReport:getGrade
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.alpha", "Alpha entry")
    local qr = lurek.docs.quality(lurek.docs.getCatalog())
    lurek.log.info("grade = " .. qr:getGrade())
    lurek.log.info("overall score = " .. tostring(qr:getOverallScore()))
    lurek.docs.resetCatalog()
end

--@api: LQualityReport:getModuleScores
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.alpha", "Alpha entry")
    local qr = lurek.docs.quality(lurek.docs.getCatalog())
    local scores = qr:getModuleScores()
    lurek.log.info("module scores type = " .. type(scores))
    lurek.log.info("module score count = " .. tostring(type(scores) == "table" and #scores or 0))
    lurek.docs.resetCatalog()
end

--@api: LQualityReport:getWorst
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.alpha", "Alpha entry")
    lurek.docs.describe("lurek.demo.beta", "")
    local qr = lurek.docs.quality(lurek.docs.getCatalog())
    local worst = qr:getWorst(5)
    lurek.log.info("worst count = " .. #worst)
    lurek.log.info("first worst = " .. tostring(worst[1] and worst[1]:getQualifiedName()))
    lurek.docs.resetCatalog()
end

--@api: LQualityReport:getBest
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.alpha", "Alpha entry")
    lurek.docs.describe("lurek.demo.beta", "")
    local qr = lurek.docs.quality(lurek.docs.getCatalog())
    local best = qr:getBest(5)
    lurek.log.info("best count = " .. #best)
    lurek.log.info("first best = " .. tostring(best[1] and best[1]:getQualifiedName()))
    lurek.docs.resetCatalog()
end

--@api: LQualityReport:getByGrade
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.alpha", "Alpha entry")
    lurek.docs.describe("lurek.demo.beta", "")
    local qr = lurek.docs.quality(lurek.docs.getCatalog())
    local c_entries = qr:getByGrade("C")
    lurek.log.info("grade C entries = " .. #c_entries)
    lurek.log.info("first C entry = " .. tostring(c_entries[1] and c_entries[1]:getQualifiedName()))
    lurek.docs.resetCatalog()
end

--@api: LQualityReport:getIssues
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.alpha", "Alpha entry")
    local qr = lurek.docs.quality(lurek.docs.getCatalog())
    local issues = qr:getIssues()
    lurek.log.info("quality issues = " .. #issues)
    lurek.log.info("first issue kind = " .. tostring(issues[1] and issues[1].kind))
    lurek.docs.resetCatalog()
end

--@api: LQualityReport:issueCount
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.alpha", "Alpha entry")
    local qr = lurek.docs.quality(lurek.docs.getCatalog())
    local issues = qr:getIssues()
    lurek.log.info("quality issue count = " .. qr:issueCount())
    lurek.log.info("issues table size = " .. #issues)
    lurek.docs.resetCatalog()
end

--@api: LQualityReport:getSummary
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.alpha", "Alpha entry")
    local qr = lurek.docs.quality(lurek.docs.getCatalog())
    local summary = qr:getSummary()
    lurek.log.info("summary = " .. summary)
    lurek.log.info("summary length = " .. #summary)
    lurek.docs.resetCatalog()
end

--@api: LQualityReport:toTable
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.alpha", "Alpha entry")
    local qr = lurek.docs.quality(lurek.docs.getCatalog())
    local t = qr:toTable()
    lurek.log.info("overall = " .. tostring(t.overallScore) .. " grade = " .. tostring(t.grade))
    lurek.log.info("module scores type = " .. tostring(type(t.moduleScores)))
    lurek.docs.resetCatalog()
end

--@api: LQualityReport:toJSON
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.alpha", "Alpha entry")
    local qr = lurek.docs.quality(lurek.docs.getCatalog())
    local json = qr:toJSON()
    lurek.log.info("json length = " .. #json)
    lurek.log.info("json has grade = " .. tostring(string.find(json, "grade", 1, true) ~= nil))
    lurek.docs.resetCatalog()
end

--@api: LQualityReport:type
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.alpha", "Alpha entry")
    local qr = lurek.docs.quality(lurek.docs.getCatalog())
    lurek.log.info("quality report type = " .. qr:type())
    lurek.log.info("summary length = " .. #qr:getSummary())
    lurek.docs.resetCatalog()
end

--@api: LQualityReport:typeOf
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.alpha", "Alpha entry")
    local qr = lurek.docs.quality(lurek.docs.getCatalog())
    lurek.log.info("is quality report = " .. tostring(qr:typeOf("LQualityReport")))
    lurek.log.info("is validation report = " .. tostring(qr:typeOf("LValidationReport")))
    lurek.docs.resetCatalog()
end
