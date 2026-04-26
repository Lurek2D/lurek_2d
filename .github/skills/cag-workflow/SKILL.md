---
name: cag-workflow
description: "Load this skill when working with the Lurek2D CAG (Copilot Agent Customization) layer: building or editing agents, skills, or prompts under .github/; choosing the right CAG artifact type; running cag_validate.py; or designing the AI-first workflow for a new task type. Skip it for general code implementation, game scripting, or roadmap planning."
---
# cag-workflow

## Mission

Own .github/ folder taxonomy, CAG artifact type decisions, skill/agent/prompt file format requirements, validation workflow, and agent routing.

## When To Load

- Adding or editing an agent, skill, or prompt
- Deciding whether knowledge should be a skill, agent, prompt, or module spec
- Running cag_validate.py to check schema compliance
- Understanding how agents route work to each other
- Maintaining copilot-instructions.md

## When To Skip

- General code implementation, game scripting, or roadmap planning

## Domain Knowledge

**CAG artifact taxonomy:**

| Artifact | When to use | Loaded by |
|----------|-------------|-----------|
| Module spec (docs/specs/<module>.md) | Module-specific architecture, types, constraints | Agents reading domain context |
| Skill (.github/skills/) | Cross-cutting reusable knowledge across modules | Explicitly via read_file |
| Agent (.github/agents/) | Specialist role with defined mission and scope | Via runSubagent or @AgentName |
| Prompt (.github/prompts/) | Task-driven playbook for a specific operation | Operator selection |

**Decision rule:** If knowledge is specific to one module → module spec. If cross-cutting pattern used across modules → skill. If it defines a role with routing → agent. If it is a user-invocable task playbook → prompt.

**Skill file format:** YAML frontmatter (name, description with "Load this skill when"/"Skip it for" clauses). Required sections: Mission, When To Load, When To Skip, Domain Knowledge, Companion File Index, References. No fenced code blocks (E201). Max 120 lines (W206).

**Agent file format:** YAML frontmatter (name, mission, personas, primary_skills, secondary_skills, routes_to, loads_tools). Required sections: Mission, Scope, Inputs, Outputs, Workflow, Routing Table, Anti-patterns. Max 200 lines.

**Prompt file format:** YAML frontmatter (description, mode, loads_skills, loads_tools, expected_agent, inputs_required). Required sections: Goal, Inputs, Steps, Success Criteria, Anti-patterns, Example Invocation. Approved verbs: analyze, create, fix, run, review, design, doc, workflow, op, implement, generate, audit.

**Validation:** run tools/validate/cag_validate.py (--type agent|skill|prompt, --file PATH, --baseline). Exit 1 = failures. Full rule details in tools-cag-validation skill.

**Load order:** copilot-instructions.md (always) → docs/specs/ (explicit) → Skills (explicit read_file) → Prompts (operator) → Agents (runSubagent).

**Agent routing — Manager routes to:** Developer (Rust), Lua-Designer (API), Renderer (GPU), Physicist (physics), Tester (tests), Doc-Writer (docs), Debugger (bugs).

**Updating copilot-instructions.md:** add/remove skill → update skills list; add agent → update agents list; change constraint → update table. Use replace_string_in_file on the specific section, never rewrite the whole file.

## Companion File Index

None — all guidance is inline.

## References

- .github/copilot-instructions.md — system prompt backbone
- docs/architecture/cag-system.md — full CAG system documentation
- tools/validate/cag_validate.py — schema validator
