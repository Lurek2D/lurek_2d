//! This file owns the shared CPU rasterization helpers that every chart renderer uses to draw into RGBA byte buffers.
//! It implements pixel writes, Bresenham lines, filled rectangles, filled circles, and whole-buffer background clears.
//! Auto-range and world-to-screen mapping live here so cartesian renderers share one default axis-domain policy.
//! Annotation helpers also live here, adding titles, ticks, legends, axis labels, and category captions onto images.
//! Small text-formatting and color-box helpers stay local because chart annotations depend on ImageData label drawing.
//! Open it when low-level raster rules or shared chart annotation behavior changes across multiple renderer files.
//! Edit the individual chart file instead when changing series storage, stacking, bucketing, or matrix-specific semantics.

use crate::charts::config::{ChartConfig, ChartSeries};
use crate::image::ImageData;

/// Set a single pixel in the buffer to the given color.
///
/// Coordinates outside the buffer dimensions are silently ignored.
pub fn set_pixel(buffer: &mut [u8], width: u32, x: u32, y: u32, color: [f32; 4]) {
    let idx = ((y * width + x) * 4) as usize;
    if idx + 3 < buffer.len() {
        buffer[idx] = (color[0] * 255.0) as u8;
        buffer[idx + 1] = (color[1] * 255.0) as u8;
        buffer[idx + 2] = (color[2] * 255.0) as u8;
        buffer[idx + 3] = (color[3] * 255.0) as u8;
    }
}

/// Draw a line between two points using Bresenham's algorithm.
///
/// Floating-point endpoints are rounded to the nearest pixel.
#[allow(clippy::too_many_arguments)]
pub fn draw_line(
    buffer: &mut [u8],
    width: u32,
    height: u32,
    x0: f32,
    y0: f32,
    x1: f32,
    y1: f32,
    color: [f32; 4],
) {
    let mut ix0 = x0.round() as i32;
    let mut iy0 = y0.round() as i32;
    let ix1 = x1.round() as i32;
    let iy1 = y1.round() as i32;

    let dx = (ix1 - ix0).abs();
    let dy = -(iy1 - iy0).abs();
    let sx = if ix0 < ix1 { 1 } else { -1 };
    let sy = if iy0 < iy1 { 1 } else { -1 };
    let mut err = dx + dy;

    loop {
        if ix0 >= 0 && iy0 >= 0 && (ix0 as u32) < width && (iy0 as u32) < height {
            set_pixel(buffer, width, ix0 as u32, iy0 as u32, color);
        }
        if ix0 == ix1 && iy0 == iy1 {
            break;
        }
        let e2 = 2 * err;
        if e2 >= dy {
            err += dy;
            ix0 += sx;
        }
        if e2 <= dx {
            err += dx;
            iy0 += sy;
        }
    }
}

/// Draw a filled axis-aligned rectangle.
///
/// Pixels outside the buffer bounds are clipped.
pub fn draw_rect_filled(
    buffer: &mut [u8],
    width: u32,
    x: u32,
    y: u32,
    w: u32,
    h: u32,
    color: [f32; 4],
) {
    let height = buffer.len() as u32 / (width * 4);
    for row in y..y.saturating_add(h).min(height) {
        for col in x..x.saturating_add(w).min(width) {
            set_pixel(buffer, width, col, row, color);
        }
    }
}

/// Draw a filled circle using per-pixel distance test.
///
/// Pixels outside the buffer bounds are clipped.
pub fn draw_circle_filled(
    buffer: &mut [u8],
    width: u32,
    height: u32,
    cx: f32,
    cy: f32,
    radius: f32,
    color: [f32; 4],
) {
    let r2 = radius * radius;
    let min_x = ((cx - radius).floor() as i32).max(0) as u32;
    let max_x = ((cx + radius).ceil() as i32).min(width as i32 - 1).max(0) as u32;
    let min_y = ((cy - radius).floor() as i32).max(0) as u32;
    let max_y = ((cy + radius).ceil() as i32).min(height as i32 - 1).max(0) as u32;

    for py in min_y..=max_y {
        for px in min_x..=max_x {
            let dx = px as f32 - cx;
            let dy = py as f32 - cy;
            if dx * dx + dy * dy <= r2 {
                set_pixel(buffer, width, px, py, color);
            }
        }
    }
}

