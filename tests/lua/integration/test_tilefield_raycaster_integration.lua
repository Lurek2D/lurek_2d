-- Integration: tilefield wall channel feeds raycaster scene building.

-- @describe integration: tilefield feeds raycaster
describe("integration: tilefield feeds raycaster", function()
    -- @integration lurek.tilefield.new
    -- @integration LTileField:setRef
    -- @integration LTileField:setModifier
    -- @integration LTileField:applyModifier
    -- @integration lurek.tileset.newCatalog
    -- @integration lurek.raycaster.buildMultiLevelSceneFromField
    -- @integration lurek.raycaster.getLastBuildStats
    it("builds render scene from typed field slots and tile light emitters", function()
        local texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
        local field = lurek.tilefield.new({ width = 6, height = 6, levels = 2 })
        field:setRef(3, 3, 1, "wall", { tileset = "dungeon", object = "stone_wall" })
        field:setRef(4, 3, 1, "door", 12)
        field:setRef(4, 4, 2, "window", 13)
        field:setRef(3, 4, 1, "floor", { tileset = "dungeon", object = "stone_floor" })
        field:setRef(3, 4, 1, "ceiling", { tileset = "dungeon", object = "stone_ceiling" })
        field:setRef(3, 4, 1, "object", { tileset = "dungeon", object = "banner" })
        field:setModifier("torch", { light = { radius = 4, intensity = 1.25, color = { 1.0, 0.7, 0.3 } } })
        field:applyModifier(3, 4, 1, "torch")
        local catalog = lurek.tileset.newCatalog({
            dungeon = lurek.tileset.fromProvider({
                firstGid = 1,
                tileCount = 4,
                columns = 2,
                tileWidth = 16,
                tileHeight = 16,
                objects = {
                    stone_wall = {
                        slot = "wall",
                        tileId = 2,
                        visual = { textureId = texture:getId(), tileId = 2 },
                    },
                    stone_floor = {
                        slot = "floor",
                        tileId = 3,
                        visual = { textureId = texture:getId(), tileId = 3 },
                    },
                    stone_ceiling = {
                        slot = "ceiling",
                        tileId = 4,
                        visual = { textureId = texture:getId(), tileId = 4 },
                    },
                    banner = {
                        slot = "object",
                        visual = { textureId = texture:getId() },
                    },
                },
            }),
        })

        local quads = lurek.raycaster.buildMultiLevelSceneFromField({
            px = 2.5,
            py = 2.5,
            angle = 0,
            fov = 1.0,
            rays = 32,
            max_dist = 8,
            screen_w = 96,
            screen_h = 64,
            active_level = 0,
        }, field, {
            catalog = catalog,
            wallChannel = "vision",
            wallSlot = "wall",
            doorSlot = "door",
            windowSlot = "window",
            floorSlot = "floor",
            ceilingSlot = "ceiling",
            objectSlot = "object",
            objectSize = 0.75,
            tileLights = true,
        }, nil, nil, { [11] = texture, [12] = texture, [13] = texture })
        local stats = lurek.raycaster.getLastBuildStats()

        expect_true(quads > 0)
        expect_true(stats.lightingSamples > 0)
    end)
end)

test_summary()
