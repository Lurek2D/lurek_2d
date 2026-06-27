# image manual spec overlay

## TL;DR

- Manages CPU image buffers, PNG texture loading, layered stacks, palette remapping, and atlases.
- Supports pixel-level effects, nine-slices, compatibility province-grid ingest, and graphical debug visualizations.

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
- Image data can be a source of gameplay structure, but `image` owns the pixel-domain side of that pipeline. Province-specific id extraction, topology, spans, and polygons are owned by `province`.
- That two-way relationship is important: `image` is useful both after a visual asset exists and when visual data is being used as input to another system.
- Serialization and format conversion keep the module connected to the outside world. The same subsystem can move between files, generated runtime state, debugging artifacts, and exported outputs without pushing those conversions into ad hoc helpers.
- That flexibility also makes the module useful for tool-driven inspection as well as asset preparation.
- This makes the module useful across the whole asset lifecycle: load, inspect, transform, compare, pack, export, and sometimes reinterpret as data for another system.
- `render` consumes prepared results, but `image` owns pixel-domain manipulation, inspection, packing, and export before or outside final rendering.
- Read `image` as the engine's pixel-domain authority for asset prep and tooling.

This module primarily collaborates with `animation`, `camera`, `color`, `math`, `province`, `render`, `runtime`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

## Notes

- `lurek.image.newProvinceGrid` remains a compatibility facade for image-origin province data. Canonical province region semantics belong to `province`.
- DDS compressed texture decode is intentionally not part of this runtime build. `isCompressed` can still detect DDS headers for migration/diagnostics, but game textures should load through PNG-backed `newImageData`.
- `ImageData:applyShader` and `lurek.image.requestShader` accept `target = "image"` WGSL shaders and run an off-screen render-owned GPU pass that reads RGBA8 pixels back into `ImageData`.

## Architecture Links

- Intentionally empty.
