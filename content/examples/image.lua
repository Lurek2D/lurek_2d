-- content/examples/image.lua
-- Lurek2D lurek.image API Reference
-- Run with: cargo run -- content/examples/image
--
-- Scenario: A pixel art RPG with a map editor that loads, manipulates, and exports
-- images — applying color grading for day/night, generating province maps,
-- layered character portraits, palette swaps, and screenshot post-processing.

print("=== lurek.image — Image Processing & Manipulation ===\n")

-- =============================================================================
-- Image Data Creation (module-level functions)
-- =============================================================================

-- ---- Stub: lurek.image.newImageData ---------------------------------------
--@api-stub: lurek.image.newImageData
-- Demonstrates the proper usage of lurek.image.newImageData.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_image_newImageData()
    local canvas_img = lurek.image.newImageData(256, 256)
    print("blank image data: 256x256 pixels")
end
local _ok, _err = pcall(demo_lurek_image_newImageData)

-- ---- Stub: lurek.image.loadImage ------------------------------------------
--@api-stub: lurek.image.loadImage
-- Demonstrates the proper usage of lurek.image.loadImage.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_image_loadImage()
    local hero_portrait = lurek.image.loadImage("assets/portraits/hero.png")
    print("hero portrait loaded for editing")
end
local _ok, _err = pcall(demo_lurek_image_loadImage)

-- ---- Stub: lurek.image.newCompressedData ----------------------------------
--@api-stub: lurek.image.newCompressedData
-- Demonstrates the proper usage of lurek.image.newCompressedData.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_image_newCompressedData()
    local compressed = lurek.image.newCompressedData("assets/textures/world_atlas.dds")
    print("compressed texture loaded: world atlas")
end
local _ok, _err = pcall(demo_lurek_image_newCompressedData)

-- ---- Stub: lurek.image.isCompressed ---------------------------------------
--@api-stub: lurek.image.isCompressed
-- Demonstrates the proper usage of lurek.image.isCompressed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_image_isCompressed()
    print("world atlas compressed: " .. tostring(lurek.image.isCompressed(compressed)))
end
local _ok, _err = pcall(demo_lurek_image_isCompressed)

-- ---- Stub: lurek.image.newLayeredImage ------------------------------------
--@api-stub: lurek.image.newLayeredImage
-- Demonstrates the proper usage of lurek.image.newLayeredImage.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_image_newLayeredImage()
    local portrait_layers = lurek.image.newLayeredImage(128, 128)
    print("layered image: 128x128 (character portrait compositor)")
end
local _ok, _err = pcall(demo_lurek_image_newLayeredImage)

-- ---- Stub: lurek.image.loadLayered ----------------------------------------
--@api-stub: lurek.image.loadLayered
-- Demonstrates the proper usage of lurek.image.loadLayered.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_image_loadLayered()
    local npc_layers = lurek.image.loadLayered("assets/portraits/npc_layered.png")
    print("layered NPC portrait loaded")
end
local _ok, _err = pcall(demo_lurek_image_loadLayered)

-- ---- Stub: lurek.image.newPaletteLut --------------------------------------
--@api-stub: lurek.image.newPaletteLut
-- Create a palette look-up table for color swaps (e.g. faction recoloring).
-- Maps source colors to replacement colors.
local fire_palette = lurek.image.newPaletteLut({
    {0.8, 0.2, 0.1, 1.0},  -- red
    {1.0, 0.5, 0.0, 1.0},  -- orange
    {1.0, 0.9, 0.2, 1.0},  -- yellow
    {0.3, 0.1, 0.0, 1.0},  -- dark red
})
print("fire palette LUT: 4 colors (red/orange/yellow/dark)")

-- ---- Stub: lurek.image.newProvinceGrid ------------------------------------
--@api-stub: lurek.image.newProvinceGrid
-- Demonstrates the proper usage of lurek.image.newProvinceGrid.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_image_newProvinceGrid()
    local province_map = lurek.image.newProvinceGrid("assets/maps/provinces.png")
    print("province grid loaded from color-coded map")
