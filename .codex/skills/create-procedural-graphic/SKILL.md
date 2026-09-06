---
name: create-procedural-graphic
description: "Load this skill when creating native MVP/POC graphics with LShape and primitive composition. Skip it for engine internals, user SVG files, bitmap assets, or shader authoring."
---

# create-procedural-graphic

## Mission
- Build small, readable 2D graphics from retained Lurek primitives so they compile once and render efficiently on the GPU.

## Domain Knowledge
- Native graphics use `lurek.render.loadBuiltinShape` or `lurek.render.newShape` and return `LShape` handles.
- The coordinate contract for catalogue templates is a 64x64 view box with an explicit anchor; keep silhouettes inside that box.
- Palette roles are closed: `background`, `primary`, `secondary`, `accent`, `outline`, `highlight`, `shadow`, and `emissive`.
- `LShape:compile({ tolerance = 0.1 })` creates retained indexed geometry. Mutating a shape invalidates its compiled revision.
- `LShape:addShape(child, transform)` snapshots the child command IR. Reuse a compiled parent rather than rebuilding it in `draw`.
- `LShape:drawMany` accepts `{x,y,rotation,sx,sy,ox,oy,tint}` records, validates the complete array, and is the preferred path for scatter and repeated props.
- The built-in catalogue has 96 IDs in eight groups: blocks/terrain, character, creature, item, prop, UI, effect, and data visualization.

## Workflow
1. Choose a 64x64 silhouette and one anchor (usually `{x=0.5,y=1}` for world props or `{x=0.5,y=0.5}` for icons).
2. Limit the art to three to five palette roles plus an outline; add detail with circles, polygons, lines, `path`, or an advanced helper such as `star`, `ring`, `sector`, `arrow`, or `trail`.
3. Create child parts in `load`/`init`, set the palette and stroke style, compose them with `addShape`, then call `compile` once.
4. In `draw`, submit one `shape:draw(...)` or one `shape:drawMany(instances)` call. Never append primitives, compile, or allocate instance tables in the hot loop.
5. For data science panels, use the same marks for scatter points, bars, line/area paths, error bars, heatmap cells, and graph links; keep chart semantics in Lua.
6. Validate with `getBounds`, `getDiagnostics`, and `lurek.render.getStats()`; a warmed-up shape should report no new shape tessellation.
7. Add a focused Lua example/test when the graphic becomes a reusable template, and keep catalogue TOML deterministic.

## References
- `contracts: AGENTS.md, .codex/AGENTS.md, src/AGENTS.md`
- `tools: tools/python.cmd tools/render/gen_builtin_shapes.py --check, tools/python.cmd tools/validate/cag_validate.py, tools/python.cmd tools/audit/cag_link_check.py --strict`
- `agent: lua_designer`
- RAG: `LShape native procedural graphics primitives drawMany GPU catalogue`
