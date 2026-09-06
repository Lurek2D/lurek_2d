-- content/examples/grep.lua
-- Smoke-optimized grep examples with per-block fixtures.

--@api: lurek.grep.newEngine
do
    local root = "save/_grep_example_new_engine"
    local search = root .. "/search"
    lurek.filesystem.createDirectory(root)
    lurek.filesystem.createDirectory(search)
    lurek.filesystem.write(search .. "/alpha.lua", "local needle = 'alpha'\nprint('needle alpha')\n")
    lurek.filesystem.write(search .. "/beta.lua", "local needle = 'beta'\n")
    local engine = lurek.grep.newEngine()
    local result = engine:search(search, "needle")
    lurek.log.info("newEngine files=" .. result.files_searched .. " total_matches=" .. result.total_matches)
end

--@api: lurek.grep.newEngineOpts
do
    local root = "save/_grep_example_new_engine_opts"
    local search = root .. "/search"
    lurek.filesystem.createDirectory(root)
    lurek.filesystem.createDirectory(search)
    lurek.filesystem.write(search .. "/alpha.lua", "local needle = 'alpha'\nprint('needle alpha')\n")
    lurek.filesystem.write(search .. "/beta.lua", "local needle = 'beta'\n")
    local engine = lurek.grep.newEngineOpts({ threads = 2, case_sensitive = true, whole_word = false, max_file_size = 4096 })
    local result = engine:search(search, "needle")
    lurek.log.info("newEngineOpts matched_files=" .. result.files_matched .. " total_matches=" .. result.total_matches)
end

--@api: lurek.grep.newFilter
do
    local filter = lurek.grep.newFilter()
    filter:addExtension("lua")
    filter:excludeExtension("txt")
    filter:excludePattern("vendor")
    filter:setIncludeHidden(false)
    lurek.log.info("newFilter configured for lua files without txt or vendor paths")
end

--@api: lurek.grep.luaFilter
do
    local root = "save/_grep_example_lua_filter"
    local search = root .. "/search"
    lurek.filesystem.createDirectory(root)
    lurek.filesystem.createDirectory(search)
    lurek.filesystem.write(search .. "/alpha.lua", "local needle = 'alpha'\nprint('needle alpha')\n")
    lurek.filesystem.write(search .. "/notes.txt", "needle in text file\n")
    local filter = lurek.grep.luaFilter()
    filter:excludePattern("notes")
    local result = lurek.grep.newEngine():searchExt(search, "needle", { "lua" })
    lurek.log.info("luaFilter companion search matched=" .. result.total_matches .. " across " .. result.files_searched .. " files")
end

--@api: lurek.grep.search
do
    local root = "save/_grep_example_search"
    local search = root .. "/search"
    local forbidden = "save/_grep_example_search_forbidden"
    lurek.filesystem.createDirectory(root)
    lurek.filesystem.createDirectory(search)
    lurek.filesystem.createDirectory(forbidden)
    lurek.filesystem.write(search .. "/alpha.lua", "local needle = 'alpha'\nprint('needle alpha')\n")
    lurek.filesystem.write(search .. "/beta.lua", "local needle = 'beta'\n")
    lurek.filesystem.write(forbidden .. "/forbidden.lua", "needle outside sandbox\n")
    local root_abs = lurek.filesystem.getSaveDirectory() .. "/_grep_example_search"
    local mod = lurek.mods.newMod({
        id = "grep_runtime_example",
        sandbox = {
            api_mode = "allow_list",
            apis = { "grep" },
            hook_mode = "allow_list",
            hooks = { "on_load" },
            read_mode = "allow_list",
            read_roots = { root_abs },
        },
    })
    mod:setHook("on_load", function()
        local allowed = lurek.grep.search(search, "needle")
        local blocked_ok = pcall(function()
            lurek.grep.search(forbidden, "needle")
        end)
        return allowed, blocked_ok
    end)
    local result, blocked_ok = mod:runHook("on_load")
    local first = result.matches[1]
    lurek.log.info("search files=" .. result.files_searched .. " matched=" .. result.files_matched .. " first_path=" .. tostring(first and first.path or "nil"))
    lurek.log.info("sandbox blocked forbidden dir=" .. tostring(not blocked_ok))
end

