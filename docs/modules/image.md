# Image

## Purpose

Manages CPU image buffers, PNG texture loading, layered stacks, palette remapping, and atlases. - Supports bounded pixel-level effects, layers, palette mapping, CPU-side atlas preparation, and encoded-byte export.

## Summary

- The `image` module is the engine's CPU-side image workbench for users who need pixel data to be loaded, transformed, composed, inspected, compared, and exported under one coherent API.
- Its role is broader than ordinary file loading. Raw buffers, filters, resizing, layers, palettes, atlas packing, drawing helpers, and serialization all live here because real image workflows usually chain several of those operations together.
- This breadth matters because many projects need to do image work inside the engine, not only before runtime in an external editor. Asset preparation, theme variation, generated visuals, screenshots, comparison tests, and data extraction can all depend on image processing.
- Layer support is especially important for tooling and content workflows where staged or partially non-destructive composition is useful.
- Color and tone operations expand the module into style control, while filter kernels and geometric transforms make it practical for more technical pixel-space workflows such as resampling, blur-like effects, and rotation.
- Atlas and texture-preparation helpers are critical from a runtime perspective because many images become packed regions, sprite sources, UI textures, or render-ready assets rather than staying as isolated files.
- This makes the module a bridge between authored content and render consumption. `render` eventually uses the resulting textures, but `image` owns the CPU-side transformations that prepare and validate them.
- Comparison and diff-style helpers turn the module into a testing and evidence surface without making image the owner of cross-domain diagnostics.
- Image-only drawing and diagnostic output remain useful for debugging, but camera, audio, animation, UI, graph, and procedural domain diagnostics belong to their respective owners.
- Image data can be a source of gameplay structure, but `image` owns the pixel-domain side of that pipeline. Province-specific id extraction, topology, spans, and polygons are owned by `province`.
- That two-way relationship is important: `image` is useful both after a visual asset exists and when visual data is being used as input to another system.
- Serialization and format conversion keep the module connected to the outside world. The same subsystem can move between files, generated runtime state, debugging artifacts, and exported outputs without pushing those conversions into ad hoc helpers.
- That flexibility also makes the module useful for tool-driven inspection as well as asset preparation.
- This makes the module useful across the whole asset lifecycle: load, inspect, transform, compare, pack, export, and sometimes reinterpret as data for another system.
- `render` consumes prepared results, but `image` owns pixel-domain manipulation, inspection, packing, and export before or outside final rendering.
- Read `image` as the engine's pixel-domain authority for asset prep and tooling.

This module primarily collaborates with `color`, `math`, `province`, `render`, and `runtime`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

## API Reference

- This page is the generated API reference for this module.

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
    lurek.log.info("screen capture " .. status .. " alpha=" .. sampled_alpha .. " blend=" .. mode)
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
    local ok, err = pcall(lurek.image.newCompressedData, dds_path)
    local status = ok and "loaded" or tostring(err)
    lurek.log.info("dds=" .. tostring(dds) .. " png=" .. tostring(png) .. " status=" .. status)
