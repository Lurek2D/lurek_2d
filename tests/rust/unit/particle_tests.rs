//! Tests for the particle module.

use lurek2d::math::Color;
use lurek2d::particle::config::*;
use lurek2d::particle::emission::*;
use lurek2d::particle::emitter::ParticleSystem;
use lurek2d::particle::math::*;
use lurek2d::particle::particle::Particle;
use lurek2d::particle::shapes::ParticleShape;
use lurek2d::particle::trail::{Trail, TrailPoint};
use lurek2d::render::renderer::RenderCommand;
use lurek2d::render::DrawMode;

// ── config ────────────────────────────────────────────────────────────────────

mod config_tests {
    use super::*;

    #[test]
    fn default_config_pool_and_rate() {
        let cfg = ParticleConfig::default();
        assert_eq!(cfg.max_particles, 256);
        assert!((cfg.emission_rate - 10.0).abs() < f32::EPSILON);
    }

    #[test]
    fn default_config_lifetime_range() {
        let cfg = ParticleConfig::default();
        assert!(cfg.lifetime_min <= cfg.lifetime_max);
        assert!((cfg.lifetime_min - 1.0).abs() < f32::EPSILON);
        assert!((cfg.lifetime_max - 2.0).abs() < f32::EPSILON);
    }

    #[test]
    fn default_config_speed_range() {
        let cfg = ParticleConfig::default();
        assert!(cfg.speed_min <= cfg.speed_max);
    }

    #[test]
    fn default_config_sizes_and_colors() {
        let cfg = ParticleConfig::default();
        assert_eq!(cfg.sizes.len(), 2);
        assert_eq!(cfg.colors.len(), 2);
    }

    #[test]
    fn default_config_shape_is_square() {
        let cfg = ParticleConfig::default();
        assert_eq!(cfg.shape, ParticleShape::default());
    }

    #[test]
    fn area_distribution_default_is_none() {
        assert_eq!(AreaDistribution::default(), AreaDistribution::None);
    }

    #[test]
    fn insert_mode_default_is_top() {
        assert_eq!(InsertMode::default(), InsertMode::Top);
    }

    #[test]
    fn emission_shape_default_is_point() {
        assert_eq!(EmissionShape::default(), EmissionShape::Point);
    }

    #[test]
    fn relative_mode_default_is_detached() {
        assert_eq!(RelativeMode::default(), RelativeMode::Detached);
    }

    #[test]
    fn attractor_clone_preserves_fields() {
        let a = Attractor { x: 1.0, y: 2.0, strength: 50.0, radius: 100.0 };
        let b = a.clone();
        assert!((b.strength - 50.0).abs() < f32::EPSILON);
        assert!((b.radius - 100.0).abs() < f32::EPSILON);
    }

    #[test]
    fn bounce_bounds_clone_preserves_restitution() {
        let bb = BounceBounds {
            x_min: 0.0, x_max: 800.0,
            y_min: 0.0, y_max: 600.0,
            restitution: 0.7,
        };
        let c = bb.clone();
        assert!((c.restitution - 0.7).abs() < f32::EPSILON);
    }

    #[test]
    fn default_config_no_death_emitter() {
        let cfg = ParticleConfig::default();
        assert!(cfg.death_emitter.is_none());
        assert_eq!(cfg.death_burst_count, 0);
    }

    #[test]
    fn default_config_shape_helper_fields() {
        let cfg = ParticleConfig::default();
        assert_eq!(cfg.shrapnel_edges, 6);
        assert!((cfg.ray_aspect - 4.0).abs() < f32::EPSILON);
        assert!((cfg.ring_thickness - 0.2).abs() < f32::EPSILON);
    }
}

// ── emission ──────────────────────────────────────────────────────────────────

mod emission_tests {
    use super::*;

