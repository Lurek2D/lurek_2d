//! CPU-side screenshot fallback for queued 2D render commands.
//! Replays a practical subset of `RenderCommand` values into `ImageData`.
//! Exists to support evidence capture in headless/unit environments where GPU readback is unavailable.

use crate::image::ImageData;
use crate::render::renderer::{DrawMode, RenderCommand};

#[derive(Clone, Copy)]
struct Mat3 {
    m: [f32; 9],
}

impl Mat3 {
    fn identity() -> Self {
        Self {
            m: [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0],
        }
    }

    fn mul(self, rhs: Self) -> Self {
        let a = self.m;
        let b = rhs.m;
        Self {
            m: [
                a[0] * b[0] + a[1] * b[3] + a[2] * b[6],
                a[0] * b[1] + a[1] * b[4] + a[2] * b[7],
                a[0] * b[2] + a[1] * b[5] + a[2] * b[8],
                a[3] * b[0] + a[4] * b[3] + a[5] * b[6],
                a[3] * b[1] + a[4] * b[4] + a[5] * b[7],
                a[3] * b[2] + a[4] * b[5] + a[5] * b[8],
                a[6] * b[0] + a[7] * b[3] + a[8] * b[6],
                a[6] * b[1] + a[7] * b[4] + a[8] * b[7],
                a[6] * b[2] + a[7] * b[5] + a[8] * b[8],
            ],
        }
    }

    fn translate(x: f32, y: f32) -> Self {
        Self {
            m: [1.0, 0.0, x, 0.0, 1.0, y, 0.0, 0.0, 1.0],
        }
    }

    fn rotate(angle: f32) -> Self {
        let c = angle.cos();
        let s = angle.sin();
        Self {
            m: [c, -s, 0.0, s, c, 0.0, 0.0, 0.0, 1.0],
        }
    }

    fn scale(sx: f32, sy: f32) -> Self {
        Self {
            m: [sx, 0.0, 0.0, 0.0, sy, 0.0, 0.0, 0.0, 1.0],
        }
    }

    fn transform_point(self, x: f32, y: f32) -> (f32, f32) {
        (
            self.m[0] * x + self.m[1] * y + self.m[2],
            self.m[3] * x + self.m[4] * y + self.m[5],
        )
    }
}

struct CaptureState {
    color: [u8; 4],
    line_width: i32,
    point_size: i32,
    color_mask: [bool; 4],
    scissor: Option<(i32, i32, i32, i32)>,
    transform: Mat3,
    stack: Vec<Mat3>,
}

impl CaptureState {
    fn new() -> Self {
        Self {
            color: [255, 255, 255, 255],
            line_width: 1,
            point_size: 1,
            color_mask: [true, true, true, true],
            scissor: None,
            transform: Mat3::identity(),
            stack: Vec::new(),
        }
    }
}

fn color_to_rgba8(color: [f32; 4]) -> [u8; 4] {
    [
        (color[0].clamp(0.0, 1.0) * 255.0) as u8,
        (color[1].clamp(0.0, 1.0) * 255.0) as u8,
        (color[2].clamp(0.0, 1.0) * 255.0) as u8,
        (color[3].clamp(0.0, 1.0) * 255.0) as u8,
    ]
}

