<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/charts.md or source docstrings instead. -->

# charts

## TL;DR

- Rasterizes line, bar, area, scatter, pie, histogram, and heatmap charts into RGBA buffers and drawable runtime textures.

## General Info

- Module group: `Feature Systems`
- Source path: `src/charts`
- Binding: `src/lua_api/charts_api.rs`
- Namespace: `lurek.charts`
- Lua API surface: `14` functions, `12` types, `215` methods
- User-facing: `true`
- Plugin tier: `tier_2_plugin`

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

## Ownership

- Canonical source: `src/charts`
- Owning tier: `Feature Systems`
- Plugin tier: `tier_2_plugin`
- Lua binding owner: `src/lua_api/charts_api.rs`
- Referenced engine modules: `color`, `dataframe`, `image`

## Imports

- `color`: Imports or references `src/color/`. Cross-group dependency from `Feature Systems` into `Foundations`.
- `dataframe`: Imports or references `src/dataframe/`. Cross-group dependency from `Feature Systems` into `Foundations`.
- `image`: Imports or references `src/image/`. Cross-group dependency from `Feature Systems` into `Platform Services`.

## Source Files

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

### boxplot.rs

- This file owns box-and-whisker chart rendering for distributions, benchmark runs, and telemetry spreads.
- It stores named sample series, computes quartiles on render, and draws whiskers, boxes, medians, and outliers.
- Shared chart helpers provide axes, ticks, category labels, legends, and background styling for consistency.
- The renderer sorts only per-series samples and otherwise draws O(series + samples) primitives for fast refreshes.
- The output is CPU `ImageData`, so chart statistics stay here while render modules only consume prepared pixels.
- Open it when distribution statistics, outlier policy, boxplot geometry, or sample limits need to change.

### bubble.rs

- This file owns bubble chart rendering for weighted point clouds, portfolio maps, and correlation dashboards.
- It stores named `(x, y, size)` samples, maps size values to radius bounds, and draws one circle per finite sample.
- Shared chart helpers provide cartesian axes, ticks, grids, labels, and legends while this file owns radius scaling.
- Streaming append and max-point trimming keep live dashboards bounded for repeated 10 FPS redraws.
- The output is CPU `ImageData`, so render modules consume pixels without owning weighted scatter semantics.
- Open it when bubble-size semantics, weighted scatter ingestion, or radius defaults need to change.

### candlestick.rs

- This file owns candlestick chart rendering for OHLC financial or telemetry interval data streams.
- It stores labeled candles, supports incremental appends, and draws wicks plus open-close bodies in one CPU pass.
- Axis scaling is derived from high/low values, while shared chart helpers provide grid, ticks, title, and captions.
- Positive and negative candles use configurable colors so streaming market views remain readable at 10 FPS.
- The output is `ImageData`, keeping market-style chart semantics separate from render submission ownership.
- Open it when OHLC ingestion, candle body geometry, or finance-style chart semantics need to change.

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
- It exports area, bar, line, pie, scatter, histogram, heatmap, candlestick, boxplot, bubble, radar, and treemap owners.
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

### radar.rs

- This file owns radar/spider chart rendering for multivariate series over shared axes and dashboards.
- It stores ordered axis labels and named series values, then draws radial grid rings and closed polygons.
- The chart can use an explicit maximum value or auto-scale from finite series samples for stable output.
- Rendering is O(axes * series) and avoids per-pixel polygon fills so live dashboards can refresh quickly.
- Shared chart configuration owns common colors and labels while this file owns radial geometry semantics.
- Open it when radar axis semantics, scaling, polygon stroke behavior, or series limits need to change.

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

### treemap.rs

- This file owns treemap chart rendering for part-to-whole dashboards and hierarchical-looking flat summaries.
- It stores weighted labeled items, applies deterministic squarified rows, and draws colored rectangles with labels.
- The API accepts flat items because runtime Lua callers commonly aggregate hierarchy before visualization.
- Rendering is O(n log n) from value sorting plus rectangle fills, keeping repeated refreshes practical.
- Shared chart configuration provides title, legend, and background while this file owns rectangle packing.
- The output is CPU `ImageData`, so render modules consume pixels instead of owning treemap layout semantics.
- Open it when treemap item ingestion, squarified row packing, or label rendering need to change.



