//! Tests for the minimap module.

use lurek2d::minimap::*;

// ── types ─────────────────────────────────────────────────────────────

mod types_tests {
    use super::*;

    #[test]
    fn color_mode_parse_terrain() {
        assert_eq!(ColorMode::parse_mode("terrain"), Some(ColorMode::Terrain));
    }

    #[test]
    fn color_mode_parse_political() {
        assert_eq!(ColorMode::parse_mode("political"), Some(ColorMode::Political));
    }

    #[test]
    fn color_mode_parse_unknown() {
        assert_eq!(ColorMode::parse_mode("unknown"), None);
    }

    #[test]
    fn color_mode_roundtrip() {
        assert_eq!(ColorMode::parse_mode(ColorMode::Terrain.as_str()), Some(ColorMode::Terrain));
        assert_eq!(ColorMode::parse_mode(ColorMode::Political.as_str()), Some(ColorMode::Political));
    }

    #[test]
    fn fog_level_from_u8() {
        assert_eq!(FogLevel::from_u8(0), FogLevel::Hidden);
        assert_eq!(FogLevel::from_u8(1), FogLevel::Explored);
        assert_eq!(FogLevel::from_u8(2), FogLevel::Visible);
        assert_eq!(FogLevel::from_u8(255), FogLevel::Visible);
    }
}

// ── render ────────────────────────────────────────────────────────────

mod render_tests {
    use super::*;
    use lurek2d::render::renderer::{DrawMode, RenderCommand};

    #[test]
    fn empty_minimap_emits_background() {
        let map = Minimap::new(10, 10, 100, 100);
        let cmds = map.generate_render_commands(0.0, 0.0);
        assert!(!cmds.is_empty(), "expected at least a background rectangle");
        assert!(
            cmds.iter().any(|c| matches!(
                c,
                RenderCommand::Rectangle {
                    mode: DrawMode::Fill,
                    ..
                }
            )),
            "expected a Fill rectangle for background"
        );
    }

    #[test]
    fn no_pings_no_circle_commands() {
        let map = Minimap::new(8, 8, 80, 80);
        let cmds = map.generate_render_commands(0.0, 0.0);
        assert!(
            !cmds
                .iter()
                .any(|c| matches!(c, RenderCommand::Circle { .. })),
            "expected no Circle commands when there are no pings"
        );
    }

    #[test]
    fn ping_produces_circle_command() {
        let mut map = Minimap::new(8, 8, 80, 80);
        map.add_ping(4.0, 4.0, 1.0, [1.0, 0.0, 0.0, 1.0]);
        let cmds = map.generate_render_commands(0.0, 0.0);
        assert!(
            cmds.iter()
                .any(|c| matches!(c, RenderCommand::Circle { .. })),
            "expected a Circle command for the ping"
        );
    }

    #[test]
    fn viewport_rect_produces_line_rectangle() {
        let mut map = Minimap::new(10, 10, 100, 100);
        map.set_viewport_rect(2.0, 2.0, 4.0, 4.0);
        let cmds = map.generate_render_commands(0.0, 0.0);
        assert!(
            cmds.iter().any(|c| matches!(
                c,
                RenderCommand::Rectangle {
                    mode: DrawMode::Line,
                    ..
                }
            )),
            "expected a Line rectangle for the viewport overlay"
        );
    }
}

// ── minimap (from sibling minimap_tests.rs) ──────────────────────────

mod minimap_data_tests {
    use super::*;

    #[test]
    fn new_initializes_grid() {
        let m = Minimap::new(10, 8, 200, 160);
        assert_eq!(m.grid_width(), 10);
        assert_eq!(m.grid_height(), 8);
        assert_eq!(m.grid_size(), 80);
        assert_eq!(m.display_width(), 200);
        assert_eq!(m.display_height(), 160);
    }

    #[test]
    fn set_display_size() {
        let mut m = Minimap::new(4, 4, 100, 100);
        m.set_display_size(320, 240);
        assert_eq!(m.display_width(), 320);
        assert_eq!(m.display_height(), 240);
    }

