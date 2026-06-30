-- Canonical unit coverage for lurek.grep.

local WORK_ROOT = "work/grep_unit"
local SEARCH_DIR = WORK_ROOT .. "/search"
local JSON_FILE = WORK_ROOT .. "/sample.json"
local LOG_FILE = WORK_ROOT .. "/sample.log"
local FILE_A = SEARCH_DIR .. "/alpha.lua"
local FILE_B = SEARCH_DIR .. "/beta.lua"
local FILE_C = SEARCH_DIR .. "/notes.txt"

local function write_fixtures()
    write_file(FILE_A, "local needle = 'alpha'\nprint('needle alpha')\n")
    write_file(FILE_B, "local other = 'beta'\nlocal needle = 'beta'\n")
    write_file(FILE_C, "needle in text file\n")
    write_file(
        JSON_FILE,
        [[
{
  "kind": "enemy",
  "nested": {
    "kind": "boss",
    "hp": 10
  },
  "items": [
    { "kind": "loot" }
  ]
}
]]
    )
    write_file(
        LOG_FILE,
        "[INFO] boot\n[ERROR] panic: sample failure\n[WARN] recoverable issue\n"
    )
end

local function new_engine()
    return lurek.grep.newEngine()
end

local function grep_sandbox_root_abs()
    return lurek.filesystem.getWorkingDirectory() .. "/" .. WORK_ROOT
end

local function new_grep_mod(hook)
    local mod = lurek.mods.newMod({
        id = "grep_sandbox_mod",
        sandbox = {
            api_mode = "allow_list",
            apis = { "grep" },
            hook_mode = "allow_list",
            hooks = { "on_load" },
            read_mode = "allow_list",
            read_roots = { grep_sandbox_root_abs() },
        },
    })
    mod:setHook("on_load", hook)
    return mod
end

