//! This module delivers the high-level fog, discovery, and line-of-sight system for region maps. `visibility/mod` is the visibility module index, declaring `adjacency`, `cost`, `events`, `flags`, `fog_render`, and 4 more so agents can identify which files own each feature slice before opening implementation code.
//! It stays geometry-agnostic so tile, province, and custom topologies can share the same model. `src/visibility/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `adjacency::AdjacencyProvider`, `cost::DiscoveryCost`, `events::VisibilityEvent`, `flags::VisibilityFlags`, and 5 more centralized for the visibility subsystem.
//! It unifies state storage, ownership sharing, reveal costs, events, and fog presentation paths. The file documents how visibility submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.
//! `visibility/mod` is the visibility module index, declaring `adjacency`, `cost`, `events`, `flags`, `fog_render`, and 4 more so agents can identify which files own each feature slice before opening implementation code.
//! `src/visibility/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `adjacency::AdjacencyProvider`, `cost::DiscoveryCost`, `events::VisibilityEvent`, `flags::VisibilityFlags`, and 5 more centralized for the visibility subsystem.
//! The file documents how visibility submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.

/// Adjacency provider trait defining region neighbor relationships.
pub mod adjacency;
/// Per-region discovery cost and adjacency requirements for reveal logic.
pub mod cost;
/// Events emitted when region visibility state transitions occur.
pub mod events;
/// Per-region bitfield flags: terrain, units, buildings, and custom bits.
pub mod flags;
/// Fog-of-war rendering configuration: intensity, color, and render hints.
pub mod fog_render;
/// Visibility grid: per-region state storage for multiple simultaneous players.
pub mod grid;
/// Player and group ownership of shared visibility and discovery state.
pub mod owner;
/// Tile-grid recursive shadowcasting FOV for roguelike and stealth games.
pub mod shadowcast;
/// Visibility state enum: Hidden, Discovered, Visible, and custom levels.
pub mod state;

pub use adjacency::AdjacencyProvider;
pub use cost::DiscoveryCost;
pub use events::VisibilityEvent;
pub use flags::VisibilityFlags;
pub use fog_render::FogConfig;
pub use grid::VisibilityGrid;
pub use owner::PlayerOwnership;
pub use shadowcast::TileFov;
pub use state::VisibilityState;
