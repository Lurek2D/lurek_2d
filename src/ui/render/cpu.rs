//! Owns the UI render cpu implementation for the UI subsystem and keeps related runtime rules local here.
//! Keeps retained widget state, layout helpers, and presentation rules so helpers stay close to invariants this updates.
//! Defines how UI render cpu data is validated, transformed, or stored before neighboring systems consume it.
//! Separates UI render cpu behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where UI code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing UI render cpu defaults, lifecycle handling, validation, or data ownership rules.
//! Keeps failure paths and edge cases near the UI render cpu state that explains them instead of spreading rules outward.
//! Preserves deterministic behavior by keeping UI render cpu calculations explicit at their owning subsystem boundary.
//! Provides the local adaptation layer that lets callers reuse UI render cpu rules without duplicating engine decisions.
//! Open this owner before sibling files when a regression centers on UI render cpu state, helpers, or integration rules.
//! Works with neighboring UI owners while keeping the main UI render cpu responsibility anchored in one file.
//! Changes to UI render cpu names, caches, or helper boundaries should usually stay coupled inside this owner.

use super::*;

impl GuiContext {
    /// Rasterise all visible widgets into a new `ImageData` of `width Ă— height` pixels.
    pub fn draw_to_image(&self, width: u32, height: u32) -> crate::image::ImageData {
        let mut img = crate::image::ImageData::new(width, height);
        img.fill(24, 26, 34, 255);
        // Load the 12-point bundled bitmap font for CPU text rendering.
        let ui_font: Option<crate::font::Font> = {
            let slot = crate::font::Font::nearest_point_size(12);
            let sizes = crate::font::Font::load_all_sizes();
            sizes.into_iter().nth(slot).map(|(f, _, _)| f)
        };
        let mut layout_ctx = self.clone();
        layout_ctx.run_layout_pass();
        let default_style = WidgetStyle::default();
        let Some(children) = layout_ctx.widgets.first().and_then(|w| w.children()) else {
            return img;
        };
        let mut sorted_children = children.to_vec();
        sorted_children.sort_by_key(|&i| {
            layout_ctx
                .widgets
                .get(i)
                .map(|w| w.base().z_order)
                .unwrap_or(0)
        });
        let active_modal = topmost_modal_dialog(&layout_ctx);
        let root_rect = layout_ctx
            .widgets
            .first()
            .map(|w| w.base().computed_rect)
            .unwrap_or(Rect::new(0.0, 0.0, width as f32, height as f32));
        let mut stack: Vec<usize> = Vec::new();
        for child_idx in sorted_children.into_iter().rev() {
            stack.push(child_idx);
            if active_modal == Some(child_idx) {
                stack.push(usize::MAX);
            }
        }
        while let Some(idx) = stack.pop() {
            if idx == usize::MAX {
                img.draw_rect(
                    root_rect.x as i32,
                    root_rect.y as i32,
                    root_rect.width.max(1.0) as u32,
                    root_rect.height.max(1.0) as u32,
                    8,
                    13,
                    23,
                    148,
                );
                continue;
            }
            let Some(widget) = layout_ctx.widgets.get(idx) else {
                continue;
            };
            let base = widget.base();
            if !base.visible
                || !base.is_visible
                || matches!(widget, WidgetKind::Dialog(dialog) if !dialog.open)
            {
                continue;
            }
            let rect = base.computed_rect;
            let x = rect.x as i32;
            let y = rect.y as i32;
            let w = rect.width.max(1.0) as u32;
            let h = rect.height.max(1.0) as u32;
            let style_with_alpha = resolve_style_with_alpha(&layout_ctx, base, &default_style);
            let style = &style_with_alpha;
            let draw_widget_chrome = !matches!(
                widget,
                WidgetKind::Label(_)
                    | WidgetKind::RichLabel(_)
                    | WidgetKind::AspectRatioContainer(_)
            );
            if draw_widget_chrome {
                let [sr, sg, sb, sa] = style.shadow_color;
                if sa > 0.0 {
                    let sx = x + style.shadow_offset[0] as i32;
                    let sy = y + style.shadow_offset[1] as i32;
                    img.draw_rect(
                        sx,
                        sy,
                        w,
                        h,
                        (sr * 255.0) as u8,
                        (sg * 255.0) as u8,
                        (sb * 255.0) as u8,
                        (sa * 255.0) as u8,
                    );
                }
                let [r0, g0, b0, a0] = style.bg_color;
                if let Some([r1, g1, b1, _a1]) = style.gradient_end {
                    for py in 0..h {
                        let t = if h <= 1 {
                            0.0
                        } else {
                            py as f32 / (h - 1) as f32
                        };
                        let rr = r0 + (r1 - r0) * t;
                        let gg = g0 + (g1 - g0) * t;
                        let bb = b0 + (b1 - b0) * t;
                        img.draw_rect(
                            x,
                            y + py as i32,
                            w,
                            1,
                            (rr * 255.0) as u8,
                            (gg * 255.0) as u8,
                            (bb * 255.0) as u8,
                            (a0 * 255.0) as u8,
                        );
                    }
                } else {
                    img.draw_rect(
                        x,
                        y,
                        w,
                        h,
                        (r0 * 255.0) as u8,
                        (g0 * 255.0) as u8,
                        (b0 * 255.0) as u8,
                        (a0 * 255.0) as u8,
                    );
                }
                if style.highlight_alpha > 0.0 {
                    let hi = (style.highlight_alpha.clamp(0.0, 1.0) * 140.0) as u8;
                    let strip_h = (style.border_width.max(2.0)) as u32;
                    img.draw_rect(
                        x + 1,
                        y + 1,
                        w.saturating_sub(2),
                        strip_h,
                        255,
                        255,
                        255,
                        hi,
                    );
                }
                if style.border_width > 0.0 {
                    let [br, bg, bb, ba] = style.border_color;
                    let br = (br * 255.0) as u8;
                    let bg = (bg * 255.0) as u8;
                    let bb = (bb * 255.0) as u8;
                    let ba = (ba * 255.0) as u8;
                    img.draw_rect(x, y, w, 1, br, bg, bb, ba);
                    img.draw_rect(x, y + h as i32 - 1, w, 1, br, bg, bb, ba);
                    img.draw_rect(x, y, 1, h, br, bg, bb, ba);
                    img.draw_rect(x + w as i32 - 1, y, 1, h, br, bg, bb, ba);
                }
            }
            let [frc, fgc, fbc, _fa] = style.fg_color;
            let fr = (frc * 255.0) as u8;
            let fg = (fgc * 255.0) as u8;
            let fb = (fbc * 255.0) as u8;
            let mut skip_text = false;
            match widget {
                WidgetKind::Slider(slider) => {
                    let range = (slider.max - slider.min).max(1e-6);
                    let t = ((slider.value - slider.min) / range).clamp(0.0, 1.0) as f32;
                    let fill_w = ((w as f32) * t).max(1.0) as u32;
                    img.draw_rect(
                        x,
                        y + (h as i32 / 3),
                        fill_w,
                        (h / 3).max(2),
                        fr,
                        fg,
                        fb,
                        255,
                    );
                    let knob_w = ((h as f32) * 0.35).clamp(4.0, 12.0) as u32;
                    let knob_h = h.saturating_sub(2).max(6);
                    let mut knob_x = x + fill_w as i32 - (knob_w as i32 / 2);
                    let max_x = x + w as i32 - knob_w as i32;
                    if knob_x < x {
                        knob_x = x;
                    } else if knob_x > max_x {
                        knob_x = max_x;
                    }
                    img.draw_rect(
                        knob_x,
                        y + ((h as i32 - knob_h as i32) / 2),
                        knob_w,
                        knob_h,
                        220,
                        230,
                        240,
                        255,
                    );
                    skip_text = true;
                }
                WidgetKind::ProgressBar(pb) => {
                    let range = (pb.max - pb.min).max(1e-6);
                    let t = ((pb.value - pb.min) / range).clamp(0.0, 1.0) as f32;
                    let fill_w = ((w as f32) * t).max(0.0) as u32;
                    if fill_w > 0 {
                        img.draw_rect(
                            x + 1,
                            y + 1,
                            fill_w.saturating_sub(2),
                            h.saturating_sub(2),
                            fr,
                            fg,
                            fb,
                            255,
                        );
                    }
                    let pct_label = format!("{}%", (t * 100.0).round() as u32);
                    let lw = ui_font
                        .as_ref()
                        .map(|f| f.text_width(&pct_label) as i32)
                        .unwrap_or((pct_label.chars().count() as i32) * 6);
                    draw_cpu_text(
                        &mut img,
                        ui_font.as_ref(),
                        &pct_label,
                        x + ((w as i32 - lw) / 2).max(1),
                        y + ((h as i32 - 7) / 2).max(1),
                        230,
                        235,
                        240,
                    );
                    skip_text = true;
                }
                WidgetKind::SpinBox(sb) => {
                    let btn_w = (h as i32).max(20);
                    img.draw_rect(
                        x + w as i32 - btn_w,
                        y,
                        btn_w as u32,
                        h / 2,
                        60,
                        65,
                        80,
                        255,
                    );
                    img.draw_rect(
                        x + w as i32 - btn_w,
                        y + (h / 2) as i32,
                        btn_w as u32,
                        h.div_ceil(2),
                        50,
                        55,
                        70,
                        255,
                    );
                    let ax = x + w as i32 - btn_w / 2;
                    let ay = y + h as i32 / 4;
                    img.draw_line(ax - 3, ay + 2, ax, ay - 2, 200, 210, 220, 255);
                    img.draw_line(ax, ay - 2, ax + 3, ay + 2, 200, 210, 220, 255);
                    let dy = y + (h as i32 * 3) / 4;
                    img.draw_line(ax - 3, dy - 2, ax, dy + 2, 200, 210, 220, 255);
                    img.draw_line(ax, dy + 2, ax + 3, dy - 2, 200, 210, 220, 255);
                    let label = format!("{}", sb.value);
                    let lw = ui_font
                        .as_ref()
                        .map(|f| f.text_width(&label) as i32)
                        .unwrap_or((label.chars().count() as i32) * 6);
                    draw_cpu_text(
                        &mut img,
                        ui_font.as_ref(),
                        &label,
                        x + ((w as i32 - btn_w - lw) / 2).max(2),
                        y + ((h as i32 - 7) / 2).max(1),
                        fr,
                        fg,
                        fb,
                    );
                    skip_text = true;
                }
                WidgetKind::ScrollBar(sb) => {
                    let total = sb.content_size.max(1.0);
                    let thumb_ratio = (sb.view_size / total).clamp(0.1, 1.0);
                    let pos_ratio = (sb.position / total).clamp(0.0, 1.0 - thumb_ratio);
                    if sb.vertical {
                        let thumb_h = ((h as f32) * thumb_ratio).max(8.0) as u32;
                        let thumb_y = y + (h as f32 * pos_ratio) as i32;
                        img.draw_rect(
                            x + 2,
                            thumb_y,
                            w.saturating_sub(4),
                            thumb_h,
                            fr,
                            fg,
                            fb,
                            200,
                        );
                    } else {
                        let thumb_w = ((w as f32) * thumb_ratio).max(8.0) as u32;
                        let thumb_x = x + (w as f32 * pos_ratio) as i32;
                        img.draw_rect(
                            thumb_x,
                            y + 2,
                            thumb_w,
                            h.saturating_sub(4),
                            fr,
                            fg,
                            fb,
                            200,
                        );
                    }
                    skip_text = true;
                }
                WidgetKind::Switch(sw) => {
                    let track_h = h.min(18);
                    let ty_off = (h - track_h) / 2;
                    let (on_r, on_g, on_b) = if sw.on { (70, 170, 100) } else { (60, 65, 80) };
                    img.draw_rect(x, y + ty_off as i32, w, track_h, on_r, on_g, on_b, 255);
                    let thumb_h = track_h.saturating_sub(4).max(6);
                    let thumb_w = ((thumb_h as f32) * 0.6).clamp(4.0, 12.0) as u32;
                    let travel = (w.saturating_sub(thumb_w + 4)) as f32;
                    let thumb_x = x + 2 + (sw.thumb_t.clamp(0.0, 1.0) * travel) as i32;
                    img.draw_rect(
                        thumb_x,
                        y + ((h as i32 - thumb_h as i32) / 2),
                        thumb_w,
                        thumb_h,
                        220,
                        230,
                        240,
                        255,
                    );
                    skip_text = true;
                }
                WidgetKind::CheckBox(cb) => {
                    let box_sz = (h as i32).clamp(10, 14);
                    let bx = x + 3;
                    let by = y + (h as i32 - box_sz) / 2;
                    img.draw_rect(bx, by, box_sz as u32, box_sz as u32, 90, 95, 115, 255);
                    img.draw_rect(
                        bx + 1,
                        by + 1,
                        (box_sz - 2).max(0) as u32,
                        (box_sz - 2).max(0) as u32,
                        28,
                        30,
                        44,
                        255,
                    );
                    if cb.checked {
                        img.draw_line(
                            bx + 2,
                            by + box_sz / 2,
                            bx + box_sz / 2 - 1,
                            by + box_sz - 3,
                            fr,
                            fg,
                            fb,
                            255,
                        );
                        img.draw_line(
                            bx + box_sz / 2 - 1,
                            by + box_sz - 3,
                            bx + box_sz - 2,
                            by + 2,
                            fr,
                            fg,
                            fb,
                            255,
                        );
                    }
                    if !cb.text.is_empty() {
                        draw_cpu_text(
                            &mut img,
                            ui_font.as_ref(),
                            &cb.text,
                            bx + box_sz + 6,
                            y + ((h as i32 - 7) / 2).max(1),
                            fr,
                            fg,
                            fb,
                        );
                    }
                    skip_text = true;
                }
                WidgetKind::RadioButton(rb) => {
                    let box_sz = (h as i32).clamp(10, 14);
                    let bx = x + 3;
                    let by = y + (h as i32 - box_sz) / 2;
                    img.draw_rect(bx, by, box_sz as u32, box_sz as u32, 90, 95, 115, 255);
                    img.draw_rect(
                        bx + 1,
                        by + 1,
                        (box_sz - 2).max(0) as u32,
                        (box_sz - 2).max(0) as u32,
                        28,
                        30,
                        44,
                        255,
                    );
                    if rb.selected {
                        let inner = ((box_sz as f32) * 0.45).round() as i32;
                        let ix = bx + ((box_sz - inner) / 2);
                        let iy = by + ((box_sz - inner) / 2);
                        img.draw_rect(
                            ix,
                            iy,
                            inner.max(2) as u32,
                            inner.max(2) as u32,
                            fr,
                            fg,
                            fb,
                            255,
                        );
                    }
                    if !rb.text.is_empty() {
                        draw_cpu_text(
                            &mut img,
                            ui_font.as_ref(),
                            &rb.text,
                            bx + box_sz + 6,
                            y + ((h as i32 - 7) / 2).max(1),
                            fr,
                            fg,
                            fb,
                        );
                    }
                    skip_text = true;
                }
                WidgetKind::TextInput(ti) => {
                    if let Some((sel_start, sel_end)) = ti.selection_range() {
                        let selection_x = x
                            + base.padding[3] as i32
                            + 4
                            + ui_font
                                .as_ref()
                                .map(|f| {
                                    f.text_width(&ti.text[..sel_start.min(ti.text.len())]) as i32
                                })
                                .unwrap_or(sel_start.min(ti.text.len()) as i32 * 6);
                        let selection_end_x = x
                            + base.padding[3] as i32
                            + 4
                            + ui_font
                                .as_ref()
                                .map(|f| {
                                    f.text_width(&ti.text[..sel_end.min(ti.text.len())]) as i32
                                })
                                .unwrap_or(sel_end.min(ti.text.len()) as i32 * 6);
                        let selection_width = (selection_end_x - selection_x).max(0) as u32;
                        if selection_width > 0 {
                            img.draw_rect(
                                selection_x,
                                y + 3,
                                selection_width,
                                h.saturating_sub(6),
                                fr,
                                fg,
                                fb,
                                55,
                            );
                        }
                    }
                    if ti.text.is_empty() && !ti.placeholder.is_empty() {
                        draw_cpu_text(
                            &mut img,
                            ui_font.as_ref(),
                            &ti.placeholder,
                            x + base.padding[3] as i32 + 4,
                            y + ((h as i32 - 7) / 2).max(1),
                            120,
                            125,
                            145,
                        );
                    } else {
                        draw_cpu_text(
                            &mut img,
                            ui_font.as_ref(),
                            &ti.text,
                            x + base.padding[3] as i32 + 4,
                            y + ((h as i32 - 7) / 2).max(1),
                            fr,
                            fg,
                            fb,
                        );
                    }
                    if ti.focused {
                        let cursor_x = x
                            + base.padding[3] as i32
                            + 4
                            + ui_font
                                .as_ref()
                                .map(|f| {
                                    f.text_width(&ti.text[..ti.cursor_pos.min(ti.text.len())])
                                        as i32
                                })
                                .unwrap_or(ti.cursor_pos.min(ti.text.len()) as i32 * 6);
                        img.draw_rect(cursor_x, y + 3, 1, h.saturating_sub(6), fr, fg, fb, 220);
                    }
                    skip_text = true;
                }
                WidgetKind::TextArea(ta) => {
                    let text = if ta.text.is_empty() {
                        ta.placeholder.as_str()
                    } else {
                        ta.text.as_str()
                    };
                    let (tr, tg, tb) = if ta.text.is_empty() {
                        (120, 125, 145)
                    } else {
                        (fr, fg, fb)
                    };
                    let line_h = cpu_text_height(ui_font.as_ref()).max(12) + 4;
                    let first_line = (ta.scroll_y.max(0.0) as i32 / line_h).max(0) as usize;
                    let visible_lines = ((h as i32 / line_h).max(1) as usize).saturating_add(1);
                    for (line_idx, line) in text
                        .lines()
                        .enumerate()
                        .skip(first_line)
                        .take(visible_lines)
                    {
                        let ty =
                            y + base.padding[0] as i32 + (line_idx - first_line) as i32 * line_h;
                        if ty >= y && ty < y + h as i32 {
                            draw_cpu_text(
                                &mut img,
                                ui_font.as_ref(),
                                line,
                                x + base.padding[3] as i32 + 4,
                                ty,
                                tr,
                                tg,
                                tb,
                            );
                        }
                    }
                    if ta.focused {
                        let before_cursor = &ta.text[..ta.cursor_pos.min(ta.text.len())];
                        let line = before_cursor.chars().filter(|ch| *ch == '\n').count();
                        let prefix = before_cursor.rsplit('\n').next().unwrap_or_default();
                        let cursor_x = x
                            + base.padding[3] as i32
                            + 4
                            + ui_font
                                .as_ref()
                                .map(|f| f.text_width(prefix) as i32)
                                .unwrap_or(prefix.chars().count() as i32 * 6);
                        let cursor_y =
                            y + base.padding[0] as i32 + line as i32 * line_h - ta.scroll_y as i32;
                        if cursor_y >= y && cursor_y < y + h as i32 {
                            img.draw_rect(cursor_x, cursor_y, 1, line_h as u32, fr, fg, fb, 220);
                        }
                    }
                    skip_text = true;
                }
                WidgetKind::RichLabel(rl) => {
                    let line_h = cpu_text_height(ui_font.as_ref()).max(12) + 4;
                    for (line_idx, line) in rl.plain_text().lines().enumerate() {
                        let ty = y + base.padding[0] as i32 + line_idx as i32 * line_h;
                        if ty >= y && ty < y + h as i32 {
                            draw_cpu_text(
                                &mut img,
                                ui_font.as_ref(),
                                line,
                                x + base.padding[3] as i32 + 4,
                                ty,
                                fr,
                                fg,
                                fb,
                            );
                        }
                    }
                    skip_text = true;
                }
                WidgetKind::ComboBox(cb) => {
                    if let Some(text) = cb.selected_item() {
                        draw_cpu_text(
                            &mut img,
                            ui_font.as_ref(),
                            text,
                            x + base.padding[3] as i32 + 4,
                            y + ((h as i32 - 7) / 2).max(1),
                            fr,
                            fg,
                            fb,
                        );
                    }
                    let ax = x + w as i32 - 12;
                    let ay = y + h as i32 / 2;
                    img.draw_line(ax - 4, ay - 2, ax, ay + 3, 200, 205, 215, 255);
                    img.draw_line(ax, ay + 3, ax + 4, ay - 2, 200, 205, 215, 255);
                    if cb.open && !cb.items.is_empty() {
                        if let Some((drop_rect, row_h, start, end, scroll_offset, _)) =
                            layout_ctx.combo_dropdown_metrics(idx)
                        {
                            let drop_x = drop_rect.x.round() as i32;
                            let drop_y = drop_rect.y.round() as i32;
                            let drop_w = drop_rect.width.max(1.0).round() as u32;
                            let drop_h = drop_rect.height.max(1.0).round() as u32;
                            let row_h_px = row_h.max(1.0).round() as i32;
                            img.draw_rect(drop_x, drop_y, drop_w, drop_h, 24, 26, 36, 255);
                            for (item_idx, item) in
                                cb.items.iter().enumerate().skip(start).take(end - start)
                            {
                                let row_y = drop_y
                                    + (((item_idx - start) as f32 * row_h) - scroll_offset).round()
                                        as i32;
                                if row_y + row_h_px <= drop_y || row_y >= drop_y + drop_h as i32 {
                                    continue;
                                }
                                if cb.selected_index == Some(item_idx) {
                                    img.draw_rect(
                                        drop_x + 1,
                                        row_y,
                                        drop_w.saturating_sub(2),
                                        row_h_px.max(1) as u32,
                                        55,
                                        90,
                                        155,
                                        220,
                                    );
                                }
                                draw_cpu_text(
                                    &mut img,
                                    ui_font.as_ref(),
                                    item,
                                    drop_x + 6,
                                    row_y + ((row_h_px - 7) / 2).max(1),
                                    fr,
                                    fg,
                                    fb,
                                );
                                img.draw_rect(
                                    drop_x,
                                    row_y + row_h_px - 1,
                                    drop_w,
                                    1,
                                    55,
                                    60,
                                    75,
                                    160,
                                );
                            }
                        }
                    }
                    skip_text = true;
                }
                WidgetKind::ListBox(lb) => {
                    let row_h = lb.item_height.max(12.0) as i32;
                    let first_row = (lb.scroll_y / row_h as f32).floor().max(0.0) as usize;
                    let scroll_offset = (lb.scroll_y - first_row as f32 * row_h as f32) as i32;
                    for (i, item) in lb.items.iter().enumerate().skip(first_row) {
                        let iy = y + (i - first_row) as i32 * row_h - scroll_offset;
                        if iy >= y + h as i32 {
                            break;
                        }
                        if lb.selected_index == Some(i) {
                            img.draw_rect(
                                x + 1,
                                iy,
                                w.saturating_sub(2),
                                row_h as u32,
                                55,
                                90,
                                155,
                                200,
                            );
                        }
                        draw_cpu_text(
                            &mut img,
                            ui_font.as_ref(),
                            item,
                            x + 6,
                            iy + (row_h - 7) / 2,
                            fr,
                            fg,
                            fb,
                        );
                        img.draw_rect(x, iy + row_h - 1, w, 1, 55, 60, 75, 120);
                    }
                    skip_text = true;
                }
                WidgetKind::TabBar(tb) => {
                    if !tb.tabs.is_empty() {
                        let tab_w = (w as i32 / tb.tabs.len() as i32).max(30);
                        for (i, tab) in tb.tabs.iter().enumerate() {
                            let tx = x + i as i32 * tab_w;
                            let (bg_r, bg_g, bg_b) = if i == tb.active_tab {
                                (48, 52, 72)
                            } else {
                                (32, 35, 50)
                            };
                            img.draw_rect(tx, y, tab_w as u32, h, bg_r, bg_g, bg_b, 255);
                            img.draw_rect(tx + tab_w - 1, y, 1, h, 28, 30, 44, 255);
                            if i == tb.active_tab {
                                img.draw_rect(tx, y, tab_w as u32, 2, fr, fg, fb, 255);
                            }
                            let lw = ui_font
                                .as_ref()
                                .map(|f| f.text_width(tab) as i32)
                                .unwrap_or((tab.chars().count() as i32) * 6);
                            draw_cpu_text(
                                &mut img,
                                ui_font.as_ref(),
                                tab,
                                tx + ((tab_w - lw) / 2).max(2),
                                y + ((h as i32 - 7) / 2).max(1),
                                fr,
                                fg,
                                fb,
                            );
                        }
                    }
                    skip_text = true;
                }
                WidgetKind::Toast(t) => {
                    let [brc, bgc, bbc, _ba] = style.border_color;
                    let br = (brc * 255.0) as u8;
                    let bg = (bgc * 255.0) as u8;
                    let bb = (bbc * 255.0) as u8;
                    img.draw_rect(x, y, 4, h, br, bg, bb, 255);
                    let fade_a = ((1.0 - t.progress()) * 200.0) as u8;
                    img.draw_rect(x + w as i32 - 6, y, 6, h, 255, 255, 255, fade_a);
                    draw_cpu_text(
                        &mut img,
                        ui_font.as_ref(),
                        &t.message,
                        x + 10,
                        y + ((h as i32 - 7) / 2).max(1),
                        fr,
                        fg,
                        fb,
                    );
                    skip_text = true;
                }
                WidgetKind::Badge(badge) => {
                    let text = badge.display_text();
                    let lw = ui_font
                        .as_ref()
                        .map(|f| f.text_width(&text) as i32)
                        .unwrap_or((text.chars().count() as i32) * 6);
                    draw_cpu_text(
                        &mut img,
                        ui_font.as_ref(),
                        &text,
                        x + ((w as i32 - lw) / 2).max(1),
                        y + ((h as i32 - 7) / 2).max(1),
                        245,
                        250,
                        255,
                    );
                    skip_text = true;
                }
                WidgetKind::TooltipPanel(ttp) => {
                    img.draw_rect(x, y, w, 2, fr, fg, fb, 100);
                    if !ttp.text.is_empty() {
                        draw_cpu_text(
                            &mut img,
                            ui_font.as_ref(),
                            &ttp.text,
                            x + 6,
                            y + ((h as i32 - 7) / 2).max(1),
                            fr,
                            fg,
                            fb,
                        );
                    }
                    skip_text = true;
                }
                WidgetKind::Separator(sep) => {
                    if sep.vertical {
                        let cx = x + w as i32 / 2;
                        img.draw_rect(cx, y, sep.thickness.max(1.0) as u32, h, fr, fg, fb, 160);
                    } else {
                        let cy = y + h as i32 / 2;
                        img.draw_rect(x, cy, w, sep.thickness.max(1.0) as u32, fr, fg, fb, 160);
                    }
                    skip_text = true;
                }
                WidgetKind::Spacer(_) => {
                    skip_text = true;
                }
                WidgetKind::GUIWindow(win) => {
                    let bar_h = 24u32;
                    img.draw_rect(x, y, w, h, 18, 21, 28, 245);
                    img.draw_rect(x, y, w, bar_h, 38, 42, 60, 255);
                    img.draw_rect(x, y + bar_h as i32, w, 1, 55, 60, 80, 255);
                    draw_cpu_text(
                        &mut img,
                        ui_font.as_ref(),
                        &win.title,
                        x + 10,
                        y + 7,
                        fr,
                        fg,
                        fb,
                    );
                    if win.closeable {
                        let cx = x + w as i32 - 14;
                        let cy = y + 8;
                        img.draw_line(cx, cy, cx + 8, cy + 8, 200, 80, 80, 255);
                        img.draw_line(cx + 8, cy, cx, cy + 8, 200, 80, 80, 255);
                    }
                    if win.resizable {
                        img.draw_line(
                            x + w as i32 - 14,
                            y + h as i32 - 6,
                            x + w as i32 - 6,
                            y + h as i32 - 14,
                            185,
                            190,
                            205,
                            255,
                        );
                        img.draw_line(
                            x + w as i32 - 10,
                            y + h as i32 - 6,
                            x + w as i32 - 6,
                            y + h as i32 - 10,
                            185,
                            190,
                            205,
                            255,
                        );
                    }
                    skip_text = true;
                }
                WidgetKind::Dialog(dlg) => {
                    let bar_h = 28u32;
                    img.draw_rect(x, y, w, h, 18, 21, 28, 250);
                    img.draw_rect(x, y, w, bar_h, 38, 42, 60, 255);
                    img.draw_rect(x, y + bar_h as i32, w, 1, 55, 60, 80, 255);
                    draw_cpu_text(
                        &mut img,
                        ui_font.as_ref(),
                        &dlg.title,
                        x + 10,
                        y + 9,
                        fr,
                        fg,
                        fb,
                    );
                    if dlg.closeable {
                        let close_x = x + w as i32 - 18;
                        let close_y = y + 10;
                        img.draw_line(close_x, close_y, close_x + 8, close_y + 8, 200, 80, 80, 255);
                        img.draw_line(close_x + 8, close_y, close_x, close_y + 8, 200, 80, 80, 255);
                    }
                    let has_footer = dlg.footer_idx.is_some() || !dlg.actions.is_empty();
                    if has_footer {
                        let footer_y = y + h as i32 - 34;
                        img.draw_rect(x, footer_y, w, 1, 55, 60, 80, 255);
                    }
                    if !dlg.actions.is_empty() {
                        let footer_y = y + h as i32 - 34;
                        let btn_w = 70i32;
                        let total_w = dlg.actions.len() as i32 * (btn_w + 6) - 6;
                        let mut bx = x + w as i32 - total_w - 8;
                        for action in &dlg.actions {
                            let (br, bg, bb) = if action.role.as_str() == "default" {
                                (72, 117, 194)
                            } else {
                                (48, 52, 72)
                            };
                            img.draw_rect(bx, footer_y + 4, btn_w as u32, 24, br, bg, bb, 255);
                            img.draw_rect(bx, footer_y + 4, btn_w as u32, 1, 75, 80, 105, 255);
                            let lw = ui_font
                                .as_ref()
                                .map(|f| f.text_width(&action.label) as i32)
                                .unwrap_or((action.label.chars().count() as i32) * 6);
                            draw_cpu_text(
                                &mut img,
                                ui_font.as_ref(),
                                &action.label,
                                bx + ((btn_w - lw) / 2).max(2),
                                footer_y + 10,
                                fr,
                                fg,
                                fb,
                            );
                            bx += btn_w + 6;
                        }
                    }
                    if dlg.resizable {
                        img.draw_line(
                            x + w as i32 - 14,
                            y + h as i32 - 6,
                            x + w as i32 - 6,
                            y + h as i32 - 14,
                            190,
                            195,
                            210,
                            255,
                        );
                        img.draw_line(
                            x + w as i32 - 10,
                            y + h as i32 - 6,
                            x + w as i32 - 6,
                            y + h as i32 - 10,
                            190,
                            195,
                            210,
                            255,
                        );
                    }
                    skip_text = true;
                }
                WidgetKind::StatusBar(sb) => {
                    let mut sx = x;
                    for (text, sec_w) in &sb.sections {
                        let sw = sec_w.max(20.0) as i32;
                        draw_cpu_text(
                            &mut img,
                            ui_font.as_ref(),
                            text,
                            sx + 6,
                            y + ((h as i32 - 7) / 2).max(1),
                            fr,
                            fg,
                            fb,
                        );
                        img.draw_rect(sx + sw, y, 1, h, 55, 60, 75, 160);
                        sx += sw;
                    }
                    skip_text = true;
                }
                WidgetKind::Accordion(acc) => {
                    let hdr_h = 24i32;
                    let mut ay = y;
                    for section in &acc.sections {
                        if ay + hdr_h > y + h as i32 {
                            break;
                        }
                        img.draw_rect(x, ay, w, hdr_h as u32, 42, 46, 65, 255);
                        img.draw_rect(x, ay + hdr_h - 1, w, 1, 30, 33, 48, 255);
                        let aw = 8i32;
                        let axp = x + 10;
                        let ayp = ay + hdr_h / 2;
                        if section.expanded {
                            img.draw_line(axp, ayp - 2, axp + aw, ayp - 2, fr, fg, fb, 220);
                            img.draw_line(axp, ayp - 2, axp + aw / 2, ayp + 4, fr, fg, fb, 220);
                            img.draw_line(
                                axp + aw,
                                ayp - 2,
                                axp + aw / 2,
                                ayp + 4,
                                fr,
                                fg,
                                fb,
                                220,
                            );
                        } else {
                            img.draw_line(axp, ayp - 4, axp, ayp + 4, fr, fg, fb, 220);
                            img.draw_line(axp, ayp - 4, axp + 6, ayp, fr, fg, fb, 220);
                            img.draw_line(axp, ayp + 4, axp + 6, ayp, fr, fg, fb, 220);
                        }
                        draw_cpu_text(
                            &mut img,
                            ui_font.as_ref(),
                            &section.title,
                            axp + 14,
                            ay + (hdr_h - 7) / 2,
                            fr,
                            fg,
                            fb,
                        );
                        ay += hdr_h;
                        if section.expanded {
                            ay += 36;
                        }
                    }
                    skip_text = true;
                }
                WidgetKind::ColorPicker(cp) => {
                    let bar_h = 14u32;
                    let bar_y = y + h as i32 - bar_h as i32 - 6;
                    for px in 0..w {
                        let hue = px as f32 / w as f32;
                        let (hr, hg, hb) = hsv_to_rgb(hue, 1.0, 1.0);
                        img.draw_rect(x + px as i32, bar_y, 1, bar_h, hr, hg, hb, 255);
                    }
                    let sw = (h.min(w) as i32 - 28).max(10) as u32;
                    img.draw_rect(
                        x + 6,
                        y + 6,
                        sw,
                        sw,
                        (cp.r * 255.0) as u8,
                        (cp.g * 255.0) as u8,
                        (cp.b * 255.0) as u8,
                        255,
                    );
                    img.draw_rect(x + 5, y + 5, sw + 2, 1, 90, 95, 115, 255);
                    img.draw_rect(x + 5, y + 5 + sw as i32 + 1, sw + 2, 1, 90, 95, 115, 255);
                    img.draw_rect(x + 5, y + 5, 1, sw + 2, 90, 95, 115, 255);
                    img.draw_rect(x + 5 + sw as i32 + 1, y + 5, 1, sw + 2, 90, 95, 115, 255);
                    let hex = format!(
                        "#{:02X}{:02X}{:02X}",
                        (cp.r * 255.0) as u8,
                        (cp.g * 255.0) as u8,
                        (cp.b * 255.0) as u8
                    );
                    draw_cpu_text(
                        &mut img,
                        ui_font.as_ref(),
                        &hex,
                        x + 6,
                        y + sw as i32 + 10,
                        fr,
                        fg,
                        fb,
                    );
                    skip_text = true;
                }
                WidgetKind::GUITable(tbl) => {
                    let col_h = 22i32;
                    img.draw_rect(x, y, w, col_h as u32, 38, 42, 60, 255);
                    img.draw_rect(x, y + col_h, w, 1, 55, 60, 80, 255);
                    let mut cx = x;
                    for col in &tbl.columns {
                        let cw = col.width.max(20.0) as i32;
                        draw_cpu_text(
                            &mut img,
                            ui_font.as_ref(),
                            &col.header,
                            cx + 4,
                            y + (col_h - 7) / 2,
                            190,
                            200,
                            220,
                        );
                        img.draw_rect(cx + cw, y, 1, col_h as u32, 55, 60, 80, 255);
                        cx += cw;
                    }
                    let row_h = 20i32;
                    let first_row = (tbl.scroll_y / row_h as f32).floor().max(0.0) as usize;
                    let scroll_offset = (tbl.scroll_y - first_row as f32 * row_h as f32) as i32;
                    for (ri, row) in tbl.rows.iter().enumerate().skip(first_row) {
                        let ry = y + col_h + (ri - first_row) as i32 * row_h - scroll_offset;
                        if ry + row_h > y + h as i32 {
                            break;
                        }
                        if tbl.selected_row == Some(ri) {
                            img.draw_rect(x, ry, w, row_h as u32, 50, 85, 150, 180);
                        } else if ri % 2 == 1 {
                            img.draw_rect(x, ry, w, row_h as u32, 30, 33, 48, 100);
                        }
                        let mut cx2 = x;
                        for (ci, cell) in row.iter().enumerate() {
                            let cw = tbl.columns.get(ci).map(|c| c.width).unwrap_or(80.0) as i32;
                            draw_cpu_text(
                                &mut img,
                                ui_font.as_ref(),
                                cell,
                                cx2 + 4,
                                ry + (row_h - 7) / 2,
                                fr,
                                fg,
                                fb,
                            );
                            cx2 += cw;
                        }
                        img.draw_rect(x, ry + row_h - 1, w, 1, 40, 43, 58, 140);
                    }
                    skip_text = true;
                }
                WidgetKind::PropertyWidget(prop) => {
                    let header_h = prop.group_header_height.max(18.0) as i32;
                    let row_h = prop.row_height.max(18.0) as i32;
                    let label_w = prop.label_width.clamp(48.0, w as f32) as i32;
                    let mut py = y;
                    for group in &prop.groups {
                        if py + header_h > y + h as i32 {
                            break;
                        }
                        img.draw_rect(x, py, w, header_h as u32, 42, 46, 58, 255);
                        img.draw_rect(x, py + header_h - 1, w, 1, 30, 33, 43, 255);
                        let arrow = if group.collapsed { ">" } else { "v" };
                        draw_cpu_text(
                            &mut img,
                            ui_font.as_ref(),
                            arrow,
                            x + 8,
                            cpu_text_center_y(ui_font.as_ref(), py, header_h),
                            fr,
                            fg,
                            fb,
                        );
                        draw_cpu_text(
                            &mut img,
                            ui_font.as_ref(),
                            &group.title,
                            x + 22,
                            cpu_text_center_y(ui_font.as_ref(), py, header_h),
                            fr,
                            fg,
                            fb,
                        );
                        py += header_h;
                        if group.collapsed {
                            continue;
                        }
                        for row in &group.rows {
                            if py + row_h > y + h as i32 {
                                break;
                            }
                            img.draw_rect(x, py, w, row_h as u32, 28, 30, 38, 245);
                            img.draw_rect(x + label_w, py, 1, row_h as u32, 58, 62, 76, 255);
                            img.draw_rect(x, py + row_h - 1, w, 1, 42, 45, 56, 180);
                            draw_cpu_text(
                                &mut img,
                                ui_font.as_ref(),
                                &row.name,
                                x + 8,
                                cpu_text_center_y(ui_font.as_ref(), py, row_h),
                                168,
                                176,
                                190,
                            );
                            let value_x = x + label_w + 8;
                            match row.value_kind {
                                crate::ui::PropertyValueKind::Bool => {
                                    let control_y = py + ((row_h - 12) / 2).max(0);
                                    img.draw_rect(value_x, control_y, 12, 12, 14, 16, 20, 255);
                                    img.draw_rect(value_x, control_y, 12, 1, 94, 100, 118, 255);
                                    img.draw_rect(
                                        value_x,
                                        control_y + 11,
                                        12,
                                        1,
                                        94,
                                        100,
                                        118,
                                        255,
                                    );
                                    img.draw_rect(value_x, control_y, 1, 12, 94, 100, 118, 255);
                                    img.draw_rect(
                                        value_x + 11,
                                        control_y,
                                        1,
                                        12,
                                        94,
                                        100,
                                        118,
                                        255,
                                    );
                                    if property_value_checked(&row.value) {
                                        draw_cpu_text(
                                            &mut img,
                                            ui_font.as_ref(),
                                            "x",
                                            value_x + 3,
                                            cpu_text_center_y(ui_font.as_ref(), py, row_h),
                                            fr,
                                            fg,
                                            fb,
                                        );
                                    }
                                }
                                crate::ui::PropertyValueKind::Color => {
                                    if let Some((r, g, b)) = parse_property_hex_color(&row.value) {
                                        let control_y = py + ((row_h - 12) / 2).max(0);
                                        img.draw_rect(value_x, control_y, 14, 12, r, g, b, 255);
                                        img.draw_rect(value_x, control_y, 14, 1, 95, 100, 116, 255);
                                        img.draw_rect(
                                            value_x,
                                            control_y + 11,
                                            14,
                                            1,
                                            95,
                                            100,
                                            116,
                                            255,
                                        );
                                        img.draw_rect(value_x, control_y, 1, 12, 95, 100, 116, 255);
                                        img.draw_rect(
                                            value_x + 13,
                                            control_y,
                                            1,
                                            12,
                                            95,
                                            100,
                                            116,
                                            255,
                                        );
                                    }
                                    draw_cpu_text(
                                        &mut img,
                                        ui_font.as_ref(),
                                        &row.value,
                                        value_x + 20,
                                        cpu_text_center_y(ui_font.as_ref(), py, row_h),
                                        fr,
                                        fg,
                                        fb,
                                    );
                                }
                                crate::ui::PropertyValueKind::Select => {
                                    draw_cpu_text(
                                        &mut img,
                                        ui_font.as_ref(),
                                        &row.value,
                                        value_x,
                                        cpu_text_center_y(ui_font.as_ref(), py, row_h),
                                        fr,
                                        fg,
                                        fb,
                                    );
                                    draw_cpu_text(
                                        &mut img,
                                        ui_font.as_ref(),
                                        "v",
                                        x + w as i32 - 16,
                                        cpu_text_center_y(ui_font.as_ref(), py, row_h),
                                        fr,
                                        fg,
                                        fb,
                                    );
                                }
                                _ => {
                                    draw_cpu_text(
                                        &mut img,
                                        ui_font.as_ref(),
                                        &row.value,
                                        value_x,
                                        cpu_text_center_y(ui_font.as_ref(), py, row_h),
                                        fr,
                                        fg,
                                        fb,
                                    );
                                }
                            }
                            py += row_h;
                        }
                    }
                    skip_text = true;
                }
                WidgetKind::TreeView(tv) => {
                    let row_h = 20i32;
                    let max_y = y + h as i32;
                    let mut ry = y;
                    let roots: Vec<usize> = tv.root_nodes.clone();
                    for ri in roots {
                        ry = draw_tree_nodes_cpu(
                            &tv.nodes,
                            ri,
                            &mut img,
                            ui_font.as_ref(),
                            x,
                            ry,
                            max_y,
                            row_h,
                            0,
                            tv.selected_node,
                            [fr, fg, fb],
                        );
                    }
                    skip_text = true;
                }
                WidgetKind::Toolbar(tb) => {
                    let btn_sz = h.min(28);
                    let mut bx = x + 4;
                    for btn in &tb.buttons {
                        let (br, bg2, bb2) = if btn.toggled {
                            (55, 90, 140)
                        } else {
                            (40, 44, 62)
                        };
                        img.draw_rect(
                            bx,
                            y + (h as i32 - btn_sz as i32) / 2,
                            btn_sz,
                            btn_sz,
                            br,
                            bg2,
                            bb2,
                            255,
                        );
                        img.draw_rect(
                            bx,
                            y + (h as i32 - btn_sz as i32) / 2,
                            btn_sz,
                            1,
                            65,
                            70,
                            90,
                            255,
                        );
                        img.draw_rect(
                            bx,
                            y + (h as i32 - btn_sz as i32) / 2,
                            1,
                            btn_sz,
                            65,
                            70,
                            90,
                            255,
                        );
                        if let Some(c) = btn.id.chars().next() {
                            let cs = c.to_uppercase().to_string();
                            draw_cpu_text(
                                &mut img,
                                ui_font.as_ref(),
                                &cs,
                                bx + btn_sz as i32 / 2 - 3,
                                y + (h as i32 - 7) / 2,
                                fr,
                                fg,
                                fb,
                            );
                        }
                        bx += btn_sz as i32 + 4;
                    }
                    skip_text = true;
                }
                WidgetKind::MenuBar(_) => {
                    img.draw_rect(x, y + h as i32 - 2, w, 2, fr, fg, fb, 100);
                    skip_text = true;
                }
                WidgetKind::MenuItem(mi) => {
                    if mi.checked {
                        draw_cpu_text(
                            &mut img,
                            ui_font.as_ref(),
                            "v",
                            x + 4,
                            y + ((h as i32 - 7) / 2).max(1),
                            fr,
                            fg,
                            fb,
                        );
                    }
                    let label_x = if mi.checked { x + 18 } else { x + 6 };
                    draw_cpu_text(
                        &mut img,
                        ui_font.as_ref(),
                        &mi.text,
                        label_x,
                        y + ((h as i32 - 7) / 2).max(1),
                        fr,
                        fg,
                        fb,
                    );
                    if !mi.shortcut.is_empty() {
                        let lw = ui_font
                            .as_ref()
                            .map(|f| f.text_width(&mi.shortcut) as i32)
                            .unwrap_or((mi.shortcut.chars().count() as i32) * 6);
                        draw_cpu_text(
                            &mut img,
                            ui_font.as_ref(),
                            &mi.shortcut,
                            x + w as i32 - lw - 6,
                            y + ((h as i32 - 7) / 2).max(1),
                            140,
                            145,
                            165,
                        );
                    }
                    skip_text = true;
                }
                WidgetKind::ImageWidget(_) => {
                    let cell = 8i32;
                    let mut row = 0;
                    let mut py = y;
                    while py < y + h as i32 {
                        let ch = cell.min(y + h as i32 - py);
                        let mut col = 0;
                        let mut px = x;
                        while px < x + w as i32 {
                            let cw = cell.min(x + w as i32 - px);
                            let c = if (row + col) % 2 == 0 { 80u8 } else { 55u8 };
                            img.draw_rect(px, py, cw as u32, ch as u32, c, c, c, 200);
                            col += 1;
                            px += cell;
                        }
                        row += 1;
                        py += cell;
                    }
                    img.draw_rect(x, y, w, 1, 90, 95, 115, 255);
                    img.draw_rect(x, y + h as i32 - 1, w, 1, 90, 95, 115, 255);
                    img.draw_rect(x, y, 1, h, 90, 95, 115, 255);
                    img.draw_rect(x + w as i32 - 1, y, 1, h, 90, 95, 115, 255);
                    draw_cpu_text(
                        &mut img,
                        ui_font.as_ref(),
                        "[image]",
                        x + ((w as i32 - 42) / 2).max(1),
                        y + ((h as i32 - 7) / 2).max(1),
                        130,
                        135,
                        155,
                    );
                    skip_text = true;
                }
                WidgetKind::SplitPanel(sp) => {
                    if sp.orientation == "vertical" {
                        let sy = y + (sp.split_position * h as f32) as i32;
                        img.draw_rect(x, sy - 1, w, 3, 55, 60, 80, 255);
                    } else {
                        let sx = x + (sp.split_position * w as f32) as i32;
                        img.draw_rect(sx - 1, y, 3, h, 55, 60, 80, 255);
                    }
                }
                WidgetKind::Panel(_)
                | WidgetKind::Layout(_)
                | WidgetKind::AspectRatioContainer(_)
                | WidgetKind::ScrollPanel(_)
                | WidgetKind::StackContainer(_)
                | WidgetKind::TabContainer(_)
                | WidgetKind::NinePatch(_)
                | WidgetKind::DockPanel(_)
                | WidgetKind::Button(_)
                | WidgetKind::Label(_)
                | WidgetKind::Custom(_) => {}
            }
            draw_cpu_focus_ring(&layout_ctx, base, &mut img);
            if !skip_text {
                draw_cpu_icon_and_text(
                    &mut img,
                    ui_font.as_ref(),
                    base,
                    display_text(widget),
                    x,
                    y,
                    w,
                    h,
                    style,
                    fr,
                    fg,
                    fb,
                );
            }
            let mut render_children = widget_render_children(widget);
            render_children.sort_by_key(|&child| {
                layout_ctx
                    .widgets
                    .get(child)
                    .map(|w| w.base().z_order)
                    .unwrap_or(0)
            });
            for child in render_children.into_iter().rev() {
                stack.push(child);
            }
        }
        img
    }
}
