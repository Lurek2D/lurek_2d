local M = {
    id = "ui_layout",
    title = "UI Layout Studio",
    summary = "TOML layout tool",
    workspace = "layout",
    actions = {
        { id = "add-panel", label = "Add Panel", w = 98 },
        { id = "add-button", label = "Add Button", w = 110 },
        { id = "validate", label = "Validate", w = 92 },
        { id = "export-layout", label = "Export TOML", w = 122 },
    },
}

local function model(ctx)
    local state = ctx.editor_state.ui_layout
    if not state then
        state = {
            file = "content/layouts/apps/lurek_workbench_panel.toml",
            selected = "right_inspector",
            widgets = 18,
            theme = "workbench_dark",
        }
        ctx.editor_state.ui_layout = state
    end
    return state
end

function M.update(_ctx, _dt)
end

function M.draw(ctx, r, ui)
    local s = model(ctx)
    ui.text("UI Layout Studio", r.x + 24, r.y + 20, ui.color.text)
    ui.text("Dogfood editor for Lurek retained UI layouts and TOML theme tokens.", r.x + 24, r.y + 46, ui.color.muted)

    local x, y, w, h = r.x + 42, r.y + 94, r.w - 84, r.h - 138
    ui.rect(x, y, w, h, { 0.020, 0.024, 0.031, 1 })
    ui.rect_line(x, y, w, h, ui.color.line)
    ui.rect(x + 18, y + 18, w - 36, 38, { 0.055, 0.063, 0.075, 1 })
    ui.text("Preview: editor_shell.toml", x + 34, y + 28, ui.color.text)

    ui.rect(x + 18, y + 72, 190, h - 96, { 0.048, 0.055, 0.066, 1 })
    ui.text("Tree", x + 34, y + 90, ui.color.muted)
    ui.text("root", x + 42, y + 124, ui.color.text)
    ui.text("dock_panel", x + 58, y + 150, ui.color.muted)
    ui.text("tab_bar", x + 74, y + 176, ui.color.muted)
    ui.text("right_inspector", x + 74, y + 202, ui.color.accent2)

    ui.rect(x + 232, y + 72, w - 464, h - 96, { 0.060, 0.068, 0.082, 1 })
    ui.rect_line(x + 232, y + 72, w - 464, h - 96, ui.color.line)
    ui.rect(x + 260, y + 106, w - 520, 54, { 0.090, 0.105, 0.124, 1 })
    ui.rect(x + 260, y + 180, 156, 120, { 0.080, 0.093, 0.110, 1 })
    ui.rect(x + 436, y + 180, w - 696, 120, { 0.080, 0.093, 0.110, 1 })
    ui.text("Canvas preview", x + 260, y + 324, ui.color.muted)

    ui.rect(x + w - 210, y + 72, 192, h - 96, { 0.048, 0.055, 0.066, 1 })
    ui.text("Properties", x + w - 194, y + 90, ui.color.text)
    ui.text("id=" .. s.selected, x + w - 194, y + 126, ui.color.muted)
    ui.text("theme=" .. s.theme, x + w - 194, y + 152, ui.color.muted)
    ui.text("snap=8px", x + w - 194, y + 178, ui.color.muted)
end

function M.inspect(ctx)
    local s = model(ctx)
    return {
        { label = "Native API", value = "lurek.ui" },
        { label = "File", value = s.file },
        { label = "Selected", value = s.selected },
        { label = "Widgets", value = tostring(s.widgets) },
        { label = "Theme", value = s.theme },
        { label = "Grid", value = "8 px" },
    }
end

function M.export(ctx)
    local s = model(ctx)
    return string.format([=[# %s
type = "dock_panel"
id = "workbench_shell"

[[children]]
type = "panel"
id = "%s"
class = "inspector"
]=], s.file, s.selected)
end

return M
