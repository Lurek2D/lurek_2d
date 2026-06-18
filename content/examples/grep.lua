-- content/examples/grep.lua
-- Run: cargo run -- content/examples/grep.lua

local function grep_log(message)
    lurek.log.info("[grep] " .. message)
end

local function fixture_paths()
    local root = "work/grep_unit"
    return {
        root = root,
        search = root .. "/search",
        alpha = root .. "/search/alpha.lua",
        beta = root .. "/search/beta.lua",
        notes = root .. "/search/notes.txt",
        json = root .. "/sample.json",
        log = root .. "/sample.log",
    }
end

-- =======================================================================
-- Lurek2D Example: Grep
-- =======================================================================
-- Demonstrates grep engine usage for scripted content audits, JSON scans,
-- and log inspection over fixture files created under work/grep_example.
-- =======================================================================

--@api: lurek.grep.newEngine
do
    local paths = fixture_paths()
    local engine = lurek.grep.newEngine()
    local result = engine:search(paths.search, "needle")
    local total = result.total_matches
    local files = result.files_searched
    grep_log("newEngine files=" .. files .. " total_matches=" .. total)
end

--@api: lurek.grep.newEngineOpts
do
    local paths = fixture_paths()
    local opts = { threads = 2, case_sensitive = true, whole_word = false, max_file_size = 4096 }
    local engine = lurek.grep.newEngineOpts(opts)
    local result = engine:search(paths.search, "needle")
    local matched = result.files_matched
    local total = result.total_matches
    grep_log("newEngineOpts matched_files=" .. matched .. " total_matches=" .. total)
end

--@api: lurek.grep.newFilter
do
    local filter = lurek.grep.newFilter()
    filter:addExtension("lua")
    filter:excludeExtension("txt")
    filter:excludePattern("vendor")
    filter:setIncludeHidden(false)
    grep_log("newFilter configured for lua files without txt or vendor paths")
end

--@api: lurek.grep.luaFilter
do
    local filter = lurek.grep.luaFilter()
    filter:excludePattern("notes")
    filter:setIncludeHidden(false)
    local engine = lurek.grep.newEngine()
    local paths = fixture_paths()
    local result = engine:searchExt(paths.search, "needle", { "lua" })
    grep_log("luaFilter companion search matched=" .. result.total_matches .. " across " .. result.files_searched .. " files")
end

--@api: lurek.grep.search
do
    local paths = fixture_paths()
    local result = lurek.grep.search(paths.search, "needle")
    local first = result.matches[1]
    local line = first and first.lines and first.lines[1]
    local line_no = line and line.line or -1
    grep_log("search files=" .. result.files_searched .. " matched=" .. result.files_matched .. " first_line=" .. line_no)
end

--@api: lurek.grep.jsonSearch
do
    local paths = fixture_paths()
    local result = lurek.grep.jsonSearch(paths.json, "kind")
    local first = result[1]
    local third = result[3]
    local first_value = first and first.value or "nil"
    local third_value = third and third.value or "nil"
    grep_log("jsonSearch hits=" .. #result .. " first=" .. first_value .. " third=" .. third_value)
end

--@api: lurek.grep.logSearch
do
    local paths = fixture_paths()
    local result = lurek.grep.logSearch(paths.log, "ERROR", "panic")
    local first = result[1]
    local level = first and first.level or "nil"
    local line = first and first.line or -1
    grep_log("logSearch hits=" .. #result .. " level=" .. tostring(level) .. " line=" .. tostring(line))
end

--@api: LFileFilter:addExtension
do
    local filter = lurek.grep.newFilter()
    filter:addExtension("lua")
    filter:addExtension("toml")
    filter:excludePattern("vendor")
    filter:setIncludeHidden(false)
    grep_log("LFileFilter:addExtension added lua and toml include rules")
end

--@api: LFileFilter:excludeExtension
do
    local filter = lurek.grep.newFilter()
    filter:addExtension("lua")
    filter:excludeExtension("txt")
    filter:excludePattern("notes")
    filter:setIncludeHidden(false)
    grep_log("LFileFilter:excludeExtension configured txt exclusion")
end

--@api: LFileFilter:excludePattern
do
    local filter = lurek.grep.newFilter()
    filter:addExtension("lua")
    filter:excludePattern("notes")
    filter:excludePattern("vendor")
    filter:setIncludeHidden(false)
    grep_log("LFileFilter:excludePattern configured notes/vendor path exclusions")
end

--@api: LFileFilter:setIncludeHidden
do
    local filter = lurek.grep.newFilter()
    filter:addExtension("lua")
    filter:setIncludeHidden(true)
    filter:setIncludeHidden(false)
    filter:excludePattern(".git")
    grep_log("LFileFilter:setIncludeHidden toggled hidden file scanning")
end

--@api: LGrepEngine:search
do
    local paths = fixture_paths()
    local engine = lurek.grep.newEngine()
    local result = engine:search(paths.search, "needle")
    local first = result.matches[1]
    local path = first and first.path or "nil"
    grep_log("LGrepEngine:search files=" .. result.files_searched .. " total=" .. result.total_matches .. " first_path=" .. tostring(path))
end

--@api: LGrepEngine:searchExt
do
    local paths = fixture_paths()
    local engine = lurek.grep.newEngine()
    local result = engine:searchExt(paths.search, "needle", { "lua" })
    local total = result.total_matches
    local files = result.files_searched
    local matched = result.files_matched
    grep_log("LGrepEngine:searchExt files=" .. files .. " matched=" .. matched .. " total=" .. total)
end

--@api: LGrepEngine:multiSearch
do
    local paths = fixture_paths()
    local engine = lurek.grep.newEngine()
    local result = engine:multiSearch(paths.search, { "needle", "other" })
    local first = result.matches[1]
    local path = first and first.path or "nil"
    grep_log("LGrepEngine:multiSearch files=" .. result.files_searched .. " total=" .. result.total_matches .. " first_path=" .. tostring(path))
end

--@api: LGrepEngine:count
do
    local paths = fixture_paths()
    local engine = lurek.grep.newEngine()
    local count = engine:count(paths.search, "needle")
    local search = engine:search(paths.search, "needle")
    local files = search.files_searched
    grep_log("LGrepEngine:count total=" .. count .. " files=" .. files)
end

--@api: LGrepEngine:searchFiles
do
    local paths = fixture_paths()
    local engine = lurek.grep.newEngine()
    local result = engine:searchFiles({ paths.alpha, paths.beta }, "needle")
    local first = result.matches[1]
    local path = first and first.path or "nil"
    grep_log("LGrepEngine:searchFiles files=" .. result.files_searched .. " total=" .. result.total_matches .. " first=" .. tostring(path))
end
