//! Owns the terminal terminal state render implementation for the terminal subsystem and keeps rules local here.
//! Keeps terminal buffers, widgets, and text-facing presentation state so helpers stay close to invariants this updates.
//! Defines how terminal terminal state render data is validated, transformed, or stored before systems consume it.
//! Separates terminal terminal state render behavior from Lua bindings, tests, and sibling owners so integration readable.
//! Documents the boundary where terminal code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing terminal terminal state render defaults, lifecycle handling, validation, or data rules.
//! Keeps failure paths and edge cases near terminal terminal state render state that explains them instead of outward.

use super::*;

impl Terminal {
    /// Compose widgets into `cells` on top of the base grid.
    fn compose_widgets_into(&self, cells: &mut [TCell]) -> TerminalRenderStats {
        let mut stats = TerminalRenderStats {
            cells_composed: self.cols * self.rows,
            ..TerminalRenderStats::default()
        };
        for (index, widget) in self.widgets.iter().enumerate() {
            if !widget.base.visible {
                continue;
            }
            stats.widgets_drawn += 1;
            match &widget.kind {
                WidgetKind::Label { text, color } => {
                    write_render_text(
                        cells,
                        self.cols,
                        self.rows,
                        widget.base.x,
                        widget.base.y,
                        text,
                        *color,
                        char_count(text),
                    );
                }
                WidgetKind::Button { text } => {
                    let fg = if self.focused == Some(index) {
                        FOCUS_FG
                    } else {
                        BUTTON_FG
                    };
                    let bg = if self.focused == Some(index) {
                        BUTTON_FOCUS_BG
                    } else {
                        BUTTON_BG
                    };
                    if widget.base.height <= 1 {
                        draw_compact_button(
                            cells,
                            self.cols,
                            self.rows,
                            widget.base.x,
                            widget.base.y,
                            widget.base.width,
                            text,
                            fg,
                            bg,
                        );
                    } else {
                        draw_shaded_frame(
                            cells,
                            self.cols,
                            self.rows,
                            widget.base.x,
                            widget.base.y,
                            widget.base.width,
                            widget.base.height,
                            bg,
                        );
                        let row = widget.base.y + widget.base.height.saturating_sub(1) / 2;
                        let inner_width = widget.base.width.saturating_sub(2).max(1);
                        let text_width = char_count(text).min(inner_width);
                        let start_col =
                            widget.base.x + widget.base.width.saturating_sub(text_width) / 2;
                        write_render_text(
                            cells, self.cols, self.rows, start_col, row, text, fg, text_width,
                        );
                    }
                }
                WidgetKind::TextBox {
                    text, cursor_pos, ..
                } => {
                    clear_render_rect(
                        cells,
                        self.cols,
                        self.rows,
                        widget.base.x,
                        widget.base.y,
                        widget.base.width,
                        widget.base.height,
                        DEFAULT_FG,
                        TEXTBOX_BG,
                    );
                    let display = truncate_chars(text, widget.base.width);
                    stats.clipped_chars += char_count(text).saturating_sub(char_count(&display));
                    write_render_text(
                        cells,
                        self.cols,
                        self.rows,
                        widget.base.x,
                        widget.base.y,
                        &display,
                        DEFAULT_FG,
                        widget.base.width,
                    );
                    if self.focused == Some(index) && widget.base.width > 0 {
                        let cursor_col = widget.base.x + (*cursor_pos).min(widget.base.width - 1);
                        set_render_cell(
                            cells,
                            self.cols,
                            self.rows,
                            cursor_col,
                            widget.base.y,
                            CURSOR_CHAR,
                            FOCUS_FG,
                        );
                    }
                }
                WidgetKind::List {
                    items,
                    selected,
                    scroll_offset,
                } => {
                    clear_render_rect(
                        cells,
                        self.cols,
                        self.rows,
                        widget.base.x,
                        widget.base.y,
                        widget.base.width,
                        widget.base.height,
                        DEFAULT_FG,
                        LIST_BG,
                    );
                    let visible_count = items
                        .len()
                        .saturating_sub(*scroll_offset)
                        .min(widget.base.height);
                    stats.list_items_drawn += visible_count;
                    stats.list_items_skipped += items.len().saturating_sub(visible_count);
                    for row_offset in 0..widget.base.height {
                        let row = widget.base.y + row_offset;
                        let item_index = scroll_offset + row_offset;
                        if item_index >= items.len() {
                            continue;
                        }
                        let is_selected = *selected == Some(item_index);
                        let fg = if is_selected {
                            LIST_SELECTED_FG
                        } else {
                            DEFAULT_FG
                        };
                        if is_selected {
                            clear_render_rect(
                                cells,
                                self.cols,
                                self.rows,
                                widget.base.x,
                                row,
                                widget.base.width,
                                1,
                                fg,
                                LIST_SELECTED_BG,
                            );
                        }
                        let prefix = if is_selected { "> " } else { "  " };
                        let available = widget.base.width.saturating_sub(char_count(prefix));
                        let text = truncate_chars(&items[item_index], available);
                        stats.clipped_chars +=
                            char_count(&items[item_index]).saturating_sub(char_count(&text));
                        write_render_text(
                            cells,
                            self.cols,
                            self.rows,
                            widget.base.x,
                            row,
                            prefix,
                            fg,
                            char_count(prefix),
                        );
                        write_render_text(
                            cells,
                            self.cols,
                            self.rows,
                            widget.base.x + char_count(prefix),
                            row,
                            &text,
                            fg,
                            available,
                        );
                    }
                }
                WidgetKind::Border {
                    style,
                    title,
                    color,
                } => {
                    self.render_border(cells, widget, *style, title, *color);
                }
                WidgetKind::Panel { .. } => {
                    draw_shaded_frame(
                        cells,
                        self.cols,
                        self.rows,
                        widget.base.x,
                        widget.base.y,
                        widget.base.width,
                        widget.base.height,
                        PANEL_BG,
                    );
                }
            }
        }
        stats
    }

