# Lurek2D Tools Registry (Auto-generated)

> [!NOTE]
> Ten plik jest generowany automatycznie przez `tools/tests/gen_tool_registry.py`.

## assets

- **`assets/_check_box_slots.py`**: Quick check: verify that atlas slots 0x80-0x9F contain non-zero pixels.
- **`assets/gen_courier_new_bitmap_fonts.py`**: Generate Courier New bitmap font sprite sheets for ASCII 32..255 (Latin-1).

## audit

- **`audit/audit_module.py`**: audit_module.py — Lurek2D module quality audit tool.
- **`audit/cag_coverage.py`**: cag_coverage.py — required-section coverage analytics for CAG files.
- **`audit/cag_link_check.py`**: cag_link_check.py — broken-link checker for the CAG layer.
- **`audit/cag_persona_matrix.py`**: cag_persona_matrix.py — persona ↔ agent value matrix.
- **`audit/count_gaps.py`**: count_gaps.py — Count undocumented public API items per lurek.* module.
- **`audit/doc_audit.py`**: doc_audit.py — Lurek2D unified documentation audit.
- **`audit/doc_coverage.py`**: doc_coverage.py — Lurek2D documentation coverage analytics.
- **`audit/docstring_audit.py`**: docstring_audit.py -- Audit Lurek2D Lua API docstrings for missing content.
- **`audit/example_add_missing.py`**: Append stub sections to content/examples/ for uncovered lurek.* API items.
- **`audit/example_coverage.py`**: Cross-reference Lua example scripts against the lurek.* Lua API.
- **`audit/extract_constructors.py`**: Extract all lurek.module.function signatures from docs/api/lurek.lua
- **`audit/gen_coverage_gaps.py`**: gen_coverage_gaps.py — Generate an API gap report for Lurek2D.
- **`audit/get_api_sigs.py`**: Extract all lurek.* namespace-level function signatures from docs/api/lurek.lua
- **`audit/golden_test.py`**: golden_test.py — Lurek2D golden file comparison tests.
- **`audit/inline_test_audit.py`**: inline_test_audit.py — Enforce TST-02 (no inline `#[cfg(test)]` in src/).
- **`audit/integration_coverage.py`**: integration_coverage.py — Lurek2D integration test coverage analysis.
- **`audit/library_coverage.py`**: library_coverage.py — Audit Lureksome library coverage across three dimensions.
- **`audit/lua_api_test_coverage.py`**: lua_api_test_coverage.py — Precise Lua API test coverage analysis.
- **`audit/lua_covers_lurek_api_audit.py`**: Audit @covers markers against docs/api/lurek.lua.
- **`audit/lua_evidence_golden_contract_audit.py`**: Audit Lua evidence and golden test contract compliance.
- **`audit/lua_spec_coverage.py`**: lua_spec_coverage.py — Measure how completely docs/specs/<module>.md covers the lurek.* Lua API.
- **`audit/lua_test_structure_audit.py`**: Audit and normalize Lua BDD test structure under tests/lua.
- **`audit/mutation_report.py`**: mutation_report.py — run cargo-mutants for selected priority modules.
- **`audit/parse_test_log.py`**: tools/audit/parse_test_log.py — Parse `cargo test` output into a structured summary.
- **`audit/perf_regression_gate.py`**: perf_regression_gate.py — lightweight perf/stress regression gate for CI.
- **`audit/quality_report.py`**: quality_report.py — Lurek2D master quality report.
- **`audit/scan_api_names.py`**: Extract all registered function names from Rust API files.
- **`audit/scan_exact.py`**: Scan specific Rust API files for exact function signatures.
- **`audit/scan_module_fns.py`**: Find module-level constructors (registered on lurek.X table, not on UserData).
- **`audit/scan_sigs.py`**: Find exact function registrations for failing APIs in Rust source files.
- **`audit/stress_report.py`**: stress_report.py — Lurek2D stress test runner and reporter.
- **`audit/strict_api_check.py`**: Validate all lurek.* API stubs in content/examples/ against the master API data.
- **`audit/strict_api_check_math.py`**: Validate math-module API stubs in content/examples/math.lua.
- **`audit/test_analytics.py`**: test_analytics.py — Lurek2D comprehensive test analytics.
- **`audit/test_coverage.py`**: test_coverage.py — Lurek2D test coverage analysis.
- **`audit/thin_modrs_audit.py`**: thin_modrs_audit.py — Enforce TST-04 (thin `mod.rs`).
- **`audit/thin_wrapper_audit.py`**: thin_wrapper_audit.py — Enforce TST-03 (thin wrappers in src/lua_api/).
- **`audit/tool_registry_audit.py`**: Audit the tools registry for internal consistency.
- **`audit/unit_test_api_coverage.py`**: unit_test_api_coverage.py — Lurek2D unit-test API coverage analysis.
- **`audit/wiki_coverage.py`**: Audit wiki page coverage against engine modules and Lua API.

