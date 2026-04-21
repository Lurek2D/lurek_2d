//! Tests for the camera module.

use lurek2d::camera::effects::{CameraBreathing, CameraSway, ZoomPulse};
use lurek2d::camera::path::{CameraPath, ZoomTween};
use lurek2d::camera::types::{Camera, Camera2D};
use lurek2d::camera::viewport::{ScaleMode, Viewport};
use lurek2d::camera::viewport_scale::ViewportScale;
use lurek2d::math::Vec2;
use lurek2d::render::renderer::RenderCommand;

// ── effects tests ───────────────────────────────────────────────────────────

mod effects_tests {
    use super::*;

    #[test]
    fn zoom_pulse_inactive_returns_zero() {
        let mut p = ZoomPulse::new();
        assert!((p.update(0.016)).abs() < f32::EPSILON);
        assert!(!p.is_active());
    }

    #[test]
    fn zoom_pulse_trigger_activates() {
        let mut p = ZoomPulse::new();
        p.trigger(0.2, 0.5);
        assert!(p.is_active());
        let delta = p.update(0.001);
        assert!(delta >= 0.0);
    }

    #[test]
    fn zoom_pulse_expires_after_duration() {
        let mut p = ZoomPulse::new();
        p.trigger(0.2, 0.1);
        p.update(0.2);
        assert!(!p.is_active());
        assert!((p.current_delta()).abs() < f32::EPSILON);
    }

    #[test]
    fn camera_sway_inactive_returns_zero_offset() {
        let mut s = CameraSway::new();
        let (dx, dy) = s.update(0.016);
        assert!((dx).abs() < f32::EPSILON);
        assert!((dy).abs() < f32::EPSILON);
    }

    #[test]
    fn camera_sway_start_activates() {
        let mut s = CameraSway::new();
        s.start(5.0, 3.0, 1.0, 1.0);
        assert!(s.is_active());
    }

    #[test]
    fn camera_sway_stop_deactivates() {
        let mut s = CameraSway::new();
        s.start(5.0, 3.0, 1.0, 1.0);
        s.stop();
        assert!(!s.is_active());
        let (dx, dy) = s.update(0.016);
        assert!((dx).abs() < f32::EPSILON);
        assert!((dy).abs() < f32::EPSILON);
    }

    #[test]
    fn camera_breathing_inactive_returns_zero() {
        let mut b = CameraBreathing::new();
        assert!((b.update(0.016)).abs() < f32::EPSILON);
        assert!(!b.is_active());
    }

    #[test]
    fn camera_breathing_start_activates() {
        let mut b = CameraBreathing::new();
        b.start(0.01, 0.5);
        assert!(b.is_active());
    }

    #[test]
    fn camera_breathing_stop_deactivates() {
        let mut b = CameraBreathing::new();
        b.start(0.01, 0.5);
        b.stop();
        assert!(!b.is_active());
        assert!((b.update(0.016)).abs() < f32::EPSILON);
    }
}

// ── path tests ──────────────────────────────────────────────────────────────

mod path_tests {
    use super::*;

    #[test]
    fn camera_path_single_waypoint_is_immediate() {
        let mut p = CameraPath::new(vec![[0.0, 0.0]], 1.0);
        assert!(p.update(0.1).is_none());
    }

    #[test]
    fn camera_path_two_waypoints_interpolates() {
        let mut p = CameraPath::new(vec![[0.0, 0.0], [100.0, 200.0]], 1.0);
        let pos = p.update(0.5).unwrap();
        assert!((pos.0 - 50.0).abs() < 1.0);
        assert!((pos.1 - 100.0).abs() < 1.0);
    }

    #[test]
    fn camera_path_completes_at_last_waypoint() {
        let mut p = CameraPath::new(vec![[0.0, 0.0], [100.0, 0.0]], 0.5);
        let pos = p.update(1.0).unwrap();
        assert!((pos.0 - 100.0).abs() < 1e-3);
        assert!(!p.active);
    }

    #[test]
    fn camera_path_progress_starts_at_zero() {
        let p = CameraPath::new(vec![[0.0, 0.0], [100.0, 0.0]], 1.0);
        assert!((p.progress()).abs() < f32::EPSILON);
    }