fn estimate_canvas_size(commands: &[RenderCommand]) -> (u32, u32) {
    let mut max_x = 320.0f32;
    let mut max_y = 180.0f32;
    for command in commands {
        match command {
            RenderCommand::Rectangle { x, y, w, h, .. }
            | RenderCommand::RoundedRectangle { x, y, w, h, .. } => {
                max_x = max_x.max(*x + *w);
                max_y = max_y.max(*y + *h);
            }
            RenderCommand::Circle { x, y, r, .. } => {
                max_x = max_x.max(*x + *r);
                max_y = max_y.max(*y + *r);
            }
            RenderCommand::Ellipse { x, y, rx, ry, .. } => {
                max_x = max_x.max(*x + *rx);
                max_y = max_y.max(*y + *ry);
            }
            RenderCommand::Triangle {
                x1,
                y1,
                x2,
                y2,
                x3,
                y3,
                ..
            } => {
                max_x = max_x.max((*x1).max(*x2).max(*x3));
                max_y = max_y.max((*y1).max(*y2).max(*y3));
            }
            RenderCommand::Polygon { vertices, .. }
            | RenderCommand::Polyline { points: vertices } => {
                for pair in vertices.chunks_exact(2) {
                    max_x = max_x.max(pair[0]);
                    max_y = max_y.max(pair[1]);
                }
            }
            RenderCommand::Line { x1, y1, x2, y2 } => {
                max_x = max_x.max((*x1).max(*x2));
                max_y = max_y.max((*y1).max(*y2));
            }
            RenderCommand::Arc { x, y, radius, .. } => {
                max_x = max_x.max(*x + *radius);
                max_y = max_y.max(*y + *radius);
            }
            _ => {}
        }
    }
    ((max_x + 40.0).ceil() as u32, (max_y + 40.0).ceil() as u32)
}

fn set_pixel(img: &mut ImageData, state: &CaptureState, x: i32, y: i32) {
    if x < 0 || y < 0 || x as u32 >= img.width() || y as u32 >= img.height() {
        return;
    }
    if let Some((sx, sy, sw, sh)) = state.scissor {
        if x < sx || y < sy || x >= sx + sw || y >= sy + sh {
            return;
        }
    }
    let idx = ((y as u32 * img.width() + x as u32) * 4) as usize;
    let bytes = img.as_mut_bytes();
    if state.color_mask[0] {
        bytes[idx] = state.color[0];
    }
    if state.color_mask[1] {
        bytes[idx + 1] = state.color[1];
    }
    if state.color_mask[2] {
        bytes[idx + 2] = state.color[2];
    }
    if state.color_mask[3] {
        bytes[idx + 3] = state.color[3];
    }
}

fn draw_line(img: &mut ImageData, state: &CaptureState, x0: f32, y0: f32, x1: f32, y1: f32) {
    let (x0, y0) = state.transform.transform_point(x0, y0);
    let (x1, y1) = state.transform.transform_point(x1, y1);
    let mut x0 = x0.round() as i32;
    let mut y0 = y0.round() as i32;
    let x1 = x1.round() as i32;
    let y1 = y1.round() as i32;
    let dx = (x1 - x0).abs();
    let dy = -(y1 - y0).abs();
    let sx = if x0 < x1 { 1 } else { -1 };
    let sy = if y0 < y1 { 1 } else { -1 };
    let mut err = dx + dy;
    let radius = (state.line_width.max(1) - 1) / 2;
    loop {
        for oy in -radius..=radius {
            for ox in -radius..=radius {
                set_pixel(img, state, x0 + ox, y0 + oy);
            }
        }
        if x0 == x1 && y0 == y1 {
            break;
        }
        let e2 = 2 * err;
        if e2 >= dy {
            err += dy;
            x0 += sx;
        }
        if e2 <= dx {
            err += dx;
            y0 += sy;
        }
    }
}

fn draw_polyline(img: &mut ImageData, state: &CaptureState, points: &[(f32, f32)], close: bool) {
    if points.len() < 2 {
        return;
    }
    for pair in points.windows(2) {
        draw_line(img, state, pair[0].0, pair[0].1, pair[1].0, pair[1].1);
    }
    if close {
        let first = points[0];
        let last = points[points.len() - 1];
        draw_line(img, state, last.0, last.1, first.0, first.1);
    }
}

fn point_in_polygon(point: (f32, f32), vertices: &[(f32, f32)]) -> bool {
    let mut inside = false;
    let mut j = vertices.len() - 1;
    for i in 0..vertices.len() {
        let (xi, yi) = vertices[i];
        let (xj, yj) = vertices[j];
        let intersects = ((yi > point.1) != (yj > point.1))
            && (point.0 < (xj - xi) * (point.1 - yi) / ((yj - yi).abs().max(f32::EPSILON)) + xi);
        if intersects {
            inside = !inside;
        }
        j = i;
    }
    inside
}

