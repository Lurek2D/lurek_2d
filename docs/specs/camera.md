# camera

## TL;DR

- The `camera` module is a versatile and fully-featured 2D camera and viewport management system positioned within the Platform Services tier.

## General Info

- Module group: `Platform Services`
- Source path: `src/camera/`
- Lua API path(s): `src/lua_api/camera_api.rs`
- Primary Lua namespace: `lurek.camera`
- Rust test path(s): tests/rust/unit/camera_tests.rs, tests/rust/stress/camera_fuzz_tests.rs
- Lua test path(s): tests/lua/unit/test_camera.lua, tests/lua/stress/test_camera_stress.lua, tests/lua/integration/test_tween_camera.lua, tests/lua/integration/test_tilemap_camera.lua, tests/lua/integration/test_scene_camera.lua, tests/lua/integration/test_parallax_camera.lua, tests/lua/integration/test_input_camera.lua, tests/lua/integration/test_render_camera.lua

## Summary

The `camera` module is the runtime camera stack for 2D view transforms, camera behavior, and viewport mapping. It is organized as cooperating submodules rather than one heavy type: core camera state (`types`), viewport scaling (`viewport` and `viewport_scale`), path/tween motion (`path`), effect primitives (`effects`), multi-camera coordination (`multi`), and render-command adapters (`render`).

This module's role is transform policy, not scene ownership. It computes where and how to view the world, then exposes that state to render paths and scripts. Features like follow behavior, easing, path interpolation, and rig composition are kept in camera space so gameplay systems can consume them without duplicating math.

The separation between viewport and camera behavior is deliberate. Viewport code governs screen/game scaling strategy and coordinate conversion, while camera code governs position/zoom/rotation behavior. This avoids accidental coupling between display resolution concerns and gameplay camera logic.

In practice, camera changes should preserve stable transform semantics across single-camera and multi-camera flows. Render integration should remain adapter-style: camera produces view data, renderer consumes commands.

Implementation detail and boundary guarantees for camera: this module keeps responsibilities explicit across source files so behavior remains inspectable during refactors. The current source map is: effects.rs: Camera effect primitives for transient motion overlays on top of base camera state.; mod.rs: Camera subsystem module root: effects, multi-view, path, render, types, and viewport.; multi.rs: Multi-camera rig that stores and manages named Camera2D instances.; path.rs: Waypoint-based camera path interpolation for scripted camera movement.; render.rs: Render command generation from camera transform state.; types.rs: Core camera state containers: Camera (minimal) and Camera2D (full runtime).; viewport.rs: Viewport scaling strategies for mapping a fixed game surface into variable window sizes.; viewport_scale.rs: Viewport scale state object used by the engine resize flow.. This split is part of the contract: orchestration stays in composition points, data models stay in type-centric files, and adapters stay in bridge files. That separation reduces hidden coupling, improves testability, and keeps Lua API surfaces aligned with Rust runtime semantics. For maintainers, the key guarantee is that high-level APIs should keep delegating into scoped internals instead of collapsing into a single large entry point. Future extensions should preserve explicit dependency direction and documented invariants near owning types and functions.

## Files

### effects.rs

- Implements transient camera-motion effects layered on top of the base follow transform state.
- Provides pulse-based zoom bursts for impact moments and short-lived cinematic emphasis.
- Adds oscillatory sway offsets with tunable frequency and damping for dynamic camera motion feel.
- Supplies breathing-style zoom modulation for subtle ambient life during low-action periods.
- Keeps each effect independently updateable so compositions remain modular and controllable.
- Serves as the reusable effect toolkit consumed by camera runtime state integration.

### mod.rs

- Defines the camera module boundary that groups transform state, effects, viewport, and rendering helpers.
- Exposes a coherent camera surface while keeping pathing, rigs, and scaling concerns modularized.
- Serves as the high-level composition root for runtime camera behavior across engine systems.

### multi.rs

- Implements multi-camera rig management over named camera instances for concurrent view setups.
- Provides preset layout helpers for split-screen, minimap, and picture-in-picture arrangements.
- Supports deterministic iteration and bulk mutation flows for multi-pass rendering integration.
- Serves as the orchestration layer for scenarios requiring more than one active camera view.

### path.rs

- Implements waypoint-driven camera path interpolation for scripted movement and guided shots.
- Provides zoom tweening with easing control for smooth focal transitions over fixed durations.
- Tracks segment progress across multi-point paths to produce continuous positional interpolation.
- Supports reusable easing selection so authored camera motion keeps consistent temporal character.
- Serves as the timeline-friendly movement layer above direct camera transform manipulation.