    #[test]
    fn camera_path_reset_restarts() {
        let mut p = CameraPath::new(vec![[0.0, 0.0], [100.0, 0.0]], 1.0);
        p.update(2.0);
        p.reset();
        assert!(p.active);
        assert!((p.elapsed).abs() < f32::EPSILON);
    }

    #[test]
    fn camera_path_multi_segment() {
        let mut p = CameraPath::new(
            vec![[0.0, 0.0], [100.0, 0.0], [100.0, 100.0]],
            2.0,
        );
        let pos = p.update(1.0).unwrap();
        assert!((pos.0 - 100.0).abs() < 1.0);
        assert!((pos.1).abs() < 1.0);
    }

    #[test]
    fn zoom_tween_interpolates() {
        let mut t = ZoomTween::new(1.0, 2.0, 1.0);
        let z = t.update(0.5).unwrap();
        assert!((z - 1.5).abs() < 1e-3);
    }

    #[test]
    fn zoom_tween_completes_at_target() {
        let mut t = ZoomTween::new(1.0, 3.0, 0.5);
        let z = t.update(1.0).unwrap();
        assert!((z - 3.0).abs() < 1e-3);
        assert!(!t.active);
    }

    #[test]
    fn zoom_tween_inactive_returns_none() {
        let mut t = ZoomTween::new(1.0, 2.0, 0.5);
        t.update(1.0);
        assert!(t.update(0.1).is_none());
    }

    #[test]
    fn zoom_tween_progress_starts_at_zero() {
        let t = ZoomTween::new(1.0, 2.0, 1.0);
        assert!((t.progress()).abs() < f32::EPSILON);
    }
}

// ── render tests ────────────────────────────────────────────────────────────

mod render_tests {
    use super::*;

    #[test]
    fn camera_default_emits_push_and_translate_only() {
        let cam = Camera::default();
        let cmds = cam.begin_render_commands();
        assert_eq!(cmds.len(), 2);
        assert!(matches!(cmds[0], RenderCommand::PushTransform));
        assert!(matches!(cmds[1], RenderCommand::Translate { .. }));
    }

    #[test]
    fn camera_with_zoom_emits_scale() {
        let cam = Camera::new(Vec2::ZERO, 2.0, 0.0);
        let cmds = cam.begin_render_commands();
        assert!(cmds
            .iter()
            .any(|c| matches!(c, RenderCommand::Scale { .. })));
    }

    #[test]
    fn camera_with_rotation_emits_rotate() {
        let cam = Camera::new(Vec2::ZERO, 1.0, 0.5);
        let cmds = cam.begin_render_commands();
        assert!(cmds
            .iter()
            .any(|c| matches!(c, RenderCommand::Rotate { .. })));
    }

    #[test]
    fn camera2d_emits_transform_stack() {
        let mut cam = Camera2D::new(800.0, 600.0);
        cam.set_position(100.0, 200.0);
        cam.set_zoom(1.5);
        cam.set_rotation(0.3);

        let cmds = cam.begin_render_commands();
        assert!(matches!(cmds[0], RenderCommand::PushTransform));
        if let RenderCommand::Translate { x, y } = cmds[1] {
            assert!((x - (-100.0)).abs() < 1e-5);
            assert!((y - (-200.0)).abs() < 1e-5);
        } else {
            panic!("Expected Translate");
        }
        assert!(cmds
            .iter()
            .any(|c| matches!(c, RenderCommand::Rotate { .. })));
        assert!(cmds
            .iter()
            .any(|c| matches!(c, RenderCommand::Scale { .. })));
    }

    #[test]
    fn end_returns_pop_transform() {
        let cmd = Camera::end_render_command();
        assert!(matches!(cmd, RenderCommand::PopTransform));
    }
}

// ── types tests ─────────────────────────────────────────────────────────────

mod types_tests {
    use super::*;

    #[test]
    fn camera_default_identity() {
        let cam = Camera::default();
        assert!((cam.position.x).abs() < f32::EPSILON);
        assert!((cam.position.y).abs() < f32::EPSILON);
        assert!((cam.zoom - 1.0).abs() < f32::EPSILON);
        assert!((cam.rotation).abs() < f32::EPSILON);
    }

