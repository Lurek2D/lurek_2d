//! Owns the UI context input implementation for the UI subsystem and keeps related runtime rules local here.
//! Keeps retained widget state, layout helpers, and presentation rules so helpers stay close to invariants this updates.
//! Defines how UI context input data is validated, transformed, or stored before neighboring systems consume it.
//! Separates UI context input behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where UI code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing UI context input defaults, lifecycle handling, validation, or data ownership rules.
//! Keeps failure paths and edge cases near UI context input state that explains them instead of spreading rules outward.
//! Preserves deterministic behavior by keeping UI context input calculations explicit at their owning subsystem boundary.
//! Provides the local adaptation layer that lets callers reuse UI context input rules without duplicating engine decisions.
//! Open this owner before sibling files when a regression centers on UI context input state, helpers, or integration rules.
//! Changes to UI context input names, caches, or helper boundaries should usually stay coupled inside this owner.
//! Local input routing changes should stay here so pointer capture and hit-testing rules remain aligned.
//! This file is the right stop for maintainers tracing UI context input regressions back to their concrete owner boundary.

use super::*;

impl GuiContext {
    fn widget_accepts_input(&self, idx: usize) -> bool {
        self.widget_in_active_input_scope(idx)
            && self.widgets.get(idx).is_some_and(|w| {
                let base = w.base();
                if let WidgetKind::Dialog(dialog) = w {
                    base.visible && base.is_visible && base.enabled && dialog.open
                } else {
                    base.visible && base.is_visible && base.enabled
                }
            })
    }
    fn widget_contains_point(&self, idx: usize, x: f32, y: f32) -> bool {
        self.widget_rect(idx)
            .is_some_and(|rect| rect.contains(x, y))
            && self.widget_accepts_input(idx)
    }
    /// Chooses the topmost hit candidate by z-order and stable widget index.
    pub(super) fn choose_topmost(
        current: Option<(usize, i32, usize)>,
        idx: usize,
        z_order: i32,
    ) -> Option<(usize, i32, usize)> {
        match current {
            Some((best_idx, best_z, best_order))
                if best_z > z_order || (best_z == z_order && best_order > idx) =>
            {
                Some((best_idx, best_z, best_order))
            }
            _ => Some((idx, z_order, idx)),
        }
    }
    fn mouse_event_route(&self, x: f32, y: f32) -> Vec<usize> {
        let mut hits: Vec<(usize, i32, usize)> = Vec::new();
        for idx in 1..self.widgets.len() {
            let base = self.widgets[idx].base();
            if !base.is_visible || !base.enabled {
                continue;
            }
            if !self.widget_in_active_input_scope(idx) {
                continue;
            }
            if base.mouse_filter == MouseFilter::Ignore || !self.widget_contains_point(idx, x, y) {
                continue;
            }
            hits.push((idx, base.z_order, idx));
        }
        hits.sort_by(|a, b| b.1.cmp(&a.1).then_with(|| b.2.cmp(&a.2)));
        let mut route = Vec::with_capacity(hits.len());
        for (idx, _, _) in hits {
            route.push(idx);
            if self.widgets[idx].base().mouse_filter == MouseFilter::Stop {
                break;
            }
        }
        route
    }
    fn hit_test_scroll_target(&self, x: f32, y: f32) -> Option<usize> {
        let mut hit = None;
        for idx in 1..self.widgets.len() {
            let base = self.widgets[idx].base();
            if !base.is_visible || !base.enabled {
                continue;
            }
            if !self.widget_in_active_input_scope(idx) {
                continue;
            }
            if base.mouse_filter == crate::ui::widget::MouseFilter::Ignore {
                continue;
            }
            if !matches!(
                self.widgets[idx],
                WidgetKind::ScrollPanel(_)
                    | WidgetKind::ListBox(_)
                    | WidgetKind::GUITable(_)
                    | WidgetKind::TextArea(_)
                    | WidgetKind::ScrollBar(_)
            ) || !self.widget_contains_point(idx, x, y)
            {
                continue;
            }
            let z_order = base.z_order;
            hit = Self::choose_topmost(hit, idx, z_order);
        }
        hit.map(|(idx, _, _)| idx)
    }

    /// Computes dropdown placement, visible row range, and scroll offset for a combo box.
    pub(crate) fn combo_dropdown_metrics(
        &self,
        idx: usize,
    ) -> Option<(Rect, f32, usize, usize, f32, usize)> {
        let WidgetKind::ComboBox(combo) = &self.widgets[idx] else {
            return None;
        };
        if combo.items.is_empty() {
            return None;
        }
        let rect = self.widget_rect(idx)?;
        let item_height = rect.height.max(COMBO_MIN_ITEM_HEIGHT);
        let (viewport_w, viewport_h) = self.effective_viewport_size();
        let max_visible_rows = combo.max_visible_items.max(1).min(combo.items.len());
        let below_y = rect.y + rect.height;
        let available_below = (viewport_h - below_y).max(0.0);
        let available_above = rect.y.max(0.0);
        let rows_below = (available_below / item_height).floor() as usize;
        let rows_above = (available_above / item_height).floor() as usize;
        let open_above = if rows_below >= max_visible_rows {
            false
        } else if rows_above >= max_visible_rows {
            true
        } else {
            rows_above > rows_below && rows_above > 0
        };
        let available_rows = if open_above { rows_above } else { rows_below };
        let visible_rows = available_rows.max(1).min(max_visible_rows);
        let drop_height = visible_rows as f32 * item_height;
        let max_x = (viewport_w - rect.width).max(0.0);
        let drop_x = rect.x.clamp(0.0, max_x);
        let max_y = (viewport_h - drop_height).max(0.0);
        let drop_y = if open_above {
            (rect.y - drop_height).clamp(0.0, max_y)
        } else {
            below_y.clamp(0.0, max_y)
        };
        let max_scroll = combo.items.len().saturating_sub(visible_rows) as f32 * item_height;
        let scroll_y = combo.scroll_y.clamp(0.0, max_scroll);
        let start = ((scroll_y / item_height).floor() as usize)
            .min(combo.items.len().saturating_sub(visible_rows));
        let scroll_offset = scroll_y - start as f32 * item_height;
        let extra_row = usize::from(scroll_offset > 0.0);
        let end = (start + visible_rows + extra_row).min(combo.items.len());
        Some((
            Rect::new(drop_x, drop_y, rect.width, drop_height),
            item_height,
            start,
            end,
            scroll_offset,
            visible_rows,
        ))
    }

    fn open_combo_dropdown_at(&self, x: f32, y: f32) -> Option<usize> {
        let mut hit = None;
        for idx in 1..self.widgets.len() {
            let WidgetKind::ComboBox(combo) = &self.widgets[idx] else {
                continue;
            };
            if !combo.open || !self.widget_accepts_input(idx) {
                continue;
            }
            let Some((rect, ..)) = self.combo_dropdown_metrics(idx) else {
                continue;
            };
            if !rect.contains(x, y) {
                continue;
            }
            let z_order = self.widgets[idx].base().z_order;
            hit = Self::choose_topmost(hit, idx, z_order);
        }
        hit.map(|(idx, _, _)| idx)
    }

    fn open_combo_item_at(&self, x: f32, y: f32) -> Option<(usize, usize)> {
        let mut hit: Option<(usize, i32, usize, usize)> = None;
        for idx in 1..self.widgets.len() {
            let WidgetKind::ComboBox(combo) = &self.widgets[idx] else {
                continue;
            };
            if !combo.open || combo.items.is_empty() || !self.widget_accepts_input(idx) {
                continue;
            }
            let Some((drop_rect, item_height, start, _end, scroll_offset, _visible_rows)) =
                self.combo_dropdown_metrics(idx)
            else {
                continue;
            };
            if !drop_rect.contains(x, y) {
                continue;
            }
            let item_idx =
                start + ((y - drop_rect.y + scroll_offset) / item_height).floor() as usize;
            if item_idx >= combo.items.len() {
                continue;
            }
            let z_order = self.widgets[idx].base().z_order;
            hit = match hit {
                Some((best_idx, best_z, best_order, best_item_idx))
                    if best_z > z_order || (best_z == z_order && best_order > idx) =>
                {
                    Some((best_idx, best_z, best_order, best_item_idx))
                }
                _ => Some((idx, z_order, idx, item_idx)),
            };
        }
        hit.map(|(idx, _, _, item_idx)| (idx, item_idx))
    }

    fn scroll_open_combo_dropdown(&mut self, idx: usize, y_delta: f32) -> bool {
        let Some((_, item_height, _, _, _, visible_rows)) = self.combo_dropdown_metrics(idx) else {
            return false;
        };
        let Some(WidgetKind::ComboBox(combo)) = self.widgets.get_mut(idx) else {
            return false;
        };
        let old_scroll = combo.scroll_y;
        let max_scroll = combo.items.len().saturating_sub(visible_rows) as f32 * item_height;
        combo.scroll_y = (combo.scroll_y - y_delta * item_height).clamp(0.0, max_scroll);
        if (combo.scroll_y - old_scroll).abs() > f32::EPSILON {
            self.dirty = true;
        }
        true
    }

