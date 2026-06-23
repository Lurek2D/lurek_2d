//! This file owns transform adapters that turn static entries or live physics bodies into scene-facing raycaster inputs.
//! It stores `SceneTransform` sources plus resolved sprite, light, and optional model bindings sampled each frame.
//! Body-backed transforms apply local offsets and angle offsets so pseudo-3D attachments stay aligned with physics owners.
//! `SceneAdapter` aggregates bindings, clears tracked groups, and resolves live entries into world sprite or light data.
//! The adapter keeps external entity ownership outside the raycaster while it consumes one normalized input surface.
//! This file is the boundary between physics or runtime state and the scene builder's input contracts.
//! Open this file when source-to-scene adaptation changes; prepared geometry and lighting evaluation live in siblings.

use std::cell::RefCell;
use std::rc::Rc;

use crate::physics::World;
#[cfg(feature = "obj-loader")]
use crate::render::obj_loader::ObjModel;
use crate::runtime::resource_keys::TextureKey;

use super::build_scene::{DirectionalSpriteTextures, WorldSprite};
use super::lighting::PointLight;

/// A resolved 2D transform sampled from a static point or a live physics body.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct ResolvedSceneTransform {
    /// World-space X.
    pub x: f32,
    /// World-space Y.
    pub y: f32,
    /// Facing angle in radians.
    pub angle: f32,
}

/// Source of a raycaster-facing transform.
#[derive(Clone)]
pub enum SceneTransform {
    /// Fixed transform authored directly by the caller.
    Static { x: f32, y: f32, angle: f32 },
    /// Transform sampled from a live physics body with optional local offsets.
    Body {
        world: Rc<RefCell<World>>,
        body_id: usize,
        offset_x: f32,
        offset_y: f32,
        angle_offset: f32,
    },
}

impl SceneTransform {
    /// Create a fixed transform.
    pub fn static_xy(x: f32, y: f32, angle: f32) -> Self {
        Self::Static { x, y, angle }
    }

    /// Create a body-tracked transform with local offsets relative to the body's angle.
    pub fn body(
        world: Rc<RefCell<World>>,
        body_id: usize,
        offset_x: f32,
        offset_y: f32,
        angle_offset: f32,
    ) -> Self {
        Self::Body {
            world,
            body_id,
            offset_x,
            offset_y,
            angle_offset,
        }
    }

    /// Resolve the current world-space transform, or `None` if the body no longer exists.
    pub fn resolve(&self) -> Option<ResolvedSceneTransform> {
        match self {
            Self::Static { x, y, angle } => Some(ResolvedSceneTransform {
                x: *x,
                y: *y,
                angle: *angle,
            }),
            Self::Body {
                world,
                body_id,
                offset_x,
                offset_y,
                angle_offset,
            } => {
                let world = world.borrow();
                let body = world.get_body(*body_id)?;
                let cos_a = body.angle.cos();
                let sin_a = body.angle.sin();
                let world_offset_x = *offset_x * cos_a - *offset_y * sin_a;
                let world_offset_y = *offset_x * sin_a + *offset_y * cos_a;
                Some(ResolvedSceneTransform {
                    x: body.position.x + world_offset_x,
                    y: body.position.y + world_offset_y,
                    angle: body.angle + *angle_offset,
                })
            }
        }
    }
}

/// Sprite binding owned by a `SceneAdapter`.
#[derive(Clone)]
pub struct SceneAdapterSprite {
    /// Optional stable caller entity id.
    pub entity_id: Option<u32>,
    /// Owning multilevel slice.
    pub level_index: usize,
    /// Position and facing source.
    pub transform: SceneTransform,
    /// Primary texture when directional textures are absent.
    pub texture_key: TextureKey,
    /// Optional directional sprite textures.
    pub directional_textures: Option<DirectionalSpriteTextures>,
    /// Sprite size in world units.
    pub size: f32,
}

impl SceneAdapterSprite {
    /// Resolve into a raycaster scene sprite.
    pub fn resolve(&self) -> Option<WorldSprite> {
        let transform = self.transform.resolve()?;
        let directional_textures = self.directional_textures.as_ref().map(|textures| {
            let mut resolved = *textures;
            resolved.facing_angle = transform.angle;
            resolved
        });
        Some(WorldSprite {
            entity_id: self.entity_id,
            level_index: self.level_index,
            world_x: transform.x,
            world_y: transform.y,
            texture_key: directional_textures
                .as_ref()
                .map(|textures| textures.front)
                .unwrap_or(self.texture_key),
            directional_textures,
            size: self.size,
        })
    }
}

