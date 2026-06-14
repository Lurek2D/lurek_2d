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

--@api-stub: lurek.charts.newHistogram
do
    -- TODO: example for lurek.charts.newHistogram
    -- keep this block until a real scenario is added
end


--@api-stub: lurek.charts.newHeatmap
do
    -- TODO: example for lurek.charts.newHeatmap
    -- keep this block until a real scenario is added
end


--@api-stub: LAreaChart:addLayer
do
    -- TODO: example for LAreaChart:addLayer
    -- keep this block until a real scenario is added
end


--@api-stub: LAreaChart:addLayerFromDataFrame
do
    -- TODO: example for LAreaChart:addLayerFromDataFrame
    -- keep this block until a real scenario is added
end


--@api-stub: LAreaChart:appendPoint
do
    -- TODO: example for LAreaChart:appendPoint
    -- keep this block until a real scenario is added
end


--@api-stub: LAreaChart:setWindow
do
    -- TODO: example for LAreaChart:setWindow
    -- keep this block until a real scenario is added
end


--@api-stub: LAreaChart:setYMax
do
    -- TODO: example for LAreaChart:setYMax
    -- keep this block until a real scenario is added
end


--@api-stub: LAreaChart:setXLabel
do
    -- TODO: example for LAreaChart:setXLabel
    -- keep this block until a real scenario is added
end


--@api-stub: LAreaChart:setYLabel
do
    -- TODO: example for LAreaChart:setYLabel
    -- keep this block until a real scenario is added
end


--@api-stub: LAreaChart:setXTickCount
do
    -- TODO: example for LAreaChart:setXTickCount
    -- keep this block until a real scenario is added
end


--@api-stub: LAreaChart:setYTickCount
do
    -- TODO: example for LAreaChart:setYTickCount
    -- keep this block until a real scenario is added
end


--@api-stub: LAreaChart:setShowLegend
do
    -- TODO: example for LAreaChart:setShowLegend
    -- keep this block until a real scenario is added
end


--@api-stub: LAreaChart:renderImage
do
    -- TODO: example for LAreaChart:renderImage
    -- keep this block until a real scenario is added
end


--@api-stub: LAreaChart:drawToImage
do
    -- TODO: example for LAreaChart:drawToImage
    -- keep this block until a real scenario is added
end


--@api-stub: LAreaChart:draw
do
    -- TODO: example for LAreaChart:draw
    -- keep this block until a real scenario is added
end


--@api-stub: LAreaChart:type
do
    -- TODO: example for LAreaChart:type
    -- keep this block until a real scenario is added
end


--@api-stub: LAreaChart:typeOf
do
    -- TODO: example for LAreaChart:typeOf
    -- keep this block until a real scenario is added
end


--@api-stub: LBarChart:addCategory
do
    -- TODO: example for LBarChart:addCategory
    -- keep this block until a real scenario is added
end


--@api-stub: LBarChart:addCategoriesFromDataFrame
do
    -- TODO: example for LBarChart:addCategoriesFromDataFrame
    -- keep this block until a real scenario is added
end


--@api-stub: LBarChart:setXLabel
do
    -- TODO: example for LBarChart:setXLabel
    -- keep this block until a real scenario is added
end


--@api-stub: LBarChart:setYLabel
do
    -- TODO: example for LBarChart:setYLabel
    -- keep this block until a real scenario is added
end


--@api-stub: LBarChart:setXTickCount
do
    -- TODO: example for LBarChart:setXTickCount
    -- keep this block until a real scenario is added
end


--@api-stub: LBarChart:setYTickCount
do
    -- TODO: example for LBarChart:setYTickCount
    -- keep this block until a real scenario is added
end


--@api-stub: LBarChart:setShowLegend
do
    -- TODO: example for LBarChart:setShowLegend
    -- keep this block until a real scenario is added
end


--@api-stub: LBarChart:renderImage
do
    -- TODO: example for LBarChart:renderImage
    -- keep this block until a real scenario is added
end


--@api-stub: LBarChart:drawToImage
do
    -- TODO: example for LBarChart:drawToImage
    -- keep this block until a real scenario is added
end


--@api-stub: LBarChart:draw
do
    -- TODO: example for LBarChart:draw
    -- keep this block until a real scenario is added
end


--@api-stub: LBarChart:type
do
    -- TODO: example for LBarChart:type
    -- keep this block until a real scenario is added
end


--@api-stub: LBarChart:typeOf
do
    -- TODO: example for LBarChart:typeOf
    -- keep this block until a real scenario is added
end


