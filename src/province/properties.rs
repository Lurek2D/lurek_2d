//! Province property storage: per-province key-value metadata and stat tables.
//!
//! - `ProvinceProperties` maps `ProvinceId → HashMap<String, PropertyValue>`.
//! - `PropertyValue` is an enum covering `Int`, `Float`, `Bool`, and `Text` variants.
//! - Properties are set from Lua via `lurek.province.set_property(id, key, value)`.
//! - Serialized into the save file as a flat list for fast round-trip loading.

use std::collections::HashMap;

/// Generic per-province property store.
/// Game defines what "population", "food" etc. mean through Lua.
pub struct ProvinceProperties {
    /// Named numeric values per province.
    numeric: HashMap<u32, HashMap<String, f64>>,
    /// Named string attributes per province.
    string_attrs: HashMap<u32, HashMap<String, String>>,
    /// Bitfield flags per province (64 custom flags).
    flags: HashMap<u32, u64>,
}

impl ProvinceProperties {
    /// Create a new empty property store with no province data.
    pub fn new() -> Self {
        Self {
            numeric: HashMap::new(),
            string_attrs: HashMap::new(),
            flags: HashMap::new(),
        }
    }

    /// Set a named numeric value for the given province.
    pub fn set_numeric(&mut self, province_id: u32, key: &str, value: f64) {
        self.numeric
            .entry(province_id)
            .or_default()
            .insert(key.to_string(), value);
    }

    /// Get the named numeric value for a province, or `None` if not set.
    pub fn get_numeric(&self, province_id: u32, key: &str) -> Option<f64> {
        self.numeric.get(&province_id)?.get(key).copied()
    }

    /// Set a named string attribute for the given province.
    pub fn set_string(&mut self, province_id: u32, key: &str, value: &str) {
        self.string_attrs
            .entry(province_id)
            .or_default()
            .insert(key.to_string(), value.to_string());
    }

    /// Get the named string attribute for a province, or `None` if not set.
    pub fn get_string(&self, province_id: u32, key: &str) -> Option<&str> {
        self.string_attrs
            .get(&province_id)?
            .get(key)
            .map(|s| s.as_str())
    }

    /// Set or clear a bitfield flag (0-63) for the given province.
    pub fn set_flag(&mut self, province_id: u32, bit: u8, value: bool) {
        let flags = self.flags.entry(province_id).or_insert(0);
        if value {
            *flags |= 1u64 << (bit.min(63));
        } else {
            *flags &= !(1u64 << (bit.min(63)));
        }
    }

    /// Return `true` if the specified bitfield flag is set for the given province.
    pub fn has_flag(&self, province_id: u32, bit: u8) -> bool {
        self.flags
            .get(&province_id)
            .is_some_and(|f| f & (1u64 << (bit.min(63))) != 0)
    }

    /// Remove all numeric, string, and flag data stored for the given province.
    pub fn clear_province(&mut self, province_id: u32) {
        self.numeric.remove(&province_id);
        self.string_attrs.remove(&province_id);
        self.flags.remove(&province_id);
    }

    /// Return a sorted list of all province IDs that have any stored properties.
    pub fn province_ids(&self) -> Vec<u32> {
        let mut ids: std::collections::HashSet<u32> = self.numeric.keys().copied().collect();
        ids.extend(self.string_attrs.keys());
        ids.extend(self.flags.keys());
        let mut v: Vec<u32> = ids.into_iter().collect();
        v.sort_unstable();
        v
    }
}

impl Default for ProvinceProperties {
    fn default() -> Self {
        Self::new()
    }
}
