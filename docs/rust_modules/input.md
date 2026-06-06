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

This module provides a unified control-state and input-processing subsystem, bridging raw host hardware events into clean gameplay inputs. It monitors physical inputs across keyboards, mice, gamepads, and multi-touch panels. By translating hardware-specific codes and controller layouts into stable logical naming conventions, the system exposes a consistent, cross-platform interface for all polling and event dispatch pathways.

At the device level, the keyboard system tracks held keys, layout transitions, modifier bitmasks, and repeat parameters, alongside text buffering for chat and UI fields. The mouse system tracks screen coordinates, wheel scroll deltas, and cursor settings, supporting pointer locking, warp requests, and custom hotspots. The gamepad manager handles device connection slotting, axis calibration, virtual d-pad mapping, and motor vibration commands.

To support advanced gameplay actions, the system includes a serialized action-binding mapping model. Developers can bind complex logical commands to multiple physical keys or buttons, compiling configurations into shared JSON presets that support user rebinding. The action engine monitors transition events per frame, offering convenient checks for whether bindings were recently triggered, held down, or released.

Specialized input handlers manage gesture detection and automation workflows. A sequential combo recognizer detects timed pattern gestures, evaluating transition deadlines and feeding progress states to gameplay scripts. Additionally, an input recorder captures sparse, frame-indexed events during gameplay. These sequences can be serialized to JSON, replayed deterministically, and seeked, supporting game automation and debug workflows.

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