## Lua API Ref

### Functions

- `lurek.charts.defaultPalette() -> table`: Returns the default chart color palette.
- `lurek.charts.newArea(config?) -> LAreaChart`: Creates a new area chart userdata instance.
- `lurek.charts.newBar(config?) -> LBarChart`: Creates a new bar chart userdata instance.
- `lurek.charts.newBoxPlot(config?) -> LBoxPlotChart`: Creates a new boxplot chart userdata instance.
- `lurek.charts.newBubble(config?) -> LBubbleChart`: Creates a new bubble chart userdata instance.
- `lurek.charts.newCandlestick(config?) -> LCandlestickChart`: Creates a new candlestick chart userdata instance.
- `lurek.charts.newHeatmap(config?) -> LHeatmapChart`: Creates a new heatmap chart userdata instance.
- `lurek.charts.newHistogram(config?) -> LHistogramChart`: Creates a new histogram chart userdata instance.
- `lurek.charts.newLine(config?) -> LLineChart`: Creates a new line chart userdata instance.
- `lurek.charts.newPie(config?) -> LPieChart`: Creates a new pie chart userdata instance.
- `lurek.charts.newRadar(config?) -> LRadarChart`: Creates a new radar chart userdata instance.
- `lurek.charts.newScatter(config?) -> LScatterPlot`: Creates a new scatter plot userdata instance.
- `lurek.charts.newTreemap(config?) -> LTreemapChart`: Creates a new treemap chart userdata instance.
- `lurek.charts.seriesColor(index) -> table`: Returns the palette color for a series index.

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
- `LAreaChart:addLayerFromDataFrame(name, df, value_col, color?, opts?) -> nil`: Builds one filled area layer from a dataframe value column.
- `LAreaChart:addSeries(name, data, color?) -> nil`: Adds a named area series from an array-style Lua table of points.
- `LAreaChart:appendPoint(name, x, y, color?) -> nil`: Appends one finite point to a named area series.
- `LAreaChart:clear() -> nil`: Clears all series and cached chart state.
- `LAreaChart:draw(x, y, opts?) -> nil`: Draws the area chart at world or screen coordinates using optional transform options.
- `LAreaChart:drawToImage(target) -> nil`: Draws the rendered chart into an existing image.
- `LAreaChart:getHeight() -> integer`: Returns the configured chart height in pixels.
- `LAreaChart:getWidth() -> integer`: Returns the configured chart width in pixels.
- `LAreaChart:render() -> integer, integer, string`: Renders the chart into raw RGBA image bytes.
- `LAreaChart:renderImage() -> nil`: Renders the chart into a new LImage userdata.
- `LAreaChart:setShowLegend(value) -> nil`: Controls whether the chart legend is rendered.
- `LAreaChart:setTitle(title) -> nil`: Sets the chart title text shown in rendered output.
- `LAreaChart:setWindow(max_points?) -> nil`: Sets the maximum retained sample window for this chart.
- `LAreaChart:setXLabel(label) -> nil`: Sets the X axis label text for rendered output.
- `LAreaChart:setXTickCount(count) -> nil`: Sets the number of X axis ticks drawn for this chart.
- `LAreaChart:setYLabel(label) -> nil`: Sets the Y axis label text for rendered output.
- `LAreaChart:setYMax(value) -> nil`: Sets the explicit Y axis maximum for chart scaling.
- `LAreaChart:setYTickCount(count) -> nil`: Sets the number of Y axis ticks drawn for this chart.
- `LAreaChart:type() -> string`: Returns the runtime userdata type name for this chart.
- `LAreaChart:typeOf(name) -> boolean`: Checks whether a type name matches this chart userdata.

#### LBarChart Type

- Lua handle for a grouped bar chart with named series and category labels.

##### Fields

- No documented fields.

##### Methods

