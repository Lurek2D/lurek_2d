# charts

## TL;DR

- Rasterizes line, bar, area, scatter, pie, histogram, and heatmap charts into RGBA buffers and drawable runtime textures.

## General Info

- Module group: `Feature Systems`
- Source path: `src/charts/`
- Binding: `src/lua_api/charts_api.rs`
- Namespace: `lurek.charts`
- Lua API surface: `9` functions, `7` types, `146` methods
- Rust test path(s): tests/rust/unit/charts_tests.rs
- Lua test path(s): tests/lua/unit/test_charts_core_unit.lua

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

### heatmap.rs

- Implements heatmap rasterization for matrix-style ML and dashboard views.
- Maps matrix values to a configurable color ramp and annotates row/column labels.
- Supports direct matrix updates, per-cell streaming changes, and dataframe pivot ingestion.

### histogram.rs

- Implements histogram rasterization for distribution analysis and dashboard telemetry.
- Buckets numeric samples into configurable bins and renders grouped bars for one or more series.
- Supports streaming sample windows, dataframe ingestion, explicit ranges, and density mode.

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

- `lurek.charts.defaultPalette() -> nil`: Lua-facing function documented in the binding source.
- `lurek.charts.newArea(config?) -> nil`: Lua-facing function documented in the binding source.
- `lurek.charts.newBar(config?) -> nil`: Lua-facing function documented in the binding source.
- `lurek.charts.newHeatmap(config?) -> nil`: Lua-facing function documented in the binding source.
- `lurek.charts.newHistogram(config?) -> nil`: Lua-facing function documented in the binding source.
- `lurek.charts.newLine(config?) -> nil`: Lua-facing function documented in the binding source.
- `lurek.charts.newPie(config?) -> nil`: Lua-facing function documented in the binding source.
- `lurek.charts.newScatter(config?) -> nil`: Lua-facing function documented in the binding source.
- `lurek.charts.seriesColor(index) -> nil`: Lua-facing function documented in the binding source.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LAreaChart Type

- Lua-visible object type.

##### Fields

- No documented fields.

##### Methods

- `LAreaChart:addLayer(name, values, color?) -> nil`: Lua-visible method.
- `LAreaChart:addLayerFromDataFrame() -> nil`: Lua-visible method.
- `LAreaChart:addSeries(name, data, color?) -> nil`: Lua-visible method.
- `LAreaChart:appendPoint(name, x, y, color?) -> nil`: Lua-visible method.
- `LAreaChart:clear() -> nil`: Lua-visible method.
- `LAreaChart:draw(x, y, opts?) -> nil`: Lua-visible method.
- `LAreaChart:drawToImage(target) -> nil`: Lua-visible method.
- `LAreaChart:getHeight() -> nil`: Lua-visible method.
- `LAreaChart:getWidth() -> nil`: Lua-visible method.
- `LAreaChart:render() -> nil`: Lua-visible method.
- `LAreaChart:renderImage() -> nil`: Lua-visible method.
- `LAreaChart:setShowLegend(value) -> nil`: Lua-visible method.
- `LAreaChart:setTitle(title) -> nil`: Lua-visible method.
- `LAreaChart:setWindow(max_points?) -> nil`: Lua-visible method.
- `LAreaChart:setXLabel(label) -> nil`: Lua-visible method.
- `LAreaChart:setXTickCount(count) -> nil`: Lua-visible method.
- `LAreaChart:setYLabel(label) -> nil`: Lua-visible method.
- `LAreaChart:setYMax(value) -> nil`: Lua-visible method.
- `LAreaChart:setYTickCount(count) -> nil`: Lua-visible method.
- `LAreaChart:type() -> nil`: Lua-visible method.
- `LAreaChart:typeOf(name) -> nil`: Lua-visible method.

#### LBarChart Type

- Lua-visible object type.

##### Fields

- No documented fields.

##### Methods

- `LBarChart:addCategoriesFromDataFrame(df, label_col, value_cols, opts?) -> nil`: Lua-visible method.
- `LBarChart:addCategory(label, values) -> nil`: Lua-visible method.
- `LBarChart:addSeries(name, data, color?) -> nil`: Lua-visible method.
- `LBarChart:clear() -> nil`: Lua-visible method.
- `LBarChart:draw(x, y, opts?) -> nil`: Lua-visible method.
- `LBarChart:drawToImage(target) -> nil`: Lua-visible method.
- `LBarChart:getHeight() -> nil`: Lua-visible method.
- `LBarChart:getWidth() -> nil`: Lua-visible method.
- `LBarChart:render() -> nil`: Lua-visible method.
- `LBarChart:renderImage() -> nil`: Lua-visible method.
- `LBarChart:setBarWidth(width) -> nil`: Lua-visible method.
- `LBarChart:setShowLegend(value) -> nil`: Lua-visible method.
- `LBarChart:setTitle(title) -> nil`: Lua-visible method.
- `LBarChart:setXLabel(label) -> nil`: Lua-visible method.
- `LBarChart:setXTickCount(count) -> nil`: Lua-visible method.
- `LBarChart:setYLabel(label) -> nil`: Lua-visible method.
- `LBarChart:setYTickCount(count) -> nil`: Lua-visible method.
- `LBarChart:type() -> nil`: Lua-visible method.
- `LBarChart:typeOf(name) -> nil`: Lua-visible method.

