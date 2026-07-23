//! File: tests/rust/unit/light_tests.rs

// TODO(lua-first): public Rust API coverage in this file should live in tests/lua/unit/; keep only private/internal seams here.

use lurek2d::light::attenuation::Attenuation;
use lurek2d::light::blend_mode::LightBlendMode;
use lurek2d::light::flicker::FlickerConfig;
use lurek2d::light::light2d::Light2D;
use lurek2d::light::light_type::LightType;
use lurek2d::light::light_world::LightWorld;
use lurek2d::light::occluder::Occluder;
use lurek2d::light::shadow::ShadowFilter;
use lurek2d::math::Vec2;

mod attenuation_tests {
    use super::*;

    #[test]
    fn factor_default_is_one_at_any_distance() {
        let attenuation = Attenuation::default();
        assert!((attenuation.factor(0.0) - 1.0).abs() < 1e-6);
        assert!((attenuation.factor(100.0) - 1.0).abs() < 1e-6);
    }

    #[test]
    fn factor_linear_decay() {
        let attenuation = Attenuation::new(1.0, 1.0, 0.0);
        assert!((attenuation.factor(1.0) - 0.5).abs() < 1e-6);
    }

    #[test]
    fn factor_quadratic_decay() {
        let attenuation = Attenuation::new(1.0, 0.0, 1.0);
        assert!((attenuation.factor(2.0) - 0.2).abs() < 1e-6);
    }

    #[test]
    fn factor_clamps_to_one_on_zero_denominator() {
        let attenuation = Attenuation::new(0.0, 0.0, 0.0);
        assert!((attenuation.factor(0.0) - 1.0).abs() < 1e-6);
    }
}

mod flicker_tests {
    use super::*;

    #[test]
    fn multiplier_disabled_is_one() {
        let flicker = FlickerConfig::default();
        assert!((flicker.multiplier() - 1.0).abs() < 1e-6);
    }

    #[test]
    fn multiplier_enabled_uses_sine() {
        let mut flicker = FlickerConfig::new(1.0, 0.5);
        flicker.phase = std::f32::consts::FRAC_PI_2;
        assert!((flicker.multiplier() - 1.5).abs() < 1e-4);
    }

    #[test]
    fn advance_does_nothing_when_disabled() {
        let mut flicker = FlickerConfig::default();
        flicker.advance(1.0);
        assert!((flicker.phase).abs() < 1e-6);
    }

    #[test]
    fn advance_increments_phase() {
        let mut flicker = FlickerConfig::new(2.0, 0.1);
        flicker.advance(0.5);
        assert!((flicker.phase - 1.0).abs() < 1e-6);
    }

    #[test]
    fn advance_wraps_phase_at_tau() {
        let mut flicker = FlickerConfig::new(1.0, 0.1);
        flicker.phase = std::f32::consts::TAU - 0.1;
        flicker.advance(1.0);
        assert!(flicker.phase < std::f32::consts::TAU);
    }
}

mod light_world_tests {
    use super::*;

    fn luminance(pixel: (u8, u8, u8, u8)) -> u16 {
        u16::from(pixel.0) + u16::from(pixel.1) + u16::from(pixel.2)
    }

    fn rectangle_occluder(x: f32, y: f32, w: f32, h: f32) -> Occluder {
        Occluder::try_new(vec![
            Vec2::new(x, y),
            Vec2::new(x + w, y),
            Vec2::new(x + w, y + h),
            Vec2::new(x, y + h),
        ])
        .unwrap()
    }

    #[test]
    fn occluder_rejects_non_finite_vertices_without_panicking() {
        let result = Occluder::try_new(vec![
            Vec2::new(0.0, 0.0),
            Vec2::new(f32::NAN, 1.0),
            Vec2::new(1.0, 0.0),
        ]);
        assert!(matches!(result, Err(message) if message.contains("finite")));
    }

    #[test]
    fn occluder_rejects_degenerate_and_concave_polygons() {
        let degenerate = Occluder::try_new(vec![
            Vec2::new(0.0, 0.0),
            Vec2::new(1.0, 0.0),
            Vec2::new(2.0, 0.0),
        ]);
        assert!(matches!(degenerate, Err(message) if message.contains("collinear")));

        let concave = Occluder::try_new(vec![
            Vec2::new(0.0, 0.0),
            Vec2::new(2.0, 0.0),
            Vec2::new(1.0, 0.5),
            Vec2::new(2.0, 2.0),
            Vec2::new(0.0, 2.0),
        ]);
        assert!(matches!(concave, Err(message) if message.contains("convex")));
    }

