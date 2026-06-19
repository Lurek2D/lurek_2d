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

## Imports

- `color`: Imports or references `src/color/`. Cross-group dependency from ``Feature Systems`` into `Edge/Integration`.
- `dataframe`: Imports or references `src/dataframe/`. Cross-group dependency from ``Feature Systems`` into `Foundations`.
- `image`: Imports or references `src/image/`. Cross-group dependency from ``Feature Systems`` into `Platform Services`.

## Files

### area.rs

- This file owns stacked area-chart rendering, keeping ordered series, optional y override, and streaming trim behavior.
- It accepts direct series, named layers, or dataframe columns, then converts them into cumulative filled plot regions.
- Stacking math and trapezoid fill rasterization live here because each layer depends on the prior series baseline.
- Shared helpers from `render_utils` provide axes, transforms, legends, and buffer fills, but not area composition rules.
- `draw_to_image`, `append_point`, and `set_max_points` make this file the owner for runtime chart streaming updates.
- `y_max` lives here so stacked datasets can clamp the vertical domain without changing shared range helpers.
- Open it when filled-region accumulation changes; plain polylines, bars, and scatter markers are owned by siblings.

### bar.rs

- This file owns grouped bar-chart rendering, including per-series storage, category labels, bar width, and inter-bar gap.
- It accepts direct series buffers or dataframe-derived categories, then maps each category slot into rectangle fills.
- Baseline handling for positive and negative bars lives here so column charts always anchor correctly around zero.
- Shared helpers provide buffer clearing, axes, labels, and legends, while this file owns group spacing and bar geometry.
- Category labels are stored beside the series here because annotation needs renderer-owned ordering for each group.
- Open it when bar grouping or category ingestion changes; line, area, pie, and heatmap behavior lives in siblings.

### config.rs

- This file owns chart configuration structs, margins, palettes, and dataframe import limits used by every renderer.
- `ChartConfig` defines image size, axis colors, titles, labels, grid policy, legend space, and streaming point limits.
- `ChartSeries` carries named colored `(x, y)` samples, while `ChartMargin` and defaults stabilize plot layout math.
- `ChartDataFrameOptions` keeps tabular import limits local so chart renderers share one narrow ingestion contract.
- Open this file when cross-chart option semantics change; per-chart rasterization and annotation live in sibling files.

### heatmap.rs

- This file owns heatmap rendering, including matrix dimensions, cell values, row and column labels, and color range.
- It accepts direct matrices, dataframe pivots, or single-cell updates, then stores a dense row-major value buffer.
- Value-range selection and low-to-high color interpolation live here because each cell shade depends on matrix extrema.
- Label trimming, value formatting, and optional cell text are local so matrix presentation stays coupled to cell layout.
- The renderer draws grid lines, frame borders, legends, and scale labels after filling cells into the RGBA buffer.
- `set_matrix_from_dataframe` performs pivot-style aggregation here, combining repeated row-column pairs into one cell.
- `set_show_values` and `set_color_range` make this file the owner for dashboard readability and scale semantics.
- Open it when matrix ingestion or color-mapping changes; generic cartesian annotation and shared config live elsewhere.

### histogram.rs

- This file owns histogram rendering, including named sample series, bin count, explicit x range, and density mode.
- It ingests raw numeric slices or dataframe columns, filters non-finite samples, and trims streaming windows locally.
- Bucketization lives here because each render derives bar counts from sample distribution instead of `(x, y)` pairs.
- Density normalization also lives here so histogram output can switch between absolute counts and relative frequencies.
- Shared chart helpers provide axes, labels, legends, and rectangle fills, while this file owns bin geometry decisions.
- `append_value`, `set_bin_count`, and `set_range` make this the file to edit for live telemetry distribution views.
- Open it when sample bucketing changes; heatmap matrices, pies, and cartesian line-series renderers live in siblings.

### line.rs

- This file owns polyline chart rendering, including series storage, optional axis overrides, and streaming point updates.
- It accepts direct points or dataframe columns, then maps each series into connected line segments plus point markers.
- Range selection lives here because line charts may override auto bounds before the shared transform helpers run.
- Shared raster helpers draw the axes, grid, legend, and circles, but this file owns series replacement and append flow.
- `set_max_points` trims live feeds locally so long-running chart streams stay bounded before any render pass begins.
- Open it when connected-series behavior changes; stacked fills, grouped bars, and scatter-only dots live in siblings.

### mod.rs

- This module is the charts index, wiring concrete chart renderers, shared config types, and raster helpers.
- It exports area, bar, line, pie, scatter, histogram, and heatmap owners from one navigation entry point.
- Shared option contracts live in `config.rs`, while `render_utils.rs` owns the CPU drawing primitives used by all charts.
- This file owns only module visibility and reexports, not chart state, buffers, dataframe ingestion, or render math.
- Open it when chart ownership, public names, or reexport boundaries move between sibling implementation files.
- For behavior changes, edit the renderer file that owns the chart type instead of growing coordination logic here.

### pie.rs

- This file owns pie-chart state as named slices plus configuration needed to turn proportions into filled sectors.
- It converts dataframe rows or direct segment calls into normalized angle spans and rasterizes them into RGBA buffers.
- Legend annotations are delegated to `render_utils`, while this file owns slice accumulation, totals, and arc membership.
- Empty or nonpositive values short-circuit rendering here so downstream image consumers avoid invalid sector math.
- Open it when pie segment ingestion or angular fill behavior changes; cartesian axes and shared config live elsewhere.

### render_utils.rs

- This file owns the shared CPU rasterization helpers that every chart renderer uses to draw into RGBA byte buffers.
- It implements pixel writes, Bresenham lines, filled rectangles, filled circles, and whole-buffer background clears.
- Auto-range and world-to-screen mapping live here so cartesian renderers share one default axis-domain policy.
- Annotation helpers also live here, adding titles, ticks, legends, axis labels, and category captions onto images.
- Small text-formatting and color-box helpers stay local because chart annotations depend on ImageData label drawing.
- Open it when low-level raster rules or shared chart annotation behavior changes across multiple renderer files.
- Edit the individual chart file instead when changing series storage, stacking, bucketing, or matrix-specific semantics.

### scatter.rs

- This file owns scatter-plot rendering, including series storage, marker radius, and optional explicit axis ranges.
- It accepts direct point arrays or dataframe columns, then draws each finite sample as a filled marker in plot space.
- Axis range overrides live here because scatter plots often frame sparse clouds differently from auto-derived bounds.
- Shared helpers provide grid lines, transforms, legend text, and buffer fills, while this file owns dot placement.
- `replace_series`, `append_point`, and `set_max_points` make this the owner for incremental point-cloud updates.
- Open it when marker rendering or range selection changes; polylines, stacked fills, and bar grouping live elsewhere.



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
