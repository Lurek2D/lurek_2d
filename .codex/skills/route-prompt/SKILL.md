---
name: route-prompt
description: "Load this skill when choosing the best active Codex skill and owner profile for a user request. Skip it for executing the selected workflow or doing implementation directly."
---

# route-prompt

## Mission
- Route user requests to the narrowest active Codex skill and an existing owner profile.

## Domain Knowledge
- Routing is a three-part decision: artifact surface determines the owning profile, requested operation determines create/review/convert skill family, and proof obligations determine only the supporting skills needed after the primary choice.
- Frontmatter descriptions are the active load/skip predicates; Mission and Workflow help execute a selected skill but should not override a clear routing boundary in the description.
- The narrowest owner wins: `create-module` for a new top-level Rust owner, `create-engine-feature` for cross-surface engine evolution, public binding audits for `review-api`, and artifact-specific test/content skills for their canonical folders.
- Multi-surface requests still need one primary skill anchored to the desired outcome. Supporting skills are sequenced dependencies, not a list of every catalog item whose noun appears in the prompt.
- Available profiles are exactly the registered `.codex/config.toml` entries backed by `.codex/agents/*.toml`; a plausible role name that is not registered cannot receive a handoff.
- Negative scope matters: docs-only, content-only, internal Rust, extension, and CAG requests often share terms such as “API,” “module,” or “test,” so skip clauses prevent routing by keywords alone.
- A request to review and fix still routes first by the evidence surface: use the narrow review skill to establish findings, then its workflow may invoke the matching creation skill for authorized remediation rather than selecting a creation skill prematurely.
- Explicit user-named skills override inferred routing when available, but supporting skill choice and registered ownership must still respect repository contracts and the named skill's stated exclusions.

## Workflow
- Parse the request into desired outcome, target artifact/path, operation, public-versus-internal boundary, evidence requirement, and explicit exclusions; use RAG/filesystem metadata to resolve ambiguous project terms before comparing skills.
- Shortlist descriptions whose load clause matches, eliminate each candidate whose skip clause applies, then break ties by the narrowest canonical owner and whether the task creates behavior, creates proof/content, or audits existing work.
- Resolve the owner through `.codex/config.toml` and its backing agent TOML, add supporting skills only for mandatory downstream surfaces, and order them according to source/generation/validation dependencies without inventing parallel owners.
- Return one primary skill, one registered owner, concise rationale tied to routing predicates, supporting sequence if required, and concrete existing target paths/tools; identify a catalog gap explicitly when no active skill matches rather than fabricating an invocation.
- Test the proposed route against one plausible neighboring interpretation of the request and state the discriminator—target path, public boundary, artifact type, or requested operation—that makes the chosen skill narrower.
- When the prompt spans independent owners, decide whether one end-to-end skill already coordinates them; only recommend manager-style decomposition when no active primary workflow owns the complete outcome.

## References
- `contracts: .codex/AGENTS.md, AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "codex skills agents routing" --profile all --limit 10, filesystem reads of .codex/skills and .codex/agents`
- `agent: manager`
- RAG: Start with: `codex skills agents routing`, `Codex AGENTS skills agents routing`, `codex CAG skills agents prompts`; Focus areas first: `.codex/skills/`, `.codex/agents/`, `.codex/AGENTS.md`, root `AGENTS.md`; If the request names a surface, append it directly: `tests`, `pages`, `tool`, `module`, `extension`, `rag`
