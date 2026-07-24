//! Lowers resolved UI widgets, styles, text, and overlays into render commands consumed by live and headless backends.
//! It owns widget visuals, inherited shader selection, clipping commands, and deterministic command ordering.
//! GuiContext supplies geometry and state; this file never changes widget ownership, focus, callbacks, or input routing.
//! Theme lookup selects colors, borders, type, and state variants before commands are emitted for live or headless output.
//! Font and shader resources remain render-owned; UI stores selected keys on retained widget state.
//! Software capture replays this command vocabulary through render-owned capture instead of duplicating UI semantics.
//! Toolbar separators and spacers are visual items paired with hit testing so only button entries are interactive.
//! Rendering uses visible fallback output for missing optional resources instead of assuming GPU state at the UI boundary.
//! Open this file for widget appearance, draw-command order, clipping, shader inheritance, or UI-to-image lowering changes.
//! Generic renderer execution, GPU pipelines, and image encoding are deliberately outside this module's ownership boundary.
//! Helper modules contain shared paint primitives; keep individual widget branches focused on observable visual contracts.
//! GuiContext checks command limits before submission so pathological retained trees cannot exhaust a frame budget.
//! Coordinates are logical UI pixels after layout scaling; downstream render modules perform target conversion.
//! Tests for this owner should assert commands or capture output, not merely that a widget factory remains callable.

use crate::font::Font;
use crate::math::Rect;
use crate::render::renderer::{DrawMode, GradientDirection, RenderCommand};
use crate::runtime::resource_keys::{FontKey, ShaderKey};
use crate::ui::context::{GuiContext, WidgetKind};
use crate::ui::extras::ToolbarItem;
use crate::ui::theme::{ThemeToken, WidgetStyle};
use crate::ui::widget::{TextVAlign, WidgetBase, WidgetState};
use slotmap::SlotMap;
use std::collections::HashMap;

mod helpers;

use helpers::*;

const ELLIPSIS: &str = "\u{2026}";

fn text_scale(style: &WidgetStyle, font: Option<&Font>) -> f32 {
    let base_height = font.map(|font| font.size()).unwrap_or(14.0).max(1.0);
    style.font_size / base_height
}

fn text_line_advance(style: &WidgetStyle, font: Option<&Font>) -> f32 {
    font.map(|font| font.line_height() * text_scale(style, Some(font)))
        .unwrap_or(style.font_size.max(1.0))
        .max(1.0)
}

fn text_visual_bounds(text: &str, style: &WidgetStyle, font: Option<&Font>) -> (f32, f32) {
    let Some(font) = font else {
        let fallback_h = (style.font_size * (7.0 / 14.0)).max(1.0);
        return (0.0, fallback_h);
    };
    let scale = text_scale(style, Some(font));
    let font_size = font.size();
    let mut min_top = f32::MAX;
    let mut max_bottom = f32::MIN;
    for glyph in text.chars().filter_map(|ch| font.glyph(ch)) {
        if glyph.width == 0 || glyph.height == 0 {
            continue;
        }
        let top = (font_size - glyph.offset_y - glyph.height as f32) * scale;
        let bottom = top + glyph.height as f32 * scale;
        min_top = min_top.min(top);
        max_bottom = max_bottom.max(bottom);
    }
    if min_top.is_finite() && max_bottom.is_finite() && max_bottom > min_top {
        (min_top, max_bottom - min_top)
    } else {
        (0.0, text_line_advance(style, Some(font)))
    }
}

fn text_origin_y(text: &str, y: f32, height: f32, style: &WidgetStyle, font: Option<&Font>) -> f32 {
    let (visual_top, visual_h) = text_visual_bounds(text, style, font);
    y + ((height - visual_h) * 0.5).max(0.0) - visual_top
}

fn measure_text(text: &str, style: &WidgetStyle, font: Option<&Font>) -> f32 {
    match font {
        Some(font) => font.text_width(text) * text_scale(style, Some(font)),
        None => text.chars().count() as f32 * 6.0 * text_scale(style, None),
    }
}

fn measure_text_cached(
    cache: &mut HashMap<String, f32>,
    text: &str,
    style: &WidgetStyle,
    font: Option<&Font>,
) -> f32 {
    if let Some(width) = cache.get(text) {
        *width
    } else {
        let width = measure_text(text, style, font);
        cache.insert(text.to_string(), width);
        width
    }
}

fn best_prefix_end_for_width(
    text: &str,
    max_width: f32,
    prefix_cache: &mut HashMap<usize, f32>,
    style: &WidgetStyle,
    font: Option<&Font>,
) -> usize {
    if text.is_empty() || max_width <= 0.0 {
        return 0;
    }
    let mut boundaries: Vec<usize> = text.char_indices().map(|(idx, _)| idx).skip(1).collect();
    boundaries.push(text.len());
    let mut low = 0usize;
    let mut high = boundaries.len();
    let mut best_end = 0usize;
    while low < high {
        let mid = (low + high) / 2;
        let end = boundaries[mid];
        let width = *prefix_cache
            .entry(end)
            .or_insert_with(|| measure_text(&text[..end], style, font));
        if width <= max_width {
            best_end = end;
            low = mid + 1;
        } else {
            high = mid;
        }
    }
    best_end
}

fn focus_ring_color(ctx: &GuiContext, base: &WidgetBase) -> Option<[f32; 4]> {
    if !base.focusable
        || !base.enabled
        || !base.is_visible
        || base.state != WidgetState::Focused
        || base.alpha <= 0.0
    {
        return None;
    }
    let mut color = match ctx
        .theme
        .as_ref()
        .and_then(|theme| theme.get_token("focus_ring_color"))
    {
        Some(ThemeToken::Color(color)) => *color,
        _ => [0.3, 0.6, 1.0, 0.8],
    };
    color[3] *= base.alpha.clamp(0.0, 1.0);
    (color[3] > 0.0).then_some(color)
}

fn emit_focus_ring(ctx: &GuiContext, base: &WidgetBase, cmds: &mut Vec<RenderCommand>) {
    let Some([r, g, b, a]) = focus_ring_color(ctx, base) else {
        return;
    };
    let thickness = 2.0;
    cmds.push(RenderCommand::SetColor(r, g, b, a));
    cmds.push(RenderCommand::Rectangle {
        mode: DrawMode::Fill,
        x: base.x - thickness,
        y: base.y - thickness,
        w: base.width + thickness * 2.0,
        h: thickness,
    });
    cmds.push(RenderCommand::Rectangle {
        mode: DrawMode::Fill,
        x: base.x - thickness,
        y: base.y + base.height,
        w: base.width + thickness * 2.0,
        h: thickness,
    });
    cmds.push(RenderCommand::Rectangle {
        mode: DrawMode::Fill,
        x: base.x - thickness,
        y: base.y,
        w: thickness,
        h: base.height,
    });
    cmds.push(RenderCommand::Rectangle {
        mode: DrawMode::Fill,
        x: base.x + base.width,
        y: base.y,
        w: thickness,
        h: base.height,
    });
}

