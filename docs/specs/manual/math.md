# math manual spec overlay

## TL;DR

- Provides vectors, matrices, spatial indexes (AABB tree and spatial hash), and polygon geometry.
- Supports splines, Bézier curves, tweens with easing, seedable randoms, and loot pity-trackers.
- Centralizes core mathematical formulas to guarantee consistent, drift-free engine behaviors.

## Summary

- The `math` module is the engine's shared numerical and geometric foundation for users who need consistent rules for coordinates, shapes, transforms, interpolation, sampling, and spatial reasoning across many feature areas.
- Its primary role is standardization. When rendering, physics, pathfinding, camera logic, UI layout, procedural generation, and gameplay helpers all rely on the same vector, matrix, angle, and shape vocabulary, the rest of the engine can cooperate without hidden conversions or drifting assumptions.
- Core vector and matrix types provide the base language for position, direction, orientation, scale, projection, and composition. They are the primitives that let modules talk about where something is, how it is rotated, how it moves, and how one space maps into another.
- Geometry helpers extend the module beyond raw numbers into practical spatial entities such as rectangles, circles, polygons, bounds, overlap tests, distance checks, clipping helpers, and containment queries used across collision, UI, culling, and selection.
- Transform logic is another major category. Translation, rotation, scale, matrix composition, inversion, and coordinate-space conversion allow scripts and subsystems to move between local, world, map, and screen representations without ambiguous manual math.
- Curve, easing, interpolation, and value-shaping helpers matter because motion paths, camera rails, UI transitions, scripted effects, and numeric blending all depend on shared progression rules rather than bespoke formulas.
- Spatial indexing and applied algorithms broaden the module from calculation into organization, giving larger systems reusable structures and geometric building blocks for broad phases, region construction, and procedural workflows.
- That common layer is important because spatial bugs usually come from disagreement, not from missing arithmetic. If one system treats a rectangle as inclusive, another applies a different rotation convention, and a third projects coordinates with a slightly different transform order, the engine becomes hard to trust even when each local feature appears reasonable in isolation.
- The module therefore acts as an agreement surface as much as a utility library. It gives neighboring systems one place to inherit conventions for handedness, angle normalization, interpolation behavior, projection rules, and coordinate conversion semantics.
- For rendering-oriented code this means predictable transforms and projection helpers. For physics-adjacent code it means stable distances and shape math. For UI and tooling code it means reliable hit testing and viewport conversion.
- Curve support broadens the module from rigid geometry into authored motion and data shaping. Bézier curves, splines, and similar helpers give camera paths, animation support systems, road generation, region shaping, and tool previews a common language for smooth trajectories and contours.
- Broad-phase and indexing helpers give the module a structural role too. Large feature sets often need partitioning, bucketing, or neighborhood lookup before they can do more expensive per-object reasoning, and those patterns are easier to keep correct when they reuse engine-level math primitives and bounds semantics.
- Determinism is another reason the module matters. Tests, replays, serialized tools, and visual evidence workflows depend on math behavior that is reproducible enough to compare, inspect, and trust across runs.
- Sampling and value-shaping helpers belong here for the same reason: even small operations such as remapping, clamping, wrapping, and parameter evaluation become more reliable when they reuse one engine-wide numeric vocabulary.
- World generation and simulation tools also lean on this layer because geometric construction rarely stays confined to one subsystem. Voronoi-like helpers, region assembly, contour processing, and transform composition often need to interoperate with render views, province maps, physics queries, or camera framing.
- The module therefore acts as a substrate for both high-level and low-level work, and it gives tools and tests a deterministic numerical layer they can trust.
- Read `math` as the place where the engine standardizes numeric and geometric reasoning across the rest of the project for code, tools, and tests alike.

This module primarily collaborates with `globe`, `image`. Its responsibility should stay inside the Foundations group rather than absorb behavior owned by those neighbors.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
