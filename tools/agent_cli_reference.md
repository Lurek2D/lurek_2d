# Agent CLI Reference

Quick entrypoint for repo tools. Start with `tools/python.cmd tools/<path>.py --help`.

## Heuristics

- Use `rag/query.py` before broad file reads.
- Use `audit/` for reports, `validate/` for pass/fail gates, `docs/` for generation, and `fix/` only for controlled rewrites.
- Prefer tools marked `mcp:candidate` when exposing new MCP commands.

## /assets
- `assets/_check_box_slots.py` - Quick check: verify that atlas slots 0x80-0x9F contain non-zero pixels. [durable; mcp:no]
- `assets/gen_courier_new_bitmap_fonts.py` - Generate Courier New bitmap font sprite sheets for ASCII 32..255 (Latin-1). [durable; mcp:no]

## /audit
- `audit/api_occurrence_validator.py` - API Occurrence Validator -- Check that each lurek.* API has examples. [durable; mcp:no]
- `audit/api_stub_validator.py` - API Stub Validator -- Validate pending --@api-stub: block structure and content. [durable; mcp:no]
- `audit/audit_module.py` - audit_module.py Ă˘â‚¬â€ť Lurek2D module quality audit tool. [durable; mcp:no]
- `audit/cag_coverage.py` - cag_coverage.py Ă˘â‚¬â€ť required-section coverage analytics for CAG files. [durable; mcp:no]
- `audit/cag_link_check.py` - cag_link_check.py Ă˘â‚¬â€ť broken-link checker for the CAG layer. [durable; mcp:candidate]
- `audit/cag_persona_matrix.py` - cag_persona_matrix.py Ă˘â‚¬â€ť persona Ă˘â€ â€ť agent value matrix. [durable; mcp:no]
- `audit/count_gaps.py` - count_gaps.py Ă˘â‚¬â€ť Count undocumented public API items per lurek.* module. [durable; mcp:no]
- `audit/doc_audit.py` - doc_audit.py Ă˘â‚¬â€ť Lurek2D unified docs-general audit. [durable; mcp:no]
- `audit/doc_coverage.py` - doc_coverage.py Ă˘â‚¬â€ť Lurek2D docs-general coverage analytics. [durable; mcp:no]
- `audit/docs_quality.py` - Audit docs ownership, generated headers, overlays, coverage data, and dead architecture links. [durable; mcp:no]
- `audit/docstring_audit.py` - docstring_audit.py -- Audit Lurek2D Lua API docstrings for missing content. [durable; mcp:no]
- `audit/docstring_quality_audit.py` - Audit docstring quality - identifies files with poor/unclear module documentation. [durable; mcp:no]
- `audit/example_add_missing.py` - Append stub sections to content/examples/ for uncovered lurek.* API items. [durable; mcp:no]
- `audit/example_coverage.py` - Cross-reference Lua example scripts against the lurek.* Lua API, classify blocks as FULL, PART, TODO, or MISS, and lint standalone marker-owned blocks. [durable; mcp:candidate]
- `audit/extract_constructors.py` - Extract all lurek.module.function signatures from docs/api/lurek.lua [durable; mcp:no]
- `audit/gen_coverage_gaps.py` - gen_coverage_gaps.py Ă˘â‚¬â€ť Generate an API gap report for Lurek2D. [durable; mcp:no]
- `audit/gen_lua_contract_tests.py` - gen_lua_contract_tests.py Ă˘â‚¬â€ť generate Lua contract smoke tests from lua_api_data.json. [durable; mcp:no]
- `audit/get_api_sigs.py` - Extract all lurek.* namespace-level function signatures from docs/api/lurek.lua [durable; mcp:no]
- `audit/golden_test.py` - golden_test.py Ă˘â‚¬â€ť Lurek2D golden file comparison tests. [durable; mcp:no]
- `audit/inline_test_audit.py` - inline_test_audit.py Ă˘â‚¬â€ť Enforce TST-02 (no inline `#[cfg(test)]` in src/). [durable; mcp:no]
- `audit/integration_coverage.py` - integration_coverage.py Ă˘â‚¬â€ť Lurek2D integration test coverage analysis. [durable; mcp:no]
- `audit/library_coverage.py` - library_coverage.py Ă˘â‚¬â€ť Audit Lureksome library coverage across three dimensions. [durable; mcp:candidate]
- `audit/lua_api_test_coverage.py` - lua_api_test_coverage.py Ă˘â‚¬â€ť Precise Lua API test coverage analysis. [durable; mcp:candidate]
- `audit/lua_artifact_lock.py` - Shared lock for Lua artifact maintenance tools. [durable; mcp:no]
- `audit/lua_covers_lurek_api_audit.py` - Audit @covers markers against docs/api/lurek.lua. [durable; mcp:no]
- `audit/lua_evidence_golden_contract_audit.py` - Audit Lua evidence and golden test contract compliance, including rationale blocks and stale evidence markers. [durable; mcp:no]
- `audit/lua_nonunit_test_coverage.py` - lua_nonunit_test_coverage.py - Audit canonical non-unit Lua tests in tests/lua. [durable; mcp:no]
- `audit/lua_spec_coverage.py` - lua_spec_coverage.py Ă˘â‚¬â€ť Measure how completely docs/specs/<module>.md covers the lurek.* Lua API. [durable; mcp:candidate]
- `audit/lua_test_structure_audit.py` - Audit and normalize Lua BDD test structure under tests/lua. [durable; mcp:no]
- `audit/module_docstring_audit.py` - Audit Rust source files for exact file-level //! documentation coverage. [durable; mcp:no]
- `audit/mutation_report.py` - mutation_report.py Ă˘â‚¬â€ť run cargo-mutants for selected priority modules. [durable; mcp:no]
- `audit/parse_test_log.py` - tools/audit/parse_test_log.py Ă˘â‚¬â€ť Parse `cargo test` output into a structured summary. [durable; mcp:no]
- `audit/perf_regression_gate.py` - perf_regression_gate.py Ă˘â‚¬â€ť lightweight perf/stress regression gate for CI. [durable; mcp:no]
- `audit/quality_report.py` - quality_report.py Ă˘â‚¬â€ť Lurek2D master quality report. [durable; mcp:candidate]
- `audit/reseed_lua_artifacts.py` - Rebuild Lua golden baselines from current evidence artifacts. [durable; mcp:no]
- `audit/scan_api_names.py` - Extract all registered function names from Rust API files. [durable; mcp:no]
- `audit/scan_exact.py` - Scan specific Rust API files for exact function signatures. [durable; mcp:no]
- `audit/scan_module_fns.py` - Find module-level constructors (registered on lurek.X table, not on UserData). [durable; mcp:no]
- `audit/scan_sigs.py` - Find exact function registrations for failing APIs in Rust source files. [durable; mcp:no]
- `audit/snippet_coverage.py` - Report snippet coverage per Lua API module based on -- @snippet markers. [durable; mcp:candidate]
- `audit/stress_report.py` - stress_report.py Ă˘â‚¬â€ť Lurek2D stress test runner and reporter. [durable; mcp:no]
- `audit/strict_api_check.py` - Validate fleshed-out lurek.* API examples in content/examples/. [durable; mcp:no]
- `audit/strict_api_check_math.py` - Validate math-module API stubs in content/examples/math.lua. [durable; mcp:no]
- `audit/test_analytics.py` - test_analytics.py Ă˘â‚¬â€ť Lurek2D comprehensive test analytics. [durable; mcp:no]
- `audit/test_coverage.py` - test_coverage.py Ă˘â‚¬â€ť Lurek2D test coverage analysis. [durable; mcp:candidate]
- `audit/thin_modrs_audit.py` - thin_modrs_audit.py Ă˘â‚¬â€ť Enforce TST-04 (thin `mod.rs`). [durable; mcp:no]
- `audit/thin_wrapper_audit.py` - thin_wrapper_audit.py Ă˘â‚¬â€ť Enforce TST-03 (thin wrappers in src/lua_api/). [durable; mcp:no]
- `audit/tool_registry_audit.py` - Audit the single-source tools registry for internal consistency. [durable; mcp:candidate]
- `audit/unit_test_api_coverage.py` - unit_test_api_coverage.py - Lurek2D unit-test API coverage analysis with exact-owner, duplicate-owner, and missing-owner counts. [durable; mcp:no]
- `audit/wiki_coverage.py` - Audit wiki page coverage against engine modules and Lua API. [durable; mcp:no]

