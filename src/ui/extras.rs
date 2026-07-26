//! Defines retained specialized widgets outside the common control and container families used by ordinary UI screens.
//! It stores local data for trees, menus, dialogs, status bars, accordions, tooltips, color pickers, and tables.
//! Property and image widgets live here with spin boxes, switches, badges, separators, and spacers with clear defaults.
//! These are data-only variants; context input performs interaction, context owns lifetime, and render emits commands.
//! Lua bindings map validated calls onto fields but do not make this module responsible for callbacks or GameFS access.
//! Dialog, menu, and tooltip links are retained indexes internally and always receive validated opaque widget handles.
//! Separator and spacer entries carry layout and hit-test semantics rather than serving as inert visual placeholders.
//! Status-bar section content is retained through this owner while context lifecycle repairs released child references.
//! These values remain cloneable so a malformed declarative layout can roll back without changing the active UI tree.
//! Open this file for local widget defaults and invariants; use input and render owners for events and paint behavior.
//! Keep shared geometry in WidgetBase and tree structure in GuiContext instead of duplicating ownership per variant.

use crate::dataframe::frame::{ColRef, DataFrame};
use crate::ui::widget::{WidgetBase, WidgetType};
/// Timed overlay notification that disappears after `duration` seconds.
#[derive(Debug, Clone)]
pub struct Toast {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Message text displayed in the toast.
    pub message: String,
    /// Total display duration in seconds.
    pub duration: f32,
    /// Time elapsed since the toast was shown; compared against `duration` to detect expiry.
    pub elapsed: f32,
}
impl Toast {
    /// Create a toast with the given message and display duration in seconds.
    pub fn new(message: impl Into<String>, duration: f32) -> Self {
        Self {
            base: WidgetBase::new(WidgetType::Toast),
            message: message.into(),
            duration,
            elapsed: 0.0,
        }
    }
    /// Return the normalised progress in `[0.0, 1.0]`; returns 1.0 when `duration <= 0`.
    pub fn progress(&self) -> f32 {
        if self.duration <= 0.0 {
            1.0
        } else {
            (self.elapsed / self.duration).clamp(0.0, 1.0)
        }
    }
    /// Return `true` if `elapsed >= duration`.
    pub fn is_expired(&self) -> bool {
        self.elapsed >= self.duration
    }
    /// Advance elapsed time by `dt` seconds.
    pub fn update(&mut self, dt: f32) {
        self.elapsed += dt;
    }
}
/// Visual rule line used to separate widget groups; horizontal by default, vertical when toggled.
#[derive(Debug, Clone)]
pub struct Separator {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// `true` for a vertical rule, `false` for a horizontal rule.
    pub vertical: bool,
    /// Thickness of the rule line in pixels.
    pub thickness: f32,
}
impl Separator {
    /// Create a separator with the given orientation; defaults to 1px thickness.
    pub fn new(vertical: bool) -> Self {
        let mut base = WidgetBase::new(WidgetType::Separator);
        if vertical {
            base.width = 2.0;
            base.height = 30.0;
        } else {
            base.width = 100.0;
            base.height = 2.0;
        }
        Self {
            base,
            vertical,
            thickness: 1.0,
        }
    }
}
/// Blank space filler that reserves a fixed pixel area in a layout container.
#[derive(Debug, Clone)]
pub struct Spacer {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
}
impl Spacer {
    /// Create a spacer with the given pixel dimensions.
    pub fn new(width: f32, height: f32) -> Self {
        let mut base = WidgetBase::new(WidgetType::Spacer);
        base.width = width;
        base.height = height;
        Self { base }
    }
}
/// Provide a default `Spacer` with zero dimensions.
impl Default for Spacer {
    fn default() -> Self {
        Self::new(0.0, 0.0)
    }
}
/// A node in a `TreeView`; holds child indices, optional icon, and expansion state.
#[derive(Debug, Clone)]
pub struct TreeNode {
    /// Node label text.
    pub text: String,
    /// Optional icon asset path shown before the label.
    pub icon: Option<String>,
    /// Indices of immediate child nodes in the owning `TreeView::nodes` list.
    pub children: Vec<usize>,
    /// Whether this node's children are currently shown.
    pub expanded: bool,
    /// Index of the parent node, or `None` for a root node.
    pub parent: Option<usize>,
}
impl TreeNode {
    /// Create a leaf node with the given text and optional parent index; initially collapsed.
    pub fn new(text: impl Into<String>, parent: Option<usize>) -> Self {
        Self {
            text: text.into(),
            icon: None,
            children: Vec::new(),
            expanded: false,
            parent,
        }
    }
}
/// Hierarchical collapsible tree widget backed by a flat node list with index-based parent links.
#[derive(Debug, Clone)]
pub struct TreeView {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Flat list of all nodes; parent and child links use indices into this list.
    pub nodes: Vec<TreeNode>,
    /// Indices of all root-level nodes (no parent).
    pub root_nodes: Vec<usize>,
    /// Index of the currently selected node, or `None`.
    pub selected_node: Option<usize>,
}
impl TreeView {
    /// Create an empty tree view with no nodes.
    pub fn new() -> Self {
        Self {
            base: WidgetBase::new(WidgetType::TreeView),
            nodes: Vec::new(),
            root_nodes: Vec::new(),
            selected_node: None,
        }
    }
    /// Add a node under `parent_index` (or as root if `None`); return the new node index.
    pub fn add_node(&mut self, text: impl Into<String>, parent_index: Option<usize>) -> usize {
        let idx = self.nodes.len();
        let parent_index = parent_index.filter(|&pi| pi < self.nodes.len());
        let node = TreeNode::new(text, parent_index);
        self.nodes.push(node);
        if let Some(pi) = parent_index {
            self.nodes[pi].children.push(idx);
        } else {
            self.root_nodes.push(idx);
        }
        idx
    }
    /// Toggle expanded state of node `index`; return `false` if index is out of range.
    pub fn toggle_node(&mut self, index: usize) -> bool {
        if let Some(node) = self.nodes.get_mut(index) {
            node.expanded = !node.expanded;
            true
        } else {
            false
        }
    }
    /// Return the total node count. This function is part of the public API.
    pub fn node_count(&self) -> usize {
        self.nodes.len()
    }
    /// Remove node at `index`, re-linking parent/children and remapping indices; return `false` when out of range.
    pub fn remove_node(&mut self, index: usize) -> bool {
        if index >= self.nodes.len() {
            return false;
        }
        let parent = self.nodes[index].parent;
        if let Some(pi) = parent {
            if pi < self.nodes.len() {
                self.nodes[pi].children.retain(|&c| c != index);
            }
        } else {
            self.root_nodes.retain(|&r| r != index);
        }
        self.nodes.remove(index);
        let remap = |i: usize| -> usize {
            if i > index {
                i - 1
            } else {
                i
            }
        };
        for node in &mut self.nodes {
            node.children.retain(|&c| c != index);
            node.children.iter_mut().for_each(|c| *c = remap(*c));
            node.parent = node
                .parent
                .and_then(|p| if p == index { None } else { Some(remap(p)) });
        }
        self.root_nodes.retain(|&r| r != index);
        self.root_nodes.iter_mut().for_each(|r| *r = remap(*r));
        self.selected_node =
            self.selected_node
                .and_then(|s| if s == index { None } else { Some(remap(s)) });
        true
    }
    /// Remove all nodes and reset selection.
    pub fn clear_nodes(&mut self) {
        self.nodes.clear();
        self.root_nodes.clear();
        self.selected_node = None;
    }
    /// Return the text of node `index`, or `None` if out of range.
    pub fn get_node_text(&self, index: usize) -> Option<&str> {
        self.nodes.get(index).map(|n| n.text.as_str())
    }
    /// Set the text of node `index`; return `false` if out of range.
    pub fn set_node_text(&mut self, index: usize, text: impl Into<String>) -> bool {
        if let Some(node) = self.nodes.get_mut(index) {
            node.text = text.into();
            true
        } else {
            false
        }
    }
    /// Set the icon path of node `index`; empty string clears the icon; return `false` if out of range.
    pub fn set_node_icon(&mut self, index: usize, icon: impl Into<String>) -> bool {
        if let Some(node) = self.nodes.get_mut(index) {
            let s = icon.into();
            node.icon = if s.is_empty() { None } else { Some(s) };
            true
        } else {
            false
        }
    }
    /// Force expand node `index`; return `false` if out of range.
    pub fn expand_node(&mut self, index: usize) -> bool {
        if let Some(node) = self.nodes.get_mut(index) {
            node.expanded = true;
            true
        } else {
            false
        }
    }
    /// Force collapse node `index`; return `false` if out of range.
    pub fn collapse_node(&mut self, index: usize) -> bool {
        if let Some(node) = self.nodes.get_mut(index) {
            node.expanded = false;
            true
        } else {
            false
        }
    }
    /// Return the expanded state of node `index`, or `None` if out of range.
    pub fn is_node_expanded(&self, index: usize) -> Option<bool> {
        self.nodes.get(index).map(|n| n.expanded)
    }
    /// Set all nodes expanded. This function is part of the public API.
    pub fn expand_all(&mut self) {
        for node in &mut self.nodes {
            node.expanded = true;
        }
    }
    /// Set all nodes collapsed. This function is part of the public API.
    pub fn collapse_all(&mut self) {
        for node in &mut self.nodes {
            node.expanded = false;
        }
    }
    /// Select node `index`; return `false` and clear selection if out of range.
    pub fn set_selected_node(&mut self, index: usize) -> bool {
        if index < self.nodes.len() {
            self.selected_node = Some(index);
            true
        } else {
            self.selected_node = None;
            false
        }
    }
    /// Return the selected node index, or `None` when nothing is selected.
    pub fn get_selected_node(&self) -> Option<usize> {
        self.selected_node
    }
    /// Return the slice of child indices for node `index`, or `None` if out of range.
    pub fn get_child_nodes(&self, index: usize) -> Option<&[usize]> {
        self.nodes.get(index).map(|n| n.children.as_slice())
    }
    /// Return the parent index (wrapped in `Some`) for node `index`, or `None` if out of range.
    pub fn get_parent_node(&self, index: usize) -> Option<Option<usize>> {
        self.nodes.get(index).map(|n| n.parent)
    }
    /// Return the depth of node `index` in the tree (root = 0), or `None` if out of range or cycle detected.
    pub fn get_node_depth(&self, index: usize) -> Option<usize> {
        let mut depth = 0usize;
        let mut current = index;
        let mut visited = vec![false; self.nodes.len()];
        loop {
            if current >= self.nodes.len() || visited[current] {
                return None;
            }
            visited[current] = true;
            let node = self.nodes.get(current)?;
            match node.parent {
                None => return Some(depth),
                Some(p) => {
                    depth += 1;
                    current = p;
                }
            }
        }
    }
}
/// Provide a default `TreeView` via `Self::new()`.
impl Default for TreeView {
    fn default() -> Self {
        Self::new()
    }
}
/// An icon-button entry inside a `Toolbar`.
#[derive(Debug, Clone)]
pub struct ToolbarButton {
    /// Unique identifier used to address this button by name.
    pub id: String,
    /// Hover tooltip text for this button.
    pub tooltip: String,
    /// Whether this button is interactive; disabled buttons are rendered dimmed.
    pub enabled: bool,
    /// Whether this button is in a pressed/on state (for toggle buttons).
    pub toggled: bool,
}
/// One concrete entry in a toolbar's ordered visual and interaction stream.
#[derive(Debug, Clone)]
pub enum ToolbarItem {
    /// An interactive icon button.
    Button(ToolbarButton),
    /// A non-interactive visual divider between button groups.
    Separator,
    /// A non-interactive spacer. `None` consumes remaining main-axis space.
    Spacer(Option<f32>),
}
impl ToolbarButton {
    /// Create an enabled, non-toggled button with the given id and tooltip.
    pub fn new(id: impl Into<String>, tooltip: impl Into<String>) -> Self {
        Self {
            id: id.into(),
            tooltip: tooltip.into(),
            enabled: true,
            toggled: false,
        }
    }
}
/// Horizontal or vertical strip of icon buttons.
#[derive(Debug, Clone)]
pub struct Toolbar {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Orientation string: `"horizontal"` or `"vertical"`.
    pub orientation: String,
    /// Child widget indices nested inside this toolbar.
    pub children: Vec<usize>,
    /// Ordered visual items. Separators and spacers participate in layout and rendering.
    pub items: Vec<ToolbarItem>,
}
impl Toolbar {
    /// Create an empty toolbar with the given orientation.
    pub fn new(orientation: impl Into<String>) -> Self {
        Self {
            base: WidgetBase::new(WidgetType::Toolbar),
            orientation: orientation.into(),
            children: Vec::new(),
            items: Vec::new(),
        }
    }
    /// Add a button with `id` and `tooltip` if not already present; return its index.
    pub fn add_button(&mut self, id: impl Into<String>, tooltip: impl Into<String>) -> usize {
        let id = id.into();
        if let Some(pos) = self
            .items
            .iter()
            .position(|item| matches!(item, ToolbarItem::Button(button) if button.id == id))
        {
            return pos;
        }
        self.items
            .push(ToolbarItem::Button(ToolbarButton::new(id, tooltip)));
        self.items.len() - 1
    }
    /// Add a visual separator between button groups.
    pub fn add_separator(&mut self) {
        self.items.push(ToolbarItem::Separator);
    }
    /// Add a fixed spacer when supplied, or a flexible spacer when `None`.
    pub fn add_spacer(&mut self, size: Option<f32>) {
        self.items.push(ToolbarItem::Spacer(size));
    }
    /// Return the index of the button with the given `id`, or `None` if not found.
    pub fn get_button_index(&self, id: &str) -> Option<usize> {
        self.items
            .iter()
            .position(|item| matches!(item, ToolbarItem::Button(button) if button.id == id))
    }
    /// Set the enabled state of the button with `id`; return `false` if not found.
    pub fn set_button_enabled(&mut self, id: &str, enabled: bool) -> bool {
        if let Some(ToolbarItem::Button(b)) = self
            .items
            .iter_mut()
            .find(|item| matches!(item, ToolbarItem::Button(button) if button.id == id))
        {
            b.enabled = enabled;
            true
        } else {
            false
        }
    }
    /// Set the toggled state of the button with `id`; return `false` if not found.
    pub fn set_button_toggled(&mut self, id: &str, toggled: bool) -> bool {
        if let Some(ToolbarItem::Button(b)) = self
            .items
            .iter_mut()
            .find(|item| matches!(item, ToolbarItem::Button(button) if button.id == id))
        {
            b.toggled = toggled;
            true
        } else {
            false
        }
    }
    /// Return the toggled state of the button with `id`, or `None` if not found.
    pub fn is_button_toggled(&self, id: &str) -> Option<bool> {
        self.items.iter().find_map(|item| match item {
            ToolbarItem::Button(button) if button.id == id => Some(button.toggled),
            _ => None,
        })
    }
}
/// Top-level application menu bar holding ordered menu indices.
#[derive(Debug, Clone)]
pub struct MenuBar {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Indices of top-level `MenuItem` widgets in the owning context.
    pub menus: Vec<usize>,
}
impl MenuBar {
    /// Create an empty menu bar. This function is part of the public API.
    pub fn new() -> Self {
        Self {
            base: WidgetBase::new(WidgetType::MenuBar),
            menus: Vec::new(),
        }
    }
}
/// Provide a default `MenuBar` via `Self::new()`.
impl Default for MenuBar {
    fn default() -> Self {
        Self::new()
    }
}
/// A menu item entry that can be nested inside a `MenuBar` or another `MenuItem`.
#[derive(Debug, Clone)]
pub struct MenuItem {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Display text for this menu item.
    pub text: String,
    /// Optional keyboard shortcut label shown on the right side.
    pub shortcut: String,
    /// Whether this item shows a checkmark when active.
    pub checked: bool,
    /// Indices of sub-menu `MenuItem` widgets, if any.
    pub items: Vec<usize>,
}
impl MenuItem {
    /// Create a menu item with the given text; no shortcut, unchecked, no sub-items.
    pub fn new(text: impl Into<String>) -> Self {
        Self {
            base: WidgetBase::new(WidgetType::MenuItem),
            text: text.into(),
            shortcut: String::new(),
            checked: false,
            items: Vec::new(),
        }
    }
}
/// Semantic role of a dialog action button.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DialogActionRole {
    /// Generic action with no default dialog semantics.
    Custom,
    /// Primary affirmative action such as "OK", "Apply", or "Yes".
    Default,
    /// Dismissive action such as "Cancel", "Back", or "No".
    Cancel,
}
impl DialogActionRole {
    /// Return the lowercase role name used by declarative layouts and Lua bindings.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Custom => "custom",
            Self::Default => "default",
            Self::Cancel => "cancel",
        }
    }
    /// Parse a lowercase role name into a dialog action role.
    pub fn parse_str(value: &str) -> Option<Self> {
        match value {
            "custom" => Some(Self::Custom),
            "default" | "primary" | "ok" => Some(Self::Default),
            "cancel" | "secondary" => Some(Self::Cancel),
            _ => None,
        }
    }
}
/// Metadata for a dialog footer action button.
#[derive(Debug, Clone)]
pub struct DialogAction {
    /// Visible label rendered in the action row.
    pub label: String,
    /// Semantic role used for keyboard shortcuts and default affordances.
    pub role: DialogActionRole,
    /// Whether activating this action should close the dialog automatically.
    pub close_on_activate: bool,
}
impl DialogAction {
    /// Create a dialog action with an explicit role and close behavior.
    pub fn new(label: impl Into<String>, role: DialogActionRole, close_on_activate: bool) -> Self {
        Self {
            label: label.into(),
            role,
            close_on_activate,
        }
    }
}
/// Modal or non-modal popup dialog with title bar, body slot, footer slot, and action row.
#[derive(Debug, Clone)]
pub struct Dialog {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Title displayed in the dialog header.
    pub title: String,
    /// Whether the dialog blocks interaction with underlying widgets.
    pub modal: bool,
    /// Whether the dialog is currently shown.
    pub open: bool,
    /// Whether the dialog shows an explicit close affordance in the title bar.
    pub closeable: bool,
    /// Whether the dialog may be repositioned by dragging the title bar.
    pub draggable: bool,
    /// Whether the dialog may be resized from its edges and corners.
    pub resizable: bool,
    /// Optional widget index used as the dialog body content.
    pub content_idx: Option<usize>,
    /// Optional widget index used as a custom footer content root.
    pub footer_idx: Option<usize>,
    /// Declarative footer action buttons rendered by the dialog chrome.
    pub actions: Vec<DialogAction>,
    /// Optional 0-based index of the action triggered by Enter.
    pub default_action_idx: Option<usize>,
    /// Optional 0-based index of the action triggered by Escape.
    pub cancel_action_idx: Option<usize>,
    /// Whether a non-modal dialog should dismiss when clicking outside its bounds.
    pub dismiss_on_outside_click: bool,
    /// Whether opening the dialog should recenter it within the viewport.
    pub center_on_open: bool,
}
impl Dialog {
    /// Create a closed modal dialog with popup-oriented defaults.
    pub fn new(title: impl Into<String>) -> Self {
        Self {
            base: WidgetBase::new(WidgetType::Dialog),
            title: title.into(),
            modal: true,
            open: false,
            closeable: true,
            draggable: false,
            resizable: false,
            content_idx: None,
            footer_idx: None,
            actions: Vec::new(),
            default_action_idx: None,
            cancel_action_idx: None,
            dismiss_on_outside_click: false,
            center_on_open: true,
        }
    }
}
/// Fixed-height application footer bar divided into named sections.
#[derive(Debug, Clone)]
pub struct StatusBar {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Ordered sections as `(text, width)` pairs; width 0 = auto-fill remaining space.
    pub sections: Vec<(String, f32)>,
    /// Optional retained child widget assigned to each section.
    pub section_widgets: Vec<Option<usize>>,
    /// Retained children currently owned by section slots.
    pub children: Vec<usize>,
}
impl StatusBar {
    /// Create an empty status bar. This function is part of the public API.
    pub fn new() -> Self {
        Self {
            base: WidgetBase::new(WidgetType::StatusBar),
            sections: Vec::new(),
            section_widgets: Vec::new(),
            children: Vec::new(),
        }
    }
}
/// Provide a default `StatusBar` via `Self::new()`.
impl Default for StatusBar {
    fn default() -> Self {
        Self::new()
    }
}
/// One collapsible section inside an `Accordion`.
#[derive(Debug, Clone)]
pub struct AccordionSection {
    /// Header text for this section.
    pub title: String,
    /// Optional widget index shown when the section is expanded.
    pub content_idx: Option<usize>,
    /// Whether this section is currently expanded.
    pub expanded: bool,
}
/// List of collapsible `AccordionSection` panels; optionally exclusive (only one open at a time).
#[derive(Debug, Clone)]
pub struct Accordion {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Ordered list of accordion sections.
    pub sections: Vec<AccordionSection>,
    /// When `true`, expanding one section collapses all others.
    pub exclusive: bool,
}
impl Accordion {
    /// Create an empty non-exclusive accordion.
    pub fn new() -> Self {
        Self {
            base: WidgetBase::new(WidgetType::Accordion),
            sections: Vec::new(),
            exclusive: false,
        }
    }
}
/// Provide a default `Accordion` via `Self::new()`.
impl Default for Accordion {
    fn default() -> Self {
        Self::new()
    }
}
/// Hover tooltip overlay anchored to a target widget; appears after a configurable delay.
#[derive(Debug, Clone)]
pub struct TooltipPanel {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Text content shown inside the tooltip.
    pub text: String,
    /// Seconds the cursor must hover before the tooltip appears.
    pub delay: f32,
    /// Index of the widget this tooltip is anchored to, if any.
    pub target_idx: Option<usize>,
}
impl TooltipPanel {
    /// Create a tooltip with the given text and a default delay of 0.5 seconds.
    pub fn new(text: impl Into<String>) -> Self {
        Self {
            base: WidgetBase::new(WidgetType::TooltipPanel),
            text: text.into(),
            delay: 0.5,
            target_idx: None,
        }
    }
}
/// HSVA/RGB colour selector with optional alpha channel and configurable colour mode.
#[derive(Debug, Clone)]
pub struct ColorPicker {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Red channel in `[0.0, 1.0]`.
    pub r: f32,
    /// Green channel in `[0.0, 1.0]`.
    pub g: f32,
    /// Blue channel in `[0.0, 1.0]`.
    pub b: f32,
    /// Alpha channel in `[0.0, 1.0]`.
    pub a: f32,
    /// Whether the alpha slider is shown.
    pub show_alpha: bool,
    /// Active colour mode string: `"rgb"` or `"hsv"`.
    pub color_mode: String,
}
impl ColorPicker {
    /// Create a colour picker defaulting to opaque white in RGB mode with alpha shown.
    pub fn new() -> Self {
        Self {
            base: WidgetBase::new(WidgetType::ColorPicker),
            r: 1.0,
            g: 1.0,
            b: 1.0,
            a: 1.0,
            show_alpha: true,
            color_mode: "rgb".to_string(),
        }
    }
}
/// Provide a default `ColorPicker` via `Self::new()`.
impl Default for ColorPicker {
    fn default() -> Self {
        Self::new()
    }
}
/// Column definition for a `GUITable`.
#[derive(Debug, Clone)]
pub struct TableColumn {
    /// Column header text.
    pub header: String,
    /// Pixel width of this column; 0 = auto.
    pub width: f32,
}
/// Options used when populating a `GUITable` from a dataframe.
#[derive(Debug, Clone, Default)]
pub struct TableDataFrameOptions {
    /// Optional maximum number of dataframe rows to copy.
    pub max_rows: Option<usize>,
    /// Optional ordered subset of dataframe column names to display.
    pub columns: Option<Vec<String>>,
    /// Whether to insert the selected column names as the first row.
    pub include_headers: bool,
}
/// Column-row data grid with optional sorting, selectable rows, and configurable column widths.
#[derive(Debug, Clone)]
pub struct GUITable {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Ordered column definitions.
    pub columns: Vec<TableColumn>,
    /// Ordered rows; each row is a parallel `Vec<String>` aligned to `columns`.
    pub rows: Vec<Vec<String>>,
    /// Index of the currently selected row, or `None`.
    pub selected_row: Option<usize>,
    /// Whether column header clicks sort the rows.
    pub sortable: bool,
    /// Vertical scroll offset used by mouse-wheel routing.
    pub scroll_y: f32,
}
impl GUITable {
    /// Create an empty, non-sortable table with no columns or rows.
    pub fn new() -> Self {
        Self {
            base: WidgetBase::new(WidgetType::GUITable),
            columns: Vec::new(),
            rows: Vec::new(),
            selected_row: None,
            sortable: false,
            scroll_y: 0.0,
        }
    }
    /// Remove all rows and clear row selection.
    pub fn clear_rows(&mut self) {
        self.rows.clear();
        self.selected_row = None;
    }
    /// Replace all rows with the supplied string cell matrix and return the row count.
    pub fn set_rows(&mut self, rows: Vec<Vec<String>>) -> usize {
        self.rows = rows;
        self.selected_row = None;
        self.rows.len()
    }
    /// Replace columns and rows from a dataframe and return the resulting row count.
    pub fn set_dataframe(
        &mut self,
        dataframe: &DataFrame,
        options: TableDataFrameOptions,
    ) -> Result<usize, String> {
        let column_names = options
            .columns
            .unwrap_or_else(|| dataframe.columns().to_vec());
        let columns = column_names
            .iter()
            .map(|name| dataframe.get_column(ColRef::Name(name.clone())))
            .collect::<Result<Vec<_>, _>>()?;
        self.columns = column_names
            .iter()
            .map(|name| TableColumn {
                header: name.clone(),
                width: 100.0,
            })
            .collect();
        self.rows.clear();
        if options.include_headers {
            self.rows.push(column_names.clone());
        }
        let row_count = options.max_rows.map_or_else(
            || dataframe.nrows(),
            |max_rows| dataframe.nrows().min(max_rows),
        );
        for row_index in 0..row_count {
            let row = columns
                .iter()
                .map(|column| column[row_index].to_string())
                .collect();
            self.rows.push(row);
        }
        self.selected_row = None;
        Ok(self.rows.len())
    }
}
/// Provide a default `GUITable` via `Self::new()`.
impl Default for GUITable {
    fn default() -> Self {
        Self::new()
    }
}
/// Predefined editor kind for one row in a `PropertyWidget`.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum PropertyValueKind {
    /// Free-form text value.
    Text,
    /// Numeric value presented as a spinner-like value.
    Number,
    /// Boolean value presented as a checkbox.
    Bool,
    /// One value selected from a predefined option list.
    Select,
    /// Colour value displayed as text plus a swatch.
    Color,
}
impl PropertyValueKind {
    /// Parse a lowercase editor kind; accepts standalone widget names as editor aliases.
    pub fn parse_str(value: &str) -> Option<Self> {
        match value {
            "text" | "string" | "textbox" | "textinput" => Some(Self::Text),
            "number" | "float" | "int" | "integer" => Some(Self::Number),
            "bool" | "boolean" | "checkbox" => Some(Self::Bool),
            "select" | "choice" | "combo" | "combobox" => Some(Self::Select),
            "color" | "colour" | "colorpicker" | "colourpicker" => Some(Self::Color),
            _ => None,
        }
    }
    /// Return the canonical lowercase editor kind.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Text => "text",
            Self::Number => "number",
            Self::Bool => "bool",
            Self::Select => "select",
            Self::Color => "color",
        }
    }
}
/// One name/value row inside a property group.
#[derive(Debug, Clone)]
pub struct PropertyRow {
    /// Stable property name displayed in the left column and used for lookup.
    pub name: String,
    /// Stringified property value displayed in the right column.
    pub value: String,
    /// Predefined editor kind used by render and interaction code.
    pub value_kind: PropertyValueKind,
    /// Optional choices for `select` rows.
    pub options: Vec<String>,
    /// Whether the row is shown but not editable.
    pub read_only: bool,
}
impl PropertyRow {
    /// Create a property row with a normalised editor kind and stringified value.
    pub fn new(
        name: impl Into<String>,
        value: impl Into<String>,
        value_kind: PropertyValueKind,
    ) -> Self {
        Self {
            name: name.into(),
            value: value.into(),
            value_kind,
            options: Vec::new(),
            read_only: false,
        }
    }
}
/// Collapsible group of property rows inside a `PropertyWidget`.
#[derive(Debug, Clone)]
pub struct PropertyGroup {
    /// Group header label.
    pub title: String,
    /// Whether rows are currently hidden.
    pub collapsed: bool,
    /// Ordered property rows.
    pub rows: Vec<PropertyRow>,
}
impl PropertyGroup {
    /// Create an empty property group.
    pub fn new(title: impl Into<String>, collapsed: bool) -> Self {
        Self {
            title: title.into(),
            collapsed,
            rows: Vec::new(),
        }
    }
}
/// Inspector-style grouped property list with a fixed name column and value editors.
#[derive(Debug, Clone)]
pub struct PropertyWidget {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Ordered collapsible groups.
    pub groups: Vec<PropertyGroup>,
    /// Width of the left name column in pixels.
    pub label_width: f32,
    /// Height of each property row in pixels.
    pub row_height: f32,
    /// Height of each group header in pixels.
    pub group_header_height: f32,
}
impl PropertyWidget {
    /// Create an empty property inspector with practical editor defaults.
    pub fn new() -> Self {
        Self {
            base: WidgetBase::new(WidgetType::PropertyWidget),
            groups: Vec::new(),
            label_width: 180.0,
            row_height: 22.0,
            group_header_height: 24.0,
        }
    }
    /// Append a group and return its zero-based index.
    pub fn add_group(&mut self, title: impl Into<String>, collapsed: bool) -> usize {
        self.groups.push(PropertyGroup::new(title, collapsed));
        self.groups.len() - 1
    }
    /// Append a row to an existing group; returns `false` when the group index is invalid.
    pub fn add_property(&mut self, group_idx: usize, row: PropertyRow) -> bool {
        let Some(group) = self.groups.get_mut(group_idx) else {
            return false;
        };
        group.rows.push(row);
        true
    }
    /// Find the first property row by name.
    pub fn get_property(&self, name: &str) -> Option<&PropertyRow> {
        self.groups
            .iter()
            .flat_map(|group| &group.rows)
            .find(|row| row.name == name)
    }
    /// Update the first property row with `name`; returns whether a row changed.
    pub fn set_property_value(&mut self, name: &str, value: impl Into<String>) -> bool {
        let value = value.into();
        for group in &mut self.groups {
            if let Some(row) = group.rows.iter_mut().find(|row| row.name == name) {
                row.value = value;
                return true;
            }
        }
        false
    }
    /// Toggle a group collapsed/expanded state and return the new state.
    pub fn toggle_group(&mut self, group_idx: usize) -> Option<bool> {
        let group = self.groups.get_mut(group_idx)?;
        group.collapsed = !group.collapsed;
        Some(group.collapsed)
    }
}
/// Provide a default `PropertyWidget` via `Self::new()`.
impl Default for PropertyWidget {
    fn default() -> Self {
        Self::new()
    }
}
/// Static image display widget with configurable scale mode and tint.
#[derive(Debug, Clone)]
pub struct ImageWidget {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Scale mode string: `"fit"`, `"fill"`, `"stretch"`, or `"none"`.
    pub scale_mode: String,
    /// RGBA tint applied to the image in `[0.0, 1.0]` per channel.
    pub tint: (f32, f32, f32, f32),
}
impl ImageWidget {
    /// Create an image widget with `"fit"` scale mode and opaque white tint.
    pub fn new() -> Self {
        Self {
            base: WidgetBase::new(WidgetType::ImageWidget),
            scale_mode: "fit".to_string(),
            tint: (1.0, 1.0, 1.0, 1.0),
        }
    }
}
/// Provide a default `ImageWidget` via `Self::new()`.
impl Default for ImageWidget {
    fn default() -> Self {
        Self::new()
    }
}
/// Numeric count badge overlay shown on top of another widget.
#[derive(Debug, Clone)]
pub struct Badge {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
    /// Current numeric count displayed in the badge.
    pub count: u32,
    /// Upper display limit; counts above this show `"{max_display}+"`.
    pub max_display: u32,
}
impl Badge {
    /// Create a badge with the given count and default max_display of 99.
    pub fn new(count: u32) -> Self {
        Self {
            base: WidgetBase::new(WidgetType::Badge),
            count,
            max_display: 99,
        }
    }
    /// Return the display string: `count.to_string()` or `"{max_display}+"` when count exceeds max.
    pub fn display_text(&self) -> String {
        if self.count > self.max_display {
            format!("{}+", self.max_display)
        } else {
            self.count.to_string()
        }
    }
    /// Update the count value. This function is part of the public API.
    pub fn set_count(&mut self, count: u32) {
        self.count = count;
    }
}
/// Fully user-controlled widget with no built-in drawing logic; callers supply all rendering via callbacks.
#[derive(Debug, Clone)]
pub struct CustomWidget {
    /// Shared layout, style, and state fields.
    pub base: WidgetBase,
}
impl CustomWidget {
    /// Create a custom widget with default base state.
    pub fn new() -> Self {
        Self {
            base: WidgetBase::new(WidgetType::Custom),
        }
    }
}
/// Provide a default `CustomWidget` via `Self::new()`.
impl Default for CustomWidget {
    fn default() -> Self {
        Self::new()
    }
}
