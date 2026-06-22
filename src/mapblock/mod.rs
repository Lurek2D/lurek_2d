//! Indexes the mapblock subsystem and keeps exported submodules discoverable from one crate entry.
//! Keeps mapblock data ownership and helper behavior clear for future engine maintenance. for engine changes.
//! Separates navigation and module wiring from implementation so feature files own behavior directly.
//! Owns mapblock behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps crate callers pointed at stable mapblock entrypoints while internals stay organized.
//! Documents where mapblock callers should change defaults, errors, or lifecycle behavior. for engine changes.
//! Indexes the mapblock subsystem and keeps exported submodules discoverable from one crate entry.
//! Keeps mapblock data ownership and helper behavior clear for future engine maintenance. for engine changes.

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

pub use block::{Edge, MapBlock, MapBlockError, MapBlockLimits};
pub use config::MapBlockConfig;
pub use constraints::{EdgeConstraint, NeighborRules};
pub use generator::{
    MapBlockDiagnostics, MapBlockGenerator, MapBlockReport, SolveFailureReason, SolverBudget,
};
pub use group::MapGroup;
pub use layer::BlockLayer;
pub use maptile::{MapTile, TileSlot};
pub use multilevel::{LevelData, MultiLevelMap};
pub use orientation::MapOrientation;
pub use output::{MapBlockResult, PlacementRecord};
pub use placement::{
    PlacedBlock, PlacementGrid, PlacementGridValidationError, PlacementTransformCache,
};
pub use script::{MapScript, ScriptStep, StepType};
pub use tileset_ref::TilesetRef;
