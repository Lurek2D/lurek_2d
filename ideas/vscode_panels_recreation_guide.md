# Detailed Description of VS Code Panels and Functions (Recreation Guide for Gemini Canvas)

This document contains a comprehensive specification of all standard Visual Studio Code panels and custom Lurek2D editors. It emphasizes a detailed **description of available features** and the **purpose** of each element, serving as a direct instruction manual for recreating a full-fledged IDE interface as a standalone application (e.g., in Gemini Canvas).

---

## UX / UI Layout Conventions for Webview Editors

To maintain a true MS VS Code experience, every custom Lurek2D editor should strictly adhere to the following layout conventions. The AI agent implementing these panels must use this spatial architecture to ensure a uniform developer experience:

1. **Top Action Toolbar:** 
   - Positioned directly under the editor tab.
   - Used for global/document-level actions.
   - Typical buttons: `Save`, `Import/Export`, `Play/Pause/Stop` (for simulations), `Zoom In/Out`, and `Toggle Grid/Snap`.
   - Never place object-specific property forms here.

2. **Left Sidebar (Palette / Tool Picker):**
   - Typically used for *Selection* and *Tool modes*.
   - Contains tools (Brush, Eraser, Selection Marquee).
   - Contains libraries (Tile Palettes, Node lists to drag-and-drop into a graph, Prefab lists).
   - Can be collapsed to maximize canvas space.

3. **Right Sidebar (Inspector / Configuration):**
   - Strictly reserved for *Properties* and *Configuration*.
   - When a user clicks a node, tile, or entity in the main canvas, this panel populates with its specific properties (e.g., X/Y coordinates, health values, specific names).
   - This is where complex TOML/JSON fields are exposed as input boxes, dropdowns, and sliders.

4. **Main Canvas (Center):**
   - The primary interactive zone (Grid map, Node Graph, Text Editor, 3D Viewport).
   - Must support panning (Middle Mouse Button / Space+Drag) and zooming (Mouse Wheel).

5. **Bottom Panel (Optional):**
   - Reserved for temporal or analytical data.
   - Typically houses Timelines (for animation), Output Logs (for testing/compilation errors), or Data Tables.

---

## 1. Activity Bar

**Purpose:** 
Provides the main global navigation point between the application's primary workspaces (Viewlets). It acts as a switcher that changes the content of the adjacent Side Bar.

**Detailed Feature List:**
- **View Switching:** Clicking an icon (Explorer, Search, Source Control, Run & Debug, Extensions) loads the corresponding view in the Side Bar. Clicking the active icon again collapses/hides the Side Bar.
- **Status Badges:** Dynamic notifications on icons, such as a blue circle with the number of uncommitted files (in Git) or available extension updates.
- **Global Actions (Bottom):**
  - **Account Management (User Icon):** Log in to synchronize settings or authenticate with GitHub.
  - **Settings (Gear Icon):** Expands a global menu granting access to Settings, Keyboard Shortcuts, Color Themes, and the Command Palette.
- **Layout Management:** Users can drag and drop icons to reorder them and right-click to hide specific icons entirely.

---

## 2. Side Bar (Main Panel)

**Purpose:** 
Displays detailed tools, trees, lists, and information for the currently selected context from the Activity Bar.

### A. View: Explorer
**Purpose:** Manage the project's file and folder structure.
**Features:**
- **File Tree:** Displays directory structures with support for expanding/collapsing folders, creating new files/folders, renaming, and deleting. Supports file drag & drop.
- **Open Editors:** A list of currently open tabs in the editor area, allowing quick closing, saving, or switching without searching through the top tab bar.
- **Outline:** A hierarchical tree of classes, methods, functions, and variables in the currently open file, enabling instant navigation to specific code blocks.
- **Timeline:** A history of local saves and Git revisions for a specific file, allowing preview and restoration of older versions.

### B. View: Search (Global Search)
**Purpose:** Search and replace text across the entire open workspace ("find in files").
**Features:**
- **Search and Replace:** Input fields for *Search* and *Replace*.
- **Match Options:** Toggles for `Match Case`, `Match Whole Word`, and `Use Regular Expression`.
- **Path Filtering:** `Files to include` and `Files to exclude` fields to target specific file types or ignore directories (e.g., `node_modules`).
- **Result View:** Results grouped by file. Clicking a result instantly navigates to the exact line in the editor, highlighting the match.

### C. View: Source Control (Git)
**Purpose:** Manage modification history, commit changes, and synchronize with a remote repository.
**Features:**
- **Commit Message Box:** Text area to write change descriptions, paired with a `Commit` button.
- **Changes Tree:** List of files separated into `Staged Changes` (included in the commit) and `Changes` (modified but not staged).
- **Inline Actions:** Quick buttons next to each file: `+` (Stage), `-` (Unstage), and `Arrow` (Revert changes).
- **Diff View:** Clicking a file in the list opens a Diff View (before/after comparison) in the editor area, highlighting added and removed lines.

### D. View: Run and Debug
**Purpose:** Full control over application execution and step-by-step code debugging.
**Features:**
- **Variables:** A tree showing local and global variables and their current values when paused at a breakpoint.
- **Watch:** Ability to add custom mathematical expressions or variable names that are continuously evaluated.
- **Call Stack:** The execution path showing how the application reached the current line, allowing navigation up and down the stack.
- **Breakpoints:** List and management of all breakpoints set in the code, with one-click toggles to enable/disable them.

### E. View: Extensions
**Purpose:** Install and manage plugins integrated into the IDE.
**Features:**
- **Search and List:** A module to search for extensions by keywords, displaying descriptions, install counts, and ratings.
- **State Management:** Options to Disable, Uninstall, or Install each item directly from the sidebar list.

---

## 3. Editor Area

**Purpose:** The main workspace canvas where the user reads/writes code, analyzes file differences, and interacts with rich plugin interfaces. It is the most complex area of the window.

**Detailed Feature List:**

### A. Tabs and Editor Groups
- **Tabs:** Cards for open files at the top of the area. Tabs support visual states:
  - "Active" (highlighted).
  - "Unsaved" (a dot replaces the 'X' icon).
  - "Preview" (italic text – the file is only being previewed and will be replaced if another preview is opened).
  - "Pinned" (pin icon – hides the filename and minimizes tab width).
- **Editor Groups (Grid/Split):** A system allowing vertical and horizontal space division. Users can edit multiple files simultaneously in independent, tiled view groups within a single window.

