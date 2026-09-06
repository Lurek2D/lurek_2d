//! Owns the raycaster build scene implementation for the raycaster subsystem and keeps related runtime rules local here.
//! Keeps ray hits, scene data, and first-person render helpers so helpers stay close to invariants this file updates.
//! Defines how raycaster build scene data is validated, transformed, or stored before neighboring systems consume it.
//! Separates raycaster build scene behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where raycaster code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing raycaster build scene defaults, lifecycle handling, validation, or data ownership rules.
//! Keeps failure paths and edge cases near raycaster build scene state that explains them instead of spreading outward.
//! Preserves deterministic behavior by keeping raycaster build scene calculations at their owning subsystem boundary.

use crate::color::Color;
use crate::math::Vec2;
use crate::raycaster::contract::{RaycasterError, RaycasterLimits};
use crate::raycaster::dda::Raycaster2D;
use crate::raycaster::lighting::{apply_global_light, compute_lighting, PointLight};
use crate::raycaster::multilevel::MultiLevelGrid;
use crate::raycaster::projection::distance_shade;
use crate::raycaster::ray_hit::RayHit;
use crate::raycaster::scene::{
    BillboardSprite, CeilingQuad, FloorQuad, RaycasterBackground, RaycasterBuildStats,
    RaycasterMaterial, RaycasterMaterialFrameLayout, RaycasterOverlayEffect, RaycasterParticle,
    RaycasterScene, WallQuad,
};
use crate::raycaster::wall_feature::{WallFeature, WallFeatureKind};
use crate::render::renderer::ParticleRenderShape;
use crate::render::BlendMode;
use crate::runtime::resource_keys::{ShaderKey, TextureKey};
use std::collections::HashMap;

mod floors;
mod pipeline;
mod sky;
mod sprites;
mod walls;

/// A floor cell that sits below the standard floor plane, used for pits and step-down areas.
#[derive(Debug, Clone, Copy)]
pub struct LoweredFloorCell {
    /// Texture applied to the lowered floor surface.
    pub texture_key: TextureKey,
    /// Downward offset from the standard floor plane (positive = lower), range 0..1.
    pub depth_offset: f32,
    /// RGB tint multiplier applied to the floor surface color.
    pub tint: [f32; 3],
    /// When true the lowered floor is emitted as a blocked render tile for pits or solid step-down cells.
    pub blocked: bool,
}

/// A billboard sprite attached to a specific multi-level slice.
#[derive(Debug, Clone)]
pub struct LevelSprite {
    /// Zero-based level index that owns the sprite.
    pub level_index: usize,
    /// Sprite payload projected within that level's floor plane.
    pub sprite: WorldSprite,
}

/// A world-space projected particle emitter attached to a specific multi-level slice.
#[derive(Debug, Clone)]
pub struct LevelParticleEmitter {
    /// Zero-based level index that owns the emitter.
    pub level_index: usize,
    /// Emitter payload projected within that level's floor plane.
    pub emitter: RaycasterParticleEmitter,
}

/// Build a 4-corner array for an axis-aligned rectangle in screen space.
fn corners_from_rect(x: f32, y: f32, w: f32, h: f32) -> [Vec2; 4] {
    [
        Vec2::new(x, y),
        Vec2::new(x + w, y),
        Vec2::new(x + w, y + h),
        Vec2::new(x, y + h),
    ]
}

/// Return the standard [0,0]..[1,1] UV coordinates for a quad's four corners.
fn rect_uvs() -> [Vec2; 4] {
    [
        Vec2::new(0.0, 0.0),
        Vec2::new(1.0, 0.0),
        Vec2::new(1.0, 1.0),
        Vec2::new(0.0, 1.0),
    ]
}

/// Return the fractional part of `v` in [0,1), wrapping negative values.
fn frac01(v: f32) -> f32 {
    let f = v - v.floor();
    if f < 0.0 {
        f + 1.0
    } else {
        f
    }
}

/// Return the grid cell just before a ray hit; used to look up the floor/ceiling texture at the approach tile.
#[allow(dead_code)]
fn floor_cell_before_hit(hit: &RayHit, ray_angle: f32) -> (u32, u32) {
    let wx = (hit.hit_x - ray_angle.cos() * 0.5).max(0.0);
    let wy = (hit.hit_y - ray_angle.sin() * 0.5).max(0.0);
    (wx.floor() as u32, wy.floor() as u32)
}

