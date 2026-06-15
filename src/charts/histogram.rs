//! Implements histogram rasterization for distribution analysis and dashboard telemetry.
//! Buckets numeric samples into configurable bins and renders grouped bars for one or more series.
//! Supports streaming sample windows, dataframe ingestion, explicit ranges, and density mode.
//! Module API documentation
//!

use crate::charts::config::{ChartConfig, ChartDataFrameOptions};
use crate::charts::render_utils::{
    annotate_cartesian_chart, draw_line, draw_rect_filled, fill_buffer, world_to_screen,
};
use crate::color::Color;
use crate::dataframe::frame::{ColRef, DataFrame};
use crate::image::ImageData;

#[derive(Debug, Clone)]
/// TODO: add chart API documentation
pub struct HistogramSeries {
    pub name: String,
    pub color: [f32; 4],
    pub values: Vec<f32>,
}

#[derive(Debug, Clone)]
/// TODO: add chart API documentation
pub struct HistogramChart {
    pub config: ChartConfig,
    series: Vec<HistogramSeries>,
    bin_count: usize,
    x_range: Option<(f32, f32)>,
    density: bool,
}

fn trim_values_to_window(data: &mut Vec<f32>, max_points: Option<usize>) {
    let Some(max_points) = max_points else {
        return;
    };
    if max_points == 0 {
        data.clear();
        return;
    }
    if data.len() > max_points {
        let drop_count = data.len() - max_points;
        data.drain(0..drop_count);
    }
}

impl HistogramChart {
    /// TODO: add chart API documentation
    pub fn new(config: ChartConfig) -> Self {
        Self {
            config,
            series: Vec::new(),
            bin_count: 16,
            x_range: None,
            density: false,
        }
    }

    /// TODO: add chart API documentation
    pub fn add_series(&mut self, name: &str, values: &[f32], color: Color) {
        self.replace_series(name, values, color);
    }

    /// TODO: add chart API documentation
    pub fn add_series_from_dataframe(
        &mut self,
        name: &str,
        df: &DataFrame,
        value_col: &str,
        color: Color,
        opts: ChartDataFrameOptions,
    ) -> Result<usize, String> {
        let limit = opts.max_rows.unwrap_or(usize::MAX);
        let mut values = Vec::new();
        let col = df.get_column(ColRef::Name(value_col.to_string()))?;
        for cell in col.iter().take(limit) {
            if let Some(value) = cell.as_number() {
                let value = value as f32;
                if value.is_finite() {
                    values.push(value);
                }
            }
        }
        let added = values.len();
        self.replace_series(name, &values, color);
        Ok(added)
    }

    /// TODO: add chart API documentation
    pub fn replace_series(&mut self, name: &str, values: &[f32], color: Color) {
        let color = [color.r, color.g, color.b, color.a];
        let mut clean_values: Vec<f32> = values
            .iter()
            .copied()
            .filter(|value| value.is_finite())
            .collect();
        trim_values_to_window(&mut clean_values, self.config.max_points);
        if let Some(series) = self.series.iter_mut().find(|series| series.name == name) {
            series.color = color;
            series.values = clean_values;
            return;
        }
        self.series.push(HistogramSeries {
            name: name.to_string(),
            color,
            values: clean_values,
        });
    }

    /// TODO: add chart API documentation
    pub fn append_value(&mut self, name: &str, value: f32, color: Color) {
        if !value.is_finite() {
            return;
        }
        if let Some(series) = self.series.iter_mut().find(|series| series.name == name) {
            series.values.push(value);
            trim_values_to_window(&mut series.values, self.config.max_points);
            return;
        }
        self.series.push(HistogramSeries {
            name: name.to_string(),
            color: [color.r, color.g, color.b, color.a],
            values: vec![value],
        });
    }

    /// TODO: add chart API documentation
    pub fn clear(&mut self) {
        self.series.clear();
    }

    /// TODO: add chart API documentation
    pub fn series(&self) -> &[HistogramSeries] {
        &self.series
    }

    /// TODO: add chart API documentation
    pub fn set_bin_count(&mut self, bins: usize) {
        self.bin_count = bins.max(1);
    }

