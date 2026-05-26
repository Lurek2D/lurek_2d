//! Visibility grid: per-region state storage for multiple simultaneous players/factions.
//!
//! - `VisibilityGrid` maps `(faction_id, region_id) → VisibilityState`.
//! - Update pass: marks visible set, propagates discovery, reverts out-of-range to Discovered.
//! - Dirty tracking ensures only changed regions emit events and redraw fog tiles.
//! - Grid is serialised into the save file; full snapshot is compact (2 bits per region per faction).

use super::{FogConfig, PlayerOwnership, VisibilityEvent, VisibilityFlags, VisibilityState};

/// The main visibility grid that tracks state for all regions and players.
#[derive(Debug, Clone)]
pub struct VisibilityGrid {
    /// Number of regions (tiles, provinces, etc.).
    region_count: u32,
    /// Per-player, per-region visibility state. Layout: [player][region].
    states: Vec<Vec<VisibilityState>>,
    /// Per-region visibility flags (what's revealed at each region).
    flags: Vec<VisibilityFlags>,
    /// Player/alliance ownership.
    ownership: PlayerOwnership,
    /// Per-region fog intensity (0.0 = clear, 1.0 = fully fogged).
    fog_intensity: Vec<f32>,
    /// Per-region discovery cost.
    costs: Vec<f32>,
    /// Pending events from last operation.
    pending_events: Vec<VisibilityEvent>,
    /// Fog configuration.
    fog_config: FogConfig,
}

impl VisibilityGrid {
    /// Create a new grid for the given number of regions and players, with all cells hidden.
    pub fn new(region_count: u32, player_count: u32) -> Self {
        let states =
            vec![vec![VisibilityState::Hidden; region_count as usize]; player_count as usize];
        let flags = vec![VisibilityFlags::NONE; region_count as usize];
        let fog_intensity = vec![1.0f32; region_count as usize];
        let costs = vec![1.0f32; region_count as usize];

        Self {
            region_count,
            states,
            flags,
            ownership: PlayerOwnership::new(player_count),
            fog_intensity,
            costs,
            pending_events: Vec::new(),
            fog_config: FogConfig::default(),
        }
    }

    /// Reveal a region for a player (and their allies).
    pub fn reveal(&mut self, player_id: u32, region_id: u32, reveal_flags: VisibilityFlags) {
        let allies = self.ownership.allies_of(player_id);
        for ally in &allies {
            if let Some(state) = self.get_state_mut(*ally, region_id) {
                let old = *state;
                *state = VisibilityState::Visible;
                if old != VisibilityState::Visible {
                    self.pending_events.push(VisibilityEvent::Revealed {
                        player_id: *ally,
                        region_id,
                    });
                }
            }
        }
        if let Some(flags) = self.flags.get_mut(region_id as usize) {
            *flags = flags.union(reveal_flags);
        }
        if let Some(fog) = self.fog_intensity.get_mut(region_id as usize) {
            *fog = 0.0;
        }
    }

    /// Hide a region for a player (move to Discovered if it was Visible).
    pub fn hide(&mut self, player_id: u32, region_id: u32) {
        let allies = self.ownership.allies_of(player_id);
        for ally in &allies {
            if let Some(state) = self.get_state_mut(*ally, region_id) {
                if *state == VisibilityState::Visible {
                    *state = VisibilityState::Discovered;
                    self.pending_events.push(VisibilityEvent::Hidden {
                        player_id: *ally,
                        region_id,
                    });
                }
            }
        }
        if let Some(fog) = self.fog_intensity.get_mut(region_id as usize) {
            *fog = self.fog_config.discovered_intensity;
        }
    }

    /// Get visibility state for a player at a region.
    pub fn get_state(&self, player_id: u32, region_id: u32) -> VisibilityState {
        self.states
            .get(player_id as usize)
            .and_then(|s| s.get(region_id as usize))
            .copied()
            .unwrap_or(VisibilityState::Hidden)
    }

    /// Get fog intensity for a region from a player's perspective.
    pub fn get_fog_intensity(&self, player_id: u32, region_id: u32) -> f32 {
        match self.get_state(player_id, region_id) {
            VisibilityState::Visible => 0.0,
            VisibilityState::Discovered => self.fog_config.discovered_intensity,
            VisibilityState::Hidden => 1.0,
            VisibilityState::Custom(level) => 1.0 - (level as f32 / 255.0),
        }
    }

    /// Set the discovery cost for a region.
    pub fn set_cost(&mut self, region_id: u32, cost: f32) {
        if let Some(c) = self.costs.get_mut(region_id as usize) {
            *c = cost;
        }
    }

    /// Get discovery cost for a region.
    pub fn get_cost(&self, region_id: u32) -> f32 {
        self.costs.get(region_id as usize).copied().unwrap_or(1.0)
    }

    /// Get visibility flags for a region.
    pub fn get_flags(&self, region_id: u32) -> VisibilityFlags {
        self.flags
            .get(region_id as usize)
            .copied()
            .unwrap_or(VisibilityFlags::NONE)
    }

    /// Set visibility flags for a region.
    pub fn set_flags(&mut self, region_id: u32, flags: VisibilityFlags) {
        if let Some(f) = self.flags.get_mut(region_id as usize) {
            *f = flags;
        }
    }

    /// Set group for players (shared visibility).
    pub fn set_group(&mut self, players: &[u32]) -> u32 {
        self.ownership.set_group(players)
    }

    /// Check if two players share visibility.
    pub fn shares_visibility(&self, a: u32, b: u32) -> bool {
        self.ownership.shares_visibility(a, b)
    }

    /// Drain and return all pending visibility events.
    pub fn drain_events(&mut self) -> Vec<VisibilityEvent> {
        std::mem::take(&mut self.pending_events)
    }

    /// Set the fog of war configuration.
    pub fn set_fog_config(&mut self, config: FogConfig) {
        self.fog_config = config;
    }

    /// Get the total number of regions tracked.
    pub fn region_count(&self) -> u32 {
        self.region_count
    }

    /// Get the total number of tracked players.
    pub fn player_count(&self) -> u32 {
        self.states.len() as u32
    }

    /// Reveal all regions for a player (debug/cheat).
    pub fn reveal_all(&mut self, player_id: u32) {
        for region_id in 0..self.region_count {
            self.reveal(player_id, region_id, VisibilityFlags::ALL);
        }
    }

    /// Reset all visibility to Hidden for a player.
    pub fn reset(&mut self, player_id: u32) {
        if let Some(states) = self.states.get_mut(player_id as usize) {
            states.fill(VisibilityState::Hidden);
        }
        self.fog_intensity.fill(1.0);
    }

    fn get_state_mut(&mut self, player_id: u32, region_id: u32) -> Option<&mut VisibilityState> {
        self.states
            .get_mut(player_id as usize)?
            .get_mut(region_id as usize)
    }
}
