# Charts

- Software-rasterized chart renderers (line, bar, scatter, pie, area) that output RGBA8 pixel buffers.

The charts module provides five chart types (line, bar, scatter, pie, area) that render entirely in software to RGBA8 pixel buffers. Charts are configured with margins, colors, grid toggles, and legend settings via `ChartConfig`. Data is fed through named `ChartSeries` or `PieSlice` objects. The module has no GPU dependency — rendered buffers can be used as textures in the render pipeline. An 8-color default palette auto-assigns series colors. The module is feature-gated behind `ui-charts`.

This module primarily collaborates with `color`, `dataframe`, `image`. Its responsibility should stay inside the `Feature Systems` group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.charts.defaultPalette`

Get the default 8-color series palette.

```lua
-- signature
lurek.charts.defaultPalette()
```

**Returns**

| Type | Description |
|------|-------------|
| `table` | Array of 8 color tables, each {r, g, b, a}. |

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
-- signature
lurek.charts.newArea(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | `table` | Optional chart configuration table. |

**Returns**

| Type | Description |
|------|-------------|
| `LuaAreaChart` | A area chart userdata object. |

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
-- signature
lurek.charts.newBar(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | `table` | Optional chart configuration table. |

**Returns**

| Type | Description |
|------|-------------|
| `LuaBarChart` | A bar chart userdata object. |

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
-- signature
lurek.charts.newLine(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | `table` | Optional chart configuration table. |

**Returns**

| Type | Description |
|------|-------------|
| `LuaLineChart` | A line chart userdata object. |

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
-- signature
lurek.charts.newPie(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | `table` | Optional chart configuration table. |

**Returns**

| Type | Description |
|------|-------------|
| `LuaPieChart` | A pie chart userdata object. |

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
-- signature
lurek.charts.newScatter(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | `table` | Optional chart configuration table. |

**Returns**

| Type | Description |
|------|-------------|
| `LuaScatterPlot` | A scatter plot userdata object. |

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
-- signature
lurek.charts.seriesColor(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | `number` | 1-based palette index. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Color table {r, g, b, a}. |

**Example**

```lua
do
    local c = lurek.charts.seriesColor(1)
    print("series 1 color r=" .. string.format("%.2f", c[1]) .. " g=" .. string.format("%.2f", c[2]) .. " b=" .. string.format("%.2f", c[3]))
    print("series 1 alpha=" .. string.format("%.2f", c[4]))
