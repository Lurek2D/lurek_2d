//! Owns the raycaster render implementation for the raycaster subsystem and keeps related runtime rules local here.
//! Keeps ray hits, scene data, and first-person render helpers so helpers stay close to invariants this file updates.
//! Defines how raycaster render data is validated, transformed, or stored before neighboring systems consume it.
//! Separates raycaster render behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where raycaster code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing raycaster render defaults, lifecycle handling, validation, or data ownership rules.
//! Keeps failure paths and edge cases near raycaster render state that explains them instead of spreading rules outward.
//! Preserves deterministic behavior by keeping raycaster render calculations explicit at their owning subsystem boundary.

use crate::math::Vec2;
use crate::raycaster::scene::{
    RaycasterBackground, RaycasterMaterial, RaycasterOverlayEffect, RaycasterParticle,
    RaycasterScene,
};
use crate::render::renderer::{
    BlendMode, DrawMode, GradientDirection, ParticleInstance, RenderCommand,
};
use crate::runtime::resource_keys::{ShaderKey, TextureKey};

/// Runtime presentation state used while translating a raycaster scene into render commands.
#[derive(Debug, Clone, Copy)]
pub struct RaycasterRenderState {
    /// Optional scene-wide fallback shader used when a surface or overlay does not provide its own shader.
    pub scene_shader: Option<ShaderKey>,
    /// Shader to restore after the raycaster commands finish.
    pub restore_shader: Option<ShaderKey>,
    /// Blend mode to restore after the raycaster commands finish.
    pub restore_blend: BlendMode,
}

impl Default for RaycasterRenderState {
    fn default() -> Self {
        Self {
            scene_shader: None,
            restore_shader: None,
            restore_blend: BlendMode::Alpha,
        }
    }
}

#[derive(Debug, Clone, Copy)]
struct FullscreenPassContext {
    width: f32,
    height: f32,
    time_seconds: f32,
    fallback_shader: Option<ShaderKey>,
}

#[derive(Debug, Clone, Copy)]
struct SurfaceQuadCommand<'a> {
    corners: [Vec2; 4],
    uvs: [Vec2; 4],
    corner_w: [f32; 4],
    texture_key: Option<TextureKey>,
    light: [f32; 4],
    material: Option<&'a RaycasterMaterial>,
    fallback_shader: Option<ShaderKey>,
}

fn push_set_blend(
    cmds: &mut Vec<RenderCommand>,
    current_blend: &mut BlendMode,
    next_blend: BlendMode,
) {
    if *current_blend != next_blend {
        cmds.push(RenderCommand::SetBlendMode(next_blend));
        *current_blend = next_blend;
    }
}

fn push_set_shader(
    cmds: &mut Vec<RenderCommand>,
    current_shader: &mut Option<ShaderKey>,
    next_shader: Option<ShaderKey>,
) {
    if *current_shader != next_shader {
        cmds.push(RenderCommand::SetShader(next_shader));
        *current_shader = next_shader;
    }
}

fn fullscreen_corners(width: f32, height: f32) -> [Vec2; 4] {
    [
        Vec2::new(0.0, 0.0),
        Vec2::new(width, 0.0),
        Vec2::new(width, height),
        Vec2::new(0.0, height),
    ]
}

fn fullscreen_material_uvs(material: &RaycasterMaterial, time_seconds: f32) -> [Vec2; 4] {
    fn frac01(v: f32) -> f32 {
        let f = v - v.floor();
        if f < 0.0 {
            f + 1.0
        } else {
            f
        }
    }

    let frame_count = material.frame_count.max(1);
    let animated = if frame_count > 1 && material.frame_rate > 0.0 {
        ((time_seconds.max(0.0) * material.frame_rate).floor() as u32) % frame_count
    } else {
        0
    };
    let base = [
        Vec2::new(0.0, 0.0),
        Vec2::new(1.0, 0.0),
        Vec2::new(1.0, 1.0),
        Vec2::new(0.0, 1.0),
    ];
    base.map(|uv| {
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
                crate::raycaster::scene::RaycasterMaterialFrameLayout::Horizontal => {
                    u = (u + animated as f32) / frame_count_f;
                }
                crate::raycaster::scene::RaycasterMaterialFrameLayout::Vertical => {
                    v = (v + animated as f32) / frame_count_f;
                }
            }
        }
        Vec2::new(u, v)
    })
}

