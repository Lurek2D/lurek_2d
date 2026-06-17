//! Provides the high-level flownet module boundary for graph flow modeling, simulation, and rendering support. `flownet/mod` is the flownet module index, declaring `algorithms`, `core`, `edge`, `item`, `node`, and 5 more so agents can identify which files own each feature slice before opening implementation code.
//! Connects nodes, edges, items, demand logic, routing, and update events into one runtime network surface. `src/flownet/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `core::{Graph, GraphStats}`, `edge::Edge`, `item::{GraphItem, ItemPosition}`, `node::{ConversionRule, Demand, FlowMode, Node, OverflowPolicy, Supply}`, and 2 more centralized for the flownet subsystem.
//! Delivers a complete directed-flow toolkit for gameplay systems that model transport and transformation. The file documents how flownet submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.
//! `flownet/mod` is the flownet module index, declaring `algorithms`, `core`, `edge`, `item`, `node`, and 5 more so agents can identify which files own each feature slice before opening implementation code.
//! `src/flownet/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `core::{Graph, GraphStats}`, `edge::Edge`, `item::{GraphItem, ItemPosition}`, `node::{ConversionRule, Demand, FlowMode, Node, OverflowPolicy, Supply}`, and 2 more centralized for the flownet subsystem.
//! The file documents how flownet submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.

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