    #[test]
    fn terrain_set_get() {
        let mut m = Minimap::new(4, 4, 100, 100);
        m.set_terrain(2, 3, 5);
        assert_eq!(m.get_terrain(2, 3), 5);
    }

    #[test]
    fn terrain_out_of_bounds_returns_zero() {
        let m = Minimap::new(4, 4, 100, 100);
        assert_eq!(m.get_terrain(99, 99), 0);
    }

    #[test]
    fn terrain_data_bulk_set() {
        let mut m = Minimap::new(2, 2, 100, 100);
        m.set_terrain_data(&[1, 2, 3, 4]);
        assert_eq!(m.get_terrain(0, 0), 1);
        assert_eq!(m.get_terrain(1, 0), 2);
        assert_eq!(m.get_terrain(0, 1), 3);
        assert_eq!(m.get_terrain(1, 1), 4);
    }

    #[test]
    fn terrain_color_default_and_custom() {
        let mut m = Minimap::new(4, 4, 100, 100);
        let default = m.get_terrain_color(0);
        assert_eq!(default, [0.5, 0.5, 0.5, 1.0]);
        m.set_terrain_color(1, [1.0, 0.0, 0.0, 1.0]);
        assert_eq!(m.get_terrain_color(1), [1.0, 0.0, 0.0, 1.0]);
    }

    #[test]
    fn tile_description() {
        let mut m = Minimap::new(4, 4, 100, 100);
        assert!(m.get_tile_description(0).is_none());
        m.set_tile_description(0, "Grass".to_string());
        assert_eq!(m.get_tile_description(0), Some("Grass"));
    }

    #[test]
    fn fog_toggle() {
        let mut m = Minimap::new(4, 4, 100, 100);
        assert!(!m.fog_enabled());
        m.set_fog_enabled(true);
        assert!(m.fog_enabled());
    }

    #[test]
    fn fog_level_set_get() {
        let mut m = Minimap::new(4, 4, 100, 100);
        m.set_fog_level(1, 1, FogLevel::Visible);
        assert_eq!(m.get_fog_level(1, 1), FogLevel::Visible);
        assert_eq!(m.get_fog_level(0, 0), FogLevel::Hidden);
    }

    #[test]
    fn fog_level_out_of_bounds() {
        let m = Minimap::new(4, 4, 100, 100);
        assert_eq!(m.get_fog_level(99, 99), FogLevel::Hidden);
    }

    #[test]
    fn fog_color() {
        let mut m = Minimap::new(4, 4, 100, 100);
        m.set_fog_color([1.0, 0.0, 0.0, 0.5]);
        assert_eq!(m.fog_color(), [1.0, 0.0, 0.0, 0.5]);
    }

    #[test]
    fn fog_data_bulk() {
        let mut m = Minimap::new(2, 2, 100, 100);
        m.set_fog_data(&[0, 1, 2, 1]);
        assert_eq!(m.get_fog_level(0, 0), FogLevel::Hidden);
        assert_eq!(m.get_fog_level(1, 0), FogLevel::Explored);
        assert_eq!(m.get_fog_level(0, 1), FogLevel::Visible);
    }

    #[test]
    fn object_type_add_and_visibility() {
        let mut m = Minimap::new(4, 4, 100, 100);
        let idx = m.add_object_type("enemy".to_string(), [1.0, 0.0, 0.0, 1.0]);
        assert_eq!(idx, 0);
        assert!(m.is_object_type_visible(idx));
        m.set_object_type_visible(idx, false);
        assert!(!m.is_object_type_visible(idx));
        assert_eq!(m.object_type_count(), 1);
    }

