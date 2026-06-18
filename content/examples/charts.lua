-- content/examples/charts.lua
-- Run: cargo run -- content/examples/charts.lua

--- Charts Examples: line, bar, scatter, pie, area charts with configuration and rendering

local function example_print_log(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring(select(i, ...))
    end
    lurek.log.info(table.concat(parts, " "))
end

--@api: lurek.charts.newLine
do
    local chart = lurek.charts.newLine({ width = 400, height = 300, title = "Monthly Sales" })
    chart:addSeries("North", {{1, 12}, {2, 18}, {3, 15}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("line chart created=" .. tostring(chart ~= nil))
    lurek.log.info("line chart size=" .. tostring(width) .. "x" .. tostring(height))
end

--@api: lurek.charts.newBar
do
    local chart = lurek.charts.newBar({ width = 400, height = 300, title = "Revenue by Category" })
    chart:addSeries("Weapons", {{1, 20}, {2, 14}, {3, 18}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("bar chart created=" .. tostring(chart ~= nil))
    lurek.log.info("bar chart size=" .. tostring(width) .. "x" .. tostring(height))
end

--@api: lurek.charts.newScatter
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300, title = "Test Scores" })
    chart:addSeries("Players", {{1, 12}, {2, 18}, {3, 14}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("scatter chart created=" .. tostring(chart ~= nil))
    lurek.log.info("scatter chart size=" .. tostring(width) .. "x" .. tostring(height))
end

--@api: lurek.charts.newPie
do
    local chart = lurek.charts.newPie({ width = 300, height = 300, title = "Market Share" })
    chart:addSlice("North", 42)
    chart:addSlice("South", 33)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("pie chart created=" .. tostring(chart ~= nil))
    lurek.log.info("pie chart size=" .. tostring(width) .. "x" .. tostring(height))
end

--@api: lurek.charts.newArea
do
    local chart = lurek.charts.newArea({ width = 400, height = 300, title = "Cumulative Users" })
    chart:addSeries("Users", {{1, 20}, {2, 32}, {3, 50}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("area chart created=" .. tostring(chart ~= nil))
    lurek.log.info("area chart size=" .. tostring(width) .. "x" .. tostring(height))
end

--@api: lurek.charts.defaultPalette
do
    local pal = lurek.charts.defaultPalette()
    example_print_log("palette colors = " .. #pal)
    if #pal > 0 then
        example_print_log("first color r=" .. string.format("%.2f", pal[1][1]))
    end
end

--@api: lurek.charts.seriesColor
do
    local c = lurek.charts.seriesColor(1)
    local c2 = lurek.charts.seriesColor(2)
    local firstColor = string.format("%.2f,%.2f,%.2f", c[1], c[2], c[3])
    local secondColor = string.format("%.2f,%.2f,%.2f", c2[1], c2[2], c2[3])
    lurek.log.info("series 1 color=" .. tostring(firstColor) .. " a=" .. string.format("%.2f", c[4]))
    lurek.log.info("series 2 color=" .. tostring(secondColor) .. " differs=" .. tostring(firstColor ~= secondColor))
end

--@api: LuaLineChart:addSeries
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    local sales = {{1, 100}, {2, 150}, {3, 130}, {4, 200}, {5, 180}, {6, 220}}
    chart:addSeries("Q1-Q2 Sales", sales)
    example_print_log("line series added")
    example_print_log("point count = " .. tostring(#sales))
end

--@api: LuaLineChart:clear
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:addSeries("temp", {{1, 10}, {2, 20}})
    chart:clear()
    local w, h, pixels = chart:render()
    lurek.log.info("line chart cleared")
    lurek.log.info("line chart render after clear=" .. tostring(w) .. "x" .. tostring(h) .. " bytes=" .. tostring(#pixels))
end

--@api: LuaLineChart:setTitle
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:setTitle("Updated Title")
    chart:addSeries("North", {{1, 12}, {2, 14}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("line title set for dashboard")
    lurek.log.info("line chart size=" .. tostring(width) .. "x" .. tostring(height))
end

--@api: LuaLineChart:render
do
    local chart = lurek.charts.newLine({ width = 200, height = 150 })
    chart:addSeries("data", {{1, 50}, {2, 80}, {3, 60}, {4, 90}})
    local w, h, pixels = chart:render()
    local image = chart:renderImage()
    lurek.log.info("line render size=" .. tostring(w) .. "x" .. tostring(h))
    lurek.log.info("line render bytes=" .. tostring(#pixels) .. " image ok=" .. tostring(image ~= nil))
end

--@api: LuaLineChart:getWidth
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:addSeries("North", {{1, 12}, {2, 18}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("line width=" .. tostring(width))
    lurek.log.info("line height=" .. tostring(height))
end

--@api: LuaLineChart:getHeight
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:addSeries("North", {{1, 12}, {2, 18}})
    local height = chart:getHeight()
    local width = chart:getWidth()
    lurek.log.info("line height=" .. tostring(height))
    lurek.log.info("line width=" .. tostring(width))
end

--@api: LuaBarChart:addSeries
do
    local chart = lurek.charts.newBar({ width = 400, height = 300, title = "Sales by Region" })
    local data = {{1, 50}, {2, 80}, {3, 30}, {4, 65}, {5, 45}}
    chart:addSeries("North", data)
    example_print_log("bar series added")
    example_print_log("bars = " .. tostring(#data))
end

--@api: LuaBarChart:setBarWidth
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:setBarWidth(24)
    chart:addSeries("North", {{1, 50}, {2, 80}, {3, 30}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("bar width set to 24")
    lurek.log.info("bar chart size=" .. tostring(width) .. "x" .. tostring(height))
end

--@api: LuaBarChart:render
do
    local chart = lurek.charts.newBar({ width = 200, height = 150 })
    chart:addSeries("items", {{1, 40}, {2, 70}, {3, 55}})
    local w, h, pixels = chart:render()
    local image = chart:renderImage()
    lurek.log.info("bar render size=" .. tostring(w) .. "x" .. tostring(h))
    lurek.log.info("bar render bytes=" .. tostring(#pixels) .. " image ok=" .. tostring(image ~= nil))
end

--@api: LuaPieChart:addSlice
do
    local chart = lurek.charts.newPie({ width = 300, height = 300, title = "Browser Market Share" })
    chart:addSlice("Chrome", 65)
    chart:addSlice("Firefox", 12)
    chart:addSlice("Safari", 18)
    chart:addSlice("Other", 5)
    example_print_log("pie slices added = 4")
    example_print_log("chart size = " .. tostring(chart:getWidth()) .. "x" .. tostring(chart:getHeight()))
end

--@api: LuaPieChart:render
do
    local chart = lurek.charts.newPie({ width = 200, height = 200 })
    chart:addSlice("A", 40)
    chart:addSlice("B", 35)
    chart:addSlice("C", 25)
    local w, h, pixels = chart:render()
    example_print_log("pie render w=" .. w .. " h=" .. h .. " pixels=" .. #pixels .. " bytes")
end

--@api: LuaScatterPlot:addSeries
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300, title = "Height vs Weight" })
    local points = {{160, 55}, {170, 68}, {175, 72}, {180, 80}, {165, 60}, {185, 88}, {172, 65}}
    chart:addSeries("Measurements", points)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("scatter series points=" .. tostring(#points))
    lurek.log.info("scatter chart size=" .. tostring(width) .. "x" .. tostring(height))
end

--@api: LuaScatterPlot:setDotRadius
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:setDotRadius(4)
    chart:addSeries("Scores", {{1, 10}, {2, 14}, {3, 18}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("scatter dot radius set to 4")
    lurek.log.info("scatter chart size=" .. tostring(width) .. "x" .. tostring(height))
end

--@api: LuaAreaChart:addSeries
do
    local chart = lurek.charts.newArea({ width = 400, height = 300, title = "Monthly Active Users" })
    local mobile = {{1, 200}, {2, 280}, {3, 350}, {4, 420}, {5, 500}, {6, 580}}
    local desktop = {{1, 400}, {2, 380}, {3, 360}, {4, 340}, {5, 320}, {6, 310}}
    chart:addSeries("Mobile", mobile)
    chart:addSeries("Desktop", desktop)
    example_print_log("area series added = 2")
    example_print_log("mobile points = " .. tostring(#mobile))
end

--@api: LuaAreaChart:render
do
    local chart = lurek.charts.newArea({ width = 200, height = 150 })
    chart:addSeries("growth", {{1, 10}, {2, 30}, {3, 60}, {4, 100}})
    local w, h, pixels = chart:render()
    local image = chart:renderImage()
    lurek.log.info("area render size=" .. tostring(w) .. "x" .. tostring(h))
    lurek.log.info("area render bytes=" .. tostring(#pixels) .. " image ok=" .. tostring(image ~= nil))
end

--@api: LAreaChart:addSeries
do
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    chart:addSeries("series1", { {1, 1}, {2, 3}, {3, 2}, {4, 5}, {5, 4} })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("area series added for trend view")
    lurek.log.info("area chart size=" .. tostring(width) .. "x" .. tostring(height))
end

--@api: LAreaChart:clear
do
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 1}, {2, 2}, {3, 3} })
    chart:clear()
    local w, h, pixels = chart:render()
    example_print_log("LAreaChart:clear ok")
    example_print_log("render bytes = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end

--@api: LAreaChart:setTitle
do
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    chart:setTitle("Monthly Sales")
    chart:addSeries("North", {{1, 5}, {2, 7}, {3, 8}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("area title set for monthly sales")
    lurek.log.info("area chart size=" .. tostring(width) .. "x" .. tostring(height))
end

--@api: LAreaChart:render
do
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 5}, {2, 3}, {3, 8}, {4, 2}, {5, 6} })
    local w, h, pixels = chart:render()
    example_print_log("LAreaChart:render ok")
    example_print_log("pixels = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end

--@api: LAreaChart:getWidth
do
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    chart:addSeries("North", {{1, 5}, {2, 7}, {3, 8}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("area width=" .. tostring(width))
    lurek.log.info("area height=" .. tostring(height))
end

--@api: LAreaChart:getHeight
do
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    chart:addSeries("North", {{1, 5}, {2, 7}, {3, 8}})
    local height = chart:getHeight()
    local width = chart:getWidth()
    lurek.log.info("area height=" .. tostring(height))
    lurek.log.info("area width=" .. tostring(width))
end

--@api: LBarChart:addSeries
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:addSeries("series1", { {1, 1}, {2, 3}, {3, 2}, {4, 5}, {5, 4} })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("bar series added for quarterly sales")
    lurek.log.info("bar chart size=" .. tostring(width) .. "x" .. tostring(height))
end

--@api: LBarChart:clear
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 1}, {2, 2}, {3, 3} })
    chart:clear()
    local w, h, pixels = chart:render()
    example_print_log("LBarChart:clear ok")
    example_print_log("render bytes = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end

--@api: LBarChart:setBarWidth
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:setBarWidth(20.0)
    chart:addSeries("North", {{1, 10}, {2, 12}, {3, 14}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("bar width set to 20")
    lurek.log.info("bar chart size=" .. tostring(width) .. "x" .. tostring(height))
end

--@api: LBarChart:setTitle
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:setTitle("Monthly Sales")
    chart:addSeries("North", {{1, 10}, {2, 12}, {3, 14}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("bar title set for monthly sales")
    lurek.log.info("bar chart size=" .. tostring(width) .. "x" .. tostring(height))
end

--@api: LBarChart:render
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 5}, {2, 3}, {3, 8}, {4, 2}, {5, 6} })
    local w, h, pixels = chart:render()
    example_print_log("LBarChart:render ok")
    example_print_log("pixels = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end

--@api: LBarChart:getWidth
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:addSeries("North", {{1, 10}, {2, 12}, {3, 14}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("bar width=" .. tostring(width))
    lurek.log.info("bar height=" .. tostring(height))
end

--@api: LBarChart:getHeight
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:addSeries("North", {{1, 10}, {2, 12}, {3, 14}})
    local height = chart:getHeight()
    local width = chart:getWidth()
    lurek.log.info("bar height=" .. tostring(height))
    lurek.log.info("bar width=" .. tostring(width))
end

--@api: LLineChart:addSeries
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:addSeries("series1", { {1, 1}, {2, 3}, {3, 2}, {4, 5}, {5, 4} })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("line series added for cadence chart")
    lurek.log.info("line chart size=" .. tostring(width) .. "x" .. tostring(height))
end

--@api: LLineChart:clear
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 1}, {2, 2}, {3, 3} })
    chart:clear()
    local w, h, pixels = chart:render()
    example_print_log("LLineChart:clear ok")
    example_print_log("render bytes = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end

--@api: LLineChart:setTitle
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:setTitle("Monthly Sales")
    chart:addSeries("North", {{1, 10}, {2, 14}, {3, 11}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("line title set for monthly sales")
    lurek.log.info("line chart size=" .. tostring(width) .. "x" .. tostring(height))
end

--@api: LLineChart:render
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 5}, {2, 3}, {3, 8}, {4, 2}, {5, 6} })
    local w, h, pixels = chart:render()
    example_print_log("LLineChart:render ok")
    example_print_log("pixels = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end

--@api: LLineChart:getWidth
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:addSeries("North", {{1, 10}, {2, 14}, {3, 11}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("line width=" .. tostring(width))
    lurek.log.info("line height=" .. tostring(height))
end

--@api: LLineChart:getHeight
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:addSeries("North", {{1, 10}, {2, 14}, {3, 11}})
    local height = chart:getHeight()
    local width = chart:getWidth()
    lurek.log.info("line height=" .. tostring(height))
    lurek.log.info("line width=" .. tostring(width))
end

--@api: LPieChart:addSlice
do
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    chart:addSlice("Food", 45.0, { 0.9, 0.3, 0.1, 1.0 })
    chart:addSlice("Transport", 20.0, { 0.2, 0.6, 0.9, 1.0 })
    example_print_log("LPieChart:addSlice ok")
    example_print_log("width = " .. tostring(chart:getWidth()))
end

--@api: LPieChart:clear
do
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    chart:addSlice("A", 1)
    chart:addSlice("B", 2)
    chart:clear()
    local w, h, pixels = chart:render()
    example_print_log("LPieChart:clear ok")
    example_print_log("render bytes = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end

--@api: LPieChart:setTitle
do
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    chart:setTitle("Monthly Sales")
    chart:addSlice("North", 42)
    chart:addSlice("South", 33)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("pie title set for monthly sales")
    lurek.log.info("pie chart size=" .. tostring(width) .. "x" .. tostring(height))
end

--@api: LPieChart:render
do
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    chart:addSlice("A", 5)
    chart:addSlice("B", 3)
    chart:addSlice("C", 8)
    local w, h, pixels = chart:render()
    example_print_log("LPieChart:render ok")
    example_print_log("pixels = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end

--@api: LPieChart:getWidth
do
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    chart:addSlice("North", 42)
    chart:addSlice("South", 33)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("pie width=" .. tostring(width))
    lurek.log.info("pie height=" .. tostring(height))
end

--@api: LPieChart:getHeight
do
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    chart:addSlice("North", 42)
    chart:addSlice("South", 33)
    local height = chart:getHeight()
    local width = chart:getWidth()
    lurek.log.info("pie height=" .. tostring(height))
    lurek.log.info("pie width=" .. tostring(width))
end

--@api: LScatterPlot:addSeries
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:addSeries("series1", { {1, 1}, {2, 3}, {3, 2}, {4, 5}, {5, 4} })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("scatter series added for player scores")
    lurek.log.info("scatter chart size=" .. tostring(width) .. "x" .. tostring(height))
end

--@api: LScatterPlot:clear
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 1}, {2, 2}, {3, 3} })
    chart:clear()
    local w, h, pixels = chart:render()
    example_print_log("LScatterPlot:clear ok")
    example_print_log("render bytes = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end

--@api: LScatterPlot:setDotRadius
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:setDotRadius(5.0)
    chart:addSeries("Players", {{1, 10}, {2, 12}, {3, 18}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("scatter dot radius set to 5")
    lurek.log.info("scatter chart size=" .. tostring(width) .. "x" .. tostring(height))
end

--@api: LScatterPlot:setTitle
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:setTitle("Monthly Sales")
    chart:addSeries("Players", {{1, 10}, {2, 12}, {3, 18}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("scatter title set for monthly sales")
    lurek.log.info("scatter chart size=" .. tostring(width) .. "x" .. tostring(height))
end

--@api: LScatterPlot:render
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 5}, {2, 3}, {3, 8}, {4, 2}, {5, 6} })
    local w, h, pixels = chart:render()
    example_print_log("LScatterPlot:render ok")
    example_print_log("pixels = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end

--@api: LScatterPlot:getWidth
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:addSeries("Players", {{1, 10}, {2, 12}, {3, 18}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("scatter width=" .. tostring(width))
    lurek.log.info("scatter height=" .. tostring(height))
end

--@api: LScatterPlot:getHeight
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:addSeries("Players", {{1, 10}, {2, 12}, {3, 18}})
    local height = chart:getHeight()
    local width = chart:getWidth()
    lurek.log.info("scatter height=" .. tostring(height))
    lurek.log.info("scatter width=" .. tostring(width))
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
    local typeName = chart:type()
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("histogram type=" .. tostring(typeName))
    lurek.log.info("histogram size=" .. tostring(width) .. "x" .. tostring(height))
end

--@api: lurek.charts.newHeatmap
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180, title = "Region Load" })
    chart:setMatrix({ { 2, 4 }, { 6, 8 } }, { "North", "South" }, { "Q1", "Q2" })
    local typeName = chart:type()
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("heatmap type=" .. tostring(typeName))
    lurek.log.info("heatmap size=" .. tostring(width) .. "x" .. tostring(height))
end

--@api: LAreaChart:addLayer
do
    local chart = lurek.charts.newArea({ width = 320, height = 180, title = "Area Layers" })
    chart:addLayer("north", { 10, 14, 18, 20 })
    chart:addLayer("south", { 8, 11, 14, 16 })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("added area layers north and south")
    lurek.log.info("area layer chart size=" .. tostring(width) .. "x" .. tostring(height))
end

--@api: LAreaChart:addLayerFromDataFrame
do
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    local df = charts_df()
    local added = chart:addLayerFromDataFrame("north", df, "north")
    example_print_log("rows added = " .. tostring(added))
    example_print_log("height = " .. chart:getHeight())
end

--@api: LAreaChart:appendPoint
do
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:addSeries("trend", { { 1, 12 }, { 2, 16 } })
    chart:appendPoint("trend", 3, 21)
    local _, _, pixels = chart:render()
    example_print_log("append point pixels = " .. #pixels)
end

--@api: LAreaChart:setWindow
do
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:addSeries("trend", { { 1, 8 }, { 2, 12 }, { 3, 15 }, { 4, 19 } })
    chart:setWindow(2)
    local _, _, pixels = chart:render()
    example_print_log("windowed render bytes = " .. #pixels)
end

--@api: LAreaChart:setYMax
do
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:addSeries("trend", { { 1, 8 }, { 2, 12 }, { 3, 15 } })
    chart:setYMax(20)
    example_print_log("manual y max applied")
    example_print_log("type = " .. chart:type())
end

--@api: LAreaChart:setXLabel
do
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:setXLabel("Month")
    chart:setYLabel("Users")
    local _, _, pixels = chart:render()
    example_print_log("labeled area bytes = " .. #pixels)
end

--@api: LAreaChart:setYLabel
do
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:setYLabel("Requests")
    chart:addLayer("api", { 3, 5, 8, 13 })
    local _, _, pixels = chart:render()
    example_print_log("area label bytes = " .. #pixels)
end

--@api: LAreaChart:setXTickCount
do
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:setXTickCount(5)
    chart:addLayer("api", { 3, 5, 8, 13 })
    local _, _, pixels = chart:render()
    example_print_log("x ticks bytes = " .. #pixels)
end

--@api: LAreaChart:setYTickCount
do
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:setYTickCount(6)
    chart:addLayer("api", { 3, 5, 8, 13 })
    local _, _, pixels = chart:render()
    example_print_log("y ticks bytes = " .. #pixels)
end

--@api: LAreaChart:setShowLegend
do
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:addLayer("north", { 5, 6, 7, 8 })
    chart:addLayer("south", { 4, 5, 5, 6 })
    chart:setShowLegend(true)
    local _, _, pixels = chart:render()
    example_print_log("legend bytes = " .. #pixels)
end

--@api: LAreaChart:renderImage
do
    local chart = lurek.charts.newArea({ width = 256, height = 128 })
    chart:addLayer("north", { 5, 6, 9, 12 })
    local img = chart:renderImage()
    example_print_log("render image type = " .. img:type())
    example_print_log("render image size = " .. img:getWidth() .. "x" .. img:getHeight())
end

--@api: LAreaChart:drawToImage
do
    local chart = lurek.charts.newArea({ width = 256, height = 128 })
    local target = chart_target_image(256, 128)
    chart:addLayer("north", { 5, 6, 9, 12 })
    chart:drawToImage(target)
    example_print_log("target size = " .. target:getWidth() .. "x" .. target:getHeight())
end

--@api: LAreaChart:draw
do
    local chart = lurek.charts.newArea({ width = 256, height = 128 })
    chart:addLayer("north", { 5, 6, 9, 12 })
    chart:draw(24, 16, {})
    example_print_log("draw call issued")
    example_print_log("area type = " .. chart:type())
end

--@api: LAreaChart:type
do
    local chart = lurek.charts.newArea({ width = 256, height = 128 })
    chart:addLayer("north", { 5, 6, 9, 12 })
    local typeName = chart:type()
    local isObject = chart:typeOf("LObject")
    lurek.log.info("area chart type=" .. tostring(typeName))
    lurek.log.info("area chart is object=" .. tostring(isObject))
end

--@api: LAreaChart:typeOf
do
    local chart = lurek.charts.newArea({ width = 256, height = 128 })
    chart:addLayer("north", { 5, 6, 9, 12 })
    local isArea = chart:typeOf("LAreaChart")
    local isBar = chart:typeOf("LBarChart")
    lurek.log.info("typeOf LAreaChart=" .. tostring(isArea))
    lurek.log.info("typeOf LBarChart=" .. tostring(isBar))
end

--@api: LBarChart:addCategory
do
    local chart = lurek.charts.newBar({ width = 320, height = 180 })
    chart:addCategory("Q1", { 12, 8, 5 })
    chart:addCategory("Q2", { 18, 11, 7 })
    local _, _, pixels = chart:render()
    example_print_log("categories bytes = " .. #pixels)
end

--@api: LBarChart:addCategoriesFromDataFrame
do
    local chart = lurek.charts.newBar({ width = 320, height = 180 })
    local df = charts_df()
    local added = chart:addCategoriesFromDataFrame(df, "label", { "north", "south", "east" })
    example_print_log("categories added = " .. tostring(added))
    example_print_log("height = " .. chart:getHeight())
end

--@api: LBarChart:setXLabel
do
    local chart = lurek.charts.newBar({ width = 320, height = 180 })
    chart:setXLabel("Quarter")
    chart:addCategory("Q1", { 12, 8, 5 })
    local _, _, pixels = chart:render()
    example_print_log("bar x label bytes = " .. #pixels)
end

--@api: LBarChart:setYLabel
do
    local chart = lurek.charts.newBar({ width = 320, height = 180 })
    chart:setYLabel("Sales")
    chart:addCategory("Q1", { 12, 8, 5 })
    local _, _, pixels = chart:render()
    example_print_log("bar y label bytes = " .. #pixels)
end

--@api: LBarChart:setXTickCount
do
    local chart = lurek.charts.newBar({ width = 320, height = 180 })
    chart:setXTickCount(4)
    chart:addCategory("Q1", { 12, 8, 5 })
    chart:addCategory("Q2", { 18, 11, 7 })
    local _, _, pixels = chart:render()
    example_print_log("bar x ticks bytes = " .. #pixels)
end

--@api: LBarChart:setYTickCount
do
    local chart = lurek.charts.newBar({ width = 320, height = 180 })
    chart:setYTickCount(6)
    chart:addCategory("Q1", { 12, 8, 5 })
    chart:addCategory("Q2", { 18, 11, 7 })
    local _, _, pixels = chart:render()
    example_print_log("bar y ticks bytes = " .. #pixels)
end

--@api: LBarChart:setShowLegend
do
    local chart = lurek.charts.newBar({ width = 320, height = 180 })
    chart:addCategory("Q1", { 12, 8, 5 })
    chart:addCategory("Q2", { 18, 11, 7 })
    chart:setShowLegend(true)
    local _, _, pixels = chart:render()
    example_print_log("bar legend bytes = " .. #pixels)
end

--@api: LBarChart:renderImage
do
    local chart = lurek.charts.newBar({ width = 256, height = 128 })
    chart:addCategory("Q1", { 12, 8, 5 })
    local img = chart:renderImage()
    example_print_log("bar image type = " .. img:type())
    example_print_log("bar image size = " .. img:getWidth() .. "x" .. img:getHeight())
end

--@api: LBarChart:drawToImage
do
    local chart = lurek.charts.newBar({ width = 256, height = 128 })
    local target = chart_target_image(256, 128)
    chart:addCategory("Q1", { 12, 8, 5 })
    chart:drawToImage(target)
    example_print_log("bar target bytes = " .. target:getWidth() .. "x" .. target:getHeight())
end

--@api: LBarChart:draw
do
    local chart = lurek.charts.newBar({ width = 256, height = 128 })
    chart:addCategory("Q1", { 12, 8, 5 })
    chart:draw(12, 8, {})
    example_print_log("bar draw issued")
    example_print_log("bar type = " .. chart:type())
end

--@api: LBarChart:type
do
    local chart = lurek.charts.newBar({ width = 256, height = 128 })
    chart:addCategory("Q1", { 12, 8, 5 })
    local typeName = chart:type()
    local isObject = chart:typeOf("LObject")
    lurek.log.info("bar chart type=" .. tostring(typeName))
    lurek.log.info("bar chart is object=" .. tostring(isObject))
end

--@api: LBarChart:typeOf
do
    local chart = lurek.charts.newBar({ width = 256, height = 128 })
    chart:addCategory("Q1", { 12, 8, 5 })
    local isBar = chart:typeOf("LBarChart")
    local isArea = chart:typeOf("LAreaChart")
    lurek.log.info("typeOf LBarChart=" .. tostring(isBar))
    lurek.log.info("typeOf LAreaChart=" .. tostring(isArea))
end

--@api: LHeatmapChart:setMatrix
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    local _, _, pixels = chart:render()
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("heatmap matrix bytes=" .. tostring(#pixels))
    lurek.log.info("heatmap size=" .. tostring(width) .. "x" .. tostring(height))
end

--@api: LHeatmapChart:setMatrixFromDataFrame
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    local df = charts_df()
    local cells = chart:setMatrixFromDataFrame(df, "row", "col", "value")
    example_print_log("matrix cells = " .. tostring(cells))
    example_print_log("width = " .. chart:getWidth())
end

--@api: LHeatmapChart:resize
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:resize(3, 2)
    chart:setCell(1, 1, 1.5)
    chart:setCell(3, 2, 4.5)
    local _, _, pixels = chart:render()
    example_print_log("resized heatmap bytes = " .. #pixels)
end

--@api: LHeatmapChart:setCell
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:resize(2, 2)
    chart:setCell(1, 1, 2.5)
    chart:setCell(2, 2, 7.5)
    local _, _, pixels = chart:render()
    example_print_log("heatmap cell bytes = " .. #pixels)
end

--@api: LHeatmapChart:clear
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    chart:clear()
    local _, _, pixels = chart:render()
    example_print_log("cleared heatmap bytes = " .. #pixels)
end

--@api: LHeatmapChart:setRowLabels
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:setRowLabels({ "North", "South" })
    local _, _, pixels = chart:render()
    example_print_log("row labels bytes = " .. #pixels)
end

--@api: LHeatmapChart:setColumnLabels
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:setColumnLabels({ "Q1", "Q2" })
    local _, _, pixels = chart:render()
    example_print_log("column labels bytes = " .. #pixels)
end

--@api: LHeatmapChart:setValueRange
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:setValueRange(0, 10)
    local _, _, pixels = chart:render()
    example_print_log("value range bytes = " .. #pixels)
end

--@api: LHeatmapChart:clearValueRange
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:setValueRange(0, 10)
    chart:clearValueRange()
    local _, _, pixels = chart:render()
    example_print_log("cleared range bytes = " .. #pixels)
end

--@api: LHeatmapChart:setColorRange
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:setColorRange({ 0.10, 0.20, 0.60, 1.0 }, { 0.90, 0.20, 0.10, 1.0 })
    local _, _, pixels = chart:render()
    example_print_log("color range bytes = " .. #pixels)
end

--@api: LHeatmapChart:setShowValues
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:setShowValues(true)
    local _, _, pixels = chart:render()
    example_print_log("show values bytes = " .. #pixels)
end

--@api: LHeatmapChart:setTitle
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setTitle("Throughput Grid")
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    local _, _, pixels = chart:render()
    example_print_log("heatmap title bytes = " .. #pixels)
end

--@api: LHeatmapChart:setShowLegend
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:setShowLegend(true)
    local _, _, pixels = chart:render()
    example_print_log("heatmap legend bytes = " .. #pixels)
end

--@api: LHeatmapChart:render
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    local w, h, pixels = chart:render()
    example_print_log("render size = " .. w .. "x" .. h)
    example_print_log("render bytes = " .. #pixels)
end

--@api: LHeatmapChart:renderImage
do
    local chart = lurek.charts.newHeatmap({ width = 256, height = 128 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    local img = chart:renderImage()
    example_print_log("heatmap image type = " .. img:type())
    example_print_log("heatmap image width = " .. img:getWidth())
end

--@api: LHeatmapChart:drawToImage
do
    local chart = lurek.charts.newHeatmap({ width = 256, height = 128 })
    local target = chart_target_image(256, 128)
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:drawToImage(target)
    example_print_log("heatmap target width = " .. target:getWidth())
end

--@api: LHeatmapChart:draw
do
    local chart = lurek.charts.newHeatmap({ width = 256, height = 128 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:draw(18, 10, {})
    example_print_log("heatmap draw issued")
    example_print_log("heatmap type = " .. chart:type())
end

--@api: LHeatmapChart:getWidth
do
    local chart = lurek.charts.newHeatmap({ width = 333, height = 144 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("heatmap width=" .. tostring(width))
    lurek.log.info("heatmap height=" .. tostring(height))
end

--@api: LHeatmapChart:getHeight
do
    local chart = lurek.charts.newHeatmap({ width = 333, height = 144 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    local height = chart:getHeight()
    local width = chart:getWidth()
    lurek.log.info("heatmap height=" .. tostring(height))
    lurek.log.info("heatmap width=" .. tostring(width))
end

--@api: LHeatmapChart:type
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    local typeName = chart:type()
    local isObject = chart:typeOf("LObject")
    lurek.log.info("heatmap type=" .. tostring(typeName))
    lurek.log.info("heatmap is object=" .. tostring(isObject))
end

--@api: LHeatmapChart:typeOf
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    local isHeatmap = chart:typeOf("LHeatmapChart")
    local isPie = chart:typeOf("LPieChart")
    lurek.log.info("typeOf LHeatmapChart=" .. tostring(isHeatmap))
    lurek.log.info("typeOf LPieChart=" .. tostring(isPie))
end

--@api: LHistogramChart:addSeries
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 18, 22, 25, 18 })
    local _, _, pixels = chart:render()
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("histogram render bytes=" .. tostring(#pixels))
    lurek.log.info("histogram size=" .. tostring(width) .. "x" .. tostring(height))
end

--@api: LHistogramChart:addSeriesFromDataFrame
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    local df = charts_df()
    local added = chart:addSeriesFromDataFrame("north", df, "north")
    example_print_log("histogram rows added = " .. tostring(added))
    example_print_log("width = " .. chart:getWidth())
end

--@api: LHistogramChart:replaceSeries
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18 })
    chart:replaceSeries("response", { 30, 28, 26, 24 })
    local _, _, pixels = chart:render()
    example_print_log("replaced histogram bytes = " .. #pixels)
end

--@api: LHistogramChart:appendValue
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18 })
    chart:appendValue("response", 21)
    local _, _, pixels = chart:render()
    example_print_log("append histogram bytes = " .. #pixels)
end

--@api: LHistogramChart:setWindow
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    chart:setWindow(4)
    local _, _, pixels = chart:render()
    example_print_log("window histogram bytes = " .. #pixels)
end

--@api: LHistogramChart:clear
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18 })
    chart:clear()
    local _, _, pixels = chart:render()
    example_print_log("cleared histogram bytes = " .. #pixels)
end

--@api: LHistogramChart:setBinCount
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    chart:setBinCount(5)
    local _, _, pixels = chart:render()
    example_print_log("bins histogram bytes = " .. #pixels)
end

--@api: LHistogramChart:setRange
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    chart:setRange(10, 30)
    local _, _, pixels = chart:render()
    example_print_log("range histogram bytes = " .. #pixels)
end

--@api: LHistogramChart:clearRange
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    chart:setRange(10, 30)
    chart:clearRange()
    local _, _, pixels = chart:render()
    example_print_log("clear range histogram bytes = " .. #pixels)
end

--@api: LHistogramChart:setDensity
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    chart:setDensity(true)
    local _, _, pixels = chart:render()
    example_print_log("density histogram bytes = " .. #pixels)
end

--@api: LHistogramChart:setTitle
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:setTitle("Response Times")
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    local _, _, pixels = chart:render()
    example_print_log("histogram title bytes = " .. #pixels)
end

--@api: LHistogramChart:setXLabel
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:setXLabel("Latency")
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    local _, _, pixels = chart:render()
    example_print_log("histogram x label bytes = " .. #pixels)
end

--@api: LHistogramChart:setYLabel
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:setYLabel("Frequency")
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    local _, _, pixels = chart:render()
    example_print_log("histogram y label bytes = " .. #pixels)
end

--@api: LHistogramChart:setXTickCount
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:setXTickCount(5)
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    local _, _, pixels = chart:render()
    example_print_log("histogram x ticks bytes = " .. #pixels)
end

--@api: LHistogramChart:setYTickCount
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:setYTickCount(6)
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    local _, _, pixels = chart:render()
    example_print_log("histogram y ticks bytes = " .. #pixels)
end

--@api: LHistogramChart:setShowLegend
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("north", { 12, 14, 18, 21 })
    chart:addSeries("south", { 9, 10, 11, 15 })
    chart:setShowLegend(true)
    local _, _, pixels = chart:render()
    example_print_log("histogram legend bytes = " .. #pixels)
end

--@api: LHistogramChart:render
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    local w, h, pixels = chart:render()
    example_print_log("histogram size = " .. w .. "x" .. h)
    example_print_log("histogram bytes = " .. #pixels)
end

--@api: LHistogramChart:renderImage
do
    local chart = lurek.charts.newHistogram({ width = 256, height = 128 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    local img = chart:renderImage()
    example_print_log("histogram image type = " .. img:type())
    example_print_log("histogram image width = " .. img:getWidth())
end

--@api: LHistogramChart:drawToImage
do
    local chart = lurek.charts.newHistogram({ width = 256, height = 128 })
    local target = chart_target_image(256, 128)
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    chart:drawToImage(target)
    example_print_log("histogram target width = " .. target:getWidth())
end

--@api: LHistogramChart:draw
do
    local chart = lurek.charts.newHistogram({ width = 256, height = 128 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    chart:draw(16, 8, {})
    example_print_log("histogram draw issued")
    example_print_log("histogram type = " .. chart:type())
end

--@api: LHistogramChart:getWidth
do
    local chart = lurek.charts.newHistogram({ width = 345, height = 176 })
    chart:addSeries("response", { 12, 14, 18, 21 })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("histogram width=" .. tostring(width))
    lurek.log.info("histogram height=" .. tostring(height))
end

--@api: LHistogramChart:getHeight
do
    local chart = lurek.charts.newHistogram({ width = 345, height = 176 })
    chart:addSeries("response", { 12, 14, 18, 21 })
    local height = chart:getHeight()
    local width = chart:getWidth()
    lurek.log.info("histogram height=" .. tostring(height))
    lurek.log.info("histogram width=" .. tostring(width))
end

--@api: LHistogramChart:type
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 21 })
    local typeName = chart:type()
    local isObject = chart:typeOf("LObject")
    lurek.log.info("histogram type=" .. tostring(typeName))
    lurek.log.info("histogram is object=" .. tostring(isObject))
end

--@api: LHistogramChart:typeOf
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 21 })
    local isHistogram = chart:typeOf("LHistogramChart")
    local isLine = chart:typeOf("LLineChart")
    lurek.log.info("typeOf LHistogramChart=" .. tostring(isHistogram))
    lurek.log.info("typeOf LLineChart=" .. tostring(isLine))
end

--@api: LLineChart:addSeriesFromDataFrame
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    local df = charts_df()
    local added = chart:addSeriesFromDataFrame("north", df, "month", "north")
    example_print_log("line rows added = " .. tostring(added))
    example_print_log("width = " .. chart:getWidth())
end

--@api: LLineChart:replaceSeries
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 } })
    chart:replaceSeries("north", { { 1, 9 }, { 2, 11 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    example_print_log("line replace bytes = " .. #pixels)
end

--@api: LLineChart:appendPoint
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 } })
    chart:appendPoint("north", 3, 15)
    local _, _, pixels = chart:render()
    example_print_log("line append bytes = " .. #pixels)
end

--@api: LLineChart:setWindow
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 }, { 4, 24 } })
    chart:setWindow(2)
    local _, _, pixels = chart:render()
    example_print_log("line window bytes = " .. #pixels)
end

--@api: LLineChart:setYMax
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setYMax(30)
    local _, _, pixels = chart:render()
    example_print_log("line y max bytes = " .. #pixels)
end

--@api: LLineChart:setXMax
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setXMax(6)
    local _, _, pixels = chart:render()
    example_print_log("line x max bytes = " .. #pixels)
end

--@api: LLineChart:setXLabel
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:setXLabel("Month")
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    example_print_log("line x label bytes = " .. #pixels)
end

--@api: LLineChart:setYLabel
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:setYLabel("Users")
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    example_print_log("line y label bytes = " .. #pixels)
end

--@api: LLineChart:setXTickCount
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:setXTickCount(5)
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    example_print_log("line x ticks bytes = " .. #pixels)
end

--@api: LLineChart:setYTickCount
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:setYTickCount(6)
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    example_print_log("line y ticks bytes = " .. #pixels)
end

--@api: LLineChart:setShowLegend
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:addSeries("south", { { 1, 8 }, { 2, 11 }, { 3, 16 } })
    chart:setShowLegend(true)
    local _, _, pixels = chart:render()
    example_print_log("line legend bytes = " .. #pixels)
end

--@api: LLineChart:renderImage
do
    local chart = lurek.charts.newLine({ width = 256, height = 128 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local img = chart:renderImage()
    example_print_log("line image type = " .. img:type())
    example_print_log("line image width = " .. img:getWidth())
end

--@api: LLineChart:drawToImage
do
    local chart = lurek.charts.newLine({ width = 256, height = 128 })
    local target = chart_target_image(256, 128)
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:drawToImage(target)
    example_print_log("line target width = " .. target:getWidth())
end

--@api: LLineChart:draw
do
    local chart = lurek.charts.newLine({ width = 256, height = 128 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:draw(20, 12, {})
    example_print_log("line draw issued")
    example_print_log("line type = " .. chart:type())
end

--@api: LLineChart:nearest
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local hit = chart:nearest(120, 80)
    example_print_log("line nearest found = " .. tostring(hit ~= nil))
    example_print_log("line nearest series = " .. tostring(hit and hit.series))
end

--@api: LLineChart:type
do
    local chart = lurek.charts.newLine({ width = 256, height = 128 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local typeName = chart:type()
    local isObject = chart:typeOf("LObject")
    lurek.log.info("line chart type=" .. tostring(typeName))
    lurek.log.info("line chart is object=" .. tostring(isObject))
end

--@api: LLineChart:typeOf
do
    local chart = lurek.charts.newLine({ width = 256, height = 128 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local isLine = chart:typeOf("LLineChart")
    local isArea = chart:typeOf("LAreaChart")
    lurek.log.info("typeOf LLineChart=" .. tostring(isLine))
    lurek.log.info("typeOf LAreaChart=" .. tostring(isArea))
end

--@api: LPieChart:addSegment
do
    local chart = lurek.charts.newPie({ width = 320, height = 180 })
    chart:addSegment("North", 42, { 0.9, 0.3, 0.2, 1.0 })
    chart:addSegment("South", 33, { 0.2, 0.6, 0.9, 1.0 })
    local _, _, pixels = chart:render()
    example_print_log("pie segment bytes = " .. #pixels)
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
    example_print_log("pie segments added = " .. tostring(added))
    example_print_log("pie height = " .. chart:getHeight())
end

--@api: LPieChart:setShowLegend
do
    local chart = lurek.charts.newPie({ width = 320, height = 180 })
    chart:addSegment("North", 42)
    chart:addSegment("South", 33)
    chart:setShowLegend(true)
    local _, _, pixels = chart:render()
    example_print_log("pie legend bytes = " .. #pixels)
end

--@api: LPieChart:renderImage
do
    local chart = lurek.charts.newPie({ width = 256, height = 128 })
    chart:addSegment("North", 42)
    chart:addSegment("South", 33)
    local img = chart:renderImage()
    example_print_log("pie image type = " .. img:type())
    example_print_log("pie image width = " .. img:getWidth())
end

--@api: LPieChart:drawToImage
do
    local chart = lurek.charts.newPie({ width = 256, height = 128 })
    local target = chart_target_image(256, 128)
    chart:addSegment("North", 42)
    chart:addSegment("South", 33)
    chart:drawToImage(target)
    example_print_log("pie target width = " .. target:getWidth())
end

--@api: LPieChart:draw
do
    local chart = lurek.charts.newPie({ width = 256, height = 128 })
    chart:addSegment("North", 42)
    chart:addSegment("South", 33)
    chart:draw(20, 10, {})
    example_print_log("pie draw issued")
    example_print_log("pie type = " .. chart:type())
end

--@api: LPieChart:type
do
    local chart = lurek.charts.newPie({ width = 256, height = 128 })
    chart:addSegment("North", 42)
    chart:addSegment("South", 33)
    local typeName = chart:type()
    local isObject = chart:typeOf("LObject")
    lurek.log.info("pie chart type=" .. tostring(typeName))
    lurek.log.info("pie chart is object=" .. tostring(isObject))
end

--@api: LPieChart:typeOf
do
    local chart = lurek.charts.newPie({ width = 256, height = 128 })
    chart:addSegment("North", 42)
    chart:addSegment("South", 33)
    local isPie = chart:typeOf("LPieChart")
    local isBar = chart:typeOf("LBarChart")
    lurek.log.info("typeOf LPieChart=" .. tostring(isPie))
    lurek.log.info("typeOf LBarChart=" .. tostring(isBar))
end

--@api: LScatterPlot:addSeriesFromDataFrame
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    local df = charts_df()
    local added = chart:addSeriesFromDataFrame("north", df, "x", "y")
    example_print_log("scatter rows added = " .. tostring(added))
    example_print_log("scatter width = " .. chart:getWidth())
end

--@api: LScatterPlot:replaceSeries
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 } })
    chart:replaceSeries("north", { { 1, 9 }, { 2, 11 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    example_print_log("scatter replace bytes = " .. #pixels)
end

--@api: LScatterPlot:appendPoint
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 } })
    chart:appendPoint("north", 3, 15)
    local _, _, pixels = chart:render()
    example_print_log("scatter append bytes = " .. #pixels)
end

--@api: LScatterPlot:setWindow
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 }, { 4, 24 } })
    chart:setWindow(3)
    local _, _, pixels = chart:render()
    example_print_log("scatter window bytes = " .. #pixels)
end

--@api: LScatterPlot:setXRange
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setXRange(0, 6)
    local _, _, pixels = chart:render()
    example_print_log("scatter x range bytes = " .. #pixels)
end

--@api: LScatterPlot:setYRange
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setYRange(0, 30)
    local _, _, pixels = chart:render()
    example_print_log("scatter y range bytes = " .. #pixels)
end

--@api: LScatterPlot:setXLabel
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:setXLabel("Hours")
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    example_print_log("scatter x label bytes = " .. #pixels)
end

--@api: LScatterPlot:setYLabel
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:setYLabel("Score")
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    example_print_log("scatter y label bytes = " .. #pixels)
end

--@api: LScatterPlot:setXTickCount
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:setXTickCount(5)
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    example_print_log("scatter x ticks bytes = " .. #pixels)
end

--@api: LScatterPlot:setYTickCount
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:setYTickCount(6)
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    example_print_log("scatter y ticks bytes = " .. #pixels)
end

--@api: LScatterPlot:setShowLegend
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:addSeries("south", { { 1, 8 }, { 2, 11 }, { 3, 16 } })
    chart:setShowLegend(true)
    local _, _, pixels = chart:render()
    example_print_log("scatter legend bytes = " .. #pixels)
end

--@api: LScatterPlot:renderImage
do
    local chart = lurek.charts.newScatter({ width = 256, height = 128 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local img = chart:renderImage()
    example_print_log("scatter image type = " .. img:type())
    example_print_log("scatter image width = " .. img:getWidth())
end

--@api: LScatterPlot:drawToImage
do
    local chart = lurek.charts.newScatter({ width = 256, height = 128 })
    local target = chart_target_image(256, 128)
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:drawToImage(target)
    example_print_log("scatter target width = " .. target:getWidth())
end

--@api: LScatterPlot:draw
do
    local chart = lurek.charts.newScatter({ width = 256, height = 128 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:draw(20, 10, {})
    example_print_log("scatter draw issued")
    example_print_log("scatter type = " .. chart:type())
end

--@api: LScatterPlot:nearest
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local hit = chart:nearest(120, 80)
    example_print_log("scatter nearest found = " .. tostring(hit ~= nil))
    example_print_log("scatter nearest series = " .. tostring(hit and hit.series))
end

--@api: LScatterPlot:type
do
    local chart = lurek.charts.newScatter({ width = 256, height = 128 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local typeName = chart:type()
    local isObject = chart:typeOf("LObject")
    lurek.log.info("scatter chart type=" .. tostring(typeName))
    lurek.log.info("scatter chart is object=" .. tostring(isObject))
end

--@api: LScatterPlot:typeOf
do
    local chart = lurek.charts.newScatter({ width = 256, height = 128 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local isScatter = chart:typeOf("LScatterPlot")
    local isPie = chart:typeOf("LPieChart")
    lurek.log.info("typeOf LScatterPlot=" .. tostring(isScatter))
    lurek.log.info("typeOf LPieChart=" .. tostring(isPie))
end
