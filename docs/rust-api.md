# Rust API Browser

Krótki indeks modułów Rust generowany ze specek.

- [Open Rust API Browser](/rust-docs/index.html)

## Module table

| Module | Source path | Files |
|--------|-------------|-------|
| [`agent`](rust_modules/agent.md) | `src/agent/` | 8 |
| [`ai`](rust_modules/ai.md) | `src/ai/` | 22 |
| [`animation`](rust_modules/animation.md) | `src/animation/` | 12 |
| [`app`](rust_modules/app.md) | `src/app/` | 7 |
| [`audio`](rust_modules/audio.md) | `src/audio/` | 9 |
| [`automation`](rust_modules/automation.md) | `src/automation/` | 4 |
| [`binary`](rust_modules/binary.md) | `src/binary/` | 10 |
| [`camera`](rust_modules/camera.md) | `src/camera/` | 8 |
| [`charts`](rust_modules/charts.md) | `src/charts/` | 8 |
| [`color`](rust_modules/color.md) | `src/color/` | 4 |
| [`compute`](rust_modules/compute.md) | `src/compute/` | 7 |
| [`cursor`](rust_modules/cursor.md) | `src/cursor/` | 8 |
| [`dataframe`](rust_modules/dataframe.md) | `src/dataframe/` | 15 |
| [`debugbridge`](rust_modules/debugbridge.md) | `src/debugbridge/` | 3 |
| [`devtools`](rust_modules/devtools.md) | `src/devtools/` | 8 |
| [`dialog`](rust_modules/dialog.md) | `src/dialog/` | 6 |
| [`docs`](rust_modules/docs.md) | `src/docs/` | 6 |
| [`dsp`](rust_modules/dsp.md) | `src/dsp/` | 7 |
| [`ecs`](rust_modules/ecs.md) | `src/ecs/` | 8 |
| [`effect`](rust_modules/effect.md) | `src/effect/` | 8 |
| [`event`](rust_modules/event.md) | `src/event/` | 3 |
| [`filesystem`](rust_modules/filesystem.md) | `src/filesystem/` | 7 |
| [`flownet`](rust_modules/flownet.md) | `src/flownet/` | 11 |
| [`font`](rust_modules/font.md) | `src/font/` | 5 |
| [`globe`](rust_modules/globe.md) | `src/globe/` | 18 |
| [`grep`](rust_modules/grep.md) | `src/grep/` | 11 |
| [`html`](rust_modules/html.md) | `src/html/` | 7 |
| [`i18n`](rust_modules/i18n.md) | `src/i18n/` | 5 |
| [`image`](rust_modules/image.md) | `src/image/` | 23 |
| [`input`](rust_modules/input.md) | `src/input/` | 9 |
| [`layout`](rust_modules/layout.md) | `src/layout/` | 6 |
| [`learning`](rust_modules/learning.md) | `src/learning/` | 15 |
| [`light`](rust_modules/light.md) | `src/light/` | 11 |
| [`log`](rust_modules/log.md) | `src/log/` | 3 |
| [`mapblock`](rust_modules/mapblock.md) | `src/mapblock/` | 14 |
| [`math`](rust_modules/math.md) | `src/math/` | 18 |
| [`midi`](rust_modules/midi.md) | `src/midi/` | 3 |
| [`minimap`](rust_modules/minimap.md) | `src/minimap/` | 6 |
| [`mods`](rust_modules/mods.md) | `src/mods/` | 6 |
| [`network`](rust_modules/network.md) | `src/network/` | 13 |
| [`overlay`](rust_modules/overlay.md) | `src/overlay/` | 8 |
| [`parallax`](rust_modules/parallax.md) | `src/parallax/` | 6 |
| [`particle`](rust_modules/particle.md) | `src/particle/` | 12 |
| [`pathfind`](rust_modules/pathfind.md) | `src/pathfind/` | 21 |
| [`patterns`](rust_modules/patterns.md) | `src/patterns/` | 22 |
| [`physics`](rust_modules/physics.md) | `src/physics/` | 10 |
| [`pipeline`](rust_modules/pipeline.md) | `src/pipeline/` | 5 |
| [`procgen`](rust_modules/procgen.md) | `src/procgen/` | 19 |
| [`province`](rust_modules/province.md) | `src/province/` | 18 |
| [`raycaster`](rust_modules/raycaster.md) | `src/raycaster/` | 22 |
| [`render`](rust_modules/render.md) | `src/render/` | 14 |
| [`repl`](rust_modules/repl.md) | `src/repl/` | 5 |
| [`runtime`](rust_modules/runtime.md) | `src/runtime/` | 10 |
| [`save`](rust_modules/save.md) | `src/save/` | 2 |
| [`scene`](rust_modules/scene.md) | `src/scene/` | 5 |
| [`serialize`](rust_modules/serialize.md) | `src/serialize/` | 10 |
| [`spine`](rust_modules/spine.md) | `src/spine/` | 7 |
| [`sprite`](rust_modules/sprite.md) | `src/sprite/` | 6 |
| [`terminal`](rust_modules/terminal.md) | `src/terminal/` | 9 |
| [`thread`](rust_modules/thread.md) | `src/thread/` | 5 |
| [`tilemap`](rust_modules/tilemap.md) | `src/tilemap/` | 17 |
| [`timer`](rust_modules/timer.md) | `src/timer/` | 5 |
| [`tween`](rust_modules/tween.md) | `src/tween/` | 7 |
| [`ui`](rust_modules/ui.md) | `src/ui/` | 10 |
| [`validator`](rust_modules/validator.md) | `src/validator/` | 11 |
| [`visibility`](rust_modules/visibility.md) | `src/visibility/` | 10 |
| [`window`](rust_modules/window.md) | `src/window/` | 4 |

