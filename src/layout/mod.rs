//! Indexes layout algorithms, shared payload types, and coordinate post-processing helper owners.
//! Declares tree, DAG, force, circular, radial, grid, spiral, stress, and alignment submodules.
//! Reexports main entry points so callers switch strategies without depending on deep owner paths.
//! Keeps coordinate math and live state out of this file; sibling modules own placement behavior.
//! Guides agents to the right algorithm owner before changing spacing, overlap, or result geometry.
//! Changes here affect reachability and API shape, not placement rules, spacing policy, or results.

/// Circular ring layout for cycle-heavy or overview graph diagrams.
pub mod circular;
/// Sugiyama layered layout algorithm for directed acyclic graphs (DAGs).
pub mod dag;
/// Fruchterman-Reingold force-directed spring simulation for arbitrary graphs.
pub mod force;
/// Compact row-column placement for dense or disconnected node sets.
pub mod grid;
/// Post-processing utilities: snap nodes to grid and center in bounding area.
pub mod grid_align;
/// Radial breadth-first graph layout for hub-and-spoke diagrams.
pub mod radial;
/// Fast expanding spiral placement for large unordered graphs.
pub mod spiral;
/// Lightweight stress-distance graph layout for topology-readable arbitrary graphs.
pub mod stress;
/// Reingold-Tilford algorithm for compact hierarchical tree node layout.
pub mod tree;
/// Shared layout types: nodes, edges, configuration, and result structures.
pub mod types;

pub use circular::layout_circular;
pub use dag::layout_dag;
pub use force::{layout_force, ForceConfig};
pub use grid::layout_grid;
pub use grid_align::{center_in_area, snap_to_grid};
pub use radial::layout_radial;
pub use spiral::layout_spiral;
pub use stress::{layout_stress, StressConfig};
pub use tree::layout_tree;
pub use types::{LayoutConfig, LayoutEdge, LayoutNode, LayoutResult, NodeId};
