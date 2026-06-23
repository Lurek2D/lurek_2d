-- content/examples/charts.lua
-- Run: cargo run -- content/examples/charts.lua

--- Charts Examples: compact standalone blocks for chart APIs

--@api: lurek.charts.newLine
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("line width=" .. tostring(width))
    lurek.log.info("line height=" .. tostring(height))
end

--@api: lurek.charts.newBar
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("bar width=" .. tostring(width))
    lurek.log.info("bar height=" .. tostring(height))
end

--@api: lurek.charts.newScatter
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("scatter width=" .. tostring(width))
    lurek.log.info("scatter height=" .. tostring(height))
end

--@api: lurek.charts.newPie
do
    local chart = lurek.charts.newPie({ width = 160, height = 120, title = "Pie" })
    chart:addSlice("North", 12)
    chart:addSlice("South", 8)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("pie width=" .. tostring(width))
    lurek.log.info("pie height=" .. tostring(height))
end

--@api: lurek.charts.newArea
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("area width=" .. tostring(width))
    lurek.log.info("area height=" .. tostring(height))
end

--@api: lurek.charts.defaultPalette
do
    local palette = lurek.charts.defaultPalette()
    local first = palette[1]
    local second = lurek.charts.seriesColor(2)
    lurek.log.info("palette count=" .. tostring(#palette))
    lurek.log.info("first color=" .. tostring(first))
    lurek.log.info("series color=" .. tostring(second))
end

--@api: lurek.charts.seriesColor
do
    local first = lurek.charts.seriesColor(1)
    local second = lurek.charts.seriesColor(2)
    local palette = lurek.charts.defaultPalette()
    lurek.log.info("first color=" .. tostring(first))
    lurek.log.info("second color=" .. tostring(second))
    lurek.log.info("palette count=" .. tostring(#palette))
end

--@api: LAreaChart:addSeries
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:addSeries("north", { { 1, 9 }, { 2, 14 }, { 3, 11 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("addSeries width=" .. tostring(width))
    lurek.log.info("addSeries height=" .. tostring(height))
end

--@api: LAreaChart:clear
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:clear()
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("clear width=" .. tostring(width))
    lurek.log.info("clear height=" .. tostring(height))
end

--@api: LAreaChart:setTitle
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setTitle("Area example")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setTitle width=" .. tostring(width))
    lurek.log.info("setTitle height=" .. tostring(height))
end

--@api: LAreaChart:render
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local w, h, pixels = chart:render()
    lurek.log.info("render size=" .. tostring(w) .. "x" .. tostring(h))
    lurek.log.info("render bytes=" .. tostring(#pixels))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("render width=" .. tostring(width))
    lurek.log.info("render height=" .. tostring(height))
end

--@api: LAreaChart:getWidth
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    lurek.log.info("width=" .. tostring(chart:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getWidth width=" .. tostring(width))
    lurek.log.info("getWidth height=" .. tostring(height))
end

--@api: LAreaChart:getHeight
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    lurek.log.info("height=" .. tostring(chart:getHeight()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getHeight width=" .. tostring(width))
    lurek.log.info("getHeight height=" .. tostring(height))
end

--@api: LBarChart:addSeries
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:addSeries("north", { { 1, 9 }, { 2, 14 }, { 3, 11 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("addSeries width=" .. tostring(width))
    lurek.log.info("addSeries height=" .. tostring(height))
end

--@api: LBarChart:clear
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:clear()
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("clear width=" .. tostring(width))
    lurek.log.info("clear height=" .. tostring(height))
end

--@api: LBarChart:setBarWidth
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setBarWidth(0.65)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setBarWidth width=" .. tostring(width))
    lurek.log.info("setBarWidth height=" .. tostring(height))
end

--@api: LBarChart:setTitle
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setTitle("Bar example")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setTitle width=" .. tostring(width))
    lurek.log.info("setTitle height=" .. tostring(height))
end

--@api: LBarChart:render
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local w, h, pixels = chart:render()
    lurek.log.info("render size=" .. tostring(w) .. "x" .. tostring(h))
    lurek.log.info("render bytes=" .. tostring(#pixels))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("render width=" .. tostring(width))
    lurek.log.info("render height=" .. tostring(height))
end

--@api: LBarChart:getWidth
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    lurek.log.info("width=" .. tostring(chart:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getWidth width=" .. tostring(width))
    lurek.log.info("getWidth height=" .. tostring(height))
end

--@api: LBarChart:getHeight
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    lurek.log.info("height=" .. tostring(chart:getHeight()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getHeight width=" .. tostring(width))
    lurek.log.info("getHeight height=" .. tostring(height))
end

--@api: LLineChart:addSeries
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:addSeries("north", { { 1, 9 }, { 2, 14 }, { 3, 11 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("addSeries width=" .. tostring(width))
    lurek.log.info("addSeries height=" .. tostring(height))
end

--@api: LLineChart:clear
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:clear()
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("clear width=" .. tostring(width))
    lurek.log.info("clear height=" .. tostring(height))
end

--@api: LLineChart:setTitle
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setTitle("Line example")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setTitle width=" .. tostring(width))
    lurek.log.info("setTitle height=" .. tostring(height))
end

--@api: LLineChart:render
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local w, h, pixels = chart:render()
    lurek.log.info("render size=" .. tostring(w) .. "x" .. tostring(h))
    lurek.log.info("render bytes=" .. tostring(#pixels))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("render width=" .. tostring(width))
    lurek.log.info("render height=" .. tostring(height))
end

--@api: LLineChart:getWidth
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    lurek.log.info("width=" .. tostring(chart:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getWidth width=" .. tostring(width))
    lurek.log.info("getWidth height=" .. tostring(height))
end

--@api: LLineChart:getHeight
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    lurek.log.info("height=" .. tostring(chart:getHeight()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getHeight width=" .. tostring(width))
    lurek.log.info("getHeight height=" .. tostring(height))
end

--@api: LPieChart:addSlice
do
    local chart = lurek.charts.newPie({ width = 160, height = 120, title = "Pie" })
    chart:addSlice("North", 12)
    chart:addSlice("South", 8)
    chart:addSlice("East", 6)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("addSlice width=" .. tostring(width))
    lurek.log.info("addSlice height=" .. tostring(height))
end

--@api: LPieChart:clear
do
    local chart = lurek.charts.newPie({ width = 160, height = 120, title = "Pie" })
    chart:addSlice("North", 12)
    chart:addSlice("South", 8)
    chart:clear()
    chart:addSlice("North", 12)
    chart:addSlice("South", 8)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("clear width=" .. tostring(width))
    lurek.log.info("clear height=" .. tostring(height))
end

--@api: LPieChart:setTitle
do
    local chart = lurek.charts.newPie({ width = 160, height = 120, title = "Pie" })
    chart:addSlice("North", 12)
    chart:addSlice("South", 8)
    chart:setTitle("Pie example")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setTitle width=" .. tostring(width))
    lurek.log.info("setTitle height=" .. tostring(height))
end

--@api: LPieChart:render
do
    local chart = lurek.charts.newPie({ width = 160, height = 120, title = "Pie" })
    chart:addSlice("North", 12)
    chart:addSlice("South", 8)
    local w, h, pixels = chart:render()
    lurek.log.info("render size=" .. tostring(w) .. "x" .. tostring(h))
    lurek.log.info("render bytes=" .. tostring(#pixels))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("render width=" .. tostring(width))
    lurek.log.info("render height=" .. tostring(height))
end

--@api: LPieChart:getWidth
do
    local chart = lurek.charts.newPie({ width = 160, height = 120, title = "Pie" })
    chart:addSlice("North", 12)
    chart:addSlice("South", 8)
    lurek.log.info("width=" .. tostring(chart:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getWidth width=" .. tostring(width))
    lurek.log.info("getWidth height=" .. tostring(height))
end

--@api: LPieChart:getHeight
do
    local chart = lurek.charts.newPie({ width = 160, height = 120, title = "Pie" })
    chart:addSlice("North", 12)
    chart:addSlice("South", 8)
    lurek.log.info("height=" .. tostring(chart:getHeight()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getHeight width=" .. tostring(width))
    lurek.log.info("getHeight height=" .. tostring(height))
end

--@api: LScatterPlot:addSeries
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:addSeries("north", { { 1, 9 }, { 2, 14 }, { 3, 11 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("addSeries width=" .. tostring(width))
    lurek.log.info("addSeries height=" .. tostring(height))
end

--@api: LScatterPlot:clear
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:clear()
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("clear width=" .. tostring(width))
    lurek.log.info("clear height=" .. tostring(height))
end

--@api: LScatterPlot:setDotRadius
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setDotRadius(4)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setDotRadius width=" .. tostring(width))
    lurek.log.info("setDotRadius height=" .. tostring(height))
end

--@api: LScatterPlot:setTitle
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setTitle("Scatter example")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setTitle width=" .. tostring(width))
    lurek.log.info("setTitle height=" .. tostring(height))
end

--@api: LScatterPlot:render
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local w, h, pixels = chart:render()
    lurek.log.info("render size=" .. tostring(w) .. "x" .. tostring(h))
    lurek.log.info("render bytes=" .. tostring(#pixels))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("render width=" .. tostring(width))
    lurek.log.info("render height=" .. tostring(height))
end

--@api: LScatterPlot:getWidth
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    lurek.log.info("width=" .. tostring(chart:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getWidth width=" .. tostring(width))
    lurek.log.info("getWidth height=" .. tostring(height))
end

--@api: LScatterPlot:getHeight
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    lurek.log.info("height=" .. tostring(chart:getHeight()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getHeight width=" .. tostring(width))
    lurek.log.info("getHeight height=" .. tostring(height))
end

--@api: lurek.charts.newHistogram
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("histogram width=" .. tostring(width))
    lurek.log.info("histogram height=" .. tostring(height))
end

--@api: lurek.charts.newHeatmap
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("heatmap width=" .. tostring(width))
    lurek.log.info("heatmap height=" .. tostring(height))
end

--@api: LAreaChart:addLayer
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:addLayer("trend", { 8, 12, 10 })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("addLayer width=" .. tostring(width))
    lurek.log.info("addLayer height=" .. tostring(height))
end

--@api: LAreaChart:addLayerFromDataFrame
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local df = lurek.dataframe.fromTable({
        { month = 1, label = "Jan", north = 12, south = 8, east = 5, value = 12, x = 1, y = 12, row = "North", col = "Q1" },
        { month = 2, label = "Feb", north = 18, south = 11, east = 7, value = 18, x = 2, y = 18, row = "North", col = "Q2" },
        { month = 3, label = "Mar", north = 15, south = 14, east = 9, value = 15, x = 3, y = 15, row = "South", col = "Q1" },
    })
    local added = chart:addLayerFromDataFrame("north", df, "north")
    lurek.log.info("rows added=" .. tostring(added))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("addLayerFromDataFrame width=" .. tostring(width))
    lurek.log.info("addLayerFromDataFrame height=" .. tostring(height))
end

--@api: LAreaChart:appendPoint
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:appendPoint("north", 4, 17)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("appendPoint width=" .. tostring(width))
    lurek.log.info("appendPoint height=" .. tostring(height))
end

--@api: LAreaChart:setWindow
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setWindow(2)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setWindow width=" .. tostring(width))
    lurek.log.info("setWindow height=" .. tostring(height))
end

--@api: LAreaChart:setYMax
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setYMax(30)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setYMax width=" .. tostring(width))
    lurek.log.info("setYMax height=" .. tostring(height))
end

--@api: LAreaChart:setXLabel
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setXLabel("Month")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setXLabel width=" .. tostring(width))
    lurek.log.info("setXLabel height=" .. tostring(height))
end

--@api: LAreaChart:setYLabel
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setYLabel("Value")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setYLabel width=" .. tostring(width))
    lurek.log.info("setYLabel height=" .. tostring(height))
end

--@api: LAreaChart:setXTickCount
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setXTickCount(4)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setXTickCount width=" .. tostring(width))
    lurek.log.info("setXTickCount height=" .. tostring(height))
end

--@api: LAreaChart:setYTickCount
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setYTickCount(4)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setYTickCount width=" .. tostring(width))
    lurek.log.info("setYTickCount height=" .. tostring(height))
end

--@api: LAreaChart:setShowLegend
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setShowLegend(true)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setShowLegend width=" .. tostring(width))
    lurek.log.info("setShowLegend height=" .. tostring(height))
end

--@api: LAreaChart:renderImage
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local image = chart:renderImage()
    lurek.log.info("image width=" .. tostring(image:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("renderImage width=" .. tostring(width))
    lurek.log.info("renderImage height=" .. tostring(height))
end

--@api: LAreaChart:drawToImage
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local target = lurek.image.newImageData(160, 120)
    chart:drawToImage(target)
    lurek.log.info("target width=" .. tostring(target:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("drawToImage width=" .. tostring(width))
    lurek.log.info("drawToImage height=" .. tostring(height))
end

--@api: LAreaChart:draw
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:draw(12, 18, {})
    lurek.log.info("draw issued=true")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("draw width=" .. tostring(width))
    lurek.log.info("draw height=" .. tostring(height))
end

--@api: LAreaChart:type
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    lurek.log.info("type=" .. tostring(chart:type()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("type width=" .. tostring(width))
    lurek.log.info("type height=" .. tostring(height))
end

--@api: LAreaChart:typeOf
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    lurek.log.info("typeOf exact=" .. tostring(chart:typeOf("LAreaChart")))
    lurek.log.info("typeOf object=" .. tostring(chart:typeOf("LObject")))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("typeOf width=" .. tostring(width))
    lurek.log.info("typeOf height=" .. tostring(height))
end

--@api: LBarChart:addCategory
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:addCategory("Q1", { 12, 8, 5 })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("addCategory width=" .. tostring(width))
    lurek.log.info("addCategory height=" .. tostring(height))
end

--@api: LBarChart:addCategoriesFromDataFrame
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local df = lurek.dataframe.fromTable({
        { month = 1, label = "Jan", north = 12, south = 8, east = 5, value = 12, x = 1, y = 12, row = "North", col = "Q1" },
        { month = 2, label = "Feb", north = 18, south = 11, east = 7, value = 18, x = 2, y = 18, row = "North", col = "Q2" },
        { month = 3, label = "Mar", north = 15, south = 14, east = 9, value = 15, x = 3, y = 15, row = "South", col = "Q1" },
    })
    local added = chart:addCategoriesFromDataFrame(df, "label", { "north", "south", "east" })
    lurek.log.info("categories added=" .. tostring(added))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("addCategoriesFromDataFrame width=" .. tostring(width))
    lurek.log.info("addCategoriesFromDataFrame height=" .. tostring(height))
end

--@api: LBarChart:setXLabel
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setXLabel("Month")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setXLabel width=" .. tostring(width))
    lurek.log.info("setXLabel height=" .. tostring(height))
end

--@api: LBarChart:setYLabel
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setYLabel("Value")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setYLabel width=" .. tostring(width))
    lurek.log.info("setYLabel height=" .. tostring(height))
end

--@api: LBarChart:setXTickCount
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setXTickCount(4)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setXTickCount width=" .. tostring(width))
    lurek.log.info("setXTickCount height=" .. tostring(height))
end

--@api: LBarChart:setYTickCount
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setYTickCount(4)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setYTickCount width=" .. tostring(width))
    lurek.log.info("setYTickCount height=" .. tostring(height))
end

--@api: LBarChart:setShowLegend
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setShowLegend(true)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setShowLegend width=" .. tostring(width))
    lurek.log.info("setShowLegend height=" .. tostring(height))
end

--@api: LBarChart:renderImage
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local image = chart:renderImage()
    lurek.log.info("image width=" .. tostring(image:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("renderImage width=" .. tostring(width))
    lurek.log.info("renderImage height=" .. tostring(height))
end

--@api: LBarChart:drawToImage
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local target = lurek.image.newImageData(160, 120)
    chart:drawToImage(target)
    lurek.log.info("target width=" .. tostring(target:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("drawToImage width=" .. tostring(width))
    lurek.log.info("drawToImage height=" .. tostring(height))
end

--@api: LBarChart:draw
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:draw(12, 18, {})
    lurek.log.info("draw issued=true")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("draw width=" .. tostring(width))
    lurek.log.info("draw height=" .. tostring(height))
end

--@api: LBarChart:type
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    lurek.log.info("type=" .. tostring(chart:type()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("type width=" .. tostring(width))
    lurek.log.info("type height=" .. tostring(height))
end

--@api: LBarChart:typeOf
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    lurek.log.info("typeOf exact=" .. tostring(chart:typeOf("LBarChart")))
    lurek.log.info("typeOf object=" .. tostring(chart:typeOf("LObject")))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("typeOf width=" .. tostring(width))
    lurek.log.info("typeOf height=" .. tostring(height))
end

--@api: LHeatmapChart:setMatrix
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setMatrix width=" .. tostring(width))
    lurek.log.info("setMatrix height=" .. tostring(height))
end

--@api: LHeatmapChart:setMatrixFromDataFrame
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    local df = lurek.dataframe.fromTable({
        { month = 1, label = "Jan", north = 12, south = 8, east = 5, value = 12, x = 1, y = 12, row = "North", col = "Q1" },
        { month = 2, label = "Feb", north = 18, south = 11, east = 7, value = 18, x = 2, y = 18, row = "North", col = "Q2" },
        { month = 3, label = "Mar", north = 15, south = 14, east = 9, value = 15, x = 3, y = 15, row = "South", col = "Q1" },
    })
    local cells = chart:setMatrixFromDataFrame(df, "row", "col", "value")
    lurek.log.info("cells=" .. tostring(cells))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setMatrixFromDataFrame width=" .. tostring(width))
    lurek.log.info("setMatrixFromDataFrame height=" .. tostring(height))
end

--@api: LHeatmapChart:resize
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    chart:resize(3, 2)
    chart:setCell(1, 1, 1.5)
    chart:setCell(3, 2, 4.5)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("resize width=" .. tostring(width))
    lurek.log.info("resize height=" .. tostring(height))
end

--@api: LHeatmapChart:setCell
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    chart:resize(2, 2)
    chart:setCell(1, 1, 2.5)
    chart:setCell(2, 2, 7.5)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setCell width=" .. tostring(width))
    lurek.log.info("setCell height=" .. tostring(height))
end

--@api: LHeatmapChart:clear
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    chart:clear()
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("clear width=" .. tostring(width))
    lurek.log.info("clear height=" .. tostring(height))
end

--@api: LHeatmapChart:setRowLabels
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    chart:setRowLabels({ "North", "South" })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setRowLabels width=" .. tostring(width))
    lurek.log.info("setRowLabels height=" .. tostring(height))
end

--@api: LHeatmapChart:setColumnLabels
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    chart:setColumnLabels({ "Q1", "Q2" })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setColumnLabels width=" .. tostring(width))
    lurek.log.info("setColumnLabels height=" .. tostring(height))
end

--@api: LHeatmapChart:setValueRange
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    chart:setValueRange(0, 10)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setValueRange width=" .. tostring(width))
    lurek.log.info("setValueRange height=" .. tostring(height))
end

--@api: LHeatmapChart:clearValueRange
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    chart:setValueRange(0, 10)
    chart:clearValueRange()
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("clearValueRange width=" .. tostring(width))
    lurek.log.info("clearValueRange height=" .. tostring(height))
end

--@api: LHeatmapChart:setColorRange
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    chart:setColorRange({ 0.1, 0.2, 0.8, 1.0 }, { 0.9, 0.1, 0.1, 1.0 })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setColorRange width=" .. tostring(width))
    lurek.log.info("setColorRange height=" .. tostring(height))
end

--@api: LHeatmapChart:setShowValues
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    chart:setShowValues(true)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setShowValues width=" .. tostring(width))
    lurek.log.info("setShowValues height=" .. tostring(height))
end

--@api: LHeatmapChart:setTitle
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    chart:setTitle("Heatmap example")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setTitle width=" .. tostring(width))
    lurek.log.info("setTitle height=" .. tostring(height))
end

--@api: LHeatmapChart:setShowLegend
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    chart:setShowLegend(true)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setShowLegend width=" .. tostring(width))
    lurek.log.info("setShowLegend height=" .. tostring(height))
end

--@api: LHeatmapChart:render
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    local w, h, pixels = chart:render()
    lurek.log.info("render size=" .. tostring(w) .. "x" .. tostring(h))
    lurek.log.info("render bytes=" .. tostring(#pixels))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("render width=" .. tostring(width))
    lurek.log.info("render height=" .. tostring(height))
end

--@api: LHeatmapChart:renderImage
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    local image = chart:renderImage()
    lurek.log.info("image width=" .. tostring(image:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("renderImage width=" .. tostring(width))
    lurek.log.info("renderImage height=" .. tostring(height))
end

--@api: LHeatmapChart:drawToImage
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    local target = lurek.image.newImageData(160, 120)
    chart:drawToImage(target)
    lurek.log.info("target width=" .. tostring(target:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("drawToImage width=" .. tostring(width))
    lurek.log.info("drawToImage height=" .. tostring(height))
end

--@api: LHeatmapChart:draw
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    chart:draw(12, 18, {})
    lurek.log.info("draw issued=true")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("draw width=" .. tostring(width))
    lurek.log.info("draw height=" .. tostring(height))
end

--@api: LHeatmapChart:getWidth
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    lurek.log.info("width=" .. tostring(chart:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getWidth width=" .. tostring(width))
    lurek.log.info("getWidth height=" .. tostring(height))
end

--@api: LHeatmapChart:getHeight
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    lurek.log.info("height=" .. tostring(chart:getHeight()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getHeight width=" .. tostring(width))
    lurek.log.info("getHeight height=" .. tostring(height))
end

--@api: LHeatmapChart:type
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    lurek.log.info("type=" .. tostring(chart:type()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("type width=" .. tostring(width))
    lurek.log.info("type height=" .. tostring(height))
end

--@api: LHeatmapChart:typeOf
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    lurek.log.info("typeOf exact=" .. tostring(chart:typeOf("LHeatmapChart")))
    lurek.log.info("typeOf object=" .. tostring(chart:typeOf("LObject")))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("typeOf width=" .. tostring(width))
    lurek.log.info("typeOf height=" .. tostring(height))
end

--@api: LHistogramChart:addSeries
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    chart:addSeries("latency", { 10, 12, 18, 24, 30 })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("addSeries width=" .. tostring(width))
    lurek.log.info("addSeries height=" .. tostring(height))
end

--@api: LHistogramChart:addSeriesFromDataFrame
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    local df = lurek.dataframe.fromTable({
        { month = 1, label = "Jan", north = 12, south = 8, east = 5, value = 12, x = 1, y = 12, row = "North", col = "Q1" },
        { month = 2, label = "Feb", north = 18, south = 11, east = 7, value = 18, x = 2, y = 18, row = "North", col = "Q2" },
        { month = 3, label = "Mar", north = 15, south = 14, east = 9, value = 15, x = 3, y = 15, row = "South", col = "Q1" },
    })
    local added = chart:addSeriesFromDataFrame("north", df, "north")
    lurek.log.info("rows added=" .. tostring(added))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("addSeriesFromDataFrame width=" .. tostring(width))
    lurek.log.info("addSeriesFromDataFrame height=" .. tostring(height))
end

--@api: LHistogramChart:replaceSeries
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    chart:replaceSeries("latency", { 10, 12, 18, 24, 30 })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("replaceSeries width=" .. tostring(width))
    lurek.log.info("replaceSeries height=" .. tostring(height))
end

--@api: LHistogramChart:appendValue
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    chart:appendValue("latency", 28)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("appendValue width=" .. tostring(width))
    lurek.log.info("appendValue height=" .. tostring(height))
end

--@api: LHistogramChart:setWindow
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    chart:setWindow(2)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setWindow width=" .. tostring(width))
    lurek.log.info("setWindow height=" .. tostring(height))
end

--@api: LHistogramChart:clear
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    chart:clear()
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("clear width=" .. tostring(width))
    lurek.log.info("clear height=" .. tostring(height))
end

--@api: LHistogramChart:setBinCount
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    chart:setBinCount(8)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setBinCount width=" .. tostring(width))
    lurek.log.info("setBinCount height=" .. tostring(height))
end

--@api: LHistogramChart:setRange
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    chart:setRange(10, 30)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setRange width=" .. tostring(width))
    lurek.log.info("setRange height=" .. tostring(height))
end

--@api: LHistogramChart:clearRange
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    chart:setRange(10, 30)
    chart:clearRange()
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("clearRange width=" .. tostring(width))
    lurek.log.info("clearRange height=" .. tostring(height))
end

--@api: LHistogramChart:setDensity
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    chart:setDensity(true)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setDensity width=" .. tostring(width))
    lurek.log.info("setDensity height=" .. tostring(height))
end

--@api: LHistogramChart:setTitle
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    chart:setTitle("Histogram example")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setTitle width=" .. tostring(width))
    lurek.log.info("setTitle height=" .. tostring(height))
end

--@api: LHistogramChart:setXLabel
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    chart:setXLabel("Month")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setXLabel width=" .. tostring(width))
    lurek.log.info("setXLabel height=" .. tostring(height))
end

--@api: LHistogramChart:setYLabel
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    chart:setYLabel("Value")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setYLabel width=" .. tostring(width))
    lurek.log.info("setYLabel height=" .. tostring(height))
end

--@api: LHistogramChart:setXTickCount
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    chart:setXTickCount(4)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setXTickCount width=" .. tostring(width))
    lurek.log.info("setXTickCount height=" .. tostring(height))
end

--@api: LHistogramChart:setYTickCount
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    chart:setYTickCount(4)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setYTickCount width=" .. tostring(width))
    lurek.log.info("setYTickCount height=" .. tostring(height))
end

--@api: LHistogramChart:setShowLegend
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    chart:setShowLegend(true)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setShowLegend width=" .. tostring(width))
    lurek.log.info("setShowLegend height=" .. tostring(height))
end

--@api: LHistogramChart:render
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    local w, h, pixels = chart:render()
    lurek.log.info("render size=" .. tostring(w) .. "x" .. tostring(h))
    lurek.log.info("render bytes=" .. tostring(#pixels))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("render width=" .. tostring(width))
    lurek.log.info("render height=" .. tostring(height))
end

--@api: LHistogramChart:renderImage
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    local image = chart:renderImage()
    lurek.log.info("image width=" .. tostring(image:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("renderImage width=" .. tostring(width))
    lurek.log.info("renderImage height=" .. tostring(height))
end

--@api: LHistogramChart:drawToImage
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    local target = lurek.image.newImageData(160, 120)
    chart:drawToImage(target)
    lurek.log.info("target width=" .. tostring(target:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("drawToImage width=" .. tostring(width))
    lurek.log.info("drawToImage height=" .. tostring(height))
end

--@api: LHistogramChart:draw
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    chart:draw(12, 18, {})
    lurek.log.info("draw issued=true")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("draw width=" .. tostring(width))
    lurek.log.info("draw height=" .. tostring(height))
end

--@api: LHistogramChart:getWidth
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    lurek.log.info("width=" .. tostring(chart:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getWidth width=" .. tostring(width))
    lurek.log.info("getWidth height=" .. tostring(height))
end

--@api: LHistogramChart:getHeight
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    lurek.log.info("height=" .. tostring(chart:getHeight()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getHeight width=" .. tostring(width))
    lurek.log.info("getHeight height=" .. tostring(height))
end

--@api: LHistogramChart:type
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    lurek.log.info("type=" .. tostring(chart:type()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("type width=" .. tostring(width))
    lurek.log.info("type height=" .. tostring(height))
end

--@api: LHistogramChart:typeOf
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    lurek.log.info("typeOf exact=" .. tostring(chart:typeOf("LHistogramChart")))
    lurek.log.info("typeOf object=" .. tostring(chart:typeOf("LObject")))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("typeOf width=" .. tostring(width))
    lurek.log.info("typeOf height=" .. tostring(height))
end

--@api: LLineChart:addSeriesFromDataFrame
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local df = lurek.dataframe.fromTable({
        { month = 1, label = "Jan", north = 12, south = 8, east = 5, value = 12, x = 1, y = 12, row = "North", col = "Q1" },
        { month = 2, label = "Feb", north = 18, south = 11, east = 7, value = 18, x = 2, y = 18, row = "North", col = "Q2" },
        { month = 3, label = "Mar", north = 15, south = 14, east = 9, value = 15, x = 3, y = 15, row = "South", col = "Q1" },
    })
    local added = chart:addSeriesFromDataFrame("north", df, "x", "y")
    lurek.log.info("rows added=" .. tostring(added))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("addSeriesFromDataFrame width=" .. tostring(width))
    lurek.log.info("addSeriesFromDataFrame height=" .. tostring(height))
end

--@api: LLineChart:replaceSeries
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:replaceSeries("north", { { 1, 9 }, { 2, 14 }, { 3, 11 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("replaceSeries width=" .. tostring(width))
    lurek.log.info("replaceSeries height=" .. tostring(height))
end

--@api: LLineChart:appendPoint
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:appendPoint("north", 4, 17)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("appendPoint width=" .. tostring(width))
    lurek.log.info("appendPoint height=" .. tostring(height))
end

--@api: LLineChart:setWindow
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setWindow(2)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setWindow width=" .. tostring(width))
    lurek.log.info("setWindow height=" .. tostring(height))
end

--@api: LLineChart:setYMax
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setYMax(30)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setYMax width=" .. tostring(width))
    lurek.log.info("setYMax height=" .. tostring(height))
end

--@api: LLineChart:setXMax
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setXMax(5)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setXMax width=" .. tostring(width))
    lurek.log.info("setXMax height=" .. tostring(height))
end

--@api: LLineChart:setXLabel
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setXLabel("Month")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setXLabel width=" .. tostring(width))
    lurek.log.info("setXLabel height=" .. tostring(height))
end

--@api: LLineChart:setYLabel
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setYLabel("Value")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setYLabel width=" .. tostring(width))
    lurek.log.info("setYLabel height=" .. tostring(height))
end

--@api: LLineChart:setXTickCount
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setXTickCount(4)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setXTickCount width=" .. tostring(width))
    lurek.log.info("setXTickCount height=" .. tostring(height))
end

--@api: LLineChart:setYTickCount
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setYTickCount(4)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setYTickCount width=" .. tostring(width))
    lurek.log.info("setYTickCount height=" .. tostring(height))
end

--@api: LLineChart:setShowLegend
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setShowLegend(true)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setShowLegend width=" .. tostring(width))
    lurek.log.info("setShowLegend height=" .. tostring(height))
end

--@api: LLineChart:renderImage
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local image = chart:renderImage()
    lurek.log.info("image width=" .. tostring(image:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("renderImage width=" .. tostring(width))
    lurek.log.info("renderImage height=" .. tostring(height))
end

--@api: LLineChart:drawToImage
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local target = lurek.image.newImageData(160, 120)
    chart:drawToImage(target)
    lurek.log.info("target width=" .. tostring(target:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("drawToImage width=" .. tostring(width))
    lurek.log.info("drawToImage height=" .. tostring(height))
end

--@api: LLineChart:draw
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:draw(12, 18, {})
    lurek.log.info("draw issued=true")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("draw width=" .. tostring(width))
    lurek.log.info("draw height=" .. tostring(height))
end

--@api: LLineChart:nearest
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local hit = chart:nearest(80, 60)
    lurek.log.info("nearest=" .. tostring(hit ~= nil))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("nearest width=" .. tostring(width))
    lurek.log.info("nearest height=" .. tostring(height))
end

--@api: LLineChart:type
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    lurek.log.info("type=" .. tostring(chart:type()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("type width=" .. tostring(width))
    lurek.log.info("type height=" .. tostring(height))
end

--@api: LLineChart:typeOf
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    lurek.log.info("typeOf exact=" .. tostring(chart:typeOf("LLineChart")))
    lurek.log.info("typeOf object=" .. tostring(chart:typeOf("LObject")))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("typeOf width=" .. tostring(width))
    lurek.log.info("typeOf height=" .. tostring(height))
end

--@api: LPieChart:addSegment
do
    local chart = lurek.charts.newPie({ width = 160, height = 120, title = "Pie" })
    chart:addSlice("North", 12)
    chart:addSlice("South", 8)
    chart:addSegment("East", 6)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("addSegment width=" .. tostring(width))
    lurek.log.info("addSegment height=" .. tostring(height))
end

--@api: LPieChart:addSegmentsFromDataFrame
do
    local chart = lurek.charts.newPie({ width = 160, height = 120, title = "Pie" })
    chart:addSlice("North", 12)
    chart:addSlice("South", 8)
    local df = lurek.dataframe.fromTable({
        { month = 1, label = "Jan", north = 12, south = 8, east = 5, value = 12, x = 1, y = 12, row = "North", col = "Q1" },
        { month = 2, label = "Feb", north = 18, south = 11, east = 7, value = 18, x = 2, y = 18, row = "North", col = "Q2" },
        { month = 3, label = "Mar", north = 15, south = 14, east = 9, value = 15, x = 3, y = 15, row = "South", col = "Q1" },
    })
    local added = chart:addSegmentsFromDataFrame(df, "label", "value")
    lurek.log.info("segments added=" .. tostring(added))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("addSegmentsFromDataFrame width=" .. tostring(width))
    lurek.log.info("addSegmentsFromDataFrame height=" .. tostring(height))
end

--@api: LPieChart:setShowLegend
do
    local chart = lurek.charts.newPie({ width = 160, height = 120, title = "Pie" })
    chart:addSlice("North", 12)
    chart:addSlice("South", 8)
    chart:setShowLegend(true)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setShowLegend width=" .. tostring(width))
    lurek.log.info("setShowLegend height=" .. tostring(height))
end

--@api: LPieChart:renderImage
do
    local chart = lurek.charts.newPie({ width = 160, height = 120, title = "Pie" })
    chart:addSlice("North", 12)
    chart:addSlice("South", 8)
    local image = chart:renderImage()
    lurek.log.info("image width=" .. tostring(image:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("renderImage width=" .. tostring(width))
    lurek.log.info("renderImage height=" .. tostring(height))
end

--@api: LPieChart:drawToImage
do
    local chart = lurek.charts.newPie({ width = 160, height = 120, title = "Pie" })
    chart:addSlice("North", 12)
    chart:addSlice("South", 8)
    local target = lurek.image.newImageData(160, 120)
    chart:drawToImage(target)
    lurek.log.info("target width=" .. tostring(target:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("drawToImage width=" .. tostring(width))
    lurek.log.info("drawToImage height=" .. tostring(height))
end

--@api: LPieChart:draw
do
    local chart = lurek.charts.newPie({ width = 160, height = 120, title = "Pie" })
    chart:addSlice("North", 12)
    chart:addSlice("South", 8)
    chart:draw(12, 18, {})
    lurek.log.info("draw issued=true")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("draw width=" .. tostring(width))
    lurek.log.info("draw height=" .. tostring(height))
end

--@api: LPieChart:type
do
    local chart = lurek.charts.newPie({ width = 160, height = 120, title = "Pie" })
    chart:addSlice("North", 12)
    chart:addSlice("South", 8)
    lurek.log.info("type=" .. tostring(chart:type()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("type width=" .. tostring(width))
    lurek.log.info("type height=" .. tostring(height))
end

--@api: LPieChart:typeOf
do
    local chart = lurek.charts.newPie({ width = 160, height = 120, title = "Pie" })
    chart:addSlice("North", 12)
    chart:addSlice("South", 8)
    lurek.log.info("typeOf exact=" .. tostring(chart:typeOf("LPieChart")))
    lurek.log.info("typeOf object=" .. tostring(chart:typeOf("LObject")))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("typeOf width=" .. tostring(width))
    lurek.log.info("typeOf height=" .. tostring(height))
end

--@api: LScatterPlot:addSeriesFromDataFrame
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local df = lurek.dataframe.fromTable({
        { month = 1, label = "Jan", north = 12, south = 8, east = 5, value = 12, x = 1, y = 12, row = "North", col = "Q1" },
        { month = 2, label = "Feb", north = 18, south = 11, east = 7, value = 18, x = 2, y = 18, row = "North", col = "Q2" },
        { month = 3, label = "Mar", north = 15, south = 14, east = 9, value = 15, x = 3, y = 15, row = "South", col = "Q1" },
    })
    local added = chart:addSeriesFromDataFrame("north", df, "x", "y")
    lurek.log.info("rows added=" .. tostring(added))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("addSeriesFromDataFrame width=" .. tostring(width))
    lurek.log.info("addSeriesFromDataFrame height=" .. tostring(height))
end

--@api: LScatterPlot:replaceSeries
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:replaceSeries("north", { { 1, 9 }, { 2, 14 }, { 3, 11 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("replaceSeries width=" .. tostring(width))
    lurek.log.info("replaceSeries height=" .. tostring(height))
end

--@api: LScatterPlot:appendPoint
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:appendPoint("north", 4, 17)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("appendPoint width=" .. tostring(width))
    lurek.log.info("appendPoint height=" .. tostring(height))
end

--@api: LScatterPlot:setWindow
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setWindow(2)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setWindow width=" .. tostring(width))
    lurek.log.info("setWindow height=" .. tostring(height))
end

--@api: LScatterPlot:setXRange
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setXRange(0, 6)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setXRange width=" .. tostring(width))
    lurek.log.info("setXRange height=" .. tostring(height))
end

--@api: LScatterPlot:setYRange
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setYRange(0, 30)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setYRange width=" .. tostring(width))
    lurek.log.info("setYRange height=" .. tostring(height))
end

--@api: LScatterPlot:setXLabel
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setXLabel("Month")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setXLabel width=" .. tostring(width))
    lurek.log.info("setXLabel height=" .. tostring(height))
end

--@api: LScatterPlot:setYLabel
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setYLabel("Value")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setYLabel width=" .. tostring(width))
    lurek.log.info("setYLabel height=" .. tostring(height))
end

--@api: LScatterPlot:setXTickCount
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setXTickCount(4)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setXTickCount width=" .. tostring(width))
    lurek.log.info("setXTickCount height=" .. tostring(height))
end

--@api: LScatterPlot:setYTickCount
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setYTickCount(4)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setYTickCount width=" .. tostring(width))
    lurek.log.info("setYTickCount height=" .. tostring(height))
end

--@api: LScatterPlot:setShowLegend
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setShowLegend(true)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setShowLegend width=" .. tostring(width))
    lurek.log.info("setShowLegend height=" .. tostring(height))
end

--@api: LScatterPlot:renderImage
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local image = chart:renderImage()
    lurek.log.info("image width=" .. tostring(image:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("renderImage width=" .. tostring(width))
    lurek.log.info("renderImage height=" .. tostring(height))
end

--@api: LScatterPlot:drawToImage
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local target = lurek.image.newImageData(160, 120)
    chart:drawToImage(target)
    lurek.log.info("target width=" .. tostring(target:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("drawToImage width=" .. tostring(width))
    lurek.log.info("drawToImage height=" .. tostring(height))
end

--@api: LScatterPlot:draw
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:draw(12, 18, {})
    lurek.log.info("draw issued=true")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("draw width=" .. tostring(width))
    lurek.log.info("draw height=" .. tostring(height))
end

--@api: LScatterPlot:nearest
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local hit = chart:nearest(80, 60)
    lurek.log.info("nearest=" .. tostring(hit ~= nil))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("nearest width=" .. tostring(width))
    lurek.log.info("nearest height=" .. tostring(height))
end

--@api: LScatterPlot:type
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    lurek.log.info("type=" .. tostring(chart:type()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("type width=" .. tostring(width))
    lurek.log.info("type height=" .. tostring(height))
end

--@api: LScatterPlot:typeOf
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    lurek.log.info("typeOf exact=" .. tostring(chart:typeOf("LScatterPlot")))
    lurek.log.info("typeOf object=" .. tostring(chart:typeOf("LObject")))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("typeOf width=" .. tostring(width))
    lurek.log.info("typeOf height=" .. tostring(height))
end

--@api: lurek.charts.newCandlestick
do
    local chart = lurek.charts.newCandlestick({ width = 160, height = 120, title = "Candlestick" })
    chart:appendCandle("Mon", 10, 14, 9, 13)
    chart:appendCandle("Tue", 13, 16, 12, 15)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("candlestick width=" .. tostring(width))
    lurek.log.info("candlestick height=" .. tostring(height))
end

--@api: LCandlestickChart:setCandles
do
    local chart = lurek.charts.newCandlestick({ width = 160, height = 120, title = "Candlestick" })
    chart:appendCandle("Mon", 10, 14, 9, 13)
    chart:appendCandle("Tue", 13, 16, 12, 15)
    chart:setCandles({
        { label = "Mon", open = 10, high = 14, low = 9, close = 13 },
        { label = "Tue", open = 13, high = 16, low = 12, close = 15 },
    })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setCandles width=" .. tostring(width))
    lurek.log.info("setCandles height=" .. tostring(height))
end

--@api: LCandlestickChart:appendCandle
do
    local chart = lurek.charts.newCandlestick({ width = 160, height = 120, title = "Candlestick" })
    chart:appendCandle("Mon", 10, 14, 9, 13)
    chart:appendCandle("Tue", 13, 16, 12, 15)
    chart:appendCandle("Wed", 15, 18, 14, 17)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("appendCandle width=" .. tostring(width))
    lurek.log.info("appendCandle height=" .. tostring(height))
end

--@api: LCandlestickChart:setColors
do
    local chart = lurek.charts.newCandlestick({ width = 160, height = 120, title = "Candlestick" })
    chart:appendCandle("Mon", 10, 14, 9, 13)
    chart:appendCandle("Tue", 13, 16, 12, 15)
    chart:setColors({ 0.1, 0.8, 0.2, 1.0 }, { 0.9, 0.1, 0.1, 1.0 })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setColors width=" .. tostring(width))
    lurek.log.info("setColors height=" .. tostring(height))
end

--@api: lurek.charts.newBoxPlot
do
    local chart = lurek.charts.newBoxPlot({ width = 160, height = 120, title = "BoxPlot" })
    chart:addSeries("latency", { 10, 12, 14, 20, 24, 40 })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("boxplot width=" .. tostring(width))
    lurek.log.info("boxplot height=" .. tostring(height))
end

--@api: LBoxPlotChart:addSeries
do
    local chart = lurek.charts.newBoxPlot({ width = 160, height = 120, title = "BoxPlot" })
    chart:addSeries("latency", { 10, 12, 14, 20, 24, 40 })
    chart:addSeries("latency", { 10, 12, 18, 24, 30 })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("addSeries width=" .. tostring(width))
    lurek.log.info("addSeries height=" .. tostring(height))
end

--@api: LBoxPlotChart:appendValue
do
    local chart = lurek.charts.newBoxPlot({ width = 160, height = 120, title = "BoxPlot" })
    chart:addSeries("latency", { 10, 12, 14, 20, 24, 40 })
    chart:appendValue("latency", 28)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("appendValue width=" .. tostring(width))
    lurek.log.info("appendValue height=" .. tostring(height))
end

--@api: lurek.charts.newBubble
do
    local chart = lurek.charts.newBubble({ width = 160, height = 120, title = "Bubble" })
    chart:addSeries("cities", { { 1, 2, 10 }, { 2, 3, 20 }, { 3, 2, 12 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("bubble width=" .. tostring(width))
    lurek.log.info("bubble height=" .. tostring(height))
end

--@api: LBubbleChart:addSeries
do
    local chart = lurek.charts.newBubble({ width = 160, height = 120, title = "Bubble" })
    chart:addSeries("cities", { { 1, 2, 10 }, { 2, 3, 20 }, { 3, 2, 12 } })
    chart:addSeries("cities", { { 1, 2, 8 }, { 2, 3, 16 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("addSeries width=" .. tostring(width))
    lurek.log.info("addSeries height=" .. tostring(height))
end

--@api: LBubbleChart:appendPoint
do
    local chart = lurek.charts.newBubble({ width = 160, height = 120, title = "Bubble" })
    chart:addSeries("cities", { { 1, 2, 10 }, { 2, 3, 20 }, { 3, 2, 12 } })
    chart:appendPoint("cities", 2, 3, 20)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("appendPoint width=" .. tostring(width))
    lurek.log.info("appendPoint height=" .. tostring(height))
end

--@api: LBubbleChart:setRadiusRange
do
    local chart = lurek.charts.newBubble({ width = 160, height = 120, title = "Bubble" })
    chart:addSeries("cities", { { 1, 2, 10 }, { 2, 3, 20 }, { 3, 2, 12 } })
    chart:setRadiusRange(3, 18)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setRadiusRange width=" .. tostring(width))
    lurek.log.info("setRadiusRange height=" .. tostring(height))
end

--@api: lurek.charts.newRadar
do
    local chart = lurek.charts.newRadar({ width = 160, height = 120, title = "Radar" })
    chart:setAxes({ "speed", "power", "range", "cost" })
    chart:addSeries("Scout", { 5, 2, 4, 3 })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("radar width=" .. tostring(width))
    lurek.log.info("radar height=" .. tostring(height))
end

--@api: LRadarChart:setAxes
do
    local chart = lurek.charts.newRadar({ width = 160, height = 120, title = "Radar" })
    chart:setAxes({ "speed", "power", "range", "cost" })
    chart:addSeries("Scout", { 5, 2, 4, 3 })
    chart:setAxes({ "speed", "power", "range", "cost" })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setAxes width=" .. tostring(width))
    lurek.log.info("setAxes height=" .. tostring(height))
end

--@api: LRadarChart:addSeries
do
    local chart = lurek.charts.newRadar({ width = 160, height = 120, title = "Radar" })
    chart:setAxes({ "speed", "power", "range", "cost" })
    chart:addSeries("Scout", { 5, 2, 4, 3 })
    chart:addSeries("Scout", { 5, 2, 4, 3 })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("addSeries width=" .. tostring(width))
    lurek.log.info("addSeries height=" .. tostring(height))
end

--@api: LRadarChart:setMaxValue
do
    local chart = lurek.charts.newRadar({ width = 160, height = 120, title = "Radar" })
    chart:setAxes({ "speed", "power", "range", "cost" })
    chart:addSeries("Scout", { 5, 2, 4, 3 })
    chart:setMaxValue(10)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setMaxValue width=" .. tostring(width))
    lurek.log.info("setMaxValue height=" .. tostring(height))
end

--@api: LRadarChart:clearMaxValue
do
    local chart = lurek.charts.newRadar({ width = 160, height = 120, title = "Radar" })
    chart:setAxes({ "speed", "power", "range", "cost" })
    chart:addSeries("Scout", { 5, 2, 4, 3 })
    chart:setMaxValue(10)
    chart:clearMaxValue()
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("clearMaxValue width=" .. tostring(width))
    lurek.log.info("clearMaxValue height=" .. tostring(height))
end

--@api: lurek.charts.newTreemap
do
    local chart = lurek.charts.newTreemap({ width = 160, height = 120, title = "Treemap" })
    chart:addItem("Rendering", 45)
    chart:addItem("Audio", 18)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("treemap width=" .. tostring(width))
    lurek.log.info("treemap height=" .. tostring(height))
end

--@api: LTreemapChart:setItems
do
    local chart = lurek.charts.newTreemap({ width = 160, height = 120, title = "Treemap" })
    chart:addItem("Rendering", 45)
    chart:addItem("Audio", 18)
    chart:setItems({
        { label = "Rendering", value = 45 },
        { label = "Audio", value = 18 },
        { label = "Input", value = 12 },
    })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setItems width=" .. tostring(width))
    lurek.log.info("setItems height=" .. tostring(height))
end

--@api: LTreemapChart:addItem
do
    local chart = lurek.charts.newTreemap({ width = 160, height = 120, title = "Treemap" })
    chart:addItem("Rendering", 45)
    chart:addItem("Audio", 18)
    chart:addItem("Input", 12)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("addItem width=" .. tostring(width))
    lurek.log.info("addItem height=" .. tostring(height))
end

--@api: LCandlestickChart:clear
do
    local chart = lurek.charts.newCandlestick({ width = 160, height = 120, title = "Candlestick" })
    chart:appendCandle("Mon", 10, 14, 9, 13)
    chart:appendCandle("Tue", 13, 16, 12, 15)
    chart:clear()
    chart:appendCandle("Mon", 10, 14, 9, 13)
    chart:appendCandle("Tue", 13, 16, 12, 15)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("clear width=" .. tostring(width))
    lurek.log.info("clear height=" .. tostring(height))
end

--@api: LCandlestickChart:setTitle
do
    local chart = lurek.charts.newCandlestick({ width = 160, height = 120, title = "Candlestick" })
    chart:appendCandle("Mon", 10, 14, 9, 13)
    chart:appendCandle("Tue", 13, 16, 12, 15)
    chart:setTitle("Candlestick example")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setTitle width=" .. tostring(width))
    lurek.log.info("setTitle height=" .. tostring(height))
end

--@api: LCandlestickChart:setShowLegend
do
    local chart = lurek.charts.newCandlestick({ width = 160, height = 120, title = "Candlestick" })
    chart:appendCandle("Mon", 10, 14, 9, 13)
    chart:appendCandle("Tue", 13, 16, 12, 15)
    chart:setShowLegend(true)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setShowLegend width=" .. tostring(width))
    lurek.log.info("setShowLegend height=" .. tostring(height))
end

--@api: LCandlestickChart:render
do
    local chart = lurek.charts.newCandlestick({ width = 160, height = 120, title = "Candlestick" })
    chart:appendCandle("Mon", 10, 14, 9, 13)
    chart:appendCandle("Tue", 13, 16, 12, 15)
    local w, h, pixels = chart:render()
    lurek.log.info("render size=" .. tostring(w) .. "x" .. tostring(h))
    lurek.log.info("render bytes=" .. tostring(#pixels))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("render width=" .. tostring(width))
    lurek.log.info("render height=" .. tostring(height))
end

--@api: LCandlestickChart:renderImage
do
    local chart = lurek.charts.newCandlestick({ width = 160, height = 120, title = "Candlestick" })
    chart:appendCandle("Mon", 10, 14, 9, 13)
    chart:appendCandle("Tue", 13, 16, 12, 15)
    local image = chart:renderImage()
    lurek.log.info("image width=" .. tostring(image:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("renderImage width=" .. tostring(width))
    lurek.log.info("renderImage height=" .. tostring(height))
end

--@api: LCandlestickChart:drawToImage
do
    local chart = lurek.charts.newCandlestick({ width = 160, height = 120, title = "Candlestick" })
    chart:appendCandle("Mon", 10, 14, 9, 13)
    chart:appendCandle("Tue", 13, 16, 12, 15)
    local target = lurek.image.newImageData(160, 120)
    chart:drawToImage(target)
    lurek.log.info("target width=" .. tostring(target:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("drawToImage width=" .. tostring(width))
    lurek.log.info("drawToImage height=" .. tostring(height))
end

--@api: LCandlestickChart:draw
do
    local chart = lurek.charts.newCandlestick({ width = 160, height = 120, title = "Candlestick" })
    chart:appendCandle("Mon", 10, 14, 9, 13)
    chart:appendCandle("Tue", 13, 16, 12, 15)
    chart:draw(12, 18, {})
    lurek.log.info("draw issued=true")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("draw width=" .. tostring(width))
    lurek.log.info("draw height=" .. tostring(height))
end

--@api: LCandlestickChart:getWidth
do
    local chart = lurek.charts.newCandlestick({ width = 160, height = 120, title = "Candlestick" })
    chart:appendCandle("Mon", 10, 14, 9, 13)
    chart:appendCandle("Tue", 13, 16, 12, 15)
    lurek.log.info("width=" .. tostring(chart:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getWidth width=" .. tostring(width))
    lurek.log.info("getWidth height=" .. tostring(height))
end

--@api: LCandlestickChart:getHeight
do
    local chart = lurek.charts.newCandlestick({ width = 160, height = 120, title = "Candlestick" })
    chart:appendCandle("Mon", 10, 14, 9, 13)
    chart:appendCandle("Tue", 13, 16, 12, 15)
    lurek.log.info("height=" .. tostring(chart:getHeight()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getHeight width=" .. tostring(width))
    lurek.log.info("getHeight height=" .. tostring(height))
end

--@api: LCandlestickChart:type
do
    local chart = lurek.charts.newCandlestick({ width = 160, height = 120, title = "Candlestick" })
    chart:appendCandle("Mon", 10, 14, 9, 13)
    chart:appendCandle("Tue", 13, 16, 12, 15)
    lurek.log.info("type=" .. tostring(chart:type()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("type width=" .. tostring(width))
    lurek.log.info("type height=" .. tostring(height))
end

--@api: LCandlestickChart:typeOf
do
    local chart = lurek.charts.newCandlestick({ width = 160, height = 120, title = "Candlestick" })
    chart:appendCandle("Mon", 10, 14, 9, 13)
    chart:appendCandle("Tue", 13, 16, 12, 15)
    lurek.log.info("typeOf exact=" .. tostring(chart:typeOf("LCandlestickChart")))
    lurek.log.info("typeOf object=" .. tostring(chart:typeOf("LObject")))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("typeOf width=" .. tostring(width))
    lurek.log.info("typeOf height=" .. tostring(height))
end

--@api: LBoxPlotChart:clear
do
    local chart = lurek.charts.newBoxPlot({ width = 160, height = 120, title = "BoxPlot" })
    chart:addSeries("latency", { 10, 12, 14, 20, 24, 40 })
    chart:clear()
    chart:addSeries("latency", { 10, 12, 14, 20, 24, 40 })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("clear width=" .. tostring(width))
    lurek.log.info("clear height=" .. tostring(height))
end

--@api: LBoxPlotChart:setTitle
do
    local chart = lurek.charts.newBoxPlot({ width = 160, height = 120, title = "BoxPlot" })
    chart:addSeries("latency", { 10, 12, 14, 20, 24, 40 })
    chart:setTitle("BoxPlot example")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setTitle width=" .. tostring(width))
    lurek.log.info("setTitle height=" .. tostring(height))
end

--@api: LBoxPlotChart:setShowLegend
do
    local chart = lurek.charts.newBoxPlot({ width = 160, height = 120, title = "BoxPlot" })
    chart:addSeries("latency", { 10, 12, 14, 20, 24, 40 })
    chart:setShowLegend(true)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setShowLegend width=" .. tostring(width))
    lurek.log.info("setShowLegend height=" .. tostring(height))
end

--@api: LBoxPlotChart:render
do
    local chart = lurek.charts.newBoxPlot({ width = 160, height = 120, title = "BoxPlot" })
    chart:addSeries("latency", { 10, 12, 14, 20, 24, 40 })
    local w, h, pixels = chart:render()
    lurek.log.info("render size=" .. tostring(w) .. "x" .. tostring(h))
    lurek.log.info("render bytes=" .. tostring(#pixels))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("render width=" .. tostring(width))
    lurek.log.info("render height=" .. tostring(height))
end

--@api: LBoxPlotChart:renderImage
do
    local chart = lurek.charts.newBoxPlot({ width = 160, height = 120, title = "BoxPlot" })
    chart:addSeries("latency", { 10, 12, 14, 20, 24, 40 })
    local image = chart:renderImage()
    lurek.log.info("image width=" .. tostring(image:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("renderImage width=" .. tostring(width))
    lurek.log.info("renderImage height=" .. tostring(height))
end

--@api: LBoxPlotChart:drawToImage
do
    local chart = lurek.charts.newBoxPlot({ width = 160, height = 120, title = "BoxPlot" })
    chart:addSeries("latency", { 10, 12, 14, 20, 24, 40 })
    local target = lurek.image.newImageData(160, 120)
    chart:drawToImage(target)
    lurek.log.info("target width=" .. tostring(target:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("drawToImage width=" .. tostring(width))
    lurek.log.info("drawToImage height=" .. tostring(height))
end

--@api: LBoxPlotChart:draw
do
    local chart = lurek.charts.newBoxPlot({ width = 160, height = 120, title = "BoxPlot" })
    chart:addSeries("latency", { 10, 12, 14, 20, 24, 40 })
    chart:draw(12, 18, {})
    lurek.log.info("draw issued=true")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("draw width=" .. tostring(width))
    lurek.log.info("draw height=" .. tostring(height))
end

--@api: LBoxPlotChart:getWidth
do
    local chart = lurek.charts.newBoxPlot({ width = 160, height = 120, title = "BoxPlot" })
    chart:addSeries("latency", { 10, 12, 14, 20, 24, 40 })
    lurek.log.info("width=" .. tostring(chart:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getWidth width=" .. tostring(width))
    lurek.log.info("getWidth height=" .. tostring(height))
end

--@api: LBoxPlotChart:getHeight
do
    local chart = lurek.charts.newBoxPlot({ width = 160, height = 120, title = "BoxPlot" })
    chart:addSeries("latency", { 10, 12, 14, 20, 24, 40 })
    lurek.log.info("height=" .. tostring(chart:getHeight()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getHeight width=" .. tostring(width))
    lurek.log.info("getHeight height=" .. tostring(height))
end

--@api: LBoxPlotChart:type
do
    local chart = lurek.charts.newBoxPlot({ width = 160, height = 120, title = "BoxPlot" })
    chart:addSeries("latency", { 10, 12, 14, 20, 24, 40 })
    lurek.log.info("type=" .. tostring(chart:type()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("type width=" .. tostring(width))
    lurek.log.info("type height=" .. tostring(height))
end

--@api: LBoxPlotChart:typeOf
do
    local chart = lurek.charts.newBoxPlot({ width = 160, height = 120, title = "BoxPlot" })
    chart:addSeries("latency", { 10, 12, 14, 20, 24, 40 })
    lurek.log.info("typeOf exact=" .. tostring(chart:typeOf("LBoxPlotChart")))
    lurek.log.info("typeOf object=" .. tostring(chart:typeOf("LObject")))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("typeOf width=" .. tostring(width))
    lurek.log.info("typeOf height=" .. tostring(height))
end

--@api: LBubbleChart:clear
do
    local chart = lurek.charts.newBubble({ width = 160, height = 120, title = "Bubble" })
    chart:addSeries("cities", { { 1, 2, 10 }, { 2, 3, 20 }, { 3, 2, 12 } })
    chart:clear()
    chart:addSeries("cities", { { 1, 2, 10 }, { 2, 3, 20 }, { 3, 2, 12 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("clear width=" .. tostring(width))
    lurek.log.info("clear height=" .. tostring(height))
end

--@api: LBubbleChart:setTitle
do
    local chart = lurek.charts.newBubble({ width = 160, height = 120, title = "Bubble" })
    chart:addSeries("cities", { { 1, 2, 10 }, { 2, 3, 20 }, { 3, 2, 12 } })
    chart:setTitle("Bubble example")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setTitle width=" .. tostring(width))
    lurek.log.info("setTitle height=" .. tostring(height))
end

--@api: LBubbleChart:setShowLegend
do
    local chart = lurek.charts.newBubble({ width = 160, height = 120, title = "Bubble" })
    chart:addSeries("cities", { { 1, 2, 10 }, { 2, 3, 20 }, { 3, 2, 12 } })
    chart:setShowLegend(true)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setShowLegend width=" .. tostring(width))
    lurek.log.info("setShowLegend height=" .. tostring(height))
end

--@api: LBubbleChart:render
do
    local chart = lurek.charts.newBubble({ width = 160, height = 120, title = "Bubble" })
    chart:addSeries("cities", { { 1, 2, 10 }, { 2, 3, 20 }, { 3, 2, 12 } })
    local w, h, pixels = chart:render()
    lurek.log.info("render size=" .. tostring(w) .. "x" .. tostring(h))
    lurek.log.info("render bytes=" .. tostring(#pixels))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("render width=" .. tostring(width))
    lurek.log.info("render height=" .. tostring(height))
end

--@api: LBubbleChart:renderImage
do
    local chart = lurek.charts.newBubble({ width = 160, height = 120, title = "Bubble" })
    chart:addSeries("cities", { { 1, 2, 10 }, { 2, 3, 20 }, { 3, 2, 12 } })
    local image = chart:renderImage()
    lurek.log.info("image width=" .. tostring(image:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("renderImage width=" .. tostring(width))
    lurek.log.info("renderImage height=" .. tostring(height))
end

--@api: LBubbleChart:drawToImage
do
    local chart = lurek.charts.newBubble({ width = 160, height = 120, title = "Bubble" })
    chart:addSeries("cities", { { 1, 2, 10 }, { 2, 3, 20 }, { 3, 2, 12 } })
    local target = lurek.image.newImageData(160, 120)
    chart:drawToImage(target)
    lurek.log.info("target width=" .. tostring(target:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("drawToImage width=" .. tostring(width))
    lurek.log.info("drawToImage height=" .. tostring(height))
end

--@api: LBubbleChart:draw
do
    local chart = lurek.charts.newBubble({ width = 160, height = 120, title = "Bubble" })
    chart:addSeries("cities", { { 1, 2, 10 }, { 2, 3, 20 }, { 3, 2, 12 } })
    chart:draw(12, 18, {})
    lurek.log.info("draw issued=true")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("draw width=" .. tostring(width))
    lurek.log.info("draw height=" .. tostring(height))
end

--@api: LBubbleChart:getWidth
do
    local chart = lurek.charts.newBubble({ width = 160, height = 120, title = "Bubble" })
    chart:addSeries("cities", { { 1, 2, 10 }, { 2, 3, 20 }, { 3, 2, 12 } })
    lurek.log.info("width=" .. tostring(chart:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getWidth width=" .. tostring(width))
    lurek.log.info("getWidth height=" .. tostring(height))
end

--@api: LBubbleChart:getHeight
do
    local chart = lurek.charts.newBubble({ width = 160, height = 120, title = "Bubble" })
    chart:addSeries("cities", { { 1, 2, 10 }, { 2, 3, 20 }, { 3, 2, 12 } })
    lurek.log.info("height=" .. tostring(chart:getHeight()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getHeight width=" .. tostring(width))
    lurek.log.info("getHeight height=" .. tostring(height))
end

--@api: LBubbleChart:type
do
    local chart = lurek.charts.newBubble({ width = 160, height = 120, title = "Bubble" })
    chart:addSeries("cities", { { 1, 2, 10 }, { 2, 3, 20 }, { 3, 2, 12 } })
    lurek.log.info("type=" .. tostring(chart:type()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("type width=" .. tostring(width))
    lurek.log.info("type height=" .. tostring(height))
end

--@api: LBubbleChart:typeOf
do
    local chart = lurek.charts.newBubble({ width = 160, height = 120, title = "Bubble" })
    chart:addSeries("cities", { { 1, 2, 10 }, { 2, 3, 20 }, { 3, 2, 12 } })
    lurek.log.info("typeOf exact=" .. tostring(chart:typeOf("LBubbleChart")))
    lurek.log.info("typeOf object=" .. tostring(chart:typeOf("LObject")))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("typeOf width=" .. tostring(width))
    lurek.log.info("typeOf height=" .. tostring(height))
end

--@api: LRadarChart:clear
do
    local chart = lurek.charts.newRadar({ width = 160, height = 120, title = "Radar" })
    chart:setAxes({ "speed", "power", "range", "cost" })
    chart:addSeries("Scout", { 5, 2, 4, 3 })
    chart:clear()
    chart:setAxes({ "speed", "power", "range", "cost" })
    chart:addSeries("Scout", { 5, 2, 4, 3 })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("clear width=" .. tostring(width))
    lurek.log.info("clear height=" .. tostring(height))
end

--@api: LRadarChart:setTitle
do
    local chart = lurek.charts.newRadar({ width = 160, height = 120, title = "Radar" })
    chart:setAxes({ "speed", "power", "range", "cost" })
    chart:addSeries("Scout", { 5, 2, 4, 3 })
    chart:setTitle("Radar example")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setTitle width=" .. tostring(width))
    lurek.log.info("setTitle height=" .. tostring(height))
end

--@api: LRadarChart:setShowLegend
do
    local chart = lurek.charts.newRadar({ width = 160, height = 120, title = "Radar" })
    chart:setAxes({ "speed", "power", "range", "cost" })
    chart:addSeries("Scout", { 5, 2, 4, 3 })
    chart:setShowLegend(true)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setShowLegend width=" .. tostring(width))
    lurek.log.info("setShowLegend height=" .. tostring(height))
end

--@api: LRadarChart:render
do
    local chart = lurek.charts.newRadar({ width = 160, height = 120, title = "Radar" })
    chart:setAxes({ "speed", "power", "range", "cost" })
    chart:addSeries("Scout", { 5, 2, 4, 3 })
    local w, h, pixels = chart:render()
    lurek.log.info("render size=" .. tostring(w) .. "x" .. tostring(h))
    lurek.log.info("render bytes=" .. tostring(#pixels))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("render width=" .. tostring(width))
    lurek.log.info("render height=" .. tostring(height))
end

--@api: LRadarChart:renderImage
do
    local chart = lurek.charts.newRadar({ width = 160, height = 120, title = "Radar" })
    chart:setAxes({ "speed", "power", "range", "cost" })
    chart:addSeries("Scout", { 5, 2, 4, 3 })
    local image = chart:renderImage()
    lurek.log.info("image width=" .. tostring(image:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("renderImage width=" .. tostring(width))
    lurek.log.info("renderImage height=" .. tostring(height))
end

--@api: LRadarChart:drawToImage
do
    local chart = lurek.charts.newRadar({ width = 160, height = 120, title = "Radar" })
    chart:setAxes({ "speed", "power", "range", "cost" })
    chart:addSeries("Scout", { 5, 2, 4, 3 })
    local target = lurek.image.newImageData(160, 120)
    chart:drawToImage(target)
    lurek.log.info("target width=" .. tostring(target:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("drawToImage width=" .. tostring(width))
    lurek.log.info("drawToImage height=" .. tostring(height))
end

--@api: LRadarChart:draw
do
    local chart = lurek.charts.newRadar({ width = 160, height = 120, title = "Radar" })
    chart:setAxes({ "speed", "power", "range", "cost" })
    chart:addSeries("Scout", { 5, 2, 4, 3 })
    chart:draw(12, 18, {})
    lurek.log.info("draw issued=true")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("draw width=" .. tostring(width))
    lurek.log.info("draw height=" .. tostring(height))
end

--@api: LRadarChart:getWidth
do
    local chart = lurek.charts.newRadar({ width = 160, height = 120, title = "Radar" })
    chart:setAxes({ "speed", "power", "range", "cost" })
    chart:addSeries("Scout", { 5, 2, 4, 3 })
    lurek.log.info("width=" .. tostring(chart:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getWidth width=" .. tostring(width))
    lurek.log.info("getWidth height=" .. tostring(height))
end

--@api: LRadarChart:getHeight
do
    local chart = lurek.charts.newRadar({ width = 160, height = 120, title = "Radar" })
    chart:setAxes({ "speed", "power", "range", "cost" })
    chart:addSeries("Scout", { 5, 2, 4, 3 })
    lurek.log.info("height=" .. tostring(chart:getHeight()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getHeight width=" .. tostring(width))
    lurek.log.info("getHeight height=" .. tostring(height))
end

--@api: LRadarChart:type
do
    local chart = lurek.charts.newRadar({ width = 160, height = 120, title = "Radar" })
    chart:setAxes({ "speed", "power", "range", "cost" })
    chart:addSeries("Scout", { 5, 2, 4, 3 })
    lurek.log.info("type=" .. tostring(chart:type()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("type width=" .. tostring(width))
    lurek.log.info("type height=" .. tostring(height))
end

--@api: LRadarChart:typeOf
do
    local chart = lurek.charts.newRadar({ width = 160, height = 120, title = "Radar" })
    chart:setAxes({ "speed", "power", "range", "cost" })
    chart:addSeries("Scout", { 5, 2, 4, 3 })
    lurek.log.info("typeOf exact=" .. tostring(chart:typeOf("LRadarChart")))
    lurek.log.info("typeOf object=" .. tostring(chart:typeOf("LObject")))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("typeOf width=" .. tostring(width))
    lurek.log.info("typeOf height=" .. tostring(height))
end

--@api: LTreemapChart:clear
do
    local chart = lurek.charts.newTreemap({ width = 160, height = 120, title = "Treemap" })
    chart:addItem("Rendering", 45)
    chart:addItem("Audio", 18)
    chart:clear()
    chart:addItem("Rendering", 45)
    chart:addItem("Audio", 18)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("clear width=" .. tostring(width))
    lurek.log.info("clear height=" .. tostring(height))
end

--@api: LTreemapChart:setTitle
do
    local chart = lurek.charts.newTreemap({ width = 160, height = 120, title = "Treemap" })
    chart:addItem("Rendering", 45)
    chart:addItem("Audio", 18)
    chart:setTitle("Treemap example")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setTitle width=" .. tostring(width))
    lurek.log.info("setTitle height=" .. tostring(height))
end

--@api: LTreemapChart:setShowLegend
do
    local chart = lurek.charts.newTreemap({ width = 160, height = 120, title = "Treemap" })
    chart:addItem("Rendering", 45)
    chart:addItem("Audio", 18)
    chart:setShowLegend(true)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setShowLegend width=" .. tostring(width))
    lurek.log.info("setShowLegend height=" .. tostring(height))
end

--@api: LTreemapChart:render
do
    local chart = lurek.charts.newTreemap({ width = 160, height = 120, title = "Treemap" })
    chart:addItem("Rendering", 45)
    chart:addItem("Audio", 18)
    local w, h, pixels = chart:render()
    lurek.log.info("render size=" .. tostring(w) .. "x" .. tostring(h))
    lurek.log.info("render bytes=" .. tostring(#pixels))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("render width=" .. tostring(width))
    lurek.log.info("render height=" .. tostring(height))
end

--@api: LTreemapChart:renderImage
do
    local chart = lurek.charts.newTreemap({ width = 160, height = 120, title = "Treemap" })
    chart:addItem("Rendering", 45)
    chart:addItem("Audio", 18)
    local image = chart:renderImage()
    lurek.log.info("image width=" .. tostring(image:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("renderImage width=" .. tostring(width))
    lurek.log.info("renderImage height=" .. tostring(height))
end

--@api: LTreemapChart:drawToImage
do
    local chart = lurek.charts.newTreemap({ width = 160, height = 120, title = "Treemap" })
    chart:addItem("Rendering", 45)
    chart:addItem("Audio", 18)
    local target = lurek.image.newImageData(160, 120)
    chart:drawToImage(target)
    lurek.log.info("target width=" .. tostring(target:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("drawToImage width=" .. tostring(width))
    lurek.log.info("drawToImage height=" .. tostring(height))
end

--@api: LTreemapChart:draw
do
    local chart = lurek.charts.newTreemap({ width = 160, height = 120, title = "Treemap" })
    chart:addItem("Rendering", 45)
    chart:addItem("Audio", 18)
    chart:draw(12, 18, {})
    lurek.log.info("draw issued=true")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("draw width=" .. tostring(width))
    lurek.log.info("draw height=" .. tostring(height))
end

--@api: LTreemapChart:getWidth
do
    local chart = lurek.charts.newTreemap({ width = 160, height = 120, title = "Treemap" })
    chart:addItem("Rendering", 45)
    chart:addItem("Audio", 18)
    lurek.log.info("width=" .. tostring(chart:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getWidth width=" .. tostring(width))
    lurek.log.info("getWidth height=" .. tostring(height))
end

--@api: LTreemapChart:getHeight
do
    local chart = lurek.charts.newTreemap({ width = 160, height = 120, title = "Treemap" })
    chart:addItem("Rendering", 45)
    chart:addItem("Audio", 18)
    lurek.log.info("height=" .. tostring(chart:getHeight()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getHeight width=" .. tostring(width))
    lurek.log.info("getHeight height=" .. tostring(height))
end

--@api: LTreemapChart:type
do
    local chart = lurek.charts.newTreemap({ width = 160, height = 120, title = "Treemap" })
    chart:addItem("Rendering", 45)
    chart:addItem("Audio", 18)
    lurek.log.info("type=" .. tostring(chart:type()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("type width=" .. tostring(width))
    lurek.log.info("type height=" .. tostring(height))
end

--@api: LTreemapChart:typeOf
do
    local chart = lurek.charts.newTreemap({ width = 160, height = 120, title = "Treemap" })
    chart:addItem("Rendering", 45)
    chart:addItem("Audio", 18)
    lurek.log.info("typeOf exact=" .. tostring(chart:typeOf("LTreemapChart")))
    lurek.log.info("typeOf object=" .. tostring(chart:typeOf("LObject")))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("typeOf width=" .. tostring(width))
    lurek.log.info("typeOf height=" .. tostring(height))
end
