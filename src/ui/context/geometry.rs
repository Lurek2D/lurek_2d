//! Maintains UI viewport geometry, resolution scaling, and input-layout preparation for retained widget trees.
//! It owns viewport dimensions and dirty-layout checks, then delegates concrete placement to GuiContext layout passes.
//! Input routing calls these helpers before hit testing so pointer coordinates observe the same rectangles as rendering.
//! Lua bindings validate public sizes; this file accepts trusted context mutations and marks layout state dirty.
//! Open this file for DPI or viewport changes, coordinate conversion, and the no-relayout fast path used by input dispatch.

use super::*;

impl GuiContext {
    /// Updates viewport resolution state and marks layout data dirty.
    pub fn update_resolution(&mut self, width: f32, height: f32) {
        if !width.is_finite()
            || !height.is_finite()
            || width <= 0.0
            || height <= 0.0
            || width > self.limits.max_image_width as f32
            || height > self.limits.max_image_height as f32
        {
            return;
        }
        self.viewport_w = width;
        self.viewport_h = height;
        self.scale_factor = if self.base_resolution.1 > 0.0 {
            height / self.base_resolution.1
        } else {
            1.0
        };
        self.layout_dirty = true;
        self.dirty = true;
        self.render_generation = self.render_generation.saturating_add(1);
    }

    /// Accept normalized safe-area insets from the window/app edge and invalidate geometry.
    pub fn set_safe_area(&mut self, top: f32, right: f32, bottom: f32, left: f32) -> bool {
        let insets = [top, right, bottom, left];
        if insets
            .iter()
            .any(|value| !value.is_finite() || *value < 0.0)
        {
            return false;
        }
        self.safe_area = insets;
        self.layout_dirty = true;
        self.dirty = true;
        self.render_generation = self.render_generation.saturating_add(1);
        true
    }

    /// Runs layout and backfills computed rectangles before hit testing or input dispatch.
    pub(super) fn ensure_input_layout(&mut self) {
        // Pointer movement over a stable tree must not relayout it. Structural
        // and viewport mutations set `layout_dirty`, making this hot path a
        // generation check after the first layout.
        if self.layout_dirty {
            self.run_layout_pass();
            self.layout_dirty = false;
        }
        if self.input_parent_cache_dirty {
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
            self.input_parent_cache = is_child;
            self.input_parent_cache_dirty = false;
        }
        let root_rect = Rect::new(0.0, 0.0, 0.0, 0.0);
        for idx in 1..self.input_parent_cache.len() {
            let child = self.input_parent_cache[idx];
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
