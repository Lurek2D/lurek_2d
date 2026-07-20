//! Owns the UI context implementation for the UI subsystem and keeps related runtime rules local here.
//! Keeps retained widget state, layout helpers, and presentation rules so helpers stay close to invariants this updates.
//! Defines how UI context data is validated, transformed, or stored before neighboring systems consume it.
//! Separates UI context behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where UI code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing UI context defaults, lifecycle handling, validation, or data ownership rules.
//! Keeps failure paths and edge cases near the UI context state that explains them instead of spreading rules outward.
//! Preserves deterministic behavior by keeping UI context calculations explicit at their owning subsystem boundary.
//! Provides the local adaptation layer that lets callers reuse UI context rules without duplicating engine decisions.
//! Open this owner before sibling files when a regression centers on UI context state, helpers, or integration rules.
//! Works with neighboring UI owners while keeping the main UI context responsibility anchored in one file.
//! Changes to UI context names, caches, or helper boundaries should usually stay coupled inside this owner.
//! This file is the right stop for maintainers tracing UI context regressions back to their concrete owner boundary.

use crate::log_msg;
use crate::math::Rect;
use crate::runtime::log_messages::{GU01_CTX_INIT, GU02_WIDGET_ADD};
use crate::ui::containers::{
    AspectRatioContainer, DockPanel, GUIWindow, Layout, NinePatch, Panel, ScrollPanel, SplitPanel,
    StackContainer,
};
use crate::ui::controls::{
    Button, CheckBox, ComboBox, Label, ListBox, ProgressBar, RadioButton, RichLabel, ScrollBar,
    Slider, SpinBox, Switch, TabBar, TextArea, TextInput,
};
use crate::ui::diagnostics::{UiAccessibilityNode, UiDiagnostic};
use crate::ui::extras::{
    Accordion, Badge, ColorPicker, CustomWidget, Dialog, GUITable, ImageWidget, MenuBar, MenuItem,
    PropertyWidget, Separator, Spacer, StatusBar, Toast, Toolbar, TooltipPanel, TreeNode, TreeView,
};
use crate::ui::limits::UiLimits;
use crate::ui::theme::Theme;
use crate::ui::widget::{
    EasingFunction, MouseFilter, WidgetBase, WidgetState, WidgetTransition, WidgetTransitionKind,
    WidgetType,
};
use std::collections::{HashMap, HashSet};
use std::sync::atomic::{AtomicU64, Ordering};

mod builders;
mod color;
mod focus;
mod geometry;
mod input;
mod lifecycle;

const COMBO_MIN_ITEM_HEIGHT: f32 = 20.0;
const TABLE_HEADER_HEIGHT: f32 = 22.0;
const TABLE_ROW_HEIGHT: f32 = 20.0;
const TREE_ROW_HEIGHT: f32 = 20.0;
const ACCORDION_HEADER_HEIGHT: f32 = 24.0;
const ACCORDION_CONTENT_HEIGHT: f32 = 36.0;
const PROPERTY_HEADER_HEIGHT: f32 = 24.0;
const PROPERTY_ROW_HEIGHT: f32 = 22.0;
const SPIN_BUTTON_ZONE_WIDTH: f32 = 24.0;
const WINDOW_TITLE_HEIGHT: f32 = 24.0;
const DIALOG_TITLE_HEIGHT: f32 = 28.0;
const DIALOG_FOOTER_HEIGHT: f32 = 34.0;
const DIALOG_FOOTER_BUTTON_WIDTH: f32 = 70.0;
const DIALOG_FOOTER_BUTTON_GAP: f32 = 6.0;
const POPUP_RESIZE_HANDLE_SIZE: f32 = 10.0;
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

/// Opaque identity for one widget generation in one UI context.
///
/// The slot is retained for diagnostics and compatibility with the existing
/// retained widget storage, but callers must validate the complete value. A
/// slot alone is never an authoritative widget reference.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct WidgetId {
    context_id: u64,
    slot: usize,
    generation: u64,
}

impl WidgetId {
    /// Return the retained-storage slot for diagnostics only.
    pub fn slot(self) -> usize {
        self.slot
    }
    /// Return the context identity used to reject cross-context handles.
    pub fn context_id(self) -> u64 {
        self.context_id
    }
    /// Return the generation used to reject handles retained across `clear`.
    pub fn generation(self) -> u64 {
        self.generation
    }
}

static NEXT_CONTEXT_ID: AtomicU64 = AtomicU64::new(1);
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
    /// A pointer or API drag began for source widget `idx`.
    DragStart(usize),
    /// A dragged source entered a droppable target.
    DragEnter(usize, usize),
    /// A dragged source left a droppable target.
    DragLeave(usize, usize),
    /// A dragged source was dropped successfully onto a target.
    Drop(usize, usize),
    /// A drag ended; the optional target is present only after a successful drop.
    DragEnd(usize, Option<usize>),
}
impl GuiEvent {
    fn targets_any(&self, doomed: &HashSet<usize>) -> bool {
        match self {
            Self::Click(idx) | Self::Change(idx) | Self::Close(idx) | Self::DragStart(idx) => {
                doomed.contains(idx)
            }
            Self::Select(idx, _) => doomed.contains(idx),
            Self::DragEnter(source, target)
            | Self::DragLeave(source, target)
            | Self::Drop(source, target) => doomed.contains(source) || doomed.contains(target),
            Self::DragEnd(source, target) => {
                doomed.contains(source) || target.is_some_and(|idx| doomed.contains(&idx))
            }
        }
    }
}

/// Bounded event queue used at the Lua/UI boundary.
#[derive(Debug, Clone)]
pub struct UiEventQueue {
    events: Vec<GuiEvent>,
    limit: usize,
    /// Number of critical events rejected after the queue reached its ceiling.
    pub overflowed_critical: usize,
}

