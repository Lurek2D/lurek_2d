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

```lua
lurek.charts.newHeatmap(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | any |  |

---

### `lurek.charts.newHistogram`

```lua
lurek.charts.newHistogram(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | any |  |

---

### `lurek.charts.newLine`

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

```lua
LAreaChart:addLayer(name, values, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |
| `values` | any |  |
| `color?` | any |  |

---

#### `LAreaChart:addLayerFromDataFrame`

```lua
LAreaChart:addLayerFromDataFrame()
```

---

#### `LAreaChart:addSeries`

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

---

#### `LAreaChart:clear`

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

```lua
LAreaChart:draw(x, y, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `opts?` | any |  |

---

#### `LAreaChart:drawToImage`

```lua
LAreaChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | any |  |

---

#### `LAreaChart:getHeight`

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

```lua
LAreaChart:renderImage()
```

---

#### `LAreaChart:setShowLegend`

```lua
LAreaChart:setShowLegend(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any |  |

---

#### `LAreaChart:setTitle`

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

```lua
LAreaChart:setWindow(max_points)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `max_points?` | any |  |

---

#### `LAreaChart:setXLabel`

```lua
LAreaChart:setXLabel(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | any |  |

---

#### `LAreaChart:setXTickCount`

```lua
LAreaChart:setXTickCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | any |  |

---

#### `LAreaChart:setYLabel`

```lua
LAreaChart:setYLabel(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | any |  |

---

#### `LAreaChart:setYMax`

```lua
LAreaChart:setYMax(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any |  |

---

#### `LAreaChart:setYTickCount`

```lua
LAreaChart:setYTickCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | any |  |

---

#### `LAreaChart:type`

```lua
LAreaChart:type()
```

---

#### `LAreaChart:typeOf`

```lua
LAreaChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |

---

## LBarChart

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LBarChart:addCategoriesFromDataFrame`

```lua
LBarChart:addCategoriesFromDataFrame(df, label_col, value_cols, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `df` | any |  |
| `label_col` | any |  |
| `value_cols` | any |  |
| `opts?` | any |  |

---

#### `LBarChart:addCategory`

```lua
LBarChart:addCategory(label, values)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | any |  |
| `values` | any |  |

---

#### `LBarChart:addSeries`

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

```lua
LBarChart:draw(x, y, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `opts?` | any |  |

---

#### `LBarChart:drawToImage`

```lua
LBarChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | any |  |

---

#### `LBarChart:getHeight`

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

```lua
LBarChart:renderImage()
```

---

#### `LBarChart:setBarWidth`

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

```lua
LBarChart:setShowLegend(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any |  |

---

#### `LBarChart:setTitle`

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

```lua
LBarChart:setXLabel(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | any |  |

---

#### `LBarChart:setXTickCount`

```lua
LBarChart:setXTickCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | any |  |

---

#### `LBarChart:setYLabel`

```lua
LBarChart:setYLabel(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | any |  |

---

#### `LBarChart:setYTickCount`

```lua
LBarChart:setYTickCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | any |  |

---

#### `LBarChart:type`

```lua
LBarChart:type()
```

---

#### `LBarChart:typeOf`

```lua
LBarChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |

---

## LHeatmapChart

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LHeatmapChart:clear`

```lua
LHeatmapChart:clear()
```

---

#### `LHeatmapChart:clearValueRange`

```lua
LHeatmapChart:clearValueRange()
```

---

#### `LHeatmapChart:draw`

```lua
LHeatmapChart:draw(x, y, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `opts?` | any |  |

---

#### `LHeatmapChart:drawToImage`

```lua
LHeatmapChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | any |  |

---

#### `LHeatmapChart:getHeight`

```lua
LHeatmapChart:getHeight()
```

---

#### `LHeatmapChart:getWidth`

```lua
LHeatmapChart:getWidth()
```

---

#### `LHeatmapChart:render`

```lua
LHeatmapChart:render()
```

---

#### `LHeatmapChart:renderImage`

```lua
LHeatmapChart:renderImage()
```

---

#### `LHeatmapChart:resize`

```lua
LHeatmapChart:resize(rows, cols)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `rows` | any |  |
| `cols` | any |  |

---

#### `LHeatmapChart:setCell`

```lua
LHeatmapChart:setCell(row, col, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `row` | any |  |
| `col` | any |  |
| `value` | any |  |

---

#### `LHeatmapChart:setColorRange`

```lua
LHeatmapChart:setColorRange(low, high)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `low` | any |  |
| `high` | any |  |

---

#### `LHeatmapChart:setColumnLabels`

```lua
LHeatmapChart:setColumnLabels(labels)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `labels` | any |  |

---

#### `LHeatmapChart:setMatrix`

```lua
LHeatmapChart:setMatrix(matrix, row_labels, col_labels)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `matrix` | any |  |
| `row_labels?` | any |  |
| `col_labels?` | any |  |

---

#### `LHeatmapChart:setMatrixFromDataFrame`

```lua
LHeatmapChart:setMatrixFromDataFrame(df, row_col, col_col, value_col, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `df` | any |  |
| `row_col` | any |  |
| `col_col` | any |  |
| `value_col` | any |  |
| `opts?` | any |  |

---

#### `LHeatmapChart:setRowLabels`

```lua
LHeatmapChart:setRowLabels(labels)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `labels` | any |  |

---

#### `LHeatmapChart:setShowLegend`

```lua
LHeatmapChart:setShowLegend(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any |  |

---

#### `LHeatmapChart:setShowValues`

```lua
LHeatmapChart:setShowValues(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any |  |

---

#### `LHeatmapChart:setTitle`

```lua
LHeatmapChart:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | any |  |

---

#### `LHeatmapChart:setValueRange`

```lua
LHeatmapChart:setValueRange(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | any |  |
| `max` | any |  |

---

#### `LHeatmapChart:type`

```lua
LHeatmapChart:type()
```

---

#### `LHeatmapChart:typeOf`

```lua
LHeatmapChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |

---

## LHistogramChart

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LHistogramChart:addSeries`

```lua
LHistogramChart:addSeries(name, values, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |
| `values` | any |  |
| `color?` | any |  |

---

#### `LHistogramChart:addSeriesFromDataFrame`

```lua
LHistogramChart:addSeriesFromDataFrame()
```

---

#### `LHistogramChart:appendValue`

```lua
LHistogramChart:appendValue(name, value, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |
| `value` | any |  |
| `color?` | any |  |

---

#### `LHistogramChart:clear`

```lua
LHistogramChart:clear()
```

---

#### `LHistogramChart:clearRange`

```lua
LHistogramChart:clearRange()
```

---

#### `LHistogramChart:draw`

```lua
LHistogramChart:draw(x, y, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `opts?` | any |  |

---

#### `LHistogramChart:drawToImage`

```lua
LHistogramChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | any |  |

---

#### `LHistogramChart:getHeight`

```lua
LHistogramChart:getHeight()
```

---

#### `LHistogramChart:getWidth`

```lua
LHistogramChart:getWidth()
```

---

#### `LHistogramChart:render`

```lua
LHistogramChart:render()
```

---

#### `LHistogramChart:renderImage`

```lua
LHistogramChart:renderImage()
```

---

#### `LHistogramChart:replaceSeries`

```lua
LHistogramChart:replaceSeries(name, values, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |
| `values` | any |  |
| `color?` | any |  |

---

#### `LHistogramChart:setBinCount`

```lua
LHistogramChart:setBinCount(bins)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bins` | any |  |

---

#### `LHistogramChart:setDensity`

```lua
LHistogramChart:setDensity(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | any |  |

---

#### `LHistogramChart:setRange`

```lua
LHistogramChart:setRange(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | any |  |
| `max` | any |  |

---

#### `LHistogramChart:setShowLegend`

```lua
LHistogramChart:setShowLegend(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any |  |

---

#### `LHistogramChart:setTitle`

```lua
LHistogramChart:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | any |  |

---

#### `LHistogramChart:setWindow`

```lua
LHistogramChart:setWindow(max_points)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `max_points?` | any |  |

---

#### `LHistogramChart:setXLabel`

```lua
LHistogramChart:setXLabel(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | any |  |

---

#### `LHistogramChart:setXTickCount`

```lua
LHistogramChart:setXTickCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | any |  |

---

#### `LHistogramChart:setYLabel`

```lua
LHistogramChart:setYLabel(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | any |  |

---

#### `LHistogramChart:setYTickCount`

```lua
LHistogramChart:setYTickCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | any |  |

---

#### `LHistogramChart:type`

```lua
LHistogramChart:type()
```

---

#### `LHistogramChart:typeOf`

```lua
LHistogramChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |

---

## LLineChart

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LLineChart:addSeries`

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

```lua
LLineChart:addSeriesFromDataFrame()
```

---

#### `LLineChart:appendPoint`

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

---

#### `LLineChart:clear`

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

```lua
LLineChart:draw(x, y, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `opts?` | any |  |

---

#### `LLineChart:drawToImage`

```lua
LLineChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | any |  |

---

#### `LLineChart:getHeight`

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

```lua
LLineChart:nearest(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |

---

#### `LLineChart:render`

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

```lua
LLineChart:renderImage()
```

---

#### `LLineChart:replaceSeries`

```lua
LLineChart:replaceSeries(name, data, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |
| `data` | any |  |
| `color?` | any |  |

---

#### `LLineChart:setShowLegend`

```lua
LLineChart:setShowLegend(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any |  |

---

#### `LLineChart:setTitle`

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

```lua
LLineChart:setWindow(max_points)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `max_points?` | any |  |

---

#### `LLineChart:setXLabel`

```lua
LLineChart:setXLabel(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | any |  |

---

#### `LLineChart:setXMax`

```lua
LLineChart:setXMax(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any |  |

---

#### `LLineChart:setXTickCount`

```lua
LLineChart:setXTickCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | any |  |

---

#### `LLineChart:setYLabel`

```lua
LLineChart:setYLabel(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | any |  |

---

#### `LLineChart:setYMax`

```lua
LLineChart:setYMax(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any |  |

---

#### `LLineChart:setYTickCount`

```lua
LLineChart:setYTickCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | any |  |

---

#### `LLineChart:type`

```lua
LLineChart:type()
```

---

#### `LLineChart:typeOf`

```lua
LLineChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |

---

## LPieChart

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LPieChart:addSegment`

```lua
LPieChart:addSegment(label, value, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | any |  |
| `value` | any |  |
| `color?` | any |  |

---

#### `LPieChart:addSegmentsFromDataFrame`

```lua
LPieChart:addSegmentsFromDataFrame(df, label_col, value_col, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `df` | any |  |
| `label_col` | any |  |
| `value_col` | any |  |
| `opts?` | any |  |

---

#### `LPieChart:addSlice`

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

```lua
LPieChart:draw(x, y, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `opts?` | any |  |

---

#### `LPieChart:drawToImage`

```lua
LPieChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | any |  |

---

#### `LPieChart:getHeight`

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

```lua
LPieChart:renderImage()
```

---

#### `LPieChart:setShowLegend`

```lua
LPieChart:setShowLegend(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any |  |

---

#### `LPieChart:setTitle`

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

```lua
LPieChart:type()
```

---

#### `LPieChart:typeOf`

```lua
LPieChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |

---

## LScatterPlot

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LScatterPlot:addSeries`

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

```lua
LScatterPlot:addSeriesFromDataFrame()
```

---

#### `LScatterPlot:appendPoint`

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

---

#### `LScatterPlot:clear`

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

```lua
LScatterPlot:draw(x, y, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `opts?` | any |  |

---

#### `LScatterPlot:drawToImage`

```lua
LScatterPlot:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | any |  |

---

#### `LScatterPlot:getHeight`

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

```lua
LScatterPlot:nearest(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |

---

#### `LScatterPlot:render`

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

```lua
LScatterPlot:renderImage()
```

---

#### `LScatterPlot:replaceSeries`

```lua
LScatterPlot:replaceSeries(name, data, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |
| `data` | any |  |
| `color?` | any |  |

---

#### `LScatterPlot:setDotRadius`

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

```lua
LScatterPlot:setShowLegend(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any |  |

---

#### `LScatterPlot:setTitle`

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

```lua
LScatterPlot:setWindow(max_points)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `max_points?` | any |  |

---

#### `LScatterPlot:setXLabel`

```lua
LScatterPlot:setXLabel(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | any |  |

---

#### `LScatterPlot:setXRange`

```lua
LScatterPlot:setXRange(min_x, max_x)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min_x` | any |  |
| `max_x` | any |  |

---

#### `LScatterPlot:setXTickCount`

```lua
LScatterPlot:setXTickCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | any |  |

---

#### `LScatterPlot:setYLabel`

```lua
LScatterPlot:setYLabel(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | any |  |

---

#### `LScatterPlot:setYRange`

```lua
LScatterPlot:setYRange(min_y, max_y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min_y` | any |  |
| `max_y` | any |  |

---

#### `LScatterPlot:setYTickCount`

```lua
LScatterPlot:setYTickCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | any |  |

---

#### `LScatterPlot:type`

```lua
LScatterPlot:type()
```

---

#### `LScatterPlot:typeOf`

```lua
LScatterPlot:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |

---
