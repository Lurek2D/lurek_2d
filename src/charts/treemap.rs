//! This file owns treemap chart rendering for part-to-whole dashboards and hierarchical-looking flat summaries.
//! It stores weighted labeled items, applies deterministic squarified rows, and draws colored rectangles with labels.
//! The API accepts flat items because runtime Lua callers commonly aggregate hierarchy before visualization.
//! Rendering is O(n log n) from value sorting plus rectangle fills, keeping repeated refreshes practical.
//! Open it when treemap item ingestion, squarified row packing, or label rendering need to change.

use crate::charts::config::ChartConfig;
use crate::charts::render_utils::{draw_line, draw_rect_filled, fill_buffer};
use crate::image::ImageData;

/// One weighted treemap item.
#[derive(Debug, Clone)]
pub struct TreemapItem {
    /// Display label.
    pub label: String,
    /// Nonnegative area weight.
    pub value: f32,
    /// Fill color.
    pub color: [f32; 4],
}

#[derive(Debug, Clone, Copy)]
struct Rect {
    x: f32,
    y: f32,
    w: f32,
    h: f32,
}

/// Treemap chart for weighted labeled rectangles.
#[derive(Debug, Clone)]
pub struct TreemapChart {
    /// Chart appearance configuration.
    pub config: ChartConfig,
    items: Vec<TreemapItem>,
}

impl TreemapChart {
    /// Create an empty treemap chart.
    pub fn new(config: ChartConfig) -> Self {
        Self {
            config,
            items: Vec::new(),
        }
    }

    /// Replace all treemap items.
    pub fn set_items(&mut self, items: Vec<TreemapItem>) {
        self.items = items
            .into_iter()
            .filter(|item| item.value.is_finite() && item.value > 0.0)
            .collect();
        self.trim_window();
    }

    /// Add one treemap item.
    pub fn add_item(&mut self, label: &str, value: f32, color: [f32; 4]) {
        if value.is_finite() && value > 0.0 {
            self.items.push(TreemapItem {
                label: label.to_string(),
                value,
                color,
            });
            self.trim_window();
        }
    }

    /// Remove all treemap items.
    pub fn clear(&mut self) {
        self.items.clear();
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
        let plot = Rect {
            x: margin.left,
            y: margin.top,
            w: w as f32 - margin.left - margin.right - legend_reserve,
            h: h as f32 - margin.top - margin.bottom,
        };
        if plot.w <= 0.0 || plot.h <= 0.0 {
            return;
        }

        let mut items = self.items.clone();
        items.sort_by(|a, b| {
            b.value
                .partial_cmp(&a.value)
                .unwrap_or(std::cmp::Ordering::Equal)
        });
        let total: f32 = items.iter().map(|item| item.value).sum();
        if total <= 0.0 {
            self.draw_labels(buffer, &[]);
            return;
        }
        let scale = plot.w * plot.h / total;
        let weighted: Vec<(TreemapItem, f32)> = items
            .into_iter()
            .map(|item| {
                let area = item.value * scale;
                (item, area)
            })
            .collect();
        let rects = squarify(&weighted, plot);

        for (item, rect) in &rects {
            draw_rect_filled(
                buffer,
                w,
                rect.x.max(0.0) as u32,
                rect.y.max(0.0) as u32,
                rect.w.ceil().max(1.0) as u32,
                rect.h.ceil().max(1.0) as u32,
                item.color,
            );
            draw_line(
                buffer,
                w,
                h,
                rect.x,
                rect.y,
                rect.x + rect.w,
                rect.y,
                self.config.axis_color,
            );
            draw_line(
                buffer,
                w,
                h,
                rect.x,
                rect.y,
                rect.x,
                rect.y + rect.h,
                self.config.axis_color,
            );
        }

        self.draw_labels(buffer, &rects);
    }

    fn trim_window(&mut self) {
        if let Some(max_points) = self.config.max_points {
            if self.items.len() > max_points {
                let drop_count = self.items.len() - max_points;
                self.items.drain(0..drop_count);
            }
        }
    }

