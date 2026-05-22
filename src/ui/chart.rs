//! - Software-rasterised chart rendering into `ImageData` pixel buffers — no GPU dependency.
//! - Five chart types: `LineChart` (polyline + dots), `BarChart` (grouped), `ScatterPlot`,
//!   `PieChart` (per-pixel angle test), and `AreaChart` (stacked cumulative layers).
//! - Shared `ChartConfig` controls dimensions, background/axis/grid/label colours, title,
//!   margins, and grid visibility across all chart types.
//! - Grid and axis helpers draw horizontal/vertical grid lines, tick marks, and numeric labels
//!   scaled to arbitrary value ranges on both axes.
//! - Legend panels reserve space outside the plotted data area when the image size allows it.
//! - Pie chart uses brute-force per-pixel distance and angle checks with edge-darkening for
//!   anti-aliased-looking wedge boundaries; divider lines drawn as white radial spokes.
//! - Area chart performs linear interpolation between uniform X samples and fills columns
//!   cumulatively from the bottom layer upward.
//! - `safe_circle` helper rasterises filled circles clamped to image bounds for dot markers.
//! - All draw operations write directly to RGBA pixel data; output is a plain `ImageData` that
//!   can be saved to PNG or uploaded as a GPU texture.

use crate::dataframe::frame::{CellValue, ColRef, DataFrame};
use crate::image::ImageData;
use crate::math::color::Color;

const PIE_DATAFRAME_PALETTE: [Color; 8] = [
    Color::new(0.22, 0.63, 0.87, 1.0),
    Color::new(0.87, 0.35, 0.22, 1.0),
    Color::new(0.35, 0.75, 0.35, 1.0),
    Color::new(0.82, 0.55, 0.18, 1.0),
    Color::new(0.50, 0.45, 0.86, 1.0),
    Color::new(0.20, 0.70, 0.65, 1.0),
    Color::new(0.86, 0.45, 0.70, 1.0),
    Color::new(0.45, 0.55, 0.62, 1.0),
];

const LEGEND_GAP: i32 = 8;
const LEGEND_PAD_X: i32 = 6;
const LEGEND_PAD_Y: i32 = 5;
const LEGEND_ROW_HEIGHT: i32 = 14;
const LEGEND_SWATCH_WIDTH: i32 = 10;
const LEGEND_SWATCH_HEIGHT: i32 = 8;
const LEGEND_MIN_WIDTH: i32 = 58;
const LEGEND_MAX_WIDTH: i32 = 128;
const MIN_CARTESIAN_PLOT_WIDTH: i32 = 72;
const MIN_CARTESIAN_PLOT_HEIGHT: i32 = 44;
const AXIS_LABEL_BAND: i32 = 20;
const PIE_PERCENT_TEXT_WIDTH: i32 = 32;
const MIN_PIE_RADIUS: i32 = 16;

#[derive(Debug, Clone, Copy)]
struct ChartRect {
    left: i32,
    right: i32,
    top: i32,
    bottom: i32,
}

impl ChartRect {
    fn width(self) -> i32 {
        (self.right - self.left).max(0)
    }

    fn height(self) -> i32 {
        (self.bottom - self.top).max(0)
    }
}

/// Options used when adding chart data from a dataframe.
#[derive(Debug, Clone, Copy, Default)]
pub struct ChartDataFrameOptions {
    /// Optional maximum number of dataframe rows to read.
    pub max_rows: Option<usize>,
}

fn dataframe_row_limit(dataframe: &DataFrame, max_rows: Option<usize>) -> usize {
    max_rows.map_or_else(|| dataframe.nrows(), |limit| dataframe.nrows().min(limit))
}

fn cell_to_f32(cell: &CellValue) -> Option<f32> {
    if let Some(value) = cell.as_number() {
        return value.is_finite().then_some(value as f32);
    }
    match cell {
        CellValue::Text(value) => value
            .parse::<f32>()
            .ok()
            .filter(|parsed| parsed.is_finite()),
        _ => None,
    }
}

fn dataframe_xy_points(
    dataframe: &DataFrame,
    x_col: &str,
    y_col: &str,
    options: ChartDataFrameOptions,
) -> Result<Vec<(f32, f32)>, String> {
    let x_values = dataframe.get_column(ColRef::Name(x_col.to_string()))?;
    let y_values = dataframe.get_column(ColRef::Name(y_col.to_string()))?;
    let row_count = dataframe_row_limit(dataframe, options.max_rows);
    let mut points = Vec::with_capacity(row_count);
    for row_index in 0..row_count {
        if let (Some(x), Some(y)) = (
            x_values.get(row_index).and_then(cell_to_f32),
            y_values.get(row_index).and_then(cell_to_f32),
        ) {
            points.push((x, y));
        }
    }
    Ok(points)
}

