//! `src/layout/mod.rs` is the module index for layout algorithms, shared types, and post-processing helpers.
//! It declares DAG, tree, force, and grid-alignment files while keeping the shared layout contracts in `types.rs`.
//! This file reexports the main entry points so callers can switch layout strategy without importing deep module paths.
//! No layout state or coordinate math lives here; it only defines the public surface and subsystem ownership map.
//! Read this index first when tracing layout behavior, because it shows where algorithms end and shared data begins.
//! Changes here affect reachability and API shape, not node placement rules, spacing policy, or result generation.

/// Sugiyama layered layout algorithm for directed acyclic graphs (DAGs).
pub mod dag;
/// Fruchterman-Reingold force-directed spring simulation for arbitrary graphs.
pub mod force;
/// Post-processing utilities: snap nodes to grid and center in bounding area.
pub mod grid_align;
/// Reingold-Tilford algorithm for compact hierarchical tree node layout.
pub mod tree;
/// Shared layout types: nodes, edges, configuration, and result structures.
pub mod types;

pub use dag::layout_dag;
pub use force::{layout_force, ForceConfig};
pub use grid_align::{center_in_area, snap_to_grid};
pub use tree::layout_tree;
pub use types::{LayoutConfig, LayoutEdge, LayoutNode, LayoutResult, NodeId};
