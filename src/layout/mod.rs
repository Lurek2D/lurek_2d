//! Generic graph/tree/DAG layout algorithms.
//!
//! - Provides algorithms for positioning nodes in 2D space:
//! - **Tree layout** — Reingold-Tilford algorithm for hierarchical trees
//! - **DAG layout** — Sugiyama layered algorithm for directed acyclic graphs
//! - **Force-directed** — Fruchterman-Reingold spring simulation for arbitrary graphs
//! - **Grid alignment** — Post-processing snap-to-grid and centering
//! - Used by: pipeline visualization, dialog tree view, skill trees, node editors.

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
