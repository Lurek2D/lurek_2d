# IDEA.md — `image` module

> Migrated from `ideas/features/image.md` and `ideas/performance/12-image-cpu-pixel-ops.md`.
> Status checked against `src/image/` and `src/lua_api/image_api.rs`.
> Lua namespace: `lurek.image`.

---

## Features

### ✅ DONE — Resize (Nearest + Bilinear)
**Source**: features/image.md — Feature Gaps #4

`resizeNearest(w, h)` (line ~668) and `resize(w, h)` with bilinear interpolation (line ~740)
both implemented in `image_api.rs`.

---

### ✅ DONE — Flip Horizontal / Vertical
**Source**: features/image.md — Feature Gaps #5

`flipHorizontal()` (line ~626) implemented. Verify `flipVertical()` exists too.

---

### ✅ DONE — Grayscale
**Source**: features/image.md — Feature Gaps #6

`grayscale()` implemented in `image_api.rs` (line ~562).

---

### ✅ DONE — Blit (Porter-Duff Composite)
**Source**: features/image.md — Feature Gaps #2

`blit(src, dstX, dstY)` with Porter-Duff over compositing implemented (line ~755).

---

### ✅ DONE — Mipmap Support
**Source**: features/image.md — Feature Gaps #3

`getMipmapCount()` implemented (line ~240). Mipmap generation present in `image/texture.rs`.

---

### ❌ TODO — Screen Pixel Readback
**Source**: features/image.md — Feature Gaps #1 / Suggestions #1

No `lurek.image.fromScreen()` or GPU texture readback found. Needed for screenshot,
visual testing, and post-processing Lua pipelines. GPU readback must be async
(submit → poll next frame) — design carefully to avoid pipeline stall.

---

### ✅ DONE — Palette LUT Application via Lua
**Source**: features/image.md — Feature Gaps #8

`lurek.img.newPaletteLut()` factory added; `image:applyPaletteLut(lut)` method exposed.
`PaletteLUT::apply(&mut ImageData)` added to `src/image/palette_lut.rs`.
Lua API: `lut:setColor(fr,fg,fb,fa, tr,tg,tb,ta)`, `lut:getColorCount()`, `lut:clear()`.

---

### ✅ DONE — Sub-Image Extraction
**Source**: features/image.md — Feature Gaps #7 / Suggestions #3

`image:crop(x, y, w, h)` (alias `getRegion`) already existed in `image_api.rs`.
Satisfies the sub-region extraction need.

---

### ✅ DONE — Pixel Convolution (Blur, Sharpen, Edge Detect)
**Source**: features/image.md — Feature Gaps #9 / Suggestions #4

`image:convolve(kernel_table, ksize)` method added in `image_api.rs`.
`ImageData::convolve(&[f64], ksize) -> Result<ImageData, String>` added to `src/image/effects.rs`.
Supports arbitrary N×N kernels (ksize must be odd); edges are clamped; alpha is preserved.

---

## Performance

### ✅ DONE — Parallel Pixel Operations (rayon)
**Source**: performance/12-image-cpu-pixel-ops.md

11 pure pixel transform functions in `src/image/effects.rs` now use `map_pixel_par`
(rayon-backed, 65 536-pixel threshold) instead of `map_pixel`:
`brightness`, `contrast`, `saturation`, `gamma`, `tint`, `grayscale`, `sepia`, `invert`,
`threshold`, `posterize`, `fill`.  The `tint` function was refactored to an inline closure
for `Send + Sync` compliance.  `threshold` and `posterize` use `move` closures to capture
`Copy` values correctly.
