# ui

## TL;DR

- The `ui` module is a comprehensive Feature Systems tier component that provides a full-featured, retained-mode Graphical User Interface (GUI) toolkit.

## General Info

- Module group: `Feature Systems`
- Source path: `src/ui/`
- Lua API path(s): `src/lua_api/ui_api.rs`
- Primary Lua namespace: `lurek.ui`
- Rust test path(s): tests/rust/unit/gui_tests.rs
- Lua test path(s): tests/lua/unit/test_gui.lua, tests/lua/unit/test_ui_input_unit.lua, tests/lua/unit/test_ui_layout.lua, tests/lua/integration/test_i18n_ui.lua

## Summary

Designed for both engine tooling and in-game interfaces, it centers around the `GuiContext`, which manages the stateful widget tree, focus navigation, input routing, and rendering lifecycle. The framework offers an extensive library of over 35 distinct widget types, ranging from core controls (Buttons, Labels, TextInputs, Checkboxes, Sliders, ComboBoxes, ProgressBars) to advanced layout containers (ScrollPanels, SplitPanels, DockPanels) and specialized extras (TreeViews, Toolbars, Menus, Accordions, ColorPickers). All widgets embed a shared `WidgetBase` that handles layout parameters, visibility, anchoring, and transitions.

At the structural level, the module employs a robust flex-based layout engine (`Layout`) that supports vertical, horizontal, and grid packing, alongside alignment, spacing, padding, and min/max constraints. Layouts can be constructed programmatically in Lua or loaded dynamically from declarative TOML files using the built-in layout loader, which dramatically accelerates UI iteration. The visual presentation is governed by a flexible `Theme` system that maps widget states (Normal, Hovered, Pressed, Focused, Disabled) to specific styles containing color palettes, font overrides, borders, and shadows. The module natively supports resolution-independent 9-slice borders (`NinePatch`) and per-widget transition animations (alpha fades, position slides) to deliver a polished, responsive user experience.

Beyond standard UI components and input routing, the module integrates powerful data binding tools. The `GUITable` seamlessly integrates with the `dataframe` module, enabling bulk loading of structured rows directly into UI views without expensive Lua-side iterations. Fully exposed through the `lurek.ui.*` API, this module equips developers with everything needed to build intricate developer dashboards, complex menus, and data-rich game interfaces.

## Files

### containers.rs

- Container widgets for the retained-mode GUI: Panel, Layout, ScrollPanel, NinePatch, GUIWindow, SplitPanel, DockPanel.
- Layout engine supports vertical, horizontal, and grid stacking with spacing, alignment, and justification.
- ScrollPanel provides viewport clipping with clamped 2D scroll offsets and configurable speed.
- NinePatch implements resolution-independent 9-slice border rendering from pixel insets.
- GUIWindow adds floating window semantics: title bar, close button, drag, and resize.
- SplitPanel and DockPanel offer two-pane splitting and edge-based docking respectively.

### context.rs

- Retained-mode GUI context owning a flat arena of widgets addressed by index.
- Discriminated `WidgetKind` union covering 35+ control/container/overlay types with shared `WidgetBase` access.
- Recursive layout pass computing absolute `computed_rect` from parent-relative positions.
- Focus management with forward/backward cycling and keyboard-driven tab navigation.
- Drag-and-drop API with cycle detection to prevent parent-into-child drops.
- Alpha and position transition animations stepped each frame with automatic expiry.
- Data binding system mapping string keys to numeric, text, or boolean widget values.
- FNV-hash render signature for fast dirty-check without full tree diffing.
- Mouse press/release/move and keyboard input dispatch to the focused widget.
- Toast overlay queue with per-message timers and automatic expiry.
- Event queue (`GuiEvent`) drained each frame by the Lua binding layer.

### controls.rs

- Concrete widget structs for buttons, labels, text inputs, checkboxes, sliders, progress bars, combo boxes, list boxes, tab bars, radio buttons, scroll bars, spin boxes, and switches.
- Each control embeds a `WidgetBase` for shared layout, style, and state; construction sets the correct `WidgetType` discriminant.
- Editing controls (TextInput, SpinBox, Slider) clamp or validate input at the boundary to guarantee invariants.
- Collection controls (ComboBox, ListBox, TabBar) auto-adjust selection indices on item removal.
- All controls derive `Debug` and `Clone` for inspection and snapshot-based undo.

### data_graph_renderer.rs

- Multi-series data graph renderer with viewport coordinate mapping.
- Supports line, scatter, and bar chart series. Provides world↔screen
- coordinate conversion and auto-range fitting for use in both runtime
- visualisation and editor panels.

### extras.rs

- Supplemental UI widgets beyond core controls: toasts, separators, spacers, tree views, toolbars, menus, dialogs, and status bars.
- Accordion panels with optional exclusive-expand mode and tooltip overlays with configurable delay.
- HSVA/RGB colour picker, column-row data grid with sorting, static image display, numeric badge overlay.
- TreeView uses a flat `Vec<TreeNode>` with index-based parent/child links; add, remove, expand, collapse, and depth queries are O(n) worst case.
- Toolbar and MenuBar hold child indices into an external widget list; buttons support enabled/toggled states.
- Dialog supports modal blocking, optional content slot, and footer action buttons.
- CustomWidget provides a blank shell for fully user-controlled rendering via Lua callbacks.
- All widgets embed `WidgetBase` for shared layout, style, and state; widget-type enum discriminant assigned at construction.

### layout_loader.rs

- Deserialise TOML layout files into a recursive `WidgetDef` tree and instantiate them into a live `GuiContext`.
- Map widget-type strings to concrete `GuiContext::add_*` constructors covering 30+ widget kinds.
- Apply optional base properties (position, size, id, visibility, enabled, tooltip) and type-specific values after creation.
- Provide a headless `render_to_image` path that saves the engine's default UI rasterisation to PNG.
- Support recursive child nesting via the `children` field in `WidgetDef`, mirroring the runtime parent–child hierarchy.
- Integrate with `GuiContext` only; no wgpu dependency — useful for offline layout validation and snapshot tests.

### mod.rs

