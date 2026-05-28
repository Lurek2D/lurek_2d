#!/usr/bin/env python3
"""Generate a static HTML browser for the Lurek2D Lua API.

The output is a folder-based static site with separate HTML pages, CSS, JS,
and a generated search index. It stays independent from Rust docs and lives in
its own output directory.

Usage:
    python tools/docs/gen_docs_lua_html.py
    python tools/docs/gen_docs_lua_html.py --input logs/data/lua_api_data.json
    python tools/docs/gen_docs_lua_html.py --output build/doc/lua-api
"""

from __future__ import annotations

import argparse
import json
import re
import shutil
import sys
from dataclasses import dataclass
from html import escape
from pathlib import Path
from typing import Any

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent.parent
INPUT_FILE = WORKSPACE_ROOT / "logs" / "data" / "lua_api_data.json"
OUTPUT_DIR = WORKSPACE_ROOT / "build" / "doc" / "lua-api"
EXAMPLES_DIR = WORKSPACE_ROOT / "content" / "examples"
ICON_CANDIDATES = [
    WORKSPACE_ROOT / "extension" / "vscode" / "media" / "lurek-logo.png",
    WORKSPACE_ROOT / "assets" / "icon-large.png",
    WORKSPACE_ROOT / "assets" / "icon.png",
]

_MODULE_ORDER = [
    "render", "graphics_ext", "window", "input", "timer", "math", "math_ext",
    "audio", "physics", "filesystem", "particle", "event", "system", "thread",
    "ai", "compute", "dataframe", "data", "image", "sound", "graph", "tilemap",
    "dialog", "ecs", "scene", "pathfind", "postfx", "minimap", "save", "mods",
    "i18n", "stats", "inventory", "crafting", "cardgame", "combat", "log",
    "debug", "battle", "debugbridge", "docs", "item", "patterns", "quest",
    "resource",
]

_LUA_NAMESPACE = {
    "timer": "time",
    "event": "signal",
    "automation": "simulator",
}

_EXAMPLE_FILE_ALIASES = {
    "data": "binary.lua",
    "graph": "flownet.lua",
    "system": "runtime.lua",
}

_CALLBACKS = [
    ("lurek.init", "function lurek.init()", "Called once when the engine initialises."),
    ("lurek.ready", "function lurek.ready()", "Called after the first init pass, when assets are ready."),
    ("lurek.process", "function lurek.process(dt)", "Runs once per frame for variable-step game logic."),
    ("lurek.process_physics", "function lurek.process_physics(dt)", "Runs on the fixed physics step; dt is the fixed-step delta."),
    ("lurek.process_late", "function lurek.process_late(dt)", "Runs after main update work, before drawing."),
    ("lurek.draw", "function lurek.draw()", "Draw world-space content for the current frame."),
    ("lurek.draw_ui", "function lurek.draw_ui()", "Draw screen-space HUD and UI layers."),
    ("lurek.resize", "function lurek.resize(w, h)", "Called when the window size changes."),
    ("lurek.keypressed", "function lurek.keypressed(key, scancode, isrepeat)", "Called when a key is pressed."),
    ("lurek.keyreleased", "function lurek.keyreleased(key, scancode)", "Called when a key is released."),
    ("lurek.mousepressed", "function lurek.mousepressed(x, y, button, istouch, presses)", "Called when a mouse button is pressed."),
    ("lurek.mousereleased", "function lurek.mousereleased(x, y, button, istouch, presses)", "Called when a mouse button is released."),
    ("lurek.mousemoved", "function lurek.mousemoved(x, y, dx, dy, istouch)", "Called when the cursor moves."),
    ("lurek.wheelmoved", "function lurek.wheelmoved(x, y)", "Called when the mouse wheel moves."),
    ("lurek.textinput", "function lurek.textinput(text)", "Called when text input is received from the platform IME."),
    ("lurek.gamepadpressed", "function lurek.gamepadpressed(joystick, button)", "Called when a gamepad button is pressed."),
    ("lurek.gamepadreleased", "function lurek.gamepadreleased(joystick, button)", "Called when a gamepad button is released."),
    ("lurek.gamepadaxis", "function lurek.gamepadaxis(joystick, axis, value)", "Called when a gamepad axis value changes."),
    ("lurek.focus", "function lurek.focus(focused)", "Called when the game window gains or loses focus."),
    ("lurek.quit", "function lurek.quit()", "Called before the runtime shuts down."),
]

LUREK_COLORS = {
    "ink": "#17385f",
    "sky": "#7fc4e7",
    "frost": "#e3f7ff",
}


@dataclass(frozen=True)
class ExampleSnippet:
    text: str
    file_name: str
    match_kind: str


def _ordered_modules(modules: dict[str, Any]) -> list[str]:
    seen = set()
    ordered: list[str] = []
    for name in _MODULE_ORDER:
        if name in modules:
            seen.add(name)
            ordered.append(name)
    for name in sorted(modules):
        if name not in seen:
            ordered.append(name)
    return ordered


def _slug(value: str) -> str:
    chars: list[str] = []
    prev_dash = False
    for ch in value.lower():
        if ch.isalnum():
            chars.append(ch)
            prev_dash = False
        elif not prev_dash:
            chars.append("-")
            prev_dash = True
    return "".join(chars).strip("-") or "item"


def _trim(text: str | None) -> str:
    return " ".join((text or "").split())


def _module_namespace(module_name: str) -> str:
    return _LUA_NAMESPACE.get(module_name, module_name)


def _module_href(module_name: str) -> str:
    return f"modules/{module_name}.html"


def _class_href(class_name: str) -> str:
    return f"classes/{class_name}.html"


def _source_label(entry: dict[str, Any]) -> str:
    file_name = entry.get("file") or entry.get("source_file") or ""
    line = entry.get("line")
    return f"{file_name}:{line}" if file_name and line else file_name


def _signature(prefix: str, entry: dict[str, Any]) -> str:
    typed_params = entry.get("typed_params")
    params: list[str] = []
    if isinstance(typed_params, list):
        for item in typed_params:
            if not item:
                continue
            name = str(item[0])
            lua_type = str(item[1]) if len(item) > 1 and item[1] else ""
            params.append(f"{name}: {lua_type}" if lua_type else name)
    ret = entry.get("inferred_return") or ""
    sig = f"{prefix}({', '.join(params)})"
    if ret and ret != "any":
        sig += f" -> {ret}"
    return sig


