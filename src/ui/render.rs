//! Render command generation for the GUI widget tree.
//!
//! Converts a [`GuiContext`] widget tree into a flat list of
//! [`RenderCommand`]s that the GPU renderer can execute.  Walks the tree
//! depth-first from the root panel, emitting background rectangles, borders,
//! and text labels for each visible widget according to the active
//! [`Theme`](super::Theme).

use crate::render::renderer::{DrawMode, RenderCommand};
use crate::runtime::resource_keys::FontKey;
use crate::ui::context::{GuiContext, WidgetKind};
use crate::ui::theme::WidgetStyle;
use crate::ui::widget::WidgetBase;

/// Return the display text for widgets that have a text field.
///
/// # Parameters
/// - `widget` — `&WidgetKind`.
///
/// # Returns
/// `Option<&str>`.
fn display_text(widget: &WidgetKind) -> Option<&str> {
    let text = match widget {
        WidgetKind::Button(w) => &w.text,
        WidgetKind::Label(w) => &w.text,
        WidgetKind::TextInput(w) => &w.text,
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

/// Emit render commands for a single widget's background and border.
///
/// Uses rounded rectangles when `corner_radius > 0`, plain rectangles
/// otherwise.
///
/// # Parameters
/// - `base` — `&WidgetBase`.
/// - `style` — `&WidgetStyle`.
/// - `cmds` — `&mut Vec<RenderCommand>`.
fn emit_box(base: &WidgetBase, style: &WidgetStyle, cmds: &mut Vec<RenderCommand>) {
    let [br, bg, bb, ba] = style.bg_color;
    cmds.push(RenderCommand::SetColor(br, bg, bb, ba));

    if style.corner_radius > 0.0 {
        cmds.push(RenderCommand::RoundedRectangle {
            mode: DrawMode::Fill,
            x: base.x,
            y: base.y,
            w: base.width,
            h: base.height,
            rx: style.corner_radius,
            ry: style.corner_radius,
        });
    } else {
        cmds.push(RenderCommand::Rectangle {
            mode: DrawMode::Fill,
            x: base.x,
            y: base.y,
            w: base.width,
            h: base.height,
        });
    }

    if style.border_width > 0.0 {
        let [cr, cg, cb, ca] = style.border_color;
        cmds.push(RenderCommand::SetColor(cr, cg, cb, ca));
        cmds.push(RenderCommand::SetLineWidth(style.border_width));

        if style.corner_radius > 0.0 {
            cmds.push(RenderCommand::RoundedRectangle {
                mode: DrawMode::Line,
                x: base.x,
                y: base.y,
                w: base.width,
                h: base.height,
                rx: style.corner_radius,
                ry: style.corner_radius,
            });
        } else {
            cmds.push(RenderCommand::Rectangle {
                mode: DrawMode::Line,
                x: base.x,
                y: base.y,
                w: base.width,
                h: base.height,
            });
        }
    }
}

/// Emit a `Print` command for the widget's text, centred inside padding.
///
/// # Parameters
/// - `base` — `&WidgetBase`.
/// - `text` — `&str`.
/// - `style` — `&WidgetStyle`.
/// - `font_key` — `FontKey`.
/// - `cmds` — `&mut Vec<RenderCommand>`.
fn emit_text(
    base: &WidgetBase,
    text: &str,
    style: &WidgetStyle,
    font_key: FontKey,
    cmds: &mut Vec<RenderCommand>,
) {
    let [fr, fg, fb, fa] = style.fg_color;
    cmds.push(RenderCommand::SetColor(fr, fg, fb, fa));

    let tx = base.x + base.padding[3]; // left padding
    let ty = base.y + base.padding[0]; // top padding
    let scale = style.font_size / 14.0; // normalise against 14 px baseline

    cmds.push(RenderCommand::Print {
        font_key,
        text: text.to_string(),
        x: tx,
        y: ty,
        scale,
    });
}

/// Emit a drop-shadow rectangle offset from the widget bounds.
///
/// # Parameters
/// - `base` — `&WidgetBase`.
/// - `style` — `&WidgetStyle`.
/// - `cmds` — `&mut Vec<RenderCommand>`.
fn emit_shadow(base: &WidgetBase, style: &WidgetStyle, cmds: &mut Vec<RenderCommand>) {
    let [sr, sg, sb, sa] = style.shadow_color;
    if sa <= 0.0 {
        return;
    }
    let [ox, oy] = style.shadow_offset;
    cmds.push(RenderCommand::SetColor(sr, sg, sb, sa));
    if style.corner_radius > 0.0 {
        cmds.push(RenderCommand::RoundedRectangle {
            mode: DrawMode::Fill,
            x: base.x + ox,
            y: base.y + oy,
            w: base.width,
            h: base.height,
            rx: style.corner_radius,
            ry: style.corner_radius,
        });
    } else {
        cmds.push(RenderCommand::Rectangle {
            mode: DrawMode::Fill,
            x: base.x + ox,
            y: base.y + oy,
            w: base.width,
            h: base.height,
        });
    }
}

/// Emit a thin translucent highlight strip along the top edge of a widget.
///
/// The strip height is `shadow_offset[1].max(2.0)` pixels.
///
/// # Parameters
/// - `base` — `&WidgetBase`.
/// - `style` — `&WidgetStyle`.
/// - `cmds` — `&mut Vec<RenderCommand>`.
fn emit_highlight(base: &WidgetBase, style: &WidgetStyle, cmds: &mut Vec<RenderCommand>) {
    if style.highlight_alpha <= 0.0 {
        return;
    }
    let a = style.highlight_alpha.clamp(0.0, 1.0);
    cmds.push(RenderCommand::SetColor(1.0, 1.0, 1.0, a));
    let strip_h = 2.0_f32.max(style.border_width);
    cmds.push(RenderCommand::Rectangle {
        mode: DrawMode::Fill,
        x: base.x + style.border_width,
        y: base.y + style.border_width,
        w: (base.width - style.border_width * 2.0).max(0.0),
        h: strip_h,
    });
}

/// Emit the filled fill-portion of a range widget (slider track fill).
///
/// The fill uses `style.gradient_end` colour if set, otherwise `style.fg_color`.
///
/// # Parameters
/// - `base` — `&WidgetBase`.
/// - `value` — `f64`. Current value.
/// - `min` — `f64`. Range minimum.
/// - `max` — `f64`. Range maximum.
/// - `style` — `&WidgetStyle`.
/// - `cmds` — `&mut Vec<RenderCommand>`.
fn emit_slider(
    base: &WidgetBase,
    value: f64,
    min: f64,
    max: f64,
    style: &WidgetStyle,
    cmds: &mut Vec<RenderCommand>,
) {
    let range = (max - min).max(1e-6);
    let t = ((value - min) / range).clamp(0.0, 1.0) as f32;
    let fill_w = (base.width * t).max(0.0);
    let fill_color = style.gradient_end.unwrap_or(style.fg_color);
    let [fr, fg, fb, fa] = fill_color;
    cmds.push(RenderCommand::SetColor(fr, fg, fb, fa));
    if fill_w > 0.0 {
        cmds.push(RenderCommand::Rectangle {
            mode: DrawMode::Fill,
            x: base.x,
            y: base.y,
            w: fill_w,
            h: base.height,
        });
    }
    // Thumb circle at fill end-point.
    let thumb_cx = base.x + fill_w;
    let thumb_cy = base.y + base.height * 0.5;
    let thumb_r = (base.height * 0.5 - 1.0).max(2.0);
    cmds.push(RenderCommand::SetColor(1.0, 1.0, 1.0, 1.0));
    cmds.push(RenderCommand::Circle {
        mode: DrawMode::Fill,
        x: thumb_cx,
        y: thumb_cy,
        r: thumb_r,
    });
}

/// Emit the fill portion of a progress bar.
///
/// # Parameters
/// - `base` — `&WidgetBase`.
/// - `value` — `f64`. Current value.
/// - `min` — `f64`. Range minimum.
/// - `max` — `f64`. Range maximum.
/// - `style` — `&WidgetStyle`.
/// - `cmds` — `&mut Vec<RenderCommand>`.
fn emit_progress_bar(
    base: &WidgetBase,
    value: f64,
    min: f64,
    max: f64,
    style: &WidgetStyle,
    cmds: &mut Vec<RenderCommand>,
) {
    let range = (max - min).max(1e-6);
    let t = ((value - min) / range).clamp(0.0, 1.0) as f32;
    let fill_w = (base.width * t).max(0.0);
    if fill_w <= 0.0 {
        return;
    }
    let fill_color = style.gradient_end.unwrap_or(style.fg_color);
    let [fr, fg, fb, fa] = fill_color;
    cmds.push(RenderCommand::SetColor(fr, fg, fb, fa));
    cmds.push(RenderCommand::Rectangle {
        mode: DrawMode::Fill,
        x: base.x,
        y: base.y,
        w: fill_w,
        h: base.height,
    });
}

/// Emit a check-mark glyph inside the checkbox bounds.
///
/// Draws two `Line` segments forming a ✓ shape.
///
/// # Parameters
/// - `base` — `&WidgetBase`.
/// - `style` — `&WidgetStyle`.
/// - `cmds` — `&mut Vec<RenderCommand>`.
fn emit_checkbox(base: &WidgetBase, style: &WidgetStyle, cmds: &mut Vec<RenderCommand>) {
    let box_size = base.height.min(base.height);
    let cx = base.x + box_size * 0.5;
    let cy = base.y + box_size * 0.5;
    let s = box_size * 0.25;
    let [fr, fg, fb, fa] = style.fg_color;
    cmds.push(RenderCommand::SetColor(fr, fg, fb, fa));
    cmds.push(RenderCommand::SetLineWidth(2.0));
    // Down-right leg of check
    cmds.push(RenderCommand::Line {
        x1: cx - s,
        y1: cy,
        x2: cx - s * 0.2,
        y2: cy + s,
    });
    // Up-right leg of check
    cmds.push(RenderCommand::Line {
        x1: cx - s * 0.2,
        y1: cy + s,
        x2: cx + s,
        y2: cy - s,
    });
}

/// Emit a filled dot inside the radio-button circle.
///
/// # Parameters
/// - `base` — `&WidgetBase`.
/// - `style` — `&WidgetStyle`.
/// - `cmds` — `&mut Vec<RenderCommand>`.
fn emit_radio_button(base: &WidgetBase, style: &WidgetStyle, cmds: &mut Vec<RenderCommand>) {
    let r = (base.height * 0.5 - 3.0).max(2.0);
    let cx = base.x + base.height * 0.5;
    let cy = base.y + base.height * 0.5;
    let [fr, fg, fb, fa] = style.fg_color;
    cmds.push(RenderCommand::SetColor(fr, fg, fb, fa));
    cmds.push(RenderCommand::Circle {
        mode: DrawMode::Fill,
        x: cx,
        y: cy,
        r,
    });
}

/// Emit a down-arrow indicator on the right side of a ComboBox.
///
/// # Parameters
/// - `base` — `&WidgetBase`.
/// - `style` — `&WidgetStyle`.
/// - `cmds` — `&mut Vec<RenderCommand>`.
fn emit_combo_box_arrow(base: &WidgetBase, style: &WidgetStyle, cmds: &mut Vec<RenderCommand>) {
    let btn_w = base.height;
    let ax = base.x + base.width - btn_w * 0.5;
    let ay = base.y + base.height * 0.5;
    let s = 5.0_f32;
    let [fr, fg, fb, fa] = style.fg_color;
    cmds.push(RenderCommand::SetColor(fr, fg, fb, fa));
    cmds.push(RenderCommand::Triangle {
        mode: DrawMode::Fill,
        x1: ax - s,
        y1: ay - s * 0.5,
        x2: ax + s,
        y2: ay - s * 0.5,
        x3: ax,
        y3: ay + s * 0.5,
    });
}

/// Emit a scroll-bar thumb rectangle.
///
/// # Parameters
/// - `base` — `&WidgetBase`.
/// - `position` — `f32`. Scroll position.
/// - `content_size` — `f32`. Total scrollable content size.
/// - `view_size` — `f32`. Visible viewport size.
/// - `vertical` — `bool`. Axis.
/// - `style` — `&WidgetStyle`.
/// - `cmds` — `&mut Vec<RenderCommand>`.
fn emit_scroll_bar(
    base: &WidgetBase,
    position: f32,
    content_size: f32,
    view_size: f32,
    vertical: bool,
    style: &WidgetStyle,
    cmds: &mut Vec<RenderCommand>,
) {
    let safe_content = content_size.max(1.0);
    let thumb_ratio = (view_size / safe_content).clamp(0.1, 1.0);
    let scroll_ratio = (position / (safe_content - view_size).max(1.0)).clamp(0.0, 1.0);
    let [fr, fg, fb, fa] = style.fg_color;
    cmds.push(RenderCommand::SetColor(fr, fg, fb, fa));
    if vertical {
        let track_h = base.height;
        let thumb_h = track_h * thumb_ratio;
        let thumb_y = base.y + (track_h - thumb_h) * scroll_ratio;
        cmds.push(RenderCommand::RoundedRectangle {
            mode: DrawMode::Fill,
            x: base.x + 2.0,
            y: thumb_y,
            w: base.width - 4.0,
            h: thumb_h,
            rx: (base.width - 4.0) * 0.5,
            ry: (base.width - 4.0) * 0.5,
        });
    } else {
        let track_w = base.width;
        let thumb_w = track_w * thumb_ratio;
        let thumb_x = base.x + (track_w - thumb_w) * scroll_ratio;
        cmds.push(RenderCommand::RoundedRectangle {
            mode: DrawMode::Fill,
            x: thumb_x,
            y: base.y + 2.0,
            w: thumb_w,
            h: base.height - 4.0,
            rx: (base.height - 4.0) * 0.5,
            ry: (base.height - 4.0) * 0.5,
        });
    }
}

/// Emit the increment/decrement arrow buttons on a SpinBox.
///
/// # Parameters
/// - `base` — `&WidgetBase`.
/// - `style` — `&WidgetStyle`.
/// - `cmds` — `&mut Vec<RenderCommand>`.
fn emit_spin_box(base: &WidgetBase, style: &WidgetStyle, cmds: &mut Vec<RenderCommand>) {
    let btn_w = base.height;
    let mid_y = base.y + base.height * 0.5;
    let s = 4.0_f32;
    let [fr, fg, fb, fa] = style.fg_color;
    cmds.push(RenderCommand::SetColor(fr, fg, fb, fa));
    // Decrement arrow (left button)
    cmds.push(RenderCommand::Triangle {
        mode: DrawMode::Fill,
        x1: base.x + btn_w * 0.5 - s,
        y1: mid_y - s * 0.5,
        x2: base.x + btn_w * 0.5 + s,
        y2: mid_y - s * 0.5,
        x3: base.x + btn_w * 0.5,
        y3: mid_y + s * 0.5,
    });
    // Increment arrow (right button)
    let rx = base.x + base.width - btn_w * 0.5;
    cmds.push(RenderCommand::Triangle {
        mode: DrawMode::Fill,
        x1: rx - s,
        y1: mid_y + s * 0.5,
        x2: rx + s,
        y2: mid_y + s * 0.5,
        x3: rx,
        y3: mid_y - s * 0.5,
    });
}

/// Emit the sliding thumb pill of a Switch widget.
///
/// When `on` is true the thumb slides to the right side.
/// `thumb_t` in `[0.0, 1.0]` drives the animated position.
///
/// # Parameters
/// - `base` — `&WidgetBase`.
/// - `on` — `bool`. Logical state.
/// - `thumb_t` — `f32`. Animation progress.
/// - `style` — `&WidgetStyle`.
/// - `cmds` — `&mut Vec<RenderCommand>`.
fn emit_switch(
    base: &WidgetBase,
    on: bool,
    thumb_t: f32,
    style: &WidgetStyle,
    cmds: &mut Vec<RenderCommand>,
) {
    // Tint the track when on.
    let [tr, tg, tb, ta] = if on {
        style.gradient_end.unwrap_or([0.20, 0.55, 0.30, 1.0])
    } else {
        [0.35, 0.35, 0.42, 1.0]
    };
    cmds.push(RenderCommand::SetColor(tr, tg, tb, ta));
    cmds.push(RenderCommand::RoundedRectangle {
        mode: DrawMode::Fill,
        x: base.x,
        y: base.y,
        w: base.width,
        h: base.height,
        rx: base.height * 0.5,
        ry: base.height * 0.5,
    });

    // Thumb
    let t = thumb_t.clamp(0.0, 1.0);
    let thumb_r = (base.height * 0.5 - 2.0).max(2.0);
    let thumb_cx = base.x + thumb_r + 2.0 + (base.width - (thumb_r + 2.0) * 2.0).max(0.0) * t;
    let thumb_cy = base.y + base.height * 0.5;
    cmds.push(RenderCommand::SetColor(1.0, 1.0, 1.0, 1.0));
    cmds.push(RenderCommand::Circle {
        mode: DrawMode::Fill,
        x: thumb_cx,
        y: thumb_cy,
        r: thumb_r,
    });
}

/// Emit a badge rendered as a rounded pill with count text.
///
/// The background is drawn by `emit_box`; this function only adds the `Print`.
///
/// # Parameters
/// - `base` — `&WidgetBase`.
/// - `text` — `&str`. Display text (from [`Badge::display_text`]).
/// - `font_key` — `FontKey`.
/// - `style` — `&WidgetStyle`.
/// - `cmds` — `&mut Vec<RenderCommand>`.
fn emit_badge(
    base: &WidgetBase,
    text: &str,
    font_key: FontKey,
    style: &WidgetStyle,
    cmds: &mut Vec<RenderCommand>,
) {
    let [fr, fg, fb, fa] = style.fg_color;
    cmds.push(RenderCommand::SetColor(fr, fg, fb, fa));
    let scale = style.font_size / 14.0;
    let tx = base.x + base.width * 0.5;
    let ty = base.y + (base.height - style.font_size) * 0.5;
    cmds.push(RenderCommand::Print {
        font_key,
        text: text.to_string(),
        x: tx,
        y: ty,
        scale,
    });
}

/// Recursively walk a widget and its children, emitting render commands.
///
/// # Parameters
/// - `ctx` — `&GuiContext`.
/// - `idx` — `usize`. Widget index in the pool.
/// - `font_key` — `FontKey`.
/// - `default_style` — `&WidgetStyle`. Fallback when no theme is set.
/// - `cmds` — `&mut Vec<RenderCommand>`.
fn render_widget(
    ctx: &GuiContext,
    idx: usize,
    font_key: FontKey,
    default_style: &WidgetStyle,
    cmds: &mut Vec<RenderCommand>,
) {
    let widget = &ctx.widgets[idx];
    let base = widget.base();

    if !base.visible {
        return;
    }

    let style = ctx
        .theme
        .as_ref()
        .and_then(|t| t.get_style(base.widget_type, base.state))
        .unwrap_or(default_style);

    // Drop shadow (drawn before background)
    emit_shadow(base, style, cmds);

    // Background + border
    emit_box(base, style, cmds);

    // Top-edge highlight strip
    if style.highlight_alpha > 0.0 {
        emit_highlight(base, style, cmds);
    }

    // Per-type specialized rendering
    match widget {
        WidgetKind::Slider(w) => {
            emit_slider(base, w.value, w.min, w.max, style, cmds);
        }
        WidgetKind::SpinBox(w) => {
            emit_progress_bar(base, w.value, w.min, w.max, style, cmds);
            emit_spin_box(base, style, cmds);
        }
        WidgetKind::ProgressBar(w) => {
            emit_progress_bar(base, w.value, w.min, w.max, style, cmds);
        }
        WidgetKind::CheckBox(w) => {
            if w.checked {
                emit_checkbox(base, style, cmds);
            }
        }
        WidgetKind::RadioButton(w) => {
            if w.selected {
                emit_radio_button(base, style, cmds);
            }
        }
        WidgetKind::ComboBox(_) => {
            emit_combo_box_arrow(base, style, cmds);
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
            emit_badge(base, &w.display_text(), font_key, style, cmds);
        }
        _ => {}
    }

    // Text label for widgets that carry text (skip Badge and Switch — already handled)
    let skip_text = matches!(widget, WidgetKind::Badge(_) | WidgetKind::Switch(_));
    if !skip_text {
        if let Some(text) = display_text(widget) {
            emit_text(base, text, style, font_key, cmds);
        }
    }

    // Recurse into children
    if let Some(children) = widget.children() {
        for &child_idx in children {
            if child_idx < ctx.widgets.len() {
                render_widget(ctx, child_idx, font_key, default_style, cmds);
            }
        }
    }
}

impl GuiContext {
    /// Generate a flat list of [`RenderCommand`]s for the entire widget tree.
    ///
    /// Walks the root panel's children depth-first, emitting styled
    /// rectangles and text for every visible widget.
    ///
    /// # Parameters
    /// - `font_key` — `FontKey`. Font used for all widget text.
    ///
    /// # Returns
    /// `Vec<RenderCommand>`.
    pub fn build_render_commands(&mut self, font_key: FontKey) -> Vec<RenderCommand> {
        self.run_layout_pass();
        let default_style = WidgetStyle::default();
        let mut cmds = Vec::new();

        // Root is always index 0 (invisible panel)
        if let Some(children) = self.widgets.first().and_then(|w| w.children()) {
            for &child_idx in children {
                if child_idx < self.widgets.len() {
                    render_widget(self, child_idx, font_key, &default_style, &mut cmds);
                }
            }
        }

        cmds
    }

    /// Generate render commands using the default font key.
    ///
    /// Convenience alias for [`build_render_commands`](Self::build_render_commands)
    /// that passes [`FontKey::default()`], satisfying the standard
    /// `generate_render_commands()` contract used across engine modules.
    ///
    /// # Returns
    /// `Vec<RenderCommand>`.
    pub fn generate_render_commands(&mut self) -> Vec<RenderCommand> {
        self.build_render_commands(FontKey::default())
    }

    /// Render the widget tree to a CPU image for headless layout testing.
    ///
    /// Draws a dark background and fills a coloured rectangle for each
    /// visible widget at its declared bounds. Text content is not rasterised
    /// (no font atlas available CPU-side).
    ///
    /// # Parameters
    /// - `width` — `u32`.
    /// - `height` — `u32`.
    ///
    /// # Returns
    /// `crate::image::ImageData`.
    pub fn draw_to_image(&self, width: u32, height: u32) -> crate::image::ImageData {
        let mut img = crate::image::ImageData::new(width, height);
        img.fill(30, 30, 40, 255);

        let default_style = WidgetStyle::default();
        let Some(children) = self.widgets.first().and_then(|w| w.children()) else {
            return img;
        };

        let mut stack: Vec<usize> = children.to_vec();
        while let Some(idx) = stack.pop() {
            let Some(widget) = self.widgets.get(idx) else {
                continue;
            };
            let base = widget.base();
            if !base.visible {
                continue;
            }
            let style = self
                .theme
                .as_ref()
                .and_then(|t| t.get_style(base.widget_type, base.state))
                .unwrap_or(&default_style);
            let [r, g, b, a] = style.bg_color;
            let alpha = (a * 255.0) as u8;
            img.draw_rect(
                base.x as i32,
                base.y as i32,
                base.width as u32,
                base.height as u32,
                (r * 255.0) as u8,
                (g * 255.0) as u8,
                (b * 255.0) as u8,
                alpha,
            );
            if let Some(ch) = widget.children() {
                stack.extend_from_slice(ch);
            }
        }
        img
    }
}
