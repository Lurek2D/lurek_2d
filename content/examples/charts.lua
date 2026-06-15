-- content/examples/charts.lua
-- Run: cargo run -- content/examples/charts.lua

--- Charts Examples: line, bar, scatter, pie, area charts with configuration and rendering

--@api: lurek.charts.newLine
do
    local chart = lurek.charts.newLine({ width = 400, height = 300, title = "Monthly Sales" })
    print("line chart created = " .. tostring(chart ~= nil))
    print("line chart width = " .. tostring(chart:getWidth()))
end

--@api: lurek.charts.newBar
do
    local chart = lurek.charts.newBar({ width = 400, height = 300, title = "Revenue by Category" })
    print("bar chart created = " .. tostring(chart ~= nil))
    print("bar chart height = " .. tostring(chart:getHeight()))
end

--@api: lurek.charts.newScatter
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300, title = "Test Scores" })
    print("scatter plot created = " .. tostring(chart ~= nil))
    print("scatter width = " .. tostring(chart:getWidth()))
end

--@api: lurek.charts.newPie
do
    local chart = lurek.charts.newPie({ width = 300, height = 300, title = "Market Share" })
    print("pie chart created = " .. tostring(chart ~= nil))
    print("pie height = " .. tostring(chart:getHeight()))
end

--@api: lurek.charts.newArea
do
    local chart = lurek.charts.newArea({ width = 400, height = 300, title = "Cumulative Users" })
    print("area chart created = " .. tostring(chart ~= nil))
    print("area chart width = " .. tostring(chart:getWidth()))
end

