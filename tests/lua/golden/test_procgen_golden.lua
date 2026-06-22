-- Golden test: procgen compare evidence output against golden samples

-- @describe golden: procgen evidence comparison
describe("golden: procgen evidence comparison", function()
    it("matches current procgen baselines", function()
        expect_golden_file_match(
            evidence_output_dir("procgen") .. "procgen_cellular_material_sandbox.gif",
            "tests/artifacts/baselines/procgen/procgen_cellular_material_sandbox.gif"
        )
        expect_golden_file_match(
            evidence_output_dir("procgen") .. "procgen_climate_biome_world.png",
            "tests/artifacts/baselines/procgen/procgen_climate_biome_world.png"
        )
        expect_golden_file_match(
            evidence_output_dir("procgen") .. "procgen_cellular_flood.png",
            "tests/artifacts/baselines/procgen/procgen_cellular_flood.png"
        )
        expect_golden_file_match(
            evidence_output_dir("procgen") .. "procgen_cellular_cave_map.png",
            "tests/artifacts/baselines/procgen/procgen_cellular_cave_map.png"
        )
        expect_golden_file_match(
            evidence_output_dir("procgen") .. "procgen_cellular_dense_map.png",
            "tests/artifacts/baselines/procgen/procgen_cellular_dense_map.png"
        )
        expect_golden_file_match(
            evidence_output_dir("procgen") .. "procgen_poisson_voronoi.png",
            "tests/artifacts/baselines/procgen/procgen_poisson_voronoi.png"
        )
        expect_golden_file_match(
            evidence_output_dir("procgen") .. "procgen_noise_map.png",
            "tests/artifacts/baselines/procgen/procgen_noise_map.png"
        )
        expect_golden_file_match(
            evidence_output_dir("procgen") .. "procgen_noise_map_parallel.png",
            "tests/artifacts/baselines/procgen/procgen_noise_map_parallel.png"
        )
        expect_golden_file_match(
            evidence_output_dir("procgen") .. "procgen_perlin_strip.png",
            "tests/artifacts/baselines/procgen/procgen_perlin_strip.png"
        )
        expect_golden_file_match(
            evidence_output_dir("procgen") .. "procgen_simplex2d_strip.png",
            "tests/artifacts/baselines/procgen/procgen_simplex2d_strip.png"
        )
        expect_golden_file_match(
            evidence_output_dir("procgen") .. "procgen_simplex3d_strip.png",
            "tests/artifacts/baselines/procgen/procgen_simplex3d_strip.png"
        )
        expect_golden_file_match(
            evidence_output_dir("procgen") .. "procgen_bsp_dungeon.png",
            "tests/artifacts/baselines/procgen/procgen_bsp_dungeon.png"
        )
        expect_golden_file_match(
            evidence_output_dir("procgen") .. "procgen_rooms_dungeon.png",
            "tests/artifacts/baselines/procgen/procgen_rooms_dungeon.png"
        )
        expect_golden_file_match(
            evidence_output_dir("procgen") .. "procgen_height_worldgraph.png",
            "tests/artifacts/baselines/procgen/procgen_height_worldgraph.png"
        )
        expect_golden_file_match(
            evidence_output_dir("procgen") .. "procgen_lsystem_river_settlement.png",
            "tests/artifacts/baselines/procgen/procgen_lsystem_river_settlement.png"
        )
        expect_golden_file_match(
            evidence_output_dir("procgen") .. "procgen_prefab_dungeon_stamps.png",
            "tests/artifacts/baselines/procgen/procgen_prefab_dungeon_stamps.png"
        )
        expect_golden_file_match(
            evidence_output_dir("procgen") .. "procgen_wfc_constraint_world.png",
            "tests/artifacts/baselines/procgen/procgen_wfc_constraint_world.png"
        )
        expect_golden_file_match(
            evidence_output_dir("procgen") .. "procgen_wfc_lsystem_names.png",
            "tests/artifacts/baselines/procgen/procgen_wfc_lsystem_names.png"
        )
        expect_golden_file_match(
            evidence_output_dir("procgen") .. "procgen_noise_heightmap_colored.png",
            "tests/artifacts/baselines/procgen/procgen_noise_heightmap_colored.png"
        )
        expect_golden_text_match(
            evidence_output_dir("procgen") .. "procgen_cellular_cave_map_stats.txt",
            "tests/artifacts/baselines/procgen/procgen_cellular_cave_map_stats.txt"
        )
        expect_golden_text_match(
            evidence_output_dir("procgen") .. "procgen_perlin_grid.json",
            "tests/artifacts/baselines/procgen/procgen_perlin_grid.json"
        )
        expect_golden_text_match(
            evidence_output_dir("procgen") .. "procgen_seeded_noise_grid.json",
            "tests/artifacts/baselines/procgen/procgen_seeded_noise_grid.json"
        )
        expect_golden_text_match(
            evidence_output_dir("procgen") .. "procgen_simplex_grid.json",
            "tests/artifacts/baselines/procgen/procgen_simplex_grid.json"
        )
    end)
end)
test_summary()
