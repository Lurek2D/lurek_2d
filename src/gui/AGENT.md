# `gui` — Agent Reference

| Property | Value |
|----------|-------|
| **Tier** | Tier 2 — Reusable Engine Extensions |
| **Status** | Implemented — Full |
| **Lua API** | `luna.gui` |
| **Source** | `src/gui/` |
| **Rust Tests** | `tests/unit/gui_tests.rs` |
| **Lua Tests** | `tests/lua/unit/test_gui.lua` |
| **Architecture** | — |

## Summary

The `gui` module provides a retained-mode 2D widget system for building in-game menus, HUDs,
dialog boxes, and inventory screens. It is a Tier 2 Engine Extension.

Widget types — `Button`, `Label`, `TextInput`, `CheckBox`, `Slider`, `ProgressBar`, `ListBox`,
`ComboBox`, `ScrollPanel`, `NinePatch`, `Panel`, `Toast`, `Separator`, `Spacer`, `TreeView`, and
more — inherit shared base properties from `WidgetBase`: position, size, visibility, padding,
margin, z-order, anchor constraints, and flexbox layout settings. A `Theme` maps
`(WidgetType, WidgetState)` pairs to `WidgetStyle` records containing colours, font size,
border width, and corner radius. `GuiContext` is the root widget tree managing focus, a toast
notification queue, and input routing.

Input events are forwarded manually from `luna.mousepressed` / `luna.keypressed` etc., giving
scripts full control over which GUI instance is active.

**Scope boundary**: The `gui` module holds layout and state as CPU data. Actual rendering is
done via `luna.graphics` draw calls issued by `lua_api/gui_api.rs`. No GPU resources here.
## Architecture

```
gui (module root)
  ├── containers.rs — Container and layout widgets: Panel, Layout, ScrollPanel, NinePatch. Containers hold child widgets and optionally apply layout rules to them. [`Panel`] is the simplest container.  [`Layout`] adds flexbox-inspired positioning (horizontal, vertical, grid).  [`ScrollPanel`] provides a scrollable viewport.  [`NinePatch`] computes nine-slice rectangles for scalable panel borders.
  ├── context.rs — Root widget tree, focus tracking, toast queue, and input routing. [`GuiContext`] is the central coordinator for the GUI system.  It owns a flat pool of type-erased widgets (stored as [`WidgetKind`] enum variants), tracks which widget has keyboard focus, manages a queue of active [`Toast`](super::Toast) notifications, and optionally holds a [`Theme`] for styled rendering. Widgets are identified by a `usize` index into the internal `widgets` vector.  The root panel is always at index `0`.  Container widgets (`Panel`, `Layout`, `ScrollPanel`) store their children's indices. Input events are forwarded from Lua callbacks and dispatched to the widget tree by hit-testing against widget bounds.
  ├── controls.rs — Interactive and display control widgets. This sub-module provides the leaf-level widgets that users interact with or read information from: [`Button`], [`Label`], [`TextInput`], [`CheckBox`], [`Slider`], [`ProgressBar`], [`ComboBox`], [`ListBox`], and [`TabBar`].  Each widget embeds a [`WidgetBase`](super::WidgetBase) for shared properties and adds type-specific data fields.
  ├── data_graph_renderer.rs — Mathematical function graph and chart renderer. [`GraphRenderer`] manages multiple named data series (line, scatter, bar) and provides viewport ↔ world coordinate mapping for rendering charts in a Luna2D game. The renderer stores pure data — actual draw calls are issued by the Lua wrapper in `graphics_api.rs`.
  ├── extras.rs — Utility widgets: toast notifications, separators, spacers, and tree views. These widgets serve auxiliary UI roles — visual dividers, empty spacing, auto-expiring notification overlays, and collapsible hierarchical trees.
  ├── theme.rs — Per-widget-type, per-state styling system. A [`Theme`] maps `(WidgetType, WidgetState)` pairs to [`WidgetStyle`] records.  When the GUI context draws a widget it looks up the style for the widget's type and current state, falling back to the `Normal` state style if no state-specific entry exists, and finally to a hard-coded default if the type has no theme entry at all. The Lua API exposes `luna.gui.newTheme()`, `theme:setStyle()`, and `luna.gui.setTheme()` so game scripts can fully customise appearance without touching Rust.
  ├── widget.rs — Shared widget base fields, state enum, and type tag. Every concrete widget embeds a [`WidgetBase`] that provides position, size, visibility, enable state, padding, margin, z-order, min/max size constraints, anchor edges, and flexbox layout properties.  The [`WidgetState`] enum models the five visual states a widget can be in (normal, hovered, pressed, focused, disabled), and [`WidgetType`] tags each concrete kind so the theme system can key its style lookup.
```