    #[test]
    fn camera_view_matrix_identity_at_default() {
        let cam = Camera::default();
        let m = cam.view_matrix();
        let p = m.transform_point(Vec2::new(10.0, 20.0));
        assert!((p.x - 10.0).abs() < 1e-5);
        assert!((p.y - 20.0).abs() < 1e-5);
    }

    #[test]
    fn camera2d_new_centered() {
        let cam = Camera2D::new(800.0, 600.0);
        assert!((cam.position.x).abs() < f32::EPSILON);
        assert!((cam.position.y).abs() < f32::EPSILON);
        assert!((cam.zoom - 1.0).abs() < f32::EPSILON);
    }

    #[test]
    fn camera2d_to_screen_and_back() {
        let cam = Camera2D::new(800.0, 600.0);
        let (sx, sy) = cam.to_screen_coords(100.0, 200.0);
        let (wx, wy) = cam.to_world_coords(sx, sy);
        assert!((wx - 100.0).abs() < 1e-3);
        assert!((wy - 200.0).abs() < 1e-3);
    }

    #[test]
    fn camera2d_bounds_clamping() {
        let mut cam = Camera2D::new(100.0, 100.0);
        cam.set_bounds(0.0, 0.0, 500.0, 500.0);
        cam.set_position(-1000.0, -1000.0);
        cam.update(0.016);
        let (px, py) = cam.get_position();
        assert!(px >= 0.0);
        assert!(py >= 0.0);
    }

    #[test]
    fn camera2d_follow_instant_snap() {
        let mut cam = Camera2D::new(800.0, 600.0);
        cam.set_follow_smooth(0.0);
        cam.set_target(200.0, 300.0);
        cam.update(0.016);
        let (px, py) = cam.get_position();
        assert!((px - 200.0).abs() < 1e-3);
        assert!((py - 300.0).abs() < 1e-3);
    }

    #[test]
    fn camera2d_follow_smooth_moves_toward_target() {
        let mut cam = Camera2D::new(800.0, 600.0);
        cam.set_follow_smooth(5.0);
        cam.set_target(200.0, 0.0);
        cam.update(0.1);
        let (px, _) = cam.get_position();
        assert!(px > 0.0);
        assert!(px < 200.0);
    }

    #[test]
    fn camera2d_shake_decays() {
        let mut cam = Camera2D::new(800.0, 600.0);
        cam.shake(10.0, 0.5);
        cam.update(0.6);
        assert!((cam.effect_offset().0).abs() < f32::EPSILON);
        assert!((cam.effect_offset().1).abs() < f32::EPSILON);
    }

    #[test]
    fn camera2d_visible_area_scales_with_zoom() {
        let cam1 = Camera2D::new(800.0, 600.0);
        let (_, _, w1, h1) = cam1.get_visible_area();

        let mut cam2 = Camera2D::new(800.0, 600.0);
        cam2.set_zoom(2.0);
        let (_, _, w2, h2) = cam2.get_visible_area();

        assert!((w2 - w1 / 2.0).abs() < 1e-3);
        assert!((h2 - h1 / 2.0).abs() < 1e-3);
    }

    #[test]
    fn camera2d_dead_zone_prevents_small_movements() {
        let mut cam = Camera2D::new(800.0, 600.0);
        cam.set_dead_zone(100.0, 100.0);
        cam.set_follow_smooth(0.0);
        cam.set_target(10.0, 10.0);
        cam.update(0.016);
        let (px, py) = cam.get_position();
        assert!((px).abs() < f32::EPSILON);
        assert!((py).abs() < f32::EPSILON);
    }
}

// ── viewport tests ──────────────────────────────────────────────────────────

mod viewport_tests {
    use super::*;

    #[test]
    fn new_default_scale_one_no_offset() {
        let vp = Viewport::new(800.0, 600.0, ScaleMode::Letterbox);
        let (sx, sy) = vp.get_scale();
        assert!((sx - 1.0).abs() < 1e-5);
        assert!((sy - 1.0).abs() < 1e-5);
        let (ox, oy) = vp.get_offset();
        assert!((ox).abs() < 1e-5);
        assert!((oy).abs() < 1e-5);
    }

    #[test]
    fn stretch_resize_fills_window() {
        let mut vp = Viewport::new(400.0, 300.0, ScaleMode::Stretch);
        vp.resize(800.0, 600.0);
        let (sx, sy) = vp.get_scale();
        assert!((sx - 2.0).abs() < 1e-5);
        assert!((sy - 2.0).abs() < 1e-5);
    }