### B. Main Code Editor (e.g., Monaco Editor)
- **Breadcrumbs:** A thin bar above the text showing the exact structure and cursor location (e.g., `src > components > index.ts > class Server > start()`).
- **Line Numbers & Gutter:** A left margin displaying line numbers with extra features:
  - Space to place red Breakpoint dots.
  - Git decorators – colored vertical bars indicating version control status (green for added, red for deleted).
  - Code Folding – arrows to collapse entire functions or loops into a single line.
- **Minimap:** A miniaturized "bird's-eye" view of the entire file structure on the right edge, acting as a scrollbar and highlighting errors or search results.
- **Scrollbars & Decorators:** The scrollbar acts as a radar; errors or warnings on specific lines appear as colored marks on the scroll track.
- **IntelliSense and Hover:**
  - **Autocomplete:** Context menus suggesting keywords, class properties, and code snippets upon typing.
  - **Hover:** Resting the mouse over a variable or function displays a popup with its JSDoc documentation and type declaration.
  - **Peek Definition:** A shortcut expands a mini-editor inline, showing the source definition of a function without leaving the current file.

---

## 4. Panel (Bottom Panel)

**Purpose:** Consolidates logs, output streams, compilation errors, and terminal access in one place without obstructing the main editor above.

**Detailed Feature List:**

### A. Problems
- A live aggregated list of all Errors, Warnings, and Infos declared by build systems and linters (e.g., ESLint, tsc) across the project.
- Double-clicking a problem opens the file and precisely places the cursor at the exact column of the error.
- Supports text filtering to hide errors from specific files.

### B. Output
- A read-only container for logs generated by background processes.
- Features a dropdown menu to quickly switch "channels" (e.g., Git logs, TypeScript Server, specific extensions).

### C. Debug Console
- A Read-Eval-Print Loop (REPL) interface. Used to interactively type commands directly into the running environment when paused at a breakpoint.

### D. Terminal
- A fully embedded system terminal emulator (bash, PowerShell, zsh) with its own internal tab system.
- Supports running multiple shells simultaneously or splitting a single console in half.
- Clickable Links: File paths printed in the terminal (e.g., `src/index.js:55`) become Ctrl-clickable links that open the file in the editor.

### E. Ports
- Port forwarding management panel. Displays applications running on localhost and allows mapping them to public URLs for collaboration (used heavily in Codespaces/Dev Containers).

---

## 5. Status Bar

**Purpose:** An information bar containing widgets at the very bottom of the screen. It not only displays status but provides instant **shortcuts to modify that status** upon clicking.

**Detailed Feature List (Left to Right):**
- **Remote Host:** Signals remote connections (e.g., "WSL: Ubuntu"). Clicking manages remote sessions.
- **Git Branch:** Displays the active branch. Clicking opens a quick-pick menu to checkout or create branches.
- **Git Sync:** Shows commits ahead/behind the remote. Clicking executes a background Fetch -> Pull -> Push.
- **Problems Summary:** Quick overview of project errors/warnings (X Error, ! Warning). Clicking focuses the bottom Problems Panel.
- **Cursor Position (Ln X, Col Y):** Real-time display of the cursor's exact line and column.
- **Indentation:** Displays space or tab rules (e.g., `Spaces: 2`). Clicking allows instant conversion between tabs and spaces.
- **Encoding & Line Endings:** Parameters like `UTF-8` and `CRLF`. Clicking allows saving or reopening the document with new encoding.
- **Language Mode:** Displays the recognized language (e.g., `TypeScript`). Clicking allows overriding the syntax highlighting mode regardless of the file extension.
- **Notifications (Bell Icon):** Opens an archive of past toast notifications.

---

## 6. Title Bar & Command Palette

**Purpose:** Provides access to all program options that lack dedicated windows, organized via a global search engine. Relies heavily on keyboard shortcuts (Ctrl+P / Cmd+P).

**Detailed Feature List:**
- **Command Center:** A central search bar replacing traditional menus (File, Edit, View). Clicking opens the Command Palette.
- **Command Palette:** The main dialog engine, functioning differently based on the leading character:
  - `>` : Execute a command (e.g., `> Format Document`). Searches hundreds of built-in and extension actions.
  - *(no prefix)* : "Go to File". Fuzzy search across all workspace files by name.
  - `@` : "Go to Symbol in Editor". Lists all variables and functions in the current file.
  - `#` : "Go to Symbol in Workspace". Global search for classes and functions across the entire project.
  - `:` : Line navigation (e.g., typing `:150` jumps to line 150).
- **Layout Control:** Buttons in the top right corner to instantly toggle the visibility of the Activity Bar, Side Bar, and Bottom Panel.

---

## 7. Custom Editors (Lurek2D Engine Tools)

Lurek2D at its core philosophy operates like Love2D: a beautiful, code-first API without a bloated standalone editor. However, when paired with MS VS Code and these 31 custom webview editors, the experience transforms into a cohesive, Godot-like environment. 

The primary requirement for these editors is that they **must generate and save data formats perfectly and natively compatible with specific Lurek2D API modules**. Each editor has a strictly unique use case to prevent functionality overlap and ensure a unified pipeline.

### 1. TileMapEditor
- **Reference / Inspiration:** Tiled Map Editor, Godot TileMap Node.
- **Use case:** Designing and building 2D grid-based maps, levels, and environments manually.
- **Lurek API Integration:** Tightly integrated with `lurek.tilemap`. Outputs data loaded natively to instantiate grid-based structures.
- **Ideas / Vision:** This editor must strictly focus on deterministic, hand-crafted level design to distinguish itself from the ProcMapEditor. It should output an optimized spatial grid format (`.ltm`) that the `lurek.tilemap` namespace can immediately consume for culling and collision generation without extra parsing logic.
- **Feature list:**
  - Layer management (add, delete, reorder) for parallax and depth sorting.
  - Interactive tile palette selector fetching from defined Tilesets.
  - Brush drawing tool with dynamic sizing.
  - Flood fill algorithm for rapid area coloring.
  - Stamp tool for saving and pasting multi-tile patterns (e.g., entire houses).
  - Collision mask painting mode overlay.
  - Auto-tiling support for seamless terrain generation on the fly.
  - Custom property injection per tile for logical triggers.