## Modules

Każdy moduł ma osobną stronę z `General Info`, `Summary` i `Files`.

- [`agent`](rust_modules/agent.md)
  - The agent module provides a complete artificial intelligence and language model capability layer for the Lurek2D engine runtime, enabling gameplay scripts to integrate smart behaviors and dynamic conversations. It establishes stateful and stateless interface models that allow game entities to interact with large language models, perform text prompt completions, execute structured JSON requests, and generate text embeddings directly within the live simulation framework.

- [`ai`](rust_modules/ai.md)
  - The AI module provides a rich array of decision-making, planning, spatial navigation, and learning tools for Lurek2D agents. At its foundation, it manages isolated virtual worlds with shared global and agent-specific blackboards, enabling actors to record and query typed local facts. Sensory input is processed through a persistent multi-channel perception system that tracks visual and auditory stimuli in the environment, simulating attention fade and sensory reliability based on range.

- [`animation`](rust_modules/animation.md)
  - The animation module provides a complete control and playback layer for sprite-based and skeletal animations. It acts as the import and execution pipeline for asset files, translating grid layouts, manual rectangles, and Aseprite JSON metadata into optimized runtime clips. The frame-animation engine supports diverse playback behaviors, including loop, reverse, ping-pong, and one-shot progression, while scaling speeds dynamically.

- [`app`](rust_modules/app.md)
  - The app module serves as the desktop execution heartbeat for Lurek2D. It unifies winit windowing, wgpu graphics, user inputs, and the LuaJIT virtual machine into a deterministic main loop. From process launch to final shutdown, it governs bootstrapping, manages graphic surface reconfigurations, and controls viewport scaling so visuals remain stable.

- [`audio`](rust_modules/audio.md)
  - The audio module delivers a comprehensive sound and music engine for Lurek2D, managing device enumeration and streaming output lifecycles. It provides dual playback surfaces: static sources cached fully in memory for immediate sound triggers, and streaming or queueable sources designed for music and procedural PCM buffer feeds. The playback engine handles fading ramps, cloned voices, and round-robin voice pools that distribute low-latency triggering load across pre-allocated voices.