- Immediate-mode GUI toolkit: containers, controls, extras, and theming.
- Provides layout panels, interactive widgets, and data-bound context.
- Optional TOML layout-loader feature behind a feature flag.

### render.rs

- GPU render-command emission for all retained-mode UI widget types (buttons, sliders, trees, tables, dialogs, etc.).
- CPU pixel-rasterisation fallback (`draw_to_image`) for headless screenshot and test verification.
- Theme-aware style resolution with per-widget alpha compositing applied to all colour channels.
- Shared helper emitters for common visual patterns: shadow, highlight strip, gradient/rounded box, border.
- Widget-specific draw routines: slider thumb, progress fill, checkbox mark, radio dot, combo arrow, scroll thumb, switch track.
- Recursive tree-node rendering in both GPU-command and CPU-pixel paths with expand/collapse indicators.
- HSV-to-RGB conversion used by the colour-picker hue bar rasteriser.
- `WidgetRenderer` carrier struct threading `GuiContext`, font key, and output buffer through the render pass.
- Child-collection logic merging standard `children()` with type-specific slots (menus, accordion sections, dock zones).
- Font-aware text measurement and alignment using the active UI font when available.

### theme.rs

- Visual theming system for the immediate-mode GUI, mapping widget-type/state pairs to style records.
- Each style carries background, foreground, border colors, font size, shadow, gradient, and text alignment.
- Lookup falls back from the requested state to `Normal`, letting partial themes work without exhaustive registration.
- Ships a full dark preset covering all standard widget types (buttons, inputs, panels, layouts, menus, dialogs, etc.).
- Style records are value types (`Clone + Debug`) so themes can be cheaply forked per-screen.
- Includes a debug helper that rasterizes button states into an `ImageData` tile for visual validation.
- Integrates with `GuiContext` at render time; the renderer reads resolved styles per-widget per-frame.
- Designed for extension: games register custom `(WidgetType, WidgetState)` entries without modifying built-in presets.

### widget.rs

- UI widget tree node: the fundamental layout and rendering unit of the UI system.
- `Widget` holds layout properties (size, margin, padding), style, and child list.
- Widgets are built from Lua tables or TOML layout files and owned by the UI tree.
- Layout is computed in a single top-down pass; results are cached until dirty.
- Render commands are emitted per-widget in tree order during the UI render phase.
- Interaction (click, hover, focus) is dispatched in a second bottom-up hit-test pass.

## Lua API Ref

- Binding: `src/lua_api/ui_api.rs`
- Namespace: `lurek.ui`

### Functions