/// Global configuration shared by all chart types; controls dimensions, colours, title, and margins.
#[derive(Debug, Clone)]
pub struct ChartConfig {
    /// Pixel width of the rendered image.
    pub width: u32,
    /// Pixel height of the rendered image.
    pub height: u32,
    /// Optional title string drawn at the top of the chart.
    pub title: Option<String>,
    /// Background fill colour as (R, G, B).
    pub bg_color: (u8, u8, u8),
    /// Axis line colour as (R, G, B).
    pub axis_color: (u8, u8, u8),
    /// Grid line colour as (R, G, B).
    pub grid_color: (u8, u8, u8),
    /// Axis label text colour as (R, G, B).
    pub label_color: (u8, u8, u8),
    /// Whether to draw grid lines behind the chart data.
    pub show_grid: bool,
    /// Pixel margins between the chart border and the drawable area.
    pub margin: ChartMargin,
}
/// Pixel margins inset from each edge of the image to the chart drawing area.
#[derive(Debug, Clone, Copy)]
pub struct ChartMargin {
    /// Pixels reserved on the left edge for Y-axis labels.
    pub left: i32,
    /// Pixels reserved on the right edge.
    pub right: i32,
    /// Pixels reserved at the top for the chart title.
    pub top: i32,
    /// Pixels reserved at the bottom for X-axis labels.
    pub bottom: i32,
}
/// Provide sensible default margins (left=40, right=20, top=30, bottom=40).
impl Default for ChartMargin {
    fn default() -> Self {
        Self {
            left: 40,
            right: 20,
            top: 30,
            bottom: 40,
        }
    }
}
/// Provide a 400×300 chart config with neutral colours and grid enabled.
impl Default for ChartConfig {
    fn default() -> Self {
        Self {
            width: 400,
            height: 300,
            title: None,
            bg_color: (240, 240, 245),
            axis_color: (60, 60, 70),
            grid_color: (200, 200, 210),
            label_color: (80, 80, 80),
            show_grid: true,
            margin: ChartMargin::default(),
        }
    }
}
/// A named (x, y) data series with an associated colour for line/scatter charts.
#[derive(Debug, Clone)]
pub struct ChartSeries {
    /// Display name used in the chart legend.
    pub name: String,
    /// Series line/point colour.
    pub color: Color,
    /// Ordered (x, y) data points.
    pub values: Vec<(f32, f32)>,
}
fn label_width_px(text: &str) -> i32 {
    text.chars().count() as i32 * 6
}

fn legend_panel_size(entries: &[(&str, Color)], extra_text_width: i32) -> (i32, i32) {
    let widest_label = entries
        .iter()
        .map(|(name, _)| label_width_px(name))
        .max()
        .unwrap_or(0);
    let content_width =
        LEGEND_PAD_X * 2 + LEGEND_SWATCH_WIDTH + 4 + widest_label + extra_text_width.max(0);
    let panel_width = content_width.clamp(
        LEGEND_MIN_WIDTH + extra_text_width.max(0),
        LEGEND_MAX_WIDTH + extra_text_width.max(0),
    );
    let panel_height = (entries.len() as i32 * LEGEND_ROW_HEIGHT + LEGEND_PAD_Y * 2).max(22);
    (panel_width, panel_height)
}

fn base_plot_rect(cfg: &ChartConfig) -> ChartRect {
    let image_width = cfg.width as i32;
    let image_height = cfg.height as i32;
    let left = cfg.margin.left.clamp(0, (image_width - 1).max(0));
    let top = cfg.margin.top.clamp(0, (image_height - 1).max(0));
    let right = (image_width - cfg.margin.right).max(left + 1);
    let bottom = (image_height - cfg.margin.bottom).max(top + 1);
    ChartRect {
        left,
        right: right.min(image_width),
        top,
        bottom: bottom.min(image_height),
    }
}

fn legend_top_for_plot(cfg: &ChartConfig, plot: ChartRect, panel_height: i32) -> i32 {
    let image_height = cfg.height as i32;
    let max_top = image_height - panel_height - 4;
    (plot.top + 6).min(max_top).max(2)
}

fn cartesian_plot_layout(
    cfg: &ChartConfig,
    entries: &[(&str, Color)],
) -> (ChartRect, Option<ChartRect>) {
    let mut plot = base_plot_rect(cfg);
    if entries.is_empty() {
        return (plot, None);
    }

    let (legend_width, legend_height) = legend_panel_size(entries, 0);
    let image_width = cfg.width as i32;
    let image_height = cfg.height as i32;
    let right_padding = cfg.margin.right.max(4);
    let right_panel_left = image_width - right_padding - legend_width;
    let right_plot_width = right_panel_left - LEGEND_GAP - plot.left;
    let right_panel_fits_height = legend_height <= image_height - plot.top - 4;
    if right_plot_width >= MIN_CARTESIAN_PLOT_WIDTH && right_panel_fits_height {
        let panel_top = legend_top_for_plot(cfg, plot, legend_height);
        let legend = ChartRect {
            left: right_panel_left,
            right: right_panel_left + legend_width,
            top: panel_top,
            bottom: panel_top + legend_height,
        };
        plot.right = right_panel_left - LEGEND_GAP;
        return (plot, Some(legend));
    }

    let bottom_panel_top = image_height - legend_height - 4;
    let bottom_plot_height = bottom_panel_top - AXIS_LABEL_BAND - LEGEND_GAP - plot.top;
    if bottom_plot_height >= MIN_CARTESIAN_PLOT_HEIGHT && legend_width <= image_width - 8 {
        let panel_left = ((image_width - legend_width) / 2).max(4);
        let legend = ChartRect {
            left: panel_left,
            right: panel_left + legend_width,
            top: bottom_panel_top,
            bottom: bottom_panel_top + legend_height,
        };
        plot.bottom = bottom_panel_top - AXIS_LABEL_BAND - LEGEND_GAP;
        return (plot, Some(legend));
    }

    (plot, None)
}

