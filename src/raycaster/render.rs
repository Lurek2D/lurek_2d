//! This file owns the render-command bridge that turns a prepared `RaycasterScene` into generic engine draw commands.
//! It emits textured quads or flat rectangles for ceilings, floors, walls, sprites, and transient meshes in scene order.
//! Because the scene already contains geometry, UVs, lighting, and depth intent, this file mostly translates existing data.
//! It is the handoff point where raycaster-specific presentation becomes backend-agnostic `RenderCommand` work.
//! Open this file when command translation or draw ordering changes; CPU rasterization and scene assembly live in siblings.

use crate::raycaster::scene::RaycasterScene;
use crate::render::renderer::{DrawMode, RenderCommand};
use crate::render::BlendMode;

/// Render-command generation for a fully built raycaster scene.
impl RaycasterScene {
    /// Build a `Vec<RenderCommand>` for the full scene: ceilings, floors, walls, then transparent entities back-to-front.
    pub fn generate_render_commands(&self) -> Vec<RenderCommand> {
        enum TransparentItem<'a> {
            Sprite(&'a crate::raycaster::scene::BillboardSprite),
            Model(&'a crate::raycaster::scene::ModelMesh),
        }

        let mut cmds = Vec::with_capacity(self.quad_count() + 2);
        cmds.push(RenderCommand::SetBlendMode(BlendMode::Alpha));
        for ceil in &self.ceilings {
            match ceil.texture_key {
                Some(tex) => {
                    cmds.push(RenderCommand::DrawTexturedQuad {
                        corners: ceil.corners,
                        uvs: ceil.uvs,
                        corner_w: ceil.corner_w,
                        texture_key: tex,
                        color: ceil.light,
                    });
                }
                None => {
                    let [r, g, b, a] = ceil.light;
                    cmds.push(RenderCommand::SetColor(r, g, b, a));
                    cmds.push(RenderCommand::Rectangle {
                        mode: DrawMode::Fill,
                        x: ceil.corners[0].x,
                        y: ceil.corners[0].y,
                        w: ceil.corners[1].x - ceil.corners[0].x,
                        h: ceil.corners[3].y - ceil.corners[0].y,
                    });
                }
            }
        }
        for floor in &self.floors {
            match floor.texture_key {
                Some(tex) => {
                    cmds.push(RenderCommand::DrawTexturedQuad {
                        corners: floor.corners,
                        uvs: floor.uvs,
                        corner_w: floor.corner_w,
                        texture_key: tex,
                        color: floor.light,
                    });
                }
                None => {
                    let [r, g, b, a] = floor.light;
                    cmds.push(RenderCommand::SetColor(r, g, b, a));
                    cmds.push(RenderCommand::Rectangle {
                        mode: DrawMode::Fill,
                        x: floor.corners[0].x,
                        y: floor.corners[0].y,
                        w: floor.corners[1].x - floor.corners[0].x,
                        h: floor.corners[3].y - floor.corners[0].y,
                    });
                }
            }
        }
        for wall in &self.walls {
            match wall.texture_key {
                Some(tex) => {
                    cmds.push(RenderCommand::DrawTexturedQuad {
                        corners: wall.corners,
                        uvs: wall.uvs,
                        corner_w: wall.corner_w,
                        texture_key: tex,
                        color: wall.light,
                    });
                }
                None => {
                    let [r, g, b, a] = wall.light;
                    cmds.push(RenderCommand::SetColor(r, g, b, a));
                    cmds.push(RenderCommand::Rectangle {
                        mode: DrawMode::Fill,
                        x: wall.corners[0].x,
                        y: wall.corners[0].y,
                        w: wall.corners[1].x - wall.corners[0].x,
                        h: wall.corners[3].y - wall.corners[0].y,
                    });
                }
            }
        }
        let mut transparent_items = Vec::with_capacity(self.sprites.len() + self.models.len());
        for sprite in &self.sprites {
            transparent_items.push(TransparentItem::Sprite(sprite));
        }
        for model in &self.models {
            transparent_items.push(TransparentItem::Model(model));
        }
        transparent_items.sort_by(|a, b| {
            let ad = match a {
                TransparentItem::Sprite(sprite) => sprite.depth,
                TransparentItem::Model(model) => model.depth,
            };
            let bd = match b {
                TransparentItem::Sprite(sprite) => sprite.depth,
                TransparentItem::Model(model) => model.depth,
            };
            bd.partial_cmp(&ad).unwrap_or(std::cmp::Ordering::Equal)
        });
        for item in transparent_items {
            match item {
                TransparentItem::Sprite(sprite) => {
                    cmds.push(RenderCommand::DrawTexturedQuad {
                        corners: sprite.corners,
                        uvs: sprite.uvs,
                        corner_w: [1.0, 1.0, 1.0, 1.0],
                        texture_key: sprite.texture_key,
                        color: sprite.light,
                    });
                }
                TransparentItem::Model(model) => {
                    cmds.push(RenderCommand::DrawMeshTransient {
                        mesh: model.mesh.clone(),
                        x: 0.0,
                        y: 0.0,
                        rotation: 0.0,
                        sx: 1.0,
                        sy: 1.0,
                        ox: 0.0,
                        oy: 0.0,
                    });
                }
            }
        }
        cmds
    }
}
