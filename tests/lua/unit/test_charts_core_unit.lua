-- Lurek2D Charts API Tests

-- @describe lurek.charts constructors
describe("lurek.charts constructors", function()
    -- @covers lurek.charts.newLine
    it("newLine returns userdata", function()
        local chart = lurek.charts.newLine()
        expect_not_nil(chart, "should not be nil")
        expect_equal("userdata", type(chart))
    end)

    -- @covers lurek.charts.newBar
    it("newBar returns userdata", function()
        local chart = lurek.charts.newBar()
        expect_not_nil(chart, "should not be nil")
        expect_equal("userdata", type(chart))
    end)

    -- @covers lurek.charts.newScatter
    it("newScatter returns userdata", function()
        local chart = lurek.charts.newScatter()
        expect_not_nil(chart, "should not be nil")
        expect_equal("userdata", type(chart))
    end)

    -- @covers lurek.charts.newPie
    it("newPie returns userdata", function()
        local chart = lurek.charts.newPie()
        expect_not_nil(chart, "should not be nil")
        expect_equal("userdata", type(chart))
    end)

    -- @covers lurek.charts.newArea
    it("newArea returns userdata", function()
        local chart = lurek.charts.newArea()
        expect_not_nil(chart, "should not be nil")
        expect_equal("userdata", type(chart))
    end)
end)

