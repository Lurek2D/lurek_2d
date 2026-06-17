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
- Owns the public charting API; UI should consume chart output as images/textures instead of exposing duplicate chart constructors.
- Telemetry-oriented modules such as `devtools`, `overlay`, and `particle` expose raw stats; this module visualizes caller-provided data rather than collecting metrics itself.
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

- Implements area-chart rasterization where series are rendered as filled regions over plot space. `charts/area` delivers the area implementation for the charts subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Supports overlapping and stacked accumulation modes for comparative and compositional data views. The file owns or coordinates data contracts including `AreaChart`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Maps data coordinates into pixel coordinates through shared chart-space transform helpers. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `add_series`, `add_layer`, `add_layer_from_dataframe`, `draw_to_image`, `clear`, and 4 more stays attached to the local data model and invariants.
- Produces RGBA buffers that downstream systems upload as textures for runtime presentation. Runtime integration reaches sibling engine areas through crate modules `charts`, `color`, `dataframe`, `image`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Integrates optional DataFrame extraction paths for column-driven area plotting workflows. External integration uses no named public items, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### bar.rs

- Implements bar-chart rasterization for categorical comparison through grouped or stacked layouts. `charts/bar` delivers the bar implementation for the charts subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Supports configurable bar width, spacing, and orientation behavior across multiple value series. The file owns or coordinates data contracts including `BarChart`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Converts scaled chart coordinates into pixel-aligned rectangle fills for each rendered segment. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `push_series`, `add_series`, `add_series_data`, `add_category`, `add_categories_from_dataframe`, and 6 more stays attached to the local data model and invariants.
- Produces RGBA image buffers suitable for per-frame upload and display in runtime overlays. Runtime integration reaches sibling engine areas through crate modules `charts`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Serves as the rectangular-series rendering backend for the charts bar API path. External integration uses no named public items, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### config.rs

- Defines shared chart configuration contracts used across all chart rendering variants. `charts/config` delivers the configuration schema and defaults for the charts subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Stores dimensions, margins, titles, palette defaults, and optional legend or axis metadata. The file owns or coordinates data contracts including `ChartMargin`, `ChartConfig`, `ChartSeries`, `ChartDataFrameOptions`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Provides common series and DataFrame mapping structures consumed by concrete chart specs. Public callable behavior is centered on no named public items, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Serves as the canonical option layer for consistent chart behavior and appearance. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### heatmap.rs

- Implements heatmap rasterization for matrix-style ML and dashboard views. `charts/heatmap` delivers the heatmap implementation for the charts subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Maps matrix values to a configurable color ramp and annotates row/column labels. The file owns or coordinates data contracts including `HeatmapChart`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supports direct matrix updates, per-cell streaming changes, and dataframe pivot ingestion. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `resize`, `set_matrix`, `set_matrix_from_dataframe`, `set_cell`, `clear`, and 8 more stays attached to the local data model and invariants.
- `charts/heatmap` delivers the heatmap implementation for the charts subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- The file owns or coordinates data contracts including `HeatmapChart`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `resize`, `set_matrix`, `set_matrix_from_dataframe`, `set_cell`, `clear`, and 8 more stays attached to the local data model and invariants.

### histogram.rs

- Implements histogram rasterization for distribution analysis and dashboard telemetry. `charts/histogram` delivers the histogram implementation for the charts subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Buckets numeric samples into configurable bins and renders grouped bars for one or more series. The file owns or coordinates data contracts including `HistogramSeries`, `HistogramChart`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supports streaming sample windows, dataframe ingestion, explicit ranges, and density mode. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `add_series`, `add_series_from_dataframe`, `replace_series`, `append_value`, `clear`, and 8 more stays attached to the local data model and invariants.
- `charts/histogram` delivers the histogram implementation for the charts subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- The file owns or coordinates data contracts including `HistogramSeries`, `HistogramChart`, so readers can connect concrete Rust types to the feature responsibilities described by this module.

### line.rs

- Implements line-chart rasterization for connected series over categorical or continuous domains. `charts/line` delivers the line implementation for the charts subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Supports multi-series rendering with configurable color, width, and optional point markers. The file owns or coordinates data contracts including `LineChart`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Maps value space into pixel coordinates through shared chart transformation utilities. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `push_series`, `add_series`, `add_series_from_dataframe`, `draw_to_image`, `clear`, and 5 more stays attached to the local data model and invariants.
- Produces RGBA output buffers that can be uploaded as frame-local chart textures. Runtime integration reaches sibling engine areas through crate modules `charts`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Serves as the polyline rendering backend exposed through the charts line API. External integration uses no named public items, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### mod.rs

