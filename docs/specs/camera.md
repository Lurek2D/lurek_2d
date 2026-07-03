<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/camera.md or source docstrings instead. -->

# camera

## TL;DR

- Tracks targets smoothly via customizable presets, dead-zones, and bounds.
- Controls screen shake, zoom pulses, sways, and multi-camera rigs.

## General Info

- Module group: `Platform Services`
- Source path: `src/camera`
- Binding: `src/lua_api/camera_api.rs`
- Namespace: `lurek.camera`
- Lua API surface: `4` functions, `3` types, `97` methods
- User-facing: `true`
- Plugin tier: `not_evaluated`

## Summary

- The `camera` module is the engine's shared view-control surface for users who need world motion to become readable player-facing framing.
- Follow logic, dead zones, damping, bounds, zoom, rotation, path motion, and viewport policy all live here so projects can define how scene focus becomes visible framing.
- This matters because camera behavior shapes feel and readability just as much as raw world state does.
- Follow and constraint logic are central because a useful camera is rarely just a position; it must decide how tightly to track a target, how much to lag, and what world bounds or dead zones should still preserve readability.
- Screen shake, sway, breathing, zoom pulses, and scripted paths extend the module from neutral viewing into gameplay feedback and cinematic presentation.
- Screen-to-world and world-to-screen conversion are equally important because overlays, minimaps, targeting, and editor tools depend on the same view contract.
- Split views, subviews, and viewport-aware framing broaden the feature beyond one player camera into inspection tools and multi-panel presentation workflows.
- Scripted path motion also makes the feature useful for guided pans, flyovers, tutorials, and tool previews where the point is not only to follow a target, but to author how attention moves through space.
- That same contract helps previews and gameplay stay visually aligned.
- This shared framing policy is what keeps several view-dependent systems aligned instead of each inventing its own screen-space math.
- `render` shows the result and world systems choose what to focus, but `camera` owns how that focus is followed, constrained, and transformed into visible space.
- Generic fit-to-screen, screen/content conversion, viewport scaling, and zoom-anchor math belong here. Domain modules such as `province` may expose adapters for their own coordinate systems, but they should delegate shared camera math to this module.
- Read `camera` as the authority for framing policy and coordinate conversion between world and screen.

This module primarily collaborates with `math`, `render`, `tilemap`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

## Ownership

- Canonical source: `src/camera`
- Owning tier: `Platform Services`
- Plugin tier: `not_evaluated`
- Lua binding owner: `src/lua_api/camera_api.rs`
- Referenced engine modules: `math`, `render`, `tilemap`

## Imports

- `math`: Imports or references `src/math/`. Cross-group dependency from `Platform Services` into `Foundations`.
- `render`: Imports or references `src/render/`. Dependency stays inside `Platform Services` and should remain acyclic.
- `tilemap`: Imports or references `src/tilemap/`. Cross-group dependency from `Platform Services` into `Feature Systems`.

## Source Files

### effects.rs

- `src/camera/effects.rs` owns transient motion effects layered on top of base camera transform and follow state.
- It defines `ZoomPulse`, `CameraSway`, and `CameraBreathing`, keeping effect timing and amplitudes together.
- Pulse-based zoom bursts, positional sway, and breathing modulation all live here under independent effect states.
- Each effect updates from elapsed time and reports current deltas, keeping effect math separate from transform storage.
- This file is the effect-state boundary for cameras; follow logic, view state, and projection helpers stay elsewhere.
- Read it when oscillation rules, damping, pulse timing, or effect composition behavior needs to change.

### mod.rs

- `src/camera/mod.rs` is the module index that exposes camera state, effects, paths, viewport logic, and render helpers.
- It reexports core camera types plus effect, rig, tween, viewport, and walker APIs through one stable camera surface.
- No live camera state is stored here; this file only declares child modules and defines which camera symbols are public.
- Read this index when wiring view behavior, because it shows where transform state ends and specialized helpers begin.
- Changes here reshape the camera boundary, since reexports decide what runtime code may import without deep paths.
- This module keeps transforms, effects, scaling, and scripted movement split by responsibility for clearer ownership.