    #[test]
    fn letterbox_preserves_aspect_ratio() {
        let mut vp = Viewport::new(400.0, 300.0, ScaleMode::Letterbox);
        vp.resize(800.0, 300.0);
        let (sx, sy) = vp.get_scale();
        assert!((sx - sy).abs() < 1e-5);
    }

    #[test]
    fn to_game_to_screen_roundtrip() {
        let mut vp = Viewport::new(800.0, 600.0, ScaleMode::Stretch);
        vp.resize(1600.0, 1200.0);
        let (gx, gy) = vp.to_game(400.0, 300.0);
        let (sx, sy) = vp.to_screen(gx, gy);
        assert!((sx - 400.0).abs() < 1e-5);
        assert!((sy - 300.0).abs() < 1e-5);
    }

    #[test]
    fn pixel_perfect_gives_integer_scale() {
        let mut vp = Viewport::new(200.0, 150.0, ScaleMode::PixelPerfect);
        vp.resize(700.0, 600.0);
        let (sx, _) = vp.get_scale();
        assert_eq!(sx.fract(), 0.0);
    }
}

// ── viewport_scale tests ────────────────────────────────────────────────────

mod viewport_scale_tests {
    use super::*;

    #[test]
    fn new_defaults_to_unit_scale() {
        let vs = ViewportScale::new(800.0, 600.0, ScaleMode::Letterbox);
        let (sx, sy) = vs.get_scale();
        assert!((sx - 1.0).abs() < 1e-5);
        assert!((sy - 1.0).abs() < 1e-5);
    }

    #[test]
    fn stretch_resize_fills_window() {
        let mut vs = ViewportScale::new(400.0, 300.0, ScaleMode::Stretch);
        vs.resize(800.0, 600.0);
        let (sx, sy) = vs.get_scale();
        assert!((sx - 2.0).abs() < 1e-5);
        assert!((sy - 2.0).abs() < 1e-5);
    }

    #[test]
    fn scaled_dimensions_track_resize() {
        let mut vs = ViewportScale::new(400.0, 300.0, ScaleMode::Stretch);
        vs.resize(800.0, 600.0);
        let (sw, sh) = vs.get_scaled_dimensions();
        assert!((sw - 800.0).abs() < 1e-3);
        assert!((sh - 600.0).abs() < 1e-3);
    }

    #[test]
    fn to_game_to_screen_roundtrip() {
        let mut vs = ViewportScale::new(800.0, 600.0, ScaleMode::Stretch);
        vs.resize(1600.0, 1200.0);
        let (gx, gy) = vs.to_game_coords(400.0, 300.0);
        let (sx, sy) = vs.to_screen_coords(gx, gy);
        assert!((sx - 400.0).abs() < 1e-3);
        assert!((sy - 300.0).abs() < 1e-3);
    }

    #[test]
    fn pixel_perfect_gives_integer_scale() {
        let mut vs = ViewportScale::new(200.0, 150.0, ScaleMode::PixelPerfect);
        vs.resize(700.0, 600.0);
        let (sx, _) = vs.get_scale();
        assert_eq!(sx.fract(), 0.0);
    }

    #[test]
    fn letterbox_preserves_aspect_ratio() {
        let mut vs = ViewportScale::new(400.0, 300.0, ScaleMode::Letterbox);
        vs.resize(800.0, 300.0);
        let (sx, sy) = vs.get_scale();
        assert!((sx - sy).abs() < 1e-5);
    }

    #[test]
    fn game_dimensions_match_construction() {
        let vs = ViewportScale::new(320.0, 240.0, ScaleMode::Letterbox);
        let (gw, gh) = vs.get_game_dimensions();
        assert!((gw - 320.0).abs() < f32::EPSILON);
        assert!((gh - 240.0).abs() < f32::EPSILON);
    }

    #[test]
    fn get_offset_zero_at_construction() {
        let vs = ViewportScale::new(800.0, 600.0, ScaleMode::Stretch);
        let (ox, oy) = vs.get_offset();
        assert!((ox).abs() < f32::EPSILON);
        assert!((oy).abs() < f32::EPSILON);
    }
}
