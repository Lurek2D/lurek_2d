<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/ui.md or source docstrings instead. -->

# ui

## TL;DR

- Centralized retained-mode UI context with generational widget handles, automatic layouts, and resolution scaling.
- Rich control catalog featuring standard inputs, multi-line text areas, rich labels, numeric steppers, combo selections, and visual containers.
- Layout-manager containers cover vertical boxes, horizontal boxes, grids, margin/padding wrappers, centering, scroll regions, split regions, aspect-ratio slots, stacks, and tabbed page containers.
- Property inspector widget for grouped name/value rows with collapsible sections and predefined value editors.
- Supports resizable window shells, modal dialog triggers, and nine-slice border-stretching layouts.
- Declarative TOML layouts, semantic theme tokens, alpha-aware animations, and drag-and-drop event dispatching.
- Integrates retained widgets, theme/layout flows, and headless screenshot exports.

## General Info

- Module group: `Feature Systems`
- Source path: `src/ui`
- Binding: `src/lua_api/ui_api.rs`
- Namespace: `lurek.ui`
- Lua API surface: `115` functions, `45` types, `395` methods
- User-facing: `true`
- Plugin tier: `tier_1_plugin`

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

## Ownership

- Canonical source: `src/ui`
- Owning tier: `Feature Systems`
- Plugin tier: `tier_1_plugin`
- Lua binding owner: `src/lua_api/ui_api.rs`
- Referenced engine modules: `dataframe`, `font`, `image`, `math`, `render`, `runtime`

## Imports

- `dataframe`: Imports or references `src/dataframe/`. Cross-group dependency from `Feature Systems` into `Foundations`.
- `font`: Imports or references `src/font/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `image`: Imports or references `src/image/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `math`: Imports or references `src/math/`. Cross-group dependency from `Feature Systems` into `Foundations`.
- `render`: Imports or references `src/render/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Feature Systems` into `Core Runtime`.

## Source Files

### containers.rs

- Defines retained layouts, panels, scroll panels, tab bars, split panes, stacks, dock panels, and toolbars.
- Each container owns local direction, selection, scroll bounds, dock placement, and toolbar-entry configuration.
- WidgetBase owns shared geometry, visibility, parent links, and dirty state for every concrete container.
- Context layout and input consume this data, while render paints it and Lua bindings translate validated handles.
- Container types never own tree lifecycle, callback registries, renderer resources, or GameFS authorization.
- Open this file for container defaults and invariants, then trace context passes for interactive behavior.
- Keep child-tree ownership in GuiContext so reparenting, destruction, and cycle rejection stay globally consistent.
- Keep visual command construction in render, allowing these cloneable values to support transactional layout loading.

### context/builders.rs

- Creates concrete retained widgets and appends them to the GuiContext-owned storage in stable creation order.
- Each builder selects a widget type and leaves parenting, layout, callbacks, input, and Lua handles to their owners.
- push_widget enforces the live-widget ceiling before a slot is allocated, giving every factory one shared budget.
- Context lifecycle owns slot invalidation and generational identity; builders expose indices only inside the crate.
- Layout loaders and Lua bindings use these constructors after validation so defaults match across public entry paths.
- Open this file when adding a widget family, changing defaults, or tracing which WidgetKind owns a public factory.

### context/color.rs

- Implements color conversion and interpolation helpers used when GuiContext updates retained widget state.
- Helpers normalize finite channels and preserve the UI 0..1 color convention before rendering reads widget values.
- Theme ownership and paint selection remain in theme and render; this file supplies only context-local transforms.

### context/focus.rs

- Implements focus ownership and traversal for the retained tree, including directional and tab-order navigation.
- It validates live focusable handles, honors explicit neighbors and groups, and clears focus during lifecycle removal.
- Context input decides when an event requests focus; this owner resolves the next eligible widget deterministically.
- Lua bindings expose opaque handles and adapters report consumption, but neither owns focus order or stale repair.
- Modal constraints apply before traversal so background widgets cannot regain authority while a dialog is open.
- Open this file for focus invalidation, explicit-neighbor rules, and the input-to-retained-state boundary.

### context/geometry.rs

- Maintains UI viewport geometry, resolution scaling, and input-layout preparation for retained widget trees.
- It owns viewport dimensions and dirty-layout checks, then delegates concrete placement to GuiContext layout passes.
- Input routing calls these helpers before hit testing so pointer coordinates observe the same rectangles as rendering.
- Lua bindings validate public sizes; this file accepts trusted context mutations and marks layout state dirty.
- Open this file for DPI or viewport changes, coordinate conversion, and the no-relayout fast path used by input dispatch.

### context/input.rs

- Routes pointer, keyboard, text, focus, modal, drag, and capture input through one retained GuiContext event pipeline.
- It owns hit testing and widget-local transitions, then queues GuiEvent values without invoking Lua callbacks directly.
- Resolved rectangles, visibility, clipping, and modal state determine whether a retained widget receives an event.
- Pointer capture and focus are cleared by lifecycle removal before stale widgets can consume input.
- Toolbar, dialog, text editor, selection, and drag helpers preserve deterministic event ordering during state changes.
- Layout preparation uses the geometry fast path so stable pointer movement does not repeatedly recompute the widget tree.
- Raw platform input belongs to adapters; Lua callback execution and registry lifetime belong to scripting bindings.
- Open this file for propagation, consumption, focus traversal, IME, modal behavior, and drag-and-drop semantics.
- GuiContext enforces queue ceilings and coalescing, keeping high-frequency input bounded before Lua observes it.
- Rendering reads the resulting widget state in a later pass, so this file deliberately emits no draw commands or pixels.
- Widget-kind branches belong here only when input changes their retained state; visual-only rules stay in render modules.
- Wrong or unsupported user actions are rejected predictably rather than silently mutating unrelated widgets or indexes.
- Tests exercise focus, capture, modal blocking, callback ordering, and destruction during dispatch through public APIs.
- Geometry helpers own coordinate validity; this file maps valid coordinates onto interactive retained widgets.

### context/lifecycle.rs

- Implements widget creation, removal, reparenting, root clear, and generational slot invalidation for GuiContext.
- Removal repairs child links, focus, capture, modal and drag state, and queued references before reuse is possible.
- These routines own tree and handle lifecycle only; layout, input, rendering, and Lua callback dispatch remain separate.
- Public handles resolve here, so stale or foreign values fail instead of accidentally selecting a recycled storage slot.

### context.rs

- Owns GuiContext, the retained UI tree, generational widget identity, event queues, and frame-level state transitions.
- GuiContext coordinates widget storage, parenting, focus, capture, dirty generations, bindings, and diagnostics.
- It owns lifecycle rules for creation, destruction, clear, reparenting, and stale-handle resolution.
- Layout, input, and rendering are separate passes coordinated here so each observes one validated retained tree snapshot.
- Lua bindings hold opaque handles and validate script input, while this module owns the Rust-side state they mutate.
- Child links, modal state, focus, and capture are repaired during removal so destroyed widgets lose authority.
- UiLimits bounds widgets, events, commands, strings, and traversal before costly work reaches the context.
- Context callbacks are registered at the Lua edge, but queued event ordering and coalescing are defined by this owner.
- Layout loaders use transactional builders around this state; failed content must not partially alter a live screen.
- Rendering lowers resolved widgets into commands; image and render modules own pixel output and GPU execution.
- Input adapters supply raw events and receive consumption results; scene or ECS data is not owned by the UI context.
- Open this file for lifecycle invariants, widget-tree rules, event ordering, or cross-pass state coordination.
- Smaller context files contain builders, geometry, and input-specific algorithms to keep this owner navigable.
- This is the primary navigation point when a UI regression crosses lifecycle, layout, input, and rendering boundaries.

### controls.rs

- Defines retained control widgets such as buttons, text inputs, selectors, sliders, and value displays for UI trees.
- Each type owns local value, selection, range, and presentation state while WidgetBase owns geometry and flags.
- Constructors normalize finite ranges and defaults so layout, input, and rendering consume valid control state.
- GuiContext owns tree membership and lifecycle; this file deliberately does not dispatch Lua callbacks or render pixels.
- Lua bindings convert script arguments into these types, while context input mutates them and render reads their state.
- Open this file for control data invariants, default values, selection semantics, and widget-specific state transitions.
- Text editing details remain with the input route, and general layouts remain owned by container and context passes.
- This data model keeps controls cloneable for transactional layout loading and deterministic software captures.
- Public constructors make no external allocation or callback registration, preserving context-owned lifetime rules.
- Neighboring extras types cover editor widgets; add common controls only when they share this base contract.
- Range and option changes keep labels, dirty generations, and one-based Lua selection rules coherent.

### diagnostics.rs

- Defines UI accessibility snapshots and diagnostics that expose retained-tree state without granting mutation authority.
- UiAccessibilityNode records printable metadata, while UiDiagnostic carries bounded warnings for caller inspection.
- GuiContext creates these from live state; Lua bindings serialize them but never expose indices as handles.
- Open this file for diagnostic vocabulary, accessibility snapshot fields, and invariant failures visible to UI users.

### extras.rs

- Defines retained specialized widgets outside the common control and container families used by ordinary UI screens.
- It stores local data for trees, menus, dialogs, status bars, accordions, tooltips, color pickers, and tables.
- Property and image widgets live here with spin boxes, switches, badges, separators, and spacers with clear defaults.
- These are data-only variants; context input performs interaction, context owns lifetime, and render emits commands.
- Lua bindings map validated calls onto fields but do not make this module responsible for callbacks or GameFS access.
- Dialog, menu, and tooltip links are retained indexes internally and always receive validated opaque widget handles.
- Separator and spacer entries carry layout and hit-test semantics rather than serving as inert visual placeholders.
- Status-bar section content is retained through this owner while context lifecycle repairs released child references.
- These values remain cloneable so a malformed declarative layout can roll back without changing the active UI tree.
- Open this file for local widget defaults and invariants; use input and render owners for events and paint behavior.
- Keep shared geometry in WidgetBase and tree structure in GuiContext instead of duplicating ownership per variant.

### icons.rs

