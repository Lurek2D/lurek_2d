---
name: create-demo
description: Create or update new demo game using specific scope or specific modules.
---

# GOAL
- Build a fully runnable demo game in the `content/games/` directory that showcases engine features.

# INPUTS REQUIRED
- Demo name and concept
- Target modules to highlight
= User must provide the overall theme, mechanics, and required modules
- Agent must collect layout structures for demos and necessary assets

# STEPS TO DO
1. Load skills: demo-creation, lua-scripting.
2. Create a directory in `content/games/<demo_name>/` containing `main.lua`, `conf.toml`, and `README.md`.
3. Write the main game loop, initialize the required subsystems, and add minimal representative gameplay logic.
4. Write a rust integration test in `tests/demo_smoke_tests.rs` to ensure the demo is automatically verified on CI.
5. Execute `python tools/validate/validate_game.py --path content/games/<demo_name>`. If the validation script returns errors, fix the demo structure and repeat step 5 until it exits with code 0.

# OUTPUTS PROVIDED
- A new folder in `content/games/` with a complete demo structure
- Smoke test registration

# SUCCESS CRITERIA
- [ ] `cargo test --test demo_smoke_tests` exits with code 0 (100% demo pass rate).
- [ ] `python tools/validate/validate_game.py` exits with code 0 (0 validation errors).

# ANTI-PATTERNS
- Creating complex logic that overshadows the engine features being demonstrated.
- Forgetting to include a `conf.toml` file or a `README.md`.

# EXAMPLE INVOCATION
- User: "request for this prompt"
- Agent: Runs this prompt workflow with provided constraints and reports changed files plus validation evidence.

# REFERENCES
- skills: demo-creation, lua-scripting
- tools: python tools/validate/validate_game.py, cargo test
- agent: Content-Maker


