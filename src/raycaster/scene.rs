//! Raycaster scene types for textured-quad rendering.
//!
//! Defines the scene representation produced by [`build_scene`](RaycasterScene::build)
//! for dungeon-crawler and retro FPS games. Every surface (wall, floor, ceiling,
//! sprite) is a textured quad with per-polygon lighting — no column-strip rendering.

use crate::math::Color;
use crate::runtime::resource_keys::TextureKey;

// ── WallQuad ─────────────────────────────────────────────────────────────────

/// A single wall segment projected onto the screen as a textured quad.
///
/// Each wall quad represents one grid-cell face visible to the camera.
/// The texture covers the entire quad (no column strips).
///
/// # Fields
/// - `texture_key` — `TextureKey`. Wall texture to draw.
/// - `screen_x` — `f32`. Left edge on screen.
/// - `screen_y` — `f32`. Top edge on screen.
/// - `screen_w` — `f32`. Width on screen (typically 1 column, but may span more).
/// - `screen_h` — `f32`. Height on screen (perspective-projected wall height).
/// - `tex_u_start` — `f32`. Texture U start coordinate `[0.0, 1.0]`.
/// - `tex_u_end` — `f32`. Texture U end coordinate `[0.0, 1.0]`.
/// - `depth` — `f32`. Distance from camera (for depth sorting).
/// - `light_color` — `Color`. Per-polygon light tint (ambient + point lights combined).
/// - `cell_value` — `u32`. Map cell value for multi-texture lookup.
#[derive(Debug, Clone)]
pub struct WallQuad {
    /// Wall texture to draw.
    pub texture_key: Option<TextureKey>,
    /// Left edge on screen in pixels.
    pub screen_x: f32,
    /// Top edge on screen in pixels.
    pub screen_y: f32,
    /// Width on screen in pixels.
    pub screen_w: f32,
    /// Height on screen in pixels.
    pub screen_h: f32,
    /// Texture U start coordinate `[0.0, 1.0]`.
    pub tex_u_start: f32,
    /// Texture U end coordinate `[0.0, 1.0]`.
    pub tex_u_end: f32,
    /// Distance from camera for depth sorting.
    pub depth: f32,
    /// Per-polygon light tint (combined ambient + point lights).
    pub light_color: Color,
    /// Map cell value for multi-texture lookup.
    pub cell_value: u32,
}

// ── FloorQuad ────────────────────────────────────────────────────────────────

/// A single floor tile projected onto the screen as a textured quad.
///
/// # Fields
/// - `texture_key` — `Option<TextureKey>`. Floor texture (or solid colour if `None`).
/// - `screen_x` — `f32`. Left edge on screen.
/// - `screen_y` — `f32`. Top edge on screen.
/// - `screen_w` — `f32`. Width on screen.
/// - `screen_h` — `f32`. Height on screen.
/// - `world_x` — `f32`. World-space X for texture mapping.
/// - `world_y` — `f32`. World-space Y for texture mapping.
/// - `depth` — `f32`. Distance from camera.
/// - `light_color` — `Color`. Per-polygon light tint.
#[derive(Debug, Clone)]
pub struct FloorQuad {
    /// Floor texture (or solid colour if `None`).
    pub texture_key: Option<TextureKey>,
    /// Left edge on screen in pixels.
    pub screen_x: f32,
    /// Top edge on screen in pixels.
    pub screen_y: f32,
    /// Width on screen in pixels.
    pub screen_w: f32,
    /// Height on screen in pixels.
    pub screen_h: f32,
    /// World-space X for texture coordinate calculation.
    pub world_x: f32,
    /// World-space Y for texture coordinate calculation.
    pub world_y: f32,
    /// Distance from camera for depth sorting.
    pub depth: f32,
    /// Per-polygon light tint.
    pub light_color: Color,
}

// ── CeilingQuad ──────────────────────────────────────────────────────────────

/// A single ceiling tile projected onto the screen as a textured quad.
///
/// Mirrors [`FloorQuad`] but drawn above the wall segments.
///
/// # Fields
/// - `texture_key` — `Option<TextureKey>`. Ceiling texture (or solid colour if `None`).
/// - `screen_x` — `f32`. Left edge on screen.
/// - `screen_y` — `f32`. Top edge on screen.
/// - `screen_w` — `f32`. Width on screen.
/// - `screen_h` — `f32`. Height on screen.
/// - `world_x` — `f32`. World-space X for texture mapping.
/// - `world_y` — `f32`. World-space Y for texture mapping.
/// - `depth` — `f32`. Distance from camera.
/// - `light_color` — `Color`. Per-polygon light tint.
#[derive(Debug, Clone)]
pub struct CeilingQuad {
    /// Ceiling texture (or solid colour if `None`).
    pub texture_key: Option<TextureKey>,
    /// Left edge on screen in pixels.
    pub screen_x: f32,
    /// Top edge on screen in pixels.
    pub screen_y: f32,
    /// Width on screen in pixels.
    pub screen_w: f32,
    /// Height on screen in pixels.
    pub screen_h: f32,
    /// World-space X for texture coordinate calculation.
    pub world_x: f32,
    /// World-space Y for texture coordinate calculation.
    pub world_y: f32,
    /// Distance from camera for depth sorting.
    pub depth: f32,
    /// Per-polygon light tint.
    pub light_color: Color,
}

// ── BillboardSprite ──────────────────────────────────────────────────────────