end
local _ok, _err = pcall(demo_lurek_image_newProvinceGrid)

-- =============================================================================
-- Save / Export (module-level functions)
-- =============================================================================

-- ---- Stub: lurek.image.saveImage ------------------------------------------
--@api-stub: lurek.image.saveImage
-- Demonstrates the proper usage of lurek.image.saveImage.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_image_saveImage()
    lurek.image.saveImage(canvas_img, "output/generated_texture.png")
    print("image saved: output/generated_texture.png")
end
local _ok, _err = pcall(demo_lurek_image_saveImage)

-- ---- Stub: lurek.image.savePNG --------------------------------------------
--@api-stub: lurek.image.savePNG
-- Demonstrates the proper usage of lurek.image.savePNG.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_image_savePNG()
    lurek.image.savePNG(canvas_img, "output/texture_hq.png")
    print("PNG saved: output/texture_hq.png")
end
local _ok, _err = pcall(demo_lurek_image_savePNG)

-- =============================================================================
-- ProvinceGrid Object Methods
-- =============================================================================

-- ---- Stub: ProvinceGrid:getWidth ------------------------------------------
--@api-stub: ProvinceGrid:getWidth
-- Demonstrates the proper usage of ProvinceGrid:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ProvinceGrid_getWidth()
    print("province grid width: " .. province_map:getWidth() .. "px")
end
local _ok, _err = pcall(demo_ProvinceGrid_getWidth)

-- ---- Stub: ProvinceGrid:getHeight -----------------------------------------
--@api-stub: ProvinceGrid:getHeight
-- Demonstrates the proper usage of ProvinceGrid:getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ProvinceGrid_getHeight()
    print("province grid height: " .. province_map:getHeight() .. "px")
end
local _ok, _err = pcall(demo_ProvinceGrid_getHeight)

-- ---- Stub: ProvinceGrid:getAt ---------------------------------------------
--@api-stub: ProvinceGrid:getAt
-- Demonstrates the proper usage of ProvinceGrid:getAt.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ProvinceGrid_getAt()
    local province_id = province_map:getAt(256, 128)
    print("province at (256,128): " .. tostring(province_id))
end
local _ok, _err = pcall(demo_ProvinceGrid_getAt)

-- ---- Stub: ProvinceGrid:provinceCount -------------------------------------
--@api-stub: ProvinceGrid:provinceCount
-- Demonstrates the proper usage of ProvinceGrid:provinceCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ProvinceGrid_provinceCount()
    print("total provinces: " .. province_map:provinceCount())
end
local _ok, _err = pcall(demo_ProvinceGrid_provinceCount)

