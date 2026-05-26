# `charts`

## TL;DR
- Software-rasterized chart renderers (line, bar, scatter, pie, area) that output RGBA8 pixel buffers.

## General Info
- Module group: `Feature Systems`
- Source path: `src/charts/`
- Lua API path(s): `src/lua_api/charts_api.rs`
- Primary Lua namespace: `lurek.charts`
- Feature gate: `ui-charts`
- Rust test path(s): `tests/rust/unit/charts_tests.rs`
- Lua test path(s): `tests/lua/unit/test_charts_core_unit.lua`

## Summary
The charts module provides five chart types (line, bar, scatter, pie, area) that render entirely in software to RGBA8 pixel buffers. Charts are configured with margins, colors, grid toggles, and legend settings via `ChartConfig`. Data is fed through named `ChartSeries` or `PieSlice` objects. The module has no GPU dependency — rendered buffers can be used as textures in the render pipeline. An 8-color default palette auto-assigns series colors. The module is feature-gated behind `ui-charts`.

## Files
- `mod.rs`: Module root and public re-exports.
- `config.rs`: ChartConfig, ChartMargin, ChartSeries, DEFAULT_PALETTE.
- `line.rs`: LineChart — polyline rendering with dot markers.
- `bar.rs`: BarChart — grouped vertical bars.
- `scatter.rs`: ScatterPlot — filled circles at data points.
- `pie.rs`: PieChart + PieSlice — per-pixel angle test.
- `area.rs`: AreaChart — stacked cumulative area fills.
- `render_utils.rs`: Shared pixel-level rasterization helpers.

## Types
- `ChartConfig` (`struct`, `config.rs`): Width, height, colors, margins, grid, legend config.
- `ChartMargin` (`struct`, `config.rs`): top, right, bottom, left padding.
- `ChartSeries` (`struct`, `config.rs`): Named, colored data series.
- `LineChart` (`struct`, `line.rs`): Polyline chart renderer with dot markers.
- `BarChart` (`struct`, `bar.rs`): Grouped vertical bar chart renderer.
- `ScatterPlot` (`struct`, `scatter.rs`): Scatter plot renderer with filled circles.
- `PieChart` (`struct`, `pie.rs`): Pie chart renderer with per-pixel angle testing.
- `PieSlice` (`struct`, `pie.rs`): Label, value, color for a pie segment.
- `AreaChart` (`struct`, `area.rs`): Stacked cumulative area chart renderer.
- `ChartDataFrameOptions` (`struct`, `config.rs`): max_rows limiter for DataFrame integration.

## Functions
- `LineChart::new` (`line.rs`): Construct with optional config.
- `LineChart::add_series` (`line.rs`): Add a named data series.
- `LineChart::clear` (`line.rs`): Remove all series.
- `LineChart::render` (`line.rs`): Rasterize to pixel buffer.
- `BarChart::new` (`bar.rs`): Construct with optional config.
- `BarChart::add_series` (`bar.rs`): Add a named data series.
- `BarChart::set_bar_width` (`bar.rs`): Override automatic bar width.
- `BarChart::clear` (`bar.rs`): Remove all series.
- `BarChart::render` (`bar.rs`): Rasterize to pixel buffer.
- `ScatterPlot::new` (`scatter.rs`): Construct with optional config.
- `ScatterPlot::add_series` (`scatter.rs`): Add a named data series.
- `ScatterPlot::set_dot_radius` (`scatter.rs`): Set radius for data point circles.
- `ScatterPlot::clear` (`scatter.rs`): Remove all series.
- `ScatterPlot::render` (`scatter.rs`): Rasterize to pixel buffer.
- `PieChart::new` (`pie.rs`): Construct with optional config.
- `PieChart::add_slice` (`pie.rs`): Add a labeled slice.
- `PieChart::clear` (`pie.rs`): Remove all slices.
- `PieChart::render` (`pie.rs`): Rasterize to pixel buffer.
- `AreaChart::new` (`area.rs`): Construct with optional config.
- `AreaChart::add_series` (`area.rs`): Add a named data series.
- `AreaChart::clear` (`area.rs`): Remove all series.
- `AreaChart::render` (`area.rs`): Rasterize to pixel buffer.
- `set_pixel` (`render_utils.rs`): Write a pixel to the buffer.
- `draw_line` (`render_utils.rs`): Bresenham line rasterization.
- `draw_rect_filled` (`render_utils.rs`): Filled rectangle.
- `draw_circle_filled` (`render_utils.rs`): Filled circle.
- `fill_buffer` (`render_utils.rs`): Clear entire buffer to a color.
- `auto_range` (`render_utils.rs`): Compute axis bounds from data.
- `world_to_screen` (`render_utils.rs`): Map data coordinates to pixel coordinates.

## Lua API Reference
- Binding path(s): `src/lua_api/charts_api.rs`
- Namespace: `lurek.charts`

### Module Functions
- `lurek.charts.newLine(config?)` → LuaLineChart: Create a line chart.
- `lurek.charts.newBar(config?)` → LuaBarChart: Create a bar chart.
- `lurek.charts.newScatter(config?)` → LuaScatterPlot: Create a scatter plot.
- `lurek.charts.newPie(config?)` → LuaPieChart: Create a pie chart.
- `lurek.charts.newArea(config?)` → LuaAreaChart: Create an area chart.
- `lurek.charts.defaultPalette()` → table: Return the 8-color default palette.
- `lurek.charts.seriesColor(index)` → table: Get a palette color by series index.

### Userdata Methods

#### Line / Bar / Scatter / Area
- `chart:addSeries(name, data, color?)`: Add a named data series.
- `chart:clear()`: Remove all series.
- `chart:setTitle(title)`: Set the chart title.
- `chart:render()` → ImageData: Rasterize the chart to a pixel buffer.
- `chart:getWidth()` → number: Chart pixel width.
- `chart:getHeight()` → number: Chart pixel height.

#### Bar (additional)
- `chart:setBarWidth(width)`: Override automatic bar width.

#### Scatter (additional)
- `chart:setDotRadius(radius)`: Set data point circle radius.

#### Pie
- `chart:addSlice(label, value, color?)`: Add a labeled pie slice.
- `chart:clear()`: Remove all slices.
- `chart:setTitle(title)`: Set the chart title.
- `chart:render()` → ImageData: Rasterize the chart to a pixel buffer.
- `chart:getWidth()` → number: Chart pixel width.
- `chart:getHeight()` → number: Chart pixel height.

## Notes
- Extracted from `src/ui/chart.rs` and `src/ui/data_graph_renderer.rs`. Feature-gated behind `ui-charts`.
- Software-rasterized to RGBA8 pixel buffers — no GPU dependency.
- Charts render to pixel data that can be used as textures in the render pipeline.
- The 8-color DEFAULT_PALETTE auto-assigns series colors.

## References
- [image.md](image.md) — ImageData buffer type used for chart output.
- [render.md](render.md) — chart buffers uploaded as textures for display.
- [dataframe.md](dataframe.md) — DataFrame integration for chart data sources.
- Example: `content/examples/charts.lua`