/// Fill the entire buffer with a single color.
pub fn fill_buffer(buffer: &mut [u8], color: [f32; 4]) {
    let r = (color[0] * 255.0) as u8;
    let g = (color[1] * 255.0) as u8;
    let b = (color[2] * 255.0) as u8;
    let a = (color[3] * 255.0) as u8;
    for chunk in buffer.chunks_exact_mut(4) {
        chunk[0] = r;
        chunk[1] = g;
        chunk[2] = b;
        chunk[3] = a;
    }
}

/// Trim a point buffer to the newest `max_points` entries.
pub fn trim_points_to_window(data: &mut Vec<(f32, f32)>, max_points: Option<usize>) {
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

/// Compute the bounding range across all series.
///
/// Returns `(min_x, max_x, min_y, max_y)`. If no data points exist,
/// returns `(0.0, 1.0, 0.0, 1.0)` to avoid degenerate ranges.
pub fn auto_range(series: &[ChartSeries]) -> (f32, f32, f32, f32) {
    let mut min_x = f32::MAX;
    let mut max_x = f32::MIN;
    let mut min_y = f32::MAX;
    let mut max_y = f32::MIN;
    let mut has_data = false;

    for s in series {
        for &(x, y) in &s.data {
            if !x.is_finite() || !y.is_finite() {
                continue;
            }
            has_data = true;
            if x < min_x {
                min_x = x;
            }
            if x > max_x {
                max_x = x;
            }
            if y < min_y {
                min_y = y;
            }
            if y > max_y {
                max_y = y;
            }
        }
    }

    if !has_data {
        return (0.0, 1.0, 0.0, 1.0);
    }

    // Prevent zero-size ranges.
    if (max_x - min_x).abs() < f32::EPSILON {
        max_x = min_x + 1.0;
    }
    if (max_y - min_y).abs() < f32::EPSILON {
        max_y = min_y + 1.0;
    }

    (min_x, max_x, min_y, max_y)
}

/// Map a data-space value to a screen-space pixel coordinate.
///
/// Linearly interpolates `value` from `[min, max]` to `[0, screen_size]`.
pub fn world_to_screen(value: f32, min: f32, max: f32, screen_size: f32) -> f32 {
    if (max - min).abs() < f32::EPSILON {
        return screen_size * 0.5;
    }
    (value - min) / (max - min) * screen_size
}

fn rgba_to_u8(color: [f32; 4]) -> (u8, u8, u8) {
    (
        (color[0].clamp(0.0, 1.0) * 255.0) as u8,
        (color[1].clamp(0.0, 1.0) * 255.0) as u8,
        (color[2].clamp(0.0, 1.0) * 255.0) as u8,
    )
}

fn chart_label_x(text: &str, center_x: i32) -> i32 {
    center_x - ((text.len() as i32 * 6) / 2)
}

fn format_tick(value: f32) -> String {
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

fn trim_label(label: &str, max_len: usize) -> String {
    let trimmed: String = label.chars().take(max_len).collect();
    if label.chars().count() > max_len {
        format!("{trimmed}.")
    } else {
        trimmed
    }
}

fn image_from_buffer(buffer: &[u8], width: u32, height: u32) -> ImageData {
    let mut img = ImageData::new(width, height);
    let _ = img.set_raw_data(buffer);
    img
}

fn write_back_buffer(buffer: &mut [u8], img: &ImageData) {
    buffer.copy_from_slice(img.as_bytes());
}

fn draw_color_box(img: &mut ImageData, width: u32, height: u32, x: u32, y: u32, color: [f32; 4]) {
    for yy in y..y.saturating_add(8).min(height) {
        for xx in x..x.saturating_add(10).min(width) {
            let idx = ((yy * width + xx) * 4) as usize;
            let bytes = img.as_mut_bytes();
            bytes[idx] = (color[0].clamp(0.0, 1.0) * 255.0) as u8;
            bytes[idx + 1] = (color[1].clamp(0.0, 1.0) * 255.0) as u8;
            bytes[idx + 2] = (color[2].clamp(0.0, 1.0) * 255.0) as u8;
            bytes[idx + 3] = 255;
        }
    }
}

#[allow(clippy::too_many_arguments)]
/// Draw axes, tick labels, optional title, axis captions, category labels, and legend entries for cartesian chart images.
pub fn annotate_cartesian_chart(
    buffer: &mut [u8],
    width: u32,
    height: u32,
    config: &ChartConfig,
    plot_x: f32,
    plot_y: f32,
    plot_w: f32,
    plot_h: f32,
    min_x: f32,
    max_x: f32,
    min_y: f32,
    max_y: f32,
    legend_entries: &[(&str, [f32; 4])],
    category_labels: Option<&[String]>,
) {
    let mut img = image_from_buffer(buffer, width, height);
    let (lr, lg, lb) = rgba_to_u8(config.label_color);

    if let Some(title) = config.title.as_deref() {
        img.draw_label(
            title,
            chart_label_x(title, (width / 2) as i32),
            8,
            lr,
            lg,
            lb,
        );
    }
    if let Some(y_label) = config.y_label.as_deref() {
        img.draw_label(y_label, 6, 20, lr, lg, lb);
    }
    if let Some(x_label) = config.x_label.as_deref() {
        img.draw_label(
            x_label,
            chart_label_x(x_label, (plot_x + plot_w * 0.5) as i32),
            (height as i32 - 16).max(0),
            lr,
            lg,
            lb,
        );
    }

    let y_ticks = config.y_tick_count.max(2);
    for i in 0..=y_ticks {
        let frac = i as f32 / y_ticks as f32;
        let value = min_y + (max_y - min_y) * frac;
        let label = format_tick(value);
        let py = (plot_y + plot_h - plot_h * frac) as i32 - 3;
        let px = (plot_x as i32 - (label.len() as i32 * 6) - 6).max(0);
        img.draw_label(&label, px, py, lr, lg, lb);
    }

    if let Some(labels) = category_labels {
        if !labels.is_empty() {
            let step = plot_w / labels.len() as f32;
            for (idx, label) in labels.iter().enumerate() {
                let center_x = plot_x + step * (idx as f32 + 0.5);
                let short = trim_label(label, 8);
                img.draw_label(
                    &short,
                    chart_label_x(&short, center_x as i32),
                    (plot_y + plot_h + 8.0) as i32,
                    lr,
                    lg,
                    lb,
                );
            }
        }
    } else {
        let x_ticks = config.x_tick_count.max(2);
        for i in 0..=x_ticks {
            let frac = i as f32 / x_ticks as f32;
            let value = min_x + (max_x - min_x) * frac;
            let label = format_tick(value);
            let px = (plot_x + plot_w * frac) as i32 - ((label.len() as i32 * 6) / 2);
            img.draw_label(
                &label,
                px.max(0),
                (plot_y + plot_h + 8.0) as i32,
                lr,
                lg,
                lb,
            );
        }
    }

    if config.show_legend && !legend_entries.is_empty() {
        let legend_x = (width as f32 - config.legend_width + 8.0).max(plot_x + plot_w + 8.0) as i32;
        let mut legend_y = (plot_y + 8.0) as i32;
        img.draw_label("Legend", legend_x, legend_y, lr, lg, lb);
        legend_y += 14;
        for (label, color) in legend_entries.iter().take(8) {
            let box_y = legend_y.max(0) as u32;
            let box_x = legend_x.max(0) as u32;
            draw_color_box(&mut img, width, height, box_x, box_y, *color);
            img.draw_label(&trim_label(label, 12), legend_x + 16, legend_y, lr, lg, lb);
            legend_y += 12;
        }
    }

    write_back_buffer(buffer, &img);
}

/// Draw the title and optional legend for pie chart images after the segment renderer has filled the chart body.
pub fn annotate_pie_chart(
    buffer: &mut [u8],
    width: u32,
    height: u32,
    config: &ChartConfig,
    legend_entries: &[(&str, [f32; 4])],
) {
    let mut img = image_from_buffer(buffer, width, height);
    let (lr, lg, lb) = rgba_to_u8(config.label_color);

    if let Some(title) = config.title.as_deref() {
        img.draw_label(
            title,
            chart_label_x(title, (width / 2) as i32),
            8,
            lr,
            lg,
            lb,
        );
    }

    if config.show_legend && !legend_entries.is_empty() {
        let legend_x =
            (width as f32 - config.legend_width + 8.0).max((width as f32 * 0.58) + 8.0) as i32;
        let mut legend_y = 28i32;
        img.draw_label("Legend", legend_x, legend_y, lr, lg, lb);
        legend_y += 14;
        for (label, color) in legend_entries.iter().take(10) {
            let box_x = legend_x.max(0) as u32;
            let box_y = legend_y.max(0) as u32;
            draw_color_box(&mut img, width, height, box_x, box_y, *color);
            img.draw_label(&trim_label(label, 12), legend_x + 16, legend_y, lr, lg, lb);
            legend_y += 12;
        }
    }

    write_back_buffer(buffer, &img);
}
