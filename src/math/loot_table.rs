//! Walker-Vose alias-method loot table and pity tracker.
//!
//! - `LootTable` samples in O(1) using the alias method after an O(n) build.
//! - `PityTracker` counts misses and primes a guaranteed drop after `threshold` misses.
//! - `sample_with_pity` combines both: forces the tracked item when the pity is primed.
//! - Serialisation via `save` / `restore` round-trips the RNG state and all weights.

use crate::math::random::RandomGenerator;
use std::collections::HashMap;

// ── LootEntry ─────────────────────────────────────────────────────────────────

/// A single entry in a loot table.
#[derive(Clone, Debug)]
pub struct LootEntry {
    /// Unique identifier for this drop.
    pub id: String,
    /// Relative drop weight (before normalisation).
    pub weight: f64,
    /// Optional metadata key-value pairs attached to the entry.
    pub meta: HashMap<String, String>,
}

// ── LootTable ─────────────────────────────────────────────────────────────────

/// O(1)-sample loot table using the Walker-Vose alias method.
///
/// Call [`LootTable::build`] after adding or modifying entries. The table
/// becomes ready for [`LootTable::sample`] calls.
pub struct LootTable {
    /// Registered entries in insertion order.
    entries: Vec<LootEntry>,
    /// Alias probability thresholds (0.0..=1.0), one per entry.
    prob: Vec<f64>,
    /// Alias target indices, one per entry.
    alias: Vec<usize>,
    /// Random generator used for sampling.
    rng: RandomGenerator,
    /// True when `build` has been called after the last mutation.
    built: bool,
}

impl LootTable {
    /// Create an empty loot table seeded from the system entropy.
    pub fn new() -> Self {
        Self {
            entries: Vec::new(),
            prob: Vec::new(),
            alias: Vec::new(),
            rng: RandomGenerator::new(),
            built: false,
        }
    }

    /// Create an empty loot table with a deterministic seed.
    pub fn with_seed(seed: u64) -> Self {
        Self {
            entries: Vec::new(),
            prob: Vec::new(),
            alias: Vec::new(),
            rng: RandomGenerator::with_seed(seed),
            built: false,
        }
    }

    /// Set the RNG seed. Invalidates the built alias table.
    pub fn set_seed(&mut self, seed: u64) {
        self.rng = RandomGenerator::with_seed(seed);
    }

    /// Add an entry. Re-build is required before the next sample.
    pub fn add(&mut self, id: &str, weight: f64, meta: HashMap<String, String>) {
        self.entries.push(LootEntry {
            id: id.to_string(),
            weight: weight.max(0.0),
            meta,
        });
        self.built = false;
    }

    /// Remove the entry with the given id. Returns `true` when found.
    pub fn remove(&mut self, id: &str) -> bool {
        if let Some(pos) = self.entries.iter().position(|e| e.id == id) {
            self.entries.remove(pos);
            self.built = false;
            true
        } else {
            false
        }
    }

    /// Update the weight of an existing entry. Returns `true` when found.
    pub fn set_weight(&mut self, id: &str, weight: f64) -> bool {
        if let Some(e) = self.entries.iter_mut().find(|e| e.id == id) {
            e.weight = weight.max(0.0);
            self.built = false;
            true
        } else {
            false
        }
    }

    /// Merge all entries from `other` into this table. Re-build required.
    pub fn merge(&mut self, other: &LootTable) {
        for e in &other.entries {
            self.entries.push(e.clone());
        }
        self.built = false;
    }

    /// Build the alias table. Must be called after every mutation.
    /// Panics when there are no entries with positive weight.
    pub fn build(&mut self) {
        let n = self.entries.len();
        if n == 0 {
            self.prob  = Vec::new();
            self.alias = Vec::new();
            self.built = true;
            return;
        }

        let total: f64 = self.entries.iter().map(|e| e.weight).sum();
        assert!(total > 0.0, "LootTable: all weights are zero");

        let avg = total / n as f64;
        let mut scaled: Vec<f64> = self.entries.iter().map(|e| e.weight / avg * n as f64).collect();

        self.prob  = vec![0.0; n];
        self.alias = vec![0usize; n];

        let mut small: Vec<usize> = Vec::new();
        let mut large: Vec<usize> = Vec::new();

        for (i, &s) in scaled.iter().enumerate() {
            if s < 1.0 { small.push(i); } else { large.push(i); }
        }

        while !small.is_empty() && !large.is_empty() {
            let l = small.pop().unwrap();
            let g = large.pop().unwrap();
            self.prob[l]  = scaled[l];
            self.alias[l] = g;
            scaled[g] = scaled[g] + scaled[l] - 1.0;
            if scaled[g] < 1.0 { small.push(g); } else { large.push(g); }
        }
        for l in small  { self.prob[l] = 1.0; }
        for g in large  { self.prob[g] = 1.0; }

        self.built = true;
    }

    /// True when `build` has been called after the last mutation.
    pub fn is_built(&self) -> bool {
        self.built
    }

