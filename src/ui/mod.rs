//! This module re-exports UI surface for `containers.rs`, `context.rs`, `controls.rs`, and `diagnostics.rs` and helpers.
//! It keeps navigation explicit by showing which sibling files own state, validation, transport, or render behavior.
//! Public exports here route callers toward `containers.rs`, `context.rs`, and `controls.rs` first, while deeper owners.
//! Open this file when the public UI symbol map moves; edit siblings when runtime rules themselves change.
//! This index exists to organize entrypoints, not to absorb the state, caches, or algorithms its children own.
//! Use neighboring owners for behavioral fixes, and keep this file limited to exports, docs, and navigation.
//! Reexports here help agents find right module quickly when changes touch `containers.rs`, `context.rs`, subsystem.
//! Keep concrete logic in `containers.rs`, `context.rs`, and `controls.rs` so symbol lookup stays shallow.

/// Container widgets: panels, docks, scroll areas, split views.
pub mod containers;
/// GUI context, event dispatch, and data-binding values.
pub mod context;
/// Interactive control widgets: buttons, sliders, inputs, combo boxes.
pub mod controls;
/// Accessibility dump and UX diagnostics payload types.
pub mod diagnostics;
/// Extended widgets: dialogs, menus, trees, tables, toasts, toolbars.
pub mod extras;
/// Built-in icon catalog and icon placement metadata.
pub mod icons;
/// Shared ceilings for UI input, retained state, and software capture.
pub mod limits;
/// UI render helpers and draw-command generation.
pub mod render;
/// Theming and per-widget style configuration.
pub mod theme;
/// Base widget trait, state, transitions, and type registry.
pub mod widget;
pub use containers::{
    DockPanel, GUIWindow, Layout, LayoutDirection, NinePatch, NineSlice, Panel, ScrollPanel,
    SplitPanel, StackContainer,
};
pub use context::{GuiContext, GuiEvent, UiBindingValue, WidgetId};
pub use controls::{
    Button, CheckBox, ComboBox, Label, ListBox, ProgressBar, RadioButton, ScrollBar, Slider,
    SpinBox, Switch, TabBar, TextInput,
};
pub use diagnostics::{UiAccessibilityNode, UiDiagnostic};
pub use extras::{
    Accordion, AccordionSection, Badge, ColorPicker, CustomWidget, Dialog, GUITable, ImageWidget,
    MenuBar, MenuItem, PropertyGroup, PropertyRow, PropertyValueKind, PropertyWidget, Separator,
    Spacer, StatusBar, TableColumn, Toast, Toolbar, ToolbarButton, TooltipPanel, TreeNode,
    TreeView,
};
pub use icons::{has_icon, icon_names, lookup_icon, UiIcon, UiIconPosition, BUILTIN_UI_ICONS};
pub use limits::UiLimits;
pub use theme::{Theme, WidgetStyle};
pub use widget::{
    EasingFunction, MouseFilter, TextVAlign, WidgetBase, WidgetState, WidgetTransition,
    WidgetTransitionKind, WidgetType,
};
/// TOML-based declarative layout loader and image renderer.
#[cfg(feature = "ui-layout-loader")]
pub mod layout_loader;
#[cfg(feature = "ui-layout-loader")]
pub use layout_loader::{
    load_layout_def, load_layout_def_attached, load_layout_toml, load_layout_toml_attached,
    render_to_image, LayoutDef, WidgetDef,
};