- `LBarChart:addCategoriesFromDataFrame(df, label_col, value_cols, opts?) -> nil`: Adds grouped bar categories by reading one label column and one or more value columns from a dataframe.
- `LBarChart:addCategory(label, values) -> nil`: Adds one category label with a numeric value list for grouped bars.
- `LBarChart:addSeries(name, data, color?) -> nil`: Adds a named bar series from an array-style Lua table of values or points.
- `LBarChart:clear() -> nil`: Clears all series and cached chart state.
- `LBarChart:draw(x, y, opts?) -> nil`: Draws the bar chart at world or screen coordinates using optional transform options.
- `LBarChart:drawToImage(target) -> nil`: Draws the rendered chart into an existing image.
- `LBarChart:getHeight() -> integer`: Returns the configured chart height in pixels.
- `LBarChart:getWidth() -> integer`: Returns the configured chart width in pixels.
- `LBarChart:render() -> integer, integer, string`: Renders the chart into raw RGBA image bytes.
- `LBarChart:renderImage() -> nil`: Renders the chart into a new LImage userdata.
- `LBarChart:setBarWidth(width) -> nil`: Sets the rendered width used for each bar.
- `LBarChart:setShowLegend(value) -> nil`: Controls whether the chart legend is rendered.
- `LBarChart:setTitle(title) -> nil`: Sets the chart title text shown in rendered output.
- `LBarChart:setXLabel(label) -> nil`: Sets the X axis label text for rendered output.
- `LBarChart:setXTickCount(count) -> nil`: Sets the number of X axis ticks drawn for this chart.
- `LBarChart:setYLabel(label) -> nil`: Sets the Y axis label text for rendered output.
- `LBarChart:setYTickCount(count) -> nil`: Sets the number of Y axis ticks drawn for this chart.
- `LBarChart:type() -> string`: Returns the runtime userdata type name for this chart.
- `LBarChart:typeOf(name) -> boolean`: Checks whether a type name matches this chart userdata.

#### LBoxPlotChart Type

- Lua handle for a box-and-whisker chart.

##### Fields

- No documented fields.

##### Methods

- `LBoxPlotChart:addSeries(name, values, color?) -> nil`: Adds or replaces a named distribution sample series.
- `LBoxPlotChart:appendValue(name, value, color?) -> nil`: Appends one numeric sample to a named distribution.
- `LBoxPlotChart:clear() -> nil`: Clears all chart data and cached chart state.
- `LBoxPlotChart:draw(x, y, opts?) -> nil`: Draws the chart at world or screen coordinates using optional transform options.
- `LBoxPlotChart:drawToImage(target) -> nil`: Draws the rendered chart into an existing image.
- `LBoxPlotChart:getHeight() -> integer`: Returns the configured chart height in pixels.
- `LBoxPlotChart:getWidth() -> integer`: Returns the configured chart width in pixels.
- `LBoxPlotChart:render() -> integer, integer, string`: Renders the chart into raw RGBA image bytes.
- `LBoxPlotChart:renderImage() -> nil`: Renders the chart into a new LImage userdata.
- `LBoxPlotChart:setShowLegend(value) -> nil`: Controls whether the chart legend is rendered.
- `LBoxPlotChart:setTitle(title) -> nil`: Sets the chart title text shown in rendered output.
- `LBoxPlotChart:type() -> string`: Returns the runtime userdata type name for this chart.
- `LBoxPlotChart:typeOf(name) -> boolean`: Checks whether a type name matches this chart userdata.

#### LBubbleChart Type

- Lua handle for a weighted bubble chart.

##### Fields

- No documented fields.

##### Methods

- `LBubbleChart:addSeries(name, data, color?) -> nil`: Adds or replaces a weighted point series from `{x, y, size}` rows.
- `LBubbleChart:appendPoint(name, x, y, size, color?) -> nil`: Appends one weighted point to a named bubble series.
- `LBubbleChart:clear() -> nil`: Clears all chart data and cached chart state.
- `LBubbleChart:draw(x, y, opts?) -> nil`: Draws the chart at world or screen coordinates using optional transform options.
- `LBubbleChart:drawToImage(target) -> nil`: Draws the rendered chart into an existing image.
- `LBubbleChart:getHeight() -> integer`: Returns the configured chart height in pixels.
- `LBubbleChart:getWidth() -> integer`: Returns the configured chart width in pixels.
- `LBubbleChart:render() -> integer, integer, string`: Renders the chart into raw RGBA image bytes.
- `LBubbleChart:renderImage() -> nil`: Renders the chart into a new LImage userdata.
- `LBubbleChart:setRadiusRange(min, max) -> nil`: Sets the minimum and maximum bubble radius in pixels.
- `LBubbleChart:setShowLegend(value) -> nil`: Controls whether the chart legend is rendered.
- `LBubbleChart:setTitle(title) -> nil`: Sets the chart title text shown in rendered output.
- `LBubbleChart:type() -> string`: Returns the runtime userdata type name for this chart.
- `LBubbleChart:typeOf(name) -> boolean`: Checks whether a type name matches this chart userdata.

