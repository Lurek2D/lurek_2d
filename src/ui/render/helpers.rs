//! Owns the UI render helpers implementation for the UI subsystem and keeps related runtime rules local here.
//! Keeps retained widget state, layout helpers, and presentation rules so helpers stay close to invariants this updates.
//! Defines how UI render helpers data is validated, transformed, or stored before neighboring systems consume it.
//! Separates UI render helpers behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where UI code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing UI render helpers defaults, lifecycle handling, validation, or data ownership rules.
//! Keeps failure paths and edge cases near UI render helpers state that explains them instead of spreading rules outward.
//! Preserves deterministic behavior by keeping UI render helpers calculations explicit at their owning subsystem boundary.
//! Provides local adaptation layer that lets callers reuse UI render helpers rules without duplicating engine decisions.
//! Read this file when renderer output depends on shared UI helper math more than widget-specific state.

use super::*;

#[allow(clippy::too_many_arguments)]
/// Rasterizes one tree node subtree into the CPU image preview for headless UI rendering.
pub(super) fn draw_tree_nodes_cpu(
    nodes: &[crate::ui::extras::TreeNode],
    idx: usize,
    img: &mut crate::image::ImageData,
    font: Option<&crate::font::Font>,
    x: i32,
    ry: i32,
    max_y: i32,
    row_h: i32,
    depth: i32,
    selected: Option<usize>,
    fg: [u8; 3],
) -> i32 {
    if ry + row_h > max_y {
        return ry;
    }
    let node = match nodes.get(idx) {
        Some(n) => n,
        None => return ry,
    };
    let indent = x + depth * 14 + 4;
    if selected == Some(idx) {
        img.draw_rect(x, ry, 9999, row_h as u32, 50, 85, 150, 180);
    }
    if !node.children.is_empty() {
        if node.expanded {
            img.draw_line(indent, ry + 4, indent + 6, ry + 4, fg[0], fg[1], fg[2], 200);
            img.draw_line(indent, ry + 4, indent + 3, ry + 8, fg[0], fg[1], fg[2], 200);
            img.draw_line(
                indent + 6,
                ry + 4,
                indent + 3,
                ry + 8,
                fg[0],
                fg[1],
                fg[2],
                200,
            );
        } else {
            img.draw_line(
                indent,
                ry + 3,
                indent,
                ry + row_h - 3,
                fg[0],
                fg[1],
                fg[2],
                200,
            );
            img.draw_line(
                indent,
                ry + 3,
                indent + 6,
                ry + row_h / 2,
                fg[0],
                fg[1],
                fg[2],
                200,
            );
            img.draw_line(
                indent,
                ry + row_h - 3,
                indent + 6,
                ry + row_h / 2,
                fg[0],
                fg[1],
                fg[2],
                200,
            );
        }
    }
    draw_cpu_text(
        img,
        font,
        &node.text,
        indent + 10,
        cpu_text_center_y(font, ry, row_h),
        fg[0],
        fg[1],
        fg[2],
    );
    let mut next_y = ry + row_h;
    if node.expanded {
        let children: Vec<usize> = node.children.clone();
        for child_idx in children {
            next_y = draw_tree_nodes_cpu(
                nodes,
                child_idx,
                img,
                font,
                x,
                next_y,
                max_y,
                row_h,
                depth + 1,
                selected,
                fg,
            );
        }
    }
    next_y
}

/// Parses a six-digit property color string into RGB byte components.
pub(super) fn parse_property_hex_color(value: &str) -> Option<(u8, u8, u8)> {
    let hex = value
        .trim()
        .strip_prefix('#')
        .unwrap_or_else(|| value.trim());
    if hex.len() != 6 {
        return None;
    }
    let r = u8::from_str_radix(&hex[0..2], 16).ok()?;
    let g = u8::from_str_radix(&hex[2..4], 16).ok()?;
    let b = u8::from_str_radix(&hex[4..6], 16).ok()?;
    Some((r, g, b))
}

