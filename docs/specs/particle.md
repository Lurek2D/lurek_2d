# particle

## TL;DR

- The `particle` module is a powerful Feature Systems tier component that provides comprehensive, emitter-based 2D particle systems for Lurek2D.

## General Info

- Module group: `Feature Systems`
- Source path: `src/particle/`
- Lua API path(s): `src/lua_api/particle_api.rs`
- Primary Lua namespace: `lurek.particle`
- Rust test path(s): tests/rust/unit/particle_tests.rs
- Lua test path(s): tests/lua/unit/test_particle.lua, tests/lua/stress/test_particle_stress.lua, tests/lua/integration/test_particle_timer.lua, tests/lua/evidence/test_evidence_particle.lua

## Summary

Designed for high-performance visual effects, it utilizes bounded, fixed-capacity memory pools and CPU-based Euler integration. At the core of the module is the `ParticleSystem`, an emitter that spawns `Particle` instances according to highly configurable emission shapes, such as point, circle, ring, rectangle, cone, line, and custom callbacks. Once spawned, each particle evolves independently based on a robust physics model that includes linear velocity, gravity, radial/tangential acceleration, linear damping, drag, orbit mechanics, and turbulence, before eventually expiring after a predefined lifetime.

The visual representation of particles is extremely flexible. The system supports both procedural geometric shapes (like squares, circles, sparks, and shrapnel) and fully textured sprites. Throughout their lifetime, particles dynamically interpolate key properties—such as color, size, rotation, and opacity—using customizable multi-stop keyframe curves. To create complex, layered effects, `ParticleSystem`s support sub-emitters, allowing particles to spawn entirely new child particle bursts upon specific events, such as birth, death, or collision. The module also features a robust physics collision integration, allowing particles to bounce realistically off defined bounding boxes or dynamic Rapier2D world geometry with configurable restitution.

Beyond standalone particles, the module implements a sophisticated `Trail` system. This generates connected ribbon segments behind moving particles or standalone points, featuring width tapering, age-based point retirement, and head-to-tail color interpolation. Additional advanced features include point attractors (gravity wells) that dynamically pull or repel live particles, and texture animation that can cycle through sprite atlas frames over a particle's lifetime. For ease of use, the module provides a suite of ready-made `presets` for common effects like fire, smoke, rain, snow, and sparks. The entire module is heavily optimized for deterministic simulation (given the same initial seed) and provides extensive debug visualization tools. It is fully exposed to the Lua scripting environment via the `lurek.particle.*` API, making it an essential tool for bringing dynamic, visually rich effects to Lurek2D games.

## Files

### config.rs

- Emitter configuration struct (`ParticleConfig`) with all tunable parameters serialisable to TOML.
- Enums controlling spawn distribution, insertion order, operating state, and coordinate mode.
- Geometric emission shapes: point, circle, rectangle, ring, line, cone, star, spiral, and custom callback.
- Helper types for point attractors and axis-aligned bounce boundaries.
- Relative-mode and area-distribution strategies for world-space vs emitter-attached particles.

### emission.rs

- Spawn-offset sampling for particle emission shapes and area distributions.
- Supports uniform, normal, ellipse, border, rectangle, ring, cone, star, and spiral modes.
- Handles area-angle rotation for distribution-based offsets.

### emitter.rs

- Live particle emitter that owns the active particle pool, physics stepping, and sub-system list.
- Per-frame integration: gravity, radial/tangential acceleration, linear damping, drag, orbit, and turbulence.
- Point-attractor influence applied per particle each frame with distance falloff.
- Axis-aligned bounce boundaries that reflect particles with configurable restitution.
- Continuous emission via fractional accumulator, burst spawning, and three insert-order modes.
- Child sub-system spawning on particle death with configurable burst count and config clone.
- State machine: Active, Paused, Stopped with lifetime-based auto-stop.
- Render command building: shape mapping, color/alpha/size interpolation, texture quads, and animated frames.
- Warm-up simulation pre-populates the pool by stepping in fixed 50 ms increments.
- Custom emission shape callback support via pending offset indices drained by the Lua bridge.
- Death event queue exposing world-space position and velocity for gameplay hooks.

### math.rs

