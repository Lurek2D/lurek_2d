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

## Source Documentation

### `color.rs`
- CSS color string parsing: hex, `rgb()`, `rgba()`, `hsl()`, `hsla()`, and named keywords.
- Component extraction for RGB bytes/percent, alpha, hue (deg/turn/rad), and percent values.
- HSL-to-RGB conversion with full hue normalization.
- Named color lookup covering the CSS basic and extended keyword set.
- All outputs normalized to `[f32; 4]` in the 0.0–1.0 range.

### `document.rs`
- Owns `HtmlDocument`, the mutable tree that holds parsed elements, CSS state, and interaction focus.
- Provides document construction from raw HTML with optional viewport size and initial CSS.
- Manages CSS source accumulation, rule parsing, and per-element computed style resolution.
- Implements a simple vertical block layout engine with dirty-flag tracking and viewport resize.
- Exposes DOM query helpers: element-by-id, CSS selector matching, ancestor traversal.
- Supports DOM mutation: set/append inner HTML, set text, remove elements, attribute and class ops.
- Handles focus, hover, hit-testing, mouse/keyboard routing, and text input for form elements.
- Produces `HtmlDrawCommand` vectors consumed by the renderer for box and text passes.
- Includes inner/outer HTML serialization and document-order traversal utilities.

### `element.rs`
- DOM element model: tag, attributes, children, parent linkage, and text content.
- Inline style handling with bidirectional sync to the `style` attribute.
- Class list manipulation: add, remove, toggle, and membership queries.
- Axis-aligned layout rectangle for hit testing and position queries.
- Attribute normalization and void-tag classification helpers.

### `mod.rs`
- HTML document tree with element storage, layout rectangles, and draw-command generation.
- CSS rule parsing, selector matching, and color normalization.
- Tag parsing and entity escaping for inline HTML content.