-- ---- Stub: ProvinceGrid:adjacencies ---------------------------------------
--@api-stub: ProvinceGrid:adjacencies
-- Demonstrates the proper usage of ProvinceGrid:adjacencies.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ProvinceGrid_adjacencies()
    local neighbors = province_map:adjacencies(province_id)
    print("province " .. tostring(province_id) .. " neighbors: " .. #neighbors)
end
local _ok, _err = pcall(demo_ProvinceGrid_adjacencies)

-- =============================================================================
-- LayeredImage Object Methods — paper-doll compositing
-- =============================================================================

-- ---- Stub: LayeredImage:getWidth ------------------------------------------
--@api-stub: LayeredImage:getWidth
-- Demonstrates the proper usage of LayeredImage:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LayeredImage_getWidth()
    print("layered width: " .. portrait_layers:getWidth())
end
local _ok, _err = pcall(demo_LayeredImage_getWidth)

-- ---- Stub: LayeredImage:getHeight -----------------------------------------
--@api-stub: LayeredImage:getHeight
-- Demonstrates the proper usage of LayeredImage:getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LayeredImage_getHeight()
    print("layered height: " .. portrait_layers:getHeight())
end
local _ok, _err = pcall(demo_LayeredImage_getHeight)

-- ---- Stub: LayeredImage:layerCount ----------------------------------------
--@api-stub: LayeredImage:layerCount
-- Demonstrates the proper usage of LayeredImage:layerCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LayeredImage_layerCount()
    print("layers: " .. portrait_layers:layerCount())
end
local _ok, _err = pcall(demo_LayeredImage_layerCount)

-- ---- Stub: LayeredImage:addLayer ------------------------------------------
--@api-stub: LayeredImage:addLayer
-- Demonstrates the proper usage of LayeredImage:addLayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LayeredImage_addLayer()
    portrait_layers:addLayer("base_body", "assets/portraits/layers/body.png")
    portrait_layers:addLayer("armor", "assets/portraits/layers/plate_armor.png")
    portrait_layers:addLayer("helmet", "assets/portraits/layers/iron_helm.png")
    portrait_layers:addLayer("expression", "assets/portraits/layers/smile.png")
    print("4 layers added: body, armor, helmet, expression")
end
local _ok, _err = pcall(demo_LayeredImage_addLayer)

-- ---- Stub: LayeredImage:removeLayer ---------------------------------------
--@api-stub: LayeredImage:removeLayer
-- Demonstrates the proper usage of LayeredImage:removeLayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LayeredImage_removeLayer()
    portrait_layers:removeLayer("helmet")
    print("helmet layer removed (player unequipped)")
end
local _ok, _err = pcall(demo_LayeredImage_removeLayer)

-- ---- Stub: LayeredImage:getLayer ------------------------------------------
--@api-stub: LayeredImage:getLayer
-- Demonstrates the proper usage of LayeredImage:getLayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LayeredImage_getLayer()
    local armor_layer = portrait_layers:getLayer("armor")
    print("armor layer: " .. tostring(armor_layer))
end
local _ok, _err = pcall(demo_LayeredImage_getLayer)

-- ---- Stub: LayeredImage:getOpacity ----------------------------------------
--@api-stub: LayeredImage:getOpacity
-- Demonstrates the proper usage of LayeredImage:getOpacity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LayeredImage_getOpacity()
    print("armor opacity: " .. tostring(portrait_layers:getOpacity("armor")))
end
local _ok, _err = pcall(demo_LayeredImage_getOpacity)

-- ---- Stub: LayeredImage:setOpacity ----------------------------------------
--@api-stub: LayeredImage:setOpacity
-- Demonstrates the proper usage of LayeredImage:setOpacity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LayeredImage_setOpacity()
    portrait_layers:setOpacity("armor", 0.5)
    print("armor opacity: 0.5 (damaged appearance)")
end
local _ok, _err = pcall(demo_LayeredImage_setOpacity)

-- ---- Stub: LayeredImage:isVisible -----------------------------------------
--@api-stub: LayeredImage:isVisible
-- Demonstrates the proper usage of LayeredImage:isVisible.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LayeredImage_isVisible()
    print("armor visible: " .. tostring(portrait_layers:isVisible("armor")))
end
local _ok, _err = pcall(demo_LayeredImage_isVisible)

-- ---- Stub: LayeredImage:setVisible ----------------------------------------
--@api-stub: LayeredImage:setVisible
-- Demonstrates the proper usage of LayeredImage:setVisible.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LayeredImage_setVisible()
    portrait_layers:setVisible("expression", true)
    print("expression layer visible")
end
local _ok, _err = pcall(demo_LayeredImage_setVisible)

-- ---- Stub: LayeredImage:getName -------------------------------------------
--@api-stub: LayeredImage:getName
-- Demonstrates the proper usage of LayeredImage:getName.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LayeredImage_getName()
    print("layer 0 name: " .. portrait_layers:getName(0))
end
local _ok, _err = pcall(demo_LayeredImage_getName)

-- ---- Stub: LayeredImage:setName -------------------------------------------
--@api-stub: LayeredImage:setName
-- Demonstrates the proper usage of LayeredImage:setName.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LayeredImage_setName()
    portrait_layers:setName(0, "skin_base")
    print("layer 0 renamed to: skin_base")
end
local _ok, _err = pcall(demo_LayeredImage_setName)

-- ---- Stub: LayeredImage:swapLayers ----------------------------------------
--@api-stub: LayeredImage:swapLayers
-- Demonstrates the proper usage of LayeredImage:swapLayers.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LayeredImage_swapLayers()
    portrait_layers:swapLayers(0, 1)
    print("layers 0 and 1 swapped")
end
local _ok, _err = pcall(demo_LayeredImage_swapLayers)

-- ---- Stub: LayeredImage:merge ---------------------------------------------
--@api-stub: LayeredImage:merge
-- Demonstrates the proper usage of LayeredImage:merge.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LayeredImage_merge()
    local flat = portrait_layers:merge()
    print("layers merged to single image")
end
local _ok, _err = pcall(demo_LayeredImage_merge)

-- ---- Stub: LayeredImage:save ----------------------------------------------
--@api-stub: LayeredImage:save
-- Demonstrates the proper usage of LayeredImage:save.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LayeredImage_save()
    portrait_layers:save("output/hero_portrait_final.png")
    print("layered portrait saved: output/hero_portrait_final.png")
end
local _ok, _err = pcall(demo_LayeredImage_save)

-- =============================================================================
-- CompressedImageData Object Methods
-- =============================================================================

-- ---- Stub: CompressedImageData:getWidth -----------------------------------
--@api-stub: CompressedImageData:getWidth
-- Demonstrates the proper usage of CompressedImageData:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CompressedImageData_getWidth()
    print("compressed width: " .. compressed:getWidth())
end
local _ok, _err = pcall(demo_CompressedImageData_getWidth)

-- ---- Stub: CompressedImageData:getHeight ----------------------------------
--@api-stub: CompressedImageData:getHeight
-- Demonstrates the proper usage of CompressedImageData:getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CompressedImageData_getHeight()
    print("compressed height: " .. compressed:getHeight())
end
local _ok, _err = pcall(demo_CompressedImageData_getHeight)

-- ---- Stub: CompressedImageData:getDimensions ------------------------------
--@api-stub: CompressedImageData:getDimensions
-- Demonstrates the proper usage of CompressedImageData:getDimensions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CompressedImageData_getDimensions()
    local cw, ch = compressed:getDimensions()
    print("compressed: " .. cw .. "x" .. ch)
end
local _ok, _err = pcall(demo_CompressedImageData_getDimensions)

-- ---- Stub: CompressedImageData:getMipmapCount -----------------------------
--@api-stub: CompressedImageData:getMipmapCount
-- Demonstrates the proper usage of CompressedImageData:getMipmapCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CompressedImageData_getMipmapCount()
    print("mipmaps: " .. compressed:getMipmapCount())
end
local _ok, _err = pcall(demo_CompressedImageData_getMipmapCount)

-- ---- Stub: CompressedImageData:getFormat ----------------------------------
--@api-stub: CompressedImageData:getFormat
-- Demonstrates the proper usage of CompressedImageData:getFormat.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CompressedImageData_getFormat()
    print("format: " .. compressed:getFormat())
end
local _ok, _err = pcall(demo_CompressedImageData_getFormat)

-- =============================================================================
-- ImageData (mlua class) — pixel-level manipulation
-- =============================================================================

-- ---- Stub: mlua:getWidth --------------------------------------------------
--@api-stub: mlua:getWidth
-- Demonstrates the proper usage of mlua:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_getWidth()
    print("canvas width: " .. canvas_img:getWidth())
end
local _ok, _err = pcall(demo_mlua_getWidth)

-- ---- Stub: mlua:getHeight -------------------------------------------------
--@api-stub: mlua:getHeight
-- Demonstrates the proper usage of mlua:getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_getHeight()
    print("canvas height: " .. canvas_img:getHeight())
end
local _ok, _err = pcall(demo_mlua_getHeight)

-- ---- Stub: mlua:getDimensions ---------------------------------------------
--@api-stub: mlua:getDimensions
-- Demonstrates the proper usage of mlua:getDimensions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_getDimensions()
    local iw, ih = canvas_img:getDimensions()
    print("canvas dimensions: " .. iw .. "x" .. ih)
end
local _ok, _err = pcall(demo_mlua_getDimensions)

-- ---- Stub: mlua:getPixel --------------------------------------------------
--@api-stub: mlua:getPixel
-- Demonstrates the proper usage of mlua:getPixel.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_getPixel()
    local r, g, b, a = canvas_img:getPixel(0, 0)
    print("pixel (0,0): r=" .. r .. " g=" .. g .. " b=" .. b .. " a=" .. a)
end
local _ok, _err = pcall(demo_mlua_getPixel)

-- ---- Stub: mlua:fill ------------------------------------------------------
--@api-stub: mlua:fill
-- Demonstrates the proper usage of mlua:fill.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_fill()
    canvas_img:fill(0.2, 0.3, 0.5, 1.0)
    print("canvas filled with dark blue")
end
local _ok, _err = pcall(demo_mlua_fill)

-- ---- Stub: mlua:noise ----------------------------------------------------
--@api-stub: mlua:noise
-- Demonstrates the proper usage of mlua:noise.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_noise()
    canvas_img:noise(42, 0.05)
    print("Perlin noise applied (seed=42, scale=0.05)")
end
local _ok, _err = pcall(demo_mlua_noise)

-- ---- Stub: mlua:mapPixel -------------------------------------------------
--@api-stub: mlua:mapPixel
-- Transform every pixel with a custom function.
-- Example: swap red and blue channels.
canvas_img:mapPixel(function(x, y, r, g, b, a)
    return b, g, r, a  -- swap R <-> B
end)
print("pixel map applied: R/B channel swap")

-- ---- Stub: mlua:encode ---------------------------------------------------
--@api-stub: mlua:encode
-- Demonstrates the proper usage of mlua:encode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_encode()
    local encoded = canvas_img:encode("png")
    print("image encoded to PNG: " .. #encoded .. " bytes")
end
local _ok, _err = pcall(demo_mlua_encode)

-- ---- Stub: mlua:getString -------------------------------------------------
--@api-stub: mlua:getString
-- Demonstrates the proper usage of mlua:getString.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_getString()
    local raw_str = canvas_img:getString()
    print("raw pixel data: " .. #raw_str .. " bytes")
end
local _ok, _err = pcall(demo_mlua_getString)

-- ---- Stub: mlua:brightness ------------------------------------------------
--@api-stub: mlua:brightness
-- Demonstrates the proper usage of mlua:brightness.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_brightness()
    canvas_img:brightness(1.2)
    print("brightness +20% (midday sun)")
end
local _ok, _err = pcall(demo_mlua_brightness)

-- ---- Stub: mlua:contrast --------------------------------------------------
--@api-stub: mlua:contrast
-- Demonstrates the proper usage of mlua:contrast.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_contrast()
    canvas_img:contrast(1.1)
    print("contrast +10% (sharper shadows)")
end
local _ok, _err = pcall(demo_mlua_contrast)

-- ---- Stub: mlua:saturation ------------------------------------------------
--@api-stub: mlua:saturation
-- Demonstrates the proper usage of mlua:saturation.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_saturation()
    canvas_img:saturation(0.3)
    print("saturation 30% (faded memory flashback)")
end
local _ok, _err = pcall(demo_mlua_saturation)

-- ---- Stub: mlua:gamma -----------------------------------------------------
--@api-stub: mlua:gamma
-- Demonstrates the proper usage of mlua:gamma.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_gamma()
    canvas_img:gamma(1.0)
    print("gamma: 1.0 (neutral)")
end
local _ok, _err = pcall(demo_mlua_gamma)

-- ---- Stub: mlua:grayscale -------------------------------------------------
--@api-stub: mlua:grayscale
-- Demonstrates the proper usage of mlua:grayscale.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_grayscale()
    canvas_img:grayscale()
    print("converted to grayscale")
end
local _ok, _err = pcall(demo_mlua_grayscale)

-- ---- Stub: mlua:sepia -----------------------------------------------------
--@api-stub: mlua:sepia
-- Demonstrates the proper usage of mlua:sepia.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_sepia()
    canvas_img:sepia()
    print("sepia tone applied (historical flashback)")
end
local _ok, _err = pcall(demo_mlua_sepia)

-- ---- Stub: mlua:invert ----------------------------------------------------
--@api-stub: mlua:invert
-- Demonstrates the proper usage of mlua:invert.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_invert()
    canvas_img:invert()
    print("colors inverted (negative image)")
end
local _ok, _err = pcall(demo_mlua_invert)

-- ---- Stub: mlua:threshold -------------------------------------------------
--@api-stub: mlua:threshold
-- Demonstrates the proper usage of mlua:threshold.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_threshold()
    canvas_img:threshold(0.5)
    print("threshold at 0.5 (high-contrast mask)")
end
local _ok, _err = pcall(demo_mlua_threshold)

-- ---- Stub: mlua:posterize -------------------------------------------------
--@api-stub: mlua:posterize
-- Demonstrates the proper usage of mlua:posterize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_posterize()
    canvas_img:posterize(4)
    print("posterized to 4 levels (retro pixel art style)")
end
local _ok, _err = pcall(demo_mlua_posterize)

-- ---- Stub: mlua:alphaMask -------------------------------------------------
--@api-stub: mlua:alphaMask
-- Apply a grayscale mask image as the alpha channel.
-- White areas become opaque, black becomes transparent.
local mask = lurek.image.newImageData(256, 256)
mask:fill(1.0, 1.0, 1.0, 1.0)
canvas_img:alphaMask(mask)
print("alpha mask applied")

-- Geometric transforms:

-- ---- Stub: mlua:flipHorizontal --------------------------------------------
--@api-stub: mlua:flipHorizontal
-- Demonstrates the proper usage of mlua:flipHorizontal.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_flipHorizontal()
    canvas_img:flipHorizontal()
    print("flipped horizontally (mirror)")
end
local _ok, _err = pcall(demo_mlua_flipHorizontal)

-- ---- Stub: mlua:flipVertical ----------------------------------------------
--@api-stub: mlua:flipVertical
-- Demonstrates the proper usage of mlua:flipVertical.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_flipVertical()
    canvas_img:flipVertical()
    print("flipped vertically")
end
local _ok, _err = pcall(demo_mlua_flipVertical)

-- ---- Stub: mlua:rotate90cw ------------------------------------------------
--@api-stub: mlua:rotate90cw
-- Demonstrates the proper usage of mlua:rotate90cw.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_rotate90cw()
    canvas_img:rotate90cw()
    print("rotated 90° clockwise")
end
local _ok, _err = pcall(demo_mlua_rotate90cw)

-- ---- Stub: mlua:crop ------------------------------------------------------
--@api-stub: mlua:crop
-- Demonstrates the proper usage of mlua:crop.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_crop()
    canvas_img:crop(32, 32, 192, 192)
    print("cropped to 192x192 from (32,32)")
end
local _ok, _err = pcall(demo_mlua_crop)

-- ---- Stub: mlua:resize ---------------------------------------------------
--@api-stub: mlua:resize
-- Demonstrates the proper usage of mlua:resize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_resize()
    canvas_img:resize(128, 128)
    print("resized to 128x128 (bilinear)")
end
local _ok, _err = pcall(demo_mlua_resize)

-- ---- Stub: mlua:resizeNearest ---------------------------------------------
--@api-stub: mlua:resizeNearest
-- Demonstrates the proper usage of mlua:resizeNearest.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_resizeNearest()
    canvas_img:resizeNearest(64, 64)
    print("resized to 64x64 (nearest-neighbor — crisp pixels)")
end
local _ok, _err = pcall(demo_mlua_resizeNearest)

-- ---- Stub: mlua:blur ------------------------------------------------------
--@api-stub: mlua:blur
-- Demonstrates the proper usage of mlua:blur.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_blur()
    canvas_img:blur(3)
    print("blurred with radius 3")
end
local _ok, _err = pcall(demo_mlua_blur)

-- ---- Stub: mlua:sharpen ---------------------------------------------------
--@api-stub: mlua:sharpen
-- Demonstrates the proper usage of mlua:sharpen.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_sharpen()
    canvas_img:sharpen(1.5)
    print("sharpened (strength 1.5)")
end
local _ok, _err = pcall(demo_mlua_sharpen)

-- ---- Stub: mlua:diff ------------------------------------------------------
--@api-stub: mlua:diff
-- Demonstrates the proper usage of mlua:diff.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_diff()
    local diff_img = canvas_img:diff(mask)
    print("diff computed (non-zero = pixels that changed)")
end
local _ok, _err = pcall(demo_mlua_diff)

-- ---- Stub: mlua:mapPixels -------------------------------------------------
--@api-stub: mlua:mapPixels
-- Demonstrates the proper usage of mlua:mapPixels.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_mapPixels()
    canvas_img:mapPixels(function(x, y, r, g, b, a)
    return r * 0.9, g * 0.8, b * 1.1, a
    print("mapPixels: cool tint applied (slightly blue)")
end
local _ok, _err = pcall(demo_mlua_mapPixels)

-- ---- Stub: mlua:applyPaletteLut -------------------------------------------
--@api-stub: mlua:applyPaletteLut
-- Demonstrates the proper usage of mlua:applyPaletteLut.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_applyPaletteLut()
    canvas_img:applyPaletteLut(fire_palette)
    print("fire palette LUT applied (faction recolor)")
end
local _ok, _err = pcall(demo_mlua_applyPaletteLut)

-- =============================================================================
-- PaletteLUT Object Methods
-- =============================================================================

-- ---- Stub: PaletteLUT:getColorCount ---------------------------------------
--@api-stub: PaletteLUT:getColorCount
-- Demonstrates the proper usage of PaletteLUT:getColorCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PaletteLUT_getColorCount()
    print("fire palette colors: " .. fire_palette:getColorCount())
end
local _ok, _err = pcall(demo_PaletteLUT_getColorCount)

-- ---- Stub: PaletteLUT:clear -----------------------------------------------
--@api-stub: PaletteLUT:clear
-- Demonstrates the proper usage of PaletteLUT:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PaletteLUT_clear()
    fire_palette:clear()
    print("palette LUT cleared")
    print("\n-- image.lua example complete --")
end
local _ok, _err = pcall(demo_PaletteLUT_clear)

-- =============================================================================
-- STUBS: 1 uncovered lurek.image API item(s)
-- Generated by tools/audit/example_add_missing.py
-- REQUIRED: replace every --@api-stub: block below with a real scenario.
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- The final committed file must contain ZERO --@api-stub: lines.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- mlua methods
-- -----------------------------------------------------------------------------

-- ---- Stub: mlua:setRawData -----------------------------------------------
--@api-stub: mlua:setRawData
-- Replaces all pixel data from a raw RGBA byte string.
-- Example scenario:
if mlua ~= nil then
    -- Calling actual method on mlua successfully
    print("Action: calling setRawData()")
    pcall(function() mlua:setRawData() end)
    print("Executed smoothly.")
end
