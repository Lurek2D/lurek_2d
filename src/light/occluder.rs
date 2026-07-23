//! This file owns `Occluder`, the convex polygon shadow caster used by `LightWorld` to block and mask lighting.
//! It stores local vertices, world offset, opacity, layer mask, and enabled state for runtime shadow participation.
//! Construction helpers validate vertex counts and support both typed point lists and flat coordinate arrays.
//! Tracks geometry generations so render caches can reuse transformed edge data until shadow geometry changes.
//! Open this file when shadow-geometry semantics change; light collection logic and filter presets live in siblings.

use crate::math::Vec2;

/// Convex polygon shape that blocks light and casts shadows in `LightWorld`.
/// # Fields
pub struct Occluder {
    /// Polygon vertices in local space; must be 3..=512 elements.
    pub vertices: Vec<Vec2>,
    /// World-space offset applied to all vertices during shadow projection.
    pub position: Vec2,
    /// Shadow opacity in [0.0, 1.0]; 1.0 = fully opaque, 0.0 = transparent.
    pub opacity: f32,
    /// Bitmask selecting which lights this occluder casts shadows for.
    pub light_mask: u16,
    /// Whether this occluder participates in shadow computation; when false, it is skipped.
    pub enabled: bool,
    /// Monotonic generation for local vertices and world-space position used by shadow edge caches.
    edge_generation: u64,
}
impl Occluder {
    /// Create an occluder after validating finite convex-polygon vertices.
    pub fn try_new(vertices: Vec<Vec2>) -> Result<Self, String> {
        Self::validate_vertices(&vertices)?;
        Ok(Self {
            vertices,
            position: Vec2::ZERO,
            opacity: 1.0,
            light_mask: 0xFFFF,
            enabled: true,
            edge_generation: 0,
        })
    }
    /// Replace vertices after validation, leaving this occluder unchanged on error.
    pub fn try_set_vertices(&mut self, vertices: Vec<Vec2>) -> Result<(), String> {
        Self::validate_vertices(&vertices)?;
        if self.vertices != vertices {
            self.vertices = vertices;
            self.bump_edge_generation();
        }
        Ok(())
    }
    /// Build an occluder from a flat `[x, y, x, y, ...]` coordinate slice; returns error on invalid length.
    pub fn from_flat_coords(flat: &[f32]) -> Result<Self, String> {
        if flat.len() < 6 || flat.len() > 1024 || !flat.len().is_multiple_of(2) {
            return Err(format!(
                "vertex array must have 6..=1024 coordinates (3..=512 vertices), got {}",
                flat.len()
            ));
        }
        let verts: Vec<Vec2> = flat.chunks(2).map(|c| Vec2::new(c[0], c[1])).collect();
        Self::try_new(verts)
    }
    /// Return the vertex slice. This function is part of the public API.
    pub fn get_vertices(&self) -> &[Vec2] {
        &self.vertices
    }
    /// Set the world-space position offset.
    pub fn set_position(&mut self, position: Vec2) {
        if self.position != position {
            self.position = position;
            self.bump_edge_generation();
        }
    }
    /// Return the world-space position offset.
    pub fn get_position(&self) -> Vec2 {
        self.position
    }
    /// Set shadow opacity; expected range [0.0, 1.0].
    pub fn set_opacity(&mut self, opacity: f32) {
        self.opacity = opacity;
    }
    /// Return shadow opacity. This function is part of the public API.
    pub fn get_opacity(&self) -> f32 {
        self.opacity
    }
    /// Set the light-layer bitmask.
    pub fn set_light_mask(&mut self, mask: u16) {
        self.light_mask = mask;
    }
    /// Return the light-layer bitmask.
    pub fn get_light_mask(&self) -> u16 {
        self.light_mask
    }
    /// Enable or disable this occluder.
    pub fn set_enabled(&mut self, enabled: bool) {
        self.enabled = enabled;
    }
    /// Return whether this occluder is enabled.
    pub fn is_enabled(&self) -> bool {
        self.enabled
    }

    /// Return the geometry generation used to invalidate cached shadow edges.
    pub fn edge_generation(&self) -> u64 {
        self.edge_generation
    }

    fn validate_vertices(vertices: &[Vec2]) -> Result<(), String> {
        if !(3..=512).contains(&vertices.len()) {
            return Err(format!(
                "vertex count must be 3..=512, got {}",
                vertices.len()
            ));
        }
        if vertices
            .iter()
            .any(|v| !v.x.is_finite() || !v.y.is_finite())
        {
            return Err("vertex coordinates must be finite".to_string());
        }
        let mut winding = 0.0_f32;
        for index in 0..vertices.len() {
            let a = vertices[index];
            let b = vertices[(index + 1) % vertices.len()];
            let c = vertices[(index + 2) % vertices.len()];
            let ab_x = b.x - a.x;
            let ab_y = b.y - a.y;
            let bc_x = c.x - b.x;
            let bc_y = c.y - b.y;
            let cross = ab_x * bc_y - ab_y * bc_x;
            if cross.abs() <= f32::EPSILON {
                return Err("polygon must not contain repeated or collinear vertices".to_string());
            }
            if winding != 0.0 && cross.signum() != winding.signum() {
                return Err("polygon must be convex with one winding direction".to_string());
            }
            winding = cross;
        }
        Ok(())
    }

    fn bump_edge_generation(&mut self) {
        self.edge_generation = self.edge_generation.checked_add(1).unwrap_or(0);
    }
}
