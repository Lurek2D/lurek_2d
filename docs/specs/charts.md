# charts

## TL;DR

- Rasterizes line, bar, area, scatter, and pie charts into RGBA buffers.

## General Info

- Module group: `Feature Systems`
- Source path: `src/charts/`
- Binding: `src/lua_api/charts_api.rs`
- Namespace: `lurek.charts`
- Lua API surface: `7` functions, `5` types, `32` methods
- Rust test path(s): tests/rust/unit/charts_tests.rs
- Lua test path(s): tests/lua/unit/test_charts_core_unit.lua

## Summary

- Lets users render runtime charts directly inside the engine for telemetry, balancing, and player-facing dashboards.
- Converts raw Lua series and table-like data into ready-to-display RGBA images without external plotting tools.
- Supports line, bar, area, scatter, and pie workflows so teams can choose the right visual grammar per metric.
- Helps debug progression, economy, and performance trends during live sessions instead of offline exports.
- Exposes chart titles, sizing, and palette controls for fast integration into HUD or debug overlays.
- Handles value-range mapping and coordinate transforms so scripts can focus on data, not pixel math.
- Works well for static snapshots and repeated redraws in tooling panels.
- Bridges DataFrame-style analytics output with immediate visual interpretation.
- Reduces friction for QA and designers who need quick, embedded diagnostic visuals.
- Keeps chart generation deterministic and portable because it runs on CPU-side rasterization.
- Serves as the in-engine visualization surface for numeric storytelling and runtime observability.
- Helps turn raw counters into actionable feedback for tuning gameplay systems.
- Gives projects a practical path from data collection to readable visual output in one module.

This module primarily collaborates with `color`, `dataframe`, `image`. Its responsibility should stay inside the `Feature Systems` group rather than absorb behavior owned by those neighbors.

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

- CPU-based rasterization toolkit providing pixel-level drawing operations (points, lines, circles, filled rectangles, buffer fills) for software chart rendering.
- Implements Bresenham line algorithm, per-pixel distance-based circle fill, and normalized coordinate mapping from data-space to screen-space pixels.
- Computes automatic value range bounds across multiple series to establish default axis domains avoiding degenerate zero-width ranges.
- Maintains consistent low-level drawing semantics across all chart renderer implementations enabling uniform image generation behavior.
- Clamps coordinates to buffer bounds, handling edge cases like zero-sized ranges and out-of-bounds pixel access silently.

### scatter.rs

- Implements scatter-plot rasterization for point-cloud visualization of value distribution and relation.
- Draws each sample as a configurable filled marker over chart-space transformed coordinates.
- Supports automatic domain estimation or explicit axis bounds for controlled plot framing.
- Produces RGBA output buffers suitable for texture upload in runtime chart presentation.
- Serves as the point-series rendering backend for the charts scatter API path.

## Lua API Ref

### Functions

- `lurek.charts.defaultPalette() -> table`: Get the default 8-color series palette.
- `lurek.charts.newArea(config?) -> LAreaChart`: Create a new area chart exposed by the lurek engine.
- `lurek.charts.newBar(config?) -> LBarChart`: Create a new bar chart exposed by the lurek engine.
- `lurek.charts.newLine(config?) -> LLineChart`: Create a new line chart exposed by the lurek engine.
- `lurek.charts.newPie(config?) -> LPieChart`: Create a new pie chart exposed by the lurek engine.
- `lurek.charts.newScatter(config?) -> LScatterPlot`: Create a new scatter plot exposed by the lurek engine.
- `lurek.charts.seriesColor(index) -> table`: Get a palette color by 1-based index (wraps around for index > 8).

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

- `LAreaChart:addSeries(name, data, color?) -> nil`: Add a named data series to the area chart (stacked above previous).
- `LAreaChart:clear() -> nil`: Removes all data series from this chart.
- `LAreaChart:getHeight() -> number`: Get the chart output height in pixels.
- `LAreaChart:getWidth() -> number`: Get the chart output width in pixels.
- `LAreaChart:render() -> number`: Renders the chart contents into a new pixel buffer.
- `LAreaChart:setTitle(title) -> nil`: Set or update the chart's displayed title.

#### LBarChart Type

- Lua userdata for rendering a vertical bar series chart.

##### Fields

- No documented fields.

##### Methods

- `LBarChart:addSeries(name, data, color?) -> nil`: Add a named data series to the bar chart.
- `LBarChart:clear() -> nil`: Removes all data series from this chart.
- `LBarChart:getHeight() -> number`: Get the chart output height in pixels.
- `LBarChart:getWidth() -> number`: Get the chart output width in pixels.
- `LBarChart:render() -> number`: Renders the chart contents into a new pixel buffer.
- `LBarChart:setBarWidth(width) -> nil`: Set the pixel width of individual bars in this chart.
- `LBarChart:setTitle(title) -> nil`: Set or update the chart's displayed title.

#### LLineChart Type

- Lua userdata for rendering a connected line series chart.

##### Fields

- No documented fields.

##### Methods

- `LLineChart:addSeries(name, data, color?) -> nil`: Add a named data series to the line chart.
- `LLineChart:clear() -> nil`: Removes all data series from this chart.
- `LLineChart:getHeight() -> number`: Get the chart output height in pixels.
- `LLineChart:getWidth() -> number`: Get the chart output width in pixels.
- `LLineChart:render() -> number`: Renders the chart contents into a new pixel buffer.
- `LLineChart:setTitle(title) -> nil`: Set or update the chart's displayed title.

#### LPieChart Type

- Lua userdata for rendering a pie slice chart.

##### Fields

- No documented fields.

##### Methods

- `LPieChart:addSlice(label, value, color?) -> nil`: Add a slice to the pie chart Ă˘â‚¬â€ť Lua userdata object exposed by the engine.
- `LPieChart:clear() -> nil`: Removes all pie data slices from this chart.
- `LPieChart:getHeight() -> number`: Get the chart output height in pixels.
- `LPieChart:getWidth() -> number`: Get the chart output width in pixels.
- `LPieChart:render() -> number`: Renders the chart contents into a new pixel buffer.
- `LPieChart:setTitle(title) -> nil`: Set or update the chart's displayed title.

#### LScatterPlot Type

- Lua-visible scatter plot userdata.

##### Fields

- No documented fields.

##### Methods

- `LScatterPlot:addSeries(name, data, color?) -> nil`: Add a named data series to the scatter plot.
- `LScatterPlot:clear() -> nil`: Removes all data series from this chart.
- `LScatterPlot:getHeight() -> number`: Get the chart output height in pixels.
- `LScatterPlot:getWidth() -> number`: Get the chart output width in pixels.
- `LScatterPlot:render() -> number`: Renders the chart contents into a new pixel buffer.
- `LScatterPlot:setDotRadius(r) -> nil`: Set the radius of the dot drawn for each data point.
- `LScatterPlot:setTitle(title) -> nil`: Set or update the chart's displayed title.
