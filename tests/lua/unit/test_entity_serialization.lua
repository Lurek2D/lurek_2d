-- Lurek2D Lua BDD tests for lurek.entity serialize/deserialize
-- Headless: no GPU, no audio, no window.

-- @description Covers suite: lurek.entity.serialize and deserialize.
describe("lurek.entity", function()
    -- @description Covers suite: entity world serialization.
    describe("serialize and deserialize", function()
        -- @covers lurek.entity.newUniverse
        -- @covers lurek.entity.serialize
        -- @covers lurek.entity.deserialize
        -- @description Verifies that serialize produces a snapshot table with entities and bitmap_tags keys.
        it("serialize returns a table with entities and bitmap_tags", function()
            local w = lurek.entity.newUniverse()
            local e = w:spawn()
            w:set(e, "name", "hero")
            local snap = w:serialize()
            expect_equal("table", type(snap))
            expect_equal("table", type(snap.entities))
            expect_equal("table", type(snap.bitmap_tags))
        end)

        -- @covers lurek.entity.serialize
        -- @description Verifies that serialized entity count matches spawn count.
        it("serialized entity count matches world entity count", function()
            local w = lurek.entity.newUniverse()
            w:spawn() w:spawn() w:spawn()
            local snap = w:serialize()
            expect_equal(3, #snap.entities)
        end)

        -- @covers lurek.entity.deserialize
        -- @description Verifies that deserialize restores component values.
        it("deserialize restores component values", function()
            local w = lurek.entity.newUniverse()
            local e1 = w:spawn()
            w:set(e1, "hp", 42)
            local snap = w:serialize()
            -- Clear and restore
            w:clear()
            w:deserialize(snap)
            expect_equal(1, w:getEntityCount())
            local ids = w:getEntities()
            local hp = w:get(ids[1], "hp")
            expect_equal(42, hp)
        end)

        -- @covers lurek.entity.deserialize
        -- @description Verifies that deserialize restores string tags.
        it("deserialize restores string tags", function()
            local w = lurek.entity.newUniverse()
            local e = w:spawn()
            w:addTag(e, "enemy")
            w:addTag(e, "active")
            local snap = w:serialize()
            w:clear()
            w:deserialize(snap)
            local enemies = w:getEntitiesByTag("enemy")
            expect_equal(1, #enemies)
        end)

        -- @covers lurek.entity.deserialize
        -- @description Verifies that deserialize preserves blueprints (does not delete them).
        it("deserialize preserves registered blueprints", function()
            local w = lurek.entity.newUniverse()
            w:defineBlueprint("Enemy", {hp = 10, speed = 5})
            local snap = w:serialize()
            w:clear()
            w:deserialize(snap)
            expect_equal(true, w:hasBlueprint("Enemy"))
        end)
    end)
end)
test_summary()
