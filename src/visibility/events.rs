//! Visibility state-change events emitted when regions transition between states.

/// Events emitted by the visibility system when regions change state.
#[derive(Debug, Clone, PartialEq)]
pub enum VisibilityEvent {
    /// A region became visible for a player.
    Revealed { player_id: u32, region_id: u32 },
    /// A region was hidden (moved from Visible to Discovered) for a player.
    Hidden { player_id: u32, region_id: u32 },
    /// A region was fully forgotten (moved to Hidden) for a player.
    Forgotten { player_id: u32, region_id: u32 },
    /// A player's alliance group changed.
    GroupChanged { player_id: u32, group_id: u32 },
}