- Keyframe interpolation for particle size, colour, and alpha over normalised lifetime.
- Uniform and normal random number helpers for emission variance.
- All evaluators clamp `t` to `[0.0, 1.0]` and return sensible defaults on empty input.

### mod.rs

- Particle emitter lifecycle: spawn, simulate, and recycle pooled particles each frame.
- Configurable emission shapes, rates, bursts, and per-particle property ranges (colour, size, alpha).
- Physics collision response, trail ribbons, spawn-shape geometry, and preset constructors.
- Render integration translating live particle state into batched draw commands.

### particle.rs

- Per-particle runtime state: position, velocity, lifetime, rotation, and acceleration.
- Holds spawn-time origin for radial/tangential force calculations.
- Carries a shape seed for deterministic procedural polygon generation.

### physics_collision.rs

- Bounce particles off rapier colliders using AABB overlap probes.
- Reflect velocity with a configurable restitution coefficient.
- Operates per-frame on all live particles in a system.

### presets.rs

- Ready-made `ParticleConfig` constructors for common visual effects (fire, smoke, rain, snow, sparks).
- Each preset returns a standalone config with tuned lifetime, speed, color ramp, and shape.
- Designed for one-call usage; callers can override individual fields after construction.

### render.rs

- Render-command generation for particle systems and trails.
- Expansion of batched `DrawParticleSystem` into individual textured draw calls.
- Untextured particles remain batched for efficient rendering.

### shapes.rs

- Geometric shape primitives controlling how individual particles are rendered.
- Includes simple fills (square, circle, triangle), directional shapes (spark, ray, capsule), and composite outlines (ring).
- Each variant may carry inline parameters (edge count, aspect ratio, thickness).

### trail.rs

- Ribbon trail built from a deque of aged world-space points.
- Automatic point retirement when age exceeds configurable lifetime.
- Width tapering and head-to-tail colour interpolation.
- Render output as triangle-strip render commands or CPU-rasterised image.

### visualization.rs

- Particle visualization helpers that render live `ParticleSystem` state to `ImageData` bitmaps.
- Generic renderer using colour/size/alpha keyframes from the emitter configuration.
- Themed preset renderers for explosions, rain, and spark-trail effects.
- Compositing support: overlay particles onto an existing background or paint in-place.
- Bar-chart lifecycle diagram showing particle count over time steps.

## Lua API Ref

- Binding: `src/lua_api/particle_api.rs`
- Namespace: `lurek.particle`

### Functions

- `lurek.particle.drawLifecycleToImage`: Draws a lifecycle chart image from `(step, count)` snapshot tables.
- `lurek.particle.fromTOML`: Creates a particle system from a TOML config file.
- `lurek.particle.newPreset`: Creates a particle system from a named preset.
- `lurek.particle.newSystem`: Creates a particle system from an optional config table.
- `lurek.particle.newTrail`: Creates a trail effect. This function is exposed to Lua scripts.

### Enums

- No documented module-level enums/constants.

### Types


#### LParticleSystem Type


##### Fields

- No documented fields.

##### Methods

