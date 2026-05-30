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
| [`terminal`](rust_modules/terminal.md) | `src/terminal/` | 8 |
| [`thread`](rust_modules/thread.md) | `src/thread/` | 5 |
| [`tilemap`](rust_modules/tilemap.md) | `src/tilemap/` | 14 |
| [`timer`](rust_modules/timer.md) | `src/timer/` | 5 |
| [`tween`](rust_modules/tween.md) | `src/tween/` | 7 |
| [`ui`](rust_modules/ui.md) | `src/ui/` | 10 |
| [`validator`](rust_modules/validator.md) | `src/validator/` | 11 |
| [`visibility`](rust_modules/visibility.md) | `src/visibility/` | 10 |
| [`window`](rust_modules/window.md) | `src/window/` | 4 |

## Modules

Każdy moduł ma osobną stronę z `General Info`, `Summary` i `Files`.

- [`agent`](rust_modules/agent.md)
  - The `agent` module turns model access into a stable service for gameplay and tools. Instead of many one-off scripts, it gives one consistent way to send prompts, receive answers, and handle callbacks. This makes AI features easier to build, easier to reason about, and safer to reuse across a project.

- [`ai`](rust_modules/ai.md)
  - The `ai` module is the behavior center for non-player actors. It gives one place to create agents, update them, and keep their decisions coherent over time. Functionally, it turns many AI techniques into one usable runtime surface, so game code can focus on design goals instead of wiring each method from scratch.

- [`animation`](rust_modules/animation.md)
  - The `animation` module is the place where visual motion is organized into a clear runtime flow. It lets teams define frames and clips, play them with stable timing, and keep updates predictable across gameplay and tooling. Functionally, it turns raw frame data into reusable animation behavior.

- [`app`](rust_modules/app.md)
  - The `app` module is where the whole runtime is assembled and driven from launch to shutdown. It does not own gameplay rules. Instead, it owns execution order: start services, process events, run frame stages, and present output in a predictable cycle.

- [`audio`](rust_modules/audio.md)
  - The `audio` module is the central runtime for sound behavior in Lurek2D. It manages source lifecycle, playback state, routing, and control so game systems can treat sound as a predictable service. In practice, it gives one place to start, stop, inspect, and shape audio during live gameplay.

- [`automation`](rust_modules/automation.md)
  - The `automation` module gives one reliable way to simulate runtime interaction without manual input. It turns test intent into scripted steps and replays those steps in a controlled timeline. This helps teams verify behavior repeatedly with the same sequence and expected outcomes.

- [`binary`](rust_modules/binary.md)
  - The `binary` module is the low-level data toolbox for byte-oriented workflows in the engine. It gives scripts and systems one consistent way to create buffers, read and write typed values, and transform payloads between raw bytes and transport-friendly formats.

- [`camera`](rust_modules/camera.md)
  - The `camera` module controls how the world is seen on screen in 2D runtime scenarios. It provides one consistent place to manage camera position, zoom, rotation, follow logic, and viewport mapping. Functionally, it separates view behavior from gameplay logic so systems can share the same camera rules.

- [`charts`](rust_modules/charts.md)
  - The `charts` module turns numeric data into ready-to-display chart images using CPU rasterization. It supports common chart families in one place, so scripts can generate visual summaries without relying on a dedicated GPU chart pipeline.

- [`color`](rust_modules/color.md)
  - The `color` module is the base utility layer for working with color values in the engine. It provides a consistent RGBA model and common operations so rendering, UI, effects, and tools can use the same color rules.

- [`compute`](rust_modules/compute.md)
  - The `compute` module is the engine's general-purpose numeric workspace. It gives scripts and systems one place to create typed arrays and run deterministic math over them, from simple element-wise operations to heavier analytical and transform workflows.

- [`cursor`](rust_modules/cursor.md)
  - The `cursor` module gives one runtime layer for pointer presentation. It lets scripts control how the pointer looks, when it is visible, whether it is locked, and how it reacts in different runtime contexts.

- [`dataframe`](rust_modules/dataframe.md)
  - The `dataframe` module is the structured table workspace for runtime and tooling data. It gives one place to store rows and columns, keep typed values, and run predictable data operations.