#### LCandlestickChart Type

- Lua handle for an OHLC candlestick chart.

##### Fields

- No documented fields.

##### Methods

- `LCandlestickChart:appendCandle(label, open, high, low, close) -> nil`: Appends one labeled OHLC candle to the end of the current candlestick stream.
- `LCandlestickChart:clear() -> nil`: Clears all chart data and cached chart state.
- `LCandlestickChart:draw(x, y, opts?) -> nil`: Draws the chart at world or screen coordinates using optional transform options.
- `LCandlestickChart:drawToImage(target) -> nil`: Draws the rendered chart into an existing image.
- `LCandlestickChart:getHeight() -> integer`: Returns the configured chart height in pixels.
- `LCandlestickChart:getWidth() -> integer`: Returns the configured chart width in pixels.
- `LCandlestickChart:render() -> integer, integer, string`: Renders the chart into raw RGBA image bytes.
- `LCandlestickChart:renderImage() -> nil`: Renders the chart into a new LImage userdata.
- `LCandlestickChart:setCandles(candles) -> nil`: Replaces all OHLC candles from table rows with open/high/low/close fields or values 1..4.
- `LCandlestickChart:setColors(up, down) -> nil`: Sets the rising and falling candle colors used by the candlestick renderer.
- `LCandlestickChart:setShowLegend(value) -> nil`: Controls whether the chart legend is rendered.
- `LCandlestickChart:setTitle(title) -> nil`: Sets the chart title text shown in rendered output.
- `LCandlestickChart:type() -> string`: Returns the runtime userdata type name for this chart.
- `LCandlestickChart:typeOf(name) -> boolean`: Checks whether a type name matches this chart userdata.

#### LHeatmapChart Type

- Lua handle for a heatmap chart backed by a numeric matrix.

##### Fields

- No documented fields.

##### Methods

- `LHeatmapChart:clear() -> nil`: Clears all series and cached chart state.
- `LHeatmapChart:clearValueRange() -> nil`: Clears the explicit heatmap value range.
- `LHeatmapChart:draw(x, y, opts?) -> nil`: Draws the heatmap at world or screen coordinates using optional transform options.
- `LHeatmapChart:drawToImage(target) -> nil`: Draws the rendered chart into an existing image.
- `LHeatmapChart:getHeight() -> integer`: Returns the configured chart height in pixels.
- `LHeatmapChart:getWidth() -> integer`: Returns the configured chart width in pixels.
- `LHeatmapChart:render() -> integer, integer, string`: Renders the chart into raw RGBA image bytes.
- `LHeatmapChart:renderImage() -> nil`: Renders the chart into a new LImage userdata.
- `LHeatmapChart:resize(rows, cols) -> nil`: Resizes the heatmap grid dimensions.
- `LHeatmapChart:setCell(row, col, value) -> nil`: Sets a numeric heatmap cell value by row and column.
- `LHeatmapChart:setColorRange(low, high) -> nil`: Sets the low and high RGBA colors used for the heatmap gradient.
- `LHeatmapChart:setColumnLabels(labels) -> nil`: Sets labels displayed for heatmap columns.
- `LHeatmapChart:setMatrix(matrix, row_labels?, col_labels?) -> nil`: Replaces the heatmap contents from a numeric matrix with optional row and column labels.
- `LHeatmapChart:setMatrixFromDataFrame(df, row_col, col_col, value_col, opts?) -> nil`: Builds the heatmap contents from dataframe row, column, and value fields.
- `LHeatmapChart:setRowLabels(labels) -> nil`: Sets labels displayed for heatmap rows.
- `LHeatmapChart:setShowLegend(value) -> nil`: Controls whether the chart legend is rendered.
- `LHeatmapChart:setShowValues(value) -> nil`: Controls whether heatmap cell values are rendered.
- `LHeatmapChart:setTitle(title) -> nil`: Sets the chart title text shown in rendered output.
- `LHeatmapChart:setValueRange(min, max) -> nil`: Sets the explicit heatmap value range.
- `LHeatmapChart:type() -> string`: Returns the runtime userdata type name for this chart.
- `LHeatmapChart:typeOf(name) -> boolean`: Checks whether a type name matches this chart userdata.

