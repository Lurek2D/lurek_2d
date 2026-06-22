//! Owns the rendering path for the terminal subsystem and keeps its rules local to this file.
//! Centers the implementation around LineGlyph, fn, color_channel, with helpers kept close to their invariants.
//! Defines how render data is validated, transformed, or stored before neighboring systems use it.
//! Owns terminal behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on render behavior while Lua registration stays elsewhere.
//! Documents the boundary where terminal code accepts inputs, reports errors, or updates state.
//! Use this file when changing render defaults, lifecycle handling, validation, or data ownership.

use super::{terminal_state::Terminal, TCell};
use crate::image::ImageData;
use crate::render::renderer::{DrawMode, RenderCommand};
use crate::runtime::resource_keys::FontKey;

#[derive(Clone, Copy)]
struct LineGlyph {
    left: bool,
    right: bool,
    up: bool,
    down: bool,
    double: bool,
}

impl LineGlyph {
    const fn new(left: bool, right: bool, up: bool, down: bool, double: bool) -> Self {
        Self {
            left,
            right,
            up,
            down,
            double,
        }
    }
}

fn color_channel(value: f32) -> u8 {
    (value.clamp(0.0, 1.0) * 255.0).round() as u8
}

fn cell_char(cells: &[TCell], cols: usize, rows: usize, col: isize, row: isize) -> char {
    if col < 0 || row < 0 || col as usize >= cols || row as usize >= rows {
        return ' ';
    }
    char::from_u32(cells[row as usize * cols + col as usize].ch).unwrap_or(' ')
}

fn unicode_line_glyph(ch: char) -> Option<LineGlyph> {
    Some(match ch {
        '─' | '━' => LineGlyph::new(true, true, false, false, false),
        '═' => LineGlyph::new(true, true, false, false, true),
        '│' | '┃' => LineGlyph::new(false, false, true, true, false),
        '║' => LineGlyph::new(false, false, true, true, true),
        '┌' => LineGlyph::new(false, true, false, true, false),
        '┐' => LineGlyph::new(true, false, false, true, false),
        '└' => LineGlyph::new(false, true, true, false, false),
        '┘' => LineGlyph::new(true, false, true, false, false),
        '╔' => LineGlyph::new(false, true, false, true, true),
        '╗' => LineGlyph::new(true, false, false, true, true),
        '╚' => LineGlyph::new(false, true, true, false, true),
        '╝' => LineGlyph::new(true, false, true, false, true),
        '├' | '┣' | '╠' => LineGlyph::new(false, true, true, true, ch == '╠'),
        '┤' | '┫' | '╣' => LineGlyph::new(true, false, true, true, ch == '╣'),
        '┬' | '┳' | '╦' => LineGlyph::new(true, true, false, true, ch == '╦'),
        '┴' | '┻' | '╩' => LineGlyph::new(true, true, true, false, ch == '╩'),
        '┼' | '╬' => LineGlyph::new(true, true, true, true, ch == '╬'),
        _ => return None,
    })
}

fn ascii_line_glyph(
    ch: char,
    cells: &[TCell],
    cols: usize,
    rows: usize,
    col: usize,
    row: usize,
) -> Option<LineGlyph> {
    fn connects_h(ch: char) -> bool {
        matches!(ch, '-' | '+')
    }
    fn connects_v(ch: char) -> bool {
        matches!(ch, '|' | '+')
    }

    let col = col as isize;
    let row = row as isize;
    match ch {
        '-' => {
            let has_h = connects_h(cell_char(cells, cols, rows, col - 1, row))
                || connects_h(cell_char(cells, cols, rows, col + 1, row));
            has_h.then(|| LineGlyph::new(true, true, false, false, false))
        }
        '|' => {
            let has_v = connects_v(cell_char(cells, cols, rows, col, row - 1))
                || connects_v(cell_char(cells, cols, rows, col, row + 1));
            has_v.then(|| LineGlyph::new(false, false, true, true, false))
        }
        '+' => {
            let left = connects_h(cell_char(cells, cols, rows, col - 1, row));
            let right = connects_h(cell_char(cells, cols, rows, col + 1, row));
            let up = connects_v(cell_char(cells, cols, rows, col, row - 1));
            let down = connects_v(cell_char(cells, cols, rows, col, row + 1));
            (left || right || up || down).then(|| LineGlyph::new(left, right, up, down, false))
        }
        _ => None,
    }
}