- [`automation`](rust_modules/automation.md)
  - The automation module delivers a deterministic input replay and scripted verification pipeline for Lurek2D. Its core purpose is to programmatically simulate human player interactions—including keyboard, mouse, and text inputs—to test gameplay behaviors. It parses ordered step sequences from TOML or Lua tables, expanding repeat directives and time intervals into concrete playback schedules.

- [`binary`](rust_modules/binary.md)
  - The binary module serves as the core byte-manipulation and low-level data transformation toolbox for Lurek2D. Its primary purpose is to provide scripts with high-performance, safe control over raw binary structures, memory buffers, and network interchange payloads. It exposes mutable, owned byte containers supporting bit-level updates and text decoding, read-only typed window views for bounds-checked numeric reads, and growable, seekable data writers for endian-aware structure construction.

- [`camera`](rust_modules/camera.md)
  - The camera module serves as the primary viewport projection layer for Lurek2D, mapping 2D world coordinates onto the user's screen. Its core purpose is to track gameplay targets smoothly using follow algorithms that apply dead-zone constraints, speed smoothing, easing modes, and look-ahead displacements. It supplies follow presets—aggressive, balanced, cinematic, and tight—to quickly capture common movement profiles while enforcing hard bounds to lock the view inside active maps.

- [`charts`](rust_modules/charts.md)
  - The charts module provides a CPU-rasterized data-visualization rendering engine for Lurek2D. Its functional purpose is to generate static chart images directly from raw data series, Lua tables, or column-driven tabular DataFrames. This enables the creation of debug telemetry panels, player statistics HUDs, and diagnostic data overlays at runtime without external dependencies.

- [`color`](rust_modules/color.md)
  - The color module provides fundamental color representations, space conversions, blending mathematics, and curated palettes for Lurek2D, supporting UI, rendering, and effects. It manages RGBA colors, supplying conversions between RGB, HSL, and HSV spaces, alongside Hex string parsing. For rendering, it computes clamped linear interpolations, alpha compositing (Porter-Duff), channel inversions, perceived luminance, gamma-to-linear conversions, and multiple blend modes. It also includes retro palettes like PICO-8, Game Boy, and NES.

- [`compute`](rust_modules/compute.md)
  - The compute module serves as the primary high-performance numeric processing engine for Lurek2D. Its core purpose is to provide scripts with dense, multi-dimensional array structures, enabling heavy mathematical calculations directly within game loops. It centers around a robust NdArray model that stores typed scalar buffers with explicit shape strides, supporting initializations for zeros, ones, or custom ranges. It manages sub-regions and supports parallel multithreaded calculation thresholds for massive array blocks.

- [`cursor`](rust_modules/cursor.md)
  - The cursor module manages pointer presentation, custom cursor assets, context-sensitive switching policies, and visual pointer feedback effects in Lurek2D. Its core purpose is to provide scripts with highly responsive, interactive cursor customizations that adapt to game states, UI contexts, and player actions.

- [`dataframe`](rust_modules/dataframe.md)
  - The dataframe module delivers a complete tabular data workspace and in-memory relational database framework for Lurek2D. Its core purpose is to provide scripts and engine subsystems with high-performance table management, enabling tabular gameplay data, analytics, and diagnostic reporting. It centers around a dual model: DataFrames storing structured columns and typed cell values, and Databases grouping multiple tables under one logical schema boundary for relational queries and frame joins.

- [`debugbridge`](rust_modules/debugbridge.md)
  - This module establishes a communication bridge between the active game session and external editing panels. By running a background network server, it allows developers to remotely inspect and control the engine's state without interrupting gameplay. It enables on-the-fly code updates, performance tracking, and screenshot captures.

