# spine manual spec overlay

## TL;DR

- Simulates skeletal rigs using bone hierarchies, slots, skin swaps, and target IK.

## Summary

- The `spine` module is the skeletal-animation surface for users who want bone-based rigs, slots, skins, and timeline-driven pose changes inside the engine.
- Bones, IK constraints, importers, skeleton state, slots, timelines, and render bridges work together so the same module can load authored rigs, pose them at runtime, and expose the result to the rest of the visual stack.
- That matters because skeletal animation is more than playback: projects also need skin changes, attachment control, hierarchy updates, and pose solving that stay coherent across several animation clips.
- Import support makes the module practical for authored content workflows, while runtime skeleton control keeps it useful for gameplay-driven animation changes after import.
- Runtime events, attachment swaps, and skin changes are especially important because skeletal content often needs to react to equipment, status, or scripted actions without reauthoring the rig itself.
- Constraint solving is a major part of the value, because believable skeletal motion often depends on live bone relationships rather than on clip playback alone.
- That keeps imported rigs flexible at runtime.
- Read `spine` as the owner of skeletal rig state and timeline evaluation.

This module primarily collaborates with `image`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
