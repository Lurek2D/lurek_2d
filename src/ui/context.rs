//! - Retained-mode GUI context owning a flat arena of widgets addressed by index.
//! - Discriminated `WidgetKind` union covering 35+ control/container/overlay types with shared `WidgetBase` access.
//! - Recursive layout pass computing absolute `computed_rect` from parent-relative positions.
//! - Focus management with forward/backward cycling and keyboard-driven tab navigation.
//! - Drag-and-drop API with cycle detection to prevent parent-into-child drops.
//! - Alpha and position transition animations stepped each frame with automatic expiry.
//! - Data binding system mapping string keys to numeric, text, or boolean widget values.
//! - FNV-hash render signature for fast dirty-check without full tree diffing.
//! - Mouse press/release/move and keyboard input dispatch to the focused widget.
//! - Toast overlay queue with per-message timers and automatic expiry.
//! - Event queue (`GuiEvent`) drained each frame by the Lua binding layer.

use crate::log_msg;
use crate::math::Rect;
use crate::runtime::log_messages::{GU01_CTX_INIT, GU02_WIDGET_ADD};
use crate::ui::containers::{
    DockPanel, GUIWindow, Layout, NinePatch, Panel, ScrollPanel, SplitPanel,
};
use crate::ui::controls::{
    Button, CheckBox, ComboBox, Label, ListBox, ProgressBar, RadioButton, ScrollBar, Slider,
    SpinBox, Switch, TabBar, TextInput,
};
use crate::ui::extras::{
    Accordion, Badge, ColorPicker, CustomWidget, Dialog, GUITable, ImageWidget, MenuBar, MenuItem,
    Separator, Spacer, StatusBar, Toast, Toolbar, TooltipPanel, TreeNode, TreeView,
};
use crate::ui::theme::Theme;
use crate::ui::widget::{WidgetBase, WidgetState, WidgetTransition, WidgetType};
use std::collections::HashMap;