- [`debugbridge`](rust_modules/debugbridge.md)
  - The `debugbridge` module is the runtime communication path between the engine and external debug clients. It allows tools to connect to a live process, exchange messages, and receive diagnostics without embedding tool code in gameplay systems.

- [`devtools`](rust_modules/devtools.md)
  - The `devtools` module is the main diagnostics toolkit for development-time runtime inspection. It gathers useful signals while the game is running, so teams can understand behavior, detect problems, and iterate faster.

- [`dialog`](rust_modules/dialog.md)
  - The `dialog` module is the runtime layer for conversation flow. It lets projects define topics, branches, and progression state in a structured way, so dialogue behavior is predictable during gameplay.

- [`docs`](rust_modules/docs.md)
  - The `docs` module is the internal documentation infrastructure used by generation and tooling flows. It gives one structured place for doc entries, catalog operations, export output, and quality checks.

- [`dsp`](rust_modules/dsp.md)
  - The `dsp` module is the signal-processing layer for audio transformation and analysis. It handles how signals are shaped and measured, while playback scheduling and source lifecycle stay outside this boundary.

- [`ecs`](rust_modules/ecs.md)
  - The `ecs` module is the world-state backbone for entity-driven gameplay logic. It provides one runtime container for entities, components, tags, hierarchy, and relationship data.

- [`effect`](rust_modules/effect.md)
  - The `effect` module manages visual post-effect composition data and lifecycle, including stack ordering, effect instances, presets, and conversion into render-command level apply/capture passes. It focuses on effect state orchestration rather than direct GPU execution.

- [`event`](rust_modules/event.md)
  - The `event` module provides priority-aware runtime event queuing and signal subscription primitives. Its core role is decoupled communication: producers push typed payloads, consumers poll or subscribe by name/wildcard, and delivery semantics preserve ordering guarantees within priority lanes.

- [`filesystem`](rust_modules/filesystem.md)
  - It provides the essential abstraction layer between Lua game scripts and the host operating system, ensuring that all file I/O is secure. By confining operations to a designated base game directory and a specific user save directory, `GameFS` actively prevents path-traversal attacks. It intercepts and validates every path component, rejecting any attempts to use `..`, symbolic links, or absolute prefixes that point outside the allowed security boundary. Violations immediately trigger an `EngineError::FsPathTraversal`.

- [`flownet`](rust_modules/flownet.md)
  - Moving beyond simple data-structure graphs, this module simulates complex logistics and transportation systems where typed items physically travel through interconnected nodes. The central `Graph` structure utilizes highly efficient `HashMap` storage and maintains persistent adjacency indexes, enabling O(1) neighbor lookups and robust graph traversal.

- [`font`](rust_modules/font.md)
  - The font module provides the CPU-side data layer for text rendering: bitmap font atlas loading with Latin-1 glyph coverage, per-glyph and per-text metrics, text alignment, word and character wrapping, and a central font registry for named handles. The module does not own GPU resources — texture management for font atlases remains in the render module. Fourteen bundled Courier New bitmap atlases are shipped in `assets/fonts/`.

- [`globe`](rust_modules/globe.md)
  - At its core is the `Globe` structure, which oversees a highly optimized, region-based spherical map. It utilizes an orbit camera with latitude and longitude positioning, supporting smooth interpolation, variable zoom levels, and automatic Level-of-Detail (LOD) adjustments. A key architectural decision is that all rendering output consists of 2D draw commands (such as convex fans, polylines, and circles) projected from spherical coordinates, intentionally avoiding the complexity of a full 3D pipeline.

- [`grep`](rust_modules/grep.md)
  - The `grep` module exposes a full-featured file search engine to Lua game scripts and developer tooling. At its core, the `GrepEngine` wires together a `FileFilter` (controlling which files to search by extension, path glob, and hidden-file rules), a compiled `Matcher` (selecting the search strategy), and a Rayon parallel thread pool sized from `GrepConfig`. Searches can be expressed as literal strings, regular expressions, shell globs, edit-distance fuzzy patterns, or Aho-Corasick multi-literal sets — all returning structured `GrepResult` values with per-file `FileMatch` arrays and `LineMatch` byte-span positions.

- [`html`](rust_modules/html.md)
  - It empowers game developers to construct complex, responsive User Interfaces (UIs) using familiar web markup technologies rather than proprietary layout languages. The engine fully parses raw HTML strings into a live DOM tree populated with `HtmlElement` nodes. It evaluates cascaded CSS stylesheets—supporting extensive CSS selector matching including tag, class, id, attribute, pseudo-classes, and relationship combinators—to resolve a computed style for every element.