--@api-stub: LHeatmapChart:setMatrix
do
    -- TODO: example for LHeatmapChart:setMatrix
    -- keep this block until a real scenario is added
end


--@api-stub: LHeatmapChart:setMatrixFromDataFrame
do
    -- TODO: example for LHeatmapChart:setMatrixFromDataFrame
    -- keep this block until a real scenario is added
end


--@api-stub: LHeatmapChart:resize
do
    -- TODO: example for LHeatmapChart:resize
    -- keep this block until a real scenario is added
end


--@api-stub: LHeatmapChart:setCell
do
    -- TODO: example for LHeatmapChart:setCell
    -- keep this block until a real scenario is added
end


--@api-stub: LHeatmapChart:clear
do
    -- TODO: example for LHeatmapChart:clear
    -- keep this block until a real scenario is added
end


--@api-stub: LHeatmapChart:setRowLabels
do
    -- TODO: example for LHeatmapChart:setRowLabels
    -- keep this block until a real scenario is added
end


--@api-stub: LHeatmapChart:setColumnLabels
do
    -- TODO: example for LHeatmapChart:setColumnLabels
    -- keep this block until a real scenario is added
end


--@api-stub: LHeatmapChart:setValueRange
do
    -- TODO: example for LHeatmapChart:setValueRange
    -- keep this block until a real scenario is added
end


--@api-stub: LHeatmapChart:clearValueRange
do
    -- TODO: example for LHeatmapChart:clearValueRange
    -- keep this block until a real scenario is added
end


--@api-stub: LHeatmapChart:setColorRange
do
    -- TODO: example for LHeatmapChart:setColorRange
    -- keep this block until a real scenario is added
end


--@api-stub: LHeatmapChart:setShowValues
do
    -- TODO: example for LHeatmapChart:setShowValues
    -- keep this block until a real scenario is added
end


--@api-stub: LHeatmapChart:setTitle
do
    -- TODO: example for LHeatmapChart:setTitle
    -- keep this block until a real scenario is added
end


--@api-stub: LHeatmapChart:setShowLegend
do
    -- TODO: example for LHeatmapChart:setShowLegend
    -- keep this block until a real scenario is added
end


--@api-stub: LHeatmapChart:render
do
    -- TODO: example for LHeatmapChart:render
    -- keep this block until a real scenario is added
end


--@api-stub: LHeatmapChart:renderImage
do
    -- TODO: example for LHeatmapChart:renderImage
    -- keep this block until a real scenario is added
end


--@api-stub: LHeatmapChart:drawToImage
do
    -- TODO: example for LHeatmapChart:drawToImage
    -- keep this block until a real scenario is added
end


--@api-stub: LHeatmapChart:draw
do
    -- TODO: example for LHeatmapChart:draw
    -- keep this block until a real scenario is added
end


--@api-stub: LHeatmapChart:getWidth
do
    -- TODO: example for LHeatmapChart:getWidth
    -- keep this block until a real scenario is added
end


--@api-stub: LHeatmapChart:getHeight
do
    -- TODO: example for LHeatmapChart:getHeight
    -- keep this block until a real scenario is added
end


--@api-stub: LHeatmapChart:type
do
    -- TODO: example for LHeatmapChart:type
    -- keep this block until a real scenario is added
end


--@api-stub: LHeatmapChart:typeOf
do
    -- TODO: example for LHeatmapChart:typeOf
    -- keep this block until a real scenario is added
end


--@api-stub: LHistogramChart:addSeries
do
    -- TODO: example for LHistogramChart:addSeries
    -- keep this block until a real scenario is added
end


--@api-stub: LHistogramChart:addSeriesFromDataFrame
do
    -- TODO: example for LHistogramChart:addSeriesFromDataFrame
    -- keep this block until a real scenario is added
end


--@api-stub: LHistogramChart:replaceSeries
do
    -- TODO: example for LHistogramChart:replaceSeries
    -- keep this block until a real scenario is added
end


--@api-stub: LHistogramChart:appendValue
do
    -- TODO: example for LHistogramChart:appendValue
    -- keep this block until a real scenario is added
end


--@api-stub: LHistogramChart:setWindow
do
    -- TODO: example for LHistogramChart:setWindow
    -- keep this block until a real scenario is added
end


--@api-stub: LHistogramChart:clear
do
    -- TODO: example for LHistogramChart:clear
    -- keep this block until a real scenario is added
end


--@api-stub: LHistogramChart:setBinCount
do
    -- TODO: example for LHistogramChart:setBinCount
    -- keep this block until a real scenario is added
end


