//! Exports the tilemap subsystem surface that combines storage, import, geometry, and render helpers.
//! Acts as the ownership index for tile worlds so callers can see where chunks, attached tilesets, maps, and importers live.
//! Centralizes module visibility and re-exports instead of storing live map data or running generation itself.
//! Connects authored formats, autotiling, large-map helpers, and base tile storage into one stack.
//! Provides the first navigation point when tracing whether a tile concern belongs to import, storage, or rendering.
//! Keeps the public tilemap surface coherent while allowing specialized owners like isomap or TMX to stay narrow.
//! Open this file first when adding a tilemap owner or changing re-export policy for shared tilemap APIs.
//! Use it to map a tile feature to its concrete Rust owner before editing storage, import, or render behavior.

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
/// Re-export core tilemap types.
pub use tilemap::{TileIndexPolicy, TileLayer, TileMap, TileMapDiagnosticsSnapshot};
/// Re-export TMX import types and loader function.
pub use tmx::{
    load_tmx, load_tmx_with_options, TmxLayer, TmxLoadOptions, TmxMap, TmxObject, TmxObjectLayer,
    TmxOrientation, TmxTileLayer, TmxTileset,
};
