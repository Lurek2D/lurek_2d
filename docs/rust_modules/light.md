# light

## General Info

- Module group: `Platform Services`
- Source path: `src/light/`
- Binding: `src/lua_api/light_api.rs`
- Namespace: `lurek.light`
- Lua API surface: `20` functions, `4` types, `79` methods
- Rust test path(s): tests/rust/unit/light_tests.rs
- Lua test path(s): tests/lua/unit/test_light.lua, tests/lua/stress/test_light_stress.lua, tests/lua/integration/test_light_render.lua, tests/lua/evidence/test_evidence_light.lua

## Summary

It is responsible for managing point, spot, and area lights, alongside shadow-casting occluders, to create dynamic and atmospheric scene illumination. At its core, the `Light2D` struct encapsulates the properties of an individual light source, including its position, color, radius, intensity, cone angles for spot behavior, falloff curves, and procedural flicker configurations. The module is intentionally designed as a pure data management layer—it handles the logical state, grouping, and animation of lights, while the actual GPU rasterization and shader execution are deferred entirely to the `render` module.

The central orchestration of these lighting primitives is handled by the `LightWorld`. This scene-level container holds pools of active lights and `Occluder` shapes (convex polygons that block light propagation to generate shadows). It provides an efficient slotmap-backed architecture for adding, removing, and querying these entities, as well as applying batch operations like intensity or color changes across named light groups. The lighting model supports sophisticated attenuation, allowing for quadratic, linear, and inverse-square falloff models, alongside custom coefficient tuples to precisely control how light decays over distance. Blend modes (additive, subtractive, alpha-mix) dictate how each light composited into the final accumulation buffer.

Beyond static illumination, the module excels in dynamic effects. It features a robust `FlickerConfig` system that drives procedural, noise-based intensity variation over time—ideal for simulating torches, candles, or unstable neon signs. To ensure optimal performance, the flicker system utilizes a lazy-indexed advance loop that only evaluates lights with active flicker states. The module also supports time-based linear transitions for smoothly animating light color, intensity, and radius. Additionally, it offers advanced shadow filtering presets (from hard shadows to various PCF soft-shadow kernels) and normal-map integration for surface shading. The entire feature set is extensively exposed to the scripting environment via the `lurek.light.*` API.

## Files

### [attenuation.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/light/attenuation.rs)

- Defines quadratic attenuation math controlling how light intensity decays with distance.
- Encapsulates constant, linear, and quadratic coefficients in a compact reusable configuration.
- Computes attenuation factors used by runtime light contribution evaluation.
- Includes simple visualization support for tuning falloff curve behavior.

### [blend_mode.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/light/blend_mode.rs)

- Defines compositing modes that control how each light contribution merges into accumulated lighting.
- Encodes additive, subtractive, and mixed behaviors for different artistic lighting goals.
- Provides compact blend-mode discriminants shared across lighting evaluation and rendering paths.

### [falloff.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/light/falloff.rs)

- Defines radial falloff profiles that shape brightness between light center and radius boundary.
- Provides linear, smooth, and constant decay modes for distinct lighting aesthetics.
- Supplies simple mode flags combined with distance attenuation during light evaluation.

### [flicker.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/light/flicker.rs)

- Defines sine-based flicker state that modulates light intensity across time.
- Tracks oscillation phase, speed, and strength for controllable temporal variation.
- Supports deterministic per-frame advancement with wrapped phase continuity.
- Enables torch, candle, and neon style animation without custom update code.

### [light2d.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/light/light2d.rs)

- Defines the full per-light data model covering transform, color, energy, and shading behavior.
- Encapsulates light geometry, blend mode, falloff, attenuation, and layer-mask participation.
- Stores spot-cone, shadow, normal-map, and volumetric options in one configurable runtime object.
- Provides constructor defaults tuned for immediate point-light usage without extra setup.
- Exposes field access patterns used by world management and Lua-facing controls.
- Supports optional flicker and grouping metadata for batched animation and edits.
- Includes debug-oriented helpers that visualize key lighting parameter effects.

### [light_type.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/light/light_type.rs)

- Defines geometric light models used by the 2D lighting pipeline.
- Distinguishes point, directional, and spot semantics for illumination behavior.
- Supplies compact type discriminants used during shading and shadow evaluation.

### [light_world.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/light/light_world.rs)

- Implements scene-level light management for `Light2D` and occluder collections keyed by stable handles.
- Supports creation, removal, lookup, and bulk mutation of lighting entities across runtime updates.
- Applies group-based operations for coordinated enable, color, and intensity adjustments.
- Advances active flicker states efficiently to animate selected lights over time.
- Exposes renderer-oriented snapshots such as ambient terms and directional data aggregates.
- Provides debug preview rasterization to inspect approximate light-map outcomes.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/light/mod.rs)

- High-level lighting module that groups light types, occluders, world state, and transition utilities.
- Re-exports core enums and structs used to configure 2D illumination behavior across the engine.
- Defines the module boundary for attenuation, blending, shadows, and runtime light orchestration.

### [occluder.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/light/occluder.rs)

- Defines convex polygon occluders that block light and contribute to shadow casting.
- Stores local vertices with world offset and opacity controls for flexible scene placement.
- Supports runtime vertex replacement from typed points or flat coordinate inputs.
- Applies layer-mask and enable flags to scope occluder influence across light groups.

### [shadow.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/light/shadow.rs)

- Defines shadow filtering quality presets used by soft-shadow evaluation paths.
- Encodes hard-shadow and PCF-based options with different sampling costs.
- Provides a compact quality enum consumed by light shadow configuration.

### [transition.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/light/transition.rs)

- Implements time-based linear transitions for light color, intensity, and radius values.
- Tracks elapsed progress against duration to produce deterministic interpolated states.
- Clamps timing parameters to safe bounds for stable update behavior.
- Supports per-frame stepping until transitions reach their configured targets.
