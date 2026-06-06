---
inclusion: manual
---

# cag-workflow

## Mission
Own `.github` file types, format rules, validation flow, and agent routing.

## When To Use
- Add or edit an agent, skill, prompt, or the system prompt.
- Decide if content belongs in a module spec, skill, agent, or prompt.
- Run `cag_validate.py`.
- Check agent routing.

## When To Skip
- Engine code work, Lua game scripting, roadmap planning.

## Rules

### File Type Selection
- System prompt (`copilot-instructions.md`) = always-on global rules.
- Agent (`*.agent.md`) = role identity, owned scope, and routing.
- Skill (`SKILL.md`) = HOW-TO domain knowledge loaded on demand.
- Prompt (`*.prompt.md`) = a focused multi-step workflow for one recurring task.
Mixing these purposes into the wrong file type breaks discoverability.

### Description Field
The `description` field is the discovery key. The first sentence must state the trigger condition precisely.
- Bad: "General Rust coding help."
- Good: "Load this skill when writing or reviewing Rust engine code in src/."

### When To Load / When To Skip
These are hard routing guards. When To Skip prevents skill stacking. If two skills have overlapping When To Load triggers, one is too broad.

### No Duplication
Shared policy belongs in `copilot-instructions.md` exactly once. If the same rule appears in a skill AND an agent, delete it from one and add a link. Duplication causes version drift.

### Token Cost
Every line added to `copilot-instructions.md` is loaded on every request. Anything not always-relevant belongs in a skill or agent. Prune regularly.

### Validation Is Mandatory
Run `python tools/validate/cag_validate.py` for schema compliance. Run `python tools/audit/cag_link_check.py --strict` for file reference integrity. Both must pass before any CAG commit.

### Workflow
baseline validate → minimal change → validate again → run `cag_link_check.py --strict` → update `docs/CHANGELOG.md` → commit. Never commit a CAG change without a green validator run.

### New Skill Criteria
A new skill is justified when: (1) its When To Load triggers are unique and non-overlapping, (2) domain knowledge is not duplicated elsewhere, (3) at least one agent lists it in their bundle.

## References
- `.github/copilot-instructions.md`
- `.github/agents/README.md`
- `docs/architecture/cag-system.md`
- `tools/validate/cag_validate.py`
- `tools/audit/cag_link_check.py`
