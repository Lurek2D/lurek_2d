//! Implements area-chart rasterization where series are rendered as filled regions over plot space. `charts/area` delivers the area implementation for the charts subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Supports overlapping and stacked accumulation modes for comparative and compositional data views. The file owns or coordinates data contracts including `AreaChart`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Maps data coordinates into pixel coordinates through shared chart-space transform helpers. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `add_series`, `add_layer`, `add_layer_from_dataframe`, `draw_to_image`, `clear`, and 4 more stays attached to the local data model and invariants.
//! Produces RGBA buffers that downstream systems upload as textures for runtime presentation. Runtime integration reaches sibling engine areas through crate modules `charts`, `color`, `dataframe`, `image`, which explains the subsystem dependencies an agent should inspect before changing behavior.
//! Integrates optional DataFrame extraction paths for column-driven area plotting workflows. External integration uses no named public items, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

use crate::charts::config::{ChartConfig, ChartDataFrameOptions, ChartSeries};
use crate::charts::render_utils::{
    annotate_cartesian_chart, auto_range, draw_line, fill_buffer, set_pixel, trim_points_to_window,
    world_to_screen,
};
use crate::color::Color;
use crate::dataframe::frame::DataFrame;
use crate::image::ImageData;

/// A stacked area chart that renders cumulative filled regions.
#[derive(Debug, Clone)]
pub struct AreaChart {
    /// Chart appearance configuration.
    pub config: ChartConfig,
    /// Data series to stack and fill.
    series: Vec<ChartSeries>,
    /// Y-axis maximum (0 = auto).
    pub y_max: f32,
}

impl AreaChart {
    /// Create a new area chart with the given configuration.
    pub fn new(config: ChartConfig) -> Self {
        Self {
            config,
            series: Vec::new(),
            y_max: 0.0,
        }
    }

    /// Add a data series to the chart (drawn stacked above previous series).
    pub fn add_series(&mut self, series: ChartSeries) {
        let mut series = series;
        trim_points_to_window(&mut series.data, self.config.max_points);
        self.series.push(series);
    }

    /// Add a named layer by values array and color.
    pub fn add_layer(&mut self, name: &str, vals: &[f32], color: Color) {
        self.series.push(ChartSeries {
            name: name.to_string(),
            color: [color.r, color.g, color.b, color.a],
            data: vals
                .iter()
                .enumerate()
                .map(|(i, &v)| (i as f32, v))
                .collect(),
        });
    }

    /// Add a layer from a DataFrame column.
    pub fn add_layer_from_dataframe(
        &mut self,
        name: &str,
        df: &DataFrame,
        value_col: &str,
        color: Color,
        opts: ChartDataFrameOptions,
    ) -> Result<usize, String> {
        use crate::dataframe::frame::{CellValue, ColRef};
        let max = opts.max_rows.unwrap_or(usize::MAX);
        let mut pts: Vec<(f32, f32)> = Vec::new();
        for row_idx in 0..df.nrows().min(max) {
            let val = df.get_value(row_idx, ColRef::Name(value_col.to_string()))?;
            let v = match val {
                CellValue::Number(n) => n as f32,
                _ => 0.0,
            };
            pts.push((row_idx as f32, v));
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

    /// Return all chart series for inspection helpers.
    pub fn series(&self) -> &[ChartSeries] {
        &self.series
    }

    /// Append one point to a named series, creating the series when needed.
    pub fn append_point(&mut self, name: &str, x: f32, y: f32, color: Color) {
        if !x.is_finite() || !y.is_finite() {
            return;
        }
        if let Some(series) = self.series.iter_mut().find(|series| series.name == name) {
            series.data.push((x, y));
            trim_points_to_window(&mut series.data, self.config.max_points);
            return;
        }
        self.add_series(ChartSeries {
            name: name.to_string(),
            color: [color.r, color.g, color.b, color.a],
            data: vec![(x, y)],
        });
    }

    /// Set the streaming window size and trim all series immediately.
    pub fn set_max_points(&mut self, max_points: Option<usize>) {
        self.config.max_points = max_points;
        for series in &mut self.series {
            trim_points_to_window(&mut series.data, self.config.max_points);
        }
    }

    /// Render the chart into an RGBA8 pixel buffer.
    ///
    /// The buffer must be exactly `width * height * 4` bytes.
    pub fn render(&self, buffer: &mut [u8]) {
        let w = self.config.width;
        let h = self.config.height;

        fill_buffer(buffer, self.config.bg_color);

        let margin = &self.config.margin;
        let legend_reserve = if self.config.show_legend {
            self.config.legend_width
        } else {
            0.0
        };
        let plot_x = margin.left;
        let plot_y = margin.top;
        let plot_w = w as f32 - margin.left - margin.right - legend_reserve;
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
        let max_y = if self.y_max > min_y {
            self.y_max
        } else if stacked_max > 0.0 {
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

                    let sy_top = (plot_y + plot_h - world_to_screen(top_val, min_y, max_y, plot_h))
                        .round() as u32;
                    let sy_bot = (plot_y + plot_h - world_to_screen(bot_val, min_y, max_y, plot_h))
                        .round() as u32;

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

        let legend_entries: Vec<(&str, [f32; 4])> = self
            .series
            .iter()
            .map(|series| (series.name.as_str(), series.color))
            .collect();
        annotate_cartesian_chart(
            buffer,
            w,
            h,
            &self.config,
            plot_x,
            plot_y,
            plot_w,
            plot_h,
            min_x,
            max_x,
            min_y,
            max_y,
            &legend_entries,
            None,
        );
    }
}
