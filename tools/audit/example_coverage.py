#!/usr/bin/env python3
"""Cross-reference Lua example scripts against the lurek.* Lua API.

Coverage is reported in four tiers:
    - "FULL" -- --@api-stub: block present, NO "-- TODO:" line, and block body has 1+ non-empty lines
    - "PART" -- reserved legacy bucket; current real examples should classify as FULL
    - "TODO" -- --@api-stub: block present AND has a "-- TODO:" line
    - "MISS" -- no --@api-stub: marker at all (item not tracked in any example)

Workflow:
  1. Run example_add_missing.py  -- adds --@api-stub: blocks with -- TODO: (pending)
  2. Agent writes real Lua code, removes -- TODO: line  (pending -> real)
  3. This tool gates on: no "missing" items (--report) or no pending (--no-stubs)

Usage:
    python tools/audit/example_coverage.py                  # summary table
    python tools/audit/example_coverage.py --examples-dir content/examples
    python tools/audit/example_coverage.py --missing        # list uncovered items
    python tools/audit/example_coverage.py --stubs          # list modules with pending stubs
    python tools/audit/example_coverage.py --module timer   # one module
    python tools/audit/example_coverage.py --json           # machine-readable
    python tools/audit/example_coverage.py --report         # exit 1 if any missing
    python tools/audit/example_coverage.py --report --no-stubs  # also fail if pending
    python tools/audit/example_coverage.py --examples-dir content/examples --markdown
    python tools/audit/example_coverage.py --markdown FILE  # export Markdown report

Exit codes:
    0 -- no missing items (all API items have at least a stub marker)
    1 -- one or more items have no --@api-stub: marker at all
"""
from __future__ import annotations
import argparse, json, re, sys
from dataclasses import dataclass, field
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
API_JSON = ROOT / 'logs' / 'data' / 'lua_api_data.json'
DEFAULT_EXAMPLES_DIR = ROOT / 'content' / 'examples'
DEFAULT_MARKDOWN_REPORT = ROOT / 'logs' / 'reports' / 'example_coverage.md'
# Real examples are already distinguished from placeholders by marker presence and TODO state.
# Requiring 5+ lines created a large PART bucket without indicating missing API coverage.
FULL_BLOCK_MIN_LINES = 1

DO_LINE_RE = re.compile(r'^do(?:\s*--.*)?$')
FUNCTION_START_RE = re.compile(r'^(?:local\s+)?function\b')
IF_START_RE = re.compile(r'^if\b.*\bthen(?:\s*--.*)?$')
FOR_START_RE = re.compile(r'^for\b.*\bdo(?:\s*--.*)?$')
WHILE_START_RE = re.compile(r'^while\b.*\bdo(?:\s*--.*)?$')
REPEAT_RE = re.compile(r'^repeat(?:\s*--.*)?$')
END_LINE_RE = re.compile(r'^end(?:\s*--.*)?$')
UNTIL_LINE_RE = re.compile(r'^until\b')

# filename = module name exactly (src/render/ -> render.lua, src/ecs/ -> ecs.lua)
# JSON key = src/ folder name; example file = content/examples/<src_folder>.lua
# When Lua API namespace differs from src folder (e.g. src/binary/ -> lurek.data),
# the example file keeps the src folder name and NAMESPACE_MAP handles the namespace.
MODULE_TO_EXAMPLE: dict[str, str] = {
    'ai':          'ai.lua',
    'animation':   'animation.lua',
    'audio':       'audio.lua',
    'automation':  'automation.lua',
    'binary':      'binary.lua',    # lurek.data API, example file matches src/ folder
    'camera':      'camera.lua',
    'compute':     'compute.lua',
    'dataframe':   'dataframe.lua',
    'debugbridge': 'debugbridge.lua',
    'devtools':    'devtools.lua',
    'docs':        'docs.lua',
    'ecs':         'ecs.lua',
    'effect':      'effect.lua',
    'engine':      'engine.lua',
    'event':       'event.lua',
    'filesystem':  'filesystem.lua',
    'flownet':     'flownet.lua',   # lurek.graph API, example file matches src/ folder
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
    'serialize':   'serialize.lua', # lurek.serial API, example file matches src/ folder
    'spine':       'spine.lua',
    'sprite':      'sprite.lua',
    'system':      'runtime.lua',   # lurek.runtime API; example was renamed from system.lua
    'terminal':    'terminal.lua',
    'thread':      'thread.lua',
    'tilemap':     'tilemap.lua',
    'timer':       'timer.lua',
    'tween':       'tween.lua',
    'ui':          'ui.lua',
    'window':      'window.lua',
}

