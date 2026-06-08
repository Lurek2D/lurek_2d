//! This file provides tilemap render-command emission with camera-aware culling across map layers.
//! It maps tile IDs to debug colors so rendering can proceed even without atlas texture sampling.
//! It applies per-layer visibility and tint state when composing command output for the renderer.
//! It respects orthogonal, isometric, and hexagonal map orientation so debug rendering matches map space.
//! It keeps draw generation predictable so map visualization remains stable during updates.
//! It provides a stable debug visualization path when textured rendering is unavailable.

use super::coords::{to_screen_hex, to_screen_iso};
use super::mapgen::MapOrientation;
use super::tilemap::TileMap;
use crate::render::renderer::{DrawMode, RenderCommand};

/// Map a GID to a debug-palette RGB triple for fallback colored tile rendering.
fn gid_to_color(gid: u32) -> (f32, f32, f32) {
    if gid >= 10 {
        match gid {
            10 => (200.0 / 255.0, 50.0 / 255.0, 50.0 / 255.0),
            11 => (50.0 / 255.0, 50.0 / 255.0, 200.0 / 255.0),
            12 => (200.0 / 255.0, 200.0 / 255.0, 50.0 / 255.0),
            _ => (1.0, 1.0, 1.0),
        }
    } else {
        match gid {
            1 => (80.0 / 255.0, 160.0 / 255.0, 80.0 / 255.0),
            2 => (60.0 / 255.0, 120.0 / 255.0, 60.0 / 255.0),
            _ => (40.0 / 255.0, 40.0 / 255.0, 40.0 / 255.0),
        }
    }
}
/// Render-command generation for `TileMap`.
impl TileMap {
    fn tile_origin_for_render(&self, tx: u32, ty: u32, tw: f32, th: f32) -> (f32, f32) {
        match self.get_orientation() {
            MapOrientation::TopDown | MapOrientation::SideView => (tx as f32 * tw, ty as f32 * th),
            MapOrientation::Isometric => {
                let pos = to_screen_iso(tx as f32, ty as f32, tw, th);
                (pos.x, pos.y)
            }
            MapOrientation::Hexagonal => {
                let pos = to_screen_hex(tx as i32, ty as i32, th * 0.5);
                (pos.x, pos.y)
            }
        }
    }

    #[allow(clippy::too_many_arguments)]
    fn tile_intersects_camera(
        &self,
        tx: u32,
        ty: u32,
        tw: f32,
        th: f32,
        cam_x: f32,
        cam_y: f32,
        cam_w: f32,
        cam_h: f32,
    ) -> bool {
        let (world_x, world_y) = self.tile_origin_for_render(tx, ty, tw, th);
        world_x + tw >= cam_x
            && world_x <= cam_x + cam_w
            && world_y + th >= cam_y
            && world_y <= cam_y + cam_h
    }

    #[allow(clippy::too_many_arguments)]
    fn push_tile_render_commands(
        &self,
        cmds: &mut Vec<RenderCommand>,
        gid: u32,
        tint: [f32; 4],
        sx: f32,
        sy: f32,
        tw: f32,
        th: f32,
    ) {
        let (gr, gg, gb) = gid_to_color(gid);
        cmds.push(RenderCommand::SetColor(
            gr * tint[0],
            gg * tint[1],
            gb * tint[2],
            tint[3],
        ));
        if gid >= 10 {
            cmds.push(RenderCommand::Circle {
                mode: DrawMode::Fill,
                x: sx + tw * 0.5,
                y: sy + th * 0.5,
                r: (tw * 0.5).clamp(3.0, 6.0),
            });
        } else {
            cmds.push(RenderCommand::Rectangle {
                mode: DrawMode::Fill,
                x: sx,
                y: sy,
                w: tw,
                h: th,
            });
        }
    }

