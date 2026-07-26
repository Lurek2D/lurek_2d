# Developer Workflow

This document describes the workflow, onboarding standards, and general project structure for developers using Lurek2D.

## Game Project Structure

A typical game folder is small and self-contained. The Lurek2D runtime looks for `main.lua` at the root of the project.

```text
my_game/
  conf.lua
  main.lua
  assets/
    player.png
    click.ogg
  data/
    level1.toml
```

### Essential Files and Folders
- `main.lua` - The primary entry point. Defines callbacks (like `lurek.init` and `lurek.process`) and connects game modules.
- `conf.lua` - (Optional) Sets window and runtime options before the game starts.
- `assets/` - Directory for media used by the render, audio, image, and game code modules.
- `data/` - Directory for TOML or other game data, read securely through the engine's GameFS sandbox.

## Core Glossary

- `lurek.*` - the only public API namespace for game scripts.
- `callback` - a function called by the runtime, such as `lurek.process(dt)`.
- `dt` - elapsed time since the previous frame, in seconds.
- `main.lua` - the main game script.
- `conf.lua` - optional startup configuration for a game.
- `Lureksome` - reusable Lua libraries layered over the base runtime API.
