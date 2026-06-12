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
end)
end
-- END test_charts_core_unit.lua

test_summary()
