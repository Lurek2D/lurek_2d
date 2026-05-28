//! Line chart renderer: connected data-point series over time or categories.
//!
//! - Data type: `LineChart`.
//! - Implementation: `LineChart`.

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
    /// Optional Y-axis maximum override.
    pub y_max: f32,
    /// Optional X-axis maximum override.
    pub x_max: f32,
}

impl LineChart {
    /// Create a new line chart with the given configuration.
    pub fn new(config: ChartConfig) -> Self {
        Self {
            config,
            series: Vec::new(),
            y_max: 0.0,
            x_max: 0.0,
        }
    }

    /// Add a data series (low-level: accepts a ChartSeries directly).
    pub fn push_series(&mut self, series: ChartSeries) {
        self.series.push(series);
    }

    /// Add a named series from point data and a color.
    pub fn add_series(&mut self, name: &str, pts: &[(f32, f32)], color: crate::color::Color) {
        self.push_series(ChartSeries {
            name: name.to_string(),
            color: [color.r, color.g, color.b, color.a],
            data: pts.to_vec(),
        });
    }

    /// Add a named series from dataframe columns, returning the number of points added.
    pub fn add_series_from_dataframe(
        &mut self,
        name: &str,
        df: &crate::dataframe::DataFrame,
        x_col: &str,
        y_col: &str,
        color: crate::color::Color,
        opts: crate::charts::config::ChartDataFrameOptions,
    ) -> Result<usize, String> {
        use crate::dataframe::frame::ColRef;
        let xs = df.get_column(ColRef::Name(x_col.to_string()))?;
        let ys = df.get_column(ColRef::Name(y_col.to_string()))?;
        let limit = opts.max_rows.unwrap_or(usize::MAX);
        let mut pts: Vec<(f32, f32)> = Vec::new();
        for (xc, yc) in xs.iter().zip(ys.iter()).take(limit) {
            if let (Some(x), Some(y)) = (xc.as_number(), yc.as_number()) {
                pts.push((x as f32, y as f32));
            }
        }
        let added = pts.len();
        self.push_series(ChartSeries {
            name: name.to_string(),
            color: [color.r, color.g, color.b, color.a],
            data: pts,
        });
        Ok(added)
    }

    /// Render this chart into an ImageData buffer.
    pub fn draw_to_image(&self, img: &mut crate::image::ImageData) {
        self.render(img.as_mut_bytes());
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
