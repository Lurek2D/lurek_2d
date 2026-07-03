//! Owns the terminal terminal state widgets implementation for the terminal subsystem and keeps rules local here.
//! Keeps terminal buffers, widgets, and text-facing presentation state so helpers stay close to invariants this updates.
//! Defines how terminal terminal state widgets data is validated, transformed, or stored before systems consume it.
//! Separates terminal terminal state widgets behavior from Lua bindings, tests, and sibling owners so integration readable.
//! Documents the boundary where terminal code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing terminal terminal state widgets defaults, lifecycle handling, validation, or data rules.
//! Keeps failure paths and edge cases near terminal terminal state widgets state that explains them instead of outward.

use super::*;

impl Terminal {
    fn widget_parent_map(&self) -> Result<HashMap<usize, usize>, TerminalWidgetValidationError> {
        let mut parents = HashMap::new();
        for (panel_index, widget) in self.widgets.iter().enumerate() {
            if let WidgetKind::Panel { children } = &widget.kind {
                for &child_index in children {
                    if child_index >= self.widgets.len() {
                        return Err(TerminalWidgetValidationError::MissingChild {
                            panel_index,
                            child_index,
                        });
                    }
                    if let Some(first_parent) = parents.insert(child_index, panel_index) {
                        if first_parent != panel_index {
                            return Err(TerminalWidgetValidationError::DuplicateParent {
                                child_index,
                                first_parent,
                                second_parent: panel_index,
                            });
                        }
                    }
                }
            }
        }
        Ok(parents)
    }

    fn panel_path_exists(
        &self,
        start_index: usize,
        target_index: usize,
        visiting: &mut HashSet<usize>,
    ) -> bool {
        if start_index == target_index {
            return true;
        }
        if !visiting.insert(start_index) {
            return false;
        }
        let result = match self.widgets.get(start_index).map(|widget| &widget.kind) {
            Some(WidgetKind::Panel { children }) => children.iter().copied().any(|child_index| {
                child_index == target_index
                    || (child_index < self.widgets.len()
                        && self.panel_path_exists(child_index, target_index, visiting))
            }),
            _ => false,
        };
        visiting.remove(&start_index);
        result
    }

    /// Append `widget` and return its index. When the terminal is at the widget limit, the widget is rejected and the existing length is returned.
    pub fn add_widget(&mut self, widget: Widget) -> usize {
        if self.widgets.len() >= self.limits.max_widgets {
            self.diagnostics.rejected_widgets += 1;
            return self.widgets.len();
        }
        let index = self.widgets.len();
        let mut widget = widget;
        let clipped = widget.apply_limits(
            self.limits.max_widget_text_chars,
            self.limits.max_list_items,
            self.limits.max_item_chars,
        );
        self.diagnostics.clipped_text += clipped;
        self.widgets.push(widget);
        index
    }

    /// Strictly append `widget` and return its index.
    pub fn try_add_widget(&mut self, widget: Widget) -> Result<usize, TerminalError> {
        if self.widgets.len() >= self.limits.max_widgets {
            return Err(TerminalError::WidgetLimitReached {
                limit: self.limits.max_widgets,
            });
        }
        let text_limit = self.limits.max_widget_text_chars;
        let item_limit = self.limits.max_item_chars;
        let max_items = self.limits.max_list_items;
        widget.try_apply_limits(text_limit, max_items, item_limit)?;
        let index = self.widgets.len();
        self.widgets.push(widget);
        Ok(index)
    }

    /// Remove the widget at `index`; adjusts focus and panel child references; returns `false` when index is out of range.
    pub fn remove_widget(&mut self, index: usize) -> bool {
        if index >= self.widgets.len() {
            return false;
        }
        self.widgets.remove(index);
        match self.focused {
            Some(focused) if focused == index => self.focused = None,
            Some(focused) if focused > index => self.focused = Some(focused - 1),
            _ => {}
        }
        self.adjust_panel_children_after_removal(index);
        true
    }

    /// Remove all widgets and clear focus.
    pub fn clear_widgets(&mut self) {
        self.widgets.clear();
        self.focused = None;
    }

    /// Return the number of registered widgets.
    pub fn get_widget_count(&self) -> usize {
        self.widgets.len()
    }

    /// Return a shared reference to the widget at `index`, or `None`.
    pub fn get_widget(&self, index: usize) -> Option<&Widget> {
        self.widgets.get(index)
    }

