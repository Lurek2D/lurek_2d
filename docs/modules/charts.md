# Charts

## Summary

- Lets users render runtime charts directly inside the engine for telemetry, balancing, and player-facing dashboards.
- Converts raw Lua series and table-like data into ready-to-display RGBA images without external plotting tools.
- Supports line, bar, area, scatter, pie, histogram, and heatmap workflows so teams can choose the right visual grammar per metric.
- Helps debug progression, economy, and performance trends during live sessions instead of offline exports.
- Exposes chart titles, sizing, and palette controls for fast integration into HUD or debug overlays.
- Handles value-range mapping and coordinate transforms so scripts can focus on data, not pixel math.
- Works well for static snapshots and repeated redraws in tooling panels.
- Bridges DataFrame-style analytics output with immediate visual interpretation.
- Adds streaming windows, nearest-point queries, and direct draw/image bridges for interactive dashboard use.
- Covers distribution analysis and matrix-style ML views without forcing scripts to leave the engine.
- Reduces friction for QA and designers who need quick, embedded diagnostic visuals.
- Keeps chart generation deterministic and portable because it runs on CPU-side rasterization.
- Serves as the in-engine visualization surface for numeric storytelling and runtime observability.
- Helps turn raw counters into actionable feedback for tuning gameplay systems.
- Gives projects a practical path from data collection to readable visual output in one module.

This module primarily collaborates with `color`, `dataframe`, `image`. Its responsibility should stay inside the `Feature Systems` group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.charts.defaultPalette`

Default palette.

```lua
lurek.charts.defaultPalette()
```

**Example**

```lua
do
    local pal = lurek.charts.defaultPalette()
    print("palette colors = " .. #pal)
    if #pal > 0 then
        print("first color r=" .. string.format("%.2f", pal[1][1]))
    end
end
```

---

### `lurek.charts.newArea`

New area.

```lua
lurek.charts.newArea(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 400, height = 300, title = "Cumulative Users" })
    print("area chart created = " .. tostring(chart ~= nil))
    print("area chart width = " .. tostring(chart:getWidth()))
end
```

---

### `lurek.charts.newBar`

New bar.

```lua
lurek.charts.newBar(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 400, height = 300, title = "Revenue by Category" })
    print("bar chart created = " .. tostring(chart ~= nil))
    print("bar chart height = " .. tostring(chart:getHeight()))
end
```

---

### `lurek.charts.newHeatmap`

New heatmap.

```lua
lurek.charts.newHeatmap(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180, title = "Region Load" })
    chart:setMatrix({ { 2, 4 }, { 6, 8 } }, { "North", "South" }, { "Q1", "Q2" })
    print("heatmap type = " .. chart:type())
    print("heatmap height = " .. chart:getHeight())
end
```

---

### `lurek.charts.newHistogram`

New histogram.

```lua
lurek.charts.newHistogram(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180, title = "Response Times" })
    chart:addSeries("ms", { 14, 18, 22, 18, 15, 21, 29, 18 })
    print("histogram type = " .. chart:type())
    print("histogram width = " .. chart:getWidth())
end
```

---

### `lurek.charts.newLine`

New line.

```lua
lurek.charts.newLine(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 400, height = 300, title = "Monthly Sales" })
    print("line chart created = " .. tostring(chart ~= nil))
    print("line chart width = " .. tostring(chart:getWidth()))
end
```

---

### `lurek.charts.newPie`

New pie.

```lua
lurek.charts.newPie(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newPie({ width = 300, height = 300, title = "Market Share" })
    print("pie chart created = " .. tostring(chart ~= nil))
    print("pie height = " .. tostring(chart:getHeight()))
end
```

---

### `lurek.charts.newScatter`

New scatter.

```lua
lurek.charts.newScatter(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300, title = "Test Scores" })
    print("scatter plot created = " .. tostring(chart ~= nil))
    print("scatter width = " .. tostring(chart:getWidth()))
