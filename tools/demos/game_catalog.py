#!/usr/bin/env python3
"""Shared discovery and classification helpers for content/games catalogs."""

from __future__ import annotations

import re
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_GAMES_ROOT = REPO_ROOT / "content" / "games"

CATEGORY_ORDER = [
    "arcade",
    "action",
    "rpg",
    "strategy",
    "simulation",
    "sports",
    "apps",
    "puzzle",
    "retro",
    "showcase",
    "test",
]

PUBLIC_DECISIONS = {"KEEP", "REWRITE_API", "TRIM"}
NON_PUBLIC_DECISIONS = {"MOVE_EXAMPLE", "MOVE_INCUBATOR", "MERGE_OR_DROP", "DROP_OR_IDEA"}

TITLE_OVERRIDES = {
    "arcade/tetris": "Falling Blocks",
    "arcade/pac_man": "Maze Chase",
}

DECISION_DESCRIPTIONS = {
    "KEEP": "Catalog candidate after metadata, preview, validation, and smoke evidence are current.",
    "REWRITE_API": "Keep the concept, but rewrite around current idiomatic lurek.* APIs.",
    "TRIM": "Keep only a small playable vertical slice.",
    "MOVE_EXAMPLE": "Move to content/examples or a showcase/example shelf.",
    "MOVE_INCUBATOR": "Move to an incubator until it is implemented and smoke-testable.",
    "MERGE_OR_DROP": "Resolve duplicate ownership, then keep one clear public demo or drop the duplicate.",
    "DROP_OR_IDEA": "Move to ideas or drop from maintained demo content.",
    "REVIEW": "Not covered by issue #30; needs manual classification.",
}

