local M = {}

local C = {
    bg = { 0.025, 0.028, 0.034, 1 },
    panel = { 0.055, 0.062, 0.074, 1 },
    panel2 = { 0.075, 0.083, 0.098, 1 },
    panel3 = { 0.095, 0.106, 0.124, 1 },
    line = { 0.18, 0.20, 0.23, 1 },
    text = { 0.86, 0.88, 0.90, 1 },
    muted = { 0.54, 0.58, 0.64, 1 },
    accent = { 0.08, 0.54, 0.72, 1 },
    accent2 = { 0.93, 0.68, 0.24, 1 },
    ok = { 0.22, 0.72, 0.44, 1 },
    warn = { 0.88, 0.57, 0.18, 1 },
    danger = { 0.82, 0.26, 0.28, 1 },
}

local FONT_LINE = 14

local function set_color(color)
    lurek.render.setColor(color[1], color[2], color[3], color[4] or 1)
end

local function rect(x, y, w, h, color)
    set_color(color)
    lurek.render.rectangle("fill", x, y, w, h)
end

local function rect_line(x, y, w, h, color)
    set_color(color)
    lurek.render.rectangle("line", x, y, w, h)
end

local function line(x1, y1, x2, y2, color)
    set_color(color)
    lurek.render.line(x1, y1, x2, y2)
end

local function text(value, x, y, color)
    set_color(color or C.text)
    lurek.render.print(tostring(value or ""), x, y)
end

local function text_center(value, x, y, w, h, color)
    set_color(color or C.text)
    lurek.render.printf(tostring(value or ""), x, y + math.floor((h - FONT_LINE) * 0.5), w, "center")
end

local function contains(r, x, y)
    return x >= r.x and y >= r.y and x <= r.x + r.w and y <= r.y + r.h
end