- `lurek.ui.addToast`: Adds a toast notification to the queue.
- `lurek.ui.animateColor`: Animate widget color tint from one RGBA value to another.
- `lurek.ui.animateRotation`: Animate widget rotation from one angle to another (in radians).
- `lurek.ui.animateScale`: Animate widget scale from one value to another.
- `lurek.ui.beginDrag`: Begins a drag operation on a widget.
- `lurek.ui.clear`: Clears all retained UI widgets and transient UI state while keeping the active theme.
- `lurek.ui.clearFocus`: Clears keyboard focus from all widgets.
- `lurek.ui.clearFont`: Clears the global UI font override so the UI falls back to the active render font again.
- `lurek.ui.draw`: Invokes custom draw callbacks for all widgets that have one registered.
- `lurek.ui.drawToImage`: Renders the entire UI to an image buffer.
- `lurek.ui.dropOn`: Drops the currently dragged widget onto a target widget.
- `lurek.ui.endDrag`: Ends the current drag operation without dropping.
- `lurek.ui.flushCache`: Flushes internal UI layout and render caches.
- `lurek.ui.focusDirection`: Move focus in a spatial direction. Uses geometry to find nearest focusable widget.
- `lurek.ui.focusNeighbor`: Moves keyboard focus using an explicit directional focus link.
- `lurek.ui.focusNext`: Moves keyboard focus to the next focusable widget.
- `lurek.ui.focusPrev`: Moves keyboard focus to the previous focusable widget.
- `lurek.ui.getActiveDrag`: Returns the widget index currently being dragged, or nil.
- `lurek.ui.getFocus`: Returns the index of the currently focused widget, or nil.
- `lurek.ui.getFont`: Returns the global UI font assigned to the root widget, or nil when UI uses the render fallback font.
- `lurek.ui.getRoot`: Returns the root panel widget of the UI tree.
- `lurek.ui.getScaleFactor`: Get the current UI scale factor (current_height / base_height).
- `lurek.ui.getStyleToken`: Returns the value of a named semantic style token from the active theme.
- `lurek.ui.getTheme`: Returns whether a theme is currently set.
- `lurek.ui.getToastCount`: Returns the number of active toast notifications.
- `lurek.ui.getWidgetCount`: Returns the total number of widgets in the UI context.
- `lurek.ui.getWidgetFont`: Returns the font override assigned to a widget, or nil when the widget inherits its font from a parent.
- `lurek.ui.keypressed`: Delivers a key press event to the UI.
- `lurek.ui.loadLayout`: Loads a UI layout from a Lua table definition.
- `lurek.ui.loadLayoutFile`: Loads a UI layout from a TOML layout file.
- `lurek.ui.loadLayoutGameFile`: Loads a UI layout from a TOML file resolved through GameFS.
- `lurek.ui.mousemoved`: Delivers a mouse move event to the UI.
- `lurek.ui.mousepressed`: Delivers a mouse press event to the UI.
- `lurek.ui.mousereleased`: Delivers a mouse release event to the UI.
- `lurek.ui.newAccordion`: Creates a new accordion widget with collapsible sections.
- `lurek.ui.newAreaChart`: Creates a new area chart for data visualization.
- `lurek.ui.newBadge`: Creates a new badge widget for displaying counts.
- `lurek.ui.newBarChart`: Creates a new bar chart for data visualization.
- `lurek.ui.newButton`: Creates a new button widget with optional label text.
- `lurek.ui.newCheckbox`: Creates a new checkbox widget with optional label.
- `lurek.ui.newColorPicker`: Creates a new color picker widget for color selection.
- `lurek.ui.newComboBox`: Creates a new combo box (drop-down) widget.
- `lurek.ui.newCustomWidget`: Creates a new custom widget with optional initial configuration.
- `lurek.ui.newDialog`: Creates a new dialog widget with an optional title.
- `lurek.ui.newDockPanel`: Creates a new dock panel widget for docking child widgets to sides.
- `lurek.ui.newImageWidget`: Creates a new image display widget.
- `lurek.ui.newLabel`: Creates a new label widget for displaying text.
- `lurek.ui.newLayout`: Creates a new layout container widget.
- `lurek.ui.newLineChart`: Creates a new line chart for data visualization.
- `lurek.ui.newList`: Creates a new list box widget for item selection.
- `lurek.ui.newMenuBar`: Creates a new menu bar widget for top-level menus.
- `lurek.ui.newMenuItem`: Creates a new menu item widget with optional text.
- `lurek.ui.newNinePatch`: Creates a new nine-patch widget for scalable bordered images.
- `lurek.ui.newPanel`: Creates a new panel widget (container).
- `lurek.ui.newPieChart`: Creates a new pie chart for data visualization.
- `lurek.ui.newProgressBar`: Creates a new progress bar widget with min and max.
- `lurek.ui.newRadioButton`: Creates a new radio button widget in a named group.
- `lurek.ui.newScatterPlot`: Creates a new scatter plot for data visualization.
- `lurek.ui.newScrollBar`: Creates a new scroll bar widget for content scrolling.
- `lurek.ui.newScrollPanel`: Creates a new scrollable panel widget.
- `lurek.ui.newSeparator`: Creates a new separator widget for visual division.
- `lurek.ui.newSlider`: Creates a new slider widget with adjustable range.
- `lurek.ui.newSpacer`: Creates a new spacer widget for spacing between other widgets.
- `lurek.ui.newSpinBox`: Creates a new spin box (numeric stepper) widget.
- `lurek.ui.newSplitPanel`: Creates a new split panel widget with two resizable sub-panels.
- `lurek.ui.newStatusBar`: Creates a new status bar widget for app-level info.
- `lurek.ui.newSwitch`: Creates a new toggle switch widget.
- `lurek.ui.newTabBar`: Creates a new tab bar widget for tabbed navigation.
- `lurek.ui.newTable`: Creates a new table widget for tabular data display.
- `lurek.ui.newTextInput`: Creates a new text input widget for user entry.
- `lurek.ui.newTheme`: Creates a new UI theme for styling widgets.
- `lurek.ui.newToast`: Creates a new toast notification widget.
- `lurek.ui.newToolbar`: Creates a new toolbar widget for action buttons.
- `lurek.ui.newTooltipPanel`: Creates a new tooltip panel widget.
- `lurek.ui.newTreeView`: Creates a new tree view widget for hierarchical data.
- `lurek.ui.newWindow`: Creates a new GUI window widget with an optional title.
- `lurek.ui.parseWidgetState`: Validates and normalizes a widget state string.
- `lurek.ui.renderToImage`: Renders the entire UI to a PNG image file.
- `lurek.ui.setBaseResolution`: Set the logical base resolution the UI was designed for.
- `lurek.ui.setDefaultTheme`: Applies the built-in default theme to the UI context.
- `lurek.ui.setFocus`: Sets keyboard focus to a widget, or clears focus if nil.
- `lurek.ui.setFont`: Sets the global UI font by applying it to the root widget.
- `lurek.ui.setTheme`: Applies a theme to the entire UI context.
- `lurek.ui.setViewport`: Sets the viewport size for the UI context.
- `lurek.ui.textinput`: Delivers a text input event to the UI.
- `lurek.ui.update`: Updates the UI context and dispatches pending events to callbacks.
- `lurek.ui.updateBindings`: Updates data bindings for widgets that reference binding keys.
- `lurek.ui.updateResolution`: Update the current viewport resolution and recompute UI scale factor.
- `lurek.ui.update_bindings`: Updates data bindings for widgets that reference binding keys.
- `lurek.ui.visibleRange`: Calculate the visible item range for a scrollable list widget.
- `lurek.ui.wheelmoved`: Delivers a mouse wheel event to the UI.

### Enums

- No documented module-level enums/constants.

### Types


#### LAccordion Type


##### Fields

- No documented fields.

##### Methods

- `LAccordion:addSection`: Adds a collapsible section to this accordion.
- `LAccordion:getSectionCount`: Returns the number of sections in this accordion.
- `LAccordion:getSectionTitle`: Returns the title of an accordion section by its 1-based index.
- `LAccordion:isExclusive`: Returns whether this accordion is in exclusive mode (only one section open at a time).
- `LAccordion:isSectionExpanded`: Returns whether an accordion section is expanded.
- `LAccordion:setExclusive`: Sets exclusive mode. When true, expanding one section collapses all others.
- `LAccordion:toggleSection`: Toggles the expanded state of an accordion section by its 1-based index.


#### LAreaChart Type


##### Fields

- No documented fields.

##### Methods

- `LAreaChart:addLayer`: Adds a data layer to this area chart.
- `LAreaChart:addLayerFromDataFrame`: Adds one area layer from a dataframe column, using zero for missing or non-numeric cells.
- `LAreaChart:drawToImage`: Renders this area chart to an image buffer.
- `LAreaChart:setYMax`: Sets the maximum Y-axis value for this area chart.
- `LAreaChart:type`: Returns the type name of this object.
- `LAreaChart:typeOf`: Checks whether this object matches the given type name.


#### LBadge Type


##### Fields

- No documented fields.

##### Methods

- `LBadge:getCount`: Returns the current notification count of this badge.
- `LBadge:getDisplayText`: Returns the formatted display text of this badge (e.g. "99+" when count exceeds the maximum).
- `LBadge:setCount`: Sets the notification count displayed by this badge.


#### LBarChart Type


##### Fields

- No documented fields.

##### Methods

- `LBarChart:addCategoriesFromDataFrame`: Adds bar categories from dataframe rows, using zero for missing or non-numeric value cells.
- `LBarChart:addCategory`: Adds a category with values for each series.
- `LBarChart:addSeries`: Adds a named series to this bar chart.
- `LBarChart:drawToImage`: Renders this bar chart to an image buffer.
- `LBarChart:type`: Returns the type name of this object.
- `LBarChart:typeOf`: Checks whether this object matches the given type name.