## demos

- **`demos/gen_demo_screenshots.py`**: gen_demo_screenshots.py — Capture a screen.png for every Lurek2D game demo.
- **`demos/gen_game_readmes.py`**: gen_game_readmes.py — Generate or repair README.md files for content/games/ projects.
- **`demos/organize_demos.py`**: organize_demos.py — Three-in-one demos maintenance tool.
- **`demos/smoke_sweep.py`**: Smoke-sweep every playable project under content/games/ and every single-file

## dev

- **`dev/parallel_cargo.py`**: Repository-owned cargo orchestration for build, run, test, lint, fmt, and doc.
- **`dev/test_fix_loop.py`**: tools/scripts/test_fix_loop.py — Agent-friendly test-run / fix / re-run loop.

## dist

- **`dist/pack.py`**: tools/pack.py — Pack a Lurek2D game directory into a .lurek archive.
- **`dist/package_games.py`**: tools/dist/package_games.py — Pack each game into a .lurek archive (ZIP).

## docs

- **`docs/collect_docs.py`**: collect_docs.py — Lurek2D rich structured API documentation collector.
- **`docs/gen_docs_lua.py`**: gen_docs_lua.py -- Generate Lua API reference from logs/data/lua_api_data.json.
- **`docs/gen_docs_rust.py`**: gen_docs_rust.py — Generate compact inline Rust API reference from logs/data/rust_api_data.json.
- **`docs/gen_engine_docs.py`**: gen_engine_docs.py — Generate per-module documentation for Lurek2D Rust engine source.
- **`docs/gen_extension_api.py`**: gen_extension_api.py -- Convert logs/data/lua_api_data.json to
- **`docs/gen_lib_docs.py`**: gen_lib_docs.py — Generate API docs from Lurek2D library Lua files.
- **`docs/gen_lua_api.py`**: gen_lua_api.py â€” Lurek2D Lua API parser library.
- **`docs/gen_lua_api_data.py`**: gen_lua_api_data.py — Generate Lurek2D master API data file.
- **`docs/gen_lua_binding_reports.py`**: Generate source-derived Lua binding snapshots from src/lua_api/*.rs.
- **`docs/gen_lua_dev_docs.py`**: gen_lua_dev_docs.py — Generate Lua developer documentation from lua_api *.rs files.
- **`docs/gen_lua_docstring_skeletons.py`**: gen_lua_docstring_skeletons.py -- Rebuild Lua API docstring skeletons from Rust source only.
- **`docs/gen_lua_library_api.py`**: gen_lua_library_api.py — Generate API reference docs from Lurek2D Lua library files.
- **`docs/gen_luadoc.py`**: gen_luadoc.py â€” Generate LuaCATS type-annotation stubs for the Lurek2D VS Code extension.
- **`docs/gen_module_specs.py`**: Generate merged docs/specs/<module>.md files for top-level src modules.
- **`docs/gen_rust_api_data.py`**: gen_rust_api_data.py — Generate Lurek2D master API data file.
- **`docs/gen_rust_docstrings.py`**: gen_rust_docstrings.py — AI-assisted Rust doc-comment generator for src/ (excluding lua_api/).
- **`docs/gen_test_docs.py`**: gen_test_docs.py — Generate human-readable test documentation for Lurek2D.
- **`docs/gen_wiki.py`**: Generate the user-facing GitHub Wiki for Lurek2D.
- **`docs/gen_wiki_api.py`**: gen_wiki_api.py — Generate wiki/API-Reference.md from logs/data/lua_api_data.json.
- **`docs/scan_missing_docs.py`**: scan_missing_docs.py — detect Rust items without doc-comments in src/ (no lua_api).

## fix

- **`fix/add_lua_docstrings.py`**: add_lua_docstrings.py - Auto-generate /// docstrings from inline comments.
- **`fix/add_lua_docstrings_auto.py`**: add_lua_docstrings_auto.py — Automatically inject /// docstrings above every
- **`fix/add_test_markers.py`**: Add @covers / @stress / @golden / @security markers to Lurek2D Lua test files.
- **`fix/docstring_fix.py`**: docstring_fix.py -- Auto-inject missing @param/@return tags into Lua API docstrings.
- **`fix/expand_examples.py`**: tools/fix/expand_examples.py
- **`fix/fix_param_types.py`**: fix_param_types.py — Auto-fix @param type tags where documented ``number`` should be ``integer``.
- **`fix/format_examples.py`**: tools/fix/format_examples.py
- **`fix/improve_examples.py`**: tools/fix/improve_examples.py
- **`fix/improve_lua_docstrings.py`**: improve_lua_docstrings.py — Rewrites existing thin/incorrect /// docstrings in

## github

- **`github/ideas_to_github_issues.py`**: Create GitHub issues from each markdown file in docs/ideas/.
- **`github/sync_agent_rules.py`**: sync_agent_rules.py — Synchronize workspace rules files with Lurek2D system prompt.

## mods

- **`mods/mod_init.py`**: mod_init.py — Scaffold a minimal Lurek2D mod project.

## root

- **`gen_all_docs.py`**: Convenience runner: regenerate the full Lurek2D documentation pipeline in one command.

## ui

- **`ui/fix_layouts.py`**: Fix Lurek2D TOML layout files.
- **`ui/snap_to_grid.py`**: Snap every pixel-coordinate field in Lurek2D TOML layout files to a grid.

## validate

- **`validate/_cag_common.py`**: Common helpers shared by CAG validator and audit tools.
- **`validate/cag_validate.py`**: cag_validate.py — Lurek2D CAG layer validator.
- **`validate/check_callbacks.py`**: check_callbacks.py — Verify that gen_docs_lua.py _callbacks() output has no embedded newlines.
- **`validate/validate_changelog.py`**: Validate docs/CHANGELOG.md structure and content.
- **`validate/validate_example_coverage.py`**: validate_example_coverage.py — Quality gate for example coverage.
- **`validate/validate_game.py`**: validate_game.py — Validate Lua game scripts against the Lurek2D API surface.
- **`validate/validate_generated_lua_stubs.py`**: Validate committed generated Lua API artifacts against fresh generator output.
- **`validate/validate_library.py`**: Validate Lureksome libraries under content/library/.
- **`validate/validate_lua_api.py`**: validate_lua_api.py -- Validates a Lurek2D lua_api file against the SKILL.md contract.
- **`validate/validate_lua_binding_reports.py`**: Validate docstring bindings against code-derived Lua registration snapshots.
- **`validate/validate_module_coverage.py`**: validate_module_coverage.py
- **`validate/validate_param_types.py`**: validate_param_types.py — Verify that @param type tags match Rust closure type inference.
- **`validate/validate_rust_source_docs.py`**: Validate file-level and public-item Rust documentation under src/.

