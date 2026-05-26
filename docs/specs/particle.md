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

## Source Documentation

### `config.rs`
- Emitter configuration struct (`ParticleConfig`) with all tunable parameters serialisable to TOML.
- Enums controlling spawn distribution, insertion order, operating state, and coordinate mode.
- Geometric emission shapes: point, circle, rectangle, ring, line, cone, star, spiral, and custom callback.
- Helper types for point attractors and axis-aligned bounce boundaries.
- Relative-mode and area-distribution strategies for world-space vs emitter-attached particles.

### `emission.rs`
- Spawn-offset sampling for particle emission shapes and area distributions.
- Supports uniform, normal, ellipse, border, rectangle, ring, cone, star, and spiral modes.
- Handles area-angle rotation for distribution-based offsets.

### `emitter.rs`
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

### `math.rs`
- Keyframe interpolation for particle size, colour, and alpha over normalised lifetime.
- Uniform and normal random number helpers for emission variance.
- All evaluators clamp `t` to `[0.0, 1.0]` and return sensible defaults on empty input.

### `mod.rs`
- Particle emitter lifecycle: spawn, simulate, and recycle pooled particles each frame.
- Configurable emission shapes, rates, bursts, and per-particle property ranges (colour, size, alpha).
- Physics collision response, trail ribbons, spawn-shape geometry, and preset constructors.
- Render integration translating live particle state into batched draw commands.

### `particle.rs`
- Per-particle runtime state: position, velocity, lifetime, rotation, and acceleration.
- Holds spawn-time origin for radial/tangential force calculations.
- Carries a shape seed for deterministic procedural polygon generation.

### `physics_collision.rs`
- Bounce particles off rapier colliders using AABB overlap probes.
- Reflect velocity with a configurable restitution coefficient.
- Operates per-frame on all live particles in a system.

### `presets.rs`
- Ready-made `ParticleConfig` constructors for common visual effects (fire, smoke, rain, snow, sparks).
- Each preset returns a standalone config with tuned lifetime, speed, color ramp, and shape.
- Designed for one-call usage; callers can override individual fields after construction.

### `render.rs`
- Render-command generation for particle systems and trails.
- Expansion of batched `DrawParticleSystem` into individual textured draw calls.
- Untextured particles remain batched for efficient rendering.

### `shapes.rs`
- Geometric shape primitives controlling how individual particles are rendered.
- Includes simple fills (square, circle, triangle), directional shapes (spark, ray, capsule), and composite outlines (ring).
- Each variant may carry inline parameters (edge count, aspect ratio, thickness).

### `trail.rs`
- Ribbon trail built from a deque of aged world-space points.
- Automatic point retirement when age exceeds configurable lifetime.
- Width tapering and head-to-tail colour interpolation.
- Render output as triangle-strip render commands or CPU-rasterised image.

### `visualization.rs`
- Particle visualization helpers that render live `ParticleSystem` state to `ImageData` bitmaps.
- Generic renderer using colour/size/alpha keyframes from the emitter configuration.
- Themed preset renderers for explosions, rain, and spark-trail effects.
- Compositing support: overlay particles onto an existing background or paint in-place.
- Bar-chart lifecycle diagram showing particle count over time steps.

## Types