fn push_fullscreen_material(
    cmds: &mut Vec<RenderCommand>,
    width: f32,
    height: f32,
    time_seconds: f32,
    material: &RaycasterMaterial,
    current_blend: &mut BlendMode,
    current_shader: &mut Option<ShaderKey>,
) {
    push_set_blend(cmds, current_blend, material.blend_mode);
    push_set_shader(cmds, current_shader, material.shader_key);
    if let Some(texture_key) = material.texture_key {
        cmds.push(RenderCommand::DrawTexturedQuad {
            corners: fullscreen_corners(width, height),
            uvs: fullscreen_material_uvs(material, time_seconds),
            corner_w: [1.0, 1.0, 1.0, 1.0],
            texture_key,
            color: material.tint,
        });
    } else {
        let [r, g, b, a] = material.tint;
        cmds.push(RenderCommand::SetColor(r, g, b, a));
        cmds.push(RenderCommand::Rectangle {
            mode: DrawMode::Fill,
            x: 0.0,
            y: 0.0,
            w: width,
            h: height,
        });
    }
}

fn push_background_commands(
    cmds: &mut Vec<RenderCommand>,
    background: &RaycasterBackground,
    pass: FullscreenPassContext,
    current_blend: &mut BlendMode,
    current_shader: &mut Option<ShaderKey>,
) {
    match background {
        RaycasterBackground::Solid { color } => {
            push_set_blend(cmds, current_blend, BlendMode::Alpha);
            push_set_shader(cmds, current_shader, pass.fallback_shader);
            let [r, g, b, a] = *color;
            cmds.push(RenderCommand::SetColor(r, g, b, a));
            cmds.push(RenderCommand::Rectangle {
                mode: DrawMode::Fill,
                x: 0.0,
                y: 0.0,
                w: pass.width,
                h: pass.height,
            });
        }
        RaycasterBackground::VerticalGradient { top, bottom } => {
            push_set_blend(cmds, current_blend, BlendMode::Alpha);
            push_set_shader(cmds, current_shader, pass.fallback_shader);
            cmds.push(RenderCommand::DrawGradientRect {
                x: 0.0,
                y: 0.0,
                w: pass.width,
                h: pass.height,
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
            push_set_blend(cmds, current_blend, BlendMode::Alpha);
            push_set_shader(cmds, current_shader, pass.fallback_shader);
            cmds.push(RenderCommand::DrawTexturedQuad {
                corners: fullscreen_corners(pass.width, pass.height),
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
        RaycasterBackground::Shader { material } => push_fullscreen_material(
            cmds,
            pass.width,
            pass.height,
            pass.time_seconds,
            material,
            current_blend,
            current_shader,
        ),
    }
}

fn push_depth_fog_commands(
    cmds: &mut Vec<RenderCommand>,
    scene: &RaycasterScene,
    color: [f32; 4],
    density: f32,
    near: f32,
    far: f32,
) {
    if scene.depth_columns.is_empty() {
        return;
    }
    let width = scene.screen_width.max(1.0);
    let far = far.max(near + 0.01);
    let step_w = (width / scene.depth_columns.len() as f32).max(1.0);
    for (index, depth) in scene.depth_columns.iter().copied().enumerate() {
        let fog_t = ((depth - near) / (far - near)).clamp(0.0, 1.0);
        let alpha = (color[3] * density.clamp(0.0, 2.0) * fog_t).clamp(0.0, 1.0);
        if alpha <= 0.001 {
            continue;
        }
        cmds.push(RenderCommand::SetColor(color[0], color[1], color[2], alpha));
        cmds.push(RenderCommand::Rectangle {
            mode: DrawMode::Fill,
            x: index as f32 * step_w,
            y: 0.0,
            w: step_w.ceil(),
            h: scene.screen_height,
        });
    }
}

fn push_overlay_commands(
    cmds: &mut Vec<RenderCommand>,
    scene: &RaycasterScene,
    overlays: &[RaycasterOverlayEffect],
    fallback_shader: Option<ShaderKey>,
    current_blend: &mut BlendMode,
    current_shader: &mut Option<ShaderKey>,
) {
    for overlay in overlays {
        match *overlay {
            RaycasterOverlayEffect::Fog { mut color, density } => {
                push_set_blend(cmds, current_blend, BlendMode::Alpha);
                push_set_shader(cmds, current_shader, fallback_shader);
                color[3] = (color[3] * density.clamp(0.0, 1.0)).clamp(0.0, 1.0);
                let [r, g, b, a] = color;
                cmds.push(RenderCommand::SetColor(r, g, b, a));
                cmds.push(RenderCommand::Rectangle {
                    mode: DrawMode::Fill,
                    x: 0.0,
                    y: 0.0,
                    w: scene.screen_width,
                    h: scene.screen_height,
                });
            }
            RaycasterOverlayEffect::Snow {
                color,
                density,
                wind,
            } => {
                push_set_blend(cmds, current_blend, BlendMode::Alpha);
                push_set_shader(cmds, current_shader, fallback_shader);
                let count = ((scene.screen_width * scene.screen_height * density.clamp(0.0, 2.0))
                    / 850.0)
                    .round()
                    .clamp(0.0, 800.0) as u32;
                let [r, g, b, a] = color;
                cmds.push(RenderCommand::SetColor(r, g, b, a));
                let mut seed = 0x9e37_79b9_u32
                    ^ (scene.screen_width.max(1.0) as u32).rotate_left(8)
                    ^ scene.screen_height.max(1.0) as u32;
                let wind_px = (wind * 4.0).round();
                for _ in 0..count {
                    seed = seed.wrapping_mul(1_664_525).wrapping_add(1_013_904_223);
                    let x = (seed % scene.screen_width.max(1.0) as u32) as f32;
                    seed = seed.wrapping_mul(1_664_525).wrapping_add(1_013_904_223);
                    let y = (seed % scene.screen_height.max(1.0) as u32) as f32;
                    let len = 2.0 + (seed % 4) as f32;
                    cmds.push(RenderCommand::Line {
                        x1: x,
                        y1: y,
                        x2: x + wind_px,
                        y2: y + len,
                    });
                }
            }
            RaycasterOverlayEffect::DepthFog {
                color,
                density,
                near,
                far,
            } => {
                push_set_blend(cmds, current_blend, BlendMode::Alpha);
                push_set_shader(cmds, current_shader, fallback_shader);
                push_depth_fog_commands(cmds, scene, color, density, near, far)
            }
            RaycasterOverlayEffect::Shader { ref material } => push_fullscreen_material(
                cmds,
                scene.screen_width,
                scene.screen_height,
                scene.time_seconds,
                material,
                current_blend,
                current_shader,
            ),
        }
    }
}

fn push_surface_quad_commands(
    cmds: &mut Vec<RenderCommand>,
    quad: SurfaceQuadCommand<'_>,
    current_blend: &mut BlendMode,
    current_shader: &mut Option<ShaderKey>,
) {
    let shader = quad
        .material
        .and_then(|material| material.shader_key)
        .or(quad.fallback_shader);
    let blend = quad
        .material
        .map(|material| material.blend_mode)
        .unwrap_or(BlendMode::Alpha);
    push_set_blend(cmds, current_blend, blend);
    push_set_shader(cmds, current_shader, shader);
    match quad.texture_key {
        Some(texture_key) => cmds.push(RenderCommand::DrawTexturedQuad {
            corners: quad.corners,
            uvs: quad.uvs,
            corner_w: quad.corner_w,
            texture_key,
            color: quad.light,
        }),
        None => cmds.push(RenderCommand::DrawColoredPolygon {
            vertices: vec![
                quad.corners[0].x,
                quad.corners[0].y,
                quad.corners[1].x,
                quad.corners[1].y,
                quad.corners[2].x,
                quad.corners[2].y,
                quad.corners[3].x,
                quad.corners[3].y,
            ],
            colors: vec![quad.light; 4],
            mode: DrawMode::Fill,
        }),
    }
}

/// Render-command generation for a fully built raycaster scene.
impl RaycasterScene {
    /// Build a `Vec<RenderCommand>` for the full scene using the default raycaster presentation state.
    pub fn generate_render_commands(&self) -> Vec<RenderCommand> {
        self.generate_render_commands_with_state(RaycasterRenderState::default())
    }

    /// Build a `Vec<RenderCommand>` for the full scene while preserving caller-managed shader and blend state.
    pub fn generate_render_commands_with_state(
        &self,
        render_state: RaycasterRenderState,
    ) -> Vec<RenderCommand> {
        enum SceneItem<'a> {
            Ceiling(&'a crate::raycaster::scene::CeilingQuad),
            Floor(&'a crate::raycaster::scene::FloorQuad),
            Wall(&'a crate::raycaster::scene::WallQuad),
            Sprite(&'a crate::raycaster::scene::BillboardSprite),
            Particle(&'a RaycasterParticle),
            Model(&'a crate::raycaster::scene::ModelMesh),
        }

        impl SceneItem<'_> {
            fn depth(&self) -> f32 {
                match self {
                    SceneItem::Ceiling(ceiling) => ceiling.depth,
                    SceneItem::Floor(floor) => floor.depth,
                    SceneItem::Wall(wall) => wall.depth,
                    SceneItem::Sprite(sprite) => sprite.depth,
                    SceneItem::Particle(particle) => particle.depth,
                    SceneItem::Model(model) => model.depth,
                }
            }
        }

        let mut cmds = Vec::with_capacity(self.quad_count() * 2 + self.overlays.len() * 2 + 4);
        let mut current_blend = render_state.restore_blend;
        let mut current_shader = render_state.restore_shader;
        push_set_blend(&mut cmds, &mut current_blend, BlendMode::Alpha);
        push_set_shader(&mut cmds, &mut current_shader, render_state.scene_shader);
        if let Some(background) = &self.background {
            push_background_commands(
                &mut cmds,
                background,
                FullscreenPassContext {
                    width: self.screen_width,
                    height: self.screen_height,
                    time_seconds: self.time_seconds,
                    fallback_shader: render_state.scene_shader,
                },
                &mut current_blend,
                &mut current_shader,
            );
        }
        let mut scene_items = Vec::with_capacity(
            self.ceilings.len()
                + self.floors.len()
                + self.walls.len()
                + self.sprites.len()
                + self.particles.len()
                + self.models.len(),
        );
        for ceiling in &self.ceilings {
            scene_items.push(SceneItem::Ceiling(ceiling));
        }
        for floor in &self.floors {
            scene_items.push(SceneItem::Floor(floor));
        }
        for wall in &self.walls {
            scene_items.push(SceneItem::Wall(wall));
        }
        for sprite in &self.sprites {
            scene_items.push(SceneItem::Sprite(sprite));
        }
        for particle in &self.particles {
            scene_items.push(SceneItem::Particle(particle));
        }
        for model in &self.models {
            scene_items.push(SceneItem::Model(model));
        }
        scene_items.sort_by(|a, b| {
            b.depth()
                .partial_cmp(&a.depth())
                .unwrap_or(std::cmp::Ordering::Equal)
        });
        for item in scene_items {
            match item {
                SceneItem::Ceiling(ceil) => {
                    push_surface_quad_commands(
                        &mut cmds,
                        SurfaceQuadCommand {
                            corners: ceil.corners,
                            uvs: ceil.uvs,
                            corner_w: ceil.corner_w,
                            texture_key: ceil.texture_key,
                            light: ceil.light,
                            material: ceil.material.as_ref(),
                            fallback_shader: render_state.scene_shader,
                        },
                        &mut current_blend,
                        &mut current_shader,
                    );
                }
                SceneItem::Floor(floor) => {
                    push_surface_quad_commands(
                        &mut cmds,
                        SurfaceQuadCommand {
                            corners: floor.corners,
                            uvs: floor.uvs,
                            corner_w: floor.corner_w,
                            texture_key: floor.texture_key,
                            light: floor.light,
                            material: floor.material.as_ref(),
                            fallback_shader: render_state.scene_shader,
                        },
                        &mut current_blend,
                        &mut current_shader,
                    );
                }
                SceneItem::Wall(wall) => {
                    push_surface_quad_commands(
                        &mut cmds,
                        SurfaceQuadCommand {
                            corners: wall.corners,
                            uvs: wall.uvs,
                            corner_w: wall.corner_w,
                            texture_key: wall.texture_key,
                            light: wall.light,
                            material: wall.material.as_ref(),
                            fallback_shader: render_state.scene_shader,
                        },
                        &mut current_blend,
                        &mut current_shader,
                    );
                }
                SceneItem::Sprite(sprite) => {
                    push_surface_quad_commands(
                        &mut cmds,
                        SurfaceQuadCommand {
                            corners: sprite.corners,
                            uvs: sprite.uvs,
                            corner_w: [sprite.depth, sprite.depth, sprite.depth, sprite.depth],
                            texture_key: Some(sprite.texture_key),
                            light: sprite.light,
                            material: None,
                            fallback_shader: render_state.scene_shader,
                        },
                        &mut current_blend,
                        &mut current_shader,
                    );
                }
                SceneItem::Particle(particle) => {
                    push_set_blend(&mut cmds, &mut current_blend, particle.blend_mode);
                    push_set_shader(&mut cmds, &mut current_shader, None);
                    cmds.push(RenderCommand::DrawParticleSystem {
                        particles: vec![ParticleInstance {
                            x: particle.x,
                            y: particle.y,
                            r: particle.color[0],
                            g: particle.color[1],
                            b: particle.color[2],
                            a: particle.color[3],
                            rotation: particle.rotation,
                            size: particle.size,
                            shape: particle.shape.clone(),
                            texture_key: particle.texture_key,
                            quad: particle.quad,
                            quad_tex_dims: particle.quad_tex_dims,
                            local_x: particle.local_x,
                            local_y: particle.local_y,
                            velocity_x: particle.velocity_x,
                            velocity_y: particle.velocity_y,
                            normalized_age: particle.normalized_age,
                            lifetime: particle.lifetime,
                            seed: particle.seed,
                        }],
                        shader: particle.shader_key,
                    });
                }
                SceneItem::Model(model) => {
                    push_set_blend(&mut cmds, &mut current_blend, BlendMode::Alpha);
                    push_set_shader(&mut cmds, &mut current_shader, render_state.scene_shader);
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
            self,
            &self.overlays,
            render_state.scene_shader,
            &mut current_blend,
            &mut current_shader,
        );
        if current_shader != render_state.restore_shader {
            cmds.push(RenderCommand::SetShader(render_state.restore_shader));
        }
        if current_blend != render_state.restore_blend {
            cmds.push(RenderCommand::SetBlendMode(render_state.restore_blend));
        }
        cmds
    }
}
