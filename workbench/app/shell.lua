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

local function text_wrap(value, x, y, width, color)
    set_color(color or C.text)
    lurek.render.printf(tostring(value or ""), x, y, width, "left")
end

local function basename(path)
    path = tostring(path or ""):gsub("\\", "/")
    return (path:match("([^/]+)$")) or path
end

local function button_width(label, min_width, max_width)
    local text_width = #tostring(label or "") * 11 + 28
    local lower = min_width or 72
    local upper = max_width or 240
    return math.min(upper, math.max(lower, text_width))
end

local function layout_for(ctx)
    local w = ctx.viewport.w
    local h = ctx.viewport.h
    local menu_h = 40
    local status_h = 24
    local tabs_h = 34
    local toolbar_h = 36
    local bottom_h = 136
    local activity_w = 48
    local sidebar_w = math.min(280, math.max(220, math.floor(w * 0.22)))
    local inspector_w = math.min(320, math.max(280, math.floor(w * 0.24)))
    local main_x = activity_w + sidebar_w
    local middle_y = menu_h + tabs_h + toolbar_h
    local middle_h = math.max(220, h - menu_h - tabs_h - toolbar_h - bottom_h - status_h)
    local workspace_w = math.max(240, w - main_x - inspector_w)

    return {
        menu = { x = 0, y = 0, w = w, h = menu_h },
        activity = { x = 0, y = menu_h, w = activity_w, h = h - menu_h - status_h },
        sidebar = { x = activity_w, y = menu_h, w = sidebar_w, h = h - menu_h - status_h },
        tabs = { x = main_x, y = menu_h, w = w - main_x, h = tabs_h },
        toolbar = { x = main_x, y = menu_h + tabs_h, w = w - main_x, h = toolbar_h },
        workspace = { x = main_x, y = middle_y, w = workspace_w, h = middle_h },
        inspector = { x = main_x + workspace_w, y = middle_y, w = inspector_w, h = middle_h },
        bottom = { x = main_x, y = h - bottom_h - status_h, w = w - main_x, h = bottom_h },
        status = { x = 0, y = h - status_h, w = w, h = status_h },
    }
end

