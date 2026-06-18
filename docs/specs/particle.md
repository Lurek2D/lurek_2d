# particle

## TL;DR

- Simulates pooled particles with rich shapes, gravity forces, and collider bounces.
- Supports keyframe curves, tapered ribbon trails, sub-emitters, and diagnostic images.

## General Info

- Module group: `Feature Systems`
- Source path: `src/particle/`
- Binding: `src/lua_api/particle_api.rs`
- Namespace: `lurek.particle`
- Lua API surface: `5` functions, `3` types, `106` methods
- Rust test path(s): tests/rust/unit/particle_tests.rs
- Lua test path(s): tests/lua/unit/test_particle_unit.lua, tests/lua/stress/test_particle_stress.lua, tests/lua/integration/test_particle_timer_integration.lua, tests/lua/evidence/test_particle_evidence.lua

## Summary

- The `particle` module is the pooled visual-effects system for users who want smoke, sparks, rain, trails, bursts, and other transient visuals to behave like one reusable runtime feature.
- Emitters, particle state, force application, lifetimes, presets, trails, and render bridges all live together here, so effects can be authored as configurations instead of one-off update loops.
- Pooling is central to the design because short-lived effects appear in large numbers and need predictable reuse instead of constant allocation churn.
- Emission rules, spawn shapes, attractors, turbulence, and per-particle lifetime state give the module enough range to cover both ambient effects and gameplay feedback.
- Per-particle state is not only position and color. Lifetime, velocity, size evolution, rotation, and other update-time values determine how an effect feels over time and are part of the same runtime model.
- Sub-emitters, trails, and simple collision hooks matter because many practical effects need layered motion and lightweight grounding in world space.
- Force handling is especially important because many effects are really motion systems: wind, gravity-like influence, turbulence, and attractors all shape how a burst reads to the player.
- Spawn-shape variety matters too, since emitters often need circles, lines, cones, boxes, or directional releases rather than a single point source.
- Presets and visualization support make the system useful for iteration, docs, tests, and content authoring as well as for final shipped visuals.
- Reusable presets keep effects expressive without letting transient visuals sprawl into dozens of bespoke mini-systems.
- The module is useful for combat hits, weather, ambience, UI flourishes, projectiles, and other procedural or semi-procedural effect workflows.
- `render` draws the result and `physics` may inform light collision behavior, but `particle` owns effect spawning, pooled update logic, and transient visual behavior over time.
- Read `particle` as the subsystem that decides how short-lived procedural effects are described, updated, reused, and inspected.


## Imports

- `color`: Imports or references `src/color/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `image`: Imports or references `image` from `src/image/`.
- `math`: Imports or references `math` from `src/math/`.
- `physics`: Imports or references `src/physics/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### config.rs

- This file owns the particle configuration schema, including emission rates, lifetimes, forces, shapes, and sub-emitters.
- It defines enums and helper structs for area distribution, insert order, emitter state, spawn shapes, and relative mode.
- `ParticleConfig` centralizes every serializable knob so scripts and data files can describe one emitter without code.
- Sanitization lives here because malformed inputs must be clamped before the emitter update loop consumes them.
- Default values also live here so callers get a stable fountain-like baseline even when configs omit most fields.
- Shape-specific normalization for rings, rays, shrapnel, and nested death emitters is handled here, not during rendering.
- `from_toml_str` and `normalized` make this file the boundary between external config text and runtime-safe values.
- Open it when option semantics change; spawning, pool simulation, and render-command generation live elsewhere.

### emission.rs

- This file owns spawn-offset sampling for particle emission areas and explicit emission shapes like circles and stars.
- `emission_offset` handles area distributions and area rotation, while `emission_shape_offset` handles shape geometry.
- Uniform, normal, ellipse, border, cone, spiral, and star sampling live here so emitters reuse one spawn policy.
- No particle pool state is stored here; the file is pure geometry and RNG mapping used during emitter spawn steps.
- Open it when spawn distributions change; emitter integration and config ownership live in sibling particle files.

### emitter.rs

- This file owns `ParticleSystem`, the live particle pool plus emitter timers, attractors, bounds, and child sub-systems.
- It advances particles each frame by applying gravity, damping, orbit, turbulence, attractors, bounce bounds, and decay.
- Continuous emission and burst spawning live here because fractional accumulation, insert mode, and RNG mutate state.
- Death handling also lives here, including pending death records, recycled child systems, and death-emitter bursts.
- Render-instance construction is local because size, color, texture, and shape all derive from live particle state.
- State transitions for active, paused, and stopped emitters are managed here with warm-up, reset, and movement helpers.
- Attractor and bounds mutators stay here so callers change runtime forces without reaching into particle internals.
- `ParticleSystemStats` also lives here because only this file can summarize direct and nested live counts coherently.
- Open it when pool ownership or per-frame behavior changes; config schema, spawn math, and previews live elsewhere.

