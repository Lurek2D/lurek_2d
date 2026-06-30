-- content/examples/grep.lua
-- Run: cargo run -- content/examples/grep.lua



-- =======================================================================
-- Lurek2D Example: Grep
-- =======================================================================
-- Demonstrates grep engine usage for scripted content audits, JSON scans,
-- and log inspection over fixture files created under work/grep_example.
-- =======================================================================

--@api: lurek.grep.newEngine
do

    local root = "work/grep_unit"
    local paths = {
        root = root,
        search = root .. "/search",
        alpha = root .. "/search/alpha.lua",
        beta = root .. "/search/beta.lua",
        notes = root .. "/search/notes.txt",
        json = root .. "/sample.json",
        log = root .. "/sample.log",
    }
    local engine = lurek.grep.newEngine()
    local result = engine:search(paths.search, "needle")
    local total = result.total_matches
    local files = result.files_searched
    lurek.log.info("newEngine files=" .. files .. " total_matches=" .. total)
end

--@api: lurek.grep.newEngineOpts
do

    local root = "work/grep_unit"
    local paths = {
        root = root,
        search = root .. "/search",
        alpha = root .. "/search/alpha.lua",
        beta = root .. "/search/beta.lua",
        notes = root .. "/search/notes.txt",
        json = root .. "/sample.json",
        log = root .. "/sample.log",
    }
    local opts = { threads = 2, case_sensitive = true, whole_word = false, max_file_size = 4096 }
    local engine = lurek.grep.newEngineOpts(opts)
    local result = engine:search(paths.search, "needle")
    local matched = result.files_matched
    local total = result.total_matches
    lurek.log.info("newEngineOpts matched_files=" .. matched .. " total_matches=" .. total)
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

    local filter = lurek.grep.luaFilter()
    filter:excludePattern("notes")
    filter:setIncludeHidden(false)
    local engine = lurek.grep.newEngine()
    local root = "work/grep_unit"
    local paths = {
        root = root,
        search = root .. "/search",
        alpha = root .. "/search/alpha.lua",
        beta = root .. "/search/beta.lua",
        notes = root .. "/search/notes.txt",
        json = root .. "/sample.json",
        log = root .. "/sample.log",
    }
    local result = engine:searchExt(paths.search, "needle", { "lua" })
    lurek.log.info("luaFilter companion search matched=" .. result.total_matches .. " across " .. result.files_searched .. " files")
end

--@api: lurek.grep.search
do

    local root = "save/_grep_example"
    local paths = {
        root = root,
        search = root .. "/search",
        alpha = root .. "/search/alpha.lua",
        beta = root .. "/search/beta.lua",
    }
    if not lurek.filesystem.exists(root) then
        lurek.filesystem.createDirectory(root)
    end
    if not lurek.filesystem.exists(paths.search) then
        lurek.filesystem.createDirectory(paths.search)
    end
    lurek.filesystem.write(paths.alpha, "local needle = 'alpha'\nprint('needle alpha')\n")
    lurek.filesystem.write(paths.beta, "local needle = 'beta'\n")

    local root_abs = lurek.filesystem.getSaveDirectory() .. "/_grep_example"
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
        local allowed = lurek.grep.search(paths.search, "needle")
        local blocked_ok = pcall(function()
            lurek.grep.search("content/examples", "needle")
        end)
        return allowed, blocked_ok
    end)

    local result, blocked_ok = mod:runHook("on_load")
    local first = result.matches[1]
    local path = first and first.path or "nil"
    lurek.log.info("search files=" .. result.files_searched .. " matched=" .. result.files_matched .. " first_path=" .. tostring(path))
    lurek.log.info("sandbox blocked content/examples=" .. tostring(not blocked_ok))
end