- [`devtools`](rust_modules/devtools.md)
  - This module provides a comprehensive diagnostics toolkit built directly into the engine, giving developers visibility and control over active session behavior. The system constantly gathers frame-timing statistics for both processing unit and graphics hardware workflows. This supports real-time calculations of performance indicators, such as render rates, average durations, and percentile profiles, helping to quickly identify performance drops.

- [`dialog`](rust_modules/dialog.md)
  - This module provides the narrative scripting and conversation logic system, allowing gameplay scripts to choreograph complex dialogues. It handles multi-character conversation graphs, player choices, and conditional narrative gates. Conversations are built as dialogue trees where branches are evaluated and ranked dynamically using utility scoring, ensuring the engine can select contextually appropriate dialogue paths.

- [`docs`](rust_modules/docs.md)
  - This module acts as the documentation workflow and quality assurance core, managing the generation, validation, and export of the engine's public interface data. It handles the parsing of API metadata into a unified in-memory documentation catalog. This central catalog groups and organizes symbols across modules, maintaining their entry definitions to provide a single, consistent source of truth for the entire scripting framework.

- [`dsp`](rust_modules/dsp.md)
  - This module handles audio signal processing and synthesis, offering control over sound generation and manipulation. It provides the runtime for real-time effects like filters, delays, and modulations. These effects use lock-free parameters to ensure low-latency safety, wrapping audio sources to apply clean transformations sample-by-sample during live playback.

- [`ecs`](rust_modules/ecs.md)
  - This module provides the Entity-Component-System framework, serving as the central database and simulation coordinator for the game world. It tracks entity lifecycles using generational IDs, which prevent dangling references when slots are reused. Component data is stored in flexible tables, exposing optimized methods to set, query, and remove components dynamically during runtime updates.

- [`effect`](rust_modules/effect.md)
  - This module represents the visual post-processing pipeline, enabling developers to apply full-screen shader effects to render outputs. It manages effect instances coupling specific shader algorithms with customizable parameters. These apply dynamically using either built-in effect types or custom shaders, giving developers control over the final visual presentation of their games.

- [`event`](rust_modules/event.md)
  - This module serves as the runtime messaging hub, decoupling subsystems through asynchronous signaling. It implements a dual-priority queue ensuring critical tasks process ahead of standard events. The system handles data marshalling between Rust and Lua, supporting both immediate pushes and deferred buffering to coordinate events across frames.

- [`filesystem`](rust_modules/filesystem.md)
  - This module provides virtual filesystem services, sandboxing file access to game directories. It coordinates path resolution, file operations, and virtual mounts, ensuring scripting layers interact with files safely. Normalising paths across systems guarantees consistent cross-platform behavior for all read, write, and directory workflows.

- [`flownet`](rust_modules/flownet.md)
  - This module represents the directed logistics and transport network subsystem, providing tools to build, analyze, and simulate complex graph networks. The graph container stores nodes, connections, and individual payloads, managing entity lifecycles to ensure consistency across connections. This architecture allows developers to design logistics networks, supply grids, or economic pipelines directly using structured network nodes and connection endpoints.

- [`font`](rust_modules/font.md)
  - This module provides typography runtime services to load, resolve, and manage fonts. It operates a central registry caching styles and point sizes for TTF, OTF, and pre-rasterized bitmap fonts. This ensures that UI and render steps can query consistent font metrics on demand to size components.

- [`globe`](rust_modules/globe.md)
  - This module represents the interactive planetary globe simulation and rendering subsystem, providing rich interfaces to model and display spherical world maps. It operates on region topologies representing territories, provinces, or coordinates mapped onto a unit sphere. By combining coordinate math and orbital projections, it manages interactive camera controls like panning, panning bounds, and variable zooms, translating screen inputs into latitude and longitude coordinates.

- [`grep`](rust_modules/grep.md)
  - This module represents the high-performance content-search and text-scanning subsystem, supplying systems with tools to query files. It supports multiple search strategies including exact literals, regular expressions, shell globs, and edit-distance fuzzy matching. By checking search configurations, the scanning engine bounds processing loads by enforcing maximum file size limits, whole-word constraints, and case filters.

