local M = {
    id = "particle",
    title = "Particle Designer",
    summary = "File-backed vertical slice",
    workspace = "preview",
    actions = {
        { id = "save-doc", label = "Save", w = 76 },
        { id = "reload-doc", label = "Reload", w = 82 },
        { id = "revert-doc", label = "Revert", w = 82 },
        { id = "export-snippet", label = "Export Lua", w = 104 },
        { id = "preset-fire", label = "Fire", w = 72 },
        { id = "preset-sparks", label = "Sparks", w = 86 },
    },
}

local CONTROL_SPECS = {
    { key = "max_particles", label = "Max particles", min = 16, max = 512, step = 1 },
    { key = "emission_rate", label = "Emission rate", min = 0, max = 120, step = 1 },
    { key = "lifetime_min", label = "Lifetime min", min = 0.05, max = 2.0, step = 0.05 },
    { key = "lifetime_max", label = "Lifetime max", min = 0.05, max = 3.0, step = 0.05 },
    { key = "speed_min", label = "Speed min", min = 0, max = 240, step = 1 },
    { key = "speed_max", label = "Speed max", min = 0, max = 360, step = 1 },
    { key = "direction", label = "Direction", min = -3.2, max = 3.2, step = 0.05 },
    { key = "spread", label = "Spread", min = 0, max = 3.2, step = 0.05 },
    { key = "gravity_y", label = "Gravity Y", min = -200, max = 400, step = 5 },
}

local DEFAULT_MODEL = {
    seed = 42,
    max_particles = 128,
    emission_rate = 22.0,
    lifetime_min = 0.25,
    lifetime_max = 0.85,
    speed_min = 32.0,
    speed_max = 140.0,
    direction = -1.5707964,
    spread = 0.62,
    gravity_x = 0.0,
    gravity_y = 88.0,
    sizes = { 9.0, 5.0, 1.5 },
    colors = {
        { 1.0, 0.72, 0.24, 0.95 },
        { 1.0, 0.28, 0.08, 0.35 },
        { 0.28, 0.05, 0.02, 0.0 },
    },
}

local PRESETS = {
    fire = DEFAULT_MODEL,
    sparks = {
        seed = 17,
        max_particles = 96,
        emission_rate = 48.0,
        lifetime_min = 0.08,
        lifetime_max = 0.24,
        speed_min = 90.0,
        speed_max = 210.0,
        direction = -1.5707964,
        spread = 1.2,
        gravity_x = 0.0,
        gravity_y = 160.0,
        sizes = { 4.0, 2.0, 0.5 },
        colors = {
            { 1.0, 0.9, 0.55, 1.0 },
            { 1.0, 0.55, 0.12, 0.55 },
            { 0.45, 0.12, 0.02, 0.0 },
        },
    },
}

local function clone(value)
    if type(value) ~= "table" then
        return value
    end
    local copy = {}
    for key, nested in pairs(value) do
        copy[key] = clone(nested)
    end
    return copy
end

local function normalize_path(path)
    path = tostring(path or ""):gsub("\\", "/")
    path = path:gsub("/+", "/")
    if #path > 1 and string.sub(path, -1) == "/" then
        path = string.sub(path, 1, -2)
    end
    return path
end

local function basename(path)
    return (normalize_path(path):match("([^/]+)$")) or normalize_path(path)
end

local function sanitize_identifier(path)
    local stem = basename(path):gsub("%.particle%.toml$", "")
    stem = stem:gsub("[^%w_]", "_")
    if stem == "" then
        return "particle_doc"
    end
    return stem
end

local function to_number(value, fallback)
    local parsed = tonumber(value)
    if parsed == nil then
        return fallback
    end
    return parsed
end

local function runtime_validate(model)
    local ok, system_or_error = pcall(function()
        return lurek.particle.newSystem(clone(model))
    end)
    if not ok then
        return false, tostring(system_or_error)
    end
    if system_or_error and system_or_error.release then
        pcall(function()
            system_or_error:release()
        end)
    end
    return true, nil
end

