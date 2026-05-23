-- Evidence tests: advanced UI
-- Artifacts are generated through lurek.ui native rendering APIs.
-- @covers lurek.image.newImageData
-- @covers lurek.image.savePNG
-- @covers lurek.ui.clear
-- @covers lurek.ui.loadLayoutFile
-- @covers lurek.ui.newAreaChart
-- @covers lurek.ui.newBarChart
-- @covers lurek.ui.newLineChart
-- @covers lurek.ui.newPieChart
-- @covers lurek.ui.newScatterPlot
-- @covers lurek.ui.renderToImage


local OUT = "tests/output/ui_advanced/"

local function render_layout(layout_path, output_name, width, height)
    lurek.ui.clear()
    lurek.ui.loadLayoutFile(layout_path)
    local path = OUT .. output_name
    lurek.ui.renderToImage(width, height, path)
    expect_evidence_created(path)
    return path
end

local function save_chart(chart, w, h, file_name)
    local img = lurek.image.newImageData(w, h)
    img:fill(18, 20, 28, 255)
    chart:drawToImage(img)
    local path = OUT .. file_name
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
    return path
end

-- @describe Evidence: advanced lurek.ui features via native API
describe("Evidence: advanced lurek.ui features via native API", function()
    before_each(function()
        ensure_evidence_dir("ui_advanced")
        lurek.ui.clear()
    end)

    -- @evidence file
    it("UI01 PNG: dashboard layout 1280x720", function()
        render_layout("content/layouts/apps/dashboard.toml", "ui01_dashboard_1280x720.png", 1280, 720)
    end)

    -- @evidence file
    it("UI02 PNG: settings layout 1366x768", function()
        render_layout("content/layouts/games/settings_menu.toml", "ui02_settings_1366x768.png", 1366, 768)
    end)

    -- @evidence file
    it("UI03 PNG: RPG inventory layout 1280x720", function()
        render_layout("content/layouts/games/rpg_inventory.toml", "ui03_inventory_1280x720.png", 1280, 720)
    end)

    -- @evidence file
    it("UI04 PNG: strategy diplomacy layout 1400x800", function()
        render_layout("content/layouts/games/strategy_world_diplomacy.toml", "ui04_diplomacy_1400x800.png", 1400, 800)
    end)

    -- @evidence file
    it("UI05 PNG: dashboard layout mobile-like 960x540", function()
        render_layout("content/layouts/apps/dashboard.toml", "ui05_dashboard_960x540.png", 960, 540)
    end)

    -- @evidence file
    it("UI06 PNG: settings layout ultrawide 1920x1080", function()
        render_layout("content/layouts/games/settings_menu.toml", "ui06_settings_1920x1080.png", 1920, 1080)
    end)

    -- @evidence file
    it("UI07 PNG: line chart widget", function()
        local chart = lurek.ui.newLineChart({ width = 500, height = 300, title = "Population Growth" })
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

        save_chart(chart, 500, 300, "ui07_line_chart.png")
    end)

    -- @evidence file
    it("UI08 PNG: bar chart widget", function()
        local chart = lurek.ui.newBarChart({ width = 480, height = 280, title = "Quarter KPI" })
        chart:addSeries("Team A", 0.95, 0.35, 0.35)
        chart:addSeries("Team B", 0.30, 0.70, 0.90)
        chart:addSeries("Team C", 0.40, 0.85, 0.45)

        chart:addCategory("Q1", { 48, 36, 22 })
        chart:addCategory("Q2", { 56, 42, 28 })
        chart:addCategory("Q3", { 73, 58, 40 })
        chart:addCategory("Q4", { 68, 62, 51 })

        save_chart(chart, 480, 280, "ui08_bar_chart.png")
    end)

    -- @evidence file
    it("UI09 PNG: pie chart widget", function()
        local chart = lurek.ui.newPieChart({ width = 420, height = 280, title = "Traffic Sources" })
        chart:addSegment("Organic", 41, 0.30, 0.75, 0.35)
        chart:addSegment("Paid", 24, 0.95, 0.55, 0.20)
        chart:addSegment("Referral", 20, 0.35, 0.55, 0.95)
        chart:addSegment("Direct", 15, 0.85, 0.35, 0.85)

        save_chart(chart, 420, 280, "ui09_pie_chart.png")
    end)

    -- @evidence file
    it("UI10 PNG: area chart widget", function()
        local chart = lurek.ui.newAreaChart({ width = 520, height = 300, title = "Capacity Plan" })
        chart:setYMax(140)
        chart:addLayer("CPU", { 25, 30, 36, 40, 48, 60, 72, 80 }, 0.90, 0.35, 0.35)
        chart:addLayer("GPU", { 15, 21, 28, 34, 39, 45, 50, 56 }, 0.35, 0.70, 0.95)
        chart:addLayer("IO",  { 10, 14, 16, 20, 25, 30, 35, 42 }, 0.40, 0.85, 0.45)

        save_chart(chart, 520, 300, "ui10_area_chart.png")
    end)

    -- @evidence file
    it("UI11 PNG: scatter plot widget", function()
        local chart = lurek.ui.newScatterPlot({ width = 500, height = 300, title = "Cluster Points" })
        local pts1, pts2 = {}, {}
        for i = 1, 25 do
            pts1[i] = { x = i * 0.04, y = i * 0.03 + (i % 4) * 0.08 }
            pts2[i] = { x = i * 0.04, y = (26 - i) * 0.03 }
        end
        chart:addSeries("alpha", pts1, 0.90, 0.35, 0.25)
        chart:addSeries("beta", pts2, 0.30, 0.65, 0.95)
        chart:setXRange(0, 1.2)
        chart:setYRange(0, 1.2)

        save_chart(chart, 500, 300, "ui11_scatter_chart.png")
    end)

    -- @evidence file
    it("UI12 PNG: dense line chart", function()
        local chart = lurek.ui.newLineChart({ width = 560, height = 320, title = "Dense Series" })
        chart:setYMax(1.0)
        chart:setXMax(120)

        local pts = {}
        for i = 0, 120 do
            local y = 0.5 + math.sin(i * 0.12) * 0.35 + math.cos(i * 0.05) * 0.1
            pts[#pts + 1] = { i, y }
        end
        chart:addSeries("signal", pts, 0.20, 0.80, 0.95)

        save_chart(chart, 560, 320, "ui12_line_dense.png")
    end)

    -- @evidence file
    it("UI13 PNG: bar chart 12 categories", function()
        local chart = lurek.ui.newBarChart({ width = 560, height = 300, title = "Monthly Production" })
        chart:addSeries("A", 0.90, 0.35, 0.35)
        chart:addSeries("B", 0.35, 0.70, 0.95)

        for m = 1, 12 do
            chart:addCategory("M" .. tostring(m), { 20 + m * 3, 15 + ((m * 7) % 30) })
        end

        save_chart(chart, 560, 300, "ui13_bar_12cats.png")
    end)

    -- @evidence file
    it("UI14 PNG: pie chart 6 segments", function()
        local chart = lurek.ui.newPieChart({ width = 480, height = 300, title = "Revenue Mix" })
        chart:addSegment("A", 28, 0.90, 0.30, 0.30)
        chart:addSegment("B", 21, 0.30, 0.80, 0.40)
        chart:addSegment("C", 16, 0.30, 0.55, 0.95)
        chart:addSegment("D", 13, 0.85, 0.55, 0.20)
        chart:addSegment("E", 12, 0.75, 0.35, 0.85)
        chart:addSegment("F", 10, 0.45, 0.85, 0.85)

        save_chart(chart, 480, 300, "ui14_pie_6seg.png")
    end)

    -- @evidence file
    it("UI15 PNG: area chart 4 layers", function()
        local chart = lurek.ui.newAreaChart({ width = 560, height = 320, title = "Stacked Capacity" })
        chart:setYMax(220)
        chart:addLayer("L1", { 20, 25, 29, 33, 36, 41, 46, 50 }, 0.90, 0.35, 0.35)
        chart:addLayer("L2", { 18, 22, 26, 28, 34, 39, 44, 47 }, 0.35, 0.70, 0.95)
        chart:addLayer("L3", { 15, 19, 22, 26, 29, 33, 38, 42 }, 0.35, 0.85, 0.45)
        chart:addLayer("L4", { 12, 15, 19, 21, 24, 28, 31, 35 }, 0.85, 0.75, 0.35)

        save_chart(chart, 560, 320, "ui15_area_4layers.png")
    end)
end)

test_summary()