### render.rs

- Converts camera transform state into renderer command sequences for scene-space projection.
- Emits ordered push, translate, rotate, scale, and pop operations for deterministic visual mapping.
- Splits begin and end phases so callers can bracket arbitrary scene draw commands safely.
- Serves as the render-bridge layer between camera math state and command-stream execution.

### types.rs

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

### viewport.rs

- Implements viewport scaling policies that map fixed game space into dynamic window dimensions.
- Defines scale modes for aspect-preserving letterbox, free stretch, and pixel-perfect presentation.
- Stores computed scale and offset transforms recalculated on resize without recreating viewport state.
- Provides bidirectional coordinate conversion between screen pixels and logical game coordinates.
- Serves as the canonical scaling contract consumed by camera and render integration paths.

### viewport_scale.rs

- Implements runtime viewport-scale state used by resize and projection update workflows.
- Stores computed scale factors, offsets, and scaled dimensions after each window-size change.
- Provides bidirectional conversion helpers between logical game space and screen pixel coordinates.
- Serves as a compact scaling container for systems that need fast coordinate remapping.

## Lua API Ref

- Binding: `src/lua_api/camera_api.rs`
- Namespace: `lurek.camera`

### Functions

- `lurek.camera.new`: Creates a 2D camera with optional virtual viewport size.
- `lurek.camera.newCamera`: Creates a 2D camera with optional virtual viewport size.
- `lurek.camera.newRig`: Creates an empty named camera rig. This function is exposed to Lua scripts.

### Enums

- No documented module-level enums/constants.

### Types

#### LCamera Type

- Lua-side 2D camera handle with transforms, effects, bounds, and render command access.

##### Fields

- No documented fields.

##### Methods