    #[test]
    fn emission_offset_none_is_zero() {
        let cfg = ParticleConfig {
            area_distribution: AreaDistribution::None,
            ..ParticleConfig::default()
        };
        let (dx, dy) = emission_offset(&cfg);
        assert!((dx).abs() < f32::EPSILON);
        assert!((dy).abs() < f32::EPSILON);
    }

    #[test]
    fn emission_offset_uniform_within_bounds() {
        let mut cfg = ParticleConfig::default();
        cfg.area_distribution = AreaDistribution::Uniform;
        cfg.area_width = 100.0;
        cfg.area_height = 50.0;
        for _ in 0..100 {
            let (dx, dy) = emission_offset(&cfg);
            assert!(dx.abs() <= 50.0 + 1e-3);
            assert!(dy.abs() <= 25.0 + 1e-3);
        }
    }

    #[test]
    fn emission_offset_ellipse_within_radius() {
        let mut cfg = ParticleConfig::default();
        cfg.area_distribution = AreaDistribution::Ellipse;
        cfg.area_width = 20.0;
        cfg.area_height = 20.0;
        for _ in 0..100 {
            let (dx, dy) = emission_offset(&cfg);
            let dist = (dx * dx + dy * dy).sqrt();
            assert!(dist <= 10.0 + 1e-3);
        }
    }

    #[test]
    fn emission_offset_area_angle_rotates() {
        let mut cfg = ParticleConfig::default();
        cfg.area_distribution = AreaDistribution::Uniform;
        cfg.area_width = 100.0;
        cfg.area_height = 0.0; // zero height — points lie on X axis
        cfg.area_angle = std::f32::consts::FRAC_PI_2; // rotate 90°
        let (dx, dy) = emission_offset(&cfg);
        // After 90° rotation, X component maps to Y
        assert!(dx.abs() < 1e-3 || dy.abs() > 0.0);
    }

    #[test]
    fn emission_shape_point_is_zero() {
        let (x, y) = emission_shape_offset(&EmissionShape::Point);
        assert!((x).abs() < f32::EPSILON);
        assert!((y).abs() < f32::EPSILON);
    }

    #[test]
    fn emission_shape_circle_edge_only() {
        let shape = EmissionShape::Circle { radius: 10.0, fill: false };
        for _ in 0..50 {
            let (x, y) = emission_shape_offset(&shape);
            let dist = (x * x + y * y).sqrt();
            assert!((dist - 10.0).abs() < 1e-3, "edge-only circle should be at radius");
        }
    }

    #[test]
    fn emission_shape_star_stays_bounded() {
        let shape = EmissionShape::Star { points: 5, outer_radius: 20.0, inner_radius: 10.0 };
        for _ in 0..100 {
            let (x, y) = emission_shape_offset(&shape);
            let dist = (x * x + y * y).sqrt();
            assert!(dist <= 20.0 + 1e-3);
        }
    }

    #[test]
    fn emission_shape_spiral_stays_bounded() {
        let shape = EmissionShape::Spiral { revolutions: 3.0, radius: 50.0 };
        for _ in 0..100 {
            let (x, y) = emission_shape_offset(&shape);
            let dist = (x * x + y * y).sqrt();
            assert!(dist <= 50.0 + 1e-3);
        }
    }

    #[test]
    fn border_rectangle_zero_perimeter_returns_zero() {
        let mut cfg = ParticleConfig::default();
        cfg.area_distribution = AreaDistribution::BorderRectangle;
        cfg.area_width = 0.0;
        cfg.area_height = 0.0;
        let (dx, dy) = emission_offset(&cfg);
        assert!((dx).abs() < f32::EPSILON);
        assert!((dy).abs() < f32::EPSILON);
    }
}

// ── math ──────────────────────────────────────────────────────────────────────

mod math_tests {
    use super::*;

    #[test]
    fn lerp_midpoint_is_average() {
        let result = lerp(0.0, 10.0, 0.5);
        assert!((result - 5.0).abs() < 1e-5);
    }

    #[test]
    fn interpolate_sizes_empty_returns_one() {
        assert!((interpolate_sizes(&[], 0.5, 0.0) - 1.0).abs() < 1e-5);
    }