- Defines the finite built-in icon vocabulary used by labels, buttons, menus, and icon-only retained widgets.
- Lookup maps stable public icon names to glyph metadata, while widgets retain only the chosen identifier string.
- Rendering resolves the identifier later, keeping font loading, glyph shaping, and rasterization outside this module.
- Lua bindings validate names here so unknown icons fail at the public boundary instead of painting silently.
- The icon set is deterministic and data-only, keeping examples and headless captures independent of font probing.
- Add or rename an icon here, then update its Lua documentation, examples, and tests that exercise the public name.
- Do not store per-widget handles or rendering resources here; WidgetBase and render remain their respective owners.
- Open this file for icon vocabulary changes and use render helpers when a valid icon has incorrect visual placement.

### layout_loader.rs

- Parses declarative TOML UI layouts into definitions and applies them transactionally to retained GuiContext state.
- This file owns schema conversion, finite-value checks, collection limits, reference resolution, and rollback behavior.
- Loaders use context builders only after the source passes depth, size, and path-policy validation.
- Lua bindings and GameFS select and read the source; this module does not authorize filesystem access itself.
- A failed document leaves the live UI tree untouched, so callers retain a usable screen and report diagnostics.
- It resolves id references, style metadata, bindings, and child structure after parsing instead of trusting TOML order.
- Layout definitions describe retained widgets; generic layout algorithms remain owned by context and container modules.
- Open this file for TOML syntax, declarative widget semantics, transaction boundaries, and loader error diagnostics.
- Collection and string limits are taken from UiLimits so layout files cannot create a separate unbounded resource path.
- Neighboring extras and controls modules provide concrete widget data configured from declarative fields.
- The parser produces deterministic definitions suitable for tests and headless capture without invoking Lua callbacks.
- Changes here require matching loader docs, GameFS examples, and tests for success and rollback failure paths.

### limits.rs

- Defines UiLimits, the shared resource ceilings used by retained UI creation, layout loading, events, and capture.
- Loader, Lua conversion, event production, and image export consult this policy so no public entry path bypasses it.
- Trusted engine setup may replace these limits before a game starts; normal Lua code cannot mutate the policy.
- Open this file when changing accepted UI sizes, collection budgets, capture allocations, or their rejection messages.

### mod.rs

- This module re-exports UI surface for `containers.rs`, `context.rs`, `controls.rs`, and `diagnostics.rs` and helpers.
- It keeps navigation explicit by showing which sibling files own state, validation, transport, or render behavior.
- Public exports here route callers toward `containers.rs`, `context.rs`, and `controls.rs` first, while deeper owners.
- Open this file when the public UI symbol map moves; edit siblings when runtime rules themselves change.
- This index exists to organize entrypoints, not to absorb the state, caches, or algorithms its children own.
- Use neighboring owners for behavioral fixes, and keep this file limited to exports, docs, and navigation.
- Reexports here help agents find right module quickly when changes touch `containers.rs`, `context.rs`, subsystem.
- Keep concrete logic in `containers.rs`, `context.rs`, and `controls.rs` so symbol lookup stays shallow.

### render/helpers.rs

- Provides shared render helpers for geometry, clipping, text placement, colors, and command construction.
- Functions convert resolved widget state into RenderCommand fragments without mutating tree or callback state.
- Widget-specific paint decisions stay in the parent render owner, keeping repeated drawing math small and consistent.
- GPU execution, fonts, images, and encoding remain renderer-owned, so helpers never allocate graphics resources directly.
- Inputs use logical UI pixels and preserve clipping and order invariants so headless capture matches live lowering.
- Helpers may choose visible fallbacks for absent optional resources but must not change layout or input ownership.
- Use this file when paint branches duplicate geometry or color calculations across parent renderer widget kinds.
- Keep lifecycle, callback dispatch, GameFS output, and coordinate conversion in dedicated subsystem owners.
- Tests should verify command content or capture evidence, rather than relying on a widget factory alone.
- Navigation stays here for shared paint math; keep per-widget visual policy in the parent render module.

### render.rs

- Lowers resolved UI widgets, styles, text, and overlays into render commands consumed by live and headless backends.
- It owns widget visuals, inherited shader selection, clipping commands, and deterministic command ordering.
- GuiContext supplies geometry and state; this file never changes widget ownership, focus, callbacks, or input routing.
- Theme lookup selects colors, borders, type, and state variants before commands are emitted for live or headless output.
- Font and shader resources remain render-owned; UI stores selected keys on retained widget state.
- Software capture replays this command vocabulary through render-owned capture instead of duplicating UI semantics.
- Toolbar separators and spacers are visual items paired with hit testing so only button entries are interactive.
- Rendering uses visible fallback output for missing optional resources instead of assuming GPU state at the UI boundary.
- Open this file for widget appearance, draw-command order, clipping, shader inheritance, or UI-to-image lowering changes.
- Generic renderer execution, GPU pipelines, and image encoding are deliberately outside this module's ownership boundary.
- Helper modules contain shared paint primitives; keep individual widget branches focused on observable visual contracts.
- GuiContext checks command limits before submission so pathological retained trees cannot exhaust a frame budget.
- Coordinates are logical UI pixels after layout scaling; downstream render modules perform target conversion.
- Tests for this owner should assert commands or capture output, not merely that a widget factory remains callable.

### theme.rs

- Defines the UI theming system that maps widget kind and state onto colors, borders, spacing, and text style.
- Stores widget styles, class styles, and semantic tokens so one theme can drive many screens consistently.
- Resolves requested style records through fallback lookup so incomplete themes still render usable interfaces.
- Keeps style records cheap to clone, which makes per-screen theme forks practical without deep mutation costs.
- Ships default dark theme values that cover standard widgets without forcing custom setup before first use.
- Supports semantic tokens so shared meanings like accent, error, or muted visuals stay stable across controls.
- Feeds render-time style resolution directly, making this the owner for visual defaults rather than draw code.
- Includes image helpers used to visualize theme states when verifying widget styling outside the live runtime.
- Acts as the styling boundary between retained widget state and the colors or metrics chosen for presentation.
- Open this file when visuals drift by state or class even though layout and control logic still behave correctly.
- Read this owner before renderer changes when the problem looks like bad token lookup or missing theme fallback.

### widget.rs

- Defines WidgetBase, widget kinds, style and state enums, geometry metadata, and text-alignment parsing rules.
- WidgetBase carries common retained state used by layout, input, diagnostics, and rendering for every widget kind.
- Concrete control, container, and specialized payloads remain in sibling files so common contracts stay centralized.
- Enums define public names and validated defaults, while generational identity and destruction remain GuiContext work.
- Lua bindings expose opaque handles and never treat storage slots or printable _idx diagnostics as mutation authority.
- Coordinates use logical UI pixels; viewport scaling occurs in context geometry before rendering consumes rectangles.
- State values describe retained interaction and paint state, not platform events or direct callback execution work.
- Parsing helpers reject unknown public enum strings at the boundary rather than silently selecting a visual fallback.
- Read this file for cross-widget vocabulary, then navigate to controls, containers, or extras for concrete behavior.
- Keep tree ownership, callback registries, GameFS policies, and render-resource lifetime in their dedicated modules.



## Lua API Ref

### Functions

