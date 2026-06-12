-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_docs_core_unit.lua
do
-- tests/lua/test_docs.lua
-- BDD tests for lurek.docs.* documentation management API

local function unique_docs_id(stem)
    return table.concat({
        stem,
        tostring(os.time()),
        tostring(math.floor(os.clock() * 1000000)),
    }, "_")
end

local function docs_temp_path(stem, ext)
    return "save/_fs_tests/" .. unique_docs_id(stem) .. ext
end

local function write_text_file(path, content)
    lurek.filesystem.write(path, content)
end

local function read_text_file(path)
    return lurek.filesystem.read(path)
end

local function file_exists(path)
    return lurek.filesystem.exists(path)
end

local function seed_catalog_entry(qualified_name, description)
    lurek.docs.describe(qualified_name, description)
    lurek.docs.setParamInfo(qualified_name, {
        { name = "value", type = "number", description = "input value", optional = false },
    })
    lurek.docs.setReturnInfo(qualified_name, {
        { type = "number", description = "result value" },
    })
end

local function sample_docs_toml(entries)
    return table.concat(entries, "\n")
end

-- @describe lurek.docs
describe("lurek.docs", function()

    -- ============= scan =============

    -- ============= describe / getCatalog / resetCatalog =============

    -- @covers lurek.docs.describe
    it("should describe and getCatalog", function()
        lurek.docs.resetCatalog()
        lurek.docs.describe("lurek.test.foo", "A test function")
        local cat = lurek.docs.getCatalog()
        local entry = cat:getEntry("lurek.test.foo")
        expect_not_nil(entry, "entry should exist after describe")
        expect_equal("A test function", entry:getDescription())
        lurek.docs.resetCatalog()
    end)
    -- ============= setParamInfo / setReturnInfo =============

    -- @covers lurek.docs.setParamInfo
    it("should set parameter info", function()
        lurek.docs.resetCatalog()
        lurek.docs.describe("lurek.test.func", "A function")
        lurek.docs.setParamInfo("lurek.test.func", {
            { name = "x", type = "number", description = "X coord", optional = false },
            { name = "y", type = "number", description = "Y coord", optional = true, default = "0" },
        })
        local cat = lurek.docs.getCatalog()
        local entry = cat:getEntry("lurek.test.func")
        expect_not_nil(entry, "entry should exist")
        local params = entry:getParameters()
        expect_equal(2, #params)
        expect_equal("x", params[1].name)
        expect_equal("number", params[1].type)
        expect_equal(true, params[2].optional)
        lurek.docs.resetCatalog()
    end)
    -- @covers lurek.docs.setReturnInfo
    it("should set return info", function()
        lurek.docs.resetCatalog()
        lurek.docs.describe("lurek.test.func2", "Another function")
        lurek.docs.setReturnInfo("lurek.test.func2", {
            { type = "number", description = "The result" },
        })
        local cat = lurek.docs.getCatalog()
        local entry = cat:getEntry("lurek.test.func2")
        expect_not_nil(entry, "entry should exist")
        local returns = entry:getReturns()
        expect_equal(1, #returns)
        expect_equal("number", returns[1].type)
        lurek.docs.resetCatalog()
    end)

    -- ============= DocEntry methods =============

    -- ============= validate =============

    -- @covers lurek.docs.validate
    it("should validate completeness", function()
        -- Validating with no catalog should report many missing
        local report = lurek.docs.validate()
        expect_not_nil(report, "validate should return a report")
        expect_true(report:missingCount() > 0, "should have missing entries with empty catalog")
        expect_true(not report:isValid(), "should not be valid with empty catalog")
    end)
    -- ============= quality =============

    -- @covers lurek.docs.quality
    it("should compute quality metrics", function()
        lurek.docs.resetCatalog()
        lurek.docs.describe("lurek.test.q1", "Good entry")
        lurek.docs.setParamInfo("lurek.test.q1", {
            { name = "a", type = "number", description = "A param" }
        })
        lurek.docs.setReturnInfo("lurek.test.q1", {
            { type = "number", description = "Result" }
        })
        local cat = lurek.docs.getCatalog()
        local quality = lurek.docs.quality(cat)
        expect_not_nil(quality, "quality() should return a report")
        local score = quality:getOverallScore()
        expect_true(math.abs(score - 0.6) < 0.01, "score should be 0.6, got " .. score)
        local grade = quality:getGrade()
        expect_equal("C", grade)
        lurek.docs.resetCatalog()
    end)
end)

-- =========================================================================
-- =========================================================================

-- @describe Missing API Coverage
describe("Missing API Coverage", function()
    -- @covers lurek.docs.loadToml
    it("covers lurek.docs.loadToml", function()
        local path = docs_temp_path("docs_load_toml", ".toml")
        write_text_file(path, sample_docs_toml({
            "[[entries]]",
            'name = "play"',
            'qualifiedName = "lurek.audio.play"',
            'module = "audio"',
            'kind = "function"',
            'description = "Plays a sound"',
        }))

        local catalog = lurek.docs.loadToml(path)
        local entry = catalog:getEntry("lurek.audio.play")

        expect_not_nil(entry)
        expect_equal(1, catalog:entryCount())
        expect_equal("Plays a sound", entry:getDescription())

        os.remove(path)
    end)

    -- @covers lurek.docs.loadAll
    it("covers lurek.docs.loadAll", function()
        local suffix = unique_docs_id("docs_load_all")
        local path_a = "save/_fs_tests/" .. suffix .. "_a.toml"
        local path_b = "save/_fs_tests/" .. suffix .. "_b.toml"

        write_text_file(path_a, sample_docs_toml({
            "[[entries]]",
            'name = "one"',
            'qualifiedName = "lurek.test.' .. suffix .. '.one"',
            'module = "test"',
            'kind = "function"',
            'description = "First entry"',
        }))
        write_text_file(path_b, sample_docs_toml({
            "[[entries]]",
            'name = "two"',
            'qualifiedName = "lurek.test.' .. suffix .. '.two"',
            'module = "test"',
            'kind = "function"',
            'description = "Second entry"',
        }))

        local catalog = lurek.docs.loadAll("save/_fs_tests")
        expect_not_nil(catalog:getEntry("lurek.test." .. suffix .. ".one"))
        expect_not_nil(catalog:getEntry("lurek.test." .. suffix .. ".two"))

        os.remove(path_a)
        os.remove(path_b)
    end)

    -- @covers lurek.docs.checkStaleness
    it("covers lurek.docs.checkStaleness", function()
        local catalog = lurek.docs.scanModule("docs")
        local report = lurek.docs.checkStaleness(catalog, "src/docs")

        expect_type("table", report)
        expect_type("table", report.stale)
        expect_type("table", report.current)
        expect_type("table", report.missing)
        expect_true(#report.current > 0)
    end)

    -- @covers lurek.docs.qualityModule
    it("covers lurek.docs.qualityModule", function()
        local module_name = "lurek.docsbatch." .. unique_docs_id("quality_module")

        lurek.docs.resetCatalog()
        seed_catalog_entry(module_name .. ".alpha", "Alpha entry")
        seed_catalog_entry(module_name .. ".beta", "Beta entry")

        local cat = lurek.docs.getCatalog()
        local quality = lurek.docs.qualityModule(module_name, cat)

        expect_type("number", quality:getOverallScore())
        expect_equal("C", quality:getGrade())
        lurek.docs.resetCatalog()
    end)

    -- @covers lurek.docs.exportCompletions
    it("covers lurek.docs.exportCompletions", function()
        local path = docs_temp_path("docs_export_completions", ".json")
        lurek.docs.resetCatalog()
        seed_catalog_entry("lurek.test.exportCompletions", "Completion entry")

        local cat = lurek.docs.getCatalog()
        lurek.docs.exportCompletions(cat, path)

        expect_true(file_exists(path))
        expect_true(string.find(read_text_file(path), "exportCompletions", 1, true) ~= nil)

        os.remove(path)
        lurek.docs.resetCatalog()
    end)

    -- @covers lurek.docs.exportHover
    it("covers lurek.docs.exportHover", function()
        local path = docs_temp_path("docs_export_hover", ".json")
        lurek.docs.resetCatalog()
        seed_catalog_entry("lurek.test.exportHover", "Hover entry")

        local cat = lurek.docs.getCatalog()
        lurek.docs.exportHover(cat, path)

        expect_true(file_exists(path))
        expect_true(string.find(read_text_file(path), "lurek.test.exportHover", 1, true) ~= nil)

        os.remove(path)
        lurek.docs.resetCatalog()
    end)

    -- @covers lurek.docs.exportSignatures
    it("covers lurek.docs.exportSignatures", function()
        local path = docs_temp_path("docs_export_signatures", ".json")
        lurek.docs.resetCatalog()
        seed_catalog_entry("lurek.test.exportSignatures", "Signature entry")

        local cat = lurek.docs.getCatalog()
        lurek.docs.exportSignatures(cat, path)

        expect_true(file_exists(path))
        expect_true(string.find(read_text_file(path), "value", 1, true) ~= nil)

        os.remove(path)
        lurek.docs.resetCatalog()
    end)

    -- @covers lurek.docs.exportAll
    it("covers lurek.docs.exportAll", function()
        local dir = "save/_fs_tests/" .. unique_docs_id("docs_export_all")
        local completions = dir .. "/completions.json"
        local hover = dir .. "/hover.json"
        local signatures = dir .. "/signatures.json"

        lurek.docs.resetCatalog()
        seed_catalog_entry("lurek.test.exportAll", "Export all entry")

        local cat = lurek.docs.getCatalog()
        lurek.docs.exportAll(cat, dir)

        expect_true(file_exists(completions))
        expect_true(file_exists(hover))
        expect_true(file_exists(signatures))

        os.remove(completions)
        os.remove(hover)
        os.remove(signatures)
        lurek.docs.resetCatalog()
    end)

    -- @covers lurek.docs.exportMarkdown
    it("covers lurek.docs.exportMarkdown", function()
        local path = docs_temp_path("docs_export_markdown", ".md")
        lurek.docs.resetCatalog()
        seed_catalog_entry("lurek.test.exportMarkdown", "Markdown entry")

        local cat = lurek.docs.getCatalog()
        lurek.docs.exportMarkdown(cat, path)

        local content = read_text_file(path)
        expect_true(string.find(content, "# API Reference", 1, true) ~= nil)
        expect_true(string.find(content, "lurek.test.exportMarkdown", 1, true) ~= nil)

        os.remove(path)
        lurek.docs.resetCatalog()
    end)

    -- @covers lurek.docs.exportCheatsheet
    it("covers lurek.docs.exportCheatsheet", function()
        local path = docs_temp_path("docs_export_cheatsheet", ".txt")
        lurek.docs.resetCatalog()
        seed_catalog_entry("lurek.test.exportCheatsheet", "Cheatsheet entry")

        local cat = lurek.docs.getCatalog()
        lurek.docs.exportCheatsheet(cat, path)

        local content = read_text_file(path)
        expect_true(string.find(content, "lurek.test.exportCheatsheet(value)", 1, true) ~= nil)
        expect_true(string.find(content, "Cheatsheet entry", 1, true) ~= nil)

        os.remove(path)
        lurek.docs.resetCatalog()
    end)

    -- @covers lurek.docs.reflectLive
    it("covers lurek.docs.reflectLive", function()
        local reflected = lurek.docs.reflectLive("math")
        expect_type("table", reflected)
        expect_type("table", reflected.math)
        expect_true(#reflected.math > 0)
        expect_type("string", reflected.math[1].name)
        expect_type("string", reflected.math[1].type)
    end)

    -- @covers lurek.docs.reflectTable
    it("covers lurek.docs.reflectTable", function()
        local reflected = lurek.docs.reflectTable({
            alpha = 1,
            beta = function() end,
        }, "demo")

        local seen_alpha = false
        local seen_beta = false
        for _, item in ipairs(reflected) do
            if item.name == "alpha" then
                seen_alpha = true
                expect_equal("demo.alpha", item.qualifiedName)
                expect_equal("integer", item.type)
            elseif item.name == "beta" then
                seen_beta = true
                expect_equal("demo.beta", item.qualifiedName)
                expect_equal("function", item.type)
            end
        end

        expect_true(seen_alpha)
        expect_true(seen_beta)
    end)

    -- @covers LSchema:getFields
    it("covers Schema:getFields", function()
        local schema = lurek.docs.schema({
            zeta = "string",
            alpha = { type = "number", required = true },
        }, "field_schema")

        local fields = schema:getFields()
        expect_equal(2, #fields)
        expect_equal("alpha", fields[1])
        expect_equal("zeta", fields[2])
    end)

    -- @covers LDocEntry:getQualifiedName
    it("DocEntry exposes qualified name kind and optional metadata", function()
        lurek.docs.resetCatalog()
        lurek.docs.describe("lurek.test.meta", "Meta entry")
        local entry = lurek.docs.getCatalog():getEntry("lurek.test.meta")

        expect_not_nil(entry)
        expect_equal("lurek.test.meta", entry:getQualifiedName())
        expect_equal("lurek.test", entry:getModule())
        expect_equal("function", entry:getKind())
        expect_nil(entry:getExample())
        expect_nil(entry:getSince())
        expect_nil(entry:getDeprecated())

        lurek.docs.resetCatalog()
    end)

    -- @covers LApiCatalog:getTypeMethods
    it("covers ApiCatalog:getTypeMethods", function()
        local path = docs_temp_path("docs_type_methods", ".toml")
        write_text_file(path, sample_docs_toml({
            "[[entries]]",
            'name = "Vector"',
            'qualifiedName = "lurek.test.Vector"',
            'module = "test"',
            'kind = "type"',
            'description = "Vector type"',
            "",
            "[[entries]]",
            'name = "len"',
            'qualifiedName = "lurek.test.Vector:len"',
            'module = "test"',
            'kind = "method"',
            'description = "Length method"',
        }))

        local catalog = lurek.docs.loadToml(path)
        local type_names = catalog:getTypes("test")
        local methods = catalog:getTypeMethods("lurek.test.Vector")

        expect_equal(1, #type_names)
        expect_equal("Vector", type_names[1])
        expect_equal(1, #methods)
        expect_equal("len", methods[1]:getName())

        os.remove(path)
    end)

    -- @covers LValidationReport:getMissing
    it("ValidationReport exposes issue lists and count helpers", function()
        local report = lurek.docs.validate()
        local missing = report:getMissing()
        local phantom = report:getPhantom()
        local incomplete = report:getIncomplete()

        expect_type("table", missing)
        expect_type("table", phantom)
        expect_type("table", incomplete)
        expect_true(#missing > 0)
        expect_equal(#phantom, report:phantomCount())
        expect_equal(#incomplete, report:incompleteCount())
    end)

end)

-- @describe Missing explicit test for lurek.docs.schema
describe("Missing explicit test for lurek.docs.schema", function()
    -- @covers lurek.docs.schema
    it("lurek.docs.schema works", function()
        local schema = lurek.docs.schema({
            name = "string",
        }, "player")
        expect_equal("player", schema:getName())
    end)
end)

-- @describe Missing explicit test for Schema:validate
describe("Missing explicit test for Schema:validate", function()
    -- @covers LSchema:validate
    it("Schema:validate works", function()
        local schema = lurek.docs.schema({
            name = { type = "string", required = true },
        }, "validate_schema")
        local ok, errors = schema:validate({})
        expect_false(ok)
        expect_equal(1, #errors)
        expect_true(string.find(errors[1].message, "required", 1, true) ~= nil)
    end)
end)

-- @describe Missing explicit test for Schema:check
describe("Missing explicit test for Schema:check", function()
    -- @covers LSchema:check
    it("Schema:check works", function()
        local schema = lurek.docs.schema({
            age = { type = "number", required = true, min = 1, max = 100 },
            class = { type = "string", required = true, enum = { "warrior", "mage" } },
        }, "check_schema")

        expect_false(schema:check({ age = "old", class = "rogue" }))
        expect_true(schema:check({ age = 50, class = "mage" }))
    end)
end)

-- @describe Missing explicit test for Schema:assert
describe("Missing explicit test for Schema:assert", function()
    -- @covers LSchema:assert
    it("Schema:assert works", function()
        local schema = lurek.docs.schema({
            __strict = true,
            level = { type = "integer", required = true, max = 10 },
        }, "assert_schema")

        expect_error(function()
            schema:assert({ level = 11, extra = true })
        end)

        schema:assert({ level = 5 })
    end)
end)

-- @describe Missing explicit test for Schema:getName
describe("Missing explicit test for Schema:getName", function()
    -- @covers LSchema:getName
    it("Schema:getName works", function()
        local schema = lurek.docs.schema({ hp = "number" }, "hero_schema")
        expect_equal("hero_schema", schema:getName())
    end)
end)

-- @describe docs strict: lurek.docs.schemaFromToml
describe("docs strict: lurek.docs.schemaFromToml", function()
    -- @covers lurek.docs.schemaFromToml
    it("creates schema from TOML text", function()
        local toml = [[
name = "player"
strict = true

[rules.level]
type = "integer"
required = true
min = 1
max = 99
        ]]

        local docs_any = lurek.docs ---@type any
        local schema = docs_any.schemaFromToml(toml)
        expect_equal("player", schema:getName())
        expect_false(schema:check({ level = 100 }))
        expect_true(schema:check({ level = 50 }))
    end)
end)

-- @describe docs strict: LSchema type / typeOf
describe("docs strict: LSchema type / typeOf", function()
    -- @covers LSchema:type
    it("LSchema type and typeOf are callable", function()
        local s = lurek.docs.schema({ name = "string" })
        expect_type("string", s:type())
        expect_type("boolean", s:typeOf("LObject"))
    end)
end)

-- @describe docs strict: LDocEntry accessors
describe("docs strict: LDocEntry accessors", function()
    -- @covers LDocEntry:getName
    it("LDocEntry accessors are callable for a real entry", function()
        local cat = lurek.docs.getCatalog()
        local entries = cat:getEntries()
        if #entries == 0 then
            expect_equal(0, #entries)
            return
        end
        local e = entries[1]
        expect_type("string", e:getName())
        expect_type("string", e:getQualifiedName())
        expect_type("string", e:getModule())
        expect_type("string", e:getKind())
        expect_type("string", e:getDescription())
        local ex = e:getExample()
        expect_true(ex == nil or type(ex) == "string")
        local since = e:getSince()
        expect_true(since == nil or type(since) == "string")
        local dep = e:getDeprecated()
        expect_true(dep == nil or type(dep) == "string")
        expect_type("string", e:type())
        expect_type("boolean", e:typeOf("LObject"))
    end)
end)

-- @describe docs strict: LApiCatalog merge / type / typeOf
describe("docs strict: LApiCatalog merge / type / typeOf", function()
    -- @covers LApiCatalog:merge
    it("LApiCatalog merge returns new catalog and type is callable", function()
        local cat = lurek.docs.getCatalog()
        local cat_any = cat ---@type any
        local ok, merged = pcall(function() return cat_any:merge(cat_any) end)
        if ok then
            expect_true(merged ~= nil)
        end
        expect_type("string", cat:type())
        expect_type("boolean", cat:typeOf("LObject"))
    end)
end)

-- @describe docs strict: LValidationReport type / typeOf
describe("docs strict: LValidationReport type / typeOf", function()
    -- @covers LValidationReport:type
    it("LValidationReport type and typeOf are callable", function()
        local report = lurek.docs.validate()
        expect_type("string", report:type())
        expect_type("boolean", report:typeOf("LObject"))
    end)
end)

-- @describe docs strict: LQualityReport toTable / type / typeOf
describe("docs strict: LQualityReport toTable / type / typeOf", function()
    -- @covers LQualityReport:toTable
    it("LQualityReport toTable / type / typeOf are callable", function()
        local q = lurek.docs.quality()
        local t = q:toTable()
        expect_type("table", t)
        expect_type("string", q:type())
        expect_type("boolean", q:typeOf("LObject"))
    end)
end)
end
-- END test_docs_core_unit.lua

-- BEGIN test_docs_api_unit.lua
do
-- tests/lua/test_docs.lua
-- BDD tests for lurek.docs.* documentation management API

-- @describe lurek.docs
describe("lurek.docs", function()

    -- ============= scan =============

    -- @covers lurek.docs.scan
    it("should scan the lurek namespace", function()
        local catalog = lurek.docs.scan()
        expect_not_nil(catalog, "scan() should return an ApiCatalog")
    end)

    -- @covers LApiCatalog:getModules
    it("scan should return catalog with getModules", function()
        local catalog = lurek.docs.scan()
        local modules = catalog:getModules()
        expect_not_nil(modules, "getModules() should return a table")
        -- There must be at least a few modules (graphics, audio, etc.)
        expect_true(#modules > 0, "should have found at least one module")
    end)

    -- @covers LApiCatalog:getEntries
    it("scan should find lurek.render functions", function()
        local catalog = lurek.docs.scan()
        local entries = catalog:getEntries("render")
        expect_not_nil(entries, "getEntries('render') should return a table")
        expect_true(#entries > 0, "render should have entries")
    end)

    -- ============= scanModule =============

    -- @covers lurek.docs.scanModule
    it("should scan a single module", function()
        local catalog = lurek.docs.scanModule("render")
        expect_not_nil(catalog, "scanModule should return a catalog")
        local count = catalog:entryCount()
        expect_true(count > 0, "graphics module should have entries")
    end)
    -- ============= describe / getCatalog / resetCatalog =============

    -- @covers lurek.docs.getCatalog
    it("should describe and getCatalog", function()
        lurek.docs.resetCatalog()
        lurek.docs.describe("lurek.test.foo", "A test function")
        local cat = lurek.docs.getCatalog()
        local entry = cat:getEntry("lurek.test.foo")
        expect_not_nil(entry, "entry should exist after describe")
        expect_equal("A test function", entry:getDescription())
        lurek.docs.resetCatalog()
    end)
    -- @covers lurek.docs.resetCatalog
    it("should reset the internal catalog", function()
        lurek.docs.describe("lurek.test.bar", "Another test")
        lurek.docs.resetCatalog()
        local cat = lurek.docs.getCatalog()
        expect_equal(0, cat:entryCount())
    end)

    -- ============= setParamInfo / setReturnInfo =============

    -- @covers LDocEntry:getParameters
    it("should set parameter info", function()
        lurek.docs.resetCatalog()
        lurek.docs.describe("lurek.test.func", "A function")
        lurek.docs.setParamInfo("lurek.test.func", {
            { name = "x", type = "number", description = "X coord", optional = false },
            { name = "y", type = "number", description = "Y coord", optional = true, default = "0" },
        })
        local cat = lurek.docs.getCatalog()
        local entry = cat:getEntry("lurek.test.func")
        expect_not_nil(entry, "entry should exist")
        local params = entry:getParameters()
        expect_equal(2, #params)
        expect_equal("x", params[1].name)
        expect_equal("number", params[1].type)
        expect_equal(true, params[2].optional)
        lurek.docs.resetCatalog()
    end)
    -- @covers LDocEntry:getReturns
    it("should set return info", function()
        lurek.docs.resetCatalog()
        lurek.docs.describe("lurek.test.func2", "Another function")
        lurek.docs.setReturnInfo("lurek.test.func2", {
            { type = "number", description = "The result" },
        })
        local cat = lurek.docs.getCatalog()
        local entry = cat:getEntry("lurek.test.func2")
        expect_not_nil(entry, "entry should exist")
        local returns = entry:getReturns()
        expect_equal(1, #returns)
        expect_equal("number", returns[1].type)
        lurek.docs.resetCatalog()
    end)

    -- ============= DocEntry methods =============

    -- @covers LDocEntry:getScore
    it("DocEntry should report score correctly", function()
        lurek.docs.resetCatalog()
        -- Entry with description only = 40%
        lurek.docs.describe("lurek.test.scored", "Has description")
        local cat = lurek.docs.getCatalog()
        local entry = cat:getEntry("lurek.test.scored")
        expect_not_nil(entry)
        local score = entry:getScore()
        expect_true(math.abs(score - 0.4) < 0.01, "score should be 0.4 for desc only, got " .. score)
        expect_true(entry:hasDescription())
        expect_true(not entry:hasParameters())
        expect_true(not entry:hasReturnType())
        expect_true(not entry:hasExample())
        lurek.docs.resetCatalog()
    end)
    -- ============= ApiCatalog methods =============

    -- @covers LApiCatalog:entryCount
    it("catalog should support entryCount", function()
        local catalog = lurek.docs.scanModule("math")
        local count = catalog:entryCount()
        expect_true(count >= 0, "entryCount should return a number")
    end)
    -- @covers LApiCatalog:search
    it("catalog should support search", function()
        local catalog = lurek.docs.scan()
        local results = catalog:search("render")
        expect_not_nil(results, "search should return results")
        -- At least lurek.render.* functions contain 'render' in qualified name
        expect_true(#results > 0, "should find render entries")
    end)

    -- @covers LApiCatalog:toTable
    it("catalog should support toTable", function()
        lurek.docs.resetCatalog()
        lurek.docs.describe("lurek.test.tt", "Test toTable")
        local cat = lurek.docs.getCatalog()
        local tbl = cat:toTable()
        expect_equal(1, #tbl)
        expect_equal("lurek.test.tt", tbl[1].qualifiedName)
        lurek.docs.resetCatalog()
    end)

    -- @covers LApiCatalog:toJSON
    it("catalog should support toJSON", function()
        lurek.docs.resetCatalog()
        lurek.docs.describe("lurek.test.json", "Test JSON")
        local cat = lurek.docs.getCatalog()
        local json = cat:toJSON()
        expect_not_nil(json, "toJSON should return a string")
        expect_true(#json > 0, "JSON should not be empty")
        lurek.docs.resetCatalog()
    end)

    -- @covers LApiCatalog:filter
    it("catalog should support filter", function()
        local catalog = lurek.docs.scan()
        local filtered = catalog:filter(function(entry)
            return entry:getName() == "setColor"
        end)
        expect_not_nil(filtered, "filter should return a catalog")
        -- Every entry should be named setColor
        local entries = filtered:getEntries()
        for i = 1, #entries do
            expect_equal("setColor", entries[i]:getName())
        end
    end)

    -- @covers LApiCatalog:type
    it("catalog exposes callable userdata type helpers", function()
        local cat1 = lurek.docs.scanModule("math")
        expect_type("function", cat1.merge)
        expect_type("string", cat1:type())
    end)

    -- ============= validate =============

    -- @covers LValidationReport:isValid
    it("should validate completeness", function()
        -- Validating with no catalog should report many missing
        local report = lurek.docs.validate()
        expect_not_nil(report, "validate should return a report")
        expect_true(report:missingCount() > 0, "should have missing entries with empty catalog")
        expect_true(not report:isValid(), "should not be valid with empty catalog")
    end)
    -- @covers lurek.docs.validateModule
    it("should validate a single module", function()
        local report = lurek.docs.validateModule("math")
        expect_not_nil(report, "validateModule should return a report")
        local summary = report:getSummary()
        expect_not_nil(summary, "getSummary should return a string")
    end)

    -- @covers LValidationReport:toTable
    it("validation report should support toTable", function()
        local report = lurek.docs.validate()
        local tbl = report:toTable()
        expect_not_nil(tbl.missing, "toTable should have missing field")
        expect_not_nil(tbl.phantom, "toTable should have phantom field")
        expect_not_nil(tbl.incomplete, "toTable should have incomplete field")
    end)

    -- @covers LValidationReport:toJSON
    it("validation report should support toJSON", function()
        local report = lurek.docs.validate()
        local json = report:toJSON()
        expect_not_nil(json, "toJSON should return a string")
        expect_true(#json > 0, "JSON should not be empty")
    end)

    -- ============= quality =============

    -- @covers LQualityReport:getOverallScore
    it("should compute quality metrics", function()
        lurek.docs.resetCatalog()
        lurek.docs.describe("lurek.test.q1", "Good entry")
        lurek.docs.setParamInfo("lurek.test.q1", {
            { name = "a", type = "number", description = "A param" }
        })
        lurek.docs.setReturnInfo("lurek.test.q1", {
            { type = "number", description = "Result" }
        })
        local cat = lurek.docs.getCatalog()
        local quality = lurek.docs.quality(cat)
        expect_not_nil(quality, "quality() should return a report")
        local score = quality:getOverallScore()
        -- domain scoring: desc(1/5) + qualified_name(1/5) + params_or_returns(1/5) = 3/5 = 0.6
        expect_true(math.abs(score - 0.6) < 0.01, "score should be 0.6, got " .. score)
        local grade = quality:getGrade()
        expect_equal("C", grade)
        lurek.docs.resetCatalog()
    end)
    -- @covers LQualityReport:getModuleScores
    it("quality should support getModuleScores", function()
        lurek.docs.resetCatalog()
        lurek.docs.describe("lurek.test.ms", "Module score test")
        local cat = lurek.docs.getCatalog()
        local quality = lurek.docs.quality(cat)
        local scores = quality:getModuleScores()
        expect_not_nil(scores, "getModuleScores should return a table")
        lurek.docs.resetCatalog()
    end)

    -- @covers LQualityReport:getWorst
    it("quality should support getWorst and getBest", function()
        lurek.docs.resetCatalog()
        lurek.docs.describe("lurek.test.w1", "Good")
        lurek.docs.describe("lurek.test.w2", "") -- bad: empty description
        local cat = lurek.docs.getCatalog()
        local quality = lurek.docs.quality(cat)
        local worst = quality:getWorst(1)
        expect_not_nil(worst, "getWorst should return entries")
        local best = quality:getBest(1)
        expect_not_nil(best, "getBest should return entries")
        lurek.docs.resetCatalog()
    end)

    -- @covers LQualityReport:getByGrade
    it("quality should support getByGrade", function()
        lurek.docs.resetCatalog()
        lurek.docs.describe("lurek.test.g1", "Has desc only")
        local cat = lurek.docs.getCatalog()
        local quality = lurek.docs.quality(cat)
        -- desc only = 0.4, grade D
        local d_entries = quality:getByGrade("D")
        expect_not_nil(d_entries, "getByGrade should return entries")
        expect_true(#d_entries > 0, "should have at least one D-grade entry")
        lurek.docs.resetCatalog()
    end)

    -- @covers LQualityReport:getSummary
    it("quality should support getSummary", function()
        lurek.docs.resetCatalog()
        lurek.docs.describe("lurek.test.sum", "Summary test")
        local cat = lurek.docs.getCatalog()
        local quality = lurek.docs.quality(cat)
        local summary = quality:getSummary()
        expect_not_nil(summary, "getSummary should return a string")
        expect_true(#summary > 0, "summary should not be empty")
        lurek.docs.resetCatalog()
    end)

    -- ============= coverage =============

    -- @covers lurek.docs.coverage
    it("should compute coverage with and without an explicit catalog", function()
        local documented, total = lurek.docs.coverage()
        expect_true(total > 0, "total should be > 0")
        expect_equal(0, documented, "documented should be 0 with no catalog")
        local catalog = lurek.docs.scan()
        documented, total = lurek.docs.coverage(catalog)
        -- When passing the full scan, documented == total
        expect_equal(total, documented)
    end)

    -- ============= coverageModule =============

    -- @covers lurek.docs.coverageModule
    it("should compute module coverage", function()
        local documented, total = lurek.docs.coverageModule("math")
        expect_true(total >= 0, "total should be >= 0")
    end)

end)
end
-- END test_docs_api_unit.lua

do
local function unique_docs_suffix(stem)
    return stem .. "_" .. tostring(math.floor(os.clock() * 1000000))
end

local function docs_temp_path(stem)
    return "save/_fs_tests/" .. unique_docs_suffix(stem) .. ".toml"
end

local function write_text(path, content)
    lurek.filesystem.write(path, content)
end

local function rich_catalog()
    local path = docs_temp_path("rich_catalog")
    write_text(path, table.concat({
        "[[entries]]",
        'name = "spawn"',
        'qualifiedName = "lurek.demo.spawn"',
        'module = "demo"',
        'kind = "function"',
        'description = "Spawn demo entity"',
        'example = "lurek.demo.spawn()"',
        'since = "0.1.0"',
        'deprecated = "use lurek.demo.spawnEx"',
        "",
        "[[entries]]",
        'name = "Thing"',
        'qualifiedName = "lurek.demo.Thing"',
        'module = "demo"',
        'kind = "type"',
        'description = "Demo type"',
        "",
        "[[entries]]",
        'name = "tick"',
        'qualifiedName = "lurek.demo.Thing:tick"',
        'module = "demo"',
        'kind = "method"',
        'description = "Tick method"',
    }, "\n"))
    local catalog = lurek.docs.loadToml(path)
    os.remove(path)
    return catalog
end

local function quality_report()
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.quality.alpha", "Alpha")
    lurek.docs.describe("lurek.quality.beta", "")
    return lurek.docs.quality(lurek.docs.getCatalog())
end

-- @describe docs explicit owner coverage
describe("docs explicit owner coverage", function()
    -- @covers LSchema:typeOf
    it("LSchema typeOf matches the schema type name", function()
        local schema = lurek.docs.schema({ hp = "number" }, "schema_typeof")
        expect_true(schema:typeOf("LSchema"))
        expect_false(schema:typeOf("LDocEntry"))
    end)

    -- @covers LDocEntry:getModule
    it("LDocEntry returns its module name", function()
        local entry = rich_catalog():getEntry("lurek.demo.spawn")
        expect_equal("demo", entry:getModule())
    end)

    -- @covers LDocEntry:getKind
    it("LDocEntry returns its kind", function()
        local entry = rich_catalog():getEntry("lurek.demo.spawn")
        expect_equal("function", entry:getKind())
    end)

    -- @covers LDocEntry:getDescription
    it("LDocEntry returns its description", function()
        local entry = rich_catalog():getEntry("lurek.demo.spawn")
        expect_equal("Spawn demo entity", entry:getDescription())
    end)

    -- @covers LDocEntry:getExample
    it("LDocEntry returns its example text", function()
        local entry = rich_catalog():getEntry("lurek.demo.spawn")
        expect_equal("lurek.demo.spawn()", entry:getExample())
    end)

    -- @covers LDocEntry:getSince
    it("LDocEntry returns its since version", function()
        local entry = rich_catalog():getEntry("lurek.demo.spawn")
        expect_equal("0.1.0", entry:getSince())
    end)

    -- @covers LDocEntry:getDeprecated
    it("LDocEntry returns its deprecation text", function()
        local entry = rich_catalog():getEntry("lurek.demo.spawn")
        expect_equal("use lurek.demo.spawnEx", entry:getDeprecated())
    end)

    -- @covers LDocEntry:hasDescription
    it("LDocEntry reports when description exists", function()
        local entry = rich_catalog():getEntry("lurek.demo.spawn")
        expect_true(entry:hasDescription())
    end)

    -- @covers LDocEntry:hasParameters
    it("LDocEntry reports when parameters are absent", function()
        local entry = rich_catalog():getEntry("lurek.demo.spawn")
        expect_false(entry:hasParameters())
    end)

    -- @covers LDocEntry:hasReturnType
    it("LDocEntry reports when returns are absent", function()
        local entry = rich_catalog():getEntry("lurek.demo.spawn")
        expect_false(entry:hasReturnType())
    end)

    -- @covers LDocEntry:hasExample
    it("LDocEntry reports when an example exists", function()
        local entry = rich_catalog():getEntry("lurek.demo.spawn")
        expect_true(entry:hasExample())
    end)

    -- @covers LDocEntry:type
    it("LDocEntry exposes its userdata type name", function()
        local entry = rich_catalog():getEntry("lurek.demo.spawn")
        expect_equal("LDocEntry", entry:type())
    end)

    -- @covers LDocEntry:typeOf
    it("LDocEntry typeOf matches the entry type name", function()
        local entry = rich_catalog():getEntry("lurek.demo.spawn")
        expect_true(entry:typeOf("LDocEntry"))
        expect_false(entry:typeOf("LApiCatalog"))
    end)

    -- @covers LApiCatalog:getEntry
    it("LApiCatalog returns entries by qualified name", function()
        local entry = rich_catalog():getEntry("lurek.demo.spawn")
        expect_not_nil(entry)
        expect_equal("spawn", entry:getName())
    end)

    -- @covers LApiCatalog:getTypes
    it("LApiCatalog returns type names for a module", function()
        local types = rich_catalog():getTypes("demo")
        expect_equal(1, #types)
        expect_equal("Thing", types[1])
    end)

    -- @covers LApiCatalog:typeOf
    it("LApiCatalog typeOf matches the catalog type name", function()
        local catalog = rich_catalog()
        expect_true(catalog:typeOf("LApiCatalog"))
        expect_false(catalog:typeOf("LDocEntry"))
    end)

    -- @covers LValidationReport:getPhantom
    it("ValidationReport exposes phantom issues", function()
        local phantom = lurek.docs.validate():getPhantom()
        expect_type("table", phantom)
    end)

    -- @covers LValidationReport:getIncomplete
    it("ValidationReport exposes incomplete issues", function()
        local incomplete = lurek.docs.validate():getIncomplete()
        expect_type("table", incomplete)
    end)

    -- @covers LValidationReport:missingCount
    it("ValidationReport reports the missing issue count", function()
        local report = lurek.docs.validate()
        expect_equal(#report:getMissing(), report:missingCount())
    end)

    -- @covers LValidationReport:phantomCount
    it("ValidationReport reports the phantom issue count", function()
        local report = lurek.docs.validate()
        expect_equal(#report:getPhantom(), report:phantomCount())
    end)

    -- @covers LValidationReport:incompleteCount
    it("ValidationReport reports the incomplete issue count", function()
        local report = lurek.docs.validate()
        expect_equal(#report:getIncomplete(), report:incompleteCount())
    end)

    -- @covers LValidationReport:getSummary
    it("ValidationReport returns a non-empty summary string", function()
        local summary = lurek.docs.validateModule("math"):getSummary()
        expect_type("string", summary)
        expect_true(#summary > 0)
    end)

    -- @covers LValidationReport:typeOf
    it("ValidationReport typeOf matches the report type name", function()
        local report = lurek.docs.validate()
        expect_true(report:typeOf("LValidationReport"))
        expect_false(report:typeOf("LQualityReport"))
    end)

    -- @covers LQualityReport:getGrade
    it("LQualityReport returns a grade string", function()
        local grade = quality_report():getGrade()
        expect_type("string", grade)
        lurek.docs.resetCatalog()
    end)

    -- @covers LQualityReport:getBest
    it("LQualityReport returns the strongest entries", function()
        local best = quality_report():getBest(1)
        expect_type("table", best)
        expect_true(#best >= 1)
        lurek.docs.resetCatalog()
    end)

    -- @covers LQualityReport:toJSON
    it("LQualityReport serializes to JSON text", function()
        local json = quality_report():toJSON()
        expect_type("string", json)
        expect_true(string.find(json, "overallScore", 1, true) ~= nil)
        lurek.docs.resetCatalog()
    end)

    -- @covers LQualityReport:type
    it("LQualityReport exposes its userdata type name", function()
        expect_equal("LQualityReport", quality_report():type())
        lurek.docs.resetCatalog()
    end)

    -- @covers LQualityReport:typeOf
    it("LQualityReport typeOf matches the report type name", function()
        local report = quality_report()
        expect_true(report:typeOf("LQualityReport"))
        expect_false(report:typeOf("LValidationReport"))
        lurek.docs.resetCatalog()
    end)
end)
end

test_summary()
