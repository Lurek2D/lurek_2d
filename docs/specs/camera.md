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

 Its primary role is to handle world-to-screen coordinate mapping, transform calculations, viewport scaling, and dynamic camera behaviors without directly allocating or managing GPU resources. At its core, the module exposes two main camera types: the lightweight `Camera`, providing minimal state like position, zoom, rotation, and view-matrix generation; and the gameplay-ready `Camera2D`, which adds robust tracking behaviors, smooth interpolation, and boundary clamping.

A defining feature of `Camera2D` is its target tracking capability. It supports smooth-follow interpolation using linear, smooth-step, or ease-out-cubic easing. Developers can fine-tune tracking through dead zones, look-ahead multipliers, and zoom/rotation damping. For common use cases, the module provides out-of-the-box follow presets: tight, cinematic, balanced, and aggressive. The `Viewport` subsystem works hand-in-hand with the camera to resolve window resizing by mapping the logical game surface to the physical window using configurable scale modes (Letterbox, Stretch, PixelPerfect).

To enrich visual feedback and game feel, the module implements a suite of composable camera effects. These include `CameraShake` for impactful events, `ZoomPulse` for quick elastic snap-zooms, `CameraSway` for continuous sinusoidal offsets (ideal for underwater or rocking effects), and `CameraBreathing` for subtle rhythmic zoom oscillations. Furthermore, `CameraPath` and `CameraZoomTween` allow for scripted, eased transitions across waypoints and zoom levels over time.

For local multiplayer or complex UI requirements, the module provides `CameraRig2D`, a multi-view manager that stores named camera instances. This rig enables preset viewport layouts such as split-screen, picture-in-picture, and minimaps, performing bulk updates across multiple views deterministically. Finally, the `render` sub-module translates these mathematical states into actionable push/pop transform sequences for the rendering pipeline. The entire feature set is cleanly exposed to Lua through the `lurek.camera.*` namespace, allowing script authors complete control over game feel and multi-camera orchestration.

## Source Documentation

### `effects.rs`
- Camera effect primitives for transient motion overlays on top of base camera state.
- ZoomPulse provides a one-shot sinusoidal zoom spike triggered by game events.
- CameraSway adds oscillating positional offset with configurable frequency and decay.
- CameraBreathing delivers subtle periodic zoom modulation for idle camera presence.
- Each effect is composable: the parent camera sums their outputs each frame.

### `mod.rs`
- Camera subsystem module root: effects, multi-view, path, render, types, and viewport.
- Re-exports all primary types for ergonomic access from engine code.
- Submodules own distinct concerns: transform state, viewport scaling, render commands.

### `multi.rs`
- Multi-camera rig that stores and manages named Camera2D instances.
- Provides preset viewport layouts: split-screen, minimap, and picture-in-picture.
- Supports bulk update and deterministic iteration for multi-view rendering passes.

### `path.rs`
- Waypoint-based camera path interpolation for scripted camera movement.
- CameraZoomTween provides eased transitions between zoom levels over time.
- CameraTweenEasing selects interpolation curve: linear, smooth-step, or ease-out-cubic.
- CameraPath segments multi-point paths with linear interpolation and progress tracking.
- ZoomTween is a type alias preserving backwards compatibility.

### `render.rs`
- Render command generation from camera transform state.
- Builds PushTransform/Translate/Rotate/Scale/PopTransform sequences for Camera and Camera2D.
- Separates begin/end phases so callers can sandwich scene commands between transforms.

### `types.rs`
- Core camera state containers: Camera (minimal) and Camera2D (full runtime).
- Camera2D drives follow-target tracking with dead-zone, smoothing, and look-ahead.
- Integrates shake, zoom pulse, sway, and breathing effects into effective transforms.
- Viewport, bounds, and coordinate conversion for world/screen mapping.
- Zoom and rotation damping with configurable constraint ranges.
- Easing selection for follow interpolation: linear, smooth-step, ease-out-cubic.
- View matrix generation composing position, rotation, zoom, and all active effects.
- Presets for common follow behaviors: tight, cinematic, balanced, aggressive.

