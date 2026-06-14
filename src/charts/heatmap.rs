//! Implements heatmap rasterization for matrix-style ML and dashboard views.
//! Maps matrix values to a configurable color ramp and annotates row/column labels.
//! Supports direct matrix updates, per-cell streaming changes, and dataframe pivot ingestion.

use crate::charts::config::{ChartConfig, ChartDataFrameOptions};
use crate::charts::render_utils::{draw_line, draw_rect_filled, fill_buffer, set_pixel};
use crate::dataframe::frame::{CellValue, ColRef, DataFrame};
use crate::image::ImageData;

#[derive(Debug, Clone)]
pub struct HeatmapChart {
    pub config: ChartConfig,
    rows: usize,
    cols: usize,
    values: Vec<f32>,
    row_labels: Vec<String>,
    col_labels: Vec<String>,
    value_range: Option<(f32, f32)>,
    low_color: [f32; 4],
    high_color: [f32; 4],
    show_values: bool,
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

fn format_value(value: f32) -> String {
    if value.abs() >= 1000.0 {
        format!("{value:.0}")
    } else if (value - value.round()).abs() < 0.05 {
        format!("{:.0}", value.round())
    } else if value.abs() >= 100.0 {
        format!("{value:.1}")
    } else {
        format!("{value:.2}")
    }
}

fn lerp_color(a: [f32; 4], b: [f32; 4], t: f32) -> [f32; 4] {
    [
        a[0] + (b[0] - a[0]) * t,
        a[1] + (b[1] - a[1]) * t,
        a[2] + (b[2] - a[2]) * t,
        a[3] + (b[3] - a[3]) * t,
    ]
}

impl HeatmapChart {
    pub fn new(config: ChartConfig) -> Self {
        Self {
            config,
            rows: 0,
            cols: 0,
            values: Vec::new(),
            row_labels: Vec::new(),
            col_labels: Vec::new(),
            value_range: None,
            low_color: [0.16, 0.34, 0.84, 1.0],
            high_color: [0.90, 0.20, 0.24, 1.0],
            show_values: false,
        }
    }

    pub fn resize(&mut self, rows: usize, cols: usize) {
        self.rows = rows;
        self.cols = cols;
        self.values.resize(rows.saturating_mul(cols), 0.0);
        self.row_labels.resize(rows, String::new());
        self.col_labels.resize(cols, String::new());
    }

    pub fn set_matrix(
        &mut self,
        rows: usize,
        cols: usize,
        values: Vec<f32>,
        row_labels: Vec<String>,
        col_labels: Vec<String>,
    ) {
        self.rows = rows;
        self.cols = cols;
        self.values = values;
        self.row_labels = row_labels;
        self.col_labels = col_labels;
        self.row_labels.resize(rows, String::new());
        self.col_labels.resize(cols, String::new());
        self.values.resize(rows.saturating_mul(cols), 0.0);
    }

    pub fn set_matrix_from_dataframe(
        &mut self,
        df: &DataFrame,
        row_col: &str,
        col_col: &str,
        value_col: &str,
        opts: ChartDataFrameOptions,
    ) -> Result<usize, String> {
        let limit = df.nrows().min(opts.max_rows.unwrap_or(usize::MAX));
        let mut row_labels = Vec::<String>::new();
        let mut col_labels = Vec::<String>::new();
        let mut entries = Vec::<(usize, usize, f32)>::new();

        for row_idx in 0..limit {
            let row_label = format!(
                "{}",
                df.get_value(row_idx, ColRef::Name(row_col.to_string()))?
            );
            let col_label = format!(
                "{}",
                df.get_value(row_idx, ColRef::Name(col_col.to_string()))?
            );
            let value = match df.get_value(row_idx, ColRef::Name(value_col.to_string()))? {
                CellValue::Number(value) if (value as f32).is_finite() => value as f32,
                _ => continue,
            };

            let row_index = match row_labels.iter().position(|existing| existing == &row_label) {
                Some(index) => index,
                None => {
                    row_labels.push(row_label);
                    row_labels.len() - 1
                }
            };
            let col_index = match col_labels.iter().position(|existing| existing == &col_label) {
                Some(index) => index,
                None => {
                    col_labels.push(col_label);
                    col_labels.len() - 1
                }
            };
            entries.push((row_index, col_index, value));
        }

        self.resize(row_labels.len(), col_labels.len());
        self.row_labels = row_labels;
        self.col_labels = col_labels;
        for (row_index, col_index, value) in entries {
            let idx = row_index * self.cols + col_index;
            if let Some(cell) = self.values.get_mut(idx) {
                *cell += value;
            }
        }
        Ok(limit.min(self.values.len()))
    }