    /// Run a closure against a reusable composed cell buffer to reduce grid buffer clone churn.
    pub(crate) fn with_render_cells<R>(&self, f: impl FnOnce(&[TCell]) -> R) -> R {
        let mut scratch = self.render_scratch.borrow_mut();
        scratch.clone_from(&self.grid);
        let stats = self.compose_widgets_into(scratch.as_mut_slice());
        *self.render_stats.borrow_mut() = stats;
        f(&scratch)
    }

    /// Draw a `BorderStyle` frame with optional `title` into `cells` for `widget`.
    fn render_border(
        &self,
        cells: &mut [TCell],
        widget: &Widget,
        style: BorderStyle,
        title: &str,
        color: [f32; 4],
    ) {
        if widget.base.width == 0 || widget.base.height == 0 {
            return;
        }
        let (top_left, top_right, bottom_left, bottom_right, horizontal, vertical) = match style {
            BorderStyle::Single => ('┌', '┐', '└', '┘', '─', '│'),
            BorderStyle::Double => ('╔', '╗', '╚', '╝', '═', '║'),
            BorderStyle::Ascii => ('+', '+', '+', '+', '-', '|'),
        };
        let x = widget.base.x;
        let y = widget.base.y;
        let width = widget.base.width;
        let height = widget.base.height;
        for offset in 0..width {
            let ch = if offset == 0 {
                top_left
            } else if offset == width.saturating_sub(1) {
                top_right
            } else {
                horizontal
            };
            set_render_cell(cells, self.cols, self.rows, x + offset, y, ch, color);
            if height > 1 {
                let ch = if offset == 0 {
                    bottom_left
                } else if offset == width.saturating_sub(1) {
                    bottom_right
                } else {
                    horizontal
                };
                set_render_cell(
                    cells,
                    self.cols,
                    self.rows,
                    x + offset,
                    y + height - 1,
                    ch,
                    color,
                );
            }
        }
        if height > 2 {
            for offset in 1..height - 1 {
                set_render_cell(cells, self.cols, self.rows, x, y + offset, vertical, color);
                if width > 1 {
                    set_render_cell(
                        cells,
                        self.cols,
                        self.rows,
                        x + width - 1,
                        y + offset,
                        vertical,
                        color,
                    );
                }
            }
        }
        if width > 2 && !title.is_empty() {
            let available = width.saturating_sub(2);
            let title = truncate_chars(title, available);
            write_render_text(
                cells,
                self.cols,
                self.rows,
                x + 1,
                y,
                &title,
                color,
                available,
            );
        }
    }