    #[test]
    fn objects_add_remove_clear() {
        let mut m = Minimap::new(4, 4, 100, 100);
        m.set_object(1, 1.0, 2.0, 0, 0);
        m.set_object(2, 3.0, 4.0, 0, 0);
        assert_eq!(m.object_count(), 2);
        assert!(m.remove_object(1));
        assert_eq!(m.object_count(), 1);
        assert!(!m.remove_object(99));
        m.clear_objects();
        assert_eq!(m.object_count(), 0);
    }

    #[test]
    fn owner_color_default_and_custom() {
        let mut m = Minimap::new(4, 4, 100, 100);
        assert_eq!(m.get_owner_color(0), [0.8, 0.8, 0.8, 1.0]);
        m.set_owner_color(1, [0.0, 1.0, 0.0, 1.0]);
        assert_eq!(m.get_owner_color(1), [0.0, 1.0, 0.0, 1.0]);
    }

    #[test]
    fn color_mode_set_get() {
        let mut m = Minimap::new(4, 4, 100, 100);
        assert_eq!(m.color_mode(), ColorMode::Terrain);
        m.set_color_mode(ColorMode::Political);
        assert_eq!(m.color_mode(), ColorMode::Political);
    }

    #[test]
    fn zoom_clamped() {
        let mut m = Minimap::new(4, 4, 100, 100);
        m.set_zoom(0.01);
        assert!((m.zoom() - 0.1).abs() < 0.001);
        m.set_zoom(5.0);
        assert_eq!(m.zoom(), 5.0);
    }

    #[test]
    fn center_set_get() {
        let mut m = Minimap::new(10, 10, 100, 100);
        m.set_center(3.0, 7.0);
        assert_eq!(m.center_x(), 3.0);
        assert_eq!(m.center_y(), 7.0);
    }

    #[test]
    fn viewport_rect_lifecycle() {
        let mut m = Minimap::new(10, 10, 100, 100);
        assert!(m.viewport_rect().is_none());
        m.set_viewport_rect(1.0, 2.0, 3.0, 4.0);
        assert_eq!(m.viewport_rect(), Some((1.0, 2.0, 3.0, 4.0)));
        m.clear_viewport_rect();
        assert!(m.viewport_rect().is_none());
    }

    #[test]
    fn viewport_visible_toggle() {
        let mut m = Minimap::new(4, 4, 100, 100);
        assert!(m.viewport_visible());
        m.set_viewport_visible(false);
        assert!(!m.viewport_visible());
    }

    #[test]
    fn viewport_color() {
        let mut m = Minimap::new(4, 4, 100, 100);
        m.set_viewport_color([1.0, 0.0, 0.0, 1.0]);
        assert_eq!(m.viewport_color(), [1.0, 0.0, 0.0, 1.0]);
    }

    #[test]
    fn ping_add_and_count() {
        let mut m = Minimap::new(4, 4, 100, 100);
        assert_eq!(m.ping_count(), 0);
        m.add_ping(2.0, 2.0, 1.0, [1.0, 1.0, 0.0, 1.0]);
        assert_eq!(m.ping_count(), 1);
        assert_eq!(m.pings().len(), 1);
    }

    #[test]
    fn update_expires_pings() {
        let mut m = Minimap::new(4, 4, 100, 100);
        m.add_ping(2.0, 2.0, 0.5, [1.0, 0.0, 0.0, 1.0]);
        m.update(0.3);
        assert_eq!(m.ping_count(), 1);
        m.update(0.3);
        assert_eq!(m.ping_count(), 0);
    }

    #[test]
    fn marker_add_remove_query() {
        let mut m = Minimap::new(4, 4, 100, 100);
        let id = m.add_marker(1.0, 2.0, "Base".to_string(), [0.0, 1.0, 0.0, 1.0]);
        assert!(m.has_marker(id));
        assert_eq!(m.get_marker_description(id), Some("Base"));
        assert_eq!(m.marker_count(), 1);
        assert!(m.remove_marker(id));
        assert!(!m.has_marker(id));
        assert_eq!(m.marker_count(), 0);
    }

