-- Lurek2D Lua BDD tests — lurek.animation blend layer system
-- Covers: newBlendLayerSet, addLayer, removeLayer, setWeight, getWeight, setMask, listLayers, len.
-- Headless: no GPU, no audio, no window.

-- @description Covers suite: lurek.animation blend layers.
describe("lurek.animation blend layers", function()
    -- @description Covers suite: factory.
    describe("factory", function()
        -- @covers lurek.animation.newBlendLayerSet
        -- @description Verifies newBlendLayerSet is exposed on the module.
        it("exposes newBlendLayerSet", function()
            expect_type("function", lurek.animation.newBlendLayerSet)
        end)

        -- @covers lurek.animation.newBlendLayerSet
        -- @description Factory returns a userdata.
        it("returns a userdata", function()
            local bls = lurek.animation.newBlendLayerSet()
            expect_type("userdata", bls)
        end)
    end)

    -- @description Covers suite: len() and addLayer().
    describe("len() / addLayer()", function()
        -- @covers lurek.animation:len
        -- @description Empty set has length zero.
        it("starts empty", function()
            local bls = lurek.animation.newBlendLayerSet()
            expect_equal(0, bls:len())
        end)

        -- @covers lurek.animation:addLayer
        -- @description Adding a layer increments length.
        it("addLayer increments len", function()
            local bls = lurek.animation.newBlendLayerSet()
            bls:addLayer("upper", "attack", 1.0)
            expect_equal(1, bls:len())
        end)

        -- @covers lurek.animation:addLayer
        -- @description Two distinct layers can be added.
        it("accepts two distinct layers", function()
            local bls = lurek.animation.newBlendLayerSet()
            bls:addLayer("upper", "attack", 1.0)
            bls:addLayer("lower", "walk",   1.0)
            expect_equal(2, bls:len())
        end)

        -- @covers lurek.animation:addLayer
        -- @description Layer with bone mask list does not error.
        it("accepts bone mask as fourth argument", function()
            local bls = lurek.animation.newBlendLayerSet()
            bls:addLayer("upper", "attack", 0.8, {"spine", "shoulder_L", "shoulder_R"})
            expect_equal(1, bls:len())
        end)
    end)

    -- @description Covers suite: weight accessors.
    describe("setWeight() / getWeight()", function()
        -- @covers lurek.animation:getWeight
        -- @description getWeight returns the initial weight.
        it("getWeight returns initial weight", function()
            local bls = lurek.animation.newBlendLayerSet()
            bls:addLayer("upper", "attack", 0.75)
            local w = bls:getWeight("upper")
            expect_near(0.75, w, 0.001)
        end)

        -- @covers lurek.animation:setWeight
        -- @description setWeight updates the weight.
        it("setWeight updates the weight", function()
            local bls = lurek.animation.newBlendLayerSet()
            bls:addLayer("lower", "walk", 1.0)
            bls:setWeight("lower", 0.5)
            local w = bls:getWeight("lower")
            expect_near(0.5, w, 0.001)
        end)
    end)

    -- @description Covers suite: listLayers().
    describe("listLayers()", function()
        -- @covers lurek.animation:listLayers
        -- @description listLayers returns a table of layer names.
        it("returns a table", function()
            local bls = lurek.animation.newBlendLayerSet()
            bls:addLayer("upper", "attack", 1.0)
            local names = bls:listLayers()
            expect_type("table", names)
        end)

        -- @covers lurek.animation:listLayers
        -- @description The table length matches the layer count.
        it("table length equals layer count", function()
            local bls = lurek.animation.newBlendLayerSet()
            bls:addLayer("upper", "attack", 1.0)
            bls:addLayer("lower", "walk",   1.0)
            local names = bls:listLayers()
            expect_equal(2, #names)
        end)
    end)

    -- @description Covers suite: removeLayer().
    describe("removeLayer()", function()
        -- @covers lurek.animation:removeLayer
        -- @description Removing a layer decrements length.
        it("decrements len after removal", function()
            local bls = lurek.animation.newBlendLayerSet()
            bls:addLayer("upper", "attack", 1.0)
            bls:addLayer("lower", "walk",   1.0)
            bls:removeLayer("upper")
            expect_equal(1, bls:len())
        end)

        -- @covers lurek.animation:removeLayer
        -- @description Removing a non-existent layer does not error.
        it("removing unknown layer does not error", function()
            local bls = lurek.animation.newBlendLayerSet()
            bls:removeLayer("nonexistent")
            expect_equal(0, bls:len())
        end)
    end)

    -- @description Covers suite: setMask().
    describe("setMask()", function()
        -- @covers lurek.animation:setMask
        -- @description setMask on an existing layer does not error.
        it("accepts a bone list without error", function()
            local bls = lurek.animation.newBlendLayerSet()
            bls:addLayer("upper", "attack", 1.0)
            bls:setMask("upper", {"spine", "head"})
            expect_equal(1, bls:len())
        end)
    end)
end)

test_summary()