/// Build quad UV coordinates from near and far world-space fractional positions for a floor column strip.
#[allow(dead_code)]
fn column_uvs_from_world(near_x: f32, near_y: f32, far_x: f32, far_y: f32) -> [Vec2; 4] {
    let nu = frac01(near_x);
    let nv = frac01(near_y);
    let fu = frac01(far_x);
    let fv = frac01(far_y);
    [
        Vec2::new(nu, nv),
        Vec2::new(nu, nv),
        Vec2::new(fu, fv),
        Vec2::new(fu, fv),
    ]
}

/// Minimum camera-depth before which floor/ceiling geometry is discarded to avoid near-plane artifacts.
const FLOOR_NEAR: f32 = 0.05;

#[derive(Debug, Clone, Copy)]
struct VerticalPlanes {
    floor_plane: f32,
    ceiling_plane: f32,
}

#[inline]
fn vertical_planes(
    camera_world_z: f32,
    floor_world_z: f32,
    ceiling_world_z: f32,
) -> VerticalPlanes {
    VerticalPlanes {
        floor_plane: camera_world_z - floor_world_z,
        ceiling_plane: camera_world_z - ceiling_world_z,
    }
}

/// Project world point `(wx, wy)` onto the camera forward axis; return signed camera-space depth.
#[inline]
fn camera_depth(wx: f32, wy: f32, px: f32, py: f32, cos_a: f32, sin_a: f32) -> f32 {
    let rx = wx - px;
    let ry = wy - py;
    rx * cos_a + ry * sin_a
}

#[inline]
fn roofed_ambient(params: &SceneBuildParams, roofed: bool) -> f32 {
    if roofed {
        params.ambient_light * params.roofed_ambient_factor
    } else {
        params.ambient_light
    }
}

#[inline]
fn apply_global_light_tint(
    light_rgb: [f32; 3],
    x: f32,
    y: f32,
    roofed: bool,
    params: &SceneBuildParams,
    wall_at: &dyn Fn(i32, i32) -> bool,
) -> [f32; 3] {
    apply_global_light(
        light_rgb,
        x,
        y,
        roofed,
        [
            params.global_light_color.r,
            params.global_light_color.g,
            params.global_light_color.b,
        ],
        params.global_light_intensity,
        params.sun_angle,
        params.max_distance.min(12.0),
        wall_at,
    )
}

#[derive(Default)]
struct LightingSampleCache {
    samples: HashMap<(usize, i32, i32, bool), [f32; 3]>,
    hits: u32,
    misses: u32,
}

impl LightingSampleCache {
    #[allow(clippy::too_many_arguments)]
    fn sample(
        &mut self,
        level_index: usize,
        x: f32,
        y: f32,
        roofed: bool,
        params: &SceneBuildParams,
        lights: &[PointLight],
        wall_at: &dyn Fn(i32, i32) -> bool,
    ) -> [f32; 3] {
        let cell_x = x.floor() as i32;
        let cell_y = y.floor() as i32;
        let key = (level_index, cell_x, cell_y, roofed);
        if let Some(light) = self.samples.get(&key).copied() {
            self.hits = self.hits.saturating_add(1);
            return light;
        }

        self.misses = self.misses.saturating_add(1);
        let ambient = roofed_ambient(params, roofed);
        let sample_x = cell_x as f32 + 0.5;
        let sample_y = cell_y as f32 + 0.5;
        let light = apply_global_light_tint(
            compute_lighting(sample_x, sample_y, ambient, lights, wall_at),
            sample_x,
            sample_y,
            roofed,
            params,
            wall_at,
        );
        self.samples.insert(key, light);
        light
    }

    fn stats(&self) -> RaycasterBuildStats {
        RaycasterBuildStats {
            lighting_samples: self.hits.saturating_add(self.misses),
            lighting_cache_hits: self.hits,
            lighting_cache_misses: self.misses,
            wall_quads: 0,
            floor_quads: 0,
            ceiling_quads: 0,
            sprites: 0,
            models: 0,
            particles: 0,
            visible_levels: 0,
            depth_columns: 0,
        }
    }
}

/// Cached projection of one grid corner to screen space for floor/ceiling quad building.
#[derive(Debug, Clone, Copy)]
struct ProjectedGroundPoint {
    /// Screen-space X coordinate of the corner.
    sx: f32,
    /// Screen-space Y coordinate of the floor plane at this corner.
    floor_y: f32,
    /// Screen-space Y coordinate of the ceiling plane at this corner.
    ceil_y: f32,
    /// Camera-space depth (positive forward), used for perspective-correct UV interpolation.
    cx: f32,
}