#### LButton Type


##### Fields

- No documented fields.

##### Methods

- `LButton:getText`: Returns the current display text of this button.
- `LButton:setText`: Sets the display text on this button.


#### LCheckbox Type


##### Fields

- No documented fields.

##### Methods

- `LCheckbox:getText`: Returns the label text of this checkbox.
- `LCheckbox:isChecked`: Returns whether this checkbox is currently checked.
- `LCheckbox:setChecked`: Sets the checked state of this checkbox.
- `LCheckbox:setText`: Sets the label text displayed next to this checkbox.


#### LColorPicker Type


##### Fields

- No documented fields.

##### Methods

- `LColorPicker:getColor`: Returns the current color as RGBA components (0.0 to 1.0).
- `LColorPicker:getColorMode`: Returns the color mode of this picker (e.g. "rgb", "hsv").
- `LColorPicker:getShowAlpha`: Returns whether the alpha channel slider is visible.
- `LColorPicker:setColor`: Sets the current color as RGBA components.
- `LColorPicker:setColorMode`: Sets the color mode of this picker (e.g. "rgb", "hsv").
- `LColorPicker:setOnChange`: Registers a callback invoked when this color picker's value changes.
- `LColorPicker:setShowAlpha`: Sets whether the alpha channel slider is visible.


#### LComboBox Type


##### Fields

- No documented fields.

##### Methods

- `LComboBox:addItem`: Appends a new text item to this combo box's dropdown list.
- `LComboBox:clearItems`: Removes all items from this combo box.
- `LComboBox:getItem`: Returns the text of the item at the given 1-based index.
- `LComboBox:getItemCount`: Returns the number of items in this combo box.
- `LComboBox:getSelectedIndex`: Returns the 1-based index of the currently selected item, or 0 if none is selected.
- `LComboBox:getSelectedItem`: Returns the text of the currently selected item, or nil if none is selected.
- `LComboBox:removeItem`: Removes the item at the given 1-based index from this combo box.
- `LComboBox:setSelectedIndex`: Sets the selected item by 1-based index.


#### LDialog Type


##### Fields

- No documented fields.

##### Methods

- `LDialog:addButton`: Adds a footer button to this dialog and returns its 1-based index.
- `LDialog:close`: Closes this dialog and fires the onClose callback if it was open.
- `LDialog:getContent`: Returns the widget index of this dialog's content, or nil if not set.
- `LDialog:getTitle`: Returns the title text of this dialog.
- `LDialog:isModal`: Returns whether this dialog is modal (blocks interaction with other widgets).
- `LDialog:isOpen`: Returns whether this dialog is currently open and visible.
- `LDialog:open`: Opens this dialog, making it visible.
- `LDialog:setContent`: Sets the content widget for this dialog.
- `LDialog:setModal`: Sets whether this dialog widget is modal.
- `LDialog:setOnClose`: Registers a callback invoked when this dialog is closed.
- `LDialog:setTitle`: Sets the title text of this dialog widget.


#### LDockPanel Type


##### Fields

- No documented fields.

##### Methods

- `LDockPanel:dock`: Docks a child widget to the specified side of this dock panel.
- `LDockPanel:getDockedCount`: Returns the number of widgets docked in this dock panel.
- `LDockPanel:getSplitSize`: Returns the size configured for a dock panel side region.
- `LDockPanel:setSplitSize`: Sets the size of a dock panel side region.
- `LDockPanel:undock`: Removes a child widget from this dock panel.


#### LGuiTable Type


##### Fields

- No documented fields.

##### Methods

- `LGuiTable:addColumn`: Adds a new column to this table widget.
- `LGuiTable:addRow`: Adds a row of data to this table widget.
- `LGuiTable:clearRows`: Clears all rows and the selected row in this table widget.
- `LGuiTable:getCell`: Returns the text of a cell at the given 1-based row and column.
- `LGuiTable:getColumnCount`: Returns the number of columns in this table widget.
- `LGuiTable:getRowCount`: Returns the number of rows in this table widget.
- `LGuiTable:getSelectedRow`: Returns the 1-based index of the currently selected row, or nil.
- `LGuiTable:isSortable`: Returns whether columns in this table can be sorted by clicking headers.
- `LGuiTable:setCell`: Sets the text of a cell at the given 1-based row and column.
- `LGuiTable:setDataFrame`: Replaces columns and rows from a dataframe, stringifying cell values for display.
- `LGuiTable:setOnSelect`: Registers a callback invoked when a table row is selected.
- `LGuiTable:setRows`: Replaces all rows with an array of row arrays.
- `LGuiTable:setSelectedRow`: Sets the selected row by its 1-based index, or nil to deselect.
- `LGuiTable:setSortable`: Sets whether columns in this table can be sorted by clicking headers.


#### LGuiWindow Type


##### Fields

- No documented fields.

##### Methods

- `LGuiWindow:getTitle`: Returns the title bar text of this GUI window.
- `LGuiWindow:isCloseable`: Returns whether this window shows a close button.
- `LGuiWindow:isDraggable`: Returns whether this window can be dragged by its title bar.
- `LGuiWindow:isResizable`: Returns whether this window can be resized by dragging its edges.
- `LGuiWindow:setCloseable`: Sets whether this window shows a close button.
- `LGuiWindow:setDraggable`: Sets whether this window can be dragged by its title bar.
- `LGuiWindow:setOnClose`: Registers a callback invoked when this window is closed.
- `LGuiWindow:setResizable`: Sets whether this window can be resized.
- `LGuiWindow:setTitle`: Sets the title bar text of this GUI window.


#### LImageWidget Type


##### Fields

- No documented fields.

##### Methods

- `LImageWidget:getScaleMode`: Returns the image scaling mode (e.g. "fit", "fill", "stretch").
- `LImageWidget:getTint`: Returns the tint color of this image widget as RGBA components.
- `LImageWidget:setScaleMode`: Sets the image scaling mode (e.g. "fit", "fill", "stretch").
- `LImageWidget:setTint`: Sets the tint color of this image widget as RGBA components.


#### LLabel Type


##### Fields

- No documented fields.

##### Methods

