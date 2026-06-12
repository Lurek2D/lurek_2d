# camera

## TL;DR

- Tracks targets smoothly via customizable presets, dead-zones, and bounds.
- Controls screen shake, zoom pulses, sways, and multi-camera rigs.

## General Info

- Module group: `Platform Services`
- Source path: `src/camera/`
- Binding: `src/lua_api/camera_api.rs`
- Namespace: `lurek.camera`
- Lua API surface: `4` functions, `3` types, `97` methods
- Rust test path(s): tests/rust/unit/camera_tests.rs, tests/rust/stress/camera_fuzz_tests.rs
- Lua test path(s): tests/lua_reorg/unit/test_camera.lua, tests/lua_reorg/stress/test_camera_stress.lua, tests/lua_reorg/integration/test_tween_camera.lua, tests/lua_reorg/integration/test_tilemap_camera.lua, tests/lua_reorg/integration/test_scene_camera.lua, tests/lua_reorg/integration/test_parallax_camera.lua, tests/lua_reorg/integration/test_input_camera.lua, tests/lua_reorg/integration/test_render_camera.lua

## Summary

- Controls how players see the world by mapping game-space motion into stable, readable screen framing.
- Enables smooth target following with dead zones, easing, and look-ahead to reduce jitter and improve readability.
- Provides practical follow presets so teams can get a good camera feel quickly before deep tuning.
- Supports world bounds to prevent exposing invalid map regions during traversal and high-speed movement.
- Exposes direct positioning and rotation controls for scripted cinematics and authored transitions.
- Includes zoom controls with constraints and damping so scale changes stay intentional and comfortable.
- Adds screen shake for impact feedback while preserving controllable intensity and duration.
- Adds sway and breathing effects for subtle motion language in exploration and menu-heavy scenes.
- Supports zoom pulses and timed transitions for moment-to-moment emphasis during gameplay beats.
- Provides world-to-screen and screen-to-world conversion for UI overlays, targeting, and interaction tools.
- Handles resize-aware viewport behavior so camera output remains predictable across resolutions.
- Supports scale modes like letterbox and pixel-perfect for different visual presentation goals.
- Enables path-driven camera movement for intros, cutscenes, and guided tutorial sequences.
- Allows multiple named cameras in one rig for split-screen, minimap, and inset workflows.
- Lets systems switch active views cleanly without rebuilding render pipelines.
- Gives gameplay, UI, and render code one shared camera contract instead of parallel ad-hoc logic.
- Helps users build camera behavior that feels responsive, cinematic, and technically stable.
- Acts as the core module for viewport control across single-camera and multi-camera game experiences.
- Reduces implementation friction by packaging common camera patterns behind script-friendly APIs.
- Improves player comfort by keeping motion framing, zoom, and rotation behavior consistent and bounded.

This module primarily collaborates with `math`, `render`, `tilemap`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

## Imports

- `math`: Imports or references `math` from `src/math/`.
- `render`: Imports or references `render` from `src/render/`.
- `tilemap`: Imports or references `src/tilemap/`. Cross-group dependency from `Platform Services` into `Feature Systems`.

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

### walker.rs

- Tile-grid walker with smooth camera following.
- Provides a walker that moves on a tile-based grid with collision detection and
- integrates camera following behavior. The walker tracks both world-space and tile-space positions,
- supports directional movement with tile collision checks, and smoothly updates an associated camera.

## Lua API Ref

### Functions

- `lurek.camera.new(vw?, vh?) -> LCamera`: Creates a 2D camera with optional virtual viewport size.
- `lurek.camera.newCamera(vw?, vh?) -> LCamera`: Creates a 2D camera with optional virtual viewport size.
- `lurek.camera.newRig() -> LCameraRig`: Creates an empty named camera rig. This function is exposed to Lua scripts.
- `lurek.camera.newWalker(map, opts?) -> LCameraWalker`: Creates a tile-grid walker with smooth camera following.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LCamera Type

- Lua-side 2D camera handle with transforms, effects, bounds, and render command access.

##### Fields

- No documented fields.

##### Methods

