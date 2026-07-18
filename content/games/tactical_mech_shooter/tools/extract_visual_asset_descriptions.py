"""Export every visual asset id and description into one deterministic TOML index."""

from pathlib import Path
import json
import tomllib


GAME_ROOT = Path(__file__).resolve().parents[1]
RACES_ROOT = GAME_ROOT / "mods/core/races"
OUTPUT = Path(__file__).resolve().parent / "visual_asset_descriptions.toml"

GROUPS = (
    ("race", "race.toml", "race"),
    ("corpus", "corpora.toml", "corpus"),
    ("weapon", "weapons.toml", "weapon"),
    ("backpack", "backpacks.toml", "backpack"),
)


def toml_string(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def main() -> None:
    rows: list[dict[str, str]] = []
    seen: set[tuple[str, str]] = set()
    for race_dir in sorted(path for path in RACES_ROOT.iterdir() if path.is_dir()):
        for category, filename, table in GROUPS:
            path = race_dir / filename
            document = tomllib.loads(path.read_text(encoding="utf-8"))
            entries = document.get(table) if category != "race" else [document.get(table, {})]
            for entry in entries or []:
                key = str(entry.get("id", ""))
                description = entry.get("description")
                assert key and isinstance(description, str) and description.strip(), f"missing description: {path} {key}"
                identity = (category, key)
                assert identity not in seen, f"duplicate visual asset key: {identity}"
                seen.add(identity)
                asset_group = "races" if category == "race" else {"corpus": "corpora", "weapon": "weapons", "backpack": "backpacks"}[category]
                asset_path = (
                    f"mods/core/assets/races/{key}.svg"
                    if category == "race"
                    else f"mods/core/assets/{asset_group}/{race_dir.name}/{key}.svg"
                )
                row = {
                    "key": key,
                    "category": category,
                    "race": race_dir.name,
                    "source": path.relative_to(GAME_ROOT).as_posix(),
                    "asset_path": asset_path,
                    "name": str(entry.get("name", key)),
                    "description": description.strip(),
                }
                if category == "weapon":
                    row["kind"] = str(entry.get("kind", "projectile"))
                rows.append(row)

    lines = [
        "# Generated visual brief index for the Tactical Mech Shooter.",
        "# The descriptions are written for top-down pixel-art asset generation.",
        'kind = "visual_asset_descriptions"',
        'format_version = 1',
        'style = "top-down pixel art, transparent background, crisp 1-pixel outlines, limited palette, no text"',
        "",
    ]
    for row in rows:
        lines.extend([
            "[[asset]]",
            f"key = {toml_string(row['key'])}",
            f"category = {toml_string(row['category'])}",
            f"race = {toml_string(row['race'])}",
            f"source = {toml_string(row['source'])}",
            f"asset_path = {toml_string(row['asset_path'])}",
            f"name = {toml_string(row['name'])}",
            f"description = {toml_string(row['description'])}",
        ])
        if "kind" in row:
            lines.append(f"kind_hint = {toml_string(row['kind'])}")
        lines.append("")
    OUTPUT.write_text("\n".join(lines), encoding="utf-8", newline="\n")
    print(f"exported {len(rows)} visual descriptions to {OUTPUT}")


if __name__ == "__main__":
    main()
