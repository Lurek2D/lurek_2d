//! File: tests/rust/unit/tilemap_tests.rs

use lurek2d::render::RenderCommand;
use lurek2d::runtime::resource_keys::ShaderKey;
use lurek2d::tilemap::*;
use lurek2d::tileset::{AutoTileMode, TileAnimFrame, TileSet};
use slotmap::KeyData;

mod ldtk_tests {
    use super::*;

    pub(super) const MINIMAL_LDTK: &str = r#"{
        "levels": [{
            "identifier": "Level_0",
            "layerInstances": [{
                "__identifier": "Ground",
                "__type": "Tiles",
                "__gridSize": 16,
                "__cWid": 4,
                "__cHei": 4,
                "gridTiles": [
                    {"px":[0,0],"src":[0,0],"t":0},
                    {"px":[16,0],"src":[16,0],"t":1}
                ],
                "autoLayerTiles": []
            }]
        }]
    }"#;

    #[test]
    fn ldtk_load_first_level_parses_correctly() {
        let map = load_ldtk(MINIMAL_LDTK, None).unwrap();
        let gid = map.get_tile(0, 0, 0);
        assert_eq!(gid, 1, "first tile must have gid=1");
        let gid2 = map.get_tile(0, 1, 0);
        assert_eq!(gid2, 2, "second tile must have gid=2");
    }

    #[test]
    fn ldtk_named_level_selection_works() {
        let result = load_ldtk(MINIMAL_LDTK, Some("Level_0"));
        assert!(result.is_ok());
    }

    #[test]
    fn ldtk_missing_level_returns_error() {
        let result = load_ldtk(MINIMAL_LDTK, Some("Missing_Level"));
        let err = result.expect_err("missing level should error");
        assert_eq!(err.code, "ldtk_level_not_found");
        assert!(err.message.contains("Missing_Level"));
    }

    #[test]
    fn ldtk_invalid_json_returns_error() {
        let result = load_ldtk("not json", None);
        let err = result.expect_err("invalid json should error");
        assert_eq!(err.code, "ldtk_json_parse");
        assert!(err.message.contains("LDtk JSON parse error"));
    }

    #[test]
    fn ldtk_missing_levels_array_returns_structured_error() {
        let result = load_ldtk("{}", None);
        let err = result.expect_err("missing levels should error");
        assert_eq!(err.code, "ldtk_missing_levels");
        assert!(err.message.contains("levels"));
    }
}

mod tmx_tests {
    use super::*;

    #[test]
    fn tmx_invalid_xml_returns_line_and_column() {
        let err = load_tmx("<map>").expect_err("invalid xml should error");
        assert_eq!(err.code, "tmx_xml_parse");
        assert!(err.line.is_some());
        assert!(err.column.is_some());
    }

    #[test]
    fn tmx_missing_map_root_returns_structured_error() {
        let err = load_tmx("<tileset></tileset>").expect_err("missing map root should error");
        assert_eq!(err.code, "tmx_missing_map_root");
    }

    #[test]
    fn tmx_missing_required_attribute_returns_structured_error() {
        let xml = r#"<?xml version="1.0" encoding="UTF-8"?>
    <map version="1.10" orientation="orthogonal" width="2" height="2" tilewidth="16"></map>"#;
        let err = load_tmx(xml).expect_err("missing tileheight should error");
        assert_eq!(err.code, "tmx_invalid_content");
        assert!(err.message.contains("tileheight"));
    }
}

mod isomap_tests {
    use super::*;

    fn make_map() -> IsoMap {
        IsoMap::new(4, 4, 64, 32, 24, 4)
    }

    #[test]
    fn add_level_returns_index() {
        let mut m = make_map();
        assert_eq!(m.add_level(), 0);
        assert_eq!(m.add_level(), 1);
        assert_eq!(m.get_level_count(), 2);
    }

    #[test]
    fn tile_part_round_trip() {
        let mut m = make_map();
        m.add_level();
        m.set_tile_part(0, 1, 2, 0, 42);
        assert_eq!(m.get_tile_part(0, 1, 2, 0), 42);
        assert_eq!(m.get_tile_part(0, 1, 2, 1), 0);
    }

