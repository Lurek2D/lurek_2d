--- Image Module: LCompressedImageData and additional newImageData

--@api-stub: LCompressedImageData:getHeight
--@api-stub: LCompressedImageData:getWidth
-- Compressed image data dimensions and mipmap info.
do
    local cd = lurek.image.newCompressedData("assets/textures/ray_water.png")
    local w = cd:getWidth()
    local h = cd:getHeight()
    local mips = cd:getMipmapCount()
    print("compressed w=" .. w .. " h=" .. h .. " mips=" .. mips)
end

-- Create blank image data by dimensions or load from file.
--@api-stub: LImageData:getWidth
do
    local id = lurek.image.newImageData(64, 64)
    local w = id:getWidth()
    local h = id:getHeight()
    print("imagedata " .. w .. "x" .. h)
end

print("image_03.lua")
