//! This module is the flownet index, wiring graph storage, simulation, routing, algorithms, and render helpers.
//! It reexports `Graph`, ids, node contracts, items, edges, and events so callers enter the subsystem from one file.
//! `core.rs` owns mutation and persistence, `simulation.rs` advances state, and `pathfinding.rs` owns route queries.
//! `node.rs`, `edge.rs`, `item.rs`, and `types.rs` define the local data contracts consumed across all flownet logic.
//! This file owns visibility and navigation only, not graph state, update rules, route costs, or debug drawing behavior.
//! Open it when public flownet exports move; open the sibling owner file when transport or simulation semantics change.

/// Graph algorithm helpers. This module is publicly re-exported.
pub mod algorithms;
/// Core graph container and stats.
pub mod core;
/// Edge data and transit helpers.
pub mod edge;
/// Graph item data. This module is publicly re-exported.
pub mod item;
/// Node data and flow configuration.
pub mod node;
/// Graph pathfinding helpers. This module is publicly re-exported.
pub mod pathfinding;
/// Graph render helpers. This module is publicly re-exported.
pub mod render;
/// Graph simulation update logic.
pub mod simulation;
/// Supply and demand helpers. This module is publicly re-exported.
pub mod supply_demand;
/// Type-safe identifiers for nodes, edges, and items.
pub mod types;
/// Core graph container and stats.
pub use core::{Graph, GraphStats};
/// Edge data type.
pub use edge::Edge;
/// Item data types.
pub use item::{GraphItem, ItemPosition};
/// Node data and flow configuration types.
pub use node::{ConversionRule, Demand, FlowMode, Node, OverflowPolicy, Supply};
/// Graph simulation event type.
pub use simulation::GraphEvent;
/// Type-safe identifiers.
pub use types::{EdgeId, ItemId, NodeId};