#### LHistogramChart Type

- Lua handle for a histogram chart that bins named numeric samples.

##### Fields

- No documented fields.

##### Methods

- `LHistogramChart:addSeries(name, data, color?) -> nil`: Adds a named histogram sample series from a numeric value list.
- `LHistogramChart:addSeriesFromDataFrame(name, df, x_col, y_col, color?, opts?) -> nil`: Builds a named histogram sample series from one dataframe value column.
- `LHistogramChart:appendValue(name, value, color?) -> nil`: Appends one finite numeric sample to a named histogram series.
- `LHistogramChart:clear() -> nil`: Clears all series and cached chart state.
- `LHistogramChart:clearRange() -> nil`: Clears the explicit histogram value range.
- `LHistogramChart:draw(x, y, opts?) -> nil`: Draws the histogram at world or screen coordinates using optional transform options.
- `LHistogramChart:drawToImage(target) -> nil`: Draws the rendered chart into an existing image.
- `LHistogramChart:getHeight() -> integer`: Returns the configured chart height in pixels.
- `LHistogramChart:getWidth() -> integer`: Returns the configured chart width in pixels.
- `LHistogramChart:render() -> integer, integer, string`: Renders the chart into raw RGBA image bytes.
- `LHistogramChart:renderImage() -> nil`: Renders the chart into a new LImage userdata.
- `LHistogramChart:replaceSeries(name, data, color?) -> nil`: Replaces a named histogram sample series with a new numeric value list.
- `LHistogramChart:setBinCount(bins) -> nil`: Sets the number of histogram bins used for samples.
- `LHistogramChart:setDensity(enabled) -> nil`: Controls whether histogram bins render as density values.
- `LHistogramChart:setRange(min, max) -> nil`: Sets the explicit histogram value range.
- `LHistogramChart:setShowLegend(value) -> nil`: Controls whether the chart legend is rendered.
- `LHistogramChart:setTitle(title) -> nil`: Sets the chart title text shown in rendered output.
- `LHistogramChart:setWindow(max_points?) -> nil`: Sets the maximum retained sample window for this chart.
- `LHistogramChart:setXLabel(label) -> nil`: Sets the X axis label text for rendered output.
- `LHistogramChart:setXTickCount(count) -> nil`: Sets the number of X axis ticks drawn for this chart.
- `LHistogramChart:setYLabel(label) -> nil`: Sets the Y axis label text for rendered output.
- `LHistogramChart:setYTickCount(count) -> nil`: Sets the number of Y axis ticks drawn for this chart.
- `LHistogramChart:type() -> string`: Returns the runtime userdata type name for this chart.
- `LHistogramChart:typeOf(name) -> boolean`: Checks whether a type name matches this chart userdata.

#### LLineChart Type

- Lua handle for a line chart with named x/y series and cached draw output.

##### Fields

- No documented fields.

##### Methods