end
```

---

### `lurek.charts.seriesColor`

Series color.

```lua
lurek.charts.seriesColor(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | any |  |

**Example**

```lua
do
    local c = lurek.charts.seriesColor(1)
    print("series 1 color r=" .. string.format("%.2f", c[1]) .. " g=" .. string.format("%.2f", c[2]) .. " b=" .. string.format("%.2f", c[3]))
    print("series 1 alpha=" .. string.format("%.2f", c[4]))
end
```

---

## Module Fields

*No module-level fields documented.*

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## Types

- [LAreaChart](#lareachart)
- [LBarChart](#lbarchart)
- [LHeatmapChart](#lheatmapchart)
- [LHistogramChart](#lhistogramchart)
- [LLineChart](#llinechart)
- [LPieChart](#lpiechart)
- [LScatterPlot](#lscatterplot)

## LAreaChart

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LAreaChart:addLayer`

Adds one filled area layer from a numeric value list.

```lua
LAreaChart:addLayer(name, values, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |
| `values` | any |  |
| `color?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 320, height = 180, title = "Area Layers" })
    chart:addLayer("north", { 10, 14, 18, 20 })
    print("added layer north")
    print("width = " .. chart:getWidth())
end
```

---

#### `LAreaChart:addLayerFromDataFrame`

Builds one filled area layer from a dataframe value column.

```lua
LAreaChart:addLayerFromDataFrame()
```

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    local df = charts_df()
    local added = chart:addLayerFromDataFrame("north", df, "north")
    print("rows added = " .. tostring(added))
    print("height = " .. chart:getHeight())
end
```

---

#### `LAreaChart:addSeries`

Adds a named area series from an array-style Lua table of points.

```lua
LAreaChart:addSeries(name, data, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |
| `data` | any |  |
| `color?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    chart:addSeries("series1", { {1, 1}, {2, 3}, {3, 2}, {4, 5}, {5, 4} })
    print("LAreaChart:addSeries ok")
    print("width = " .. tostring(chart:getWidth()))
end
```

---

#### `LAreaChart:appendPoint`

Appends one finite point to a named area series.

```lua
LAreaChart:appendPoint(name, x, y, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |
| `x` | any |  |
| `y` | any |  |
| `color?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:addSeries("trend", { { 1, 12 }, { 2, 16 } })
    chart:appendPoint("trend", 3, 21)
    local _, _, pixels = chart:render()
    print("append point pixels = " .. #pixels)
end
```

---

#### `LAreaChart:clear`

Clears the state.

```lua
LAreaChart:clear()
```

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 1}, {2, 2}, {3, 3} })
    chart:clear()
    local w, h, pixels = chart:render()
    print("LAreaChart:clear ok")
    print("render bytes = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end
```

---

#### `LAreaChart:draw`

Draws the area chart at world or screen coordinates using optional transform options.

```lua
LAreaChart:draw(x, y, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `opts?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 256, height = 128 })
    chart:addLayer("north", { 5, 6, 9, 12 })
    chart:draw(24, 16, {})
    print("draw call issued")
    print("area type = " .. chart:type())
end
```

---

#### `LAreaChart:drawToImage`

Draw to image.

```lua
LAreaChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 256, height = 128 })
    local target = chart_target_image(256, 128)
    chart:addLayer("north", { 5, 6, 9, 12 })
    chart:drawToImage(target)
    print("target size = " .. target:getWidth() .. "x" .. target:getHeight())
end
```

---

#### `LAreaChart:getHeight`

Returns the height.

```lua
LAreaChart:getHeight()
```

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    print("LAreaChart:getHeight=" .. chart:getHeight())
    print("LAreaChart:getWidth=" .. chart:getWidth())
end
```

---

#### `LAreaChart:getWidth`

Returns the width.

```lua
LAreaChart:getWidth()
```

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    print("LAreaChart:getWidth=" .. chart:getWidth())
    print("LAreaChart:getHeight=" .. chart:getHeight())
end
```

---

#### `LAreaChart:render`

Render.

```lua
LAreaChart:render()
```

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 5}, {2, 3}, {3, 8}, {4, 2}, {5, 6} })
    local w, h, pixels = chart:render()
    print("LAreaChart:render ok")
    print("pixels = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end
```

---

#### `LAreaChart:renderImage`

Render image.

```lua
LAreaChart:renderImage()
```

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 256, height = 128 })
    chart:addLayer("north", { 5, 6, 9, 12 })
    local img = chart:renderImage()
    print("render image type = " .. img:type())
    print("render image size = " .. img:getWidth() .. "x" .. img:getHeight())
end
```

---

#### `LAreaChart:setShowLegend`

Sets the show legend.

```lua
LAreaChart:setShowLegend(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:addLayer("north", { 5, 6, 7, 8 })
    chart:addLayer("south", { 4, 5, 5, 6 })
    chart:setShowLegend(true)
    local _, _, pixels = chart:render()
    print("legend bytes = " .. #pixels)
end
```

---

#### `LAreaChart:setTitle`

Sets the title.

```lua
LAreaChart:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    chart:setTitle("Monthly Sales")
    print("LAreaChart:setTitle ok")
    print("height = " .. tostring(chart:getHeight()))
end
```

---

#### `LAreaChart:setWindow`

Sets the window.

```lua
LAreaChart:setWindow(max_points)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `max_points?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:addSeries("trend", { { 1, 8 }, { 2, 12 }, { 3, 15 }, { 4, 19 } })
    chart:setWindow(2)
    local _, _, pixels = chart:render()
    print("windowed render bytes = " .. #pixels)
end
```

---

#### `LAreaChart:setXLabel`

Sets the x label.

```lua
LAreaChart:setXLabel(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:setXLabel("Month")
    chart:setYLabel("Users")
    local _, _, pixels = chart:render()
    print("labeled area bytes = " .. #pixels)
end
```

---

#### `LAreaChart:setXTickCount`

Sets the x tick count.

```lua
LAreaChart:setXTickCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:setXTickCount(5)
    chart:addLayer("api", { 3, 5, 8, 13 })
    local _, _, pixels = chart:render()
    print("x ticks bytes = " .. #pixels)
end
```

---

#### `LAreaChart:setYLabel`

Sets the y label.

```lua
LAreaChart:setYLabel(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:setYLabel("Requests")
    chart:addLayer("api", { 3, 5, 8, 13 })
    local _, _, pixels = chart:render()
    print("area label bytes = " .. #pixels)
end
```

---

#### `LAreaChart:setYMax`

Sets the y max.

```lua
LAreaChart:setYMax(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:addSeries("trend", { { 1, 8 }, { 2, 12 }, { 3, 15 } })
    chart:setYMax(20)
    print("manual y max applied")
    print("type = " .. chart:type())
end
```

---

#### `LAreaChart:setYTickCount`

Sets the y tick count.

```lua
LAreaChart:setYTickCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:setYTickCount(6)
    chart:addLayer("api", { 3, 5, 8, 13 })
    local _, _, pixels = chart:render()
    print("y ticks bytes = " .. #pixels)
end
```

---

#### `LAreaChart:type`

Type.

```lua
LAreaChart:type()
```

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 256, height = 128 })
    print("type = " .. chart:type())
    print("is object = " .. tostring(chart:typeOf("LObject")))
end
```

---

#### `LAreaChart:typeOf`

Type of.

```lua
LAreaChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 256, height = 128 })
    print("typeOf LAreaChart = " .. tostring(chart:typeOf("LAreaChart")))
    print("typeOf LBarChart = " .. tostring(chart:typeOf("LBarChart")))
end
```

---

## LBarChart

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LBarChart:addCategoriesFromDataFrame`

Adds grouped bar categories by reading one label column and one or more value columns from a dataframe.

```lua
LBarChart:addCategoriesFromDataFrame()
```

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 320, height = 180 })
    local df = charts_df()
    local added = chart:addCategoriesFromDataFrame(df, "label", { "north", "south", "east" })
    print("categories added = " .. tostring(added))
    print("height = " .. chart:getHeight())
end
```

---

#### `LBarChart:addCategory`

Adds one category label with a numeric value list for grouped bars.

```lua
LBarChart:addCategory(label, values)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | any |  |
| `values` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 320, height = 180 })
    chart:addCategory("Q1", { 12, 8, 5 })
    chart:addCategory("Q2", { 18, 11, 7 })
    local _, _, pixels = chart:render()
    print("categories bytes = " .. #pixels)
end
```

---

#### `LBarChart:addSeries`

Adds a named bar series from an array-style Lua table of values or points.

```lua
LBarChart:addSeries(name, data, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |
| `data` | any |  |
| `color?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:addSeries("series1", { {1, 1}, {2, 3}, {3, 2}, {4, 5}, {5, 4} })
    print("LBarChart:addSeries ok")
    print("height = " .. tostring(chart:getHeight()))
end
```

---

#### `LBarChart:clear`

Clears the state.

```lua
LBarChart:clear()
```

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 1}, {2, 2}, {3, 3} })
    chart:clear()
    local w, h, pixels = chart:render()
    print("LBarChart:clear ok")
    print("render bytes = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end
```

---

#### `LBarChart:draw`

Draws the bar chart at world or screen coordinates using optional transform options.

```lua
LBarChart:draw(x, y, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `opts?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 256, height = 128 })
    chart:addCategory("Q1", { 12, 8, 5 })
    chart:draw(12, 8, {})
    print("bar draw issued")
    print("bar type = " .. chart:type())
end
```

---

#### `LBarChart:drawToImage`

Draw to image.

```lua
LBarChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 256, height = 128 })
    local target = chart_target_image(256, 128)
    chart:addCategory("Q1", { 12, 8, 5 })
    chart:drawToImage(target)
    print("bar target bytes = " .. target:getWidth() .. "x" .. target:getHeight())
end
```

---

#### `LBarChart:getHeight`

Returns the height.

```lua
LBarChart:getHeight()
```

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    print("LBarChart:getHeight=" .. chart:getHeight())
    print("LBarChart:getWidth=" .. chart:getWidth())
end
```

---

#### `LBarChart:getWidth`

Returns the width.

```lua
LBarChart:getWidth()
```

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    print("LBarChart:getWidth=" .. chart:getWidth())
    print("LBarChart:getHeight=" .. chart:getHeight())
end
```

---

#### `LBarChart:render`

Render.

```lua
LBarChart:render()
```

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 5}, {2, 3}, {3, 8}, {4, 2}, {5, 6} })
    local w, h, pixels = chart:render()
    print("LBarChart:render ok")
    print("pixels = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end
```

---

#### `LBarChart:renderImage`

Render image.

```lua
LBarChart:renderImage()
```

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 256, height = 128 })
    chart:addCategory("Q1", { 12, 8, 5 })
    local img = chart:renderImage()
    print("bar image type = " .. img:type())
    print("bar image size = " .. img:getWidth() .. "x" .. img:getHeight())
end
```

---

#### `LBarChart:setBarWidth`

Sets the bar width.

```lua
LBarChart:setBarWidth(width)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:setBarWidth(20.0)
    print("LBarChart:setBarWidth ok")
    print("chart width = " .. tostring(chart:getWidth()))
end
```

---

#### `LBarChart:setShowLegend`

Sets the show legend.

```lua
LBarChart:setShowLegend(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 320, height = 180 })
    chart:addCategory("Q1", { 12, 8, 5 })
    chart:addCategory("Q2", { 18, 11, 7 })
    chart:setShowLegend(true)
    local _, _, pixels = chart:render()
    print("bar legend bytes = " .. #pixels)
end
```

---

#### `LBarChart:setTitle`

Sets the title.

```lua
LBarChart:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:setTitle("Monthly Sales")
    print("LBarChart:setTitle ok")
    print("chart height = " .. tostring(chart:getHeight()))
end
```

---

#### `LBarChart:setXLabel`

Sets the x label.

```lua
LBarChart:setXLabel(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 320, height = 180 })
    chart:setXLabel("Quarter")
    chart:addCategory("Q1", { 12, 8, 5 })
    local _, _, pixels = chart:render()
    print("bar x label bytes = " .. #pixels)
end
```

---

#### `LBarChart:setXTickCount`

Sets the x tick count.

```lua
LBarChart:setXTickCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 320, height = 180 })
    chart:setXTickCount(4)
    chart:addCategory("Q1", { 12, 8, 5 })
    chart:addCategory("Q2", { 18, 11, 7 })
    local _, _, pixels = chart:render()
    print("bar x ticks bytes = " .. #pixels)
end
```

---

#### `LBarChart:setYLabel`

Sets the y label.

```lua
LBarChart:setYLabel(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 320, height = 180 })
    chart:setYLabel("Sales")
    chart:addCategory("Q1", { 12, 8, 5 })
    local _, _, pixels = chart:render()
    print("bar y label bytes = " .. #pixels)
end
```

---

#### `LBarChart:setYTickCount`

Sets the y tick count.

```lua
LBarChart:setYTickCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 320, height = 180 })
    chart:setYTickCount(6)
    chart:addCategory("Q1", { 12, 8, 5 })
    chart:addCategory("Q2", { 18, 11, 7 })
    local _, _, pixels = chart:render()
    print("bar y ticks bytes = " .. #pixels)
end
```

---

#### `LBarChart:type`

Type.

```lua
LBarChart:type()
```

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 256, height = 128 })
    print("type = " .. chart:type())
    print("object = " .. tostring(chart:typeOf("LObject")))
