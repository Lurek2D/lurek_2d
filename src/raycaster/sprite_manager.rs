//! This file manages world-space billboard content that should appear inside the raycast view without becoming part of the wall grid.
//! It keeps sprite placement, identity, and visibility data in one registry so gameplay systems can add props, pickups, or actors cheaply.
//! When the camera needs them, sprites are exposed in depth-aware order that fits alpha-friendly first-person rendering. Public callable behavior is centered on no named public items, while method-level behavior such as `select_for_viewer`, `new`, `add`, `add_directional`, `remove`, `set_position`, and 6 more stays attached to the local data model and invariants.
//! The registry therefore acts as the dynamic object layer that rides on top of static map geometry. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.
//! `raycaster/sprite_manager` delivers the sprite manager implementation for the raycaster subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

fn normalize_signed_angle(mut angle: f32) -> f32 {
    while angle > std::f32::consts::PI {
        angle -= 2.0 * std::f32::consts::PI;
    }
    while angle < -std::f32::consts::PI {
        angle += 2.0 * std::f32::consts::PI;
    }
    angle
}

/// Directional texture set for a sprite that should show different bitmaps by facing.
#[derive(Debug, Clone)]
pub struct DirectionalSpriteTextures {
    /// Texture path for the front-facing bitmap.
    pub front: String,
    /// Texture path for the right-facing bitmap.
    pub right: String,
    /// Texture path for the back-facing bitmap.
    pub back: String,
    /// Texture path for the left-facing bitmap.
    pub left: String,
    /// World-space angle of the sprite's front in radians.
    pub facing_angle: f32,
}

/// Which directional sprite bitmap was selected for the current viewer position.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DirectionalSpriteVariant {
    Front,
    Right,
    Back,
    Left,
}

impl DirectionalSpriteTextures {
    /// Resolve the texture path and variant to show from viewer position `(cam_x, cam_y)`.
    pub fn select_for_viewer(
        &self,
        cam_x: f32,
        cam_y: f32,
        sprite_x: f32,
        sprite_y: f32,
    ) -> (&str, DirectionalSpriteVariant) {
        let to_viewer = (cam_y - sprite_y).atan2(cam_x - sprite_x);
        let relative = normalize_signed_angle(to_viewer - self.facing_angle);
        let quarter_turn = std::f32::consts::FRAC_PI_4;
        let three_quarter_turn = quarter_turn * 3.0;

        if relative.abs() <= quarter_turn {
            (&self.front, DirectionalSpriteVariant::Front)
        } else if relative > quarter_turn && relative < three_quarter_turn {
            (&self.right, DirectionalSpriteVariant::Right)
        } else if relative < -quarter_turn && relative > -three_quarter_turn {
            (&self.left, DirectionalSpriteVariant::Left)
        } else {
            (&self.back, DirectionalSpriteVariant::Back)
        }
    }
}

