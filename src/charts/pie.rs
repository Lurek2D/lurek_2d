//! Pie chart renderer: proportional slice segments from a single data series.
//!
//! - Rasterises a `PieChartSpec` into an RGBA pixel buffer using arc fill.
//! - Slice angles are computed from normalised values; labels are optional.
//! - A configurable donut-hole radius converts the pie into a ring chart.
//! - Owned by `lurek.charts.pie`; output is uploaded as a texture.

use crate::charts::config::{ChartConfig, ChartDataFrameOptions};
use crate::charts::render_utils::{fill_buffer, set_pixel};
use crate::color::Color;
use crate::dataframe::frame::DataFrame;
use crate::image::ImageData;

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

    /// Add a new data slice to the pie chart using a `Color`.
    pub fn add_segment(&mut self, label: &str, value: f32, color: Color) {
        self.slices.push(PieSlice {
            label: label.to_owned(),
            value,
            color: [color.r, color.g, color.b, color.a],
        });
    }

    /// Add slices from a DataFrame.  One slice per row; colors auto-assigned from palette.
    pub fn add_segments_from_dataframe(
        &mut self,
        df: &DataFrame,
        label_col: &str,
        value_col: &str,
        opts: ChartDataFrameOptions,
    ) -> Result<usize, String> {
        use crate::dataframe::frame::{CellValue, ColRef};
        // Simple palette
        const PALETTE: [[f32; 4]; 8] = [
            [0.94, 0.28, 0.24, 1.0],
            [0.13, 0.59, 0.95, 1.0],
            [0.30, 0.69, 0.31, 1.0],
            [1.00, 0.76, 0.03, 1.0],
            [0.61, 0.15, 0.69, 1.0],
            [1.00, 0.34, 0.13, 1.0],
            [0.01, 0.66, 0.96, 1.0],
            [0.38, 0.49, 0.55, 1.0],
        ];
        let max = opts.max_rows.unwrap_or(usize::MAX);
        let mut count = 0usize;
        for row_idx in 0..df.nrows().min(max) {
            let label_val = df.get_value(row_idx, ColRef::Name(label_col.to_string()))?;
            let value_val = df.get_value(row_idx, ColRef::Name(value_col.to_string()))?;
            let label = match label_val {
                CellValue::Text(s) => s,
                CellValue::Number(n) => n.to_string(),
                _ => continue,
            };
            let value = match value_val {
                CellValue::Number(n) if n > 0.0 => n as f32,
                _ => continue,
            };
            let color = PALETTE[count % PALETTE.len()];
            self.slices.push(PieSlice { label, value, color });
            count += 1;
        }
        Ok(count)
    }

    /// Render the chart into an ImageData buffer.
    pub fn draw_to_image(&self, img: &mut ImageData) {
        let w = self.config.width as usize;
        let h = self.config.height as usize;
        let mut buf = vec![0u8; w * h * 4];
        self.render(&mut buf);
        let _ = img.set_raw_data(&buf);
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