## Source Files

| File | Purpose |
|------|---------|
| `containers.rs` | Container and layout widgets: Panel, Layout, ScrollPanel, NinePatch. Containers hold child widgets and optionally apply layout rules to them. [`Panel`] is the simplest container.  [`Layout`] adds flexbox-inspired positioning (horizontal, vertical, grid).  [`ScrollPanel`] provides a scrollable viewport.  [`NinePatch`] computes nine-slice rectangles for scalable panel borders. |
| `context.rs` | Root widget tree, focus tracking, toast queue, and input routing. [`GuiContext`] is the central coordinator for the GUI system.  It owns a flat pool of type-erased widgets (stored as [`WidgetKind`] enum variants), tracks which widget has keyboard focus, manages a queue of active [`Toast`](super::Toast) notifications, and optionally holds a [`Theme`] for styled rendering. Widgets are identified by a `usize` index into the internal `widgets` vector.  The root panel is always at index `0`.  Container widgets (`Panel`, `Layout`, `ScrollPanel`) store their children's indices. Input events are forwarded from Lua callbacks and dispatched to the widget tree by hit-testing against widget bounds. |
| `controls.rs` | Interactive and display control widgets. This sub-module provides the leaf-level widgets that users interact with or read information from: [`Button`], [`Label`], [`TextInput`], [`CheckBox`], [`Slider`], [`ProgressBar`], [`ComboBox`], [`ListBox`], and [`TabBar`].  Each widget embeds a [`WidgetBase`](super::WidgetBase) for shared properties and adds type-specific data fields. |
| `data_graph_renderer.rs` | Mathematical function graph and chart renderer. [`GraphRenderer`] manages multiple named data series (line, scatter, bar) and provides viewport ↔ world coordinate mapping for rendering charts in a Luna2D game. The renderer stores pure data — actual draw calls are issued by the Lua wrapper in `graphics_api.rs`. |
| `extras.rs` | Utility widgets: toast notifications, separators, spacers, and tree views. These widgets serve auxiliary UI roles — visual dividers, empty spacing, auto-expiring notification overlays, and collapsible hierarchical trees. |
| `theme.rs` | Per-widget-type, per-state styling system. A [`Theme`] maps `(WidgetType, WidgetState)` pairs to [`WidgetStyle`] records.  When the GUI context draws a widget it looks up the style for the widget's type and current state, falling back to the `Normal` state style if no state-specific entry exists, and finally to a hard-coded default if the type has no theme entry at all. The Lua API exposes `luna.gui.newTheme()`, `theme:setStyle()`, and `luna.gui.setTheme()` so game scripts can fully customise appearance without touching Rust. |
| `widget.rs` | Shared widget base fields, state enum, and type tag. Every concrete widget embeds a [`WidgetBase`] that provides position, size, visibility, enable state, padding, margin, z-order, min/max size constraints, anchor edges, and flexbox layout properties.  The [`WidgetState`] enum models the five visual states a widget can be in (normal, hovered, pressed, focused, disabled), and [`WidgetType`] tags each concrete kind so the theme system can key its style lookup. |