local function normalize_model(raw)
    raw = type(raw) == "table" and raw or {}
    local model = {
        seed = math.floor(to_number(raw.seed, DEFAULT_MODEL.seed)),
        max_particles = math.max(1, math.floor(to_number(raw.max_particles or raw.maxParticles, DEFAULT_MODEL.max_particles))),
        emission_rate = to_number(raw.emission_rate or raw.emissionRate, DEFAULT_MODEL.emission_rate),
        lifetime_min = to_number(raw.lifetime_min or raw.lifetimeMin, DEFAULT_MODEL.lifetime_min),
        lifetime_max = to_number(raw.lifetime_max or raw.lifetimeMax, DEFAULT_MODEL.lifetime_max),
        speed_min = to_number(raw.speed_min or raw.speedMin, DEFAULT_MODEL.speed_min),
        speed_max = to_number(raw.speed_max or raw.speedMax, DEFAULT_MODEL.speed_max),
        direction = to_number(raw.direction, DEFAULT_MODEL.direction),
        spread = to_number(raw.spread, DEFAULT_MODEL.spread),
        gravity_x = to_number(raw.gravity_x or raw.gravityX, DEFAULT_MODEL.gravity_x),
        gravity_y = to_number(raw.gravity_y or raw.gravityY, DEFAULT_MODEL.gravity_y),
        sizes = clone(raw.sizes or DEFAULT_MODEL.sizes),
        colors = clone(raw.colors or DEFAULT_MODEL.colors),
    }

    if type(model.sizes) ~= "table" or #model.sizes == 0 then
        model.sizes = clone(DEFAULT_MODEL.sizes)
    end
    if type(model.colors) ~= "table" or #model.colors == 0 then
        model.colors = clone(DEFAULT_MODEL.colors)
    end
    return model
end

local function active_document(ctx)
    local document = ctx.services.documents:get_active()
    if document and document.editor_id == M.id then
        return document
    end
    if ctx.active_editor == M.id then
        return ctx.services.documents:find_by_editor(M.id)
    end
    return nil
end

local function release_preview(document)
    if document.preview and document.preview.release then
        pcall(function()
            document.preview:release()
        end)
    end
    document.preview = nil
end

local function ensure_preview(document)
    if document.preview and document.preview_revision == document.revision then
        return document.preview
    end

    release_preview(document)
    local ok, preview_or_error = pcall(function()
        local preview = lurek.particle.newSystem(clone(document.model))
        preview:start()
        preview:warmUp(0.2)
        return preview
    end)
    if not ok then
        document.preview_error = tostring(preview_or_error)
        return nil
    end

    document.preview = preview_or_error
    document.preview_revision = document.revision
    document.preview_clock = 0
    document.preview_error = nil
    return document.preview
end

local function format_number(value)
    if math.abs(value - math.floor(value + 0.0001)) < 0.001 then
        return tostring(math.floor(value + 0.0001))
    end
    return string.format("%.2f", value)
end

local function export_text_for(document)
    local relative = document.relative_path or normalize_path(document.path)
    local identifier = sanitize_identifier(relative)
    return string.format([[local %s = lurek.particle.fromTOML(%q)
%s:setPosition(320, 220)
%s:start()
return %s
]], identifier, relative, identifier, identifier, identifier)
end

function M.matches_path(path)
    return normalize_path(path):match("%.particle%.toml$") ~= nil
end

function M.preset_model(name)
    local preset = PRESETS[name]
    if not preset then
        return nil
    end
    return clone(preset)
end

function M.create_document(path, source_text, project_root)
    local parsed = lurek.serialize.fromToml(source_text)
    local document = {
        path = normalize_path(path),
        relative_path = normalize_path(path),
        project_root = normalize_path(project_root),
        title = basename(path),
        model = normalize_model(parsed),
        export_path = nil,
        export_preview = "",
        preview = nil,
        preview_revision = -1,
        preview_clock = 0,
        preview_error = nil,
    }
    document.export_path = M.build_export(document, project_root).path
    document.export_preview = export_text_for(document)
    return document
end

function M.serialize_document(document, _project_root)
    document.export_preview = export_text_for(document)
    return lurek.serialize.toToml(clone(document.model))
end

