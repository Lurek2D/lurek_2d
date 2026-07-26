# audio manual spec overlay

## TL;DR

- Plays static and streaming sound via voice pools and mixing buses.
- Controls priority ducking, spatial panning, and Doppler shifts.
- Provides beat clocks for rhythmic scheduling and timing checks.
- Applies lowpass/highpass filters and manages source-level playback state.
- `lurek.audio.manager.playMusic` now creates a looping streamed source, routes it through a named group, and applies optional fade-in and volume; `setGroupVolume` controls that group explicitly.

## Summary

- The `audio` module is the engine's main runtime sound system for users who need playback, routing, source state, timing, and mix control to live under one API.
- It covers the full everyday audio workflow: loading or decoding sound assets, creating reusable sound data, instantiating live voices, tracking listener state, and managing mixer-facing behavior without splitting those jobs across unrelated helpers.
- Named buses are one of the core abstractions because projects usually want music, effects, voice, ambience, and UI to be grouped, muted, paused, ducked, or rebalanced as categories instead of as isolated sounds.
- Source lifecycle and inspectable runtime state make the module practical for reactive gameplay cues, debugging, and longer sequences where scripts need to know what is playing, stopped, fading, pooled, or otherwise active.
- Sound pools give repeated effects such as footsteps, shots, and impacts a structured reuse path, while beat-clock support lets rhythm-aware gameplay or presentation synchronize against shared musical timing.
- The same subsystem therefore serves both simple one-shot playback and more deliberate mix orchestration, which is important for projects that start small and later grow into layered, routing-heavy sound design.
- Mixer control keeps overall gain policy and category coordination in one place, and deterministic timing helpers make live audio behavior easier to reason about during testing or tuning.
- Those timing and routing semantics are especially valuable when several playback categories must coexist coherently.
- They are also what keep music changes, ambience, voice, and reactive effects readable as parts of one shared mix.
- Asset-facing loading is also a major part of the value. Imported files become runtime-ready sound objects through engine-owned decoding and preparation rules instead of requiring every caller to reinvent codec handling, caching, or source setup.
- That content workflow matters because audio systems often fail not at playback itself but at all the surrounding decisions: how assets are reused, how transient voices are pooled, how categories stay legible, and how stateful transitions are coordinated over longer sessions.
- The module therefore gives projects a stable answer to both "play this now" and "manage the whole current mix." Those are different needs, but they have to coexist if a game wants reactive effects, adaptive music, voiced UI, and ambient layers to remain understandable together.
- Buses and mixer policy are the main reason the subsystem scales. A small prototype may only play a few sounds, but a larger project needs volume hierarchy, pause semantics, ducking rules, mute groups, and category-level tuning that remain visible rather than being buried in ad hoc script conventions.
- Listener-facing state broadens the feature from raw playback into world-aware audio behavior. Even when neighboring modules provide the scene, `audio` owns how sources and listener context become heard spatial or positional results.
- Multi-listener spatialization extends that same listener state without adding another system: up to 64 atomically validated listeners feed `nearest`, `weighted`, or source-mask-driven `manual` policy, while each source still owns exactly one sink and authored volume/pan remain separate from computed spatial gain/pan.
- Listener masks only filter calculation candidates. They never copy sources or trigger playback, and `getSourceSpatialResult` exposes the deterministic calculation for Lua-side inspection.
- This is why the module stays useful across both live gameplay and tool-driven verification: it keeps playback, routing, timing, and category policy visible enough to inspect instead of hiding sound behavior behind fire-and-forget calls.
- It keeps mix policy legible as projects scale.
- `dsp` specializes lower-level signal processing, but `audio` owns the user-facing contract for how sounds are loaded, instantiated, routed, timed, and heard at runtime.

This module primarily collaborates with `dsp`, `image`, `runtime`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

## Notes

- Legacy `setListener`, `setListener2D`, `getListener`, and `getListener2D` remain compatible. A legacy setter installs the single `default` listener with nearest policy; legacy getters read the first configured listener or zeroes when the list is empty.
- Audio does not pull camera, player, ECS, or world state automatically. Lua explicitly supplies listener sets and source masks.

## Architecture Links

- Intentionally empty.