- `LLabel:getText`: Returns the current display text of this label.
- `LLabel:setText`: Sets the display text on this label.


#### LLayout Type


##### Fields

- No documented fields.

##### Methods

- `LLayout:getAlign`: Returns the current cross-axis alignment mode.
- `LLayout:getDirection`: Returns the current layout direction.
- `LLayout:getJustify`: Returns the current main-axis justification mode.
- `LLayout:getSpacing`: Returns the current spacing between children.
- `LLayout:getWrap`: Returns whether wrapping is enabled for this layout.
- `LLayout:setAlign`: Sets the cross-axis alignment for children (e.g. "start", "center", "end", "stretch").
- `LLayout:setColumns`: Sets the number of columns for grid layout mode (minimum 1).
- `LLayout:setDirection`: Sets the layout direction for child arrangement ("horizontal", "vertical", or "grid").
- `LLayout:setJustify`: Sets the main-axis justification for children (e.g. "start", "center", "end", "space-between").
- `LLayout:setSpacing`: Sets the spacing in pixels between child widgets in this layout.
- `LLayout:setWrap`: Enables or disables wrapping of children to the next row/column when they overflow.


#### LLineChart Type


##### Fields

- No documented fields.

##### Methods

- `LLineChart:addSeries`: Adds a named series of points to this line chart.
- `LLineChart:addSeriesFromDataFrame`: Adds a named series from dataframe columns, skipping rows with non-numeric x or y cells.
- `LLineChart:drawToImage`: Renders this line chart to an image buffer.
- `LLineChart:setXMax`: Sets the maximum X-axis value for this line chart.
- `LLineChart:setYMax`: Sets the maximum Y-axis value for this line chart.
- `LLineChart:type`: Returns the type name of this object.
- `LLineChart:typeOf`: Checks whether this object matches the given type name.


#### LListBox Type


##### Fields

- No documented fields.

##### Methods

- `LListBox:addItem`: Appends a new text item to this list box.
- `LListBox:clearItems`: Removes all items from this list box.
- `LListBox:getItem`: Returns the text of the item at the given 1-based index.
- `LListBox:getItemCount`: Returns the number of items in this list box.
- `LListBox:getSelectedIndex`: Returns the 1-based index of the currently selected item, or 0 if none.
- `LListBox:removeItem`: Removes the item at the given 1-based index from this list box.
- `LListBox:setItemHeight`: Sets the pixel height of each item row in this list box.
- `LListBox:setSelectedIndex`: Sets the selected item by 1-based index.


#### LMenuBar Type


##### Fields

- No documented fields.

##### Methods

- `LMenuBar:addMenu`: Adds a menu (by its widget index) to this menu bar.
- `LMenuBar:getMenuCount`: Returns the number of menus in this menu bar.
- `LMenuBar:getMenus`: Returns a table of widget indices for all menus in this menu bar.
- `LMenuBar:removeMenu`: Removes a menu from this menu bar by its widget index.


#### LMenuItem Type


##### Fields

- No documented fields.

##### Methods

- `LMenuItem:addSubItem`: Adds a sub-item to this menu item for building nested menus.
- `LMenuItem:getShortcut`: Returns the keyboard shortcut string associated with this menu item.
- `LMenuItem:getSubItems`: Returns a table of widget indices for all sub-items of this menu item.
- `LMenuItem:getText`: Returns the display text of this menu item.
- `LMenuItem:isChecked`: Returns whether this menu item is checked (for checkable menu items).
- `LMenuItem:setChecked`: Sets the checked state of this menu item.
- `LMenuItem:setOnClick`: Registers a callback invoked when this menu item is clicked.
- `LMenuItem:setShortcut`: Sets the keyboard shortcut text displayed next to this menu item.
- `LMenuItem:setText`: Sets the display text of this menu item.


#### LNinePatch Type


##### Fields

- No documented fields.

##### Methods

- `LNinePatch:getImageDimensions`: Returns the original image dimensions of this nine-patch.
- `LNinePatch:getInsets`: Returns the border insets of this nine-patch.
- `LNinePatch:getSlices`: Returns the computed nine-patch slices as a table of source/dest rectangles for rendering.
- `LNinePatch:setImageDimensions`: Sets the original image dimensions used for nine-patch slice calculations.
- `LNinePatch:setInsets`: Sets the border insets defining the stretchable center region of the nine-patch image.


#### LPanel Type


##### Fields

- No documented fields.

##### Methods

- `LPanel:getTitle`: Returns the title text of this panel.
- `LPanel:setScrollable`: Enables or disables scrolling within this panel.
- `LPanel:setTitle`: Sets the title text displayed on this panel's header.


#### LPieChart Type


##### Fields

- No documented fields.

##### Methods

- `LPieChart:addSegment`: Adds a labeled segment to this pie chart widget.
- `LPieChart:addSegmentsFromDataFrame`: Adds pie segments from dataframe rows with a built-in color palette, skipping non-positive or non-numeric values.
- `LPieChart:drawToImage`: Renders this pie chart to an image buffer.
- `LPieChart:type`: Returns the type name of this object.
- `LPieChart:typeOf`: Checks whether this object matches the given type name.


#### LProgressBar Type


##### Fields

- No documented fields.

##### Methods

- `LProgressBar:getMax`: Returns the maximum value of this progress bar's range.
- `LProgressBar:getMin`: Returns the minimum value of this progress bar's range.
- `LProgressBar:getProgress`: Returns the normalized progress as a fraction (0.0 to 1.0) of the current range.
- `LProgressBar:getValue`: Returns the current value of this progress bar.
- `LProgressBar:setRange`: Sets the minimum and maximum bounds for this progress bar.
- `LProgressBar:setValue`: Sets the current fill value of this progress bar, clamped to its range.


#### LRadioButton Type


##### Fields

- No documented fields.

##### Methods

- `LRadioButton:getGroup`: Returns the radio button group name. Buttons in the same group are mutually exclusive.
- `LRadioButton:getText`: Returns the label text of this radio button.
- `LRadioButton:isSelected`: Returns whether this radio button is currently selected.
- `LRadioButton:setGroup`: Sets the radio button group name. Buttons in the same group are mutually exclusive.
- `LRadioButton:setOnChange`: Registers a callback invoked when this radio button's selection changes.
- `LRadioButton:setSelected`: Sets the selected state of this radio button.
- `LRadioButton:setText`: Sets the label text of this radio button.