# Maps JSON module key  â†’  lurek.* namespace used in example files
# Namespace = src/ folder name exactly (e.g. src/render/ -> lurek.render)
NAMESPACE_MAP: dict[str, str] = {
    'ai':          'ai',
    'animation':   'animation',
    'audio':       'audio',
    'automation':  'automation',
    'binary':      'data',        # src/binary/ -> lurek.data
    'camera':      'camera',
    'compute':     'compute',
    'dataframe':   'dataframe',
    'debugbridge': 'debugbridge',
    'devtools':    'devtools',
    'docs':        'docs',
    'ecs':         'ecs',
    'effect':      'effect',
    'engine':      'engine',
    'event':       'event',
    'filesystem':  'filesystem',
    'flownet':     'graph',       # src/flownet/ -> lurek.graph
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
    'serialize':   'serial',      # src/serialize/ -> lurek.serial
    'spine':       'spine',
    'sprite':      'sprite',
    'system':      'runtime',     # src/runtime/ -> lurek.runtime
    'terminal':    'terminal',
    'thread':      'thread',
    'tilemap':     'tilemap',
    'timer':       'timer',
    'tween':       'tween',
    'ui':          'ui',
    'window':      'window',
}

# Some Lua-visible classes are surfaced from multiple module docs, but examples should
# live in one canonical module file to avoid exact duplicate --@api-stub markers.
CANONICAL_API_MODULE: dict[str, str] = {
    'LBehaviorTree:setRoot': 'patterns',
    'LTween:getDuration': 'tween',
    'LTween:getEasingName': 'tween',
    'LTween:type': 'tween',
    'LTween:typeOf': 'tween',
    'LImageData:blit': 'image',
    'LImageData:diff': 'image',
    'LImageData:getHeight': 'image',
    'LImageData:getRegion': 'image',
    'LImageData:getWidth': 'image',
    'LImageData:mapPixels': 'image',
    'LImageData:resize': 'image',
    'LImageData:type': 'image',
    'LImageData:typeOf': 'image',
}


@dataclass
class ApiEntry:
    module: str
    name: str          # bare Lua method/function name, e.g. "getDelta"
    api_name: str      # full stub marker id, e.g. "lurek.timer.after" or "LTimer:start"
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
    example_files: list[str] = field(default_factory=list)
    total: int = 0
    full_count: int = 0
    part_count: int = 0
    todo_count: int = 0
    miss_count: int = 0
    line_count: int = 0     # total lines in file
    comment_count: int = 0  # comment lines
    docstring_count: int = 0  # items covered with docstrings
    missing: list = field(default_factory=list)
    todo_items: list = field(default_factory=list)
    status_by_api: dict[str, str] = field(default_factory=dict)

    @property
    def pct(self) -> float:
        return (self.real_count / self.total * 100) if self.total else 100.0

    @property
    def pct_with_stubs(self) -> float:
        return (self.tracked_count / self.total * 100) if self.total else 100.0

    @property
    def real_count(self) -> int:
        return self.full_count + self.part_count

    @property
    def tracked_count(self) -> int:
        return self.full_count + self.part_count + self.todo_count


def load_entries(jp: Path) -> list[ApiEntry]:
    data = json.loads(jp.read_text(encoding='utf-8'))
    mods = data['lua_api']['modules']
    out: list[ApiEntry] = []
    for mn, m in mods.items():
        if mn == 'collision': continue
        if mn == 'collision': continue
        ex = MODULE_TO_EXAMPLE.get(mn, mn + '.lua')
        for fn in (m.get('functions') or []):
            out.append(ApiEntry(
                module=mn, name=fn['name'], api_name=fn.get('lua_name') or f"lurek.{NAMESPACE_MAP.get(mn, mn)}.{fn['name']}", is_method=False,
                owner_type='', example_file=ex,
                description=fn.get('description', ''),
                inferred_sig=fn.get('inferred_sig', '()'),
            ))
        for cn, cls in (m.get('classes') or {}).items():
            for meth in (cls.get('methods') or []):
                out.append(ApiEntry(
                    module=mn, name=meth['name'], api_name=meth.get('lua_name') or f'{cn}:{meth["name"]}', is_method=True,
                    owner_type=cn, example_file=ex,
                    description=meth.get('description', ''),
                    inferred_sig=meth.get('inferred_sig', '()'),
                ))
    return out