### `viewport.rs`
- Viewport scaling strategies for mapping a fixed game surface into variable window sizes.
- ScaleMode selects Letterbox (aspect-preserving), Stretch, or PixelPerfect scaling.
- Viewport struct holds computed scale factors and offsets after each window resize.
- Bidirectional coordinate conversion between screen pixels and game-space units.
- Recomputes transforms on resize without allocating new state.

### `viewport_scale.rs`
- Viewport scale state object used by the engine resize flow.
- Stores computed scale, offset, and scaled dimensions after each resize.
- Provides bidirectional game/screen coordinate conversion helpers.

## Types

- `ZoomPulse` (`struct`, `effects.rs`): Zoom pulse effect — brief zoom-in that decays back to the original zoom via a sine envelope.
- `CameraSway` (`struct`, `effects.rs`): Camera sway — sinusoidal x/y offset oscillation for rocking or underwater effects.
- `CameraBreathing` (`struct`, `effects.rs`): Camera breathing — subtle periodic zoom oscillation for a "living camera" feel.
- `CameraRig2D` (`struct`, `multi.rs`): Stores named camera instances used by multi-view rendering flows.
- `CameraPath` (`struct`, `path.rs`): Animates a camera along a series of world-space waypoints over a fixed duration using linear interpolation between consecutive points.
- `CameraTweenEasing` (`enum`, `path.rs`): Easing mode for camera-local tweening.
- `CameraZoomTween` (`struct`, `path.rs`): Smoothly transitions a camera zoom level from a start value to a target value over a fixed duration.
- `ZoomTween` (`type`, `path.rs`): Backward-compatible alias for `CameraZoomTween`.
- `CameraFollowEasing` (`enum`, `types.rs`): Selects easing behavior used by target-follow interpolation.
- `Camera` (`struct`, `types.rs`): Lightweight camera state with position, zoom, rotation, and view-matrix generation.
- `Camera2D` (`struct`, `types.rs`): Gameplay-facing 2D camera with follow targets, dead zones, look-ahead, bounds clamping, shake, and coordinate helpers.
- `ScaleMode` (`enum`, `viewport.rs`): Enum selecting letterbox, stretch, or pixel-perfect viewport behavior.
- `Viewport` (`struct`, `viewport.rs`): Logical-resolution mapper that computes scale and offset for letterbox, stretch, and pixel-perfect modes.
- `ViewportScale` (`struct`, `viewport_scale.rs`): Viewport variant that also tracks scaled pixel dimensions for transform-stack integration.

## Functions