    #[test]
    fn interpolate_sizes_single_value_with_zero_variation() {
        assert!((interpolate_sizes(&[4.0], 0.5, 0.0) - 4.0).abs() < 1e-5);
    }

    #[test]
    fn interpolate_sizes_multi_stop_at_start_and_end() {
        let sizes = [0.0f32, 10.0];
        assert!((interpolate_sizes(&sizes, 0.0, 0.0) - 0.0).abs() < 1e-5);
        assert!((interpolate_sizes(&sizes, 1.0, 0.0) - 10.0).abs() < 1e-5);
    }
}

// ── particle ──────────────────────────────────────────────────────────────────

mod particle_tests {
    use super::*;

    fn default_particle() -> Particle {
        Particle {
            x: 10.0,
            y: 20.0,
            vx: 1.0,
            vy: -2.0,
            life: 1.5,
            max_life: 3.0,
            rotation: 0.0,
            spin: 0.5,
            radial_accel: 0.0,
            tangential_accel: 0.0,
            linear_damping: 0.0,
            size_variation: 0.0,
            origin_x: 0.0,
            origin_y: 0.0,
            shape_seed: 42,
        }
    }

    #[test]
    fn particle_clone_preserves_fields() {
        let p = default_particle();
        let c = p.clone();
        assert!((c.x - 10.0).abs() < f32::EPSILON);
        assert!((c.vy - (-2.0)).abs() < f32::EPSILON);
        assert_eq!(c.shape_seed, 42);
    }

    #[test]
    fn particle_debug_format_contains_fields() {
        let p = default_particle();
        let dbg = format!("{:?}", p);
        assert!(dbg.contains("Particle"));
        assert!(dbg.contains("shape_seed"));
    }

    #[test]
    fn particle_life_ratio() {
        let p = default_particle();
        let ratio = 1.0 - (p.life / p.max_life);
        assert!((ratio - 0.5).abs() < f32::EPSILON);
    }
}

// ── shapes ────────────────────────────────────────────────────────────────────

mod shapes_tests {
    use super::*;

    #[test]
    fn default_shape_is_square() {
        assert_eq!(ParticleShape::default(), ParticleShape::Square);
    }

    #[test]
    fn shrapnel_edges_cloned() {
        let s = ParticleShape::Shrapnel { edges: 8 };
        let c = s.clone();
        assert_eq!(c, ParticleShape::Shrapnel { edges: 8 });
    }

    #[test]
    fn ray_aspect_preserved() {
        let s = ParticleShape::Ray { aspect: 6.0 };
        if let ParticleShape::Ray { aspect } = s {
            assert!((aspect - 6.0).abs() < f32::EPSILON);
        } else {
            panic!("expected Ray variant");
        }
    }

    #[test]
    fn ring_thickness_preserved() {
        let s = ParticleShape::Ring { thickness: 0.3 };
        if let ParticleShape::Ring { thickness } = s {
            assert!((thickness - 0.3).abs() < f32::EPSILON);
        } else {
            panic!("expected Ring variant");
        }
    }

    #[test]
    fn all_variants_are_debug_printable() {
        let variants: Vec<ParticleShape> = vec![
            ParticleShape::Square,
            ParticleShape::Circle,
            ParticleShape::Triangle,
            ParticleShape::Spark,
            ParticleShape::Diamond,
            ParticleShape::Shrapnel { edges: 5 },
            ParticleShape::Ray { aspect: 4.0 },
            ParticleShape::Puff,
            ParticleShape::Ring { thickness: 0.2 },
            ParticleShape::Capsule,
        ];
        for v in &variants {
            let _ = format!("{:?}", v);
        }
        assert_eq!(variants.len(), 10);
    }
}

// ── render ────────────────────────────────────────────────────────────────────

mod render_tests {
    use super::*;

