# html

## TL;DR

- Runs interactive HTML/CSS documents with input routing, selector queries, and element mutations.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/html/`
- Binding: `src/lua_api/html_api.rs`
- Namespace: `lurek.html`
- Lua API surface: `6` functions, `2` types, `54` methods
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

This module provides the HTML/CSS user interface subsystem, letting developers build interactive menus and HUDs. It parses markup and CSS stylesheets into dynamic DOM trees. The layout engine computes bounds using a box model, resolving cascades into precise pixel coordinates for rendering.

The document orchestrator manages the UI lifecycle, handling layout passes, styling cascades, and viewport resizes. It converts CSS declarations into normalized color vectors and size scales. Styles are resolved deterministically across elements, allowing developers to manage visuals through stylesheets.

For user interactions, the module handles clicks, keyboard focus, and text inputs. Input events are dispatched down the element tree, triggering hover states or text changes. DOM elements can be mutated at runtime by toggling classes, editing attributes, or replacing inner HTML fragments.

Additionally, selector queries support class, ID, and ancestry matching to locate elements. The completed layout output compiles into draw command streams containing render rectangles and text blocks ready for GPU rendering.

## Imports

- `color`: Imports or references `src/color/`. Cross-group dependency from ``Edge/Integration`` into `Edge/Integration`.

## Files

### color.rs

- Turns raw CSS color text into normalized RGBA values ready for render-side blending.
- Accepts hex codes, rgb/rgba, hsl/hsla forms, and named web colors used by authored styles.
- Normalizes hue units and percentage channels so mixed input formats resolve to one stable shape.
- Applies alpha parsing with clamping semantics that keep transparent and opaque intent predictable.
- Returns compact `[f32; 4]` color vectors in 0..1 space for direct engine consumption.

### document.rs

- Orchestrates the full HTML document lifecycle from source text to interactive, drawable UI state.
- Builds and rebuilds element trees while preserving viewport constraints and accumulated stylesheet inputs.
- Resolves selector-driven style cascades into computed per-element visual properties for later layout.
- Runs block-style layout passes with dirty tracking so structural and style edits trigger fresh geometry.
- Supports focused and hovered interaction state used by pointer routing, keyboard input, and text editing.
- Exposes traversal and lookup paths for id, selector, ancestry, and document-order element queries.
- Applies DOM mutations like attribute edits, class toggles, text replacement, and inner fragment insertion.
- Serializes inner and outer HTML snapshots so runtime edits can be observed or persisted deterministically.
- Generates draw command streams carrying rectangles, text, and color intent for render-side execution.
- Collects parse and style warnings so caller code can surface authoring issues without aborting runtime flow.

### element.rs

- Defines the core DOM node shape used to store structure, attributes, text, and layout geometry.
- Keeps normalized attribute and inline-style maps in sync so style edits remain coherent with HTML state.
- Provides class token mutation paths that preserve deterministic ordering and membership checks.
- Tracks parent-child linkage and removal flags to support stable traversal without index churn.
- Carries axis-aligned rectangles for hit testing, layout output, and pointer targeting in UI flow.
- Supplies normalization and void-element classification rules that guide parsing and tree mutations.

### mod.rs

- High-level HTML module surface that composes parsing, styling, selection, and document orchestration.
- Re-exports stable document and element types used by runtime code interacting with HTML-driven UI.
- Binds color, parser, selector, and style helpers into one cohesive entry point for the subsystem.

### parser.rs

- Converts raw HTML text into document nodes with stable parent-child links and normalized attributes.
- Handles open, close, self-closing, void, and comment forms so authored markup maps to valid tree state.
- Parses attribute key-value pairs with quote-aware scanning and consistent lowercase key normalization.
- Encodes and decodes common HTML entities to preserve readable text while keeping stored values canonical.
- Collapses insignificant whitespace in text nodes to keep rendered output predictable across content styles.

### selector.rs

- Implements selector matching logic that maps CSS-like queries onto the live HTML element tree.
- Parses selector text into tag, id, class, and combinator fragments with deterministic chain ordering.
- Supports descendant and direct-child relationships for ancestry-aware filtering semantics.
- Walks parent links to evaluate multi-part selector chains against runtime element topology.
- Provides the core predicate shared by style cascade resolution and document query operations.

### style.rs

- Parses stylesheet sources into ordered selector rules and normalized declaration maps for HTML layout.
- Validates supported properties while collecting non-fatal warnings for unknown or malformed inputs.
- Normalizes declaration keys and values so later cascade merges operate on stable property naming.
- Resolves pixel, percent, and unitless length text into float values against caller-provided bases.
- Supplies compact parse outputs consumed by document rebuild, style recompute, and layout phases.

## Lua API Ref

### Functions

- `lurek.html.isDefaultPrevented() -> boolean`: Returns whether the default action was prevented.
- `lurek.html.loadDocument(path, opts?) -> LHtmlDocument`: Loads an HTML document from GameFS and optionally loads CSS from options or companion file.
- `lurek.html.newDocument(source?, opts?) -> LHtmlDocument`: Creates an HTML document from optional source and layout/style options.
- `lurek.html.preventDefault() -> nil`: Marks the event as having its default action prevented.
- `lurek.html.stopPropagation() -> nil`: Stops event propagation to remaining listeners.
- `lurek.html.supports(feature) -> boolean`: Returns whether the HTML engine supports a named feature.

### Callbacks

- `LHtmlDocument:on` param `func` (`function`): Lua callback receiving an event table.
- `LHtmlElement:on` param `func` (`function`): Lua callback receiving an event table.

### Enums

- No documented module-level enums/constants.

### Types

#### LHtmlDocument Type

- Lua-side HTML document handle with DOM state, callbacks, and render command access.

##### Fields

- No documented fields.

##### Methods

- `LHtmlDocument:addCss(css) -> nil`: Appends CSS source text to the document stylesheet.
- `LHtmlDocument:clearCss() -> nil`: Clears all CSS source text from the document.
- `LHtmlDocument:draw(x?, y?) -> nil`: Queues render commands for this document at an optional offset.
- `LHtmlDocument:getElementById(id) -> LuaValue`: Looks up the first element with a matching id attribute.
- `LHtmlDocument:getHtml() -> string`: Returns the current document markup string.
- `LHtmlDocument:getRoot() -> LHtmlElement`: Returns the root DOM element handle.
- `LHtmlDocument:getViewport() -> number`: Returns the document layout viewport size.
- `LHtmlDocument:isDirty() -> boolean`: Returns whether the document layout is dirty.
- `LHtmlDocument:keypressed(key) -> boolean`: Forwards a key press to the focused document element and dispatches `keydown`.
- `LHtmlDocument:mousemoved(x, y) -> boolean`: Forwards mouse movement to the document.
- `LHtmlDocument:mousepressed(x, y, button?) -> boolean`: Forwards a mouse press to the document and dispatches a click event when an element is hit.
- `LHtmlDocument:mousereleased(x, y, button?) -> boolean`: Forwards a mouse release to the document.
- `LHtmlDocument:off(handle) -> nil`: Removes a document-level event listener by handle.
- `LHtmlDocument:on(event, func) -> integer`: Registers a document-level event listener.
- `LHtmlDocument:query(selector) -> LuaValue`: Looks up the first element matching a selector.
- `LHtmlDocument:queryAll(selector) -> LHtmlElement[]`: Returns all elements matching a selector.
- `LHtmlDocument:relayout() -> nil`: Rebuilds document layout immediately.
- `LHtmlDocument:render(x?, y?) -> nil`: Queues render commands for this document at an optional offset.
- `LHtmlDocument:setCss(css) -> nil`: Replaces the document stylesheet text.
- `LHtmlDocument:setHtml(html) -> nil`: Replaces the document markup and invalidates existing element handles.
- `LHtmlDocument:setViewport(w, h) -> nil`: Sets the document layout viewport size.
- `LHtmlDocument:textinput(text) -> boolean`: Forwards text input to the focused document element and dispatches `input`.
- `LHtmlDocument:type() -> string`: Returns the Lua-visible type name for this HTML document handle.
- `LHtmlDocument:typeOf(name) -> boolean`: Returns whether this document handle matches a supported type name.
- `LHtmlDocument:update(dt) -> nil`: Advances document timers and animated state.
- `LHtmlDocument:wheelmoved(dx, dy) -> boolean`: Forwards mouse wheel movement to the document.

#### LHtmlElement Type

- Lua-side DOM element handle with stale-generation detection.

##### Fields

- No documented fields.

##### Methods

- `LHtmlElement:addClass(name) -> nil`: Adds a CSS class to this element's class list.
- `LHtmlElement:appendHtml(html) -> nil`: Appends HTML source to this element's inner HTML.
- `LHtmlElement:blur() -> nil`: Removes keyboard focus from this element when it is focused.
- `LHtmlElement:focus() -> nil`: Gives keyboard focus to this element.
- `LHtmlElement:getAttribute(name) -> LuaValue`: Returns an attribute value from this element.
- `LHtmlElement:getDocument() -> LHtmlDocument`: Returns the document handle that owns this element.
- `LHtmlElement:getHtml() -> string`: Returns this element's inner HTML.
- `LHtmlElement:getId() -> LuaValue`: Returns this element's id attribute.
- `LHtmlElement:getRect() -> number`: Returns this element's layout rectangle after relayout if needed.
- `LHtmlElement:getStyle(name) -> LuaValue`: Returns an inline or computed style value for this element.
- `LHtmlElement:getTagName() -> string`: Returns this element's HTML tag name.
- `LHtmlElement:getText() -> string`: Returns this element's text content.
- `LHtmlElement:hasClass(name) -> boolean`: Returns whether this element has a CSS class.
- `LHtmlElement:off(handle) -> nil`: Removes an element-level event listener by handle.
- `LHtmlElement:on(event, func) -> integer`: Registers an element-level event listener.
- `LHtmlElement:query(selector) -> LuaValue`: Looks up the first descendant element matching a selector.
- `LHtmlElement:queryAll(selector) -> LHtmlElement[]`: Returns all descendant elements matching a selector.
- `LHtmlElement:remove() -> nil`: Removes this element from the document.
- `LHtmlElement:removeAttribute(name) -> nil`: Removes an attribute from this element.
- `LHtmlElement:removeClass(name) -> nil`: Removes a CSS class from this element.
- `LHtmlElement:setAttribute(name, value?) -> nil`: Sets or clears an attribute on this element.
- `LHtmlElement:setHtml(html) -> nil`: Replaces this element's inner HTML and may invalidate descendant element handles.
- `LHtmlElement:setId(id?) -> nil`: Sets or clears this element's id attribute.
- `LHtmlElement:setStyle(name, value?) -> nil`: Sets or clears a style property on this element.
- `LHtmlElement:setText(text) -> nil`: Replaces this element's text content.
- `LHtmlElement:toggleClass(name, force?) -> boolean`: Toggles a CSS class on this element, optionally forcing the final state.
- `LHtmlElement:type() -> string`: Returns the Lua-visible type name for this HTML element handle.
- `LHtmlElement:typeOf(name) -> boolean`: Returns whether this element handle matches a supported type name.
