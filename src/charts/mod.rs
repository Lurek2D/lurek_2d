//! This module is the charts index, wiring concrete chart renderers, shared config types, and raster helpers.
//! It exports area, bar, line, pie, scatter, histogram, heatmap, candlestick, boxplot, bubble, radar, and treemap owners.
//! Shared option contracts live in `config.rs`, while `render_utils.rs` owns the CPU drawing primitives used by all charts.
//! This file owns only module visibility and reexports, not chart state, buffers, dataframe ingestion, or render math.
//! Open it when chart ownership, public names, or reexport boundaries move between sibling implementation files.
//! For behavior changes, edit the renderer file that owns the chart type instead of growing coordination logic here.

/// Area chart: filled regions below line series for cumulative value display.
pub mod area;
/// Bar chart: displays grouped or stacked vertical bars for category comparison.
pub mod bar;
/// Boxplot chart: displays quartiles, medians, whiskers, and outliers for distributions.
pub mod boxplot;
/// Bubble chart: weighted scatter plot where point size encodes a third value.
pub mod bubble;
/// Candlestick chart: displays ordered OHLC candles for financial or interval data.
pub mod candlestick;
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
/// Radar chart: compares multivariate series across shared radial axes.
pub mod radar;
/// Shared rasterization utilities.
pub mod render_utils;
/// Scatter plot: renders (x, y) point series to show distribution and correlation.
pub mod scatter;
/// Treemap chart: renders weighted labeled rectangles for part-to-whole summaries.
pub mod treemap;

pub use area::AreaChart;
pub use bar::BarChart;
pub use boxplot::BoxPlotChart;
pub use bubble::BubbleChart;
pub use candlestick::{Candle, CandlestickChart};
pub use config::{ChartConfig, ChartDataFrameOptions, ChartMargin, ChartSeries};
pub use heatmap::HeatmapChart;
pub use histogram::HistogramChart;
pub use line::LineChart;
pub use pie::PieChart;
pub use radar::RadarChart;
pub use scatter::ScatterPlot;
pub use treemap::{TreemapChart, TreemapItem};
