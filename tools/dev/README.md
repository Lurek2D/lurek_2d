# tools/dev/

Developer-facing helper tools for Lurek2D build, test, and fix workflows.

These scripts are permanent tools under `tools/dev/`. They are intended for local
developer use, VS Code task wiring, and agent-driven workflow automation.

## Scripts

| Script | Purpose |
|--------|---------|
| `parallel_cargo.py` | Unified cargo orchestration for build, check, run, test, clippy, fmt, and doc, including bounded Rust test fan-out |
| `test_fix_loop.py` | Run tests → parse failures → show top errors → iterate until clean |

## Usage

```powershell
# Run an all-core debug build through the permanent orchestration tool
python tools/dev/parallel_cargo.py build debug

# Type-check without linking
python tools/dev/parallel_cargo.py check

# Run a showcase game in debug or release mode
python tools/dev/parallel_cargo.py run debug -- content/games/showcase/hello_world
python tools/dev/parallel_cargo.py run release -- content/games/showcase/hello_world

# Fan out non-Lua Rust test targets across bounded concurrent cargo processes
python tools/dev/parallel_cargo.py test rust --warm-build

# Run one explicit test target with stdout/stderr visible
python tools/dev/parallel_cargo.py test target math_tests --nocapture

# Run the full repo-owned test flow through one wrapper
python tools/dev/parallel_cargo.py test all --warm-build

# Run lint / format / docs through the same wrapper
python tools/dev/parallel_cargo.py clippy --deny-warnings
python tools/dev/parallel_cargo.py fmt check
python tools/dev/parallel_cargo.py doc --open --no-deps

# Run all Lua tests and summarize failures
python tools/dev/test_fix_loop.py --test lua_tests

# Run with explicit thread count
python tools/dev/test_fix_loop.py --test lua_tests --threads 8

# Filter to one category
python tools/dev/test_fix_loop.py --test lua_tests --filter library

# Run once and exit (no loop)
python tools/dev/test_fix_loop.py --test lua_tests --once
```
