---
name: create-cag-artifact
description: Create or update new prompt, agent, skill or update them, revalidate CAG after it.
---

# GOAL
- Author or modify Context Augmented Guidance (CAG) artifacts in `.github/` and validate their structural integrity.

# INPUTS REQUIRED
- Artifact type (agent, skill, prompt)
- Desired behavioral change or definition
= User must define what the CAG system needs to learn or adjust
- Agent must collect existing CAG validation rules

# STEPS TO DO
1. Load skills: cag-workflow, cag-validation.
2. Edit or create the Markdown file in `.github/agents/`, `.github/skills/`, or `.github/prompts/` applying strict YAML formatting rules.
3. Execute `python tools/validate/cag_validate.py`. If it exits with code >0, fix the YAML metadata or naming conventions and repeat this step.
4. Execute `python tools/audit/cag_link_check.py --strict`. If it reports >0 broken links, fix the file references and repeat.

# OUTPUTS PROVIDED
- Updated CAG artifact files (`.md`)
- Clean validation output

# SUCCESS CRITERIA
- `python tools/validate/cag_validate.py` exits with code 0 (exactly 0 validation errors).
- `python tools/audit/cag_link_check.py --strict` exits with code 0 (exactly 0 broken links).

# ANIT PATTERNS
- Creating overlapping skills or agents that confuse the routing logic.
- Failing to include the mandatory `CAG Metadata` block.

# REFERENCES
- skills: cag-workflow, cag-validation
- tools: python tools/validate/cag_validate.py, python tools/audit/cag_link_check.py
- agent: CAG-Architect
