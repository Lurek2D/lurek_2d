//! Area chart renderer: filled regions below one or more line series.
//!
//! - Rasterises each series into an RGBA pixel buffer via `render_area_chart`.
//! - Supports stacked and overlapping fill modes with per-series alpha.
//! - Delegates coordinate mapping to `charts::render_utils::world_to_screen`.
//! - Owned by `lurek.charts.area` Lua API; output is uploaded as a texture.

use crate::charts::config::{ChartConfig, ChartSeries};
use crate::charts::render_utils::{
    auto_range, draw_line, fill_buffer, set_pixel, world_to_screen,
};

/// A stacked area chart that renders cumulative filled regions.
#[derive(Debug, Clone)]
pub struct AreaChart {
    /// Chart appearance configuration.
    pub config: ChartConfig,
    /// Data series to stack and fill.
    series: Vec<ChartSeries>,
}

impl AreaChart {
    /// Create a new area chart with the given configuration.
    pub fn new(config: ChartConfig) -> Self {
        Self {
            config,
            series: Vec::new(),
        }
    }

    /// Add a data series to the chart (drawn stacked above previous series).
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

        if plot_w <= 0.0 || plot_h <= 0.0 || self.series.is_empty() {
            return;
        }

        // Compute combined y-range for stacked values.
        let (min_x, max_x, _, _) = auto_range(&self.series);

        // Compute stacked maximums for y-range.
        let max_points = self.series.iter().map(|s| s.data.len()).max().unwrap_or(0);
        let mut stacked_max: f32 = 0.0;
        let mut stacked_values = vec![vec![0.0_f32; max_points]; self.series.len()];

        for (si, s) in self.series.iter().enumerate() {
            for (di, &(_x, y)) in s.data.iter().enumerate() {
                let base = if si > 0 {
                    stacked_values[si - 1].get(di).copied().unwrap_or(0.0)
                } else {
                    0.0
                };
                let val = base + y;
                stacked_values[si][di] = val;
                if val > stacked_max {
                    stacked_max = val;
                }
            }
        }

        let min_y = 0.0_f32;
        let max_y = if stacked_max > 0.0 {
            stacked_max
        } else {
            1.0
        };

        // Draw grid.
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

        // Draw filled areas from top series to bottom (painter's algorithm: bottom first).
        for si in 0..self.series.len() {
            let s = &self.series[si];
            let point_count = s.data.len();
            if point_count == 0 {
                continue;
            }

            // For each column (x pixel), fill between bottom and top y.
            for di in 0..point_count.saturating_sub(1) {
                let x0_data = s.data[di].0;
                let x1_data = s.data[di + 1].0;

                let sx0 = (plot_x + world_to_screen(x0_data, min_x, max_x, plot_w)).round() as u32;
                let sx1 = (plot_x + world_to_screen(x1_data, min_x, max_x, plot_w)).round() as u32;

                let top0 = stacked_values[si][di];
                let top1 = stacked_values[si][di + 1];
                let bot0 = if si > 0 {
                    stacked_values[si - 1].get(di).copied().unwrap_or(0.0)
                } else {
                    0.0
                };
                let bot1 = if si > 0 {
                    stacked_values[si - 1].get(di + 1).copied().unwrap_or(0.0)
                } else {
                    0.0
                };

                // Rasterize the trapezoid column by column.
                for px in sx0..=sx1.min(w - 1) {
                    let t = if sx1 > sx0 {
                        (px - sx0) as f32 / (sx1 - sx0) as f32
                    } else {
                        0.0
                    };
                    let top_val = top0 + (top1 - top0) * t;
                    let bot_val = bot0 + (bot1 - bot0) * t;

                    let sy_top =
                        (plot_y + plot_h - world_to_screen(top_val, min_y, max_y, plot_h)).round()
                            as u32;
                    let sy_bot =
                        (plot_y + plot_h - world_to_screen(bot_val, min_y, max_y, plot_h)).round()
                            as u32;

                    for py in sy_top..=sy_bot.min(h - 1) {
                        set_pixel(buffer, w, px, py, s.color);
                    }
                }
            }
        }

        // Draw axes on top.
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
    }
}