- `ZoomPulse::new` (`effects.rs`): Create pulse state and return it with effect disabled.
- `ZoomPulse::trigger` (`effects.rs`): Start a pulse and return once state is reset to frame zero.
- `ZoomPulse::update` (`effects.rs`): Advance pulse time and return current zoom delta, returning zero when inactive.
- `ZoomPulse::current_delta` (`effects.rs`): Read current pulse zoom delta and return zero when inactive.
- `ZoomPulse::is_active` (`effects.rs`): Read active flag and return whether pulse contributes any offset.
- `CameraSway::new` (`effects.rs`): Create sway state and return it with zero contribution.
- `CameraSway::start` (`effects.rs`): Start sway motion and return after resetting phase and decay factor.
- `CameraSway::stop` (`effects.rs`): Disable sway and return after clearing contribution factor.
- `CameraSway::update` (`effects.rs`): Advance sway phase and return the current positional offset tuple.
- `CameraSway::current_offset` (`effects.rs`): Read current sway offset and return zeros when inactive.
- `CameraSway::is_active` (`effects.rs`): Read active flag and return whether sway contributes offset.
- `CameraBreathing::new` (`effects.rs`): Create breathing state and return it with default tuning.
- `CameraBreathing::start` (`effects.rs`): Start breathing and return after resetting phase.
- `CameraBreathing::stop` (`effects.rs`): Disable breathing and return immediately.
- `CameraBreathing::update` (`effects.rs`): Advance breathing phase and return current zoom delta.
- `CameraBreathing::current_delta` (`effects.rs`): Read current breathing zoom delta and return zero when inactive.
- `CameraBreathing::is_active` (`effects.rs`): Read active flag and return whether breathing contributes zoom.
- `CameraRig2D::new` (`multi.rs`): Create an empty rig and return it with no registered cameras.
- `CameraRig2D::has_camera` (`multi.rs`): Check camera presence by name and return true when it exists.
- `CameraRig2D::remove_camera` (`multi.rs`): Remove camera by name and return true when an entry was removed.
- `CameraRig2D::ensure_camera` (`multi.rs`): Return mutable camera by name, creating one with the provided viewport when missing.
- `CameraRig2D::camera_mut` (`multi.rs`): Return mutable camera reference for a registered name, or none when absent.
- `CameraRig2D::camera` (`multi.rs`): Return immutable camera reference for a registered name, or none when absent.
- `CameraRig2D::apply_split_screen_layout` (`multi.rs`): Apply left-right split layout and return after updating both camera viewports.
- `CameraRig2D::apply_minimap_layout` (`multi.rs`): Apply main-plus-minimap layout and return after updating camera viewports.
- `CameraRig2D::apply_picture_in_picture_layout` (`multi.rs`): Apply picture-in-picture layout and return after clamping overlay viewport size.
- `CameraRig2D::update_all` (`multi.rs`): Update every camera with delta time and return when all states are advanced.
- `CameraRig2D::viewport_of` (`multi.rs`): Read viewport for named camera and return none when camera is missing.
- `CameraRig2D::camera_names` (`multi.rs`): Return sorted camera names for deterministic iteration in callers.
- `CameraPath::new` (`path.rs`): Create path state and return it with elapsed time reset to zero.
- `CameraPath::update` (`path.rs`): Advance elapsed time and return interpolated waypoint coordinates while active.
- `CameraPath::progress` (`path.rs`): Read normalized path progress and return value clamped to [0, 1].
- `CameraPath::reset` (`path.rs`): Reset path timer and return after re-enabling active progression.
- `CameraZoomTween::new` (`path.rs`): Create linear zoom tween and return initialized state.
- `CameraZoomTween::new_with_easing` (`path.rs`): Create zoom tween with explicit easing and return initialized state.
- `CameraZoomTween::update` (`path.rs`): Advance tween time and return current zoom value while active.
- `CameraZoomTween::progress` (`path.rs`): Read normalized tween progress and return value clamped to [0, 1].
- `Camera::append_begin_render_commands` (`render.rs`): Append camera begin-transform commands and return after extending output.
- `Camera::begin_render_commands` (`render.rs`): Build begin-transform command list and return it for immediate submission.
- `Camera::end_render_command` (`render.rs`): Return render command that restores transform stack after camera pass.
- `Camera::generate_render_commands` (`render.rs`): Wrap scene commands with camera begin/end transforms and return combined list.
- `Camera2D::append_begin_render_commands` (`render.rs`): Append 2D camera begin-transform commands and return after extending output.
- `Camera2D::begin_render_commands` (`render.rs`): Build 2D begin-transform command list and return it for submission.
- `Camera2D::end_render_command` (`render.rs`): Return render command that restores transform stack after 2D camera pass.
- `Camera2D::generate_render_commands` (`render.rs`): Wrap scene commands with 2D camera transforms and return combined list.
- `Camera::new` (`types.rs`): Create camera state and return it with provided transform values.
- `Camera::view_matrix` (`types.rs`): Build camera view matrix and return world-to-view transform.
- `Camera::set_position` (`types.rs`): Set camera position and return after replacing previous value.
- `Camera::set_zoom` (`types.rs`): Set camera zoom and return after replacing previous value.
- `Camera::set_rotation` (`types.rs`): Set camera rotation and return after replacing previous value.
- `Camera2D::new` (`types.rs`): Create 2D camera state and return it for the provided viewport size.
- `Camera2D::set_position` (`types.rs`): Set camera position from x/y values and return after update.
- `Camera2D::get_position` (`types.rs`): Read camera position and return (x, y).
- `Camera2D::set_zoom` (`types.rs`): Set zoom target and return after applying immediate mode when undamped.
- `Camera2D::get_zoom` (`types.rs`): Read current zoom value and return scalar zoom.
- `Camera2D::set_rotation` (`types.rs`): Set rotation target and return after applying immediate mode when undamped.
- `Camera2D::get_rotation` (`types.rs`): Read current rotation value and return radians.
- `Camera2D::set_follow_easing` (`types.rs`): Set follow easing mode and return after replacing previous mode.
- `Camera2D::get_follow_easing` (`types.rs`): Read follow easing mode and return selected easing enum.
- `Camera2D::set_zoom_constraints` (`types.rs`): Set zoom constraints and return after clamping current and target zoom.
- `Camera2D::get_zoom_constraints` (`types.rs`): Read zoom constraints and return (min, max) options.
- `Camera2D::set_zoom_damping` (`types.rs`): Set zoom damping coefficient and return after sync when damping is zero.
- `Camera2D::get_zoom_damping` (`types.rs`): Read zoom damping coefficient and return normalized damping value.
- `Camera2D::set_rotation_constraints` (`types.rs`): Set rotation constraints and return after clamping current and target rotation.
- `Camera2D::get_rotation_constraints` (`types.rs`): Read rotation constraints and return (min, max) options.
- `Camera2D::set_rotation_damping` (`types.rs`): Set rotation damping coefficient and return after sync when damping is zero.
- `Camera2D::get_rotation_damping` (`types.rs`): Read rotation damping coefficient and return normalized damping value.
- `Camera2D::preset_tight_follow` (`types.rs`): Apply tight-follow preset and return after updating follow parameters.
- `Camera2D::preset_cinematic_follow` (`types.rs`): Apply cinematic-follow preset and return after updating follow parameters.
- `Camera2D::preset_balanced_follow` (`types.rs`): Apply balanced-follow preset and return after updating follow parameters.
- `Camera2D::preset_aggressive_follow` (`types.rs`): Apply aggressive-follow preset and return after updating follow parameters.
- `Camera2D::on_window_resize` (`types.rs`): Resize viewport to window dimensions and return after clamping minimum size.
- `Camera2D::on_window_resize_scaled` (`types.rs`): Resize viewport using scale mode and return after applying computed transform.
- `Camera2D::set_viewport` (`types.rs`): Set viewport rectangle and return after replacing previous viewport.
- `Camera2D::get_viewport` (`types.rs`): Read viewport rectangle and return (x, y, w, h).
- `Camera2D::set_bounds` (`types.rs`): Set camera bounds rectangle and return after enabling bounds.
- `Camera2D::get_bounds` (`types.rs`): Read camera bounds and return rectangle tuple when bounds exist.
- `Camera2D::remove_bounds` (`types.rs`): Disable bounds constraint and return after clearing bounds.
- `Camera2D::has_bounds` (`types.rs`): Check bounds presence and return true when bounds are enabled.
- `Camera2D::move_by` (`types.rs`): Move camera by delta vector and return after updating position.
- `Camera2D::look_at` (`types.rs`): Set camera position directly to target coordinates and return.
- `Camera2D::to_world_coords` (`types.rs`): Convert screen coordinates to world coordinates and return mapped pair.
- `Camera2D::to_screen_coords` (`types.rs`): Convert world coordinates to screen coordinates and return mapped pair.
- `Camera2D::get_visible_area` (`types.rs`): Compute visible world rectangle and return (x, y, w, h).
- `Camera2D::set_dead_zone` (`types.rs`): Set dead-zone size and return after storing half-extents.
- `Camera2D::get_dead_zone` (`types.rs`): Read dead-zone size and return full extents when configured.
- `Camera2D::set_target` (`types.rs`): Set follow target and return after enabling target tracking.
- `Camera2D::get_target` (`types.rs`): Read follow target and return (x, y) when target exists.
- `Camera2D::clear_target` (`types.rs`): Disable target tracking and return after clearing target state.
- `Camera2D::set_follow_smooth` (`types.rs`): Set follow smoothing scalar and return after clamping to non-negative.
- `Camera2D::get_follow_smooth` (`types.rs`): Read follow smoothing scalar and return configured value.
- `Camera2D::set_look_ahead` (`types.rs`): Set look-ahead multiplier and return after replacing previous value.
- `Camera2D::get_look_ahead` (`types.rs`): Read look-ahead multiplier and return configured value.
- `Camera2D::shake` (`types.rs`): Start shake effect and return after configuring timer and intensity.
- `Camera2D::get_shake_offset` (`types.rs`): Read current shake offset and return (x, y).
- `Camera2D::update` (`types.rs`): Advance camera simulation and return after follow, bounds, shake, and damping updates.
- `Camera2D::effective_zoom` (`types.rs`): Read zoom including active effects and return effective zoom value.
- `Camera2D::effect_offset` (`types.rs`): Read active effect offset and return sway contribution tuple.
- `Camera2D::render_offset` (`types.rs`): Read render offset and return sum of sway and shake offsets.
- `Camera2D::view_matrix` (`types.rs`): Build view matrix from camera state and return world-to-view transform.
- `ScaleMode::compute_transforms` (`viewport.rs`): Compute scale and offset transforms and return (sx, sy, ox, oy).
- `Viewport::new` (`viewport.rs`): Create viewport state and return it with identity scaling.
- `Viewport::resize` (`viewport.rs`): Recompute scale and offsets from window size and return after updating state.
- `Viewport::get_scale` (`viewport.rs`): Read current scale factors and return (scale_x, scale_y).
- `Viewport::get_offset` (`viewport.rs`): Read current screen offsets and return (offset_x, offset_y).
- `Viewport::get_game_dimensions` (`viewport.rs`): Read configured game dimensions and return (width, height).
- `Viewport::get_scale_mode` (`viewport.rs`): Read active scale mode and return immutable reference to mode.
- `Viewport::set_scale_mode` (`viewport.rs`): Set active scale mode and return after replacing previous mode.
- `Viewport::to_game` (`viewport.rs`): Convert screen coordinates to game coordinates and return mapped pair.
- `Viewport::to_screen` (`viewport.rs`): Convert game coordinates to screen coordinates and return mapped pair.
- `ViewportScale::new` (`viewport_scale.rs`): Create viewport scale state and return it with identity transforms.
- `ViewportScale::resize` (`viewport_scale.rs`): Recompute transforms from window dimensions and return after updating fields.
- `ViewportScale::get_game_dimensions` (`viewport_scale.rs`): Read logical game dimensions and return (width, height).
- `ViewportScale::get_scaled_dimensions` (`viewport_scale.rs`): Read scaled dimensions and return (scaled_width, scaled_height).
- `ViewportScale::get_offset` (`viewport_scale.rs`): Read viewport offset and return (offset_x, offset_y).
- `ViewportScale::get_scale` (`viewport_scale.rs`): Read scale factors and return (scale_x, scale_y).
- `ViewportScale::get_mode` (`viewport_scale.rs`): Read active scale mode and return immutable reference to it.
- `ViewportScale::to_game_coords` (`viewport_scale.rs`): Convert screen coordinates into game-space coordinates and return mapped pair.
- `ViewportScale::to_screen_coords` (`viewport_scale.rs`): Convert game coordinates into screen-space coordinates and return mapped pair.

