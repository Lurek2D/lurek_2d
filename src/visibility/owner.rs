//! Player and faction ownership of shared visibility and discovery state.
//!
//! - Data type: `PlayerOwnership`.

use std::collections::HashMap;

/// Manages which players share visibility (alliances/teams).
#[derive(Debug, Clone)]
pub struct PlayerOwnership {
    /// Total number of players.
    player_count: u32,
    /// Group assignments: player_id → group_id.
    groups: HashMap<u32, u32>,
    /// Next available group ID.
    next_group: u32,
}

impl PlayerOwnership {
    /// Create a new `PlayerOwnership` tracking the given number of players, all ungrouped.
    pub fn new(player_count: u32) -> Self {
        Self {
            player_count,
            groups: HashMap::new(),
            next_group: 0,
        }
    }

    /// Assign multiple players to a shared visibility group.
    pub fn set_group(&mut self, players: &[u32]) -> u32 {
        let gid = self.next_group;
        self.next_group += 1;
        for &p in players {
            if p < self.player_count {
                self.groups.insert(p, gid);
            }
        }
        gid
    }

    /// Remove a player from their group (becomes independent).
    pub fn remove_from_group(&mut self, player_id: u32) {
        self.groups.remove(&player_id);
    }

    /// Get all players that share visibility with a given player.
    pub fn allies_of(&self, player_id: u32) -> Vec<u32> {
        if let Some(&gid) = self.groups.get(&player_id) {
            self.groups
                .iter()
                .filter(|(_, &g)| g == gid)
                .map(|(&p, _)| p)
                .collect()
        } else {
            vec![player_id]
        }
    }

    /// Check if two players share visibility.
    pub fn shares_visibility(&self, a: u32, b: u32) -> bool {
        if a == b {
            return true;
        }
        match (self.groups.get(&a), self.groups.get(&b)) {
            (Some(ga), Some(gb)) => ga == gb,
            _ => false,
        }
    }

    /// Return the total number of players managed by this ownership tracker.
    pub fn player_count(&self) -> u32 {
        self.player_count
    }
}
