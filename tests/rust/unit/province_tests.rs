//! File: tests/rust/unit/province_tests.rs

// TODO(lua-first): public Rust API coverage in this file should live in tests/lua/unit/; keep only private/internal seams here.

use std::collections::HashMap;
use std::path::{Path, PathBuf};

use lurek2d::image::{ImageData, ProvinceGrid};
use lurek2d::province::cache::ProvinceGeometryCache;
use lurek2d::province::import::{
    import_metadata_from_files, sanitize_marked_png, MarkerSanitizeOptions,
    ProvinceMetadataImportOptions,
};
use lurek2d::province::registry::ProvinceRegistry;
use lurek2d::province::render::{
    generate_capital_path_commands, generate_render_commands, render_segment_raster,
    viewport_bounds, ProvinceCapitalPathMode, ProvinceCapitalPathOptions, ProvinceRenderOptions,
    ProvinceSegmentRasterOptions, ProvinceZoomMode,
};
use lurek2d::province::types::{
    BorderPairFlags, BorderPairStyle, BorderTypeConfig, ProvinceClimateKind, ProvinceId,
    ProvinceVisualState, ProvinceWeatherKind, PROVINCE_EFFECT_STRIPES,
    parse_province_effect_flag_token,
};
use lurek2d::province::{
    border_index::{
        build_border_index_from_registry, build_styled_border_index_from_registry,
        dilate_border_index_with_styles,
    },
    distance_field::compute_distance_field_from_registry,
    gpu_bridge::{build_border_style_gpu_records, build_dense_gpu_records},
    gpu_upload::{pack_u16_pixels_le, pack_u32_pixels_le},
};
use lurek2d::render::renderer::{DrawMode, RenderCommand};
use lurek2d::runtime::resource_keys::FontKey;
use slotmap::KeyData;

fn sample_grid() -> ProvinceGrid {
    let mut img = ImageData::new(4, 2);
    // Row 0: A A B B
    img.set_pixel(0, 0, 255, 0, 0, 255);
    img.set_pixel(1, 0, 255, 0, 0, 255);
    img.set_pixel(2, 0, 0, 255, 0, 255);
    img.set_pixel(3, 0, 0, 255, 0, 255);
    // Row 1: A A B B
    img.set_pixel(0, 1, 255, 0, 0, 255);
    img.set_pixel(1, 1, 255, 0, 0, 255);
    img.set_pixel(2, 1, 0, 255, 0, 255);
    img.set_pixel(3, 1, 0, 255, 0, 255);
    ProvinceGrid::from_image(&img)
}

fn write_png(path: &Path, img: &ImageData) {
    if let Some(parent) = path.parent() {
        std::fs::create_dir_all(parent).expect("create test png parent");
    }
    let encoded = img.encode_png().expect("encode png");
    std::fs::write(path, encoded).expect("write png");
}

fn write_text(path: &Path, text: &str) {
    if let Some(parent) = path.parent() {
        std::fs::create_dir_all(parent).expect("create test text parent");
    }
    std::fs::write(path, text).expect("write text file");
}

fn test_output_path(name: &str) -> PathBuf {
    let mut p = std::env::temp_dir();
    p.push("lurek2d_province_tests");
    p.push(name);
    p
}

fn dummy_font_key() -> FontKey {
    FontKey::from(KeyData::from_ffi(1))
}

#[test]
fn test_registry_from_grid_has_provinces_and_adjacency() {
    let grid = sample_grid();
    let reg = ProvinceRegistry::from_grid(&grid);
    assert_eq!(reg.province_count(), 2);

    let neighbors_1 = reg.get_neighbors(ProvinceId(1));
    assert_eq!(neighbors_1, vec![ProvinceId(2)]);

    let neighbors_2 = reg.get_neighbors(ProvinceId(2));
    assert_eq!(neighbors_2, vec![ProvinceId(1)]);
}

#[test]
fn test_dense_gpu_records_are_indexed_by_raw_province_id() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);
    reg.set_political_color(ProvinceId(2), [0.25, 0.5, 0.75, 1.0]);
    reg.set_visual_state(
        ProvinceId(2),
        ProvinceVisualState {
            climate_type: ProvinceClimateKind::Temperate.id(),
            weather_type: ProvinceWeatherKind::Snow.id(),
            weather_strength: 0.6,
            effect_flags: 0x05,
            visual_seed: 42,
        },
    );

    let records = build_dense_gpu_records(&reg);

    assert!(records.len() >= 3);
    assert_eq!(records[2].political_color, [0.25, 0.5, 0.75, 1.0]);
    assert_eq!(records[2].visual_u32, [4, 2, 0x05, 42]);
    assert_eq!(records[2].visual_f32[0], 0.6);
}

#[test]
fn test_visual_state_roundtrip_clamps_weather_strength_and_logs_change() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);

    assert!(reg.set_visual_state(
        ProvinceId(1),
        ProvinceVisualState {
            climate_type: ProvinceClimateKind::Arid.id(),
            weather_type: ProvinceWeatherKind::Sandstorm.id(),
            weather_strength: 4.0,
            effect_flags: 0x03,
            visual_seed: 99,
        },
    ));

    let visual_state = reg.visual_state_for(ProvinceId(1)).expect("visual state");
    assert_eq!(visual_state.climate_type, ProvinceClimateKind::Arid.id());
    assert_eq!(
        visual_state.weather_type,
        ProvinceWeatherKind::Sandstorm.id()
    );
    assert_eq!(visual_state.weather_strength, 1.0);
    assert_eq!(visual_state.effect_flags, 0x03);
    assert_eq!(visual_state.visual_seed, 99);

    let changes = reg.get_changes_since(0);
    assert_eq!(changes.len(), 1);
    assert!(matches!(
        &changes[0].1,
        lurek2d::province::ProvinceChange::VisualState {
            province_id,
            visual_state
        } if *province_id == ProvinceId(1)
            && visual_state.weather_strength == 1.0
            && visual_state.visual_seed == 99
    ));
}