/// Point light binding owned by a `SceneAdapter`.
#[derive(Clone)]
pub struct SceneAdapterLight {
    /// Position source.
    pub transform: SceneTransform,
    /// Optional owning multilevel slice.
    pub level_index: Option<usize>,
    /// Falloff radius.
    pub radius: f32,
    /// RGB light color.
    pub color: [f32; 3],
    /// Brightness multiplier.
    pub intensity: f32,
}

impl SceneAdapterLight {
    /// Resolve into a raycaster point light.
    pub fn resolve(&self) -> Option<PointLight> {
        let transform = self.transform.resolve()?;
        Some(PointLight {
            x: transform.x,
            y: transform.y,
            level_index: self.level_index,
            radius: self.radius,
            color: self.color,
            intensity: self.intensity,
        })
    }
}

/// Resolved model instance for later Lua-side projection.
#[cfg(feature = "obj-loader")]
#[derive(Clone)]
pub struct ResolvedSceneModel {
    /// Model geometry.
    pub model: ObjModel,
    /// Optional stable caller entity id.
    pub entity_id: Option<u32>,
    /// Owning multilevel slice.
    pub level_index: usize,
    /// World-space X.
    pub world_x: f32,
    /// World-space Y.
    pub world_y: f32,
    /// Yaw in radians.
    pub yaw: f32,
    /// Vertical offset above the owning floor plane.
    pub z_offset: f32,
    /// Uniform scale multiplier.
    pub scale: f32,
}

/// Model binding owned by a `SceneAdapter`.
#[cfg(feature = "obj-loader")]
#[derive(Clone)]
pub struct SceneAdapterModel {
    /// Model geometry.
    pub model: ObjModel,
    /// Optional stable caller entity id.
    pub entity_id: Option<u32>,
    /// Owning multilevel slice.
    pub level_index: usize,
    /// Position and facing source.
    pub transform: SceneTransform,
    /// Vertical offset above the owning floor plane.
    pub z_offset: f32,
    /// Uniform scale multiplier.
    pub scale: f32,
}

#[cfg(feature = "obj-loader")]
impl SceneAdapterModel {
    /// Resolve into a model instance description.
    pub fn resolve(&self) -> Option<ResolvedSceneModel> {
        let transform = self.transform.resolve()?;
        Some(ResolvedSceneModel {
            model: self.model.clone(),
            entity_id: self.entity_id,
            level_index: self.level_index,
            world_x: transform.x,
            world_y: transform.y,
            yaw: transform.angle,
            z_offset: self.z_offset,
            scale: self.scale,
        })
    }
}

/// Aggregates raycaster-facing scene inputs from static entries and live physics bodies.
#[derive(Clone, Default)]
pub struct SceneAdapter {
    sprites: Vec<SceneAdapterSprite>,
    lights: Vec<SceneAdapterLight>,
    #[cfg(feature = "obj-loader")]
    models: Vec<SceneAdapterModel>,
}

impl SceneAdapter {
    /// Create an empty adapter.
    pub fn new() -> Self {
        Self::default()
    }

    /// Remove all tracked sprites, lights, and models.
    pub fn clear(&mut self) {
        self.sprites.clear();
        self.lights.clear();
        #[cfg(feature = "obj-loader")]
        self.models.clear();
    }

    /// Remove all tracked sprites.
    pub fn clear_sprites(&mut self) {
        self.sprites.clear();
    }

    /// Remove all tracked lights.
    pub fn clear_lights(&mut self) {
        self.lights.clear();
    }

    /// Remove all tracked models.
    #[cfg(feature = "obj-loader")]
    pub fn clear_models(&mut self) {
        self.models.clear();
    }

    /// Append a sprite binding.
    pub fn add_sprite(&mut self, sprite: SceneAdapterSprite) {
        self.sprites.push(sprite);
    }

    /// Append a point light binding.
    pub fn add_light(&mut self, light: SceneAdapterLight) {
        self.lights.push(light);
    }

    /// Append a model binding.
    #[cfg(feature = "obj-loader")]
    pub fn add_model(&mut self, model: SceneAdapterModel) {
        self.models.push(model);
    }

    /// Resolve all visible sprite bindings.
    pub fn resolve_sprites(&self) -> Vec<WorldSprite> {
        self.sprites
            .iter()
            .filter_map(SceneAdapterSprite::resolve)
            .collect()
    }

    /// Resolve all live light bindings.
    pub fn resolve_lights(&self) -> Vec<PointLight> {
        self.lights
            .iter()
            .filter_map(SceneAdapterLight::resolve)
            .collect()
    }

    /// Resolve all live model bindings.
    #[cfg(feature = "obj-loader")]
    pub fn resolve_models(&self) -> Vec<ResolvedSceneModel> {
        self.models
            .iter()
            .filter_map(SceneAdapterModel::resolve)
            .collect()
    }
}
