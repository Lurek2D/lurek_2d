//! Stores globe markers with stable ids so pins and point annotations can be added, moved, filtered, and rendered.
//! Owns marker lookup, visibility, arbitrary string attrs, and typed grouping by marker classification name.
//! Provides the state boundary between gameplay marker semantics and draw or picking code that consumes marker data.
//! Keeps iteration and id assignment deterministic so UI, render, and sync systems see stable marker identity.
//! Open this owner when marker lifecycle, filtering, or per-marker metadata behavior needs adjustment.

use crate::globe::orbit::SURFACE_ORBIT_NAME;
use crate::globe::types::{Marker, MarkerStyle};
use std::collections::HashMap;

/// Authored marker placement payload shared by registry validation and marker storage.
#[derive(Debug, Clone)]
pub struct MarkerPlacement {
    /// Marker category used by lookup and styling.
    pub marker_type: String,
    /// Latitude in degrees.
    pub lat_deg: f32,
    /// Longitude in degrees.
    pub lon_deg: f32,
    /// Named shell that owns this marker.
    pub orbit: String,
    /// Optional offset above the owning shell.
    pub altitude_px: Option<f32>,
    /// Optional marker label text.
    pub label: Option<String>,
    /// Visual style used when drawing the marker.
    pub style: MarkerStyle,
}

impl MarkerPlacement {
    /// Build a placement on the canonical surface shell.
    pub fn surface(
        marker_type: impl Into<String>,
        lat_deg: f32,
        lon_deg: f32,
        label: Option<String>,
        style: MarkerStyle,
    ) -> Self {
        Self {
            marker_type: marker_type.into(),
            lat_deg,
            lon_deg,
            orbit: SURFACE_ORBIT_NAME.to_string(),
            altitude_px: None,
            label,
            style,
        }
    }

    /// Build a placement on one named orbit shell.
    pub fn orbit(
        marker_type: impl Into<String>,
        lat_deg: f32,
        lon_deg: f32,
        orbit: impl Into<String>,
        altitude_px: Option<f32>,
        label: Option<String>,
        style: MarkerStyle,
    ) -> Self {
        Self {
            marker_type: marker_type.into(),
            lat_deg,
            lon_deg,
            orbit: orbit.into(),
            altitude_px,
            label,
            style,
        }
    }
}

/// Marker collection keyed by stable id.
#[derive(Debug, Clone, Default)]
pub struct MarkerStore {
    /// Stored markers by id.
    markers: HashMap<u32, Marker>,
    /// Next marker id to assign.
    next_id: u32,
}
impl MarkerStore {
    /// Create an empty marker store.
    pub fn new() -> Self {
        Self::default()
    }
    /// Insert a marker and return its assigned id.
    pub fn add(
        &mut self,
        marker_type: impl Into<String>,
        lat_deg: f32,
        lon_deg: f32,
        label: Option<String>,
        style: MarkerStyle,
    ) -> u32 {
        self.add_with_placement(MarkerPlacement::surface(
            marker_type,
            lat_deg,
            lon_deg,
            label,
            style,
        ))
    }

    /// Insert a marker on one named shell and return its assigned id.
    pub fn add_with_placement(&mut self, placement: MarkerPlacement) -> u32 {
        let MarkerPlacement {
            marker_type,
            lat_deg,
            lon_deg,
            orbit,
            altitude_px,
            label,
            style,
        } = placement;
        let id = self.next_id;
        self.next_id += 1;
        self.markers.insert(
            id,
            Marker {
                id,
                marker_type,
                lat_deg,
                lon_deg,
                orbit,
                altitude_px,
                label,
                visible: true,
                style,
                attrs: HashMap::new(),
            },
        );
        id
    }
    /// Remove a marker by id and return it when found.
    pub fn remove(&mut self, id: u32) -> Option<Marker> {
        self.markers.remove(&id)
    }
    /// Return a shared marker reference when the id exists.
    pub fn get(&self, id: u32) -> Option<&Marker> {
        self.markers.get(&id)
    }
    /// Return a mutable marker reference when the id exists.
    pub fn get_mut(&mut self, id: u32) -> Option<&mut Marker> {
        self.markers.get_mut(&id)
    }
    /// Move a marker and return true when the id exists.
    pub fn move_to(&mut self, id: u32, lat_deg: f32, lon_deg: f32) -> bool {
        if let Some(m) = self.markers.get_mut(&id) {
            m.lat_deg = lat_deg;
            m.lon_deg = lon_deg;
            true
        } else {
            false
        }
    }
    /// Reassign a marker to a different named shell and return true when the id exists.
    pub fn set_orbit(&mut self, id: u32, orbit: String) -> bool {
        if let Some(m) = self.markers.get_mut(&id) {
            m.orbit = orbit;
            true
        } else {
            false
        }
    }
    /// Set or clear a marker-specific shell offset and return true when the id exists.
    pub fn set_altitude(&mut self, id: u32, altitude_px: Option<f32>) -> bool {
        if let Some(m) = self.markers.get_mut(&id) {
            m.altitude_px = altitude_px;
            true
        } else {
            false
        }
    }
    /// Set marker visibility and return true when the id exists.
    pub fn set_visible(&mut self, id: u32, visible: bool) -> bool {
        if let Some(m) = self.markers.get_mut(&id) {
            m.visible = visible;
            true
        } else {
            false
        }
    }
    /// Set a string attribute and return true when the id exists.
    pub fn set_attr(&mut self, id: u32, key: String, value: String) -> bool {
        if let Some(m) = self.markers.get_mut(&id) {
            m.attrs.insert(key, value);
            true
        } else {
            false
        }
    }
    /// Return a string attribute for a marker when it exists.
    pub fn get_attr(&self, id: u32, key: &str) -> Option<&str> {
        self.markers.get(&id)?.attrs.get(key).map(String::as_str)
    }
    /// Iterate over all stored markers.
    pub fn iter(&self) -> impl Iterator<Item = &Marker> {
        self.markers.values()
    }
    /// Iterate over visible markers only.
    pub fn iter_visible(&self) -> impl Iterator<Item = &Marker> {
        self.markers.values().filter(|m| m.visible)
    }
    /// Iterate over all markers sorted by id for deterministic render and pick order.
    pub fn iter_sorted(&self) -> Vec<&Marker> {
        let mut out: Vec<&Marker> = self.markers.values().collect();
        out.sort_by_key(|marker| marker.id);
        out
    }
    /// Iterate over visible markers sorted by id for deterministic render and pick order.
    pub fn iter_visible_sorted(&self) -> Vec<&Marker> {
        let mut out: Vec<&Marker> = self
            .markers
            .values()
            .filter(|marker| marker.visible)
            .collect();
        out.sort_by_key(|marker| marker.id);
        out
    }
    /// Return all markers whose type matches the supplied string.
    pub fn by_type(&self, marker_type: &str) -> Vec<&Marker> {
        self.markers
            .values()
            .filter(|m| m.marker_type == marker_type)
            .collect()
    }
    /// Return the number of stored markers.
    pub fn len(&self) -> usize {
        self.markers.len()
    }
    /// Return true when no markers are stored.
    pub fn is_empty(&self) -> bool {
        self.markers.is_empty()
    }
}
