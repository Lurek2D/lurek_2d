# Image

## Purpose

Manages CPU image buffers, compressed textures, layered stacks, palette remapping, and atlases.

## When To Use

- Its role is broader than ordinary file loading. Raw buffers, filters, resizing, layers, palettes, atlas packing, drawing helpers, visualization output, and serialization all live here because real image workflows usually chain several of those operations together.
- This breadth matters because many projects need to do image work inside the engine, not only before runtime in an external editor. Asset preparation, theme variation, generated visuals, screenshots, comparison tests, and data extraction can all depend on image processing.
- Layer support is especially important for tooling and content workflows where staged or partially non-destructive composition is useful.

## Minimal Example

Example block: `lurek.image.newImageData`

```lua
do
    local img = lurek.image.newImageData(128, 64)
    img:fill(20, 30, 60, 255)
    local w, h = img:getDimensions()
    local raw = img:getRawBytes()
    image_log("blank minimap canvas " .. w .. "x" .. h .. " bytes=" .. #raw)
end
```

## Common Patterns

- Start with `lurek.image.fromScreen` when exploring this module.
- Start with `lurek.image.isCompressed` when exploring this module.
- Start with `lurek.image.loadImage` when exploring this module.
- Start with `lurek.image.loadLayered` when exploring this module.
- Start with `lurek.image.newCompressedData` when exploring this module.

## API Reference

- This page is the generated API reference for this module.

## Summary

- The `image` module is the engine's CPU-side image workbench for users who need pixel data to be loaded, transformed, composed, inspected, compared, and exported under one coherent API.
- Its role is broader than ordinary file loading. Raw buffers, filters, resizing, layers, palettes, atlas packing, drawing helpers, visualization output, and serialization all live here because real image workflows usually chain several of those operations together.
- This breadth matters because many projects need to do image work inside the engine, not only before runtime in an external editor. Asset preparation, theme variation, generated visuals, screenshots, comparison tests, and data extraction can all depend on image processing.
- Layer support is especially important for tooling and content workflows where staged or partially non-destructive composition is useful.
- Color and tone operations expand the module into style control, while filter kernels and geometric transforms make it practical for more technical pixel-space workflows such as resampling, blur-like effects, and rotation.
- Atlas and texture-preparation helpers are critical from a runtime perspective because many images become packed regions, sprite sources, UI textures, or render-ready assets rather than staying as isolated files.
- This makes the module a bridge between authored content and render consumption. `render` eventually uses the resulting textures, but `image` owns the CPU-side transformations that prepare and validate them.
- Comparison and diff-style helpers turn the module into a testing and evidence surface, and visualization support makes it useful for diagnostics as well as assets.
- Visualization support is one of the most distinctive capabilities. Audio analysis, graph structures, easing curves, procedural outputs, camera data, and other runtime information can all be turned into inspectable images, making the module useful for debugging as well as for asset work.
- Province and grid extraction features show that image data can also be a source of gameplay structure. A picture may become region data, mask data, or map guidance rather than only something to display.
- That two-way relationship is important: `image` is useful both after a visual asset exists and when visual data is being used as input to another system.
- Serialization and format conversion keep the module connected to the outside world. The same subsystem can move between files, generated runtime state, debugging artifacts, and exported outputs without pushing those conversions into ad hoc helpers.
- That flexibility also makes the module useful for tool-driven inspection as well as asset preparation.
- This makes the module useful across the whole asset lifecycle: load, inspect, transform, compare, pack, export, and sometimes reinterpret as data for another system.
- `render` consumes prepared results, but `image` owns pixel-domain manipulation, inspection, packing, and export before or outside final rendering.
- Read `image` as the engine's pixel-domain authority for asset prep and tooling.

