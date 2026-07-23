# Image Module Contract

## Mission & Scope
- Own bounded CPU RGBA buffers, pixel effects, palettes, layered composition, codecs, and generic atlas preparation.
- Leave runtime sprites, GPU execution, province topology, animation policy, and domain diagnostics with their canonical owners.

## Files
- `limits.rs` owns shared image resource ceilings; `image_data.rs` owns bounded CPU RGBA allocation and mutation.
- `serial.rs` and `animated_gif.rs` own bounded byte codecs; `layers.rs` and `rect_packing.rs` own image-domain composition and packing.
- `src/lua_api/image_api.rs` is the validation and GameFS adapter, not a second image implementation.

## Rules
- Construct buffers through `ImageData::try_new_with_limits` or a checked equivalent using `ImageLimits`.
- Check dimensions, bytes, aggregate frames/layers, decompression output, and multiplied work before allocation or iteration.
- Treat Lua inputs as untrusted; reject non-finite effect values and preserve state on callback, codec, or chain failure.
- Lua paths use `GameFS` only; image encodes bounded bytes while GameFS authorizes atomic writes.
- Keep codec parsing bounded and transactional; reject malformed lengths, invalid UTF-8, unsupported versions, and trailing records.
- Keep `mod.rs` export-only and do not import feature-system state upward into image.
- `image` owns the generic rectangle packer; sprite owns runtime region metadata and render owns GPU resources.
- Put Rust seam tests in `tests/rust/unit/image_tests.rs` and hostile Lua tests in `tests/lua/security/test_image_security.lua`.

## Workflow
- Run `cargo test --test image_tests`, `cargo test --test lua_tests`, and relevant image audits after behavior changes.
- Regenerate docs when Lua docstrings or public signatures change.
