-- Evidence test: physics zone event tracking
-- Produces: zone_events.txt proving that zone enter/leave events are emitted.
-- If this module's code was deleted, the output file would contain no events.

-- @description Covers suite: evidence: physics zone event tracking.
describe("evidence: physics zone event tracking", function()
    -- @covers lurek.physics.newWorld
    -- @covers World:addZone
    -- @covers LuaZone:setGravityZero
    -- @covers World:step
    -- @covers World:getZoneEvents
    -- @evidence file
    -- @description Creates a world with a zero-g zone, drops a body into it,
    --              steps the simulation, and writes all zone events to a text
    --              file that proves the event system works.
    it("zone events are recorded and written to evidence file", function()
        ensure_evidence_dir("physics")
        local path = evidence_output_dir("physics") .. "zone_events.txt"

        local world = lurek.physics.newWorld(0, 0)  -- no gravity
        local zone = world:addZone(-500, -500, 1000, 1000)
        zone:setGravityZero()

        -- Add a body inside the zone.
        world:newBody(0, 0, 10, 10, "dynamic")

        -- Step to trigger enter events.
        world:step(1/60)
        local events = world:getZoneEvents()

        -- Write evidence.
        local lines = {}
        table.insert(lines, string.format("steps: 1  event_count: %d", #events))
        for i, ev in ipairs(events) do
            table.insert(lines, string.format(
                "event[%d]: zone_id=%d  body_id=%d  kind=%s",
                i, ev.zone_id, ev.body_id, ev.kind
            ))
        end

        -- Step more and collect leave events (destroy zone).
        zone:destroy()
        world:step(1/60)
        local events2 = world:getZoneEvents()
        table.insert(lines, string.format("after_destroy_event_count: %d", #events2))

        -- Write to evidence file.
        local content = table.concat(lines, "\n") .. "\n"
        local f = io.open(path, "w")
        expect_true(f ~= nil, "could not open evidence file for writing")
        f:write(content)
        f:close()

        -- Verify at least one enter event was produced.
        expect_true(#events >= 1, "expected at least one zone enter event")
        expect_evidence_created(path)
    end)
end)

test_summary()
