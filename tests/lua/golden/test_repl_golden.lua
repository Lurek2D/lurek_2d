-- Canonical golden file for lurek.repl visual evidence comparisons.

-- @describe golden: repl evidence comparison
describe("golden: repl evidence comparison", function()
    it("matches repl evidence baselines", function()
        expect_golden_file_match(
            evidence_output_dir("repl") .. "repl_eval_session_ui.png",
            "tests/artifacts/baselines/repl/repl_eval_session_ui.png"
        )
        expect_golden_file_match(
            evidence_output_dir("repl") .. "repl_commands_ui.png",
            "tests/artifacts/baselines/repl/repl_commands_ui.png"
        )
        expect_golden_file_match(
            evidence_output_dir("repl") .. "repl_completion_ui.png",
            "tests/artifacts/baselines/repl/repl_completion_ui.png"
        )
        expect_golden_file_match(
            evidence_output_dir("repl") .. "repl_history_ui.png",
            "tests/artifacts/baselines/repl/repl_history_ui.png"
        )
        expect_golden_file_match(
            evidence_output_dir("repl") .. "repl_error_recovery_ui.png",
            "tests/artifacts/baselines/repl/repl_error_recovery_ui.png"
        )
    end)
end)
test_summary()
