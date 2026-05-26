# Lurek2D Docs Tools

> [!NOTE]
> Ten plik jest generowany automatycznie przez `tools/tests/gen_tool_registry.py`.

- **`collect_docs.py`**: collect_docs.py — Lurek2D rich structured API documentation collector.
- **`gen_docs_lua.py`**: gen_docs_lua.py -- Generate Lua API reference from logs/data/lua_api_data.json.
- **`gen_docs_rust.py`**: gen_docs_rust.py — Generate compact inline Rust API reference from logs/data/rust_api_data.json.
- **`gen_engine_docs.py`**: gen_engine_docs.py — Generate per-module documentation for Lurek2D Rust engine source.
- **`gen_extension_api.py`**: gen_extension_api.py -- Convert logs/data/lua_api_data.json to
- **`gen_lib_docs.py`**: gen_lib_docs.py — Generate API docs from Lurek2D library Lua files.
- **`gen_lua_api.py`**: gen_lua_api.py â€” Lurek2D Lua API parser library.
- **`gen_lua_api_data.py`**: gen_lua_api_data.py — Generate Lurek2D master API data file.
- **`gen_lua_binding_reports.py`**: Generate source-derived Lua binding snapshots from src/lua_api/*.rs.
- **`gen_lua_dev_docs.py`**: gen_lua_dev_docs.py — Generate Lua developer documentation from lua_api *.rs files.
- **`gen_lua_docstring_skeletons.py`**: gen_lua_docstring_skeletons.py -- Rebuild Lua API docstring skeletons from Rust source only.
- **`gen_lua_library_api.py`**: gen_lua_library_api.py — Generate API reference docs from Lurek2D Lua library files.
- **`gen_luadoc.py`**: gen_luadoc.py â€” Generate LuaCATS type-annotation stubs for the Lurek2D VS Code extension.
- **`gen_module_specs.py`**: Generate merged docs/specs/<module>.md files for top-level src modules.
- **`gen_rust_api_data.py`**: gen_rust_api_data.py — Generate Lurek2D master API data file.
- **`gen_rust_docstrings.py`**: gen_rust_docstrings.py — AI-assisted Rust doc-comment generator for src/ (excluding lua_api/).
- **`gen_test_docs.py`**: gen_test_docs.py — Generate human-readable test documentation for Lurek2D.
- **`gen_wiki.py`**: Generate the user-facing GitHub Wiki for Lurek2D.
- **`gen_wiki_api.py`**: gen_wiki_api.py — Generate wiki/API-Reference.md from logs/data/lua_api_data.json.
- **`scan_missing_docs.py`**: scan_missing_docs.py — detect Rust items without doc-comments in src/ (no lua_api).