end
```

---

## LAreaChart

### `LAreaChart:addLayer`

Adds a data layer to this area chart.

```lua
-- signature
LAreaChart:addLayer(name, vals_tbl, r, g, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | The layer name. |
| `vals_tbl` | `table` | Array of numeric values. |
| `r` | `number` | Red color component. |
| `g` | `number` | Green color component. |
| `b` | `number` | Blue color component. |

---

### `LAreaChart:addLayerFromDataFrame`

Adds one area layer from a dataframe column, using zero for missing or non-numeric cells.

```lua
-- signature
LAreaChart:addLayerFromDataFrame(name, df, value_col, r, g, b, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | The layer name. |
| `df` | `LDataFrame` | Source dataframe. |
| `value_col` | `string` | Column name for layer values. |
| `r` | `number` | Red color component. |
| `g` | `number` | Green color component. |
| `b` | `number` | Blue color component. |
| `opts?` | `table` | Optional table with maxRows integer. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Number of values copied into the layer. |

---

### `LAreaChart:addSeries`

Add a named data series to the area chart (stacked above previous).

```lua
-- signature
LAreaChart:addSeries(name, data, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Display name of the series. |
| `data` | `table` | Array of {x, y} point tables. |
| `color?` | `table` | Optional RGBA color {r, g, b, a}. |

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

### `LAreaChart:clear`

Removes all data series from this chart.

```lua
-- signature
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

### `LAreaChart:drawToImage`

Renders this area chart to an image buffer.

```lua
-- signature
LAreaChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | `LImageData` | The image to draw into. |

---

### `LAreaChart:getHeight`

Get the chart output height in pixels.

```lua
-- signature
LAreaChart:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Height in pixels. |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    print("LAreaChart:getHeight=" .. chart:getHeight())
    print("LAreaChart:getWidth=" .. chart:getWidth())
end
```

---

### `LAreaChart:getWidth`

Get the chart output width in pixels.

```lua
-- signature
LAreaChart:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Width in pixels. |

**Example**

```lua
do
    local chart = lurek.charts.newArea({ width = 400, height = 300 })
    print("LAreaChart:getWidth=" .. chart:getWidth())
    print("LAreaChart:getHeight=" .. chart:getHeight())
end
```

---

### `LAreaChart:render`

Renders the chart contents into a new pixel buffer.

```lua
-- signature
LAreaChart:render()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Output width in pixels. |
| `number` | b Output height in pixels. |
| `string` | c RGBA8 pixel data as a binary string. |

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

### `LAreaChart:setTitle`

Set or update the chart's displayed title.

```lua
-- signature
LAreaChart:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | `string` | New chart title text. |

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

### `LAreaChart:setYMax`

Sets the maximum Y-axis value for this area chart.

```lua
-- signature
LAreaChart:setYMax(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | The Y-axis maximum. |

---

### `LAreaChart:type`

Returns the type name of this object.

```lua
-- signature
LAreaChart:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always "LAreaChart". |

---

### `LAreaChart:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LAreaChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the name matches this userdata type. |

---

## LBarChart

### `LBarChart:addCategoriesFromDataFrame`

Adds bar categories from dataframe rows, using zero for missing or non-numeric value cells.

```lua
-- signature
LBarChart:addCategoriesFromDataFrame(df, label_col, value_cols, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `df` | `LDataFrame` | Source dataframe. |
| `label_col` | `string` | Column name for category labels. |
| `value_cols` | `string[]` | Value columns matching registered series order. |
| `opts?` | `table` | Optional table with maxRows integer. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Number of categories added. |

---

### `LBarChart:addCategory`

Adds a category with values for each series.

```lua
-- signature
LBarChart:addCategory(label, vals_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | `string` | The category label. |
| `vals_tbl` | `table` | Array of values, one per series. |

---

### `LBarChart:addSeries`

Add a named data series to the bar chart.

```lua
-- signature
LBarChart:addSeries(name, data, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Display name of the series. |
| `data` | `table` | Array of {x, y} point tables. |
| `color?` | `table` | Optional RGBA color {r, g, b, a}. |

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

### `LBarChart:clear`

Removes all data series from this chart.

```lua
-- signature
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

### `LBarChart:drawToImage`

Renders this bar chart to an image buffer.

```lua
-- signature
LBarChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | `LImageData` | The image to draw into. |

---

### `LBarChart:getHeight`

Get the chart output height in pixels.

```lua
-- signature
LBarChart:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Height in pixels. |

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    print("LBarChart:getHeight=" .. chart:getHeight())
    print("LBarChart:getWidth=" .. chart:getWidth())
end
```

---

### `LBarChart:getWidth`

Get the chart output width in pixels.

```lua
-- signature
LBarChart:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Width in pixels. |

**Example**

```lua
do
    local chart = lurek.charts.newBar({ width = 400, height = 300 })
    print("LBarChart:getWidth=" .. chart:getWidth())
    print("LBarChart:getHeight=" .. chart:getHeight())
end
```

---

### `LBarChart:render`

Renders the chart contents into a new pixel buffer.

```lua
-- signature
LBarChart:render()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Output width in pixels. |
| `number` | b Output height in pixels. |
| `string` | c RGBA8 pixel data as a binary string. |

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

### `LBarChart:setBarWidth`

Set the pixel width of individual bars in this chart.

```lua
-- signature
LBarChart:setBarWidth(width)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | `number` | Bar width in pixels (minimum 1). |

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

### `LBarChart:setTitle`

Set or update the chart's displayed title.

```lua
-- signature
LBarChart:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | `string` | New chart title text. |

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

### `LBarChart:type`

Returns the type name of this object.

```lua
-- signature
LBarChart:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always "LBarChart". |

---

### `LBarChart:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LBarChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the name matches this userdata type. |

---

## LLineChart

### `LLineChart:addSeries`

Add a named data series to the line chart.

```lua
-- signature
LLineChart:addSeries(name, data, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Display name of the series. |
| `data` | `table` | Array of {x, y} point tables. |
| `color?` | `table` | Optional RGBA color {r, g, b, a}. |

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

### `LLineChart:addSeriesFromDataFrame`

Adds a named series from dataframe columns, skipping rows with non-numeric x or y cells.

```lua
-- signature
LLineChart:addSeriesFromDataFrame(name, df, x_col, y_col, r, g, b, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | The series name. |
| `df` | `LDataFrame` | Source dataframe. |
| `x_col` | `string` | Column name for X values. |
| `y_col` | `string` | Column name for Y values. |
| `r` | `number` | Red color component. |
| `g` | `number` | Green color component. |
| `b` | `number` | Blue color component. |
| `opts?` | `table` | Optional table with maxRows integer. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Number of accepted points added to the series. |

---

### `LLineChart:clear`

Removes all data series from this chart.

```lua
-- signature
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

### `LLineChart:drawToImage`

Renders this line chart to an image buffer.

```lua
-- signature
LLineChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | `LImageData` | The image to draw into. |

---

### `LLineChart:getHeight`

Get the chart output height in pixels.

```lua
-- signature
LLineChart:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Height in pixels. |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    print("LLineChart:getHeight=" .. chart:getHeight())
    print("LLineChart:getWidth=" .. chart:getWidth())
end
```

---

### `LLineChart:getWidth`

Get the chart output width in pixels.

```lua
-- signature
LLineChart:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Width in pixels. |

**Example**

```lua
do
    local chart = lurek.charts.newLine({ width = 400, height = 300 })
    print("LLineChart:getWidth=" .. chart:getWidth())
    print("LLineChart:getHeight=" .. chart:getHeight())
end
```

---

### `LLineChart:render`

Renders the chart contents into a new pixel buffer.

```lua
-- signature
LLineChart:render()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Output width in pixels. |
| `number` | b Output height in pixels. |
| `string` | c RGBA8 pixel data as a binary string. |

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

### `LLineChart:setTitle`

Set or update the chart's displayed title.

```lua
-- signature
LLineChart:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | `string` | New chart title text. |

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

### `LLineChart:setXMax`

Sets the maximum X-axis value for this line chart.

```lua
-- signature
LLineChart:setXMax(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | The X-axis maximum. |

---

### `LLineChart:setYMax`

Sets the maximum Y-axis value for this line chart.

```lua
-- signature
LLineChart:setYMax(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | The Y-axis maximum. |

---

### `LLineChart:type`

Returns the type name of this object.

```lua
-- signature
LLineChart:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always "LLineChart". |

---

### `LLineChart:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LLineChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the name matches this userdata type. |

---

## LPieChart

### `LPieChart:addSegment`

Adds a labeled segment to this pie chart widget.

```lua
-- signature
LPieChart:addSegment(label, value, r, g, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | `string` | The segment label. |
| `value` | `number` | The segment value. |
| `r` | `number` | Red color component. |
| `g` | `number` | Green color component. |
| `b` | `number` | Blue color component. |

---

### `LPieChart:addSegmentsFromDataFrame`

Adds pie segments from dataframe rows with a built-in color palette, skipping non-positive or non-numeric values.

```lua
-- signature
LPieChart:addSegmentsFromDataFrame(df, label_col, value_col, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `df` | `LDataFrame` | Source dataframe. |
| `label_col` | `string` | Column name for segment labels. |
| `value_col` | `string` | Column name for segment values. |
| `opts?` | `table` | Optional table with maxRows integer. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Number of segments added. |

---

### `LPieChart:addSlice`

Add a slice to the pie chart â€” Lua userdata object exposed by the engine.

```lua
-- signature
LPieChart:addSlice(label, value, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label` | `string` | Display label for the slice. |
| `value` | `number` | Numeric value determining the slice proportion. |
| `color?` | `table` | Optional RGBA color {r, g, b, a}. Auto-assigned from palette if nil. |

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

### `LPieChart:clear`

Removes all pie data slices from this chart.

```lua
-- signature
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

### `LPieChart:drawToImage`

Renders this pie chart to an image buffer.

```lua
-- signature
LPieChart:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | `LImageData` | The image to draw into. |

---

### `LPieChart:getHeight`

Get the chart output height in pixels.

```lua
-- signature
LPieChart:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Height in pixels. |

**Example**

```lua
do
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    print("LPieChart:getHeight=" .. chart:getHeight())
    print("LPieChart:getWidth=" .. chart:getWidth())
end
```

---

### `LPieChart:getWidth`

Get the chart output width in pixels.

```lua
-- signature
LPieChart:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Width in pixels. |

**Example**

```lua
do
    local chart = lurek.charts.newPie({ width = 400, height = 300 })
    print("LPieChart:getWidth=" .. chart:getWidth())
    print("LPieChart:getHeight=" .. chart:getHeight())
end
```

---

### `LPieChart:render`

Renders the chart contents into a new pixel buffer.

```lua
-- signature
LPieChart:render()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Output width in pixels. |
| `number` | b Output height in pixels. |
| `string` | c RGBA8 pixel data as a binary string. |

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

### `LPieChart:setTitle`

Set or update the chart's displayed title.

```lua
-- signature
LPieChart:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | `string` | New chart title text. |

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

### `LPieChart:type`

Returns the type name of this object.

```lua
-- signature
LPieChart:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always "LPieChart". |

---

### `LPieChart:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LPieChart:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the name matches this userdata type. |

---

## LScatterPlot

### `LScatterPlot:addSeries`

Add a named data series to the scatter plot.

```lua
-- signature
LScatterPlot:addSeries(name, data, color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Display name of the series. |
| `data` | `table` | Array of {x, y} point tables. |
| `color?` | `table` | Optional RGBA color {r, g, b, a}. |

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

### `LScatterPlot:addSeriesFromDataFrame`

Adds a data series from dataframe columns, skipping rows with non-numeric x or y cells.

```lua
-- signature
LScatterPlot:addSeriesFromDataFrame(name, df, x_col, y_col, r, g, b, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | The series name. |
| `df` | `LDataFrame` | Source dataframe. |
| `x_col` | `string` | Column name for X values. |
| `y_col` | `string` | Column name for Y values. |
| `r` | `number` | Red color component. |
| `g` | `number` | Green color component. |
| `b` | `number` | Blue color component. |
| `opts?` | `table` | Optional table with maxRows integer. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Number of accepted points added to the series. |

---

### `LScatterPlot:clear`

Removes all data series from this chart.

```lua
-- signature
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

### `LScatterPlot:drawToImage`

Renders this scatter plot to an image buffer.

```lua
-- signature
LScatterPlot:drawToImage(target)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | `LImageData` | The image to draw into. |

---

### `LScatterPlot:getHeight`

Get the chart output height in pixels.

```lua
-- signature
LScatterPlot:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Height in pixels. |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    print("LScatterPlot:getHeight=" .. chart:getHeight())
    print("LScatterPlot:getWidth=" .. chart:getWidth())
end
```

---

### `LScatterPlot:getWidth`

Get the chart output width in pixels.

```lua
-- signature
LScatterPlot:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Width in pixels. |

**Example**

```lua
do
    local chart = lurek.charts.newScatter({ width = 400, height = 300 })
    print("LScatterPlot:getWidth=" .. chart:getWidth())
    print("LScatterPlot:getHeight=" .. chart:getHeight())
end
```

---

### `LScatterPlot:render`

Renders the chart contents into a new pixel buffer.

```lua
-- signature
LScatterPlot:render()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Output width in pixels. |
| `number` | b Output height in pixels. |
| `string` | c RGBA8 pixel data as a binary string. |

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

### `LScatterPlot:setDotRadius`

Set the radius of the dot drawn for each data point.

```lua
-- signature
LScatterPlot:setDotRadius(r)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | `number` | Dot radius in pixels (minimum 1). |

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

### `LScatterPlot:setTitle`

Set or update the chart's displayed title.

```lua
-- signature
LScatterPlot:setTitle(title)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `title` | `string` | New chart title text. |

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

### `LScatterPlot:setXRange`

Sets the X-axis range for this scatter plot.

```lua
-- signature
LScatterPlot:setXRange(mn, mx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mn` | `number` | Minimum X value. |
| `mx` | `number` | Maximum X value. |

---

### `LScatterPlot:setYRange`

Sets the Y-axis range for this scatter plot.

```lua
-- signature
LScatterPlot:setYRange(mn, mx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mn` | `number` | Minimum Y value. |
| `mx` | `number` | Maximum Y value. |

---

### `LScatterPlot:type`

Returns the type name of this object.

```lua
-- signature
LScatterPlot:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always "LScatterPlot". |

---

### `LScatterPlot:typeOf`

Checks whether this object matches the given type name.

```lua
-- signature
LScatterPlot:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the name matches this userdata type. |

---
