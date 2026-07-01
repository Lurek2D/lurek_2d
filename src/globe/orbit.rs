//! Stores named globe orbit shells with deterministic ordering for render, picking, and marker placement.
//! Owns shell insertion, updates, visibility, attrs, and the special always-present surface shell contract.
//! Provides the state boundary between Lua-facing orbit configuration and the projection or draw code that consumes it.
//! This file matters when shell ordering, pickability, or orbit metadata drift out of sync across globe features.

use crate::globe::types::{GlobeOrbit, GlobeOrbitKind};
use std::collections::HashMap;

/// Canonical orbit name for the base globe surface shell.
pub const SURFACE_ORBIT_NAME: &str = "surface";

/// Named globe orbit collection keyed by orbit name.
#[derive(Debug, Clone)]
pub struct OrbitStore {
    /// Stored orbit shells by stable name.
    orbits: HashMap<String, GlobeOrbit>,
}

impl Default for OrbitStore {
    fn default() -> Self {
        let mut out = Self {
            orbits: HashMap::new(),
        };
        out.ensure_surface();
        out
    }
}

impl OrbitStore {
    /// Create an orbit store that already contains the canonical surface shell.
    pub fn new() -> Self {
        Self::default()
    }

    /// Return the immutable surface shell definition.
    pub fn surface(&self) -> &GlobeOrbit {
        self.get(SURFACE_ORBIT_NAME)
            .expect("surface orbit must always exist")
    }

    /// Return a shared orbit definition when it exists.
    pub fn get(&self, name: &str) -> Option<&GlobeOrbit> {
        self.orbits.get(name)
    }

    /// Return a mutable orbit definition when it exists.
    pub fn get_mut(&mut self, name: &str) -> Option<&mut GlobeOrbit> {
        self.orbits.get_mut(name)
    }

    /// Insert or replace one orbit after validation.
    pub fn upsert(&mut self, mut orbit: GlobeOrbit) -> Result<(), String> {
        orbit.name = orbit.name.trim().to_string();
        if orbit.name.is_empty() {
            return Err("orbit name must not be empty".to_string());
        }
        if !orbit.altitude_px.is_finite() || orbit.altitude_px < 0.0 {
            return Err(format!(
                "orbit '{}' altitude_px must be finite and >= 0",
                orbit.name
            ));
        }
        if !orbit.width_px.is_finite() || orbit.width_px < 0.0 {
            return Err(format!(
                "orbit '{}' width_px must be finite and >= 0",
                orbit.name
            ));
        }
        if orbit.name == SURFACE_ORBIT_NAME {
            orbit.altitude_px = 0.0;
            orbit.kind = GlobeOrbitKind::Surface;
        }
        self.orbits.insert(orbit.name.clone(), orbit);
        self.ensure_surface();
        Ok(())
    }

    /// Remove one orbit and return the removed definition when it existed.
    pub fn remove(&mut self, name: &str) -> Option<GlobeOrbit> {
        if name == SURFACE_ORBIT_NAME {
            return None;
        }
        let removed = self.orbits.remove(name);
        self.ensure_surface();
        removed
    }

    /// Set orbit visibility and return true when the orbit exists.
    pub fn set_visible(&mut self, name: &str, visible: bool) -> bool {
        if let Some(orbit) = self.orbits.get_mut(name) {
            orbit.visible = visible;
            true
        } else {
            false
        }
    }

    /// Set one string attribute on an orbit and return true when the orbit exists.
    pub fn set_attr(&mut self, name: &str, key: String, value: String) -> bool {
        if let Some(orbit) = self.orbits.get_mut(name) {
            orbit.attrs.insert(key, value);
            true
        } else {
            false
        }
    }

    /// Read one string attribute from an orbit.
    pub fn get_attr(&self, name: &str, key: &str) -> Option<&str> {
        self.orbits.get(name)?.attrs.get(key).map(String::as_str)
    }

    /// Return orbit names sorted by z-order and name for deterministic iteration.
    pub fn names_sorted(&self) -> Vec<String> {
        let mut names: Vec<String> = self.orbits.keys().cloned().collect();
        names.sort_by(|a, b| {
            let ao = self
                .orbits
                .get(a)
                .map(|orbit| (orbit.z_order, orbit.altitude_px))
                .unwrap_or((0, 0.0));
            let bo = self
                .orbits
                .get(b)
                .map(|orbit| (orbit.z_order, orbit.altitude_px))
                .unwrap_or((0, 0.0));
            ao.0.cmp(&bo.0)
                .then_with(|| ao.1.total_cmp(&bo.1))
                .then_with(|| a.cmp(b))
        });
        names
    }

    /// Return shared orbit references sorted by z-order and name for deterministic iteration.
    pub fn sorted(&self) -> Vec<&GlobeOrbit> {
        let mut out: Vec<&GlobeOrbit> = self.orbits.values().collect();
        out.sort_by(|a, b| {
            a.z_order
                .cmp(&b.z_order)
                .then_with(|| a.altitude_px.total_cmp(&b.altitude_px))
                .then_with(|| a.name.cmp(&b.name))
        });
        out
    }

    /// Return only visible orbit references sorted for deterministic iteration.
    pub fn visible_sorted(&self) -> Vec<&GlobeOrbit> {
        self.sorted()
            .into_iter()
            .filter(|orbit| orbit.visible)
            .collect()
    }

    /// Return the number of stored orbit shells.
    pub fn len(&self) -> usize {
        self.orbits.len()
    }

    /// Return true when only the canonical surface shell is present.
    pub fn is_empty(&self) -> bool {
        self.orbits.len() <= 1 && self.orbits.contains_key(SURFACE_ORBIT_NAME)
    }

    /// Ensure the canonical surface shell always exists.
    pub fn ensure_surface(&mut self) {
        self.orbits
            .entry(SURFACE_ORBIT_NAME.to_string())
            .or_insert_with(GlobeOrbit::surface);
    }
}