- Defines the charts module boundary for CPU-rasterized data-visualization rendering. `charts/mod` is the charts module index, declaring `area`, `bar`, `config`, `heatmap`, `histogram`, and 4 more so agents can identify which files own each feature slice before opening implementation code.
- Groups chart types, shared config contracts, and utility drawing primitives into one surface. `src/charts/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `area::AreaChart`, `bar::BarChart`, `config::{ChartConfig, ChartDataFrameOptions, ChartMargin, ChartSeries}`, `heatmap::HeatmapChart`, and 4 more centralized for the charts subsystem.
- Serves as the composition entry for runtime chart image generation from raw series or DataFrames. The file documents how charts submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.
- `charts/mod` is the charts module index, declaring `area`, `bar`, `config`, `heatmap`, `histogram`, and 4 more so agents can identify which files own each feature slice before opening implementation code.
- `src/charts/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `area::AreaChart`, `bar::BarChart`, `config::{ChartConfig, ChartDataFrameOptions, ChartMargin, ChartSeries}`, `heatmap::HeatmapChart`, and 4 more centralized for the charts subsystem.
- The file documents how charts submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.

### pie.rs

- Implements pie-style chart rasterization where values are mapped to proportional angular slices. `charts/pie` delivers the pie implementation for the charts subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Computes normalized slice spans and renders arc-filled sectors into RGBA output buffers. The file owns or coordinates data contracts including `PieSlice`, `PieChart`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supports optional donut-hole shaping and label metadata for ring-style visual presentation. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `add_segment`, `add_segments_from_dataframe`, `draw_to_image`, `add_slice`, `clear`, and 2 more stays attached to the local data model and invariants.
- Integrates DataFrame-derived value extraction for tabular-to-pie plotting workflows. Runtime integration reaches sibling engine areas through crate modules `charts`, `color`, `dataframe`, `image`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### render_utils.rs

- CPU-based rasterization toolkit providing pixel-level drawing operations (points, lines, circles, filled rectangles, buffer fills) for software chart rendering.
- Implements Bresenham line algorithm, per-pixel distance-based circle fill, and normalized coordinate mapping from data-space to screen-space pixels.
- Computes automatic value range bounds across multiple series to establish default axis domains avoiding degenerate zero-width ranges.
- Maintains consistent low-level drawing semantics across all chart renderer implementations enabling uniform image generation behavior.
- Clamps coordinates to buffer bounds, handling edge cases like zero-sized ranges and out-of-bounds pixel access silently.
- `charts/render_utils` delivers the render utils implementation for the charts subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

### scatter.rs

- Implements scatter-plot rasterization for point-cloud visualization of value distribution and relation. `charts/scatter` delivers the scatter implementation for the charts subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Draws each sample as a configurable filled marker over chart-space transformed coordinates. The file owns or coordinates data contracts including `ScatterPlot`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supports automatic domain estimation or explicit axis bounds for controlled plot framing. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `push_series_raw`, `add_series`, `add_series_from_dataframe`, `draw_to_image`, `clear`, and 6 more stays attached to the local data model and invariants.
- Produces RGBA output buffers suitable for texture upload in runtime chart presentation. Runtime integration reaches sibling engine areas through crate modules `charts`, `color`, `dataframe`, `image`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Serves as the point-series rendering backend for the charts scatter API path. External integration uses no named public items, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.



## Lua API Ref

### Functions

- `lurek.charts.defaultPalette() -> nil`: Default palette.
- `lurek.charts.newArea(config?) -> nil`: New area.
- `lurek.charts.newBar(config?) -> nil`: New bar.
- `lurek.charts.newHeatmap(config?) -> nil`: New heatmap.
- `lurek.charts.newHistogram(config?) -> nil`: New histogram.
- `lurek.charts.newLine(config?) -> nil`: New line.
- `lurek.charts.newPie(config?) -> nil`: New pie.
- `lurek.charts.newScatter(config?) -> nil`: New scatter.
- `lurek.charts.seriesColor(index) -> nil`: Series color.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LAreaChart Type

- Lua handle for an area chart with stacked layers or named series.

##### Fields

- No documented fields.

##### Methods