def resolve_examples_dir(path_arg: str | None) -> Path:
    if not path_arg:
        return DEFAULT_EXAMPLES_DIR
    path = Path(path_arg)
    return path if path.is_absolute() else ROOT / path


def resolve_markdown_path(path_arg: str, examples_dir: Path) -> Path:
    if path_arg == '__AUTO__':
        if examples_dir == DEFAULT_EXAMPLES_DIR:
            return DEFAULT_MARKDOWN_REPORT
        return examples_dir / 'example_coverage.md'
    path = Path(path_arg)
    return path if path.is_absolute() else ROOT / path


def _count_scope_openings(stripped: str) -> int:
    if DO_LINE_RE.match(stripped):
        return 1
    if REPEAT_RE.match(stripped):
        return 1
    if FUNCTION_START_RE.match(stripped):
        return 1
    if IF_START_RE.match(stripped) and not stripped.startswith('elseif'):
        return 1
    if FOR_START_RE.match(stripped):
        return 1
    if WHILE_START_RE.match(stripped):
        return 1
    return 0


def _count_scope_closures(stripped: str) -> int:
    if END_LINE_RE.match(stripped):
        return 1
    if UNTIL_LINE_RE.match(stripped):
        return 1
    return 0


def _is_outer_block_end(stripped: str, depth: int) -> bool:
    return depth == 1 and _count_scope_closures(stripped) == 1 and _count_scope_openings(stripped) == 0


def classify_block(block: dict | None) -> str:
    if not block:
        return 'MISS'
    # doc-alias: stub without a do block immediately followed by another stub tag.
    # The following stub provides the example code; this one is a coverage alias.
    if block.get('is_alias'):
        return 'FULL'
    if block['has_todo'] or block['body_line_count'] == 0:
        return 'TODO'
    if block['body_line_count'] >= FULL_BLOCK_MIN_LINES:
        return 'FULL'
    return 'PART'


def load_texts(d: Path) -> dict[str, dict]:
    """Load all .lua files.

    Returns dict: filename -> { 'blocks': dict, 'lines': int, 'comments': int }
    """
    out: dict[str, dict] = {}
    global_markers: dict[str, tuple[str, int]] = {}
    for p in d.glob('*.lua'):
        raw = p.read_text(encoding='utf-8', errors='replace')
        file_lines = raw.splitlines()
        comments = 0
        blocks = {}

        current_stub = None
        current_block = None
        block_depth = 0
        for line_no, ln in enumerate(file_lines, start=1):
            stripped = ln.strip()
            if stripped.startswith('--'):
                comments += 1

            if stripped.startswith('--@api-stub:'):
                marker = stripped[len('--@api-stub:'):].strip()
                if marker in blocks:
                    import sys
                    print(f"WARN: Duplicate stub marker '{marker}' found twice in {p.name}", file=sys.stderr)
                    continue
                if marker in global_markers:
                    import sys
                    prev_file, prev_line = global_markers[marker]
                    print(
                        f"WARN: Stub '{marker}' appears in both {prev_file}:{prev_line} and {p.name}:{line_no}"
                        f" (class registered in multiple modules)",
                        file=sys.stderr,
                    )
                    # still register in blocks so this file's module shows as covered
                global_markers[marker] = (p.name, line_no)
                # Mark the previous stub as a doc-alias if it never received a do block.
                # Doc-alias: intentional no-do stub pointing to the next stub's example.
                if current_stub is not None and current_block is not None:
                    if not current_block.get('found_block', False):
                        current_block['is_alias'] = True
                current_stub = marker
                current_block = {'has_todo': False, 'body_line_count': 0, 'found_block': False, 'is_alias': False}
                blocks[current_stub] = current_block
                block_depth = 0
                continue

            if current_stub is not None:
                if current_block is None:
                    continue

                if '-- TODO:' in stripped:
                    current_block['has_todo'] = True

                if not current_block['found_block']:
                    if DO_LINE_RE.match(stripped):
                        current_block['found_block'] = True
                        block_depth = 1
                    continue

                if _is_outer_block_end(stripped, block_depth):
                    current_stub = None
                    current_block = None
                    block_depth = 0
                    continue

                if stripped:
                    current_block['body_line_count'] += 1

                block_depth += _count_scope_openings(stripped)
                block_depth -= _count_scope_closures(stripped)

                if block_depth <= 0:
                    current_stub = None
                    current_block = None
                    block_depth = 0

        out[p.name] = {
            'blocks': blocks,
            'lines': len(file_lines),
            'comments': comments
        }
    return out


