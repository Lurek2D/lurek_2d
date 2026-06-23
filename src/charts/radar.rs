//! This file owns radar/spider chart rendering for multivariate series over shared axes.
//! It stores ordered axis labels and named series values, then draws radial grid rings and closed polygons.
//! The chart can use an explicit maximum value or auto-scale from finite series samples.
//! Rendering is O(axes * series) and avoids per-pixel polygon fills so live dashboards can refresh quickly.
//! Open it when radar axis semantics, scaling, or polygon stroke behavior need to change.

use crate::charts::config::ChartConfig;
use crate::charts::render_utils::{draw_line, fill_buffer};
use crate::image::ImageData;

#[derive(Debug, Clone)]
struct RadarSeries {
    name: String,
    color: [f32; 4],
    values: Vec<f32>,
}

/// Radar chart for comparing named series across shared axes.
#[derive(Debug, Clone)]
pub struct RadarChart {
    /// Chart appearance configuration.
    pub config: ChartConfig,
    axes: Vec<String>,
    series: Vec<RadarSeries>,
    max_value: Option<f32>,
}

impl RadarChart {
    /// Create an empty radar chart.
    pub fn new(config: ChartConfig) -> Self {
        Self {
            config,
            axes: Vec::new(),
            series: Vec::new(),
            max_value: None,
        }
    }

    /// Replace the ordered axis labels.
    pub fn set_axes(&mut self, axes: Vec<String>) {
        self.axes = axes;
    }

    /// Add or replace a named radar series.
    pub fn add_series(&mut self, name: &str, values: &[f32], color: [f32; 4]) {
        let mut values: Vec<f32> = values.iter().copied().filter(|v| v.is_finite()).collect();
        if let Some(max_points) = self.config.max_points {
            if values.len() > max_points {
                let drop_count = values.len() - max_points;
                values.drain(0..drop_count);
            }
        }
        if let Some(series) = self.series.iter_mut().find(|series| series.name == name) {
            series.values = values;
            series.color = color;
            return;
        }
        self.series.push(RadarSeries {
            name: name.to_string(),
            color,
            values,
        });
    }

    /// Set an explicit maximum value for radial scaling.
    pub fn set_max_value(&mut self, value: f32) {
        if value.is_finite() && value > 0.0 {
            self.max_value = Some(value);
        }
    }

    /// Clear the explicit maximum value.
    pub fn clear_max_value(&mut self) {
        self.max_value = None;
    }

    /// Remove all axes and series.
    pub fn clear(&mut self) {
        self.axes.clear();
        self.series.clear();
        self.max_value = None;
    }

    /// Render the chart into an RGBA8 pixel buffer.
    pub fn render(&self, buffer: &mut [u8]) {
        let w = self.config.width;
        let h = self.config.height;
        fill_buffer(buffer, self.config.bg_color);
        let axis_count = self.axis_count();
        if axis_count < 3 {
            self.draw_labels(buffer);
            return;
        }

        let margin = &self.config.margin;
        let legend_reserve = if self.config.show_legend {
            self.config.legend_width
        } else {
            0.0
        };
        let plot_w = w as f32 - margin.left - margin.right - legend_reserve;
        let plot_h = h as f32 - margin.top - margin.bottom;
        if plot_w <= 0.0 || plot_h <= 0.0 {
            return;
        }
        let cx = margin.left + plot_w * 0.5;
        let cy = margin.top + plot_h * 0.5;
        let radius = plot_w.min(plot_h) * 0.42;
        let max_value = self
            .max_value
            .unwrap_or_else(|| self.auto_max_value())
            .max(1.0);

        if self.config.show_grid {
            for ring in 1..=4 {
                let r = radius * ring as f32 / 4.0;
                let points = self.ring_points(cx, cy, r, axis_count);
                draw_closed_polyline(buffer, w, h, &points, self.config.grid_color);
            }
            for (x, y) in self.ring_points(cx, cy, radius, axis_count) {
                draw_line(buffer, w, h, cx, cy, x, y, self.config.grid_color);
            }
        }

        for series in &self.series {
            let mut points = Vec::with_capacity(axis_count);
            for index in 0..axis_count {
                let value = series.values.get(index).copied().unwrap_or(0.0).max(0.0);
                let r = radius * (value / max_value).clamp(0.0, 1.0);
                let angle = -std::f32::consts::FRAC_PI_2
                    + std::f32::consts::TAU * index as f32 / axis_count as f32;
                points.push((cx + r * angle.cos(), cy + r * angle.sin()));
            }
            draw_closed_polyline(buffer, w, h, &points, series.color);
            for (x, y) in points {
                crate::charts::render_utils::draw_circle_filled(
                    buffer,
                    w,
                    h,
                    x,
                    y,
                    2.5,
                    series.color,
                );
            }
        }

        self.draw_labels(buffer);
    }

