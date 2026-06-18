//! This module is the charts index, wiring concrete chart renderers, shared config types, and raster helpers.
//! It exports area, bar, line, pie, scatter, histogram, and heatmap owners from one navigation entry point.
//! Shared option contracts live in `config.rs`, while `render_utils.rs` owns the CPU drawing primitives used by all charts.
//! This file owns only module visibility and reexports, not chart state, buffers, dataframe ingestion, or render math.
//! Open it when chart ownership, public names, or reexport boundaries move between sibling implementation files.
//! For behavior changes, edit the renderer file that owns the chart type instead of growing coordination logic here.

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
