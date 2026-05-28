//! Grid-based and graph-based pathfinding algorithms (A*, bidirectional, JPS, HPA*).
//!
//! - Sub-modules: `ai_flow_field`, `astar`, `async_pool`, `bidir`, and 15 more.

/// AI-oriented flow field with steering integration.
pub mod ai_flow_field;
/// Core A* search, line-of-sight checks, and path smoothing.
pub mod astar;
/// Thread pool for dispatching pathfinding requests off the main thread.
pub mod async_pool;
/// Bidirectional A* search meeting in the middle.
pub mod bidir;
/// Dijkstra-based flow field for multi-target distance maps.
pub mod flow_field;
/// Province-level graph pathfinding and reachability.
pub mod graph_path;
/// Generic 2D grid abstraction for pathfinding algorithms.
pub mod grid;
/// Hierarchical Pathfinding A* (HPA*) with abstract graph construction.
pub mod hpa;
/// Influence map for spatial scoring and tactical queries.
pub mod influence_map;
/// Navigation grid with configurable diagonal movement modes.
pub mod nav_grid;
/// Triangle-based navigation mesh for free-form 2D areas.
pub mod navmesh;
/// Cell-based path grid with obstacle and cost marking.
pub mod pathgrid;
/// Debug and visualization rendering for pathfinding structures.
pub mod render;
/// Per-unit pathfinder with waypoint queue and replanning.
pub mod unit_pathfinder;
pub use ai_flow_field::FlowField as SimpleFlowField;
pub use astar::{astar, line_of_sight, smooth_path};
pub use async_pool::PathThreadPool;
pub use bidir::bidirectional_astar;
pub use flow_field::FlowField;
pub use graph_path::{find_province_path, province_reachable, ProvinceCostFn, ProvincePath};
pub use grid::Grid;
pub use hpa::{build_abstract, is_reachable as hpa_is_reachable, AbstractGraph};
pub use influence_map::InfluenceMap;
pub use nav_grid::{DiagonalMode, NavGrid};
pub use navmesh::NavMesh;
pub use pathgrid::{Cell, PathGrid};
pub use unit_pathfinder::{UnitPathfinder, Waypoint};
#[cfg(feature = "flownet")]
/// Graph-based A* and range queries on abstract node networks.
pub mod graph_nav;
/// Hexagonal grid with axial coordinates and layout conversion.
pub mod hex_grid;
/// Isometric grid for 2D-projected tile maps.
pub mod iso_grid;
/// Jump Point Search on uniform-cost grids.
pub mod jps;
/// Range map for distance-bounded area queries.
pub mod range_map;
#[cfg(feature = "flownet")]
pub use graph_nav::{graph_astar, graph_range};
pub use hex_grid::{HexGrid, HexLayout};
pub use iso_grid::IsoGrid;
pub use jps::JpsGrid;
pub use range_map::RangeMap;
