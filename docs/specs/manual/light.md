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

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