def _module_summary(mod_data: dict[str, Any]) -> tuple[int, int, int]:
    functions = mod_data.get("functions", [])
    classes = mod_data.get("classes", {})
    method_count = sum(len(cls.get("methods", [])) for cls in classes.values())
    return len(functions), len(classes), method_count


def _global_nav(site_base: str, current_page: str) -> str:
    nav_items = [
        ("index.html", "Overview", "overview"),
        ("callbacks.html", "Callbacks", "callbacks"),
        ("types.html", "Types", "types"),
    ]
    out: list[str] = []
    for href, label, page_key in nav_items:
        active = " active" if page_key == current_page else ""
        out.append(f'<a class="global-link{active}" href="{escape(site_base)}/{href}">{escape(label)}</a>')
    return "\n".join(out)


def _render_sidebar(ordered: list[str], modules: dict[str, Any], current_module: str | None, site_base: str, current_page: str) -> str:
    module_links: list[str] = []
    for name in ordered:
        functions, classes, methods = _module_summary(modules[name])
        active = ' class="active"' if name == current_module else ""
        namespace = _module_namespace(name)
        module_links.append(
            f'<a{active} href="{escape(site_base)}/{_module_href(name)}">'
            f'<span class="nav-name">lurek.{escape(namespace)}</span>'
            f'<span class="nav-meta">{functions} fn · {classes} cls · {methods} meth</span>'
            f'</a>'
        )

    return (
        f'<div class="global-nav">{_global_nav(site_base, current_page)}</div>'
        '<div class="nav-section-title">Modules</div>'
        f'<nav class="module-nav">{"".join(module_links)}</nav>'
    )


def _callback_example(signature: str, name: str) -> str:
    if name == "lurek.process":
        return "function lurek.process(dt)\n  player:update(dt)\n  hud:tick(dt)\nend"
    if name == "lurek.process_physics":
        return "function lurek.process_physics(dt)\n  world:step(dt)\n  scene:syncBodies()\nend"
    if name == "lurek.draw":
        return "function lurek.draw()\n  worldRenderer:draw()\n  effects:draw()\nend"
    if name == "lurek.draw_ui":
        return "function lurek.draw_ui()\n  hud:draw()\n  pauseMenu:draw()\nend"
    if name == "lurek.keypressed":
        return "function lurek.keypressed(key, scancode, isrepeat)\n  if key == \"escape\" then\n    pauseMenu:toggle()\n  end\nend"
    if name == "lurek.resize":
        return "function lurek.resize(w, h)\n  camera:setViewport(w, h)\n  hud:layout(w, h)\nend"
    return f"{signature}\n  -- handle {name.split('.')[-1]} here\nend"


def _example_key(value: str) -> str:
    return re.sub(r"\s+", "", value.strip().strip("`")).lower()


def _example_key_variants(value: str) -> set[str]:
    clean = value.strip().strip("` ")
    variants = {clean}
    if ":" in clean:
        owner, method_name = clean.split(":", 1)
        if owner.startswith("L") and len(owner) > 1:
            variants.add(f"{owner[1:]}:{method_name}")
        else:
            variants.add(f"L{owner}:{method_name}")
    return {_example_key(item) for item in variants if item}


def _lua_block_delta(line: str) -> int:
    code = line.split("--", 1)[0]
    opens = len(re.findall(r"\b(?:do|function|then|repeat)\b", code))
    closes = len(re.findall(r"\b(?:end|until)\b", code))
    return opens - closes


def _extract_lua_block(lines: list[str], start: int, max_lines: int = 48) -> str:
    selected: list[str] = []
    depth = 0
    for index in range(start, min(len(lines), start + max_lines)):
        line = lines[index]
        if any(marker in line for marker in (".github/", "CAG", "Generated by tools/", "COVERAGE:")):
            continue
        selected.append(line)
        depth += _lua_block_delta(line)
        if index > start and depth <= 0:
            break
    while selected and not selected[0].strip():
        selected.pop(0)
    while selected and not selected[-1].strip():
        selected.pop()
    return "\n".join(selected)


def _snippet_around(lines: list[str], index: int, max_lines: int = 18) -> str:
    start = max(0, index - 4)
    while start > 0 and lines[start].strip() and not lines[start].strip().startswith("--@api-stub"):
        if index - start >= 6:
            break
        start -= 1
    selected = lines[start:min(len(lines), start + max_lines)]
    while selected and selected[0].strip().startswith("--@api-stub"):
        selected.pop(0)
    while selected and not selected[0].strip():
        selected.pop(0)
    while selected and not selected[-1].strip():
        selected.pop()
    return "\n".join(selected)


def _example_snippet_from_lines(lines: list[str], max_lines: int = 48) -> str:
    for index, line in enumerate(lines):
        if re.match(r"\s*do\s+--\s+", line):
            return _extract_lua_block(lines, index, max_lines)
    for index, line in enumerate(lines):
        if "function lurek." in line and not line.strip().startswith("--"):
            return _snippet_around(lines, index, max_lines)
    for index, line in enumerate(lines):
        if line.strip() and not line.strip().startswith("--"):
            return _snippet_around(lines, index, max_lines)
    return ""


def _build_example_indexes() -> tuple[dict[str, ExampleSnippet], dict[str, ExampleSnippet]]:
    callable_examples: dict[str, ExampleSnippet] = {}
    file_snippets: dict[str, ExampleSnippet] = {}
    if not EXAMPLES_DIR.exists():
        return callable_examples, file_snippets

    for path in sorted(EXAMPLES_DIR.rglob("*.lua")):
        if "assets" in path.parts:
            continue
        lines = path.read_text(encoding="utf-8").splitlines()
        snippet = _example_snippet_from_lines(lines)
        if snippet:
            file_snippets[path.name] = ExampleSnippet(snippet, path.name, "module")

        pending_targets: list[str] = []
        for index, line in enumerate(lines):
            stub_match = re.search(r"--@api-stub:\s*([^\s]+)", line)
            if stub_match:
                pending_targets = [stub_match.group(1)]
                continue

            block_match = re.match(r"\s*do\s+--\s*(.+?)\s*$", line)
            plain_do = re.match(r"\s*do\s*$", line) and bool(pending_targets)
            if block_match or plain_do:
                block = _extract_lua_block(lines, index)
                targets = pending_targets + ([block_match.group(1)] if block_match else [])
                pending_targets = []
                for target in targets:
                    for key in _example_key_variants(target):
                        callable_examples[key] = ExampleSnippet(block, path.name, "exact")
                continue

            if pending_targets and line.strip() and not line.strip().startswith("--"):
                block = _snippet_around(lines, index)
                targets = pending_targets
                pending_targets = []
                for target in targets:
                    for key in _example_key_variants(target):
                        callable_examples.setdefault(key, ExampleSnippet(block, path.name, "exact"))
    return callable_examples, file_snippets


