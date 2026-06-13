-- Canonical golden file for lurek.binary evidence comparisons.

-- @describe golden: binary evidence comparison
describe("golden: binary evidence comparison", function()
    it("matches binary_toml_roundtrip_snapshot.toml", function()
        expect_golden_text_match(
            evidence_output_dir("binary") .. "binary_toml_roundtrip_snapshot.toml",
            "tests/artifacts/baselines/binary/binary_toml_roundtrip_snapshot.toml"
        )
    end)

    it("matches binary_encode_reference_values.txt", function()
        expect_golden_text_match(
            evidence_output_dir("binary") .. "binary_encode_reference_values.txt",
            "tests/artifacts/baselines/binary/binary_encode_reference_values.txt"
        )
    end)

    it("matches binary_hash_reference_values.txt", function()
        expect_golden_text_match(
            evidence_output_dir("binary") .. "binary_hash_reference_values.txt",
            "tests/artifacts/baselines/binary/binary_hash_reference_values.txt"
        )
    end)
end)
test_summary()
