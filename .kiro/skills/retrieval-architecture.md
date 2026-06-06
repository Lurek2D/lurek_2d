---
inclusion: manual
---

# retrieval-architecture

## Mission
Own retrieval corpus design, freshness rules, and evaluation for agent-facing knowledge.

## When To Use
- Define a retrieval corpus.
- Add or change chunking rules.
- Design source ranking or provenance.
- Evaluate RAG quality or freshness.

## When To Skip
- Generic CAG writing, engine code work, non-retrieval docs updates.

## Rules

### Source Priority (highest to lowest)
binding constraints (`docs/architecture/philosophy.md`) → CAG layer (`.github/`) → module specs (`docs/specs/*.md`) → architecture docs (`docs/architecture/`) → handbook/CONTRIBUTING → wiki pages → examples/games → generated outputs (`docs/api/`).

A retrieval answer from a higher tier overrides one from a lower tier.

### Chunking
Chunk by ownership boundary, not by fixed byte size. One complete SKILL.md, one module spec, one agent file, one `## Section` in a doc, or one function docstring are all natural chunk units. Never split a module spec's Invariants section from its Public API section — that destroys useful context.

### Generated Files at Lower Priority
`docs/api/lurek.md`, `docs/api/lurek.lua` should be indexed at lower priority than their sources (`src/lua_api/*_api.rs`, `library/*/init.lua`). When both match a query, prefer the source.

### Freshness Trigger Table
- `src/lua_api/<module>_api.rs` changes → invalidate chunks for `docs/api/lurek.md` and `docs/specs/<module>.md`.
- Agent file changes → invalidate the `.github/agents/README.md` chunk.
- Skill `SKILL.md` changes → invalidate that skill's chunk only.

### Stale Chunk Detection
A chunk is stale when its `last_modified` timestamp is older than the source file that generates or governs it. Run `python tools/audit/cag_link_check.py` as a proxy stale-link detector.

### Evaluation Query Set (minimum 10 per corpus update)
- 3 exact-contract questions ("what does X return?")
- 3 workflow questions ("how do I Y?")
- 2 ownership questions ("which module owns Z?")
- 1 ambiguous-ownership question
- 1 stale-content trap (query for a renamed API)

Expected top-1 result must be from the canonical source, not a generated copy.

### Duplicate Ranking Problem
`docs/api/lurek.md`, `wiki/API-Reference.md`, and `docs/specs/<module>.md` may all describe the same function. Index only the canonical source at full weight; generated and wiki variants at 0.3 weight.

## References
- `docs/specs/`
- `docs/architecture/`
- `.github/`
- `tools/README.md`
- `extension/vscode/src/mcp/`
- `logs/data/`