- `lurek.ui.addToast(toast_table) -> nil`: Adds a toast notification to the queue.
- `lurek.ui.animateColor(widget, from, to, duration, easing?) -> nil`: Animate widget color tint from one RGBA value to another.
- `lurek.ui.animateRotation(widget, from, to, duration, easing?) -> nil`: Animate widget rotation from one angle to another (in radians).
- `lurek.ui.animateScale(widget, from_sx, from_sy, to_sx, to_sy, duration, easing?) -> nil`: Animate widget scale from one value to another.
- `lurek.ui.beginDrag(widget) -> boolean`: Begins a drag operation on a live widget handle.
- `lurek.ui.clear() -> integer`: Clears all retained UI widgets and transient UI state while keeping the active theme.
- `lurek.ui.clearFocus() -> nil`: Clears keyboard focus from all widgets.
- `lurek.ui.clearFont() -> nil`: Clears the global UI font override so the UI falls back to the active render font again.
- `lurek.ui.destroy(widget, recursive?) -> integer`: Destroys a widget handle and, by default, its retained descendant subtree.
- `lurek.ui.draw() -> nil`: Queues retained UI render commands, then invokes custom draw callbacks for widgets that registered one.
- `lurek.ui.drawToImage(w, h) -> LImageData`: Renders the entire UI to an image buffer.
- `lurek.ui.dropOn(target) -> boolean`: Drops the currently dragged widget onto a target widget.
- `lurek.ui.endDrag() -> LUiWidget?`: Ends the current drag operation without dropping.
- `lurek.ui.flushCache() -> boolean`: Flushes internal UI layout and render caches.
- `lurek.ui.focusDirection(dx, dy) -> boolean`: Move focus in a spatial direction. Uses geometry to find nearest focusable widget.
- `lurek.ui.focusNeighbor(direction) -> boolean`: Moves keyboard focus using an explicit directional focus link.
- `lurek.ui.focusNext() -> nil`: Moves keyboard focus to the next focusable widget.
- `lurek.ui.focusPrev() -> nil`: Moves keyboard focus to the previous focusable widget.
- `lurek.ui.getAccessibilityTree() -> table`: Returns a flattened accessibility snapshot for all live widgets except the root.
- `lurek.ui.getActiveDrag() -> LUiWidget?`: Returns the live widget currently being dragged, or nil.
- `lurek.ui.getFocus() -> integer`: Returns the index of the currently focused widget, or nil.
- `lurek.ui.getFont() -> LFont`: Returns the global UI font assigned to the root widget, or nil when UI uses the render fallback font.
- `lurek.ui.getIconGlyph(name) -> string|nil`: Returns the built-in text glyph for an icon name, or nil when missing.
- `lurek.ui.getIconNames() -> string[]`: Returns all built-in UI icon names in stable catalog order.
- `lurek.ui.getRoot() -> LPanel`: Returns the root panel widget of the UI tree.
- `lurek.ui.getRuntimeStats() -> table`: Returns bounded UI work counters for development diagnostics.
- `lurek.ui.getScaleFactor() -> number`: Get the current UI scale factor (current_height / base_height).
- `lurek.ui.getStyleToken(name) -> number`: Returns the value of a named semantic style token from the active theme.
- `lurek.ui.getTheme() -> boolean`: Returns whether a theme is currently set.
- `lurek.ui.getToastCount() -> integer`: Returns the number of active toast notifications.
- `lurek.ui.getWidgetCount() -> integer`: Returns the total number of widgets in the UI context.
- `lurek.ui.getWidgetFont(widget) -> LFont`: Returns the font override assigned to a widget, or nil when the widget inherits its font from a parent.
- `lurek.ui.hasAutoInput() -> boolean`: Returns whether platform input is automatically forwarded to `lurek.ui`.
- `lurek.ui.hasAutoUpdate() -> boolean`: Returns whether `lurek.ui.update(dt)` is called automatically each frame.
- `lurek.ui.hasIcon(name) -> boolean`: Returns whether a built-in UI icon name exists.
- `lurek.ui.keypressed(key) -> boolean`: Delivers a key press event to the UI.
- `lurek.ui.loadLayout(def) -> LUiWidget`: Loads a UI layout from a Lua table definition.
- `lurek.ui.loadLayoutFile(path) -> LUiWidget`: Loads a UI layout from a TOML layout file.
- `lurek.ui.loadLayoutGameFile(path) -> LUiWidget`: Loads a UI layout from a TOML file resolved through GameFS.
- `lurek.ui.mousemoved(x, y) -> boolean`: Delivers a mouse move event to the UI.
- `lurek.ui.mousepressed(x, y, btn?) -> boolean`: Delivers a mouse press event to the UI.
- `lurek.ui.mousereleased(x, y, btn?) -> boolean`: Delivers a mouse release event to the UI.
- `lurek.ui.newAccordion() -> LAccordion`: Creates a new accordion widget with collapsible sections.
- `lurek.ui.newAspectRatioContainer() -> LAspectRatioContainer`: Creates a container that fits its child to a fixed aspect ratio.
- `lurek.ui.newBadge(count?) -> LBadge`: Creates a new badge widget for displaying counts.
- `lurek.ui.newButton(text?) -> LButton`: Creates a new button widget with optional label text.
- `lurek.ui.newCenterContainer() -> LLayout`: Creates a container that centers its child along both axes.
- `lurek.ui.newCheckbox(text?) -> LCheckbox`: Creates a new checkbox widget with optional label.
- `lurek.ui.newColorPicker() -> LColorPicker`: Creates a new color picker widget for color selection.
- `lurek.ui.newComboBox() -> LComboBox`: Creates a new combo box (drop-down) widget.
- `lurek.ui.newComparisonBar(label, current, target) -> LLayout`: Creates a horizontal comparison row from a label, current value, and target value.
- `lurek.ui.newCustomWidget(config?) -> LUiWidget`: Creates a new custom widget with optional initial configuration.
- `lurek.ui.newDialog(title?) -> LDialog`: Creates a new dialog widget with an optional title.
- `lurek.ui.newDockPanel() -> LDockPanel`: Creates a new dock panel widget for docking child widgets to sides.
- `lurek.ui.newGridContainer(columns?) -> LLayout`: Creates a grid container with an optional column count.
- `lurek.ui.newHBoxContainer() -> LLayout`: Creates a horizontal box container that stacks children left-to-right.
- `lurek.ui.newIcon(icon) -> LLabel|nil`: Creates a label-like widget that displays only a built-in UI icon.
- `lurek.ui.newImageWidget() -> LImageWidget`: Creates a new image display widget.
- `lurek.ui.newLabel(text?) -> LLabel`: Creates a new label widget for displaying text.
- `lurek.ui.newLayout(direction?) -> LLayout`: Creates a new layout container widget.
- `lurek.ui.newList() -> LListBox`: Creates a new list box widget for item selection.
- `lurek.ui.newMarginContainer(top?, right?, bottom?, left?) -> LLayout`: Creates a padding container around one or more child widgets using CSS-style shorthand.
- `lurek.ui.newMenuBar() -> LMenuBar`: Creates a new menu bar widget for top-level menus.
- `lurek.ui.newMenuItem(text?) -> LMenuItem`: Creates a new menu item widget with optional text.
- `lurek.ui.newNinePatch() -> LNinePatch`: Creates a new nine-patch widget for scalable bordered images.
- `lurek.ui.newPanel() -> LPanel`: Creates a new panel widget (container).
- `lurek.ui.newProgressBar(min?, max?) -> LProgressBar`: Creates a new progress bar widget with min and max.
- `lurek.ui.newPropertyWidget() -> LPropertyWidget`: Creates a new property inspector widget with collapsible groups and typed value rows.
- `lurek.ui.newRadioButton(text?, group?) -> LRadioButton`: Creates a new radio button widget in a named group.
- `lurek.ui.newRichLabel(text?) -> LRichLabel`: Creates a new rich label with simple inline formatting spans.
- `lurek.ui.newScrollBar(vertical?) -> LScrollBar`: Creates a new scroll bar widget for content scrolling.
- `lurek.ui.newScrollContainer() -> LScrollPanel`: Creates a scroll container alias for `newScrollPanel`.
- `lurek.ui.newScrollPanel() -> LScrollPanel`: Creates a new scrollable panel widget.
- `lurek.ui.newSeparator(vertical?) -> LSeparator`: Creates a new separator widget for visual division.
- `lurek.ui.newSlider(min?, max?) -> LSlider`: Creates a new slider widget with adjustable range.
- `lurek.ui.newSlotGrid(slots, columns?) -> LLayout`: Creates a grid layout for unit slots or equipped parts.
- `lurek.ui.newSpacer(w?, h?) -> LSpacer`: Creates a new spacer widget for spacing between other widgets.
- `lurek.ui.newSpinBox(min?, max?) -> LSpinBox`: Creates a new spin box (numeric stepper) widget.
- `lurek.ui.newSplitContainer(orientation?) -> LSplitPanel`: Creates a split container alias for `newSplitPanel`.
- `lurek.ui.newSplitPanel(orientation?) -> LSplitPanel`: Creates a new split panel widget with two resizable sub-panels.
- `lurek.ui.newStackContainer() -> LStackContainer`: Creates a stack container that lays out all children in one rectangle and shows one active child.
- `lurek.ui.newStatPanel(stats) -> LLayout`: Creates a compact stat panel from a table of numeric values.
- `lurek.ui.newStatusBar() -> LStatusBar`: Creates a new status bar widget for app-level info.
- `lurek.ui.newSwitch(on?) -> LSwitch`: Creates a new toggle switch widget.
- `lurek.ui.newTabBar() -> LTabBar`: Creates a new tab bar widget for tabbed navigation.
- `lurek.ui.newTabContainer() -> LTabContainer`: Creates a tab container with tab labels and one active child page.
- `lurek.ui.newTable() -> LGuiTable`: Creates a new table widget for tabular data display.
- `lurek.ui.newTextArea() -> LTextArea`: Creates a new multi-line text area widget.
- `lurek.ui.newTextInput() -> LTextInput`: Creates a new text input widget for user entry.
- `lurek.ui.newTheme() -> LTheme`: Creates a new UI theme for styling widgets.
- `lurek.ui.newToast(message?, duration?) -> LToast`: Creates a new toast notification widget.
- `lurek.ui.newToolbar(orientation?) -> LToolbar`: Creates a new toolbar widget for action buttons.
- `lurek.ui.newTooltipPanel(text?) -> LTooltipPanel`: Creates a new tooltip panel widget.
- `lurek.ui.newTreeView() -> LTreeView`: Creates a new tree view widget for hierarchical data.
- `lurek.ui.newVBoxContainer() -> LLayout`: Creates a vertical box container that stacks children top-to-bottom.
- `lurek.ui.newWindow(title?) -> LGuiWindow`: Creates a new GUI window widget with an optional title.
- `lurek.ui.parseWidgetState(state) -> string`: Validates and normalizes a widget state string.
- `lurek.ui.renderToImage(pathOrWidth, widthOrHeight, heightOrPath) -> nil`: Renders the entire UI to a PNG image file. The canonical form is `(width, height, path)`.
- `lurek.ui.setAutoInput(enabled) -> nil`: Enables or disables automatic forwarding of platform mouse, wheel, key, and text input to `lurek.ui`.
- `lurek.ui.setAutoUpdate(enabled) -> nil`: Enables or disables automatic `lurek.ui.update(dt)` calls during the frame update.
- `lurek.ui.setBaseResolution(width, height) -> nil`: Set the logical base resolution the UI was designed for.
- `lurek.ui.setDefaultTheme() -> nil`: Applies the built-in default theme to the UI context.
- `lurek.ui.setFocus(widget?) -> nil`: Sets keyboard focus to a widget, or clears focus if nil.
- `lurek.ui.setFont(font) -> nil`: Sets the global UI font by applying it to the root widget.
- `lurek.ui.setSafeArea(top, right, bottom, left) -> nil`: Supplies normalized window safe-area insets in pixels. Window discovery remains app-owned.
- `lurek.ui.setTheme(theme_ud) -> nil`: Applies a theme to the entire UI context.
- `lurek.ui.setViewport(w, h) -> nil`: Sets the viewport size for the UI context.
- `lurek.ui.textinput(text) -> boolean`: Delivers a text input event to the UI.
- `lurek.ui.update(dt) -> nil`: Updates the UI context and dispatches pending events to callbacks.
- `lurek.ui.updateBindings(data) -> integer`: Updates data bindings for widgets that reference binding keys.
- `lurek.ui.updateResolution(width, height) -> nil`: Update the current viewport resolution and recompute UI scale factor.
- `lurek.ui.update_bindings(data) -> integer`: Updates data bindings for widgets that reference binding keys.
- `lurek.ui.validateUx() -> table`: Returns accessibility and usability diagnostics for the live widget tree.
- `lurek.ui.visibleRange(widget, item_count, item_height) -> integer`: Calculate the visible item range for a scrollable list widget.
- `lurek.ui.wheelmoved(x, y) -> boolean`: Delivers a mouse wheel event to the UI.

