//! This module index owns the public shape of the tilemap subsystem and its source navigation map.
//! It declares which sibling files participate in tilemap behavior and which names are reexported outward.
//! Reexports here are intentionally narrow so callers do not depend on private implementation modules.
//! Agents should start here to understand subsystem boundaries before opening deeper implementation files.
//! New submodules belong here only when they add durable behavior rather than temporary test scaffolding.
//! Keep this index synchronized with specs, examples, and Lua bindings whenever public ownership changes.
//! The ordering groups core data, helpers, and rendering-facing pieces so code search stays predictable.
//! This file should explain where to navigate next, not repeat details owned by the implementation files.

/// Autotile sprite-sheet layout and rule matching.
pub mod autotile_sheet;
/// Chunk-based storage for very large tile grids.
pub mod chunk;
/// Tile-space coordinate conversion helpers.
pub mod coords;
/// Shared tilemap validation and resource-limit errors.
pub mod error;
/// Isometric tile maps with layered `IsoTile` items.
pub mod isomap;
/// Large-map chunked renderer suitable for maps exceeding GPU texture limits.
pub mod large_map_renderer;
/// LDtk JSON level format import.
pub mod ldtk;
/// Shared tilemap limits and checked arithmetic helpers.
pub mod limits;
/// Tilemap projection orientation.
pub mod orientation;
/// Render helpers converting tilemap data to `RenderCommand` sequences.
pub mod render;
/// Format-neutral bounded Tiled object-map import used by geometry-owning modules.
pub mod tiled;
/// Core `TileMap` and `TileLayer` types.
#[allow(clippy::module_inception)]
pub mod tilemap;
/// Tilemap reverse-index cache helpers extracted from `tilemap.rs`.
pub mod tilemap_index;
/// Tiled TMX XML format import. This module is publicly re-exported.
pub mod tmx;

/// Re-export autotile layout and sheet types for callers.
pub use autotile_sheet::{AutoTileLayout, AutoTileSheet};
/// Re-export chunk map type for callers.
pub use chunk::ChunkMap;
/// Re-export all coordinate helpers as a flat namespace.
pub use coords::*;
/// Re-export shared tilemap error type.
pub use error::TileMapError;
/// Re-export isometric map types for callers.
pub use isomap::{IsoDrawItem, IsoLevel, IsoMap, IsoTile, IsoTilePart};
/// Re-export large-map renderer types.
pub use large_map_renderer::{LargeMapRenderer, MapChunk};
/// Re-export the LDtk level loader function.
pub use ldtk::{load_ldtk, load_ldtk_with_limits};
/// Re-export shared tilemap limits.
pub use limits::TileMapLimits;
/// Re-export tilemap orientation used by storage and render adapters.
pub use orientation::MapOrientation;
/// Re-export normalized Tiled object-map import types.
pub use tiled::{
    load_tiled, load_tiled_json, load_tiled_tmx, TiledImportError, TiledMap, TiledObject,
    TiledObjectLayer, TiledObjectShape, TiledPoint, TiledPropertyValue,
};
/// Re-export core tilemap types.
pub use tilemap::{TileIndexPolicy, TileLayer, TileMap, TileMapDiagnosticsSnapshot};
/// Re-export TMX import types and loader function.
pub use tmx::{
    load_tmx, load_tmx_with_options, TmxLayer, TmxLoadOptions, TmxMap, TmxObject, TmxObjectLayer,
    TmxOrientation, TmxTileLayer, TmxTileset,
};
