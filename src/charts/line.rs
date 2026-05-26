//! Line chart renderer: connected data-point series over time or categories.
//!
//! - Rasterises a `LineChartSpec` into an RGBA pixel buffer.
//! - Supports multiple named series with per-series colour and line width.
//! - Pixel coordinates are mapped via `render_utils::world_to_screen`.
//! - Owned by `lurek.charts.line`; result is uploaded as a texture each frame.

use crate::charts::config::{ChartConfig, ChartSeries};
use crate::charts::render_utils::{
    auto_range, draw_circle_filled, draw_line, fill_buffer, world_to_screen,
};

/// A line chart that renders one or more series as connected polylines.
#[derive(Debug, Clone)]
pub struct LineChart {
    /// Chart appearance configuration.
    pub config: ChartConfig,
    /// Data series to plot.
    series: Vec<ChartSeries>,
}

impl LineChart {
    /// Create a new line chart with the given configuration.
    pub fn new(config: ChartConfig) -> Self {
        Self {
            config,
            series: Vec::new(),
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

        let (min_x, max_x, min_y, max_y) = auto_range(&self.series);

        // Draw grid lines.
        if self.config.show_grid {
            let grid_lines = 5u32;
            for i in 0..=grid_lines {
                let frac = i as f32 / grid_lines as f32;
                // Horizontal grid line.
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
                // Vertical grid line.
                let gx = plot_x + plot_w * frac;
                draw_line(
                    buffer,
                    w,
                    h,
                    gx,
                    plot_y,
                    gx,
                    plot_y + plot_h,
                    self.config.grid_color,
                );
            }
        }

        // Draw axes.
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

        // Draw each series.
        for s in &self.series {
            if s.data.is_empty() {
                continue;
            }

            let to_screen = |x: f32, y: f32| -> (f32, f32) {
                let sx = plot_x + world_to_screen(x, min_x, max_x, plot_w);
                let sy = plot_y + plot_h - world_to_screen(y, min_y, max_y, plot_h);
                (sx, sy)
            };

            // Draw connecting lines.
            for pair in s.data.windows(2) {
                let (sx0, sy0) = to_screen(pair[0].0, pair[0].1);
                let (sx1, sy1) = to_screen(pair[1].0, pair[1].1);
                draw_line(buffer, w, h, sx0, sy0, sx1, sy1, s.color);
            }

            // Draw dots at data points.
            for &(x, y) in &s.data {
                let (sx, sy) = to_screen(x, y);
                draw_circle_filled(buffer, w, h, sx, sy, 3.0, s.color);
            }
        }
    }
}
