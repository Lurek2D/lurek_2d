//! Defines the charts module boundary for CPU-rasterized data-visualization rendering. `charts/mod` is the charts module index, declaring `area`, `bar`, `config`, `heatmap`, `histogram`, and 4 more so agents can identify which files own each feature slice before opening implementation code.
//! Groups chart types, shared config contracts, and utility drawing primitives into one surface. `src/charts/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `area::AreaChart`, `bar::BarChart`, `config::{ChartConfig, ChartDataFrameOptions, ChartMargin, ChartSeries}`, `heatmap::HeatmapChart`, and 4 more centralized for the charts subsystem.
//! Serves as the composition entry for runtime chart image generation from raw series or DataFrames. The file documents how charts submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.
//! `charts/mod` is the charts module index, declaring `area`, `bar`, `config`, `heatmap`, `histogram`, and 4 more so agents can identify which files own each feature slice before opening implementation code.
//! `src/charts/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `area::AreaChart`, `bar::BarChart`, `config::{ChartConfig, ChartDataFrameOptions, ChartMargin, ChartSeries}`, `heatmap::HeatmapChart`, and 4 more centralized for the charts subsystem.
//! The file documents how charts submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.

/// Area chart: filled regions below line series for cumulative value display.
pub mod area;
/// Bar chart: displays grouped or stacked vertical bars for category comparison.
pub mod bar;
/// Chart configuration and shared types.
pub mod config;
/// Heatmap chart: renders matrix data using a color ramp for dense dashboard and ML views.
pub mod heatmap;
/// Histogram chart: renders bucketed value distributions for telemetry and analytics.
pub mod histogram;
/// Line chart: plots data series as connected lines over time or categories.
pub mod line;
/// Pie chart: renders proportional slice segments from a single data series.
pub mod pie;
/// Shared rasterization utilities.
pub mod render_utils;
/// Scatter plot: renders (x, y) point series to show distribution and correlation.
pub mod scatter;

pub use area::AreaChart;
pub use bar::BarChart;
pub use config::{ChartConfig, ChartDataFrameOptions, ChartMargin, ChartSeries};
pub use heatmap::HeatmapChart;
pub use histogram::HistogramChart;
pub use line::LineChart;
pub use pie::PieChart;
pub use scatter::ScatterPlot;