# Product decisions copied from https://github.com/Lurek2D/lurek_2d/issues/30.
# Keys are content/games/<category>/<name> without the content/games prefix.
GAME_DECISIONS: dict[str, tuple[str, str]] = {
    # action
    "action/brick_breaker": ("KEEP", "Refresh README, screen, GIF, and smoke evidence."),
    "action/bullet_hell": ("KEEP", "Strong action demo using input/render/particle/ui."),
    "action/cannon_fodder": ("KEEP", "Resolved duplicate owner; keep as the public tactical action variant."),
    "action/cinematic_chase": ("MOVE_INCUBATOR", "Skeleton; do not promote as a ready demo."),
    "action/endless_runner": ("KEEP", "Small arcade loop demo."),
    "action/fighting_game": ("TRIM", "Keep a small 1v1 vertical slice."),
    "action/horde_survivor": ("KEEP", "Good enemy spawning, auto-fire, particles, and camera demo."),
    "action/infiltration": ("KEEP", "Stealth-puzzle mini game."),
    "action/metroidvania": ("REWRITE_API", "Rewrite around tilemap/camera/input/scene idioms."),
    "action/platform_fighter": ("TRIM", "Keep as simple local multiplayer demo."),
    "action/platformer": ("REWRITE_API", "Original platformer showing tilemap, collision, camera, and audio."),
    "action/roguelite": ("TRIM", "Keep a five-room vertical slice."),
    "action/sniper": ("KEEP", "Small ballistics puzzle game."),
    "action/soulslike": ("TRIM", "Keep a boss-fight vertical slice."),
    "action/spine_boss_arena": ("MOVE_INCUBATOR", "Skeleton pending real spine/animation demo."),
    "action/stealth": ("KEEP", "Top-down stealth demo."),
    "action/stealth_ops": ("REWRITE_API", "Confirm declared ai/pathfind/light/tilemap/visibility APIs are real and stable."),
    "action/vertical_climber": ("KEEP", "Small arcade climbing demo."),

    # apps
    "apps/audio_composer": ("MOVE_INCUBATOR", "Skeleton pending real audio/dsp/midi API demo."),
    "apps/household_finance_lab": ("TRIM", "Trim to a dashboard app demo or move to an apps lab."),
    "apps/html_ui_suite": ("MOVE_INCUBATOR", "Skeleton; HTML examples belong in showcase/examples until complete."),
    "apps/image_workbench": ("MOVE_INCUBATOR", "Skeleton pending real compute/image workflow."),
    "apps/learning_lab": ("MOVE_INCUBATOR", "Skeleton; not a complete app demo."),
    "apps/learning_route_attention_lab": ("KEEP", "Small data app demo."),
    "apps/learning_sales_forecast_lab": ("KEEP", "Small lurek.learning data app demo."),
    "apps/localization_dialog_studio": ("MOVE_INCUBATOR", "Skeleton narrative tooling concept."),
    "apps/mod_manager_lab": ("MOVE_INCUBATOR", "Skeleton mod tooling idea."),
    "apps/network_sync_lab": ("MOVE_INCUBATOR", "Skeleton pending network/thread demo."),

    # arcade
    "arcade/asteroids": ("KEEP", "Flagship arcade demo candidate."),
    "arcade/centipede": ("KEEP", "Classic arcade shooter."),
    "arcade/donkey_kong": ("REWRITE_API", "Rewrite as an original platform climber, not an IP clone."),
    "arcade/dyna_blaster": ("KEEP", "Bomber-grid demo; verify scene/ui use."),
    "arcade/frogger": ("KEEP", "Small complete arcade demo."),
    "arcade/galaga": ("REWRITE_API", "Check API compatibility and simplify to a clear pattern."),
    "arcade/network_duel": ("MOVE_INCUBATOR", "Skeleton multiplayer until network API is stable."),
    "arcade/pac_man": ("KEEP", "Rewritten as an original maze-chase demo with local BFS hunter AI."),
    "arcade/pong": ("KEEP", "Beginner reference classic."),
    "arcade/snake": ("KEEP", "Beginner reference classic."),
    "arcade/space_invaders": ("KEEP", "Arcade shooter demo."),
    "arcade/tetris": ("KEEP", "Rewritten as an original falling-block puzzle on current lurek.* APIs."),

    # puzzle
    "puzzle/mapblock_labyrinth": ("KEEP", "Logic/tile puzzle after smoke and preview."),

    # retro
    "retro/another_world": ("TRIM", "Keep as cinematic/platformer API slice, not an IP clone."),
    "retro/boulder_dash": ("REWRITE_API", "Rewrite as original cave-digging demo."),
    "retro/cannon_fodder": ("MOVE_INCUBATOR", "Resolved duplicate; action/cannon_fodder is the public owner."),
    "retro/commando": ("KEEP", "Top-down shooter demo."),
    "retro/dungeon_crawler": ("REWRITE_API", "Rewrite as clear raycast/tilemap/ui vertical slice."),
    "retro/giana_sisters": ("REWRITE_API", "Rewrite as original platformer or merge with action/platformer."),
    "retro/lemmings": ("TRIM", "Keep a small puzzle-command slice."),
    "retro/paradroid": ("TRIM", "Keep a small infiltration/hacking vertical slice."),
    "retro/raycaster_fps": ("KEEP", "Good unusual 2D-runtime rendering demo if working."),
    "retro/sensible_soccer": ("MOVE_INCUBATOR", "Resolved duplicate; sports/sensible_soccer is the public owner."),
    "retro/shadow_beast": ("TRIM", "Keep as limited visual/platformer showcase."),
    "retro/turrican": ("TRIM", "Keep action-platformer slice or merge with platformer/metroidvania."),

    # rpg
    "rpg/adventure": ("KEEP", "Small RPG/adventure after validation."),
    "rpg/alchemy": ("KEEP", "Systems demo."),
    "rpg/courtroom": ("KEEP", "UI/dialog app-game hybrid."),
    "rpg/creature_collector": ("TRIM", "Keep battle/collection mini loop."),
    "rpg/dialog_demo": ("MOVE_EXAMPLE", "Dialog API showcase rather than a complete game."),
    "rpg/dungeon_eye": ("KEEP", "Dungeon/RPG slice."),
    "rpg/horror": ("TRIM", "Keep a small atmospheric demo."),
    "rpg/loot_rpg": ("KEEP", "Reference RPG loop."),
    "rpg/loot_rpg_demo": ("MOVE_INCUBATOR", "Resolved duplicate; rpg/loot_rpg is the public owner."),
    "rpg/merchant": ("KEEP", "Economy/RPG app-like demo."),
    "rpg/merchant_demo": ("MOVE_INCUBATOR", "Resolved duplicate; rpg/merchant is the public owner."),
    "rpg/modded_arena": ("REWRITE_API", "Keep only if it really demonstrates modding."),
    "rpg/mystery_case": ("KEEP", "Narrative/UI demo."),
    "rpg/raycaster_dungeon": ("KEEP", "Rendering/dungeon slice."),
    "rpg/roguelike": ("KEEP", "Procedural/grid demo."),
    "rpg/social_deduction": ("TRIM", "Small local simulation slice or incubator."),
    "rpg/star_voyage": ("TRIM", "Small exploration/trading slice."),
    "rpg/survival_crafting": ("TRIM", "Small crafting loop."),
    "rpg/visual_novel": ("KEEP", "UI/dialog/localization demo if complete."),

    # showcase
    "showcase/agent_pipeline_demo": ("MOVE_EXAMPLE", "Feature showcase, not a game."),
    "showcase/automation_demo": ("MOVE_EXAMPLE", "API example/showcase."),
    "showcase/automation_replay_lab": ("MOVE_EXAMPLE", "API lab, not a complete game."),
    "showcase/debugbridge_demo": ("MOVE_EXAMPLE", "Devtool showcase."),
    "showcase/demo_game": ("KEEP", "Keep if playable; otherwise move to examples."),
    "showcase/devtools_demo": ("MOVE_EXAMPLE", "Devtool/API showcase."),
    "showcase/docs_demo": ("MOVE_EXAMPLE", "Docs/API demo."),
    "showcase/entity_showcase": ("MOVE_EXAMPLE", "Feature showcase."),
    "showcase/globe_demo": ("KEEP", "Complete interactive app/showcase exception."),
    "showcase/hacking_game": ("KEEP", "Small playable game if complete."),
    "showcase/hello_world": ("MOVE_EXAMPLE", "Beginner example."),
    "showcase/html-dialog": ("MOVE_EXAMPLE", "HTML UI example."),
    "showcase/html-hud": ("MOVE_EXAMPLE", "HTML UI example."),
    "showcase/html-inventory": ("MOVE_EXAMPLE", "HTML UI example."),
    "showcase/html-load-document": ("MOVE_EXAMPLE", "HTML UI example."),
    "showcase/html-scoreboard": ("MOVE_EXAMPLE", "HTML UI example."),
    "showcase/html-settings": ("MOVE_EXAMPLE", "HTML UI example."),
    "showcase/light_demo": ("MOVE_EXAMPLE", "Feature showcase."),
    "showcase/light_showcase": ("MOVE_EXAMPLE", "Feature showcase."),
    "showcase/localization_demo": ("MOVE_EXAMPLE", "i18n example."),
    "showcase/minimap_demo": ("MOVE_EXAMPLE", "Feature showcase unless embedded into a complete game."),
    "showcase/modding_demo": ("MOVE_EXAMPLE", "Feature showcase unless rebuilt as rpg/modded_arena."),
    "showcase/music_composer": ("MOVE_INCUBATOR", "Large unfinished app; incubator/apps lab."),
    "showcase/nine_slice_demo": ("MOVE_EXAMPLE", "UI rendering example."),
    "showcase/overlay_demo": ("MOVE_EXAMPLE", "UI/render example."),
    "showcase/particles_demo": ("MOVE_EXAMPLE", "Particle API example."),
    "showcase/patterns_demo": ("MOVE_EXAMPLE", "Rendering/patterns example."),
    "showcase/pipeline_showcase": ("MOVE_EXAMPLE", "Pipeline feature showcase."),
    "showcase/postfx_demo": ("MOVE_EXAMPLE", "PostFX example."),
    "showcase/province_demo": ("MOVE_EXAMPLE", "Globe/province API example unless app-like."),
    "showcase/scene_demo": ("MOVE_EXAMPLE", "Scene API example."),
    "showcase/signal_demo": ("MOVE_EXAMPLE", "Signal API example."),
    "showcase/sprites": ("MOVE_EXAMPLE", "Sprite/image feature example."),
    "showcase/svg_provinces": ("MOVE_EXAMPLE", "Data/render showcase."),
    "showcase/terminal_demo": ("MOVE_EXAMPLE", "Terminal API example."),
    "showcase/terminal_dev_console": ("MOVE_EXAMPLE", "Dev console example."),
    "showcase/tween_demo": ("MOVE_EXAMPLE", "Tween API example."),
    "showcase/vending_lights": ("MOVE_EXAMPLE", "Light/UI showcase."),
    "showcase/visual_fx_lab": ("MOVE_EXAMPLE", "FX showcase."),

    # simulation
    "simulation/colony_sim": ("TRIM", "Keep a small colony loop."),
    "simulation/cooking_sim": ("KEEP", "Simple simulation loop demo."),
    "simulation/deep_cave_rescue": ("KEEP", "Exploration/sim demo."),
    "simulation/factory": ("KEEP", "Systems demo with controlled scope."),
    "simulation/farming_sim": ("TRIM", "Keep a small crop loop."),
    "simulation/god_game": ("TRIM", "Keep a small sandbox."),
    "simulation/hotel_manager": ("TRIM", "App/sim vertical slice."),
    "simulation/idle_game": ("KEEP", "Minimal systems/UI demo."),
    "simulation/medical_sim": ("TRIM", "Small triage sim or incubator."),
    "simulation/mining": ("KEEP", "Resource loop demo."),
    "simulation/physics_demo": ("MOVE_EXAMPLE", "Physics API example, not a game."),
    "simulation/physics_sandbox": ("MOVE_EXAMPLE", "Sandbox/API showcase."),
    "simulation/province_economy_demo": ("MOVE_EXAMPLE", "Globe/economy API showcase or app lab."),
    "simulation/rail_flow_tycoon": ("TRIM", "Small logistics slice."),
    "simulation/railroad": ("TRIM", "Resolve with rail_flow_tycoon."),
    "simulation/settlers_rise": ("TRIM", "Small settlement loop."),
    "simulation/tower_sim": ("TRIM", "Small management loop."),
    "simulation/tycoon": ("TRIM", "Specific mini-tycoon or drop."),
    "simulation/vehicle_builder": ("TRIM", "Controlled builder demo."),
    "simulation/wildlife_photo": ("KEEP", "Small unusual game."),
    "simulation/zoo_tycoon": ("TRIM", "Small enclosure/economy loop."),

    # sports
    "sports/boxing_ring": ("KEEP", "Small sports/fighting slice."),
    "sports/drift_racing": ("KEEP", "Physics/input demo if playable."),
    "sports/fishing": ("KEEP", "Slow-game demo."),
    "sports/golf_classic": ("KEEP", "Physics trajectory demo."),
    "sports/physics_arena": ("MOVE_EXAMPLE", "Sandbox unless it is a full game."),
    "sports/pinball": ("KEEP", "Physics demo as a game."),
    "sports/rhythm_game": ("KEEP", "Audio/input timing demo."),
    "sports/sensible_soccer": ("REWRITE_API", "Original soccer demo; merge retro duplicate."),
    "sports/ski_jump": ("KEEP", "Small sports game."),
    "sports/sports_manager": ("TRIM", "Small manager loop."),
    "sports/tennis_classic": ("KEEP", "Small sports arcade."),
    "sports/track_and_field": ("KEEP", "Mini-event loop."),
    "sports/trajectory_sports": ("MOVE_EXAMPLE", "Trajectory example or merge with golf/ski."),

    # strategy
    "strategy/bridge_builder": ("KEEP", "Physics/strategy puzzle."),
    "strategy/card_game": ("KEEP", "UI/rules demo."),
    "strategy/deckbuilder": ("KEEP", "Systems/UI demo with controlled scope."),
    "strategy/dune2_like": ("REWRITE_API", "Original RTS base demo, not an IP clone."),
    "strategy/eu2": ("TRIM", "Small province/economy/tick sim or incubator."),
    "strategy/frontier_tactics": ("KEEP", "Tactical slice if playable."),
    "strategy/hex_logistics": ("KEEP", "Logistics/hex demo."),
    "strategy/hex_strategy": ("KEEP", "Grid strategy demo."),
    "strategy/logic_game": ("KEEP", "Small puzzle/strategy game."),
    "strategy/match3": ("KEEP", "Catalog mini-game."),
    "strategy/maze_defense": ("KEEP", "Tower defense variant."),
    "strategy/party_games": ("TRIM", "One small minigame or drop."),
    "strategy/physics_puzzle": ("KEEP", "Physics/puzzle demo."),
    "strategy/rts": ("TRIM", "Small unit-command/building slice."),
    "strategy/swarm_evolution": ("KEEP", "Systems demo if playable."),
    "strategy/tactical_battle": ("KEEP", "Turn-based strategy slice."),
    "strategy/tower_defense": ("KEEP", "Priority mini-game demo."),
    "strategy/wargame": ("TRIM", "Small tactical map slice."),
    "strategy/worms_artillery": ("REWRITE_API", "Original artillery game, not an IP clone."),

    # test
    "test/light_min": ("MOVE_EXAMPLE", "Minimal API test, not a public game demo."),
}