const COMBO_MIN_ITEM_HEIGHT: f32 = 20.0;
const TABLE_HEADER_HEIGHT: f32 = 22.0;
const TABLE_ROW_HEIGHT: f32 = 20.0;
const TREE_ROW_HEIGHT: f32 = 20.0;
const ACCORDION_HEADER_HEIGHT: f32 = 24.0;
const ACCORDION_CONTENT_HEIGHT: f32 = 36.0;
const SPIN_BUTTON_ZONE_WIDTH: f32 = 24.0;
const WINDOW_TITLE_HEIGHT: f32 = 24.0;
const DIALOG_TITLE_HEIGHT: f32 = 28.0;
const DIALOG_FOOTER_HEIGHT: f32 = 34.0;
const DIALOG_FOOTER_BUTTON_WIDTH: f32 = 70.0;
const DIALOG_FOOTER_BUTTON_GAP: f32 = 6.0;
const TOOLBAR_BUTTON_GAP: f32 = 4.0;
const COLOR_PICKER_HUE_BAR_HEIGHT: f32 = 14.0;
const COLOR_PICKER_HUE_BAR_BOTTOM_PAD: f32 = 6.0;
const COLOR_PICKER_SWATCH_PAD: f32 = 6.0;
/// A typed binding value that can be pushed into widgets via `update_bindings`.
#[derive(Debug, Clone, PartialEq)]
pub enum UiBindingValue {
    /// Numeric binding applied to sliders, progress bars, spin boxes, and badges.
    Number(f64),
    /// Text binding applied to labels, buttons, text inputs, and menu items.
    Text(String),
    /// Boolean binding applied to checkboxes, switches, and visibility.
    Bool(bool),
}
/// An event emitted by a widget interaction and drained each frame by the Lua binding.
#[derive(Debug, Clone)]
pub enum GuiEvent {
    /// Primary click or activation of a button, radio button, or menu item at widget `idx`.
    Click(usize),
    /// Value change on a slider, checkbox, switch, or text input at widget `idx`.
    Change(usize),
    /// Window close request for a `GUIWindow` at widget `idx`.
    Close(usize),
    /// Item selection at `(widget_idx, item_idx)` for list boxes or tab bars.
    Select(usize, usize),
}
/// Discriminated union of all concrete widget types stored in the flat `GuiContext::widgets` list.
#[derive(Debug, Clone)]
pub enum WidgetKind {
    /// Push button control.
    Button(Button),
    /// Non-interactive text display.
    Label(Label),
    /// Single-line editable text field.
    TextInput(TextInput),
    /// Toggled checkbox with a label.
    CheckBox(CheckBox),
    /// Draggable value slider.
    Slider(Slider),
    /// Bounded progress indicator.
    ProgressBar(ProgressBar),
    /// Drop-down selection list.
    ComboBox(ComboBox),
    /// Scrollable multi-item selection list.
    ListBox(ListBox),
    /// Box container with optional title.
    Panel(Panel),
    /// Flow/grid layout container.
    Layout(Layout),
    /// Scrollable content panel.
    ScrollPanel(ScrollPanel),
    /// 9-patch scalable border.
    NinePatch(NinePatch),
    /// Horizontal tab navigation bar.
    TabBar(TabBar),
    /// Temporary pop-up message.
    Toast(Toast),
    /// Visual divider line.
    Separator(Separator),
    /// Blank space filler.
    Spacer(Spacer),
    /// Expandable tree of `TreeNode` items.
    TreeView(TreeView),
    /// Mutually exclusive group radio option.
    RadioButton(RadioButton),
    /// Explicit horizontal or vertical scroll bar.
    ScrollBar(ScrollBar),
    /// Floating draggable window.
    GUIWindow(GUIWindow),
    /// Two-pane splitter.
    SplitPanel(SplitPanel),
    /// Multi-region dock container.
    DockPanel(DockPanel),
    /// Icon button strip.
    Toolbar(Toolbar),
    /// Top-level application menu bar.
    MenuBar(MenuBar),
    /// Single entry inside a `MenuBar`.
    MenuItem(MenuItem),
    /// Modal dialog overlay.
    Dialog(Dialog),
    /// Fixed footer status bar.
    StatusBar(StatusBar),
    /// Collapsible section list.
    Accordion(Accordion),
    /// Hover tooltip overlay.
    TooltipPanel(TooltipPanel),
    /// HSVA colour selector.
    ColorPicker(ColorPicker),
    /// Column-row data grid.
    GUITable(GUITable),
    /// Static image display widget.
    ImageWidget(ImageWidget),
    /// Integer or float number field with step buttons.
    SpinBox(SpinBox),
    /// On/off toggle switch.
    Switch(Switch),
    /// Numeric count badge overlay.
    Badge(Badge),
    /// User-defined fully custom widget.
    Custom(CustomWidget),
}
macro_rules! widget_kind_base_match {
    ($value:expr, $map:ident) => {
        match $value {
            WidgetKind::Button(w) => $map!(w),
            WidgetKind::Label(w) => $map!(w),
            WidgetKind::TextInput(w) => $map!(w),
            WidgetKind::CheckBox(w) => $map!(w),
            WidgetKind::Slider(w) => $map!(w),
            WidgetKind::ProgressBar(w) => $map!(w),
            WidgetKind::ComboBox(w) => $map!(w),
            WidgetKind::ListBox(w) => $map!(w),
            WidgetKind::Panel(w) => $map!(w),
            WidgetKind::Layout(w) => $map!(w),
            WidgetKind::ScrollPanel(w) => $map!(w),
            WidgetKind::NinePatch(w) => $map!(w),
            WidgetKind::TabBar(w) => $map!(w),
            WidgetKind::Toast(w) => $map!(w),
            WidgetKind::Separator(w) => $map!(w),
            WidgetKind::Spacer(w) => $map!(w),
            WidgetKind::TreeView(w) => $map!(w),
            WidgetKind::RadioButton(w) => $map!(w),
            WidgetKind::ScrollBar(w) => $map!(w),
            WidgetKind::GUIWindow(w) => $map!(w),
            WidgetKind::SplitPanel(w) => $map!(w),
            WidgetKind::DockPanel(w) => $map!(w),
            WidgetKind::Toolbar(w) => $map!(w),
            WidgetKind::MenuBar(w) => $map!(w),
            WidgetKind::MenuItem(w) => $map!(w),
            WidgetKind::Dialog(w) => $map!(w),
            WidgetKind::StatusBar(w) => $map!(w),
            WidgetKind::Accordion(w) => $map!(w),
            WidgetKind::TooltipPanel(w) => $map!(w),
            WidgetKind::ColorPicker(w) => $map!(w),
            WidgetKind::GUITable(w) => $map!(w),
            WidgetKind::ImageWidget(w) => $map!(w),
            WidgetKind::SpinBox(w) => $map!(w),
            WidgetKind::Switch(w) => $map!(w),
            WidgetKind::Badge(w) => $map!(w),
            WidgetKind::Custom(w) => $map!(w),
        }
    };
}
macro_rules! base_ref {
    ($w:ident) => {
        &$w.base
    };
}
macro_rules! base_mut_ref {
    ($w:ident) => {
        &mut $w.base
    };
}
impl WidgetKind {
    /// Return a shared reference to the common `WidgetBase` of any variant.
    pub fn base(&self) -> &WidgetBase {
        widget_kind_base_match!(self, base_ref)
    }
    /// Return a mutable reference to the common `WidgetBase` of any variant.
    pub fn base_mut(&mut self) -> &mut WidgetBase {
        widget_kind_base_match!(self, base_mut_ref)
    }
    /// Return a shared reference to the child-index list for container variants; `None` for leaf widgets.
    pub fn children(&self) -> Option<&Vec<usize>> {
        match self {
            Self::Panel(p) => Some(&p.children),
            Self::Layout(l) => Some(&l.children),
            Self::ScrollPanel(s) => Some(&s.children),
            Self::GUIWindow(w) => Some(&w.children),
            Self::Toolbar(w) => Some(&w.children),
            _ => None,
        }
    }
    /// Return a mutable reference to the child-index list for container variants; `None` for leaf widgets.
    pub fn children_mut(&mut self) -> Option<&mut Vec<usize>> {
        match self {
            Self::Panel(p) => Some(&mut p.children),
            Self::Layout(l) => Some(&mut l.children),
            Self::ScrollPanel(s) => Some(&mut s.children),
            Self::GUIWindow(w) => Some(&mut w.children),
            Self::Toolbar(w) => Some(&mut w.children),
            _ => None,
        }
    }
}
/// Retained-mode GUI context owning all widgets, focus state, animations, drag state, and event queue.
#[derive(Debug, Clone)]
pub struct GuiContext {
    /// Flat list of all widgets; index 0 is always the invisible root `Panel`.
    pub widgets: Vec<WidgetKind>,
    /// Index of the currently focused widget, if any.
    pub focused_widget: Option<usize>,
    /// Active toast messages rendered as overlays; removed when expired.
    pub toasts: Vec<Toast>,
    /// Current visual theme applied to all widgets during rendering.
    pub theme: Option<Theme>,
    /// Events accumulated this frame, drained by Lua or caller each tick.
    pub pending_events: Vec<GuiEvent>,
    /// Set to `true` whenever any widget state changes; cleared by `flush_cache`.
    pub dirty: bool,
    /// True when layout geometry requires recomputation.
    pub layout_dirty: bool,
    /// True when style/theme-derived values changed.
    pub style_dirty: bool,
    /// True when text content/metrics changed.
    pub text_dirty: bool,
    /// True when any visual output changed and render commands should be rebuilt.
    pub render_dirty: bool,
    /// Last-known viewport width used for layout calculations.
    pub viewport_w: f32,
    /// Last-known viewport height used for layout calculations.
    pub viewport_h: f32,
    /// Widget index currently being dragged via the drag-and-drop API, if any.
    pub drag_widget: Option<usize>,
    /// Widget index currently capturing pointer movement during a mouse drag.
    pub captured_widget: Option<usize>,
    /// Last known mouse position, used by wheel routing for hover-based scroll targets.
    pub last_mouse_pos: Option<(f32, f32)>,
    /// FNV hash of the last rendered widget tree; used to detect changes without full diff.
    pub last_render_signature: u64,
}
impl GuiContext {
    /// Create a new context with a root panel, default dark theme, and dirty=true.
    pub fn new() -> Self {
        log_msg!(debug, GU01_CTX_INIT);
        let root = Panel::new();
        Self {
            widgets: vec![WidgetKind::Panel(root)],
            focused_widget: None,
            toasts: Vec::new(),
            theme: Some(crate::ui::theme::Theme::default_dark()),
            pending_events: Vec::new(),
            dirty: true,
            layout_dirty: true,
            style_dirty: true,
            text_dirty: true,
            render_dirty: true,
            viewport_w: 0.0,
            viewport_h: 0.0,
            drag_widget: None,
            captured_widget: None,
            last_mouse_pos: None,
            last_render_signature: 0,
        }
    }
    /// Reset the retained widget tree and transient UI state while preserving the active theme.
    pub fn clear(&mut self) -> usize {
        let removed = self.widgets.len().saturating_sub(1);
        let theme = self.theme.clone();
        *self = Self::new();
        self.theme = theme;
        removed
    }
    /// Mark dirty state at both legacy and fine-grained levels.
    fn mark_dirty_flags(&mut self, layout: bool, style: bool, text: bool, render: bool) {
        self.dirty = true;
        self.layout_dirty |= layout;
        self.style_dirty |= style;
        self.text_dirty |= text;
        self.render_dirty |= render;
    }
    /// Return the total number of widgets including the root panel.
    pub fn widget_count(&self) -> usize {
        self.widgets.len()
    }
    /// Drain and return all pending events accumulated since the last call.
    pub fn drain_events(&mut self) -> Vec<GuiEvent> {
        self.pending_events.drain(..).collect()
    }
    /// Recursively compute and write `computed_rect` and `is_visible` for all widgets from root.
    pub fn run_layout_pass(&mut self) {
        let root_rect = Rect::new(0.0, 0.0, self.viewport_w.max(0.0), self.viewport_h.max(0.0));
        let root_visible = if let Some(root) = self.widgets.first_mut() {
            let base = root.base_mut();
            base.computed_rect = root_rect;
            base.is_visible = base.visible;
            base.visible
        } else {
            true
        };
        let root_children: Vec<usize> = self
            .widgets
            .first()
            .and_then(|w| w.children())
            .cloned()
            .unwrap_or_default();
        for &child_idx in &root_children {
            self.layout_widget(child_idx, &root_rect, root_visible, None);
        }
    }