- `AreaDistribution` (`enum`, `config.rs`): Enum controlling secondary spread across rectangular or elliptical areas.
- `InsertMode` (`enum`, `config.rs`): Insert mode controlling where new particles are placed in the particle list.
- `EmitterState` (`enum`, `config.rs`): Enum tracking whether an emitter is active, paused, or stopped.
- `EmissionShape` (`enum`, `config.rs`): Enum controlling where particles spawn relative to the emitter. Variants: `Point`, `Circle`, `Rectangle`, `Ring`, `Line`, `Cone`, `Star`, `Spiral`, `Custom { callback_id: u32 }`. Derives `serde::Serialize + Deserialize`.
- `RelativeMode` (`enum`, `config.rs`): Enum controlling whether particles remain in world space or move with the emitter.
- `Attractor` (`struct`, `config.rs`): Gravity well applied to live particles. Fields: `x: f32`, `y: f32`, `strength: f32`, `radius: f32`. Positive strength pulls; negative repels.
- `BounceBounds` (`struct`, `config.rs`): Axis-aligned bounding rectangle. Particles that cross a wall have their velocity component reversed and scaled by `restitution`. Fields: `x_min`, `x_max`, `y_min`, `y_max`, `restitution: f32`.
- `ParticleConfig` (`struct`, `config.rs`): Main emitter configuration object controlling spawn rate, lifetime, forces, interpolation curves, rendering shape, and batching limits. Fields added: `death_emitter: Option<Box<ParticleConfig>>`, `death_burst_count: u32`, `shrapnel_edges: u8`, `ray_aspect: f32`, `ring_thickness: f32`.
- `ParticleSystem` (`struct`, `emitter.rs`): Main emitter simulation that owns the live particle pool and advances it each frame. Fields added: `attractors: Vec<Attractor>`, `bounce_bounds: Option<BounceBounds>`, `sub_systems: Vec<ParticleSystem>`.
- `Particle` (`struct`, `particle.rs`): Per-particle runtime state including position, velocity, lifetime, rotation, and acceleration terms. Field added: `shape_seed: u32` — assigned at spawn for deterministic `Shrapnel` polygon generation.
- `ParticleShape` (`enum`, `shapes.rs`): Enum selecting the geometric primitive used for untextured particles. Variants: `Square`, `Circle`, `Triangle`, `Spark`, `Diamond`, `Shrapnel { edges: u8 }`, `Ray { aspect: f32 }`, `Puff`, `Ring { thickness: f32 }`, `Capsule`.
- `TrailPoint` (`struct`, `trail.rs`): Individual point stored inside a Trail.
- `Trail` (`struct`, `trail.rs`): Fading ribbon effect that stores and ages trail points over time.

## Functions