- [`html`](rust_modules/html.md)
  - This module provides the HTML/CSS user interface subsystem, letting developers build interactive menus and HUDs. It parses markup and CSS stylesheets into dynamic DOM trees. The layout engine computes bounds using a box model, resolving cascades into precise pixel coordinates for rendering.

- [`i18n`](rust_modules/i18n.md)
  - This module represents the internationalization and localization subsystem, providing tools to manage translations and regional formatting during runtime. It hosts a translation catalog that maps hierarchical locale keys from TOML, JSON, or nested Lua tables into a flattened namespace. Resilient lookup chains resolve missing text strings by walking configured fallbacks before reporting coverage gaps, facilitating language switching without restarting the game.

- [`image`](rust_modules/image.md)
  - This module represents the CPU-side image manipulation and asset preparation subsystem, supplying comprehensive tools to load, decode, and transform pixel buffers. It manages mutable raw pixel maps and compressed DDS texture streams, handling format tags, mip chains, and transparency models. This ensures that assets are validated and pre-processed in memory before being staged for GPU uploads, keeping all pixel mutations isolated without side effects.

- [`input`](rust_modules/input.md)
  - This module provides a unified control-state and input-processing subsystem, bridging raw host hardware events into clean gameplay inputs. It monitors physical inputs across keyboards, mice, gamepads, and multi-touch panels. By translating hardware-specific codes and controller layouts into stable logical naming conventions, the system exposes a consistent, cross-platform interface for all polling and event dispatch pathways.

- [`layout`](rust_modules/layout.md)
  - This module provides graph and hierarchy layouts to compute 2D coordinates for nodes. It offers layered placement for directed graphs to reduce crossings, recursive allocations for compact trees, and force-directed simulations that arrange relation webs organically.

- [`learning`](rust_modules/learning.md)
  - This module represents the machine-learning runtime and artificial intelligence modeling subsystem, providing a rich collection of CPU-side training and inference blocks. It allows developers to build, organize, and evaluate various learning architectures directly in active game sessions. These models run without external runtime dependencies, utilizing flat, row-major tensor buffers for fast and predictable numeric calculations on the main CPU thread.

- [`light`](rust_modules/light.md)
  - This module represents the dynamic 2D illumination and shadow-casting subsystem, offering developers control over visual lighting environments. It operates a centralized light world container that manages active lights and structural occluders keyed by stable handles. By processing coordinates, global ambient colors, and light groupings, the system produces coordinated illumination layers that shape visual depth and gameplay moods in real-time.

- [`log`](rust_modules/log.md)
  - This module provides structured logging, letting developers filter and route runtime messages. It hosts a logging facade that dispatches level-tagged entries and key-value fields. Enforcing severity gates early minimizes performance overhead, keeping diagnostics highly efficient.

- [`mapblock`](rust_modules/mapblock.md)
  - This module provides the procedural map block assembly and generation subsystem, enabling developers to build large tilemaps from pre-configured block layouts. It manages individual map blocks that bundle tile grids, edge connectors, and weighted metadata. Adjacency constraints use socket-style interfaces, defining how blocks link to their neighbors. This allows the generator to validate boundary compatibilities during runtime procedurally.

- [`math`](rust_modules/math.md)
  - This module represents the core numeric and geometric foundation of the engine, supplying a comprehensive suite of mathematical types, algorithms, and spatial data structures. It provides basic vectors and row-major matrices to manage positions, velocities, and affine transformations. Chained operations like translation, rotation, scale, and shear are packaged in memory-efficient structures, serving as the mathematical backbone for motion and collision across the entire engine.

- [`midi`](rust_modules/midi.md)
  - This module handles MIDI playback and software synthesis by managing SoundFont resources. It implements a stateful transport player to control files, seeking, and loops. Additionally, it exposes per-channel mix properties like instrument selection, volume, mute, and solo controls, routing audio to the mixer.

