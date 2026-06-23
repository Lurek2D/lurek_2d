-- Golden test: tilefield evidence comparison.

-- @describe golden: tilefield evidence comparison
describe("golden: tilefield evidence comparison", function()
    it("matches tilefield visual baselines", function()
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_channels.png",
            "tests/artifacts/baselines/tilefield/tilefield_channels.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_visibility_action_players.png",
            "tests/artifacts/baselines/tilefield/tilefield_visibility_action_players.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_lighting_multilevel.png",
            "tests/artifacts/baselines/tilefield/tilefield_lighting_multilevel.png"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_lighting_values.txt",
            "tests/artifacts/baselines/tilefield/tilefield_lighting_values.txt"
        )
        expect_golden_file_match(
            evidence_output_dir("tilefield") .. "tilefield_raycaster_input.png",
            "tests/artifacts/baselines/tilefield/tilefield_raycaster_input.png"
        )
    end)
end)

test_summary()