    /// Sample one entry in O(1). Returns `None` when the table is empty.
    /// Panics when `build` has not been called since the last mutation.
    pub fn sample(&mut self) -> Option<&LootEntry> {
        self.ensure_built();
        let n = self.entries.len();
        if n == 0 { return None; }
        let col = self.rng.random_int(0, n as i64 - 1) as usize;
        let r   = self.rng.random();
        let idx = if r < self.prob[col] { col } else { self.alias[col] };
        Some(&self.entries[idx])
    }

    /// Sample `n` entries with replacement (may repeat).
    pub fn sample_n(&mut self, n: usize) -> Vec<LootEntry> {
        self.ensure_built();
        let mut out = Vec::with_capacity(n);
        for _ in 0..n {
            if let Some(entry) = self.sample() {
                out.push(entry.clone());
            }
        }
        out
    }

    /// Sample up to `n` unique entries (by id). Stops when the pool is exhausted.
    pub fn sample_unique(&mut self, n: usize) -> Vec<LootEntry> {
        self.ensure_built();
        let mut seen = std::collections::HashSet::new();
        let mut result = Vec::new();
        let max_attempts = n * 20 + 100;
        for _ in 0..max_attempts {
            if result.len() >= n { break; }
            if seen.len() >= self.entries.len() { break; }
            if let Some(e) = self.sample() {
                if seen.insert(e.id.clone()) {
                    result.push(e.clone());
                }
            }
        }
        result
    }

    /// Build if not already built (idempotent).
    fn ensure_built(&mut self) {
        if !self.built {
            self.build();
        }
    }

    /// Access the raw entries slice.
    pub fn entries(&self) -> &[LootEntry] {
        &self.entries
    }
}

impl Default for LootTable {
    fn default() -> Self {
        Self::new()
    }
}

// ── PityTracker ───────────────────────────────────────────────────────────────

/// Tracks consecutive misses of a target item and primes a guaranteed drop
/// after `threshold` misses.
///
/// Call [`PityTracker::notice`] after every sample. When `primed` is `true`,
/// pass the tracker to [`sample_with_pity`] to force the guaranteed drop.
pub struct PityTracker {
    /// The item id that triggers the pity reset on a hit.
    target_id: String,
    /// Number of consecutive misses before the tracker primes.
    threshold: u32,
    /// Current consecutive miss counter.
    counter: u32,
    /// True when the guaranteed drop is due.
    primed: bool,
}

impl PityTracker {
    /// Create a new pity tracker for `target_id` that primes after `threshold` misses.
    pub fn new(target_id: &str, threshold: u32) -> Self {
        Self {
            target_id: target_id.to_string(),
            threshold,
            counter: 0,
            primed: false,
        }
    }

    /// Notify the tracker of a sample result.
    /// Returns `true` when the tracker just primed (threshold was just hit).
    pub fn notice(&mut self, result_id: &str) -> bool {
        if result_id == self.target_id {
            self.counter = 0;
            self.primed  = false;
            false
        } else {
            self.counter += 1;
            if self.counter >= self.threshold {
                let just_primed = !self.primed;
                self.primed = true;
                just_primed
            } else {
                false
            }
        }
    }

    /// True when the guaranteed drop is due on the next sample.
    pub fn is_primed(&self) -> bool {
        self.primed
    }

    /// Reset counter and primed state without consuming a guaranteed drop.
    pub fn reset(&mut self) {
        self.counter = 0;
        self.primed  = false;
    }

    /// Returns the current pity-system miss counter value.
    pub fn counter(&self) -> u32 {
        self.counter
    }

    /// Serialise state as a compact byte blob.
    /// Layout: `[threshold: u32 le][counter: u32 le][primed: u8]`.
    pub fn save(&self) -> Vec<u8> {
        let mut out = Vec::with_capacity(9);
        out.extend_from_slice(&self.threshold.to_le_bytes());
        out.extend_from_slice(&self.counter.to_le_bytes());
        out.push(if self.primed { 1u8 } else { 0u8 });
        out
    }

    /// Restore from a blob produced by [`PityTracker::save`].
    pub fn restore(&mut self, data: &[u8]) -> Result<(), String> {
        if data.len() < 9 {
            return Err("pity restore: blob too short".into());
        }
        self.threshold = u32::from_le_bytes(data[0..4].try_into().unwrap());
        self.counter   = u32::from_le_bytes(data[4..8].try_into().unwrap());
        self.primed    = data[8] != 0;
        Ok(())
    }
}

// ── sample_with_pity ─────────────────────────────────────────────────────────

/// Sample from `table`, forcing `pity.target_id` when `pity` is primed.
///
/// Notifies the tracker with the result before returning.
/// Returns `None` when the table has no entries.
pub fn sample_with_pity<'a>(
    table: &'a mut LootTable,
    pity: &mut PityTracker,
) -> Option<&'a LootEntry> {
    let result_id = if pity.is_primed() {
        // Force the tracked item
        table.ensure_built();
        pity.target_id.clone()
    } else {
        table.sample()?.id.clone()
    };

    pity.notice(&result_id);

    // Return a reference to the entry with the selected id
    table.entries().iter().find(|e| e.id == result_id)
}