    #[test]
    fn empty_system_gives_empty_commands() {
        let sys = ParticleSystem::new(ParticleConfig::default());
        let cmds = sys.generate_render_commands();
        assert!(
            cmds.is_empty(),
            "a new emitter with no particles should produce no commands"
        );
    }

    #[test]
    fn generate_render_commands_matches_build() {
        let sys = ParticleSystem::new(ParticleConfig::default());
        let a = sys.generate_render_commands();
        let b = sys.build_render_commands(0.0, 0.0);
        assert_eq!(
            a.len(),
            b.len(),
            "generate_render_commands must produce the same commands as build_render_commands(0, 0)"
        );
    }

    #[test]
    fn empty_trail_gives_empty_commands() {
        let trail = Trail::new(2.0, 4.0);
        let cmds: Vec<RenderCommand> = trail.generate_render_commands();
        assert!(cmds.is_empty(), "an empty trail should produce no commands");
    }
}

// ── trail ─────────────────────────────────────────────────────────────────────

mod trail_tests {
    use super::*;

    #[test]
    fn empty_trail_no_commands() {
        let trail = Trail::new(1.0, 4.0);
        let cmds = trail.build_render_commands();
        assert!(cmds.is_empty());
    }

    #[test]
    fn single_point_no_commands() {
        let mut trail = Trail::new(1.0, 4.0);
        trail.min_distance = 0.0;
        trail.points.push(TrailPoint { x: 0.0, y: 0.0, age: 0.0 });
        let cmds = trail.build_render_commands();
        assert!(cmds.is_empty());
    }

    #[test]
    fn two_points_produce_three_commands() {
        let mut trail = Trail::new(1.0, 4.0);
        trail.min_distance = 0.0;
        trail.points.push(TrailPoint { x: 0.0, y: 0.0, age: 0.0 });
        trail.points.push(TrailPoint { x: 10.0, y: 0.0, age: 0.5 });
        let cmds = trail.build_render_commands();
        // 1 segment = SetColor + 2 triangles = 3 commands
        assert_eq!(cmds.len(), 3);
        assert!(matches!(cmds[0], RenderCommand::SetColor(..)));
        assert!(matches!(cmds[1], RenderCommand::Triangle { mode: DrawMode::Fill, .. }));
        assert!(matches!(cmds[2], RenderCommand::Triangle { mode: DrawMode::Fill, .. }));
    }

    #[test]
    fn color_interpolation_midpoint() {
        let mut trail = Trail::new(2.0, 4.0);
        trail.head_color = Color::new(1.0, 0.0, 0.0, 1.0);
        trail.tail_color = Color::new(0.0, 1.0, 0.0, 1.0);
        trail.min_distance = 0.0;
        trail.points.push(TrailPoint { x: 0.0, y: 0.0, age: 0.0 });
        trail.points.push(TrailPoint { x: 10.0, y: 0.0, age: 2.0 });
        let cmds = trail.build_render_commands();
        match &cmds[0] {
            RenderCommand::SetColor(r, g, _b, _a) => {
                // Midpoint t=0.5: head(1,0,0) + 0.5*(tail-head) = (0.5, 0.5, 0)
                assert!((r - 0.5).abs() < 1e-5);
                assert!((g - 0.5).abs() < 1e-5);
            }
            other => panic!("Expected SetColor, got {:?}", other),
        }
    }

    #[test]
    fn width_tapering_at_tail() {
        let mut trail = Trail::new(1.0, 10.0);
        trail.end_width = 2.0;
        trail.min_distance = 0.0;
        // Head (age=0) → width 10, tail (age=1) → width 2
        trail.points.push(TrailPoint { x: 0.0, y: 0.0, age: 0.0 });
        trail.points.push(TrailPoint { x: 20.0, y: 0.0, age: 1.0 });
        let cmds = trail.build_render_commands();
        // The triangles should have different y-offsets at head vs tail
        match &cmds[1] {
            RenderCommand::Triangle { y1, y2, .. } => {
                // Head side should be wider (hw=5) than tail side (hw=1)
                assert!((y1.abs() - 5.0).abs() < 1e-5);
                assert!((y2.abs() - 5.0).abs() < 1e-5);
            }
            other => panic!("Expected Triangle, got {:?}", other),
        }
    }
}