CALLBACKS = {
    "init",
    "process",
    "process_physics",
    "process_late",
    "draw",
    "draw_ui",
    "render_ui",
    "load",
    "update",
    "keypressed",
    "keyreleased",
    "mousepressed",
    "mousereleased",
    "mousemoved",
    "wheelmoved",
    "touchpressed",
    "touchmoved",
    "touchreleased",
    "focus",
    "visible",
    "resize",
    "quit",
    "errhand",
}

STATUS_RE = re.compile(r"\*\*Status:\*\*\s*([^\n\r|]+)|\bStatus:\s*([^\n\r|]+)", re.I)
API_RE = re.compile(r"\blurek\.([a-zA-Z_][a-zA-Z0-9_]*)\b")


def rel_to_repo(path: Path) -> str:
    try:
        return path.relative_to(REPO_ROOT).as_posix()
    except ValueError:
        return path.as_posix()


def game_id(game_dir: Path, games_root: Path = DEFAULT_GAMES_ROOT) -> str:
    return game_dir.relative_to(games_root).as_posix()


def title_from_id(identifier: str) -> str:
    if identifier in TITLE_OVERRIDES:
        return TITLE_OVERRIDES[identifier]
    return identifier.rsplit("/", 1)[-1].replace("_", " ").replace("-", " ").title()