- `ParticleConfig::from_toml_str` (`config.rs`): Parse a `ParticleConfig` from a TOML string; returns the error string on failure.
- `emission_offset` (`emission.rs`): Compute an emission offset `(dx, dy)` based on the config's area distribution.
- `emission_shape_offset` (`emission.rs`): Compute an emission offset `(dx, dy)` based on the emission shape.
- `ParticleSystem::new` (`emitter.rs`): Create a new system from `config`; allocates the particle pool upfront.
- `ParticleSystem::update` (`emitter.rs`): Advance all particles by `dt` seconds: integrate physics, retire dead particles, and spawn new ones.
- `ParticleSystem::emit` (`emitter.rs`): Burst-spawn up to `count` particles immediately, capped by `max_particles`.
- `ParticleSystem::count` (`emitter.rs`): Return the number of live particles in the pool.
- `ParticleSystem::reset` (`emitter.rs`): Clear all particles and reset the accumulator and age.
- `ParticleSystem::start` (`emitter.rs`): Transition to `Active` and reset `emitter_age` to zero.
- `ParticleSystem::stop` (`emitter.rs`): Transition to `Stopped`; existing particles continue to live but no new ones are emitted.
- `ParticleSystem::pause` (`emitter.rs`): Transition to `Paused`; update loop stops advancing but particles freeze in place.
- `ParticleSystem::resume` (`emitter.rs`): Resume from `Paused` or `Stopped`; transitions to `Active`.
- `ParticleSystem::move_to` (`emitter.rs`): Update the emitter's world-space position, recording the previous position for motion blur.
- `ParticleSystem::clone_config` (`emitter.rs`): Return a new `ParticleSystem` with the same config but no live particles.
- `ParticleSystem::is_active` (`emitter.rs`): Return `true` when the emitter state is `Active`.
- `ParticleSystem::is_paused` (`emitter.rs`): Return `true` when the emitter state is `Paused`.
- `ParticleSystem::is_stopped` (`emitter.rs`): Return `true` when the emitter state is `Stopped`.
- `ParticleSystem::is_empty` (`emitter.rs`): Return `true` when the particle pool is empty.
- `ParticleSystem::is_full` (`emitter.rs`): Return `true` when the pool has reached `max_particles`.
- `ParticleSystem::build_render_commands` (`emitter.rs`): Build `RenderCommand` values for all live particles at world offset `(ox, oy)`, including sub-systems.
- `ParticleSystem::warm_up` (`emitter.rs`): Run the update loop for up to `seconds` in 50 ms steps to pre-populate the particle pool.
- `ParticleSystem::add_attractor` (`emitter.rs`): Add a point attractor at `(x, y)` with given `strength` and influence `radius`.
- `ParticleSystem::clear_attractors` (`emitter.rs`): Remove all attractors.
- `ParticleSystem::attractor_count` (`emitter.rs`): Return the number of active attractors.
- `ParticleSystem::set_bounds` (`emitter.rs`): Set the axis-aligned bounce boundary; particles reflect on crossing any edge.
- `ParticleSystem::clear_bounds` (`emitter.rs`): Remove the bounce boundary.
- `ParticleSystem::add_sub_system` (`emitter.rs`): Append a child sub-system; returns its index in `sub_systems`.
- `ParticleSystem::sub_system_count` (`emitter.rs`): Return the number of active sub-systems.
- `ParticleSystem::drain_pending_deaths` (`emitter.rs`): Drain and return all `(world_x, world_y, vx, vy)` death events accumulated since the last call.
- `ParticleSystem::drain_custom_offsets` (`emitter.rs`): Drain and return particle pool indices that need a custom spawn-offset callback applied.
- `interpolate_sizes` (`math.rs`): Interpolate a multi-stop size array at normalised time `t` (0 = birth, 1 = death).
- `interpolate_colors` (`math.rs`): Interpolate a multi-stop color array at normalised time `t` (0 = birth, 1 = death).
- `interpolate_alphas` (`math.rs`): Interpolate a multi-stop alpha array at normalised time `t` (0 = birth, 1 = death).
- `rand_range` (`math.rs`): Sample a uniform random value in `[min, max]`.
- `rand_normal` (`math.rs`): Approximate a standard-normal random value using Box-Muller transform.
- `collide_with_world` (`physics_collision.rs`): Reflect all particles in `system` that overlap a rapier collider in `world`; uses AABB probe of `probe_radius` and `restitution` coefficient.
- `fire` (`presets.rs`): Return a `ParticleConfig` producing an upward fire effect with turbulence and RGB fade.
- `smoke` (`presets.rs`): Return a `ParticleConfig` producing rising smoke with growing size and fading alpha.
- `rain` (`presets.rs`): Return a `ParticleConfig` producing fast downward rain streaks.
- `snow` (`presets.rs`): Return a `ParticleConfig` producing slow-drifting white snowflakes with turbulence.
- `sparks` (`presets.rs`): Return a `ParticleConfig` for a burst-only spark explosion; set `emission_rate > 0` or call `emit` manually.
- `ParticleSystem::generate_render_commands` (`render.rs`): Generate render commands for this system at world offset `(0, 0)`.
- `Trail::generate_render_commands` (`render.rs`): Generate `RenderCommand` values for the trail ribbon.
- `expand_particle_commands` (`render.rs`): Expand particle render commands for textured particles.
- `Trail::new` (`trail.rs`): Create a trail with `lifetime` seconds per point and `start_width` pixels at the head.
- `Trail::push_point` (`trail.rs`): Append a point at `(x, y)` if it is at least `min_distance` from the current head.
- `Trail::update` (`trail.rs`): Advance all point ages by `dt` seconds and retire points that exceed `lifetime`.
- `Trail::set_width` (`trail.rs`): Set ribbon width; `start` is the head width and optional `end` sets the tail width.
- `Trail::set_lifetime` (`trail.rs`): Set the maximum point lifetime in seconds.
- `Trail::get_lifetime` (`trail.rs`): Return the current maximum point lifetime in seconds.
- `Trail::set_min_distance` (`trail.rs`): Set the minimum distance between consecutive trail points.
- `Trail::clear` (`trail.rs`): Remove all points.
- `Trail::get_point_count` (`trail.rs`): Return the current number of live trail points.
- `Trail::get_width` (`trail.rs`): Return the current `(start_width, end_width)` pair.
- `Trail::set_head_color` (`trail.rs`): Set the RGBA colour at the head of the trail.
- `Trail::set_tail_color` (`trail.rs`): Set the RGBA colour at the tail of the trail.
- `Trail::build_render_commands` (`trail.rs`): Build a list of `SetColor` + `Triangle` commands forming the ribbon; returns empty when fewer than 2 points.
- `Trail::draw_to_image` (`trail.rs`): Render the trail to an `ImageData` of `width` x `height`; returns a dark-filled image when fewer than 2 points.
- `draw_to_image` (`visualization.rs`): Render all live particles to an `ImageData`.
- `draw_explosion_to_image` (`visualization.rs`): Render an explosion burst: particles radiate from center with age-based red-to-yellow coloring.
- `draw_rain_to_image` (`visualization.rs`): Render particles styled as falling rain streaks.
- `draw_spark_trail_to_image` (`visualization.rs`): Render particles as hot orange sparks with short trails.
- `draw_over_image` (`visualization.rs`): Render particles over a provided background image.
- `paint_onto` (`visualization.rs`): Paint live spark particles onto an existing mutable image.
- `draw_lifecycle_to_image` (`visualization.rs`): Renders a bar chart of particle lifecycle counts over time into an `ImageData` frame.

