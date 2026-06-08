---
name: cag-workflow
description: "Load this skill when editing .github agents, skills, prompts, or the system prompt, or when choosing the right CAG file type. Skip it for engine code, Lua scripts, or roadmap work."
---
# cag-workflow

## Use when
- Add or edit an agent, skill, prompt, or the system prompt.
- Decide if content belongs in a module spec, skill, agent, or prompt.
- Run cag_validate.py.
- Check agent routing.

## Avoid when
- Engine code work.
- Lua game scripting.
- Roadmap planning.

## Repo rules
- File type selection rule: system prompt = always-on global rules; agent = role identity, owned scope, and routing; skill = HOW-TO domain knowledge loaded on demand; prompt = a focused create-first workflow for one recurring task. Analysis, audit, review, fix, and run-only work belongs in tool scripts under tools/validate/ and tools/audit/, not in the prompt catalog.
- `description` field is the discovery key for skills and agents. It is searched first by the skill loader.
- `When To Load` and `When To Skip` sections are hard routing guards. When To Skip prevents skill stacking: two overlapping skills loaded simultaneously create conflicting advice.
- Shared policy belongs in `copilot-instructions.md` exactly once. If the same rule appears in a skill AND an agent AND a prompt, delete it from two of the three and add a link.
- Companion File Index lists only files that the skill reader must open to execute the skill correctly. Do not list architecture reference docs that are nice-to-know.
- Agent scope must be mutually exclusive. When two agents could plausibly handle the same request, that is a routing defect â€” the scope must be sharpened or one agent must defer explicitly.
- Before creating a new skill, check if an existing skill can absorb the domain knowledge. A new skill is justified when: its When To Load triggers are unique and non-overlapping, its domain knowledge is not duplicated elsewhere, at least one agent lists it in their bundle.
- Token cost rule: every line added to `copilot-instructions.md` is loaded on every request. Anything that is not always-relevant belongs in a skill or agent, not in the system prompt.
- Validation is mandatory before any CAG commit. Run `python tools/validate/cag_validate.py` for schema compliance, `python tools/validate/prompt_scope_report.py` to keep the prompt catalog create-first, and `python tools/audit/cag_link_check.py --strict` for file reference integrity.
- Workflow: baseline validate â†’ minimal change â†’ validate again â†’ run `cag_link_check.py --strict` â†’ commit. Never commit a CAG change without a green validator run.

## Checks
- `python tools/validate/cag_validate.py`
- `cag_link_check.py --strict`

## References
- `.github/copilot-instructions.md`
- `.github/agents/README.md`
- `docs/architecture/cag-system.md`
- `tools/validate/cag_validate.py`
- `tools/audit/cag_link_check.py`