def category_sort_key(category: str) -> tuple[int, str]:
    try:
        return CATEGORY_ORDER.index(category), category
    except ValueError:
        return len(CATEGORY_ORDER), category


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return ""


def discover_game_dirs(games_root: Path = DEFAULT_GAMES_ROOT) -> list[Path]:
    out: list[Path] = []
    if not games_root.is_dir():
        return out
    for main_lua in sorted(games_root.glob("*/*/main.lua")):
        rel = main_lua.parent.relative_to(games_root)
        if any(part.startswith("_") for part in rel.parts):
            continue
        out.append(main_lua.parent)
    return out


def find_lurek_modules(game_dir: Path) -> list[str]:
    modules: set[str] = set()
    for lua_file in sorted(game_dir.rglob("*.lua")):
        text = read_text(lua_file)
        for hit in API_RE.findall(text):
            if hit not in CALLBACKS:
                modules.add(hit)
    return sorted(modules)


def extract_status(readme_text: str) -> str:
    match = STATUS_RE.search(readme_text)
    if not match:
        return "unspecified"
    raw = (match.group(1) or match.group(2) or "").strip()
    raw = raw.strip(" _*`.")
    return raw or "unspecified"


def extract_description(game_dir: Path) -> str:
    readme = read_text(game_dir / "README.md")
    for line in readme.splitlines():
        stripped = line.strip()
        if not stripped:
            continue
        if stripped.startswith(("#", "|", "!", "[", "- ", "* ", "```")):
            continue
        if stripped.lower().startswith(("category:", "**category", "**status", "status:")):
            continue
        return stripped[:220]

    main_lua = read_text(game_dir / "main.lua")
    for match in re.finditer(r"^\s*--\s*(.+)$", main_lua, re.M):
        text = match.group(1).strip(" -=\t")
        if len(text) >= 16 and "category" not in text.lower():
            return text[:220]
    return "No description available."


def decision_for(identifier: str) -> tuple[str, str]:
    return GAME_DECISIONS.get(identifier, ("REVIEW", DECISION_DESCRIPTIONS["REVIEW"]))


def is_public_decision(decision: str) -> bool:
    return decision in PUBLIC_DECISIONS


def is_non_public_decision(decision: str) -> bool:
    return decision in NON_PUBLIC_DECISIONS
