## Lurek2D tools registry

This file is the canonical inventory of reusable scripts under `tools/`.

Policy:
- Keep only long-term tools that are reusable by developers, agents, or recurring maintenance workflows.
- Put one-off migrations, single-batch cleanups, and temporary debug scripts under `work/<session>/scripts/` instead of `tools/`.
- Treat subfolder `README.md` files as local usage notes. This file is the source of truth for what stays in `tools/`.

## Root orchestration

- `tools/gen_all_docs.py` - runs the full generated-doc pipeline in dependency order.

## tools/docs

- `tools/docs/collect_docs.py` - collect Rust and Lua docs into structured reports.
- `tools/docs/gen_docs_lua.py` - render `docs/api/lurek.md` from Lua API data.
- `tools/docs/gen_docs_rust.py` - render `docs/api/rust.md` from Rust API data.
- `tools/docs/gen_engine_docs.py` - generate engine-facing docs and reports from `src/`.
- `tools/docs/gen_extension_api.py` - export API data for the VS Code extension.
- `tools/docs/gen_lib_docs.py` - generate library API docs.
- `tools/docs/gen_luadoc.py` - generate LuaCATS stubs.
- `tools/docs/gen_lua_api.py` - scan Lua API doc comments and extract API metadata.
- `tools/docs/gen_lua_api_data.py` - generate structured Lua API data from `src/lua_api/`.
- `tools/docs/gen_lua_binding_reports.py` - snapshot Lua bindings from code and doc comments.
- `tools/docs/gen_lua_dev_docs.py` - generate developer-facing Lua API reports.
- `tools/docs/gen_lua_docstring_skeletons.py` - generate missing-doc skeleton suggestions for Lua bindings.
- `tools/docs/gen_lua_library_api.py` - generate Lua library API artifacts.
- `tools/docs/gen_module_specs.py` - refresh generated sections in `docs/specs/*.md`.
- `tools/docs/gen_rust_api_data.py` - generate structured Rust API data from `src/`.
- `tools/docs/gen_rust_docstrings.py` - generate or analyze Rust docstring scaffolding.
- `tools/docs/gen_test_docs.py` - generate Rust and Lua test catalog docs.
- `tools/docs/gen_wiki.py` - generate broader wiki pages.
- `tools/docs/gen_wiki_api.py` - generate API-focused wiki pages.
- `tools/docs/scan_missing_docs.py` - scan source for missing documentation.

## tools/audit