    #[test]
    fn checked_insert_limits_leave_world_unchanged() {
        let mut world = LightWorld::new();
        world.limits.max_registered_lights = 1;
        world.try_add_light(Light2D::new(0.0, 0.0, 10.0)).unwrap();
        assert!(world.try_add_light(Light2D::new(0.0, 0.0, 10.0)).is_err());
        assert_eq!(world.light_count(), 1);

        world.limits.max_registered_occluders = 0;
        assert!(world
            .try_add_occluder(rectangle_occluder(0.0, 0.0, 1.0, 1.0))
            .is_err());
        assert_eq!(world.occluder_count(), 0);
    }

    #[test]
    fn checked_public_insertion_rejects_non_finite_scene_values() {
        let mut world = LightWorld::new();
        assert!(world.add_light(Light2D::new(f32::NAN, 0.0, 10.0)).is_err());
        assert_eq!(world.light_count(), 0);

        let mut occluder = rectangle_occluder(0.0, 0.0, 1.0, 1.0);
        occluder.position = Vec2::new(f32::INFINITY, 0.0);
        assert!(world.add_occluder(occluder).is_err());
        assert_eq!(world.occluder_count(), 0);
    }

    #[test]
    fn renderer_selection_excludes_corrupted_non_finite_light_state() {
        let mut world = LightWorld::new();
        let key = world.add_light(Light2D::new(1.0, 2.0, 10.0)).unwrap();
        world.get_light_mut(key).unwrap().x = f32::NAN;
        assert!(world.selected_render_lights().is_empty());
    }

    #[test]
    fn preview_limit_is_checked_before_image_allocation() {
        let mut world = LightWorld::new();
        world.limits.max_debug_preview_pixels = 16;
        assert!(world.try_draw_to_image(5, 5).is_err());
    }

    #[test]
    fn preview_work_limit_counts_pcf_shadow_samples() {
        let mut world = LightWorld::new();
        let key = world.add_light(Light2D::new(0.0, 0.0, 10.0)).unwrap();
        let light = world.get_light_mut(key).unwrap();
        light.set_shadow_enabled(true);
        light.set_shadow_filter(ShadowFilter::Pcf13);
        world
            .add_occluder(rectangle_occluder(0.0, 0.0, 1.0, 1.0))
            .unwrap();
        // One direct sample + four occluder edges at 13 PCF taps = 53 work units per pixel.
        world.limits.max_debug_preview_work = 52;
        assert!(world.try_draw_to_image(1, 1).is_err());
    }

    #[test]
    fn clear_preserves_explicit_enable_state() {
        let mut world = LightWorld::new();
        world.set_enabled(true);
        world.add_light(Light2D::new(0.0, 0.0, 10.0)).unwrap();
        world.clear();
        assert!(world.enabled);
        assert_eq!(world.light_count(), 0);
    }

    #[test]
    fn explicit_disable_is_not_overridden_by_new_light() {
        let mut world = LightWorld::new();
        world.set_enabled(false);
        world.add_light(Light2D::new(0.0, 0.0, 10.0)).unwrap();
        assert!(!world.enabled);
    }

    #[test]
    fn renderer_selection_uses_stable_insertion_order_after_removal() {
        let mut world = LightWorld::new();
        world.max_lights = 2;
        let first = world.add_light(Light2D::new(1.0, 0.0, 10.0)).unwrap();
        world.add_light(Light2D::new(2.0, 0.0, 10.0)).unwrap();
        world.add_light(Light2D::new(3.0, 0.0, 10.0)).unwrap();
        let before: Vec<_> = world
            .selected_render_lights()
            .into_iter()
            .map(|(_, light)| light.x)
            .collect();
        assert!((before[0] - 1.0).abs() < 1e-6);
        assert!((before[1] - 2.0).abs() < 1e-6);

        world.remove_light(first);
        world.add_light(Light2D::new(4.0, 0.0, 10.0)).unwrap();
        let after: Vec<_> = world
            .selected_render_lights()
            .into_iter()
            .map(|(_, light)| light.x)
            .collect();
        assert!((after[0] - 2.0).abs() < 1e-6);
        assert!((after[1] - 3.0).abs() < 1e-6);
    }

