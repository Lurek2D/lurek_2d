-- Golden test: globe compare evidence output against golden samples

-- @describe golden: globe evidence comparison
describe("golden: globe evidence comparison", function()
    it("matches globe baselines", function()
        expect_golden_file_match(
            evidence_output_dir("globe") .. "globe_great_circle_route.png",
            "tests/artifacts/baselines/globe/globe_great_circle_route.png"
        )
        expect_golden_file_match(
            evidence_output_dir("globe") .. "globe_province_projection.png",
            "tests/artifacts/baselines/globe/globe_province_projection.png"
        )
        expect_golden_text_match(
            evidence_output_dir("globe") .. "globe_great_circle_metrics.txt",
            "tests/artifacts/baselines/globe/globe_great_circle_metrics.txt"
        )
        expect_golden_text_match(
            evidence_output_dir("globe") .. "globe_region_trace.txt",
            "tests/artifacts/baselines/globe/globe_region_trace.txt"
        )
        expect_golden_text_match(
            evidence_output_dir("globe") .. "globe_camera_fog_registry_trace.txt",
            "tests/artifacts/baselines/globe/globe_camera_fog_registry_trace.txt"
        )
    end)
end)
test_summary()
