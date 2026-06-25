//! This file owns `RaycasterScene` and its quad, sprite, mesh, pick, and build-stat record types for one frame.
//! It stores walls, floors, ceilings, billboard sprites, transient models, viewport size, and build counters.
//! Quad records carry corners, UVs, texture routing, light tint, depth, and perspective data for later draw paths.
//! Picking helpers resolve screen pixels against projected sprites and model triangles, with optional sprite alpha tests.
//! `EntityPickResult` and related enums define the stable payload returned when higher layers query scene selections.
//! This file is the staging boundary between raycaster world reasoning and renderer or CPU draw translation.
//! Open this file when prepared-scene data or picking semantics change; build and render flow live in siblings.

use crate::math::Vec2;
use crate::render::mesh::Mesh;
use crate::runtime::resource_keys::TextureKey;

/// Build-time counters captured while assembling a `RaycasterScene`.
#[derive(Debug, Clone, Copy, Default)]
pub struct RaycasterBuildStats {
    /// Total number of lighting samples requested while building the last scene.
    pub lighting_samples: u32,
    /// Number of lighting samples served from the per-build memoization cache.
    pub lighting_cache_hits: u32,
    /// Number of lighting samples that required a fresh visibility/light solve.
    pub lighting_cache_misses: u32,
}

/// Entity class resolved by scene-space picking.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum EntityPickKind {
    /// Billboard sprite quad.
    Sprite,
    /// Projected transient model mesh.
    Model,
}

impl EntityPickKind {
    /// Return the Lua-facing stable string for this entity kind.
    pub fn as_str(self) -> &'static str {
        match self {
            EntityPickKind::Sprite => "sprite",
            EntityPickKind::Model => "model",
        }
    }
}

/// Result of picking a projected sprite or model from a prepared raycaster scene.
#[derive(Debug, Clone, Copy)]
pub struct EntityPickResult {
    /// Entity class that was selected.
    pub kind: EntityPickKind,
    /// Optional stable caller-supplied id for the picked entity.
    pub entity_id: Option<u32>,
    /// Multi-level slice index owning the picked entity.
    pub level_index: usize,
    /// Camera-space depth used for occlusion comparisons.
    pub distance: f32,
    /// World-space anchor X position of the entity.
    pub world_x: f32,
    /// World-space anchor Y position of the entity.
    pub world_y: f32,
    /// Interpolated U coordinate at the picked point.
    pub tex_u: f32,
    /// Interpolated V coordinate at the picked point.
    pub tex_v: f32,
    /// Optional texture key bound to the picked entity.
    pub texture_key: Option<TextureKey>,
}

/// A textured or flat-shaded wall slice quad emitted for one raycaster column or face.
#[derive(Debug, Clone)]
pub struct WallQuad {
    /// Screen-space corner positions; order: top-left, top-right, bottom-right, bottom-left.
    pub corners: [Vec2; 4],
    /// UV coordinates matching `corners`.
    pub uvs: [Vec2; 4],
    /// Optional texture; `None` draws a flat `light`-colored rectangle.
    pub texture_key: Option<TextureKey>,
    /// Premultiplied RGBA light and tint applied at draw time.
    pub light: [f32; 4],
    /// Perpendicular camera-plane depth used for sprite occlusion sorting.
    pub depth: f32,
    /// Homogeneous W values per corner for perspective-correct texture sampling.
    pub corner_w: [f32; 4],
    /// Tile value of the wall cell that produced this quad.
    pub cell_value: u32,
}
/// A perspective-correct floor quad covering one screen column strip.
#[derive(Debug, Clone)]
pub struct FloorQuad {
    /// Screen-space corner positions.
    pub corners: [Vec2; 4],
    /// UV coordinates matching `corners`.
    pub uvs: [Vec2; 4],
    /// Optional texture; `None` draws a flat-colored rectangle.
    pub texture_key: Option<TextureKey>,
    /// Premultiplied RGBA light tint.
    pub light: [f32; 4],
    /// Depth for back-to-front sorting.
    pub depth: f32,
    /// Homogeneous W values for perspective-correct UV interpolation.
    pub corner_w: [f32; 4],
}
/// A perspective-correct ceiling quad covering one screen column strip.
#[derive(Debug, Clone)]
pub struct CeilingQuad {
    /// Screen-space corner positions.
    pub corners: [Vec2; 4],
    /// UV coordinates matching `corners`.
    pub uvs: [Vec2; 4],
    /// Optional texture; `None` draws a flat-colored rectangle.
    pub texture_key: Option<TextureKey>,
    /// Premultiplied RGBA light tint.
    pub light: [f32; 4],
    /// Depth for back-to-front sorting.
    pub depth: f32,
    /// Homogeneous W values for perspective-correct UV interpolation.
    pub corner_w: [f32; 4],
}
/// An axis-aligned billboard sprite quad, sorted by depth relative to walls.
#[derive(Debug, Clone)]
pub struct BillboardSprite {
    /// Screen-space corner positions.
    pub corners: [Vec2; 4],
    /// UV coordinates matching `corners`.
    pub uvs: [Vec2; 4],
    /// Texture used to draw this sprite.
    pub texture_key: TextureKey,
    /// Premultiplied RGBA light tint.
    pub light: [f32; 4],
    /// Perpendicular depth for depth-buffer occlusion testing.
    pub depth: f32,
    /// Optional stable caller-supplied id for this projected sprite.
    pub entity_id: Option<u32>,
    /// Multi-level slice index owning this sprite.
    pub level_index: usize,
    /// World-space anchor X position of the sprite.
    pub world_x: f32,
    /// World-space anchor Y position of the sprite.
    pub world_y: f32,
}