    /// Return a mutable reference to the widget at `index`, or `None`.
    pub fn get_widget_mut(&mut self, index: usize) -> Option<&mut Widget> {
        self.widgets.get_mut(index)
    }

    /// Permissively set attached widget text using terminal limits; returns whether the widget's change callback should fire.
    pub fn set_widget_text(
        &mut self,
        index: usize,
        new_text: String,
    ) -> Result<bool, TerminalError> {
        let widget = self
            .widgets
            .get_mut(index)
            .ok_or(TerminalError::InvalidWidgetIndex { index })?;
        let before = widget.get_text().ok();
        let changed = widget
            .set_text(new_text)
            .map_err(|_| TerminalError::InvalidWidgetKind {
                expected: "label, button, or text box",
            })?;
        let clipped = widget.apply_limits(
            self.limits.max_widget_text_chars,
            self.limits.max_list_items,
            self.limits.max_item_chars,
        );
        self.diagnostics.clipped_text += clipped;
        Ok(changed || before != widget.get_text().ok())
    }

    /// Strictly set attached widget text using terminal limits.
    pub fn try_set_widget_text(
        &mut self,
        index: usize,
        new_text: String,
    ) -> Result<bool, TerminalError> {
        let limit = self.limits.max_widget_text_chars;
        self.widgets
            .get_mut(index)
            .ok_or(TerminalError::InvalidWidgetIndex { index })?
            .try_set_text_with_limit(new_text, limit)
    }

    /// Permissively append a list item to the widget at `index`.
    pub fn add_widget_item(&mut self, index: usize, item: String) -> Result<(), TerminalError> {
        let widget = self
            .widgets
            .get_mut(index)
            .ok_or(TerminalError::InvalidWidgetIndex { index })?;
        if let Err(err) = widget.try_add_item_with_limits(
            item.clone(),
            self.limits.max_list_items,
            self.limits.max_item_chars,
        ) {
            match err {
                TerminalError::TextTooLong { .. } | TerminalError::ListItemLimitReached { .. } => {
                    self.diagnostics.clipped_text +=
                        char_count(&item).saturating_sub(self.limits.max_item_chars);
                    widget
                        .add_item(item)
                        .map_err(|_| TerminalError::InvalidWidgetKind { expected: "list" })?;
                    widget.apply_limits(
                        self.limits.max_widget_text_chars,
                        self.limits.max_list_items,
                        self.limits.max_item_chars,
                    );
                    Ok(())
                }
                other => Err(other),
            }
        } else {
            Ok(())
        }
    }

    /// Strictly append a list item to the widget at `index`.
    pub fn try_add_widget_item(&mut self, index: usize, item: String) -> Result<(), TerminalError> {
        self.widgets
            .get_mut(index)
            .ok_or(TerminalError::InvalidWidgetIndex { index })?
            .try_add_item_with_limits(item, self.limits.max_list_items, self.limits.max_item_chars)
    }

    /// Permissively set attached widget title using terminal limits.
    pub fn set_widget_title(&mut self, index: usize, title: String) -> Result<(), TerminalError> {
        let widget = self
            .widgets
            .get_mut(index)
            .ok_or(TerminalError::InvalidWidgetIndex { index })?;
        widget
            .set_title(title)
            .map_err(|_| TerminalError::InvalidWidgetKind { expected: "border" })?;
        let clipped = widget.apply_limits(
            self.limits.max_widget_text_chars,
            self.limits.max_list_items,
            self.limits.max_item_chars,
        );
        self.diagnostics.clipped_text += clipped;
        Ok(())
    }

    /// Strictly set attached widget title using terminal limits.
    pub fn try_set_widget_title(
        &mut self,
        index: usize,
        title: String,
    ) -> Result<(), TerminalError> {
        self.widgets
            .get_mut(index)
            .ok_or(TerminalError::InvalidWidgetIndex { index })?
            .try_set_title_with_limit(title, self.limits.max_widget_text_chars)
    }