def _callable_example_keys(module_name: str, entry: dict[str, Any], class_name: str | None = None) -> list[str]:
    keys: list[str] = []
    lua_name = str(entry.get("lua_name") or "")
    name = str(entry.get("name") or "")
    if class_name:
        keys.append(f"{class_name}:{name}")
    elif lua_name:
        keys.append(lua_name)
    else:
        keys.append(f"lurek.{_module_namespace(module_name)}.{name}")

    variants: list[str] = []
    for key in keys:
        for variant in _example_key_variants(key):
            if variant not in variants:
                variants.append(variant)
    return variants


def _lookup_example(callable_examples: dict[str, ExampleSnippet], module_name: str, entry: dict[str, Any], class_name: str | None = None) -> ExampleSnippet | None:
    for key in _callable_example_keys(module_name, entry, class_name):
        if key in callable_examples:
            return callable_examples[key]
    return None


def _module_exact_example_count(module_name: str, mod_data: dict[str, Any], callable_examples: dict[str, ExampleSnippet]) -> int:
    count = 0
    for entry in mod_data.get("functions", []):
        if _lookup_example(callable_examples, module_name, entry):
            count += 1
    for class_name, class_data in mod_data.get("classes", {}).items():
        for entry in class_data.get("methods", []):
            if _lookup_example(callable_examples, module_name, entry, class_name):
                count += 1
    return count


def _render_example_block(title: str, snippet: ExampleSnippet | None) -> str:
    if not snippet or not snippet.text.strip():
        return ""
    badge = "Exact example" if snippet.match_kind == "exact" else "Module example"
    return (
        '<details class="example-block">'
        f'<summary>{escape(title)} · {escape(badge)} · {escape(snippet.file_name)}</summary>'
        f'<pre><code>{escape(snippet.text)}</code></pre>'
        '</details>'
    )


def _method_preview(methods: list[dict[str, Any]], class_name: str, limit: int = 8) -> str:
    preview = methods[:limit]
    chips = "".join(
        f'<a href="{_class_href(class_name)}#method-{_slug(str(method["name"]))}">{escape(str(method["name"]))}</a>'
        for method in preview
    )
    remaining = len(methods) - len(preview)
    if remaining > 0:
        chips += f'<span>+{remaining} more</span>'
    return chips or "<span>None</span>"


def _render_api_card(kind: str, title: str, signature: str, description: str, source_label: str, anchor: str, example_block: str = "") -> str:
    meta = f'<div class="api-meta"><span>{escape(kind)}</span><span>{escape(source_label or "generated")}</span></div>'
    return (
        f'<article class="api-card" id="{escape(anchor)}">'
        f'<h3>{escape(title)}</h3>'
        f'<pre>{escape(signature)}</pre>'
        f'<p>{escape(description)}</p>'
        f'{meta}'
        f'{example_block}'
        '</article>'
    )


def _page_template(*, title: str, site_base: str, asset_prefix: str, sidebar_html: str, body_html: str, icon_path: str | None) -> str:
    icon_html = (
        f'<img class="brand-mark" src="{escape(asset_prefix)}/{escape(icon_path)}" alt="Lurek2D logo">'
        if icon_path
        else '<div class="brand-orb" aria-hidden="true"></div>'
    )
    return f"""<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{escape(title)}</title>
  <link rel="stylesheet" href="{escape(asset_prefix)}/assets/style.css">
</head>
<body>
  <div class="shell">
    <aside class="sidebar">
      <a class="brand" href="{escape(site_base)}/index.html">
        {icon_html}
        <div>
          <strong>Lurek Lua Docs</strong>
          <span>Static browser for the generated API</span>
        </div>
      </a>
      <label class="search-box">
        <span>Search API</span>
        <input id="search" type="search" placeholder="module, class, function, method">
      </label>
      <div class="search-filters">
        <label><span>Module</span><select id="filter-module"><option value="">All modules</option></select></label>
        <label><span>Type</span><select id="filter-kind"><option value="">All types</option></select></label>
      </div>
      <div id="search-results" class="search-results" hidden></div>
      {sidebar_html}
    </aside>
    <main class="content">
      {body_html}
    </main>
  </div>
  <script>
    window.LUREK_SITE_BASE = {json.dumps(site_base)};
  </script>
    <script src="{escape(asset_prefix)}/assets/search-index.js"></script>
  <script src="{escape(asset_prefix)}/assets/app.js"></script>
</body>
</html>
"""


def _render_home(data: dict[str, Any], ordered: list[str], output_dir: Path, icon_path: str | None, callable_examples: dict[str, ExampleSnippet]) -> None:
    modules = data["lua_api"]["modules"]
    summary = data["lua_api"]["summary"]
    meta = data["meta"]

    cards: list[str] = []
    for name in ordered:
        mod_data = modules[name]
        functions, classes, methods = _module_summary(mod_data)
        description = _trim(mod_data.get("description")) or f"Lua namespace lurek.{_module_namespace(name)}."
        exact_examples = _module_exact_example_count(name, mod_data, callable_examples)
        sample_note = f'<span>examples {exact_examples}</span>' if exact_examples else ""
        cards.append(
            '<article class="item-row">'
            f'<div class="item-row-main"><h3><a href="{_module_href(name)}">lurek.{escape(_module_namespace(name))}</a></h3><p>{escape(description)}</p></div>'
            f'<div class="item-row-meta"><span>{functions} fn</span><span>{classes} cls</span><span>{methods} meth</span>{sample_note}</div>'
            '</article>'
        )

        body_html = f"""
<header class="page-header compact-header">
    <p class="eyebrow">Generated from logs/data/lua_api_data.json</p>
    <h1>Lurek2D Lua API Browser</h1>
    <p class="hero-copy">Static docs for lurek.* with module pages, type index, callbacks, and exact example snippets.</p>
    <div class="api-meta api-meta-header"><span>v{escape(meta['version'])}</span><span>{escape(meta['generated'][:10])}</span><span>{summary['modules']} modules</span><span>{summary['total_functions']} items</span><span>{summary['coverage_pct']}% coverage</span></div>
</header>

<section class="section-block">
  <div class="section-head">
    <h2>Global Pages</h2>
        <p>Quick navigation.</p>
  </div>
    <div class="item-list compact-list">
        <article class="item-row"><div class="item-row-main"><h3><a href="callbacks.html">Callback Index</a></h3><p>Lifecycle, input, and platform hooks.</p></div></article>
        <article class="item-row"><div class="item-row-main"><h3><a href="types.html">Type Index</a></h3><p>All classes and enums in one catalog.</p></div></article>
  </div>
</section>

<section class="section-block">
  <div class="section-head">
    <h2>Modules</h2>
        <p>Short description and navigation only.</p>
  </div>
    <div class="item-list compact-list">
    {''.join(cards)}
  </div>
</section>
"""

    html = _page_template(
        title="Lurek2D Lua API Browser",
        site_base=".",
        asset_prefix=".",
        sidebar_html=_render_sidebar(ordered, modules, None, ".", "overview"),
        body_html=body_html,
        icon_path=icon_path,
    )
    (output_dir / "index.html").write_text(html, encoding="utf-8")


