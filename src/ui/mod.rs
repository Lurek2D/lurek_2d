//! Exports the retained UI subsystem surface that combines widgets, containers, context, render, and theming.
//! Acts as the index for UI ownership so callers can see where tree state, controls, layout, and draw logic live.
//! Centralizes module visibility and re-exports instead of storing live widget state or performing UI updates.
//! Connects code-built and data-driven UI flows by exposing the owners used by both runtime screens and tools.
//! Open this file first when adding or removing a UI owner or when public UI re-export policy needs to change.
//! Use it to map a UI concern to its concrete Rust file before editing control, context, or render behavior.

/// Container widgets: panels, docks, scroll areas, split views.
pub mod containers;
/// GUI context, event dispatch, and data-binding values.
pub mod context;
/// Interactive control widgets: buttons, sliders, inputs, combo boxes.
pub mod controls;
/// Extended widgets: dialogs, menus, trees, tables, toasts, toolbars.
pub mod extras;
/// UI render helpers and draw-command generation.
pub mod render;
/// Theming and per-widget style configuration.
pub mod theme;
/// Base widget trait, state, transitions, and type registry.
pub mod widget;
pub use containers::{
    DockPanel, GUIWindow, Layout, LayoutDirection, NinePatch, NineSlice, Panel, ScrollPanel,
    SplitPanel,
};
pub use context::{GuiContext, GuiEvent, UiBindingValue};
pub use controls::{
    Button, CheckBox, ComboBox, Label, ListBox, ProgressBar, RadioButton, ScrollBar, Slider,
    SpinBox, Switch, TabBar, TextInput,
};
pub use extras::{
    Accordion, AccordionSection, Badge, ColorPicker, CustomWidget, Dialog, GUITable, ImageWidget,
    MenuBar, MenuItem, Separator, Spacer, StatusBar, TableColumn, Toast, Toolbar, ToolbarButton,
    TooltipPanel, TreeNode, TreeView,
};
pub use theme::{Theme, WidgetStyle};
pub use widget::{
    EasingFunction, MouseFilter, TextVAlign, WidgetBase, WidgetState, WidgetTransition,
    WidgetTransitionKind, WidgetType,
};
/// TOML-based declarative layout loader and image renderer.
#[cfg(feature = "ui-layout-loader")]
pub mod layout_loader;
#[cfg(feature = "ui-layout-loader")]
pub use layout_loader::{load_layout_def, load_layout_toml, render_to_image, LayoutDef, WidgetDef};