    /// Build a batched `RenderCommand` list for the composited cell grid at pixel origin `(ox, oy)` with `cell_w`/`cell_h` and `font_key`.
    pub fn build_render_commands(
        &self,
        ox: f32,
        oy: f32,
        cell_w: f32,
        cell_h: f32,
        font_key: FontKey,
    ) -> Vec<RenderCommand> {
        self.with_render_cells(|cells| {
            let mut commands = Vec::new();
            for row in 0..self.rows {
                let row_cells = &cells[row * self.cols..(row + 1) * self.cols];
                if row_cells.is_empty() {
                    continue;
                }
                let flush_bg_run = |commands: &mut Vec<RenderCommand>,
                                    run_start: usize,
                                    run_len: usize,
                                    run_color: [f32; 4]| {
                    if run_len > 0 && run_color[3] > 0.0 {
                        commands.push(RenderCommand::SetColor(
                            run_color[0],
                            run_color[1],
                            run_color[2],
                            run_color[3],
                        ));
                        commands.push(RenderCommand::Rectangle {
                            mode: crate::render::renderer::DrawMode::Fill,
                            x: ox + run_start as f32 * cell_w,
                            y: oy + row as f32 * cell_h,
                            w: run_len as f32 * cell_w,
                            h: cell_h,
                        });
                    }
                };
                let mut bg_start = 0usize;
                let mut bg_color = row_cells[0].bg;
                let mut bg_len = 0usize;
                for (col, cell) in row_cells.iter().enumerate() {
                    if col > 0 && cell.bg != bg_color {
                        flush_bg_run(&mut commands, bg_start, bg_len, bg_color);
                        bg_start = col;
                        bg_color = cell.bg;
                        bg_len = 0;
                    }
                    bg_len += 1;
                }
                flush_bg_run(&mut commands, bg_start, bg_len, bg_color);
                let mut run_start = 0usize;
                let mut run_color = row_cells[0].fg;
                let mut run_text = String::new();
                let flush_run = |commands: &mut Vec<RenderCommand>,
                                 run_start: usize,
                                 run_color: [f32; 4],
                                 run_text: &mut String| {
                    if !run_text.trim().is_empty() {
                        commands.push(RenderCommand::SetColor(
                            run_color[0],
                            run_color[1],
                            run_color[2],
                            run_color[3],
                        ));
                        commands.push(RenderCommand::Print {
                            font_key,
                            text: run_text.clone(),
                            x: ox + run_start as f32 * cell_w,
                            y: oy + row as f32 * cell_h,
                            scale: 1.0,
                        });
                    }
                    run_text.clear();
                };
                for (col, cell) in row_cells.iter().enumerate() {
                    if col > 0 && cell.fg != run_color {
                        flush_run(&mut commands, run_start, run_color, &mut run_text);
                        run_start = col;
                        run_color = cell.fg;
                    }
                    run_text.push(char::from_u32(cell.ch).unwrap_or(' '));
                }
                flush_run(&mut commands, run_start, run_color, &mut run_text);
            }
            if !commands.is_empty() {
                commands.push(RenderCommand::SetColor(1.0, 1.0, 1.0, 1.0));
            }
            commands
        })
    }
}