### 2. SceneFlowEditor
- **Reference / Inspiration:** Unity Animator (State Machine View), Unreal Engine Blueprints.
- **Use case:** Designing the global state machine structure defining transitions between scenes (e.g., Splash -> Main Menu -> Gameplay).
- **Lurek API Integration:** Integrates with `lurek.scene` and `lurek.scene.transitions` to generate state machine flows.
- **Ideas / Vision:** Must act as the absolute top-level entry point router. It should completely eliminate the need for hardcoded state-switching logic by letting developers visually connect which Scene loads when an event is fired.
- **Feature list:**
  - Visual node-based state machine editor mapping entire game states.
  - Drag-and-drop state creation for UI screens and gameplay segments.
  - Event-driven transition linking lines with conditional parameters.
  - Real-time path highlighting during live gameplay debugging.
  - State validation and unreachable code/node checking.
  - Global variable bindings persistent across specific state transitions.
  - Export flow data structurally to JSON/Lua definitions.
  - Nested sub-scenes visualization for complex, deep UI menus.

### 3. EntityEditor
- **Reference / Inspiration:** Godot Node Inspector, Unity GameObject Inspector.
- **Use case:** Visual configuration of "prefabs" or in-game spatial objects by setting their attributes and components.
- **Lurek API Integration:** Fully bound to `lurek.ecs` (Entity Component System). Outputs data that translates directly into ECS entities.
- **Ideas / Vision:** Completely distinct from the DatabaseEditor. This editor focuses exclusively on spatial, component-based actors in the world. It provides the Godot-like "Inspector" experience where developers assemble an entity from a Sprite and a Collider without writing boilerplate ECS registration code.
- **Feature list:**
  - Component attachment library (Transform, Sprite, Rigidbody, Custom Scripts).
  - Real-time component property inspector with slider and text inputs.
  - Visual bounds, hitbox, and offset relative child preview.
  - Default instantiation value overriding directly in the inspector.
  - Nested child entity grouping (Parent/Child transform hierarchy).
  - Quick-search component filtering.
  - Copy/paste entire component configurations between different entities.
  - Live stat and variable monitoring while the game is running.

### 4. PixelArtEditor
- **Reference / Inspiration:** Aseprite, Piskel.
- **Use case:** Built-in painting tool allowing editing, drawing from scratch, and tweaking pixel-art textures directly in the IDE.
- **Lurek API Integration:** Works with `lurek.image` and `lurek.sprite` to save and live-reload optimized image assets.
- **Ideas / Vision:** Must integrate flawlessly with Lurek's live-reload functionality. If an artist tweaks a single pixel in this editor, it must instantly reflect on the moving character in the running Lurek2D game window via `lurek.image` hot-reloading.
- **Feature list:**
  - Pixel-perfect pencil and eraser tools optimized for low resolutions.
  - Bucket fill and magic wand with tolerance settings.
  - Multi-layer management with opacity and blend mode controls.
  - Custom color palette selection locked to specific hexadecimal ranges.
  - Symmetry and mirror drawing axes for character faces.
  - Frame-by-frame animation timeline integrated into the painting view.
  - Onion skinning for visualizing previous and next frames.
  - Real-time zoom and customizable grid overlays.

### 5. ParticleEditor
- **Reference / Inspiration:** Unity Shuriken Particle System, Godot Particles2D.
- **Use case:** Authoring 2D particle systems—creating visual special effects like smoke, explosions, or sparks.
- **Lurek API Integration:** Integrates directly with `lurek.particle` and `lurek.effect` namespaces.
- **Ideas / Vision:** Must remain completely distinct from the PostFxOverlayEditor. The ParticleEditor deals with localized, spawned spatial entities in the `lurek.particle` system, whereas PostFx handles global screen space.
- **Feature list:**
  - Emitter shape configuration (cone, circle, edge, box area).
  - Lifetime, emission rate, and max particle count controls.
  - Color over lifetime complex gradient curve editor.
  - Size and scale over time spline interpolations.
  - Gravity, wind vector, and tangential velocity modifiers.
  - Live interactive preview canvas running local physics simulations.
  - Burst emission triggers for explosion effects.
  - Custom texture/sprite assignment per individual particle.

### 6. DialogEditor
- **Reference / Inspiration:** Twine, Yarn Spinner, Articy: Draft.
- **Use case:** Composing branching and multi-threaded narrative dialogue for RPGs or adventure games.
- **Lurek API Integration:** Generates data for `LDialogueAI` inside the `lurek.ai` namespace, rendering text via `lurek.html`.
- **Ideas / Vision:** Uniquely bridges narrative with AI logic. It must not overlap with the QuestTreeEditor: Dialog is strictly for conversational text and dialogue AI choices, while QuestTree tracks game-state progress. It utilizes `LDialogueAI` for topic and branch selection.
- **Feature list:**
  - Node-based branching narrative and conversation structure layout.
  - Designated NPC and Player dialogue nodes with distinct styling.
  - Conditional checks for node execution (e.g. requires specific item in inventory).
  - Lua script trigger insertion to execute game commands mid-sentence.
  - Localization key mapping for multi-language translation.
  - Character portrait and mood assignment per dialogue line.
  - Voice-over audio track linking and playback preview.
  - Auto-arrange layout tool for massive, tangled conversation webs.

### 7. DatabaseEditor
- **Reference / Inspiration:** CastleDB, RPG Maker Database, Google Sheets.
- **Use case:** Editing and managing pure game mechanics databases (e.g., weapon stats, merchant prices, loot tables) in a spreadsheet layout.
- **Lurek API Integration:** Interfaces with `lurek.data` and `lurek.dataframe` namespaces to export structured tables.
- **Ideas / Vision:** Distinctly handles tabular, abstract game balance data. Unlike the EntityEditor, the DatabaseEditor is where systems designers balance numeric values across hundreds of rows without ever looking at visual sprites, heavily utilizing `lurek.dataframe` capabilities.
- **Feature list:**
  - Spreadsheet-style interactive grid view.
  - Strongly-typed columns (integer, string, boolean, enum, asset reference).
  - Advanced row sorting, tagging, and filtering capabilities.
  - Foreign key relational linking between distinct tables.
  - CSV/JSON structural import and export mapping.
  - Bulk find/replace and math operations (e.g., +10% to entire column).
  - Custom Lua formula columns for calculated fields.
  - Real-time data validation and schema error highlighting.