- [`i18n`](rust_modules/i18n.md)
  - At the core of the module is the `Catalog`, a high-performance, locale-indexed translation store. It loads locale data directly from flat files—typically TOML or JSON—flattening nested structures into dot-separated string keys. To ensure a seamless user experience, the module supports hierarchical fallback chains; if a translation is missing in the active locale, the `Catalog` automatically searches through a defined sequence of fallback languages before defaulting to the raw key.

- [`image`](rust_modules/image.md)
  - The foundational type is `ImageData`, which manages raw RGBA8 pixel buffers along with their dimensions. It supports a wide array of image processing operations including filling, nearest-neighbor and bilinear resizing, flipping, rotation, cropping, and primitive drawing (lines, circles, rectangles, and compact bitmap text). Crucially, it provides a comprehensive set of pixel-level effects—such as brightness, contrast, saturation, gamma correction, tinting, grayscale, sepia, inversion, thresholding, and separable box blurs—many of which are highly optimized using parallel processing (Rayon) for large images.

- [`input`](rust_modules/input.md)
  - Functioning as a translation layer between the winit OS event loop and the game logic, it provides frame-perfect state tracking and querying. The `KeyboardState` system accurately monitors key-down, key-up, just-pressed, and just-released events on a per-frame basis. It maintains a strict separation between physical scan-codes (ideal for layout-agnostic WASD movement) and logical key mappings, while also supporting OS key-repeat events, text-input buffering for typing, and modifier bitmasks.

- [`layout`](rust_modules/layout.md)
  - The `layout` module offers four complementary 2D graph layout algorithms with no engine runtime dependencies, making it usable from any scripting context. `layout_tree` implements the Reingold-Tilford algorithm for compact hierarchical tree layout, packing sibling subtrees as tightly as possible with configurable horizontal and vertical node separation. Both top-down and left-to-right orientations are supported via `TreeConfig`. `layout_dag` applies the multi-phase Sugiyama layered layout to directed acyclic graphs — cycle removal, layer assignment, crossing minimization, and coordinate assignment — producing readable hierarchical diagrams for tech trees, build-dependency graphs, and quest dependency views.

- [`learning`](rust_modules/learning.md)
  - The `learning` module extracts machine learning and evolutionary computation primitives into a focused, standalone subsystem. These algorithms have no dependency on the AI decision-making infrastructure (FSMs, behavior trees, GOAP, etc.) and can be used in any game context — from evolving creature behaviors to adaptive difficulty tuning to player modeling.

- [`light`](rust_modules/light.md)
  - It is responsible for managing point, spot, and area lights, alongside shadow-casting occluders, to create dynamic and atmospheric scene illumination. At its core, the `Light2D` struct encapsulates the properties of an individual light source, including its position, color, radius, intensity, cone angles for spot behavior, falloff curves, and procedural flicker configurations. The module is intentionally designed as a pure data management layer—it handles the logical state, grouping, and animation of lights, while the actual GPU rasterization and shader execution are deferred entirely to the `render` module.

- [`log`](rust_modules/log.md)
  - It provides a unified system for capturing, filtering, and dispatching diagnostic messages across the entire engine and Lua scripting environment. At its core, the module utilizes a level-gated emission system. The global log level acts as an initial filter, ensuring that messages below the active threshold incur near-zero performance cost—they are suppressed before any formatting or string allocation occurs. This allows developers to instrument code heavily with debug and trace messages without impacting production performance.

- [`mapblock`](rust_modules/mapblock.md)
  - The `mapblock` module implements a Carcassonne-inspired map assembly pipeline where discrete `MapBlock` prefabs — each a grid of `MapTile` slots with typed edges — are placed on a `PlacementGrid` according to `EdgeConstraint` rules that ensure neighboring blocks share compatible socket types (e.g., `"road"`, `"river"`). Block placement is driven by a `MapScript`: an ordered sequence of typed `ScriptStep` operations including `Fill` (flood-fill a region with a block group), `PlaceGroup` (weighted random selection from a named `BlockGroup`), `PlaceBlock` (explicit placement), `ApplyLayer` (copy a layer from another block), and `Repeat` (nested sub-sequence with its own RNG advance). The `MapBlockGenerator` executes these steps in order with backtrack support, capped by a configurable `retry_limit`.

