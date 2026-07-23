//! This file owns `Sprite`, the minimal textured instance record for transform, tint, and optional normal-map state.
//! It stores render-facing fields directly on one struct so systems can pass lightweight draw data without atlas owners.
//! Setters here mutate position, scale, rotation, color, and normal-map properties while math helpers stay delegated.
//! Open this file when per-sprite draw state changes; animation playback and grouped submission live elsewhere.

use crate::color::Color;
use crate::math::Vec2;
use crate::runtime::resource_keys::ShaderKey;

/// # Fields
///
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
    /// Optional render-owned shader material applied by sprite workflows.
    pub shader: Option<ShaderKey>,
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
            shader: None,
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

    /// Attach or clear the render-owned shader material for this sprite.
    pub fn set_shader(&mut self, shader: Option<ShaderKey>) {
        self.shader = shader;
    }

    /// Return the render-owned shader material bound to this sprite, if any.
    pub fn get_shader(&self) -> Option<ShaderKey> {
        self.shader
    }
}