local function ensure_tab(ctx, id)
    if ctx.open[id] then
        return
    end
    ctx.open[id] = true
    ctx.tabs[#ctx.tabs + 1] = id
end

function M.create(ctx)
    local self = {
        ctx = ctx,
        widgets = {},
        editor_widgets = {},
        tab_slots = {},
        toolbar_slots = {},
        suspend_editor_sync = false,
        layout = layout_for(ctx),
    }

    lurek.ui.clear()
    lurek.ui.setDefaultTheme()
    lurek.ui.setViewport(ctx.viewport.w, ctx.viewport.h)
    lurek.ui.setAutoInput(false)
    lurek.ui.setAutoUpdate(false)
    self.root = lurek.ui.getRoot()
    self.root:setSize(ctx.viewport.w, ctx.viewport.h)

    local function attach_root(widget)
        self.root:addChild(widget)
        return widget
    end

    local function create_background_widget(draw_fn)
        local widget = lurek.ui.newCustomWidget({ width = 16, height = 16 })
        widget:setOnDraw(draw_fn)
        widget:setMouseFilter("ignore")
        return attach_root(widget)
    end

    local function active_document()
        return self.ctx.services.documents:get_active()
    end

    function self:log(level, message)
        local logs = self.ctx.logs
        logs[#logs + 1] = {
            level = level or "info",
            text = tostring(message or ""),
        }
        while #logs > 64 do
            table.remove(logs, 1)
        end
    end

    function self:apply_command_result(ok, result)
        if ok then
            if type(result) == "table" then
                if result.status then
                    self.ctx.status = result.status
                end
                if result.log then
                    self:log(result.level or "info", result.log)
                end
            end
            return true
        end
        self.ctx.status = tostring(result)
        self:log("error", tostring(result))
        return false
    end

    function self:run_command(name, payload)
        return self:apply_command_result(self.ctx.command_bus:dispatch(name, payload))
    end

    function self:register_editor_widget(editor_id, key, widget)
        if not self.editor_widgets[editor_id] then
            self.editor_widgets[editor_id] = {}
        end
        attach_root(widget)
        self.editor_widgets[editor_id][key] = widget
        widget:setVisible(false)
        return widget
    end

    function self:get_editor_widget(editor_id, key)
        local widgets = self.editor_widgets[editor_id]
        return widgets and widgets[key] or nil
    end

    function self:set_editor_widgets_visible(editor_id, visible)
        local widgets = self.editor_widgets[editor_id]
        if not widgets then
            return
        end
        for _, widget in pairs(widgets) do
            widget:setVisible(visible)
        end
    end

    function self:show_only_editor_widgets(active_editor_id)
        for editor_id in pairs(self.editor_widgets) do
            self:set_editor_widgets_visible(editor_id, editor_id == active_editor_id)
        end
    end

    function self:open_editor(id)
        local editor = self.ctx.registry:get(id)
        ensure_tab(self.ctx, editor.id)
        self.ctx.active_editor = editor.id
        if editor.id == "particle" then
            local document = self.ctx.services.documents:find_by_editor("particle")
            if document then
                self.ctx.services.documents:activate(document.path)
                self.ctx.problems = document.problems or {}
                self.ctx.dirty = document.dirty or false
            end
        else
            self.ctx.problems = {}
            self.ctx.dirty = false
        end
        self.ctx.status = "Opened " .. editor.title
    end

    function self:run_editor_action(action_id)
        local editor = self.ctx.registry:get(self.ctx.active_editor)
        if editor.handle_action then
            return self:apply_command_result(editor.handle_action(self.ctx, action_id))
        end
        self.ctx.status = "No action handler for " .. tostring(action_id)
        self:log("warn", "Skipped " .. tostring(action_id) .. " in " .. editor.title)
        return false
    end

    self.widgets.menu_back = create_background_widget(function(r)
        rect(r.x, r.y, r.w, r.h, { 0.035, 0.040, 0.048, 1 })
    end)

    self.widgets.activity_back = create_background_widget(function(r)
        rect(r.x, r.y, r.w, r.h, { 0.031, 0.035, 0.043, 1 })
        rect_line(r.x, r.y, r.w, r.h, C.line)
    end)

    self.widgets.sidebar_back = create_background_widget(function(r)
        rect(r.x, r.y, r.w, r.h, C.panel)
        rect_line(r.x, r.y, r.w, r.h, C.line)
        local title = self.ctx.active_sidebar == "editors" and "Visual Editors"
            or self.ctx.active_sidebar == "project" and "Project Index"
            or self.ctx.active_sidebar == "assets" and "Assets"
            or "Workbench Settings"
        text(title, r.x + 16, r.y + 14, C.text)
        line(r.x, r.y + 40, r.x + r.w, r.y + 40, C.line)
        if self.ctx.active_sidebar == "project" then
            text(self.ctx.project_name, r.x + 16, r.y + 52, C.text)
            text(self.ctx.project_root, r.x + 16, r.y + 72, C.muted)
            text("indexed files: " .. tostring(self.ctx.services.projects.file_count), r.x + 16, r.y + 92, C.muted)
        elseif self.ctx.active_sidebar == "assets" then
            text_wrap("The project index is active first. Asset authoring will sit on the same document and command services later.", r.x + 16, r.y + 58, r.w - 32, C.muted)
        elseif self.ctx.active_sidebar == "settings" then
            text_wrap("Workbench is a content host, not a Lua source editor. VS Code still owns code editing, diagnostics, rename, and navigation.", r.x + 16, r.y + 58, r.w - 32, C.muted)
        else
            text_wrap("Editor selection stays in the sidebar; shared save/export/reload flows now route through the workbench command bus.", r.x + 16, r.y + 52, r.w - 32, C.muted)
        end
    end)

    self.widgets.tabs_back = create_background_widget(function(r)
        rect(r.x, r.y, r.w, r.h, C.panel2)
        line(r.x, r.y + r.h - 1, r.x + r.w, r.y + r.h - 1, C.line)
    end)

    self.widgets.toolbar_back = create_background_widget(function(r)
        rect(r.x, r.y, r.w, r.h, { 0.045, 0.050, 0.060, 1 })
        line(r.x, r.y + r.h - 1, r.x + r.w, r.y + r.h - 1, C.line)
    end)

    self.widgets.workspace_back = create_background_widget(function(r)
        rect(r.x, r.y, r.w, r.h, { 0.032, 0.036, 0.044, 1 })
        rect_line(r.x, r.y, r.w, r.h, C.line)
        local editor = self.ctx.registry:get(self.ctx.active_editor)
        if editor.draw then
            editor.draw(self.ctx, r, {
                color = C,
                rect = rect,
                rect_line = rect_line,
                line = line,
                text = text,
            })
        end
    end)

    self.widgets.inspector_back = create_background_widget(function(r)
        rect(r.x, r.y, r.w, r.h, C.panel)
        rect_line(r.x, r.y, r.w, r.h, C.line)
        text("Inspector", r.x + 16, r.y + 14, C.text)
        line(r.x, r.y + 40, r.x + r.w, r.y + 40, C.line)

        local editor = self.ctx.registry:get(self.ctx.active_editor)
        local rows = editor.inspect and editor.inspect(self.ctx) or {}
        local y = r.y + 56
        for index, row in ipairs(rows) do
            if index > 5 then
                break
            end
            text(row.label, r.x + 16, y, C.muted)
            text_wrap(row.value, r.x + 122, y, r.w - 138, C.text)
            y = y + 20
        end
    end)

    self.widgets.bottom_back = create_background_widget(function(r)
        rect(r.x, r.y, r.w, r.h, C.panel)
        rect_line(r.x, r.y, r.w, r.h, C.line)
        local y = r.y + 44
        if self.ctx.bottom_tab == "problems" then
            if #self.ctx.problems == 0 then
                text("No active validation problems.", r.x + 18, y, C.ok)
            else
                for i, problem in ipairs(self.ctx.problems) do
                    if i > 5 then
                        break
                    end
                    text_wrap(problem, r.x + 18, y, r.w - 36, C.warn)
                    y = y + 20
                end
            end
        elseif self.ctx.bottom_tab == "export" then
            local editor = self.ctx.registry:get(self.ctx.active_editor)
            local export_text = editor.export and editor.export(self.ctx) or "-- No export preview"
            for line_text in string.gmatch(export_text or "", "[^\n]+") do
                text(line_text, r.x + 18, y, C.muted)
                y = y + 18
                if y > r.y + r.h - 18 then
                    break
                end
            end
        else
            local first = math.max(1, #self.ctx.logs - 5)
            for i = first, #self.ctx.logs do
                local entry = self.ctx.logs[i]
                local color = entry.level == "warn" and C.warn or entry.level == "error" and C.danger or C.muted
                text_wrap("[" .. entry.level .. "] " .. entry.text, r.x + 18, y, r.w - 36, color)
                y = y + 18
            end
        end
    end)

    self.widgets.status = attach_root(lurek.ui.newStatusBar())
    self.widgets.status:addSection("Ready", 280)
    self.widgets.status:addSection("", 0)
    self.widgets.status:addSection("", 280)

    self.widgets.sample_button = attach_root(lurek.ui.newButton("Sample Project"))
    self.widgets.sample_button:setOnClick(function()
        self:run_command("project.open_sample")
    end)

    self.widgets.rescan_button = attach_root(lurek.ui.newButton("Rescan"))
    self.widgets.rescan_button:setOnClick(function()
        self:run_command("project.rescan")
    end)

    self.widgets.home_button = attach_root(lurek.ui.newButton("Workbench Home"))
    self.widgets.home_button:setOnClick(function()
        self:open_editor("overview")
    end)

    self.widgets.activity_project = attach_root(lurek.ui.newButton("P"))
    self.widgets.activity_project:setOnClick(function()
        self.ctx.active_sidebar = "project"
        self.ctx.status = "Sidebar: project"
    end)

    self.widgets.activity_editors = attach_root(lurek.ui.newButton("E"))
    self.widgets.activity_editors:setOnClick(function()
        self.ctx.active_sidebar = "editors"
        self.ctx.status = "Sidebar: editors"
    end)

    self.widgets.activity_assets = attach_root(lurek.ui.newButton("A"))
    self.widgets.activity_assets:setOnClick(function()
        self.ctx.active_sidebar = "assets"
        self.ctx.status = "Sidebar: assets"
    end)

    self.widgets.activity_settings = attach_root(lurek.ui.newButton("S"))
    self.widgets.activity_settings:setOnClick(function()
        self.ctx.active_sidebar = "settings"
        self.ctx.status = "Sidebar: settings"
    end)

    self.widgets.project_tree = attach_root(lurek.ui.newTreeView())
    self.widgets.project_tree:setOnChange(function()
        local node_index = self.widgets.project_tree:getSelectedNode()
        local entry = self.ctx.services.projects:selected_entry(node_index)
        if entry and entry.path and entry.path:match("%.particle%.toml$") then
            self:run_command("document.open_path", { path = entry.path })
        end
    end)

    self.editor_buttons = {}
    for _, editor in ipairs(self.ctx.registry:list()) do
        local button = attach_root(lurek.ui.newButton(editor.title))
        button:setOnClick(function()
            self:open_editor(editor.id)
        end)
        self.editor_buttons[#self.editor_buttons + 1] = {
            editor_id = editor.id,
            widget = button,
        }
    end

    for index = 1, 6 do
        local button = attach_root(lurek.ui.newButton("tab"))
        button:setOnClick(function()
            local editor_id = self.tab_slots[index]
            if editor_id then
                self:open_editor(editor_id)
            end
        end)
        self.widgets["tab_" .. tostring(index)] = button
    end

    for index = 1, 6 do
        local button = attach_root(lurek.ui.newButton("action"))
        button:setOnClick(function()
            local action = self.toolbar_slots[index]
            if action then
                self:run_editor_action(action.id)
            end
        end)
        self.widgets["toolbar_" .. tostring(index)] = button
    end

    self.widgets.bottom_log = attach_root(lurek.ui.newButton("Log"))
    self.widgets.bottom_log:setOnClick(function()
        self.ctx.bottom_tab = "log"
    end)

    self.widgets.bottom_problems = attach_root(lurek.ui.newButton("Problems"))
    self.widgets.bottom_problems:setOnClick(function()
        self.ctx.bottom_tab = "problems"
    end)

    self.widgets.bottom_export = attach_root(lurek.ui.newButton("Export"))
    self.widgets.bottom_export:setOnClick(function()
        self.ctx.bottom_tab = "export"
    end)

    function self:sync_layout()
        local width, height = lurek.window.getDimensions()
        if width and height then
            self.ctx.viewport.w = width
            self.ctx.viewport.h = height
        end

        self.layout = layout_for(self.ctx)
        lurek.ui.updateResolution(self.ctx.viewport.w, self.ctx.viewport.h)
        self.root:setSize(self.ctx.viewport.w, self.ctx.viewport.h)

        self.ctx.dirty = active_document() and active_document().dirty or false
        self.ctx.problems = active_document() and (active_document().problems or {}) or {}

        self.widgets.menu_back:setPosition(self.layout.menu.x, self.layout.menu.y)
        self.widgets.menu_back:setSize(self.layout.menu.w, self.layout.menu.h)
        self.widgets.activity_back:setPosition(self.layout.activity.x, self.layout.activity.y)
        self.widgets.activity_back:setSize(self.layout.activity.w, self.layout.activity.h)
        self.widgets.sidebar_back:setPosition(self.layout.sidebar.x, self.layout.sidebar.y)
        self.widgets.sidebar_back:setSize(self.layout.sidebar.w, self.layout.sidebar.h)
        self.widgets.tabs_back:setPosition(self.layout.tabs.x, self.layout.tabs.y)
        self.widgets.tabs_back:setSize(self.layout.tabs.w, self.layout.tabs.h)
        self.widgets.toolbar_back:setPosition(self.layout.toolbar.x, self.layout.toolbar.y)
        self.widgets.toolbar_back:setSize(self.layout.toolbar.w, self.layout.toolbar.h)
        self.widgets.workspace_back:setPosition(self.layout.workspace.x, self.layout.workspace.y)
        self.widgets.workspace_back:setSize(self.layout.workspace.w, self.layout.workspace.h)
        self.widgets.inspector_back:setPosition(self.layout.inspector.x, self.layout.inspector.y)
        self.widgets.inspector_back:setSize(self.layout.inspector.w, self.layout.inspector.h)
        self.widgets.bottom_back:setPosition(self.layout.bottom.x, self.layout.bottom.y)
        self.widgets.bottom_back:setSize(self.layout.bottom.w, self.layout.bottom.h)
        self.widgets.status:setPosition(self.layout.status.x, self.layout.status.y)
        self.widgets.status:setSize(self.layout.status.w, self.layout.status.h)

        local sample_width = button_width("Sample Project", 128, 176)
        local rescan_width = button_width("Rescan", 88, 120)
        local home_width = button_width("Workbench Home", 144, 196)
        self.widgets.sample_button:setPosition(12, 6)
        self.widgets.sample_button:setSize(sample_width, 28)
        self.widgets.rescan_button:setPosition(12 + sample_width + 8, 6)
        self.widgets.rescan_button:setSize(rescan_width, 28)
        self.widgets.home_button:setPosition(12 + sample_width + rescan_width + 16, 6)
        self.widgets.home_button:setSize(home_width, 28)

        self.widgets.activity_project:setPosition(4, self.layout.activity.y + 12)
        self.widgets.activity_project:setSize(40, 32)
        self.widgets.activity_editors:setPosition(4, self.layout.activity.y + 48)
        self.widgets.activity_editors:setSize(40, 32)
        self.widgets.activity_assets:setPosition(4, self.layout.activity.y + 84)
        self.widgets.activity_assets:setSize(40, 32)
        self.widgets.activity_settings:setPosition(4, self.layout.activity.y + 120)
        self.widgets.activity_settings:setSize(40, 32)

        local show_project = self.ctx.active_sidebar == "project"
        local show_editors = self.ctx.active_sidebar == "editors"

        self.widgets.project_tree:setVisible(show_project)
        self.widgets.project_tree:setPosition(self.layout.sidebar.x + 12, self.layout.sidebar.y + 116)
        self.widgets.project_tree:setSize(self.layout.sidebar.w - 24, self.layout.sidebar.h - 128)
        if self.ctx.project_needs_tree_refresh then
            self.ctx.services.projects:populate_tree(self.widgets.project_tree)
            self.ctx.project_needs_tree_refresh = false
        end

        local editor_button_y = self.layout.sidebar.y + 56
        for _, entry in ipairs(self.editor_buttons) do
            entry.widget:setVisible(show_editors)
            entry.widget:setPosition(self.layout.sidebar.x + 12, editor_button_y)
            entry.widget:setSize(self.layout.sidebar.w - 24, 38)
            editor_button_y = editor_button_y + 44
        end

        local tab_x = self.layout.tabs.x + 10
        for index = 1, 6 do
            local button = self.widgets["tab_" .. tostring(index)]
            local editor_id = self.ctx.tabs[index]
            self.tab_slots[index] = editor_id
            if editor_id then
                local editor = self.ctx.registry:get(editor_id)
                local width = button_width(editor.title, 120, 220)
                button:setText(editor.title)
                button:setVisible(true)
                button:setPosition(tab_x, self.layout.tabs.y + 4)
                button:setSize(width, 24)
                tab_x = tab_x + width + 8
            else
                button:setVisible(false)
            end
        end

        local toolbar_x = self.layout.toolbar.x + 12
        local editor = self.ctx.registry:get(self.ctx.active_editor)
        local mode_text = "Mode: " .. tostring(editor.workspace or "workspace")
        for index = 1, 6 do
            local button = self.widgets["toolbar_" .. tostring(index)]
            local action = editor.actions and editor.actions[index] or nil
            self.toolbar_slots[index] = action
            if action then
                local width = button_width(action.label, action.w or 96, 200)
                button:setText(action.label)
                button:setVisible(true)
                button:setPosition(toolbar_x, self.layout.toolbar.y + 4)
                button:setSize(width, 28)
                toolbar_x = toolbar_x + width + 8
            else
                button:setVisible(false)
            end
        end

        self.widgets.bottom_log:setPosition(self.layout.bottom.x + 12, self.layout.bottom.y + 8)
        self.widgets.bottom_log:setSize(60, 26)
        self.widgets.bottom_problems:setPosition(self.layout.bottom.x + 80, self.layout.bottom.y + 8)
        self.widgets.bottom_problems:setSize(92, 26)
        self.widgets.bottom_export:setPosition(self.layout.bottom.x + 180, self.layout.bottom.y + 8)
        self.widgets.bottom_export:setSize(82, 26)

        local document = active_document()
        local path_text = document and basename(document.relative_path or document.path) or "No active document"
        local detail_text = tostring(editor.workspace or "workspace")
            .. " | "
            .. self.ctx.active_editor
            .. " | "
            .. (self.ctx.dirty and "dirty" or "clean")
        self.widgets.status:setSectionText(1, self.ctx.status)
        self.widgets.status:setSectionText(2, path_text)
        self.widgets.status:setSectionText(3, detail_text)

        self:show_only_editor_widgets(self.ctx.active_editor)
        if editor.ensure_controls then
            editor.ensure_controls(self)
        end
        if editor.layout_controls then
            editor.layout_controls(self.ctx, self.layout.inspector, self)
        end
    end

    function self:update(dt)
        self.ctx.clock = self.ctx.clock + (dt or 0)
        local editor = self.ctx.registry:get(self.ctx.active_editor)
        if editor.update then
            editor.update(self.ctx, dt or 0)
        end
        self:sync_layout()
        lurek.ui.update(dt or 0)
    end

    function self:draw()
        rect(0, 0, self.ctx.viewport.w, self.ctx.viewport.h, C.bg)
        self:sync_layout()
        lurek.ui.draw()
    end

    function self:keypressed(key)
        if lurek.ui.keypressed(key) then
            return true
        end
        if key == "escape" then
            lurek.event.quit()
            return true
        end
        if key == "f1" then
            self:open_editor("overview")
            return true
        end
        if key == "tab" then
            local idx = self.ctx.registry:index_of(self.ctx.active_editor) + 1
            local editors = self.ctx.registry:list()
            if idx > #editors then
                idx = 1
            end
            self:open_editor(editors[idx].id)
            return true
        end
        if key == "s" then
            return self:run_command("document.save_active")
        end
        if key == "e" then
            return self:run_command("document.export_active")
        end
        return false
    end

    function self:textinput(text_value)
        return lurek.ui.textinput(text_value)
    end

    function self:mousepressed(x, y, button)
        return lurek.ui.mousepressed(x, y, button or 1)
    end

    function self:mousereleased(x, y, button)
        return lurek.ui.mousereleased(x, y, button or 1)
    end

    function self:mousemoved(x, y)
        return lurek.ui.mousemoved(x, y)
    end

    function self:wheelmoved(x, y)
        return lurek.ui.wheelmoved(x, y)
    end

    function self:resize(width, height)
        self.ctx.viewport.w = width
        self.ctx.viewport.h = height
        lurek.ui.updateResolution(width, height)
        self.ctx.status = "Viewport resized to " .. tostring(width) .. "x" .. tostring(height)
    end

    return self
end

return M
