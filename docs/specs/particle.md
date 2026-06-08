# particle

## TL;DR

- Simulates pooled particles with rich shapes, gravity forces, and collider bounces.
- Supports keyframe curves, tapered ribbon trails, sub-emitters, and diagnostic images.

## General Info

- Module group: `Feature Systems`
- Source path: `src/particle/`
- Binding: `src/lua_api/particle_api.rs`
- Namespace: `lurek.particle`
- Lua API surface: `5` functions, `3` types, `105` methods
- Rust test path(s): tests/rust/unit/particle_tests.rs
- Lua test path(s): tests/lua/unit/test_particle.lua, tests/lua/stress/test_particle_stress.lua, tests/lua/integration/test_particle_timer.lua, tests/lua/evidence/test_evidence_particle.lua

## Summary

- This module gives users a high-volume particle simulation system for gameplay VFX and atmospheric effects.
- Pool-based runtime management keeps large particle counts efficient and stable.
- Emitters support continuous, burst, and warm-up driven spawning patterns.
- Shape controls support varied spawn distributions, including custom callback-defined emission.
- Force models include gravity, drag, turbulence, orbit, and attractor behavior.
- Bounce and bounds controls shape movement within scene constraints.
- Keyframe-driven color, alpha, and size interpolation support expressive lifetime animation.
- Trail systems provide ribbon-style motion accents for fast-moving effects.
- Sub-emitter support enables chained effects like secondary bursts on particle death.
- Physics collision integration supports particle responses to world colliders.
- Preset constructors speed up authoring for common effects such as fire, smoke, and rain.
- Render paths support textured and non-textured particle output.
- Debug draw-to-image tools help tune effects and capture evidence artifacts.
- Lifecycle chart output improves observability of spawn and decay dynamics.
- The module is useful for combat impacts, weather, ambient motion, and UI accents.
- For users, it centralizes particle behavior rather than scattering custom emitter logic.
- It balances artistic flexibility with deterministic, test-friendly controls.
- Overall, users get a production-ready VFX runtime in one script API.
- This enables richer scenes with less effect-specific boilerplate.

## Imports

- `color`: Imports or references `src/color/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `image`: Imports or references `image` from `src/image/`.
- `math`: Imports or references `math` from `src/math/`.
- `physics`: Imports or references `src/physics/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### config.rs

- Runtime configuration for particle emitters and their tunable behavior.
- Carries spawn distribution, insertion order, state, and coordinate mode settings.
- Describes emission shapes from point and circle to cone, star, spiral, and custom callbacks.
- Includes attractor and bounce helper types for motion control.
- Covers world-space versus emitter-attached spawning rules.
- Packs every serializable knob into one config object for scripts and data files.
- Serves as the authored contract for building particle systems.

### emission.rs

- Spawn-offset sampling for particle emission shapes and area distributions.
- Supports uniform, normal, ellipse, border, rectangle, ring, cone, star, and spiral modes.
- Handles area-angle rotation so emitted particles respect the configured shape.
- Keeps emission math separate from the particle runtime.
- Supplies the offset generator used by emitters and presets.

### emitter.rs

- Live particle emitter that owns the active particle pool, physics stepping, and sub-system list.
- Integrates gravity, drag, orbit, turbulence, and other per-frame forces.
- Spawns particles continuously or in bursts using fractional accumulation and ordered insertion modes.
- Applies attractors and axis-aligned bounce boundaries to active particles.
- Runs child emitters on particle death when sub-systems are configured.
- Tracks active, paused, and stopped states with lifetime-based auto-stop.
- Builds render commands from current particle state, shape mapping, and interpolation curves.
- Supports warm-up simulation so systems can start in a settled state.
- Exposes custom emission-shape callbacks through the Lua bridge without coupling spawn math to rendering.
- Provides the runtime core for all particle effects.

### math.rs

- Keyframe interpolation for particle size, colour, and alpha over normalized lifetime.
- Offers uniform and normal random helpers for emission variance.
- Clamps interpolation inputs and falls back cleanly on empty keyframe sets.
- Supports the numeric shaping layer used by emitter animation.

### mod.rs

- Particle emitter lifecycle for spawn, simulation, and pooled recycling.
- Collects emission, physics, trail, rendering, and preset helpers under one namespace.
- Keeps particle effects modular while exposing a single runtime surface.

### particle.rs

- Per-particle runtime state for position, velocity, lifetime, rotation, and acceleration.
- Stores spawn origin and shape seed for force calculations and deterministic geometry.
- Keeps the minimum state needed by the emitter loop.

### physics_collision.rs

- Bounce particles off rapier colliders using AABB overlap probes.
- Reflects velocity with configurable restitution per collision pass.
- Operates on all live particles in a system each frame.

### presets.rs

- Ready-made ParticleConfig constructors for common visual effects.
- Covers fire, smoke, rain, snow, sparks, and other standard patterns.
- Returns self-contained configs with tuned lifetime, speed, color ramp, and shape.
- Lets callers start from a stable preset and override fields afterward.
- Makes quick particle authoring simple without hiding the underlying config.

### render.rs

- Render-command generation for particle systems and trails.
- Expands textured particle batches into individual draw calls when needed.
- Keeps untextured particles batched for efficiency.
- Bridges live particle state to renderer submission.

### shapes.rs

- Geometric shape primitives that control how individual particles are rendered.
- Covers fills, directional shapes, and composite outlines with inline parameters.
- Gives emitters a compact vocabulary for particle silhouette design.

### trail.rs

- Ribbon trail built from a deque of aged world-space points.
- Retires points automatically when they exceed the configured lifetime.
- Tapers width and interpolates color from head to tail.
- Can render as triangle-strip commands or as a CPU-rasterized image.
- Provides a lightweight motion trail for fast effects and debug views.

### visualization.rs

- Particle visualization helpers that render live ParticleSystem state to ImageData bitmaps.
- Includes a generic renderer plus themed presets for explosions, rain, and spark trails.
- Supports compositing particles over an existing background or painting in place.
- Adds a chart-style lifetime view for inspecting particle counts over time.
- Keeps render inspection separate from the particle simulation core.
- Helps debug effect tuning without touching the live emitter loop.

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
