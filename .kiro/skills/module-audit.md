---
inclusion: manual
---

# module-audit

## Mission
Own the 12-phase module audit process: structure, documentation, testing, architecture, code quality checks, and the `tools/audit/audit_module.py` workflow.

## When To Use
- Running a full quality audit on a `src/` module.
- Checking a module against the 12-phase audit checklist.
- Preparing a module for review or release.

## When To Skip
- Implementing features, writing game scripts, pure Lua work.

## Rules

### Entry Point
`python tools/audit/audit_module.py <module>` runs 12 phases:
1. mod.rs thinness
2. File size limits
3. `docs/specs` presence
4. Lua API coverage
5. Test coverage
6. Wiki coverage
7. Example coverage
8. Dependency direction
9. lua_api wrapper leakage
10. println/eprintln hotspots
11. unsafe without SAFETY comments
12. bare unwrap in public paths

A module passing all 12 is ready for release.

### Phase 9 — Wrapper Leakage
Checks that no `src/<module>/` file imports from `src/lua_api/`. If it does, that is a T-02 violation — a blocking defect.

### Phase 3 — Docs/Specs Presence
Checks that `docs/specs/<module>.md` exists AND has non-empty Ownership and Invariants sections. A spec file with placeholder text fails this phase.

### Phase 4 — Lua API Coverage
Compares functions registered in `src/lua_api/<module>_api.rs` against `@covers` markers in `tests/lua/unit/test_<module>_*.lua`. Every registered function must have at least one test covering it.

### Phase 10 — println/eprintln
Any `println!` in `src/<module>/` is a defect. Engine output must go through `src/log/` with proper level tagging.

### Audit Output Format
Each finding includes: phase number, file path, line number, finding type (BLOCKING/WARNING/INFO), and description. BLOCKING findings must be resolved before merge.

### Routing Audit Findings
- BLOCKING dependency violations → Architect.
- BLOCKING coverage gaps → Tester.
- BLOCKING spec defects → Doc-Writer.
- Code-quality findings (unsafe, unwrap) → Developer.

### Additional Tool
Run `python tools/audit/doc_coverage.py --module <name>` alongside the main audit to get the documentation completeness score separately.

### Use as Pre-PR Gate
Run the audit before PR, not as a post-merge cleanup job. A module entering review with 12/12 phases passing costs half the reviewer time.

### Root Cause First
When several audit findings share a root cause, report the shared root cause first rather than listing individual findings.

## References
- `tools/audit/audit_module.py`
- `tools/audit/doc_coverage.py`
- `tools/audit/test_coverage.py`
- `tools/validate/validate_module_coverage.py`