## Submodules

### `gui::containers`

Container and layout widgets: Panel, Layout, ScrollPanel, NinePatch. Containers hold child widgets and optionally apply layout rules to them. [`Panel`] is the simplest container.  [`Layout`] adds flexbox-inspired positioning (horizontal, vertical, grid).  [`ScrollPanel`] provides a scrollable viewport.  [`NinePatch`] computes nine-slice rectangles for scalable panel borders.

- **`Panel`** (struct): TODO: one-line description.
- **`Layout`** (struct): TODO: one-line description.
- **`ScrollPanel`** (struct): TODO: one-line description.
- **`NinePatch`** (struct): TODO: one-line description.
- **`GUIWindow`** (struct): TODO: one-line description.
- **`SplitPanel`** (struct): TODO: one-line description.
- **`DockPanel`** (struct): TODO: one-line description.
- **`LayoutDirection`** (enum): TODO: one-line description.

### `gui::context`

Root widget tree, focus tracking, toast queue, and input routing. [`GuiContext`] is the central coordinator for the GUI system.  It owns a flat pool of type-erased widgets (stored as [`WidgetKind`] enum variants), tracks which widget has keyboard focus, manages a queue of active [`Toast`](super::Toast) notifications, and optionally holds a [`Theme`] for styled rendering. Widgets are identified by a `usize` index into the internal `widgets` vector.  The root panel is always at index `0`.  Container widgets (`Panel`, `Layout`, `ScrollPanel`) store their children's indices. Input events are forwarded from Lua callbacks and dispatched to the widget tree by hit-testing against widget bounds.

- **`GuiContext`** (struct): TODO: one-line description.
- **`WidgetKind`** (enum): TODO: one-line description.

### `gui::controls`

Interactive and display control widgets. This sub-module provides the leaf-level widgets that users interact with or read information from: [`Button`], [`Label`], [`TextInput`], [`CheckBox`], [`Slider`], [`ProgressBar`], [`ComboBox`], [`ListBox`], and [`TabBar`].  Each widget embeds a [`WidgetBase`](super::WidgetBase) for shared properties and adds type-specific data fields.

- **`Button`** (struct): TODO: one-line description.
- **`Label`** (struct): TODO: one-line description.
- **`TextInput`** (struct): TODO: one-line description.
- **`CheckBox`** (struct): TODO: one-line description.
- **`Slider`** (struct): TODO: one-line description.
- **`ProgressBar`** (struct): TODO: one-line description.
- **`ComboBox`** (struct): TODO: one-line description.
- **`ListBox`** (struct): TODO: one-line description.
- **`TabBar`** (struct): TODO: one-line description.
- **`RadioButton`** (struct): TODO: one-line description.
- **`ScrollBar`** (struct): TODO: one-line description.

### `gui::data_graph_renderer`

Mathematical function graph and chart renderer. [`GraphRenderer`] manages multiple named data series (line, scatter, bar) and provides viewport ↔ world coordinate mapping for rendering charts in a Luna2D game. The renderer stores pure data — actual draw calls are issued by the Lua wrapper in `graphics_api.rs`.

- **`GraphRenderer`** (struct): TODO: one-line description.
- **`GraphSeries`** (enum): TODO: one-line description.

### `gui::extras`

Utility widgets: toast notifications, separators, spacers, and tree views. These widgets serve auxiliary UI roles — visual dividers, empty spacing, auto-expiring notification overlays, and collapsible hierarchical trees.