- `LLineChart:addSeries(name, data, color?) -> nil`: Adds a named line series from an array-style Lua table of points.
- `LLineChart:addSeriesFromDataFrame(name, df, x_col, y_col, color?, opts?) -> nil`: Builds a named line series from x and y columns in a dataframe.
- `LLineChart:appendPoint(name, x, y, color?) -> nil`: Appends one finite point to a named line series.
- `LLineChart:clear() -> nil`: Clears all series and cached chart state.
- `LLineChart:draw(x, y, opts?) -> nil`: Draws the line chart at world or screen coordinates using optional transform options.
- `LLineChart:drawToImage(target) -> nil`: Draws the rendered chart into an existing image.
- `LLineChart:getHeight() -> integer`: Returns the configured chart height in pixels.
- `LLineChart:getWidth() -> integer`: Returns the configured chart width in pixels.
- `LLineChart:nearest(x, y) -> table`: Finds the nearest plotted point to screen coordinates.
- `LLineChart:render() -> integer, integer, string`: Renders the chart into raw RGBA image bytes.
- `LLineChart:renderImage() -> nil`: Renders the chart into a new LImage userdata.
- `LLineChart:replaceSeries(name, data, color?) -> nil`: Replaces a named line series with a new array-style Lua table of points.
- `LLineChart:setShowLegend(value) -> nil`: Controls whether the chart legend is rendered.
- `LLineChart:setTitle(title) -> nil`: Sets the chart title text shown in rendered output.
- `LLineChart:setWindow(max_points?) -> nil`: Sets the maximum retained sample window for this chart.
- `LLineChart:setXLabel(label) -> nil`: Sets the X axis label text for rendered output.
- `LLineChart:setXMax(value) -> nil`: Sets the explicit X axis maximum for chart scaling.
- `LLineChart:setXTickCount(count) -> nil`: Sets the number of X axis ticks drawn for this chart.
- `LLineChart:setYLabel(label) -> nil`: Sets the Y axis label text for rendered output.
- `LLineChart:setYMax(value) -> nil`: Sets the explicit Y axis maximum for chart scaling.
- `LLineChart:setYTickCount(count) -> nil`: Sets the number of Y axis ticks drawn for this chart.
- `LLineChart:type() -> string`: Returns the runtime userdata type name for this chart.
- `LLineChart:typeOf(name) -> boolean`: Checks whether a type name matches this chart userdata.

#### LPieChart Type

- Lua handle for a pie chart with labeled slices and cached draw output.

##### Fields

- No documented fields.

##### Methods

- `LPieChart:addSegment(label, value, color?) -> nil`: Adds one pie segment with a non-negative value.
- `LPieChart:addSegmentsFromDataFrame(df, label_col, value_col, opts?) -> nil`: Adds pie segments by reading label and value columns from a dataframe.
- `LPieChart:addSlice(label, value, color?) -> nil`: Legacy alias that adds one pie slice with a non-negative value.
- `LPieChart:clear() -> nil`: Clears all series and cached chart state.
- `LPieChart:draw(x, y, opts?) -> nil`: Draws the pie chart at world or screen coordinates using optional transform options.
- `LPieChart:drawToImage(target) -> nil`: Draws the rendered chart into an existing image.
- `LPieChart:getHeight() -> integer`: Returns the configured chart height in pixels.
- `LPieChart:getWidth() -> integer`: Returns the configured chart width in pixels.
- `LPieChart:render() -> integer, integer, string`: Renders the chart into raw RGBA image bytes.
- `LPieChart:renderImage() -> nil`: Renders the chart into a new LImage userdata.
- `LPieChart:setShowLegend(value) -> nil`: Controls whether the chart legend is rendered.
- `LPieChart:setTitle(title) -> nil`: Sets the chart title text shown in rendered output.
- `LPieChart:type() -> string`: Returns the runtime userdata type name for this chart.
- `LPieChart:typeOf(name) -> boolean`: Checks whether a type name matches this chart userdata.

#### LRadarChart Type

- Lua handle for a radar/spider chart.

##### Fields

- No documented fields.

##### Methods