def _render_module_page(module_name: str, mod_data: dict[str, Any], ordered: list[str], modules: dict[str, Any], output_dir: Path, icon_path: str | None, callable_examples: dict[str, ExampleSnippet]) -> None:
    namespace = _module_namespace(module_name)
    description = _trim(mod_data.get("description")) or f"Lua namespace lurek.{namespace}."
    source_label = _source_label(mod_data)
    functions = mod_data.get("functions", [])
    classes = mod_data.get("classes", {})

    function_cards: list[str] = []
    for entry in sorted(functions, key=lambda item: item["name"]):
        name = str(entry["name"])
        anchor = f"fn-{_slug(name)}"
        signature = _signature(f"lurek.{namespace}.{name}", entry)
        example_block = _render_example_block("Example", _lookup_example(callable_examples, module_name, entry))
        function_cards.append(
            f'<article class="item-row api-row" id="{escape(anchor)}">'
            f'<div class="item-row-main"><h3>{escape(name)}</h3><pre class="inline-signature">{escape(signature)}</pre><p>{escape(_trim(entry.get("description")) or "No summary available.")}</p></div>'
            f'<div class="item-row-meta"><span>function</span><span>{escape(_source_label(entry) or "generated")}</span></div>'
            f'{example_block}'
            '</article>'
        )

    class_cards: list[str] = []
    for class_name, class_data in sorted(classes.items()):
        methods = class_data.get("methods", [])
        example = None
        for method in methods:
            example = _lookup_example(callable_examples, module_name, method, class_name)
            if example:
                break
        example_note = f'<div class="card-note">Example: {escape(example.file_name)}</div>' if example else ""
        class_cards.append(
            '<article class="item-row">'
            f'<div class="item-row-main"><h3><a href="../{_class_href(class_name)}">{escape(class_name)}</a></h3><p>{escape(_trim(class_data.get("description")) or "Lua userdata type.")}</p></div>'
            f'<div class="item-row-meta"><span>{len(methods)} methods</span><span>module {escape(namespace)}</span></div>'
            f'{example_note}'
            '</article>'
        )

    exact_examples = _module_exact_example_count(module_name, mod_data, callable_examples)
    body_html = f"""
<header class="page-header">
  <p class="eyebrow">Module</p>
  <h1>lurek.{escape(namespace)}</h1>
  <p>{escape(description)}</p>
  <div class="api-meta api-meta-header"><span>{len(functions)} functions</span><span>{len(classes)} classes</span><span>{escape(source_label or 'generated')}</span></div>
    <div class="api-meta api-meta-header"><span>Exact examples: {exact_examples}</span><a href="#functions">Functions</a><a href="#classes">Classes</a></div>
</header>

<section class="section-block" id="functions">
  <div class="section-head">
    <h2>Functions</h2>
    <p>Standalone namespace functions registered under lurek.{escape(namespace)}.</p>
  </div>
    <div class="item-list">
    {''.join(function_cards) if function_cards else '<p class="empty-state">No standalone functions in this module.</p>'}
  </div>
</section>

<section class="section-block" id="classes">
  <div class="section-head">
    <h2>Classes</h2>
    <p>Lua userdata types that expose methods through this module.</p>
  </div>
    <div class="item-list compact-list">
    {''.join(class_cards) if class_cards else '<p class="empty-state">No classes in this module.</p>'}
  </div>
</section>
"""

    html = _page_template(
        title=f"lurek.{namespace} - Lurek2D Lua API Browser",
        site_base="..",
        asset_prefix="..",
        sidebar_html=_render_sidebar(ordered, modules, module_name, "..", "overview"),
        body_html=body_html,
        icon_path=icon_path,
    )
    (output_dir / "modules" / f"{module_name}.html").write_text(html, encoding="utf-8")


def _render_class_page(class_name: str, module_name: str, class_data: dict[str, Any], ordered: list[str], modules: dict[str, Any], output_dir: Path, icon_path: str | None, callable_examples: dict[str, ExampleSnippet]) -> None:
    namespace = _module_namespace(module_name)
    methods = class_data.get("methods", [])
    method_cards: list[str] = []
    for entry in sorted(methods, key=lambda item: item["name"]):
        name = str(entry["name"])
        anchor = f"method-{_slug(name)}"
        signature = _signature(f"{class_name}:{name}", entry)
        example_block = _render_example_block("Example", _lookup_example(callable_examples, module_name, entry, class_name))
        method_cards.append(
            f'<article class="item-row api-row" id="{escape(anchor)}">'
            f'<div class="item-row-main"><h3>{escape(name)}</h3><pre class="inline-signature">{escape(signature)}</pre><p>{escape(_trim(entry.get("description")) or "No summary available.")}</p></div>'
            f'<div class="item-row-meta"><span>method</span><span>{escape(_source_label(entry) or "generated")}</span></div>'
            f'{example_block}'
            '</article>'
        )

    description = _trim(class_data.get("description")) or "Lua userdata type."
    class_example = None
    for entry in methods:
        class_example = _lookup_example(callable_examples, module_name, entry, class_name)
        if class_example:
            break
    body_html = f"""
<header class="page-header">
  <p class="eyebrow">Class</p>
  <h1>{escape(class_name)}</h1>
  <p>{escape(description)}</p>
  <div class="crumbs"><a href="../index.html">Docs home</a><span>/</span><a href="../{_module_href(module_name)}">lurek.{escape(namespace)}</a></div>
  {_render_example_block('Class Example', class_example)}
</header>

<section class="section-block">
  <div class="section-head">
    <h2>Methods</h2>
    <p>Instance methods exported from the {escape(class_name)} userdata.</p>
  </div>
    <div class="item-list">
    {''.join(method_cards) if method_cards else '<p class="empty-state">No methods documented for this class.</p>'}
  </div>
</section>
"""

    html = _page_template(
        title=f"{class_name} - Lurek2D Lua API Browser",
        site_base="..",
        asset_prefix="..",
        sidebar_html=_render_sidebar(ordered, modules, module_name, "..", "overview"),
        body_html=body_html,
        icon_path=icon_path,
    )
    (output_dir / "classes" / f"{class_name}.html").write_text(html, encoding="utf-8")