- `LCamera:apply() -> nil`: Appends render commands that apply this camera transform.
- `LCamera:attach() -> nil`: Appends render commands that attach this camera transform.
- `LCamera:clearParallaxFactors() -> nil`: Clears all layer parallax factor overrides.
- `LCamera:clearTarget() -> nil`: Clears the follow target. This method is available to Lua scripts.
- `LCamera:detach() -> nil`: Appends a render command that detaches the active camera transform.
- `LCamera:followPath(points, duration) -> nil`: Starts camera movement along an array of waypoint tables.
- `LCamera:getBounds() -> boolean, number, number, number, number`: Returns camera bounds with a leading availability flag.
- `LCamera:getDeadZone() -> boolean, number, number`: Returns follow dead-zone dimensions with a leading availability flag.
- `LCamera:getEffectOffset() -> number, number`: Returns combined camera effect offset.
- `LCamera:getEffectiveZoom() -> number`: Returns zoom after camera effects are applied.
- `LCamera:getFollowEasing() -> string`: Returns target follow easing mode.
- `LCamera:getFollowSmooth() -> number`: Returns follow smoothing speed. This method is available to Lua scripts.
- `LCamera:getLookAhead() -> number`: Returns follow look-ahead multiplier.
- `LCamera:getParallaxFactor(layer) -> number`: Returns a parallax factor for a named layer.
- `LCamera:getPosition() -> number, number`: Returns the camera world position.
- `LCamera:getRenderOffset() -> number, number`: Returns current render offset after camera effects.
- `LCamera:getRotation() -> number`: Returns the camera rotation. This method is available to Lua scripts.
- `LCamera:getRotationConstraints() -> boolean, number, boolean, number`: Returns rotation constraints with availability flags.
- `LCamera:getRotationDamping() -> number`: Returns rotation damping. This method is available to Lua scripts.
- `LCamera:getShakeOffset() -> number, number`: Returns current camera shake offset.
- `LCamera:getTarget() -> boolean, number, number`: Returns the follow target with a leading availability flag.
- `LCamera:getViewport() -> number, number, number, number`: Returns the camera viewport rectangle.
- `LCamera:getVisibleArea() -> number, number, number, number`: Returns the world-space area visible through this camera.
- `LCamera:getZoom() -> number`: Returns the camera zoom factor. This method is available to Lua scripts.
- `LCamera:getZoomConstraints() -> boolean, number, boolean, number`: Returns zoom constraints with availability flags.
- `LCamera:getZoomDamping() -> number`: Returns zoom damping. This method is available to Lua scripts.
- `LCamera:hasBounds() -> boolean`: Returns whether camera bounds are active.
- `LCamera:isBreathing() -> boolean`: Returns whether breathing zoom animation is active.
- `LCamera:isSway() -> boolean`: Returns whether camera sway is active.
- `LCamera:lookAt(x, y) -> nil`: Centers the camera on a world position.
- `LCamera:move(dx, dy) -> nil`: Moves the camera by a delta. This method is available to Lua scripts.
- `LCamera:onWindowResize(window_w, window_h) -> nil`: Updates camera viewport state after a window resize.
- `LCamera:onWindowResizeScaled(game_w, game_h, window_w, window_h, mode) -> nil`: Updates camera viewport state using a virtual game size and scale mode.
- `LCamera:pathProgress() -> number`: Returns active path progress. This method is available to Lua scripts.
- `LCamera:presetAggressiveFollow() -> nil`: Applies the aggressive follow camera preset.
- `LCamera:presetBalancedFollow() -> nil`: Applies the balanced follow camera preset.
- `LCamera:presetCinematicFollow() -> nil`: Applies the cinematic follow camera preset.
- `LCamera:presetTightFollow() -> nil`: Applies the tight follow camera preset.
- `LCamera:removeBounds() -> nil`: Removes active camera bounds. This method is available to Lua scripts.
- `LCamera:reset() -> nil`: Appends a render command that removes the active camera transform.
- `LCamera:setBounds(x, y, w, h) -> nil`: Sets camera world bounds. This method is available to Lua scripts.
- `LCamera:setDeadZone(w, h) -> nil`: Sets follow dead-zone dimensions.
- `LCamera:setFollowEasing(easing) -> nil`: Sets target follow easing mode. This method is available to Lua scripts.
- `LCamera:setFollowSmooth(speed) -> nil`: Sets follow smoothing speed. This method is available to Lua scripts.
- `LCamera:setLookAhead(mul) -> nil`: Sets follow look-ahead multiplier.
- `LCamera:setParallaxFactor(layer, factor) -> nil`: Sets a parallax factor for a named layer.
- `LCamera:setPosition(x, y) -> nil`: Sets the camera world position. This method is available to Lua scripts.
- `LCamera:setRotation(r) -> nil`: Sets the camera rotation. This method is available to Lua scripts.
- `LCamera:setRotationConstraints(min_rot?, max_rot?) -> nil`: Sets optional minimum and maximum rotation constraints.
- `LCamera:setRotationDamping(damping) -> nil`: Sets rotation damping. This method is available to Lua scripts.
- `LCamera:setTarget(x, y) -> nil`: Sets a world-space follow target. This method is available to Lua scripts.
- `LCamera:setViewport(x, y, w, h) -> nil`: Sets the camera viewport rectangle.
- `LCamera:setZoom(zoom) -> nil`: Sets the camera zoom factor. This method is available to Lua scripts.
- `LCamera:setZoomConstraints(min_zoom?, max_zoom?) -> nil`: Sets optional minimum and maximum zoom constraints.
- `LCamera:setZoomDamping(damping) -> nil`: Sets zoom damping. This method is available to Lua scripts.
- `LCamera:shake(intensity, duration) -> nil`: Starts a camera shake effect. This method is available to Lua scripts.
- `LCamera:startBreathing(amplitude?, rate?) -> nil`: Starts subtle breathing zoom animation.
- `LCamera:startSway(amplitude_x, amplitude_y, frequency, decay?) -> nil`: Starts camera sway offset animation.
- `LCamera:stopBreathing() -> nil`: Stops breathing zoom animation. This method is available to Lua scripts.
- `LCamera:stopPath() -> nil`: Stops the active camera path. This method is available to Lua scripts.
- `LCamera:stopSway() -> nil`: Stops camera sway offset animation.
- `LCamera:stopZoom() -> nil`: Stops the active zoom tween. This method is available to Lua scripts.
- `LCamera:toScreen(wx, wy) -> number, number`: Converts world coordinates to screen coordinates.
- `LCamera:toWorld(sx, sy) -> number, number`: Converts screen coordinates to world coordinates.
- `LCamera:type() -> string`: Returns the Lua-visible type name for this camera handle.
- `LCamera:typeOf(name) -> boolean`: Returns whether this camera handle matches a supported type name.
- `LCamera:update(dt) -> nil`: Advances camera follow, shake, and effect state.
- `LCamera:updatePath(dt) -> boolean`: Advances the active camera path and applies its position.
- `LCamera:updateZoom(dt) -> boolean`: Advances the active zoom tween and applies its zoom value.
- `LCamera:zoomPulse(amplitude, duration) -> nil`: Triggers a temporary zoom pulse effect.
- `LCamera:zoomTo(target_zoom, duration, easing?) -> nil`: Starts a zoom tween toward a target zoom factor.