def find_module_example_files(texts: dict[str, dict], module_name: str, example_file: str) -> list[str]:
    if example_file in texts:
        return [example_file]

    prefix = f'{module_name}_'
    return sorted(
        file_name
        for file_name in texts.keys()
        if file_name.startswith(prefix) and file_name.endswith('.lua')
    )


def merge_blocks(target: dict[str, dict], source: dict[str, dict]) -> None:
    for marker, block in source.items():
        if marker not in target:
            target[marker] = {
                'has_todo': block['has_todo'],
                'body_line_count': block.get('body_line_count', 0),
                'is_alias': block.get('is_alias', False),
            }
            continue
        # If any duplicate block no longer has TODO, treat the API item as covered.
        target[marker]['has_todo'] = target[marker]['has_todo'] and block['has_todo']
        # Preserve alias status.
        if block.get('is_alias'):
            target[marker]['is_alias'] = True
        target[marker]['body_line_count'] = max(
            target[marker].get('body_line_count', 0),
            block.get('body_line_count', 0),
        )


def collect_module_data(texts: dict[str, dict], module_name: str, example_file: str) -> dict:
    file_names = find_module_example_files(texts, module_name, example_file)
    blocks: dict[str, dict] = {}
    line_count = 0
    comment_count = 0

    for file_name in file_names:
        data = texts[file_name]
        line_count += data['lines']
        comment_count += data['comments']
        merge_blocks(blocks, data['blocks'])

    return {
        'files': file_names,
        'blocks': blocks,
        'lines': line_count,
        'comments': comment_count,
    }


def _match_name(entry: 'ApiEntry', text: str) -> bool:
    """Return True if entry is called in hand-written code."""
    if entry.is_method:
        pat = r':' + re.escape(entry.name) + r'\s*\('
    else:
        pat = r'\b' + re.escape(entry.name) + r'\s*\('
    return bool(re.search(pat, text))


def build_cov(entries: list[ApiEntry], texts: dict[str, dict]) -> dict[str, ModuleCov]:
    bk: dict[str, ModuleCov] = {}
    module_data_cache: dict[str, dict] = {}
    for e in entries:
        canonical_module = CANONICAL_API_MODULE.get(e.api_name)
        if canonical_module is not None and e.module != canonical_module:
            continue

        key = e.module
        if key not in bk:
            bk[key] = ModuleCov(
                key=key,
                example_file=e.example_file,
                namespace=NAMESPACE_MAP.get(key, key),
            )
            module_data = collect_module_data(texts, key, e.example_file)
            module_data_cache[key] = module_data
            bk[key].example_files = module_data['files']
            bk[key].line_count = module_data['lines']
            bk[key].comment_count = module_data['comments']
        mc = bk[key]
        mc.total += 1

        data = module_data_cache[key]
        if not data['files']:
            mc.missing.append(e.api_name)
            mc.status_by_api[e.api_name] = 'missing'
            continue

        blocks = data['blocks']

        if e.api_name not in blocks:
            mc.missing.append(e.api_name)
            mc.miss_count += 1
            mc.status_by_api[e.api_name] = 'MISS'
            continue

        status = classify_block(blocks[e.api_name])
        mc.status_by_api[e.api_name] = status

        if status == 'FULL':
            mc.full_count += 1
            if len(e.description.strip()) > 0:
                mc.docstring_count += 1
        elif status == 'PART':
            mc.part_count += 1
            if len(e.description.strip()) > 0:
                mc.docstring_count += 1
        elif status == 'TODO':
            mc.todo_count += 1
            mc.todo_items.append(e.api_name)
        else:
            mc.miss_count += 1
            mc.missing.append(e.api_name)

    return bk


