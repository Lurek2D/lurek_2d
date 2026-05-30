# charts

## TL;DR

- Software-rasterized chart renderers (line, bar, scatter, pie, area) that output RGBA8 pixel buffers.

## General Info

- Module group: `Feature Systems`
- Source path: `src/charts/`
- Binding: `src/lua_api/charts_api.rs`
- Namespace: `lurek.charts`
- Lua API surface: `7` functions, `5` types, `32` methods
- Rust test path(s): tests/rust/unit/charts_tests.rs
- Lua test path(s): tests/lua/unit/test_charts_core_unit.lua

## Summary

The `charts` module is a CPU-side chart rendering system for data visualization, designed to work without a dedicated GPU chart pipeline. It supports line, bar, scatter, pie, and area charts, with shared configuration and raster helpers that produce pixel buffers suitable for reuse as textures in normal render flows.

Each chart type is implemented in its own module (`line`, `bar`, `scatter`, `pie`, `area`) while shared appearance/data contracts live in `config` and drawing primitives live in `render_utils`. This keeps chart-specific behavior isolated while preserving consistent styling and axis/legend behavior across chart families.

The module is intentionally data-driven: callers provide series/slice data and chart options, and the renderer emits deterministic software raster output. This makes charts reproducible in tests and usable in headless or tooling contexts where GPU access is not assumed.

Because chart rendering can be consumed by UI and reporting paths, the boundary should stay focused on conversion from numeric data to image output. Layout orchestration and interaction policy belong to higher layers.

## Imports

- `color`: Imports or references `src/color/`. Cross-group dependency from ``Feature Systems`` into `Edge/Integration`.
- `dataframe`: Imports or references `src/dataframe/`. Cross-group dependency from ``Feature Systems`` into `Foundations`.
- `image`: Imports or references `src/image/`. Cross-group dependency from ``Feature Systems`` into `Platform Services`.

## Files

### area.rs

- Implements area-chart rasterization where series are rendered as filled regions over plot space.
- Supports overlapping and stacked accumulation modes for comparative and compositional data views.
- Maps data coordinates into pixel coordinates through shared chart-space transform helpers.
- Produces RGBA buffers that downstream systems upload as textures for runtime presentation.
- Integrates optional DataFrame extraction paths for column-driven area plotting workflows.
- Serves as the filled-series rendering backend behind the charts area API surface.

### bar.rs

- Implements bar-chart rasterization for categorical comparison through grouped or stacked layouts.
- Supports configurable bar width, spacing, and orientation behavior across multiple value series.
- Converts scaled chart coordinates into pixel-aligned rectangle fills for each rendered segment.
- Produces RGBA image buffers suitable for per-frame upload and display in runtime overlays.
- Serves as the rectangular-series rendering backend for the charts bar API path.

### config.rs

- Defines shared chart configuration contracts used across all chart rendering variants.
- Stores dimensions, margins, titles, palette defaults, and optional legend or axis metadata.
- Provides common series and DataFrame mapping structures consumed by concrete chart specs.
- Serves as the canonical option layer for consistent chart behavior and appearance.

### line.rs

- Implements line-chart rasterization for connected series over categorical or continuous domains.
- Supports multi-series rendering with configurable color, width, and optional point markers.
- Maps value space into pixel coordinates through shared chart transformation utilities.
- Produces RGBA output buffers that can be uploaded as frame-local chart textures.
- Serves as the polyline rendering backend exposed through the charts line API.

### mod.rs

- Defines the charts module boundary for CPU-rasterized data-visualization rendering.
- Groups chart types, shared config contracts, and utility drawing primitives into one surface.
- Serves as the composition entry for runtime chart image generation from raw series or DataFrames.

### pie.rs

- Implements pie-style chart rasterization where values are mapped to proportional angular slices.
- Computes normalized slice spans and renders arc-filled sectors into RGBA output buffers.
- Supports optional donut-hole shaping and label metadata for ring-style visual presentation.
- Integrates DataFrame-derived value extraction for tabular-to-pie plotting workflows.
- Serves as the circular-segment rendering backend behind the charts pie API.

### render_utils.rs

- Provides shared CPU rasterization helpers used by all chart renderer implementations.
- Includes primitive pixel operations for points, lines, circles, rectangles, and full-buffer fills.
- Converts chart data coordinates to screen-space pixels through normalized range mapping utilities.
- Computes automatic value ranges across multiple series for default axis domain selection.
- Serves as the low-level drawing toolkit for consistent chart image generation behavior.

### scatter.rs

- Implements scatter-plot rasterization for point-cloud visualization of value distribution and relation.
- Draws each sample as a configurable filled marker over chart-space transformed coordinates.
- Supports automatic domain estimation or explicit axis bounds for controlled plot framing.
- Produces RGBA output buffers suitable for texture upload in runtime chart presentation.
- Serves as the point-series rendering backend for the charts scatter API path.

## Lua API Ref

### Functions

- `lurek.charts.defaultPalette`: Get the default 8-color series palette.
- `lurek.charts.newArea`: Create a new area chart exposed by the lurek engine.
- `lurek.charts.newBar`: Create a new bar chart exposed by the lurek engine.
- `lurek.charts.newLine`: Create a new line chart exposed by the lurek engine.
- `lurek.charts.newPie`: Create a new pie chart exposed by the lurek engine.
- `lurek.charts.newScatter`: Create a new scatter plot exposed by the lurek engine.
- `lurek.charts.seriesColor`: Get a palette color by 1-based index (wraps around for index > 8).

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LAreaChart Type

- Lua userdata for rendering a stacked area series chart.

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

- Lua userdata for rendering a vertical bar series chart.

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

- Lua userdata for rendering a connected line series chart.

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

- Lua userdata for rendering a pie slice chart.

##### Fields

- No documented fields.

##### Methods

- `LPieChart:addSlice`: Add a slice to the pie chart Ă˘â‚¬â€ť Lua userdata object exposed by the engine.
- `LPieChart:clear`: Removes all pie data slices from this chart.
- `LPieChart:getHeight`: Get the chart output height in pixels.
- `LPieChart:getWidth`: Get the chart output width in pixels.
- `LPieChart:render`: Renders the chart contents into a new pixel buffer.
- `LPieChart:setTitle`: Set or update the chart's displayed title.

#### LScatterPlot Type

- Lua-visible scatter plot userdata.

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
