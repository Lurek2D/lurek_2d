---
name: review-specs
description: Regenerate specs via script and then review summary section based on updated content for specific module.
---

# GOAL
- Ensure module specifications are up-to-date with code reality and summarize changes.

# INPUTS REQUIRED
- Target module
= User must define which module spec to review
- Agent must collect current source code vs existing spec state

# STEPS TO DO
1. Load skills: documentation, module-architecture.
2. Execute `python tools/gen_all_docs.py` to automatically update the raw data tables in `docs/specs/<module>.md`. If it exits with >0, fix the source code annotations.
3. Rewrite the human-authored summary section in the spec to reflect the regenerated data.
4. Execute `python tools/audit/lua_spec_coverage.py`. If it reports coverage <100% or missing specs, create the missing spec files and repeat step 4 until it returns exactly 100%.

# OUTPUTS PROVIDED
- Updated `docs/specs/<module>.md`
- Spec coverage report

# SUCCESS CRITERIA
- `python tools/gen_all_docs.py` exits with code 0.
- `python tools/audit/lua_spec_coverage.py` reports exactly 100% spec coverage.

# ANIT PATTERNS
- Blindly accepting generated output without reviewing human-readable summaries.
- Allowing spec-to-code drift to remain unaddressed.

# REFERENCES
- skills: documentation, module-architecture
- tools: python tools/gen_all_docs.py, python tools/audit/lua_spec_coverage.py
- agent: Doc-Writer
