//! `src/html/mod.rs` is the module index for HTML colors, DOM elements, parsing, selectors, styles, and documents.
//! It declares the files that own DOM storage, CSS parsing, selector matching, color parsing, and document orchestration.
//! This file reexports the main HTML types so callers can use document and element services without deep internal paths.
//! No DOM nodes, computed styles, or viewport state live here; it only defines visibility and subsystem boundaries.
//! Read this index first when tracing HTML behavior, because it shows where parsing, storage, and interaction split.
//! Changes here affect reachability and API shape, not selector semantics, layout rules, or text parsing behavior.

/// CSS color parsing helpers for HTML style handling.
pub mod color;
/// HTML document tree, viewport state, and draw-command generation.
pub mod document;
/// HTML element storage, attributes, and geometry.
pub mod element;
/// Tag parsing and HTML entity escaping.
pub mod parser;
/// Selector parsing and element matching.
pub mod selector;
/// CSS rule parsing and property normalization.
pub mod style;
/// Parse a CSS color string into normalized RGBA values.
pub use color::parse_css_color_rgba;
/// HTML document types and draw command output.
pub use document::{HtmlDocument, HtmlDocumentOptions, HtmlDrawCommand};
/// HTML element types and rectangles.
pub use element::{HtmlElement, HtmlElementId, HtmlRect};
