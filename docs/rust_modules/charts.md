# charts

## General Info

- Module group: `Feature Systems`
- Source path: `src/charts/`
- Binding: `src/lua_api/charts_api.rs`
- Namespace: `lurek.charts`
- Lua API surface: `7` functions, `5` types, `32` methods
- Rust test path(s): tests/rust/unit/charts_tests.rs
- Lua test path(s): tests/lua/unit/test_charts_core_unit.lua

## Summary

The charts module provides a CPU-rasterized data-visualization rendering engine for Lurek2D. Its functional purpose is to generate static chart images directly from raw data series, Lua tables, or column-driven tabular DataFrames. This enables the creation of debug telemetry panels, player statistics HUDs, and diagnostic data overlays at runtime without external dependencies.

The rasterization engine supports several standard chart formats: line charts for continuous trends, vertical or horizontal bar charts for categorical comparisons, stacked area charts for compositional trends, scatter plots for sample distributions, and proportional pie charts with optional donut-hole ring designs. It translates numerical data arrays into 32-bit RGBA pixel buffers, managing coordinate transformations, automatic axis domain estimation, title margins, and multi-color palette mappings.

## Files

### [area.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/charts/area.rs)

- Implements area-chart rasterization where series are rendered as filled regions over plot space.
- Supports overlapping and stacked accumulation modes for comparative and compositional data views.
- Maps data coordinates into pixel coordinates through shared chart-space transform helpers.
- Produces RGBA buffers that downstream systems upload as textures for runtime presentation.
- Integrates optional DataFrame extraction paths for column-driven area plotting workflows.
- Serves as the filled-series rendering backend behind the charts area API surface.

### [bar.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/charts/bar.rs)

- Implements bar-chart rasterization for categorical comparison through grouped or stacked layouts.
- Supports configurable bar width, spacing, and orientation behavior across multiple value series.
- Converts scaled chart coordinates into pixel-aligned rectangle fills for each rendered segment.
- Produces RGBA image buffers suitable for per-frame upload and display in runtime overlays.
- Serves as the rectangular-series rendering backend for the charts bar API path.

### [config.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/charts/config.rs)

- Defines shared chart configuration contracts used across all chart rendering variants.
- Stores dimensions, margins, titles, palette defaults, and optional legend or axis metadata.
- Provides common series and DataFrame mapping structures consumed by concrete chart specs.
- Serves as the canonical option layer for consistent chart behavior and appearance.

### [line.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/charts/line.rs)

- Implements line-chart rasterization for connected series over categorical or continuous domains.
- Supports multi-series rendering with configurable color, width, and optional point markers.
- Maps value space into pixel coordinates through shared chart transformation utilities.
- Produces RGBA output buffers that can be uploaded as frame-local chart textures.
- Serves as the polyline rendering backend exposed through the charts line API.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/charts/mod.rs)

- Defines the charts module boundary for CPU-rasterized data-visualization rendering.
- Groups chart types, shared config contracts, and utility drawing primitives into one surface.
- Serves as the composition entry for runtime chart image generation from raw series or DataFrames.

### [pie.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/charts/pie.rs)

- Implements pie-style chart rasterization where values are mapped to proportional angular slices.
- Computes normalized slice spans and renders arc-filled sectors into RGBA output buffers.
- Supports optional donut-hole shaping and label metadata for ring-style visual presentation.
- Integrates DataFrame-derived value extraction for tabular-to-pie plotting workflows.
- Serves as the circular-segment rendering backend behind the charts pie API.

### [render_utils.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/charts/render_utils.rs)

- Provides shared CPU rasterization helpers used by all chart renderer implementations.
- Includes primitive pixel operations for points, lines, circles, rectangles, and full-buffer fills.
- Converts chart data coordinates to screen-space pixels through normalized range mapping utilities.
- Computes automatic value ranges across multiple series for default axis domain selection.
- Serves as the low-level drawing toolkit for consistent chart image generation behavior.

### [scatter.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/charts/scatter.rs)

- Implements scatter-plot rasterization for point-cloud visualization of value distribution and relation.
- Draws each sample as a configurable filled marker over chart-space transformed coordinates.
- Supports automatic domain estimation or explicit axis bounds for controlled plot framing.
- Produces RGBA output buffers suitable for texture upload in runtime chart presentation.
- Serves as the point-series rendering backend for the charts scatter API path.
