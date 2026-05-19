-- ui_06.lua: Charts — area, bar, line, pie, scatter

--@api-stub: lurek.ui.newAreaChart
do
    -- create an area chart with stacked layers
    ---@type LAreaChart
    local chart = lurek.ui.newAreaChart({ width = 400, height = 200, title = "CPU Usage" })
    chart:addLayer("user", { 10, 25, 30, 45, 50, 40, 35 }, 0.2, 0.6, 1.0)
    chart:addLayer("system", { 5, 10, 15, 20, 15, 10, 8 }, 1.0, 0.4, 0.2)
    chart:setYMax(100)
    print("area chart type:", chart:type())
    print("is area chart:", chart:typeOf("LAreaChart"))
end

--@api-stub: lurek.ui.newBarChart
do
    -- create a bar chart with categories and series
    ---@type LBarChart
    local chart = lurek.ui.newBarChart({ width = 300, height = 200, title = "Sales" })
    chart:addSeries("Q1", 0.2, 0.8, 0.4)
    chart:addSeries("Q2", 0.8, 0.2, 0.4)
    chart:addCategory("Widgets", { 150, 200 })
    chart:addCategory("Gadgets", { 90, 120 })
    chart:addCategory("Tools", { 60, 80 })
    print("bar chart type:", chart:type())
end

--@api-stub: lurek.ui.newLineChart
do
    -- create a line chart with data series
    ---@type LLineChart
    local chart = lurek.ui.newLineChart({ width = 400, height = 250, title = "Temperature" })
    chart:addSeries("indoor", {
        { x = 0, y = 20 }, { x = 6, y = 19 }, { x = 12, y = 22 }, { x = 18, y = 21 }, { x = 24, y = 20 }
    }, 1.0, 0.3, 0.3)
    chart:addSeries("outdoor", {
        { x = 0, y = 5 }, { x = 6, y = 3 }, { x = 12, y = 15 }, { x = 18, y = 10 }, { x = 24, y = 6 }
    }, 0.3, 0.3, 1.0)
    chart:setXMax(24)
    chart:setYMax(30)
    print("line chart type:", chart:type())
end

--@api-stub: lurek.ui.newPieChart
do
    -- create a pie chart with labeled segments
    ---@type LPieChart
    local chart = lurek.ui.newPieChart({ width = 200, height = 200, title = "Market Share" })
    chart:addSegment("Product A", 45, 0.2, 0.6, 1.0)
    chart:addSegment("Product B", 30, 1.0, 0.4, 0.2)
    chart:addSegment("Product C", 15, 0.3, 0.9, 0.3)
    chart:addSegment("Other", 10, 0.7, 0.7, 0.7)
    print("pie chart type:", chart:type())
    print("is pie chart:", chart:typeOf("LPieChart"))
end

--@api-stub: lurek.ui.newScatterPlot
do
    -- create a scatter plot with data points
    ---@type LScatterPlot
    local chart = lurek.ui.newScatterPlot({ width = 400, height = 300, title = "Height vs Weight" })
    chart:addSeries("male", {
        { x = 170, y = 70 }, { x = 180, y = 80 }, { x = 175, y = 75 }, { x = 185, y = 90 }
    }, 0.2, 0.5, 1.0)
    chart:addSeries("female", {
        { x = 160, y = 55 }, { x = 165, y = 60 }, { x = 170, y = 65 }, { x = 155, y = 50 }
    }, 1.0, 0.3, 0.6)
    chart:setXRange(150, 200)
    chart:setYRange(40, 100)
    print("scatter plot type:", chart:type())
end

print("ui_06.lua")
