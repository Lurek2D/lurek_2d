# Lurek2D Examples Guide

`content/examples/` is the canonical example layer for the public `lurek.*` API.

## What This Folder Is For

- Each file owns one public module such as `render`, `audio`, `physics`, or `ui`.
- Each public API in that module has exactly one owning example block.
- Each block is a small runnable scenario that shows how to use that API with enough context to copy into a real script.
- Examples are reference material for the wiki, for agents, and for contributors building higher-level content.
- Examples are not unit tests, evidence tests, or games.

## How To Use It

1. Open the file that matches the API area you want to learn.
2. Search for `-- @api:` to jump to a specific callable.
3. Copy the relevant block into your own script and adapt it to your project.

## Structure Contract

- One file per module.
- One `-- @api:` marker per public API.
- One `do ... end` block per marker.
- The block should show one concrete usage pattern, not every edge case.
- The full file must run in Lurek without errors.
- No `-- TODO:` stubs are allowed in committed examples.

## Running Examples In Lurek

- Run one example directly through the engine:
  - `tools/python.cmd tools/dev/parallel_cargo.py run debug -- content/examples/render.lua`
- Run all examples sequentially through Lurek:
  - `tools/python.cmd tools/demos/smoke_sweep.py --kind example`
- Check example coverage quality:
  - `tools/python.cmd tools/audit/example_coverage.py --report --no-stubs --no-partials`

The sweep command is the canonical way to verify that every `content/examples/*.lua` script still runs in the engine. It is not the same thing as the Rust or Lua test harnesses.

## Related Docs

| Topic | Link |
|---|---|
| Lua API reference | [../../docs/api/lurek.md](../../docs/api/lurek.md) |
| Test suite overview | [../../tests/README.md](../../tests/README.md) |
| Quality assurance | [../../docs/architecture/quality-assurance.md](../../docs/architecture/quality-assurance.md) |

Examples should stay aligned with the generated API docs. If an example looks wrong, fix the source API docs in `src/lua_api/*_api.rs`, regenerate the docs, and then update the example owner block if needed.