    fn ensure_combo_item_visible(&mut self, idx: usize, item_idx: usize) {
        let Some((_, item_height, start, _end, _, visible_rows)) = self.combo_dropdown_metrics(idx)
        else {
            return;
        };
        let Some(WidgetKind::ComboBox(combo)) = self.widgets.get_mut(idx) else {
            return;
        };
        if item_idx < start {
            combo.scroll_y = item_idx as f32 * item_height;
        } else if item_idx >= start + visible_rows {
            combo.scroll_y =
                item_idx.saturating_add(1).saturating_sub(visible_rows) as f32 * item_height;
        }
    }

    fn set_combo_open(&mut self, idx: usize, open: bool) -> bool {
        let mut closed = false;
        let selected_idx = {
            let Some(WidgetKind::ComboBox(combo_box)) = self.widgets.get_mut(idx) else {
                return false;
            };
            if combo_box.open == open {
                return true;
            }
            combo_box.open = open;
            if open {
                Some(combo_box.selected_index.unwrap_or(0))
            } else {
                closed = true;
                None
            }
        };
        if closed {
            self.reset_combo_typeahead();
        }
        if let Some(selected_idx) = selected_idx {
            self.ensure_combo_item_visible(idx, selected_idx);
        }
        self.dirty = true;
        true
    }

    fn close_open_combos_except(&mut self, keep_idx: Option<usize>) -> bool {
        let mut changed = false;
        for (idx, widget) in self.widgets.iter_mut().enumerate() {
            if keep_idx == Some(idx) {
                continue;
            }
            if let WidgetKind::ComboBox(combo) = widget {
                if combo.open {
                    combo.open = false;
                    changed = true;
                }
            }
        }
        if changed {
            self.reset_combo_typeahead();
            self.dirty = true;
        }
        changed
    }

    fn set_slider_value_from_x(&mut self, idx: usize, x: f32) -> bool {
        let Some(rect) = self.widget_rect(idx) else {
            return false;
        };
        if rect.width <= 0.0 {
            return false;
        }
        let WidgetKind::Slider(slider) = &mut self.widgets[idx] else {
            return false;
        };
        let old_value = slider.value;
        let t = ((x - rect.x) / rect.width).clamp(0.0, 1.0) as f64;
        slider.set_value(slider.min + (slider.max - slider.min) * t);
        let changed = (slider.value - old_value).abs() > f64::EPSILON;
        if changed {
            self.pending_events.push(GuiEvent::Change(idx));
            self.dirty = true;
        }
        changed
    }

    fn tab_index_at(&self, idx: usize, x: f32, y: f32) -> Option<usize> {
        let WidgetKind::TabBar(tab_bar) = &self.widgets[idx] else {
            return None;
        };
        if tab_bar.tabs.is_empty() {
            return None;
        }
        let rect = self.widget_rect(idx)?;
        if !rect.contains(x, y) || rect.width <= 0.0 {
            return None;
        }
        let tab_w = rect.width / tab_bar.tabs.len() as f32;
        let tab_idx = ((x - rect.x) / tab_w).floor() as usize;
        Some(tab_idx.min(tab_bar.tabs.len() - 1))
    }

    fn select_tab_at(&mut self, idx: usize, x: f32, y: f32) -> bool {
        let Some(tab_idx) = self.tab_index_at(idx, x, y) else {
            return false;
        };
        let WidgetKind::TabBar(tab_bar) = &mut self.widgets[idx] else {
            return false;
        };
        if tab_bar.active_tab != tab_idx {
            tab_bar.active_tab = tab_idx;
            self.pending_events.push(GuiEvent::Select(idx, tab_idx));
            self.pending_events.push(GuiEvent::Change(idx));
            self.dirty = true;
        }
        true
    }

    fn list_row_at(&self, idx: usize, x: f32, y: f32) -> Option<usize> {
        let WidgetKind::ListBox(list) = &self.widgets[idx] else {
            return None;
        };
        let rect = self.widget_rect(idx)?;
        if !rect.contains(x, y) {
            return None;
        }
        let row_h = list.item_height.max(12.0);
        let row_idx = ((y - rect.y + list.scroll_y) / row_h).floor() as usize;
        (row_idx < list.items.len()).then_some(row_idx)
    }

    fn select_list_row_at(&mut self, idx: usize, x: f32, y: f32) -> bool {
        let Some(row_idx) = self.list_row_at(idx, x, y) else {
            return false;
        };
        let WidgetKind::ListBox(list) = &mut self.widgets[idx] else {
            return false;
        };
        if list.selected_index != Some(row_idx) {
            list.selected_index = Some(row_idx);
            self.pending_events.push(GuiEvent::Change(idx));
            self.dirty = true;
        }
        self.pending_events.push(GuiEvent::Select(idx, row_idx));
        true
    }

    fn table_column_at(&self, idx: usize, x: f32, y: f32) -> Option<usize> {
        let WidgetKind::GUITable(table) = &self.widgets[idx] else {
            return None;
        };
        let rect = self.widget_rect(idx)?;
        if y < rect.y || y >= rect.y + TABLE_HEADER_HEIGHT || x < rect.x || x > rect.x + rect.width
        {
            return None;
        }
        let mut col_x = rect.x;
        for (col_idx, column) in table.columns.iter().enumerate() {
            let col_w = column.width.max(20.0);
            if x >= col_x && x < col_x + col_w {
                return Some(col_idx);
            }
            col_x += col_w;
        }
        None
    }

    fn table_row_at(&self, idx: usize, x: f32, y: f32) -> Option<usize> {
        let WidgetKind::GUITable(table) = &self.widgets[idx] else {
            return None;
        };
        let rect = self.widget_rect(idx)?;
        if x < rect.x || x > rect.x + rect.width || y < rect.y + TABLE_HEADER_HEIGHT {
            return None;
        }
        let visible_body_h = (rect.height - TABLE_HEADER_HEIGHT).max(0.0);
        if y >= rect.y + TABLE_HEADER_HEIGHT + visible_body_h {
            return None;
        }
        let row_y = y - rect.y - TABLE_HEADER_HEIGHT + table.scroll_y;
        let row_idx = (row_y / TABLE_ROW_HEIGHT).floor() as usize;
        (row_idx < table.rows.len()).then_some(row_idx)
    }

    fn sort_table_at(&mut self, idx: usize, x: f32, y: f32) -> bool {
        let Some(col_idx) = self.table_column_at(idx, x, y) else {
            return false;
        };
        let WidgetKind::GUITable(table) = &mut self.widgets[idx] else {
            return false;
        };
        if !table.sortable {
            return true;
        }
        table
            .rows
            .sort_by(|left, right| left.get(col_idx).cmp(&right.get(col_idx)));
        self.pending_events.push(GuiEvent::Change(idx));
        self.dirty = true;
        true
    }

    fn select_table_row_at(&mut self, idx: usize, x: f32, y: f32) -> bool {
        let Some(row_idx) = self.table_row_at(idx, x, y) else {
            return false;
        };
        let WidgetKind::GUITable(table) = &mut self.widgets[idx] else {
            return false;
        };
        if table.selected_row != Some(row_idx) {
            table.selected_row = Some(row_idx);
            self.dirty = true;
        }
        self.pending_events.push(GuiEvent::Select(idx, row_idx));
        true
    }

    fn scroll_widget(&mut self, idx: usize, x_delta: f32, y_delta: f32) -> bool {
        let Some(widget) = self.widgets.get_mut(idx) else {
            return false;
        };
        match widget {
            WidgetKind::ScrollPanel(panel) => {
                let old_x = panel.scroll_x;
                let old_y = panel.scroll_y;
                panel.scroll_x -= x_delta * panel.scroll_speed;
                panel.scroll_y -= y_delta * panel.scroll_speed;
                panel.clamp_scroll();
                let changed = (panel.scroll_x - old_x).abs() > f32::EPSILON
                    || (panel.scroll_y - old_y).abs() > f32::EPSILON;
                if changed {
                    self.dirty = true;
                }
                true
            }
            WidgetKind::ListBox(list) => {
                let old_y = list.scroll_y;
                let content_h = list.items.len() as f32 * list.item_height.max(12.0);
                let viewport_h = if list.base.computed_rect.height > 0.0 {
                    list.base.computed_rect.height
                } else {
                    list.base.height
                };
                let max_y = (content_h - viewport_h).max(0.0);
                list.scroll_y =
                    (list.scroll_y - y_delta * list.item_height.max(12.0)).clamp(0.0, max_y);
                if (list.scroll_y - old_y).abs() > f32::EPSILON {
                    self.dirty = true;
                }
                true
            }
            WidgetKind::GUITable(table) => {
                let old_y = table.scroll_y;
                let viewport_h = if table.base.computed_rect.height > 0.0 {
                    table.base.computed_rect.height
                } else {
                    table.base.height
                };
                let visible_h = (viewport_h - TABLE_HEADER_HEIGHT).max(0.0);
                let content_h = table.rows.len() as f32 * TABLE_ROW_HEIGHT;
                let max_y = (content_h - visible_h).max(0.0);
                table.scroll_y = (table.scroll_y - y_delta * TABLE_ROW_HEIGHT).clamp(0.0, max_y);
                if (table.scroll_y - old_y).abs() > f32::EPSILON {
                    self.dirty = true;
                }
                true
            }
            WidgetKind::TextArea(text_area) => {
                let old_y = text_area.scroll_y;
                let line_h = 18.0_f32;
                let content_h = text_area.text.lines().count().max(1) as f32 * line_h;
                let viewport_h = if text_area.base.computed_rect.height > 0.0 {
                    text_area.base.computed_rect.height
                } else {
                    text_area.base.height
                };
                let max_y = (content_h - viewport_h).max(0.0);
                text_area.scroll_y = (text_area.scroll_y - y_delta * line_h).clamp(0.0, max_y);
                if (text_area.scroll_y - old_y).abs() > f32::EPSILON {
                    self.dirty = true;
                }
                true
            }
            WidgetKind::ScrollBar(scroll_bar) => {
                let old_position = scroll_bar.position;
                let delta = if scroll_bar.vertical {
                    y_delta
                } else {
                    x_delta
                };
                let max_position = (scroll_bar.content_size - scroll_bar.view_size).max(0.0);
                scroll_bar.position = (scroll_bar.position - delta * 20.0).clamp(0.0, max_position);
                if (scroll_bar.position - old_position).abs() > f32::EPSILON {
                    self.pending_events.push(GuiEvent::Change(idx));
                    self.dirty = true;
                }
                true
            }
            _ => false,
        }
    }