    pub fn set_cell(&mut self, row: usize, col: usize, value: f32) {
        if row >= self.rows || col >= self.cols || !value.is_finite() {
            return;
        }
        let idx = row * self.cols + col;
        if let Some(cell) = self.values.get_mut(idx) {
            *cell = value;
        }
    }

    pub fn clear(&mut self) {
        self.rows = 0;
        self.cols = 0;
        self.values.clear();
        self.row_labels.clear();
        self.col_labels.clear();
    }

    pub fn set_row_labels(&mut self, labels: Vec<String>) {
        self.row_labels = labels;
        self.row_labels.resize(self.rows, String::new());
    }

    pub fn set_col_labels(&mut self, labels: Vec<String>) {
        self.col_labels = labels;
        self.col_labels.resize(self.cols, String::new());
    }

    pub fn set_value_range(&mut self, min: f32, max: f32) {
        if min.is_finite() && max.is_finite() && max > min {
            self.value_range = Some((min, max));
        }
    }

    pub fn clear_value_range(&mut self) {
        self.value_range = None;
    }

    pub fn set_color_range(&mut self, low: [f32; 4], high: [f32; 4]) {
        self.low_color = low;
        self.high_color = high;
    }

    pub fn set_show_values(&mut self, show_values: bool) {
        self.show_values = show_values;
    }

    pub fn draw_to_image(&self, img: &mut ImageData) {
        self.render(img.as_mut_bytes());
    }

