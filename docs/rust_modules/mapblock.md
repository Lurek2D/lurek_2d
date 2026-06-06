# mapblock

## General Info

- Module group: `Edge/Integration`
- Source path: `src/mapblock/`
- Binding: `src/lua_api/mapblock_api.rs`
- Namespace: `lurek.mapblock`
- Lua API surface: `10` functions, `9` types, `53` methods
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

This module provides the procedural map block assembly and generation subsystem, enabling developers to build large tilemaps from pre-configured block layouts. It manages individual map blocks that bundle tile grids, edge connectors, and weighted metadata. Adjacency constraints use socket-style interfaces, defining how blocks link to their neighbors. This allows the generator to validate boundary compatibilities during runtime procedurally.

The generation engine is controlled by scripted procedural steps, driving layout passes through fill, targeted, and random placement operations. The generator evaluates candidates using neighbor rules, resolving conflicts dynamically to maintain structural consistency. Multiple vertical storeys are supported, allowing developers to generate multi-level buildings and layered biomes under unified grid seeds.

Placement grids handle spatial validation and keep track of cell occupancies. These coordinate fields support top-down and isometric orientations, tailoring block placements to the game's presentation style. When placement finishes, the output converter translates layered slot layouts into concrete tile layer arrays and resolves tileset IDs. This decouples procedural generation logic from final map rendering systems.

## Files

### [block.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/mapblock/block.rs)

- Fundamental mapblock unit combining tile payloads, edge sockets, and metadata.
- Carries the data needed to match blocks during procedural placement.
- Stores selection weighting, naming, and tileset references for later output.
- Encodes the local shape and slot content that downstream stages consume.
- Keeps neighbor semantics alongside the block so validation stays data-driven.
- Acts as the atomic building piece for the entire mapblock pipeline.

### [config.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/mapblock/config.rs)

- Runtime configuration for mapblock generation shape, slots, and randomness.
- Holds grid dimensions, layer limits, and placement behavior flags.
- Stores seed and retry controls for deterministic or exploratory runs.
- Defines the slot schema that orders per-tile payload interpretation.
- Serves as the canonical loaded settings object for assembly routines.

### [constraints.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/mapblock/constraints.rs)

- Edge compatibility rules that decide whether neighboring blocks can connect.
- Describes socket-style match data per edge for fine-grained placement checks.
- Provides opposite-edge helpers for two-sided adjacency validation.
- Keeps connection semantics data-driven instead of hard-coded.
- Powers fast local legality checks during generator execution.

### [generator.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/mapblock/generator.rs)

- Operational core for scripted mapblock assembly over a block grid.
- Owns block registries, multi-level placement state, and RNG progression.
- Executes fill, targeted placement, random placement, and repeat steps.
- Applies neighbor constraints to keep layouts structurally coherent.
- Threads orientation and config context through the build process.
- Converts intermediate placements into renderer-ready output structures.
- Supports deterministic runs through seeded randomness and explicit step ordering.
- Serves as the main execution engine behind mapblock authoring tools.

### [group.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/mapblock/group.rs)

- Named block group for themed procedural generation passes.
- Carries weighted selection metadata for controlled randomness.
- Lets scripts reference semantic groups instead of numeric ids.
- Supports biome-style or region-style content curation.

### [layer.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/mapblock/layer.rs)

- Per-level tile storage for multi-storey mapblock outputs.
- Manages independent 2D block layers indexed by non-negative vertical levels.
- Provides bounds-aware tile access and mutation for placement operations.
- Keeps slot counts and layer dimensions aligned with global config.
- Supplies the layered container used by multilevel map assembly.

### [maptile.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/mapblock/maptile.rs)

- Atomic tile payload composed from configurable slot values and metadata.
- Encodes tile-slot identifiers that point at tileset entries for rendering and logic.
- Distinguishes slot roles so ordered drawing stays consistent.
- Serves as the smallest content unit stored inside mapblock grids.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/mapblock/mod.rs)

- High-level mapblock module that wires blocks, scripts, constraints, and output conversion together.
- Exposes the procedural assembly surface used to build tilemaps from authored content.
- Keeps layered generation, orientation handling, and placement validation under one namespace.

### [multilevel.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/mapblock/multilevel.rs)

- Multilevel container for placed blocks across vertical storeys.
- Tracks level metadata and block placements with bounds-safe access patterns.
- Supports mutation and query by level and grid coordinate during generation.
- Preserves structure needed for serialization and output transformation.
- Bridges layered placement logic with final map export.

### [orientation.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/mapblock/orientation.rs)

- Orientation modes for interpreting generated mapblock layouts.
- Provides top-down and isometric variants for different presentation styles.
- Supplies parsing and helpers used by config-driven renderer integration.

### [output.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/mapblock/output.rs)

- Final mapblock conversion layer that turns placements into tile data outputs.
- Translates layered slot payloads into ordered tile layers and resolved tileset ids.
- Applies orientation and level handling so exports match runtime presentation.
- Produces owned result structures detached from mutable generator state.
- Serves as the last step in the mapblock build pipeline.

### [placement.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/mapblock/placement.rs)

- Placement-grid state and legality checks for mapblock assembly operations.
- Tracks occupied cells and placed-block metadata used by scripted steps.
- Evaluates candidates against edge constraints and neighborhood compatibility rules.
- Enumerates valid placements for deterministic or random selection passes.
- Records coordinates and orientation details for downstream processing.
- Acts as the spatial validation core inside the generator loop.

### [script.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/mapblock/script.rs)

- Scripted step language that drives procedural mapblock generation flow.
- Encodes fill, targeted placement, random placement, and repeat operations.
- Stores ordered step sequences consumed directly by the execution engine.
- Supports data-driven authoring and runtime construction of generation programs.
- Provides the control plane for deterministic and expressive map assembly.

### [tileset_ref.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/mapblock/tileset_ref.rs)

- Tileset reference metadata used to resolve slot values into concrete tile resources.
- Stores tileset identity, sizing, and index-offset data shared across blocks.
- Supports reuse of one tileset with different offset conventions per content group.
- Serves as lookup glue between authored blocks and runtime tilemap output.
