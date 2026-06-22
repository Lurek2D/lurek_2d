# input manual spec overlay

## TL;DR

- Unifies keyboard, mouse, gamepad slotting, and touch events into stable inputs.
- Supports custom action-bindings, gesture combo timing, and JSON input replays.

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
- Input capture and replay also make the module one of the cleanest sources of truth for what happened during a failing run, a scripted demonstration, or a tool-driven automation pass.
- The result is a surface that serves players, tools, and tests at the same time: it turns noisy device events into deterministic, serializable, reusable intent.
- Other systems consume the result, but `input` owns normalization, mapping, serialization, and replay semantics for device-originated intent.

This module primarily collaborates with `filesystem`, `runtime`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

## Notes

- Action bindings are canonicalized at the API boundary. Alias key names collapse to one stored spelling, malformed structured bindings are rejected, and reserved binding families stay unavailable to action queries until the engine supports them end to end.
- Custom cursor creation validates image dimensions, RGBA byte length, and hotspot bounds before the request becomes a runtime cursor handle.
- Gamepad mapping import and export use sandboxed `GameFS` path resolution instead of arbitrary host filesystem paths, and mapping lines must pass GUID and token validation before they are stored.
- Losing window focus clears held keyboard keys and modifier state so stale `ctrl`, `alt`, `shift`, `meta`, and `altgr` flags do not leak across blur events.
- Replay playback preserves sparse mouse coordinates, and recording JSON loading enforces byte, frame-count, event-count, and metadata-length limits before accepting untrusted payloads.

## Architecture Links

- Intentionally empty.