#### LScatterPlot Type


##### Fields

- No documented fields.

##### Methods

- `LScatterPlot:addSeries`: Adds a data series to this scatter plot.
- `LScatterPlot:addSeriesFromDataFrame`: Adds a data series from dataframe columns, skipping rows with non-numeric x or y cells.
- `LScatterPlot:drawToImage`: Renders this scatter plot to an image buffer.
- `LScatterPlot:setXRange`: Sets the X-axis range for this scatter plot.
- `LScatterPlot:setYRange`: Sets the Y-axis range for this scatter plot.
- `LScatterPlot:type`: Returns the type name of this object.
- `LScatterPlot:typeOf`: Checks whether this object matches the given type name.


#### LScrollBar Type


##### Fields

- No documented fields.

##### Methods

- `LScrollBar:getContentSize`: Returns the total content size tracked by this scroll bar.
- `LScrollBar:getScrollPosition`: Returns the current scroll position of this scroll bar.
- `LScrollBar:getViewSize`: Returns the visible viewport size tracked by this scroll bar.
- `LScrollBar:isVertical`: Returns whether this scroll bar is oriented vertically.
- `LScrollBar:setContentSize`: Sets the total content size that this scroll bar represents.
- `LScrollBar:setOnChange`: Registers a callback invoked when this scroll bar's position changes.
- `LScrollBar:setScrollPosition`: Sets the scroll position of this scroll bar, clamped to the valid range.
- `LScrollBar:setViewSize`: Sets the visible viewport size for this scroll bar.


#### LScrollPanel Type


##### Fields

- No documented fields.

##### Methods

- `LScrollPanel:getContentSize`: Returns the virtual content dimensions of this scroll panel.
- `LScrollPanel:getMaxScroll`: Returns the maximum scroll offset allowed in each axis.
- `LScrollPanel:getScrollPosition`: Returns the current scroll offset of this scroll panel.
- `LScrollPanel:getScrollSpeed`: Returns the current scroll speed multiplier.
- `LScrollPanel:setContentSize`: Sets the virtual content dimensions of this scroll panel.
- `LScrollPanel:setScrollPosition`: Sets the scroll offset position of this scroll panel.
- `LScrollPanel:setScrollSpeed`: Sets the scroll speed multiplier for mouse wheel scrolling.


#### LSeparator Type


##### Fields

- No documented fields.

##### Methods

- `LSeparator:getThickness`: Returns the line thickness of this separator.
- `LSeparator:isVertical`: Returns whether this separator is oriented vertically.
- `LSeparator:setThickness`: Sets the line thickness of this separator in pixels.
- `LSeparator:setVertical`: Sets whether this separator draws vertically or horizontally.


#### LSlider Type


##### Fields

- No documented fields.

##### Methods

- `LSlider:getMax`: Returns the maximum value of this slider's range.
- `LSlider:getMin`: Returns the minimum value of this slider's range.
- `LSlider:getValue`: Returns the current value of this slider.
- `LSlider:setRange`: Sets the minimum and maximum bounds for this slider.
- `LSlider:setStep`: Sets the step increment for this slider's value snapping.
- `LSlider:setValue`: Sets the current value of this slider, clamped to its range.


#### LSpinBox Type


##### Fields

- No documented fields.

##### Methods

- `LSpinBox:decrement`: Decreases this spin box's value by one step.
- `LSpinBox:getValue`: Returns the current numeric value of this spin box.
- `LSpinBox:increment`: Increases this spin box's value by one step.
- `LSpinBox:setRange`: Sets the minimum and maximum bounds for this spin box.
- `LSpinBox:setStep`: Sets the step increment for this spin box.
- `LSpinBox:setValue`: Sets the numeric value of this spin box, clamped to its range.


#### LSplitPanel Type


##### Fields

- No documented fields.

##### Methods

- `LSplitPanel:getFirstChild`: Returns the widget index of the first (left/top) child panel.
- `LSplitPanel:getMinPanelSize`: Returns the minimum pixel size of each split sub-panel.
- `LSplitPanel:getOrientation`: Returns the orientation of this split panel ("horizontal" or "vertical").
- `LSplitPanel:getSecondChild`: Returns the widget index of the second (right/bottom) child panel.
- `LSplitPanel:getSplitPosition`: Returns the split position as a fraction (0.0 to 1.0) of the panel's total size.
- `LSplitPanel:setFirstChild`: Sets the widget index for the first (left/top) panel.
- `LSplitPanel:setMinPanelSize`: Sets the minimum pixel size of each split sub-panel.
- `LSplitPanel:setOrientation`: Sets the orientation of this split panel ("horizontal" or "vertical").
- `LSplitPanel:setSecondChild`: Sets the widget index for the second (right/bottom) panel.
- `LSplitPanel:setSplitPosition`: Sets the split position as a fraction (0.0 to 1.0).


#### LStatusBar Type


##### Fields

- No documented fields.

##### Methods

- `LStatusBar:addSection`: Adds a labeled section to this status bar.
- `LStatusBar:getSectionCount`: Returns the number of sections in this status bar.
- `LStatusBar:getSectionText`: Returns the text of a status bar section by its 1-based index.
- `LStatusBar:setSectionCount`: Sets the number of sections, truncating or adding empty sections as needed.
- `LStatusBar:setSectionText`: Sets the text of a status bar section by its 1-based index.
- `LStatusBar:setSectionWidget`: Associates a widget with a status bar section (reserved for future use).


#### LSwitch Type


##### Fields

- No documented fields.

##### Methods

- `LSwitch:isOn`: Returns whether this switch is currently in the on state.
- `LSwitch:setOn`: Sets the on/off state of this toggle switch.
- `LSwitch:toggle`: Toggles this switch between on and off states.


#### LTabBar Type


##### Fields

- No documented fields.

##### Methods