- [`math`](rust_modules/math.md)
  - As the foundational leaf of the engine's dependency graph, it is imported and utilized by nearly every other subsystem. The core vector mathematics are handled by highly optimized `Vec2` and `Vec3` types, which offer a complete set of arithmetic operations, geometric helpers (dot, cross, normalize, distance), and angle conversions. Complex transformations are managed by the `Transform` struct, backed by a row-major 3x3 affine matrix (`Mat3`), facilitating chainable translation, rotation, scale, and shear operations.

- [`midi`](rust_modules/midi.md)
  - The `midi` module encapsulates MIDI file parsing, event sequencing, and PCM synthesis using loaded SoundFont (.sf2) instrument data. It was extracted from `src/audio/` to isolate the MIDI-specific logic from the core playback and mixing pipeline.

- [`minimap`](rust_modules/minimap.md)
  - It manages an independent grid of terrain cells, allowing games to display a scaled-down representation of the world entirely distinct from the main rendering pipeline. The core `Minimap` struct maintains multi-layered cellular data encompassing terrain types, associated colors, and a sophisticated three-state fog-of-war system (Hidden, Explored, Visible) that dynamically restricts player vision and modifies rendered cell colors based on discovery status.

- [`mods`](rust_modules/mods.md)
  - It is engineered to handle the complete lifecycle of mods, from initial discovery on the filesystem to dependency resolution, load-order sorting, asset mounting, and runtime hot-reloading. The core orchestrator is the `ModManager`, which actively scans designated directories for `mod.toml` manifests, securely parses them, and validates their structural integrity and version constraints.

- [`network`](rust_modules/network.md)
  - It is engineered to handle a diverse array of network topologies and transport protocols, including high-performance ENet UDP transport, raw non-blocking TCP sockets, asynchronous HTTP requests, and persistent bidirectional WebSocket connections. The module is built around a dedicated background `NetworkRuntime` thread (powered by Tokio) that handles all blocking I/O, ensuring that socket latency and network operations never stall the primary game loop. The game thread communicates with this runtime via highly efficient MPSC request/response channels.

- [`overlay`](rust_modules/overlay.md)
  - The `overlay` module provides a self-contained screen-space effects layer that sits above world rendering and below the HUD. The central `Overlay` struct owns every subsystem and drives their per-frame update via a single `update(dt)` call. It handles five distinct effect categories.

- [`parallax`](rust_modules/parallax.md)
  - It allows developers to easily create a deep sense of 2D perspective by stacking multiple textured layers that scroll at varying speeds relative to camera movement. The core of this system is the `ParallaxLayer`, which defines a single depth plane. By assigning a scroll speed multiplier to each layer (where 0.0 represents a distant static background and 1.0 moves precisely with the camera), the system automatically handles the complex camera-relative pixel offset computations necessary for convincing parallax effects. Layers are sorted back-to-front by their assigned Z-depth, with the lowest scroll factors naturally appearing furthest away.

- [`particle`](rust_modules/particle.md)
  - Designed for high-performance visual effects, it utilizes bounded, fixed-capacity memory pools and CPU-based Euler integration. At the core of the module is the `ParticleSystem`, an emitter that spawns `Particle` instances according to highly configurable emission shapes, such as point, circle, ring, rectangle, cone, line, and custom callbacks. Once spawned, each particle evolves independently based on a robust physics model that includes linear velocity, gravity, radial/tangential acceleration, linear damping, drag, orbit mechanics, and turbulence, before eventually expiring after a predefined lifetime.

- [`pathfind`](rust_modules/pathfind.md)
  - It is designed to handle everything from simple grid-based movement to complex, multi-agent AI steering and hierarchical navigation. The foundation of the module is the `NavGrid`, a robust 2D grid structure supporting per-cell walkability masks, integer-based movement costs, and configurable diagonal movement policies (with corner-cutting prevention). On top of this, the module implements classical algorithms like A* (with octile or Manhattan heuristics), Dijkstra's algorithm for cost-weighted reachability, and unweighted BFS. For high-performance uniform-cost grids, it features Jump Point Search (JPS), which dramatically accelerates A* by pruning symmetric neighbors.

