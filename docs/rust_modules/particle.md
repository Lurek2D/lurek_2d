# particle

## General Info

- Module group: `Feature Systems`
- Source path: `src/particle/`
- Binding: `src/lua_api/particle_api.rs`
- Namespace: `lurek.particle`
- Lua API surface: `5` functions, `3` types, `105` methods
- Rust test path(s): tests/rust/unit/particle_tests.rs
- Lua test path(s): tests/lua/unit/test_particle.lua, tests/lua/stress/test_particle_stress.lua, tests/lua/integration/test_particle_timer.lua, tests/lua/evidence/test_evidence_particle.lua

## Summary

Designed for high-performance visual effects, it utilizes bounded, fixed-capacity memory pools and CPU-based Euler integration. At the core of the module is the `ParticleSystem`, an emitter that spawns `Particle` instances according to highly configurable emission shapes, such as point, circle, ring, rectangle, cone, line, and custom callbacks. Once spawned, each particle evolves independently based on a robust physics model that includes linear velocity, gravity, radial/tangential acceleration, linear damping, drag, orbit mechanics, and turbulence, before eventually expiring after a predefined lifetime.

The visual representation of particles is extremely flexible. The system supports both procedural geometric shapes (like squares, circles, sparks, and shrapnel) and fully textured sprites. Throughout their lifetime, particles dynamically interpolate key properties—such as color, size, rotation, and opacity—using customizable multi-stop keyframe curves. To create complex, layered effects, `ParticleSystem`s support sub-emitters, allowing particles to spawn entirely new child particle bursts upon specific events, such as birth, death, or collision. The module also features a robust physics collision integration, allowing particles to bounce realistically off defined bounding boxes or dynamic Rapier2D world geometry with configurable restitution.

Beyond standalone particles, the module implements a sophisticated `Trail` system. This generates connected ribbon segments behind moving particles or standalone points, featuring width tapering, age-based point retirement, and head-to-tail color interpolation. Additional advanced features include point attractors (gravity wells) that dynamically pull or repel live particles, and texture animation that can cycle through sprite atlas frames over a particle's lifetime. For ease of use, the module provides a suite of ready-made `presets` for common effects like fire, smoke, rain, snow, and sparks. The entire module is heavily optimized for deterministic simulation (given the same initial seed) and provides extensive debug visualization tools. It is fully exposed to the Lua scripting environment via the `lurek.particle.*` API, making it an essential tool for bringing dynamic, visually rich effects to Lurek2D games.

## Files

### [config.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/particle/config.rs)

- Runtime configuration for particle emitters and their tunable behavior.
- Carries spawn distribution, insertion order, state, and coordinate mode settings.
- Describes emission shapes from point and circle to cone, star, spiral, and custom callbacks.
- Includes attractor and bounce helper types for motion control.
- Covers world-space versus emitter-attached spawning rules.
- Packs every serializable knob into one config object for scripts and data files.
- Serves as the authored contract for building particle systems.

### [emission.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/particle/emission.rs)

- Spawn-offset sampling for particle emission shapes and area distributions.
- Supports uniform, normal, ellipse, border, rectangle, ring, cone, star, and spiral modes.
- Handles area-angle rotation so emitted particles respect the configured shape.
- Keeps emission math separate from the particle runtime.
- Supplies the offset generator used by emitters and presets.

### [emitter.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/particle/emitter.rs)

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

### [math.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/particle/math.rs)

- Keyframe interpolation for particle size, colour, and alpha over normalized lifetime.
- Offers uniform and normal random helpers for emission variance.
- Clamps interpolation inputs and falls back cleanly on empty keyframe sets.
- Supports the numeric shaping layer used by emitter animation.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/particle/mod.rs)

- Particle emitter lifecycle for spawn, simulation, and pooled recycling.
- Collects emission, physics, trail, rendering, and preset helpers under one namespace.
- Keeps particle effects modular while exposing a single runtime surface.

### [particle.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/particle/particle.rs)

- Per-particle runtime state for position, velocity, lifetime, rotation, and acceleration.
- Stores spawn origin and shape seed for force calculations and deterministic geometry.
- Keeps the minimum state needed by the emitter loop.

### [physics_collision.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/particle/physics_collision.rs)

- Bounce particles off rapier colliders using AABB overlap probes.
- Reflects velocity with configurable restitution per collision pass.
- Operates on all live particles in a system each frame.

### [presets.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/particle/presets.rs)

- Ready-made ParticleConfig constructors for common visual effects.
- Covers fire, smoke, rain, snow, sparks, and other standard patterns.
- Returns self-contained configs with tuned lifetime, speed, color ramp, and shape.
- Lets callers start from a stable preset and override fields afterward.
- Makes quick particle authoring simple without hiding the underlying config.

### [render.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/particle/render.rs)

- Render-command generation for particle systems and trails.
- Expands textured particle batches into individual draw calls when needed.
- Keeps untextured particles batched for efficiency.
- Bridges live particle state to renderer submission.

### [shapes.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/particle/shapes.rs)

- Geometric shape primitives that control how individual particles are rendered.
- Covers fills, directional shapes, and composite outlines with inline parameters.
- Gives emitters a compact vocabulary for particle silhouette design.

### [trail.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/particle/trail.rs)

- Ribbon trail built from a deque of aged world-space points.
- Retires points automatically when they exceed the configured lifetime.
- Tapers width and interpolates color from head to tail.
- Can render as triangle-strip commands or as a CPU-rasterized image.
- Provides a lightweight motion trail for fast effects and debug views.

### [visualization.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/particle/visualization.rs)

- Particle visualization helpers that render live ParticleSystem state to ImageData bitmaps.
- Includes a generic renderer plus themed presets for explosions, rain, and spark trails.
- Supports compositing particles over an existing background or painting in place.
- Adds a chart-style lifetime view for inspecting particle counts over time.
- Keeps render inspection separate from the particle simulation core.
- Helps debug effect tuning without touching the live emitter loop.