### 8. ProcMapEditor
- **Reference / Inspiration:** World Machine (2D adaptation), Blender Geometry Nodes.
- **Use case:** Tuning procedural generation algorithms for maps, dungeons, and caves by manipulating seeds and mathematical noise grids.
- **Lurek API Integration:** Feeds procedural rules and noise generation configuration directly to `lurek.procgen` and `lurek.math`.
- **Ideas / Vision:** Outputs the *rules* of generation for `lurek.procgen` rather than baking static maps. It gives technical artists a playground to visually tweak Perlin noise octaves in `lurek.math`, outputting a configuration file for runtime generation.
- **Feature list:**
  - Visual noise generation and heatmap preview.
  - Configurable seed and frequency numeric inputs.
  - Multi-octave Perlin/Simplex noise node mixing.
  - Rule-based biome assignment based on moisture/elevation data.
  - Density thresholds and radial falloff map masking.
  - Real-time procedural map generation visualization overlay.
  - Export generated heightmaps to PNG assets.
  - Terrain smoothing and cellular automata configuration controls.

### 9. QuestTreeEditor
- **Reference / Inspiration:** Obsidian Canvas, Articy: Draft (Quest Flows).
- **Use case:** Defining main story arcs and side quests as branching objective trees.
- **Lurek API Integration:** Integrates with `lurek.save`, `lurek.event`, and `lurek.patterns` to track objective flags.
- **Ideas / Vision:** Acts as the macro-orchestrator of game states. It allows developers to visualize the entire logical flow of the game's campaign without hardcoding progression flags, tracking states directly through `lurek.save` events.
- **Feature list:**
  - Visual flowchart mapping of quest progression stages.
  - Prerequisite and mutual exclusion link routing between nodes.
  - Objective tracking configuration (e.g., kill 5 X, fetch Y).
  - Reward dispensing triggers upon successful node completion.
  - Interactive quest stage simulation mimicking player progress.
  - Automatic layout generation for complex branching story arcs.
  - Note and documentation attachments for writers.
  - Quest state tracking and live debugging overlay.

### 10. GuiWidgetEditor
- **Reference / Inspiration:** Figma, Godot Control Nodes, Unity UI Builder.
- **Use case:** Visually designing and composing user interfaces (UI/HUD, inventory windows, health bars, menus).
- **Lurek API Integration:** Outputs UI layouts designed with HTML/CSS directly for the `lurek.html` namespace.
- **Ideas / Vision:** Focuses purely on screen-space anchors and relative positioning using standard web technologies. It provides a visual builder so developers don't have to guess X/Y pixel coordinates in code, letting `lurek.html` natively render the resulting layouts.
- **Feature list:**
  - Drag-and-drop UI component canvas (Divs, Text, Buttons).
  - Screen anchor and alignment snapping features.
  - Margin, padding, and Flexbox properties inspector.
  - Font and text styling CSS overrides.
  - TOML to CSS translation property panel.
  - Z-index layer management for overlapping HUD elements.
  - Hover and click active state simulation previews.
  - Responsive scaling simulation across various aspect ratios.

### 11. AiBehaviorEditor
- **Reference / Inspiration:** Unreal Engine Behavior Tree Editor, NodeCanvas.
- **Use case:** Constructing artificial intelligence logic for characters using Behavior Trees.
- **Lurek API Integration:** Integrates natively with `lurek.ai` (specifically `LAIWorld`, `LBehaviorTree`, and `LBTNode`).
- **Ideas / Vision:** Distinct from the general GraphEditor. This is strictly designed around the strict paradigm of Behavior Trees (Selectors, Sequences, Decorators) for decision-making agents. It outputs tree data that `lurek.ai` processes efficiently per tick.
- **Feature list:**
  - Top-down tree execution topology visualization.
  - Composite node insertion (Sequence, Selector, Parallel).
  - Decorator wrapping (Inverter, Limiter, Cooldown, Repeater).
  - Custom condition and action nodes with Lua bindings.
  - Direct compilation of node logic to raw Lua code.
  - Real-time visual execution pinging during live game debug.
  - Sub-tree referencing to modularize AI behaviors.
  - Node copy/paste and duplication across multiple enemy types.

### 12. GraphEditor
- **Reference / Inspiration:** Unreal Engine Blueprints, Godot VisualScript.
- **Use case:** A generic directed-graph editor used for visual scripting and generic logical flows.
- **Lurek API Integration:** Utilizes `lurek.graph` for managing visual node-based execution logic.
- **Ideas / Vision:** Functions as the "Blueprint" equivalent for Lurek2D. It empowers game designers who do not want to type raw Lua code to build custom gameplay logic by connecting functional nodes parsed by `lurek.graph`.
- **Feature list:**
  - Infinite panning and zooming visual scripting canvas.
  - Custom input and output execution/data pins.
  - Typed connection cables enforcing logic (float, string, vector).
  - Live data flow visualization and value inspection during runtime.
  - Grouping and commenting blocks for organized logic.
  - Automatic node arrangement algorithms.
  - Graph diffing capabilities for Git version control.
  - Mini-map navigation for massively complex scripts.

### 13. TilemapScriptEditor
- **Reference / Inspiration:** Warcraft III World Editor (Region triggers), RPG Maker Event Map.
- **Use case:** Attaching specific triggers and Lua mechanics directly to specific cells on a tilemap.
- **Lurek API Integration:** Injects embedded Lua callbacks (e.g., `OnStep`) into `lurek.tilemap` events triggered via `lurek.event`.
- **Ideas / Vision:** A text-based editor strongly bound to physical grid coordinates. It solves the problem of local tile logic by allowing script injection directly onto `lurek.tilemap` data structures.
- **Feature list:**
  - Inline Lua code editor attached to grid coordinates.
  - Syntax highlighting and Lurek API IntelliSense.
  - Exact tile coordinate binding and visualization.
  - Event trigger dropdown selection (OnStep, OnInteract).
  - Debug print console integration within the panel.
  - Parameter exposure allowing designers to tweak variables.
  - Real-time syntax validation before saving.
  - Snippet injection for common logic patterns (e.g., teleporting).

### 14. VoxelEditor
- **Reference / Inspiration:** MagicaVoxel, Blockbench.
- **Use case:** Constructing 3D models using volumetric blocks (voxels).
- **Lurek API Integration:** Exports slice data used by `lurek.raycaster` and pseudo-3D isometric sprites for `lurek.sprite`.
- **Ideas / Vision:** Since Lurek is primarily a 2D engine, this editor provides a unique workflow to create the illusion of 3D. It allows artists to build voxel models and automatically projects them into 2.5D representations for `lurek.raycaster` and `lurek.sprite`.
- **Feature list:**
  - Full 3D grid voxel painting viewport.
  - Layer-by-layer slicing view for interior detailing.
  - Isometric rendering projection preview.
  - Voxel color palette manager with hex inputs.
  - Hollow and fill bucket tools for mass placement.
  - Extrusion and carving operators.
  - Export tools for generating optimized 2D isometric sprite sheets.
  - Lighting and shading parameter adjustments for baked shadows.

