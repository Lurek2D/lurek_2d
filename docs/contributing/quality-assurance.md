# Lurek2D Quality Assurance Guide

## Purpose

This document defines the intended ownership chain for public Lurek2D behavior and the quality gates that keep content from drifting into duplicated or mixed-purpose folders.

## The Content Lifecycle

Public `lurek.*` behavior should move through these layers in order:

1. API docs define the surface.
2. `content/examples/` shows one concrete usage block for every public API.
3. `tests/lua/unit/` proves every public API works.
4. `tests/lua/evidence/` produces selected artifacts that make behavior reviewable.
5. `tests/lua/golden/` compares those artifacts against reviewed baselines.
6. `lurek_2d_content/games/` packages APIs into complete games or mini games.

Each layer has a different job:

| Layer | Purpose | What it is not |
|---|---|---|
| Examples | Teach usage with context | Exhaustive testing |
| Lua unit tests | Prove public behavior | Human-facing documentation |
| Rust unit tests | Prove private/internal behavior | Public API ownership |
| Evidence tests | Generate meaningful artifacts | Behavioral assertions |
| Golden tests | Detect drift in stored artifacts | Artifact generation |
| Games | Deliver complete playable projects | API showcases or mechanic scraps |

## Folder Contracts

### `content/examples/`

- One file per public module.
- One API = one `-- @api:` marker = one runnable block.
- Coverage is 100%.
- The file must run in Lurek without errors.
- The block should show one realistic use case with short context.

### `tests/lua/unit/`

- One file per public module.
- Coverage is 100%.
- One API = one `it()` = one directly-adjacent `-- @covers`.
- That single `it()` may contain many assertions if they all prove the same API.

### `tests/rust/unit/`

- Rust tests exist only for private seams, helpers, serialization, and Lua-unreachable glue.
- There is no 100% coverage requirement here.
- Public behavior reachable through Lua should not be duplicated in Rust tests.

### `tests/lua/evidence/`

- Evidence tests produce artifacts under `tests/artifacts/current/`.
- They pass when the intended artifact is produced.
- They do not exist to assert correctness directly.
- Every artifact must answer four review questions:
  - What does it do?
  - What does it show?
  - What file did it write?
  - Why is that artifact meaningful?
- If a reviewer cannot tell what an artifact proves, it is not acceptable evidence.

### `tests/lua/golden/`

- Golden tests compare current artifacts against committed baselines in `tests/artifacts/baselines/`.
- Golden tests do not create new artifacts.
- Evidence must stay meaningful before golden baselines are refreshed.

### `lurek_2d_content/games/`

- Only finished playable `game` or `minigame` entries belong here.
- Both are complete products. `minigame` only means smaller scope.
- A folder that mainly showcases 1-3 APIs, one mechanic, or one renderer trick does not belong here.
- Showcase-like entries should become `content/examples/` material or evidence coverage when the main value is the generated artifact.

## Placement Rules

Use this decision order:

1. Is the goal to explain one public API? Put it in `content/examples/`.
2. Is the goal to prove one public API works? Put it in `tests/lua/unit/`.
3. Is the goal to prove a private helper or internal seam? Put it in `tests/rust/unit/`.
4. Is the goal to generate a screenshot, audio file, text dump, waveform, or other proof artifact? Put it in `tests/lua/evidence/`.
5. Is the goal to compare a newly generated artifact with a baseline? Put it in `tests/lua/golden/`.
6. Is the goal to ship a finished playable experience? Put it in `lurek_2d_content/games/`.
7. Is it interactive but not a complete game? Split the durable API slice into `content/examples/` and the reviewable proof into `tests/lua/evidence/`.

## Quality Gates

Run these when changing contracts, examples, tests, or game classification:

```powershell
tools/python.cmd tools/validate/validate_example_coverage.py
tools/python.cmd tools/audit/unit_test_api_coverage.py
tools/python.cmd tools/audit/lua_nonunit_test_coverage.py
tools/python.cmd tools/audit/lua_test_structure_audit.py --path tests/lua/unit
tools/python.cmd tools/audit/lua_evidence_golden_contract_audit.py
tools/python.cmd tools/demos/audit_games.py
tools/python.cmd tools/validate/cag_validate.py
tools/python.cmd tools/audit/cag_link_check.py --strict
```

Use `cargo test` and `cargo clippy -- -D warnings` when code behavior changes, not just contract prose.

## Current Cleanup Direction

The cleanup order for this repo is:

1. Fix example ownership and 100% example coverage.
2. Fix Lua unit ownership and remove public API duplication from Rust tests.
3. Redesign evidence so every artifact has a clear review purpose.
4. Realign golden baselines to the cleaned evidence layer.
5. Reclassify `lurek_2d_content/games/` so only real games and mini games remain there.

That order matters. Cleaning games before fixing examples, unit coverage, and evidence will keep recreating the same duplication.
