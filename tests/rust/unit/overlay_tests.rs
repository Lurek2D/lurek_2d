//! File: tests/rust/unit/overlay_tests.rs

use lurek2d::color::Color;
use lurek2d::overlay::{
    Overlay, OverlayAccessibilityPolicy, OverlayError, OverlayRenderLayer, WeatherType,
};

fn plan_has_layer(plan: &[OverlayRenderLayer], layer: OverlayRenderLayer) -> bool {
    plan.iter().any(|entry| *entry == layer)
}

mod accessibility_tests {
    use super::*;

    #[test]
    fn reduced_motion_limits_shake_and_flash() {
        let mut overlay = Overlay::new(320, 240);
        overlay.set_accessibility_policy(OverlayAccessibilityPolicy::reduced_motion());

        overlay.trigger_flash(1.0, 1.0, 1.0, 0.9, 0.5);
        assert!(overlay.flash.active);
        assert!(overlay.flash.color[3] <= overlay.accessibility_policy().max_flash_alpha + 1e-6);
        assert!(overlay.flash.duration <= overlay.accessibility_policy().max_flash_duration + 1e-6);

        overlay.trigger_shake(8.0, 0.4);
        assert!(
            overlay.shake.intensity <= overlay.accessibility_policy().max_shake_intensity + 1e-6
        );

        overlay.trigger_lightning();
        assert!(!overlay.lightning.active);
    }
}

mod sanitize_tests {
    use super::*;

    #[test]
    fn sanitize_removes_nan_state() {
        let mut overlay = Overlay::new(320, 240);
        overlay.weather.intensity = f32::NAN;
        overlay.weather.wind_speed = f32::INFINITY;
        overlay.ambient.color = [f32::NAN, -1.0, 2.0, f32::INFINITY];
        overlay.flash.duration = f32::NAN;
        overlay.shake.offset_x = f32::NAN;
        overlay.shake.offset_y = f32::INFINITY;
        overlay.fog.color = [f32::NAN, 0.2, 0.3, 2.0];
        overlay.water.time = f32::NAN;
        overlay.custom_shader = Some("../bad".to_string());

        overlay.sanitize();

        assert_eq!(overlay.weather.intensity, 0.5);
        assert_eq!(overlay.weather.wind_speed, 0.0);
        assert!(overlay.ambient.color.iter().all(|value| value.is_finite()));
        assert!(overlay.flash.duration.is_finite());
        assert_eq!(overlay.shake.offset_x, 0.0);
        assert_eq!(overlay.shake.offset_y, 0.0);
        assert!(overlay.fog.color.iter().all(|value| value.is_finite()));
        assert_eq!(overlay.water.time, 0.0);
        assert!(overlay.custom_shader.is_none());
        assert!(overlay.stats().sanitized_fields > 0);
    }
}

mod shader_policy_tests {
    use super::*;

    #[test]
    fn custom_shader_policy_rejects_invalid_name() {
        let mut overlay = Overlay::new(320, 240);

        let invalid = overlay
            .set_custom_shader(Some("../bad".to_string()))
            .unwrap_err();
        assert!(matches!(invalid, OverlayError::InvalidShaderName(_)));

        let too_long = overlay
            .set_custom_shader(Some("x".repeat(200)))
            .unwrap_err();
        assert!(matches!(too_long, OverlayError::InvalidShaderName(_)));

        overlay
            .set_custom_shader(Some("vignette".to_string()))
            .expect("valid built-in shader name should be accepted");
        assert_eq!(overlay.custom_shader.as_deref(), Some("vignette"));
    }
}

mod weather_tests {
    use super::*;

    #[test]
    fn weather_large_dt_reports_dropped_spawns() {
        let mut overlay = Overlay::new(320, 240);
        overlay.weather.enabled = true;
        overlay.weather.weather_type = WeatherType::Rain;
        overlay.weather.intensity = 8.0;

        overlay.update(12.0);

        let stats = overlay.stats();
        assert!(stats.weather_spawns_this_frame > 0);
        assert!(stats.weather_dropped_spawns > 0);
        assert!(stats.weather_dt_spike_clamps > 0);
    }

    #[test]
    fn weather_same_seed_snapshot() {
        let mut a = Overlay::new(320, 240);
        let mut b = Overlay::new(320, 240);
        for overlay in [&mut a, &mut b] {
            overlay.weather.enabled = true;
            overlay.weather.weather_type = WeatherType::Snow;
            overlay.weather.intensity = 1.5;
            overlay.weather.set_seed(0xABCD_EF01);
        }

        for dt in [0.016, 0.033, 0.050, 0.100] {
            a.update(dt);
            b.update(dt);
        }

        assert_eq!(a.weather.particles.len(), b.weather.particles.len());
        assert_eq!(a.weather.rng_state(), b.weather.rng_state());
        for (left, right) in a.weather.particles.iter().zip(b.weather.particles.iter()) {
            assert!((left.x - right.x).abs() < 1e-6);
            assert!((left.y - right.y).abs() < 1e-6);
            assert!((left.vx - right.vx).abs() < 1e-6);
            assert!((left.vy - right.vy).abs() < 1e-6);
            assert!((left.size - right.size).abs() < 1e-6);
            assert!((left.alpha - right.alpha).abs() < 1e-6);
        }
    }
}

mod render_plan_tests {
    use super::*;

    #[test]
    fn active_fog_water_reported_in_render_plan() {
        let mut overlay = Overlay::new(320, 240);
        overlay.fog.enabled = true;
        overlay.fog.density = 0.4;
        overlay.water.enabled = true;
        overlay.clouds.enabled = true;
        overlay.film_grain.enabled = true;

        let plan = overlay.render_plan();
        assert!(plan_has_layer(
            &plan.externally_handled,
            OverlayRenderLayer::Fog
        ));
        assert!(plan_has_layer(
            &plan.externally_handled,
            OverlayRenderLayer::Water
        ));
        assert!(plan_has_layer(
            &plan.externally_handled,
            OverlayRenderLayer::Clouds
        ));
        assert!(plan_has_layer(
            &plan.externally_handled,
            OverlayRenderLayer::FilmGrain
        ));
    }
}

mod debug_image_tests {
    use super::*;

    #[test]
    fn draw_flash_sequence_rejects_huge_image() {
        let mut overlay = Overlay::new(320, 240);
        overlay.limits.debug_images.max_pixels = 64;
        overlay.limits.debug_images.max_bytes = 256;

        let err = overlay
            .try_draw_flash_sequence_to_image(1.0, 1.0, 1.0, 0.8, 0.2, &[0.0, 0.1], 32, 32)
            .unwrap_err();
        assert!(matches!(err, OverlayError::DebugImageTooLarge { .. }));
    }
}

mod ambient_sync_tests {
    use super::*;

    #[test]
    fn sync_ambient_clamps_nan() {
        let mut overlay = Overlay::new(320, 240);
        overlay.ambient.color = [0.7, 0.2, 0.4, 0.9];
        let mut light = Color::new(f32::NAN, 2.0, -1.0, f32::INFINITY);

        overlay
            .sync_ambient_with_light(&mut light, "avg")
            .expect("valid mode should succeed");

        assert!(overlay.ambient.color.iter().all(|value| value.is_finite()));
        assert!((0.0..=1.0).contains(&overlay.ambient.color[0]));
        assert!(light.r.is_finite());
        assert!(light.g.is_finite());
        assert!(light.b.is_finite());
        assert!(light.a.is_finite());
    }
}
