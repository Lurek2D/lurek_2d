-- test_ui_evidence.lua
-- Canonical evidence file for lurek.ui layouts, widgets, and charts.
-- @covers lurek.binary.parseToml
-- @covers lurek.filesystem.listRecursive
-- @covers lurek.filesystem.read
-- @covers lurek.filesystem.write
-- @covers lurek.image.newImageData
-- @covers lurek.image.savePNG
-- @covers lurek.ui.addToast
-- @covers lurek.ui.beginDrag
-- @covers lurek.ui.clear
-- @covers lurek.ui.dropOn
-- @covers lurek.ui.endDrag
-- @covers lurek.ui.getActiveDrag
-- @covers lurek.ui.getRoot
-- @covers lurek.ui.getStyleToken
-- @covers lurek.ui.keypressed
-- @covers lurek.ui.loadLayoutFile
-- @covers lurek.ui.loadLayoutGameFile
-- @covers lurek.ui.mousemoved
-- @covers lurek.ui.mousepressed
-- @covers lurek.ui.mousereleased
-- @covers lurek.ui.newAccordion
-- @covers lurek.ui.newAreaChart
-- @covers lurek.ui.newBadge
-- @covers lurek.ui.newBarChart
-- @covers lurek.ui.newButton
-- @covers lurek.ui.newCheckbox
-- @covers lurek.ui.newColorPicker
-- @covers lurek.ui.newComboBox
-- @covers lurek.ui.newCustomWidget
-- @covers lurek.ui.newDialog
-- @covers lurek.ui.newDockPanel
-- @covers lurek.ui.newImageWidget
-- @covers lurek.ui.newLabel
-- @covers lurek.ui.newLayout
-- @covers lurek.ui.newLineChart
-- @covers lurek.ui.newList
-- @covers lurek.ui.newMenuBar
-- @covers lurek.ui.newMenuItem
-- @covers lurek.ui.newNinePatch
-- @covers lurek.ui.newPanel
-- @covers lurek.ui.newPieChart
-- @covers lurek.ui.newProgressBar
-- @covers lurek.ui.newRadioButton
-- @covers lurek.ui.newScatterPlot
-- @covers lurek.ui.newScrollBar
-- @covers lurek.ui.newScrollPanel
-- @covers lurek.ui.newSeparator
-- @covers lurek.ui.newSlider
-- @covers lurek.ui.newSpacer
-- @covers lurek.ui.newSpinBox
-- @covers lurek.ui.newSplitPanel
-- @covers lurek.ui.newStatusBar
-- @covers lurek.ui.newSwitch
-- @covers lurek.ui.newTabBar
-- @covers lurek.ui.newTable
-- @covers lurek.ui.newTextInput
-- @covers lurek.ui.newToast
-- @covers lurek.ui.newToolbar
-- @covers lurek.ui.newTooltipPanel
-- @covers lurek.ui.newTreeView
-- @covers lurek.ui.newWindow
-- @covers lurek.ui.renderToImage
-- @covers lurek.ui.setDefaultTheme
-- @covers lurek.ui.setViewport
-- @covers lurek.ui.textinput
-- @covers lurek.ui.update
-- @covers lurek.ui.updateBindings
-- @covers lurek.ui.update_bindings
-- @covers lurek.ui.wheelmoved


local OUT = evidence_output_dir("ui")

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
    local relative = layout_path:gsub("^content/layouts/", "")
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
    local parsed = lurek.binary.parseToml(lurek.filesystem.read(layout_path))
    if parsed.resolution and #parsed.resolution >= 2 then
        return parsed.resolution[1], parsed.resolution[2]
    end

    local root = parsed.root or {}
    return math.max(1, math.floor(root.w or 1280)), math.max(1, math.floor(root.h or 720))
end

local function representative_layouts()
    return {
        "content/layouts/apps/dashboard.toml",
        "content/layouts/apps/chat_app.toml",
        "content/layouts/games/main_menu.toml",
        "content/layouts/games/fps_hud.toml",
    }
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

local function save_chart(chart, w, h, file_name)
    local img = lurek.image.newImageData(w, h)
    img:fill(18, 20, 28, 255)
    chart:drawToImage(img)
    local path = OUT .. file_name
    save_png(img, path)
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