### 15. TestRunnerEditor
- **Reference / Inspiration:** Jest VS Code Extension, IntelliJ Test Runner.
- **Use case:** Managing, invoking, and monitoring engine unit tests without relying solely on the console.
- **Lurek API Integration:** Deeply integrated with `lurek.debugbridge` and `lurek.devtools` to fetch test results.
- **Ideas / Vision:** Uniquely bridges the gap between CI/CD pipelines and the developer's immediate VS Code environment. It ensures that writing and running game logic tests through `lurek.devtools` feels native and visual.
- **Feature list:**
  - Categorized hierarchical test list (Pass/Fail/Skip/Running).
  - Test tagging and regex filtering capabilities.
  - Run/Debug execution buttons per individual test or suite.
  - Inline error stack trace expansion mapping back to code lines.
  - Code coverage visualization and heatmaps.
  - Performance execution timers per test.
  - Output log capture segregated per test instance.
  - Automatic re-run on save (Watch mode).

### 16. ApiReferenceEditor
- **Reference / Inspiration:** Dash, Zeal, Godot built-in Help.
- **Use case:** Quick, built-in offline access to the full, specific API documentation of the Lurek2D engine.
- **Lurek API Integration:** Pulls data from `lurek.docs` to provide fully generated, up-to-date offline documentation.
- **Ideas / Vision:** Acts as the offline heartbeat of the Love2D-style code-first philosophy. By reading directly from `lurek.docs`, it guarantees that the documentation never drifts from the actual installed engine version.
- **Feature list:**
  - Full offline markdown-rendered documentation browser.
  - Fuzzy search across all Lurek API namespaces.
  - Syntax examples and executable code snippets.
  - Cross-linking hyperlinks between related functions.
  - One-click copy-to-clipboard API signatures.
  - Dark/Light theme readability support.
  - Detailed parameter and return type definitions.
  - Direct hyperlink to engine source code files.

### 17. PostFxOverlayEditor
- **Reference / Inspiration:** Unity Post Processing Stack v2, ReShade.
- **Use case:** Live testing and refining of post-processing filters applied globally to game screens.
- **Lurek API Integration:** Interfaces with `lurek.pipeline` and `lurek.effect` to apply visual overlays globally.
- **Ideas / Vision:** This editor is for designers tweaking global visual parameters (like bloom or blur intensity) over an existing game scene in `lurek.pipeline`, distinct from engineers writing raw compute shaders.
- **Feature list:**
  - Full-screen interactive game viewport preview.
  - Bloom threshold, intensity, and knee curve sliders.
  - Chromatic aberration shifting inputs.
  - CRT distortion, curvature, and scanline toggles.
  - Color grading LUT injection and interpolation.
  - Real-time performance profiling (GPU cost).
  - Preset saving, loading, and cross-fading.
  - Split-screen before/after comparison view.

### 18. SoundDspEditor
- **Reference / Inspiration:** Pure Data, FL Studio Patcher, Max/MSP.
- **Use case:** Creating Digital Signal Processing (DSP) chains for audio modification.
- **Lurek API Integration:** Configures processing chains directly within the `lurek.audio` namespace.
- **Ideas / Vision:** Distinct from the AudioMixer. While the mixer balances volumes, the DSP editor physically alters the sound waves (adding reverb, EQ, compression) using a node graph tied to `lurek.audio` effects.
- **Feature list:**
  - Node-based audio routing graph architecture.
  - Parametric EQ node configuration with graphical curves.
  - Reverb room size, delay, and damping control dials.
  - Compressor threshold, ratio, and attack/release dials.
  - Live visual audio spectrum analyzer.
  - Audio playback scrubbing and looping tools.
  - Channel muting, soloing, and bypass toggles.
  - Export functionality for saving DSP chains to JSON.

### 19. SpriteAnimEditor
- **Reference / Inspiration:** Spine 2D (basic timeline), Godot AnimationPlayer.
- **Use case:** Assembling motion clips from Sprite Sheet files by defining frames and animation states.
- **Lurek API Integration:** Relies on `lurek.animation` and `lurek.sprite` to define frame durations and states.
- **Ideas / Vision:** Bridges the gap between static PNG images and active game entities. By allowing developers to visually define frame durations, hitboxes, and hurtboxes per frame, it outputs data `lurek.animation` can instantly consume.
- **Feature list:**
  - Frame sequence horizontal timeline view.
  - Keyframe duration tweaking and easing adjustments.
  - Playback modes: Looping, Ping-pong, Once.
  - Hitbox and hurtbox rectangular drawing synchronized per frame.
  - Real-time animation playback preview at target framerates.
  - Onion skinning displaying adjacent animation frames.
  - Custom event triggers bound to specific frames (e.g., 'footstep').
  - Sprite sheet slicing grid generation.

### 20. TilesetEditor
- **Reference / Inspiration:** Tiled Tileset Editor, RPG Maker Tileset Manager.
- **Use case:** Preparing graphic sheets and marking individual tiles before actual usage in the TileMapEditor.
- **Lurek API Integration:** Prepares properties, bounds, and auto-tile rules used strictly by `lurek.tilemap`.
- **Ideas / Vision:** Strictly decoupled from map painting. This editor exists purely to define the "source material" for `lurek.tilemap`. By defining collision polygons and terrain tags here, the TileMapEditor can remain focused solely on painting grids.
- **Feature list:**
  - Grid dimension definition and offset spacing controls.
  - Solid and one-way collision polygon drawing per specific tile.
  - Terrain mask and bitmask rule configuration for auto-tiling logic.
  - Animation sequence linking for defining animated tiles (e.g., water).
  - Custom tag assignment (e.g. 'water_type', 'slippery_ice').
  - Precision zoom and pan tools for pixel-perfect slicing.
  - Bulk tile property editing via marquee selection.
  - Export to structured tileset JSON referencing the source image.

