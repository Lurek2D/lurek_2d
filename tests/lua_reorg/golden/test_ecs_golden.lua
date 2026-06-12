-- Canonical golden file for lurek.ecs evidence comparisons.

-- @describe golden: ecs evidence comparison
describe("golden: ecs evidence comparison", function()
    it("matches ecs_entity_lifecycle_snapshot.txt", function()
        expect_golden_text_match(
            evidence_output_dir("ecs") .. "ecs_entity_lifecycle_snapshot.txt",
            "tests/artifacts/baselines/ecs/ecs_entity_lifecycle_snapshot.txt"
        )
    end)
end)
test_summary()
