# charts

## TL;DR

- Software-rasterized chart renderers (line, bar, scatter, pie, area) that output RGBA8 pixel buffers.

## General Info

- Module group: `Feature Systems`
- Source path: `src/charts/`
- Lua API path(s): `src/lua_api/charts_api.rs`
- Primary Lua namespace: `lurek.charts`
- Rust test path(s): tests/rust/unit/charts_tests.rs
- Lua test path(s): tests/lua/unit/test_charts_core_unit.lua

## Summary

The `charts` module is a CPU-side chart rendering system for data visualization, designed to work without a dedicated GPU chart pipeline. It supports line, bar, scatter, pie, and area charts, with shared configuration and raster helpers that produce pixel buffers suitable for reuse as textures in normal render flows.

Each chart type is implemented in its own module (`line`, `bar`, `scatter`, `pie`, `area`) while shared appearance/data contracts live in `config` and drawing primitives live in `render_utils`. This keeps chart-specific behavior isolated while preserving consistent styling and axis/legend behavior across chart families.

The module is intentionally data-driven: callers provide series/slice data and chart options, and the renderer emits deterministic software raster output. This makes charts reproducible in tests and usable in headless or tooling contexts where GPU access is not assumed.

Because chart rendering can be consumed by UI and reporting paths, the boundary should stay focused on conversion from numeric data to image output. Layout orchestration and interaction policy belong to higher layers.

## Files

### area.rs

- Area chart renderer: filled regions below one or more line series.
- Rasterises each series into an RGBA pixel buffer via `render_area_chart`.
- Supports stacked and overlapping fill modes with per-series alpha.
- Delegates coordinate mapping to `charts::render_utils::world_to_screen`.
- Owned by `lurek.charts.area` Lua API; output is uploaded as a texture.

### bar.rs

- Bar chart renderer: vertical or horizontal grouped/stacked bars.
- Rasterises a `BarChartSpec` into an RGBA pixel buffer.
- Supports grouped and stacked layouts; bar width and gap are configurable.
- Uses `render_utils::draw_rect_filled` for individual bar segments.
- Owned by `lurek.charts.bar`; output is uploaded as a per-frame texture.

### config.rs

- Shared chart configuration types: size, background, margins, and axis labels.
- `ChartConfig` is the common base embedded in every chart spec.
- Pixel dimensions, background colour, and title string live here.
- Axis label and legend settings are optional; missing values use defaults.
- Referenced by `BarChartSpec`, `LineChartSpec`, `PieChartSpec`, etc.

### line.rs

- Line chart renderer: connected data-point series over time or categories.
- Rasterises a `LineChartSpec` into an RGBA pixel buffer.
- Supports multiple named series with per-series colour and line width.
- Pixel coordinates are mapped via `render_utils::world_to_screen`.
- Owned by `lurek.charts.line`; result is uploaded as a texture each frame.

### mod.rs

- Software-rasterised chart rendering for data visualisation.
- Five chart types: line, bar, scatter, pie, area.
- Configurable appearance: colors, margins, grid, titles, legends.
- Renders to CPU pixel buffers (no GPU dependency).
- DataFrame integration for direct column-to-series mapping.

### pie.rs

- Pie chart renderer: proportional slice segments from a single data series.
- Rasterises a `PieChartSpec` into an RGBA pixel buffer using arc fill.
- Slice angles are computed from normalised values; labels are optional.
- A configurable donut-hole radius converts the pie into a ring chart.
- Owned by `lurek.charts.pie`; output is uploaded as a texture.

### render_utils.rs

- Internal rasterisation utilities shared by all chart renderers.
- `fill_buffer` — flood-fills an RGBA buffer with a single background colour.
- `draw_rect_filled` / `draw_circle_filled` — axis-aligned primitive fill.
- `world_to_screen` — maps a data-space value to a pixel coordinate.
- `auto_range` — computes the bounding min/max across all series data.
- All functions operate on a flat `&mut [u8]` RGBA buffer with stride = width×4.

### scatter.rs

