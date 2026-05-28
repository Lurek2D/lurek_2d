//! Shared chart configuration types: size, background, margins, and axis labels.
//!
//! - `ChartConfig` is the common base embedded in every chart spec.
//! - Pixel dimensions, background colour, and title string live here.
//! - Axis label and legend settings are optional; missing values use defaults.
//! - Referenced by `BarChartSpec`, `LineChartSpec`, `PieChartSpec`, etc.

/// Default palette of 8 distinct colors for auto-assigning series (RGBA, 0.0–1.0).
pub const DEFAULT_PALETTE: &[[f32; 4]; 8] = &[
    [0.227, 0.525, 0.733, 1.0], // blue
    [0.894, 0.333, 0.290, 1.0], // red
    [0.180, 0.659, 0.400, 1.0], // green
    [0.584, 0.404, 0.741, 1.0], // purple
    [1.000, 0.647, 0.000, 1.0], // orange
    [0.369, 0.725, 0.820, 1.0], // cyan
    [0.863, 0.745, 0.000, 1.0], // yellow
    [0.600, 0.600, 0.600, 1.0], // grey
];

/// Top/right/bottom/left margins around the chart plot area.
#[derive(Debug, Clone, Copy)]
pub struct ChartMargin {
    /// Top margin in pixels.
    pub top: f32,
    /// Right margin in pixels.
    pub right: f32,
    /// Bottom margin in pixels.
    pub bottom: f32,
    /// Left margin in pixels.
    pub left: f32,
}

impl Default for ChartMargin {
    fn default() -> Self {
        Self {
            top: 30.0,
            right: 20.0,
            bottom: 40.0,
            left: 50.0,
        }
    }
}

/// Configuration shared by all chart types.
#[derive(Debug, Clone)]
pub struct ChartConfig {
    /// Output width in pixels.
    pub width: u32,
    /// Output height in pixels.
    pub height: u32,
    /// Background color (RGBA, 0.0–1.0).
    pub bg_color: [f32; 4],
    /// Axis line color (RGBA, 0.0–1.0).
    pub axis_color: [f32; 4],
    /// Grid line color (RGBA, 0.0–1.0).
    pub grid_color: [f32; 4],
    /// Label/text color (RGBA, 0.0–1.0).
    pub label_color: [f32; 4],
    /// Optional chart title.
    pub title: Option<String>,
    /// Margins around the plot area.
    pub margin: ChartMargin,
    /// Whether to draw background grid lines.
    pub show_grid: bool,
    /// Whether to draw a legend panel.
    pub show_legend: bool,
    /// Width reserved for the legend panel in pixels.
    pub legend_width: f32,
}

impl Default for ChartConfig {
    fn default() -> Self {
        Self {
            width: 400,
            height: 300,
            bg_color: [1.0, 1.0, 1.0, 1.0],
            axis_color: [0.0, 0.0, 0.0, 1.0],
            grid_color: [0.85, 0.85, 0.85, 1.0],
            label_color: [0.0, 0.0, 0.0, 1.0],
            title: None,
            margin: ChartMargin::default(),
            show_grid: true,
            show_legend: false,
            legend_width: 80.0,
        }
    }
}

/// A named, colored data series containing (x, y) points.
#[derive(Debug, Clone)]
pub struct ChartSeries {
    /// Display name of the series.
    pub name: String,
    /// Series color (RGBA, 0.0–1.0).
    pub color: [f32; 4],
    /// Data points as (x, y) pairs.
    pub data: Vec<(f32, f32)>,
}

/// Options for DataFrame-to-chart mapping.
#[derive(Debug, Clone, Default)]
pub struct ChartDataFrameOptions {
    /// Maximum number of rows to plot from the DataFrame.
    pub max_rows: Option<usize>,
}
