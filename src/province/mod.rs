//! Province-based map system for strategy games.
//!
//! Provides province data from colour-coded PNG maps, adjacency detection,
//! map modes, fog of war, pathfinding, and random world generation.
//!
//! All game-specific data (terrain, owner, region, etc.) is managed via the
//! generic [`ProvinceProperties`] system — the province struct itself holds
//! only spatial data.

/// Core province data structures: Province, AdjacencyEdge, ProvinceMap.
pub mod core;
/// Province map loader: PNG parsing and province extraction.
pub mod loader;
/// Adjacency detection between provinces from the pixel grid.
pub mod adjacency;
/// Auto-position calculation for primary positions, labels, and object slots.
pub mod positions;
/// Map mode system for different colour schemes.
pub mod map_mode;
/// Border segment extraction for province rendering.
pub mod borders;
/// Fog of war per province.
pub mod fog;
/// Province-based minimap generation.
pub mod minimap;
/// Province-level pathfinding on the adjacency graph.
pub mod pathfinding;
/// Unit movement along province paths.
pub mod movement;
/// Generic province properties and state system.
pub mod properties;
/// Province improvements and movable map objects.
pub mod objects;
/// Random world generation using Voronoi tessellation.
pub mod worldgen;
/// Generic organization system: physical and virtual entities that control provinces.
pub mod organization;
/// Configurable relation system between organizations (numeric value + named states).
pub mod relations;
/// Province event bus for lifecycle events (property changed, org assigned, turn, tick).
pub mod events;

pub use core::{AdjacencyEdge, Province, ProvinceError, ProvinceMap};
pub use fog::{FogOfWar, FogState};
pub use map_mode::{MapMode, MapModeColorFn};
pub use borders::{BorderSegment, BorderStyle};
pub use pathfinding::{ProvinceCostFn, ProvincePath};
pub use movement::{MovementManager, MovingUnit};
pub use properties::{ProvinceData, ProvinceProperties, ProvinceState, ProvinceValue};
pub use objects::{Improvement, MapObject, ObjectManager};
pub use minimap::ProvinceMinimap;
pub use worldgen::WorldGenConfig;
pub use organization::{Organization, OrganizationManager};
pub use relations::{Relation, RelationManager, RelationType};
pub use events::ProvinceEventBus;