## /demos
- `demos/audit_games.py` - Audit content/games readiness and classify legacy folders as catalog, backlog, or migration candidates. [targeted-maintenance; mcp:no]
- `demos/audit_showcase.py` - Inventory and classify example-style entries. [targeted-maintenance; mcp:no]
- `demos/capture_demo_gifs.py` - Create preview.gif files for content/games demos from existing screen.png. [targeted-maintenance; mcp:no]
- `demos/game_catalog.py` - Shared discovery and classification helpers for content/games catalogs, including scale and status extraction. [internal; mcp:no]
- `demos/gen_demo_catalog.py` - Generate the public content/games catalog from audited metadata while keeping backlog out of the README. [targeted-maintenance; mcp:no]
- `demos/gen_demo_screenshots.py` - gen_demo_screenshots.py Ă˘â‚¬â€ť Capture a screen.png for every Lurek2D game demo. [targeted-maintenance; mcp:no]
- `demos/gen_game_readmes.py` - gen_game_readmes.py Ă˘â‚¬â€ť Generate or repair README.md files for content/games/ projects. [targeted-maintenance; mcp:no]
- `demos/migrate_game_shelves.py` - Move non-public game catalog entries into explicit holding shelves. [targeted-maintenance; mcp:no]
- `demos/organize_demos.py` - organize_demos.py Ă˘â‚¬â€ť Three-in-one demos maintenance tool. [targeted-maintenance; mcp:no]
- `demos/smoke_sweep.py` - Smoke-sweep every playable project under content/games/ and every single-file [targeted-maintenance; mcp:no]