### math.rs

- This file owns particle interpolation and deterministic random helpers used by emission and per-particle animation math.
- It reexports `lerp`, advances the local PRNG, and provides uniform, normal, and ranged random sampling utilities.
- Size, color, and alpha interpolation live here so emitter updates and visualizers share one lifetime-evaluation policy.
- Fallback and clamping behavior are defined here to keep malformed configs from destabilizing particle playback.
- Open it when numeric sampling or keyframe interpolation changes; emitter state and config schema live in sibling files.

### mod.rs

- This module is the particle index, wiring emitter state, config contracts, spawn math, rendering, trails, and presets.
- It reexports `ParticleSystem`, `ParticleConfig`, shapes, trails, interpolation helpers, and the core `Particle` record.
- `emitter.rs` owns live pool updates, `config.rs` owns tunables, and `render.rs` bridges particle state to commands.
- `emission.rs`, `math.rs`, and `shapes.rs` provide reusable spawn and interpolation primitives shared across emitters.
- `trail.rs`, `visualization.rs`, and `physics_collision.rs` cover ribbons, debug images, and world bounce integration.
- This file owns visibility and navigation only; simulation rules and data ownership stay in sibling implementation files.

### particle.rs

- This file owns the per-particle runtime record storing motion, lifetime, rotation, and spawn-relative acceleration data.
- `Particle` is the mutable unit consumed by the emitter loop, render interpolation, and collision or trail helpers.
- Open it when particle field semantics change; pool management, spawning, and rendering behavior live in siblings.

### physics_collision.rs

- This file owns the simple particle-to-world bounce bridge that probes Rapier AABBs and reflects particle velocities.
- It reads `ParticleSystem` positions plus the physics `World`, then applies restitution and a small hit separation step.
- Open it when particle/world collision policy changes; emitter integration and general physics ownership live elsewhere.

### presets.rs

- This file owns ready-made `ParticleConfig` constructors for common effects such as fire, smoke, rain, snow, and sparks.
- Each function returns a fully populated config with tuned lifetimes, speeds, colors, sizes, and emission shapes.
- The presets are data-oriented so callers can clone them and override fields without touching emitter internals.
- No live particle state is stored here; this file is the catalog layer for reusable effect starting points.
- Open it when shared effect defaults change; config schema and emitter execution live in sibling files.

### render.rs

- This file owns the renderer bridge that turns particle systems and trails into engine `RenderCommand` values.
- It exposes helpers on `ParticleSystem` and `Trail`, then expands textured batches into quad or image draw commands.
- Untextured particles remain batched here so the adapter preserves renderer efficiency without changing emitter state.
- Open it when particle command translation changes; pool updates, preview images, and config ownership live elsewhere.

### shapes.rs

- This file owns the `ParticleShape` enum that describes how a single particle should be drawn by the renderer.
- It keeps square, circle, spark, shrapnel, ray, ring, and capsule variants with the parameters each shape needs.
- Open it when particle silhouette vocabulary changes; emitter logic and render-command expansion live in sibling files.

### trail.rs

- This file owns ribbon trails built from aged world-space points, including width taper, color fade, and age cleanup.
- `Trail` stores the live point list plus width, colors, and minimum distance rules that suppress redundant samples.
- Update and push helpers live here because trail aging and head insertion are independent from particle pool ownership.
- The file also builds triangle ribbon commands and a simple image preview, keeping trail rendering beside trail geometry.
- Open it when ribbon behavior changes; generic particle rendering and emitter simulation live in sibling files.

### visualization.rs

- This file owns bitmap visualization helpers that render `ParticleSystem` state into `ImageData` for previews and debug.
- It includes generic previews plus themed explosion, rain, spark, overlay, paint, and lifecycle chart renderers.
- Color, alpha, and size interpolation are reused here so debug output matches the runtime particle config semantics.
- The functions are intentionally read-only over `ParticleSystem`, with no authority to spawn, kill, or reorder particles.
- Lifecycle chart drawing also lives here because it is an inspection surface rather than part of the renderer bridge.
- Open it when particle preview imagery changes; pool simulation and render-command batching live in sibling files.