- `tools/audit/audit_module.py` - run the end-to-end module audit.
- `tools/audit/cag_coverage.py` - report required-section and field coverage for CAG files.
- `tools/audit/cag_link_check.py` - report broken CAG links and path references.
- `tools/audit/cag_persona_matrix.py` - build the persona-to-agent coverage matrix.
- `tools/audit/count_gaps.py` - count documentation gaps by Lua API module.
- `tools/audit/docstring_audit.py` - audit Lua binding docstring quality per file.
- `tools/audit/doc_audit.py` - combine Rust and Lua doc audits into one report.
- `tools/audit/doc_coverage.py` - measure Rust and Lua doc coverage.
- `tools/audit/example_add_missing.py` - append missing example stubs for uncovered API items.
- `tools/audit/example_coverage.py` - measure `content/examples/` coverage against the Lua API.
- `tools/audit/extract_constructors.py` - extract constructor information from API metadata.
- `tools/audit/gen_coverage_gaps.py` - generate the Rust-to-Lua coverage gap report.
- `tools/audit/gen_lua_contract_tests.py` - generate Lua contract-test scaffolding from API data.
- `tools/audit/get_api_sigs.py` - extract API signatures for inspection or comparison.
- `tools/audit/golden_test.py` - run deterministic golden-output comparisons.
- `tools/audit/inline_test_audit.py` - find inline Rust tests that should move out of `src/`.
- `tools/audit/integration_coverage.py` - measure integration test module-pair coverage.
- `tools/audit/library_coverage.py` - measure library coverage and completeness.
- `tools/audit/lua_api_test_coverage.py` - measure Lua API coverage via `@covers` markers.
- `tools/audit/lua_covers_lurek_api_audit.py` - audit `@covers` usage against the Lua API surface.
- `tools/audit/lua_evidence_golden_contract_audit.py` - audit evidence and golden test markers.
- `tools/audit/lua_spec_coverage.py` - compare Lua-facing behavior against spec coverage.
- `tools/audit/lua_test_structure_audit.py` - audit Lua test structure and marker placement.
- `tools/audit/mutation_report.py` - summarize mutation-test style findings.
- `tools/audit/parse_test_log.py` - parse Rust test logs for higher-level reporting.
- `tools/audit/perf_regression_gate.py` - fail on configured performance regressions.
- `tools/audit/quality_report.py` - produce the top-level quality dashboard.
- `tools/audit/scan_api_names.py` - scan API names from source artifacts.
- `tools/audit/scan_exact.py` - run exact text or signature scans.
- `tools/audit/scan_module_fns.py` - scan module function inventories.
- `tools/audit/scan_sigs.py` - scan extracted signatures.
- `tools/audit/stress_report.py` - summarize stress-test output.
- `tools/audit/strict_api_check.py` - strictly validate example API stub usage.
- `tools/audit/strict_api_check_math.py` - strict API stub validation for math examples.
- `tools/audit/test_analytics.py` - summarize test execution trends.
- `tools/audit/test_coverage.py` - measure Rust test coverage heuristically.
- `tools/audit/thin_modrs_audit.py` - flag non-thin `mod.rs` files.
- `tools/audit/thin_wrapper_audit.py` - flag business logic in Lua API wrapper files.
- `tools/audit/tool_registry_audit.py` - audit this tools registry for consistency.
- `tools/audit/unit_test_api_coverage.py` - report unit-test API coverage metrics.
- `tools/audit/wiki_coverage.py` - measure wiki coverage against modules and libraries.

## tools/validate

- `tools/validate/cag_validate.py` - validate `.github/` CAG files.
- `tools/validate/check_callbacks.py` - validate callback formatting in generated docs.
- `tools/validate/validate_changelog.py` - validate changelog structure and dates.
- `tools/validate/validate_game.py` - validate game and example directory structure.
- `tools/validate/validate_generated_lua_stubs.py` - ensure generated Lua artifacts are fresh.
- `tools/validate/validate_library.py` - validate `library/` entries and LDoc coverage.
- `tools/validate/validate_lua_api.py` - validate Lua binding doc comments against project rules.
- `tools/validate/validate_lua_binding_reports.py` - validate code-vs-doc binding snapshots.
- `tools/validate/validate_module_coverage.py` - ensure every top-level module has a matching spec.
- `tools/validate/validate_param_types.py` - validate `@param` types against Rust closure inference.
- `tools/validate/validate_rust_source_docs.py` - validate Rust source doc coverage rules.

Internal support files:
- `tools/validate/_cag_common.py` - shared helper module for CAG validators and audits.
- `tools/validate/cag_validate.baseline.json` - optional baseline snapshot for the CAG validator.

## tools/fix

These scripts modify files in place. Prefer `--dry-run` when the tool supports it.

- `tools/fix/add_lua_docstrings.py` - interactive helper for adding missing Lua binding docstrings.
- `tools/fix/add_lua_docstrings_auto.py` - non-interactive generator for missing Lua binding docstrings.
- `tools/fix/add_test_markers.py` - add missing Lua test markers like `@covers`.
- `tools/fix/docstring_fix.py` - patch missing Lua binding doc tags from audit output.
- `tools/fix/expand_examples.py` - expand example blocks with richer usage.
- `tools/fix/fix_docstrings.py` - fill missing Rust doc comment sections.
- `tools/fix/fix_param_types.py` - auto-correct `number` vs `integer` mismatches in Lua binding docs.
- `tools/fix/format_examples.py` - normalize example formatting.
- `tools/fix/improve_examples.py` - improve example quality in bulk.
- `tools/fix/improve_lua_docstrings.py` - rewrite thin Lua binding docstrings with better content.

