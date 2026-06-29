local M = {
    id = "overview",
    title = "Workbench Home",
    summary = "Project hub",
    workspace = "dashboard",
    actions = {
        { id = "open-project", label = "Open Project", w = 118 },
        { id = "scan-assets", label = "Scan Assets", w = 112 },
        { id = "new-tool", label = "New Tool", w = 96 },
    },
}

local function editor_cards()
    return {
        { title = "Particle Designer", body = "Real file-backed slice: parse, validate, preview, save, and export .particle.toml documents." },
        { title = "Tilemap Editor", body = "Still a planned vertical slice. The shell now exposes command, document, and project-index services for future tools." },
        { title = "Sprite Atlas", body = "Remains a focused content tool, not a code editor. VS Code stays responsible for Lua source work." },
        { title = "UI Layout Studio", body = "Dogfood retained lurek.ui workflows and future shared document services from the same shell host." },
    }
end

function M.update(_ctx, _dt)
end

function M.draw(ctx, r, ui)
    ui.text("Lurek Workbench", r.x + 28, r.y + 26, ui.color.text)
    ui.text("Native visual tooling for Lurek project content. VS Code stays responsible for Lua code and language intelligence.", r.x + 28, r.y + 54, ui.color.muted)

    local card_w = math.max(220, (r.w - 84) / 2)
    local card_h = 116
    for i, card in ipairs(editor_cards()) do
        local col = (i - 1) % 2
        local row = math.floor((i - 1) / 2)
        local x = r.x + 28 + col * (card_w + 28)
        local y = r.y + 96 + row * (card_h + 24)
        ui.rect(x, y, card_w, card_h, ui.color.panel)
        ui.rect_line(x, y, card_w, card_h, ui.color.line)
        ui.text(card.title, x + 18, y + 18, ui.color.text)
        ui.text(card.body, x + 18, y + 48, ui.color.muted)
        ui.text(i == 1 and "Status: implemented vertical slice" or "Status: shell baseline", x + 18, y + 82, i == 1 and ui.color.ok or ui.color.accent2)
    end

    local y = r.y + r.h - 116
    ui.rect(r.x + 28, y, r.w - 56, 88, { 0.045, 0.052, 0.064, 1 })
    ui.text("Workbench architecture", r.x + 46, y + 18, ui.color.text)
    ui.text("Shell hosts retained-ui chrome plus shared command, project-index, and document services.", r.x + 46, y + 44, ui.color.muted)
    ui.text("Particle Designer is the first real slice: live lurek.particle preview, save/reload/revert, export snippet, and validation.", r.x + 46, y + 66, ui.color.muted)
end

function M.inspect(ctx)
    return {
        { label = "Project", value = ctx.project_name },
        { label = "Open tabs", value = tostring(#ctx.tabs) },
        { label = "Mode", value = "Retained shell host" },
        { label = "Code editor", value = "VS Code" },
        { label = "Runtime", value = "Lurek Lua + lurek.ui" },
    }
end

function M.export(_ctx)
    return [[-- Workbench shell milestone
-- Shared services:
--   command bus
--   project index
--   document service
-- First vertical slice:
--   particle designer
--   real .particle.toml preview/save/export
]]
end

function M.handle_action(ctx, action_id)
    if action_id == "open-project" then
        return ctx.command_bus:dispatch("project.open_sample")
    end
    if action_id == "scan-assets" then
        return ctx.command_bus:dispatch("project.rescan")
    end
    if action_id == "new-tool" then
        return true, {
            status = "Workbench remains focused on content tools",
            log = "Skipped creating a generic new tool. Issue #36 keeps the first real slice focused on particles.",
            level = "warn",
        }
    end
    return false, "Unknown overview action: " .. tostring(action_id)
end

return M