- `LCamera:apply`: Appends render commands that apply this camera transform.
- `LCamera:attach`: Appends render commands that attach this camera transform.
- `LCamera:clearParallaxFactors`: Clears all layer parallax factor overrides.
- `LCamera:clearTarget`: Clears the follow target. This method is available to Lua scripts.
- `LCamera:detach`: Appends a render command that detaches the active camera transform.
- `LCamera:followPath`: Starts camera movement along an array of waypoint tables.
- `LCamera:getBounds`: Returns camera bounds with a leading availability flag.
- `LCamera:getDeadZone`: Returns follow dead-zone dimensions with a leading availability flag.
- `LCamera:getEffectOffset`: Returns combined camera effect offset.
- `LCamera:getEffectiveZoom`: Returns zoom after camera effects are applied.
- `LCamera:getFollowEasing`: Returns target follow easing mode.
- `LCamera:getFollowSmooth`: Returns follow smoothing speed. This method is available to Lua scripts.
- `LCamera:getLookAhead`: Returns follow look-ahead multiplier.
- `LCamera:getParallaxFactor`: Returns a parallax factor for a named layer.
- `LCamera:getPosition`: Returns the camera world position.
- `LCamera:getRenderOffset`: Returns current render offset after camera effects.
- `LCamera:getRotation`: Returns the camera rotation. This method is available to Lua scripts.
- `LCamera:getRotationConstraints`: Returns rotation constraints with availability flags.
- `LCamera:getRotationDamping`: Returns rotation damping. This method is available to Lua scripts.
- `LCamera:getShakeOffset`: Returns current camera shake offset.
- `LCamera:getTarget`: Returns the follow target with a leading availability flag.
- `LCamera:getViewport`: Returns the camera viewport rectangle.
- `LCamera:getVisibleArea`: Returns the world-space area visible through this camera.
- `LCamera:getZoom`: Returns the camera zoom factor. This method is available to Lua scripts.
- `LCamera:getZoomConstraints`: Returns zoom constraints with availability flags.
- `LCamera:getZoomDamping`: Returns zoom damping. This method is available to Lua scripts.
- `LCamera:hasBounds`: Returns whether camera bounds are active.
- `LCamera:isBreathing`: Returns whether breathing zoom animation is active.
- `LCamera:isSway`: Returns whether camera sway is active.
- `LCamera:lookAt`: Centers the camera on a world position.
- `LCamera:move`: Moves the camera by a delta. This method is available to Lua scripts.
- `LCamera:onWindowResize`: Updates camera viewport state after a window resize.
- `LCamera:onWindowResizeScaled`: Updates camera viewport state using a virtual game size and scale mode.
- `LCamera:pathProgress`: Returns active path progress. This method is available to Lua scripts.
- `LCamera:presetAggressiveFollow`: Applies the aggressive follow camera preset.
- `LCamera:presetBalancedFollow`: Applies the balanced follow camera preset.
- `LCamera:presetCinematicFollow`: Applies the cinematic follow camera preset.
- `LCamera:presetTightFollow`: Applies the tight follow camera preset.
- `LCamera:removeBounds`: Removes active camera bounds. This method is available to Lua scripts.
- `LCamera:reset`: Appends a render command that removes the active camera transform.
- `LCamera:setBounds`: Sets camera world bounds. This method is available to Lua scripts.
- `LCamera:setDeadZone`: Sets follow dead-zone dimensions.
- `LCamera:setFollowEasing`: Sets target follow easing mode. This method is available to Lua scripts.
- `LCamera:setFollowSmooth`: Sets follow smoothing speed. This method is available to Lua scripts.
- `LCamera:setLookAhead`: Sets follow look-ahead multiplier.
- `LCamera:setParallaxFactor`: Sets a parallax factor for a named layer.
- `LCamera:setPosition`: Sets the camera world position. This method is available to Lua scripts.
- `LCamera:setRotation`: Sets the camera rotation. This method is available to Lua scripts.
- `LCamera:setRotationConstraints`: Sets optional minimum and maximum rotation constraints.
- `LCamera:setRotationDamping`: Sets rotation damping. This method is available to Lua scripts.
- `LCamera:setTarget`: Sets a world-space follow target. This method is available to Lua scripts.
- `LCamera:setViewport`: Sets the camera viewport rectangle.
- `LCamera:setZoom`: Sets the camera zoom factor. This method is available to Lua scripts.
- `LCamera:setZoomConstraints`: Sets optional minimum and maximum zoom constraints.
- `LCamera:setZoomDamping`: Sets zoom damping. This method is available to Lua scripts.
- `LCamera:shake`: Starts a camera shake effect. This method is available to Lua scripts.
- `LCamera:startBreathing`: Starts subtle breathing zoom animation.
- `LCamera:startSway`: Starts camera sway offset animation.
- `LCamera:stopBreathing`: Stops breathing zoom animation. This method is available to Lua scripts.
- `LCamera:stopPath`: Stops the active camera path. This method is available to Lua scripts.
- `LCamera:stopSway`: Stops camera sway offset animation.
- `LCamera:stopZoom`: Stops the active zoom tween. This method is available to Lua scripts.
- `LCamera:toScreen`: Converts world coordinates to screen coordinates.
- `LCamera:toWorld`: Converts screen coordinates to world coordinates.
- `LCamera:type`: Returns the Lua-visible type name for this camera handle.
- `LCamera:typeOf`: Returns whether this camera handle matches a supported type name.
- `LCamera:update`: Advances camera follow, shake, and effect state.
- `LCamera:updatePath`: Advances the active camera path and applies its position.
- `LCamera:updateZoom`: Advances the active zoom tween and applies its zoom value.
- `LCamera:zoomPulse`: Triggers a temporary zoom pulse effect.
- `LCamera:zoomTo`: Starts a zoom tween toward a target zoom factor.

#### LCameraRig Type

- Lua-side camera rig that manages named cameras and viewport layouts.

##### Fields

- No documented fields.

##### Methods

- `LCameraRig:apply`: Appends render commands for a named camera in this rig.
- `LCameraRig:getViewport`: Returns a named rig camera viewport with a leading availability flag.
- `LCameraRig:has`: Returns whether this rig contains a named camera.
- `LCameraRig:minimap`: Applies a minimap layout using the current window size and optional ratio.
- `LCameraRig:names`: Returns all camera names in this rig.
- `LCameraRig:pictureInPicture`: Applies a picture-in-picture layout using optional inset size.
- `LCameraRig:remove`: Removes a named camera from this rig.
- `LCameraRig:setPosition`: Sets the position of a named rig camera, creating it if needed.
- `LCameraRig:setTarget`: Sets the follow target of a named rig camera, creating it if needed.
- `LCameraRig:setZoom`: Sets the zoom of a named rig camera, creating it if needed.
- `LCameraRig:splitScreen`: Applies a split-screen layout using the current window size.
- `LCameraRig:type`: Returns the Lua-visible type name for this camera rig handle.
- `LCameraRig:typeOf`: Returns whether this camera rig handle matches a supported type name.
- `LCameraRig:updateAll`: Advances every camera in this rig. This method is available to Lua scripts.

## References

- `math`: Imports or references `math` from `src/math/`.
- `render`: Imports or references `render` from `src/render/`.