--@api: lurek.charts.defaultPalette
do
    local pal = lurek.charts.defaultPalette()
    print("palette colors = " .. #pal)
    if #pal > 0 then
        print("first color r=" .. string.format("%.2f", pal[1][1]))
    end
end

--@api: lurek.charts.seriesColor
do
    local c = lurek.charts.seriesColor(1)
    print("series 1 color r=" .. string.format("%.2f", c[1]) .. " g=" .. string.format("%.2f", c[2]) .. " b=" .. string.format("%.2f", c[3]))
    print("series 1 alpha=" .. string.format("%.2f", c[4]))
end

--@api: LuaLineChart:addSeries
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    local sales = {{1, 100}, {2, 150}, {3, 130}, {4, 200}, {5, 180}, {6, 220}}
    chart:addSeries("Q1-Q2 Sales", sales)
    print("line series added")
    print("point count = " .. tostring(#sales))
end

--@api: LuaLineChart:clear
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:addSeries("temp", {{1, 10}, {2, 20}})
    chart:clear()
    print("line chart cleared")
end

--@api: LuaLineChart:setTitle
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:setTitle("Updated Title")
    print("line title set")
    print("chart width = " .. tostring(chart:getWidth()))
end

--@api: LuaLineChart:render
do
    local chart = lurek.charts.newLine({ width = 200, height = 150 })
    chart:addSeries("data", {{1, 50}, {2, 80}, {3, 60}, {4, 90}})
    local w, h, pixels = chart:render()
    print("line render w=" .. w .. " h=" .. h .. " pixels=" .. #pixels .. " bytes")
end

--@api: LuaLineChart:getWidth
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    print("line width = " .. chart:getWidth())
end

--@api: LuaLineChart:getHeight
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    print("line height = " .. chart:getHeight())
end

--@api: LuaBarChart:addSeries
do
    local chart = lurek.charts.newBar({ width = 400, height = 300, title = "Sales by Region" })
    local data = {{1, 50}, {2, 80}, {3, 30}, {4, 65}, {5, 45}}
    chart:addSeries("North", data)
    print("bar series added")
    print("bars = " .. tostring(#data))
end

--@api: LuaBarChart:setBarWidth
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:setBarWidth(24)
    print("bar width set to 24")
    print("chart width = " .. tostring(chart:getWidth()))
end

--@api: LuaBarChart:render
do
    local chart = lurek.charts.newBar({ width = 200, height = 150 })
    chart:addSeries("items", {{1, 40}, {2, 70}, {3, 55}})
    local w, h, pixels = chart:render()
    print("bar render w=" .. w .. " h=" .. h .. " pixels=" .. #pixels .. " bytes")
end

--@api: LuaPieChart:addSlice
do
    local chart = lurek.charts.newPie({ width = 300, height = 300, title = "Browser Market Share" })
    chart:addSlice("Chrome", 65)
    chart:addSlice("Firefox", 12)
    chart:addSlice("Safari", 18)
    chart:addSlice("Other", 5)
    print("pie slices added = 4")
    print("chart size = " .. tostring(chart:getWidth()) .. "x" .. tostring(chart:getHeight()))
end

--@api: LuaPieChart:render
do
    local chart = lurek.charts.newPie({ width = 200, height = 200 })
    chart:addSlice("A", 40)
    chart:addSlice("B", 35)
    chart:addSlice("C", 25)
    local w, h, pixels = chart:render()
    print("pie render w=" .. w .. " h=" .. h .. " pixels=" .. #pixels .. " bytes")
end

--@api: LuaScatterPlot:addSeries
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300, title = "Height vs Weight" })
    local points = {{160, 55}, {170, 68}, {175, 72}, {180, 80}, {165, 60}, {185, 88}, {172, 65}}
    chart:addSeries("Measurements", points)
    print("scatter series added with " .. #points .. " points")
end

--@api: LuaScatterPlot:setDotRadius
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:setDotRadius(4)
    print("dot radius set to 4")
    print("chart height = " .. tostring(chart:getHeight()))
end

--@api: LuaAreaChart:addSeries
do
    local chart = lurek.charts.newArea({ width = 400, height = 300, title = "Monthly Active Users" })
    local mobile = {{1, 200}, {2, 280}, {3, 350}, {4, 420}, {5, 500}, {6, 580}}
    local desktop = {{1, 400}, {2, 380}, {3, 360}, {4, 340}, {5, 320}, {6, 310}}
    chart:addSeries("Mobile", mobile)
    chart:addSeries("Desktop", desktop)
    print("area series added = 2")
    print("mobile points = " .. tostring(#mobile))
end

--@api: LuaAreaChart:render
do
    local chart = lurek.charts.newArea({ width = 200, height = 150 })
    chart:addSeries("growth", {{1, 10}, {2, 30}, {3, 60}, {4, 100}})
    local w, h, pixels = chart:render()
    print("area render w=" .. w .. " h=" .. h .. " pixels=" .. #pixels .. " bytes")
end

--@api: LAreaChart:addSeries
do
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    chart:addSeries("series1", { {1, 1}, {2, 3}, {3, 2}, {4, 5}, {5, 4} })
    print("LAreaChart:addSeries ok")
    print("width = " .. tostring(chart:getWidth()))
end

--@api: LAreaChart:clear
do
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 1}, {2, 2}, {3, 3} })
    chart:clear()
    local w, h, pixels = chart:render()
    print("LAreaChart:clear ok")
    print("render bytes = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end

--@api: LAreaChart:setTitle
do
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    chart:setTitle("Monthly Sales")
    print("LAreaChart:setTitle ok")
    print("height = " .. tostring(chart:getHeight()))
end

--@api: LAreaChart:render
do
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 5}, {2, 3}, {3, 8}, {4, 2}, {5, 6} })
    local w, h, pixels = chart:render()
    print("LAreaChart:render ok")
    print("pixels = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end

--@api: LAreaChart:getWidth
do
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    print("LAreaChart:getWidth=" .. chart:getWidth())
    print("LAreaChart:getHeight=" .. chart:getHeight())
end

--@api: LAreaChart:getHeight
do
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    print("LAreaChart:getHeight=" .. chart:getHeight())
    print("LAreaChart:getWidth=" .. chart:getWidth())
end

--@api: LBarChart:addSeries
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:addSeries("series1", { {1, 1}, {2, 3}, {3, 2}, {4, 5}, {5, 4} })
    print("LBarChart:addSeries ok")
    print("height = " .. tostring(chart:getHeight()))
end

--@api: LBarChart:clear
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 1}, {2, 2}, {3, 3} })
    chart:clear()
    local w, h, pixels = chart:render()
    print("LBarChart:clear ok")
    print("render bytes = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end

--@api: LBarChart:setBarWidth
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:setBarWidth(20.0)
    print("LBarChart:setBarWidth ok")
    print("chart width = " .. tostring(chart:getWidth()))
end

--@api: LBarChart:setTitle
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:setTitle("Monthly Sales")
    print("LBarChart:setTitle ok")
    print("chart height = " .. tostring(chart:getHeight()))
end

--@api: LBarChart:render
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 5}, {2, 3}, {3, 8}, {4, 2}, {5, 6} })
    local w, h, pixels = chart:render()
    print("LBarChart:render ok")
    print("pixels = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end

--@api: LBarChart:getWidth
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    print("LBarChart:getWidth=" .. chart:getWidth())
    print("LBarChart:getHeight=" .. chart:getHeight())
end

--@api: LBarChart:getHeight
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    print("LBarChart:getHeight=" .. chart:getHeight())
    print("LBarChart:getWidth=" .. chart:getWidth())
end

--@api: LLineChart:addSeries
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:addSeries("series1", { {1, 1}, {2, 3}, {3, 2}, {4, 5}, {5, 4} })
    print("LLineChart:addSeries ok")
    print("width = " .. tostring(chart:getWidth()))
end

--@api: LLineChart:clear
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 1}, {2, 2}, {3, 3} })
    chart:clear()
    local w, h, pixels = chart:render()
    print("LLineChart:clear ok")
    print("render bytes = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end

--@api: LLineChart:setTitle
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:setTitle("Monthly Sales")
    print("LLineChart:setTitle ok")
    print("height = " .. tostring(chart:getHeight()))
end

--@api: LLineChart:render
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 5}, {2, 3}, {3, 8}, {4, 2}, {5, 6} })
    local w, h, pixels = chart:render()
    print("LLineChart:render ok")
    print("pixels = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end

--@api: LLineChart:getWidth
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    print("LLineChart:getWidth=" .. chart:getWidth())
    print("LLineChart:getHeight=" .. chart:getHeight())
end

--@api: LLineChart:getHeight
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    print("LLineChart:getHeight=" .. chart:getHeight())
    print("LLineChart:getWidth=" .. chart:getWidth())
end

--@api: LPieChart:addSlice
do
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    chart:addSlice("Food", 45.0, { 0.9, 0.3, 0.1, 1.0 })
    chart:addSlice("Transport", 20.0, { 0.2, 0.6, 0.9, 1.0 })
    print("LPieChart:addSlice ok")
    print("width = " .. tostring(chart:getWidth()))
end

--@api: LPieChart:clear
do
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    chart:addSlice("A", 1)
    chart:addSlice("B", 2)
    chart:clear()
    local w, h, pixels = chart:render()
    print("LPieChart:clear ok")
    print("render bytes = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end

--@api: LPieChart:setTitle
do
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    chart:setTitle("Monthly Sales")
    print("LPieChart:setTitle ok")
    print("height = " .. tostring(chart:getHeight()))
end

--@api: LPieChart:render
do
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    chart:addSlice("A", 5)
    chart:addSlice("B", 3)
    chart:addSlice("C", 8)
    local w, h, pixels = chart:render()
    print("LPieChart:render ok")
    print("pixels = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end

--@api: LPieChart:getWidth
do
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    print("LPieChart:getWidth=" .. chart:getWidth())
    print("LPieChart:getHeight=" .. chart:getHeight())
end

--@api: LPieChart:getHeight
do
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    print("LPieChart:getHeight=" .. chart:getHeight())
    print("LPieChart:getWidth=" .. chart:getWidth())
end

--@api: LScatterPlot:addSeries
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:addSeries("series1", { {1, 1}, {2, 3}, {3, 2}, {4, 5}, {5, 4} })
    print("LScatterPlot:addSeries ok")
    print("width = " .. tostring(chart:getWidth()))
end

--@api: LScatterPlot:clear
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 1}, {2, 2}, {3, 3} })
    chart:clear()
    local w, h, pixels = chart:render()
    print("LScatterPlot:clear ok")
    print("render bytes = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end

--@api: LScatterPlot:setDotRadius
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:setDotRadius(5.0)
    print("LScatterPlot:setDotRadius ok")
    print("height = " .. tostring(chart:getHeight()))
end

--@api: LScatterPlot:setTitle
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:setTitle("Monthly Sales")
    print("LScatterPlot:setTitle ok")
    print("width = " .. tostring(chart:getWidth()))
end

--@api: LScatterPlot:render
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 5}, {2, 3}, {3, 8}, {4, 2}, {5, 6} })
    local w, h, pixels = chart:render()
    print("LScatterPlot:render ok")
    print("pixels = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end

--@api: LScatterPlot:getWidth
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    print("LScatterPlot:getWidth=" .. chart:getWidth())
    print("LScatterPlot:getHeight=" .. chart:getHeight())
end

--@api: LScatterPlot:getHeight
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    print("LScatterPlot:getHeight=" .. chart:getHeight())
    print("LScatterPlot:getWidth=" .. chart:getWidth())
end

local function charts_df()
    return lurek.dataframe.fromTable({
        { month = 1, label = "Jan", north = 12, south = 8, east = 5, value = 12, x = 1, y = 12, row = "North", col = "Q1" },
        { month = 2, label = "Feb", north = 18, south = 11, east = 7, value = 18, x = 2, y = 18, row = "North", col = "Q2" },
        { month = 3, label = "Mar", north = 15, south = 14, east = 9, value = 15, x = 3, y = 15, row = "South", col = "Q1" },
        { month = 4, label = "Apr", north = 24, south = 16, east = 12, value = 24, x = 4, y = 24, row = "South", col = "Q2" },
    })
end

local function chart_target_image(w, h)
    return lurek.image.newImageData(w, h)
end

--@api: lurek.charts.newHistogram
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180, title = "Response Times" })
    chart:addSeries("ms", { 14, 18, 22, 18, 15, 21, 29, 18 })
    print("histogram type = " .. chart:type())
    print("histogram width = " .. chart:getWidth())
