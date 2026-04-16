#!/usr/bin/env python3
"""Cross-reference content/examples/ scripts against the lurek.* Lua API.

Reports which API functions are covered by an example and which are not.
Reads the pre-built docs/logs/lua_api_data.json (run gen_all_docs.py first).

Usage:
    python tools/audit/example_coverage.py                  # summary table
    python tools/audit/example_coverage.py --missing        # list uncovered items
    python tools/audit/example_coverage.py --module timer   # one module
    python tools/audit/example_coverage.py --json           # machine-readable
    python tools/audit/example_coverage.py --report         # exit 1 if any gap (CI gate)

Exit codes:
    0 — all examples 100% covered
    1 — one or more gaps exist (or --report flag set with gaps)
"""
from __future__ import annotations
import argparse, json, re, sys
from dataclasses import dataclass, field
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
API_JSON = ROOT / 'docs' / 'logs' / 'lua_api_data.json'
EXAMPLES_DIR = ROOT / 'content' / 'examples'

# Maps JSON module key  →  content/examples/<file>.lua
# JSON keys come from src/lua_api/<module>_api.rs luna.set("namespace", tbl)
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
    'ecs':         'entity.lua',       # lurek.entity
    'effect':      'fx.lua',           # lurek.overlay
    'engine':      'engine.lua',
    'event':       'event.lua',
    'filesystem':  'filesystem.lua',   # lurek.fs
    'graph':       'graph.lua',
    'i18n':        'localization.lua', # lurek.localization
    'image':       'image.lua',        # lurek.img
    'input':       'input.lua',        # lurek.keyboard
    'light':       'light.lua',
    'log':         'log.lua',
    'math':        'math.lua',
    'minimap':     'minimap.lua',
    'mods':        'modding.lua',      # lurek.modding
    'network':     'network.lua',
    'parallax':    'parallax.lua',
    'particle':    'particle.lua',     # lurek.particles
    'pathfind':    'pathfinding.lua',  # lurek.pathfinding
    'patterns':    'patterns.lua',
    'physics':     'physics.lua',
    'pipeline':    'pipeline.lua',
    'procgen':     'procgen.lua',
    'raycaster':   'raycaster.lua',
    'render':      'graphics.lua',     # lurek.graphic
    'save':        'savegame.lua',     # lurek.savegame
    'scene':       'scene.lua',
    'serial':      'serial.lua',       # lurek.codec
    'spine':       'spine.lua',
    'sprite':      'sprite.lua',       # may not exist yet — shows as missing
    'system':      'system.lua',       # lurek.platform — may not exist yet
    'terminal':    'terminal.lua',
    'thread':      'thread.lua',
    'tilemap':     'tilemap.lua',
    'timer':       'timer.lua',        # lurek.time
    'tween':       'tween.lua',
    'ui':          'gui.lua',          # lurek.ui
    'window':      'window.lua',
}

# Maps JSON module key  →  lurek.* namespace used in example files
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


@dataclass
class ApiEntry:
    module: str
    name: str          # bare Lua method/function name, e.g. "getDelta"
    is_method: bool
    owner_type: str    # class name for methods, e.g. "Scheduler"
    example_file: str
    description: str = ''
    inferred_sig: str = '()'


@dataclass
class ModuleCov:
    key: str
    example_file: str
    namespace: str = ''
    total: int = 0
    covered: int = 0
    missing: list = field(default_factory=list)

    @property
    def pct(self) -> float:
        return (self.covered / self.total * 100) if self.total else 100.0


def load_entries(jp: Path) -> list[ApiEntry]:
    data = json.loads(jp.read_text(encoding='utf-8'))
    mods = data['lua_api']['modules']
    out: list[ApiEntry] = []
    for mn, m in mods.items():
        ex = MODULE_TO_EXAMPLE.get(mn, mn + '.lua')
        for fn in (m.get('functions') or []):
            out.append(ApiEntry(
                module=mn, name=fn['name'], is_method=False,
                owner_type='', example_file=ex,
                description=fn.get('description', ''),
                inferred_sig=fn.get('inferred_sig', '()'),
            ))
        for cn, cls in (m.get('classes') or {}).items():
            for meth in (cls.get('methods') or []):
                out.append(ApiEntry(
                    module=mn, name=meth['name'], is_method=True,
                    owner_type=cn, example_file=ex,
                    description=meth.get('description', ''),
                    inferred_sig=meth.get('inferred_sig', '()'),
                ))
    return out