## Lua API Reference

- Binding path(s): `src/lua_api/particle_api.rs`
- Namespace: `lurek.particle`

### Module Functions
- `lurek.particle.newSystem`: Creates a particle system from an optional config table.
- `lurek.particle.newTrail`: Creates a trail effect. This function is exposed to Lua scripts.
- `lurek.particle.fromTOML`: Creates a particle system from a TOML config file.
- `lurek.particle.newPreset`: Creates a particle system from a named preset.

### `LParticleSystem` Methods
- `LParticleSystem:update`: Updates the particle system, applies optional physics collision, and invokes pending callbacks.
- `LParticleSystem:emit`: Emits particles immediately. This method is available to Lua scripts.
- `LParticleSystem:start`: Starts particle emission on this object.
- `LParticleSystem:stop`: Stops particle emission on this object.
- `LParticleSystem:pause`: Pauses particle emission and updates.
- `LParticleSystem:resume`: Resumes a paused particle system if it was previously paused.
- `LParticleSystem:reset`: Resets particles and emitter state.
- `LParticleSystem:moveTo`: Moves the particle emitter. This method is available to Lua scripts.
- `LParticleSystem:count`: Returns the current particle count.
- `LParticleSystem:isActive`: Returns whether the particle system is active.
- `LParticleSystem:isPaused`: Returns whether the particle system is paused.
- `LParticleSystem:isStopped`: Returns whether the particle system is stopped or missing.
- `LParticleSystem:isEmpty`: Returns whether the particle system has no particles or is missing.
- `LParticleSystem:isFull`: Returns whether the particle system has reached capacity.
- `LParticleSystem:release`: Releases the particle system from shared storage.
- `LParticleSystem:getCount`: Returns particle count and errors if the handle was released.
- `LParticleSystem:type`: Returns the Lua-visible type name for this particle system handle.
- `LParticleSystem:typeOf`: Returns whether this particle system handle matches a supported type name.
- `LParticleSystem:setPosition`: Sets emitter position. This method is available to Lua scripts.
- `LParticleSystem:getPosition`: Returns emitter position. This method is available to Lua scripts.
- `LParticleSystem:setEmissionRate`: Sets emission rate. This method is available to Lua scripts.
- `LParticleSystem:getEmissionRate`: Returns emission rate. This method is available to Lua scripts.
- `LParticleSystem:setParticleLifetime`: Sets particle lifetime range. This method is available to Lua scripts.
- `LParticleSystem:getParticleLifetime`: Returns particle lifetime range. This method is available to Lua scripts.
- `LParticleSystem:setEmitterLifetime`: Sets emitter lifetime. This method is available to Lua scripts.
- `LParticleSystem:getEmitterLifetime`: Returns emitter lifetime. This method is available to Lua scripts.
- `LParticleSystem:setSpeed`: Sets particle speed range. This method is available to Lua scripts.
- `LParticleSystem:getSpeed`: Returns particle speed range. This method is available to Lua scripts.
- `LParticleSystem:setDirection`: Sets emission direction. This method is available to Lua scripts.
- `LParticleSystem:getDirection`: Returns emission direction. This method is available to Lua scripts.
- `LParticleSystem:setSpread`: Sets emission spread. This method is available to Lua scripts.
- `LParticleSystem:getSpread`: Returns emission spread. This method is available to Lua scripts.
- `LParticleSystem:setLinearAcceleration`: Sets linear acceleration range. This method is available to Lua scripts.
- `LParticleSystem:getLinearAcceleration`: Returns linear acceleration range.
- `LParticleSystem:setRadialAcceleration`: Sets radial acceleration range. This method is available to Lua scripts.
- `LParticleSystem:getRadialAcceleration`: Returns radial acceleration range.
- `LParticleSystem:setTangentialAcceleration`: Sets tangential acceleration range for emitted particles.
- `LParticleSystem:getTangentialAcceleration`: Returns tangential acceleration range.
- `LParticleSystem:setLinearDamping`: Sets linear damping range. This method is available to Lua scripts.
- `LParticleSystem:getLinearDamping`: Returns linear damping range. This method is available to Lua scripts.
- `LParticleSystem:setSizes`: Sets the particle size keyframes used during a particle's lifetime. Pass two or more values to interpolate between them.
- `LParticleSystem:getSizes`: Returns particle size keyframes. This method is available to Lua scripts.
- `LParticleSystem:setSizeVariation`: Sets size variation. This method is available to Lua scripts.
- `LParticleSystem:getSizeVariation`: Returns size variation. This method is available to Lua scripts.
- `LParticleSystem:setRotation`: Sets particle rotation range. This method is available to Lua scripts.
- `LParticleSystem:getRotation`: Returns particle rotation range. This method is available to Lua scripts.
- `LParticleSystem:setSpin`: Sets particle spin range. This method is available to Lua scripts.
- `LParticleSystem:getSpin`: Returns particle spin range. This method is available to Lua scripts.
- `LParticleSystem:setSpinVariation`: Sets spin variation. This method is available to Lua scripts.
- `LParticleSystem:getSpinVariation`: Returns spin variation. This method is available to Lua scripts.
- `LParticleSystem:setRelativeRotation`: Sets whether particle rotation is relative to movement.
- `LParticleSystem:hasRelativeRotation`: Returns whether relative rotation is enabled.
- `LParticleSystem:setColors`: Sets particle color keyframes from one or more RGBA tables.
- `LParticleSystem:getColors`: Returns particle color keyframes.
- `LParticleSystem:setOffset`: Sets particle spawn offset. This method is available to Lua scripts.
- `LParticleSystem:getOffset`: Returns particle spawn offset. This method is available to Lua scripts.
- `LParticleSystem:setInsertMode`: Sets particle insert mode. This method is available to Lua scripts.
- `LParticleSystem:getInsertMode`: Returns particle insert mode. This method is available to Lua scripts.
- `LParticleSystem:setBufferSize`: Sets maximum particle buffer size.
- `LParticleSystem:getBufferSize`: Returns maximum particle buffer size.
- `LParticleSystem:setEmissionArea`: Sets emission area distribution and size.
- `LParticleSystem:getEmissionArea`: Returns emission area distribution and size.
- `LParticleSystem:setShape`: Sets particle shape. This method is available to Lua scripts.
- `LParticleSystem:getShape`: Returns particle shape. This method is available to Lua scripts.
- `LParticleSystem:getGravity`: Returns particle gravity. This method is available to Lua scripts.
- `LParticleSystem:setGravity`: Sets particle gravity. This method is available to Lua scripts.
- `LParticleSystem:render`: Enqueues particle render commands with an optional offset.
- `LParticleSystem:clone`: Clones this particle system configuration into a new system handle.
- `LParticleSystem:drawToImage`: Draws particles to image data. This method is available to Lua scripts.
- `LParticleSystem:toImage`: Draws particles to image data. This method is available to Lua scripts.
- `LParticleSystem:warmUp`: Advances the system by a warm-up duration.
- `LParticleSystem:addAttractor`: Adds an attractor to the particle system.
- `LParticleSystem:clearAttractors`: Clears all attractors on this object.
- `LParticleSystem:getAttractorCount`: Returns attractor count. This method is available to Lua scripts.
- `LParticleSystem:setBounds`: Sets collision bounds for particles.
- `LParticleSystem:clearBounds`: Clears collision bounds on this object.
- `LParticleSystem:setCollidesWithPhysics`: Enables particle collision against a physics world.
- `LParticleSystem:clearCollidesWithPhysics`: Disables particle collision against a physics world.
- `LParticleSystem:hasCollidesWithPhysics`: Returns whether particle physics collision is enabled.
- `LParticleSystem:addSubEmitter`: Configures a death sub-emitter from a config table.
- `LParticleSystem:setFlipbook`: Sets flipbook grid and frame rate. This method is available to Lua scripts.
- `LParticleSystem:getFlipbook`: Returns flipbook grid and frame rate when configured.
- `LParticleSystem:addSubSystem`: Adds a particle sub-system from a config table.
- `LParticleSystem:subSystemCount`: Returns particle sub-system count.
- `LParticleSystem:setCustomEmissionShape`: Sets a Lua callback for custom emission positions.
- `LParticleSystem:setOnDeathBatch`: Sets a Lua callback invoked with batched particle death records.