    fn slider_keyboard_step(slider: &Slider) -> f64 {
        if slider.step > 0.0 {
            slider.step
        } else {
            ((slider.max - slider.min).abs() / 100.0).max(0.01)
        }
    }

    fn adjust_slider_by_steps(&mut self, idx: usize, direction: f64) -> bool {
        let Some(WidgetKind::Slider(slider)) = self.widgets.get_mut(idx) else {
            return false;
        };
        let old_value = slider.value;
        let step = Self::slider_keyboard_step(slider);
        slider.set_value(slider.value + step * direction);
        if (slider.value - old_value).abs() > f64::EPSILON {
            self.pending_events.push(GuiEvent::Change(idx));
            self.dirty = true;
        }
        true
    }

    fn adjust_spin_box_by_steps(&mut self, idx: usize, direction: f64) -> bool {
        let Some(WidgetKind::SpinBox(spin_box)) = self.widgets.get_mut(idx) else {
            return false;
        };
        let old_value = spin_box.value;
        if direction > 0.0 {
            spin_box.increment();
        } else {
            spin_box.decrement();
        }
        if (spin_box.value - old_value).abs() > f64::EPSILON {
            self.pending_events.push(GuiEvent::Change(idx));
            self.dirty = true;
        }
        true
    }

    fn spin_box_direction_at(&self, idx: usize, x: f32, y: f32) -> Option<f64> {
        let rect = self.widget_rect(idx)?;
        if !rect.contains(x, y) || x < rect.x + rect.width - SPIN_BUTTON_ZONE_WIDTH {
            return None;
        }
        if y < rect.y + rect.height * 0.5 {
            Some(1.0)
        } else {
            Some(-1.0)
        }
    }

    fn select_list_index(&mut self, idx: usize, item_idx: usize) -> bool {
        let Some(WidgetKind::ListBox(list_box)) = self.widgets.get_mut(idx) else {
            return false;
        };
        if item_idx >= list_box.items.len() {
            return false;
        }
        let changed = list_box.selected_index != Some(item_idx);
        if changed {
            list_box.selected_index = Some(item_idx);
            self.pending_events.push(GuiEvent::Change(idx));
            self.dirty = true;
        }
        self.pending_events.push(GuiEvent::Select(idx, item_idx));
        true
    }

    fn move_list_selection(&mut self, idx: usize, direction: isize) -> bool {
        let (item_count, current_selection) = match self.widgets.get(idx) {
            Some(WidgetKind::ListBox(list_box)) => (list_box.items.len(), list_box.selected_index),
            _ => return false,
        };
        if item_count == 0 {
            return true;
        }
        let next = if let Some(current) = current_selection {
            current
                .saturating_add_signed(direction)
                .min(item_count.saturating_sub(1))
        } else if direction < 0 {
            item_count - 1
        } else {
            0
        };
        self.select_list_index(idx, next)
    }

    fn select_combo_index(&mut self, idx: usize, item_idx: usize) -> bool {
        let Some(WidgetKind::ComboBox(combo_box)) = self.widgets.get_mut(idx) else {
            return false;
        };
        if item_idx >= combo_box.items.len() {
            return false;
        }
        let changed = combo_box.selected_index != Some(item_idx);
        combo_box.selected_index = Some(item_idx);
        let combo_is_open = combo_box.open;
        if changed {
            self.pending_events.push(GuiEvent::Select(idx, item_idx));
            self.pending_events.push(GuiEvent::Change(idx));
            self.dirty = true;
        }
        if combo_is_open {
            self.ensure_combo_item_visible(idx, item_idx);
        }
        true
    }

    fn move_combo_selection(&mut self, idx: usize, direction: isize) -> bool {
        let (item_count, current_selection) = match self.widgets.get(idx) {
            Some(WidgetKind::ComboBox(combo_box)) => {
                (combo_box.items.len(), combo_box.selected_index)
            }
            _ => return false,
        };
        if item_count == 0 {
            return true;
        }
        let next = if let Some(current) = current_selection {
            current
                .saturating_add_signed(direction)
                .min(item_count.saturating_sub(1))
        } else if direction < 0 {
            item_count - 1
        } else {
            0
        };
        self.select_combo_index(idx, next)
    }

    fn find_combo_item_by_prefix(&self, idx: usize, prefix: &str) -> Option<usize> {
        let (items, current_selection) = match self.widgets.get(idx) {
            Some(WidgetKind::ComboBox(combo_box)) => (&combo_box.items, combo_box.selected_index),
            _ => return None,
        };
        if items.is_empty() {
            return None;
        }
        let normalized_prefix = prefix.trim().to_lowercase();
        if normalized_prefix.is_empty() {
            return None;
        }
        let start = current_selection.map_or(0, |current| (current + 1) % items.len());
        (0..items.len())
            .map(|offset| (start + offset) % items.len())
            .find(|item_idx| {
                items[*item_idx]
                    .to_lowercase()
                    .starts_with(&normalized_prefix)
            })
    }

    fn combo_typeahead_input(&mut self, idx: usize, text: &str) -> bool {
        let query = text.trim();
        if query.is_empty() {
            return false;
        }
        if self.combo_typeahead_ttl <= 0.0 {
            self.combo_typeahead_buffer.clear();
        }
        self.combo_typeahead_buffer.push_str(query);
        self.combo_typeahead_ttl = 0.75;
        if let Some(item_idx) = self.find_combo_item_by_prefix(idx, &self.combo_typeahead_buffer) {
            return self.select_combo_index(idx, item_idx);
        }
        if query.chars().count() > 1 {
            self.combo_typeahead_buffer = query.to_string();
            if let Some(item_idx) =
                self.find_combo_item_by_prefix(idx, &self.combo_typeahead_buffer)
            {
                return self.select_combo_index(idx, item_idx);
            }
        } else if let Some(last_char) = query.chars().last() {
            self.combo_typeahead_buffer = last_char.to_string();
            if let Some(item_idx) =
                self.find_combo_item_by_prefix(idx, &self.combo_typeahead_buffer)
            {
                return self.select_combo_index(idx, item_idx);
            }
        }
        false
    }

    fn select_tab_index(&mut self, idx: usize, tab_idx: usize) -> bool {
        let Some(WidgetKind::TabBar(tab_bar)) = self.widgets.get_mut(idx) else {
            return false;
        };
        if tab_idx >= tab_bar.tabs.len() {
            return false;
        }
        if tab_bar.active_tab != tab_idx {
            tab_bar.active_tab = tab_idx;
            self.pending_events.push(GuiEvent::Select(idx, tab_idx));
            self.pending_events.push(GuiEvent::Change(idx));
            self.dirty = true;
        }
        true
    }

    fn move_tab_selection(&mut self, idx: usize, direction: isize) -> bool {
        let (tab_count, active_tab) = match self.widgets.get(idx) {
            Some(WidgetKind::TabBar(tab_bar)) => (tab_bar.tabs.len(), tab_bar.active_tab),
            _ => return false,
        };
        if tab_count == 0 {
            return true;
        }
        let next = active_tab
            .saturating_add_signed(direction)
            .min(tab_count.saturating_sub(1));
        self.select_tab_index(idx, next)
    }

    fn select_radio_button(&mut self, idx: usize) -> bool {
        let group = match self.widgets.get(idx) {
            Some(WidgetKind::RadioButton(radio_button)) => radio_button.group.clone(),
            _ => return false,
        };
        let mut changed_indices = Vec::new();
        for (widget_idx, widget) in self.widgets.iter_mut().enumerate() {
            let WidgetKind::RadioButton(radio_button) = widget else {
                continue;
            };
            if radio_button.group != group {
                continue;
            }
            let should_select = widget_idx == idx;
            if radio_button.selected != should_select {
                radio_button.selected = should_select;
                changed_indices.push(widget_idx);
            }
        }
        if !changed_indices.is_empty() {
            for changed_idx in changed_indices {
                self.pending_events.push(GuiEvent::Change(changed_idx));
            }
            self.pending_events.push(GuiEvent::Select(idx, idx));
            self.dirty = true;
        }
        true
    }