// ── emitter (merged from emitter_tests.rs) ────────────────────────────────────

mod emitter_tests {
    use super::*;

    #[test]
    fn test_default_config() {
        let cfg = ParticleConfig::default();
        assert_eq!(cfg.max_particles, 256);
        assert!((cfg.emission_rate - 10.0).abs() < f32::EPSILON);
        assert_eq!(cfg.sizes.len(), 2);
        assert!((cfg.sizes[0] - 4.0).abs() < f32::EPSILON);
        assert!((cfg.sizes[1] - 1.0).abs() < f32::EPSILON);
        assert_eq!(cfg.colors.len(), 2);
    }

    #[test]
    fn test_system_creation() {
        let sys = ParticleSystem::new(ParticleConfig::default());
        assert_eq!(sys.count(), 0);
        assert!(sys.is_active());
    }

    #[test]
    fn test_update_emits_particles() {
        let mut cfg = ParticleConfig::default();
        cfg.emission_rate = 100.0;
        let mut sys = ParticleSystem::new(cfg);
        sys.update(1.0);
        assert!(sys.count() > 0);
    }

    #[test]
    fn test_particles_die() {
        let mut cfg = ParticleConfig::default();
        cfg.emission_rate = 100.0;
        cfg.lifetime_min = 0.1;
        cfg.lifetime_max = 0.1;
        let mut sys = ParticleSystem::new(cfg);
        sys.update(0.05);
        let count_after_emit = sys.count();
        assert!(count_after_emit > 0);
        sys.stop();
        sys.update(0.2);
        assert_eq!(sys.count(), 0);
    }

    #[test]
    fn test_inactive_no_emit() {
        let mut cfg = ParticleConfig::default();
        cfg.emission_rate = 1000.0;
        let mut sys = ParticleSystem::new(cfg);
        sys.stop();
        sys.update(1.0);
        assert_eq!(sys.count(), 0);
    }

    #[test]
    fn test_max_particles_cap() {
        let mut cfg = ParticleConfig::default();
        cfg.max_particles = 5;
        cfg.emission_rate = 1000.0;
        cfg.lifetime_min = 10.0;
        cfg.lifetime_max = 10.0;
        let mut sys = ParticleSystem::new(cfg);
        sys.update(1.0);
        assert!(sys.count() <= 5);
    }

    #[test]
    fn test_reset_clears_particles() {
        let mut cfg = ParticleConfig::default();
        cfg.emission_rate = 100.0;
        let mut sys = ParticleSystem::new(cfg);
        sys.update(1.0);
        assert!(sys.count() > 0);
        sys.reset();
        assert_eq!(sys.count(), 0);
    }

    #[test]
    fn test_draw_commands_count() {
        let mut cfg = ParticleConfig::default();
        cfg.emission_rate = 100.0;
        let mut sys = ParticleSystem::new(cfg);
        sys.update(1.0);
        let count = sys.count();
        assert!(count > 0);
        let cmds = sys.build_render_commands(0.0, 0.0);
        // All particles are batched into a single DrawParticleSystem command
        assert_eq!(cmds.len(), 1);
        if let RenderCommand::DrawParticleSystem { particles } = &cmds[0] {
            assert_eq!(particles.len(), count);
        } else {
            panic!("expected DrawParticleSystem");
        }
    }

    #[test]
    fn test_gravity_affects_velocity() {
        let mut cfg = ParticleConfig::default();
        cfg.emission_rate = 100.0;
        cfg.gravity_y = 100.0;
        cfg.speed_min = 0.0;
        cfg.speed_max = 0.0;
        let mut sys = ParticleSystem::new(cfg);
        sys.update(0.01);
        let initial_vy: Vec<f32> = sys.particles.iter().map(|p| p.vy).collect();
        sys.update(1.0);
        for (i, p) in sys.particles.iter().enumerate() {
            if i < initial_vy.len() {
                assert!(p.vy > initial_vy[i]);
            }
        }
    }

