//! Per-region discovery cost and adjacency requirements for visibility reveal logic.

/// Configuration for how expensive it is to discover a region.
#[derive(Debug, Clone, Copy)]
pub struct DiscoveryCost {
    /// Base cost to discover this region (default 1.0).
    pub base_cost: f32,
    /// Whether adjacent regions must be discovered first.
    pub requires_adjacent: bool,
    /// Minimum number of adjacent discovered regions required (0 = no requirement).
    pub min_adjacent_discovered: u8,
}

impl Default for DiscoveryCost {
    fn default() -> Self {
        Self {
            base_cost: 1.0,
            requires_adjacent: false,
            min_adjacent_discovered: 0,
        }
    }
}