/// A single laid-out text run with absolute screen position and clip bounds.
pub struct TextLine {
    /// Text content for this run.
    pub text: String,
    /// Absolute X screen coordinate for the `Print` command origin.
    pub x: f32,
    /// Absolute Y screen coordinate for the `Print` command origin.
    pub y: f32,
    /// Scissor rect that must enclose this run; caller emits `SetScissor` before printing.
    pub clip_rect: Rect,
}
/// Compute a list of [`TextLine`]s for `text` inside `rect`, applying wrap, ellipsis, and vertical alignment.
///
/// - `wrap=false, ellipsis=true`: truncate to one line ending with "â€¦" when text exceeds `rect.width`.
/// - `wrap=true`: break at word boundaries; no per-line ellipsis.
/// - `v_align`: distribute the total text block vertically within `rect`.
/// - `padding`: `[top, right, bottom, left]` insets applied before placement.
#[allow(clippy::too_many_arguments)]
fn layout_text(
    text: &str,
    rect: Rect,
    style: &WidgetStyle,
    font: Option<&Font>,
    wrap: bool,
    ellipsis: bool,
    v_align: TextVAlign,
    padding: [f32; 4],
    h_align: &str,
) -> Vec<TextLine> {
    let line_height = text_line_advance(style, font);
    let inner_x = rect.x + padding[3];
    let inner_y = rect.y + padding[0];
    let inner_w = (rect.width - padding[1] - padding[3]).max(0.0);
    let inner_h = (rect.height - padding[0] - padding[2]).max(0.0);
    let clip = Rect::new(rect.x, rect.y, rect.width, rect.height);
    let mut width_cache = HashMap::new();

    let raw_lines: Vec<&str> = text.split('\n').collect();
    let mut final_lines: Vec<String> = Vec::new();

    if wrap {
        let space_w = measure_text_cached(&mut width_cache, " ", style, font);
        for raw in &raw_lines {
            let mut current = String::new();
            let mut current_w = 0.0_f32;
            for word in raw.split_whitespace() {
                let word_w = measure_text_cached(&mut width_cache, word, style, font);
                let gap_w = if current.is_empty() { 0.0 } else { space_w };
                if !current.is_empty() && current_w + gap_w + word_w > inner_w {
                    final_lines.push(std::mem::take(&mut current));
                    current_w = 0.0;
                }
                if !current.is_empty() {
                    current.push(' ');
                    current_w += gap_w;
                }
                current.push_str(word);
                current_w += word_w;
            }
            if !current.is_empty() || raw.is_empty() {
                final_lines.push(current);
            }
        }
    } else {
        let single: String = raw_lines.join(" ");
        if ellipsis && inner_w > 0.0 {
            let total_w = measure_text_cached(&mut width_cache, &single, style, font);
            if total_w > inner_w {
                let ellipsis_w = measure_text_cached(&mut width_cache, ELLIPSIS, style, font);
                if ellipsis_w >= inner_w {
                    final_lines.push(ELLIPSIS.to_string());
                } else {
                    let mut prefix_cache = HashMap::new();
                    let end = best_prefix_end_for_width(
                        &single,
                        inner_w - ellipsis_w,
                        &mut prefix_cache,
                        style,
                        font,
                    );
                    let mut truncated = single[..end].to_string();
                    truncated.push_str(ELLIPSIS);
                    final_lines.push(truncated);
                }
            } else {
                final_lines.push(single);
            }
        } else {
            final_lines.push(single);
        }
    }

    let total_text_h = final_lines.len() as f32 * line_height;
    let start_y = match v_align {
        TextVAlign::Top => inner_y,
        TextVAlign::Middle => inner_y + ((inner_h - total_text_h) * 0.5).max(0.0),
        TextVAlign::Bottom => (inner_y + inner_h - total_text_h).max(inner_y),
    };

    final_lines
        .into_iter()
        .enumerate()
        .map(|(i, line)| {
            let line_w = measure_text_cached(&mut width_cache, &line, style, font);
            let lx = match h_align {
                "left" => inner_x + 4.0,
                "right" => (inner_x + inner_w - line_w - 6.0).max(inner_x),
                _ => inner_x + ((inner_w - line_w) * 0.5).max(0.0),
            };
            let line_box_y = start_y + i as f32 * line_height;
            let ly = text_origin_y(&line, line_box_y, line_height, style, font);
            TextLine {
                text: line,
                x: lx,
                y: ly,
                clip_rect: clip,
            }
        })
        .collect()
}

#[allow(dead_code)]
fn cpu_text_height(font: Option<&crate::font::Font>) -> i32 {
    font.map(|f| f.size().round() as i32).unwrap_or(7).max(1)
}

#[allow(dead_code)]
fn cpu_text_center_y(font: Option<&crate::font::Font>, y: i32, h: i32) -> i32 {
    y + ((h - cpu_text_height(font)) / 2).max(0)
}

/// Return the primary display text of text-bearing widget variants, or `None` for all others.
fn display_text(widget: &WidgetKind) -> Option<&str> {
    let text = match widget {
        WidgetKind::Button(w) => &w.text,
        WidgetKind::Label(w) => &w.text,
        WidgetKind::CheckBox(w) => &w.text,
        WidgetKind::RadioButton(w) => &w.text,
        WidgetKind::MenuItem(w) => &w.text,
        _ => return None,
    };
    if text.is_empty() {
        None
    } else {
        Some(text)
    }
}

fn emit_text_lines(
    lines: Vec<TextLine>,
    font_key: FontKey,
    font: Option<&Font>,
    style: &WidgetStyle,
    cmds: &mut Vec<RenderCommand>,
) {
    for line in lines {
        cmds.push(RenderCommand::SetScissor(Some((
            line.clip_rect.x,
            line.clip_rect.y,
            line.clip_rect.width,
            line.clip_rect.height,
        ))));
        emit_text_at(&line.text, line.x, line.y, font_key, font, style, cmds);
    }
    cmds.push(RenderCommand::SetScissor(None));
}

fn emit_multiline_text_box(
    text: &str,
    base: &WidgetBase,
    scroll_y: f32,
    font_key: FontKey,
    font: Option<&Font>,
    style: &WidgetStyle,
    cmds: &mut Vec<RenderCommand>,
) {
    let rect = Rect::new(
        base.x,
        base.y - scroll_y.max(0.0),
        base.width,
        base.height + scroll_y.max(0.0),
    );
    let mut lines = layout_text(
        text,
        rect,
        style,
        font,
        true,
        false,
        TextVAlign::Top,
        base.padding,
        &base.text_align,
    );
    let clip = Rect::new(base.x, base.y, base.width, base.height);
    for line in &mut lines {
        line.clip_rect = clip;
    }
    emit_text_lines(lines, font_key, font, style, cmds);
}

fn widget_icon_glyph(base: &WidgetBase) -> Option<&'static str> {
    base.icon
        .as_deref()
        .and_then(crate::ui::lookup_icon)
        .map(|icon| icon.glyph)
}

fn icon_style(base: &WidgetBase, style: &WidgetStyle) -> WidgetStyle {
    let mut icon_style = style.clone();
    if base.icon_size > 0.0 {
        icon_style.font_size = base.icon_size;
    }
    icon_style
}

fn emit_icon_and_text(
    base: &WidgetBase,
    text: Option<&str>,
    font_key: FontKey,
    font: Option<&Font>,
    style: &WidgetStyle,
    cmds: &mut Vec<RenderCommand>,
) {
    let Some(glyph) = widget_icon_glyph(base) else {
        if let Some(text) = text {
            emit_text(base, text, style, font_key, font, cmds);
        }
        return;
    };
    let icon_style = icon_style(base, style);
    let icon_w = measure_text(glyph, &icon_style, font);
    let icon_h = icon_style.font_size;
    let text = match base.icon_position {
        crate::ui::UiIconPosition::Only => None,
        _ => text,
    };
    let gap = if text.is_some() { 6.0 } else { 0.0 };
    match (base.icon_position, text) {
        (crate::ui::UiIconPosition::Right, Some(text)) => {
            let text_w = measure_text(text, style, font);
            let total_w = icon_w + gap + text_w;
            let x = base.x + ((base.width - total_w) * 0.5).max(0.0);
            let y = text_origin_y(text, base.y, base.height, style, font);
            emit_text_at(text, x, y, font_key, font, style, cmds);
            emit_text_at(
                glyph,
                x + text_w + gap,
                text_origin_y(glyph, base.y, base.height, &icon_style, font),
                font_key,
                font,
                &icon_style,
                cmds,
            );
        }
        (crate::ui::UiIconPosition::Top, Some(text)) => {
            let text_w = measure_text(text, style, font);
            let total_h = icon_h + gap + style.font_size;
            let y = base.y + ((base.height - total_h) * 0.5).max(0.0);
            emit_text_at(
                glyph,
                base.x + ((base.width - icon_w) * 0.5).max(0.0),
                text_origin_y(glyph, y, icon_h, &icon_style, font),
                font_key,
                font,
                &icon_style,
                cmds,
            );
            emit_text_at(
                text,
                base.x + ((base.width - text_w) * 0.5).max(0.0),
                y + icon_h + gap,
                font_key,
                font,
                style,
                cmds,
            );
        }
        (crate::ui::UiIconPosition::Bottom, Some(text)) => {
            let text_w = measure_text(text, style, font);
            let total_h = icon_h + gap + style.font_size;
            let y = base.y + ((base.height - total_h) * 0.5).max(0.0);
            emit_text_at(
                text,
                base.x + ((base.width - text_w) * 0.5).max(0.0),
                text_origin_y(text, y, style.font_size, style, font),
                font_key,
                font,
                style,
                cmds,
            );
            emit_text_at(
                glyph,
                base.x + ((base.width - icon_w) * 0.5).max(0.0),
                y + style.font_size + gap,
                font_key,
                font,
                &icon_style,
                cmds,
            );
        }
        (_, Some(text)) => {
            let text_w = measure_text(text, style, font);
            let total_w = icon_w + gap + text_w;
            let x = base.x + ((base.width - total_w) * 0.5).max(0.0);
            emit_text_at(
                glyph,
                x,
                text_origin_y(glyph, base.y, base.height, &icon_style, font),
                font_key,
                font,
                &icon_style,
                cmds,
            );
            emit_text_at(
                text,
                x + icon_w + gap,
                text_origin_y(text, base.y, base.height, style, font),
                font_key,
                font,
                style,
                cmds,
            );
        }
        (_, None) => {
            emit_text_at(
                glyph,
                base.x + ((base.width - icon_w) * 0.5).max(0.0),
                text_origin_y(glyph, base.y, base.height, &icon_style, font),
                font_key,
                font,
                &icon_style,
                cmds,
            );
        }
    }
}
/// Convert HSV in `[0.0, 1.0]` to 8-bit `(R, G, B)` using a six-sector conversion.
#[allow(dead_code)] // Transitional compatibility helper; software replay owns production capture.
fn hsv_to_rgb(h: f32, s: f32, v: f32) -> (u8, u8, u8) {
    let h6 = (h * 6.0).rem_euclid(6.0);
    let i = h6 as u32;
    let f = h6 - i as f32;
    let p = v * (1.0 - s);
    let q = v * (1.0 - s * f);
    let t = v * (1.0 - s * (1.0 - f));
    let (r, g, b) = match i {
        0 => (v, t, p),
        1 => (q, v, p),
        2 => (p, v, t),
        3 => (p, q, v),
        4 => (t, p, v),
        _ => (v, p, q),
    };
    ((r * 255.0) as u8, (g * 255.0) as u8, (b * 255.0) as u8)
}
/// Draw `text` into `img` using the bundled bitmap font if available, falling back to the 5Ă—7 bitmap.
#[allow(clippy::too_many_arguments)]
#[allow(dead_code)] // Transitional compatibility helper; software replay owns production capture.
fn draw_cpu_text(
    img: &mut crate::image::ImageData,
    font: Option<&crate::font::Font>,
    text: &str,
    x: i32,
    y: i32,
    r: u8,
    g: u8,
    b: u8,
) {
    if let Some(f) = font {
        img.draw_text_with_font(text, x, y, r, g, b, f);
    } else {
        img.draw_label(text, x, y, r, g, b);
    }
}

