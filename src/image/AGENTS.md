# Image Module Contract

## Mission & Scope
- Own bounded CPU RGBA buffers, pixel effects, palettes, layered composition, codecs, and generic atlas preparation.
- Leave runtime sprites, GPU work, and province data to their own modules.

## Files
- `image_data.rs`, `limits.rs`: Pixel buffers and resource limits.
- `effects.rs`, `layers.rs`, `palette_lut.rs`: Pixel changes and composition.
- `serial.rs`, `compressed.rs`, `animated_gif.rs`: Bounded codecs.
- `rect_packing.rs`, `texture.rs`: Generic atlas preparation and texture data.

## Rules
- Create buffers through a checked `ImageLimits` path.
- Check dimensions, byte counts, frame/layer totals, decode output, and work limits before allocation or loops.
- Reject non-finite Lua values before mutation. A failed effect, callback, or codec must leave old state unchanged.
- Lua file paths use GameFS. Codecs return bounded bytes; the filesystem owner approves writes.
- Reject bad lengths, unsupported versions, invalid text, and trailing codec data.
- `image` owns generic packing. `sprite` owns runtime regions. `render` owns GPU resources.

## Workflow
- Run `cargo test --test image_tests` and the image Lua security tests.
- Regenerate docs after public Lua signature or docstring changes.
