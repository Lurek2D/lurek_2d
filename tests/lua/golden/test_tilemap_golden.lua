-- Golden test: tilemap compare evidence output against golden samples

-- @describe golden: tilemap evidence comparison
describe("golden: tilemap evidence comparison", function()
    it("matches tilemap baselines", function()
        expect_golden_file_match(
            evidence_output_dir("tilemap") .. "tilemap_layers.png",
            "tests/artifacts/baselines/tilemap/tilemap_layers.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilemap") .. "tilemap_collision.png",
            "tests/artifacts/baselines/tilemap/tilemap_collision.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilemap") .. "tilemap_isometric.png",
            "tests/artifacts/baselines/tilemap/tilemap_isometric.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilemap") .. "tilemap_viewport.png",
            "tests/artifacts/baselines/tilemap/tilemap_viewport.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilemap") .. "tilemap_autotile.png",
            "tests/artifacts/baselines/tilemap/tilemap_autotile.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilemap") .. "tilemap_draw_to_image_ground.png",
            "tests/artifacts/baselines/tilemap/tilemap_draw_to_image_ground.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilemap") .. "tilemap_draw_to_image_objects.png",
            "tests/artifacts/baselines/tilemap/tilemap_draw_to_image_objects.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilemap") .. "tilemap_hex_biomes_area.png",
            "tests/artifacts/baselines/tilemap/tilemap_hex_biomes_area.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilemap") .. "tilemap_hex_route.png",
            "tests/artifacts/baselines/tilemap/tilemap_hex_route.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilemap") .. "tilemap_hex_neighbors.png",
            "tests/artifacts/baselines/tilemap/tilemap_hex_neighbors.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilemap") .. "tilemap_hex_operations_frontier.png",
            "tests/artifacts/baselines/tilemap/tilemap_hex_operations_frontier.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilemap") .. "tilemap_chunk_streaming_window.png",
            "tests/artifacts/baselines/tilemap/tilemap_chunk_streaming_window.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilemap") .. "tilemap_isometric_stacked_settlement.png",
            "tests/artifacts/baselines/tilemap/tilemap_isometric_stacked_settlement.png"
        )
    end)
end)
test_summary()
