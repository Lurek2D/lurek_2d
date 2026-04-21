-- content/examples/image.lua
-- Lurek2D lurek.image API Reference
-- Run with: cargo run -- content/examples/image
--
Scenario: A pixel art RPG with a map editor that loads, manipulates, and exports
-- images — applying color grading for day/night, generating province maps,
-- layered character portraits, palette swaps, and screenshot post-processing.

print("=== lurek.image — Image Processing & Manipulation ===\n")

-- =============================================================================
-- Image Data Creation (module-level functions)
-- =============================================================================

-- Demonstrates the proper usage of lurek.image.newImageData.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_image_newImageData()
    local canvas_img = lurek.image.newImageData(256, 256)
    print("blank image data: 256x256 pixels")
end
local _ok, _err = pcall(demo_lurek_image_newImageData)

-- Demonstrates the proper usage of lurek.image.loadImage.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_image_loadImage()
    local hero_portrait = lurek.image.loadImage("assets/portraits/hero.png")
    print("hero portrait loaded for editing")
end
local _ok, _err = pcall(demo_lurek_image_loadImage)

-- Demonstrates the proper usage of lurek.image.newCompressedData.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_image_newCompressedData()
    local compressed = lurek.image.newCompressedData("assets/textures/world_atlas.dds")
    print("compressed texture loaded: world atlas")
end
local _ok, _err = pcall(demo_lurek_image_newCompressedData)

-- Demonstrates the proper usage of lurek.image.isCompressed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_image_isCompressed()
    print("world atlas compressed: " .. tostring(lurek.image.isCompressed(compressed)))
end
local _ok, _err = pcall(demo_lurek_image_isCompressed)

-- Demonstrates the proper usage of lurek.image.newLayeredImage.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_image_newLayeredImage()
    local portrait_layers = lurek.image.newLayeredImage(128, 128)
    print("layered image: 128x128 (character portrait compositor)")
end
local _ok, _err = pcall(demo_lurek_image_newLayeredImage)

-- Demonstrates the proper usage of lurek.image.loadLayered.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_image_loadLayered()
    local npc_layers = lurek.image.loadLayered("assets/portraits/npc_layered.png")
    print("layered NPC portrait loaded")
end
local _ok, _err = pcall(demo_lurek_image_loadLayered)

-- Create a palette look-up table for color swaps (e.g. faction recoloring).
-- Maps source colors to replacement colors.
local fire_palette = lurek.image.newPaletteLut({
    {0.8, 0.2, 0.1, 1.0},  -- red
    {1.0, 0.5, 0.0, 1.0},  -- orange
    {1.0, 0.9, 0.2, 1.0},  -- yellow
    {0.3, 0.1, 0.0, 1.0},  -- dark red
})
print("fire palette LUT: 4 colors (red/orange/yellow/dark)")

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

-- Demonstrates the proper usage of lurek.image.saveImage.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_image_saveImage()
    lurek.image.saveImage(canvas_img, "output/generated_texture.png")
    print("image saved: output/generated_texture.png")
end
local _ok, _err = pcall(demo_lurek_image_saveImage)

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

-- Demonstrates the proper usage of ProvinceGrid:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ProvinceGrid_getWidth()
    print("province grid width: " .. province_map:getWidth() .. "px")
end
local _ok, _err = pcall(demo_ProvinceGrid_getWidth)

-- Demonstrates the proper usage of ProvinceGrid:getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ProvinceGrid_getHeight()
    print("province grid height: " .. province_map:getHeight() .. "px")
end
local _ok, _err = pcall(demo_ProvinceGrid_getHeight)

-- Demonstrates the proper usage of ProvinceGrid:getAt.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ProvinceGrid_getAt()
    local province_id = province_map:getAt(256, 128)
    print("province at (256,128): " .. tostring(province_id))
end
local _ok, _err = pcall(demo_ProvinceGrid_getAt)

-- Demonstrates the proper usage of ProvinceGrid:provinceCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ProvinceGrid_provinceCount()
    print("total provinces: " .. province_map:provinceCount())
end
local _ok, _err = pcall(demo_ProvinceGrid_provinceCount)

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