#[test]
fn test_parse_province_effect_flag_token_supports_stripe_aliases() {
    assert_eq!(
        parse_province_effect_flag_token("stripes"),
        Some(PROVINCE_EFFECT_STRIPES)
    );
    assert_eq!(
        parse_province_effect_flag_token("hatched"),
        Some(PROVINCE_EFFECT_STRIPES)
    );
}

#[test]
fn test_segment_raster_uses_scaled_border_segments() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);
    reg.set_political_color(ProvinceId(1), [0.5, 0.5, 0.5, 1.0]);
    reg.set_political_color(ProvinceId(2), [0.75, 0.0, 0.0, 1.0]);
    reg.set_terrain_type(ProvinceId(1), 1);
    reg.set_terrain_type(ProvinceId(2), 1);
    reg.set_border_pair_style(
        ProvinceId(1),
        ProvinceId(2),
        BorderPairStyle {
            color: None,
            thickness: 3.0,
            flags: BorderPairFlags::from_bits(BorderPairFlags::COUNTRY),
        },
    );

    let raster = render_segment_raster(
        &reg,
        &ProvinceSegmentRasterOptions {
            pixel_size: 8,
            edge_gradient_radius: 16.0,
            edge_gradient_strength: 0.25,
            ..ProvinceSegmentRasterOptions::default()
        },
    );

    assert_eq!(raster.width, 32);
    assert_eq!(raster.height, 16);
    assert!(raster
        .pixels
        .chunks_exact(4)
        .any(|px| px == [230, 46, 42, 255]));
}

#[test]
fn test_registry_revision_and_change_tracking() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);
    assert_eq!(reg.revision(), 0);

    assert!(reg.set_political_color(ProvinceId(1), [1.0, 0.0, 0.0, 1.0]));
    assert!(reg.set_terrain_type(ProvinceId(1), 7));

    let rev = reg.revision();
    assert!(rev >= 2);

    let changes = reg.get_changes_since(0);
    assert!(changes.len() >= 2);
}

#[test]
fn test_registry_border_type_roundtrip() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);

    reg.set_border_type(ProvinceId(1), ProvinceId(2), 1);
    assert_eq!(reg.get_border_type(ProvinceId(1), ProvinceId(2)), Some(1));
    assert_eq!(reg.get_border_type(ProvinceId(2), ProvinceId(1)), Some(1));
}

#[test]
fn test_registry_border_type_config() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);

    reg.register_border_type(
        0,
        BorderTypeConfig {
            name: "land".to_string(),
            color: [0.5, 0.5, 0.5, 1.0],
            thickness: 1.0,
            draw_priority: 0,
        },
    );
    reg.register_border_type(
        1,
        BorderTypeConfig {
            name: "coast".to_string(),
            color: [0.0, 0.5, 1.0, 1.0],
            thickness: 2.0,
            draw_priority: 1,
        },
    );

    let config0 = reg.get_border_type_config(0).expect("config 0");
    assert_eq!(config0.name, "land");
    let config1 = reg.get_border_type_config(1).expect("config 1");
    assert_eq!(config1.name, "coast");
    assert_eq!(config1.thickness, 2.0);
    assert!(reg.get_border_type_config(2).is_none());
}

#[test]
fn test_viewport_bounds_maps_screen_to_visible_province_rect() {
    let bounds = viewport_bounds(&ProvinceRenderOptions {
        x: -20.0,
        y: -10.0,
        zoom: 2.0,
        pixel_size: 1.0,
        screen_w: 200.0,
        screen_h: 100.0,
        ..ProvinceRenderOptions::default()
    });

    assert_eq!(bounds, (10.0, 5.0, 110.0, 55.0));
}

#[test]
fn test_render_commands_use_border_type_thickness() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);
    reg.register_border_type(
        1,
        BorderTypeConfig {
            name: "wide".to_string(),
            color: [0.2, 0.3, 0.4, 1.0],
            thickness: 2.5,
            draw_priority: 0,
        },
    );
    reg.set_border_type(ProvinceId(1), ProvinceId(2), 1);

    let opts = ProvinceRenderOptions {
        draw_fills: false,
        draw_borders: true,
        draw_labels: false,
        draw_capitals: false,
        draw_roads: false,
        zoom_mode: Some(ProvinceZoomMode::Tactical),
        ..ProvinceRenderOptions::default()
    };

    let commands = generate_render_commands(&reg, &opts, None);
    assert!(
        commands
            .iter()
            .any(|cmd| matches!(cmd, RenderCommand::SetLineWidth(width) if *width == 2.5)),
        "border type thickness should set command-render border width"
    );
}

#[test]
fn test_province_render_resets_line_width_before_pop() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);
    assert!(reg.set_visibility_state(ProvinceId(1), 2));

    let commands = generate_render_commands(
        &reg,
        &ProvinceRenderOptions {
            draw_fills: false,
            draw_borders: false,
            draw_labels: false,
            draw_capitals: false,
            draw_roads: false,
            selected_id: Some(ProvinceId(1)),
            ..ProvinceRenderOptions::default()
        },
        None,
    );

    assert!(
        commands.windows(2).any(|pair| matches!(
            pair,
            [RenderCommand::SetLineWidth(width), RenderCommand::PopTransform] if *width == 1.0
        )),
        "province rendering should not leak selected/hover line width into later draws"
    );
}

