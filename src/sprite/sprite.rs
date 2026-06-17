//! This file defines the lightweight single-sprite record used when one textured image instance needs position, transform, and tint data.
//! It is intentionally small because many systems want sprite-like draw data without carrying atlas, animation, or batching machinery.
//! Optional normal-map metadata lives here as sprite-owned lighting data even when the renderer path is handled elsewhere. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `set_position`, `set_scale`, `set_rotation`, `set_color`, `set_normal_map`, and 5 more stays attached to the local data model and invariants.
//! The type is the simplest textured presentation unit in the sprite subsystem. Runtime integration reaches sibling engine areas through crate modules `color`, `math`, which explains the subsystem dependencies an agent should inspect before changing behavior.

use crate::color::Color;
use crate::math::Vec2;

/// A single drawable texture instance with position, scale, rotation, and colour tint.
pub struct Sprite {
    /// Index of the texture resource used to draw this sprite.
    pub texture_id: usize,
    /// World-space position of the sprite anchor in pixels.
    pub position: Vec2,
    /// Non-uniform scale applied to the sprite dimensions; (1, 1) = no scale.
    pub scale: Vec2,
    /// Rotation angle in radians counter-clockwise around the anchor.
    pub rotation: f32,
    /// Colour tint multiplied with the texture samples; WHITE = no tint.
    pub color: Color,
    /// Optional texture resource used as the sprite's normal map.
    pub normal_map_texture_id: Option<usize>,
    /// Strength multiplier applied when the normal map is used for lit sprite shading.
    pub normal_intensity: f32,
}
/// Constructor and transform setters for Sprite.
impl Sprite {
    /// Create a sprite at position with identity scale, zero rotation, and white tint.
    pub fn new(texture_id: usize, position: Vec2) -> Self {
        Sprite {
            texture_id,
            position,
            scale: Vec2::ONE,
            rotation: 0.0,
            color: Color::WHITE,
            normal_map_texture_id: None,
            normal_intensity: 1.0,
        }
    }
    /// Set the world-space position to (x, y).
    pub fn set_position(&mut self, x: f32, y: f32) {
        self.position = Vec2::new(x, y);
    }
    /// Set the non-uniform scale to (sx, sy).
    pub fn set_scale(&mut self, sx: f32, sy: f32) {
        self.scale = Vec2::new(sx, sy);
    }
    /// Set the rotation angle in radians.
    pub fn set_rotation(&mut self, rotation: f32) {
        self.rotation = rotation;
    }
    /// Replace the colour tint. This function is part of the public API.
    pub fn set_color(&mut self, color: Color) {
        self.color = color;
    }

    /// Attach a normal-map texture to this sprite for lit-sprite shading.
    pub fn set_normal_map(&mut self, texture_id: usize) {
        self.normal_map_texture_id = Some(texture_id);
    }

    /// Remove the currently assigned normal map.
    pub fn clear_normal_map(&mut self) {
        self.normal_map_texture_id = None;
    }

    /// Return the currently assigned normal-map texture, if any.
    pub fn get_normal_map(&self) -> Option<usize> {
        self.normal_map_texture_id
    }

    /// Return true when a normal map is assigned.
    pub fn has_normal_map(&self) -> bool {
        self.normal_map_texture_id.is_some()
    }

    /// Set the intensity multiplier applied to the normal map.
    pub fn set_normal_intensity(&mut self, intensity: f32) {
        self.normal_intensity = intensity.max(0.0);
    }

    /// Return the intensity multiplier applied to the normal map.
    pub fn get_normal_intensity(&self) -> f32 {
        self.normal_intensity
    }
}
