//! This file owns box-and-whisker chart rendering for distributions, benchmark runs, and telemetry spreads.
//! It stores named sample series, computes quartiles on render, and draws whiskers, boxes, medians, and outliers.
//! Shared chart helpers provide axes, ticks, category labels, legends, and background styling for consistency.
//! The renderer sorts only per-series samples and otherwise draws O(series + samples) primitives for fast refreshes.
//! Open it when distribution statistics, outlier policy, or boxplot geometry need to change.

use crate::charts::config::ChartConfig;
use crate::charts::render_utils::{
    annotate_cartesian_chart, draw_circle_filled, draw_line, draw_rect_filled, fill_buffer,
    trim_points_to_window, world_to_screen,
};

#[derive(Debug, Clone)]
struct BoxSeries {
    name: String,
    color: [f32; 4],
    values: Vec<f32>,
}

#[derive(Debug, Clone, Copy)]
struct Stats {
    min_whisker: f32,
    q1: f32,
    median: f32,
    q3: f32,
    max_whisker: f32,
}

/// Box-and-whisker chart for one or more named distributions.
#[derive(Debug, Clone)]
pub struct BoxPlotChart {
    /// Chart appearance configuration.
    pub config: ChartConfig,
    series: Vec<BoxSeries>,
}

impl BoxPlotChart {
    /// Create an empty boxplot chart.
    pub fn new(config: ChartConfig) -> Self {
        Self {
            config,
            series: Vec::new(),
        }
    }

    /// Add or replace a named sample series.
    pub fn add_series(&mut self, name: &str, values: &[f32], color: [f32; 4]) {
        let mut values: Vec<f32> = values.iter().copied().filter(|v| v.is_finite()).collect();
        trim_value_window(&mut values, self.config.max_points);
        if let Some(series) = self.series.iter_mut().find(|series| series.name == name) {
            series.values = values;
            series.color = color;
            return;
        }
        self.series.push(BoxSeries {
            name: name.to_string(),
            color,
            values,
        });
    }

    /// Append one sample to a named series, creating it when needed.
    pub fn append_value(&mut self, name: &str, value: f32, color: [f32; 4]) {
        if !value.is_finite() {
            return;
        }
        if let Some(series) = self.series.iter_mut().find(|series| series.name == name) {
            series.values.push(value);
            trim_value_window(&mut series.values, self.config.max_points);
            return;
        }
        self.series.push(BoxSeries {
            name: name.to_string(),
            color,
            values: vec![value],
        });
    }

    /// Remove all sample series.
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

        let stats: Vec<Option<Stats>> = self
            .series
            .iter()
            .map(|series| compute_stats(&series.values))
            .collect();
        let mut min_y = f32::MAX;
        let mut max_y = f32::MIN;
        for (series, stats) in self.series.iter().zip(&stats) {
            if let Some(stats) = stats {
                min_y = min_y.min(stats.min_whisker);
                max_y = max_y.max(stats.max_whisker);
                for value in &series.values {
                    min_y = min_y.min(*value);
                    max_y = max_y.max(*value);
                }
            }
        }
        if min_y == f32::MAX || max_y == f32::MIN {
            min_y = 0.0;
            max_y = 1.0;
        }
        if (max_y - min_y).abs() < f32::EPSILON {
            max_y = min_y + 1.0;
        }

