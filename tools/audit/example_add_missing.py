#!/usr/bin/env python3
"""Append stub sections to content/examples/ for uncovered lurek.* API items.

For each module with <100% coverage, reads the matching example file and appends
a commented stub block for every missing function or method.  The stubs are
intentionally minimal — run `.github/prompts/flesh-out-example.md` to ask an AI
to expand each stub into a real working example.

Usage:
    python tools/audit/example_add_missing.py                  # patch all modules
    python tools/audit/example_add_missing.py --module timer   # one module only
    python tools/audit/example_add_missing.py --dry-run        # preview, no writes
    python tools/audit/example_add_missing.py --report         # exit 1 if stubs needed

Exit codes:
    0 — nothing to add (all 100%) or dry-run completed
    1 — one or more stubs were appended (or --report with gaps)
"""
from __future__ import annotations
import argparse, json, re, sys
from dataclasses import dataclass, field
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
API_JSON = ROOT / 'docs' / 'logs' / 'lua_api_data.json'
EXAMPLES_DIR = ROOT / 'content' / 'examples'

# Canonical mapping: JSON module key → content/examples/<file>.lua
MODULE_TO_EXAMPLE: dict[str, str] = {
    'ai':          'ai.lua',
    'animation':   'animation.lua',
    'audio':       'audio.lua',
    'automation':  'automation.lua',
    'camera':      'camera.lua',
    'collision':   'collision.lua',
    'compute':     'compute.lua',
    'data':        'data.lua',
    'dataframe':   'dataframe.lua',
    'debugbridge': 'debugbridge.lua',
    'devtools':    'devtools.lua',
    'docs':        'docs.lua',
    'ecs':         'entity.lua',
    'effect':      'fx.lua',
    'engine':      'engine.lua',
    'event':       'event.lua',
    'filesystem':  'filesystem.lua',
    'graph':       'graph.lua',
    'i18n':        'localization.lua',
    'image':       'image.lua',
    'input':       'input.lua',
    'light':       'light.lua',
    'log':         'log.lua',
    'math':        'math.lua',
    'minimap':     'minimap.lua',
    'mods':        'modding.lua',
    'network':     'network.lua',
    'parallax':    'parallax.lua',
    'particle':    'particle.lua',
    'pathfind':    'pathfinding.lua',
    'patterns':    'patterns.lua',
    'physics':     'physics.lua',
    'pipeline':    'pipeline.lua',
    'procgen':     'procgen.lua',
    'raycaster':   'raycaster.lua',
    'render':      'graphics.lua',
    'save':        'savegame.lua',
    'scene':       'scene.lua',
    'serial':      'serial.lua',
    'spine':       'spine.lua',
    'sprite':      'sprite.lua',
    'system':      'system.lua',
    'terminal':    'terminal.lua',
    'thread':      'thread.lua',
    'tilemap':     'tilemap.lua',
    'timer':       'timer.lua',
    'tween':       'tween.lua',
    'ui':          'gui.lua',
    'window':      'window.lua',
}

NAMESPACE_MAP: dict[str, str] = {
    'ai': 'ai', 'animation': 'animation', 'audio': 'audio',
    'automation': 'simulator', 'camera': 'camera', 'collision': 'collision',
    'compute': 'compute', 'data': 'data', 'dataframe': 'dataframe',
    'debugbridge': 'debugbridge', 'devtools': 'devtools', 'docs': 'docs',
    'ecs': 'entity', 'effect': 'overlay', 'engine': 'engine',
    'event': 'signal', 'filesystem': 'fs', 'graph': 'graph',
    'i18n': 'localization', 'image': 'img', 'input': 'keyboard',
    'light': 'light', 'log': 'log', 'math': 'math', 'minimap': 'minimap',
    'mods': 'modding', 'network': 'network', 'parallax': 'parallax',
    'particle': 'particles', 'pathfind': 'pathfinding', 'patterns': 'patterns',
    'physics': 'physics', 'pipeline': 'pipeline', 'procgen': 'procgen',
    'raycaster': 'raycaster', 'render': 'graphic', 'save': 'savegame',
    'scene': 'scene', 'serial': 'codec', 'spine': 'spine', 'sprite': 'sprite',
    'system': 'platform', 'terminal': 'terminal', 'thread': 'thread',
    'tilemap': 'tilemap', 'timer': 'time', 'tween': 'tween',
    'ui': 'ui', 'window': 'window',
}

_LINE = '─' * 77


@dataclass
class Entry:
    module: str
    name: str
    is_method: bool
    owner_type: str
    description: str = ''
    inferred_sig: str = '()'
    inferred_return: str = ''


def load_entries(jp: Path) -> list[Entry]:
    data = json.loads(jp.read_text(encoding='utf-8'))
    mods = data['lua_api']['modules']
    out: list[Entry] = []
    for mn, m in mods.items():
        for fn in (m.get('functions') or []):
            out.append(Entry(
                module=mn, name=fn['name'], is_method=False, owner_type='',
                description=fn.get('description', ''),
                inferred_sig=fn.get('inferred_sig', '()'),
                inferred_return=fn.get('inferred_return', ''),
            ))
        for cn, cls in (m.get('classes') or {}).items():
            for meth in (cls.get('methods') or []):
                out.append(Entry(
                    module=mn, name=meth['name'], is_method=True, owner_type=cn,
                    description=meth.get('description', ''),
                    inferred_sig=meth.get('inferred_sig', '()'),
                    inferred_return=meth.get('inferred_return', ''),
                ))
    return out


def load_code_text(path: Path) -> str:
    """Return file stripped of comment lines for coverage matching."""
    raw = path.read_text(encoding='utf-8', errors='replace')
    return '\n'.join(ln for ln in raw.splitlines() if not ln.lstrip().startswith('--'))


