---
name: ui-html
description: "Load this skill when building lurek.html screens, HUDs, menus, dialogs, or scoreboards with HTML and CSS. Skip it for src/ui/ Rust internals, TOML layouts, or pure game logic."
---
# ui-html

## Use when
- Build an HTML screen.
- Add HUD, menu, dialog, or scoreboard markup.
- Review CSS layout or UI document flow.
- Connect Lua callbacks to HTML UI behavior.

## Avoid when
- src/ui/ Rust internals.
- TOML layout files.
- Pure game logic.

## Repo rules
- Full pipeline: `src/html/parser.rs` tokenises the HTML string â†’ `src/html/element.rs` builds the DOM arena â†’ `src/html/style.rs` parses CSS and resolves computed styles â†’ `src/html/selector.rs` matches selectors â†’ `src/html/document.rs` returns an `HtmlDocument` with layout rects. The `HtmlDocument` is then handed to `GpuRenderer` as a draw source.
- Supported CSS subset: type selectors, class selectors, id selectors, descendant and child combinators, `color`, `font-size`, `padding`, `text-align`, `background-color`, `width`, `height`, `display: none`. Flexbox is available as an opt-in via `lurek.html.supports("css-flex")` â€” check this before using flex layout so the code degrades gracefully in CI environments.
- How to wire a Lua callback: after calling `lurek.html.newDocument(html, options)`, use `doc:on("click", "#button_id", function(evt) ... end)`.
- How to update DOM state from Lua: call `doc:setAttr("#score", "text", tostring(score))` to change text content, or `doc:setClass("#panel", "hidden", true)` to toggle visibility. Do not rebuild the whole document each frame â€” that triggers a full re-parse and layout cycle, which is expensive.
- Performance rule: relayout triggers when DOM structure, element count, or CSS that affects sizing changes. Text-only changes and class toggles that affect only color or display:none are cheaper.
- The supported HTML tags are those `src/html/parser.rs` explicitly handles. Before using an uncommon tag or attribute, check the parser source.
- Content separation rule: HTML and CSS own structure and visual rules. Lua owns state transitions, data flow, and timing.

## Checks
- `Run the narrowest relevant validation for the touched files or workflow.`

## References
- `docs/specs/html.md`
- `docs/specs/ui.md`
- `src/html/`
- `src/lua_api/html_api.rs`
- `content/games/showcase/`