### `parser.rs`
- Parse raw HTML strings into a live element tree with parent-child relationships.
- Split tag headers, extract and normalize attribute key-value pairs.
- Decode and encode the small HTML entity set (amp, lt, gt, quot, #39).
- Collapse whitespace in text nodes before attaching to elements.
- Handle self-closing tags, void tags, closing tags, and comments.

### `selector.rs`
- CSS selector matching for the HTML element tree.
- Parse selector strings into tag, id, class, and combinator fragments.
- Support descendant and child combinators for ancestor-chain traversal.
- Match parsed selector chains against live elements by walking parent links.
- Provide the core predicate used by style resolution and query APIs.

### `style.rs`
- CSS stylesheet parsing: split source text into selector/declaration blocks.
- Declaration normalization: property validation, value extraction, warning collection.
- Length unit resolution: convert px, %, and unitless values to pixel floats.

## Types

- `HtmlDocumentOptions` (`struct`, `document.rs`): Configuration options for [`HtmlDocument::new`].
- `HtmlDrawCommand` (`struct`, `document.rs`): A single renderer-agnostic draw instruction produced by [`HtmlDocument::draw`].
- `HtmlDocument` (`struct`, `document.rs`): An HTML/CSS document with an integrated layout engine and draw-command emitter.
- `HtmlElementId` (`type`, `element.rs`): Opaque index into the element arena inside [`super::document::HtmlDocument`].
- `HtmlRect` (`struct`, `element.rs`): Axis-aligned bounding rectangle in screen pixels, set during the layout pass.
- `HtmlElement` (`struct`, `element.rs`): A single DOM element node within an [`super::document::HtmlDocument`] arena.
- `CssRule` (`struct`, `style.rs`): A parsed CSS rule with a selector string and a property → value map.
- `CssParseResult` (`struct`, `style.rs`): Output of [`parse_declarations`] — a property map and any parse warnings.

## Functions

- `parse_css_color_rgba` (`color.rs`): Parse a CSS color string and return normalized RGBA components, or `None` when unsupported.
- `HtmlDocument::new` (`document.rs`): Build a document from HTML using default options.
- `HtmlDocument::with_options` (`document.rs`): Build a document from HTML and explicit viewport or CSS options.
- `HtmlDocument::supports` (`document.rs`): Report whether the HTML engine supports a named capability.
- `HtmlDocument::generation` (`document.rs`): Return the current rebuild generation counter.
- `HtmlDocument::root` (`document.rs`): Return the root element id.
- `HtmlDocument::element` (`document.rs`): Return a live element reference when the id exists and is not removed.
- `HtmlDocument::get_html` (`document.rs`): Return the source HTML string currently stored in the document.
- `HtmlDocument::set_html` (`document.rs`): Replace the source HTML, rebuild the tree, and mark the document dirty.
- `HtmlDocument::set_css` (`document.rs`): Append a CSS source string and rebuild the CSS rule cache.
- `HtmlDocument::add_css` (`document.rs`): Add a CSS source string and rebuild the CSS rule cache.
- `HtmlDocument::clear_css` (`document.rs`): Clear all CSS sources and mark the document dirty.
- `HtmlDocument::set_viewport` (`document.rs`): Update the viewport size and mark the document dirty.
- `HtmlDocument::viewport` (`document.rs`): Return the current viewport size.
- `HtmlDocument::update` (`document.rs`): Rebuild layout when dirty and ignore the supplied delta time.
- `HtmlDocument::is_dirty` (`document.rs`): Return whether the document needs layout recomputation.
- `HtmlDocument::relayout` (`document.rs`): Recompute root layout and clear the dirty flag.
- `HtmlDocument::draw_commands` (`document.rs`): Return draw commands for the document at the given screen offset.
- `HtmlDocument::get_element_by_id` (`document.rs`): Return the first live element with a matching `id` attribute.
- `HtmlDocument::query` (`document.rs`): Return the first live element matching a selector from the document root.
- `HtmlDocument::query_all` (`document.rs`): Return all live elements matching a selector from the document root.
- `HtmlDocument::query_from` (`document.rs`): Return the first live descendant of `start` matching a selector.
- `HtmlDocument::query_all_from` (`document.rs`): Return all live descendants of `start` matching a selector.
- `HtmlDocument::ancestors_inclusive` (`document.rs`): Return the inclusive ancestor chain for a live element, starting at the element itself.
- `HtmlDocument::text` (`document.rs`): Return the concatenated visible text for a live element or `None` when missing.
- `HtmlDocument::set_text` (`document.rs`): Replace an element's text content, remove descendants, and return success.
- `HtmlDocument::element_html` (`document.rs`): Return serialized inner HTML for a live element or `None` when missing.
- `HtmlDocument::set_element_html` (`document.rs`): Replace an element's children with parsed HTML and return success.
- `HtmlDocument::append_element_html` (`document.rs`): Append parsed HTML as children of a live element and return success.
- `HtmlDocument::remove_element` (`document.rs`): Remove a non-root element and mark its subtree removed.
- `HtmlDocument::set_attribute` (`document.rs`): Set an attribute on a live element and return whether the update succeeded.
- `HtmlDocument::set_id_attribute` (`document.rs`): Set an element's `id` attribute and return whether the update succeeded.
- `HtmlDocument::add_class` (`document.rs`): Add a class to a live element and return whether the update succeeded.
- `HtmlDocument::remove_class` (`document.rs`): Remove a class from a live element and return whether the update succeeded.
- `HtmlDocument::toggle_class` (`document.rs`): Toggle a class on a live element and return the resulting class state.
- `HtmlDocument::style_value` (`document.rs`): Return the computed or inline style value for a property.
- `HtmlDocument::set_style` (`document.rs`): Set an inline style property on a live element and return whether it succeeded.
- `HtmlDocument::focus` (`document.rs`): Focus a live element and return whether the focus target existed.
- `HtmlDocument::blur` (`document.rs`): Clear focus when the given element is focused and return true.
- `HtmlDocument::mouse_pressed` (`document.rs`): Hit-test mouse press coordinates, update focus, and return the target element.
- `HtmlDocument::mouse_released` (`document.rs`): Hit-test mouse release coordinates and return the target element.
- `HtmlDocument::mouse_moved` (`document.rs`): Update hover state from mouse coordinates and return the hovered element.
- `HtmlDocument::wheel_moved` (`document.rs`): Return the hovered element or the focused element for wheel input.
- `HtmlDocument::key_pressed` (`document.rs`): Return the focused element or root when a key is pressed.
- `HtmlDocument::text_input` (`document.rs`): Append text input to a focused `input` element and return its id.
- `HtmlDocument::warnings` (`document.rs`): Return collected warnings from parsing, CSS, and layout.
- `HtmlRect::contains` (`element.rs`): Return whether the point lies inside the rectangle bounds.
- `HtmlElement::new` (`element.rs`): Create a new element with empty attributes, children, text, and layout.
- `HtmlElement::id` (`element.rs`): Return the stable element id.
- `HtmlElement::tag_name` (`element.rs`): Return the lowercased tag name.
- `HtmlElement::parent` (`element.rs`): Return the parent element id, or `None` for the root.
- `HtmlElement::children` (`element.rs`): Return the child element ids in document order.
- `HtmlElement::rect` (`element.rs`): Return the current layout rectangle.
- `HtmlElement::attribute` (`element.rs`): Return a normalized attribute value by name.
- `HtmlElement::set_attribute` (`element.rs`): Set or clear an attribute and keep inline style state in sync.
- `HtmlElement::id_attribute` (`element.rs`): Return the `id` attribute value when present.
- `HtmlElement::set_id_attribute` (`element.rs`): Set the `id` attribute value.
- `HtmlElement::has_class` (`element.rs`): Return whether the element currently has the named class.
- `HtmlElement::add_class` (`element.rs`): Add a class name when it is non-empty and not already present.
- `HtmlElement::remove_class` (`element.rs`): Remove a class name from the class list.
- `HtmlElement::toggle_class` (`element.rs`): Toggle a class name and return the resulting presence state.
- `HtmlElement::style` (`element.rs`): Return an inline style property by normalized name.
- `HtmlElement::set_style` (`element.rs`): Set an inline style property and keep the serialized `style` attribute updated.
- `HtmlElement::is_removed` (`element.rs`): Return whether this element has been removed from the live tree.
- `HtmlElement::is_void_tag` (`element.rs`): Return whether the tag is void and should not receive closing markup.
- `HtmlElement::class_names` (`element.rs`): Return an iterator over whitespace-separated class names.
- `normalise_name` (`element.rs`): Trims and lowercases `name` for consistent attribute / property map keying.
- `parse_into` (`parser.rs`): Parses `html` and appends new elements under `parent`, returning the direct child ids.
- `escape_text` (`parser.rs`): Escapes `&`, `<`, and `>` for safe inclusion in HTML text content.
- `escape_attribute` (`parser.rs`): Escapes `&`, `<`, `>`, and `"` for safe inclusion in HTML attribute values.
- `matches_selector` (`selector.rs`): Returns `true` if `element_id` satisfies the CSS `selector` within the element arena.
- `parse_stylesheets` (`style.rs`): Parses multiple stylesheet source strings into a flat list of [`CssRule`]s and any warnings.
- `parse_declarations` (`style.rs`): Parses a single CSS declaration block (e.g.
- `parse_length` (`style.rs`): Parses a CSS length value (`px`, `%` relative to `basis`, or bare `f32`).

## Lua API Reference

- Binding path(s): `src/lua_api/html_api.rs`
- Namespace: `lurek.html`

### Module Functions
- `lurek.html.preventDefault`: Marks the event as having its default action prevented.
- `lurek.html.stopPropagation`: Stops event propagation to remaining listeners.
- `lurek.html.isDefaultPrevented`: Returns whether the default action was prevented.
- `lurek.html.newDocument`: Creates an HTML document from optional source and layout/style options.
- `lurek.html.loadDocument`: Loads an HTML document from GameFS and optionally loads CSS from options or companion file.
- `lurek.html.supports`: Returns whether the HTML engine supports a named feature.

### `LHtmlDocument` Methods
- `LHtmlDocument:setHtml`: Replaces the document markup and invalidates existing element handles.
- `LHtmlDocument:getHtml`: Returns the current document markup string.
- `LHtmlDocument:setCss`: Replaces the document stylesheet text.
- `LHtmlDocument:addCss`: Appends CSS source text to the document stylesheet.
- `LHtmlDocument:clearCss`: Clears all CSS source text from the document.
- `LHtmlDocument:setViewport`: Sets the document layout viewport size.
- `LHtmlDocument:getViewport`: Returns the document layout viewport size.
- `LHtmlDocument:update`: Advances document timers and animated state.
- `LHtmlDocument:draw`: Queues render commands for this document at an optional offset.
- `LHtmlDocument:render`: Queues render commands for this document at an optional offset.
- `LHtmlDocument:relayout`: Rebuilds document layout immediately.
- `LHtmlDocument:isDirty`: Returns whether the document layout is dirty.
- `LHtmlDocument:getRoot`: Returns the root DOM element handle.
- `LHtmlDocument:getElementById`: Looks up the first element with a matching id attribute.
- `LHtmlDocument:query`: Looks up the first element matching a selector.
- `LHtmlDocument:queryAll`: Returns all elements matching a selector.
- `LHtmlDocument:on`: Registers a document-level event listener.
- `LHtmlDocument:off`: Removes a document-level event listener by handle.
- `LHtmlDocument:mousepressed`: Forwards a mouse press to the document and dispatches a click event when an element is hit.
- `LHtmlDocument:mousereleased`: Forwards a mouse release to the document.
- `LHtmlDocument:mousemoved`: Forwards mouse movement to the document.
- `LHtmlDocument:wheelmoved`: Forwards mouse wheel movement to the document.
- `LHtmlDocument:keypressed`: Forwards a key press to the focused document element and dispatches `keydown`.
- `LHtmlDocument:textinput`: Forwards text input to the focused document element and dispatches `input`.
- `LHtmlDocument:type`: Returns the Lua-visible type name for this HTML document handle.
- `LHtmlDocument:typeOf`: Returns whether this document handle matches a supported type name.

### `LHtmlElement` Methods
- `LHtmlElement:getDocument`: Returns the document handle that owns this element.
- `LHtmlElement:getTagName`: Returns this element's HTML tag name.
- `LHtmlElement:getId`: Returns this element's id attribute.
- `LHtmlElement:setId`: Sets or clears this element's id attribute.
- `LHtmlElement:getText`: Returns this element's text content.
- `LHtmlElement:setText`: Replaces this element's text content.
- `LHtmlElement:getHtml`: Returns this element's inner HTML.
- `LHtmlElement:setHtml`: Replaces this element's inner HTML and may invalidate descendant element handles.
- `LHtmlElement:appendHtml`: Appends HTML source to this element's inner HTML.
- `LHtmlElement:remove`: Removes this element from the document.
- `LHtmlElement:getAttribute`: Returns an attribute value from this element.
- `LHtmlElement:setAttribute`: Sets or clears an attribute on this element.
- `LHtmlElement:removeAttribute`: Removes an attribute from this element.
- `LHtmlElement:hasClass`: Returns whether this element has a CSS class.
- `LHtmlElement:addClass`: Adds a CSS class to this element's class list.
- `LHtmlElement:removeClass`: Removes a CSS class from this element.
- `LHtmlElement:toggleClass`: Toggles a CSS class on this element, optionally forcing the final state.
- `LHtmlElement:getStyle`: Returns an inline or computed style value for this element.
- `LHtmlElement:setStyle`: Sets or clears a style property on this element.
- `LHtmlElement:getRect`: Returns this element's layout rectangle after relayout if needed.
- `LHtmlElement:focus`: Gives keyboard focus to this element.
- `LHtmlElement:blur`: Removes keyboard focus from this element when it is focused.
- `LHtmlElement:query`: Looks up the first descendant element matching a selector.
- `LHtmlElement:queryAll`: Returns all descendant elements matching a selector.
- `LHtmlElement:on`: Registers an element-level event listener.
- `LHtmlElement:off`: Removes an element-level event listener by handle.
- `LHtmlElement:type`: Returns the Lua-visible type name for this HTML element handle.
- `LHtmlElement:typeOf`: Returns whether this element handle matches a supported type name.

## References

- `color`: Imports or references `src/color/`. Cross-group dependency from ``Edge/Integration`` into `Edge/Integration`.

## Notes

- Keep this module reference synchronized with `src/html/` and any matching Lua bindings.
- UI boundary: `lurek.html` is the document/CSS-oriented UI layer for HTML strings, DOM mutation, CSS selectors, computed style, document layout, and DOM-style input events. Use [`lurek.ui`](ui.md) instead when you want native retained widgets, themes, focus navigation, TOML layouts, charts, or table widgets without DOM/CSS authoring.
- HTML draw-command color parsing accepts hex, `rgb/rgba`, `hsl/hsla`, `transparent`, and an extended set of CSS named colors (for example `orange`, `teal`, `crimson`, `indigo`).
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