#[allow(clippy::too_many_arguments)]
#[allow(dead_code)] // Transitional compatibility helper; software replay owns production capture.
fn draw_cpu_icon_and_text(
    img: &mut crate::image::ImageData,
    font: Option<&crate::font::Font>,
    base: &WidgetBase,
    text: Option<&str>,
    x: i32,
    y: i32,
    w: u32,
    h: u32,
    style: &WidgetStyle,
    r: u8,
    g: u8,
    b: u8,
) {
    let Some(glyph) = widget_icon_glyph(base) else {
        if let Some(text) = text {
            let approx_w = font
                .map(|f| f.text_width(text) as i32)
                .unwrap_or((text.chars().count() as i32) * 6);
            let tx = match style.text_align.as_str() {
                "left" => x + base.padding[3] as i32 + 4,
                "right" => x + w as i32 - approx_w - 6,
                _ => x + ((w as i32 - approx_w) / 2).max(2),
            };
            let ty = cpu_text_center_y(font, y, h as i32);
            draw_cpu_text(img, font, text, tx, ty, r, g, b);
        }
        return;
    };
    let text = match base.icon_position {
        crate::ui::UiIconPosition::Only => None,
        _ => text,
    };
    let glyph_w = font
        .map(|f| f.text_width(glyph) as i32)
        .unwrap_or((glyph.chars().count() as i32) * 6);
    let glyph_h = cpu_text_height(font);
    let gap = if text.is_some() { 6 } else { 0 };
    match (base.icon_position, text) {
        (crate::ui::UiIconPosition::Right, Some(text)) => {
            let text_w = font
                .map(|f| f.text_width(text) as i32)
                .unwrap_or((text.chars().count() as i32) * 6);
            let total_w = text_w + gap + glyph_w;
            let tx = x + ((w as i32 - total_w) / 2).max(2);
            let ty = y + ((h as i32 - glyph_h) / 2).max(1);
            draw_cpu_text(img, font, text, tx, ty, r, g, b);
            draw_cpu_text(img, font, glyph, tx + text_w + gap, ty, r, g, b);
        }
        (crate::ui::UiIconPosition::Top, Some(text)) => {
            let text_w = font
                .map(|f| f.text_width(text) as i32)
                .unwrap_or((text.chars().count() as i32) * 6);
            let total_h = glyph_h * 2 + gap;
            let iy = y + ((h as i32 - total_h) / 2).max(1);
            draw_cpu_text(
                img,
                font,
                glyph,
                x + ((w as i32 - glyph_w) / 2).max(2),
                iy,
                r,
                g,
                b,
            );
            draw_cpu_text(
                img,
                font,
                text,
                x + ((w as i32 - text_w) / 2).max(2),
                iy + glyph_h + gap,
                r,
                g,
                b,
            );
        }
        (crate::ui::UiIconPosition::Bottom, Some(text)) => {
            let text_w = font
                .map(|f| f.text_width(text) as i32)
                .unwrap_or((text.chars().count() as i32) * 6);
            let total_h = glyph_h * 2 + gap;
            let ty = y + ((h as i32 - total_h) / 2).max(1);
            draw_cpu_text(
                img,
                font,
                text,
                x + ((w as i32 - text_w) / 2).max(2),
                ty,
                r,
                g,
                b,
            );
            draw_cpu_text(
                img,
                font,
                glyph,
                x + ((w as i32 - glyph_w) / 2).max(2),
                ty + glyph_h + gap,
                r,
                g,
                b,
            );
        }
        (_, Some(text)) => {
            let text_w = font
                .map(|f| f.text_width(text) as i32)
                .unwrap_or((text.chars().count() as i32) * 6);
            let total_w = glyph_w + gap + text_w;
            let ix = x + ((w as i32 - total_w) / 2).max(2);
            let iy = y + ((h as i32 - glyph_h) / 2).max(1);
            draw_cpu_text(img, font, glyph, ix, iy, r, g, b);
            draw_cpu_text(img, font, text, ix + glyph_w + gap, iy, r, g, b);
        }
        (_, None) => {
            draw_cpu_text(
                img,
                font,
                glyph,
                x + ((w as i32 - glyph_w) / 2).max(2),
                y + ((h as i32 - glyph_h) / 2).max(1),
                r,
                g,
                b,
            );
        }
    }
}

/// Recursively draw tree node `idx` and its expanded children into `img` as labelled rows; return next Y.
#[allow(clippy::too_many_arguments)]
fn resolve_style_with_alpha(
    ctx: &GuiContext,
    base: &WidgetBase,
    default_style: &WidgetStyle,
) -> WidgetStyle {
    let style = ctx
        .theme
        .as_ref()
        .and_then(|t| {
            t.get_style_with_class(base.widget_type, base.state, base.style_class.as_deref())
        })
        .unwrap_or(default_style);
    let mut style_with_alpha = style.clone();
    let alpha = base.alpha.clamp(0.0, 1.0);
    style_with_alpha.bg_color[3] *= alpha;
    style_with_alpha.fg_color[3] *= alpha;
    style_with_alpha.border_color[3] *= alpha;
    style_with_alpha.shadow_color[3] *= alpha;
    style_with_alpha.highlight_alpha *= alpha;
    style_with_alpha
}

// â”€â”€ Feature 5: Scissor Stack for Nested Clipping â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

/// Push a scissor rect onto the stack, intersecting with the current topmost scissor.
pub fn push_scissor(
    cmds: &mut Vec<RenderCommand>,
    stack: &mut Vec<(f32, f32, f32, f32)>,
    rect: Rect,
) {
    let new_scissor = if let Some(&(sx, sy, sw, sh)) = stack.last() {
        let x1 = rect.x.max(sx);
        let y1 = rect.y.max(sy);
        let x2 = (rect.x + rect.width).min(sx + sw);
        let y2 = (rect.y + rect.height).min(sy + sh);
        let w = (x2 - x1).max(0.0);
        let h = (y2 - y1).max(0.0);
        (x1, y1, w, h)
    } else {
        (rect.x, rect.y, rect.width, rect.height)
    };
    stack.push(new_scissor);
    cmds.push(RenderCommand::SetScissor(Some(new_scissor)));
}

/// Pop the topmost scissor rect and restore the previous one (or disable scissor if stack is empty).
pub fn pop_scissor(cmds: &mut Vec<RenderCommand>, stack: &mut Vec<(f32, f32, f32, f32)>) {
    stack.pop();
    let restore = stack.last().copied();
    cmds.push(RenderCommand::SetScissor(restore));
}

/// Temporary borrow-carrier used to thread `ctx`, font, and output buffer through widget rendering.
struct WidgetRenderer<'a> {
    /// Shared GUI context providing widget list and theme.
    ctx: &'a GuiContext,
    /// Font key passed to all text-emit helpers.
    font_key: FontKey,
    /// Shared font storage for resolving exact glyph metrics.
    fonts: &'a SlotMap<FontKey, Font>,
    /// Fallback widget style used when the theme has no entry for a widget type.
    default_style: &'a WidgetStyle,
    /// Output command buffer accumulated during a render pass.
    cmds: &'a mut Vec<RenderCommand>,
}
impl<'a> WidgetRenderer<'a> {
    /// Create a renderer borrowing `ctx`, `font_key`, `default_style`, and output `cmds`.
    fn new(
        ctx: &'a GuiContext,
        font_key: FontKey,
        fonts: &'a SlotMap<FontKey, Font>,
        default_style: &'a WidgetStyle,
        cmds: &'a mut Vec<RenderCommand>,
    ) -> Self {
        Self {
            ctx,
            font_key,
            fonts,
            default_style,
            cmds,
        }
    }

