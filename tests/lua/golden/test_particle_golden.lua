-- Golden test: particle compare deterministic evidence output against golden samples

-- @describe golden: particle evidence comparison
describe("golden: particle evidence comparison", function()
    it("matches stable particle baselines", function()
        expect_golden_file_match(
            evidence_output_dir("particle") .. "particle_archetype_showcase.png",
            "tests/artifacts/baselines/particle/particle_archetype_showcase.png"
        )
        expect_golden_file_match(
            evidence_output_dir("particle") .. "particle_velocity_burst.gif",
            "tests/artifacts/baselines/particle/particle_velocity_burst.gif"
        )
        expect_golden_file_match(
            evidence_output_dir("particle") .. "particle_attractor_field.gif",
            "tests/artifacts/baselines/particle/particle_attractor_field.gif"
        )
        expect_golden_file_match(
            evidence_output_dir("particle") .. "particle_trail_ribbon_decay.gif",
            "tests/artifacts/baselines/particle/particle_trail_ribbon_decay.gif"
        )
        expect_golden_file_match(
            evidence_output_dir("particle") .. "particle_paint_composite.png",
            "tests/artifacts/baselines/particle/particle_paint_composite.png"
        )
        expect_golden_file_match(
            evidence_output_dir("particle") .. "particle_lifecycle_chart.png",
            "tests/artifacts/baselines/particle/particle_lifecycle_chart.png"
        )
        expect_golden_file_match(
            evidence_output_dir("particle") .. "particle_emission_area_shapes.png",
            "tests/artifacts/baselines/particle/particle_emission_area_shapes.png"
        )
        expect_golden_file_match(
            evidence_output_dir("particle") .. "particle_bounds_bounce_box.gif",
            "tests/artifacts/baselines/particle/particle_bounds_bounce_box.gif"
        )
        expect_golden_file_match(
            evidence_output_dir("particle") .. "particle_subemitter_death_burst.gif",
            "tests/artifacts/baselines/particle/particle_subemitter_death_burst.gif"
        )
        expect_golden_file_match(
            evidence_output_dir("particle") .. "particle_shape_size_keyframes.png",
            "tests/artifacts/baselines/particle/particle_shape_size_keyframes.png"
        )
        expect_golden_file_match(
            evidence_output_dir("particle") .. "particle_control_state_timeline.gif",
            "tests/artifacts/baselines/particle/particle_control_state_timeline.gif"
        )
    end)
end)

test_summary()
