# Module Guides

Module pages explain what each `lurek.*` namespace is for, when to use it, common patterns, examples, and its generated API details. This index lists every public user-facing module generated from `docs/meta/modules.toml`.

## Foundations

| Module | Namespace | Purpose |
|---|---|---|
| [Binary](modules/binary.md) | `lurek.binary` | Manages byte buffers, format packing, compression, hashing, and byte-safe encodings. |
| [Color](modules/color.md) | `lurek.color` | Manages color spaces, blends, and retro palettes. |
| [Compute](modules/compute.md) | `lurek.compute` | Manages dense array math, linear algebra, and FFT transforms. |
| [Dataframe](modules/dataframe.md) | `lurek.dataframe` | Manages DataFrames, databases, SQL query execution, and lazy pipelines. |
| [Graph](modules/flownet.md) | `lurek.graph` | Simulates directed logistics networks using node inventories, push-pull rates, and overflow policies. |
| [Globe](modules/globe.md) | `lurek.globe` | Manages spherical map registries, orbit projections, picking hit tests, and split views. |
| [Layout](modules/layout.md) | `lurek.layout` | Computes graph layouts with grid snapping. |
| [Log](modules/log.md) | `lurek.log` | Runs structured logs with level-filtered sinks. |
| [Math](modules/math.md) | `lurek.math` | Provides vectors, matrices, spatial indexes (AABB tree and spatial hash), and polygon geometry. |
| [Patterns](modules/patterns.md) | `lurek.patterns` | Provides a comprehensive architectural toolkit for state, decision, and communication coordination. |
| [Procgen](modules/procgen.md) | `lurek.procgen` | Orchestrates deterministic generation of terrain heightmaps, biomes, dungeons, and overworlds. |
| [Serial](modules/serialize.md) | `lurek.serial` | Translates JSON, TOML, CSV, XML, INI, and MessagePack via one intermediate tree. |
| [SVG](modules/vector.md) | `lurek.svg` | Provides dynamic SVG vector parsing, hit-testing, state read-back, hierarchy navigation, and GPU-cached rendering. |

## Core Runtime

| Module | Namespace | Purpose |
|---|---|---|
| [Event](modules/event.md) | `lurek.event` | Runs a dual-priority event queue and wildcard signal registry. |
| [Filesystem](modules/filesystem.md) | `lurek.filesystem` | Sandboxes path resolution, mount overlays, and ZIP archives. |
| [Network](modules/network.md) | `lurek.network` | Manages ENet UDP hosts, TCP/WebSocket pools, and ureq-backed HTTP/SSE channels. |
| [Repl](modules/repl.md) | `lurek.repl` | Evaluates Lua inputs with tab completion. |
| [Runtime](modules/runtime.md) | `lurek.runtime` | Manages engine shared state, asset registries, and configurations. |
| [Thread](modules/thread.md) | `lurek.thread` | Parallel Lua workers via isolated threads, safe channels, and promises. |
| [Timer](modules/timer.md) | `lurek.timer` | Clock system with smoothed deltas, FPS telemetry, and schedulers for timed callbacks and coroutines. |

## Platform Services

| Module | Namespace | Purpose |
|---|---|---|
| [Audio](modules/audio.md) | `lurek.audio` | Plays static and streaming sound via voice pools and mixing buses. |
| [Camera](modules/camera.md) | `lurek.camera` | Tracks targets smoothly via customizable presets, dead-zones, and bounds. |
| [DSP](modules/dsp.md) | `lurek.dsp` | Manages audio effect graphs, procedural synthesis, level detection, and visualizations. |
| [Effect](modules/effect.md) | `lurek.effect` | Manages visual post-processing stacks, shader parameters, and presets. |
| [Font](modules/font.md) | `lurek.font` | Manages font loading, metrics caching, and text wrapping. |
| [Image](modules/image.md) | `lurek.image` | Manages CPU image buffers, compressed textures, layered stacks, palette remapping, and atlases. |
| [Input](modules/input.md) | `lurek.input` | Unifies keyboard, mouse, gamepad slotting, and touch events into stable inputs. |
| [Light](modules/light.md) | `lurek.light` | Manages point, spot, and directional lights with custom decay falloffs and groups. |
| [Midi](modules/midi.md) | `lurek.midi` | Synthesizes MIDI files. |
| [Physics](modules/physics.md) | `lurek.physics` | Simulates 2D bodies under dynamic, static, kinematic, or sensor behaviors. |
| [Render](modules/render.md) | `lurek.render` | Orchestrates the engine's visual backend using a device-facing wgpu renderer. |
| [Visibility](modules/visibility.md) | `lurek.visibility` | Geometry-agnostic fog-of-war and shadowcasting field-of-view simulation. |
| [Window](modules/window.md) | `lurek.window` | Manages OS window lifecycles, displays, VSync syncs, and viewport scaling with native dialogs. |

## Feature Systems