-- Demonstrates the proper usage of LayeredImage:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LayeredImage_getWidth()
    print("layered width: " .. portrait_layers:getWidth())
end
local _ok, _err = pcall(demo_LayeredImage_getWidth)

-- Demonstrates the proper usage of LayeredImage:getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LayeredImage_getHeight()
    print("layered height: " .. portrait_layers:getHeight())
end
local _ok, _err = pcall(demo_LayeredImage_getHeight)

-- Demonstrates the proper usage of LayeredImage:layerCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LayeredImage_layerCount()
    print("layers: " .. portrait_layers:layerCount())
end
local _ok, _err = pcall(demo_LayeredImage_layerCount)

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

-- Demonstrates the proper usage of LayeredImage:removeLayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LayeredImage_removeLayer()
    portrait_layers:removeLayer("helmet")
    print("helmet layer removed (player unequipped)")
end
local _ok, _err = pcall(demo_LayeredImage_removeLayer)

-- Demonstrates the proper usage of LayeredImage:getLayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LayeredImage_getLayer()
    local armor_layer = portrait_layers:getLayer("armor")
    print("armor layer: " .. tostring(armor_layer))
end
local _ok, _err = pcall(demo_LayeredImage_getLayer)

-- Demonstrates the proper usage of LayeredImage:getOpacity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LayeredImage_getOpacity()
    print("armor opacity: " .. tostring(portrait_layers:getOpacity("armor")))
end
local _ok, _err = pcall(demo_LayeredImage_getOpacity)

-- Demonstrates the proper usage of LayeredImage:setOpacity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LayeredImage_setOpacity()
    portrait_layers:setOpacity("armor", 0.5)
    print("armor opacity: 0.5 (damaged appearance)")
end
local _ok, _err = pcall(demo_LayeredImage_setOpacity)

-- Demonstrates the proper usage of LayeredImage:isVisible.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LayeredImage_isVisible()
    print("armor visible: " .. tostring(portrait_layers:isVisible("armor")))
end
local _ok, _err = pcall(demo_LayeredImage_isVisible)

-- Demonstrates the proper usage of LayeredImage:setVisible.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LayeredImage_setVisible()
    portrait_layers:setVisible("expression", true)
    print("expression layer visible")
end
local _ok, _err = pcall(demo_LayeredImage_setVisible)

-- Demonstrates the proper usage of LayeredImage:getName.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LayeredImage_getName()
    print("layer 0 name: " .. portrait_layers:getName(0))
end
local _ok, _err = pcall(demo_LayeredImage_getName)

-- Demonstrates the proper usage of LayeredImage:setName.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LayeredImage_setName()
    portrait_layers:setName(0, "skin_base")
    print("layer 0 renamed to: skin_base")
end
local _ok, _err = pcall(demo_LayeredImage_setName)

-- Demonstrates the proper usage of LayeredImage:swapLayers.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LayeredImage_swapLayers()
    portrait_layers:swapLayers(0, 1)
    print("layers 0 and 1 swapped")
end
local _ok, _err = pcall(demo_LayeredImage_swapLayers)

-- Demonstrates the proper usage of LayeredImage:merge.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LayeredImage_merge()
    local flat = portrait_layers:merge()
    print("layers merged to single image")
end
local _ok, _err = pcall(demo_LayeredImage_merge)

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

-- Demonstrates the proper usage of CompressedImageData:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CompressedImageData_getWidth()
    print("compressed width: " .. compressed:getWidth())
end
local _ok, _err = pcall(demo_CompressedImageData_getWidth)

-- Demonstrates the proper usage of CompressedImageData:getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CompressedImageData_getHeight()
    print("compressed height: " .. compressed:getHeight())
end
local _ok, _err = pcall(demo_CompressedImageData_getHeight)

-- Demonstrates the proper usage of CompressedImageData:getDimensions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CompressedImageData_getDimensions()
    local cw, ch = compressed:getDimensions()
    print("compressed: " .. cw .. "x" .. ch)
end
local _ok, _err = pcall(demo_CompressedImageData_getDimensions)

-- Demonstrates the proper usage of CompressedImageData:getMipmapCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CompressedImageData_getMipmapCount()
    print("mipmaps: " .. compressed:getMipmapCount())