    fn perform_flex_layout(&self, idx: usize, parent_rect: &Rect) -> Vec<(usize, Rect)> {
        let WidgetKind::Layout(layout) = &self.widgets[idx] else {
            return Vec::new();
        };

        let mut overrides = Vec::new();
        let base = &layout.base;
        let pad = base.padding;

        let inner_w = (parent_rect.width - pad[1] - pad[3]).max(0.0);
        let inner_h = (parent_rect.height - pad[0] - pad[2]).max(0.0);

        let mut fixed_size = 0.0;
        let mut total_grow = 0.0;
        let mut child_count = 0;

        for &child_idx in &layout.children {
            if child_idx >= self.widgets.len() || !self.widgets[child_idx].base().visible {
                continue;
            }
            child_count += 1;
            let cb = self.widgets[child_idx].base();
            match layout.direction {
                crate::ui::containers::LayoutDirection::Horizontal => {
                    fixed_size += cb.width + cb.margin[1] + cb.margin[3];
                }
                crate::ui::containers::LayoutDirection::Vertical => {
                    fixed_size += cb.height + cb.margin[0] + cb.margin[2];
                }
                _ => {}
            }
            total_grow += cb.flex_grow;
        }

        if child_count > 1 {
            fixed_size += layout.spacing * (child_count as f32 - 1.0);
        }

        let free_space = match layout.direction {
            crate::ui::containers::LayoutDirection::Horizontal => (inner_w - fixed_size).max(0.0),
            crate::ui::containers::LayoutDirection::Vertical => (inner_h - fixed_size).max(0.0),
            _ => 0.0,
        };

        let mut cx = parent_rect.x + pad[3];
        let mut cy = parent_rect.y + pad[0];

        if total_grow == 0.0 && free_space > 0.0 {
            match layout.justify.as_str() {
                "center" => match layout.direction {
                    crate::ui::containers::LayoutDirection::Horizontal => cx += free_space / 2.0,
                    crate::ui::containers::LayoutDirection::Vertical => cy += free_space / 2.0,
                    _ => {}
                },
                "end" => match layout.direction {
                    crate::ui::containers::LayoutDirection::Horizontal => cx += free_space,
                    crate::ui::containers::LayoutDirection::Vertical => cy += free_space,
                    _ => {}
                },
                _ => {}
            }
        }

        let spacing = if total_grow == 0.0 && layout.justify == "space-between" && child_count > 1 {
            layout.spacing + free_space / (child_count as f32 - 1.0)
        } else {
            layout.spacing
        };

        for &child_idx in &layout.children {
            if child_idx >= self.widgets.len() {
                continue;
            }
            let cb = self.widgets[child_idx].base();
            if !cb.visible {
                continue;
            }

            let mut cw = cb.width;
            let mut ch = cb.height;

            if total_grow > 0.0 {
                let extra = free_space * (cb.flex_grow / total_grow);
                match layout.direction {
                    crate::ui::containers::LayoutDirection::Horizontal => cw += extra,
                    crate::ui::containers::LayoutDirection::Vertical => ch += extra,
                    _ => {}
                }
            }

            let mut rx = cx + cb.margin[3];
            let mut ry = cy + cb.margin[0];

            match layout.align.as_str() {
                "center" => match layout.direction {
                    crate::ui::containers::LayoutDirection::Horizontal => {
                        ry += (inner_h - ch - cb.margin[0] - cb.margin[2]).max(0.0) / 2.0
                    }
                    crate::ui::containers::LayoutDirection::Vertical => {
                        rx += (inner_w - cw - cb.margin[1] - cb.margin[3]).max(0.0) / 2.0
                    }
                    _ => {}
                },
                "end" => match layout.direction {
                    crate::ui::containers::LayoutDirection::Horizontal => {
                        ry += (inner_h - ch - cb.margin[0] - cb.margin[2]).max(0.0)
                    }
                    crate::ui::containers::LayoutDirection::Vertical => {
                        rx += (inner_w - cw - cb.margin[1] - cb.margin[3]).max(0.0)
                    }
                    _ => {}
                },
                _ => {}
            }

            overrides.push((child_idx, crate::math::Rect::new(rx, ry, cw, ch)));

            match layout.direction {
                crate::ui::containers::LayoutDirection::Horizontal => {
                    cx += cw + cb.margin[1] + cb.margin[3] + spacing
                }
                crate::ui::containers::LayoutDirection::Vertical => {
                    cy += ch + cb.margin[0] + cb.margin[2] + spacing
                }
                crate::ui::containers::LayoutDirection::Grid => {
                    let col = overrides.len() - 1;
                    let col_in_row = col % layout.columns.max(1);
                    if col_in_row == layout.columns.max(1) - 1 {
                        cx = parent_rect.x + pad[3];
                        cy += ch + cb.margin[0] + cb.margin[2] + spacing;
                    } else {
                        cx += cw + cb.margin[1] + cb.margin[3] + spacing;
                    }
                }
            }
        }
        overrides
    }