- [`minimap`](rust_modules/minimap.md)
  - This module provides a grid-based tactical minimap subsystem for HUD views. It maintains a map model tracking cells, terrain types, and display layers. These layers can be stacked to combine different map representations (like terrain and political views) or show varied vertical elevations, offering highly customizable tactical HUD feedback.

- [`mods`](rust_modules/mods.md)
  - This module represents the modular extension and package management subsystem, supplying tools to discover, validate, and orchestrate user-created packages. It processes manifest declarations to register mods with the manager, tracking metadata such as versions, authors, and configuration schemas. This decouples core engine operations from custom content folders while guaranteeing stable load pathways at runtime.

- [`network`](rust_modules/network.md)
  - This module represents the network communication and multiplayer transport subsystem, enabling real-time game coordination across host sessions. It wraps ENet bindings to handle low-level UDP sockets, connection lifecycles, and multi-channel packet delivery. By abstracting host behaviors into server, client, or combined host configurations, the engine manages connection slotting, disconnect sequences, and round-trip statistics seamlessly.

- [`overlay`](rust_modules/overlay.md)
  - This module serves as the primary engine layer for screen-space presentation, offering a suite of visual techniques that enhance environmental storytelling and mood. It orchestrates long-lived atmospheric layers, including clouds, fog, and grain, and handles dynamic particle weather systems that respond to simulated wind direction and speed. This enables realistic settings such as falling snow or dust storms, giving developers precise artistic control over depth and visibility.

- [`parallax`](rust_modules/parallax.md)
  - This module provides a multi-layered parallax scrolling system that creates a sense of depth in 2D environments. By assigning distinct scroll factors, z-orders, and offsets to individual planes, layers move relative to the camera at varying speeds. The system supports autonomous autoscrolling for moving skies, as well as scroll clamping to restrict layer movement within designated map boundaries.

- [`particle`](rust_modules/particle.md)
  - This module delivers a robust particle simulation subsystem designed to model dynamic visual effects like fire, smoke, rain, and explosions. At its core, the system utilizes high-performance pooling to recycle and manage thousands of active particles efficiently. Emitters control the lifecycle, spawning particles continuously or in sudden bursts, updating their positions, velocities, rotations, and lifetimes over each frame, and supporting warm-up cycles to start scenes in a fully settled state.

- [`pathfind`](rust_modules/pathfind.md)
  - This module provides a navigation and spatial pathfinding subsystem designed to handle diverse 2D grid and graph environments. It supports standard grid surfaces, hex grids with pointy or flat orientations, rectangular isometric cell structures, and polygon-based navigation meshes for large open spaces. Additionally, adjacency graphs represent province-level connections, giving developers a comprehensive toolkit to manage paths across strategic maps, tactical grids, or complex geometric zones.

- [`patterns`](rust_modules/patterns.md)
  - This module serves as a foundational gameplay-architecture toolkit, offering an array of reusable coordination, state-flow, and data-structure patterns. By packaging complex logic routing, decision architectures, and communication networks into lightweight primitives, the system enables highly decoupled game designs. These components bridge Lua scripting and Rust systems, ensuring that developers can coordinate state across distinct gameplay layers safely and deterministically.

- [`physics`](rust_modules/physics.md)
  - This module delivers a high-performance 2D rigid-body physics simulation subsystem that drives motion, collision, and mechanical interactions. It manages rigid bodies under distinct behavioral roles, including dynamic movers, fixed solid obstacles, script-driven kinematics, and trigger sensors. To ensure deterministic results regardless of rendering frame rate, the engine utilizes fixed-timestep updates, automatically reconciling screen pixels with physics meters.

- [`pipeline`](rust_modules/pipeline.md)
  - This module provides a dependency-aware workflow orchestration system that manages execution flows as directed acyclic graphs. Rather than using rigid call sequences, work is modeled as distinct steps linked by explicit prerequisites. This dependency-oriented design ensures that complex tasks execute in a safe and logical order, keeping code modular and allowing developers to assemble dynamic workflows from scripts and data-driven configuration tables.