    #[test]
    fn tile_part_oob_returns_zero() {
        let mut m = make_map();
        m.add_level();
        assert_eq!(m.get_tile_part(0, 99, 99, 0), 0);
        assert_eq!(m.get_tile_part(5, 0, 0, 0), 0);
        assert_eq!(m.get_tile_part(0, 0, 0, 4), 0);
    }

    #[test]
    fn fill_level() {
        let mut m = make_map();
        m.add_level();
        m.fill_level(0, 0, 7);
        for y in 0..4 {
            for x in 0..4 {
                assert_eq!(m.get_tile_part(0, x, y, 0), 7);
                assert_eq!(m.get_tile_part(0, x, y, 1), 0);
            }
        }
    }

    #[test]
    fn tile_to_screen() {
        let mut m = IsoMap::new(10, 10, 64, 32, 24, 4);
        m.origin_x = 400.0;
        m.origin_y = 50.0;
        let (sx, sy) = m.tile_to_screen(0.0, 0.0, 0.0);
        assert!((sx - 400.0).abs() < 1e-4);
        assert!((sy - 50.0).abs() < 1e-4);
        let (sx, sy) = m.tile_to_screen(1.0, 0.0, 0.0);
        assert!((sx - 432.0).abs() < 1e-4);
        assert!((sy - 66.0).abs() < 1e-4);
        let (_, sy2) = m.tile_to_screen(1.0, 0.0, 1.0);
        assert!((sy2 - (66.0 - 24.0)).abs() < 1e-4);
    }

    #[test]
    fn screen_to_tile_inverse() {
        let mut m = IsoMap::new(10, 10, 64, 32, 24, 4);
        m.origin_x = 200.0;
        m.origin_y = 100.0;
        let (sx, sy) = m.tile_to_screen(3.0, 2.0, 0.0);
        let (tx, ty) = m.screen_to_tile(sx, sy);
        assert!((tx - 3.0).abs() < 1e-4);
        assert!((ty - 2.0).abs() < 1e-4);
    }

    #[test]
    fn draw_iter_order() {
        let mut m = IsoMap::new(2, 2, 64, 32, 24, 4);
        m.add_level();
        let items = m.draw_iter(0);
        assert_eq!(items.len(), 16);
        let first = &items[0];
        assert_eq!((first.tile_x, first.tile_y, first.part), (0, 0, 0));
        let second_group = &items[4];
        assert_eq!((second_group.tile_x, second_group.tile_y), (0, 1));
        let third_group = &items[8];
        assert_eq!((third_group.tile_x, third_group.tile_y), (1, 0));
        let last = &items[12];
        assert_eq!((last.tile_x, last.tile_y), (1, 1));
    }

    #[test]
    fn draw_iter_multi_z_order() {
        let mut m = IsoMap::new(1, 1, 64, 32, 24, 4);
        m.add_level();
        m.add_level();
        m.set_tile_part(0, 0, 0, 0, 10);
        m.set_tile_part(1, 0, 0, 0, 20);

        let items = m.draw_iter(1);
        assert_eq!(items.len(), 8);
        assert_eq!(items[0].level, 0);
        assert_eq!(items[0].gid, 10);
        assert_eq!(items[4].level, 1);
        assert_eq!(items[4].gid, 20);
    }

    #[test]
    fn level_visible_skip() {
        let mut m = IsoMap::new(1, 1, 64, 32, 24, 4);
        m.add_level();
        m.add_level();
        m.set_level_visible(0, false);

        let items = m.draw_iter(1);
        assert_eq!(items.len(), 4);
        assert_eq!(items[0].level, 1);
    }

    #[test]
    fn active_z_clamped() {
        let mut m = IsoMap::new(1, 1, 64, 32, 24, 4);
        m.add_level();
        let items = m.draw_iter(10);
        assert_eq!(items.len(), 4);
    }

    #[test]
    fn draw_iter_empty() {
        let m = IsoMap::new(4, 4, 64, 32, 24, 4);
        assert!(m.draw_iter(0).is_empty());
    }
}

mod coords_tests {
    use super::*;

