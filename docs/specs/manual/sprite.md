# sprite manual spec overlay

## TL;DR

- Manages 2D sprites, JSON atlases, animation sheets, nine-slice panels, and lit-sprite normal-map state.
- Supports sprite batching.

## Summary

- The `sprite` module is the engine's textured-2D surface for users who want single sprites, sheets, atlases, scalable panels, and batched instances to share one coherent runtime model.
- It unifies several common 2D visual patterns that often become fragmented in smaller engines: stand-alone images, atlas regions, sheet-based animation helpers, batched draws, and resizable textured panels all belong to the same family here.
- Atlas support matters because production assets are frequently packed, and a sprite system that does not understand regions and packing semantics quickly forces users into repetitive coordinate plumbing.
- Sheet-oriented helpers broaden the feature into frame-driven presentation while still staying lighter-weight than the more general `animation` module.
- Nine-slice and panel-oriented support matter because many projects mix game objects with UI-like scalable textured elements and still want one shared textured-visual layer.
- Batching support gives the module practical performance value while keeping atlas, panel, and instance behavior inside one shared textured-2D model.
- That shared model is especially useful when gameplay visuals and UI-adjacent textured elements overlap, because one subsystem can describe ordinary sprites, atlas regions, simple frame sequences, and scalable panels without forcing users to jump between unrelated feature surfaces.
- `image` owns raw pixel assets and `render` performs final drawing, while `sprite` owns the runtime model for textured 2D instances, atlases, sheets, and related presentation helpers.

This module primarily collaborates with `animation`, `color`, `image`, `math`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
