# IDEA.md — `input` module

> Migrated from `ideas/features/input.md`.
> Status checked against `src/input/` and `src/lua_api/input_api.rs`.
> Lua namespaces: `lurek.keyboard`, `lurek.mouse`, `lurek.gamepad`, `lurek.touch`.

---

## Features

### ✅ DONE — Custom Cursor
**Source**: features/input.md — Suggestions #4

`setCursor(image, hotX, hotY)` implemented in `input_api.rs` (line ~285). Sets cursor from
ImageData or system cursor name.

---

### ✅ DONE — Input Action Mapping (HIGH PRIORITY)
**Source**: features/input.md — Feature Gaps #1 / Suggestions #1

No `lurek.input.bind("jump", {"space", "gamepad:a"})` or `isActionDown("jump")` found.
This is the #1 missing input feature — every game re-implements key rebinding from scratch.

Suggested API:
```lua
lurek.input.bind("jump", {"space", "gamepad:a"})
lurek.input.isActionDown("jump")   -- true if any bound source is held
lurek.input.wasActionPressed("jump")
```

Consider implementing as a new `input_map` module or as a namespace within `lurek.input`.

---

### ✅ DONE — Input Buffering (Frame Tolerance)
**Source**: features/input.md — Feature Gaps #8 / Suggestions #5

No `wasActionPressedWithin("jump", frames)` found. Frame-tolerance input is essential for
responsive platformer controls (coyote time, jump queueing).

---

### ✅ DONE — Input Recording / Playback
**Source**: features/input.md — Feature Gaps #3 / Suggestions #2
**Implemented**: 2026-04-16

`src/input/recorder.rs` — `InputRecorder`, `InputRecording`, `RecordedFrame`, `InputEvent`.

Lua API in `src/lua_api/input_api.rs`:
- `lurek.input.startRecording()` — start capture
- `lurek.input.stopRecording()` → `InputRecording` userdata (or nil)
- `lurek.input.loadRecording(json)` — load a JSON recording for playback
- `lurek.input.startPlayback()` / `stopPlayback()`
- `lurek.input.isRecording()` / `isPlayingBack()` → boolean
- `lurek.input.getPlaybackFrame()` → integer
- `lurek.input.advancePlayback()` → array of `{kind, name}` event tables
- `InputRecording:toJson()` / `totalFrames()` / `frameCount()`

Recordings are sparse (only frames with events are stored) and JSON-serializable.
The automation module (`lurek.simulator`) handles scripted injection; this module records
raw input state for deterministic replay and testing.

Tests: `tests/lua/unit/test_input_recording.lua` — 11 BDD cases.

---

### ✅ DONE — Gamepad Vibration (Haptics)
**Source**: features/input.md — Feature Gaps #6 / Suggestions #3

`lurek.gamepad.vibrate(id, low_freq, high_freq, duration_ms)` added to `src/lua_api/input_api.rs`.
Parameters are clamped: `low_freq` and `high_freq` to `[0, 1]`; `duration_ms` to `[0, ∞)`.
Returns `false` (hardware vibration not available in winit 0.30; stub ready for future winit
haptics support).  `lurek.gamepad.isVibrationSupported(id)` documents the limitation.
Tests: `tests/lua/unit/test_input_vibrate.lua`.

---

### ✅ DONE — Combo / Sequence Detection
**Source**: features/input.md — Feature Gaps #2

✅ DONE (2026-04-16) — New `src/input/combo.rs` with `ComboDetector`, `ComboStep`, and
`ComboProgress`. Exposed via `lurek.input.newCombo(steps, opts?)` in `src/lua_api/input_api.rs`
as `LuaCombo` UserData. Supports per-step gap timeouts, total-combo budget, and methods
`:feed(key)`, `:tick(dt)`, `:reset()`, `:progress()`, `:totalSteps()`, `:isInProgress()`,
`:getStep(index)`.

---

### ✅ DONE — Unified `lurek.input` Facade
**Source**: features/input.md — Structural Issues

Four separate namespaces (`keyboard`, `mouse`, `gamepad`, `touch`) are clear but verbose.
Consider also exposing `lurek.input` as a unified query interface — device-agnostic for
action mapping. This is additive, not a breaking change.