end
```

---

#### `LBarChart:typeOf`

Type of.

```lua
LBarChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 256, height = 128 })
    print("typeOf LBarChart = " .. tostring(chart:typeOf("LBarChart")))
    print("typeOf LAreaChart = " .. tostring(chart:typeOf("LAreaChart")))
end
```

---

## LHeatmapChart

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LHeatmapChart:clear`

Clears the state.

```lua
LHeatmapChart:clear()
```

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    chart:clear()
    local _, _, pixels = chart:render()
    print("cleared heatmap bytes = " .. #pixels)
end
```

---

#### `LHeatmapChart:clearValueRange`

Clears value range.

```lua
LHeatmapChart:clearValueRange()
```

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:setValueRange(0, 10)
    chart:clearValueRange()
    local _, _, pixels = chart:render()
    print("cleared range bytes = " .. #pixels)
end
```

---

#### `LHeatmapChart:draw`

Draws the heatmap at world or screen coordinates using optional transform options.

```lua
LHeatmapChart:draw(x, y, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `opts?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 256, height = 128 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:draw(18, 10, {})
    print("heatmap draw issued")
    print("heatmap type = " .. chart:type())
end
```

---

#### `LHeatmapChart:drawToImage`

Draw to image.

```lua
LHeatmapChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 256, height = 128 })
    local target = chart_target_image(256, 128)
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:drawToImage(target)
    print("heatmap target width = " .. target:getWidth())
