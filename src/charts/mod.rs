//! Software-rasterised chart rendering for data visualisation.
//!
//! - Five chart types: line, bar, scatter, pie, area.
//! - Configurable appearance: colors, margins, grid, titles, legends.
//! - Renders to CPU pixel buffers (no GPU dependency).
//! - DataFrame integration for direct column-to-series mapping.

/// Chart configuration and shared types.
pub mod config;
/// Line chart: plots data series as connected lines over time or categories.
pub mod line;
/// Bar chart: displays grouped or stacked vertical bars for category comparison.
pub mod bar;
/// Scatter plot: renders (x, y) point series to show distribution and correlation.
pub mod scatter;
/// Pie chart: renders proportional slice segments from a single data series.
pub mod pie;
/// Area chart: filled regions below line series for cumulative value display.
pub mod area;
/// Shared rasterization utilities.
pub mod render_utils;

pub use area::AreaChart;
pub use bar::BarChart;
pub use config::{ChartConfig, ChartDataFrameOptions, ChartMargin, ChartSeries};
pub use line::LineChart;
pub use pie::PieChart;
pub use scatter::ScatterPlot;