### multi.rs

- `src/camera/multi.rs` owns multi-camera rig management for named camera instances used by split and overlay layouts.
- It defines `CameraRig2D`, keeping camera lookup, creation, layout presets, and bulk updates under one owner.
- Split-screen, minimap, and picture-in-picture viewport arrangements live here, separate from single-camera logic.
- Read this file when rig layout policy, named camera lifecycle, or multi-view update behavior needs to change.

### path.rs

- `src/camera/path.rs` owns waypoint paths and zoom tweens used for scripted camera travel and focal transitions.
- It defines `CameraPath`, `CameraTweenEasing`, `CameraZoomTween`, and `ZoomTween`, keeping timed interpolation together.
- Waypoint progression, segment interpolation, tween progress, and easing-aware zoom updates all live in this file.
- This is the path-and-tween boundary for authored camera motion, while base camera transforms and effects stay elsewhere.
- Read it when path timing, easing selection, or scripted movement interpolation behavior needs to change.

### render.rs

- `src/camera/render.rs` owns render-command generation that wraps scene drawing with camera transform operations.
- It extends `Camera` and `Camera2D` with begin and end transform helpers, keeping render bridging separate from state.
- Push, translate, rotate, scale, and pop command sequencing all live here so projection behavior stays explicit.
- Read this file when camera-to-render-command mapping or bracketing behavior for scene draws needs to change.

### types.rs

- `src/camera/types.rs` owns core camera state models, follow behavior, constraints, and coordinate conversion logic.
- It defines `CameraEasing`, `Camera`, and `Camera2D`, keeping transform storage and runtime camera logic together.
- Follow smoothing, dead-zone handling, look-ahead, bounds clamping, and target tracking all live in this file.
- Zoom and rotation damping plus min/max constraints are also implemented here, keeping stability rules near the state.
- Shake, zoom pulse, sway, and breathing contributions are composed here into effective zoom, offsets, and view matrices.
- Viewport-aware screen-to-world and world-to-screen conversions live here, along with visible-area and resize helpers.
- This file is the main runtime owner of camera transform semantics; effects, paths, and render adapters depend on it.
- Read it when follow policy, constraints, view-matrix composition, or coordinate mapping behavior needs to change.

### viewport.rs

- Owns the camera viewport implementation for the camera subsystem and keeps related runtime rules local here.
- Keeps camera transforms, view state, and viewport rules ownership so helpers stay close to invariants this file updates.
- Defines how camera viewport data is validated, transformed, or stored before neighboring systems consume it.
- Separates camera viewport behavior from Lua bindings, tests, and sibling owners so integration stays readable.
- Documents the boundary where camera code accepts inputs, reports errors, allocates state, or emits outputs.
- Use this file when changing camera viewport defaults, lifecycle handling, validation, or data ownership rules.

### viewport_scale.rs

- `src/camera/viewport_scale.rs` owns compact runtime scaling state for game-to-screen transforms from scale modes.
- It defines `ViewportScale`, keeping computed scales, offsets, and scaled dimensions under one lightweight container.
- Resize recomputation and bidirectional coordinate conversion live here for callers that need cached transform data.
- Read this file when stored scaling fields or fast coordinate-remap behavior needs to change.

### walker.rs

- This file owns walker behavior inside the camera subsystem, close to its data and invariants.
- It keeps validation, defaults, and error-facing rules near the operations that mutate walker state.
- Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
- Public functions in this file are the stable entry points other modules should use for walker work.
- Serialization, indexing, and boundary checks stay here when they depend on walker internals.



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

- `LCameraWalker:getCamera() -> LCamera`: Returns the camera associated with this walker.
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

## Examples

- `content/examples/camera.lua` (present)

## Architecture Links

- Intentionally empty.

## Notes

- Domain modules can keep ergonomic helpers such as province picking, but shared viewport and zoom behavior should remain reusable through `camera`.
