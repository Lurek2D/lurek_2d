//! Owns the UI context lifecycle implementation for the UI subsystem and keeps related runtime rules local here.
//! Keeps retained widget state, layout helpers, and presentation rules so helpers stay close to invariants this updates.
//! Defines how UI context lifecycle data is validated, transformed, or stored before neighboring systems consume it.
//! Separates UI context lifecycle behavior from Lua bindings, tests, and sibling owners so integration stays readable.

use super::*;

impl GuiContext {
    /// Appends a toast notification to the active UI toast queue.
    pub fn add_toast(&mut self, toast: Toast) {
        self.toasts.push(toast);
    }
    /// Return the number of active toast messages.
    pub fn toast_count(&self) -> usize {
        self.toasts.len()
    }
    /// Advance toast timers, expire old toasts, and step all active widget transitions by `dt` seconds.
    pub fn update(&mut self, dt: f32) {
        let dt = self.limits.normalized_dt(dt);
        if self.combo_typeahead_ttl > 0.0 {
            self.combo_typeahead_ttl = (self.combo_typeahead_ttl - dt).max(0.0);
            if self.combo_typeahead_ttl <= 0.0 {
                self.combo_typeahead_buffer.clear();
            }
        }
        for toast in &mut self.toasts {
            toast.update(dt);
        }
        self.toasts.retain(|t| !t.is_expired());
        let mut any_changed = false;
        for widget in &mut self.widgets {
            let base = widget.base_mut();
            if base.transitions.is_empty() {
                continue;
            }
            let mut kept = Vec::with_capacity(base.transitions.len());
            for mut transition in base.transitions.drain(..) {
                transition.elapsed = (transition.elapsed + dt).max(0.0);
                let linear_t = if transition.duration <= 0.0 {
                    1.0
                } else {
                    (transition.elapsed / transition.duration).clamp(0.0, 1.0)
                };
                let t = transition.easing.eval(linear_t);
                match transition.kind {
                    crate::ui::widget::WidgetTransitionKind::Alpha { from, to } => {
                        base.alpha = (from + (to - from) * t).clamp(0.0, 1.0);
                        base.visible = true;
                        if linear_t >= 1.0 && transition.hide_on_complete && to <= 0.0 {
                            base.visible = false;
                        }
                    }
                    crate::ui::widget::WidgetTransitionKind::Position {
                        from_x,
                        from_y,
                        to_x,
                        to_y,
                    } => {
                        base.x = from_x + (to_x - from_x) * t;
                        base.y = from_y + (to_y - from_y) * t;
                    }
                    crate::ui::widget::WidgetTransitionKind::Scale {
                        from_sx,
                        from_sy,
                        to_sx,
                        to_sy,
                    } => {
                        base.scale_x = from_sx + (to_sx - from_sx) * t;
                        base.scale_y = from_sy + (to_sy - from_sy) * t;
                    }
                    crate::ui::widget::WidgetTransitionKind::Rotation { from, to } => {
                        base.rotation = from + (to - from) * t;
                    }
                    crate::ui::widget::WidgetTransitionKind::Color { from, to } => {
                        base.color_tint = [
                            from[0] + (to[0] - from[0]) * t,
                            from[1] + (to[1] - from[1]) * t,
                            from[2] + (to[2] - from[2]) * t,
                            from[3] + (to[3] - from[3]) * t,
                        ];
                    }
                }
                any_changed = true;
                if linear_t < 1.0 {
                    kept.push(transition);
                }
            }
            base.transitions = kept;
        }
        if any_changed {
            self.dirty = true;
        }
    }
}