    #[test]
    fn has_active_lights_reflects_enabled_flag() {
        let mut world = LightWorld::new();
        assert!(!world.has_active_lights());

        let key = world.add_light(Light2D::new(0.0, 0.0, 50.0)).unwrap();
        assert!(world.has_active_lights());

        world.get_light_mut(key).unwrap().set_enabled(false);
        assert!(!world.has_active_lights());
    }

    #[test]
    fn advance_flickers_updates_phase() {
        let mut world = LightWorld::new();
        let key = world.add_light(Light2D::new(0.0, 0.0, 50.0)).unwrap();
        world.get_light_mut(key).unwrap().flicker_mut().enabled = true;
        world.get_light_mut(key).unwrap().flicker_mut().speed = 2.0;
        world.reindex_flickers();

        world.advance_flickers(0.5);

        assert!(world.get_light(key).unwrap().flicker().phase > 0.0);
    }

    #[test]
    fn normal_map_hints_include_only_enabled_mapped_lights() {
        let mut world = LightWorld::new();

        let a = world.add_light(Light2D::new(10.0, 20.0, 30.0)).unwrap();
        {
            let la = world.get_light_mut(a).unwrap();
            la.set_normal_map_path("assets/textures/normals/brick.png".to_string());
            la.set_normal_strength(1.7);
        }

        let b = world.add_light(Light2D::new(40.0, 50.0, 60.0)).unwrap();
        world.get_light_mut(b).unwrap().set_enabled(false);
        world
            .get_light_mut(b)
            .unwrap()
            .set_normal_map_path("assets/textures/normals/off.png".to_string());

        let hints = world.normal_map_light_hints();
        assert_eq!(hints.len(), 1);
        assert!((hints[0].x - 10.0).abs() < 1e-6);
        assert!((hints[0].y - 20.0).abs() < 1e-6);
        assert_eq!(hints[0].path, "assets/textures/normals/brick.png");
        assert!((hints[0].strength - 1.7).abs() < 1e-6);
    }

    #[test]
    fn draw_to_image_casts_shadow_behind_enabled_occluder() {
        let mut world = LightWorld::new();
        world.ambient = lurek2d::color::Color::new(0.02, 0.02, 0.02, 1.0);

        let light_key = world.add_light(Light2D::new(50.0, 20.0, 110.0)).unwrap();
        {
            let light = world.get_light_mut(light_key).unwrap();
            light.set_shadow_enabled(true);
            light.set_intensity(1.8);
        }
        world
            .add_occluder(rectangle_occluder(40.0, 45.0, 20.0, 10.0))
            .unwrap();

        let img = world.draw_to_image(120, 120).unwrap();
        let shadowed = luminance(img.get_pixel(50, 92).unwrap());
        let lit_side = luminance(img.get_pixel(95, 92).unwrap());

        assert!(
            shadowed + 20 < lit_side,
            "expected occluder shadow pixel to be darker than side light: shadowed={shadowed}, side={lit_side}"
        );
    }

    #[test]
    fn draw_to_image_applies_occluder_position_to_shadow_geometry() {
        let mut world = LightWorld::new();
        world.ambient = lurek2d::color::Color::new(0.02, 0.02, 0.02, 1.0);

        let light_key = world.add_light(Light2D::new(50.0, 20.0, 110.0)).unwrap();
        {
            let light = world.get_light_mut(light_key).unwrap();
            light.set_shadow_enabled(true);
            light.set_intensity(1.8);
        }
        let occ_key = world
            .add_occluder(rectangle_occluder(0.0, 0.0, 20.0, 10.0))
            .unwrap();
        world
            .get_occluder_mut(occ_key)
            .unwrap()
            .set_position(Vec2::new(40.0, 45.0));

        let img = world.draw_to_image(120, 120).unwrap();
        let shadowed = luminance(img.get_pixel(50, 92).unwrap());
        let lit_side = luminance(img.get_pixel(95, 92).unwrap());

        assert!(
            shadowed + 20 < lit_side,
            "expected positioned occluder to cast a shadow: shadowed={shadowed}, side={lit_side}"
        );
    }