/// Full-frame background drawn before raycaster geometry.
#[derive(Debug, Clone)]
pub enum RaycasterBackground {
    /// Flat RGBA clear color.
    Solid { color: [f32; 4] },
    /// Vertical sky/background gradient.
    VerticalGradient { top: [f32; 4], bottom: [f32; 4] },
    /// Textured skybox/background covering the frame.
    Skybox {
        texture_key: TextureKey,
        tint: [f32; 4],
        offset: f32,
    },
}

/// Screen-space presentation effect drawn over the raycaster frame.
#[derive(Debug, Clone)]
pub enum RaycasterOverlayEffect {
    /// Transparent full-screen fog tint.
    Fog { color: [f32; 4], density: f32 },
    /// Deterministic snow streaks drawn over the frame.
    Snow {
        color: [f32; 4],
        density: f32,
        wind: f32,
    },
}
/// A static mesh injected into the raycaster scene with an associated depth.
#[derive(Debug, Clone)]
pub struct ModelMesh {
    /// Mesh geometry and texture to draw.
    pub mesh: Mesh,
    /// Depth used for sorting alongside sprites and walls.
    pub depth: f32,
    /// Camera-space depth per emitted triangle, aligned with `mesh.vertices.chunks_exact(3)`.
    pub triangle_depths: Vec<f32>,
    /// Optional stable caller-supplied id for this projected model.
    pub entity_id: Option<u32>,
    /// Multi-level slice index owning this model.
    pub level_index: usize,
    /// World-space anchor X position of the model instance.
    pub world_x: f32,
    /// World-space anchor Y position of the model instance.
    pub world_y: f32,
}
/// Full frame scene produced by `RaycasterScene::build`; consumed by `render::generate_render_commands`.
#[derive(Debug, Clone, Default)]
pub struct RaycasterScene {
    /// Wall quads sorted front-to-back by depth.
    pub walls: Vec<WallQuad>,
    /// Floor quads sorted front-to-back.
    pub floors: Vec<FloorQuad>,
    /// Ceiling quads sorted front-to-back.
    pub ceilings: Vec<CeilingQuad>,
    /// Billboard sprites sorted back-to-front for alpha blending.
    pub sprites: Vec<BillboardSprite>,
    /// Static model meshes sorted back-to-front.
    pub models: Vec<ModelMesh>,
    /// Optional full-frame background drawn before geometry.
    pub background: Option<RaycasterBackground>,
    /// Optional full-frame overlay effects drawn after geometry.
    pub overlays: Vec<RaycasterOverlayEffect>,
    /// Framebuffer width in pixels used when building this scene.
    pub screen_width: f32,
    /// Framebuffer height in pixels used when building this scene.
    pub screen_height: f32,
    /// Build-time counters captured while assembling this scene.
    pub build_stats: RaycasterBuildStats,
}
impl RaycasterScene {
    /// Create an empty scene sized to `screen_width` × `screen_height` pixels.
    pub fn new(screen_width: f32, screen_height: f32) -> Self {
        Self {
            walls: Vec::new(),
            floors: Vec::new(),
            ceilings: Vec::new(),
            sprites: Vec::new(),
            models: Vec::new(),
            background: None,
            overlays: Vec::new(),
            screen_width,
            screen_height,
            build_stats: RaycasterBuildStats::default(),
        }
    }
    /// Return the total number of quads, sprites, and models in this scene.
    pub fn quad_count(&self) -> usize {
        self.walls.len()
            + self.floors.len()
            + self.ceilings.len()
            + self.sprites.len()
            + self.models.len()
    }
    /// Return true when no geometry has been added to this scene.
    pub fn is_empty(&self) -> bool {
        self.quad_count() == 0
    }

