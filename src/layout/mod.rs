//! Aggregates graph and tree layout strategies into one coherent coordinate service for runtime visuals. `layout/mod` is the layout module index, declaring `dag`, `force`, `grid_align`, `tree`, `types` so agents can identify which files own each feature slice before opening implementation code.
//! Unifies result and config contracts so callers can switch placement style without changing integration code. `src/layout/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `dag::layout_dag`, `force::{layout_force, ForceConfig}`, `grid_align::{center_in_area, snap_to_grid}`, `tree::layout_tree`, and 1 more centralized for the layout subsystem.

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
