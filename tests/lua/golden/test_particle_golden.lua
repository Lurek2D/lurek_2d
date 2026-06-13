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
            evidence_output_dir("particle") .. "particle_lifecycle_chart.png",
            "tests/artifacts/baselines/particle/particle_lifecycle_chart.png"
        )
    end)
end)
test_summary()
