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

The charts module provides five chart types (line, bar, scatter, pie, area) that render entirely in software to RGBA8 pixel buffers. Charts are configured with margins, colors, grid toggles, and legend settings via `ChartConfig`. Data is fed through named `ChartSeries` or `PieSlice` objects. The module has no GPU dependency — rendered buffers can be used as textures in the render pipeline. An 8-color default palette auto-assigns series colors. The module is feature-gated behind `ui-charts`.

This module primarily collaborates with `color`, `dataframe`, `image`. Its responsibility should stay inside the `Feature Systems` group rather than absorb behavior owned by those neighbors.

## Source Documentation

### `area.rs`
- Area chart renderer: filled regions below one or more line series.
- Rasterises each series into an RGBA pixel buffer via `render_area_chart`.
- Supports stacked and overlapping fill modes with per-series alpha.
- Delegates coordinate mapping to `charts::render_utils::world_to_screen`.
- Owned by `lurek.charts.area` Lua API; output is uploaded as a texture.

### `bar.rs`
- Bar chart renderer: vertical or horizontal grouped/stacked bars.
- Rasterises a `BarChartSpec` into an RGBA pixel buffer.
- Supports grouped and stacked layouts; bar width and gap are configurable.
- Uses `render_utils::draw_rect_filled` for individual bar segments.
- Owned by `lurek.charts.bar`; output is uploaded as a per-frame texture.

### `config.rs`
- Shared chart configuration types: size, background, margins, and axis labels.
- `ChartConfig` is the common base embedded in every chart spec.
- Pixel dimensions, background colour, and title string live here.
- Axis label and legend settings are optional; missing values use defaults.
- Referenced by `BarChartSpec`, `LineChartSpec`, `PieChartSpec`, etc.

### `line.rs`
- Line chart renderer: connected data-point series over time or categories.
- Rasterises a `LineChartSpec` into an RGBA pixel buffer.
- Supports multiple named series with per-series colour and line width.
- Pixel coordinates are mapped via `render_utils::world_to_screen`.
- Owned by `lurek.charts.line`; result is uploaded as a texture each frame.

### `mod.rs`
- Software-rasterised chart rendering for data visualisation.
- Five chart types: line, bar, scatter, pie, area.
- Configurable appearance: colors, margins, grid, titles, legends.
- Renders to CPU pixel buffers (no GPU dependency).
- DataFrame integration for direct column-to-series mapping.

### `pie.rs`
- Pie chart renderer: proportional slice segments from a single data series.
- Rasterises a `PieChartSpec` into an RGBA pixel buffer using arc fill.
- Slice angles are computed from normalised values; labels are optional.
- A configurable donut-hole radius converts the pie into a ring chart.
- Owned by `lurek.charts.pie`; output is uploaded as a texture.

### `render_utils.rs`
- Internal rasterisation utilities shared by all chart renderers.
- `fill_buffer` — flood-fills an RGBA buffer with a single background colour.
- `draw_rect_filled` / `draw_circle_filled` — axis-aligned primitive fill.
- `world_to_screen` — maps a data-space value to a pixel coordinate.
- `auto_range` — computes the bounding min/max across all series data.
- All functions operate on a flat `&mut [u8]` RGBA buffer with stride = width×4.

### `scatter.rs`
- Scatter plot renderer: (x, y) point series showing distribution and correlation.
- Rasterises a `ScatterChartSpec` into an RGBA pixel buffer.
- Each point is drawn as a filled circle; radius and colour are per-series.
- Axes are auto-ranged or clamped to user-supplied min/max bounds.
- Owned by `lurek.charts.scatter`; output is uploaded as a texture.

## Types

- `AreaChart` (`struct`, `area.rs`): Stacked cumulative area chart renderer.
- `BarChart` (`struct`, `bar.rs`): Grouped vertical bar chart renderer.
- `ChartMargin` (`struct`, `config.rs`): top, right, bottom, left padding.
- `ChartConfig` (`struct`, `config.rs`): Width, height, colors, margins, grid, legend config.
- `ChartSeries` (`struct`, `config.rs`): Named, colored data series.
- `ChartDataFrameOptions` (`struct`, `config.rs`): max_rows limiter for DataFrame integration.
- `LineChart` (`struct`, `line.rs`): Polyline chart renderer with dot markers.
- `PieSlice` (`struct`, `pie.rs`): Label, value, color for a pie segment.
- `PieChart` (`struct`, `pie.rs`): Pie chart renderer with per-pixel angle testing.
- `ScatterPlot` (`struct`, `scatter.rs`): Scatter plot renderer with filled circles.

