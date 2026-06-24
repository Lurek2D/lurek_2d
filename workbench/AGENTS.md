# Workbench Contract

## Mission & Scope
- Own the native Lurek Workbench app used to author and inspect Lurek project content.
- Keep the workbench as a Lurek project: Lua modules, optional local data, and `conf.toml`.

## Files
- `main.lua`: Thin runtime bootstrap and callback wiring.
- `app/`: Shell, state, rendering helpers, command routing, project services.
- `editors/`: Independent visual editor modules hosted by the shell.
- `data/`: Local app presets, templates, and sample project data.

## Rules
- Do not add a code editor here; VS Code owns Lua editing and language intelligence.
- Keep editors independent. Each editor must expose `id`, `title`, `draw`, `update`, `inspect`, and `export`.
- Use real `lurek.*` APIs for window, input, render, filesystem, and future UI widgets.
- Keep `main.lua` thin; put shell and editor logic in modules.
- Use forward slashes in paths.

