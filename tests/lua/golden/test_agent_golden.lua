-- Canonical golden file for lurek.agent evidence comparisons.

-- @describe golden: agent evidence comparison
describe("golden: agent evidence comparison", function()
    it("matches agent evidence baselines", function()
        expect_golden_text_match(
            evidence_output_dir("agent") .. "agent_context_memory_report.txt",
            "tests/artifacts/baselines/agent/agent_context_memory_report.txt"
        )
        expect_golden_text_match(
            evidence_output_dir("agent") .. "agent_memory_bundle.json",
            "tests/artifacts/baselines/agent/agent_memory_bundle.json"
        )
    end)
end)
test_summary()
