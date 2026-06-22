<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/html.md or source docstrings instead. -->

# html

## TL;DR

- Runs interactive HTML/CSS documents with input routing, selector queries, and element mutations.

## General Info

- Module group: `Feature Systems`
- Source path: `src/html`
- Binding: `src/lua_api/html_api.rs`
- Namespace: `lurek.html`
- Lua API surface: `6` functions, `2` types, `54` methods
- User-facing: `true`
- Plugin tier: `not_evaluated`

## Summary

- The `html` module is the in-engine document-style UI surface for users who want markup, styles, and DOM-like interaction inside the runtime.
- Parsing, runtime document state, selectors, style resolution, layout, and event routing work together so a project can build menus, tool panels, and overlays with a web-like authoring model.
- Dynamic mutation matters because the module is not only for static documents: scripts can update attributes, styles, and content while still relying on the same layout and event system.
- Input handling, dirty or reflow behavior, and render-command generation make the feature practical as an interactive UI stack instead of a passive HTML parser.
- Style inheritance and selector resolution are especially valuable because document-driven interfaces stay manageable only when broad presentation rules can change without rewriting every element.
- That authoring model is especially appealing for tool panels and content-driven menus.
- It also keeps document structure visible at runtime.
- Read `html` as the module that turns markup and CSS-like data into live engine UI. Rendering shows the result, but `html` owns how the document is parsed, laid out, mutated, and interacted with.

This module primarily collaborates with `color`. Its responsibility should stay inside the `Edge/Integration` group rather than absorb behavior owned by those neighbors.

## Ownership

- Canonical source: `src/html`
- Owning tier: `Feature Systems`
- Plugin tier: `not_evaluated`
- Lua binding owner: `src/lua_api/html_api.rs`
- Referenced engine modules: `color`

## Imports

- `color`: Imports or references `src/color/`. Cross-group dependency from `Feature Systems` into `Foundations`.

## Source Files

### color.rs

- `src/html/color.rs` owns CSS color parsing that turns author text into normalized RGBA values for HTML styling.
- It handles hex, rgb or rgba, hsl or hsla, and named web colors while clamping channels into one stable output shape.
- Hue normalization, percent handling, alpha parsing, and HSL-to-RGB conversion all live here as color-text semantics.
- This file is the color-text boundary for HTML styles; it does not own DOM state, CSS rules, or selector matching.
- Read it when supported color syntax, channel clamping, or normalized RGBA output rules for HTML styles need changes.

### document.rs

- `src/html/document.rs` owns the full HTML document lifecycle from source text to interactive and drawable UI state.
- It defines `HtmlDocumentOptions`, `HtmlDrawCommand`, and `HtmlDocument`, keeping HTML, CSS, tree, and viewport together.
- Parsing and CSS rebuild orchestration live here so reloads refresh rules, warnings, and element storage coherently.
- Layout, dirty tracking, draw-command emission, and computed style lookup all live here as the document runtime boundary.
- Focus, hover, pointer routing, key input, text entry, and hit testing are coordinated here for HTML controls.
- Query, ancestry, text collection, id lookup, and document-order traversal helpers also live here for inspection.
- This file is the owner of whole-document state; it does not parse selectors or CSS declarations internally from scratch.
- Element insertion, subtree removal, attribute edits, and inline-style updates are routed here so mutations stay synced.
- Read it when HTML rebuild flow, layout policy, interaction state, or draw output behavior for documents needs changes.

### element.rs

- `src/html/element.rs` owns the core DOM element record used to store structure, attributes, text, and geometry.
- It defines `HtmlElementId`, `HtmlRect`, and `HtmlElement`, including parent links, child ids, styles, and removal state.
- Attribute normalization, class-token mutation, inline-style syncing, and hit-test rectangles all live in this file.
- This file is the DOM-storage boundary for HTML; it does not parse source text or orchestrate whole-document layout.
- Read it when element fields, attribute behavior, class handling, or geometry ownership for HTML nodes need changes.
- Parent-child linkage and removal flags stay here so traversal can remain stable without reindexing the element store.

