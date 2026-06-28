//! File: tests/rust/unit/particle_tests.rs

// TODO(lua-first): public Rust API coverage in this file should live in tests/lua/unit/; keep only private/internal seams here.

use lurek2d::particle::visualization::draw_to_image;
use lurek2d::particle::{
    AreaDistribution, EmissionShape, ParticleConfig, ParticleError, ParticleLimits,
    ParticleRngVersion, ParticleSystem,
};

mod visualization_tests {
    use super::*;

    #[test]
    fn draw_to_image_correct_dimensions() {
        let ps = ParticleSystem::new(ParticleConfig::default());
        let img = draw_to_image(&ps, 80, 40);
        assert_eq!(img.width(), 80);
        assert_eq!(img.height(), 40);
    }
}

mod extensibility_tests {
    use lurek2d::particle::render::expand_particle_commands;
    use lurek2d::particle::{EmissionShape, ParticleConfig, ParticleSystem};
    use lurek2d::render::renderer::{ParticleInstance, ParticleRenderShape, RenderCommand};
    use lurek2d::runtime::resource_keys::{ShaderKey, TextureKey};

    #[test]
    fn custom_emission_shape_variant_exists() {
        let shape = EmissionShape::Custom { callback_id: 99 };
        match shape {
            EmissionShape::Custom { callback_id } => assert_eq!(callback_id, 99),
            _ => panic!("unexpected variant"),
        }
    }

    #[test]
    fn pending_deaths_drained_after_update() {
        let config = ParticleConfig {
            lifetime_min: 0.001,
            lifetime_max: 0.001,
            emission_rate: 0.0,
            ..Default::default()
        };
        let mut ps = ParticleSystem::new(config);
        ps.emit(3);
        ps.update(1.0); // enough time to kill all 3
        let deaths = ps.drain_pending_deaths();
        assert!(
            !deaths.is_empty(),
            "should have deaths recorded after all particles expire"
        );
    }

    #[test]
    fn drain_custom_offsets_clears_vec() {
        let config = ParticleConfig {
            emission_shape: EmissionShape::Custom { callback_id: 1 },
            emission_rate: 0.0,
            ..Default::default()
        };
        let mut ps = ParticleSystem::new(config);
        ps.emit(2);
        let offsets = ps.drain_custom_offsets();
        assert_eq!(offsets.len(), 2);
        assert!(
            ps.drain_custom_offsets().is_empty(),
            "second drain should be empty"
        );
    }

    #[test]
    fn build_render_commands_keeps_sub_emitter_output_when_parent_is_empty() {
        let death_emitter = ParticleConfig {
            emission_rate: 0.0,
            max_particles: 8,
            lifetime_min: 1.0,
            lifetime_max: 1.0,
            speed_min: 0.0,
            speed_max: 0.0,
            ..ParticleConfig::default()
        };
        let config = ParticleConfig {
            emission_rate: 0.0,
            max_particles: 4,
            lifetime_min: 0.001,
            lifetime_max: 0.001,
            death_burst_count: 3,
            death_emitter: Some(Box::new(death_emitter)),
            ..ParticleConfig::default()
        };

        let mut ps = ParticleSystem::new(config);
        ps.emit(1);
        ps.update(0.01);

        assert_eq!(ps.count(), 0, "parent particles should be dead");
        assert!(
            ps.sub_system_count() > 0,
            "death emitter should spawn a child system"
        );

        let cmds = ps.build_render_commands(0.0, 0.0);
        assert!(
            cmds.iter()
                .any(|cmd| matches!(cmd, RenderCommand::DrawParticleSystem { .. })),
            "sub-system particles should still render"
        );
    }

    #[test]
    fn shadered_textured_particles_stay_on_particle_shader_path() {
        let particle = ParticleInstance {
            x: 10.0,
            y: 20.0,
            r: 1.0,
            g: 1.0,
            b: 1.0,
            a: 1.0,
            rotation: 0.0,
            size: 8.0,
            shape: ParticleRenderShape::Square,
            texture_key: Some(TextureKey::default()),
            quad: Some([0.0, 0.0, 8.0, 8.0]),
            quad_tex_dims: Some((8.0, 8.0)),
            local_x: 1.0,
            local_y: 2.0,
            velocity_x: 3.0,
            velocity_y: 4.0,
            normalized_age: 0.5,
            lifetime: 2.0,
            seed: 123,
        };
        let expanded = expand_particle_commands(vec![RenderCommand::DrawParticleSystem {
            particles: vec![particle],
            shader: Some(ShaderKey::default()),
        }]);

        assert!(matches!(
            expanded.as_slice(),
            [RenderCommand::DrawParticleSystem {
                shader: Some(_),
                ..
            }]
        ));
    }