#[allow(clippy::too_many_arguments)]
fn draw_terminal_line_glyph(
    img: &mut ImageData,
    px: i32,
    py: i32,
    cell_w: u32,
    cell_h: u32,
    line: LineGlyph,
    r: u8,
    g: u8,
    b: u8,
    a: u8,
) {
    let cw = cell_w as i32;
    let ch = cell_h as i32;
    let cx = px + cw / 2;
    let cy = py + ch / 2;
    let thickness = (cell_w.min(cell_h) / 6).clamp(1, 3);
    let half = (thickness as i32) / 2;

    fn draw_h(
        img: &mut ImageData,
        x0: i32,
        x1: i32,
        y: i32,
        thickness: u32,
        r: u8,
        g: u8,
        b: u8,
        a: u8,
    ) {
        let left = x0.min(x1);
        let right = x0.max(x1);
        img.draw_rect(
            left,
            y - (thickness as i32 / 2),
            (right - left + 1) as u32,
            thickness,
            r,
            g,
            b,
            a,
        );
    }
    fn draw_v(
        img: &mut ImageData,
        x: i32,
        y0: i32,
        y1: i32,
        thickness: u32,
        r: u8,
        g: u8,
        b: u8,
        a: u8,
    ) {
        let top = y0.min(y1);
        let bottom = y0.max(y1);
        img.draw_rect(
            x - (thickness as i32 / 2),
            top,
            thickness,
            (bottom - top + 1) as u32,
            r,
            g,
            b,
            a,
        );
    }

    if line.double {
        let offset = (cell_w.min(cell_h) as i32 / 5).max(2);
        for y in [cy - offset, cy + offset] {
            if line.left {
                draw_h(img, px, cx + half, y, 1, r, g, b, a);
            }
            if line.right {
                draw_h(img, cx - half, px + cw - 1, y, 1, r, g, b, a);
            }
        }
        for x in [cx - offset, cx + offset] {
            if line.up {
                draw_v(img, x, py, cy + half, 1, r, g, b, a);
            }
            if line.down {
                draw_v(img, x, cy - half, py + ch - 1, 1, r, g, b, a);
            }
        }
    } else {
        if line.left {
            draw_h(img, px, cx + half, cy, thickness, r, g, b, a);
        }
        if line.right {
            draw_h(img, cx - half, px + cw - 1, cy, thickness, r, g, b, a);
        }
        if line.up {
            draw_v(img, cx, py, cy + half, thickness, r, g, b, a);
        }
        if line.down {
            draw_v(img, cx, cy - half, py + ch - 1, thickness, r, g, b, a);
        }
    }
}

#[allow(clippy::too_many_arguments)]
fn draw_block_marker(
    img: &mut ImageData,
    px: i32,
    py: i32,
    cell_w: u32,
    cell_h: u32,
    r: u8,
    g: u8,
    b: u8,
    a: u8,
) {
    let inset_x = (cell_w / 8).min(2) as i32;
    let inset_y = (cell_h / 8).min(2) as i32;
    let w = cell_w.saturating_sub((inset_x as u32) * 2).max(1);
    let h = cell_h.saturating_sub((inset_y as u32) * 2).max(1);
    img.draw_rect(px + inset_x, py + inset_y, w, h, r, g, b, a);
}

#[allow(clippy::too_many_arguments)]
fn draw_dot_marker(
    img: &mut ImageData,
    px: i32,
    py: i32,
    cell_w: u32,
    cell_h: u32,
    r: u8,
    g: u8,
    b: u8,
    a: u8,
) {
    let radius = (cell_w.min(cell_h) / 4).max(2);
    img.draw_circle(
        px + cell_w as i32 / 2,
        py + cell_h as i32 / 2,
        radius,
        r,
        g,
        b,
        a,
    );
}

#[allow(clippy::too_many_arguments)]
fn draw_braille_marker(
    img: &mut ImageData,
    ch: char,
    px: i32,
    py: i32,
    cell_w: u32,
    cell_h: u32,
    r: u8,
    g: u8,
    b: u8,
    a: u8,
) -> bool {
    let code = ch as u32;
    if !(0x2800..=0x28ff).contains(&code) || code == 0x2800 {
        return false;
    }
    let mask = code - 0x2800;
    let dot_radius = (cell_w.min(cell_h) / 10).max(1);
    let x0 = px + (cell_w as i32 / 3);
    let x1 = px + (cell_w as i32 * 2 / 3);
    let rows = [
        py + (cell_h as i32 / 5),
        py + (cell_h as i32 * 2 / 5),
        py + (cell_h as i32 * 3 / 5),
        py + (cell_h as i32 * 4 / 5),
    ];
    let dots = [
        (0, x0, rows[0]),
        (1, x0, rows[1]),
        (2, x0, rows[2]),
        (6, x0, rows[3]),
        (3, x1, rows[0]),
        (4, x1, rows[1]),
        (5, x1, rows[2]),
        (7, x1, rows[3]),
    ];
    for (bit, x, y) in dots {
        if mask & (1 << bit) != 0 {
            img.draw_circle(x, y, dot_radius, r, g, b, a);
        }
    }
    true
}

