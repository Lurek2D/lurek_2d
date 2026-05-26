-- content/examples/charts.lua
-- Run: cargo run -- content/examples/charts.lua

--- Charts Examples: line, bar, scatter, pie, area charts with configuration and rendering

--@api-stub: lurek.charts.newLine
do
    local chart = lurek.charts.newLine({ width = 400, height = 300, title = "Monthly Sales" })
    print("line chart created = " .. tostring(chart ~= nil))
    print("line chart width = " .. tostring(chart:getWidth()))
end

--@api-stub: lurek.charts.newBar
do
    local chart = lurek.charts.newBar({ width = 400, height = 300, title = "Revenue by Category" })
    print("bar chart created = " .. tostring(chart ~= nil))
    print("bar chart height = " .. tostring(chart:getHeight()))
end

--@api-stub: lurek.charts.newScatter
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300, title = "Test Scores" })
    print("scatter plot created = " .. tostring(chart ~= nil))
    print("scatter width = " .. tostring(chart:getWidth()))
end

--@api-stub: lurek.charts.newPie
do
    local chart = lurek.charts.newPie({ width = 300, height = 300, title = "Market Share" })
    print("pie chart created = " .. tostring(chart ~= nil))
    print("pie height = " .. tostring(chart:getHeight()))
end

--@api-stub: lurek.charts.newArea
do
    local chart = lurek.charts.newArea({ width = 400, height = 300, title = "Cumulative Users" })
    print("area chart created = " .. tostring(chart ~= nil))
    print("area chart width = " .. tostring(chart:getWidth()))
end