    /// Recursively lay out widget `idx` relative to `parent_rect`.
    fn layout_widget(
        &mut self,
        idx: usize,
        parent_rect: &Rect,
        parent_visible: bool,
        override_rect: Option<Rect>,
    ) {
        if idx >= self.widgets.len() {
            return;
        }

        let computed = if let Some(rect) = override_rect {
            rect
        } else {
            let (x, y, mut w, mut h) = {
                let base = self.widgets[idx].base();
                (base.x, base.y, base.width, base.height)
            };
            if w == 0.0 && parent_rect.width > 0.0 {
                w = parent_rect.width;
            }
            if h == 0.0 && parent_rect.height > 0.0 {
                h = parent_rect.height;
            }
            crate::math::Rect::new(parent_rect.x + x, parent_rect.y + y, w, h)
        };

        {
            let base = self.widgets[idx].base_mut();
            base.computed_rect = computed;
            base.is_visible = parent_visible && base.visible;
        }

        let overrides = self.perform_flex_layout(idx, &computed);
        let child_indices: Vec<usize> = self.widgets[idx].children().cloned().unwrap_or_default();
        let visible = self.widgets[idx].base().is_visible;

        for child_idx in child_indices {
            let child_override = overrides
                .iter()
                .find(|(i, _)| *i == child_idx)
                .map(|(_, r)| *r);
            self.layout_widget(child_idx, &computed, visible, child_override);
        }
    }
    /// Add a `Button` widget and return its index.
    pub fn add_button(&mut self, text: impl Into<String>) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::Button(Button::new(text)));
        idx
    }
    /// Add a `Label` widget and return its index.
    pub fn add_label(&mut self, text: impl Into<String>) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::Label(Label::new(text)));
        idx
    }
    /// Add a `TextInput` widget and return its index.
    pub fn add_text_input(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::TextInput(TextInput::new()));
        idx
    }
    /// Add a `CheckBox` widget with the given label and return its index.
    pub fn add_checkbox(&mut self, text: impl Into<String>) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::CheckBox(CheckBox::new(text)));
        idx
    }
    /// Add a `Slider` widget with the given value range and return its index.
    pub fn add_slider(&mut self, min: f64, max: f64) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::Slider(Slider::new(min, max)));
        idx
    }
    /// Add a `ProgressBar` widget with the given value range and return its index.
    pub fn add_progress_bar(&mut self, min: f64, max: f64) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::ProgressBar(ProgressBar::new(min, max)));
        idx
    }
    /// Add a `ComboBox` widget and return its index.
    pub fn add_combo_box(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::ComboBox(ComboBox::new()));
        idx
    }
    /// Add a `ListBox` widget and return its index.
    pub fn add_list_box(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::ListBox(ListBox::new()));
        idx
    }
    /// Add a `Panel` container and return its index.
    pub fn add_panel(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::Panel(Panel::new()));
        idx
    }
    /// Add a `Layout` container with the given direction and return its index.
    pub fn add_layout(&mut self, direction: super::LayoutDirection) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::Layout(Layout::new(direction)));
        idx
    }
    /// Add a `ScrollPanel` container and return its index.
    pub fn add_scroll_panel(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::ScrollPanel(ScrollPanel::new()));
        idx
    }
    /// Add a `NinePatch` widget and return its index.
    pub fn add_nine_patch(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::NinePatch(NinePatch::new()));
        idx
    }
    /// Add a `TabBar` widget and return its index.
    pub fn add_tab_bar(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::TabBar(TabBar::new()));
        idx
    }
    /// Add a `Separator` widget (horizontal or vertical) and return its index.
    pub fn add_separator(&mut self, vertical: bool) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::Separator(Separator::new(vertical)));
        idx
    }
    /// Add a `Spacer` widget with the given dimensions and return its index.
    pub fn add_spacer(&mut self, width: f32, height: f32) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::Spacer(Spacer::new(width, height)));
        idx
    }
    /// Add a `TreeView` widget and return its index.
    pub fn add_tree_view(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::TreeView(TreeView::new()));
        idx
    }
    /// Add a `RadioButton` with the given label and group name and return its index.
    pub fn add_radio_button(&mut self, text: impl Into<String>, group: impl Into<String>) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::RadioButton(RadioButton::new(text, group)));
        idx
    }
    /// Add a `ScrollBar` (horizontal or vertical) and return its index.
    pub fn add_scroll_bar(&mut self, vertical: bool) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::ScrollBar(ScrollBar::new(vertical)));
        idx
    }
    /// Add a `GUIWindow` with the given title and return its index.
    pub fn add_gui_window(&mut self, title: impl Into<String>) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::GUIWindow(GUIWindow::new(title)));
        idx
    }
    /// Add a `SplitPanel` with the given orientation and return its index.
    pub fn add_split_panel(&mut self, orientation: impl Into<String>) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::SplitPanel(SplitPanel::new(orientation)));
        idx
    }
    /// Add a `DockPanel` container and return its index.
    pub fn add_dock_panel(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::DockPanel(DockPanel::new()));
        idx
    }
    /// Add a `Toolbar` with the given orientation and return its index.
    pub fn add_toolbar(&mut self, orientation: impl Into<String>) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::Toolbar(Toolbar::new(orientation)));
        idx
    }
    /// Add a `MenuBar` and return its index.
    pub fn add_menu_bar(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::MenuBar(MenuBar::new()));
        idx
    }
    /// Add a `MenuItem` with the given label and return its index.
    pub fn add_menu_item(&mut self, text: impl Into<String>) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::MenuItem(MenuItem::new(text)));
        idx
    }
    /// Add a `Dialog` with the given title and return its index.
    pub fn add_dialog(&mut self, title: impl Into<String>) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::Dialog(Dialog::new(title)));
        idx
    }
    /// Add a `StatusBar` and return its index.
    pub fn add_status_bar(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::StatusBar(StatusBar::new()));
        idx
    }
    /// Add an `Accordion` container and return its index.
    pub fn add_accordion(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::Accordion(Accordion::new()));
        idx
    }
    /// Add a `TooltipPanel` with the given text and return its index.
    pub fn add_tooltip_panel(&mut self, text: impl Into<String>) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::TooltipPanel(TooltipPanel::new(text)));
        idx
    }
    /// Add a `ColorPicker` widget and return its index.
    pub fn add_color_picker(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::ColorPicker(ColorPicker::new()));
        idx
    }
    /// Add a `GUITable` widget and return its index.
    pub fn add_gui_table(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::GUITable(GUITable::new()));
        idx
    }
    /// Add an `ImageWidget` and return its index; also marks context dirty.
    pub fn add_image_widget(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::ImageWidget(ImageWidget::new()));
        self.dirty = true;
        idx
    }
    /// Add a `SpinBox` with the given value range and return its index; marks dirty.
    pub fn add_spin_box(&mut self, min: f64, max: f64) -> usize {
        let idx = self.widgets.len();
        self.widgets
            .push(WidgetKind::SpinBox(SpinBox::new(min, max)));
        self.dirty = true;
        idx
    }
    /// Add a `Switch` with the given initial on state and return its index; marks dirty.
    pub fn add_switch(&mut self, on: bool) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::Switch(Switch::new(on)));
        self.dirty = true;
        idx
    }
    /// Add a `Badge` with the given count and return its index; marks dirty.
    pub fn add_badge(&mut self, count: u32) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::Badge(Badge::new(count)));
        self.mark_dirty_flags(true, false, false, true);
        idx
    }
    /// Add a `CustomWidget` and return its index; marks dirty.
    pub fn add_custom_widget(&mut self) -> usize {
        let idx = self.widgets.len();
        self.widgets.push(WidgetKind::Custom(CustomWidget::new()));
        self.mark_dirty_flags(true, false, false, true);
        idx
    }
    /// Reset to the built-in dark theme and mark dirty.
    pub fn set_default_theme(&mut self) {
        self.theme = Some(crate::ui::theme::Theme::default_dark());
        self.mark_dirty_flags(false, true, false, true);
    }
    /// Set the viewport size used for root-relative layout; marks dirty.
    pub fn set_viewport(&mut self, width: f32, height: f32) {
        self.viewport_w = width;
        self.viewport_h = height;
        self.mark_dirty_flags(true, false, false, true);
    }
    /// Return `true` if the widget tree has changed since the last call; resets `dirty` and updates the render signature.
    pub fn flush_cache(&mut self) -> bool {
        let signature = self.compute_render_signature();
        let was_dirty = self.dirty
            || self.layout_dirty
            || self.style_dirty
            || self.text_dirty
            || self.render_dirty
            || signature != self.last_render_signature;
        self.dirty = false;
        self.layout_dirty = false;
        self.style_dirty = false;
        self.text_dirty = false;
        self.render_dirty = false;
        self.last_render_signature = signature;
        was_dirty
    }
    /// Start a drag operation on `widget_idx`; return `false` if the index is invalid or is the root.
    pub fn begin_drag(&mut self, widget_idx: usize) -> bool {
        if widget_idx == 0 || widget_idx >= self.widgets.len() {
            return false;
        }
        self.drag_widget = Some(widget_idx);
        true
    }
    /// Return the widget index currently being dragged, if any.
    pub fn active_drag(&self) -> Option<usize> {
        self.drag_widget
    }
    /// End the current drag operation and return the dragged widget index, if any.
    pub fn end_drag(&mut self) -> Option<usize> {
        self.drag_widget.take()
    }
    /// Drop the active dragged widget onto `target_idx`; returns `false` if target is not a container or would create a cycle.
    pub fn drop_on(&mut self, target_idx: usize) -> bool {
        let Some(drag_idx) = self.drag_widget else {
            return false;
        };
        if target_idx >= self.widgets.len() || drag_idx == target_idx {
            return false;
        }
        if self.widgets[target_idx].children().is_none() {
            return false;
        }
        if self.contains_descendant(drag_idx, target_idx) {
            return false;
        }
        self.detach_from_all_parents(drag_idx);
        if !self.add_child(target_idx, drag_idx) {
            return false;
        }
        self.drag_widget = None;
        self.dirty = true;
        true
    }
    /// Remove `child_idx` from every container that currently holds it.
    fn detach_from_all_parents(&mut self, child_idx: usize) {
        for idx in 0..self.widgets.len() {
            if let Some(children) = self.widgets[idx].children_mut() {
                children.retain(|c| *c != child_idx);
            }
        }
    }
    /// Return `true` if `needle_idx` is a descendant of `root_idx` in the widget tree.
    fn contains_descendant(&self, root_idx: usize, needle_idx: usize) -> bool {
        if root_idx >= self.widgets.len() {
            return false;
        }
        if let Some(children) = self.widgets[root_idx].children() {
            for child in children {
                if *child == needle_idx || self.contains_descendant(*child, needle_idx) {
                    return true;
                }
            }
        }
        false
    }
    /// Queue an alpha tween on `widget_idx` from its current alpha to `to_alpha` over `duration` seconds; returns `false` on invalid index.
    pub fn animate_alpha(
        &mut self,
        widget_idx: usize,
        to_alpha: f32,
        duration: f32,
        hide_on_complete: bool,
    ) -> bool {
        if widget_idx >= self.widgets.len() {
            return false;
        }
        let base = self.widgets[widget_idx].base_mut();
        base.visible = true;
        base.transitions.push(WidgetTransition::alpha(
            base.alpha,
            to_alpha.clamp(0.0, 1.0),
            duration,
            hide_on_complete,
        ));
        self.dirty = true;
        true
    }
    /// Queue a position tween on `widget_idx` from its current position to `(to_x, to_y)` over `duration` seconds.
    pub fn animate_position(
        &mut self,
        widget_idx: usize,
        to_x: f32,
        to_y: f32,
        duration: f32,
    ) -> bool {
        if widget_idx >= self.widgets.len() {
            return false;
        }
        let base = self.widgets[widget_idx].base_mut();
        base.transitions.push(WidgetTransition::position(
            base.x, base.y, to_x, to_y, duration,
        ));
        self.dirty = true;
        true
    }
    /// Clear all pending transitions on `widget_idx`; returns `false` on invalid index.
    pub fn cancel_animations(&mut self, widget_idx: usize) -> bool {
        if widget_idx >= self.widgets.len() {
            return false;
        }
        self.widgets[widget_idx].base_mut().transitions.clear();
        self.dirty = true;
        true
    }
    /// Return `true` if `widget_idx` has at least one active transition.
    pub fn is_animating(&self, widget_idx: usize) -> bool {
        self.widgets
            .get(widget_idx)
            .is_some_and(|w| !w.base().transitions.is_empty())
    }
    /// Apply `values` to bound widgets; return the number of widgets whose state changed.
    pub fn update_bindings(&mut self, values: &HashMap<String, UiBindingValue>) -> usize {
        let mut changed = 0usize;
        for w in &mut self.widgets {
            let Some(key) = w.base().bind_key.clone() else {
                continue;
            };
            let Some(value) = values.get(&key) else {
                continue;
            };
            match value {
                UiBindingValue::Number(n) => match w {
                    WidgetKind::Slider(sl) => {
                        if (sl.value - *n).abs() > f64::EPSILON {
                            sl.value = *n;
                            changed += 1;
                        }
                    }
                    WidgetKind::ProgressBar(pb) => {
                        if (pb.value - *n).abs() > f64::EPSILON {
                            pb.value = *n;
                            changed += 1;
                        }
                    }
                    WidgetKind::SpinBox(sb) => {
                        if (sb.value - *n).abs() > f64::EPSILON {
                            sb.value = *n;
                            changed += 1;
                        }
                    }
                    WidgetKind::Badge(b) => {
                        let next = if *n < 0.0 { 0 } else { *n as u32 };
                        if b.count != next {
                            b.count = next;
                            changed += 1;
                        }
                    }
                    _ => {}
                },
                UiBindingValue::Text(t) => match w {
                    WidgetKind::Label(lbl) => {
                        if lbl.text != *t {
                            lbl.text = t.clone();
                            changed += 1;
                        }
                    }
                    WidgetKind::Button(btn) => {
                        if btn.text != *t {
                            btn.text = t.clone();
                            changed += 1;
                        }
                    }
                    WidgetKind::TextInput(input) => {
                        if input.text != *t {
                            let previous = input.text.clone();
                            input.set_text(t.clone());
                            if input.text != previous {
                                changed += 1;
                            }
                        }
                    }
                    WidgetKind::MenuItem(item) => {
                        if item.text != *t {
                            item.text = t.clone();
                            changed += 1;
                        }
                    }
                    _ => {}
                },
                UiBindingValue::Bool(v) => match w {
                    WidgetKind::CheckBox(cb) => {
                        if cb.checked != *v {
                            cb.checked = *v;
                            changed += 1;
                        }
                    }
                    WidgetKind::Switch(sw) => {
                        if sw.on != *v {
                            sw.on = *v;
                            changed += 1;
                        }
                    }
                    _ => {
                        if w.base().visible != *v {
                            w.base_mut().visible = *v;
                            changed += 1;
                        }
                    }
                },
            }
        }
        if changed > 0 {
            self.dirty = true;
        }
        changed
    }
    /// Compute an FNV-style hash of the visible widget tree for change detection.
    fn compute_render_signature(&self) -> u64 {
        let mut hash = 1469598103934665603u64;
        for (idx, w) in self.widgets.iter().enumerate() {
            let b = w.base();
            hash ^= idx as u64;
            hash = hash.wrapping_mul(1099511628211);
            hash ^= (b.x.to_bits() as u64) ^ ((b.y.to_bits() as u64) << 1);
            hash = hash.wrapping_mul(1099511628211);
            hash ^= (b.width.to_bits() as u64)
                ^ ((b.height.to_bits() as u64) << 1)
                ^ ((b.alpha.to_bits() as u64) << 2);
            hash = hash.wrapping_mul(1099511628211);
            hash ^= (b.visible as u64) | ((b.enabled as u64) << 1) | ((b.state as u64) << 2);
            hash = hash.wrapping_mul(1099511628211);
            hash ^= b.id.len() as u64;
            hash = hash.wrapping_mul(1099511628211);
            if let Some(children) = w.children() {
                hash ^= children.len() as u64;
                hash = hash.wrapping_mul(1099511628211);
                for child in children {
                    hash ^= *child as u64;
                    hash = hash.wrapping_mul(1099511628211);
                }
            }
        }
        hash
    }
    /// Append `child_idx` to `parent_idx`'s child list if it is a container; return `false` on invalid indices or non-container.
    pub fn add_child(&mut self, parent_idx: usize, child_idx: usize) -> bool {
        log_msg!(debug, GU02_WIDGET_ADD);
        if parent_idx >= self.widgets.len() || child_idx >= self.widgets.len() {
            return false;
        }
        if let Some(children) = self.widgets[parent_idx].children_mut() {
            if !children.contains(&child_idx) {
                children.push(child_idx);
            }
            self.mark_dirty_flags(true, false, false, true);
            true
        } else {
            false
        }
    }
    /// Remove `child_idx` from `parent_idx`'s child list; return `false` if not found.
    pub fn remove_child(&mut self, parent_idx: usize, child_idx: usize) -> bool {
        if parent_idx >= self.widgets.len() {
            return false;
        }
        if let Some(children) = self.widgets[parent_idx].children_mut() {
            if let Some(pos) = children.iter().position(|&c| c == child_idx) {
                children.remove(pos);
                self.mark_dirty_flags(true, false, false, true);
                return true;
            }
        }
        false
    }
    /// Return the number of direct children of `widget_idx`; 0 for leaf widgets or invalid index.
    pub fn child_count(&self, widget_idx: usize) -> usize {
        self.widgets
            .get(widget_idx)
            .and_then(|w| w.children())
            .map_or(0, |c| c.len())
    }
    /// Move focus to `widget_idx`, updating `WidgetState` for the previous and new focused widgets.
    pub fn set_focus(&mut self, widget_idx: Option<usize>) {
        let previous_focus = self.focused_widget;
        if let Some(prev) = self.focused_widget {
            if let Some(w) = self.widgets.get_mut(prev) {
                let base = w.base_mut();
                if base.state == WidgetState::Focused {
                    base.state = WidgetState::Normal;
                }
                if let WidgetKind::TextInput(ti) = w {
                    ti.focused = false;
                }
            }
        }
        let next_focus = widget_idx.and_then(|idx| {
            let base = self.widgets.get(idx)?.base();
            if base.visible && base.enabled && base.focusable {
                Some(idx)
            } else {
                None
            }
        });
        if let Some(idx) = next_focus {
            if let Some(w) = self.widgets.get_mut(idx) {
                w.base_mut().state = WidgetState::Focused;
                if let WidgetKind::TextInput(ti) = w {
                    ti.focused = true;
                }
            }
        }
        self.focused_widget = next_focus;
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
                if !(b.visible && b.enabled && b.focusable) {
                    return None;
                }
                if let Some(g) = group {
                    if !g.is_empty() && b.focus_group != g {
                        return None;
                    }
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
    /// Push a toast message into the overlay queue.
    pub fn add_toast(&mut self, toast: Toast) {
        self.toasts.push(toast);
    }
    /// Return the number of active toast messages.
    pub fn toast_count(&self) -> usize {
        self.toasts.len()
    }
    /// Advance toast timers, expire old toasts, and step all active widget transitions by `dt` seconds.
    pub fn update(&mut self, dt: f32) {
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
                let t = if transition.duration <= 0.0 {
                    1.0
                } else {
                    (transition.elapsed / transition.duration).clamp(0.0, 1.0)
                };
                match transition.kind {
                    crate::ui::widget::WidgetTransitionKind::Alpha { from, to } => {
                        base.alpha = (from + (to - from) * t).clamp(0.0, 1.0);
                        base.visible = true;
                        if t >= 1.0 && transition.hide_on_complete && to <= 0.0 {
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
                }
                any_changed = true;
                if t < 1.0 {
                    kept.push(transition);
                }
            }
            base.transitions = kept;
        }
        if any_changed {
            self.dirty = true;
        }
    }
    /// Search the subtree rooted at `start_idx` for a widget whose `id` matches; return its index or `None`.
    pub fn find_by_id(&self, start_idx: usize, id: &str) -> Option<usize> {
        if start_idx >= self.widgets.len() {
            return None;
        }
        if self.widgets[start_idx].base().id == id {
            return Some(start_idx);
        }
        if let Some(children) = self.widgets[start_idx].children() {
            for &child_idx in children {
                if let Some(found) = self.find_by_id(child_idx, id) {
                    return Some(found);
                }
            }
        }
        None
    }

    fn ensure_input_layout(&mut self) {
        self.run_layout_pass();
        let mut is_child = vec![false; self.widgets.len()];
        for widget in &self.widgets {
            if let Some(children) = widget.children() {
                for &child_idx in children {
                    if child_idx < is_child.len() {
                        is_child[child_idx] = true;
                    }
                }
            }
        }
        let root_rect = Rect::new(0.0, 0.0, 0.0, 0.0);
        for (idx, child) in is_child.iter().enumerate().skip(1) {
            if !child {
                self.layout_widget(idx, &root_rect, true, None);
            }
        }
        for widget in self.widgets.iter_mut().skip(1) {
            let base = widget.base_mut();
            if base.computed_rect.width <= 0.0 || base.computed_rect.height <= 0.0 {
                base.computed_rect = Rect::new(base.x, base.y, base.width, base.height);
                base.is_visible = base.visible;
            }
        }
    }

    fn widget_rect(&self, idx: usize) -> Option<Rect> {
        let base = self.widgets.get(idx)?.base();
        if base.computed_rect.width > 0.0 && base.computed_rect.height > 0.0 {
            Some(base.computed_rect)
        } else {
            Some(Rect::new(base.x, base.y, base.width, base.height))
        }
    }

    fn widget_accepts_input(&self, idx: usize) -> bool {
        self.widgets.get(idx).is_some_and(|w| {
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

    fn choose_topmost(
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

    fn hit_test(&self, x: f32, y: f32) -> Option<usize> {
        let mut hit = None;
        for idx in 1..self.widgets.len() {
            let base = self.widgets[idx].base();
            // Hidden or disabled widgets never participate in hit-testing.
            if !base.is_visible || !base.enabled {
                continue;
            }
            // Ignore: the widget itself is not an event target (children are separate entries).
            // Pass: the widget receives hover styling but is not the authoritative event target.
            // Both are skipped here; only Stop widgets claim events.
            if base.mouse_filter != crate::ui::widget::MouseFilter::Stop {
                continue;
            }
            if !self.widget_contains_point(idx, x, y) {
                continue;
            }
            let z_order = base.z_order;
            hit = Self::choose_topmost(hit, idx, z_order);
        }
        hit.map(|(idx, _, _)| idx)
    }

    fn hit_test_scroll_target(&self, x: f32, y: f32) -> Option<usize> {
        let mut hit = None;
        for idx in 1..self.widgets.len() {
            let base = self.widgets[idx].base();
            if !base.is_visible || !base.enabled {
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

    fn open_combo_item_at(&self, x: f32, y: f32) -> Option<(usize, usize)> {
        let mut hit: Option<(usize, i32, usize, usize)> = None;
        for idx in 1..self.widgets.len() {
            let WidgetKind::ComboBox(combo) = &self.widgets[idx] else {
                continue;
            };
            if !combo.open || combo.items.is_empty() || !self.widget_accepts_input(idx) {
                continue;
            }
            let Some(rect) = self.widget_rect(idx) else {
                continue;
            };
            let item_height = rect.height.max(COMBO_MIN_ITEM_HEIGHT);
            let top = rect.y + rect.height;
            let bottom = top + item_height * combo.items.len() as f32;
            if x < rect.x || x > rect.x + rect.width || y < top || y >= bottom {
                continue;
            }
            let item_idx = ((y - top) / item_height).floor() as usize;
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
                let max_y = (content_h - list.base.height).max(0.0);
                list.scroll_y =
                    (list.scroll_y - y_delta * list.item_height.max(12.0)).clamp(0.0, max_y);
                if (list.scroll_y - old_y).abs() > f32::EPSILON {
                    self.dirty = true;
                }
                true
            }
            WidgetKind::GUITable(table) => {
                let old_y = table.scroll_y;
                let visible_h = (table.base.height - TABLE_HEADER_HEIGHT).max(0.0);
                let content_h = table.rows.len() as f32 * TABLE_ROW_HEIGHT;
                let max_y = (content_h - visible_h).max(0.0);
                table.scroll_y = (table.scroll_y - y_delta * TABLE_ROW_HEIGHT).clamp(0.0, max_y);
                if (table.scroll_y - old_y).abs() > f32::EPSILON {
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
        if changed {
            self.pending_events.push(GuiEvent::Select(idx, item_idx));
            self.pending_events.push(GuiEvent::Change(idx));
            self.dirty = true;
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
        let Some(WidgetKind::GUIWindow(window)) = self.widgets.get(idx) else {
            return false;
        };
        if !window.closeable {
            return false;
        }
        let Some(rect) = self.widget_rect(idx) else {
            return false;
        };
        y >= rect.y
            && y < rect.y + WINDOW_TITLE_HEIGHT
            && x >= rect.x + rect.width - WINDOW_TITLE_HEIGHT
            && x <= rect.x + rect.width
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
        let Some(WidgetKind::Dialog(dialog)) = self.widgets.get(idx) else {
            return false;
        };
        if !dialog.open {
            return false;
        }
        let Some(rect) = self.widget_rect(idx) else {
            return false;
        };
        y >= rect.y
            && y < rect.y + DIALOG_TITLE_HEIGHT
            && x >= rect.x + rect.width - DIALOG_TITLE_HEIGHT
            && x <= rect.x + rect.width
    }

    fn dialog_footer_button_at(&self, idx: usize, x: f32, y: f32) -> Option<usize> {
        let WidgetKind::Dialog(dialog) = &self.widgets[idx] else {
            return None;
        };
        if !dialog.open || dialog.footer_buttons.is_empty() {
            return None;
        }
        let rect = self.widget_rect(idx)?;
        let footer_y = rect.y + rect.height - DIALOG_FOOTER_HEIGHT;
        if y < footer_y + 4.0 || y > footer_y + 28.0 {
            return None;
        }
        let total_width = dialog.footer_buttons.len() as f32
            * (DIALOG_FOOTER_BUTTON_WIDTH + DIALOG_FOOTER_BUTTON_GAP);
        let mut button_x = rect.x + rect.width - total_width;
        for button_idx in 0..dialog.footer_buttons.len() {
            let button_rect = Rect::new(button_x, footer_y + 4.0, DIALOG_FOOTER_BUTTON_WIDTH, 24.0);
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
        self.pending_events.push(GuiEvent::Close(idx));
        self.dirty = true;
        true
    }

    fn activate_dialog_footer_button(&mut self, idx: usize, button_idx: usize) -> bool {
        let label = match self.widgets.get(idx) {
            Some(WidgetKind::Dialog(dialog)) => dialog.footer_buttons.get(button_idx).cloned(),
            _ => None,
        };
        let Some(label) = label else {
            return false;
        };
        self.pending_events.push(GuiEvent::Select(idx, button_idx));
        self.pending_events.push(GuiEvent::Click(idx));
        let normalized_label = label.to_ascii_lowercase();
        if matches!(normalized_label.as_str(), "ok" | "close" | "cancel") {
            self.close_dialog(idx);
        }
        true
    }

    fn close_open_dialogs(&mut self) -> bool {
        let open_dialogs: Vec<usize> = self
            .widgets
            .iter()
            .enumerate()
            .filter_map(|(widget_idx, widget)| match widget {
                WidgetKind::Dialog(dialog) if dialog.open => Some(widget_idx),
                _ => None,
            })
            .collect();
        let mut closed = false;
        for widget_idx in open_dialogs {
            closed |= self.close_dialog(widget_idx);
        }
        closed
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

    fn hsv_to_rgb_unit(hue: f32, saturation: f32, value: f32) -> (f32, f32, f32) {
        let hue = hue.rem_euclid(1.0) * 6.0;
        let sector = hue.floor() as i32;
        let sector_fraction = hue - sector as f32;
        let p_component = value * (1.0 - saturation);
        let q_component = value * (1.0 - saturation * sector_fraction);
        let t_component = value * (1.0 - saturation * (1.0 - sector_fraction));
        match sector {
            0 => (value, t_component, p_component),
            1 => (q_component, value, p_component),
            2 => (p_component, value, t_component),
            3 => (p_component, q_component, value),
            4 => (t_component, p_component, value),
            _ => (value, p_component, q_component),
        }
    }

    fn rgb_to_hsv_unit(red: f32, green: f32, blue: f32) -> (f32, f32, f32) {
        let max_component = red.max(green).max(blue);
        let min_component = red.min(green).min(blue);
        let delta = max_component - min_component;
        let hue = if delta <= f32::EPSILON {
            0.0
        } else if (max_component - red).abs() <= f32::EPSILON {
            ((green - blue) / delta / 6.0).rem_euclid(1.0)
        } else if (max_component - green).abs() <= f32::EPSILON {
            ((blue - red) / delta + 2.0) / 6.0
        } else {
            ((red - green) / delta + 4.0) / 6.0
        };
        let saturation = if max_component <= f32::EPSILON {
            0.0
        } else {
            delta / max_component
        };
        (hue, saturation, max_component)
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
                if let Some(WidgetKind::ComboBox(combo_box)) = self.widgets.get_mut(idx) {
                    combo_box.open = !combo_box.open;
                    self.dirty = true;
                    true
                } else {
                    false
                }
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
        let hit = self.hit_test(x, y);
        if let Some(idx) = hit {
            let keep_combo = matches!(self.widgets[idx], WidgetKind::ComboBox(_)).then_some(idx);
            self.close_open_combos_except(keep_combo);
            self.set_focus(Some(idx));
            self.widgets[idx].base_mut().state = WidgetState::Pressed;
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
                    self.captured_widget = Some(idx);
                    self.set_slider_value_from_x(idx, x);
                }
                WidgetType::TabBar => {
                    self.select_tab_at(idx, x, y);
                }
                WidgetType::ComboBox => {
                    if let WidgetKind::ComboBox(combo_box) = &mut self.widgets[idx] {
                        combo_box.open = !combo_box.open;
                    }
                    self.dirty = true;
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
                    self.captured_widget = Some(idx);
                    self.set_scroll_bar_position_from_point(idx, x, y);
                }
                WidgetType::GUIWindow => {
                    if self.gui_window_close_hit(idx, x, y) {
                        self.close_gui_window(idx);
                    }
                }
                WidgetType::Dialog => {
                    if self.dialog_close_hit(idx, x, y) {
                        self.close_dialog(idx);
                    } else if let Some(button_idx) = self.dialog_footer_button_at(idx, x, y) {
                        self.activate_dialog_footer_button(idx, button_idx);
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
        if let Some(idx) = self.captured_widget.take() {
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
        for i in 1..self.widgets.len() {
            let base = self.widgets[i].base();
            if base.state == WidgetState::Pressed {
                // Defensive: skip widgets that should not have reached Pressed state.
                if !base.is_visible
                    || !base.enabled
                    || base.mouse_filter != crate::ui::widget::MouseFilter::Stop
                {
                    self.widgets[i].base_mut().state = WidgetState::Normal;
                    continue;
                }
                let inside = self.widget_contains_point(i, x, y);
                if inside {
                    let is_clickable = matches!(
                        self.widgets[i],
                        WidgetKind::Button(_)
                            | WidgetKind::RadioButton(_)
                            | WidgetKind::MenuItem(_)
                    );
                    if is_clickable {
                        self.pending_events.push(GuiEvent::Click(i));
                    }
                }
                let new_state = if inside {
                    WidgetState::Hovered
                } else {
                    WidgetState::Normal
                };
                self.widgets[i].base_mut().state = new_state;
                consumed = true;
            }
        }
        consumed
    }
    /// Process a mouse move to `(x, y)`; updates `Hovered`/`Normal` states; return `true` on any state change.
    pub fn mouse_moved(&mut self, x: f32, y: f32) -> bool {
        self.last_mouse_pos = Some((x, y));
        self.ensure_input_layout();
        let mut changed = false;
        if let Some(idx) = self.captured_widget {
            match self
                .widgets
                .get(idx)
                .map(|widget| widget.base().widget_type)
            {
                Some(WidgetType::Slider) => {
                    changed |= self.set_slider_value_from_x(idx, x);
                }
                Some(WidgetType::ScrollBar) => {
                    changed |= self.set_scroll_bar_position_from_point(idx, x, y);
                }
                _ => {}
            }
        }
        for i in 1..self.widgets.len() {
            let base = self.widgets[i].base();
            if !base.visible || !base.is_visible || !base.enabled {
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
            "tab" => {
                self.focus_next();
                true
            }
            "backspace" => {
                if let Some(idx) = self.focused_widget {
                    if let WidgetKind::TextInput(ti) = &mut self.widgets[idx] {
                        if ti.backspace() {
                            self.pending_events.push(GuiEvent::Change(idx));
                            self.dirty = true;
                        }
                        return true;
                    }
                }
                false
            }
            "left" | "right" | "home" | "end" => {
                if let Some(idx) = self.focused_widget {
                    if let WidgetKind::TextInput(ti) = &mut self.widgets[idx] {
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
                }
                self.navigate_focused_widget(&normalized_key)
            }
            "up" | "down" => self.navigate_focused_widget(&normalized_key),
            "return" | "enter" | "space" => self.activate_focused_widget(),
            "escape" => {
                let closed_combos = self.close_open_combos_except(None);
                let closed_dialogs = self.close_open_dialogs();
                closed_combos || closed_dialogs
            }
            _ => false,
        }
    }
    /// Insert `text` into the focused `TextInput`; return `true` if consumed.
    pub fn text_input(&mut self, text: &str) -> bool {
        if let Some(idx) = self.focused_widget {
            if let WidgetKind::TextInput(ti) = &mut self.widgets[idx] {
                if ti.insert_text(text) {
                    self.pending_events.push(GuiEvent::Change(idx));
                    self.dirty = true;
                }
                return true;
            }
        }
        false
    }
    /// Scroll the focused `ScrollPanel` by `y` lines; return `true` if consumed.
    pub fn wheel_moved(&mut self, x: f32, y: f32) -> bool {
        self.ensure_input_layout();
        if let Some((mouse_x, mouse_y)) = self.last_mouse_pos {
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
                        | WidgetKind::ScrollBar(_)
                )
            ) {
                return self.scroll_widget(idx, x, y);
            }
        }
        false
    }
}
/// Provide a default `GuiContext` via `Self::new()`.
impl Default for GuiContext {
    fn default() -> Self {
        Self::new()
    }
}