def _render_callbacks_page(output_dir: Path, ordered: list[str], modules: dict[str, Any], icon_path: str | None) -> None:
    callback_cards: list[str] = []
    for name, signature, description in _CALLBACKS:
        callback_cards.append(
            _render_api_card(
                "callback",
                name,
                signature,
                description,
                "runtime hook",
                f"callback-{_slug(name)}",
                _render_example_block("Example", ExampleSnippet(_callback_example(signature, name), "generated callback skeleton", "module")),
            )
        )

    body_html = f"""
<header class="page-header">
  <p class="eyebrow">Global Index</p>
  <h1>Callbacks</h1>
  <p>Global lifecycle, input, and platform callbacks. These are not module methods; they are special runtime entry points the engine looks up directly on the global lurek table.</p>
</header>

<section class="section-block">
  <div class="section-head">
    <h2>Runtime Hooks</h2>
    <p>Use these as stable entry points for frame flow, input, focus, and shutdown work.</p>
  </div>
  <div class="api-list">
    {''.join(callback_cards)}
  </div>
</section>
"""

    html = _page_template(
        title="Callbacks - Lurek2D Lua API Browser",
        site_base=".",
        asset_prefix=".",
        sidebar_html=_render_sidebar(ordered, modules, None, ".", "callbacks"),
        body_html=body_html,
        icon_path=icon_path,
    )
    (output_dir / "callbacks.html").write_text(html, encoding="utf-8")


def _render_search_page(ordered: list[str], modules: dict[str, Any], output_dir: Path, icon_path: str | None) -> None:
        body_html = """
<header class="page-header">
    <p class="eyebrow">Global Search</p>
    <h1>Search Results</h1>
    <p>Use the sidebar query and filters to browse a full-page result list across modules, functions, methods, classes, callbacks, and enums.</p>
</header>

<section class="section-block">
    <div class="section-head">
        <h2>Matches</h2>
        <p id="search-summary">Enter a query or use filters to list API entries.</p>
    </div>
    <div id="page-search-results" class="api-list"></div>
</section>
"""

        html = _page_template(
                title="Search - Lurek2D Lua API Browser",
                site_base=".",
                asset_prefix=".",
                sidebar_html=_render_sidebar(ordered, modules, None, ".", "search"),
                body_html=body_html,
                icon_path=icon_path,
        )
        (output_dir / "search.html").write_text(html, encoding="utf-8")


def _render_types_page(data: dict[str, Any], ordered: list[str], output_dir: Path, icon_path: str | None) -> None:
    modules = data["lua_api"]["modules"]
    class_cards: list[str] = []
    for module_name in ordered:
        namespace = _module_namespace(module_name)
        for class_name, class_data in sorted(modules[module_name].get("classes", {}).items()):
            methods = sorted(class_data.get("methods", []), key=lambda item: item["name"])
            method_tokens = "".join(
                f'<a href="{_class_href(class_name)}#method-{_slug(str(method["name"]))}">{escape(str(method["name"]))}</a>'
                for method in methods
            )
            class_cards.append(
                '<article class="item-row">'
                f'<div class="item-row-main"><h3><a href="{_class_href(class_name)}">{escape(class_name)}</a></h3><p>{escape(_trim(class_data.get("description")) or "Lua userdata type.")}</p><div class="type-methods"><strong>Methods</strong><div class="token-row">{_method_preview(methods, class_name)}</div></div></div>'
                f'<div class="item-row-meta"><span>class</span><span>lurek.{escape(namespace)}</span><span>{len(methods)} methods</span></div>'
                '</article>'
            )

    enum_cards: list[str] = []
    for enum_name, values in sorted(data["lua_api"].get("enums", {}).items()):
        value_html = "".join(f'<span>{escape(str(value))}</span>' for value in values)
        enum_cards.append(
            f'<article class="api-card" id="enum-{_slug(enum_name)}">'
            f'<h3>{escape(enum_name)}</h3>'
            '<p>Generated enum values available to Lua callers.</p>'
            f'<div class="token-row">{value_html}</div>'
            '</article>'
        )

    body_html = f"""
<header class="page-header">
  <p class="eyebrow">Global Index</p>
  <h1>Type Index</h1>
  <p>Cross-module catalog of all Lua userdata types and generated enum values.</p>
</header>

<section class="section-block">
  <div class="section-head">
    <h2>Classes</h2>
        <p>Compact index with short method preview.</p>
  </div>
    <div class="item-list compact-list">
    {''.join(class_cards) if class_cards else '<p class="empty-state">No classes found.</p>'}
  </div>
</section>

<section class="section-block">
  <div class="section-head">
    <h2>Enums</h2>
    <p>Generated enum domains extracted from the Lua API data snapshot.</p>
  </div>
  <div class="api-list">
    {''.join(enum_cards) if enum_cards else '<p class="empty-state">No enums found.</p>'}
  </div>
</section>
"""

    html = _page_template(
        title="Type Index - Lurek2D Lua API Browser",
        site_base=".",
        asset_prefix=".",
        sidebar_html=_render_sidebar(ordered, modules, None, ".", "types"),
        body_html=body_html,
        icon_path=icon_path,
    )
    (output_dir / "types.html").write_text(html, encoding="utf-8")


