# light manual spec overlay

## TL;DR

- Manages point, spot, and directional lights with custom decay falloffs and groups.
- Coordinates convex polygon occluders, shadow masks, flicker, and transitions.

## Summary

- The `light` module is the engine's shared 2D lighting-data surface for users who need lights, occluders, shadows, and illumination behavior to remain structured before rendering.
- It lets scripts reason about lighting as scene data instead of raw draw commands by grouping light types, falloff, attenuation, blend modes, occlusion, and shadow-related state in one model.
- This matters because atmosphere, visibility, stealth cues, alarms, and scene readability often depend on several changing lights at once.
- Flicker, ramps, fades, and other transitions are part of the contract because lighting is usually dynamic rather than fixed at load time.
- Light-world organization matters too, since several systems may contribute lights and occluders to the same scene and still need one inspectable runtime authority.
- Blend and attenuation semantics are especially important because they control not only whether a light exists, but how strongly it influences surrounding space and how several lights combine visually.
- Occluder-aware behavior is equally important because lights only become useful for scene reasoning when blocking and shadow semantics are modeled alongside them.
- This lets the same subsystem support both atmosphere and gameplay readability, since visibility cues often depend on how light is shaped by world geometry rather than on color alone.
- It also gives tools a stable light-world model to inspect.
- That shared data layer matters whenever gameplay, art direction, and debugging all need to read the same light setup.
- `render` draws the final result, but `light` owns how 2D light entities, falloff, and occlusion semantics are represented together.
- Read `light` as the owner of light definitions and light-world state inside the engine.

This module primarily collaborates with `color`, `image`, `math`, `runtime`. Its responsibility should stay inside the Platform Services group rather than absorb behavior owned by those neighbors.

## Notes

- `lurek.light` is the 2D render-light and occluder module: point/spot/directional scene lights, render occluders, shadow masks, and visual light-world state.
- `lurek.light.createLightsFromTilefield(field, slot, tileset, opts?)` is the canonical consumer-owned adapter for turning tilefield refs plus tileset `renderLight`/`occluder` metadata into render objects. `lurek.tilefield.createLightsFromTileset(...)` remains a compatibility alias during the migration window.
- Custom light shaders are render-time contribution shaders. `LLight:setShader(shader)` and `lurek.light.setShader(shader)` accept only `target = "light"` WGSL and can modify falloff, rim/highlight, color grading, normal-map influence, ambient blending, and shadow response. Shadow casting geometry, occluder masks, and tile lighting remain engine-owned.
- Normal-map data reaches custom light shaders as a compact contribution hint derived from `setNormalMap`, `setNormalStrength`, and light direction. The hint is zero when no normal map is configured.
- `lurek.tilefield` owns the tile data consumed by tile lighting: per-tile `"light"` blockers, transmission costs, and multilevel sun occlusion.
- `lurek.tilelight` owns tile-based environment lighting: grid point lights, ambient light, global top light, and computed RGB/luma layers.
- Do not use `lurek.light` as the source of truth for tile movement, sight, action, or tile-light gameplay semantics.
- Light storage is bounded independently of renderer selection: `max_lights` selects at most 1–256 active lights for rendering, while `LightLimits` caps 4,096 registered lights, 4,096 occluders, 512 vertices per occluder, 65,536 total vertices, and 4,096 exported hints before insertion/export.
- Cookie and normal-map resource keys must be non-empty UTF-8 strings of at most 1,024 bytes. Asset resolution and texture binding remain render/asset responsibilities.
- Debug previews allow at most 4,194,304 pixels and 100,000,000 conservative work units: one direct sample per selected light plus `relevant edges × PCF taps` for shadowed lights (1, 5, or 13 taps).
- `drawToImage` rejects previews whose pixels or conservative pixel/light/occluder-edge work exceed `LightLimits`; it never allocates an unbounded debug bitmap.
- CPU preview rasterization is isolated from `LightWorld` and borrows selected lights and occluder geometry rather than cloning transformed scene polygons. It is debug/evidence-only; GPU rendering remains owned by `render`.
- Occluders require 3–512 finite vertices. Invalid geometry is rejected and leaves existing occluders unchanged.
- A new world enables itself on its first light only until `setEnabled` is called. An explicit disable persists across later additions and `clear`; `clear` removes scene objects and resets ambient without changing that enable decision.
- Cookie paths are authoritative per-light resource references shared by every handle. They are configuration only until renderer cookie sampling is implemented.
- `transitionTo` stores state on the authoritative light and is advanced by `LLight:updateTransition(dt)`; all aliases observe the same progress, but it is not a world-frame animation.
- When eligible lights exceed `max_lights`, renderer and preview selection uses stable insertion order. Removing and re-adding a light gives it a new order at the end of the selection queue.

## Architecture Links

- Intentionally empty.
