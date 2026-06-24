# Lurek Workbench

Lurek Workbench is a native Lurek application for visual project tooling. It is not a replacement for VS Code. Lua code editing, IntelliSense, formatting, rename, diagnostics, and source navigation stay in VS Code. Workbench focuses on content tasks where an in-engine visual tool is better than editing text by hand.

## Run

From the repository root:

```powershell
cargo run -- workbench
```

The app starts as a normal native desktop window, resizable and maximized by default through `conf.toml` plus `lurek.window.windowConfig`. Window minimize, maximize, and close are handled by the operating system title bar.

## Current Baseline

- Fullscreen Lurek project under `workbench/`.
- Professional shell with menu, activity bar, sidebar, editor tabs, contextual toolbar, central workspace, inspector, bottom log/problems/export panel, and status bar.
- Independent editor registry.
- Baseline editor modules:
  - `overview`: project hub and architecture summary.
  - `particle`: deterministic emitter preview and TOML/Lua export shape.
  - `tilemap`: layer/grid painter preview and Lua tilemap export shape.
  - `sprite_atlas`: sheet slicing and quad export shape.
  - `ui_layout`: TOML layout studio preview.

## Architecture

```text
workbench/
  conf.toml
  main.lua
  app/
    state.lua
    editor_registry.lua
    shell.lua
  editors/
    overview.lua
    particle.lua
    tilemap.lua
    sprite_atlas.lua
    ui_layout.lua
```

`main.lua` only wires Lurek callbacks and loads modules. `app/shell.lua` owns the workbench frame, input hit testing, tabs, activity bar, status, logs, and editor hosting. Each editor owns its own preview, inspector fields, update loop, actions, and export text.

## Editor Contract

Each editor should expose this shape:

```lua
return {
    id = "particle",
    title = "Particle Designer",
    summary = "Emitter sandbox",
    workspace = "preview",
    actions = {
        { id = "export-toml", label = "Export TOML" },
    },
    update = function(ctx, dt) end,
    draw = function(ctx, rect, ui) end,
    inspect = function(ctx) return fields end,
    export = function(ctx) return text end,
}
```

## Next Implementation Steps

1. Promote `Particle Designer` to a full vertical slice:
   - Open and save `.particle.toml`.
   - Create/update a real `lurek.particle` handle when values change.
   - Add sliders, color keyframes, seed reset, preset import, and validation.
2. Add project file services:
   - Project open, recent projects, GameFS path normalization, file watch.
   - Write only through explicit save/export actions.
3. Add real interaction to `Tilemap Editor`:
   - Cell picking, brush, fill, layers, tile palette, collision/ref slots.
4. Move shell panels from custom hit testing toward retained `lurek.ui` widgets where richer text input, lists, and dock resizing are needed.
5. Add screenshot evidence for the shell and every editor.

## Boundary

Do not add a Lua source editor here. Workbench should generate or edit content data and snippets that the user can inspect in VS Code.
