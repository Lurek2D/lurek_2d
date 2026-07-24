---
name: route-prompt
description: "Load this skill when choosing the best active Codex skill and owner profile for a user request. Skip it for executing the selected workflow or doing implementation directly."
---

# route-prompt

## Mission
- Route user requests to the narrowest active Codex skill and an existing owner profile.

## Domain Knowledge
- Skill load and skip rules are in each `SKILL.md` frontmatter description.
- Mission explains the selected skill's outcome.
- Domain Knowledge gives repo facts for execution.
- Workflow gives the normal execution order.
- The target artifact path determines the canonical owner.
- The requested operation selects create, convert, or review.
- Proof requirements add only the supporting skills needed after the primary skill.
- One request has one primary skill when one workflow owns the final outcome.
- Supporting skills are ordered dependencies, not every skill that shares a noun with the prompt.
- `create-module` owns a new top-level Rust module and its complete public surface.
- `create-engine-feature` owns a feature that changes several engine surfaces.
- `review-api` owns Rust-to-Lua public binding parity review.
- Test skills are split by Lua unit, Rust seam, integration, evidence, and stress ownership.
- Content skills are split by example, game, library, layout, design, and snippet output.
- Registered profiles are defined in `.codex/config.toml`.
- Profile definitions are backed by `.codex/agents/*.toml`.
- An unregistered role name cannot receive a handoff.
- A review-and-fix request starts with the narrow review skill.
- The review workflow selects the matching create skill only after a finding is confirmed and fixes are authorized.
- An explicitly named available skill overrides inferred routing.
- Explicit exclusions in the user request and skill description still apply.
- If no active skill owns the outcome, the result is a catalog gap.
- The workspace registry currently contains 11 profiles and limits agent depth to 1.
- `manager` scopes, splits, and routes work; it is not the default implementation owner.
- `reviewer` owns read-only audits and verdicts.
- `builder` owns `tools/`, packaging, CI, and developer CLI work.
- `cag_architect` owns `.codex/`, RAG inputs, and retrieval tuning.
- `content` owns Lua artifacts in `content/`, `lurek_2d_content/`, and `lurek_2d_workbench/`.
- `extension` owns only `lurek_2d_extension/` and VS Code workflows.
- `.codex/coverage.toml` maps each domain to roots, contracts, and active skills.
- Domains marked `optional_checkout = true` may be absent without creating a new owner.

## Workflow
1. Read `.codex/AGENTS.md` and the nearest contract for the target path.
2. Extract the desired outcome from the request.
3. Identify the target artifact or repository path.
4. Identify create, convert, review, or routing operation.
5. Identify public versus internal ownership.
6. Record required proof and explicit exclusions.
7. Resolve unclear project terms with RAG and filesystem metadata.
8. Shortlist skills whose load rule matches the request.
9. Remove every skill whose skip rule matches.
10. Prefer the skill with the narrowest canonical artifact owner.
11. Prefer one end-to-end skill when it owns the full outcome.
12. Check explicit user-named skills before inferred choices.
13. Resolve the owner in `.codex/config.toml`.
14. Confirm its backing file exists under `.codex/agents/`.
15. Add supporting skills only for mandatory downstream work.
16. Order support by canonical source, generation, and validation.
17. Return one primary skill and one registered owner.
18. Give the load or skip facts that decided the route.
19. Name existing target paths and tools.
20. Report a catalog gap when no active skill matches.
21. Use manager-style decomposition only when independent owners have no single coordinating skill.

## References
- `contracts: .codex/AGENTS.md, AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "codex skills agents routing" --profile all --limit 10, filesystem reads of .codex/skills and .codex/agents`
- `agent: manager`
- RAG: `codex skills agents routing <surface>`; inspect matching frontmatter descriptions, nearest path contract, registered profile, and the closest excluded neighbor.
