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

This module represents the dynamic 2D illumination and shadow-casting subsystem, offering developers control over visual lighting environments. It operates a centralized light world container that manages active lights and structural occluders keyed by stable handles. By processing coordinates, global ambient colors, and light groupings, the system produces coordinated illumination layers that shape visual depth and gameplay moods in real-time.

At the heart of the light simulation are geometric models distinguishing point, spot-cone, and directional light types. Individual lights carry parameters for color, energy, and quadratic attenuation formulas that dictate how intensity decays over distance. Radial falloff profiles define custom decay curves between light centers and outer radii. These properties blend using additive or subtractive modes to compose complex, overlapping lighting maps.

To animate lighting layouts dynamically, the module includes temporal flicker modules and smooth transition helpers. Flicker units animate lights using sine-based oscillations that simulate torches, candles, or flickering neon bulbs over time. Transition systems interpolate values linearly across frame boundaries, stepping colors, intensities, and sizes toward target goals smoothly to create environmental changes.

Shadow casting is supported by convex polygon occluders that block light dynamically. Occluders carry local coordinates, enabling developers to position collision shapes and modify their opacity in real-time. Inclusion and shadow receiver masks allow developers to control which lights interact with specific occluding objects. This system features hard-shadowing or soft-shadow PCF-based filters to control both visual styling and rendering costs.

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