### Callbacks

- `LColorPicker:setOnChange` param `f` (`function`): Callback receiving the widget index.
- `LDialog:addAction` param `cb` (`function?`): Optional callback fired when the action activates.
- `LDialog:addButton` param `cb` (`function?`): Optional callback invoked when the action is activated.
- `LDialog:setOnClose` param `f` (`function`): Callback invoked by the UI event dispatcher.
- `LGuiTable:setOnSelect` param `f` (`function`): Callback receiving the widget index.
- `LGuiWindow:setOnClose` param `f` (`function`): Callback receiving the widget index.
- `LMenuItem:setOnClick` param `f` (`function`): Callback receiving the widget index.
- `LRadioButton:setOnChange` param `f` (`function`): Callback receiving the widget index.
- `LScrollBar:setOnChange` param `f` (`function`): Callback receiving the widget index.
- `LUiWidget:setOnChange` param `f` (`function`): Callback receiving the widget index as argument.
- `LUiWidget:setOnClick` param `f` (`function`): Callback receiving the widget index as argument.
- `LUiWidget:setOnDragEnd` param `f` (`function`): Callback receiving source and target widget indices; target is nil when cancelled.
- `LUiWidget:setOnDragEnter` param `f` (`function`): Callback receiving source and target widget indices.
- `LUiWidget:setOnDragLeave` param `f` (`function`): Callback receiving source and target widget indices.
- `LUiWidget:setOnDragStart` param `f` (`function`): Callback receiving the source widget index.
- `LUiWidget:setOnDraw` param `f` (`function`): Callback receiving a rect table {x, y, w, h} with the computed bounds.
- `LUiWidget:setOnDrop` param `f` (`function`): Callback receiving source and target widget indices.

### Enums

- No documented module-level enums/constants.

### Types

#### LAccordion Type

- Adds accordion-specific methods to an accordion widget table.

##### Fields

- No documented fields.

##### Methods

- `LAccordion:addSection(title, content?) -> nil`: Adds a collapsible section to this accordion.
- `LAccordion:getSectionCount() -> integer`: Returns the number of sections in this accordion.
- `LAccordion:getSectionTitle(section_idx) -> string`: Returns the title of an accordion section by its 1-based index.
- `LAccordion:isExclusive() -> boolean`: Returns whether this accordion is in exclusive mode (only one section open at a time).
- `LAccordion:isSectionExpanded(section_idx) -> boolean`: Returns whether an accordion section is expanded.
- `LAccordion:setExclusive(v) -> nil`: Sets exclusive mode. When true, expanding one section collapses all others.
- `LAccordion:toggleSection(section_idx) -> boolean`: Toggles the expanded state of an accordion section by its 1-based index.

#### LAspectRatioContainer Type

- Adds aspect-container-specific methods.

##### Fields

- No documented fields.

##### Methods

- `LAspectRatioContainer:getFit() -> string`: Returns how the child is fit into the aspect rectangle.
- `LAspectRatioContainer:getRatio() -> number`: Returns the child aspect ratio used by this container.
- `LAspectRatioContainer:setFit(fit) -> nil`: Sets how the child is fit into the aspect rectangle.
- `LAspectRatioContainer:setRatio(ratio) -> nil`: Sets the child aspect ratio used by this container.

#### LBadge Type

- Adds badge-specific methods to a notification badge widget table.

##### Fields

- No documented fields.

##### Methods

- `LBadge:getCount() -> integer`: Returns the current notification count of this badge.
- `LBadge:getDisplayText() -> string`: Returns the formatted display text of this badge (e.g. "99+" when count exceeds the maximum).
- `LBadge:setCount(count) -> nil`: Sets the notification count displayed by this badge.

#### LButton Type

- Adds button-specific methods (setText, getText) to a button widget table.

##### Fields

- No documented fields.

##### Methods

- `LButton:getText() -> string`: Returns the current display text of this button.
- `LButton:setText(text) -> nil`: Sets the display text on this button.

#### LCheckbox Type

- Adds checkbox-specific methods to a checkbox widget table.

##### Fields

- No documented fields.

##### Methods

- `LCheckbox:getText() -> string`: Returns the label text of this checkbox.
- `LCheckbox:isChecked() -> boolean`: Returns whether this checkbox is currently checked.
- `LCheckbox:setChecked(checked) -> nil`: Sets the checked state of this checkbox.
- `LCheckbox:setText(text) -> nil`: Sets the label text displayed next to this checkbox.

#### LColorPicker Type

- Adds color-picker-specific methods to a color picker widget table.

##### Fields

- No documented fields.

##### Methods

- `LColorPicker:getColor() -> number`: Returns the current color as RGBA components (0.0 to 1.0).
- `LColorPicker:getColorMode() -> string`: Returns the color mode of this picker (e.g. "rgb", "hsv").
- `LColorPicker:getShowAlpha() -> boolean`: Returns whether the alpha channel slider is visible.
- `LColorPicker:setColor(r, g, b, a?) -> nil`: Sets the current color as RGBA components.
- `LColorPicker:setColorMode(mode) -> nil`: Sets the color mode of this picker (e.g. "rgb", "hsv").
- `LColorPicker:setOnChange(f) -> nil`: Registers a callback invoked when this color picker's value changes.
- `LColorPicker:setShowAlpha(v) -> nil`: Sets whether the alpha channel slider is visible.

#### LComboBox Type

- Adds combo-box-specific methods to a combo box widget table.

##### Fields

- No documented fields.

##### Methods

- `LComboBox:addItem(text) -> nil`: Appends a new text item to this combo box's dropdown list.
- `LComboBox:clearItems() -> nil`: Removes all items from this combo box.
- `LComboBox:getItem(index) -> string`: Returns the text of the item at the given 1-based index.
- `LComboBox:getItemCount() -> integer`: Returns the number of items in this combo box.
- `LComboBox:getMaxVisibleItems() -> integer`: Returns the maximum number of dropdown rows shown before the combo box scrolls.
- `LComboBox:getSelectedIndex() -> integer`: Returns the 1-based index of the currently selected item, or 0 if none is selected.
- `LComboBox:getSelectedItem() -> string`: Returns the text of the currently selected item, or nil if none is selected.
- `LComboBox:removeItem(index) -> boolean`: Removes the item at the given 1-based index from this combo box.
- `LComboBox:setMaxVisibleItems(count) -> nil`: Sets the maximum number of dropdown rows shown at once before the combo box scrolls.
- `LComboBox:setSelectedIndex(index) -> nil`: Sets the selected item by 1-based index.

#### LDialog Type

- Adds dialog-specific methods to a dialog widget table.

##### Fields

- No documented fields.

##### Methods

- `LDialog:addAction(text, cb?, role?, close_on_activate?) -> integer`: Adds a footer action button and returns its 1-based index.
- `LDialog:addButton(text, cb?) -> integer`: Adds a custom action button to this dialog.
- `LDialog:centerInViewport() -> nil`: Repositions this dialog to the center of the active viewport immediately.
- `LDialog:close() -> nil`: Closes this dialog and dispatches close handling.
- `LDialog:getCancelAction() -> integer`: Returns the 1-based action index triggered by Escape, if any.
- `LDialog:getCenterOnOpen() -> boolean`: Returns whether opening this dialog recenters it in the viewport.
- `LDialog:getContent() -> integer`: Returns the widget index currently assigned to this dialog's content slot.
- `LDialog:getDefaultAction() -> integer`: Returns the 1-based action index triggered by Enter, if any.
- `LDialog:getDismissOnOutsideClick() -> boolean`: Returns whether outside clicks dismiss this non-modal dialog.
- `LDialog:getFooter() -> integer`: Returns the optional footer content widget index.
- `LDialog:getMaxSize() -> number, number`: Returns the optional maximum popup dimensions for this dialog.
- `LDialog:getMinSize() -> number, number`: Returns the minimum popup size for this dialog.
- `LDialog:getTitle() -> string`: Returns the current title text for this dialog.
- `LDialog:isCloseable() -> boolean`: Returns whether this dialog exposes user-driven close affordances.
- `LDialog:isDraggable() -> boolean`: Returns whether this dialog can be dragged by its title bar.
- `LDialog:isModal() -> boolean`: Returns whether this dialog is modal.
- `LDialog:isOpen() -> boolean`: Returns whether this dialog is currently open.
- `LDialog:isResizable() -> boolean`: Returns whether this dialog can be resized from its edges or corners.
- `LDialog:open() -> nil`: Opens this dialog and marks it visible.
- `LDialog:setCancelAction(index?) -> nil`: Sets the action triggered by Escape, using a 1-based action index.
- `LDialog:setCenterOnOpen(value) -> nil`: Controls whether opening this dialog recenters it in the viewport.
- `LDialog:setCloseable(value) -> nil`: Sets whether this dialog can be dismissed by close affordances or Escape fallback.
- `LDialog:setContent(content?) -> nil`: Sets the widget index rendered as this dialog's content.
- `LDialog:setDefaultAction(index?) -> nil`: Sets the action triggered by Enter, using a 1-based action index.
- `LDialog:setDismissOnOutsideClick(value) -> nil`: Controls whether clicking outside a non-modal dialog closes it.
- `LDialog:setDraggable(value) -> nil`: Enables or disables title-bar dragging for this dialog.
- `LDialog:setFooter(footer?) -> nil`: Assigns an optional footer content root for this dialog.
- `LDialog:setMaxSize(width?, height?) -> nil`: Sets optional maximum popup dimensions for this dialog.
- `LDialog:setMinSize(width, height) -> nil`: Sets the minimum popup size for this dialog.
- `LDialog:setModal(v) -> nil`: Sets whether this dialog blocks outside interaction.
- `LDialog:setOnClose(f) -> nil`: Registers a callback fired when this dialog closes.
- `LDialog:setResizable(value) -> nil`: Enables or disables edge and corner resizing for this dialog.
- `LDialog:setTitle(title) -> nil`: Sets the current title text for this dialog.

#### LDockPanel Type

- Adds dock-panel-specific methods to a dock panel widget table.

##### Fields

- No documented fields.

##### Methods

