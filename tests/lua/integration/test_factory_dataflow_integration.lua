-- Integration: a Lua-owned factory slice composed from independent Lurek APIs.
--
-- The engine modules do not know about each other here. Lua owns every mapping:
-- ECS entity -> tilefield footprint -> flownet node -> game checkpoint.

-- @describe Lua-owned factory dataflow integration
describe("Lua-owned factory dataflow integration", function()
    -- @integration lurek.tilefield.new
    -- @integration LTileField:setFootprintOccupant
    -- @integration lurek.ecs.newUniverse
    -- @integration LUniverse:readComponents
    -- @integration lurek.graph.newGraph
    -- @integration LGraph:prepareBatch
    -- @integration LGraph:getNodeById
    -- @integration LGraphNode:setRecipe
    -- @integration LGraphNode:runRecipe
    -- @integration lurek.serialize.canonicalHash
    -- @integration lurek.runtime.getFixedTick
    it("lets Lua compose placement, identity, logistics, recipes, and checkpoints", function()
        local field = lurek.tilefield.new({ width = 8, height = 4 })
        local world = lurek.ecs.newUniverse()
        local graph = lurek.graph.newGraph()

        local topology = graph:prepareBatch({
            { op = "addNode", key = "mine", nodeType = "source", capacity = 32 },
            { op = "addNode", key = "assembler", nodeType = "assembler", capacity = 32 },
            { op = "addEdge", from = "mine", to = "assembler", edgeType = "belt" },
        })
        local node_ids = topology:commit()
        local mine_node = graph:getNodeById(node_ids.mine)
        local assembler_node = graph:getNodeById(node_ids.assembler)

        local mine_entity = world:spawn()
        local assembler_entity = world:spawn()
        world:set(mine_entity, "building", {
            kind = "mine",
            graphNodeId = node_ids.mine,
            footprint = { x = 1, y = 1, w = 2, h = 2 },
        })
        world:set(assembler_entity, "building", {
            kind = "assembler",
            graphNodeId = node_ids.assembler,
            footprint = { x = 4, y = 1, w = 2, h = 2 },
        })

        field:setFootprintOccupant({ x = 1, y = 1, w = 2, h = 2, occupant = mine_entity })
        field:setFootprintOccupant({
            x = 4, y = 1, w = 2, h = 2, occupant = assembler_entity,
        })

        -- Game policy remains in Lua: this scenario decides when resources reach
        -- the assembler and when its explicit recipe is allowed to run.
        assembler_node:setRecipe("gear", { ore = 2, coal = 1 }, { gear = 1 })
        for _, item_type in ipairs({ "ore", "coal", "ore" }) do
            graph:addItem(graph:createItem(item_type), assembler_node)
        end
        local execution = assembler_node:runRecipe("gear", 1)
        expect_equal(1, execution.runs)
        expect_equal(3, #execution.consumedIds)
        expect_equal(1, #execution.producedIds)
        expect_not_nil(mine_node)

        world:set(assembler_entity, "inventory", graph:summarizeInventory().byType)
        local rows = world:readComponents({
            { id = mine_entity, names = { "building" } },
            { id = assembler_entity, names = { "building", "inventory" } },
        })
        expect_equal(node_ids.mine, rows[1].components.building.graphNodeId)
        expect_equal(node_ids.assembler, rows[2].components.building.graphNodeId)
        expect_equal(1, rows[2].components.inventory.gear)
        expect_equal(mine_entity, field:getOccupant(1, 1, 1))
        expect_equal(assembler_entity, field:getOccupant(4, 1, 1))

        local checkpoint = {
            fixedTick = lurek.runtime.getFixedTick(),
            field = field:hashRegion({ x = 1, y = 1, w = 6, h = 2 }),
            graph = graph:stateHash(),
            buildings = rows,
        }
        local first_hash = lurek.serialize.canonicalHash(checkpoint)
        local second_hash = lurek.serialize.canonicalHash({
            buildings = rows,
            graph = graph:stateHash(),
            field = field:hashRegion({ x = 1, y = 1, w = 6, h = 2 }),
            fixedTick = lurek.runtime.getFixedTick(),
        })
        expect_equal(first_hash, second_hash)
    end)
end)

test_summary()