--@api: lurek.grep.jsonSearch
do
    local root = "save/_grep_example_json"
    local json = root .. "/sample.json"
    lurek.filesystem.createDirectory(root)
    lurek.filesystem.write(json, [[
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
]])
    local result = lurek.grep.jsonSearch(json, "kind")
    local first = result[1]
    local third = result[3]
    lurek.log.info("jsonSearch hits=" .. #result .. " first=" .. tostring(first and first.value or "nil") .. " third=" .. tostring(third and third.value or "nil"))
end

--@api: lurek.grep.logSearch
do
    local root = "save/_grep_example_log"
    local log_path = root .. "/sample.log"
    lurek.filesystem.createDirectory(root)
    lurek.filesystem.write(log_path, "[INFO] boot\n[ERROR] panic: sample failure\n[WARN] recoverable issue\n")
    local result = lurek.grep.logSearch(log_path, "ERROR", "panic")
    local first = result[1]
    lurek.log.info("logSearch hits=" .. #result .. " level=" .. tostring(first and first.level or "nil") .. " line=" .. tostring(first and first.line or -1))
end

--@api: LFileFilter:addExtension
do
    local filter = lurek.grep.newFilter()
    filter:addExtension("lua")
    filter:addExtension("toml")
    filter:excludePattern("vendor")
    filter:setIncludeHidden(false)
    lurek.log.info("LFileFilter:addExtension added lua and toml include rules")
end

--@api: LFileFilter:excludeExtension
do
    local filter = lurek.grep.newFilter()
    filter:addExtension("lua")
    filter:excludeExtension("txt")
    filter:excludePattern("notes")
    filter:setIncludeHidden(false)
    lurek.log.info("LFileFilter:excludeExtension configured txt exclusion")
end

--@api: LFileFilter:excludePattern
do
    local filter = lurek.grep.newFilter()
    filter:addExtension("lua")
    filter:excludePattern("notes")
    filter:excludePattern("vendor")
    filter:setIncludeHidden(false)
    lurek.log.info("LFileFilter:excludePattern configured notes/vendor path exclusions")
end

--@api: LFileFilter:setIncludeHidden
do
    local filter = lurek.grep.newFilter()
    filter:addExtension("lua")
    filter:setIncludeHidden(true)
    filter:setIncludeHidden(false)
    filter:excludePattern(".git")
    lurek.log.info("LFileFilter:setIncludeHidden toggled hidden file scanning")
end

--@api: LGrepEngine:search
do
    local root = "save/_grep_engine_example"
    local search = root .. "/search"
    local forbidden = "save/_grep_engine_example_forbidden"
    lurek.filesystem.createDirectory(root)
    lurek.filesystem.createDirectory(search)
    lurek.filesystem.createDirectory(forbidden)
    lurek.filesystem.write(search .. "/alpha.lua", "local needle = 'alpha'\n")
    lurek.filesystem.write(search .. "/beta.lua", "local needle = 'beta'\n")
    lurek.filesystem.write(forbidden .. "/forbidden.lua", "needle outside sandbox\n")
    local root_abs = lurek.filesystem.getSaveDirectory() .. "/_grep_engine_example"
    local mod = lurek.mods.newMod({
        id = "grep_engine_runtime_example",
        sandbox = {
            api_mode = "allow_list",
            apis = { "grep" },
            hook_mode = "allow_list",
            hooks = { "on_load" },
            read_mode = "allow_list",
            read_roots = { root_abs },
        },
    })
    mod:setHook("on_load", function()
        local engine = lurek.grep.newEngine()
        local allowed = engine:search(search, "needle")
        local blocked_ok = pcall(function()
            engine:search(forbidden, "needle")
        end)
        return allowed, blocked_ok
    end)
    local result, blocked_ok = mod:runHook("on_load")
    local first = result.matches[1]
    lurek.log.info("LGrepEngine:search files=" .. result.files_searched .. " total=" .. result.total_matches .. " first_path=" .. tostring(first and first.path or "nil"))
    lurek.log.info("LGrepEngine:search sandbox blocked forbidden dir=" .. tostring(not blocked_ok))
end

--@api: LGrepEngine:searchExt
do
    local root = "save/_grep_engine_search_ext"
    local search = root .. "/search"
    lurek.filesystem.createDirectory(root)
    lurek.filesystem.createDirectory(search)
    lurek.filesystem.write(search .. "/alpha.lua", "local needle = 'alpha'\nprint('needle alpha')\n")
    lurek.filesystem.write(search .. "/notes.txt", "needle in text file\n")
    local result = lurek.grep.newEngine():searchExt(search, "needle", { "lua" })
    lurek.log.info("LGrepEngine:searchExt files=" .. result.files_searched .. " matched=" .. result.files_matched .. " total=" .. result.total_matches)
end

--@api: LGrepEngine:multiSearch
do
    local root = "save/_grep_engine_multi_search"
    local search = root .. "/search"
    lurek.filesystem.createDirectory(root)
    lurek.filesystem.createDirectory(search)
    lurek.filesystem.write(search .. "/alpha.lua", "local needle = 'alpha'\nlocal other = 'ally'\n")
    lurek.filesystem.write(search .. "/beta.lua", "local needle = 'beta'\n")
    local result = lurek.grep.newEngine():multiSearch(search, { "needle", "other" })
    local first = result.matches[1]
    lurek.log.info("LGrepEngine:multiSearch files=" .. result.files_searched .. " total=" .. result.total_matches .. " first_path=" .. tostring(first and first.path or "nil"))
end

--@api: LGrepEngine:count
do
    local root = "save/_grep_engine_count"
    local search = root .. "/search"
    lurek.filesystem.createDirectory(root)
    lurek.filesystem.createDirectory(search)
    lurek.filesystem.write(search .. "/alpha.lua", "local needle = 'alpha'\nprint('needle alpha')\n")
    lurek.filesystem.write(search .. "/beta.lua", "local needle = 'beta'\n")
    local engine = lurek.grep.newEngine()
    local count = engine:count(search, "needle")
    local files = engine:search(search, "needle").files_searched
    lurek.log.info("LGrepEngine:count total=" .. count .. " files=" .. files)
end

--@api: LGrepEngine:searchFiles
do
    local root = "save/_grep_engine_search_files"
    local search = root .. "/search"
    local alpha = search .. "/alpha.lua"
    local beta = search .. "/beta.lua"
    lurek.filesystem.createDirectory(root)
    lurek.filesystem.createDirectory(search)
    lurek.filesystem.write(alpha, "local needle = 'alpha'\nprint('needle alpha')\n")
    lurek.filesystem.write(beta, "local needle = 'beta'\n")
    local result = lurek.grep.newEngine():searchFiles({ alpha, beta }, "needle")
    local first = result.matches[1]
    lurek.log.info("LGrepEngine:searchFiles files=" .. result.files_searched .. " total=" .. result.total_matches .. " first=" .. tostring(first and first.path or "nil"))
end
