//! Owns the raycaster build scene sprites implementation for the raycaster subsystem and keeps rules local here.
//! Keeps ray hits, scene data, and first-person render helpers so helpers stay close to invariants this file updates.
//! Defines how raycaster build scene sprites data is validated, transformed, or stored before systems consume it.
//! Separates raycaster build scene sprites behavior from Lua bindings, tests, and sibling owners so integration readable.
//! Documents the boundary where raycaster code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing raycaster build scene sprites defaults, lifecycle handling, validation, or data rules.

use super::*;

impl RaycasterScene {
    #[allow(clippy::too_many_arguments)]
    /// Projects world sprites for one level into billboard draw data using cached lighting samples.
    pub(super) fn build_level_sprites(
        &mut self,
        raycaster: &Raycaster2D,
        level_index: usize,
        params: &SceneBuildParams,
        lights: &[PointLight],
        wall_at: &dyn Fn(i32, i32) -> bool,
        roofed_at: &dyn Fn(u32, u32) -> bool,
        lighting_cache: &mut LightingSampleCache,
        sprites: &[WorldSprite],
        planes: VerticalPlanes,
    ) {
        let floor_plane = planes.floor_plane;
        for ws in sprites {
            let dx = ws.world_x - params.player_x;
            let dy = ws.world_y - params.player_y;
            let dist = (dx * dx + dy * dy).sqrt();
            if dist < 0.1 || dist > params.max_distance {
                continue;
            }
            let sprite_angle = dy.atan2(dx);
            let angle_diff = normalize_signed_angle(sprite_angle - params.player_angle);
            let half_fov = params.fov / 2.0;
            if angle_diff.abs() > half_fov {
                continue;
            }
            let screen_x_center =
                params.screen_width / 2.0 + (angle_diff / half_fov) * (params.screen_width / 2.0);
            let horizon = params.screen_height * 0.5 - params.horizon_offset;
            let proj_dist = (params.screen_width * 0.5) / (params.fov * 0.5).tan();
            let base = project_horizontal_plane(
                ws.world_x,
                ws.world_y,
                params.player_x,
                params.player_y,
                params.player_angle.cos(),
                params.player_angle.sin(),
                proj_dist,
                params.screen_width,
                horizon,
                floor_plane,
            );
            let top = project_horizontal_plane(
                ws.world_x,
                ws.world_y,
                params.player_x,
                params.player_y,
                params.player_angle.cos(),
                params.player_angle.sin(),
                proj_dist,
                params.screen_width,
                horizon,
                floor_plane - ws.size,
            );
            let (_, base_y, _) = base;
            let (_, top_y, _) = top;
            let projected_size = (base_y - top_y).abs().max(1.0);
            let gx = ws
                .world_x
                .floor()
                .clamp(0.0, (raycaster.width().saturating_sub(1)) as f32)
                as u32;
            let gy = ws
                .world_y
                .floor()
                .clamp(0.0, (raycaster.height().saturating_sub(1)) as f32)
                as u32;
            let roofed_here = roofed_at(gx, gy);
            let sprite_light = lighting_cache.sample(
                level_index,
                ws.world_x,
                ws.world_y,
                roofed_here,
                params,
                lights,
                wall_at,
            );
            let sprite_shade = distance_shade(dist, params.shade_distance);
            let sprite_color = Color::new(
                sprite_shade * sprite_light[0],
                sprite_shade * sprite_light[1],
                sprite_shade * sprite_light[2],
                1.0,
            );
            let texture_key = ws
                .directional_textures
                .as_ref()
                .map(|textures| {
                    textures.select_texture(
                        params.player_x,
                        params.player_y,
                        ws.world_x,
                        ws.world_y,
                    )
                })
                .unwrap_or(ws.texture_key);
            self.sprites.push(BillboardSprite {
                corners: corners_from_rect(
                    screen_x_center - projected_size / 2.0,
                    base_y - projected_size,
                    projected_size,
                    projected_size,
                ),
                uvs: rect_uvs(),
                texture_key,
                light: color_to_light(&sprite_color),
                depth: dist,
                entity_id: ws.entity_id,
                level_index: ws.level_index,
                world_x: ws.world_x,
                world_y: ws.world_y,
                attrs: ws.attrs.clone(),
            });
        }
    }