- `LTabBar:addTab`: Adds a new tab with the given label to this tab bar.
- `LTabBar:getActiveTab`: Returns the 1-based index of the currently active tab.
- `LTabBar:getTab`: Returns the label of the tab at the given 1-based index.
- `LTabBar:getTabCount`: Returns the total number of tabs in this tab bar.
- `LTabBar:removeTab`: Removes the tab at the given 1-based index.
- `LTabBar:setActiveTab`: Sets the active (selected) tab by 1-based index.


#### LTextInput Type


##### Fields

- No documented fields.

##### Methods

- `LTextInput:getCursorPosition`: Returns the current cursor position (character index) within the text input.
- `LTextInput:getPlaceholder`: Returns the placeholder text of this text input.
- `LTextInput:getText`: Returns the current text content of this text input field.
- `LTextInput:isFocused`: Returns whether this text input currently has keyboard focus.
- `LTextInput:setMaxLength`: Sets the maximum number of characters allowed in this text input.
- `LTextInput:setPlaceholder`: Sets the placeholder text shown when the input is empty.
- `LTextInput:setText`: Sets the text content of this text input field and moves the cursor to the end.


#### LTheme Type


##### Fields

- No documented fields.

##### Methods

- `LTheme:setStyle`: Sets a style entry for the given widget type and state, optionally restricted to a style class.
- `LTheme:type`: Returns the type name of this object.
- `LTheme:typeOf`: Checks whether this object matches the given type name.


#### LToast Type


##### Fields

- No documented fields.

##### Methods

- `LToast:getDuration`: Returns the display duration of this toast in seconds.
- `LToast:getMessage`: Returns the message text of this toast.
- `LToast:getProgress`: Returns the elapsed fraction (0.0 to 1.0) of this toast's lifetime.
- `LToast:isExpired`: Returns whether this toast has exceeded its display duration.
- `LToast:setDuration`: Sets how long this toast is displayed in seconds.
- `LToast:setMessage`: Sets the message text displayed by this toast notification.


#### LToolbar Type


##### Fields

- No documented fields.

##### Methods

- `LToolbar:addButton`: Adds a new button to this toolbar and returns its 1-based index.
- `LToolbar:addSeparator`: Adds a visual separator to this toolbar.
- `LToolbar:addSpacer`: Adds a flexible spacer to this toolbar.
- `LToolbar:getButton`: Returns a table describing the toolbar button with the given ID.
- `LToolbar:getOrientation`: Returns the toolbar orientation ("horizontal" or "vertical").
- `LToolbar:isButtonToggled`: Returns whether a toolbar button is toggled on.
- `LToolbar:setButtonEnabled`: Enables or disables a toolbar button by its ID.
- `LToolbar:setButtonToggled`: Sets the toggle state of a toolbar button by its ID.
- `LToolbar:setOrientation`: Sets the toolbar orientation ("horizontal" or "vertical").


#### LTooltipPanel Type


##### Fields

- No documented fields.

##### Methods

- `LTooltipPanel:getDelay`: Returns the delay in seconds before this tooltip appears.
- `LTooltipPanel:getTarget`: Returns the widget index that this tooltip is attached to.
- `LTooltipPanel:getText`: Returns the current tooltip display text.
- `LTooltipPanel:setDelay`: Sets the delay in seconds before this tooltip appears.
- `LTooltipPanel:setTarget`: Sets the widget index that this tooltip is attached to.
- `LTooltipPanel:setText`: Sets the tooltip panel display text content.


#### LTreeView Type


##### Fields

- No documented fields.

##### Methods

- `LTreeView:addNode`: Adds a new node to this tree view, optionally under a parent node.
- `LTreeView:clearNodes`: Removes all nodes from this tree view.
- `LTreeView:collapseAll`: Collapses all nodes in this tree view.
- `LTreeView:collapseNode`: Collapses the node at the given 1-based index to hide its children.
- `LTreeView:expandAll`: Expands all nodes in this tree view.
- `LTreeView:expandNode`: Expands the node at the given 1-based index to show its children.
- `LTreeView:getChildNodes`: Returns a table of 1-based child node indices for the node at the given index.
- `LTreeView:getNodeCount`: Returns the total number of nodes in this tree view.
- `LTreeView:getNodeDepth`: Returns the nesting depth of the node at the given index (0 for root nodes).
- `LTreeView:getNodeText`: Returns the text of the node at the given 1-based index.
- `LTreeView:getParentNode`: Returns the 1-based index of the parent of the node at the given index.
- `LTreeView:getSelectedNode`: Returns the 1-based index of the currently selected node.
- `LTreeView:isExpanded`: Returns whether the node at the given 1-based index is currently expanded.
- `LTreeView:isNodeExpanded`: Returns whether the node at the given 1-based index is expanded. Returns nil if the index is invalid.
- `LTreeView:removeNode`: Removes the node at the given 1-based index from this tree view.
- `LTreeView:setNodeIcon`: Sets the icon of the node at the given 1-based index.
- `LTreeView:setNodeText`: Sets the text of the node at the given 1-based index.
- `LTreeView:setSelectedNode`: Sets the selected node by 1-based index.
- `LTreeView:toggleNode`: Toggles the expanded/collapsed state of the node at the given 1-based index.


#### LUiWidget Type


##### Fields

- No documented fields.

##### Methods