- **`Toast`** (struct): TODO: one-line description.
- **`Separator`** (struct): TODO: one-line description.
- **`Spacer`** (struct): TODO: one-line description.
- **`TreeNode`** (struct): TODO: one-line description.
- **`TreeView`** (struct): TODO: one-line description.
- **`ToolbarButton`** (struct): TODO: one-line description.
- **`Toolbar`** (struct): TODO: one-line description.
- **`MenuBar`** (struct): TODO: one-line description.
- **`MenuItem`** (struct): TODO: one-line description.
- **`Dialog`** (struct): TODO: one-line description.
- **`StatusBar`** (struct): TODO: one-line description.
- **`AccordionSection`** (struct): TODO: one-line description.
- **`Accordion`** (struct): TODO: one-line description.
- **`TooltipPanel`** (struct): TODO: one-line description.
- **`ColorPicker`** (struct): TODO: one-line description.
- **`TableColumn`** (struct): TODO: one-line description.
- **`GUITable`** (struct): TODO: one-line description.
- **`ImageWidget`** (struct): TODO: one-line description.

### `gui::theme`

Per-widget-type, per-state styling system. A [`Theme`] maps `(WidgetType, WidgetState)` pairs to [`WidgetStyle`] records.  When the GUI context draws a widget it looks up the style for the widget's type and current state, falling back to the `Normal` state style if no state-specific entry exists, and finally to a hard-coded default if the type has no theme entry at all. The Lua API exposes `luna.gui.newTheme()`, `theme:setStyle()`, and `luna.gui.setTheme()` so game scripts can fully customise appearance without touching Rust.

- **`WidgetStyle`** (struct): TODO: one-line description.
- **`Theme`** (struct): TODO: one-line description.

### `gui::widget`

Shared widget base fields, state enum, and type tag. Every concrete widget embeds a [`WidgetBase`] that provides position, size, visibility, enable state, padding, margin, z-order, min/max size constraints, anchor edges, and flexbox layout properties.  The [`WidgetState`] enum models the five visual states a widget can be in (normal, hovered, pressed, focused, disabled), and [`WidgetType`] tags each concrete kind so the theme system can key its style lookup.

- **`WidgetBase`** (struct): TODO: one-line description.
- **`WidgetState`** (enum): TODO: one-line description.
- **`WidgetType`** (enum): TODO: one-line description.

## Key Types

### Structs

#### `gui::containers::Panel`

TODO: description from `///` doc comment.

#### `gui::containers::Layout`

TODO: description from `///` doc comment.

#### `gui::containers::ScrollPanel`

TODO: description from `///` doc comment.

#### `gui::containers::NinePatch`

TODO: description from `///` doc comment.

#### `gui::containers::GUIWindow`

TODO: description from `///` doc comment.

#### `gui::containers::SplitPanel`

TODO: description from `///` doc comment.

#### `gui::containers::DockPanel`

TODO: description from `///` doc comment.

#### `gui::context::GuiContext`

TODO: description from `///` doc comment.

#### `gui::controls::Button`

TODO: description from `///` doc comment.

#### `gui::controls::Label`

TODO: description from `///` doc comment.

#### `gui::controls::TextInput`

TODO: description from `///` doc comment.

#### `gui::controls::CheckBox`

TODO: description from `///` doc comment.

#### `gui::controls::Slider`

TODO: description from `///` doc comment.

#### `gui::controls::ProgressBar`

TODO: description from `///` doc comment.

#### `gui::controls::ComboBox`

TODO: description from `///` doc comment.

#### `gui::controls::ListBox`

TODO: description from `///` doc comment.

#### `gui::controls::TabBar`

TODO: description from `///` doc comment.

#### `gui::controls::RadioButton`

TODO: description from `///` doc comment.

#### `gui::controls::ScrollBar`

TODO: description from `///` doc comment.

#### `gui::data_graph_renderer::GraphRenderer`

TODO: description from `///` doc comment.

#### `gui::extras::Toast`

TODO: description from `///` doc comment.

#### `gui::extras::Separator`

TODO: description from `///` doc comment.

#### `gui::extras::Spacer`

TODO: description from `///` doc comment.

#### `gui::extras::TreeNode`

TODO: description from `///` doc comment.

#### `gui::extras::TreeView`

TODO: description from `///` doc comment.