impl UiEventQueue {
    fn new(limit: usize) -> Self {
        Self {
            events: Vec::new(),
            limit: limit.max(1),
            overflowed_critical: 0,
        }
    }
    fn is_safe_to_coalesce(event: &GuiEvent) -> bool {
        matches!(
            event,
            GuiEvent::Change(_) | GuiEvent::DragEnter(_, _) | GuiEvent::DragLeave(_, _)
        )
    }
    fn push(&mut self, event: GuiEvent) {
        if self.events.len() < self.limit {
            self.events.push(event);
            return;
        }
        if Self::is_safe_to_coalesce(&event) {
            let duplicate = match event {
                GuiEvent::Change(idx) => self
                    .events
                    .iter()
                    .any(|queued| matches!(queued, GuiEvent::Change(existing) if *existing == idx)),
                GuiEvent::DragEnter(source, target) => self.events.iter().any(|queued| {
                    matches!(queued, GuiEvent::DragEnter(existing_source, existing_target) if *existing_source == source && *existing_target == target)
                }),
                GuiEvent::DragLeave(source, target) => self.events.iter().any(|queued| {
                    matches!(queued, GuiEvent::DragLeave(existing_source, existing_target) if *existing_source == source && *existing_target == target)
                }),
                _ => false,
            };
            if duplicate {
                return;
            }
        }
        // Critical events are accounted for explicitly instead of silently
        // evicting an already queued click/change/close event.
        self.overflowed_critical = self.overflowed_critical.saturating_add(1);
    }
    fn retain<F>(&mut self, f: F)
    where
        F: FnMut(&GuiEvent) -> bool,
    {
        self.events.retain(f);
    }
    fn drain<R>(&mut self, range: R) -> std::vec::Drain<'_, GuiEvent>
    where
        R: std::ops::RangeBounds<usize>,
    {
        self.events.drain(range)
    }
    pub(crate) fn is_empty(&self) -> bool {
        self.events.is_empty()
    }
    pub(crate) fn remove(&mut self, index: usize) -> GuiEvent {
        self.events.remove(index)
    }
    pub(crate) fn insert(&mut self, index: usize, event: GuiEvent) {
        if self.events.len() < self.limit {
            self.events.insert(index.min(self.events.len()), event);
        } else {
            self.overflowed_critical = self.overflowed_critical.saturating_add(1);
        }
    }
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
    /// Multi-line editable text field.
    TextArea(TextArea),
    /// Read-only lightweight formatted text label.
    RichLabel(RichLabel),
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
    /// Aspect-ratio constrained child container.
    AspectRatioContainer(AspectRatioContainer),
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
    /// Layered page container.
    StackContainer(StackContainer),
    /// Layered page container with tab labels.
    TabContainer(StackContainer),
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
    /// Inspector-style grouped property list.
    PropertyWidget(PropertyWidget),
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
            WidgetKind::TextArea(w) => $map!(w),
            WidgetKind::RichLabel(w) => $map!(w),
            WidgetKind::CheckBox(w) => $map!(w),
            WidgetKind::Slider(w) => $map!(w),
            WidgetKind::ProgressBar(w) => $map!(w),
            WidgetKind::ComboBox(w) => $map!(w),
            WidgetKind::ListBox(w) => $map!(w),
            WidgetKind::Panel(w) => $map!(w),
            WidgetKind::Layout(w) => $map!(w),
            WidgetKind::AspectRatioContainer(w) => $map!(w),
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
            WidgetKind::StackContainer(w) => $map!(w),
            WidgetKind::TabContainer(w) => $map!(w),
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
            WidgetKind::PropertyWidget(w) => $map!(w),
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
            Self::AspectRatioContainer(a) => Some(&a.children),
            Self::ScrollPanel(s) => Some(&s.children),
            Self::StackContainer(s) | Self::TabContainer(s) => Some(&s.children),
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
            Self::AspectRatioContainer(a) => Some(&mut a.children),
            Self::ScrollPanel(s) => Some(&mut s.children),
            Self::StackContainer(s) | Self::TabContainer(s) => Some(&mut s.children),
            Self::GUIWindow(w) => Some(&mut w.children),
            Self::Toolbar(w) => Some(&mut w.children),
            _ => None,
        }
    }
}
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum PopupSurface {
    Window,
    Dialog,
}
#[derive(Debug, Clone, Copy)]
struct PopupResizeEdges {
    left: bool,
    right: bool,
    top: bool,
    bottom: bool,
}
impl PopupResizeEdges {
    fn any(self) -> bool {
        self.left || self.right || self.top || self.bottom
    }
}
#[derive(Debug, Clone, Copy)]
struct PopupResizeCapture {
    idx: usize,
    surface: PopupSurface,
    edges: PopupResizeEdges,
    start_mouse_x: f32,
    start_mouse_y: f32,
    start_rect: Rect,
}
#[derive(Debug, Clone, Copy)]
struct DragSession {
    source_idx: usize,
    start_x: f32,
    start_y: f32,
    started: bool,
    hover_target: Option<usize>,
}
#[derive(Debug, Clone, Copy)]
enum PointerCapture {
    Slider(usize),
    ScrollBar(usize),
    DragDrop(usize),
    PopupMove {
        idx: usize,
        surface: PopupSurface,
        offset_x: f32,
        offset_y: f32,
    },
    PopupResize(PopupResizeCapture),
}
impl PointerCapture {
    fn targets_any(self, doomed: &HashSet<usize>) -> bool {
        match self {
            Self::Slider(idx)
            | Self::ScrollBar(idx)
            | Self::DragDrop(idx)
            | Self::PopupMove { idx, .. }
            | Self::PopupResize(PopupResizeCapture { idx, .. }) => doomed.contains(&idx),
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
    pub pending_events: UiEventQueue,
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
    /// Active drag-and-drop session, including pointer origin and current drop target.
    drag_session: Option<DragSession>,
    /// Current pointer capture state for sliders, scroll bars, or popup drag/resize interactions.
    captured_pointer: Option<PointerCapture>,
    /// Last known mouse position, used by wheel routing for hover-based scroll targets.
    pub last_mouse_pos: Option<(f32, f32)>,
    /// FNV hash of the last rendered widget tree; used to detect changes without full diff.
    pub last_render_signature: u64,
    /// Logical base resolution the UI was designed for (default 1920x1080).
    pub base_resolution: (f32, f32),
    /// Computed scale factor = current_height / base_height.
    pub scale_factor: f32,
    /// Trusted engine-owned resource ceilings for this context.
    limits: UiLimits,
    /// Stable identity of this context; never expose it as a Lua-authoritative value.
    context_id: u64,
    /// Generation incremented whenever the retained tree is cleared.
    identity_generation: u64,
    /// Explicit root identity; root is not defined by a magic slot in the handle API.
    root_id: WidgetId,
    /// Live-state bitmap for retained slots. Dead slots are never reused, so stale closures cannot alias a replacement.
    live_slots: Vec<bool>,
    /// Rolling typeahead query buffer used by focused combo boxes.
    combo_typeahead_buffer: String,
    /// Seconds remaining before the combo-box typeahead buffer expires.
    combo_typeahead_ttl: f32,
}
impl GuiContext {
    /// Create a new context with a root panel, default dark theme, and dirty=true.
    pub fn new() -> Self {
        log_msg!(debug, GU01_CTX_INIT);
        let root = Panel::new();
        let context_id = NEXT_CONTEXT_ID.fetch_add(1, Ordering::Relaxed);
        let root_id = WidgetId {
            context_id,
            slot: 0,
            generation: 1,
        };
        Self {
            widgets: vec![WidgetKind::Panel(root)],
            focused_widget: None,
            toasts: Vec::new(),
            theme: Some(crate::ui::theme::Theme::default_dark()),
            pending_events: UiEventQueue::new(UiLimits::default().max_pending_events),
            dirty: true,
            layout_dirty: true,
            style_dirty: true,
            text_dirty: true,
            render_dirty: true,
            viewport_w: 0.0,
            viewport_h: 0.0,
            drag_session: None,
            captured_pointer: None,
            last_mouse_pos: None,
            last_render_signature: 0,
            base_resolution: (1920.0, 1080.0),
            scale_factor: 1.0,
            limits: UiLimits::default(),
            context_id,
            identity_generation: 1,
            root_id,
            live_slots: vec![true],
            combo_typeahead_buffer: String::new(),
            combo_typeahead_ttl: 0.0,
        }
    }
    /// Reset the retained widget tree and transient UI state while preserving the active theme.
    pub fn clear(&mut self) -> usize {
        let removed = self.widget_count().saturating_sub(1);
        let theme = self.theme.clone();
        let limits = self.limits;
        let slot_count = self.widgets.len().max(1);
        let context_id = self.context_id;
        let next_generation = self.identity_generation.saturating_add(1).max(1);
        let mut fresh = Self::new();
        fresh.context_id = context_id;
        fresh.identity_generation = next_generation;
        fresh.root_id = WidgetId {
            context_id,
            slot: 0,
            generation: next_generation,
        };
        fresh.widgets.reserve(slot_count.saturating_sub(1));
        fresh.live_slots = vec![true];
        for _ in 1..slot_count {
            fresh.widgets.push(Self::dead_widget());
            fresh.live_slots.push(false);
        }
        fresh.theme = theme;
        fresh.limits = limits;
        fresh.pending_events = UiEventQueue::new(limits.max_pending_events);
        *self = fresh;
        removed
    }
    fn dead_widget() -> WidgetKind {
        let mut panel = Panel::new();
        panel.base.visible = false;
        panel.base.is_visible = false;
        panel.base.enabled = false;
        WidgetKind::Panel(panel)
    }
    /// Return whether a retained slot is live. Missing bitmap entries represent
    /// newly appended legacy slots and are treated as live until registered.
    pub fn widget_is_live(&self, idx: usize) -> bool {
        idx < self.widgets.len() && self.live_slots.get(idx).copied().unwrap_or(true)
    }
    /// Return the opaque identity for a live widget slot.
    pub fn widget_id(&self, idx: usize) -> Option<WidgetId> {
        self.widget_is_live(idx).then_some(WidgetId {
            context_id: self.context_id,
            slot: idx,
            generation: self.identity_generation,
        })
    }
    /// Resolve a complete widget identity or return a stable lifecycle error.
    pub fn resolve_widget_id(&self, id: WidgetId) -> Result<usize, String> {
        if id.context_id != self.context_id {
            return Err("lurek.ui: widget handle belongs to another UI context".to_string());
        }
        if id.generation != self.identity_generation {
            return Err("lurek.ui: widget handle is stale after UI reset".to_string());
        }
        if !self.widget_is_live(id.slot) {
            return Err("lurek.ui: widget handle is destroyed or invalid".to_string());
        }
        Ok(id.slot)
    }
    /// Return the explicit root identity.
    pub fn root_id(&self) -> WidgetId {
        self.root_id
    }
    /// Return the active trusted UI resource policy.
    pub fn limits(&self) -> UiLimits {
        self.limits
    }
    /// Replace the UI resource policy from trusted engine setup code.
    pub fn set_limits(&mut self, limits: UiLimits) {
        self.limits = limits;
    }
    /// Mark a retained widget dead and clean all state that can point at it.
    pub fn destroy_widget(&mut self, idx: usize, recursive: bool) -> Result<usize, String> {
        if idx == 0 {
            return Err("lurek.ui.destroy: the root widget cannot be destroyed".to_string());
        }
        if !self.widget_is_live(idx) {
            return Err("lurek.ui.destroy: widget handle is destroyed or invalid".to_string());
        }
        let children = self.traversal_children(idx);
        if !recursive && !children.is_empty() {
            return Err(
                "lurek.ui.destroy: non-recursive destruction requires a leaf widget".to_string(),
            );
        }

        let mut doomed = HashSet::new();
        let mut stack = vec![idx];
        while let Some(current) = stack.pop() {
            if !self.widget_is_live(current) || !doomed.insert(current) {
                continue;
            }
            if recursive {
                stack.extend(self.traversal_children(current));
            }
        }

        for widget in &mut self.widgets {
            let base = widget.base_mut();
            if base
                .focus_neighbor_up
                .is_some_and(|target| doomed.contains(&target))
            {
                base.focus_neighbor_up = None;
            }
            if base
                .focus_neighbor_down
                .is_some_and(|target| doomed.contains(&target))
            {
                base.focus_neighbor_down = None;
            }
            if base
                .focus_neighbor_left
                .is_some_and(|target| doomed.contains(&target))
            {
                base.focus_neighbor_left = None;
            }
            if base
                .focus_neighbor_right
                .is_some_and(|target| doomed.contains(&target))
            {
                base.focus_neighbor_right = None;
            }
            if base
                .label_for
                .is_some_and(|target| doomed.contains(&target))
            {
                base.label_for = None;
            }
            if let Some(children) = widget.children_mut() {
                children.retain(|child| !doomed.contains(child));
            }
            match widget {
                WidgetKind::Dialog(dialog) => {
                    if dialog
                        .content_idx
                        .is_some_and(|target| doomed.contains(&target))
                    {
                        dialog.content_idx = None;
                    }
                    if dialog
                        .footer_idx
                        .is_some_and(|target| doomed.contains(&target))
                    {
                        dialog.footer_idx = None;
                    }
                }
                WidgetKind::SplitPanel(split) => {
                    if split
                        .first_child
                        .is_some_and(|target| doomed.contains(&target))
                    {
                        split.first_child = None;
                    }
                    if split
                        .second_child
                        .is_some_and(|target| doomed.contains(&target))
                    {
                        split.second_child = None;
                    }
                }
                WidgetKind::DockPanel(dock) => {
                    dock.docked.retain(|(child, _)| !doomed.contains(child))
                }
                WidgetKind::MenuBar(menu) => menu.menus.retain(|child| !doomed.contains(child)),
                WidgetKind::MenuItem(item) => item.items.retain(|child| !doomed.contains(child)),
                WidgetKind::Accordion(accordion) => accordion.sections.retain(|section| {
                    !section
                        .content_idx
                        .is_some_and(|target| doomed.contains(&target))
                }),
                WidgetKind::TooltipPanel(tooltip) => {
                    if tooltip
                        .target_idx
                        .is_some_and(|target| doomed.contains(&target))
                    {
                        tooltip.target_idx = None;
                    }
                }
                _ => {}
            }
        }
        self.pending_events
            .retain(|event| !event.targets_any(&doomed));
        if self
            .focused_widget
            .is_some_and(|target| doomed.contains(&target))
        {
            self.focused_widget = None;
        }
        if self
            .drag_session
            .is_some_and(|session| doomed.contains(&session.source_idx))
        {
            self.drag_session = None;
        }
        if self
            .captured_pointer
            .is_some_and(|capture| capture.targets_any(&doomed))
        {
            self.captured_pointer = None;
        }
        for dead in doomed.iter().copied() {
            if dead < self.widgets.len() {
                self.widgets[dead] = Self::dead_widget();
            }
            if dead >= self.live_slots.len() {
                self.live_slots.resize(dead + 1, true);
            }
            self.live_slots[dead] = false;
        }
        self.mark_dirty_flags(true, true, true, true);
        Ok(doomed.len())
    }
    /// Mark dirty state at both legacy and fine-grained levels.
    fn mark_dirty_flags(&mut self, layout: bool, style: bool, text: bool, render: bool) {
        self.dirty = true;
        self.layout_dirty |= layout;
        self.style_dirty |= style;
        self.text_dirty |= text;
        self.render_dirty |= render;
    }
    /// Mark cached layout, style, text, or render state as stale after external widget mutation.
    pub fn mark_widget_dirty(&mut self, layout: bool, style: bool, text: bool, render: bool) {
        self.mark_dirty_flags(layout, style, text, render);
    }
    /// Return the total number of widgets including the root panel.
    pub fn widget_count(&self) -> usize {
        self.widgets
            .iter()
            .enumerate()
            .filter(|(idx, _)| self.widget_is_live(*idx))
            .count()
    }
    /// Drain and return all pending events accumulated since the last call.
    pub fn drain_events(&mut self) -> Vec<GuiEvent> {
        self.pending_events.drain(..).collect()
    }
    fn dialog_has_footer_chrome(dialog: &Dialog) -> bool {
        dialog.footer_idx.is_some() || !dialog.actions.is_empty()
    }
    fn reset_combo_typeahead(&mut self) {
        self.combo_typeahead_buffer.clear();
        self.combo_typeahead_ttl = 0.0;
    }
    fn dialog_body_rect(rect: Rect, dialog: &Dialog) -> Rect {
        let pad = 8.0;
        let footer_h = if Self::dialog_has_footer_chrome(dialog) {
            DIALOG_FOOTER_HEIGHT
        } else {
            0.0
        };
        let body_y = rect.y + DIALOG_TITLE_HEIGHT + pad;
        let body_h = (rect.height - DIALOG_TITLE_HEIGHT - footer_h - pad * 2.0).max(0.0);
        Rect::new(
            rect.x + pad,
            body_y,
            (rect.width - pad * 2.0).max(0.0),
            body_h,
        )
    }
    fn dialog_footer_rect(rect: Rect) -> Rect {
        let pad = 8.0;
        Rect::new(
            rect.x + pad,
            rect.y + rect.height - DIALOG_FOOTER_HEIGHT + 4.0,
            (rect.width - pad * 2.0).max(0.0),
            (DIALOG_FOOTER_HEIGHT - 8.0).max(0.0),
        )
    }
    fn traversal_children(&self, idx: usize) -> Vec<usize> {
        if !self.widget_is_live(idx) {
            return Vec::new();
        }
        let mut out = self
            .widgets
            .get(idx)
            .and_then(|w| w.children())
            .cloned()
            .unwrap_or_default();
        if let Some(WidgetKind::Dialog(dialog)) = self.widgets.get(idx) {
            if let Some(child_idx) = dialog.content_idx {
                if !out.contains(&child_idx) {
                    out.push(child_idx);
                }
            }
            if let Some(child_idx) = dialog.footer_idx {
                if !out.contains(&child_idx) {
                    out.push(child_idx);
                }
            }
        }
        if let Some(WidgetKind::SplitPanel(split)) = self.widgets.get(idx) {
            if let Some(child_idx) = split.first_child {
                if !out.contains(&child_idx) {
                    out.push(child_idx);
                }
            }
            if let Some(child_idx) = split.second_child {
                if !out.contains(&child_idx) {
                    out.push(child_idx);
                }
            }
        }
        out
    }
    fn is_descendant_of(&self, root_idx: usize, needle_idx: usize) -> bool {
        let mut visited = HashSet::new();
        let mut stack = self.traversal_children(root_idx);
        while let Some(current) = stack.pop() {
            if current == needle_idx {
                return true;
            }
            if self.widget_is_live(current) && visited.insert(current) {
                stack.extend(self.traversal_children(current));
            }
        }
        false
    }
    fn active_modal_dialog(&self) -> Option<usize> {
        let mut best: Option<(usize, i32, usize)> = None;
        for (idx, widget) in self.widgets.iter().enumerate().skip(1) {
            if !self.widget_is_live(idx) {
                continue;
            }
            let WidgetKind::Dialog(dialog) = widget else {
                continue;
            };
            let base = widget.base();
            if !(dialog.open && dialog.modal && base.visible && base.is_visible && base.enabled) {
                continue;
            }
            best = Self::choose_topmost(best, idx, base.z_order);
        }
        best.map(|(idx, _, _)| idx)
    }
    fn widget_in_active_input_scope(&self, idx: usize) -> bool {
        match self.active_modal_dialog() {
            Some(dialog_idx) => idx == dialog_idx || self.is_descendant_of(dialog_idx, idx),
            None => true,
        }
    }
    fn effective_viewport_size(&self) -> (f32, f32) {
        let width = if self.viewport_w > 0.0 {
            self.viewport_w
        } else {
            self.base_resolution.0.max(1.0)
        };
        let height = if self.viewport_h > 0.0 {
            self.viewport_h
        } else {
            self.base_resolution.1.max(1.0)
        };
        (width, height)
    }
    /// Recursively compute and write `computed_rect` and `is_visible` for all widgets from root.
    pub fn run_layout_pass(&mut self) {
        // Phase 1: Enforce minimum sizes on widgets with zero or undersize dimensions.
        for idx in 1..self.widgets.len() {
            if !self.widget_is_live(idx) {
                continue;
            }
            let (min_w, min_h) = self.calculate_minimum_size(idx, None);
            let base = self.widgets[idx].base_mut();
            if base.width < min_w && base.width <= 0.0 {
                base.width = min_w;
            }
            if base.height < min_h && base.height <= 0.0 {
                base.height = min_h;
            }
        }

        // Phase 2: Top-down layout pass computing absolute rects.
        let (viewport_w, viewport_h) = self.effective_viewport_size();
        let root_rect = Rect::new(0.0, 0.0, viewport_w, viewport_h);
        let root_visible = if let Some(root) = self.widgets.first_mut() {
            let base = root.base_mut();
            base.computed_rect = root_rect;
            base.is_visible = base.visible;
            base.visible
        } else {
            true
        };
        let root_children = self.traversal_children(0);
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

    fn perform_stack_layout(&self, idx: usize, rect: Rect) -> Vec<(usize, Rect)> {
        let stack = match &self.widgets[idx] {
            WidgetKind::StackContainer(stack) | WidgetKind::TabContainer(stack) => stack,
            _ => return Vec::new(),
        };
        let content_rect = stack.content_rect(rect);
        stack
            .children
            .iter()
            .copied()
            .map(|child_idx| (child_idx, content_rect))
            .collect()
    }

    fn perform_split_layout(&self, idx: usize, rect: Rect) -> Vec<(usize, Rect)> {
        let WidgetKind::SplitPanel(split) = &self.widgets[idx] else {
            return Vec::new();
        };
        let pad = split.base.padding;
        let inner = Rect::new(
            rect.x + pad[3],
            rect.y + pad[0],
            (rect.width - pad[1] - pad[3]).max(0.0),
            (rect.height - pad[0] - pad[2]).max(0.0),
        );
        let mut out = Vec::new();
        let min_size = split.min_panel_size.max(0.0);
        let split_fraction = split.split_position.clamp(0.0, 1.0);
        if split.orientation == "vertical" {
            let first_h = (inner.height * split_fraction).clamp(
                0.0_f32.min(inner.height),
                (inner.height - min_size).max(0.0),
            );
            let first_h = if inner.height >= min_size * 2.0 {
                first_h.clamp(min_size, inner.height - min_size)
            } else {
                first_h
            };
            if let Some(child_idx) = split.first_child {
                out.push((child_idx, Rect::new(inner.x, inner.y, inner.width, first_h)));
            }
            if let Some(child_idx) = split.second_child {
                out.push((
                    child_idx,
                    Rect::new(
                        inner.x,
                        inner.y + first_h,
                        inner.width,
                        (inner.height - first_h).max(0.0),
                    ),
                ));
            }
        } else {
            let first_w = (inner.width * split_fraction)
                .clamp(0.0_f32.min(inner.width), (inner.width - min_size).max(0.0));
            let first_w = if inner.width >= min_size * 2.0 {
                first_w.clamp(min_size, inner.width - min_size)
            } else {
                first_w
            };
            if let Some(child_idx) = split.first_child {
                out.push((
                    child_idx,
                    Rect::new(inner.x, inner.y, first_w, inner.height),
                ));
            }
            if let Some(child_idx) = split.second_child {
                out.push((
                    child_idx,
                    Rect::new(
                        inner.x + first_w,
                        inner.y,
                        (inner.width - first_w).max(0.0),
                        inner.height,
                    ),
                ));
            }
        }
        out
    }

    fn perform_aspect_ratio_layout(&self, idx: usize, rect: Rect) -> Vec<(usize, Rect)> {
        let WidgetKind::AspectRatioContainer(container) = &self.widgets[idx] else {
            return Vec::new();
        };
        let child_rect = container.child_rect(rect);
        container
            .children
            .iter()
            .copied()
            .map(|child_idx| (child_idx, child_rect))
            .collect()
    }

    fn anchored_rect(base: &WidgetBase, parent_rect: &Rect, mut w: f32, mut h: f32) -> Rect {
        let has_horizontal_anchors = base.anchor_left.is_some() || base.anchor_right.is_some();
        let has_vertical_anchors = base.anchor_top.is_some() || base.anchor_bottom.is_some();
        let mut x = parent_rect.x + base.x;
        let mut y = parent_rect.y + base.y;
        if let (Some(left), Some(right)) = (base.anchor_left, base.anchor_right) {
            x = parent_rect.x + left;
            w = (parent_rect.width - left - right).max(0.0);
        } else if let Some(left) = base.anchor_left {
            x = parent_rect.x + left;
        } else if let Some(right) = base.anchor_right {
            x = parent_rect.x + parent_rect.width - right - w;
        } else if let Some(center_x) = base.anchor_center_x {
            x = parent_rect.x + parent_rect.width * center_x - w * 0.5;
        }
        if let (Some(top), Some(bottom)) = (base.anchor_top, base.anchor_bottom) {
            y = parent_rect.y + top;
            h = (parent_rect.height - top - bottom).max(0.0);
        } else if let Some(top) = base.anchor_top {
            y = parent_rect.y + top;
        } else if let Some(bottom) = base.anchor_bottom {
            y = parent_rect.y + parent_rect.height - bottom - h;
        } else if let Some(center_y) = base.anchor_center_y {
            y = parent_rect.y + parent_rect.height * center_y - h * 0.5;
        }
        if !has_horizontal_anchors && base.anchor_center_x.is_none() {
            x = parent_rect.x + base.x;
        }
        if !has_vertical_anchors && base.anchor_center_y.is_none() {
            y = parent_rect.y + base.y;
        }
        Rect::new(x, y, w, h)
    }

    /// Recursively lay out widget `idx` relative to `parent_rect`.
    fn layout_widget(
        &mut self,
        idx: usize,
        parent_rect: &Rect,
        parent_visible: bool,
        override_rect: Option<Rect>,
    ) {
        self.layout_widget_inner(idx, parent_rect, parent_visible, override_rect, 0);
    }

    fn layout_widget_inner(
        &mut self,
        idx: usize,
        parent_rect: &Rect,
        parent_visible: bool,
        override_rect: Option<Rect>,
        depth: usize,
    ) {
        if idx >= self.widgets.len()
            || !self.widget_is_live(idx)
            || depth > self.limits.max_tree_depth
        {
            return;
        }

        let computed = if let Some(rect) = override_rect {
            rect
        } else {
            let (mut w, mut h) = {
                let base = self.widgets[idx].base();
                (base.width, base.height)
            };
            if w == 0.0 && parent_rect.width > 0.0 {
                w = parent_rect.width;
            }
            if h == 0.0 && parent_rect.height > 0.0 {
                h = parent_rect.height;
            }
            Self::anchored_rect(self.widgets[idx].base(), parent_rect, w, h)
        };

        {
            let base = self.widgets[idx].base_mut();
            base.computed_rect = computed;
            base.is_visible = parent_visible && base.visible;
        }

        let mut overrides = self.perform_flex_layout(idx, &computed);
        overrides.extend(self.perform_stack_layout(idx, computed));
        overrides.extend(self.perform_split_layout(idx, computed));
        overrides.extend(self.perform_aspect_ratio_layout(idx, computed));
        let mut child_indices: Vec<usize> =
            self.widgets[idx].children().cloned().unwrap_or_default();
        if let Some(WidgetKind::SplitPanel(split)) = self.widgets.get(idx) {
            if let Some(child_idx) = split.first_child {
                if !child_indices.contains(&child_idx) {
                    child_indices.push(child_idx);
                }
            }
            if let Some(child_idx) = split.second_child {
                if !child_indices.contains(&child_idx) {
                    child_indices.push(child_idx);
                }
            }
        }
        let visible = self.widgets[idx].base().is_visible;
        let active_stack_child = match self.widgets.get(idx) {
            Some(WidgetKind::StackContainer(stack)) | Some(WidgetKind::TabContainer(stack)) => {
                stack.children.get(stack.active_index).copied()
            }
            _ => None,
        };

        for child_idx in child_indices {
            let child_override = overrides
                .iter()
                .find(|(i, _)| *i == child_idx)
                .map(|(_, r)| *r);
            let child_visible =
                active_stack_child.map_or(visible, |active| visible && active == child_idx);
            self.layout_widget_inner(
                child_idx,
                &computed,
                child_visible,
                child_override,
                depth.saturating_add(1),
            );
        }
        if let Some((content_idx, footer_idx, body_rect, footer_rect)) =
            self.widgets.get(idx).and_then(|widget| {
                let WidgetKind::Dialog(dialog) = widget else {
                    return None;
                };
                Some((
                    dialog.content_idx,
                    dialog.footer_idx,
                    Self::dialog_body_rect(computed, dialog),
                    Self::dialog_footer_rect(computed),
                ))
            })
        {
            if let Some(content_idx) = content_idx {
                self.layout_widget_inner(
                    content_idx,
                    &body_rect,
                    visible,
                    Some(body_rect),
                    depth.saturating_add(1),
                );
            }
            if let Some(footer_idx) = footer_idx {
                self.layout_widget_inner(
                    footer_idx,
                    &footer_rect,
                    visible,
                    Some(footer_rect),
                    depth.saturating_add(1),
                );
            }
        }
    }
    /// Add a `Button` widget and return its index.
    pub fn begin_drag(&mut self, widget_idx: usize) -> bool {
        if widget_idx == 0 || !self.widget_is_live(widget_idx) {
            return false;
        }
        let base = self.widgets[widget_idx].base();
        if !base.visible
            || !base.is_visible
            || !base.enabled
            || base.mouse_filter == MouseFilter::Ignore
        {
            return false;
        }
        self.drag_session = Some(DragSession {
            source_idx: widget_idx,
            start_x: 0.0,
            start_y: 0.0,
            started: true,
            hover_target: None,
        });
        self.pending_events.push(GuiEvent::DragStart(widget_idx));
        true
    }
    /// Return the widget index currently being dragged, if any.
    pub fn active_drag(&self) -> Option<usize> {
        self.drag_session
            .and_then(|session| session.started.then_some(session.source_idx))
    }
    /// End the current drag operation and return the dragged widget index, if any.
    pub fn end_drag(&mut self) -> Option<usize> {
        let session = self.drag_session.take()?;
        if let Some(target_idx) = session.hover_target {
            self.pending_events
                .push(GuiEvent::DragLeave(session.source_idx, target_idx));
        }
        self.pending_events
            .push(GuiEvent::DragEnd(session.source_idx, None));
        Some(session.source_idx)
    }
    /// Drop the active dragged widget onto `target_idx`; returns `false` if target is not a container or would create a cycle.
    pub fn drop_on(&mut self, target_idx: usize) -> bool {
        let Some(session) = self.drag_session else {
            return false;
        };
        let drag_idx = session.source_idx;
        if !self.widget_is_live(target_idx)
            || !self.widget_is_live(drag_idx)
            || drag_idx == target_idx
        {
            return false;
        }
        let target_base = self.widgets[target_idx].base();
        if self.widgets[target_idx].children().is_none()
            || !target_base.visible
            || !target_base.is_visible
            || !target_base.enabled
            || target_base.mouse_filter == MouseFilter::Ignore
        {
            return false;
        }
        if self.contains_descendant(drag_idx, target_idx) {
            return false;
        }
        self.detach_from_all_parents(drag_idx);
        if !self.add_child(target_idx, drag_idx) {
            return false;
        }
        self.drag_session = None;
        self.pending_events
            .push(GuiEvent::Drop(drag_idx, target_idx));
        self.pending_events
            .push(GuiEvent::DragEnd(drag_idx, Some(target_idx)));
        self.mark_dirty_flags(true, false, false, true);
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
        let mut visited = HashSet::new();
        let mut stack = self.traversal_children(root_idx);
        while let Some(current) = stack.pop() {
            if current == needle_idx {
                return true;
            }
            if self.widget_is_live(current) && visited.insert(current) {
                stack.extend(self.traversal_children(current));
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
        if !self.widget_is_live(widget_idx) {
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
        if !self.widget_is_live(widget_idx) {
            return false;
        }
        let base = self.widgets[widget_idx].base_mut();
        base.transitions.push(WidgetTransition::position(
            base.x, base.y, to_x, to_y, duration,
        ));
        self.dirty = true;
        true
    }
    /// Start a scale animation on a widget. Returns true if widget exists.
    #[allow(clippy::too_many_arguments)]
    pub fn animate_scale(
        &mut self,
        idx: usize,
        from_sx: f32,
        from_sy: f32,
        to_sx: f32,
        to_sy: f32,
        duration: f32,
        easing: EasingFunction,
    ) -> bool {
        if self.widget_is_live(idx) {
            if let Some(w) = self.widgets.get_mut(idx) {
                let base = w.base_mut();
                base.transitions.push(WidgetTransition {
                    kind: WidgetTransitionKind::Scale {
                        from_sx,
                        from_sy,
                        to_sx,
                        to_sy,
                    },
                    duration,
                    elapsed: 0.0,
                    hide_on_complete: false,
                    easing,
                });
                true
            } else {
                false
            }
        } else {
            false
        }
    }

    /// Start a rotation animation on a widget. Returns true if widget exists.
    pub fn animate_rotation(
        &mut self,
        idx: usize,
        from: f32,
        to: f32,
        duration: f32,
        easing: EasingFunction,
    ) -> bool {
        if self.widget_is_live(idx) {
            if let Some(w) = self.widgets.get_mut(idx) {
                let base = w.base_mut();
                base.transitions.push(WidgetTransition {
                    kind: WidgetTransitionKind::Rotation { from, to },
                    duration,
                    elapsed: 0.0,
                    hide_on_complete: false,
                    easing,
                });
                true
            } else {
                false
            }
        } else {
            false
        }
    }

    /// Start a color tint animation on a widget. Returns true if widget exists.
    pub fn animate_color(
        &mut self,
        idx: usize,
        from: [f32; 4],
        to: [f32; 4],
        duration: f32,
        easing: EasingFunction,
    ) -> bool {
        if self.widget_is_live(idx) {
            if let Some(w) = self.widgets.get_mut(idx) {
                let base = w.base_mut();
                base.transitions.push(WidgetTransition {
                    kind: WidgetTransitionKind::Color { from, to },
                    duration,
                    elapsed: 0.0,
                    hide_on_complete: false,
                    easing,
                });
                true
            } else {
                false
            }
        } else {
            false
        }
    }
    /// Clear all pending transitions on `widget_idx`; returns `false` on invalid index.
    pub fn cancel_animations(&mut self, widget_idx: usize) -> bool {
        if !self.widget_is_live(widget_idx) {
            return false;
        }
        self.widgets[widget_idx].base_mut().transitions.clear();
        self.dirty = true;
        true
    }
    /// Return `true` if `widget_idx` has at least one active transition.
    pub fn is_animating(&self, widget_idx: usize) -> bool {
        self.widget_is_live(widget_idx)
            && self
                .widgets
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
                    WidgetKind::TextArea(input) => {
                        if input.text != *t {
                            let previous = input.text.clone();
                            input.set_text(t.clone());
                            if input.text != previous {
                                changed += 1;
                            }
                        }
                    }
                    WidgetKind::RichLabel(label) => {
                        if label.text != *t {
                            label.text = t.clone();
                            changed += 1;
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
            for value in b.padding.iter().chain(b.margin.iter()) {
                hash ^= value.to_bits() as u64;
                hash = hash.wrapping_mul(1099511628211);
            }
            hash ^= (b.text_wrap as u64)
                | ((b.text_ellipsis as u64) << 1)
                | ((b.text_v_align as u64) << 2);
            hash = hash.wrapping_mul(1099511628211);
            hash ^= b.text_align.len() as u64;
            for byte in b.text_align.as_bytes() {
                hash ^= *byte as u64;
                hash = hash.wrapping_mul(1099511628211);
            }
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
        if !self.widget_is_live(parent_idx) || !self.widget_is_live(child_idx) {
            return false;
        }
        if child_idx == 0 || parent_idx == child_idx {
            return false;
        }
        if self.contains_descendant(child_idx, parent_idx) {
            return false;
        }
        for idx in 0..self.widgets.len() {
            if idx != parent_idx && self.traversal_children(idx).contains(&child_idx) {
                return false;
            }
        }
        if let Some(children) = self.widgets[parent_idx].children_mut() {
            if !children.contains(&child_idx)
                && children.len() >= self.limits.max_children_per_widget
            {
                return false;
            }
            if !children.contains(&child_idx) {
                children.push(child_idx);
            }
            self.mark_dirty_flags(true, false, false, true);
            true
        } else {
            false
        }
    }
    /// Validate the retained widget tree and return any structural problems found.
    pub fn validate_tree(&self) -> Vec<String> {
        let mut errors = Vec::new();
        let mut parent_counts = vec![0usize; self.widgets.len()];
        for idx in 0..self.widgets.len() {
            if !self.widget_is_live(idx) {
                continue;
            }
            let mut seen_children = HashSet::new();
            for child_idx in self.traversal_children(idx) {
                if child_idx >= self.widgets.len() {
                    errors.push(format!("widget {idx} references invalid child {child_idx}"));
                    continue;
                }
                if !seen_children.insert(child_idx) {
                    errors.push(format!(
                        "widget {idx} references child {child_idx} more than once"
                    ));
                    continue;
                }
                if child_idx == 0 {
                    errors.push(format!(
                        "widget {idx} references the root widget as a child"
                    ));
                }
                parent_counts[child_idx] += 1;
            }
        }
        for (idx, count) in parent_counts.iter().enumerate().skip(1) {
            if *count == 0 {
                errors.push(format!("widget {idx} is orphaned"));
            } else if *count > 1 {
                errors.push(format!("widget {idx} has multiple parents"));
            }
        }
        let mut visit_state = vec![0u8; self.widgets.len()];
        for idx in 0..self.widgets.len() {
            self.validate_tree_cycles(idx, &mut visit_state, &mut errors);
        }
        errors
    }
    fn validate_tree_cycles(&self, idx: usize, visit_state: &mut [u8], errors: &mut Vec<String>) {
        if !self.widget_is_live(idx) {
            return;
        }
        match visit_state[idx] {
            1 => {
                errors.push(format!("cycle detected at widget {idx}"));
                return;
            }
            2 => return,
            _ => {}
        }
        let mut stack = vec![(idx, false)];
        while let Some((current, exiting)) = stack.pop() {
            if current >= self.widgets.len() || !self.widget_is_live(current) {
                continue;
            }
            if exiting {
                visit_state[current] = 2;
                continue;
            }
            match visit_state[current] {
                1 => errors.push(format!("cycle detected at widget {current}")),
                2 => continue,
                _ => {
                    visit_state[current] = 1;
                    stack.push((current, true));
                    for child_idx in self.traversal_children(current).into_iter().rev() {
                        if child_idx < self.widgets.len() {
                            stack.push((child_idx, false));
                        }
                    }
                }
            }
        }
    }
    fn widget_text_content(&self, idx: usize) -> Option<&str> {
        match self.widgets.get(idx)? {
            WidgetKind::Button(button) => Some(button.text.as_str()),
            WidgetKind::Label(label) => Some(label.text.as_str()),
            WidgetKind::TextInput(text_input) => {
                if text_input.text.is_empty() {
                    None
                } else {
                    Some(text_input.text.as_str())
                }
            }
            WidgetKind::TextArea(text_area) => {
                if text_area.text.is_empty() {
                    None
                } else {
                    Some(text_area.text.as_str())
                }
            }
            WidgetKind::RichLabel(rich_label) => Some(rich_label.text.as_str()),
            WidgetKind::CheckBox(check_box) => Some(check_box.text.as_str()),
            WidgetKind::ComboBox(combo) => combo.selected_item(),
            WidgetKind::ListBox(list) => list.selected_item(),
            WidgetKind::TabBar(tab_bar) => tab_bar.tabs.get(tab_bar.active_tab).map(String::as_str),
            WidgetKind::TreeView(tree) => tree
                .selected_node
                .and_then(|node_idx| tree.get_node_text(node_idx)),
            WidgetKind::RadioButton(radio_button) => Some(radio_button.text.as_str()),
            WidgetKind::GUIWindow(window) => Some(window.title.as_str()),
            WidgetKind::MenuItem(menu_item) => Some(menu_item.text.as_str()),
            WidgetKind::Dialog(dialog) => Some(dialog.title.as_str()),
            WidgetKind::TooltipPanel(tooltip) => Some(tooltip.text.as_str()),
            WidgetKind::Accordion(accordion) => accordion
                .sections
                .first()
                .map(|section| section.title.as_str()),
            WidgetKind::StatusBar(status_bar) => {
                status_bar.sections.first().map(|(text, _)| text.as_str())
            }
            WidgetKind::Badge(_) => None,
            _ => None,
        }
    }
    fn label_text_for_widget(&self, idx: usize) -> Option<&str> {
        self.widgets.iter().find_map(|widget| {
            let base = widget.base();
            if base.label_for != Some(idx) {
                return None;
            }
            match widget {
                WidgetKind::Label(label) => {
                    let text = label.text.trim();
                    if text.is_empty() {
                        None
                    } else {
                        Some(text)
                    }
                }
                WidgetKind::RichLabel(label) => {
                    let text = label.text.trim();
                    if text.is_empty() {
                        None
                    } else {
                        Some(text)
                    }
                }
                _ => None,
            }
        })
    }
    fn resolved_role(&self, idx: usize) -> String {
        self.widgets.get(idx).map_or_else(String::new, |widget| {
            let base = widget.base();
            let role = base.role.trim();
            if role.is_empty() {
                base.widget_type.default_role().to_string()
            } else {
                role.to_string()
            }
        })
    }
    fn resolved_accessible_name(&self, idx: usize) -> String {
        let Some(widget) = self.widgets.get(idx) else {
            return String::new();
        };
        let aria_name = widget.base().aria_name.trim();
        if !aria_name.is_empty() {
            return aria_name.to_string();
        }
        if let Some(text) = self.widget_text_content(idx) {
            let text = text.trim();
            if !text.is_empty() {
                return text.to_string();
            }
        }
        self.label_text_for_widget(idx)
            .map_or_else(String::new, ToString::to_string)
    }
    fn widget_touch_target_size(&self, idx: usize) -> (f32, f32) {
        self.widget_rect(idx)
            .map(|rect| (rect.width, rect.height))
            .unwrap_or_else(|| {
                let base = self.widgets[idx].base();
                (base.width, base.height)
            })
    }
    fn widget_is_popup_shell(&self, idx: usize) -> bool {
        matches!(
            self.widgets.get(idx),
            Some(WidgetKind::GUIWindow(_) | WidgetKind::Dialog(_))
        )
    }
    fn widget_is_popup_open(&self, idx: usize) -> bool {
        match self.widgets.get(idx) {
            Some(WidgetKind::GUIWindow(window)) => window.base.visible && window.base.is_visible,
            Some(WidgetKind::Dialog(dialog)) => {
                dialog.open && dialog.base.visible && dialog.base.is_visible
            }
            _ => false,
        }
    }
    fn widget_rect_outside_viewport(&self, idx: usize) -> bool {
        let Some(rect) = self.widget_rect(idx) else {
            return false;
        };
        let (viewport_w, viewport_h) = self.effective_viewport_size();
        rect.x < 0.0
            || rect.y < 0.0
            || rect.x + rect.width > viewport_w
            || rect.y + rect.height > viewport_h
    }
    fn popup_has_z_order_conflict(&self, idx: usize) -> Option<usize> {
        if !self.widget_is_popup_shell(idx) || !self.widget_is_popup_open(idx) {
            return None;
        }
        let z_order = self.widgets[idx].base().z_order;
        (1..self.widgets.len()).find(|other_idx| {
            *other_idx != idx
                && self.widget_is_popup_shell(*other_idx)
                && self.widget_is_popup_open(*other_idx)
                && self.widgets[*other_idx].base().z_order == z_order
        })
    }
    /// Return a flattened accessibility snapshot for all live non-root widgets.
    pub fn accessibility_tree(&self) -> Vec<UiAccessibilityNode> {
        (1..self.widgets.len())
            .map(|idx| {
                let base = self.widgets[idx].base();
                UiAccessibilityNode {
                    widget_idx: idx,
                    widget_type: base.widget_type.as_str().to_string(),
                    role: self.resolved_role(idx),
                    name: self.resolved_accessible_name(idx),
                    description: base.description.clone(),
                    label_for: base.label_for,
                    focusable: base.focusable,
                    visible: base.is_visible,
                    enabled: base.enabled,
                }
            })
            .collect()
    }
    /// Validate accessibility and interaction semantics beyond structural tree checks.
    pub fn validate_ux(&self) -> Vec<UiDiagnostic> {
        let mut diagnostics = Vec::new();
        for error in self.validate_tree() {
            diagnostics.push(UiDiagnostic::new(None, error));
        }
        let mut seen_ids: HashMap<&str, usize> = HashMap::new();
        for idx in 1..self.widgets.len() {
            let widget = &self.widgets[idx];
            let base = widget.base();
            let id = base.id.trim();
            if !id.is_empty() {
                if let Some(first_idx) = seen_ids.insert(id, idx) {
                    diagnostics.push(UiDiagnostic::new(
                        Some(idx),
                        format!("widget id '{id}' duplicates widget {first_idx}"),
                    ));
                }
            }
            if base.label_for.is_some()
                && !matches!(widget, WidgetKind::Label(_) | WidgetKind::RichLabel(_))
            {
                diagnostics.push(UiDiagnostic::new(
                    Some(idx),
                    "label_for is only supported on Label and RichLabel widgets",
                ));
            }
            if let Some(target_idx) = base.label_for {
                if target_idx >= self.widgets.len() {
                    diagnostics.push(UiDiagnostic::new(
                        Some(idx),
                        format!("label_for points to invalid widget {target_idx}"),
                    ));
                } else if target_idx == idx {
                    diagnostics.push(UiDiagnostic::new(
                        Some(idx),
                        "label_for cannot point to the same widget",
                    ));
                }
            }
            if base.focusable && !base.widget_type.default_focusable() {
                diagnostics.push(UiDiagnostic::new(
                    Some(idx),
                    format!(
                        "{} is focusable even though it is decorative by default",
                        base.widget_type.as_str()
                    ),
                ));
            }
            if base.focusable && self.resolved_accessible_name(idx).is_empty() {
                diagnostics.push(UiDiagnostic::new(
                    Some(idx),
                    format!(
                        "{} is focusable but has no accessible name",
                        base.widget_type.as_str()
                    ),
                ));
            }
            if base.enabled && base.widget_type.default_focusable() {
                let (width, height) = self.widget_touch_target_size(idx);
                if width < 44.0 || height < 44.0 {
                    diagnostics.push(UiDiagnostic::new(
                        Some(idx),
                        format!(
                            "{} touch target is only {:.1}x{:.1}; expected at least 44x44",
                            base.widget_type.as_str(),
                            width,
                            height
                        ),
                    ));
                }
            }
            if self.widget_is_popup_shell(idx) && self.widget_is_popup_open(idx) {
                if self.widget_rect_outside_viewport(idx) {
                    diagnostics.push(UiDiagnostic::new(
                        Some(idx),
                        format!(
                            "{} extends outside the active viewport",
                            base.widget_type.as_str()
                        ),
                    ));
                }
                if let Some(conflict_idx) = self.popup_has_z_order_conflict(idx) {
                    diagnostics.push(UiDiagnostic::new(
                        Some(idx),
                        format!(
                            "{} shares z-order with popup widget {}",
                            base.widget_type.as_str(),
                            conflict_idx
                        ),
                    ));
                }
            }
            if let WidgetKind::Dialog(dialog) = widget {
                if dialog.modal && dialog.default_action_idx.is_none() {
                    diagnostics.push(UiDiagnostic::new(
                        Some(idx),
                        "modal dialog has no default action",
                    ));
                }
                if dialog.modal && dialog.cancel_action_idx.is_none() && !dialog.closeable {
                    diagnostics.push(UiDiagnostic::new(
                        Some(idx),
                        "modal dialog has no cancel action and is not closeable",
                    ));
                }
            }
        }
        diagnostics
    }
    /// Remove `child_idx` from `parent_idx`'s child list; return `false` if not found.
    pub fn remove_child(&mut self, parent_idx: usize, child_idx: usize) -> bool {
        if !self.widget_is_live(parent_idx) || !self.widget_is_live(child_idx) {
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
        if !self.widget_is_live(widget_idx) {
            return 0;
        }
        self.widgets
            .get(widget_idx)
            .and_then(|w| w.children())
            .map_or(0, |c| c.len())
    }
    /// Push a toast message into the overlay queue.
    pub fn find_by_id(&self, start_idx: usize, id: &str) -> Option<usize> {
        let mut visited = HashSet::new();
        let mut stack = vec![start_idx];
        while let Some(current) = stack.pop() {
            if !self.widget_is_live(current) || !visited.insert(current) {
                continue;
            }
            if self.widgets[current].base().id == id {
                return Some(current);
            }
            stack.extend(self.traversal_children(current).into_iter().rev());
        }
        None
    }

    // â”€â”€ Feature 1: Two-Phase Layout (Min-Size Negotiation) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    /// Calculate the minimum size a widget needs based on its content.
    /// Returns (min_width, min_height).
    pub fn calculate_minimum_size(
        &self,
        idx: usize,
        font: Option<&crate::font::Font>,
    ) -> (f32, f32) {
        if idx >= self.widgets.len() {
            return (0.0, 0.0);
        }
        let widget = &self.widgets[idx];
        let base = widget.base();
        let pad_h = base.padding[1] + base.padding[3];
        let pad_v = base.padding[0] + base.padding[2];

        match widget {
            WidgetKind::Button(w) => {
                let text_w = Self::measure_text_width(&w.text, font);
                (
                    text_w + pad_h + 16.0,
                    base.padding[0] + base.padding[2] + 24.0,
                )
            }
            WidgetKind::Label(w) => {
                let text_w = Self::measure_text_width(&w.text, font);
                (text_w + pad_h + 4.0, pad_v + 16.0)
            }
            WidgetKind::RichLabel(w) => {
                let text_w = Self::measure_text_width(&w.plain_text(), font);
                (
                    text_w.min(base.width.max(text_w)) + pad_h + 4.0,
                    pad_v + 32.0,
                )
            }
            WidgetKind::TextInput(_) => (pad_h + 48.0, pad_v + 24.0),
            WidgetKind::TextArea(_) => (pad_h + 96.0, pad_v + 72.0),
            WidgetKind::CheckBox(w) => {
                let text_w = Self::measure_text_width(&w.text, font);
                (text_w + pad_h + 20.0, pad_v + 16.0)
            }
            WidgetKind::RadioButton(w) => {
                let text_w = Self::measure_text_width(&w.text, font);
                (text_w + pad_h + 20.0, pad_v + 16.0)
            }
            WidgetKind::Layout(l) => {
                let spacing = l.spacing;
                let mut total_w = 0.0_f32;
                let mut total_h = 0.0_f32;
                let mut count = 0usize;
                for &child_idx in &l.children {
                    let (cw, ch) = self.calculate_minimum_size(child_idx, font);
                    match l.direction {
                        crate::ui::containers::LayoutDirection::Horizontal => {
                            total_w += cw;
                            total_h = total_h.max(ch);
                        }
                        crate::ui::containers::LayoutDirection::Vertical => {
                            total_w = total_w.max(cw);
                            total_h += ch;
                        }
                        crate::ui::containers::LayoutDirection::Grid => {
                            total_w = total_w.max(cw);
                            total_h += ch;
                        }
                    }
                    count += 1;
                }
                if count > 1 {
                    match l.direction {
                        crate::ui::containers::LayoutDirection::Horizontal => {
                            total_w += spacing * (count as f32 - 1.0);
                        }
                        crate::ui::containers::LayoutDirection::Vertical
                        | crate::ui::containers::LayoutDirection::Grid => {
                            total_h += spacing * (count as f32 - 1.0);
                        }
                    }
                }
                (total_w + pad_h, total_h + pad_v)
            }
            WidgetKind::AspectRatioContainer(container) => {
                let mut max_w = 0.0_f32;
                let mut max_h = 0.0_f32;
                for &child_idx in &container.children {
                    let (cw, ch) = self.calculate_minimum_size(child_idx, font);
                    max_w = max_w.max(cw);
                    max_h = max_h.max(ch);
                }
                (max_w + pad_h, max_h + pad_v)
            }
            WidgetKind::Panel(p) => {
                let mut max_w = 0.0_f32;
                let mut max_h = 0.0_f32;
                for &child_idx in &p.children {
                    let (cw, ch) = self.calculate_minimum_size(child_idx, font);
                    max_w = max_w.max(cw);
                    max_h = max_h.max(ch);
                }
                (max_w + pad_h, max_h + pad_v)
            }
            WidgetKind::ScrollPanel(sp) => {
                let mut max_w = 0.0_f32;
                let mut max_h = 0.0_f32;
                for &child_idx in &sp.children {
                    let (cw, ch) = self.calculate_minimum_size(child_idx, font);
                    max_w = max_w.max(cw);
                    max_h = max_h.max(ch);
                }
                (max_w + pad_h, max_h + pad_v)
            }
            WidgetKind::StackContainer(stack) | WidgetKind::TabContainer(stack) => {
                let mut max_w = 0.0_f32;
                let mut max_h = 0.0_f32;
                for &child_idx in &stack.children {
                    let (cw, ch) = self.calculate_minimum_size(child_idx, font);
                    max_w = max_w.max(cw);
                    max_h = max_h.max(ch);
                }
                let tab_h = if stack.show_tabs {
                    stack.tab_bar_height.max(0.0)
                } else {
                    0.0
                };
                (max_w + pad_h, max_h + pad_v + tab_h)
            }
            WidgetKind::SplitPanel(split) => {
                let (first_w, first_h) = split
                    .first_child
                    .map(|child_idx| self.calculate_minimum_size(child_idx, font))
                    .unwrap_or((0.0, 0.0));
                let (second_w, second_h) = split
                    .second_child
                    .map(|child_idx| self.calculate_minimum_size(child_idx, font))
                    .unwrap_or((0.0, 0.0));
                if split.orientation == "vertical" {
                    (first_w.max(second_w) + pad_h, first_h + second_h + pad_v)
                } else {
                    (first_w + second_w + pad_h, first_h.max(second_h) + pad_v)
                }
            }
            WidgetKind::GUIWindow(window) => {
                let mut max_w = 0.0_f32;
                let mut max_h = 0.0_f32;
                for &child_idx in &window.children {
                    let (cw, ch) = self.calculate_minimum_size(child_idx, font);
                    max_w = max_w.max(cw);
                    max_h = max_h.max(ch);
                }
                (
                    max_w + pad_h + 16.0,
                    max_h + pad_v + WINDOW_TITLE_HEIGHT + 8.0,
                )
            }
            WidgetKind::Dialog(dialog) => {
                let mut max_w = 0.0_f32;
                let mut max_h = 0.0_f32;
                if let Some(content_idx) = dialog.content_idx {
                    let (cw, ch) = self.calculate_minimum_size(content_idx, font);
                    max_w = max_w.max(cw);
                    max_h = max_h.max(ch);
                }
                if let Some(footer_idx) = dialog.footer_idx {
                    let (cw, ch) = self.calculate_minimum_size(footer_idx, font);
                    max_w = max_w.max(cw);
                    max_h += ch.max(24.0);
                } else if !dialog.actions.is_empty() {
                    max_w = max_w.max(
                        dialog.actions.len() as f32
                            * (DIALOG_FOOTER_BUTTON_WIDTH + DIALOG_FOOTER_BUTTON_GAP),
                    );
                    max_h += DIALOG_FOOTER_HEIGHT;
                }
                (
                    max_w + pad_h + 16.0,
                    max_h + pad_v + DIALOG_TITLE_HEIGHT + 16.0,
                )
            }
            WidgetKind::PropertyWidget(property_widget) => {
                let visible_rows: usize = property_widget
                    .groups
                    .iter()
                    .map(|group| if group.collapsed { 0 } else { group.rows.len() })
                    .sum();
                let max_name_width = property_widget
                    .groups
                    .iter()
                    .flat_map(|group| &group.rows)
                    .map(|row| Self::measure_text_width(&row.name, font))
                    .fold(0.0_f32, f32::max);
                let max_value_width = property_widget
                    .groups
                    .iter()
                    .flat_map(|group| &group.rows)
                    .map(|row| Self::measure_text_width(&row.value, font))
                    .fold(0.0_f32, f32::max);
                (
                    property_widget.label_width.max(max_name_width + 20.0)
                        + max_value_width
                        + pad_h
                        + 32.0,
                    property_widget.groups.len() as f32 * property_widget.group_header_height
                        + visible_rows as f32 * property_widget.row_height
                        + pad_v,
                )
            }
            _ => {
                let (dw, dh) = base.widget_type.default_size();
                (
                    base.min_width.max(dw.min(32.0)) + pad_h,
                    base.min_height.max(dh.min(16.0)) + pad_v,
                )
            }
        }
    }

    /// Simple text width measurement for min-size calculations.
    fn measure_text_width(text: &str, font: Option<&crate::font::Font>) -> f32 {
        match font {
            Some(f) => f.text_width(text),
            None => text.chars().count() as f32 * 7.0,
        }
    }

    // â”€â”€ Feature 2: Spatial Focus Navigation â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    // â”€â”€ Feature 3: UI Virtualization â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    /// Calculate the visible item range for a scrollable list widget.
    /// Returns (start_index, end_index_exclusive) of items that should be rendered.
    pub fn visible_item_range(
        &self,
        widget_idx: usize,
        item_count: usize,
        item_height: f32,
    ) -> (usize, usize) {
        if widget_idx >= self.widgets.len() || item_height <= 0.0 || item_count == 0 {
            return (0, 0);
        }
        let base = self.widgets[widget_idx].base();
        let scroll_offset = match &self.widgets[widget_idx] {
            WidgetKind::ScrollPanel(sp) => sp.scroll_y,
            WidgetKind::ListBox(lb) => lb.scroll_y,
            WidgetKind::GUITable(t) => t.scroll_y,
            _ => 0.0,
        };
        let viewport_h = base.computed_rect.height;
        let start = (scroll_offset / item_height).floor().max(0.0) as usize;
        let visible_count = (viewport_h / item_height).ceil() as usize + 1;
        let end = (start + visible_count).min(item_count);
        (start, end)
    }

    // â”€â”€ Feature 4: Global Resolution Scaling â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
}

impl Default for GuiContext {
    fn default() -> Self {
        Self::new()
    }
}
