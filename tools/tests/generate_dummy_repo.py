import os
import shutil
from pathlib import Path

def generate_dummy_repo():
    root = Path(__file__).resolve().parent / "dummy_data"
    
    # Remove old dummy_data if exists
    if root.exists():
        shutil.rmtree(root)
    root.mkdir(parents=True)

    # 1. Rust Source files (already have some, let's regenerate them)
    src_dir = root / "src"
    src_dir.mkdir()
    (src_dir / "good.rs").write_text(
        "//! This is a good file with a module level header.\n//! It contains enough characters to pass the validation script.\n\n"
        "/// This is a summary line that has at least 25 characters.\n"
        "pub fn valid_function() {}\n\n"
        "/// This is a summary line that has at least 25 characters.\n"
        "pub struct ValidStruct;\n", encoding="utf-8"
    )
    (src_dir / "bad_no_header.rs").write_text(
        "/// This is a summary line that has at least 25 characters.\n"
        "pub fn another_function() {}\n", encoding="utf-8"
    )
    (src_dir / "bad_short_summary.rs").write_text(
        "//! Module level header that is perfectly fine.\n\n"
        "/// Too short summary\n"
        "pub fn short_summary_function() {}\n", encoding="utf-8"
    )
    (src_dir / "bad_no_summary.rs").write_text(
        "//! Module level header that is perfectly fine.\n\n"
        "pub fn no_summary_function() {}\n", encoding="utf-8"
    )

    lua_api_dir = src_dir / "lua_api"
    lua_api_dir.mkdir()
    (lua_api_dir / "dummy_api.rs").write_text(
        "//! Dummy API bindings\n"
        "/// A dummy lua binding summary with enough characters.\n"
        "pub struct DummyApi;\n", encoding="utf-8"
    )

    # 2. Lua Examples
    examples_dir = root / "content" / "examples"
    examples_dir.mkdir(parents=True)
    (examples_dir / "example.lua").write_text(
        "--@api-stub: lurek.dummy.test\n"
        "do\n"
        "  print('dummy example')\n"
        "end\n", encoding="utf-8"
    )

    # 3. Games
    games_dir = root / "content" / "games" / "dummy_game"
    games_dir.mkdir(parents=True)
    (games_dir / "main.lua").write_text("print('game')\n", encoding="utf-8")
    (games_dir / "conf.lua").write_text("function lurek.conf(t)\n  t.window.title = 'Dummy Game'\nend\n", encoding="utf-8")
    (games_dir / "README.md").write_text("# Dummy Game\n\nDummy game description.\n", encoding="utf-8")

    # 4. Layouts
    layouts_dir = root / "content" / "layouts"
    layouts_dir.mkdir(parents=True)
    (layouts_dir / "main_menu.layout.toml").write_text("[layout]\nwidth = 800\nheight = 600\n", encoding="utf-8")

    # 5. Libraries
    lib_dir = root / "library" / "dummy_lib"
    lib_dir.mkdir(parents=True)
    (lib_dir / "init.lua").write_text("-- Module description here\nlocal dummy = {}\nreturn dummy\n", encoding="utf-8")
    (lib_dir / "example.lua").write_text("local d = require('dummy_lib')\n", encoding="utf-8")

    # 6. Tests Lua
    tests_lua_dir = root / "tests" / "lua"
    tests_lua_dir.mkdir(parents=True)
    (tests_lua_dir / "test_dummy.lua").write_text(
        "-- @covers: lurek.dummy.test\n"
        "local test = require('test_harness')\n", encoding="utf-8"
    )

    # 7. GitHub CAG Files
    agents_dir = root / ".github" / "agents"
    agents_dir.mkdir(parents=True)
    (agents_dir / "dummy.agent.md").write_text(
        "---\nname: Dummy Agent\ndescription: Dummy description.\n---\n# Dummy\n", encoding="utf-8"
    )
    skills_dir = root / ".github" / "skills" / "dummy_skill"
    skills_dir.mkdir(parents=True)
    (skills_dir / "SKILL.md").write_text("# Dummy Skill\n", encoding="utf-8")

    # 8. Docs Changelog
    docs_dir = root / "docs"
    docs_dir.mkdir(parents=True)
    (docs_dir / "CHANGELOG.md").write_text(
        "# Changelog\nAll notable changes to this project will be documented in this file.\n"
        "\n## [1.0.0] - 2026-01-01\n- Added dummy feature.\n", encoding="utf-8"
    )

    print(f"Generated dummy repository structure at {root}")

if __name__ == "__main__":
    generate_dummy_repo()