- `LDockPanel:dock(child, side) -> nil`: Docks a child widget to the specified side of this dock panel.
- `LDockPanel:getDockedCount() -> integer`: Returns the number of widgets docked in this dock panel.
- `LDockPanel:getSplitSize(side) -> number`: Returns the size configured for a dock panel side region.
- `LDockPanel:setSplitSize(side, size) -> nil`: Sets the size of a dock panel side region.
- `LDockPanel:undock(child) -> nil`: Removes a child widget from this dock panel.

#### LGuiTable Type

- Adds GUI-table-specific methods to a table widget.

##### Fields

- No documented fields.

##### Methods

- `LGuiTable:addColumn(header, width?) -> nil`: Adds a new column to this table widget.
- `LGuiTable:addRow(cells) -> nil`: Adds a row of data to this table widget.
- `LGuiTable:clearRows() -> nil`: Clears all rows and the selected row in this table widget.
- `LGuiTable:getCell(row, col) -> string`: Returns the text of a cell at the given 1-based row and column.
- `LGuiTable:getColumnCount() -> integer`: Returns the number of columns in this table widget.
- `LGuiTable:getRowCount() -> integer`: Returns the number of rows in this table widget.
- `LGuiTable:getSelectedRow() -> integer`: Returns the 1-based index of the currently selected row, or nil.
- `LGuiTable:isSortable() -> boolean`: Returns whether columns in this table can be sorted by clicking headers.
- `LGuiTable:setCell(row, col, text) -> nil`: Sets the text of a cell at the given 1-based row and column.
- `LGuiTable:setDataFrame(df, opts?) -> integer`: Replaces columns and rows from a dataframe, stringifying cell values for display.
- `LGuiTable:setOnSelect(f) -> nil`: Registers a callback invoked when a table row is selected.
- `LGuiTable:setRows(rows) -> integer`: Replaces all rows with an array of row arrays.
- `LGuiTable:setSelectedRow(row?) -> nil`: Sets the selected row by its 1-based index, or nil to deselect.
- `LGuiTable:setSortable(v) -> nil`: Sets whether columns in this table can be sorted by clicking headers.

#### LGuiWindow Type

- Adds GUI-window-specific methods to a window widget table.

##### Fields

- No documented fields.

##### Methods

- `LGuiWindow:getTitle() -> string`: Returns the title bar text of this GUI window.
- `LGuiWindow:isCloseable() -> boolean`: Returns whether this window shows a close button.
- `LGuiWindow:isDraggable() -> boolean`: Returns whether this window can be dragged by its title bar.
- `LGuiWindow:isResizable() -> boolean`: Returns whether this window can be resized by dragging its edges.
- `LGuiWindow:setCloseable(v) -> nil`: Sets whether this window shows a close button.
- `LGuiWindow:setDraggable(v) -> nil`: Sets whether this window can be dragged by its title bar.
- `LGuiWindow:setOnClose(f) -> nil`: Registers a callback invoked when this window is closed.
- `LGuiWindow:setResizable(v) -> nil`: Sets whether this window can be resized.
- `LGuiWindow:setTitle(title) -> nil`: Sets the title bar text of this GUI window.

#### LImageWidget Type

- Adds image-widget-specific methods to an image widget table.

##### Fields

- No documented fields.

##### Methods

- `LImageWidget:getScaleMode() -> string`: Returns the image scaling mode (e.g. "fit", "fill", "stretch").
- `LImageWidget:getTint() -> number`: Returns the tint color of this image widget as RGBA components.
- `LImageWidget:setScaleMode(mode) -> nil`: Sets the image scaling mode (e.g. "fit", "fill", "stretch").
- `LImageWidget:setTint(r, g, b, a?) -> nil`: Sets the tint color of this image widget as RGBA components.

#### LLabel Type

- Adds label-specific methods (setText, getText) to a label widget table.

##### Fields

- No documented fields.

##### Methods

- `LLabel:getText() -> string`: Returns the current display text of this label.
- `LLabel:setText(text) -> nil`: Sets the display text on this label.

#### LLayout Type

- Adds layout-specific methods to a layout container widget table.

##### Fields

- No documented fields.

##### Methods

- `LLayout:getAlign() -> string`: Returns the current cross-axis alignment mode.
- `LLayout:getDirection() -> string`: Returns the current layout direction.
- `LLayout:getJustify() -> string`: Returns the current main-axis justification mode.
- `LLayout:getSpacing() -> number`: Returns the current spacing between children.
- `LLayout:getWrap() -> boolean`: Returns whether wrapping is enabled for this layout.
- `LLayout:setAlign(align) -> boolean`: Sets the cross-axis alignment for children (e.g. "start", "center", "end", "stretch").
- `LLayout:setColumns(n) -> nil`: Sets the number of columns for grid layout mode (minimum 1).
- `LLayout:setDirection(dir) -> nil`: Sets the layout direction for child arrangement ("horizontal", "vertical", or "grid").
- `LLayout:setJustify(justify) -> boolean`: Sets the main-axis justification for children (e.g. "start", "center", "end", "space-between").
- `LLayout:setSpacing(spacing) -> nil`: Sets the spacing in pixels between child widgets in this layout.
- `LLayout:setWrap(wrap) -> nil`: Enables or disables wrapping of children to the next row/column when they overflow.

#### LListBox Type

- Adds list-box-specific methods to a list box widget table.

##### Fields

- No documented fields.

##### Methods

- `LListBox:addItem(text) -> nil`: Appends a new text item to this list box.
- `LListBox:clearItems() -> nil`: Removes all items from this list box.
- `LListBox:getItem(index) -> string`: Returns the text of the item at the given 1-based index.
- `LListBox:getItemCount() -> integer`: Returns the number of items in this list box.
- `LListBox:getSelectedIndex() -> integer`: Returns the 1-based index of the currently selected item, or 0 if none.
- `LListBox:removeItem(index) -> nil`: Removes the item at the given 1-based index from this list box.
- `LListBox:setItemHeight(h) -> nil`: Sets the pixel height of each item row in this list box.
- `LListBox:setSelectedIndex(index) -> nil`: Sets the selected item by 1-based index.

#### LMenuBar Type

- Adds menu-bar-specific methods to a menu bar widget table.

##### Fields

- No documented fields.

##### Methods

- `LMenuBar:addMenu(menu) -> nil`: Adds a menu (by its widget index) to this menu bar.
- `LMenuBar:getMenuCount() -> integer`: Returns the number of menus in this menu bar.
- `LMenuBar:getMenus() -> integer[]`: Returns a table of widget indices for all menus in this menu bar.
- `LMenuBar:removeMenu(menu) -> boolean`: Removes a menu from this menu bar by its widget index.

#### LMenuItem Type

- Adds menu-item-specific methods to a menu item widget table.

##### Fields

- No documented fields.

##### Methods

- `LMenuItem:addSubItem(child) -> nil`: Adds a sub-item to this menu item for building nested menus.
- `LMenuItem:getShortcut() -> string`: Returns the keyboard shortcut string associated with this menu item.
- `LMenuItem:getSubItems() -> integer[]`: Returns a table of widget indices for all sub-items of this menu item.
- `LMenuItem:getText() -> string`: Returns the display text of this menu item.
- `LMenuItem:isChecked() -> boolean`: Returns whether this menu item is checked (for checkable menu items).
- `LMenuItem:setChecked(v) -> nil`: Sets the checked state of this menu item.
- `LMenuItem:setOnClick(f) -> nil`: Registers a callback invoked when this menu item is clicked.
- `LMenuItem:setShortcut(shortcut) -> nil`: Sets the keyboard shortcut text displayed next to this menu item.
- `LMenuItem:setText(text) -> nil`: Sets the display text of this menu item.

#### LNinePatch Type

- Adds nine-patch-specific methods to a nine-patch widget table.

##### Fields

- No documented fields.

##### Methods

- `LNinePatch:getImageDimensions() -> integer, integer`: Returns the original image dimensions of this nine-patch.
- `LNinePatch:getInsets() -> integer, integer, integer, integer`: Returns the border insets of this nine-patch.
- `LNinePatch:getSlices() -> table`: Returns the computed nine-patch slices as a table of source/dest rectangles for rendering.
- `LNinePatch:setImageDimensions(w, h) -> nil`: Sets the original image dimensions used for nine-patch slice calculations.
- `LNinePatch:setInsets(left, top, right, bottom) -> nil`: Sets the border insets defining the stretchable center region of the nine-patch image.

#### LNinePatchGetSlicesResult Type

- Generated result shape from @field tags.

##### Fields

- `dh` (`number`): Dest height.
- `dw` (`number`): Dest width.
- `dx` (`number`): Dest x.
- `dy` (`number`): Dest y.
- `sh` (`number`): Source height.
- `sw` (`number`): Source width.
- `sx` (`number`): Source x.
- `sy` (`number`): Source y.

##### Methods

- No documented methods.

#### LPanel Type

- Adds panel-specific methods (setTitle, getTitle, setScrollable) to a panel widget table.

##### Fields

- No documented fields.

##### Methods

- `LPanel:getTitle() -> string`: Returns the title text of this panel.
- `LPanel:setScrollable(scrollable) -> nil`: Enables or disables scrolling within this panel.
- `LPanel:setTitle(title) -> nil`: Sets the title text displayed on this panel's header.

#### LProgressBar Type

- Adds progress-bar-specific methods to a progress bar widget table.

##### Fields

- No documented fields.

##### Methods

- `LProgressBar:getMax() -> number`: Returns the maximum value of this progress bar's range.
- `LProgressBar:getMin() -> number`: Returns the minimum value of this progress bar's range.
- `LProgressBar:getProgress() -> number`: Returns the normalized progress as a fraction (0.0 to 1.0) of the current range.
- `LProgressBar:getValue() -> number`: Returns the current value of this progress bar.
- `LProgressBar:setRange(min, max) -> nil`: Sets the minimum and maximum bounds for this progress bar.
- `LProgressBar:setValue(v) -> nil`: Sets the current fill value of this progress bar, clamped to its range.

#### LPropertyWidget Type

- Adds property-widget-specific methods to an inspector widget.

##### Fields

- No documented fields.