end
```

---

### `lurek.image.loadAnimated`

Loads an animated GIF from GameFS path or decodes animated GIF bytes.

```lua
lurek.image.loadAnimated(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | string | GameFS path or raw GIF bytes. |

**Returns**

| Type | Description |
|------|-------------|
| [LAnimatedImage](#lanimatedimage) | Decoded frames and durations. |

**Example**

```lua
do
    local a = lurek.image.newImageData(2, 2)
    local b = lurek.image.newImageData(2, 2)
    a:fill(255, 0, 0, 255)
    b:fill(0, 255, 0, 255)
    lurek.image.saveGIF({ a, b }, "save/example_load_animated.gif", { delayMs = 40 })
    local animated = lurek.image.loadAnimated("save/example_load_animated.gif")
    lurek.log.info("[image] animated frames=" .. tostring(animated:frameCount()))
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
    lurek.log.info("loaded image " .. img:getWidth() .. "x" .. img:getHeight())
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
    lurek.log.info("loaded layered=" .. tostring(loaded ~= nil) .. " size=" .. w .. "x" .. h .. " layers=" .. count)
end
```

---

### `lurek.image.newCompressedData`

Attempts to load DDS compressed image data from GameFS.

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
| [LCompressedImageData](#lcompressedimagedata) | New compressed image data handle when DDS support is enabled. |

**Example**

```lua
do

    local path = "content/examples/assets/images/sample_normal.dds"
    local ok, result = pcall(lurek.image.newCompressedData, path)
    local is_dds = lurek.image.isCompressed(path)
    local status = ok and result:type() or "unsupported"
    local detail = ok and result:getFormat() or tostring(result)
    lurek.log.info("compressed dds=" .. tostring(is_dds) .. " status=" .. status .. " detail=" .. detail)
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
    lurek.log.info("blank minimap canvas " .. w .. "x" .. h .. " bytes=" .. #raw)
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
    lurek.log.info("from bytes " .. w .. "x" .. h .. " first=" .. r .. "," .. g .. "," .. b .. "," .. a)
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
    lurek.log.info("layered " .. w .. "x" .. h .. " layers=" .. li:layerCount() .. " last=" .. idx .. " sample_r=" .. sample)
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
    lurek.log.info("palette LUT colors = " .. count .. " type=" .. kind)
end
```

---

### `lurek.image.newProvinceGrid`

Loads a province id grid from an image file under the current game directory. This is a compatibility facade over the province subsystem.

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
| LProvinceGrid | New province grid handle. |

**Example**

```lua
do

    local grid = lurek.image.newProvinceGrid("content/examples/assets/textures/province_map.png")
    local w, h = grid:getWidth(), grid:getHeight()
    local provinces = grid:provinceCount()
    local sample = grid:getAt(10, 10)
    lurek.log.info("province grid " .. w .. "x" .. h .. " provinces=" .. provinces .. " sample=" .. sample)
end
```

---

### `lurek.image.requestShader`

Starts an offline image shader request and returns a completed job handle.

```lua
lurek.image.requestShader(image, shader, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `image` | [LImageData](#limagedata) | Source image data. |
| `shader` | [LShader](render.md#lshader) | Image-target shader. |
| `opts?` | table | Optional job options. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageShaderJob](#limageshaderjob) | Offline shader job handle. |

**Example**

```lua
do
    local image = lurek.image.newImageData(2, 2)
    image:fill(120, 80, 40, 255)
    local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.b, color.g, color.r, color.a);
}
]], { target = "image" })
    local job = lurek.image.requestShader(image, shader)
    local output = job:wait(50)
    lurek.log.info("[image] shader job done=" .. tostring(output ~= nil))
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
    lurek.log.info("saved GIF")
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
    lurek.log.info("saved limg bytes=" .. #raw)
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
    lurek.log.info("saved png bytes=" .. #encoded)
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LAnimatedImage](#lanimatedimage)
- [LCompressedImageData](#lcompressedimagedata)
- [LImageData](#limagedata)
- [LImageShaderJob](#limageshaderjob)
- [LLayeredImage](#llayeredimage)
- [LPaletteLUT](#lpalettelut)
- [LUnknown](#lunknown)

## LAnimatedImage

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LAnimatedImage:frameCount`

Returns the number of decoded frames.

```lua
LAnimatedImage:frameCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Frame count. |

**Example**

```lua
do
    local frame = lurek.image.newImageData(2, 2)
    frame:fill(255, 255, 255, 255)
    lurek.image.saveGIF({ frame, frame }, "save/example_anim_count.gif", { delayMs = 30 })
    local animated = lurek.image.loadAnimated("save/example_anim_count.gif")
    local count = animated:frameCount()
    lurek.log.info("[image] frameCount=" .. tostring(count))
end
```

---

#### `LAnimatedImage:getDuration`

Returns a frame duration in milliseconds by one-based index.

```lua
LAnimatedImage:getDuration(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | One-based frame index. |

**Returns**

| Type | Description |
|------|-------------|
| number | Duration in milliseconds. |

**Example**

```lua
do
    local frame = lurek.image.newImageData(2, 2)
    frame:fill(20, 40, 80, 255)
    lurek.image.saveGIF({ frame, frame }, "save/example_anim_duration.gif", { delayMs = 50 })
    local animated = lurek.image.loadAnimated("save/example_anim_duration.gif")
    local duration = animated:getDuration(1)
    lurek.log.info("[image] duration=" .. tostring(duration))
end
```

---

#### `LAnimatedImage:getDurations`

Returns all frame durations in milliseconds.

```lua
LAnimatedImage:getDurations()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of integer durations. |

**Example**

```lua
do
    local frame = lurek.image.newImageData(2, 2)
    frame:fill(80, 40, 20, 255)
    lurek.image.saveGIF({ frame, frame }, "save/example_anim_durations.gif", { delayMs = 30 })
    local animated = lurek.image.loadAnimated("save/example_anim_durations.gif")
    local durations = animated:getDurations()
    lurek.log.info("[image] durations table=" .. tostring(#durations))
end
```

---

#### `LAnimatedImage:getFrame`

Returns a decoded frame by one-based index.

```lua
LAnimatedImage:getFrame(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | One-based frame index. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Decoded frame image. |

**Example**

```lua
do
    local frame = lurek.image.newImageData(2, 2)
    frame:fill(20, 40, 80, 255)
    lurek.image.saveGIF({ frame, frame }, "save/example_anim_frame.gif", { delayMs = 30 })
    local animated = lurek.image.loadAnimated("save/example_anim_frame.gif")
    local first = animated:getFrame(1)
    lurek.log.info("[image] first frame width=" .. tostring(first:getWidth()))
end
```

---

#### `LAnimatedImage:getFrames`

Returns all decoded frame images as an array.

```lua
LAnimatedImage:getFrames()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of `[LImageData](#limagedata)` values. |

**Example**

```lua
do
    local frame = lurek.image.newImageData(2, 2)
    frame:fill(80, 40, 20, 255)
    lurek.image.saveGIF({ frame, frame }, "save/example_anim_frames.gif", { delayMs = 30 })
    local animated = lurek.image.loadAnimated("save/example_anim_frames.gif")
    local frames = animated:getFrames()
    lurek.log.info("[image] frames table=" .. tostring(#frames))
end
```

---

#### `LAnimatedImage:type`

Returns the Lua-visible type name.

```lua
LAnimatedImage:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LAnimatedImage](#lanimatedimage)`. |

**Example**

```lua
do
    local frame = lurek.image.newImageData(2, 2)
    frame:fill(1, 2, 3, 255)
    lurek.image.saveGIF({ frame, frame }, "save/example_anim_type.gif", { delayMs = 30 })
    local animated = lurek.image.loadAnimated("save/example_anim_type.gif")
    local kind = animated:type()
    lurek.log.info("[image] animated type=" .. kind)
end
```

---

#### `LAnimatedImage:typeOf`

Returns whether this handle matches a supported type name.

```lua
LAnimatedImage:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches. |

**Example**

```lua
do
    local frame = lurek.image.newImageData(2, 2)
    frame:fill(1, 2, 3, 255)
    lurek.image.saveGIF({ frame, frame }, "save/example_anim_typeof.gif", { delayMs = 30 })
    local animated = lurek.image.loadAnimated("save/example_anim_typeof.gif")
    local ok = animated:typeOf("LObject")
    lurek.log.info("[image] animated typeOf=" .. tostring(ok))
end
```

---

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

    local ok, cdata = pcall(lurek.image.newCompressedData, "content/examples/assets/images/sample_normal.dds")
    local w, h = 0, 0
    if ok then
        w, h = cdata:getDimensions()
    end
    local status = ok and (w .. "x" .. h) or "unsupported in PNG runtime"
    lurek.log.info("compressed = " .. status)
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

    local ok, cdata = pcall(lurek.image.newCompressedData, "content/examples/assets/images/sample_normal.dds")
    local w = ok and cdata:getWidth() or 0
    local h = ok and cdata:getHeight() or 0
    local format = ok and cdata:getFormat() or "unsupported"
    lurek.log.info("format = " .. format .. " size=" .. w .. "x" .. h)
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

    local ok, cd = pcall(lurek.image.newCompressedData, "content/examples/assets/images/sample_normal.dds")
    local w = ok and cd:getWidth() or 0
    local h = ok and cd:getHeight() or 0
    local mips = ok and cd:getMipmapCount() or 0
    lurek.log.info("compressed w=" .. w .. " h=" .. h .. " mips=" .. mips)
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

    local ok, cdata = pcall(lurek.image.newCompressedData, "content/examples/assets/images/sample_normal.dds")
    local fmt = ok and cdata:getFormat() or "unsupported"
    local w = ok and cdata:getWidth() or 0
    local h = ok and cdata:getHeight() or 0
    local mips = ok and cdata:getMipmapCount() or 0
    lurek.log.info("mipmaps = " .. mips .. " format=" .. fmt .. " size=" .. w .. "x" .. h)
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

    local ok, cd = pcall(lurek.image.newCompressedData, "content/examples/assets/images/sample_normal.dds")
    local w = ok and cd:getWidth() or 0
    local h = ok and cd:getHeight() or 0
    local mips = ok and cd:getMipmapCount() or 0
    lurek.log.info("compressed w=" .. w .. " h=" .. h .. " mips=" .. mips)
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

    local ok, cdata = pcall(lurek.image.newCompressedData, "content/examples/assets/images/sample_normal.dds")
    local fmt = ok and cdata:getFormat() or "unsupported"
    local w = ok and cdata:getWidth() or 0
    local type_name = ok and cdata:type() or "nil"
    lurek.log.info("type = " .. type_name .. " format=" .. fmt .. " width=" .. w)
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

    local ok, cdata = pcall(lurek.image.newCompressedData, "content/examples/assets/images/sample_normal.dds")
    local fmt = ok and cdata:getFormat() or "unsupported"
    local is_object = ok and cdata:typeOf("LObject") or false
    local is_compressed = ok and cdata:typeOf("LCompressedImageData") or false
    lurek.log.info("typeOf object=" .. tostring(is_object) .. " compressed=" .. tostring(is_compressed) .. " format=" .. fmt)
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
    lurek.log.info("alpha = " .. a)
end
```

---

#### `LImageData:applyEffect`

Applies a named image effect in place, or returns a new image when the effect changes size.

```lua
LImageData:applyEffect(name, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Effect name. |
| `opts?` | table | Effect options such as `factor`, `amount`, `radius`, `levels`, `region`, or `color`. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | nil | New image for size-changing effects, otherwise nil. |

**Example**

```lua
do
    local image = lurek.image.newImageData(4, 4)
    image:fill(20, 30, 40, 255)
    image:applyEffect("invert", { region = { 0, 0, 2, 2 } })
    local r = ({ image:getPixel(0, 0) })[1]
    lurek.log.info("[image] effect red=" .. tostring(r))
end
```

---

#### `LImageData:applyEffects`

Applies a sequence of named effects in order.

```lua
LImageData:applyEffects(effects, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `effects` | table | Array of effect names or `{name=..., opts=...}` tables. |
| `opts?` | table | Default options used by string entries. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | nil | Last new image returned by a size-changing effect, otherwise nil. |

**Example**

```lua
do
    local image = lurek.image.newImageData(4, 4)
    image:fill(20, 30, 40, 255)
    image:applyEffects({ "grayscale", { name = "posterize", opts = { levels = 3 } } })
    local r = ({ image:getPixel(0, 0) })[1]
    lurek.log.info("[image] effects red=" .. tostring(r))
end
```

---

#### `LImageData:applyMask`

Multiplies this image alpha by another image's alpha channel.

```lua
LImageData:applyMask(mask)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mask` | [LImageData](#limagedata) | Same-sized alpha mask image. |

**Example**

```lua
do
    local image = lurek.image.newImageData(2, 2)
    local mask = lurek.image.newImageData(2, 2)
    image:fill(255, 255, 255, 255)
    mask:fill(0, 0, 0, 128)
    image:applyMask(mask)
    lurek.log.info("[image] mask applied")
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
    lurek.log.info("palette LUT applied")
end
```

---

#### `LImageData:applyShader`

Applies an offline image shader and returns the processed image.

```lua
LImageData:applyShader(shader, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shader` | [LShader](render.md#lshader) | Image-target shader. |
| `opts?` | table | Optional processing options. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Processed image. |

**Example**

```lua
do
    local image = lurek.image.newImageData(4, 4)
    image:fill(40, 80, 160, 255)
    local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(1.0 - color.r, color.g, uv.x, color.a);
}
]], { target = "image" })
    local output = image:applyShader(shader)
    local r, g, b, _ = output:getPixel(0, 0)
    lurek.log.info("[image] shader output=" .. output:getWidth() .. "x" .. output:getHeight() .. " pixel=" .. r .. "," .. g .. "," .. b)
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
    lurek.log.info("blitted")
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
    lurek.log.info("blurred " .. blurred:getWidth() .. "x" .. blurred:getHeight() .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
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
    lurek.log.info("brightness sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LImageData:clone`

Returns a deep copy of this image data.

```lua
LImageData:clone()
```

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Copied image data. |

**Example**

```lua
do
    local image = lurek.image.newImageData(4, 4)
    image:fill(10, 20, 30, 255)
    local copy = image:clone()
    copy:setPixel(0, 0, 255, 0, 0, 255)
    lurek.log.info("[image] clone width=" .. tostring(copy:getWidth()))
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
    lurek.log.info("contrast sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
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
    lurek.log.info("convolved " .. result:getWidth() .. "x" .. result:getHeight() .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LImageData:copyRegion`

Copies a rectangular region into a new image.

```lua
LImageData:copyRegion(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Source x coordinate. |
| `y` | number | Source y coordinate. |
| `w` | number | Region width. |
| `h` | number | Region height. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Copied region. |

**Example**

```lua
do
    local image = lurek.image.newImageData(8, 8)
    image:fill(20, 30, 40, 255)
    local region = image:copyRegion(2, 2, 4, 4)
    local w, h = region:getDimensions()
    lurek.log.info("[image] copied region=" .. tostring(w) .. "x" .. tostring(h))
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
    lurek.log.info("cropped " .. cropped:getWidth() .. "x" .. cropped:getHeight() .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
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
    lurek.log.info("diff score = " .. score)
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
    lurek.log.info("circle drawn on " .. dims .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
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
    lurek.log.info("line drawn on " .. dims .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
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
    lurek.log.info("rect drawn on " .. dims .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
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
    lurek.log.info("encoded " .. #bytes .. " bytes from raw=" .. #raw)
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
    lurek.log.info("filled blue " .. w .. "x" .. h .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
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
    lurek.log.info("flipped h, corner r = " .. r)
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
    lurek.log.info("flipped v, corner g = " .. g)
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
    lurek.log.info("gamma sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
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
    lurek.log.info("dimensions = " .. w .. "x" .. h .. " bytes=" .. #raw)
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
    lurek.log.info("height = " .. height .. " width=" .. width)
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
    lurek.log.info("pixel = " .. r .. "," .. g .. "," .. b .. "," .. a .. " width=" .. width)
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
    lurek.log.info("raw bytes = " .. #raw .. " width=" .. width)
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
        lurek.log.info("region " .. region:getWidth() .. "x" .. region:getHeight())
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
    lurek.log.info("string bytes = " .. #str .. " height=" .. height)
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
    lurek.log.info("width = " .. width .. " height=" .. height)
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
    lurek.log.info("gray r=" .. r .. " g=" .. g .. " b=" .. b)
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
    lurek.log.info("inverted r=" .. r .. " g=" .. g .. " b=" .. b)
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
    lurek.log.info("mapped pixels to half brightness")
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
    lurek.log.info("gradient mapped")
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
    lurek.log.info("noise sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
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
    lurek.log.info("pasted")
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
    lurek.log.info("posterized sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
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
    lurek.log.info("resized = " .. resized:getWidth() .. "x" .. resized:getHeight() .. " center_r=" .. center .. " bytes=" .. #raw)
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
    lurek.log.info("nearest = " .. resized:getWidth() .. "x" .. resized:getHeight() .. " center_g=" .. center .. " bytes=" .. #raw)
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
    lurek.log.info("rotated = " .. rotated:getWidth() .. "x" .. rotated:getHeight() .. " marker_r=" .. marker .. " bytes=" .. #raw)
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
    lurek.log.info("saturation sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
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
    lurek.log.info("sepia sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
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
    lurek.log.info("set pixel = " .. r .. "," .. g .. "," .. b .. "," .. a .. " width=" .. width)
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
    lurek.log.info("raw data set sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
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
    lurek.log.info("sharpened " .. sharp:getWidth() .. "x" .. sharp:getHeight() .. " sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
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
    lurek.log.info("threshold sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
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
    lurek.log.info("tint sample=" .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LImageData:transform`

Returns a transformed image, currently supporting high-quality resize through `width`, `height`, and `filter`.

```lua
LImageData:transform(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | table | Transform options. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Transformed image. |

**Example**

```lua
do
    local image = lurek.image.newImageData(4, 4)
    image:fill(5, 10, 15, 255)
    local resized = image:transform({ width = 8, height = 6, filter = "linear" })
    local w, h = resized:getDimensions()
    lurek.log.info("[image] transformed=" .. tostring(w) .. "x" .. tostring(h))
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
    lurek.log.info("type = " .. type_name .. " sample_r=" .. r)
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
    lurek.log.info("is ImageData = " .. tostring(is_image) .. " object=" .. tostring(is_object))
end
```

---

## LImageShaderJob

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LImageShaderJob:cancel`

Cancels this pending offline image shader job.

```lua
LImageShaderJob:cancel()
```

**Example**

```lua
do
    local image = lurek.image.newImageData(2, 2)
    image:fill(70, 80, 90, 255)
    local shader = lurek.render.newShader("@fragment fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> { return color; }", { target = "image" })
    local job = lurek.image.requestShader(image, shader)
    job:cancel()
    local output = job:poll()
    lurek.log.info("[image] shader cancel output=" .. tostring(output))
end
```

---

#### `LImageShaderJob:poll`

Returns the shader output image when the job has completed, or nil if pending/cancelled.

```lua
LImageShaderJob:poll()
```

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Completed image result. |

**Example**

```lua
do
    local image = lurek.image.newImageData(2, 2)
    image:fill(10, 20, 30, 255)
    local shader = lurek.render.newShader("@fragment fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> { return color; }", { target = "image" })
    local job = lurek.image.requestShader(image, shader)
    local output = job:poll()
    local ready = output ~= nil and output:getWidth() == image:getWidth()
    lurek.log.info("[image] shader poll ready=" .. tostring(ready))
end
```

---

#### `LImageShaderJob:wait`

Waits for the offline image shader job and returns its output image.

```lua
LImageShaderJob:wait(timeoutMs)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `timeoutMs?` | number | Optional timeout in milliseconds. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](#limagedata) | Completed image result. |

**Example**

```lua
do
    local image = lurek.image.newImageData(2, 2)
    image:fill(40, 50, 60, 255)
    local shader = lurek.render.newShader("@fragment fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> { return color; }", { target = "image" })
    local job = lurek.image.requestShader(image, shader)
    local output = job:wait(100)
    local done = output ~= nil and output:getHeight() == image:getHeight()
    lurek.log.info("[image] shader wait done=" .. tostring(done))
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
    lurek.log.info("added layer at index " .. idx .. " layers=" .. count .. " sample_a=" .. select(4, layer:getPixel(0, 0)))
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
    lurek.log.info("layered size = " .. width .. "x" .. height .. " layers=" .. count)
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
    lurek.log.info("layer " .. idx .. " size=" .. data:getWidth() .. "x" .. data:getHeight() .. " sample_g=" .. g)
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
    lurek.log.info("layer " .. idx .. " name=" .. name .. " count=" .. count)
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
    lurek.log.info("opacity = " .. opacity .. " visible=" .. tostring(visible))
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
    lurek.log.info("layered size = " .. width .. "x" .. height .. " layers=" .. count)
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
    lurek.log.info("visible hidden=" .. tostring(hidden) .. " restored=" .. tostring(restored))
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
    lurek.log.info("layers " .. empty .. " -> " .. total)
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
    lurek.log.info("merged " .. merged:getWidth() .. "x" .. merged:getHeight() .. " sample_r=" .. sample)
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
    lurek.log.info("moved: first is now " .. li:getName(1))
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
    lurek.log.info("layers " .. before .. " -> " .. after .. " first=" .. first)
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
    lurek.log.info("layered image saved layers=" .. li:layerCount() .. " sample_a=" .. select(4, merged:getPixel(0, 0)))
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
    lurek.log.info("layer replaced width=" .. li:getLayer(1):getWidth() .. " sample_r=" .. sample)
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
    lurek.log.info("new name = " .. name .. " count=" .. count)
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
    lurek.log.info("opacity = " .. opacity .. " merged=" .. dims)
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
    lurek.log.info("visible hidden=" .. tostring(hidden) .. " restored=" .. tostring(restored))
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
    lurek.log.info("after swap: 1=" .. li:getName(1) .. " 2=" .. li:getName(2))
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
    lurek.log.info("type = " .. type_name .. " layered=" .. tostring(is_layered) .. " object=" .. tostring(is_object))
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
    lurek.log.info("type = " .. type_name .. " layered=" .. tostring(is_layered) .. " object=" .. tostring(is_object))
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
    lurek.log.info("LUT cleared, colors = " .. lut:getColorCount())
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
    lurek.log.info("palette cycled")
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
    lurek.log.info("color count = " .. lut:getColorCount())
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
    lurek.log.info("red → green mapping set")
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
    lurek.log.info("type = " .. lut:type())
    lurek.log.info("is PaletteLUT = " .. tostring(lut:typeOf("LPaletteLUT")))
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
    lurek.log.info("type = " .. lut:type())
    lurek.log.info("is PaletteLUT = " .. tostring(lut:typeOf("LPaletteLUT")))
end
```

---

## LUnknown

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LUnknown:adjacencies`

Returns province adjacency records and shared border pixel counts.

```lua
LUnknown:adjacencies()
```

**Returns**

| Type | Description |
|------|-------------|
| LUnknownAdjacenciesResult | Array table with `province_a`, `province_b`, and `border_pixels` fields. |

---

#### `LUnknown:borderSegments`

Returns border line segments between neighboring provinces.

```lua
LUnknown:borderSegments()
```

**Returns**

| Type | Description |
|------|-------------|
| LUnknownBorderSegmentsResult | Array table with province ids and segment coordinates. |

---

#### `LUnknown:deserializeShapeData`

Decodes serialized province shape data into span and segment tables.

```lua
LUnknown:deserializeShapeData(bytes)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bytes` | string | Serialized shape data bytes. |

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Table with `spans` and `segments`, or nil when decoding fails. |

---

#### `LUnknown:drawShapes`

Queues filled polygon draw commands for province shapes, optionally culled to a viewport rect.

```lua
LUnknown:drawShapes(x, y, w, h)
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

---

#### `LUnknown:getAt`

Returns the province id stored at grid coordinates.

```lua
LUnknown:getAt(x, y)
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

---

#### `LUnknown:getHeight`

Returns the province grid height. This method is available to Lua scripts.

```lua
LUnknown:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Grid height in pixels. |

---

#### `LUnknown:getPolygons`

Returns polygon rings for every province.

```lua
LUnknown:getPolygons()
```

**Returns**

| Type | Description |
|------|-------------|
| LUnknownGetPolygonsResult | Array table of province polygon records with `province_id` and `rings` fields. |

---

#### `LUnknown:getPolygonsSimplified`

Returns simplified polygon rings for every province.

```lua
LUnknown:getPolygonsSimplified()
```

**Returns**

| Type | Description |
|------|-------------|
| LUnknownGetPolygonsSimplifiedResult | Array table of simplified province polygon records with `province_id` and `rings` fields. |

---

#### `LUnknown:getWidth`

Returns the province grid width. This method is available to Lua scripts.

```lua
LUnknown:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Grid width in pixels. |

---

#### `LUnknown:provinceCount`

Returns the number of distinct provinces in the grid.

```lua
LUnknown:provinceCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Province count. |

---

#### `LUnknown:provinceSpans`

Returns horizontal province spans by row.

```lua
LUnknown:provinceSpans()
```

**Returns**

| Type | Description |
|------|-------------|
| LUnknownProvinceSpansResult | Array table with `province_id`, `y`, `x0`, and `x1` fields. |

---

#### `LUnknown:serializeShapeData`

Serializes province span and border shape data into a binary Lua string.

```lua
LUnknown:serializeShapeData()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Serialized shape data bytes. |

---

#### `LUnknown:type`

Returns the Lua-visible type name for this province grid handle.

```lua
LUnknown:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `LProvinceGrid`. |

---

#### `LUnknown:typeOf`

Returns whether this province grid handle matches a supported type name.

```lua
LUnknown:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `LProvinceGrid` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

---
