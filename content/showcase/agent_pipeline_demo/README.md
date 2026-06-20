# Agent Pipeline Demo

Simple demo that opens a window and runs a full `lurek.agent` pipeline with console logs.

## Features
- starts Ollama from Lua via `LOllamaManager`
- checks and optionally pulls the selected model
- builds 3 agents, manager, AISystem, skills, and instructions
- dispatches async prompts in sequence and prints callbacks

## How To Run

```powershell
cargo run -- content/games/showcase/agent_pipeline_demo
```

## What To Look For
- Window shows live status lines and recent log messages.
- Console prints prefixed with `[agent-demo]` show each API step and callback result.
- If model download is slow, demo dispatches after a fallback timeout to also show error callbacks.