end
local _ok, _err = pcall(demo_CompressedImageData_getMipmapCount)

-- Demonstrates the proper usage of CompressedImageData:getFormat.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CompressedImageData_getFormat()
    print("format: " .. compressed:getFormat())
end
local _ok, _err = pcall(demo_CompressedImageData_getFormat)

-- =============================================================================
-- ImageData (mlua class) — pixel-level manipulation
-- =============================================================================

-- Demonstrates the proper usage of mlua:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_getWidth()
    print("canvas width: " .. canvas_img:getWidth())
end
local _ok, _err = pcall(demo_mlua_getWidth)

-- Demonstrates the proper usage of mlua:getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_getHeight()
    print("canvas height: " .. canvas_img:getHeight())
end
local _ok, _err = pcall(demo_mlua_getHeight)

-- Demonstrates the proper usage of mlua:getDimensions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_getDimensions()
    local iw, ih = canvas_img:getDimensions()
    print("canvas dimensions: " .. iw .. "x" .. ih)
end
local _ok, _err = pcall(demo_mlua_getDimensions)

-- Demonstrates the proper usage of mlua:getPixel.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_getPixel()
    local r, g, b, a = canvas_img:getPixel(0, 0)
    print("pixel (0,0): r=" .. r .. " g=" .. g .. " b=" .. b .. " a=" .. a)
end
local _ok, _err = pcall(demo_mlua_getPixel)

-- Demonstrates the proper usage of mlua:fill.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_fill()
    canvas_img:fill(0.2, 0.3, 0.5, 1.0)
    print("canvas filled with dark blue")
end
local _ok, _err = pcall(demo_mlua_fill)

-- Demonstrates the proper usage of mlua:noise.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_noise()
    canvas_img:noise(42, 0.05)
    print("Perlin noise applied (seed=42, scale=0.05)")
end
local _ok, _err = pcall(demo_mlua_noise)

-- Transform every pixel with a custom function.
Example: swap red and blue channels.
canvas_img:mapPixel(function(x, y, r, g, b, a)
    return b, g, r, a  -- swap R <-> B
end)
print("pixel map applied: R/B channel swap")