def is_covered(entry: Entry, code_text: str) -> bool:
    if entry.is_method:
        pat = r':' + re.escape(entry.name) + r'\s*\('
    else:
        pat = r'\b' + re.escape(entry.name) + r'\s*\('
    return bool(re.search(pat, code_text))


def _ruler(label: str) -> str:
    pad = max(0, 77 - len(label) - 4)
    return f'-- ── {label} ' + '─' * pad


def build_stub_block(entry: Entry, ns: str) -> str:
    """Return the Lua comment block for one missing API item."""
    lines: list[str] = []
    lines.append(_ruler(f'lurek.{ns}.{entry.name}' if not entry.is_method
                        else f'{entry.owner_type}:{entry.name}'))
    if entry.description:
        lines.append(f'-- {entry.description}')
    ret_hint = f'  -- -> {entry.inferred_return}' if entry.inferred_return and entry.inferred_return != 'nil' else ''
    if entry.is_method:
        lines.append(f'-- local obj = ...  -- replace with your {entry.owner_type} instance')
        lines.append(f'-- obj:{entry.name}{entry.inferred_sig}{ret_hint}')
    else:
        lines.append(f'-- lurek.{ns}.{entry.name}{entry.inferred_sig}{ret_hint}')
    return '\n'.join(lines)


def patch_example(
    module: str,
    entries: list[Entry],
    dry_run: bool,
    verbose: bool,
) -> int:
    """Append missing stub blocks to the example file.  Returns count of stubs appended."""
    ex_filename = MODULE_TO_EXAMPLE.get(module, module + '.lua')
    ns = NAMESPACE_MAP.get(module, module)
    ex_path = EXAMPLES_DIR / ex_filename

    # Load or initialise the example file
    if ex_path.exists():
        raw = ex_path.read_text(encoding='utf-8', errors='replace')
        code_text = load_code_text(ex_path)
    else:
        # Create a minimal header if file doesn't exist yet
        raw = (
            f'-- content/examples/{ex_filename}\n'
            f'-- Lurek2D lurek.{ns} API Reference\n'
            f'-- Run with: cargo run -- content/examples/{ex_filename[:-4]}\n\n'
        )
        code_text = ''
        if verbose:
            print(f'  [NEW] Creating {ex_filename}')

    # Find missing entries
    missing = [e for e in entries if not is_covered(e, code_text)]
    if not missing:
        return 0

    # Group by owner (functions together, each class together)
    fn_entries    = [e for e in missing if not e.is_method]
    method_groups: dict[str, list[Entry]] = {}
    for e in missing:
        if e.is_method:
            method_groups.setdefault(e.owner_type, []).append(e)

    new_lines: list[str] = [
        '',
        f'-- {"═" * 77}',
        f'-- STUBS: {len(missing)} uncovered lurek.{ns} API item(s)',
        f'-- Generated by tools/audit/example_add_missing.py',
        f'-- Run .github/prompts/flesh-out-example.md to expand each stub.',
        f'-- {"═" * 77}',
    ]

    for e in fn_entries:
        new_lines.append('')
        new_lines.append(build_stub_block(e, ns))

    for owner, methods in sorted(method_groups.items()):
        new_lines.append('')
        new_lines.append(f'-- {"─" * 77}')
        new_lines.append(f'-- {owner} methods')
        new_lines.append(f'-- {"─" * 77}')
        for e in methods:
            new_lines.append('')
            new_lines.append(build_stub_block(e, ns))

    appended = '\n'.join(new_lines) + '\n'

    if verbose or dry_run:
        verb = 'DRY-RUN' if dry_run else 'PATCHING'
        print(f'  [{verb}] {ex_filename}: +{len(missing)} stub(s)')
        if dry_run:
            for line in new_lines[:20]:
                print('    ' + line)
            if len(new_lines) > 20:
                print(f'    ... ({len(new_lines) - 20} more lines)')

    if not dry_run:
        ex_path.write_text(raw.rstrip('\n') + '\n' + appended,
                           encoding='utf-8', newline='\n')

    return len(missing)


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('--module',   metavar='NAME', help='Process one module only')
    p.add_argument('--dry-run',  action='store_true', help='Preview changes, do not write')
    p.add_argument('--report',   action='store_true', help='Exit 1 if any stubs are needed')
    p.add_argument('--verbose',  action='store_true', help='Show per-module progress')
    args = p.parse_args()

    if not API_JSON.exists():
        print(f'ERROR: {API_JSON} not found — run python tools/gen_all_docs.py first')
        return 1

    all_entries = load_entries(API_JSON)

    # Group entries by module
    by_module: dict[str, list[Entry]] = {}
    for e in all_entries:
        by_module.setdefault(e.module, []).append(e)

    if args.module:
        modules = [args.module] if args.module in by_module else []
        if not modules:
            print(f'ERROR: module "{args.module}" not found in API data')
            return 1
    else:
        modules = sorted(by_module.keys())

    total_stubs = 0
    for mod in modules:
        n = patch_example(mod, by_module.get(mod, []),
                          dry_run=args.dry_run, verbose=args.verbose or args.dry_run)
        total_stubs += n

    if total_stubs:
        action = 'would append' if args.dry_run else 'appended'
        print(f'\nDone. {action} {total_stubs} stub(s) across {len(modules)} module(s).')
        print('Next step: run .github/prompts/flesh-out-example.md to expand stubs.')
    else:
        print('All example files are already 100% covered — nothing to add.')

    if args.report and total_stubs:
        return 1
    return 0 if not args.dry_run else 0


if __name__ == '__main__':
    sys.exit(main())