-- @describe lurek.charts.defaultPalette
describe("lurek.charts.defaultPalette", function()
    -- @covers lurek.charts.defaultPalette
    it("returns table with 8 entries", function()
        local pal = lurek.charts.defaultPalette()
        expect_equal(8, #pal)
    end)

    -- @covers lurek.charts.defaultPalette
    it("each entry is an RGBA table with 4 values", function()
        local pal = lurek.charts.defaultPalette()
        for i = 1, #pal do
            expect_equal(4, #pal[i])
            expect_true(pal[i][1] >= 0 and pal[i][1] <= 1, "r in range")
            expect_true(pal[i][4] >= 0 and pal[i][4] <= 1, "a in range")
        end
    end)
end)

-- @describe lurek.charts.seriesColor
describe("lurek.charts.seriesColor", function()
    -- @covers lurek.charts.seriesColor
    it("index 1 returns table with 4 numbers", function()
        local c = lurek.charts.seriesColor(1)
        expect_equal(4, #c)
        expect_true(type(c[1]) == "number", "r is number")
        expect_true(type(c[2]) == "number", "g is number")
        expect_true(type(c[3]) == "number", "b is number")
        expect_true(type(c[4]) == "number", "a is number")
    end)

    -- @covers lurek.charts.seriesColor
    it("index wraps around for index > 8", function()
        local c1 = lurek.charts.seriesColor(1)
        local c9 = lurek.charts.seriesColor(9)
        expect_near(c1[1], c9[1], 0.01)
        expect_near(c1[2], c9[2], 0.01)
        expect_near(c1[3], c9[3], 0.01)
        expect_near(c1[4], c9[4], 0.01)
    end)

    -- @covers lurek.charts.seriesColor
    it("index 0 raises an error", function()
        expect_error(function()
            lurek.charts.seriesColor(0)
        end)
    end)
end)

-- @describe LuaLineChart methods
describe("LuaLineChart methods", function()
    -- @covers lurek.charts.newLine
    -- @covers LLineChart:getWidth
    -- @covers LLineChart:getHeight
    it("custom config width is respected", function()
        local chart = lurek.charts.newLine({width = 800, height = 600})
        expect_equal(800, chart:getWidth())
        expect_equal(600, chart:getHeight())
    end)
    -- @covers lurek.charts.newLine
    -- @covers LLineChart:addSeries
    -- @covers LLineChart:render
    it("addSeries then render returns 3 values", function()
        local chart = lurek.charts.newLine()
        chart:addSeries("test", {{1, 2}, {3, 4}, {5, 6}})
        local w, h, data = chart:render()
        expect_true(w > 0, "width > 0")
        expect_true(h > 0, "height > 0")
        expect_true(type(data) == "string", "data is a string")
        expect_true(#data > 0, "data is not empty")
    end)
    -- @covers lurek.charts.newLine
    -- @covers LLineChart:addSeries
    -- @covers LLineChart:clear
    -- @covers LLineChart:render
    it("clear then render still works", function()
        local chart = lurek.charts.newLine()
        chart:addSeries("test", {{1, 2}, {3, 4}})
        chart:clear()
        local w, h, data = chart:render()
        expect_true(w > 0, "width > 0 after clear")
        expect_true(type(data) == "string", "data is string after clear")
    end)
    -- @covers lurek.charts.newLine
    -- @covers LLineChart:setTitle
    -- @covers LLineChart:render
    it("setTitle does not error", function()
        local chart = lurek.charts.newLine()
        chart:setTitle("My Line Chart")
        local w, h, data = chart:render()
        expect_true(w > 0, "renders after setTitle")
    end)
end)

-- @describe LuaBarChart methods
describe("LuaBarChart methods", function()
    -- @covers lurek.charts.newBar
    -- @covers LBarChart:addSeries
    -- @covers LBarChart:render
    it("addSeries and render returns valid data", function()
        local chart = lurek.charts.newBar()
        chart:addSeries("sales", {{1, 10}, {2, 20}, {3, 15}})
        local w, h, data = chart:render()
        expect_true(w > 0, "width > 0")
        expect_true(h > 0, "height > 0")
        expect_true(#data > 0, "data not empty")
    end)
    -- @covers lurek.charts.newBar
    -- @covers LBarChart:setBarWidth
    -- @covers LBarChart:addSeries
    -- @covers LBarChart:render
    it("setBarWidth does not error", function()
        local chart = lurek.charts.newBar()
        chart:setBarWidth(20)
        chart:addSeries("test", {{1, 5}})
        local w, h, data = chart:render()
        expect_true(w > 0, "renders after setBarWidth")
    end)
    -- @covers lurek.charts.newBar
    -- @covers LBarChart:addSeries
    -- @covers LBarChart:clear
    -- @covers LBarChart:render
    it("clear removes all series", function()
        local chart = lurek.charts.newBar()
        chart:addSeries("a", {{1, 1}})
        chart:clear()
        local w, h, data = chart:render()
        expect_true(w > 0, "renders after clear")
    end)
    -- @covers lurek.charts.newBar
    -- @covers LBarChart:getWidth
    -- @covers LBarChart:getHeight
    it("custom config dimensions", function()
        local chart = lurek.charts.newBar({width = 640, height = 480})
        expect_equal(640, chart:getWidth())
        expect_equal(480, chart:getHeight())
    end)
    -- @covers LBarChart:setTitle
    it("setTitle updates bar chart title", function()
        local chart = lurek.charts.newBar()
        chart:setTitle("Bar Title")
        local w, h, data = chart:render()
        expect_true(w > 0, "renders after setTitle")
    end)
end)

-- @describe LuaScatterPlot methods
describe("LuaScatterPlot methods", function()
    -- @covers lurek.charts.newScatter
    -- @covers LScatterPlot:addSeries
    -- @covers LScatterPlot:render
    it("addSeries and render works", function()
        local chart = lurek.charts.newScatter()
        chart:addSeries("points", {{1, 1}, {2, 4}, {3, 9}})
        local w, h, data = chart:render()
        expect_true(w > 0, "width > 0")
        expect_true(h > 0, "height > 0")
        expect_true(#data > 0, "data not empty")
    end)
    -- @covers lurek.charts.newScatter
    -- @covers LScatterPlot:setDotRadius
    -- @covers LScatterPlot:addSeries
    -- @covers LScatterPlot:render
    it("setDotRadius does not error", function()
        local chart = lurek.charts.newScatter()
        chart:setDotRadius(5)
        chart:addSeries("dots", {{0, 0}})
        local w, h, data = chart:render()
        expect_true(w > 0, "renders after setDotRadius")
    end)
    -- @covers lurek.charts.newScatter
    -- @covers LScatterPlot:addSeries
    -- @covers LScatterPlot:clear
    -- @covers LScatterPlot:render
    it("clear and render on empty chart", function()
        local chart = lurek.charts.newScatter()
        chart:addSeries("x", {{1, 2}})
        chart:clear()
        local w, h, data = chart:render()
        expect_true(type(data) == "string", "data is string")
    end)
    -- @covers LScatterPlot:setTitle
    it("setTitle updates scatter chart title", function()
        local chart = lurek.charts.newScatter()
        chart:setTitle("Scatter Title")
        chart:addSeries("dots", {{1, 1}})
        local w, h, data = chart:render()
        expect_true(w > 0, "renders after setTitle")
    end)

    -- @covers LScatterPlot:getWidth
    it("getWidth returns configured width", function()
        local chart = lurek.charts.newScatter({width = 700, height = 350})
        expect_equal(700, chart:getWidth())
    end)

    -- @covers LScatterPlot:getHeight
    it("getHeight returns configured height", function()
        local chart = lurek.charts.newScatter({width = 700, height = 350})
        expect_equal(350, chart:getHeight())
    end)
end)

-- @describe LuaPieChart methods
describe("LuaPieChart methods", function()
    -- @covers lurek.charts.newPie
    -- @covers LPieChart:addSlice
    -- @covers LPieChart:render
    it("addSlice and render works", function()
        local chart = lurek.charts.newPie()
        chart:addSlice("A", 30)
        chart:addSlice("B", 50)
        chart:addSlice("C", 20)
        local w, h, data = chart:render()
        expect_true(w > 0, "width > 0")
        expect_true(h > 0, "height > 0")
        expect_true(#data > 0, "data not empty")
    end)
    -- @covers lurek.charts.newPie
    -- @covers LPieChart:addSlice
    -- @covers LPieChart:render
    it("addSlice with auto-color assigns palette colors", function()
        local chart = lurek.charts.newPie()
        chart:addSlice("First", 100)
        chart:addSlice("Second", 200)
        local w, h, data = chart:render()
        expect_true(#data > 0, "renders with auto-colors")
    end)
    -- @covers lurek.charts.newPie
    -- @covers LPieChart:addSlice
    -- @covers LPieChart:clear
    -- @covers LPieChart:render
    it("clear removes all slices", function()
        local chart = lurek.charts.newPie()
        chart:addSlice("X", 50)
        chart:clear()
        local w, h, data = chart:render()
        expect_true(type(data) == "string", "renders after clear")
    end)
    -- @covers lurek.charts.newPie
    -- @covers LPieChart:setTitle
    -- @covers LPieChart:addSlice
    -- @covers LPieChart:render
    it("setTitle updates without error", function()
        local chart = lurek.charts.newPie()
        chart:setTitle("Pie Distribution")
        chart:addSlice("Slice", 100)
        local w, h, data = chart:render()
        expect_true(w > 0, "renders with title")
    end)
    -- @covers LPieChart:getWidth
    it("getWidth returns configured width", function()
        local chart = lurek.charts.newPie({width = 420, height = 240})
        expect_equal(420, chart:getWidth())
    end)

    -- @covers LPieChart:getHeight
    it("getHeight returns configured height", function()
        local chart = lurek.charts.newPie({width = 420, height = 240})
        expect_equal(240, chart:getHeight())
    end)
end)

-- @describe LuaAreaChart methods
describe("LuaAreaChart methods", function()
    -- @covers lurek.charts.newArea
    -- @covers LAreaChart:addSeries
    -- @covers LAreaChart:render
    it("addSeries and render works", function()
        local chart = lurek.charts.newArea()
        chart:addSeries("temp", {{1, 10}, {2, 20}, {3, 15}, {4, 25}})
        local w, h, data = chart:render()
        expect_true(w > 0, "width > 0")
        expect_true(h > 0, "height > 0")
        expect_true(#data > 0, "data not empty")
    end)
    -- @covers lurek.charts.newArea
    -- @covers LAreaChart:addSeries
    -- @covers LAreaChart:clear
    -- @covers LAreaChart:render
    it("clear removes all series", function()
        local chart = lurek.charts.newArea()
        chart:addSeries("data", {{0, 5}, {1, 10}})
        chart:clear()
        local w, h, data = chart:render()
        expect_true(type(data) == "string", "renders after clear")
    end)
    -- @covers lurek.charts.newArea
    -- @covers LAreaChart:getWidth
    -- @covers LAreaChart:getHeight
    -- @covers LAreaChart:addSeries
    -- @covers LAreaChart:render
    it("custom config with title renders", function()
        local chart = lurek.charts.newArea({width = 1024, height = 768, title = "Area Chart"})
        expect_equal(1024, chart:getWidth())
        expect_equal(768, chart:getHeight())
        chart:addSeries("s1", {{0, 0}, {10, 10}})
        local w, h, data = chart:render()
        expect_equal(1024, w)
        expect_equal(768, h)
    end)
    -- @covers LAreaChart:setTitle
    it("setTitle updates area chart title", function()
        local chart = lurek.charts.newArea()
        chart:setTitle("Area Title")
        chart:addSeries("s", {{1, 1}})
        local w, h, data = chart:render()
        expect_true(w > 0, "renders after setTitle")
    end)
end)

-- @describe chart config
describe("chart config", function()
    -- @covers lurek.charts.newLine
    -- @covers LLineChart:getWidth
    -- @covers LLineChart:getHeight
    it("default dimensions are applied", function()
        local chart = lurek.charts.newLine()
        expect_true(chart:getWidth() > 0, "default width > 0")
        expect_true(chart:getHeight() > 0, "default height > 0")
    end)
    -- @covers lurek.charts.newBar
    -- @covers LBarChart:getWidth
    -- @covers LBarChart:getHeight
    it("config title does not affect dimensions", function()
        local chart = lurek.charts.newBar({width = 500, height = 300, title = "Test"})
        expect_equal(500, chart:getWidth())
        expect_equal(300, chart:getHeight())
    end)
end)
test_summary()