end
```

---

#### `LHeatmapChart:getHeight`

Returns the height.

```lua
LHeatmapChart:getHeight()
```

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 333, height = 144 })
    print("height = " .. chart:getHeight())
    print("width = " .. chart:getWidth())
end
```

---

#### `LHeatmapChart:getWidth`

Returns the width.

```lua
LHeatmapChart:getWidth()
```

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 333, height = 144 })
    print("width = " .. chart:getWidth())
    print("height = " .. chart:getHeight())
end
```

---

#### `LHeatmapChart:render`

Render.

```lua
LHeatmapChart:render()
```

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    local w, h, pixels = chart:render()
    print("render size = " .. w .. "x" .. h)
    print("render bytes = " .. #pixels)
end
```

---

#### `LHeatmapChart:renderImage`

Render image.

```lua
LHeatmapChart:renderImage()
```

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 256, height = 128 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    local img = chart:renderImage()
    print("heatmap image type = " .. img:type())
    print("heatmap image width = " .. img:getWidth())
end
```

---

#### `LHeatmapChart:resize`

Resize.

```lua
LHeatmapChart:resize(rows, cols)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `rows` | any |  |
| `cols` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:resize(3, 2)
    chart:setCell(1, 1, 1.5)
    chart:setCell(3, 2, 4.5)
    local _, _, pixels = chart:render()
    print("resized heatmap bytes = " .. #pixels)
end
```

---

#### `LHeatmapChart:setCell`

Sets the cell.

```lua
LHeatmapChart:setCell(row, col, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `row` | any |  |
| `col` | any |  |
| `value` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:resize(2, 2)
    chart:setCell(1, 1, 2.5)
    chart:setCell(2, 2, 7.5)
    local _, _, pixels = chart:render()
    print("heatmap cell bytes = " .. #pixels)
end
```

---

#### `LHeatmapChart:setColorRange`

Sets the low and high RGBA colors used for the heatmap gradient.

```lua
LHeatmapChart:setColorRange(low, high)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `low` | any |  |
| `high` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:setColorRange({ 0.10, 0.20, 0.60, 1.0 }, { 0.90, 0.20, 0.10, 1.0 })
    local _, _, pixels = chart:render()
    print("color range bytes = " .. #pixels)
end
```

---

#### `LHeatmapChart:setColumnLabels`

Sets the column labels.

```lua
LHeatmapChart:setColumnLabels(labels)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `labels` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:setColumnLabels({ "Q1", "Q2" })
    local _, _, pixels = chart:render()
    print("column labels bytes = " .. #pixels)
end
```

---

#### `LHeatmapChart:setMatrix`

Replaces the heatmap contents from a numeric matrix with optional row and column labels.

```lua
LHeatmapChart:setMatrix(matrix, row_labels, col_labels)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `matrix` | any |  |
| `row_labels?` | any |  |
| `col_labels?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    local _, _, pixels = chart:render()
    print("heatmap matrix bytes = " .. #pixels)
end
```

---

#### `LHeatmapChart:setMatrixFromDataFrame`

Builds the heatmap contents from dataframe row, column, and value fields.

```lua
LHeatmapChart:setMatrixFromDataFrame()
```

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    local df = charts_df()
    local cells = chart:setMatrixFromDataFrame(df, "row", "col", "value")
    print("matrix cells = " .. tostring(cells))
    print("width = " .. chart:getWidth())
end
```

---

#### `LHeatmapChart:setRowLabels`

Sets the row labels.

```lua
LHeatmapChart:setRowLabels(labels)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `labels` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:setRowLabels({ "North", "South" })
    local _, _, pixels = chart:render()
    print("row labels bytes = " .. #pixels)
end
```

---

#### `LHeatmapChart:setShowLegend`

Sets the show legend.

```lua
LHeatmapChart:setShowLegend(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:setShowLegend(true)
    local _, _, pixels = chart:render()
    print("heatmap legend bytes = " .. #pixels)
end
```

---

#### `LHeatmapChart:setShowValues`

Sets the show values.

```lua
LHeatmapChart:setShowValues(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:setShowValues(true)
    local _, _, pixels = chart:render()
    print("show values bytes = " .. #pixels)
end
```

---

#### `LHeatmapChart:setTitle`

Sets the title.

```lua
LHeatmapChart:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setTitle("Throughput Grid")
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    local _, _, pixels = chart:render()
    print("heatmap title bytes = " .. #pixels)
end
```

---

#### `LHeatmapChart:setValueRange`

Sets the value range.

```lua
LHeatmapChart:setValueRange(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | any |  |
| `max` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:setValueRange(0, 10)
    local _, _, pixels = chart:render()
    print("value range bytes = " .. #pixels)
end
```

---

#### `LHeatmapChart:type`

Type.

```lua
LHeatmapChart:type()
```

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    print("type = " .. chart:type())
    print("object = " .. tostring(chart:typeOf("LObject")))
end
```

---

#### `LHeatmapChart:typeOf`

Type of.

```lua
LHeatmapChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    print("typeOf LHeatmapChart = " .. tostring(chart:typeOf("LHeatmapChart")))
    print("typeOf LPieChart = " .. tostring(chart:typeOf("LPieChart")))
end
```

---

## LHistogramChart

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LHistogramChart:addSeries`

Adds a named histogram sample series from a numeric value list.

```lua
LHistogramChart:addSeries(name, values, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |
| `values` | any |  |
| `color?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 18, 22, 25, 18 })
    local _, _, pixels = chart:render()
    print("histogram bytes = " .. #pixels)
end
```

---

#### `LHistogramChart:addSeriesFromDataFrame`

Builds a named histogram sample series from one dataframe value column.

```lua
LHistogramChart:addSeriesFromDataFrame()
```

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    local df = charts_df()
    local added = chart:addSeriesFromDataFrame("north", df, "north")
    print("histogram rows added = " .. tostring(added))
    print("width = " .. chart:getWidth())
end
```

---

#### `LHistogramChart:appendValue`

Appends one finite numeric sample to a named histogram series.

```lua
LHistogramChart:appendValue(name, value, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |
| `value` | any |  |
| `color?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18 })
    chart:appendValue("response", 21)
    local _, _, pixels = chart:render()
    print("append histogram bytes = " .. #pixels)
end
```

---

#### `LHistogramChart:clear`

Clears the state.

```lua
LHistogramChart:clear()
```

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18 })
    chart:clear()
    local _, _, pixels = chart:render()
    print("cleared histogram bytes = " .. #pixels)
end
```

---

#### `LHistogramChart:clearRange`

Clears range.

```lua
LHistogramChart:clearRange()
```

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    chart:setRange(10, 30)
    chart:clearRange()
    local _, _, pixels = chart:render()
    print("clear range histogram bytes = " .. #pixels)
end
```

---

#### `LHistogramChart:draw`

Draws the histogram at world or screen coordinates using optional transform options.

```lua
LHistogramChart:draw(x, y, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `opts?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 256, height = 128 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    chart:draw(16, 8, {})
    print("histogram draw issued")
    print("histogram type = " .. chart:type())
end
```

---

#### `LHistogramChart:drawToImage`

Draw to image.

```lua
LHistogramChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 256, height = 128 })
    local target = chart_target_image(256, 128)
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    chart:drawToImage(target)
    print("histogram target width = " .. target:getWidth())
end
```

---

#### `LHistogramChart:getHeight`

Returns the height.

```lua
LHistogramChart:getHeight()
```

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 345, height = 176 })
    print("height = " .. chart:getHeight())
    print("width = " .. chart:getWidth())
end
```

---

#### `LHistogramChart:getWidth`

Returns the width.

```lua
LHistogramChart:getWidth()
```

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 345, height = 176 })
    print("width = " .. chart:getWidth())
    print("height = " .. chart:getHeight())
end
```

---

#### `LHistogramChart:render`

Render.

```lua
LHistogramChart:render()
```

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    local w, h, pixels = chart:render()
    print("histogram size = " .. w .. "x" .. h)
    print("histogram bytes = " .. #pixels)
end
```

---

#### `LHistogramChart:renderImage`

Render image.

```lua
LHistogramChart:renderImage()
```

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 256, height = 128 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    local img = chart:renderImage()
    print("histogram image type = " .. img:type())
    print("histogram image width = " .. img:getWidth())
end
```

---

#### `LHistogramChart:replaceSeries`

Replaces a named histogram sample series with a new numeric value list.

```lua
LHistogramChart:replaceSeries(name, values, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |
| `values` | any |  |
| `color?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18 })
    chart:replaceSeries("response", { 30, 28, 26, 24 })
    local _, _, pixels = chart:render()
    print("replaced histogram bytes = " .. #pixels)
end
```

---

#### `LHistogramChart:setBinCount`

Sets the bin count.

```lua
LHistogramChart:setBinCount(bins)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bins` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    chart:setBinCount(5)
    local _, _, pixels = chart:render()
    print("bins histogram bytes = " .. #pixels)
end
```

---

#### `LHistogramChart:setDensity`

Sets the density.

```lua
LHistogramChart:setDensity(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    chart:setDensity(true)
    local _, _, pixels = chart:render()
    print("density histogram bytes = " .. #pixels)
end
```

---

#### `LHistogramChart:setRange`

Sets the range.

```lua
LHistogramChart:setRange(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | any |  |
| `max` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    chart:setRange(10, 30)
    local _, _, pixels = chart:render()
    print("range histogram bytes = " .. #pixels)
end
```

---

#### `LHistogramChart:setShowLegend`

Sets the show legend.

```lua
LHistogramChart:setShowLegend(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("north", { 12, 14, 18, 21 })
    chart:addSeries("south", { 9, 10, 11, 15 })
    chart:setShowLegend(true)
    local _, _, pixels = chart:render()
    print("histogram legend bytes = " .. #pixels)
end
```

---

#### `LHistogramChart:setTitle`

Sets the title.

```lua
LHistogramChart:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:setTitle("Response Times")
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    local _, _, pixels = chart:render()
    print("histogram title bytes = " .. #pixels)
end
```

---

#### `LHistogramChart:setWindow`

Sets the window.

```lua
LHistogramChart:setWindow(max_points)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `max_points?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    chart:setWindow(4)
    local _, _, pixels = chart:render()
    print("window histogram bytes = " .. #pixels)
end
```

---

#### `LHistogramChart:setXLabel`

Sets the x label.

```lua
LHistogramChart:setXLabel(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:setXLabel("Latency")
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    local _, _, pixels = chart:render()
    print("histogram x label bytes = " .. #pixels)
end
```

---

#### `LHistogramChart:setXTickCount`

Sets the x tick count.

```lua
LHistogramChart:setXTickCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:setXTickCount(5)
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    local _, _, pixels = chart:render()
    print("histogram x ticks bytes = " .. #pixels)
end
```

---

#### `LHistogramChart:setYLabel`

Sets the y label.

```lua
LHistogramChart:setYLabel(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:setYLabel("Frequency")
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    local _, _, pixels = chart:render()
    print("histogram y label bytes = " .. #pixels)
end
```

---

#### `LHistogramChart:setYTickCount`

Sets the y tick count.

```lua
LHistogramChart:setYTickCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:setYTickCount(6)
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    local _, _, pixels = chart:render()
    print("histogram y ticks bytes = " .. #pixels)
end
```

---

#### `LHistogramChart:type`

Type.

```lua
LHistogramChart:type()
```

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    print("type = " .. chart:type())
    print("object = " .. tostring(chart:typeOf("LObject")))
end
```

---

#### `LHistogramChart:typeOf`

Type of.

```lua
LHistogramChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    print("typeOf LHistogramChart = " .. tostring(chart:typeOf("LHistogramChart")))
    print("typeOf LLineChart = " .. tostring(chart:typeOf("LLineChart")))
end
```

---

## LLineChart

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LLineChart:addSeries`

Adds a named line series from an array-style Lua table of points.

```lua
LLineChart:addSeries(name, data, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |
| `data` | any |  |
| `color?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:addSeries("series1", { {1, 1}, {2, 3}, {3, 2}, {4, 5}, {5, 4} })
    print("LLineChart:addSeries ok")
    print("width = " .. tostring(chart:getWidth()))
end
```

---

#### `LLineChart:addSeriesFromDataFrame`

Builds a named line series from x and y columns in a dataframe.

```lua
LLineChart:addSeriesFromDataFrame()
```

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    local df = charts_df()
    local added = chart:addSeriesFromDataFrame("north", df, "month", "north")
    print("line rows added = " .. tostring(added))
    print("width = " .. chart:getWidth())
end
```

---

#### `LLineChart:appendPoint`

Appends one finite point to a named line series.

```lua
LLineChart:appendPoint(name, x, y, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |
| `x` | any |  |
| `y` | any |  |
| `color?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 } })
    chart:appendPoint("north", 3, 15)
    local _, _, pixels = chart:render()
    print("line append bytes = " .. #pixels)
end
```

---

#### `LLineChart:clear`

Clears the state.

```lua
LLineChart:clear()
```

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 1}, {2, 2}, {3, 3} })
    chart:clear()
    local w, h, pixels = chart:render()
    print("LLineChart:clear ok")
    print("render bytes = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end
```

---

#### `LLineChart:draw`

Draws the line chart at world or screen coordinates using optional transform options.

```lua
LLineChart:draw(x, y, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `opts?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 256, height = 128 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:draw(20, 12, {})
    print("line draw issued")
    print("line type = " .. chart:type())
end
```

---

#### `LLineChart:drawToImage`

Draw to image.

```lua
LLineChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 256, height = 128 })
    local target = chart_target_image(256, 128)
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:drawToImage(target)
    print("line target width = " .. target:getWidth())
end
```

---

#### `LLineChart:getHeight`

Returns the height.

```lua
LLineChart:getHeight()
```

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    print("LLineChart:getHeight=" .. chart:getHeight())
    print("LLineChart:getWidth=" .. chart:getWidth())
end
```

---

#### `LLineChart:getWidth`

Returns the width.

```lua
LLineChart:getWidth()
```

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    print("LLineChart:getWidth=" .. chart:getWidth())
    print("LLineChart:getHeight=" .. chart:getHeight())
end
```

---

#### `LLineChart:nearest`

Nearest.

```lua
LLineChart:nearest(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local hit = chart:nearest(120, 80)
    print("line nearest found = " .. tostring(hit ~= nil))
    print("line nearest series = " .. tostring(hit and hit.series))
end
```

---

#### `LLineChart:render`

Render.

```lua
LLineChart:render()
```

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 5}, {2, 3}, {3, 8}, {4, 2}, {5, 6} })
    local w, h, pixels = chart:render()
    print("LLineChart:render ok")
    print("pixels = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end
```

---

#### `LLineChart:renderImage`

Render image.

```lua
LLineChart:renderImage()
```

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 256, height = 128 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local img = chart:renderImage()
    print("line image type = " .. img:type())
    print("line image width = " .. img:getWidth())
end
```

---

#### `LLineChart:replaceSeries`

Replaces a named line series with a new array-style Lua table of points.

```lua
LLineChart:replaceSeries(name, data, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |
| `data` | any |  |
| `color?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 } })
    chart:replaceSeries("north", { { 1, 9 }, { 2, 11 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    print("line replace bytes = " .. #pixels)
end
```

---

#### `LLineChart:setShowLegend`

Sets the show legend.

```lua
LLineChart:setShowLegend(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:addSeries("south", { { 1, 8 }, { 2, 11 }, { 3, 16 } })
    chart:setShowLegend(true)
    local _, _, pixels = chart:render()
    print("line legend bytes = " .. #pixels)
end
```

---

#### `LLineChart:setTitle`

Sets the title.

```lua
LLineChart:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:setTitle("Monthly Sales")
    print("LLineChart:setTitle ok")
    print("height = " .. tostring(chart:getHeight()))
end
```

---

#### `LLineChart:setWindow`

Sets the window.

```lua
LLineChart:setWindow(max_points)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `max_points?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 }, { 4, 24 } })
    chart:setWindow(2)
    local _, _, pixels = chart:render()
    print("line window bytes = " .. #pixels)
end
```

---

#### `LLineChart:setXLabel`

Sets the x label.

```lua
LLineChart:setXLabel(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:setXLabel("Month")
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    print("line x label bytes = " .. #pixels)
end
```

---

#### `LLineChart:setXMax`

Sets the x max.

```lua
LLineChart:setXMax(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setXMax(6)
    local _, _, pixels = chart:render()
    print("line x max bytes = " .. #pixels)
end
```

---

#### `LLineChart:setXTickCount`

Sets the x tick count.

```lua
LLineChart:setXTickCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:setXTickCount(5)
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    print("line x ticks bytes = " .. #pixels)
end
```

---

#### `LLineChart:setYLabel`

Sets the y label.

```lua
LLineChart:setYLabel(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:setYLabel("Users")
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    print("line y label bytes = " .. #pixels)
end
```

---

#### `LLineChart:setYMax`

Sets the y max.

```lua
LLineChart:setYMax(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setYMax(30)
    local _, _, pixels = chart:render()
    print("line y max bytes = " .. #pixels)
end
```

---

#### `LLineChart:setYTickCount`

Sets the y tick count.

```lua
LLineChart:setYTickCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:setYTickCount(6)
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    print("line y ticks bytes = " .. #pixels)
end
```

---

#### `LLineChart:type`

Type.

```lua
LLineChart:type()
```

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 256, height = 128 })
    print("type = " .. chart:type())
    print("object = " .. tostring(chart:typeOf("LObject")))
end
```

---

#### `LLineChart:typeOf`

Type of.

```lua
LLineChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 256, height = 128 })
    print("typeOf LLineChart = " .. tostring(chart:typeOf("LLineChart")))
    print("typeOf LAreaChart = " .. tostring(chart:typeOf("LAreaChart")))
end
```

---

## LPieChart

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LPieChart:addSegment`

Adds one pie segment with a non-negative value.

```lua
LPieChart:addSegment(label, value, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | any |  |
| `value` | any |  |
| `color?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newPie({ width = 320, height = 180 })
    chart:addSegment("North", 42, { 0.9, 0.3, 0.2, 1.0 })
    chart:addSegment("South", 33, { 0.2, 0.6, 0.9, 1.0 })
    local _, _, pixels = chart:render()
    print("pie segment bytes = " .. #pixels)
end
```

---

#### `LPieChart:addSegmentsFromDataFrame`

Adds pie segments by reading label and value columns from a dataframe.

```lua
LPieChart:addSegmentsFromDataFrame()
```

**Example**

```lua
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
```

---

#### `LPieChart:addSlice`

Legacy alias that adds one pie slice with a non-negative value.

```lua
LPieChart:addSlice(label, value, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | any |  |
| `value` | any |  |
| `color?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    chart:addSlice("Food", 45.0, { 0.9, 0.3, 0.1, 1.0 })
    chart:addSlice("Transport", 20.0, { 0.2, 0.6, 0.9, 1.0 })
    print("LPieChart:addSlice ok")
    print("width = " .. tostring(chart:getWidth()))
end
```

---

#### `LPieChart:clear`

Clears the state.

```lua
LPieChart:clear()
```

**Example**

```lua
do
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    chart:addSlice("A", 1)
    chart:addSlice("B", 2)
    chart:clear()
    local w, h, pixels = chart:render()
    print("LPieChart:clear ok")
    print("render bytes = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end
```

---

#### `LPieChart:draw`

Draws the pie chart at world or screen coordinates using optional transform options.

```lua
LPieChart:draw(x, y, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `opts?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newPie({ width = 256, height = 128 })
    chart:addSegment("North", 42)
    chart:addSegment("South", 33)
    chart:draw(20, 10, {})
    print("pie draw issued")
    print("pie type = " .. chart:type())
end
```

---

#### `LPieChart:drawToImage`

Draw to image.

```lua
LPieChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newPie({ width = 256, height = 128 })
    local target = chart_target_image(256, 128)
    chart:addSegment("North", 42)
    chart:addSegment("South", 33)
    chart:drawToImage(target)
    print("pie target width = " .. target:getWidth())
end
```

---

#### `LPieChart:getHeight`

Returns the height.

```lua
LPieChart:getHeight()
```

**Example**

```lua
do
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    print("LPieChart:getHeight=" .. chart:getHeight())
    print("LPieChart:getWidth=" .. chart:getWidth())
end
```

---

#### `LPieChart:getWidth`

Returns the width.

```lua
LPieChart:getWidth()
```

**Example**

```lua
do
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    print("LPieChart:getWidth=" .. chart:getWidth())
    print("LPieChart:getHeight=" .. chart:getHeight())
end
```

---

#### `LPieChart:render`

Render.

```lua
LPieChart:render()
```

**Example**

```lua
do
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    chart:addSlice("A", 5)
    chart:addSlice("B", 3)
    chart:addSlice("C", 8)
    local w, h, pixels = chart:render()
    print("LPieChart:render ok")
    print("pixels = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end
```

---

#### `LPieChart:renderImage`

Render image.

```lua
LPieChart:renderImage()
```

**Example**

```lua
do
    local chart = lurek.charts.newPie({ width = 256, height = 128 })
    chart:addSegment("North", 42)
    chart:addSegment("South", 33)
    local img = chart:renderImage()
    print("pie image type = " .. img:type())
    print("pie image width = " .. img:getWidth())
end
```

---

#### `LPieChart:setShowLegend`

Sets the show legend.

```lua
LPieChart:setShowLegend(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newPie({ width = 320, height = 180 })
    chart:addSegment("North", 42)
    chart:addSegment("South", 33)
    chart:setShowLegend(true)
    local _, _, pixels = chart:render()
    print("pie legend bytes = " .. #pixels)
end
```

---

#### `LPieChart:setTitle`

Sets the title.

```lua
LPieChart:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    chart:setTitle("Monthly Sales")
    print("LPieChart:setTitle ok")
    print("height = " .. tostring(chart:getHeight()))
end
```

---

#### `LPieChart:type`

Type.

```lua
LPieChart:type()
```

**Example**

```lua
do
    local chart = lurek.charts.newPie({ width = 256, height = 128 })
    print("type = " .. chart:type())
    print("object = " .. tostring(chart:typeOf("LObject")))
end
```

---

#### `LPieChart:typeOf`

Type of.

```lua
LPieChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newPie({ width = 256, height = 128 })
    print("typeOf LPieChart = " .. tostring(chart:typeOf("LPieChart")))
    print("typeOf LBarChart = " .. tostring(chart:typeOf("LBarChart")))
end
```

---

## LScatterPlot

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LScatterPlot:addSeries`

Adds a named scatter series from an array-style Lua table of points.

```lua
LScatterPlot:addSeries(name, data, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |
| `data` | any |  |
| `color?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:addSeries("series1", { {1, 1}, {2, 3}, {3, 2}, {4, 5}, {5, 4} })
    print("LScatterPlot:addSeries ok")
    print("width = " .. tostring(chart:getWidth()))
end
```

---

#### `LScatterPlot:addSeriesFromDataFrame`

Builds a named scatter series from x and y columns in a dataframe.

```lua
LScatterPlot:addSeriesFromDataFrame()
```

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    local df = charts_df()
    local added = chart:addSeriesFromDataFrame("north", df, "x", "y")
    print("scatter rows added = " .. tostring(added))
    print("scatter width = " .. chart:getWidth())
end
```

---

#### `LScatterPlot:appendPoint`

Appends one finite point to a named scatter series.

```lua
LScatterPlot:appendPoint(name, x, y, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |
| `x` | any |  |
| `y` | any |  |
| `color?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 } })
    chart:appendPoint("north", 3, 15)
    local _, _, pixels = chart:render()
    print("scatter append bytes = " .. #pixels)
end
```

---

#### `LScatterPlot:clear`

Clears the state.

```lua
LScatterPlot:clear()
```

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 1}, {2, 2}, {3, 3} })
    chart:clear()
    local w, h, pixels = chart:render()
    print("LScatterPlot:clear ok")
    print("render bytes = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end
```

---

#### `LScatterPlot:draw`

Draws the scatter plot at world or screen coordinates using optional transform options.

```lua
LScatterPlot:draw(x, y, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `opts?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 256, height = 128 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:draw(20, 10, {})
    print("scatter draw issued")
    print("scatter type = " .. chart:type())
end
```

---

#### `LScatterPlot:drawToImage`

Draw to image.

```lua
LScatterPlot:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 256, height = 128 })
    local target = chart_target_image(256, 128)
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:drawToImage(target)
    print("scatter target width = " .. target:getWidth())
end
```

---

#### `LScatterPlot:getHeight`

Returns the height.

```lua
LScatterPlot:getHeight()
```

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    print("LScatterPlot:getHeight=" .. chart:getHeight())
    print("LScatterPlot:getWidth=" .. chart:getWidth())
end
```

---

#### `LScatterPlot:getWidth`

Returns the width.

```lua
LScatterPlot:getWidth()
```

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    print("LScatterPlot:getWidth=" .. chart:getWidth())
    print("LScatterPlot:getHeight=" .. chart:getHeight())
end
```

---

#### `LScatterPlot:nearest`

Nearest.

```lua
LScatterPlot:nearest(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local hit = chart:nearest(120, 80)
    print("scatter nearest found = " .. tostring(hit ~= nil))
    print("scatter nearest series = " .. tostring(hit and hit.series))
end
```

---

#### `LScatterPlot:render`

Render.

```lua
LScatterPlot:render()
```

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 5}, {2, 3}, {3, 8}, {4, 2}, {5, 6} })
    local w, h, pixels = chart:render()
    print("LScatterPlot:render ok")
    print("pixels = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
end
```

---

#### `LScatterPlot:renderImage`

Render image.

```lua
LScatterPlot:renderImage()
```

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 256, height = 128 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local img = chart:renderImage()
    print("scatter image type = " .. img:type())
    print("scatter image width = " .. img:getWidth())
end
```

---

#### `LScatterPlot:replaceSeries`

Replaces a named scatter series with a new array-style Lua table of points.

```lua
LScatterPlot:replaceSeries(name, data, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |
| `data` | any |  |
| `color?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 } })
    chart:replaceSeries("north", { { 1, 9 }, { 2, 11 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    print("scatter replace bytes = " .. #pixels)
end
```

---

#### `LScatterPlot:setDotRadius`

Sets the dot radius.

```lua
LScatterPlot:setDotRadius(radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `radius` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:setDotRadius(5.0)
    print("LScatterPlot:setDotRadius ok")
    print("height = " .. tostring(chart:getHeight()))
end
```

---

#### `LScatterPlot:setShowLegend`

Sets the show legend.

```lua
LScatterPlot:setShowLegend(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:addSeries("south", { { 1, 8 }, { 2, 11 }, { 3, 16 } })
    chart:setShowLegend(true)
    local _, _, pixels = chart:render()
    print("scatter legend bytes = " .. #pixels)
end
```

---

#### `LScatterPlot:setTitle`

Sets the title.

```lua
LScatterPlot:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:setTitle("Monthly Sales")
    print("LScatterPlot:setTitle ok")
    print("width = " .. tostring(chart:getWidth()))
end
```

---

#### `LScatterPlot:setWindow`

Sets the window.

```lua
LScatterPlot:setWindow(max_points)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `max_points?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 }, { 4, 24 } })
    chart:setWindow(3)
    local _, _, pixels = chart:render()
    print("scatter window bytes = " .. #pixels)
end
```

---

#### `LScatterPlot:setXLabel`

Sets the x label.

```lua
LScatterPlot:setXLabel(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:setXLabel("Hours")
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    print("scatter x label bytes = " .. #pixels)
end
```

---

#### `LScatterPlot:setXRange`

Sets the x range.

```lua
LScatterPlot:setXRange(min_x, max_x)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min_x` | any |  |
| `max_x` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setXRange(0, 6)
    local _, _, pixels = chart:render()
    print("scatter x range bytes = " .. #pixels)
end
```

---

#### `LScatterPlot:setXTickCount`

Sets the x tick count.

```lua
LScatterPlot:setXTickCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:setXTickCount(5)
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    print("scatter x ticks bytes = " .. #pixels)
end
```

---

#### `LScatterPlot:setYLabel`

Sets the y label.

```lua
LScatterPlot:setYLabel(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:setYLabel("Score")
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    print("scatter y label bytes = " .. #pixels)
end
```

---

#### `LScatterPlot:setYRange`

Sets the y range.

```lua
LScatterPlot:setYRange(min_y, max_y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min_y` | any |  |
| `max_y` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setYRange(0, 30)
    local _, _, pixels = chart:render()
    print("scatter y range bytes = " .. #pixels)
end
```

---

#### `LScatterPlot:setYTickCount`

Sets the y tick count.

```lua
LScatterPlot:setYTickCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:setYTickCount(6)
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    print("scatter y ticks bytes = " .. #pixels)
end
```

---

#### `LScatterPlot:type`

Type.

```lua
LScatterPlot:type()
```

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 256, height = 128 })
    print("type = " .. chart:type())
    print("object = " .. tostring(chart:typeOf("LObject")))
end
```

---

#### `LScatterPlot:typeOf`

Type of.

```lua
LScatterPlot:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 256, height = 128 })
    print("typeOf LScatterPlot = " .. tostring(chart:typeOf("LScatterPlot")))
    print("typeOf LPieChart = " .. tostring(chart:typeOf("LPieChart")))
end
```

---
