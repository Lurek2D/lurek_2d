-- Integration: minimap native adapters consume tilefield, awareness, and tilelight data.

-- @describe integration: minimap consumes tilefield systems
describe("integration: minimap consumes tilefield systems", function()
    -- @integration lurek.tilefield.new
    -- @integration LTileField:applyProfile
    -- @integration lurek.tilelight.new
    -- @integration LTileLightMap:addPointLight
    -- @integration LTileLightMap:compute
    -- @integration lurek.awareness.newTileAwareness
    -- @integration LTileAwareness:computeVisible
    -- @integration lurek.minimap.newMinimap
    -- @integration LMinimap:syncTileFieldBlockLayer
    -- @integration LMinimap:syncTileLightLayer
    -- @integration LMinimap:syncTileAwarenessFog
    -- @integration LMinimap:getFogLevel
    -- @integration LMinimap:getLayerData
    it("minimap ingests terrain fog and light data from native adapters", function()
        local width, height = 6, 6
        local field = lurek.tilefield.new({ width = width, height = height, levels = 2 })
        field:applyProfile(3, 2, 1, "wall")
        field:applyProfile(4, 2, 1, "window")
        local light_map = lurek.tilelight.new(field)
        light_map:addPointLight({ x = 2, y = 2, z = 1, radius = 5, intensity = 1 })
        light_map:compute({ includePointLights = true, includeGlobalLight = false })

        local vis = lurek.awareness.newTileAwareness(field, { players = { "p1" } })
        vis:computeVisible("p1", { origin = { x = 1, y = 1, z = 1 }, range = 4 })

        local mm = lurek.minimap.newMinimap(width, height)
        mm:syncTileFieldBlockLayer(field, "move", 1)
        mm:syncTileAwarenessFog(vis, "p1")
        mm:syncTileLightLayer(light_map, 2, { scale = 9 })

        local blockers = mm:getLayerData(1)
        expect_equal(255, blockers[9])
        expect_equal(2, mm:getFogLevel(1, 1))
        local layer = mm:getLayerData(2)
        expect_type("table", layer)
        expect_true(layer[8] > 0, "light layer should be ingested as passive overlay data")
    end)
end)

test_summary()
