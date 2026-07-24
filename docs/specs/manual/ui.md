# ui manual spec overlay

## TL;DR

- Centralized retained-mode UI context with generational widget handles, automatic layouts, and resolution scaling.
- Rich control catalog featuring standard inputs, multi-line text areas, rich labels, numeric steppers, combo selections, and visual containers.
- Layout-manager containers cover vertical boxes, horizontal boxes, grids, margin/padding wrappers, centering, scroll regions, split regions, aspect-ratio slots, stacks, and tabbed page containers.
- Property inspector widget for grouped name/value rows with collapsible sections and predefined value editors.
- Supports resizable window shells, modal dialog triggers, and nine-slice border-stretching layouts.
- Declarative TOML layouts, semantic theme tokens, alpha-aware animations, and drag-and-drop event dispatching.
- Integrates retained widgets, theme/layout flows, and headless screenshot exports.

## Summary

- The `ui` module is the engine's retained-interface system for users who want menus, HUDs, editors, overlays, and tool panels to behave like one persistent application layer instead of a loose pile of draw calls and ad hoc click tests.
- Its core promise is continuity across frames. The UI context remembers widget identity, parent-child structure, focus, hover, active state, capture, bindings, transitions, and pending events, so a screen can evolve over time without losing the state that makes it feel interactive and stable.
- This retained model matters because large interfaces are rarely redrawn from pure stateless logic. Text inputs need cursors and selection, lists need scroll position, windows need placement, trees need expansion state, and complex panels need to survive temporary data changes without resetting user intent.
- Container widgets define the structural grammar of the module. Panels, windows, stacks, docks, split regions, scroll containers, frames, and nine-slice shells let projects assemble larger interface layouts from composable blocks rather than hand-managing every rectangle.
- Basic controls sit on top of that structure as first-class runtime widgets. Buttons, labels, rich labels, checkboxes, sliders, text boxes, text areas, radio groups, combo boxes, lists, tabs, steppers, toggles, and status displays all share the same identity, event, and style model.
- Property widgets cover editor-style inspector panels where a script or TOML layout needs a left-hand property name, a right-hand value, predefined editor semantics such as text/number/bool/select/color, and collapsible groups that can hide advanced settings without rebuilding the widget tree.
- The `extras` surface pushes the module past ordinary menus into more tool-like workflows by covering dialogs, menus, tree views, inspectors, status bars, toasts, overlays, and richer dashboard-oriented pieces that are common in internal tools and game editors.
- Declarative layout loading from TOML is one of the most important user-facing capabilities because it means interface structure can be authored as content. Teams can describe screens in data, instantiate them into live widgets, and still use the same event, style, and binding behavior as hand-written UI.
- For inspector-style tools, TOML can define property widget groups and rows directly, so configuration panels can live as content while Lua remains responsible for runtime value updates and callbacks.
- TOML layouts expose Godot-inspired control metadata such as `style_class`, `mouse_filter`, `z_order`, `tab_index`, `focus_group`, `focus_neighbors`, `role`, `aria_name`, `label_for`, `bind`, and anchor fields, with id references resolved after the widget tree is instantiated.
- Data-heavy widgets can now be populated declaratively: combo boxes, list boxes, and tab bars accept `items`, tables accept `columns` and `rows`, and tree views accept `nodes`, while legacy pipe-delimited `text` remains a compatibility path for combo/list/tab widgets.
- Styling is not a thin afterthought. Themes, classes, semantic colors, spacing, typography, borders, fills, corner treatment, widget states, and transition-friendly variants all live inside one coherent theme system so several screens can share a recognizable visual language.
- Layout calculation is another central responsibility. The module resolves requested size, parent constraints, alignment, padding, spacing, scrolling, overflow, clipping, stacking order, and viewport-aware placement into concrete geometry so widgets can be reasoned about structurally instead of geometrically line by line.
- Layout-manager constructors expose the common screen-structure vocabulary directly: `newVBoxContainer`, `newHBoxContainer`, `newGridContainer`, `newMarginContainer`, `newCenterContainer`, `newScrollContainer`, `newSplitContainer`, `newStackContainer`, and `newTabContainer`. These names mirror the way users think about menu columns, HUD rows, inventory grids, safe-area padding, centered dialogs, scrollable lists, resizable panes, layered views, and settings tabs.
- `Layout` remains the underlying owner for box, grid, margin, and center behavior, so spacing, padding, alignment, justification, flex grow, and child margins stay on one code path instead of fragmenting into one-off containers.
- `StackContainer` and `TabContainer` own page selection. They keep all child pages in the retained tree while the layout pass marks only the active child as effectively visible, which lets hidden pages preserve state without being drawn or hit-tested as active content.
- `SplitPanel` owns two explicit child slots and divides its content rectangle in the layout pass with a clamped split fraction and minimum panel size, making dockable editor-style panes layout-managed rather than manually positioned.
- `AspectRatioContainer` owns the common media-preview case where one child must be fit into a stable aspect rectangle using `contain`, `cover`, or `stretch` behavior.
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

- UI lowers retained widgets into bounded, deterministic `RenderCommand` streams. `render` owns GPU execution and software replay/capture; UI must not add a second pixel rasterizer or GPU/WGSL types. A software capture that cannot represent a command records an explicit render diagnostic rather than silently taking a different UI-specific path.
- Layout state is invalidated by explicit geometry, topology, theme, and viewport changes. Input routing checks that generation before recomputing geometry, so pointer movement over a clean tree does not perform another layout pass.
- Toolbar separators and spacers are retained toolbar items with visible layout semantics. A spacer with an omitted size is flexible; a supplied finite non-negative size is fixed.

