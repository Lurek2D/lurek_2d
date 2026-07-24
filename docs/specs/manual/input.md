# input manual spec overlay

## TL;DR

- Unifies keyboard, mouse, gamepad slotting, and touch events into stable inputs.
- Supports custom action bindings, chord expressions, timed combo history, and JSON input replay.

## Summary

- The `input` module is the engine's unified control surface for users who need keyboard, mouse, gamepad, and touch state to behave as one coherent runtime system.
- Its main job is normalization. Device-specific events become stable engine-side state so scripts can ask about buttons, axes, touches, combos, and actions through one consistent vocabulary.
- Per-frame snapshots matter because gameplay, UI, replays, and tools all need deterministic control state rather than raw transient platform events.
- Action mapping, rebinding, presets, and conflict handling are central because real projects care about intent and user-configurable schemes more than about hardwired physical keys.
- Mouse, pointer, touch, and compound input remain part of the same model, which keeps interaction semantics consistent across device families and helps accessibility layers share the same action surface.
- Recording and playback make the module useful for debugging, tests, automation, tutorials, and deterministic repro workflows as well as for live play.
- Replay payloads also carry schema and provenance metadata so tools can reason about compatibility, timing assumptions, and keyboard-layout risk before treating a recording as deterministic.
- That normalization layer protects higher-level systems from platform detail churn. Gameplay and UI code can ask for stable actions instead of reinventing per-device handling every time a new device family or interaction surface appears.
- Rebinding is especially important because modern projects often need several physical inputs to express the same logical action under explicit precedence, accessibility, or user-preference rules.
- Action bindings can target named Xbox controls, an assigned player, or any connected controller while preserving legacy numeric slot bindings.
- Keyboard and mouse expose held and edge-triggered polling. Physical key mapping includes punctuation, F13–F24, international, browser, and media keys; mouse input retains raw movement, buttons beyond the standard five, and a trailing click-count callback argument.
- Combo handles consume the normalized history automatically and support press, release, directional, neutral, chord, and charge/hold steps; the original `feed()` / `tick()` mode remains available.
- Input capture and replay also make the module one of the cleanest sources of truth for what happened during a failing run, a scripted demonstration, or a tool-driven automation pass.
- The result is a surface that serves players, tools, and tests at the same time: it turns noisy device events into deterministic, serializable, reusable intent.
- Other systems consume the result, but `input` owns normalization, mapping, serialization, and replay semantics for device-originated intent.

This module primarily collaborates with `filesystem`, `runtime`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

## Notes

- Action bindings are canonicalized at the API boundary. The JSON payload is `schema_version = 2`, while the previous bare-map payload remains readable. Bindings may be simple controls, `{ all = {...}, within_ms = N }` chords, or named gamepad axis thresholds.
- Action definitions have a context (default `gameplay`). `setContextEnabled` disables polling for one context without removing its bindings.
- The bounded normalized history stores up to 4,096 events and two seconds of keyboard, mouse, gamepad, touch, motion, wheel, text, and connection transitions. It is the shared source for action timing, combos, and recording.
- Mouse buttons above the standard five are stable one-based numbers (`MouseButton::Other(n)` becomes `n + 6`); raw motion is available through `mouse.getDelta()` even while the cursor is locked.
- Xbox/XInput buttons and axes can be addressed with standard names such as `gamepad:any:a`, `gamepad:p1:dpad_up`, and `righttrigger`. SDL mapping entries are applied during XInput normalization (`bN` and `aN` tokens); player slots survive a disconnect so a reconnect can resume the same assignment.
- Rumble requests are centralized per gamepad: a new request replaces the previous effect, a zero duration stops it, and elapsed effects are stopped on the polling path rather than through one thread per request.
- Custom cursor creation validates image dimensions, RGBA byte length, and hotspot bounds before the request becomes a runtime cursor handle.
- Gamepad mapping import and export use sandboxed `GameFS` path resolution instead of arbitrary host filesystem paths, and mapping lines must pass GUID and token validation before they are stored.
- Losing window focus clears held keyboard keys and modifier state so stale `ctrl`, `alt`, `shift`, `meta`, and `altgr` flags do not leak across blur events.
- Replay records normalized event kind, device, optional analog value, pointer data, and monotonic capture timestamps in addition to sparse mouse coordinates. Playback accepts `frame`, `fixed`, and `realtime` scheduling; all recorded device state is reinjected through the same normalized history path. Recording JSON loading enforces byte, frame-count, event-count, and metadata-length limits before accepting untrusted payloads.
- Hardware gamepad polling is intentionally Windows/XInput-only in this release; other platforms expose no live hardware gamepads without adding a backend dependency.

## Architecture Links

- Intentionally empty.