- Scatter plot renderer: (x, y) point series showing distribution and correlation.
- Rasterises a `ScatterChartSpec` into an RGBA pixel buffer.
- Each point is drawn as a filled circle; radius and colour are per-series.
- Axes are auto-ranged or clamped to user-supplied min/max bounds.
- Owned by `lurek.charts.scatter`; output is uploaded as a texture.

## Lua API Ref

- Binding: `src/lua_api/charts_api.rs`
- Namespace: `lurek.charts`

### Functions

- `lurek.charts.defaultPalette`: Get the default 8-color series palette.
- `lurek.charts.newArea`: Create a new area chart exposed by the lurek engine.
- `lurek.charts.newBar`: Create a new bar chart exposed by the lurek engine.
- `lurek.charts.newLine`: Create a new line chart exposed by the lurek engine.
- `lurek.charts.newPie`: Create a new pie chart exposed by the lurek engine.
- `lurek.charts.newScatter`: Create a new scatter plot exposed by the lurek engine.
- `lurek.charts.seriesColor`: Get a palette color by 1-based index (wraps around for index > 8).

### Enums

- No documented module-level enums/constants.

### Types


#### LAreaChart Type


##### Fields

- No documented fields.

##### Methods

- `LAreaChart:addSeries`: Add a named data series to the area chart (stacked above previous).
- `LAreaChart:clear`: Removes all data series from this chart.
- `LAreaChart:getHeight`: Get the chart output height in pixels.
- `LAreaChart:getWidth`: Get the chart output width in pixels.
- `LAreaChart:render`: Renders the chart contents into a new pixel buffer.
- `LAreaChart:setTitle`: Set or update the chart's displayed title.


#### LBarChart Type


##### Fields

- No documented fields.

##### Methods

- `LBarChart:addSeries`: Add a named data series to the bar chart.
- `LBarChart:clear`: Removes all data series from this chart.
- `LBarChart:getHeight`: Get the chart output height in pixels.
- `LBarChart:getWidth`: Get the chart output width in pixels.
- `LBarChart:render`: Renders the chart contents into a new pixel buffer.
- `LBarChart:setBarWidth`: Set the pixel width of individual bars in this chart.
- `LBarChart:setTitle`: Set or update the chart's displayed title.


#### LLineChart Type


##### Fields

- No documented fields.

##### Methods

- `LLineChart:addSeries`: Add a named data series to the line chart.
- `LLineChart:clear`: Removes all data series from this chart.
- `LLineChart:getHeight`: Get the chart output height in pixels.
- `LLineChart:getWidth`: Get the chart output width in pixels.
- `LLineChart:render`: Renders the chart contents into a new pixel buffer.
- `LLineChart:setTitle`: Set or update the chart's displayed title.


#### LPieChart Type


##### Fields

- No documented fields.

##### Methods

- `LPieChart:addSlice`: Add a slice to the pie chart â€” Lua userdata object exposed by the engine.
- `LPieChart:clear`: Removes all pie data slices from this chart.
- `LPieChart:getHeight`: Get the chart output height in pixels.
- `LPieChart:getWidth`: Get the chart output width in pixels.
- `LPieChart:render`: Renders the chart contents into a new pixel buffer.
- `LPieChart:setTitle`: Set or update the chart's displayed title.


#### LScatterPlot Type


##### Fields

- No documented fields.

##### Methods

- `LScatterPlot:addSeries`: Add a named data series to the scatter plot.
- `LScatterPlot:clear`: Removes all data series from this chart.
- `LScatterPlot:getHeight`: Get the chart output height in pixels.
- `LScatterPlot:getWidth`: Get the chart output width in pixels.
- `LScatterPlot:render`: Renders the chart contents into a new pixel buffer.
- `LScatterPlot:setDotRadius`: Set the radius of the dot drawn for each data point.
- `LScatterPlot:setTitle`: Set or update the chart's displayed title.

## References

- `color`: Imports or references `src/color/`. Cross-group dependency from ``Feature Systems`` into `Edge/Integration`.
- `dataframe`: Imports or references `src/dataframe/`. Cross-group dependency from ``Feature Systems`` into `Foundations`.
- `image`: Imports or references `src/image/`. Cross-group dependency from ``Feature Systems`` into `Platform Services`.
