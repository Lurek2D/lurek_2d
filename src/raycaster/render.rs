//! Render-command generation for raycaster scenes.
//!
//! Converts a [`RaycasterScene`] into [`RenderCommand`] sequences.
//! Each quad type (wall, floor, ceiling, sprite) becomes a `DrawQuad` or
//! `DrawImageEx` command with per-polygon light tint applied via `SetColor`.
//! Pure CPU — no wgpu, winit, or mlua.

use crate::raycaster::scene::RaycasterScene;
use crate::render::renderer::RenderCommand;
use crate::render::BlendMode;

impl RaycasterScene {
    /// Converts the entire scene into render commands.
    ///
    /// Draw order: ceilings → floors → walls (front-to-back) → sprites (back-to-front).
    /// Each quad gets a `SetColor` for its per-polygon `light_color`, then
    /// a draw command. Textured quads use `DrawImageEx`; untextured quads
    /// use `Rectangle` filled with the light colour.
    ///
    /// # Returns
    /// `Vec<RenderCommand>`.
    pub fn generate_render_commands(&self) -> Vec<RenderCommand> {
        // Rough capacity: 2 per quad (SetColor + draw)
        let mut cmds = Vec::with_capacity(self.quad_count() * 2 + 2);

        cmds.push(RenderCommand::SetBlendMode(BlendMode::Alpha));

        // ── Ceilings ──
        for ceil in &self.ceilings {
            let c = &ceil.light_color;
            cmds.push(RenderCommand::SetColor(c.r, c.g, c.b, c.a));

            match ceil.texture_key {
                Some(tex) => {
                    cmds.push(RenderCommand::DrawImageEx {
                        texture_key: tex,
                        x: ceil.screen_x,
                        y: ceil.screen_y,
                        rotation: 0.0,
                        sx: ceil.screen_w,
                        sy: ceil.screen_h,
                        ox: 0.0,
                        oy: 0.0,
                        effect: None,
                    });
                }
                None => {
                    cmds.push(RenderCommand::Rectangle {
                        mode: crate::render::renderer::DrawMode::Fill,
                        x: ceil.screen_x,
                        y: ceil.screen_y,
                        w: ceil.screen_w,
                        h: ceil.screen_h,
                    });
                }
            }
        }

        // ── Floors ──
        for floor in &self.floors {
            let c = &floor.light_color;
            cmds.push(RenderCommand::SetColor(c.r, c.g, c.b, c.a));

            match floor.texture_key {
                Some(tex) => {
                    cmds.push(RenderCommand::DrawImageEx {
                        texture_key: tex,
                        x: floor.screen_x,
                        y: floor.screen_y,
                        rotation: 0.0,
                        sx: floor.screen_w,
                        sy: floor.screen_h,
                        ox: 0.0,
                        oy: 0.0,
                        effect: None,
                    });
                }
                None => {
                    cmds.push(RenderCommand::Rectangle {
                        mode: crate::render::renderer::DrawMode::Fill,
                        x: floor.screen_x,
                        y: floor.screen_y,
                        w: floor.screen_w,
                        h: floor.screen_h,
                    });
                }
            }
        }

        // ── Walls (front-to-back by depth for correct overdraw) ──
        // Already in column order from build; depth sorting within columns
        // is handled by the scene builder.
        for wall in &self.walls {
            let c = &wall.light_color;
            cmds.push(RenderCommand::SetColor(c.r, c.g, c.b, c.a));

            match wall.texture_key {
                Some(tex) => {
                    cmds.push(RenderCommand::DrawQuad {
                        texture_key: tex,
                        quad_x: wall.tex_u_start * 64.0, // assume 64px tile
                        quad_y: 0.0,
                        quad_w: (wall.tex_u_end - wall.tex_u_start).abs().max(1.0 / 64.0) * 64.0,
                        quad_h: 64.0,
                        tex_w: 64.0,
                        tex_h: 64.0,
                        x: wall.screen_x,
                        y: wall.screen_y,
                        rotation: 0.0,
                        sx: wall.screen_w / 64.0,
                        sy: wall.screen_h / 64.0,
                        ox: 0.0,
                        oy: 0.0,
                        effect: None,
                    });
                }
                None => {
                    cmds.push(RenderCommand::Rectangle {
                        mode: crate::render::renderer::DrawMode::Fill,
                        x: wall.screen_x,
                        y: wall.screen_y,
                        w: wall.screen_w,
                        h: wall.screen_h,
                    });
                }
            }
        }

        // ── Sprites (already sorted back-to-front by build_scene) ──
        for sprite in &self.sprites {
            let c = &sprite.light_color;
            cmds.push(RenderCommand::SetColor(c.r, c.g, c.b, c.a));

            // Billboard: entire texture on a square quad — dungeon-crawler style
            cmds.push(RenderCommand::DrawImageEx {
                texture_key: sprite.texture_key,
                x: sprite.screen_x - sprite.screen_w / 2.0,
                y: sprite.screen_y,
                rotation: 0.0,
                sx: sprite.screen_w,
                sy: sprite.screen_h,
                ox: 0.0,
                oy: 0.0,
                effect: None,
            });
        }

        cmds
    }
}