    #[test]
    fn set_max_particles_truncates_live_pool_when_shrinking() {
        let mut ps = ParticleSystem::new(ParticleConfig {
            emission_rate: 0.0,
            max_particles: 16,
            ..ParticleConfig::default()
        });
        ps.emit(10);
        assert_eq!(ps.count(), 10);

        ps.set_max_particles(4);

        assert_eq!(ps.config.max_particles, 4);
        assert_eq!(
            ps.count(),
            4,
            "live particles should be truncated to the new limit"
        );
    }
}

mod distribution_and_fuzz_tests {
    use super::*;
    use lurek2d::particle::emission::emission_offset;
    use lurek2d::particle::presets;

    #[test]
    fn border_rectangle_emission_is_edge_biased() {
        let cfg = ParticleConfig {
            area_distribution: AreaDistribution::BorderRectangle,
            area_width: 100.0,
            area_height: 80.0,
            ..ParticleConfig::default()
        };

        let mut edge_hits = 0;
        let samples = 5000;
        let hw = cfg.area_width * 0.5;
        let hh = cfg.area_height * 0.5;
        let mut rng_state = 1;
        for _ in 0..samples {
            let (x, y) = emission_offset(&cfg, &mut rng_state);
            let on_vertical = (x.abs() - hw).abs() < 1e-3;
            let on_horizontal = (y.abs() - hh).abs() < 1e-3;
            if on_vertical || on_horizontal {
                edge_hits += 1;
            }
        }
        assert!(
            edge_hits > (samples as f32 * 0.98) as usize,
            "expected almost all samples on rectangle border"
        );
    }

    #[test]
    fn presets_build_valid_configs() {
        let all = [
            presets::fire(),
            presets::smoke(),
            presets::rain(),
            presets::snow(),
            presets::sparks(),
        ];
        for cfg in all {
            let ps = ParticleSystem::new(cfg);
            assert!(ps.config.max_particles > 0);
        }
    }

    #[test]
    fn randomized_particle_update_does_not_panic() {
        for i in 0..200 {
            let mut cfg = ParticleConfig {
                max_particles: 16 + (i % 64) as u32,
                emission_rate: (i % 120) as f32,
                lifetime_min: 0.01,
                lifetime_max: 0.5 + (i as f32 * 0.001),
                speed_min: 0.0,
                speed_max: 250.0,
                spread: std::f32::consts::PI,
                drag: (i % 10) as f32 * 0.02,
                turbulence: (i % 8) as f32 * 1.5,
                ..ParticleConfig::default()
            };
            if i % 3 == 0 {
                cfg.area_distribution = AreaDistribution::BorderRectangle;
                cfg.area_width = 20.0 + i as f32;
                cfg.area_height = 15.0 + i as f32 * 0.5;
            }

            let mut ps = ParticleSystem::new(cfg);
            ps.emit(10);
            for _ in 0..8 {
                ps.update(1.0 / 120.0);
            }
        }
    }
}

mod safety_and_determinism_tests {
    use super::*;

    fn short_lived_config() -> ParticleConfig {
        ParticleConfig {
            emission_rate: 0.0,
            max_particles: 4,
            lifetime_min: 0.001,
            lifetime_max: 0.001,
            speed_min: 0.0,
            speed_max: 0.0,
            ..ParticleConfig::default()
        }
    }

    #[test]
    fn particle_try_new_rejects_huge_max_particles() {
        let limits = ParticleLimits {
            max_particles_per_system: 32,
            ..ParticleLimits::default()
        };
        let err = ParticleSystem::try_new(
            ParticleConfig {
                max_particles: 1_000,
                ..ParticleConfig::default()
            },
            &limits,
        )
        .expect_err("strict constructor should reject huge max_particles");
        assert!(matches!(err, ParticleError::InvalidConfig { .. }));
    }

    #[test]
    fn death_emitter_depth_limit_prevents_runaway() {
        let leaf = ParticleConfig {
            death_burst_count: 1,
            ..short_lived_config()
        };
        let child = ParticleConfig {
            death_burst_count: 1,
            death_emitter: Some(Box::new(leaf)),
            ..short_lived_config()
        };
        let root = ParticleConfig {
            death_burst_count: 1,
            death_emitter: Some(Box::new(child)),
            ..short_lived_config()
        };

        let mut ps = ParticleSystem::new(root);
        ps.limits = ParticleLimits {
            max_sub_emitter_depth: 1,
            max_sub_systems: 16,
            max_sub_systems_per_update: 16,
            max_total_particles: 16,
            ..ParticleLimits::default()
        };

        ps.emit(1);
        for _ in 0..6 {
            ps.update(0.01);
        }

        let stats = ps.stats();
        let child_drops = ps
            .sub_systems
            .iter()
            .chain(ps.recycled_sub_systems.iter())
            .map(|sub| sub.stats().dropped_sub_emitters)
            .sum::<u64>();
        assert!(
            stats.dropped_sub_emitters + child_drops > 0,
            "depth limit should drop recursive child spawns"
        );
        assert!(
            stats.total_live_particles <= ps.limits.max_total_particles,
            "live particle count should stay within the configured total budget"
        );
    }