-- @describe lurek.grep module
describe("lurek.grep module", function()
    before_each(function()
        write_fixtures()
    end)

    -- @covers lurek.grep.newEngine
    it("newEngine creates a grep engine userdata", function()
        expect_equal("userdata", type(new_engine()))
    end)

    -- @covers lurek.grep.newEngineOpts
    it("newEngineOpts creates a configured grep engine", function()
        local engine = lurek.grep.newEngineOpts({
            threads = 2,
            case_sensitive = true,
            whole_word = false,
            max_file_size = 4096,
        })
        expect_equal("userdata", type(engine))
    end)

    -- @covers lurek.grep.newFilter
    it("newFilter creates a file filter userdata", function()
        expect_equal("userdata", type(lurek.grep.newFilter()))
    end)

    -- @covers lurek.grep.luaFilter
    it("luaFilter creates a file filter userdata", function()
        expect_equal("userdata", type(lurek.grep.luaFilter()))
    end)

    -- @covers lurek.grep.search
    it("search returns logical paths and respects mod sandbox reads", function()
        local result = lurek.grep.search(SEARCH_DIR, "needle")
        expect_equal(3, result.files_searched)
        expect_equal(3, result.files_matched)
        expect_equal(4, result.total_matches)
        expect_equal(3, #result.matches)
        expect_contains(result.matches[1].path, SEARCH_DIR)
        expect_true(string.find(result.matches[1].path, lurek.filesystem.getWorkingDirectory(), 1, true) == nil)
        expect_type("table", result.matches[1].lines)

        local mod = new_grep_mod(function()
            local allowed = lurek.grep.search(SEARCH_DIR, "needle")
            local blocked_ok, blocked_err = pcall(function()
                return lurek.grep.search("content/examples", "needle")
            end)
            local first_path = allowed.matches[1] and allowed.matches[1].path or ""
            return first_path, blocked_ok, blocked_err
        end)

        local first_path, blocked_ok, blocked_err = mod:runHook("on_load")
        expect_contains(first_path, SEARCH_DIR)
        expect_false(blocked_ok)
        expect_not_nil(blocked_err)
    end)

    -- @covers lurek.grep.jsonSearch
    it("jsonSearch finds every matching key in a json document", function()
        local result = lurek.grep.jsonSearch(JSON_FILE, "kind")
        expect_equal(3, #result)
        expect_equal("enemy", result[1].value)
        expect_equal("kind", result[2].path)
    end)

    -- @covers lurek.grep.logSearch
    it("logSearch filters entries by level and message pattern", function()
        local result = lurek.grep.logSearch(LOG_FILE, "ERROR", "panic")
        expect_equal(1, #result)
        expect_equal(2, result[1].line)
        expect_equal("ERROR", result[1].level)
        expect_contains(result[1].message, "panic")
    end)
end)

-- @describe file filter methods
describe("grep file filter methods", function()
    -- @covers LFileFilter:addExtension
    it("addExtension accepts a file extension", function()
        local filter = lurek.grep.newFilter()
        expect_no_error(function()
            filter:addExtension("lua")
        end)
    end)

    -- @covers LFileFilter:excludeExtension
    it("excludeExtension accepts an extension to skip", function()
        local filter = lurek.grep.newFilter()
        expect_no_error(function()
            filter:excludeExtension("txt")
        end)
    end)

    -- @covers LFileFilter:excludePattern
    it("excludePattern accepts a path substring", function()
        local filter = lurek.grep.newFilter()
        expect_no_error(function()
            filter:excludePattern("vendor")
        end)
    end)

    -- @covers LFileFilter:setIncludeHidden
    it("setIncludeHidden accepts boolean toggles", function()
        local filter = lurek.grep.newFilter()
        expect_no_error(function()
            filter:setIncludeHidden(true)
            filter:setIncludeHidden(false)
        end)
    end)
end)

-- @describe grep engine methods
describe("grep engine methods", function()
    before_each(function()
        write_fixtures()
    end)

    -- @covers LGrepEngine:search
    it("search scans the provided directory for literal matches inside sandbox policy", function()
        local result = new_engine():search(SEARCH_DIR, "needle")
        expect_equal(3, result.files_searched)
        expect_equal(4, result.total_matches)
        expect_equal(3, #result.matches)
        expect_true(string.find(result.matches[1].path, lurek.filesystem.getWorkingDirectory(), 1, true) == nil)

        local mod = new_grep_mod(function()
            local engine = lurek.grep.newEngine()
            local allowed = engine:search(SEARCH_DIR, "needle")
            local blocked_ok, blocked_err = pcall(function()
                return engine:search("content/examples", "needle")
            end)
            local first_path = allowed.matches[1] and allowed.matches[1].path or ""
            return first_path, blocked_ok, blocked_err
        end)

        local first_path, blocked_ok, blocked_err = mod:runHook("on_load")
        expect_contains(first_path, SEARCH_DIR)
        expect_false(blocked_ok)
        expect_not_nil(blocked_err)
    end)

    -- @covers LGrepEngine:searchExt
    it("searchExt respects a supplied extension whitelist", function()
        local result = new_engine():searchExt(SEARCH_DIR, "needle", { "lua" })
        expect_equal(2, result.files_searched)
        expect_equal(3, result.total_matches)
    end)

    -- @covers LGrepEngine:multiSearch
    it("multiSearch aggregates multiple literal patterns", function()
        local result = new_engine():multiSearch(SEARCH_DIR, { "needle", "other" })
        expect_equal(3, result.files_searched)
        expect_equal(5, result.total_matches)
    end)

    -- @covers LGrepEngine:count
    it("count returns the total literal match count", function()
        expect_equal(4, new_engine():count(SEARCH_DIR, "needle"))
    end)

    -- @covers LGrepEngine:searchFiles
    it("searchFiles restricts scanning to the provided file list", function()
        local result = new_engine():searchFiles({ FILE_A }, "needle")
        expect_equal(1, result.files_searched)
        expect_equal(2, result.total_matches)
        expect_equal(FILE_A, result.matches[1].path)
        expect_true(string.find(result.matches[1].path, lurek.filesystem.getWorkingDirectory(), 1, true) == nil)
    end)
end)

test_summary()
