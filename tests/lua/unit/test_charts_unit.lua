-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_charts_core_unit.lua
do
-- Lurek2D Charts API Tests

-- @describe lurek.charts constructors
describe("lurek.charts constructors", function()
    -- @covers lurek.charts.newLine
    it("newLine returns userdata", function()
        local chart = lurek.charts.newLine()
        expect_type("userdata", chart)
    end)

    -- @covers lurek.charts.newBar
    it("newBar returns userdata", function()
        local chart = lurek.charts.newBar()
        expect_type("userdata", chart)
    end)

    -- @covers lurek.charts.newScatter
    it("newScatter returns userdata", function()
        local chart = lurek.charts.newScatter()
        expect_type("userdata", chart)
    end)

    -- @covers lurek.charts.newPie
    it("newPie returns userdata", function()
        local chart = lurek.charts.newPie()
        expect_type("userdata", chart)
    end)

    -- @covers lurek.charts.newArea
    it("newArea returns userdata", function()
        local chart = lurek.charts.newArea()
        expect_type("userdata", chart)
    end)
end)

-- @describe lurek.charts palette helpers
describe("lurek.charts palette helpers", function()
    -- @covers lurek.charts.defaultPalette
    it("defaultPalette returns eight rgba entries", function()
        local pal = lurek.charts.defaultPalette()
        expect_equal(8, #pal)
        for i = 1, #pal do
            expect_equal(4, #pal[i])
            expect_true(pal[i][1] >= 0 and pal[i][1] <= 1)
            expect_true(pal[i][4] >= 0 and pal[i][4] <= 1)
        end
    end)

    -- @covers lurek.charts.seriesColor
    it("seriesColor returns rgba values, wraps indices, and rejects zero", function()
        local c1 = lurek.charts.seriesColor(1)
        local c9 = lurek.charts.seriesColor(9)
        expect_equal(4, #c1)
        expect_type("number", c1[1])
        expect_near(c1[1], c9[1], 0.01)
        expect_near(c1[2], c9[2], 0.01)
        expect_near(c1[3], c9[3], 0.01)
        expect_near(c1[4], c9[4], 0.01)
        expect_error(function()
            lurek.charts.seriesColor(0)
        end)
    end)
end)

local function image_has_drawn_pixels(img)
    for y = 0, img:getHeight() - 1 do
        for x = 0, img:getWidth() - 1 do
            local r, g, b, a = img:getPixel(x, y)
            if r ~= 0 or g ~= 0 or b ~= 0 or a ~= 0 then
                return true
            end
        end
    end
    return false
end

local function expect_chart_draws(chart, width, height)
    local img = lurek.image.newImageData(width, height)
    chart:drawToImage(img)
    expect_true(image_has_drawn_pixels(img))
end

-- @describe LuaLineChart methods
describe("LuaLineChart methods", function()
    -- @covers LLineChart:getWidth
    it("getWidth returns configured width", function()
        local chart = lurek.charts.newLine({ width = 800, height = 600 })
        expect_equal(800, chart:getWidth())
    end)

    -- @covers LLineChart:getHeight
    it("getHeight returns configured height", function()
        local chart = lurek.charts.newLine({ width = 800, height = 600 })
        expect_equal(600, chart:getHeight())
    end)

    -- @covers LLineChart:addSeries
    it("addSeries accepts point pairs before render", function()
        local chart = lurek.charts.newLine()
        chart:addSeries("test", {{1, 2}, {3, 4}, {5, 6}})
        local w, h, data = chart:render()
        expect_true(w > 0)
        expect_true(h > 0)
        expect_true(#data > 0)
    end)

    -- @covers LLineChart:render
    it("render returns width, height, and byte data", function()
        local chart = lurek.charts.newLine()
        chart:addSeries("test", {{1, 2}, {3, 4}})
        local w, h, data = chart:render()
        expect_true(w > 0)
        expect_true(h > 0)
        expect_type("string", data)
    end)

    -- @covers LLineChart:replaceSeries
    it("replaceSeries swaps line data and keeps render working", function()
        local chart = lurek.charts.newLine({ width = 96, height = 72 })
        chart:addSeries("test", {{1, 2}, {2, 4}})
        chart:replaceSeries("test", {{10, 1}, {20, 3}, {30, 2}})
        expect_chart_draws(chart, 96, 72)
    end)

    -- @covers LLineChart:renderImage
    it("renderImage returns a drawn image for line charts", function()
        local chart = lurek.charts.newLine({ width = 96, height = 72 })
        chart:addSeries("test", {{1, 2}, {2, 4}, {3, 3}})
        local img = chart:renderImage()
        expect_type("userdata", img)
        expect_equal(96, img:getWidth())
        expect_equal(72, img:getHeight())
        expect_true(image_has_drawn_pixels(img))
    end)

    -- @covers LLineChart:clear
    it("clear removes series and render still succeeds", function()
        local chart = lurek.charts.newLine()
        chart:addSeries("test", {{1, 2}, {3, 4}})
        chart:clear()
        local w, _, data = chart:render()
        expect_true(w > 0)
        expect_type("string", data)
    end)

    -- @covers LLineChart:setTitle
    it("setTitle keeps line chart renderable", function()
        local chart = lurek.charts.newLine()
        chart:setTitle("My Line Chart")
        local w = chart:render()
        expect_true(w > 0)
    end)

    -- @covers LLineChart:appendPoint
    it("appendPoint keeps recent line samples within the configured history", function()
        local chart = lurek.charts.newLine({ width = 96, height = 72, maxPoints = 3 })
        chart:appendPoint("loss", 1, 0.9)
        chart:appendPoint("loss", 2, 0.7)
        chart:appendPoint("loss", 3, 0.5)
        chart:appendPoint("loss", 4, 0.4)
        expect_chart_draws(chart, 96, 72)
    end)

    -- @covers LLineChart:setWindow
    it("setWindow keeps streaming line charts renderable", function()
        local chart = lurek.charts.newLine({ width = 96, height = 72, maxPoints = 3 })
        chart:appendPoint("loss", 1, 0.9)
        chart:appendPoint("loss", 2, 0.7)
        chart:appendPoint("loss", 3, 0.5)
        chart:appendPoint("loss", 4, 0.4)
        chart:setWindow(2)
        expect_chart_draws(chart, 96, 72)
    end)

    -- @covers LLineChart:nearest
    it("nearest exposes nearest point metadata for streaming line charts", function()
        local chart = lurek.charts.newLine({ width = 96, height = 72, maxPoints = 3 })
        chart:appendPoint("loss", 1, 0.9)
        chart:appendPoint("loss", 2, 0.7)
        chart:appendPoint("loss", 3, 0.5)
        chart:appendPoint("loss", 4, 0.4)
        chart:setWindow(2)
        local nearest = chart:nearest(70, 32)
        expect_type("table", nearest)
        expect_equal("loss", nearest.series)
        expect_true(nearest.index >= 1)
    end)
end)

-- @describe LuaBarChart methods
describe("LuaBarChart methods", function()
    -- @covers LBarChart:addSeries
    it("addSeries accepts bar values", function()
        local chart = lurek.charts.newBar()
        chart:addSeries("sales", {{1, 10}, {2, 20}, {3, 15}})
        local w, h, data = chart:render()
        expect_true(w > 0)
        expect_true(h > 0)
        expect_true(#data > 0)
    end)

    -- @covers LBarChart:render
    it("render returns valid image data", function()
        local chart = lurek.charts.newBar()
        chart:addSeries("sales", {{1, 10}})
        local w, h, data = chart:render()
        expect_true(w > 0)
        expect_true(h > 0)
        expect_true(#data > 0)
    end)

    -- @covers LBarChart:renderImage
    it("renderImage returns a drawn image for bar charts", function()
        local chart = lurek.charts.newBar({ width = 96, height = 72 })
        chart:addSeries("sales", {{1, 10}, {2, 14}})
        local img = chart:renderImage()
        expect_type("userdata", img)
        expect_equal(96, img:getWidth())
        expect_equal(72, img:getHeight())
        expect_true(image_has_drawn_pixels(img))
    end)

    -- @covers LBarChart:setBarWidth
    it("setBarWidth keeps bar chart renderable", function()
        local chart = lurek.charts.newBar()
        chart:setBarWidth(20)
        chart:addSeries("test", {{1, 5}})
        local w = chart:render()
        expect_true(w > 0)
    end)

    -- @covers LBarChart:clear
    it("clear removes all bar series", function()
        local chart = lurek.charts.newBar()
        chart:addSeries("a", {{1, 1}})
        chart:clear()
        local w = chart:render()
        expect_true(w > 0)
    end)

    -- @covers LBarChart:getWidth
    it("getWidth returns configured bar chart width", function()
        local chart = lurek.charts.newBar({ width = 640, height = 480 })
        expect_equal(640, chart:getWidth())
    end)

    -- @covers LBarChart:getHeight
    it("getHeight returns configured bar chart height", function()
        local chart = lurek.charts.newBar({ width = 640, height = 480 })
        expect_equal(480, chart:getHeight())
    end)

    -- @covers LBarChart:setTitle
    it("setTitle keeps bar chart renderable", function()
        local chart = lurek.charts.newBar()
        chart:setTitle("Bar Title")
        chart:addSeries("test", {{1, 5}})
        local w = chart:render()
        expect_true(w > 0)
    end)

    -- @covers LBarChart:addCategory
    it("addCategory appends one category row to a bar chart", function()
        local chart = lurek.charts.newBar({ width = 96, height = 72 })
        chart:addSeries("Revenue", {})
        chart:addSeries("Cost", {})
        chart:addCategory("Seed", { 100, 60 })
        expect_chart_draws(chart, 96, 72)
    end)

    -- @covers LBarChart:addCategoriesFromDataFrame
    it("addCategoriesFromDataFrame ingests category rows from a dataframe", function()
        local df = lurek.dataframe.fromRows({ "month", "revenue", "cost" }, {
            { "Jan", 120, 80 },
            { "Feb", 150, 95 },
        })
        local chart = lurek.charts.newBar({ width = 96, height = 72 })
        chart:addSeries("Revenue", {})
        chart:addSeries("Cost", {})
        expect_equal(2, chart:addCategoriesFromDataFrame(df, "month", { "revenue", "cost" }))
        expect_chart_draws(chart, 96, 72)
    end)
end)

-- @describe LuaScatterPlot methods
describe("LuaScatterPlot methods", function()
    -- @covers LScatterPlot:addSeries
    it("addSeries accepts scatter points", function()
        local chart = lurek.charts.newScatter()
        chart:addSeries("points", {{1, 1}, {2, 4}, {3, 9}})
        local w, h, data = chart:render()
        expect_true(w > 0)
        expect_true(h > 0)
        expect_true(#data > 0)
    end)

    -- @covers LScatterPlot:render
    it("render returns scatter plot bytes", function()
        local chart = lurek.charts.newScatter()
        chart:addSeries("points", {{1, 1}})
        local w, h, data = chart:render()
        expect_true(w > 0)
        expect_true(h > 0)
        expect_true(#data > 0)
    end)

    -- @covers LScatterPlot:replaceSeries
    it("replaceSeries swaps scatter data and keeps render working", function()
        local chart = lurek.charts.newScatter({ width = 96, height = 72 })
        chart:addSeries("points", {{1, 1}, {2, 4}})
        chart:replaceSeries("points", {{10, 2}, {20, 6}, {30, 5}})
        expect_chart_draws(chart, 96, 72)
    end)

    -- @covers LScatterPlot:renderImage
    it("renderImage returns a drawn image for scatter charts", function()
        local chart = lurek.charts.newScatter({ width = 96, height = 72 })
        chart:addSeries("points", {{1, 1}, {2, 4}, {3, 9}})
        local img = chart:renderImage()
        expect_type("userdata", img)
        expect_equal(96, img:getWidth())
        expect_equal(72, img:getHeight())
        expect_true(image_has_drawn_pixels(img))
    end)

    -- @covers LScatterPlot:setDotRadius
    it("setDotRadius keeps scatter chart renderable", function()
        local chart = lurek.charts.newScatter()
        chart:setDotRadius(5)
        chart:addSeries("dots", {{0, 0}})
        local w = chart:render()
        expect_true(w > 0)
    end)

    -- @covers LScatterPlot:clear
    it("clear removes scatter series", function()
        local chart = lurek.charts.newScatter()
        chart:addSeries("x", {{1, 2}})
        chart:clear()
        local _, _, data = chart:render()
        expect_type("string", data)
    end)

    -- @covers LScatterPlot:setTitle
    it("setTitle keeps scatter chart renderable", function()
        local chart = lurek.charts.newScatter()
        chart:setTitle("Scatter Title")
        chart:addSeries("dots", {{1, 1}})
        local w = chart:render()
        expect_true(w > 0)
    end)

    -- @covers LScatterPlot:getWidth
    it("getWidth returns configured scatter width", function()
        local chart = lurek.charts.newScatter({ width = 700, height = 350 })
        expect_equal(700, chart:getWidth())
    end)

    -- @covers LScatterPlot:getHeight
    it("getHeight returns configured scatter height", function()
        local chart = lurek.charts.newScatter({ width = 700, height = 350 })
        expect_equal(350, chart:getHeight())
    end)
end)

-- @describe LuaHistogramChart methods
describe("LuaHistogramChart methods", function()
    -- @covers lurek.charts.newHistogram
    it("newHistogram returns userdata", function()
        local chart = lurek.charts.newHistogram()
        expect_type("userdata", chart)
    end)

    -- @covers LHistogramChart:addSeries
    it("addSeries renders grouped histogram distributions", function()
        local chart = lurek.charts.newHistogram({ width = 96, height = 72, showLegend = true })
        chart:addSeries("train", { 0.1, 0.2, 0.2, 0.4, 0.6, 0.9 })
        chart:addSeries("valid", { 0.15, 0.18, 0.5, 0.55, 0.8 })
        expect_chart_draws(chart, 96, 72)
    end)

    -- @covers LHistogramChart:setBinCount
    it("setBinCount keeps grouped histograms renderable", function()
        local chart = lurek.charts.newHistogram({ width = 96, height = 72, showLegend = true })
        chart:setBinCount(6)
        chart:addSeries("train", { 0.1, 0.2, 0.2, 0.4, 0.6, 0.9 })
        expect_chart_draws(chart, 96, 72)
    end)

    -- @covers LHistogramChart:setDensity
    it("setDensity toggles density rendering without breaking grouped histograms", function()
        local chart = lurek.charts.newHistogram({ width = 96, height = 72, showLegend = true })
        chart:setDensity(true)
        chart:addSeries("train", { 0.1, 0.2, 0.2, 0.4, 0.6, 0.9 })
        expect_chart_draws(chart, 96, 72)
    end)

    -- @covers LHistogramChart:addSeriesFromDataFrame
    it("addSeriesFromDataFrame copies numeric histogram samples from a dataframe", function()
        local df = lurek.dataframe.fromRows({ "latency_ms" }, {
            { 12 },
            { 18 },
            { "bad" },
            { 30 },
        })
        local chart = lurek.charts.newHistogram({ width = 96, height = 72, maxPoints = 4 })
        expect_equal(3, chart:addSeriesFromDataFrame("latency", df, "latency_ms"))
        local w, h, bytes = chart:render()
        expect_equal(96, w)
        expect_equal(72, h)
        expect_true(#bytes > 0)
    end)

    -- @covers LHistogramChart:appendValue
    it("appendValue extends a histogram sample stream", function()
        local chart = lurek.charts.newHistogram({ width = 96, height = 72, maxPoints = 4 })
        chart:addSeries("latency", { 12, 18, 30 })
        chart:appendValue("latency", 45)
        local w, h, bytes = chart:render()
        expect_equal(96, w)
        expect_equal(72, h)
        expect_true(#bytes > 0)
    end)

    -- @covers LHistogramChart:setWindow
    it("setWindow keeps streaming histograms renderable", function()
        local chart = lurek.charts.newHistogram({ width = 96, height = 72, maxPoints = 4 })
        chart:addSeries("latency", { 12, 18, 30 })
        chart:appendValue("latency", 45)
        chart:setWindow(2)
        local w, h, bytes = chart:render()
        expect_equal(96, w)
        expect_equal(72, h)
        expect_true(#bytes > 0)
    end)

    -- @covers LHistogramChart:replaceSeries
    it("replaceSeries swaps histogram sample sets", function()
        local chart = lurek.charts.newHistogram({ width = 96, height = 72 })
        chart:addSeries("latency", { 1, 2, 3 })
        chart:replaceSeries("latency", { 10, 12, 18, 20 })
        expect_chart_draws(chart, 96, 72)
    end)

    -- @covers LHistogramChart:clearRange
    it("clearRange removes an explicit histogram range without breaking render", function()
        local chart = lurek.charts.newHistogram({ width = 96, height = 72 })
        chart:addSeries("latency", { 1, 2, 3, 4, 5 })
        chart:setRange(0, 5)
        chart:clearRange()
        expect_chart_draws(chart, 96, 72)
    end)

    -- @covers LHistogramChart:renderImage
    it("renderImage returns a drawn image for histograms", function()
        local chart = lurek.charts.newHistogram({ width = 96, height = 72 })
        chart:addSeries("latency", { 5, 7, 9, 12, 14 })
        local img = chart:renderImage()
        expect_type("userdata", img)
        expect_equal(96, img:getWidth())
        expect_equal(72, img:getHeight())
        expect_true(image_has_drawn_pixels(img))
    end)
end)

-- @describe LuaHeatmapChart methods
describe("LuaHeatmapChart methods", function()
    -- @covers lurek.charts.newHeatmap
    it("newHeatmap returns userdata", function()
        local chart = lurek.charts.newHeatmap()
        expect_type("userdata", chart)
    end)

    -- @covers LHeatmapChart:setMatrix
    it("setMatrix loads labeled heatmap matrix data", function()
        local chart = lurek.charts.newHeatmap({ width = 120, height = 90, showLegend = true, title = "Confusion" })
        chart:setMatrix({
            { 22, 3, 1 },
            { 4, 18, 2 },
            { 0, 2, 26 },
        }, { "cat", "dog", "fox" }, { "cat", "dog", "fox" })
        expect_chart_draws(chart, 120, 90)
    end)

    -- @covers LHeatmapChart:setColorRange
    it("setColorRange keeps heatmap matrix charts renderable", function()
        local chart = lurek.charts.newHeatmap({ width = 120, height = 90, showLegend = true, title = "Confusion" })
        chart:setMatrix({
            { 22, 3, 1 },
            { 4, 18, 2 },
            { 0, 2, 26 },
        }, { "cat", "dog", "fox" }, { "cat", "dog", "fox" })
        chart:setColorRange({ 0.1, 0.3, 0.9, 1.0 }, { 0.9, 0.2, 0.2, 1.0 })
        expect_chart_draws(chart, 120, 90)
    end)

    -- @covers LHeatmapChart:setShowValues
    it("setShowValues overlays numeric labels on heatmap cells", function()
        local chart = lurek.charts.newHeatmap({ width = 120, height = 90, showLegend = true, title = "Confusion" })
        chart:setMatrix({
            { 22, 3, 1 },
            { 4, 18, 2 },
            { 0, 2, 26 },
        }, { "cat", "dog", "fox" }, { "cat", "dog", "fox" })
        chart:setShowValues(true)
        expect_chart_draws(chart, 120, 90)
    end)

    -- @covers LHeatmapChart:setCell
    it("setCell updates one heatmap cell after dataframe ingestion", function()
        local df = lurek.dataframe.fromRows({ "actual", "predicted", "count" }, {
            { "spam", "spam", 17 },
            { "spam", "ham", 3 },
            { "ham", "spam", 2 },
            { "ham", "ham", 21 },
        })
        local chart = lurek.charts.newHeatmap({ width = 120, height = 90 })
        local copied = chart:setMatrixFromDataFrame(df, "actual", "predicted", "count")
        expect_equal(4, copied)
        chart:setCell(1, 2, 5)
        local w, h, bytes = chart:render()
        expect_equal(120, w)
        expect_equal(90, h)
        expect_true(#bytes > 0)
    end)

    -- @covers LHeatmapChart:setMatrixFromDataFrame
    it("setMatrixFromDataFrame pivots dataframe rows into heatmap cells", function()
        local df = lurek.dataframe.fromRows({ "actual", "predicted", "count" }, {
            { "spam", "spam", 17 },
            { "spam", "ham", 3 },
            { "ham", "spam", 2 },
            { "ham", "ham", 21 },
        })
        local chart = lurek.charts.newHeatmap({ width = 120, height = 90 })
        local copied = chart:setMatrixFromDataFrame(df, "actual", "predicted", "count")
        expect_equal(4, copied)
        local w, h, bytes = chart:render()
        expect_equal(120, w)
        expect_equal(90, h)
        expect_true(#bytes > 0)
    end)

    -- @covers LHeatmapChart:setValueRange
    it("setValueRange pins the numeric domain for dataframe-backed heatmaps", function()
        local df = lurek.dataframe.fromRows({ "actual", "predicted", "count" }, {
            { "spam", "spam", 17 },
            { "spam", "ham", 3 },
            { "ham", "spam", 2 },
            { "ham", "ham", 21 },
        })
        local chart = lurek.charts.newHeatmap({ width = 120, height = 90 })
        local copied = chart:setMatrixFromDataFrame(df, "actual", "predicted", "count")
        expect_equal(4, copied)
        chart:setValueRange(0, 25)
        local w, h, bytes = chart:render()
        expect_equal(120, w)
        expect_equal(90, h)
        expect_true(#bytes > 0)
    end)

    -- @covers LHeatmapChart:setRowLabels
    it("setRowLabels replaces heatmap row labels without breaking render", function()
        local chart = lurek.charts.newHeatmap({ width = 96, height = 72 })
        chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "r1", "r2" }, { "c1", "c2" })
        chart:setRowLabels({ "train", "valid" })
        expect_chart_draws(chart, 96, 72)
    end)

    -- @covers LHeatmapChart:setColumnLabels
    it("setColumnLabels replaces heatmap column labels without breaking render", function()
        local chart = lurek.charts.newHeatmap({ width = 96, height = 72 })
        chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "r1", "r2" }, { "c1", "c2" })
        chart:setColumnLabels({ "low", "high" })
        expect_chart_draws(chart, 96, 72)
    end)

    -- @covers LHeatmapChart:clearValueRange
    it("clearValueRange removes explicit heatmap scaling without breaking render", function()
        local chart = lurek.charts.newHeatmap({ width = 96, height = 72 })
        chart:setMatrix({ { 1, 2 }, { 3, 4 } })
        chart:setValueRange(0, 5)
        chart:clearValueRange()
        expect_chart_draws(chart, 96, 72)
    end)

    -- @covers LHeatmapChart:renderImage
    it("renderImage returns a drawn image for heatmaps", function()
        local chart = lurek.charts.newHeatmap({ width = 96, height = 72 })
        chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "r1", "r2" }, { "c1", "c2" })
        local img = chart:renderImage()
        expect_type("userdata", img)
        expect_equal(96, img:getWidth())
        expect_equal(72, img:getHeight())
        expect_true(image_has_drawn_pixels(img))
    end)
end)

-- @describe LuaPieChart methods
describe("LuaPieChart methods", function()
    -- @covers LPieChart:addSlice
    it("addSlice accepts pie values", function()
        local chart = lurek.charts.newPie()
        chart:addSlice("A", 30)
        chart:addSlice("B", 50)
        chart:addSlice("C", 20)
        local w, h, data = chart:render()
        expect_true(w > 0)
        expect_true(h > 0)
        expect_true(#data > 0)
    end)

    -- @covers LPieChart:render
    it("render returns pie chart bytes", function()
        local chart = lurek.charts.newPie()
        chart:addSlice("Only", 100)
        local w, h, data = chart:render()
        expect_true(w > 0)
        expect_true(h > 0)
        expect_true(#data > 0)
    end)

    -- @covers LPieChart:renderImage
    it("renderImage returns a drawn image for pie charts", function()
        local chart = lurek.charts.newPie({ width = 96, height = 72 })
        chart:addSlice("A", 70)
        chart:addSlice("B", 30)
        local img = chart:renderImage()
        expect_type("userdata", img)
        expect_equal(96, img:getWidth())
        expect_equal(72, img:getHeight())
        expect_true(image_has_drawn_pixels(img))
    end)

    -- @covers LPieChart:clear
    it("clear removes all slices", function()
        local chart = lurek.charts.newPie()
        chart:addSlice("X", 50)
        chart:clear()
        local _, _, data = chart:render()
        expect_type("string", data)
    end)

    -- @covers LPieChart:setTitle
    it("setTitle keeps pie chart renderable", function()
        local chart = lurek.charts.newPie()
        chart:setTitle("Pie Distribution")
        chart:addSlice("Slice", 100)
        local w = chart:render()
        expect_true(w > 0)
    end)

    -- @covers LPieChart:getWidth
    it("getWidth returns configured pie width", function()
        local chart = lurek.charts.newPie({ width = 420, height = 240 })
        expect_equal(420, chart:getWidth())
    end)

    -- @covers LPieChart:getHeight
    it("getHeight returns configured pie height", function()
        local chart = lurek.charts.newPie({ width = 420, height = 240 })
        expect_equal(240, chart:getHeight())
    end)
end)

-- @describe LuaAreaChart methods
describe("LuaAreaChart methods", function()
    -- @covers LAreaChart:addSeries
    it("addSeries accepts area data", function()
        local chart = lurek.charts.newArea()
        chart:addSeries("temp", {{1, 10}, {2, 20}, {3, 15}, {4, 25}})
        local w, h, data = chart:render()
        expect_true(w > 0)
        expect_true(h > 0)
        expect_true(#data > 0)
    end)

    -- @covers LAreaChart:render
    it("render returns area chart bytes", function()
        local chart = lurek.charts.newArea()
        chart:addSeries("temp", {{1, 10}, {2, 20}})
        local w, h, data = chart:render()
        expect_true(w > 0)
        expect_true(h > 0)
        expect_true(#data > 0)
    end)

    -- @covers LAreaChart:renderImage
    it("renderImage returns a drawn image for area charts", function()
        local chart = lurek.charts.newArea({ width = 96, height = 72 })
        chart:addSeries("temp", {{1, 10}, {2, 20}, {3, 15}})
        local img = chart:renderImage()
        expect_type("userdata", img)
        expect_equal(96, img:getWidth())
        expect_equal(72, img:getHeight())
        expect_true(image_has_drawn_pixels(img))
    end)

    -- @covers LAreaChart:clear
    it("clear removes all area series", function()
        local chart = lurek.charts.newArea()
        chart:addSeries("data", {{0, 5}, {1, 10}})
        chart:clear()
        local _, _, data = chart:render()
        expect_type("string", data)
    end)

    -- @covers LAreaChart:getWidth
    it("getWidth returns configured area width", function()
        local chart = lurek.charts.newArea({ width = 1024, height = 768, title = "Area Chart" })
        expect_equal(1024, chart:getWidth())
    end)

    -- @covers LAreaChart:getHeight
    it("getHeight returns configured area height", function()
        local chart = lurek.charts.newArea({ width = 1024, height = 768, title = "Area Chart" })
        expect_equal(768, chart:getHeight())
    end)

    -- @covers LAreaChart:setTitle
    it("setTitle keeps area chart renderable", function()
        local chart = lurek.charts.newArea()
        chart:setTitle("Area Title")
        chart:addSeries("s", {{1, 1}})
        local w = chart:render()
        expect_true(w > 0)
    end)

    -- @covers LAreaChart:setYMax
    it("setYMax keeps area chart renderable with explicit range", function()
        local chart = lurek.charts.newArea({ width = 96, height = 72 })
        chart:setYMax(100)
        chart:addSeries("temp", {{1, 10}, {2, 20}, {3, 15}})
        expect_chart_draws(chart, 96, 72)
    end)

    -- @describe explicit charts-owner coverage migrated from ui wrappers
    describe("explicit charts-owner coverage migrated from ui wrappers", function()
        -- @covers LLineChart:addSeriesFromDataFrame
        it("addSeriesFromDataFrame skips non numeric points for line charts", function()
            local df = lurek.dataframe.fromRows({ "month", "savings" }, {
                { 1, 240 },
                { 2, "260" },
                { 3, "bad" },
            })
            local chart = lurek.charts.newLine({ width = 64, height = 64 })
            expect_equal(1, chart:addSeriesFromDataFrame("Savings", df, "month", "savings"))
        end)

        -- @covers LLineChart:setXMax
        it("setXMax keeps line charts renderable", function()
            local chart = lurek.charts.newLine({ width = 96, height = 72 })
            chart:setXMax(10)
            chart:addSeries("speed", {{1, 10}, {2, 20}, {10, 15}})
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LLineChart:setYMax
        it("setYMax keeps line charts renderable", function()
            local chart = lurek.charts.newLine({ width = 96, height = 72 })
            chart:setYMax(50)
            chart:addSeries("speed", {{1, 10}, {2, 20}, {3, 15}})
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LLineChart:setXLabel
        it("setXLabel keeps annotated line charts renderable", function()
            local chart = lurek.charts.newLine({ width = 96, height = 72 })
            chart:setXLabel("Time")
            chart:addSeries("speed", {{1, 10}, {2, 20}, {3, 15}})
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LLineChart:setYLabel
        it("setYLabel keeps annotated line charts renderable", function()
            local chart = lurek.charts.newLine({ width = 96, height = 72 })
            chart:setYLabel("Speed")
            chart:addSeries("speed", {{1, 10}, {2, 20}, {3, 15}})
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LLineChart:setXTickCount
        it("setXTickCount keeps annotated line charts renderable", function()
            local chart = lurek.charts.newLine({ width = 96, height = 72 })
            chart:setXTickCount(6)
            chart:addSeries("speed", {{1, 10}, {2, 20}, {3, 15}})
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LLineChart:setYTickCount
        it("setYTickCount keeps annotated line charts renderable", function()
            local chart = lurek.charts.newLine({ width = 96, height = 72 })
            chart:setYTickCount(6)
            chart:addSeries("speed", {{1, 10}, {2, 20}, {3, 15}})
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LLineChart:setShowLegend
        it("setShowLegend keeps annotated line charts renderable", function()
            local chart = lurek.charts.newLine({ width = 96, height = 72 })
            chart:setShowLegend(true)
            chart:addSeries("speed", {{1, 10}, {2, 20}, {3, 15}})
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LLineChart:drawToImage
        it("drawToImage paints line charts into existing image data", function()
            local chart = lurek.charts.newLine({ width = 64, height = 64 })
            chart:addSeries("speed", {{1, 10}, {2, 20}, {3, 15}})
            expect_chart_draws(chart, 64, 64)
        end)

        -- @covers LLineChart:type
        it("type returns LLineChart for charts module line charts", function()
            expect_equal("LLineChart", lurek.charts.newLine({ width = 64, height = 64 }):type())
        end)

        -- @covers LLineChart:typeOf
        it("typeOf recognizes LLineChart for charts module line charts", function()
            expect_true(lurek.charts.newLine({ width = 64, height = 64 }):typeOf("LLineChart"))
        end)

        -- @covers LBarChart:setXLabel
        it("setXLabel keeps annotated bar charts renderable", function()
            local chart = lurek.charts.newBar({ width = 96, height = 72 })
            chart:setXLabel("Month")
            chart:addSeries("Q1", {})
            chart:addCategory("Jan", {30})
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LBarChart:setYLabel
        it("setYLabel keeps annotated bar charts renderable", function()
            local chart = lurek.charts.newBar({ width = 96, height = 72 })
            chart:setYLabel("Units")
            chart:addSeries("Q1", {})
            chart:addCategory("Jan", {30})
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LBarChart:setXTickCount
        it("setXTickCount keeps annotated bar charts renderable", function()
            local chart = lurek.charts.newBar({ width = 96, height = 72 })
            chart:setXTickCount(6)
            chart:addSeries("Q1", {})
            chart:addCategory("Jan", {30})
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LBarChart:setYTickCount
        it("setYTickCount keeps annotated bar charts renderable", function()
            local chart = lurek.charts.newBar({ width = 96, height = 72 })
            chart:setYTickCount(6)
            chart:addSeries("Q1", {})
            chart:addCategory("Jan", {30})
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LBarChart:setShowLegend
        it("setShowLegend keeps annotated bar charts renderable", function()
            local chart = lurek.charts.newBar({ width = 96, height = 72 })
            chart:setShowLegend(true)
            chart:addSeries("Q1", {})
            chart:addCategory("Jan", {30})
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LBarChart:drawToImage
        it("drawToImage paints bar charts into existing image data", function()
            local chart = lurek.charts.newBar({ width = 64, height = 64 })
            chart:addSeries("Q1", {})
            chart:addCategory("Jan", {30})
            expect_chart_draws(chart, 64, 64)
        end)

        -- @covers LBarChart:type
        it("type returns LBarChart for charts module bar charts", function()
            expect_equal("LBarChart", lurek.charts.newBar({ width = 64, height = 64 }):type())
        end)

        -- @covers LBarChart:typeOf
        it("typeOf recognizes LBarChart for charts module bar charts", function()
            expect_true(lurek.charts.newBar({ width = 64, height = 64 }):typeOf("LBarChart"))
        end)

        -- @covers LScatterPlot:addSeriesFromDataFrame
        it("addSeriesFromDataFrame skips non numeric points for scatter plots", function()
            local df = lurek.dataframe.fromRows({ "x", "y" }, {
                { 1, 2 },
                { 3, 4 },
                { 5, "bad" },
            })
            local chart = lurek.charts.newScatter({ width = 64, height = 64 })
            expect_equal(2, chart:addSeriesFromDataFrame("Points", df, "x", "y"))
        end)

        -- @covers LScatterPlot:setXRange
        it("setXRange keeps scatter charts renderable", function()
            local chart = lurek.charts.newScatter({ width = 96, height = 72 })
            chart:setXRange(0, 10)
            chart:addSeries("Points", {{1, 2}, {3, 4}, {5, 6}})
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LScatterPlot:setYRange
        it("setYRange keeps scatter charts renderable", function()
            local chart = lurek.charts.newScatter({ width = 96, height = 72 })
            chart:setYRange(0, 10)
            chart:addSeries("Points", {{1, 2}, {3, 4}, {5, 6}})
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LScatterPlot:setXLabel
        it("setXLabel keeps annotated scatter charts renderable", function()
            local chart = lurek.charts.newScatter({ width = 96, height = 72 })
            chart:setXLabel("Axis X")
            chart:addSeries("Points", {{1, 2}, {3, 4}, {5, 6}})
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LScatterPlot:setYLabel
        it("setYLabel keeps annotated scatter charts renderable", function()
            local chart = lurek.charts.newScatter({ width = 96, height = 72 })
            chart:setYLabel("Axis Y")
            chart:addSeries("Points", {{1, 2}, {3, 4}, {5, 6}})
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LScatterPlot:setXTickCount
        it("setXTickCount keeps annotated scatter charts renderable", function()
            local chart = lurek.charts.newScatter({ width = 96, height = 72 })
            chart:setXTickCount(6)
            chart:addSeries("Points", {{1, 2}, {3, 4}, {5, 6}})
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LScatterPlot:setYTickCount
        it("setYTickCount keeps annotated scatter charts renderable", function()
            local chart = lurek.charts.newScatter({ width = 96, height = 72 })
            chart:setYTickCount(6)
            chart:addSeries("Points", {{1, 2}, {3, 4}, {5, 6}})
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LScatterPlot:setShowLegend
        it("setShowLegend keeps annotated scatter charts renderable", function()
            local chart = lurek.charts.newScatter({ width = 96, height = 72 })
            chart:setShowLegend(true)
            chart:addSeries("Points", {{1, 2}, {3, 4}, {5, 6}})
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LScatterPlot:drawToImage
        it("drawToImage paints scatter charts into existing image data", function()
            local chart = lurek.charts.newScatter({ width = 64, height = 64 })
            chart:addSeries("Points", {{1, 2}, {3, 4}, {5, 6}})
            expect_chart_draws(chart, 64, 64)
        end)

        -- @covers LScatterPlot:type
        it("type returns LScatterPlot for charts module scatter charts", function()
            expect_equal("LScatterPlot", lurek.charts.newScatter({ width = 64, height = 64 }):type())
        end)

        -- @covers LScatterPlot:typeOf
        it("typeOf recognizes LScatterPlot for charts module scatter charts", function()
            expect_true(lurek.charts.newScatter({ width = 64, height = 64 }):typeOf("LScatterPlot"))
        end)

        -- @covers LPieChart:addSegment
        it("addSegment adds drawable pie data", function()
            local chart = lurek.charts.newPie({ width = 64, height = 64 })
            chart:addSegment("Food", 420)
            expect_chart_draws(chart, 64, 64)
        end)

        -- @covers LPieChart:addSegmentsFromDataFrame
        it("addSegmentsFromDataFrame skips invalid pie values", function()
            local df = lurek.dataframe.fromRows({ "category", "amount" }, {
                { "Food", 420 },
                { "Rent", "1200" },
                { "Skip", "bad" },
                { "Zero", 0 },
            })
            local chart = lurek.charts.newPie({ width = 64, height = 64 })
            expect_equal(1, chart:addSegmentsFromDataFrame(df, "category", "amount"))
        end)

        -- @covers LPieChart:setShowLegend
        it("setShowLegend keeps annotated pie charts renderable", function()
            local chart = lurek.charts.newPie({ width = 96, height = 72 })
            chart:setShowLegend(true)
            chart:addSegment("Food", 420)
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LPieChart:drawToImage
        it("drawToImage paints pie charts into existing image data", function()
            local chart = lurek.charts.newPie({ width = 64, height = 64 })
            chart:addSegment("Food", 420)
            expect_chart_draws(chart, 64, 64)
        end)

        -- @covers LPieChart:type
        it("type returns LPieChart for charts module pie charts", function()
            expect_equal("LPieChart", lurek.charts.newPie({ width = 64, height = 64 }):type())
        end)

        -- @covers LPieChart:typeOf
        it("typeOf recognizes LPieChart for charts module pie charts", function()
            expect_true(lurek.charts.newPie({ width = 64, height = 64 }):typeOf("LPieChart"))
        end)

        -- @covers LAreaChart:addLayer
        it("addLayer adds drawable area layer data", function()
            local chart = lurek.charts.newArea({ width = 64, height = 64 })
            chart:addLayer("series1", {10, 20, 30, 25, 15})
            expect_chart_draws(chart, 64, 64)
        end)

        -- @covers LAreaChart:addLayerFromDataFrame
        it("addLayerFromDataFrame copies dataframe values for area charts", function()
            local df = lurek.dataframe.fromRows({ "balance" }, {
                { 1200 },
                { "1325" },
                { "bad" },
            })
            local chart = lurek.charts.newArea({ width = 64, height = 64 })
            expect_equal(3, chart:addLayerFromDataFrame("Balance", df, "balance"))
        end)

        -- @covers LAreaChart:setXLabel
        it("setXLabel keeps annotated area charts renderable", function()
            local chart = lurek.charts.newArea({ width = 96, height = 72 })
            chart:setXLabel("Step")
            chart:addLayer("series1", {10, 20, 30, 25, 15})
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LAreaChart:setYLabel
        it("setYLabel keeps annotated area charts renderable", function()
            local chart = lurek.charts.newArea({ width = 96, height = 72 })
            chart:setYLabel("Load")
            chart:addLayer("series1", {10, 20, 30, 25, 15})
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LAreaChart:setXTickCount
        it("setXTickCount keeps annotated area charts renderable", function()
            local chart = lurek.charts.newArea({ width = 96, height = 72 })
            chart:setXTickCount(6)
            chart:addLayer("series1", {10, 20, 30, 25, 15})
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LAreaChart:setYTickCount
        it("setYTickCount keeps annotated area charts renderable", function()
            local chart = lurek.charts.newArea({ width = 96, height = 72 })
            chart:setYTickCount(6)
            chart:addLayer("series1", {10, 20, 30, 25, 15})
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LAreaChart:setShowLegend
        it("setShowLegend keeps annotated area charts renderable", function()
            local chart = lurek.charts.newArea({ width = 96, height = 72 })
            chart:setShowLegend(true)
            chart:addLayer("series1", {10, 20, 30, 25, 15})
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LAreaChart:drawToImage
        it("drawToImage paints area charts into existing image data", function()
            local chart = lurek.charts.newArea({ width = 64, height = 64 })
            chart:addLayer("series1", {10, 20, 30, 25, 15})
            expect_chart_draws(chart, 64, 64)
        end)

        -- @covers LAreaChart:type
        it("type returns LAreaChart for charts module area charts", function()
            expect_equal("LAreaChart", lurek.charts.newArea({ width = 64, height = 64 }):type())
        end)

        -- @covers LAreaChart:typeOf
        it("typeOf recognizes LAreaChart for charts module area charts", function()
            expect_true(lurek.charts.newArea({ width = 64, height = 64 }):typeOf("LAreaChart"))
        end)
    end)

    -- @describe explicit strict-owner coverage additions
    describe("explicit strict-owner coverage additions", function()
        -- @covers LLineChart:draw
        it("draw queues a line chart with a transform tuple", function()
            local chart = lurek.charts.newLine({ width = 96, height = 72 })
            chart:addSeries("loss", {{1, 0.9}, {2, 0.7}, {3, 0.4}})
            expect_no_error(function()
                chart:draw(10, 20)
            end)
        end)

        -- @covers LBarChart:draw
        it("draw queues a bar chart with a transform tuple", function()
            local chart = lurek.charts.newBar({ width = 96, height = 72 })
            chart:addSeries("sales", {{1, 10}, {2, 14}})
            expect_no_error(function()
                chart:draw(12, 18)
            end)
        end)

        -- @covers LScatterPlot:appendPoint
        it("appendPoint streams scatter samples into a named series", function()
            local chart = lurek.charts.newScatter({ width = 96, height = 72, maxPoints = 3 })
            chart:appendPoint("points", 1, 1)
            chart:appendPoint("points", 2, 4)
            chart:appendPoint("points", 3, 9)
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LScatterPlot:setWindow
        it("setWindow keeps streaming scatter plots renderable", function()
            local chart = lurek.charts.newScatter({ width = 96, height = 72, maxPoints = 3 })
            chart:appendPoint("points", 1, 1)
            chart:appendPoint("points", 2, 4)
            chart:appendPoint("points", 3, 9)
            chart:setWindow(2)
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LScatterPlot:draw
        it("draw queues a scatter plot with a transform tuple", function()
            local chart = lurek.charts.newScatter({ width = 96, height = 72 })
            chart:addSeries("points", {{1, 1}, {2, 4}, {3, 9}})
            expect_no_error(function()
                chart:draw(8, 14)
            end)
        end)

        -- @covers LScatterPlot:nearest
        it("nearest returns point metadata for scatter plots", function()
            local chart = lurek.charts.newScatter({ width = 96, height = 72, maxPoints = 3 })
            chart:appendPoint("points", 1, 1)
            chart:appendPoint("points", 2, 4)
            chart:appendPoint("points", 3, 9)
            local nearest = chart:nearest(70, 32)
            expect_type("table", nearest)
            expect_equal("points", nearest.series)
            expect_true(nearest.index >= 1)
        end)

        -- @covers LPieChart:draw
        it("draw queues a pie chart with a transform tuple", function()
            local chart = lurek.charts.newPie({ width = 96, height = 72 })
            chart:addSlice("A", 30)
            chart:addSlice("B", 70)
            expect_no_error(function()
                chart:draw(5, 9)
            end)
        end)

        -- @covers LAreaChart:appendPoint
        it("appendPoint streams area samples into a named series", function()
            local chart = lurek.charts.newArea({ width = 96, height = 72, maxPoints = 3 })
            chart:appendPoint("traffic", 1, 2)
            chart:appendPoint("traffic", 2, 5)
            chart:appendPoint("traffic", 3, 4)
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LAreaChart:setWindow
        it("setWindow keeps streaming area charts renderable", function()
            local chart = lurek.charts.newArea({ width = 96, height = 72, maxPoints = 3 })
            chart:appendPoint("traffic", 1, 2)
            chart:appendPoint("traffic", 2, 5)
            chart:appendPoint("traffic", 3, 4)
            chart:setWindow(2)
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LAreaChart:draw
        it("draw queues an area chart with a transform tuple", function()
            local chart = lurek.charts.newArea({ width = 96, height = 72 })
            chart:addSeries("traffic", {{1, 2}, {2, 5}, {3, 4}})
            expect_no_error(function()
                chart:draw(6, 11)
            end)
        end)

        -- @covers LHistogramChart:clear
        it("clear removes histogram samples and keeps rendering valid", function()
            local chart = lurek.charts.newHistogram({ width = 96, height = 72 })
            chart:addSeries("latency", {1, 2, 3, 4})
            chart:clear()
            local w, h, bytes = chart:render()
            expect_equal(96, w)
            expect_equal(72, h)
            expect_true(#bytes > 0)
        end)

        -- @covers LHistogramChart:setRange
        it("setRange pins histogram axis bounds", function()
            local chart = lurek.charts.newHistogram({ width = 96, height = 72 })
            chart:addSeries("latency", {1, 2, 3, 4})
            chart:setRange(0, 5)
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LHistogramChart:setTitle
        it("setTitle keeps histogram charts renderable", function()
            local chart = lurek.charts.newHistogram({ width = 96, height = 72 })
            chart:setTitle("Latency")
            chart:addSeries("latency", {1, 2, 3, 4})
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LHistogramChart:setXLabel
        it("setXLabel annotates histogram x axis", function()
            local chart = lurek.charts.newHistogram({ width = 96, height = 72 })
            chart:setXLabel("Latency")
            chart:addSeries("latency", {1, 2, 3, 4})
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LHistogramChart:setYLabel
        it("setYLabel annotates histogram y axis", function()
            local chart = lurek.charts.newHistogram({ width = 96, height = 72 })
            chart:setYLabel("Count")
            chart:addSeries("latency", {1, 2, 3, 4})
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LHistogramChart:setXTickCount
        it("setXTickCount updates histogram tick density on x axis", function()
            local chart = lurek.charts.newHistogram({ width = 96, height = 72 })
            chart:setXTickCount(5)
            chart:addSeries("latency", {1, 2, 3, 4})
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LHistogramChart:setYTickCount
        it("setYTickCount updates histogram tick density on y axis", function()
            local chart = lurek.charts.newHistogram({ width = 96, height = 72 })
            chart:setYTickCount(6)
            chart:addSeries("latency", {1, 2, 3, 4})
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LHistogramChart:setShowLegend
        it("setShowLegend toggles histogram legend rendering", function()
            local chart = lurek.charts.newHistogram({ width = 96, height = 72 })
            chart:setShowLegend(true)
            chart:addSeries("latency", {1, 2, 3, 4})
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LHistogramChart:render
        it("render returns histogram raster data", function()
            local chart = lurek.charts.newHistogram({ width = 96, height = 72 })
            chart:addSeries("latency", {1, 2, 3, 4})
            local w, h, bytes = chart:render()
            expect_equal(96, w)
            expect_equal(72, h)
            expect_true(#bytes > 0)
        end)

        -- @covers LHistogramChart:drawToImage
        it("drawToImage paints histogram output into existing image data", function()
            local chart = lurek.charts.newHistogram({ width = 96, height = 72 })
            local img = lurek.image.newImageData(96, 72)
            chart:addSeries("latency", {1, 2, 3, 4})
            chart:drawToImage(img)
            expect_equal(96, img:getWidth())
            expect_equal(72, img:getHeight())
        end)

        -- @covers LHistogramChart:draw
        it("draw queues a histogram chart with a transform tuple", function()
            local chart = lurek.charts.newHistogram({ width = 96, height = 72 })
            chart:addSeries("latency", {1, 2, 3, 4})
            expect_no_error(function()
                chart:draw(7, 13)
            end)
        end)

        -- @covers LHistogramChart:getWidth
        it("getWidth returns configured histogram width", function()
            local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
            expect_equal(320, chart:getWidth())
        end)

        -- @covers LHistogramChart:getHeight
        it("getHeight returns configured histogram height", function()
            local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
            expect_equal(180, chart:getHeight())
        end)

        -- @covers LHistogramChart:type
        it("type returns the histogram userdata name", function()
            local chart = lurek.charts.newHistogram()
            expect_equal("LHistogramChart", chart:type())
        end)

        -- @covers LHistogramChart:typeOf
        it("typeOf recognizes histogram userdata inheritance", function()
            local chart = lurek.charts.newHistogram()
            expect_true(chart:typeOf("LHistogramChart"))
            expect_true(chart:typeOf("LObject"))
        end)

        -- @covers LHeatmapChart:resize
        it("resize changes the heatmap grid dimensions", function()
            local chart = lurek.charts.newHeatmap({ width = 96, height = 72 })
            chart:setMatrix({ { 1 } }, { "r1" }, { "c1" })
            chart:resize(2, 3)
            chart:setCell(1, 1, 5)
            chart:setCell(2, 3, 7)
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LHeatmapChart:clear
        it("clear removes heatmap state and keeps rendering valid", function()
            local chart = lurek.charts.newHeatmap({ width = 96, height = 72 })
            chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "r1", "r2" }, { "c1", "c2" })
            chart:clear()
            local w, h, bytes = chart:render()
            expect_equal(96, w)
            expect_equal(72, h)
            expect_true(#bytes > 0)
        end)

        -- @covers LHeatmapChart:setTitle
        it("setTitle keeps heatmap charts renderable", function()
            local chart = lurek.charts.newHeatmap({ width = 96, height = 72 })
            chart:setTitle("Confusion")
            chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "r1", "r2" }, { "c1", "c2" })
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LHeatmapChart:setShowLegend
        it("setShowLegend toggles heatmap legend rendering", function()
            local chart = lurek.charts.newHeatmap({ width = 96, height = 72 })
            chart:setShowLegend(true)
            chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "r1", "r2" }, { "c1", "c2" })
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LHeatmapChart:render
        it("render returns heatmap raster data", function()
            local chart = lurek.charts.newHeatmap({ width = 96, height = 72 })
            chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "r1", "r2" }, { "c1", "c2" })
            local w, h, bytes = chart:render()
            expect_equal(96, w)
            expect_equal(72, h)
            expect_true(#bytes > 0)
        end)

        -- @covers LHeatmapChart:drawToImage
        it("drawToImage paints heatmap output into existing image data", function()
            local chart = lurek.charts.newHeatmap({ width = 96, height = 72 })
            local img = lurek.image.newImageData(96, 72)
            chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "r1", "r2" }, { "c1", "c2" })
            chart:drawToImage(img)
            expect_equal(96, img:getWidth())
            expect_equal(72, img:getHeight())
        end)

        -- @covers LHeatmapChart:draw
        it("draw queues a heatmap chart with a transform tuple", function()
            local chart = lurek.charts.newHeatmap({ width = 96, height = 72 })
            chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "r1", "r2" }, { "c1", "c2" })
            expect_no_error(function()
                chart:draw(9, 15)
            end)
        end)

        -- @covers LHeatmapChart:getWidth
        it("getWidth returns configured heatmap width", function()
            local chart = lurek.charts.newHeatmap({ width = 256, height = 144 })
            expect_equal(256, chart:getWidth())
        end)

        -- @covers LHeatmapChart:getHeight
        it("getHeight returns configured heatmap height", function()
            local chart = lurek.charts.newHeatmap({ width = 256, height = 144 })
            expect_equal(144, chart:getHeight())
        end)

        -- @covers LHeatmapChart:type
        it("type returns the heatmap userdata name", function()
            local chart = lurek.charts.newHeatmap()
            expect_equal("LHeatmapChart", chart:type())
        end)

        -- @covers LHeatmapChart:typeOf
        it("typeOf recognizes heatmap userdata inheritance", function()
            local chart = lurek.charts.newHeatmap()
            expect_true(chart:typeOf("LHeatmapChart"))
            expect_true(chart:typeOf("LObject"))
        end)
    end)

    -- @describe additional common chart types
    describe("additional common chart types", function()
        -- @covers lurek.charts.newCandlestick
        it("newCandlestick returns userdata", function()
            expect_type("userdata", lurek.charts.newCandlestick())
        end)

        -- @covers LCandlestickChart:setCandles
        it("setCandles renders OHLC rows", function()
            local chart = lurek.charts.newCandlestick({ width = 96, height = 72 })
            chart:setCandles({
                { label = "Mon", open = 10, high = 14, low = 9, close = 13 },
                { label = "Tue", open = 13, high = 15, low = 11, close = 12 },
            })
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LCandlestickChart:appendCandle
        it("appendCandle streams one OHLC row", function()
            local chart = lurek.charts.newCandlestick({ width = 96, height = 72 })
            chart:appendCandle("Mon", 10, 14, 9, 13)
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LCandlestickChart:setColors
        it("setColors keeps candlesticks renderable", function()
            local chart = lurek.charts.newCandlestick({ width = 96, height = 72 })
            chart:setColors({ 0.1, 0.8, 0.2, 1 }, { 0.9, 0.1, 0.1, 1 })
            chart:appendCandle("Mon", 10, 14, 9, 13)
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers lurek.charts.newBoxPlot
        it("newBoxPlot returns userdata", function()
            expect_type("userdata", lurek.charts.newBoxPlot())
        end)

        -- @covers LBoxPlotChart:addSeries
        it("addSeries renders boxplot distributions", function()
            local chart = lurek.charts.newBoxPlot({ width = 96, height = 72 })
            chart:addSeries("latency", { 10, 12, 13, 14, 18, 22, 44 })
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LBoxPlotChart:appendValue
        it("appendValue streams boxplot samples", function()
            local chart = lurek.charts.newBoxPlot({ width = 96, height = 72 })
            chart:appendValue("latency", 10)
            chart:appendValue("latency", 14)
            chart:appendValue("latency", 22)
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers lurek.charts.newBubble
        it("newBubble returns userdata", function()
            expect_type("userdata", lurek.charts.newBubble())
        end)

        -- @covers LBubbleChart:addSeries
        it("addSeries renders weighted bubble points", function()
            local chart = lurek.charts.newBubble({ width = 96, height = 72 })
            chart:addSeries("cities", { { 1, 2, 10 }, { 2, 3, 20 }, { 3, 2, 12 } })
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LBubbleChart:appendPoint
        it("appendPoint streams weighted bubble points", function()
            local chart = lurek.charts.newBubble({ width = 96, height = 72 })
            chart:appendPoint("cities", 1, 2, 10)
            chart:appendPoint("cities", 2, 3, 20)
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LBubbleChart:setRadiusRange
        it("setRadiusRange controls bubble size mapping", function()
            local chart = lurek.charts.newBubble({ width = 96, height = 72 })
            chart:setRadiusRange(2, 8)
            chart:addSeries("cities", { { 1, 2, 10 }, { 2, 3, 20 } })
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers lurek.charts.newRadar
        it("newRadar returns userdata", function()
            expect_type("userdata", lurek.charts.newRadar())
        end)

        -- @covers LRadarChart:setAxes
        it("setAxes labels radar dimensions", function()
            local chart = lurek.charts.newRadar({ width = 120, height = 100 })
            chart:setAxes({ "speed", "power", "range", "cost" })
            chart:addSeries("A", { 4, 3, 5, 2 })
            expect_chart_draws(chart, 120, 100)
        end)

        -- @covers LRadarChart:addSeries
        it("addSeries renders radar polygons", function()
            local chart = lurek.charts.newRadar({ width = 120, height = 100 })
            chart:setAxes({ "speed", "power", "range", "cost" })
            chart:addSeries("A", { 4, 3, 5, 2 })
            chart:addSeries("B", { 2, 5, 3, 4 })
            expect_chart_draws(chart, 120, 100)
        end)

        -- @covers LRadarChart:setMaxValue
        it("setMaxValue pins radar scaling", function()
            local chart = lurek.charts.newRadar({ width = 120, height = 100 })
            chart:setAxes({ "speed", "power", "range", "cost" })
            chart:setMaxValue(10)
            chart:addSeries("A", { 4, 3, 5, 2 })
            expect_chart_draws(chart, 120, 100)
        end)

        -- @covers LRadarChart:clearMaxValue
        it("clearMaxValue restores radar auto scaling", function()
            local chart = lurek.charts.newRadar({ width = 120, height = 100 })
            chart:setMaxValue(10)
            chart:clearMaxValue()
            chart:setAxes({ "speed", "power", "range", "cost" })
            chart:addSeries("A", { 4, 3, 5, 2 })
            expect_chart_draws(chart, 120, 100)
        end)

        -- @covers lurek.charts.newTreemap
        it("newTreemap returns userdata", function()
            expect_type("userdata", lurek.charts.newTreemap())
        end)

        -- @covers LTreemapChart:setItems
        it("setItems renders weighted treemap rectangles", function()
            local chart = lurek.charts.newTreemap({ width = 120, height = 90 })
            chart:setItems({
                { label = "CPU", value = 45 },
                { label = "GPU", value = 30 },
                { label = "IO", value = 15 },
            })
            expect_chart_draws(chart, 120, 90)
        end)

        -- @covers LTreemapChart:addItem
        it("addItem appends treemap rectangles", function()
            local chart = lurek.charts.newTreemap({ width = 120, height = 90 })
            chart:addItem("CPU", 45)
            chart:addItem("GPU", 30)
            expect_chart_draws(chart, 120, 90)
        end)
    end)

    -- @describe common methods for additional chart types
    describe("common methods for additional chart types", function()
        local function additional_chart(kind)
            if kind == "candlestick" then
                local chart = lurek.charts.newCandlestick({ width = 96, height = 72 })
                chart:appendCandle("Mon", 10, 14, 9, 13)
                return chart
            elseif kind == "boxplot" then
                local chart = lurek.charts.newBoxPlot({ width = 96, height = 72 })
                chart:addSeries("latency", { 10, 12, 15, 20 })
                return chart
            elseif kind == "bubble" then
                local chart = lurek.charts.newBubble({ width = 96, height = 72 })
                chart:addSeries("cities", { { 1, 2, 10 }, { 2, 3, 20 } })
                return chart
            elseif kind == "radar" then
                local chart = lurek.charts.newRadar({ width = 96, height = 72 })
                chart:setAxes({ "a", "b", "c" })
                chart:addSeries("A", { 1, 2, 3 })
                return chart
            end
            local chart = lurek.charts.newTreemap({ width = 96, height = 72 })
            chart:addItem("Rendering", 45)
            chart:addItem("Audio", 18)
            return chart
        end

        -- @covers LCandlestickChart:render
        it("render returns candlestick bytes", function()
            local chart = lurek.charts.newCandlestick({ width = 96, height = 72 })
            chart:appendCandle("Mon", 10, 14, 9, 13)
            local w, h, bytes = chart:render()
            expect_equal(96, w)
            expect_equal(72, h)
            expect_true(#bytes > 0)
        end)

        -- @covers LBoxPlotChart:renderImage
        it("renderImage returns boxplot image data", function()
            local chart = lurek.charts.newBoxPlot({ width = 96, height = 72 })
            chart:addSeries("latency", { 10, 12, 15, 20 })
            expect_type("userdata", chart:renderImage())
        end)

        -- @covers LBubbleChart:drawToImage
        it("drawToImage paints bubble chart output", function()
            local chart = lurek.charts.newBubble({ width = 96, height = 72 })
            chart:addSeries("cities", { { 1, 2, 10 }, { 2, 3, 20 } })
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LRadarChart:draw
        it("draw queues radar chart output", function()
            local chart = lurek.charts.newRadar({ width = 96, height = 72 })
            chart:setAxes({ "a", "b", "c" })
            chart:addSeries("A", { 1, 2, 3 })
            expect_no_error(function()
                chart:draw(4, 6)
            end)
        end)

        -- @covers LTreemapChart:type
        it("type returns treemap chart userdata name", function()
            expect_equal("LTreemapChart", lurek.charts.newTreemap():type())
        end)

        -- @covers LTreemapChart:typeOf
        it("typeOf recognizes treemap chart userdata", function()
            local chart = lurek.charts.newTreemap()
            expect_true(chart:typeOf("LTreemapChart"))
            expect_true(chart:typeOf("LObject"))
        end)

        -- @covers LCandlestickChart:clear
        it("clear removes candlestick data", function()
            local chart = lurek.charts.newCandlestick({ width = 96, height = 72 })
            chart:appendCandle("Mon", 10, 14, 9, 13)
            chart:clear()
            local w = chart:render()
            expect_equal(96, w)
        end)

        -- @covers LBoxPlotChart:setTitle
        it("setTitle annotates additional charts", function()
            local chart = lurek.charts.newBoxPlot({ width = 96, height = 72 })
            chart:setTitle("Latency")
            chart:addSeries("latency", { 10, 12, 15, 20 })
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LBubbleChart:setShowLegend
        it("setShowLegend annotates bubble chart legends", function()
            local chart = lurek.charts.newBubble({ width = 120, height = 90 })
            chart:setShowLegend(true)
            chart:addSeries("cities", { { 1, 2, 10 }, { 2, 3, 20 } })
            expect_chart_draws(chart, 120, 90)
        end)

        -- @covers LRadarChart:getWidth
        it("getWidth returns radar width", function()
            expect_equal(123, lurek.charts.newRadar({ width = 123, height = 80 }):getWidth())
        end)

        -- @covers LRadarChart:getHeight
        it("getHeight returns radar height", function()
            expect_equal(80, lurek.charts.newRadar({ width = 123, height = 80 }):getHeight())
        end)

        -- @covers LCandlestickChart:setTitle
        it("setTitle annotates candlestick charts", function()
            local chart = additional_chart("candlestick")
            chart:setTitle("OHLC")
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LCandlestickChart:setShowLegend
        it("setShowLegend keeps candlestick charts renderable", function()
            local chart = additional_chart("candlestick")
            chart:setShowLegend(true)
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LCandlestickChart:renderImage
        it("renderImage returns candlestick image data", function()
            expect_type("userdata", additional_chart("candlestick"):renderImage())
        end)

        -- @covers LCandlestickChart:drawToImage
        it("drawToImage paints candlestick chart output", function()
            expect_chart_draws(additional_chart("candlestick"), 96, 72)
        end)

        -- @covers LCandlestickChart:draw
        it("draw queues candlestick chart output", function()
            expect_no_error(function()
                additional_chart("candlestick"):draw(4, 6)
            end)
        end)

        -- @covers LCandlestickChart:getWidth
        it("getWidth returns candlestick width", function()
            expect_equal(96, additional_chart("candlestick"):getWidth())
        end)

        -- @covers LCandlestickChart:getHeight
        it("getHeight returns candlestick height", function()
            expect_equal(72, additional_chart("candlestick"):getHeight())
        end)

        -- @covers LCandlestickChart:type
        it("type returns candlestick chart userdata name", function()
            expect_equal("LCandlestickChart", additional_chart("candlestick"):type())
        end)

        -- @covers LCandlestickChart:typeOf
        it("typeOf recognizes candlestick chart userdata", function()
            local chart = additional_chart("candlestick")
            expect_true(chart:typeOf("LCandlestickChart"))
            expect_true(chart:typeOf("LObject"))
        end)

        -- @covers LBoxPlotChart:clear
        it("clear removes boxplot data", function()
            local chart = additional_chart("boxplot")
            chart:clear()
            local w = chart:render()
            expect_equal(96, w)
        end)

        -- @covers LBoxPlotChart:setShowLegend
        it("setShowLegend keeps boxplot charts renderable", function()
            local chart = additional_chart("boxplot")
            chart:setShowLegend(true)
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LBoxPlotChart:render
        it("render returns boxplot bytes", function()
            local w, h, bytes = additional_chart("boxplot"):render()
            expect_equal(96, w)
            expect_equal(72, h)
            expect_true(#bytes > 0)
        end)

        -- @covers LBoxPlotChart:drawToImage
        it("drawToImage paints boxplot chart output", function()
            expect_chart_draws(additional_chart("boxplot"), 96, 72)
        end)

        -- @covers LBoxPlotChart:draw
        it("draw queues boxplot chart output", function()
            expect_no_error(function()
                additional_chart("boxplot"):draw(4, 6)
            end)
        end)

        -- @covers LBoxPlotChart:getWidth
        it("getWidth returns boxplot width", function()
            expect_equal(96, additional_chart("boxplot"):getWidth())
        end)

        -- @covers LBoxPlotChart:getHeight
        it("getHeight returns boxplot height", function()
            expect_equal(72, additional_chart("boxplot"):getHeight())
        end)

        -- @covers LBoxPlotChart:type
        it("type returns boxplot chart userdata name", function()
            expect_equal("LBoxPlotChart", additional_chart("boxplot"):type())
        end)

        -- @covers LBoxPlotChart:typeOf
        it("typeOf recognizes boxplot chart userdata", function()
            local chart = additional_chart("boxplot")
            expect_true(chart:typeOf("LBoxPlotChart"))
            expect_true(chart:typeOf("LObject"))
        end)

        -- @covers LBubbleChart:clear
        it("clear removes bubble chart data", function()
            local chart = additional_chart("bubble")
            chart:clear()
            local w = chart:render()
            expect_equal(96, w)
        end)

        -- @covers LBubbleChart:setTitle
        it("setTitle annotates bubble charts", function()
            local chart = additional_chart("bubble")
            chart:setTitle("Cities")
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LBubbleChart:render
        it("render returns bubble chart bytes", function()
            local w, h, bytes = additional_chart("bubble"):render()
            expect_equal(96, w)
            expect_equal(72, h)
            expect_true(#bytes > 0)
        end)

        -- @covers LBubbleChart:renderImage
        it("renderImage returns bubble image data", function()
            expect_type("userdata", additional_chart("bubble"):renderImage())
        end)

        -- @covers LBubbleChart:draw
        it("draw queues bubble chart output", function()
            expect_no_error(function()
                additional_chart("bubble"):draw(4, 6)
            end)
        end)

        -- @covers LBubbleChart:getWidth
        it("getWidth returns bubble width", function()
            expect_equal(96, additional_chart("bubble"):getWidth())
        end)

        -- @covers LBubbleChart:getHeight
        it("getHeight returns bubble height", function()
            expect_equal(72, additional_chart("bubble"):getHeight())
        end)

        -- @covers LBubbleChart:type
        it("type returns bubble chart userdata name", function()
            expect_equal("LBubbleChart", additional_chart("bubble"):type())
        end)

        -- @covers LBubbleChart:typeOf
        it("typeOf recognizes bubble chart userdata", function()
            local chart = additional_chart("bubble")
            expect_true(chart:typeOf("LBubbleChart"))
            expect_true(chart:typeOf("LObject"))
        end)

        -- @covers LRadarChart:clear
        it("clear removes radar chart data", function()
            local chart = additional_chart("radar")
            chart:clear()
            local w = chart:render()
            expect_equal(96, w)
        end)

        -- @covers LRadarChart:setTitle
        it("setTitle annotates radar charts", function()
            local chart = additional_chart("radar")
            chart:setTitle("Stats")
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LRadarChart:setShowLegend
        it("setShowLegend keeps radar charts renderable", function()
            local chart = additional_chart("radar")
            chart:setShowLegend(true)
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LRadarChart:render
        it("render returns radar chart bytes", function()
            local w, h, bytes = additional_chart("radar"):render()
            expect_equal(96, w)
            expect_equal(72, h)
            expect_true(#bytes > 0)
        end)

        -- @covers LRadarChart:renderImage
        it("renderImage returns radar image data", function()
            expect_type("userdata", additional_chart("radar"):renderImage())
        end)

        -- @covers LRadarChart:drawToImage
        it("drawToImage paints radar chart output", function()
            expect_chart_draws(additional_chart("radar"), 96, 72)
        end)

        -- @covers LRadarChart:type
        it("type returns radar chart userdata name", function()
            expect_equal("LRadarChart", additional_chart("radar"):type())
        end)

        -- @covers LRadarChart:typeOf
        it("typeOf recognizes radar chart userdata", function()
            local chart = additional_chart("radar")
            expect_true(chart:typeOf("LRadarChart"))
            expect_true(chart:typeOf("LObject"))
        end)

        -- @covers LTreemapChart:clear
        it("clear removes treemap data", function()
            local chart = additional_chart("treemap")
            chart:clear()
            local w = chart:render()
            expect_equal(96, w)
        end)

        -- @covers LTreemapChart:setTitle
        it("setTitle annotates treemap charts", function()
            local chart = additional_chart("treemap")
            chart:setTitle("Budget")
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LTreemapChart:setShowLegend
        it("setShowLegend keeps treemap charts renderable", function()
            local chart = additional_chart("treemap")
            chart:setShowLegend(true)
            expect_chart_draws(chart, 96, 72)
        end)

        -- @covers LTreemapChart:render
        it("render returns treemap bytes", function()
            local w, h, bytes = additional_chart("treemap"):render()
            expect_equal(96, w)
            expect_equal(72, h)
            expect_true(#bytes > 0)
        end)

        -- @covers LTreemapChart:renderImage
        it("renderImage returns treemap image data", function()
            expect_type("userdata", additional_chart("treemap"):renderImage())
        end)

        -- @covers LTreemapChart:drawToImage
        it("drawToImage paints treemap chart output", function()
            expect_chart_draws(additional_chart("treemap"), 96, 72)
        end)

        -- @covers LTreemapChart:draw
        it("draw queues treemap chart output", function()
            expect_no_error(function()
                additional_chart("treemap"):draw(4, 6)
            end)
        end)

        -- @covers LTreemapChart:getWidth
        it("getWidth returns treemap width", function()
            expect_equal(96, additional_chart("treemap"):getWidth())
        end)

        -- @covers LTreemapChart:getHeight
        it("getHeight returns treemap height", function()
            expect_equal(72, additional_chart("treemap"):getHeight())
        end)
    end)
end)
end
-- END test_charts_core_unit.lua

test_summary()