        if self.config.show_grid {
            for i in 0..=5 {
                let frac = i as f32 / 5.0;
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

        let count = self.series.len().max(1);
        let step = plot_w / count as f32;
        let box_w = (step * 0.45).max(4.0);
        for (index, (series, stats)) in self.series.iter().zip(stats).enumerate() {
            let Some(stats) = stats else {
                continue;
            };
            let cx = plot_x + step * (index as f32 + 0.5);
            let y_min = plot_y + plot_h - world_to_screen(stats.min_whisker, min_y, max_y, plot_h);
            let y_q1 = plot_y + plot_h - world_to_screen(stats.q1, min_y, max_y, plot_h);
            let y_med = plot_y + plot_h - world_to_screen(stats.median, min_y, max_y, plot_h);
            let y_q3 = plot_y + plot_h - world_to_screen(stats.q3, min_y, max_y, plot_h);
            let y_max = plot_y + plot_h - world_to_screen(stats.max_whisker, min_y, max_y, plot_h);
            let left = cx - box_w * 0.5;
            let right = cx + box_w * 0.5;
            draw_line(buffer, w, h, cx, y_max, cx, y_min, series.color);
            draw_line(buffer, w, h, left, y_max, right, y_max, series.color);
            draw_line(buffer, w, h, left, y_min, right, y_min, series.color);
            draw_rect_filled(
                buffer,
                w,
                left.max(0.0) as u32,
                y_q3.min(y_q1).max(0.0) as u32,
                box_w as u32,
                (y_q1 - y_q3).abs().max(1.0) as u32,
                with_alpha(series.color, 0.45),
            );
            draw_line(buffer, w, h, left, y_med, right, y_med, series.color);

            let iqr = stats.q3 - stats.q1;
            let low_fence = stats.q1 - 1.5 * iqr;
            let high_fence = stats.q3 + 1.5 * iqr;
            for value in &series.values {
                if *value < low_fence || *value > high_fence {
                    let y = plot_y + plot_h - world_to_screen(*value, min_y, max_y, plot_h);
                    draw_circle_filled(buffer, w, h, cx, y, 2.0, series.color);
                }
            }
        }

        let labels: Vec<String> = self
            .series
            .iter()
            .map(|series| series.name.clone())
            .collect();
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
            0.0,
            count as f32,
            min_y,
            max_y,
            &legends,
            Some(&labels),
        );
    }
}

fn trim_value_window(values: &mut Vec<f32>, max_points: Option<usize>) {
    let mut proxy: Vec<(f32, f32)> = values
        .iter()
        .enumerate()
        .map(|(i, v)| (i as f32, *v))
        .collect();
    trim_points_to_window(&mut proxy, max_points);
    values.clear();
    values.extend(proxy.into_iter().map(|(_, value)| value));
}

fn percentile(sorted: &[f32], p: f32) -> f32 {
    if sorted.is_empty() {
        return 0.0;
    }
    let pos = (sorted.len() - 1) as f32 * p;
    let lo = pos.floor() as usize;
    let hi = pos.ceil() as usize;
    if lo == hi {
        sorted[lo]
    } else {
        let t = pos - lo as f32;
        sorted[lo] * (1.0 - t) + sorted[hi] * t
    }
}

fn compute_stats(values: &[f32]) -> Option<Stats> {
    let mut sorted: Vec<f32> = values.iter().copied().filter(|v| v.is_finite()).collect();
    if sorted.is_empty() {
        return None;
    }
    sorted.sort_by(|a, b| a.partial_cmp(b).unwrap_or(std::cmp::Ordering::Equal));
    let q1 = percentile(&sorted, 0.25);
    let median = percentile(&sorted, 0.5);
    let q3 = percentile(&sorted, 0.75);
    let iqr = q3 - q1;
    let low_fence = q1 - 1.5 * iqr;
    let high_fence = q3 + 1.5 * iqr;
    let min_whisker = sorted
        .iter()
        .copied()
        .find(|value| *value >= low_fence)
        .unwrap_or(sorted[0]);
    let max_whisker = sorted
        .iter()
        .rev()
        .copied()
        .find(|value| *value <= high_fence)
        .unwrap_or(*sorted.last().unwrap());
    Some(Stats {
        min_whisker,
        q1,
        median,
        q3,
        max_whisker,
    })
}

fn with_alpha(mut color: [f32; 4], alpha: f32) -> [f32; 4] {
    color[3] = alpha;
    color
}