#### `gui::extras::ToolbarButton`

TODO: description from `///` doc comment.

#### `gui::extras::Toolbar`

TODO: description from `///` doc comment.

#### `gui::extras::MenuBar`

TODO: description from `///` doc comment.

#### `gui::extras::MenuItem`

TODO: description from `///` doc comment.

#### `gui::extras::Dialog`

TODO: description from `///` doc comment.

#### `gui::extras::StatusBar`

TODO: description from `///` doc comment.

#### `gui::extras::AccordionSection`

TODO: description from `///` doc comment.

#### `gui::extras::Accordion`

TODO: description from `///` doc comment.

#### `gui::extras::TooltipPanel`

TODO: description from `///` doc comment.

#### `gui::extras::ColorPicker`

TODO: description from `///` doc comment.

#### `gui::extras::TableColumn`

TODO: description from `///` doc comment.

#### `gui::extras::GUITable`

TODO: description from `///` doc comment.

#### `gui::extras::ImageWidget`

TODO: description from `///` doc comment.

#### `gui::theme::WidgetStyle`

TODO: description from `///` doc comment.

#### `gui::theme::Theme`

TODO: description from `///` doc comment.

#### `gui::widget::WidgetBase`

TODO: description from `///` doc comment.

### Enums

#### `gui::containers::LayoutDirection`

TODO: description from `///` doc comment.

#### `gui::context::WidgetKind`

TODO: description from `///` doc comment.

#### `gui::data_graph_renderer::GraphSeries`

TODO: description from `///` doc comment.

#### `gui::widget::WidgetState`

TODO: description from `///` doc comment.

#### `gui::widget::WidgetType`

TODO: description from `///` doc comment.

## Lua API

Exposed under `luna.gui.*` by `src\lua_api\gui_api.rs`.

TODO: Describe the overall API surface. List the major categories of functions.

Exposed functions include: `addToast`, `clearFocus`, `focusNext`, `focusPrev`, `getFocus`, `getRoot`, `getTheme`, `getToastCount`, `getWidgetCount`, `gui`, `keypressed`, `mousemoved`, `mousepressed`, `mousereleased`, `newAccordion`, `newButton`, `newCheckbox`, `newColorPicker`, `newComboBox`, `newDialog`, `newDockPanel`, `newImageWidget`, `newLabel`, `newLayout`, `newList`, `newMenuBar`, `newMenuItem`, `newNinePatch`, `newPanel`, `newProgressBar`, `newRadioButton`, `newScrollBar`, `newScrollPanel`, `newSeparator`, `newSlider`, `newSpacer`, `newSplitPanel`, `newStatusBar`, `newTabBar`, `newTable`, `newTextInput`, `newTheme`, `newToast`, `newToolbar`, `newTooltipPanel`, `newTreeView`, `newWindow`, `setFocus`, `setTheme`, `textinput`, `update`, `wheelmoved`.

## Lua Examples

```lua
-- Example: Basic gui usage
function luna.load()
    -- TODO: replace with real gui setup
    local obj = luna.gui.addToast()
end

function luna.update(dt)
    -- TODO: update logic
end
```

## Item Summary

| Kind | Count |
|------|-------|
| `struct` | 41 |
| `enum`   | 5 |
| `fn`     | 0 |
| **Total** | **46** |

## References

| Module | Relationship | Notes |
|--------|--------------|-------|
| `engine` | Imports from | Uses SharedState, EngineError |
| `math` | Imports from | Vec2, Color, Rect |
| `lua_api` | Imported by | Binds public API to Lua |

TODO: Add entries for similar modules and explain the separation of duties.

## Notes

TODO: Document unique facts an agent must know before editing this module:
- External crate constraints (version, thread-safety, API limitations)
- Hardware or OS-specific behaviour (e.g., headless fallback on CI)
- Known limitations or intentional omissions
- Best practices and anti-patterns for this module
- What Lua scripts will break if the API changes