## Lua API Reference

- Binding path(s): `src/lua_api/camera_api.rs`
- Namespace: `lurek.camera`

### Module Functions
- `lurek.camera.new`: Creates a 2D camera with optional virtual viewport size.
- `lurek.camera.newCamera`: Creates a 2D camera with optional virtual viewport size.
- `lurek.camera.newRig`: Creates an empty named camera rig. This function is exposed to Lua scripts.

### `LCamera` Methods
- `LCamera:setPosition`: Sets the camera world position. This method is available to Lua scripts.
- `LCamera:getPosition`: Returns the camera world position.
- `LCamera:setZoom`: Sets the camera zoom factor. This method is available to Lua scripts.
- `LCamera:getZoom`: Returns the camera zoom factor. This method is available to Lua scripts.
- `LCamera:setRotation`: Sets the camera rotation. This method is available to Lua scripts.
- `LCamera:getRotation`: Returns the camera rotation. This method is available to Lua scripts.
- `LCamera:setViewport`: Sets the camera viewport rectangle.
- `LCamera:getViewport`: Returns the camera viewport rectangle.
- `LCamera:getBounds`: Returns camera bounds with a leading availability flag.
- `LCamera:hasBounds`: Returns whether camera bounds are active.
- `LCamera:setBounds`: Sets camera world bounds. This method is available to Lua scripts.
- `LCamera:removeBounds`: Removes active camera bounds. This method is available to Lua scripts.
- `LCamera:setTarget`: Sets a world-space follow target. This method is available to Lua scripts.
- `LCamera:getTarget`: Returns the follow target with a leading availability flag.
- `LCamera:clearTarget`: Clears the follow target. This method is available to Lua scripts.
- `LCamera:setFollowSmooth`: Sets follow smoothing speed. This method is available to Lua scripts.
- `LCamera:getFollowSmooth`: Returns follow smoothing speed. This method is available to Lua scripts.
- `LCamera:setFollowEasing`: Sets target follow easing mode. This method is available to Lua scripts.
- `LCamera:getFollowEasing`: Returns target follow easing mode.
- `LCamera:setDeadZone`: Sets follow dead-zone dimensions.
- `LCamera:getDeadZone`: Returns follow dead-zone dimensions with a leading availability flag.
- `LCamera:setLookAhead`: Sets follow look-ahead multiplier.
- `LCamera:getLookAhead`: Returns follow look-ahead multiplier.
- `LCamera:onWindowResize`: Updates camera viewport state after a window resize.
- `LCamera:onWindowResizeScaled`: Updates camera viewport state using a virtual game size and scale mode.
- `LCamera:shake`: Starts a camera shake effect. This method is available to Lua scripts.
- `LCamera:update`: Advances camera follow, shake, and effect state.
- `LCamera:toWorld`: Converts screen coordinates to world coordinates.
- `LCamera:toScreen`: Converts world coordinates to screen coordinates.
- `LCamera:getVisibleArea`: Returns the world-space area visible through this camera.
- `LCamera:lookAt`: Centers the camera on a world position.
- `LCamera:move`: Moves the camera by a delta. This method is available to Lua scripts.
- `LCamera:followPath`: Starts camera movement along an array of waypoint tables.
- `LCamera:stopPath`: Stops the active camera path. This method is available to Lua scripts.
- `LCamera:updatePath`: Advances the active camera path and applies its position.
- `LCamera:pathProgress`: Returns active path progress. This method is available to Lua scripts.
- `LCamera:zoomTo`: Starts a zoom tween toward a target zoom factor.
- `LCamera:stopZoom`: Stops the active zoom tween. This method is available to Lua scripts.
- `LCamera:updateZoom`: Advances the active zoom tween and applies its zoom value.
- `LCamera:setParallaxFactor`: Sets a parallax factor for a named layer.
- `LCamera:getParallaxFactor`: Returns a parallax factor for a named layer.
- `LCamera:clearParallaxFactors`: Clears all layer parallax factor overrides.
- `LCamera:apply`: Appends render commands that apply this camera transform.
- `LCamera:reset`: Appends a render command that removes the active camera transform.
- `LCamera:attach`: Appends render commands that attach this camera transform.
- `LCamera:detach`: Appends a render command that detaches the active camera transform.
- `LCamera:zoomPulse`: Triggers a temporary zoom pulse effect.
- `LCamera:startSway`: Starts camera sway offset animation.
- `LCamera:stopSway`: Stops camera sway offset animation.
- `LCamera:isSway`: Returns whether camera sway is active.
- `LCamera:startBreathing`: Starts subtle breathing zoom animation.
- `LCamera:stopBreathing`: Stops breathing zoom animation. This method is available to Lua scripts.
- `LCamera:isBreathing`: Returns whether breathing zoom animation is active.
- `LCamera:getEffectiveZoom`: Returns zoom after camera effects are applied.
- `LCamera:getEffectOffset`: Returns combined camera effect offset.
- `LCamera:getShakeOffset`: Returns current camera shake offset.
- `LCamera:getRenderOffset`: Returns current render offset after camera effects.
- `LCamera:setZoomConstraints`: Sets optional minimum and maximum zoom constraints.
- `LCamera:getZoomConstraints`: Returns zoom constraints with availability flags.
- `LCamera:setZoomDamping`: Sets zoom damping. This method is available to Lua scripts.
- `LCamera:getZoomDamping`: Returns zoom damping. This method is available to Lua scripts.
- `LCamera:setRotationConstraints`: Sets optional minimum and maximum rotation constraints.
- `LCamera:getRotationConstraints`: Returns rotation constraints with availability flags.
- `LCamera:setRotationDamping`: Sets rotation damping. This method is available to Lua scripts.
- `LCamera:getRotationDamping`: Returns rotation damping. This method is available to Lua scripts.
- `LCamera:presetTightFollow`: Applies the tight follow camera preset.
- `LCamera:presetCinematicFollow`: Applies the cinematic follow camera preset.
- `LCamera:presetBalancedFollow`: Applies the balanced follow camera preset.
- `LCamera:presetAggressiveFollow`: Applies the aggressive follow camera preset.
- `LCamera:type`: Returns the Lua-visible type name for this camera handle.
- `LCamera:typeOf`: Returns whether this camera handle matches a supported type name.

