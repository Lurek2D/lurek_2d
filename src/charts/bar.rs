//! Bar chart renderer: vertical or horizontal grouped/stacked bars.
//!
//! - Rasterises a `BarChartSpec` into an RGBA pixel buffer.
//! - Supports grouped and stacked layouts; bar width and gap are configurable.
//! - Uses `render_utils::draw_rect_filled` for individual bar segments.
//! - Owned by `lurek.charts.bar`; output is uploaded as a per-frame texture.

use crate::charts::config::{ChartConfig, ChartSeries};
use crate::charts::render_utils::{
    auto_range, draw_line, draw_rect_filled, fill_buffer, world_to_screen,
};

/// A bar chart that renders series as grouped vertical bars.
#[derive(Debug, Clone)]
pub struct BarChart {
    /// Chart appearance configuration.
    pub config: ChartConfig,
    /// Data series to plot.
    series: Vec<ChartSeries>,
    /// Width of each bar in pixels.
    bar_width: f32,
    /// Gap between bar groups in pixels.
    gap: f32,
}

impl BarChart {
    /// Create a new bar chart with the given configuration.
    pub fn new(config: ChartConfig) -> Self {
        Self {
            config,
            series: Vec::new(),
            bar_width: 20.0,
            gap: 4.0,
        }
    }

    /// Add a data series to the chart.
    pub fn add_series(&mut self, series: ChartSeries) {
        self.series.push(series);
    }

    /// Remove all series from the chart.
    pub fn clear(&mut self) {
        self.series.clear();
    }

    /// Set the individual bar width in pixels.
    pub fn set_bar_width(&mut self, width: f32) {
        self.bar_width = width.max(1.0);
    }

    /// Render the chart into an RGBA8 pixel buffer.
    ///
    /// The buffer must be exactly `width * height * 4` bytes.
    pub fn render(&self, buffer: &mut [u8]) {
        let w = self.config.width;
        let h = self.config.height;

        fill_buffer(buffer, self.config.bg_color);

        let margin = &self.config.margin;
        let plot_x = margin.left;
        let plot_y = margin.top;
        let plot_w = w as f32 - margin.left - margin.right;
        let plot_h = h as f32 - margin.top - margin.bottom;

        if plot_w <= 0.0 || plot_h <= 0.0 {
            return;
        }

        let (_, _, min_y, max_y) = auto_range(&self.series);
        // Ensure y-axis starts at zero for bar charts when all values are positive.
        let min_y = if min_y > 0.0 { 0.0 } else { min_y };

        // Draw grid lines.
        if self.config.show_grid {
            let grid_lines = 5u32;
            for i in 0..=grid_lines {
                let frac = i as f32 / grid_lines as f32;
                let gy = plot_y + plot_h * (1.0 - frac);
                draw_line(
                    buffer,
                    w,
                    h,
                    plot_x,
                    gy,
                    plot_x + plot_w,
                    gy,
                    self.config.grid_color,
                );
            }
        }

        // Draw axes.
        let baseline_y = plot_y + plot_h - world_to_screen(0.0_f32.max(min_y), min_y, max_y, plot_h);
        draw_line(
            buffer,
            w,
            h,
            plot_x,
            plot_y + plot_h,
            plot_x + plot_w,
            plot_y + plot_h,
            self.config.axis_color,
        );
        draw_line(
            buffer,
            w,
            h,
            plot_x,
            plot_y,
            plot_x,
            plot_y + plot_h,
            self.config.axis_color,
        );

        // Determine total number of data points across all series.
        let max_points = self.series.iter().map(|s| s.data.len()).max().unwrap_or(0);
        if max_points == 0 {
            return;
        }

        let num_series = self.series.len() as f32;
        let group_width = num_series * self.bar_width + (num_series - 1.0).max(0.0) * self.gap;
        let step = plot_w / max_points as f32;

        for (si, s) in self.series.iter().enumerate() {
            for (di, &(_x, y)) in s.data.iter().enumerate() {
                let group_center = plot_x + step * (di as f32 + 0.5);
                let bar_x = group_center - group_width * 0.5
                    + si as f32 * (self.bar_width + self.gap);

                let bar_top =
                    plot_y + plot_h - world_to_screen(y, min_y, max_y, plot_h);
                let bar_bottom = baseline_y;

                let (draw_y, draw_h) = if bar_top < bar_bottom {
                    (bar_top as u32, (bar_bottom - bar_top) as u32)
                } else {
                    (bar_bottom as u32, (bar_top - bar_bottom) as u32)
                };

                draw_rect_filled(
                    buffer,
                    w,
                    bar_x as u32,
                    draw_y,
                    self.bar_width as u32,
                    draw_h,
                    s.color,
                );
            }
        }
    }
}
