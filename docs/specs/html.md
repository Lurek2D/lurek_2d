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
- Lua test path(s): tests/lua/unit/test_html_unit.lua

## Summary

- This module gives users an in-engine HTML/CSS UI layer for menus, HUDs, and tool panels.
- Markup and stylesheet parsing produce a runtime DOM model that can be queried and mutated from scripts.
- Layout computation applies box-model style rules to generate deterministic element geometry.
- Selector support allows class/id/ancestry targeting for dynamic UI behavior.
- Runtime style and attribute mutation makes reactive interfaces practical without rebuilding documents.
- Input routing handles clicks, focus, keyboard, wheel, and text events on document and element scopes.
- Event hooks support component-style interaction patterns directly in Lua.
- Dirty/reflow management keeps relayout explicit when content or style changes.
- Viewport APIs support responsive behavior across window sizes.
- Render-command generation bridges computed layout into the engine draw pipeline.
- The module is useful for interactive overlays, launcher-style screens, and debug UIs.
- For users, it brings familiar web-style authoring ergonomics into game runtime workflows.
- It reduces boilerplate for complex UI state handling and DOM-like interaction logic.
- Overall, users get a script-controllable UI stack with both declarative styling and imperative control.

This module primarily collaborates with `color`. Its responsibility should stay inside the `Edge/Integration` group rather than absorb behavior owned by those neighbors.

## Imports

- `color`: Imports or references `src/color/`. Cross-group dependency from ``Edge/Integration`` into `Edge/Integration`.

## Files

### color.rs

- Turns raw CSS color text into normalized RGBA values ready for render-side blending. `html/color` delivers the color implementation for the html subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Accepts hex codes, rgb/rgba, hsl/hsla forms, and named web colors used by authored styles. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Normalizes hue units and percentage channels so mixed input formats resolve to one stable shape. Public callable behavior is centered on `parse_css_color_rgba`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Applies alpha parsing with clamping semantics that keep transparent and opaque intent predictable. Runtime integration reaches sibling engine areas through crate modules `color`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### document.rs

- Orchestrates the full HTML document lifecycle from source text to interactive, drawable UI state. `html/document` delivers the document implementation for the html subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Builds and rebuilds element trees while preserving viewport constraints and accumulated stylesheet inputs. The file owns or coordinates data contracts including `HtmlDocumentOptions`, `HtmlDrawCommand`, `HtmlDocument`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Resolves selector-driven style cascades into computed per-element visual properties for later layout. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `with_options`, `supports`, `generation`, `root`, `element`, and 39 more stays attached to the local data model and invariants.
- Runs block-style layout passes with dirty tracking so structural and style edits trigger fresh geometry. Runtime integration reaches sibling engine areas through crate modules `html`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Supports focused and hovered interaction state used by pointer routing, keyboard input, and text editing. External integration uses `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Exposes traversal and lookup paths for id, selector, ancestry, and document-order element queries. The file boundary separates html implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

### element.rs

- Defines the core DOM node shape used to store structure, attributes, text, and layout geometry. `html/element` delivers the element implementation for the html subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Keeps normalized attribute and inline-style maps in sync so style edits remain coherent with HTML state. The file owns or coordinates data contracts including `HtmlElementId`, `HtmlRect`, `HtmlElement`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Provides class token mutation paths that preserve deterministic ordering and membership checks. Public callable behavior is centered on `normalise_name`, while method-level behavior such as `contains`, `new`, `id`, `tag_name`, `parent`, `children`, and 14 more stays attached to the local data model and invariants.
- Tracks parent-child linkage and removal flags to support stable traversal without index churn. Runtime integration reaches sibling engine areas through crate modules `html`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Carries axis-aligned rectangles for hit testing, layout output, and pointer targeting in UI flow. External integration uses `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### mod.rs

- High-level HTML module surface that composes parsing, styling, selection, and document orchestration. `html/mod` is the html module index, declaring `color`, `document`, `element`, `parser`, `selector`, and 1 more so agents can identify which files own each feature slice before opening implementation code.
- Re-exports stable document and element types used by runtime code interacting with HTML-driven UI. `src/html/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `color::parse_css_color_rgba`, `document::{HtmlDocument, HtmlDocumentOptions, HtmlDrawCommand}`, `element::{HtmlElement, HtmlElementId, HtmlRect}` centralized for the html subsystem.

### parser.rs

- Converts raw HTML text into document nodes with stable parent-child links and normalized attributes. `html/parser` delivers the text parsing and structured conversion for the html subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Handles open, close, self-closing, void, and comment forms so authored markup maps to valid tree state. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Parses attribute key-value pairs with quote-aware scanning and consistent lowercase key normalization. Public callable behavior is centered on `parse_into`, `escape_text`, `escape_attribute`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Encodes and decodes common HTML entities to preserve readable text while keeping stored values canonical. Runtime integration reaches sibling engine areas through crate modules `html`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### selector.rs

- Implements selector matching logic that maps CSS-like queries onto the live HTML element tree. `html/selector` delivers the selector implementation for the html subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Parses selector text into tag, id, class, and combinator fragments with deterministic chain ordering. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supports descendant and direct-child relationships for ancestry-aware filtering semantics. Public callable behavior is centered on `matches_selector`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Walks parent links to evaluate multi-part selector chains against runtime element topology. Runtime integration reaches sibling engine areas through crate modules `html`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### style.rs

- Parses stylesheet sources into ordered selector rules and normalized declaration maps for HTML layout. `html/style` delivers the style implementation for the html subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Validates supported properties while collecting non-fatal warnings for unknown or malformed inputs. The file owns or coordinates data contracts including `CssRule`, `CssParseResult`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Normalizes declaration keys and values so later cascade merges operate on stable property naming. Public callable behavior is centered on `parse_stylesheets`, `parse_declarations`, `parse_length`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Resolves pixel, percent, and unitless length text into float values against caller-provided bases. Runtime integration reaches sibling engine areas through crate modules `html`, which explains the subsystem dependencies an agent should inspect before changing behavior.



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

## References

- `color`: Imports or references `src/color/`. Cross-group dependency from ``Edge/Integration`` into `Edge/Integration`.

## Notes

- No additional module-specific notes.
