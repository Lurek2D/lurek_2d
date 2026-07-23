# render manual spec overlay

## TL;DR

- Orchestrates the engine's visual backend using a device-facing wgpu renderer.
- Supports shapes, batched textures, off-screen canvases, and dynamic font rasterization.
- Enables custom WGSL shaders, chained post-processing filters, and stencil portal masks.
- Projects 3D Wavefront models into 2D vertex meshes with software screenshot readbacks.

## Summary

- The `render` module is the engine's central visual execution layer, responsible for turning high-level drawing intent from many other systems into concrete frame output on GPU-backed and software-backed paths.
- Its most important user-facing role is normalization. Different modules can describe sprites, shapes, text, overlays, tiles, provinces, lights, effects, or custom geometry in their own terms while still relying on one shared renderer to decide how those requests become final pixels.
- This makes `render` less like one feature among many and more like the final translation authority for visual state. Other modules decide what should exist visually, but `render` decides how that existence is encoded, ordered, shaded, and emitted.
- The module spans several rendering families at once: sprite and texture drawing, text output, shape drawing, mesh and geometry support, canvas-like targets, shader pipelines, post-processing, lighting, shadows, decals, screenshots, and software-render evidence paths.
- GPU resource ownership is a core part of that responsibility. Buffers, textures, samplers, shader modules, bind groups, pipelines, intermediate targets, typed GPU-side records, and staging resources live here so the rest of the engine does not fragment backend management.
- Resource inputs are validated before backend allocation or shader-source generation: texture and canvas dimensions must be non-zero and within device limits, RGBA uploads must match exact byte length, dynamic font atlases are bounded, OBJ material paths must stay under their base directory, and shader uniform names must be valid non-reserved WGSL identifiers.
- Centralizing those resources matters because otherwise each visual feature would invent its own backend conventions, lifetime rules, and upload paths. `render` provides one stable home for those concerns and reduces backend duplication.
- Rendering commands and pipeline structures give the engine a common language between feature modules and execution code. This shared command vocabulary is what allows gameplay-facing APIs to remain expressive while still mapping onto a disciplined backend.
- The module is broader than simple 2D quad drawing. Mesh support, OBJ and MagicaVoxel loading, tessellation, decals, shape batching, and specialized pipelines show that it can represent both standard 2D workflows and richer geometric or stylized visual features without leaving the engine's main render authority.
- MagicaVoxel props flatten their static scene graph once, preserve palette colour, and remove hidden interior faces before entering the existing projected-model path. They are object geometry; raycaster wall, floor, and ceiling terrain remains texture/block driven.
- Text and font integration are part of the same visual surface, not a parallel universe. Menus, labels, debug overlays, editor tools, and evidence images all need text rendering that cooperates with layers, transforms, clipping, and final composition.
- Post-processing support matters after scene composition has already happened. Once a view exists, users often want bloom-like treatments, color transforms, blur-like effects, or custom shader passes, and `render` provides the controlled place where those frame-wide or target-specific effects belong.
- Lighting and shadow support connect scene-level illumination data to actual frame execution. Neighboring modules define lights, occluders, and light-world state, but `render` owns how those concepts become shaded images, masks, and composited outputs.
- Camera-aware and viewport-aware composition are part of the same boundary. Data coming from tilemaps, particles, raycasters, provinces, overlays, and UI all eventually has to agree on transforms, clipping regions, target sizes, and layer order, and `render` is where that agreement is enforced.
- Software-render and capture paths are a major practical capability, not an afterthought. They make it possible to generate deterministic screenshots, evidence images, docs artifacts, test outputs, and headless previews without relying on an interactive GPU session.
- The module therefore serves both runtime presentation and development workflow needs. It is equally relevant when the goal is shipping a frame to the screen and when the goal is extracting a reproducible image for debugging or documentation.
- Render-target management matters for the same reason, because complex scenes often need offscreen surfaces, intermediate passes, and controlled composition order to stay inspectable and stable.
- The renderer is therefore not just a drawer of primitives, but the arbiter of when and where visual work becomes final output.
- That backend discipline is what lets several higher-level modules share one frame pipeline without each inventing its own incompatible render lifecycle.
- For users, the important boundary is that `render` does not usually define domain meaning. It does not decide enemy AI, tile adjacency, or UI layout policy. Instead, it owns the visual execution model that allows those domains to appear consistently.
- Read `render` as the final visual translation layer of the engine. Feature modules describe visual state and intent, and `render` turns that intent into frames, captures, shadows, text, effects, and finished composited output for a shared frame contract.

This module primarily collaborates with `font`, `image`, `light`, `math`, `runtime`, `sprite`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

### Render Input Invariants