#[test]
fn test_registry_border_pair_style_roundtrip() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);

    let mut flags = BorderPairFlags::empty();
    flags.insert_bits(BorderPairFlags::COUNTRY);
    let style = BorderPairStyle {
        color: Some([0.9, 0.1, 0.1, 1.0]),
        thickness: 3.0,
        flags,
    };
    reg.set_border_pair_style(ProvinceId(1), ProvinceId(2), style);
    let got = reg
        .get_border_pair_style(ProvinceId(2), ProvinceId(1))
        .expect("style should exist");

    assert_eq!(got.color, style.color);
    assert_eq!(got.thickness, style.thickness);
    assert!(got.flags.contains_bits(BorderPairFlags::COUNTRY));
}

#[test]
fn test_geometry_cache_encode_decode_roundtrip() {
    let grid = sample_grid();
    let reg = ProvinceRegistry::from_grid(&grid);

    let cache = ProvinceGeometryCache::from_registry(&reg);
    let bytes = cache.encode();
    let decoded = ProvinceGeometryCache::decode(&bytes).expect("decode should succeed");

    assert_eq!(decoded.spans, cache.spans);
    assert_eq!(decoded.border_segments, cache.border_segments);
}

#[test]
fn test_registry_capital_and_label_metadata_roundtrip() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);

    assert!(reg.set_capital(ProvinceId(1), 10.5, 20.5));
    assert_eq!(reg.capital_for(ProvinceId(1)), Some((10.5, 20.5)));

    assert!(reg.set_label_line(ProvinceId(1), 1.0, 2.0, 3.0, 4.0));
    assert_eq!(
        reg.label_line_for(ProvinceId(1)),
        Some(((1.0, 2.0), (3.0, 4.0)))
    );

    assert!(reg.set_label_text(ProvinceId(1), "Yukon".to_string()));
    assert_eq!(reg.label_text_for(ProvinceId(1)), Some("Yukon"));

    assert!(reg.bbox_for(ProvinceId(1)).is_some());
    assert!(reg.spans_for(ProvinceId(1)).is_some());
    assert!(reg.style_for(ProvinceId(1)).is_some());
}

#[test]
fn test_label_render_commands_follow_label_line_transform() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);
    assert!(reg.set_visibility_state(ProvinceId(1), 2));
    assert!(reg.set_visibility_state(ProvinceId(2), 0));
    assert!(reg.set_label_text(ProvinceId(1), "Nordland".to_string()));
    assert!(reg.set_label_line(ProvinceId(1), 0.0, 0.5, 8.0, 0.5));

    let commands = generate_render_commands(
        &reg,
        &ProvinceRenderOptions {
            draw_fills: false,
            draw_borders: false,
            draw_labels: true,
            draw_capitals: false,
            draw_roads: false,
            pixel_size: 10.0,
            ..ProvinceRenderOptions::default()
        },
        Some(dummy_font_key()),
    );

    let label_commands: Vec<_> = commands
        .iter()
        .filter_map(|cmd| match cmd {
            RenderCommand::PrintTransformed {
                text,
                rotation,
                sx,
                sy,
                ..
            } if text == "Nordland" => Some((*rotation, *sx, *sy)),
            _ => None,
        })
        .collect();

    assert_eq!(
        label_commands.len(),
        1,
        "single plain label expected"
    );
    assert!(!commands.iter().any(|cmd| {
        matches!(
            cmd,
            RenderCommand::Print { text, .. } if text == "Nordland"
        )
    }));
    assert!(label_commands.iter().all(|(rotation, sx, sy)| {
        rotation.abs() < 0.001 && *sx > 0.0 && (*sx - *sy).abs() < 0.001
    }));
}

#[test]
fn test_auto_label_line_prefers_row_away_from_centroid() {
    let mut img = ImageData::new(8, 5);
    for y in 0..5 {
        for x in 0..8 {
            img.set_pixel(x, y, 255, 0, 0, 255);
        }
    }

    let grid = ProvinceGrid::from_image(&img);
    let reg = ProvinceRegistry::from_grid(&grid);
    let centroid = reg.centroid_for(ProvinceId(1)).expect("centroid");
    let ((ax, ay), (bx, by)) = reg
        .auto_label_line_for(ProvinceId(1))
        .expect("auto label line");
    let mid_y = (ay + by) * 0.5;

    assert!(
        (mid_y - centroid.1).abs() >= 0.75,
        "label line should avoid the centroid row when another full row is available"
    );
    assert!((bx - ax).abs() > 1.0);
}

#[test]
fn test_auto_label_line_follows_diagonal_province_axis() {
    let mut img = ImageData::new(10, 10);
    for y in 0..10 {
        for x in 0..10 {
            if x == y || x == y + 1 {
                img.set_pixel(x, y, 255, 0, 0, 255);
            }
        }
    }

    let grid = ProvinceGrid::from_image(&img);
    let reg = ProvinceRegistry::from_grid(&grid);
    let ((ax, ay), (bx, by)) = reg
        .auto_label_line_for(ProvinceId(1))
        .expect("auto label line");
    let rotation = (by - ay).atan2(bx - ax);

    assert!(
        rotation > 0.45 && rotation < 1.05,
        "diagonal provinces should get a diagonal label baseline, got {rotation}"
    );
}

#[test]
fn test_label_scale_is_map_space_not_inverse_zoom() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);
    assert!(reg.set_visibility_state(ProvinceId(1), 2));
    assert!(reg.set_label_text(ProvinceId(1), "Scale".to_string()));
    assert!(reg.set_label_line(ProvinceId(1), 0.0, 0.5, 8.0, 0.5));

    let label_scale_at = |zoom| {
        let commands = generate_render_commands(
            &reg,
            &ProvinceRenderOptions {
                draw_fills: false,
                draw_borders: false,
                draw_labels: true,
                draw_capitals: false,
                draw_roads: false,
                pixel_size: 10.0,
                zoom,
                ..ProvinceRenderOptions::default()
            },
            Some(dummy_font_key()),
        );
        commands
            .iter()
            .find_map(|cmd| match cmd {
                RenderCommand::PrintTransformed { text, sx, .. } if text == "Scale" => Some(*sx),
                _ => None,
            })
            .expect("label scale")
    };

    let scale_1 = label_scale_at(1.0);
    let scale_2 = label_scale_at(2.0);
    assert!((scale_1 - scale_2).abs() < 0.001);
    assert!(scale_1 <= 0.62);
}