/// Rendering helpers for the terminal cell grid.
impl Terminal {
    /// Build a `RenderCommand` list for the current cell grid using `font_key`, `char_w`/`char_h` cell dimensions, and `scale`.
    pub fn generate_render_commands(
        &self,
        font_key: FontKey,
        char_w: f32,
        char_h: f32,
        scale: f32,
    ) -> Vec<RenderCommand> {
        let (cols, rows) = self.get_dimensions();
        self.with_render_cells(|cells| {
            let mut cmds = Vec::with_capacity(cols * rows * 2);
            for row in 0..rows {
                for col in 0..cols {
                    let cell = cells[row * cols + col];
                    let x = col as f32 * char_w;
                    let y = row as f32 * char_h;
                    let [br, bg_clr, bb, ba] = cell.bg;
                    if ba > 0.0 {
                        cmds.push(RenderCommand::SetColor(br, bg_clr, bb, ba));
                        cmds.push(RenderCommand::Rectangle {
                            mode: DrawMode::Fill,
                            x,
                            y,
                            w: char_w,
                            h: char_h,
                        });
                    }
                    let ch = char::from_u32(cell.ch).unwrap_or(' ');
                    if ch != ' ' {
                        let [r, g, b, a] = cell.fg;
                        cmds.push(RenderCommand::SetColor(r, g, b, a));
                        cmds.push(RenderCommand::Print {
                            font_key,
                            text: ch.to_string(),
                            x,
                            y,
                            scale,
                        });
                    }
                }
            }
            cmds
        })
    }

    /// Rasterise the cell grid into a `width` by `height` `ImageData` thumbnail with readable cell glyphs.
    pub fn draw_to_image(&self, width: u32, height: u32) -> ImageData {
        let mut img = ImageData::new(width, height);
        img.fill(18, 18, 28, 255);
        let (cols, rows) = self.get_dimensions();
        if cols == 0 || rows == 0 || width == 0 || height == 0 {
            return img;
        }
        let cell_w = (width / cols as u32).max(1);
        let cell_h = (height / rows as u32).max(1);
        self.with_render_cells(|cells| {
            for row in 0..rows {
                for col in 0..cols {
                    let cell = cells[row * cols + col];
                    let [br, bg, bb, ba] = cell.bg;
                    let px = (col as u32 * cell_w) as i32;
                    let py = (row as u32 * cell_h) as i32;
                    if ba > 0.0 {
                        img.draw_rect(
                            px,
                            py,
                            cell_w,
                            cell_h,
                            (br * 255.0).min(255.0) as u8,
                            (bg * 255.0).min(255.0) as u8,
                            (bb * 255.0).min(255.0) as u8,
                            (ba * 255.0).min(255.0) as u8,
                        );
                    }
                    let ch = char::from_u32(cell.ch).unwrap_or(' ');
                    if ch == ' ' {
                        continue;
                    }
                    let [r, g, b, a] = cell.fg;
                    let pr = color_channel(r);
                    let pg = color_channel(g);
                    let pb = color_channel(b);
                    let pa = color_channel(a);
                    if let Some(line) = unicode_line_glyph(ch)
                        .or_else(|| ascii_line_glyph(ch, cells, cols, rows, col, row))
                    {
                        draw_terminal_line_glyph(
                            &mut img, px, py, cell_w, cell_h, line, pr, pg, pb, pa,
                        );
                        continue;
                    }
                    if matches!(ch, '#' | '█' | '▓' | '▒' | '■') {
                        draw_block_marker(&mut img, px, py, cell_w, cell_h, pr, pg, pb, pa);
                        continue;
                    }
                    if matches!(ch, '*' | '•' | '·' | '●') {
                        draw_dot_marker(&mut img, px, py, cell_w, cell_h, pr, pg, pb, pa);
                        continue;
                    }
                    if draw_braille_marker(&mut img, ch, px, py, cell_w, cell_h, pr, pg, pb, pa) {
                        continue;
                    }
                    let mut glyph_buf = [0u8; 4];
                    let label = if ch.is_ascii() {
                        ch.encode_utf8(&mut glyph_buf)
                    } else {
                        "?"
                    };
                    let text_x = px + ((cell_w as i32 - 5).max(0) / 2);
                    let text_y = py + ((cell_h as i32 - 7).max(0) / 2);
                    img.draw_label(label, text_x, text_y, pr, pg, pb);
                }
            }
        });
        img
    }
}