## tools/dev

- `tools/dev/parallel_cargo.py` - unified wrapper for build, check, run, test, clippy, fmt, and doc flows.
- `tools/dev/test_fix_loop.py` - local test/fix iteration helper.

## tools/dist

- `tools/dist/dist.ps1` - build and package the Windows release.
- `tools/dist/dist.sh` - build and package Linux and macOS releases.
- `tools/dist/install.ps1` - install the Windows binary locally.
- `tools/dist/install.sh` - install the Unix binary locally.
- `tools/dist/installer.nsi` - NSIS installer definition for Windows.
- `tools/dist/pack.ps1` - pack a game folder into a `.lurek` archive on Windows.
- `tools/dist/pack.py` - cross-platform `.lurek` packer.
- `tools/dist/package_games.py` - package game/demo content for distribution workflows.
- `tools/dist/register_lurek_filetype.ps1` - register the `.lurek` file type on Windows.
- `tools/dist/release.ps1` - run the full Windows release pipeline.

## tools/demos

- `tools/demos/gen_demo_screenshots.py` - generate screenshots for demos.
- `tools/demos/gen_game_readmes.py` - generate or refresh demo and game README files.
- `tools/demos/organize_demos.py` - reorganize demo folders.
- `tools/demos/smoke_sweep.py` - smoke-test demos and examples for crash-free launch.

## tools/ui

- `tools/ui/fix_layouts.py` - normalize or repair UI layout TOML files.
- `content/games/tools/layout_toml_renderer` - render UI layout TOML files to PNG through the engine runtime.
- `tools/ui/snap_to_grid.py` - snap UI layout coordinates to a grid.

## tools/github

- `tools/github/ideas_to_github_issues.py` - import `ideas/` entries into GitHub issues.
- `tools/github/sync_agent_rules.py` - synchronize workspace rules file (.antigravityrules) with .github/copilot-instructions.md.

## tools/mods

- `tools/mods/mod_init.py` - scaffold a new mod.

## Notes-only directories

- `tools/assets/` - notes about engine asset placement, no executable tools.

## Keep this directory clean

If a script is written to fix one file, one demo, one migration, or one temporary batch, do not add it here. Put it under `work/<session>/scripts/` and archive it with the session.

## Filename index

This parser-friendly index is kept so `tools/audit/tool_registry_audit.py` can verify that every reusable tool is registered here.

