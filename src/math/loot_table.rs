//! Walker-Vose alias-method loot table and pity tracker.
//!
//! - `LootTable` samples in O(1) using the alias method after an O(n) build.
//! - `PityTracker` counts misses and primes a guaranteed drop after `threshold` misses.
//! - `sample_with_pity` combines both: forces the tracked item when the pity is primed.
//! - Serialisation via `save` / `restore` round-trips the RNG state and all weights.

use crate::math::random::RandomGenerator;
use std::collections::HashMap;
use toml::Value as TomlValue;

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

    /// Serialise the loot table and RNG state into a compact binary blob.
    pub fn save(&self) -> Vec<u8> {
        let mut out = Vec::new();

        write_u32(&mut out, 1); // format version
        write_u32(&mut out, self.entries.len() as u32);
        for entry in &self.entries {
            write_bytes(&mut out, entry.id.as_bytes());
            out.extend_from_slice(&entry.weight.to_le_bytes());
            write_u32(&mut out, entry.meta.len() as u32);
            for (k, v) in &entry.meta {
                write_bytes(&mut out, k.as_bytes());
                write_bytes(&mut out, v.as_bytes());
            }
        }

        write_u32(&mut out, self.prob.len() as u32);
        for p in &self.prob {
            out.extend_from_slice(&p.to_le_bytes());
        }

        write_u32(&mut out, self.alias.len() as u32);
        for a in &self.alias {
            out.extend_from_slice(&(*a as u64).to_le_bytes());
        }

        out.push(if self.built { 1u8 } else { 0u8 });
        write_bytes(&mut out, self.rng.get_state().as_bytes());

        out
    }

    /// Restore from a blob produced by [`LootTable::save`].
    pub fn restore(&mut self, data: &[u8]) -> Result<(), String> {
        let mut cursor = 0usize;
        let version = read_u32(data, &mut cursor)?;
        if version != 1 {
            return Err(format!("loot table restore: unsupported version {version}"));
        }

        let entry_count = read_u32(data, &mut cursor)? as usize;
        let mut entries = Vec::with_capacity(entry_count);
        for _ in 0..entry_count {
            let id = read_string(data, &mut cursor)?;
            let weight = read_f64(data, &mut cursor)?;
            let meta_count = read_u32(data, &mut cursor)? as usize;
            let mut meta = HashMap::with_capacity(meta_count);
            for _ in 0..meta_count {
                let k = read_string(data, &mut cursor)?;
                let v = read_string(data, &mut cursor)?;
                meta.insert(k, v);
            }
            entries.push(LootEntry { id, weight, meta });
        }

        let prob_len = read_u32(data, &mut cursor)? as usize;
        let mut prob = Vec::with_capacity(prob_len);
        for _ in 0..prob_len {
            prob.push(read_f64(data, &mut cursor)?);
        }

        let alias_len = read_u32(data, &mut cursor)? as usize;
        let mut alias = Vec::with_capacity(alias_len);
        for _ in 0..alias_len {
            alias.push(read_u64(data, &mut cursor)? as usize);
        }

        let built = read_u8(data, &mut cursor)? != 0;
        let rng_state = read_string(data, &mut cursor)?;
        if cursor != data.len() {
            return Err("loot table restore: trailing bytes in blob".into());
        }

        let mut rng = RandomGenerator::new();
        rng.set_state(&rng_state)
            .map_err(|e| format!("loot table restore: invalid RNG state: {e}"))?;

        self.entries = entries;
        self.prob = prob;
        self.alias = alias;
        self.built = built;
        self.rng = rng;

        if self.built {
            if self.prob.len() != self.entries.len() || self.alias.len() != self.entries.len() {
                return Err("loot table restore: alias/prob lengths do not match entry count".into());
            }
        } else {
            self.prob.clear();
            self.alias.clear();
        }

        Ok(())
    }

    /// Build a loot table from TOML source.
    ///
    /// Expected shape:
    /// `seed = 123` (optional)
    /// and `entries = [{ id = "x", weight = 1.0, meta = { key = "value" } }, ...]`.
    pub fn from_toml(src: &str) -> Result<Self, String> {
        let value: TomlValue = src
            .parse::<TomlValue>()
            .map_err(|e| format!("loot table from_toml: parse error: {e}"))?;
        let root = value
            .as_table()
            .ok_or_else(|| "loot table from_toml: root must be a table".to_string())?;

        let mut table = if let Some(seed) = root.get("seed").and_then(TomlValue::as_integer) {
            if seed < 0 {
                return Err("loot table from_toml: seed must be >= 0".into());
            }
            Self::with_seed(seed as u64)
        } else {
            Self::new()
        };

        let entries = root
            .get("entries")
            .and_then(TomlValue::as_array)
            .ok_or_else(|| "loot table from_toml: missing entries array".to_string())?;

        for (idx, entry) in entries.iter().enumerate() {
            let entry_tbl = entry.as_table().ok_or_else(|| {
                format!("loot table from_toml: entries[{idx}] must be a table")
            })?;
            let id = entry_tbl
                .get("id")
                .and_then(TomlValue::as_str)
                .ok_or_else(|| format!("loot table from_toml: entries[{idx}].id must be string"))?;
            let weight = match entry_tbl.get("weight") {
                Some(TomlValue::Float(f)) => *f,
                Some(TomlValue::Integer(i)) => *i as f64,
                Some(_) => {
                    return Err(format!(
                        "loot table from_toml: entries[{idx}].weight must be number"
                    ))
                }
                None => {
                    return Err(format!(
                        "loot table from_toml: entries[{idx}] missing weight"
                    ))
                }
            };

            let mut meta = HashMap::new();
            if let Some(meta_tbl) = entry_tbl.get("meta").and_then(TomlValue::as_table) {
                for (k, v) in meta_tbl {
                    meta.insert(k.clone(), toml_value_to_string(v));
                }
            }

            table.add(id, weight, meta);
        }

        if !table.entries.is_empty() {
            table.build();
        }
        Ok(table)
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

fn toml_value_to_string(v: &TomlValue) -> String {
    match v {
        TomlValue::String(s) => s.clone(),
        TomlValue::Integer(n) => n.to_string(),
        TomlValue::Float(f) => f.to_string(),
        TomlValue::Boolean(b) => b.to_string(),
        TomlValue::Datetime(dt) => dt.to_string(),
        _ => v.to_string(),
    }
}

fn write_u32(out: &mut Vec<u8>, value: u32) {
    out.extend_from_slice(&value.to_le_bytes());
}

fn write_bytes(out: &mut Vec<u8>, bytes: &[u8]) {
    write_u32(out, bytes.len() as u32);
    out.extend_from_slice(bytes);
}

fn read_u8(data: &[u8], cursor: &mut usize) -> Result<u8, String> {
    if *cursor + 1 > data.len() {
        return Err("loot table restore: unexpected EOF (u8)".into());
    }
    let v = data[*cursor];
    *cursor += 1;
    Ok(v)
}

fn read_u32(data: &[u8], cursor: &mut usize) -> Result<u32, String> {
    if *cursor + 4 > data.len() {
        return Err("loot table restore: unexpected EOF (u32)".into());
    }
    let mut buf = [0u8; 4];
    buf.copy_from_slice(&data[*cursor..*cursor + 4]);
    *cursor += 4;
    Ok(u32::from_le_bytes(buf))
}

fn read_u64(data: &[u8], cursor: &mut usize) -> Result<u64, String> {
    if *cursor + 8 > data.len() {
        return Err("loot table restore: unexpected EOF (u64)".into());
    }
    let mut buf = [0u8; 8];
    buf.copy_from_slice(&data[*cursor..*cursor + 8]);
    *cursor += 8;
    Ok(u64::from_le_bytes(buf))
}

fn read_f64(data: &[u8], cursor: &mut usize) -> Result<f64, String> {
    if *cursor + 8 > data.len() {
        return Err("loot table restore: unexpected EOF (f64)".into());
    }
    let mut buf = [0u8; 8];
    buf.copy_from_slice(&data[*cursor..*cursor + 8]);
    *cursor += 8;
    Ok(f64::from_le_bytes(buf))
}

fn read_bytes<'a>(data: &'a [u8], cursor: &mut usize) -> Result<&'a [u8], String> {
    let len = read_u32(data, cursor)? as usize;
    if *cursor + len > data.len() {
        return Err("loot table restore: unexpected EOF (bytes)".into());
    }
    let out = &data[*cursor..*cursor + len];
    *cursor += len;
    Ok(out)
}

fn read_string(data: &[u8], cursor: &mut usize) -> Result<String, String> {
    let bytes = read_bytes(data, cursor)?;
    String::from_utf8(bytes.to_vec())
        .map_err(|_| "loot table restore: invalid UTF-8 in string".to_string())
}