- [`patterns`](rust_modules/patterns.md)
  - Designed to be highly reusable, completely decoupled from one another, and fully exposed to the Lua environment, these primitives act as high-level building blocks for complex game logic. At the core of AI decision-making is the `BehaviorTree` system, featuring Sequences, Selectors, Parallels, Inverters, Repeats, and Leaf action nodes. For transition-heavy logic, the module offers a hierarchical `StateMachine` with enter/exit/update callbacks, explicit transition rules, and bounded history, alongside a `SimpleState` alternative for simpler needs.

- [`physics`](rust_modules/physics.md)
  - At its center is the `World` struct, which completely encapsulates the Rapier simulation state, including body sets, collider sets, joint sets, and the broad/narrow-phase collision pipelines. The simulation is advanced via deterministic fixed-timestep sub-stepping (`step_fixed`), ensuring consistent and predictable physical interactions regardless of frame rate fluctuations.

- [`pipeline`](rust_modules/pipeline.md)
  - It is designed to sequence complex, multi-step operations—such as asset processing, test orchestration, analytics batching, or mod build workflows—by strictly enforcing dependency ordering. At the core of the module is the `Pipeline` struct, which stores named `PipelineStep`s and their dependencies. Using Kahn's algorithm, it performs topological sorting to determine the correct execution order and detects cycles before a workflow can run. It also groups independent steps into parallel execution tiers, allowing unrelated tasks to be scheduled concurrently.

- [`procgen`](rust_modules/procgen.md)
  - It offers a rich suite of deterministic, headless-testable algorithms for creating diverse game worlds, terrains, and structures. Central to the module is a robust `NoiseGenerator` built on an internal seeded Linear Congruential Generator (LCG). It supports 2D/3D/4D Perlin and Simplex noise, as well as 2D/3D Worley (cellular) noise with various distance metrics. These base noises can be combined using fractal combinators like Fractal Brownian Motion (FBM), ridged multifractal, and turbulence, and deformed via domain warping. For map generation, `procgen` provides sequential and parallel (`rayon`-powered) heightmap generation with options for hydraulic erosion, which can then be classified into dynamic biomes (e.g., ocean, desert, forest) via the `BiomeClassifier`.

- [`province`](rust_modules/province.md)
  - The `province` module is an advanced Edge/Integration tier subsystem that provides a complete, engine-native province map runtime, tailor-made for grand strategy and map-painting games in Lurek2D. Operating independently of tilemaps, it manages irregular, pixel-perfect regions using a `ProvinceRegistry`. This registry acts as the central source of truth, storing metadata for each province—including ownership, terrain type, border styles, capital coordinates, label anchors, and arbitrary string attributes. At its core, the registry maintains a `ProvinceGraph` that tracks undirected adjacencies, allowing for rapid topological queries (e.g., neighbor enumeration) and game-defined border types registered from Lua (e.g., land, coast, river — defined per-game rather than hardcoded).

- [`raycaster`](rust_modules/raycaster.md)
  - It projects a grid-based 2D map into a textured, first-person 3D perspective using Digital Differential Analyzer (DDA) ray-stepping. At the core is the `Raycaster2D` struct, which maintains the tile grid. Each cell in the grid can be assigned per-face wall textures (North, South, East, West), floor/ceiling textures, alpha transparency overrides, and unique height modifiers via the `HeightMap` system (allowing for variable-height floors, ceilings, and lowered pits). The DDA stepper casts rays for each screen column, applies perpendicular distance corrections (to fix "fish-eye" distortion), and emits texture-sampled wall slices.

- [`render`](rust_modules/render.md)
  - Backed by `wgpu 22`, it utilizes a deferred `RenderCommand` queue architecture. Rather than executing GPU commands immediately during game logic, Lua scripts emit draw commands (for rectangles, circles, lines, polygons, text, textures, and meshes) into a frame-local buffer. At the end of the frame, the `GpuRenderer` sorts these commands by z-order using the `DrawLayer` system, batches compatible operations to minimize state changes, and encodes highly optimized wgpu render passes. This deferred approach ensures that no heavy GPU work stalls the Lua execution thread.