### 21. AudioMixerEditor
- **Reference / Inspiration:** FL Studio Mixer, Unity Audio Mixer.
- **Use case:** A classic virtual audio console to balance channel levels between BGM, SFX, and Master.
- **Lurek API Integration:** Configures global audio bus routing directly into `lurek.audio`.
- **Ideas / Vision:** Prevents developers from hardcoding volume calls throughout scripts. It establishes a Godot-like centralized audio routing system inside `lurek.audio`, where logic scripts merely play a sound, and the Mixer dictates its final output volume.
- **Feature list:**
  - Multi-track vertical fader interface (Master, BGM, SFX, UI).
  - Real-time volume peak metering in decibels (dB).
  - Mute and solo isolation toggles per audio bus.
  - Audio ducking and sidechain compression rules (e.g., lower BGM when Dialogue plays).
  - Panning and 2D spatialization balance settings.
  - Clipping indicators and redline warnings.
  - Snapshot saving for transitioning between different scene mixes.
  - Sub-mix grouping and auxiliary sends.

### 22. ColorPaletteEditor
- **Reference / Inspiration:** Lospec Palette Viewer, Adobe Color.
- **Use case:** Establishing a global system of predefined colors and gradients for cohesive aesthetics.
- **Lurek API Integration:** Defines color constants applied throughout `lurek.render` and `lurek.image`.
- **Ideas / Vision:** Enforces strict art direction. Instead of developers guessing hex codes, this editor ensures they reference semantic names mapped to `lurek.render`, allowing for one-click color blindness mode swaps.
- **Feature list:**
  - Hex, RGB, and HSL color picker wheels and sliders.
  - Semantic color swatch saving and naming (e.g. 'Enemy_Blood').
  - Mathematical gradient interpolation generator.
  - Color contrast and accessibility ratio checker.
  - Dynamic theme swapping configurations (Light Mode / Dark Mode).
  - Auto-generation of complementary, analogous, and triadic colors.
  - Export palettes to global Lua tables.
  - Import functionality from standard `.gpl` palette formats.

### 23. InputMapperEditor
- **Reference / Inspiration:** Steam Input Configuration, Godot Input Map.
- **Use case:** Designing unified input mappings bound to virtual actions rather than specific hardware keys.
- **Lurek API Integration:** Configures bindings mapped to `lurek.input` and its submodules (`lurek.input.keyboard`, `lurek.input.gamepad`).
- **Ideas / Vision:** Completely separates physical hardware from game logic. It ensures that a script checks if a virtual action was triggered in `lurek.input`, while the editor handles whether that action means the Spacebar, a Gamepad 'A' button, or a screen tap.
- **Feature list:**
  - Virtual action creation list (e.g. 'Jump', 'Shoot').
  - Keyboard, mouse, and gamepad hardware sniffing and binding.
  - Analog stick deadzone threshold curves and sensitivity sliders.
  - Axis mapping converting hardware input to Vector2 math.
  - Combo and chord definition (e.g., Shift + Space).
  - Input conflict and overlapping binding warnings.
  - Live input testing overlay visualizing controller states.
  - Export to standardized config TOML.

### 24. TimelineEditor
- **Reference / Inspiration:** Unity Timeline, Adobe Premiere sequence.
- **Use case:** Producing cutscenes, staged shots, and time-controlled cinematic sequences.
- **Lurek API Integration:** Operates closely with `lurek.automation` and `lurek.tween` to script sequences over time.
- **Ideas / Vision:** Uniquely solves the problem of coordinating multiple independent systems over time. It provides a visual track to align animations, sound effects, and camera pans perfectly using `lurek.automation`.
- **Feature list:**
  - Multi-track horizontal timeline (Animation Track, Audio Track, Event Track).
  - Keyframe insertion, deletion, and manipulation.
  - Easing curve editor providing Bezier, Linear, and Bounce interpolation.
  - Playhead scrubbing perfectly synchronized with the game viewport.
  - Audio waveform visualization overlaid on the timeline track.
  - Event trigger tracks executing Lua functions at specific milliseconds.
  - Sub-timeline nesting for modular cutscene architecture.
  - Real-time cinematic preview at target framerate.

### 25. ShaderPreviewEditor
- **Reference / Inspiration:** ShaderToy, The Book of Shaders Editor.
- **Use case:** Writing, testing, and visualizing raw compute and rendering shaders from scratch.
- **Lurek API Integration:** Compiles shaders tested directly against `lurek.compute` and `lurek.pipeline`.
- **Ideas / Vision:** A low-level graphics programming environment for raw `lurek.compute` shaders. It provides immediate visual feedback for math-heavy shader coding, mimicking tools like ShaderToy directly inside the IDE.
- **Feature list:**
  - Split-screen code editor paired with a live preview canvas.
  - Syntax highlighting for shader-specific languages (GLSL/WGSL).
  - Live compilation error reporting with line-number mapping.
  - Uniform variable injection exposing sliders and color pickers to the editor.
  - Time and resolution variable auto-mocking for testing animations.
  - Custom texture binding for previewing displacement maps.
  - Vertex and fragment shader separation tabs.
  - Performance metric overlay showing GPU instruction counts.

### 26. FontPreviewEditor
- **Reference / Inspiration:** BMFont, FontForge preview.
- **Use case:** Inspecting how vector fonts (TTF) or bitmap fonts render under scaling.
- **Lurek API Integration:** Generates font atlas data used by `lurek.render` and UI text rendered by `lurek.html`.
- **Ideas / Vision:** Ensures text rendering is performant and visually crisp in `lurek.render`. By previewing exactly how Lurek's rasterizer will pack the glyphs into a texture atlas, developers can tweak kerning visually before committing to UI layouts.
- **Feature list:**
  - Custom sample text input testing rendering.
  - Real-time font size and scaling interpolation preview.
  - Kerning and line-height numeric nudging.
  - Font atlas texture packing visualization.
  - Hinting and anti-aliasing rendering toggles.
  - Missing glyph highlighting and fallback font configuration.
  - Export configuration to Lua/JSON rendering profiles.
  - Memory usage estimation based on atlas size.

### 27. LocalizationEditor
- **Reference / Inspiration:** POEditor, Crowdin.
- **Use case:** Organizing multi-language translated text strings used across the game.
- **Lurek API Integration:** Outputs structured `.locale.json` dictionaries consumed seamlessly by `lurek.i18n`.
- **Ideas / Vision:** Completely separates hardcoded strings from logic. It provides a dedicated matrix specifically tailored for translators, ensuring the game is internationalization-ready through `lurek.i18n` from day one.
- **Feature list:**
  - Side-by-side multi-language column view grid.
  - Missing translation warnings and progress percentage trackers.
  - Regex search and filtering by localization key or text content.
  - Pluralization and variable interpolation syntax support (e.g. "{count} apples").
  - Export/Import to JSON/CSV for external localization agencies.
  - Integration with machine translation APIs (optional capability).
  - Context note attachments guiding translators on meaning.
  - Duplicate key detection and strict validation.

