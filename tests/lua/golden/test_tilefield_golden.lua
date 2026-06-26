-- Golden test: tilefield evidence comparison.

-- @describe golden: tilefield evidence comparison
describe("golden: tilefield evidence comparison", function()
    it("matches tilefield visual baselines", function()
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_channels.png",
            "tests/artifacts/baselines/tilefield/tilefield_channels.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_hex_systems_01_procgen_refs.png",
            "tests/artifacts/baselines/tilefield/tilefield_hex_systems_01_procgen_refs.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_hex_systems_02_procgen_move_costs.png",
            "tests/artifacts/baselines/tilefield/tilefield_hex_systems_02_procgen_move_costs.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_hex_systems_03_mapblock_to_refs.png",
            "tests/artifacts/baselines/tilefield/tilefield_hex_systems_03_mapblock_to_refs.png"
        )
        expect_golden_text_match(
            evidence_output_dir("tilefield") .. "tilefield_hex_systems_04_mapblock_write_report.txt",
            "tests/artifacts/baselines/tilefield/tilefield_hex_systems_04_mapblock_write_report.txt"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_hex_systems_05_tileset_object_semantics.png",
            "tests/artifacts/baselines/tilefield/tilefield_hex_systems_05_tileset_object_semantics.png"
        )
        expect_golden_text_match(
            evidence_output_dir("tilefield") .. "tilefield_hex_systems_06_tileset_catalog_refs.txt",
            "tests/artifacts/baselines/tilefield/tilefield_hex_systems_06_tileset_catalog_refs.txt"
        )
        expect_golden_text_match(
            evidence_output_dir("tilefield") .. "tilefield_hex_systems_07_sprite_atlas_manifest.txt",
            "tests/artifacts/baselines/tilefield/tilefield_hex_systems_07_sprite_atlas_manifest.txt"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_hex_systems_08_tilemap_from_refs.png",
            "tests/artifacts/baselines/tilefield/tilefield_hex_systems_08_tilemap_from_refs.png"
        )
        expect_golden_text_match(
            evidence_output_dir("tilefield") .. "tilefield_hex_systems_09_tilemap_render_adapters.txt",
            "tests/artifacts/baselines/tilefield/tilefield_hex_systems_09_tilemap_render_adapters.txt"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_hex_systems_10_pathfind_route.png",
            "tests/artifacts/baselines/tilefield/tilefield_hex_systems_10_pathfind_route.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_hex_systems_11_pathfind_range.png",
            "tests/artifacts/baselines/tilefield/tilefield_hex_systems_11_pathfind_range.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_hex_systems_12_pathfind_fov.png",
            "tests/artifacts/baselines/tilefield/tilefield_hex_systems_12_pathfind_fov.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_hex_systems_13_awareness_players.png",
            "tests/artifacts/baselines/tilefield/tilefield_hex_systems_13_awareness_players.png"
        )
        expect_golden_text_match(
            evidence_output_dir("tilefield") .. "tilefield_hex_systems_14_awareness_team.txt",
            "tests/artifacts/baselines/tilefield/tilefield_hex_systems_14_awareness_team.txt"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_hex_systems_15_awareness_cone.png",
            "tests/artifacts/baselines/tilefield/tilefield_hex_systems_15_awareness_cone.png"
        )
        expect_golden_text_match(
            evidence_output_dir("tilefield") .. "tilefield_hex_systems_16_awareness_line_channels.txt",
            "tests/artifacts/baselines/tilefield/tilefield_hex_systems_16_awareness_line_channels.txt"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_hex_systems_17_tilelight_point_blockers.png",
            "tests/artifacts/baselines/tilefield/tilefield_hex_systems_17_tilelight_point_blockers.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_hex_systems_18_tilelight_many_sources.png",
            "tests/artifacts/baselines/tilefield/tilefield_hex_systems_18_tilelight_many_sources.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_hex_systems_19_tilelight_line_area.png",
            "tests/artifacts/baselines/tilefield/tilefield_hex_systems_19_tilelight_line_area.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_hex_systems_20_tilelight_global_multilevel.png",
            "tests/artifacts/baselines/tilefield/tilefield_hex_systems_20_tilelight_global_multilevel.png"
        )
        expect_golden_text_match(
            evidence_output_dir("tilefield") .. "tilefield_hex_systems_21_tilelight_source_lifecycle.txt",
            "tests/artifacts/baselines/tilefield/tilefield_hex_systems_21_tilelight_source_lifecycle.txt"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_hex_systems_22_fog_light_minimap.png",
            "tests/artifacts/baselines/tilefield/tilefield_hex_systems_22_fog_light_minimap.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_hex_systems_23_fieldmap_chunks.png",
            "tests/artifacts/baselines/tilefield/tilefield_hex_systems_23_fieldmap_chunks.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_hex_systems_24_procgen_mapblock_overlay.png",
            "tests/artifacts/baselines/tilefield/tilefield_hex_systems_24_procgen_mapblock_overlay.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_hex_systems_25_final_maptile_render.png",
            "tests/artifacts/baselines/tilefield/tilefield_hex_systems_25_final_maptile_render.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_lighting_multilevel.png",
            "tests/artifacts/baselines/tilefield/tilefield_lighting_multilevel.png"
        )
        expect_golden_text_match(
            evidence_output_dir("tilefield") .. "tilefield_lighting_values.txt",
            "tests/artifacts/baselines/tilefield/tilefield_lighting_values.txt"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_raycaster_input.png",
            "tests/artifacts/baselines/tilefield/tilefield_raycaster_input.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_systems_01_procgen_refs.png",
            "tests/artifacts/baselines/tilefield/tilefield_systems_01_procgen_refs.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_systems_02_procgen_move_costs.png",
            "tests/artifacts/baselines/tilefield/tilefield_systems_02_procgen_move_costs.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_systems_03_mapblock_to_refs.png",
            "tests/artifacts/baselines/tilefield/tilefield_systems_03_mapblock_to_refs.png"
        )
        expect_golden_text_match(
            evidence_output_dir("tilefield") .. "tilefield_systems_04_mapblock_write_report.txt",
            "tests/artifacts/baselines/tilefield/tilefield_systems_04_mapblock_write_report.txt"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_systems_05_tileset_object_semantics.png",
            "tests/artifacts/baselines/tilefield/tilefield_systems_05_tileset_object_semantics.png"
        )
        expect_golden_text_match(
            evidence_output_dir("tilefield") .. "tilefield_systems_06_tileset_catalog_refs.txt",
            "tests/artifacts/baselines/tilefield/tilefield_systems_06_tileset_catalog_refs.txt"
        )
        expect_golden_text_match(
            evidence_output_dir("tilefield") .. "tilefield_systems_07_sprite_atlas_manifest.txt",
            "tests/artifacts/baselines/tilefield/tilefield_systems_07_sprite_atlas_manifest.txt"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_systems_08_tilemap_from_refs.png",
            "tests/artifacts/baselines/tilefield/tilefield_systems_08_tilemap_from_refs.png"
        )
        expect_golden_text_match(
            evidence_output_dir("tilefield") .. "tilefield_systems_09_tilemap_render_adapters.txt",
            "tests/artifacts/baselines/tilefield/tilefield_systems_09_tilemap_render_adapters.txt"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_systems_10_pathfind_route.png",
            "tests/artifacts/baselines/tilefield/tilefield_systems_10_pathfind_route.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_systems_11_pathfind_range.png",
            "tests/artifacts/baselines/tilefield/tilefield_systems_11_pathfind_range.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_systems_12_pathfind_flow.png",
            "tests/artifacts/baselines/tilefield/tilefield_systems_12_pathfind_flow.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_systems_13_awareness_players.png",
            "tests/artifacts/baselines/tilefield/tilefield_systems_13_awareness_players.png"
        )
        expect_golden_text_match(
            evidence_output_dir("tilefield") .. "tilefield_systems_14_awareness_team.txt",
            "tests/artifacts/baselines/tilefield/tilefield_systems_14_awareness_team.txt"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_systems_15_awareness_cone.png",
            "tests/artifacts/baselines/tilefield/tilefield_systems_15_awareness_cone.png"
        )
        expect_golden_text_match(
            evidence_output_dir("tilefield") .. "tilefield_systems_16_awareness_line_channels.txt",
            "tests/artifacts/baselines/tilefield/tilefield_systems_16_awareness_line_channels.txt"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_systems_17_tilelight_point_blockers.png",
            "tests/artifacts/baselines/tilefield/tilefield_systems_17_tilelight_point_blockers.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_systems_18_tilelight_many_sources.png",
            "tests/artifacts/baselines/tilefield/tilefield_systems_18_tilelight_many_sources.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_systems_19_tilelight_line_area.png",
            "tests/artifacts/baselines/tilefield/tilefield_systems_19_tilelight_line_area.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_systems_20_tilelight_global_multilevel.png",
            "tests/artifacts/baselines/tilefield/tilefield_systems_20_tilelight_global_multilevel.png"
        )
        expect_golden_text_match(
            evidence_output_dir("tilefield") .. "tilefield_systems_21_tilelight_source_lifecycle.txt",
            "tests/artifacts/baselines/tilefield/tilefield_systems_21_tilelight_source_lifecycle.txt"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_systems_22_fog_light_minimap.png",
            "tests/artifacts/baselines/tilefield/tilefield_systems_22_fog_light_minimap.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_systems_23_fieldmap_chunks.png",
            "tests/artifacts/baselines/tilefield/tilefield_systems_23_fieldmap_chunks.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_systems_24_procgen_mapblock_overlay.png",
            "tests/artifacts/baselines/tilefield/tilefield_systems_24_procgen_mapblock_overlay.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_systems_25_final_maptile_render.png",
            "tests/artifacts/baselines/tilefield/tilefield_systems_25_final_maptile_render.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_systems_26_iso_xcom_slot_logic.png",
            "tests/artifacts/baselines/tilefield/tilefield_systems_26_iso_xcom_slot_logic.png"
        )
        expect_golden_text_match(
            evidence_output_dir("tilefield") .. "tilefield_systems_26_iso_xcom_slot_logic.txt",
            "tests/artifacts/baselines/tilefield/tilefield_systems_26_iso_xcom_slot_logic.txt"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_visibility_action_players.png",
            "tests/artifacts/baselines/tilefield/tilefield_visibility_action_players.png"
        )
    end)
end)

test_summary()
