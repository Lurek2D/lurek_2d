//! AI Level-of-Detail (LOD) system — budget-aware update throttling.
//!
//! Assigns LOD tiers to AI agents based on their distance to a reference point
//! (typically the camera or nearest player). High-LOD agents (tier 0) run full
//! per-frame AI; medium-LOD agents (tier 1) run every N frames; distant agents
//! (tier 2+) run rarely or are put to sleep.
//!
//! ## Architecture
//!
//! - [`LodTier`] describes one distance band: name, max distance, update interval.
//! - [`AILod`] owns ordered tiers and maps a flat list of agent positions to
//!   tier indices each call to `assign_tiers`.
//!
//! ## Typical Usage Sequence
//!
//! 1. Create `AILod::default()` or configure custom tiers via `AILod::new(tiers)`.
//! 2. Each frame call `assign_tiers(agent_positions, reference_pos)` → Vec of tier indices.
//! 3. In the AI update loop, read each agent's tier and skip the update when the
//!    elapsed frame counter doesn't satisfy the tier's `update_every`.
//! 4. Optionally call `should_update(tier_idx, frame_number)` for a one-liner gate.

// ────────────────────────────────────────────────────────────────────────────
// LodTier
// ────────────────────────────────────────────────────────────────────────────

/// One distance band in the AI LOD system.
///
/// # Fields
/// - `name` — `String`.
/// - `max_distance` — `f32`.
/// - `update_every` — `u32`.
/// - `think_distance` — `f32`.
#[derive(Clone)]
pub struct LodTier {
    /// Human-readable tier name (e.g. `"near"`, `"mid"`, `"far"`, `"sleep"`).
    pub name: String,
    /// Maximum distance from the reference point for this tier.
    /// `f32::INFINITY` means "everything beyond the previous tier".
    pub max_distance: f32,
    /// Run the full AI update every `update_every` frames. `1` = every frame.
    /// `0` = completely suspended (sleeping).
    pub update_every: u32,
    /// Agents beyond this distance are considered out of "think range". Used by
    /// the AIWorld to skip expensive graph/perception queries.
    pub think_distance: f32,
}

impl LodTier {
    /// Creates a new LOD tier.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    /// - `max_distance` — `f32`.
    /// - `update_every` — `u32`.
    /// - `think_distance` — `f32`.
    ///
    /// # Returns
    /// `Self`.
    pub fn new(name: &str, max_distance: f32, update_every: u32, think_distance: f32) -> Self {
        Self {
            name: name.to_string(),
            max_distance,
            update_every,
            think_distance,
        }
    }
}

// ────────────────────────────────────────────────────────────────────────────
// AILod
// ────────────────────────────────────────────────────────────────────────────

/// LOD distance tiers and per-frame assignment engine.
///
/// Tiers are ordered by `max_distance` (ascending). Each agent falls into the
/// first tier whose `max_distance` exceeds the agent's distance to the reference
/// point. If no tier matches, the last tier is used.
///
/// # Fields
/// - `tiers` — `Vec<LodTier>`.
pub struct AILod {
    /// Ordered tier definitions (sorted ascending by `max_distance`).
    pub tiers: Vec<LodTier>,
}

impl AILod {
    /// Creates a LOD system from a custom tier list.
    ///
    /// The tiers are sorted by `max_distance` automatically.
    ///
    /// # Parameters
    /// - `tiers` — `Vec<LodTier>`.
    ///
    /// # Returns
    /// `Self`.
    pub fn new(mut tiers: Vec<LodTier>) -> Self {
        tiers.sort_by(|a, b| a.max_distance.partial_cmp(&b.max_distance).unwrap());
        Self { tiers }
    }

    /// Returns a reference to the tier at index `i`.
    ///
    /// # Parameters
    /// - `i` — `usize`.
    ///
    /// # Returns
    /// `Option<&LodTier>`.
    pub fn tier(&self, i: usize) -> Option<&LodTier> {
        self.tiers.get(i)
    }

    /// Returns the number of tiers.
    ///
    /// # Returns
    /// `usize`.
    pub fn tier_count(&self) -> usize {
        self.tiers.len()
    }

    /// Determines the LOD tier index for an agent at `agent_pos` from `ref_pos`.
    ///
    /// # Parameters
    /// - `agent_pos` — `(f32, f32)`.
    /// - `ref_pos` — `(f32, f32)`.
    ///
    /// # Returns
    /// `usize`.
    pub fn tier_for(&self, agent_pos: (f32, f32), ref_pos: (f32, f32)) -> usize {
        let dx = agent_pos.0 - ref_pos.0;
        let dy = agent_pos.1 - ref_pos.1;
        let dist = (dx * dx + dy * dy).sqrt();
        for (i, tier) in self.tiers.iter().enumerate() {
            if dist <= tier.max_distance {
                return i;
            }
        }
        self.tiers.len().saturating_sub(1)
    }

    /// Computes tier indices for a batch of agent positions. Returns a `Vec<usize>`
    /// with length equal to `agent_positions`.
    ///
    /// # Parameters
    /// - `agent_positions` — `&[(f32, f32)]`.
    /// - `ref_pos` — `(f32, f32)`.
    ///
    /// # Returns
    /// `Vec<usize>`.
    pub fn assign_tiers(&self, agent_positions: &[(f32, f32)], ref_pos: (f32, f32)) -> Vec<usize> {
        agent_positions
            .iter()
            .map(|&p| self.tier_for(p, ref_pos))
            .collect()
    }

    /// Returns `true` if an agent in `tier` should be updated on `frame_number`.
    ///
    /// An `update_every` of `0` always returns `false` (sleeping).
    /// `update_every` of `1` always returns `true` (every frame).
    ///
    /// # Parameters
    /// - `tier` — `usize`.
    /// - `frame_number` — `u64`.
    ///
    /// # Returns
    /// `bool`.
    pub fn should_update(&self, tier: usize, frame_number: u64) -> bool {
        match self.tiers.get(tier) {
            Some(t) => {
                if t.update_every == 0 {
                    false
                } else {
                    frame_number % t.update_every as u64 == 0
                }
            }
            None => false,
        }
    }
}

impl Default for AILod {
    /// Creates a three-tier default configuration:
    /// - Tier 0 `"near"`: ≤400 units, every frame.
    /// - Tier 1 `"mid"`: ≤800 units, every 4 frames.
    /// - Tier 2 `"far"`: ∞, every 16 frames.
    fn default() -> Self {
        Self::new(vec![
            LodTier::new("near", 400.0, 1, 400.0),
            LodTier::new("mid", 800.0, 4, 600.0),
            LodTier::new("far", f32::INFINITY, 16, 2000.0),
        ])
    }
}