### `LTrail` Methods
- `LTrail:pushPoint`: Adds a point to the trail. This method is available to Lua scripts.
- `LTrail:update`: Updates trail point lifetimes. This method is available to Lua scripts.
- `LTrail:setWidth`: Sets trail start and optional end width.
- `LTrail:getWidth`: Returns trail width settings from this object.
- `LTrail:setLifetime`: Sets trail point lifetime. This method is available to Lua scripts.
- `LTrail:getLifetime`: Returns trail point lifetime. This method is available to Lua scripts.
- `LTrail:setMinDistance`: Sets minimum distance between trail points.
- `LTrail:setHeadColor`: Sets the color of the leading edge of the trail.
- `LTrail:setTailColor`: Sets the color of the trailing edge of the trail.
- `LTrail:getPointCount`: Returns trail point count. This method is available to Lua scripts.
- `LTrail:clear`: Clears all trail points on this object.
- `LTrail:drawToImage`: Draws the trail to image data. This method is available to Lua scripts.
- `LTrail:type`: Returns the Lua-visible type name for this trail handle.
- `LTrail:typeOf`: Returns whether this trail handle matches a supported type name.

## References

- `image`: Imports or references `image` from `src/image/`.
- `math`: Imports or references `math` from `src/math/`.
- `physics`: Imports or references `src/physics/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/particle/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
