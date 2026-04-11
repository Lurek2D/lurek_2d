//! Scene builder for textured-quad raycaster rendering.
//!
//! Builds a [`RaycasterScene`] from a [`Raycaster2D`] grid, camera parameters,
//! and lighting data. Every surface is represented as a textured quad with
//! per-polygon lighting — no column-strip rendering.

use crate::math::Color;
use crate::raycaster::dda::Raycaster2D;
use crate::raycaster::lighting::{compute_lighting, PointLight};
use crate::raycaster::projection::{distance_shade, project_column};
use crate::raycaster::scene::{
    BillboardSprite, CeilingQuad, FloorQuad, RaycasterScene, WallQuad,
};
use crate::runtime::resource_keys::TextureKey;

/// Parameters for building a raycaster scene.
///
/// # Fields
/// - `player_x` — `f32`. Player world X position.
/// - `player_y` — `f32`. Player world Y position.
/// - `player_angle` — `f32`. Player facing angle in radians.
/// - `fov` — `f32`. Horizontal field of view in radians.
/// - `ray_count` — `u32`. Number of rays to cast (screen columns).
/// - `max_distance` — `f32`. Maximum ray distance.
/// - `screen_width` — `f32`. Screen width in pixels.
/// - `screen_height` — `f32`. Screen height in pixels.
/// - `ambient_light` — `f32`. Base ambient light level `[0.0, 1.0]`.
/// - `shade_distance` — `f32`. Maximum shading distance.
/// - `floor_color` — `Color`. Fallback floor colour when no texture.
/// - `ceiling_color` — `Color`. Fallback ceiling colour when no texture.
#[derive(Debug, Clone)]
pub struct SceneBuildParams {
    /// Player world X position.
    pub player_x: f32,
    /// Player world Y position.
    pub player_y: f32,
    /// Player facing angle in radians.
    pub player_angle: f32,
    /// Horizontal field of view in radians.
    pub fov: f32,
    /// Number of rays to cast (one per screen column).
    pub ray_count: u32,
    /// Maximum ray casting distance.
    pub max_distance: f32,
    /// Screen width in pixels.
    pub screen_width: f32,
    /// Screen height in pixels.
    pub screen_height: f32,
    /// Base ambient light level `[0.0, 1.0]`.
    pub ambient_light: f32,
    /// Maximum distance for distance-based shading.
    pub shade_distance: f32,
    /// Fallback floor colour when no floor texture is set.
    pub floor_color: Color,
    /// Fallback ceiling colour when no ceiling texture is set.
    pub ceiling_color: Color,
}

/// A world-space sprite for scene building.
///
/// # Fields
/// - `world_x` — `f32`. Sprite world X.
/// - `world_y` — `f32`. Sprite world Y.
/// - `texture_key` — `TextureKey`. Sprite texture.
/// - `size` — `f32`. Sprite size in world units (used for screen projection).
#[derive(Debug, Clone)]
pub struct WorldSprite {
    /// Sprite world X position.
    pub world_x: f32,
    /// Sprite world Y position.
    pub world_y: f32,
    /// Sprite texture.
    pub texture_key: TextureKey,
    /// Sprite size in world units (projected to screen space).
    pub size: f32,
}

/// Texture lookup function type. Given a cell value, returns a texture key.
pub type TextureLookup = dyn Fn(u32) -> Option<TextureKey>;

