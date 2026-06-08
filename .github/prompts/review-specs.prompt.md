---
name: review-specs
description: Regenerate specs via script, then explicitly review and rewrite the human Summary section for the selected module(s).
---

# GOAL
- Ensure module specifications are up-to-date with code reality and rewrite `## Summary` as a unique, user-oriented synopsis of the module's delivered functionality.

# INPUTS REQUIRED
- Target module
= User must define which module spec to review. Allowed values: a single module name (for example `agent`) or `all modules`.
- Agent must collect current source code vs existing spec state

# STEPS TO DO
1. Load skills: docs-general, module-architecture.
2. Execute `python tools/docs/gen_module_specs.py` to refresh module specs in `docs/specs/`.
	- For one module: `python tools/docs/gen_module_specs.py --module <module>`
	- For all modules: `python tools/docs/gen_module_specs.py`
	If it exits with >0, fix source annotations/spec merge inputs and rerun until exit code 0.
3. For each selected module:
	- Open `docs/specs/<module>.md`.
	- Measure spec size before rewriting Summary:
	  - Count total non-empty lines in the whole spec.
	  - Count non-empty lines outside the `## Summary` section.
	- Rewrite the human-authored `## Summary` section to match regenerated data and current code reality, as a unique functional synopsis of the rest of the spec.
	- Write from the user's perspective: explain what the module lets a user build, control, observe, automate, or integrate.
	- Describe scope boundaries only as support for the user-facing value, not as a file inventory.
	- Use fresh wording that is not a paraphrase or copy of:
	  - file descriptions from `## Files`
	  - class/type/function descriptions from `## Lua API Ref`
	  - the module `TL;DR`, source docstrings, or generated tables
	- Do not list classes, files, or functions unless they are necessary to explain a user-visible capability or boundary.
	- If a sentence could be pasted into a file description, type description, or API entry without sounding wrong, rewrite it.
	- Target Summary size: approximately 10% of non-empty lines outside Summary (acceptable range: 8% to 12%).
	- Edit only the Summary narrative (do not hand-edit generated tables).
	- This review is mandatory even when no text changes are needed; report `reviewed-no-change` for that module and include measured ratio.
4. Execute `python tools/audit/lua_spec_coverage.py`. If it reports coverage <100% or missing specs, create missing spec files and repeat step 4 until it returns exactly 100%.

# OUTPUTS PROVIDED
- Updated `docs/specs/<module>.md`
- Spec coverage report
- Per-module Summary review status (`updated` or `reviewed-no-change`)
- Per-module Summary sizing evidence: `non-empty lines outside Summary`, `Summary non-empty lines`, and `% ratio`
- Per-module confirmation that Summary was checked for unique wording and user-facing functionality focus

# SUCCESS CRITERIA
- [ ] `python tools/docs/gen_module_specs.py` exits with code 0.
- [ ] `python tools/audit/lua_spec_coverage.py` reports exactly 100% spec coverage.
- [ ] For each selected module, `## Summary` is rewritten as functional synopsis and its size is in the 8%-12% range of non-empty lines outside Summary.
- [ ] For each selected module, `## Summary` uses unique wording and explains module value from the user's perspective rather than restating file/type/API descriptions.

# ANTI-PATTERNS
- Blindly accepting generated output without reviewing human-readable summaries.
- Allowing spec-to-code drift to remain unaddressed.
- Writing Summary as generic prose that does not reflect concrete functions/capabilities in the current spec.
- Copying or lightly paraphrasing file descriptions, class/type descriptions, Lua API entries, or the module `TL;DR` into Summary.
- Writing Summary as an internal implementation inventory instead of a user-facing capability description.
- Keeping Summary too short or too long versus the target 10% sizing rule.

# EXAMPLE INVOCATION
- User: "request for this prompt"
- Agent: Runs this prompt workflow with provided constraints and reports changed files plus validation evidence.

# REFERENCES
- skills: docs-general, module-architecture
- tools: python tools/docs/gen_module_specs.py, python tools/audit/lua_spec_coverage.py
- agent: Doc-Writer


