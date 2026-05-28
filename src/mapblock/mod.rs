//! Map-block procedural assembly system.
//!
//! - Builds tile maps from composable blocks using scripted placement.
//! - Supports configurable tile slots (floor, roof, object, walls, custom).
//! - Carcassonne-style neighbor edge matching for placement constraints.
//! - Multi-level (Z-layers) for multi-storey maps.
//! - TopDown and Isometric orientations (no hex).
//! - Arbitrary map shapes (not limited to rectangles).
//! - Output converts to standard `TileMap` for rendering.

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

pub use block::MapBlock;
pub use config::MapBlockConfig;
pub use constraints::{EdgeConstraint, NeighborRules};
pub use generator::MapBlockGenerator;
pub use group::MapGroup;
pub use layer::BlockLayer;
pub use maptile::{MapTile, TileSlot};
pub use multilevel::{LevelData, MultiLevelMap};
pub use orientation::MapOrientation;
pub use output::MapBlockResult;
pub use placement::{PlacedBlock, PlacementGrid};
pub use script::{MapScript, ScriptStep, StepType};
pub use tileset_ref::TilesetRef;
