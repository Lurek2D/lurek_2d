//! This file owns bubble chart rendering for weighted point clouds, portfolio maps, and correlation dashboards.
//! It stores named `(x, y, size)` samples, maps size values to radius bounds, and draws one circle per finite sample.
//! Shared chart helpers provide cartesian axes, ticks, grids, labels, and legends while this file owns radius scaling.
//! Streaming append and max-point trimming keep live dashboards bounded for repeated 10 FPS redraws.
//! Open it when bubble-size semantics, weighted scatter ingestion, or radius defaults need to change.

use crate::charts::config::ChartConfig;
use crate::charts::render_utils::{
    annotate_cartesian_chart, auto_range, draw_circle_filled, draw_line, fill_buffer,
    trim_points_to_window,
};

#[derive(Debug, Clone)]
struct BubbleSeries {
    name: String,
    color: [f32; 4],
    points: Vec<(f32, f32, f32)>,
}

/// Bubble chart with named weighted point series.
#[derive(Debug, Clone)]
pub struct BubbleChart {
    /// Chart appearance configuration.
    pub config: ChartConfig,
    series: Vec<BubbleSeries>,
    min_radius: f32,
    max_radius: f32,
}

impl BubbleChart {
    /// Create an empty bubble chart.
    pub fn new(config: ChartConfig) -> Self {
        Self {
            config,
            series: Vec::new(),
            min_radius: 3.0,
            max_radius: 14.0,
        }
    }

    /// Add or replace a named weighted point series.
    pub fn add_series(&mut self, name: &str, points: &[(f32, f32, f32)], color: [f32; 4]) {
        let mut points: Vec<(f32, f32, f32)> = points
            .iter()
            .copied()
            .filter(|(x, y, size)| x.is_finite() && y.is_finite() && size.is_finite())
            .collect();
        trim_bubbles_to_window(&mut points, self.config.max_points);
        if let Some(series) = self.series.iter_mut().find(|series| series.name == name) {
            series.points = points;
            series.color = color;
            return;
        }
        self.series.push(BubbleSeries {
            name: name.to_string(),
            color,
            points,
        });
    }

    /// Append one weighted point to a named series.
    pub fn append_point(&mut self, name: &str, x: f32, y: f32, size: f32, color: [f32; 4]) {
        if !(x.is_finite() && y.is_finite() && size.is_finite()) {
            return;
        }
        if let Some(series) = self.series.iter_mut().find(|series| series.name == name) {
            series.points.push((x, y, size));
            trim_bubbles_to_window(&mut series.points, self.config.max_points);
            return;
        }
        self.series.push(BubbleSeries {
            name: name.to_string(),
            color,
            points: vec![(x, y, size)],
        });
    }

    /// Set the minimum and maximum rendered bubble radii in pixels.
    pub fn set_radius_range(&mut self, min_radius: f32, max_radius: f32) {
        if min_radius.is_finite() && max_radius.is_finite() && max_radius >= min_radius {
            self.min_radius = min_radius.max(1.0);
            self.max_radius = max_radius.max(self.min_radius);
        }
    }

    /// Remove all point series.
    pub fn clear(&mut self) {
        self.series.clear();
    }

    /// Render the chart into an RGBA8 pixel buffer.
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
        if plot_w <= 0.0 || plot_h <= 0.0 {
            return;
        }

        let proxy = self.proxy_series();
        let (min_x, max_x, min_y, max_y) = auto_range(&proxy);
        let mut min_size = f32::MAX;
        let mut max_size = f32::MIN;
        for series in &self.series {
            for &(_, _, size) in &series.points {
                min_size = min_size.min(size);
                max_size = max_size.max(size);
            }
        }
        if min_size == f32::MAX
            || max_size == f32::MIN
            || (max_size - min_size).abs() < f32::EPSILON
        {
            min_size = 0.0;
            max_size = 1.0;
        }

        if self.config.show_grid {
            for i in 0..=5 {
                let frac = i as f32 / 5.0;
                let gy = plot_y + plot_h * (1.0 - frac);
                let gx = plot_x + plot_w * frac;
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

        for series in &self.series {
            for &(x, y, size) in &series.points {
                let sx =
                    plot_x + crate::charts::render_utils::world_to_screen(x, min_x, max_x, plot_w);
                let sy = plot_y + plot_h
                    - crate::charts::render_utils::world_to_screen(y, min_y, max_y, plot_h);
                let t = ((size - min_size) / (max_size - min_size)).clamp(0.0, 1.0);
                let radius = self.min_radius + (self.max_radius - self.min_radius) * t;
                draw_circle_filled(buffer, w, h, sx, sy, radius, with_alpha(series.color, 0.72));
            }
        }

        let legends: Vec<(&str, [f32; 4])> = self
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
            &legends,
            None,
        );
    }

    fn proxy_series(&self) -> Vec<crate::charts::config::ChartSeries> {
        self.series
            .iter()
            .map(|series| crate::charts::config::ChartSeries {
                name: series.name.clone(),
                color: series.color,
                data: series.points.iter().map(|(x, y, _)| (*x, *y)).collect(),
            })
            .collect()
    }
}

fn trim_bubbles_to_window(points: &mut Vec<(f32, f32, f32)>, max_points: Option<usize>) {
    let mut proxy: Vec<(f32, f32)> = points.iter().map(|(x, y, _)| (*x, *y)).collect();
    trim_points_to_window(&mut proxy, max_points);
    if proxy.len() < points.len() {
        let keep = proxy.len();
        let drop_count = points.len() - keep;
        points.drain(0..drop_count);
    }
}

fn with_alpha(mut color: [f32; 4], alpha: f32) -> [f32; 4] {
    color[3] = alpha;
    color
}
