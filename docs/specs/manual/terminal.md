# terminal manual spec overlay

## TL;DR

- Grid terminal supporting ANSI formats, syntax highlighting, and cycling tab-completions.
- Cell widgets with input focus, scrollback history, and pixel-perfect rendering.

## Summary

- The `terminal` module is the engine's character-grid interface surface for users who want text-mode displays, debug consoles, command panels, or roguelike-style presentation.
- It treats terminal behavior as an actual interface model rather than as plain text drawing: cells, ANSI parsing, completion, highlighting, editing state, prompt handling, and render helpers cooperate under one system.
- That matters because terminal-like surfaces need cursor movement, history, navigation, scrollback, and structured command input, not only glyph output.
- The grid model gives the module a clear role distinct from ordinary widget UI and makes it suitable for dense dashboards, shells, ASCII-heavy views, and trace-oriented tooling.
- Completion, highlighting, prompt handling, and command history make the feature practical for live developer tools as well as for player-facing interfaces that rely on typed interaction.
- The same surface also gives projects a natural place for aligned textual diagnostics, command-driven introspection, and replayable console workflows without building a separate debug UI for every task.
- Cursor-aware editing and scrollback behavior are part of that value too, because terminal surfaces usually need to behave like interactive text tools rather than passive output panes.
- ANSI parsing and style-aware cells broaden the feature from a retro display into a practical runtime console that can show logs, structured status, highlighted feedback, or shell-like results without abandoning the grid model.
- The module is therefore useful for debug consoles, roguelike views, dashboards, and embedded command panels.
- That makes it especially strong when text itself is the interface instead of only the output format.
- Systems can feed or consume text, but `terminal` owns how that interaction becomes an editable, navigable, scrollable, character-grid runtime surface.

This module primarily collaborates with `image`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Notes

- Grid coordinates exposed to Lua stay 1-based. `get` remains permissive for convenience, while `tryGet`/`trySet`-style strict helpers are the path for tooling and assertions that must distinguish out-of-bounds access from an empty cell.
- Terminal text is bounded. Grid-print payloads, scrollback lines, command-history entries, clipboard contents, widget text, list items, and border titles are truncated or rejected according to `TerminalLimits`.
- Clipboard policy is internal-only by default. Ctrl+C/X/V operate on the terminal-owned clipboard buffer, which is length-limited and participates in diagnostics.
- Text-box paste is partial by design. When a widget `maxLength` leaves only partial capacity, paste inserts the longest prefix that fits instead of rejecting the whole operation.
- Widget focus traversal is keyboard-defined. Tab and Shift+Tab skip hidden or disabled widgets, and stale/hidden/disabled focus targets are cleared predictably.
- Panel ownership is validated. A child widget may not belong to multiple panels, stale child references are invalid, and cycles are rejected before traversal.
- Cell colors must be finite and are clamped to `0..1`. Invalid codepoints are rejected by strict setters and sanitized to a safe fallback by permissive setters.
- Render helpers record composition stats including visible list rows, skipped rows, drawn widgets, and clipped characters so large-list behavior is observable instead of implicit.

## Architecture Links

- Intentionally empty.
