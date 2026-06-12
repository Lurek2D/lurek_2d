-- Canonical golden file for lurek.ai evidence comparisons.

-- @describe golden: ai evidence comparison
describe("golden: ai evidence comparison", function()
    it("matches ai_state_machine_transitions.txt", function()
        expect_golden_text_match(
            evidence_output_dir("ai") .. "ai_state_machine_transitions.txt",
            "tests/artifacts/baselines/ai/ai_state_machine_transitions.txt"
        )
    end)
end)
test_summary()