    #[test]
    fn test_lerp_basic() {
        assert!((lerp(0.0, 10.0, 0.0) - 0.0).abs() < f32::EPSILON);
        assert!((lerp(0.0, 10.0, 0.5) - 5.0).abs() < f32::EPSILON);
        assert!((lerp(0.0, 10.0, 1.0) - 10.0).abs() < f32::EPSILON);
    }

    #[test]
    fn test_interpolate_sizes_empty() {
        assert!((interpolate_sizes(&[], 0.5, 0.0) - 1.0).abs() < f32::EPSILON);
    }

    #[test]
    fn test_interpolate_sizes_single() {
        assert!((interpolate_sizes(&[5.0], 0.5, 0.0) - 5.0).abs() < f32::EPSILON);
    }

    #[test]
    fn test_interpolate_sizes_two_stops() {
        assert!((interpolate_sizes(&[10.0, 2.0], 0.0, 0.0) - 10.0).abs() < 1e-5);
        assert!((interpolate_sizes(&[10.0, 2.0], 0.5, 0.0) - 6.0).abs() < 1e-5);
        assert!((interpolate_sizes(&[10.0, 2.0], 1.0, 0.0) - 2.0).abs() < 1e-5);
    }

    #[test]
    fn test_interpolate_sizes_three_stops() {
        let sizes = [10.0, 20.0, 5.0];
        assert!((interpolate_sizes(&sizes, 0.0, 0.0) - 10.0).abs() < 1e-5);
        assert!((interpolate_sizes(&sizes, 0.25, 0.0) - 15.0).abs() < 1e-5);
        assert!((interpolate_sizes(&sizes, 0.5, 0.0) - 20.0).abs() < 1e-5);
        assert!((interpolate_sizes(&sizes, 1.0, 0.0) - 5.0).abs() < 1e-5);
    }

    #[test]
    fn test_interpolate_colors_empty() {
        let c = interpolate_colors(&[], 0.5);
        assert!((c[0] - 1.0).abs() < f32::EPSILON);
        assert!((c[3] - 1.0).abs() < f32::EPSILON);
    }

    #[test]
    fn test_interpolate_colors_two_stops() {
        let colors = [[1.0, 0.0, 0.0, 1.0], [0.0, 1.0, 0.0, 0.0]];
        let mid = interpolate_colors(&colors, 0.5);
        assert!((mid[0] - 0.5).abs() < 1e-5);
        assert!((mid[1] - 0.5).abs() < 1e-5);
        assert!((mid[2] - 0.0).abs() < 1e-5);
        assert!((mid[3] - 0.5).abs() < 1e-5);
    }

    #[test]
    fn test_emitter_state_transitions() {
        let mut sys = ParticleSystem::new(ParticleConfig::default());
        assert!(sys.is_active());
        sys.pause();
        assert!(sys.is_paused());
        sys.resume();
        assert!(sys.is_active());
        sys.stop();
        assert!(sys.is_stopped());
        sys.start();
        assert!(sys.is_active());
    }

    #[test]
    fn test_interpolate_alphas_empty() {
        assert!((interpolate_alphas(&[], 0.5) - 1.0).abs() < f32::EPSILON);
    }

    #[test]
    fn test_interpolate_alphas_single() {
        assert!((interpolate_alphas(&[0.5], 0.0) - 0.5).abs() < f32::EPSILON);
    }

    #[test]
    fn test_interpolate_alphas_two_stops() {
        assert!((interpolate_alphas(&[1.0, 0.0], 0.0) - 1.0).abs() < 1e-5);
        assert!((interpolate_alphas(&[1.0, 0.0], 0.5) - 0.5).abs() < 1e-5);
        assert!((interpolate_alphas(&[1.0, 0.0], 1.0) - 0.0).abs() < 1e-5);
    }