    #[test]
    fn iso_roundtrip() {
        let tile_w = 64.0;
        let tile_h = 32.0;
        let screen = to_screen_iso(3.0, 2.0, tile_w, tile_h);
        let back = from_screen_iso(screen.x, screen.y, tile_w, tile_h);
        assert!((back.x - 3.0).abs() < 1e-5);
        assert!((back.y - 2.0).abs() < 1e-5);
    }

    #[test]
    fn hex_screen_roundtrip() {
        let size = 20.0;
        let screen = to_screen_hex(3, -2, size);
        let (rq, rr) = from_screen_hex(screen.x, screen.y, size);
        assert_eq!((rq, rr), (3, -2));
    }
}

mod safety_tests {
    use super::*;

    #[test]
    fn tilemap_try_new_rejects_zero_tile_size() {
        let err = TileMap::try_new(0, 16, 8).expect_err("zero tile width should be rejected");
        assert!(matches!(err, TileMapError::InvalidTileSize { .. }));
    }

    #[test]
    fn tile_layer_try_new_rejects_overflow_dimensions() {
        let limits = TileMapLimits {
            max_tiles_per_layer: 1024,
            ..TileMapLimits::default()
        };
        let err = TileMap::try_new_with_limits(16, 16, 8, limits)
            .and_then(|mut map| map.try_add_layer("overflow", 64, 64))
            .expect_err("oversized layer should be rejected");
        assert!(matches!(err, TileMapError::LayerCellLimitExceeded { .. }));
    }

    #[test]
    fn chunkmap_try_new_rejects_zero_and_huge_chunk_size() {
        let zero = ChunkMap::try_new(0).expect_err("zero chunk size should be rejected");
        assert!(matches!(zero, TileMapError::InvalidChunkSize { .. }));

        let limits = TileMapLimits {
            max_chunk_cells: 256,
            ..TileMapLimits::default()
        };
        let huge = ChunkMap::try_new_with_limits(32, &limits)
            .expect_err("oversized chunk size should be rejected");
        assert!(matches!(huge, TileMapError::ChunkCellLimitExceeded { .. }));
    }

    #[test]
    fn try_world_to_tile_negative_returns_none() {
        let map = TileMap::try_new(16, 16, 8).unwrap();
        assert_eq!(map.try_world_to_tile(-1.0, 0.0), None);
        assert_eq!(map.try_world_to_tile(0.0, -1.0), None);
    }

    #[test]
    fn animation_update_large_dt_advances_multiple_frames() {
        let mut map = TileMap::try_new(16, 16, 8).unwrap();
        let mut ts = TileSet::new(1, 10, 10, 16, 16, 0, 0);
        ts.set_animation(
            0,
            vec![
                TileAnimFrame {
                    tile_id: 0,
                    duration_ms: 100.0,
                },
                TileAnimFrame {
                    tile_id: 9,
                    duration_ms: 100.0,
                },
                TileAnimFrame {
                    tile_id: 2,
                    duration_ms: 100.0,
                },
            ],
        );
        map.add_tileset(ts);
        map.try_add_layer("base", 2, 2).unwrap();
        map.try_set_tile(0, 0, 0, 1).unwrap();
        map.set_viewport(0.0, 0.0, 32.0, 32.0);

        map.update(1.0);

        assert!(map
            .build_render_commands(0.0, 0.0)
            .iter()
            .any(|cmd| matches!(cmd, RenderCommand::Circle { .. })));
    }

    #[test]
    fn tilemap_shader_scope_wraps_generated_render_commands() {
        let mut map = TileMap::try_new(16, 16, 8).unwrap();
        map.try_add_layer("base", 1, 1).unwrap();
        map.try_set_tile(0, 0, 0, 1).unwrap();
        let shader = ShaderKey::from(KeyData::from_ffi(101));
        map.set_shader(Some(shader));

        let commands = map.build_render_commands(0.0, 0.0);

        assert!(matches!(
            commands.first(),
            Some(RenderCommand::SetShader(Some(key))) if *key == shader
        ));
        assert!(commands
            .iter()
            .any(|command| matches!(command, RenderCommand::Rectangle { .. })));
        assert!(matches!(
            commands.last(),
            Some(RenderCommand::SetShader(None))
        ));
    }

