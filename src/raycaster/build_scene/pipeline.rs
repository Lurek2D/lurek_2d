//! Owns the raycaster build scene pipeline implementation for the raycaster subsystem and keeps rules local here.
//! Keeps ray hits, scene data, and first-person render helpers so helpers stay close to invariants this file updates.
//! Defines how raycaster build scene pipeline data is validated, transformed, or stored before systems consume it.
//! Separates raycaster build scene pipeline behavior from Lua bindings, tests, and sibling owners so integration readable.
//! Documents the boundary where raycaster code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing raycaster build scene pipeline defaults, lifecycle handling, validation, or data rules.
//! Keeps failure paths and edge cases near raycaster build scene pipeline state that explains them instead of outward.

use super::*;

fn build_depth_columns(raycaster: &Raycaster2D, params: &SceneBuildParams) -> Vec<f32> {
    raycaster
        .cast_rays(
            params.player_x,
            params.player_y,
            params.player_angle,
            params.fov,
            params.ray_count.max(1),
            params.max_distance,
        )
        .into_iter()
        .map(|hit| hit.distance.max(0.0))
        .collect()
}

impl RaycasterScene {
    #[allow(clippy::too_many_arguments)]
    fn build_scene_into(
        &mut self,
        raycaster: &Raycaster2D,
        level_index: usize,
        params: &SceneBuildParams,
        lights: &[PointLight],
        sprites: &[WorldSprite],
        particle_emitters: &[RaycasterParticleEmitter],
        wall_texture: &dyn Fn(u32) -> Option<TextureKey>,
        wall_material: &dyn Fn(u32) -> Option<RaycasterMaterial>,
        wall_feature_at: &dyn Fn(u32, u32) -> Option<WallFeature>,
        floor_texture_at: &dyn Fn(u32, u32) -> Option<TextureKey>,
        ceiling_texture_at: &dyn Fn(u32, u32) -> Option<TextureKey>,
        floor_material_at: &dyn Fn(u32, u32) -> Option<RaycasterMaterial>,
        ceiling_material_at: &dyn Fn(u32, u32) -> Option<RaycasterMaterial>,
        floor_visible_at: &dyn Fn(u32, u32) -> bool,
        ceiling_visible_at: &dyn Fn(u32, u32) -> bool,
        roofed_at: &dyn Fn(u32, u32) -> bool,
        lowered_floor_at: &dyn Fn(u32, u32) -> Option<LoweredFloorCell>,
        lighting_cache: &mut LightingSampleCache,
        planes: VerticalPlanes,
    ) {
        let proj_dist = (params.screen_width * 0.5) / (params.fov * 0.5).tan();
        let wall_at = |x: i32, y: i32| -> bool {
            x < 0 || y < 0 || raycaster.blocks_render_light_at(x as u32, y as u32)
        };
        super::floors::build_floor_tiles(
            raycaster,
            level_index,
            params,
            proj_dist,
            planes,
            lights,
            &wall_at,
            floor_texture_at,
            ceiling_texture_at,
            floor_material_at,
            ceiling_material_at,
            floor_visible_at,
            ceiling_visible_at,
            roofed_at,
            lowered_floor_at,
            lighting_cache,
            &mut self.walls,
            &mut self.floors,
            &mut self.ceilings,
        );
        super::walls::build_wall_faces(
            raycaster,
            level_index,
            params,
            proj_dist,
            planes,
            lights,
            &wall_at,
            wall_texture,
            wall_material,
            wall_feature_at,
            ceiling_texture_at,
            ceiling_material_at,
            ceiling_visible_at,
            roofed_at,
            lowered_floor_at,
            lighting_cache,
            &mut self.walls,
        );
        self.build_level_sprites(
            raycaster,
            level_index,
            params,
            lights,
            &wall_at,
            roofed_at,
            lighting_cache,
            sprites,
            planes,
        );
        self.build_level_particles(level_index, params, particle_emitters, planes);
    }