#### LHeatmapChart Type

- Lua-visible object type.

##### Fields

- No documented fields.

##### Methods

- `LHeatmapChart:clear() -> nil`: Lua-visible method.
- `LHeatmapChart:clearValueRange() -> nil`: Lua-visible method.
- `LHeatmapChart:draw(x, y, opts?) -> nil`: Lua-visible method.
- `LHeatmapChart:drawToImage(target) -> nil`: Lua-visible method.
- `LHeatmapChart:getHeight() -> nil`: Lua-visible method.
- `LHeatmapChart:getWidth() -> nil`: Lua-visible method.
- `LHeatmapChart:render() -> nil`: Lua-visible method.
- `LHeatmapChart:renderImage() -> nil`: Lua-visible method.
- `LHeatmapChart:resize(rows, cols) -> nil`: Lua-visible method.
- `LHeatmapChart:setCell(row, col, value) -> nil`: Lua-visible method.
- `LHeatmapChart:setColorRange(low, high) -> nil`: Lua-visible method.
- `LHeatmapChart:setColumnLabels(labels) -> nil`: Lua-visible method.
- `LHeatmapChart:setMatrix(matrix, row_labels?, col_labels?) -> nil`: Lua-visible method.
- `LHeatmapChart:setMatrixFromDataFrame(df, row_col, col_col, value_col, opts?) -> nil`: Lua-visible method.
- `LHeatmapChart:setRowLabels(labels) -> nil`: Lua-visible method.
- `LHeatmapChart:setShowLegend(value) -> nil`: Lua-visible method.
- `LHeatmapChart:setShowValues(value) -> nil`: Lua-visible method.
- `LHeatmapChart:setTitle(title) -> nil`: Lua-visible method.
- `LHeatmapChart:setValueRange(min, max) -> nil`: Lua-visible method.
- `LHeatmapChart:type() -> nil`: Lua-visible method.
- `LHeatmapChart:typeOf(name) -> nil`: Lua-visible method.

#### LHistogramChart Type

- Lua-visible object type.

##### Fields

- No documented fields.

##### Methods

- `LHistogramChart:addSeries(name, values, color?) -> nil`: Lua-visible method.
- `LHistogramChart:addSeriesFromDataFrame() -> nil`: Lua-visible method.
- `LHistogramChart:appendValue(name, value, color?) -> nil`: Lua-visible method.
- `LHistogramChart:clear() -> nil`: Lua-visible method.
- `LHistogramChart:clearRange() -> nil`: Lua-visible method.
- `LHistogramChart:draw(x, y, opts?) -> nil`: Lua-visible method.
- `LHistogramChart:drawToImage(target) -> nil`: Lua-visible method.
- `LHistogramChart:getHeight() -> nil`: Lua-visible method.
- `LHistogramChart:getWidth() -> nil`: Lua-visible method.
- `LHistogramChart:render() -> nil`: Lua-visible method.
- `LHistogramChart:renderImage() -> nil`: Lua-visible method.
- `LHistogramChart:replaceSeries(name, values, color?) -> nil`: Lua-visible method.
- `LHistogramChart:setBinCount(bins) -> nil`: Lua-visible method.
- `LHistogramChart:setDensity(enabled) -> nil`: Lua-visible method.
- `LHistogramChart:setRange(min, max) -> nil`: Lua-visible method.
- `LHistogramChart:setShowLegend(value) -> nil`: Lua-visible method.
- `LHistogramChart:setTitle(title) -> nil`: Lua-visible method.
- `LHistogramChart:setWindow(max_points?) -> nil`: Lua-visible method.
- `LHistogramChart:setXLabel(label) -> nil`: Lua-visible method.
- `LHistogramChart:setXTickCount(count) -> nil`: Lua-visible method.
- `LHistogramChart:setYLabel(label) -> nil`: Lua-visible method.
- `LHistogramChart:setYTickCount(count) -> nil`: Lua-visible method.
- `LHistogramChart:type() -> nil`: Lua-visible method.
- `LHistogramChart:typeOf(name) -> nil`: Lua-visible method.

#### LLineChart Type

- Lua-visible object type.

##### Fields

- No documented fields.

##### Methods