- Widget tables carry an engine-owned generational handle. The `_idx` field is diagnostic only; APIs that accept widget references require the live widget table and reject forged, destroyed, or cleared handles.
- `lurek.ui.destroy(widget, recursive?)`, `widget:destroy(recursive?)`, and `lurek.ui.clear()` remove references, focus/capture state, queued events, and registered callbacks before invalidating the affected handles. A stale table reports `isValid() == false` and cannot address a replacement widget.
- UI input, layout, event, and render queues are bounded by trusted `UiLimits` ceilings. Layout sources are size-checked and loaded transactionally, with finite numeric fields, collection counts, child counts, and tree depth validated before the live context is committed.
- `lurek.ui.loadLayoutFile` and `lurek.ui.loadLayoutGameFile` read through GameFS. `lurek.ui.renderToImage` writes only through the GameFS save boundary, validates dimensions and encoded size, and commits output through an atomic temporary-file rename.
- Callback dispatch removes an event before invoking Lua and restores it at the front if the callback fails, so a failed callback cannot silently discard later queued events. Safe duplicate change/drag-hover events may coalesce at the queue ceiling; critical events are counted and never evict earlier events.
- `LUiWidget:setShader` and `LUiWidget:setShaderLayer` accept only `ui` shaders created through `lurek.render.newShader`. UI stores `ShaderKey` bindings on retained widget state; WGSL validation, pipeline creation, fallback, and GPU execution remain owned by `render`.
- `lurek.ui.draw()` queues retained widget render commands before invoking custom draw callbacks. Widget shader bindings affect that live render-command path and are inherited by child widgets until overridden by a child shader.
- `lurek.ui.drawToImage` and `lurek.ui.renderToImage` remain deterministic software preview/export paths and do not execute GPU shaders.
- `TextArea`, `RichLabel`, and `AspectRatioContainer` are intentionally pragmatic Godot-inspired additions: they cover multi-line editing, lightweight inline rich text spans, and aspect-ratio child fitting without attempting full Godot parity.

### Trusted `UiLimits` defaults

These ceilings are Rust-side trusted configuration, not Lua-settable knobs. Public entry points reject work above them rather
than clamping or allocating partially: live widgets `8192`, children per widget `1024`, tree depth `128`, layout bytes
`1048576`, strings `65536` bytes, collection items `10000`, queued events `4096`, render commands `100000`, image width
and height `4096`, image pixels `16777216`, encoded image bytes `67108864`, and logical path bytes `512`.

## Architecture Links

- [UI module scope boundary](../../architecture/module-scope-boundaries.md#ui-boundary)
- [Rendering pipeline](../../architecture/render-pipeline.md) owns GPU execution and command capture.
- [Scripting bridge](../../architecture/scripting-bridge.md) owns Lua-side input and GameFS boundary behavior.
- [Runtime tooling boundaries](../../architecture/runtime-tooling-boundaries.md) defines GameFS reads and authorized capture writes.

## Practical journeys

1. Build a root layout, add typed widget handles, and retain the root. A handle is valid only in its creating context; after
   `destroy` or `clear`, use `isValid()` before retaining it in application state.
2. Set sizes and style, then let the UI layout pass resolve logical pixels, clipping, and DPI scaling. Generic geometry stays
   in `layout`; retained composition, theme inheritance, and focusable geometry belong to `ui`.
3. Feed input through the UI context. It resolves hit testing, propagation, capture, focus, text input, and modal blocking
   before queued callbacks run; raw platform input remains owned by `input`.
4. Load declarative layouts through GameFS. Parsing is bounded and transactional: invalid content leaves the existing tree
   untouched. Bind application data at the UI boundary rather than exposing ECS internals to layouts.
5. Render with `ui.draw()` for the live command stream, or use headless capture. Fonts, images, encoding, and GPU shader
   execution remain owned by the `font`, `image`, and `render` modules.
6. Keep table, tree, and list data in the application or dataframe adapter; UI owns only visible rows, selection, scroll,
   expansion, and bounded diagnostic snapshots. Do not expose ECS or storage indexes as widget mutation authority.
7. Inspect diagnostics and accessibility snapshots when scaling a screen. Printable widget IDs help locate state but are
   never accepted as handles; rebuild dynamic subtrees through typed widget references and lifecycle-safe cleanup.

## Compatibility and removals

| Legacy surface | Canonical form | Warning / removal | Migration and proof |
| --- | --- | --- | --- |
| `_idx` or numeric widget references | Opaque typed widget tables | Rejected now; no compatibility window. | Replace numeric arguments with the widget returned by a UI constructor; handle tests prove forged/stale tables fail. |
| `loadLayoutGameFile` | `loadLayoutFile` | Deprecated in 1.1; remove in 1.3. | Mechanical rename; tests keep both loaders behaviorally identical until removal. |
| `renderToImage(path, width, height)` | `renderToImage(width, height, path)` | Deprecated in 1.1; remove in 1.3. | Reorder arguments; unit tests cover both forms until removal. |
| `attachToEntity` / `detachFromEntity` | Scene-owned versioned screen-anchor adapter | Removed in 1.1. | No automated migration: UI never queried ECS/camera state, so callers must supply an explicit screen-position snapshot. |
