--- TileMap Part 4: getChunkSize, getTileDimensions, getTileHeight, getTileWidth, type, typeOf, iso/hex helpers

--@api-stub: LTileMap:getChunkSize
--@api-stub: LTileMap:getTileDimensions
--@api-stub: LTileMap:getTileHeight
--@api-stub: LTileMap:getTileWidth
--@api-stub: LTileMap:type
--@api-stub: LTileMap:typeOf
-- TileMap introspection: tile dimensions, chunk size, and type queries.
do
    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local cs = tm:getChunkSize()
    print("chunk_size=" .. cs)
    local tw, th = tm:getTileDimensions()
    print("tile_w=" .. tw .. " tile_h=" .. th)
    local tw2 = tm:getTileWidth()
    local th2 = tm:getTileHeight()
    print("tw2=" .. tw2 .. " th2=" .. th2)
    print("type=" .. tm:type())
    print("typeOf=" .. tostring(tm:typeOf("LTileMap")))
end

--@api-stub: lurek.tilemap.fromScreenHex
--@api-stub: lurek.tilemap.fromScreenIso
--@api-stub: lurek.tilemap.isoDirectionName
--@api-stub: lurek.tilemap.isoRotate
-- Hex and isometric coordinate helpers.
do
    local hx, hy = lurek.tilemap.fromScreenHex(80, 40, 32)
    print("hex_x=" .. hx .. " hex_y=" .. hy)
    local ix, iy = lurek.tilemap.fromScreenIso(128, 64, 32, 16)
    print("iso_x=" .. ix .. " iso_y=" .. iy)
    local name = lurek.tilemap.isoDirectionName(1)
    print("iso_dir=" .. name)
    local rotated = lurek.tilemap.isoRotate(1, 2)
    print("iso_rotated=" .. rotated)
end

print("tilemap_04.lua")