    #[test]
    fn tilemap_layer_shader_overrides_map_shader_scope() {
        let mut map = TileMap::try_new(16, 16, 8).unwrap();
        map.try_add_layer("base", 1, 1).unwrap();
        map.try_add_layer("water", 1, 1).unwrap();
        map.try_set_tile(0, 0, 0, 1).unwrap();
        map.try_set_tile(1, 0, 0, 2).unwrap();
        let map_shader = ShaderKey::from(KeyData::from_ffi(101));
        let layer_shader = ShaderKey::from(KeyData::from_ffi(202));
        map.set_shader(Some(map_shader));
        map.set_layer_shader(1, Some(layer_shader)).unwrap();

        let shader_starts = map
            .build_render_commands(0.0, 0.0)
            .into_iter()
            .filter_map(|command| match command {
                RenderCommand::SetShader(Some(key)) => Some(key),
                _ => None,
            })
            .collect::<Vec<_>>();

        assert_eq!(shader_starts, vec![map_shader, layer_shader]);
    }

    #[test]
    fn apply_autotile_at_empty_layer_no_underflow() {
        let mut map = TileMap::try_new(16, 16, 8).unwrap();
        map.try_add_layer("empty", 0, 0).unwrap();
        map.apply_autotile_at(0, 0, 0, "grass");
        map.apply_autotile_8_at(0, 0, 0, "grass");
    }

    #[test]
    fn fill_large_layer_lazy_index_policy() {
        let limits = TileMapLimits {
            max_tiles_per_layer: 10_000_000,
            ..TileMapLimits::default()
        };
        let mut map = TileMap::try_new_with_limits(16, 16, 8, limits).unwrap();
        map.try_add_layer("base", 2_000, 2_000).unwrap();
        map.fill(0, 7);
        let before = map.diagnostics_snapshot().lazy_index_rebuilds;
        let positions = map.find_tiles_by_gid(0, 7);
        let after = map.diagnostics_snapshot().lazy_index_rebuilds;
        assert_eq!(positions.len(), 4_000_000);
        assert_eq!(before + 1, after);
    }

    #[test]
    fn tmx_strict_rejects_short_and_long_layer_data() {
        let short = r#"
            <map width="2" height="2" tilewidth="16" tileheight="16" orientation="orthogonal">
              <layer name="ground">
                <data encoding="csv">1,2,3</data>
              </layer>
            </map>
        "#;
        let options = TmxLoadOptions {
            strict_layer_size: true,
            ..TmxLoadOptions::default()
        };
        let err =
            load_tmx_with_options(short, &options).expect_err("short strict layer should fail");
        assert_eq!(err.code, "tmx_invalid_content");

        let long = r#"
            <map width="2" height="2" tilewidth="16" tileheight="16" orientation="orthogonal">
              <layer name="ground">
                <data encoding="csv">1,2,3,4,5</data>
              </layer>
            </map>
        "#;
        let err = load_tmx_with_options(long, &options).expect_err("long strict layer should fail");
        assert_eq!(err.code, "tmx_invalid_content");
    }

    #[test]
    fn tmx_rejects_decompression_over_limit() {
        let raw = [1u8, 0, 0, 0];
        let encoded = {
            use base64::Engine as _;
            base64::engine::general_purpose::STANDARD.encode(raw)
        };
        let xml = format!(
            r#"<map width="1" height="1" tilewidth="16" tileheight="16" orientation="orthogonal"><layer name="ground"><data encoding="base64">{encoded}</data></layer></map>"#
        );
        let mut options = TmxLoadOptions::default();
        options.limits.max_decoded_bytes = 2;
        let err = load_tmx_with_options(&xml, &options)
            .expect_err("decoded payload over limit should fail");
        assert_eq!(err.code, "tmx_invalid_content");
    }

