local M = {}

local function make_project_tree()
    return {
        { kind = "folder", label = "content", depth = 0 },
        { kind = "folder", label = "assets", depth = 1 },
        { kind = "file", label = "particles/fire.toml", depth = 2 },
        { kind = "file", label = "maps/test_level.ltm", depth = 2 },
        { kind = "folder", label = "scripts", depth = 1 },
        { kind = "file", label = "main.lua", depth = 2 },
        { kind = "file", label = "player.lua", depth = 2 },
    }
end

local function default_logs()
    return {
        { level = "info", text = "Workbench shell booted" },
        { level = "info", text = "VS Code remains the Lua code editor" },
        { level = "warn", text = "Visual tools write config and generated snippets" },
    }
end

function M.create(registry)
    local overview = registry:get("overview")
    local tabs = { "overview" }
    return {
        registry = registry,
        active_editor = overview.id,
        active_sidebar = "editors",
        tabs = tabs,
        open = { overview = true },
        dirty = false,
        project_name = "No project selected",
        project_root = "Select a Lurek project folder",
        project_tree = make_project_tree(),
        logs = default_logs(),
        problems = {},
        mouse = { x = 0, y = 0, down = false },
        clock = 0,
        status = "Ready",
        command = "idle",
        viewport = { w = 1600, h = 900 },
        hit = {},
        editor_state = {},
        bottom_tab = "log",
    }
end

return M

