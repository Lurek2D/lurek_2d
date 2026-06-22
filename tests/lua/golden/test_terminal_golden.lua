-- Canonical golden file for lurek.terminal visual evidence comparisons.

-- @describe golden: terminal evidence comparison
describe("golden: terminal evidence comparison", function()
    it("matches terminal evidence baselines", function()
        expect_golden_file_match(
            evidence_output_dir("terminal") .. "terminal_tui_dashboard_widgets.png",
            "tests/artifacts/baselines/terminal/terminal_tui_dashboard_widgets.png"
        )
        expect_golden_file_match(
            evidence_output_dir("terminal") .. "terminal_tui_form_focus.png",
            "tests/artifacts/baselines/terminal/terminal_tui_form_focus.png"
        )
        expect_golden_file_match(
            evidence_output_dir("terminal") .. "terminal_tui_chart_panels.png",
            "tests/artifacts/baselines/terminal/terminal_tui_chart_panels.png"
        )
        expect_golden_file_match(
            evidence_output_dir("terminal") .. "terminal_tui_diagnostics_panels.png",
            "tests/artifacts/baselines/terminal/terminal_tui_diagnostics_panels.png"
        )
        expect_golden_file_match(
            evidence_output_dir("terminal") .. "terminal_tui_command_palette.png",
            "tests/artifacts/baselines/terminal/terminal_tui_command_palette.png"
        )
    end)
end)
test_summary()