    #[test]
    fn external_tsx_requires_policy() {
        let xml = r#"
            <map width="1" height="1" tilewidth="16" tileheight="16" orientation="orthogonal">
              <tileset firstgid="1" source="tiles.tsx" />
              <layer name="ground">
                <data encoding="csv">1</data>
              </layer>
            </map>
        "#;
        let err = load_tmx(xml).expect_err("external TSX should require explicit policy");
        assert_eq!(err.code, "tmx_invalid_content");
    }

    #[test]
    fn ldtk_limits_reject_oversized_layers() {
        let limits = TileMapLimits {
            max_tiles_per_layer: 4,
            ..TileMapLimits::default()
        };
        let err = load_ldtk_with_limits(super::ldtk_tests::MINIMAL_LDTK, None, &limits)
            .expect_err("LDtk import should respect layer limits");
        assert_eq!(err.code, "ldtk_invalid_layer");
    }
}

mod chunk_tests {
    use super::*;

    #[test]
    fn new_chunk_reads_zero() {
        let m = ChunkMap::new(16);
        assert_eq!(m.get_tile(0, 0), 0);
        assert_eq!(m.get_tile(-5, 3), 0);
        assert_eq!(m.get_tile(1000, 1000), 0);
    }

    #[test]
    fn set_and_get_tile() {
        let mut m = ChunkMap::new(16);
        m.set_tile(0, 0, 42);
        assert_eq!(m.get_tile(0, 0), 42);
        m.set_tile(-1, -1, 99);
        assert_eq!(m.get_tile(-1, -1), 99);
    }

    #[test]
    fn clear_tile_sets_zero() {
        let mut m = ChunkMap::new(8);
        m.set_tile(3, 3, 7);
        m.clear_tile(3, 3);
        assert_eq!(m.get_tile(3, 3), 0);
    }

    #[test]
    fn fill_rect_writes_all() {
        let mut m = ChunkMap::new(16);
        m.fill_rect(0, 0, 4, 4, 1);
        for y in 0..4 {
            for x in 0..4 {
                assert_eq!(m.get_tile(x, y), 1, "({x},{y}) should be 1");
            }
        }
        assert_eq!(m.get_tile(4, 0), 0);
    }

    #[test]
    fn chunk_allocated_on_write() {
        let mut m = ChunkMap::new(16);
        assert_eq!(m.get_loaded_chunk_count(), 0);
        m.set_tile(0, 0, 1);
        assert_eq!(m.get_loaded_chunk_count(), 1);
        m.set_tile(16, 0, 2);
        assert_eq!(m.get_loaded_chunk_count(), 2);
    }

    #[test]
    fn load_and_unload_chunk() {
        let mut m = ChunkMap::new(16);
        m.load_chunk(0, 0);
        assert!(m.is_chunk_loaded(0, 0));
        m.set_tile(5, 5, 3);
        m.unload_chunk(0, 0);
        assert!(!m.is_chunk_loaded(0, 0));
        assert_eq!(m.get_tile(5, 5), 0);
    }

    #[test]
    fn tile_to_chunk_negative_coords() {
        let m = ChunkMap::new(16);
        assert_eq!(m.tile_to_chunk(-1, -1), (-1, -1));
        assert_eq!(m.tile_to_chunk(-16, -16), (-1, -1));
        assert_eq!(m.tile_to_chunk(-17, -1), (-2, -1));
    }

    #[test]
    fn chunk_tile_range() {
        let m = ChunkMap::new(8);
        let (x0, y0, x1, y1) = m.chunk_tile_range(2, -1);
        assert_eq!((x0, y0, x1, y1), (16, -8, 24, 0));
    }

    #[test]
    fn chunks_in_view() {
        let m = ChunkMap::new(16);
        let chunks = m.get_chunks_in_view(0.0, 0.0, 511.0, 511.0, 32.0, 32.0);
        assert!(chunks.contains(&(0, 0)));
    }

    #[test]
    fn iter_chunk_returns_slice() {
        let mut m = ChunkMap::new(4);
        m.set_tile(1, 2, 5);
        let (cx, cy) = m.tile_to_chunk(1, 2);
        let slice = m
            .iter_chunk(cx, cy)
            .expect("cx/cy in bounds for chunk iteration");
        assert_eq!(slice.len(), 16);
    }