- Texture uploads require non-zero width and height, exact RGBA8 byte length, checked pixel arithmetic, and dimensions no larger than the active wgpu device limit.
- Canvas GPU allocations require non-zero width and height within the same 2D texture dimension limit; changing a canvas size under the same key recreates its GPU backing texture.
- Dynamic font creation clamps very small point sizes upward and rejects non-finite, oversized, zero-dimension, or oversized atlas allocations before CPU buffer growth.
- Mesh upload and Lua-facing mesh construction reject non-finite vertex fields, out-of-range indices, and incomplete triangle-list topology before static geometry is synchronized.
- OBJ face indices are bounded after 1-based or negative-index normalization, index zero is invalid, and material-library paths must stay under the supplied base directory.
- Shader uniform names must be valid, non-reserved WGSL identifiers before they can participate in wrapper-source generation.
- Render commands and registered compound shapes pass through a central input sanitizer before backend work; non-finite floats, invalid sizes, out-of-range colors, excessive segments, and malformed point arrays are rejected and counted.
- Arc tessellation clamps zero segment counts to a safe minimum before vertex generation.
- Draw-layer ordering uses total floating-point ordering and callback ID tie-breaks, so NaN and equal depths flush deterministically.
- `RenderDiagnostics` records skipped render commands, missing GPU or shape resources, invalid uploads, invalid meshes, GPU buffer growth, and shader or pipeline cache fallback events without turning the frame into a hard error.
- Frame-local color, texture, draw, instance, merge, and command scratch buffers clear between frames without shrinking; hot flat-color primitives tessellate directly into shared frame buffers and textured paths reuse scratch buffers instead of allocating per command.
- Shadow edge collection filters disabled, masked-out, and out-of-radius occluders before GPU upload, reuses per-occluder world-space edge caches for shadow lights in the same frame, and records rendered shadow rows plus collected and culled edge counts.
- `SoftwareCaptureDiagnostics` records unsupported capture commands and bounded polygon fill behavior; software capture is evidence-oriented and does not promise pixel parity for GPU-only texture, shader, post-fx, layer, batch, or registered-resource commands.

## Notes

- Public `lurek.render` behavior is Lua-first and should keep canonical coverage in `tests/lua/unit/`.
- `src/render/mod.rs` stays export-only; implementation logic belongs in peer files.
- Renderer reliability changes should prefer recoverable errors or skipped invalid draws over panics in frame submission.
- Shader API:
  `lurek.render.newShader(code, opts?)` is the canonical public constructor for WGSL fragment shaders. `opts.target` defaults to `draw` and may be `draw`, `postfx`, `image`, `overlay`, `particle`, `light`, `sprite`, `tilemap`, `mapviz`, `text`, `ui`, or `debugviz`. There is no public `lurek.shader` module; shaders are render resources bound by other modules through `LShader` handles.
- Shader target contracts:
  Fullscreen targets (`postfx`, `image`, `overlay`) share source color, uv, pixel position, resolution, and texel-size inputs; this is the intended contract for palette/LUT grading, heat haze and water distortion, CRT/retro passes, screen transitions such as wipe/dissolve/fade masks, and offline bitmap filters. `image` executes off-screen over RGBA8 `ImageData` and reads back a new `ImageData`. `particle` forwards color, uv, local/world position, velocity, normalized age, lifetime, seed, and sampled texture color. `light` forwards world/light position, normal-map contribution hint, normalized distance, radius, intensity, shadow factor, ambient color, and direction/spot data. `sprite` is a textured material target for sprite recolor, palette swap, team color, damage flash, and dissolve-style fragment effects. `tilemap` is a tile-visual material target for biome tinting, animated water/lava color, fog overlays, and atlas-tile recolor; its current contract exposes tile draw color and uv, with uv set to zero for debug-color primitives. `mapviz` is a command-render visualization target for province and minimap maps; it accepts color, uv, local/pixel position, screen resolution, and texel-size inputs, but province-id or minimap-cell semantic data is still module-owned and not yet forwarded as shader inputs. `text` is a font-atlas target for glyph color/alpha effects, gradient text, glow, outline-like tinting, scanline text, terminal CRT text, and SDF-like experiments; it is activated through `lurek.render.setTextShader` and affects render text commands without changing generic image/sprite draws. `ui` is a terminal/widget surface target for command groups such as `LTerminal:render` and retained widgets emitted by `lurek.ui.draw`; it accepts color, uv, local/pixel position, screen resolution, and texel-size inputs and is intended for CRT terminals, hover/highlight panels, masked UI surfaces, and full-surface UI tinting. `debugviz` is a diagnostic render-command target for non-gameplay overlays such as pathfinding cost fields, physics heatmaps, AI influence maps, flow fields, and runtime inspection layers; it uses the same color/uv/pixel/resolution/texel contract and is activated through `lurek.render.setDebugShader`. Runtime custom shaders are fragment-only; arbitrary user vertex and compute shaders are outside this API.
- Canvas shader passes:
  `LCanvas:applyShader(shader, opts?)` and `lurek.render.applyShaderToCanvas(canvas, shader, opts?)` accept `postfx` shaders and queue a render-owned GPU pass that mutates the canvas render target after its queued draws. The postfx contract is reused because canvas passes operate over a source texture; no separate `canvas` shader target exists until canvas-specific semantic inputs are required.
- Shader ownership:
  Feature modules such as `image`, `effect`, `overlay`, `particle`, `light`, `sprite`, `tilemap`, `province`, `minimap`, `terminal`, `ui`, `parallax`, `raycaster`, and `globe` may store shader handles and semantic binding choices, but WGSL validation, GPU modules, bind groups, pipeline selection, fallback, and frame execution stay in `render`.
- Raycaster shader routing:
  Raycaster surface materials use `draw` shaders. Raycaster shader backgrounds and fullscreen overlays accept `overlay`, `postfx`, or `draw` shaders because they are emitted through render-owned fullscreen/material passes. Raycaster projected emitters use `particle` shaders. The raycaster bridge also forwards semantic auto uniforms including `ray_player_pos`, `ray_screen_size`, `ray_camera_angle`, `ray_fov`, `ray_horizon`, `ray_camera_height`, and `ray_max_distance`.
- Software capture boundary:
  `lurek.raycaster.drawLastScene` and other CPU evidence paths do not execute WGSL. `render` preserves the fallback approximation contract instead: base texture/tint, UV animation, depth-fog composition, and projected particle placement remain visible, but shader code for raycaster materials, fullscreen overlays, and particle effects is skipped.

## Architecture Links

- Intentionally empty.