--@api-stub: LHistogramChart:setRange
do
    -- TODO: example for LHistogramChart:setRange
    -- keep this block until a real scenario is added
end


--@api-stub: LHistogramChart:clearRange
do
    -- TODO: example for LHistogramChart:clearRange
    -- keep this block until a real scenario is added
end


--@api-stub: LHistogramChart:setDensity
do
    -- TODO: example for LHistogramChart:setDensity
    -- keep this block until a real scenario is added
end


--@api-stub: LHistogramChart:setTitle
do
    -- TODO: example for LHistogramChart:setTitle
    -- keep this block until a real scenario is added
end


--@api-stub: LHistogramChart:setXLabel
do
    -- TODO: example for LHistogramChart:setXLabel
    -- keep this block until a real scenario is added
end


--@api-stub: LHistogramChart:setYLabel
do
    -- TODO: example for LHistogramChart:setYLabel
    -- keep this block until a real scenario is added
end


--@api-stub: LHistogramChart:setXTickCount
do
    -- TODO: example for LHistogramChart:setXTickCount
    -- keep this block until a real scenario is added
end


--@api-stub: LHistogramChart:setYTickCount
do
    -- TODO: example for LHistogramChart:setYTickCount
    -- keep this block until a real scenario is added
end


--@api-stub: LHistogramChart:setShowLegend
do
    -- TODO: example for LHistogramChart:setShowLegend
    -- keep this block until a real scenario is added
end


--@api-stub: LHistogramChart:render
do
    -- TODO: example for LHistogramChart:render
    -- keep this block until a real scenario is added
end


--@api-stub: LHistogramChart:renderImage
do
    -- TODO: example for LHistogramChart:renderImage
    -- keep this block until a real scenario is added
end


--@api-stub: LHistogramChart:drawToImage
do
    -- TODO: example for LHistogramChart:drawToImage
    -- keep this block until a real scenario is added
end


--@api-stub: LHistogramChart:draw
do
    -- TODO: example for LHistogramChart:draw
    -- keep this block until a real scenario is added
end


--@api-stub: LHistogramChart:getWidth
do
    -- TODO: example for LHistogramChart:getWidth
    -- keep this block until a real scenario is added
end


--@api-stub: LHistogramChart:getHeight
do
    -- TODO: example for LHistogramChart:getHeight
    -- keep this block until a real scenario is added
end


--@api-stub: LHistogramChart:type
do
    -- TODO: example for LHistogramChart:type
    -- keep this block until a real scenario is added
end


--@api-stub: LHistogramChart:typeOf
do
    -- TODO: example for LHistogramChart:typeOf
    -- keep this block until a real scenario is added
end


--@api-stub: LLineChart:addSeriesFromDataFrame
do
    -- TODO: example for LLineChart:addSeriesFromDataFrame
    -- keep this block until a real scenario is added
end


--@api-stub: LLineChart:replaceSeries
do
    -- TODO: example for LLineChart:replaceSeries
    -- keep this block until a real scenario is added
end


--@api-stub: LLineChart:appendPoint
do
    -- TODO: example for LLineChart:appendPoint
    -- keep this block until a real scenario is added
end


--@api-stub: LLineChart:setWindow
do
    -- TODO: example for LLineChart:setWindow
    -- keep this block until a real scenario is added
end


--@api-stub: LLineChart:setYMax
do
    -- TODO: example for LLineChart:setYMax
    -- keep this block until a real scenario is added
end


--@api-stub: LLineChart:setXMax
do
    -- TODO: example for LLineChart:setXMax
    -- keep this block until a real scenario is added
end


--@api-stub: LLineChart:setXLabel
do
    -- TODO: example for LLineChart:setXLabel
    -- keep this block until a real scenario is added
end


--@api-stub: LLineChart:setYLabel
do
    -- TODO: example for LLineChart:setYLabel
    -- keep this block until a real scenario is added
end


--@api-stub: LLineChart:setXTickCount
do
    -- TODO: example for LLineChart:setXTickCount
    -- keep this block until a real scenario is added
end


--@api-stub: LLineChart:setYTickCount
do
    -- TODO: example for LLineChart:setYTickCount
    -- keep this block until a real scenario is added
end


--@api-stub: LLineChart:setShowLegend
do
    -- TODO: example for LLineChart:setShowLegend
    -- keep this block until a real scenario is added
end


--@api-stub: LLineChart:renderImage
do
    -- TODO: example for LLineChart:renderImage
    -- keep this block until a real scenario is added
end


--@api-stub: LLineChart:drawToImage
do
    -- TODO: example for LLineChart:drawToImage
    -- keep this block until a real scenario is added