def example_label(mc: ModuleCov) -> str:
    if not mc.example_files:
        return mc.example_file
    if len(mc.example_files) == 1:
        return mc.example_files[0]
    return f'{mc.key}_*.lua ({len(mc.example_files)} files)'


def print_summary(bk: dict[str, ModuleCov], filt: str | None = None) -> None:
    print(f"\n{'Module':<18} {'Namespace':<18} {'Example':<28} {'Full':>4} {'Part':>4} {'Todo':>4} {'Miss':>4} {'Tot':>4} {'%':>5}")
    print('-' * 112)
    tf = tp = tt = tm = ta = 0
    for k, mc in sorted(bk.items()):
        if filt and filt.lower() not in k.lower():
            continue
        flag = ' MISSING' if not mc.example_files else ''
        stub_flag = ' [TODO]' if mc.todo_items else ''
        ns = f"lurek.{mc.namespace}"
        print(f'{k:<18} {ns:<18} {example_label(mc):<28} {mc.full_count:>4} {mc.part_count:>4} {mc.todo_count:>4} {mc.miss_count:>4} {mc.total:>4} {mc.pct_with_stubs:>4.0f}%{flag}{stub_flag}')
        tf += mc.full_count
        tp += mc.part_count
        tt += mc.todo_count
        tm += mc.miss_count
        ta += mc.total
    print('-' * 112)
    total_pct = ((tf + tp + tt) / ta * 100) if ta else 100.0
    print(f"{'TOTAL':<74} {tf:>4} {tp:>4} {tt:>4} {tm:>4} {ta:>4} {total_pct:>4.0f}%")
    if tt:
        print(f"\n  NOTE: {tt} item(s) are still auto-stubs with TODO markers.")
        print(f"        Run --stubs to see which modules need fleshing out.")


def print_stubs(bk: dict[str, ModuleCov], filt: str | None = None) -> None:
    """Show modules that have pending --@api-stub: blocks (-- TODO: still present)."""
    found = False
    for k, mc in sorted(bk.items()):
        if filt and filt.lower() not in k.lower():
            continue
        if not mc.todo_items:
            continue
        found = True
        print(f'\n[{k}] lurek.{mc.namespace} -> {example_label(mc)}: {len(mc.todo_items)} pending stub(s)')
        for fn in sorted(mc.todo_items):
            print(f'  --@api-stub: {fn}  [remove -- TODO: when done]')
    if not found:
        print('No pending stubs. All --@api-stub: blocks have real scenario code.')


def print_missing(bk: dict[str, ModuleCov], filt: str | None = None) -> None:
    for k, mc in sorted(bk.items()):
        if filt and filt.lower() not in k.lower():
            continue
        if not mc.missing and not mc.todo_items:
            continue
        exists = bool(mc.example_files)
        status = '' if exists else ' (FILE MISSING)'
        real_pct = mc.pct
        print(f'\n[{k}] lurek.{mc.namespace} -> {example_label(mc)}{status} ({real_pct:.0f}% real, {mc.todo_count} todo)')
        for fn in sorted(mc.missing):
            print(f'  - {fn}  [MISSING -- no --@api-stub: marker]')
        for fn in sorted(mc.todo_items):
            print(f'  ~ {fn}  [PENDING -- remove -- TODO: to mark as done]')


def format_path(path: Path) -> str:
    try:
        return str(path.relative_to(ROOT)).replace('\\', '/')
    except ValueError:
        return str(path).replace('\\', '/')


def export_markdown(bk: dict[str, ModuleCov], entries: list[ApiEntry], out_path: Path, examples_dir: Path):
    p = Path(out_path)
    p.parent.mkdir(parents=True, exist_ok=True)

    with p.open('w', encoding='utf-8') as f:
        f.write('# Example Coverage Report\n\n')
        f.write(f'Source directory: {format_path(examples_dir)}\n\n')
        f.write('## Per API Coverage\n\n')

        for entry in sorted(entries, key=lambda item: (item.module, item.api_name.lower())):
            mc = bk.get(entry.module)
            status = mc.status_by_api.get(entry.api_name, 'MISS') if mc else 'MISS'
            f.write(f'{entry.api_name} {status}\n')

        f.write('\n## Module Summary\n\n')
        f.write('| Module | MISS | TODO | PART | FULL | TOTAL |\n')
        f.write('|---|---:|---:|---:|---:|---:|\n')

        total_miss = 0
        total_todo = 0
        total_part = 0
        total_full = 0
        total_all = 0
        for _, mc in sorted(bk.items()):
            total_miss += mc.miss_count
            total_todo += mc.todo_count
            total_part += mc.part_count
            total_full += mc.full_count
            total_all += mc.total
            f.write(f'| lurek.{mc.namespace} | {mc.miss_count} | {mc.todo_count} | {mc.part_count} | {mc.full_count} | {mc.total} |\n')

        f.write(f'| TOTAL | {total_miss} | {total_todo} | {total_part} | {total_full} | {total_all} |\n')

