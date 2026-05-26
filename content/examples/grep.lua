-- ==========================================================================
-- Lurek2D Example: Grep
-- ==========================================================================
-- Demonstrates text search engine for game content files with literal,
-- regex, glob, fuzzy, and multi-pattern parallel search.
--
-- Topics: grep engine, file filters, search, JSON search, log search.
-- ==========================================================================

-- Quick search (simplest usage)
--@api-stub: lurek.grep.newEngine
do
    local eng = lurek.grep.newEngine()
    print("engine created = " .. tostring(eng ~= nil))
end

--@api-stub: lurek.grep.newEngineOpts
do
    local opts = { case_sensitive = false, threads = 2, whole_word = false }
    local eng = lurek.grep.newEngineOpts(opts)
    print("engine with opts created = " .. tostring(eng ~= nil))
end

--@api-stub: lurek.grep.newFilter
do
    local fil = lurek.grep.newFilter()
    fil:addExtension("lua")
    print("filter created = " .. tostring(fil ~= nil))
end

--@api-stub: lurek.grep.luaFilter
do
    local fil = lurek.grep.luaFilter()
    print("lua filter created = " .. tostring(fil ~= nil))
end

--@api-stub: lurek.grep.search
do
    local results = lurek.grep.search("content/examples", "api-stub")
    print("files searched = " .. results.files_searched)
    print("total matches = " .. results.total_matches)
end

--@api-stub: lurek.grep.jsonSearch
do
    local results = lurek.grep.jsonSearch("content/examples", "api-stub")
    print("json results = " .. #results)
end

--@api-stub: lurek.grep.logSearch
do
    local results = lurek.grep.logSearch("logs/runtime.log", "ERROR", "panic")
    print("log results = " .. #results)
end

--@api-stub: LFileFilter:addExtension
do
    local fil = lurek.grep.newFilter()
    fil:addExtension("lua")
    fil:addExtension("toml")
    print("LFileFilter:addExtension ok")
end

--@api-stub: LFileFilter:excludeExtension
do
    local fil = lurek.grep.newFilter()
    fil:excludeExtension("min.lua")
    print("LFileFilter:excludeExtension ok")
end

--@api-stub: LFileFilter:excludePattern
do
    local fil = lurek.grep.newFilter()
    fil:excludePattern("test_")
    print("LFileFilter:excludePattern ok")
end

--@api-stub: LFileFilter:setIncludeHidden
do
    local fil = lurek.grep.newFilter()
    fil:setIncludeHidden(false)
    print("LFileFilter:setIncludeHidden ok")
end

--@api-stub: LGrepEngine:search
do
    local eng = lurek.grep.newEngine()
    local results = eng:search("content/examples", "api-stub")
    print("LGrepEngine:search files=" .. results.files_searched)
    print("LGrepEngine:search matches=" .. results.total_matches)
end

--@api-stub: LGrepEngine:searchExt
do
    local eng = lurek.grep.newEngine()
    local results = eng:searchExt("content/examples", "api-stub", { "lua" })
    print("LGrepEngine:searchExt files=" .. results.files_searched)
    print("LGrepEngine:searchExt matches=" .. results.total_matches)
end

--@api-stub: LGrepEngine:multiSearch
do
    local eng = lurek.grep.newEngine()
    local results = eng:multiSearch("content/examples", { "api-stub", "lurek.math" })
    print("LGrepEngine:multiSearch files=" .. results.files_searched)
    print("LGrepEngine:multiSearch matches=" .. results.total_matches)
end

--@api-stub: LGrepEngine:count
do
    local eng = lurek.grep.newEngine()
    local n = eng:count("content/examples", "api-stub")
    print("LGrepEngine:count=" .. n)
end

--@api-stub: LGrepEngine:searchFiles
do
    local eng = lurek.grep.newEngine()
    local results = eng:searchFiles({ "content/examples/grep.lua", "content/examples/font.lua" }, "api-stub")
    print("LGrepEngine:searchFiles files=" .. results.files_searched)
    print("LGrepEngine:searchFiles matches=" .. results.total_matches)
end
