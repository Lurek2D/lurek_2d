//! Defines lightweight accessibility snapshots and UX diagnostics for the retained UI system.
//! Keeps report payload types separate from the live context owner so diagnostics APIs stay readable.
//! Provides stable data shapes used by Lua bindings, tests, and tooling that inspect UI semantics.
//! Acts as the type boundary for validation output without owning tree traversal or interaction logic.
//! Open this file when accessibility dumps or diagnostics payloads need to grow without bloating `context.rs`.

/// A flattened accessibility snapshot entry describing one live widget.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct UiAccessibilityNode {
    /// Widget index in `GuiContext::widgets`.
    pub widget_idx: usize,
    /// Canonical widget type name such as `"button"` or `"textinput"`.
    pub widget_type: String,
    /// Semantic role used for accessibility and diagnostics.
    pub role: String,
    /// Accessible name after applying text and label fallback rules.
    pub name: String,
    /// Extended accessible description text.
    pub description: String,
    /// Optional widget index this node labels.
    pub label_for: Option<usize>,
    /// Whether this widget participates in keyboard focus traversal.
    pub focusable: bool,
    /// Whether the widget is currently visible in effective tree state.
    pub visible: bool,
    /// Whether the widget is enabled for interaction.
    pub enabled: bool,
}

/// A lightweight UX or accessibility warning associated with the live UI tree.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct UiDiagnostic {
    /// Optional widget index associated with this diagnostic.
    pub widget_idx: Option<usize>,
    /// Human-readable warning or error text.
    pub message: String,
}

impl UiDiagnostic {
    pub(crate) fn new(widget_idx: Option<usize>, message: impl Into<String>) -> Self {
        Self {
            widget_idx,
            message: message.into(),
        }
    }
}