    #[test]
    fn shadow_mask_mismatch_does_not_block_light() {
        let mut world = LightWorld::new();
        world.ambient = lurek2d::color::Color::BLACK;
        let light_key = world.add_light(Light2D::new(16.0, 4.0, 40.0)).unwrap();
        let light = world.get_light_mut(light_key).unwrap();
        light.set_shadow_enabled(true);
        light.set_shadow_mask(0b0001);
        let mut occluder = rectangle_occluder(12.0, 12.0, 8.0, 4.0);
        occluder.set_light_mask(0b0010);
        world.add_occluder(occluder).unwrap();

        let image = world.draw_to_image(32, 32).unwrap();
        assert!(luminance(image.get_pixel(16, 24).unwrap()) > 20);
    }

    #[test]
    fn all_shadow_filters_render_bounded_previews() {
        for filter in [ShadowFilter::None, ShadowFilter::Pcf5, ShadowFilter::Pcf13] {
            let mut world = LightWorld::new();
            let light_key = world.add_light(Light2D::new(12.0, 4.0, 32.0)).unwrap();
            let light = world.get_light_mut(light_key).unwrap();
            light.set_shadow_enabled(true);
            light.set_shadow_filter(filter);
            world
                .add_occluder(rectangle_occluder(8.0, 12.0, 8.0, 4.0))
                .unwrap();
            assert!(world.draw_to_image(24, 24).is_ok());
        }
    }

    #[test]
    fn all_blend_modes_render_without_invalid_pixels() {
        for blend in [
            LightBlendMode::Add,
            LightBlendMode::Sub,
            LightBlendMode::Mix,
        ] {
            let mut world = LightWorld::new();
            let key = world.add_light(Light2D::new(8.0, 8.0, 16.0)).unwrap();
            world.get_light_mut(key).unwrap().set_blend_mode(blend);
            let image = world.draw_to_image(16, 16).unwrap();
            assert_eq!(image.get_pixel(8, 8).unwrap().3, 255);
        }
    }

    #[test]
    fn directional_lights_are_not_radius_clipped_in_preview() {
        let mut world = LightWorld::new();
        let key = world.add_light(Light2D::new(0.0, 0.0, 1.0)).unwrap();
        let light = world.get_light_mut(key).unwrap();
        light.set_light_type(LightType::Directional);
        light.set_intensity(1.0);

        let image = world.draw_to_image(32, 32).unwrap();
        assert!(luminance(image.get_pixel(31, 31).unwrap()) > 20);
    }
}

mod light_data_tests {
    use super::*;

    #[test]
    fn shadow_softness_round_trip() {
        let mut light = Light2D::new(0.0, 0.0, 10.0);
        light.set_shadow_softness(2.25);
        assert!((light.get_shadow_softness() - 2.25).abs() < 1e-6);
    }

    #[test]
    fn normal_map_path_and_strength_round_trip() {
        let mut light = Light2D::new(0.0, 0.0, 10.0);
        assert!(light.get_normal_map_path().is_none());

        light.set_normal_map_path("assets/textures/normals/torch.png".to_string());
        light.set_normal_strength(0.85);

        assert_eq!(
            light.get_normal_map_path(),
            Some("assets/textures/normals/torch.png")
        );
        assert!((light.get_normal_strength() - 0.85).abs() < 1e-6);

        light.clear_normal_map_path();
        assert!(light.get_normal_map_path().is_none());
    }

    #[test]
    fn cookie_path_is_authoritative_light_state() {
        let mut light = Light2D::new(0.0, 0.0, 10.0);
        assert!(light.get_cookie_path().is_none());
        light.set_cookie_path("assets/cookies/window.png".to_string());
        assert_eq!(light.get_cookie_path(), Some("assets/cookies/window.png"));
        light.clear_cookie_path();
        assert!(light.get_cookie_path().is_none());
    }

    #[test]
    fn transition_state_is_authoritative_light_state() {
        let mut light = Light2D::new(0.0, 0.0, 10.0);
        light.start_transition([0.5, 0.25, 0.75, 1.0], 2.0, 20.0, 2.0);
        assert!(light.advance_transition(1.0));
        assert!((light.transition_progress() - 0.5).abs() < 1e-6);
        assert!((light.get_radius() - 15.0).abs() < 1e-6);
        light.clear_transition();
        assert!((light.transition_progress() - 1.0).abs() < 1e-6);
    }
}
