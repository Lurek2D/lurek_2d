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
- Agent must collect layout structures for demos and necessary assets

## Profile hint
- `content`

## Read these contracts
- `content/AGENTS.md`
- `content/games/AGENTS.md`
- `tests/lua/AGENTS.md`

## Steps
- Read the listed contracts before building the demo.
- Create a directory in `content/games/<demo_name>/` containing `main.lua`, `conf.toml`, and `README.md`.
- Write the main game loop, initialize the required subsystems, and add minimal representative gameplay logic.
- Write a rust integration test in `tests/demo_smoke_tests.rs` to ensure the demo is automatically verified on CI.
- Execute `python tools/validate/validate_game.py --path content/games/<demo_name>`. If the validation script returns errors, fix the demo structure and repeat step 5 until it exits with code 0.

## Outputs
- A new folder in `content/games/` with a complete demo structure
- Smoke test registration

## Success criteria
- [ ] `cargo test --test demo_smoke_tests` exits with code 0 (100% demo pass rate).
- [ ] `python tools/validate/validate_game.py` exits with code 0 (0 validation errors).

## Stop conditions
- Creating complex logic that overshadows the engine features being demonstrated.
- Forgetting to include a `conf.toml` file or a `README.md`.

## References
- `contracts: content/AGENTS.md, content/games/AGENTS.md, tests/lua/AGENTS.md`
- `tools: python tools/validate/validate_game.py, cargo test`
- `agent: Content-Maker`