- `LRadarChart:addSeries(name, values, color?) -> nil`: Adds or replaces a named radar series.
- `LRadarChart:clear() -> nil`: Clears all chart data and cached chart state.
- `LRadarChart:clearMaxValue() -> nil`: Clears the explicit maximum radial value.
- `LRadarChart:draw(x, y, opts?) -> nil`: Draws the chart at world or screen coordinates using optional transform options.
- `LRadarChart:drawToImage(target) -> nil`: Draws the rendered chart into an existing image.
- `LRadarChart:getHeight() -> integer`: Returns the configured chart height in pixels.
- `LRadarChart:getWidth() -> integer`: Returns the configured chart width in pixels.
- `LRadarChart:render() -> integer, integer, string`: Renders the chart into raw RGBA image bytes.
- `LRadarChart:renderImage() -> nil`: Renders the chart into a new LImage userdata.
- `LRadarChart:setAxes(axes) -> nil`: Replaces the radar axis labels used for each radial spoke.
- `LRadarChart:setMaxValue(value) -> nil`: Sets the explicit maximum radial value.
- `LRadarChart:setShowLegend(value) -> nil`: Controls whether the chart legend is rendered.
- `LRadarChart:setTitle(title) -> nil`: Sets the chart title text shown in rendered output.
- `LRadarChart:type() -> string`: Returns the runtime userdata type name for this chart.
- `LRadarChart:typeOf(name) -> boolean`: Checks whether a type name matches this chart userdata.

#### LScatterPlot Type

- Lua handle for a scatter plot with named point series and cached draw output.

##### Fields

- No documented fields.

##### Methods

- `LScatterPlot:addSeries(name, data, color?) -> nil`: Adds a named scatter series from an array-style Lua table of points.
- `LScatterPlot:addSeriesFromDataFrame(name, df, x_col, y_col, color?, opts?) -> nil`: Builds a named scatter series from x and y columns in a dataframe.
- `LScatterPlot:appendPoint(name, x, y, color?) -> nil`: Appends one finite point to a named scatter series.
- `LScatterPlot:clear() -> nil`: Clears all series and cached chart state.
- `LScatterPlot:draw(x, y, opts?) -> nil`: Draws the scatter plot at world or screen coordinates using optional transform options.
- `LScatterPlot:drawToImage(target) -> nil`: Draws the rendered chart into an existing image.
- `LScatterPlot:getHeight() -> integer`: Returns the configured chart height in pixels.
- `LScatterPlot:getWidth() -> integer`: Returns the configured chart width in pixels.
- `LScatterPlot:nearest(x, y) -> table`: Finds the nearest plotted point to screen coordinates.
- `LScatterPlot:render() -> integer, integer, string`: Renders the chart into raw RGBA image bytes.
- `LScatterPlot:renderImage() -> nil`: Renders the chart into a new LImage userdata.
- `LScatterPlot:replaceSeries(name, data, color?) -> nil`: Replaces a named scatter series with a new array-style Lua table of points.
- `LScatterPlot:setDotRadius(radius) -> nil`: Sets the rendered radius used for scatter dots.
- `LScatterPlot:setShowLegend(value) -> nil`: Controls whether the chart legend is rendered.
- `LScatterPlot:setTitle(title) -> nil`: Sets the chart title text shown in rendered output.
- `LScatterPlot:setWindow(max_points?) -> nil`: Sets the maximum retained sample window for this chart.
- `LScatterPlot:setXLabel(label) -> nil`: Sets the X axis label text for rendered output.
- `LScatterPlot:setXRange(min_x, max_x) -> nil`: Sets the explicit X axis range for plotted points.
- `LScatterPlot:setXTickCount(count) -> nil`: Sets the number of X axis ticks drawn for this chart.
- `LScatterPlot:setYLabel(label) -> nil`: Sets the Y axis label text for rendered output.
- `LScatterPlot:setYRange(min_y, max_y) -> nil`: Sets the explicit Y axis range for plotted points.
- `LScatterPlot:setYTickCount(count) -> nil`: Sets the number of Y axis ticks drawn for this chart.
- `LScatterPlot:type() -> string`: Returns the runtime userdata type name for this chart.
- `LScatterPlot:typeOf(name) -> boolean`: Checks whether a type name matches this chart userdata.

#### LTreemapChart Type

- Lua handle for a treemap chart that renders weighted hierarchical rectangles.

##### Fields

- No documented fields.

##### Methods