    #[test]
    fn iter_chunk_unloaded_returns_none() {
        let m = ChunkMap::new(8);
        assert!(m.iter_chunk(99, 99).is_none());
    }
}

mod large_map_renderer_tests {
    use super::*;

    fn make_renderer() -> LargeMapRenderer {
        let mut renderer = LargeMapRenderer::new(16, 16);
        renderer.set_chunk_size(8);
        renderer.set_map_data(vec![1; 32 * 32], 32, 32);
        renderer
    }

    #[test]
    fn zero_sized_viewport_counts_all_cached_chunks() {
        let renderer = make_renderer();

        assert_eq!(renderer.get_total_chunks(), 16);
        assert_eq!(renderer.get_visible_chunks(), 16);
    }

    #[test]
    fn camera_view_outside_map_counts_no_visible_chunks() {
        let mut renderer = make_renderer();
        renderer.set_viewport(64.0, 64.0);
        renderer.set_camera(-512.0, -512.0, 1.0);

        assert_eq!(renderer.get_visible_chunks(), 0);
    }
}

mod autotile_sheet_tests {
    use super::*;
    use lurek2d::tilemap::autotile_sheet::{AutoTileLayout, AutoTileSheet};

    #[test]
    fn creation_blob47() {
        let sheet = AutoTileSheet::new(32, 32, AutoTileLayout::Blob47);
        assert_eq!(sheet.get_layout(), AutoTileLayout::Blob47);
        assert_eq!(sheet.get_tile_count(), 47);
        assert_eq!(sheet.get_tile_width(), 32);
        assert_eq!(sheet.get_tile_height(), 32);
    }

    #[test]
    fn creation_composite48() {
        let sheet = AutoTileSheet::new(16, 16, AutoTileLayout::Composite48);
        assert_eq!(sheet.get_layout(), AutoTileLayout::Composite48);
        assert_eq!(sheet.get_tile_count(), 48);
    }

    #[test]
    fn creation_rpgmaker48() {
        let sheet = AutoTileSheet::new(16, 16, AutoTileLayout::RpgMaker48);
        assert_eq!(sheet.get_layout(), AutoTileLayout::RpgMaker48);
        assert_eq!(sheet.get_layout_name(), "rpgmaker48");
        assert_eq!(sheet.get_tile_count(), 48);
        assert_eq!(sheet.get_default_mode(), AutoTileMode::MatchCornersAndSides);
    }

    #[test]
    fn creation_minimal16() {
        let sheet = AutoTileSheet::new(24, 24, AutoTileLayout::Minimal16);
        assert_eq!(sheet.get_layout(), AutoTileLayout::Minimal16);
        assert_eq!(sheet.get_tile_count(), 16);
    }

    #[test]
    fn tile_count_per_layout() {
        assert_eq!(
            AutoTileSheet::new(16, 16, AutoTileLayout::Blob47).get_tile_count(),
            47
        );
        assert_eq!(
            AutoTileSheet::new(16, 16, AutoTileLayout::Composite48).get_tile_count(),
            48
        );
        assert_eq!(
            AutoTileSheet::new(16, 16, AutoTileLayout::RpgMaker48).get_tile_count(),
            48
        );
        assert_eq!(
            AutoTileSheet::new(16, 16, AutoTileLayout::Minimal16).get_tile_count(),
            16
        );
    }

    #[test]
    fn get_quad_bounds() {
        let sheet = AutoTileSheet::new(32, 32, AutoTileLayout::Blob47);
        let q0 = sheet.get_quad(0);
        assert!((q0.x - 0.0).abs() < 1e-5);
        assert!((q0.y - 0.0).abs() < 1e-5);
        assert!((q0.width - 32.0).abs() < 1e-5);
        assert!((q0.height - 32.0).abs() < 1e-5);
        let q5 = sheet.get_quad(5);
        assert!((q5.x - 160.0).abs() < 1e-5);
        assert!((q5.y - 0.0).abs() < 1e-5);
    }

    #[test]
    fn get_quad_out_of_bounds() {
        let sheet = AutoTileSheet::new(32, 32, AutoTileLayout::Minimal16);
        let q = sheet.get_quad(100);
        assert!((q.width - 0.0).abs() < 1e-5);
        assert!((q.height - 0.0).abs() < 1e-5);
    }

