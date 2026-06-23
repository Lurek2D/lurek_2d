-- Integration: tilefield and visibility export passive data consumed by minimap.

-- @describe integration: tilefield feeds minimap
describe("integration: tilefield feeds minimap", function()
    -- @integration lurek.tilefield.new
    -- @integration LTileField:applyProfile
    -- @integration LTileField:addPointLight
    -- @integration LTileField:computeLight
    -- @integration LTileField:exportBlockLayer
    -- @integration LTileField:exportLightLayer
    -- @integration lurek.visibility.newTileVisibility
    -- @integration LTileVisibility:computeVisible
    -- @integration LTileVisibility:visibleCells
    -- @integration lurek.minimap.newMinimap
    -- @integration LMinimap:setTerrainData
    -- @integration LMinimap:setFogData
    -- @integration LMinimap:setLayerData
    -- @integration LMinimap:getTerrain
    -- @integration LMinimap:getFogLevel
    -- @integration LMinimap:getLayerData
    it("minimap ingests terrain fog and light data exported from tilefield systems", function()
        local width, height = 6, 6
        local field = lurek.tilefield.new({ width = width, height = height, levels = 2 })
        field:applyProfile(3, 2, 1, "wall")
        field:applyProfile(4, 2, 1, "window")
        field:addPointLight({ x = 2, y = 2, z = 1, radius = 5, intensity = 1 })
        field:computeLight({ includePointLights = true, includeGlobalLight = false })

        local vis = lurek.visibility.newTileVisibility(field, { players = { "p1" } })
        vis:computeVisible("p1", { origin = { x = 1, y = 1, z = 1 }, range = 4 })

        local terrain = {}
        local blockers = field:exportBlockLayer("move", 1)
        for i = 1, #blockers do
            terrain[i] = blockers[i] and 1 or 0
        end

        local fog = {}
        for i = 1, width * height do fog[i] = 0 end
        for _, cell in ipairs(vis:visibleCells("p1", 1)) do
            fog[(cell.y - 1) * width + cell.x] = 2
        end

        local light_layer = {}
        for i, light in ipairs(field:exportLightLayer(1)) do
            light_layer[i] = math.floor((light.luma or 0) * 9 + 0.5)
        end

        local mm = lurek.minimap.newMinimap(width, height)
        mm:setTerrainData(terrain)
        mm:setFogData(fog)
        mm:setLayerData(1, light_layer)

        expect_equal(1, mm:getTerrain(3, 2))
        expect_equal(2, mm:getFogLevel(1, 1))
        local layer = mm:getLayerData(1)
        expect_type("table", layer)
        expect_true(layer[8] > 0, "light layer should be ingested as passive overlay data")
    end)
end)

test_summary()