fn fill_polygon(img: &mut ImageData, state: &CaptureState, vertices: &[(f32, f32)]) {
    if vertices.len() < 3 {
        return;
    }
    let transformed: Vec<(f32, f32)> = vertices
        .iter()
        .map(|(x, y)| state.transform.transform_point(*x, *y))
        .collect();
    let min_x = transformed
        .iter()
        .map(|(x, _)| *x)
        .fold(f32::INFINITY, f32::min)
        .floor() as i32;
    let max_x = transformed
        .iter()
        .map(|(x, _)| *x)
        .fold(f32::NEG_INFINITY, f32::max)
        .ceil() as i32;
    let min_y = transformed
        .iter()
        .map(|(_, y)| *y)
        .fold(f32::INFINITY, f32::min)
        .floor() as i32;
    let max_y = transformed
        .iter()
        .map(|(_, y)| *y)
        .fold(f32::NEG_INFINITY, f32::max)
        .ceil() as i32;
    for py in min_y..=max_y {
        for px in min_x..=max_x {
            if point_in_polygon((px as f32 + 0.5, py as f32 + 0.5), &transformed) {
                set_pixel(img, state, px, py);
            }
        }
    }
}

fn draw_polygon(
    img: &mut ImageData,
    state: &CaptureState,
    mode: &DrawMode,
    vertices: &[(f32, f32)],
) {
    match mode {
        DrawMode::Fill => fill_polygon(img, state, vertices),
        DrawMode::Line => draw_polyline(img, state, vertices, true),
    }
}

fn draw_rect(
    img: &mut ImageData,
    state: &CaptureState,
    mode: &DrawMode,
    x: f32,
    y: f32,
    w: f32,
    h: f32,
) {
    let vertices = [(x, y), (x + w, y), (x + w, y + h), (x, y + h)];
    draw_polygon(img, state, mode, &vertices);
}

fn draw_circle(
    img: &mut ImageData,
    state: &CaptureState,
    mode: &DrawMode,
    cx: f32,
    cy: f32,
    radius: f32,
) {
    let segments = ((radius.abs() * 0.8).ceil() as usize).clamp(16, 64);
    let mut vertices = Vec::with_capacity(segments);
    for i in 0..segments {
        let angle = (i as f32 / segments as f32) * std::f32::consts::TAU;
        vertices.push((cx + radius * angle.cos(), cy + radius * angle.sin()));
    }
    draw_polygon(img, state, mode, &vertices);
}

fn draw_ellipse(
    img: &mut ImageData,
    state: &CaptureState,
    mode: &DrawMode,
    cx: f32,
    cy: f32,
    rx: f32,
    ry: f32,
) {
    let segments = ((rx.abs().max(ry.abs()) * 0.8).ceil() as usize).clamp(18, 72);
    let mut vertices = Vec::with_capacity(segments);
    for i in 0..segments {
        let angle = (i as f32 / segments as f32) * std::f32::consts::TAU;
        vertices.push((cx + rx * angle.cos(), cy + ry * angle.sin()));
    }
    draw_polygon(img, state, mode, &vertices);
}

#[allow(clippy::too_many_arguments)]
fn draw_arc(
    img: &mut ImageData,
    state: &CaptureState,
    mode: &DrawMode,
    cx: f32,
    cy: f32,
    radius: f32,
    angle1: f32,
    angle2: f32,
    segments: u32,
) {
    let segments = segments.max(8) as usize;
    let mut points = Vec::with_capacity(segments + 1);
    for i in 0..=segments {
        let t = i as f32 / segments as f32;
        let angle = angle1 + (angle2 - angle1) * t;
        points.push((cx + radius * angle.cos(), cy + radius * angle.sin()));
    }
    match mode {
        DrawMode::Line => draw_polyline(img, state, &points, false),
        DrawMode::Fill => {
            let mut fan = Vec::with_capacity(points.len() + 1);
            fan.push((cx, cy));
            fan.extend(points);
            fill_polygon(img, state, &fan);
        }
    }
}