    fn collect_visible_tree_nodes(
        nodes: &[TreeNode],
        node_idx: usize,
        depth: usize,
        visible_nodes: &mut Vec<(usize, usize)>,
    ) {
        let Some(node) = nodes.get(node_idx) else {
            return;
        };
        visible_nodes.push((node_idx, depth));
        if node.expanded {
            for &child_idx in &node.children {
                Self::collect_visible_tree_nodes(nodes, child_idx, depth + 1, visible_nodes);
            }
        }
    }

    fn tree_node_at(&self, idx: usize, x: f32, y: f32) -> Option<(usize, usize)> {
        let WidgetKind::TreeView(tree_view) = &self.widgets[idx] else {
            return None;
        };
        let rect = self.widget_rect(idx)?;
        if !rect.contains(x, y) {
            return None;
        }
        let row_idx = ((y - rect.y) / TREE_ROW_HEIGHT).floor() as usize;
        let mut visible_nodes = Vec::new();
        for &root_idx in &tree_view.root_nodes {
            Self::collect_visible_tree_nodes(&tree_view.nodes, root_idx, 0, &mut visible_nodes);
        }
        visible_nodes.get(row_idx).copied()
    }

    fn select_tree_node_at(&mut self, idx: usize, x: f32, y: f32) -> bool {
        let Some((node_idx, _depth)) = self.tree_node_at(idx, x, y) else {
            return false;
        };
        let Some(WidgetKind::TreeView(tree_view)) = self.widgets.get_mut(idx) else {
            return false;
        };
        let mut changed = false;
        if tree_view.selected_node != Some(node_idx) {
            tree_view.selected_node = Some(node_idx);
            changed = true;
        }
        if let Some(node) = tree_view.nodes.get_mut(node_idx) {
            if !node.children.is_empty() {
                node.expanded = !node.expanded;
                changed = true;
            }
        }
        self.pending_events.push(GuiEvent::Select(idx, node_idx));
        if changed {
            self.pending_events.push(GuiEvent::Change(idx));
            self.dirty = true;
        }
        true
    }

    fn accordion_section_at(&self, idx: usize, x: f32, y: f32) -> Option<usize> {
        let WidgetKind::Accordion(accordion) = &self.widgets[idx] else {
            return None;
        };
        let rect = self.widget_rect(idx)?;
        if !rect.contains(x, y) {
            return None;
        }
        let mut section_y = rect.y;
        for (section_idx, section) in accordion.sections.iter().enumerate() {
            if y >= section_y && y < section_y + ACCORDION_HEADER_HEIGHT {
                return Some(section_idx);
            }
            section_y += ACCORDION_HEADER_HEIGHT;
            if section.expanded {
                section_y += ACCORDION_CONTENT_HEIGHT;
            }
        }
        None
    }

    fn toggle_accordion_section(&mut self, idx: usize, section_idx: usize) -> bool {
        let Some(WidgetKind::Accordion(accordion)) = self.widgets.get_mut(idx) else {
            return false;
        };
        if section_idx >= accordion.sections.len() {
            return false;
        }
        let new_state = !accordion.sections[section_idx].expanded;
        if accordion.exclusive && new_state {
            for section in &mut accordion.sections {
                section.expanded = false;
            }
        }
        accordion.sections[section_idx].expanded = new_state;
        self.pending_events.push(GuiEvent::Select(idx, section_idx));
        self.pending_events.push(GuiEvent::Change(idx));
        self.dirty = true;
        true
    }

    fn toggle_accordion_section_at(&mut self, idx: usize, x: f32, y: f32) -> bool {
        let Some(section_idx) = self.accordion_section_at(idx, x, y) else {
            return false;
        };
        self.toggle_accordion_section(idx, section_idx)
    }

    fn set_scroll_bar_position_from_point(&mut self, idx: usize, x: f32, y: f32) -> bool {
        let Some(rect) = self.widget_rect(idx) else {
            return false;
        };
        let Some(WidgetKind::ScrollBar(scroll_bar)) = self.widgets.get_mut(idx) else {
            return false;
        };
        let max_position = (scroll_bar.content_size - scroll_bar.view_size).max(0.0);
        let track_length = if scroll_bar.vertical {
            rect.height.max(1.0)
        } else {
            rect.width.max(1.0)
        };
        let thumb_ratio = if scroll_bar.content_size <= 0.0 {
            1.0
        } else {
            (scroll_bar.view_size / scroll_bar.content_size).clamp(0.1, 1.0)
        };
        let thumb_length = (track_length * thumb_ratio).max(1.0);
        let available_track = (track_length - thumb_length).max(1.0);
        let pointer_axis = if scroll_bar.vertical {
            y - rect.y
        } else {
            x - rect.x
        };
        let ratio =
            (pointer_axis - thumb_length * 0.5).clamp(0.0, available_track) / available_track;
        let old_position = scroll_bar.position;
        scroll_bar.position = (max_position * ratio).clamp(0.0, max_position);
        if (scroll_bar.position - old_position).abs() > f32::EPSILON {
            self.pending_events.push(GuiEvent::Change(idx));
            self.dirty = true;
        }
        true
    }

    fn gui_window_close_hit(&self, idx: usize, x: f32, y: f32) -> bool {
        self.popup_close_hit(idx, PopupSurface::Window, x, y)
    }

    fn close_gui_window(&mut self, idx: usize) -> bool {
        let Some(WidgetKind::GUIWindow(window)) = self.widgets.get_mut(idx) else {
            return false;
        };
        if !window.closeable || !window.base.visible {
            return false;
        }
        window.base.visible = false;
        self.pending_events.push(GuiEvent::Close(idx));
        self.dirty = true;
        true
    }

    fn dialog_close_hit(&self, idx: usize, x: f32, y: f32) -> bool {
        self.popup_close_hit(idx, PopupSurface::Dialog, x, y)
    }

    fn popup_title_height(surface: PopupSurface) -> f32 {
        match surface {
            PopupSurface::Window => WINDOW_TITLE_HEIGHT,
            PopupSurface::Dialog => DIALOG_TITLE_HEIGHT,
        }
    }

    fn popup_is_open(&self, idx: usize, surface: PopupSurface) -> bool {
        match (surface, self.widgets.get(idx)) {
            (PopupSurface::Window, Some(WidgetKind::GUIWindow(window))) => window.base.visible,
            (PopupSurface::Dialog, Some(WidgetKind::Dialog(dialog))) => dialog.open,
            _ => false,
        }
    }

    fn popup_is_closeable(&self, idx: usize, surface: PopupSurface) -> bool {
        match (surface, self.widgets.get(idx)) {
            (PopupSurface::Window, Some(WidgetKind::GUIWindow(window))) => window.closeable,
            (PopupSurface::Dialog, Some(WidgetKind::Dialog(dialog))) => dialog.closeable,
            _ => false,
        }
    }

    fn popup_is_draggable(&self, idx: usize, surface: PopupSurface) -> bool {
        match (surface, self.widgets.get(idx)) {
            (PopupSurface::Window, Some(WidgetKind::GUIWindow(window))) => window.draggable,
            (PopupSurface::Dialog, Some(WidgetKind::Dialog(dialog))) => dialog.draggable,
            _ => false,
        }
    }

    fn popup_is_resizable(&self, idx: usize, surface: PopupSurface) -> bool {
        match (surface, self.widgets.get(idx)) {
            (PopupSurface::Window, Some(WidgetKind::GUIWindow(window))) => window.resizable,
            (PopupSurface::Dialog, Some(WidgetKind::Dialog(dialog))) => dialog.resizable,
            _ => false,
        }
    }

    fn popup_close_hit(&self, idx: usize, surface: PopupSurface, x: f32, y: f32) -> bool {
        if !self.popup_is_open(idx, surface) || !self.popup_is_closeable(idx, surface) {
            return false;
        }
        let Some(rect) = self.widget_rect(idx) else {
            return false;
        };
        let title_h = Self::popup_title_height(surface);
        y >= rect.y
            && y < rect.y + title_h
            && x >= rect.x + rect.width - title_h
            && x <= rect.x + rect.width
    }

    fn popup_title_bar_hit(&self, idx: usize, surface: PopupSurface, x: f32, y: f32) -> bool {
        if !self.popup_is_open(idx, surface) || !self.popup_is_draggable(idx, surface) {
            return false;
        }
        let Some(rect) = self.widget_rect(idx) else {
            return false;
        };
        rect.contains(x, y)
            && y < rect.y + Self::popup_title_height(surface)
            && !self.popup_close_hit(idx, surface, x, y)
    }

    fn popup_resize_edges_at(
        &self,
        idx: usize,
        surface: PopupSurface,
        x: f32,
        y: f32,
    ) -> Option<PopupResizeEdges> {
        if !self.popup_is_open(idx, surface) || !self.popup_is_resizable(idx, surface) {
            return None;
        }
        let rect = self.widget_rect(idx)?;
        if x < rect.x || x > rect.x + rect.width || y < rect.y || y > rect.y + rect.height {
            return None;
        }
        let edges = PopupResizeEdges {
            left: x <= rect.x + POPUP_RESIZE_HANDLE_SIZE,
            right: x >= rect.x + rect.width - POPUP_RESIZE_HANDLE_SIZE,
            top: y <= rect.y + POPUP_RESIZE_HANDLE_SIZE,
            bottom: y >= rect.y + rect.height - POPUP_RESIZE_HANDLE_SIZE,
        };
        edges.any().then_some(edges)
    }