- `LAreaChart:addLayer(name, values, color?) -> nil`: Adds one filled area layer from a numeric value list.
- `LAreaChart:addLayerFromDataFrame() -> nil`: Builds one filled area layer from a dataframe value column.
- `LAreaChart:addSeries(name, data, color?) -> nil`: Adds a named area series from an array-style Lua table of points.
- `LAreaChart:appendPoint(name, x, y, color?) -> nil`: Appends one finite point to a named area series.
- `LAreaChart:clear() -> nil`: Clears the state.
- `LAreaChart:draw(x, y, opts?) -> nil`: Draws the area chart at world or screen coordinates using optional transform options.
- `LAreaChart:drawToImage(target) -> nil`: Draw to image.
- `LAreaChart:getHeight() -> nil`: Returns the height.
- `LAreaChart:getWidth() -> nil`: Returns the width.
- `LAreaChart:render() -> nil`: Render.
- `LAreaChart:renderImage() -> nil`: Render image.
- `LAreaChart:setShowLegend(value) -> nil`: Sets the show legend.
- `LAreaChart:setTitle(title) -> nil`: Sets the title.
- `LAreaChart:setWindow(max_points?) -> nil`: Sets the window.
- `LAreaChart:setXLabel(label) -> nil`: Sets the x label.
- `LAreaChart:setXTickCount(count) -> nil`: Sets the x tick count.
- `LAreaChart:setYLabel(label) -> nil`: Sets the y label.
- `LAreaChart:setYMax(value) -> nil`: Sets the y max.
- `LAreaChart:setYTickCount(count) -> nil`: Sets the y tick count.
- `LAreaChart:type() -> nil`: Type.
- `LAreaChart:typeOf(name) -> nil`: Type of.

#### LBarChart Type

- Lua handle for a grouped bar chart with named series and category labels.

##### Fields

- No documented fields.

##### Methods

- `LBarChart:addCategoriesFromDataFrame() -> nil`: Adds grouped bar categories by reading one label column and one or more value columns from a dataframe.
- `LBarChart:addCategory(label, values) -> nil`: Adds one category label with a numeric value list for grouped bars.
- `LBarChart:addSeries(name, data, color?) -> nil`: Adds a named bar series from an array-style Lua table of values or points.
- `LBarChart:clear() -> nil`: Clears the state.
- `LBarChart:draw(x, y, opts?) -> nil`: Draws the bar chart at world or screen coordinates using optional transform options.
- `LBarChart:drawToImage(target) -> nil`: Draw to image.
- `LBarChart:getHeight() -> nil`: Returns the height.
- `LBarChart:getWidth() -> nil`: Returns the width.
- `LBarChart:render() -> nil`: Render.
- `LBarChart:renderImage() -> nil`: Render image.
- `LBarChart:setBarWidth(width) -> nil`: Sets the bar width.
- `LBarChart:setShowLegend(value) -> nil`: Sets the show legend.
- `LBarChart:setTitle(title) -> nil`: Sets the title.
- `LBarChart:setXLabel(label) -> nil`: Sets the x label.
- `LBarChart:setXTickCount(count) -> nil`: Sets the x tick count.
- `LBarChart:setYLabel(label) -> nil`: Sets the y label.
- `LBarChart:setYTickCount(count) -> nil`: Sets the y tick count.
- `LBarChart:type() -> nil`: Type.
- `LBarChart:typeOf(name) -> nil`: Type of.

#### LHeatmapChart Type

- Lua handle for a heatmap chart backed by a numeric matrix.

##### Fields

- No documented fields.

##### Methods

- `LHeatmapChart:clear() -> nil`: Clears the state.
- `LHeatmapChart:clearValueRange() -> nil`: Clears value range.
- `LHeatmapChart:draw(x, y, opts?) -> nil`: Draws the heatmap at world or screen coordinates using optional transform options.
- `LHeatmapChart:drawToImage(target) -> nil`: Draw to image.
- `LHeatmapChart:getHeight() -> nil`: Returns the height.
- `LHeatmapChart:getWidth() -> nil`: Returns the width.
- `LHeatmapChart:render() -> nil`: Render.
- `LHeatmapChart:renderImage() -> nil`: Render image.
- `LHeatmapChart:resize(rows, cols) -> nil`: Resize.
- `LHeatmapChart:setCell(row, col, value) -> nil`: Sets the cell.
- `LHeatmapChart:setColorRange(low, high) -> nil`: Sets the low and high RGBA colors used for the heatmap gradient.
- `LHeatmapChart:setColumnLabels(labels) -> nil`: Sets the column labels.
- `LHeatmapChart:setMatrix(matrix, row_labels?, col_labels?) -> nil`: Replaces the heatmap contents from a numeric matrix with optional row and column labels.
- `LHeatmapChart:setMatrixFromDataFrame() -> nil`: Builds the heatmap contents from dataframe row, column, and value fields.
- `LHeatmapChart:setRowLabels(labels) -> nil`: Sets the row labels.
- `LHeatmapChart:setShowLegend(value) -> nil`: Sets the show legend.
- `LHeatmapChart:setShowValues(value) -> nil`: Sets the show values.
- `LHeatmapChart:setTitle(title) -> nil`: Sets the title.
- `LHeatmapChart:setValueRange(min, max) -> nil`: Sets the value range.
- `LHeatmapChart:type() -> nil`: Type.
- `LHeatmapChart:typeOf(name) -> nil`: Type of.

