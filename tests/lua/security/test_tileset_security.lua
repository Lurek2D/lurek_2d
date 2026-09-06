-- Adversarial coverage for bounded tileset construction and nested metadata validation.

local function provider(extra)
    local value = {
        tileCount = 4,
        columns = 2,
        tileWidth = 16,
        tileHeight = 16,
    }
    for key, entry in pairs(extra or {}) do
        value[key] = entry
    end
    return value
end

-- @describe tileset hostile inputs
describe("tileset hostile inputs", function()
    -- @security lurek.tileset.newTileSet
    it("rejects zero dimensions and overflowing gid ranges", function()
        expect_error(function() lurek.tileset.newTileSet(1, 0, 1, 16, 16) end)
        expect_error(function() lurek.tileset.newTileSet(1, 4, 0, 16, 16) end)
        expect_error(function() lurek.tileset.newTileSet(1, 4, 2, 0, 16) end)
        expect_error(function() lurek.tileset.newTileSet(4294967295, 2, 1, 16, 16) end)
    end)

    -- @security lurek.tileset.fromProvider
    it("rejects malformed providers before publishing a tileset", function()
        expect_error(function() lurek.tileset.fromProvider(provider({ tileHeight = 0 })) end)
        expect_error(function()
            lurek.tileset.fromProvider(provider({
                animations = { [1] = { { tileid = 5, duration = 10 } } },
            }))
        end)
        expect_error(function()
            lurek.tileset.fromProvider(provider({
                objects = { lamp = { light = { radius = 0 / 0 } } },
            }))
        end)
        local oversized = {}
        for index = 1, 257 do
            oversized[index] = "value"
        end
        expect_error(function()
            lurek.tileset.fromProvider(provider({
                properties = { [1] = oversized },
            }))
        end)
    end)
    local function __audit_security_5()
        local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
        expect_error(function() tileset:getQuad(0) end)
        expect_error(function() tileset:getQuad(5) end)
    end


    -- @security LTileSet:getQuad
    it("errors for zero and out-of-range local ids", function()
        __audit_security_5()
    end)
    local function __audit_security_4()
        local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
        expect_error(function() tileset:setAnimation(1, { { tileid = 1, duration = 0 / 0 } }) end)
        expect_error(function() tileset:setAnimation(1, { { tileid = 5, duration = 10 } }) end)
        expect_error(function() tileset:setAnimation(5, { { tileid = 1, duration = 10 } }) end)
    end


    -- @security LTileSet:setAnimation
    it("rejects non-finite durations and invalid frame ids", function()
        __audit_security_4()
    end)
    local function __audit_security_3()
        local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
        expect_error(function() tileset:setProperty(5, "bad", "value") end)
        expect_error(function() tileset:setProperty(1, string.rep("x", 300), "value") end)
        expect_error(function() tileset:setProperty(1, "bad", string.rep("x", 5000)) end)
    end


    -- @security LTileSet:setProperty
    it("rejects invalid tile ids and oversized strings", function()
        __audit_security_3()
    end)
    local function __audit_security_2()
        local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
        expect_error(function() tileset:setAutoTileRule("", 0, 1) end)
        expect_error(function() tileset:setAutoTileRule("wall", 0, 5) end)
        expect_error(function() tileset:setAutoTileRule8("wall", 0, 5) end)
    end


    -- @security LTileSet:setAutoTileRule
    it("rejects invalid four- and eight-way rule ids and names", function()
        __audit_security_2()
    end)
    local function __audit_security_1()
        local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
        expect_error(function()
            tileset:setTerrainProfile("ground", { terrainSet = "terrain", defaultTileId = 5 })
        end)
        expect_error(function() tileset:setObject("lamp", { light = { radius = 0 / 0 } }) end)
        expect_error(function() tileset:setObject("body", { physics = { restitution = 2 } }) end)
    end


    -- @security LTileSet:setTerrainProfile
    it("rejects invalid default terrain tile ids and numeric archetype fields", function()
        __audit_security_1()
    end)
end)

test_summary()