    #[test]
    fn pending_custom_offsets_stable_with_random_insert() {
        let mut ps = ParticleSystem::new(ParticleConfig {
            emission_rate: 0.0,
            max_particles: 8,
            seed: Some(7),
            insert_mode: lurek2d::particle::InsertMode::Random,
            emission_shape: EmissionShape::Custom { callback_id: 11 },
            ..ParticleConfig::default()
        });

        ps.emit(3);
        let original_ids: Vec<u64> = ps.particles.iter().map(|particle| particle.id).collect();
        ps.emit(3);

        let pending = ps.drain_custom_offsets();
        assert_eq!(pending.len(), 6, "all spawned particles should be pending");

        for (idx, particle_id) in pending.iter().enumerate() {
            assert!(
                ps.apply_custom_offset(*particle_id, idx as f32 + 10.0, -(idx as f32)),
                "stable particle id should still resolve after random inserts"
            );
        }

        for (idx, particle_id) in pending.iter().enumerate() {
            let particle = ps
                .particles
                .iter()
                .find(|particle| particle.id == *particle_id)
                .expect("particle id should still exist");
            assert_eq!(particle.x, idx as f32 + 10.0);
            assert_eq!(particle.y, -(idx as f32));
        }
        assert!(
            original_ids.iter().all(|particle_id| ps
                .particles
                .iter()
                .any(|particle| particle.id == *particle_id)),
            "random inserts should not lose existing particles"
        );
    }

    #[test]
    fn from_toml_rejects_nested_death_emitter_over_limit() {
        let toml = r#"
max_particles = 4
death_burst_count = 1

[death_emitter]
max_particles = 4
death_burst_count = 1

[death_emitter.death_emitter]
max_particles = 4
"#;

        let limits = ParticleLimits {
            max_sub_emitter_depth: 1,
            ..ParticleLimits::default()
        };
        let err = ParticleConfig::from_toml_str_with_limits(toml, &limits)
            .expect_err("strict TOML parser should reject configs deeper than the limit");
        assert!(matches!(err, ParticleError::InvalidConfig { .. }));
    }

    #[test]
    fn config_validate_reports_sanitized_values() {
        let warnings = ParticleConfig {
            speed_min: -1.0,
            speed_max: f32::NAN,
            colors: vec![[f32::NAN, 0.0, 0.0, 1.0]],
            quads: vec![[0.0, 0.0, -8.0, 4.0]],
            ..ParticleConfig::default()
        }
        .validate();

        assert!(warnings.iter().any(|warning| warning.field == "speed"));
        assert!(warnings.iter().any(|warning| warning.field == "colors"));
        assert!(warnings.iter().any(|warning| warning.field == "quads"));
    }

    #[test]
    fn same_seed_same_particle_snapshot() {
        let config = ParticleConfig {
            emission_rate: 0.0,
            max_particles: 8,
            lifetime_min: 1.0,
            lifetime_max: 1.0,
            speed_min: 12.0,
            speed_max: 12.0,
            direction: 0.25,
            spread: 0.5,
            seed: Some(42),
            ..ParticleConfig::default()
        };
        let mut a = ParticleSystem::new(config.clone());
        let mut b = ParticleSystem::new(config);

        assert_eq!(ParticleRngVersion::V1, a.rng_version());
        assert_eq!(a.get_rng_state(), b.get_rng_state());

        a.emit(6);
        b.emit(6);
        a.update(0.25);
        b.update(0.25);

        let snapshot_a: Vec<(f32, f32, f32, f32)> = a
            .particles
            .iter()
            .map(|particle| (particle.x, particle.y, particle.vx, particle.vy))
            .collect();
        let snapshot_b: Vec<(f32, f32, f32, f32)> = b
            .particles
            .iter()
            .map(|particle| (particle.x, particle.y, particle.vx, particle.vy))
            .collect();

        assert_eq!(
            snapshot_a, snapshot_b,
            "same seed should produce identical snapshots"
        );
    }

    #[test]
    fn add_attractor_rejects_nan_and_limit() {
        let limits = ParticleLimits {
            max_attractors: 1,
            ..ParticleLimits::default()
        };
        let mut ps = ParticleSystem::try_new(ParticleConfig::default(), &limits)
            .expect("strict constructor should succeed for the default config");

        assert!(ps.try_add_attractor(f32::NAN, 0.0, 1.0, 1.0).is_err());
        ps.try_add_attractor(0.0, 0.0, 5.0, 8.0)
            .expect("first attractor should succeed");
        assert!(ps.try_add_attractor(1.0, 1.0, 2.0, 4.0).is_err());
    }
}