    /// Render all immediate children of the root widget (index 0).
    fn render_root_children(&mut self) {
        let root_font_key = self
            .ctx
            .widgets
            .first()
            .and_then(|w| w.base().font_key)
            .unwrap_or(self.font_key);
        if let Some(children) = self.ctx.widgets.first().and_then(|w| w.children()) {
            let root_shader = self.ctx.widgets.first().and_then(|widget| {
                let base = widget.base();
                base.shader.or_else(|| first_named_shader_layer(base))
            });
            if let Some(shader) = root_shader {
                self.cmds.push(RenderCommand::SetShader(Some(shader)));
            }
            let mut sorted = children.to_vec();
            sorted.sort_by_key(|&i| {
                self.ctx
                    .widgets
                    .get(i)
                    .map(|w| w.base().z_order)
                    .unwrap_or(0)
            });
            let active_modal = topmost_modal_dialog(self.ctx);
            let mut scrim_drawn = false;
            for child_idx in sorted {
                if child_idx < self.ctx.widgets.len() {
                    if !scrim_drawn && active_modal == Some(child_idx) {
                        emit_modal_scrim(self.ctx, self.cmds);
                        scrim_drawn = true;
                    }
                    render_widget(
                        self.ctx,
                        child_idx,
                        root_font_key,
                        self.fonts,
                        self.default_style,
                        root_shader,
                        self.cmds,
                    );
                }
            }
            if root_shader.is_some() {
                self.cmds.push(RenderCommand::SetShader(None));
            }
        }
    }
}
/// Emit all `RenderCommand`s for the widget at `idx` and its visible descendants, using `font_key` and `default_style`.
fn render_widget(
    ctx: &GuiContext,
    idx: usize,
    font_key: FontKey,
    fonts: &SlotMap<FontKey, Font>,
    default_style: &WidgetStyle,
    inherited_shader: Option<ShaderKey>,
    cmds: &mut Vec<RenderCommand>,
) {
    render_widget_inner(
        ctx,
        idx,
        font_key,
        fonts,
        default_style,
        inherited_shader,
        cmds,
        0,
    );
}

