# ui

## General Info

- Module group: `Feature Systems`
- Source path: `src/ui/`
- Binding: `src/lua_api/ui_api.rs`
- Namespace: `lurek.ui`
- Lua API surface: `91` functions, `44` types, `338` methods
- Rust test path(s): tests/rust/unit/gui_tests.rs
- Lua test path(s): tests/lua/unit/test_gui.lua, tests/lua/unit/test_ui_input_unit.lua, tests/lua/unit/test_ui_layout.lua, tests/lua/integration/test_i18n_ui.lua

## Summary

Designed for both engine tooling and in-game interfaces, it centers around the `GuiContext`, which manages the stateful widget tree, focus navigation, input routing, and rendering lifecycle. The framework offers an extensive library of over 35 distinct widget types, ranging from core controls (Buttons, Labels, TextInputs, Checkboxes, Sliders, ComboBoxes, ProgressBars) to advanced layout containers (ScrollPanels, SplitPanels, DockPanels) and specialized extras (TreeViews, Toolbars, Menus, Accordions, ColorPickers). All widgets embed a shared `WidgetBase` that handles layout parameters, visibility, anchoring, and transitions.

At the structural level, the module employs a robust flex-based layout engine (`Layout`) that supports vertical, horizontal, and grid packing, alongside alignment, spacing, padding, and min/max constraints. Layouts can be constructed programmatically in Lua or loaded dynamically from declarative TOML files using the built-in layout loader, which dramatically accelerates UI iteration. The visual presentation is governed by a flexible `Theme` system that maps widget states (Normal, Hovered, Pressed, Focused, Disabled) to specific styles containing color palettes, font overrides, borders, and shadows. The module natively supports resolution-independent 9-slice borders (`NinePatch`) and per-widget transition animations (alpha fades, position slides) to deliver a polished, responsive user experience.

Beyond standard UI components and input routing, the module integrates powerful data binding tools. The `GUITable` seamlessly integrates with the `dataframe` module, enabling bulk loading of structured rows directly into UI views without expensive Lua-side iterations. Fully exposed through the `lurek.ui.*` API, this module equips developers with everything needed to build intricate developer dashboards, complex menus, and data-rich game interfaces.

## Files

### [containers.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ui/containers.rs)

- This file provides retained-mode UI containers that structure complex screen hierarchies.
- It defines panels, layouts, windows, splits, and docks as composable spatial building blocks.
- It drives vertical, horizontal, and grid arrangement with stable spacing and alignment rules.
- It supplies scrollable viewports for overflowed content without breaking parent layout flow.
- It supports nine-slice framing so scalable borders keep visual intent across resolutions.
- It enables draggable and resizable window shells for tool-like and in-game interface scenes.
- It anchors container semantics that other widgets rely on for predictable composition.

### [context.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ui/context.rs)

- This file provides the central retained-mode UI context that owns widget state and lifecycle.
- It stores all widget variants in one indexed arena so references stay compact and stable.
- It runs recursive layout to compute absolute rectangles from parent-relative placement data.
- It manages focus traversal and keyboard navigation for consistent interaction behavior.
- It routes mouse and key events through controlled dispatch paths tied to active widgets.
- It drives drag-and-drop with safety checks that prevent invalid parent-child cycles.
- It advances alpha and position transitions so UI motion remains smooth and deterministic.
- It maintains data bindings that synchronize widget values with script-owned state keys.
- It tracks render signatures to detect dirtiness without expensive full-tree comparisons.
- It queues interface events so Lua can consume interactions in a frame-coherent order.
- It handles toast overlay lifetimes and visibility as transient UI feedback primitives.
- It maintains root-level viewport and scaling context used by layout and rendering passes.
- It exposes creation and lookup surfaces that keep widget graph mutations predictable.
- It centralizes ownership so memory, input, and animation behavior are coordinated.
- It forms the contract boundary between UI data, behavior, and visual output.
- It keeps high-volume interface updates efficient enough for runtime and tooling screens.
- It enables complex widget ecosystems while preserving one coherent execution timeline.
- It anchors the entire UI subsystem around deterministic per-frame state progression.

### [controls.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ui/controls.rs)

- This file provides the concrete interactive controls used by the retained-mode UI layer.
- It defines buttons, text inputs, toggles, selectors, and numeric widgets with shared behavior.
- It embeds common widget base state so style, layout, and interaction remain consistent.
- It validates and clamps editable values to enforce reliable control invariants.
- It normalizes selection behavior when list-like data mutates at runtime.
- It keeps control construction explicit so type identity is always unambiguous.
- It supports snapshot-friendly cloning for tooling, testing, and reversible operations.
- It packages core interaction primitives in one predictable and reusable control set.
- It establishes stable semantics for input-heavy interfaces across gameplay and tools.
- It forms the practical interaction surface most UI scripts build on top of.

### [data_graph_renderer.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ui/data_graph_renderer.rs)

