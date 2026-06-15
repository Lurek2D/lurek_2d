# ui

## TL;DR

- Centralized retained-mode UI context with arena storage, automatic layouts, and resolution scaling.
- Rich control catalog featuring standard inputs, numeric steppers, combo selections, and visual containers.
- Supports resizable window shells, modal dialog triggers, and nine-slice border-stretching layouts.
- Declarative TOML layouts, semantic theme tokens, alpha-aware animations, and drag-and-drop event dispatching.
- Integrates retained widgets, theme/layout flows, and headless screenshot exports.

## General Info

- Module group: `Feature Systems`
- Source path: `src/ui/`
- Binding: `src/lua_api/ui_api.rs`
- Namespace: `lurek.ui`
- Lua API surface: `90` functions, `39` types, `331` methods
- Rust test path(s): tests/rust/unit/gui_tests.rs
- Lua test path(s): tests/lua/unit/test_gui.lua, tests/lua/unit/test_ui_input_unit.lua, tests/lua/unit/test_ui_layout.lua, tests/lua/integration/test_i18n_ui.lua

## Summary

- The ui module provides a retained-mode interface system for HUDs, menus, overlays, and tool screens.
- Dialogs now act as full popup windows with modal or non-modal behavior, footer slots, semantic actions, default/cancel shortcuts, and close-policy controls.
- Popup shells support shared drag and resize behavior with viewport clamping, so dialogs and tool windows stay aligned in runtime behavior and rendering defaults.
- It centralizes widget ownership in a context-managed arena with stable handles.
- Stable IDs make per-frame mutation safe for large interactive trees.
- The context owns lifecycle, layout, input routing, and event queue behavior.
- Root scaling controls support DPI-aware rendering across resolutions.
- Layout is recursive and deterministic from root to leaf bounds.
- Container primitives include vertical, horizontal, grid, split, and dock arrangements.
- Scrollable containers support overflow while preserving parent layout contracts.
- Window containers support dragging and resizing interactions.
- Nine-patch support preserves border fidelity under scale changes.
- Widget base state captures visibility, interaction flags, and style links.
- Shared state semantics keep hover, focus, and press behavior consistent.
- Focus traversal supports sequential and geometric navigation modes.
- Keyboard-driven UI is supported without mouse-only assumptions.
- Input events are normalized into frame-coherent dispatch.
- Event queues allow deterministic script-side consumption order.
- Drag-and-drop lifecycle is explicit from begin to drop/cancel.
- Parent-child safety checks prevent cyclic widget relationships.
- Core controls include button, label, input, checkbox, radio, slider, and spinbox.
- Additional controls include list, combo, progress, separator, and spacer variants.
- Extended widgets include dialogs, menus, tree views, toolbars, and badges.
- Notification/toast systems provide transient user feedback primitives.
- Charts are owned by `lurek.charts`; `lurek.ui` should not expose chart constructors or chart-specific rendering wrappers.
- Telemetry and analytics data can still be presented inside UI layouts by embedding textures or images produced by other modules.
- DataFrame integration in this module stays focused on table/grid presentation and layout-driven UI flows.
- Theming maps widget type/state to style records and semantic tokens.
- Style records include colors, borders, shadows, spacing, and typography knobs.
- Fallback style resolution keeps partial themes functional.
- Theme tokenization supports global skin changes with low churn.
- Rendering converts widget tree state into shared draw command primitives.
- Headless software rendering supports screenshot and regression test flows.
- Headless output allows CI verification without a window backend.
- Text measurement is integrated with active font context and alignment rules.
- Global and per-widget font overrides are both supported.
- Animation channels include alpha, scale, rotation, and color transitions.
- Animation updates are integrated in context progression each frame.
- Data bindings synchronize widget values with script-managed keys.
- Binding utilities reduce repetitive synchronization code.
- Layout loading supports TOML-defined UI structures.
- Lua table definitions can also be loaded into runtime widget trees.
- Data-driven layouts speed iteration without Rust-side recompilation.
- Render signatures and cache controls reduce unnecessary full recomputation.
- Widget count and cache APIs support runtime diagnostics.
- Clear/reset APIs support controlled tree rebuild scenarios.
- The module supports both lightweight HUDs and complex editor-like screens.
- It is designed for predictable behavior under heavy UI mutation.
- Ownership boundaries separate widget semantics from gameplay domain logic.
- Integration with runtime and render remains explicit and acyclic.
- Geometry and color helpers are consumed through math/color modules.
- The module does not own business logic; it owns presentation and interaction contracts.
- Deterministic traversal order is a core invariant.
- Stable widget handle lifetime is a core invariant.
- Layout consistency across scale changes is a core invariant.
- Style fallback correctness is a core invariant.
- Event ordering guarantees are required for reproducible interaction behavior.
- The API surface is broad but internally structured by focused submodules.
- Context, controls, containers, theme, and render layers remain separated.
- This separation keeps maintenance practical as feature count grows.
- The module supports accessibility-oriented keyboard navigation paths.
- It supports tool-facing UI and in-game UI with one runtime model.
- It enables rapid prototyping while staying production-capable.
- Headless rendering makes visual QA automatable in test pipelines.
- Theme tokens make large-scale visual changes manageable.
- Drag/drop support enables inventory and editor workflows.
- Chart widgets make telemetry and debugging views first-class.
- The retained model reduces imperative draw boilerplate in scripts.
- It improves readability and maintainability of complex interface flows.
- The module is a key user-facing layer in Feature Systems.
- It bridges gameplay state and player interaction with deterministic contracts.
- It is designed for reliability under both runtime and tooling workloads.
- Overall, ui is the canonical interface subsystem in Lurek2D.
- It closes the full loop of definition, layout, input, animation, and rendering.
- It provides the structure needed to scale UI complexity without architectural drift.
- The subsystem remains testable, observable, and extensible by design.
- This balance of flexibility and control is its primary architectural value.
- It is intended to remain the long-term UI foundation across project types.
- The module's contracts prioritize stability as screen complexity grows.
- It gives teams one consistent UI language for game and tool surfaces.

