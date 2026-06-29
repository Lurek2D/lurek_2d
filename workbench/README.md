# Lurek Workbench

Lurek Workbench is a native Lurek application for visual project tooling. It is not a replacement for VS Code. Lua code editing, IntelliSense, formatting, rename, diagnostics, and source navigation stay in VS Code. Workbench focuses on content tasks where an in-engine visual tool is better than editing text by hand.

## Run

From the repository root:

```powershell
cargo run -- workbench
```

The app starts as a normal native desktop window, resizable and maximized by default through `conf.toml` plus `lurek.window.windowConfig`. Window minimize, maximize, and close are handled by the operating system title bar.

## Current Baseline

- Native Lurek project under `workbench/` with a retained `lurek.ui` shell host.
- Shared workbench services for command dispatch, project indexing, and document lifecycle.
- Sample project data under `workbench/data/sample_project/` for startup and smoke coverage.
- Current editor modules:
  - `overview`: project hub and architecture summary.
  - `particle`: real `.particle.toml` vertical slice with parse, validate, preview, save, reload, revert, and Lua export.
  - `tilemap`: planned next slice running on the shared shell baseline.
  - `sprite_atlas`: placeholder content tool module on the same host.
  - `ui_layout`: placeholder layout tool module on the same host.

## Architecture

```text
workbench/
  conf.toml
  main.lua
  app/
    command_bus.lua
    state.lua
    editor_registry.lua
    shell.lua
    services/
      document_service.lua
      project_index.lua
  editors/
    overview.lua
    particle.lua
    tilemap.lua
    sprite_atlas.lua
    ui_layout.lua
  data/
    sample_project/
```

`main.lua` only wires Lurek callbacks and loads modules. `app/shell.lua` owns the retained `lurek.ui` chrome, routing input and editor actions through shared services. `app/state.lua` registers workbench commands and keeps project/document state coherent. Editors stay independent and own their own preview, validation, inspector fields, and exports.

## Editor Contract

Each editor should expose this shape:

```lua
return {
    id = "particle",
    title = "Particle Designer",
    summary = "Emitter sandbox",
    workspace = "preview",
    matches_path = function(path) return boolean end,
    actions = {
        { id = "export-toml", label = "Export TOML" },
    },
    create_document = function(path, source_text, project_root) return doc end,
    serialize_document = function(document, project_root) return text end,
    validate_document = function(document, project_root) return problems end,
    build_export = function(document, project_root) return payload end,
    handle_action = function(ctx, action_id) return ok, result end,
    update = function(ctx, dt) end,
    draw = function(ctx, rect, ui) end,
    inspect = function(ctx) return fields end,
    export = function(ctx) return text end,
    ensure_controls = function(shell) end,
    layout_controls = function(ctx, rect, shell) end,
}
```

## Next Implementation Steps

1. Deepen `Particle Designer` controls with color keyframe editing, seed reset, and more presets.
2. Promote `Tilemap Editor` to the next real document-backed slice on the shared services.
3. Add recent-project and file-watch workflows on top of the project index.
4. Add screenshot evidence for the retained shell and each real editor slice.

## Validation

- Headless workbench coverage: `cargo test --test workbench_smoke_tests`
- Real window smoke path: `cargo test --test workbench_smoke_tests -- --include-ignored`
- Lua document flow coverage: `cargo test --test lua_tests lua_integration_workbench_particle_integration`

## Boundary

Do not add a Lua source editor here. Workbench should generate or edit content data and snippets that the user can inspect in VS Code.