    fn popup_resize_limits(&self, idx: usize) -> (f32, f32, f32, f32) {
        let base = self.widgets[idx].base();
        let (calc_min_w, calc_min_h) = self.calculate_minimum_size(idx, None);
        let min_w = base.min_width.max(calc_min_w).max(48.0);
        let min_h = base.min_height.max(calc_min_h).max(32.0);
        let max_w = if base.max_width.is_finite() {
            base.max_width.max(min_w)
        } else {
            f32::INFINITY
        };
        let max_h = if base.max_height.is_finite() {
            base.max_height.max(min_h)
        } else {
            f32::INFINITY
        };
        (min_w, min_h, max_w, max_h)
    }

    fn clamp_popup_rect(&self, idx: usize, rect: Rect) -> Rect {
        let (min_w, min_h, max_w, max_h) = self.popup_resize_limits(idx);
        let (viewport_w, viewport_h) = self.effective_viewport_size();
        let width_floor = min_w.min(viewport_w.max(min_w.min(1.0)));
        let height_floor = min_h.min(viewport_h.max(min_h.min(1.0)));
        let width_ceil = max_w.min(viewport_w.max(width_floor)).max(width_floor);
        let height_ceil = max_h.min(viewport_h.max(height_floor)).max(height_floor);
        let width = rect.width.clamp(width_floor, width_ceil);
        let height = rect.height.clamp(height_floor, height_ceil);
        let x = rect.x.clamp(0.0, (viewport_w - width).max(0.0));
        let y = rect.y.clamp(0.0, (viewport_h - height).max(0.0));
        Rect::new(x, y, width, height)
    }

    fn apply_popup_rect(&mut self, idx: usize, rect: Rect) -> bool {
        let next = self.clamp_popup_rect(idx, rect);
        let base = self.widgets[idx].base_mut();
        let changed = (base.x - next.x).abs() > f32::EPSILON
            || (base.y - next.y).abs() > f32::EPSILON
            || (base.width - next.width).abs() > f32::EPSILON
            || (base.height - next.height).abs() > f32::EPSILON;
        if changed {
            base.x = next.x;
            base.y = next.y;
            base.width = next.width;
            base.height = next.height;
            base.computed_rect = next;
            self.dirty = true;
        }
        changed
    }

    fn center_popup_in_viewport(&mut self, idx: usize) -> bool {
        let base = self.widgets[idx].base();
        let (viewport_w, viewport_h) = self.effective_viewport_size();
        let rect = Rect::new(
            (viewport_w - base.width).max(0.0) * 0.5,
            (viewport_h - base.height).max(0.0) * 0.5,
            base.width,
            base.height,
        );
        self.apply_popup_rect(idx, rect)
    }

    fn begin_popup_move(&mut self, idx: usize, surface: PopupSurface, x: f32, y: f32) -> bool {
        if !self.popup_title_bar_hit(idx, surface, x, y) {
            return false;
        }
        let Some(rect) = self.widget_rect(idx) else {
            return false;
        };
        self.captured_pointer = Some(PointerCapture::PopupMove {
            idx,
            surface,
            offset_x: x - rect.x,
            offset_y: y - rect.y,
        });
        true
    }

    fn begin_popup_resize(&mut self, idx: usize, surface: PopupSurface, x: f32, y: f32) -> bool {
        let Some(edges) = self.popup_resize_edges_at(idx, surface, x, y) else {
            return false;
        };
        let Some(rect) = self.widget_rect(idx) else {
            return false;
        };
        self.captured_pointer = Some(PointerCapture::PopupResize(PopupResizeCapture {
            idx,
            surface,
            edges,
            start_mouse_x: x,
            start_mouse_y: y,
            start_rect: rect,
        }));
        true
    }

    fn update_popup_move(&mut self, idx: usize, surface: PopupSurface, x: f32, y: f32) -> bool {
        if !self.popup_is_open(idx, surface) {
            return false;
        }
        let Some(PointerCapture::PopupMove {
            offset_x, offset_y, ..
        }) = self.captured_pointer
        else {
            return false;
        };
        self.apply_popup_rect(
            idx,
            Rect::new(
                x - offset_x,
                y - offset_y,
                self.widgets[idx].base().width,
                self.widgets[idx].base().height,
            ),
        )
    }

    fn update_popup_resize(&mut self, capture: PopupResizeCapture, x: f32, y: f32) -> bool {
        let PopupResizeCapture {
            idx,
            surface,
            edges,
            start_mouse_x,
            start_mouse_y,
            start_rect,
        } = capture;
        if !self.popup_is_open(idx, surface) || !self.popup_is_resizable(idx, surface) {
            return false;
        }
        let mut next = start_rect;
        let delta_x = x - start_mouse_x;
        let delta_y = y - start_mouse_y;
        if edges.left {
            next.x += delta_x;
            next.width -= delta_x;
        }
        if edges.right {
            next.width += delta_x;
        }
        if edges.top {
            next.y += delta_y;
            next.height -= delta_y;
        }
        if edges.bottom {
            next.height += delta_y;
        }
        let (min_w, min_h, max_w, max_h) = self.popup_resize_limits(idx);
        if next.width < min_w {
            if edges.left {
                next.x = start_rect.x + start_rect.width - min_w;
            }
            next.width = min_w;
        }
        if next.height < min_h {
            if edges.top {
                next.y = start_rect.y + start_rect.height - min_h;
            }
            next.height = min_h;
        }
        if next.width > max_w {
            if edges.left {
                next.x = start_rect.x + start_rect.width - max_w;
            }
            next.width = max_w;
        }
        if next.height > max_h {
            if edges.top {
                next.y = start_rect.y + start_rect.height - max_h;
            }
            next.height = max_h;
        }
        self.apply_popup_rect(idx, next)
    }

    fn topmost_open_dialog(&self) -> Option<usize> {
        let mut best: Option<(usize, i32, usize)> = None;
        for (idx, widget) in self.widgets.iter().enumerate().skip(1) {
            let WidgetKind::Dialog(dialog) = widget else {
                continue;
            };
            let base = widget.base();
            if !(dialog.open && base.visible && base.is_visible && base.enabled) {
                continue;
            }
            best = Self::choose_topmost(best, idx, base.z_order);
        }
        best.map(|(idx, _, _)| idx)
    }

    fn dismiss_dialog_on_outside_click(&mut self, x: f32, y: f32) -> bool {
        let Some(idx) = self.topmost_open_dialog() else {
            return false;
        };
        let Some(WidgetKind::Dialog(dialog)) = self.widgets.get(idx) else {
            return false;
        };
        if dialog.modal || !dialog.dismiss_on_outside_click || !dialog.open {
            return false;
        }
        let Some(rect) = self.widget_rect(idx) else {
            return false;
        };
        if rect.contains(x, y) {
            return false;
        }
        self.close_dialog(idx)
    }

    fn dialog_footer_button_at(&self, idx: usize, x: f32, y: f32) -> Option<usize> {
        let WidgetKind::Dialog(dialog) = &self.widgets[idx] else {
            return None;
        };
        if !dialog.open || dialog.actions.is_empty() {
            return None;
        }
        let footer_rect = Self::dialog_footer_rect(self.widget_rect(idx)?);
        let total_width = dialog.actions.len() as f32
            * (DIALOG_FOOTER_BUTTON_WIDTH + DIALOG_FOOTER_BUTTON_GAP)
            - DIALOG_FOOTER_BUTTON_GAP;
        let mut button_x = footer_rect.x + (footer_rect.width - total_width).max(0.0);
        for (button_idx, _action) in dialog.actions.iter().enumerate() {
            let button_rect = Rect::new(
                button_x,
                footer_rect.y,
                DIALOG_FOOTER_BUTTON_WIDTH,
                footer_rect.height.min(24.0),
            );
            if button_rect.contains(x, y) {
                return Some(button_idx);
            }
            button_x += DIALOG_FOOTER_BUTTON_WIDTH + DIALOG_FOOTER_BUTTON_GAP;
        }
        None
    }

    fn close_dialog(&mut self, idx: usize) -> bool {
        let Some(WidgetKind::Dialog(dialog)) = self.widgets.get_mut(idx) else {
            return false;
        };
        if !dialog.open {
            return false;
        }
        dialog.open = false;
        if matches!(
            self.captured_pointer,
            Some(PointerCapture::PopupMove { idx: capture_idx, .. }
                | PointerCapture::PopupResize(PopupResizeCapture {
                    idx: capture_idx,
                    ..
                }))
                if capture_idx == idx
        ) {
            self.captured_pointer = None;
        }
        if self
            .focused_widget
            .is_some_and(|focused| focused == idx || self.is_descendant_of(idx, focused))
        {
            self.focused_widget = None;
        }
        self.pending_events.push(GuiEvent::Close(idx));
        self.dirty = true;
        true
    }

    fn activate_dialog_action(&mut self, idx: usize, button_idx: usize) -> bool {
        let action = match self.widgets.get(idx) {
            Some(WidgetKind::Dialog(dialog)) => dialog.actions.get(button_idx).cloned(),
            _ => None,
        };
        let Some(action) = action else {
            return false;
        };
        self.pending_events.push(GuiEvent::Select(idx, button_idx));
        self.pending_events.push(GuiEvent::Click(idx));
        if action.close_on_activate {
            self.close_dialog(idx);
        }
        true
    }