- [`repl`](rust_modules/repl.md)
  - Designed to execute Lua commands dynamically, it empowers developers and users to introspect state, run functions, and tweak variables at runtime. At its center is the `ReplSession`, a stateful evaluator that operates over an existing `mlua::Lua` VM without directly owning it. This design makes the REPL completely headless—processing string input and returning string output—so it can be seamlessly embedded into both in-game GUI developer terminals and external command-line debug bridges.

- [`runtime`](rust_modules/runtime.md)
  - As a Core Runtime tier component, it defines the essential shared state, engine configuration, unified error handling, and structured logging mechanisms upon which every other engine subsystem relies. At the heart of the module is `SharedState`, a central, mutable state container accessed via `RefCell` borrows. It orchestrates cross-module communication during a frame, tracking window state, input aggregation, timing profiles, asynchronous file I/O (GameFS), render pipeline configurations, and managing slot-map resource pools (textures, fonts, shaders, particle systems, etc.) while enforcing memory budgets via LRU eviction.

- [`save`](rust_modules/save.md)
  - It enables developers to reliably save and load game state with built-in support for compression, file rotation, and schema versioning. The architecture is built around the `SaveManager`, which coordinates persistence using a named-section approach. Developers register game modules (like inventory, player stats, or level state) by assigning a string name and providing paired `collect` and `restore` Lua callback functions. During a save operation, the manager queries these collectors to gather the current game state as a Lua table; during load, the state is passed back via the restorers.

- [`scene`](rust_modules/scene.md)
  - It provides the structural backbone for Lurek2D games by coordinating transitions between distinct game states, such as main menus, gameplay levels, and pause screens. The core `SceneStack` maintains the active scene hierarchy. Pushing a new scene pauses the underlying scene, while popping it resumes the previous one. The module supports overlay scenes for logic flow, but rendering now follows a strict engine-level rule: **only the top scene is render-active**.

- [`serialize`](rust_modules/serialize.md)
  - At its core, it relies on the recursive `SerialValue` enum—an intermediate type-erased representation—to seamlessly map between native Lua tables and six popular text and binary formats: JSON, TOML, CSV, XML, INI, and MessagePack. This design allows developers to read and write diverse data sources using a unified API without worrying about the underlying parsing mechanics. The module features an intelligent auto-detection system that inspects content bytes to automatically guess the correct `SerialFormat` during decoding, making it exceptionally robust for loading arbitrary user-provided files or unknown network payloads.

- [`spine`](rust_modules/spine.md)
  - Moving beyond traditional frame-by-frame sprites, this module enables fluid, dynamic animations using hierarchical bone trees and slot-based attachments. Central to the system is the `Skeleton` struct, which maintains an ordered array of `Bone` elements. Each bone stores local transform properties (position, rotation, scale) and automatically computes accumulated world-space transforms as they propagate down the parent-child hierarchy. Visual representation is handled via `Slot` attachments, which bind graphical content—such as sprite regions, meshes, or bounding boxes—to specific bones with precise draw-order and blend-mode configurations, ensuring correct back-to-front rendering even in complex layered characters.

- [`sprite`](rust_modules/sprite.md)
  - It provides the essential building blocks for 2D game visuals, encompassing sprite sheets, texture atlases, scalable UI panels, and high-performance batch rendering. At its most basic level, the `Sprite` struct defines a single textured unit with properties for position, scale, rotation, and color tint. To manage animation frames, the `SpriteSheet` divides a single texture into a uniform grid. It supports precomputed frame rectangles, named frame groups for animation sequences, and specific layouts for directional character sprites (such as the standard RPG Maker 3x4 layout).

- [`terminal`](rust_modules/terminal.md)
  - Originally designed to host the in-game developer console, it functions as a highly versatile UI surface capable of rendering classic ASCII interfaces, roguelike displays, and complex debugging tools. At its foundation, the `Terminal` struct manages a fixed-size grid of cells (`TCell`), each storing a character codepoint alongside independent foreground and background colors. The module implements a robust ANSI escape sequence parser (`ansi.rs`), capable of decoding standard 8-color palettes, 256-color xterm indexes, and 24-bit true-color RGB combinations, enabling seamless integration with existing terminal-based output streams and logging tools.

