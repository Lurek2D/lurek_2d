//! Exports the pathfinding surface for routing, spatial fields, steering, local avoidance, and debug views.
//! Acts as the navigation index for A*, HPA, flow fields, influence maps, ORCA, and province graphs.
//! Keeps boundaries explicit so callers can locate data, search, movement, validation, or debug ownership.
//! Re-exports grid, hex, iso, navmesh, steering, tactical, and graph helpers without storing live state.
//! This index owns visibility contracts, not queues, caches, solver internals, or renderer submission data.
//! Start here when tracing navigation behavior because it reveals the authoritative file split by feature.
//! Neighboring changes usually span `NavGrid`, async requests, solvers, steering helpers, and debug adapters.
//! Update this file when adding, retiring, or renaming pathfinding owners or public re-export policy.

/// AI-oriented flow field with steering integration.
pub mod ai_flow_field;
/// Core A* search, line-of-sight checks, and path smoothing.
pub mod astar;
/// Thread pool for dispatching pathfinding requests off the main thread.
pub mod async_pool;
/// Bidirectional A* search meeting in the middle.
pub mod bidir;
/// Slot-based context steering for local movement direction selection.
pub mod context_steering;
/// Dijkstra-based flow field for multi-target distance maps.
pub mod flow_field;
/// Multi-source Dijkstra distance field for goal-oriented AI movement.
pub mod goal_map;
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
/// ORCA-style reciprocal local collision avoidance.
pub mod orca;
/// Cell-based path grid with obstacle and cost marking.
pub mod pathgrid;
/// Debug and visualization rendering for pathfinding structures.
pub mod render;
/// Steering behaviors, path following, flocking, and named-entity pursuit/evade helpers.
pub mod steering;
/// Per-unit pathfinder with waypoint queue and replanning.
pub mod unit_pathfinder;
/// Shared validation limits for pathfinding movement helpers.
pub mod validation;
pub use ai_flow_field::FlowField as SimpleFlowField;
pub use astar::{astar, smooth_path};
pub use async_pool::{AsyncPathEvent, AsyncPathRequest, PathEventStatus, PathThreadPool};
pub use bidir::bidirectional_astar;
pub use context_steering::{ContextBehavior, ContextBehaviorKind, ContextSteering};
pub use flow_field::FlowField;
pub use goal_map::{GoalMap, GoalSource, UNREACHABLE};
pub use graph_path::{find_province_path, province_reachable, ProvinceCostFn, ProvincePath};
pub use grid::Grid;
pub use hpa::{build_abstract, is_reachable as hpa_is_reachable, AbstractGraph};
pub use influence_map::InfluenceMap;
pub use nav_grid::{DiagonalMode, NavGrid};
pub use navmesh::NavMesh;
pub use orca::{ORCAAgent, ORCASolver};
pub use pathgrid::{Cell, PathGrid};
pub use steering::*;
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
