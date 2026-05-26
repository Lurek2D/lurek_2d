//! Pie chart renderer: proportional slice segments from a single data series.
//!
//! - Rasterises a `PieChartSpec` into an RGBA pixel buffer using arc fill.
//! - Slice angles are computed from normalised values; labels are optional.
//! - A configurable donut-hole radius converts the pie into a ring chart.
//! - Owned by `lurek.charts.pie`; output is uploaded as a texture.

use crate::charts::config::ChartConfig;
use crate::charts::render_utils::{fill_buffer, set_pixel};

/// A single named slice of a pie chart.
#[derive(Debug, Clone)]
pub struct PieSlice {
    /// Display label for this slice.
    pub label: String,
    /// Numeric value determining the slice's angular proportion.
    pub value: f32,
    /// Slice color (RGBA, 0.0–1.0).
    pub color: [f32; 4],
}

/// A pie chart that renders proportional slices as a filled circle.
#[derive(Debug, Clone)]
pub struct PieChart {
    /// Chart appearance configuration.
    pub config: ChartConfig,
    /// Slices to render.
    slices: Vec<PieSlice>,
}

impl PieChart {
    /// Create a new pie chart with the given configuration.
    pub fn new(config: ChartConfig) -> Self {
        Self {
            config,
            slices: Vec::new(),
        }
    }

    /// Add a new data slice to the pie chart.
    pub fn add_slice(&mut self, label: &str, value: f32, color: [f32; 4]) {
        self.slices.push(PieSlice {
            label: label.to_owned(),
            value,
            color,
        });
    }

    /// Remove all slices from the chart.
    pub fn clear(&mut self) {
        self.slices.clear();
    }

    /// Render the chart into an RGBA8 pixel buffer.
    ///
    /// The buffer must be exactly `width * height * 4` bytes.
    /// Uses per-pixel angle testing to determine slice membership.
    pub fn render(&self, buffer: &mut [u8]) {
        let w = self.config.width;
        let h = self.config.height;

        fill_buffer(buffer, self.config.bg_color);

        if self.slices.is_empty() {
            return;
        }

        let total: f32 = self.slices.iter().map(|s| s.value.max(0.0)).sum();
        if total <= 0.0 {
            return;
        }

        // Compute cumulative angles (in radians, starting from -PI/2 i.e. top).
        let mut cumulative = Vec::with_capacity(self.slices.len() + 1);
        cumulative.push(0.0_f32);
        for slice in &self.slices {
            let frac = slice.value.max(0.0) / total;
            cumulative.push(cumulative.last().unwrap() + frac * std::f32::consts::TAU);
        }

        let margin = &self.config.margin;
        let plot_w = w as f32 - margin.left - margin.right;
        let plot_h = h as f32 - margin.top - margin.bottom;
        let cx = margin.left + plot_w * 0.5;
        let cy = margin.top + plot_h * 0.5;
        let radius = plot_w.min(plot_h) * 0.45;
        let r2 = radius * radius;

        // Per-pixel rendering.
        for py in 0..h {
            for px in 0..w {
                let dx = px as f32 - cx;
                let dy = py as f32 - cy;
                if dx * dx + dy * dy > r2 {
                    continue;
                }

                // Angle from top (clockwise), mapped to [0, TAU).
                let angle = (dy.atan2(dx) + std::f32::consts::FRAC_PI_2)
                    .rem_euclid(std::f32::consts::TAU);

                // Find which slice this pixel belongs to.
                for (i, slice) in self.slices.iter().enumerate() {
                    if angle >= cumulative[i] && angle < cumulative[i + 1] {
                        set_pixel(buffer, w, px, py, slice.color);
                        break;
                    }
                }
            }
        }
    }
}