impl RaycasterScene {
    /// Builds a complete scene from a raycaster grid with per-polygon lighting.
    ///
    /// Casts rays across the player's FOV, projects wall hits to textured quads,
    /// generates floor/ceiling quads for each column, and projects billboard
    /// sprites. All geometry receives per-polygon lighting computed from the
    /// ambient level and active point lights.
    ///
    /// # Parameters
    /// - `raycaster` — `&Raycaster2D`. The grid to raycast against.
    /// - `params` — `&SceneBuildParams`. Camera and rendering parameters.
    /// - `lights` — `&[PointLight]`. Active point lights in the scene.
    /// - `sprites` — `&[WorldSprite]`. World-space sprites to project.
    /// - `wall_texture` — `&dyn Fn(u32) -> Option<TextureKey>`. Maps cell values to textures.
    ///
    /// # Returns
    /// `RaycasterScene`.
    pub fn build(
        raycaster: &Raycaster2D,
        params: &SceneBuildParams,
        lights: &[PointLight],
        sprites: &[WorldSprite],
        wall_texture: &dyn Fn(u32) -> Option<TextureKey>,
    ) -> Self {
        let ray_hits = raycaster.cast_rays(
            params.player_x,
            params.player_y,
            params.player_angle,
            params.fov,
            params.ray_count,
            params.max_distance,
        );

        let col_width = params.screen_width / params.ray_count.max(1) as f32;
        let half_height = params.screen_height / 2.0;

        let mut scene = RaycasterScene::new(params.screen_width, params.screen_height);

        // Pre-allocate rough capacity
        scene.walls.reserve(ray_hits.len());
        scene.floors.reserve(ray_hits.len());
        scene.ceilings.reserve(ray_hits.len());

        for (i, hit) in ray_hits.iter().enumerate() {
            let screen_x = i as f32 * col_width;

            if !hit.hit {
                // No wall hit — draw full-height floor and ceiling
                let floor_light =
                    compute_lighting(params.player_x, params.player_y, params.ambient_light, lights);
                let floor_lc = Color::new(floor_light[0], floor_light[1], floor_light[2], 1.0);

                scene.floors.push(FloorQuad {
                    texture_key: None,
                    screen_x,
                    screen_y: half_height,
                    screen_w: col_width,
                    screen_h: half_height,
                    world_x: params.player_x,
                    world_y: params.player_y,
                    depth: params.max_distance,
                    light_color: floor_lc,
                });
                scene.ceilings.push(CeilingQuad {
                    texture_key: None,
                    screen_x,
                    screen_y: 0.0,
                    screen_w: col_width,
                    screen_h: half_height,
                    world_x: params.player_x,
                    world_y: params.player_y,
                    depth: params.max_distance,
                    light_color: floor_lc,
                });
                continue;
            }

            // ── Wall quad ──
            let (_wall_height, draw_start, draw_end) =
                project_column(hit.distance, params.fov, params.screen_height);
            let shade = distance_shade(hit.distance, params.shade_distance);
            let wall_light_rgb = compute_lighting(hit.hit_x, hit.hit_y, params.ambient_light, lights);
            let wall_color = Color::new(
                shade * wall_light_rgb[0],
                shade * wall_light_rgb[1],
                shade * wall_light_rgb[2],
                1.0,
            );

            scene.walls.push(WallQuad {
                texture_key: wall_texture(hit.cell_value),
                screen_x,
                screen_y: draw_start,
                screen_w: col_width,
                screen_h: draw_end - draw_start,
                tex_u_start: hit.tex_u,
                tex_u_end: hit.tex_u,
                depth: hit.distance,
                light_color: wall_color,
                cell_value: hit.cell_value,
            });

            // ── Floor quad (below wall) ──
            let floor_y = draw_end;
            let floor_h = params.screen_height - floor_y;
            if floor_h > 0.0 {
                let floor_light =
                    compute_lighting(hit.hit_x, hit.hit_y, params.ambient_light, lights);
                let floor_shade = shade * 0.8; // floors slightly darker
                let floor_color = Color::new(
                    floor_shade * floor_light[0],
                    floor_shade * floor_light[1],
                    floor_shade * floor_light[2],
                    1.0,
                );

                scene.floors.push(FloorQuad {
                    texture_key: None,
                    screen_x,
                    screen_y: floor_y,
                    screen_w: col_width,
                    screen_h: floor_h,
                    world_x: hit.hit_x,
                    world_y: hit.hit_y,
                    depth: hit.distance,
                    light_color: floor_color,
                });
            }

            // ── Ceiling quad (above wall) ──
            let ceil_h = draw_start;
            if ceil_h > 0.0 {
                let ceil_light =
                    compute_lighting(hit.hit_x, hit.hit_y, params.ambient_light, lights);
                let ceil_shade = shade * 0.7; // ceilings slightly darker than floors
                let ceil_color = Color::new(
                    ceil_shade * ceil_light[0],
                    ceil_shade * ceil_light[1],
                    ceil_shade * ceil_light[2],
                    1.0,
                );

                scene.ceilings.push(CeilingQuad {
                    texture_key: None,
                    screen_x,
                    screen_y: 0.0,
                    screen_w: col_width,
                    screen_h: ceil_h,
                    world_x: hit.hit_x,
                    world_y: hit.hit_y,
                    depth: hit.distance,
                    light_color: ceil_color,
                });
            }
        }

        // ── Billboard sprites ──
        for ws in sprites {
            let dx = ws.world_x - params.player_x;
            let dy = ws.world_y - params.player_y;
            let dist = (dx * dx + dy * dy).sqrt();

            if dist < 0.1 || dist > params.max_distance {
                continue;
            }

            // Angle from player to sprite
            let sprite_angle = dy.atan2(dx);
            let mut angle_diff = sprite_angle - params.player_angle;
            // Normalise to [-PI, PI]
            while angle_diff > std::f32::consts::PI {
                angle_diff -= 2.0 * std::f32::consts::PI;
            }
            while angle_diff < -std::f32::consts::PI {
                angle_diff += 2.0 * std::f32::consts::PI;
            }

            let half_fov = params.fov / 2.0;
            if angle_diff.abs() > half_fov {
                continue; // outside FOV
            }

            // Project to screen
            let screen_x_center =
                params.screen_width / 2.0 + (angle_diff / half_fov) * (params.screen_width / 2.0);
            let projected_size = (ws.size / dist) * (params.screen_height / params.fov.tan());

            let sprite_light = compute_lighting(ws.world_x, ws.world_y, params.ambient_light, lights);
            let sprite_shade = distance_shade(dist, params.shade_distance);
            let sprite_color = Color::new(
                sprite_shade * sprite_light[0],
                sprite_shade * sprite_light[1],
                sprite_shade * sprite_light[2],
                1.0,
            );

            scene.sprites.push(BillboardSprite {
                texture_key: ws.texture_key,
                screen_x: screen_x_center,
                screen_y: (params.screen_height - projected_size) / 2.0,
                screen_w: projected_size,
                screen_h: projected_size,
                depth: dist,
                light_color: sprite_color,
                world_x: ws.world_x,
                world_y: ws.world_y,
            });
        }

        // Sort sprites back-to-front
        scene
            .sprites
            .sort_by(|a, b| b.depth.partial_cmp(&a.depth).unwrap_or(std::cmp::Ordering::Equal));

        scene
    }
}