| Module | Namespace | Purpose |
|---|---|---|
| [Agent](modules/agent.md) | `lurek.agent` | Orchestrates multi-agent AI completions and stateful conversations. |
| [AI](modules/ai.md) | `lurek.ai` | Orchestrates agent choices via behavior trees, FSMs, GOAP, HTN, and utility AI. |
| [Animation](modules/animation.md) | `lurek.animation` | Orchestrates sprite animation playback and processes Aseprite JSON imports. |
| [Asset](modules/asset.md) | `lurek.asset` | Caches, tags, and queries reference-counted asset handles. |
| [Automation](modules/automation.md) | `lurek.automation` | Replays input steps and runs visual test assertions. |
| [Charts](modules/charts.md) | `lurek.charts` | Rasterizes line, bar, area, scatter, pie, histogram, and heatmap charts into RGBA buffers and drawable runtime textures. |
| [Cinematic](modules/cinematic.md) | `lurek.cinematic` | Multi-track timeline system for orchestrating game sequences. |
| [Cursor](modules/cursor.md) | `lurek.cursor` | Manages contextual custom cursors, motion trails, and magnifiers. |
| [Dialog](modules/dialog.md) | `lurek.dialog` | Orchestrates branching narrative graphs using conditional gates. |
| [ECS](modules/ecs.md) | `lurek.ecs` | Manages an Entity-Component-System database with generational IDs. |
| [Grep](modules/grep.md) | `lurek.grep` | Provides literal-first file scanning, lightweight pattern helpers, and JSON/log searches. |
| [Html](modules/html.md) | `lurek.html` | Runs interactive HTML/CSS documents with input routing, selector queries, and element mutations. |
| [I18n](modules/i18n.md) | `lurek.i18n` | Manages translation catalogs, plural rules, and locale-aware formatting. |
| [Learning](modules/learning.md) | `lurek.learning` | Manages dynamic neural nets, attention blocks, transformers, and flat tensor buffers. |
| [Mapblock](modules/mapblock.md) | `lurek.mapblock` | Assembles tilemaps from block pieces using socket rules, scripts, and multi-level grids. |
| [Minimap](modules/minimap.md) | `lurek.minimap` | Runs grid-based HUD minimaps with fog-of-war, custom markers, raycaster overlays, and camera tracking. |
| [Mods](modules/mods.md) | `lurek.mods` | Manages mod lifecycles using dependency sorting, permission sandboxing, and hot reloads. |
| [Overlay](modules/overlay.md) | `lurek.overlay` | Manages screen-space weather, fog, camera shakes, and screen flashes. |
| [Parallax](modules/parallax.md) | `lurek.parallax` | Manages layered scroll depth, autoscrolling, and tiling. |
| [Particle](modules/particle.md) | `lurek.particle` | Simulates pooled particles with rich shapes, gravity forces, and collider bounces. |
| [Pathfind](modules/pathfind.md) | `lurek.pathfind` | Navigates grids, hex layouts, isometric maps, navmeshes, and province graphs. |
| [Pipeline](modules/pipeline.md) | `lurek.pipeline` | Orchestrates steps using validated dependency graphs. |
| [Province](modules/province.md) | `lurek.province` | Simulates region maps decoded from color-coded PNG cartographic assets. |
| [Raycaster](modules/raycaster.md) | `lurek.raycaster` | Simulates pseudo-3D first-person views from 2D maps using DDA marching. |
| [Save](modules/save.md) | `lurek.save` | Manages game saves with compression, auto-save timers, and schema migrations. |
| [Scene](modules/scene.md) | `lurek.scene` | Manages stack-based scenes, overlays, and metatable factories. |
| [Spine](modules/spine.md) | `lurek.spine` | Simulates skeletal rigs using bone hierarchies, slots, skin swaps, and target IK. |
| [Sprite](modules/sprite.md) | `lurek.sprite` | Manages 2D sprites, JSON atlases, animation sheets, nine-slice panels, and lit-sprite normal-map state. |
| [Terminal](modules/terminal.md) | `lurek.terminal` | Grid terminal supporting ANSI formats, syntax highlighting, and cycling tab-completions. |
| [Tilemap](modules/tilemap.md) | `lurek.tilemap` | Supports orthogonal, isometric, and hex grids with sparse culling, LOD, and standard map imports. |
| [Tween](modules/tween.md) | `lurek.tween` | Timed interpolation engine supporting easing curves, spring dynamics, and sequence composition with coroutine awaiting. |
| [UI](modules/ui.md) | `lurek.ui` | Centralized retained-mode UI context with arena storage, automatic layouts, and resolution scaling. |
| [Validator](modules/validator.md) | `lurek.validator` | Static validator verifying APIs, assets, and imports. |

## Edge/Integration

| Module | Namespace | Purpose |
|---|---|---|
| [App](modules/app.md) | `lurek.engine` | Drives the main winit/wgpu frame loop and Lua VM execution. |
| [Debugbridge](modules/debugbridge.md) | `lurek.debugbridge` | Connects the game runtime to external editor panels. |
| [Devtools](modules/devtools.md) | `lurek.devtools` | Gathers hardware frame stats and runs a hierarchical zone profiler. |
| [Docs](modules/docs.md) | `lurek.docs` | Builds an API catalog to generate editor files and Markdown reference. |

## Page Format

Generated module pages use this structure:

- Purpose
- When to use
- Minimal example
- Common patterns
- API reference and full callable details

Use [Lua API Overview](lua-api.md) when you need to move from a guide to exact signatures.
