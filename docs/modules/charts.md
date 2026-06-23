# Charts

## Purpose

Rasterizes line, bar, area, scatter, pie, histogram, and heatmap charts into RGBA buffers and drawable runtime textures.

## When To Use

- It supports line, bar, area, scatter, pie, histogram, and heatmap views so different kinds of telemetry and balancing data can share one visualization system.
- That range matters because frame-time traces, economy curves, loot distributions, progression trends, and density-style data do not all want the same display form.
- Live projects often need to inspect those measurements without exporting them into external plotting tools first, and this module keeps that workflow inside the runtime.

## Minimal Example

Example block: `lurek.charts.newLine`

```lua
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("line width=" .. tostring(width))
    lurek.log.info("line height=" .. tostring(height))
end
```

## Common Patterns

- Start with `lurek.charts.defaultPalette` when exploring this module.
- Start with `lurek.charts.newArea` when exploring this module.
- Start with `lurek.charts.newBar` when exploring this module.
- Start with `lurek.charts.newBoxPlot` when exploring this module.
- Start with `lurek.charts.newBubble` when exploring this module.

## API Reference

- This page is the generated API reference for this module.

## Summary

- The `charts` module is the engine's in-runtime data-visualization surface for users who want tables, counters, time series, and distributions to become readable graphics.
- It supports line, bar, area, scatter, pie, histogram, and heatmap views so different kinds of telemetry and balancing data can share one visualization system.
- That range matters because frame-time traces, economy curves, loot distributions, progression trends, and density-style data do not all want the same display form.
- Live projects often need to inspect those measurements without exporting them into external plotting tools first, and this module keeps that workflow inside the runtime.
- CPU-side rasterization is central because it makes chart output deterministic and portable across live UI, screenshots, reports, docs, and test artifacts.
- Styling controls keep the module useful for polished runtime dashboards as well as for raw debug panels, while interactive helpers such as nearest-point queries make exact values explorable instead of merely visible.
- Interactivity also matters because a chart often becomes useful only when a caller can inspect an exact point, bucket, or outlier instead of visually guessing from the overall shape.
- Portability is part of the module's practical value too, because the same chart can move between live overlays, screenshots, generated reports, and regression artifacts without changing the underlying data model.
- The module also helps bridge structured analysis and communication: once numbers become a chart, teams can compare trends, outliers, and distributions much faster than by reading rows or logs directly.
- The module is useful for telemetry, tuning, economy balancing, analytics overlays, progress dashboards, and any workflow where numbers should become images instead of logs.
- `dataframe` and other systems may own the source data, but `charts` owns the mapping from structured values to chart-specific visual form.
- Read `charts` as the place where engine-side measurements become inspectable visual explanations.

This module primarily collaborates with `color`, `dataframe`, `image`. Its responsibility should stay inside the `Feature Systems` group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.charts.defaultPalette`

Returns the default chart color palette.

```lua
lurek.charts.defaultPalette()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Default color palette as RGB tables. |

**Example**

```lua
do
    local palette = lurek.charts.defaultPalette()
    local first = palette[1]
    local second = lurek.charts.seriesColor(2)
    lurek.log.info("palette count=" .. tostring(#palette))
    lurek.log.info("first color=" .. tostring(first))
    lurek.log.info("series color=" .. tostring(second))
end
```

---

### `lurek.charts.newArea`

Creates a new area chart userdata instance.

```lua
lurek.charts.newArea(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LAreaChart](#lareachart) | New area chart userdata. |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("area width=" .. tostring(width))
    lurek.log.info("area height=" .. tostring(height))
end
```

---

### `lurek.charts.newBar`

Creates a new bar chart userdata instance.

```lua
lurek.charts.newBar(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LBarChart](#lbarchart) | New bar chart userdata. |

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("bar width=" .. tostring(width))
    lurek.log.info("bar height=" .. tostring(height))
end
```

---

### `lurek.charts.newBoxPlot`

Creates a new boxplot chart userdata instance.

```lua
lurek.charts.newBoxPlot(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LBoxPlotChart](#lboxplotchart) | New boxplot chart userdata. |

**Example**

```lua
do
    local chart = lurek.charts.newBoxPlot({ width = 160, height = 120, title = "BoxPlot" })
    chart:addSeries("latency", { 10, 12, 14, 20, 24, 40 })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("boxplot width=" .. tostring(width))
    lurek.log.info("boxplot height=" .. tostring(height))
