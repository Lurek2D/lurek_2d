# tween manual spec overlay

## TL;DR

- Timed interpolation engine supporting easing curves, spring dynamics, and sequence composition with coroutine awaiting.

## Summary

- The `tween` module is the engine's interpolation and motion-sequencing surface for users who want values to change over time without hand-writing frame-by-frame update loops.
- Tweens, handles, chains, grouped sequences, interpolators, and springs all live together here so one-off transitions and larger scripted motion can share one model.
- This matters because many features need shaped progression, not just endpoint changes: UI reveals, camera motion, gameplay feedback, and scripted effects all depend on timing semantics.
- Easing and spring behavior give the module expressive range, while handle-based control makes active transitions inspectable, cancelable, and synchronizable.
- The sequencing surface is important because many real transitions happen in stages instead of one linear interpolation.
- Parallel and chained motion therefore belong in the same subsystem as simple tweens, which keeps authored timing workflows coherent instead of scattering them across unrelated feature code.
- This makes the module suitable not only for decorative polish, but also for stateful workflows where motion is part of how a feature behaves instead of merely how it looks.
- The feature is useful whenever another system decides what should move but still needs reusable rules for how that movement advances over time.
- That separation is what lets several domains share one timing model without sharing any domain-specific update semantics.
- It also gives tools and gameplay code the same language for staged motion and timed value changes.
- The same model also helps previews and iteration stay controllable while motion is active.
- It is therefore as much a sequencing tool as a visual-polish helper.
- The module improves consistency across UI, cameras, overlays, and feedback systems by giving them one temporal vocabulary.
- Read `tween` as the engine's reusable workflow for interpolation, sequencing, and spring-like motion.

This module primarily collaborates with `math`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
