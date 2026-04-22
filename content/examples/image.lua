-- content/examples/image.lua
-- love2d-style usage snippets for the lurek.image API (68 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/image.lua

-- ── lurek.image.* functions ──

--@api-stub: lurek.image.newImageData
-- Creates a new blank ImageData or loads one from a file.
-- Build once at startup; reuse across frames.
local imagedata = lurek.image.newImageData({ x = 0, y = 0 })
print("created", imagedata)
return imagedata

--@api-stub: lurek.image.newCompressedData
-- Loads compressed texture data from a DDS file.
-- Build once at startup; reuse across frames.
local compresseddata = lurek.image.newCompressedData("img/sprite.png")
print("created", compresseddata)
return compresseddata

--@api-stub: lurek.image.isCompressed
-- Returns true if the file at the given path is a DDS file.
-- Use as a guard inside lurek.update or event handlers.
if lurek.image.isCompressed("img/sprite.png") then
  print("isCompressed -> true")
end

--@api-stub: lurek.image.newLayeredImage
-- Creates a new empty LayeredImage canvas with no layers.
-- Build once at startup; reuse across frames.
local layeredimage = lurek.image.newLayeredImage(64, 64)
print("created", layeredimage)
return layeredimage

--@api-stub: lurek.image.saveImage
-- Saves a flat ImageData to a LIMG binary file at the given path.
-- May block — call from a worker thread for large payloads.
local result = lurek.image.saveImage(img_ud, "img/sprite.png")
-- may block; consider lurek.thread for large payloads
print("saveImage:", result)
print("ok")

--@api-stub: lurek.image.savePNG
-- Saves a flat ImageData as a PNG file at the given path.
-- May block — call from a worker thread for large payloads.
local result = lurek.image.savePNG(img_ud, "img/sprite.png")
-- may block; consider lurek.thread for large payloads
print("savePNG:", result)
print("ok")

--@api-stub: lurek.image.loadImage
-- Loads an ImageData from a LIMG binary file.
-- May block — call from a worker thread for large payloads.
local result = lurek.image.loadImage("img/sprite.png")
-- may block; consider lurek.thread for large payloads
print("loadImage:", result)
print("ok")

--@api-stub: lurek.image.loadLayered
-- Loads a LayeredImage from a LIMG binary file.
-- May block — call from a worker thread for large payloads.
local result = lurek.image.loadLayered("img/sprite.png")
-- may block; consider lurek.thread for large payloads
print("loadLayered:", result)
print("ok")

--@api-stub: lurek.image.newPaletteLut
-- Creates a new empty `PaletteLUT` used to remap colours in an image.
-- Build once at startup; reuse across frames.
local palettelut = lurek.image.newPaletteLut()
print("created", palettelut)
return palettelut

--@api-stub: lurek.image.newProvinceGrid
-- Loads a province map PNG and builds an O(1) spatial index with adjacency data.
-- Build once at startup; reuse across frames.
local provincegrid = lurek.image.newProvinceGrid("img/sprite.png")
print("created", provincegrid)
return provincegrid

-- ── ProvinceGrid methods ──

--@api-stub: ProvinceGrid:getWidth
-- Returns the grid width in pixels.
-- Cheap to call; safe inside callbacks.
local provinceGrid = lurek.image.newProvinceGrid()  -- or your existing handle
local value = provinceGrid:getWidth()
print("ProvinceGrid:getWidth ->", value)

--@api-stub: ProvinceGrid:getHeight
-- Returns the grid height in pixels.
-- Cheap to call; safe inside callbacks.
local provinceGrid = lurek.image.newProvinceGrid()  -- or your existing handle
local value = provinceGrid:getHeight()
print("ProvinceGrid:getHeight ->", value)

--@api-stub: ProvinceGrid:getAt
-- Returns the province ID at pixel coordinates (x, y).
-- Cheap to call; safe inside callbacks.
local provinceGrid = lurek.image.newProvinceGrid()  -- or your existing handle
local value = provinceGrid:getAt(100, 100)
print("ProvinceGrid:getAt ->", value)

--@api-stub: ProvinceGrid:provinceCount
-- Returns the number of unique non-zero province IDs detected in the map.
-- See the module spec for detailed semantics.
local provinceGrid = lurek.image.newProvinceGrid()
provinceGrid:provinceCount()
print("ProvinceGrid:provinceCount done")

--@api-stub: ProvinceGrid:adjacencies
-- Returns an array of adjacency records.
-- See the module spec for detailed semantics.
local provinceGrid = lurek.image.newProvinceGrid()
provinceGrid:adjacencies()
print("ProvinceGrid:adjacencies done")

-- ── LayeredImage methods ──

--@api-stub: LayeredImage:getWidth
-- Returns the canvas width shared by all layers.
-- Cheap to call; safe inside callbacks.
local layeredImage = lurek.image.newLayeredImage()  -- or your existing handle
local value = layeredImage:getWidth()
print("LayeredImage:getWidth ->", value)

--@api-stub: LayeredImage:getHeight
-- Returns the canvas height shared by all layers.
-- Cheap to call; safe inside callbacks.
local layeredImage = lurek.image.newLayeredImage()  -- or your existing handle
local value = layeredImage:getHeight()
print("LayeredImage:getHeight ->", value)

--@api-stub: LayeredImage:layerCount
-- Returns the number of layers in the stack.
-- See the module spec for detailed semantics.
local layeredImage = lurek.image.newLayeredImage()
layeredImage:layerCount()
print("LayeredImage:layerCount done")

--@api-stub: LayeredImage:addLayer
-- Appends a new blank transparent layer on top and returns its 1-based index.
-- Side-effecting; safe to call any time after init.
local layeredImage = lurek.image.newLayeredImage()
layeredImage:addLayer("img/sprite.png")
print("LayeredImage:addLayer done")

--@api-stub: LayeredImage:removeLayer
-- Removes the layer at the given 1-based index.
-- Pair with the matching constructor to free resources.
local layeredImage = lurek.image.newLayeredImage()
layeredImage:removeLayer(1)
-- layeredImage is now released
print("ok")

--@api-stub: LayeredImage:getLayer
-- Returns a copy of the layer's pixel buffer as an ImageData.
-- Cheap to call; safe inside callbacks.
local layeredImage = lurek.image.newLayeredImage()  -- or your existing handle
local value = layeredImage:getLayer(1)
print("LayeredImage:getLayer ->", value)

--@api-stub: LayeredImage:getOpacity
-- Returns the opacity of a layer in [0.0, 1.0].
-- Cheap to call; safe inside callbacks.
local layeredImage = lurek.image.newLayeredImage()  -- or your existing handle
local value = layeredImage:getOpacity(1)
print("LayeredImage:getOpacity ->", value)

--@api-stub: LayeredImage:setOpacity
-- Sets the opacity of a layer.
-- Apply at startup or in response to user input.
local layeredImage = lurek.image.newLayeredImage()
layeredImage:setOpacity(1, opacity)
print("LayeredImage:setOpacity applied")

--@api-stub: LayeredImage:isVisible
-- Returns whether a layer is visible.
-- Use as a guard inside lurek.update or event handlers.
local layeredImage = lurek.image.newLayeredImage()
if layeredImage:isVisible(1) then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: LayeredImage:setVisible
-- Shows or hides a layer during compositing.
-- Apply at startup or in response to user input.
local layeredImage = lurek.image.newLayeredImage()
layeredImage:setVisible(1, visible)
print("LayeredImage:setVisible applied")

--@api-stub: LayeredImage:getName
-- Returns the name of a layer.
-- Cheap to call; safe inside callbacks.
local layeredImage = lurek.image.newLayeredImage()  -- or your existing handle
local value = layeredImage:getName(1)
print("LayeredImage:getName ->", value)

--@api-stub: LayeredImage:setName
-- Renames the layer at the given index to the new name string.
-- Apply at startup or in response to user input.
local layeredImage = lurek.image.newLayeredImage()
layeredImage:setName(1, "img/sprite.png")
print("LayeredImage:setName applied")

--@api-stub: LayeredImage:swapLayers
-- Swaps two layers by their 1-based indices, changing their compositing order.
-- See the module spec for detailed semantics.
local layeredImage = lurek.image.newLayeredImage()
layeredImage:swapLayers(1, 0)
print("LayeredImage:swapLayers done")

--@api-stub: LayeredImage:merge
-- Flattens all visible layers into a single ImageData using Porter-Duff "over" compositing.
-- See the module spec for detailed semantics.
local layeredImage = lurek.image.newLayeredImage()
layeredImage:merge()
print("LayeredImage:merge done")

--@api-stub: LayeredImage:save
-- Saves the layered image to a LIMG binary file at the given path.
-- May block — call from a worker thread for large payloads.
local layeredImage = lurek.image.newLayeredImage()
layeredImage:save("img/sprite.png")
print("LayeredImage:save done")

-- ── CompressedImageData methods ──

--@api-stub: CompressedImageData:getWidth
-- Returns the width of the base mip level in pixels.
-- Cheap to call; safe inside callbacks.
local compressedImageData = lurek.image.newCompressedImageData()  -- or your existing handle
local value = compressedImageData:getWidth()
print("CompressedImageData:getWidth ->", value)

--@api-stub: CompressedImageData:getHeight
-- Returns the height of the base mip level in pixels.
-- Cheap to call; safe inside callbacks.
local compressedImageData = lurek.image.newCompressedImageData()  -- or your existing handle
local value = compressedImageData:getHeight()
print("CompressedImageData:getHeight ->", value)

--@api-stub: CompressedImageData:getDimensions
-- Returns the width and height of the base mip level.
-- Cheap to call; safe inside callbacks.
local compressedImageData = lurek.image.newCompressedImageData()  -- or your existing handle
local value = compressedImageData:getDimensions()
print("CompressedImageData:getDimensions ->", value)

--@api-stub: CompressedImageData:getMipmapCount
-- Returns the number of mipmap levels stored.
-- Cheap to call; safe inside callbacks.
local compressedImageData = lurek.image.newCompressedImageData()  -- or your existing handle
local value = compressedImageData:getMipmapCount()
print("CompressedImageData:getMipmapCount ->", value)

--@api-stub: CompressedImageData:getFormat
-- Returns the compressed format name string.
-- Cheap to call; safe inside callbacks.
local compressedImageData = lurek.image.newCompressedImageData()  -- or your existing handle
local value = compressedImageData:getFormat()
print("CompressedImageData:getFormat ->", value)

-- ── mlua methods ──

--@api-stub: mlua:getWidth
-- Returns the width.
-- Cheap to call; safe inside callbacks.
local mlua = lurek.image.newmlua()  -- or your existing handle
local value = mlua:getWidth()
print("mlua:getWidth ->", value)

--@api-stub: mlua:getHeight
-- Returns the height.
-- Cheap to call; safe inside callbacks.
local mlua = lurek.image.newmlua()  -- or your existing handle
local value = mlua:getHeight()
print("mlua:getHeight ->", value)

--@api-stub: mlua:getDimensions
-- Returns the dimensions.
-- Cheap to call; safe inside callbacks.
local mlua = lurek.image.newmlua()  -- or your existing handle
local value = mlua:getDimensions()
print("mlua:getDimensions ->", value)

--@api-stub: mlua:getPixel
-- Returns the pixel.
-- Cheap to call; safe inside callbacks.
local mlua = lurek.image.newmlua()  -- or your existing handle
local value = mlua:getPixel(100, 100)
print("mlua:getPixel ->", value)

--@api-stub: mlua:encode
-- Encode.
-- May block — call from a worker thread for large payloads.
local mlua = lurek.image.newmlua()
mlua:encode("hello")
print("mlua:encode done")

--@api-stub: mlua:getString
-- Returns the string.
-- Cheap to call; safe inside callbacks.
local mlua = lurek.image.newmlua()  -- or your existing handle
local value = mlua:getString()
print("mlua:getString ->", value)

--@api-stub: mlua:mapPixel
-- Map pixel.
-- See the module spec for detailed semantics.
local mlua = lurek.image.newmlua()
mlua:mapPixel(function() print("mapPixel fired") end)
print("mlua:mapPixel done")

--@api-stub: mlua:brightness
-- Brightness.
-- See the module spec for detailed semantics.
local mlua = lurek.image.newmlua()
mlua:brightness(1.0)
print("mlua:brightness done")

--@api-stub: mlua:contrast
-- Contrast.
-- See the module spec for detailed semantics.
local mlua = lurek.image.newmlua()
mlua:contrast(1.0)
print("mlua:contrast done")

--@api-stub: mlua:saturation
-- Saturation.
-- See the module spec for detailed semantics.
local mlua = lurek.image.newmlua()
mlua:saturation(1.0)
print("mlua:saturation done")

--@api-stub: mlua:gamma
-- Gamma.
-- See the module spec for detailed semantics.
local mlua = lurek.image.newmlua()
mlua:gamma(gamma)
print("mlua:gamma done")

--@api-stub: mlua:grayscale
-- Grayscale.
-- See the module spec for detailed semantics.
local mlua = lurek.image.newmlua()
mlua:grayscale()
print("mlua:grayscale done")

--@api-stub: mlua:sepia
-- Sepia.
-- See the module spec for detailed semantics.
local mlua = lurek.image.newmlua()
mlua:sepia()
print("mlua:sepia done")

--@api-stub: mlua:invert
-- Invert.
-- See the module spec for detailed semantics.
local mlua = lurek.image.newmlua()
mlua:invert()
print("mlua:invert done")

--@api-stub: mlua:threshold
-- Threshold.
-- See the module spec for detailed semantics.
local mlua = lurek.image.newmlua()
mlua:threshold(value)
print("mlua:threshold done")

--@api-stub: mlua:posterize
-- Posterize.
-- See the module spec for detailed semantics.
local mlua = lurek.image.newmlua()
mlua:posterize(levels)
print("mlua:posterize done")

--@api-stub: mlua:fill
-- Fill.
-- See the module spec for detailed semantics.
local mlua = lurek.image.newmlua()
mlua:fill(1, 0.5, 0, 1)
print("mlua:fill done")

--@api-stub: mlua:noise
-- Noise.
-- See the module spec for detailed semantics.
local mlua = lurek.image.newmlua()
mlua:noise(amount)
print("mlua:noise done")

--@api-stub: mlua:alphaMask
-- Alpha mask.
-- See the module spec for detailed semantics.
local mlua = lurek.image.newmlua()
mlua:alphaMask(1.0)
print("mlua:alphaMask done")

--@api-stub: mlua:flipHorizontal
-- Flip horizontal.
-- See the module spec for detailed semantics.
local mlua = lurek.image.newmlua()
mlua:flipHorizontal()
print("mlua:flipHorizontal done")

--@api-stub: mlua:flipVertical
-- Flip vertical.
-- See the module spec for detailed semantics.
local mlua = lurek.image.newmlua()
mlua:flipVertical()
print("mlua:flipVertical done")

--@api-stub: mlua:rotate90cw
-- Rotate90cw.
-- See the module spec for detailed semantics.
local mlua = lurek.image.newmlua()
mlua:rotate90cw()
print("mlua:rotate90cw done")

--@api-stub: mlua:crop
-- Crop.
-- See the module spec for detailed semantics.
local mlua = lurek.image.newmlua()
mlua:crop(100, 100, 64, 64)
print("mlua:crop done")

--@api-stub: mlua:resizeNearest
-- Resize nearest.
-- See the module spec for detailed semantics.
local mlua = lurek.image.newmlua()
mlua:resizeNearest(new_w, new_h)
print("mlua:resizeNearest done")

--@api-stub: mlua:blur
-- Blur.
-- See the module spec for detailed semantics.
local mlua = lurek.image.newmlua()
mlua:blur(radius)
print("mlua:blur done")

--@api-stub: mlua:sharpen
-- Sharpen.
-- See the module spec for detailed semantics.
local mlua = lurek.image.newmlua()
mlua:sharpen()
print("mlua:sharpen done")

--@api-stub: mlua:resize
-- Returns a bilinear-interpolated copy of the image at the given dimensions.
-- See the module spec for detailed semantics.
local mlua = lurek.image.newmlua()
mlua:resize(64, 64)
print("mlua:resize done")

--@api-stub: mlua:diff
-- Returns the sum of absolute per-channel pixel differences with another ImageData.
-- See the module spec for detailed semantics.
local mlua = lurek.image.newmlua()
mlua:diff(other_ud)
print("mlua:diff done")

--@api-stub: mlua:mapPixels
-- Applies a function to every pixel in-place.
-- See the module spec for detailed semantics.
local mlua = lurek.image.newmlua()
mlua:mapPixels(function() print("mapPixels fired") end)
print("mlua:mapPixels done")

--@api-stub: mlua:applyPaletteLut
-- Applies a `PaletteLUT` to the image in place, replacing exact colour matches.
-- Apply at startup or in response to user input.
local mlua = lurek.image.newmlua()
mlua:applyPaletteLut(lut_ud)
print("mlua:applyPaletteLut applied")

--@api-stub: mlua:setRawData
-- Replaces all pixel data from a raw RGBA byte string.
-- Apply at startup or in response to user input.
local mlua = lurek.image.newmlua()
mlua:setRawData(bytes)
print("mlua:setRawData applied")

-- ── PaletteLUT methods ──

--@api-stub: PaletteLUT:getColorCount
-- Returns the number of colour mapping entries.
-- Cheap to call; safe inside callbacks.
local paletteLUT = lurek.image.newPaletteLUT()  -- or your existing handle
local value = paletteLUT:getColorCount()
print("PaletteLUT:getColorCount ->", value)

--@api-stub: PaletteLUT:clear
-- Removes all colour mapping entries.
-- Pair with the matching constructor to free resources.
local paletteLUT = lurek.image.newPaletteLUT()
paletteLUT:clear()
-- paletteLUT is now released
print("ok")