## Functions

- `AreaChart::new` (`area.rs`): Create a new area chart with the given configuration.
- `AreaChart::add_series` (`area.rs`): Add a data series to the chart (drawn stacked above previous series).
- `AreaChart::add_layer` (`area.rs`): Add a named layer by values array and color.
- `AreaChart::add_layer_from_dataframe` (`area.rs`): Add a layer from a DataFrame column.
- `AreaChart::draw_to_image` (`area.rs`): Render the chart into an ImageData buffer.
- `AreaChart::clear` (`area.rs`): Remove all series from the chart.
- `AreaChart::render` (`area.rs`): Render the chart into an RGBA8 pixel buffer.
- `BarChart::new` (`bar.rs`): Create a new bar chart with the given configuration.
- `BarChart::push_series` (`bar.rs`): Add a data series (low-level: accepts a ChartSeries directly).
- `BarChart::add_series` (`bar.rs`): Register a named series slot with a color.
- `BarChart::add_category` (`bar.rs`): Add a category with one value per registered series.
- `BarChart::add_categories_from_dataframe` (`bar.rs`): Add categories from dataframe rows, returning the number of categories added.
- `BarChart::draw_to_image` (`bar.rs`): Render this chart into an ImageData buffer.
- `BarChart::clear` (`bar.rs`): Remove all series from the chart.
- `BarChart::set_bar_width` (`bar.rs`): Set the individual bar width in pixels.
- `BarChart::render` (`bar.rs`): Render the chart into an RGBA8 pixel buffer.
- `LineChart::new` (`line.rs`): Create a new line chart with the given configuration.
- `LineChart::push_series` (`line.rs`): Add a data series (low-level: accepts a ChartSeries directly).
- `LineChart::add_series` (`line.rs`): Add a named series from point data and a color.
- `LineChart::add_series_from_dataframe` (`line.rs`): Add a named series from dataframe columns, returning the number of points added.
- `LineChart::draw_to_image` (`line.rs`): Render this chart into an ImageData buffer.
- `LineChart::clear` (`line.rs`): Remove all series from the chart.
- `LineChart::render` (`line.rs`): Render the chart into an RGBA8 pixel buffer.
- `PieChart::new` (`pie.rs`): Create a new pie chart with the given configuration.
- `PieChart::add_segment` (`pie.rs`): Add a new data slice to the pie chart using a `Color`.
- `PieChart::add_segments_from_dataframe` (`pie.rs`): Add slices from a DataFrame.
- `PieChart::draw_to_image` (`pie.rs`): Render the chart into an ImageData buffer.
- `PieChart::add_slice` (`pie.rs`): Add a new data slice to the pie chart.
- `PieChart::clear` (`pie.rs`): Remove all slices from the chart.
- `PieChart::render` (`pie.rs`): Render the chart into an RGBA8 pixel buffer.
- `set_pixel` (`render_utils.rs`): Write a pixel to the buffer.
- `draw_line` (`render_utils.rs`): Bresenham line rasterization.
- `draw_rect_filled` (`render_utils.rs`): Filled rectangle.
- `draw_circle_filled` (`render_utils.rs`): Filled circle.
- `fill_buffer` (`render_utils.rs`): Clear entire buffer to a color.
- `auto_range` (`render_utils.rs`): Compute axis bounds from data.
- `world_to_screen` (`render_utils.rs`): Map data coordinates to pixel coordinates.
- `ScatterPlot::new` (`scatter.rs`): Create a new scatter plot with the given configuration.
- `ScatterPlot::push_series_raw` (`scatter.rs`): Add a pre-built series entry directly.
- `ScatterPlot::add_series` (`scatter.rs`): Add a data series by name, points, and color.
- `ScatterPlot::add_series_from_dataframe` (`scatter.rs`): Add a data series from a DataFrame, reading x and y from named columns.
- `ScatterPlot::draw_to_image` (`scatter.rs`): Render the chart into an ImageData buffer.
- `ScatterPlot::clear` (`scatter.rs`): Remove all series from the chart.
- `ScatterPlot::set_dot_radius` (`scatter.rs`): Set the scatter dot radius in pixels.
- `ScatterPlot::render` (`scatter.rs`): Render the chart into an RGBA8 pixel buffer.