def _build_search_index(data: dict[str, Any], ordered: list[str]) -> list[dict[str, str]]:
    modules = data["lua_api"]["modules"]
    items: list[dict[str, str]] = []
    for module_name in ordered:
        namespace = _module_namespace(module_name)
        mod_data = modules[module_name]
        items.append({
            "kind": "module",
            "module": namespace,
            "title": f"lurek.{namespace}",
            "subtitle": _trim(mod_data.get("description")) or "Lua namespace",
            "href": _module_href(module_name),
            "keywords": f"lurek {namespace} module",
        })

        for entry in mod_data.get("functions", []):
            name = str(entry["name"])
            items.append({
                "kind": "function",
                "module": namespace,
                "title": f"lurek.{namespace}.{name}",
                "subtitle": _trim(entry.get("description")) or "Lua function",
                "href": f"{_module_href(module_name)}#fn-{_slug(name)}",
                "keywords": f"{namespace} {name} function {_signature(name, entry)}",
            })

        for class_name, class_data in mod_data.get("classes", {}).items():
            items.append({
                "kind": "class",
                "module": namespace,
                "title": class_name,
                "subtitle": _trim(class_data.get("description")) or f"Class in lurek.{namespace}",
                "href": _class_href(class_name),
                "keywords": f"{class_name} class {namespace} userdata",
            })
            for entry in class_data.get("methods", []):
                name = str(entry["name"])
                items.append({
                    "kind": "method",
                    "module": namespace,
                    "title": f"{class_name}:{name}",
                    "subtitle": _trim(entry.get("description")) or f"Method on {class_name}",
                    "href": f"{_class_href(class_name)}#method-{_slug(name)}",
                    "keywords": f"{class_name} {name} method {namespace} {_signature(name, entry)}",
                })

    for name, signature, description in _CALLBACKS:
        items.append({
            "kind": "callback",
            "module": "callbacks",
            "title": name,
            "subtitle": description,
            "href": f"callbacks.html#callback-{_slug(name)}",
            "keywords": f"callback runtime {signature}",
        })

    for enum_name, values in sorted(data["lua_api"].get("enums", {}).items()):
        items.append({
            "kind": "enum",
            "module": "types",
            "title": enum_name,
            "subtitle": ", ".join(str(value) for value in values[:6]),
            "href": f"types.html#enum-{_slug(enum_name)}",
            "keywords": f"enum {enum_name} {' '.join(str(value) for value in values)}",
        })
    return items