## Lua API Ref

### Functions

- `lurek.particle.drawLifecycleToImage(snapshots, max_particles, w, h) -> LImageData`: Draws a lifecycle chart image from `(step, count)` snapshot tables.
- `lurek.particle.fromTOML(path) -> LParticleSystem`: Creates a particle system from a TOML config file.
- `lurek.particle.newPreset(name) -> LParticleSystem`: Creates a particle system from a named preset.
- `lurek.particle.newSystem(config?) -> LParticleSystem`: Creates a particle system from an optional config table.
- `lurek.particle.newTrail(lifetime, start_width) -> LTrail`: Creates a trail effect. This function is exposed to Lua scripts.

### Callbacks

- `LParticleSystem:setCustomEmissionShape` param `cb` (`function`): Callback returning an x/y position.
- `LParticleSystem:setOnDeathBatch` param `cb` (`function`): Death batch callback.

### Enums

- No documented module-level enums/constants.

### Types

#### LParticleSystem Type

- Lua-side handle for a particle system stored in shared runtime state.

##### Fields

- No documented fields.

##### Methods

- `LParticleSystem:addAttractor(x, y, strength, radius) -> nil`: Adds an attractor to the particle system.
- `LParticleSystem:addSubEmitter(config_tbl, burst_count?) -> nil`: Configures a death sub-emitter from a config table.
- `LParticleSystem:addSubSystem(config_tbl) -> integer`: Adds a particle sub-system from a config table.
- `LParticleSystem:clearAttractors() -> nil`: Clears all attractors on this object.
- `LParticleSystem:clearBounds() -> nil`: Clears collision bounds on this object.
- `LParticleSystem:clearCollidesWithPhysics() -> nil`: Disables particle collision against a physics world.
- `LParticleSystem:clone() -> LParticleSystem`: Clones this particle system configuration into a new system handle.
- `LParticleSystem:count() -> integer`: Returns the current particle count.
- `LParticleSystem:drawExplosionToImage(w, h) -> LImageData`: Draws particles as an explosion preview image.
- `LParticleSystem:drawOverImage(image) -> LImageData`: Draws particles over an existing image and returns a composited copy.
- `LParticleSystem:drawRainToImage(w, h) -> LImageData`: Draws particles as a rain preview image.
- `LParticleSystem:drawSparkTrailToImage(w, h) -> LImageData`: Draws particles as a spark-trail preview image.
- `LParticleSystem:drawToImage(w, h) -> LImageData`: Draws particles to image data. This method is available to Lua scripts.
- `LParticleSystem:emit(count) -> nil`: Emits particles immediately. This method is available to Lua scripts.
- `LParticleSystem:getAttractorCount() -> integer`: Returns attractor count. This method is available to Lua scripts.
- `LParticleSystem:getBufferSize() -> integer`: Returns maximum particle buffer size.
- `LParticleSystem:getColors() -> table`: Returns particle color keyframes.
- `LParticleSystem:getCount() -> integer`: Returns particle count and errors if the handle was released.
- `LParticleSystem:getDirection() -> number`: Returns emission direction. This method is available to Lua scripts.
- `LParticleSystem:getEmissionArea() -> string`: Returns emission area distribution and size.
- `LParticleSystem:getEmissionRate() -> number`: Returns emission rate. This method is available to Lua scripts.
- `LParticleSystem:getEmitterLifetime() -> number`: Returns emitter lifetime. This method is available to Lua scripts.
- `LParticleSystem:getFlipbook() -> integer`: Returns flipbook grid and frame rate when configured.
- `LParticleSystem:getGravity() -> number`: Returns particle gravity. This method is available to Lua scripts.
- `LParticleSystem:getInsertMode() -> string`: Returns particle insert mode. This method is available to Lua scripts.
- `LParticleSystem:getLinearAcceleration() -> number`: Returns linear acceleration range.
- `LParticleSystem:getLinearDamping() -> number`: Returns linear damping range. This method is available to Lua scripts.
- `LParticleSystem:getOffset() -> number`: Returns particle spawn offset. This method is available to Lua scripts.
- `LParticleSystem:getParticleLifetime() -> number`: Returns particle lifetime range. This method is available to Lua scripts.
- `LParticleSystem:getPosition() -> number`: Returns emitter position. This method is available to Lua scripts.
- `LParticleSystem:getRadialAcceleration() -> number`: Returns radial acceleration range.
- `LParticleSystem:getRotation() -> number`: Returns particle rotation range. This method is available to Lua scripts.
- `LParticleSystem:getShape() -> string`: Returns particle shape. This method is available to Lua scripts.
- `LParticleSystem:getSizeVariation() -> number`: Returns size variation. This method is available to Lua scripts.
- `LParticleSystem:getSizes() -> number[]`: Returns particle size keyframes. This method is available to Lua scripts.
- `LParticleSystem:getSpeed() -> number`: Returns particle speed range. This method is available to Lua scripts.
- `LParticleSystem:getSpin() -> number`: Returns particle spin range. This method is available to Lua scripts.
- `LParticleSystem:getSpinVariation() -> number`: Returns spin variation. This method is available to Lua scripts.
- `LParticleSystem:getSpread() -> number`: Returns emission spread. This method is available to Lua scripts.
- `LParticleSystem:getStats() -> table`: Returns a telemetry snapshot for dashboard and debug workflows.
- `LParticleSystem:getTangentialAcceleration() -> number`: Returns tangential acceleration range.
- `LParticleSystem:hasCollidesWithPhysics() -> boolean`: Returns whether particle physics collision is enabled.
- `LParticleSystem:hasRelativeRotation() -> boolean`: Returns whether relative rotation is enabled.
- `LParticleSystem:isActive() -> boolean`: Returns whether the particle system is active.
- `LParticleSystem:isEmpty() -> boolean`: Returns whether the particle system has no particles or is missing.
- `LParticleSystem:isFull() -> boolean`: Returns whether the particle system has reached capacity.
- `LParticleSystem:isPaused() -> boolean`: Returns whether the particle system is paused.
- `LParticleSystem:isStopped() -> boolean`: Returns whether the particle system is stopped or missing.
- `LParticleSystem:moveTo(x, y) -> nil`: Moves the particle emitter. This method is available to Lua scripts.
- `LParticleSystem:paintOnto(image) -> nil`: Paints live particles directly onto an existing image in place.
- `LParticleSystem:pause() -> nil`: Pauses particle emission and updates.
- `LParticleSystem:release() -> boolean`: Releases the particle system from shared storage.
- `LParticleSystem:render(ox?, oy?) -> nil`: Enqueues particle render commands with an optional offset.
- `LParticleSystem:reset() -> nil`: Resets particles and emitter state.
- `LParticleSystem:resume() -> nil`: Resumes a paused particle system if it was previously paused.
- `LParticleSystem:setBounds(xmin, xmax, ymin, ymax, restitution) -> nil`: Sets collision bounds for particles.
- `LParticleSystem:setBufferSize(n) -> nil`: Sets maximum particle buffer size.
- `LParticleSystem:setCollidesWithPhysics(world_ud, probe_radius?, restitution?) -> nil`: Enables particle collision against a physics world.
- `LParticleSystem:setColors(...) -> nil`: Sets particle color keyframes from one or more RGBA tables.
- `LParticleSystem:setCustomEmissionShape(cb) -> nil`: Sets a Lua callback for custom emission positions.
- `LParticleSystem:setDirection(dir) -> nil`: Sets emission direction. This method is available to Lua scripts.
- `LParticleSystem:setEmissionArea(dist, w, h, angle?, dir_rel?) -> nil`: Sets emission area distribution and size.
- `LParticleSystem:setEmissionRate(rate) -> nil`: Sets emission rate. This method is available to Lua scripts.
- `LParticleSystem:setEmitterLifetime(t) -> nil`: Sets emitter lifetime. This method is available to Lua scripts.
- `LParticleSystem:setFlipbook(cols, rows, fps) -> nil`: Sets flipbook grid and frame rate. This method is available to Lua scripts.
- `LParticleSystem:setGravity(gx, gy) -> nil`: Sets particle gravity. This method is available to Lua scripts.
- `LParticleSystem:setInsertMode(mode) -> nil`: Sets particle insert mode. This method is available to Lua scripts.
- `LParticleSystem:setLinearAcceleration(xmin, ymin, xmax, ymax) -> nil`: Sets linear acceleration range. This method is available to Lua scripts.
- `LParticleSystem:setLinearDamping(min, max) -> nil`: Sets linear damping range. This method is available to Lua scripts.
- `LParticleSystem:setOffset(ox, oy) -> nil`: Sets particle spawn offset. This method is available to Lua scripts.
- `LParticleSystem:setOnDeathBatch(cb) -> nil`: Sets a Lua callback invoked with batched particle death records.
- `LParticleSystem:setParticleLifetime(min, max) -> nil`: Sets particle lifetime range. This method is available to Lua scripts.
- `LParticleSystem:setPosition(x, y) -> nil`: Sets emitter position. This method is available to Lua scripts.
- `LParticleSystem:setRadialAcceleration(min, max) -> nil`: Sets radial acceleration range. This method is available to Lua scripts.
- `LParticleSystem:setRelativeRotation(v) -> nil`: Sets whether particle rotation is relative to movement.
- `LParticleSystem:setRotation(min, max) -> nil`: Sets particle rotation range. This method is available to Lua scripts.
- `LParticleSystem:setShape(shape) -> nil`: Sets particle shape. This method is available to Lua scripts.
- `LParticleSystem:setSizeVariation(v) -> nil`: Sets size variation. This method is available to Lua scripts.
- `LParticleSystem:setSizes(...) -> nil`: Sets the particle size keyframes used during a particle's lifetime. Pass two or more values to interpolate between them.
- `LParticleSystem:setSpeed(min, max) -> nil`: Sets particle speed range. This method is available to Lua scripts.
- `LParticleSystem:setSpin(min, max) -> nil`: Sets particle spin range. This method is available to Lua scripts.
- `LParticleSystem:setSpinVariation(v) -> nil`: Sets spin variation. This method is available to Lua scripts.
- `LParticleSystem:setSpread(spread) -> nil`: Sets emission spread. This method is available to Lua scripts.
- `LParticleSystem:setTangentialAcceleration(min, max) -> nil`: Sets tangential acceleration range for emitted particles.
- `LParticleSystem:start() -> nil`: Starts particle emission on this object.
- `LParticleSystem:stop() -> nil`: Stops particle emission on this object.
- `LParticleSystem:subSystemCount() -> integer`: Returns particle sub-system count.
- `LParticleSystem:toImage(w, h) -> LImageData`: Draws particles to image data. This method is available to Lua scripts.
- `LParticleSystem:type() -> string`: Returns the Lua-visible type name for this particle system handle.
- `LParticleSystem:typeOf(name) -> boolean`: Returns whether this particle system handle matches a supported type name.
- `LParticleSystem:update(dt) -> nil`: Updates the particle system, applies optional physics collision, and invokes pending callbacks.
- `LParticleSystem:warmUp(seconds) -> nil`: Advances the system by a warm-up duration.