#[test]
fn test_water_labels_use_dark_water_foreground() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);
    assert!(reg.set_visibility_state(ProvinceId(1), 2));
    assert!(reg.set_label_text(ProvinceId(1), "Sea".to_string()));
    assert!(reg.set_label_line(ProvinceId(1), 0.0, 0.5, 8.0, 0.5));

    let commands = generate_render_commands(
        &reg,
        &ProvinceRenderOptions {
            draw_fills: false,
            draw_borders: false,
            draw_labels: true,
            draw_capitals: false,
            draw_roads: false,
            pixel_size: 10.0,
            ..ProvinceRenderOptions::default()
        },
        Some(dummy_font_key()),
    );

    assert!(commands.iter().any(|cmd| {
        matches!(
            cmd,
            RenderCommand::SetColor(r, g, b, a)
                if (*r - 0.10).abs() < 0.001
                    && (*g - 0.27).abs() < 0.001
                    && (*b - 0.40).abs() < 0.001
                    && (*a - 1.0).abs() < 0.001
        )
    }));
}

#[test]
fn test_label_render_commands_keep_overlapping_labels() {
    let mut img = ImageData::new(1, 2);
    img.set_pixel(0, 0, 255, 0, 0, 255);
    img.set_pixel(0, 1, 0, 255, 0, 255);

    let grid = ProvinceGrid::from_image(&img);
    let mut reg = ProvinceRegistry::from_grid(&grid);
    assert!(reg.set_visibility_state(ProvinceId(1), 2));
    assert!(reg.set_visibility_state(ProvinceId(2), 2));
    assert!(reg.set_label_text(ProvinceId(1), "Province Alpha".to_string()));
    assert!(reg.set_label_text(ProvinceId(2), "Province Beta".to_string()));
    assert!(reg.set_label_line(ProvinceId(1), 0.0, 0.0, 10.0, 0.0));
    assert!(reg.set_label_line(ProvinceId(2), 0.0, 1.0, 10.0, 1.0));

    let commands = generate_render_commands(
        &reg,
        &ProvinceRenderOptions {
            draw_fills: false,
            draw_borders: false,
            draw_labels: true,
            draw_capitals: false,
            draw_roads: false,
            pixel_size: 10.0,
            ..ProvinceRenderOptions::default()
        },
        Some(dummy_font_key()),
    );

    let label_commands = commands
        .iter()
        .filter(|cmd| {
            matches!(
                cmd,
                RenderCommand::PrintTransformed { text, .. }
                    if text == "Province Alpha" || text == "Province Beta"
            )
        })
        .count();

    assert_eq!(
        label_commands, 2,
        "overlap should not hide province labels"
    );
}

#[test]
fn test_small_province_label_renders_at_minimum_scale() {
    let mut img = ImageData::new(1, 1);
    img.set_pixel(0, 0, 255, 0, 0, 255);

    let grid = ProvinceGrid::from_image(&img);
    let mut reg = ProvinceRegistry::from_grid(&grid);
    assert!(reg.set_visibility_state(ProvinceId(1), 2));
    assert!(reg.set_label_text(ProvinceId(1), "Tiny".to_string()));

    let commands = generate_render_commands(
        &reg,
        &ProvinceRenderOptions {
            draw_fills: false,
            draw_borders: false,
            draw_labels: true,
            draw_capitals: false,
            draw_roads: false,
            pixel_size: 8.0,
            ..ProvinceRenderOptions::default()
        },
        Some(dummy_font_key()),
    );

    let scale = commands
        .iter()
        .find_map(|cmd| match cmd {
            RenderCommand::PrintTransformed { text, sx, .. } if text == "Tiny" => Some(*sx),
            _ => None,
        })
        .expect("small province label should render");
    assert!((0.20..=0.62).contains(&scale));
}

#[test]
fn test_capital_path_commands_connect_route_capitals_as_beziers() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);
    assert!(reg.set_capital(ProvinceId(1), 1.0, 1.0));
    assert!(reg.set_capital(ProvinceId(2), 3.0, 1.0));

    let commands = generate_capital_path_commands(
        &reg,
        &[ProvinceId(1), ProvinceId(2)],
        &ProvinceCapitalPathOptions {
            pixel_size: 2.0,
            width: 3.0,
            mode: ProvinceCapitalPathMode::Bezier,
            curve_offset: 4.0,
            segments: 12,
            ..ProvinceCapitalPathOptions::default()
        },
    );

    assert!(matches!(commands[0], RenderCommand::SetLineWidth(3.0)));
    assert!(
        commands
            .iter()
            .any(|cmd| matches!(cmd, RenderCommand::DrawQuadBezier { segments: 12, .. })),
        "bezier capital paths should emit quadratic route hops"
    );
}

#[test]
fn test_sanitize_marked_png_replaces_marker_pixels() {
    let mut src = ImageData::new(3, 1);
    src.set_pixel(0, 0, 20, 40, 60, 255);
    src.set_pixel(1, 0, 255, 255, 255, 255);
    src.set_pixel(2, 0, 80, 120, 160, 255);

    let in_path = test_output_path("sanitize_input.png");
    let out_path = test_output_path("sanitize_output.png");
    write_png(&in_path, &src);

    let summary = sanitize_marked_png(
        &in_path.to_string_lossy(),
        &out_path.to_string_lossy(),
        &MarkerSanitizeOptions::default(),
    )
    .expect("sanitize should succeed");

    assert_eq!(summary.replaced_pixels, 1);
    let out = ImageData::from_file(&out_path.to_string_lossy()).expect("read output png");
    assert_eq!(out.get_pixel(1, 0), Some((20, 40, 60, 255)));
}

