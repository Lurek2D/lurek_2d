# camera

## General Info

- Module group: `Platform Services`
- Source path: `src/camera/`
- Binding: `src/lua_api/camera_api.rs`
- Namespace: `lurek.camera`
- Lua API surface: `3` functions, `2` types, `85` methods
- Rust test path(s): tests/rust/unit/camera_tests.rs, tests/rust/stress/camera_fuzz_tests.rs
- Lua test path(s): tests/lua/unit/test_camera.lua, tests/lua/stress/test_camera_stress.lua, tests/lua/integration/test_tween_camera.lua, tests/lua/integration/test_tilemap_camera.lua, tests/lua/integration/test_scene_camera.lua, tests/lua/integration/test_parallax_camera.lua, tests/lua/integration/test_input_camera.lua, tests/lua/integration/test_render_camera.lua

## Summary

The `camera` module controls how the world is seen on screen in 2D runtime scenarios. It provides one consistent place to manage camera position, zoom, rotation, follow logic, and viewport mapping. Functionally, it separates view behavior from gameplay logic so systems can share the same camera rules.

Its camera state tools support both direct control and guided motion. Scripts can move or target the camera, apply smoothing and easing, run path-based travel, and use zoom transitions. This makes the module useful for gameplay tracking, cutscene movement, and tool-driven inspection flows.

Visual motion quality is improved through effect primitives such as shake, sway, and pulse-like zoom. These effects layer on top of base camera behavior, so teams can add impact and feedback without rewriting core follow or transform code.

Viewport handling is treated as its own concern. Scaling strategy and coordinate conversion are managed alongside camera transforms, which helps keep behavior stable across different window sizes and presentation modes. This reduces coupling between display policy and gameplay camera decisions.

The module also supports multi-camera orchestration through named rigs and layout helpers. Split-screen, minimap, and picture-in-picture flows can be managed through one control surface while keeping render integration predictable. Overall, the module provides a complete and reusable view-control foundation for 2D projects.

## Files

### [effects.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/camera/effects.rs)

- Implements transient camera-motion effects layered on top of the base follow transform state.
- Provides pulse-based zoom bursts for impact moments and short-lived cinematic emphasis.
- Adds oscillatory sway offsets with tunable frequency and damping for dynamic camera motion feel.
- Supplies breathing-style zoom modulation for subtle ambient life during low-action periods.
- Keeps each effect independently updateable so compositions remain modular and controllable.
- Serves as the reusable effect toolkit consumed by camera runtime state integration.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/camera/mod.rs)

- Defines the camera module boundary that groups transform state, effects, viewport, and rendering helpers.
- Exposes a coherent camera surface while keeping pathing, rigs, and scaling concerns modularized.
- Serves as the high-level composition root for runtime camera behavior across engine systems.

### [multi.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/camera/multi.rs)

- Implements multi-camera rig management over named camera instances for concurrent view setups.
- Provides preset layout helpers for split-screen, minimap, and picture-in-picture arrangements.
- Supports deterministic iteration and bulk mutation flows for multi-pass rendering integration.
- Serves as the orchestration layer for scenarios requiring more than one active camera view.

### [path.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/camera/path.rs)

- Implements waypoint-driven camera path interpolation for scripted movement and guided shots.
- Provides zoom tweening with easing control for smooth focal transitions over fixed durations.
- Tracks segment progress across multi-point paths to produce continuous positional interpolation.
- Supports reusable easing selection so authored camera motion keeps consistent temporal character.
- Serves as the timeline-friendly movement layer above direct camera transform manipulation.

### [render.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/camera/render.rs)

- Converts camera transform state into renderer command sequences for scene-space projection.
- Emits ordered push, translate, rotate, scale, and pop operations for deterministic visual mapping.
- Splits begin and end phases so callers can bracket arbitrary scene draw commands safely.
- Serves as the render-bridge layer between camera math state and command-stream execution.

### [types.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/camera/types.rs)

- Defines core camera state models that represent both minimal and fully featured 2D camera behavior.
- Implements follow logic with dead-zone handling, smoothing response, and look-ahead displacement control.
- Integrates transient effects such as shake, pulse, sway, and breathing into effective camera transforms.
- Maintains zoom and rotation state with damping and bounded constraint ranges for runtime stability.
- Provides viewport-aware world-to-screen and screen-to-world mapping through explicit conversion utilities.
- Builds view matrices by composing position, rotation, zoom, and active effect contributions coherently.
- Exposes easing-driven interpolation options for authored motion character and follow response tuning.
- Supports target-follow presets that package common control profiles for gameplay camera styles.
- Keeps transform ownership centralized so dependent render and logic systems read consistent state.
- Serves as the primary camera runtime contract consumed across movement, rendering, and tooling layers.

### [viewport.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/camera/viewport.rs)

- Implements viewport scaling policies that map fixed game space into dynamic window dimensions.
- Defines scale modes for aspect-preserving letterbox, free stretch, and pixel-perfect presentation.
- Stores computed scale and offset transforms recalculated on resize without recreating viewport state.
- Provides bidirectional coordinate conversion between screen pixels and logical game coordinates.
- Serves as the canonical scaling contract consumed by camera and render integration paths.

### [viewport_scale.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/camera/viewport_scale.rs)

- Implements runtime viewport-scale state used by resize and projection update workflows.
- Stores computed scale factors, offsets, and scaled dimensions after each window-size change.
- Provides bidirectional conversion helpers between logical game space and screen pixel coordinates.
- Serves as a compact scaling container for systems that need fast coordinate remapping.
