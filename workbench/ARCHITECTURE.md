# Workbench Architecture Notes

## Product Shape

Workbench is a host for focused tools, not a monolithic IDE. The shell provides navigation and shared app services; editors remain small and replaceable.

## Shared Shell Responsibilities

- Window setup for a native, resizable, maximized desktop app.
- Activity bar and left sidebar.
- Open editor tabs.
- Context toolbar.
- Central workspace rectangle.
- Inspector panel.
- Bottom log, problems, and export preview.
- Dirty state and status messaging.

## Editor Responsibilities

- Own state under `ctx.editor_state[editor_id]`.
- Render only inside the provided workspace rectangle.
- Return inspector fields as plain `{ label, value }` rows.
- Return export text without writing files directly.
- Defer project-wide file writes to a future app file service.

## Data Flow

```text
input -> shell hit testing -> command/status/log
input -> active editor state
editor state -> preview draw
editor state -> inspector fields
editor state -> export text
```

## First Real Vertical Slice

Particle Designer should be the first fully real editor because `lurek.particle` already has strong Lua-facing primitives:

- `lurek.particle.newSystem(config)`
- `lurek.particle.fromTOML(path)`
- `LParticleSystem:update(dt)`
- `LParticleSystem:drawToImage(w, h)`
- `LParticleSystem:setEmissionRate(rate)`
- `LParticleSystem:setSpeed(min, max)`
- `LParticleSystem:setColors(...)`

The target deliverable is a `.particle.toml` editor with live preview, validation, save/export, and a generated Lua loader snippet.
