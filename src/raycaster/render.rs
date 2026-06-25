//! This file owns the render-command bridge that turns a prepared `RaycasterScene` into generic engine draw commands.
//! It emits textured quads or flat rectangles for ceilings, floors, walls, sprites, and transient meshes in scene order.
//! Because the scene already contains geometry, UVs, lighting, and depth intent, this file mostly translates existing data.
//! It is the handoff point where raycaster-specific presentation becomes backend-agnostic `RenderCommand` work.
//! Open this file when command translation or draw ordering changes; CPU rasterization and scene assembly live in siblings.

use crate::math::Vec2;
use crate::raycaster::scene::{RaycasterBackground, RaycasterOverlayEffect, RaycasterScene};
use crate::render::renderer::{DrawMode, GradientDirection, RenderCommand};
use crate::render::BlendMode;

fn push_background_commands(
    cmds: &mut Vec<RenderCommand>,
    background: &RaycasterBackground,
    width: f32,
    height: f32,
) {
    match background {
        RaycasterBackground::Solid { color } => {
            let [r, g, b, a] = *color;
            cmds.push(RenderCommand::SetColor(r, g, b, a));
            cmds.push(RenderCommand::Rectangle {
                mode: DrawMode::Fill,
                x: 0.0,
                y: 0.0,
                w: width,
                h: height,
            });
        }
        RaycasterBackground::VerticalGradient { top, bottom } => {
            cmds.push(RenderCommand::DrawGradientRect {
                x: 0.0,
                y: 0.0,
                w: width,
                h: height,
                color1: *top,
                color2: *bottom,
                direction: GradientDirection::Vertical,
            });
        }
        RaycasterBackground::Skybox {
            texture_key,
            tint,
            offset,
        } => {
            cmds.push(RenderCommand::DrawTexturedQuad {
                corners: [
                    Vec2::new(0.0, 0.0),
                    Vec2::new(width, 0.0),
                    Vec2::new(width, height),
                    Vec2::new(0.0, height),
                ],
                uvs: [
                    Vec2::new(*offset, 0.0),
                    Vec2::new(*offset + 1.0, 0.0),
                    Vec2::new(*offset + 1.0, 1.0),
                    Vec2::new(*offset, 1.0),
                ],
                corner_w: [1.0, 1.0, 1.0, 1.0],
                texture_key: *texture_key,
                color: *tint,
            });
        }
    }
}

fn push_overlay_commands(
    cmds: &mut Vec<RenderCommand>,
    overlays: &[RaycasterOverlayEffect],
    width: f32,
    height: f32,
) {
    for overlay in overlays {
        match *overlay {
            RaycasterOverlayEffect::Fog { mut color, density } => {
                color[3] = (color[3] * density.clamp(0.0, 1.0)).clamp(0.0, 1.0);
                let [r, g, b, a] = color;
                cmds.push(RenderCommand::SetColor(r, g, b, a));
                cmds.push(RenderCommand::Rectangle {
                    mode: DrawMode::Fill,
                    x: 0.0,
                    y: 0.0,
                    w: width,
                    h: height,
                });
            }
            RaycasterOverlayEffect::Snow {
                color,
                density,
                wind,
            } => {
                let count = ((width * height * density.clamp(0.0, 2.0)) / 850.0)
                    .round()
                    .clamp(0.0, 800.0) as u32;
                let [r, g, b, a] = color;
                cmds.push(RenderCommand::SetColor(r, g, b, a));
                let mut seed = 0x9e37_79b9_u32
                    ^ (width.max(1.0) as u32).rotate_left(8)
                    ^ height.max(1.0) as u32;
                let wind_px = (wind * 4.0).round();
                for _ in 0..count {
                    seed = seed.wrapping_mul(1_664_525).wrapping_add(1_013_904_223);
                    let x = (seed % width.max(1.0) as u32) as f32;
                    seed = seed.wrapping_mul(1_664_525).wrapping_add(1_013_904_223);
                    let y = (seed % height.max(1.0) as u32) as f32;
                    let len = 2.0 + (seed % 4) as f32;
                    cmds.push(RenderCommand::Line {
                        x1: x,
                        y1: y,
                        x2: x + wind_px,
                        y2: y + len,
                    });
                }
            }
        }
    }
}

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
        if let Some(background) = &self.background {
            push_background_commands(&mut cmds, background, self.screen_width, self.screen_height);
        }
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
                        corner_w: [sprite.depth, sprite.depth, sprite.depth, sprite.depth],
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
        push_overlay_commands(
            &mut cmds,
            &self.overlays,
            self.screen_width,
            self.screen_height,
        );
        cmds
    }
}