/// Draw grid lines and axis borders within precomputed plot boundaries.
fn draw_grid_and_axes_in_rect(
    img: &mut ImageData,
    cfg: &ChartConfig,
    plot: ChartRect,
    x_divisions: u32,
    y_divisions: u32,
) -> (i32, i32, i32, i32) {
    let x_divisions = x_divisions.max(1);
    let y_divisions = y_divisions.max(1);
    let left = plot.left;
    let right = plot.right;
    let top = plot.top;
    let bottom = plot.bottom;
    let (gr, gg, gb) = cfg.grid_color;
    let (ar, ag, ab) = cfg.axis_color;
    if cfg.show_grid {
        let chart_w = (right - left).max(1) as f32;
        let chart_h = (bottom - top).max(1) as f32;
        for i in 0..=y_divisions {
            let y = top + (i as f32 * chart_h / y_divisions as f32) as i32;
            img.draw_line(left, y, right, y, gr, gg, gb, 255);
        }
        for i in 0..=x_divisions {
            let x = left + (i as f32 * chart_w / x_divisions as f32) as i32;
            img.draw_line(x, top, x, bottom, gr, gg, gb, 255);
        }
    }
    img.draw_line(left, top, left, bottom, ar, ag, ab, 255);
    img.draw_line(left, bottom, right, bottom, ar, ag, ab, 255);
    (left, right, top, bottom)
}
/// Convert a `Color` (float components [0,1]) to an `(R, G, B)` u8 tuple.
fn to_rgb(color: Color) -> (u8, u8, u8) {
    (
        (color.r * 255.0) as u8,
        (color.g * 255.0) as u8,
        (color.b * 255.0) as u8,
    )
}
/// Draw tick marks and numeric labels on both axes using the supplied value ranges.
#[allow(clippy::too_many_arguments)]
fn draw_numeric_axes(
    img: &mut ImageData,
    cfg: &ChartConfig,
    left: i32,
    right: i32,
    top: i32,
    bottom: i32,
    x_ticks: u32,
    y_ticks: u32,
    x_min: f32,
    x_max: f32,
    y_min: f32,
    y_max: f32,
) {
    let x_ticks = x_ticks.max(1);
    let y_ticks = y_ticks.max(1);
    let chart_w = (right - left).max(1) as f32;
    let chart_h = (bottom - top).max(1) as f32;
    let (lr, lg, lb) = cfg.label_color;
    for i in 0..=x_ticks {
        let x = left + (i as f32 * chart_w / x_ticks as f32) as i32;
        let v = x_min + (x_max - x_min) * (i as f32 / x_ticks as f32);
        img.draw_line(x, bottom, x, bottom + 4, lr, lg, lb, 255);
        img.draw_label(&format!("{v:.1}"), x - 10, bottom + 8, lr, lg, lb);
    }
    for i in 0..=y_ticks {
        let y = bottom - (i as f32 * chart_h / y_ticks as f32) as i32;
        let v = y_min + (y_max - y_min) * (i as f32 / y_ticks as f32);
        img.draw_line(left - 4, y, left, y, lr, lg, lb, 255);
        img.draw_label(&format!("{v:.1}"), 4, y - 3, lr, lg, lb);
    }
    img.draw_label("X", right + 6, bottom - 4, lr, lg, lb);
    img.draw_label("Y", left - 12, top - 14, lr, lg, lb);
}

fn readable_x_tick_count(plot: ChartRect, desired_ticks: u32, x_min: f32, x_max: f32) -> u32 {
    let desired_ticks = desired_ticks.max(1);
    let min_label = format!("{x_min:.1}");
    let max_label = format!("{x_max:.1}");
    let label_spacing = label_width_px(&min_label).max(label_width_px(&max_label)) + 12;
    let max_labels = (plot.width() / label_spacing.max(1)).clamp(2, 9) as u32;
    desired_ticks.min(max_labels.saturating_sub(1).max(1))
}

fn readable_y_tick_count(plot: ChartRect, desired_ticks: u32) -> u32 {
    let desired_ticks = desired_ticks.max(1);
    let max_labels = (plot.height() / 16).clamp(2, 6) as u32;
    desired_ticks.min(max_labels.saturating_sub(1).max(1))
}

/// Draw Y-axis tick marks and numeric labels for category-based charts.
#[allow(clippy::too_many_arguments)]
fn draw_numeric_y_axis(
    img: &mut ImageData,
    cfg: &ChartConfig,
    left: i32,
    top: i32,
    bottom: i32,
    y_ticks: u32,
    y_min: f32,
    y_max: f32,
) {
    let y_ticks = y_ticks.max(1);
    let chart_h = (bottom - top).max(1) as f32;
    let (lr, lg, lb) = cfg.label_color;
    for tick_index in 0..=y_ticks {
        let y = bottom - (tick_index as f32 * chart_h / y_ticks as f32) as i32;
        let value = y_min + (y_max - y_min) * (tick_index as f32 / y_ticks as f32);
        img.draw_line(left - 4, y, left, y, lr, lg, lb, 255);
        img.draw_label(&format!("{value:.1}"), 4, y - 3, lr, lg, lb);
    }
    img.draw_label("Y", left - 12, top - 14, lr, lg, lb);
}

fn draw_legend_panel_frame(img: &mut ImageData, panel: ChartRect) {
    let panel_width = panel.width();
    let panel_height = panel.height();
    if panel_width <= 0 || panel_height <= 0 {
        return;
    }
    img.draw_rect(
        panel.left,
        panel.top,
        panel_width as u32,
        panel_height as u32,
        250,
        250,
        252,
        230,
    );
    img.draw_rect(
        panel.left,
        panel.top,
        panel_width as u32,
        1,
        170,
        176,
        188,
        255,
    );
    img.draw_rect(
        panel.left,
        panel.bottom - 1,
        panel_width as u32,
        1,
        170,
        176,
        188,
        255,
    );
    img.draw_rect(
        panel.left,
        panel.top,
        1,
        panel_height as u32,
        170,
        176,
        188,
        255,
    );
    img.draw_rect(
        panel.right - 1,
        panel.top,
        1,
        panel_height as u32,
        170,
        176,
        188,
        255,
    );
}

/// Draw a colour-swatch legend box in a caller-provided panel outside plotted data.
fn draw_series_legend(
    img: &mut ImageData,
    cfg: &ChartConfig,
    panel: ChartRect,
    entries: &[(&str, Color)],
) {
    if entries.is_empty() {
        return;
    }
    draw_legend_panel_frame(img, panel);
    let (lr, lg, lb) = cfg.label_color;
    for (idx, (name, color)) in entries.iter().enumerate() {
        let y = panel.top + LEGEND_PAD_Y + idx as i32 * LEGEND_ROW_HEIGHT;
        let (cr, cg, cb) = to_rgb(*color);
        img.draw_rect(
            panel.left + LEGEND_PAD_X,
            y,
            LEGEND_SWATCH_WIDTH as u32,
            LEGEND_SWATCH_HEIGHT as u32,
            cr,
            cg,
            cb,
            255,
        );
        img.draw_label(
            name,
            panel.left + LEGEND_PAD_X + LEGEND_SWATCH_WIDTH + 4,
            y + 1,
            lr,
            lg,
            lb,
        );
    }
}

