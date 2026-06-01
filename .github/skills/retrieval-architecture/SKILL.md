---
name: retrieval-architecture
description: "Load this skill when designing or maintaining retrieval corpus shape, chunking, freshness, source ranking, or RAG evaluation for agent support. Skip it for generic."
---
# retrieval-architecture

## Mission
- Own retrieval corpus design, freshness rules, and evaluation for agent-facing knowledge.

## When To Load
- Define a retrieval corpus.
- Add or change chunking rules.
- Design source ranking or provenance.
- Evaluate RAG quality or freshness.

## When To Skip
- Generic CAG writing.
- Engine code work.
- Non-retrieval docs updates.

## Domain Knowledge
- Source priority: binding constraints â†’ CAG layer â†’ module specs â†’ architecture docs â†’ handbook/CONTRIBUTING â†’ wiki pages â†’ examples/games â†’ generated outputs. A retrieval answer from a higher tier overrides one from a lower tier.
- Chunk by ownership boundary, not by fixed byte size. One complete SKILL.md, one module spec, one agent file, one `## Section` in a doc, or one function docstring are all natural chunk units.
- Generated files must be indexed at lower priority than their sources. When both the source and the generated output match a query, prefer the source â€” it is what gets edited.
- Freshness trigger table: if `src/lua_api/<module>_api.rs` changes, invalidate chunks for `docs/api/lurek.md` and `docs/specs/<module>.md`. If an agent file changes, invalidate the `.github/agents/README.md` chunk.
- Stale chunk detection: a chunk is stale when its `last_modified` timestamp is older than the source file that generates or governs it. Run `python tools/audit/cag_link_check.py` as a proxy stale-link detector for CAG chunks.
- Evaluation query set: 3 exact-contract questions, 3 workflow questions, 2 ownership questions, 1 ambiguous-ownership question, 1 stale-content trap. Expected top-1 result must be from the canonical source, not a generated copy.
- Duplicate ranking problem: `docs/api/lurek.md`, `wiki/API-Reference.md`, and `docs/specs/<module>.md` may all describe the same function. Index only the canonical source at full weight; generated and wiki variants at 0.3 weight.
- Coverage gap reporting: `python tools/audit/doc_coverage.py --retrieval` outputs modules with no retrievable spec. Each gap is a source that must be added or a module that needs a spec created.
## Companion File Index
- None.

## References
- docs/specs/
- docs/architecture/
- .github/
- tools/README.md
- extension/vscode/src/mcp/
- logs/data/