- Root: `gen_all_docs.py`
- `tools/docs`: `collect_docs.py`, `gen_docs_lua.py`, `gen_docs_rust.py`, `gen_engine_docs.py`, `gen_extension_api.py`, `gen_lib_docs.py`, `gen_luadoc.py`, `gen_lua_api.py`, `gen_lua_api_data.py`, `gen_lua_binding_reports.py`, `gen_lua_dev_docs.py`, `gen_lua_docstring_skeletons.py`, `gen_lua_library_api.py`, `gen_module_specs.py`, `gen_rust_api_data.py`, `gen_rust_docstrings.py`, `gen_test_docs.py`, `gen_wiki.py`, `gen_wiki_api.py`, `scan_missing_docs.py`
- `tools/audit`: `audit_module.py`, `cag_coverage.py`, `cag_link_check.py`, `cag_persona_matrix.py`, `count_gaps.py`, `docstring_audit.py`, `doc_audit.py`, `doc_coverage.py`, `example_add_missing.py`, `example_coverage.py`, `extract_constructors.py`, `generate_examples2_stubs.py`, `gen_coverage_gaps.py`, `gen_lua_contract_tests.py`, `get_api_sigs.py`, `golden_test.py`, `inline_test_audit.py`, `integration_coverage.py`, `library_coverage.py`, `lua_api_test_coverage.py`, `lua_covers_lurek_api_audit.py`, `lua_evidence_golden_contract_audit.py`, `lua_spec_coverage.py`, `lua_test_structure_audit.py`, `mutation_report.py`, `parse_test_log.py`, `perf_regression_gate.py`, `quality_report.py`, `scan_api_names.py`, `scan_exact.py`, `scan_module_fns.py`, `scan_sigs.py`, `stress_report.py`, `strict_api_check.py`, `strict_api_check_math.py`, `test_analytics.py`, `test_coverage.py`, `thin_modrs_audit.py`, `thin_wrapper_audit.py`, `tool_registry_audit.py`, `unit_test_api_coverage.py`, `wiki_coverage.py`
- `tools/validate`: `cag_validate.py`, `check_callbacks.py`, `validate_changelog.py`, `validate_game.py`, `validate_generated_lua_stubs.py`, `validate_library.py`, `validate_lua_api.py`, `validate_lua_binding_reports.py`, `validate_module_coverage.py`, `validate_param_types.py`, `validate_rust_source_docs.py`
- `tools/fix`: `add_lua_docstrings.py`, `add_lua_docstrings_auto.py`, `add_test_markers.py`, `docstring_fix.py`, `expand_examples.py`, `fix_docstrings.py`, `fix_param_types.py`, `format_examples.py`, `improve_examples.py`, `improve_lua_docstrings.py`
- `tools/dev`: `parallel_cargo.py`, `test_fix_loop.py`
- `tools/dist`: `pack.py`, `package_games.py`
- `tools/demos`: `gen_demo_screenshots.py`, `gen_game_readmes.py`, `organize_demos.py`, `smoke_sweep.py`
- `tools/ui`: `fix_layouts.py`, `snap_to_grid.py`
- `tools/github`: `ideas_to_github_issues.py`, `sync_agent_rules.py`
- `tools/mods`: `mod_init.py`
python tools/audit/audit_module.py --all --docs-quality  # all module reports
python tools/audit/lua_api_test_coverage.py --report  # Lua test coverage
```

### After editing `.github/` CAG files

```powershell
python tools/validate/cag_validate.py                 # validate CAG layer
```

### After editing `library/`

```powershell
python tools/validate/validate_library.py             # validate all libraries
python tools/validate/validate_library.py --library NAME --strict  # single library
python tools/docs/gen_lib_docs.py                     # regenerate library docs
```

### After editing `docs/CHANGELOG.md`

```powershell
python tools/validate/validate_changelog.py           # validate structure
python tools/validate/validate_changelog.py --strict   # treat warnings as errors
```

### After editing `tools/`

```powershell
python tools/audit/tool_registry_audit.py             # self-audit tools registry
```

---

## Adding a New Tool

1. Choose the right subfolder (`docs/`, `audit/`, `fix/`, `validate/`, `dist/`, or `github/`)
2. Add a module-level docstring with:
   - One-sentence purpose
   - Usage examples matching the new path
3. Update the subfolder's `README.md` table
4. Update this `tools/README.md` table
5. If the tool is invoked from `gen_all_docs.py`, add it to the `SCRIPTS` list there
6. If it needs a VS Code task, add an entry in `.vscode/tasks.json`
7. If it's a quality tool, consider adding it to the `quality-pipeline` skill

---

## Discovery for Agents

AI agents working in this repo should pick a tool by **subfolder taxonomy first, script docstring second**. The taxonomy maps directly to intent:

| Intent                                                | Subfolder           |
| ----------------------------------------------------- | ------------------- |
| "Is this CAG / spec / contract well-formed?"          | `tools/validate/`   |
| "Measure quality / coverage / report gaps."           | `tools/audit/`      |
| "Modify source files in-place to fix something."      | `tools/fix/`        |
| "Regenerate generated documentation."                 | `tools/docs/`       |
| "Build, package, or install the engine binary."       | `tools/dist/`       |
| "Manage GitHub issues, milestones, or releases."      | `tools/github/`     |
| "Maintain `content/demos/` (folders, screenshots)."   | `tools/demos/`      |
| "Author or scaffold a `lurek-mod` plugin."            | `tools/mods/`       |
| "Render or fix `*.layout.toml` UI files."             | `tools/ui/`         |
| "Engine-developer helper (test-fix loop, etc)."       | `tools/dev/`        |

Workflow:
1. Classify the task into one of the rows above.
2. Open that subfolder's `README.md` and pick the script whose one-line description matches.
3. Read the script's module docstring (`python -c "import tools.subdir.script as m; print(m.__doc__)"` or just open the file) for full CLI flags.
4. If no script fits, check **Standalone utilities** below â€” a one-shot might already exist.

Validators always exit 1 on failure; auditors print metrics and return 0 unless `--strict` or `--threshold` is used; fixers default to in-place edits and should be invoked with `--dry-run` first when supported.

---

## Standalone utilities

Scripts kept in `tools/` that are not currently referenced by any `.github/` agent, skill, or prompt. They remain because they are ad-hoc one-shots, archived debug helpers, or have niche scopes.

| Script                                          | Kept because                                                              |
| ----------------------------------------------- | ------------------------------------------------------------------------- |
| `tools/audit/gen_coverage_gaps.py`              | Invoked via `gen_all_docs.py` orchestrator, not directly by agents.       |
| `tools/audit/golden_test.py`                    | Manual diff-debug helper for golden-file regressions.                     |
| `tools/audit/test_analytics.py`                 | Trend-only reporter; consumed by humans, not gates.                       |
| `tools/audit/unit_test_api_coverage.py`         | Niche metric; superset covered by `lua_api_test_coverage.py`.             |
| `tools/audit/parse_test_log.py`                 | Internal helper for `quality_report.py`.                                  |
| `tools/demos/organize_demos.py`                 | One-shot demos folder normaliser, run only when restructuring.            |
| `tools/dev/test_fix_loop.py`                    | Local dev convenience; not part of CI or any agent workflow.              |
| `tools/dist/pack.ps1`, `tools/dist/pack.py`     | Player-facing pack helpers, invoked from VS Code tasks not CAG.           |
| `tools/docs/gen_docs_rust.py`                   | Run via `gen_all_docs.py`; not directly invoked by agents.                |
| `tools/docs/gen_lua_dev_docs.py`                | Subset of `gen_all_docs.py` pipeline.                                     |
| `tools/docs/gen_lua_library_api.py`             | Run via `gen_lib_docs.py`; chained internally.                            |
| `tools/docs/gen_luadoc.py`                      | Chained from `gen_all_docs.py`; produces LuaCATS stubs.                   |
| `tools/docs/gen_rust_api_data.py`               | Chained from `gen_all_docs.py`; produces JSON intermediate.               |
| `tools/docs/gen_test_docs.py`                   | Chained from `gen_all_docs.py`.                                           |
| `tools/docs/gen_wiki.py`                        | Manual wiki-rebuild helper; superseded by `gen_wiki_api.py` for API page. |
| `tools/fix/add_lua_docstrings.py`               | Interactive â€” used by humans, not agents (auto variant is preferred).     |
| `tools/fix/improve_examples.py`                 | Manual content-quality helper.                                            |
| `tools/github/ideas_to_github_issues.py`        | One-shot â€” bulk-imports `ideas/` into Issues; rarely needed.              |
| `tools/mods/mod_init.py`                        | Modder-facing scaffolder; invoked by humans via VS Code task.             |
| `tools/validate/_cag_common.py`                 | Private helper module for CAG validators (not directly callable).         |