    /// Strictly attach `child_index` to the panel at `panel_index`.
    pub(crate) fn try_add_panel_child(
        &mut self,
        panel_index: usize,
        child_index: usize,
    ) -> Result<(), TerminalError> {
        if panel_index >= self.widgets.len() {
            return Err(TerminalError::InvalidPanelIndex { index: panel_index });
        }
        if child_index >= self.widgets.len() {
            return Err(TerminalError::InvalidWidgetIndex { index: child_index });
        }
        if panel_index == child_index {
            return Err(TerminalError::PanelCycle {
                panel_index,
                child_index,
            });
        }
        if !matches!(self.widgets[panel_index].kind, WidgetKind::Panel { .. }) {
            return Err(TerminalError::InvalidPanelIndex { index: panel_index });
        }
        if let Ok(parent_map) = self.widget_parent_map() {
            if let Some(existing_parent) = parent_map.get(&child_index).copied() {
                if existing_parent != panel_index {
                    return Err(TerminalError::DuplicateParent {
                        child_index,
                        existing_parent,
                    });
                }
            }
        }
        let mut visiting = HashSet::new();
        if self.panel_path_exists(child_index, panel_index, &mut visiting) {
            return Err(TerminalError::PanelCycle {
                panel_index,
                child_index,
            });
        }
        match &mut self.widgets[panel_index].kind {
            WidgetKind::Panel { children } => {
                if !children.contains(&child_index) {
                    children.push(child_index);
                }
                Ok(())
            }
            _ => Err(TerminalError::InvalidPanelIndex { index: panel_index }),
        }
    }

    /// Remove `child_index` from the Panel widget at `panel_index`; returns `true` when the child was present.
    pub(crate) fn remove_panel_child(&mut self, panel_index: usize, child_index: usize) -> bool {
        if panel_index >= self.widgets.len() {
            return false;
        }
        match &mut self.widgets[panel_index].kind {
            WidgetKind::Panel { children } => {
                let before = children.len();
                children.retain(|&index| index != child_index);
                before != children.len()
            }
            _ => false,
        }
    }

    /// Remove all children from the Panel widget at `panel_index`; returns `false` when index is wrong kind.
    pub(crate) fn clear_panel_children(&mut self, panel_index: usize) -> bool {
        if panel_index >= self.widgets.len() {
            return false;
        }
        match &mut self.widgets[panel_index].kind {
            WidgetKind::Panel { children } => {
                children.clear();
                true
            }
            _ => false,
        }
    }

    /// Patch all Panel children lists after a widget at `removed_index` was removed: drop references to it and decrement higher indices.
    pub(super) fn adjust_panel_children_after_removal(&mut self, removed_index: usize) {
        for widget in &mut self.widgets {
            if let WidgetKind::Panel { children } = &mut widget.kind {
                let mut i = 0;
                while i < children.len() {
                    if children[i] == removed_index {
                        children.remove(i);
                    } else {
                        if children[i] > removed_index {
                            children[i] -= 1;
                        }
                        i += 1;
                    }
                }
            }
        }
    }

    /// Validate the panel child graph and current focus target, returning every discovered problem.
    pub fn validate_widgets(&self) -> Vec<TerminalWidgetValidationError> {
        let mut errors = Vec::new();
        let mut parents = HashMap::new();
        for (panel_index, widget) in self.widgets.iter().enumerate() {
            if let WidgetKind::Panel { children } = &widget.kind {
                for &child_index in children {
                    if child_index >= self.widgets.len() {
                        errors.push(TerminalWidgetValidationError::MissingChild {
                            panel_index,
                            child_index,
                        });
                        continue;
                    }
                    if let Some(first_parent) = parents.insert(child_index, panel_index) {
                        if first_parent != panel_index {
                            errors.push(TerminalWidgetValidationError::DuplicateParent {
                                child_index,
                                first_parent,
                                second_parent: panel_index,
                            });
                        }
                    }
                    let mut visiting = HashSet::new();
                    if self.panel_path_exists(child_index, panel_index, &mut visiting) {
                        errors.push(TerminalWidgetValidationError::Cycle {
                            panel_index,
                            child_index,
                        });
                    }
                }
            }
        }
        if let Some(index) = self.focused {
            if !self.is_focusable_widget_index(index) {
                errors.push(TerminalWidgetValidationError::InvalidFocusTarget { index });
            }
        }
        errors
    }

    /// Return the number of registered widgets.
    pub fn widget_count(&self) -> usize {
        self.widgets.len()
    }

    /// Return the first widget whose `base.tag` matches `tag`, or `None`.
    pub fn find_by_tag(&self, tag: &str) -> Option<&Widget> {
        self.widgets.iter().find(|widget| widget.base.tag == tag)
    }
}