end


--@api-stub: LLineChart:draw
do
    -- TODO: example for LLineChart:draw
    -- keep this block until a real scenario is added
end


--@api-stub: LLineChart:nearest
do
    -- TODO: example for LLineChart:nearest
    -- keep this block until a real scenario is added
end


--@api-stub: LLineChart:type
do
    -- TODO: example for LLineChart:type
    -- keep this block until a real scenario is added
end


--@api-stub: LLineChart:typeOf
do
    -- TODO: example for LLineChart:typeOf
    -- keep this block until a real scenario is added
end


--@api-stub: LPieChart:addSegment
do
    -- TODO: example for LPieChart:addSegment
    -- keep this block until a real scenario is added
end


--@api-stub: LPieChart:addSegmentsFromDataFrame
do
    -- TODO: example for LPieChart:addSegmentsFromDataFrame
    -- keep this block until a real scenario is added
end


--@api-stub: LPieChart:setShowLegend
do
    -- TODO: example for LPieChart:setShowLegend
    -- keep this block until a real scenario is added
end


--@api-stub: LPieChart:renderImage
do
    -- TODO: example for LPieChart:renderImage
    -- keep this block until a real scenario is added
end


--@api-stub: LPieChart:drawToImage
do
    -- TODO: example for LPieChart:drawToImage
    -- keep this block until a real scenario is added
end


--@api-stub: LPieChart:draw
do
    -- TODO: example for LPieChart:draw
    -- keep this block until a real scenario is added
end


--@api-stub: LPieChart:type
do
    -- TODO: example for LPieChart:type
    -- keep this block until a real scenario is added
end


--@api-stub: LPieChart:typeOf
do
    -- TODO: example for LPieChart:typeOf
    -- keep this block until a real scenario is added
end


--@api-stub: LScatterPlot:addSeriesFromDataFrame
do
    -- TODO: example for LScatterPlot:addSeriesFromDataFrame
    -- keep this block until a real scenario is added
end


--@api-stub: LScatterPlot:replaceSeries
do
    -- TODO: example for LScatterPlot:replaceSeries
    -- keep this block until a real scenario is added
end


--@api-stub: LScatterPlot:appendPoint
do
    -- TODO: example for LScatterPlot:appendPoint
    -- keep this block until a real scenario is added
end


--@api-stub: LScatterPlot:setWindow
do
    -- TODO: example for LScatterPlot:setWindow
    -- keep this block until a real scenario is added
end


--@api-stub: LScatterPlot:setXRange
do
    -- TODO: example for LScatterPlot:setXRange
    -- keep this block until a real scenario is added
end


--@api-stub: LScatterPlot:setYRange
do
    -- TODO: example for LScatterPlot:setYRange
    -- keep this block until a real scenario is added
end


--@api-stub: LScatterPlot:setXLabel
do
    -- TODO: example for LScatterPlot:setXLabel
    -- keep this block until a real scenario is added
end


--@api-stub: LScatterPlot:setYLabel
do
    -- TODO: example for LScatterPlot:setYLabel
    -- keep this block until a real scenario is added
end


--@api-stub: LScatterPlot:setXTickCount
do
    -- TODO: example for LScatterPlot:setXTickCount
    -- keep this block until a real scenario is added
end


--@api-stub: LScatterPlot:setYTickCount
do
    -- TODO: example for LScatterPlot:setYTickCount
    -- keep this block until a real scenario is added
end


--@api-stub: LScatterPlot:setShowLegend
do
    -- TODO: example for LScatterPlot:setShowLegend
    -- keep this block until a real scenario is added
end


--@api-stub: LScatterPlot:renderImage
do
    -- TODO: example for LScatterPlot:renderImage
    -- keep this block until a real scenario is added
end


--@api-stub: LScatterPlot:drawToImage
do
    -- TODO: example for LScatterPlot:drawToImage
    -- keep this block until a real scenario is added
end


--@api-stub: LScatterPlot:draw
do
    -- TODO: example for LScatterPlot:draw
    -- keep this block until a real scenario is added
end


--@api-stub: LScatterPlot:nearest
do
    -- TODO: example for LScatterPlot:nearest
    -- keep this block until a real scenario is added
end


--@api-stub: LScatterPlot:type
do
    -- TODO: example for LScatterPlot:type
    -- keep this block until a real scenario is added
end


--@api-stub: LScatterPlot:typeOf
do
    -- TODO: example for LScatterPlot:typeOf
    -- keep this block until a real scenario is added
end

