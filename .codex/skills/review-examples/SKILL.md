---
name: review-examples
description: "Load this skill when auditing and fixing example coverage, example correctness, and content/examples conventions. Skip it for full demos, snippets, or internal tests."
---

# review-examples

## Mission
- Audit and fix API example coverage and example quality.
- Enforce one public API = one example owner block in `content/examples/`.

## Domain Knowledge
- Example coverage is exact ownership, not occurrence counting: every generated public API name needs one real marker-owned block, and duplicate mentions outside that block do not repair a missing owner.
- Parser shape is part of publication because generators extract the immediate `do ... end` block. Top-level helpers, setup between marker and `do`, or hidden dependencies make an example invalid even if the entire file runs.
- Quality has three independent gates: structural extractability, runtime bootability, and teaching value. A five-line block can pass structural checks while showing no observable outcome or misleading lifecycle placement.
- Examples are intentionally narrower than tests and games: one representative success path, enough setup to stand alone, no assertion matrix, and no multi-system progression loop.
- Stateful example files must be reviewed as a whole for leaked callbacks, resources, global state, or duplicate registrations between individually isolated blocks.
- Generated-page context should remain understandable when a block is extracted without its filename or neighboring API descriptions; local variable names and observable outcomes must carry enough meaning for independent reading.
- Example assets are shared infrastructure and should be minimal, stable, and referenced by forward-slash paths. An example that relies on a game-local or machine-local asset is structurally covered but not portable.
- Lifecycle-sensitive examples must create resources at a legal phase and demonstrate the API where its result becomes visible, avoiding accidental patterns such as allocating every draw or mutating simulation only during rendering.

## Workflow
- Run module and repository coverage with no stubs/partials, classify missing, duplicate, malformed, TODO/PART, and thin owners, then join each candidate to its generated signature and canonical module file.
- Inspect blocks in extraction context and full-file runtime context, checking self-contained setup, exact generated name, observable use, correct callback/lifecycle placement, bounded resources, valid assets, and absence of test/game scope creep.
- Report structural/parser failures separately from runtime failures and teaching defects, with the API name, owner block, emitted-page consequence, and a concrete minimum success case for missing coverage.
- If editable, repair through the `create-example` workflow, boot the complete module, rerun strict coverage/validation and example smoke, then inspect generated-page extraction; otherwise hand off exact API owners to `content`.
- Compare each repaired block with its generated docs, unit owner, and snippet inventory so it teaches the canonical success path without duplicating assertion matrices or editor-oriented recipes.
- Run affected example files in sequence and independently where tooling permits, detecting hidden ordering, shared callback, or asset-cache dependencies that a single full-suite boot can conceal.

## References
- `contracts: AGENTS.md, content/AGENTS.md, content/examples/AGENTS.md, docs/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "example coverage content examples API" --profile game --limit 10, tools/python.cmd tools/audit/example_coverage.py --module <module>, tools/python.cmd tools/validate/validate_example_coverage.py`
- `agent: content`
- RAG: Use when locating example owners and similar samples; `example coverage content examples API`; `content examples lua sample feature`; `docs example usage snippet`; `content/examples/`; `docs/`; `library/`; feature-owning modules in `src/`
