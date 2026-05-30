# html

## General Info

- Module group: `Edge/Integration`
- Source path: `src/html/`
- Binding: `src/lua_api/html_api.rs`
- Namespace: `lurek.html`
- Lua API surface: `6` functions, `2` types, `54` methods
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

It empowers game developers to construct complex, responsive User Interfaces (UIs) using familiar web markup technologies rather than proprietary layout languages. The engine fully parses raw HTML strings into a live DOM tree populated with `HtmlElement` nodes. It evaluates cascaded CSS stylesheets—supporting extensive CSS selector matching including tag, class, id, attribute, pseudo-classes, and relationship combinators—to resolve a computed style for every element.

Layout computation is driven by a flexible vertical block layout engine with robust flexbox support, accurately calculating an `HtmlRect` for every DOM node. Instead of rendering pixels directly, the module translates the computed layout into a renderer-agnostic list of `HtmlDrawCommand` instructions (rectangles, text, borders, images, and clipping regions). The engine includes a comprehensive CSS color parser that understands hex, `rgb()`, `rgba()`, `hsl()`, `hsla()`, and an extended set of named color keywords.

The module also handles complex text rendering, ensuring accurate wrapping, alignment, and multi-line overflow management. Furthermore, the `html` module is deeply interactive. It routes user input—such as mouse clicks, hover events, keyboard focus, and text input—directly to the appropriate DOM elements, executing bound Lua callbacks (`mousepressed`, `mousemoved`, `keypressed`). The entire document lifecycle, from DOM queries (`getElementById`, `querySelector`) to dynamic structural mutations, is fully scriptable via the `lurek.html.*` API.

## Files

### [color.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/html/color.rs)

- Turns raw CSS color text into normalized RGBA values ready for render-side blending.
- Accepts hex codes, rgb/rgba, hsl/hsla forms, and named web colors used by authored styles.
- Normalizes hue units and percentage channels so mixed input formats resolve to one stable shape.
- Applies alpha parsing with clamping semantics that keep transparent and opaque intent predictable.
- Returns compact `[f32; 4]` color vectors in 0..1 space for direct engine consumption.

### [document.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/html/document.rs)

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

### [element.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/html/element.rs)

- Defines the core DOM node shape used to store structure, attributes, text, and layout geometry.
- Keeps normalized attribute and inline-style maps in sync so style edits remain coherent with HTML state.
- Provides class token mutation paths that preserve deterministic ordering and membership checks.
- Tracks parent-child linkage and removal flags to support stable traversal without index churn.
- Carries axis-aligned rectangles for hit testing, layout output, and pointer targeting in UI flow.
- Supplies normalization and void-element classification rules that guide parsing and tree mutations.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/html/mod.rs)

- High-level HTML module surface that composes parsing, styling, selection, and document orchestration.
- Re-exports stable document and element types used by runtime code interacting with HTML-driven UI.
- Binds color, parser, selector, and style helpers into one cohesive entry point for the subsystem.

### [parser.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/html/parser.rs)

- Converts raw HTML text into document nodes with stable parent-child links and normalized attributes.
- Handles open, close, self-closing, void, and comment forms so authored markup maps to valid tree state.
- Parses attribute key-value pairs with quote-aware scanning and consistent lowercase key normalization.
- Encodes and decodes common HTML entities to preserve readable text while keeping stored values canonical.
- Collapses insignificant whitespace in text nodes to keep rendered output predictable across content styles.

### [selector.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/html/selector.rs)

- Implements selector matching logic that maps CSS-like queries onto the live HTML element tree.
- Parses selector text into tag, id, class, and combinator fragments with deterministic chain ordering.
- Supports descendant and direct-child relationships for ancestry-aware filtering semantics.
- Walks parent links to evaluate multi-part selector chains against runtime element topology.
- Provides the core predicate shared by style cascade resolution and document query operations.

### [style.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/html/style.rs)

- Parses stylesheet sources into ordered selector rules and normalized declaration maps for HTML layout.
- Validates supported properties while collecting non-fatal warnings for unknown or malformed inputs.
- Normalizes declaration keys and values so later cascade merges operate on stable property naming.
- Resolves pixel, percent, and unitless length text into float values against caller-provided bases.
- Supplies compact parse outputs consumed by document rebuild, style recompute, and layout phases.