## /dev
- `dev/headroom_runtime.py` - Manage a repo-local Headroom runtime for Codex and MCP workflows. [developer-workflow; mcp:no]
- `dev/parallel_cargo.py` - Repository-owned cargo orchestration for build, run, test, lint, fmt, and doc. [developer-workflow; mcp:no]
- `dev/test_fix_loop.py` - Agent-friendly test-run / fix / re-run loop for cargo test. [developer-workflow; mcp:no]

## /dist
- `dist/pack.py` - tools/pack.py Ă˘â‚¬â€ť Pack a Lurek2D game directory into a .lurek archive. [durable; mcp:no]
- `dist/package_games.py` - tools/dist/package_games.py Ă˘â‚¬â€ť Pack each game into a .lurek archive (ZIP). [durable; mcp:no]

## /docs
- `docs/collect_docs.py` - collect_docs.py Ă˘â‚¬â€ť Lurek2D rich structured API docs-general collector. [durable; mcp:no]
- `docs/check_freshness.py` - Regenerate docs and fail if generated outputs are stale. [durable; mcp:no]
- `docs/gen_evidence_manifest.py` - Generate build/docs-data/evidence_manifest.json for module specs. [durable; mcp:no]
- `docs/gen_docs_lua.py` - gen_docs_lua.py -- Generate Lua API reference from logs/data/lua_api_data.json. [durable; mcp:no]
- `docs/gen_docs_lua_html.py` - Generate compatibility redirects for legacy ``/lua-docs`` URLs. [durable; mcp:no]
- `docs/gen_docs_rust.py` - gen_docs_rust.py Ă˘â‚¬â€ť Generate compact inline Rust API reference from logs/data/rust_api_data.json. [durable; mcp:no]
- `docs/gen_engine_docs.py` - gen_engine_docs.py Ă˘â‚¬â€ť Generate per-module docs-general for Lurek2D Rust engine source. [durable; mcp:no]
- `docs/gen_extension_api.py` - gen_extension_api.py -- Convert logs/data/lua_api_data.json to [durable; mcp:no]
- `docs/gen_lib_docs.py` - gen_lib_docs.py Ă˘â‚¬â€ť Generate API docs from Lurek2D library Lua files. [durable; mcp:no]
- `docs/gen_lua_api.py` - gen_lua_api.py Ä‚ËĂ˘â€šÂ¬Ă˘â‚¬ĹĄ Lurek2D Lua API parser library. [durable; mcp:no]
- `docs/gen_lua_api_data.py` - gen_lua_api_data.py Ă˘â‚¬â€ť Generate Lurek2D master API data file. [durable; mcp:no]
- `docs/gen_lua_api_html_wrapper.py` - gen_lua_api_html_wrapper.py Ă˘â‚¬â€ť Generate HTML index wrapper for Lua API docs-general in pages/lua-docs/. [durable; mcp:no]
- `docs/gen_lua_binding_reports.py` - Generate source-derived Lua binding snapshots from src/lua_api/*.rs. [durable; mcp:no]
- `docs/gen_lua_dev_docs.py` - gen_lua_dev_docs.py Ă˘â‚¬â€ť Generate Lua developer docs-general from lua_api *.rs files. [durable; mcp:no]
- `docs/gen_lua_docstring_skeletons.py` - gen_lua_docstring_skeletons.py -- Rebuild Lua API docstring skeletons from Rust source only. [durable; mcp:no]
- `docs/gen_lua_library_api.py` - gen_lua_library_api.py Ă˘â‚¬â€ť Generate API reference docs from Lurek2D Lua library files. [durable; mcp:no]
- `docs/gen_luadoc.py` - gen_luadoc.py Ä‚ËĂ˘â€šÂ¬Ă˘â‚¬ĹĄ Generate LuaCATS type-annotation stubs for the Lurek2D VS Code extension. [durable; mcp:no]
- `docs/gen_module_pages.py` - Generate per-module MkDocs pages in docs/modules/ from: [durable; mcp:no]
- `docs/gen_module_specs.py` - Generate docs/specs/<module>.md from source facts and manual overlays. [durable; mcp:no]
- `docs/migrate_spec_manual_overlays.py` - Migrate hand-written spec sections into docs/specs/manual overlays. [targeted-maintenance; mcp:no]
- `docs/module_registry.py` - Load and inspect docs/meta/modules.toml module metadata. [durable; mcp:no]
- `docs/gen_rust_api_data.py` - gen_rust_api_data.py Ă˘â‚¬â€ť Generate Lurek2D master API data file. [durable; mcp:no]
- `docs/gen_rust_docstrings.py` - gen_rust_docstrings.py Ă˘â‚¬â€ť AI-assisted Rust doc-comment generator for src/ (excluding lua_api/). [durable; mcp:no]
- `docs/gen_test_docs.py` - gen_test_docs.py Ă˘â‚¬â€ť Generate human-readable test docs-general for Lurek2D. [durable; mcp:no]
- `docs/gen_wiki.py` - Generate the user-facing GitHub Wiki for Lurek2D. [durable; mcp:no]
- `docs/gen_wiki_api.py` - gen_wiki_api.py Ă˘â‚¬â€ť Generate wiki/API-Reference.md from logs/data/lua_api_data.json. [durable; mcp:no]
- `docs/scan_missing_docs.py` - scan_missing_docs.py Ă˘â‚¬â€ť detect Rust items without doc-comments in src/ (no lua_api). [durable; mcp:no]

## /fix
- `fix/add_lua_docstrings.py` - add_lua_docstrings.py - Auto-generate /// docstrings from inline comments. [targeted-maintenance; mcp:no]
- `fix/add_lua_docstrings_auto.py` - add_lua_docstrings_auto.py Ă˘â‚¬â€ť Automatically inject /// docstrings above every [targeted-maintenance; mcp:no]
- `fix/add_test_markers.py` - Add @covers / @stress / @golden / @security markers to Lurek2D Lua test files. [targeted-maintenance; mcp:no]
- `fix/docstring_fix.py` - docstring_fix.py -- Auto-inject missing @param/@return tags into Lua API docstrings. [targeted-maintenance; mcp:no]
- `fix/expand_examples.py` - tools/fix/expand_examples.py [targeted-maintenance; mcp:no]
- `fix/fix_file_docstrings.py` - Fix file-level //! docstrings to meet size and length requirements. [targeted-maintenance; mcp:no]
- `fix/fix_param_types.py` - fix_param_types.py Ă˘â‚¬â€ť Auto-fix @param type tags where documented ``number`` should be ``integer``. [targeted-maintenance; mcp:no]
- `fix/format_examples.py` - tools/fix/format_examples.py [targeted-maintenance; mcp:no]
- `fix/improve_examples.py` - tools/fix/improve_examples.py [targeted-maintenance; mcp:no]
- `fix/improve_lua_docstrings.py` - improve_lua_docstrings.py Ă˘â‚¬â€ť Rewrites existing thin/incorrect /// docstrings in [targeted-maintenance; mcp:no]
- `fix/module_docstring_fix.py` - Apply manually authored Rust file-level //! docs from a manifest. [targeted-maintenance; mcp:no]
- `fix/spec_docstring_apply.py` - Deprecated one-time migration helper; default docs flow is source docstrings -> generated specs. [targeted-maintenance; mcp:no]
- `fix/strip_garbage_doc_lines.py` - strip_garbage_doc_lines.py -- Remove auto-generated garbage lines from //! docstrings. [targeted-maintenance; mcp:no]

## /github
- `github/ideas_to_github_issues.py` - Create GitHub issues from each markdown file in docs/ideas/. [targeted-maintenance; mcp:no]
- `github/sync_agent_rules.py` - sync_agent_rules.py Ă˘â‚¬â€ť Synchronize workspace rules files with Lurek2D system prompt. [targeted-maintenance; mcp:no]

## /mcp
- `mcp/lurek_mcp_server.py` - Expose Lurek2D RAG and repo quality audits as a minimal stdio MCP server. [durable; mcp:server]

## /mods
- `mods/mod_init.py` - mod_init.py Ă˘â‚¬â€ť Scaffold a minimal Lurek2D mod project. [durable; mcp:no]

## /rag
- `rag/build_index.py` - Build the local DuckDB RAG index for Lurek2D docs, code, tests, and Codex assets. [durable; mcp:no]
- `rag/context.py` - Build an agent-friendly context bundle from the local Lurek2D RAG index. [durable; mcp:no]
- `rag/contract.py` - Shared RAG contract constants loaded from ``rag_contract.json``. [durable; mcp:no]
- `rag/eval.py` - Evaluate local RAG recall against a prompt baseline for agent workflows. [durable; mcp:no]
- `rag/insights.py` - Run SQL insights and audits over the local DuckDB RAG index. [durable; mcp:no]
- `rag/query.py` - Query and read the local DuckDB RAG index for Lurek2D. [durable; mcp:candidate]
- `rag/read.py` - Read full chunks from the local Lurek2D RAG index by chunk id. [durable; mcp:no]

## /root
- `fix_remaining_markers.py` - Add missing @covers markers to specific it() blocks. [targeted-maintenance; mcp:no]
- `fix_test_markers.py` - Add missing @covers markers to it() blocks in Lua tests. [targeted-maintenance; mcp:no]
- `fix_test_structure.py` - Fix Lua test structure violations. [targeted-maintenance; mcp:no]
- `fix_wrapped_tests.py` - Add missing @covers markers to wrapped test functions. [targeted-maintenance; mcp:no]
- `gen_all_docs.py` - Convenience runner: regenerate the full Lurek2D documentation pipeline in one command. [durable; mcp:no]

## /snippets
- `snippets/gen_vscode_snippets.py` - Build extension/vscode/data/snippets.json from content/snippets/*.lua. [durable; mcp:no]
- `snippets/snippet_catalog.py` - Shared parser for content/snippets/*.lua marker blocks. [internal; mcp:no]

## /ui
- `ui/fix_layouts.py` - Fix Lurek2D TOML layout files. [durable; mcp:no]
- `ui/snap_to_grid.py` - Snap every pixel-coordinate field in Lurek2D TOML layout files to a grid. [durable; mcp:no]

## /validate
- `validate/_cag_common.py` - Common helpers shared by CAG validator and audit tools. [internal; mcp:no]
- `validate/cag_validate.py` - cag_validate.py Ă˘â‚¬â€ť Lurek2D CAG layer validator. [durable; mcp:candidate]
- `validate/check_callbacks.py` - check_callbacks.py Ă˘â‚¬â€ť Verify that gen_docs_lua.py _callbacks() output has no embedded newlines. [durable; mcp:no]
- `validate/cleanup_prompt_catalog.py` - Remove deprecated prompts and rename remaining create-oriented prompts. [durable; mcp:no]
- `validate/prompt_scope_report.py` - Report active prompt scope and flag deprecated analysis-style prompts. [durable; mcp:no]
- `validate/validate_changelog.py` - Validate docs/CHANGELOG.md structure and content. [durable; mcp:no]
- `validate/validate_example_coverage.py` - validate_example_coverage.py Ă˘â‚¬â€ť Quality gate for example coverage. [durable; mcp:candidate]
- `validate/validate_game.py` - validate_game.py Ă˘â‚¬â€ť Validate Lua game scripts against the Lurek2D API surface. [durable; mcp:candidate]
- `validate/validate_generated_lua_stubs.py` - Validate committed generated Lua API artifacts against fresh generator output. [durable; mcp:no]
- `validate/validate_library.py` - Validate Lureksome libraries under content/library/. [durable; mcp:candidate]
- `validate/validate_lua_api.py` - validate_lua_api.py -- Validates a Lurek2D lua_api file against the SKILL.md contract. [durable; mcp:no]
- `validate/validate_lua_binding_reports.py` - Validate docstring bindings against code-derived Lua registration snapshots. [durable; mcp:candidate]
- `validate/validate_module_coverage.py` - Validate top-level module/spec coverage. [durable; mcp:candidate]
- `validate/validate_param_types.py` - validate_param_types.py Ă˘â‚¬â€ť Verify that @param type tags match Rust closure type inference. [durable; mcp:candidate]
- `validate/validate_rust_file_docs.py` - Validate Rust file-level //! docs with the repository docstring coverage policy. [durable; mcp:no]
- `validate/validate_rust_source_docs.py` - Validate file-level and public-item Rust docs-general under src/. [durable; mcp:no]
- `validate/validate_snippets.py` - Validate content/snippets marker structure and VS Code snippet output freshness. [durable; mcp:candidate]
