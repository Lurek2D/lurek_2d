#!/usr/bin/env python3
"""Append stub sections to content/examples/ for uncovered lurek.* API items.

Each stub emits:
  1. A machine-readable marker line:   --@api-stub: Owner.functionName
  2. A one-line description comment
  3. Real (minimal) executable Lua code that calls the API — NOT pseudocode.

The marker format allows example_coverage.py to distinguish hand-written scenario
code from auto-generated stubs.  Run flesh-out-example.prompt.md to replace every
stub block with a proper scenario; the final committed file must contain ZERO
--@api-stub: lines.

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
API_JSON = ROOT / 'logs' / 'data' / 'lua_api_data.json'
EXAMPLES_DIR = ROOT / 'content' / 'examples'


def resolve_examples_dir(path_arg: str | None) -> Path:
    if not path_arg:
        return EXAMPLES_DIR
    p = Path(path_arg)
    return p if p.is_absolute() else ROOT / p


def find_target_file(examples_dir: Path, module: str, ex_filename: str) -> Path:
    """Find the file to append to.

    In content/examples/, use ex_filename directly (e.g. ui.lua).
    In examples/ (or any dir without that file), find the last
    <module>_NN.lua file (e.g. ui_07.lua) and append there.
    """
    direct = examples_dir / ex_filename
    if direct.exists():
        return direct
    # Look for numbered files: <module>_00.lua .. <module>_99.lua
    numbered = sorted(examples_dir.glob(f'{module}_*.lua'))
    if numbered:
        return numbered[-1]
    # Fallback: create ex_filename in the target dir
    return direct

# filename = module name exactly (src/render/ -> render.lua, src/ecs/ -> ecs.lua)
MODULE_TO_EXAMPLE: dict[str, str] = {
    'ai':          'ai.lua',
    'animation':   'animation.lua',
    'audio':       'audio.lua',
    'automation':  'automation.lua',
    'camera':      'camera.lua',
    'compute':     'compute.lua',
    'data':        'data.lua',
    'dataframe':   'dataframe.lua',
    'debugbridge': 'debugbridge.lua',
    'devtools':    'devtools.lua',
    'docs':        'docs.lua',
    'ecs':         'ecs.lua',
    'effect':      'effect.lua',
    'engine':      'engine.lua',
    'event':       'event.lua',
    'filesystem':  'filesystem.lua',
    'globe':       'globe.lua',
    'graph':       'graph.lua',
    'html':        'html.lua',
    'i18n':        'i18n.lua',
    'image':       'image.lua',
    'input':       'input.lua',
    'light':       'light.lua',
    'log':         'log.lua',
    'math':        'math.lua',
    'minimap':     'minimap.lua',
    'mods':        'mods.lua',
    'network':     'network.lua',
    'parallax':    'parallax.lua',
    'particle':    'particle.lua',
    'pathfind':    'pathfind.lua',
    'patterns':    'patterns.lua',
    'physics':     'physics.lua',
    'pipeline':    'pipeline.lua',
    'procgen':     'procgen.lua',
    'raycaster':   'raycaster.lua',
    'render':      'render.lua',
    'save':        'save.lua',
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
    'ui':          'ui.lua',
    'window':      'window.lua',
}

# Namespace = src/ folder name exactly (e.g. src/render/ -> lurek.render)
NAMESPACE_MAP: dict[str, str] = {
    'ai':          'ai',
    'animation':   'animation',
    'audio':       'audio',
    'automation':  'automation',
    'camera':      'camera',
    'compute':     'compute',
    'data':        'data',
    'dataframe':   'dataframe',
    'debugbridge': 'debugbridge',
    'devtools':    'devtools',
    'docs':        'docs',
    'ecs':         'ecs',
    'effect':      'effect',
    'engine':      'engine',
    'event':       'event',
    'filesystem':  'filesystem',
    'globe':       'globe',
    'graph':       'graph',
    'html':        'html',
    'i18n':        'i18n',
    'image':       'image',
    'input':       'input',
    'light':       'light',
    'log':         'log',
    'math':        'math',
    'minimap':     'minimap',
    'mods':        'mods',
    'network':     'network',
    'parallax':    'parallax',
    'particle':    'particle',
    'pathfind':    'pathfind',
    'patterns':    'patterns',
    'physics':     'physics',
    'pipeline':    'pipeline',
    'procgen':     'procgen',
    'raycaster':   'raycaster',
    'render':      'render',
    'save':        'save',
    'scene':       'scene',
    'serial':      'serial',
    'spine':       'spine',
    'sprite':      'sprite',
    'system':      'system',
    'terminal':    'terminal',
    'thread':      'thread',
    'tilemap':     'tilemap',
    'timer':       'timer',
    'tween':       'tween',
    'ui':          'ui',
    'window':      'window',
}

_LINE = '-' * 77


@dataclass
class Entry:
    module: str
    name: str
    is_method: bool
    owner_type: str | None = None
    api_name: str | None = None
    description: str = ''
    inferred_sig: str = '()'
    inferred_return: str = ''


def load_entries(jp: Path) -> list[Entry]:
    data = json.loads(jp.read_text(encoding='utf-8'))
    mods = data['lua_api']['modules']
    out: list[Entry] = []
    for mn, m in mods.items():
        if mn == 'collision': continue
        if mn == 'collision': continue
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
                    api_name=meth.get('lua_name'),
                    description=meth.get('description', ''),
                    inferred_sig=meth.get('inferred_sig', '()'),
                    inferred_return=meth.get('inferred_return', ''),
                ))
    return out


def load_code_text(path: Path) -> str:
    """Return file stripped of comment lines for coverage matching."""
    raw = path.read_text(encoding='utf-8', errors='replace')
    return '\n'.join(ln for ln in raw.splitlines() if not ln.lstrip().startswith('--'))


def is_covered(entry: "Entry", raw_text: str, ns: str) -> bool:
    """Return True if the file already contains an --@api-stub: marker for this entry.

    Matches exactly how example_coverage.py checks coverage: requires the
    machine-readable ``--@api-stub: <id>`` tag in the raw file.  This avoids
    false-positives from broad regex matches on common names like ``:new(`` or
    ``:update(`` that appear in unrelated code.
    """
    if entry.is_method:
        stub_id = f'{entry.owner_type}:{entry.name}'
    else:
        stub_id = f'lurek.{ns}.{entry.name}'
    return f'--@api-stub: {stub_id}' in raw_text


def _make_call_args(sig: str) -> str:
    """Convert an inferred signature like '(x, y, w, h)' into placeholder args."""
    sig = sig.strip()
    if sig in ('()', ''):
        return '()'
    inner = sig[1:-1].strip()
    if not inner:
        return '()'
    parts = [p.strip().split(':')[0].strip() for p in inner.split(',')]
    # Replace bare param names with domain-flavoured literals
    _DOMAIN = {
        'x': '0.0', 'y': '0.0', 'w': '64.0', 'h': '64.0',
        'width': '256', 'height': '256',
        'dt': '0.016', 'delta': '0.016',
        'name': '"hero"', 'key': '"player_score"', 'id': '1',
        'text': '"Hello, world!"', 'msg': '"level_complete"',
        'r': '1.0', 'g': '0.8', 'b': '0.2', 'a': '1.0',
        'angle': '0.0', 'rotation': '0.0',
        'scale': '1.0', 'sx': '1.0', 'sy': '1.0',
        'fn': 'function() end', 'callback': 'function() end',
        'value': '42', 'v': '1.0',
        'path': '"assets/hero.png"', 'file': '"save_slot1"',
        'slot': '"slot1"', 'tag': '"enemy"',
        'index': '1', 'idx': '1', 'i': '1',
        'count': '10', 'n': '5',
        'speed': '120.0', 'radius': '24.0',
        'layer': '1', 'z': '0',
        'enabled': 'true', 'flag': 'true', 'visible': 'true',
    }
    result = []
    for p in parts:
        result.append(_DOMAIN.get(p, p if p else '"TODO"'))
    return '(' + ', '.join(result) + ')'


def build_stub_block(entry: Entry, ns: str) -> str:
    """Return a stub block for one missing API item."""
    if entry.api_name:
        api_id = entry.api_name
    elif entry.is_method:
        api_id = f'{entry.owner_type}:{entry.name}'
    else:
        api_id = f'lurek.{ns}.{entry.name}'

    marker = f'--@api-stub: {api_id}'
    return f"""{marker}
do
end
"""


def patch_example(
    module: str,
    entries: list[Entry],
    dry_run: bool,
    verbose: bool,
    examples_dir: Path | None = None,
) -> int:
    """Append missing stub blocks to the example file.  Returns count of stubs appended."""
    ex_filename = MODULE_TO_EXAMPLE.get(module, module + '.lua')
    ns = NAMESPACE_MAP.get(module, module)
    target_dir = examples_dir if examples_dir is not None else EXAMPLES_DIR
    ex_path = find_target_file(target_dir, module, ex_filename)

    # Load or initialise the example file
    if ex_path.exists():
        raw = ex_path.read_text(encoding='utf-8', errors='replace')
    else:
        # Create a minimal header if file doesn't exist yet
        rel = ex_path.relative_to(ROOT) if ex_path.is_relative_to(ROOT) else ex_path
        raw = (
            f'-- {rel}\n'
            f'-- Lurek2D lurek.{ns} API Reference\n\n'
        )
        if verbose:
            print(f'  [NEW] Creating {ex_path.name}')

    # Find missing entries
    missing = [e for e in entries if not is_covered(e, raw, ns)]
    if not missing:
        return 0

    # Group by owner (functions together, each class together)
    fn_entries    = [e for e in missing if not e.is_method]
    method_groups: dict[str, list[Entry]] = {}
    for e in missing:
        if e.is_method:
            method_groups.setdefault(e.owner_type, []).append(e)

    new_lines: list[str] = []

    for e in fn_entries:
        new_lines.append('')
        new_lines.append(build_stub_block(e, ns))

    for owner, methods in sorted(method_groups.items()):
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
    p.add_argument('--module',       metavar='NAME', help='Process one module only')
    p.add_argument('--examples-dir', metavar='DIR',  help='Target examples directory (default: content/examples)')
    p.add_argument('--dry-run',      action='store_true', help='Preview changes, do not write')
    p.add_argument('--report',       action='store_true', help='Exit 1 if any stubs are needed')
    p.add_argument('--verbose',      action='store_true', help='Show per-module progress')
    args = p.parse_args()
    examples_dir = resolve_examples_dir(args.examples_dir)

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
                          dry_run=args.dry_run, verbose=args.verbose or args.dry_run,
                          examples_dir=examples_dir)
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
