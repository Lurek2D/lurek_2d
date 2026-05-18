--- Docs Module Part 1: Scanning, Catalog, Schema, DocEntry, Validation, Quality, Export

--@api-stub: lurek.docs.scan
-- Reflects the live lurek table and builds a catalog.
do
    local cat = lurek.docs.scan()
    print("scanned entries = " .. cat:entryCount())
end

--@api-stub: lurek.docs.scanModule
-- Reflects one module and builds a catalog for it.
do
    local cat = lurek.docs.scanModule("math")
    print("math entries = " .. cat:entryCount())
end

--@api-stub: lurek.docs.loadToml
-- Loads a TOML documentation catalog file.
do
    local path = "docs/api/math.toml"
    local cat = lurek.docs.loadToml(path)
    print("loaded entries = " .. cat:entryCount())
end

--@api-stub: lurek.docs.loadAll
-- Loads all TOML catalog files from a directory.
do
    local cat = lurek.docs.loadAll("docs/api/")
    print("all entries = " .. cat:entryCount())
end

--@api-stub: lurek.docs.describe
-- Adds or updates the description for a catalog entry.
do
    lurek.docs.describe("lurek.math.lerp", "Linearly interpolates between a and b.")
    print("description set")
end

--@api-stub: lurek.docs.setParamInfo
-- Replaces parameter metadata for a catalog entry.
do
    lurek.docs.setParamInfo("lurek.math.lerp", {
        {name = "a", type = "number", description = "Start value", optional = false},
        {name = "b", type = "number", description = "End value", optional = false},
        {name = "t", type = "number", description = "Interpolation factor", optional = false},
    })
    print("params set")
end

--@api-stub: lurek.docs.setReturnInfo
-- Replaces return-value metadata for a catalog entry.
do
    lurek.docs.setReturnInfo("lurek.math.lerp", {
        {type = "number", description = "Interpolated value"},
    })
    print("returns set")
end

--@api-stub: lurek.docs.getCatalog
-- Returns the editable in-memory documentation catalog.
do
    local cat = lurek.docs.getCatalog()
    print("catalog entries = " .. cat:entryCount())
end

--@api-stub: lurek.docs.resetCatalog
-- Clears the editable in-memory catalog.
do
    lurek.docs.resetCatalog()
    local cat = lurek.docs.getCatalog()
    print("after reset entries = " .. cat:entryCount())
end

--@api-stub: lurek.docs.validate
-- Compares a catalog with the live API table.
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    print("valid = " .. tostring(report:isValid()))
end

--@api-stub: lurek.docs.validateModule
-- Validates one module's catalog against live reflection.
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validateModule("math", cat)
    print("math missing = " .. report:missingCount())
end

