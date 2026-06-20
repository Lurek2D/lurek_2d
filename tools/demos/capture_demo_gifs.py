#!/usr/bin/env python3
"""Create preview.gif files for content/games demos from existing screen.png.

This is a lightweight catalog helper. The engine already captures screen.png
through smoke_sweep.py/gen_demo_screenshots.py; this script turns that screenshot
into a short deterministic GIF placeholder until full frame capture is available.

Examples:
    python tools/demos/capture_demo_gifs.py --demo snake --overwrite
    python tools/demos/capture_demo_gifs.py --only-public --limit 10
    python tools/demos/capture_demo_gifs.py --kind game --only-public
    python tools/demos/capture_demo_gifs.py --only-public --restore-screen
    python tools/demos/capture_demo_gifs.py --all --dry-run
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

import game_catalog


def _load_pillow():
    try:
        from PIL import Image, ImageEnhance  # type: ignore[import-not-found]
    except ImportError as exc:
        raise SystemExit(
            "ERROR: Pillow is required to create preview.gif. "
            "Install project image tooling or run only screenshot capture first."
        ) from exc
    return Image, ImageEnhance


def _matches_demo(path: Path, games_root: Path, names: list[str]) -> bool:
    if not names:
        return True
    identifier = game_catalog.game_id(path, games_root)
    return any(name == path.name or name in identifier for name in names)


def discover_targets(args: argparse.Namespace) -> list[Path]:
    targets = game_catalog.discover_game_dirs(args.games_root)
    if args.only_public:
        targets = [
            path for path in targets
            if game_catalog.is_public_decision(game_catalog.decision_for(game_catalog.game_id(path, args.games_root))[0])
        ]
    if args.demo:
        targets = [path for path in targets if _matches_demo(path, args.games_root, args.demo)]
    if not args.all and not args.demo and not args.only_public:
        raise SystemExit("ERROR: choose --demo NAME, --only-public, or --all")
    if args.limit:
        targets = targets[: args.limit]
    return targets


def make_gif(screen_path: Path, gif_path: Path, *, seconds: float, fps: int, overwrite: bool) -> str:
    if gif_path.exists() and not overwrite:
        return "skip"
    if not screen_path.exists():
        return "missing-screen"

    Image, ImageEnhance = _load_pillow()
    source = Image.open(screen_path).convert("RGB")
    frames = max(1, int(seconds * fps))
    duration_ms = max(20, int(1000 / fps))

    images = []
    for index in range(frames):
        phase = index / max(1, frames - 1)
        # Subtle brightness pulse keeps the file an actual multi-frame preview
        # without inventing gameplay frames the engine did not capture.
        factor = 0.92 + 0.08 * (1.0 - abs(phase * 2.0 - 1.0))
        images.append(ImageEnhance.Brightness(source).enhance(factor))

    gif_path.parent.mkdir(parents=True, exist_ok=True)
    images[0].save(
        gif_path,
        save_all=True,
        append_images=images[1:],
        duration=duration_ms,
        loop=0,
        optimize=True,
    )
    return "wrote"


def restore_screen_from_gif(screen_path: Path, gif_path: Path, *, overwrite: bool) -> str:
    if screen_path.exists() and not overwrite:
        return "skip-screen"
    if not gif_path.exists():
        return "missing-gif"

    Image, _ImageEnhance = _load_pillow()
    frame = Image.open(gif_path).convert("RGB")
    screen_path.parent.mkdir(parents=True, exist_ok=True)
    frame.save(screen_path, "PNG")
    return "restored-screen"


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Create preview.gif files for content/games demos from existing screen.png.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument("--games-root", type=Path, default=game_catalog.DEFAULT_GAMES_ROOT)
    parser.add_argument(
        "--kind",
        choices=("game",),
        default="game",
        help="Compatibility flag; this tool currently captures game previews only.",
    )
    parser.add_argument("--demo", action="append", help="Demo name or id substring. Repeatable.")
    parser.add_argument("--only-public", action="store_true", help="Only KEEP/REWRITE_API/TRIM decisions.")
    parser.add_argument("--all", action="store_true", help="Process every discovered demo.")
    parser.add_argument("--seconds", type=float, default=5.0)
    parser.add_argument("--fps", type=int, default=12)
    parser.add_argument("--limit", type=int, default=0)
    parser.add_argument("--overwrite", action="store_true")
    parser.add_argument(
        "--restore-screen",
        action="store_true",
        help="Restore missing screen.png from the first preview.gif frame.",
    )
    parser.add_argument("--dry-run", action="store_true")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    targets = discover_targets(args)
    if not targets:
        print("No matching demos found.", file=sys.stderr)
        return 1

    counts: dict[str, int] = {
        "wrote": 0,
        "skip": 0,
        "missing-screen": 0,
        "restored-screen": 0,
        "skip-screen": 0,
        "missing-gif": 0,
    }
    for demo_dir in targets:
        rel = game_catalog.game_id(demo_dir, args.games_root)
        if args.dry_run:
            print(f"[dry-run] {rel}/screen.png -> {rel}/preview.gif")
            continue
        if args.restore_screen:
            status = restore_screen_from_gif(
                demo_dir / "screen.png",
                demo_dir / "preview.gif",
                overwrite=args.overwrite,
            )
        else:
            status = make_gif(
                demo_dir / "screen.png",
                demo_dir / "preview.gif",
                seconds=args.seconds,
                fps=args.fps,
                overwrite=args.overwrite,
            )
        counts[status] = counts.get(status, 0) + 1
        print(f"{status.upper():<14} {rel}")

    if not args.dry_run:
        print(
            "Summary: {wrote} wrote, {skip} skipped, {missing} missing screen.png, "
            "{restored} restored screen.png, {missing_gif} missing preview.gif".format(
                wrote=counts.get("wrote", 0),
                skip=counts.get("skip", 0),
                missing=counts.get("missing-screen", 0),
                restored=counts.get("restored-screen", 0),
                missing_gif=counts.get("missing-gif", 0),
            )
        )
    return 0 if counts.get("missing-screen", 0) == 0 and counts.get("missing-gif", 0) == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