## Lua API Reference

- Binding path(s): `src/lua_api/charts_api.rs`
- Namespace: `lurek.charts`

### Module Functions
- `lurek.charts.newLine`: Create a new line chart exposed by the lurek engine.
- `lurek.charts.newBar`: Create a new bar chart exposed by the lurek engine.
- `lurek.charts.newScatter`: Create a new scatter plot exposed by the lurek engine.
- `lurek.charts.newPie`: Create a new pie chart exposed by the lurek engine.
- `lurek.charts.newArea`: Create a new area chart exposed by the lurek engine.
- `lurek.charts.defaultPalette`: Get the default 8-color series palette.
- `lurek.charts.seriesColor`: Get a palette color by 1-based index (wraps around for index > 8).

### `LAreaChart` Methods
- `LAreaChart:addSeries`: Add a named data series to the area chart (stacked above previous).
- `LAreaChart:clear`: Removes all data series from this chart.
- `LAreaChart:setTitle`: Set or update the chart's displayed title.
- `LAreaChart:render`: Renders the chart contents into a new pixel buffer.
- `LAreaChart:getWidth`: Get the chart output width in pixels.
- `LAreaChart:getHeight`: Get the chart output height in pixels.

### `LBarChart` Methods
- `LBarChart:addSeries`: Add a named data series to the bar chart.
- `LBarChart:clear`: Removes all data series from this chart.
- `LBarChart:setBarWidth`: Set the pixel width of individual bars in this chart.
- `LBarChart:setTitle`: Set or update the chart's displayed title.
- `LBarChart:render`: Renders the chart contents into a new pixel buffer.
- `LBarChart:getWidth`: Get the chart output width in pixels.
- `LBarChart:getHeight`: Get the chart output height in pixels.

### `LLineChart` Methods
- `LLineChart:addSeries`: Add a named data series to the line chart.
- `LLineChart:clear`: Removes all data series from this chart.
- `LLineChart:setTitle`: Set or update the chart's displayed title.
- `LLineChart:render`: Renders the chart contents into a new pixel buffer.
- `LLineChart:getWidth`: Get the chart output width in pixels.
- `LLineChart:getHeight`: Get the chart output height in pixels.

### `LPieChart` Methods
- `LPieChart:addSlice`: Add a slice to the pie chart â€” Lua userdata object exposed by the engine.
- `LPieChart:clear`: Removes all pie data slices from this chart.
- `LPieChart:setTitle`: Set or update the chart's displayed title.
- `LPieChart:render`: Renders the chart contents into a new pixel buffer.
- `LPieChart:getWidth`: Get the chart output width in pixels.
- `LPieChart:getHeight`: Get the chart output height in pixels.

### `LScatterPlot` Methods
- `LScatterPlot:addSeries`: Add a named data series to the scatter plot.
- `LScatterPlot:clear`: Removes all data series from this chart.
- `LScatterPlot:setDotRadius`: Set the radius of the dot drawn for each data point.
- `LScatterPlot:setTitle`: Set or update the chart's displayed title.
- `LScatterPlot:render`: Renders the chart contents into a new pixel buffer.
- `LScatterPlot:getWidth`: Get the chart output width in pixels.
- `LScatterPlot:getHeight`: Get the chart output height in pixels.

## References

- `color`: Imports or references `src/color/`. Cross-group dependency from ``Feature Systems`` into `Edge/Integration`.
- `dataframe`: Imports or references `src/dataframe/`. Cross-group dependency from ``Feature Systems`` into `Foundations`.
- `image`: Imports or references `src/image/`. Cross-group dependency from ``Feature Systems`` into `Platform Services`.

## Notes

- Extracted from `src/ui/chart.rs` and `src/ui/data_graph_renderer.rs`. Feature-gated behind `ui-charts`.
- Software-rasterized to RGBA8 pixel buffers — no GPU dependency.
- Charts render to pixel data that can be used as textures in the render pipeline.
- The 8-color DEFAULT_PALETTE auto-assigns series colors.
