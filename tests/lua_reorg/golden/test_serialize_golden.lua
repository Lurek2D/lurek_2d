-- Golden test: serial compare-only evidence validation.

-- @describe golden: serial Encode/decode deterministic output
describe("golden: serial Encode/decode deterministic output", function()
    it("matches binary_encode_reference_values.txt", function()
        expect_golden_text_match(
            evidence_output_dir("binary") .. "binary_encode_reference_values.txt",
            "tests/artifacts/baselines/binary/binary_encode_reference_values.txt"
        )
    end)
end)
test_summary()
