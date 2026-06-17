//! High-level HTML module surface that composes parsing, styling, selection, and document orchestration. `html/mod` is the html module index, declaring `color`, `document`, `element`, `parser`, `selector`, and 1 more so agents can identify which files own each feature slice before opening implementation code.
//! Re-exports stable document and element types used by runtime code interacting with HTML-driven UI. `src/html/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `color::parse_css_color_rgba`, `document::{HtmlDocument, HtmlDocumentOptions, HtmlDrawCommand}`, `element::{HtmlElement, HtmlElementId, HtmlRect}` centralized for the html subsystem.

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