local function add_hit(ctx, kind, id, x, y, w, h)
    ctx.hit[#ctx.hit + 1] = { kind = kind, id = id, x = x, y = y, w = w, h = h }
end

local function draw_button(ctx, id, label, x, y, w, h, active)
    local hovering = contains({ x = x, y = y, w = w, h = h }, ctx.mouse.x, ctx.mouse.y)
    rect(x, y, w, h, active and C.accent or hovering and C.panel3 or C.panel2)
    rect_line(x, y, w, h, active and C.accent2 or C.line)
    text_center(label, x, y, w, h, active and { 1, 1, 1, 1 } or C.text)
    add_hit(ctx, "button", id, x, y, w, h)
end

local function draw_icon_button(ctx, id, label, x, y, active)
    local size = 40
    local hovering = contains({ x = x, y = y, w = size, h = size }, ctx.mouse.x, ctx.mouse.y)
    rect(x, y, size, size, active and C.accent or hovering and C.panel3 or C.panel)
    rect_line(x, y, size, size, active and C.accent2 or C.line)
    text_center(label, x, y, size, size, active and { 1, 1, 1, 1 } or C.muted)
    add_hit(ctx, "activity", id, x, y, size, size)
end

local function layout_for(ctx)
    local w, h = ctx.viewport.w, ctx.viewport.h
    local menu_h = 36
    local top = menu_h
    return {
        menu = { x = 0, y = 0, w = w, h = menu_h },
        activity = { x = 0, y = top, w = 56, h = h - top - 24 },
        sidebar = { x = 56, y = top, w = 284, h = h - top - 24 },
        status = { x = 0, y = h - 24, w = w, h = 24 },
        tabs = { x = 340, y = top, w = w - 340, h = 34 },
        toolbar = { x = 340, y = top + 34, w = w - 340, h = 44 },
        inspector = { x = w - 324, y = top + 78, w = 324, h = h - top - 242 },
        bottom = { x = 340, y = h - 164, w = w - 340, h = 140 },
        workspace = { x = 340, y = top + 78, w = w - 664, h = h - top - 242 },
    }
end

local function draw_menu(ctx, L)
    rect(L.menu.x, L.menu.y, L.menu.w, L.menu.h, { 0.035, 0.040, 0.048, 1 })
    local x = 16
    for _, item in ipairs({ "File", "Edit", "Project", "Tools", "Run", "Window", "Help" }) do
        draw_button(ctx, "menu:" .. item, item, x, L.menu.y + 5, math.max(58, #item * 8 + 22), 26, false)
        x = x + math.max(58, #item * 8 + 22) + 4
    end
    draw_button(ctx, "save", "Save", L.menu.w - 238, L.menu.y + 5, 64, 26, false)
    draw_button(ctx, "run", "Run", L.menu.w - 168, L.menu.y + 5, 58, 26, false)
    draw_button(ctx, "stop", "Stop", L.menu.w - 104, L.menu.y + 5, 64, 26, false)
end

local function draw_activity(ctx, L)
    rect(L.activity.x, L.activity.y, L.activity.w, L.activity.h, { 0.031, 0.035, 0.043, 1 })
    local items = {
        { id = "project", label = "P" },
        { id = "editors", label = "E" },
        { id = "assets", label = "A" },
        { id = "settings", label = "S" },
    }
    for i, item in ipairs(items) do
        draw_icon_button(ctx, item.id, item.label, 8, L.activity.y + 14 + (i - 1) * 48, ctx.active_sidebar == item.id)
    end
end

local function draw_sidebar(ctx, L)
    rect(L.sidebar.x, L.sidebar.y, L.sidebar.w, L.sidebar.h, C.panel)
    rect_line(L.sidebar.x, L.sidebar.y, L.sidebar.w, L.sidebar.h, C.line)
    local title = ctx.active_sidebar == "editors" and "Visual Editors"
        or ctx.active_sidebar == "project" and "Project"
        or ctx.active_sidebar == "assets" and "Assets"
        or "Workbench Settings"
    text(title, L.sidebar.x + 16, L.sidebar.y + 16, C.text)
    line(L.sidebar.x, L.sidebar.y + 44, L.sidebar.x + L.sidebar.w, L.sidebar.y + 44, C.line)

    if ctx.active_sidebar == "editors" then
        local y = L.sidebar.y + 60
        for _, editor in ipairs(ctx.registry:list()) do
            local active = editor.id == ctx.active_editor
            local row_h = 58
            rect(L.sidebar.x + 10, y, L.sidebar.w - 20, row_h, active and C.panel3 or C.panel)
            if active then rect(L.sidebar.x + 10, y, 4, row_h, C.accent2) end
            text(editor.title, L.sidebar.x + 24, y + 10, C.text)
            text(editor.summary, L.sidebar.x + 24, y + 31, C.muted)
            add_hit(ctx, "open_editor", editor.id, L.sidebar.x + 10, y, L.sidebar.w - 20, row_h)
            y = y + row_h + 8
        end
    elseif ctx.active_sidebar == "project" then
        text(ctx.project_name, L.sidebar.x + 16, L.sidebar.y + 60, C.text)
        text(ctx.project_root, L.sidebar.x + 16, L.sidebar.y + 84, C.muted)
        local y = L.sidebar.y + 124
        for _, item in ipairs(ctx.project_tree) do
            local prefix = item.kind == "folder" and "[+]" or " - "
            text(prefix .. " " .. item.label, L.sidebar.x + 16 + item.depth * 18, y, item.kind == "folder" and C.text or C.muted)
            y = y + 22
        end
    elseif ctx.active_sidebar == "assets" then
        local assets = {
            "images/*.png",
            "audio/*.ogg",
            "particles/*.toml",
            "maps/*.ltm",
            "layouts/*.toml",
        }
        for i, item in ipairs(assets) do
            text(item, L.sidebar.x + 18, L.sidebar.y + 58 + i * 28, C.muted)
        end
    else
        text("Theme: Workbench Dark", L.sidebar.x + 18, L.sidebar.y + 72, C.muted)
        text("Shell: native window", L.sidebar.x + 18, L.sidebar.y + 100, C.muted)
        text("Code editor: VS Code", L.sidebar.x + 18, L.sidebar.y + 128, C.muted)
    end
end

local function draw_tabs(ctx, L)
    rect(L.tabs.x, L.tabs.y, L.tabs.w, L.tabs.h, C.panel2)
    local x = L.tabs.x + 8
    for _, id in ipairs(ctx.tabs) do
        local editor = ctx.registry:get(id)
        local w = math.max(126, #editor.title * 7 + 24)
        local active = id == ctx.active_editor
        rect(x, L.tabs.y + 4, w, 26, active and C.panel or { 0.052, 0.058, 0.068, 1 })
        if active then line(x, L.tabs.y + 30, x + w, L.tabs.y + 30, C.accent2) end
        text_center(editor.title, x, L.tabs.y + 4, w, 26, active and C.text or C.muted)
        add_hit(ctx, "tab", id, x, L.tabs.y + 4, w, 26)
        x = x + w + 6
    end
end

local function draw_toolbar(ctx, L, editor)
    rect(L.toolbar.x, L.toolbar.y, L.toolbar.w, L.toolbar.h, { 0.045, 0.050, 0.060, 1 })
    local actions = editor.actions or {}
    local x = L.toolbar.x + 12
    for _, action in ipairs(actions) do
        draw_button(ctx, "editor:" .. action.id, action.label, x, L.toolbar.y + 8, action.w or 86, 28, false)
        x = x + (action.w or 92) + 8
    end
    text("Mode: " .. (editor.workspace or "workspace"), L.toolbar.x + L.toolbar.w - 210, L.toolbar.y + 14, C.muted)
end

local function draw_inspector(ctx, L, editor)
    rect(L.inspector.x, L.inspector.y, L.inspector.w, L.inspector.h, C.panel)
    rect_line(L.inspector.x, L.inspector.y, L.inspector.w, L.inspector.h, C.line)
    text("Inspector", L.inspector.x + 16, L.inspector.y + 14, C.text)
    line(L.inspector.x, L.inspector.y + 42, L.inspector.x + L.inspector.w, L.inspector.y + 42, C.line)
    local fields = editor.inspect and editor.inspect(ctx) or {}
    local y = L.inspector.y + 60
    for _, field in ipairs(fields) do
        text(field.label, L.inspector.x + 16, y, C.muted)
        text(field.value, L.inspector.x + 148, y, C.text)
        y = y + 28
    end
end

local function draw_bottom(ctx, L, editor)
    rect(L.bottom.x, L.bottom.y, L.bottom.w, L.bottom.h, C.panel)
    rect_line(L.bottom.x, L.bottom.y, L.bottom.w, L.bottom.h, C.line)
    draw_button(ctx, "bottom:log", "Log", L.bottom.x + 12, L.bottom.y + 8, 64, 28, ctx.bottom_tab == "log")
    draw_button(ctx, "bottom:problems", "Problems", L.bottom.x + 84, L.bottom.y + 8, 104, 28, ctx.bottom_tab == "problems")
    draw_button(ctx, "bottom:export", "Export Preview", L.bottom.x + 196, L.bottom.y + 8, 140, 28, ctx.bottom_tab == "export")
    local y = L.bottom.y + 48
    if ctx.bottom_tab == "export" and editor.export then
        for line_text in string.gmatch(editor.export(ctx) or "", "[^\n]+") do
            text(line_text, L.bottom.x + 18, y, C.muted)
            y = y + 20
            if y > L.bottom.y + L.bottom.h - 18 then break end
        end
    elseif ctx.bottom_tab == "problems" then
        if #ctx.problems == 0 then
            text("No validation problems in the active workbench model.", L.bottom.x + 18, y, C.ok)
        else
            for _, problem in ipairs(ctx.problems) do
                text(problem, L.bottom.x + 18, y, C.warn)
                y = y + 20
            end
        end
    else
        local first = math.max(1, #ctx.logs - 4)
        for i = first, #ctx.logs do
            local log = ctx.logs[i]
            local color = log.level == "warn" and C.warn or log.level == "error" and C.danger or C.muted
            text("[" .. log.level .. "] " .. log.text, L.bottom.x + 18, y, color)
            y = y + 20
        end
    end
end

local function draw_status(ctx, L)
    rect(L.status.x, L.status.y, L.status.w, L.status.h, { 0.038, 0.044, 0.052, 1 })
    text(ctx.status, L.status.x + 12, L.status.y + 4, C.muted)
    text("editor=" .. ctx.active_editor .. "  dirty=" .. tostring(ctx.dirty), L.status.w - 260, L.status.y + 4, C.muted)
end

local function execute_button(ctx, id)
    if id == "save" then
        ctx.dirty = false
        ctx.status = "Saved workbench document snapshot"
        return "Saved current workbench state"
    elseif id == "run" then
        ctx.command = "run-preview"
        ctx.status = "Preview running for " .. ctx.active_editor
        return "Started preview for active editor"
    elseif id == "stop" then
        ctx.command = "idle"
        ctx.status = "Preview stopped"
        return "Stopped active preview"
    elseif id == "bottom:log" then
        ctx.bottom_tab = "log"
    elseif id == "bottom:problems" then
        ctx.bottom_tab = "problems"
    elseif id == "bottom:export" then
        ctx.bottom_tab = "export"
    elseif string.sub(id, 1, 5) == "menu:" then
        ctx.status = string.sub(id, 6) .. " menu"
    elseif string.sub(id, 1, 7) == "editor:" then
        local action = string.sub(id, 8)
        ctx.status = "Editor action: " .. action
        ctx.dirty = true
        return "Executed " .. action .. " in " .. ctx.active_editor
    end
    return nil
end

function M.create(ctx)
    local self = { ctx = ctx }
    self.fonts = {}

    function self:ensure_fonts()
        if not self.fonts.ui and lurek.render.newFont then
            self.fonts.ui = lurek.render.newFont(10)
        end
    end

    function self:log(level, message)
        local logs = self.ctx.logs
        logs[#logs + 1] = { level = level or "info", text = tostring(message or "") }
        while #logs > 64 do table.remove(logs, 1) end
    end

    function self:open_editor(id)
        local editor = self.ctx.registry:get(id)
        self.ctx.active_editor = editor.id
        if not self.ctx.open[editor.id] then
            self.ctx.open[editor.id] = true
            self.ctx.tabs[#self.ctx.tabs + 1] = editor.id
        end
        self.ctx.status = "Opened " .. editor.title
    end

    function self:update(dt)
        local ctx = self.ctx
        ctx.clock = ctx.clock + dt
        local editor = ctx.registry:get(ctx.active_editor)
        if editor.update then editor.update(ctx, dt) end
        if lurek.ui and lurek.ui.update then lurek.ui.update(dt) end
    end

    function self:draw()
        local ctx = self.ctx
        self:ensure_fonts()
        if self.fonts.ui then lurek.render.setFont(self.fonts.ui) end
        ctx.hit = {}
        local w, h = lurek.window.getDimensions()
        ctx.viewport.w, ctx.viewport.h = w or ctx.viewport.w, h or ctx.viewport.h
        rect(0, 0, ctx.viewport.w, ctx.viewport.h, C.bg)
        local L = layout_for(ctx)
        local editor = ctx.registry:get(ctx.active_editor)

        draw_menu(ctx, L)
        draw_activity(ctx, L)
        draw_sidebar(ctx, L)
        draw_tabs(ctx, L)
        draw_toolbar(ctx, L, editor)
        rect(L.workspace.x, L.workspace.y, L.workspace.w, L.workspace.h, { 0.032, 0.036, 0.044, 1 })
        rect_line(L.workspace.x, L.workspace.y, L.workspace.w, L.workspace.h, C.line)
        if editor.draw then editor.draw(ctx, L.workspace, { color = C, rect = rect, rect_line = rect_line, line = line, text = text }) end
        draw_inspector(ctx, L, editor)
        draw_bottom(ctx, L, editor)
        draw_status(ctx, L)
    end

    function self:keypressed(key)
        if key == "escape" then
            lurek.event.quit()
            return true
        end
        if key == "f1" then self:open_editor("overview"); return true end
        if key == "tab" then
            local idx = self.ctx.registry:index_of(self.ctx.active_editor) + 1
            local editors = self.ctx.registry:list()
            if idx > #editors then idx = 1 end
            self:open_editor(editors[idx].id)
            return true
        end
        local number = tonumber(key)
        if number then
            local editor = self.ctx.registry:list()[number]
            if editor then self:open_editor(editor.id); return true end
        end
        if key == "s" then
            local msg = execute_button(self.ctx, "save")
            if msg then self:log("info", msg) end
            return true
        end
        if key == "r" then
            local msg = execute_button(self.ctx, "run")
            if msg then self:log("info", msg) end
            return true
        end
        return false
    end

    function self:textinput(_text)
        return false
    end

    function self:mousepressed(x, y, button)
        local ctx = self.ctx
        ctx.mouse.x, ctx.mouse.y, ctx.mouse.down = x, y, true
        if button ~= 1 then return false end
        for i = #ctx.hit, 1, -1 do
            local h = ctx.hit[i]
            if contains(h, x, y) then
                if h.kind == "activity" then
                    ctx.active_sidebar = h.id
                    ctx.status = "Sidebar: " .. h.id
                    return true
                elseif h.kind == "open_editor" or h.kind == "tab" then
                    self:open_editor(h.id)
                    return true
                elseif h.kind == "button" then
                    local msg = execute_button(ctx, h.id)
                    if msg then self:log("info", msg) end
                    return true
                end
            end
        end
        return false
    end

    function self:mousereleased(x, y, _button)
        self.ctx.mouse.x, self.ctx.mouse.y, self.ctx.mouse.down = x, y, false
        return false
    end

    function self:mousemoved(x, y)
        self.ctx.mouse.x, self.ctx.mouse.y = x, y
        return false
    end

    function self:wheelmoved(_x, _y)
        return false
    end

    function self:resize(width, height)
        self.ctx.viewport.w = width
        self.ctx.viewport.h = height
        self.ctx.status = "Viewport resized to " .. tostring(width) .. "x" .. tostring(height)
    end

    return self
end

return M
