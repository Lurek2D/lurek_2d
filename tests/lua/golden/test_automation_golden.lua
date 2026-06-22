-- Canonical golden file for lurek.automation evidence comparisons.

-- @describe golden: automation evidence comparison
describe("golden: automation evidence comparison", function()
    it("matches automation evidence baselines", function()
        expect_golden_text_match(
            evidence_output_dir("automation") .. "automation_condition_gate_trace.txt",
            "tests/artifacts/baselines/automation/automation_condition_gate_trace.txt"
        )
        expect_golden_text_match(
            evidence_output_dir("automation") .. "automation_macro_control_trace.txt",
            "tests/artifacts/baselines/automation/automation_macro_control_trace.txt"
        )
        expect_golden_text_match(
            evidence_output_dir("automation") .. "automation_timeline_trace.txt",
            "tests/artifacts/baselines/automation/automation_timeline_trace.txt"
        )
    end)
end)
test_summary()
