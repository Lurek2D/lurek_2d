--@api-stub: LAutoTileSheet:getLayout
--@api-stub: LAutoTileSheet:getTileCount
--@api-stub: LAutoTileSheet:getTileHeight
-- LAutoTileSheet dimension and layout queries.
do
    local sheet = lurek.tilemap.newAutoTileSheet(16, 16, "blob47")
    local layout = sheet:getLayout()
    local count = sheet:getTileCount()
    local h = sheet:getTileHeight()
    print("layout:", layout, "tileCount:", count, "tileHeight:", h)
end

--@api-stub: LAutoTileSheet:getTileWidth
--@api-stub: LAutoTileSheet:type
--@api-stub: LAutoTileSheet:typeOf
-- LAutoTileSheet tile width and type identity.
do
    local sheet = lurek.tilemap.newAutoTileSheet(32, 32, "minimal16")
    local w = sheet:getTileWidth()
    local t = sheet:type()
    local ok = sheet:typeOf("LAutoTileSheet")
    print("tileWidth:", w, "type:", t, "typeOf:", ok)
end

--@api-stub: LChunkMap:getChunkSize
--@api-stub: LChunkMap:type
--@api-stub: LChunkMap:typeOf
-- LChunkMap size and type identity.
do
    local cm = lurek.tilemap.newChunkMap(32)
    local sz = cm:getChunkSize()
    local t = cm:type()
    local ok = cm:typeOf("LChunkMap")
    print("chunkSize:", sz, "type:", t, "typeOf:", ok)
end