#[test]
fn test_import_metadata_from_files_sets_attrs_labels_and_markers() {
    let mut marked = ImageData::new(2, 1);
    marked.set_pixel(0, 0, 12, 34, 56, 255);
    marked.set_pixel(1, 0, 255, 255, 255, 255);

    let mut color_map = ImageData::new(2, 1);
    color_map.set_pixel(0, 0, 12, 34, 56, 255);
    color_map.set_pixel(1, 0, 12, 34, 56, 255);

    let marked_path = test_output_path("import_marked.png");
    let color_path = test_output_path("import_color.png");
    let csv_path = test_output_path("import_map.csv");
    let toml_path = test_output_path("import_data.toml");

    write_png(&marked_path, &marked);
    write_png(&color_path, &color_map);
    write_text(&csv_path, "id,r,g,b\n101,12,34,56\n");
    write_text(
        &toml_path,
        "[101]\nname = \"Alpha_Province\"\nterrain = \"sea\"\n",
    );

    let grid = ProvinceGrid::from_image(&color_map);
    let mut reg = ProvinceRegistry::from_grid(&grid);
    assert_eq!(reg.province_count(), 1);

    let opts = ProvinceMetadataImportOptions {
        color_map_png_path: color_path.to_string_lossy().into_owned(),
        marker_png_path: Some(marked_path.to_string_lossy().into_owned()),
        color_csv_path: csv_path.to_string_lossy().into_owned(),
        province_toml_path: Some(toml_path.to_string_lossy().into_owned()),
        ..Default::default()
    };

    let summary = import_metadata_from_files(&mut reg, &opts).expect("import metadata");
    assert_eq!(summary.mapped_provinces, 1);
    assert!(summary.capitals_set >= 1);
    assert!(summary.labels_set >= 1);

    let snap = reg
        .get_province(ProvinceId(1))
        .expect("province 1 snapshot");
    assert_eq!(snap.style.terrain_type, 0);
    assert_eq!(snap.attrs.get("game_id").map(String::as_str), Some("101"));
    assert_eq!(snap.attrs.get("terrain").map(String::as_str), Some("sea"));
    assert_eq!(
        snap.attrs.get("name").map(String::as_str),
        Some("Alpha Province")
    );
    assert_eq!(reg.label_text_for(ProvinceId(1)), Some("Alpha Province"));
    assert_eq!(reg.capital_for(ProvinceId(1)), Some((1.5, 0.5)));
}

#[test]
fn test_import_metadata_from_files_uses_label_marker_cluster_centers() {
    let mut marker_map = ImageData::new(8, 3);
    for y in 0..3 {
        for x in 0..8 {
            marker_map.set_pixel(x, y, 12, 34, 56, 255);
        }
    }
    marker_map.set_pixel(0, 1, 255, 0, 255, 255);
    marker_map.set_pixel(1, 1, 255, 0, 255, 255);
    marker_map.set_pixel(6, 1, 255, 0, 255, 255);
    marker_map.set_pixel(7, 1, 255, 0, 255, 255);

    let mut color_map = ImageData::new(8, 3);
    for y in 0..3 {
        for x in 0..8 {
            color_map.set_pixel(x, y, 12, 34, 56, 255);
        }
    }

    let marked_path = test_output_path("import_label_clusters_marked.png");
    let color_path = test_output_path("import_label_clusters_color.png");
    let csv_path = test_output_path("import_label_clusters_map.csv");
    let toml_path = test_output_path("import_label_clusters_data.toml");

    write_png(&marked_path, &marker_map);
    write_png(&color_path, &color_map);
    write_text(&csv_path, "id,r,g,b\n101,12,34,56\n");
    write_text(&toml_path, "[101]\nname = \"Alpha_Province\"\nterrain = \"plains\"\n");

    let grid = ProvinceGrid::from_image(&color_map);
    let mut reg = ProvinceRegistry::from_grid(&grid);

    let opts = ProvinceMetadataImportOptions {
        color_map_png_path: color_path.to_string_lossy().into_owned(),
        marker_png_path: Some(marked_path.to_string_lossy().into_owned()),
        color_csv_path: csv_path.to_string_lossy().into_owned(),
        province_toml_path: Some(toml_path.to_string_lossy().into_owned()),
        set_capitals: false,
        set_label_lines: true,
        ..Default::default()
    };

    let summary = import_metadata_from_files(&mut reg, &opts).expect("import metadata");
    assert_eq!(summary.label_lines_set, 1);

    let ((ax, ay), (bx, by)) = reg
        .label_line_for(ProvinceId(1))
        .expect("explicit label line");
    assert!((ax - 1.0).abs() < 0.001);
    assert!((ay - 1.5).abs() < 0.001);
    assert!((bx - 7.0).abs() < 0.001);
    assert!((by - 1.5).abs() < 0.001);
}

#[test]
fn test_province_polygons_rectangle_simplifies_to_four_corners() {
    let mut img = ImageData::new(3, 2);
    for y in 0..2 {
        for x in 0..3 {
            img.set_pixel(x, y, 200, 20, 20, 255);
        }
    }

    let grid = ProvinceGrid::from_image(&img);
    let polygons = grid.province_polygons_simplified();
    let loops = polygons.get(&1).expect("province 1 loops");
    let main = loops
        .iter()
        .max_by_key(|ring| ring.len())
        .expect("at least one loop");

    assert_eq!(main.first(), main.last());
    assert_eq!(main.len(), 5);
    assert!(main.contains(&(0, 0)));
    assert!(main.contains(&(3, 0)));
    assert!(main.contains(&(3, 2)));
    assert!(main.contains(&(0, 2)));
}