    /// Resolve a screen pixel against projected sprites and transient models in this scene.
    pub fn pick_entity(&self, screen_x: f32, screen_y: f32) -> Option<EntityPickResult> {
        self.pick_entity_with_sprite_alpha_test(screen_x, screen_y, &|_, _, _| true)
    }

    /// Resolve a screen pixel against projected sprites and transient models in this scene.
    ///
    /// `sprite_alpha_test(texture_key, u, v)` should return `true` when the sampled sprite texel
    /// is meaningfully opaque for picking. This lets higher layers reject transparent billboard
    /// corners without teaching the scene about texture storage.
    pub fn pick_entity_with_sprite_alpha_test(
        &self,
        screen_x: f32,
        screen_y: f32,
        sprite_alpha_test: &dyn Fn(TextureKey, f32, f32) -> bool,
    ) -> Option<EntityPickResult> {
        fn barycentric(p: Vec2, a: Vec2, b: Vec2, c: Vec2) -> Option<(f32, f32, f32)> {
            let v0 = Vec2::new(b.x - a.x, b.y - a.y);
            let v1 = Vec2::new(c.x - a.x, c.y - a.y);
            let v2 = Vec2::new(p.x - a.x, p.y - a.y);
            let denom = v0.x * v1.y - v1.x * v0.y;
            if denom.abs() < 1e-5 {
                return None;
            }
            let inv = 1.0 / denom;
            let v = (v2.x * v1.y - v1.x * v2.y) * inv;
            let w = (v0.x * v2.y - v2.x * v0.y) * inv;
            let u = 1.0 - v - w;
            if u >= -1e-4 && v >= -1e-4 && w >= -1e-4 {
                Some((u, v, w))
            } else {
                None
            }
        }

        let sx = screen_x.clamp(0.0, self.screen_width.max(1.0) - 1.0);
        let sy = screen_y.clamp(0.0, self.screen_height.max(1.0) - 1.0);
        let point = Vec2::new(sx, sy);
        let mut best_pick: Option<EntityPickResult> = None;

        for sprite in &self.sprites {
            let left = sprite.corners[0].x.min(sprite.corners[2].x);
            let right = sprite.corners[0].x.max(sprite.corners[2].x);
            let top = sprite.corners[0].y.min(sprite.corners[2].y);
            let bottom = sprite.corners[0].y.max(sprite.corners[2].y);
            if sx < left || sx > right || sy < top || sy > bottom {
                continue;
            }
            let u = ((sx - left) / (right - left).max(1e-4)).clamp(0.0, 1.0);
            let v = ((sy - top) / (bottom - top).max(1e-4)).clamp(0.0, 1.0);
            if !sprite_alpha_test(sprite.texture_key, u, v) {
                continue;
            }
            let candidate = EntityPickResult {
                kind: EntityPickKind::Sprite,
                entity_id: sprite.entity_id,
                level_index: sprite.level_index,
                distance: sprite.depth,
                world_x: sprite.world_x,
                world_y: sprite.world_y,
                tex_u: u,
                tex_v: v,
                texture_key: Some(sprite.texture_key),
            };
            if best_pick
                .as_ref()
                .map(|current| candidate.distance < current.distance)
                .unwrap_or(true)
            {
                best_pick = Some(candidate);
            }
        }

        for model in &self.models {
            let vertices = &model.mesh.vertices;
            for (tri_index, tri) in vertices.chunks_exact(3).enumerate() {
                let a = Vec2::new(tri[0].x, tri[0].y);
                let b = Vec2::new(tri[1].x, tri[1].y);
                let c = Vec2::new(tri[2].x, tri[2].y);
                let Some((wa, wb, wc)) = barycentric(point, a, b, c) else {
                    continue;
                };
                let triangle_depth = model
                    .triangle_depths
                    .get(tri_index)
                    .copied()
                    .unwrap_or(model.depth);
                let candidate = EntityPickResult {
                    kind: EntityPickKind::Model,
                    entity_id: model.entity_id,
                    level_index: model.level_index,
                    distance: triangle_depth,
                    world_x: model.world_x,
                    world_y: model.world_y,
                    tex_u: (tri[0].u * wa + tri[1].u * wb + tri[2].u * wc).clamp(0.0, 1.0),
                    tex_v: (tri[0].v * wa + tri[1].v * wb + tri[2].v * wc).clamp(0.0, 1.0),
                    texture_key: model.mesh.texture,
                };
                if best_pick
                    .as_ref()
                    .map(|current| candidate.distance < current.distance)
                    .unwrap_or(true)
                {
                    best_pick = Some(candidate);
                }
                break;
            }
        }

        best_pick
    }
}
