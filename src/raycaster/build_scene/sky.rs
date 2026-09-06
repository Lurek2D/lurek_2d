//! Builds elevated layered-sky tiles using the same world-to-screen projection as ceilings.
//! This module owns map-cell iteration and plane-height selection; UV seam subdivision remains
//! in the sibling `raycaster::sky` helper so GPU and CPU presentation consume identical quads.

use super::*;
use crate::raycaster::scene::{RaycasterSkyLayer, RaycasterSkyQuad};

/// Emit elevated sky-plane tiles over the open cells visible from the current camera.
pub(super) fn build_sky_tiles(
    raycaster: &Raycaster2D,
    params: &SceneBuildParams,
    planes: VerticalPlanes,
    layers: &[RaycasterSkyLayer],
    sky_quads: &mut Vec<RaycasterSkyQuad>,
) {
    if layers.is_empty() {
        return;
    }
    let proj_dist = (params.screen_width * 0.5) / (params.fov * 0.5).tan();
    let cos_a = params.player_angle.cos();
    let sin_a = params.player_angle.sin();
    let px = params.player_x;
    let py = params.player_y;
    let map_w = raycaster.width() as i32;
    let map_h = raycaster.height() as i32;
    if map_w <= 0 || map_h <= 0 {
        return;
    }
    let max_distance = params.max_distance.max(0.0);
    let tx0 = ((px - max_distance - 1.0).floor() as i32).max(0);
    let ty0 = ((py - max_distance - 1.0).floor() as i32).max(0);
    let tx1 = ((px + max_distance + 1.0).ceil() as i32).min(map_w - 1);
    let ty1 = ((py + max_distance + 1.0).ceil() as i32).min(map_h - 1);
    let camera_world = Vec2::new(px, py);

    for ty in ty0..=ty1 {
        for tx in tx0..=tx1 {
            if raycaster.get_cell(tx as u32, ty as u32) != 0 {
                continue;
            }
            let tile_center = Vec2::new(tx as f32 + 0.5, ty as f32 + 0.5);
            let dx = tile_center.x - px;
            let dy = tile_center.y - py;
            if (dx * dx + dy * dy).sqrt() > max_distance + 1.5 {
                continue;
            }
            let world_corners = [
                Vec2::new(tx as f32, ty as f32),
                Vec2::new(tx as f32 + 1.0, ty as f32),
                Vec2::new(tx as f32 + 1.0, ty as f32 + 1.0),
                Vec2::new(tx as f32, ty as f32 + 1.0),
            ];
            for layer in layers {
                if !layer.height.is_finite() || layer.height <= 0.0 || layer.copies == 0 {
                    continue;
                }
                let sky_plane = planes.floor_plane - layer.height;
                if sky_plane >= -FLOOR_NEAR {
                    continue;
                }
                let projected = world_corners.map(|world| {
                    project_ground_point(
                        world.x,
                        world.y,
                        px,
                        py,
                        cos_a,
                        sin_a,
                        proj_dist,
                        params.screen_width,
                        params.screen_height * 0.5 - params.horizon_offset,
                        planes.floor_plane,
                        sky_plane,
                    )
                });
                if projected.iter().all(|point| point.cx <= FLOOR_NEAR) {
                    continue;
                }
                let screen_corners = projected.map(|point| Vec2::new(point.sx, point.ceil_y));
                let corner_w = projected.map(|point| point.cx);
                sky_quads.extend(crate::raycaster::sky::project_sky_tile(
                    layer,
                    screen_corners,
                    corner_w,
                    world_corners,
                    camera_world,
                    params.time_seconds,
                    [1.0, 1.0, 1.0, 1.0],
                ));
            }
        }
    }
}
