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

This module provides the HTML/CSS user interface subsystem, letting developers build interactive menus and HUDs. It parses markup and CSS stylesheets into dynamic DOM trees. The layout engine computes bounds using a box model, resolving cascades into precise pixel coordinates for rendering.

The document orchestrator manages the UI lifecycle, handling layout passes, styling cascades, and viewport resizes. It converts CSS declarations into normalized color vectors and size scales. Styles are resolved deterministically across elements, allowing developers to manage visuals through stylesheets.

For user interactions, the module handles clicks, keyboard focus, and text inputs. Input events are dispatched down the element tree, triggering hover states or text changes. DOM elements can be mutated at runtime by toggling classes, editing attributes, or replacing inner HTML fragments.

Additionally, selector queries support class, ID, and ancestry matching to locate elements. The completed layout output compiles into draw command streams containing render rectangles and text blocks ready for GPU rendering.

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