#[test]
fn test_province_polygons_staircase_produces_fewer_points_and_diagonal() {
    let mut img = ImageData::new(5, 5);
    let steps = [(0, 0), (1, 0), (1, 1), (2, 1), (2, 2), (3, 2), (3, 3)];
    for (x, y) in steps {
        img.set_pixel(x, y, 20, 200, 20, 255);
    }

    let grid = ProvinceGrid::from_image(&img);
    let raw = grid.province_polygons();
    let simplified = grid.province_polygons_simplified();

    let raw_loop = raw
        .get(&1)
        .and_then(|loops| loops.iter().max_by_key(|ring| ring.len()))
        .expect("raw loop");
    let simp_loop = simplified
        .get(&1)
        .and_then(|loops| loops.iter().max_by_key(|ring| ring.len()))
        .expect("simplified loop");

    assert!(simp_loop.len() < raw_loop.len());

    let has_diagonal = simp_loop.windows(2).any(|w| {
        let dx = (w[1].0 as i64 - w[0].0 as i64).abs();
        let dy = (w[1].1 as i64 - w[0].1 as i64).abs();
        dx == dy && dx > 0
    });
    assert!(has_diagonal);
}

#[test]
fn test_fow_render_hidden_and_discovered_fill_rules() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);
    assert!(reg.set_visibility_state(ProvinceId(1), 0));
    assert!(reg.set_visibility_state(ProvinceId(2), 1));

    let opts = ProvinceRenderOptions {
        draw_fills: true,
        draw_borders: false,
        draw_labels: false,
        draw_capitals: false,
        ..ProvinceRenderOptions::default()
    };
    let cmds = generate_render_commands(&reg, &opts, None);

    let fill_rect_count = cmds
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
    assert_eq!(fill_rect_count, 1, "only discovered province should fill");

    let has_discovered_gray = cmds.iter().any(|cmd| {
        matches!(
            cmd,
            RenderCommand::SetColor(r, g, b, a)
                if (*r, *g, *b, *a) == (0.2_f32, 0.2_f32, 0.2_f32, 1.0_f32)
        )
    });
    assert!(
        has_discovered_gray,
        "discovered province should render gray fill"
    );
}

#[test]
fn test_render_applies_province_tints_without_mutating_registry_colors() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);
    assert!(reg.set_visibility_state(ProvinceId(1), 2));
    assert!(reg.set_visibility_state(ProvinceId(2), 2));
    assert!(reg.set_political_color(ProvinceId(1), [0.1, 0.1, 0.1, 1.0]));

    let mut province_tints = HashMap::new();
    province_tints.insert(ProvinceId(1), [0.25, 0.5, 0.75, 1.0]);

    let opts = ProvinceRenderOptions {
        draw_fills: true,
        draw_borders: false,
        draw_labels: false,
        draw_capitals: false,
        province_tints,
        ..ProvinceRenderOptions::default()
    };
    let cmds = generate_render_commands(&reg, &opts, None);

    let has_tinted_fill = cmds.iter().any(|cmd| {
        matches!(
            cmd,
            RenderCommand::SetColor(r, g, b, a)
                if (*r, *g, *b, *a) == (0.25_f32, 0.5_f32, 0.75_f32, 1.0_f32)
        )
    });
    assert!(
        has_tinted_fill,
        "province_tints should override fill color for this render"
    );

    let style_after = reg.style_for(ProvinceId(1)).expect("province style");
    assert_eq!(style_after.political_color, [0.1, 0.1, 0.1, 1.0]);
}

#[test]
fn test_fow_borders_require_both_provinces_fully_visible() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);
    assert!(reg.set_visibility_state(ProvinceId(1), 2));
    assert!(reg.set_visibility_state(ProvinceId(2), 2));

    let opts = ProvinceRenderOptions {
        draw_fills: false,
        draw_borders: true,
        draw_labels: false,
        draw_capitals: false,
        ..ProvinceRenderOptions::default()
    };
    let visible_cmds = generate_render_commands(&reg, &opts, None);
    let visible_lines = visible_cmds
        .iter()
        .filter(|cmd| matches!(cmd, RenderCommand::Line { .. }))
        .count();
    assert!(
        visible_lines > 0,
        "expected border lines when both provinces are visible"
    );

    assert!(reg.set_visibility_state(ProvinceId(2), 1));
    let discovered_cmds = generate_render_commands(&reg, &opts, None);
    let discovered_lines = discovered_cmds
        .iter()
        .filter(|cmd| matches!(cmd, RenderCommand::Line { .. }))
        .count();
    assert_eq!(
        discovered_lines, 0,
        "no border lines should render when one province is only discovered"
    );
}

#[test]
fn test_fow_capitals_render_only_for_fully_visible_provinces() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);
    assert!(reg.set_capital(ProvinceId(1), 1.0, 1.0));
    assert!(reg.set_visibility_state(ProvinceId(1), 1));

    let opts = ProvinceRenderOptions {
        draw_fills: false,
        draw_borders: false,
        draw_labels: false,
        draw_capitals: true,
        ..ProvinceRenderOptions::default()
    };
    let discovered_cmds = generate_render_commands(&reg, &opts, None);
    let discovered_circles = discovered_cmds
        .iter()
        .filter(|cmd| matches!(cmd, RenderCommand::Circle { .. }))
        .count();
    assert_eq!(
        discovered_circles, 0,
        "capital markers should not render for discovered provinces"
    );

    assert!(reg.set_visibility_state(ProvinceId(1), 2));
    let visible_cmds = generate_render_commands(&reg, &opts, None);
    let visible_circles = visible_cmds
        .iter()
        .filter(|cmd| matches!(cmd, RenderCommand::Circle { .. }))
        .count();
    assert!(
        visible_circles >= 2,
        "fully visible capital should render marker circles"
    );
}