- [`procgen`](rust_modules/procgen.md)
  - This module provides a deterministic procedural generation subsystem that powers the repeatable synthesis of terrain, layouts, names, and networks. All operations revolve around a compact, seeded linear congruential generator that provides dependable randomness. The core noise engines deliver multi-dimensional Perlin, Simplex, and cellular Worley noise. They support fractal octave combinators for rugged textures, domain warping, tileable loops, and multi-threaded parallel generation for massive maps.

- [`province`](rust_modules/province.md)
  - This module provides a province-based cartography and region simulation subsystem that manages irregular region maps as semantic gameplay entities. Unlike cell-based tilemaps, provinces represent cohesive territories parsed from color-coded map graphics. The system maintains an authoritative registry that decodes raster pixels into stable province identities, establishing an adjacency network that acts as the topological foundation for map-wide routing and borders.

- [`raycaster`](rust_modules/raycaster.md)
  - This module provides a classic grid-based first-person raycasting subsystem, turning 2D maps into immersive pseudo-3D environments. At its computational core, a Digital Differential Analysis marcher shoots rays across the map grid to detect wall collisions, calculating corrected perpendicular distances to prevent perspective distortion. This allows developers to present textured first-person viewpoints while preserving the low-overhead structure of a 2D engine runtime.

- [`render`](rust_modules/render.md)
  - This module serves as the primary visual execution backend for Lurek2D, orchestrating all deferred draw operations to produce final frame outputs. It establishes a robust 2D rendering pipeline that supports basic vector shapes, dynamically rasterized text, custom vertex meshes, and complex fullscreen post-processing layers. By acting as a central gateway, it unifies diverse presentation requests from scripting and internal systems into a single frame lifecycle.

- [`repl`](rust_modules/repl.md)
  - This module provides a headless, embeddable interactive Lua session that evaluates code against the running VM. It operates independently of rendering layers, maintaining a bounded history and executing colon-prefixed console commands.

- [`runtime`](rust_modules/runtime.md)
  - This module serves as the central coordination nucleus of the Lurek2D engine, orchestrating shared state, configurations, and system-wide behaviors. At its core, the subsystem manages a global borrowable state container that unites windowing, timing, and inputs under one unified hub. It provides authoritative ownership for essential asset pools—including textures, canvases, fonts, shaders, and meshes—preventing duplicate resource allocation and managing global memory budgets.

- [`save`](rust_modules/save.md)
  - This module provides a unified state persistence and save slot manager designed to handle game progress. Diverse gameplay systems register data sections using collector and restorer callback pairs. When saving, the manager invokes collectors to assemble a single structured state payload; during loads, it distributes this data back to their respective systems to ensure smooth, reliable state restorations.

- [`scene`](rust_modules/scene.md)
  - This module provides a robust game flow and state control subsystem built on a structured scene stack model. It organizes game progression across major runtime states, such as menus, levels, and popup screens, through standard push, pop, and switch operations. The stack supports overlay layouts that can run alongside underlying states, and utilizes prototype metatable factories to define and instantiate custom scene classes dynamically.

- [`serialize`](rust_modules/serialize.md)
  - This module serves as the primary data-translation and validation subsystem for Lurek2D, providing a unified frontend to ingest and export data. The subsystem translates all text and binary inputs into a format-agnostic intermediate value tree. Through a single entry point, the codec automatically detects and parses payloads—including JSON, TOML, CSV, XML, INI, and MessagePack—isolating format quirks from the runtime.

- [`spine`](rust_modules/spine.md)
  - This module provides a skeletal animation runtime for 2D assets, offering pose-driven movement through hierarchies of bones and slots. Bones carry local transform offsets that propagate down parent-child chains to resolve world-space positions. To achieve organic, procedural responsiveness alongside keyframed animations, the system implements an inverse-kinematics solver that constrains joint angles toward target positions with controllable bend directions.

