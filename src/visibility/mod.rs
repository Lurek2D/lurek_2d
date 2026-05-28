//! Universal visibility system for fog-of-war, discovery, and line-of-sight.
//!
//! - This module provides a generic visibility layer that can be attached to any
//! - region-based system (tilemap, province map, globe, custom). The module is
//! - agnostic to geometry — it receives region counts and adjacency lists.
//! - # Architecture
//! - `VisibilityGrid` — per-region visibility state for multiple players
//! - `VisibilityState` — enum: Hidden, Discovered, Visible (+ custom u8 levels)
//! - `PlayerOwnership` — which players/groups share visibility
//! - `VisibilityFlags` — bitfield per region (terrain, units, buildings, etc.)
//! - `DiscoveryCost` — per-region cost to reveal, adjacency requirements
//! - `FogConfig` — fog intensity and rendering hints

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
/// Visibility state enum: Hidden, Discovered, Visible, and custom levels.
pub mod state;

pub use adjacency::AdjacencyProvider;
pub use cost::DiscoveryCost;
pub use events::VisibilityEvent;
pub use flags::VisibilityFlags;
pub use fog_render::FogConfig;
pub use grid::VisibilityGrid;
pub use owner::PlayerOwnership;
pub use state::VisibilityState;
