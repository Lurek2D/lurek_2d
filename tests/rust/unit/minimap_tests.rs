//! File: tests/rust/unit/minimap_tests.rs

// TODO(lua-first): public Rust API coverage in this file should live in tests/lua/unit/; keep only private/internal seams here.

use lurek2d::camera::Camera2D;
use lurek2d::minimap::*;
use lurek2d::render::renderer::{DrawMode, RenderCommand};
use lurek2d::runtime::resource_keys::TextureKey;
use slotmap::KeyData;

#[test]
fn minimap_try_new_rejects_zero_and_overflow_grid_dimensions() {
    let limits = MinimapLimits::default();
    assert!(matches!(
        Minimap::try_new(0, 8, 80, 80, limits),
        Err(MinimapError::GridDimensionsZero)
    ));
    assert!(matches!(
        Minimap::try_new(u32::MAX, 2, 80, 80, limits),
        Err(MinimapError::GridCellOverflow { .. })
    ));
}

#[test]
fn set_terrain_data_exact_length_validation_preserves_old_state() {
    let mut map = Minimap::new(3, 2, 30, 20);
    map.set_terrain_data(&[7, 7, 7, 7, 7, 7]);

    let err = map
        .try_set_terrain_data(&[1, 2, 3, 4, 5])
        .expect_err("short terrain data should be rejected");

    assert_eq!(
        err,
        MinimapError::DataLengthMismatch {
            context: "terrain data",
            expected: 6,
            actual: 5,
        }
    );
    assert_eq!(map.get_terrain(0, 0), 7);
    assert_eq!(map.get_terrain(2, 1), 7);
}

#[test]
fn set_fog_data_exact_length_validation_preserves_old_state() {
    let mut map = Minimap::new(3, 2, 30, 20);
    map.set_fog_data(&[2, 2, 2, 2, 2, 2]);

    let err = map
        .try_set_fog_data(&[0, 1, 2, 0, 1])
        .expect_err("short fog data should be rejected");

    assert_eq!(
        err,
        MinimapError::DataLengthMismatch {
            context: "fog data",
            expected: 6,
            actual: 5,
        }
    );
    assert_eq!(map.get_fog_level(0, 0), FogLevel::Visible);
    assert_eq!(map.get_fog_level(2, 1), FogLevel::Visible);
}

#[test]
fn reveal_radius_rejects_non_finite_and_marks_valid_cells() {
    let mut map = Minimap::new(8, 8, 80, 80);
    map.set_fog_enabled(true);
    map.set_fog_data(&[0; 64]);

    assert!(matches!(
        map.try_reveal_radius(f32::NAN, 3.5, 2.0),
        Err(MinimapError::InvalidFloat {
            field: "reveal center x"
        })
    ));
    assert_eq!(map.get_fog_level(3, 3), FogLevel::Hidden);

    map.try_reveal_radius(3.5, 3.5, 1.6)
        .expect("valid reveal should succeed");

    assert_eq!(map.get_fog_level(3, 3), FogLevel::Visible);
    assert_eq!(map.get_fog_level(2, 3), FogLevel::Visible);
    assert_eq!(map.get_fog_level(0, 0), FogLevel::Hidden);
}

#[test]
fn track_camera_syncs_center_and_viewport_rect() {
    let mut map = Minimap::new(64, 64, 256, 256);
    let mut camera = Camera2D::new(20.0, 10.0);
    camera.set_position(12.0, 18.0);
    camera.set_zoom(2.0);

    map.track_camera(&camera);

    assert_eq!((map.center_x(), map.center_y()), (12.0, 18.0));
    assert_eq!(map.viewport_rect(), Some((7.0, 15.5, 10.0, 5.0)));
}

#[test]
fn screen_to_grid_invalid_display_no_nan() {
    let mut map = Minimap::new(10, 10, 100, 100);
    map.set_display_size(0, 0);

    let (gx, gy) = map.screen_to_grid(50.0, 50.0, 0.0, 0.0);
    assert!(gx.is_finite());
    assert!(gy.is_finite());
    assert!(matches!(
        map.try_screen_to_grid(50.0, 50.0, 0.0, 0.0),
        Err(MinimapError::TransformUnavailable { .. })
    ));
}

#[test]
fn draw_to_image_covers_non_divisible_display() {
    let mut map = Minimap::new(10, 10, 101, 101);
    map.set_terrain_color(1, [1.0, 0.0, 0.0, 1.0]);
    map.try_set_terrain_data(&vec![1; 100])
        .expect("exact terrain load should succeed");

    let image = map
        .try_draw_to_image(0)
        .expect("display-sized image should render");

    assert_eq!(image.dimensions(), (101, 101));
    let first = image.get_pixel(0, 0).expect("top-left pixel should exist");
    let last = image
        .get_pixel(100, 100)
        .expect("bottom-right pixel should exist");
    assert!(first.0 > 200 && first.3 == 255);
    assert!(last.0 > 200 && last.3 == 255);
}

