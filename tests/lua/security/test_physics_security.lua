-- Adversarial coverage for bounded physics construction, stepping, and numeric conversion.

local function world()
    return lurek.physics.newWorld(0, 0)
end

local function terrain_state_survives_corrupt_load()
    local terrain = lurek.physics.newTerrain(4, 4, 2, world())
    terrain:setCell(1, 1, true)
    local loaded = terrain:loadFromBytes("corrupt")
    return not loaded and terrain:getCell(1, 1)
end

local function liquid_state_survives_corrupt_load()
    local liquid = lurek.physics.newLiquidMap(4, 4, 2, world())
    liquid:setCell(1, 1, 0.75, "water")
    local loaded = liquid:loadFromBytes("corrupt")
    local amount, kind = liquid:getCell(1, 1)
    return not loaded and math.abs(amount - 0.75) < 0.001 and kind == "water"
end

-- @describe physics hostile inputs
describe("physics hostile inputs", function()
    -- @security LWorld:setMeter
    it("rejects invalid meter scales without changing conversion state", function()
        local w = world()
        w:setMeter(64)
        expect_error(function() w:setMeter(0) end)
        expect_error(function() w:setMeter(-1) end)
        expect_error(function() w:setMeter(math.huge) end)
        expect_equal(64, w:getMeter())
    end)

    -- @security LWorld:newBodies
    it("rejects invalid batch entries atomically", function()
        local w = world()
        expect_error(function()
            w:newBodies({
                { 0, 0, 4, 4, "dynamic" },
                { math.huge, 0, 4, 4, "dynamic" },
            })
        end)
        expect_equal(0, #w:getBodyIds())
    end)

    -- @security LWorld:stepFixed
    it("rejects unbounded or invalid fixed-step controls", function()
        local w = world()
        expect_error(function() w:stepFixed(1, 0, 1) end)
        expect_error(function() w:stepFixed(1, 1 / 60, 0) end)
        expect_error(function() w:stepFixed(1, 1 / 60, 1000000) end)
    end)

    -- @security LWorld:setSolverIterations
    it("rejects excessive solver and CCD controls", function()
        local w = world()
        expect_error(function() w:setSolverIterations(0) end)
        expect_error(function() w:setSolverIterations(1000000) end)
        expect_error(function() w:setCcdSubsteps(0) end)
        expect_error(function() w:setCcdSubsteps(1000000) end)
    end)

    -- @security LWorld:raycast
    it("rejects fractional and overflow filter body ids", function()
        local w = world()
        expect_error(function()
            w:raycast(0, 0, 10, 0, { excludeBody = 0.5 })
        end)
        expect_error(function()
            w:raycast(0, 0, 10, 0, { excludeBody = math.huge })
        end)
    end)

    -- @security LTerrain:loadFromBytes
    it("rejects corrupt terrain snapshots without replacing existing cells", function()
        expect_true(terrain_state_survives_corrupt_load())
    end)

    -- @security LLiquidMap:loadFromBytes
    it("rejects corrupt liquid snapshots without replacing existing cells", function()
        expect_true(liquid_state_survives_corrupt_load())
    end)
end)

test_summary()