    fn activate_dialog_default_action(&mut self, idx: usize) -> bool {
        let action_idx = match self.widgets.get(idx) {
            Some(WidgetKind::Dialog(dialog)) => dialog.default_action_idx,
            _ => None,
        };
        action_idx.is_some_and(|action_idx| self.activate_dialog_action(idx, action_idx))
    }

    fn activate_dialog_cancel_action(&mut self, idx: usize) -> bool {
        let (cancel_idx, closeable) = match self.widgets.get(idx) {
            Some(WidgetKind::Dialog(dialog)) => (dialog.cancel_action_idx, dialog.closeable),
            _ => return false,
        };
        if let Some(cancel_idx) = cancel_idx {
            return self.activate_dialog_action(idx, cancel_idx);
        }
        if closeable {
            return self.close_dialog(idx);
        }
        false
    }

    /// Open a dialog widget, enforcing size constraints and optional centering.
    pub(crate) fn open_dialog_widget(&mut self, idx: usize) -> bool {
        let (was_open, center_on_open) = match self.widgets.get(idx) {
            Some(WidgetKind::Dialog(dialog)) => (dialog.open, dialog.center_on_open),
            _ => return false,
        };
        if let Some(WidgetKind::Dialog(dialog)) = self.widgets.get_mut(idx) {
            dialog.open = true;
        }
        let current = {
            let base = self.widgets[idx].base();
            Rect::new(base.x, base.y, base.width, base.height)
        };
        let _ = self.apply_popup_rect(idx, current);
        if center_on_open && !was_open {
            let _ = self.center_popup_in_viewport(idx);
        }
        if self.active_modal_dialog() == Some(idx) {
            self.set_focus(None);
            self.focus_next();
        }
        true
    }

    /// Close a dialog widget and emit its close event when needed.
    pub(crate) fn close_dialog_widget(&mut self, idx: usize) -> bool {
        self.close_dialog(idx)
    }

    /// Center a dialog widget within the active viewport while keeping it clamped.
    pub(crate) fn center_dialog_widget(&mut self, idx: usize) -> bool {
        matches!(self.widgets.get(idx), Some(WidgetKind::Dialog(_)))
            && self.center_popup_in_viewport(idx)
    }

    fn toolbar_button_at(&self, idx: usize, x: f32, y: f32) -> Option<usize> {
        let WidgetKind::Toolbar(toolbar) = &self.widgets[idx] else {
            return None;
        };
        let rect = self.widget_rect(idx)?;
        if !rect.contains(x, y) {
            return None;
        }
        let button_size = rect.height.min(28.0);
        if toolbar.orientation == "vertical" {
            let mut button_y = rect.y + TOOLBAR_BUTTON_GAP;
            let button_x = rect.x + (rect.width - button_size) * 0.5;
            for (button_idx, button) in toolbar.buttons.iter().enumerate() {
                let button_rect = Rect::new(button_x, button_y, button_size, button_size);
                if button.enabled && button_rect.contains(x, y) {
                    return Some(button_idx);
                }
                button_y += button_size + TOOLBAR_BUTTON_GAP;
            }
        } else {
            let mut button_x = rect.x + TOOLBAR_BUTTON_GAP;
            let button_y = rect.y + (rect.height - button_size) * 0.5;
            for (button_idx, button) in toolbar.buttons.iter().enumerate() {
                let button_rect = Rect::new(button_x, button_y, button_size, button_size);
                if button.enabled && button_rect.contains(x, y) {
                    return Some(button_idx);
                }
                button_x += button_size + TOOLBAR_BUTTON_GAP;
            }
        }
        None
    }

    fn toggle_toolbar_button(&mut self, idx: usize, button_idx: usize) -> bool {
        let Some(WidgetKind::Toolbar(toolbar)) = self.widgets.get_mut(idx) else {
            return false;
        };
        let Some(button) = toolbar.buttons.get_mut(button_idx) else {
            return false;
        };
        if !button.enabled {
            return false;
        }
        button.toggled = !button.toggled;
        self.pending_events.push(GuiEvent::Select(idx, button_idx));
        self.pending_events.push(GuiEvent::Change(idx));
        self.pending_events.push(GuiEvent::Click(idx));
        self.dirty = true;
        true
    }

    fn color_picker_color_at(&self, idx: usize, x: f32, y: f32) -> Option<(f32, f32, f32)> {
        let WidgetKind::ColorPicker(color_picker) = &self.widgets[idx] else {
            return None;
        };
        let rect = self.widget_rect(idx)?;
        let hue_bar_rect = Rect::new(
            rect.x,
            rect.y + rect.height - COLOR_PICKER_HUE_BAR_HEIGHT - COLOR_PICKER_HUE_BAR_BOTTOM_PAD,
            rect.width,
            COLOR_PICKER_HUE_BAR_HEIGHT,
        );
        if hue_bar_rect.contains(x, y) {
            let hue = ((x - hue_bar_rect.x) / hue_bar_rect.width).clamp(0.0, 1.0);
            return Some(Self::hsv_to_rgb_unit(hue, 1.0, 1.0));
        }
        let swatch_size = (rect.height.min(rect.width) - 28.0).max(10.0);
        let swatch_rect = Rect::new(
            rect.x + COLOR_PICKER_SWATCH_PAD,
            rect.y + COLOR_PICKER_SWATCH_PAD,
            swatch_size,
            swatch_size,
        );
        if swatch_rect.contains(x, y) {
            let (hue, _old_saturation, _old_value) =
                Self::rgb_to_hsv_unit(color_picker.r, color_picker.g, color_picker.b);
            let saturation = ((x - swatch_rect.x) / swatch_rect.width).clamp(0.0, 1.0);
            let value = (1.0 - (y - swatch_rect.y) / swatch_rect.height).clamp(0.0, 1.0);
            return Some(Self::hsv_to_rgb_unit(hue, saturation, value));
        }
        None
    }

    fn set_color_picker_from_point(&mut self, idx: usize, x: f32, y: f32) -> bool {
        let Some((next_red, next_green, next_blue)) = self.color_picker_color_at(idx, x, y) else {
            return false;
        };
        let Some(WidgetKind::ColorPicker(color_picker)) = self.widgets.get_mut(idx) else {
            return false;
        };
        let changed = (color_picker.r - next_red).abs() > f32::EPSILON
            || (color_picker.g - next_green).abs() > f32::EPSILON
            || (color_picker.b - next_blue).abs() > f32::EPSILON;
        if changed {
            color_picker.r = next_red.clamp(0.0, 1.0);
            color_picker.g = next_green.clamp(0.0, 1.0);
            color_picker.b = next_blue.clamp(0.0, 1.0);
            self.pending_events.push(GuiEvent::Change(idx));
            self.dirty = true;
        }
        true
    }

    fn activate_focused_widget(&mut self) -> bool {
        let Some(idx) = self.focused_widget else {
            return false;
        };
        let Some(widget_type) = self
            .widgets
            .get(idx)
            .map(|widget| widget.base().widget_type)
        else {
            return false;
        };
        match widget_type {
            WidgetType::Button | WidgetType::MenuItem => {
                self.pending_events.push(GuiEvent::Click(idx));
                true
            }
            WidgetType::CheckBox => {
                if let Some(WidgetKind::CheckBox(check_box)) = self.widgets.get_mut(idx) {
                    check_box.checked = !check_box.checked;
                    self.pending_events.push(GuiEvent::Change(idx));
                    self.dirty = true;
                    true
                } else {
                    false
                }
            }
            WidgetType::Switch => {
                if let Some(WidgetKind::Switch(switch)) = self.widgets.get_mut(idx) {
                    switch.toggle();
                    self.pending_events.push(GuiEvent::Change(idx));
                    self.dirty = true;
                    true
                } else {
                    false
                }
            }
            WidgetType::RadioButton => {
                let consumed = self.select_radio_button(idx);
                if consumed {
                    self.pending_events.push(GuiEvent::Click(idx));
                }
                consumed
            }
            WidgetType::ComboBox => {
                let next_open = matches!(self.widgets.get(idx), Some(WidgetKind::ComboBox(combo_box)) if !combo_box.open);
                self.set_combo_open(idx, next_open)
            }
            _ => false,
        }
    }