fn replay_command(img: &mut ImageData, state: &mut CaptureState, command: &RenderCommand) {
    match command {
        RenderCommand::SetColor(r, g, b, a) => {
            state.color = color_to_rgba8([*r, *g, *b, *a]);
        }
        RenderCommand::SetLineWidth(width) => {
            state.line_width = width.round().max(1.0) as i32;
        }
        RenderCommand::SetPointSize(size) => {
            state.point_size = size.round().max(1.0) as i32;
        }
        RenderCommand::PushTransform => state.stack.push(state.transform),
        RenderCommand::PopTransform => {
            if let Some(transform) = state.stack.pop() {
                state.transform = transform;
            }
        }
        RenderCommand::Translate { x, y } => {
            state.transform = state.transform.mul(Mat3::translate(*x, *y));
        }
        RenderCommand::Rotate { angle } => {
            state.transform = state.transform.mul(Mat3::rotate(*angle));
        }
        RenderCommand::Scale { sx, sy } => {
            state.transform = state.transform.mul(Mat3::scale(*sx, *sy));
        }
        RenderCommand::Origin => state.transform = Mat3::identity(),
        RenderCommand::SetScissor(rect) => {
            state.scissor = rect.map(|(x, y, w, h)| (x as i32, y as i32, w as i32, h as i32));
        }
        RenderCommand::SetColorMask(r, g, b, a) => {
            state.color_mask = [*r, *g, *b, *a];
        }
        RenderCommand::Rectangle { mode, x, y, w, h } => {
            draw_rect(img, state, mode, *x, *y, *w, *h)
        }
        RenderCommand::RoundedRectangle {
            mode, x, y, w, h, ..
        } => draw_rect(img, state, mode, *x, *y, *w, *h),
        RenderCommand::Circle { mode, x, y, r } => draw_circle(img, state, mode, *x, *y, *r),
        RenderCommand::Ellipse { mode, x, y, rx, ry } => {
            draw_ellipse(img, state, mode, *x, *y, *rx, *ry)
        }
        RenderCommand::Triangle {
            mode,
            x1,
            y1,
            x2,
            y2,
            x3,
            y3,
        } => draw_polygon(img, state, mode, &[(*x1, *y1), (*x2, *y2), (*x3, *y3)]),
        RenderCommand::Polygon { mode, vertices } => {
            let points: Vec<(f32, f32)> = vertices
                .chunks_exact(2)
                .map(|pair| (pair[0], pair[1]))
                .collect();
            draw_polygon(img, state, mode, &points);
        }
        RenderCommand::Line { x1, y1, x2, y2 } => draw_line(img, state, *x1, *y1, *x2, *y2),
        RenderCommand::Polyline { points } => {
            let vertices: Vec<(f32, f32)> = points
                .chunks_exact(2)
                .map(|pair| (pair[0], pair[1]))
                .collect();
            draw_polyline(img, state, &vertices, false);
        }
        RenderCommand::Arc {
            mode,
            x,
            y,
            radius,
            angle1,
            angle2,
            segments,
        } => draw_arc(
            img, state, mode, *x, *y, *radius, *angle1, *angle2, *segments,
        ),
        RenderCommand::Points { points } => {
            let radius = (state.point_size.max(1) - 1) / 2;
            for (x, y) in points {
                let (tx, ty) = state.transform.transform_point(*x, *y);
                for oy in -radius..=radius {
                    for ox in -radius..=radius {
                        set_pixel(img, state, tx.round() as i32 + ox, ty.round() as i32 + oy);
                    }
                }
            }
        }
        _ => {}
    }
}

pub fn capture_commands_to_image(
    commands: &[RenderCommand],
    background_color: [f32; 4],
) -> ImageData {
    let (width, height) = estimate_canvas_size(commands);
    let bg = color_to_rgba8(background_color);
    let mut img = ImageData::new(width, height);
    img.draw_rect(0, 0, width, height, bg[0], bg[1], bg[2], bg[3]);
    let mut state = CaptureState::new();
    for command in commands {
        replay_command(&mut img, &mut state, command);
    }
    img
}
