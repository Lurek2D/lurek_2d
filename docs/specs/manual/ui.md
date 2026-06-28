# ui manual spec overlay

## TL;DR

- Centralized retained-mode UI context with arena storage, automatic layouts, and resolution scaling.
- Rich control catalog featuring standard inputs, numeric steppers, combo selections, and visual containers.
- Layout-manager containers cover vertical boxes, horizontal boxes, grids, margin/padding wrappers, centering, scroll regions, split regions, stacks, and tabbed page containers.
- Property inspector widget for grouped name/value rows with collapsible sections and predefined value editors.
- Supports resizable window shells, modal dialog triggers, and nine-slice border-stretching layouts.
- Declarative TOML layouts, semantic theme tokens, alpha-aware animations, and drag-and-drop event dispatching.
- Integrates retained widgets, theme/layout flows, and headless screenshot exports.

## Summary

- The `ui` module is the engine's retained-interface system for users who want menus, HUDs, editors, overlays, and tool panels to behave like one persistent application layer instead of a loose pile of draw calls and ad hoc click tests.
- Its core promise is continuity across frames. The UI context remembers widget identity, parent-child structure, focus, hover, active state, capture, bindings, transitions, and pending events, so a screen can evolve over time without losing the state that makes it feel interactive and stable.
- This retained model matters because large interfaces are rarely redrawn from pure stateless logic. Text inputs need cursors and selection, lists need scroll position, windows need placement, trees need expansion state, and complex panels need to survive temporary data changes without resetting user intent.
- Container widgets define the structural grammar of the module. Panels, windows, stacks, docks, split regions, scroll containers, frames, and nine-slice shells let projects assemble larger interface layouts from composable blocks rather than hand-managing every rectangle.
- Basic controls sit on top of that structure as first-class runtime widgets. Buttons, labels, checkboxes, sliders, text boxes, radio groups, combo boxes, lists, tabs, steppers, toggles, and status displays all share the same identity, event, and style model.
- Property widgets cover editor-style inspector panels where a script or TOML layout needs a left-hand property name, a right-hand value, predefined editor semantics such as text/number/bool/select/color, and collapsible groups that can hide advanced settings without rebuilding the widget tree.
- The `extras` surface pushes the module past ordinary menus into more tool-like workflows by covering dialogs, menus, tree views, inspectors, status bars, toasts, overlays, and richer dashboard-oriented pieces that are common in internal tools and game editors.
- Declarative layout loading from TOML is one of the most important user-facing capabilities because it means interface structure can be authored as content. Teams can describe screens in data, instantiate them into live widgets, and still use the same event, style, and binding behavior as hand-written UI.
- For inspector-style tools, TOML can define property widget groups and rows directly, so configuration panels can live as content while Lua remains responsible for runtime value updates and callbacks.
- Styling is not a thin afterthought. Themes, classes, semantic colors, spacing, typography, borders, fills, corner treatment, widget states, and transition-friendly variants all live inside one coherent theme system so several screens can share a recognizable visual language.
- Layout calculation is another central responsibility. The module resolves requested size, parent constraints, alignment, padding, spacing, scrolling, overflow, clipping, stacking order, and viewport-aware placement into concrete geometry so widgets can be reasoned about structurally instead of geometrically line by line.
- Layout-manager constructors expose the common screen-structure vocabulary directly: `newVBoxContainer`, `newHBoxContainer`, `newGridContainer`, `newMarginContainer`, `newCenterContainer`, `newScrollContainer`, `newSplitContainer`, `newStackContainer`, and `newTabContainer`. These names mirror the way users think about menu columns, HUD rows, inventory grids, safe-area padding, centered dialogs, scrollable lists, resizable panes, layered views, and settings tabs.
- `Layout` remains the underlying owner for box, grid, margin, and center behavior, so spacing, padding, alignment, justification, flex grow, and child margins stay on one code path instead of fragmenting into one-off containers.
- `StackContainer` and `TabContainer` own page selection. They keep all child pages in the retained tree while the layout pass marks only the active child as effectively visible, which lets hidden pages preserve state without being drawn or hit-tested as active content.
- `SplitPanel` owns two explicit child slots and divides its content rectangle in the layout pass with a clamped split fraction and minimum panel size, making dockable editor-style panes layout-managed rather than manually positioned.
- Scroll regions, nested containers, resizable panels, and dock-like arrangements are important examples of why layout belongs here: they require persistent bookkeeping and cross-widget coordination that would become brittle if each feature implemented its own layout rules.
- Input routing is part of the same authority. Mouse, keyboard, controller-like activation, focus traversal, drag, drop, text entry, pointer capture, and event bubbling all flow through the UI context so the entire screen obeys one interaction model.
- Binding support turns UI from a decorative layer into a practical application surface. Widgets can synchronize with script-visible values, settings models, editor records, or runtime debug state without every screen inventing its own plumbing for reads, writes, and synchronization.
- That makes the module useful for options menus, save slots, inventory panels, runtime profilers, asset inspectors, conversation UIs, mission journals, or modding tools where visible controls need reliable two-way data flow.
- Transition support matters because retained UI should still feel alive. Alpha fades, motion offsets, highlight ramps, show-hide behavior, and state-based animation can advance inside the same widget runtime instead of being bolted on as unrelated per-screen tween code.
- Rendering support keeps the module viable in both normal gameplay and tooling contexts. The same resolved widget tree can be drawn into the live frame, directed to overlays, or exported through headless paths for screenshots, docs, regression tests, and proof artifacts.
- The module also serves as a coordination layer between neighboring systems. `input` contributes raw control state, `render` turns resolved draw commands into pixels, `font` and `image` provide assets, and game systems provide data, but `ui` owns how those pieces become one coherent interface runtime.
- Accessibility-like concerns such as focus order, keyboard navigation, readable state transitions, and predictable interaction semantics also belong naturally here because a retained UI system is only useful if complex screens remain operable and legible under several input styles.
- That retained model is especially valuable for editor-style surfaces, where selection, docking, inspectors, and scroll state must survive incremental content changes.
- It also gives testing and evidence workflows a stable target, because headless captures can reflect the same widget resolution and theme rules as the live runtime.
- Data-driven layouts and retained state work well together here: authored screen structure can evolve without discarding the persistent interaction model behind it.
- This is what lets the module cover both simple menus and large tool workspaces without switching to a different UI paradigm halfway through a project.
- The module is therefore not only a widget library but also a screen-architecture system. It gives projects a stable way to build interfaces that can grow from a few controls to full editors, dashboards, and data-heavy tool surfaces without changing mental models.
- For wiki readers, the practical boundary is clear: if a feature is about widget identity, composition, style, layout, focus, event dispatch, data binding, or retained state over time, it belongs to `ui` even when another system supplies the data being shown.
- Read `ui` as the engine's main authority for structured interactive surfaces. It is the module that makes screens persistent, composable, themeable, testable, and interoperable, whether the result is a simple pause menu or a full internal editor workspace.

This module primarily collaborates with `dataframe`, `image`, `math`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Notes

- `LUiWidget:setShader` and `LUiWidget:setShaderLayer` accept only `ui` shaders created through `lurek.render.newShader`. UI stores `ShaderKey` bindings on retained widget state; WGSL validation, pipeline creation, fallback, and GPU execution remain owned by `render`.
- `lurek.ui.draw()` queues retained widget render commands before invoking custom draw callbacks. Widget shader bindings affect that live render-command path and are inherited by child widgets until overridden by a child shader.
- `lurek.ui.drawToImage` and `lurek.ui.renderToImage` remain deterministic software preview/export paths and do not execute GPU shaders.

## Architecture Links

- Intentionally empty.
