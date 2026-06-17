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
- Optional emitter seeds make particle playback deterministic for tests, evidence, and replay capture.
- Runtime telemetry snapshots expose pool pressure, sub-emitter activity, attractor load, and age for dashboard workflows.
- The module is useful for combat impacts, weather, ambient motion, and UI accents.
- For users, it centralizes particle behavior rather than scattering custom emitter logic.
- It balances artistic flexibility with deterministic, test-friendly controls.
- Overall, users get a production-ready VFX runtime in one script API.
- This enables richer scenes with less effect-specific boilerplate.

This module primarily collaborates with `color`, `image`, `math`, `physics`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Imports

- `color`: Imports or references `src/color/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `image`: Imports or references `image` from `src/image/`.
- `math`: Imports or references `math` from `src/math/`.
- `physics`: Imports or references `src/physics/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### config.rs

- Runtime configuration for particle emitters and their tunable behavior. `particle/config` delivers the configuration schema and defaults for the particle subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Carries spawn distribution, insertion order, state, and coordinate mode settings. The file owns or coordinates data contracts including `AreaDistribution`, `InsertMode`, `EmitterState`, `EmissionShape`, `RelativeMode`, and 3 more, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Describes emission shapes from point and circle to cone, star, spiral, and custom callbacks. Public callable behavior is centered on no named public items, while method-level behavior such as `sanitize`, `normalized`, `from_toml_str` stays attached to the local data model and invariants.
- Includes attractor and bounce helper types for motion control. Runtime integration reaches sibling engine areas through crate modules `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Covers world-space versus emitter-attached spawning rules. External integration uses `super`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Packs every serializable knob into one config object for scripts and data files. The file boundary separates particle implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

### emission.rs

- Spawn-offset sampling for particle emission shapes and area distributions. `particle/emission` delivers the emission implementation for the particle subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Supports uniform, normal, ellipse, border, rectangle, ring, cone, star, and spiral modes. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Handles area-angle rotation so emitted particles respect the configured shape. Public callable behavior is centered on `emission_offset`, `emission_shape_offset`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Keeps emission math separate from the particle runtime. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### emitter.rs

- Live particle emitter that owns the active particle pool, physics stepping, and sub-system list. `particle/emitter` delivers the emitter implementation for the particle subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Integrates gravity, drag, orbit, turbulence, and other per-frame forces. The file owns or coordinates data contracts including `ParticleSystemStats`, `ParticleSystem`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Spawns particles continuously or in bursts using fractional accumulation and ordered insertion modes. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `update`, `emit`, `count`, `reset`, `start`, and 23 more stays attached to the local data model and invariants.
- Applies attractors and axis-aligned bounce boundaries to active particles. Runtime integration reaches sibling engine areas through crate modules `log_msg`, `particle`, `render`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Runs child emitters on particle death when sub-systems are configured. External integration uses `super`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Tracks active, paused, and stopped states with lifetime-based auto-stop. The file boundary separates particle implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

### math.rs

- Keyframe interpolation for particle size, colour, and alpha over normalized lifetime. `particle/math` delivers the math implementation for the particle subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Offers uniform and normal random helpers for emission variance. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Clamps interpolation inputs and falls back cleanly on empty keyframe sets. Public callable behavior is centered on `next_u64`, `rand_f32`, `interpolate_sizes`, `interpolate_colors`, `interpolate_alphas`, and 4 more, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Supports the numeric shaping layer used by emitter animation. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### mod.rs

- Particle emitter lifecycle for spawn, simulation, and pooled recycling. `particle/mod` is the particle module index, declaring `config`, `emission`, `emitter`, `math`, `particle`, and 6 more so agents can identify which files own each feature slice before opening implementation code.
- Collects emission, physics, trail, rendering, and preset helpers under one namespace. `src/particle/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `config::{ AreaDistribution, EmissionShape, EmitterState, InsertMode, ParticleConfig, RelativeMode, }`, `emitter::ParticleSystem`, `math::{interpolate_alphas, interpolate_colors, interpolate_sizes, lerp}`, `particle::Particle`, and 2 more centralized for the particle subsystem.
- Keeps particle effects modular while exposing a single runtime surface. The file documents how particle submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.
- `particle/mod` is the particle module index, declaring `config`, `emission`, `emitter`, `math`, `particle`, and 6 more so agents can identify which files own each feature slice before opening implementation code.
- `src/particle/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `config::{ AreaDistribution, EmissionShape, EmitterState, InsertMode, ParticleConfig, RelativeMode, }`, `emitter::ParticleSystem`, `math::{interpolate_alphas, interpolate_colors, interpolate_sizes, lerp}`, `particle::Particle`, and 2 more centralized for the particle subsystem.
- The file documents how particle submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.

### particle.rs

- Per-particle runtime state for position, velocity, lifetime, rotation, and acceleration. `particle/particle` delivers the particle implementation for the particle subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Stores spawn origin and shape seed for force calculations and deterministic geometry. The file owns or coordinates data contracts including `Particle`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Keeps the minimum state needed by the emitter loop. Public callable behavior is centered on no named public items, while method-level behavior such as no named public items stays attached to the local data model and invariants.

### physics_collision.rs

- Bounce particles off rapier colliders using AABB overlap probes. `particle/physics_collision` delivers the physics collision implementation for the particle subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

### presets.rs

- Ready-made ParticleConfig constructors for common visual effects. `particle/presets` delivers the presets implementation for the particle subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Covers fire, smoke, rain, snow, sparks, and other standard patterns. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Returns self-contained configs with tuned lifetime, speed, color ramp, and shape. Public callable behavior is centered on `fire`, `smoke`, `rain`, `snow`, `sparks`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Lets callers start from a stable preset and override fields afterward. Runtime integration reaches sibling engine areas through crate modules `particle`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### render.rs

- Render-command generation for particle systems and trails. `particle/render` delivers the rendering adapter and draw-command integration for the particle subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Expands textured particle batches into individual draw calls when needed. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Keeps untextured particles batched for efficiency. Public callable behavior is centered on `expand_particle_commands`, while method-level behavior such as `generate_render_commands` stays attached to the local data model and invariants.

### shapes.rs

- Geometric shape primitives that control how individual particles are rendered. `particle/shapes` delivers the shapes implementation for the particle subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Covers fills, directional shapes, and composite outlines with inline parameters. The file owns or coordinates data contracts including `ParticleShape`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Gives emitters a compact vocabulary for particle silhouette design. Public callable behavior is centered on no named public items, while method-level behavior such as no named public items stays attached to the local data model and invariants.

### trail.rs

- Ribbon trail built from a deque of aged world-space points. `particle/trail` delivers the trail implementation for the particle subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Retires points automatically when they exceed the configured lifetime. The file owns or coordinates data contracts including `TrailPoint`, `Trail`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Tapers width and interpolates color from head to tail. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `push_point`, `update`, `set_width`, `set_lifetime`, `get_lifetime`, and 8 more stays attached to the local data model and invariants.
- Can render as triangle-strip commands or as a CPU-rasterized image. Runtime integration reaches sibling engine areas through crate modules `color`, `render`, which explains the subsystem dependencies an agent should inspect before changing behavior.

### visualization.rs

- Particle visualization helpers that render live ParticleSystem state to ImageData bitmaps. `particle/visualization` delivers the visualization implementation for the particle subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Includes a generic renderer plus themed presets for explosions, rain, and spark trails. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Supports compositing particles over an existing background or painting in place. Public callable behavior is centered on `draw_to_image`, `draw_explosion_to_image`, `draw_rain_to_image`, `draw_spark_trail_to_image`, `draw_over_image`, and 2 more, while method-level behavior such as no named public items stays attached to the local data model and invariants.
- Adds a chart-style lifetime view for inspecting particle counts over time. Runtime integration reaches sibling engine areas through crate modules `image`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Keeps render inspection separate from the particle simulation core. External integration uses `super`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.



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
