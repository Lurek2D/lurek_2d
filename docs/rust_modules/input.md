# input

## General Info

- Module group: `Platform Services`
- Source path: `src/input/`
- Binding: `src/lua_api/input_api.rs`
- Namespace: `lurek.input`
- Lua API surface: `89` functions, `8` types, `18` methods
- Rust test path(s): tests/rust/unit/input_tests.rs
- Lua test path(s): tests/lua/unit/test_input.lua, tests/lua/integration/test_input_camera.lua

## Summary

Functioning as a translation layer between the winit OS event loop and the game logic, it provides frame-perfect state tracking and querying. The `KeyboardState` system accurately monitors key-down, key-up, just-pressed, and just-released events on a per-frame basis. It maintains a strict separation between physical scan-codes (ideal for layout-agnostic WASD movement) and logical key mappings, while also supporting OS key-repeat events, text-input buffering for typing, and modifier bitmasks.

The `MouseState` system offers comprehensive tracking of cursor coordinates, scroll-wheel deltas, and multi-button states. It allows developers to customize the cursor by selecting from system icons, providing raw RGBA pixel data, or toggling visibility and window-grab confinement (relative mode) for first-person control schemes. Gamepad support is exceptionally robust via the `GamepadState` struct, which tracks up to four connected controllers simultaneously. It manages analog sticks, triggers, button presses, connection lifecycles, and OS force-feedback vibration requests, synthesizing virtual D-pads and providing SDL2 GameControllerDB GUID mapping for maximum compatibility. `TouchState` similarly handles multi-point contact tracking for mobile or touchscreen interfaces, capturing press, move, and release lifecycles.

To support complex game mechanics, the module includes a highly capable `ComboDetector` designed to recognize fighting-game-style multi-step input sequences, complete with configurable per-step and total-sequence timeout windows. Furthermore, the module implements an `InputRecorder` that can capture sparse frame-by-frame event streams into versioned JSON envelopes. These recordings can be loaded and played back deterministically, facilitating automated testing, replay systems, and automated demo loops. All of these features are seamlessly exposed to the scripting engine via the `lurek.input.*` Lua namespace.

## Files

### [action_def.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/input/action_def.rs)

- Defines action-binding data shapes used to map logical actions onto multiple physical inputs.
- Stores ordered binding strings and optional category grouping for tooling and menu presentation.
- Provides serializable action-map structures for loading, saving, and sharing binding presets.

### [combo.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/input/combo.rs)

- Implements sequential combo recognition for multi-step input patterns with timing constraints.
- Tracks progress state across key feeds, validating per-step gaps and whole-sequence deadlines.
- Emits explicit advanced, completed, and broken states to simplify caller-side response logic.
- Resets predictably after failures or completion to support repeated combo attempts.
- Powers gameplay and scripting features that require ordered gesture-style key sequences.

### [events.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/input/events.rs)

- Declares normalized input event names and payload types emitted from the platform event loop.
- Defines keyboard, mouse, wheel, text, and gamepad event variants for unified downstream handling.
- Serves as the shared event contract consumed by runtime queues and Lua-facing dispatch paths.

### [gamepad.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/input/gamepad.rs)

- Manages gamepad device state per slot, including buttons, axes, and connection lifecycle changes.
- Tracks per-frame deltas for press and release transitions so polling remains deterministic.
- Queues rumble requests with normalized motor strengths for runtime delivery to OS backends.
- Parses and stores mapping profiles using GUID-keyed formats compatible with common controller data.
- Bridges backend-specific button and axis identities into stable engine-facing naming.
- Synthesizes virtual directional output from analog sticks with deadzone-aware interpretation.
- Exposes hat and direction queries used by gameplay code and Lua input APIs.

### [keyboard.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/input/keyboard.rs)

- Implements per-frame keyboard state with held keys, transition deltas, and modifier tracking.
- Separates logical key identity from physical scancode paths for layout-aware and layout-agnostic input.
- Updates modifier bitmasks on each event to keep control-state queries cheap and consistent.
- Maintains optional key-repeat and text-input buffering for UI fields and chat-like interactions.
- Performs translation from backend key enums into stable engine key naming conventions.
- Clears transient deltas at frame boundaries while preserving held-state continuity.
- Supports binding workflows that combine textual key names with physical scan-code fallback semantics.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/input/mod.rs)

- High-level input module that groups keyboard, mouse, gamepad, touch, and recording components.
- Re-exports action and state types so caller code can consume one coherent input surface.
- Defines the composition boundary where platform events become gameplay-usable input state.

### [mouse.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/input/mouse.rs)

- Tracks mouse position, button transitions, and scroll deltas with frame-local reset semantics.
- Stores held, pressed, and released button sets for deterministic polling across gameplay systems.
- Supports system cursor variants and custom cursor image metadata with hotspot offsets.
- Exposes cursor visibility, grab, relative mode, and warp requests for runtime window integration.
- Preserves smooth pointer-control behavior while separating transient and persistent state.
- Serves as the central mouse state source for UI interaction and gameplay input checks.

### [recorder.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/input/recorder.rs)

- Records and replays input timelines as frame-indexed event sequences for automation and debugging.
- Captures sparse frame data so silent periods do not inflate stored replay size.
- Serializes recordings through versioned JSON envelopes for stable persistence and interchange.
- Tracks recorder lifecycle state for live capture, loading, seeking, and playback progression.
- Supports deterministic test scenarios by emitting recorded events on their original frame numbers.
- Unifies recording and playback behavior in one stateful component used by runtime and tools.

### [touch.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/input/touch.rs)

- Tracks multi-touch contacts with active-point state and per-frame transition sets.
- Stores per-contact position and pressure values keyed by stable touch identifiers.
- Clears transient pressed and released markers at frame boundaries while preserving active points.
- Provides touch lifecycle mutation paths for start, move, and end events from the platform layer.
