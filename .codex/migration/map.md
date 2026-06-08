# Migration map

## System prompt
- `.github/copilot-instructions.md` -> `AGENTS.md`

## Agents to nested AGENTS
- `developer.agent.md` -> `src/AGENTS.md`
- `lua-designer.agent.md` -> `src/lua_api/AGENTS.md`
- `tester.agent.md` -> `tests/AGENTS.md`
- `doc-writer.agent.md` -> `docs/AGENTS.md`
- `architect.agent.md` -> `docs/architecture/AGENTS.md`
- `content-maker.agent.md` -> `content/AGENTS.md` and `library/AGENTS.md`
- `extension-engineer.agent.md` -> `extension/AGENTS.md`
- `build-engineer.agent.md` -> `tools/AGENTS.md`
- `cag-architect.agent.md` -> `.codex/AGENTS.md`

## Agents to role configs or skills
- `developer.agent.md` -> `.codex/agents/developer.toml`
- `tester.agent.md` -> `.codex/agents/tester.toml`
- `verifier.agent.md` -> `.codex/agents/reviewer.toml` plus `reviewer-gate`
- `architect.agent.md` -> `.codex/agents/architect.toml`
- `content-maker.agent.md` -> `.codex/agents/content.toml`
- `extension-engineer.agent.md` -> `.codex/agents/extension.toml`
- `build-engineer.agent.md` -> `.codex/agents/builder.toml`
- `manager.agent.md` -> `.codex/agents/manager.toml`
- `planner.agent.md` -> planning mode and future planning task-skills

## Prompts to task-skills
- `.github/prompts/*.prompt.md` -> `.codex/task-skills/*/SKILL.md`

## Skills
- `.github/skills/*/SKILL.md` -> `.codex/skills/*/SKILL.md`