    /// Build a complete `RaycasterScene` from camera params, lights, sprites, and texture lookups.
    #[allow(clippy::too_many_arguments)]
    pub fn build_with_scene_features(
        raycaster: &Raycaster2D,
        params: &SceneBuildParams,
        lights: &[PointLight],
        sprites: &[WorldSprite],
        particle_emitters: &[RaycasterParticleEmitter],
        wall_texture: &dyn Fn(u32) -> Option<TextureKey>,
        wall_material: &dyn Fn(u32) -> Option<RaycasterMaterial>,
        floor_texture_at: &dyn Fn(u32, u32) -> Option<TextureKey>,
        ceiling_texture_at: &dyn Fn(u32, u32) -> Option<TextureKey>,
        floor_material_at: &dyn Fn(u32, u32) -> Option<RaycasterMaterial>,
        ceiling_material_at: &dyn Fn(u32, u32) -> Option<RaycasterMaterial>,
        lowered_floor_at: &dyn Fn(u32, u32) -> Option<LoweredFloorCell>,
    ) -> Self {
        let mut scene = RaycasterScene::new(params.screen_width, params.screen_height);
        scene.background = params.background.clone();
        scene.overlays = params.overlays.clone();
        scene.time_seconds = params.time_seconds;
        let limits = RaycasterLimits::default();
        if params.validate(&limits).is_err()
            || limits
                .validate_scene_counts(sprites.len(), 0, lights.len())
                .is_err()
        {
            return scene;
        }
        scene.depth_columns = build_depth_columns(raycaster, params);
        let mut lighting_cache = LightingSampleCache::default();
        scene.build_scene_into(
            raycaster,
            0,
            params,
            lights,
            sprites,
            particle_emitters,
            wall_texture,
            wall_material,
            &|x, y| raycaster.wall_feature(x, y),
            floor_texture_at,
            ceiling_texture_at,
            floor_material_at,
            ceiling_material_at,
            &|_, _| true,
            &|_, _| true,
            &|x, y| ceiling_texture_at(x, y).is_some(),
            lowered_floor_at,
            &mut lighting_cache,
            vertical_planes(params.camera_height.clamp(0.1, 0.9), 0.0, 1.0),
        );
        scene.sprites.sort_by(|a, b| {
            b.depth
                .partial_cmp(&a.depth)
                .unwrap_or(std::cmp::Ordering::Equal)
        });
        scene.particles.sort_by(|a, b| {
            b.depth
                .partial_cmp(&a.depth)
                .unwrap_or(std::cmp::Ordering::Equal)
        });
        scene.build_stats = RaycasterBuildStats {
            wall_quads: scene.walls.len(),
            floor_quads: scene.floors.len(),
            ceiling_quads: scene.ceilings.len(),
            sprites: scene.sprites.len(),
            models: scene.models.len(),
            particles: scene.particles.len(),
            visible_levels: 1,
            depth_columns: scene.depth_columns.len(),
            ..lighting_cache.stats()
        };
        scene
    }

    /// Build a complete `RaycasterScene` from camera params, lights, sprites, and texture lookups.
    #[allow(clippy::too_many_arguments)]
    pub fn build(
        raycaster: &Raycaster2D,
        params: &SceneBuildParams,
        lights: &[PointLight],
        sprites: &[WorldSprite],
        wall_texture: &dyn Fn(u32) -> Option<TextureKey>,
        floor_texture_at: &dyn Fn(u32, u32) -> Option<TextureKey>,
        ceiling_texture_at: &dyn Fn(u32, u32) -> Option<TextureKey>,
        lowered_floor_at: &dyn Fn(u32, u32) -> Option<LoweredFloorCell>,
    ) -> Self {
        Self::build_with_scene_features(
            raycaster,
            params,
            lights,
            sprites,
            &[],
            wall_texture,
            &|_| None,
            floor_texture_at,
            ceiling_texture_at,
            &|_, _| None,
            &|_, _| None,
            lowered_floor_at,
        )
    }

