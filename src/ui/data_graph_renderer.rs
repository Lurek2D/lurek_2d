//! Multi-series data graph renderer with viewport coordinate mapping.
//!
//! - Data type: `GraphRenderer`.
//! - Enum: `SeriesData`.
//! - Implementations: `SeriesData`, `GraphRenderer`.

use crate::color::Color;

// ─────────────────────────────────────────────────────────────────────────────
// SeriesData
// ─────────────────────────────────────────────────────────────────────────────

/// A single named data series stored in a [`GraphRenderer`].
pub enum SeriesData {
    /// Connected line series with (x, y) data points.
    Line {
        name: String,
        points: Vec<(f32, f32)>,
        color: Color,
    },
    /// Scatter-plot series with per-dot size.
    Scatter {
        name: String,
        points: Vec<(f32, f32)>,
        color: Color,
        dot_size: f32,
    },
    /// Vertical bar series with one value per bar.
    Bar {
        name: String,
        values: Vec<f32>,
        color: Color,
    },
}

impl SeriesData {
    /// Return the series name.
    pub fn name(&self) -> &str {
        match self {
            Self::Line { name, .. } => name,
            Self::Scatter { name, .. } => name,
            Self::Bar { name, .. } => name,
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// GraphRenderer
// ─────────────────────────────────────────────────────────────────────────────

/// Lightweight renderer that stores data series and maps world↔screen coords.
///
/// It owns the raw series data and viewport/range state. Actual draw-command
/// emission is done by the UI pipeline using `build_render_commands`.
pub struct GraphRenderer {
    /// Show background grid lines.
    pub show_grid: bool,
    /// Show axis lines (x = 0 and y = 0).
    pub show_axes: bool,

    // Viewport in screen pixels.
    viewport_x: f32,
    viewport_y: f32,
    viewport_w: f32,
    viewport_h: f32,

    // World-space data range.
    x_min: f32,
    x_max: f32,
    y_min: f32,
    y_max: f32,

    // Optional cursor overlay position (world-space).
    cursor: Option<(f32, f32)>,

    series: Vec<SeriesData>,
}

impl GraphRenderer {
    /// Create a renderer with sensible defaults (full-hidden viewport, 0..1 range).
    pub fn new() -> Self {
        Self {
            show_grid: true,
            show_axes: true,
            viewport_x: 0.0,
            viewport_y: 0.0,
            viewport_w: 800.0,
            viewport_h: 600.0,
            x_min: 0.0,
            x_max: 1.0,
            y_min: 0.0,
            y_max: 1.0,
            cursor: None,
            series: Vec::new(),
        }
    }

    // ── viewport ─────────────────────────────────────────────────────────────

    /// Set the screen-pixel viewport rectangle.
    pub fn set_viewport(&mut self, x: f32, y: f32, w: f32, h: f32) {
        self.viewport_x = x;
        self.viewport_y = y;
        self.viewport_w = w;
        self.viewport_h = h;
    }

    /// Return the current viewport as `(x, y, w, h)`.
    pub fn get_viewport(&self) -> (f32, f32, f32, f32) {
        (self.viewport_x, self.viewport_y, self.viewport_w, self.viewport_h)
    }

    // ── range ─────────────────────────────────────────────────────────────────

    /// Set the world-space data range.
    pub fn set_range(&mut self, x_min: f32, x_max: f32, y_min: f32, y_max: f32) {
        self.x_min = x_min;
        self.x_max = x_max;
        self.y_min = y_min;
        self.y_max = y_max;
    }

    /// Return the current range as `(x_min, x_max, y_min, y_max)`.
    pub fn get_range(&self) -> (f32, f32, f32, f32) {
        (self.x_min, self.x_max, self.y_min, self.y_max)
    }

    /// Fit the range to the bounding box of all series data, with 10 % padding.
    ///
    /// Bar series always include `y = 0` in the range.
    pub fn auto_range(&mut self) {
        if self.series.is_empty() {
            return;
        }

        let mut xs: Vec<f32> = Vec::new();
        let mut ys: Vec<f32> = Vec::new();
        let mut include_zero_y = false;

        for s in &self.series {
            match s {
                SeriesData::Line { points, .. } | SeriesData::Scatter { points, .. } => {
                    for &(x, y) in points {
                        xs.push(x);
                        ys.push(y);
                    }
                }
                SeriesData::Bar { values, .. } => {
                    for (i, &v) in values.iter().enumerate() {
                        xs.push(i as f32);
                        ys.push(v);
                    }
                    include_zero_y = true;
                }
            }
        }

        if xs.is_empty() {
            return;
        }

        let x_min = xs.iter().cloned().fold(f32::INFINITY, f32::min);
        let x_max = xs.iter().cloned().fold(f32::NEG_INFINITY, f32::max);
        let mut y_min = ys.iter().cloned().fold(f32::INFINITY, f32::min);
        let mut y_max = ys.iter().cloned().fold(f32::NEG_INFINITY, f32::max);

        if include_zero_y {
            y_min = y_min.min(0.0);
            y_max = y_max.max(0.0);
        }

        let x_span = (x_max - x_min).abs().max(1.0);
        let y_span = (y_max - y_min).abs().max(1.0);
        let pad_x = x_span * 0.1;
        let pad_y = y_span * 0.1;

        self.x_min = x_min - pad_x;
        self.x_max = x_max + pad_x;
        self.y_min = y_min - pad_y;
        self.y_max = y_max + pad_y;
    }

    // ── coordinate mapping ────────────────────────────────────────────────────

    /// Map a world-space point to screen pixels.
    pub fn world_to_screen(&self, wx: f32, wy: f32) -> (f32, f32) {
        let range_w = self.x_max - self.x_min;
        let range_h = self.y_max - self.y_min;
        let sx = self.viewport_x + (wx - self.x_min) / range_w * self.viewport_w;
        // y-axis is flipped: world y=y_min maps to bottom of viewport
        let sy = self.viewport_y + self.viewport_h
            - (wy - self.y_min) / range_h * self.viewport_h;
        (sx, sy)
    }

    /// Map a screen-pixel point back to world space.
    pub fn screen_to_world(&self, sx: f32, sy: f32) -> (f32, f32) {
        let range_w = self.x_max - self.x_min;
        let range_h = self.y_max - self.y_min;
        let wx = self.x_min + (sx - self.viewport_x) / self.viewport_w * range_w;
        let wy = self.y_min
            + (self.viewport_y + self.viewport_h - sy) / self.viewport_h * range_h;
        (wx, wy)
    }

    // ── grid / axes toggles ───────────────────────────────────────────────────

    /// Enable or disable the background grid.
    pub fn set_show_grid(&mut self, v: bool) {
        self.show_grid = v;
    }

    /// Enable or disable axis lines.
    pub fn set_show_axes(&mut self, v: bool) {
        self.show_axes = v;
    }

    // ── cursor ────────────────────────────────────────────────────────────────

    /// Set the crosshair cursor at a world-space position.
    pub fn set_cursor_position(&mut self, x: f32, y: f32) {
        self.cursor = Some((x, y));
    }

    /// Return the cursor world position, or `None` if not set.
    pub fn get_cursor_value(&self) -> Option<(f32, f32)> {
        self.cursor
    }

    // ── series management ─────────────────────────────────────────────────────

    /// Return a slice of all stored series.
    pub fn series(&self) -> &[SeriesData] {
        &self.series
    }

    /// Return the names of all stored series.
    pub fn get_series_names(&self) -> Vec<String> {
        self.series.iter().map(|s| s.name().to_string()).collect()
    }

    /// Add a line series.
    pub fn add_line_series(&mut self, name: &str, points: Vec<(f32, f32)>, color: Color) {
        self.series.push(SeriesData::Line {
            name: name.to_string(),
            points,
            color,
        });
    }

    /// Add a scatter-plot series.
    pub fn add_scatter_series(
        &mut self,
        name: &str,
        points: Vec<(f32, f32)>,
        color: Color,
        dot_size: f32,
    ) {
        self.series.push(SeriesData::Scatter {
            name: name.to_string(),
            points,
            color,
            dot_size,
        });
    }

    /// Add a bar chart series.
    pub fn add_bar_series(&mut self, name: &str, values: Vec<f32>, color: Color) {
        self.series.push(SeriesData::Bar {
            name: name.to_string(),
            values,
            color,
        });
    }

    /// Remove the first series whose name matches. Returns `true` if removed.
    pub fn remove_series(&mut self, name: &str) -> bool {
        if let Some(idx) = self.series.iter().position(|s| s.name() == name) {
            self.series.remove(idx);
            true
        } else {
            false
        }
    }

    /// Remove all series.
    pub fn clear_series(&mut self) {
        self.series.clear();
    }
}

impl Default for GraphRenderer {
    fn default() -> Self {
        Self::new()
    }
}