#[test]
fn test_tactical_roads_render_for_visible_land_adjacencies_without_capitals() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);
    assert!(reg.set_visibility_state(ProvinceId(1), 2));
    assert!(reg.set_visibility_state(ProvinceId(2), 2));
    assert!(reg.set_terrain_type(ProvinceId(1), 1));
    assert!(reg.set_terrain_type(ProvinceId(2), 1));

    let commands = generate_render_commands(
        &reg,
        &ProvinceRenderOptions {
            draw_fills: false,
            draw_borders: false,
            draw_labels: false,
            draw_capitals: false,
            draw_roads: true,
            zoom_mode: Some(ProvinceZoomMode::Tactical),
            border_width: 1.0,
            pixel_size: 10.0,
            ..ProvinceRenderOptions::default()
        },
        None,
    );

    let road_lines = commands
        .iter()
        .filter(|cmd| matches!(cmd, RenderCommand::Line { .. }))
        .count();
    assert!(
        road_lines >= 2,
        "tactical roads should emit visible line segments even when provinces only have centroids"
    );
}

#[test]
fn test_strategic_mode_renders_country_overrides_but_skips_land_land() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);
    assert!(reg.set_visibility_state(ProvinceId(1), 2));
    assert!(reg.set_visibility_state(ProvinceId(2), 2));

    let tactical_opts = ProvinceRenderOptions {
        draw_fills: false,
        draw_borders: true,
        draw_labels: false,
        draw_capitals: false,
        draw_roads: false,
        zoom_mode: Some(ProvinceZoomMode::Tactical),
        ..ProvinceRenderOptions::default()
    };
    let tactical_lines = generate_render_commands(&reg, &tactical_opts, None)
        .iter()
        .filter(|cmd| matches!(cmd, RenderCommand::Line { .. }))
        .count();
    assert!(
        tactical_lines > 0,
        "tactical mode should draw default land-land borders"
    );

    let strategic_opts = ProvinceRenderOptions {
        draw_fills: false,
        draw_borders: true,
        draw_labels: false,
        draw_capitals: false,
        draw_roads: false,
        zoom_mode: Some(ProvinceZoomMode::Strategic),
        ..ProvinceRenderOptions::default()
    };
    let strategic_lines_without_override = generate_render_commands(&reg, &strategic_opts, None)
        .iter()
        .filter(|cmd| matches!(cmd, RenderCommand::Line { .. }))
        .count();
    assert_eq!(
        strategic_lines_without_override, 0,
        "strategic mode should skip plain land-land borders"
    );

    let mut flags = BorderPairFlags::empty();
    flags.insert_bits(BorderPairFlags::COUNTRY);
    reg.set_border_pair_style(
        ProvinceId(1),
        ProvinceId(2),
        BorderPairStyle {
            color: Some([1.0, 0.0, 0.0, 1.0]),
            thickness: 3.0,
            flags,
        },
    );
    let strategic_lines_with_country = generate_render_commands(&reg, &strategic_opts, None)
        .iter()
        .filter(|cmd| matches!(cmd, RenderCommand::Line { .. }))
        .count();
    assert!(
        strategic_lines_with_country > 0,
        "strategic mode should draw country border overrides"
    );
}

#[test]
fn test_distance_field_has_zero_on_border_and_greater_inside() {
    let mut img = ImageData::new(5, 5);
    for y in 0..5 {
        for x in 0..5 {
            if (1..=3).contains(&x) && (1..=3).contains(&y) {
                img.set_pixel(x, y, 255, 0, 0, 255);
            } else {
                img.set_pixel(x, y, 0, 255, 0, 255);
            }
        }
    }

    let grid = ProvinceGrid::from_image(&img);
    let reg = ProvinceRegistry::from_grid(&grid);
    let field = compute_distance_field_from_registry(&reg, 25);

    let center = field.at(2, 2).expect("center exists");
    let border = field.at(1, 2).expect("border exists");

    assert_eq!(border, 0, "border pixel distance must be zero");
    assert!(
        center > 0,
        "interior pixel distance must be greater than zero"
    );
}

#[test]
fn test_border_index_builds_pair_ids_and_dilation_expands_coverage() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);

    let mut index = build_border_index_from_registry(&reg);
    assert_eq!(
        index.pair_count(),
        1,
        "sample grid should have one border pair"
    );

    let border_pixels_before = index.data.iter().filter(|&&v| v != 0).count();
    assert!(
        border_pixels_before > 0,
        "border index should mark border pixels"
    );

    let mut flags = BorderPairFlags::empty();
    flags.insert_bits(BorderPairFlags::COUNTRY);
    reg.set_border_pair_style(
        ProvinceId(1),
        ProvinceId(2),
        BorderPairStyle {
            color: Some([1.0, 0.0, 0.0, 1.0]),
            thickness: 4.0,
            flags,
        },
    );

    let mut styles = std::collections::HashMap::new();
    let style = reg
        .get_border_pair_style(ProvinceId(1), ProvinceId(2))
        .expect("pair style should be present");
    styles.insert((ProvinceId(1), ProvinceId(2)), style);
    dilate_border_index_with_styles(&mut index, &styles);

    let border_pixels_after = index.data.iter().filter(|&&v| v != 0).count();
    assert!(
        border_pixels_after >= border_pixels_before,
        "dilation should not reduce border coverage"
    );
}