/// Project world corner `(wx, wy)` to screen space for both floor and ceiling planes; return a `ProjectedGroundPoint`.
#[allow(clippy::too_many_arguments)]
#[inline]
fn project_ground_point(
    wx: f32,
    wy: f32,
    px: f32,
    py: f32,
    cos_a: f32,
    sin_a: f32,
    proj_dist: f32,
    screen_w: f32,
    horizon: f32,
    floor_plane: f32,
    ceiling_plane: f32,
) -> ProjectedGroundPoint {
    let rx = wx - px;
    let ry = wy - py;
    let cx = (rx * cos_a + ry * sin_a).max(FLOOR_NEAR);
    let cy = -rx * sin_a + ry * cos_a;
    let sx = (screen_w * 0.5 + (cy / cx) * proj_dist).clamp(-screen_w * 2.0, screen_w * 3.0);
    let sy_floor = horizon + proj_dist * floor_plane / cx;
    let sy_ceil = horizon + proj_dist * ceiling_plane / cx;
    ProjectedGroundPoint {
        sx: snap_half(sx),
        floor_y: snap_half(sy_floor),
        ceil_y: snap_half(sy_ceil),
        cx,
    }
}

/// Project world point `(wx, wy)` onto a single horizontal plane at `plane_offset`; return `(screen_x, screen_y, camera_depth)`.
#[allow(clippy::too_many_arguments)]
#[inline]
fn project_horizontal_plane(
    wx: f32,
    wy: f32,
    px: f32,
    py: f32,
    cos_a: f32,
    sin_a: f32,
    proj_dist: f32,
    screen_w: f32,
    horizon: f32,
    plane_offset: f32,
) -> (f32, f32, f32) {
    let rx = wx - px;
    let ry = wy - py;
    let cx = (rx * cos_a + ry * sin_a).max(FLOOR_NEAR);
    let cy = -rx * sin_a + ry * cos_a;
    let sx = (screen_w * 0.5 + (cy / cx) * proj_dist).clamp(-screen_w * 2.0, screen_w * 3.0);
    let sy = horizon + proj_dist * plane_offset / cx;
    (snap_half(sx), snap_half(sy), cx)
}

/// Round `v` to the nearest 0.5 to reduce sub-pixel jitter on floor/ceiling edges.
#[inline]
fn snap_half(v: f32) -> f32 {
    (v * 2.0).round() * 0.5
}

fn hash_u32(mut value: u32) -> u32 {
    value ^= value >> 16;
    value = value.wrapping_mul(0x7feb_352d);
    value ^= value >> 15;
    value = value.wrapping_mul(0x846c_a68b);
    value ^ (value >> 16)
}

fn random01(seed: u32, stream: u32) -> f32 {
    let hashed = hash_u32(seed ^ stream.wrapping_mul(0x9e37_79b9));
    hashed as f32 / u32::MAX as f32
}

fn random_signed(seed: u32, stream: u32) -> f32 {
    random01(seed, stream) * 2.0 - 1.0
}

/// Multiply `base` color by `light_rgb` and `shade`; preserve alpha.
fn lit_surface_color(base: &Color, light_rgb: [f32; 3], shade: f32) -> Color {
    Color::new(
        base.r * light_rgb[0] * shade,
        base.g * light_rgb[1] * shade,
        base.b * light_rgb[2] * shade,
        base.a,
    )
}

/// Convert a `Color` to a `[r, g, b, a]` f32 array used as a light multiplier.
fn color_to_light(c: &Color) -> [f32; 4] {
    [c.r, c.g, c.b, c.a]
}

