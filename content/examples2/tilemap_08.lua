--@api-stub: LLargeMapRenderer:getChunkSize
--@api-stub: LLargeMapRenderer:getTilesetColumns
--@api-stub: LLargeMapRenderer:type
-- LLargeMapRenderer chunk size, tileset columns, and type.
do
    local lmr = lurek.tilemap.newLargeMapRenderer(16, 16)
    local cs = lmr:getChunkSize()
    local cols = lmr:getTilesetColumns()
    local t = lmr:type()
    print("chunkSize:", cs, "tilesetColumns:", cols, "type:", t)
end

--@api-stub: LLargeMapRenderer:typeOf
--@api-stub: LMapBlock:getDimensions
--@api-stub: LMapBlock:getHeight
-- LLargeMapRenderer typeOf and LMapBlock dimension queries.
do
    local lmr = lurek.tilemap.newLargeMapRenderer(32, 32)
    local ok = lmr:typeOf("LLargeMapRenderer")
    local mb = lurek.tilemap.newMapBlock(10, 8, 2, 4)
    local w, h = mb:getDimensions()
    local height = mb:getHeight()
    print("typeOf:", ok, "getDimensions:", w, h, "getHeight:", height)
end

--@api-stub: LMapBlock:getHeightInSegments
--@api-stub: LMapBlock:getLayerCount
--@api-stub: LMapBlock:getSegmentSize
-- LMapBlock segment and layer metadata.
do
    local mb = lurek.tilemap.newMapBlock(12, 8, 3, 4)
    local hs = mb:getHeightInSegments()
    local lc = mb:getLayerCount()
    local ss = mb:getSegmentSize()
    print("heightInSegments:", hs, "layerCount:", lc, "segmentSize:", ss)
end

--@api-stub: LMapBlock:getWidth
--@api-stub: LMapBlock:getWidthInSegments
--@api-stub: LMapBlock:type
-- LMapBlock width and type.
do
    local mb = lurek.tilemap.newMapBlock(16, 12, 1, 4)
    local w = mb:getWidth()
    local ws = mb:getWidthInSegments()
    local t = mb:type()
    print("width:", w, "widthInSegments:", ws, "type:", t)
end

--@api-stub: LMapBlock:typeOf
-- LMapBlock typeOf.
do
    local mb = lurek.tilemap.newMapBlock(8, 8, 1, 2)
    local ok = mb:typeOf("LMapBlock")
    local notOk = mb:typeOf("LIsoMap")
    print("typeOf LMapBlock:", ok, "typeOf LIsoMap:", notOk)
end
