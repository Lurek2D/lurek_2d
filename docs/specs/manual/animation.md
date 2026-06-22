# animation manual spec overlay

## TL;DR

- Orchestrates sprite animation playback and processes Aseprite JSON imports.
- Manages parameter state networks with crossfading and Spine skeletons.
- Controls layered weighted blending, keyframe curves, and phase sync.

## Summary

- The `animation` module is the engine's time-based motion system for users who need sprites, poses, and related visual states to advance through structured runtime playback.
- Clips, frames, controllers, state machines, sync groups, events, blending, and curve handling live together here so simple loops and richer motion behavior share one model.
- Animation is not only frame stepping; it also needs transitions, timing hooks, authored state changes, and gameplay-aware playback control.
- Runtime events make the module useful beyond visuals, since footsteps, attack windows, cutscene timing, and other logic often need to fire from the animation timeline.
- Blend and sync-group support matter because animated systems often need continuity across states or coordinated playback across several visual parts instead of abrupt clip swaps.
- Aseprite import and Spine bridging keep the feature aligned with common art pipelines, while the shared timeline model gives teams one place to reason about authored motion timing for gameplay, tools, and preview behavior.
- State-machine support matters because animation behavior usually depends on more than a current clip. Characters, UI elements, effects, and tools often need explicit transitions, guard conditions, and coordinated playback states that remain inspectable instead of being hidden in scattered script logic.
- Timeline events also help gameplay and motion stay synchronized.
- This makes `animation` useful for straightforward sprite loops and richer authored motion systems where timing, transitions, and events need to stay deterministic enough for debugging, preview, and gameplay integration.
- `render` shows the result and `spine` specializes skeletal rigs, but `animation` owns clip selection, transitions, and timeline advancement.

This module primarily collaborates with `image`, `math`, `render`, `runtime`, `spine`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