##### Methods

- `LPropertyWidget:addGroup(title, collapsed?) -> integer`: Adds a collapsible property group and returns its 1-based index.
- `LPropertyWidget:addProperty(group, name, value, valueType?, options?, readOnly?) -> integer`: Adds a labeled property row to the selected group.
- `LPropertyWidget:getGroupCount() -> integer`: Returns the number of property groups.
- `LPropertyWidget:getLabelWidth() -> number`: Returns the left label column width in pixels.
- `LPropertyWidget:getPropertyCount(group) -> integer`: Returns the row count for a property group.
- `LPropertyWidget:getPropertyOptions(name) -> table`: Returns the select options of the first property with `name`.
- `LPropertyWidget:getPropertyType(name) -> string`: Returns the canonical editor type of the first property with `name`.
- `LPropertyWidget:getPropertyValue(name) -> string`: Returns the stringified value of the first property with `name`.
- `LPropertyWidget:isGroupCollapsed(group) -> boolean`: Returns whether a property group is collapsed.
- `LPropertyWidget:setLabelWidth(width) -> nil`: Sets the left label column width in pixels.
- `LPropertyWidget:setPropertyValue(name, value) -> boolean`: Updates the first property with `name`.
- `LPropertyWidget:toggleGroup(group) -> boolean`: Toggles a property group collapsed/expanded state.

#### LRadioButton Type

- Adds radio-button-specific methods to a radio button widget table.

##### Fields

- No documented fields.

##### Methods

- `LRadioButton:getGroup() -> string`: Returns the radio button group name. Buttons in the same group are mutually exclusive.
- `LRadioButton:getText() -> string`: Returns the label text of this radio button.
- `LRadioButton:isSelected() -> boolean`: Returns whether this radio button is currently selected.
- `LRadioButton:setGroup(group) -> nil`: Sets the radio button group name. Buttons in the same group are mutually exclusive.
- `LRadioButton:setOnChange(f) -> nil`: Registers a callback invoked when this radio button's selection changes.
- `LRadioButton:setSelected(v) -> nil`: Sets the selected state of this radio button.
- `LRadioButton:setText(text) -> nil`: Sets the label text of this radio button.

#### LRichLabel Type

- Adds rich-label-specific methods to a formatted read-only label table.

##### Fields

- No documented fields.

##### Methods

- `LRichLabel:getPlainText() -> string`: Returns the rich label text with simple inline span markers stripped.
- `LRichLabel:getText() -> string`: Returns the rich label source text, including inline span markers.
- `LRichLabel:setText(text) -> nil`: Sets the rich label source text with simple `[b]` and `[color=...]` spans.

#### LScrollBar Type

- Adds scroll-bar-specific methods to a scroll bar widget table.

##### Fields

- No documented fields.

##### Methods

- `LScrollBar:getContentSize() -> number`: Returns the total content size tracked by this scroll bar.
- `LScrollBar:getScrollPosition() -> number`: Returns the current scroll position of this scroll bar.
- `LScrollBar:getViewSize() -> number`: Returns the visible viewport size tracked by this scroll bar.
- `LScrollBar:isVertical() -> boolean`: Returns whether this scroll bar is oriented vertically.
- `LScrollBar:setContentSize(v) -> nil`: Sets the total content size that this scroll bar represents.
- `LScrollBar:setOnChange(f) -> nil`: Registers a callback invoked when this scroll bar's position changes.
- `LScrollBar:setScrollPosition(v) -> nil`: Sets the scroll position of this scroll bar, clamped to the valid range.
- `LScrollBar:setViewSize(v) -> nil`: Sets the visible viewport size for this scroll bar.

#### LScrollPanel Type

- Adds scroll-panel-specific methods to a scroll panel widget table.

##### Fields

- No documented fields.

##### Methods

- `LScrollPanel:getContentSize() -> number, number`: Returns the virtual content dimensions of this scroll panel.
- `LScrollPanel:getMaxScroll() -> number, number`: Returns the maximum scroll offset allowed in each axis.
- `LScrollPanel:getScrollPosition() -> number, number`: Returns the current scroll offset of this scroll panel.
- `LScrollPanel:getScrollSpeed() -> number`: Returns the current scroll speed multiplier.
- `LScrollPanel:setContentSize(w, h) -> nil`: Sets the virtual content dimensions of this scroll panel.
- `LScrollPanel:setScrollPosition(x, y) -> nil`: Sets the scroll offset position of this scroll panel.
- `LScrollPanel:setScrollSpeed(speed) -> nil`: Sets the scroll speed multiplier for mouse wheel scrolling.

#### LSeparator Type

- Adds separator-specific methods to a separator widget table.

##### Fields

- No documented fields.

##### Methods

- `LSeparator:getThickness() -> number`: Returns the line thickness of this separator.
- `LSeparator:isVertical() -> boolean`: Returns whether this separator is oriented vertically.
- `LSeparator:setThickness(thickness) -> nil`: Sets the line thickness of this separator in pixels.
- `LSeparator:setVertical(v) -> nil`: Sets whether this separator draws vertically or horizontally.

#### LSlider Type

- Adds slider-specific methods to a slider widget table.

##### Fields

- No documented fields.

##### Methods

- `LSlider:getMax() -> number`: Returns the maximum value of this slider's range.
- `LSlider:getMin() -> number`: Returns the minimum value of this slider's range.
- `LSlider:getValue() -> number`: Returns the current value of this slider.
- `LSlider:setRange(min, max) -> nil`: Sets the minimum and maximum bounds for this slider.
- `LSlider:setStep(step) -> nil`: Sets the step increment for this slider's value snapping.
- `LSlider:setValue(v) -> nil`: Sets the current value of this slider, clamped to its range.

#### LSpinBox Type

- Adds spin-box-specific methods to a spin box widget table.

##### Fields

- No documented fields.

##### Methods

- `LSpinBox:decrement() -> nil`: Decreases this spin box's value by one step.
- `LSpinBox:getValue() -> number`: Returns the current numeric value of this spin box.
- `LSpinBox:increment() -> nil`: Increases this spin box's value by one step.
- `LSpinBox:setRange(min, max) -> nil`: Sets the minimum and maximum bounds for this spin box.
- `LSpinBox:setStep(step) -> nil`: Sets the step increment for this spin box.
- `LSpinBox:setValue(v) -> nil`: Sets the numeric value of this spin box, clamped to its range.

#### LSplitPanel Type

- Adds split-panel-specific methods to a split panel widget table.

##### Fields

- No documented fields.

##### Methods

- `LSplitPanel:getFirstChild() -> integer`: Returns the widget index of the first (left/top) child panel.
- `LSplitPanel:getMinPanelSize() -> number`: Returns the minimum pixel size of each split sub-panel.
- `LSplitPanel:getOrientation() -> string`: Returns the orientation of this split panel ("horizontal" or "vertical").
- `LSplitPanel:getSecondChild() -> integer`: Returns the widget index of the second (right/bottom) child panel.
- `LSplitPanel:getSplitPosition() -> number`: Returns the split position as a fraction (0.0 to 1.0) of the panel's total size.
- `LSplitPanel:setFirstChild(child) -> nil`: Sets the widget index for the first (left/top) panel.
- `LSplitPanel:setMinPanelSize(v) -> nil`: Sets the minimum pixel size of each split sub-panel.
- `LSplitPanel:setOrientation(v) -> nil`: Sets the orientation of this split panel ("horizontal" or "vertical").
- `LSplitPanel:setSecondChild(child) -> nil`: Sets the widget index for the second (right/bottom) panel.
- `LSplitPanel:setSplitPosition(v) -> nil`: Sets the split position as a fraction (0.0 to 1.0).

#### LStackContainer Type

- Adds stack-container-specific methods to stack and tab container widget tables.

##### Fields

- No documented fields.

##### Methods

- `LStackContainer:addTab(label) -> nil`: Adds a tab/page label to this stack or tab container.
- `LStackContainer:getActiveChild() -> integer|nil`: Returns the widget index of the active child page.
- `LStackContainer:getActiveIndex() -> integer`: Returns the active child page as a 1-based index.
- `LStackContainer:getTab(index) -> string|nil`: Returns a tab/page label by 1-based index.
- `LStackContainer:getTabCount() -> integer`: Returns the number of tab/page labels in this stack or tab container.
- `LStackContainer:setActiveIndex(index) -> boolean`: Sets the active child page by 1-based child index.

#### LStatusBar Type

- Adds status-bar-specific methods to a status bar widget table.

##### Fields

- No documented fields.

##### Methods

- `LStatusBar:addSection(text, width?) -> nil`: Adds a labeled section to this status bar.
- `LStatusBar:getSectionCount() -> integer`: Returns the number of sections in this status bar.
- `LStatusBar:getSectionText(section_idx) -> string`: Returns the text of a status bar section by its 1-based index.
- `LStatusBar:setSectionCount(count) -> nil`: Sets the number of sections, truncating or adding empty sections as needed.
- `LStatusBar:setSectionText(section_idx, text) -> nil`: Sets the text of a status bar section by its 1-based index.
- `LStatusBar:setSectionWidget(section_idx, widget?) -> nil`: Assigns a live widget to a status bar section. The widget is reparented into the bar and clipped to that section.

#### LSwitch Type

- Adds switch-specific methods (setOn, isOn, toggle) to a switch widget table.

##### Fields

- No documented fields.

##### Methods

- `LSwitch:isOn() -> boolean`: Returns whether this switch is currently in the on state.
- `LSwitch:setOn(on) -> nil`: Sets the on/off state of this toggle switch.
- `LSwitch:toggle() -> nil`: Toggles this switch between on and off states.

#### LTabBar Type

- Adds tab-bar-specific methods to a tab bar widget table.

##### Fields

- No documented fields.

##### Methods

- `LTabBar:addTab(label) -> nil`: Adds a new tab with the given label to this tab bar.
- `LTabBar:getActiveTab() -> integer`: Returns the 1-based index of the currently active tab.
- `LTabBar:getTab(index) -> string`: Returns the label of the tab at the given 1-based index.
- `LTabBar:getTabCount() -> integer`: Returns the total number of tabs in this tab bar.
- `LTabBar:removeTab(index) -> boolean`: Removes the tab at the given 1-based index.
- `LTabBar:setActiveTab(index) -> nil`: Sets the active (selected) tab by 1-based index.