This module primarily collaborates with `animation`, `camera`, `color`, `math`, `province`, `render`, `runtime`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.image.fromScreen`

Returns a completed screen capture image or requests one for a future call.

```lua
lurek.image.fromScreen()
```

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | nil | `[LImageData](#limagedata)` when capture data is ready, or nil after requesting capture. |

**Example**

```lua
do
    local capture = lurek.image.fromScreen()
    local status = capture and (capture:getWidth() .. "x" .. capture:getHeight()) or "not ready yet"
    local sampled_alpha = capture and select(4, capture:getPixel(0, 0)) or -1
    local mode = lurek.render.getBlendMode()
    image_log("screen capture " .. status .. " alpha=" .. sampled_alpha .. " blend=" .. mode)
end
```

---

### `lurek.image.isCompressed`

Returns whether a GameFS image file begins with DDS compressed image magic bytes.

```lua
lurek.image.isCompressed(filename)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `filename` | string | GameFS path to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the file appears to be DDS compressed data. |

**Example**

```lua
do
    local dds_path = "content/examples/assets/images/sample_normal.dds"
    local png_path = "content/examples/assets/images/sample_texture.png"
    local dds = lurek.image.isCompressed(dds_path)
    local png = lurek.image.isCompressed(png_path)
    local cdata = lurek.image.newCompressedData(dds_path)
    local fmt = cdata:getFormat()
    image_log("dds=" .. tostring(dds) .. " png=" .. tostring(png) .. " format=" .. fmt)
end
```

---

### `lurek.image.loadImage`

Loads and decodes image data from GameFS.

```lua
lurek.image.loadImage(filename)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `filename` | string | GameFS path to an encoded image. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Loaded image data handle. |

**Example**

```lua
do
    local src = lurek.image.newImageData(8, 8)
    src:fill(255, 0, 0, 255)
    lurek.image.saveImage(src, "save/sample_image.limg")
    local img = lurek.image.loadImage("save/sample_image.limg")
    example_print_log("loaded image " .. img:getWidth() .. "x" .. img:getHeight())
end
```

---

### `lurek.image.loadLayered`

Loads a serialized layered image stack from GameFS.

```lua
lurek.image.loadLayered(filename)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `filename` | string | GameFS path to the layered image file. |

**Returns**

| Type | Description |
|------|-------------|
| [LLayeredImage](#llayeredimage) | Loaded layered image handle. |

**Example**

```lua
do
    local path = "content/examples/assets/sample_layered.limg"
    local loaded = lurek.image.loadLayered(path)
    local count = loaded:layerCount()
    local w, h = loaded:getWidth(), loaded:getHeight()
    image_log("loaded layered=" .. tostring(loaded ~= nil) .. " size=" .. w .. "x" .. h .. " layers=" .. count)
end
```

---

### `lurek.image.newCompressedData`

Loads DDS compressed image data from GameFS.

```lua
lurek.image.newCompressedData(filename)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `filename` | string | GameFS path to a DDS file. |

**Returns**

| Type | Description |
|------|-------------|
| [LCompressedImageData](#lcompressedimagedata) | New compressed image data handle. |

**Example**

```lua
do
    local cdata = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    local w, h = cdata:getDimensions()
    local fmt = cdata:getFormat()
    local mips = cdata:getMipmapCount()
    image_log("compressed " .. w .. "x" .. h .. " format=" .. fmt .. " mips=" .. mips)
end
```

---

### `lurek.image.newImageData`

Creates empty image data from dimensions or decodes image data from a GameFS filename.

```lua
lurek.image.newImageData(width_or_filename, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width_or_filename` | number|string | Width in pixels for a blank canvas, or a GameFS filename string to load from disk. |
| `height?` | number | Height in pixels; required when the first argument is a width integer. Omit when loading from filename. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | New image data handle. |

**Example**

```lua
do
    local img = lurek.image.newImageData(128, 64)
    img:fill(20, 30, 60, 255)
    local w, h = img:getDimensions()
    local raw = img:getRawBytes()
    image_log("blank minimap canvas " .. w .. "x" .. h .. " bytes=" .. #raw)
end
```

---

### `lurek.image.newImageDataFromBytes`

Creates image data from raw RGBA bytes and explicit dimensions.

```lua
lurek.image.newImageDataFromBytes(w, h, bytes)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Width in pixels. |
| `h` | number | Height in pixels. |
| `bytes` | string | Raw RGBA byte string. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | New image data handle. |

**Example**

```lua
do
    local bytes = string.rep("\255\0\0\255", 4)
    local img = lurek.image.newImageDataFromBytes(2, 2, bytes)
    local w, h = img:getDimensions()
    local r, g, b, a = img:getPixel(0, 0)
    image_log("from bytes " .. w .. "x" .. h .. " first=" .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

### `lurek.image.newLayeredImage`

Creates a layered image stack with one or more blank layers.

```lua
lurek.image.newLayeredImage(width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Width in pixels. |
| `height` | number | Height in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| [LLayeredImage](#llayeredimage) | New layered image handle. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(256, 256)
    local idx = li:addLayer("paint")
    local paint = li:getLayer(idx)
    paint:drawRect(32, 32, 192, 192, 255, 210, 80, 255)
    local w, h = li:getWidth(), li:getHeight()
    local sample = select(1, paint:getPixel(40, 40))
    image_log("layered " .. w .. "x" .. h .. " layers=" .. li:layerCount() .. " last=" .. idx .. " sample_r=" .. sample)
end
```

---

### `lurek.image.newPaletteLut`

Creates an empty palette lookup table.

```lua
lurek.image.newPaletteLut()
```

**Returns**

| Type | Description |
|------|-------------|
| [LPaletteLUT](#lpalettelut) | New palette lookup table handle. |

**Example**

```lua
do
    local lut = lurek.image.newPaletteLut()
    lut:setColor(255, 0, 0, 255, 255, 255, 0, 255)
    lut:setColor(0, 0, 255, 255, 120, 220, 255, 255)
    local count = lut:getColorCount()
    local kind = lut:type()
    image_log("palette LUT colors = " .. count .. " type=" .. kind)
end
```

---

### `lurek.image.newProvinceGrid`

Loads a province id grid from an image file under the current game directory.

```lua
lurek.image.newProvinceGrid(filename)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `filename` | string | Province map image filename relative to game directory. |

**Returns**

| Type | Description |
|------|-------------|
| [LProvinceGrid](#lprovincegrid) | New province grid handle. |

**Example**

```lua
do
    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local w, h = grid:getWidth(), grid:getHeight()
    local provinces = grid:provinceCount()
    local sample = grid:getAt(10, 10)
    image_log("province grid " .. w .. "x" .. h .. " provinces=" .. provinces .. " sample=" .. sample)
end
```

---

### `lurek.image.saveGIF`

Encodes a sequence of equally sized image frames as an animated GIF.

```lua
lurek.image.saveGIF(frames, filename, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `frames` | table | Array of `[LImageData](#limagedata)` frames in playback order. |
| `filename` | string | Output filename relative to the current game directory. |
| `opts?` | table | Optional GIF settings such as `delayMs`, `speed`, `loop`, or `loopCount`. |

**Example**

```lua
do
    local frames = {}

    local a = lurek.image.newImageData(32, 32)
    a:fill(20, 30, 60, 255)
    a:drawCircle(10, 16, 6, 255, 210, 80, 255)
    frames[1] = a

    local b = lurek.image.newImageData(32, 32)
    b:fill(20, 30, 60, 255)
    b:drawCircle(22, 16, 6, 80, 210, 255, 255)
    frames[2] = b

    lurek.image.saveGIF(frames, "save/two_frame_orb.gif", { delayMs = 120, speed = 10 })
    example_print_log("saved GIF")
end
```

---

### `lurek.image.saveImage`

Saves an image data object to a path under the current game directory.

```lua
lurek.image.saveImage(img_ud, filename)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `img_ud` | [LImageData](#limagedata) | Image data handle to save. |
| `filename` | string | Output filename relative to game directory. |

**Example**

```lua
do
    local img = lurek.image.newImageData(32, 32)
    img:fill(255, 0, 0, 255)
    img:drawRect(8, 8, 16, 16, 255, 255, 255, 255)
    lurek.image.saveImage(img, "save/red_square.limg")
    local raw = img:getRawBytes()
    image_log("saved limg bytes=" .. #raw)
end
```

---

### `lurek.image.savePNG`

Encodes image data as PNG and writes it under the current game directory.

```lua
lurek.image.savePNG(img_ud, filename)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `img_ud` | [LImageData](#limagedata) | Image data handle to encode. |
| `filename` | string | Output filename relative to game directory. |

**Example**

```lua
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(0, 255, 0, 255)
    img:drawCircle(8, 8, 4, 255, 255, 255, 255)
    lurek.image.savePNG(img, "save/green_square.png")
    local encoded = img:encode("png")
    image_log("saved png bytes=" .. #encoded)
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LCompressedImageData](#lcompressedimagedata)
- [LImageData](#limagedata)
- [LLayeredImage](#llayeredimage)
- [LPaletteLUT](#lpalettelut)
- [LProvinceGrid](#lprovincegrid)

## LCompressedImageData

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LCompressedImageData:getDimensions`

Returns compressed image dimensions.

```lua
LCompressedImageData:getDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels. |
| number | Height in pixels. |

**Example**

```lua
do
    local cdata = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    local w, h = cdata:getDimensions()
    local fmt = cdata:getFormat()
    local mips = cdata:getMipmapCount()
    example_print_log("compressed = " .. w .. "x" .. h)
end
```

---

#### `LCompressedImageData:getFormat`

Returns the compressed image format name.

```lua
LCompressedImageData:getFormat()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Format name. |

**Example**

```lua
do
    local cdata = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    local w = cdata:getWidth()
    local h = cdata:getHeight()
    local mips = cdata:getMipmapCount()
    example_print_log("format = " .. cdata:getFormat())
end
```

---

#### `LCompressedImageData:getHeight`

Returns compressed image height. This method is available to Lua scripts.

```lua
LCompressedImageData:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Height in pixels. |

**Example**

```lua
do
    local cd = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    local w = cd:getWidth()
    local h = cd:getHeight()
    local mips = cd:getMipmapCount()
    example_print_log("compressed w=" .. w .. " h=" .. h .. " mips=" .. mips)
end
```

---

#### `LCompressedImageData:getMipmapCount`

Returns the number of mipmap levels in this compressed image.

```lua
LCompressedImageData:getMipmapCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Mipmap level count. |

**Example**

```lua
do
    local cdata = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    local fmt = cdata:getFormat()
    local w = cdata:getWidth()
    local h = cdata:getHeight()
    example_print_log("mipmaps = " .. cdata:getMipmapCount())
end
```

---

#### `LCompressedImageData:getWidth`

Returns compressed image width. This method is available to Lua scripts.

```lua
LCompressedImageData:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels. |

**Example**

```lua
do
    local cd = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    local w = cd:getWidth()
    local h = cd:getHeight()
    local mips = cd:getMipmapCount()
    example_print_log("compressed w=" .. w .. " h=" .. h .. " mips=" .. mips)
end
```

---

#### `LCompressedImageData:type`

Returns the Lua-visible type name for this compressed image handle.

```lua
LCompressedImageData:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LCompressedImageData](#lcompressedimagedata)`. |

**Example**

```lua
do
    local cdata = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    local fmt = cdata:getFormat()
    local w = cdata:getWidth()
    example_print_log("type = " .. cdata:type())
    example_print_log("is CompressedImageData = " .. tostring(cdata:typeOf("LCompressedImageData")))
end
```

---

#### `LCompressedImageData:typeOf`

Returns whether this compressed image handle matches a supported type name.

```lua
LCompressedImageData:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LCompressedImageData](#lcompressedimagedata)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local cdata = lurek.image.newCompressedData("content/examples/assets/images/sample_normal.dds")
    local fmt = cdata:getFormat()
    local is_object = cdata:typeOf("LObject")
    example_print_log("type = " .. cdata:type())
    example_print_log("is CompressedImageData = " .. tostring(cdata:typeOf("LCompressedImageData")))
end
```

---

## LImageData

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LImageData:alphaMask`

Multiplies this image alpha channel by a factor in place.

```lua
LImageData:alphaMask(factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `factor` | number | Alpha multiplier. |

**Example**

```lua
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(255, 0, 0, 255)
    img:alphaMask(0.5)
    local _, _, _, a = img:getPixel(0, 0)
    example_print_log("alpha = " .. a)
end
```

---

#### `LImageData:applyPaletteLut`

Applies a palette lookup table to this image in place.

```lua
LImageData:applyPaletteLut(lut_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `lut_ud` | [LPaletteLUT](#lpalettelut) | Palette lookup table handle. |

**Example**

```lua
do
    local img = lurek.image.newImageData(16, 16)
    local lut = lurek.image.newPaletteLut()
    img:fill(255, 0, 0, 255)
    lut:setColor(255, 0, 0, 255, 0, 255, 0, 255)
    lut:setColor(0, 0, 255, 255, 255, 255, 255, 255)
    local count = lut:getColorCount()
    local kind = lut:type()
    img:applyPaletteLut(lut)
    example_print_log("palette LUT applied")
end
```

---

#### `LImageData:blit`

Copies a source image into this image at a destination coordinate.

```lua
LImageData:blit(src_ud, dst_x, dst_y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `src_ud` | [LImageData](#limagedata) | Source image data handle. |
| `dst_x` | number | Destination x coordinate. |
| `dst_y` | number | Destination y coordinate. |

**Example**

```lua
do
    local dst = lurek.image.newImageData(64, 64)
    local src = lurek.image.newImageData(16, 16)
    src:fill(255, 255, 0, 255)
    dst:blit(src, 10, 10)
    example_print_log("blitted")
end
```

---

#### `LImageData:blur`

Returns a blurred copy of this image.

```lua
LImageData:blur(radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `radius` | number | Blur radius. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Blurred image data handle. |

**Example**

```lua
do
    local img = lurek.image.newImageData(64, 64)
    img:fill(255, 0, 0, 255)
    local blurred = img:blur(3)
    local r, g, b, a = blurred:getPixel(0, 0)
    image_log("blurred " .. blurred:getWidth() .. "x" .. blurred:getHeight() .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LImageData:brightness`

Applies a brightness factor to this image in place.

```lua
LImageData:brightness(factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `factor` | number | Brightness multiplier or adjustment factor. |

**Example**

```lua
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(128, 128, 128, 255)
    img:brightness(1.5)
    local r, g, b, a = img:getPixel(0, 0)
    image_log("brightness sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LImageData:contrast`

Applies a contrast factor to this image in place.

```lua
LImageData:contrast(factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `factor` | number | Contrast factor. |

**Example**

```lua
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(102, 153, 128, 255)
    img:contrast(2.0)
    local r, g, b, a = img:getPixel(0, 0)
    image_log("contrast sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LImageData:convolve`

Applies a convolution kernel and returns the filtered image.

```lua
LImageData:convolve(kernel_t, ksize)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `kernel_t` | table | Array table of numeric kernel weights. |
| `ksize` | number | Kernel width and height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Convolved image data handle. |

**Example**

```lua
do
    local img = lurek.image.newImageData(32, 32)
    local kernel = {0, -1, 0, -1, 5, -1, 0, -1, 0}
    local result = img:convolve(kernel, 3)
    local r, g, b, a = result:getPixel(0, 0)
    image_log("convolved " .. result:getWidth() .. "x" .. result:getHeight() .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LImageData:crop`

Returns a cropped image region. This method is available to Lua scripts.

```lua
LImageData:crop(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Source x coordinate. |
| `y` | number | Source y coordinate. |
| `w` | number | Crop width. |
| `h` | number | Crop height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Cropped image data handle. |

**Example**

```lua
do
    local img = lurek.image.newImageData(100, 100)
    img:drawRect(10, 10, 50, 50, 255, 0, 0, 255)
    local cropped = img:crop(10, 10, 50, 50)
    local r, g, b, a = cropped:getPixel(0, 0)
    image_log("cropped " .. cropped:getWidth() .. "x" .. cropped:getHeight() .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LImageData:diff`

Computes a difference metric against another image.

```lua
LImageData:diff(other_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other_ud` | [LImageData](#limagedata) | Image data handle to compare with this image. |

**Returns**

| Type | Description |
|------|-------------|
| number | Difference score. |

**Example**

```lua
do
    local a = lurek.image.newImageData(8, 8)
    local b = lurek.image.newImageData(8, 8)
    b:setPixel(0, 0, 1, 0, 0, 1)
    local score = a:diff(b)
    example_print_log("diff score = " .. score)
end
```

---

#### `LImageData:drawCircle`

Draws a filled circle into this image.

```lua
LImageData:drawCircle(cx, cy, radius, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | number | Circle center x coordinate. |
| `cy` | number | Circle center y coordinate. |
| `radius` | number | Circle radius. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

**Example**

```lua
do
    local img = lurek.image.newImageData(64, 64)
    img:drawCircle(32, 32, 16, 255, 0, 0, 255)
    local r, g, b, a = img:getPixel(32, 32)
    local dims = img:getWidth() .. "x" .. img:getHeight()
    image_log("circle drawn on " .. dims .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LImageData:drawLine`

Draws a line into this image. This method is available to Lua scripts.

```lua
LImageData:drawLine(x0, y0, x1, y1, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x0` | number | Start x coordinate. |
| `y0` | number | Start y coordinate. |
| `x1` | number | End x coordinate. |
| `y1` | number | End y coordinate. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

**Example**

```lua
do
    local img = lurek.image.newImageData(32, 32)
    img:drawLine(0, 0, 31, 31, 255, 255, 0, 255)
    local r, g, b, a = img:getPixel(0, 0)
    local dims = img:getWidth() .. "x" .. img:getHeight()
    image_log("line drawn on " .. dims .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LImageData:drawNineSlice`

Draws a nine-slice region from a source image into this image.

```lua
LImageData:drawNineSlice(src_ud, src_x, src_y, src_w, src_h, dst_x, dst_y, dst_w, dst_h, inset_left, inset_right, inset_top, inset_bottom)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `src_ud` | [LImageData](#limagedata) | Source image data handle. |
| `src_x` | number | Source region x coordinate. |
| `src_y` | number | Source region y coordinate. |
| `src_w` | number | Source region width. |
| `src_h` | number | Source region height. |
| `dst_x` | number | Destination x coordinate. |
| `dst_y` | number | Destination y coordinate. |
| `dst_w` | number | Destination width. |
| `dst_h` | number | Destination height. |
| `inset_left` | number | Left inset width. |
| `inset_right` | number | Right inset width. |
| `inset_top` | number | Top inset height. |
| `inset_bottom` | number | Bottom inset height. |

**Example**

```lua
do
    local dst = lurek.image.newImageData(64, 64)
    local src = lurek.image.newImageData(32, 32)
    src:fill(128, 128, 128, 255)
    dst:drawNineSlice(src, 0, 0, 32, 32, 0, 0, 64, 64, 8, 8, 8, 8)
    example_print_log("nine-slice drawn")
end
```

---

#### `LImageData:drawRect`

Draws a filled rectangle into this image.

```lua
LImageData:drawRect(x, y, w, h, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Rectangle x coordinate. |
| `y` | number | Rectangle y coordinate. |
| `w` | number | Rectangle width. |
| `h` | number | Rectangle height. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

**Example**

```lua
do
    local img = lurek.image.newImageData(32, 32)
    img:drawRect(4, 4, 24, 24, 0, 255, 0, 255)
    local r, g, b, a = img:getPixel(4, 4)
    local dims = img:getWidth() .. "x" .. img:getHeight()
    image_log("rect drawn on " .. dims .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LImageData:encode`

Encodes image data in a supported format.

```lua
LImageData:encode(format)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `format` | string | Format name; currently `png`. |

**Returns**

| Type | Description |
|------|-------------|
| string | Encoded image bytes. |

**Example**

```lua
do
    local img = lurek.image.newImageData(4, 4)
    img:fill(255, 0, 0, 255)
    local bytes = img:encode("png")
    local raw = img:getRawBytes()
    image_log("encoded " .. #bytes .. " bytes from raw=" .. #raw)
end
```

---

#### `LImageData:fill`

Fills the whole image with one RGBA color.

```lua
LImageData:fill(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

**Example**

```lua
do
    local img = lurek.image.newImageData(8, 8)
    img:fill(0, 0, 255, 255)
    local r, g, b, a = img:getPixel(0, 0)
    local w, h = img:getDimensions()
    image_log("filled blue " .. w .. "x" .. h .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LImageData:flipHorizontal`

Flips this image horizontally in place.

```lua
LImageData:flipHorizontal()
```

**Example**

```lua
do
    local img = lurek.image.newImageData(16, 16)
    img:setPixel(0, 0, 255, 0, 0, 255)
    img:flipHorizontal()
    local r, _, _, _ = img:getPixel(15, 0)
    example_print_log("flipped h, corner r = " .. r)
end
```

---

#### `LImageData:flipVertical`

Flips this image vertically in place.

```lua
LImageData:flipVertical()
```

**Example**

```lua
do
    local img = lurek.image.newImageData(16, 16)
    img:setPixel(0, 0, 0, 255, 0, 255)
    img:flipVertical()
    local _, g, _, _ = img:getPixel(0, 15)
    example_print_log("flipped v, corner g = " .. g)
end
```

---

#### `LImageData:gamma`

Applies gamma correction to this image in place.

```lua
LImageData:gamma(gamma)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `gamma` | number | Gamma value. |

**Example**

```lua
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(128, 128, 128, 255)
    img:gamma(2.2)
    local r, g, b, a = img:getPixel(0, 0)
    image_log("gamma sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LImageData:getDimensions`

Returns image dimensions. This method is available to Lua scripts.

```lua
LImageData:getDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels. |
| number | Height in pixels. |

**Example**

```lua
do
    local img = lurek.image.newImageData(100, 50)
    img:fill(10, 20, 30, 255)
    local w, h = img:getDimensions()
    local raw = img:getRawBytes()
    image_log("dimensions = " .. w .. "x" .. h .. " bytes=" .. #raw)
end
```

---

#### `LImageData:getHeight`

Returns image height. This method is available to Lua scripts.

```lua
LImageData:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Height in pixels. |

**Example**

```lua
do
    local img = lurek.image.newImageData(80, 40)
    img:fill(50, 60, 70, 255)
    local height = img:getHeight()
    local width = img:getWidth()
    image_log("height = " .. height .. " width=" .. width)
end
```

---

#### `LImageData:getPixel`

Returns RGBA channels at a pixel coordinate.

```lua
LImageData:getPixel(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Red channel. |
| number | Green channel. |
| number | Blue channel. |
| number | Alpha channel. |

**Example**

```lua
do
    local img = lurek.image.newImageData(10, 10)
    img:fill(255, 128, 0, 255)
    local r, g, b, a = img:getPixel(5, 5)
    local width = img:getWidth()
    image_log("pixel = " .. r .. "," .. g .. "," .. b .. "," .. a .. " width=" .. width)
end
```

---

#### `LImageData:getRawBytes`

Returns raw image bytes as a Lua string.

```lua
LImageData:getRawBytes()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Raw image byte string. |

**Example**

```lua
do
    local img = lurek.image.newImageData(2, 2)
    img:fill(10, 20, 30, 255)
    local raw = img:getRawBytes()
    local width = img:getWidth()
    image_log("raw bytes = " .. #raw .. " width=" .. width)
end
```

---

#### `LImageData:getRegion`

Returns an image region when the requested rectangle is inside bounds.

```lua
LImageData:getRegion(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Region x coordinate. |
| `y` | number | Region y coordinate. |
| `w` | number | Region width. |
| `h` | number | Region height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | nil | `[LImageData](#limagedata)` handle, or nil when the region is out of bounds. |

**Example**

```lua
do
    local img = lurek.image.newImageData(64, 64)
    local region = img:getRegion(0, 0, 32, 32)
    if region then
        example_print_log("region " .. region:getWidth() .. "x" .. region:getHeight())
    end
end
```

---

#### `LImageData:getString`

Returns raw image bytes as a Lua string.

```lua
LImageData:getString()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Raw image byte string. |

**Example**

```lua
do
    local img = lurek.image.newImageData(2, 2)
    img:fill(10, 20, 30, 255)
    local str = img:getString()
    local height = img:getHeight()
    image_log("string bytes = " .. #str .. " height=" .. height)
end
```

---

#### `LImageData:getWidth`

Returns image width. This method is available to Lua scripts.

```lua
LImageData:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels. |

**Example**

```lua
do
    local img = lurek.image.newImageData(80, 40)
    img:fill(50, 60, 70, 255)
    local width = img:getWidth()
    local height = img:getHeight()
    image_log("width = " .. width .. " height=" .. height)
end
```

---

#### `LImageData:grayscale`

Converts this image to grayscale in place.

```lua
LImageData:grayscale()
```

**Example**

```lua
do
    local img = lurek.image.newImageData(32, 32)
    img:fill(255, 0, 0, 255)
    img:grayscale()
    local r, g, b, a = img:getPixel(0, 0)
    example_print_log("gray r=" .. r .. " g=" .. g .. " b=" .. b)
end
```

---

#### `LImageData:invert`

Inverts image color channels in place.

```lua
LImageData:invert()
```

**Example**

```lua
do
    local img = lurek.image.newImageData(8, 8)
    img:fill(255, 0, 0, 255)
    img:invert()
    local r, g, b, a = img:getPixel(0, 0)
    example_print_log("inverted r=" .. r .. " g=" .. g .. " b=" .. b)
end
```

---

#### `LImageData:mapPixel`

Applies a Lua callback to every pixel and replaces each pixel with returned RGBA values.

```lua
LImageData:mapPixel(func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `func` | function | Callback receiving `(x, y, r, g, b, a)` and returning replacement channels. |

**Example**

```lua
do
    local img = lurek.image.newImageData(8, 8)
    img:fill(255, 255, 255, 255)
    img:mapPixel(function(_, _, r, g, b, a)
        return math.floor(r * 0.5), math.floor(g * 0.5), math.floor(b * 0.5), a
    end)
    example_print_log("mapped pixels to half brightness")
end
```

---

#### `LImageData:mapPixels`

Applies a Lua callback to every pixel and replaces each pixel with returned RGBA values.

```lua
LImageData:mapPixels(func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `func` | function | Callback receiving `(x, y, r, g, b, a)` and returning replacement channels. |

**Example**

```lua
do
    local img = lurek.image.newImageData(8, 8)
    img:mapPixels(function(x, y)
        return x * 32, y * 32, 0, 255
    end)
    example_print_log("gradient mapped")
end
```

---

#### `LImageData:noise`

Adds noise to this image in place. This method is available to Lua scripts.

```lua
LImageData:noise(amount)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `amount` | number | Noise amount. |

**Example**

```lua
do
    local img = lurek.image.newImageData(32, 32)
    img:fill(128, 128, 128, 255)
    img:noise(16)
    local r, g, b, a = img:getPixel(0, 0)
    image_log("noise sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LImageData:paste`

Pastes a source image into this image at unsigned destination coordinates.

```lua
LImageData:paste(src_ud, dx, dy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `src_ud` | [LImageData](#limagedata) | Source image data handle. |
| `dx` | number | Destination x coordinate. |
| `dy` | number | Destination y coordinate. |

**Example**

```lua
do
    local dst = lurek.image.newImageData(64, 64)
    local src = lurek.image.newImageData(8, 8)
    src:fill(0, 255, 255, 255)
    dst:paste(src, 0, 0)
    example_print_log("pasted")
end
```

---

#### `LImageData:posterize`

Reduces image colors to a fixed number of levels in place.

```lua
LImageData:posterize(levels)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `levels` | number | Number of posterization levels. |

**Example**

```lua
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(179, 77, 128, 255)
    img:posterize(4)
    local r, g, b, a = img:getPixel(0, 0)
    image_log("posterized sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LImageData:resize`

Returns a resized image using an optional named filter.

```lua
LImageData:resize(width, height, filter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Output width. |
| `height` | number | Output height. |
| `filter` | string | Optional filter name, defaulting to `bilinear`. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | nil | Resized `[LImageData](#limagedata)` handle, or nil when resizing fails. |

**Example**

```lua
do
    local img = lurek.image.newImageData(64, 64)
    img:drawRect(16, 16, 32, 32, 255, 210, 80, 255)
    local resized = img:resize(128, 128, "bilinear")
    local center = select(1, resized:getPixel(64, 64))
    local raw = resized:getRawBytes()
    image_log("resized = " .. resized:getWidth() .. "x" .. resized:getHeight() .. " center_r=" .. center .. " bytes=" .. #raw)
end
```

---

#### `LImageData:resizeNearest`

Returns a resized image using nearest-neighbor sampling.

```lua
LImageData:resizeNearest(new_w, new_h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `new_w` | number | Output width. |
| `new_h` | number | Output height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Resized image data handle. |

**Example**

```lua
do
    local img = lurek.image.newImageData(32, 32)
    img:drawRect(8, 8, 16, 16, 0, 200, 255, 255)
    local resized = img:resizeNearest(64, 64)
    local center = select(2, resized:getPixel(32, 32))
    local raw = resized:getRawBytes()
    image_log("nearest = " .. resized:getWidth() .. "x" .. resized:getHeight() .. " center_g=" .. center .. " bytes=" .. #raw)
end
```

---

#### `LImageData:rotate90cw`

Returns a new image rotated ninety degrees clockwise.

```lua
LImageData:rotate90cw()
```

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Rotated image data handle. |

**Example**

```lua
do
    local img = lurek.image.newImageData(20, 40)
    img:setPixel(2, 30, 255, 0, 0, 255)
    local rotated = img:rotate90cw()
    local marker = select(1, rotated:getPixel(9, 2))
    local raw = rotated:getRawBytes()
    image_log("rotated = " .. rotated:getWidth() .. "x" .. rotated:getHeight() .. " marker_r=" .. marker .. " bytes=" .. #raw)
end
```

---

#### `LImageData:saturation`

Applies a saturation factor to this image in place.

```lua
LImageData:saturation(factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `factor` | number | Saturation factor. |

**Example**

```lua
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(255, 0, 0, 255)
    img:saturation(0.5)
    local r, g, b, a = img:getPixel(0, 0)
    image_log("saturation sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LImageData:sepia`

Applies a sepia filter to this image in place.

```lua
LImageData:sepia()
```

**Example**

```lua
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(128, 128, 128, 255)
    img:sepia()
    local r, g, b, a = img:getPixel(0, 0)
    image_log("sepia sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LImageData:setPixel`

Sets RGBA channels at a pixel coordinate.

```lua
LImageData:setPixel(x, y, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

**Example**

```lua
do
    local img = lurek.image.newImageData(10, 10)
    img:setPixel(0, 0, 255, 255, 255, 255)
    local r, g, b, a = img:getPixel(0, 0)
    local width = img:getWidth()
    image_log("set pixel = " .. r .. "," .. g .. "," .. b .. "," .. a .. " width=" .. width)
end
```

---

#### `LImageData:setRawData`

Replaces the image byte buffer with raw bytes.

```lua
LImageData:setRawData(bytes)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bytes` | string | Raw byte string matching the image storage size. |

**Example**

```lua
do
    local img = lurek.image.newImageData(2, 2)
    local bytes = string.rep("\0\255\0\255", 4)
    img:setRawData(bytes)
    local r, g, b, a = img:getPixel(0, 0)
    image_log("raw data set sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LImageData:sharpen`

Returns a sharpened copy of this image.

```lua
LImageData:sharpen()
```

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Sharpened image data handle. |

**Example**

```lua
do
    local img = lurek.image.newImageData(64, 64)
    img:fill(128, 128, 128, 255)
    local sharp = img:sharpen()
    local r, g, b, a = sharp:getPixel(0, 0)
    image_log("sharpened " .. sharp:getWidth() .. "x" .. sharp:getHeight() .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LImageData:threshold`

Applies a threshold filter to this image in place.

```lua
LImageData:threshold(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | number | Threshold channel value. |

**Example**

```lua
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(153, 153, 153, 255)
    img:threshold(128)
    local r, g, b, a = img:getPixel(0, 0)
    image_log("threshold sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LImageData:tint`

Blends this image toward a tint color in place.

```lua
LImageData:tint(tr, tg, tb, factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tr` | number | Tint red channel. |
| `tg` | number | Tint green channel. |
| `tb` | number | Tint blue channel. |
| `factor` | number | Tint blend factor. |

**Example**

```lua
do
    local img = lurek.image.newImageData(16, 16)
    img:fill(255, 255, 255, 255)
    img:tint(255, 0, 0, 0.5)
    local r, g, b, a = img:getPixel(0, 0)
    image_log("tint sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LImageData:type`

Returns the Lua-visible type name for this image data handle.

```lua
LImageData:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LImageData](#limagedata)`. |

**Example**

```lua
do
    local img = lurek.image.newImageData(1, 1)
    img:setPixel(0, 0, 255, 255, 255, 255)
    local type_name = img:type()
    local r = select(1, img:getPixel(0, 0))
    image_log("type = " .. type_name .. " sample_r=" .. r)
end
```

---

#### `LImageData:typeOf`

Returns whether this image data handle matches the `[LImageData](#limagedata)` type name.

```lua
LImageData:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LImageData](#limagedata)` or `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches. |

**Example**

```lua
do
    local img = lurek.image.newImageData(1, 1)
    img:setPixel(0, 0, 255, 255, 255, 255)
    local is_image = img:typeOf("LImageData")
    local is_object = img:typeOf("LObject")
    image_log("is ImageData = " .. tostring(is_image) .. " object=" .. tostring(is_object))
end
```

---

## LLayeredImage

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LLayeredImage:addLayer`

Adds a blank layer with an optional name.

```lua
LLayeredImage:addLayer(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name?` | string | Optional layer name. |

**Returns**

| Type | Description |
|------|-------------|
| number | One-based index of the new layer. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(64, 64)
    local idx = li:addLayer("background")
    local layer = li:getLayer(idx)
    layer:fill(20, 30, 60, 255)
    local count = li:layerCount()
    image_log("added layer at index " .. idx .. " layers=" .. count .. " sample_a=" .. select(4, layer:getPixel(0, 0)))
end
```

---

#### `LLayeredImage:getHeight`

Returns the layered image height. This method is available to Lua scripts.

```lua
LLayeredImage:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Height in pixels. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(100, 50)
    li:addLayer("preview")
    local width = li:getWidth()
    local height = li:getHeight()
    local count = li:layerCount()
    image_log("layered size = " .. width .. "x" .. height .. " layers=" .. count)
end
```

---

#### `LLayeredImage:getLayer`

Returns image data for a layer by one-based index.

```lua
LLayeredImage:getLayer(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | One-based layer index. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Layer image data handle. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(16, 16)
    local idx = li:addLayer("green")
    local data = li:getLayer(1)
    data:fill(0, 255, 0, 255)
    local g = select(2, data:getPixel(0, 0))
    image_log("layer " .. idx .. " size=" .. data:getWidth() .. "x" .. data:getHeight() .. " sample_g=" .. g)
end
```

---

#### `LLayeredImage:getName`

Returns a layer name by one-based index.

```lua
LLayeredImage:getName(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | One-based layer index. |

**Returns**

| Type | Description |
|------|-------------|
| string | Layer name. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(8, 8)
    local idx = li:addLayer("background")
    local name = li:getName(1)
    local count = li:layerCount()
    image_log("layer " .. idx .. " name=" .. name .. " count=" .. count)
end
```

---

#### `LLayeredImage:getOpacity`

Returns a layer opacity by one-based index.

```lua
LLayeredImage:getOpacity(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | One-based layer index. |

**Returns**

| Type | Description |
|------|-------------|
| number | Layer opacity. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("layer")
    li:setOpacity(1, 0.35)
    local opacity = li:getOpacity(1)
    local visible = li:isVisible(1)
    image_log("opacity = " .. opacity .. " visible=" .. tostring(visible))
end
```

---

#### `LLayeredImage:getWidth`

Returns the layered image width. This method is available to Lua scripts.

```lua
LLayeredImage:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width in pixels. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(100, 50)
    li:addLayer("preview")
    local width = li:getWidth()
    local height = li:getHeight()
    local count = li:layerCount()
    image_log("layered size = " .. width .. "x" .. height .. " layers=" .. count)
end
```

---

#### `LLayeredImage:isVisible`

Returns layer visibility by one-based index.

```lua
LLayeredImage:isVisible(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | One-based layer index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the layer is visible. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("vis")
    li:setVisible(1, false)
    local hidden = li:isVisible(1)
    li:setVisible(1, true)
    local restored = li:isVisible(1)
    image_log("visible hidden=" .. tostring(hidden) .. " restored=" .. tostring(restored))
end
```

---

#### `LLayeredImage:layerCount`

Returns the number of layers in the stack.

```lua
LLayeredImage:layerCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Layer count. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(8, 8)
    local empty = li:layerCount()
    li:addLayer("terrain")
    li:addLayer("roads")
    local total = li:layerCount()
    image_log("layers " .. empty .. " -> " .. total)
end
```

---

#### `LLayeredImage:merge`

Merges visible layers into a single image data object.

```lua
LLayeredImage:merge()
```

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Merged image data handle. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(32, 32)
    local base = li:addLayer("base")
    local fx = li:addLayer("fx")
    li:getLayer(base):fill(40, 60, 120, 255)
    li:getLayer(fx):drawCircle(16, 16, 8, 255, 220, 120, 255)
    local merged = li:merge()
    local sample = select(1, merged:getPixel(16, 16))
    image_log("merged " .. merged:getWidth() .. "x" .. merged:getHeight() .. " sample_r=" .. sample)
end
```

---

#### `LLayeredImage:moveLayer`

Moves a layer from one one-based index to another.

```lua
LLayeredImage:moveLayer(from_idx, to_idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_idx` | number | Source one-based layer index. |
| `to_idx` | number | Destination one-based layer index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the move succeeds. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("first")
    li:addLayer("second")
    li:moveLayer(2, 1)
    example_print_log("moved: first is now " .. li:getName(1))
end
```

---

#### `LLayeredImage:removeLayer`

Removes a layer by one-based index.

```lua
LLayeredImage:removeLayer(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | One-based layer index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a layer was removed. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(32, 32)
    li:addLayer("background")
    li:addLayer("temp")
    local before = li:layerCount()
    li:removeLayer(1)
    local after = li:layerCount()
    local first = li:getName(1)
    image_log("layers " .. before .. " -> " .. after .. " first=" .. first)
end
```

---

#### `LLayeredImage:save`

Saves the layered image stack to a file.

```lua
LLayeredImage:save(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Output path. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(16, 16)
    local idx = li:addLayer("only")
    li:getLayer(idx):fill(255, 255, 255, 255)
    li:save("save/layered_test.limg")
    local merged = li:merge()
    image_log("layered image saved layers=" .. li:layerCount() .. " sample_a=" .. select(4, merged:getPixel(0, 0)))
end
```

---

#### `LLayeredImage:setLayer`

Replaces a layer's image data by one-based index.

```lua
LLayeredImage:setLayer(index, img)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | One-based layer index. |
| `img` | [LImageData](#limagedata) | Image data assigned to the layer. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the layer was replaced. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(16, 16)
    li:addLayer("slot")
    local replacement = lurek.image.newImageData(16, 16)
    replacement:fill(255, 255, 255, 255)
    li:setLayer(1, replacement)
    local sample = select(1, li:getLayer(1):getPixel(0, 0))
    image_log("layer replaced width=" .. li:getLayer(1):getWidth() .. " sample_r=" .. sample)
end
```

---

#### `LLayeredImage:setName`

Sets a layer name by one-based index.

```lua
LLayeredImage:setName(index, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | One-based layer index. |
| `name` | string | New layer name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the layer exists. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("old")
    li:setName(1, "renamed")
    local name = li:getName(1)
    local count = li:layerCount()
    image_log("new name = " .. name .. " count=" .. count)
end
```

---

#### `LLayeredImage:setOpacity`

Sets a layer opacity by one-based index.

```lua
LLayeredImage:setOpacity(index, opacity)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | One-based layer index. |
| `opacity` | number | New layer opacity. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the layer exists. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("layer")
    li:setOpacity(1, 0.5)
    local opacity = li:getOpacity(1)
    local merged = li:merge()
    local dims = merged:getWidth() .. "x" .. merged:getHeight()
    image_log("opacity = " .. opacity .. " merged=" .. dims)
end
```

---

#### `LLayeredImage:setVisible`

Sets layer visibility by one-based index.

```lua
LLayeredImage:setVisible(index, visible)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | One-based layer index. |
| `visible` | boolean | New visibility flag. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the layer exists. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("toggle")
    li:setVisible(1, false)
    local hidden = li:isVisible(1)
    li:setVisible(1, true)
    local restored = li:isVisible(1)
    image_log("visible hidden=" .. tostring(hidden) .. " restored=" .. tostring(restored))
end
```

---

#### `LLayeredImage:swapLayers`

Swaps two layers by one-based indices.

```lua
LLayeredImage:swapLayers(a, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | number | First one-based layer index. |
| `b` | number | Second one-based layer index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when both layers exist. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("alpha")
    li:addLayer("beta")
    li:swapLayers(1, 2)
    example_print_log("after swap: 1=" .. li:getName(1) .. " 2=" .. li:getName(2))
end
```

---

#### `LLayeredImage:type`

Returns the Lua-visible type name for this layered image handle.

```lua
LLayeredImage:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LLayeredImage](#llayeredimage)`. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("debug")
    local type_name = li:type()
    local is_layered = li:typeOf("LLayeredImage")
    local is_object = li:typeOf("LObject")
    image_log("type = " .. type_name .. " layered=" .. tostring(is_layered) .. " object=" .. tostring(is_object))
end
```

---

#### `LLayeredImage:typeOf`

Returns whether this layered image handle matches a supported type name.

```lua
LLayeredImage:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LLayeredImage](#llayeredimage)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local li = lurek.image.newLayeredImage(8, 8)
    li:addLayer("debug")
    local type_name = li:type()
    local is_layered = li:typeOf("LLayeredImage")
    local is_object = li:typeOf("LObject")
    image_log("type = " .. type_name .. " layered=" .. tostring(is_layered) .. " object=" .. tostring(is_object))
end
```

---

## LPaletteLUT

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LPaletteLUT:clear`

Removes every color mapping from this palette lookup table.

```lua
LPaletteLUT:clear()
```

**Example**

```lua
do
    local lut = lurek.image.newPaletteLut()
    lut:setColor(255, 0, 0, 255, 0, 0, 255, 255)
    local before = lut:getColorCount()
    lut:clear()
    local after = lut:getColorCount()
    local kind = lut:type()
    example_print_log("LUT cleared, colors = " .. lut:getColorCount())
end
```

---

#### `LPaletteLUT:cycle`

Cycles palette mappings by an offset.

```lua
LPaletteLUT:cycle(offset)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `offset` | number | Mapping offset. |

**Example**

```lua
do
    local lut = lurek.image.newPaletteLut()
    lut:setColor(255, 0, 0, 255, 0, 255, 0, 255)
    lut:setColor(0, 255, 0, 255, 0, 0, 255, 255)
    lut:cycle(1)
    example_print_log("palette cycled")
end
```

---

#### `LPaletteLUT:getColorCount`

Returns the number of color mappings in this palette lookup table.

```lua
LPaletteLUT:getColorCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Color mapping count. |

**Example**

```lua
do
    local lut = lurek.image.newPaletteLut()
    lut:setColor(255, 0, 0, 255, 128, 0, 0, 255)
    lut:setColor(0, 255, 0, 255, 0, 128, 0, 255)
    local count = lut:getColorCount()
    local kind = lut:type()
    example_print_log("color count = " .. lut:getColorCount())
end
```

---

#### `LPaletteLUT:setColor`

Adds a color mapping from source RGBA channels to destination RGBA channels.

```lua
LPaletteLUT:setColor(fr, fg, fb, fa, tr, tg, tb, ta)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fr` | number | Source red channel. |
| `fg` | number | Source green channel. |
| `fb` | number | Source blue channel. |
| `fa` | number | Source alpha channel. |
| `tr` | number | Destination red channel. |
| `tg` | number | Destination green channel. |
| `tb` | number | Destination blue channel. |
| `ta` | number | Destination alpha channel. |

**Example**

```lua
do
    local lut = lurek.image.newPaletteLut()
    lut:setColor(255, 0, 0, 255, 0, 255, 0, 255)
    lut:setColor(0, 0, 255, 255, 255, 255, 255, 255)
    local count = lut:getColorCount()
    local kind = lut:type()
    example_print_log("red → green mapping set")
end
```

---

#### `LPaletteLUT:type`

Returns the Lua-visible type name for this palette lookup table handle.

```lua
LPaletteLUT:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LPaletteLUT](#lpalettelut)`. |

**Example**

```lua
do
    local lut = lurek.image.newPaletteLut()
    lut:setColor(255, 255, 255, 255, 200, 200, 200, 255)
    local count = lut:getColorCount()
    example_print_log("type = " .. lut:type())
    example_print_log("is PaletteLUT = " .. tostring(lut:typeOf("LPaletteLUT")))
end
```

---

#### `LPaletteLUT:typeOf`

Returns whether this palette lookup table handle matches a supported type name.

```lua
LPaletteLUT:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LPaletteLUT](#lpalettelut)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local lut = lurek.image.newPaletteLut()
    lut:setColor(255, 255, 255, 255, 200, 200, 200, 255)
    local is_object = lut:typeOf("LObject")
    example_print_log("type = " .. lut:type())
    example_print_log("is PaletteLUT = " .. tostring(lut:typeOf("LPaletteLUT")))
end
```

---

## LProvinceGrid

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LProvinceGrid:adjacencies`

Returns province adjacency records and shared border pixel counts.

```lua
LProvinceGrid:adjacencies()
```

**Returns**

| Type | Description |
|------|-------------|
| LProvinceGridAdjacenciesResult | Array table with `province_a`, `province_b`, and `border_pixels` fields. |

**Example**

```lua
do
    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local adj = grid:adjacencies()
    local borders = grid:borderSegments()
    local first = adj[1]
    example_print_log("adjacency records = " .. #adj)
end
```

---

#### `LProvinceGrid:borderSegments`

Returns border line segments between neighboring provinces.

```lua
LProvinceGrid:borderSegments()
```

**Returns**

| Type | Description |
|------|-------------|
| LProvinceGridBorderSegmentsResult | Array table with province ids and segment coordinates. |

**Example**

```lua
do
    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local segs = grid:borderSegments()
    local polys = grid:getPolygonsSimplified()
    local first = segs[1]
    example_print_log("border segments = " .. #segs)
end
```

---

#### `LProvinceGrid:deserializeShapeData`

Decodes serialized province shape data into span and segment tables.

```lua
LProvinceGrid:deserializeShapeData(bytes)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bytes` | string | Serialized shape data bytes. |

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Table with `spans` and `segments`, or nil when decoding fails. |

**Example**

```lua
do
    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local data = grid:serializeShapeData()
    example_print_log("serialized " .. #data .. " bytes")
    grid:deserializeShapeData(data)
    example_print_log("deserialized")
end
```

---

#### `LProvinceGrid:drawShapes`

Queues filled polygon draw commands for province shapes, optionally culled to a viewport rect.

```lua
LProvinceGrid:drawShapes(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x?` | number | Viewport left edge (required if providing a viewport). |
| `y?` | number | Viewport top edge (required if providing a viewport). |
| `w?` | number | Viewport width (required if providing a viewport). |
| `h?` | number | Viewport height (required if providing a viewport). |

**Returns**

| Type | Description |
|------|-------------|
| number | Number of polygons emitted to the render command queue. |

**Example**

```lua
do
    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local count = grid:drawShapes(0, 0, 800, 600)
    local provinces = grid:provinceCount()
    local w = grid:getWidth()
    example_print_log("drew " .. count .. " polygons")
end
```

---

#### `LProvinceGrid:getAt`

Returns the province id stored at grid coordinates.

```lua
LProvinceGrid:getAt(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Province id at the pixel. |

**Example**

```lua
do
    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local id = grid:getAt(10, 10)
    local neighbor = grid:getAt(11, 10)
    local total = grid:provinceCount()
    example_print_log("province at (10,10) = " .. id)
end
```

---

#### `LProvinceGrid:getHeight`

Returns the province grid height. This method is available to Lua scripts.

```lua
LProvinceGrid:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Grid height in pixels. |

**Example**

```lua
do
    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local width = grid:getWidth()
    local provinces = grid:provinceCount()
    local start = grid:getAt(0, 0)
    example_print_log("grid = " .. grid:getWidth() .. "x" .. grid:getHeight())
end
```

---

#### `LProvinceGrid:getPolygons`

Returns polygon rings for every province.

```lua
LProvinceGrid:getPolygons()
```

**Returns**

| Type | Description |
|------|-------------|
| LProvinceGridGetPolygonsResult | Array table of province polygon records with `province_id` and `rings` fields. |

**Example**

```lua
do
    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local polys = grid:getPolygons()
    local simplified = grid:getPolygonsSimplified()
    local first = polys[1]
    example_print_log("polygon records = " .. #polys)
end
```

---

#### `LProvinceGrid:getPolygonsSimplified`

Returns simplified polygon rings for every province.

```lua
LProvinceGrid:getPolygonsSimplified()
```

**Returns**

| Type | Description |
|------|-------------|
| LProvinceGridGetPolygonsSimplifiedResult | Array table of simplified province polygon records with `province_id` and `rings` fields. |

**Example**

```lua
do
    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local polys = grid:getPolygonsSimplified()
    local full = grid:getPolygons()
    local first = polys[1]
    example_print_log("simplified records = " .. #polys)
end
```

---

#### `LProvinceGrid:getWidth`

Returns the province grid width. This method is available to Lua scripts.

```lua
LProvinceGrid:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Grid width in pixels. |

**Example**

```lua
do
    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local height = grid:getHeight()
    local provinces = grid:provinceCount()
    local start = grid:getAt(0, 0)
    example_print_log("grid = " .. grid:getWidth() .. "x" .. grid:getHeight())
end
```

---

#### `LProvinceGrid:provinceCount`

Returns the number of distinct provinces in the grid.

```lua
LProvinceGrid:provinceCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Province count. |

**Example**

```lua
do
    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local w = grid:getWidth()
    local h = grid:getHeight()
    local start = grid:getAt(0, 0)
    example_print_log("provinces = " .. grid:provinceCount())
end
```

---

#### `LProvinceGrid:provinceSpans`

Returns horizontal province spans by row.

```lua
LProvinceGrid:provinceSpans()
```

**Returns**

| Type | Description |
|------|-------------|
| LProvinceGridProvinceSpansResult | Array table with `province_id`, `y`, `x0`, and `x1` fields. |

**Example**

```lua
do
    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local spans = grid:provinceSpans()
    local provinces = grid:provinceCount()
    local first = spans[1]
    example_print_log("total spans = " .. #spans)
end
```

---

#### `LProvinceGrid:serializeShapeData`

Serializes province span and border shape data into a binary Lua string.

```lua
LProvinceGrid:serializeShapeData()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Serialized shape data bytes. |

**Example**

```lua
do
    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local data = grid:serializeShapeData()
    example_print_log("serialized " .. #data .. " bytes")
    grid:deserializeShapeData(data)
    example_print_log("deserialized")
end
```

---

#### `LProvinceGrid:type`

Returns the Lua-visible type name for this province grid handle.

```lua
LProvinceGrid:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LProvinceGrid](#lprovincegrid)`. |

**Example**

```lua
do
    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local sample = grid:getAt(10, 10)
    local provinces = grid:provinceCount()
    example_print_log("type = " .. grid:type())
    example_print_log("is ProvinceGrid = " .. tostring(grid:typeOf("LProvinceGrid")))
end
```

---

#### `LProvinceGrid:typeOf`

Returns whether this province grid handle matches a supported type name.

```lua
LProvinceGrid:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LProvinceGrid](#lprovincegrid)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local sample = grid:getAt(10, 10)
    local is_object = grid:typeOf("LObject")
    example_print_log("type = " .. grid:type())
    example_print_log("is ProvinceGrid = " .. tostring(grid:typeOf("LProvinceGrid")))
end
```

---
