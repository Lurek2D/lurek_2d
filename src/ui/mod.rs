//! Immediate-mode GUI toolkit: containers, controls, extras, and theming.
//!
//! - Sub-modules: `chart`, `data_graph_renderer`, `containers`, `context`, and 6 more.

/// Chart types re-exported from the charts crate module.
pub mod chart;
/// Multi-series data graph renderer with viewport and coordinate mapping.
pub mod data_graph_renderer;
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
pub use widget::{EasingFunction, MouseFilter, WidgetBase, WidgetState, WidgetTransition, WidgetTransitionKind, WidgetType, TextVAlign};
/// TOML-based declarative layout loader and image renderer.
#[cfg(feature = "ui-layout-loader")]
pub mod layout_loader;
#[cfg(feature = "ui-layout-loader")]
pub use layout_loader::{load_layout_def, load_layout_toml, render_to_image, LayoutDef, WidgetDef};
