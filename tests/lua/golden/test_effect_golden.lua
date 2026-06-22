-- Canonical golden file for lurek.effect evidence comparisons.

-- @describe golden: effect evidence comparison
describe("golden: effect evidence comparison", function()
    it("matches effect evidence baselines", function()
        expect_golden_file_match(
            evidence_output_dir("effect") .. "effect_type_catalog.png",
            "tests/artifacts/baselines/effect/effect_type_catalog.png"
        )
        expect_golden_file_match(
            evidence_output_dir("effect") .. "effect_stack_pipeline.gif",
            "tests/artifacts/baselines/effect/effect_stack_pipeline.gif"
        )
        expect_golden_file_match(
            evidence_output_dir("effect") .. "effect_image_chain_parameters.png",
            "tests/artifacts/baselines/effect/effect_image_chain_parameters.png"
        )
        expect_golden_file_match(
            evidence_output_dir("effect") .. "effect_parameter_response_curves.png",
            "tests/artifacts/baselines/effect/effect_parameter_response_curves.png"
        )
        expect_golden_file_match(
            evidence_output_dir("effect") .. "effect_preset_stack_contact_sheet.png",
            "tests/artifacts/baselines/effect/effect_preset_stack_contact_sheet.png"
        )
        expect_golden_file_match(
            evidence_output_dir("effect") .. "effect_enable_dedup_matrix.png",
            "tests/artifacts/baselines/effect/effect_enable_dedup_matrix.png"
        )
        expect_golden_file_match(
            evidence_output_dir("effect") .. "effect_custom_shader_pass_map.png",
            "tests/artifacts/baselines/effect/effect_custom_shader_pass_map.png"
        )
        expect_golden_file_match(
            evidence_output_dir("effect") .. "effect_stack_order_lookbook.gif",
            "tests/artifacts/baselines/effect/effect_stack_order_lookbook.gif"
        )
        expect_golden_text_match(
            evidence_output_dir("effect") .. "effect_stack_state.json",
            "tests/artifacts/baselines/effect/effect_stack_state.json"
        )
        expect_golden_text_match(
            evidence_output_dir("effect") .. "effect_capture_preset_state.json",
            "tests/artifacts/baselines/effect/effect_capture_preset_state.json"
        )
        expect_golden_text_match(
            evidence_output_dir("effect") .. "effect_image_chain_state.json",
            "tests/artifacts/baselines/effect/effect_image_chain_state.json"
        )
    end)
end)

test_summary()
