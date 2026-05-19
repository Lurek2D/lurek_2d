--- TileMap Part 5: LTileSet full coverage

--@api-stub: LTileSet:getColumns
--@api-stub: LTileSet:getFirstGid
--@api-stub: LTileSet:getMargin
--@api-stub: LTileSet:getSpacing
--@api-stub: LTileSet:getTileCount
--@api-stub: LTileSet:getTileDimensions
--@api-stub: LTileSet:getTileHeight
--@api-stub: LTileSet:getTileWidth
--@api-stub: LTileSet:type
--@api-stub: LTileSet:typeOf
-- LTileSet introspection: dimensions, gid, columns, spacing, type.
do
    -- firstGid, tileCount, columns, tileWidth, tileHeight, spacing, margin
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 16, 16, 1, 0)
    print("columns=" .. ts:getColumns())
    print("firstGid=" .. ts:getFirstGid())
    print("margin=" .. ts:getMargin())
    print("spacing=" .. ts:getSpacing())
    print("tileCount=" .. ts:getTileCount())
    local tw, th = ts:getTileDimensions()
    print("tile_w=" .. tw .. " tile_h=" .. th)
    print("tileWidth=" .. ts:getTileWidth())
    print("tileHeight=" .. ts:getTileHeight())
    print("type=" .. ts:type())
    print("typeOf=" .. tostring(ts:typeOf("LTileSet")))
end

print("tilemap_05.lua")
