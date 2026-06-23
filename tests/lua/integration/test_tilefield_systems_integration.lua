-- Integration: tilefield is the shared source for movement, visibility, lighting, minimap, and raycaster input.

-- @describe integration: tilefield coordinates gameplay systems without raycaster ownership
describe("integration: tilefield coordinates gameplay systems without raycaster ownership", function()
    -- @integration lurek.tilefield.new
    -- @integration LTileField:applyProfile
    -- @integration LTileField:addPointLight
    -- @integration LTileField:computeLight
    -- @integration LTileField:getLight
    -- @integration LTileField:exportBlockLayer
    -- @integration lurek.pathfind.newNavGridFromField
    -- @integration lurek.pathfind.newPathfinder
    -- @integration lurek.pathfind.rangeMapFromField
    -- @integration LUnitPathfinder:findPath
    -- @integration lurek.visibility.lineOfSight
    -- @integration lurek.visibility.lineOfAction
    -- @integration lurek.visibility.newTileVisibility
    -- @integration LTileVisibility:computeVisible
    -- @integration LTileVisibility:computeAction
    -- @integration LTileVisibility:isVisible
    -- @integration LTileVisibility:canActOn
    -- @integration LTileVisibility:visibleCells
    -- @integration lurek.minimap.newMinimap
    -- @integration LMinimap:setTerrainData
    -- @integration LMinimap:setFogData
    -- @integration LMinimap:setLayerData
    -- @integration LMinimap:getTerrain
    -- @integration LMinimap:getFogLevel
    -- @integration LMinimap:getLayerData
    -- @integration lurek.raycaster.buildMultiLevelSceneFromField
    it("uses one field while each module owns only its own calculation", function()
        local width, height = 8, 6
        local field = lurek.tilefield.new({ width = width, height = height, levels = 2 })
        field:applyProfile(3, 2, 1, "window")
        field:applyProfile(4, 4, 1, "wall")
        field:applyProfile(5, 3, 2, "half_wall")
        field:addPointLight({ x = 1, y = 2, z = 1, radius = 6, intensity = 1.0 })
        field:computeLight({ includePointLights = true, includeGlobalLight = false })

        local from = { x = 1, y = 2, z = 1 }
        local target = { x = 6, y = 2, z = 1 }
        expect_true(lurek.visibility.lineOfSight(field, from, target), "window must not block vision")
        expect_true(not lurek.visibility.lineOfAction(field, from, target), "window must block action")

        local nav = lurek.pathfind.newNavGridFromField(field, { level = 1, channel = "move" })
        local pathfinder = lurek.pathfind.newPathfinder(nav)
        local path = pathfinder:findPath(1, 2, 6, 2)
        expect_not_nil(path)
        for i = 1, #path do
            expect_true(not (path[i].x == 3 and path[i].y == 2), "pathfind must avoid window movement blocker")
        end

        local range = lurek.pathfind.rangeMapFromField(field, {
            origin = from,
            budget = 5,
            channel = "move",
        })
        expect_equal(width, range.width)
        expect_true(#range.cells > 1)

        local vis = lurek.visibility.newTileVisibility(field, { players = { "p1", "p2" }, rememberExplored = true })
        vis:computeVisible("p1", { origin = from, range = 6, channel = "vision" })
        vis:computeAction("p1", { origin = from, range = 6, channel = "action" })
        expect_true(vis:isVisible("p1", target.x, target.y, target.z))
        expect_true(not vis:canActOn("p1", target.x, target.y, target.z))
        expect_true(not vis:isVisible("p2", target.x, target.y, target.z), "players keep independent masks")

        local _, _, _, luma = field:getLight(4, 2, 1)
        expect_true(luma > 0, "tile lighting is computed by tilefield and remains independent of visibility")

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
        local light_overlay = {}
        for y = 1, height do
            for x = 1, width do
                local _, _, _, cell_luma = field:getLight(x, y, 1)
                light_overlay[(y - 1) * width + x] = math.floor(cell_luma * 9 + 0.5)
            end
        end

        local mm = lurek.minimap.newMinimap(width, height)
        mm:setTerrainData(terrain)
        mm:setFogData(fog)
        mm:setLayerData(1, light_overlay)
        expect_equal(1, mm:getTerrain(3, 2))
        expect_equal(2, mm:getFogLevel(1, 2))
        expect_true(mm:getLayerData(1)[2] > 0)

        local quads = lurek.raycaster.buildMultiLevelSceneFromField({
            px = 1.5,
            py = 2.5,
            angle = 0,
            fov = 1.0,
            rays = 32,
            max_dist = 8,
            screen_w = 96,
            screen_h = 64,
            active_level = 0,
        }, field, { wallChannel = "vision" })
        expect_true(quads >= 0)

        expect_nil(lurek.raycaster["line" .. "OfSight"])
        expect_nil(lurek.raycaster["compute" .. "TileLight"])
        expect_nil(lurek.raycaster["is" .. "WalkBlocked"])
    end)
end)

test_summary()
