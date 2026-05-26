//! Scatter plot renderer: (x, y) point series showing distribution and correlation.
//!
//! - Rasterises a `ScatterChartSpec` into an RGBA pixel buffer.
//! - Each point is drawn as a filled circle; radius and colour are per-series.
//! - Axes are auto-ranged or clamped to user-supplied min/max bounds.
//! - Owned by `lurek.charts.scatter`; output is uploaded as a texture.

use crate::charts::config::{ChartConfig, ChartSeries};
use crate::charts::render_utils::{
    auto_range, draw_circle_filled, draw_line, fill_buffer, world_to_screen,
};

/// A scatter plot that renders data points as filled circles.
#[derive(Debug, Clone)]
pub struct ScatterPlot {
    /// Chart appearance configuration.
    pub config: ChartConfig,
    /// Data series to plot.
    series: Vec<ChartSeries>,
    /// Radius of each dot in pixels.
    dot_radius: f32,
}

impl ScatterPlot {
    /// Create a new scatter plot with the given configuration.
    pub fn new(config: ChartConfig) -> Self {
        Self {
            config,
            series: Vec::new(),
            dot_radius: 4.0,
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

    /// Set the scatter dot radius in pixels.
    pub fn set_dot_radius(&mut self, r: f32) {
        self.dot_radius = r.max(1.0);
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

        // Draw each series as dots.
        for s in &self.series {
            for &(x, y) in &s.data {
                let sx = plot_x + world_to_screen(x, min_x, max_x, plot_w);
                let sy = plot_y + plot_h - world_to_screen(y, min_y, max_y, plot_h);
                draw_circle_filled(buffer, w, h, sx, sy, self.dot_radius, s.color);
            }
        }
    }
}