/// All camera and world parameters consumed by `RaycasterScene::build` each frame.
#[derive(Debug, Clone)]
pub struct SceneBuildParams {
    /// Player world X position.
    pub player_x: f32,
    /// Player world Y position.
    pub player_y: f32,
    /// Player view angle in radians.
    pub player_angle: f32,
    /// Horizontal field of view in radians.
    pub fov: f32,
    /// Number of DDA rays cast across the screen width.
    pub ray_count: u32,
    /// Maximum tile distance at which geometry is rendered.
    pub max_distance: f32,
    /// Render target width in pixels.
    pub screen_width: f32,
    /// Render target height in pixels.
    pub screen_height: f32,
    /// Base ambient light level, 0.0..1.0.
    pub ambient_light: f32,
    /// Global day/night or sun-light tint applied after local lighting.
    pub global_light_color: Color,
    /// Scalar multiplier applied to `global_light_color`.
    pub global_light_intensity: f32,
    /// Optional world-space direction from the lit sample toward the sun source, in radians.
    pub sun_angle: Option<f32>,
    /// Fraction of ambient light that survives under a roof or ceiling texture.
    pub roofed_ambient_factor: f32,
    /// Distance at which walls are fully dark; controls distance-shading fall-off.
    pub shade_distance: f32,
    /// Flat tint color for untextured floor surfaces.
    pub floor_color: Color,
    /// Flat tint color for untextured ceiling surfaces.
    /// Set alpha to `0.0` to leave untextured ceiling cells transparent so a
    /// background or caller-drawn sky can show through.
    pub ceiling_color: Color,
    /// Camera eye height as a fraction of cell height, 0.1..0.9.
    pub camera_height: f32,
    /// Vertical offset applied to the horizon line in pixels (positive = up).
    pub horizon_offset: f32,
    /// Optional scene background drawn behind first-person geometry.
    pub background: Option<RaycasterBackground>,
    /// Optional full-frame overlay effects drawn after first-person geometry.
    pub overlays: Vec<RaycasterOverlayEffect>,
    /// Deterministic time source used for animated UVs and projected particle simulation.
    pub time_seconds: f32,
}

impl SceneBuildParams {
    /// Validate scene-build parameters against shared raycaster limits.
    pub fn validate(&self, limits: &RaycasterLimits) -> Result<(), RaycasterError> {
        limits.validate_finite("player_x", self.player_x)?;
        limits.validate_finite("player_y", self.player_y)?;
        limits.validate_finite("player_angle", self.player_angle)?;
        limits.validate_fov(self.fov)?;
        limits.validate_max_distance(self.max_distance)?;
        limits.validate_screen_dimensions(self.screen_width, self.screen_height)?;
        if self.ray_count == 0 || self.ray_count > limits.max_rays {
            return Err(RaycasterError::InvalidRayCount {
                count: self.ray_count,
                max: limits.max_rays,
            });
        }
        limits.validate_finite("horizon_offset", self.horizon_offset)?;
        limits.validate_finite("time_seconds", self.time_seconds)?;
        if let Some(sun_angle) = self.sun_angle {
            limits.validate_finite("sun_angle", sun_angle)?;
        }
        Ok(())
    }
}

fn material_texture(
    material: Option<&RaycasterMaterial>,
    fallback: Option<TextureKey>,
) -> Option<TextureKey> {
    material
        .and_then(|material| material.texture_key)
        .or(fallback)
}

fn tint_light(mut light: [f32; 4], material: Option<&RaycasterMaterial>) -> [f32; 4] {
    if let Some(material) = material {
        for (value, tint) in light.iter_mut().zip(material.tint) {
            *value *= tint;
        }
    }
    light
}

fn material_uvs(
    base_uvs: [Vec2; 4],
    material: Option<&RaycasterMaterial>,
    time_seconds: f32,
) -> [Vec2; 4] {
    let Some(material) = material else {
        return base_uvs;
    };
    let frame_count = material.frame_count.max(1);
    let animated = if frame_count > 1 && material.frame_rate > 0.0 {
        ((time_seconds.max(0.0) * material.frame_rate).floor() as u32) % frame_count
    } else {
        0
    };
    base_uvs.map(|uv| {
        let mut u = frac01(
            uv.x * material.uv_scale[0]
                + material.uv_offset[0]
                + material.uv_scroll[0] * time_seconds,
        );
        let mut v = frac01(
            uv.y * material.uv_scale[1]
                + material.uv_offset[1]
                + material.uv_scroll[1] * time_seconds,
        );
        if frame_count > 1 {
            let frame_count_f = frame_count as f32;
            match material.frame_layout {
                RaycasterMaterialFrameLayout::Horizontal => {
                    u = (u + animated as f32) / frame_count_f;
                }
                RaycasterMaterialFrameLayout::Vertical => {
                    v = (v + animated as f32) / frame_count_f;
                }
            }
        }
        Vec2::new(u, v)
    })
}

fn normalize_signed_angle(mut angle: f32) -> f32 {
    while angle > std::f32::consts::PI {
        angle -= 2.0 * std::f32::consts::PI;
    }
    while angle < -std::f32::consts::PI {
        angle += 2.0 * std::f32::consts::PI;
    }
    angle
}