--@api: lurek.grep.jsonSearch
do

    local root = "work/grep_unit"
    local paths = {
        root = root,
        search = root .. "/search",
        alpha = root .. "/search/alpha.lua",
        beta = root .. "/search/beta.lua",
        notes = root .. "/search/notes.txt",
        json = root .. "/sample.json",
        log = root .. "/sample.log",
    }
    local result = lurek.grep.jsonSearch(paths.json, "kind")
    local first = result[1]
    local third = result[3]
    local first_value = first and first.value or "nil"
    local third_value = third and third.value or "nil"
    lurek.log.info("jsonSearch hits=" .. #result .. " first=" .. first_value .. " third=" .. third_value)
end

--@api: lurek.grep.logSearch
do

    local root = "work/grep_unit"
    local paths = {
        root = root,
        search = root .. "/search",
        alpha = root .. "/search/alpha.lua",
        beta = root .. "/search/beta.lua",
        notes = root .. "/search/notes.txt",
        json = root .. "/sample.json",
        log = root .. "/sample.log",
    }
    local result = lurek.grep.logSearch(paths.log, "ERROR", "panic")
    local first = result[1]
    local level = first and first.level or "nil"
    local line = first and first.line or -1
    lurek.log.info("logSearch hits=" .. #result .. " level=" .. tostring(level) .. " line=" .. tostring(line))
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
    local paths = {
        root = root,
        search = root .. "/search",
        alpha = root .. "/search/alpha.lua",
        beta = root .. "/search/beta.lua",
    }
    if not lurek.filesystem.exists(root) then
        lurek.filesystem.createDirectory(root)
    end
    if not lurek.filesystem.exists(paths.search) then
        lurek.filesystem.createDirectory(paths.search)
    end
    lurek.filesystem.write(paths.alpha, "local needle = 'alpha'\n")
    lurek.filesystem.write(paths.beta, "local needle = 'beta'\n")

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
        local allowed = engine:search(paths.search, "needle")
        local blocked_ok = pcall(function()
            engine:search("content/examples", "needle")
        end)
        return allowed, blocked_ok
    end)

    local result, blocked_ok = mod:runHook("on_load")
    local first = result.matches[1]
    local path = first and first.path or "nil"
    lurek.log.info("LGrepEngine:search files=" .. result.files_searched .. " total=" .. result.total_matches .. " first_path=" .. tostring(path))
    lurek.log.info("LGrepEngine:search sandbox blocked content/examples=" .. tostring(not blocked_ok))
end

--@api: LGrepEngine:searchExt
do

    local root = "work/grep_unit"
    local paths = {
        root = root,
        search = root .. "/search",
        alpha = root .. "/search/alpha.lua",
        beta = root .. "/search/beta.lua",
        notes = root .. "/search/notes.txt",
        json = root .. "/sample.json",
        log = root .. "/sample.log",
    }
    local engine = lurek.grep.newEngine()
    local result = engine:searchExt(paths.search, "needle", { "lua" })
    local total = result.total_matches
    local files = result.files_searched
    local matched = result.files_matched
    lurek.log.info("LGrepEngine:searchExt files=" .. files .. " matched=" .. matched .. " total=" .. total)
end

--@api: LGrepEngine:multiSearch
do

    local root = "work/grep_unit"
    local paths = {
        root = root,
        search = root .. "/search",
        alpha = root .. "/search/alpha.lua",
        beta = root .. "/search/beta.lua",
        notes = root .. "/search/notes.txt",
        json = root .. "/sample.json",
        log = root .. "/sample.log",
    }
    local engine = lurek.grep.newEngine()
    local result = engine:multiSearch(paths.search, { "needle", "other" })
    local first = result.matches[1]
    local path = first and first.path or "nil"
    lurek.log.info("LGrepEngine:multiSearch files=" .. result.files_searched .. " total=" .. result.total_matches .. " first_path=" .. tostring(path))
end

--@api: LGrepEngine:count
do

    local root = "work/grep_unit"
    local paths = {
        root = root,
        search = root .. "/search",
        alpha = root .. "/search/alpha.lua",
        beta = root .. "/search/beta.lua",
        notes = root .. "/search/notes.txt",
        json = root .. "/sample.json",
        log = root .. "/sample.log",
    }
    local engine = lurek.grep.newEngine()
    local count = engine:count(paths.search, "needle")
    local search = engine:search(paths.search, "needle")
    local files = search.files_searched
    lurek.log.info("LGrepEngine:count total=" .. count .. " files=" .. files)
end

--@api: LGrepEngine:searchFiles
do

    local root = "work/grep_unit"
    local paths = {
        root = root,
        search = root .. "/search",
        alpha = root .. "/search/alpha.lua",
        beta = root .. "/search/beta.lua",
        notes = root .. "/search/notes.txt",
        json = root .. "/sample.json",
        log = root .. "/sample.log",
    }
    local engine = lurek.grep.newEngine()
    local result = engine:searchFiles({ paths.alpha, paths.beta }, "needle")
    local first = result.matches[1]
    local path = first and first.path or "nil"
    lurek.log.info("LGrepEngine:searchFiles files=" .. result.files_searched .. " total=" .. result.total_matches .. " first=" .. tostring(path))
end