end
```

---

### `lurek.charts.newBubble`

Creates a new bubble chart userdata instance.

```lua
lurek.charts.newBubble(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LBubbleChart](#lbubblechart) | New bubble chart userdata. |

**Example**

```lua
do
    local chart = lurek.charts.newBubble({ width = 160, height = 120, title = "Bubble" })
    chart:addSeries("cities", { { 1, 2, 10 }, { 2, 3, 20 }, { 3, 2, 12 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("bubble width=" .. tostring(width))
    lurek.log.info("bubble height=" .. tostring(height))
end
```

---

### `lurek.charts.newCandlestick`

Creates a new candlestick chart userdata instance.

```lua
lurek.charts.newCandlestick(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LCandlestickChart](#lcandlestickchart) | New candlestick chart userdata. |

**Example**

```lua
do
    local chart = lurek.charts.newCandlestick({ width = 160, height = 120, title = "Candlestick" })
    chart:appendCandle("Mon", 10, 14, 9, 13)
    chart:appendCandle("Tue", 13, 16, 12, 15)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("candlestick width=" .. tostring(width))
    lurek.log.info("candlestick height=" .. tostring(height))
end
```

---

### `lurek.charts.newHeatmap`

Creates a new heatmap chart userdata instance.

```lua
lurek.charts.newHeatmap(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LHeatmapChart](#lheatmapchart) | New heatmap chart userdata. |

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("heatmap width=" .. tostring(width))
    lurek.log.info("heatmap height=" .. tostring(height))
end
```

---

### `lurek.charts.newHistogram`

Creates a new histogram chart userdata instance.

```lua
lurek.charts.newHistogram(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LHistogramChart](#lhistogramchart) | New histogram chart userdata. |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("histogram width=" .. tostring(width))
    lurek.log.info("histogram height=" .. tostring(height))
end
```

---

### `lurek.charts.newLine`

Creates a new line chart userdata instance.

```lua
lurek.charts.newLine(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LLineChart](#llinechart) | New line chart userdata. |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("line width=" .. tostring(width))
    lurek.log.info("line height=" .. tostring(height))
end
```

---

### `lurek.charts.newPie`

Creates a new pie chart userdata instance.

```lua
lurek.charts.newPie(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LPieChart](#lpiechart) | New pie chart userdata. |

**Example**

```lua
do
    local chart = lurek.charts.newPie({ width = 160, height = 120, title = "Pie" })
    chart:addSlice("North", 12)
    chart:addSlice("South", 8)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("pie width=" .. tostring(width))
    lurek.log.info("pie height=" .. tostring(height))
end
```

---

### `lurek.charts.newRadar`

Creates a new radar chart userdata instance.

```lua
lurek.charts.newRadar(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LRadarChart](#lradarchart) | New radar chart userdata. |

**Example**

```lua
do
    local chart = lurek.charts.newRadar({ width = 160, height = 120, title = "Radar" })
    chart:setAxes({ "speed", "power", "range", "cost" })
    chart:addSeries("Scout", { 5, 2, 4, 3 })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("radar width=" .. tostring(width))
    lurek.log.info("radar height=" .. tostring(height))
end
```

---

### `lurek.charts.newScatter`

Creates a new scatter plot userdata instance.

```lua
lurek.charts.newScatter(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LScatterPlot](#lscatterplot) | New scatter plot userdata. |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("scatter width=" .. tostring(width))
    lurek.log.info("scatter height=" .. tostring(height))
end
```

---

### `lurek.charts.newTreemap`

Creates a new treemap chart userdata instance.

```lua
lurek.charts.newTreemap(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LTreemapChart](#ltreemapchart) | New treemap chart userdata. |

**Example**

```lua
do
    local chart = lurek.charts.newTreemap({ width = 160, height = 120, title = "Treemap" })
    chart:addItem("Rendering", 45)
    chart:addItem("Audio", 18)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("treemap width=" .. tostring(width))
    lurek.log.info("treemap height=" .. tostring(height))
end
```

---

### `lurek.charts.seriesColor`

Returns the palette color for a series index.

```lua
lurek.charts.seriesColor(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| table | Palette color table for the requested series. |

**Example**

```lua
do
    local first = lurek.charts.seriesColor(1)
    local second = lurek.charts.seriesColor(2)
    local palette = lurek.charts.defaultPalette()
    lurek.log.info("first color=" .. tostring(first))
    lurek.log.info("second color=" .. tostring(second))
    lurek.log.info("palette count=" .. tostring(#palette))
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LAreaChart](#lareachart)
- [LBarChart](#lbarchart)
- [LBoxPlotChart](#lboxplotchart)
- [LBubbleChart](#lbubblechart)
- [LCandlestickChart](#lcandlestickchart)
- [LHeatmapChart](#lheatmapchart)
- [LHistogramChart](#lhistogramchart)
- [LLineChart](#llinechart)
- [LPieChart](#lpiechart)
- [LRadarChart](#lradarchart)
- [LScatterPlot](#lscatterplot)
- [LTreemapChart](#ltreemapchart)

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
| `name` | string | Parameter value for this chart operation. |
| `values` | table | Parameter value for this chart operation. |
| `color?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:addLayer("trend", { 8, 12, 10 })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("addLayer width=" .. tostring(width))
    lurek.log.info("addLayer height=" .. tostring(height))
end
```

---

#### `LAreaChart:addLayerFromDataFrame`

Builds one filled area layer from a dataframe value column.

```lua
LAreaChart:addLayerFromDataFrame(name, df, value_col, color, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Parameter value for this chart operation. |
| `df` | userdata | Parameter value for this chart operation. |
| `value_col` | string | Parameter value for this chart operation. |
| `color?` | table | Parameter value for this chart operation. |
| `opts?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
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
| `name` | string | Parameter value for this chart operation. |
| `data` | table | Parameter value for this chart operation. |
| `color?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:addSeries("north", { { 1, 9 }, { 2, 14 }, { 3, 11 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("addSeries width=" .. tostring(width))
    lurek.log.info("addSeries height=" .. tostring(height))
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
| `name` | string | Parameter value for this chart operation. |
| `x` | number | Parameter value for this chart operation. |
| `y` | number | Parameter value for this chart operation. |
| `color?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:appendPoint("north", 4, 17)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("appendPoint width=" .. tostring(width))
    lurek.log.info("appendPoint height=" .. tostring(height))
end
```

---

#### `LAreaChart:clear`

Clears all series and cached chart state.

```lua
LAreaChart:clear()
```

**Example**

```lua
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
| `x` | number | Parameter value for this chart operation. |
| `y` | number | Parameter value for this chart operation. |
| `opts?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
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
```

---

#### `LAreaChart:drawToImage`

Draws the rendered chart into an existing image.

```lua
LAreaChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | userdata | Parameter value for this chart operation. |

**Example**

```lua
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
```

---

#### `LAreaChart:getHeight`

Returns the configured chart height in pixels.

```lua
LAreaChart:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Configured chart dimension in pixels. |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    lurek.log.info("height=" .. tostring(chart:getHeight()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getHeight width=" .. tostring(width))
    lurek.log.info("getHeight height=" .. tostring(height))
end
```

---

#### `LAreaChart:getWidth`

Returns the configured chart width in pixels.

```lua
LAreaChart:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Configured chart dimension in pixels. |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    lurek.log.info("width=" .. tostring(chart:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getWidth width=" .. tostring(width))
    lurek.log.info("getWidth height=" .. tostring(height))
end
```

---

#### `LAreaChart:render`

Renders the chart into raw RGBA image bytes.

```lua
LAreaChart:render()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width; height; and RGBA image bytes for the rendered chart. (value 1). |
| number | Width; height; and RGBA image bytes for the rendered chart. (value 2). |
| string | Width; height; and RGBA image bytes for the rendered chart. (value 3). |

**Example**

```lua
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
```

---

#### `LAreaChart:renderImage`

Renders the chart into a new [LImage](render.md#limage) userdata.

```lua
LAreaChart:renderImage()
```

**Example**

```lua
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
```

---

#### `LAreaChart:setShowLegend`

Controls whether the chart legend is rendered.

```lua
LAreaChart:setShowLegend(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | boolean | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setShowLegend(true)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setShowLegend width=" .. tostring(width))
    lurek.log.info("setShowLegend height=" .. tostring(height))
end
```

---

#### `LAreaChart:setTitle`

Sets the chart title text shown in rendered output.

```lua
LAreaChart:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | string | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setTitle("Area example")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setTitle width=" .. tostring(width))
    lurek.log.info("setTitle height=" .. tostring(height))
end
```

---

#### `LAreaChart:setWindow`

Sets the maximum retained sample window for this chart.

```lua
LAreaChart:setWindow(max_points)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `max_points?` | number | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setWindow(2)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setWindow width=" .. tostring(width))
    lurek.log.info("setWindow height=" .. tostring(height))
end
```

---

#### `LAreaChart:setXLabel`

Sets the X axis label text for rendered output.

```lua
LAreaChart:setXLabel(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | string | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setXLabel("Month")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setXLabel width=" .. tostring(width))
    lurek.log.info("setXLabel height=" .. tostring(height))
end
```

---

#### `LAreaChart:setXTickCount`

Sets the number of X axis ticks drawn for this chart.

```lua
LAreaChart:setXTickCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | number | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setXTickCount(4)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setXTickCount width=" .. tostring(width))
    lurek.log.info("setXTickCount height=" .. tostring(height))
end
```

---

#### `LAreaChart:setYLabel`

Sets the Y axis label text for rendered output.

```lua
LAreaChart:setYLabel(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | string | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setYLabel("Value")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setYLabel width=" .. tostring(width))
    lurek.log.info("setYLabel height=" .. tostring(height))
end
```

---

#### `LAreaChart:setYMax`

Sets the explicit Y axis maximum for chart scaling.

```lua
LAreaChart:setYMax(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | number | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setYMax(30)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setYMax width=" .. tostring(width))
    lurek.log.info("setYMax height=" .. tostring(height))
end
```

---

#### `LAreaChart:setYTickCount`

Sets the number of Y axis ticks drawn for this chart.

```lua
LAreaChart:setYTickCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | number | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setYTickCount(4)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setYTickCount width=" .. tostring(width))
    lurek.log.info("setYTickCount height=" .. tostring(height))
end
```

---

#### `LAreaChart:type`

Returns the runtime userdata type name for this chart.

```lua
LAreaChart:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Runtime userdata type name. |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 160, height = 120, title = "Area" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    lurek.log.info("type=" .. tostring(chart:type()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("type width=" .. tostring(width))
    lurek.log.info("type height=" .. tostring(height))
end
```

---

#### `LAreaChart:typeOf`

Checks whether a type name matches this chart userdata.

```lua
LAreaChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this chart userdata. |

**Example**

```lua
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
```

---

## LBarChart

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LBarChart:addCategoriesFromDataFrame`

Adds grouped bar categories by reading one label column and one or more value columns from a dataframe.

```lua
LBarChart:addCategoriesFromDataFrame(df, label_col, value_cols, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `df` | userdata | Parameter value for this chart operation. |
| `label_col` | string | Parameter value for this chart operation. |
| `value_cols` | table | Parameter value for this chart operation. |
| `opts?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
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
| `label` | string | Parameter value for this chart operation. |
| `values` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:addCategory("Q1", { 12, 8, 5 })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("addCategory width=" .. tostring(width))
    lurek.log.info("addCategory height=" .. tostring(height))
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
| `name` | string | Parameter value for this chart operation. |
| `data` | table | Parameter value for this chart operation. |
| `color?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:addSeries("north", { { 1, 9 }, { 2, 14 }, { 3, 11 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("addSeries width=" .. tostring(width))
    lurek.log.info("addSeries height=" .. tostring(height))
end
```

---

#### `LBarChart:clear`

Clears all series and cached chart state.

```lua
LBarChart:clear()
```

**Example**

```lua
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
| `x` | number | Parameter value for this chart operation. |
| `y` | number | Parameter value for this chart operation. |
| `opts?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
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
```

---

#### `LBarChart:drawToImage`

Draws the rendered chart into an existing image.

```lua
LBarChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | userdata | Parameter value for this chart operation. |

**Example**

```lua
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
```

---

#### `LBarChart:getHeight`

Returns the configured chart height in pixels.

```lua
LBarChart:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Configured chart dimension in pixels. |

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    lurek.log.info("height=" .. tostring(chart:getHeight()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getHeight width=" .. tostring(width))
    lurek.log.info("getHeight height=" .. tostring(height))
end
```

---

#### `LBarChart:getWidth`

Returns the configured chart width in pixels.

```lua
LBarChart:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Configured chart dimension in pixels. |

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    lurek.log.info("width=" .. tostring(chart:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getWidth width=" .. tostring(width))
    lurek.log.info("getWidth height=" .. tostring(height))
end
```

---

#### `LBarChart:render`

Renders the chart into raw RGBA image bytes.

```lua
LBarChart:render()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width; height; and RGBA image bytes for the rendered chart. (value 1). |
| number | Width; height; and RGBA image bytes for the rendered chart. (value 2). |
| string | Width; height; and RGBA image bytes for the rendered chart. (value 3). |

**Example**

```lua
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
```

---

#### `LBarChart:renderImage`

Renders the chart into a new [LImage](render.md#limage) userdata.

```lua
LBarChart:renderImage()
```

**Example**

```lua
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
```

---

#### `LBarChart:setBarWidth`

Sets the rendered width used for each bar.

```lua
LBarChart:setBarWidth(width)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setBarWidth(0.65)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setBarWidth width=" .. tostring(width))
    lurek.log.info("setBarWidth height=" .. tostring(height))
end
```

---

#### `LBarChart:setShowLegend`

Controls whether the chart legend is rendered.

```lua
LBarChart:setShowLegend(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | boolean | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setShowLegend(true)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setShowLegend width=" .. tostring(width))
    lurek.log.info("setShowLegend height=" .. tostring(height))
end
```

---

#### `LBarChart:setTitle`

Sets the chart title text shown in rendered output.

```lua
LBarChart:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | string | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setTitle("Bar example")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setTitle width=" .. tostring(width))
    lurek.log.info("setTitle height=" .. tostring(height))
end
```

---

#### `LBarChart:setXLabel`

Sets the X axis label text for rendered output.

```lua
LBarChart:setXLabel(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | string | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setXLabel("Month")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setXLabel width=" .. tostring(width))
    lurek.log.info("setXLabel height=" .. tostring(height))
end
```

---

#### `LBarChart:setXTickCount`

Sets the number of X axis ticks drawn for this chart.

```lua
LBarChart:setXTickCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | number | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setXTickCount(4)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setXTickCount width=" .. tostring(width))
    lurek.log.info("setXTickCount height=" .. tostring(height))
end
```

---

#### `LBarChart:setYLabel`

Sets the Y axis label text for rendered output.

```lua
LBarChart:setYLabel(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | string | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setYLabel("Value")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setYLabel width=" .. tostring(width))
    lurek.log.info("setYLabel height=" .. tostring(height))
end
```

---

#### `LBarChart:setYTickCount`

Sets the number of Y axis ticks drawn for this chart.

```lua
LBarChart:setYTickCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | number | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setYTickCount(4)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setYTickCount width=" .. tostring(width))
    lurek.log.info("setYTickCount height=" .. tostring(height))
end
```

---

#### `LBarChart:type`

Returns the runtime userdata type name for this chart.

```lua
LBarChart:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Runtime userdata type name. |

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 160, height = 120, title = "Bar" })
    chart:addSeries("items", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    lurek.log.info("type=" .. tostring(chart:type()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("type width=" .. tostring(width))
    lurek.log.info("type height=" .. tostring(height))
end
```

---

#### `LBarChart:typeOf`

Checks whether a type name matches this chart userdata.

```lua
LBarChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this chart userdata. |

**Example**

```lua
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
```

---

## LBoxPlotChart

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LBoxPlotChart:addSeries`

Adds or replaces a named distribution sample series.

```lua
LBoxPlotChart:addSeries(name, values, color)
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
    local chart = lurek.charts.newBoxPlot({ width = 160, height = 120, title = "BoxPlot" })
    chart:addSeries("latency", { 10, 12, 14, 20, 24, 40 })
    chart:addSeries("latency", { 10, 12, 18, 24, 30 })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("addSeries width=" .. tostring(width))
    lurek.log.info("addSeries height=" .. tostring(height))
end
```

---

#### `LBoxPlotChart:appendValue`

Appends one numeric sample to a named distribution.

```lua
LBoxPlotChart:appendValue(name, value, color)
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
    local chart = lurek.charts.newBoxPlot({ width = 160, height = 120, title = "BoxPlot" })
    chart:addSeries("latency", { 10, 12, 14, 20, 24, 40 })
    chart:appendValue("latency", 28)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("appendValue width=" .. tostring(width))
    lurek.log.info("appendValue height=" .. tostring(height))
end
```

---

#### `LBoxPlotChart:clear`

Clears all chart data and cached chart state.

```lua
LBoxPlotChart:clear()
```

**Example**

```lua
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
```

---

#### `LBoxPlotChart:draw`

Draws the chart at world or screen coordinates using optional transform options.

```lua
LBoxPlotChart:draw(x, y, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Draw X coordinate. |
| `y` | number | Draw Y coordinate. |
| `opts?` | table | Optional render transform options. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
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
```

---

#### `LBoxPlotChart:drawToImage`

Draws the rendered chart into an existing image.

```lua
LBoxPlotChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | userdata | ImageData target to receive chart pixels. |

**Example**

```lua
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
```

---

#### `LBoxPlotChart:getHeight`

Returns the configured chart height in pixels.

```lua
LBoxPlotChart:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Configured chart height in pixels. |

**Example**

```lua
do
    local chart = lurek.charts.newBoxPlot({ width = 160, height = 120, title = "BoxPlot" })
    chart:addSeries("latency", { 10, 12, 14, 20, 24, 40 })
    lurek.log.info("height=" .. tostring(chart:getHeight()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getHeight width=" .. tostring(width))
    lurek.log.info("getHeight height=" .. tostring(height))
end
```

---

#### `LBoxPlotChart:getWidth`

Returns the configured chart width in pixels.

```lua
LBoxPlotChart:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Configured chart width in pixels. |

**Example**

```lua
do
    local chart = lurek.charts.newBoxPlot({ width = 160, height = 120, title = "BoxPlot" })
    chart:addSeries("latency", { 10, 12, 14, 20, 24, 40 })
    lurek.log.info("width=" .. tostring(chart:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getWidth width=" .. tostring(width))
    lurek.log.info("getWidth height=" .. tostring(height))
end
```

---

#### `LBoxPlotChart:render`

Renders the chart into raw RGBA image bytes.

```lua
LBoxPlotChart:render()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width; height; and RGBA image bytes for the rendered chart. (value 1). |
| number | Width; height; and RGBA image bytes for the rendered chart. (value 2). |
| string | Width; height; and RGBA image bytes for the rendered chart. (value 3). |

**Example**

```lua
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
```

---

#### `LBoxPlotChart:renderImage`

Renders the chart into a new [LImage](render.md#limage) userdata.

```lua
LBoxPlotChart:renderImage()
```

**Example**

```lua
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
```

---

#### `LBoxPlotChart:setShowLegend`

Controls whether the chart legend is rendered.

```lua
LBoxPlotChart:setShowLegend(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | boolean | True to show the legend. |

**Example**

```lua
do
    local chart = lurek.charts.newBoxPlot({ width = 160, height = 120, title = "BoxPlot" })
    chart:addSeries("latency", { 10, 12, 14, 20, 24, 40 })
    chart:setShowLegend(true)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setShowLegend width=" .. tostring(width))
    lurek.log.info("setShowLegend height=" .. tostring(height))
end
```

---

#### `LBoxPlotChart:setTitle`

Sets the chart title text shown in rendered output.

```lua
LBoxPlotChart:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | string | New chart title. |

**Example**

```lua
do
    local chart = lurek.charts.newBoxPlot({ width = 160, height = 120, title = "BoxPlot" })
    chart:addSeries("latency", { 10, 12, 14, 20, 24, 40 })
    chart:setTitle("BoxPlot example")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setTitle width=" .. tostring(width))
    lurek.log.info("setTitle height=" .. tostring(height))
end
```

---

#### `LBoxPlotChart:type`

Returns the runtime userdata type name for this chart.

```lua
LBoxPlotChart:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Runtime userdata type name. |

**Example**

```lua
do
    local chart = lurek.charts.newBoxPlot({ width = 160, height = 120, title = "BoxPlot" })
    chart:addSeries("latency", { 10, 12, 14, 20, 24, 40 })
    lurek.log.info("type=" .. tostring(chart:type()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("type width=" .. tostring(width))
    lurek.log.info("type height=" .. tostring(height))
end
```

---

#### `LBoxPlotChart:typeOf`

Checks whether a type name matches this chart userdata.

```lua
LBoxPlotChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this chart userdata. |

**Example**

```lua
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
```

---

## LBubbleChart

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LBubbleChart:addSeries`

Adds or replaces a weighted point series from `{x, y, size}` rows.

```lua
LBubbleChart:addSeries(name, data, color)
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
    local chart = lurek.charts.newBubble({ width = 160, height = 120, title = "Bubble" })
    chart:addSeries("cities", { { 1, 2, 10 }, { 2, 3, 20 }, { 3, 2, 12 } })
    chart:addSeries("cities", { { 1, 2, 8 }, { 2, 3, 16 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("addSeries width=" .. tostring(width))
    lurek.log.info("addSeries height=" .. tostring(height))
end
```

---

#### `LBubbleChart:appendPoint`

Appends one weighted point to a named bubble series.

```lua
LBubbleChart:appendPoint(name, x, y, size, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |
| `x` | any |  |
| `y` | any |  |
| `size` | any |  |
| `color?` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newBubble({ width = 160, height = 120, title = "Bubble" })
    chart:addSeries("cities", { { 1, 2, 10 }, { 2, 3, 20 }, { 3, 2, 12 } })
    chart:appendPoint("cities", 2, 3, 20)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("appendPoint width=" .. tostring(width))
    lurek.log.info("appendPoint height=" .. tostring(height))
end
```

---

#### `LBubbleChart:clear`

Clears all chart data and cached chart state.

```lua
LBubbleChart:clear()
```

**Example**

```lua
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
```

---

#### `LBubbleChart:draw`

Draws the chart at world or screen coordinates using optional transform options.

```lua
LBubbleChart:draw(x, y, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Draw X coordinate. |
| `y` | number | Draw Y coordinate. |
| `opts?` | table | Optional render transform options. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
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
```

---

#### `LBubbleChart:drawToImage`

Draws the rendered chart into an existing image.

```lua
LBubbleChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | userdata | ImageData target to receive chart pixels. |

**Example**

```lua
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
```

---

#### `LBubbleChart:getHeight`

Returns the configured chart height in pixels.

```lua
LBubbleChart:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Configured chart height in pixels. |

**Example**

```lua
do
    local chart = lurek.charts.newBubble({ width = 160, height = 120, title = "Bubble" })
    chart:addSeries("cities", { { 1, 2, 10 }, { 2, 3, 20 }, { 3, 2, 12 } })
    lurek.log.info("height=" .. tostring(chart:getHeight()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getHeight width=" .. tostring(width))
    lurek.log.info("getHeight height=" .. tostring(height))
end
```

---

#### `LBubbleChart:getWidth`

Returns the configured chart width in pixels.

```lua
LBubbleChart:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Configured chart width in pixels. |

**Example**

```lua
do
    local chart = lurek.charts.newBubble({ width = 160, height = 120, title = "Bubble" })
    chart:addSeries("cities", { { 1, 2, 10 }, { 2, 3, 20 }, { 3, 2, 12 } })
    lurek.log.info("width=" .. tostring(chart:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getWidth width=" .. tostring(width))
    lurek.log.info("getWidth height=" .. tostring(height))
end
```

---

#### `LBubbleChart:render`

Renders the chart into raw RGBA image bytes.

```lua
LBubbleChart:render()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width; height; and RGBA image bytes for the rendered chart. (value 1). |
| number | Width; height; and RGBA image bytes for the rendered chart. (value 2). |
| string | Width; height; and RGBA image bytes for the rendered chart. (value 3). |

**Example**

```lua
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
```

---

#### `LBubbleChart:renderImage`

Renders the chart into a new [LImage](render.md#limage) userdata.

```lua
LBubbleChart:renderImage()
```

**Example**

```lua
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
```

---

#### `LBubbleChart:setRadiusRange`

Sets the minimum and maximum bubble radius in pixels.

```lua
LBubbleChart:setRadiusRange(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | any |  |
| `max` | any |  |

**Example**

```lua
do
    local chart = lurek.charts.newBubble({ width = 160, height = 120, title = "Bubble" })
    chart:addSeries("cities", { { 1, 2, 10 }, { 2, 3, 20 }, { 3, 2, 12 } })
    chart:setRadiusRange(3, 18)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setRadiusRange width=" .. tostring(width))
    lurek.log.info("setRadiusRange height=" .. tostring(height))
end
```

---

#### `LBubbleChart:setShowLegend`

Controls whether the chart legend is rendered.

```lua
LBubbleChart:setShowLegend(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | boolean | True to show the legend. |

**Example**

```lua
do
    local chart = lurek.charts.newBubble({ width = 160, height = 120, title = "Bubble" })
    chart:addSeries("cities", { { 1, 2, 10 }, { 2, 3, 20 }, { 3, 2, 12 } })
    chart:setShowLegend(true)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setShowLegend width=" .. tostring(width))
    lurek.log.info("setShowLegend height=" .. tostring(height))
end
```

---

#### `LBubbleChart:setTitle`

Sets the chart title text shown in rendered output.

```lua
LBubbleChart:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | string | New chart title. |

**Example**

```lua
do
    local chart = lurek.charts.newBubble({ width = 160, height = 120, title = "Bubble" })
    chart:addSeries("cities", { { 1, 2, 10 }, { 2, 3, 20 }, { 3, 2, 12 } })
    chart:setTitle("Bubble example")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setTitle width=" .. tostring(width))
    lurek.log.info("setTitle height=" .. tostring(height))
end
```

---

#### `LBubbleChart:type`

Returns the runtime userdata type name for this chart.

```lua
LBubbleChart:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Runtime userdata type name. |

**Example**

```lua
do
    local chart = lurek.charts.newBubble({ width = 160, height = 120, title = "Bubble" })
    chart:addSeries("cities", { { 1, 2, 10 }, { 2, 3, 20 }, { 3, 2, 12 } })
    lurek.log.info("type=" .. tostring(chart:type()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("type width=" .. tostring(width))
    lurek.log.info("type height=" .. tostring(height))
end
```

---

#### `LBubbleChart:typeOf`

Checks whether a type name matches this chart userdata.

```lua
LBubbleChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this chart userdata. |

**Example**

```lua
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
```

---

## LCandlestickChart

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LCandlestickChart:appendCandle`

Appends one labeled OHLC candle to the end of the current candlestick stream.

```lua
LCandlestickChart:appendCandle(label, open, high, low, close)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | any |  |
| `open` | any |  |
| `high` | any |  |
| `low` | any |  |
| `close` | any |  |

**Example**

```lua
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
```

---

#### `LCandlestickChart:clear`

Clears all chart data and cached chart state.

```lua
LCandlestickChart:clear()
```

**Example**

```lua
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
```

---

#### `LCandlestickChart:draw`

Draws the chart at world or screen coordinates using optional transform options.

```lua
LCandlestickChart:draw(x, y, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Draw X coordinate. |
| `y` | number | Draw Y coordinate. |
| `opts?` | table | Optional render transform options. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
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
```

---

#### `LCandlestickChart:drawToImage`

Draws the rendered chart into an existing image.

```lua
LCandlestickChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | userdata | ImageData target to receive chart pixels. |

**Example**

```lua
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
```

---

#### `LCandlestickChart:getHeight`

Returns the configured chart height in pixels.

```lua
LCandlestickChart:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Configured chart height in pixels. |

**Example**

```lua
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
```

---

#### `LCandlestickChart:getWidth`

Returns the configured chart width in pixels.

```lua
LCandlestickChart:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Configured chart width in pixels. |

**Example**

```lua
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
```

---

#### `LCandlestickChart:render`

Renders the chart into raw RGBA image bytes.

```lua
LCandlestickChart:render()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width; height; and RGBA image bytes for the rendered chart. (value 1). |
| number | Width; height; and RGBA image bytes for the rendered chart. (value 2). |
| string | Width; height; and RGBA image bytes for the rendered chart. (value 3). |

**Example**

```lua
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
```

---

#### `LCandlestickChart:renderImage`

Renders the chart into a new [LImage](render.md#limage) userdata.

```lua
LCandlestickChart:renderImage()
```

**Example**

```lua
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
```

---

#### `LCandlestickChart:setCandles`

Replaces all OHLC candles from table rows with open/high/low/close fields or values 1..4.

```lua
LCandlestickChart:setCandles(candles)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `candles` | any |  |

**Example**

```lua
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
```

---

#### `LCandlestickChart:setColors`

Sets up/down candle colors.

```lua
LCandlestickChart:setColors(up, down)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `up` | any |  |
| `down` | any |  |

**Example**

```lua
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
```

---

#### `LCandlestickChart:setShowLegend`

Controls whether the chart legend is rendered.

```lua
LCandlestickChart:setShowLegend(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | boolean | True to show the legend. |

**Example**

```lua
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
```

---

#### `LCandlestickChart:setTitle`

Sets the chart title text shown in rendered output.

```lua
LCandlestickChart:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | string | New chart title. |

**Example**

```lua
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
```

---

#### `LCandlestickChart:type`

Returns the runtime userdata type name for this chart.

```lua
LCandlestickChart:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Runtime userdata type name. |

**Example**

```lua
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
```

---

#### `LCandlestickChart:typeOf`

Checks whether a type name matches this chart userdata.

```lua
LCandlestickChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this chart userdata. |

**Example**

```lua
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
```

---

## LHeatmapChart

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LHeatmapChart:clear`

Clears all series and cached chart state.

```lua
LHeatmapChart:clear()
```

**Example**

```lua
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
```

---

#### `LHeatmapChart:clearValueRange`

Clears the explicit heatmap value range.

```lua
LHeatmapChart:clearValueRange()
```

**Example**

```lua
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
| `x` | number | Parameter value for this chart operation. |
| `y` | number | Parameter value for this chart operation. |
| `opts?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
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
```

---

#### `LHeatmapChart:drawToImage`

Draws the rendered chart into an existing image.

```lua
LHeatmapChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | userdata | Parameter value for this chart operation. |

**Example**

```lua
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
```

---

#### `LHeatmapChart:getHeight`

Returns the configured chart height in pixels.

```lua
LHeatmapChart:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Configured chart dimension in pixels. |

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    lurek.log.info("height=" .. tostring(chart:getHeight()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getHeight width=" .. tostring(width))
    lurek.log.info("getHeight height=" .. tostring(height))
end
```

---

#### `LHeatmapChart:getWidth`

Returns the configured chart width in pixels.

```lua
LHeatmapChart:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Configured chart dimension in pixels. |

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    lurek.log.info("width=" .. tostring(chart:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getWidth width=" .. tostring(width))
    lurek.log.info("getWidth height=" .. tostring(height))
end
```

---

#### `LHeatmapChart:render`

Renders the chart into raw RGBA image bytes.

```lua
LHeatmapChart:render()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width; height; and RGBA image bytes for the rendered chart. (value 1). |
| number | Width; height; and RGBA image bytes for the rendered chart. (value 2). |
| string | Width; height; and RGBA image bytes for the rendered chart. (value 3). |

**Example**

```lua
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
```

---

#### `LHeatmapChart:renderImage`

Renders the chart into a new [LImage](render.md#limage) userdata.

```lua
LHeatmapChart:renderImage()
```

**Example**

```lua
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
```

---

#### `LHeatmapChart:resize`

Resizes the heatmap grid dimensions.

```lua
LHeatmapChart:resize(rows, cols)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `rows` | number | Parameter value for this chart operation. |
| `cols` | number | Parameter value for this chart operation. |

**Example**

```lua
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
```

---

#### `LHeatmapChart:setCell`

Sets a numeric heatmap cell value by row and column.

```lua
LHeatmapChart:setCell(row, col, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `row` | number | Parameter value for this chart operation. |
| `col` | number | Parameter value for this chart operation. |
| `value` | number | Parameter value for this chart operation. |

**Example**

```lua
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
| `low` | table | Parameter value for this chart operation. |
| `high` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    chart:setColorRange({ 0.1, 0.2, 0.8, 1.0 }, { 0.9, 0.1, 0.1, 1.0 })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setColorRange width=" .. tostring(width))
    lurek.log.info("setColorRange height=" .. tostring(height))
end
```

---

#### `LHeatmapChart:setColumnLabels`

Sets labels displayed for heatmap columns.

```lua
LHeatmapChart:setColumnLabels(labels)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `labels` | table | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    chart:setColumnLabels({ "Q1", "Q2" })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setColumnLabels width=" .. tostring(width))
    lurek.log.info("setColumnLabels height=" .. tostring(height))
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
| `matrix` | table | Parameter value for this chart operation. |
| `row_labels?` | table | Parameter value for this chart operation. |
| `col_labels?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setMatrix width=" .. tostring(width))
    lurek.log.info("setMatrix height=" .. tostring(height))
end
```

---

#### `LHeatmapChart:setMatrixFromDataFrame`

Builds the heatmap contents from dataframe row, column, and value fields.

```lua
LHeatmapChart:setMatrixFromDataFrame(df, row_col, col_col, value_col, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `df` | userdata | Parameter value for this chart operation. |
| `row_col` | string | Parameter value for this chart operation. |
| `col_col` | string | Parameter value for this chart operation. |
| `value_col` | string | Parameter value for this chart operation. |
| `opts?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
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
```

---

#### `LHeatmapChart:setRowLabels`

Sets labels displayed for heatmap rows.

```lua
LHeatmapChart:setRowLabels(labels)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `labels` | table | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    chart:setRowLabels({ "North", "South" })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setRowLabels width=" .. tostring(width))
    lurek.log.info("setRowLabels height=" .. tostring(height))
end
```

---

#### `LHeatmapChart:setShowLegend`

Controls whether the chart legend is rendered.

```lua
LHeatmapChart:setShowLegend(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | boolean | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    chart:setShowLegend(true)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setShowLegend width=" .. tostring(width))
    lurek.log.info("setShowLegend height=" .. tostring(height))
end
```

---

#### `LHeatmapChart:setShowValues`

Controls whether heatmap cell values are rendered.

```lua
LHeatmapChart:setShowValues(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | boolean | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    chart:setShowValues(true)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setShowValues width=" .. tostring(width))
    lurek.log.info("setShowValues height=" .. tostring(height))
end
```

---

#### `LHeatmapChart:setTitle`

Sets the chart title text shown in rendered output.

```lua
LHeatmapChart:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | string | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    chart:setTitle("Heatmap example")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setTitle width=" .. tostring(width))
    lurek.log.info("setTitle height=" .. tostring(height))
end
```

---

#### `LHeatmapChart:setValueRange`

Sets the explicit heatmap value range.

```lua
LHeatmapChart:setValueRange(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | number | Parameter value for this chart operation. |
| `max` | number | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    chart:setValueRange(0, 10)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setValueRange width=" .. tostring(width))
    lurek.log.info("setValueRange height=" .. tostring(height))
end
```

---

#### `LHeatmapChart:type`

Returns the runtime userdata type name for this chart.

```lua
LHeatmapChart:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Runtime userdata type name. |

**Example**

```lua
do
    local chart = lurek.charts.newHeatmap({ width = 160, height = 120, title = "Heatmap" })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    lurek.log.info("type=" .. tostring(chart:type()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("type width=" .. tostring(width))
    lurek.log.info("type height=" .. tostring(height))
end
```

---

#### `LHeatmapChart:typeOf`

Checks whether a type name matches this chart userdata.

```lua
LHeatmapChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this chart userdata. |

**Example**

```lua
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
```

---

## LHistogramChart

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LHistogramChart:addSeries`

Adds a named histogram sample series from a numeric value list.

```lua
LHistogramChart:addSeries(name, data, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Parameter value for this chart operation. |
| `data` | table | Parameter value for this chart operation. |
| `color?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    chart:addSeries("latency", { 10, 12, 18, 24, 30 })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("addSeries width=" .. tostring(width))
    lurek.log.info("addSeries height=" .. tostring(height))
end
```

---

#### `LHistogramChart:addSeriesFromDataFrame`

Builds a named histogram sample series from one dataframe value column.

```lua
LHistogramChart:addSeriesFromDataFrame(name, df, x_col, y_col, color, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Parameter value for this chart operation. |
| `df` | userdata | Parameter value for this chart operation. |
| `x_col` | string | Parameter value for this chart operation. |
| `y_col` | string | Parameter value for this chart operation. |
| `color?` | table | Parameter value for this chart operation. |
| `opts?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
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
| `name` | string | Parameter value for this chart operation. |
| `value` | number | Parameter value for this chart operation. |
| `color?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    chart:appendValue("latency", 28)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("appendValue width=" .. tostring(width))
    lurek.log.info("appendValue height=" .. tostring(height))
end
```

---

#### `LHistogramChart:clear`

Clears all series and cached chart state.

```lua
LHistogramChart:clear()
```

**Example**

```lua
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
```

---

#### `LHistogramChart:clearRange`

Clears the explicit histogram value range.

```lua
LHistogramChart:clearRange()
```

**Example**

```lua
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
| `x` | number | Parameter value for this chart operation. |
| `y` | number | Parameter value for this chart operation. |
| `opts?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
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
```

---

#### `LHistogramChart:drawToImage`

Draws the rendered chart into an existing image.

```lua
LHistogramChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | userdata | Parameter value for this chart operation. |

**Example**

```lua
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
```

---

#### `LHistogramChart:getHeight`

Returns the configured chart height in pixels.

```lua
LHistogramChart:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Configured chart dimension in pixels. |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    lurek.log.info("height=" .. tostring(chart:getHeight()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getHeight width=" .. tostring(width))
    lurek.log.info("getHeight height=" .. tostring(height))
end
```

---

#### `LHistogramChart:getWidth`

Returns the configured chart width in pixels.

```lua
LHistogramChart:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Configured chart dimension in pixels. |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    lurek.log.info("width=" .. tostring(chart:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getWidth width=" .. tostring(width))
    lurek.log.info("getWidth height=" .. tostring(height))
end
```

---

#### `LHistogramChart:render`

Renders the chart into raw RGBA image bytes.

```lua
LHistogramChart:render()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width; height; and RGBA image bytes for the rendered chart. (value 1). |
| number | Width; height; and RGBA image bytes for the rendered chart. (value 2). |
| string | Width; height; and RGBA image bytes for the rendered chart. (value 3). |

**Example**

```lua
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
```

---

#### `LHistogramChart:renderImage`

Renders the chart into a new [LImage](render.md#limage) userdata.

```lua
LHistogramChart:renderImage()
```

**Example**

```lua
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
```

---

#### `LHistogramChart:replaceSeries`

Replaces a named histogram sample series with a new numeric value list.

```lua
LHistogramChart:replaceSeries(name, data, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Parameter value for this chart operation. |
| `data` | table | Parameter value for this chart operation. |
| `color?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    chart:replaceSeries("latency", { 10, 12, 18, 24, 30 })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("replaceSeries width=" .. tostring(width))
    lurek.log.info("replaceSeries height=" .. tostring(height))
end
```

---

#### `LHistogramChart:setBinCount`

Sets the number of histogram bins used for samples.

```lua
LHistogramChart:setBinCount(bins)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bins` | number | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    chart:setBinCount(8)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setBinCount width=" .. tostring(width))
    lurek.log.info("setBinCount height=" .. tostring(height))
end
```

---

#### `LHistogramChart:setDensity`

Controls whether histogram bins render as density values.

```lua
LHistogramChart:setDensity(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    chart:setDensity(true)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setDensity width=" .. tostring(width))
    lurek.log.info("setDensity height=" .. tostring(height))
end
```

---

#### `LHistogramChart:setRange`

Sets the explicit histogram value range.

```lua
LHistogramChart:setRange(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | number | Parameter value for this chart operation. |
| `max` | number | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    chart:setRange(10, 30)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setRange width=" .. tostring(width))
    lurek.log.info("setRange height=" .. tostring(height))
end
```

---

#### `LHistogramChart:setShowLegend`

Controls whether the chart legend is rendered.

```lua
LHistogramChart:setShowLegend(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | boolean | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    chart:setShowLegend(true)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setShowLegend width=" .. tostring(width))
    lurek.log.info("setShowLegend height=" .. tostring(height))
end
```

---

#### `LHistogramChart:setTitle`

Sets the chart title text shown in rendered output.

```lua
LHistogramChart:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | string | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    chart:setTitle("Histogram example")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setTitle width=" .. tostring(width))
    lurek.log.info("setTitle height=" .. tostring(height))
end
```

---

#### `LHistogramChart:setWindow`

Sets the maximum retained sample window for this chart.

```lua
LHistogramChart:setWindow(max_points)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `max_points?` | number | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    chart:setWindow(2)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setWindow width=" .. tostring(width))
    lurek.log.info("setWindow height=" .. tostring(height))
end
```

---

#### `LHistogramChart:setXLabel`

Sets the X axis label text for rendered output.

```lua
LHistogramChart:setXLabel(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | string | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    chart:setXLabel("Month")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setXLabel width=" .. tostring(width))
    lurek.log.info("setXLabel height=" .. tostring(height))
end
```

---

#### `LHistogramChart:setXTickCount`

Sets the number of X axis ticks drawn for this chart.

```lua
LHistogramChart:setXTickCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | number | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    chart:setXTickCount(4)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setXTickCount width=" .. tostring(width))
    lurek.log.info("setXTickCount height=" .. tostring(height))
end
```

---

#### `LHistogramChart:setYLabel`

Sets the Y axis label text for rendered output.

```lua
LHistogramChart:setYLabel(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | string | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    chart:setYLabel("Value")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setYLabel width=" .. tostring(width))
    lurek.log.info("setYLabel height=" .. tostring(height))
end
```

---

#### `LHistogramChart:setYTickCount`

Sets the number of Y axis ticks drawn for this chart.

```lua
LHistogramChart:setYTickCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | number | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    chart:setYTickCount(4)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setYTickCount width=" .. tostring(width))
    lurek.log.info("setYTickCount height=" .. tostring(height))
end
```

---

#### `LHistogramChart:type`

Returns the runtime userdata type name for this chart.

```lua
LHistogramChart:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Runtime userdata type name. |

**Example**

```lua
do
    local chart = lurek.charts.newHistogram({ width = 160, height = 120, title = "Histogram" })
    chart:addSeries("response", { 10, 12, 18, 20, 24, 30 })
    lurek.log.info("type=" .. tostring(chart:type()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("type width=" .. tostring(width))
    lurek.log.info("type height=" .. tostring(height))
end
```

---

#### `LHistogramChart:typeOf`

Checks whether a type name matches this chart userdata.

```lua
LHistogramChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this chart userdata. |

**Example**

```lua
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
| `name` | string | Parameter value for this chart operation. |
| `data` | table | Parameter value for this chart operation. |
| `color?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:addSeries("north", { { 1, 9 }, { 2, 14 }, { 3, 11 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("addSeries width=" .. tostring(width))
    lurek.log.info("addSeries height=" .. tostring(height))
end
```

---

#### `LLineChart:addSeriesFromDataFrame`

Builds a named line series from x and y columns in a dataframe.

```lua
LLineChart:addSeriesFromDataFrame(name, df, x_col, y_col, color, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Parameter value for this chart operation. |
| `df` | userdata | Parameter value for this chart operation. |
| `x_col` | string | Parameter value for this chart operation. |
| `y_col` | string | Parameter value for this chart operation. |
| `color?` | table | Parameter value for this chart operation. |
| `opts?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
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
| `name` | string | Parameter value for this chart operation. |
| `x` | number | Parameter value for this chart operation. |
| `y` | number | Parameter value for this chart operation. |
| `color?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:appendPoint("north", 4, 17)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("appendPoint width=" .. tostring(width))
    lurek.log.info("appendPoint height=" .. tostring(height))
end
```

---

#### `LLineChart:clear`

Clears all series and cached chart state.

```lua
LLineChart:clear()
```

**Example**

```lua
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
| `x` | number | Parameter value for this chart operation. |
| `y` | number | Parameter value for this chart operation. |
| `opts?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
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
```

---

#### `LLineChart:drawToImage`

Draws the rendered chart into an existing image.

```lua
LLineChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | userdata | Parameter value for this chart operation. |

**Example**

```lua
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
```

---

#### `LLineChart:getHeight`

Returns the configured chart height in pixels.

```lua
LLineChart:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Configured chart dimension in pixels. |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    lurek.log.info("height=" .. tostring(chart:getHeight()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getHeight width=" .. tostring(width))
    lurek.log.info("getHeight height=" .. tostring(height))
end
```

---

#### `LLineChart:getWidth`

Returns the configured chart width in pixels.

```lua
LLineChart:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Configured chart dimension in pixels. |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    lurek.log.info("width=" .. tostring(chart:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getWidth width=" .. tostring(width))
    lurek.log.info("getWidth height=" .. tostring(height))
end
```

---

#### `LLineChart:nearest`

Finds the nearest plotted point to screen coordinates.

```lua
LLineChart:nearest(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Parameter value for this chart operation. |
| `y` | number | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| table | Nearest point table, or nil when no point is available. |

**Example**

```lua
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
```

---

#### `LLineChart:render`

Renders the chart into raw RGBA image bytes.

```lua
LLineChart:render()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width; height; and RGBA image bytes for the rendered chart. (value 1). |
| number | Width; height; and RGBA image bytes for the rendered chart. (value 2). |
| string | Width; height; and RGBA image bytes for the rendered chart. (value 3). |

**Example**

```lua
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
```

---

#### `LLineChart:renderImage`

Renders the chart into a new [LImage](render.md#limage) userdata.

```lua
LLineChart:renderImage()
```

**Example**

```lua
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
| `name` | string | Parameter value for this chart operation. |
| `data` | table | Parameter value for this chart operation. |
| `color?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:replaceSeries("north", { { 1, 9 }, { 2, 14 }, { 3, 11 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("replaceSeries width=" .. tostring(width))
    lurek.log.info("replaceSeries height=" .. tostring(height))
end
```

---

#### `LLineChart:setShowLegend`

Controls whether the chart legend is rendered.

```lua
LLineChart:setShowLegend(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | boolean | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setShowLegend(true)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setShowLegend width=" .. tostring(width))
    lurek.log.info("setShowLegend height=" .. tostring(height))
end
```

---

#### `LLineChart:setTitle`

Sets the chart title text shown in rendered output.

```lua
LLineChart:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | string | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setTitle("Line example")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setTitle width=" .. tostring(width))
    lurek.log.info("setTitle height=" .. tostring(height))
end
```

---

#### `LLineChart:setWindow`

Sets the maximum retained sample window for this chart.

```lua
LLineChart:setWindow(max_points)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `max_points?` | number | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setWindow(2)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setWindow width=" .. tostring(width))
    lurek.log.info("setWindow height=" .. tostring(height))
end
```

---

#### `LLineChart:setXLabel`

Sets the X axis label text for rendered output.

```lua
LLineChart:setXLabel(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | string | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setXLabel("Month")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setXLabel width=" .. tostring(width))
    lurek.log.info("setXLabel height=" .. tostring(height))
end
```

---

#### `LLineChart:setXMax`

Sets the explicit X axis maximum for chart scaling.

```lua
LLineChart:setXMax(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | number | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setXMax(5)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setXMax width=" .. tostring(width))
    lurek.log.info("setXMax height=" .. tostring(height))
end
```

---

#### `LLineChart:setXTickCount`

Sets the number of X axis ticks drawn for this chart.

```lua
LLineChart:setXTickCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | number | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setXTickCount(4)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setXTickCount width=" .. tostring(width))
    lurek.log.info("setXTickCount height=" .. tostring(height))
end
```

---

#### `LLineChart:setYLabel`

Sets the Y axis label text for rendered output.

```lua
LLineChart:setYLabel(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | string | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setYLabel("Value")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setYLabel width=" .. tostring(width))
    lurek.log.info("setYLabel height=" .. tostring(height))
end
```

---

#### `LLineChart:setYMax`

Sets the explicit Y axis maximum for chart scaling.

```lua
LLineChart:setYMax(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | number | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setYMax(30)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setYMax width=" .. tostring(width))
    lurek.log.info("setYMax height=" .. tostring(height))
end
```

---

#### `LLineChart:setYTickCount`

Sets the number of Y axis ticks drawn for this chart.

```lua
LLineChart:setYTickCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | number | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setYTickCount(4)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setYTickCount width=" .. tostring(width))
    lurek.log.info("setYTickCount height=" .. tostring(height))
end
```

---

#### `LLineChart:type`

Returns the runtime userdata type name for this chart.

```lua
LLineChart:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Runtime userdata type name. |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 160, height = 120, title = "Line" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    lurek.log.info("type=" .. tostring(chart:type()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("type width=" .. tostring(width))
    lurek.log.info("type height=" .. tostring(height))
end
```

---

#### `LLineChart:typeOf`

Checks whether a type name matches this chart userdata.

```lua
LLineChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this chart userdata. |

**Example**

```lua
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
| `label` | string | Parameter value for this chart operation. |
| `value` | number | Parameter value for this chart operation. |
| `color?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
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
```

---

#### `LPieChart:addSegmentsFromDataFrame`

Adds pie segments by reading label and value columns from a dataframe.

```lua
LPieChart:addSegmentsFromDataFrame(df, label_col, value_col, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `df` | userdata | Parameter value for this chart operation. |
| `label_col` | string | Parameter value for this chart operation. |
| `value_col` | string | Parameter value for this chart operation. |
| `opts?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
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
| `label` | string | Parameter value for this chart operation. |
| `value` | number | Parameter value for this chart operation. |
| `color?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
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
```

---

#### `LPieChart:clear`

Clears all series and cached chart state.

```lua
LPieChart:clear()
```

**Example**

```lua
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
| `x` | number | Parameter value for this chart operation. |
| `y` | number | Parameter value for this chart operation. |
| `opts?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
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
```

---

#### `LPieChart:drawToImage`

Draws the rendered chart into an existing image.

```lua
LPieChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | userdata | Parameter value for this chart operation. |

**Example**

```lua
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
```

---

#### `LPieChart:getHeight`

Returns the configured chart height in pixels.

```lua
LPieChart:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Configured chart dimension in pixels. |

**Example**

```lua
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
```

---

#### `LPieChart:getWidth`

Returns the configured chart width in pixels.

```lua
LPieChart:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Configured chart dimension in pixels. |

**Example**

```lua
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
```

---

#### `LPieChart:render`

Renders the chart into raw RGBA image bytes.

```lua
LPieChart:render()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width; height; and RGBA image bytes for the rendered chart. (value 1). |
| number | Width; height; and RGBA image bytes for the rendered chart. (value 2). |
| string | Width; height; and RGBA image bytes for the rendered chart. (value 3). |

**Example**

```lua
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
```

---

#### `LPieChart:renderImage`

Renders the chart into a new [LImage](render.md#limage) userdata.

```lua
LPieChart:renderImage()
```

**Example**

```lua
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
```

---

#### `LPieChart:setShowLegend`

Controls whether the chart legend is rendered.

```lua
LPieChart:setShowLegend(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | boolean | Parameter value for this chart operation. |

**Example**

```lua
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
```

---

#### `LPieChart:setTitle`

Sets the chart title text shown in rendered output.

```lua
LPieChart:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | string | Parameter value for this chart operation. |

**Example**

```lua
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
```

---

#### `LPieChart:type`

Returns the runtime userdata type name for this chart.

```lua
LPieChart:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Runtime userdata type name. |

**Example**

```lua
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
```

---

#### `LPieChart:typeOf`

Checks whether a type name matches this chart userdata.

```lua
LPieChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this chart userdata. |

**Example**

```lua
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
```

---

## LRadarChart

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LRadarChart:addSeries`

Adds or replaces a named radar series.

```lua
LRadarChart:addSeries(name, values, color)
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
    local chart = lurek.charts.newRadar({ width = 160, height = 120, title = "Radar" })
    chart:setAxes({ "speed", "power", "range", "cost" })
    chart:addSeries("Scout", { 5, 2, 4, 3 })
    chart:addSeries("Scout", { 5, 2, 4, 3 })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("addSeries width=" .. tostring(width))
    lurek.log.info("addSeries height=" .. tostring(height))
end
```

---

#### `LRadarChart:clear`

Clears all chart data and cached chart state.

```lua
LRadarChart:clear()
```

**Example**

```lua
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
```

---

#### `LRadarChart:clearMaxValue`

Clears the explicit maximum radial value.

```lua
LRadarChart:clearMaxValue()
```

**Example**

```lua
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
```

---

#### `LRadarChart:draw`

Draws the chart at world or screen coordinates using optional transform options.

```lua
LRadarChart:draw(x, y, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Draw X coordinate. |
| `y` | number | Draw Y coordinate. |
| `opts?` | table | Optional render transform options. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
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
```

---

#### `LRadarChart:drawToImage`

Draws the rendered chart into an existing image.

```lua
LRadarChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | userdata | ImageData target to receive chart pixels. |

**Example**

```lua
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
```

---

#### `LRadarChart:getHeight`

Returns the configured chart height in pixels.

```lua
LRadarChart:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Configured chart height in pixels. |

**Example**

```lua
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
```

---

#### `LRadarChart:getWidth`

Returns the configured chart width in pixels.

```lua
LRadarChart:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Configured chart width in pixels. |

**Example**

```lua
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
```

---

#### `LRadarChart:render`

Renders the chart into raw RGBA image bytes.

```lua
LRadarChart:render()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width; height; and RGBA image bytes for the rendered chart. (value 1). |
| number | Width; height; and RGBA image bytes for the rendered chart. (value 2). |
| string | Width; height; and RGBA image bytes for the rendered chart. (value 3). |

**Example**

```lua
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
```

---

#### `LRadarChart:renderImage`

Renders the chart into a new [LImage](render.md#limage) userdata.

```lua
LRadarChart:renderImage()
```

**Example**

```lua
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
```

---

#### `LRadarChart:setAxes`

Replaces radar axis labels.

```lua
LRadarChart:setAxes(axes)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `axes` | any |  |

**Example**

```lua
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
```

---

#### `LRadarChart:setMaxValue`

Sets the explicit maximum radial value.

```lua
LRadarChart:setMaxValue(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any |  |

**Example**

```lua
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
```

---

#### `LRadarChart:setShowLegend`

Controls whether the chart legend is rendered.

```lua
LRadarChart:setShowLegend(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | boolean | True to show the legend. |

**Example**

```lua
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
```

---

#### `LRadarChart:setTitle`

Sets the chart title text shown in rendered output.

```lua
LRadarChart:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | string | New chart title. |

**Example**

```lua
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
```

---

#### `LRadarChart:type`

Returns the runtime userdata type name for this chart.

```lua
LRadarChart:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Runtime userdata type name. |

**Example**

```lua
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
```

---

#### `LRadarChart:typeOf`

Checks whether a type name matches this chart userdata.

```lua
LRadarChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this chart userdata. |

**Example**

```lua
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
| `name` | string | Parameter value for this chart operation. |
| `data` | table | Parameter value for this chart operation. |
| `color?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:addSeries("north", { { 1, 9 }, { 2, 14 }, { 3, 11 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("addSeries width=" .. tostring(width))
    lurek.log.info("addSeries height=" .. tostring(height))
end
```

---

#### `LScatterPlot:addSeriesFromDataFrame`

Builds a named scatter series from x and y columns in a dataframe.

```lua
LScatterPlot:addSeriesFromDataFrame(name, df, x_col, y_col, color, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Parameter value for this chart operation. |
| `df` | userdata | Parameter value for this chart operation. |
| `x_col` | string | Parameter value for this chart operation. |
| `y_col` | string | Parameter value for this chart operation. |
| `color?` | table | Parameter value for this chart operation. |
| `opts?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
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
| `name` | string | Parameter value for this chart operation. |
| `x` | number | Parameter value for this chart operation. |
| `y` | number | Parameter value for this chart operation. |
| `color?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:appendPoint("north", 4, 17)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("appendPoint width=" .. tostring(width))
    lurek.log.info("appendPoint height=" .. tostring(height))
end
```

---

#### `LScatterPlot:clear`

Clears all series and cached chart state.

```lua
LScatterPlot:clear()
```

**Example**

```lua
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
| `x` | number | Parameter value for this chart operation. |
| `y` | number | Parameter value for this chart operation. |
| `opts?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
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
```

---

#### `LScatterPlot:drawToImage`

Draws the rendered chart into an existing image.

```lua
LScatterPlot:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | userdata | Parameter value for this chart operation. |

**Example**

```lua
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
```

---

#### `LScatterPlot:getHeight`

Returns the configured chart height in pixels.

```lua
LScatterPlot:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Configured chart dimension in pixels. |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    lurek.log.info("height=" .. tostring(chart:getHeight()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getHeight width=" .. tostring(width))
    lurek.log.info("getHeight height=" .. tostring(height))
end
```

---

#### `LScatterPlot:getWidth`

Returns the configured chart width in pixels.

```lua
LScatterPlot:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Configured chart dimension in pixels. |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    lurek.log.info("width=" .. tostring(chart:getWidth()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("getWidth width=" .. tostring(width))
    lurek.log.info("getWidth height=" .. tostring(height))
end
```

---

#### `LScatterPlot:nearest`

Finds the nearest plotted point to screen coordinates.

```lua
LScatterPlot:nearest(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Parameter value for this chart operation. |
| `y` | number | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| table | Nearest point table, or nil when no point is available. |

**Example**

```lua
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
```

---

#### `LScatterPlot:render`

Renders the chart into raw RGBA image bytes.

```lua
LScatterPlot:render()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width; height; and RGBA image bytes for the rendered chart. (value 1). |
| number | Width; height; and RGBA image bytes for the rendered chart. (value 2). |
| string | Width; height; and RGBA image bytes for the rendered chart. (value 3). |

**Example**

```lua
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
```

---

#### `LScatterPlot:renderImage`

Renders the chart into a new [LImage](render.md#limage) userdata.

```lua
LScatterPlot:renderImage()
```

**Example**

```lua
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
| `name` | string | Parameter value for this chart operation. |
| `data` | table | Parameter value for this chart operation. |
| `color?` | table | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:replaceSeries("north", { { 1, 9 }, { 2, 14 }, { 3, 11 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("replaceSeries width=" .. tostring(width))
    lurek.log.info("replaceSeries height=" .. tostring(height))
end
```

---

#### `LScatterPlot:setDotRadius`

Sets the rendered radius used for scatter dots.

```lua
LScatterPlot:setDotRadius(radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `radius` | number | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setDotRadius(4)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setDotRadius width=" .. tostring(width))
    lurek.log.info("setDotRadius height=" .. tostring(height))
end
```

---

#### `LScatterPlot:setShowLegend`

Controls whether the chart legend is rendered.

```lua
LScatterPlot:setShowLegend(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | boolean | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setShowLegend(true)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setShowLegend width=" .. tostring(width))
    lurek.log.info("setShowLegend height=" .. tostring(height))
end
```

---

#### `LScatterPlot:setTitle`

Sets the chart title text shown in rendered output.

```lua
LScatterPlot:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | string | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setTitle("Scatter example")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setTitle width=" .. tostring(width))
    lurek.log.info("setTitle height=" .. tostring(height))
end
```

---

#### `LScatterPlot:setWindow`

Sets the maximum retained sample window for this chart.

```lua
LScatterPlot:setWindow(max_points)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `max_points?` | number | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setWindow(2)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setWindow width=" .. tostring(width))
    lurek.log.info("setWindow height=" .. tostring(height))
end
```

---

#### `LScatterPlot:setXLabel`

Sets the X axis label text for rendered output.

```lua
LScatterPlot:setXLabel(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | string | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setXLabel("Month")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setXLabel width=" .. tostring(width))
    lurek.log.info("setXLabel height=" .. tostring(height))
end
```

---

#### `LScatterPlot:setXRange`

Sets the explicit X axis range for plotted points.

```lua
LScatterPlot:setXRange(min_x, max_x)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min_x` | number | Parameter value for this chart operation. |
| `max_x` | number | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setXRange(0, 6)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setXRange width=" .. tostring(width))
    lurek.log.info("setXRange height=" .. tostring(height))
end
```

---

#### `LScatterPlot:setXTickCount`

Sets the number of X axis ticks drawn for this chart.

```lua
LScatterPlot:setXTickCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | number | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setXTickCount(4)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setXTickCount width=" .. tostring(width))
    lurek.log.info("setXTickCount height=" .. tostring(height))
end
```

---

#### `LScatterPlot:setYLabel`

Sets the Y axis label text for rendered output.

```lua
LScatterPlot:setYLabel(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | string | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setYLabel("Value")
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setYLabel width=" .. tostring(width))
    lurek.log.info("setYLabel height=" .. tostring(height))
end
```

---

#### `LScatterPlot:setYRange`

Sets the explicit Y axis range for plotted points.

```lua
LScatterPlot:setYRange(min_y, max_y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min_y` | number | Parameter value for this chart operation. |
| `max_y` | number | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setYRange(0, 30)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setYRange width=" .. tostring(width))
    lurek.log.info("setYRange height=" .. tostring(height))
end
```

---

#### `LScatterPlot:setYTickCount`

Sets the number of Y axis ticks drawn for this chart.

```lua
LScatterPlot:setYTickCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | number | Parameter value for this chart operation. |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setYTickCount(4)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("setYTickCount width=" .. tostring(width))
    lurek.log.info("setYTickCount height=" .. tostring(height))
end
```

---

#### `LScatterPlot:type`

Returns the runtime userdata type name for this chart.

```lua
LScatterPlot:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Runtime userdata type name. |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 160, height = 120, title = "Scatter" })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    lurek.log.info("type=" .. tostring(chart:type()))
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("type width=" .. tostring(width))
    lurek.log.info("type height=" .. tostring(height))
end
```

---

#### `LScatterPlot:typeOf`

Checks whether a type name matches this chart userdata.

```lua
LScatterPlot:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Parameter value for this chart operation. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this chart userdata. |

**Example**

```lua
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
```

---

## LTreemapChart

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTreemapChart:addItem`

Adds one weighted treemap item.

```lua
LTreemapChart:addItem(label, value, color)
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
    local chart = lurek.charts.newTreemap({ width = 160, height = 120, title = "Treemap" })
    chart:addItem("Rendering", 45)
    chart:addItem("Audio", 18)
    chart:addItem("Input", 12)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("addItem width=" .. tostring(width))
    lurek.log.info("addItem height=" .. tostring(height))
end
```

---

#### `LTreemapChart:clear`

Clears all chart data and cached chart state.

```lua
LTreemapChart:clear()
```

**Example**

```lua
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
```

---

#### `LTreemapChart:draw`

Draws the chart at world or screen coordinates using optional transform options.

```lua
LTreemapChart:draw(x, y, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Draw X coordinate. |
| `y` | number | Draw Y coordinate. |
| `opts?` | table | Optional render transform options. |

**Returns**

| Type | Description |
|------|-------------|
| nil | Return value produced by this chart operation. |

**Example**

```lua
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
```

---

#### `LTreemapChart:drawToImage`

Draws the rendered chart into an existing image.

```lua
LTreemapChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | userdata | ImageData target to receive chart pixels. |

**Example**

```lua
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
```

---

#### `LTreemapChart:getHeight`

Returns the configured chart height in pixels.

```lua
LTreemapChart:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Configured chart height in pixels. |

**Example**

```lua
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
```

---

#### `LTreemapChart:getWidth`

Returns the configured chart width in pixels.

```lua
LTreemapChart:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Configured chart width in pixels. |

**Example**

```lua
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
```

---

#### `LTreemapChart:render`

Renders the chart into raw RGBA image bytes.

```lua
LTreemapChart:render()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width; height; and RGBA image bytes for the rendered chart. (value 1). |
| number | Width; height; and RGBA image bytes for the rendered chart. (value 2). |
| string | Width; height; and RGBA image bytes for the rendered chart. (value 3). |

**Example**

```lua
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
```

---

#### `LTreemapChart:renderImage`

Renders the chart into a new [LImage](render.md#limage) userdata.

```lua
LTreemapChart:renderImage()
```

**Example**

```lua
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
```

---

#### `LTreemapChart:setItems`

Replaces weighted treemap items from label/value rows or fields.

```lua
LTreemapChart:setItems(items)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `items` | any |  |

**Example**

```lua
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
```

---

#### `LTreemapChart:setShowLegend`

Controls whether the chart legend is rendered.

```lua
LTreemapChart:setShowLegend(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | boolean | True to show the legend. |

**Example**

```lua
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
```

---

#### `LTreemapChart:setTitle`

Sets the chart title text shown in rendered output.

```lua
LTreemapChart:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | string | New chart title. |

**Example**

```lua
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
```

---

#### `LTreemapChart:type`

Returns the runtime userdata type name for this chart.

```lua
LTreemapChart:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Runtime userdata type name. |

**Example**

```lua
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
```

---

#### `LTreemapChart:typeOf`

Checks whether a type name matches this chart userdata.

```lua
LTreemapChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this chart userdata. |

**Example**

```lua
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
```

---
