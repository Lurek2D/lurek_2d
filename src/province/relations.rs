//! Generic configurable relation system for organizations.
//!
//! Relations store a numeric value between two organizations, plus optional
//! named-state fields (e.g. military stance, trade status).

use std::collections::HashMap;

/// Definition of a named relation type with a fixed set of valid level strings.
///
/// # Example
/// ```text
/// define_type("military", &["war","neutral","truce","alliance"], "neutral")
/// ```
#[derive(Debug, Clone)]
pub struct RelationType {
    /// Name of this relation type (e.g. `"military"`, `"economic"`).
    pub name: String,
    /// Valid level strings for this type.
    pub levels: Vec<String>,
    /// The default level applied when no explicit level has been set.
    pub default_level: String,
}

impl RelationType {
    /// Create a new relation type. Panics in debug if `default_level` is not in `levels`.
    pub fn new(name: &str, levels: Vec<String>, default_level: &str) -> Self {
        debug_assert!(
            levels.iter().any(|l| l == default_level),
            "default_level '{default_level}' must be one of the declared levels"
        );
        Self {
            name: name.to_string(),
            levels,
            default_level: default_level.to_string(),
        }
    }

    /// Return `true` if `level` is a valid level for this type.
    pub fn has_level(&self, level: &str) -> bool {
        self.levels.iter().any(|l| l == level)
    }
}

/// A relation between two organizations: numeric value plus per-type named levels.
///
/// The relation is keyed as `(min(a, b), max(a, b))` so that `A↔B` and `B↔A` share
/// the same record. Code using [`RelationManager`] does not need to sort the IDs.
#[derive(Debug, Clone)]
pub struct Relation {
    /// First org ID (lower of the two).
    pub from_org: u64,
    /// Second org ID (higher of the two).
    pub to_org: u64,
    /// The generic numeric relation value (e.g. −100 = total war, +100 = alliance).
    pub value: f64,
    /// Per-type named states: `type_name → level_string`.
    pub type_levels: HashMap<String, String>,
}

impl Relation {
    fn new(a: u64, b: u64) -> Self {
        let (from_org, to_org) = ordered(a, b);
        Self {
            from_org,
            to_org,
            value: 0.0,
            type_levels: HashMap::new(),
        }
    }
}

/// Manages all relation types and the per-pair relation records.
#[derive(Debug, Default)]
pub struct RelationManager {
    types: HashMap<String, RelationType>,
    relations: HashMap<(u64, u64), Relation>,
}

/// Normalize a pair so the lower ID is always first.
#[inline]
fn ordered(a: u64, b: u64) -> (u64, u64) {
    if a <= b {
        (a, b)
    } else {
        (b, a)
    }
}

impl RelationManager {
    /// Create a new empty manager.
    pub fn new() -> Self {
        Self::default()
    }

    // ── Type definitions ────────────────────────────────────────────────────

    /// Define a named relation type with a set of valid levels.
    ///
    /// Replaces any existing type with the same name.
    pub fn define_type(&mut self, name: &str, levels: Vec<String>, default_level: &str) {
        self.types
            .insert(name.to_string(), RelationType::new(name, levels, default_level));
    }

    /// Remove a relation type. Returns `true` if it existed.
    pub fn remove_type(&mut self, name: &str) -> bool {
        self.types.remove(name).is_some()
    }

    /// Get a reference to a relation type definition.
    pub fn get_type(&self, name: &str) -> Option<&RelationType> {
        self.types.get(name)
    }

    /// Get the names of all defined relation types.
    pub fn type_names(&self) -> Vec<String> {
        self.types.keys().cloned().collect()
    }

    // ── Value ────────────────────────────────────────────────────────────────

    /// Get the relation record for a pair (creating it at zero if absent).
    fn ensure(&mut self, a: u64, b: u64) -> &mut Relation {
        let key = ordered(a, b);
        self.relations.entry(key).or_insert_with(|| Relation::new(a, b))
    }

    /// Get the numeric relation value between two organizations.
    pub fn get_value(&self, a: u64, b: u64) -> f64 {
        self.relations
            .get(&ordered(a, b))
            .map(|r| r.value)
            .unwrap_or(0.0)
    }

    /// Set the numeric relation value between two organizations.
    pub fn set_value(&mut self, a: u64, b: u64, value: f64) {
        self.ensure(a, b).value = value;
    }

    /// Adjust the numeric relation value by `delta`.
    pub fn adjust_value(&mut self, a: u64, b: u64, delta: f64) {
        let rel = self.ensure(a, b);
        rel.value += delta;
    }

    // ── Named levels ────────────────────────────────────────────────────────

    /// Set the named level for a relation type between two orgs.
    ///
    /// Returns `false` if the type is unknown or the level is not valid for that type.
    pub fn set_level(&mut self, a: u64, b: u64, type_name: &str, level: &str) -> bool {
        match self.types.get(type_name) {
            None => false,
            Some(t) if !t.has_level(level) => false,
            Some(_) => {
                self.ensure(a, b)
                    .type_levels
                    .insert(type_name.to_string(), level.to_string());
                true
            }
        }
    }

    /// Get the level for a relation type between two orgs.
    ///
    /// Falls back to the type's `default_level` if no explicit level has been set.
    /// Returns `None` if the type name is unknown.
    pub fn get_level(&self, a: u64, b: u64, type_name: &str) -> Option<String> {
        let def = self.types.get(type_name)?.default_level.clone();
        let level = self
            .relations
            .get(&ordered(a, b))
            .and_then(|r| r.type_levels.get(type_name))
            .cloned()
            .unwrap_or(def);
        Some(level)
    }

    // ── Query ────────────────────────────────────────────────────────────────

    /// Get all relations involving a given organization.
    pub fn all_relations_for(&self, org_id: u64) -> Vec<&Relation> {
        self.relations
            .values()
            .filter(|r| r.from_org == org_id || r.to_org == org_id)
            .collect()
    }

    /// Get all relations as an iterator.
    pub fn all_relations(&self) -> impl Iterator<Item = &Relation> {
        self.relations.values()
    }
}