#[test]
fn test_border_index_keeps_one_cell_border_pairs_at_corner_conflicts() {
    let mut img = ImageData::new(2, 2);
    img.set_pixel(0, 0, 255, 0, 0, 255);
    img.set_pixel(1, 0, 0, 255, 0, 255);
    img.set_pixel(0, 1, 0, 0, 255, 255);
    img.set_pixel(1, 1, 0, 0, 255, 255);

    let grid = ProvinceGrid::from_image(&img);
    let reg = ProvinceRegistry::from_grid(&grid);
    let index = build_border_index_from_registry(&reg);

    assert!(
        index
            .pair_to_id
            .contains_key(&(ProvinceId(1), ProvinceId(2))),
        "horizontal one-cell pair should be indexed"
    );
    assert!(
        index
            .pair_to_id
            .contains_key(&(ProvinceId(1), ProvinceId(3))),
        "vertical one-cell pair should not be dropped by right/down conflicts"
    );
    assert!(
        index
            .pair_to_id
            .contains_key(&(ProvinceId(2), ProvinceId(3))),
        "neighboring one-cell pair should be indexed"
    );

    let pair_13 = index.pair_to_id[&(ProvinceId(1), ProvinceId(3))];
    assert!(
        index.data.contains(&pair_13),
        "one-cell vertical pair should have a texture slot"
    );
}

#[test]
fn test_styled_border_index_uses_pair_style_thickness() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);

    let raw = build_border_index_from_registry(&reg);
    let raw_pixels = raw.data.iter().filter(|&&v| v != 0).count();

    reg.set_border_pair_style(
        ProvinceId(1),
        ProvinceId(2),
        BorderPairStyle {
            color: None,
            thickness: 4.0,
            flags: BorderPairFlags::empty(),
        },
    );

    let styled = build_styled_border_index_from_registry(&reg);
    let styled_pixels = styled.data.iter().filter(|&&v| v != 0).count();

    assert_eq!(styled.id_to_pair, raw.id_to_pair);
    assert!(
        styled_pixels > raw_pixels,
        "pair-style thickness should expand the GPU border index"
    );
}

#[test]
fn test_styled_border_index_uses_border_type_thickness() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);

    let raw = build_border_index_from_registry(&reg);
    let raw_pixels = raw.data.iter().filter(|&&v| v != 0).count();

    reg.register_border_type(
        1,
        BorderTypeConfig {
            name: "wide".to_string(),
            color: [0.2, 0.3, 0.4, 1.0],
            thickness: 4.0,
            draw_priority: 0,
        },
    );
    reg.set_border_type(ProvinceId(1), ProvinceId(2), 1);

    let styled = build_styled_border_index_from_registry(&reg);
    let styled_pixels = styled.data.iter().filter(|&&v| v != 0).count();

    assert!(
        styled_pixels > raw_pixels,
        "border-type thickness should expand the GPU border index"
    );
}

#[test]
fn test_gpu_upload_pack_u32_pixels_le_is_little_endian_and_dense() {
    let bytes = pack_u32_pixels_le(&[0x1122_3344, 0xAABB_CCDD]);
    assert_eq!(bytes.len(), 8);
    assert_eq!(bytes, vec![0x44, 0x33, 0x22, 0x11, 0xDD, 0xCC, 0xBB, 0xAA]);
}

#[test]
fn test_gpu_upload_pack_u16_pixels_le_is_little_endian_and_dense() {
    let bytes = pack_u16_pixels_le(&[0x1122, 0xAABB, 0x00FF]);
    assert_eq!(bytes.len(), 6);
    assert_eq!(bytes, vec![0x22, 0x11, 0xBB, 0xAA, 0xFF, 0x00]);
}

#[test]
fn test_gpu_bridge_border_style_records_follow_border_index_pairs() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);
    let index = build_border_index_from_registry(&reg);

    let mut flags = BorderPairFlags::empty();
    flags.insert_bits(BorderPairFlags::COUNTRY);
    reg.set_border_pair_style(
        ProvinceId(1),
        ProvinceId(2),
        BorderPairStyle {
            color: Some([1.0, 0.0, 0.0, 1.0]),
            thickness: 4.0,
            flags,
        },
    );

    let records = build_border_style_gpu_records(&reg, &index);
    assert_eq!(records.len(), index.id_to_pair.len());
    assert_eq!(records[0].flags, 0, "slot 0 should stay empty");
    assert_eq!(
        records[1].flags & 0x01,
        0x01,
        "country flag should be propagated"
    );
    assert_eq!(records[1].thickness, 4.0);
    assert_eq!(records[1].color, [1.0, 0.0, 0.0, 1.0]);
    assert_eq!(records[1].province_a, 1);
    assert_eq!(records[1].province_b, 2);
    assert_eq!(
        records[1].flags & 0x80,
        0x80,
        "explicit pair colors should bypass render-level border palettes"
    );
}

#[test]
fn test_gpu_bridge_border_style_records_use_border_type_thickness() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);
    let index = build_border_index_from_registry(&reg);

    reg.register_border_type(
        1,
        BorderTypeConfig {
            name: "wide".to_string(),
            color: [0.2, 0.3, 0.4, 1.0],
            thickness: 3.5,
            draw_priority: 0,
        },
    );
    reg.set_border_type(ProvinceId(1), ProvinceId(2), 1);

    let records = build_border_style_gpu_records(&reg, &index);
    assert_eq!(records[1].thickness, 3.5);
    assert_eq!(records[1].color, [0.2, 0.3, 0.4, 1.0]);
    assert_eq!(
        records[1].flags & 0x80,
        0x80,
        "non-semantic custom border types should keep their registered color"
    );
}

#[test]
fn test_gpu_bridge_border_style_records_mark_coast_from_terrain_types() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);
    assert!(reg.set_terrain_type(ProvinceId(1), 1));
    assert!(reg.set_terrain_type(ProvinceId(2), 0));
    let index = build_border_index_from_registry(&reg);

    let records = build_border_style_gpu_records(&reg, &index);

    assert_eq!(
        records[1].flags & 0x10,
        0x10,
        "land-water borders should be marked as coast for render-level palettes"
    );
    assert_eq!(
        records[1].flags & 0x80,
        0,
        "terrain-derived coast borders should use the render-level palette"
    );
}
