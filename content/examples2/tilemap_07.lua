--@api-stub: LIsoMap:getHeight
--@api-stub: LIsoMap:getLevelHeight
--@api-stub: LIsoMap:getPartCount
-- LIsoMap dimension and level geometry queries.
do
    local iso = lurek.tilemap.newIsoMap(20, 15, 64, 32, 16, 4)
    local h = iso:getHeight()
    local lh = iso:getLevelHeight()
    local pc = iso:getPartCount()
    print("isomap height:", h, "levelHeight:", lh, "partCount:", pc)
end

--@api-stub: LIsoMap:getTileHeight
--@api-stub: LIsoMap:getTileWidth
--@api-stub: LIsoMap:getWidth
-- LIsoMap tile size and width.
do
    local iso = lurek.tilemap.newIsoMap(10, 10, 64, 32, 16, 4)
    local tw = iso:getTileWidth()
    local th = iso:getTileHeight()
    local w = iso:getWidth()
    print("tileWidth:", tw, "tileHeight:", th, "width:", w)
end

--@api-stub: LIsoMap:type
--@api-stub: LIsoMap:typeOf
-- LIsoMap type identity.
do
    local iso = lurek.tilemap.newIsoMap(8, 8, 32, 16, 8, 2)
    local t = iso:type()
    local ok = iso:typeOf("LIsoMap")
    local notOk = iso:typeOf("LTileMap")
    print("type:", t, "typeOf:", ok, "typeOf LTileMap:", notOk)
end