def _write_assets(output_dir: Path, search_index: list[dict[str, str]]) -> str | None:
    assets_dir = output_dir / "assets"
    assets_dir.mkdir(parents=True, exist_ok=True)

    css = f""":root {{
  --lurek-ink: {LUREK_COLORS['ink']};
  --lurek-sky: {LUREK_COLORS['sky']};
  --lurek-frost: {LUREK_COLORS['frost']};
  --lurek-bg: #f5fbff;
  --lurek-surface: #ffffff;
  --lurek-border: #b9dced;
  --lurek-muted: #5f7692;
  --lurek-shadow: 0 18px 45px rgba(23, 56, 95, 0.12);
}}

* {{ box-sizing: border-box; }}
html {{ scroll-behavior: smooth; }}
body {{
  margin: 0;
  color: var(--lurek-ink);
  background:
    radial-gradient(circle at top left, rgba(127, 196, 231, 0.28), transparent 24%),
    radial-gradient(circle at top right, rgba(227, 247, 255, 0.95), transparent 28%),
    linear-gradient(180deg, #fcfeff 0%, var(--lurek-bg) 100%);
  font: 16px/1.6 "Segoe UI", "Trebuchet MS", sans-serif;
}}

a {{ color: inherit; text-decoration: none; }}
pre {{ margin: 0; white-space: pre-wrap; overflow-wrap: anywhere; word-break: break-word; font: 600 0.95rem/1.55 "Cascadia Code", Consolas, monospace; }}
code {{ font-family: "Cascadia Code", Consolas, monospace; }}

.shell {{ min-height: 100vh; display: grid; grid-template-columns: 320px minmax(0, 1fr); }}
.sidebar {{
  position: sticky;
  top: 0;
  height: 100vh;
  overflow-y: auto;
  padding: 28px 20px 32px;
  border-right: 1px solid rgba(23, 56, 95, 0.08);
  background: linear-gradient(180deg, rgba(255,255,255,0.95), rgba(232,246,252,0.92));
  backdrop-filter: blur(12px);
}}

.brand {{ display: grid; grid-template-columns: 60px 1fr; gap: 14px; align-items: center; margin-bottom: 22px; }}
.brand strong {{ display: block; font-size: 1.1rem; }}
.brand span {{ color: var(--lurek-muted); font-size: 0.9rem; }}
.brand-mark, .brand-orb {{ width: 60px; height: 60px; border-radius: 18px; box-shadow: var(--lurek-shadow); }}
.brand-orb {{ background: linear-gradient(135deg, var(--lurek-frost), var(--lurek-sky)); }}

.search-box {{ display: block; margin-bottom: 10px; }}
.search-box span, .search-filters span, .nav-section-title {{ display: block; margin-bottom: 8px; font-size: 0.82rem; font-weight: 700; letter-spacing: 0.08em; text-transform: uppercase; color: var(--lurek-muted); }}
.search-box input, .search-filters select {{
  width: 100%;
  padding: 12px 14px;
  border: 1px solid var(--lurek-border);
  border-radius: 14px;
  background: rgba(255,255,255,0.95);
  color: var(--lurek-ink);
  outline: none;
}}
.search-box input:focus, .search-filters select:focus {{ border-color: var(--lurek-sky); box-shadow: 0 0 0 4px rgba(127, 196, 231, 0.22); }}
.search-filters {{ display: grid; gap: 10px; margin-bottom: 14px; }}

.search-results {{ margin-bottom: 18px; padding: 10px; border: 1px solid var(--lurek-border); border-radius: 16px; background: rgba(255,255,255,0.94); box-shadow: var(--lurek-shadow); }}
.search-result {{ display: block; padding: 10px 12px; border-radius: 12px; }}
.search-result:hover {{ background: rgba(127, 196, 231, 0.12); }}
.search-result strong {{ display: block; }}
.search-result span {{ display: block; color: var(--lurek-muted); font-size: 0.88rem; }}
.search-link {{ display: inline-flex; align-items: center; justify-content: center; width: 100%; margin-bottom: 18px; padding: 11px 12px; border-radius: 14px; background: rgba(127, 196, 231, 0.16); font-weight: 700; }}

.global-nav {{ display: grid; gap: 6px; margin-bottom: 18px; }}
.global-link, .module-nav a {{ display: block; padding: 11px 12px; border-radius: 14px; transition: background 120ms ease, transform 120ms ease; }}
.global-link:hover, .global-link.active, .module-nav a:hover, .module-nav a.active {{ background: rgba(127, 196, 231, 0.16); transform: translateX(2px); }}
.module-nav {{ display: grid; gap: 6px; }}
.nav-name {{ display: block; font-weight: 700; }}
.nav-meta {{ display: block; font-size: 0.82rem; color: var(--lurek-muted); }}

.content {{ padding: 22px clamp(16px, 3vw, 34px) 40px; }}
.hero, .page-header, .section-block, .summary-card, .module-card, .api-card, .class-card, .item-row {{
  background: rgba(255,255,255,0.88);
  border: 1px solid rgba(185, 220, 237, 0.85);
    border-radius: 14px;
    box-shadow: 0 8px 20px rgba(23, 56, 95, 0.06);
}}

.hero, .page-header {{ padding: 16px 18px; margin-bottom: 16px; }}
.eyebrow {{ margin: 0 0 8px; font-size: 0.8rem; font-weight: 800; letter-spacing: 0.14em; text-transform: uppercase; color: var(--lurek-muted); }}
h1, h2, h3 {{ margin: 0; line-height: 1.15; }}
h1 {{ font-size: clamp(1.75rem, 3vw, 2.35rem); letter-spacing: -0.03em; }}
h2 {{ font-size: clamp(1.1rem, 2vw, 1.35rem); }}
h3 {{ font-size: 1rem; }}
.hero-copy, .page-header p {{ max-width: 72ch; }}

.section-block {{ padding: 14px 16px; margin-bottom: 14px; }}
.section-head {{ display: flex; flex-wrap: wrap; justify-content: space-between; gap: 12px 24px; align-items: end; margin-bottom: 18px; }}
.section-head p {{ margin: 0; color: var(--lurek-muted); max-width: 68ch; }}

.item-list {{ display: grid; gap: 10px; }}
.compact-list {{ grid-template-columns: 1fr; }}
.item-row {{ padding: 12px 14px; }}
.item-row-main p, .api-card p {{ margin: 6px 0 0; color: var(--lurek-muted); }}
.item-row-meta {{ display: flex; flex-wrap: wrap; gap: 8px; margin-top: 10px; }}
.item-row-meta span, .item-row-meta a {{ padding: 4px 8px; border-radius: 999px; background: rgba(127, 196, 231, 0.12); font-size: 0.8rem; color: var(--lurek-ink); }}
.api-row .item-row-main {{ display: grid; gap: 4px; }}
.inline-signature {{ margin-top: 6px; padding: 10px 12px; border-radius: 10px; background: linear-gradient(135deg, rgba(227, 247, 255, 0.95), rgba(127, 196, 231, 0.12)); border: 1px solid rgba(127, 196, 231, 0.26); }}
.type-methods {{ margin-top: 14px; }}
.type-methods strong {{ display: block; margin-bottom: 8px; font-size: 0.84rem; text-transform: uppercase; letter-spacing: 0.06em; color: var(--lurek-muted); }}

.api-list {{ display: grid; gap: 10px; }}
.api-card {{ padding: 14px 16px; scroll-margin-top: 18px; }}
.api-card pre, .example-block pre {{ margin-top: 10px; padding: 12px 14px; border-radius: 10px; background: linear-gradient(135deg, rgba(227, 247, 255, 0.95), rgba(127, 196, 231, 0.12)); border: 1px solid rgba(127, 196, 231, 0.26); }}

.stat-row, .api-meta, .crumbs, .token-row {{ display: flex; flex-wrap: wrap; gap: 10px 14px; margin-top: 14px; }}
.api-meta span, .stat-row span, .crumbs a, .crumbs span, .token-row span, .token-row a {{ padding: 6px 10px; border-radius: 999px; background: rgba(127, 196, 231, 0.12); font-size: 0.84rem; color: var(--lurek-ink); }}
.api-meta-header {{ margin-top: 18px; }}
.empty-state {{ padding: 18px; border: 1px dashed var(--lurek-border); border-radius: 18px; color: var(--lurek-muted); }}

.example-block {{ margin-top: 10px; }}
.example-block summary {{ cursor: pointer; color: var(--lurek-muted); font-size: 0.88rem; }}

@media (max-width: 960px) {{
  .shell {{ grid-template-columns: 1fr; }}
  .sidebar {{ position: static; height: auto; border-right: 0; border-bottom: 1px solid rgba(23, 56, 95, 0.08); }}
}}

@media (max-width: 640px) {{
  .content {{ padding-inline: 16px; }}
  .brand {{ grid-template-columns: 48px 1fr; }}
  .brand-mark, .brand-orb {{ width: 48px; height: 48px; }}
    .section-block {{ padding: 12px; }}
}}
"""

    js = """let searchIndexPromise;

function loadSearchIndex() {
  if (!searchIndexPromise) {
        searchIndexPromise = Promise.resolve(Array.isArray(window.LUREK_SEARCH_INDEX) ? window.LUREK_SEARCH_INDEX : []);
  }
  return searchIndexPromise;
}

function uniqueSorted(values) {
  return [...new Set(values.filter(Boolean))].sort((left, right) => left.localeCompare(right));
}

function populateFilter(select, values, placeholder) {
  const current = select.value;
  select.innerHTML = `<option value="">${placeholder}</option>`;
  for (const value of values) {
    const option = document.createElement("option");
    option.value = value;
    option.textContent = value;
    select.appendChild(option);
  }
  select.value = values.includes(current) ? current : "";
}

function renderResults(items, host) {
  if (!items.length) {
    host.hidden = true;
    host.innerHTML = "";
    return;
  }

  host.hidden = false;
  host.innerHTML = items.map((item) => {
    const href = new URL(`${window.LUREK_SITE_BASE}/${item.href}`, window.location.href).toString();
    return `
      <a class="search-result" href="${href}">
        <strong>${item.title}</strong>
        <span>${item.kind} · ${item.module || "global"} · ${item.subtitle}</span>
      </a>
    `;
  }).join("");
}

function renderPageResults(items, host) {
    if (!host) {
        return;
    }

    if (!items.length) {
        host.innerHTML = '<p class="empty-state">No entries match the current query and filters.</p>';
        return;
    }

    host.innerHTML = items.map((item) => {
        const href = new URL(`${window.LUREK_SITE_BASE}/${item.href}`, window.location.href).toString();
        return `
            <article class="api-card">
                <h3><a href="${href}">${item.title}</a></h3>
                <p>${item.subtitle}</p>
                <div class="api-meta"><span>${item.kind}</span><span>${item.module || "global"}</span></div>
            </article>
        `;
    }).join("");
}

function setSearchPageLink(link, query, selectedModule, selectedKind) {
    if (!link) {
        return;
    }

    const params = new URLSearchParams();
    if (query) {
        params.set("q", query);
    }
    if (selectedModule) {
        params.set("module", selectedModule);
    }
    if (selectedKind) {
        params.set("kind", selectedKind);
    }
    const suffix = params.toString() ? `?${params.toString()}` : "";
    link.href = `${window.LUREK_SITE_BASE}/search.html${suffix}`;
}

document.addEventListener("DOMContentLoaded", async () => {
  const input = document.getElementById("search");
  const results = document.getElementById("search-results");
  const moduleFilter = document.getElementById("filter-module");
  const kindFilter = document.getElementById("filter-kind");
    if (!input || !results || !moduleFilter || !kindFilter) {
    return;
  }

    const pageResults = document.getElementById("page-search-results");
    const summary = document.getElementById("search-summary");
    const isSearchPage = Boolean(pageResults);
    const searchLink = document.createElement("a");
    searchLink.id = "search-page-link";
    searchLink.className = "search-link";
    searchLink.textContent = "Open full search page";
    results.insertAdjacentElement("afterend", searchLink);

  const items = await loadSearchIndex();
  populateFilter(moduleFilter, uniqueSorted(items.map((item) => item.module)), "All modules");
  populateFilter(kindFilter, uniqueSorted(items.map((item) => item.kind)), "All types");

    if (isSearchPage) {
        const params = new URLSearchParams(window.location.search);
        input.value = params.get("q") || "";
        moduleFilter.value = params.get("module") || "";
        kindFilter.value = params.get("kind") || "";
    }

  const applySearch = () => {
    const query = input.value.trim().toLowerCase();
    const selectedModule = moduleFilter.value;
    const selectedKind = kindFilter.value;
        setSearchPageLink(searchLink, query, selectedModule, selectedKind);
    const filtered = items
      .filter((item) => {
        if (selectedModule && item.module !== selectedModule) {
          return false;
        }
        if (selectedKind && item.kind !== selectedKind) {
          return false;
        }
        if (!query) {
          return selectedModule || selectedKind;
        }
        const haystack = `${item.title} ${item.subtitle} ${item.keywords}`.toLowerCase();
        return haystack.includes(query);
      })
      .slice(0, 50);
    renderResults(filtered, results);

        if (isSearchPage) {
            renderPageResults(filtered, pageResults);
            if (summary) {
                summary.textContent = filtered.length
                    ? `${filtered.length} entries match the current query.`
                    : "No entries match the current query and filters.";
            }
            const params = new URLSearchParams();
            if (query) {
                params.set("q", query);
            }
            if (selectedModule) {
                params.set("module", selectedModule);
            }
            if (selectedKind) {
                params.set("kind", selectedKind);
            }
            const suffix = params.toString() ? `?${params.toString()}` : "";
            window.history.replaceState({}, "", `${window.location.pathname}${suffix}`);
        }
  };

  input.addEventListener("input", applySearch);
  moduleFilter.addEventListener("change", applySearch);
  kindFilter.addEventListener("change", applySearch);
    input.addEventListener("keydown", (event) => {
        if (event.key === "Enter") {
            window.location.href = searchLink.href;
        }
    });

    if (isSearchPage) {
        applySearch();
    }

  document.addEventListener("click", (event) => {
    if (!results.contains(event.target) && event.target !== input && event.target !== moduleFilter && event.target !== kindFilter) {
      if (!input.value.trim() && !moduleFilter.value && !kindFilter.value) {
        renderResults([], results);
      }
    }
  });
});
"""

    (assets_dir / "style.css").write_text(css, encoding="utf-8")
    (assets_dir / "app.js").write_text(js, encoding="utf-8")
    (assets_dir / "search-index.js").write_text(
        "window.LUREK_SEARCH_INDEX = " + json.dumps(search_index, ensure_ascii=False) + ";\n",
        encoding="utf-8",
    )

    for candidate in ICON_CANDIDATES:
        if candidate.exists():
            target = assets_dir / "lurek-logo.png"
            shutil.copy2(candidate, target)
            return "assets/lurek-logo.png"
    return None