- `LUiWidget:addChild`: Adds a child widget to this widget's hierarchy.
- `LUiWidget:animateAlpha`: Smoothly animates this widget's opacity toward a target value over the given duration.
- `LUiWidget:animatePosition`: Smoothly animates this widget's position toward the target coordinates.
- `LUiWidget:attachToEntity`: Attaches this widget to a game entity so it follows the entity's position on screen.
- `LUiWidget:bind`: Binds this widget to a data key for use with update_bindings.
- `LUiWidget:cancelAnimations`: Cancels all active animations on this widget, leaving it at its current state.
- `LUiWidget:clearAnchor`: Removes all anchor constraints from this widget.
- `LUiWidget:clearFont`: Clears any font override on this widget so it inherits from its parent again.
- `LUiWidget:containsPoint`: Tests whether the given screen-space point is inside this widget's bounds.
- `LUiWidget:detachFromEntity`: Detaches this widget from any previously attached entity.
- `LUiWidget:fadeIn`: Instantly makes this widget fully opaque and visible.
- `LUiWidget:fadeOut`: Instantly makes this widget fully transparent and hidden.
- `LUiWidget:findById`: Searches this widget's subtree for a child with the given ID.
- `LUiWidget:getAlpha`: Returns the current opacity of this widget.
- `LUiWidget:getChildCount`: Returns the number of direct child widgets attached to this widget.
- `LUiWidget:getChildren`: Returns a table of lightweight child widget references, each containing an _idx field.
- `LUiWidget:getFlexGrow`: Returns the flex-grow factor of this widget.
- `LUiWidget:getFlexShrink`: Returns the flex-shrink factor of this widget.
- `LUiWidget:getId`: Returns the string identifier assigned to this widget.
- `LUiWidget:getMargin`: Returns the outer margin of this widget.
- `LUiWidget:getMaxSize`: Returns the maximum width and height of this widget.
- `LUiWidget:getMinSize`: Returns the minimum width and height of this widget.
- `LUiWidget:getMouseFilter`: Returns the mouse filter of this widget.
- `LUiWidget:getPadding`: Returns the inner padding of this widget.
- `LUiWidget:getPosition`: Returns the local position of this widget relative to its parent.
- `LUiWidget:getRect`: Returns the computed bounding rectangle of this widget in screen coordinates after layout.
- `LUiWidget:getSize`: Returns the width and height of this widget.
- `LUiWidget:getState`: Returns the current interaction state of this widget (e.g. "normal", "hovered", "pressed", "disabled").
- `LUiWidget:getStyleClass`: Returns the style class of this widget.
- `LUiWidget:getTooltip`: Returns the tooltip text of this widget.
- `LUiWidget:getZOrder`: Returns the z-order (draw priority) of this widget.
- `LUiWidget:isAnimating`: Returns whether this widget currently has an active animation.
- `LUiWidget:isEnabled`: Returns whether this widget is currently enabled and can receive input.
- `LUiWidget:isVisible`: Returns whether this widget is currently visible.
- `LUiWidget:removeChild`: Removes a child widget from this widget's hierarchy.
- `LUiWidget:setAlpha`: Sets the opacity of this widget, clamped to 0.0 (fully transparent) through 1.0 (fully opaque).
- `LUiWidget:setAnchor`: Anchors this widget to its parent's edges. Pass nil for any side to leave it unanchored.
- `LUiWidget:setAnchorCenter`: Centers this widget within its parent using proportional anchor offsets (0.0 to 1.0).
- `LUiWidget:setAriaName`: Sets the accessible name metadata for this widget.
- `LUiWidget:setBindKey`: Binds this widget to a data key and reports whether the widget exists.
- `LUiWidget:setEnabled`: Enables or disables this widget. Disabled widgets appear grayed out and ignore input.
- `LUiWidget:setFlexGrow`: Sets the flex-grow factor controlling how much extra space this widget receives in a layout.
- `LUiWidget:setFlexShrink`: Sets the flex-shrink factor controlling how much this widget shrinks when layout space is insufficient.
- `LUiWidget:setFocusGroup`: Sets the focus traversal group for this widget.
- `LUiWidget:setFocusNeighbor`: Sets an explicit directional focus neighbor for this widget.
- `LUiWidget:setFocusable`: Sets whether this widget participates in keyboard focus traversal.
- `LUiWidget:setFont`: Assigns a specific font to this widget and its descendants unless overridden further down the tree.
- `LUiWidget:setId`: Assigns a string identifier to this widget for lookup with findById.
- `LUiWidget:setMargin`: Sets the outer margin of this widget. Accepts 1 to 4 values (top, right?, bottom?, left?) following CSS shorthand rules.
- `LUiWidget:setMaxSize`: Sets the maximum allowed width and height for this widget during layout.
- `LUiWidget:setMinSize`: Sets the minimum allowed width and height for this widget during layout.
- `LUiWidget:setMouseFilter`: Sets the mouse filter for this widget ("stop", "pass", "ignore").
- `LUiWidget:setOnChange`: Registers a callback function invoked when this widget's value changes.
- `LUiWidget:setOnClick`: Registers a callback function invoked when this widget is clicked.
- `LUiWidget:setOnDraw`: Registers a custom draw callback for this widget, invoked each frame during the draw pass.
- `LUiWidget:setPadding`: Sets the inner padding of this widget. Accepts 1 to 4 values (top, right?, bottom?, left?) following CSS shorthand rules.
- `LUiWidget:setPosition`: Sets the local position of this widget relative to its parent.
- `LUiWidget:setRole`: Sets a semantic role string for this widget.
- `LUiWidget:setSize`: Sets the width and height of this widget in pixels.
- `LUiWidget:setStyleClass`: Sets the style class of this widget.
- `LUiWidget:setTabIndex`: Sets the tab-order index for this widget.
- `LUiWidget:setTextEllipsis`: Enables or disables ellipsis clipping for overflowing single-line text.
- `LUiWidget:setTextVAlign`: Sets the vertical alignment of text inside this widget.
- `LUiWidget:setTextWrap`: Enables or disables word-wrap for text inside this widget.
- `LUiWidget:setTooltip`: Sets the tooltip text shown when the user hovers over this widget.
- `LUiWidget:setVisible`: Shows or hides this widget. Hidden widgets are not drawn and do not receive input.
- `LUiWidget:setZOrder`: Sets the z-order (draw priority) of this widget. Higher values draw on top.
- `LUiWidget:slideIn`: Moves this widget to the given position and makes it visible.
- `LUiWidget:slideOut`: Moves this widget to the given position and hides it.
- `LUiWidget:type`: Returns the type name string of this widget (e.g. "LButton", "LSlider").
- `LUiWidget:typeOf`: Checks whether this widget matches the given type name, including base types "LWidget" and "Object".
- `LUiWidget:unbind`: Removes the data binding from this widget.

## References

- `charts`: Imports or references `src/charts/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `color`: Imports or references `src/color/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `dataframe`: Imports or references `src/dataframe/`. Cross-group dependency from `Feature Systems` into `Foundations`.
- `image`: Imports or references `image` from `src/image/`.
- `math`: Imports or references `math` from `src/math/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
