# Native procedural graphics

Lurek2D's built-in graphics are retained `LShape` assets. They are made from
flat-color primitives and compiled into one indexed mesh, so the Lua agent does
not need an SVG, texture file, or per-frame CPU tessellation.

## Authoring contract

Use a 64x64 local view box for reusable templates. Keep the silhouette inside
the box, choose an anchor (`{x=0.5, y=1}` for world props and
`{x=0.5, y=0.5}` for icons), and use three to five palette roles plus an
outline. The closed roles are `background`, `primary`, `secondary`, `accent`,
`outline`, `highlight`, `shadow`, and `emissive`.

```lua
local hero = lurek.render.newShape()
hero:setPalette({ primary={0.25,0.55,1,1}, secondary={0.15,0.2,0.35,1}, outline={0.03,0.04,0.08,1} })
hero:setColorRole("primary")
hero:circle("fill", 32, 18, 10)
hero:setColorRole("secondary")
hero:rectangle("fill", 18, 28, 28, 25)
hero:setColorRole("outline")
hero:setStrokeStyle({ width=3, cap="round", join="round" })
hero:circle("line", 32, 18, 10)
hero:rectangle("line", 18, 28, 28, 25)
hero:compile({ tolerance=0.1 })
```

Build child parts during `load`/`init`, then compose them once:

```lua
local body = lurek.render.loadBuiltinShape("character/hero")
local sword = lurek.render.loadBuiltinShape("item/sword")
local unit = lurek.render.newShape()
unit:addShape(body, { x=0, y=0 })
unit:addShape(sword, { x=30, y=24, rotation=-0.35, sx=0.7, sy=0.7 })
unit:compile()

function draw_units(units)
    unit:drawMany(units) -- one compatible instanced draw
end
```

Do not append primitives, compile, or allocate geometry in `draw`. Mutations
increment the shape revision and invalidate its GPU cache. `getBounds()` and
`getDiagnostics()` are useful while authoring; `lurek.render.getStats()` should
show zero new shape tessellations after warm-up.

For free-form paths, use `path` with `fillRule="nonzero"` or `"evenodd"` and
the same cap/join/dash options as `setStrokeStyle`. Immediate
`lurek.render.drawPath` accepts an equivalent options table, but retained
`LShape` assets are preferred for anything drawn more than once.

## Advanced marks for agents

The vocabulary is intentionally close to the reusable mark families in
[Vega marks](https://vega.github.io/vega/docs/marks/) and the generators in
[D3 shape](https://d3js.org/d3-shape): the engine supplies geometry and
instancing, while Lua owns scales, data joins, labels, and chart semantics.

- Games: `regularPolygon`, `star`, `capsule`, `ring`, `sector`, `arrow`, and
  `trail` cover shields, gems, effects, arrows, and variable-width attacks.
- Data science: use `point`/`points` for scatter plots, rectangles for bars and
  heatmap cells, `path` for line/area plots, `error_bar`-style compositions for
  uncertainty, and `arrow`/`line` for graph links. Chart scales and labels stay
  in Lua; the renderer only receives geometry.
- Effects: use a compiled ring/star/burst child and tint instances with
  `{tint={r,g,b,a}}` instead of rebuilding colors for every particle.

The executable contains 96 catalogue templates. Discover them with
`lurek.render.listBuiltinShapes()` and use canonical IDs such as
`blocks_terrain/stone_block`, `character/hero`, `item/sword`,
`ui/heart`, or `data_viz/error_bar`.
Each metadata row also reports the canonical primitive vocabulary in
`primitives`; this lets an agent choose a template without opening TOML or
SVG files.