#### LTabContainer Type

- Adds tab-container-specific methods to tab container widget tables.

##### Fields

- No documented fields.

##### Methods

- `LTabContainer:addTab(label) -> nil`: Adds a tab label to this tab container.
- `LTabContainer:getActiveChild() -> integer|nil`: Returns the widget index of the active tab page.
- `LTabContainer:getActiveIndex() -> integer`: Returns the active tab page as a 1-based child index.
- `LTabContainer:getTab(index) -> string|nil`: Returns a tab label by 1-based index.
- `LTabContainer:getTabCount() -> integer`: Returns the number of tab labels in this tab container.
- `LTabContainer:setActiveIndex(index) -> boolean`: Sets the active tab page by 1-based child index.

#### LTextArea Type

- Adds text-area-specific methods to a multi-line text widget table.

##### Fields

- No documented fields.

##### Methods

- `LTextArea:getCursorPosition() -> integer`: Returns the current cursor position as a zero-based character index.
- `LTextArea:getPlaceholder() -> string`: Returns the placeholder text of this text area.
- `LTextArea:getText() -> string`: Returns the current text content of this multi-line text area.
- `LTextArea:isFocused() -> boolean`: Returns whether this text area currently has keyboard focus.
- `LTextArea:setMaxLength(n) -> nil`: Sets the maximum number of characters allowed in this text area.
- `LTextArea:setPlaceholder(text) -> nil`: Sets the placeholder text shown when the text area is empty.
- `LTextArea:setText(text) -> nil`: Sets the text content of this multi-line text area and moves the cursor to the end.

#### LTextInput Type

- Adds text-input-specific methods to a text input widget table.

##### Fields

- No documented fields.

##### Methods

- `LTextInput:getCursorPosition() -> integer`: Returns the current cursor position (character index) within the text input.
- `LTextInput:getPlaceholder() -> string`: Returns the placeholder text of this text input.
- `LTextInput:getSubmitOnEnter() -> boolean`: Returns whether pressing Enter in this text input submits the surrounding dialog default action.
- `LTextInput:getText() -> string`: Returns the current text content of this text input field.
- `LTextInput:isFocused() -> boolean`: Returns whether this text input currently has keyboard focus.
- `LTextInput:setMaxLength(n) -> nil`: Sets the maximum number of characters allowed in this text input.
- `LTextInput:setPlaceholder(text) -> nil`: Sets the placeholder text shown when the input is empty.
- `LTextInput:setSubmitOnEnter(value) -> nil`: Controls whether pressing Enter in this text input submits the surrounding dialog default action.
- `LTextInput:setText(text) -> nil`: Sets the text content of this text input field and moves the cursor to the end.

#### LTheme Type

- Lua-exposed wrapper around a GUI theme for styling widgets.

##### Fields

- No documented fields.

##### Methods

- `LTheme:setStyle(widget_type, state, styleOrClass, styleTable?) -> boolean`: Sets a style entry for the given widget type and state, optionally restricted to a style class.
- `LTheme:type() -> string`: Returns the type name of this object.
- `LTheme:typeOf(name) -> boolean`: Checks whether this object matches the given type name.

#### LToast Type

- Adds toast-specific methods to a toast notification widget table.

##### Fields

- No documented fields.

##### Methods

- `LToast:getDuration() -> number`: Returns the display duration of this toast in seconds.
- `LToast:getMessage() -> string`: Returns the message text of this toast.
- `LToast:getProgress() -> number`: Returns the elapsed fraction (0.0 to 1.0) of this toast's lifetime.
- `LToast:isExpired() -> boolean`: Returns whether this toast has exceeded its display duration.
- `LToast:setDuration(d) -> nil`: Sets how long this toast is displayed in seconds.
- `LToast:setMessage(msg) -> nil`: Sets the message text displayed by this toast notification.

#### LToolbar Type

- Adds toolbar-specific methods to a toolbar widget table.

##### Fields

- No documented fields.

##### Methods

- `LToolbar:addButton(id, tooltip?) -> integer`: Adds a new button to this toolbar and returns its 1-based index.
- `LToolbar:addSeparator() -> nil`: Adds a visual separator to this toolbar.
- `LToolbar:addSpacer(size?) -> nil`: Adds a flexible spacer to this toolbar.
- `LToolbar:getButton(id) -> table`: Returns a table describing the toolbar button with the given ID.
- `LToolbar:getOrientation() -> string`: Returns the toolbar orientation ("horizontal" or "vertical").
- `LToolbar:isButtonToggled(id) -> boolean`: Returns whether a toolbar button is toggled on.
- `LToolbar:setButtonEnabled(id, enabled) -> boolean`: Enables or disables a toolbar button by its ID.
- `LToolbar:setButtonToggled(id, toggled) -> boolean`: Sets the toggle state of a toolbar button by its ID.
- `LToolbar:setOrientation(v) -> nil`: Sets the toolbar orientation ("horizontal" or "vertical").

#### LToolbarGetButtonResult Type

- Generated result shape from @field tags.

##### Fields

- `enabled` (`boolean`): Whether the button is enabled.
- `id` (`integer`): Id.
- `toggled` (`boolean`): Whether the button is toggled.
- `tooltip` (`string?`): Tooltip text.

##### Methods

- No documented methods.

#### LTooltipPanel Type

- Adds tooltip-panel-specific methods to a tooltip panel widget table.

##### Fields

- No documented fields.

##### Methods

- `LTooltipPanel:getDelay() -> number`: Returns the delay in seconds before this tooltip appears.
- `LTooltipPanel:getTarget() -> integer`: Returns the widget index that this tooltip is attached to.
- `LTooltipPanel:getText() -> string`: Returns the current tooltip display text.
- `LTooltipPanel:setDelay(v) -> nil`: Sets the delay in seconds before this tooltip appears.
- `LTooltipPanel:setTarget(target?) -> nil`: Sets the widget index that this tooltip is attached to.
- `LTooltipPanel:setText(text) -> nil`: Sets the tooltip panel display text content.

#### LTreeView Type

- Registers tree-view-specific Lua methods on a widget method table.

##### Fields

- No documented fields.

##### Methods

- `LTreeView:addNode(text, parent_index?) -> integer`: Adds a new node to this tree view, optionally under a parent node.
- `LTreeView:clearNodes() -> nil`: Removes all nodes from this tree view.
- `LTreeView:collapseAll() -> nil`: Collapses all nodes in this tree view.
- `LTreeView:collapseNode(index) -> boolean`: Collapses the node at the given 1-based index to hide its children.
- `LTreeView:expandAll() -> nil`: Expands all nodes in this tree view.
- `LTreeView:expandNode(index) -> boolean`: Expands the node at the given 1-based index to show its children.
- `LTreeView:getChildNodes(index) -> integer[]`: Returns a table of 1-based child node indices for the node at the given index.
- `LTreeView:getNodeCount() -> integer`: Returns the total number of nodes in this tree view.
- `LTreeView:getNodeDepth(index) -> integer`: Returns the nesting depth of the node at the given index (0 for root nodes).
- `LTreeView:getNodeText(index) -> string`: Returns the text of the node at the given 1-based index.
- `LTreeView:getParentNode(index) -> integer`: Returns the 1-based index of the parent of the node at the given index.
- `LTreeView:getSelectedNode() -> integer`: Returns the 1-based index of the currently selected node.
- `LTreeView:isExpanded(index) -> boolean`: Returns whether the node at the given 1-based index is currently expanded.
- `LTreeView:isNodeExpanded(index) -> boolean`: Returns whether the node at the given 1-based index is expanded. Returns nil if the index is invalid.
- `LTreeView:removeNode(index) -> boolean`: Removes the node at the given 1-based index from this tree view.
- `LTreeView:setNodeIcon(index, icon) -> boolean`: Sets the icon of the node at the given 1-based index.
- `LTreeView:setNodeText(index, text) -> boolean`: Sets the text of the node at the given 1-based index.
- `LTreeView:setSelectedNode(index) -> boolean`: Sets the selected node by 1-based index.
- `LTreeView:toggleNode(index) -> boolean`: Toggles the expanded/collapsed state of the node at the given 1-based index.

#### LUiWidget Type

- Creates a Lua table representing a widget with all shared base methods common to every widget type.

##### Fields

- No documented fields.

##### Methods

