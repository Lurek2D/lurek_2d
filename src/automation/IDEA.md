# IDEA.md — `automation` module

> Migrated from `ideas/features/automation.md`.
> Status checked against `src/automation/` and `src/lua_api/automation_api.rs`.
> Note: the Lua namespace is `lurek.simulator` (not `lurek.automation`).

---

## Features

### ✅ DONE — Named Macros (Reusable Input Scripts)
**Source**: features/automation.md — Feature Gaps #3 / Suggestions #1

`saveMacro(name, script)`, `playMacro(name)`, `hasMacro(name)`, and `listMacros()` added
to `simulator.rs` and `automation_api.rs`. Named macros are stored in `Simulator.macros`
and can be re-used across frames without re-loading the step table.

```lua
lurek.simulator.saveMacro("combo", script)
lurek.simulator.playMacro("combo")
```

---

### ✅ DONE — Wait-for-Condition
**Source**: features/automation.md — Feature Gaps #2 / Suggestions #2

`waitUntil(predicate, timeout)` added to `automation_api.rs`. Automation queue advances only
when the predicate returns true (or the timeout elapses), allowing scripts like "wait until
entity reaches position Y, then press space" without brittle frame-count guesswork.

---

### ❌ TODO — Screenshot Comparison / Visual Assertions
**Source**: features/automation.md — Feature Gaps #1 / Suggestions #3

No integration with `saveScreenshot()` or the `image` module for pixel-level assertions.
Needed for visual regression testing pipelines.

---

### ✅ DONE — Variable Speed Playback
**Source**: features/automation.md — Feature Gaps #4 / Suggestions #4

`setPlaybackSpeed(factor)` and `getPlaybackSpeed()` added to `automation_api.rs`. The simulator
scales the `dt` accumulator by `playback_speed`, so the entire replay runs at the requested
rate. `0.5` = half-speed slow motion; `2.0` = double-speed fast forward.

---

### ✅ DONE — Input Highlight Mode
**Source**: features/automation.md — Suggestions #5

`Simulator` now carries `highlight_mode: bool` (default `false`) with methods
`set_highlight_mode(enable: bool)` and `is_highlight_mode() -> bool`.
Lua API: `lurek.simulator.setHighlightMode(enable)` and `lurek.simulator.isHighlightMode()`.
The engine does not draw the overlay itself; the flag is a hint for the game script's
render pass to draw a cursor/key indicator overlay during replay.
Tests: `tests/lua/unit/test_automation_highlight.lua`.
