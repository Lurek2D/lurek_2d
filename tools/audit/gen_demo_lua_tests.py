#!/usr/bin/env python3
"""Generate tests/lua/demos/test_*.lua from demo_smoke_tests.rs paths."""

from __future__ import annotations

from pathlib import Path

WORKSPACE = Path(__file__).resolve().parent.parent.parent
OUT = WORKSPACE / "tests" / "lua" / "demos"

DEMOS: list[tuple[str, str, str]] = [
    ("test_globe_demo.lua", "globe_demo", "content/games/showcase/globe_demo"),
    ("test_hello_world.lua", "hello_world", "content/games/showcase/hello_world"),
    ("test_sprites.lua", "sprites", "content/games/showcase/sprites"),
    ("test_particles_demo.lua", "particles_demo", "content/games/showcase/particles_demo"),
    ("test_tween_demo.lua", "tween_demo", "content/games/showcase/tween_demo"),
    ("test_scene_demo.lua", "scene_demo", "content/games/showcase/scene_demo"),
    ("test_postfx_demo.lua", "postfx_demo", "content/games/showcase/postfx_demo"),
    ("test_minimap_demo.lua", "minimap_demo", "content/games/showcase/minimap_demo"),
    ("test_light_demo.lua", "light_demo", "content/games/showcase/light_demo"),
    ("test_demo_game.lua", "demo_game", "content/games/showcase/demo_game"),
    ("test_pong.lua", "pong", "content/games/arcade/pong"),
    ("test_snake.lua", "snake", "content/games/arcade/snake"),
    ("test_tetris.lua", "tetris", "content/games/arcade/tetris"),
    ("test_pac_man.lua", "pac_man", "content/games/arcade/pac_man"),
    ("test_asteroids.lua", "asteroids", "content/games/arcade/asteroids"),
    ("test_dyna_blaster.lua", "dyna_blaster", "content/games/arcade/dyna_blaster"),
    ("test_physics_demo.lua", "physics_demo", "content/games/simulation/physics_demo"),
    ("test_physics_sandbox.lua", "physics_sandbox", "content/games/simulation/physics_sandbox"),
    ("test_platformer.lua", "platformer", "content/games/action/platformer"),
    ("test_brick_breaker.lua", "brick_breaker", "content/games/action/brick_breaker"),
    ("test_tower_defense.lua", "tower_defense", "content/games/strategy/tower_defense"),
    ("test_html_hud.lua", "html-hud", "content/games/showcase/html-hud"),
    ("test_html_inventory.lua", "html-inventory", "content/games/showcase/html-inventory"),
    ("test_html_dialog.lua", "html-dialog", "content/games/showcase/html-dialog"),
    (
        "test_html_load_document.lua",
        "html-load-document",
        "content/games/showcase/html-load-document",
    ),
    ("test_html_settings.lua", "html-settings", "content/games/showcase/html-settings"),
    ("test_html_scoreboard.lua", "html-scoreboard", "content/games/showcase/html-scoreboard"),
]

TEMPLATE = """-- Headless contract test for {slug} ({path})
dofile("tests/lua/demos/_common_checks.lua")

-- @describe demo: {slug}
describe("demo: {slug}", function()
    local DEMO = "{path}"

    it("main.lua defines lifecycle callbacks", function()
        demo_check_lifecycle(DEMO)
    end)

    it("conf.toml is valid when present", function()
        demo_check_conf_optional(DEMO)
    end)

    it("main.lua avoids direct window present calls", function()
        demo_check_no_direct_present(DEMO)
    end)
end)

test_summary()
"""


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for fname, slug, path in DEMOS:
        text = TEMPLATE.format(slug=slug, path=path)
        (OUT / fname).write_text(text, encoding="utf-8", newline="\n")
    print(f"[OK] wrote {len(DEMOS)} files to {OUT}")


if __name__ == "__main__":
    main()