end

--@api: lurek.charts.newHeatmap
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180, title = "Region Load" })
    chart:setMatrix({ { 2, 4 }, { 6, 8 } }, { "North", "South" }, { "Q1", "Q2" })
    print("heatmap type = " .. chart:type())
    print("heatmap height = " .. chart:getHeight())
end

--@api: LAreaChart:addLayer
do
    local chart = lurek.charts.newArea({ width = 320, height = 180, title = "Area Layers" })
    chart:addLayer("north", { 10, 14, 18, 20 })
    print("added layer north")
    print("width = " .. chart:getWidth())
end

--@api: LAreaChart:addLayerFromDataFrame
do
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    local df = charts_df()
    local added = chart:addLayerFromDataFrame("north", df, "north")
    print("rows added = " .. tostring(added))
    print("height = " .. chart:getHeight())
end

--@api: LAreaChart:appendPoint
do
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:addSeries("trend", { { 1, 12 }, { 2, 16 } })
    chart:appendPoint("trend", 3, 21)
    local _, _, pixels = chart:render()
    print("append point pixels = " .. #pixels)
end

--@api: LAreaChart:setWindow
do
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:addSeries("trend", { { 1, 8 }, { 2, 12 }, { 3, 15 }, { 4, 19 } })
    chart:setWindow(2)
    local _, _, pixels = chart:render()
    print("windowed render bytes = " .. #pixels)
end

--@api: LAreaChart:setYMax
do
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:addSeries("trend", { { 1, 8 }, { 2, 12 }, { 3, 15 } })
    chart:setYMax(20)
    print("manual y max applied")
    print("type = " .. chart:type())
end

--@api: LAreaChart:setXLabel
do
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:setXLabel("Month")
    chart:setYLabel("Users")
    local _, _, pixels = chart:render()
    print("labeled area bytes = " .. #pixels)
end

--@api: LAreaChart:setYLabel
do
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:setYLabel("Requests")
    chart:addLayer("api", { 3, 5, 8, 13 })
    local _, _, pixels = chart:render()
    print("area label bytes = " .. #pixels)
end

--@api: LAreaChart:setXTickCount
do
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:setXTickCount(5)
    chart:addLayer("api", { 3, 5, 8, 13 })
    local _, _, pixels = chart:render()
    print("x ticks bytes = " .. #pixels)
end

--@api: LAreaChart:setYTickCount
do
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:setYTickCount(6)
    chart:addLayer("api", { 3, 5, 8, 13 })
    local _, _, pixels = chart:render()
    print("y ticks bytes = " .. #pixels)
end

--@api: LAreaChart:setShowLegend
do
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:addLayer("north", { 5, 6, 7, 8 })
    chart:addLayer("south", { 4, 5, 5, 6 })
    chart:setShowLegend(true)
    local _, _, pixels = chart:render()
    print("legend bytes = " .. #pixels)
end

--@api: LAreaChart:renderImage
do
    local chart = lurek.charts.newArea({ width = 256, height = 128 })
    chart:addLayer("north", { 5, 6, 9, 12 })
    local img = chart:renderImage()
    print("render image type = " .. img:type())
    print("render image size = " .. img:getWidth() .. "x" .. img:getHeight())
end

--@api: LAreaChart:drawToImage
do
    local chart = lurek.charts.newArea({ width = 256, height = 128 })
    local target = chart_target_image(256, 128)
    chart:addLayer("north", { 5, 6, 9, 12 })
    chart:drawToImage(target)
    print("target size = " .. target:getWidth() .. "x" .. target:getHeight())
end

--@api: LAreaChart:draw
do
    local chart = lurek.charts.newArea({ width = 256, height = 128 })
    chart:addLayer("north", { 5, 6, 9, 12 })
    chart:draw(24, 16, {})
    print("draw call issued")
    print("area type = " .. chart:type())
end

--@api: LAreaChart:type
do
    local chart = lurek.charts.newArea({ width = 256, height = 128 })
    print("type = " .. chart:type())
    print("is object = " .. tostring(chart:typeOf("LObject")))
end

--@api: LAreaChart:typeOf
do
    local chart = lurek.charts.newArea({ width = 256, height = 128 })
    print("typeOf LAreaChart = " .. tostring(chart:typeOf("LAreaChart")))
    print("typeOf LBarChart = " .. tostring(chart:typeOf("LBarChart")))
end

--@api: LBarChart:addCategory
do
    local chart = lurek.charts.newBar({ width = 320, height = 180 })
    chart:addCategory("Q1", { 12, 8, 5 })
    chart:addCategory("Q2", { 18, 11, 7 })
    local _, _, pixels = chart:render()
    print("categories bytes = " .. #pixels)
end

--@api: LBarChart:addCategoriesFromDataFrame
do
    local chart = lurek.charts.newBar({ width = 320, height = 180 })
    local df = charts_df()
    local added = chart:addCategoriesFromDataFrame(df, "label", { "north", "south", "east" })
    print("categories added = " .. tostring(added))
    print("height = " .. chart:getHeight())
end

--@api: LBarChart:setXLabel
do
    local chart = lurek.charts.newBar({ width = 320, height = 180 })
    chart:setXLabel("Quarter")
    chart:addCategory("Q1", { 12, 8, 5 })
    local _, _, pixels = chart:render()
    print("bar x label bytes = " .. #pixels)
end

--@api: LBarChart:setYLabel
do
    local chart = lurek.charts.newBar({ width = 320, height = 180 })
    chart:setYLabel("Sales")
    chart:addCategory("Q1", { 12, 8, 5 })
    local _, _, pixels = chart:render()
    print("bar y label bytes = " .. #pixels)
end

--@api: LBarChart:setXTickCount
do
    local chart = lurek.charts.newBar({ width = 320, height = 180 })
    chart:setXTickCount(4)
    chart:addCategory("Q1", { 12, 8, 5 })
    chart:addCategory("Q2", { 18, 11, 7 })
    local _, _, pixels = chart:render()
    print("bar x ticks bytes = " .. #pixels)
end

--@api: LBarChart:setYTickCount
do
    local chart = lurek.charts.newBar({ width = 320, height = 180 })
    chart:setYTickCount(6)
    chart:addCategory("Q1", { 12, 8, 5 })
    chart:addCategory("Q2", { 18, 11, 7 })
    local _, _, pixels = chart:render()
    print("bar y ticks bytes = " .. #pixels)
end

--@api: LBarChart:setShowLegend
do
    local chart = lurek.charts.newBar({ width = 320, height = 180 })
    chart:addCategory("Q1", { 12, 8, 5 })
    chart:addCategory("Q2", { 18, 11, 7 })
    chart:setShowLegend(true)
    local _, _, pixels = chart:render()
    print("bar legend bytes = " .. #pixels)
end

--@api: LBarChart:renderImage
do
    local chart = lurek.charts.newBar({ width = 256, height = 128 })
    chart:addCategory("Q1", { 12, 8, 5 })
    local img = chart:renderImage()
    print("bar image type = " .. img:type())
    print("bar image size = " .. img:getWidth() .. "x" .. img:getHeight())
end

--@api: LBarChart:drawToImage
do
    local chart = lurek.charts.newBar({ width = 256, height = 128 })
    local target = chart_target_image(256, 128)
    chart:addCategory("Q1", { 12, 8, 5 })
    chart:drawToImage(target)
    print("bar target bytes = " .. target:getWidth() .. "x" .. target:getHeight())
end

--@api: LBarChart:draw
do
    local chart = lurek.charts.newBar({ width = 256, height = 128 })
    chart:addCategory("Q1", { 12, 8, 5 })
    chart:draw(12, 8, {})
    print("bar draw issued")
    print("bar type = " .. chart:type())
end

--@api: LBarChart:type
do
    local chart = lurek.charts.newBar({ width = 256, height = 128 })
    print("type = " .. chart:type())
    print("object = " .. tostring(chart:typeOf("LObject")))
end

--@api: LBarChart:typeOf
do
    local chart = lurek.charts.newBar({ width = 256, height = 128 })
    print("typeOf LBarChart = " .. tostring(chart:typeOf("LBarChart")))
    print("typeOf LAreaChart = " .. tostring(chart:typeOf("LAreaChart")))
end

--@api: LHeatmapChart:setMatrix
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    local _, _, pixels = chart:render()
    print("heatmap matrix bytes = " .. #pixels)
end

--@api: LHeatmapChart:setMatrixFromDataFrame
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    local df = charts_df()
    local cells = chart:setMatrixFromDataFrame(df, "row", "col", "value")
    print("matrix cells = " .. tostring(cells))
    print("width = " .. chart:getWidth())
end

--@api: LHeatmapChart:resize
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:resize(3, 2)
    chart:setCell(1, 1, 1.5)
    chart:setCell(3, 2, 4.5)
    local _, _, pixels = chart:render()
    print("resized heatmap bytes = " .. #pixels)
end

--@api: LHeatmapChart:setCell
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:resize(2, 2)
    chart:setCell(1, 1, 2.5)
    chart:setCell(2, 2, 7.5)
    local _, _, pixels = chart:render()
    print("heatmap cell bytes = " .. #pixels)
end

--@api: LHeatmapChart:clear
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    chart:clear()
    local _, _, pixels = chart:render()
    print("cleared heatmap bytes = " .. #pixels)
end

--@api: LHeatmapChart:setRowLabels
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:setRowLabels({ "North", "South" })
    local _, _, pixels = chart:render()
    print("row labels bytes = " .. #pixels)
end

--@api: LHeatmapChart:setColumnLabels
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:setColumnLabels({ "Q1", "Q2" })
    local _, _, pixels = chart:render()
    print("column labels bytes = " .. #pixels)
end

--@api: LHeatmapChart:setValueRange
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:setValueRange(0, 10)
    local _, _, pixels = chart:render()
    print("value range bytes = " .. #pixels)
end

--@api: LHeatmapChart:clearValueRange
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:setValueRange(0, 10)
    chart:clearValueRange()
    local _, _, pixels = chart:render()
    print("cleared range bytes = " .. #pixels)
end

--@api: LHeatmapChart:setColorRange
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:setColorRange({ 0.10, 0.20, 0.60, 1.0 }, { 0.90, 0.20, 0.10, 1.0 })
    local _, _, pixels = chart:render()
    print("color range bytes = " .. #pixels)
end

--@api: LHeatmapChart:setShowValues
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:setShowValues(true)
    local _, _, pixels = chart:render()
    print("show values bytes = " .. #pixels)
end

--@api: LHeatmapChart:setTitle
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setTitle("Throughput Grid")
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    local _, _, pixels = chart:render()
    print("heatmap title bytes = " .. #pixels)
end

--@api: LHeatmapChart:setShowLegend
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:setShowLegend(true)
    local _, _, pixels = chart:render()
    print("heatmap legend bytes = " .. #pixels)
end

--@api: LHeatmapChart:render
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    local w, h, pixels = chart:render()
    print("render size = " .. w .. "x" .. h)
    print("render bytes = " .. #pixels)
end

--@api: LHeatmapChart:renderImage
do
    local chart = lurek.charts.newHeatmap({ width = 256, height = 128 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    local img = chart:renderImage()
    print("heatmap image type = " .. img:type())
    print("heatmap image width = " .. img:getWidth())
end

--@api: LHeatmapChart:drawToImage
do
    local chart = lurek.charts.newHeatmap({ width = 256, height = 128 })
    local target = chart_target_image(256, 128)
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:drawToImage(target)
    print("heatmap target width = " .. target:getWidth())
end

--@api: LHeatmapChart:draw
do
    local chart = lurek.charts.newHeatmap({ width = 256, height = 128 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:draw(18, 10, {})
    print("heatmap draw issued")
    print("heatmap type = " .. chart:type())
end

--@api: LHeatmapChart:getWidth
do
    local chart = lurek.charts.newHeatmap({ width = 333, height = 144 })
    print("width = " .. chart:getWidth())
    print("height = " .. chart:getHeight())
end

--@api: LHeatmapChart:getHeight
do
    local chart = lurek.charts.newHeatmap({ width = 333, height = 144 })
    print("height = " .. chart:getHeight())
    print("width = " .. chart:getWidth())
end

--@api: LHeatmapChart:type
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    print("type = " .. chart:type())
    print("object = " .. tostring(chart:typeOf("LObject")))
end

--@api: LHeatmapChart:typeOf
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    print("typeOf LHeatmapChart = " .. tostring(chart:typeOf("LHeatmapChart")))
    print("typeOf LPieChart = " .. tostring(chart:typeOf("LPieChart")))
end

--@api: LHistogramChart:addSeries
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 18, 22, 25, 18 })
    local _, _, pixels = chart:render()
    print("histogram bytes = " .. #pixels)
end

--@api: LHistogramChart:addSeriesFromDataFrame
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    local df = charts_df()
    local added = chart:addSeriesFromDataFrame("north", df, "north")
    print("histogram rows added = " .. tostring(added))
    print("width = " .. chart:getWidth())
end

--@api: LHistogramChart:replaceSeries
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18 })
    chart:replaceSeries("response", { 30, 28, 26, 24 })
    local _, _, pixels = chart:render()
    print("replaced histogram bytes = " .. #pixels)
end

--@api: LHistogramChart:appendValue
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18 })
    chart:appendValue("response", 21)
    local _, _, pixels = chart:render()
    print("append histogram bytes = " .. #pixels)
end

--@api: LHistogramChart:setWindow
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    chart:setWindow(4)
    local _, _, pixels = chart:render()
    print("window histogram bytes = " .. #pixels)
end

--@api: LHistogramChart:clear
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18 })
    chart:clear()
    local _, _, pixels = chart:render()
    print("cleared histogram bytes = " .. #pixels)
end

--@api: LHistogramChart:setBinCount
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    chart:setBinCount(5)
    local _, _, pixels = chart:render()
    print("bins histogram bytes = " .. #pixels)
end

--@api: LHistogramChart:setRange
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    chart:setRange(10, 30)
    local _, _, pixels = chart:render()
    print("range histogram bytes = " .. #pixels)
end

--@api: LHistogramChart:clearRange
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    chart:setRange(10, 30)
    chart:clearRange()
    local _, _, pixels = chart:render()
    print("clear range histogram bytes = " .. #pixels)
end

--@api: LHistogramChart:setDensity
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    chart:setDensity(true)
    local _, _, pixels = chart:render()
    print("density histogram bytes = " .. #pixels)
end

--@api: LHistogramChart:setTitle
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:setTitle("Response Times")
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    local _, _, pixels = chart:render()
    print("histogram title bytes = " .. #pixels)
end

--@api: LHistogramChart:setXLabel
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:setXLabel("Latency")
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    local _, _, pixels = chart:render()
    print("histogram x label bytes = " .. #pixels)
end

--@api: LHistogramChart:setYLabel
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:setYLabel("Frequency")
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    local _, _, pixels = chart:render()
    print("histogram y label bytes = " .. #pixels)
end

--@api: LHistogramChart:setXTickCount
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:setXTickCount(5)
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    local _, _, pixels = chart:render()
    print("histogram x ticks bytes = " .. #pixels)
end

--@api: LHistogramChart:setYTickCount
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:setYTickCount(6)
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    local _, _, pixels = chart:render()
    print("histogram y ticks bytes = " .. #pixels)
end

--@api: LHistogramChart:setShowLegend
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("north", { 12, 14, 18, 21 })
    chart:addSeries("south", { 9, 10, 11, 15 })
    chart:setShowLegend(true)
    local _, _, pixels = chart:render()
    print("histogram legend bytes = " .. #pixels)
end

--@api: LHistogramChart:render
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    local w, h, pixels = chart:render()
    print("histogram size = " .. w .. "x" .. h)
    print("histogram bytes = " .. #pixels)
end

--@api: LHistogramChart:renderImage
do
    local chart = lurek.charts.newHistogram({ width = 256, height = 128 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    local img = chart:renderImage()
    print("histogram image type = " .. img:type())
    print("histogram image width = " .. img:getWidth())
end

--@api: LHistogramChart:drawToImage
do
    local chart = lurek.charts.newHistogram({ width = 256, height = 128 })
    local target = chart_target_image(256, 128)
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    chart:drawToImage(target)
    print("histogram target width = " .. target:getWidth())
end

--@api: LHistogramChart:draw
do
    local chart = lurek.charts.newHistogram({ width = 256, height = 128 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    chart:draw(16, 8, {})
    print("histogram draw issued")
    print("histogram type = " .. chart:type())
end

--@api: LHistogramChart:getWidth
do
    local chart = lurek.charts.newHistogram({ width = 345, height = 176 })
    print("width = " .. chart:getWidth())
    print("height = " .. chart:getHeight())
end

--@api: LHistogramChart:getHeight
do
    local chart = lurek.charts.newHistogram({ width = 345, height = 176 })
    print("height = " .. chart:getHeight())
    print("width = " .. chart:getWidth())
end

--@api: LHistogramChart:type
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    print("type = " .. chart:type())
    print("object = " .. tostring(chart:typeOf("LObject")))
end

--@api: LHistogramChart:typeOf
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    print("typeOf LHistogramChart = " .. tostring(chart:typeOf("LHistogramChart")))
    print("typeOf LLineChart = " .. tostring(chart:typeOf("LLineChart")))
end

--@api: LLineChart:addSeriesFromDataFrame
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    local df = charts_df()
    local added = chart:addSeriesFromDataFrame("north", df, "month", "north")
    print("line rows added = " .. tostring(added))
    print("width = " .. chart:getWidth())
end

--@api: LLineChart:replaceSeries
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 } })
    chart:replaceSeries("north", { { 1, 9 }, { 2, 11 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    print("line replace bytes = " .. #pixels)
end

--@api: LLineChart:appendPoint
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 } })
    chart:appendPoint("north", 3, 15)
    local _, _, pixels = chart:render()
    print("line append bytes = " .. #pixels)
end

--@api: LLineChart:setWindow
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 }, { 4, 24 } })
    chart:setWindow(2)
    local _, _, pixels = chart:render()
    print("line window bytes = " .. #pixels)
end

--@api: LLineChart:setYMax
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setYMax(30)
    local _, _, pixels = chart:render()
    print("line y max bytes = " .. #pixels)
end

--@api: LLineChart:setXMax
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setXMax(6)
    local _, _, pixels = chart:render()
    print("line x max bytes = " .. #pixels)
end

--@api: LLineChart:setXLabel
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:setXLabel("Month")
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    print("line x label bytes = " .. #pixels)
end

--@api: LLineChart:setYLabel
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:setYLabel("Users")
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    print("line y label bytes = " .. #pixels)
end

--@api: LLineChart:setXTickCount
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:setXTickCount(5)
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    print("line x ticks bytes = " .. #pixels)
end

--@api: LLineChart:setYTickCount
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:setYTickCount(6)
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    print("line y ticks bytes = " .. #pixels)
end

--@api: LLineChart:setShowLegend
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:addSeries("south", { { 1, 8 }, { 2, 11 }, { 3, 16 } })
    chart:setShowLegend(true)
    local _, _, pixels = chart:render()
    print("line legend bytes = " .. #pixels)
end

--@api: LLineChart:renderImage
do
    local chart = lurek.charts.newLine({ width = 256, height = 128 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local img = chart:renderImage()
    print("line image type = " .. img:type())
    print("line image width = " .. img:getWidth())
end

--@api: LLineChart:drawToImage
do
    local chart = lurek.charts.newLine({ width = 256, height = 128 })
    local target = chart_target_image(256, 128)
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:drawToImage(target)
    print("line target width = " .. target:getWidth())
end

--@api: LLineChart:draw
do
    local chart = lurek.charts.newLine({ width = 256, height = 128 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:draw(20, 12, {})
    print("line draw issued")
    print("line type = " .. chart:type())
end

--@api: LLineChart:nearest
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local hit = chart:nearest(120, 80)
    print("line nearest found = " .. tostring(hit ~= nil))
    print("line nearest series = " .. tostring(hit and hit.series))
end

--@api: LLineChart:type
do
    local chart = lurek.charts.newLine({ width = 256, height = 128 })
    print("type = " .. chart:type())
    print("object = " .. tostring(chart:typeOf("LObject")))
end

--@api: LLineChart:typeOf
do
    local chart = lurek.charts.newLine({ width = 256, height = 128 })
    print("typeOf LLineChart = " .. tostring(chart:typeOf("LLineChart")))
    print("typeOf LAreaChart = " .. tostring(chart:typeOf("LAreaChart")))
end

--@api: LPieChart:addSegment
do
    local chart = lurek.charts.newPie({ width = 320, height = 180 })
    chart:addSegment("North", 42, { 0.9, 0.3, 0.2, 1.0 })
    chart:addSegment("South", 33, { 0.2, 0.6, 0.9, 1.0 })
    local _, _, pixels = chart:render()
    print("pie segment bytes = " .. #pixels)
end

--@api: LPieChart:addSegmentsFromDataFrame
do
    local chart = lurek.charts.newPie({ width = 320, height = 180 })
    local df = lurek.dataframe.fromTable({
        { label = "North", value = 42 },
        { label = "South", value = 33 },
        { label = "East", value = 25 },
    })
    local added = chart:addSegmentsFromDataFrame(df, "label", "value")
    print("pie segments added = " .. tostring(added))
    print("pie height = " .. chart:getHeight())
end

--@api: LPieChart:setShowLegend
do
    local chart = lurek.charts.newPie({ width = 320, height = 180 })
    chart:addSegment("North", 42)
    chart:addSegment("South", 33)
    chart:setShowLegend(true)
    local _, _, pixels = chart:render()
    print("pie legend bytes = " .. #pixels)
end

--@api: LPieChart:renderImage
do
    local chart = lurek.charts.newPie({ width = 256, height = 128 })
    chart:addSegment("North", 42)
    chart:addSegment("South", 33)
    local img = chart:renderImage()
    print("pie image type = " .. img:type())
    print("pie image width = " .. img:getWidth())
end

--@api: LPieChart:drawToImage
do
    local chart = lurek.charts.newPie({ width = 256, height = 128 })
    local target = chart_target_image(256, 128)
    chart:addSegment("North", 42)
    chart:addSegment("South", 33)
    chart:drawToImage(target)
    print("pie target width = " .. target:getWidth())
end

--@api: LPieChart:draw
do
    local chart = lurek.charts.newPie({ width = 256, height = 128 })
    chart:addSegment("North", 42)
    chart:addSegment("South", 33)
    chart:draw(20, 10, {})
    print("pie draw issued")
    print("pie type = " .. chart:type())
end

--@api: LPieChart:type
do
    local chart = lurek.charts.newPie({ width = 256, height = 128 })
    print("type = " .. chart:type())
    print("object = " .. tostring(chart:typeOf("LObject")))
end

--@api: LPieChart:typeOf
do
    local chart = lurek.charts.newPie({ width = 256, height = 128 })
    print("typeOf LPieChart = " .. tostring(chart:typeOf("LPieChart")))
    print("typeOf LBarChart = " .. tostring(chart:typeOf("LBarChart")))
end

--@api: LScatterPlot:addSeriesFromDataFrame
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    local df = charts_df()
    local added = chart:addSeriesFromDataFrame("north", df, "x", "y")
    print("scatter rows added = " .. tostring(added))
    print("scatter width = " .. chart:getWidth())
end

--@api: LScatterPlot:replaceSeries
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 } })
    chart:replaceSeries("north", { { 1, 9 }, { 2, 11 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    print("scatter replace bytes = " .. #pixels)
end

--@api: LScatterPlot:appendPoint
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 } })
    chart:appendPoint("north", 3, 15)
    local _, _, pixels = chart:render()
    print("scatter append bytes = " .. #pixels)
end

--@api: LScatterPlot:setWindow
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 }, { 4, 24 } })
    chart:setWindow(3)
    local _, _, pixels = chart:render()
    print("scatter window bytes = " .. #pixels)
end

--@api: LScatterPlot:setXRange
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setXRange(0, 6)
    local _, _, pixels = chart:render()
    print("scatter x range bytes = " .. #pixels)
end

--@api: LScatterPlot:setYRange
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setYRange(0, 30)
    local _, _, pixels = chart:render()
    print("scatter y range bytes = " .. #pixels)
end

--@api: LScatterPlot:setXLabel
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:setXLabel("Hours")
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    print("scatter x label bytes = " .. #pixels)
end

--@api: LScatterPlot:setYLabel
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:setYLabel("Score")
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    print("scatter y label bytes = " .. #pixels)
end

--@api: LScatterPlot:setXTickCount
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:setXTickCount(5)
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    print("scatter x ticks bytes = " .. #pixels)
end

--@api: LScatterPlot:setYTickCount
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:setYTickCount(6)
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    print("scatter y ticks bytes = " .. #pixels)
end

--@api: LScatterPlot:setShowLegend
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:addSeries("south", { { 1, 8 }, { 2, 11 }, { 3, 16 } })
    chart:setShowLegend(true)
    local _, _, pixels = chart:render()
    print("scatter legend bytes = " .. #pixels)
end

--@api: LScatterPlot:renderImage
do
    local chart = lurek.charts.newScatter({ width = 256, height = 128 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local img = chart:renderImage()
    print("scatter image type = " .. img:type())
    print("scatter image width = " .. img:getWidth())
end

--@api: LScatterPlot:drawToImage
do
    local chart = lurek.charts.newScatter({ width = 256, height = 128 })
    local target = chart_target_image(256, 128)
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:drawToImage(target)
    print("scatter target width = " .. target:getWidth())
end

--@api: LScatterPlot:draw
do
    local chart = lurek.charts.newScatter({ width = 256, height = 128 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:draw(20, 10, {})
    print("scatter draw issued")
    print("scatter type = " .. chart:type())
end

--@api: LScatterPlot:nearest
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local hit = chart:nearest(120, 80)
    print("scatter nearest found = " .. tostring(hit ~= nil))
    print("scatter nearest series = " .. tostring(hit and hit.series))
end

--@api: LScatterPlot:type
do
    local chart = lurek.charts.newScatter({ width = 256, height = 128 })
    print("type = " .. chart:type())
    print("object = " .. tostring(chart:typeOf("LObject")))
end

--@api: LScatterPlot:typeOf
do
    local chart = lurek.charts.newScatter({ width = 256, height = 128 })
    print("typeOf LScatterPlot = " .. tostring(chart:typeOf("LScatterPlot")))
    print("typeOf LPieChart = " .. tostring(chart:typeOf("LPieChart")))
end
