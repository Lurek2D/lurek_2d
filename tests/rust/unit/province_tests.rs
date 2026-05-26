//! INTERNAL ONLY: Rust-only tests for province engine internals.

use std::path::{Path, PathBuf};

use lurek2d::image::{ImageData, ProvinceGrid};
use lurek2d::province::cache::ProvinceGeometryCache;
use lurek2d::province::import::{
    import_metadata_from_files, sanitize_marked_png, MarkerSanitizeOptions,
    ProvinceMetadataImportOptions,
};
use lurek2d::province::{
    border_index::{
        build_border_index_from_registry, dilate_border_index_with_styles,
    },
    distance_field::compute_distance_field_from_registry,
    gpu_bridge::build_border_style_gpu_records,
    gpu_upload::{pack_u16_pixels_le, pack_u32_pixels_le},
};
use lurek2d::province::render::{
    generate_render_commands, ProvinceRenderOptions, ProvinceZoomMode,
};
use lurek2d::province::registry::ProvinceRegistry;
use lurek2d::province::types::{BorderPairFlags, BorderPairStyle, BorderType, BorderTypeConfig};
use lurek2d::render::renderer::{DrawMode, RenderCommand};

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

#[test]
fn test_registry_from_grid_has_provinces_and_adjacency() {
    let grid = sample_grid();
    let reg = ProvinceRegistry::from_grid(&grid);
    assert_eq!(reg.province_count(), 2);

    let neighbors_1 = reg.get_neighbors(1);
    assert_eq!(neighbors_1, vec![2]);

    let neighbors_2 = reg.get_neighbors(2);
    assert_eq!(neighbors_2, vec![1]);
}

#[test]
fn test_registry_revision_and_change_tracking() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);
    assert_eq!(reg.revision(), 0);

    assert!(reg.set_political_color(1, [1.0, 0.0, 0.0, 1.0]));
    assert!(reg.set_terrain_type(1, 7));

    let rev = reg.revision();
    assert!(rev >= 2);

    let changes = reg.get_changes_since(0);
    assert!(changes.len() >= 2);
}

#[test]
fn test_registry_border_type_roundtrip() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);

    reg.set_border_type(1, 2, 1);
    assert_eq!(reg.get_border_type(1, 2), Some(1));
    assert_eq!(reg.get_border_type(2, 1), Some(1));
}

#[test]
fn test_registry_border_type_config() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);

    reg.register_border_type(0, BorderTypeConfig {
        name: "land".to_string(),
        color: [0.5, 0.5, 0.5, 1.0],
        thickness: 1.0,
        draw_priority: 0,
    });
    reg.register_border_type(1, BorderTypeConfig {
        name: "coast".to_string(),
        color: [0.0, 0.5, 1.0, 1.0],
        thickness: 2.0,
        draw_priority: 1,
    });

    let config0 = reg.get_border_type_config(0).expect("config 0");
    assert_eq!(config0.name, "land");
    let config1 = reg.get_border_type_config(1).expect("config 1");
    assert_eq!(config1.name, "coast");
    assert_eq!(config1.thickness, 2.0);
    assert!(reg.get_border_type_config(2).is_none());
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
    reg.set_border_pair_style(1, 2, style);
    let got = reg.get_border_pair_style(2, 1).expect("style should exist");

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

    assert!(reg.set_capital(1, 10.5, 20.5));
    assert_eq!(reg.capital_for(1), Some((10.5, 20.5)));

    assert!(reg.set_label_line(1, 1.0, 2.0, 3.0, 4.0));
    assert_eq!(reg.label_line_for(1), Some(((1.0, 2.0), (3.0, 4.0))));

    assert!(reg.set_label_text(1, "Yukon".to_string()));
    assert_eq!(reg.label_text_for(1), Some("Yukon"));

    assert!(reg.bbox_for(1).is_some());
    assert!(reg.spans_for(1).is_some());
    assert!(reg.style_for(1).is_some());
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

    let mut opts = ProvinceMetadataImportOptions::default();
    opts.color_map_png_path = color_path.to_string_lossy().into_owned();
    opts.marker_png_path = Some(marked_path.to_string_lossy().into_owned());
    opts.color_csv_path = csv_path.to_string_lossy().into_owned();
    opts.province_toml_path = Some(toml_path.to_string_lossy().into_owned());

    let summary = import_metadata_from_files(&mut reg, &opts).expect("import metadata");
    assert_eq!(summary.mapped_provinces, 1);
    assert!(summary.capitals_set >= 1);
    assert!(summary.labels_set >= 1);

    let snap = reg.get_province(1).expect("province 1 snapshot");
    assert_eq!(snap.style.terrain_type, 0);
    assert_eq!(snap.attrs.get("game_id").map(String::as_str), Some("101"));
    assert_eq!(snap.attrs.get("terrain").map(String::as_str), Some("sea"));
    assert_eq!(
        snap.attrs.get("name").map(String::as_str),
        Some("Alpha Province")
    );
    assert_eq!(reg.label_text_for(1), Some("Alpha Province"));
    assert_eq!(reg.capital_for(1), Some((1.5, 0.5)));
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
    assert!(reg.set_visibility_state(1, 0));
    assert!(reg.set_visibility_state(2, 1));

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
    assert!(has_discovered_gray, "discovered province should render gray fill");
}