    #[test]
    fn bitmask_roundtrip_minimal16() {
        let sheet = AutoTileSheet::new(16, 16, AutoTileLayout::Minimal16);
        for i in 0u32..16 {
            let bm = sheet.get_bitmask_for_tile(i);
            assert_eq!(bm, i as u16);
            let tile = sheet.get_tile_for_bitmask(bm);
            assert_eq!(tile, Some(i));
        }
    }

    #[test]
    fn bitmask_roundtrip_blob47() {
        let sheet = AutoTileSheet::new(16, 16, AutoTileLayout::Blob47);
        for i in 0u32..47 {
            let bm = sheet.get_bitmask_for_tile(i);
            let tile = sheet.get_tile_for_bitmask(bm);
            assert_eq!(tile, Some(i));
        }
    }

    #[test]
    fn bitmask_out_of_bounds() {
        let sheet = AutoTileSheet::new(16, 16, AutoTileLayout::Blob47);
        assert_eq!(sheet.get_bitmask_for_tile(100), 0);
    }

    #[test]
    fn apply_to_tileset_minimal16() {
        let sheet = AutoTileSheet::new(16, 16, AutoTileLayout::Minimal16);
        let mut ts = TileSet::new(1, 16, 4, 16, 16, 0, 0);
        sheet.apply_to_tileset(&mut ts, "grass", None);
        assert_eq!(ts.get_auto_tile_id("grass", 0), Some(0));
        assert_eq!(ts.get_auto_tile_id("grass", 15), Some(15));
    }

    #[test]
    fn apply_to_tileset_with_offset() {
        let sheet = AutoTileSheet::new(16, 16, AutoTileLayout::Minimal16);
        let mut ts = TileSet::new(1, 32, 4, 16, 16, 0, 0);
        sheet.apply_to_tileset(&mut ts, "wall", Some(10));
        assert_eq!(ts.get_auto_tile_id("wall", 0), Some(10));
    }

    #[test]
    fn apply_to_tileset_blob47() {
        let sheet = AutoTileSheet::new(16, 16, AutoTileLayout::Blob47);
        let mut ts = TileSet::new(1, 64, 8, 16, 16, 0, 0);
        sheet.apply_to_tileset(&mut ts, "stone", None);
        let bm0 = sheet.get_bitmask_for_tile(0);
        assert_eq!(ts.get_auto_tile_id_8("stone", bm0), Some(0));
        assert_eq!(
            ts.get_auto_tile_mode("stone"),
            AutoTileMode::MatchCornersAndSides
        );
    }

    #[test]
    fn apply_to_tileset_rpgmaker48_sets_8bit_rules_and_mode() {
        let sheet = AutoTileSheet::new(16, 16, AutoTileLayout::RpgMaker48);
        let mut ts = TileSet::new(1, 64, 8, 16, 16, 0, 0);
        sheet.apply_to_tileset(&mut ts, "water", Some(3));
        let bm0 = sheet.get_bitmask_for_tile(0);
        assert_eq!(ts.get_auto_tile_id_8("water", bm0), Some(3));
        assert_eq!(
            ts.get_auto_tile_mode("water"),
            AutoTileMode::MatchCornersAndSides
        );
    }

    #[test]
    fn layout_equality() {
        assert_ne!(AutoTileLayout::Blob47, AutoTileLayout::Composite48);
        assert_ne!(AutoTileLayout::Composite48, AutoTileLayout::RpgMaker48);
        assert_ne!(AutoTileLayout::Composite48, AutoTileLayout::Minimal16);
        assert_eq!(AutoTileLayout::Blob47, AutoTileLayout::Blob47);
    }

    #[test]
    #[ignore = "reduce_8bit is pub(crate)"]
    fn reduce_8bit_masks_out_irrelevant_diagonals() {
        let _raw = 0b0001_0000;
        let _raw2 = 0b0001_0011;
    }
}

// TileMap layer/tile/viewport/sweep/index behavior: `tests/lua/unit/test_tilemap_core_unit.lua`.
