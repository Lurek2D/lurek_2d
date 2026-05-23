# Lurek2D Audit Tools

> [!NOTE]
> Ten plik jest generowany automatycznie przez `tools/tests/gen_tool_registry.py`.

- **`audit_module.py`**: audit_module.py — Lurek2D module quality audit tool.
- **`cag_coverage.py`**: cag_coverage.py — required-section coverage analytics for CAG files.
- **`cag_link_check.py`**: cag_link_check.py — broken-link checker for the CAG layer.
- **`cag_persona_matrix.py`**: cag_persona_matrix.py — persona ↔ agent value matrix.
- **`count_gaps.py`**: count_gaps.py — Count undocumented public API items per lurek.* module.
- **`doc_audit.py`**: doc_audit.py — Lurek2D unified documentation audit.
- **`doc_coverage.py`**: doc_coverage.py — Lurek2D documentation coverage analytics.
- **`docstring_audit.py`**: docstring_audit.py -- Audit Lurek2D Lua API docstrings for missing content.
- **`example_add_missing.py`**: Append stub sections to content/examples/ for uncovered lurek.* API items.
- **`example_coverage.py`**: Cross-reference Lua example scripts against the lurek.* Lua API.
- **`extract_constructors.py`**: Extract all lurek.module.function signatures from docs/api/lurek.lua
- **`gen_coverage_gaps.py`**: gen_coverage_gaps.py — Generate an API gap report for Lurek2D.
- **`get_api_sigs.py`**: Extract all lurek.* namespace-level function signatures from docs/api/lurek.lua
- **`golden_test.py`**: golden_test.py — Lurek2D golden file comparison tests.
- **`inline_test_audit.py`**: inline_test_audit.py — Enforce TST-02 (no inline `#[cfg(test)]` in src/).
- **`integration_coverage.py`**: integration_coverage.py — Lurek2D integration test coverage analysis.
- **`library_coverage.py`**: library_coverage.py — Audit Lureksome library coverage across three dimensions.
- **`lua_api_test_coverage.py`**: lua_api_test_coverage.py — Precise Lua API test coverage analysis.
- **`lua_covers_lurek_api_audit.py`**: Audit @covers markers against docs/api/lurek.lua.
- **`lua_evidence_golden_contract_audit.py`**: Audit Lua evidence and golden test contract compliance.
- **`lua_spec_coverage.py`**: lua_spec_coverage.py — Measure how completely docs/specs/<module>.md covers the lurek.* Lua API.
- **`lua_test_structure_audit.py`**: Audit and normalize Lua BDD test structure under tests/lua.
- **`mutation_report.py`**: mutation_report.py — run cargo-mutants for selected priority modules.
- **`parse_test_log.py`**: tools/audit/parse_test_log.py — Parse `cargo test` output into a structured summary.
- **`perf_regression_gate.py`**: perf_regression_gate.py — lightweight perf/stress regression gate for CI.
- **`quality_report.py`**: quality_report.py — Lurek2D master quality report.
- **`scan_api_names.py`**: Extract all registered function names from Rust API files.
- **`scan_exact.py`**: Scan specific Rust API files for exact function signatures.
- **`scan_module_fns.py`**: Find module-level constructors (registered on lurek.X table, not on UserData).
- **`scan_sigs.py`**: Find exact function registrations for failing APIs in Rust source files.
- **`stress_report.py`**: stress_report.py — Lurek2D stress test runner and reporter.
- **`strict_api_check.py`**: Validate all lurek.* API stubs in content/examples/ against the master API data.
- **`strict_api_check_math.py`**: Validate math-module API stubs in content/examples/math.lua.
- **`test_analytics.py`**: test_analytics.py — Lurek2D comprehensive test analytics.
- **`test_coverage.py`**: test_coverage.py — Lurek2D test coverage analysis.
- **`thin_modrs_audit.py`**: thin_modrs_audit.py — Enforce TST-04 (thin `mod.rs`).
- **`thin_wrapper_audit.py`**: thin_wrapper_audit.py — Enforce TST-03 (thin wrappers in src/lua_api/).
- **`tool_registry_audit.py`**: Audit the tools registry for internal consistency.
- **`unit_test_api_coverage.py`**: unit_test_api_coverage.py — Lurek2D unit-test API coverage analysis.
- **`wiki_coverage.py`**: Audit wiki page coverage against engine modules and Lua API.