    /// Build a complete `RaycasterScene` from a stack of raycaster levels sharing one camera.
    #[allow(clippy::too_many_arguments)]
    pub fn build_multilevel_with_scene_features(
        grid: &MultiLevelGrid,
        params: &SceneBuildParams,
        lights: &[PointLight],
        sprites: &[LevelSprite],
        particle_emitters: &[LevelParticleEmitter],
        wall_texture: &dyn Fn(usize, u32) -> Option<TextureKey>,
        wall_material: &dyn Fn(usize, u32) -> Option<RaycasterMaterial>,
        floor_texture_at: &dyn Fn(usize, u32, u32) -> Option<TextureKey>,
        ceiling_texture_at: &dyn Fn(usize, u32, u32) -> Option<TextureKey>,
        floor_material_at: &dyn Fn(usize, u32, u32) -> Option<RaycasterMaterial>,
        ceiling_material_at: &dyn Fn(usize, u32, u32) -> Option<RaycasterMaterial>,
        lowered_floor_at: &dyn Fn(usize, u32, u32) -> Option<LoweredFloorCell>,
    ) -> Self {
        let mut scene = RaycasterScene::new(params.screen_width, params.screen_height);
        scene.background = params.background.clone();
        scene.overlays = params.overlays.clone();
        scene.time_seconds = params.time_seconds;
        let limits = RaycasterLimits::default();
        if params.validate(&limits).is_err()
            || limits
                .validate_scene_counts(sprites.len(), 0, lights.len())
                .is_err()
        {
            return scene;
        }
        let mut lighting_cache = LightingSampleCache::default();
        let eye = params.camera_height.clamp(0.1, 0.9);
        let camera_world_z = grid
            .get_active()
            .map(|level| level.floor_offset + eye)
            .unwrap_or(eye);
        if let Some(active_depth) = grid.with_runtime_level(grid.active_level(), |_, raycaster| {
            build_depth_columns(raycaster, params)
        }) {
            scene.depth_columns = active_depth;
        }
        let level_count = grid.level_count();
        let mut sprites_by_level = vec![Vec::new(); level_count];
        for sprite in sprites {
            if sprite.level_index < level_count {
                sprites_by_level[sprite.level_index].push(sprite.sprite.clone());
            }
        }
        let mut emitters_by_level = vec![Vec::new(); level_count];
        for emitter in particle_emitters {
            if emitter.level_index < level_count {
                emitters_by_level[emitter.level_index].push(emitter.emitter.clone());
            }
        }
        let mut lights_by_level = vec![Vec::new(); level_count];
        for light in lights {
            match light.level_index {
                Some(level_index) if level_index < level_count => {
                    lights_by_level[level_index].push(light.clone());
                }
                Some(_) => {}
                None => {
                    for bucket in &mut lights_by_level {
                        bucket.push(light.clone());
                    }
                }
            }
        }

        let visible_levels =
            grid.visible_level_indices(params.player_x, params.player_y, params.max_distance);
        let visible_level_count = visible_levels.len();
        for level_index in visible_levels {
            let _ = grid.with_runtime_level(level_index, |level, raycaster| {
                scene.build_scene_into(
                    raycaster,
                    level_index,
                    params,
                    &lights_by_level[level_index],
                    &sprites_by_level[level_index],
                    &emitters_by_level[level_index],
                    &|cell_value| wall_texture(level_index, cell_value),
                    &|cell_value| wall_material(level_index, cell_value),
                    &|x, y| raycaster.wall_feature(x, y),
                    &|x, y| {
                        floor_texture_at(level_index, x, y)
                            .or_else(|| level.floor_texture_at(x as usize, y as usize))
                    },
                    &|x, y| {
                        ceiling_texture_at(level_index, x, y)
                            .or_else(|| level.ceiling_texture_at(x as usize, y as usize))
                    },
                    &|x, y| floor_material_at(level_index, x, y),
                    &|x, y| ceiling_material_at(level_index, x, y),
                    &|x, y| !level.is_floor_hole(x as usize, y as usize),
                    &|x, y| !level.is_ceiling_hole(x as usize, y as usize),
                    &|x, y| !level.is_ceiling_hole(x as usize, y as usize),
                    &|x, y| {
                        lowered_floor_at(level_index, x, y)
                            .or_else(|| level.lowered_floor(x as usize, y as usize))
                    },
                    &mut lighting_cache,
                    vertical_planes(camera_world_z, level.floor_offset, level.ceiling_height),
                );
            });
        }

        scene.sprites.sort_by(|a, b| {
            b.depth
                .partial_cmp(&a.depth)
                .unwrap_or(std::cmp::Ordering::Equal)
        });
        scene.particles.sort_by(|a, b| {
            b.depth
                .partial_cmp(&a.depth)
                .unwrap_or(std::cmp::Ordering::Equal)
        });
        scene.build_stats = RaycasterBuildStats {
            wall_quads: scene.walls.len(),
            floor_quads: scene.floors.len(),
            ceiling_quads: scene.ceilings.len(),
            sprites: scene.sprites.len(),
            models: scene.models.len(),
            particles: scene.particles.len(),
            visible_levels: visible_level_count,
            depth_columns: scene.depth_columns.len(),
            ..lighting_cache.stats()
        };
        scene
    }

    /// Build a complete `RaycasterScene` from a stack of raycaster levels sharing one camera.
    #[allow(clippy::too_many_arguments)]
    pub fn build_multilevel(
        grid: &MultiLevelGrid,
        params: &SceneBuildParams,
        lights: &[PointLight],
        sprites: &[LevelSprite],
        wall_texture: &dyn Fn(usize, u32) -> Option<TextureKey>,
        floor_texture_at: &dyn Fn(usize, u32, u32) -> Option<TextureKey>,
        ceiling_texture_at: &dyn Fn(usize, u32, u32) -> Option<TextureKey>,
        lowered_floor_at: &dyn Fn(usize, u32, u32) -> Option<LoweredFloorCell>,
    ) -> Self {
        Self::build_multilevel_with_scene_features(
            grid,
            params,
            lights,
            sprites,
            &[],
            wall_texture,
            &|_, _| None,
            floor_texture_at,
            ceiling_texture_at,
            &|_, _, _| None,
            &|_, _, _| None,
            lowered_floor_at,
        )
    }
}
