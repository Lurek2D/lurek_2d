//! Owns minimap behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps minimap data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
//! Defines how render data is validated, transformed, or stored before neighboring systems use it.
//! Owns minimap behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on render behavior while Lua registration stays elsewhere.
//! Documents the boundary where minimap code accepts inputs, reports errors, or updates state.
//! Use this file when changing render defaults, lifecycle handling, validation, or data ownership.

use super::minimap::Minimap;
use super::types::{FogLevel, MinimapRenderStats, OverlayShape};
use crate::render::renderer::{DrawMode, RenderCommand};

fn same_color(lhs: [f32; 4], rhs: [f32; 4]) -> bool {
    lhs.map(f32::to_bits) == rhs.map(f32::to_bits)
}

/// Provide `RenderCommand` generation for `Minimap`.
impl Minimap {
    fn generate_render_commands_with_stats(
        &self,
        screen_x: f32,
        screen_y: f32,
    ) -> (Vec<RenderCommand>, MinimapRenderStats) {
        let mut cmds = Vec::new();
        let mut stats = MinimapRenderStats::default();
        let dw = self.display_width() as f32;
        let dh = self.display_height() as f32;
        if dw <= 0.0 || dh <= 0.0 {
            return (cmds, stats);
        }

        cmds.push(RenderCommand::SetColor(0.0, 0.0, 0.0, 0.85));
        cmds.push(RenderCommand::Rectangle {
            mode: DrawMode::Fill,
            x: screen_x,
            y: screen_y,
            w: dw,
            h: dh,
        });

        let Ok((cells_vis_x, cells_vis_y, cell_px_w, cell_px_h, _, _)) = self.transform_metrics()
        else {
            stats.commands_generated = cmds.len();
            return (cmds, stats);
        };

        let gw = self.grid_width() as f32;
        let gh = self.grid_height() as f32;
        let cx = self.center_x();
        let cy = self.center_y();
        let start_gx = ((cx - cells_vis_x / 2.0).floor() as i64).max(0) as u32;
        let start_gy = ((cy - cells_vis_y / 2.0).floor() as i64).max(0) as u32;
        let end_gx = ((cx + cells_vis_x / 2.0).ceil() as u32).min(gw as u32);
        let end_gy = ((cy + cells_vis_y / 2.0).ceil() as u32).min(gh as u32);
        let fog_enabled = self.fog_enabled();
        let [fcr, fcg, fcb, fca] = self.fog_color();
        let owner_colors = self.owner_colors_by_cell();

        let flush_run = |run_start: u32,
                         run_end: u32,
                         gy: u32,
                         color: [f32; 4],
                         cmds: &mut Vec<RenderCommand>,
                         stats: &mut MinimapRenderStats| {
            if run_end <= run_start {
                return;
            }
            let (sx, sy) = self.grid_to_screen(run_start as f32, gy as f32, screen_x, screen_y);
            cmds.push(RenderCommand::SetColor(
                color[0], color[1], color[2], color[3],
            ));
            cmds.push(RenderCommand::Rectangle {
                mode: DrawMode::Fill,
                x: sx,
                y: sy,
                w: cell_px_w * (run_end - run_start) as f32,
                h: cell_px_h,
            });
            stats.terrain_runs_batched += 1;
        };

        for gy in start_gy..end_gy {
            let mut run_start = start_gx;
            let mut run_color: Option<[f32; 4]> = None;
            for gx in start_gx..end_gx {
                stats.visible_cells += 1;
                let terrain = self.get_terrain(gx, gy);
                let base_color = self.resolve_cell_color(gx, gy, terrain, &owner_colors);
                let [r, g, b, a] = self.resolve_layered_cell_color(gx, gy, base_color);
                let color = if fog_enabled {
                    match self.get_fog_level(gx, gy) {
                        FogLevel::Hidden => [fcr, fcg, fcb, fca],
                        FogLevel::Explored => [r, g, b, a * 0.4],
                        FogLevel::Visible => [r, g, b, a],
                    }
                } else {
                    [r, g, b, a]
                };
                match run_color {
                    Some(prev) if same_color(prev, color) => {}
                    Some(prev) => {
                        flush_run(run_start, gx, gy, prev, &mut cmds, &mut stats);
                        run_start = gx;
                        run_color = Some(color);
                    }
                    None => {
                        run_start = gx;
                        run_color = Some(color);
                    }
                }
            }
            if let Some(color) = run_color {
                flush_run(run_start, end_gx, gy, color, &mut cmds, &mut stats);
            }
        }

        for shape in self.overlay_shapes() {
            match shape {
                OverlayShape::Line {
                    x1,
                    y1,
                    x2,
                    y2,
                    color,
                } if x1.is_finite() && y1.is_finite() && x2.is_finite() && y2.is_finite() => {
                    let (sx1, sy1) = self.grid_to_screen(*x1, *y1, screen_x, screen_y);
                    let (sx2, sy2) = self.grid_to_screen(*x2, *y2, screen_x, screen_y);
                    cmds.push(RenderCommand::SetColor(
                        color[0] as f32 / 255.0,
                        color[1] as f32 / 255.0,
                        color[2] as f32 / 255.0,
                        color[3] as f32 / 255.0,
                    ));
                    cmds.push(RenderCommand::Line {
                        x1: sx1,
                        y1: sy1,
                        x2: sx2,
                        y2: sy2,
                    });
                }
                OverlayShape::Rect { x, y, w, h, color }
                    if x.is_finite() && y.is_finite() && w.is_finite() && h.is_finite() =>
                {
                    let (sx, sy) = self.grid_to_screen(*x, *y, screen_x, screen_y);
                    let (ex, ey) = self.grid_to_screen(*x + *w, *y + *h, screen_x, screen_y);
                    cmds.push(RenderCommand::SetColor(
                        color[0] as f32 / 255.0,
                        color[1] as f32 / 255.0,
                        color[2] as f32 / 255.0,
                        color[3] as f32 / 255.0,
                    ));
                    cmds.push(RenderCommand::Rectangle {
                        mode: DrawMode::Line,
                        x: sx,
                        y: sy,
                        w: (ex - sx).abs(),
                        h: (ey - sy).abs(),
                    });
                }
                _ => {}
            }
        }

        for path in self.paths() {
            if path.points.len() < 2 {
                continue;
            }
            cmds.push(RenderCommand::SetColor(
                path.color[0] as f32 / 255.0,
                path.color[1] as f32 / 255.0,
                path.color[2] as f32 / 255.0,
                path.color[3] as f32 / 255.0,
            ));
            for window in path.points.windows(2) {
                let (x1, y1) = window[0];
                let (x2, y2) = window[1];
                if !x1.is_finite() || !y1.is_finite() || !x2.is_finite() || !y2.is_finite() {
                    continue;
                }
                let (sx1, sy1) = self.grid_to_screen(x1, y1, screen_x, screen_y);
                let (sx2, sy2) = self.grid_to_screen(x2, y2, screen_x, screen_y);
                cmds.push(RenderCommand::Line {
                    x1: sx1,
                    y1: sy1,
                    x2: sx2,
                    y2: sy2,
                });
            }
        }

        if self.viewport_visible() {
            if let Some((vx, vy, vw, vh)) = self.viewport_rect() {
                if vx.is_finite() && vy.is_finite() && vw.is_finite() && vh.is_finite() {
                    let [vr, vg, vb, va] = self.viewport_color();
                    let (sx, sy) = self.grid_to_screen(vx, vy, screen_x, screen_y);
                    let (ex, ey) = self.grid_to_screen(vx + vw, vy + vh, screen_x, screen_y);
                    cmds.push(RenderCommand::SetColor(vr, vg, vb, va));
                    cmds.push(RenderCommand::Rectangle {
                        mode: DrawMode::Line,
                        x: sx,
                        y: sy,
                        w: (ex - sx).abs(),
                        h: (ey - sy).abs(),
                    });
                }
            }
        }

        let ping_radius = (cell_px_w * 1.5).max(4.0);
        for ping in self.pings() {
            if !ping.x.is_finite() || !ping.y.is_finite() {
                continue;
            }
            let [pr, pg, pb, pa] = ping.color;
            let fade = if ping.duration > 0.0 {
                ping.remaining / ping.duration
            } else {
                1.0
            };
            let (sx, sy) = self.grid_to_screen(ping.x, ping.y, screen_x, screen_y);
            cmds.push(RenderCommand::SetColor(pr, pg, pb, pa * fade));
            cmds.push(RenderCommand::Circle {
                mode: DrawMode::Line,
                x: sx,
                y: sy,
                r: ping_radius,
            });
        }

        for object in self.objects_iter() {
            let Some(object_type) = self.object_type(object.type_index) else {
                continue;
            };
            if !object_type.visible || !object.x.is_finite() || !object.y.is_finite() {
                continue;
            }
            let (sx, sy) = self.grid_to_screen(object.x, object.y, screen_x, screen_y);
            if let Some(icon) = self.object_type_icon(object.type_index) {
                cmds.push(RenderCommand::DrawImageEx {
                    texture_key: icon.texture_key,
                    x: sx,
                    y: sy,
                    rotation: 0.0,
                    sx: icon.display_width / icon.texture_width,
                    sy: icon.display_height / icon.texture_height,
                    ox: icon.texture_width * 0.5,
                    oy: icon.texture_height * 0.5,
                    effect: None,
                });
                continue;
            }
            cmds.push(RenderCommand::SetColor(
                object_type.color[0],
                object_type.color[1],
                object_type.color[2],
                object_type.color[3],
            ));
            cmds.push(RenderCommand::Circle {
                mode: DrawMode::Fill,
                x: sx,
                y: sy,
                r: (cell_px_w.min(cell_px_h) * 0.35).max(3.0),
            });
        }

        for (marker_id, marker) in self.markers_with_ids() {
            if !marker.x.is_finite() || !marker.y.is_finite() {
                continue;
            }
            let (sx, sy) = self.grid_to_screen(marker.x, marker.y, screen_x, screen_y);
            if let Some(icon) = self.marker_icon(*marker_id) {
                cmds.push(RenderCommand::DrawImageEx {
                    texture_key: icon.texture_key,
                    x: sx,
                    y: sy,
                    rotation: 0.0,
                    sx: icon.display_width / icon.texture_width,
                    sy: icon.display_height / icon.texture_height,
                    ox: icon.texture_width * 0.5,
                    oy: icon.texture_height * 0.5,
                    effect: None,
                });
                continue;
            }
            cmds.push(RenderCommand::SetColor(
                marker.color[0],
                marker.color[1],
                marker.color[2],
                marker.color[3],
            ));
            cmds.push(RenderCommand::Circle {
                mode: DrawMode::Fill,
                x: sx,
                y: sy,
                r: (cell_px_w.min(cell_px_h) * 0.3).max(3.0),
            });
            cmds.push(RenderCommand::Line {
                x1: sx - 4.0,
                y1: sy,
                x2: sx + 4.0,
                y2: sy,
            });
            cmds.push(RenderCommand::Line {
                x1: sx,
                y1: sy - 4.0,
                x2: sx,
                y2: sy + 4.0,
            });
        }

        stats.commands_generated = cmds.len();
        (cmds, stats)
    }

    /// Return debug counters for the current minimap render-command generation path.
    pub fn render_stats(&self, screen_x: f32, screen_y: f32) -> MinimapRenderStats {
        self.generate_render_commands_with_stats(screen_x, screen_y)
            .1
    }

    /// Build the full ordered `RenderCommand` list for this minimap at screen origin `(screen_x, screen_y)`.
    pub fn generate_render_commands(&self, screen_x: f32, screen_y: f32) -> Vec<RenderCommand> {
        self.generate_render_commands_with_stats(screen_x, screen_y)
            .0
    }
}
