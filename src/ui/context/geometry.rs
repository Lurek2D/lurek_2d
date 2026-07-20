//! Owns the UI context geometry implementation for the UI subsystem and keeps related runtime rules local here.
//! Keeps retained widget state, layout helpers, and presentation rules so helpers stay close to invariants this updates.
//! Defines how UI context geometry data is validated, transformed, or stored before neighboring systems consume it.
//! Separates UI context geometry behavior from Lua bindings, tests, and sibling owners so integration stays readable.

use super::*;

impl GuiContext {
    /// Updates viewport resolution state and marks layout data dirty.
    pub fn update_resolution(&mut self, width: f32, height: f32) {
        self.viewport_w = width;
        self.viewport_h = height;
        self.scale_factor = if self.base_resolution.1 > 0.0 {
            height / self.base_resolution.1
        } else {
            1.0
        };
        self.layout_dirty = true;
        self.dirty = true;
    }

    /// Runs layout and backfills computed rectangles before hit testing or input dispatch.
    pub(super) fn ensure_input_layout(&mut self) {
        self.run_layout_pass();
        let mut is_child = vec![false; self.widgets.len()];
        for idx in 0..self.widgets.len() {
            if !self.widget_is_live(idx) {
                continue;
            }
            for child_idx in self.traversal_children(idx) {
                if child_idx < is_child.len() {
                    is_child[child_idx] = true;
                }
            }
        }
        let root_rect = Rect::new(0.0, 0.0, 0.0, 0.0);
        for (idx, child) in is_child.iter().enumerate().skip(1) {
            if !child && self.widget_is_live(idx) {
                self.layout_widget(idx, &root_rect, true, None);
            }
        }
        for (idx, widget) in self.widgets.iter_mut().enumerate().skip(1) {
            if !self.live_slots.get(idx).copied().unwrap_or(true) {
                continue;
            }
            let base = widget.base_mut();
            if base.computed_rect.width <= 0.0 || base.computed_rect.height <= 0.0 {
                base.computed_rect = Rect::new(base.x, base.y, base.width, base.height);
                base.is_visible = base.visible;
            }
        }
    }

    /// Returns the computed widget rectangle, falling back to authored bounds when layout is absent.
    pub(super) fn widget_rect(&self, idx: usize) -> Option<Rect> {
        let base = self.widgets.get(idx)?.base();
        if base.computed_rect.width > 0.0 && base.computed_rect.height > 0.0 {
            Some(base.computed_rect)
        } else {
            Some(Rect::new(base.x, base.y, base.width, base.height))
        }
    }

    /// Returns the property-group header hit at `(x, y)` inside a property widget.
    pub(super) fn property_group_header_at(&self, idx: usize, x: f32, y: f32) -> Option<usize> {
        let WidgetKind::PropertyWidget(property_widget) = self.widgets.get(idx)? else {
            return None;
        };
        let rect = self.widget_rect(idx)?;
        if !rect.contains(x, y) {
            return None;
        }
        let header_h = property_widget
            .group_header_height
            .max(PROPERTY_HEADER_HEIGHT);
        let row_h = property_widget.row_height.max(PROPERTY_ROW_HEIGHT);
        let mut current_y = rect.y;
        for (group_idx, group) in property_widget.groups.iter().enumerate() {
            if y >= current_y && y < current_y + header_h {
                return Some(group_idx);
            }
            current_y += header_h;
            if !group.collapsed {
                current_y += group.rows.len() as f32 * row_h;
            }
        }
        None
    }
}