#[allow(clippy::too_many_arguments)]
fn render_widget_inner(
    ctx: &GuiContext,
    idx: usize,
    font_key: FontKey,
    fonts: &SlotMap<FontKey, Font>,
    default_style: &WidgetStyle,
    inherited_shader: Option<ShaderKey>,
    cmds: &mut Vec<RenderCommand>,
    depth: usize,
) {
    if depth > ctx.limits().max_tree_depth {
        return;
    }
    if idx >= ctx.widgets.len() || !ctx.widget_is_live(idx) {
        return;
    }
    let widget = &ctx.widgets[idx];
    let raw_base = widget.base();
    if !raw_base.visible
        || !raw_base.is_visible
        || matches!(widget, WidgetKind::Dialog(dialog) if !dialog.open)
    {
        return;
    }
    // Use computed_rect for absolute screen coordinates; fall back to raw fields if layout has not run.
    let patched;
    let base: &WidgetBase =
        if raw_base.computed_rect.width > 0.0 || raw_base.computed_rect.height > 0.0 {
            patched = WidgetBase {
                x: raw_base.computed_rect.x,
                y: raw_base.computed_rect.y,
                width: raw_base.computed_rect.width,
                height: raw_base.computed_rect.height,
                ..raw_base.clone()
            };
            &patched
        } else {
            raw_base
        };
    let font_key = base.font_key.unwrap_or(font_key);
    let local_shader = base.shader.or_else(|| first_named_shader_layer(base));
    let effective_shader = local_shader.or(inherited_shader);
    if let Some(shader) = local_shader {
        cmds.push(RenderCommand::SetShader(Some(shader)));
    }
    let font = fonts.get(font_key);
    let style_with_alpha = resolve_style_with_alpha(ctx, base, default_style);
    let style = &style_with_alpha;
    let draw_widget_chrome = !matches!(
        widget,
        WidgetKind::Label(_)
            | WidgetKind::RichLabel(_)
            | WidgetKind::AspectRatioContainer(_)
            | WidgetKind::DockPanel(_)
    );
    if draw_widget_chrome {
        emit_shadow(base, style, cmds);
        emit_box(base, style, cmds);
        if style.highlight_alpha > 0.0 {
            emit_highlight(base, style, cmds);
        }
    }
    match widget {
        WidgetKind::Slider(w) => {
            emit_slider(base, w.value, w.min, w.max, style, cmds);
        }
        WidgetKind::SpinBox(w) => {
            emit_progress_bar(base, w.value, w.min, w.max, style, cmds);
            emit_spin_box(base, style, cmds);
            emit_text_centered_vertically(
                &format!("{}", w.value),
                TextVerticalBox::new(base.x + 8.0, base.y, base.height),
                font_key,
                font,
                style,
                cmds,
            );
        }
        WidgetKind::ProgressBar(w) => {
            emit_progress_bar(base, w.value, w.min, w.max, style, cmds);
            let range = (w.max - w.min).max(1e-6);
            let pct = (((w.value - w.min) / range).clamp(0.0, 1.0) * 100.0).round() as i32;
            emit_text_centered_vertically(
                &format!("{pct}%"),
                TextVerticalBox::new(base.x + (base.width - 24.0) * 0.5, base.y, base.height),
                font_key,
                font,
                style,
                cmds,
            );
        }
        WidgetKind::CheckBox(w) => {
            if w.checked {
                emit_checkbox(base, style, cmds);
            }
            if !w.text.is_empty() {
                emit_text_centered_vertically(
                    &w.text,
                    TextVerticalBox::new(base.x + base.height + 6.0, base.y, base.height),
                    font_key,
                    font,
                    style,
                    cmds,
                );
            }
        }
        WidgetKind::RadioButton(w) => {
            if w.selected {
                emit_radio_button(base, style, cmds);
            }
            if !w.text.is_empty() {
                emit_text_centered_vertically(
                    &w.text,
                    TextVerticalBox::new(base.x + base.height + 6.0, base.y, base.height),
                    font_key,
                    font,
                    style,
                    cmds,
                );
            }
        }
        WidgetKind::TextInput(w) => {
            if let Some((sel_start, sel_end)) = w.selection_range() {
                let selection_x = base.x
                    + base.padding[3]
                    + 4.0
                    + measure_text(&w.text[..sel_start.min(w.text.len())], style, font);
                let selection_end_x = base.x
                    + base.padding[3]
                    + 4.0
                    + measure_text(&w.text[..sel_end.min(w.text.len())], style, font);
                let selection_width = (selection_end_x - selection_x).max(0.0);
                if selection_width > 0.0 {
                    cmds.push(RenderCommand::SetColor(
                        style.fg_color[0],
                        style.fg_color[1],
                        style.fg_color[2],
                        0.22,
                    ));
                    cmds.push(RenderCommand::Rectangle {
                        mode: DrawMode::Fill,
                        x: selection_x,
                        y: base.y + 3.0,
                        w: selection_width,
                        h: (base.height - 6.0).max(0.0),
                    });
                }
            }
            let content = if w.text.is_empty() {
                w.placeholder.as_str()
            } else {
                w.text.as_str()
            };
            if !content.is_empty() {
                let [tr, tg, tb, ta] = if w.text.is_empty() {
                    [0.55, 0.57, 0.64, 1.0]
                } else {
                    style.fg_color
                };
                let mut text_style = style.clone();
                text_style.fg_color = [tr, tg, tb, ta];
                emit_text_centered_vertically(
                    content,
                    TextVerticalBox::new(base.x + base.padding[3] + 4.0, base.y, base.height),
                    font_key,
                    font,
                    &text_style,
                    cmds,
                );
            }
            if w.focused {
                let cursor_x = base.x
                    + base.padding[3]
                    + 4.0
                    + measure_text(&w.text[..w.cursor_pos.min(w.text.len())], style, font);
                cmds.push(RenderCommand::SetColor(
                    style.fg_color[0],
                    style.fg_color[1],
                    style.fg_color[2],
                    0.9,
                ));
                cmds.push(RenderCommand::Rectangle {
                    mode: DrawMode::Fill,
                    x: cursor_x,
                    y: base.y + 3.0,
                    w: 1.0,
                    h: (base.height - 6.0).max(0.0),
                });
            }
        }
        WidgetKind::TextArea(w) => {
            if let Some((sel_start, sel_end)) = w.selection_range() {
                let before = &w.text[..sel_start.min(w.text.len())];
                let selected = &w.text[sel_start.min(w.text.len())..sel_end.min(w.text.len())];
                let before_line = before.rsplit('\n').next().unwrap_or_default();
                let selected_w = measure_text(selected, style, font);
                let line_idx = before.chars().filter(|ch| *ch == '\n').count() as f32;
                let selection_x =
                    base.x + base.padding[3] + 4.0 + measure_text(before_line, style, font);
                let selection_y =
                    base.y + base.padding[0] + line_idx * text_line_advance(style, font)
                        - w.scroll_y.max(0.0);
                if selected_w > 0.0 && selection_y + text_line_advance(style, font) >= base.y {
                    cmds.push(RenderCommand::SetColor(
                        style.fg_color[0],
                        style.fg_color[1],
                        style.fg_color[2],
                        0.22,
                    ));
                    cmds.push(RenderCommand::Rectangle {
                        mode: DrawMode::Fill,
                        x: selection_x,
                        y: selection_y.max(base.y),
                        w: selected_w,
                        h: text_line_advance(style, font).min(base.y + base.height - selection_y),
                    });
                }
            }
            let content = if w.text.is_empty() {
                w.placeholder.as_str()
            } else {
                w.text.as_str()
            };
            if !content.is_empty() {
                let mut text_style = style.clone();
                if w.text.is_empty() {
                    text_style.fg_color = [0.55, 0.57, 0.64, 1.0];
                }
                emit_multiline_text_box(
                    content,
                    base,
                    if w.text.is_empty() { 0.0 } else { w.scroll_y },
                    font_key,
                    font,
                    &text_style,
                    cmds,
                );
            }
            if w.focused {
                let before_cursor = &w.text[..w.cursor_pos.min(w.text.len())];
                let line = before_cursor.chars().filter(|ch| *ch == '\n').count();
                let prefix = before_cursor.rsplit('\n').next().unwrap_or_default();
                let cursor_x = base.x + base.padding[3] + 4.0 + measure_text(prefix, style, font);
                let cursor_y =
                    base.y + base.padding[0] + line as f32 * text_line_advance(style, font)
                        - w.scroll_y.max(0.0);
                if cursor_y + text_line_advance(style, font) >= base.y
                    && cursor_y <= base.y + base.height
                {
                    cmds.push(RenderCommand::SetColor(
                        style.fg_color[0],
                        style.fg_color[1],
                        style.fg_color[2],
                        0.9,
                    ));
                    cmds.push(RenderCommand::Rectangle {
                        mode: DrawMode::Fill,
                        x: cursor_x,
                        y: cursor_y.max(base.y + 2.0),
                        w: 1.0,
                        h: (text_line_advance(style, font) - 2.0)
                            .min(base.y + base.height - cursor_y)
                            .max(0.0),
                    });
                }
            }
        }
        WidgetKind::RichLabel(w) => {
            emit_multiline_text_box(&w.plain_text(), base, 0.0, font_key, font, style, cmds);
        }
        WidgetKind::ComboBox(w) => {
            emit_combo_box_arrow(base, style, cmds);
            if let Some(text) = w.selected_item() {
                emit_text_centered_vertically(
                    text,
                    TextVerticalBox::new(base.x + 6.0, base.y, base.height),
                    font_key,
                    font,
                    style,
                    cmds,
                );
            }
            if w.open && !w.items.is_empty() {
                if let Some((drop_rect, row_h, start, end, scroll_offset, _visible_rows)) =
                    ctx.combo_dropdown_metrics(idx)
                {
                    cmds.push(RenderCommand::SetColor(0.10, 0.11, 0.16, 1.0));
                    cmds.push(RenderCommand::Rectangle {
                        mode: DrawMode::Fill,
                        x: drop_rect.x,
                        y: drop_rect.y,
                        w: drop_rect.width,
                        h: drop_rect.height,
                    });
                    for (item_idx, item) in w.items.iter().enumerate().skip(start).take(end - start)
                    {
                        let row_y = drop_rect.y + (item_idx - start) as f32 * row_h - scroll_offset;
                        if row_y + row_h <= drop_rect.y || row_y >= drop_rect.y + drop_rect.height {
                            continue;
                        }
                        if w.selected_index == Some(item_idx) {
                            cmds.push(RenderCommand::SetColor(0.22, 0.36, 0.60, 0.85));
                            cmds.push(RenderCommand::Rectangle {
                                mode: DrawMode::Fill,
                                x: drop_rect.x + 1.0,
                                y: row_y,
                                w: (drop_rect.width - 2.0).max(0.0),
                                h: row_h,
                            });
                        }
                        emit_text_centered_vertically(
                            item,
                            TextVerticalBox::new(drop_rect.x + 6.0, row_y, row_h),
                            font_key,
                            font,
                            style,
                            cmds,
                        );
                        cmds.push(RenderCommand::SetColor(0.22, 0.24, 0.30, 0.60));
                        cmds.push(RenderCommand::Rectangle {
                            mode: DrawMode::Fill,
                            x: drop_rect.x,
                            y: row_y + row_h - 1.0,
                            w: drop_rect.width,
                            h: 1.0,
                        });
                    }
                }
            }
        }
        WidgetKind::ListBox(w) => {
            let row_h = w.item_height.max(14.0);
            let first_row = (w.scroll_y / row_h).floor().max(0.0) as usize;
            let scroll_offset = w.scroll_y - first_row as f32 * row_h;
            for (row_idx, item) in w.items.iter().enumerate().skip(first_row) {
                let row_y = base.y + (row_idx - first_row) as f32 * row_h - scroll_offset;
                if row_y + row_h > base.y + base.height {
                    break;
                }
                if w.selected_index == Some(row_idx) {
                    cmds.push(RenderCommand::SetColor(0.22, 0.36, 0.60, 0.80));
                    cmds.push(RenderCommand::Rectangle {
                        mode: DrawMode::Fill,
                        x: base.x + 1.0,
                        y: row_y,
                        w: (base.width - 2.0).max(0.0),
                        h: row_h,
                    });
                }
                emit_text_centered_vertically(
                    item,
                    TextVerticalBox::new(base.x + 6.0, row_y, row_h),
                    font_key,
                    font,
                    style,
                    cmds,
                );
                cmds.push(RenderCommand::SetColor(0.22, 0.24, 0.30, 0.60));
                cmds.push(RenderCommand::Rectangle {
                    mode: DrawMode::Fill,
                    x: base.x,
                    y: row_y + row_h - 1.0,
                    w: base.width,
                    h: 1.0,
                });
            }
        }
        WidgetKind::TabBar(w) => {
            if !w.tabs.is_empty() {
                let tab_w = (base.width / w.tabs.len() as f32).max(24.0);
                for (tab_idx, tab) in w.tabs.iter().enumerate() {
                    let tab_x = base.x + tab_idx as f32 * tab_w;
                    let active = tab_idx == w.active_tab;
                    cmds.push(RenderCommand::SetColor(
                        if active { 0.20 } else { 0.13 },
                        if active { 0.24 } else { 0.14 },
                        if active { 0.34 } else { 0.18 },
                        1.0,
                    ));
                    cmds.push(RenderCommand::Rectangle {
                        mode: DrawMode::Fill,
                        x: tab_x,
                        y: base.y,
                        w: tab_w,
                        h: base.height,
                    });
                    if active {
                        cmds.push(RenderCommand::SetColor(
                            style.fg_color[0],
                            style.fg_color[1],
                            style.fg_color[2],
                            1.0,
                        ));
                        cmds.push(RenderCommand::Rectangle {
                            mode: DrawMode::Fill,
                            x: tab_x,
                            y: base.y,
                            w: tab_w,
                            h: 2.0,
                        });
                    }
                    emit_text_centered_vertically(
                        tab,
                        TextVerticalBox::new(
                            tab_x + (tab_w - measure_text(tab, style, font)) * 0.5,
                            base.y,
                            base.height,
                        ),
                        font_key,
                        font,
                        style,
                        cmds,
                    );
                }
            }
        }
        WidgetKind::Toast(w) => {
            cmds.push(RenderCommand::SetColor(
                style.border_color[0],
                style.border_color[1],
                style.border_color[2],
                style.border_color[3],
            ));
            cmds.push(RenderCommand::Rectangle {
                mode: DrawMode::Fill,
                x: base.x,
                y: base.y,
                w: 4.0,
                h: base.height,
            });
            emit_text_at(
                &w.message,
                base.x + 10.0,
                base.y + (base.height - style.font_size) * 0.5,
                font_key,
                font,
                style,
                cmds,
            );
        }
        WidgetKind::Separator(w) => {
            cmds.push(RenderCommand::SetColor(
                style.fg_color[0],
                style.fg_color[1],
                style.fg_color[2],
                0.7,
            ));
            if w.vertical {
                cmds.push(RenderCommand::Rectangle {
                    mode: DrawMode::Fill,
                    x: base.x + (base.width - w.thickness) * 0.5,
                    y: base.y,
                    w: w.thickness.max(1.0),
                    h: base.height,
                });
            } else {
                cmds.push(RenderCommand::Rectangle {
                    mode: DrawMode::Fill,
                    x: base.x,
                    y: base.y + (base.height - w.thickness) * 0.5,
                    w: base.width,
                    h: w.thickness.max(1.0),
                });
            }
        }
        WidgetKind::TreeView(w) => {
            let mut row_y = base.y + 4.0;
            let mut ctx = TreeCtx {
                nodes: &w.nodes,
                selected: w.selected_node,
                font_key,
                font,
                style,
                cmds,
            };
            for &root_idx in &w.root_nodes {
                row_y = emit_tree_nodes(&mut ctx, root_idx, base.x + 4.0, row_y, 20.0, 0);
            }
        }
        WidgetKind::ScrollBar(w) => {
            emit_scroll_bar(
                base,
                w.position,
                w.content_size,
                w.view_size,
                w.vertical,
                style,
                cmds,
            );
        }
        WidgetKind::Switch(w) => {
            emit_switch(base, w.on, w.thumb_t, style, cmds);
        }
        WidgetKind::Badge(w) => {
            emit_badge(base, &w.display_text(), font_key, font, style, cmds);
        }
        WidgetKind::GUIWindow(w) => {
            cmds.push(RenderCommand::SetColor(0.12, 0.14, 0.19, 0.96));
            cmds.push(RenderCommand::RoundedRectangle {
                mode: DrawMode::Fill,
                x: base.x,
                y: base.y,
                w: base.width,
                h: base.height,
                rx: style.corner_radius + 2.0,
                ry: style.corner_radius + 2.0,
            });
            cmds.push(RenderCommand::SetColor(0.18, 0.22, 0.32, 1.0));
            cmds.push(RenderCommand::RoundedRectangle {
                mode: DrawMode::Fill,
                x: base.x,
                y: base.y,
                w: base.width,
                h: 24.0,
                rx: style.corner_radius,
                ry: style.corner_radius,
            });
            emit_text_at(
                &w.title,
                base.x + 10.0,
                base.y + 5.0,
                font_key,
                font,
                style,
                cmds,
            );
            if w.closeable {
                cmds.push(RenderCommand::SetColor(0.85, 0.35, 0.35, 1.0));
                cmds.push(RenderCommand::Line {
                    x1: base.x + base.width - 16.0,
                    y1: base.y + 7.0,
                    x2: base.x + base.width - 8.0,
                    y2: base.y + 15.0,
                });
                cmds.push(RenderCommand::Line {
                    x1: base.x + base.width - 8.0,
                    y1: base.y + 7.0,
                    x2: base.x + base.width - 16.0,
                    y2: base.y + 15.0,
                });
            }
            if w.resizable {
                cmds.push(RenderCommand::SetColor(0.66, 0.70, 0.78, 0.9));
                cmds.push(RenderCommand::Line {
                    x1: base.x + base.width - 14.0,
                    y1: base.y + base.height - 6.0,
                    x2: base.x + base.width - 6.0,
                    y2: base.y + base.height - 14.0,
                });
                cmds.push(RenderCommand::Line {
                    x1: base.x + base.width - 10.0,
                    y1: base.y + base.height - 6.0,
                    x2: base.x + base.width - 6.0,
                    y2: base.y + base.height - 10.0,
                });
            }
        }
        WidgetKind::SplitPanel(w) => {
            cmds.push(RenderCommand::SetColor(0.26, 0.28, 0.34, 1.0));
            if w.orientation == "vertical" {
                let split_y = base.y + base.height * w.split_position.clamp(0.0, 1.0);
                cmds.push(RenderCommand::Rectangle {
                    mode: DrawMode::Fill,
                    x: base.x,
                    y: split_y - 1.0,
                    w: base.width,
                    h: 3.0,
                });
            } else {
                let split_x = base.x + base.width * w.split_position.clamp(0.0, 1.0);
                cmds.push(RenderCommand::Rectangle {
                    mode: DrawMode::Fill,
                    x: split_x - 1.0,
                    y: base.y,
                    w: 3.0,
                    h: base.height,
                });
            }
        }
        WidgetKind::Toolbar(w) => {
            let vertical = w.orientation == "vertical";
            let button_size = if vertical { base.width.min(28.0) } else { base.height.min(28.0) };
            let main_extent = if vertical { base.height } else { base.width };
            let flexible = w.items.iter().filter(|item| matches!(item, ToolbarItem::Spacer(None))).count();
            let fixed_spacers: f32 = w.items.iter().map(|item| match item { ToolbarItem::Spacer(Some(size)) => size.max(0.0), _ => 0.0 }).sum();
            let button_count = w.items.iter().filter(|item| matches!(item, ToolbarItem::Button(_))).count() as f32;
            let separator_count = w.items.iter().filter(|item| matches!(item, ToolbarItem::Separator)).count() as f32;
            let remaining = (main_extent - 8.0 - button_count * (button_size + 4.0) - separator_count * 9.0 - fixed_spacers).max(0.0);
            let mut main = if vertical { base.y + 4.0 } else { base.x + 4.0 };
            for item in &w.items {
                match item {
                ToolbarItem::Separator => {
                    cmds.push(RenderCommand::SetColor(0.32, 0.35, 0.42, 1.0));
                    let (x, y, width, height) = if vertical {
                        (base.x + 5.0, main + 3.0, (base.width - 10.0).max(1.0), 1.0)
                    } else {
                        (main + 3.0, base.y + 5.0, 1.0, (base.height - 10.0).max(1.0))
                    };
                    cmds.push(RenderCommand::Rectangle { mode: DrawMode::Fill, x, y, w: width, h: height });
                    main += 9.0;
                }
                ToolbarItem::Spacer(size) => { main += size.unwrap_or_else(|| if flexible == 0 { 0.0 } else { remaining / flexible as f32 }).max(0.0); }
                ToolbarItem::Button(button) => {
                cmds.push(RenderCommand::SetColor(
                    if button.toggled { 0.22 } else { 0.16 },
                    if button.toggled { 0.36 } else { 0.18 },
                    if button.toggled { 0.56 } else { 0.24 },
                    1.0,
                ));
                cmds.push(RenderCommand::RoundedRectangle {
                    mode: DrawMode::Fill,
                    x: if vertical { base.x + (base.width - button_size) * 0.5 } else { main },
                    y: if vertical { main } else { base.y + (base.height - button_size) * 0.5 },
                    w: button_size,
                    h: button_size,
                    rx: 4.0,
                    ry: 4.0,
                });
                let label = button
                    .id
                    .chars()
                    .next()
                    .unwrap_or('?')
                    .to_ascii_uppercase()
                    .to_string();
                emit_text_at(
                    &label,
                    if vertical { base.x + button_size * 0.5 - 3.0 } else { main + button_size * 0.5 - 3.0 },
                    if vertical { main + (button_size - style.font_size) * 0.5 } else { base.y + (base.height - style.font_size) * 0.5 },
                    font_key,
                    font,
                    style,
                    cmds,
                );
                main += button_size + 4.0;
                }
                }
            }
        }
        WidgetKind::MenuBar(_) => {
            cmds.push(RenderCommand::SetColor(0.24, 0.26, 0.32, 1.0));
            cmds.push(RenderCommand::Rectangle {
                mode: DrawMode::Fill,
                x: base.x,
                y: base.y + base.height - 2.0,
                w: base.width,
                h: 2.0,
            });
        }
        WidgetKind::MenuItem(w) => {
            if w.checked {
                emit_text_at(
                    "v",
                    base.x + 4.0,
                    base.y + (base.height - style.font_size) * 0.5,
                    font_key,
                    font,
                    style,
                    cmds,
                );
            }
            emit_text_at(
                &w.text,
                base.x + if w.checked { 18.0 } else { 6.0 },
                base.y + (base.height - style.font_size) * 0.5,
                font_key,
                font,
                style,
                cmds,
            );
            if !w.shortcut.is_empty() {
                let shortcut_w = measure_text(&w.shortcut, style, font);
                emit_text_at(
                    &w.shortcut,
                    base.x + (base.width - shortcut_w - 6.0).max(0.0),
                    base.y + (base.height - style.font_size) * 0.5,
                    font_key,
                    font,
                    style,
                    cmds,
                );
            }
        }
        WidgetKind::Dialog(w) => {
            cmds.push(RenderCommand::SetColor(0.10, 0.12, 0.17, 0.98));
            cmds.push(RenderCommand::RoundedRectangle {
                mode: DrawMode::Fill,
                x: base.x,
                y: base.y,
                w: base.width,
                h: base.height,
                rx: style.corner_radius + 3.0,
                ry: style.corner_radius + 3.0,
            });
            cmds.push(RenderCommand::SetColor(0.18, 0.22, 0.32, 1.0));
            cmds.push(RenderCommand::RoundedRectangle {
                mode: DrawMode::Fill,
                x: base.x,
                y: base.y,
                w: base.width,
                h: 28.0,
                rx: style.corner_radius,
                ry: style.corner_radius,
            });
            emit_text_at(
                &w.title,
                base.x + 10.0,
                base.y + 6.0,
                font_key,
                font,
                style,
                cmds,
            );
            if w.closeable {
                cmds.push(RenderCommand::SetColor(0.78, 0.26, 0.26, 1.0));
                let close_x = base.x + base.width - 18.0;
                let close_y = base.y + 10.0;
                cmds.push(RenderCommand::Line {
                    x1: close_x,
                    y1: close_y,
                    x2: close_x + 8.0,
                    y2: close_y + 8.0,
                });
                cmds.push(RenderCommand::Line {
                    x1: close_x + 8.0,
                    y1: close_y,
                    x2: close_x,
                    y2: close_y + 8.0,
                });
            }
            let has_footer = w.footer_idx.is_some() || !w.actions.is_empty();
            if has_footer {
                let footer_y = base.y + base.height - 34.0;
                cmds.push(RenderCommand::SetColor(0.25, 0.28, 0.36, 1.0));
                cmds.push(RenderCommand::Line {
                    x1: base.x,
                    y1: footer_y,
                    x2: base.x + base.width,
                    y2: footer_y,
                });
            }
            if !w.actions.is_empty() {
                let footer_y = base.y + base.height - 30.0;
                let button_w = 70.0;
                let total_w = w.actions.len() as f32 * (button_w + 6.0) - 6.0;
                let mut button_x = base.x + base.width - total_w - 8.0;
                for action in &w.actions {
                    let is_primary = action.role.as_str() == "default";
                    if is_primary {
                        cmds.push(RenderCommand::SetColor(0.28, 0.46, 0.76, 1.0));
                    } else {
                        cmds.push(RenderCommand::SetColor(0.18, 0.22, 0.32, 1.0));
                    }
                    cmds.push(RenderCommand::RoundedRectangle {
                        mode: DrawMode::Fill,
                        x: button_x,
                        y: footer_y,
                        w: button_w,
                        h: 24.0,
                        rx: 4.0,
                        ry: 4.0,
                    });
                    emit_text_at(
                        &action.label,
                        button_x + 14.0,
                        footer_y + 4.0,
                        font_key,
                        font,
                        style,
                        cmds,
                    );
                    button_x += button_w + 6.0;
                }
            }
            if w.resizable {
                cmds.push(RenderCommand::SetColor(0.72, 0.76, 0.84, 0.9));
                cmds.push(RenderCommand::Line {
                    x1: base.x + base.width - 14.0,
                    y1: base.y + base.height - 6.0,
                    x2: base.x + base.width - 6.0,
                    y2: base.y + base.height - 14.0,
                });
                cmds.push(RenderCommand::Line {
                    x1: base.x + base.width - 10.0,
                    y1: base.y + base.height - 6.0,
                    x2: base.x + base.width - 6.0,
                    y2: base.y + base.height - 10.0,
                });
            }
        }
        WidgetKind::StatusBar(w) => {
            let mut section_x = base.x;
            for (text, width) in &w.sections {
                emit_text_at(
                    text,
                    section_x + 6.0,
                    base.y + (base.height - style.font_size) * 0.5,
                    font_key,
                    font,
                    style,
                    cmds,
                );
                section_x += *width;
                cmds.push(RenderCommand::SetColor(0.24, 0.26, 0.32, 1.0));
                cmds.push(RenderCommand::Rectangle {
                    mode: DrawMode::Fill,
                    x: section_x,
                    y: base.y,
                    w: 1.0,
                    h: base.height,
                });
            }
        }
        WidgetKind::Accordion(w) => {
            let mut section_y = base.y;
            for section in &w.sections {
                cmds.push(RenderCommand::SetColor(0.18, 0.20, 0.28, 1.0));
                cmds.push(RenderCommand::RoundedRectangle {
                    mode: DrawMode::Fill,
                    x: base.x,
                    y: section_y,
                    w: base.width,
                    h: 24.0,
                    rx: 4.0,
                    ry: 4.0,
                });
                emit_text_at(
                    &section.title,
                    base.x + 18.0,
                    section_y + 5.0,
                    font_key,
                    font,
                    style,
                    cmds,
                );
                cmds.push(RenderCommand::SetColor(
                    style.fg_color[0],
                    style.fg_color[1],
                    style.fg_color[2],
                    0.9,
                ));
                if section.expanded {
                    cmds.push(RenderCommand::Triangle {
                        mode: DrawMode::Fill,
                        x1: base.x + 8.0,
                        y1: section_y + 8.0,
                        x2: base.x + 14.0,
                        y2: section_y + 8.0,
                        x3: base.x + 11.0,
                        y3: section_y + 14.0,
                    });
                    section_y += 60.0;
                } else {
                    cmds.push(RenderCommand::Triangle {
                        mode: DrawMode::Fill,
                        x1: base.x + 9.0,
                        y1: section_y + 6.0,
                        x2: base.x + 9.0,
                        y2: section_y + 16.0,
                        x3: base.x + 15.0,
                        y3: section_y + 11.0,
                    });
                    section_y += 26.0;
                }
            }
        }
        WidgetKind::TooltipPanel(w) => {
            cmds.push(RenderCommand::SetColor(0.78, 0.68, 0.26, 1.0));
            cmds.push(RenderCommand::Rectangle {
                mode: DrawMode::Fill,
                x: base.x,
                y: base.y,
                w: base.width,
                h: 2.0,
            });
            emit_text_at(
                &w.text,
                base.x + 6.0,
                base.y + (base.height - style.font_size) * 0.5,
                font_key,
                font,
                style,
                cmds,
            );
        }
        WidgetKind::ColorPicker(w) => {
            let swatch_size = (base.height.min(base.width) - 26.0).max(12.0);
            cmds.push(RenderCommand::SetColor(w.r, w.g, w.b, w.a));
            cmds.push(RenderCommand::Rectangle {
                mode: DrawMode::Fill,
                x: base.x + 6.0,
                y: base.y + 6.0,
                w: swatch_size,
                h: swatch_size,
            });
            let hue_y = base.y + base.height - 18.0;
            cmds.push(RenderCommand::DrawGradientRect {
                x: base.x + 6.0,
                y: hue_y,
                w: (base.width - 12.0).max(0.0),
                h: 12.0,
                color1: [1.0, 0.0, 0.0, 1.0],
                color2: [1.0, 0.0, 1.0, 1.0],
                direction: GradientDirection::Horizontal,
            });
            emit_text_at(
                &format!(
                    "#{:02X}{:02X}{:02X}",
                    (w.r * 255.0) as u8,
                    (w.g * 255.0) as u8,
                    (w.b * 255.0) as u8
                ),
                base.x + 6.0,
                base.y + swatch_size + 10.0,
                font_key,
                font,
                style,
                cmds,
            );
        }
        WidgetKind::GUITable(w) => {
            let header_h = 22.0;
            cmds.push(RenderCommand::SetColor(0.18, 0.22, 0.32, 1.0));
            cmds.push(RenderCommand::Rectangle {
                mode: DrawMode::Fill,
                x: base.x,
                y: base.y,
                w: base.width,
                h: header_h,
            });
            let mut col_x = base.x;
            for col in &w.columns {
                emit_text_at(
                    &col.header,
                    col_x + 4.0,
                    base.y + 4.0,
                    font_key,
                    font,
                    style,
                    cmds,
                );
                col_x += col.width;
                cmds.push(RenderCommand::SetColor(0.22, 0.24, 0.30, 0.8));
                cmds.push(RenderCommand::Rectangle {
                    mode: DrawMode::Fill,
                    x: col_x,
                    y: base.y,
                    w: 1.0,
                    h: base.height,
                });
            }
            let row_h = 20.0;
            let first_row = (w.scroll_y / row_h).floor().max(0.0) as usize;
            let scroll_offset = w.scroll_y - first_row as f32 * row_h;
            for (row_idx, row) in w.rows.iter().enumerate().skip(first_row) {
                let row_y =
                    base.y + header_h + (row_idx - first_row) as f32 * row_h - scroll_offset;
                if row_y + row_h > base.y + base.height {
                    break;
                }
                if w.selected_row == Some(row_idx) {
                    cmds.push(RenderCommand::SetColor(0.22, 0.36, 0.60, 0.80));
                    cmds.push(RenderCommand::Rectangle {
                        mode: DrawMode::Fill,
                        x: base.x,
                        y: row_y,
                        w: base.width,
                        h: row_h,
                    });
                }
                let mut cell_x = base.x;
                for (cell_idx, cell) in row.iter().enumerate() {
                    emit_text_at(cell, cell_x + 4.0, row_y + 4.0, font_key, font, style, cmds);
                    cell_x += w.columns.get(cell_idx).map(|c| c.width).unwrap_or(80.0);
                }
            }
        }
        WidgetKind::PropertyWidget(w) => {
            let header_h = w.group_header_height.max(18.0);
            let row_h = w.row_height.max(18.0);
            let label_w = w.label_width.clamp(48.0, base.width.max(48.0));
            let mut y = base.y;
            for group in &w.groups {
                if y + header_h > base.y + base.height {
                    break;
                }
                cmds.push(RenderCommand::SetColor(0.18, 0.20, 0.25, 1.0));
                cmds.push(RenderCommand::Rectangle {
                    mode: DrawMode::Fill,
                    x: base.x,
                    y,
                    w: base.width,
                    h: header_h,
                });
                let arrow = if group.collapsed { ">" } else { "v" };
                emit_text_centered_vertically(
                    arrow,
                    TextVerticalBox::new(base.x + 8.0, y, header_h),
                    font_key,
                    font,
                    style,
                    cmds,
                );
                emit_text_centered_vertically(
                    &group.title,
                    TextVerticalBox::new(base.x + 22.0, y, header_h),
                    font_key,
                    font,
                    style,
                    cmds,
                );
                y += header_h;
                if group.collapsed {
                    continue;
                }
                for row in &group.rows {
                    if y + row_h > base.y + base.height {
                        break;
                    }
                    cmds.push(RenderCommand::SetColor(0.13, 0.14, 0.18, 0.95));
                    cmds.push(RenderCommand::Rectangle {
                        mode: DrawMode::Fill,
                        x: base.x,
                        y,
                        w: base.width,
                        h: row_h,
                    });
                    cmds.push(RenderCommand::SetColor(0.25, 0.27, 0.33, 1.0));
                    cmds.push(RenderCommand::Rectangle {
                        mode: DrawMode::Fill,
                        x: base.x + label_w,
                        y,
                        w: 1.0,
                        h: row_h,
                    });
                    emit_text_centered_vertically(
                        &row.name,
                        TextVerticalBox::new(base.x + 8.0, y, row_h),
                        font_key,
                        font,
                        style,
                        cmds,
                    );
                    let value_x = base.x + label_w + 8.0;
                    match row.value_kind {
                        crate::ui::PropertyValueKind::Bool => {
                            cmds.push(RenderCommand::SetColor(0.08, 0.09, 0.11, 1.0));
                            cmds.push(RenderCommand::Rectangle {
                                mode: DrawMode::Fill,
                                x: value_x,
                                y: y + (row_h - 12.0) * 0.5,
                                w: 12.0,
                                h: 12.0,
                            });
                            if property_value_checked(&row.value) {
                                emit_text_centered_vertically(
                                    "x",
                                    TextVerticalBox::new(value_x + 2.0, y, row_h),
                                    font_key,
                                    font,
                                    style,
                                    cmds,
                                );
                            }
                        }
                        crate::ui::PropertyValueKind::Color => {
                            if let Some((r, g, b)) = parse_property_hex_color(&row.value) {
                                cmds.push(RenderCommand::SetColor(
                                    r as f32 / 255.0,
                                    g as f32 / 255.0,
                                    b as f32 / 255.0,
                                    1.0,
                                ));
                                cmds.push(RenderCommand::Rectangle {
                                    mode: DrawMode::Fill,
                                    x: value_x,
                                    y: y + (row_h - 12.0) * 0.5,
                                    w: 14.0,
                                    h: 12.0,
                                });
                            }
                            emit_text_centered_vertically(
                                &row.value,
                                TextVerticalBox::new(value_x + 20.0, y, row_h),
                                font_key,
                                font,
                                style,
                                cmds,
                            );
                        }
                        crate::ui::PropertyValueKind::Select => {
                            emit_text_centered_vertically(
                                &row.value,
                                TextVerticalBox::new(value_x, y, row_h),
                                font_key,
                                font,
                                style,
                                cmds,
                            );
                            emit_text_centered_vertically(
                                "v",
                                TextVerticalBox::new(base.x + base.width - 16.0, y, row_h),
                                font_key,
                                font,
                                style,
                                cmds,
                            );
                        }
                        _ => {
                            emit_text_centered_vertically(
                                &row.value,
                                TextVerticalBox::new(value_x, y, row_h),
                                font_key,
                                font,
                                style,
                                cmds,
                            );
                        }
                    }
                    y += row_h;
                }
            }
        }
        WidgetKind::ImageWidget(_) => {
            cmds.push(RenderCommand::SetColor(0.30, 0.32, 0.38, 1.0));
            cmds.push(RenderCommand::Line {
                x1: base.x,
                y1: base.y,
                x2: base.x + base.width,
                y2: base.y + base.height,
            });
            cmds.push(RenderCommand::Line {
                x1: base.x + base.width,
                y1: base.y,
                x2: base.x,
                y2: base.y + base.height,
            });
            emit_text_at(
                "[image]",
                base.x + (base.width - measure_text("[image]", style, font)) * 0.5,
                base.y + (base.height - style.font_size) * 0.5,
                font_key,
                font,
                style,
                cmds,
            );
        }
        _ => {}
    }
    emit_focus_ring(ctx, base, cmds);
    let skip_text = matches!(
        widget,
        WidgetKind::Badge(_)
            | WidgetKind::Switch(_)
            | WidgetKind::CheckBox(_)
            | WidgetKind::RadioButton(_)
            | WidgetKind::TextInput(_)
            | WidgetKind::TextArea(_)
            | WidgetKind::RichLabel(_)
            | WidgetKind::ComboBox(_)
            | WidgetKind::MenuItem(_)
    );
    if !skip_text {
        emit_icon_and_text(base, display_text(widget), font_key, font, style, cmds);
    }
    let mut render_children = widget_render_children(widget);
    render_children.sort_by_key(|&i| ctx.widgets.get(i).map(|w| w.base().z_order).unwrap_or(0));

    // Feature 5: Scissor clipping for ScrollPanel children.
    let needs_scissor = matches!(widget, WidgetKind::ScrollPanel(_));
    if needs_scissor {
        let clip = (base.x, base.y, base.width, base.height);
        cmds.push(RenderCommand::SetScissor(Some(clip)));
    }

    for child_idx in render_children {
        if child_idx < ctx.widgets.len() {
            render_widget_inner(
                ctx,
                child_idx,
                font_key,
                fonts,
                default_style,
                effective_shader,
                cmds,
                depth.saturating_add(1),
            );
        }
    }

    if needs_scissor {
        cmds.push(RenderCommand::SetScissor(None));
    }
    if local_shader.is_some() {
        cmds.push(RenderCommand::SetShader(inherited_shader));
    }
}
impl GuiContext {
    /// Run a layout pass then emit render commands using `font_key` and explicit font storage.
    pub fn build_render_commands_with_fonts(
        &mut self,
        font_key: FontKey,
        fonts: &SlotMap<FontKey, Font>,
    ) -> Vec<RenderCommand> {
        if !self.dirty && !self.layout_dirty && !self.style_dirty && !self.text_dirty && !self.render_dirty {
            if let Some((cached_font, generation, signature, cached)) = &self.command_cache {
                if *cached_font == font_key && *generation == self.render_generation && *signature == self.compute_render_signature() {
                    self.runtime_stats.last_frame_commands = cached.len();
                    self.runtime_stats.command_cache_hits = self.runtime_stats.command_cache_hits.saturating_add(1);
                    return cached.clone();
                }
            }
        }
        // Lowering a clean retained tree must not redo geometry work. Mutators
        // and viewport updates invalidate `layout_dirty`; the first lowering
        // after such a change performs the required layout pass.
        if self.layout_dirty {
            self.run_layout_pass();
        }
        let default_style = WidgetStyle::default();
        self.runtime_stats.command_cache_misses = self.runtime_stats.command_cache_misses.saturating_add(1);
        let mut cmds = Vec::new();
        WidgetRenderer::new(self, font_key, fonts, &default_style, &mut cmds)
            .render_root_children();
        self.runtime_stats.last_frame_commands = cmds.len();
        if cmds.len() > self.limits().max_render_commands {
            cmds.truncate(self.limits().max_render_commands);
            self.runtime_stats.command_limit_rejections = self.runtime_stats.command_limit_rejections.saturating_add(1);
        }
        self.command_cache = Some((font_key, self.render_generation, self.compute_render_signature(), cmds.clone()));
        cmds
    }

