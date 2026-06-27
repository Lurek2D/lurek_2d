-- test_ui_evidence.lua
-- Canonical evidence file for lurek.ui layouts and widgets.


local OUT = evidence_output_dir("ui")
local FIXTURE_LAYOUT_ROOT = "tests/fixtures/ui_layouts"

local function fixture_layout(name)
    return FIXTURE_LAYOUT_ROOT .. "/" .. name
end

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function layout_output_name(layout_path)
    local relative = layout_path
        :gsub("^content/layouts/", "")
        :gsub("^tests/fixtures/ui_layouts/", "")
    local segments = {}
    for segment in relative:gmatch("[^/\\]+") do
        segments[#segments + 1] = segment
    end

    local file_name = segments[#segments] or "layout.toml"
    local parent_name = segments[#segments - 1]
    file_name = file_name:gsub("%.layout%.toml$", ".png"):gsub("%.toml$", ".png")
    if parent_name and file_name:match("^" .. parent_name .. "_") then
        file_name = file_name:gsub("^" .. parent_name .. "_", "")
    end
    segments[#segments] = file_name

    return "layout_" .. table.concat(segments, "_")
end

local function layout_size(layout_path)
    local parsed = lurek.serialize.fromToml(lurek.filesystem.read(layout_path))
    if parsed.resolution and #parsed.resolution >= 2 then
        return parsed.resolution[1], parsed.resolution[2]
    end

    local root = parsed.root or {}
    return math.max(1, math.floor(root.w or 1280)), math.max(1, math.floor(root.h or 720))
end

local function render_layout(layout_path, output_name, width, height)
    lurek.ui.clear()
    lurek.ui.loadLayoutFile(layout_path)
    local path = OUT .. output_name
    lurek.ui.renderToImage(width, height, path)
    expect_evidence_created(path)
    return path
end

local function render_layout_output(layout_path, width, height, file_name)
    lurek.ui.clear()
    lurek.ui.loadLayoutFile(layout_path)
    local path = OUT .. file_name
    lurek.ui.renderToImage(width, height, path)
    expect_evidence_created(path)
    return path
end

local function place(widget, x, y, w, h, z)
    widget:setPosition(x, y)
    if w and h then
        widget:setSize(w, h)
    end
    if z then
        widget:setZOrder(z)
    end
    return widget
end

local function save_scene(file_name, width, height, build_fn)
    lurek.ui.clear()
    lurek.ui.setDefaultTheme()
    lurek.ui.setViewport(width, height)
    build_fn(width, height)
    lurek.ui.update(0.0)
    local path = OUT .. file_name
    lurek.ui.renderToImage(width, height, path)
    expect_evidence_created(path)
    return path
end

local function attach(parent, child)
    parent:addChild(child)
    return child
end

local function draw_outline(img, x, y, w, h, r, g, b, a)
    img:drawLine(x, y, x + w - 1, y, r, g, b, a or 255)
    img:drawLine(x + w - 1, y, x + w - 1, y + h - 1, r, g, b, a or 255)
    img:drawLine(x + w - 1, y + h - 1, x, y + h - 1, r, g, b, a or 255)
    img:drawLine(x, y + h - 1, x, y, r, g, b, a or 255)
end

-- @describe Evidence: lurek.ui layouts and widgets
describe("Evidence: lurek.ui layouts and widgets", function()
    before_each(function()
        ensure_evidence_dir("ui")
        lurek.ui.clear()
    end)
    -- Does: Runs "dashboard layout 1280x720" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.ui.renderToImage and lurek.ui.loadLayoutFile without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/ui/layout_dashboard_desktop_1280x720.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.ui.renderToImage and lurek.ui.loadLayoutFile; export helpers are just the container.

    it("UI01 PNG: dashboard layout 1280x720", function()
        render_layout_output(fixture_layout("dashboard_fixture.toml"), 1280, 720, "layout_dashboard_desktop_1280x720.png")
    end)
    -- Does: Runs "settings layout 1366x768" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.ui.renderToImage without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/ui/layout_settings_desktop_1366x768.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.ui.renderToImage; export helpers are just the container.

    it("UI02 PNG: settings layout 1366x768", function()
        render_layout_output(fixture_layout("settings_fixture.toml"), 1366, 768, "layout_settings_desktop_1366x768.png")
    end)
    -- Does: Runs "RPG inventory layout 1280x720" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.ui.renderToImage without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/ui/layout_rpg_inventory_1280x720.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.ui.renderToImage; export helpers are just the container.

    it("UI03 PNG: RPG inventory layout 1280x720", function()
        render_layout_output(fixture_layout("inventory_fixture.toml"), 1280, 720, "layout_rpg_inventory_1280x720.png")
    end)
    -- Does: Runs "strategy diplomacy layout 1400x800" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.ui.renderToImage without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/ui/layout_strategy_diplomacy_1400x800.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.ui.renderToImage; export helpers are just the container.

    it("UI04 PNG: strategy diplomacy layout 1400x800", function()
        render_layout_output(fixture_layout("diplomacy_fixture.toml"), 1400, 800, "layout_strategy_diplomacy_1400x800.png")
    end)
    -- Does: Runs "dashboard layout mobile-like 960x540" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.ui.renderToImage without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/ui/layout_dashboard_compact_960x540.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.ui.renderToImage; export helpers are just the container.

    it("UI05 PNG: dashboard layout mobile-like 960x540", function()
        render_layout_output(fixture_layout("dashboard_fixture.toml"), 960, 540, "layout_dashboard_compact_960x540.png")
    end)
    -- Does: Runs "settings layout ultrawide 1920x1080" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.ui.renderToImage without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/ui/layout_settings_ultrawide_1920x1080.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.ui.renderToImage; export helpers are just the container.

    it("UI06 PNG: settings layout ultrawide 1920x1080", function()
        render_layout_output(fixture_layout("settings_fixture.toml"), 1920, 1080, "layout_settings_ultrawide_1920x1080.png")
    end)
    -- Does: Runs "form widget scenes" and turns the owner-module result into inspectable artifacts.
    -- Shows: The artifacts should expose the behavior produced by lurek.ui.newButton, lurek.ui.newLabel, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/ui/form_widget_account_panel.png, tests/artifacts/current/ui/form_widget_plan_panel.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.ui.newButton, lurek.ui.newLabel, and related owner calls; export helpers are just the container.

    it("PNG: form widget scenes", function()
        save_scene("form_widget_account_panel.png", 460, 280, function()
            local root = lurek.ui.getRoot()
            local panel = attach(root, place(lurek.ui.newPanel(), 20, 20, 420, 220, 10))
            panel:setTitle("Account")

            local title = attach(panel, place(lurek.ui.newLabel("Profile Details"), 18, 34, 180, 24, 20))
            title:setStyleClass("primary")

            local action = attach(panel, place(lurek.ui.newButton("Save Changes"), 18, 150, 160, 34, 20))
            action:setRole("button")

            local name = attach(panel, place(lurek.ui.newTextInput(), 18, 78, 220, 30, 20))
            name:setText("tombl.dev")

            local newsletter = attach(panel, place(lurek.ui.newCheckbox("Send weekly report"), 18, 116, 220, 24, 20))
            newsletter:setChecked(true)
        end)

        save_scene("form_widget_plan_panel.png", 300, 220, function()
            local root = lurek.ui.getRoot()
            local plan_panel = attach(root, place(lurek.ui.newPanel(), 20, 20, 260, 160, 10))
            plan_panel:setTitle("Plan")
            local cash = attach(plan_panel, place(lurek.ui.newRadioButton("Starter", "plan"), 18, 50, 140, 24, 20))
            local pro = attach(plan_panel, place(lurek.ui.newRadioButton("Pro", "plan"), 18, 82, 140, 24, 20))
            pro:setSelected(true)
        end)
    end)
    -- Does: Runs "selection and range widget scenes" and turns the owner-module result into inspectable artifacts.
    -- Shows: The artifacts should expose the behavior produced by lurek.ui.newSlider, lurek.ui.newSpinBox, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/ui/range_widgets_panel.png, tests/artifacts/current/ui/selection_widgets_panel.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.ui.newSlider, lurek.ui.newSpinBox, and related owner calls; export helpers are just the container.

    it("PNG: selection and range widget scenes", function()
        save_scene("range_widgets_panel.png", 340, 310, function()
            local root = lurek.ui.getRoot()
            local range_panel = attach(root, place(lurek.ui.newPanel(), 20, 20, 300, 250, 10))
            range_panel:setTitle("Ranges")

            local slider = attach(range_panel, place(lurek.ui.newSlider(0, 100), 18, 42, 260, 24, 20))
            slider:setValue(72)
            slider:setStep(1)

            local spin = attach(range_panel, place(lurek.ui.newSpinBox(0, 24), 18, 86, 120, 28, 20))
            spin:setStep(2)
            spin:setValue(14)

            local toggle = attach(range_panel, place(lurek.ui.newSwitch(false), 18, 132, 72, 30, 20))
            toggle:setOn(true)

            local progress = attach(range_panel, place(lurek.ui.newProgressBar(0, 100), 18, 182, 260, 22, 20))
            progress:setValue(68)
        end)

        save_scene("selection_widgets_panel.png", 320, 340, function()
            local root = lurek.ui.getRoot()
            local select_panel = attach(root, place(lurek.ui.newPanel(), 20, 20, 280, 280, 10))
            select_panel:setTitle("Selections")
            local combo = attach(select_panel, place(lurek.ui.newComboBox(), 18, 42, 220, 30, 20))
            combo:addItem("Low")
            combo:addItem("Medium")
            combo:addItem("High")
            combo:setSelectedIndex(2)

            local list = attach(select_panel, place(lurek.ui.newList(), 18, 86, 220, 160, 20))
            list:addItem("Warehouse")
            list:addItem("Downtown")
            list:addItem("Harbor")
            list:addItem("Hilltop")
            list:setItemHeight(28)
            list:setSelectedIndex(3)
        end)
    end)
    -- Does: Runs "container and spacing widget scenes" and turns the owner-module result into inspectable artifacts.
    -- Shows: The artifacts should expose the behavior produced by lurek.ui.newPanel, lurek.ui.newLayout, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/ui/container_widget_inspector_panel.png, tests/artifacts/current/ui/container_widget_scroll_bar.png, tests/artifacts/current/ui/container_widget_scroll_panel.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.ui.newPanel, lurek.ui.newLayout, and related owner calls; export helpers are just the container.

    it("PNG: container and spacing widget scenes", function()
        save_scene("container_widget_inspector_panel.png", 320, 260, function()
            local root = lurek.ui.getRoot()
            local panel = attach(root, place(lurek.ui.newPanel(), 20, 20, 280, 210, 20))
            panel:setTitle("Inspector")
            panel:setScrollable(true)

            local layout = attach(panel, place(lurek.ui.newLayout("horizontal"), 18, 42, 230, 36, 30))
            layout:setSpacing(10)
            layout:addChild(lurek.ui.newButton("Apply"))
            layout:addChild(lurek.ui.newSpacer(36, 4))
            layout:addChild(lurek.ui.newButton("Reset"))

            local separator = attach(panel, place(lurek.ui.newSeparator(false), 18, 96, 220, 3, 30))
            separator:setThickness(2)
            attach(panel, place(lurek.ui.newLabel("Reserved gap"), 18, 122, 120, 20, 30))
        end)

        save_scene("container_widget_scroll_panel.png", 300, 260, function()
            local root = lurek.ui.getRoot()
            local scroll = attach(root, place(lurek.ui.newScrollPanel(), 20, 20, 260, 210, 20))
            scroll:setContentSize(240, 520)
            scroll:setScrollPosition(0, 96)
            scroll:addChild(place(lurek.ui.newLabel("Log Entries"), 12, 12, 120, 20, 30))
            scroll:addChild(place(lurek.ui.newLabel("Renderer ready"), 12, 52, 180, 20, 30))
            scroll:addChild(place(lurek.ui.newLabel("Bindings synced"), 12, 120, 180, 20, 30))
            scroll:addChild(place(lurek.ui.newButton("Retry"), 12, 180, 120, 30, 30))
        end)

        save_scene("container_widget_scroll_bar.png", 80, 260, function()
            local root = lurek.ui.getRoot()
            local bar = attach(root, place(lurek.ui.newScrollBar(true), 30, 20, 18, 210, 20))
            bar:setContentSize(520)
            bar:setViewSize(180)
            bar:setScrollPosition(140)
        end)
    end)
    -- Does: Runs "navigation container scenes" and turns the owner-module result into inspectable artifacts.
    -- Shows: The artifacts should expose the behavior produced by lurek.ui.newSplitPanel, lurek.ui.newDockPanel, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/ui/navigation_widget_dock_panel.png, tests/artifacts/current/ui/navigation_widget_split_panel.png, tests/artifacts/current/ui/navigation_widget_status_bar.png, tests/artifacts/current/ui/navigation_widget_tabs.png, tests/artifacts/current/ui/navigation_widget_toolbar.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.ui.newSplitPanel, lurek.ui.newDockPanel, and related owner calls; export helpers are just the container.

    it("PNG: navigation container scenes", function()
        save_scene("navigation_widget_toolbar.png", 260, 100, function()
            local root = lurek.ui.getRoot()
            attach(root, place(lurek.ui.newLabel("Toolbar"), 20, 18, 120, 20, 30))
            local toolbar = attach(root, place(lurek.ui.newToolbar("horizontal"), 20, 42, 220, 34, 20))
            toolbar:addButton("save", "Save")
            toolbar:addSeparator()
            toolbar:addButton("run", "Run")
        end)

        save_scene("navigation_widget_tabs.png", 320, 100, function()
            local root = lurek.ui.getRoot()
            attach(root, place(lurek.ui.newLabel("Tabs"), 20, 18, 120, 20, 30))
            local tabs = attach(root, place(lurek.ui.newTabBar(), 20, 42, 280, 32, 20))
            tabs:addTab("Overview")
            tabs:addTab("Traffic")
            tabs:addTab("Exports")
            tabs:setActiveTab(2)
        end)

        save_scene("navigation_widget_split_panel.png", 420, 320, function()
            local root = lurek.ui.getRoot()
            attach(root, place(lurek.ui.newLabel("Split Panel"), 20, 20, 120, 20, 30))
            local split = attach(root, place(lurek.ui.newSplitPanel("horizontal"), 20, 120, 380, 160, 20))
            local left = place(lurek.ui.newPanel(), 32, 142, 145, 118, 0)
            local right = place(lurek.ui.newPanel(), 198, 142, 188, 118, 0)
            split:addChild(left)
            split:addChild(right)
            split:setFirstChild(left._idx)
            split:setSecondChild(right._idx)
            split:setSplitPosition(0.42)

            attach(root, place(lurek.ui.newLabel("Layers"), 42, 144, 100, 20, 30))
            attach(root, place(lurek.ui.newLabel("Terrain"), 42, 174, 100, 20, 30))
            attach(root, place(lurek.ui.newLabel("Units"), 42, 198, 100, 20, 30))
            attach(root, place(lurek.ui.newLabel("Preview"), 214, 144, 100, 20, 30))
            attach(root, place(lurek.ui.newButton("Play"), 214, 176, 112, 28, 30))
            attach(root, place(lurek.ui.newLabel("Frame 184"), 214, 214, 120, 20, 30))
        end)

        save_scene("navigation_widget_dock_panel.png", 400, 320, function()
            local root = lurek.ui.getRoot()
            attach(root, place(lurek.ui.newLabel("Dock Panel"), 20, 20, 120, 20, 30))
            local dock = attach(root, place(lurek.ui.newDockPanel(), 20, 60, 360, 160, 20))
            local dock_left = place(lurek.ui.newPanel(), 34, 82, 96, 118, 0)
            local dock_bottom = place(lurek.ui.newPanel(), 142, 162, 224, 38, 0)
            dock:addChild(dock_left)
            dock:addChild(dock_bottom)
            dock:dock(dock_left._idx, "left")
            dock:dock(dock_bottom._idx, "bottom")
            dock:setSplitSize("left", 110)
            dock:setSplitSize("bottom", 50)

            attach(root, place(lurek.ui.newLabel("Scenes"), 42, 84, 100, 20, 30))
            attach(root, place(lurek.ui.newLabel("Menu"), 42, 114, 70, 20, 30))
            attach(root, place(lurek.ui.newLabel("HUD"), 42, 138, 70, 20, 30))
            attach(root, place(lurek.ui.newLabel("Console"), 156, 164, 100, 20, 30))
            attach(root, place(lurek.ui.newLabel("Build complete"), 156, 184, 140, 20, 30))
        end)

        save_scene("navigation_widget_status_bar.png", 820, 80, function()
            local root = lurek.ui.getRoot()
            attach(root, place(lurek.ui.newLabel("Status"), 20, 12, 120, 20, 30))
            local status = attach(root, place(lurek.ui.newStatusBar(), 20, 36, 770, 28, 20))
            status:setSectionCount(2)
            status:setSectionText(1, "Ready")
            status:setSectionText(2, "ui live")
        end)
    end)
    -- Does: Runs "popup and menu widget scenes" and turns the owner-module result into inspectable artifacts.
    -- Shows: The artifacts should expose the behavior produced by lurek.ui.newMenuBar, lurek.ui.newMenuItem, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/ui/popup_widget_badge.png, tests/artifacts/current/ui/popup_widget_dialog.png, tests/artifacts/current/ui/popup_widget_menu_bar.png, tests/artifacts/current/ui/popup_widget_toast.png, tests/artifacts/current/ui/popup_widget_tooltip.png, tests/artifacts/current/ui/popup_widget_window.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.ui.newMenuBar, lurek.ui.newMenuItem, and related owner calls; export helpers are just the container.

    it("PNG: popup and menu widget scenes", function()
        save_scene("popup_widget_menu_bar.png", 200, 120, function()
            local root = lurek.ui.getRoot()
            attach(root, place(lurek.ui.newLabel("Menu"), 20, 20, 140, 20, 30))
            local bar = attach(root, place(lurek.ui.newMenuBar(), 20, 60, 140, 28, 20))
            local file_menu = lurek.ui.newMenuItem("File")
            local open_item = lurek.ui.newMenuItem("Open")
            open_item:setShortcut("Ctrl+O")
            local export_item = lurek.ui.newMenuItem("Export")
            export_item:setShortcut("Ctrl+E")
            file_menu:addSubItem(open_item._idx)
            file_menu:addSubItem(export_item._idx)
            bar:addMenu(file_menu._idx)
        end)

        save_scene("popup_widget_badge.png", 80, 80, function()
            local root = lurek.ui.getRoot()
            local badge = attach(root, place(lurek.ui.newBadge(12), 24, 28, 28, 22, 30))
            badge:setCount(12)
        end)

        save_scene("popup_widget_window.png", 300, 340, function()
            local root = lurek.ui.getRoot()
            attach(root, place(lurek.ui.newLabel("Window"), 20, 20, 120, 20, 30))
            local window = attach(root, place(lurek.ui.newWindow("Inventory"), 20, 50, 250, 180, 20))
            window:setDraggable(true)
            window:setResizable(true)
            window:addChild(place(lurek.ui.newLabel("4 items equipped"), 14, 34, 140, 20, 10))
            window:addChild(place(lurek.ui.newButton("Unequip"), 14, 64, 120, 28, 10))
        end)

        save_scene("popup_widget_dialog.png", 320, 320, function()
            local root = lurek.ui.getRoot()
            attach(root, place(lurek.ui.newLabel("Dialog"), 20, 20, 120, 20, 30))
            local dialog = lurek.ui.newDialog("Confirm Purchase")
            dialog:setCenterOnOpen(false)
            dialog:setPosition(20, 50)
            dialog:setSize(260, 180)
            dialog:setModal(true)
            local body = lurek.ui.newPanel()
            body:setSize(220, 96)
            body:addChild(place(lurek.ui.newLabel("Spend 120 credits?"), 12, 18, 160, 20, 10))
            local footer = lurek.ui.newLayout("horizontal")
            footer:setSize(220, 28)
            footer:setSpacing(8)
            dialog:setContent(body._idx)
            dialog:setFooter(footer._idx)
            dialog:addButton("Confirm")
            dialog:addButton("Cancel")
            attach(root, dialog)
            dialog:open()
        end)

        save_scene("popup_widget_tooltip.png", 300, 280, function()
            local root = lurek.ui.getRoot()
            attach(root, place(lurek.ui.newLabel("Tooltip"), 20, 20, 140, 20, 30))
            local target = attach(root, place(lurek.ui.newButton("Hover target"), 20, 50, 160, 34, 20))
            local tooltip = attach(root, place(lurek.ui.newTooltipPanel("Shows sales breakdown"), 20, 96, 220, 56, 20))
            tooltip:setTarget(target._idx)
            tooltip:setDelay(0.25)
        end)

        save_scene("popup_widget_toast.png", 280, 120, function()
            local root = lurek.ui.getRoot()
            local toast = lurek.ui.newToast("Export finished", 3.5)
            toast:setMessage("Export finished")
            place(toast, 20, 50, 220, 34, 20)
            attach(root, toast)
            lurek.ui.addToast(toast)
        end)
    end)
    -- Does: Runs "property widget inspector scene" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose collapsible groups, left-side property names, right-side typed values, select arrows, boolean checks, and color swatches produced by lurek.ui.newPropertyWidget.
    -- Artifact: tests/artifacts/current/ui/property_widget_inspector.png
    -- Why: This is meaningful only if the visible inspector comes from the retained property widget rather than hand-drawn evidence plumbing.

    it("PNG: property widget inspector scene", function()
        save_scene("property_widget_inspector.png", 420, 360, function()
            local root = lurek.ui.getRoot()
            local props = attach(root, place(lurek.ui.newPropertyWidget(), 20, 20, 380, 320, 20))
            props:setLabelWidth(200)

            local video = props:addGroup("Video System", false)
            props:addProperty(video, "Resolution", "UHD - 2160p", "select", { "HD - 1080p", "UHD - 2160p" })
            props:addProperty(video, "Colorimetry", "Rec. 709", "select", { "Rec. 601", "Rec. 709" })
            props:addProperty(video, "Bits Per Channel", 10, "number")

            local settings = props:addGroup("Video Settings", false)
            props:addProperty(settings, "Contains Alpha", false, "bool")
            props:addProperty(settings, "Delay DVE", 1, "number")
            props:addProperty(settings, "Overlay Tint", "#55AAFF", "color")

            local audio = props:addGroup("Audio Settings", false)
            props:addProperty(audio, "Enable Audio", true, "bool")
            props:addProperty(audio, "Audio Channels", "2 Channels", "select", { "2 Channels", "8 Channels" })
            props:addProperty(audio, "Notes", "Preview bus", "text")

            local key = props:addGroup("Key Settings", true)
            props:addProperty(key, "Chroma Clipping", false, "bool")
        end)
    end)
    -- Does: Runs "structured data widget scenes" and turns the owner-module result into inspectable artifacts.
    -- Shows: The artifacts should expose the behavior produced by lurek.ui.newAccordion, lurek.ui.newTreeView, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/ui/structured_widget_accordion.png, tests/artifacts/current/ui/structured_widget_color_picker.png, tests/artifacts/current/ui/structured_widget_custom_surface.png, tests/artifacts/current/ui/structured_widget_table.png, tests/artifacts/current/ui/structured_widget_tree_view.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.ui.newAccordion, lurek.ui.newTreeView, and related owner calls; export helpers are just the container.

    it("PNG: structured data widget scenes", function()
        save_scene("structured_widget_accordion.png", 260, 220, function()
            local root = lurek.ui.getRoot()
            local accordion = attach(root, place(lurek.ui.newAccordion(), 20, 20, 220, 160, 20))
            accordion:addSection("General")
            accordion:addSection("Display")
            accordion:addSection("Automation")
            accordion:toggleSection(2)
        end)

        save_scene("structured_widget_tree_view.png", 260, 240, function()
            local root = lurek.ui.getRoot()
            local tree = attach(root, place(lurek.ui.newTreeView(), 20, 20, 220, 180, 20))
            local tree_root = tree:addNode("Project")
            local src = tree:addNode("src", tree_root)
            tree:addNode("ui_api.rs", src)
            tree:addNode("render.rs", src)
            tree:expandAll()
        end)

        save_scene("structured_widget_table.png", 540, 180, function()
            local root = lurek.ui.getRoot()
            local tbl = attach(root, place(lurek.ui.newTable(), 20, 20, 500, 124, 20))
            tbl:addColumn("Widget")
            tbl:addColumn("State")
            tbl:addColumn("Owner")
            tbl:addRow({ "Button", "ready", "ui-core" })
            tbl:addRow({ "Dialog", "modal", "ui-core" })
            tbl:addRow({ "Table", "selected", "analytics" })
            tbl:setSelectedRow(2)
        end)

        save_scene("structured_widget_color_picker.png", 260, 240, function()
            local root = lurek.ui.getRoot()
            local picker = attach(root, place(lurek.ui.newColorPicker(), 20, 20, 220, 180, 20))
            picker:setColor(0.20, 0.65, 0.95, 1.0)
            picker:setColorMode("hsv")
        end)

        save_scene("structured_widget_custom_surface.png", 260, 160, function()
            local root = lurek.ui.getRoot()
            local custom = attach(root, place(lurek.ui.newCustomWidget({ width = 220, height = 110 }), 20, 20, 220, 110, 20))
            custom:setStyleClass("primary")
            custom:addChild(place(lurek.ui.newLabel("Custom KPI Surface"), 12, 16, 160, 20, 10))
            custom:addChild(place(lurek.ui.newButton("Refresh"), 12, 50, 100, 28, 10))
        end)
    end)
    -- Does: Runs "visual utility widget scenes" and turns the owner-module result into inspectable artifacts.
    -- Shows: The artifacts should expose the behavior produced by lurek.ui.newImageWidget and lurek.ui.newNinePatch without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/ui/visual_widget_image.png, tests/artifacts/current/ui/visual_widget_nine_patch.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.ui.newImageWidget and lurek.ui.newNinePatch; export helpers are just the container.

    it("PNG: visual utility widget scenes", function()
        save_scene("visual_widget_image.png", 300, 240, function()
            local root = lurek.ui.getRoot()
            attach(root, place(lurek.ui.newLabel("Image Widget"), 40, 16, 120, 20, 30))
            local image_widget = attach(root, place(lurek.ui.newImageWidget(), 40, 40, 220, 160, 20))
            image_widget:setScaleMode("stretch")
            image_widget:setTint(1.0, 0.75, 0.35, 1.0)
        end)

        save_scene("visual_widget_nine_patch.png", 320, 260, function()
            local root = lurek.ui.getRoot()
            attach(root, place(lurek.ui.newLabel("Nine Patch"), 20, 16, 120, 20, 30))
            local frame = attach(root, place(lurek.ui.newNinePatch(), 20, 40, 260, 180, 20))
            frame:setImageDimensions(128, 128)
            frame:setInsets(18, 18, 18, 18)
            attach(root, place(lurek.ui.newLabel("Framed utility panel"), 78, 118, 160, 20, 30))
        end)
    end)
end)

-- @describe Evidence: lurek.ui runtime input, drag, and binding flow
describe("Evidence: lurek.ui runtime input, drag, and binding flow", function()
    before_each(function()
        ensure_evidence_dir("ui")
        lurek.ui.clear()
    end)
    -- Does: Runs "runtime input, drag, binding, and layout trace" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.ui.mousepressed, lurek.ui.mousereleased, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/ui/runtime_input_binding_layout_trace.txt
    -- Why: This is meaningful only if the visible/text output comes from lurek.ui.mousepressed, lurek.ui.mousereleased, and related owner calls; export helpers are just the container.

    it("TXT: runtime input, drag, binding, and layout trace", function()
        lurek.ui.setDefaultTheme()
        lurek.ui.setViewport(640, 360)

        local source = lurek.ui.newCustomWidget({
            x = 24,
            y = 24,
            width = 120,
            height = 36,
            id = "ui_evidence_drag_source",
        })
        local target = lurek.ui.newPanel()
        target:setPosition(220, 18)
        target:setSize(180, 96)

        source:bind("hp")

        lurek.ui.beginDrag(source)
        local drag_state = lurek.ui.getActiveDrag()
        expect_not_nil(drag_state)
        expect_no_error(function()
            lurek.ui.dropOn(target)
        end)

        expect_no_error(function() lurek.ui.mousemoved(48, 52) end)
        expect_no_error(function() lurek.ui.mousepressed(48, 52, 1) end)
        expect_no_error(function() lurek.ui.mousereleased(48, 52, 1) end)
        expect_no_error(function() lurek.ui.keypressed("tab") end)
        expect_no_error(function() lurek.ui.textinput("alpha") end)
        expect_no_error(function() lurek.ui.wheelmoved(0, 1) end)

        local bound_update_count = lurek.ui.update_bindings({ hp = 10 })
        local camel_update_count = lurek.ui.updateBindings({ hp = 15 })

        lurek.ui.endDrag()
        expect_nil(lurek.ui.getActiveDrag())

        expect_no_error(function()
            lurek.ui.loadLayoutGameFile(fixture_layout("main_menu_fixture.toml"))
        end)

        local spacing = lurek.ui.getStyleToken("spacing_md")
        local style_type = spacing == nil and "nil" or type(spacing)
        local lines = {
            "drag_started=true",
            "drag_state_present=" .. tostring(drag_state ~= nil),
            "bound_update_count=" .. tostring(bound_update_count),
            "camel_update_count=" .. tostring(camel_update_count),
            "style_token_type=" .. style_type,
            "layout_loaded=" .. fixture_layout("main_menu_fixture.toml"),
            "drag_cleared=" .. tostring(lurek.ui.getActiveDrag() == nil),
        }

        write_text(OUT .. "runtime_input_binding_layout_trace.txt", table.concat(lines, "\n") .. "\n")
    end)
end)

-- @describe Evidence: lurek.ui layout batch rendering
describe("Evidence: lurek.ui layout batch rendering", function()
    before_each(function()
        ensure_evidence_dir("ui")
        lurek.ui.clear()
    end)
    -- Does: Runs "renders all TOML layouts from content/layouts" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.ui.clear, lurek.ui.loadLayoutFile, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/ui/layout_dashboard_fixture.png, tests/artifacts/current/ui/layout_diplomacy_fixture.png, tests/artifacts/current/ui/layout_inventory_fixture.png, tests/artifacts/current/ui/layout_main_menu_fixture.png, tests/artifacts/current/ui/layout_settings_fixture.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.ui.clear, lurek.ui.loadLayoutFile, and related owner calls; export helpers are just the container.

    it("renders all TOML layouts from tests fixtures", function()
        local layout_paths = lurek.filesystem.listRecursive(FIXTURE_LAYOUT_ROOT)
        local rendered = 0

        for _, rel_path in ipairs(layout_paths) do
            if rel_path:match("%.toml$") then
                local layout_path = FIXTURE_LAYOUT_ROOT .. "/" .. rel_path
                local width, height = layout_size(layout_path)
                render_layout(layout_path, layout_output_name(layout_path), width, height)
                rendered = rendered + 1
            end
        end

        expect_true(rendered > 0, "should render at least one TOML fixture layout")
    end)
    -- Does: Runs "writes a layout render manifest" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.ui.loadLayoutFile and lurek.ui.renderToImage without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/ui/layout_gallery_manifest.txt
    -- Why: This is meaningful only if the visible/text output comes from lurek.ui.loadLayoutFile and lurek.ui.renderToImage; export helpers are just the container.

    it("writes a layout render manifest", function()
        local layout_paths = lurek.filesystem.listRecursive(FIXTURE_LAYOUT_ROOT)
        local lines = {}

        for _, rel_path in ipairs(layout_paths) do
            if rel_path:match("%.toml$") then
                local layout_path = FIXTURE_LAYOUT_ROOT .. "/" .. rel_path
                local width, height = layout_size(layout_path)
                local output_name = layout_output_name(layout_path)
                render_layout(layout_path, output_name, width, height)
                lines[#lines + 1] = string.format("%s|%dx%d|%s", layout_path, width, height, OUT .. output_name)
            end
        end

        local manifest_path = OUT .. "layout_gallery_manifest.txt"
        write_text(manifest_path, table.concat(lines, "\n") .. "\n")
    end)
end)
test_summary()
