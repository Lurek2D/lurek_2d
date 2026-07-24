---
name: create-game
description: "Load this skill when creating or modifying a finished playable Lua game or mini game under lurek_2d_content/games. Skip it for API examples, mechanic labs, engine work, or reusable libraries."
---

# create-game

## Mission
- Deliver a catalog-ready, runnable game with a complete player loop and clear product boundary.

## Domain Knowledge
- Finished games live under `lurek_2d_content/games/<name>/`.
- Every game needs `main.lua`.
- A local README declares `Scale: game` or `Scale: minigame`.
- A catalog game needs `screen.png` from active play.
- Games and minigames differ in scope, not completeness.
- Examples belong in `content/examples/`.
- Focused visual proof belongs in `tests/lua/evidence/`.
- Game state stays in local tables or game modules.
- Draw callbacks do not advance simulation state.
- Persistent resources are not created every frame.
- Assets stay inside the game folder.
- Asset paths use forward slashes and relative paths.
- Only generated or allowlisted `lurek.*` APIs are valid.
- `lurek.window.present` is not allowed in games.
- Local UI files use `w` and `h`.
- Game text uses bitmap font sizes 8, 10, 12, 16, 20, 24, or 30.
- Player input and automation use the same action path.
- `conf.toml` is an optional game-local runtime configuration file.
- Demo-specific headless coverage lives beside the game as `test.lua`.
- The public games README contains only entries classified as `KEEP`.
- `REWRITE_API`, `TRIM`, and migration decisions stay in `work/games-audit.md` and `work/games-audit.json`.
- `validate_game.py` rejects unknown `lurek.*` calls and unknown callback assignments.
- `preview.gif` is optional catalog motion evidence; `screen.png` remains the required static preview.

## Workflow
1. Read the games contract.
2. Run the game catalog audit.
3. Read the two nearest games.
4. Define controls, goal, progress, failure, and restart.
5. Define module and state ownership.
6. Build one complete playable loop.
7. Add HUD, menu, feedback, and local assets.
8. Keep update, draw, UI, and automation code separate.
9. Test normal and large `dt`.
10. Test loss, win, and repeated restart.
11. Run `validate_game.py` on the exact folder.
12. Launch the exact game in debug mode.
13. Run the targeted game smoke sweep.
14. Fix unknown APIs, callbacks, and asset paths.
15. Capture `screen.png` during stable active play.
16. Update the catalog only when the game is complete.

## References
- `contracts: AGENTS.md, content/AGENTS.md, lurek_2d_content/AGENTS.md, lurek_2d_content/games/AGENTS.md, tests/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "finished playable Lua game core loop" --profile game --limit 10, tools/python.cmd tools/demos/audit_games.py, tools/python.cmd tools/validate/validate_game.py lurek_2d_content/games/<name>, tools/python.cmd tools/demos/smoke_sweep.py --kind game --only <name>`
- `agent: content`
- RAG: `finished playable game minigame controls core loop`; inspect neighboring `lurek_2d_content/games/` entries and the APIs used by the selected loop.
