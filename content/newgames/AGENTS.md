# New Games Contract

## Mission & Scope
- Own finished playable mini games and game-like apps under `content/newgames/`.
- Treat `content/games/` as reference only; new work belongs here.
- Prove Lurek2D can ship games people can play, not API showcases.

## Files
- `_template/`: Modular starter project for new playable games.
- `*/main.lua`: Thin bootstrap that wires modules and Lurek callbacks.
- `*/scripts/*.lua`: Gameplay, rendering, input, UI, audio, data, and scenario modules.
- `*/assets/`: Local PNG, audio, fonts, maps, and source/license notes.
- `*/README.md`: English design, controls, structure, APIs, and run notes.
- `*/ui.toml`: Required when the game has menus, HUDs, panels, or app UI.
- `*/screen.png`: Gameplay screenshot for catalog/review, not a menu.

## Rules
- No throwaway mechanic snippets, stub demos, or single-file games.
- Every project must include `main.lua`, multiple Lua modules, local assets, `README.md`, and `screen.png`.
- Include PNG art and audio assets inside the game folder; document third-party sources or generated assets.
- Use real `lurek.*` APIs when they exist; do not clone engine systems locally.
- Keep gameplay state in local tables, modules, or explicit context objects.
- Put UI layout in TOML and drive it through `lurek.ui`.
- Capture `screen.png` from active gameplay; use automation if a menu must be crossed first.
- Keep scratch and evidence under `work/{short-chat-name}/`, never inside a game folder except intended assets.

## Target Apps
- Calculator.
- CSV/dataframe table browser with schema and simple analytics.
- Timeline music composer with piano-roll editing.
- Particle system editor that builds effects from the Lurek particle API.

## Target Games
- Tetris, Asteroids, Pac-Man, Galaga, Dyna Blaster, Snake, Space Invaders.
- Boulder Dash, Turrican, Giana Sisters, Roguelike, Star Voyage, Visual Novel.
- Settlers Rise, Sensible Soccer, Ski Jumping, Pinball, Golf Classic, Card Game.
- Dune 2-style RTS, high-level strategic hex strategy, Match 3, Tower Defense.
- Worms artillery, tactical UFO/XCOM-style battle, fighting game, stealth game.
- Cannon Fodder and Endless Runner.

## Workflow
- Run RAG before broad reads: `tools/python.cmd tools/rag/query.py "content newgames playable game modules assets screenshot ui toml" --profile game --limit 10`.
- Start from `content/newgames/_template/` for new projects, then replace template mechanics with the requested game design.
- Validate with `tools/python.cmd tools/validate/validate_game.py content/newgames/<name>`.
- Smoke with `build/debug/lurek2d.exe content/newgames/<name> --screenshot=screen.png --screenshot-frames=180`.