    fn navigate_focused_widget(&mut self, key: &str) -> bool {
        let Some(idx) = self.focused_widget else {
            return false;
        };
        let Some(widget_type) = self
            .widgets
            .get(idx)
            .map(|widget| widget.base().widget_type)
        else {
            return false;
        };
        match (widget_type, key) {
            (WidgetType::Slider, "left" | "down") => self.adjust_slider_by_steps(idx, -1.0),
            (WidgetType::Slider, "right" | "up") => self.adjust_slider_by_steps(idx, 1.0),
            (WidgetType::SpinBox, "left" | "down") => self.adjust_spin_box_by_steps(idx, -1.0),
            (WidgetType::SpinBox, "right" | "up") => self.adjust_spin_box_by_steps(idx, 1.0),
            (WidgetType::ListBox, "up") => self.move_list_selection(idx, -1),
            (WidgetType::ListBox, "down") => self.move_list_selection(idx, 1),
            (WidgetType::ListBox, "home") => self.select_list_index(idx, 0),
            (WidgetType::ListBox, "end") => {
                let item_count = match self.widgets.get(idx) {
                    Some(WidgetKind::ListBox(list_box)) => list_box.items.len(),
                    _ => 0,
                };
                item_count > 0 && self.select_list_index(idx, item_count - 1)
            }
            (WidgetType::ComboBox, "up") => self.move_combo_selection(idx, -1),
            (WidgetType::ComboBox, "down") => self.move_combo_selection(idx, 1),
            (WidgetType::ComboBox, "home") => self.select_combo_index(idx, 0),
            (WidgetType::ComboBox, "end") => {
                let item_count = match self.widgets.get(idx) {
                    Some(WidgetKind::ComboBox(combo_box)) => combo_box.items.len(),
                    _ => 0,
                };
                item_count > 0 && self.select_combo_index(idx, item_count - 1)
            }
            (WidgetType::TabBar, "left" | "up") => self.move_tab_selection(idx, -1),
            (WidgetType::TabBar, "right" | "down") => self.move_tab_selection(idx, 1),
            (WidgetType::TabBar, "home") => self.select_tab_index(idx, 0),
            (WidgetType::TabBar, "end") => {
                let tab_count = match self.widgets.get(idx) {
                    Some(WidgetKind::TabBar(tab_bar)) => tab_bar.tabs.len(),
                    _ => 0,
                };
                tab_count > 0 && self.select_tab_index(idx, tab_count - 1)
            }
            _ => false,
        }
    }

