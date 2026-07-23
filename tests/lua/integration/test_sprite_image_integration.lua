-- Cross-module proof for image-backed sprite sheet and atlas validation.

-- @describe sprite and image integration
describe("sprite and image integration", function()
    -- @integration lurek.sprite.newSheetFromImage
    -- @integration lurek.sprite.newAtlasFromImage
    -- @integration LSpriteAtlas:entryCount
    -- @integration LSpriteSheet:getFrameCount
    -- @integration lurek.image.newImageData
    it("derives sheets from image dimensions and rejects out-of-bounds atlas regions", function()
        local image = lurek.image.newImageData(32, 16)
        local sheet = lurek.sprite.newSheetFromImage(image, { frameWidth = 16, frameHeight = 16 })
        expect_equal(2, sheet:getFrameCount())
        local atlas = lurek.sprite.newAtlasFromImage(image, '{"frames":{"ok":{"frame":{"x":0,"y":0,"w":16,"h":16}}}}')
        expect_equal(1, atlas:entryCount())
        expect_error(function()
            lurek.sprite.newAtlasFromImage(image, '{"frames":{"bad":{"frame":{"x":24,"y":0,"w":16,"h":16}}}}')
        end)
    end)

    -- @integration lurek.sprite.newAutoTileSheet
    -- @integration lurek.tilemap.newAutoTileSheet
    -- @integration LAutoTileSheet:getLayout
    -- @integration LAutoTileSheet:getTileCount
    -- @integration LSpriteAutoTileSheet:getLayout
    -- @integration LSpriteAutoTileSheet:getTileCount
    -- @integration lurek.image.newImageData
    it("keeps the sprite autotile compatibility descriptor aligned with tilemap", function()
        local image = lurek.image.newImageData(32, 32)
        local sprite_sheet = lurek.sprite.newAutoTileSheet(image, "minimal16", {
            tileWidth = 16,
            tileHeight = 16,
        })
        local tilemap_sheet = lurek.tilemap.newAutoTileSheet(16, 16, "minimal16")
        expect_equal(tilemap_sheet:getLayout(), sprite_sheet:getLayout())
        expect_equal(tilemap_sheet:getTileCount(), sprite_sheet:getTileCount())
    end)

    -- @integration lurek.sprite.parseAtlas
    -- @integration LSkeleton:bindAtlas
    -- @integration lurek.spine.newSkeleton
    it("supplies canonical sprite atlas regions to Spine attachments", function()
        local atlas = lurek.sprite.parseAtlas('{"frames":{"body":{"frame":{"x":0,"y":0,"w":16,"h":16}}}}')
        local skeleton = lurek.spine.newSkeleton("sprite-atlas-consumer")
        expect_equal(1, skeleton:bindAtlas(atlas))
    end)
end)

test_summary()