- `LLineChart:addSeries(name, data, color?) -> nil`: Lua-visible method.
- `LLineChart:addSeriesFromDataFrame() -> nil`: Lua-visible method.
- `LLineChart:appendPoint(name, x, y, color?) -> nil`: Lua-visible method.
- `LLineChart:clear() -> nil`: Lua-visible method.
- `LLineChart:draw(x, y, opts?) -> nil`: Lua-visible method.
- `LLineChart:drawToImage(target) -> nil`: Lua-visible method.
- `LLineChart:getHeight() -> nil`: Lua-visible method.
- `LLineChart:getWidth() -> nil`: Lua-visible method.
- `LLineChart:nearest(x, y) -> nil`: Lua-visible method.
- `LLineChart:render() -> nil`: Lua-visible method.
- `LLineChart:renderImage() -> nil`: Lua-visible method.
- `LLineChart:replaceSeries(name, data, color?) -> nil`: Lua-visible method.
- `LLineChart:setShowLegend(value) -> nil`: Lua-visible method.
- `LLineChart:setTitle(title) -> nil`: Lua-visible method.
- `LLineChart:setWindow(max_points?) -> nil`: Lua-visible method.
- `LLineChart:setXLabel(label) -> nil`: Lua-visible method.
- `LLineChart:setXMax(value) -> nil`: Lua-visible method.
- `LLineChart:setXTickCount(count) -> nil`: Lua-visible method.
- `LLineChart:setYLabel(label) -> nil`: Lua-visible method.
- `LLineChart:setYMax(value) -> nil`: Lua-visible method.
- `LLineChart:setYTickCount(count) -> nil`: Lua-visible method.
- `LLineChart:type() -> nil`: Lua-visible method.
- `LLineChart:typeOf(name) -> nil`: Lua-visible method.

#### LPieChart Type

- Lua-visible object type.

##### Fields

- No documented fields.

##### Methods

- `LPieChart:addSegment(label, value, color?) -> nil`: Lua-visible method.
- `LPieChart:addSegmentsFromDataFrame(df, label_col, value_col, opts?) -> nil`: Lua-visible method.
- `LPieChart:addSlice(label, value, color?) -> nil`: Lua-visible method.
- `LPieChart:clear() -> nil`: Lua-visible method.
- `LPieChart:draw(x, y, opts?) -> nil`: Lua-visible method.
- `LPieChart:drawToImage(target) -> nil`: Lua-visible method.
- `LPieChart:getHeight() -> nil`: Lua-visible method.
- `LPieChart:getWidth() -> nil`: Lua-visible method.
- `LPieChart:render() -> nil`: Lua-visible method.
- `LPieChart:renderImage() -> nil`: Lua-visible method.
- `LPieChart:setShowLegend(value) -> nil`: Lua-visible method.
- `LPieChart:setTitle(title) -> nil`: Lua-visible method.
- `LPieChart:type() -> nil`: Lua-visible method.
- `LPieChart:typeOf(name) -> nil`: Lua-visible method.

#### LScatterPlot Type

- Lua-visible object type.

##### Fields

- No documented fields.

##### Methods

- `LScatterPlot:addSeries(name, data, color?) -> nil`: Lua-visible method.
- `LScatterPlot:addSeriesFromDataFrame() -> nil`: Lua-visible method.
- `LScatterPlot:appendPoint(name, x, y, color?) -> nil`: Lua-visible method.
- `LScatterPlot:clear() -> nil`: Lua-visible method.
- `LScatterPlot:draw(x, y, opts?) -> nil`: Lua-visible method.
- `LScatterPlot:drawToImage(target) -> nil`: Lua-visible method.
- `LScatterPlot:getHeight() -> nil`: Lua-visible method.
- `LScatterPlot:getWidth() -> nil`: Lua-visible method.
- `LScatterPlot:nearest(x, y) -> nil`: Lua-visible method.
- `LScatterPlot:render() -> nil`: Lua-visible method.
- `LScatterPlot:renderImage() -> nil`: Lua-visible method.
- `LScatterPlot:replaceSeries(name, data, color?) -> nil`: Lua-visible method.
- `LScatterPlot:setDotRadius(radius) -> nil`: Lua-visible method.
- `LScatterPlot:setShowLegend(value) -> nil`: Lua-visible method.
- `LScatterPlot:setTitle(title) -> nil`: Lua-visible method.
- `LScatterPlot:setWindow(max_points?) -> nil`: Lua-visible method.
- `LScatterPlot:setXLabel(label) -> nil`: Lua-visible method.
- `LScatterPlot:setXRange(min_x, max_x) -> nil`: Lua-visible method.
- `LScatterPlot:setXTickCount(count) -> nil`: Lua-visible method.
- `LScatterPlot:setYLabel(label) -> nil`: Lua-visible method.
- `LScatterPlot:setYRange(min_y, max_y) -> nil`: Lua-visible method.
- `LScatterPlot:setYTickCount(count) -> nil`: Lua-visible method.
- `LScatterPlot:type() -> nil`: Lua-visible method.
- `LScatterPlot:typeOf(name) -> nil`: Lua-visible method.

## References

- `color`: Imports or references `src/color/`. Cross-group dependency from ``Feature Systems`` into `Edge/Integration`.
- `dataframe`: Imports or references `src/dataframe/`. Cross-group dependency from ``Feature Systems`` into `Foundations`.
- `image`: Imports or references `src/image/`. Cross-group dependency from ``Feature Systems`` into `Platform Services`.

## Notes

- No additional module-specific notes.
