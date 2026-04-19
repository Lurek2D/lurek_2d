# P0 — Baseline Audit & Gates

**Session:** `src-module-review-20260418`
**Phase:** P0 — Baseline audit & gates
**Agent:** Reviewer
**Branch:** `refactor/src-migration-v2`
**Commit:** `5d8e9eb8b11e07e10992a8119f066d9eda70eb6f`
**Result:** **BLOCKED** — Rust toolchain not available in this environment.

---

## Blocker

`cargo` is not installed on this machine.

- `where.exe cargo` → not found.
- `C:\Users\TomaszBłądkowski\.cargo\bin\` does not exist (`Test-Path` = False), even though that directory is present in `$env:Path`.
- `Get-ChildItem -Recurse -Filter cargo.exe` across `C:\Users\…\AppData` and `C:\Program Files` returned nothing.

Therefore the two cargo-bound gates of P0 cannot be executed:

1. `cargo test` — **NOT RUN** (no toolchain).
2. `cargo clippy -- -D warnings` — **NOT RUN** (no toolchain).

Per the run instructions ("If `cargo test` or `cargo clippy` fail OUTSIDE the docstring/doc-coverage scope … STOP and return `result: BLOCKED`"), I have stopped before producing the full P0 report. Manager must triage:

- install `rustup` + the `1.78`-stable toolchain pinned by [rust-toolchain.toml](rust-toolchain.toml), **or**
- delegate P0 to an environment that has `cargo` on PATH, **or**
- revise PLAN.md P0 to skip the cargo gates and proceed on Python/CAG signals only.

---

## Lint policy decision (answerable without cargo)

**Question:** Is `missing_docs` (or `clippy::missing_docs_in_private_items`) currently enforced under `-D warnings`?

**Answer: NO.**

- `grep_search` for `missing_docs` across `src/**/*.rs` (including `src/lib.rs`) returns **zero matches**.
- `src/lib.rs` lines 1–30 contain only the crate-level rustdoc preamble — no `#![warn(...)]` / `#![deny(...)]` lint attributes for `missing_docs` (or anything else doc-related). [src/lib.rs](src/lib.rs#L1-L30)
- Confirmed by direct inspection: there is no root-crate lint gate that would fail the build on missing docstrings today.

**Implication for P3:** Manager's per-family commit gate does **not** need to fight a `missing_docs`-driven clippy fail today. Adding docstrings is a pure docs improvement and will not by itself flip clippy red/green. Conversely, anyone who later turns `#![deny(missing_docs)]` on at the crate root will instantly get a wall of failures for every undocumented public item the audit identifies.

---

## Python / CAG gate results (executed)

| Tool | Status | Headline |
|---|---|---|
| `python tools/audit/doc_coverage.py` | PASS | 5086 / 5086 = **100.0 %** (rust 5037/5037, lua 49/49) |
| `python tools/audit/test_coverage.py` | exit 1 (by design — non-zero on uncovered items) | rust **31.7 %** (1236/3904), lua **90.9 %** (3291/3622) |
| `python tools/gen_all_docs.py` | **FAILED (exit 1)** | All doc generators succeed; pipeline marks itself failed because it pipes through `tools/audit/test_coverage.py`, which exits 1 on coverage gaps — not a real generator failure. Generated artifacts are present and current. |
| `python tools/validate/cag_validate.py --baseline` | PASS | system_prompt=1, agents=20, skills=33, prompts=56, **0 errors / 0 warnings**, baseline OK |

Logs: `docs/logs/doc_coverage.json`, `docs/logs/test_coverage.json`.

### Doc coverage gaps

None. **100 %** for both Rust public items and Lua API bindings. No modules below 100 %.

### Test coverage gaps

Rust uncovered items by module (top 25 of 49):

| Module | Uncovered items |
|---|---:|
| ai | 198 |
| tilemap | 185 |
| audio | 174 |
| physics | 137 |
| ui | 134 |
| image | 109 |
| graph | 102 |
| math | 92 |
| pathfind | 86 |
| patterns | 85 |
| terminal | 82 |
| compute | 81 |
| input | 79 |
| minimap | 77 |
| dataframe | 73 |
| lua_api | 69 |
| ecs | 68 |
| light | 63 |
| effect | 57 |
| network | 51 |
| filesystem | 47 |
| data | 36 |
| spine | 36 |
| render | 35 |
| animation | 34 |

Lua uncovered items: 331, all in `lua_api/` (the auditor classifies Lua coverage by binding file, not domain module).

Full per-item lists: `docs/logs/test_coverage.json` (uncovered_items array; 2668 rust + 331 lua).

---

## Risks / findings for P3 (advisory — written despite BLOCKED status)

1. **Rust test coverage is the dominant gap, not docs.** Doc coverage is already 100 %. The biggest payoff in this session will come from P3-style work on test coverage, not docstrings. Manager should consider whether the current PLAN.md weighting reflects this.
2. **`tools/gen_all_docs.py` exit code is misleading.** It exits 1 whenever `tools/audit/test_coverage.py` finds gaps (i.e. essentially always). Consider splitting "generators" from "audits" in the pipeline or marking the audit step as advisory inside the pipeline. If P3 family gates rely on `gen_all_docs.py` exit 0, they will spuriously fail.
3. **`missing_docs` is not enforced.** Family commit gates that add docstrings will not be tightened by clippy; a reviewer/CI check on `doc_coverage.py` ≥ 100 % is the actual enforcement surface today.
4. **Top-5 worst-tested modules (ai, tilemap, audio, physics, ui)** account for 828/2668 = 31 % of all Rust gaps. P3-A (or whichever family covers these) will dominate the session.
5. **`lua_api` shows 69 uncovered Rust items + 331 uncovered Lua bindings.** Per the Lua-first testing rule, the 331 should be tested in Lua under `tests/lua/`. Worth a dedicated sub-phase rather than mixing into a domain-module sweep.

---

## Files this run produced

- `work/src-module-review-20260418/scripts/p0_breakdown.py` — derives per-module breakdown from `docs/logs/test_coverage.json`.
- `work/src-module-review-20260418/reports/P0_BASELINE.md` — this file.
- `docs/logs/doc_coverage.json`, `docs/logs/test_coverage.json` — refreshed by the runs above.
- `docs/CHANGELOG.md` — appended one bullet per run instructions.

No source code was modified. Nothing was staged. Nothing was committed.