- [`thread`](rust_modules/thread.md)
  - Adhering to the engine's strict architectural constraints (specifically B-04), it ensures that Lua VMs do not share state. Instead, it provisions isolated, per-thread Lua VMs that communicate exclusively via typed Multi-Producer, Multi-Consumer (MPMC) channels. The `Channel` struct is the backbone of this system, offering thread-safe message passing with both bounded (fixed capacity) and unbounded variants. It supports various overflow policies (block, drop-oldest, drop-newest, error) and handles transparent, recursive serialization between Lua values and Rust's `ChannelValue` enum (supporting nil, booleans, numbers, strings, nested tables, and raw bytes).

- [`tilemap`](rust_modules/tilemap.md)
  - Central to this module is the `TileMap` struct, which stores stacked `TileLayer` grids, managing per-cell tile IDs (GIDs), flip flags, collision data, and layer-specific properties like tint and parallax scroll factors. Maps can be populated dynamically or imported from standard industry formats; the module includes robust parsers for both TMX (Tiled) and LDtk map files, seamlessly transforming their XML or JSON data into engine-native structures while supporting orthogonal, staggered, hexagonal, and isometric orientations.

- [`timer`](rust_modules/timer.md)
  - At the core of the engine's main loop sits the `Clock`, which meticulously tracks per-frame delta time, accumulated total elapsed time, and a rolling frames-per-second (FPS) measurement. To ensure smooth gameplay and stable adaptive logic, it calculates a rolling average delta using a fixed-size ring buffer, which mitigates frame-time jitter. Furthermore, its internal microsecond accumulation employs fractional sub-microsecond carry, completely preventing time-drift errors across frames.

- [`tween`](rust_modules/tween.md)
  - It provides a robust engine for animating numeric properties over time, making it ideal for UI transitions, camera movements, and gameplay juice. At its core, `LuaTween` interpolates a single numeric property (or multiple numeric fields on a single Lua table) from a start value to a target value over a specified duration. Developers can choose from over 30 built-in easing curves—including linear, quadratic, cubic, elastic, bounce, and back—or register custom easing functions to achieve the exact feel required. Tweens support full lifecycle callbacks (`onUpdate`, `onComplete`, `onCancel`) and can be configured to repeat infinitely, yoyo (reverse direction on repeat), or operate in relative mode where targets act as offsets.

- [`ui`](rust_modules/ui.md)
  - Designed for both engine tooling and in-game interfaces, it centers around the `GuiContext`, which manages the stateful widget tree, focus navigation, input routing, and rendering lifecycle. The framework offers an extensive library of over 35 distinct widget types, ranging from core controls (Buttons, Labels, TextInputs, Checkboxes, Sliders, ComboBoxes, ProgressBars) to advanced layout containers (ScrollPanels, SplitPanels, DockPanels) and specialized extras (TreeViews, Toolbars, Menus, Accordions, ColorPickers). All widgets embed a shared `WidgetBase` that handles layout parameters, visibility, anchoring, and transitions.

- [`validator`](rust_modules/validator.md)
  - The `validator` module equips developers and CI pipelines with a structured static analysis engine for Lua game scripts. The central `ValidationEngine` is configured via `ValidatorConfig` (deserialized from a `[validator]` TOML block) and orchestrates a set of `ValidationRule` implementations over a file tree in parallel using a Rayon worker pool. Thread count defaults to the configured value; 0 forces synchronous single-threaded mode.

- [`visibility`](rust_modules/visibility.md)
  - The `visibility` module provides a universal fog-of-war and discovery layer that can be attached to any region-based map without coupling to a specific map module. The foundational abstraction is the `AdjacencyProvider` trait: callers implement a single `neighbors(region_id)` method to describe neighbor relationships. Grid maps inject 4- or 8-directional adjacency; province maps use their border index; custom systems supply arbitrary neighbor lists. This injection point is the only geometry dependency.

- [`window`](rust_modules/window.md)
  - Built upon the robust `winit` 0.30 backend, it controls window creation, sizing, positioning, and input acquisition while insulating the game loop from native platform quirks. To ensure frame-perfect consistency, the `WindowState` system employs a deferred update strategy: requests to change properties like title, size, position, fullscreen mode, or cursor visibility are queued during the frame and applied atomically just before the next event poll, completely eliminating mid-frame tearing or inconsistent state reads.

## Powiązane

- [Architecture](architecture/engine-core.md)
- [Generated Rust API (Markdown)](api/rust.md)