#### LParticleSystemGetColorsResult Type

- Generated result shape from @field tags.

##### Fields

- `a` (`number`): Alpha component.
- `b` (`number`): Blue component.
- `g` (`number`): Green component.
- `r` (`number`): Red component.

##### Methods

- No documented methods.

#### LTrail Type

- Lua-side wrapper for a trail effect.

##### Fields

- No documented fields.

##### Methods

- `LTrail:clear() -> nil`: Clears all trail points on this object.
- `LTrail:drawToImage(w, h) -> LImageData`: Draws the trail to image data. This method is available to Lua scripts.
- `LTrail:getLifetime() -> number`: Returns trail point lifetime. This method is available to Lua scripts.
- `LTrail:getPointCount() -> integer`: Returns trail point count. This method is available to Lua scripts.
- `LTrail:getWidth() -> number`: Returns trail width settings from this object.
- `LTrail:pushPoint(x, y) -> nil`: Adds a point to the trail. This method is available to Lua scripts.
- `LTrail:setHeadColor(r, g, b, a) -> nil`: Sets the color of the leading edge of the trail.
- `LTrail:setLifetime(lifetime) -> nil`: Sets trail point lifetime. This method is available to Lua scripts.
- `LTrail:setMinDistance(distance) -> nil`: Sets minimum distance between trail points.
- `LTrail:setTailColor(r, g, b, a) -> nil`: Sets the color of the trailing edge of the trail.
- `LTrail:setWidth(start, end?) -> nil`: Sets trail start and optional end width.
- `LTrail:type() -> string`: Returns the Lua-visible type name for this trail handle.
- `LTrail:typeOf(name) -> boolean`: Returns whether this trail handle matches a supported type name.
- `LTrail:update(dt) -> nil`: Updates trail point lifetimes. This method is available to Lua scripts.

## References

- `color`: Imports or references `src/color/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `image`: Imports or references `image` from `src/image/`.
- `math`: Imports or references `math` from `src/math/`.
- `physics`: Imports or references `src/physics/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- No additional module-specific notes.
