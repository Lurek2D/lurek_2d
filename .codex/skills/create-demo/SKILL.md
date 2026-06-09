---
name: create-demo
description: "Create or update new demo game using specific scope or specific modules."
---
# create-demo

## Goal
- Build a fully runnable demo game in the `content/games/` directory that showcases engine features.

## Required inputs
- Demo name and concept
- Target modules to highlight
- User must provide the overall theme, mechanics, and required modules
- Agent must collect the current demo layout conventions and required assets

## Profile hint
- `content`

## Read these contracts
- `content/AGENTS.md`
- `content/games/AGENTS.md`
- `tests/lua/AGENTS.md`

## Steps
- Read the listed contracts before building the demo.
- Create a new subdirectory under `content/games/` and place `main.lua`, `conf.toml`, and `README.md` in it.
- Write the main game loop, initialize the required subsystems, and add minimal representative gameplay logic that exercises the highlighted modules.
- Register the demo in `tests/demo_smoke_tests.rs` so the CI smoke suite knows to launch it.
- Execute `python tools/validate/validate_game.py` against the new demo directory. If the validation script returns errors, fix the demo structure and repeat the validation step until it exits with code 0.

## Outputs
- A new folder in `content/games/` with a complete demo structure
- Smoke test registration

## Success criteria
- [ ] `cargo test --test demo_smoke_tests` exits with code 0.
- [ ] `python tools/validate/validate_game.py` exits with code 0.

## Stop conditions
- Creating complex logic that overshadows the engine features being demonstrated.
- Forgetting to include a `conf.toml` file or a `README.md`.

## References
- `contracts: content/AGENTS.md, content/games/AGENTS.md, tests/lua/AGENTS.md`
- `tools: python tools/validate/validate_game.py, cargo test`
- `agent: content`


