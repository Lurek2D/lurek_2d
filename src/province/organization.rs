//! Generic organization system for the province module.
//!
//! Organizations are entities that can control provinces (physical) or exist without
//! province ownership (virtual). Multiple organizations can overlap on a province.

use std::collections::{HashMap, HashSet};

use super::properties::ProvinceValue;

/// An organization entity — nation, faction, company, alliance, religion, etc.
///
/// Physical organizations control provinces. Virtual organizations exist without
/// requiring province ownership (e.g., religions, trade networks, guilds).
#[derive(Debug, Clone)]
pub struct Organization {
    /// Unique numeric ID assigned by [`OrganizationManager`].
    pub id: u64,
    /// Human-readable name.
    pub name: String,
    /// Game-developer-defined type tag (e.g. `"nation"`, `"guild"`, `"religion"`).
    pub org_type: String,
    /// When `true`, this org can own provinces and the province→org index is maintained.
    pub is_physical: bool,
    /// Set of province IDs this organization controls. Only meaningful when `is_physical`.
    pub province_ids: HashSet<u32>,
    /// The "capital" province — the org's administrative center.
    pub capital_province: Option<u32>,
    /// Generic key-value properties (same value type as province properties).
    pub properties: HashMap<String, ProvinceValue>,
}

impl Organization {
    /// Create a new organization with no provinces and no properties.
    pub fn new(id: u64, name: &str, org_type: &str, is_physical: bool) -> Self {
        Self {
            id,
            name: name.to_string(),
            org_type: org_type.to_string(),
            is_physical,
            province_ids: HashSet::new(),
            capital_province: None,
            properties: HashMap::new(),
        }
    }
}

/// Manages all organizations and the province → org membership reverse index.
#[derive(Debug, Default)]
pub struct OrganizationManager {
    next_id: u64,
    orgs: HashMap<u64, Organization>,
    /// Reverse index: province_id → set of org IDs that include it.
    province_members: HashMap<u32, HashSet<u64>>,
}

impl OrganizationManager {
    /// Create a new empty manager.
    pub fn new() -> Self {
        Self::default()
    }

    // ── CRUD ────────────────────────────────────────────────────────────────

    /// Create a new organization and return its assigned ID.
    pub fn create(&mut self, name: &str, org_type: &str, is_physical: bool) -> u64 {
        self.next_id += 1;
        let id = self.next_id;
        self.orgs
            .insert(id, Organization::new(id, name, org_type, is_physical));
        id
    }

    /// Remove an organization, cleaning up all province memberships. Returns `true` if removed.
    pub fn remove(&mut self, id: u64) -> bool {
        if let Some(org) = self.orgs.remove(&id) {
            for pid in &org.province_ids {
                if let Some(set) = self.province_members.get_mut(pid) {
                    set.remove(&id);
                }
            }
            true
        } else {
            false
        }
    }

    /// Get an organization by ID.
    pub fn get(&self, id: u64) -> Option<&Organization> {
        self.orgs.get(&id)
    }

    /// Get a mutable reference to an organization.
    pub fn get_mut(&mut self, id: u64) -> Option<&mut Organization> {
        self.orgs.get_mut(&id)
    }

    /// Get all organization IDs in an unspecified order.
    pub fn all_ids(&self) -> Vec<u64> {
        self.orgs.keys().copied().collect()
    }

    // ── Province membership ──────────────────────────────────────────────────

    /// Assign a province to an organization. Returns `false` if the org does not exist.
    pub fn assign_province(&mut self, org_id: u64, province_id: u32) -> bool {
        if let Some(org) = self.orgs.get_mut(&org_id) {
            org.province_ids.insert(province_id);
            self.province_members
                .entry(province_id)
                .or_default()
                .insert(org_id);
            true
        } else {
            false
        }
    }

    /// Remove a province from an organization. Returns `true` if it was present.
    pub fn unassign_province(&mut self, org_id: u64, province_id: u32) -> bool {
        if let Some(org) = self.orgs.get_mut(&org_id) {
            let removed = org.province_ids.remove(&province_id);
            if removed {
                if let Some(set) = self.province_members.get_mut(&province_id) {
                    set.remove(&org_id);
                }
            }
            removed
        } else {
            false
        }
    }

    /// Set the capital province of an organization. Returns `false` if org not found
    /// or if the province does not belong to this organization.
    pub fn set_capital(&mut self, org_id: u64, province_id: u32) -> bool {
        if let Some(org) = self.orgs.get_mut(&org_id) {
            if org.province_ids.contains(&province_id) {
                org.capital_province = Some(province_id);
                true
            } else {
                false
            }
        } else {
            false
        }
    }

    /// Get all org IDs that have claimed the given province.
    pub fn orgs_in_province(&self, province_id: u32) -> Vec<u64> {
        self.province_members
            .get(&province_id)
            .map(|s| s.iter().copied().collect())
            .unwrap_or_default()
    }

    /// Get all province IDs belonging to an organization.
    pub fn provinces_of_org(&self, org_id: u64) -> Vec<u32> {
        self.orgs
            .get(&org_id)
            .map(|o| o.province_ids.iter().copied().collect())
            .unwrap_or_default()
    }

    // ── Properties ──────────────────────────────────────────────────────────

    /// Set a property on an organization. Returns `false` if org not found.
    pub fn set_property(&mut self, org_id: u64, key: String, value: ProvinceValue) -> bool {
        if let Some(org) = self.orgs.get_mut(&org_id) {
            org.properties.insert(key, value);
            true
        } else {
            false
        }
    }

    /// Get a property from an organization.
    pub fn get_property(&self, org_id: u64, key: &str) -> Option<&ProvinceValue> {
        self.orgs.get(&org_id)?.properties.get(key)
    }

    // ── Convenience ─────────────────────────────────────────────────────────

    /// Return the ID of the "primary" physical organization controlling a province.
    ///
    /// Primary is defined as the physical org with the lowest ID. Returns `None`
    /// if no physical org controls the province.
    pub fn primary_org(&self, province_id: u32) -> Option<u64> {
        self.province_members
            .get(&province_id)?
            .iter()
            .filter(|&&id| {
                self.orgs
                    .get(&id)
                    .map(|o| o.is_physical)
                    .unwrap_or(false)
            })
            .copied()
            .min()
    }
}