- [`sprite`](rust_modules/sprite.md)
  - This module turns raw textures into reusable sprites, sheets, and UI panels. It supports named texture atlases parsed from TexturePacker and Aseprite JSON data, mapping semantic names to specific regions while handling rotation and flip flags. This allows scripts to query packed sprites by name instead of raw coordinates.

- [`terminal`](rust_modules/terminal.md)
  - This module introduces a highly interactive, character-grid emulator that maps text-based layouts directly into the visual window. By translating virtual screen positions into structured cell matrices, it allows developers to build classic console-like displays and terminal environments within the game runtime. The system stores detailed cell attributes including glyphs, foreground and background colors, and custom styles, serving as the foundational layer for text-mode graphics.

- [`thread`](rust_modules/thread.md)
  - This module delivers a safe and robust concurrency framework for executing asynchronous Lua jobs outside the main frame loop. Because separate virtual machines do not share state, the runtime guarantees thread safety by spinning up isolated workers on dedicated operating system threads. Background tasks run within a restricted environment, which prevents hazardous cross-thread memory sharing while keeping gameplay operations fluid.

- [`tilemap`](rust_modules/tilemap.md)
  - This module serves as the primary system for building, simulating, and visualizing rich, grid-based game worlds. It unifies orthogonal, isometric, and hexagonal structures under a single set of spatial operations, enabling developers to map virtual grid coordinates directly into screen-space projections. The system manages conversions, diamond layout ordering, diagonal sorting, and hexadecimal neighborhood navigations for gameplay logic.

- [`timer`](rust_modules/timer.md)
  - This module serves as the core timing backbone for the game runtime, ensuring that delta times, elapsed sessions, and frame-rate calculations remain highly stable and precise. By integrating a drift-safe microsecond accumulator that retains fractional carry between updates, the system eliminates rounding errors over long sessions. Clocking metrics provide both raw delta times and smoothed averages, reducing frame jitter for movement interpolations.

- [`tween`](rust_modules/tween.md)
  - This module serves as the primary animation engine for driving timed value changes and fluid transitions across table properties. By combining mathematical easing curves with physical dynamics, it enables developers to craft expressive motion patterns without manual tracking. The system translates raw time deltas into normalized progress ratios, applying built-in or custom-registered easing curves to produce organic visual responses.

- [`ui`](rust_modules/ui.md)
  - This module provides a robust, retained-mode user interface toolkit designed to support both in-game graphical HUDs and complex editor-style workspaces. At its core, a centralized context manager manages the complete widget lifecycle, allocating every node inside an indexed arena to guarantee memory stability and fast lookups. The context monitors root-level viewport scales and base resolutions to ensure widgets scale cleanly across high-DPI displays.

- [`validator`](rust_modules/validator.md)
  - This module provides a static analysis engine designed to inspect Lua projects before runtime. By scanning source files statically, it identifies API compliance issues, broken module imports, and missing asset references early. The validation orchestrator lets teams enforce clean code standards by combining built-in checks with customizable rules.

- [`visibility`](rust_modules/visibility.md)
  - This module delivers a highly flexible, geometry-agnostic visibility and fog-of-war system that integrates seamlessly with varied world models. By decoupling layout metrics from visibility calculations through a generic adjacency interface, the system can track exploration across tile grids, hex maps, province networks, and global spheres. It tracks hidden, discovered, and visible statuses separately across factions.

- [`window`](rust_modules/window.md)
  - This module serves as the primary gateway for controlling the OS-level application window and managing multi-monitor systems. By abstracting the operating system's display APIs, it lets developers query connected monitors, retrieve desktop resolutions, and transition the game window across screens seamlessly. The window manager targets startup monitors dynamically while exposing centering and window-movement operations.

## Powiązane

- [Architecture](architecture/engine-core.md)
- [Generated Rust API (Markdown)](api/rust.md)
