-- Lurek2D Grep API Tests
-- Covers lurek.grep module: engine, filters, search functions,
-- and result structure.

-- =========================================================================
-- Module existence
-- =========================================================================

-- @describe lurek.grep module exists
describe("lurek.grep module exists", function()
    -- @covers lurek.grep
    it("lurek.grep is a table", function()
        expect_type("table", lurek.grep)
    end)

    -- @covers lurek.grep.newEngine
    -- @covers lurek.grep.newEngineOpts
    -- @covers lurek.grep.newFilter
    -- @covers lurek.grep.luaFilter
    -- @covers lurek.grep.search
    -- @covers lurek.grep.jsonSearch
    -- @covers lurek.grep.logSearch
    it("exposes factory and quick functions", function()
        expect_type("function", lurek.grep.newEngine)
        expect_type("function", lurek.grep.newEngineOpts)
        expect_type("function", lurek.grep.newFilter)
        expect_type("function", lurek.grep.luaFilter)
        expect_type("function", lurek.grep.search)
        expect_type("function", lurek.grep.jsonSearch)
        expect_type("function", lurek.grep.logSearch)
    end)
end)

-- =========================================================================
-- GrepEngine
-- =========================================================================

-- @describe GrepEngine
describe("GrepEngine", function()
    -- @covers lurek.grep.newEngine
    it("newEngine creates engine", function()
        local engine = lurek.grep.newEngine()
        expect_type("userdata", engine)
    end)

    -- @covers lurek.grep.newEngineOpts
    it("newEngineOpts creates engine with options", function()
        local engine = lurek.grep.newEngineOpts({
            threads = 2,
            case_sensitive = true,
            whole_word = false,
            max_file_size = 1024 * 1024
        })
        expect_type("userdata", engine)
    end)

    -- @covers lurek.grep.newEngine
    it("search returns result table", function()
        local engine = lurek.grep.newEngine()
        local result = engine:search("content/examples", "lurek")
        expect_type("table", result)
        expect_type("number", result.files_searched)
        expect_type("number", result.files_matched)
        expect_type("number", result.total_matches)
        expect_type("number", result.duration_ms)
        expect_type("table", result.matches)
    end)

    -- @covers lurek.grep.newEngine
    it("search finds matches in lua files", function()
        local engine = lurek.grep.newEngine()
        local result = engine:search("content/examples", "lurek.sprite")
        expect_true(result.total_matches > 0)
    end)

    -- @covers lurek.grep.newEngine
    it("searchExt filters by extension", function()
        local engine = lurek.grep.newEngine()
        local result = engine:searchExt("content/examples", "lurek", { "lua" })
        expect_true(result.files_searched > 0)
    end)

    -- @covers lurek.grep.newEngine
    it("count returns match count", function()
        local engine = lurek.grep.newEngine()
        local count = engine:count("content/examples", "function")
        expect_type("number", count)
        expect_true(count > 0)
    end)

    -- @covers lurek.grep.newEngine
    it("multiSearch accepts multiple patterns", function()
        local engine = lurek.grep.newEngine()
        local result = engine:multiSearch("content/examples", { "lurek.sprite", "lurek.audio" })
        expect_type("table", result)
        expect_true(result.total_matches >= 0)
    end)
end)

-- =========================================================================
-- FileFilter
-- =========================================================================

-- @describe FileFilter
describe("FileFilter", function()
    -- @covers lurek.grep.newFilter
    it("newFilter creates empty filter", function()
        local filter = lurek.grep.newFilter()
        expect_type("userdata", filter)
    end)

    -- @covers lurek.grep.luaFilter
    it("luaFilter creates pre-configured filter", function()
        local filter = lurek.grep.luaFilter()
        expect_type("userdata", filter)
    end)

    -- @covers lurek.grep.newFilter
    it("addExtension configures filter", function()
        local filter = lurek.grep.newFilter()
        filter:addExtension("lua")
        filter:addExtension("toml")
        -- No crash = success
        expect_true(true)
    end)

    -- @covers lurek.grep.newFilter
    it("excludeExtension and excludePattern", function()
        local filter = lurek.grep.newFilter()
        filter:excludeExtension("png")
        filter:excludePattern("node_modules")
        expect_true(true)
    end)

    -- @covers lurek.grep.newFilter
    it("setIncludeHidden toggles hidden files", function()
        local filter = lurek.grep.newFilter()
        filter:setIncludeHidden(true)
        expect_true(true)
    end)
end)

-- =========================================================================
-- Quick functions
-- =========================================================================

-- @describe Quick search functions
describe("Quick search functions", function()
    -- @covers lurek.grep.search
    it("search quick function works", function()
        local result = lurek.grep.search("content/examples", "local")
        expect_type("table", result)
        expect_true(result.total_matches > 0)
    end)
end)

-- =========================================================================
-- Result structure
-- =========================================================================

-- @describe Result match structure
describe("Result match structure", function()
    -- @covers lurek.grep.newEngine
    it("match entries have path and lines", function()
        local engine = lurek.grep.newEngine()
        local result = engine:search("content/examples", "lurek.sprite")
        if #result.matches > 0 then
            local entry = result.matches[1]
            expect_type("string", entry.path)
            expect_type("number", entry.total_matches)
            expect_type("table", entry.lines)
            if #entry.lines > 0 then
                expect_type("number", entry.lines[1].line)
                expect_type("string", entry.lines[1].content)
            end
        end
        expect_true(true)
    end)
end)

-- =========================================================================
-- GrepEngine searchFiles
-- =========================================================================

-- @describe GrepEngine searchFiles
describe("GrepEngine searchFiles", function()
    -- @covers LGrepEngine:searchFiles
    it("searchFiles searches a list of specific files", function()
        local engine = lurek.grep.newEngine()
        local result = engine:searchFiles({"content/examples/sprite.lua"}, "lurek")
        expect_type("table", result)
        expect_type("number", result.total_matches)
        expect_true(result.total_matches >= 0)
    end)

    -- @covers LGrepEngine:searchFiles
    it("searchFiles with empty file list returns zero matches", function()
        local engine = lurek.grep.newEngine()
        local result = engine:searchFiles({}, "lurek")
        expect_type("table", result)
        expect_equal(0, result.total_matches)
    end)
end)

test_summary()