#### LHistogramChart Type

- Lua handle for a histogram chart that bins named numeric samples.

##### Fields

- No documented fields.

##### Methods

- `LHistogramChart:addSeries(name, values, color?) -> nil`: Adds a named histogram sample series from a numeric value list.
- `LHistogramChart:addSeriesFromDataFrame() -> nil`: Builds a named histogram sample series from one dataframe value column.
- `LHistogramChart:appendValue(name, value, color?) -> nil`: Appends one finite numeric sample to a named histogram series.
- `LHistogramChart:clear() -> nil`: Clears the state.
- `LHistogramChart:clearRange() -> nil`: Clears range.
- `LHistogramChart:draw(x, y, opts?) -> nil`: Draws the histogram at world or screen coordinates using optional transform options.
- `LHistogramChart:drawToImage(target) -> nil`: Draw to image.
- `LHistogramChart:getHeight() -> nil`: Returns the height.
- `LHistogramChart:getWidth() -> nil`: Returns the width.
- `LHistogramChart:render() -> nil`: Render.
- `LHistogramChart:renderImage() -> nil`: Render image.
- `LHistogramChart:replaceSeries(name, values, color?) -> nil`: Replaces a named histogram sample series with a new numeric value list.
- `LHistogramChart:setBinCount(bins) -> nil`: Sets the bin count.
- `LHistogramChart:setDensity(enabled) -> nil`: Sets the density.
- `LHistogramChart:setRange(min, max) -> nil`: Sets the range.
- `LHistogramChart:setShowLegend(value) -> nil`: Sets the show legend.
- `LHistogramChart:setTitle(title) -> nil`: Sets the title.
- `LHistogramChart:setWindow(max_points?) -> nil`: Sets the window.
- `LHistogramChart:setXLabel(label) -> nil`: Sets the x label.
- `LHistogramChart:setXTickCount(count) -> nil`: Sets the x tick count.
- `LHistogramChart:setYLabel(label) -> nil`: Sets the y label.
- `LHistogramChart:setYTickCount(count) -> nil`: Sets the y tick count.
- `LHistogramChart:type() -> nil`: Type.
- `LHistogramChart:typeOf(name) -> nil`: Type of.

#### LLineChart Type

- Lua handle for a line chart with named x/y series and cached draw output.

##### Fields

- No documented fields.

##### Methods

- `LLineChart:addSeries(name, data, color?) -> nil`: Adds a named line series from an array-style Lua table of points.
- `LLineChart:addSeriesFromDataFrame() -> nil`: Builds a named line series from x and y columns in a dataframe.
- `LLineChart:appendPoint(name, x, y, color?) -> nil`: Appends one finite point to a named line series.
- `LLineChart:clear() -> nil`: Clears the state.
- `LLineChart:draw(x, y, opts?) -> nil`: Draws the line chart at world or screen coordinates using optional transform options.
- `LLineChart:drawToImage(target) -> nil`: Draw to image.
- `LLineChart:getHeight() -> nil`: Returns the height.
- `LLineChart:getWidth() -> nil`: Returns the width.
- `LLineChart:nearest(x, y) -> nil`: Nearest.
- `LLineChart:render() -> nil`: Render.
- `LLineChart:renderImage() -> nil`: Render image.
- `LLineChart:replaceSeries(name, data, color?) -> nil`: Replaces a named line series with a new array-style Lua table of points.
- `LLineChart:setShowLegend(value) -> nil`: Sets the show legend.
- `LLineChart:setTitle(title) -> nil`: Sets the title.
- `LLineChart:setWindow(max_points?) -> nil`: Sets the window.
- `LLineChart:setXLabel(label) -> nil`: Sets the x label.
- `LLineChart:setXMax(value) -> nil`: Sets the x max.
- `LLineChart:setXTickCount(count) -> nil`: Sets the x tick count.
- `LLineChart:setYLabel(label) -> nil`: Sets the y label.
- `LLineChart:setYMax(value) -> nil`: Sets the y max.
- `LLineChart:setYTickCount(count) -> nil`: Sets the y tick count.
- `LLineChart:type() -> nil`: Type.
- `LLineChart:typeOf(name) -> nil`: Type of.

