---
inclusion: manual
---

# html-css

## Mission
Own `lurek.html` authoring patterns for HTML, CSS, and Lua-driven UI flow.

## When To Use
- Build an HTML screen, HUD, menu, dialog, or scoreboard.
- Review CSS layout or UI document flow.
- Connect Lua callbacks to HTML UI behavior.

## When To Skip
- `src/ui/` Rust internals, TOML layout files, pure game logic.

## Rules

### Pipeline
`src/html/parser.rs` tokenises HTML → `src/html/element.rs` builds DOM arena → `src/html/style.rs` parses CSS and resolves computed styles → `src/html/selector.rs` matches selectors → `src/html/document.rs` returns an `HtmlDocument` with layout rects. Every step is pure Rust; there is no browser engine.

### Supported CSS Subset
Type selectors, class selectors (`.foo`), id selectors (`#foo`), descendant (` `) and child (`>`) combinators, `color`, `font-size`, `padding`, `text-align`, `background-color`, `width`, `height`, `display: none`. Flexbox via `lurek.html.supports("css-flex")` — check this before using flex layout.

### Wiring a Lua Callback
After `lurek.html.newDocument(html, options)`, use `doc:on("click", "#button_id", function(evt) ... end)`. The `evt` table has `id`, `tag`, and `value` fields. Callbacks fire synchronously before the next `lurek.draw()`. Never do heavy computation in a callback.

### Updating DOM from Lua
- `doc:setAttr("#score", "text", tostring(score))` to change text content.
- `doc:setClass("#panel", "hidden", true)` to toggle visibility.
- Do not rebuild the whole document each frame — that triggers a full re-parse and layout cycle.

### Performance Rule
Relayout triggers when DOM structure, element count, or sizing CSS changes. Text-only changes and class toggles affecting only color or `display:none` are cheaper. For complex screens, split: static chrome in one document, dynamic counters in a second.

### Content Separation
HTML and CSS own structure and visual rules. Lua owns state transitions, data flow, and timing. Never compute game state inside a CSS expression or inline HTML attribute.

### Unsupported Tags
Check `src/html/parser.rs` before using uncommon tags. Unsupported tags are silently skipped — they do not error but do not render either, which is a silent bug.

## References
- `docs/specs/html.md`
- `docs/specs/ui.md`
- `src/html/`
- `src/lua_api/html_api.rs`
- `content/games/showcase/`