    pub fn render(&self, buffer: &mut [u8]) {
        let width = self.config.width;
        let height = self.config.height;
        fill_buffer(buffer, self.config.bg_color);

        if self.rows == 0 || self.cols == 0 {
            return;
        }

        let margin = &self.config.margin;
        let legend_reserve = if self.config.show_legend {
            self.config.legend_width
        } else {
            0.0
        };
        let plot_x = margin.left;
        let plot_y = margin.top;
        let plot_w = width as f32 - margin.left - margin.right - legend_reserve;
        let plot_h = height as f32 - margin.top - margin.bottom;
        if plot_w <= 0.0 || plot_h <= 0.0 {
            return;
        }

        let (mut min_value, mut max_value) = self.value_range.unwrap_or((f32::MAX, f32::MIN));
        if self.value_range.is_none() {
            for &value in &self.values {
                if !value.is_finite() {
                    continue;
                }
                min_value = min_value.min(value);
                max_value = max_value.max(value);
            }
            if min_value == f32::MAX || max_value == f32::MIN {
                min_value = 0.0;
                max_value = 1.0;
            }
        }
        if (max_value - min_value).abs() < f32::EPSILON {
            max_value = min_value + 1.0;
        }

        let cell_w = plot_w / self.cols as f32;
        let cell_h = plot_h / self.rows as f32;
        for row in 0..self.rows {
            for col in 0..self.cols {
                let idx = row * self.cols + col;
                let value = self.values.get(idx).copied().unwrap_or(0.0);
                let t = if value.is_finite() {
                    ((value - min_value) / (max_value - min_value)).clamp(0.0, 1.0)
                } else {
                    0.0
                };
                let color = lerp_color(self.low_color, self.high_color, t);
                let x = plot_x + cell_w * col as f32;
                let y = plot_y + cell_h * row as f32;
                draw_rect_filled(
                    buffer,
                    width,
                    x.max(0.0) as u32,
                    y.max(0.0) as u32,
                    cell_w.ceil().max(1.0) as u32,
                    cell_h.ceil().max(1.0) as u32,
                    color,
                );
            }
        }

        if self.config.show_grid {
            for row in 0..=self.rows {
                let y = plot_y + cell_h * row as f32;
                draw_line(buffer, width, height, plot_x, y, plot_x + plot_w, y, self.config.grid_color);
            }
            for col in 0..=self.cols {
                let x = plot_x + cell_w * col as f32;
                draw_line(buffer, width, height, x, plot_y, x, plot_y + plot_h, self.config.grid_color);
            }
        }

        draw_line(
            buffer,
            width,
            height,
            plot_x,
            plot_y,
            plot_x + plot_w,
            plot_y,
            self.config.axis_color,
        );
        draw_line(
            buffer,
            width,
            height,
            plot_x,
            plot_y + plot_h,
            plot_x + plot_w,
            plot_y + plot_h,
            self.config.axis_color,
        );
        draw_line(
            buffer,
            width,
            height,
            plot_x,
            plot_y,
            plot_x,
            plot_y + plot_h,
            self.config.axis_color,
        );
        draw_line(
            buffer,
            width,
            height,
            plot_x + plot_w,
            plot_y,
            plot_x + plot_w,
            plot_y + plot_h,
            self.config.axis_color,
        );

        let mut img = ImageData::new(width, height);
        let _ = img.set_raw_data(buffer);
        let (lr, lg, lb) = rgba_to_u8(self.config.label_color);

        if let Some(title) = self.config.title.as_deref() {
            let title_x = ((width / 2) as i32) - ((title.len() as i32 * 6) / 2);
            img.draw_label(title, title_x.max(0), 8, lr, lg, lb);
        }

        for (row, label) in self.row_labels.iter().enumerate().take(self.rows) {
            if label.is_empty() {
                continue;
            }
            let short = trim_label(label, 10);
            let y = (plot_y + cell_h * row as f32 + cell_h * 0.5 - 4.0) as i32;
            img.draw_label(&short, 4, y.max(0), lr, lg, lb);
        }

        for (col, label) in self.col_labels.iter().enumerate().take(self.cols) {
            if label.is_empty() {
                continue;
            }
            let short = trim_label(label, 10);
            let x = (plot_x + cell_w * col as f32 + cell_w * 0.5 - (short.len() as f32 * 3.0)) as i32;
            let y = (plot_y + plot_h + 8.0) as i32;
            img.draw_label(&short, x.max(0), y.max(0), lr, lg, lb);
        }

        if self.show_values && cell_w >= 20.0 && cell_h >= 12.0 {
            for row in 0..self.rows {
                for col in 0..self.cols {
                    let idx = row * self.cols + col;
                    let value = self.values.get(idx).copied().unwrap_or(0.0);
                    let label = trim_label(&format_value(value), 6);
                    let x =
                        (plot_x + cell_w * col as f32 + cell_w * 0.5 - (label.len() as f32 * 3.0)) as i32;
                    let y = (plot_y + cell_h * row as f32 + cell_h * 0.5 - 4.0) as i32;
                    img.draw_label(&label, x.max(0), y.max(0), lr, lg, lb);
                }
            }
        }

        if self.config.show_legend && legend_reserve > 16.0 {
            let legend_x = (width as f32 - legend_reserve + 10.0).max(plot_x + plot_w + 8.0) as i32;
            let legend_top = plot_y.max(0.0) as u32 + 16;
            let legend_bottom = (plot_y + plot_h).max(0.0) as u32;
            img.draw_label("Scale", legend_x, (legend_top as i32 - 12).max(0), lr, lg, lb);
            if legend_bottom > legend_top {
                for py in legend_top..legend_bottom {
                    let frac = 1.0 - (py - legend_top) as f32 / (legend_bottom - legend_top) as f32;
                    let color = lerp_color(self.low_color, self.high_color, frac);
                    for px in legend_x.max(0) as u32..(legend_x + 12).max(0) as u32 {
                        if px < width && py < height {
                            set_pixel(img.as_mut_bytes(), width, px, py, color);
                        }
                    }
                }
                img.draw_label(&format_value(max_value), legend_x + 18, legend_top as i32, lr, lg, lb);
                img.draw_label(
                    &format_value(min_value),
                    legend_x + 18,
                    (legend_bottom as i32 - 8).max(0),
                    lr,
                    lg,
                    lb,
                );
            }
        }

        buffer.copy_from_slice(img.as_bytes());
    }
}
