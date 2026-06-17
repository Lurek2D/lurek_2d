//! Defines shared chart configuration contracts used across all chart rendering variants. `charts/config` delivers the configuration schema and defaults for the charts subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Stores dimensions, margins, titles, palette defaults, and optional legend or axis metadata. The file owns or coordinates data contracts including `ChartMargin`, `ChartConfig`, `ChartSeries`, `ChartDataFrameOptions`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Provides common series and DataFrame mapping structures consumed by concrete chart specs. Public callable behavior is centered on no named public items, while method-level behavior such as no named public items stays attached to the local data model and invariants.
//! Serves as the canonical option layer for consistent chart behavior and appearance. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

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
    /// Optional X-axis label.
    pub x_label: Option<String>,
    /// Optional Y-axis label.
    pub y_label: Option<String>,
    /// Margins around the plot area.
    pub margin: ChartMargin,
    /// Number of X-axis ticks to annotate for cartesian charts.
    pub x_tick_count: u32,
    /// Number of Y-axis ticks to annotate for cartesian charts.
    pub y_tick_count: u32,
    /// Whether to draw background grid lines.
    pub show_grid: bool,
    /// Whether to draw a legend panel.
    pub show_legend: bool,
    /// Width reserved for the legend panel in pixels.
    pub legend_width: f32,
    /// Optional maximum number of points retained per series for streaming charts.
    pub max_points: Option<usize>,
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
            x_label: None,
            y_label: None,
            margin: ChartMargin::default(),
            x_tick_count: 5,
            y_tick_count: 5,
            show_grid: true,
            show_legend: false,
            legend_width: 80.0,
            max_points: None,
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