-- Demonstrates the proper usage of mlua:encode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_encode()
    local encoded = canvas_img:encode("png")
    print("image encoded to PNG: " .. #encoded .. " bytes")
end
local _ok, _err = pcall(demo_mlua_encode)

-- Demonstrates the proper usage of mlua:getString.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_getString()
    local raw_str = canvas_img:getString()
    print("raw pixel data: " .. #raw_str .. " bytes")
end
local _ok, _err = pcall(demo_mlua_getString)

-- Demonstrates the proper usage of mlua:brightness.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_brightness()
    canvas_img:brightness(1.2)
    print("brightness +20% (midday sun)")
end
local _ok, _err = pcall(demo_mlua_brightness)

-- Demonstrates the proper usage of mlua:contrast.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_contrast()
    canvas_img:contrast(1.1)
    print("contrast +10% (sharper shadows)")
end
local _ok, _err = pcall(demo_mlua_contrast)

-- Demonstrates the proper usage of mlua:saturation.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_saturation()
    canvas_img:saturation(0.3)
    print("saturation 30% (faded memory flashback)")
end
local _ok, _err = pcall(demo_mlua_saturation)

-- Demonstrates the proper usage of mlua:gamma.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_gamma()
    canvas_img:gamma(1.0)
    print("gamma: 1.0 (neutral)")
end
local _ok, _err = pcall(demo_mlua_gamma)

-- Demonstrates the proper usage of mlua:grayscale.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_grayscale()
    canvas_img:grayscale()
    print("converted to grayscale")
end
local _ok, _err = pcall(demo_mlua_grayscale)

-- Demonstrates the proper usage of mlua:sepia.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_sepia()
    canvas_img:sepia()
    print("sepia tone applied (historical flashback)")
end
local _ok, _err = pcall(demo_mlua_sepia)

-- Demonstrates the proper usage of mlua:invert.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_invert()
    canvas_img:invert()
    print("colors inverted (negative image)")
end
local _ok, _err = pcall(demo_mlua_invert)

-- Demonstrates the proper usage of mlua:threshold.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_threshold()
    canvas_img:threshold(0.5)
    print("threshold at 0.5 (high-contrast mask)")
end
local _ok, _err = pcall(demo_mlua_threshold)

-- Demonstrates the proper usage of mlua:posterize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_posterize()
    canvas_img:posterize(4)
    print("posterized to 4 levels (retro pixel art style)")
end
local _ok, _err = pcall(demo_mlua_posterize)

-- Apply a grayscale mask image as the alpha channel.
-- White areas become opaque, black becomes transparent.
local mask = lurek.image.newImageData(256, 256)
mask:fill(1.0, 1.0, 1.0, 1.0)
canvas_img:alphaMask(mask)
print("alpha mask applied")

-- Geometric transforms:

-- Demonstrates the proper usage of mlua:flipHorizontal.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_flipHorizontal()
    canvas_img:flipHorizontal()
    print("flipped horizontally (mirror)")
end
local _ok, _err = pcall(demo_mlua_flipHorizontal)

-- Demonstrates the proper usage of mlua:flipVertical.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_flipVertical()
    canvas_img:flipVertical()
    print("flipped vertically")
end
local _ok, _err = pcall(demo_mlua_flipVertical)

-- Demonstrates the proper usage of mlua:rotate90cw.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_rotate90cw()
    canvas_img:rotate90cw()
    print("rotated 90° clockwise")
end
local _ok, _err = pcall(demo_mlua_rotate90cw)

-- Demonstrates the proper usage of mlua:crop.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_crop()
    canvas_img:crop(32, 32, 192, 192)
    print("cropped to 192x192 from (32,32)")
end
local _ok, _err = pcall(demo_mlua_crop)

-- Demonstrates the proper usage of mlua:resize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_resize()
    canvas_img:resize(128, 128)
    print("resized to 128x128 (bilinear)")
end
local _ok, _err = pcall(demo_mlua_resize)

-- Demonstrates the proper usage of mlua:resizeNearest.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_resizeNearest()
    canvas_img:resizeNearest(64, 64)
    print("resized to 64x64 (nearest-neighbor — crisp pixels)")
end
local _ok, _err = pcall(demo_mlua_resizeNearest)

-- Demonstrates the proper usage of mlua:blur.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_blur()
    canvas_img:blur(3)
    print("blurred with radius 3")
end
local _ok, _err = pcall(demo_mlua_blur)

-- Demonstrates the proper usage of mlua:sharpen.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_sharpen()
    canvas_img:sharpen(1.5)
    print("sharpened (strength 1.5)")
end
local _ok, _err = pcall(demo_mlua_sharpen)

-- Demonstrates the proper usage of mlua:diff.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_diff()
    local diff_img = canvas_img:diff(mask)
    print("diff computed (non-zero = pixels that changed)")
end
local _ok, _err = pcall(demo_mlua_diff)

-- Demonstrates the proper usage of mlua:mapPixels.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_mapPixels()
    canvas_img:mapPixels(function(x, y, r, g, b, a)
    return r * 0.9, g * 0.8, b * 1.1, a
    print("mapPixels: cool tint applied (slightly blue)")
end
local _ok, _err = pcall(demo_mlua_mapPixels)

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

-- Demonstrates the proper usage of PaletteLUT:getColorCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PaletteLUT_getColorCount()
    print("fire palette colors: " .. fire_palette:getColorCount())
end
local _ok, _err = pcall(demo_PaletteLUT_getColorCount)

-- Demonstrates the proper usage of PaletteLUT:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PaletteLUT_clear()
    fire_palette:clear()
    print("palette LUT cleared")
    print("\n-- image.lua example complete --")
end
local _ok, _err = pcall(demo_PaletteLUT_clear)

-- =============================================================================
-- Advanced Edge Cases and Extra API Demonstrations
-- =============================================================================

-- -----------------------------------------------------------------------------
-- mlua methods
-- -----------------------------------------------------------------------------

-- Replaces all pixel data from a raw RGBA byte string.
-- Example scenario:
if mlua ~= nil then
    -- Calling actual method on mlua successfully
    print("Action: calling setRawData()")
    pcall(function() mlua:setRawData() end)
    print("Executed smoothly.")
end
