//! High-level mapblock module that wires blocks, scripts, constraints, and output conversion together. `mapblock/mod` is the mapblock module index, declaring `block`, `config`, `constraints`, `generator`, `group`, and 8 more so agents can identify which files own each feature slice before opening implementation code.
//! Exposes the procedural assembly surface used to build tilemaps from authored content. `src/mapblock/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `block::{Edge, MapBlock}`, `config::MapBlockConfig`, `constraints::{EdgeConstraint, NeighborRules}`, `generator::MapBlockGenerator`, and 9 more centralized for the mapblock subsystem.
//! Keeps layered generation, orientation handling, and placement validation under one namespace. The file documents how mapblock submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.
//! `mapblock/mod` is the mapblock module index, declaring `block`, `config`, `constraints`, `generator`, `group`, and 8 more so agents can identify which files own each feature slice before opening implementation code.
//! `src/mapblock/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `block::{Edge, MapBlock}`, `config::MapBlockConfig`, `constraints::{EdgeConstraint, NeighborRules}`, `generator::MapBlockGenerator`, and 9 more centralized for the mapblock subsystem.
//! The file documents how mapblock submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.

/// Map block definition: tile slots, metadata, and per-block configuration.
pub mod block;
/// Map block generator configuration and global assembly settings.
pub mod config;
/// Carcassonne-style edge constraints for neighbor block matching rules.
pub mod constraints;
/// Scripted procedural map assembler that executes placement step sequences.
pub mod generator;
/// Named block groups for random weighted selection and themed zone filling.
pub mod group;
/// Z-layer management for multi-storey and multi-level map construction.
pub mod layer;
/// Map tile and slot definitions: floor, roof, object, wall, and custom slots.
pub mod maptile;
/// Multi-level (Z-layer) map data structure with per-level accessors.
pub mod multilevel;
/// Map orientation modes: TopDown and Isometric projection support.
pub mod orientation;
/// Output converter transforming assembled map block results into TileMap.
pub mod output;
/// Block placement grid, valid-position search, and placed-block tracking.
pub mod placement;
/// Script steps that drive procedural map block generation sequences.
pub mod script;
/// Tileset reference linking block slots to tile ID ranges in a tileset.
pub mod tileset_ref;

pub use block::{Edge, MapBlock};
pub use config::MapBlockConfig;
pub use constraints::{EdgeConstraint, NeighborRules};
pub use generator::MapBlockGenerator;
pub use group::MapGroup;
pub use layer::BlockLayer;
pub use maptile::{MapTile, TileSlot};
pub use multilevel::{LevelData, MultiLevelMap};
pub use orientation::MapOrientation;
pub use output::{MapBlockResult, PlacementRecord};
pub use placement::{PlacedBlock, PlacementGrid};
pub use script::{MapScript, ScriptStep, StepType};
pub use tileset_ref::TilesetRef;
