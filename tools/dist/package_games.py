"""
tools/dist/package_games.py — Pack each game into a .lurek archive (ZIP).

Usage:
    python tools/dist/package_games.py [--out DIR] [--demo NAME]

Outputs one  <game_name>.lurek  file per game under:
    dist/games/        (default) or the path given by --out

The .lurek format is a standard ZIP archive.  The Lurek2D engine recognises
the .lurek extension and extracts it to a temp directory on launch.

File layout inside the ZIP (flat, no top-level folder):
    conf.toml   (required if present)
    main.lua    (required)
    README.md   (included if present)
    screen.png  (included if present)
    *.lua       (all other .lua files)
    assets/**   (everything in an assets/ sub-folder, if any)
"""

import argparse
import pathlib
import sys
import zipfile

REPO_ROOT = pathlib.Path(__file__).resolve().parents[2]
GAMES_ROOT = REPO_ROOT / "content" / "games"

# Files to always include if they exist (relative to game folder)
ALWAYS_INCLUDE = {"conf.toml", "main.lua", "README.md", "screen.png"}

# Extensions to include from the game folder root
INCLUDE_EXTENSIONS = {".lua", ".toml", ".md", ".png", ".jpg", ".jpeg",
                      ".wav", ".ogg", ".mp3", ".flac",
                      ".wgsl", ".json", ".txt", ".ttf", ".otf"}

# Sub-folders to include recursively
INCLUDE_DIRS = {"assets", "fonts", "sounds", "music", "images", "sprites",
                "maps", "data", "shaders", "levels", "lib", "modules"}


def collect_files(game_dir: pathlib.Path) -> list[tuple[pathlib.Path, str]]:
    """
    Return (absolute_path, archive_name) pairs for every file to include.
    The archive_name is the path inside the ZIP (always relative, no top folder).
    """
    entries: list[tuple[pathlib.Path, str]] = []
    seen: set[str] = set()

    def add(p: pathlib.Path, name: str):
        if name not in seen:
            seen.add(name)
            entries.append((p, name))

    # Root-level files
    for f in sorted(game_dir.iterdir()):
        if f.is_file() and f.suffix.lower() in INCLUDE_EXTENSIONS:
            add(f, f.name)

    # Recognised sub-folders (recursive)
    for sub in sorted(game_dir.iterdir()):
        if sub.is_dir() and sub.name.lower() in INCLUDE_DIRS:
            for f in sorted(sub.rglob("*")):
                if f.is_file() and f.suffix.lower() in INCLUDE_EXTENSIONS:
                    archive_name = f.relative_to(game_dir).as_posix()
                    add(f, archive_name)

    return entries


def pack_game(game_dir: pathlib.Path, out_dir: pathlib.Path, archive_stem: str) -> pathlib.Path:
    """Create <archive_stem>.lurek in out_dir and return the output path."""
    out_dir.mkdir(parents=True, exist_ok=True)
    out_path = out_dir / (archive_stem + ".lurek")

    entries = collect_files(game_dir)
    if not any(name == "main.lua" for _, name in entries):
        raise FileNotFoundError(f"No main.lua in {game_dir}")

    with zipfile.ZipFile(out_path, "w", zipfile.ZIP_DEFLATED, compresslevel=6) as zf:
        for abs_path, arc_name in entries:
            zf.write(abs_path, arc_name)

    kb = out_path.stat().st_size // 1024
    return out_path, kb


def main():
    parser = argparse.ArgumentParser(
        description="Pack Lurek2D games into .lurek archives."
    )
    parser.add_argument(
        "--out",
        default=str(REPO_ROOT / "dist" / "games"),
        help="Output directory (default: dist/games/)",
    )
    parser.add_argument(
        "--demo",
        metavar="NAME",
        help="Only pack the game with this folder name.",
    )
    args = parser.parse_args()
    out_dir = pathlib.Path(args.out)

    games = sorted(GAMES_ROOT.rglob("main.lua"))
    if args.demo:
        games = [g for g in games if g.parent.name == args.demo]
        if not games:
            print(f"ERROR: no game named '{args.demo}' found.", file=sys.stderr)
            sys.exit(1)

    ok = 0
    errors = []
    for main_lua in games:
        game_dir = main_lua.parent
        category = game_dir.parent.name
        name = game_dir.name
        archive_stem = f"{category}_{name}"
        try:
            out_path, kb = pack_game(game_dir, out_dir, archive_stem)
            print(f"  OK  {archive_stem:40s}  {kb:4d} KB  -> {out_path.name}")
            ok += 1
        except Exception as e:
            errors.append((archive_stem, str(e)))
            print(f"  ERR {archive_stem:40s}  {e}", file=sys.stderr)

    print(f"\nPacked: {ok}  |  Errors: {len(errors)}")
    if errors:
        sys.exit(1)


if __name__ == "__main__":
    main()