#### LPieChart Type

- Lua handle for a pie chart with labeled slices and cached draw output.

##### Fields

- No documented fields.

##### Methods

- `LPieChart:addSegment(label, value, color?) -> nil`: Adds one pie segment with a non-negative value.
- `LPieChart:addSegmentsFromDataFrame() -> nil`: Adds pie segments by reading label and value columns from a dataframe.
- `LPieChart:addSlice(label, value, color?) -> nil`: Legacy alias that adds one pie slice with a non-negative value.
- `LPieChart:clear() -> nil`: Clears the state.
- `LPieChart:draw(x, y, opts?) -> nil`: Draws the pie chart at world or screen coordinates using optional transform options.
- `LPieChart:drawToImage(target) -> nil`: Draw to image.
- `LPieChart:getHeight() -> nil`: Returns the height.
- `LPieChart:getWidth() -> nil`: Returns the width.
- `LPieChart:render() -> nil`: Render.
- `LPieChart:renderImage() -> nil`: Render image.
- `LPieChart:setShowLegend(value) -> nil`: Sets the show legend.
- `LPieChart:setTitle(title) -> nil`: Sets the title.
- `LPieChart:type() -> nil`: Type.
- `LPieChart:typeOf(name) -> nil`: Type of.

#### LScatterPlot Type

- Lua handle for a scatter plot with named point series and cached draw output.

##### Fields

- No documented fields.

##### Methods

- `LScatterPlot:addSeries(name, data, color?) -> nil`: Adds a named scatter series from an array-style Lua table of points.
- `LScatterPlot:addSeriesFromDataFrame() -> nil`: Builds a named scatter series from x and y columns in a dataframe.
- `LScatterPlot:appendPoint(name, x, y, color?) -> nil`: Appends one finite point to a named scatter series.
- `LScatterPlot:clear() -> nil`: Clears the state.
- `LScatterPlot:draw(x, y, opts?) -> nil`: Draws the scatter plot at world or screen coordinates using optional transform options.
- `LScatterPlot:drawToImage(target) -> nil`: Draw to image.
- `LScatterPlot:getHeight() -> nil`: Returns the height.
- `LScatterPlot:getWidth() -> nil`: Returns the width.
- `LScatterPlot:nearest(x, y) -> nil`: Nearest.
- `LScatterPlot:render() -> nil`: Render.
- `LScatterPlot:renderImage() -> nil`: Render image.
- `LScatterPlot:replaceSeries(name, data, color?) -> nil`: Replaces a named scatter series with a new array-style Lua table of points.
- `LScatterPlot:setDotRadius(radius) -> nil`: Sets the dot radius.
- `LScatterPlot:setShowLegend(value) -> nil`: Sets the show legend.
- `LScatterPlot:setTitle(title) -> nil`: Sets the title.
- `LScatterPlot:setWindow(max_points?) -> nil`: Sets the window.
- `LScatterPlot:setXLabel(label) -> nil`: Sets the x label.
- `LScatterPlot:setXRange(min_x, max_x) -> nil`: Sets the x range.
- `LScatterPlot:setXTickCount(count) -> nil`: Sets the x tick count.
- `LScatterPlot:setYLabel(label) -> nil`: Sets the y label.
- `LScatterPlot:setYRange(min_y, max_y) -> nil`: Sets the y range.
- `LScatterPlot:setYTickCount(count) -> nil`: Sets the y tick count.
- `LScatterPlot:type() -> nil`: Type.
- `LScatterPlot:typeOf(name) -> nil`: Type of.

## References

- `color`: Imports or references `src/color/`. Cross-group dependency from ``Feature Systems`` into `Edge/Integration`.
- `dataframe`: Imports or references `src/dataframe/`. Cross-group dependency from ``Feature Systems`` into `Foundations`.
- `image`: Imports or references `src/image/`. Cross-group dependency from ``Feature Systems`` into `Platform Services`.

## Notes

- No additional module-specific notes.
