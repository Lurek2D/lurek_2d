-- Golden test: spine compare evidence output against golden samples

-- @describe golden: spine evidence comparison
describe("golden: spine evidence comparison", function()
    it("matches stable spine baselines", function()
        expect_golden_text_match(
            evidence_output_dir("spine") .. "bone_operations.txt",
            "tests/artifacts/baselines/spine/bone_operations.txt"
        )
        expect_golden_file_match(
            evidence_output_dir("spine") .. "skeleton_stick_figure.png",
            "tests/artifacts/baselines/spine/skeleton_stick_figure.png"
        )
        expect_golden_file_match(
            evidence_output_dir("spine") .. "spine_walk_cycle_5s.gif",
            "tests/artifacts/baselines/spine/spine_walk_cycle_5s.gif"
        )
        expect_golden_file_match(
            evidence_output_dir("spine") .. "spine_walk_cycle_pose_snapshots.gif",
            "tests/artifacts/baselines/spine/spine_walk_cycle_pose_snapshots.gif"
        )
        expect_golden_file_match(
            evidence_output_dir("spine") .. "spine_ik_target_reach.gif",
            "tests/artifacts/baselines/spine/spine_ik_target_reach.gif"
        )
        expect_golden_file_match(
            evidence_output_dir("spine") .. "spine_imported_animation.gif",
            "tests/artifacts/baselines/spine/spine_imported_animation.gif"
        )
    end)
end)
test_summary()