--@api-stub: lurek.charts.defaultPalette
do
    local pal = lurek.charts.defaultPalette()
    print("palette colors = " .. #pal)
    if #pal > 0 then
        print("first color r=" .. string.format("%.2f", pal[1][1]))
    end
end

--@api-stub: lurek.charts.seriesColor
do
    local c = lurek.charts.seriesColor(1)
    print("series 1 color r=" .. string.format("%.2f", c[1]) .. " g=" .. string.format("%.2f", c[2]) .. " b=" .. string.format("%.2f", c[3]))
    print("series 1 alpha=" .. string.format("%.2f", c[4]))
end

--@api-stub: LuaLineChart:addSeries
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    local sales = {{1, 100}, {2, 150}, {3, 130}, {4, 200}, {5, 180}, {6, 220}}
    chart:addSeries("Q1-Q2 Sales", sales)
    print("line series added")
    print("point count = " .. tostring(#sales))
end

--@api-stub: LuaLineChart:clear
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:addSeries("temp", {{1, 10}, {2, 20}})
    chart:clear()
    print("line chart cleared")
end

--@api-stub: LuaLineChart:setTitle
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:setTitle("Updated Title")
    print("line title set")
    print("chart width = " .. tostring(chart:getWidth()))
end

--@api-stub: LuaLineChart:render
do
    local chart = lurek.charts.newLine({ width = 200, height = 150 })
    chart:addSeries("data", {{1, 50}, {2, 80}, {3, 60}, {4, 90}})
    local w, h, pixels = chart:render()
    print("line render w=" .. w .. " h=" .. h .. " pixels=" .. #pixels .. " bytes")
end

--@api-stub: LuaLineChart:getWidth
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    print("line width = " .. chart:getWidth())
end

--@api-stub: LuaLineChart:getHeight
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    print("line height = " .. chart:getHeight())
end

--@api-stub: LuaBarChart:addSeries
do
    local chart = lurek.charts.newBar({ width = 400, height = 300, title = "Sales by Region" })
    local data = {{1, 50}, {2, 80}, {3, 30}, {4, 65}, {5, 45}}
    chart:addSeries("North", data)
    print("bar series added")
    print("bars = " .. tostring(#data))
end

--@api-stub: LuaBarChart:setBarWidth
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:setBarWidth(24)
    print("bar width set to 24")
    print("chart width = " .. tostring(chart:getWidth()))
end

--@api-stub: LuaBarChart:render
do
    local chart = lurek.charts.newBar({ width = 200, height = 150 })
    chart:addSeries("items", {{1, 40}, {2, 70}, {3, 55}})
    local w, h, pixels = chart:render()
    print("bar render w=" .. w .. " h=" .. h .. " pixels=" .. #pixels .. " bytes")
end

--@api-stub: LuaPieChart:addSlice
do
    local chart = lurek.charts.newPie({ width = 300, height = 300, title = "Browser Market Share" })
    chart:addSlice("Chrome", 65)
    chart:addSlice("Firefox", 12)
    chart:addSlice("Safari", 18)
    chart:addSlice("Other", 5)
    print("pie slices added = 4")
    print("chart size = " .. tostring(chart:getWidth()) .. "x" .. tostring(chart:getHeight()))
end

--@api-stub: LuaPieChart:render
do
    local chart = lurek.charts.newPie({ width = 200, height = 200 })
    chart:addSlice("A", 40)
    chart:addSlice("B", 35)
    chart:addSlice("C", 25)
    local w, h, pixels = chart:render()
    print("pie render w=" .. w .. " h=" .. h .. " pixels=" .. #pixels .. " bytes")
end

--@api-stub: LuaScatterPlot:addSeries
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300, title = "Height vs Weight" })
    local points = {{160, 55}, {170, 68}, {175, 72}, {180, 80}, {165, 60}, {185, 88}, {172, 65}}
    chart:addSeries("Measurements", points)
    print("scatter series added with " .. #points .. " points")
end

--@api-stub: LuaScatterPlot:setDotRadius
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:setDotRadius(4)
    print("dot radius set to 4")
    print("chart height = " .. tostring(chart:getHeight()))
end

--@api-stub: LuaAreaChart:addSeries
do
    local chart = lurek.charts.newArea({ width = 400, height = 300, title = "Monthly Active Users" })
    local mobile = {{1, 200}, {2, 280}, {3, 350}, {4, 420}, {5, 500}, {6, 580}}
    local desktop = {{1, 400}, {2, 380}, {3, 360}, {4, 340}, {5, 320}, {6, 310}}
    chart:addSeries("Mobile", mobile)
    chart:addSeries("Desktop", desktop)
    print("area series added = 2")
    print("mobile points = " .. tostring(#mobile))
end

--@api-stub: LuaAreaChart:render
do
    local chart = lurek.charts.newArea({ width = 200, height = 150 })
    chart:addSeries("growth", {{1, 10}, {2, 30}, {3, 60}, {4, 100}})
    local w, h, pixels = chart:render()
    print("area render w=" .. w .. " h=" .. h .. " pixels=" .. #pixels .. " bytes")
end

--@api-stub: LAreaChart:addSeries
do
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    chart:addSeries("series1", { {1, 1}, {2, 3}, {3, 2}, {4, 5}, {5, 4} })
    print("LAreaChart:addSeries ok")
    print("width = " .. tostring(chart:getWidth()))
end

--@api-stub: LAreaChart:clear
do
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 1}, {2, 2}, {3, 3} })
    chart:clear()
    local w, h, pixels = chart:render()
    print("LAreaChart:clear ok")
    print("render bytes = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end

--@api-stub: LAreaChart:setTitle
do
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    chart:setTitle("Monthly Sales")
    print("LAreaChart:setTitle ok")
    print("height = " .. tostring(chart:getHeight()))
end

--@api-stub: LAreaChart:render
do
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 5}, {2, 3}, {3, 8}, {4, 2}, {5, 6} })
    local w, h, pixels = chart:render()
    print("LAreaChart:render ok")
    print("pixels = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end

--@api-stub: LAreaChart:getWidth
do
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    print("LAreaChart:getWidth=" .. chart:getWidth())
    print("LAreaChart:getHeight=" .. chart:getHeight())
end

--@api-stub: LAreaChart:getHeight
do
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    print("LAreaChart:getHeight=" .. chart:getHeight())
    print("LAreaChart:getWidth=" .. chart:getWidth())
end

--@api-stub: LBarChart:addSeries
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:addSeries("series1", { {1, 1}, {2, 3}, {3, 2}, {4, 5}, {5, 4} })
    print("LBarChart:addSeries ok")
    print("height = " .. tostring(chart:getHeight()))
end

--@api-stub: LBarChart:clear
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 1}, {2, 2}, {3, 3} })
    chart:clear()
    local w, h, pixels = chart:render()
    print("LBarChart:clear ok")
    print("render bytes = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end

--@api-stub: LBarChart:setBarWidth
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:setBarWidth(20.0)
    print("LBarChart:setBarWidth ok")
    print("chart width = " .. tostring(chart:getWidth()))
end

--@api-stub: LBarChart:setTitle
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:setTitle("Monthly Sales")
    print("LBarChart:setTitle ok")
    print("chart height = " .. tostring(chart:getHeight()))
end

--@api-stub: LBarChart:render
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 5}, {2, 3}, {3, 8}, {4, 2}, {5, 6} })
    local w, h, pixels = chart:render()
    print("LBarChart:render ok")
    print("pixels = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end

--@api-stub: LBarChart:getWidth
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    print("LBarChart:getWidth=" .. chart:getWidth())
    print("LBarChart:getHeight=" .. chart:getHeight())
end

--@api-stub: LBarChart:getHeight
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    print("LBarChart:getHeight=" .. chart:getHeight())
    print("LBarChart:getWidth=" .. chart:getWidth())
end

--@api-stub: LLineChart:addSeries
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:addSeries("series1", { {1, 1}, {2, 3}, {3, 2}, {4, 5}, {5, 4} })
    print("LLineChart:addSeries ok")
    print("width = " .. tostring(chart:getWidth()))
end

--@api-stub: LLineChart:clear
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 1}, {2, 2}, {3, 3} })
    chart:clear()
    local w, h, pixels = chart:render()
    print("LLineChart:clear ok")
    print("render bytes = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end

--@api-stub: LLineChart:setTitle
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:setTitle("Monthly Sales")
    print("LLineChart:setTitle ok")
    print("height = " .. tostring(chart:getHeight()))
end

--@api-stub: LLineChart:render
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 5}, {2, 3}, {3, 8}, {4, 2}, {5, 6} })
    local w, h, pixels = chart:render()
    print("LLineChart:render ok")
    print("pixels = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end

--@api-stub: LLineChart:getWidth
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    print("LLineChart:getWidth=" .. chart:getWidth())
    print("LLineChart:getHeight=" .. chart:getHeight())
end

--@api-stub: LLineChart:getHeight
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    print("LLineChart:getHeight=" .. chart:getHeight())
    print("LLineChart:getWidth=" .. chart:getWidth())
end

--@api-stub: LPieChart:addSlice
do
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    chart:addSlice("Food", 45.0, { 0.9, 0.3, 0.1, 1.0 })
    chart:addSlice("Transport", 20.0, { 0.2, 0.6, 0.9, 1.0 })
    print("LPieChart:addSlice ok")
    print("width = " .. tostring(chart:getWidth()))
end

--@api-stub: LPieChart:clear
do
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    chart:addSlice("A", 1)
    chart:addSlice("B", 2)
    chart:clear()
    local w, h, pixels = chart:render()
    print("LPieChart:clear ok")
    print("render bytes = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end

--@api-stub: LPieChart:setTitle
do
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    chart:setTitle("Monthly Sales")
    print("LPieChart:setTitle ok")
    print("height = " .. tostring(chart:getHeight()))
end

--@api-stub: LPieChart:render
do
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    chart:addSlice("A", 5)
    chart:addSlice("B", 3)
    chart:addSlice("C", 8)
    local w, h, pixels = chart:render()
    print("LPieChart:render ok")
    print("pixels = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end

--@api-stub: LPieChart:getWidth
do
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    print("LPieChart:getWidth=" .. chart:getWidth())
    print("LPieChart:getHeight=" .. chart:getHeight())
end

--@api-stub: LPieChart:getHeight
do
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    print("LPieChart:getHeight=" .. chart:getHeight())
    print("LPieChart:getWidth=" .. chart:getWidth())
end

--@api-stub: LScatterPlot:addSeries
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:addSeries("series1", { {1, 1}, {2, 3}, {3, 2}, {4, 5}, {5, 4} })
    print("LScatterPlot:addSeries ok")
    print("width = " .. tostring(chart:getWidth()))
end

--@api-stub: LScatterPlot:clear
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 1}, {2, 2}, {3, 3} })
    chart:clear()
    local w, h, pixels = chart:render()
    print("LScatterPlot:clear ok")
    print("render bytes = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end

--@api-stub: LScatterPlot:setDotRadius
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:setDotRadius(5.0)
    print("LScatterPlot:setDotRadius ok")
    print("height = " .. tostring(chart:getHeight()))
end

--@api-stub: LScatterPlot:setTitle
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:setTitle("Monthly Sales")
    print("LScatterPlot:setTitle ok")
    print("width = " .. tostring(chart:getWidth()))
end

--@api-stub: LScatterPlot:render
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 5}, {2, 3}, {3, 8}, {4, 2}, {5, 6} })
    local w, h, pixels = chart:render()
    print("LScatterPlot:render ok")
    print("pixels = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end

--@api-stub: LScatterPlot:getWidth
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    print("LScatterPlot:getWidth=" .. chart:getWidth())
    print("LScatterPlot:getHeight=" .. chart:getHeight())
end

--@api-stub: LScatterPlot:getHeight
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    print("LScatterPlot:getHeight=" .. chart:getHeight())
    print("LScatterPlot:getWidth=" .. chart:getWidth())
end