- `LUiWidget:addChild(child) -> nil`: Adds a child widget to this widget's hierarchy.
- `LUiWidget:animateAlpha(target, duration?, hide_on_complete?) -> table`: Smoothly animates this widget's opacity toward a target value over the given duration.
- `LUiWidget:animatePosition(x, y, duration?) -> table`: Smoothly animates this widget's position toward the target coordinates.
- `LUiWidget:bind(key) -> nil`: Binds this widget to a data key for use with update_bindings.
- `LUiWidget:cancelAnimations() -> boolean`: Cancels all active animations on this widget, leaving it at its current state.
- `LUiWidget:clearAnchor() -> nil`: Removes all anchor constraints from this widget.
- `LUiWidget:clearFont() -> nil`: Clears any font override on this widget so it inherits from its parent again.
- `LUiWidget:clearIcon() -> nil`: Clears this widget's assigned built-in icon.
- `LUiWidget:containsPoint(x, y) -> boolean`: Tests whether the given screen-space point is inside this widget's bounds.
- `LUiWidget:destroy(recursive?) -> integer`: Destroys this widget and, by default, its retained descendant subtree.
- `LUiWidget:fadeIn() -> nil`: Instantly makes this widget fully opaque and visible.
- `LUiWidget:fadeOut() -> nil`: Instantly makes this widget fully transparent and hidden.
- `LUiWidget:findById(id) -> LWidget`: Searches this widget's subtree for a child with the given ID.
- `LUiWidget:getAlpha() -> number`: Returns the current opacity of this widget.
- `LUiWidget:getAriaName() -> string`: Returns the explicit accessible name metadata for this widget.
- `LUiWidget:getChildCount() -> integer`: Returns the number of direct child widgets attached to this widget.
- `LUiWidget:getChildren() -> LUiWidget[]`: Returns live typed child widget handles. Their printable `_idx` field is diagnostic only and is never mutation authority.
- `LUiWidget:getFlexGrow() -> number`: Returns the flex-grow factor of this widget.
- `LUiWidget:getFlexShrink() -> number`: Returns the flex-shrink factor of this widget.
- `LUiWidget:getIcon() -> string|nil`: Returns this widget's assigned built-in icon name, or nil when no icon is assigned.
- `LUiWidget:getIconPosition() -> string`: Returns this widget's icon placement token.
- `LUiWidget:getIconSize() -> number`: Returns this widget's requested icon size in pixels.
- `LUiWidget:getId() -> string`: Returns the string identifier assigned to this widget.
- `LUiWidget:getLabelFor() -> LUiWidget?`: Returns the live widget handle associated through `setLabelFor`, or nil.
- `LUiWidget:getMargin() -> number, number, number, number`: Returns the outer margin of this widget.
- `LUiWidget:getMaxSize() -> number, number`: Returns the maximum width and height of this widget.
- `LUiWidget:getMinSize() -> number, number`: Returns the minimum width and height of this widget.
- `LUiWidget:getMouseFilter() -> string`: Returns the mouse filter of this widget.
- `LUiWidget:getPadding() -> number, number, number, number`: Returns the inner padding of this widget.
- `LUiWidget:getPosition() -> number, number`: Returns the local position of this widget relative to its parent.
- `LUiWidget:getRect() -> number, number, number, number`: Returns the computed bounding rectangle of this widget in screen coordinates after layout.
- `LUiWidget:getRole() -> string`: Returns the semantic role string for this widget.
- `LUiWidget:getSize() -> number, number`: Returns the width and height of this widget.
- `LUiWidget:getState() -> string`: Returns the current interaction state of this widget (e.g. "normal", "hovered", "pressed", "disabled").
- `LUiWidget:getStyleClass() -> string`: Returns the style class of this widget.
- `LUiWidget:getTextAlign() -> string`: Returns this widget's horizontal text alignment.
- `LUiWidget:getTooltip() -> string`: Returns the tooltip text of this widget.
- `LUiWidget:getZOrder() -> integer`: Returns the z-order (draw priority) of this widget.
- `LUiWidget:isAnimating() -> boolean`: Returns whether this widget currently has an active animation.
- `LUiWidget:isDragEnabled() -> boolean`: Returns whether pointer-initiated drag-and-drop is enabled for this widget.
- `LUiWidget:isDropEnabled() -> boolean`: Returns whether this widget accepts pointer drag-and-drop operations.
- `LUiWidget:isEnabled() -> boolean`: Returns whether this widget is currently enabled and can receive input.
- `LUiWidget:isValid() -> boolean`: Returns whether this widget handle still identifies a live widget in its originating UI context.
- `LUiWidget:isVisible() -> boolean`: Returns whether this widget is currently visible.
- `LUiWidget:removeChild(child) -> nil`: Removes a child widget from this widget's hierarchy.
- `LUiWidget:setAlpha(alpha) -> nil`: Sets the opacity of this widget, clamped to 0.0 (fully transparent) through 1.0 (fully opaque).
- `LUiWidget:setAnchor(left?, top?, right?, bottom?) -> nil`: Anchors this widget to its parent's edges. Pass nil for any side to leave it unanchored.
- `LUiWidget:setAnchorCenter(cx?, cy?) -> nil`: Centers this widget within its parent using proportional anchor offsets (0.0 to 1.0).
- `LUiWidget:setAriaName(name) -> nil`: Sets the accessible name metadata for this widget.
- `LUiWidget:setBindKey(key) -> boolean`: Binds this widget to a data key and reports whether the widget exists.
- `LUiWidget:setDragEnabled(enabled) -> boolean`: Enables or disables pointer-initiated drag-and-drop for this widget. Defaults to disabled.
- `LUiWidget:setDropEnabled(enabled) -> boolean`: Enables or disables this widget as a pointer drag-and-drop target. Defaults to disabled; enabling promotes an ignored mouse filter to `"stop"`.
- `LUiWidget:setEnabled(v) -> nil`: Enables or disables this widget. Disabled widgets appear grayed out and ignore input.
- `LUiWidget:setFlexGrow(grow) -> nil`: Sets the flex-grow factor controlling how much extra space this widget receives in a layout.
- `LUiWidget:setFlexShrink(shrink) -> nil`: Sets the flex-shrink factor controlling how much this widget shrinks when layout space is insufficient.
- `LUiWidget:setFocusGroup(group) -> nil`: Sets the focus traversal group for this widget.
- `LUiWidget:setFocusNeighbor(direction, target?) -> boolean`: Sets an explicit directional focus neighbor for this widget.
- `LUiWidget:setFocusable(value) -> nil`: Sets whether this widget participates in keyboard focus traversal.
- `LUiWidget:setFont(font) -> nil`: Assigns a specific font to this widget and its descendants unless overridden further down the tree.
- `LUiWidget:setIcon(icon) -> boolean`: Sets this widget's built-in UI icon by semantic name.
- `LUiWidget:setIconPosition(position) -> boolean`: Sets where this widget's icon is placed relative to its text.
- `LUiWidget:setIconSize(size) -> boolean`: Sets this widget's requested icon size in pixels.
- `LUiWidget:setId(id) -> nil`: Assigns a string identifier to this widget for lookup with findById.
- `LUiWidget:setLabelFor(target?) -> nil`: Associates this label widget with another widget for accessibility naming.
- `LUiWidget:setMargin(top, right?, bottom?, left?) -> nil`: Sets the outer margin of this widget. Accepts 1 to 4 values (top, right?, bottom?, left?) following CSS shorthand rules.
- `LUiWidget:setMaxSize(w, h) -> nil`: Sets the maximum allowed width and height for this widget during layout.
- `LUiWidget:setMinSize(w, h) -> nil`: Sets the minimum allowed width and height for this widget during layout.
- `LUiWidget:setMouseFilter(filter) -> boolean`: Sets the mouse filter for this widget ("stop", "pass", "ignore").
- `LUiWidget:setOnChange(f) -> nil`: Registers a callback function invoked when this widget's value changes.
- `LUiWidget:setOnClick(f) -> nil`: Registers a callback function invoked when this widget is clicked.
- `LUiWidget:setOnDragEnd(f) -> nil`: Registers a callback invoked when a drag from this widget ends.
- `LUiWidget:setOnDragEnter(f) -> nil`: Registers a callback invoked when a dragged widget enters this drop target.
- `LUiWidget:setOnDragLeave(f) -> nil`: Registers a callback invoked when a dragged widget leaves this drop target.
- `LUiWidget:setOnDragStart(f) -> nil`: Registers a callback invoked when a drag starts from this widget.
- `LUiWidget:setOnDraw(f) -> nil`: Registers a custom draw callback for this widget, invoked each frame during the draw pass.
- `LUiWidget:setOnDrop(f) -> nil`: Registers a callback invoked after a dragged widget is dropped onto this target.
- `LUiWidget:setPadding(top, right?, bottom?, left?) -> nil`: Sets the inner padding of this widget. Accepts 1 to 4 values (top, right?, bottom?, left?) following CSS shorthand rules.
- `LUiWidget:setPosition(x, y) -> nil`: Sets the local position of this widget relative to its parent.
- `LUiWidget:setRole(role) -> nil`: Sets a semantic role string for this widget.
- `LUiWidget:setShader(shader?, opts?) -> nil`: Binds or clears a render-owned UI shader for this widget subtree.
- `LUiWidget:setShaderLayer(name, shader?, opts?) -> nil`: Binds or clears a named render-owned UI shader layer for this widget subtree.
- `LUiWidget:setSize(w, h) -> nil`: Sets the width and height of this widget in pixels.
- `LUiWidget:setStyleClass(class) -> boolean`: Sets the style class of this widget.
- `LUiWidget:setTabIndex(value) -> nil`: Sets the tab-order index for this widget.
- `LUiWidget:setTextAlign(align) -> boolean`: Sets the horizontal alignment of text inside this widget.
- `LUiWidget:setTextEllipsis(ellipsis) -> nil`: Enables or disables ellipsis clipping for overflowing single-line text.
- `LUiWidget:setTextVAlign(align) -> boolean`: Sets the vertical alignment of text inside this widget.
- `LUiWidget:setTextWrap(wrap) -> nil`: Enables or disables word-wrap for text inside this widget.
- `LUiWidget:setTooltip(text) -> nil`: Sets the tooltip text shown when the user hovers over this widget.
- `LUiWidget:setVisible(v) -> nil`: Shows or hides this widget. Hidden widgets are not drawn and do not receive input.
- `LUiWidget:setZOrder(z) -> nil`: Sets the z-order (draw priority) of this widget. Higher values draw on top.
- `LUiWidget:slideIn(x, y) -> nil`: Moves this widget to the given position and makes it visible.
- `LUiWidget:slideOut(x, y) -> nil`: Moves this widget to the given position and hides it.
- `LUiWidget:type() -> string`: Returns the type name string of this widget (e.g. "LButton", "LSlider").
- `LUiWidget:typeOf(name) -> boolean`: Checks whether this widget matches the given type name, including base types "LWidget" and "Object".
- `LUiWidget:unbind() -> nil`: Removes the data binding from this widget.

#### LUiWidgetGetChildrenResult Type

- Generated result shape from @field tags.

##### Fields

- `_idx` (`integer`): Diagnostic storage slot; never authoritative.

##### Methods

- No documented methods.

## Examples

- `content/examples/ui.lua` (present)

## Architecture Links

- [UI module scope boundary](../../architecture/module-scope-boundaries.md#ui-boundary)
- [Rendering pipeline](../../architecture/render-pipeline.md) owns GPU execution and command capture.
- [Scripting bridge](../../architecture/scripting-bridge.md) owns Lua-side input and GameFS boundary behavior.
- [Runtime tooling boundaries](../../architecture/runtime-tooling-boundaries.md) defines GameFS reads and authorized capture writes.

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