fn pie_layout(cfg: &ChartConfig, entries: &[(&str, Color)]) -> (f32, f32, f32, Option<ChartRect>) {
    let image_width = cfg.width as i32;
    let image_height = cfg.height as i32;
    let title_space = if cfg.title.is_some() { 26 } else { 8 };

    if !entries.is_empty() {
        let (legend_width, legend_height) = legend_panel_size(entries, PIE_PERCENT_TEXT_WIDTH);
        let right_panel_left = image_width - 6 - legend_width;
        let right_area = ChartRect {
            left: 8,
            right: right_panel_left - LEGEND_GAP,
            top: title_space,
            bottom: image_height - 8,
        };
        let right_radius = right_area.width().min(right_area.height()) / 2 - 2;
        let right_legend_fits = right_radius >= MIN_PIE_RADIUS
            && legend_height <= image_height - title_space - 4
            && right_panel_left > right_area.left;
        if right_legend_fits {
            let panel_top = (title_space
                + ((image_height - title_space - legend_height) / 2).max(0))
            .min(image_height - legend_height - 4)
            .max(2);
            let legend = ChartRect {
                left: right_panel_left,
                right: right_panel_left + legend_width,
                top: panel_top,
                bottom: panel_top + legend_height,
            };
            let center_x = right_area.left as f32 + right_area.width() as f32 * 0.5;
            let center_y = right_area.top as f32 + right_area.height() as f32 * 0.5;
            return (center_x, center_y, right_radius as f32, Some(legend));
        }

        let bottom_panel_top = image_height - legend_height - 4;
        let bottom_area = ChartRect {
            left: 8,
            right: image_width - 8,
            top: title_space,
            bottom: bottom_panel_top - LEGEND_GAP,
        };
        let bottom_radius = bottom_area.width().min(bottom_area.height()) / 2 - 2;
        if bottom_radius >= MIN_PIE_RADIUS && legend_width <= image_width - 8 {
            let panel_left = ((image_width - legend_width) / 2).max(4);
            let legend = ChartRect {
                left: panel_left,
                right: panel_left + legend_width,
                top: bottom_panel_top,
                bottom: bottom_panel_top + legend_height,
            };
            let center_x = bottom_area.left as f32 + bottom_area.width() as f32 * 0.5;
            let center_y = bottom_area.top as f32 + bottom_area.height() as f32 * 0.5;
            return (center_x, center_y, bottom_radius as f32, Some(legend));
        }
    }

    let fallback_area = ChartRect {
        left: 8,
        right: image_width - 8,
        top: title_space,
        bottom: image_height - 8,
    };
    let radius = (fallback_area.width().min(fallback_area.height()) / 2 - 2).max(1);
    let center_x = fallback_area.left as f32 + fallback_area.width() as f32 * 0.5;
    let center_y = fallback_area.top as f32 + fallback_area.height() as f32 * 0.5;
    (center_x, center_y, radius as f32, None)
}

