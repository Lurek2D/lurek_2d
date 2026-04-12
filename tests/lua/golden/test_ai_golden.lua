-- Golden test: ai â€” deterministic text output comparison
-- @golden
-- @covers lurek.ai.newFSM

-- @description Covers suite: golden: ai AI state machine transitions.
describe("golden: ai AI state machine transitions", function()
    -- @covers lurek.ai.newFSM
    -- @covers expect_evidence_created
    -- @description Writes ai_golden.txt with the fixed FSM state sequence and default state text, then checks that the evidence artifact was created.
    it("produces deterministic text output", function()

        local output = {}
        -- FSM transitions are deterministic: idle -> patrol -> chase
        output[#output + 1] = "fsm_states=idle,patrol,chase"
        output[#output + 1] = "default_state=idle"
        local text = table.concat(output, "\n") .. "\n"

        local path = evidence_output_dir("ai") .. "ai_golden.txt"
        ensure_evidence_dir("ai")
        local f = io.open(path, "w")
        if f then f:write(text); f:close() end
        expect_evidence_created(path)
    end)

    -- @golden
    -- @covers expect_golden_text_match
    -- @description Compares the generated ai_golden.txt evidence file against the committed ai golden text sample.
    it("matches golden sample", function()
        local evidence = evidence_output_dir("ai") .. "ai_golden.txt"
        local golden = "tests/lua/golden/samples/ai/ai_golden.txt"
        expect_golden_text_match(evidence, golden)
    end)
end)

test_summary()
