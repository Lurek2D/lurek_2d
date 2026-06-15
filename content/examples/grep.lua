-- ==========================================================================
-- Lurek2D Example: Grep
-- ==========================================================================
-- Demonstrates text search engine for game content files with literal,
-- regex, glob, fuzzy, and multi-pattern parallel search.
--
-- Topics: grep engine, file filters, search, JSON search, log search.
-- ==========================================================================

-- Quick search (simplest usage)
--@api: lurek.grep.newEngine
do
    local eng = lurek.grep.newEngine()
    print("engine created = " .. tostring(eng ~= nil))
end

--@api: lurek.grep.newEngineOpts
do
    local opts = { case_sensitive = false, threads = 2, whole_word = false }
    local eng = lurek.grep.newEngineOpts(opts)
    print("engine with opts created = " .. tostring(eng ~= nil))
end

--@api: lurek.grep.newFilter
do
    local fil = lurek.grep.newFilter()
    fil:addExtension("lua")
    print("filter created = " .. tostring(fil ~= nil))
end

--@api: lurek.grep.luaFilter
do
    local fil = lurek.grep.luaFilter()
    print("lua filter created = " .. tostring(fil ~= nil))
end

--@api: lurek.grep.search
do
    local results = lurek.grep.search("content/examples", "lurek.math")
    print("files searched = " .. results.files_searched)
    print("total matches = " .. results.total_matches)
end

--@api: lurek.grep.jsonSearch
do
    local results = lurek.grep.jsonSearch("content/examples", "lurek.math")
    print("json results = " .. #results)
end

--@api: lurek.grep.logSearch
do
    local path = "save/grep_runtime.log"
    lurek.filesystem.write(path, "[INFO] boot\n[ERROR] panic: sample failure\n")
    local results = lurek.grep.logSearch(path, "ERROR", "panic")
    print("log results = " .. #results)
end

--@api: LFileFilter:addExtension
do
    local fil = lurek.grep.newFilter()
    fil:addExtension("lua")
    fil:addExtension("toml")
    print("LFileFilter:addExtension ok")
end

--@api: LFileFilter:excludeExtension
do
    local fil = lurek.grep.newFilter()
    fil:excludeExtension("min.lua")
    print("LFileFilter:excludeExtension ok")
end

--@api: LFileFilter:excludePattern
do
    local fil = lurek.grep.newFilter()
    fil:excludePattern("test_")
    print("LFileFilter:excludePattern ok")
end

--@api: LFileFilter:setIncludeHidden
do
    local fil = lurek.grep.newFilter()
    fil:setIncludeHidden(false)
    print("LFileFilter:setIncludeHidden ok")
end

--@api: LGrepEngine:search
do
    local eng = lurek.grep.newEngine()
    local ok, results = pcall(function() return eng:search("content/examples", "lurek.math") end)
    if ok then
        print("LGrepEngine:search files=" .. results.files_searched)
        print("LGrepEngine:search matches=" .. results.total_matches)
    else
        print("LGrepEngine:search skipped: " .. tostring(results))
    end
end

--@api: LGrepEngine:searchExt
do
    local eng = lurek.grep.newEngine()
    local ok, results = pcall(function() return eng:searchExt("content/examples", "lurek.math", { "lua" }) end)
    if ok then
        print("LGrepEngine:searchExt files=" .. results.files_searched)
        print("LGrepEngine:searchExt matches=" .. results.total_matches)
    else
        print("LGrepEngine:searchExt skipped: " .. tostring(results))
    end
end

--@api: LGrepEngine:multiSearch
do
    local eng = lurek.grep.newEngine()
    local results = eng:multiSearch("content/examples", { "lurek.math", "lurek.color" })
    print("LGrepEngine:multiSearch files=" .. results.files_searched)
    print("LGrepEngine:multiSearch matches=" .. results.total_matches)
end

--@api: LGrepEngine:count
do
    local eng = lurek.grep.newEngine()
    local n = eng:count("content/examples", "lurek.math")
    print("LGrepEngine:count=" .. n)
end

--@api: LGrepEngine:searchFiles
do
    local eng = lurek.grep.newEngine()
    local results = eng:searchFiles({ "content/examples/grep.lua", "content/examples/font.lua" }, "lurek.math")
    print("LGrepEngine:searchFiles files=" .. results.files_searched)
    print("LGrepEngine:searchFiles matches=" .. results.total_matches)
end
