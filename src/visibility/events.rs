//! This file owns `VisibilityEvent`, the event payload emitted when regions are revealed, hidden, forgotten, or regrouped.
//! It gives callers stable event variants for reacting to state changes without inspecting grid internals directly.
//! Open this file when visibility notifications change; stored state and ownership logic live in sibling modules.

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
