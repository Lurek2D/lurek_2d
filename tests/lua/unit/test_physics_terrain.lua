-- Lurek2D Physics Terrain API Tests
-- Tests for lurek.physics.newTerrain, LuaTerrain cell access, fill, and metadata.

-- @description Covers suite: lurek.physics terrain factory.
describe("lurek.physics terrain factory", function()
    -- @covers lurek.physics.newTerrain
    -- @description Verifies newTerrain is exposed as a callable factory.
    it("newTerrain is a function", function()
        expect_type("function", lurek.physics.newTerrain)
    end)

    -- @covers lurek.physics.newTerrain
    -- @description Verifies newTerrain returns userdata.
    it("newTerrain returns userdata", function()
        local world = lurek.physics.newWorld(0, 0)
        local terrain = lurek.physics.newTerrain(32, 32, 8, world)
        expect_type("userdata", terrain)
    end)
end)

-- @description Covers suite: lurek.physics terrain cell access.
describe("lurek.physics terrain cell access", function()
    local world, terrain

    before_each(function()
        world = lurek.physics.newWorld(0, 0)
        terrain = lurek.physics.newTerrain(16, 16, 8, world)
    end)

    -- @covers LuaTerrain:getCell
    -- @description Verifies all cells start as non-solid.
    it("all cells start empty", function()
        expect_false(terrain:getCell(0, 0))
        expect_false(terrain:getCell(7, 7))
        expect_false(terrain:getCell(15, 15))
    end)

    -- @covers LuaTerrain:setCell
    -- @covers LuaTerrain:getCell
    -- @description Verifies setCell(solid=true) makes a cell solid.
    it("setCell true makes cell solid", function()
        terrain:setCell(3, 3, true)
        expect_true(terrain:getCell(3, 3))
    end)

    -- @covers LuaTerrain:setCell
    -- @covers LuaTerrain:getCell
    -- @description Verifies setCell(solid=false) removes solid state.
    it("setCell false clears a solid cell", function()
        terrain:setCell(5, 5, true)
        terrain:setCell(5, 5, false)
        expect_false(terrain:getCell(5, 5))
    end)

    -- @covers LuaTerrain:setCell
    -- @covers LuaTerrain:isDirty
    -- @description Verifies isDirty returns true after setCell changes a value.
    it("isDirty is true after setCell", function()
        expect_false(terrain:isDirty())
        terrain:setCell(0, 0, true)
        expect_true(terrain:isDirty())
    end)
end)

-- @description Covers suite: lurek.physics terrain bulk fill.
describe("lurek.physics terrain bulk fill", function()
    local world, terrain

    before_each(function()
        world = lurek.physics.newWorld(0, 0)
        terrain = lurek.physics.newTerrain(32, 32, 8, world)
    end)

    -- @covers LuaTerrain:fillAll
    -- @covers LuaTerrain:getCell
    -- @description Verifies fillAll(true) makes every cell solid.
    it("fillAll true marks all cells solid", function()
        terrain:fillAll(true)
        expect_true(terrain:getCell(0, 0))
        expect_true(terrain:getCell(15, 15))
        expect_true(terrain:getCell(31, 31))
    end)

    -- @covers LuaTerrain:fillAll
    -- @covers LuaTerrain:getCell
    -- @description Verifies fillAll(false) clears every cell.
    it("fillAll false clears all cells", function()
        terrain:fillAll(true)
        terrain:fillAll(false)
        expect_false(terrain:getCell(0, 0))
        expect_false(terrain:getCell(15, 15))
    end)

    -- @covers LuaTerrain:fillRect
    -- @covers LuaTerrain:getCell
    -- @description Verifies fillRect marks cells inside the bounds.
    it("fillRect marks affected cells solid", function()
        -- fill a 5×5 block at cell (0,0), world coords 0,0 / 40,40 (8px cells)
        terrain:fillRect(0, 0, 40, 40, true)
        expect_true(terrain:getCell(2, 2))
    end)

    -- @covers LuaTerrain:fillCircle
    -- @covers LuaTerrain:getCell
    -- @description Verifies fillCircle marks centre cell solid.
    it("fillCircle marks centre cell solid", function()
        -- centre at world (64,64), radius 16 → hits cell (8,8)
        terrain:fillCircle(64, 64, 16, true)
        expect_true(terrain:getCell(8, 8))
    end)
end)

-- @description Covers suite: lurek.physics terrain flush.
describe("lurek.physics terrain flush", function()
    -- @covers LuaTerrain:flush
    -- @covers LuaTerrain:isDirty
    -- @description Verifies flush clears the dirty flag.
    it("flush clears isDirty", function()
        local world = lurek.physics.newWorld(0, 0)
        local terrain = lurek.physics.newTerrain(16, 16, 8, world)
        terrain:setCell(0, 0, true)
        expect_true(terrain:isDirty())
        terrain:flush()
        expect_false(terrain:isDirty())
    end)
end)

-- @description Covers suite: lurek.physics terrain serialisation.
describe("lurek.physics terrain serialisation", function()
    -- @covers LuaTerrain:toBytes
    -- @covers LuaTerrain:loadFromBytes
    -- @description Verifies round-trip serialisation preserves cell state.
    it("toBytes/loadFromBytes round-trip preserves cells", function()
        local world = lurek.physics.newWorld(0, 0)
        local t1 = lurek.physics.newTerrain(16, 16, 8, world)
        t1:setCell(7, 5, true)
        t1:setCell(2, 10, true)

        local bytes = t1:toBytes()
        expect_type("string", bytes)

        local t2 = lurek.physics.newTerrain(16, 16, 8, world)
        local ok = t2:loadFromBytes(bytes)
        expect_true(ok)
        expect_true(t2:getCell(7, 5))
        expect_true(t2:getCell(2, 10))
        expect_false(t2:getCell(0, 0))
    end)
end)

test_summary()
