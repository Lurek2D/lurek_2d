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
        { title = "Particle Designer", body = "Tune emitters, color ramps, lifetimes, spawn shape, and export TOML or Lua." },
        { title = "Tilemap Editor", body = "Paint map layers, collision hints, autotile regions, and tilefield refs." },
        { title = "Sprite Atlas", body = "Slice sheets, name frames, preview clips, and generate quad metadata." },
        { title = "UI Layout Studio", body = "Author TOML layouts and inspect responsive panel structure." },
    }
end

function M.update(_ctx, _dt)
end

function M.draw(ctx, r, ui)
    ui.text("Lurek Workbench", r.x + 28, r.y + 26, ui.color.text)
    ui.text("Native visual tooling for Lurek project content. VS Code stays responsible for Lua code.", r.x + 28, r.y + 54, ui.color.muted)

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
        ui.text("Status: planned baseline", x + 18, y + 82, ui.color.accent2)
    end

    local y = r.y + r.h - 116
    ui.rect(r.x + 28, y, r.w - 56, 88, { 0.045, 0.052, 0.064, 1 })
    ui.text("Workbench architecture", r.x + 46, y + 18, ui.color.text)
    ui.text("Shell hosts independent editors. Editors own preview, inspector fields, validation, and export text.", r.x + 46, y + 44, ui.color.muted)
    ui.text("Next hardening step: wire real file open/save and promote Particle Designer to full vertical slice.", r.x + 46, y + 66, ui.color.muted)
end

function M.inspect(ctx)
    return {
        { label = "Project", value = ctx.project_name },
        { label = "Open tabs", value = tostring(#ctx.tabs) },
        { label = "Mode", value = "Workbench shell" },
        { label = "Code editor", value = "VS Code" },
        { label = "Runtime", value = "Lurek Lua" },
    }
end

function M.export(_ctx)
    return [[-- Workbench shell contract
editor = {
  open = function(ctx, path) end,
  save = function(ctx) end,
  draw = function(ctx, rect) end,
  inspect = function(ctx) return fields end,
  export = function(ctx) return text end,
}]]
end

return M

