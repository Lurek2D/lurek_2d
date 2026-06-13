-- Golden test: html compare evidence output against golden samples

-- @describe golden: html evidence comparison
describe("golden: html evidence comparison", function()
    it("matches html baselines", function()
        expect_golden_text_match(
            evidence_output_dir("html") .. "html_click_event_trace.txt",
            "tests/artifacts/baselines/html/html_click_event_trace.txt"
        )
        expect_golden_text_match(
            evidence_output_dir("html") .. "html_document_markup_snapshot.txt",
            "tests/artifacts/baselines/html/html_document_markup_snapshot.txt"
        )
        expect_golden_text_match(
            evidence_output_dir("html") .. "html_element_state.json",
            "tests/artifacts/baselines/html/html_element_state.json"
        )
        expect_golden_text_match(
            evidence_output_dir("html") .. "html_mutation_snapshot.txt",
            "tests/artifacts/baselines/html/html_mutation_snapshot.txt"
        )
        expect_golden_text_match(
            evidence_output_dir("html") .. "html_query_viewport_snapshot.json",
            "tests/artifacts/baselines/html/html_query_viewport_snapshot.json"
        )
    end)
end)
test_summary()
