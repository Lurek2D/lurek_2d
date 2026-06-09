---
name: route-prompt
description: "Find the best prompt for the current work context."
---
# route-prompt

## Goal
- Identify the single most appropriate prompt for a user's request so the user can invoke it immediately.

## Required inputs
- User's request description (natural language)
- Optional: known agent name or domain constraint
- User provides the work objective
- Agent must collect available prompts in `.github/prompts/`

## Profile hint
- `manager`

## Read these contracts
- `.codex/AGENTS.md`

## Steps
- Read `.codex/AGENTS.md` and route by current folder contracts, role profiles, and task-skill scope instead of legacy routing skills.
- Read the user's natural language request. Categorize it to a primary domain (e.g., Rust engine, Lua API, testing).
- Identify the owning agent from the CAG architecture rules that is responsible for that domain.
- Scan `.github/prompts/` to find the prompt whose `description` or `goal` directly solves the user's request.
- Print the single best-matching prompt, detailing its agent, required skills, and provide a filled-out example invocation command. Do not guess or invent files.

## Outputs
- Recommendation output block with prompt details
- Filled-in example invocation line

## Success criteria
- [ ] Output lists exactly 1 prompt matching the request's domain.
- [ ] The printed invocation command contains 0 generic placeholders and 100% real values from the user's context.

## Stop conditions
- Nominating multiple prompts without a clear recommendation.
- Inventing prompt filenames that don't exist.

## References
- `contracts: .codex/AGENTS.md`
- `tools: file system read over `.github/prompts/``
- `agent: manager`


