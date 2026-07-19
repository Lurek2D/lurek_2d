-- Integration: tilefield is the shared source for movement, awareness, tile lighting, minimap, and raycaster input.

-- @describe integration: tilefield coordinates gameplay systems without raycaster ownership
describe("integration: tilefield coordinates gameplay systems without raycaster ownership", function()
    -- @integration lurek.tilefield.new
    -- @integration LTileField:applyProfile
    -- @integration lurek.tilelight.new
    -- @integration LTileLightMap:addPointLight
    -- @integration LTileLightMap:compute
    -- @integration LTileLightMap:getLight
    -- @integration LTileField:exportBlockLayer
    -- @integration lurek.pathfind.newNavGridFromField
    -- @integration lurek.pathfind.newPathfinder
    -- @integration lurek.pathfind.rangeMapFromField
    -- @integration LUnitPathfinder:findPath
    -- @integration lurek.awareness.lineOfSight
    -- @integration lurek.awareness.lineOfAction
    -- @integration lurek.awareness.newTileAwareness
    -- @integration LTileAwareness:computeVisible
    -- @integration LTileAwareness:computeAction
    -- @integration LTileAwareness:isVisible
    -- @integration LTileAwareness:canActOn
    -- @integration LTileAwareness:visibleCells
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
        local light = lurek.tilelight.new(field)
        light:addPointLight({ x = 1, y = 2, z = 1, radius = 6, intensity = 1.0 })
        light:compute({ includePointLights = true, includeGlobalLight = false })

        local from = { x = 1, y = 2, z = 1 }
        local target = { x = 6, y = 2, z = 1 }
        expect_true(lurek.awareness.lineOfSight(field, from, target), "window must not block vision")
        expect_true(not lurek.awareness.lineOfAction(field, from, target), "window must block action")

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

        local vis = lurek.awareness.newTileAwareness(field, { players = { "p1", "p2" }, rememberExplored = true })
        vis:computeVisible("p1", { origin = from, range = 6, channel = "vision" })
        vis:computeAction("p1", { origin = from, range = 6, channel = "action" })
        expect_true(vis:isVisible("p1", target.x, target.y, target.z))
        expect_true(not vis:canActOn("p1", target.x, target.y, target.z))
        expect_true(not vis:isVisible("p2", target.x, target.y, target.z), "players keep independent masks")

        local _, _, _, luma = light:getLight(4, 2, 1)
        expect_true(luma > 0, "tile lighting is computed by tilelight and remains independent of awareness")

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
                local _, _, _, cell_luma = light:getLight(x, y, 1)
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

-- @describe integration: mutable side-view block edit pipeline
describe("integration: mutable side-view block edit pipeline", function()
    -- @integration LChunkMap:chunkToBytes
    -- @integration LChunkMap:getDirtyChunks
    -- @integration LChunkMap:loadChunkFromBytes
    -- @integration LChunkMap:setTiles
    -- @integration LLiquidMap:getDirtyChunks
    -- @integration LMinimap:syncTileFieldBlockLayer
    -- @integration LTerrain:flush
    -- @integration LTerrain:getDirtyChunks
    -- @integration LTileField:beginEdit
    -- @integration LTileField:commitEdit
    -- @integration LTileField:defineBlockWorldSlots
    -- @integration LTileField:setBlock
    -- @integration LTileField:setRef
    -- @integration LTileField:snapshot
    -- @integration LTileField:restore
    -- @integration lurek.minimap.newMinimap
    -- @integration lurek.physics.newLiquidMap
    -- @integration lurek.physics.newTerrain
    -- @integration lurek.physics.newWorld
    -- @integration lurek.tilefield.new
    -- @integration lurek.tilelight.new
    -- @integration lurek.tilemap.newChunkMap
    it("mines and saves a small Terraria-like slice through existing owners", function()
        local width, height = 12, 8
        local field = lurek.tilefield.new({ width = width, height = height })
        field:defineBlockWorldSlots()
        field:beginEdit()
        for x = 1, width do
            field:setRef(x, 7, 1, "foreground", 2)
            field:setBlock(x, 7, 1, "move", true)
            field:setBlock(x, 7, 1, "light", true)
        end
        field:setRef(4, 6, 1, "wall", 3)
        field:setResource(5, 7, 1, "copper")
        local dirty_rects = field:commitEdit(4)
        expect_true(#dirty_rects >= 1)

        local chunks = lurek.tilemap.newChunkMap(4)
        chunks:setTiles({
            { x = 3, y = 6, gid = 0 },
            { x = 4, y = 6, gid = 0 },
            { x = 5, y = 6, gid = 2 },
        })
        expect_true(#chunks:getDirtyChunks() >= 1)
        local bytes = chunks:chunkToBytes(1, 1)
        expect_type("string", bytes)
        local chunk_clone = lurek.tilemap.newChunkMap(4)
        chunk_clone:loadChunkFromBytes(1, 1, bytes)
        expect_equal(2, chunk_clone:getTile(5, 6))

        local world = lurek.physics.newWorld(0, 200)
        local terrain = lurek.physics.newTerrain(width, height, 16, world)
        for x = 0, width - 1 do
            terrain:setCell(x, 6, true)
        end
        expect_true(#terrain:getDirtyChunks() >= 1)
        terrain:flush()
        expect_equal(0, #terrain:getDirtyChunks())

        local liquid = lurek.physics.newLiquidMap(width, height, 16, world, terrain)
        liquid:setCell(2, 5, 1.0, "water")
        expect_true(#liquid:getDirtyChunks() >= 1)

        local light = lurek.tilelight.new(field)
        light:compute({ includePointLights = false, includeGlobalLight = true })
        local mm = lurek.minimap.newMinimap(width, height)
        mm:syncTileFieldBlockLayer(field, "move", 1)
        expect_equal(255, mm:getLayerData(1)[(7 - 1) * width + 1])

        local saved = field:snapshot()
        local restored = lurek.tilefield.new({ width = 1, height = 1 })
        restored:restore(saved)
        expect_equal(2, restored:getRef(1, 7, 1, "foreground"))
        expect_equal(3, restored:getRef(4, 6, 1, "wall"))
        expect_equal("copper", restored:getResource(5, 7, 1))

        lurek.physics.destroyWorld(world)
    end)
end)

test_summary()
