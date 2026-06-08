---
name: docs-specs
description: "Load this skill when creating or updating docs/specs/<module>.md merged module specs. It owns section layout, sync rules, and validate flow. Skip it for Rust code, tests, or Lua scripts."
---
# docs-specs

## Use when
- Create a new merged module spec.
- Update docs/specs/<module>.md after source changes.
- Check section order or spec sync rules.

## Avoid when
- Rust implementation.
- Test writing.
- Lua script work.

## Repo rules
- `docs/specs/<module>.md` describes exactly one module â€” one `src/<module>/` directory. Split if two modules.
- Required sections: **Overview**, **Ownership**, **Public API**, **Invariants**, **Dependencies**, **Test Coverage**, **References**. Generator writes Public API.
- Auto-generated sections come from `python tools/docs/gen_module_specs.py`. Fix docstrings to fix auto-sections.
- Version of truth: `docs/specs/<module>.md` is truth for what module owns. Ownership section must answer where code goes.
- Run `python tools/validate/validate_module_coverage.py` on structure changes. Confirms spec matches `src/` and README is updated.
- Write Invariants section. It must state: what preconditions, postconditions, and what module refuses to do.
- No `AGENT.md` files. Put docs in `docs/specs/<module>.md`.
- Dependencies must list tier relationships: module tier, imports, and imports block. Enforces T-01 and T-02.
- Archive old specs on remove. Update README.
- Spec must answer: "What it owns, what it does not, caller guarantees."

## Checks
- `python tools/docs/gen_module_specs.py`
- `python tools/validate/validate_module_coverage.py`

## References
- `docs/specs/`
- `docs/specs/SPEC_TEMPLATE.md`
- `tools/docs/gen_module_specs.py`
- `tools/validate/validate_module_coverage.py`