- `LParticleSystem:addAttractor`: Adds an attractor to the particle system.
- `LParticleSystem:addSubEmitter`: Configures a death sub-emitter from a config table.
- `LParticleSystem:addSubSystem`: Adds a particle sub-system from a config table.
- `LParticleSystem:clearAttractors`: Clears all attractors on this object.
- `LParticleSystem:clearBounds`: Clears collision bounds on this object.
- `LParticleSystem:clearCollidesWithPhysics`: Disables particle collision against a physics world.
- `LParticleSystem:clone`: Clones this particle system configuration into a new system handle.
- `LParticleSystem:count`: Returns the current particle count.
- `LParticleSystem:drawExplosionToImage`: Draws particles as an explosion preview image.
- `LParticleSystem:drawOverImage`: Draws particles over an existing image and returns a composited copy.
- `LParticleSystem:drawRainToImage`: Draws particles as a rain preview image.
- `LParticleSystem:drawSparkTrailToImage`: Draws particles as a spark-trail preview image.
- `LParticleSystem:drawToImage`: Draws particles to image data. This method is available to Lua scripts.
- `LParticleSystem:emit`: Emits particles immediately. This method is available to Lua scripts.
- `LParticleSystem:getAttractorCount`: Returns attractor count. This method is available to Lua scripts.
- `LParticleSystem:getBufferSize`: Returns maximum particle buffer size.
- `LParticleSystem:getColors`: Returns particle color keyframes.
- `LParticleSystem:getCount`: Returns particle count and errors if the handle was released.
- `LParticleSystem:getDirection`: Returns emission direction. This method is available to Lua scripts.
- `LParticleSystem:getEmissionArea`: Returns emission area distribution and size.
- `LParticleSystem:getEmissionRate`: Returns emission rate. This method is available to Lua scripts.
- `LParticleSystem:getEmitterLifetime`: Returns emitter lifetime. This method is available to Lua scripts.
- `LParticleSystem:getFlipbook`: Returns flipbook grid and frame rate when configured.
- `LParticleSystem:getGravity`: Returns particle gravity. This method is available to Lua scripts.
- `LParticleSystem:getInsertMode`: Returns particle insert mode. This method is available to Lua scripts.
- `LParticleSystem:getLinearAcceleration`: Returns linear acceleration range.
- `LParticleSystem:getLinearDamping`: Returns linear damping range. This method is available to Lua scripts.
- `LParticleSystem:getOffset`: Returns particle spawn offset. This method is available to Lua scripts.
- `LParticleSystem:getParticleLifetime`: Returns particle lifetime range. This method is available to Lua scripts.
- `LParticleSystem:getPosition`: Returns emitter position. This method is available to Lua scripts.
- `LParticleSystem:getRadialAcceleration`: Returns radial acceleration range.
- `LParticleSystem:getRotation`: Returns particle rotation range. This method is available to Lua scripts.
- `LParticleSystem:getShape`: Returns particle shape. This method is available to Lua scripts.
- `LParticleSystem:getSizeVariation`: Returns size variation. This method is available to Lua scripts.
- `LParticleSystem:getSizes`: Returns particle size keyframes. This method is available to Lua scripts.
- `LParticleSystem:getSpeed`: Returns particle speed range. This method is available to Lua scripts.
- `LParticleSystem:getSpin`: Returns particle spin range. This method is available to Lua scripts.
- `LParticleSystem:getSpinVariation`: Returns spin variation. This method is available to Lua scripts.
- `LParticleSystem:getSpread`: Returns emission spread. This method is available to Lua scripts.
- `LParticleSystem:getTangentialAcceleration`: Returns tangential acceleration range.
- `LParticleSystem:hasCollidesWithPhysics`: Returns whether particle physics collision is enabled.
- `LParticleSystem:hasRelativeRotation`: Returns whether relative rotation is enabled.
- `LParticleSystem:isActive`: Returns whether the particle system is active.
- `LParticleSystem:isEmpty`: Returns whether the particle system has no particles or is missing.
- `LParticleSystem:isFull`: Returns whether the particle system has reached capacity.
- `LParticleSystem:isPaused`: Returns whether the particle system is paused.
- `LParticleSystem:isStopped`: Returns whether the particle system is stopped or missing.
- `LParticleSystem:moveTo`: Moves the particle emitter. This method is available to Lua scripts.
- `LParticleSystem:paintOnto`: Paints live particles directly onto an existing image in place.
- `LParticleSystem:pause`: Pauses particle emission and updates.
- `LParticleSystem:release`: Releases the particle system from shared storage.
- `LParticleSystem:render`: Enqueues particle render commands with an optional offset.
- `LParticleSystem:reset`: Resets particles and emitter state.
- `LParticleSystem:resume`: Resumes a paused particle system if it was previously paused.
- `LParticleSystem:setBounds`: Sets collision bounds for particles.
- `LParticleSystem:setBufferSize`: Sets maximum particle buffer size.
- `LParticleSystem:setCollidesWithPhysics`: Enables particle collision against a physics world.
- `LParticleSystem:setColors`: Sets particle color keyframes from one or more RGBA tables.
- `LParticleSystem:setCustomEmissionShape`: Sets a Lua callback for custom emission positions.
- `LParticleSystem:setDirection`: Sets emission direction. This method is available to Lua scripts.
- `LParticleSystem:setEmissionArea`: Sets emission area distribution and size.
- `LParticleSystem:setEmissionRate`: Sets emission rate. This method is available to Lua scripts.
- `LParticleSystem:setEmitterLifetime`: Sets emitter lifetime. This method is available to Lua scripts.
- `LParticleSystem:setFlipbook`: Sets flipbook grid and frame rate. This method is available to Lua scripts.
- `LParticleSystem:setGravity`: Sets particle gravity. This method is available to Lua scripts.
- `LParticleSystem:setInsertMode`: Sets particle insert mode. This method is available to Lua scripts.
- `LParticleSystem:setLinearAcceleration`: Sets linear acceleration range. This method is available to Lua scripts.
- `LParticleSystem:setLinearDamping`: Sets linear damping range. This method is available to Lua scripts.
- `LParticleSystem:setOffset`: Sets particle spawn offset. This method is available to Lua scripts.
- `LParticleSystem:setOnDeathBatch`: Sets a Lua callback invoked with batched particle death records.
- `LParticleSystem:setParticleLifetime`: Sets particle lifetime range. This method is available to Lua scripts.
- `LParticleSystem:setPosition`: Sets emitter position. This method is available to Lua scripts.
- `LParticleSystem:setRadialAcceleration`: Sets radial acceleration range. This method is available to Lua scripts.
- `LParticleSystem:setRelativeRotation`: Sets whether particle rotation is relative to movement.
- `LParticleSystem:setRotation`: Sets particle rotation range. This method is available to Lua scripts.
- `LParticleSystem:setShape`: Sets particle shape. This method is available to Lua scripts.
- `LParticleSystem:setSizeVariation`: Sets size variation. This method is available to Lua scripts.
- `LParticleSystem:setSizes`: Sets the particle size keyframes used during a particle's lifetime. Pass two or more values to interpolate between them.
- `LParticleSystem:setSpeed`: Sets particle speed range. This method is available to Lua scripts.
- `LParticleSystem:setSpin`: Sets particle spin range. This method is available to Lua scripts.
- `LParticleSystem:setSpinVariation`: Sets spin variation. This method is available to Lua scripts.
- `LParticleSystem:setSpread`: Sets emission spread. This method is available to Lua scripts.
- `LParticleSystem:setTangentialAcceleration`: Sets tangential acceleration range for emitted particles.
- `LParticleSystem:start`: Starts particle emission on this object.
- `LParticleSystem:stop`: Stops particle emission on this object.
- `LParticleSystem:subSystemCount`: Returns particle sub-system count.
- `LParticleSystem:toImage`: Draws particles to image data. This method is available to Lua scripts.
- `LParticleSystem:type`: Returns the Lua-visible type name for this particle system handle.
- `LParticleSystem:typeOf`: Returns whether this particle system handle matches a supported type name.
- `LParticleSystem:update`: Updates the particle system, applies optional physics collision, and invokes pending callbacks.
- `LParticleSystem:warmUp`: Advances the system by a warm-up duration.