### 28. PhysicsMaterialsEditor
- **Reference / Inspiration:** Unity Physics Material 2D, Godot PhysicsMaterial.
- **Use case:** Managing physical parameters (friction, bounce) for environmental substances.
- **Lurek API Integration:** Configures physical material presets natively applied in `lurek.physics`.
- **Ideas / Vision:** Separates physical collision logic from individual objects. Rather than an entity defining its own friction, it assigns itself an "Ice" material defined here, ensuring consistent `lurek.physics` behavior across the world.
- **Feature list:**
  - Density and mass configuration baseline sliders.
  - Friction coefficient settings (static and dynamic separation).
  - Restitution (bounciness) tuning and energy retention.
  - Preset templates creation (e.g. Ice, Rubber, Metal).
  - Visual bounce simulation sandbox.
  - Layer collision matrix configuration (defining who collides with whom).
  - Export material constants to global Lua tables.
  - Continuous vs Discrete collision detection toggles.

### 29. WorldMapEditor
- **Reference / Inspiration:** Super Mario World Map Editor (Lunar Magic), CK3 Point Map.
- **Use case:** Mapping macro-geographical overworld navigation structures (e.g., node-based travel).
- **Lurek API Integration:** Exports topological graphing data natively parsed by `lurek.pathfind` and `lurek.graph`.
- **Ideas / Vision:** Distinct from the TileMapEditor. This editor focuses on high-level topological graphs for travel logic analyzed by `lurek.pathfind`, rather than pixel-perfect, local-level collision mapping.
- **Feature list:**
  - Node placement for points of interest across the overworld.
  - Spline path linking with automatic distance calculation.
  - Region boundary drawing.
  - Encounter and danger zone definitions overlay.
  - Fast travel point tagging and unlock condition bindings.
  - Visual weather zone mapping and ambient sound linking.
  - Custom icon assignment per individual node.
  - Export graph structure to JSON pathfinding logic.

### 30. ProvinceEditor
- **Reference / Inspiration:** Hearts of Iron IV Nudge Tool, Europa Universalis IV Mapper.
- **Use case:** Designing territorial map divisions for macro-management or grand-strategy games.
- **Lurek API Integration:** Generates regional metadata seamlessly queried by `lurek.province`.
- **Ideas / Vision:** Distinct from the WorldMapEditor. Instead of points connected by lines, this uses polygon-based territory claiming integrated directly with the `lurek.province` system to handle wealth and population data visually.
- **Feature list:**
  - Polygon border drawing tools and vertex snapping.
  - Territory ownership color mapping.
  - Resource and demographic metadata inputs (Population, Wealth).
  - Automatic neighbor adjacency and border length calculation.
  - Heatmap visualization toggles (e.g. viewing wealth distribution).
  - Quick-select and bulk edit lasso tools.
  - Export map data to indexed arrays for strategy calculation.
  - Sea versus Land province boolean toggles.

### 31. GlobeEditor
- **Reference / Inspiration:** Google Earth Engine, Kerbal Space Program MapView.
- **Use case:** Topography editing and viewing for environments depicting game worlds directly on a convex sphere.
- **Lurek API Integration:** Fully integrated with `lurek.globe`, outputting spherical coordinates for mapping and projection.
- **Ideas / Vision:** A completely unique topological mapping tool. Since 2D flat maps fail at representing planetary scales, this editor provides genuine spherical coordinate systems (Lat/Lon) tailored exactly for the specialized `lurek.globe` API.
- **Feature list:**
  - 3D interactive convex sphere viewport preview.
  - Precise latitude and longitude coordinate plotting tools.
  - Equirectangular texture projection wrapping and preview.
  - Camera rotation and altitude zoom controls.
  - Waypoint placement mapped directly onto the sphere surface.
  - Day/Night cycle terminator line simulation.
  - Export coordinates directly to Lua vector representations.
  - Pole distortion severity warning visualization.

### 32. NavMeshEditor
- **Reference / Inspiration:** Godot NavigationPolygon, Unity NavMesh (2D adapted).
- **Use case:** Drawing walkable and obstacle polygons for free-form 2D navigation.
- **Lurek API Integration:** Generates polygon arrays consumed natively by `lurek.pathfind` for A* routing.
- **Ideas / Vision:** Essential for point-and-click or aRPG games where agents navigate off-grid. Completely distinct from TileMap or WorldMap; this provides actual vector-based movement areas.
- **Feature list:**
  - Polygon drawing and vertex snapping tools over the game map.
  - Subtraction tools for cutting holes (obstacles) in walkable areas.
  - Bake configuration for agent radius offsets.
  - Multi-layer navigation linking (e.g. ground vs water).
  - Visualization overlay of the final baked navigation mesh.
  - Dynamic obstacle insertion rules.
  - Cost modifiers assigned to specific polygons (e.g. swamp is slower).
  - Export to optimized 2D vertex arrays for fast pathfinding.

### 33. SkeletonRiggingEditor
- **Reference / Inspiration:** Spine 2D, Godot 2D Skeleton/Polygon2D.
- **Use case:** Rigging 2D sprites with bones for procedural deformation animation.
- **Lurek API Integration:** Integrates directly with `lurek.spine` to manage skeletal hierarchy.
- **Ideas / Vision:** Avoids reliance on external software (Spine) for basic 2D rigging. Allows creating fluid boss animations using vertex weights and Inverse Kinematics (IK) instead of drawing 50 individual sprite frames.
- **Feature list:**
  - Bone placement and hierarchical parent/child linking.
  - Inverse Kinematics (IK) chain creation for limbs.
  - Polygon mesh generation over 2D sprites.
  - Vertex weight painting assigned to specific bones.
  - Animation timeline for keyframing bone rotations and IK targets.
  - Skin switching (swapping texture while keeping the rig).
  - Real-time physics ragdoll testing sandbox.
  - Export to `lurek.spine` native data format.