/// A billboard sprite placed in world space with an associated texture and uniform scale.
#[derive(Debug, Clone)]
pub struct WorldSprite {
    /// Unique sprite ID assigned at `SpriteManager::add` time.
    pub id: u32,
    /// World X position of the sprite's center.
    pub x: f32,
    /// World Y position of the sprite's center.
    pub y: f32,
    /// Asset path of the texture to draw.
    pub texture: String,
    /// Optional directional texture set for front/side/back actor sprites.
    pub directional_textures: Option<DirectionalSpriteTextures>,
    /// Uniform scale applied to the billboard quad; 1.0 = native tile size.
    pub scale: f32,
    /// When false, the sprite is skipped during sorting and rendering.
    pub visible: bool,
}
/// Tracks all world-space billboard sprites; owned by `RaycasterState`.
pub struct SpriteManager {
    /// All registered sprites in insertion order.
    sprites: Vec<WorldSprite>,
    /// Monotonically incrementing ID counter; starts at 1.
    next_id: u32,
}
impl SpriteManager {
    /// Create an empty `SpriteManager` with ID counter starting at 1.
    pub fn new() -> Self {
        Self {
            sprites: Vec::new(),
            next_id: 1,
        }
    }
    /// Register a sprite at `(x, y)` with the given `texture` path and `scale`; return its new ID.
    pub fn add(&mut self, x: f32, y: f32, texture: &str, scale: f32) -> u32 {
        let id = self.next_id;
        self.next_id += 1;
        self.sprites.push(WorldSprite {
            id,
            x,
            y,
            texture: texture.to_owned(),
            directional_textures: None,
            scale,
            visible: true,
        });
        id
    }
    /// Register a sprite with directional front/right/back/left textures and world-facing angle.
    #[allow(clippy::too_many_arguments)]
    pub fn add_directional(
        &mut self,
        x: f32,
        y: f32,
        front: &str,
        right: &str,
        back: &str,
        left: &str,
        facing_angle: f32,
        scale: f32,
    ) -> u32 {
        let id = self.next_id;
        self.next_id += 1;
        self.sprites.push(WorldSprite {
            id,
            x,
            y,
            texture: front.to_owned(),
            directional_textures: Some(DirectionalSpriteTextures {
                front: front.to_owned(),
                right: right.to_owned(),
                back: back.to_owned(),
                left: left.to_owned(),
                facing_angle,
            }),
            scale,
            visible: true,
        });
        id
    }
    /// Remove the sprite with the given `id`; silently does nothing if not found.
    pub fn remove(&mut self, id: u32) {
        self.sprites.retain(|s| s.id != id);
    }
    /// Move the sprite with `id` to world position `(x, y)`; silently does nothing if not found.
    pub fn set_position(&mut self, id: u32, x: f32, y: f32) {
        if let Some(s) = self.sprites.iter_mut().find(|s| s.id == id) {
            s.x = x;
            s.y = y;
        }
    }
    /// Update the sprite-facing angle for a directional sprite; no-op when not found.
    pub fn set_facing(&mut self, id: u32, facing_angle: f32) {
        if let Some(s) = self.sprites.iter_mut().find(|s| s.id == id) {
            if let Some(textures) = &mut s.directional_textures {
                textures.facing_angle = facing_angle;
            }
        }
    }
    /// Replace directional textures for sprite `id` and keep or assign a facing angle.
    pub fn set_directional_textures(
        &mut self,
        id: u32,
        front: &str,
        right: &str,
        back: &str,
        left: &str,
        facing_angle: Option<f32>,
    ) {
        if let Some(s) = self.sprites.iter_mut().find(|s| s.id == id) {
            let angle = facing_angle.unwrap_or_else(|| {
                s.directional_textures
                    .as_ref()
                    .map(|textures| textures.facing_angle)
                    .unwrap_or(0.0)
            });
            s.texture = front.to_owned();
            s.directional_textures = Some(DirectionalSpriteTextures {
                front: front.to_owned(),
                right: right.to_owned(),
                back: back.to_owned(),
                left: left.to_owned(),
                facing_angle: angle,
            });
        }
    }
    /// Set the visibility flag for sprite `id`; silently does nothing if not found.
    pub fn set_visible(&mut self, id: u32, visible: bool) {
        if let Some(s) = self.sprites.iter_mut().find(|s| s.id == id) {
            s.visible = visible;
        }
    }
    /// Remove all sprites from the registry.
    pub fn clear(&mut self) {
        self.sprites.clear();
    }
    /// Return the registry snapshot in insertion order for higher-level bindings that need
    /// visibility, transform, and facing state without reimplementing storage.
    pub(crate) fn sprites(&self) -> &[WorldSprite] {
        &self.sprites
    }
    /// Return visible sprites sorted farthest-to-nearest from `(cam_x, cam_y)`.
    pub fn sort_by_distance(&self, cam_x: f32, cam_y: f32) -> Vec<&WorldSprite> {
        let mut visible: Vec<&WorldSprite> = self.sprites.iter().filter(|s| s.visible).collect();
        visible.sort_by(|a, b| {
            let da = (a.x - cam_x) * (a.x - cam_x) + (a.y - cam_y) * (a.y - cam_y);
            let db = (b.x - cam_x) * (b.x - cam_x) + (b.y - cam_y) * (b.y - cam_y);
            db.partial_cmp(&da).unwrap_or(std::cmp::Ordering::Equal)
        });
        visible
    }
}
/// Delegate `Default` to `SpriteManager::new`.
impl Default for SpriteManager {
    fn default() -> Self {
        Self::new()
    }
}
