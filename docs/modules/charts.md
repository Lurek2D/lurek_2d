# Charts

## Summary

The `charts` module turns numeric data into ready-to-display chart images using CPU rasterization. It supports common chart families in one place, so scripts can generate visual summaries without relying on a dedicated GPU chart pipeline.

Its main value is predictable image output from structured data. Callers provide series or slice values plus options, and the module produces RGBA buffers that can be shown in UI, overlays, reports, or saved artifacts. This keeps chart generation practical in both runtime and offline workflows.

Each chart type keeps its own rendering behavior, while shared configuration and drawing helpers enforce consistent defaults and visual rules. That split allows chart-specific flexibility without losing cross-chart consistency in dimensions, styling, and value mapping.

Because output is software-rasterized and deterministic, charts are easy to test and reproduce across environments. This makes the module useful for headless validation, automated evidence generation, and tooling scenarios where graphical backend assumptions should stay minimal.

Overall, the module provides a clean conversion boundary: data in, chart pixels out. Higher layers can handle layout and interaction, while `charts` focuses on reliable visual generation from tabular or series-based inputs.

## Functions

### `lurek.charts.defaultPalette`

Get the default 8-color series palette.

```lua
lurek.charts.defaultPalette()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of 8 color tables, each {r, g, b, a}. |

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

Create a new area chart exposed by the lurek engine.

```lua
lurek.charts.newArea(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | table | Optional chart configuration table. |

**Returns**

| Type | Description |
|------|-------------|
| [LAreaChart](#lareachart) | A area chart userdata object. |

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

Create a new bar chart exposed by the lurek engine.

```lua
lurek.charts.newBar(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | table | Optional chart configuration table. |

**Returns**

| Type | Description |
|------|-------------|
| [LBarChart](#lbarchart) | A bar chart userdata object. |

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 400, height = 300, title = "Revenue by Category" })
    print("bar chart created = " .. tostring(chart ~= nil))
    print("bar chart height = " .. tostring(chart:getHeight()))
end
```

---

### `lurek.charts.newLine`

Create a new line chart exposed by the lurek engine.

```lua
lurek.charts.newLine(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | table | Optional chart configuration table. |

**Returns**

| Type | Description |
|------|-------------|
| [LLineChart](#llinechart) | A line chart userdata object. |

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

Create a new pie chart exposed by the lurek engine.

```lua
lurek.charts.newPie(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | table | Optional chart configuration table. |

**Returns**

| Type | Description |
|------|-------------|
| [LPieChart](#lpiechart) | A pie chart userdata object. |

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

Create a new scatter plot exposed by the lurek engine.

```lua
lurek.charts.newScatter(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | table | Optional chart configuration table. |

**Returns**

| Type | Description |
|------|-------------|
| [LScatterPlot](#lscatterplot) | A scatter plot userdata object. |

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

Get a palette color by 1-based index (wraps around for index > 8).

```lua
lurek.charts.seriesColor(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | 1-based palette index. |

**Returns**

| Type | Description |
|------|-------------|
| table | Color table {r, g, b, a}. |

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
- [LLineChart](#llinechart)
- [LPieChart](#lpiechart)
- [LScatterPlot](#lscatterplot)

## LAreaChart

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LAreaChart:addLayer`

Adds a data layer to this area chart.

```lua
LAreaChart:addLayer(name, vals_tbl, r, g, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | The layer name. |
| `vals_tbl` | table | Array of numeric values. |
| `r` | number | Red color component. |
| `g` | number | Green color component. |
| `b` | number | Blue color component. |

---

#### `LAreaChart:addLayerFromDataFrame`

Adds one area layer from a dataframe column, using zero for missing or non-numeric cells.

```lua
LAreaChart:addLayerFromDataFrame(name, df, value_col, r, g, b, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | The layer name. |
| `df` | [LDataFrame](dataframe.md#ldataframe) | Source dataframe. |
| `value_col` | string | Column name for layer values. |
| `r` | number | Red color component. |
| `g` | number | Green color component. |
| `b` | number | Blue color component. |
| `opts?` | table | Optional table with maxRows integer. |

**Returns**

| Type | Description |
|------|-------------|
| number | Number of values copied into the layer. |

---

#### `LAreaChart:addSeries`

Add a named data series to the area chart (stacked above previous).

```lua
LAreaChart:addSeries(name, data, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Display name of the series. |
| `data` | table | Array of {x, y} point tables. |
| `color?` | table | Optional RGBA color {r, g, b, a}. |

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

#### `LAreaChart:clear`

Removes all data series from this chart.

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

#### `LAreaChart:drawToImage`

Renders this area chart to an image buffer.

```lua
LAreaChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | [LImageData](render.md#limagedata) | The image to draw into. |

---

#### `LAreaChart:getHeight`

Get the chart output height in pixels.

```lua
LAreaChart:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Height in pixels. |

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

Get the chart output width in pixels.

```lua
LAreaChart:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels. |

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

Renders the chart contents into a new pixel buffer.

```lua
LAreaChart:render()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Output width in pixels. |
| number | Output height in pixels. |
| string | RGBA8 pixel data as a binary string. |

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

#### `LAreaChart:setTitle`

Set or update the chart's displayed title.

```lua
LAreaChart:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | string | New chart title text. |

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

#### `LAreaChart:setYMax`

Sets the maximum Y-axis value for this area chart.

```lua
LAreaChart:setYMax(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | The Y-axis maximum. |

---

#### `LAreaChart:type`

Returns the type name of this object.

```lua
LAreaChart:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always "[LAreaChart](#lareachart)". |

---

#### `LAreaChart:typeOf`

Checks whether this object matches the given type name.

```lua
LAreaChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the name matches this userdata type. |

---

## LBarChart

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LBarChart:addCategoriesFromDataFrame`

Adds bar categories from dataframe rows, using zero for missing or non-numeric value cells.

```lua
LBarChart:addCategoriesFromDataFrame(df, label_col, value_cols, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `df` | [LDataFrame](dataframe.md#ldataframe) | Source dataframe. |
| `label_col` | string | Column name for category labels. |
| `value_cols` | string[] | Value columns matching registered series order. |
| `opts?` | table | Optional table with maxRows integer. |

**Returns**

| Type | Description |
|------|-------------|
| number | Number of categories added. |

---

#### `LBarChart:addCategory`

Adds a category with values for each series.

```lua
LBarChart:addCategory(label, vals_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | string | The category label. |
| `vals_tbl` | table | Array of values, one per series. |

---

#### `LBarChart:addSeries`

Add a named data series to the bar chart.

```lua
LBarChart:addSeries(name, data, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Display name of the series. |
| `data` | table | Array of {x, y} point tables. |
| `color?` | table | Optional RGBA color {r, g, b, a}. |

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

Removes all data series from this chart.

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

#### `LBarChart:drawToImage`

Renders this bar chart to an image buffer.

```lua
LBarChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | [LImageData](render.md#limagedata) | The image to draw into. |

---

#### `LBarChart:getHeight`

Get the chart output height in pixels.

```lua
LBarChart:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Height in pixels. |

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

Get the chart output width in pixels.

```lua
LBarChart:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels. |

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

Renders the chart contents into a new pixel buffer.

```lua
LBarChart:render()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Output width in pixels. |
| number | Output height in pixels. |
| string | RGBA8 pixel data as a binary string. |

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

#### `LBarChart:setBarWidth`

Set the pixel width of individual bars in this chart.

```lua
LBarChart:setBarWidth(width)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Bar width in pixels (minimum 1). |

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

#### `LBarChart:setTitle`

Set or update the chart's displayed title.

```lua
LBarChart:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | string | New chart title text. |

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

#### `LBarChart:type`

Returns the type name of this object.

```lua
LBarChart:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always "[LBarChart](#lbarchart)". |

---

#### `LBarChart:typeOf`

Checks whether this object matches the given type name.

```lua
LBarChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the name matches this userdata type. |

---

## LLineChart

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LLineChart:addSeries`

Add a named data series to the line chart.

```lua
LLineChart:addSeries(name, data, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Display name of the series. |
| `data` | table | Array of {x, y} point tables. |
| `color?` | table | Optional RGBA color {r, g, b, a}. |

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

Adds a named series from dataframe columns, skipping rows with non-numeric x or y cells.

```lua
LLineChart:addSeriesFromDataFrame(name, df, x_col, y_col, r, g, b, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | The series name. |
| `df` | [LDataFrame](dataframe.md#ldataframe) | Source dataframe. |
| `x_col` | string | Column name for X values. |
| `y_col` | string | Column name for Y values. |
| `r` | number | Red color component. |
| `g` | number | Green color component. |
| `b` | number | Blue color component. |
| `opts?` | table | Optional table with maxRows integer. |

**Returns**

| Type | Description |
|------|-------------|
| number | Number of accepted points added to the series. |

---

#### `LLineChart:clear`

Removes all data series from this chart.

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

#### `LLineChart:drawToImage`

Renders this line chart to an image buffer.

```lua
LLineChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | [LImageData](render.md#limagedata) | The image to draw into. |

---

#### `LLineChart:getHeight`

Get the chart output height in pixels.

```lua
LLineChart:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Height in pixels. |

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

Get the chart output width in pixels.

```lua
LLineChart:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels. |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    print("LLineChart:getWidth=" .. chart:getWidth())
    print("LLineChart:getHeight=" .. chart:getHeight())
end
```

---

#### `LLineChart:render`

Renders the chart contents into a new pixel buffer.

```lua
LLineChart:render()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Output width in pixels. |
| number | Output height in pixels. |
| string | RGBA8 pixel data as a binary string. |

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

#### `LLineChart:setTitle`

Set or update the chart's displayed title.

```lua
LLineChart:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | string | New chart title text. |

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

#### `LLineChart:setXMax`

Sets the maximum X-axis value for this line chart.

```lua
LLineChart:setXMax(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | The X-axis maximum. |

---

#### `LLineChart:setYMax`

Sets the maximum Y-axis value for this line chart.

```lua
LLineChart:setYMax(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | The Y-axis maximum. |

---

#### `LLineChart:type`

Returns the type name of this object.

```lua
LLineChart:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always "[LLineChart](#llinechart)". |

---

#### `LLineChart:typeOf`

Checks whether this object matches the given type name.

```lua
LLineChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the name matches this userdata type. |

---

## LPieChart

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LPieChart:addSegment`

Adds a labeled segment to this pie chart widget.

```lua
LPieChart:addSegment(label, value, r, g, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | string | The segment label. |
| `value` | number | The segment value. |
| `r` | number | Red color component. |
| `g` | number | Green color component. |
| `b` | number | Blue color component. |

---

#### `LPieChart:addSegmentsFromDataFrame`

Adds pie segments from dataframe rows with a built-in color palette, skipping non-positive or non-numeric values.

```lua
LPieChart:addSegmentsFromDataFrame(df, label_col, value_col, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `df` | [LDataFrame](dataframe.md#ldataframe) | Source dataframe. |
| `label_col` | string | Column name for segment labels. |
| `value_col` | string | Column name for segment values. |
| `opts?` | table | Optional table with maxRows integer. |

**Returns**

| Type | Description |
|------|-------------|
| number | Number of segments added. |

---

#### `LPieChart:addSlice`

Add a slice to the pie chart Ă˘â‚¬â€ť Lua userdata object exposed by the engine.

```lua
LPieChart:addSlice(label, value, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | string | Display label for the slice. |
| `value` | number | Numeric value determining the slice proportion. |
| `color?` | table | Optional RGBA color {r, g, b, a}. Auto-assigned from palette if nil. |

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

Removes all pie data slices from this chart.

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

#### `LPieChart:drawToImage`

Renders this pie chart to an image buffer.

```lua
LPieChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | [LImageData](render.md#limagedata) | The image to draw into. |

---

#### `LPieChart:getHeight`

Get the chart output height in pixels.

```lua
LPieChart:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Height in pixels. |

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

Get the chart output width in pixels.

```lua
LPieChart:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels. |

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

Renders the chart contents into a new pixel buffer.

```lua
LPieChart:render()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Output width in pixels. |
| number | Output height in pixels. |
| string | RGBA8 pixel data as a binary string. |

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

#### `LPieChart:setTitle`

Set or update the chart's displayed title.

```lua
LPieChart:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | string | New chart title text. |

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

Returns the type name of this object.

```lua
LPieChart:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always "[LPieChart](#lpiechart)". |

---

#### `LPieChart:typeOf`

Checks whether this object matches the given type name.

```lua
LPieChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the name matches this userdata type. |

---

## LScatterPlot

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LScatterPlot:addSeries`

Add a named data series to the scatter plot.

```lua
LScatterPlot:addSeries(name, data, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Display name of the series. |
| `data` | table | Array of {x, y} point tables. |
| `color?` | table | Optional RGBA color {r, g, b, a}. |

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

Adds a data series from dataframe columns, skipping rows with non-numeric x or y cells.

```lua
LScatterPlot:addSeriesFromDataFrame(name, df, x_col, y_col, r, g, b, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | The series name. |
| `df` | [LDataFrame](dataframe.md#ldataframe) | Source dataframe. |
| `x_col` | string | Column name for X values. |
| `y_col` | string | Column name for Y values. |
| `r` | number | Red color component. |
| `g` | number | Green color component. |
| `b` | number | Blue color component. |
| `opts?` | table | Optional table with maxRows integer. |

**Returns**

| Type | Description |
|------|-------------|
| number | Number of accepted points added to the series. |

---

#### `LScatterPlot:clear`

Removes all data series from this chart.

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

#### `LScatterPlot:drawToImage`

Renders this scatter plot to an image buffer.

```lua
LScatterPlot:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | [LImageData](render.md#limagedata) | The image to draw into. |

---

#### `LScatterPlot:getHeight`

Get the chart output height in pixels.

```lua
LScatterPlot:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Height in pixels. |

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

Get the chart output width in pixels.

```lua
LScatterPlot:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels. |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    print("LScatterPlot:getWidth=" .. chart:getWidth())
    print("LScatterPlot:getHeight=" .. chart:getHeight())
end
```

---

#### `LScatterPlot:render`

Renders the chart contents into a new pixel buffer.

```lua
LScatterPlot:render()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Output width in pixels. |
| number | Output height in pixels. |
| string | RGBA8 pixel data as a binary string. |

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

#### `LScatterPlot:setDotRadius`

Set the radius of the dot drawn for each data point.

```lua
LScatterPlot:setDotRadius(r)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Dot radius in pixels (minimum 1). |

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

#### `LScatterPlot:setTitle`

Set or update the chart's displayed title.

```lua
LScatterPlot:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | string | New chart title text. |

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

#### `LScatterPlot:setXRange`

Sets the X-axis range for this scatter plot.

```lua
LScatterPlot:setXRange(mn, mx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mn` | number | Minimum X value. |
| `mx` | number | Maximum X value. |

---

#### `LScatterPlot:setYRange`

Sets the Y-axis range for this scatter plot.

```lua
LScatterPlot:setYRange(mn, mx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mn` | number | Minimum Y value. |
| `mx` | number | Maximum Y value. |

---

#### `LScatterPlot:type`

Returns the type name of this object.

```lua
LScatterPlot:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always "[LScatterPlot](#lscatterplot)". |

---

#### `LScatterPlot:typeOf`

Checks whether this object matches the given type name.

```lua
LScatterPlot:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the name matches this userdata type. |

---
