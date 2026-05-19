--@api-stub: LImageData:getWidth
--@api-stub: LImageData:getHeight
--@api-stub: LImageData:getRegion
-- LImageData dimensions and region extraction.
do
    local img = lurek.image.newImageData(64, 32)
    local w = img:getWidth()
    local h = img:getHeight()
    local region = img:getRegion(0, 0, 16, 16)
    print("image size:", w, h, "region:", region:getWidth(), region:getHeight())
end

--@api-stub: LImageData:blit
--@api-stub: LImageData:diff
--@api-stub: LImageData:resize
-- LImageData blit, diff and resize operations.
do
    local src = lurek.image.newImageData(32, 32)
    local dst = lurek.image.newImageData(64, 64)
    dst:blit(src, 0, 0)
    local d = dst:diff(src)
    local resized = src:resize(16, 16, "nearest")
    print("blit ok, diff ok, resized:", resized:getWidth())
end

--@api-stub: LImageData:mapPixels
--@api-stub: LImageData:type
--@api-stub: LImageData:typeOf
-- LImageData pixel mapping and type introspection.
do
    local img = lurek.image.newImageData(8, 8)
    img:mapPixels(function(x, y, r, g, b, a)
        return r, g, b, a
    end)
    local t = img:type()
    local ok = img:typeOf("LImageData")
    print("map done, type:", t)
end
