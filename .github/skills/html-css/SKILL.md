---
name: html-css
description: "Load this skill when building UI screens, HUD overlays, inventory grids, dialogs, settings menus, or scoreboards using lurek.html — HTML markup and CSS for layout, Lua callbacks for logic. Skip it for Rust src/ui/ internals, TOML layout files (use ui-layout), pure game logic, or non-HTML widget work."
---
# html-css

## Mission

Own lurek.html screen authoring patterns: document lifecycle, input forwarding, CSS class state machines, event wiring, viewport sync, and feature guards.

## When To Load

- Adding HUD overlays, health bars, menus, dialogs, or scoreboards using HTML/CSS
- Forwarding input events to an HTML document
- Animating element state with CSS classes
- Creating a new HTML-based demo

## When To Skip

- Modifying src/ui/html/*.rs Rust internals -> use rust-coding + lua-rust-bridge
- Authoring content/layouts/*.toml files -> use ui-layout skill
- Pure game logic with no UI -> use lua-scripting

## Domain Knowledge

**Document lifecycle:** (1) create once in lurek.load with lurek.html.newDocument(html?, opts?), (2) call doc:update(dt) every frame in lurek.update, (3) call doc:draw(x?, y?) every frame in lurek.draw, (4) after any bulk setHtml call, invoke doc:relayout() before the next draw.

**newDocument vs loadDocument:** newDocument(html, opts) for inline HTML strings (small templates). loadDocument(path, opts) reads a .html file from the game folder — raises Lua error if missing, always guard with pcall in production.

**Input forwarding:** forward all four input events (mousepressed, mousereleased, keypressed, textinput) to the document and check the consumed boolean to block game hit-tests beneath the UI.

**Event wiring:** el:on("click", fn) returns an opaque handle. Unwire with el:off(handle) in teardown. Document-level doc:on/doc:off follow the same contract.

**CSS class state machine:** prefer toggling CSS classes over inline setStyle for mutually exclusive states. el:toggleClass(cls) for binary toggles (returns new state: true=added). Use queryAll + removeClass + single addClass for radio-group patterns.

**Viewport sync:** always call doc:setViewport(w, h) inside lurek.resize(w, h) so the document re-flows to match the new window size.

**Performance:** avoid rebuilding the full DOM every frame. Prefer el:setText, el:setStyle, or CSS class swaps for per-frame updates. Reserve setHtml + relayout for bulk changes triggered by discrete events (level start, dialog page turn, score update).

**supports() feature guard:** call lurek.html.supports("feature") once at startup. Known truthy values: "html", "css", "selectors", "events", "forms", "pure-rust", "inline-style", "draw-commands", "descendant-selectors", "child-selectors".

## Companion File Index

None — all guidance is inline.

## References

- docs/specs/ui.md — canonical lurek.html API reference
- src/lua_api/ui_api.rs — thin Lua wrapper (LuaHtmlDocument / LuaHtmlElement)
- src/ui/html/ — pure-Rust HTML/CSS engine (domain logic)
- content/examples/ui.lua — API stub blocks for every lurek.html.* function
