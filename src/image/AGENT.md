# `image` — Agent Reference

| Property       | Value                                                |
|----------------|------------------------------------------------------|
| **Tier**       | Tier 1 — Core Engine Subsystems                      |
| **Status**     | Implemented — Full                                   |
| **Lua API**    | `luna.img`                                         |
| **Source**     | `src/image/`                                         |
| **Rust Tests** | `tests/rust/unit/image_tests.rs`                     |
| **Lua Tests**  | `tests/lua/unit/test_image.lua`                      |
| **Architecture** | See `specs/image.md` — 4 source files, 20 CPU effects, thin Lua wrapper |

## Purpose

The `image` module provides CPU-side pixel-level access to RGBA image data. It is the raw pixel layer that sits beneath the GPU texture pipeline — `ImageData` is never on the GPU until explicitly uploaded via the graphics API (`luna.gfx.newImage(imgdata)`). The module covers three distinct concerns: uncompressed RGBA pixel buffers (`ImageData`), GPU-compressed DDS texture containers (`CompressedImageData`), and colour palette lookup tables for shader-based palette swapping (`PaletteLUT`).

## Source Files

| File             | Purpose                                                                                       |
|------------------|-----------------------------------------------------------------------------------------------|
| `image_data.rs`  | CPU-side RGBA8 pixel buffer: per-pixel access, paste, map, PNG encode, `mlua::UserData` impl |
| `effects.rs`     | 20 image-processing effects: brightness, contrast, saturation, gamma, tint, grayscale, sepia, invert, threshold, posterize, fill, noise, alpha_mask, flip_horizontal, flip_vertical, rotate_90_cw, crop, resize_nearest, blur, sharpen |
| `compressed.rs`  | DDS/DXT compressed GPU texture container with format detection and loading                    |
| `palette_lut.rs` | Colour palette lookup table mapping source colours to target colours                          |

## Key Types

| Type                  | Kind   | Location            | Description                                          |
|-----------------------|--------|---------------------|------------------------------------------------------|
| `ImageData`           | struct | `image_data.rs`     | CPU-side RGBA8 pixel buffer; also implements 20 effects via `effects.rs` |
| `CompressedImageData` | struct | `compressed.rs`     | DDS compressed texture data for direct GPU upload    |
| `CompressedFormat`    | enum   | `compressed.rs`     | Format tag: Dxt1/Dxt3/Dxt5/Bc7/Etc1/Etc2…           |
| `PaletteLUT`          | struct | `palette_lut.rs`    | Source→target colour map for palette-swap shaders    |

## Lua API Summary

| Namespace / Method           | Description                                                     |
|------------------------------|-----------------------------------------------------------------|
| `luna.img.newImageData(w,h)` | Create blank RGBA8 buffer                                       |
| `luna.img.newImageData(fn)`  | Load PNG/JPEG from game directory                               |
| `luna.img.newCompressedData` | Load DDS file as CompressedImageData                            |
| `luna.img.isCompressed`      | Check if path is a DDS file                                     |
| **ImageData core**           | `getWidth`, `getHeight`, `getDimensions`, `getPixel`, `setPixel`, `mapPixel`, `encode`, `getString`, `paste` |
| **Color/Tone (in-place)**    | `brightness`, `contrast`, `saturation`, `gamma`, `tint`         |
| **Filters (in-place)**       | `grayscale`, `sepia`, `invert`, `threshold`, `posterize`, `fill`, `noise`, `alphaMask` |
| **Geometric in-place**       | `flipHorizontal`, `flipVertical`                                |
| **Geometric new-image**      | `rotate90cw`, `crop`, `resizeNearest`                           |
| **Convolution new-image**    | `blur`, `sharpen`                                               |

## Full Specification

All architecture diagrams, detailed type documentation, Lua API reference, examples, and cross-module references live in the consolidated spec:

→ [`specs/image.md`](../../specs/image.md)

_Update both this file **and** `specs/image.md` whenever source files, public types, or Lua bindings change._
