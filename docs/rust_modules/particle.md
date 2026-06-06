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

This module delivers a robust particle simulation subsystem designed to model dynamic visual effects like fire, smoke, rain, and explosions. At its core, the system utilizes high-performance pooling to recycle and manage thousands of active particles efficiently. Emitters control the lifecycle, spawning particles continuously or in sudden bursts, updating their positions, velocities, rotations, and lifetimes over each frame, and supporting warm-up cycles to start scenes in a fully settled state.

Visual behavior is highly configurable through detailed shape distributions and environmental forces. Emitters spawn particles from diverse spatial shapes, including circles, cones, spirals, and custom user callbacks, and direct their paths using linear, radial, and tangential acceleration. The simulation integrates physical forces such as gravity, drag, orbit, and wind turbulence, and can apply gravity-based attractors or axis-aligned bounce boundaries to steer particle trajectories.

For advanced presentations, the module features color and size keyframe interpolation, ribbon trails, and nested hierarchies. Particles animate their size, opacity, and color over their lifespan, rendering as textured or untextured batches. Ribbon trails track motion paths with tapered widths and smooth color gradients. Emitters can also spawn nested sub-emitters on particle death, enabling complex chain reactions like exploding firework sparks.

The subsystem also integrates with physics colliders and offline visualization utilities. Particles can collide and bounce off solid shapes in the physics world, reflecting velocity with custom bounce parameters. Additionally, diagnostic tools let developers export particle snapshots and lifetime charts directly into CPU-side image buffers. This simplifies testing, tuning, and asset design processes without affecting the active simulation loops.

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
