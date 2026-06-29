# Workbench Architecture Notes

## Product Shape

Workbench is a host for focused tools, not a monolithic IDE. The shell provides navigation and shared app services; editors remain small and replaceable.

## Shared Shell Responsibilities

- Window setup for a native, resizable, maximized desktop app.
- Retained `lurek.ui` chrome: activity bar, sidebar, tabs, toolbar, inspector, bottom panel, and status bar.
- Command dispatch, status messaging, and log capture.
- Project-tree selection routing into document open commands.
- Editor widget visibility and per-editor inspector control hosting.

## Shared Services

- `command_bus.lua`: named action routing with consistent success/error payloads.
- `project_index.lua`: recursive sample/project scan plus tree bucketing for particles, maps, layouts, assets, and other files.
- `document_service.lua`: open, validate, serialize, save, reload, revert, export, and active-document tracking.

## Editor Responsibilities

- Match file paths when they can open project documents.
- Build and validate document models when they are document-backed.
- Render only inside the provided workspace rectangle.
- Return inspector fields as plain `{ label, value }` rows.
- Return export text and export payloads without writing files directly.
- Keep editor-specific controls inside `ensure_controls` and `layout_controls`.

## Data Flow

```text
input -> lurek.ui widgets -> shell action routing
shell action -> command bus -> project/document services
document state -> active editor preview + inspector + export
editor mutation -> document service refresh -> validation + dirty state + live preview rebuild
```

## First Real Vertical Slice

Particle Designer is the first fully real editor because `lurek.particle` already has strong Lua-facing primitives:

- `lurek.particle.newSystem(config)`
- `lurek.particle.fromTOML(path)`
- `LParticleSystem:update(dt)`
- `LParticleSystem:drawToImage(w, h)`
- `LParticleSystem:setEmissionRate(rate)`
- `LParticleSystem:setSpeed(min, max)`
- `LParticleSystem:setColors(...)`

The delivered slice is a `.particle.toml` editor with:

- project-index discovery from the sample project tree
- TOML parse/serialize via `lurek.serialize`
- runtime validation through `lurek.particle.newSystem`
- live preview in the workbench workspace
- explicit save, reload, revert, and Lua loader export flows
