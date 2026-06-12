-- Canonical evidence file for lurek.ecs data outputs.

local OUT = evidence_output_dir("ecs")

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

-- @describe Evidence: lurek.ecs data outputs
describe("Evidence: lurek.ecs data outputs", function()
    before_each(function()
        ensure_evidence_dir("ecs")
    end)

    -- @evidence lurek.ecs.newUniverse
    it("writes ecs_entity_lifecycle_snapshot.txt", function()
        local world = lurek.ecs.newUniverse()
        local entity = world:spawn()
        local text = table.concat({
            "entity_id=" .. tostring(entity),
            "alive=" .. tostring(world:isAlive(entity)),
            "entity_count=" .. tostring(world:getEntityCount()),
        }, "\n")
        write_text(OUT .. "ecs_entity_lifecycle_snapshot.txt", text)
    end)
end)
test_summary()