    /// Run a layout pass then emit all render commands using `font_key`; return the command list.
    pub fn build_render_commands(&mut self, font_key: FontKey) -> Vec<RenderCommand> {
        let fonts = SlotMap::with_key();
        self.build_render_commands_with_fonts(font_key, &fonts)
    }

    /// Run a layout pass and emit render commands using the default font key.
    pub fn generate_render_commands(&mut self) -> Vec<RenderCommand> {
        self.build_render_commands(FontKey::default())
    }

    /// Replay this UI's single render-command stream through the render-owned software capture path.
    pub fn draw_to_image(&self, width: u32, height: u32) -> crate::image::ImageData {
        let mut layout_ctx = self.clone();
        layout_ctx.set_viewport(width as f32, height as f32);
        let ui_commands = layout_ctx.generate_render_commands();
        // Seed the replay canvas before UI commands, both fixing its requested
        // extent and avoiding a trailing transparent command that would erase
        // rendered pixels in the software compositor.
        let mut commands = vec![
            RenderCommand::SetColor(0.094, 0.102, 0.133, 1.0),
            RenderCommand::Rectangle { mode: DrawMode::Fill, x: 0.0, y: 0.0, w: width as f32, h: height as f32 },
        ];
        commands.extend(ui_commands);
        crate::render::software_capture::capture_commands_to_image_sized(
            &commands,
            [0.094, 0.102, 0.133, 1.0],
            width,
            height,
        )
    }
}
