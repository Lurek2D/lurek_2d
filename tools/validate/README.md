# Lurek2D Validate Tools

> [!NOTE]
> Ten plik jest generowany automatycznie przez `tools/tests/gen_tool_registry.py`.

- **`_cag_common.py`**: Common helpers shared by CAG validator and audit tools.
- **`cag_validate.py`**: cag_validate.py — Lurek2D CAG layer validator.
- **`check_callbacks.py`**: check_callbacks.py — Verify that gen_docs_lua.py _callbacks() output has no embedded newlines.
- **`validate_changelog.py`**: Validate docs/CHANGELOG.md structure and content.
- **`validate_example_coverage.py`**: validate_example_coverage.py — Quality gate for example coverage.
- **`validate_game.py`**: validate_game.py — Validate Lua game scripts against the Lurek2D API surface.
- **`validate_generated_lua_stubs.py`**: Validate committed generated Lua API artifacts against fresh generator output.
- **`validate_library.py`**: Validate Lureksome libraries under content/library/.
- **`validate_lua_api.py`**: validate_lua_api.py -- Validates a Lurek2D lua_api file against the SKILL.md contract.
- **`validate_lua_binding_reports.py`**: Validate docstring bindings against code-derived Lua registration snapshots.
- **`validate_module_coverage.py`**: validate_module_coverage.py
- **`validate_param_types.py`**: validate_param_types.py — Verify that @param type tags match Rust closure type inference.
- **`validate_rust_source_docs.py`**: Validate file-level and public-item Rust documentation under src/.
- **`validate_snippets.py`**: Validate content/snippets marker structure and VS Code snippet output freshness.
