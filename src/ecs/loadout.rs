//! Owns generic loadout, slot, part, and stat aggregation data for ECS-authored units.
//! This keeps modular unit composition inside the existing ECS feature boundary while
//! exposing deterministic validation and derived stats to Lua bindings and tests.

use std::collections::{BTreeMap, BTreeSet};

/// Numeric stat collection produced by equipped parts and base values.
#[derive(Debug, Clone, Default, PartialEq)]
pub struct StatBlock {
    /// Stable stat values keyed by stat name.
    pub values: BTreeMap<String, f64>,
}

impl StatBlock {
    /// Create an empty stat block.
    pub fn new() -> Self {
        Self::default()
    }

    /// Add `value` to one stat key.
    pub fn add(&mut self, key: impl Into<String>, value: f64) {
        let key = key.into();
        *self.values.entry(key).or_insert(0.0) += value;
    }

    /// Return a stat value, or zero when it is absent.
    pub fn get(&self, key: &str) -> f64 {
        self.values.get(key).copied().unwrap_or(0.0)
    }

    /// Merge another block into this block by adding matching keys.
    pub fn merge(&mut self, other: &StatBlock) {
        for (key, value) in &other.values {
            self.add(key.clone(), *value);
        }
    }
}

/// One compatible equipment slot in a loadout.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct SlotDef {
    /// Slot identifier used by equip and unequip calls.
    pub name: String,
    /// Accepted compatibility tags. Empty means any part can be equipped.
    pub accepts: BTreeSet<String>,
    /// Whether validation reports an empty slot as an error.
    pub required: bool,
    /// Optional hardpoint name exposed for weapon or visual mounting.
    pub hardpoint: Option<String>,
}

impl SlotDef {
    /// Create a slot definition.
    pub fn new(name: impl Into<String>) -> Self {
        Self {
            name: name.into(),
            accepts: BTreeSet::new(),
            required: false,
            hardpoint: None,
        }
    }

    /// Return true when this slot accepts the supplied part.
    pub fn accepts_part(&self, part: &PartDef) -> bool {
        if !part.slot.is_empty() && part.slot != self.name {
            return false;
        }
        self.accepts.is_empty() || part.tags.iter().any(|tag| self.accepts.contains(tag))
    }
}

/// Data-only definition of one loadout part.
#[derive(Debug, Clone, PartialEq)]
pub struct PartDef {
    /// Stable part identifier.
    pub id: String,
    /// Preferred slot name. Empty means any compatible slot may receive it.
    pub slot: String,
    /// Compatibility tags used by slots.
    pub tags: BTreeSet<String>,
    /// Additive stat modifiers contributed while equipped.
    pub stats: StatBlock,
    /// Resource or production cost.
    pub cost: f64,
    /// Mass contribution.
    pub mass: f64,
    /// Energy capacity or drain contribution.
    pub energy: f64,
    /// Heat generation or capacity contribution.
    pub heat: f64,
    /// Armor contribution.
    pub armor: f64,
    /// Optional hardpoints exposed by this part.
    pub hardpoints: Vec<String>,
    /// Visual slot-to-attachment mapping used by sprite or spine helpers.
    pub visuals: BTreeMap<String, String>,
}

impl PartDef {
    /// Create a part definition with a stable id and preferred slot.
    pub fn new(id: impl Into<String>, slot: impl Into<String>) -> Self {
        Self {
            id: id.into(),
            slot: slot.into(),
            tags: BTreeSet::new(),
            stats: StatBlock::new(),
            cost: 0.0,
            mass: 0.0,
            energy: 0.0,
            heat: 0.0,
            armor: 0.0,
            hardpoints: Vec::new(),
            visuals: BTreeMap::new(),
        }
    }
}

/// Equipped parts and slot policy for one modular unit.
#[derive(Debug, Clone, Default, PartialEq)]
pub struct Loadout {
    /// Available slots keyed by slot name.
    pub slots: BTreeMap<String, SlotDef>,
    /// Equipped parts keyed by slot name.
    pub equipped: BTreeMap<String, PartDef>,
    /// Base stats added before part modifiers.
    pub base_stats: StatBlock,
}

impl Loadout {
    /// Create an empty loadout.
    pub fn new() -> Self {
        Self::default()
    }

    /// Add or replace one slot definition.
    pub fn add_slot(&mut self, slot: SlotDef) {
        self.slots.insert(slot.name.clone(), slot);
    }

    /// Equip `part` into `slot_name` after compatibility validation.
    pub fn equip(&mut self, slot_name: &str, part: PartDef) -> Result<(), String> {
        let slot = self
            .slots
            .get(slot_name)
            .ok_or_else(|| format!("unknown loadout slot '{slot_name}'"))?;
        if !slot.accepts_part(&part) {
            return Err(format!(
                "part '{}' is not compatible with slot '{slot_name}'",
                part.id
            ));
        }
        self.equipped.insert(slot_name.to_string(), part);
        Ok(())
    }

    /// Remove and return the part equipped in `slot_name`.
    pub fn unequip(&mut self, slot_name: &str) -> Option<PartDef> {
        self.equipped.remove(slot_name)
    }

    /// Return validation errors for missing or incompatible equipment.
    pub fn validate(&self) -> Vec<String> {
        let mut errors = Vec::new();
        for (name, slot) in &self.slots {
            match self.equipped.get(name) {
                Some(part) if !slot.accepts_part(part) => {
                    errors.push(format!(
                        "part '{}' is not compatible with slot '{name}'",
                        part.id
                    ));
                }
                None if slot.required => errors.push(format!("required slot '{name}' is empty")),
                _ => {}
            }
        }
        errors
    }

    /// Compute the additive stat block from base stats and equipped parts.
    pub fn compute_stats(&self) -> StatBlock {
        let mut out = self.base_stats.clone();
        for part in self.equipped.values() {
            out.merge(&part.stats);
            out.add("cost", part.cost);
            out.add("mass", part.mass);
            out.add("energy", part.energy);
            out.add("heat", part.heat);
            out.add("armor", part.armor);
        }
        out
    }

    /// Return total resource cost of equipped parts.
    pub fn get_cost(&self) -> f64 {
        self.equipped.values().map(|part| part.cost).sum()
    }

    /// Return all hardpoints exposed by slots and equipped parts.
    pub fn get_hardpoints(&self) -> Vec<String> {
        let mut out = Vec::new();
        for slot in self.slots.values() {
            if let Some(hardpoint) = &slot.hardpoint {
                out.push(hardpoint.clone());
            }
        }
        for part in self.equipped.values() {
            out.extend(part.hardpoints.iter().cloned());
        }
        out
    }
}
