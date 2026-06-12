-- Golden test: camera compare evidence output against golden samples

-- @describe golden: camera evidence comparison
describe("golden: camera evidence comparison", function()
    it("matches camera baselines", function()
        expect_golden_file_match(
            evidence_output_dir("camera") .. "camera_follow_path_trace.png",
            "tests/artifacts/baselines/camera/camera_follow_path_trace.png"
        )
        expect_golden_text_match(
            evidence_output_dir("camera") .. "camera_follow_smoothing_trace.json",
            "tests/artifacts/baselines/camera/camera_follow_smoothing_trace.json"
        )
        expect_golden_text_match(
            evidence_output_dir("camera") .. "camera_shake_response_trace.json",
            "tests/artifacts/baselines/camera/camera_shake_response_trace.json"
        )
        expect_golden_text_match(
            evidence_output_dir("camera") .. "camera_transform_samples.json",
            "tests/artifacts/baselines/camera/camera_transform_samples.json"
        )
        expect_golden_file_match(
            evidence_output_dir("camera") .. "camera_visible_area_transform_grid.png",
            "tests/artifacts/baselines/camera/camera_visible_area_transform_grid.png"
        )
    end)
end)
test_summary()
