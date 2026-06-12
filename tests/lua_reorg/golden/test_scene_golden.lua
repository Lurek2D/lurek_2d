-- Golden test: scene compare evidence output against golden samples

-- @describe golden: scene evidence comparison
describe("golden: scene evidence comparison", function()
    it("matches scene baselines", function()
        expect_golden_text_match(
            evidence_output_dir("scene") .. "scene_depth_sort_ascending.txt",
            "tests/artifacts/baselines/scene/scene_depth_sort_ascending.txt"
        )
        expect_golden_file_match(
            evidence_output_dir("scene") .. "scene_depth_sort_bands.png",
            "tests/artifacts/baselines/scene/scene_depth_sort_bands.png"
        )
        expect_golden_text_match(
            evidence_output_dir("scene") .. "scene_depth_sort_object_entries.txt",
            "tests/artifacts/baselines/scene/scene_depth_sort_object_entries.txt"
        )
        expect_golden_text_match(
            evidence_output_dir("scene") .. "scene_depth_sort_stable_equal_depth.txt",
            "tests/artifacts/baselines/scene/scene_depth_sort_stable_equal_depth.txt"
        )
        expect_golden_text_match(
            evidence_output_dir("scene") .. "scene_transition_queue_trace.txt",
            "tests/artifacts/baselines/scene/scene_transition_queue_trace.txt"
        )
    end)
end)
test_summary()
