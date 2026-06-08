---
name: review-architecture
description: Review if docs in architecture are in sync with specs and lurek api, fix all gaps.
---

# GOAL
- Validate that high-level architecture documents align with module specs and the actual API surface.

# INPUTS REQUIRED
- Entire codebase context
= User triggers the architecture review
- Agent must collect `docs/architecture/` files, specs, and API definitions

# STEPS TO DO
1. Load skills: enterprise-architecture, docs-general.
2. Execute `python tools/audit/cag_link_check.py --strict`. Capture the number of broken links relating to `docs/architecture/`.
3. Modify the architecture markdown files to fix outdated module names and broken references to deprecated APIs.
4. Execute `python tools/audit/cag_link_check.py --strict` again. If the broken link count is >0, repeat step 3 until the count is exactly 0.

# OUTPUTS PROVIDED
- Updated markdown files in `docs/architecture/`
- Gap analysis summary

# SUCCESS CRITERIA
- [ ] `python tools/audit/cag_link_check.py --strict` reports exactly 0 broken links.

# ANTI-PATTERNS
- Modifying code to fit outdated architecture docs (docs should follow code reality).
- Adding overly granular implementation details to high-level architecture docs.

# EXAMPLE INVOCATION
- User: "request for this prompt"
- Agent: Runs this prompt workflow with provided constraints and reports changed files plus validation evidence.

# REFERENCES
- skills: enterprise-architecture, docs-general
- tools: python tools/audit/cag_link_check.py
- agent: Architect


