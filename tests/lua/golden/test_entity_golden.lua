-- Golden test: entity â€” deterministic text output comparison
-- @golden
-- @covers lurek.entity.newUniverse
-- @covers Universe:spawn
-- @covers Universe:setPosition

-- @description Covers suite: golden: entity Entity creation and component state.
describe("golden: entity Entity creation and component state", function()
    -- @covers lurek.entity.newUniverse
    -- @covers Universe:spawn
    -- @covers Universe:setPosition
    -- @covers Universe:getPosition
    -- @covers Universe:isAlive
    -- @covers expect_evidence_created
    -- @description Writes entity_golden.txt with the spawned entity position and alive-state text, then checks that the evidence file was created.
    it("produces deterministic text output", function()

        local output = {}
        local universe = lurek.entity.newUniverse()
        local e = universe:spawn()
        universe:setPosition(e, 100, 200)
        local x, y = universe:getPosition(e)
        output[#output + 1] = string.format("pos=%.6f,%.6f", x, y)
        output[#output + 1] = "alive=" .. tostring(universe:isAlive(e))
        local text = table.concat(output, "\n") .. "\n"

        local path = evidence_output_dir("entity") .. "entity_golden.txt"
        ensure_evidence_dir("entity")
        local f = io.open(path, "w")
        if f then f:write(text); f:close() end
        expect_evidence_created(path)
    end)

    -- @golden
    -- @covers expect_golden_text_match
    -- @description Compares the generated entity_golden.txt evidence file against the committed golden text sample.
    it("matches golden sample", function()
        local evidence = evidence_output_dir("entity") .. "entity_golden.txt"
        local golden = "tests/lua/golden/samples/entity/entity_golden.txt"
        expect_golden_text_match(evidence, golden)
    end)
end)

test_summary()