    fn draw_labels(&self, buffer: &mut [u8], rects: &[(TreemapItem, Rect)]) {
        let mut img = ImageData::new(self.config.width, self.config.height);
        let _ = img.set_raw_data(buffer);
        let (lr, lg, lb) = rgba_to_u8(self.config.label_color);
        if let Some(title) = self.config.title.as_deref() {
            let title_x = ((self.config.width / 2) as i32) - ((title.len() as i32 * 6) / 2);
            img.draw_label(title, title_x.max(0), 8, lr, lg, lb);
        }
        for (item, rect) in rects {
            if rect.w >= 28.0 && rect.h >= 14.0 {
                img.draw_label(
                    &trim_label(&item.label, (rect.w / 6.0).floor().max(3.0) as usize),
                    rect.x as i32 + 4,
                    rect.y as i32 + 4,
                    lr,
                    lg,
                    lb,
                );
            }
        }
        if self.config.show_legend {
            let legend_x = (self.config.width as f32 - self.config.legend_width + 8.0) as i32;
            let mut legend_y = 28;
            img.draw_label("Legend", legend_x, legend_y, lr, lg, lb);
            legend_y += 14;
            for item in self.items.iter().take(8) {
                draw_color_box(
                    &mut img,
                    legend_x.max(0) as u32,
                    legend_y.max(0) as u32,
                    item.color,
                );
                img.draw_label(
                    &trim_label(&item.label, 12),
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

fn squarify(items: &[(TreemapItem, f32)], mut rect: Rect) -> Vec<(TreemapItem, Rect)> {
    let mut result = Vec::with_capacity(items.len());
    let mut row: Vec<(TreemapItem, f32)> = Vec::new();
    let mut remaining = items;
    while let Some((item, area)) = remaining.first().cloned() {
        let side = rect.w.min(rect.h).max(1.0);
        let current = worst_ratio(&row, side);
        let mut candidate = row.clone();
        candidate.push((item, area));
        if row.is_empty() || worst_ratio(&candidate, side) <= current {
            row = candidate;
            remaining = &remaining[1..];
        } else {
            layout_row(&row, &mut rect, &mut result);
            row.clear();
        }
    }
    if !row.is_empty() {
        layout_row(&row, &mut rect, &mut result);
    }
    result
}

fn worst_ratio(row: &[(TreemapItem, f32)], side: f32) -> f32 {
    if row.is_empty() {
        return f32::MAX;
    }
    let sum: f32 = row.iter().map(|(_, area)| *area).sum();
    let min_area = row.iter().map(|(_, area)| *area).fold(f32::MAX, f32::min);
    let max_area = row.iter().map(|(_, area)| *area).fold(f32::MIN, f32::max);
    let side2 = side * side;
    ((side2 * max_area) / (sum * sum)).max((sum * sum) / (side2 * min_area.max(0.001)))
}

fn layout_row(row: &[(TreemapItem, f32)], rect: &mut Rect, result: &mut Vec<(TreemapItem, Rect)>) {
    let sum: f32 = row.iter().map(|(_, area)| *area).sum();
    if rect.w >= rect.h {
        let row_h = (sum / rect.w.max(1.0)).min(rect.h);
        let mut x = rect.x;
        for (item, area) in row {
            let w = (area / row_h.max(1.0)).min(rect.x + rect.w - x);
            result.push((
                item.clone(),
                Rect {
                    x,
                    y: rect.y,
                    w,
                    h: row_h,
                },
            ));
            x += w;
        }
        rect.y += row_h;
        rect.h -= row_h;
    } else {
        let row_w = (sum / rect.h.max(1.0)).min(rect.w);
        let mut y = rect.y;
        for (item, area) in row {
            let h = (area / row_w.max(1.0)).min(rect.y + rect.h - y);
            result.push((
                item.clone(),
                Rect {
                    x: rect.x,
                    y,
                    w: row_w,
                    h,
                },
            ));
            y += h;
        }
        rect.x += row_w;
        rect.w -= row_w;
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
