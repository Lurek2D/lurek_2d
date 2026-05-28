//! Scatter plot renderer: (x, y) point series showing distribution and correlation.
//!
//! - Data type: `ScatterPlot`.
//! - Implementation: `ScatterPlot`.

use crate::charts::config::{ChartConfig, ChartDataFrameOptions, ChartSeries};
use crate::charts::render_utils::{
    auto_range, draw_circle_filled, draw_line, fill_buffer, world_to_screen,
};
use crate::color::Color;
use crate::dataframe::frame::DataFrame;
use crate::image::ImageData;

/// A scatter plot that renders data points as filled circles.
#[derive(Debug, Clone)]
pub struct ScatterPlot {
    /// Chart appearance configuration.
    pub config: ChartConfig,
    /// Data series to plot.
    series: Vec<ChartSeries>,
    /// Radius of each dot in pixels.
    dot_radius: f32,
    /// Optional explicit X-axis range.
    pub x_range: (f32, f32),
    /// Optional explicit Y-axis range.
    pub y_range: (f32, f32),
}

impl ScatterPlot {
    /// Create a new scatter plot with the given configuration.
    pub fn new(config: ChartConfig) -> Self {
        Self {
            config,
            series: Vec::new(),
            dot_radius: 4.0,
            x_range: (0.0, 0.0),
            y_range: (0.0, 0.0),
        }
    }

    /// Add a pre-built series entry directly.
    pub fn push_series_raw(&mut self, series: ChartSeries) {
        self.series.push(series);
    }

    /// Add a data series by name, points, and color.
    pub fn add_series(&mut self, name: &str, data: &[(f32, f32)], color: Color) {
        self.series.push(ChartSeries {
            name: name.to_string(),
            color: [color.r, color.g, color.b, color.a],
            data: data.to_vec(),
        });
    }

    /// Add a data series from a DataFrame, reading x and y from named columns.
    pub fn add_series_from_dataframe(
        &mut self,
        name: &str,
        df: &DataFrame,
        x_col: &str,
        y_col: &str,
        color: Color,
        opts: ChartDataFrameOptions,
    ) -> Result<usize, String> {
        use crate::dataframe::frame::{CellValue, ColRef};
        let max = opts.max_rows.unwrap_or(usize::MAX);
        let mut pts: Vec<(f32, f32)> = Vec::new();
        for row_idx in 0..df.nrows().min(max) {
            let xv = df.get_value(row_idx, ColRef::Name(x_col.to_string()))?;
            let yv = df.get_value(row_idx, ColRef::Name(y_col.to_string()))?;
            if let (CellValue::Number(x), CellValue::Number(y)) = (xv, yv) { pts.push((x as f32, y as f32)) }
        }
        let n = pts.len();
        self.series.push(ChartSeries {
            name: name.to_string(),
            color: [color.r, color.g, color.b, color.a],
            data: pts,
        });
        Ok(n)
    }

    /// Render the chart into an ImageData buffer.
    pub fn draw_to_image(&self, img: &mut ImageData) {
        let w = self.config.width as usize;
        let h = self.config.height as usize;
        let mut buf = vec![0u8; w * h * 4];
        self.render(&mut buf);
        let _ = img.set_raw_data(&buf);
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
