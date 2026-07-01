# globe manual spec overlay

## TL;DR

- Manages spherical map registries, orbit shells, shell-aware picking hit tests, and split views.
- Supports layers, multi-shell markers, day-night cycles, LOD annotations, fog-of-war masks, and region routing.

## Summary

- The `globe` module is the planetary-map surface for users who want a world-scale spherical view to behave as a full gameplay and tooling system instead of a decorative background.
- It combines region topology, spherical navigation, camera movement, picking, overlays, labels, markers, fog, lighting, and style control so the globe can serve as a strategic layer, simulation view, or inspectable data surface.
- The module owns both interaction and presentation: users can navigate the sphere, click into it, convert screen interactions into geographic meaning, and layer game-specific information on top.
- Orbit shells extend that surface into a stack of named concentric bands so surface markers, low-orbit markers, high-orbit effects, and shell-specific shaders can stay in one deterministic globe data model instead of becoming unrelated overlays.
- Region adjacency and route helpers matter because many globe-driven games treat the world as a graph of territories, paths, logistics, or influence rather than as a sphere to admire.
- Layer support keeps ownership, heatmaps, tactical overlays, visibility, and markers in one annotation surface, while lighting and atmosphere improve readability as well as mood.
- Shell-aware markers and picking matter because globe scenes often need to distinguish between surface objects and elevated objects without giving up stable lat-lon queries, front-hemisphere culling, or deterministic CPU-owned metadata.
- Province and world-state adapters keep the globe synchronized with larger simulation systems, and import or generation helpers make it practical across authored, procedural, and tool-facing workflows.
- Region topology is equally central. The globe often acts as a graph of territories, travel arcs, or influence zones, so adjacency, routing, and territory-aware lookup must remain queryable rather than being flattened away into generic mesh behavior.
- Overlay and marker support keep several kinds of information visible at once: ownership, danger, weather, heat, logistics, missions, visibility, faction presence, or educational annotation can coexist without each feature reinventing map decoration rules.
- Province adapters and world-state synchronization keep the planetary view grounded in the rest of the simulation. A campaign map is only useful when ownership, events, region metadata, and larger systems can flow into the same world representation.
- Spherical picking and camera movement remain especially important because a globe becomes strategically useful only when users can navigate it, inspect regions, and turn screen-space interaction into stable geographic meaning.
- The result is a world-view layer that supports strategy, geoscape-style play, simulation inspection, and data-driven presentation without forcing projects to collapse planetary logic into a flat approximation too early.
- Read `globe` as the owner of planetary interaction, topology, and visualization. Rendering shows the result, but this module decides how a spherical world is represented, navigated, annotated, and synchronized.

This module primarily collaborates with `math`, `pathfind`, `province`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Notes

- `LGlobe:setShader(shaderOrNil)` still accepts only `mapviz` shaders created through `lurek.render.newShader`, and now orbit shells can also bind their own `mapviz` shader scope through `LGlobe:setOrbitShader(...)` without leaking into unrelated shell or surface passes.
- Orbit shells are named, always include the canonical `surface` shell, and add `altitude_px` to `GlobeSpec.radius` before zoom so shell projection, shell picking, and orbit marker placement stay radius-based and deterministic.
- Globe shaders are intended for atmospheric bands, tactical heatmap styling, fog/visibility tinting, orbital overlays, and map visualization treatments over the generated command stream. Globe topology, picking, routes, and fog state remain CPU-owned gameplay/tooling data.

## Architecture Links

- Intentionally empty.