// ── Tests ────────────────────────────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;
    use crate::math::Color;
    use crate::raycaster::scene::{CeilingQuad, FloorQuad, WallQuad, RaycasterScene};

    #[test]
    fn empty_scene_produces_minimal_commands() {
        let scene = RaycasterScene::new(320.0, 200.0);
        let cmds = scene.generate_render_commands();
        // Just SetBlendMode
        assert_eq!(cmds.len(), 1);
    }

    #[test]
    fn wall_quad_emits_set_color_and_draw() {
        let mut scene = RaycasterScene::new(320.0, 200.0);
        scene.walls.push(WallQuad {
            texture_key: None,
            screen_x: 10.0,
            screen_y: 50.0,
            screen_w: 32.0,
            screen_h: 100.0,
            tex_u_start: 0.0,
            tex_u_end: 1.0,
            depth: 3.0,
            light_color: Color::new(0.8, 0.6, 0.4, 1.0),
            cell_value: 1,
        });
        let cmds = scene.generate_render_commands();
        // SetBlendMode + SetColor + Rectangle = 3
        assert_eq!(cmds.len(), 3);
        assert!(matches!(cmds[1], RenderCommand::SetColor(..)));
        assert!(matches!(cmds[2], RenderCommand::Rectangle { .. }));
    }

    #[test]
    fn floor_emits_draw_command() {
        let mut scene = RaycasterScene::new(320.0, 200.0);
        scene.floors.push(FloorQuad {
            texture_key: None,
            screen_x: 0.0,
            screen_y: 100.0,
            screen_w: 32.0,
            screen_h: 100.0,
            world_x: 5.0,
            world_y: 5.0,
            depth: 3.0,
            light_color: Color::WHITE,
        });
        let cmds = scene.generate_render_commands();
        assert!(cmds.len() >= 2);
    }

    #[test]
    fn ceiling_drawn_before_walls() {
        let mut scene = RaycasterScene::new(320.0, 200.0);
        scene.ceilings.push(CeilingQuad {
            texture_key: None,
            screen_x: 0.0,
            screen_y: 0.0,
            screen_w: 32.0,
            screen_h: 50.0,
            world_x: 5.0,
            world_y: 5.0,
            depth: 3.0,
            light_color: Color::WHITE,
        });
        scene.walls.push(WallQuad {
            texture_key: None,
            screen_x: 0.0,
            screen_y: 50.0,
            screen_w: 32.0,
            screen_h: 100.0,
            tex_u_start: 0.0,
            tex_u_end: 1.0,
            depth: 3.0,
            light_color: Color::WHITE,
            cell_value: 1,
        });
        let cmds = scene.generate_render_commands();
        // Find first Rectangle after SetBlendMode — should be the ceiling
        let first_rect_idx = cmds
            .iter()
            .position(|c| matches!(c, RenderCommand::Rectangle { .. }))
            .unwrap();
        // Ceiling rect has y=0
        if let RenderCommand::Rectangle { y, .. } = &cmds[first_rect_idx] {
            assert!((*y).abs() < 1e-5, "First rectangle should be ceiling (y=0)");
        }
    }
}