    #[test]
    fn test_interpolate_alphas_four_stops() {
        let alphas = [1.0, 0.9, 0.5, 0.0];
        assert!((interpolate_alphas(&alphas, 0.0) - 1.0).abs() < 1e-5);
        assert!((interpolate_alphas(&alphas, 1.0) - 0.0).abs() < 1e-5);
    }

    #[test]
    fn test_default_config_new_fields() {
        let cfg = ParticleConfig::default();
        assert!(cfg.alpha_keyframes.is_empty());
        assert_eq!(cfg.emission_shape, EmissionShape::Point);
        assert_eq!(cfg.relative_mode, RelativeMode::Detached);
    }

    #[test]
    fn test_emission_shape_circle() {
        let shape = EmissionShape::Circle {
            radius: 10.0,
            fill: true,
        };
        let (x, y) = emission_shape_offset(&shape);
        let dist = (x * x + y * y).sqrt();
        assert!(dist <= 10.0 + 1e-5);
    }

    #[test]
    fn test_emission_shape_rectangle() {
        let shape = EmissionShape::Rectangle {
            width: 20.0,
            height: 10.0,
        };
        let (x, y) = emission_shape_offset(&shape);
        assert!(x.abs() <= 10.0 + 1e-5);
        assert!(y.abs() <= 5.0 + 1e-5);
    }

    #[test]
    fn test_emission_shape_ring() {
        let shape = EmissionShape::Ring {
            inner_radius: 5.0,
            outer_radius: 10.0,
        };
        let (x, y) = emission_shape_offset(&shape);
        let dist = (x * x + y * y).sqrt();
        assert!(dist >= 5.0 - 1e-5);
        assert!(dist <= 10.0 + 1e-5);
    }

    #[test]
    fn test_emission_shape_line() {
        let shape = EmissionShape::Line {
            length: 20.0,
            angle: 0.0,
        };
        let (x, y) = emission_shape_offset(&shape);
        assert!(x.abs() <= 10.0 + 1e-5);
        assert!(y.abs() < 1e-5);
    }

    #[test]
    fn test_emission_shape_cone() {
        let shape = EmissionShape::Cone {
            radius: 10.0,
            angle: 0.0,
            spread: std::f32::consts::PI,
        };
        let (x, y) = emission_shape_offset(&shape);
        let dist = (x * x + y * y).sqrt();
        assert!(dist <= 10.0 + 1e-5);
    }

    #[test]
    fn test_clone_config() {
        let mut cfg = ParticleConfig::default();
        cfg.emission_rate = 42.0;
        cfg.alpha_keyframes = vec![1.0, 0.5, 0.0];
        cfg.emission_shape = EmissionShape::Circle {
            radius: 5.0,
            fill: true,
        };
        cfg.relative_mode = RelativeMode::Attached;
        let mut sys = ParticleSystem::new(cfg);
        sys.update(0.1);
        let cloned = sys.clone_config();
        assert_eq!(cloned.count(), 0);
        assert!((cloned.config.emission_rate - 42.0).abs() < 1e-5);
        assert_eq!(cloned.config.alpha_keyframes, vec![1.0, 0.5, 0.0]);
        assert_eq!(
            cloned.config.emission_shape,
            EmissionShape::Circle {
                radius: 5.0,
                fill: true
            }
        );
        assert_eq!(cloned.config.relative_mode, RelativeMode::Attached);
    }

    #[test]
    fn test_alpha_keyframes_override_in_draw() {
        let mut cfg = ParticleConfig::default();
        cfg.emission_rate = 100.0;
        cfg.alpha_keyframes = vec![1.0, 0.0]; // fade from 1 to 0
        cfg.lifetime_min = 1.0;
        cfg.lifetime_max = 1.0;
        let mut sys = ParticleSystem::new(cfg);
        sys.update(0.5); // emit some particles
        let cmds = sys.build_render_commands(0.0, 0.0);
        // Should have commands; alpha should be driven by alpha_keyframes
        assert!(!cmds.is_empty());
    }