#### LCameraRig Type

- Lua-side camera rig that manages named cameras and viewport layouts.

##### Fields

- No documented fields.

##### Methods

- `LCameraRig:apply(name) -> boolean`: Appends render commands for a named camera in this rig.
- `LCameraRig:getViewport(name) -> boolean, number, number, number, number`: Returns a named rig camera viewport with a leading availability flag.
- `LCameraRig:has(name) -> boolean`: Returns whether this rig contains a named camera.
- `LCameraRig:minimap(window_w, window_h, ratio?) -> nil`: Applies a minimap layout using the current window size and optional ratio.
- `LCameraRig:names() -> string[]`: Returns all camera names in this rig.
- `LCameraRig:pictureInPicture(window_w, window_h, pip_w?, pip_h?) -> nil`: Applies a picture-in-picture layout using optional inset size.
- `LCameraRig:remove(name) -> boolean`: Removes a named camera from this rig.
- `LCameraRig:setPosition(name, x, y) -> nil`: Sets the position of a named rig camera, creating it if needed.
- `LCameraRig:setTarget(name, x, y) -> nil`: Sets the follow target of a named rig camera, creating it if needed.
- `LCameraRig:setZoom(name, zoom) -> nil`: Sets the zoom of a named rig camera, creating it if needed.
- `LCameraRig:splitScreen(window_w, window_h) -> nil`: Applies a split-screen layout using the current window size.
- `LCameraRig:type() -> string`: Returns the Lua-visible type name for this camera rig handle.
- `LCameraRig:typeOf(name) -> boolean`: Returns whether this camera rig handle matches a supported type name.
- `LCameraRig:updateAll(dt) -> nil`: Advances every camera in this rig. This method is available to Lua scripts.

#### LCameraWalker Type

- Lua-side walker combining tile-grid movement with camera following.

##### Fields

- No documented fields.

##### Methods

- `LCameraWalker:getCamera() -> LCamera`: Returns the associated camera.
- `LCameraWalker:getPosition() -> number, number`: Returns the walker world-space center position.
- `LCameraWalker:getTilePosition() -> integer, integer`: Returns current walker tile coordinates (1-based).
- `LCameraWalker:moveDown(dt?) -> nil`: Moves the walker down (positive Y) with collision checking.
- `LCameraWalker:moveLeft(dt?) -> nil`: Moves the walker left (negative X) with collision checking.
- `LCameraWalker:moveRight(dt?) -> nil`: Moves the walker right (positive X) with collision checking.
- `LCameraWalker:moveUp(dt?) -> nil`: Moves the walker up (negative Y) with collision checking.
- `LCameraWalker:setPosition(x, y) -> nil`: Sets the walker world-space center position.
- `LCameraWalker:setTilePosition(tx, ty) -> nil`: Places walker using 1-based tile coordinates.
- `LCameraWalker:type() -> string`: Returns the type name of this userdata.
- `LCameraWalker:typeOf(name) -> boolean`: Checks whether this object matches the given type name.
- `LCameraWalker:update(dt?) -> nil`: Updates camera state and advances smooth interpolation.