    fn axis_count(&self) -> usize {
        self.axes.len().max(
            self.series
                .iter()
                .map(|series| series.values.len())
                .max()
                .unwrap_or(0),
        )
    }

    fn auto_max_value(&self) -> f32 {
        self.series
            .iter()
            .flat_map(|series| series.values.iter().copied())
            .filter(|value| value.is_finite())
            .fold(1.0, f32::max)
    }

    fn ring_points(&self, cx: f32, cy: f32, radius: f32, axis_count: usize) -> Vec<(f32, f32)> {
        (0..axis_count)
            .map(|index| {
                let angle = -std::f32::consts::FRAC_PI_2
                    + std::f32::consts::TAU * index as f32 / axis_count as f32;
                (cx + radius * angle.cos(), cy + radius * angle.sin())
            })
            .collect()
    }

    fn draw_labels(&self, buffer: &mut [u8]) {
        let mut img = ImageData::new(self.config.width, self.config.height);
        let _ = img.set_raw_data(buffer);
        let (lr, lg, lb) = rgba_to_u8(self.config.label_color);
        if let Some(title) = self.config.title.as_deref() {
            let title_x = ((self.config.width / 2) as i32) - ((title.len() as i32 * 6) / 2);
            img.draw_label(title, title_x.max(0), 8, lr, lg, lb);
        }
        let axis_count = self.axis_count();
        if axis_count >= 3 {
            let margin = &self.config.margin;
            let legend_reserve = if self.config.show_legend {
                self.config.legend_width
            } else {
                0.0
            };
            let plot_w = self.config.width as f32 - margin.left - margin.right - legend_reserve;
            let plot_h = self.config.height as f32 - margin.top - margin.bottom;
            let cx = margin.left + plot_w * 0.5;
            let cy = margin.top + plot_h * 0.5;
            let radius = plot_w.min(plot_h) * 0.47;
            for index in 0..axis_count {
                let label = self.axes.get(index).map(String::as_str).unwrap_or("");
                if label.is_empty() {
                    continue;
                }
                let angle = -std::f32::consts::FRAC_PI_2
                    + std::f32::consts::TAU * index as f32 / axis_count as f32;
                let x = (cx + radius * angle.cos()) as i32 - (label.len() as i32 * 3);
                let y = (cy + radius * angle.sin()) as i32 - 4;
                img.draw_label(&trim_label(label, 10), x.max(0), y.max(0), lr, lg, lb);
            }
        }
        if self.config.show_legend {
            let legend_x = (self.config.width as f32 - self.config.legend_width + 8.0) as i32;
            let mut legend_y = 28;
            img.draw_label("Legend", legend_x, legend_y, lr, lg, lb);
            legend_y += 14;
            for series in self.series.iter().take(8) {
                draw_color_box(
                    &mut img,
                    legend_x.max(0) as u32,
                    legend_y.max(0) as u32,
                    series.color,
                );
                img.draw_label(
                    &trim_label(&series.name, 12),
                    legend_x + 16,
                    legend_y,
                    lr,
                    lg,
                    lb,
                );
                legend_y += 12;
            }
        }
        buffer.copy_from_slice(img.as_bytes());
    }
}

fn draw_closed_polyline(
    buffer: &mut [u8],
    width: u32,
    height: u32,
    points: &[(f32, f32)],
    color: [f32; 4],
) {
    for pair in points.windows(2) {
        draw_line(
            buffer, width, height, pair[0].0, pair[0].1, pair[1].0, pair[1].1, color,
        );
    }
    if let (Some(first), Some(last)) = (points.first(), points.last()) {
        draw_line(
            buffer, width, height, last.0, last.1, first.0, first.1, color,
        );
    }
}

fn rgba_to_u8(color: [f32; 4]) -> (u8, u8, u8) {
    (
        (color[0].clamp(0.0, 1.0) * 255.0) as u8,
        (color[1].clamp(0.0, 1.0) * 255.0) as u8,
        (color[2].clamp(0.0, 1.0) * 255.0) as u8,
    )
}

fn trim_label(label: &str, max_len: usize) -> String {
    let trimmed: String = label.chars().take(max_len).collect();
    if label.chars().count() > max_len {
        format!("{trimmed}.")
    } else {
        trimmed
    }
}

fn draw_color_box(img: &mut ImageData, x: u32, y: u32, color: [f32; 4]) {
    for yy in y..y.saturating_add(8).min(img.height()) {
        for xx in x..x.saturating_add(10).min(img.width()) {
            let idx = ((yy * img.width() + xx) * 4) as usize;
            let bytes = img.as_mut_bytes();
            bytes[idx] = (color[0].clamp(0.0, 1.0) * 255.0) as u8;
            bytes[idx + 1] = (color[1].clamp(0.0, 1.0) * 255.0) as u8;
            bytes[idx + 2] = (color[2].clamp(0.0, 1.0) * 255.0) as u8;
            bytes[idx + 3] = 255;
        }
    }
}
