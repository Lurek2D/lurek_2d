//! File: tests/rust/unit/light_tests.rs

// TODO(lua-first): public Rust API coverage in this file should live in tests/lua/unit/; keep only private/internal seams here.

use lurek2d::light::attenuation::Attenuation;
use lurek2d::light::flicker::FlickerConfig;
use lurek2d::light::light2d::Light2D;
use lurek2d::light::light_world::LightWorld;
use lurek2d::light::occluder::Occluder;
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
        Occluder::new(vec![
            Vec2::new(x, y),
            Vec2::new(x + w, y),
            Vec2::new(x + w, y + h),
            Vec2::new(x, y + h),
        ])
    }

    #[test]
    fn has_active_lights_reflects_enabled_flag() {
        let mut world = LightWorld::new();
        assert!(!world.has_active_lights());

        let key = world.add_light(Light2D::new(0.0, 0.0, 50.0));
        assert!(world.has_active_lights());

        world.get_light_mut(key).unwrap().set_enabled(false);
        assert!(!world.has_active_lights());
    }

    #[test]
    fn advance_flickers_updates_phase() {
        let mut world = LightWorld::new();
        let key = world.add_light(Light2D::new(0.0, 0.0, 50.0));
        world.get_light_mut(key).unwrap().flicker_mut().enabled = true;
        world.get_light_mut(key).unwrap().flicker_mut().speed = 2.0;
        world.reindex_flickers();

        world.advance_flickers(0.5);

        assert!(world.get_light(key).unwrap().flicker().phase > 0.0);
    }

    #[test]
    fn normal_map_hints_include_only_enabled_mapped_lights() {
        let mut world = LightWorld::new();

        let a = world.add_light(Light2D::new(10.0, 20.0, 30.0));
        {
            let la = world.get_light_mut(a).unwrap();
            la.set_normal_map_path("assets/textures/normals/brick.png".to_string());
            la.set_normal_strength(1.7);
        }

        let b = world.add_light(Light2D::new(40.0, 50.0, 60.0));
        world.get_light_mut(b).unwrap().set_enabled(false);
        world
            .get_light_mut(b)
            .unwrap()
            .set_normal_map_path("assets/textures/normals/off.png".to_string());

        let hints = world.normal_map_light_hints();
        assert_eq!(hints.len(), 1);
        assert_eq!(hints[0].x, 10.0);
        assert_eq!(hints[0].y, 20.0);
        assert_eq!(hints[0].path, "assets/textures/normals/brick.png");
        assert!((hints[0].strength - 1.7).abs() < 1e-6);
    }

    #[test]
    fn draw_to_image_casts_shadow_behind_enabled_occluder() {
        let mut world = LightWorld::new();
        world.ambient = lurek2d::color::Color::new(0.02, 0.02, 0.02, 1.0);

        let light_key = world.add_light(Light2D::new(50.0, 20.0, 110.0));
        {
            let light = world.get_light_mut(light_key).unwrap();
            light.set_shadow_enabled(true);
            light.set_intensity(1.8);
        }
        world.add_occluder(rectangle_occluder(40.0, 45.0, 20.0, 10.0));

        let img = world.draw_to_image(120, 120);
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

        let light_key = world.add_light(Light2D::new(50.0, 20.0, 110.0));
        {
            let light = world.get_light_mut(light_key).unwrap();
            light.set_shadow_enabled(true);
            light.set_intensity(1.8);
        }
        let occ_key = world.add_occluder(rectangle_occluder(0.0, 0.0, 20.0, 10.0));
        world
            .get_occluder_mut(occ_key)
            .unwrap()
            .set_position(Vec2::new(40.0, 45.0));

        let img = world.draw_to_image(120, 120);
        let shadowed = luminance(img.get_pixel(50, 92).unwrap());
        let lit_side = luminance(img.get_pixel(95, 92).unwrap());

        assert!(
            shadowed + 20 < lit_side,
            "expected positioned occluder to cast a shadow: shadowed={shadowed}, side={lit_side}"
        );
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
}
