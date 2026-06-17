//! This module delivers the full retained UI toolkit used by gameplay and tooling layers. `ui/mod` is the ui module index, declaring `containers`, `context`, `controls`, `extras`, `render`, and 3 more so agents can identify which files own each feature slice before opening implementation code.
//! It combines context, widgets, containers, rendering, and theming into one coherent surface. `src/ui/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `containers::{ DockPanel, GUIWindow, Layout, LayoutDirection, NinePatch, NineSlice, Panel, ScrollPanel, SplitPanel, }`, `context::{GuiContext, GuiEvent, UiBindingValue}`, `controls::{ Button, CheckBox, ComboBox, Label, ListBox, ProgressBar, RadioButton, ScrollBar, Slider, SpinBox, Switch, TabBar, TextInput, }`, `extras::{ Accordion, AccordionSection, Badge, ColorPicker, CustomWidget, Dialog, GUITable, ImageWidget, MenuBar, MenuItem, Separator, Spacer, StatusBar, TableColumn, Toast, Toolbar, ToolbarButton, TooltipPanel, TreeNode, TreeView, }`, and 3 more centralized for the ui subsystem.
//! It keeps interface construction flexible through code-first and data-driven layout paths. The file documents how ui submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.
//! `ui/mod` is the ui module index, declaring `containers`, `context`, `controls`, `extras`, `render`, and 3 more so agents can identify which files own each feature slice before opening implementation code.
//! `src/ui/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `containers::{ DockPanel, GUIWindow, Layout, LayoutDirection, NinePatch, NineSlice, Panel, ScrollPanel, SplitPanel, }`, `context::{GuiContext, GuiEvent, UiBindingValue}`, `controls::{ Button, CheckBox, ComboBox, Label, ListBox, ProgressBar, RadioButton, ScrollBar, Slider, SpinBox, Switch, TabBar, TextInput, }`, `extras::{ Accordion, AccordionSection, Badge, ColorPicker, CustomWidget, Dialog, GUITable, ImageWidget, MenuBar, MenuItem, Separator, Spacer, StatusBar, TableColumn, Toast, Toolbar, ToolbarButton, TooltipPanel, TreeNode, TreeView, }`, and 3 more centralized for the ui subsystem.
//! The file documents how ui submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.

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