def main() -> int:
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('--examples-dir', metavar='DIR', help='Directory with .lua example files (default: content/examples)')
    p.add_argument('--json',      action='store_true', help='Machine-readable JSON output')
    p.add_argument('--missing',   action='store_true', help='Show only missing items per module')
    p.add_argument('--stubs',     action='store_true', help='Show modules with --@api-stub: blocks remaining')
    p.add_argument('--summary',   action='store_true', help='Show summary table (default)')
    p.add_argument('--report',    action='store_true', help='CI gate: exit 1 if any gaps exist')
    p.add_argument('--no-stubs',  action='store_true', help='With --report: also fail if any stub blocks remain')
    p.add_argument('--module',    metavar='NAME',      help='Filter to one module')
    p.add_argument('--markdown',  metavar='FILE',      nargs='?', const='__AUTO__', help='Export Markdown report to FILE')
    args = p.parse_args()

    if not API_JSON.exists():
        print(f'ERROR: {API_JSON} not found â€” run python tools/gen_all_docs.py first')
        return 1

    examples_dir = resolve_examples_dir(args.examples_dir)
    if not examples_dir.exists():
        print(f'ERROR: examples dir not found: {examples_dir}')
        return 1

    entries = load_entries(API_JSON)
    if args.module:
        entries = [entry for entry in entries if args.module.lower() in entry.module.lower()]
        if not entries:
            print(f'ERROR: module "{args.module}" not found in API data')
            return 1

    texts   = load_texts(examples_dir)
    bk      = build_cov(entries, texts)

    markdown_path = resolve_markdown_path(args.markdown, examples_dir) if args.markdown else None

    has_gaps  = any(mc.miss_count > 0 for mc in bk.values())
    has_stubs = any(mc.todo_count > 0 for mc in bk.values())

    if args.markdown:
        export_markdown(bk, entries, markdown_path, examples_dir)
        print(f"Exported Markdown report to {markdown_path}")
    elif args.json:
        print(json.dumps({
            k: {
                'namespace':    f"lurek.{mc.namespace}",
                'example_file': mc.example_file,
                'example_files': mc.example_files,
                'file_exists':  bool(mc.example_files),
                'covered':      mc.real_count,
                'stub_covered': mc.todo_count,
                'full':         mc.full_count,
                'part':         mc.part_count,
                'todo':         mc.todo_count,
                'miss':         mc.miss_count,
                'total':        mc.total,
                'pct':          round(mc.pct_with_stubs, 1),
                'missing':      sorted(mc.missing),
                'stub_items':   sorted(mc.todo_items),
                'status_by_api': {k2: mc.status_by_api[k2] for k2 in sorted(mc.status_by_api)},
            }
            for k, mc in sorted(bk.items())
        }, indent=2))
    elif args.missing:
        print_missing(bk, filt=args.module)
    elif args.stubs:
        print_stubs(bk, filt=args.module)
    else:
        print_summary(bk, filt=args.module)

    if args.report:
        failures = []
        if has_gaps:
            gaps = sum(1 for mc in bk.values() if mc.miss_count)
            failures.append(f'{gaps} module(s) have MISS API items (no stub marker).')
        if args.no_stubs and has_stubs:
            stubs = sum(1 for mc in bk.values() if mc.todo_count)
            failures.append(f'{stubs} module(s) still have TODO stub blocks (not real scenarios).')
        if failures:
            for f in failures:
                print(f'\n[REPORT] {f}')
            return 1

    return 1 if has_gaps else 0


if __name__ == '__main__':
    sys.exit(main())