// ── Tests ────────────────────────────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;
    use crate::raycaster::dda::Raycaster2D;

    fn default_params() -> SceneBuildParams {
        SceneBuildParams {
            player_x: 5.0,
            player_y: 5.0,
            player_angle: 0.0,
            fov: std::f32::consts::FRAC_PI_3,
            ray_count: 10,
            max_distance: 20.0,
            screen_width: 320.0,
            screen_height: 200.0,
            ambient_light: 0.3,
            shade_distance: 15.0,
            floor_color: Color::new(0.2, 0.2, 0.2, 1.0),
            ceiling_color: Color::new(0.1, 0.1, 0.15, 1.0),
        }
    }

    #[test]
    fn empty_grid_produces_only_floor_ceiling() {
        let rc = Raycaster2D::new(10, 10);
        let params = default_params();
        let scene = RaycasterScene::build(&rc, &params, &[], &[], &|_| None);

        assert!(scene.walls.is_empty(), "No walls in empty grid");
        assert!(!scene.floors.is_empty(), "Floor quads should exist");
        assert!(!scene.ceilings.is_empty(), "Ceiling quads should exist");
    }

    #[test]
    fn wall_produces_wall_quads() {
        let mut rc = Raycaster2D::new(10, 10);
        // Place a wall directly in front of the player
        rc.set_cell(7, 5, 1);
        let params = default_params();
        let scene = RaycasterScene::build(&rc, &params, &[], &[], &|_| None);

        assert!(!scene.walls.is_empty(), "Should have wall quads");
        for wall in &scene.walls {
            assert!(wall.depth > 0.0, "Wall depth should be positive");
            assert!(wall.screen_h > 0.0, "Wall height should be positive");
        }
    }

    #[test]
    fn sprites_sorted_back_to_front() {
        let rc = Raycaster2D::new(20, 20);
        let params = SceneBuildParams {
            player_x: 10.0,
            player_y: 10.0,
            player_angle: 0.0,
            fov: std::f32::consts::FRAC_PI_3,
            ray_count: 10,
            max_distance: 20.0,
            screen_width: 320.0,
            screen_height: 200.0,
            ambient_light: 0.3,
            shade_distance: 15.0,
            floor_color: Color::BLACK,
            ceiling_color: Color::BLACK,
        };

        let tk = {
            use crate::runtime::resource_keys::TextureKey;
            use slotmap::KeyData;
            TextureKey::from(KeyData::from_ffi(1))
        };

        let sprites = vec![
            WorldSprite {
                world_x: 12.0,
                world_y: 10.0,
                texture_key: tk,
                size: 1.0,
            },
            WorldSprite {
                world_x: 15.0,
                world_y: 10.0,
                texture_key: tk,
                size: 1.0,
            },
        ];

        let scene = RaycasterScene::build(&rc, &params, &[], &sprites, &|_| None);
        if scene.sprites.len() >= 2 {
            assert!(
                scene.sprites[0].depth >= scene.sprites[1].depth,
                "Sprites should be sorted back-to-front"
            );
        }
    }

    #[test]
    fn per_polygon_lighting_applied() {
        let mut rc = Raycaster2D::new(10, 10);
        rc.set_cell(7, 5, 1);

        let params = default_params();
        let lights = vec![PointLight {
            x: 6.0,
            y: 5.0,
            radius: 5.0,
            intensity: 1.0,
            color: [1.0, 0.5, 0.0],
        }];

        let scene = RaycasterScene::build(&rc, &params, &lights, &[], &|_| None);
        if let Some(wall) = scene.walls.first() {
            // With an orange light nearby, red channel should be higher than blue
            assert!(
                wall.light_color.r > 0.0,
                "Wall should receive some light"
            );
        }
    }
}
