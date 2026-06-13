-- Golden test: globe compare evidence output against golden samples

-- @describe golden: globe evidence comparison
describe("golden: globe evidence comparison", function()
    it("matches globe baselines", function()
        expect_golden_file_match(
            evidence_output_dir("globe") .. "globe_atmosphere_scattering.png",
            "tests/artifacts/baselines/globe/globe_atmosphere_scattering.png"
        )
        expect_golden_file_match(
            evidence_output_dir("globe") .. "globe_city_night_lights.png",
            "tests/artifacts/baselines/globe/globe_city_night_lights.png"
        )
        expect_golden_file_match(
            evidence_output_dir("globe") .. "globe_day_night_terminator.png",
            "tests/artifacts/baselines/globe/globe_day_night_terminator.png"
        )
        expect_golden_file_match(
            evidence_output_dir("globe") .. "globe_elevated_markers.png",
            "tests/artifacts/baselines/globe/globe_elevated_markers.png"
        )
        expect_golden_file_match(
            evidence_output_dir("globe") .. "globe_great_circle_route.png",
            "tests/artifacts/baselines/globe/globe_great_circle_route.png"
        )
        expect_golden_file_match(
            evidence_output_dir("globe") .. "globe_latitude_longitude_grid.png",
            "tests/artifacts/baselines/globe/globe_latitude_longitude_grid.png"
        )
        expect_golden_file_match(
            evidence_output_dir("globe") .. "globe_political_regions.png",
            "tests/artifacts/baselines/globe/globe_political_regions.png"
        )
        expect_golden_file_match(
            evidence_output_dir("globe") .. "globe_province_projection.png",
            "tests/artifacts/baselines/globe/globe_province_projection.png"
        )
        expect_golden_file_match(
            evidence_output_dir("globe") .. "globe_temperature_heatmap.png",
            "tests/artifacts/baselines/globe/globe_temperature_heatmap.png"
        )
        expect_golden_file_match(
            evidence_output_dir("globe") .. "globe_topography_palette.png",
            "tests/artifacts/baselines/globe/globe_topography_palette.png"
        )
    end)
end)
test_summary()
