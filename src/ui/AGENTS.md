# UI Module Contract

## Mission & Scope
- Own retained widgets, layout, theme lookup, input routing, dialogs, and event queues.
- Keep widget identity stable across frame updates.

## Files
- `context.rs`, `widget.rs`, `layout.rs`: Tree state and layout.
- `dialog.rs`, `theme.rs`, `events.rs`: Interaction surface.

## Rules
- Use stable IDs/handles for mutation; do not index transient render order.
- Keep layout, input routing, and rendering as separate passes.
- Clamp popup, drag, resize, and focus behavior to viewport-safe bounds.

## Workflow
- Validate with `cargo test --test gui_tests`.
