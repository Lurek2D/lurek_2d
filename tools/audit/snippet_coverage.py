#!/usr/bin/env python3
"""Report snippet coverage per Lua API module based on -- @snippet markers."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
if str(ROOT / "tools" / "snippets") not in sys.path:
    sys.path.insert(0, str(ROOT / "tools" / "snippets"))

from snippet_catalog import parse_dir  # noqa: E402

API_JSON = ROOT / "logs" / "data" / "lua_api_data.json"
DEFAULT_SNIPPETS_DIR = ROOT / "content" / "snippets"
DEFAULT_REPORT = ROOT / "logs" / "reports" / "snippet_coverage.md"


def load_api_counts(path: Path) -> dict[str, int]:
    data = json.loads(path.read_text(encoding="utf-8"))
    modules = data.get("lua_api", {}).get("modules", {})

    out: dict[str, int] = {}
    for module, payload in modules.items():
        fn_count = len(payload.get("functions", []))
        method_count = 0
        for cls_data in (payload.get("classes") or {}).values():
            method_count += len(cls_data.get("methods", []))
        out[module] = fn_count + method_count

    return out


def render_markdown(rows: list[dict]) -> str:
    lines = [
        "# Snippet Coverage",
        "",
        "_Coverage model: snippet_count per module and snippet density per 100 API items._",
        "",
        "| Module | API items | Snippets | Snippets / 100 API |",
        "| ------ | --------: | -------: | -----------------: |",
    ]

    for row in rows:
        lines.append(
            f"| `{row['module']}` | {row['api_items']} | {row['snippets']} | {row['density']:.1f} |"
        )

    total_api = sum(r["api_items"] for r in rows)
    total_snippets = sum(r["snippets"] for r in rows)
    total_density = (total_snippets / total_api * 100.0) if total_api else 0.0

    lines += [
        "",
        "## Summary",
        "",
        f"- Modules: **{len(rows)}**",
        f"- API items: **{total_api}**",
        f"- Snippets: **{total_snippets}**",
        f"- Snippets / 100 API: **{total_density:.1f}**",
        "",
    ]

    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description="Audit marker-based snippet coverage per module.")
    parser.add_argument("--snippets-dir", default=str(DEFAULT_SNIPPETS_DIR))
    parser.add_argument("--api-json", default=str(API_JSON))
    parser.add_argument("--json", action="store_true", help="Print JSON output.")
    parser.add_argument("--output", default=str(DEFAULT_REPORT), help="Markdown report path.")
    parser.add_argument("--threshold", type=float, default=0.0, help="Minimum snippets-per-100-API threshold.")
    args = parser.parse_args()

    snippets_dir = Path(args.snippets_dir)
    api_json = Path(args.api_json)

    api_counts = load_api_counts(api_json)
    blocks = parse_dir(snippets_dir)

    snippet_counts: dict[str, int] = {module: 0 for module in api_counts}
    for block in blocks:
        snippet_counts.setdefault(block.module, 0)
        snippet_counts[block.module] += 1

    rows: list[dict] = []
    for module in sorted(api_counts.keys()):
        api_items = api_counts[module]
        snippets = snippet_counts.get(module, 0)
        density = (snippets / api_items * 100.0) if api_items else 0.0
        rows.append(
            {
                "module": module,
                "api_items": api_items,
                "snippets": snippets,
                "density": density,
            }
        )

    if args.json:
        print(json.dumps({"modules": rows}, indent=2, ensure_ascii=False))
    else:
        report_path = Path(args.output)
        report_path.parent.mkdir(parents=True, exist_ok=True)
        report_path.write_text(render_markdown(rows), encoding="utf-8", newline="\n")
        print(f"Wrote snippet coverage report to {report_path}")

    avg_density = (sum(r["density"] for r in rows) / len(rows)) if rows else 0.0
    if args.threshold > 0 and avg_density < args.threshold:
        print(
            f"FAIL: average snippet density {avg_density:.1f} is below threshold {args.threshold:.1f}",
            file=sys.stderr,
        )
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