function M.validate_document(document, _project_root)
    local problems = {}
    local model = document.model or {}
    if model.lifetime_min > model.lifetime_max then
        problems[#problems + 1] = "lifetime_min should stay <= lifetime_max"
    end
    if model.speed_min > model.speed_max then
        problems[#problems + 1] = "speed_min should stay <= speed_max"
    end
    if model.max_particles < 1 then
        problems[#problems + 1] = "max_particles must be at least 1"
    end
    if not model.colors or #model.colors < 2 then
        problems[#problems + 1] = "colors should include at least two keyframes"
    end
    local ok, runtime_error = runtime_validate(model)
    if not ok then
        problems[#problems + 1] = "Runtime preview rejected config: " .. tostring(runtime_error)
    end
    return problems
end

function M.build_export(document, project_root)
    project_root = normalize_path(project_root or "")
    local export_root = project_root ~= "" and (project_root .. "/content/snippets") or (normalize_path(document.path):match("^(.*)/[^/]+$") or "")
    local identifier = sanitize_identifier(document.relative_path or document.path)
    return {
        path = normalize_path(export_root .. "/" .. identifier .. "_particle.lua"),
        text = export_text_for(document),
    }
end

function M.handle_action(ctx, action_id)
    if action_id == "save-doc" then
        return ctx.command_bus:dispatch("document.save_active")
    end
    if action_id == "reload-doc" then
        return ctx.command_bus:dispatch("document.reload_active")
    end
    if action_id == "revert-doc" then
        return ctx.command_bus:dispatch("document.revert_active")
    end
    if action_id == "export-snippet" then
        return ctx.command_bus:dispatch("document.export_active")
    end
    if action_id == "preset-fire" then
        return ctx.command_bus:dispatch("particle.apply_preset", { name = "fire" })
    end
    if action_id == "preset-sparks" then
        return ctx.command_bus:dispatch("particle.apply_preset", { name = "sparks" })
    end
    return false, "Unknown particle action: " .. tostring(action_id)
end

function M.update(ctx, dt)
    local document = active_document(ctx)
    if not document then
        return
    end

    local preview = ensure_preview(document)
    if not preview then
        return
    end

    document.preview_clock = (document.preview_clock or 0) + (dt or 0)
    preview:update(dt or 0)
    if document.preview_clock > 3.0 or preview:isStopped() then
        preview:reset()
        preview:start()
        preview:warmUp(0.2)
        document.preview_clock = 0
    end
end

function M.draw(ctx, r, ui)
    local document = active_document(ctx)
    ui.text("Particle Designer", r.x + 24, r.y + 20, ui.color.text)
    ui.text("Real .particle.toml document slice using lurek.serialize, lurek.filesystem, and live lurek.particle preview.", r.x + 24, r.y + 46, ui.color.muted)

    if not document then
        ui.text("Select a .particle.toml file from the project tree to begin editing.", r.x + 24, r.y + 92, ui.color.warn)
        return
    end

    local preview_x = r.x + 28
    local preview_y = r.y + 88
    local preview_w = r.w - 56
    local preview_h = r.h - 150
    ui.rect(preview_x, preview_y, preview_w, preview_h, { 0.018, 0.021, 0.027, 1 })
    ui.rect_line(preview_x, preview_y, preview_w, preview_h, ui.color.line)
    ui.line(preview_x + 24, preview_y + preview_h * 0.68, preview_x + preview_w - 24, preview_y + preview_h * 0.68, { 0.12, 0.16, 0.19, 1 })
    ui.line(preview_x + preview_w * 0.5, preview_y + 24, preview_x + preview_w * 0.5, preview_y + preview_h - 24, { 0.12, 0.16, 0.19, 1 })

    local preview = ensure_preview(document)
    if preview then
        preview:moveTo(preview_x + preview_w * 0.5, preview_y + preview_h * 0.68)
        preview:render()
        local stats = preview:getStats()
        ui.text("live=" .. tostring(stats.live_particles) .. " rate=" .. format_number(document.model.emission_rate) .. " spread=" .. format_number(document.model.spread), preview_x + 18, preview_y + preview_h - 30, ui.color.muted)
    else
        ui.text(document.preview_error or "Preview unavailable for the current particle document.", preview_x + 18, preview_y + 18, ui.color.warn)
    end

    ui.text("file: " .. tostring(document.relative_path), preview_x, preview_y + preview_h + 18, ui.color.muted)
    if #document.problems > 0 then
        ui.text("validation: " .. tostring(document.problems[1]), preview_x, preview_y + preview_h + 40, ui.color.warn)
    else
        ui.text("validation: no active problems", preview_x, preview_y + preview_h + 40, ui.color.ok)
    end
end

function M.inspect(ctx)
    local document = active_document(ctx)
    if not document then
        return {
            { label = "Document", value = "No active particle document" },
            { label = "Preview", value = "Select a file from the project tree" },
        }
    end
    local export_path = document.export_path or M.build_export(document, ctx.project_root).path
    return {
        { label = "Document", value = document.relative_path },
        { label = "Dirty", value = tostring(document.dirty) },
        { label = "Export", value = export_path:gsub("\\", "/") },
        { label = "Seed", value = tostring(document.model.seed) },
        { label = "Warnings", value = tostring(#(document.problems or {})) },
    }
end

function M.export(ctx)
    local document = active_document(ctx)
    if not document then
        return "-- No active particle document"
    end
    return export_text_for(document)
end

function M.ensure_controls(shell)
    if shell:get_editor_widget(M.id, "doc_label") then
        return
    end

    local doc_label = shell:register_editor_widget(M.id, "doc_label", lurek.ui.newLabel("Particle document"))
    local export_label = shell:register_editor_widget(M.id, "export_label", lurek.ui.newLabel("Export path"))
    local note_label = shell:register_editor_widget(M.id, "note_label", lurek.ui.newLabel("Toolbar actions write files. Sliders update the live preview immediately."))
    note_label:setTextWrap(true)

    for _, spec in ipairs(CONTROL_SPECS) do
        local name_label = shell:register_editor_widget(M.id, spec.key .. "_name", lurek.ui.newLabel(spec.label))
        local value_label = shell:register_editor_widget(M.id, spec.key .. "_value", lurek.ui.newLabel(""))
        local slider = shell:register_editor_widget(M.id, spec.key .. "_slider", lurek.ui.newSlider(spec.min, spec.max))
        slider:setStep(spec.step)
        slider:setOnChange(function()
            if shell.suspend_editor_sync then
                return
            end
            local document = active_document(shell.ctx)
            if not document then
                return
            end
            local updated, error_message = shell.ctx.services.documents:mutate_active(function(current)
                local value = slider:getValue()
                if spec.key == "max_particles" then
                    current.model.max_particles = math.max(1, math.floor(value + 0.5))
                    return
                end
                current.model[spec.key] = value
                if spec.key == "lifetime_min" and current.model.lifetime_max < value then
                    current.model.lifetime_max = value
                end
                if spec.key == "lifetime_max" and current.model.lifetime_min > value then
                    current.model.lifetime_min = value
                end
                if spec.key == "speed_min" and current.model.speed_max < value then
                    current.model.speed_max = value
                end
                if spec.key == "speed_max" and current.model.speed_min > value then
                    current.model.speed_min = value
                end
            end)
            if updated then
                shell.ctx.status = "Updated " .. spec.label
                shell.ctx.problems = updated.problems or {}
                shell.ctx.dirty = updated.dirty or false
            else
                shell.ctx.status = tostring(error_message)
            end
        end)
        name_label:setTextWrap(true)
        value_label:setTextAlign("right")
    end

    doc_label:setTextWrap(true)
    export_label:setTextWrap(true)
end

function M.layout_controls(ctx, rect, shell)
    M.ensure_controls(shell)
    local document = active_document(ctx)
    if not document then
        shell:set_editor_widgets_visible(M.id, false)
        return
    end

    shell:set_editor_widgets_visible(M.id, true)
    shell.suspend_editor_sync = true

    local doc_label = shell:get_editor_widget(M.id, "doc_label")
    local export_label = shell:get_editor_widget(M.id, "export_label")
    local note_label = shell:get_editor_widget(M.id, "note_label")
    local export_path = document.export_path or M.build_export(document, ctx.project_root).path

    doc_label:setText("Document: " .. tostring(document.relative_path))
    export_label:setText("Export: " .. tostring(export_path))

    doc_label:setPosition(rect.x + 16, rect.y + 118)
    doc_label:setSize(rect.w - 32, 18)
    export_label:setPosition(rect.x + 16, rect.y + 136)
    export_label:setSize(rect.w - 32, 18)
    note_label:setPosition(rect.x + 16, rect.y + 156)
    note_label:setSize(rect.w - 32, 30)

    local row_y = rect.y + 196
    for _, spec in ipairs(CONTROL_SPECS) do
        local name_label = shell:get_editor_widget(M.id, spec.key .. "_name")
        local value_label = shell:get_editor_widget(M.id, spec.key .. "_value")
        local slider = shell:get_editor_widget(M.id, spec.key .. "_slider")
        local value = document.model[spec.key]

        name_label:setPosition(rect.x + 16, row_y)
        name_label:setSize(rect.w - 120, 18)
        value_label:setText(format_number(value))
        value_label:setPosition(rect.x + rect.w - 92, row_y)
        value_label:setSize(76, 18)
        slider:setPosition(rect.x + 16, row_y + 18)
        slider:setSize(rect.w - 32, 18)
        slider:setValue(value)
        row_y = row_y + 44
    end

    shell.suspend_editor_sync = false
end

return M