-- @describe Evidence: lurek.ui layouts, widgets, and native charts
describe("Evidence: lurek.ui layouts, widgets, and native charts", function()
    before_each(function()
        ensure_evidence_dir("ui")
        lurek.ui.clear()
    end)

    -- @evidence lurek.ui.renderToImage
    -- @evidence lurek.ui.loadLayoutFile
    it("UI01 PNG: dashboard layout 1280x720", function()
        render_layout_output("content/layouts/apps/dashboard.toml", 1280, 720, "layout_dashboard_desktop_1280x720.png")
    end)

    -- @evidence lurek.ui.renderToImage
    it("UI02 PNG: settings layout 1366x768", function()
        render_layout_output("content/layouts/games/settings_menu.toml", 1366, 768, "layout_settings_desktop_1366x768.png")
    end)

    -- @evidence lurek.ui.renderToImage
    it("UI03 PNG: RPG inventory layout 1280x720", function()
        render_layout_output("content/layouts/games/rpg_inventory.toml", 1280, 720, "layout_rpg_inventory_1280x720.png")
    end)

    -- @evidence lurek.ui.renderToImage
    it("UI04 PNG: strategy diplomacy layout 1400x800", function()
        render_layout_output("content/layouts/games/strategy_world_diplomacy.toml", 1400, 800, "layout_strategy_diplomacy_1400x800.png")
    end)

    -- @evidence lurek.ui.renderToImage
    it("UI05 PNG: dashboard layout mobile-like 960x540", function()
        render_layout_output("content/layouts/apps/dashboard.toml", 960, 540, "layout_dashboard_compact_960x540.png")
    end)

    -- @evidence lurek.ui.renderToImage
    it("UI06 PNG: settings layout ultrawide 1920x1080", function()
        render_layout_output("content/layouts/games/settings_menu.toml", 1920, 1080, "layout_settings_ultrawide_1920x1080.png")
    end)

    -- @evidence lurek.ui.newLineChart
    it("UI07 PNG: line chart widget", function()
        local chart = lurek.ui.newLineChart({
            width = 500,
            height = 300,
            title = "Population Growth",
            xLabel = "Year",
            yLabel = "Population",
            showLegend = true,
            legendWidth = 120,
            xTickCount = 5,
            yTickCount = 5,
        })
        chart:setYMax(120)
        chart:setXMax(10)
        chart:addSeries("city_a", {
            {0, 14}, {1, 20}, {2, 29}, {3, 35}, {4, 47},
            {5, 59}, {6, 68}, {7, 81}, {8, 95}, {9, 107}, {10, 116},
        }, 0.20, 0.55, 0.95)
        chart:addSeries("city_b", {
            {0, 10}, {1, 16}, {2, 22}, {3, 31}, {4, 42},
            {5, 48}, {6, 57}, {7, 66}, {8, 74}, {9, 83}, {10, 92},
        }, 0.85, 0.45, 0.25)

        save_chart(chart, 500, 300, "chart_line_population_growth.png")
    end)

    -- @evidence lurek.image.savePNG
    -- @evidence lurek.ui.newBarChart
    it("UI08 PNG: bar chart widget", function()
        local chart = lurek.ui.newBarChart({
            width = 480,
            height = 280,
            title = "Quarter KPI",
            xLabel = "Quarter",
            yLabel = "Score",
            showLegend = true,
            legendWidth = 120,
            yTickCount = 5,
        })
        chart:addSeries("Team A", 0.95, 0.35, 0.35)
        chart:addSeries("Team B", 0.30, 0.70, 0.90)
        chart:addSeries("Team C", 0.40, 0.85, 0.45)

        chart:addCategory("Q1", { 48, 36, 22 })
        chart:addCategory("Q2", { 56, 42, 28 })
        chart:addCategory("Q3", { 73, 58, 40 })
        chart:addCategory("Q4", { 68, 62, 51 })

        local img = lurek.image.newImageData(480, 280)
        img:fill(18, 20, 28, 255)
        chart:drawToImage(img)
        local path = OUT .. "chart_bar_quarter_kpi.png"
        save_png(img, path)
    end)

    -- @evidence lurek.ui.newPieChart
    it("UI09 PNG: pie chart widget", function()
        local chart = lurek.ui.newPieChart({
            width = 420,
            height = 280,
            title = "Traffic Sources",
            showLegend = true,
            legendWidth = 140,
        })
        chart:addSegment("Organic", 41, 0.30, 0.75, 0.35)
        chart:addSegment("Paid", 24, 0.95, 0.55, 0.20)
        chart:addSegment("Referral", 20, 0.35, 0.55, 0.95)
        chart:addSegment("Direct", 15, 0.85, 0.35, 0.85)

        save_chart(chart, 420, 280, "chart_pie_traffic_sources.png")
    end)

    -- @evidence lurek.image.savePNG
    -- @evidence lurek.ui.newAreaChart
    it("UI10 PNG: area chart widget", function()
        local chart = lurek.ui.newAreaChart({
            width = 520,
            height = 300,
            title = "Capacity Plan",
            xLabel = "Sprint",
            yLabel = "Utilization",
            showLegend = true,
            legendWidth = 120,
            xTickCount = 7,
            yTickCount = 5,
        })
        chart:setYMax(140)
        chart:addLayer("CPU", { 25, 30, 36, 40, 48, 60, 72, 80 }, 0.90, 0.35, 0.35)
        chart:addLayer("GPU", { 15, 21, 28, 34, 39, 45, 50, 56 }, 0.35, 0.70, 0.95)
        chart:addLayer("IO",  { 10, 14, 16, 20, 25, 30, 35, 42 }, 0.40, 0.85, 0.45)

        local img = lurek.image.newImageData(520, 300)
        img:fill(18, 20, 28, 255)
        chart:drawToImage(img)
        local path = OUT .. "chart_area_capacity_plan.png"
        save_png(img, path)
    end)

    -- @evidence lurek.ui.newScatterPlot
    
    it("PNG: scatter plot cluster points", function()
        local chart = lurek.ui.newScatterPlot({
            width = 500,
            height = 300,
            title = "Cluster Points",
            xLabel = "X score",
            yLabel = "Y score",
            showLegend = true,
            legendWidth = 120,
            xTickCount = 6,
            yTickCount = 6,
        })
        local pts1, pts2 = {}, {}
        for i = 1, 25 do
            pts1[i] = { i * 0.04, i * 0.03 + (i % 4) * 0.08 }
            pts2[i] = { i * 0.04, (26 - i) * 0.03 }
        end
        chart:addSeries("alpha", pts1, 0.90, 0.35, 0.25)
        chart:addSeries("beta", pts2, 0.30, 0.65, 0.95)
        chart:setXRange(0, 1.2)
        chart:setYRange(0, 1.2)

        save_chart(chart, 500, 300, "scatter_plot_cluster_points.png")
    end)

    -- @evidence lurek.image.savePNG
    it("PNG: dense line chart signal", function()
        local chart = lurek.ui.newLineChart({
            width = 560,
            height = 320,
            title = "Dense Series",
            xLabel = "Frame",
            yLabel = "Amplitude",
            showLegend = true,
            legendWidth = 120,
            xTickCount = 6,
            yTickCount = 5,
        })
        chart:setYMax(1.0)
        chart:setXMax(120)

        local pts = {}
        for i = 0, 120 do
            local y = 0.5 + math.sin(i * 0.12) * 0.35 + math.cos(i * 0.05) * 0.1
            pts[#pts + 1] = { i, y }
        end
        chart:addSeries("signal", pts, 0.20, 0.80, 0.95)

        local img = lurek.image.newImageData(560, 320)
        img:fill(18, 20, 28, 255)
        chart:drawToImage(img)
        local path = OUT .. "line_chart_dense_signal.png"
        save_png(img, path)
    end)

    -- @evidence lurek.ui.newBarChart
    it("PNG: bar chart monthly production", function()
        local chart = lurek.ui.newBarChart({
            width = 560,
            height = 300,
            title = "Monthly Production",
            xLabel = "Month",
            yLabel = "Units",
            showLegend = true,
            legendWidth = 120,
            yTickCount = 5,
        })
        chart:addSeries("A", 0.90, 0.35, 0.35)
        chart:addSeries("B", 0.35, 0.70, 0.95)

        for m = 1, 12 do
            chart:addCategory("M" .. tostring(m), { 20 + m * 3, 15 + ((m * 7) % 30) })
        end

        save_chart(chart, 560, 300, "bar_chart_monthly_production.png")
    end)

    -- @evidence lurek.image.savePNG
    it("PNG: pie chart revenue mix", function()
        local chart = lurek.ui.newPieChart({
            width = 480,
            height = 300,
            title = "Revenue Mix",
            showLegend = true,
            legendWidth = 140,
        })
        chart:addSegment("A", 28, 0.90, 0.30, 0.30)
        chart:addSegment("B", 21, 0.30, 0.80, 0.40)
        chart:addSegment("C", 16, 0.30, 0.55, 0.95)
        chart:addSegment("D", 13, 0.85, 0.55, 0.20)
        chart:addSegment("E", 12, 0.75, 0.35, 0.85)
        chart:addSegment("F", 10, 0.45, 0.85, 0.85)

        local img = lurek.image.newImageData(480, 300)
        img:fill(18, 20, 28, 255)
        chart:drawToImage(img)
        local path = OUT .. "pie_chart_revenue_mix.png"
        save_png(img, path)
    end)

    -- @evidence lurek.ui.newAreaChart
    it("PNG: stacked area chart capacity plan", function()
        local chart = lurek.ui.newAreaChart({
            width = 560,
            height = 320,
            title = "Stacked Capacity",
            xLabel = "Slice",
            yLabel = "Load",
            showLegend = true,
            legendWidth = 120,
            xTickCount = 7,
            yTickCount = 5,
        })
        chart:setYMax(220)
        chart:addLayer("L1", { 20, 25, 29, 33, 36, 41, 46, 50 }, 0.90, 0.35, 0.35)
        chart:addLayer("L2", { 18, 22, 26, 28, 34, 39, 44, 47 }, 0.35, 0.70, 0.95)
        chart:addLayer("L3", { 15, 19, 22, 26, 29, 33, 38, 42 }, 0.35, 0.85, 0.45)
        chart:addLayer("L4", { 12, 15, 19, 21, 24, 28, 31, 35 }, 0.85, 0.75, 0.35)

        save_chart(chart, 560, 320, "area_chart_stacked_capacity.png")
    end)

    -- @evidence lurek.ui.newLineChart
    -- @evidence lurek.ui.newBarChart
    -- @evidence lurek.ui.newPieChart
    -- @evidence lurek.ui.newScatterPlot
    -- @evidence lurek.image.savePNG
    it("PNG: analytics chart contact sheet", function()
        local canvas = lurek.image.newImageData(1080, 760)
        canvas:fill(14, 18, 24, 255)

        local line = lurek.ui.newLineChart({
            width = 500, height = 320, title = "Retention Cohorts",
            xLabel = "Week", yLabel = "Users", showLegend = true, legendWidth = 120,
            xTickCount = 6, yTickCount = 5,
        })
        line:setYMax(160)
        line:setXMax(12)
        line:addSeries("cohort_a", {
            {0, 148}, {2, 132}, {4, 118}, {6, 106}, {8, 94}, {10, 86}, {12, 80},
        }, 0.30, 0.70, 0.98)
        line:addSeries("cohort_b", {
            {0, 126}, {2, 110}, {4, 96}, {6, 88}, {8, 78}, {10, 70}, {12, 64},
        }, 0.95, 0.58, 0.24)
        local line_img = lurek.image.newImageData(500, 320)
        line_img:fill(18, 20, 28, 255)
        line:drawToImage(line_img)

        local bar = lurek.ui.newBarChart({
            width = 500, height = 320, title = "Region Orders",
            xLabel = "Region", yLabel = "Orders", showLegend = true, legendWidth = 130,
            yTickCount = 5,
        })
        bar:addSeries("fulfilled", 0.26, 0.78, 0.52)
        bar:addSeries("returned", 0.92, 0.42, 0.42)
        bar:addCategory("North", { 84, 8 })
        bar:addCategory("South", { 72, 12 })
        bar:addCategory("East", { 93, 6 })
        bar:addCategory("West", { 68, 10 })
        local bar_img = lurek.image.newImageData(500, 320)
        bar_img:fill(18, 20, 28, 255)
        bar:drawToImage(bar_img)

        local pie = lurek.ui.newPieChart({
            width = 300, height = 220, title = "Channel Mix",
            showLegend = true, legendWidth = 120,
        })
        pie:addSegment("Search", 35, 0.34, 0.74, 0.96)
        pie:addSegment("Email", 22, 0.34, 0.82, 0.46)
        pie:addSegment("Ads", 18, 0.94, 0.56, 0.24)
        pie:addSegment("Direct", 15, 0.86, 0.38, 0.84)
        pie:addSegment("Social", 10, 0.92, 0.38, 0.42)
        local pie_img = lurek.image.newImageData(300, 220)
        pie_img:fill(18, 20, 28, 255)
        pie:drawToImage(pie_img)

        local scatter = lurek.ui.newScatterPlot({
            width = 300, height = 220, title = "Latency Clusters",
            xLabel = "CPU ms", yLabel = "GPU ms", showLegend = true, legendWidth = 110,
            xTickCount = 5, yTickCount = 5,
        })
        local fast, slow = {}, {}
        for i = 1, 18 do
            fast[i] = { 2.0 + i * 0.18, 1.6 + (i % 5) * 0.35 }
            slow[i] = { 4.4 + i * 0.12, 3.0 + (i % 4) * 0.42 }
        end
        scatter:addSeries("fast", fast, 0.28, 0.78, 0.52)
        scatter:addSeries("slow", slow, 0.94, 0.48, 0.26)
        scatter:setXRange(0, 8.0)
        scatter:setYRange(0, 6.0)
        local scatter_img = lurek.image.newImageData(300, 220)
        scatter_img:fill(18, 20, 28, 255)
        scatter:drawToImage(scatter_img)

        canvas:paste(line_img, 24, 24)
        canvas:paste(bar_img, 556, 24)
        canvas:paste(pie_img, 120, 430)
        canvas:paste(scatter_img, 660, 430)
        draw_outline(canvas, 24, 24, 500, 320, 230, 234, 242, 255)
        draw_outline(canvas, 556, 24, 500, 320, 230, 234, 242, 255)
        draw_outline(canvas, 120, 430, 300, 220, 230, 234, 242, 255)
        draw_outline(canvas, 660, 430, 300, 220, 230, 234, 242, 255)

        local path = OUT .. "chart_analytics_contact_sheet.png"
        save_png(canvas, path)
    end)

    -- @evidence lurek.ui.newButton
    -- @evidence lurek.ui.newLabel
    -- @evidence lurek.ui.newTextInput
    -- @evidence lurek.ui.newCheckbox
    -- @evidence lurek.ui.newRadioButton
    it("PNG: form widgets account panel", function()
        save_scene("form_widgets_account_panel.png", 960, 540, function()
            local root = lurek.ui.getRoot()

            local panel = attach(root, place(lurek.ui.newPanel(), 24, 24, 420, 220, 10))
            panel:setTitle("Account")

            local title = attach(panel, place(lurek.ui.newLabel("Profile Details"), 18, 34, 180, 24, 20))
            title:setStyleClass("primary")

            local action = attach(panel, place(lurek.ui.newButton("Save Changes"), 18, 150, 160, 34, 20))
            action:setRole("button")

            local name = attach(panel, place(lurek.ui.newTextInput(), 18, 78, 220, 30, 20))
            name:setText("tombl.dev")

            local newsletter = attach(panel, place(lurek.ui.newCheckbox("Send weekly report"), 18, 116, 220, 24, 20))
            newsletter:setChecked(true)

            local plan_panel = attach(root, place(lurek.ui.newPanel(), 470, 24, 260, 160, 10))
            plan_panel:setTitle("Plan")
            local cash = attach(plan_panel, place(lurek.ui.newRadioButton("Starter", "plan"), 18, 50, 140, 24, 20))
            local pro = attach(plan_panel, place(lurek.ui.newRadioButton("Pro", "plan"), 18, 82, 140, 24, 20))
            pro:setSelected(true)
        end)
    end)

    -- @evidence lurek.ui.newSlider
    -- @evidence lurek.ui.newSpinBox
    -- @evidence lurek.ui.newSwitch
    -- @evidence lurek.ui.newProgressBar
    -- @evidence lurek.ui.newComboBox
    -- @evidence lurek.ui.newList
    it("PNG: selection and range widgets gallery", function()
        save_scene("selection_widgets_controls_gallery.png", 960, 560, function()
            local root = lurek.ui.getRoot()
            local range_panel = attach(root, place(lurek.ui.newPanel(), 24, 24, 300, 250, 10))
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

            local select_panel = attach(root, place(lurek.ui.newPanel(), 350, 24, 280, 280, 10))
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

    -- @evidence lurek.ui.newPanel
    -- @evidence lurek.ui.newLayout
    -- @evidence lurek.ui.newScrollPanel
    -- @evidence lurek.ui.newScrollBar
    -- @evidence lurek.ui.newSeparator
    -- @evidence lurek.ui.newSpacer
    it("PNG: container and spacing widgets gallery", function()
        save_scene("container_widgets_inspector_scroll_gallery.png", 760, 320, function()
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

            local scroll = attach(root, place(lurek.ui.newScrollPanel(), 330, 20, 260, 210, 20))
            scroll:setContentSize(240, 520)
            scroll:setScrollPosition(0, 96)
            scroll:addChild(place(lurek.ui.newLabel("Log Entries"), 12, 12, 120, 20, 30))
            scroll:addChild(place(lurek.ui.newLabel("Renderer ready"), 12, 52, 180, 20, 30))
            scroll:addChild(place(lurek.ui.newLabel("Bindings synced"), 12, 120, 180, 20, 30))
            scroll:addChild(place(lurek.ui.newButton("Retry"), 12, 180, 120, 30, 30))

            local bar = attach(root, place(lurek.ui.newScrollBar(true), 610, 20, 18, 210, 20))
            bar:setContentSize(520)
            bar:setViewSize(180)
            bar:setScrollPosition(140)
        end)
    end)

    -- @evidence lurek.ui.newSplitPanel
    -- @evidence lurek.ui.newDockPanel
    -- @evidence lurek.ui.newToolbar
    -- @evidence lurek.ui.newStatusBar
    -- @evidence lurek.ui.newTabBar
    it("PNG: navigation containers workspace shell", function()
        save_scene("navigation_widgets_workspace_shell.png", 920, 380, function()
            local root = lurek.ui.getRoot()
            attach(root, place(lurek.ui.newLabel("Toolbar"), 20, 18, 120, 20, 30))
            local toolbar = attach(root, place(lurek.ui.newToolbar("horizontal"), 20, 42, 220, 34, 20))
            toolbar:addButton("save", "Save")
            toolbar:addSeparator()
            toolbar:addButton("run", "Run")

            attach(root, place(lurek.ui.newLabel("Tabs"), 270, 18, 120, 20, 30))
            local tabs = attach(root, place(lurek.ui.newTabBar(), 270, 42, 280, 32, 20))
            tabs:addTab("Overview")
            tabs:addTab("Traffic")
            tabs:addTab("Exports")
            tabs:setActiveTab(2)

            attach(root, place(lurek.ui.newLabel("Split Panel"), 20, 96, 120, 20, 30))
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

            attach(root, place(lurek.ui.newLabel("Dock Panel"), 430, 96, 120, 20, 30))
            local dock = attach(root, place(lurek.ui.newDockPanel(), 430, 120, 360, 160, 20))
            local dock_left = place(lurek.ui.newPanel(), 444, 142, 96, 118, 0)
            local dock_bottom = place(lurek.ui.newPanel(), 552, 222, 224, 38, 0)
            dock:addChild(dock_left)
            dock:addChild(dock_bottom)
            dock:dock(dock_left._idx, "left")
            dock:dock(dock_bottom._idx, "bottom")
            dock:setSplitSize("left", 110)
            dock:setSplitSize("bottom", 50)

            attach(root, place(lurek.ui.newLabel("Scenes"), 452, 144, 100, 20, 30))
            attach(root, place(lurek.ui.newLabel("Menu"), 452, 174, 70, 20, 30))
            attach(root, place(lurek.ui.newLabel("HUD"), 452, 198, 70, 20, 30))
            attach(root, place(lurek.ui.newLabel("Console"), 566, 224, 100, 20, 30))
            attach(root, place(lurek.ui.newLabel("Build complete"), 566, 244, 140, 20, 30))

            attach(root, place(lurek.ui.newLabel("Status"), 20, 300, 120, 20, 30))
            local status = attach(root, place(lurek.ui.newStatusBar(), 20, 324, 770, 28, 20))
            status:setSectionCount(2)
            status:setSectionText(1, "Ready")
            status:setSectionText(2, "ui live")
        end)
    end)

    -- @evidence lurek.ui.newMenuBar
    -- @evidence lurek.ui.newMenuItem
    -- @evidence lurek.ui.newWindow
    -- @evidence lurek.ui.newDialog
    -- @evidence lurek.ui.newTooltipPanel
    -- @evidence lurek.ui.newToast
    -- @evidence lurek.ui.newBadge
    it("PNG: popup and menu widgets gallery", function()
        save_scene("popup_widgets_window_dialog_toast.png", 940, 380, function()
            local root = lurek.ui.getRoot()
            attach(root, place(lurek.ui.newLabel("Menu / badge"), 20, 36, 140, 20, 30))
            local bar = attach(root, place(lurek.ui.newMenuBar(), 20, 60, 140, 28, 20))
            local file_menu = lurek.ui.newMenuItem("File")
            local open_item = lurek.ui.newMenuItem("Open")
            open_item:setShortcut("Ctrl+O")
            local export_item = lurek.ui.newMenuItem("Export")
            export_item:setShortcut("Ctrl+E")
            file_menu:addSubItem(open_item._idx)
            file_menu:addSubItem(export_item._idx)
            bar:addMenu(file_menu._idx)

            local badge = attach(root, place(lurek.ui.newBadge(12), 176, 62, 28, 22, 30))
            badge:setCount(12)

            attach(root, place(lurek.ui.newLabel("Window"), 20, 104, 120, 20, 30))
            local window = attach(root, place(lurek.ui.newWindow("Inventory"), 20, 130, 250, 180, 20))
            window:setDraggable(true)
            window:setResizable(true)
            window:addChild(place(lurek.ui.newLabel("4 items equipped"), 14, 34, 140, 20, 10))
            window:addChild(place(lurek.ui.newButton("Unequip"), 14, 64, 120, 28, 10))

            attach(root, place(lurek.ui.newLabel("Dialog"), 320, 104, 120, 20, 30))
            local dialog = lurek.ui.newDialog("Confirm Purchase")
            dialog:setCenterOnOpen(false)
            dialog:setPosition(320, 130)
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

            attach(root, place(lurek.ui.newLabel("Tooltip / toast"), 620, 104, 140, 20, 30))
            local target = attach(root, place(lurek.ui.newButton("Hover target"), 620, 130, 160, 34, 20))
            local tooltip = attach(root, place(lurek.ui.newTooltipPanel("Shows sales breakdown"), 620, 176, 220, 56, 20))
            tooltip:setTarget(target._idx)
            tooltip:setDelay(0.25)

            local toast = lurek.ui.newToast("Export finished", 3.5)
            toast:setMessage("Export finished")
            place(toast, 620, 264, 220, 34, 20)
            attach(root, toast)
            lurek.ui.addToast(toast)
        end)
    end)

    -- @evidence lurek.ui.newAccordion
    -- @evidence lurek.ui.newTreeView
    -- @evidence lurek.ui.newTable
    -- @evidence lurek.ui.newColorPicker
    -- @evidence lurek.ui.newCustomWidget
    it("PNG: structured data widgets gallery", function()
        save_scene("structured_widgets_table_tree_picker.png", 920, 460, function()
            local root = lurek.ui.getRoot()
            local accordion = attach(root, place(lurek.ui.newAccordion(), 20, 20, 220, 160, 20))
            accordion:addSection("General")
            accordion:addSection("Display")
            accordion:addSection("Automation")
            accordion:toggleSection(2)

            local tree = attach(root, place(lurek.ui.newTreeView(), 260, 20, 220, 180, 20))
            local tree_root = tree:addNode("Project")
            local src = tree:addNode("src", tree_root)
            tree:addNode("ui_api.rs", src)
            tree:addNode("render.rs", src)
            tree:expandAll()

            local tbl = attach(root, place(lurek.ui.newTable(), 20, 218, 500, 124, 20))
            tbl:addColumn("Widget")
            tbl:addColumn("State")
            tbl:addColumn("Owner")
            tbl:addRow({ "Button", "ready", "ui-core" })
            tbl:addRow({ "Dialog", "modal", "ui-core" })
            tbl:addRow({ "Table", "selected", "analytics" })
            tbl:setSelectedRow(2)

            local picker = attach(root, place(lurek.ui.newColorPicker(), 500, 20, 220, 180, 20))
            picker:setColor(0.20, 0.65, 0.95, 1.0)
            picker:setColorMode("hsv")

            local custom = attach(root, place(lurek.ui.newCustomWidget({ width = 220, height = 110 }), 560, 228, 220, 110, 20))
            custom:setStyleClass("primary")
            custom:addChild(place(lurek.ui.newLabel("Custom KPI Surface"), 12, 16, 160, 20, 10))
            custom:addChild(place(lurek.ui.newButton("Refresh"), 12, 50, 100, 28, 10))
        end)
    end)

    -- @evidence lurek.ui.newImageWidget
    -- @evidence lurek.ui.newNinePatch
    it("PNG: visual utility widgets gallery", function()
        save_scene("visual_widgets_image_nine_patch.png", 660, 260, function()
            local root = lurek.ui.getRoot()
            attach(root, place(lurek.ui.newLabel("Image Widget"), 40, 16, 120, 20, 30))
            local image_widget = attach(root, place(lurek.ui.newImageWidget(), 40, 40, 220, 160, 20))
            image_widget:setScaleMode("stretch")
            image_widget:setTint(1.0, 0.75, 0.35, 1.0)

            attach(root, place(lurek.ui.newLabel("Nine Patch"), 320, 16, 120, 20, 30))
            local frame = attach(root, place(lurek.ui.newNinePatch(), 320, 40, 260, 180, 20))
            frame:setImageDimensions(128, 128)
            frame:setInsets(18, 18, 18, 18)
            attach(root, place(lurek.ui.newLabel("Framed utility panel"), 378, 118, 160, 20, 30))
        end)
    end)
end)

-- @describe Evidence: lurek.ui runtime input, drag, and binding flow
describe("Evidence: lurek.ui runtime input, drag, and binding flow", function()
    before_each(function()
        ensure_evidence_dir("ui")
        lurek.ui.clear()
    end)

    -- @evidence lurek.ui.mousepressed
    -- @evidence lurek.ui.mousereleased
    -- @evidence lurek.ui.mousemoved
    -- @evidence lurek.ui.keypressed
    -- @evidence lurek.ui.textinput
    -- @evidence lurek.ui.wheelmoved
    -- @evidence lurek.ui.beginDrag
    -- @evidence lurek.ui.getActiveDrag
    -- @evidence lurek.ui.dropOn
    -- @evidence lurek.ui.endDrag
    -- @evidence lurek.ui.update_bindings
    -- @evidence lurek.ui.updateBindings
    -- @evidence lurek.ui.loadLayoutGameFile
    -- @evidence lurek.ui.getStyleToken
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
            lurek.ui.loadLayoutGameFile("content/examples/assets/layouts/sample_main_menu.toml")
        end)

        local spacing = lurek.ui.getStyleToken("spacing_md")
        local style_type = spacing == nil and "nil" or type(spacing)
        local lines = {
            "drag_started=true",
            "drag_state_present=" .. tostring(drag_state ~= nil),
            "bound_update_count=" .. tostring(bound_update_count),
            "camel_update_count=" .. tostring(camel_update_count),
            "style_token_type=" .. style_type,
            "layout_loaded=content/examples/assets/layouts/sample_main_menu.toml",
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

    -- @evidence lurek.filesystem.listRecursive
    -- @evidence lurek.ui.clear
    -- @evidence lurek.ui.loadLayoutFile
    -- @evidence lurek.ui.renderToImage
    it("renders all TOML layouts from content/layouts", function()
        local layout_paths = lurek.filesystem.listRecursive("content/layouts")
        local rendered = 0

        for _, rel_path in ipairs(layout_paths) do
            if rel_path:match("%.toml$") then
                local layout_path = "content/layouts/" .. rel_path
                local width, height = layout_size(layout_path)
                render_layout(layout_path, layout_output_name(layout_path), width, height)
                rendered = rendered + 1
            end
        end

        expect_true(rendered > 0, "should render at least one TOML layout from content/layouts")
    end)

    -- @evidence lurek.ui.loadLayoutFile
    -- @evidence lurek.ui.renderToImage
    -- @evidence lurek.image.savePNG
    it("builds a representative layout contact sheet", function()
        local thumb_w, thumb_h = 240, 135
        local canvas = lurek.image.newImageData(thumb_w * 2, thumb_h * 2)
        canvas:fill(12, 14, 18, 255)

        local layouts = representative_layouts()
        for i, layout_path in ipairs(layouts) do
            local output_name = layout_output_name(layout_path)
            local width, height = layout_size(layout_path)
            render_layout(layout_path, output_name, width, height)

            local img = lurek.image.newImageData(OUT .. output_name)
            local thumb = img:resize(thumb_w, thumb_h, "bilinear")
            local col = (i - 1) % 2
            local row = math.floor((i - 1) / 2)
            canvas:paste(thumb, col * thumb_w, row * thumb_h)
            draw_outline(canvas, col * thumb_w, row * thumb_h, thumb_w, thumb_h, 220, 220, 230, 255)
        end

        local contact_path = OUT .. "layout_gallery_contact_sheet.png"
        save_png(canvas, contact_path)
    end)

    -- @evidence lurek.filesystem.listRecursive
    -- @evidence lurek.ui.loadLayoutFile
    -- @evidence lurek.ui.renderToImage
    it("writes a layout render manifest", function()
        local layout_paths = lurek.filesystem.listRecursive("content/layouts")
        local lines = {}

        for _, rel_path in ipairs(layout_paths) do
            if rel_path:match("%.toml$") then
                local layout_path = "content/layouts/" .. rel_path
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