/// Optional 4-direction texture set for bitmap actors that should read as front/side/back sprites.
#[derive(Debug, Clone, Copy)]
pub struct DirectionalSpriteTextures {
    /// Texture shown when the camera sees the sprite from the front.
    pub front: TextureKey,
    /// Texture shown when the camera sees the sprite's right side.
    pub right: TextureKey,
    /// Texture shown when the camera sees the sprite from behind.
    pub back: TextureKey,
    /// Texture shown when the camera sees the sprite's left side.
    pub left: TextureKey,
    /// World-space facing angle of the sprite's front, in radians.
    pub facing_angle: f32,
}

impl DirectionalSpriteTextures {
    fn select_texture(
        &self,
        viewer_x: f32,
        viewer_y: f32,
        sprite_x: f32,
        sprite_y: f32,
    ) -> TextureKey {
        let to_viewer = (viewer_y - sprite_y).atan2(viewer_x - sprite_x);
        let relative = normalize_signed_angle(to_viewer - self.facing_angle);
        let quarter_turn = std::f32::consts::FRAC_PI_4;
        let three_quarter_turn = quarter_turn * 3.0;

        if relative.abs() <= quarter_turn {
            self.front
        } else if relative > quarter_turn && relative < three_quarter_turn {
            self.right
        } else if relative < -quarter_turn && relative > -three_quarter_turn {
            self.left
        } else {
            self.back
        }
    }
}

/// A billboard sprite placed in world space and projected to screen by `RaycasterScene::build`.
#[derive(Debug, Clone)]
pub struct WorldSprite {
    /// Optional stable caller-supplied id for this sprite instance.
    pub entity_id: Option<u32>,
    /// Multi-level slice index owning this sprite.
    pub level_index: usize,
    /// World X position of the sprite center.
    pub world_x: f32,
    /// World Y position of the sprite center.
    pub world_y: f32,
    /// Texture used for the billboard quad.
    pub texture_key: TextureKey,
    /// Optional 4-direction texture set selected from the viewer angle.
    pub directional_textures: Option<DirectionalSpriteTextures>,
    /// World-space size of the sprite (height and width are equal).
    pub size: f32,
    /// Arbitrary string metadata attached to the sprite.
    pub attrs: std::collections::HashMap<String, String>,
}

/// A deterministic world-space particle emitter projected into the raycaster view.
#[derive(Debug, Clone)]
pub struct RaycasterParticleEmitter {
    /// Stable caller-assigned emitter id.
    pub emitter_id: u32,
    /// Multi-level slice index that owns this emitter.
    pub level_index: usize,
    /// World X position of the emitter origin.
    pub world_x: f32,
    /// World Y position of the emitter origin.
    pub world_y: f32,
    /// Height above the owning level floor where particles begin.
    pub world_z: f32,
    /// Horizontal spawn radius around the emitter origin.
    pub radius: f32,
    /// Vertical spawn span applied before velocity motion.
    pub height: f32,
    /// Spawn rate in particles per second.
    pub rate: f32,
    /// Minimum and maximum lifetime in seconds.
    pub lifetime_range: [f32; 2],
    /// Base XYZ velocity in world units per second.
    pub velocity: [f32; 3],
    /// Symmetric random XYZ velocity jitter added per particle.
    pub velocity_jitter: [f32; 3],
    /// Minimum and maximum particle size in world units.
    pub size_range: [f32; 2],
    /// RGBA color multiplied into the projected particle.
    pub color: [f32; 4],
    /// Fallback particle shape.
    pub shape: ParticleRenderShape,
    /// Optional texture applied to the particle billboard.
    pub texture_key: Option<TextureKey>,
    /// Optional particle-target shader.
    pub shader_key: Option<ShaderKey>,
    /// Blend mode used while presenting this emitter.
    pub blend_mode: BlendMode,
    /// When true, particles hidden behind nearer wall columns are culled.
    pub occlude_walls: bool,
    /// Deterministic seed driving per-particle jitter.
    pub seed: u32,
}

/// Callback type mapping a wall cell value to an optional `TextureKey`.
pub type TextureLookup = dyn Fn(u32) -> Option<TextureKey>;
/// Callback type mapping a grid `(x, y)` cell to an optional `TextureKey`.
pub type CellTextureLookup = dyn Fn(u32, u32) -> Option<TextureKey>;
