---
name: create-cag-artifact
description: "Load this skill when creating or modifying Codex CAG artifacts such as local skills, agents, and routing guidance. Skip it for product code, docs content unrelated to Codex behavior, or broad repo audits."
---

# create-cag-artifact

## Mission
- Create or modify active Codex CAG artifacts and keep validation and routing coherent.

## Domain Knowledge
- Root and nested `AGENTS.md` files own path-scoped invariants; `.codex/agents/*.toml` own role behavior; `.codex/skills/*/SKILL.md` own reusable task procedures; `.codex/config.toml` makes profiles active.
- Skill descriptions are routing predicates: their load/skip clauses must discriminate neighboring skills, while the body explains execution after routing rather than repeating the trigger.
- Active skills intentionally retain Mission, Domain Knowledge, Workflow, and References. Optional `CAG Metadata` is for parser-consumed relationships, not general prose.
- Agent labels in references are executable registry names; they must resolve under `.codex/agents/` and match the surface that owns the work.
- Link validation resolves referenced artifacts, while `cag_validate.py` checks frontmatter, required sections, metadata names, fences, and registered owners.
- Skill content should encode judgment that another Codex instance cannot cheaply infer: project-specific ownership, parser contracts, ordering constraints, evidence standards, and failure recovery. Generic advice such as “write tests” or “follow best practices” consumes context without changing behavior.
- Similar skills need asymmetric boundaries. Creation skills explain how to produce an artifact; review skills explain how to establish evidence and severity; routing skills choose among them. Copying a shared workflow across those families weakens routing and wastes loaded context.
- References are retrieval handles as well as documentation. Paths and RAG phrases should point to canonical owners and realistic vocabulary a future task will contain, while avoiding obsolete migration paths or broad directories with no decision value.

## Workflow
- Classify each requested rule before editing: path invariant to the nearest `AGENTS.md`, role posture to an agent TOML, repeatable task judgment to a skill, and registry/runtime defaults to `.codex/config.toml`; link to an owner instead of copying its rules.
- Inspect the artifact, its validator/parser in `tools/validate/`, its template in `docs/templates/`, and adjacent routing boundaries. Preserve current names and catalog entries unless the request explicitly changes them.
- Rewrite the smallest owning surface with a discriminating description, project-specific decision knowledge, ordered verification, and resolvable references; when parser shape changes, update its validator and template in the same scope.
- Run focused then full CAG validation plus strict link checking, and manually verify that edited skills route to existing agents, avoid contract duplication, and remain distinct from sibling skills.
- Compare the revised skill against its closest two siblings and nearest contract line by line: remove copied invariants, sharpen conflicting load/skip cases, and retain only knowledge that changes the selected skill's execution.
- Rebuild the RAG index when indexed CAG sources change, run representative routing/retrieval queries for the edited artifact, and verify the intended skill ranks without displacing a higher-authority path contract.

## References
- `contracts: AGENTS.md, .codex/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "codex CAG skills agents prompts" --profile engine --limit 10, tools/python.cmd tools/validate/cag_validate.py, tools/python.cmd tools/audit/cag_link_check.py --strict`
- `agent: cag_architect`
- RAG: `codex CAG skills agents prompts`; `AGENTS.md SKILL.md prompt routing`; `.codex skills agents vendor_imports`; `.codex/`; root `AGENTS.md`; nested `AGENTS.md`