    /// Build a flat `RenderCommand` list for all visible layers using the debug color palette and `offset`.
    pub fn build_render_commands(&self, offset_x: f32, offset_y: f32) -> Vec<RenderCommand> {
        let mut cmds = Vec::new();
        if self.get_layer_count() == 0 {
            return cmds;
        }
        let tw = self.get_tile_width() as f32;
        let th = self.get_tile_height() as f32;
        if tw <= 0.0 || th <= 0.0 {
            return cmds;
        }
        for layer_idx in 0..self.get_layer_count() {
            if !self.get_layer_visible(layer_idx) {
                continue;
            }
            let Some((lw, lh)) = self.get_layer_dimensions(layer_idx) else {
                continue;
            };
            for ty in 0..lh {
                for tx in 0..lw {
                    let source_gid = self.get_tile(layer_idx, tx, ty);
                    if source_gid == 0 && layer_idx > 0 {
                        continue;
                    }
                    let gid = self.render_gid(source_gid);
                    let (world_x, world_y) = self.tile_origin_for_render(tx, ty, tw, th);
                    self.push_tile_render_commands(
                        &mut cmds,
                        gid,
                        self.effective_tile_tint(layer_idx, tx, ty),
                        offset_x + world_x,
                        offset_y + world_y,
                        tw,
                        th,
                    );
                }
            }
        }
        cmds
    }

    #[allow(clippy::too_many_arguments)]
    #[allow(clippy::manual_clamp)]
    /// Generate camera-culled `RenderCommand` primitives for all visible layers; returns an empty vec when the map has no layers or zero tile size.
    pub fn generate_render_commands(
        &self,
        offset_x: f32,
        offset_y: f32,
        cam_x: f32,
        cam_y: f32,
        cam_w: f32,
        cam_h: f32,
    ) -> Vec<RenderCommand> {
        let mut cmds = Vec::new();
        if self.get_layer_count() == 0 {
            return cmds;
        }
        let tw = self.get_tile_width() as f32;
        let th = self.get_tile_height() as f32;
        if tw <= 0.0 || th <= 0.0 {
            return cmds;
        }
        for layer_idx in 0..self.get_layer_count() {
            if !self.get_layer_visible(layer_idx) {
                continue;
            }
            let Some((lw, lh)) = self.get_layer_dimensions(layer_idx) else {
                continue;
            };
            let [lt_r, lt_g, lt_b, lt_a] = self.get_layer_color(layer_idx);
            let (x_start, x_end, y_start, y_end) = match self.get_orientation() {
                MapOrientation::TopDown | MapOrientation::SideView => {
                    let tile_x0 = ((cam_x / tw).floor() as i64).max(0) as u32;
                    let tile_y0 = ((cam_y / th).floor() as i64).max(0) as u32;
                    let tile_x1_cam = ((cam_x + cam_w) / tw).ceil() as u32;
                    let tile_y1_cam = ((cam_y + cam_h) / th).ceil() as u32;
                    (
                        tile_x0.min(lw),
                        lw.min(tile_x1_cam),
                        tile_y0.min(lh),
                        lh.min(tile_y1_cam),
                    )
                }
                MapOrientation::Isometric | MapOrientation::Hexagonal => (0, lw, 0, lh),
            };
            for ty in y_start..y_end {
                for tx in x_start..x_end {
                    let source_gid = self.get_tile(layer_idx, tx, ty);
                    if source_gid == 0 {
                        continue;
                    }
                    if !self.tile_intersects_camera(tx, ty, tw, th, cam_x, cam_y, cam_w, cam_h) {
                        continue;
                    }
                    let gid = self.render_gid(source_gid);
                    let (world_x, world_y) = self.tile_origin_for_render(tx, ty, tw, th);
                    self.push_tile_render_commands(
                        &mut cmds,
                        gid,
                        {
                            let tint = self.effective_tile_tint(layer_idx, tx, ty);
                            [
                                tint[0] * lt_r,
                                tint[1] * lt_g,
                                tint[2] * lt_b,
                                tint[3] * lt_a,
                            ]
                        },
                        offset_x + world_x,
                        offset_y + world_y,
                        tw,
                        th,
                    );
                }
            }
        }
        cmds
    }
}
