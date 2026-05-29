# html

## TL;DR

- The `html` module is a powerful Edge/Integration tier component that provides a complete HTML/CSS document engine for Lurek2D.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/html/`
- Lua API path(s): `src/lua_api/html_api.rs`
- Primary Lua namespace: `lurek.html`
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

It empowers game developers to construct complex, responsive User Interfaces (UIs) using familiar web markup technologies rather than proprietary layout languages. The engine fully parses raw HTML strings into a live DOM tree populated with `HtmlElement` nodes. It evaluates cascaded CSS stylesheets—supporting extensive CSS selector matching including tag, class, id, attribute, pseudo-classes, and relationship combinators—to resolve a computed style for every element.

Layout computation is driven by a flexible vertical block layout engine with robust flexbox support, accurately calculating an `HtmlRect` for every DOM node. Instead of rendering pixels directly, the module translates the computed layout into a renderer-agnostic list of `HtmlDrawCommand` instructions (rectangles, text, borders, images, and clipping regions). The engine includes a comprehensive CSS color parser that understands hex, `rgb()`, `rgba()`, `hsl()`, `hsla()`, and an extended set of named color keywords.

The module also handles complex text rendering, ensuring accurate wrapping, alignment, and multi-line overflow management. Furthermore, the `html` module is deeply interactive. It routes user input—such as mouse clicks, hover events, keyboard focus, and text input—directly to the appropriate DOM elements, executing bound Lua callbacks (`mousepressed`, `mousemoved`, `keypressed`). The entire document lifecycle, from DOM queries (`getElementById`, `querySelector`) to dynamic structural mutations, is fully scriptable via the `lurek.html.*` API.

## Files

### color.rs

- CSS color string parsing: hex, `rgb()`, `rgba()`, `hsl()`, `hsla()`, and named keywords.
- Component extraction for RGB bytes/percent, alpha, hue (deg/turn/rad), and percent values.
- HSL-to-RGB conversion with full hue normalization.
- Named color lookup covering the CSS basic and extended keyword set.
- All outputs normalized to `[f32; 4]` in the 0.0–1.0 range.

### document.rs

- Owns `HtmlDocument`, the mutable tree that holds parsed elements, CSS state, and interaction focus.
- Provides document construction from raw HTML with optional viewport size and initial CSS.
- Manages CSS source accumulation, rule parsing, and per-element computed style resolution.
- Implements a simple vertical block layout engine with dirty-flag tracking and viewport resize.
- Exposes DOM query helpers: element-by-id, CSS selector matching, ancestor traversal.
- Supports DOM mutation: set/append inner HTML, set text, remove elements, attribute and class ops.
- Handles focus, hover, hit-testing, mouse/keyboard routing, and text input for form elements.
- Produces `HtmlDrawCommand` vectors consumed by the renderer for box and text passes.
- Includes inner/outer HTML serialization and document-order traversal utilities.

### element.rs

- DOM element model: tag, attributes, children, parent linkage, and text content.
- Inline style handling with bidirectional sync to the `style` attribute.
- Class list manipulation: add, remove, toggle, and membership queries.
- Axis-aligned layout rectangle for hit testing and position queries.
- Attribute normalization and void-tag classification helpers.

### mod.rs

- HTML document tree with element storage, layout rectangles, and draw-command generation.
- CSS rule parsing, selector matching, and color normalization.
- Tag parsing and entity escaping for inline HTML content.

### parser.rs

- Parse raw HTML strings into a live element tree with parent-child relationships.
- Split tag headers, extract and normalize attribute key-value pairs.
- Decode and encode the small HTML entity set (amp, lt, gt, quot, #39).
- Collapse whitespace in text nodes before attaching to elements.
- Handle self-closing tags, void tags, closing tags, and comments.

### selector.rs

- CSS selector matching for the HTML element tree.
- Parse selector strings into tag, id, class, and combinator fragments.
- Support descendant and child combinators for ancestor-chain traversal.
- Match parsed selector chains against live elements by walking parent links.
- Provide the core predicate used by style resolution and query APIs.

### style.rs

- CSS stylesheet parsing: split source text into selector/declaration blocks.
- Declaration normalization: property validation, value extraction, warning collection.
- Length unit resolution: convert px, %, and unitless values to pixel floats.

## Lua API Ref

- Binding: `src/lua_api/html_api.rs`
- Namespace: `lurek.html`

### Functions

- `lurek.html.isDefaultPrevented`: Returns whether the default action was prevented.
- `lurek.html.loadDocument`: Loads an HTML document from GameFS and optionally loads CSS from options or companion file.
- `lurek.html.newDocument`: Creates an HTML document from optional source and layout/style options.
- `lurek.html.preventDefault`: Marks the event as having its default action prevented.
- `lurek.html.stopPropagation`: Stops event propagation to remaining listeners.
- `lurek.html.supports`: Returns whether the HTML engine supports a named feature.

### Enums

- No documented module-level enums/constants.

### Types


#### LHtmlDocument Type


##### Fields

- No documented fields.

##### Methods

- `LHtmlDocument:addCss`: Appends CSS source text to the document stylesheet.
- `LHtmlDocument:clearCss`: Clears all CSS source text from the document.
- `LHtmlDocument:draw`: Queues render commands for this document at an optional offset.
- `LHtmlDocument:getElementById`: Looks up the first element with a matching id attribute.
- `LHtmlDocument:getHtml`: Returns the current document markup string.
- `LHtmlDocument:getRoot`: Returns the root DOM element handle.
- `LHtmlDocument:getViewport`: Returns the document layout viewport size.
- `LHtmlDocument:isDirty`: Returns whether the document layout is dirty.
- `LHtmlDocument:keypressed`: Forwards a key press to the focused document element and dispatches `keydown`.
- `LHtmlDocument:mousemoved`: Forwards mouse movement to the document.
- `LHtmlDocument:mousepressed`: Forwards a mouse press to the document and dispatches a click event when an element is hit.
- `LHtmlDocument:mousereleased`: Forwards a mouse release to the document.
- `LHtmlDocument:off`: Removes a document-level event listener by handle.
- `LHtmlDocument:on`: Registers a document-level event listener.
- `LHtmlDocument:query`: Looks up the first element matching a selector.
- `LHtmlDocument:queryAll`: Returns all elements matching a selector.
- `LHtmlDocument:relayout`: Rebuilds document layout immediately.
- `LHtmlDocument:render`: Queues render commands for this document at an optional offset.
- `LHtmlDocument:setCss`: Replaces the document stylesheet text.
- `LHtmlDocument:setHtml`: Replaces the document markup and invalidates existing element handles.
- `LHtmlDocument:setViewport`: Sets the document layout viewport size.
- `LHtmlDocument:textinput`: Forwards text input to the focused document element and dispatches `input`.
- `LHtmlDocument:type`: Returns the Lua-visible type name for this HTML document handle.
- `LHtmlDocument:typeOf`: Returns whether this document handle matches a supported type name.
- `LHtmlDocument:update`: Advances document timers and animated state.
- `LHtmlDocument:wheelmoved`: Forwards mouse wheel movement to the document.


#### LHtmlElement Type


##### Fields

- No documented fields.

##### Methods

- `LHtmlElement:addClass`: Adds a CSS class to this element's class list.
- `LHtmlElement:appendHtml`: Appends HTML source to this element's inner HTML.
- `LHtmlElement:blur`: Removes keyboard focus from this element when it is focused.
- `LHtmlElement:focus`: Gives keyboard focus to this element.
- `LHtmlElement:getAttribute`: Returns an attribute value from this element.
- `LHtmlElement:getDocument`: Returns the document handle that owns this element.
- `LHtmlElement:getHtml`: Returns this element's inner HTML.
- `LHtmlElement:getId`: Returns this element's id attribute.
- `LHtmlElement:getRect`: Returns this element's layout rectangle after relayout if needed.
- `LHtmlElement:getStyle`: Returns an inline or computed style value for this element.
- `LHtmlElement:getTagName`: Returns this element's HTML tag name.
- `LHtmlElement:getText`: Returns this element's text content.
- `LHtmlElement:hasClass`: Returns whether this element has a CSS class.
- `LHtmlElement:off`: Removes an element-level event listener by handle.
- `LHtmlElement:on`: Registers an element-level event listener.
- `LHtmlElement:query`: Looks up the first descendant element matching a selector.
- `LHtmlElement:queryAll`: Returns all descendant elements matching a selector.
- `LHtmlElement:remove`: Removes this element from the document.
- `LHtmlElement:removeAttribute`: Removes an attribute from this element.
- `LHtmlElement:removeClass`: Removes a CSS class from this element.
- `LHtmlElement:setAttribute`: Sets or clears an attribute on this element.
- `LHtmlElement:setHtml`: Replaces this element's inner HTML and may invalidate descendant element handles.
- `LHtmlElement:setId`: Sets or clears this element's id attribute.
- `LHtmlElement:setStyle`: Sets or clears a style property on this element.
- `LHtmlElement:setText`: Replaces this element's text content.
- `LHtmlElement:toggleClass`: Toggles a CSS class on this element, optionally forcing the final state.
- `LHtmlElement:type`: Returns the Lua-visible type name for this HTML element handle.
- `LHtmlElement:typeOf`: Returns whether this element handle matches a supported type name.

## References

- `color`: Imports or references `src/color/`. Cross-group dependency from ``Edge/Integration`` into `Edge/Integration`.
