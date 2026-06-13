-- Golden test: svg compare evidence output against golden samples

-- @describe golden: svg evidence comparison
describe("golden: svg evidence comparison", function()
    it("matches svg baselines", function()
        expect_golden_file_match(
            evidence_output_dir("svg") .. "svg_geometry_debug.png",
            "tests/artifacts/baselines/svg/svg_geometry_debug.png"
        )
        expect_golden_text_match(
            evidence_output_dir("svg") .. "svg_report.txt",
            "tests/artifacts/baselines/svg/svg_report.txt"
        )
        expect_golden_file_match(
            evidence_output_dir("svg") .. "svg_transform_visibility.png",
            "tests/artifacts/baselines/svg/svg_transform_visibility.png"
        )
    end)
end)
test_summary()
