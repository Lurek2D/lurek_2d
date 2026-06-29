local M = {}

local DEFAULT_SAMPLE_PROJECT_ROOT = "data/sample_project"

local function normalize_path(path)
    path = tostring(path or ""):gsub("\\", "/")
    path = path:gsub("/+", "/")
    if #path > 1 and string.sub(path, -1) == "/" then
        path = string.sub(path, 1, -2)
    end
    return path
end

local function basename(path)
    path = tostring(path or ""):gsub("\\", "/")
    return (path:match("([^/]+)$")) or path
end

local function default_logs()
    return {
        { level = "info", text = "Workbench shell booted on lurek.ui" },
        { level = "info", text = "VS Code remains the Lua code editor" },
        { level = "info", text = "Particle Designer is the first real file-backed vertical slice" },
    }
end

local function ensure_tab(ctx, id)
    if ctx.open[id] then
        return
    end
    ctx.open[id] = true
    ctx.tabs[#ctx.tabs + 1] = id
end

local function command_result(status, log_text, level)
    return {
        status = status,
        log = log_text or status,
        level = level or "info",
    }
end

function M.create(registry, services, opts)
    opts = opts or {}
    local sample_project_root = normalize_path(opts.sample_project_root or DEFAULT_SAMPLE_PROJECT_ROOT)
    local overview = registry:get("overview")
    local ctx = {
        registry = registry,
        services = services,
        command_bus = services.commands,
        active_editor = overview.id,
        active_sidebar = "project",
        tabs = { overview.id },
        open = { overview = true },
        dirty = false,
        project_name = "Sample Project",
        project_root = sample_project_root,
        project_tree = {},
        project_needs_tree_refresh = true,
        logs = default_logs(),
        problems = {},
        clock = 0,
        status = "Booting workbench",
        command = "idle",
        viewport = { w = 1600, h = 900 },
        editor_state = {},
        bottom_tab = "log",
    }

    local function attach_active_document(document)
        if not document then
            ctx.dirty = false
            ctx.problems = {}
            return
        end
        ensure_tab(ctx, document.editor_id)
        ctx.active_editor = document.editor_id
        ctx.dirty = document.dirty or false
        ctx.problems = document.problems or {}
    end

    local function refresh_project(root, preferred_path)
        ctx.project_root = root
        ctx.project_name = basename(root)
        ctx.services.documents:set_project_root(root)
        ctx.services.projects:scan(root)
        ctx.project_tree = ctx.services.projects.entries
        ctx.project_needs_tree_refresh = true

        local active = ctx.services.documents:get_active()
        if preferred_path and lurek.filesystem.exists(preferred_path) then
            local document, error_message = ctx.services.documents:open(preferred_path)
            if not document then
                error(error_message)
            end
            attach_active_document(document)
            return document
        end

        if active and string.sub(active.path, 1, #root) == root then
            attach_active_document(active)
            return active
        end

        local particle_paths = ctx.services.projects:get_particle_paths()
        if #particle_paths > 0 then
            local document, error_message = ctx.services.documents:open(particle_paths[1])
            if not document then
                error(error_message)
            end
            attach_active_document(document)
            return document
        end

        attach_active_document(nil)
        return nil
    end

    ctx.command_bus:register("project.open_sample", function(payload)
        local document = refresh_project(sample_project_root, payload and payload.path)
        local suffix = document and (" and opened " .. (document.relative_path or document.path)) or ""
        return command_result("Loaded sample project", "Indexed " .. sample_project_root .. suffix)
    end)

    ctx.command_bus:register("project.rescan", function()
        local active = ctx.services.documents:get_active()
        local preferred = active and active.path or nil
        refresh_project(ctx.project_root, preferred)
        return command_result(
            "Project index refreshed",
            "Scanned " .. ctx.project_root .. " (" .. tostring(ctx.services.projects.file_count) .. " files)"
        )
    end)

    ctx.command_bus:register("document.open_path", function(payload)
        assert(payload and payload.path, "document.open_path requires a path")
        local document, error_message = ctx.services.documents:open(payload.path)
        if not document then
            error(error_message)
        end
        attach_active_document(document)
        return command_result(
            "Opened " .. (document.relative_path or document.path),
            "Active document is " .. (document.relative_path or document.path)
        )
    end)

    ctx.command_bus:register("document.save_active", function()
        local document, error_message = ctx.services.documents:save_active()
        if not document then
            error(error_message)
        end
        attach_active_document(document)
        return command_result(
            "Saved " .. (document.relative_path or document.path),
            "Wrote " .. (document.relative_path or document.path)
        )
    end)

    ctx.command_bus:register("document.reload_active", function()
        local document, error_message = ctx.services.documents:reload_active()
        if not document then
            error(error_message)
        end
        attach_active_document(document)
        return command_result(
            "Reloaded " .. (document.relative_path or document.path),
            "Reparsed " .. (document.relative_path or document.path)
        )
    end)

    ctx.command_bus:register("document.revert_active", function()
        local document, error_message = ctx.services.documents:revert_active()
        if not document then
            error(error_message)
        end
        attach_active_document(document)
        return command_result(
            "Reverted unsaved changes",
            "Restored " .. (document.relative_path or document.path) .. " from the last saved version"
        )
    end)

    ctx.command_bus:register("document.export_active", function()
        local document, error_message = ctx.services.documents:export_active()
        if not document then
            error(error_message)
        end
        attach_active_document(document)
        return command_result(
            "Exported loader snippet",
            "Wrote " .. tostring(document.export_path or "loader snippet")
        )
    end)

    ctx.command_bus:register("particle.apply_preset", function(payload)
        local active = ctx.services.documents:get_active()
        if not active or active.editor_id ~= "particle" then
            error("No active particle document")
        end
        local editor = registry:get("particle")
        local model = editor.preset_model(payload and payload.name or "")
        if not model then
            error("Unknown particle preset: " .. tostring(payload and payload.name))
        end
        local document, error_message = ctx.services.documents:mutate_active(function(current)
            current.model = model
        end)
        if not document then
            error(error_message)
        end
        attach_active_document(document)
        return command_result(
            "Applied " .. tostring(payload.name) .. " preset",
            "Updated " .. (document.relative_path or document.path) .. " from the " .. tostring(payload.name) .. " preset"
        )
    end)

    local ok, result = ctx.command_bus:dispatch("project.open_sample")
    if ok then
        ctx.status = result.status or "Loaded sample project"
        ctx.logs[#ctx.logs + 1] = {
            level = result.level or "info",
            text = result.log or result.status or "Loaded sample project",
        }
    else
        ctx.status = tostring(result)
        ctx.logs[#ctx.logs + 1] = {
            level = "error",
            text = tostring(result),
        }
    end

    return ctx
end

return M