This module primarily collaborates with `color`, `dataframe`, `image`, `math`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Imports

- `dataframe`: Imports or references `src/dataframe/`. Cross-group dependency from `Feature Systems` into `Foundations`.
- `image`: Imports or references `image` from `src/image/`.
- `math`: Imports or references `math` from `src/math/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### containers.rs

- This file provides retained-mode UI containers that structure complex screen hierarchies.
- It defines panels, layouts, windows, splits, and docks as composable spatial building blocks.
- It drives vertical, horizontal, and grid arrangement with stable spacing and alignment rules.
- It supplies scrollable viewports for overflowed content without breaking parent layout flow.
- It supports nine-slice framing so scalable borders keep visual intent across resolutions.
- It enables draggable and resizable window shells for tool-like and in-game interface scenes.
- It anchors container semantics that other widgets rely on for predictable composition.

### context.rs

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

### controls.rs

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

### extras.rs

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

### layout_loader.rs

- This file provides declarative UI loading from TOML definitions into live widget trees.
- It maps textual widget kinds onto concrete context constructors with consistent defaults.
- It applies generic and type-specific properties so authored layouts become runtime-ready.
- It supports recursive child structures that mirror retained parent-child composition.
- It offers headless image rendering for snapshot checks and offline layout verification.
- It enables fast iteration on UI structure without hardcoding full trees in Lua scripts.

### mod.rs

- This module delivers the full retained UI toolkit used by gameplay and tooling layers.
- It combines context, widgets, containers, rendering, and theming into one coherent surface.
- It keeps interface construction flexible through code-first and data-driven layout paths.

### render.rs

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

### theme.rs

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

### widget.rs

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



## Lua API Ref

### Functions

- `lurek.ui.addToast(toast_table) -> nil`: Adds a toast notification to the queue.
- `lurek.ui.animateColor(idx, from, to, duration, easing?) -> nil`: Animate widget color tint from one RGBA value to another.
- `lurek.ui.animateRotation(idx, from, to, duration, easing?) -> nil`: Animate widget rotation from one angle to another (in radians).
- `lurek.ui.animateScale(idx, from_sx, from_sy, to_sx, to_sy, duration, easing?) -> nil`: Animate widget scale from one value to another.
- `lurek.ui.beginDrag(widget) -> boolean`: Begins a drag operation on a widget.
- `lurek.ui.clear() -> integer`: Clears all retained UI widgets and transient UI state while keeping the active theme.
- `lurek.ui.clearFocus() -> nil`: Clears keyboard focus from all widgets.
- `lurek.ui.clearFont() -> nil`: Clears the global UI font override so the UI falls back to the active render font again.
- `lurek.ui.draw() -> nil`: Invokes custom draw callbacks for all widgets that have one registered.
- `lurek.ui.drawToImage(w, h) -> LImageData`: Renders the entire UI to an image buffer.
- `lurek.ui.dropOn(target) -> boolean`: Drops the currently dragged widget onto a target widget.
- `lurek.ui.endDrag() -> integer`: Ends the current drag operation without dropping.
- `lurek.ui.flushCache() -> boolean`: Flushes internal UI layout and render caches.
- `lurek.ui.focusDirection(dx, dy) -> boolean`: Move focus in a spatial direction. Uses geometry to find nearest focusable widget.
- `lurek.ui.focusNeighbor(direction) -> boolean`: Moves keyboard focus using an explicit directional focus link.
- `lurek.ui.focusNext() -> nil`: Moves keyboard focus to the next focusable widget.
- `lurek.ui.focusPrev() -> nil`: Moves keyboard focus to the previous focusable widget.
- `lurek.ui.getActiveDrag() -> integer`: Returns the widget index currently being dragged, or nil.
- `lurek.ui.getFocus() -> integer`: Returns the index of the currently focused widget, or nil.
- `lurek.ui.getFont() -> LFont`: Returns the global UI font assigned to the root widget, or nil when UI uses the render fallback font.
- `lurek.ui.getRoot() -> LPanel`: Returns the root panel widget of the UI tree.
- `lurek.ui.getScaleFactor() -> number`: Get the current UI scale factor (current_height / base_height).
- `lurek.ui.getStyleToken(name) -> number`: Returns the value of a named semantic style token from the active theme.
- `lurek.ui.getTheme() -> boolean`: Returns whether a theme is currently set.
- `lurek.ui.getToastCount() -> integer`: Returns the number of active toast notifications.
- `lurek.ui.getWidgetCount() -> integer`: Returns the total number of widgets in the UI context.
- `lurek.ui.getWidgetFont(widget) -> LFont`: Returns the font override assigned to a widget, or nil when the widget inherits its font from a parent.
- `lurek.ui.hasAutoInput() -> boolean`: Returns whether platform input is automatically forwarded to `lurek.ui`.
- `lurek.ui.hasAutoUpdate() -> boolean`: Returns whether `lurek.ui.update(dt)` is called automatically each frame.
- `lurek.ui.keypressed(key) -> boolean`: Delivers a key press event to the UI.
- `lurek.ui.loadLayout(def) -> integer`: Loads a UI layout from a Lua table definition.
- `lurek.ui.loadLayoutFile(path) -> integer`: Loads a UI layout from a TOML layout file.
- `lurek.ui.loadLayoutGameFile(path) -> integer`: Loads a UI layout from a TOML file resolved through GameFS.
- `lurek.ui.mousemoved(x, y) -> boolean`: Delivers a mouse move event to the UI.
- `lurek.ui.mousepressed(x, y, btn?) -> boolean`: Delivers a mouse press event to the UI.
- `lurek.ui.mousereleased(x, y, btn?) -> boolean`: Delivers a mouse release event to the UI.
- `lurek.ui.newAccordion() -> LAccordion`: Creates a new accordion widget with collapsible sections.
- `lurek.ui.newBadge(count?) -> LBadge`: Creates a new badge widget for displaying counts.
- `lurek.ui.newButton(text?) -> LButton`: Creates a new button widget with optional label text.
- `lurek.ui.newCheckbox(text?) -> LCheckbox`: Creates a new checkbox widget with optional label.
- `lurek.ui.newColorPicker() -> LColorPicker`: Creates a new color picker widget for color selection.
- `lurek.ui.newComboBox() -> LComboBox`: Creates a new combo box (drop-down) widget.
- `lurek.ui.newCustomWidget(config?) -> LUiWidget`: Creates a new custom widget with optional initial configuration.
- `lurek.ui.newDialog(title?) -> LDialog`: Creates a new dialog widget with an optional title.
- `lurek.ui.newDockPanel() -> LDockPanel`: Creates a new dock panel widget for docking child widgets to sides.
- `lurek.ui.newImageWidget() -> LImageWidget`: Creates a new image display widget.
- `lurek.ui.newLabel(text?) -> LLabel`: Creates a new label widget for displaying text.
- `lurek.ui.newLayout(direction?) -> LLayout`: Creates a new layout container widget.
- `lurek.ui.newList() -> LListBox`: Creates a new list box widget for item selection.
- `lurek.ui.newMenuBar() -> LMenuBar`: Creates a new menu bar widget for top-level menus.
- `lurek.ui.newMenuItem(text?) -> LMenuItem`: Creates a new menu item widget with optional text.
- `lurek.ui.newNinePatch() -> LNinePatch`: Creates a new nine-patch widget for scalable bordered images.
- `lurek.ui.newPanel() -> LPanel`: Creates a new panel widget (container).
- `lurek.ui.newProgressBar(min?, max?) -> LProgressBar`: Creates a new progress bar widget with min and max.
- `lurek.ui.newRadioButton(text?, group?) -> LRadioButton`: Creates a new radio button widget in a named group.
- `lurek.ui.newScrollBar(vertical?) -> LScrollBar`: Creates a new scroll bar widget for content scrolling.
- `lurek.ui.newScrollPanel() -> LScrollPanel`: Creates a new scrollable panel widget.
- `lurek.ui.newSeparator(vertical?) -> LSeparator`: Creates a new separator widget for visual division.
- `lurek.ui.newSlider(min?, max?) -> LSlider`: Creates a new slider widget with adjustable range.
- `lurek.ui.newSpacer(w?, h?) -> LSpacer`: Creates a new spacer widget for spacing between other widgets.
- `lurek.ui.newSpinBox(min?, max?) -> LSpinBox`: Creates a new spin box (numeric stepper) widget.
- `lurek.ui.newSplitPanel(orientation?) -> LSplitPanel`: Creates a new split panel widget with two resizable sub-panels.
- `lurek.ui.newStatusBar() -> LStatusBar`: Creates a new status bar widget for app-level info.
- `lurek.ui.newSwitch(on?) -> LSwitch`: Creates a new toggle switch widget.
- `lurek.ui.newTabBar() -> LTabBar`: Creates a new tab bar widget for tabbed navigation.
- `lurek.ui.newTable() -> LGuiTable`: Creates a new table widget for tabular data display.
- `lurek.ui.newTextInput() -> LTextInput`: Creates a new text input widget for user entry.
- `lurek.ui.newTheme() -> LTheme`: Creates a new UI theme for styling widgets.
- `lurek.ui.newToast(message?, duration?) -> LToast`: Creates a new toast notification widget.
- `lurek.ui.newToolbar(orientation?) -> LToolbar`: Creates a new toolbar widget for action buttons.
- `lurek.ui.newTooltipPanel(text?) -> LTooltipPanel`: Creates a new tooltip panel widget.
- `lurek.ui.newTreeView() -> LTreeView`: Creates a new tree view widget for hierarchical data.
- `lurek.ui.newWindow(title?) -> LGuiWindow`: Creates a new GUI window widget with an optional title.
- `lurek.ui.parseWidgetState(state) -> string`: Validates and normalizes a widget state string.
- `lurek.ui.renderToImage(pathOrWidth, widthOrHeight, heightOrPath) -> nil`: Renders the entire UI to a PNG image file.
- `lurek.ui.setAutoInput(enabled) -> nil`: Enables or disables automatic forwarding of platform mouse, wheel, key, and text input to `lurek.ui`.
- `lurek.ui.setAutoUpdate(enabled) -> nil`: Enables or disables automatic `lurek.ui.update(dt)` calls during the frame update.
- `lurek.ui.setBaseResolution(width, height) -> nil`: Set the logical base resolution the UI was designed for.
- `lurek.ui.setDefaultTheme() -> nil`: Applies the built-in default theme to the UI context.
- `lurek.ui.setFocus(widget?) -> nil`: Sets keyboard focus to a widget, or clears focus if nil.
- `lurek.ui.setFont(font) -> nil`: Sets the global UI font by applying it to the root widget.
- `lurek.ui.setTheme(theme_ud) -> nil`: Applies a theme to the entire UI context.
- `lurek.ui.setViewport(w, h) -> nil`: Sets the viewport size for the UI context.
- `lurek.ui.textinput(text) -> boolean`: Delivers a text input event to the UI.
- `lurek.ui.update(dt) -> nil`: Updates the UI context and dispatches pending events to callbacks.
- `lurek.ui.updateBindings(data) -> integer`: Updates data bindings for widgets that reference binding keys.
- `lurek.ui.updateResolution(width, height) -> nil`: Update the current viewport resolution and recompute UI scale factor.
- `lurek.ui.update_bindings(data) -> integer`: Updates data bindings for widgets that reference binding keys.
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
- `LUiWidget:setOnDraw` param `f` (`function`): Callback receiving a rect table {x, y, w, h} with the computed bounds.

### Enums

- No documented module-level enums/constants.

### Types

#### LAccordion Type

- Adds accordion-specific methods to an accordion widget table.

##### Fields

- No documented fields.

##### Methods

- `LAccordion:addSection(title, content_idx?) -> nil`: Adds a collapsible section to this accordion.
- `LAccordion:getSectionCount() -> integer`: Returns the number of sections in this accordion.
- `LAccordion:getSectionTitle(section_idx) -> string`: Returns the title of an accordion section by its 1-based index.
- `LAccordion:isExclusive() -> boolean`: Returns whether this accordion is in exclusive mode (only one section open at a time).
- `LAccordion:isSectionExpanded(section_idx) -> boolean`: Returns whether an accordion section is expanded.
- `LAccordion:setExclusive(v) -> nil`: Sets exclusive mode. When true, expanding one section collapses all others.
- `LAccordion:toggleSection(section_idx) -> boolean`: Toggles the expanded state of an accordion section by its 1-based index.

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
- `LComboBox:getSelectedIndex() -> integer`: Returns the 1-based index of the currently selected item, or 0 if none is selected.
- `LComboBox:getSelectedItem() -> string`: Returns the text of the currently selected item, or nil if none is selected.
- `LComboBox:removeItem(index) -> boolean`: Removes the item at the given 1-based index from this combo box.
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
- `LDialog:setContent(content_idx?) -> nil`: Sets the widget index rendered as this dialog's content.
- `LDialog:setDefaultAction(index?) -> nil`: Sets the action triggered by Enter, using a 1-based action index.
- `LDialog:setDismissOnOutsideClick(value) -> nil`: Controls whether clicking outside a non-modal dialog closes it.
- `LDialog:setDraggable(value) -> nil`: Enables or disables title-bar dragging for this dialog.
- `LDialog:setFooter(footer_idx?) -> nil`: Assigns an optional footer content root for this dialog.
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

- `LDockPanel:dock(child_idx, side) -> nil`: Docks a child widget to the specified side of this dock panel.
- `LDockPanel:getDockedCount() -> integer`: Returns the number of widgets docked in this dock panel.
- `LDockPanel:getSplitSize(side) -> number`: Returns the size configured for a dock panel side region.
- `LDockPanel:setSplitSize(side, size) -> nil`: Sets the size of a dock panel side region.
- `LDockPanel:undock(child_idx) -> nil`: Removes a child widget from this dock panel.

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

- `LMenuBar:addMenu(menu_idx) -> nil`: Adds a menu (by its widget index) to this menu bar.
- `LMenuBar:getMenuCount() -> integer`: Returns the number of menus in this menu bar.
- `LMenuBar:getMenus() -> integer[]`: Returns a table of widget indices for all menus in this menu bar.
- `LMenuBar:removeMenu(menu_idx) -> boolean`: Removes a menu from this menu bar by its widget index.

#### LMenuItem Type

- Adds menu-item-specific methods to a menu item widget table.

##### Fields

- No documented fields.

##### Methods

- `LMenuItem:addSubItem(child_idx) -> nil`: Adds a sub-item to this menu item for building nested menus.
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
- `LSplitPanel:setFirstChild(child_idx) -> nil`: Sets the widget index for the first (left/top) panel.
- `LSplitPanel:setMinPanelSize(v) -> nil`: Sets the minimum pixel size of each split sub-panel.
- `LSplitPanel:setOrientation(v) -> nil`: Sets the orientation of this split panel ("horizontal" or "vertical").
- `LSplitPanel:setSecondChild(child_idx) -> nil`: Sets the widget index for the second (right/bottom) panel.
- `LSplitPanel:setSplitPosition(v) -> nil`: Sets the split position as a fraction (0.0 to 1.0).

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
- `LStatusBar:setSectionWidget(section_idx, widget?) -> nil`: Associates a widget with a status bar section (reserved for future use).

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

#### LTextInput Type

- Adds text-input-specific methods to a text input widget table.

##### Fields

- No documented fields.

##### Methods

- `LTextInput:getCursorPosition() -> integer`: Returns the current cursor position (character index) within the text input.
- `LTextInput:getPlaceholder() -> string`: Returns the placeholder text of this text input.
- `LTextInput:getText() -> string`: Returns the current text content of this text input field.
- `LTextInput:isFocused() -> boolean`: Returns whether this text input currently has keyboard focus.
- `LTextInput:setMaxLength(n) -> nil`: Sets the maximum number of characters allowed in this text input.
- `LTextInput:setPlaceholder(text) -> nil`: Sets the placeholder text shown when the input is empty.
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
- `LToolbar:addSpacer(_size?) -> nil`: Adds a flexible spacer to this toolbar.
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
- `LUiWidget:attachToEntity(entity_id) -> nil`: Attaches this widget to a game entity so it follows the entity's position on screen.
- `LUiWidget:bind(key) -> nil`: Binds this widget to a data key for use with update_bindings.
- `LUiWidget:cancelAnimations() -> boolean`: Cancels all active animations on this widget, leaving it at its current state.
- `LUiWidget:clearAnchor() -> nil`: Removes all anchor constraints from this widget.
- `LUiWidget:clearFont() -> nil`: Clears any font override on this widget so it inherits from its parent again.
- `LUiWidget:containsPoint(x, y) -> boolean`: Tests whether the given screen-space point is inside this widget's bounds.
- `LUiWidget:detachFromEntity() -> nil`: Detaches this widget from any previously attached entity.
- `LUiWidget:fadeIn() -> nil`: Instantly makes this widget fully opaque and visible.
- `LUiWidget:fadeOut() -> nil`: Instantly makes this widget fully transparent and hidden.
- `LUiWidget:findById(id) -> LWidget`: Searches this widget's subtree for a child with the given ID.
- `LUiWidget:getAlpha() -> number`: Returns the current opacity of this widget.
- `LUiWidget:getChildCount() -> integer`: Returns the number of direct child widgets attached to this widget.
- `LUiWidget:getChildren() -> table`: Returns a table of lightweight child widget references, each containing an _idx field.
- `LUiWidget:getFlexGrow() -> number`: Returns the flex-grow factor of this widget.
- `LUiWidget:getFlexShrink() -> number`: Returns the flex-shrink factor of this widget.
- `LUiWidget:getId() -> string`: Returns the string identifier assigned to this widget.
- `LUiWidget:getMargin() -> number, number, number, number`: Returns the outer margin of this widget.
- `LUiWidget:getMaxSize() -> number, number`: Returns the maximum width and height of this widget.
- `LUiWidget:getMinSize() -> number, number`: Returns the minimum width and height of this widget.
- `LUiWidget:getMouseFilter() -> string`: Returns the mouse filter of this widget.
- `LUiWidget:getPadding() -> number, number, number, number`: Returns the inner padding of this widget.
- `LUiWidget:getPosition() -> number, number`: Returns the local position of this widget relative to its parent.
- `LUiWidget:getRect() -> number, number, number, number`: Returns the computed bounding rectangle of this widget in screen coordinates after layout.
- `LUiWidget:getSize() -> number, number`: Returns the width and height of this widget.
- `LUiWidget:getState() -> string`: Returns the current interaction state of this widget (e.g. "normal", "hovered", "pressed", "disabled").
- `LUiWidget:getStyleClass() -> string`: Returns the style class of this widget.
- `LUiWidget:getTextAlign() -> string`: Returns this widget's horizontal text alignment.
- `LUiWidget:getTooltip() -> string`: Returns the tooltip text of this widget.
- `LUiWidget:getZOrder() -> integer`: Returns the z-order (draw priority) of this widget.
- `LUiWidget:isAnimating() -> boolean`: Returns whether this widget currently has an active animation.
- `LUiWidget:isEnabled() -> boolean`: Returns whether this widget is currently enabled and can receive input.
- `LUiWidget:isVisible() -> boolean`: Returns whether this widget is currently visible.
- `LUiWidget:removeChild(child) -> nil`: Removes a child widget from this widget's hierarchy.
- `LUiWidget:setAlpha(alpha) -> nil`: Sets the opacity of this widget, clamped to 0.0 (fully transparent) through 1.0 (fully opaque).
- `LUiWidget:setAnchor(left?, top?, right?, bottom?) -> nil`: Anchors this widget to its parent's edges. Pass nil for any side to leave it unanchored.
- `LUiWidget:setAnchorCenter(cx?, cy?) -> nil`: Centers this widget within its parent using proportional anchor offsets (0.0 to 1.0).
- `LUiWidget:setAriaName(name) -> nil`: Sets the accessible name metadata for this widget.
- `LUiWidget:setBindKey(key) -> boolean`: Binds this widget to a data key and reports whether the widget exists.
- `LUiWidget:setEnabled(v) -> nil`: Enables or disables this widget. Disabled widgets appear grayed out and ignore input.
- `LUiWidget:setFlexGrow(grow) -> nil`: Sets the flex-grow factor controlling how much extra space this widget receives in a layout.
- `LUiWidget:setFlexShrink(shrink) -> nil`: Sets the flex-shrink factor controlling how much this widget shrinks when layout space is insufficient.
- `LUiWidget:setFocusGroup(group) -> nil`: Sets the focus traversal group for this widget.
- `LUiWidget:setFocusNeighbor(direction, target?) -> boolean`: Sets an explicit directional focus neighbor for this widget.
- `LUiWidget:setFocusable(value) -> nil`: Sets whether this widget participates in keyboard focus traversal.
- `LUiWidget:setFont(font) -> nil`: Assigns a specific font to this widget and its descendants unless overridden further down the tree.
- `LUiWidget:setId(id) -> nil`: Assigns a string identifier to this widget for lookup with findById.
- `LUiWidget:setMargin(top, right?, bottom?, left?) -> nil`: Sets the outer margin of this widget. Accepts 1 to 4 values (top, right?, bottom?, left?) following CSS shorthand rules.
- `LUiWidget:setMaxSize(w, h) -> nil`: Sets the maximum allowed width and height for this widget during layout.
- `LUiWidget:setMinSize(w, h) -> nil`: Sets the minimum allowed width and height for this widget during layout.
- `LUiWidget:setMouseFilter(filter) -> boolean`: Sets the mouse filter for this widget ("stop", "pass", "ignore").
- `LUiWidget:setOnChange(f) -> nil`: Registers a callback function invoked when this widget's value changes.
- `LUiWidget:setOnClick(f) -> nil`: Registers a callback function invoked when this widget is clicked.
- `LUiWidget:setOnDraw(f) -> nil`: Registers a custom draw callback for this widget, invoked each frame during the draw pass.
- `LUiWidget:setPadding(top, right?, bottom?, left?) -> nil`: Sets the inner padding of this widget. Accepts 1 to 4 values (top, right?, bottom?, left?) following CSS shorthand rules.
- `LUiWidget:setPosition(x, y) -> nil`: Sets the local position of this widget relative to its parent.
- `LUiWidget:setRole(role) -> nil`: Sets a semantic role string for this widget.
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

- `_idx` (`integer`): Widget index.

##### Methods

- No documented methods.

## References

- `dataframe`: Imports or references `src/dataframe/`. Cross-group dependency from `Feature Systems` into `Foundations`.
- `image`: Imports or references `image` from `src/image/`.
- `math`: Imports or references `math` from `src/math/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- No additional module-specific notes.
