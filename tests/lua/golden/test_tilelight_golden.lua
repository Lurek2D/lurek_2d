-- Golden test: tilelight

-- @describe golden: tilelight evidence comparison
describe("golden: tilelight evidence comparison", function()
    it("matches golden samples", function()
        expect_golden_file_match(
            evidence_output_dir("tilelight") .. "tilelight_hex_sources_blockers.png",
            "tests/artifacts/baselines/tilelight/tilelight_hex_sources_blockers.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilelight") .. "tilelight_multilevel_volume.png",
            "tests/artifacts/baselines/tilelight/tilelight_multilevel_volume.png"
        )
        expect_golden_text_match(
            evidence_output_dir("tilelight") .. "tilelight_multilevel_samples.txt",
            "tests/artifacts/baselines/tilelight/tilelight_multilevel_samples.txt"
        )
        expect_golden_file_match(
            evidence_output_dir("tilelight") .. "tilelight_square_sources_blockers.png",
            "tests/artifacts/baselines/tilelight/tilelight_square_sources_blockers.png"
        )
    end)
end)
test_summary()