/// A world-space sprite rendered as a camera-facing quad (billboard).
///
/// Used for objects, monsters, items, etc. The entire texture is drawn
/// on a single square quad — dungeon-crawler style (beholder, monsters).
///
/// # Fields
/// - `texture_key` — `TextureKey`. Sprite texture.
/// - `screen_x` — `f32`. Centre X on screen.
/// - `screen_y` — `f32`. Top edge on screen.
/// - `screen_w` — `f32`. Width on screen.
/// - `screen_h` — `f32`. Height on screen.
/// - `depth` — `f32`. Distance from camera (for depth sorting / occlusion).
/// - `light_color` — `Color`. Per-polygon light tint.
/// - `world_x` — `f32`. World X position (for lighting calculation).
/// - `world_y` — `f32`. World Y position (for lighting calculation).
#[derive(Debug, Clone)]
pub struct BillboardSprite {
    /// Sprite texture.
    pub texture_key: TextureKey,
    /// Centre X on screen in pixels.
    pub screen_x: f32,
    /// Top edge on screen in pixels.
    pub screen_y: f32,
    /// Width on screen in pixels.
    pub screen_w: f32,
    /// Height on screen in pixels.
    pub screen_h: f32,
    /// Distance from camera for depth sorting.
    pub depth: f32,
    /// Per-polygon light tint.
    pub light_color: Color,
    /// World X position (for lighting calculation).
    pub world_x: f32,
    /// World Y position (for lighting calculation).
    pub world_y: f32,
}

// ── RaycasterScene ───────────────────────────────────────────────────────────

/// Complete raycaster scene ready for rendering as textured quads.
///
/// Built by [`RaycasterScene::build`] from a [`Raycaster2D`](super::Raycaster2D)
/// grid and camera parameters. Contains all visible wall, floor, ceiling,
/// and sprite quads with per-polygon lighting pre-computed.
///
/// # Fields
/// - `walls` — `Vec<WallQuad>`. Visible wall segments.
/// - `floors` — `Vec<FloorQuad>`. Visible floor tiles.
/// - `ceilings` — `Vec<CeilingQuad>`. Visible ceiling tiles.
/// - `sprites` — `Vec<BillboardSprite>`. Billboard sprites sorted back-to-front.
/// - `screen_width` — `f32`. Screen width used for projection.
/// - `screen_height` — `f32`. Screen height used for projection.
#[derive(Debug, Clone)]
pub struct RaycasterScene {
    /// Visible wall segments as textured quads.
    pub walls: Vec<WallQuad>,
    /// Visible floor tiles as textured quads.
    pub floors: Vec<FloorQuad>,
    /// Visible ceiling tiles as textured quads.
    pub ceilings: Vec<CeilingQuad>,
    /// Billboard sprites sorted back-to-front by depth.
    pub sprites: Vec<BillboardSprite>,
    /// Screen width used for projection.
    pub screen_width: f32,
    /// Screen height used for projection.
    pub screen_height: f32,
}

impl RaycasterScene {
    /// Creates an empty scene.
    ///
    /// # Parameters
    /// - `screen_width` — `f32`.
    /// - `screen_height` — `f32`.
    ///
    /// # Returns
    /// `Self`.
    pub fn new(screen_width: f32, screen_height: f32) -> Self {
        Self {
            walls: Vec::new(),
            floors: Vec::new(),
            ceilings: Vec::new(),
            sprites: Vec::new(),
            screen_width,
            screen_height,
        }
    }

    /// Returns the total number of quads in the scene.
    ///
    /// # Returns
    /// `usize`.
    pub fn quad_count(&self) -> usize {
        self.walls.len() + self.floors.len() + self.ceilings.len() + self.sprites.len()
    }

    /// Returns `true` when the scene has no visible geometry.
    ///
    /// # Returns
    /// `bool`.
    pub fn is_empty(&self) -> bool {
        self.quad_count() == 0
    }
}

// ── Tests ────────────────────────────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;
    use crate::math::Color;

    #[test]
    fn empty_scene_has_zero_quads() {
        let scene = RaycasterScene::new(800.0, 600.0);
        assert_eq!(scene.quad_count(), 0);
        assert!(scene.is_empty());
    }

    #[test]
    fn scene_counts_all_quad_types() {
        let mut scene = RaycasterScene::new(800.0, 600.0);
        scene.walls.push(WallQuad {
            texture_key: None,
            screen_x: 0.0,
            screen_y: 0.0,
            screen_w: 1.0,
            screen_h: 100.0,
            tex_u_start: 0.0,
            tex_u_end: 1.0,
            depth: 2.0,
            light_color: Color::WHITE,
            cell_value: 1,
        });
        scene.floors.push(FloorQuad {
            texture_key: None,
            screen_x: 0.0,
            screen_y: 100.0,
            screen_w: 1.0,
            screen_h: 50.0,
            world_x: 0.0,
            world_y: 0.0,
            depth: 2.0,
            light_color: Color::WHITE,
        });
        scene.ceilings.push(CeilingQuad {
            texture_key: None,
            screen_x: 0.0,
            screen_y: 0.0,
            screen_w: 1.0,
            screen_h: 50.0,
            world_x: 0.0,
            world_y: 0.0,
            depth: 2.0,
            light_color: Color::WHITE,
        });
        assert_eq!(scene.quad_count(), 3);
        assert!(!scene.is_empty());
    }
}