    #[test]
    fn test_warm_up_fills_particles() {
        let mut cfg = ParticleConfig::default();
        cfg.emission_rate = 100.0;
        cfg.lifetime_min = 5.0;
        cfg.lifetime_max = 5.0;
        let mut sys = ParticleSystem::new(cfg);
        sys.warm_up(1.0);
        assert!(sys.count() > 0, "warm_up should have emitted particles");
    }

    #[test]
    fn test_warm_up_clamped_to_30s() {
        let mut cfg = ParticleConfig::default();
        cfg.max_particles = 5;
        cfg.emission_rate = 1.0;
        cfg.lifetime_min = 0.1;
        cfg.lifetime_max = 0.1;
        let mut sys = ParticleSystem::new(cfg);
        // 999 seconds should be clamped to 30 — must not hang
        sys.warm_up(999.0);
        // Just verify it returns without hanging
    }

    #[test]
    fn test_attractor_add_and_count() {
        let mut sys = ParticleSystem::new(ParticleConfig::default());
        assert_eq!(sys.attractor_count(), 0);
        sys.add_attractor(100.0, 200.0, 50.0, 300.0);
        sys.add_attractor(-50.0, 0.0, -30.0, 100.0);
        assert_eq!(sys.attractor_count(), 2);
    }

    #[test]
    fn test_attractor_clear() {
        let mut sys = ParticleSystem::new(ParticleConfig::default());
        sys.add_attractor(0.0, 0.0, 1.0, 10.0);
        sys.clear_attractors();
        assert_eq!(sys.attractor_count(), 0);
    }

    #[test]
    fn test_set_and_clear_bounds() {
        let mut sys = ParticleSystem::new(ParticleConfig::default());
        assert!(sys.bounce_bounds.is_none());
        sys.set_bounds(0.0, 800.0, 0.0, 600.0, 0.8);
        assert!(sys.bounce_bounds.is_some());
        let bb = sys.bounce_bounds.as_ref().unwrap();
        assert!((bb.restitution - 0.8).abs() < 1e-5);
        sys.clear_bounds();
        assert!(sys.bounce_bounds.is_none());
    }

    #[test]
    fn test_shape_seed_is_assigned() {
        let mut cfg = ParticleConfig::default();
        cfg.emission_rate = 100.0;
        cfg.lifetime_min = 5.0;
        cfg.lifetime_max = 5.0;
        let mut sys = ParticleSystem::new(cfg);
        sys.update(0.1);
        // All particles must have a shape_seed field (compile check is sufficient;
        // values may collide by random chance but the field must exist)
        for p in &sys.particles {
            let _seed: u32 = p.shape_seed; // type check
        }
        assert!(sys.count() > 0);
    }

    #[test]
    fn test_bounce_reverse_velocity() {
        let mut cfg = ParticleConfig::default();
        cfg.speed_min = 100.0;
        cfg.speed_max = 100.0;
        cfg.direction = 0.0; // rightward
        cfg.spread = 0.0;
        cfg.emission_rate = 1000.0;
        cfg.lifetime_min = 5.0;
        cfg.lifetime_max = 5.0;
        cfg.gravity_x = 0.0;
        cfg.gravity_y = 0.0;
        let mut sys = ParticleSystem::new(cfg);
        sys.set_bounds(-50.0, 50.0, -50.0, 50.0, 1.0);
        sys.update(0.01);
        // Run for a while — with right wall at 50 and speed=100, should bounce back
        for _ in 0..100 {
            sys.update(0.01);
        }
        // Particles should still be within (or very near) bounds
        for p in &sys.particles {
            let wx = p.x + sys.emitter_x;
            assert!(wx <= 55.0 && wx >= -55.0, "particle x {wx} should stay near bounds");
        }
    }
}