- This file provides the data graph renderer used for chart-like UI visualization surfaces.
- It supports multiple series forms so lines, points, and bars share one rendering core.
- It maps graph space to screen space with reversible coordinate conversion helpers.
- It computes automatic ranges so diverse datasets fit cleanly into constrained viewports.
- It serves both runtime HUD analytics and editor-facing diagnostic chart panels.
- It keeps chart rendering behavior consistent across tooling and in-game dashboards.

### [extras.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ui/extras.rs)

- This file provides the extended widget set that goes beyond baseline UI control primitives.
- It defines overlays, trees, menus, toolbars, dialogs, grids, and feedback-oriented elements.
- It supports rich interaction patterns such as accordions, tooltips, and modal UI workflows.
- It includes color and data-oriented widgets for editor-like and analytics-heavy interfaces.
- It models hierarchical trees and menu structures in forms suitable for retained updates.
- It supplies status and notification components that communicate system state to players.
- It keeps advanced widgets aligned with shared base style and layout semantics.
- It provides custom widget shells for script-driven rendering and bespoke interactions.
- It enables dense information surfaces without leaving the core retained UI ecosystem.
- It expands UI expressiveness while keeping integration with context and renderer coherent.
- It supports practical tool-building needs alongside in-game menu and HUD requirements.
- It rounds out the module with specialized pieces required for full product interfaces.

### [layout_loader.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ui/layout_loader.rs)

- This file provides declarative UI loading from TOML definitions into live widget trees.
- It maps textual widget kinds onto concrete context constructors with consistent defaults.
- It applies generic and type-specific properties so authored layouts become runtime-ready.
- It supports recursive child structures that mirror retained parent-child composition.
- It offers headless image rendering for snapshot checks and offline layout verification.
- It enables fast iteration on UI structure without hardcoding full trees in Lua scripts.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ui/mod.rs)

- This module delivers the full retained UI toolkit used by gameplay and tooling layers.
- It combines context, widgets, containers, rendering, and theming into one coherent surface.
- It keeps interface construction flexible through code-first and data-driven layout paths.

### [render.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ui/render.rs)

- This file provides UI render emission for GPU commands and headless pixel raster outputs.
- It draws the full retained widget catalog with consistent visual behavior across states.
- It resolves theme style data per widget and applies alpha-aware color composition.
- It emits shared primitives for shadows, fills, borders, gradients, and highlights.
- It handles control-specific visuals such as sliders, checks, radios, combos, and switches.
- It renders hierarchical content like trees and menus while preserving structural readability.
- It supports color-picker internals with hue-space conversion used during visual generation.
- It threads context, font, and output carriers through one deterministic render traversal.
- It merges generic and type-specific child sources so nested widgets render in correct order.
- It measures and aligns text with active font context to keep typography placement stable.
- It supports CPU fallback output for screenshots, tests, and non-GPU verification paths.
- It keeps rendering logic centralized so visual changes remain coherent and maintainable.
- It scales from lightweight HUDs to complex tool panels using one render architecture.
- It preserves deterministic draw command shape for regression checks and diagnostics.
- It bridges widget semantics to backend draw primitives without leaking UI internals.
- It supports theme-driven look changes without requiring widget logic rewrites.
- It maintains robust rendering behavior under dynamic UI mutation each frame.
- It anchors the visual execution layer of the retained UI subsystem.

### [theme.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ui/theme.rs)

- This file provides the theming system that maps widget type and state to visual style data.
- It stores colors, typography, borders, shadows, gradients, and alignment in reusable records.
- It resolves requested styles with controlled fallback so partial themes remain functional.
- It ships practical defaults that cover standard widgets without requiring custom setup.
- It keeps style records clonable for cheap per-screen forks and variation experiments.
- It supports semantic theme tokens so shared visual meanings stay consistent across widgets.
- It integrates directly with render-time style resolution inside the UI drawing pipeline.
- It includes debug-oriented raster helpers for quick visual verification of style states.
- It enables extension through custom type-state registrations without changing core presets.
- It separates visual policy from interaction logic for cleaner UI architecture boundaries.
- It supports rapid skin iteration while preserving stable widget behavior contracts.
- It keeps style lookup deterministic so rendering output stays predictable across frames.
- It provides one source of truth for interface look-and-feel in the module.
- It allows games and tools to share a common style backbone with targeted overrides.
- It anchors maintainable visual customization across the retained UI ecosystem.

### [widget.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ui/widget.rs)

- This file provides core widget primitives that define shared UI node state and semantics.
- It models layout metrics, style linkage, identity, and interaction flags per widget instance.
- It represents the tree unit that context, layout, and renderer pipelines operate on.
- It supports state transitions that drive hover, focus, press, and animated visual behavior.
- It keeps parent-child composition explicit so traversal and ownership rules remain stable.
- It anchors type and state enums used across all concrete control and container variants.
- It enables consistent text alignment and font override behavior at the widget boundary.
- It provides reusable base data that reduces duplication across the larger UI catalog.
- It ensures widget-level contracts remain predictable for script and engine integrations.
- It defines the structural vocabulary that the retained UI subsystem builds upon.