    /// Process a mouse button press at `(x, y)`; return `true` if any widget consumed it.
    pub fn mouse_pressed(&mut self, x: f32, y: f32, _button: u32) -> bool {
        self.last_mouse_pos = Some((x, y));
        self.ensure_input_layout();
        if let Some((idx, item_idx)) = self.open_combo_item_at(x, y) {
            self.set_focus(Some(idx));
            let changed = if let WidgetKind::ComboBox(combo) = &mut self.widgets[idx] {
                let changed = combo.selected_index != Some(item_idx);
                combo.selected_index = Some(item_idx);
                combo.open = false;
                changed
            } else {
                false
            };
            if changed {
                self.pending_events.push(GuiEvent::Select(idx, item_idx));
                self.pending_events.push(GuiEvent::Change(idx));
            }
            self.dirty = true;
            return true;
        }
        self.dismiss_dialog_on_outside_click(x, y);
        let route = self.mouse_event_route(x, y);
        let hit = route
            .iter()
            .copied()
            .find(|idx| self.widgets[*idx].base().mouse_filter == MouseFilter::Stop);
        if !route.is_empty() {
            let keep_combo =
                hit.filter(|idx| matches!(self.widgets[*idx], WidgetKind::ComboBox(_)));
            self.close_open_combos_except(keep_combo);
            let focus_target = hit.or_else(|| {
                route.iter().copied().find(|idx| {
                    let base = self.widgets[*idx].base();
                    base.focusable && base.is_visible && base.enabled
                })
            });
            self.set_focus(focus_target);
            for idx in &route {
                self.widgets[*idx].base_mut().state = WidgetState::Pressed;
            }
            let Some(idx) = hit else {
                self.dirty = true;
                return true;
            };
            let widget_type = self.widgets[idx].base().widget_type;
            match widget_type {
                WidgetType::CheckBox => {
                    if let WidgetKind::CheckBox(check_box) = &mut self.widgets[idx] {
                        check_box.checked = !check_box.checked;
                    }
                    self.pending_events.push(GuiEvent::Change(idx));
                    self.dirty = true;
                }
                WidgetType::Switch => {
                    if let WidgetKind::Switch(switch) = &mut self.widgets[idx] {
                        switch.toggle();
                    }
                    self.pending_events.push(GuiEvent::Change(idx));
                    self.dirty = true;
                }
                WidgetType::Slider => {
                    self.captured_pointer = Some(PointerCapture::Slider(idx));
                    self.set_slider_value_from_x(idx, x);
                }
                WidgetType::TabBar => {
                    self.select_tab_at(idx, x, y);
                }
                WidgetType::ComboBox => {
                    let next_open = matches!(self.widgets.get(idx), Some(WidgetKind::ComboBox(combo_box)) if !combo_box.open);
                    self.set_combo_open(idx, next_open);
                }
                WidgetType::ListBox => {
                    self.select_list_row_at(idx, x, y);
                }
                WidgetType::GUITable => {
                    if !self.sort_table_at(idx, x, y) {
                        self.select_table_row_at(idx, x, y);
                    }
                }
                WidgetType::RadioButton => {
                    self.select_radio_button(idx);
                }
                WidgetType::TreeView => {
                    self.select_tree_node_at(idx, x, y);
                }
                WidgetType::SpinBox => {
                    if let Some(direction) = self.spin_box_direction_at(idx, x, y) {
                        self.adjust_spin_box_by_steps(idx, direction);
                    }
                }
                WidgetType::Accordion => {
                    self.toggle_accordion_section_at(idx, x, y);
                }
                WidgetType::ScrollBar => {
                    self.captured_pointer = Some(PointerCapture::ScrollBar(idx));
                    self.set_scroll_bar_position_from_point(idx, x, y);
                }
                WidgetType::GUIWindow => {
                    if self.gui_window_close_hit(idx, x, y) {
                        self.close_gui_window(idx);
                    } else if self.begin_popup_resize(idx, PopupSurface::Window, x, y) {
                    } else {
                        self.begin_popup_move(idx, PopupSurface::Window, x, y);
                    }
                }
                WidgetType::Dialog => {
                    if self.dialog_close_hit(idx, x, y) {
                        self.close_dialog(idx);
                    } else if let Some(button_idx) = self.dialog_footer_button_at(idx, x, y) {
                        self.activate_dialog_action(idx, button_idx);
                    } else if self.begin_popup_resize(idx, PopupSurface::Dialog, x, y) {
                    } else {
                        self.begin_popup_move(idx, PopupSurface::Dialog, x, y);
                    }
                }
                WidgetType::Toolbar => {
                    if let Some(button_idx) = self.toolbar_button_at(idx, x, y) {
                        self.toggle_toolbar_button(idx, button_idx);
                    }
                }
                WidgetType::ColorPicker => {
                    self.set_color_picker_from_point(idx, x, y);
                }
                WidgetType::PropertyWidget => {
                    if let Some(group_idx) = self.property_group_header_at(idx, x, y) {
                        if let WidgetKind::PropertyWidget(property_widget) = &mut self.widgets[idx]
                        {
                            let _ = property_widget.toggle_group(group_idx);
                            self.pending_events.push(GuiEvent::Change(idx));
                            self.dirty = true;
                        }
                    }
                }
                _ => {}
            }
            true
        } else {
            self.close_open_combos_except(None);
            self.set_focus(None);
            false
        }
    }
    /// Process a mouse button release at `(x, y)`; fires `Click` events on clickable widgets.
    pub fn mouse_released(&mut self, x: f32, y: f32, _button: u32) -> bool {
        self.last_mouse_pos = Some((x, y));
        self.ensure_input_layout();
        let mut consumed = false;
        let mut click_targets = Vec::new();
        if let Some(capture) = self.captured_pointer.take() {
            match capture {
                PointerCapture::Slider(idx)
                | PointerCapture::ScrollBar(idx)
                | PointerCapture::PopupMove { idx, .. }
                | PointerCapture::PopupResize(PopupResizeCapture { idx, .. }) => {
                    if idx < self.widgets.len() {
                        let inside = self.widget_contains_point(idx, x, y);
                        self.widgets[idx].base_mut().state = if inside {
                            WidgetState::Hovered
                        } else {
                            WidgetState::Normal
                        };
                        consumed = true;
                    }
                }
            }
        }
        for idx in self.mouse_event_route(x, y) {
            let base = self.widgets[idx].base();
            if base.state != WidgetState::Pressed
                || !base.is_visible
                || !base.enabled
                || base.mouse_filter == MouseFilter::Ignore
            {
                continue;
            }
            let is_clickable = base.mouse_filter == MouseFilter::Pass
                || matches!(
                    self.widgets[idx],
                    WidgetKind::Button(_) | WidgetKind::RadioButton(_) | WidgetKind::MenuItem(_)
                );
            if is_clickable {
                click_targets.push(idx);
            }
        }
        for i in 1..self.widgets.len() {
            let base = self.widgets[i].base();
            if base.state == WidgetState::Pressed {
                if !base.is_visible || !base.enabled || base.mouse_filter == MouseFilter::Ignore {
                    self.widgets[i].base_mut().state = WidgetState::Normal;
                    continue;
                }
                let inside = self.widget_contains_point(i, x, y);
                let new_state = if inside {
                    WidgetState::Hovered
                } else {
                    WidgetState::Normal
                };
                self.widgets[i].base_mut().state = new_state;
                consumed = true;
            }
        }
        for idx in click_targets {
            self.pending_events.push(GuiEvent::Click(idx));
        }
        consumed
    }
    /// Process a mouse move to `(x, y)`; updates `Hovered`/`Normal` states; return `true` on any state change.
    pub fn mouse_moved(&mut self, x: f32, y: f32) -> bool {
        self.last_mouse_pos = Some((x, y));
        self.ensure_input_layout();
        let mut changed = false;
        if let Some(capture) = self.captured_pointer {
            match capture {
                PointerCapture::Slider(idx) => {
                    changed |= self.set_slider_value_from_x(idx, x);
                }
                PointerCapture::ScrollBar(idx) => {
                    changed |= self.set_scroll_bar_position_from_point(idx, x, y);
                }
                PointerCapture::PopupMove { idx, surface, .. } => {
                    changed |= self.update_popup_move(idx, surface, x, y);
                }
                PointerCapture::PopupResize(capture) => {
                    changed |= self.update_popup_resize(capture, x, y);
                }
            }
        }
        for i in 1..self.widgets.len() {
            let base = self.widgets[i].base();
            if !base.visible
                || !base.is_visible
                || !base.enabled
                || !self.widget_in_active_input_scope(i)
            {
                continue;
            }
            // Ignore widgets do not receive hover state changes.
            if base.mouse_filter == crate::ui::widget::MouseFilter::Ignore {
                continue;
            }
            let inside = self.widget_contains_point(i, x, y);
            let current = base.state;
            if current == WidgetState::Pressed || current == WidgetState::Disabled {
                continue;
            }
            let new_state = if inside {
                if self.focused_widget == Some(i) {
                    WidgetState::Focused
                } else {
                    WidgetState::Hovered
                }
            } else if self.focused_widget == Some(i) {
                WidgetState::Focused
            } else {
                WidgetState::Normal
            };
            if current != new_state {
                self.widgets[i].base_mut().state = new_state;
                changed = true;
            }
        }
        changed
    }
    /// Process a key press by name; routes focus, editing, activation, and widget navigation keys.
    pub fn key_pressed(&mut self, key: &str) -> bool {
        let normalized_key = key.to_ascii_lowercase();
        match normalized_key.as_str() {
            "ctrl+a" => {
                if let Some(idx) = self.focused_widget {
                    match &mut self.widgets[idx] {
                        WidgetKind::TextInput(ti) => {
                            if ti.select_all() {
                                self.dirty = true;
                            }
                            return true;
                        }
                        WidgetKind::TextArea(ta) => {
                            if ta.select_all() {
                                self.dirty = true;
                            }
                            return true;
                        }
                        _ => {}
                    }
                }
                false
            }
            "shift+tab" => {
                self.focus_prev();
                true
            }
            "tab" => {
                self.focus_next();
                true
            }
            "backspace" => {
                if let Some(idx) = self.focused_widget {
                    match &mut self.widgets[idx] {
                        WidgetKind::TextInput(ti) => {
                            if ti.backspace() {
                                self.pending_events.push(GuiEvent::Change(idx));
                                self.dirty = true;
                            }
                            return true;
                        }
                        WidgetKind::TextArea(ta) => {
                            if ta.backspace() {
                                self.pending_events.push(GuiEvent::Change(idx));
                                self.dirty = true;
                            }
                            return true;
                        }
                        _ => {}
                    }
                }
                false
            }
            "delete" => {
                if let Some(idx) = self.focused_widget {
                    match &mut self.widgets[idx] {
                        WidgetKind::TextInput(ti) => {
                            if ti.delete_forward() {
                                self.pending_events.push(GuiEvent::Change(idx));
                                self.dirty = true;
                            }
                            return true;
                        }
                        WidgetKind::TextArea(ta) => {
                            if ta.delete_forward() {
                                self.pending_events.push(GuiEvent::Change(idx));
                                self.dirty = true;
                            }
                            return true;
                        }
                        _ => {}
                    }
                }
                false
            }
            "left" | "right" | "home" | "end" => {
                if let Some(idx) = self.focused_widget {
                    match &mut self.widgets[idx] {
                        WidgetKind::TextInput(ti) => {
                            let moved = match normalized_key.as_str() {
                                "left" => ti.move_cursor_left(),
                                "right" => ti.move_cursor_right(),
                                "home" => ti.move_cursor_home(),
                                "end" => ti.move_cursor_end(),
                                _ => false,
                            };
                            if moved {
                                self.dirty = true;
                            }
                            return true;
                        }
                        WidgetKind::TextArea(ta) => {
                            let moved = match normalized_key.as_str() {
                                "left" => ta.move_cursor_left(),
                                "right" => ta.move_cursor_right(),
                                "home" => ta.move_cursor_home(),
                                "end" => ta.move_cursor_end(),
                                _ => false,
                            };
                            if moved {
                                self.dirty = true;
                            }
                            return true;
                        }
                        _ => {}
                    }
                }
                self.navigate_focused_widget(&normalized_key)
            }
            "ctrl+left" | "ctrl+right" => {
                if let Some(idx) = self.focused_widget {
                    if let WidgetKind::TextInput(ti) = &mut self.widgets[idx] {
                        let moved = match normalized_key.as_str() {
                            "ctrl+left" => ti.move_cursor_word_left(),
                            "ctrl+right" => ti.move_cursor_word_right(),
                            _ => false,
                        };
                        if moved {
                            self.dirty = true;
                        }
                        return true;
                    }
                }
                false
            }
            "shift+left" | "shift+right" | "shift+home" | "shift+end" => {
                if let Some(idx) = self.focused_widget {
                    if let WidgetKind::TextInput(ti) = &mut self.widgets[idx] {
                        let moved = match normalized_key.as_str() {
                            "shift+left" => ti.move_cursor_left_with_selection(true),
                            "shift+right" => ti.move_cursor_right_with_selection(true),
                            "shift+home" => ti.move_cursor_home_with_selection(true),
                            "shift+end" => ti.move_cursor_end_with_selection(true),
                            _ => false,
                        };
                        if moved {
                            self.dirty = true;
                        }
                        return true;
                    }
                }
                false
            }
            "up" | "down" => self.navigate_focused_widget(&normalized_key),
            "return" | "enter" => {
                if let Some(idx) = self.focused_widget {
                    if let WidgetKind::TextArea(text_area) = &mut self.widgets[idx] {
                        if text_area.insert_text("\n") {
                            self.pending_events.push(GuiEvent::Change(idx));
                            self.dirty = true;
                        }
                        return true;
                    }
                }
                if let Some(dialog_idx) = self.active_modal_dialog() {
                    let text_input_submit_on_enter = self.focused_widget.and_then(|idx| match self
                        .widgets
                        .get(idx)
                    {
                        Some(WidgetKind::TextInput(text_input)) => Some(text_input.submit_on_enter),
                        _ => None,
                    });
                    if matches!(text_input_submit_on_enter, Some(false)) {
                        return true;
                    }
                    let focused_is_text_input = text_input_submit_on_enter.is_some();
                    let focused_is_dialog_shell = self.focused_widget == Some(dialog_idx);
                    if focused_is_text_input
                        || focused_is_dialog_shell
                        || self.focused_widget.is_none()
                    {
                        return self.activate_dialog_default_action(dialog_idx);
                    }
                }
                self.activate_focused_widget()
            }
            "space" => self.activate_focused_widget(),
            "escape" => {
                let closed_combos = self.close_open_combos_except(None);
                if closed_combos {
                    return true;
                }
                if let Some(dialog_idx) = self
                    .active_modal_dialog()
                    .or_else(|| self.topmost_open_dialog())
                {
                    return self.activate_dialog_cancel_action(dialog_idx);
                }
                false
            }
            _ => false,
        }
    }
    /// Insert `text` into the focused `TextInput`; return `true` if consumed.
    pub fn text_input(&mut self, text: &str) -> bool {
        if let Some(idx) = self.focused_widget {
            match &mut self.widgets[idx] {
                WidgetKind::TextInput(ti) => {
                    if ti.insert_text(text) {
                        self.pending_events.push(GuiEvent::Change(idx));
                        self.dirty = true;
                    }
                    return true;
                }
                WidgetKind::TextArea(ta) => {
                    if ta.insert_text(text) {
                        self.pending_events.push(GuiEvent::Change(idx));
                        self.dirty = true;
                    }
                    return true;
                }
                WidgetKind::ComboBox(_) => {
                    return self.combo_typeahead_input(idx, text);
                }
                _ => {}
            }
        }
        false
    }
    /// Scroll the focused `ScrollPanel` by `y` lines; return `true` if consumed.
    pub fn wheel_moved(&mut self, x: f32, y: f32) -> bool {
        self.ensure_input_layout();
        if let Some((mouse_x, mouse_y)) = self.last_mouse_pos {
            if let Some(idx) = self.open_combo_dropdown_at(mouse_x, mouse_y) {
                return self.scroll_open_combo_dropdown(idx, y);
            }
            if let Some(idx) = self.hit_test_scroll_target(mouse_x, mouse_y) {
                return self.scroll_widget(idx, x, y);
            }
        }
        if let Some(idx) = self.focused_widget {
            if matches!(
                self.widgets.get(idx),
                Some(
                    WidgetKind::ScrollPanel(_)
                        | WidgetKind::ListBox(_)
                        | WidgetKind::GUITable(_)
                        | WidgetKind::TextArea(_)
                        | WidgetKind::ScrollBar(_)
                )
            ) {
                return self.scroll_widget(idx, x, y);
            }
        }
        false
    }
}