def generate_site(data: dict[str, Any], output_dir: Path) -> None:
    if output_dir.exists():
        shutil.rmtree(output_dir)
    (output_dir / "modules").mkdir(parents=True, exist_ok=True)
    (output_dir / "classes").mkdir(parents=True, exist_ok=True)

    modules = data["lua_api"]["modules"]
    ordered = _ordered_modules(modules)
    callable_examples, _ = _build_example_indexes()
    search_index = _build_search_index(data, ordered)
    icon_path = _write_assets(output_dir, search_index)

    _render_home(data, ordered, output_dir, icon_path, callable_examples)
    _render_callbacks_page(output_dir, ordered, modules, icon_path)
    _render_search_page(ordered, modules, output_dir, icon_path)
    _render_types_page(data, ordered, output_dir, icon_path)

    for module_name in ordered:
        mod_data = modules[module_name]
        _render_module_page(module_name, mod_data, ordered, modules, output_dir, icon_path, callable_examples)
        for class_name, class_data in mod_data.get("classes", {}).items():
            _render_class_page(class_name, module_name, class_data, ordered, modules, output_dir, icon_path, callable_examples)

    (output_dir / "search-index.json").write_text(
        json.dumps(search_index, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", default=str(INPUT_FILE))
    parser.add_argument("--output", default=str(OUTPUT_DIR))
    args = parser.parse_args()

    input_path = Path(args.input)
    if not input_path.exists():
        print(f"[ERROR] Not found: {input_path}", file=sys.stderr)
        return 1

    data = json.loads(input_path.read_text(encoding="utf-8"))
    output_dir = Path(args.output)
    generate_site(data, output_dir)

    module_count = len(data["lua_api"]["modules"])
    total_items = data["lua_api"]["summary"]["total_functions"]
    print(f"[OK] Generated {output_dir} ({module_count} modules, {total_items} API items)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