- `LTreemapChart:addItem(label, value, color?) -> nil`: Adds one weighted treemap item to the current rectangle layout.
- `LTreemapChart:clear() -> nil`: Clears all chart data and cached chart state.
- `LTreemapChart:draw(x, y, opts?) -> nil`: Draws the chart at world or screen coordinates using optional transform options.
- `LTreemapChart:drawToImage(target) -> nil`: Draws the rendered chart into an existing image.
- `LTreemapChart:getHeight() -> integer`: Returns the configured chart height in pixels.
- `LTreemapChart:getWidth() -> integer`: Returns the configured chart width in pixels.
- `LTreemapChart:render() -> integer, integer, string`: Renders the chart into raw RGBA image bytes.
- `LTreemapChart:renderImage() -> nil`: Renders the chart into a new LImage userdata.
- `LTreemapChart:setItems(items) -> nil`: Replaces weighted treemap items from label/value rows or fields.
- `LTreemapChart:setShowLegend(value) -> nil`: Controls whether the chart legend is rendered.
- `LTreemapChart:setTitle(title) -> nil`: Sets the chart title text shown in rendered output.
- `LTreemapChart:type() -> string`: Returns the runtime userdata type name for this chart.
- `LTreemapChart:typeOf(name) -> boolean`: Checks whether a type name matches this chart userdata.

## Examples

- `content/examples/charts.lua` (present)

## Tests

- Lua unit: `tests/lua/unit/test_charts_unit.lua` (present)
- Rust: none detected.

## Evidence / Golden

| Kind | Path |
|---|---|
| Evidence test | `tests/lua/evidence/test_charts_evidence.lua` |
| Golden test | `tests/lua/golden/test_charts_golden.lua` |
| Current artifact | `tests/artifacts/current/charts/charts_area_layered_usage.png` |
| Current artifact | `tests/artifacts/current/charts/charts_bar_category_revenue.png` |
| Current artifact | `tests/artifacts/current/charts/charts_boxplot_latency_spread.png` |
| Current artifact | `tests/artifacts/current/charts/charts_bubble_market_risk.png` |
| Current artifact | `tests/artifacts/current/charts/charts_candlestick_volatile_ohlc.png` |
| Current artifact | `tests/artifacts/current/charts/charts_dataframe_heatmap.png` |
| Current artifact | `tests/artifacts/current/charts/charts_dataframe_histogram.png` |
| Current artifact | `tests/artifacts/current/charts/charts_dataframe_line.png` |
| Current artifact | `tests/artifacts/current/charts/charts_dataframe_pie.png` |
| Current artifact | `tests/artifacts/current/charts/charts_heatmap_region_load.png` |
| Current artifact | `tests/artifacts/current/charts/charts_histogram_latency_distribution.png` |
| Current artifact | `tests/artifacts/current/charts/charts_line_revenue_trend.png` |
| Current artifact | `tests/artifacts/current/charts/charts_nearest_trace.json` |
| Current artifact | `tests/artifacts/current/charts/charts_pie_market_share.png` |
| Current artifact | `tests/artifacts/current/charts/charts_radar_unit_comparison.png` |
| Current artifact | `tests/artifacts/current/charts/charts_scatter_player_scores.png` |
| Current artifact | `tests/artifacts/current/charts/charts_treemap_budget_breakdown.png` |
| Baseline artifact | `tests/artifacts/baselines/charts/charts_area_layered_usage.png` |
| Baseline artifact | `tests/artifacts/baselines/charts/charts_bar_category_revenue.png` |
| Baseline artifact | `tests/artifacts/baselines/charts/charts_dataframe_heatmap.png` |
| Baseline artifact | `tests/artifacts/baselines/charts/charts_dataframe_histogram.png` |
| Baseline artifact | `tests/artifacts/baselines/charts/charts_dataframe_line.png` |
| Baseline artifact | `tests/artifacts/baselines/charts/charts_dataframe_pie.png` |
| Baseline artifact | `tests/artifacts/baselines/charts/charts_heatmap_region_load.png` |
| Baseline artifact | `tests/artifacts/baselines/charts/charts_histogram_latency_distribution.png` |
| Baseline artifact | `tests/artifacts/baselines/charts/charts_line_revenue_trend.png` |
| Baseline artifact | `tests/artifacts/baselines/charts/charts_nearest_trace.json` |
| Baseline artifact | `tests/artifacts/baselines/charts/charts_pie_market_share.png` |
| Baseline artifact | `tests/artifacts/baselines/charts/charts_scatter_player_scores.png` |

## Architecture Links

- Intentionally empty.

## Notes

- No additional module-specific notes.