def load_texts(d: Path) -> dict[str, str]:
    """Load all .lua files, stripping comment lines for matching."""
    out: dict[str, str] = {}
    for p in d.glob('*.lua'):
        raw = p.read_text(encoding='utf-8', errors='replace')
        # Keep only non-comment lines for coverage matching
        code_lines = [ln for ln in raw.splitlines() if not ln.lstrip().startswith('--')]
        out[p.name] = '\n'.join(code_lines)
    return out


def build_cov(entries: list[ApiEntry], texts: dict[str, str]) -> dict[str, ModuleCov]:
    bk: dict[str, ModuleCov] = {}
    for e in entries:
        key = e.module
        if key not in bk:
            bk[key] = ModuleCov(
                key=key,
                example_file=e.example_file,
                namespace=NAMESPACE_MAP.get(key, key),
            )
        mc = bk[key]
        mc.total += 1
        text = texts.get(mc.example_file, '')
        if not text:
            mc.missing.append(e.name)
            continue
        # Methods: :methodName(   Functions: word-boundary match (catches aliases)
        if e.is_method:
            pat = r':' + re.escape(e.name) + r'\s*\('
        else:
            pat = r'\b' + re.escape(e.name) + r'\s*\('
        if re.search(pat, text):
            mc.covered += 1
        else:
            mc.missing.append(e.name)
    return bk


def print_summary(bk: dict[str, ModuleCov], filt: str | None = None) -> None:
    print(f"\n{'Module':<18} {'Namespace':<18} {'Example':<22} {'Cov':>4} {'Tot':>4} {'%':>5}")
    print('-' * 76)
    tc = ta = 0
    for k, mc in sorted(bk.items()):
        if filt and filt.lower() not in k.lower():
            continue
        flag = ' MISSING' if not (EXAMPLES_DIR / mc.example_file).exists() else ''
        ns = f"lurek.{mc.namespace}"
        print(f'{k:<18} {ns:<18} {mc.example_file:<22} {mc.covered:>4} {mc.total:>4} {mc.pct:>4.0f}%{flag}')
        tc += mc.covered
        ta += mc.total
    print('-' * 76)
    total_pct = (tc / ta * 100) if ta else 100.0
    print(f"{'TOTAL':<58} {tc:>4} {ta:>4} {total_pct:>4.0f}%")


def print_missing(bk: dict[str, ModuleCov], filt: str | None = None) -> None:
    for k, mc in sorted(bk.items()):
        if filt and filt.lower() not in k.lower():
            continue
        if not mc.missing:
            continue
        exists = (EXAMPLES_DIR / mc.example_file).exists()
        status = '' if exists else ' (FILE MISSING)'
        print(f'\n[{k}] lurek.{mc.namespace} -> {mc.example_file}{status} ({mc.pct:.0f}%)')
        for fn in sorted(mc.missing):
            print(f'  - {fn}')


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('--json',    action='store_true', help='Machine-readable JSON output')
    p.add_argument('--missing', action='store_true', help='Show only missing items per module')
    p.add_argument('--summary', action='store_true', help='Show summary table (default)')
    p.add_argument('--report',  action='store_true', help='CI gate: exit 1 if any gaps exist')
    p.add_argument('--module',  metavar='NAME',      help='Filter to one module')
    args = p.parse_args()

    if not API_JSON.exists():
        print(f'ERROR: {API_JSON} not found — run python tools/gen_all_docs.py first')
        return 1

    entries = load_entries(API_JSON)
    texts   = load_texts(EXAMPLES_DIR)
    bk      = build_cov(entries, texts)

    if args.module:
        bk = {k: v for k, v in bk.items() if args.module.lower() in k.lower()}

    has_gaps = any(mc.pct < 100.0 for mc in bk.values())

    if args.json:
        print(json.dumps({
            k: {
                'namespace':    f"lurek.{mc.namespace}",
                'example_file': mc.example_file,
                'file_exists':  (EXAMPLES_DIR / mc.example_file).exists(),
                'covered':      mc.covered,
                'total':        mc.total,
                'pct':          round(mc.pct, 1),
                'missing':      sorted(mc.missing),
            }
            for k, mc in sorted(bk.items())
        }, indent=2))
    elif args.missing:
        print_missing(bk)
    else:
        print_summary(bk, filt=args.module)

    if args.report and has_gaps:
        gaps = sum(1 for mc in bk.values() if mc.pct < 100.0)
        print(f'\n[REPORT] {gaps} module(s) below 100% example coverage.')
        return 1

    return 1 if has_gaps else 0


if __name__ == '__main__':
    sys.exit(main())
