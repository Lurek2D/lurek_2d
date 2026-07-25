# Examples Contract

## Mission & Scope
- Own runnable single-file examples for every public `lurek.*` API.
- Teach one public API at a time. Tests own full behavior proof.

## Files
- `README.md`: Example index by namespace.
- `*.lua`: One module per file, with all APIs for that module grouped there.
- `assets/`: Resources loaded by examples.

## Rules
- Every public Lua API has one exact `--@api:` marker.
- The next non-blank line after the marker must start its own `do ... end` block.
- Each block has at least five useful non-comment code lines.
- Keep all setup and helpers inside the owning block. A block must run on its own.
- Use `--@api-stub:` only for generated pending work. Finished files have no stubs or TODOs.
- Keep each module file runnable, deterministic, and free of assertions.
- Use forward-slash paths inside `assets/`.

## Workflow
- Run `tools/python.cmd tools/demos/smoke_sweep.py --kind example`.
- Run `tools/python.cmd tools/audit/example_coverage.py --report --no-stubs --no-partials`.
