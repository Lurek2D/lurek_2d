//! Generic graph/tree/DAG layout algorithms.

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