### mod.rs

- `src/html/mod.rs` is the module index for HTML colors, DOM elements, parsing, selectors, styles, and documents.
- It declares the files that own DOM storage, CSS parsing, selector matching, color parsing, and document orchestration.
- This file reexports the main HTML types so callers can use document and element services without deep internal paths.
- No DOM nodes, computed styles, or viewport state live here; it only defines visibility and subsystem boundaries.
- Read this index first when tracing HTML behavior, because it shows where parsing, storage, and interaction split.
- Changes here affect reachability and API shape, not selector semantics, layout rules, or text parsing behavior.

### parser.rs

- `src/html/parser.rs` owns HTML text parsing, entity handling, and tree construction into live element storage.
- It handles open, close, self-closing, void, and comment tags while keeping parent-child links and text collapse stable.
- Attribute parsing, quote-aware scanning, key normalization, and supported entity decoding all live here together.
- This file is the text-to-DOM boundary for HTML content; it does not own CSS cascade, layout, or interactive state.
- Read it when tag parsing, attribute decoding, or entity and text-normalization behavior for HTML input needs changes.

### selector.rs

- `src/html/selector.rs` owns CSS-like selector parsing and element matching against the live HTML tree.
- It parses tag, id, class, descendant, and child relationships into ordered selector parts with stable chain semantics.
- Parent-walk matching lives here so ancestry-aware filtering stays separate from DOM storage and CSS rule collection.
- This file is the selector-evaluation boundary for HTML documents; it does not own parsed styles or element mutation.
- Read it when selector syntax, combinator behavior, or tree-matching semantics for HTML queries need changes.

### style.rs

- `src/html/style.rs` owns stylesheet parsing, declaration normalization, and CSS length parsing for HTML layout.
- It defines `CssRule` and `CssParseResult`, keeping selector rules, declaration maps, and parse warnings in one owner.
- Supported-property filtering and normalized property names live here so later cascade merges operate on stable keys.
- This file is the CSS-rule parsing boundary for HTML; it does not own selector matching, DOM nodes, or layout state.
- Read it when CSS property support, declaration parsing, or px and percent length semantics need changes.



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

## Examples

- `content/examples/html.lua` (present)

## Tests

- Lua unit: `tests/lua/unit/test_html_unit.lua` (present)
- Rust: `tests/rust/unit/html_tests.rs`

## Evidence / Golden

| Kind | Path |
|---|---|
| Evidence test | `tests/lua/evidence/test_html_evidence.lua` |
| Golden test | `tests/lua/golden/test_html_golden.lua` |
| Current artifact | `tests/artifacts/current/html/html_click_event_trace.txt` |
| Current artifact | `tests/artifacts/current/html/html_document_markup_snapshot.txt` |
| Current artifact | `tests/artifacts/current/html/html_element_state.json` |
| Current artifact | `tests/artifacts/current/html/html_lifecycle_trace.txt` |
| Current artifact | `tests/artifacts/current/html/html_loaded_document_snapshot.txt` |
| Current artifact | `tests/artifacts/current/html/html_mutation_snapshot.txt` |
| Current artifact | `tests/artifacts/current/html/html_query_viewport_snapshot.json` |
| Current artifact | `tests/artifacts/current/html/html_support_render_trace.txt` |
| Baseline artifact | `tests/artifacts/baselines/html/html_click_event_trace.txt` |
| Baseline artifact | `tests/artifacts/baselines/html/html_document_markup_snapshot.txt` |
| Baseline artifact | `tests/artifacts/baselines/html/html_element_state.json` |
| Baseline artifact | `tests/artifacts/baselines/html/html_mutation_snapshot.txt` |
| Baseline artifact | `tests/artifacts/baselines/html/html_query_viewport_snapshot.json` |

## Architecture Links

- Intentionally empty.

## Notes

- No additional module-specific notes.
