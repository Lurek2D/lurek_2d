-- Integration: save manager tracking entity state and TOML config blueprints
-- @describe integration: save entity world state

-- @describe integration: save entity world state
describe("integration: save entity world state", function()

    -- @integration LSaveManager:isDirty
    -- @integration LSaveManager:markDirty
    -- @integration LSaveManager:register
    -- @integration LUniverse:set
    -- @integration LUniverse:spawn
    -- @integration lurek.ecs.newUniverse
    -- @integration lurek.save.newSaveManager
    -- @integration lurek.serialize.fromToml
    -- @integration lurek.ecs.newUniverse
    -- @integration lurek.save.newSaveManager
    it("save manager tracks entity dirty state", function()
        local mgr = lurek.save.newSaveManager()
        local universe = lurek.ecs.newUniverse()

        mgr:register("entities", function() return {} end, function(_data) end)
        expect_false(mgr:isDirty(), "initially clean")

        -- Modify entities
        local id = universe:spawn()
        universe:set(id, "modified", true)
        mgr:markDirty()

        expect_true(mgr:isDirty(), "dirty after entity modification")
    end)
end)


-- @describe integration: TOML config for entities
describe("integration: TOML config for entities", function()
    -- @integration LUniverse:get
    -- @integration LUniverse:getEntityCount
    -- @integration LUniverse:set
    -- @integration LUniverse:spawn
    -- @integration lurek.serialize.fromToml
    -- @integration lurek.ecs.newUniverse
    it("entity blueprints from TOML", function()
        local toml_str = [[
            [player]
            health = 100
            speed = 5.0
            name = "Hero"

            [goblin]
            health = 30
            speed = 3.0
            name = "Goblin"

            [dragon]
            health = 500
            speed = 2.0
            name = "Dragon"
        ]]

        local config = lurek.serialize.fromToml(toml_str)

        local universe = lurek.ecs.newUniverse()

        -- Create entities from TOML config
        local entities = {}
        for entity_type, props in pairs(config --[[@as table]]) do
            local id = universe:spawn()
            if type(props) == "table" then
                for key, value in pairs(props) do
                    universe:set(id, key, value)
                end
                universe:set(id, "type", entity_type)
                entities[entity_type] = id
            end
        end

        -- Verify entities created from config
        expect_true(universe:getEntityCount() >= 3, "at least 3 entities from TOML")

        -- Check one entity
        if entities["player"] then
            local name = universe:get(entities["player"], "name")
            expect_equal("Hero", name, "player name from TOML")
        end
    end)
end)

-- @describe integration: save payload codec boundaries
describe("integration: save payload codec boundaries", function()
    -- @integration LSaveManager:getFormat
    -- @integration LSaveManager:delete
    -- @integration LSaveManager:isCompressed
    -- @integration LSaveManager:load
    -- @integration LSaveManager:register
    -- @integration LSaveManager:save
    -- @integration LSaveManager:setCompress
    -- @integration LSaveManager:setFormat
    -- @integration lurek.save.newManager
    it("save lifecycle round-trips JSON payloads with compression enabled", function()
        local slot = "integration_save_serialize_binary_json"
        local restored = nil
        local mgr = lurek.save.newManager()

        mgr:setFormat("json")
        mgr:setCompress(true)
        expect_equal("json", mgr:getFormat())
        expect_true(mgr:isCompressed())

        mgr:register("state", function()
            return {
                player = { hp = 77, ammo = 12 },
                flags = { tutorial = true },
            }
        end, function(data)
            restored = data
        end)

        mgr:save(slot)
        local ok, err = mgr:load(slot)
        expect_true(ok, err or "expected compressed JSON save to load")
        expect_equal(77, restored.player.hp)
        expect_equal(12, restored.player.ammo)
        expect_true(restored.flags.tutorial)
        mgr:delete(slot)
    end)
end)
test_summary()