fn draw_pie_legend(
    img: &mut ImageData,
    cfg: &ChartConfig,
    panel: ChartRect,
    segments: &[PieSegment],
    total: f32,
) {
    if segments.is_empty() || total <= 0.0 {
        return;
    }
    draw_legend_panel_frame(img, panel);
    let (lr, lg, lb) = cfg.label_color;
    let percent_x = (panel.right - PIE_PERCENT_TEXT_WIDTH - LEGEND_PAD_X)
        .max(panel.left + LEGEND_PAD_X + LEGEND_SWATCH_WIDTH + 8);
    for (segment_index, segment) in segments.iter().enumerate() {
        let y = panel.top + LEGEND_PAD_Y + segment_index as i32 * LEGEND_ROW_HEIGHT;
        let (cr, cg, cb) = to_rgb(segment.color);
        img.draw_rect(
            panel.left + LEGEND_PAD_X,
            y,
            LEGEND_SWATCH_WIDTH as u32,
            LEGEND_SWATCH_HEIGHT as u32,
            cr,
            cg,
            cb,
            255,
        );
        img.draw_label(
            &segment.label,
            panel.left + LEGEND_PAD_X + LEGEND_SWATCH_WIDTH + 4,
            y + 1,
            lr,
            lg,
            lb,
        );
        let percent = segment.value / total * 100.0;
        img.draw_label(&format!("{percent:.1}%"), percent_x, y + 1, lr, lg, lb);
    }
}
/// Draw the chart title string at pixel position `(x, y)` if one is set in `cfg`.
fn draw_chart_title(img: &mut ImageData, cfg: &ChartConfig, x: i32, y: i32) {
    if let Some(ref title) = cfg.title {
        let (lr, lg, lb) = cfg.label_color;
        img.draw_label(title, x, y, lr, lg, lb);
    }
}
/// Build legend `(name, color)` pairs from a slice of `ChartSeries`.
fn legend_entries_from_series(series: &[ChartSeries]) -> Vec<(&str, Color)> {
    series.iter().map(|s| (s.name.as_str(), s.color)).collect()
}
/// Build legend `(name, color)` pairs by zipping name strings and colour slices.
fn legend_entries_from_names<'a>(names: &'a [String], colors: &[Color]) -> Vec<(&'a str, Color)> {
    names
        .iter()
        .zip(colors.iter().copied())
        .map(|(name, c)| (name.as_str(), c))
        .collect()
}
/// Build legend `(name, color)` pairs from a slice of `AreaLayer` entries.
fn legend_entries_from_layers(layers: &[AreaLayer]) -> Vec<(&str, Color)> {
    layers.iter().map(|l| (l.name.as_str(), l.color)).collect()
}
/// Build legend `(label, color)` pairs from a slice of `PieSegment` entries.
fn legend_entries_from_segments(segments: &[PieSegment]) -> Vec<(&str, Color)> {
    segments
        .iter()
        .map(|seg| (seg.label.as_str(), seg.color))
        .collect()
}
/// Draw a filled circle of radius `r` centred at `(cx, cy)`, clamped to image bounds.
#[allow(clippy::too_many_arguments)]
fn safe_circle(img: &mut ImageData, cx: i32, cy: i32, r: i32, red: u8, g: u8, b: u8, a: u8) {
    let w = img.width() as i32;
    let h = img.height() as i32;
    let y0 = (cy - r).max(0);
    let y1 = (cy + r + 1).min(h);
    let x0 = (cx - r).max(0);
    let x1 = (cx + r + 1).min(w);
    let r2 = (r * r) as i64;
    for py in y0..y1 {
        let dy = (py - cy) as i64;
        for px in x0..x1 {
            let dx = (px - cx) as i64;
            if dx * dx + dy * dy <= r2 {
                img.set_pixel(px as u32, py as u32, red, g, b, a);
            }
        }
    }
}
/// Cartesian line chart that draws one or more `ChartSeries` as polylines with data-point dots.
#[derive(Debug, Clone)]
pub struct LineChart {
    /// Shared configuration (dimensions, colours, title, margins).
    pub config: ChartConfig,
    /// All data series to render.
    pub series: Vec<ChartSeries>,
    /// Maximum Y value; used to normalise series values into the chart area.
    pub y_max: f32,
    /// Maximum X value; used to normalise series values into the chart area.
    pub x_max: f32,
}
impl LineChart {
    /// Create a new line chart with the given config and default Y/X range of 100.0/6.0.
    pub fn new(config: ChartConfig) -> Self {
        Self {
            config,
            series: Vec::new(),
            y_max: 100.0,
            x_max: 6.0,
        }
    }
    /// Append a named data series of `(x, y)` points with the given colour.
    pub fn add_series(&mut self, name: &str, points: &[(f32, f32)], color: Color) {
        self.series.push(ChartSeries {
            name: name.to_string(),
            color,
            values: points.to_vec(),
        });
    }
    /// Append a named series from dataframe columns and return the number of accepted points.
    pub fn add_series_from_dataframe(
        &mut self,
        name: &str,
        dataframe: &DataFrame,
        x_col: &str,
        y_col: &str,
        color: Color,
        options: ChartDataFrameOptions,
    ) -> Result<usize, String> {
        let points = dataframe_xy_points(dataframe, x_col, y_col, options)?;
        let point_count = points.len();
        self.add_series(name, &points, color);
        Ok(point_count)
    }
    /// Rasterise the line chart into `img`, overwriting its contents.
    pub fn draw_to_image(&self, img: &mut crate::image::ImageData) {
        let cfg = &self.config;
        let (bgr, bgg, bgb) = cfg.bg_color;
        img.fill(bgr, bgg, bgb, 255);
        let legend_entries = legend_entries_from_series(&self.series);
        let (plot, legend_panel) = cartesian_plot_layout(cfg, &legend_entries);
        let x_ticks = readable_x_tick_count(plot, self.x_max.ceil() as u32, 0.0, self.x_max);
        let y_ticks = readable_y_tick_count(plot, 5);
        draw_grid_and_axes_in_rect(img, cfg, plot, x_ticks, y_ticks);
        let (left, right, top, bottom) = (plot.left, plot.right, plot.top, plot.bottom);
        let chart_w = (right - left).max(1) as f32;
        let chart_h = (bottom - top).max(1) as f32;
        draw_numeric_axes(
            img, cfg, left, right, top, bottom, x_ticks, y_ticks, 0.0, self.x_max, 0.0, self.y_max,
        );
        draw_chart_title(img, cfg, left + 10, 10);
        if let Some(panel) = legend_panel {
            draw_series_legend(img, cfg, panel, &legend_entries);
        }
        for s in &self.series {
            let (cr, cg, cb) = to_rgb(s.color);
            for i in 1..s.values.len() {
                let x0 = left + (s.values[i - 1].0 / self.x_max * chart_w) as i32;
                let y0 = bottom - (s.values[i - 1].1 / self.y_max * chart_h) as i32;
                let x1 = left + (s.values[i].0 / self.x_max * chart_w) as i32;
                let y1 = bottom - (s.values[i].1 / self.y_max * chart_h) as i32;
                img.draw_line(x0, y0, x1, y1, cr, cg, cb, 255);
                img.draw_line(x0, y0 + 1, x1, y1 + 1, cr, cg, cb, 255);
            }
            for pt in &s.values {
                let x = left + (pt.0 / self.x_max * chart_w) as i32;
                let y = bottom - (pt.1 / self.y_max * chart_h) as i32;
                safe_circle(img, x, y, 3, cr, cg, cb, 255);
            }
        }
    }
}
/// One labelled category (group of bars) in a `BarChart`.
#[derive(Debug, Clone)]
pub struct BarCategory {
    /// X-axis label displayed below this group.
    pub label: String,
    /// One value per series in this category; parallel to `BarChart::series_colors`.
    pub values: Vec<f32>,
}
/// Grouped bar chart with named series and labelled categories.
#[derive(Debug, Clone)]
pub struct BarChart {
    /// Shared configuration.
    pub config: ChartConfig,
    /// All category groups, each containing one value per series.
    pub categories: Vec<BarCategory>,
    /// Colours for each series; parallel to `series_names`.
    pub series_colors: Vec<Color>,
    /// Display names for each series; parallel to `series_colors`.
    pub series_names: Vec<String>,
    /// Maximum Y value used to normalise bar heights.
    pub y_max: f32,
}
impl BarChart {
    /// Create an empty bar chart with the given config and default Y max of 100.0.
    pub fn new(config: ChartConfig) -> Self {
        Self {
            config,
            categories: Vec::new(),
            series_colors: Vec::new(),
            series_names: Vec::new(),
            y_max: 100.0,
        }
    }
    /// Register a named series with the given colour; call before `add_category`.
    pub fn add_series(&mut self, name: &str, color: Color) {
        self.series_names.push(name.to_string());
        self.series_colors.push(color);
    }
    /// Add a labelled category group with one value per series.
    pub fn add_category(&mut self, label: &str, values: &[f32]) {
        self.categories.push(BarCategory {
            label: label.to_string(),
            values: values.to_vec(),
        });
    }
    /// Append categories from dataframe rows and return the number of categories added.
    pub fn add_categories_from_dataframe(
        &mut self,
        dataframe: &DataFrame,
        label_col: &str,
        value_cols: &[String],
        options: ChartDataFrameOptions,
    ) -> Result<usize, String> {
        if self.series_names.len() != value_cols.len() {
            return Err(format!(
                "value column count {} must match registered series count {}",
                value_cols.len(),
                self.series_names.len()
            ));
        }
        let labels = dataframe.get_column(ColRef::Name(label_col.to_string()))?;
        let value_columns = value_cols
            .iter()
            .map(|name| dataframe.get_column(ColRef::Name(name.clone())))
            .collect::<Result<Vec<_>, _>>()?;
        let row_count = dataframe_row_limit(dataframe, options.max_rows);
        for row_index in 0..row_count {
            let label = labels
                .get(row_index)
                .map(ToString::to_string)
                .unwrap_or_default();
            let values = value_columns
                .iter()
                .map(|column| column.get(row_index).and_then(cell_to_f32).unwrap_or(0.0))
                .collect::<Vec<_>>();
            self.add_category(&label, &values);
        }
        Ok(row_count)
    }
    /// Rasterise the bar chart into `img`, overwriting its contents.
    pub fn draw_to_image(&self, img: &mut crate::image::ImageData) {
        let cfg = &self.config;
        let (bgr, bgg, bgb) = cfg.bg_color;
        img.fill(bgr, bgg, bgb, 255);
        let legend_entries = legend_entries_from_names(&self.series_names, &self.series_colors);
        let (plot, legend_panel) = cartesian_plot_layout(cfg, &legend_entries);
        draw_grid_and_axes_in_rect(img, cfg, plot, self.categories.len() as u32, 5);
        let (left, right, top, bottom) = (plot.left, plot.right, plot.top, plot.bottom);
        let chart_h = (bottom - top).max(1) as f32;
        let (lr, lg, lb) = cfg.label_color;
        draw_numeric_y_axis(img, cfg, left, top, bottom, 5, 0.0, self.y_max);
        draw_chart_title(img, cfg, left + 10, 10);
        if let Some(panel) = legend_panel {
            draw_series_legend(img, cfg, panel, &legend_entries);
        }
        let n_series = self.series_colors.len().max(1);
        let n_cats = self.categories.len().max(1);
        let group_w = (right - left) / n_cats as i32;
        let bar_w = (group_w / (n_series as i32 + 1)).max(4);
        let draw_value_labels = chart_h >= 70.0 && bar_w >= 8;
        for (ci, cat) in self.categories.iter().enumerate() {
            let group_x = left + ci as i32 * group_w;
            for (si, &val) in cat.values.iter().enumerate() {
                let c = self.series_colors.get(si).copied().unwrap_or(Color::WHITE);
                let (cr, cg, cb) = to_rgb(c);
                let bh = (val / self.y_max * chart_h) as i32;
                let bx = group_x + 10 + si as i32 * (bar_w + 2);
                img.draw_rect(bx, bottom - bh, bar_w as u32, bh as u32, cr, cg, cb, 255);
                if draw_value_labels && bottom - bh - 8 > top {
                    img.draw_label(
                        &format!("{}", val as i32),
                        bx + 2,
                        bottom - bh - 8,
                        lr,
                        lg,
                        lb,
                    );
                }
            }
            img.draw_label(&cat.label, group_x + 8, bottom + 6, lr, lg, lb);
        }
    }
}
/// Cartesian scatter plot that renders each data point as a filled circle.
#[derive(Debug, Clone)]
pub struct ScatterPlot {
    /// Shared configuration.
    pub config: ChartConfig,
    /// All data series to render.
    pub series: Vec<ChartSeries>,
    /// Visible (min, max) range on the X axis.
    pub x_range: (f32, f32),
    /// Visible (min, max) range on the Y axis.
    pub y_range: (f32, f32),
}
impl ScatterPlot {
    /// Create an empty scatter plot with the given config and default axis ranges of (0.0, 1.0).
    pub fn new(config: ChartConfig) -> Self {
        Self {
            config,
            series: Vec::new(),
            x_range: (0.0, 1.0),
            y_range: (0.0, 1.0),
        }
    }
    /// Append a named series of `(x, y)` scatter points with the given colour.
    pub fn add_series(&mut self, name: &str, points: &[(f32, f32)], color: Color) {
        self.series.push(ChartSeries {
            name: name.to_string(),
            color,
            values: points.to_vec(),
        });
    }
    /// Append a named point series from dataframe columns and return the number of accepted points.
    pub fn add_series_from_dataframe(
        &mut self,
        name: &str,
        dataframe: &DataFrame,
        x_col: &str,
        y_col: &str,
        color: Color,
        options: ChartDataFrameOptions,
    ) -> Result<usize, String> {
        let points = dataframe_xy_points(dataframe, x_col, y_col, options)?;
        let point_count = points.len();
        self.add_series(name, &points, color);
        Ok(point_count)
    }
    /// Rasterise the scatter plot into `img`, overwriting its contents.
    pub fn draw_to_image(&self, img: &mut crate::image::ImageData) {
        let cfg = &self.config;
        let (bgr, bgg, bgb) = cfg.bg_color;
        img.fill(bgr, bgg, bgb, 255);
        let legend_entries = legend_entries_from_series(&self.series);
        let (plot, legend_panel) = cartesian_plot_layout(cfg, &legend_entries);
        let x_ticks = readable_x_tick_count(plot, 5, self.x_range.0, self.x_range.1);
        let y_ticks = readable_y_tick_count(plot, 5);
        draw_grid_and_axes_in_rect(img, cfg, plot, x_ticks, y_ticks);
        let (left, right, top, bottom) = (plot.left, plot.right, plot.top, plot.bottom);
        let chart_w = (right - left).max(1) as f32;
        let chart_h = (bottom - top).max(1) as f32;
        draw_numeric_axes(
            img,
            cfg,
            left,
            right,
            top,
            bottom,
            x_ticks,
            y_ticks,
            self.x_range.0,
            self.x_range.1,
            self.y_range.0,
            self.y_range.1,
        );
        draw_chart_title(img, cfg, left + 10, 10);
        if let Some(panel) = legend_panel {
            draw_series_legend(img, cfg, panel, &legend_entries);
        }
        let x_span = (self.x_range.1 - self.x_range.0).max(f32::EPSILON);
        let y_span = (self.y_range.1 - self.y_range.0).max(f32::EPSILON);
        for s in &self.series {
            let (cr, cg, cb) = to_rgb(s.color);
            for &(x, y) in &s.values {
                let px = left + ((x - self.x_range.0) / x_span * chart_w) as i32;
                let py = bottom - ((y - self.y_range.0) / y_span * chart_h) as i32;
                safe_circle(img, px, py, 4, cr, cg, cb, 180);
            }
        }
    }
}
/// One labelled segment of a `PieChart`.
#[derive(Debug, Clone)]
pub struct PieSegment {
    /// Legend label for this segment.
    pub label: String,
    /// Numerical value; the fraction rendered is `value / total`.
    pub value: f32,
    /// Fill colour for this segment.
    pub color: Color,
}
/// Pie chart that rasterises coloured wedge segments into a pixel image.
#[derive(Debug, Clone)]
pub struct PieChart {
    /// Shared configuration (dimensions, colours, title).
    pub config: ChartConfig,
    /// Ordered segments; rendered clockwise starting from the top.
    pub segments: Vec<PieSegment>,
}
impl PieChart {
    /// Create an empty pie chart with the given config.
    pub fn new(config: ChartConfig) -> Self {
        Self {
            config,
            segments: Vec::new(),
        }
    }
    /// Append a labelled segment with the given value and fill colour.
    pub fn add_segment(&mut self, label: &str, value: f32, color: Color) {
        self.segments.push(PieSegment {
            label: label.to_string(),
            value,
            color,
        });
    }
    /// Append positive numeric segments from dataframe rows using a built-in colour palette.
    pub fn add_segments_from_dataframe(
        &mut self,
        dataframe: &DataFrame,
        label_col: &str,
        value_col: &str,
        options: ChartDataFrameOptions,
    ) -> Result<usize, String> {
        let labels = dataframe.get_column(ColRef::Name(label_col.to_string()))?;
        let values = dataframe.get_column(ColRef::Name(value_col.to_string()))?;
        let row_count = dataframe_row_limit(dataframe, options.max_rows);
        let mut added = 0usize;
        for row_index in 0..row_count {
            let Some(value) = values.get(row_index).and_then(cell_to_f32) else {
                continue;
            };
            if value <= 0.0 {
                continue;
            }
            let label = labels
                .get(row_index)
                .map(ToString::to_string)
                .unwrap_or_default();
            let color = PIE_DATAFRAME_PALETTE[added % PIE_DATAFRAME_PALETTE.len()];
            self.add_segment(&label, value, color);
            added += 1;
        }
        Ok(added)
    }
    /// Rasterise the pie chart into `img`, overwriting its contents; no-ops when total value <= 0.
    pub fn draw_to_image(&self, img: &mut crate::image::ImageData) {
        let cfg = &self.config;
        let w = cfg.width;
        let h = cfg.height;
        let (bgr, bgg, bgb) = cfg.bg_color;
        img.fill(bgr, bgg, bgb, 255);
        let total: f32 = self.segments.iter().map(|s| s.value).sum();
        if total <= 0.0 {
            return;
        }
        let legend_entries = legend_entries_from_segments(&self.segments);
        let (cx, cy, radius, legend_panel) = pie_layout(cfg, &legend_entries);
        let mut angle = -std::f32::consts::FRAC_PI_2;
        for seg in &self.segments {
            let pct = seg.value / total;
            let sweep = pct * 2.0 * std::f32::consts::PI;
            let end_angle = angle + sweep;
            let cr = (seg.color.r * 255.0) as u8;
            let cg = (seg.color.g * 255.0) as u8;
            let cb = (seg.color.b * 255.0) as u8;
            for py in 0..h {
                for px in 0..w {
                    let dx = px as f32 - cx;
                    let dy = py as f32 - cy;
                    let dist = (dx * dx + dy * dy).sqrt();
                    if dist > radius {
                        continue;
                    }
                    let mut a = dy.atan2(dx);
                    if a < -std::f32::consts::FRAC_PI_2 {
                        a += 2.0 * std::f32::consts::PI;
                    }
                    let mut check_a = a;
                    if check_a < angle {
                        check_a += 2.0 * std::f32::consts::PI;
                    }
                    let mut check_end = end_angle;
                    if check_end < angle {
                        check_end += 2.0 * std::f32::consts::PI;
                    }
                    if check_a >= angle && check_a < check_end {
                        let edge_factor = if dist > radius - 3.0 { 0.7f32 } else { 1.0 };
                        img.set_pixel(
                            px,
                            py,
                            (cr as f32 * edge_factor) as u8,
                            (cg as f32 * edge_factor) as u8,
                            (cb as f32 * edge_factor) as u8,
                            255,
                        );
                    }
                }
            }
            angle = end_angle;
        }
        angle = -std::f32::consts::FRAC_PI_2;
        for seg in &self.segments {
            let sweep = seg.value / total * 2.0 * std::f32::consts::PI;
            let lx = cx + angle.cos() * radius;
            let ly = cy + angle.sin() * radius;
            img.draw_line(
                cx as i32, cy as i32, lx as i32, ly as i32, 255, 255, 255, 255,
            );
            angle += sweep;
        }
        if let Some(panel) = legend_panel {
            draw_pie_legend(img, cfg, panel, &self.segments, total);
        }
        draw_chart_title(img, cfg, 10, 10);
    }
}
/// Stacked area chart where each layer fills from its own cumulative base upward.
#[derive(Debug, Clone)]
pub struct AreaChart {
    /// Shared configuration.
    pub config: ChartConfig,
    /// Ordered area layers drawn from bottom to top; stacked cumulatively.
    pub layers: Vec<AreaLayer>,
    /// Total Y axis maximum used to normalise layer values.
    pub y_max: f32,
}
/// One named value series rendered as a filled area in an `AreaChart`.
#[derive(Debug, Clone)]
pub struct AreaLayer {
    /// Display name used in the chart legend.
    pub name: String,
    /// Y values sampled at uniform X intervals.
    pub values: Vec<f32>,
    /// Fill colour for the area region.
    pub color: Color,
}
impl AreaChart {
    /// Create an empty area chart with the given config and Y max of 100.0.
    pub fn new(config: ChartConfig) -> Self {
        Self {
            config,
            layers: Vec::new(),
            y_max: 100.0,
        }
    }
    /// Append a named area layer; `values` are sampled at uniform X intervals across the chart width.
    pub fn add_layer(&mut self, name: &str, values: &[f32], color: Color) {
        self.layers.push(AreaLayer {
            name: name.to_string(),
            values: values.to_vec(),
            color,
        });
    }
    /// Append one area layer from a dataframe column and return the number of values copied.
    pub fn add_layer_from_dataframe(
        &mut self,
        name: &str,
        dataframe: &DataFrame,
        value_col: &str,
        color: Color,
        options: ChartDataFrameOptions,
    ) -> Result<usize, String> {
        let column = dataframe.get_column(ColRef::Name(value_col.to_string()))?;
        let row_count = dataframe_row_limit(dataframe, options.max_rows);
        let values = (0..row_count)
            .map(|row_index| column.get(row_index).and_then(cell_to_f32).unwrap_or(0.0))
            .collect::<Vec<_>>();
        let value_count = values.len();
        self.add_layer(name, &values, color);
        Ok(value_count)
    }
    /// Rasterise the stacked area chart into `img`, overwriting its contents.
    pub fn draw_to_image(&self, img: &mut crate::image::ImageData) {
        let cfg = &self.config;
        let (bgr, bgg, bgb) = cfg.bg_color;
        img.fill(bgr, bgg, bgb, 255);
        let legend_entries = legend_entries_from_layers(&self.layers);
        let (plot, legend_panel) = cartesian_plot_layout(cfg, &legend_entries);
        let desired_x_ticks = self
            .layers
            .first()
            .map(|layer| layer.values.len().saturating_sub(1) as u32)
            .unwrap_or(1)
            .min(8);
        let x_ticks = readable_x_tick_count(plot, desired_x_ticks, 0.0, desired_x_ticks as f32);
        let y_ticks = readable_y_tick_count(plot, 4);
        draw_grid_and_axes_in_rect(img, cfg, plot, x_ticks, y_ticks);
        let (left, right, top, bottom) = (plot.left, plot.right, plot.top, plot.bottom);
        let chart_w = (right - left).max(1) as f32;
        let chart_h = (bottom - top).max(1) as f32;
        if self.layers.is_empty() {
            return;
        }
        let n = self.layers[0].values.len().max(2);
        draw_numeric_axes(
            img,
            cfg,
            left,
            right,
            top,
            bottom,
            readable_x_tick_count(plot, (n as u32).min(8), 0.0, (n - 1) as f32),
            y_ticks,
            0.0,
            (n - 1) as f32,
            0.0,
            self.y_max,
        );
        for x_px in left..right {
            let t = (x_px - left) as f32 / chart_w;
            let idx_f = t * (n - 1) as f32;
            let idx0 = (idx_f as usize).min(n.saturating_sub(2));
            let frac = idx_f - idx0 as f32;
            let mut cumulative = 0.0f32;
            let mut prev_y = bottom;
            for layer in &self.layers {
                let v0 = layer.values.get(idx0).copied().unwrap_or(0.0);
                let v1 = layer.values.get(idx0 + 1).copied().unwrap_or(v0);
                let val = v0 + (v1 - v0) * frac;
                cumulative += val;
                let cur_y = bottom - (cumulative / self.y_max * chart_h) as i32;
                let cr = (layer.color.r * 255.0) as u8;
                let cg = (layer.color.g * 255.0) as u8;
                let cb = (layer.color.b * 255.0) as u8;
                for y_px in cur_y.max(top)..prev_y {
                    img.set_pixel(x_px as u32, y_px as u32, cr, cg, cb, 220);
                }
                prev_y = cur_y;
            }
        }
        if let Some(panel) = legend_panel {
            draw_series_legend(img, cfg, panel, &legend_entries);
        }
        draw_chart_title(img, cfg, left + 10, 10);
    }
}