--@api-stub: lurek.docs.checkStaleness
-- Lists source files for staleness checks.
do
    local cat = lurek.docs.scan()
    local result = lurek.docs.checkStaleness(cat, "src/math/")
    print("stale = " .. #result.stale .. " current = " .. #result.current)
end

--@api-stub: lurek.docs.quality
-- Computes documentation quality for a catalog.
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    print("quality score = " .. qr:getOverallScore())
end

--@api-stub: lurek.docs.qualityModule
-- Computes quality for one module.
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.qualityModule("math", cat)
    print("math quality = " .. qr:getOverallScore())
end

--@api-stub: lurek.docs.coverage
-- Returns documented and live API counts.
do
    local cat = lurek.docs.scan()
    local documented, live = lurek.docs.coverage(cat)
    print("documented=" .. documented .. " live=" .. live)
end

--@api-stub: lurek.docs.coverageModule
-- Returns documented and live API counts for one module.
do
    local cat = lurek.docs.scan()
    local documented, live = lurek.docs.coverageModule("math", cat)
    print("math documented=" .. documented .. " live=" .. live)
end

--@api-stub: lurek.docs.exportCompletions
-- Exports completion metadata to a file.
do
    local cat = lurek.docs.scan()
    lurek.docs.exportCompletions(cat, "build/completions.json")
    print("completions exported")
end

--@api-stub: lurek.docs.exportHover
-- Exports hover metadata to a file.
do
    local cat = lurek.docs.scan()
    lurek.docs.exportHover(cat, "build/hover.json")
    print("hover exported")
end

--@api-stub: lurek.docs.exportSignatures
-- Exports signature metadata to a file.
do
    local cat = lurek.docs.scan()
    lurek.docs.exportSignatures(cat, "build/signatures.json")
    print("signatures exported")
end

--@api-stub: lurek.docs.exportAll
-- Exports all editor documentation artifacts to a directory.
do
    local cat = lurek.docs.scan()
    lurek.docs.exportAll(cat, "build/docs/")
    print("all docs exported")
end

--@api-stub: lurek.docs.exportMarkdown
-- Writes a Markdown API reference from catalog entries.
do
    local cat = lurek.docs.scan()
    lurek.docs.exportMarkdown(cat, "build/api.md")
    print("markdown exported")
end

--@api-stub: lurek.docs.exportCheatsheet
-- Writes a compact text cheatsheet.
do
    local cat = lurek.docs.scan()
    lurek.docs.exportCheatsheet(cat, "build/cheatsheet.txt")
    print("cheatsheet exported")
end

--@api-stub: lurek.docs.schema
-- Builds a schema validator from Lua table rules.
do
    local s = lurek.docs.schema({
        name = {type = "string", required = true},
        age = {type = "number"},
    }, "PlayerSchema")
    print("schema name = " .. s:getName())
end

--@api-stub: lurek.docs.schemaFromToml
-- Builds a schema validator from TOML text.
do
    local toml = "[fields.name]\ntype = \"string\"\nrequired = true"
    local s = lurek.docs.schemaFromToml(toml)
    print("schema from toml, name = " .. s:getName())
end

--@api-stub: lurek.docs.reflectLive
-- Reflects live lurek module tables into name/type rows.
do
    local data = lurek.docs.reflectLive("math")
    print("reflect math type = " .. type(data))
end

--@api-stub: lurek.docs.reflectTable
-- Reflects an arbitrary Lua table into rows.
do
    local t = {foo = 1, bar = "hello"}
    local rows = lurek.docs.reflectTable(t, "mymod")
    print("reflected rows = " .. #rows)
end

--@api-stub: LSchema:validate
-- Validates a table and returns success plus error rows.
do
    local s = lurek.docs.schema({name = {type = "string", required = true}})
    local ok, errors = s:validate({name = "test"})
    print("valid = " .. tostring(ok) .. " errors = " .. #errors)
end

--@api-stub: LSchema:check
-- Validates a table and returns only the boolean result.
do
    local s = lurek.docs.schema({x = {type = "number"}})
    print("check = " .. tostring(s:check({x = 42})))
end

--@api-stub: LSchema:assert
-- Validates a table and raises a Lua error on failure.
do
    local s = lurek.docs.schema({v = {type = "number"}})
    s:assert({v = 10})
    print("assert passed")
end

--@api-stub: LSchema:getName
-- Returns this schema's display name.
do
    local s = lurek.docs.schema({}, "TestSchema")
    print("name = " .. s:getName())
end

--@api-stub: LSchema:getFields
-- Returns the field names declared by this schema.
do
    local s = lurek.docs.schema({a = {type = "number"}, b = {type = "string"}})
    local fields = s:getFields()
    print("fields = " .. #fields)
end

--@api-stub: LSchema:type
-- Returns the type name ("LSchema").
do
    local s = lurek.docs.schema({})
    print("type = " .. s:type())
end

--@api-stub: LSchema:typeOf
-- Returns whether this handle matches a type name.
do
    local s = lurek.docs.schema({})
    print("is LSchema = " .. tostring(s:typeOf("LSchema")))
end

--@api-stub: LDocEntry:getName
-- Returns the short API name.
do
    local cat = lurek.docs.scan()
    local entries = cat:getEntries("math")
    if #entries > 0 then
        print("name = " .. entries[1]:getName())
    end
end

--@api-stub: LDocEntry:getQualifiedName
-- Returns the full dotted API name.
do
    local cat = lurek.docs.scan()
    local entries = cat:getEntries("math")
    if #entries > 0 then
        print("qualified = " .. entries[1]:getQualifiedName())
    end
end

--@api-stub: LDocEntry:getModule
-- Returns the module name.
do
    local cat = lurek.docs.scan()
    local entries = cat:getEntries("math")
    if #entries > 0 then
        print("module = " .. entries[1]:getModule())
    end
end

--@api-stub: LDocEntry:getKind
-- Returns the documentation kind.
do
    local cat = lurek.docs.scan()
    local entries = cat:getEntries("math")
    if #entries > 0 then
        print("kind = " .. entries[1]:getKind())
    end
end

--@api-stub: LDocEntry:getDescription
-- Returns the description text.
do
    local cat = lurek.docs.scan()
    local entries = cat:getEntries()
    if #entries > 0 then
        print("desc len = " .. #entries[1]:getDescription())
    end
end

--@api-stub: LDocEntry:getParameters
-- Returns parameter metadata rows.
do
    local cat = lurek.docs.scan()
    local entries = cat:getEntries("math")
    if #entries > 0 then
        local params = entries[1]:getParameters()
        print("params = " .. #params)
    end
end

--@api-stub: LDocEntry:getReturns
-- Returns return-value metadata rows.
do
    local cat = lurek.docs.scan()
    local entries = cat:getEntries("math")
    if #entries > 0 then
        local rets = entries[1]:getReturns()
        print("returns = " .. #rets)
    end
end

--@api-stub: LDocEntry:getExample
-- Returns example text when present.
do
    local cat = lurek.docs.scan()
    local entries = cat:getEntries()
    if #entries > 0 then
        local ex = entries[1]:getExample()
        print("example = " .. type(ex))
    end
end

--@api-stub: LDocEntry:getSince
-- Returns the since-version text.
do
    local cat = lurek.docs.scan()
    local entries = cat:getEntries()
    if #entries > 0 then
        local since = entries[1]:getSince()
        print("since = " .. type(since))
    end
end

--@api-stub: LDocEntry:getDeprecated
-- Returns the deprecation text.
do
    local cat = lurek.docs.scan()
    local entries = cat:getEntries()
    if #entries > 0 then
        local dep = entries[1]:getDeprecated()
        print("deprecated = " .. type(dep))
    end
end

--@api-stub: LDocEntry:getScore
-- Returns the documentation quality score.
do
    local cat = lurek.docs.scan()
    local entries = cat:getEntries()
    if #entries > 0 then
        print("score = " .. entries[1]:getScore())
    end
end

--@api-stub: LDocEntry:hasDescription
-- Returns whether this entry has description text.
do
    local cat = lurek.docs.scan()
    local entries = cat:getEntries()
    if #entries > 0 then
        print("hasDesc = " .. tostring(entries[1]:hasDescription()))
    end
end

--@api-stub: LDocEntry:hasParameters
-- Returns whether this entry has parameter metadata.
do
    local cat = lurek.docs.scan()
    local entries = cat:getEntries()
    if #entries > 0 then
        print("hasParams = " .. tostring(entries[1]:hasParameters()))
    end
end

--@api-stub: LDocEntry:hasReturnType
-- Returns whether this entry has return-value metadata.
do
    local cat = lurek.docs.scan()
    local entries = cat:getEntries()
    if #entries > 0 then
        print("hasReturn = " .. tostring(entries[1]:hasReturnType()))
    end
end

--@api-stub: LDocEntry:hasExample
-- Returns whether this entry has example text.
do
    local cat = lurek.docs.scan()
    local entries = cat:getEntries()
    if #entries > 0 then
        print("hasExample = " .. tostring(entries[1]:hasExample()))
    end
end

--@api-stub: LDocEntry:type
-- Returns the type name ("LDocEntry").
do
    local cat = lurek.docs.scan()
    local entries = cat:getEntries()
    if #entries > 0 then
        print("type = " .. entries[1]:type())
    end
end

--@api-stub: LDocEntry:typeOf
-- Returns whether this handle matches a type name.
do
    local cat = lurek.docs.scan()
    local entries = cat:getEntries()
    if #entries > 0 then
        print("is LDocEntry = " .. tostring(entries[1]:typeOf("LDocEntry")))
    end
end

print("docs_00.lua")
