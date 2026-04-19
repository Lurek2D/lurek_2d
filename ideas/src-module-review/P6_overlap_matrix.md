# P6 — Overlap Matrix (TODO(dedup) Synthesis)

> Generated: 2026-04-18 | Session: src-module-review-20260418

## Summary

113 TODO(dedup) entries found across ~30 modules. The matrix below groups them by overlap pair, sorted by frequency (most cross-referenced pairs first).

## High-Priority Overlap Pairs (referenced by 3+ modules)

| # | Pair | Modules citing | Description | Recommended action |
|---|------|----------------|-------------|--------------------|
| 1 | **tween ↔ animation** | tween, animation, math, sprite | AnimCurve vs TweenState both interpolate over time; add_frames_from_grid duplicates grid-slicing | Clarify boundary: tween = numeric property animation, animation = frame indices. Share easing resolution. |
| 2 | **effect ↔ camera (shake)** | camera, effect, light | Screen shake in Camera2D.shake_* and Overlay.shake | Consolidate into camera module as canonical shake source |
| 3 | **serial ↔ data (msgpack)** | serial, data, network | msgpack encoding in serial, data, and network modules | Single canonical msgpack in serial; data + network delegate |
| 4 | **sprite ↔ animation (aseprite)** | sprite, animation | Both parse Aseprite JSON for different output types | Unify parser; atlas for regions, aseprite for frames+tags |
| 5 | **thread ↔ event (FIFO queues)** | thread, event, runtime | Channel (thread-safe) vs EventQueue (single-threaded) | Document as intentional split; consider EventQueue wrapping Channel |
| 6 | **render ↔ tilemap/physics (RenderCommand)** | render, tilemap, physics, parallax | Multiple modules build RenderCommands independently | Extract shared debug-draw/tile-draw trait |
| 7 | **effect ↔ particle** | particle, effect | Weather particles in effect vs emitters in particle | Clarify: particle = point emitters, effect = full-screen post-processing |
| 8 | **math ↔ physics (Vec2/AABB)** | math, physics, tilemap | collision_helpers reimplements point/AABB math; coords.rs returns tuples not Vec2 | Use math::Vec2 directly in physics helpers and tilemap coords |

## Medium-Priority Overlap Pairs (referenced by 2 modules)

| # | Pair | Modules citing | Description |
|---|------|----------------|-------------|
| 9 | effect ↔ light (ambient) | effect, light | AmbientState vs LightWorld.ambient — two ambient systems |
| 10 | save ↔ filesystem | save, filesystem | save_api does file I/O in Lua layer; SaveManager duplicates write-to-save-dir logic |
| 11 | save ↔ serial (TOML) | save, serial | SaveManager has self-contained Lua-syntax serializer despite serial module |
| 12 | data ↔ log (RingBuffer) | data, log | MemorySink uses VecDeque as bounded ring; data::RingBuffer provides same abstraction |
| 13 | image ↔ effect (pixel transforms) | image, effect | image/effects.rs and effect/image_effect.rs both apply pixel transforms |
| 14 | image ↔ sprite (atlas) | image, sprite | Sprite builds frame atlas from TextureAtlas; shared packing could live in image |
| 15 | scene ↔ ecs | scene, ecs | Scene and Universe both manage entity lifecycle |
| 16 | scene ↔ effect (transitions) | scene, effect | Scene transitions overlap with ScreenTransition |
| 17 | patterns ↔ ecs | patterns, ecs | Observer/Pool patterns overlap with ECS query/archetype |
| 18 | patterns ↔ ai | patterns, ai | FSM in patterns and ai::fsm |
| 19 | automation ↔ timer | automation, timer | Both track "remaining time to fire" lists |
| 20 | automation ↔ pipeline | automation, pipeline | Sequential-step execution overlaps |
| 21 | automation ↔ input | automation, input | Input-event capture overlap |
| 22 | window ↔ camera (viewport) | window, camera | Viewport coordinate mapping overlap |
| 23 | render ↔ pipeline (naming) | render, pipeline | "pipeline" naming collides with GPU render pipeline |
| 24 | input ↔ window (cursor) | input, window | Cursor show/hide in both modules |

## Low-Priority / Informational (single module citation)

| # | Pair | Module | Description |
|---|------|--------|-------------|
| 25 | log structured formatting | log | log_structured duplicates Sink::write_structured formatting |
| 26 | runtime ↔ timer (Clock) | runtime | SharedState owns Clock; timer exports Clock |
| 27 | camera viewport ↔ viewport_scale | camera | Near-identical resize logic |
| 28 | image premultiply-alpha | image | Texture::load duplicates renderer's premultiply logic |
| 29 | math noise | math | noise_functions.rs vs noise_generator.rs duplicate algorithms |
| 30 | bin ↔ main | bin | Both call lurek_run() |
| 31 | save dead file | save | save_data.rs is dead duplicate of save_manager.rs |
| 32 | parallax ↔ tilemap | parallax | Both produce tiled draw calls (minor) |
| 33 | parallax ↔ camera | parallax | Data dependency, not code overlap |
| 34 | i18n ↔ serial (TOML) | i18n | Catalog could delegate TOML parsing to serial |
| 35 | network ↔ thread (Channel) | network | net_thread uses raw mpsc vs thread::Channel |
| 36 | audio ↔ effect | audio | Effect module has audio-visual coupling duplicating bus DSP |
| 37 | audio ↔ image (visualizer) | audio | Waveform export overlaps with ImageData pixel writing |
| 38 | graph dead files | graph | graph.rs and traversal.rs are dead duplicates |

## Action Items

1. **Immediate cleanup** (dead code): Delete save/save_data.rs, graph/graph.rs, graph/traversal.rs
2. **Short-term** (boundary docs): Document tween↔animation, effect↔particle, scene↔ecs boundaries in specs
3. **Medium-term** (shared helpers): Extract RenderCommand builder trait, unify msgpack, share Vec2 usage
4. **Long-term** (consolidation): Merge shake into camera, unify ambient systems, consider EventQueue→Channel wrapper
