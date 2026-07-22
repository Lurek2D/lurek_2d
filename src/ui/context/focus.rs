//! Owns the UI context focus implementation for the UI subsystem and keeps related runtime rules local here.
//! Keeps retained widget state, layout helpers, and presentation rules so helpers stay close to invariants this updates.
//! Defines how UI context focus data is validated, transformed, or stored before neighboring systems consume it.
//! Separates UI context focus behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where UI code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing UI context focus defaults, lifecycle handling, validation, or data ownership rules.

use super::*;

impl GuiContext {
    /// Move focus to `widget_idx`, updating `WidgetState` for the previous and new focused widgets.
    pub fn set_focus(&mut self, widget_idx: Option<usize>) {
        let previous_focus = self.focused_widget;
        let widget_idx = widget_idx.filter(|idx| self.widget_in_active_input_scope(*idx));
        if let Some(prev) = self.focused_widget {
            if let Some(w) = self.widgets.get_mut(prev) {
                let base = w.base_mut();
                if base.state == WidgetState::Focused {
                    base.state = WidgetState::Normal;
                }
                match w {
                    WidgetKind::TextInput(ti) => ti.focused = false,
                    WidgetKind::TextArea(ta) => ta.focused = false,
                    _ => {}
                }
            }
        }
        let next_focus = widget_idx.and_then(|idx| {
            let base = self.widgets.get(idx)?.base();
            if base.is_visible && base.enabled && base.focusable {
                Some(idx)
            } else {
                None
            }
        });
        if let Some(idx) = next_focus {
            if let Some(w) = self.widgets.get_mut(idx) {
                w.base_mut().state = WidgetState::Focused;
                match w {
                    WidgetKind::TextInput(ti) => ti.focused = true,
                    WidgetKind::TextArea(ta) => ta.focused = true,
                    _ => {}
                }
            }
        }
        self.focused_widget = next_focus;
        if previous_focus != self.focused_widget
            && !matches!(
                self.focused_widget.and_then(|idx| self.widgets.get(idx)),
                Some(WidgetKind::ComboBox(_))
            )
        {
            self.reset_combo_typeahead();
        }
        if previous_focus != self.focused_widget {
            self.dirty = true;
        }
    }
    fn collect_focus_candidates(&self, group: Option<&str>) -> Vec<usize> {
        let mut out: Vec<usize> = self
            .widgets
            .iter()
            .enumerate()
            .skip(1)
            .filter_map(|(idx, w)| {
                let b = w.base();
                if !(b.is_visible && b.enabled && b.focusable) {
                    return None;
                }
                if matches!(w, WidgetKind::Dialog(dialog) if !dialog.open) {
                    return None;
                }
                if let Some(g) = group {
                    if !g.is_empty() && b.focus_group != g {
                        return None;
                    }
                }
                if !self.widget_in_active_input_scope(idx) {
                    return None;
                }
                Some(idx)
            })
            .collect();
        out.sort_by_key(|idx| {
            let b = self.widgets[*idx].base();
            (b.tab_index, *idx)
        });
        out
    }
    /// Advance focus to the next visible enabled widget, wrapping around.
    pub fn focus_next(&mut self) {
        let active_group = self
            .focused_widget
            .and_then(|idx| self.widgets.get(idx).map(|w| w.base().focus_group.clone()));
        let mut candidates = self.collect_focus_candidates(active_group.as_deref());
        if candidates.is_empty() && active_group.as_deref().is_some_and(|g| !g.is_empty()) {
            candidates = self.collect_focus_candidates(None);
        }
        if candidates.is_empty() {
            return;
        }
        if let Some(current) = self.focused_widget {
            if let Some(pos) = candidates.iter().position(|&idx| idx == current) {
                let next = (pos + 1) % candidates.len();
                self.set_focus(Some(candidates[next]));
                return;
            }
        }
        self.set_focus(Some(candidates[0]));
    }
    /// Move focus to the previous visible enabled widget, wrapping around.
    pub fn focus_prev(&mut self) {
        let active_group = self
            .focused_widget
            .and_then(|idx| self.widgets.get(idx).map(|w| w.base().focus_group.clone()));
        let mut candidates = self.collect_focus_candidates(active_group.as_deref());
        if candidates.is_empty() && active_group.as_deref().is_some_and(|g| !g.is_empty()) {
            candidates = self.collect_focus_candidates(None);
        }
        if candidates.is_empty() {
            return;
        }
        if let Some(current) = self.focused_widget {
            if let Some(pos) = candidates.iter().position(|&idx| idx == current) {
                let prev = if pos == 0 {
                    candidates.len() - 1
                } else {
                    pos - 1
                };
                self.set_focus(Some(candidates[prev]));
                return;
            }
        }
        self.set_focus(Some(*candidates.last().unwrap_or(&candidates[0])));
    }
    /// Move focus using an explicit neighbor edge on the currently focused widget.
    pub fn focus_neighbor(&mut self, direction: &str) -> bool {
        let Some(current) = self.focused_widget else {
            return false;
        };
        let Some(w) = self.widgets.get(current) else {
            return false;
        };
        let base = w.base();
        let target = match direction {
            "up" => base.focus_neighbor_up,
            "down" => base.focus_neighbor_down,
            "left" => base.focus_neighbor_left,
            "right" => base.focus_neighbor_right,
            _ => None,
        };
        if let Some(idx) = target {
            self.set_focus(Some(idx));
            return self.focused_widget == Some(idx);
        }
        false
    }
    /// Find the nearest focusable widget in the given direction from `current_idx`.
    /// Direction is (dx, dy) normalized: (0,-1)=up, (0,1)=down, (-1,0)=left, (1,0)=right.
    pub fn find_spatial_focus_neighbor(
        &self,
        current_idx: usize,
        direction: (f32, f32),
    ) -> Option<usize> {
        let current_rect = self.widgets.get(current_idx)?.base().computed_rect;
        let cx = current_rect.x + current_rect.width * 0.5;
        let cy = current_rect.y + current_rect.height * 0.5;

        let mut best: Option<(usize, f32)> = None;

        for (idx, widget) in self.widgets.iter().enumerate() {
            if idx == current_idx || idx == 0 {
                continue;
            }
            let base = widget.base();
            if !(base.is_visible && base.enabled && base.focusable) {
                continue;
            }
            if !self.widget_in_active_input_scope(idx) {
                continue;
            }
            let rect = base.computed_rect;
            let tx = rect.x + rect.width * 0.5;
            let ty = rect.y + rect.height * 0.5;

            let dx = tx - cx;
            let dy = ty - cy;
            let dist = (dx * dx + dy * dy).sqrt();
            if dist < 0.001 {
                continue;
            }

            // Dot product with direction to check alignment
            let dot = (dx / dist) * direction.0 + (dy / dist) * direction.1;
            if dot < 0.5 {
                continue; // outside ~60Â° cone
            }

            // Score: lower is better (closer + more aligned)
            let score = dist / dot;
            let improves_best = match best {
                None => true,
                Some((_, best_score)) => score < best_score,
            };
            if improves_best {
                best = Some((idx, score));
            }
        }

        best.map(|(idx, _)| idx)
    }

    /// Move focus in a spatial direction. Returns true if focus moved.
    pub fn focus_direction(&mut self, dx: f32, dy: f32) -> bool {
        if let Some(current) = self.focused_widget {
            // First check explicit neighbor
            let explicit = match (dx, dy) {
                (_, y) if y < -0.5 => self.widgets[current].base().focus_neighbor_up,
                (_, y) if y > 0.5 => self.widgets[current].base().focus_neighbor_down,
                (x, _) if x < -0.5 => self.widgets[current].base().focus_neighbor_left,
                (x, _) if x > 0.5 => self.widgets[current].base().focus_neighbor_right,
                _ => None,
            };
            let target = explicit.or_else(|| self.find_spatial_focus_neighbor(current, (dx, dy)));
            if let Some(t) = target {
                self.set_focus(Some(t));
                return true;
            }
        }
        false
    }
}