#### LTrail Type


##### Fields

- No documented fields.

##### Methods

- `LTrail:clear`: Clears all trail points on this object.
- `LTrail:drawToImage`: Draws the trail to image data. This method is available to Lua scripts.
- `LTrail:getLifetime`: Returns trail point lifetime. This method is available to Lua scripts.
- `LTrail:getPointCount`: Returns trail point count. This method is available to Lua scripts.
- `LTrail:getWidth`: Returns trail width settings from this object.
- `LTrail:pushPoint`: Adds a point to the trail. This method is available to Lua scripts.
- `LTrail:setHeadColor`: Sets the color of the leading edge of the trail.
- `LTrail:setLifetime`: Sets trail point lifetime. This method is available to Lua scripts.
- `LTrail:setMinDistance`: Sets minimum distance between trail points.
- `LTrail:setTailColor`: Sets the color of the trailing edge of the trail.
- `LTrail:setWidth`: Sets trail start and optional end width.
- `LTrail:type`: Returns the Lua-visible type name for this trail handle.
- `LTrail:typeOf`: Returns whether this trail handle matches a supported type name.
- `LTrail:update`: Updates trail point lifetimes. This method is available to Lua scripts.

## References

- `color`: Imports or references `src/color/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `image`: Imports or references `image` from `src/image/`.
- `math`: Imports or references `math` from `src/math/`.
- `physics`: Imports or references `src/physics/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