    /// Synthesizes deterministic particle billboards for one level from authored emitter definitions.
    pub(super) fn build_level_particles(
        &mut self,
        level_index: usize,
        params: &SceneBuildParams,
        emitters: &[RaycasterParticleEmitter],
        planes: VerticalPlanes,
    ) {
        let floor_plane = planes.floor_plane;
        let half_fov = params.fov * 0.5;
        let horizon = params.screen_height * 0.5 - params.horizon_offset;
        let proj_dist = (params.screen_width * 0.5) / (params.fov * 0.5).tan();
        let cos_a = params.player_angle.cos();
        let sin_a = params.player_angle.sin();
        let screen_w = params.screen_width.max(1.0);
        let screen_h = params.screen_height.max(1.0);

        for emitter in emitters {
            if emitter.level_index != level_index {
                continue;
            }
            let rate = emitter.rate.max(0.0);
            if rate <= 0.0 {
                continue;
            }
            let min_lifetime = emitter.lifetime_range[0].max(0.05);
            let max_lifetime = emitter.lifetime_range[1].max(min_lifetime);
            let max_live = (rate * max_lifetime).ceil().clamp(1.0, 192.0) as i32;
            let last_spawn = (params.time_seconds.max(0.0) * rate).floor() as i32;
            let first_spawn = (last_spawn - max_live - 2).max(0);

            for spawn_index in first_spawn..=last_spawn {
                let spawn_time = spawn_index as f32 / rate;
                let age = params.time_seconds - spawn_time;
                if age < 0.0 {
                    continue;
                }

                let seed = hash_u32(
                    emitter.seed
                        ^ emitter.emitter_id.wrapping_mul(0x045d_9f3b)
                        ^ spawn_index as u32,
                );
                let lifetime = min_lifetime + (max_lifetime - min_lifetime) * random01(seed, 0);
                if age > lifetime {
                    continue;
                }
                let normalized_age = (age / lifetime).clamp(0.0, 1.0);
                let spawn_angle = random01(seed, 1) * std::f32::consts::TAU;
                let spawn_radius = emitter.radius.max(0.0) * random01(seed, 2).sqrt();
                let local_x = spawn_angle.cos() * spawn_radius;
                let local_y = spawn_angle.sin() * spawn_radius;
                let local_z = emitter.height.max(0.0) * random01(seed, 3);
                let velocity = [
                    emitter.velocity[0] + emitter.velocity_jitter[0] * random_signed(seed, 4),
                    emitter.velocity[1] + emitter.velocity_jitter[1] * random_signed(seed, 5),
                    emitter.velocity[2] + emitter.velocity_jitter[2] * random_signed(seed, 6),
                ];
                let world_x = emitter.world_x + local_x + velocity[0] * age;
                let world_y = emitter.world_y + local_y + velocity[1] * age;
                let world_z = emitter.world_z + local_z + velocity[2] * age;
                let dx = world_x - params.player_x;
                let dy = world_y - params.player_y;
                let depth = (dx * dx + dy * dy).sqrt();
                if depth < 0.05 || depth > params.max_distance + 1.0 {
                    continue;
                }
                let particle_angle = dy.atan2(dx);
                let angle_diff = normalize_signed_angle(particle_angle - params.player_angle);
                if angle_diff.abs() > half_fov {
                    continue;
                }
                let screen_x = params.screen_width * 0.5
                    + (angle_diff / half_fov) * (params.screen_width * 0.5);
                let sample_x = screen_x.clamp(0.0, screen_w - 1.0);
                if emitter.occlude_walls && !self.depth_columns.is_empty() {
                    let depth_index = ((sample_x / screen_w) * self.depth_columns.len() as f32)
                        .floor()
                        .clamp(0.0, self.depth_columns.len().saturating_sub(1) as f32)
                        as usize;
                    if depth > self.depth_columns[depth_index] + 0.05 {
                        continue;
                    }
                }
                let size_world = (emitter.size_range[0]
                    + (emitter.size_range[1] - emitter.size_range[0]) * random01(seed, 7))
                .max(0.05);
                let (_, base_y, _) = project_horizontal_plane(
                    world_x,
                    world_y,
                    params.player_x,
                    params.player_y,
                    cos_a,
                    sin_a,
                    proj_dist,
                    params.screen_width,
                    horizon,
                    floor_plane - world_z,
                );
                let (_, top_y, _) = project_horizontal_plane(
                    world_x,
                    world_y,
                    params.player_x,
                    params.player_y,
                    cos_a,
                    sin_a,
                    proj_dist,
                    params.screen_width,
                    horizon,
                    floor_plane - (world_z + size_world),
                );
                let projected_size = (base_y - top_y).abs().max(1.0);
                let screen_y = base_y - projected_size * 0.5;
                if screen_x + projected_size < 0.0
                    || screen_x - projected_size > params.screen_width
                    || screen_y + projected_size < 0.0
                    || screen_y - projected_size > screen_h
                {
                    continue;
                }

                let mut color = emitter.color;
                color[3] *= 1.0 - normalized_age;
                if color[3] <= 0.01 {
                    continue;
                }
                let rotation = match emitter.shape {
                    ParticleRenderShape::Spark | ParticleRenderShape::Ray { .. } => {
                        velocity[1].atan2(velocity[0])
                    }
                    _ => random01(seed, 8) * std::f32::consts::TAU + normalized_age * 1.5,
                };
                self.particles.push(RaycasterParticle {
                    x: screen_x,
                    y: screen_y,
                    rotation,
                    size: projected_size,
                    color,
                    shape: emitter.shape.clone(),
                    texture_key: emitter.texture_key,
                    quad: None,
                    quad_tex_dims: None,
                    local_x,
                    local_y,
                    velocity_x: velocity[0],
                    velocity_y: velocity[1],
                    normalized_age,
                    lifetime,
                    seed,
                    depth,
                    shader_key: emitter.shader_key,
                    blend_mode: emitter.blend_mode,
                    level_index,
                    emitter_id: emitter.emitter_id,
                });
            }
        }
    }
}