    /// TODO: add chart API documentation
    pub fn set_range(&mut self, min: f32, max: f32) {
        if min.is_finite() && max.is_finite() && max > min {
            self.x_range = Some((min, max));
        }
    }

    /// TODO: add chart API documentation
    pub fn clear_range(&mut self) {
        self.x_range = None;
    }

    /// TODO: add chart API documentation
    pub fn set_density(&mut self, density: bool) {
        self.density = density;
    }

    /// TODO: add chart API documentation
    pub fn set_max_points(&mut self, max_points: Option<usize>) {
        self.config.max_points = max_points;
        for series in &mut self.series {
            trim_values_to_window(&mut series.values, self.config.max_points);
        }
    }

    /// TODO: add chart API documentation
    pub fn draw_to_image(&self, img: &mut ImageData) {
        self.render(img.as_mut_bytes());
    }

    /// TODO: add chart API documentation
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

        let mut found_value = false;
        let mut min_x = f32::MAX;
        let mut max_x = f32::MIN;
        for series in &self.series {
            for &value in &series.values {
                if !value.is_finite() {
                    continue;
                }
                found_value = true;
                min_x = min_x.min(value);
                max_x = max_x.max(value);
            }
        }
        if !found_value {
            return;
        }
        let (min_x, max_x) = match self.x_range {
            Some((min, max)) => (min, max),
            None => {
                if (max_x - min_x).abs() < f32::EPSILON {
                    (min_x, min_x + 1.0)
                } else {
                    (min_x, max_x)
                }
            }
        };

        let bins = self.bin_count.max(1);
        let bin_width = (max_x - min_x) / bins as f32;
        if !bin_width.is_finite() || bin_width <= 0.0 {
            return;
        }

        let mut bucketed = Vec::with_capacity(self.series.len());
        let mut max_y = 0.0_f32;
        for series in &self.series {
            let mut counts = vec![0.0_f32; bins];
            let mut sample_count = 0.0_f32;
            for &value in &series.values {
                if !value.is_finite() || value < min_x || value > max_x {
                    continue;
                }
                let normalized = ((value - min_x) / (max_x - min_x)).clamp(0.0, 1.0);
                let mut idx = (normalized * bins as f32).floor() as usize;
                if idx >= bins {
                    idx = bins - 1;
                }
                counts[idx] += 1.0;
                sample_count += 1.0;
            }
            if self.density && sample_count > 0.0 {
                for count in &mut counts {
                    *count /= sample_count;
                }
            }
            for &count in &counts {
                max_y = max_y.max(count);
            }
            bucketed.push(counts);
        }
        if max_y <= 0.0 {
            max_y = 1.0;
        }

        if self.config.show_grid {
            let y_lines = self.config.y_tick_count.max(2);
            for i in 0..=y_lines {
                let frac = i as f32 / y_lines as f32;
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
            for i in 0..=bins {
                let frac = i as f32 / bins as f32;
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

        let group_step = plot_w / bins as f32;
        let series_count = self.series.len().max(1) as f32;
        let bar_band = group_step * 0.8;
        let gap = (group_step * 0.05).max(1.0);
        let per_bar = ((bar_band - gap * (series_count - 1.0)) / series_count).max(1.0);
        for (series_idx, counts) in bucketed.iter().enumerate() {
            for (bin_idx, &count) in counts.iter().enumerate() {
                if count <= 0.0 {
                    continue;
                }
                let group_x = plot_x + group_step * bin_idx as f32;
                let bar_x =
                    group_x + (group_step - bar_band) * 0.5 + series_idx as f32 * (per_bar + gap);
                let bar_top = plot_y + plot_h - world_to_screen(count, 0.0, max_y, plot_h);
                let bar_height = (plot_y + plot_h - bar_top).max(1.0);
                draw_rect_filled(
                    buffer,
                    w,
                    bar_x.max(0.0) as u32,
                    bar_top.max(0.0) as u32,
                    per_bar.ceil() as u32,
                    bar_height.ceil() as u32,
                    self.series[series_idx].color,
                );
            }
        }

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
            0.0,
            max_y,
            &legend_entries,
            None,
        );
    }
}