### 34. VisualShaderEditor
- **Reference / Inspiration:** Godot VisualShader, Unity Shader Graph.
- **Use case:** Creating fragment, vertex, and compute shaders via a visual node interface.
- **Lurek API Integration:** Translates node logic into raw code for `lurek.compute` and `lurek.pipeline`.
- **Ideas / Vision:** Enables technical artists to build complex visual effects (like flowing water or dissolve transitions) without writing mathematical GLSL code.
- **Feature list:**
  - Infinite node canvas with math, texture, and logic blocks.
  - Real-time preview sphere/sprite updating with every connection.
  - Automatic conversion of nodes to optimized shader code.
  - Uniform variable exposure for the main properties inspector.
  - Sub-graph creation for reusable shader functions.
  - Built-in time and screen-UV coordinate nodes.
  - Vertex displacement logic implementation.
  - Compute shader dispatch node configuration.

### 35. LightingEnvironmentEditor
- **Reference / Inspiration:** Godot WorldEnvironment, 2D Lights & Shadows.
- **Use case:** Configuring global ambient lighting, 2D shadows, and Global Illumination (GI).
- **Lurek API Integration:** Direct configuration of the `lurek.light` system.
- **Ideas / Vision:** Elevates the 2D aesthetic by adding dynamic shadows and ambient occlusion. It shifts Lurek2D from flat pixel art to a modern 2D lit environment.
- **Feature list:**
  - Ambient light color and energy scaling.
  - 2D Point Light and Directional Light placement.
  - Shadow caster polygon drawing tools.
  - 2D Global Illumination (GI) bounce intensity tuning.
  - Normal map visualization for 2D sprites.
  - Signed Distance Field (SDF) baking configuration.
  - Light culling mask layer assignments.
  - Volumetric fog/haze density sliders.

### 36. GuiThemeEditor
- **Reference / Inspiration:** Godot Theme Editor.
- **Use case:** Establishing global CSS styling constants for all UI widgets.
- **Lurek API Integration:** Generates global CSS stylesheets injected into `lurek.html`.
- **Ideas / Vision:** Separates UI layout (GuiWidgetEditor) from UI styling. Ensures that changing the "Button" color updates across the entire game immediately, preventing hardcoded styles.
- **Feature list:**
  - Component-specific styling (Buttons, Sliders, TextBoxes).
  - State configuration (Normal, Hover, Pressed, Disabled).
  - Border radius, box-shadow, and stroke editing.
  - Nine-patch scale configuration for UI panels.
  - Custom font assignment and baseline shifting.
  - CSS variable generation and overriding.
  - Live preview across a sample "UI Gallery".
  - Theme exporting to global `.css` files.

### 37. NetworkTopologyEditor
- **Reference / Inspiration:** Godot MultiplayerSynchronizer/Spawner, Photon PUN.
- **Use case:** Defining multiplayer authority, synchronization targets, and RPCs.
- **Lurek API Integration:** Configures data packet rules for `lurek.network`.
- **Ideas / Vision:** Makes netcode visual. Instead of coding serialization by hand, developers define which entity variables are synchronized over the network and who owns them (Server vs Client).
- **Feature list:**
  - Variable synchronization tagging (Position, Health, State).
  - RPC (Remote Procedure Call) registration and permissions.
  - Authority delegation (Server authoritative vs Client prediction).
  - Network interpolation and extrapolation smoothing settings.
  - Entity spawning/despawning replication rules.
  - Bandwidth consumption estimator based on sync rate.
  - Simulated latency and packet-loss testing environment.
  - Export to optimized network manifest configurations.

### 38. GlobalAutoloadEditor
- **Reference / Inspiration:** Godot Autoloads / Project Settings.
- **Use case:** Managing persistent global singletons and services that survive scene loads.
- **Lurek API Integration:** Registers modules via `lurek.system` and `lurek.scene`.
- **Ideas / Vision:** Solves the problem of "where do I put the player's inventory across levels?". Provides a clean registry for persistent Lua scripts.
- **Feature list:**
  - Singleton script registration table.
  - Load order prioritization (who boots first).
  - Scene-agnostic persistent data viewing.
  - Hot-reloading toggles for specific singletons.
  - Dependency injection mapping.
  - Boot initialization timing (Pre-engine vs Post-engine ready).
  - Export to core boot configuration files.
  - Isolation sandbox configuration for secure modules.

### 39. AssetManifestEditor
- **Reference / Inspiration:** Godot ResourcePreloader, Unity Addressables.
- **Use case:** Grouping and managing asynchronous asset loading packages.
- **Lurek API Integration:** Configures preload groups for `lurek.filesystem`.
- **Ideas / Vision:** Prevents mid-game stutter by explicitly defining what needs to be in RAM for Level 1 vs Level 2. Essential for memory management on lower-end devices.
- **Feature list:**
  - Grouping assets into named "Loading Buckets".
  - RAM consumption estimation per bucket.
  - Priority queuing for asynchronous background loading.
  - Missing asset dependency detection.
  - Unused asset highlighting and purging.
  - Automatic packing into encrypted `.pak` files.
  - Live VRAM memory visualization per group.
  - Loading screen progress bar integration hooks.

### 40. PerformanceProfilerEditor
- **Reference / Inspiration:** Godot Debugger Monitors, Unity Profiler.
- **Use case:** Visualizing real-time game performance and bottlenecks.
- **Lurek API Integration:** Hooks directly into telemetry from `lurek.devtools` and `lurek.debugbridge`.
- **Ideas / Vision:** The command center for optimization. Ensures 2D games run at a locked 60FPS by exposing Lua GC pauses and draw-call spikes.
- **Feature list:**
  - Real-time frame-time line graphs (CPU vs GPU).
  - Lua Garbage Collection pause monitoring.
  - VRAM and RAM consumption tracking.
  - Draw call and batch count tracking.
  - Heavy function execution time highlighting (Flame graphs).
  - Physics step simulation timing.
  - Remote profiling of built executables over network.
  - Snapshot saving for performance regression comparison.

### 41. ProjectExportEditor
- **Reference / Inspiration:** Godot Export Profiles, Unity Build Settings.
- **Use case:** Configuring platform-specific build settings and compiling the game.
- **Lurek API Integration:** Interfaces with `lurek.engine` and `lurek.system` compilation flags.
- **Ideas / Vision:** The final step. Replaces writing manual Cargo build scripts with a visual UI to set app icons, window sizing, and platform targeting.
- **Feature list:**
  - Target platform selection (Windows, Linux, macOS).
  - Application icon assignment per platform resolution.
  - Window configuration (Resizable, Borderless, Fullscreen, V-Sync).
  - Feature flag toggles (e.g., Disable Console in Release build).
  - Security and permission configurations.
  - File exclusion filters (e.g., ignore `.psd` files on build).
  - Archive encryption setting configuration.
  - One-click build triggering and progress monitoring.