### `LCameraRig` Methods
- `LCameraRig:splitScreen`: Applies a split-screen layout using the current window size.
- `LCameraRig:minimap`: Applies a minimap layout using the current window size and optional ratio.
- `LCameraRig:pictureInPicture`: Applies a picture-in-picture layout using optional inset size.
- `LCameraRig:setPosition`: Sets the position of a named rig camera, creating it if needed.
- `LCameraRig:setZoom`: Sets the zoom of a named rig camera, creating it if needed.
- `LCameraRig:setTarget`: Sets the follow target of a named rig camera, creating it if needed.
- `LCameraRig:updateAll`: Advances every camera in this rig. This method is available to Lua scripts.
- `LCameraRig:apply`: Appends render commands for a named camera in this rig.
- `LCameraRig:getViewport`: Returns a named rig camera viewport with a leading availability flag.
- `LCameraRig:names`: Returns all camera names in this rig.
- `LCameraRig:remove`: Removes a named camera from this rig.
- `LCameraRig:has`: Returns whether this rig contains a named camera.
- `LCameraRig:type`: Returns the Lua-visible type name for this camera rig handle.
- `LCameraRig:typeOf`: Returns whether this camera rig handle matches a supported type name.

## References

- `math`: Imports or references `math` from `src/math/`.
- `render`: Imports or references `render` from `src/render/`.

## Notes

- Keep this module reference synchronized with `src/camera/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
