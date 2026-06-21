-- Golden test: particle compare deterministic evidence output against golden samples

-- @describe golden: particle evidence comparison
describe("golden: particle evidence comparison", function()
    it("matches stable particle baselines", function()
        expect_golden_file_match(
            evidence_output_dir("particle") .. "particle_attractor_contraction.png",
            "tests/artifacts/baselines/particle/particle_attractor_contraction.png"
        )
        expect_golden_file_match(
            evidence_output_dir("particle") .. "particle_burst_evolution.gif",
            "tests/artifacts/baselines/particle/particle_burst_evolution.gif"
        )
        expect_golden_file_match(
            evidence_output_dir("particle") .. "particle_emitter_burst.png",
            "tests/artifacts/baselines/particle/particle_emitter_burst.png"
        )
        expect_golden_file_match(
            evidence_output_dir("particle") .. "particle_emitter_cluster_snapshot.png",
            "tests/artifacts/baselines/particle/particle_emitter_cluster_snapshot.png"
        )
        expect_golden_file_match(
            evidence_output_dir("particle") .. "particle_trail_wave_ribbon.png",
            "tests/artifacts/baselines/particle/particle_trail_wave_ribbon.png"
        )
        expect_golden_file_match(
            evidence_output_dir("particle") .. "particle_explosion_renderer.png",
            "tests/artifacts/baselines/particle/particle_explosion_renderer.png"
        )
        expect_golden_file_match(
            evidence_output_dir("particle") .. "particle_rain_renderer.png",
            "tests/artifacts/baselines/particle/particle_rain_renderer.png"
        )
        expect_golden_file_match(
            evidence_output_dir("particle") .. "particle_spark_trail_renderer.png",
            "tests/artifacts/baselines/particle/particle_spark_trail_renderer.png"
        )
        expect_golden_file_match(
            evidence_output_dir("particle") .. "particle_over_paint_renderer.png",
            "tests/artifacts/baselines/particle/particle_over_paint_renderer.png"
        )
        expect_golden_file_match(
            evidence_output_dir("particle") .. "particle_lifecycle_chart.png",
            "tests/artifacts/baselines/particle/particle_lifecycle_chart.png"
        )
        expect_golden_file_match(
            evidence_output_dir("particle") .. "particle_runtime_population_lines.png",
            "tests/artifacts/baselines/particle/particle_runtime_population_lines.png"
        )
        expect_golden_file_match(
            evidence_output_dir("particle") .. "particle_runtime_summary_bars.png",
            "tests/artifacts/baselines/particle/particle_runtime_summary_bars.png"
        )
        expect_golden_file_match(
            evidence_output_dir("particle") .. "particle_histogram_live_population.png",
            "tests/artifacts/baselines/particle/particle_histogram_live_population.png"
        )
        expect_golden_file_match(
            evidence_output_dir("particle") .. "particle_heatmap_runtime_phase.png",
            "tests/artifacts/baselines/particle/particle_heatmap_runtime_phase.png"
        )
    end)
end)
test_summary()
