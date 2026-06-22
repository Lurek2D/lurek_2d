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
    local chart = lurek.charts.newLine({ width = 400, height = 300, title = "Monthly Sales" })
    chart:addSeries("North", {{1, 12}, {2, 18}, {3, 15}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("line chart created=" .. tostring(chart ~= nil))
    lurek.log.info("line chart size=" .. tostring(width) .. "x" .. tostring(height))
end
```

## Common Patterns

- Start with `lurek.charts.defaultPalette` when exploring this module.
- Start with `lurek.charts.newArea` when exploring this module.
- Start with `lurek.charts.newBar` when exploring this module.
- Start with `lurek.charts.newHeatmap` when exploring this module.
- Start with `lurek.charts.newHistogram` when exploring this module.

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
    local pal = lurek.charts.defaultPalette()
    example_print_log("palette colors = " .. #pal)
    if #pal > 0 then
        example_print_log("first color r=" .. string.format("%.2f", pal[1][1]))
    end
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
    local chart = lurek.charts.newArea({ width = 400, height = 300, title = "Cumulative Users" })
    chart:addSeries("Users", {{1, 20}, {2, 32}, {3, 50}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("area chart created=" .. tostring(chart ~= nil))
    lurek.log.info("area chart size=" .. tostring(width) .. "x" .. tostring(height))
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
    local chart = lurek.charts.newBar({ width = 400, height = 300, title = "Revenue by Category" })
    chart:addSeries("Weapons", {{1, 20}, {2, 14}, {3, 18}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("bar chart created=" .. tostring(chart ~= nil))
    lurek.log.info("bar chart size=" .. tostring(width) .. "x" .. tostring(height))
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
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180, title = "Region Load" })
    chart:setMatrix({ { 2, 4 }, { 6, 8 } }, { "North", "South" }, { "Q1", "Q2" })
    local typeName = chart:type()
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("heatmap type=" .. tostring(typeName))
    lurek.log.info("heatmap size=" .. tostring(width) .. "x" .. tostring(height))
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
    local chart = lurek.charts.newHistogram({ width = 320, height = 180, title = "Response Times" })
    chart:addSeries("ms", { 14, 18, 22, 18, 15, 21, 29, 18 })
    local typeName = chart:type()
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("histogram type=" .. tostring(typeName))
    lurek.log.info("histogram size=" .. tostring(width) .. "x" .. tostring(height))
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
    local chart = lurek.charts.newLine({ width = 400, height = 300, title = "Monthly Sales" })
    chart:addSeries("North", {{1, 12}, {2, 18}, {3, 15}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("line chart created=" .. tostring(chart ~= nil))
    lurek.log.info("line chart size=" .. tostring(width) .. "x" .. tostring(height))
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
    local chart = lurek.charts.newPie({ width = 300, height = 300, title = "Market Share" })
    chart:addSlice("North", 42)
    chart:addSlice("South", 33)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("pie chart created=" .. tostring(chart ~= nil))
    lurek.log.info("pie chart size=" .. tostring(width) .. "x" .. tostring(height))
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
    local chart = lurek.charts.newScatter({ width = 400, height = 300, title = "Test Scores" })
    chart:addSeries("Players", {{1, 12}, {2, 18}, {3, 14}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("scatter chart created=" .. tostring(chart ~= nil))
    lurek.log.info("scatter chart size=" .. tostring(width) .. "x" .. tostring(height))
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
    local c = lurek.charts.seriesColor(1)
    local c2 = lurek.charts.seriesColor(2)
    local firstColor = string.format("%.2f,%.2f,%.2f", c[1], c[2], c[3])
    local secondColor = string.format("%.2f,%.2f,%.2f", c2[1], c2[2], c2[3])
    lurek.log.info("series 1 color=" .. tostring(firstColor) .. " a=" .. string.format("%.2f", c[4]))
    lurek.log.info("series 2 color=" .. tostring(secondColor) .. " differs=" .. tostring(firstColor ~= secondColor))
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
    local chart = lurek.charts.newArea({ width = 320, height = 180, title = "Area Layers" })
    chart:addLayer("north", { 10, 14, 18, 20 })
    chart:addLayer("south", { 8, 11, 14, 16 })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("added area layers north and south")
    lurek.log.info("area layer chart size=" .. tostring(width) .. "x" .. tostring(height))
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
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    local df = charts_df()
    local added = chart:addLayerFromDataFrame("north", df, "north")
    example_print_log("rows added = " .. tostring(added))
    example_print_log("height = " .. chart:getHeight())
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
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    chart:addSeries("series1", { {1, 1}, {2, 3}, {3, 2}, {4, 5}, {5, 4} })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("area series added for trend view")
    lurek.log.info("area chart size=" .. tostring(width) .. "x" .. tostring(height))
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
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:addSeries("trend", { { 1, 12 }, { 2, 16 } })
    chart:appendPoint("trend", 3, 21)
    local _, _, pixels = chart:render()
    example_print_log("append point pixels = " .. #pixels)
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
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 1}, {2, 2}, {3, 3} })
    chart:clear()
    local w, h, pixels = chart:render()
    example_print_log("LAreaChart:clear ok")
    example_print_log("render bytes = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
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
    local chart = lurek.charts.newArea({ width = 256, height = 128 })
    chart:addLayer("north", { 5, 6, 9, 12 })
    chart:draw(24, 16, {})
    example_print_log("draw call issued")
    example_print_log("area type = " .. chart:type())
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
    local chart = lurek.charts.newArea({ width = 256, height = 128 })
    local target = chart_target_image(256, 128)
    chart:addLayer("north", { 5, 6, 9, 12 })
    chart:drawToImage(target)
    example_print_log("target size = " .. target:getWidth() .. "x" .. target:getHeight())
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
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    chart:addSeries("North", {{1, 5}, {2, 7}, {3, 8}})
    local height = chart:getHeight()
    local width = chart:getWidth()
    lurek.log.info("area height=" .. tostring(height))
    lurek.log.info("area width=" .. tostring(width))
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
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    chart:addSeries("North", {{1, 5}, {2, 7}, {3, 8}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("area width=" .. tostring(width))
    lurek.log.info("area height=" .. tostring(height))
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
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 5}, {2, 3}, {3, 8}, {4, 2}, {5, 6} })
    local w, h, pixels = chart:render()
    example_print_log("LAreaChart:render ok")
    example_print_log("pixels = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
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
    local chart = lurek.charts.newArea({ width = 256, height = 128 })
    chart:addLayer("north", { 5, 6, 9, 12 })
    local img = chart:renderImage()
    example_print_log("render image type = " .. img:type())
    example_print_log("render image size = " .. img:getWidth() .. "x" .. img:getHeight())
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
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:addLayer("north", { 5, 6, 7, 8 })
    chart:addLayer("south", { 4, 5, 5, 6 })
    chart:setShowLegend(true)
    local _, _, pixels = chart:render()
    example_print_log("legend bytes = " .. #pixels)
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
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    chart:setTitle("Monthly Sales")
    chart:addSeries("North", {{1, 5}, {2, 7}, {3, 8}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("area title set for monthly sales")
    lurek.log.info("area chart size=" .. tostring(width) .. "x" .. tostring(height))
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
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:addSeries("trend", { { 1, 8 }, { 2, 12 }, { 3, 15 }, { 4, 19 } })
    chart:setWindow(2)
    local _, _, pixels = chart:render()
    example_print_log("windowed render bytes = " .. #pixels)
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
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:setXLabel("Month")
    chart:setYLabel("Users")
    local _, _, pixels = chart:render()
    example_print_log("labeled area bytes = " .. #pixels)
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
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:setXTickCount(5)
    chart:addLayer("api", { 3, 5, 8, 13 })
    local _, _, pixels = chart:render()
    example_print_log("x ticks bytes = " .. #pixels)
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
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:setYLabel("Requests")
    chart:addLayer("api", { 3, 5, 8, 13 })
    local _, _, pixels = chart:render()
    example_print_log("area label bytes = " .. #pixels)
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
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:addSeries("trend", { { 1, 8 }, { 2, 12 }, { 3, 15 } })
    chart:setYMax(20)
    example_print_log("manual y max applied")
    example_print_log("type = " .. chart:type())
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
    local chart = lurek.charts.newArea({ width = 320, height = 180 })
    chart:setYTickCount(6)
    chart:addLayer("api", { 3, 5, 8, 13 })
    local _, _, pixels = chart:render()
    example_print_log("y ticks bytes = " .. #pixels)
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
    local chart = lurek.charts.newArea({ width = 256, height = 128 })
    chart:addLayer("north", { 5, 6, 9, 12 })
    local typeName = chart:type()
    local isObject = chart:typeOf("LObject")
    lurek.log.info("area chart type=" .. tostring(typeName))
    lurek.log.info("area chart is object=" .. tostring(isObject))
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
    local chart = lurek.charts.newArea({ width = 256, height = 128 })
    chart:addLayer("north", { 5, 6, 9, 12 })
    local isArea = chart:typeOf("LAreaChart")
    local isBar = chart:typeOf("LBarChart")
    lurek.log.info("typeOf LAreaChart=" .. tostring(isArea))
    lurek.log.info("typeOf LBarChart=" .. tostring(isBar))
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
    local chart = lurek.charts.newBar({ width = 320, height = 180 })
    local df = charts_df()
    local added = chart:addCategoriesFromDataFrame(df, "label", { "north", "south", "east" })
    example_print_log("categories added = " .. tostring(added))
    example_print_log("height = " .. chart:getHeight())
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
    local chart = lurek.charts.newBar({ width = 320, height = 180 })
    chart:addCategory("Q1", { 12, 8, 5 })
    chart:addCategory("Q2", { 18, 11, 7 })
    local _, _, pixels = chart:render()
    example_print_log("categories bytes = " .. #pixels)
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
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:addSeries("series1", { {1, 1}, {2, 3}, {3, 2}, {4, 5}, {5, 4} })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("bar series added for quarterly sales")
    lurek.log.info("bar chart size=" .. tostring(width) .. "x" .. tostring(height))
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
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 1}, {2, 2}, {3, 3} })
    chart:clear()
    local w, h, pixels = chart:render()
    example_print_log("LBarChart:clear ok")
    example_print_log("render bytes = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
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
    local chart = lurek.charts.newBar({ width = 256, height = 128 })
    chart:addCategory("Q1", { 12, 8, 5 })
    chart:draw(12, 8, {})
    example_print_log("bar draw issued")
    example_print_log("bar type = " .. chart:type())
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
    local chart = lurek.charts.newBar({ width = 256, height = 128 })
    local target = chart_target_image(256, 128)
    chart:addCategory("Q1", { 12, 8, 5 })
    chart:drawToImage(target)
    example_print_log("bar target bytes = " .. target:getWidth() .. "x" .. target:getHeight())
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
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:addSeries("North", {{1, 10}, {2, 12}, {3, 14}})
    local height = chart:getHeight()
    local width = chart:getWidth()
    lurek.log.info("bar height=" .. tostring(height))
    lurek.log.info("bar width=" .. tostring(width))
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
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:addSeries("North", {{1, 10}, {2, 12}, {3, 14}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("bar width=" .. tostring(width))
    lurek.log.info("bar height=" .. tostring(height))
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
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 5}, {2, 3}, {3, 8}, {4, 2}, {5, 6} })
    local w, h, pixels = chart:render()
    example_print_log("LBarChart:render ok")
    example_print_log("pixels = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
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
    local chart = lurek.charts.newBar({ width = 256, height = 128 })
    chart:addCategory("Q1", { 12, 8, 5 })
    local img = chart:renderImage()
    example_print_log("bar image type = " .. img:type())
    example_print_log("bar image size = " .. img:getWidth() .. "x" .. img:getHeight())
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
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:setBarWidth(20.0)
    chart:addSeries("North", {{1, 10}, {2, 12}, {3, 14}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("bar width set to 20")
    lurek.log.info("bar chart size=" .. tostring(width) .. "x" .. tostring(height))
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
    local chart = lurek.charts.newBar({ width = 320, height = 180 })
    chart:addCategory("Q1", { 12, 8, 5 })
    chart:addCategory("Q2", { 18, 11, 7 })
    chart:setShowLegend(true)
    local _, _, pixels = chart:render()
    example_print_log("bar legend bytes = " .. #pixels)
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
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    chart:setTitle("Monthly Sales")
    chart:addSeries("North", {{1, 10}, {2, 12}, {3, 14}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("bar title set for monthly sales")
    lurek.log.info("bar chart size=" .. tostring(width) .. "x" .. tostring(height))
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
    local chart = lurek.charts.newBar({ width = 320, height = 180 })
    chart:setXLabel("Quarter")
    chart:addCategory("Q1", { 12, 8, 5 })
    local _, _, pixels = chart:render()
    example_print_log("bar x label bytes = " .. #pixels)
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
    local chart = lurek.charts.newBar({ width = 320, height = 180 })
    chart:setXTickCount(4)
    chart:addCategory("Q1", { 12, 8, 5 })
    chart:addCategory("Q2", { 18, 11, 7 })
    local _, _, pixels = chart:render()
    example_print_log("bar x ticks bytes = " .. #pixels)
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
    local chart = lurek.charts.newBar({ width = 320, height = 180 })
    chart:setYLabel("Sales")
    chart:addCategory("Q1", { 12, 8, 5 })
    local _, _, pixels = chart:render()
    example_print_log("bar y label bytes = " .. #pixels)
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
    local chart = lurek.charts.newBar({ width = 320, height = 180 })
    chart:setYTickCount(6)
    chart:addCategory("Q1", { 12, 8, 5 })
    chart:addCategory("Q2", { 18, 11, 7 })
    local _, _, pixels = chart:render()
    example_print_log("bar y ticks bytes = " .. #pixels)
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
    local chart = lurek.charts.newBar({ width = 256, height = 128 })
    chart:addCategory("Q1", { 12, 8, 5 })
    local typeName = chart:type()
    local isObject = chart:typeOf("LObject")
    lurek.log.info("bar chart type=" .. tostring(typeName))
    lurek.log.info("bar chart is object=" .. tostring(isObject))
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
    local chart = lurek.charts.newBar({ width = 256, height = 128 })
    chart:addCategory("Q1", { 12, 8, 5 })
    local isBar = chart:typeOf("LBarChart")
    local isArea = chart:typeOf("LAreaChart")
    lurek.log.info("typeOf LBarChart=" .. tostring(isBar))
    lurek.log.info("typeOf LAreaChart=" .. tostring(isArea))
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
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    chart:clear()
    local _, _, pixels = chart:render()
    example_print_log("cleared heatmap bytes = " .. #pixels)
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
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:setValueRange(0, 10)
    chart:clearValueRange()
    local _, _, pixels = chart:render()
    example_print_log("cleared range bytes = " .. #pixels)
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
    local chart = lurek.charts.newHeatmap({ width = 256, height = 128 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:draw(18, 10, {})
    example_print_log("heatmap draw issued")
    example_print_log("heatmap type = " .. chart:type())
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
    local chart = lurek.charts.newHeatmap({ width = 256, height = 128 })
    local target = chart_target_image(256, 128)
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:drawToImage(target)
    example_print_log("heatmap target width = " .. target:getWidth())
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
    local chart = lurek.charts.newHeatmap({ width = 333, height = 144 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    local height = chart:getHeight()
    local width = chart:getWidth()
    lurek.log.info("heatmap height=" .. tostring(height))
    lurek.log.info("heatmap width=" .. tostring(width))
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
    local chart = lurek.charts.newHeatmap({ width = 333, height = 144 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("heatmap width=" .. tostring(width))
    lurek.log.info("heatmap height=" .. tostring(height))
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
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    local w, h, pixels = chart:render()
    example_print_log("render size = " .. w .. "x" .. h)
    example_print_log("render bytes = " .. #pixels)
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
    local chart = lurek.charts.newHeatmap({ width = 256, height = 128 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    local img = chart:renderImage()
    example_print_log("heatmap image type = " .. img:type())
    example_print_log("heatmap image width = " .. img:getWidth())
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
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:resize(3, 2)
    chart:setCell(1, 1, 1.5)
    chart:setCell(3, 2, 4.5)
    local _, _, pixels = chart:render()
    example_print_log("resized heatmap bytes = " .. #pixels)
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
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:resize(2, 2)
    chart:setCell(1, 1, 2.5)
    chart:setCell(2, 2, 7.5)
    local _, _, pixels = chart:render()
    example_print_log("heatmap cell bytes = " .. #pixels)
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
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:setColorRange({ 0.10, 0.20, 0.60, 1.0 }, { 0.90, 0.20, 0.10, 1.0 })
    local _, _, pixels = chart:render()
    example_print_log("color range bytes = " .. #pixels)
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
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:setColumnLabels({ "Q1", "Q2" })
    local _, _, pixels = chart:render()
    example_print_log("column labels bytes = " .. #pixels)
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
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } }, { "North", "South" }, { "Q1", "Q2" })
    local _, _, pixels = chart:render()
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("heatmap matrix bytes=" .. tostring(#pixels))
    lurek.log.info("heatmap size=" .. tostring(width) .. "x" .. tostring(height))
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
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    local df = charts_df()
    local cells = chart:setMatrixFromDataFrame(df, "row", "col", "value")
    example_print_log("matrix cells = " .. tostring(cells))
    example_print_log("width = " .. chart:getWidth())
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
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:setRowLabels({ "North", "South" })
    local _, _, pixels = chart:render()
    example_print_log("row labels bytes = " .. #pixels)
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
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:setShowLegend(true)
    local _, _, pixels = chart:render()
    example_print_log("heatmap legend bytes = " .. #pixels)
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
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:setShowValues(true)
    local _, _, pixels = chart:render()
    example_print_log("show values bytes = " .. #pixels)
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
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setTitle("Throughput Grid")
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    local _, _, pixels = chart:render()
    example_print_log("heatmap title bytes = " .. #pixels)
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
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    chart:setValueRange(0, 10)
    local _, _, pixels = chart:render()
    example_print_log("value range bytes = " .. #pixels)
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
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    local typeName = chart:type()
    local isObject = chart:typeOf("LObject")
    lurek.log.info("heatmap type=" .. tostring(typeName))
    lurek.log.info("heatmap is object=" .. tostring(isObject))
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
    local chart = lurek.charts.newHeatmap({ width = 320, height = 180 })
    chart:setMatrix({ { 1, 2 }, { 3, 4 } })
    local isHeatmap = chart:typeOf("LHeatmapChart")
    local isPie = chart:typeOf("LPieChart")
    lurek.log.info("typeOf LHeatmapChart=" .. tostring(isHeatmap))
    lurek.log.info("typeOf LPieChart=" .. tostring(isPie))
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
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 18, 22, 25, 18 })
    local _, _, pixels = chart:render()
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("histogram render bytes=" .. tostring(#pixels))
    lurek.log.info("histogram size=" .. tostring(width) .. "x" .. tostring(height))
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
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    local df = charts_df()
    local added = chart:addSeriesFromDataFrame("north", df, "north")
    example_print_log("histogram rows added = " .. tostring(added))
    example_print_log("width = " .. chart:getWidth())
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
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18 })
    chart:appendValue("response", 21)
    local _, _, pixels = chart:render()
    example_print_log("append histogram bytes = " .. #pixels)
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
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18 })
    chart:clear()
    local _, _, pixels = chart:render()
    example_print_log("cleared histogram bytes = " .. #pixels)
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
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    chart:setRange(10, 30)
    chart:clearRange()
    local _, _, pixels = chart:render()
    example_print_log("clear range histogram bytes = " .. #pixels)
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
    local chart = lurek.charts.newHistogram({ width = 256, height = 128 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    chart:draw(16, 8, {})
    example_print_log("histogram draw issued")
    example_print_log("histogram type = " .. chart:type())
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
    local chart = lurek.charts.newHistogram({ width = 256, height = 128 })
    local target = chart_target_image(256, 128)
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    chart:drawToImage(target)
    example_print_log("histogram target width = " .. target:getWidth())
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
    local chart = lurek.charts.newHistogram({ width = 345, height = 176 })
    chart:addSeries("response", { 12, 14, 18, 21 })
    local height = chart:getHeight()
    local width = chart:getWidth()
    lurek.log.info("histogram height=" .. tostring(height))
    lurek.log.info("histogram width=" .. tostring(width))
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
    local chart = lurek.charts.newHistogram({ width = 345, height = 176 })
    chart:addSeries("response", { 12, 14, 18, 21 })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("histogram width=" .. tostring(width))
    lurek.log.info("histogram height=" .. tostring(height))
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
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    local w, h, pixels = chart:render()
    example_print_log("histogram size = " .. w .. "x" .. h)
    example_print_log("histogram bytes = " .. #pixels)
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
    local chart = lurek.charts.newHistogram({ width = 256, height = 128 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    local img = chart:renderImage()
    example_print_log("histogram image type = " .. img:type())
    example_print_log("histogram image width = " .. img:getWidth())
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
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18 })
    chart:replaceSeries("response", { 30, 28, 26, 24 })
    local _, _, pixels = chart:render()
    example_print_log("replaced histogram bytes = " .. #pixels)
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
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    chart:setBinCount(5)
    local _, _, pixels = chart:render()
    example_print_log("bins histogram bytes = " .. #pixels)
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
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    chart:setDensity(true)
    local _, _, pixels = chart:render()
    example_print_log("density histogram bytes = " .. #pixels)
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
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    chart:setRange(10, 30)
    local _, _, pixels = chart:render()
    example_print_log("range histogram bytes = " .. #pixels)
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
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("north", { 12, 14, 18, 21 })
    chart:addSeries("south", { 9, 10, 11, 15 })
    chart:setShowLegend(true)
    local _, _, pixels = chart:render()
    example_print_log("histogram legend bytes = " .. #pixels)
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
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:setTitle("Response Times")
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    local _, _, pixels = chart:render()
    example_print_log("histogram title bytes = " .. #pixels)
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
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    chart:setWindow(4)
    local _, _, pixels = chart:render()
    example_print_log("window histogram bytes = " .. #pixels)
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
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:setXLabel("Latency")
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    local _, _, pixels = chart:render()
    example_print_log("histogram x label bytes = " .. #pixels)
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
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:setXTickCount(5)
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    local _, _, pixels = chart:render()
    example_print_log("histogram x ticks bytes = " .. #pixels)
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
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:setYLabel("Frequency")
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    local _, _, pixels = chart:render()
    example_print_log("histogram y label bytes = " .. #pixels)
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
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:setYTickCount(6)
    chart:addSeries("response", { 12, 14, 18, 21, 25, 19 })
    local _, _, pixels = chart:render()
    example_print_log("histogram y ticks bytes = " .. #pixels)
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
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 21 })
    local typeName = chart:type()
    local isObject = chart:typeOf("LObject")
    lurek.log.info("histogram type=" .. tostring(typeName))
    lurek.log.info("histogram is object=" .. tostring(isObject))
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
    local chart = lurek.charts.newHistogram({ width = 320, height = 180 })
    chart:addSeries("response", { 12, 14, 18, 21 })
    local isHistogram = chart:typeOf("LHistogramChart")
    local isLine = chart:typeOf("LLineChart")
    lurek.log.info("typeOf LHistogramChart=" .. tostring(isHistogram))
    lurek.log.info("typeOf LLineChart=" .. tostring(isLine))
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
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:addSeries("series1", { {1, 1}, {2, 3}, {3, 2}, {4, 5}, {5, 4} })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("line series added for cadence chart")
    lurek.log.info("line chart size=" .. tostring(width) .. "x" .. tostring(height))
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
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    local df = charts_df()
    local added = chart:addSeriesFromDataFrame("north", df, "month", "north")
    example_print_log("line rows added = " .. tostring(added))
    example_print_log("width = " .. chart:getWidth())
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
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 } })
    chart:appendPoint("north", 3, 15)
    local _, _, pixels = chart:render()
    example_print_log("line append bytes = " .. #pixels)
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
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 1}, {2, 2}, {3, 3} })
    chart:clear()
    local w, h, pixels = chart:render()
    example_print_log("LLineChart:clear ok")
    example_print_log("render bytes = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
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
    local chart = lurek.charts.newLine({ width = 256, height = 128 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:draw(20, 12, {})
    example_print_log("line draw issued")
    example_print_log("line type = " .. chart:type())
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
    local chart = lurek.charts.newLine({ width = 256, height = 128 })
    local target = chart_target_image(256, 128)
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:drawToImage(target)
    example_print_log("line target width = " .. target:getWidth())
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
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:addSeries("North", {{1, 10}, {2, 14}, {3, 11}})
    local height = chart:getHeight()
    local width = chart:getWidth()
    lurek.log.info("line height=" .. tostring(height))
    lurek.log.info("line width=" .. tostring(width))
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
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:addSeries("North", {{1, 10}, {2, 14}, {3, 11}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("line width=" .. tostring(width))
    lurek.log.info("line height=" .. tostring(height))
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
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local hit = chart:nearest(120, 80)
    example_print_log("line nearest found = " .. tostring(hit ~= nil))
    example_print_log("line nearest series = " .. tostring(hit and hit.series))
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
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 5}, {2, 3}, {3, 8}, {4, 2}, {5, 6} })
    local w, h, pixels = chart:render()
    example_print_log("LLineChart:render ok")
    example_print_log("pixels = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
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
    local chart = lurek.charts.newLine({ width = 256, height = 128 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local img = chart:renderImage()
    example_print_log("line image type = " .. img:type())
    example_print_log("line image width = " .. img:getWidth())
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
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 } })
    chart:replaceSeries("north", { { 1, 9 }, { 2, 11 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    example_print_log("line replace bytes = " .. #pixels)
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
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:addSeries("south", { { 1, 8 }, { 2, 11 }, { 3, 16 } })
    chart:setShowLegend(true)
    local _, _, pixels = chart:render()
    example_print_log("line legend bytes = " .. #pixels)
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
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    chart:setTitle("Monthly Sales")
    chart:addSeries("North", {{1, 10}, {2, 14}, {3, 11}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("line title set for monthly sales")
    lurek.log.info("line chart size=" .. tostring(width) .. "x" .. tostring(height))
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
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 }, { 4, 24 } })
    chart:setWindow(2)
    local _, _, pixels = chart:render()
    example_print_log("line window bytes = " .. #pixels)
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
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:setXLabel("Month")
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    example_print_log("line x label bytes = " .. #pixels)
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
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setXMax(6)
    local _, _, pixels = chart:render()
    example_print_log("line x max bytes = " .. #pixels)
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
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:setXTickCount(5)
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    example_print_log("line x ticks bytes = " .. #pixels)
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
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:setYLabel("Users")
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    example_print_log("line y label bytes = " .. #pixels)
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
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setYMax(30)
    local _, _, pixels = chart:render()
    example_print_log("line y max bytes = " .. #pixels)
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
    local chart = lurek.charts.newLine({ width = 320, height = 180 })
    chart:setYTickCount(6)
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    example_print_log("line y ticks bytes = " .. #pixels)
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
    local chart = lurek.charts.newLine({ width = 256, height = 128 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local typeName = chart:type()
    local isObject = chart:typeOf("LObject")
    lurek.log.info("line chart type=" .. tostring(typeName))
    lurek.log.info("line chart is object=" .. tostring(isObject))
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
    local chart = lurek.charts.newLine({ width = 256, height = 128 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local isLine = chart:typeOf("LLineChart")
    local isArea = chart:typeOf("LAreaChart")
    lurek.log.info("typeOf LLineChart=" .. tostring(isLine))
    lurek.log.info("typeOf LAreaChart=" .. tostring(isArea))
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
    local chart = lurek.charts.newPie({ width = 320, height = 180 })
    chart:addSegment("North", 42, { 0.9, 0.3, 0.2, 1.0 })
    chart:addSegment("South", 33, { 0.2, 0.6, 0.9, 1.0 })
    local _, _, pixels = chart:render()
    example_print_log("pie segment bytes = " .. #pixels)
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
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    chart:addSlice("Food", 45.0, { 0.9, 0.3, 0.1, 1.0 })
    chart:addSlice("Transport", 20.0, { 0.2, 0.6, 0.9, 1.0 })
    example_print_log("LPieChart:addSlice ok")
    example_print_log("width = " .. tostring(chart:getWidth()))
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
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    chart:addSlice("A", 1)
    chart:addSlice("B", 2)
    chart:clear()
    local w, h, pixels = chart:render()
    example_print_log("LPieChart:clear ok")
    example_print_log("render bytes = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
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
    local chart = lurek.charts.newPie({ width = 256, height = 128 })
    chart:addSegment("North", 42)
    chart:addSegment("South", 33)
    chart:draw(20, 10, {})
    example_print_log("pie draw issued")
    example_print_log("pie type = " .. chart:type())
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
    local chart = lurek.charts.newPie({ width = 256, height = 128 })
    local target = chart_target_image(256, 128)
    chart:addSegment("North", 42)
    chart:addSegment("South", 33)
    chart:drawToImage(target)
    example_print_log("pie target width = " .. target:getWidth())
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
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    chart:addSlice("North", 42)
    chart:addSlice("South", 33)
    local height = chart:getHeight()
    local width = chart:getWidth()
    lurek.log.info("pie height=" .. tostring(height))
    lurek.log.info("pie width=" .. tostring(width))
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
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    chart:addSlice("North", 42)
    chart:addSlice("South", 33)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("pie width=" .. tostring(width))
    lurek.log.info("pie height=" .. tostring(height))
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
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    chart:addSlice("A", 5)
    chart:addSlice("B", 3)
    chart:addSlice("C", 8)
    local w, h, pixels = chart:render()
    example_print_log("LPieChart:render ok")
    example_print_log("pixels = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
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
    local chart = lurek.charts.newPie({ width = 256, height = 128 })
    chart:addSegment("North", 42)
    chart:addSegment("South", 33)
    local img = chart:renderImage()
    example_print_log("pie image type = " .. img:type())
    example_print_log("pie image width = " .. img:getWidth())
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
    local chart = lurek.charts.newPie({ width = 320, height = 180 })
    chart:addSegment("North", 42)
    chart:addSegment("South", 33)
    chart:setShowLegend(true)
    local _, _, pixels = chart:render()
    example_print_log("pie legend bytes = " .. #pixels)
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
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    chart:setTitle("Monthly Sales")
    chart:addSlice("North", 42)
    chart:addSlice("South", 33)
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("pie title set for monthly sales")
    lurek.log.info("pie chart size=" .. tostring(width) .. "x" .. tostring(height))
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
    local chart = lurek.charts.newPie({ width = 256, height = 128 })
    chart:addSegment("North", 42)
    chart:addSegment("South", 33)
    local typeName = chart:type()
    local isObject = chart:typeOf("LObject")
    lurek.log.info("pie chart type=" .. tostring(typeName))
    lurek.log.info("pie chart is object=" .. tostring(isObject))
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
    local chart = lurek.charts.newPie({ width = 256, height = 128 })
    chart:addSegment("North", 42)
    chart:addSegment("South", 33)
    local isPie = chart:typeOf("LPieChart")
    local isBar = chart:typeOf("LBarChart")
    lurek.log.info("typeOf LPieChart=" .. tostring(isPie))
    lurek.log.info("typeOf LBarChart=" .. tostring(isBar))
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
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:addSeries("series1", { {1, 1}, {2, 3}, {3, 2}, {4, 5}, {5, 4} })
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("scatter series added for player scores")
    lurek.log.info("scatter chart size=" .. tostring(width) .. "x" .. tostring(height))
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
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    local df = charts_df()
    local added = chart:addSeriesFromDataFrame("north", df, "x", "y")
    example_print_log("scatter rows added = " .. tostring(added))
    example_print_log("scatter width = " .. chart:getWidth())
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
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 } })
    chart:appendPoint("north", 3, 15)
    local _, _, pixels = chart:render()
    example_print_log("scatter append bytes = " .. #pixels)
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
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 1}, {2, 2}, {3, 3} })
    chart:clear()
    local w, h, pixels = chart:render()
    example_print_log("LScatterPlot:clear ok")
    example_print_log("render bytes = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
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
    local chart = lurek.charts.newScatter({ width = 256, height = 128 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:draw(20, 10, {})
    example_print_log("scatter draw issued")
    example_print_log("scatter type = " .. chart:type())
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
    local chart = lurek.charts.newScatter({ width = 256, height = 128 })
    local target = chart_target_image(256, 128)
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:drawToImage(target)
    example_print_log("scatter target width = " .. target:getWidth())
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
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:addSeries("Players", {{1, 10}, {2, 12}, {3, 18}})
    local height = chart:getHeight()
    local width = chart:getWidth()
    lurek.log.info("scatter height=" .. tostring(height))
    lurek.log.info("scatter width=" .. tostring(width))
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
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:addSeries("Players", {{1, 10}, {2, 12}, {3, 18}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("scatter width=" .. tostring(width))
    lurek.log.info("scatter height=" .. tostring(height))
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
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local hit = chart:nearest(120, 80)
    example_print_log("scatter nearest found = " .. tostring(hit ~= nil))
    example_print_log("scatter nearest series = " .. tostring(hit and hit.series))
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
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:addSeries("data", { {1, 5}, {2, 3}, {3, 8}, {4, 2}, {5, 6} })
    local w, h, pixels = chart:render()
    example_print_log("LScatterPlot:render ok")
    example_print_log("pixels = " .. tostring(#pixels) .. " for " .. tostring(w) .. "x" .. tostring(h))
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
    local chart = lurek.charts.newScatter({ width = 256, height = 128 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local img = chart:renderImage()
    example_print_log("scatter image type = " .. img:type())
    example_print_log("scatter image width = " .. img:getWidth())
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
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 } })
    chart:replaceSeries("north", { { 1, 9 }, { 2, 11 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    example_print_log("scatter replace bytes = " .. #pixels)
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
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:setDotRadius(5.0)
    chart:addSeries("Players", {{1, 10}, {2, 12}, {3, 18}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("scatter dot radius set to 5")
    lurek.log.info("scatter chart size=" .. tostring(width) .. "x" .. tostring(height))
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
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:addSeries("south", { { 1, 8 }, { 2, 11 }, { 3, 16 } })
    chart:setShowLegend(true)
    local _, _, pixels = chart:render()
    example_print_log("scatter legend bytes = " .. #pixels)
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
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    chart:setTitle("Monthly Sales")
    chart:addSeries("Players", {{1, 10}, {2, 12}, {3, 18}})
    local width = chart:getWidth()
    local height = chart:getHeight()
    lurek.log.info("scatter title set for monthly sales")
    lurek.log.info("scatter chart size=" .. tostring(width) .. "x" .. tostring(height))
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
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 }, { 4, 24 } })
    chart:setWindow(3)
    local _, _, pixels = chart:render()
    example_print_log("scatter window bytes = " .. #pixels)
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
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:setXLabel("Hours")
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    example_print_log("scatter x label bytes = " .. #pixels)
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
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setXRange(0, 6)
    local _, _, pixels = chart:render()
    example_print_log("scatter x range bytes = " .. #pixels)
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
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:setXTickCount(5)
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    example_print_log("scatter x ticks bytes = " .. #pixels)
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
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:setYLabel("Score")
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    example_print_log("scatter y label bytes = " .. #pixels)
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
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    chart:setYRange(0, 30)
    local _, _, pixels = chart:render()
    example_print_log("scatter y range bytes = " .. #pixels)
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
    local chart = lurek.charts.newScatter({ width = 320, height = 180 })
    chart:setYTickCount(6)
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local _, _, pixels = chart:render()
    example_print_log("scatter y ticks bytes = " .. #pixels)
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
    local chart = lurek.charts.newScatter({ width = 256, height = 128 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local typeName = chart:type()
    local isObject = chart:typeOf("LObject")
    lurek.log.info("scatter chart type=" .. tostring(typeName))
    lurek.log.info("scatter chart is object=" .. tostring(isObject))
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
    local chart = lurek.charts.newScatter({ width = 256, height = 128 })
    chart:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 } })
    local isScatter = chart:typeOf("LScatterPlot")
    local isPie = chart:typeOf("LPieChart")
    lurek.log.info("typeOf LScatterPlot=" .. tostring(isScatter))
    lurek.log.info("typeOf LPieChart=" .. tostring(isPie))
end
```

---