#[test]
fn political_draw_to_image_uses_owner_color_for_occupied_cell() {
    let mut map = Minimap::new(4, 4, 40, 40);
    let unit_type = map.add_object_type("unit".to_string(), [0.2, 0.8, 0.2, 1.0]);
    map.set_terrain_color(1, [0.0, 0.0, 1.0, 1.0]);
    map.set_owner_color(9, [1.0, 0.0, 0.0, 1.0]);
    map.set_terrain(1, 1, 1);
    assert!(map.set_object(1, 1.2, 1.3, unit_type, 9));
    map.set_color_mode(ColorMode::Political);

    let image = map.draw_to_image(10);
    let pixel = image
        .get_pixel(18, 18)
        .expect("expected political terrain pixel inside occupied cell");

    assert!(
        pixel.0 > 200,
        "expected owner red channel to dominate, got {pixel:?}"
    );
    assert!(
        pixel.2 < 80,
        "expected terrain blue to be replaced by owner color, got {pixel:?}"
    );
}

#[test]
fn marker_and_path_id_overflow_returns_error() {
    let mut map = Minimap::new(8, 8, 80, 80);
    map.set_next_marker_id_for_testing(u32::MAX);
    assert!(matches!(
        map.try_add_marker(1.0, 1.0, "poi".to_string(), [1.0, 0.0, 0.0, 1.0]),
        Err(MinimapError::IdOverflow { kind: "marker" })
    ));

    map.set_next_path_id_for_testing(u32::MAX);
    assert!(matches!(
        map.try_show_path(vec![(0.0, 0.0), (1.0, 1.0)], [255, 0, 0, 255]),
        Err(MinimapError::IdOverflow { kind: "path" })
    ));
}

#[test]
fn missing_marker_and_object_type_operations_are_detectable() {
    let mut map = Minimap::new(8, 8, 80, 80);
    let texture_key = TextureKey::from(KeyData::from_ffi(1));
    assert!(!map.set_marker_texture(99, texture_key, 8.0, 8.0, 8.0, 8.0));
    assert!(!map.set_object_type_visible(0, false));
    assert!(!map.set_object_type_texture(0, texture_key, 8.0, 8.0, 8.0, 8.0));
}

#[test]
fn render_commands_batch_same_color_cells() {
    let mut map = Minimap::new(4, 1, 40, 10);
    map.set_terrain_color(1, [0.1, 0.2, 0.3, 1.0]);
    map.try_set_terrain_data(&[1, 1, 1, 1])
        .expect("terrain data should load");

    let stats = map.render_stats(0.0, 0.0);
    let cmds = map.generate_render_commands(0.0, 0.0);
    let fill_rects = cmds
        .iter()
        .filter(|cmd| {
            matches!(
                cmd,
                RenderCommand::Rectangle {
                    mode: DrawMode::Fill,
                    ..
                }
            )
        })
        .count();

    assert_eq!(stats.visible_cells, 4);
    assert_eq!(stats.terrain_runs_batched, 1);
    assert_eq!(
        fill_rects, 2,
        "background + one batched terrain run expected"
    );
}

#[test]
fn build_render_commands_matches_generate_render_commands() {
    let mut map = Minimap::new(12, 12, 120, 120);
    let unit_type = map.add_object_type("unit".to_string(), [0.9, 0.1, 0.1, 1.0]);
    map.set_terrain_color(1, [0.2, 0.3, 0.4, 1.0]);
    map.set_terrain(3, 4, 1);
    assert!(map.set_object(1, 3.5, 4.5, unit_type, 2));
    map.add_marker(5.0, 5.0, "poi".to_string(), [1.0, 1.0, 0.0, 1.0]);
    assert!(map.draw_line(1.0, 1.0, 6.0, 6.0, [255, 255, 255, 255]));
    map.show_path(vec![(0.0, 0.0), (2.0, 3.0), (5.0, 8.0)], [255, 0, 0, 255]);

    let generated = map.generate_render_commands(8.0, 12.0);
    let built = map.build_render_commands(8.0, 12.0);

    assert_eq!(generated.len(), built.len());
    let generated_debug: Vec<String> = generated.iter().map(|cmd| format!("{cmd:?}")).collect();
    let built_debug: Vec<String> = built.iter().map(|cmd| format!("{cmd:?}")).collect();
    assert_eq!(generated_debug, built_debug);
}