/// Returns whether a property value string should be treated as a checked boolean.
pub(super) fn property_value_checked(value: &str) -> bool {
    matches!(
        value.trim().to_ascii_lowercase().as_str(),
        "true" | "yes" | "on" | "1" | "checked"
    )
}
/// Emit a filled and optionally bordered background box for `base` using `style`.
pub(super) fn emit_box(base: &WidgetBase, style: &WidgetStyle, cmds: &mut Vec<RenderCommand>) {
    let [br, bg, bb, ba] = style.bg_color;
    if let Some(color2) = style.gradient_end {
        if style.corner_radius <= 0.0 {
            cmds.push(RenderCommand::DrawGradientRect {
                x: base.x,
                y: base.y,
                w: base.width,
                h: base.height,
                color1: [br, bg, bb, ba],
                color2,
                direction: GradientDirection::Vertical,
            });
        } else {
            cmds.push(RenderCommand::SetColor(br, bg, bb, ba));
            cmds.push(RenderCommand::RoundedRectangle {
                mode: DrawMode::Fill,
                x: base.x,
                y: base.y,
                w: base.width,
                h: base.height,
                rx: style.corner_radius,
                ry: style.corner_radius,
            });
        }
    } else if style.corner_radius > 0.0 {
        cmds.push(RenderCommand::SetColor(br, bg, bb, ba));
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
        cmds.push(RenderCommand::SetColor(br, bg, bb, ba));
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
/// Emit a centred or aligned `Print` command for `text` inside `base`, using layout_text for wrap/ellipsis/valign.
pub(super) fn emit_text(
    base: &WidgetBase,
    text: &str,
    style: &WidgetStyle,
    font_key: FontKey,
    font: Option<&Font>,
    cmds: &mut Vec<RenderCommand>,
) {
    let [fr, fg, fb, fa] = style.fg_color;
    cmds.push(RenderCommand::SetColor(fr, fg, fb, fa));
    let scale = text_scale(style, font);
    let rect = Rect::new(base.x, base.y, base.width, base.height);
    let text_align = if base.text_align.is_empty() {
        style.text_align.as_str()
    } else {
        base.text_align.as_str()
    };
    let lines = layout_text(
        text,
        rect,
        style,
        font,
        base.text_wrap,
        base.text_ellipsis,
        base.text_v_align,
        base.padding,
        text_align,
    );
    if lines.is_empty() {
        return;
    }
    let clip = lines[0].clip_rect;
    cmds.push(RenderCommand::SetScissor(Some((
        clip.x,
        clip.y,
        clip.width,
        clip.height,
    ))));
    for line in &lines {
        cmds.push(RenderCommand::Print {
            font_key,
            text: line.text.clone(),
            x: line.x,
            y: line.y,
            scale,
        });
    }
    cmds.push(RenderCommand::SetScissor(None));
}
/// Emit a shadow rectangle behind `base` when `style.shadow_color` alpha is non-zero.
pub(super) fn emit_shadow(base: &WidgetBase, style: &WidgetStyle, cmds: &mut Vec<RenderCommand>) {
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
/// Emit a top-edge highlight strip when `style.highlight_alpha > 0`.
pub(super) fn emit_highlight(
    base: &WidgetBase,
    style: &WidgetStyle,
    cmds: &mut Vec<RenderCommand>,
) {
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
/// Emit a filled progress track and rectangular thumb for a slider widget.
pub(super) fn emit_slider(
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
    let thumb_w = (base.height * 0.35).clamp(4.0, 12.0);
    let thumb_h = (base.height - 2.0).max(6.0);
    let thumb_x =
        (base.x + fill_w - thumb_w * 0.5).clamp(base.x, base.x + (base.width - thumb_w).max(0.0));
    let thumb_y = base.y + (base.height - thumb_h) * 0.5;
    cmds.push(RenderCommand::SetColor(1.0, 1.0, 1.0, 1.0));
    cmds.push(RenderCommand::Rectangle {
        mode: DrawMode::Fill,
        x: thumb_x,
        y: thumb_y,
        w: thumb_w,
        h: thumb_h,
    });
}
/// Emit a filled progress fill rectangle proportional to `value` in `[min, max]`.
pub(super) fn emit_progress_bar(
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
/// Emit a tick/check mark glyph inside the checkbox bounding box.
pub(super) fn emit_checkbox(base: &WidgetBase, style: &WidgetStyle, cmds: &mut Vec<RenderCommand>) {
    let box_size = base.height.min(base.height);
    let cx = base.x + box_size * 0.5;
    let cy = base.y + box_size * 0.5;
    let s = box_size * 0.25;
    let [fr, fg, fb, fa] = style.fg_color;
    cmds.push(RenderCommand::SetColor(fr, fg, fb, fa));
    cmds.push(RenderCommand::SetLineWidth(2.0));
    cmds.push(RenderCommand::Line {
        x1: cx - s,
        y1: cy,
        x2: cx - s * 0.2,
        y2: cy + s,
    });
    cmds.push(RenderCommand::Line {
        x1: cx - s * 0.2,
        y1: cy + s,
        x2: cx + s,
        y2: cy - s,
    });
}
/// Emit a filled square marker indicating a selected radio button.
pub(super) fn emit_radio_button(
    base: &WidgetBase,
    style: &WidgetStyle,
    cmds: &mut Vec<RenderCommand>,
) {
    let side = (base.height - 6.0).clamp(8.0, 14.0);
    let x = base.x + 3.0;
    let y = base.y + (base.height - side) * 0.5;
    let [fr, fg, fb, fa] = style.fg_color;
    cmds.push(RenderCommand::SetColor(fr, fg, fb, fa));
    cmds.push(RenderCommand::Rectangle {
        mode: DrawMode::Fill,
        x,
        y,
        w: side,
        h: side,
    });
}
/// Emit a downward-pointing triangle drop-arrow at the right edge of a combo box.
pub(super) fn emit_combo_box_arrow(
    base: &WidgetBase,
    style: &WidgetStyle,
    cmds: &mut Vec<RenderCommand>,
) {
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
/// Emit a proportional rounded-rect scroll thumb inside the scroll bar track.
pub(super) fn emit_scroll_bar(
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
/// Emit up/down arrow triangles at the left and right edges of a spin box.
pub(super) fn emit_spin_box(base: &WidgetBase, style: &WidgetStyle, cmds: &mut Vec<RenderCommand>) {
    let btn_w = base.height;
    let mid_y = base.y + base.height * 0.5;
    let s = 4.0_f32;
    let [fr, fg, fb, fa] = style.fg_color;
    cmds.push(RenderCommand::SetColor(fr, fg, fb, fa));
    cmds.push(RenderCommand::Triangle {
        mode: DrawMode::Fill,
        x1: base.x + btn_w * 0.5 - s,
        y1: mid_y - s * 0.5,
        x2: base.x + btn_w * 0.5 + s,
        y2: mid_y - s * 0.5,
        x3: base.x + btn_w * 0.5,
        y3: mid_y + s * 0.5,
    });
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
/// Emit a rounded track and interpolated rectangular thumb for a toggle switch; `thumb_t` is the thumb position in `[0.0, 1.0]`.
pub(super) fn emit_switch(
    base: &WidgetBase,
    on: bool,
    thumb_t: f32,
    style: &WidgetStyle,
    cmds: &mut Vec<RenderCommand>,
) {
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
    let t = thumb_t.clamp(0.0, 1.0);
    let thumb_h = (base.height - 4.0).max(6.0);
    let thumb_w = (thumb_h * 0.6).clamp(4.0, 12.0);
    let travel = (base.width - thumb_w - 4.0).max(0.0);
    let thumb_x = base.x + 2.0 + travel * t;
    let thumb_y = base.y + (base.height - thumb_h) * 0.5;
    cmds.push(RenderCommand::SetColor(1.0, 1.0, 1.0, 1.0));
    cmds.push(RenderCommand::Rectangle {
        mode: DrawMode::Fill,
        x: thumb_x,
        y: thumb_y,
        w: thumb_w,
        h: thumb_h,
    });
}
/// Emit the display text of a badge centred inside its bounding box.
pub(super) fn emit_badge(
    base: &WidgetBase,
    text: &str,
    font_key: FontKey,
    font: Option<&Font>,
    style: &WidgetStyle,
    cmds: &mut Vec<RenderCommand>,
) {
    let [fr, fg, fb, fa] = style.fg_color;
    cmds.push(RenderCommand::SetColor(fr, fg, fb, fa));
    let scale = text_scale(style, font);
    let tx = base.x + ((base.width - measure_text(text, style, font)) * 0.5).max(0.0);
    let ty = text_origin_y(text, base.y, base.height, style, font);
    cmds.push(RenderCommand::Print {
        font_key,
        text: text.to_string(),
        x: tx,
        y: ty,
        scale,
    });
}
/// Emit a `Print` command at an explicit `(x, y)` position, bypassing widget padding.
pub(super) fn emit_text_at(
    text: &str,
    x: f32,
    y: f32,
    font_key: FontKey,
    font: Option<&Font>,
    style: &WidgetStyle,
    cmds: &mut Vec<RenderCommand>,
) {
    let [fr, fg, fb, fa] = style.fg_color;
    cmds.push(RenderCommand::SetColor(fr, fg, fb, fa));
    cmds.push(RenderCommand::Print {
        font_key,
        text: text.to_string(),
        x,
        y,
        scale: text_scale(style, font),
    });
}

/// Carries vertical text bounds for helpers that center labels inside arbitrary rectangles.
pub(super) struct TextVerticalBox {
    x: f32,
    y: f32,
    height: f32,
}
impl TextVerticalBox {
    /// Builds a `TextVerticalBox` helper for centered vertical text placement.
    pub(super) fn new(x: f32, y: f32, height: f32) -> Self {
        Self { x, y, height }
    }
}

/// Emits text at the vertically centered baseline inside the supplied text bounds.
pub(super) fn emit_text_centered_vertically(
    text: &str,
    bounds: TextVerticalBox,
    font_key: FontKey,
    font: Option<&Font>,
    style: &WidgetStyle,
    cmds: &mut Vec<RenderCommand>,
) {
    emit_text_at(
        text,
        bounds.x,
        text_origin_y(text, bounds.y, bounds.height, style, font),
        font_key,
        font,
        style,
        cmds,
    );
}

/// Returns the first named shader layer attached to a widget base, if any.
pub(super) fn first_named_shader_layer(base: &WidgetBase) -> Option<ShaderKey> {
    base.shader_layers
        .iter()
        .min_by(|(left, _), (right, _)| left.cmp(right))
        .map(|(_, shader)| *shader)
}

/// Temporary borrowed context passed through recursive `emit_tree_nodes` calls.
pub(super) struct TreeCtx<'a> {
    /// Flat node list owned by the `TreeView`.
    pub(super) nodes: &'a [crate::ui::extras::TreeNode],
    /// Currently selected node index, if any.
    pub(super) selected: Option<usize>,
    /// Font key used to print node labels.
    pub(super) font_key: FontKey,
    /// Concrete font metrics for this tree.
    pub(super) font: Option<&'a Font>,
    /// Active widget style for colour selection.
    pub(super) style: &'a WidgetStyle,
    /// Output command buffer.
    pub(super) cmds: &'a mut Vec<RenderCommand>,
}
/// Recursively emit tree node `idx` and its expanded children as indented rows; return next Y position.
pub(super) fn emit_tree_nodes(
    ctx: &mut TreeCtx<'_>,
    idx: usize,
    x: f32,
    mut y: f32,
    row_h: f32,
    depth: usize,
) -> f32 {
    let Some(node) = ctx.nodes.get(idx) else {
        return y;
    };
    let indent = x + depth as f32 * 14.0 + 4.0;
    if ctx.selected == Some(idx) {
        ctx.cmds
            .push(RenderCommand::SetColor(0.22, 0.36, 0.60, 0.80));
        ctx.cmds.push(RenderCommand::Rectangle {
            mode: DrawMode::Fill,
            x,
            y,
            w: 9999.0,
            h: row_h,
        });
    }
    if !node.children.is_empty() {
        ctx.cmds
            .push(RenderCommand::SetColor(0.88, 0.90, 0.94, 0.90));
        if node.expanded {
            ctx.cmds.push(RenderCommand::Line {
                x1: indent,
                y1: y + 4.0,
                x2: indent + 6.0,
                y2: y + 4.0,
            });
            ctx.cmds.push(RenderCommand::Line {
                x1: indent,
                y1: y + 4.0,
                x2: indent + 3.0,
                y2: y + 8.0,
            });
            ctx.cmds.push(RenderCommand::Line {
                x1: indent + 6.0,
                y1: y + 4.0,
                x2: indent + 3.0,
                y2: y + 8.0,
            });
        } else {
            ctx.cmds.push(RenderCommand::Line {
                x1: indent,
                y1: y + 3.0,
                x2: indent,
                y2: y + row_h - 3.0,
            });
            ctx.cmds.push(RenderCommand::Line {
                x1: indent,
                y1: y + 3.0,
                x2: indent + 6.0,
                y2: y + row_h * 0.5,
            });
            ctx.cmds.push(RenderCommand::Line {
                x1: indent,
                y1: y + row_h - 3.0,
                x2: indent + 6.0,
                y2: y + row_h * 0.5,
            });
        }
    }
    emit_text_at(
        &node.text,
        indent + 10.0,
        y + (row_h - ctx.style.font_size) * 0.5,
        ctx.font_key,
        ctx.font,
        ctx.style,
        ctx.cmds,
    );
    y += row_h;
    if node.expanded {
        let children = node.children.clone();
        for child_idx in children {
            y = emit_tree_nodes(ctx, child_idx, x, y, row_h, depth + 1);
        }
    }
    y
}
/// Collect all child indices that should be rendered for `widget`, merging `children()` and type-specific slots.
pub(super) fn widget_render_children(widget: &WidgetKind) -> Vec<usize> {
    let mut children = widget.children().cloned().unwrap_or_default();
    match widget {
        WidgetKind::MenuBar(w) => children.extend(w.menus.iter().copied()),
        WidgetKind::MenuItem(w) => children.extend(w.items.iter().copied()),
        WidgetKind::Dialog(w) => {
            if let Some(child) = w.content_idx {
                children.push(child);
            }
            if let Some(child) = w.footer_idx {
                children.push(child);
            }
        }
        WidgetKind::Accordion(w) => {
            for section in &w.sections {
                if let Some(child) = section.content_idx {
                    children.push(child);
                }
            }
        }
        WidgetKind::SplitPanel(w) => {
            if let Some(child) = w.first_child {
                children.push(child);
            }
            if let Some(child) = w.second_child {
                children.push(child);
            }
        }
        WidgetKind::DockPanel(w) => {
            children.extend(w.docked.iter().map(|(child, _)| *child));
        }
        _ => {}
    }
    children.sort_unstable();
    children.dedup();
    children
}

/// Finds the topmost visible modal dialog that should own the UI modal scrim.
pub(super) fn topmost_modal_dialog(ctx: &GuiContext) -> Option<usize> {
    let mut best: Option<(usize, i32)> = None;
    for (idx, widget) in ctx.widgets.iter().enumerate().skip(1) {
        let WidgetKind::Dialog(dialog) = widget else {
            continue;
        };
        let base = widget.base();
        if !(dialog.open && dialog.modal && base.visible && base.is_visible && base.enabled) {
            continue;
        }
        match best {
            Some((best_idx, best_z))
                if best_z > base.z_order || (best_z == base.z_order && best_idx > idx) => {}
            _ => best = Some((idx, base.z_order)),
        }
    }
    best.map(|(idx, _)| idx)
}

/// Draws the fullscreen modal scrim behind the topmost active dialog.
pub(super) fn emit_modal_scrim(ctx: &GuiContext, cmds: &mut Vec<RenderCommand>) {
    let Some(root) = ctx.widgets.first() else {
        return;
    };
    let rect = root.base().computed_rect;
    cmds.push(RenderCommand::SetColor(0.03, 0.05, 0.09, 0.58));
    cmds.push(RenderCommand::Rectangle {
        mode: DrawMode::Fill,
        x: rect.x,
        y: rect.y,
        w: rect.width,
        h: rect.height,
    });
}