    #[test]
    fn marker_animation_attach_clear() {
        let mut m = Minimap::new(4, 4, 100, 100);
        let id = m.add_marker(1.0, 1.0, "Alert".to_string(), [1.0, 0.0, 0.0, 1.0]);
        m.set_marker_animation(id, MarkerAnimation::Blink { speed: 2.0, phase: 0.0 });
        m.update(0.25);
        m.clear_marker_animation(id);
        // No panic — animation removed gracefully
    }

    #[test]
    fn overlay_shapes_draw_and_clear() {
        let mut m = Minimap::new(4, 4, 100, 100);
        m.draw_line(0.0, 0.0, 3.0, 3.0, [255, 0, 0, 255]);
        m.draw_rect(1.0, 1.0, 2.0, 2.0, [0, 255, 0, 255]);
        assert_eq!(m.overlay_shapes().len(), 2);
        m.clear_overlay();
        assert!(m.overlay_shapes().is_empty());
    }

    #[test]
    fn path_show_and_clear() {
        let mut m = Minimap::new(4, 4, 100, 100);
        let id = m.show_path(vec![(0.0, 0.0), (1.0, 1.0), (2.0, 0.0)], [255, 255, 0, 255]);
        assert_eq!(m.paths().len(), 1);
        m.clear_path(Some(id));
        assert!(m.paths().is_empty());
    }

    #[test]
    fn path_clear_all() {
        let mut m = Minimap::new(4, 4, 100, 100);
        m.show_path(vec![(0.0, 0.0), (1.0, 1.0)], [255, 0, 0, 255]);
        m.show_path(vec![(2.0, 2.0), (3.0, 3.0)], [0, 255, 0, 255]);
        assert_eq!(m.paths().len(), 2);
        m.clear_path(None);
        assert!(m.paths().is_empty());
    }

    #[test]
    fn layer_management() {
        let mut m = Minimap::new(4, 4, 100, 100);
        assert_eq!(m.layer_count(), 0);
        assert_eq!(m.get_layer(), 0);
        m.set_layer_data(
            0,
            LayerData {
                cells: vec![1, 2, 3, 4],
                width: 2,
                height: 2,
            },
        );
        assert_eq!(m.layer_count(), 1);
        assert!(m.layer_data(0).is_some());
        assert!(m.layer_data(5).is_none());
        m.set_layer(1);
        assert_eq!(m.get_layer(), 1);
    }

    #[test]
    fn anti_alias_toggle() {
        let mut m = Minimap::new(4, 4, 100, 100);
        assert!(!m.anti_alias());
        m.set_anti_alias(true);
        assert!(m.anti_alias());
    }

    #[test]
    fn clickable_toggle() {
        let mut m = Minimap::new(4, 4, 100, 100);
        assert!(m.is_clickable());
        m.set_clickable(false);
        assert!(!m.is_clickable());
    }

    #[test]
    fn screen_grid_roundtrip() {
        let m = Minimap::new(10, 10, 200, 200);
        let (sx, sy) = m.grid_to_screen(5.0, 5.0, 0.0, 0.0);
        let (gx, gy) = m.screen_to_grid(sx, sy, 0.0, 0.0);
        assert!((gx - 5.0).abs() < 0.01);
        assert!((gy - 5.0).abs() < 0.01);
    }

    #[test]
    fn hover_info_with_description() {
        let mut m = Minimap::new(4, 4, 80, 80);
        m.set_terrain(0, 0, 1);
        m.set_tile_description(1, "Water".to_string());
        // Screen coords (10, 10) with minimap at (0, 0) should map to roughly cell (0, 0)
        let info = m.get_hover_info(5.0, 5.0, 0.0, 0.0);
        assert_eq!(info, Some("Water"));
    }

    #[test]
    fn hover_info_outside_bounds() {
        let m = Minimap::new(4, 4, 80, 80);
        assert!(m.get_hover_info(-10.0, -10.0, 0.0, 0.0).is_none());
        assert!(m.get_hover_info(200.0, 200.0, 0.0, 0.0).is_none());
    }
}
