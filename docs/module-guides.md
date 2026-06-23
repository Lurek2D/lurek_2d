# Module API Specs

This GitHub Pages site contains only generated API module specs and runtime callbacks.

Callbacks: [Runtime callbacks](api/callbacks.md)

| Module | Namespace | Purpose |
|---|---|---|
| [Agent](modules/agent.md) | `lurek.agent` | The agent module is the engine's AI-assistant surface for users who want LLM-backed behavior inside the runtime without building transport, memory, and orchestration infrastructure from scratch. |
| [AI](modules/ai.md) | `lurek.ai` | The ai module is the engine's gameplay-intelligence surface for users who need actors to perceive, decide, coordinate, and adapt in ways that go far beyond hard-coded if-then behavior. |
| [Animation](modules/animation.md) | `lurek.animation` | The animation module is the engine's time-based motion system for users who need sprites, poses, and related visual states to advance through structured runtime playback. |
| [Asset](modules/asset.md) | `lurek.asset` | The asset module is the shared runtime catalog for loaded resources, so users can work with stable handles instead of repeatedly reopening raw file paths. |
| [Audio](modules/audio.md) | `lurek.audio` | The audio module is the engine's main runtime sound system for users who need playback, routing, source state, timing, and mix control to live under one API. |
| [Automation](modules/automation.md) | `lurek.automation` | The automation module is the scripted replay layer for users who want deterministic QA, repeatable demos, or regression-oriented gameplay checks. |
| [Binary](modules/binary.md) | `lurek.binary` | The binary module is the byte-oriented data surface for users who need exact control over compact formats, protocol payloads, and structured runtime interchange. |
| [Camera](modules/camera.md) | `lurek.camera` | The camera module is the engine's shared view-control surface for users who need world motion to become readable player-facing framing. |
| [Charts](modules/charts.md) | `lurek.charts` | The charts module is the engine's in-runtime data-visualization surface for users who want tables, counters, time series, and distributions to become readable graphics. |
| [Cinematic](modules/cinematic.md) | `lurek.cinematic` | Multi-track timeline system for orchestrating game sequences. |
| [Color](modules/color.md) | `lurek.color` | The color module is the shared toolbox for defining, converting, and reusing runtime color values across the engine. |
| [Compute](modules/compute.md) | `lurek.compute` | The compute module is the dense numeric workspace for users who want array-heavy processing, analysis, and transformation logic inside the engine. |
| [Cursor](modules/cursor.md) | `lurek.cursor` | The cursor module is the pointer-behavior surface for users who want the cursor to feel like part of the game UX rather than a fixed OS artifact. |
| [Dataframe](modules/dataframe.md) | `lurek.dataframe` | The dataframe module is the engine's tabular-data workspace for users who want table-shaped information to be loaded, queried, transformed, summarized, and exported without leaving the runtime. |
| [Debugbridge](modules/debugbridge.md) | `lurek.debugbridge` | The debugbridge module is the remote inspection channel between a running game and external development tools such as the VS Code extension or MCP-style clients. |
| [Devtools](modules/devtools.md) | `lurek.devtools` | The devtools module is the live diagnostics surface for users who need to inspect runtime behavior while the game is still running. |
| [Dialog](modules/dialog.md) | `lurek.dialog` | The dialog module is the conversation-runtime surface for users building branching narrative, tutorial flows, reactive chatter, or choice-driven exchanges. |
| [Docs](modules/docs.md) | `lurek.docs` | The docs module treats documentation as an active engine-managed system rather than as a pile of disconnected markdown files. |
| [DSP](modules/dsp.md) | `lurek.dsp` | The dsp module is the programmable signal-processing layer for users who need audio to be transformed, analyzed, or synthesized at runtime. |
| [ECS](modules/ecs.md) | `lurek.ecs` | The ecs module is the engine's entity-component world model for users who want gameplay state to scale through entities, components, queries, and scheduled systems. |
| [Effect](modules/effect.md) | `lurek.effect` | The effect module is the post-processing surface for users who want final-frame styling to be configurable at runtime instead of buried in renderer internals. |
| [Engine](modules/engine.md) | `lurek.engine` | The engine module is the top-level runtime shell that turns the engine from a set of subsystems into one running desktop application. |
| [Event](modules/event.md) | `lurek.event` | The event module is the central message-routing layer for users who want runtime systems to communicate without hardwiring direct dependencies. |
| [Filesystem](modules/filesystem.md) | `lurek.filesystem` | The filesystem module is the sandboxed storage surface for users who need file access without giving every script raw platform path power. |
| [Font](modules/font.md) | `lurek.font` | The font module is the typography layer for users who need predictable text behavior in UI, HUDs, overlays, or retro-style screens. |
| [Globe](modules/globe.md) | `lurek.globe` | The globe module is the planetary-map surface for users who want a world-scale spherical view to behave as a full gameplay and tooling system instead of a decorative background. |
| [Graph](modules/graph.md) | `lurek.graph` | The graph module is the logistics-graph simulation surface for users who want resources, items, queues, routes, and transformation rules to behave as one explicit networked system. |
| [Grep](modules/grep.md) | `lurek.grep` | The grep module is the scriptable text-search surface for users who want to scan project files, logs, or structured content from inside the engine environment. |
| [Html](modules/html.md) | `lurek.html` | The html module is the in-engine document-style UI surface for users who want markup, styles, and DOM-like interaction inside the runtime. |
| [I18n](modules/i18n.md) | `lurek.i18n` | The i18n module is the localization surface for projects that want translated text, locale-aware formatting, and language switching to behave as one system. |
| [Image](modules/image.md) | `lurek.image` | The image module is the engine's CPU-side image workbench for users who need pixel data to be loaded, transformed, composed, inspected, compared, and exported under one coherent API. |
| [Input](modules/input.md) | `lurek.input` | The input module is the engine's unified control surface for users who need keyboard, mouse, gamepad, and touch state to behave as one coherent runtime system. |
| [Layout](modules/layout.md) | `lurek.layout` | The layout module is the automatic placement layer for users who need graph-like structures to become readable 2D diagrams without hand-positioning every node. |
| [Learning](modules/learning.md) | `lurek.learning` | The learning module is the engine's machine-learning and adaptive-policy surface for users who want experimentation, inference, and lightweight training loops to live inside the same runtime as gameplay and tooling code. |
| [Light](modules/light.md) | `lurek.light` | The light module is the engine's shared 2D lighting-data surface for users who need lights, occluders, shadows, and illumination behavior to remain structured before rendering. |
| [Log](modules/log.md) | `lurek.log` | The log module is the common script-facing path for runtime diagnostics, so users can emit messages through one consistent logging surface instead of mixing ad hoc print styles. |
| [Mapblock](modules/mapblock.md) | `lurek.mapblock` | The mapblock module is the engine's modular map-assembly surface for users who want larger spaces built from reusable authored blocks instead of from one monolithic generator. |
| [Math](modules/math.md) | `lurek.math` | The math module is the engine's shared numerical and geometric foundation for users who need consistent rules for coordinates, shapes, transforms, interpolation, sampling, and spatial reasoning across many feature areas. |
| [Midi](modules/midi.md) | `lurek.midi` | The midi module is the playback surface for projects that want symbolic music control instead of treating every cue as rendered audio. |
| [Minimap](modules/minimap.md) | `lurek.minimap` | The minimap module is the HUD-scale map surface for users who want world state, fog, markers, and view tracking to become a compact readable overlay. |
| [Mods](modules/mods.md) | `lurek.mods` | The mods module is the governed extension surface for projects that want external content packs to behave like controlled runtime extensions instead of unrestricted code drops. |
| [Network](modules/network.md) | `lurek.network` | The network module is the engine's communication and session surface for users who need game state, tool messages, service calls, telemetry, or multiplayer traffic to move between processes or machines. |
| [Overlay](modules/overlay.md) | `lurek.overlay` | The overlay module is the engine's screen-layer presentation surface for users who want weather, atmosphere, transitions, and other scene-wide visual treatments to behave as one coherent system. |
| [Parallax](modules/parallax.md) | `lurek.parallax` | The parallax module is the layered-background surface for projects that want depth and atmospheric motion without full 3D simulation. |
| [Particle](modules/particle.md) | `lurek.particle` | The particle module is the pooled visual-effects system for users who want smoke, sparks, rain, trails, bursts, and other transient visuals to behave like one reusable runtime feature. |
| [Pathfind](modules/pathfind.md) | `lurek.pathfind` | The pathfind module is the engine's navigation and movement-analysis surface for users who need more than one hard-coded shortest-path helper. |
| [Patterns](modules/patterns.md) | `lurek.patterns` | The patterns module is the engine's reusable architectural toolkit for users who want common coordination, control-flow, storage, and utility structures implemented once and then reused across gameplay, tools, UI, AI, and automation features. |
| [Physics](modules/physics.md) | `lurek.physics` | The physics module is the engine's 2D simulation authority for users who want motion, contact, shapes, joints, and collision queries to live inside one consistent world model. |
| [Pipeline](modules/pipeline.md) | `lurek.pipeline` | The pipeline module is the engine's workflow-orchestration surface for users who want multi-step processing to behave like explicit directed workflows instead of loosely nested call sequences. |
| [Procgen](modules/procgen.md) | `lurek.procgen` | The procgen module is the engine's procedural-content creation toolkit for users who want maps, regions, structures, names, distributions, and generated support data to be produced inside the engine from reusable algorithms. |
| [Province](modules/province.md) | `lurek.province` | The province module is the engine's territory-region system for users who want named areas, borders, ownership, routing, and province-like gameplay state to behave as one native feature. |
| [Raycaster](modules/raycaster.md) | `lurek.raycaster` | The raycaster module is the engine's pseudo-3D first-person view system for users who want corridor shooters, dungeon crawlers, exploration views, or tactical previews built from structured 2D world data instead of from a full freeform 3D engine stack. |
| [Render](modules/render.md) | `lurek.render` | The render module is the engine's central visual execution layer, responsible for turning high-level drawing intent from many other systems into concrete frame output on GPU-backed and software-backed paths. |
| [Repl](modules/repl.md) | `lurek.repl` | The repl module is the interactive evaluation surface for users who want to inspect or execute Lua code live inside a running engine context. |
| [Runtime](modules/runtime.md) | `lurek.runtime` | The runtime module is the shared engine-state surface that many other modules depend on before they expose their own user-facing features. |
| [Save](modules/save.md) | `lurek.save` | The save module is the persistence-lifecycle surface for users who want game state to be stored, versioned, and restored as a managed workflow instead of a raw file dump. |
| [Scene](modules/scene.md) | `lurek.scene` | The scene module is the high-level flow coordinator for users who want menus, gameplay states, overlays, pause layers, and transitions to behave like one ordered stack instead of a collection of unrelated toggles. |
| [Serial](modules/serial.md) | `lurek.serial` | The serial module is the format-translation surface for users who want several external data formats to map into one shared runtime value model. |
| [Spine](modules/spine.md) | `lurek.spine` | The spine module is the skeletal-animation surface for users who want bone-based rigs, slots, skins, and timeline-driven pose changes inside the engine. |
| [Sprite](modules/sprite.md) | `lurek.sprite` | The sprite module is the engine's textured-2D surface for users who want single sprites, sheets, atlases, scalable panels, and batched instances to share one coherent runtime model. |
| [SVG](modules/svg.md) | `lurek.svg` | The svg module is the engine surface for scalable vector artwork, aimed at users who want SVG-style content to stay editable and resolution-independent for as long as possible. |
| [Terminal](modules/terminal.md) | `lurek.terminal` | The terminal module is the engine's character-grid interface surface for users who want text-mode displays, debug consoles, command panels, or roguelike-style presentation. |
| [Thread](modules/thread.md) | `lurek.thread` | The thread module is the isolated-concurrency surface for projects that want background Lua work without violating the engine's VM and runtime-safety rules. |
| [Tilefield](modules/tilefield.md) | `lurek.tilefield` | Coordinates exposed to Lua are one-based x, y, z; Rust storage is zero-based. |
| [Tilemap](modules/tilemap.md) | `lurek.tilemap` | The tilemap module is the engine's full grid-world framework for users who want tile-based spaces to be authored, generated, rendered, queried, and traversed through one reusable system rather than through several disconnected helpers. |
| [Timer](modules/timer.md) | `lurek.timer` | The timer module is the shared time-management surface for users who need clocks, delayed callbacks, repeating work, and timing queries to behave consistently. |
| [Tween](modules/tween.md) | `lurek.tween` | The tween module is the engine's interpolation and motion-sequencing surface for users who want values to change over time without hand-writing frame-by-frame update loops. |
| [UI](modules/ui.md) | `lurek.ui` | The ui module is the engine's retained-interface system for users who want menus, HUDs, editors, overlays, and tool panels to behave like one persistent application layer instead of a loose pile of draw calls and ad hoc click tests. |
| [Validator](modules/validator.md) | `lurek.validator` | The validator module is the content-checking surface for users who want assets, imports, and API usage to be verified as a structured workflow instead of informal manual review. |
| [Visibility](modules/visibility.md) | `lurek.visibility` | The visibility module is the shared answer to fog-of-war, line-of-sight, and remembered exploration for users building map-aware gameplay. |
| [Window](modules/window.md) | `lurek.window` | The window module is the desktop-window control surface for users who need display selection, viewport scaling, mode changes, and OS-facing window behavior under one runtime API. |