#[test]
fn test_fow_borders_require_both_provinces_fully_visible() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);
    assert!(reg.set_visibility_state(1, 2));
    assert!(reg.set_visibility_state(2, 2));

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
    assert!(visible_lines > 0, "expected border lines when both provinces are visible");

    assert!(reg.set_visibility_state(2, 1));
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
    assert!(reg.set_capital(1, 1.0, 1.0));
    assert!(reg.set_visibility_state(1, 1));

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

    assert!(reg.set_visibility_state(1, 2));
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
fn test_strategic_mode_renders_country_overrides_but_skips_land_land() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);
    assert!(reg.set_visibility_state(1, 2));
    assert!(reg.set_visibility_state(2, 2));

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
    assert!(tactical_lines > 0, "tactical mode should draw default land-land borders");

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
        1,
        2,
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
            if x >= 1 && x <= 3 && y >= 1 && y <= 3 {
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
    assert!(center > 0, "interior pixel distance must be greater than zero");
}

#[test]
fn test_border_index_builds_pair_ids_and_dilation_expands_coverage() {
    let grid = sample_grid();
    let mut reg = ProvinceRegistry::from_grid(&grid);

    let mut index = build_border_index_from_registry(&reg);
    assert_eq!(index.pair_count(), 1, "sample grid should have one border pair");

    let border_pixels_before = index.data.iter().filter(|&&v| v != 0).count();
    assert!(border_pixels_before > 0, "border index should mark border pixels");

    let mut flags = BorderPairFlags::empty();
    flags.insert_bits(BorderPairFlags::COUNTRY);
    reg.set_border_pair_style(
        1,
        2,
        BorderPairStyle {
            color: Some([1.0, 0.0, 0.0, 1.0]),
            thickness: 4.0,
            flags,
        },
    );

    let mut styles = std::collections::HashMap::new();
    let style = reg
        .get_border_pair_style(1, 2)
        .expect("pair style should be present");
    styles.insert((1, 2), style);
    dilate_border_index_with_styles(&mut index, &styles);

    let border_pixels_after = index.data.iter().filter(|&&v| v != 0).count();
    assert!(
        border_pixels_after >= border_pixels_before,
        "dilation should not reduce border coverage"
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
        1,
        2,
        BorderPairStyle {
            color: Some([1.0, 0.0, 0.0, 1.0]),
            thickness: 4.0,
            flags,
        },
    );

    let records = build_border_style_gpu_records(&reg, &index);
    assert_eq!(records.len(), index.id_to_pair.len());
    assert_eq!(records[0].flags, 0, "slot 0 should stay empty");
    assert_eq!(records[1].flags & 0x01, 0x01, "country flag should be propagated");
    assert_eq!(records[1].thickness, 4.0);
    assert_eq!(records[1].color, [1.0, 0.0, 0.0, 1.0]);
}
