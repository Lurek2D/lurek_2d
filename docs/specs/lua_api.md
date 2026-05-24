# lua_api

## TL;DR

- The `lua_api` module serves as the critical Edge/Integration tier composition root for Lurek2D, acting as the primary interface bridge between the high-performance Rust engine and the flexible Lua scripting environment.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/lua_api/`
- Lua API path(s): None direct
- Primary Lua namespace: `lurek.runtime`
- Rust test path(s): tests/rust/unit/; tests/rust/ext/
- Lua test path(s): tests/lua/harness.rs; tests/lua/unit/; tests/lua/integration/; tests/lua/security/; tests/lua/stress/; tests/lua/golden/

## Summary

 Its fundamental responsibility is the creation and configuration of the Lua Virtual Machine (via the `mlua` crate) and the comprehensive registration of all `lurek.*` API namespaces. This module is the structural terminus of the engine's dependency graph—it imports nearly every other core module to expose their functionality, but is strictly never imported by them, ensuring a unidirectional data flow and enforcing architectural boundaries.

At the heart of this module is a vast collection of over 70 custom userdata type definitions that wrap Rust engine structs (such as `LuaVec2`, `LuaLight`, `LuaSpriteBatch`, and `LuaWorld`) and expose them as fully-featured Lua objects. Each engine subsystem has a dedicated binding file (e.g., `audio_api.rs`, `physics_api.rs`, `render_api.rs`) responsible for parsing Lua arguments, invoking the underlying Rust business logic, and safely converting the results back into Lua-compatible values. The module strictly enforces Lurek2D's binding constraints (TST-03): binding files must contain absolutely no domain business logic. Their sole purpose is translation, validation, and error boundary management.

A crucial aspect of the `lua_api` module is its rigorous approach to state management and memory safety across the FFI boundary. All access to engine state from Lua is mediated through `SharedState` borrows, with strict rules preventing mutable borrows (`borrow_mut()`) from being held across Lua callback invocations to avoid deadlocks or runtime panics. The module also automatically handles boundary value clamping for numeric inputs, ensuring that invalid Lua data cannot crash the underlying Rust engine. Furthermore, it manages a robust `CallbackRegistry` system that allows Rust subsystems to safely store and asynchronously invoke Lua functions. Through this extensive binding layer, Lurek2D achieves its goal of providing an ergonomic, fully-scriptable game development experience backed by a robust systems-level runtime.

## Source Documentation

### `ai_api.rs`
- `lurek.ai` - Lua bindings for AI worlds, agents, blackboards, behavior trees, steering, planning, learning, and simulation helpers.

### `animation_api.rs`
- `lurek.animation` -- Animation bindings for sprite clips, state machines, blend layers, curves, sync groups, and Aseprite import helpers.

### `audio_api.rs`
- `lurek.audio` - Audio playback, mixing, spatial sound, MIDI, and DSP processing for 2D games.

### `automation_api.rs`
- `lurek.automation` -- Automation bindings for loading simulator scripts, controlling playback, inspecting state, saving macros, and waiting on Lua predicates.

### `callback_registry.rs`
- Public types and helpers for the callback_registry module.

### `camera_api.rs`
- `lurek.camera` -- Camera bindings for 2D transforms, targets, bounds, screen conversion, paths, zoom tweens, parallax factors, effects, constraints, presets, and camera rigs.

### `compute_api.rs`
- `lurek.compute` -- Compute bindings for multidimensional arrays, numeric operations, reductions, spatial filters, analytics, linear algebra, FFT helpers, and parallel threshold tuning.

### `data_api.rs`
- `lurek.data` -- Data bindings for binary packing, compression, encoding, hashing, byte buffers, data views, TOML conversion, ring buffers, and structured writers.

### `dataframe_api.rs`
- `lurek.dataframe` -- DataFrame bindings for tabular rows, columns, grouping, joins, SQL queries, lazy pipelines, databases, vectorized frames, serialization, and statistics.

### `debugbridge_api.rs`
- `lurek.debugbridge` -- Debug bridge bindings for starting the local TCP bridge, polling debugger requests, print capture, performance data, screenshots, protocol metadata, and hot reload flags.

### `devtools_api.rs`
- `lurek.devtools` -- Developer tooling bindings for logs, profiling, frame stats, file watching, console state, watch expressions, snapshots, REPL, and debugger-style eval helpers.

### `docs_api.rs`
- `lurek.docs` -- Documentation tooling bindings for live API reflection, editable catalogs, quality reports, schema validation, and export helpers that produce editor and Markdown artifacts from Lua-visible API metadata.

### `ecs_api.rs`
- `lurek.ecs` -- Entity-component-system bindings for creating universes, managing entities and components, running Lua systems, querying tags and blueprints, serializing state, and tracking hierarchy and relation data.

### `effect_api.rs`
- `lurek.effect` -- Visual effect bindings for post-processing passes, effect stacks, image effect chains, screen overlays, weather and ambient controls, screen transitions, and shader error display state used by the renderer command queue.

### `engine_api.rs`
- `lurek.engine` -- Runtime metadata and diagnostics bindings for version, platform, uptime, FPS, frame counters, resource memory budgets, frame timing profile tables, and configuration reload revision exposed to Lua scripts.

### `event_api.rs`
- `lurek.event` -- Event queue and signal bindings for quit/restart requests, polling, waiting, immediate and deferred event pushes, priority delivery, optional history capture, and Lua callback signal dispatch.

### `filesystem_api.rs`
- `lurek.filesystem` -- GameFS bindings for text, binary, JSON, directory, metadata, async IO, mount, ZIP archive, file handle, file data, watcher, path conversion, and script chunk loading operations available to Lua.

### `globe_api.rs`
- `lurek.globe` -- Spherical province-map bindings for globe registries, province graphs, sectors, heat layers, camera controls, picking, fog of war, markers, labels, render layers, arcs, pathfinding, exports, and coordinate math.

### `graph_api.rs`
- `lurek.graph` -- Logistics graph bindings for nodes, directed edges, typed items, capacities, queues, conversion rules, supply and demand, pathfinding, reachability, graph algorithms, events, and Lua callbacks.

### `html_api.rs`
- `lurek.html` -- HTML document bindings for markup and CSS loading, layout, rendering into engine draw commands, DOM element selection and mutation, input forwarding, event listeners, and feature support checks.

### `i18n_api.rs`
- `lurek.i18n` -- Localization bindings for in-memory catalogs, locale selection, fallback lists, translation lookup, interpolation, plural and gender variants, search indexes, formatting helpers, locale validation, and coverage gap reports.

### `image_api.rs`
- `lurek.image` -- Image bindings for pixel buffers, encoded image load/save, layered image stacks, DDS compressed metadata, palette lookup tables, province color grids, polygon extraction, shape rendering, and screen capture handoff.

### `input_api.rs`
- `lurek.input` -- Input bindings for keyboard, mouse, cursor objects, gamepads, touch points, action mappings, combo detection, virtual d-pad conversion, input recording, and playback state exposed through nested Lua tables.

### `light_api.rs`
- `lurek.light` -- 2D lighting bindings for light handles, occluders, ambient color, shadows, masks, groups, flicker animation, transitions, cookies, normal-map hints, and renderer-facing lighting world state.

### `log_api.rs`
- `lurek.log` -- Logging bindings for severity helpers, global level control, memory/file/rotating/callback sinks, sink listing and flushing, memory reads, structured field logs, tag filters, and Lua callback dispatch.

### `lua_types.rs`
- Public types and helpers for the lua_types module.

### `math_api.rs`
- `lurek.math` -- Math bindings for vectors, splines, random generators, transforms, curves, tweens, spatial queries, noise generation, circles, AABB trees, rectangle packing, easing, geometry, polygon operations, colors, and scalar helpers.

### `minimap_api.rs`
- `lurek.minimap` -- Lua bindings for grid minimaps, terrain colors, fog, object markers, overlays, layers, hover conversion, and render command output.

### `mod.rs`
- Lua API binding modules and shared runtime re-exports for building Lurek2D Lua VMs.

### `mods_api.rs`
- `lurek.mods` -- Lua bindings for mod metadata, mod manager load order/dependency helpers, content registries, and API version checks.

### `network_api.rs`
- `lurek.network` -- Lua bindings for ENet-style hosts, async network runtime, message packing, lobby helpers, relay tickets, and snapshot prediction.

### `parallax_api.rs`
- `lurek.parallax` -- Lua bindings for parallax layers, parallax sets, presets, automatic camera rendering, tiling, blend modes, and effect chains.

### `particle_api.rs`
- `lurek.particle` -- Lua bindings for particle systems, trails, presets, TOML configs, physics collision, custom emission callbacks, death callbacks, and module-level forwarding helpers.

### `pathfind_api.rs`
- `lurek.pathfind` - Lua bindings for navigation grids, unit pathfinding, flow fields, path grids, hex grids, JPS grids, nav meshes, range maps, and tilemap-derived path data.

### `patterns_api.rs`
- `lurek.patterns` — Design pattern utilities: event buses, object pools, state machines, command stacks, observers, mediators, factories, data structures, behavior trees, and graphs.

### `physics_api.rs`
- `lurek.physics` — 2D rigid-body physics: worlds, bodies, shapes, joints, raycasting, collision queries, terrain, cellular simulation, and debug drawing via Rapier2D.

### `pipeline_api.rs`
- `lurek.pipeline` — Declarative task pipelines with dependency ordering, retry logic, branching, and async coroutine execution.

### `procgen_api.rs`
- `lurek.procgen` — Procedural generation tools: noise, dungeon generators, wave function collapse, heightmaps, L-systems, name generation, voronoi, biomes, and world graphs.

### `province_api.rs`
- `lurek.province` — Province-based strategic map system with grid regions, borders, ownership tracking, adjacency queries, and map-mode rendering.

### `raycaster_api.rs`
- `lurek.raycaster` - Provides a pseudo-3D raycasting engine for first-person dungeon crawlers with textured walls, floors, and ceilings.

### `register.rs`
- Lua VM creation and `lurek.*` module registration entry point.

### `render_api.rs`
- `lurek.render` - Provides 2D drawing primitives, texture rendering, text output, blend modes, and render state management.

### `repl_api.rs`
- `lurek.repl` -- Release-safe Lua REPL session bindings for interactive evaluation.

### `save_api.rs`
- `lurek.save` — Persistent game save/load system with named slots, schema versioning, auto-save, compression, and migration support.

### `scene_api.rs`
- `lurek.scene` — Stack-based scene management with animated transitions, overlay support, shared data passing, lifecycle callbacks (enter/leave/pause/resume/ready/update/draw/render), and depth-sorted rendering via `LDepthSorter`.

### `serial_api.rs`
- `lurek.serial` — Data serialization and deserialization with JSON, TOML, CSV, XML, INI, and MessagePack encoding/decoding for game configuration, save data, and inter-system data exchange.

### `spine_api.rs`
- `lurek.spine` — Spine-like skeletal animation with bones, slots, attachments, IK constraints, and skin mixing.

### `sprite_api.rs`
- `lurek.sprite` - Provides sprite batch rendering, sprite sheets, quad management, and texture atlas operations for efficient 2D rendering.

### `system_api.rs`
- `lurek.system` - Provides OS-level utilities including clipboard, system info, environment variables, and platform detection.

### `terminal_api.rs`
- `lurek.terminal` - Provides an in-game terminal emulator with command parsing, history, output buffering, and ANSI-style formatting.

### `thread_api.rs`
- `lurek.thread` - Provides multi-threaded Lua worker VMs with typed channel messaging for parallel game logic execution.

### `tilemap_api.rs`
- `lurek.tilemap` - Provides tile-based map rendering with layers, animated tiles, auto-tiling, collision maps, and TMX/Tiled import.

### `timer_api.rs`
- `lurek.timer` - Provides time management with delta time, fixed timestep, cooldowns, delays, intervals, and frame counting.

### `tween_api.rs`
- `lurek.tween` - Provides value tweening with easing functions, sequences, parallel groups, and property animation for smooth game transitions.

### `ui_api.rs`
- `lurek.ui` - Provides immediate-mode and retained-mode UI widgets including buttons, sliders, text inputs, panels, and layout containers.

### `window_api.rs`
- `lurek.window` - Provides window management with resizing, fullscreen, title, icon, DPI scaling, and display mode control.

## Types

- `LuaAnimation` (`struct`, `animation_api.rs`): Lua-side wrapper around an [`Animation`] controller.
- `LuaAnimStateMachine` (`struct`, `animation_api.rs`): Lua-side wrapper around an [`AnimStateMachine`] FSM controller.
- `LuaBlendLayerSet` (`struct`, `animation_api.rs`): Lua-side wrapper around a [`BlendLayerSet`] blend layer compositor.
- `LuaAnimCurve` (`struct`, `animation_api.rs`): Lua-side wrapper around an [`AnimCurve`].
- `LuaAnimSyncGroup` (`struct`, `animation_api.rs`): Lua-side wrapper around an [`AnimSyncGroup`].
- `LuaSource` (`struct`, `audio_api.rs`): Lua-side wrapper for an audio source resource.
- `LuaBus` (`struct`, `audio_api.rs`): Lua-side wrapper for an audio bus resource.
- `LuaMidiPlayer` (`struct`, `audio_api.rs`): Lua-side wrapper for the MIDI player.
- `LuaSoundPool` (`struct`, `audio_api.rs`): Lua-side wrapper for a polyphonic [`crate::audio::SoundPool`].
- `LuaDecoder` (`struct`, `audio_api.rs`): Lua-side wrapper for a streaming audio decoder.
- `CallbackRegistry` (`struct`, `callback_registry.rs`): Opaque store mapping `u32` IDs to [`LuaRegistryKey`] values.
- `LuaCamera2D` (`struct`, `camera_api.rs`): Lua-side wrapper around a [`Camera2D`] instance.
- `LuaCameraRig` (`struct`, `camera_api.rs`): Lua-side camera rig that manages named cameras and viewport layouts.
- `LuaArray` (`struct`, `compute_api.rs`): Lua-side wrapper around [`NdArray`].
- `LuaRingBuffer` (`struct`, `data_api.rs`): Lua-side fixed-capacity ring buffer that holds any Lua value.
- `LuaDataWriter` (`struct`, `data_api.rs`): Write-cursor wrapper for the `lurek.data` module.
- `LuaGroupedFrame` (`struct`, `dataframe_api.rs`): Lua-side wrapper around a grouped result from [`DataFrame::group_by`].
- `LuaDataFrameTask` (`struct`, `dataframe_api.rs`): Lua-side handle for a threaded dataframe job.
- `LuaDataFrame` (`struct`, `dataframe_api.rs`): Lua-side wrapper around a shared [`DataFrame`].
- `LuaLazyQuery` (`struct`, `dataframe_api.rs`): Lua-side lazy dataframe query pipeline.
- `LuaDatabase` (`struct`, `dataframe_api.rs`): Lua-side wrapper around a shared [`Database`].
- `LuaVecFrame` (`struct`, `dataframe_api.rs`): Thin Lua wrapper around a [`VecFrame`]: typed-column vectorized DataFrame.
- `LuaReplConsole` (`struct`, `devtools_api.rs`): Lua-side wrapper around a [`ReplConsole`] interactive evaluator.
- `LuaUniverse` (`struct`, `ecs_api.rs`): Lua-side wrapper around a [`Universe`] ECS world.
- `LuaPostFxEffect` (`struct`, `effect_api.rs`): Lua-side wrapper around [`PostFxEffect`].
- `LuaPostFxStack` (`struct`, `effect_api.rs`): Lua-side wrapper around [`PostFxStack`].
- `LuaImageEffect` (`struct`, `effect_api.rs`): Lua-side wrapper around [`ImageEffect`].
- `LuaOverlay` (`struct`, `effect_api.rs`): Lua-side wrapper around [`Overlay`].
- `LuaScreenTransition` (`struct`, `effect_api.rs`): Lua-side wrapper around a [`crate::effect::ScreenTransition`].
- `LuaSignal` (`struct`, `event_api.rs`): Lua-side wrapper around a [`Signal`] with registry-stored callbacks.
- `LuaFileData` (`struct`, `filesystem_api.rs`): Lua-side wrapper around a [`FileData`] buffer.
- `LuaFileHandle` (`struct`, `filesystem_api.rs`): Lua-side wrapper around a [`FileHandle`] with interior mutability.
- `LuaGlobe` (`struct`, `globe_api.rs`): Lua-accessible handle to a `Globe` inside a `GlobeRegistry`.
- `LuaGlobeRegistry` (`struct`, `globe_api.rs`): Lua-accessible handle to the shared `GlobeRegistry`.
- `LuaProvinceGrid` (`struct`, `image_api.rs`): Lua-side wrapper around [`ProvinceGrid`].
- `LuaLayeredImage` (`struct`, `image_api.rs`): Lua-side wrapper around [`LayeredImage`].
- `LuaCompressedImageData` (`struct`, `image_api.rs`): Lua-side wrapper around [`CompressedImageData`].
- `LuaPaletteLUT` (`struct`, `image_api.rs`): Lua-side wrapper around [`PaletteLUT`].
- `LuaCursor` (`struct`, `input_api.rs`): Lua-side wrapper around a mouse cursor handle.
- `LuaLight` (`struct`, `light_api.rs`): Lua-side handle to a light resource stored in [`LightWorld`].
- `LuaOccluder` (`struct`, `light_api.rs`): Lua-side handle to an occluder resource stored in [`LightWorld`].
- `LurekType` (`trait`, `lua_types.rs`): Marker trait that every Lua UserData type in Lurek2D must implement.
- `LuaVec2` (`struct`, `math_api.rs`): Lua-side wrapper around a [`Vec2`] value type.
- `LuaVec3` (`struct`, `math_api.rs`): Lua-side wrapper around a [`Vec3`] value type.
- `LuaCatmullRom` (`struct`, `math_api.rs`): Lua-side wrapper around a [`CatmullRomSpline`].
- `LuaHermite` (`struct`, `math_api.rs`): Lua-side wrapper around a [`HermiteSpline`].
- `LuaRandomGenerator` (`struct`, `math_api.rs`): Lua-side wrapper around a [`RandomGenerator`].
- `LuaTransform` (`struct`, `math_api.rs`): Lua-side wrapper around a [`Transform`].
- `LuaBezierCurve` (`struct`, `math_api.rs`): Lua-side wrapper around a [`BezierCurve`].
- `LuaTween` (`struct`, `math_api.rs`): Lua-side wrapper around a [`Tween`].
- `LuaSpatialHash` (`struct`, `math_api.rs`): Lua-side wrapper around a [`SpatialHash`].
- `LuaNoiseGenerator` (`struct`, `math_api.rs`): Lua-side wrapper around a [`NoiseGenerator`].
- `LuaCircle` (`struct`, `math_api.rs`): Lua-side wrapper around a [`Circle`].
- `LuaAabbTree` (`struct`, `math_api.rs`): Lua-side wrapper around an [`AabbTree`].
- `LuaRectPacker` (`struct`, `math_api.rs`): Lua-side wrapper for a rectangle packer.
- `LuaMinimap` (`struct`, `minimap_api.rs`): Lua-side wrapper around a [`Minimap`].
- `LuaMod` (`struct`, `mods_api.rs`): Lua-side wrapper around [`ModInfo`] with per-mod hook and config storage.
- `LuaModManager` (`struct`, `mods_api.rs`): Lua-side wrapper around [`ModManager`].
- `LuaContentRegistry` (`struct`, `mods_api.rs`): A typed content registry for mod-contributed assets and objects.
- `LuaNetworkHost` (`struct`, `network_api.rs`): Lua-side wrapper around [`NetworkHost`].
- `LuaNetworkRuntime` (`struct`, `network_api.rs`): Lua-side wrapper around [`NetworkRuntime`] for async HTTP/TCP/WebSocket.
- `LuaParallaxLayer` (`struct`, `parallax_api.rs`): Lua-side handle to a single parallax background layer.
- `LuaParallaxSet` (`struct`, `parallax_api.rs`): Lua-side container that groups `LuaParallaxLayer` objects for scene-level management.
- `LuaParticleSystem` (`struct`, `particle_api.rs`): Lua-side handle to a particle system stored in SharedState.
- `LuaTrail` (`struct`, `particle_api.rs`): Lua-side wrapper around a [`Trail`] ribbon effect.
- `LuaNavGrid` (`struct`, `pathfind_api.rs`): Lua-side wrapper around a [`NavGrid`] with optional HPA★ abstract graph.
- `LuaUnitPathfinder` (`struct`, `pathfind_api.rs`): Lua-side wrapper around a [`UnitPathfinder`].
- `LuaFlowField` (`struct`, `pathfind_api.rs`): Lua-side wrapper around a [`FlowField`].
- `LuaPathGrid` (`struct`, `pathfind_api.rs`): Lua-side wrapper around a [`PathGrid`] (A★ weighted grid with per-cell cost).
- `LuaAiFlowField` (`struct`, `pathfind_api.rs`): Lua-side wrapper around a PathGrid-based [`AiFlowField`].
- `LuaHexGrid` (`struct`, `pathfind_api.rs`): Lua-side wrapper around a [`HexGrid`].
- `LuaJpsGrid` (`struct`, `pathfind_api.rs`): Lua-side wrapper around a [`JpsGrid`].
- `LuaNavMesh` (`struct`, `pathfind_api.rs`): Lua-side wrapper for a navigation mesh.
- `LuaWorld` (`struct`, `physics_api.rs`): Lua-side handle wrapping a physics World.
- `LuaZone` (`struct`, `physics_api.rs`): Lua-side handle to a [`PhysicsZone`] living inside a [`World`].
- `LuaTerrain` (`struct`, `physics_api.rs`): Lua-side handle to a destructible [`TerrainMap`].
- `LuaCellular` (`struct`, `physics_api.rs`): Lua-side handle to a falling-sand [`CellularWorld`].
- `LuaBody` (`struct`, `physics_api.rs`): Lua-side handle to a physics body accessed through its world.
- `LuaPhysicsShape` (`struct`, `physics_api.rs`): Lua-side standalone shape object (circle, rectangle, edge, polygon, chain).
- `LuaStep` (`struct`, `pipeline_api.rs`): Lua-side wrapper around a single [`PipelineStep`], plus Lua callback registry keys.
- `LuaPipeline` (`struct`, `pipeline_api.rs`): Lua-side wrapper around a [`Pipeline`] DAG with scheduler and Lua callback registry.
- `LuaBiomeClassifier` (`struct`, `procgen_api.rs`): Lua-visible wrapper around the biome classification engine, used to assign biome types based on height, moisture, and temperature.
- `LuaProvinceRegistry` (`struct`, `province_api.rs`): Lua handle referencing one named engine-side province registry.
- `LuaDoorManager` (`struct`, `raycaster_api.rs`): Lua-side wrapper around a [`DoorManager`], managing sliding doors in a level.
- `LuaHeightMap` (`struct`, `raycaster_api.rs`): Lua-side wrapper around a [`HeightMap`] for variable floor/ceiling heights.
- `LuaPointLight` (`struct`, `raycaster_api.rs`): Lua-side value wrapper around a raycaster [`PointLight`].
- `LuaRaycaster` (`struct`, `raycaster_api.rs`): Lua-side wrapper around a [`Raycaster2D`] grid.
- `LuaSpriteManager` (`struct`, `raycaster_api.rs`): Lua-side wrapper around a [`SpriteManager`] for batch depth-sorted sprite projection.
- `LuaImageData` (`struct`, `render_api.rs`): Lua-side handle to a loaded texture stored in SharedState.
- `LuaImage` (`struct`, `render_api.rs`): Lua-side handle to a loaded GPU texture stored in the engine's texture pool.
- `LuaNineSlice` (`struct`, `render_api.rs`): Lua-side 9-slice descriptor.
- `LuaFont` (`struct`, `render_api.rs`): Lua-side handle to a loaded font stored in SharedState.
- `LuaCanvas` (`struct`, `render_api.rs`): Lua-side handle to an off-screen render target stored in SharedState.
- `LuaSpriteBatch` (`struct`, `render_api.rs`): Lua-side handle to a sprite batch stored in SharedState.
- `LuaMesh` (`struct`, `render_api.rs`): Lua-side handle to a mesh stored in SharedState.
- `LuaShader` (`struct`, `render_api.rs`): Lua-side handle to a compiled shader stored in SharedState.
- `LuaQuad` (`struct`, `render_api.rs`): Lua-side quad viewport into a texture.
- `LuaShape` (`struct`, `render_api.rs`): Lua-side handle to a [`CompoundShape`] stored in [`SharedState::shapes`].
- `LObjModel` (`struct`, `render_api.rs`): Lua-side handle to a parsed Wavefront OBJ model.
- `LReplSession` (`struct`, `repl_api.rs`): Lua-side REPL session handle with bounded history.
- `LuaSaveManager` (`struct`, `save_api.rs`): Lua-side wrapper around [`SaveManager`] with per-module callback storage.
- `LuaDepthSorter` (`struct`, `scene_api.rs`): Lua-side wrapper around a [`DepthSorter`] with registry-stored callbacks.
- `LuaSkeleton` (`struct`, `spine_api.rs`): Lua-side wrapper around a [`Skeleton`].
- `LuaSkeletonAnimation` (`struct`, `spine_api.rs`): Lua-side wrapper around a [`SkeletonAnimation`] keyframe clip.
- `LuaSpriteSheet` (`struct`, `sprite_api.rs`): Lua-side wrapper around a [`SpriteSheet`] frame-grid calculator.
- `LuaSpriteAtlas` (`struct`, `sprite_api.rs`): Lua-side wrapper around a [`SpriteAtlas`] named-region store.
- `LuaThreadHandle` (`struct`, `thread_api.rs`): Lua-side wrapper around a background [`LuaThread`].
- `LuaThreadPool` (`struct`, `thread_api.rs`): Lua-side wrapper around a [`ThreadPool`].
- `LuaPromise` (`struct`, `thread_api.rs`): Lua-side wrapper around a one-shot [`Promise`].
- `LuaTileSet` (`struct`, `tilemap_api.rs`): Lua-side wrapper around a [`TileSet`].
- `LuaTileMap` (`struct`, `tilemap_api.rs`): Lua-side wrapper around a [`TileMap`].
- `LuaAutoTileSheet` (`struct`, `tilemap_api.rs`): Lua-side wrapper around an [`AutoTileSheet`].
- `LuaChunkMap` (`struct`, `tilemap_api.rs`): Lua-side wrapper around a [`ChunkMap`].
- `LuaLargeMapRenderer` (`struct`, `tilemap_api.rs`): Lua-side wrapper around a [`LargeMapRenderer`] for chunk-level occlusion culling on large worlds.
- `LuaIsoMap` (`struct`, `tilemap_api.rs`): Lua-side wrapper around an [`IsoMap`].
- `LuaMapBlock` (`struct`, `tilemap_api.rs`): Lua-side wrapper around a [`MapBlock`].
- `LuaMapGroup` (`struct`, `tilemap_api.rs`): Lua-side wrapper around a [`MapGroup`].
- `LuaMapScript` (`struct`, `tilemap_api.rs`): Lua-side wrapper around a [`MapScript`] procedural generation script.
- `LuaMapGen` (`struct`, `tilemap_api.rs`): Lua-side wrapper for a map generator (size preset or explicit dimensions).
- `LuaScheduler` (`struct`, `timer_api.rs`): Lua-side wrapper around a [`Scheduler`] with per-event callback storage.
- `LuaTweenState` (`struct`, `tween_api.rs`): Lua-side wrapper around the pure-Rust [`TweenState`] timing core.
- `LuaSpring` (`struct`, `tween_api.rs`): Lua-side spring handle: wraps [`SpringSystem`] and a registry reference to the target table.
- `LuaLineChart` (`struct`, `ui_api.rs`): Lua wrapper for a line chart renderer.
- `LuaBarChart` (`struct`, `ui_api.rs`): Lua wrapper for a grouped bar chart renderer.
- `LuaScatterPlot` (`struct`, `ui_api.rs`): Lua wrapper for a scatter plot renderer.
- `LuaPieChart` (`struct`, `ui_api.rs`): Lua wrapper for a pie chart renderer.
- `LuaAreaChart` (`struct`, `ui_api.rs`): Lua wrapper for a stacked area chart renderer.

## Functions

- `register` (`ai_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`animation_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`audio_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`automation_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `Step::vec_from_lua_table` (`automation_api.rs`): Converts a Lua array of step tables into automation steps.
- `CallbackRegistry::new` (`callback_registry.rs`): Creates a new value.
- `CallbackRegistry::register` (`callback_registry.rs`): Register.
- `CallbackRegistry::get` (`callback_registry.rs`): Returns a value.
- `CallbackRegistry::remove` (`callback_registry.rs`): Removes or clears stored state.
- `CallbackRegistry::contains` (`callback_registry.rs`): Contains.
- `CallbackRegistry::clear` (`callback_registry.rs`): Removes or clears stored state.
- `CallbackRegistry::len` (`callback_registry.rs`): Len.
- `CallbackRegistry::is_empty` (`callback_registry.rs`): Returns true if empty.
- `CallbackRegistry::invoke` (`callback_registry.rs`): Invoke.
- `LuaCamera2D::visible_area` (`camera_api.rs`): Returns the camera visible area tuple for engine-side helpers.
- `LuaCamera2D::position` (`camera_api.rs`): Returns the camera position tuple for engine-side helpers.
- `register` (`camera_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`compute_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`data_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `LuaDataFrame::borrow_dataframe` (`dataframe_api.rs`): Borrows the inner dataframe for cross-binding helpers.
- `LuaVecFrame::new` (`dataframe_api.rs`): Wraps a vectorized frame in shared Lua userdata state.
- `register` (`dataframe_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`debugbridge_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`devtools_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`docs_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`ecs_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`effect_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`engine_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`event_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`filesystem_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`globe_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`graph_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`html_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`i18n_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`image_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`input_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`light_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`log_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `add_type_methods` (`lua_types.rs`): Adds the standard `type()`, `typeOf(typeName)`, and `__tostring` methods to any [`LuaUserData`] type that also implements [`LunaType`].
- `register` (`math_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`minimap_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `LuaMod::new` (`mods_api.rs`): Creates a Lua mod wrapper from mod metadata.
- `LuaModManager::new` (`mods_api.rs`): Creates an empty Lua mod manager wrapper.
- `LuaContentRegistry::new` (`mods_api.rs`): Creates an empty content registry with no registered types or entries.
- `register` (`mods_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`network_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`parallax_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`particle_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `ParticleConfig::from_lua_opts` (`particle_api.rs`): Builds a particle config from a Lua options table.
- `register` (`pathfind_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`patterns_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `LuaWorld::world_handle` (`physics_api.rs`): World handle.
- `register` (`physics_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `LuaStep::new` (`pipeline_api.rs`): Wraps an existing pipeline step in a Lua-visible userdata handle.
- `LuaStep::execute_sync` (`pipeline_api.rs`): Execute sync.
- `LuaPipeline::new` (`pipeline_api.rs`): Creates a new Lua-visible pipeline wrapper around a pipeline value.
- `LuaPipeline::from_parts` (`pipeline_api.rs`): Rebuilds a Lua pipeline wrapper from shared pipeline and step-wrapper state.
- `pipeline_result_to_lua` (`pipeline_api.rs`): Converts a `PipelineResult` to a Lua result table for the `run` return value.
- `cancel_remaining_steps` (`pipeline_api.rs`): Cancels all steps in `order` that are still pending.
- `fire_step_callbacks` (`pipeline_api.rs`): Fires the per-step pipeline callbacks based on the step's terminal status.
- `finalize_pipeline_result` (`pipeline_api.rs`): Finalises a pipeline run: collects the `PipelineResult`, converts it to a Lua table, and fires the `on_complete` callback if registered.
- `register` (`pipeline_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `BiomeRules::from_lua_table` (`procgen_api.rs`): Builds biome classification rules from a Lua options table.
- `BiomeType::from_name` (`procgen_api.rs`): Parses a biome type name into its enum variant.
- `register` (`procgen_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `CellularOpts::from_lua_table` (`procgen_api.rs`): Builds cellular-generation options from a Lua options table.
- `VoronoiOpts::from_lua_table` (`procgen_api.rs`): Builds Voronoi-generation options from a Lua options table.
- `register` (`province_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`raycaster_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `create_lua_vm` (`register.rs`): Creates and configures the Lua VM, registers `lurek.*` sub-APIs according to the provided module flags, and returns the ready `Lua` instance.
- `create_headless_vm` (`register.rs`): Creates a Lua VM with no-window headless module profile applied.
- `create_test_vm` (`register.rs`): Creates a test Lua VM with the BDD test framework loaded and all available API modules registered.
- `register` (`render_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`repl_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `LuaSaveManager::new` (`save_api.rs`): Creates a new Lua-visible save manager bound to shared engine state.
- `register` (`save_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`scene_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`serial_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`spine_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`sprite_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`system_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`terminal_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`thread_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`tilemap_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`timer_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `LuaSpring::tick_with` (`tween_api.rs`): Advances the spring simulation and writes updated axis values back into the target table.
- `register` (`tween_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`ui_api.rs`): Registers the `lurek.window` API table with the Lua VM.
- `register` (`window_api.rs`): Registers the `lurek.window` API table with the Lua VM.

## Lua API Reference

- Namespace: `lurek.runtime`

## References

- `ai`: Imports or references `ai` from `src/ai/`.
- `animation`: Imports or references `animation` from `src/animation/`.
- `app`: Imports or references `src/app/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `audio`: Imports or references `audio` from `src/audio/`.
- `automation`: Imports or references `automation` from `src/automation/`.
- `camera`: Imports or references `camera` from `src/camera/`.
- `compute`: Imports or references `compute` from `src/compute/`.
- `data`: Imports or references `data` from `src/data/`.
- `dataframe`: Imports or references `dataframe` from `src/dataframe/`.
- `debugbridge`: Imports or references `debugbridge` from `src/debugbridge/`.
- `devtools`: Imports or references `devtools` from `src/devtools/`.
- `docs`: Imports or references `docs` from `src/docs/`.
- `ecs`: Imports or references `ecs` from `src/ecs/`.
- `effect`: Imports or references `effect` from `src/effect/`.
- `event`: Imports or references `event` from `src/event/`.
- `filesystem`: Imports or references `filesystem` from `src/filesystem/`.
- `globe`: Imports or references `src/globe/`. Cross-group dependency from ``Edge/Integration`` into `Edge/Integration`.
- `graph`: Imports or references `graph` from `src/graph/`.
- `html`: Imports or references `src/html/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `i18n`: Imports or references `i18n` from `src/i18n/`.
- `image`: Imports or references `image` from `src/image/`.
- `input`: Imports or references `input` from `src/input/`.
- `light`: Imports or references `light` from `src/light/`.
- `log`: Imports or references `log` from `src/log/`.
- `math`: Imports or references `math` from `src/math/`.
- `minimap`: Imports or references `minimap` from `src/minimap/`.
- `mods`: Imports or references `mods` from `src/mods/`.
- `network`: Imports or references `network` from `src/network/`.
- `parallax`: Imports or references `parallax` from `src/parallax/`.
- `particle`: Imports or references `particle` from `src/particle/`.
- `pathfind`: Imports or references `pathfind` from `src/pathfind/`.
- `patterns`: Imports or references `patterns` from `src/patterns/`.
- `physics`: Imports or references `physics` from `src/physics/`.
- `pipeline`: Imports or references `pipeline` from `src/pipeline/`.
- `procgen`: Imports or references `procgen` from `src/procgen/`.
- `province`: Imports or references `src/province/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `raycaster`: Imports or references `raycaster` from `src/raycaster/`.
- `render`: Imports or references `render` from `src/render/`.
- `repl`: Imports or references `src/repl/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
- `save`: Imports or references `save` from `src/save/`.
- `scene`: Imports or references `scene` from `src/scene/`.
- `serial`: Imports or references `serial` from `src/serial/`.
- `spine`: Imports or references `spine` from `src/spine/`.
- `sprite`: Imports or references `sprite` from `src/sprite/`.
- `terminal`: Imports or references `terminal` from `src/terminal/`.
- `thread`: Imports or references `thread` from `src/thread/`.
- `tilemap`: Imports or references `tilemap` from `src/tilemap/`.
- `timer`: Imports or references `timer` from `src/timer/`.
- `tween`: Imports or references `tween` from `src/tween/`.
- `ui`: Imports or references `ui` from `src/ui/`.
- `window`: Imports or references `window` from `src/window/`.

## Notes

- Keep this module reference synchronized with `src/lua_api/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
- `create_headless_vm()` is the no-window VM profile used by `--headless`. It reuses the same binding layer but applies the headless module mask before registration.
- `repl_api.rs` now owns the release-safe `lurek.repl` surface, while `devtools_api.rs` keeps a compatibility wrapper for `lurek.devtools.newRepl()`.
