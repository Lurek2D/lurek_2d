-- Golden test: minimap

-- @describe golden: minimap evidence comparison
describe("golden: minimap evidence comparison", function()
    it("matches golden samples", function()
        expect_golden_file_match(
            evidence_output_dir("minimap") .. "minimap_terrain_palette_grid.png",
            "tests/artifacts/baselines/minimap/minimap_terrain_palette_grid.png"
        )
        expect_golden_file_match(
            evidence_output_dir("minimap") .. "minimap_fog_states.png",
            "tests/artifacts/baselines/minimap/minimap_fog_states.png"
        )
        expect_golden_file_match(
            evidence_output_dir("minimap") .. "minimap_layer_blend_modes.png",
            "tests/artifacts/baselines/minimap/minimap_layer_blend_modes.png"
        )
        expect_golden_file_match(
            evidence_output_dir("minimap") .. "minimap_layer_visibility_toggle.png",
            "tests/artifacts/baselines/minimap/minimap_layer_visibility_toggle.png"
        )
        expect_golden_file_match(
            evidence_output_dir("minimap") .. "minimap_markers_objects_pings.png",
            "tests/artifacts/baselines/minimap/minimap_markers_objects_pings.png"
        )
        expect_golden_file_match(
            evidence_output_dir("minimap") .. "minimap_paths_and_overlay_shapes.png",
            "tests/artifacts/baselines/minimap/minimap_paths_and_overlay_shapes.png"
        )
        expect_golden_file_match(
            evidence_output_dir("minimap") .. "minimap_viewport_rect.png",
            "tests/artifacts/baselines/minimap/minimap_viewport_rect.png"
        )
        expect_golden_file_match(
            evidence_output_dir("minimap") .. "minimap_tilefield_layers.png",
            "tests/artifacts/baselines/minimap/minimap_tilefield_layers.png"
        )
        expect_golden_file_match(
            evidence_output_dir("minimap") .. "minimap_visibility_fog_action.png",
            "tests/artifacts/baselines/minimap/minimap_visibility_fog_action.png"
        )
        expect_golden_file_match(
            evidence_output_dir("minimap") .. "minimap_province_registry_compact.png",
            "tests/artifacts/baselines/minimap/minimap_province_registry_compact.png"
        )
    end)
end)
test_summary()
