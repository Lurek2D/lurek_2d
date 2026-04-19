# IDEA — `src/window/`

> **This file is forward-looking.** It records ideas, not commitments. Nothing here is
> implemented in the same session that produces it. Implementation is gated by a separate
> roadmap decision.

---

## 1. Header

- **Module**: `window`
- **Owner module path**: `src/window/`
- **Last reviewed**: 2026-04-18 (UTC)
- **Reviewer agent**: `developer` · Session: `src-module-review-20260418`
- **Plugin tier candidacy**: `CORE-KEEP`
- **LOC (rust only)**: ~500 · **Public Lua surface**: `lurek.window` — ~39 fns / 0 userdata
- **Inbound non-`lua_api` callers**: `app` (event loop integration), `render` (surface setup)
- **Heavy dependencies**: `winit` (via `app` — not direct dep of this module)

## 2. Mission Summary

Manages window lifecycle, display mode, coordinate viewport scaling, and DPI awareness.
Serves EngDev (platform integration), GameDev (window configuration from Lua), and Player
(fullscreen/windowed/resolution). Deliberately NOT the event loop owner (`app` owns the
winit event loop); this module provides stateless helper functions on `WindowState`.

## 3. Existing Strengths

- Pure-function architecture — `management.rs` operates on `WindowState` with zero side effects; easy to test.
- Viewport coordinate transform (`to_pixels`, `from_pixels`) properly handles offset + scale.
- Scale mode validation accepts only `none | letterbox | stretch | pixel` — rejects invalid input.
- Good doc coverage across all public functions with `///` and file-level `//!`.
- DPI-aware positioning with `set_position` supporting both physical and logical coordinates.

## 4. Gap List

1. **[P2][GAP]** `Multi-monitor awareness` — no API to enumerate displays or move window between monitors.
   - Why: players with multi-monitor setups expect monitor selection in fullscreen.
2. **[P2][GAP]** `API sub-table reorganization` — 39+ functions in flat `lurek.window` namespace.
   - Why: discoverability suffers; grouping (`display.*`, `cursor.*`) would help GameDev.
3. **[P3][GAP]** `Event loop placeholder` — `event_loop.rs` is empty; no winit event dispatch integration.
   - Why: currently all event handling lives in `app`; dedicated module could improve separation.

## 5. Feature Ideas

1. **[P2][FEAT]** `lurek.window.getDisplays()` — Enumerate connected displays with resolution and position.
   - Rationale: multi-monitor fullscreen and monitor selection.
   - Effort: M · Risk: low (winit provides `available_monitors()`).
   - Competitor inspiration: [LOVE2D: love.window.getDisplayCount — love2d.org/wiki/love.window.getDisplayCount].
2. **[P2][FEAT]** `Sub-table API split` — Group into `lurek.window.display`, `lurek.window.cursor`, `lurek.window.mode`.
   - Rationale: 39+ flat functions is hard to discover for GameDev.
   - Effort: M · Risk: high (breaking change — requires API version bump).
3. **[P3][FEAT]** `lurek.window.flash()` — Taskbar flash / attention request.
   - Rationale: common in multiplayer turn notifications.
   - Effort: S · Risk: low.
   - Competitor inspiration: [SDL2: SDL_FlashWindow — wiki.libsdl.org/SDL2/SDL_FlashWindow].

## 6. Performance / Reliability / Quality Ideas

- **[P3][QUAL]** `event_loop.rs cleanup` — file is an empty 10-line placeholder; either populate or remove.
  - File: `event_loop.rs`.
  - Reason: empty files confuse discovery and inflate file counts.
- **[P3][QUAL]** `WindowState field sprawl` — WindowState (in `runtime/shared_state`) has 30+ fields mixing display, mode, cursor, clipboard, and viewport concerns.
  - File: `runtime/shared_state.rs`.
  - Reason: consider grouping into sub-structs (DisplayConfig, CursorState, ViewportConfig).

## 7. Test Coverage Gaps

- ✅ `viewport::to_pixels` / `from_pixels` round-trip — covered in `viewport.rs` tests.
- ✅ `management::set_title`, `set_fullscreen`, `set_vsync` state changes — covered in `management.rs` tests.
- ✅ `viewport::set_scale_mode_validated` acceptance/rejection — covered in `viewport.rs` tests.
- **[P2][TEST-LUA]** Add Lua BDD test for `lurek.window.getWidth()`, `lurek.window.setTitle()` under `tests/lua/window/`.
- **[P2][TEST-RUST]** `show_message_box` is untested (requires GUI interaction via rfd).

## 8. TODO(dedup): Cross-Module Overlap

```text
TODO(dedup): render::surface_setup — render module re-reads WindowState.game_width/height; could take ViewportInfo instead
TODO(dedup): camera::Camera — camera viewport transform overlaps with window viewport coordinate mapping
```

## 9. TODO(helper): Engine-Level Helper Candidates

```text
TODO(helper): window_config_helper — conf.lua window settings pattern (width/height/title/fullscreen) repeated across all game scripts — citation: content/examples/window.lua:1
```

## 10. TODO(plugin): Plugin Candidacy Proposal

```text
TODO(plugin): CORE-KEEP — window management is fundamental to every game; no game runs without a window.
```

- **Extraction blockers**: `app` event loop directly calls management functions; `render` needs surface dimensions.
- **Heavy dep impact if extracted**: none (winit is owned by `app`, not `window`).
- **Lua surface stability**: stable.
- **Migration step**: n/a (CORE-KEEP).

## 11. References

- Module spec: [docs/specs/window.md](../../../docs/specs/window.md)
- Lua API reference: [docs/API/lua-api.md#window](../../../docs/API/lua-api.md)
- Philosophy constraints touched: `A-02` (desktop only), `B-03` (60 FPS target — vsync related)
- Plugin doc tier table: [plugins.md §5](../../../docs/architecture/plugins.md#5-candidate-modules)
- Authoring guide: [IDEA_AUTHORING.md](../../work/src-module-review-20260418/reports/IDEA_AUTHORING.md)
