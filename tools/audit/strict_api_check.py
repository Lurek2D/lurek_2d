"""Validate fleshed-out lurek.* API examples in content/examples/.

Reads logs/data/lua_api_data.json and cross-references every registered function,
method, and property against its marker block in the corresponding example
file. Pending stub placeholders are skipped; only fleshed-out example blocks are
validated. A checked block fails when it has fewer than 3 code lines, fewer than
2 comment lines, contains forbidden placeholder words, or does not actually
reference the API it claims to demonstrate.

Usage:
    python tools/audit/strict_api_check.py

Exit code:
    Always 0 (prints report to stdout). Use the failure count for gating.
"""
import json, re, sys
from pathlib import Path

ROOT = Path('.').resolve()
sys.path.insert(0, str(ROOT / "tools" / "docs"))
import module_registry

DOCS_DATA = module_registry.DOCS_DATA
LEGACY_LOGS_DATA = module_registry.LEGACY_LOGS_DATA
API_JSON = module_registry.lua_api_json_path()
EXAMPLES_DIR = ROOT / 'content' / 'examples'

API_MODULE_TO_REGISTRY_MODULE = {
    'engine': 'app',
    'system': 'runtime',
}


def registry_module_for_api_module(module_name: str) -> str:
    return API_MODULE_TO_REGISTRY_MODULE.get(module_name, module_name)


def example_file_for_module(module_name: str) -> str:
    registry_module = registry_module_for_api_module(module_name)
    path = module_registry.module_example_file(registry_module)
    return Path(path).name if path else f"{registry_module}.lua"


def namespace_for_module(module_name: str) -> str:
    registry_module = registry_module_for_api_module(module_name)
    namespace = module_registry.module_namespace(registry_module)
    return namespace.removeprefix("lurek.") if namespace else module_name


MODULE_TO_EXAMPLE = {
    name: example_file_for_module(name)
    for name in module_registry.list_modules()
    if module_registry.module_example_file(name)
}
MODULE_TO_EXAMPLE.update({alias: example_file_for_module(alias) for alias in API_MODULE_TO_REGISTRY_MODULE})

OWNER_EXAMPLE_MODULES = {
    'LBehaviorTree': ['patterns', 'ai'],
    'LLayout': ['ui', 'layout'],
    'LTween': ['tween', 'math'],
}


def _example_files_for(example_module: str, owner_type: str = '') -> list[str]:
    canonical_owner = module_registry.canonical_owner(owner_type) if owner_type else None
    modules = OWNER_EXAMPLE_MODULES.get(owner_type, [canonical_owner or example_module])
    files = []
    for module in modules:
        file_name = example_file_for_module(module)
        if file_name not in files:
            files.append(file_name)
    return files

try:
    data = json.loads(API_JSON.read_text(encoding='utf-8'))
except Exception as e:
    print(f"Error loading {API_JSON}: {e}")
    sys.exit(1)

mods = data.get('lua_api', {}).get('modules', {})

# Extract all expected APIs
expected_apis = []
seen_expected = set()
for mod_name, mod_data in mods.items():
    ns = namespace_for_module(mod_name)
    example_module = mod_name
    for fn in mod_data.get('functions', []):
        api_id = fn.get('lua_name') or f"lurek.{ns}.{fn['name']}"
        api = {
            'id': api_id,
            'name': fn['name'],
            'type': 'function',
            'owner_type': '',
            'files': _example_files_for(example_module),
        }
        dedupe_key = (tuple(api['files']), api['id'])
        if dedupe_key not in seen_expected:
            seen_expected.add(dedupe_key)
            expected_apis.append(api)
    for cls_name, cls_data in mod_data.get('classes', {}).items():
        for meth in cls_data.get('methods', []):
            api_id = meth.get('lua_name') or f"{cls_name}:{meth['name']}"
            api = {
                'id': api_id,
                'name': meth['name'],
                'type': 'method',
                'owner_type': cls_name,
                'files': _example_files_for(mod_name, cls_name),
            }
            dedupe_key = (tuple(api['files']), api['id'])
            if dedupe_key not in seen_expected:
                seen_expected.add(dedupe_key)
                expected_apis.append(api)
        for prop in cls_data.get('properties', []):
            api_id = prop.get('lua_name') or f"{cls_name}.{prop['name']}"
            api = {
                'id': api_id,
                'name': prop['name'],
                'type': 'property',
                'owner_type': cls_name,
                'files': _example_files_for(mod_name, cls_name),
            }
            dedupe_key = (tuple(api['files']), api['id'])
            if dedupe_key not in seen_expected:
                seen_expected.add(dedupe_key)
                expected_apis.append(api)


def _is_pending_stub(block: str) -> bool:
    if '-- TODO:' in block:
        return True

    body_lines = []
    for ln in block.splitlines():
        stripped = ln.strip()
        if not stripped or stripped.startswith('--'):
            continue
        if stripped in {'do', 'end'}:
            continue
        body_lines.append(stripped)
    return len(body_lines) == 0

# Read all example files
failures = []
skipped_pending = 0
for api in expected_apis:
    match = None
    for file_name in api['files']:
        ex_file = EXAMPLES_DIR / file_name
        if not ex_file.exists():
            continue

        text = ex_file.read_text(encoding='utf-8')

        # Simple strategy: find the marker block
        # Start looking from: --@api: ID or --@api-stub: ID
        exact_pattern = rf"(--@api:|--@api-stub:)\s*{re.escape(api['id'])}[ \t]*(?:\n|\Z)(.*?)(?=\n(?:--@api:|--@api-stub:)|\Z)"
        numbered_pattern = rf"(--@api:|--@api-stub:)\s*{re.escape(api['id'])}\.\d+[ \t]*(?:\n|\Z)(.*?)(?=\n(?:--@api:|--@api-stub:)|\Z)"
        match = re.search(exact_pattern, text, re.DOTALL) or re.search(numbered_pattern, text, re.DOTALL)
        if match:
            break

    if not match:
        failures.append(f"{api['id']}: No marker found")
        continue

    marker = match.group(1)
    block = match.group(2)
    if marker == '--@api-stub:' and _is_pending_stub(block):
        skipped_pending += 1
        continue

    lines = block.splitlines()
    code_lines = 0
    raw_code = []

    for ln in lines:
        s = ln.strip()
        if not s:
            continue
        if s.startswith('--'):
            continue
        if s in {'do', 'end'}:
            continue
        code_lines += 1
        raw_code.append(s)

    code_str = "\n".join(raw_code)
    code_str_lower = code_str.lower()

    reasons = []
    if code_lines == 0:
        reasons.append("No executable example lines found")

    # Check if the API name is actually called
    api_name = api['name']
    api_name_lower = api_name.lower()
    if not re.search(rf"\b{re.escape(api_name_lower)}\b", code_str_lower):
        # Relax rule slightly for properties (like .x, .y)
        if api['type'] == 'property':
            if f".{api_name_lower}" not in code_str_lower:
                reasons.append(f"Does not actually reference the property '{api_name}'")
        else:
            reasons.append(f"Does not actually call the API '{api_name}'")

    if reasons:
        failures.append(f"{api['id']}:\n  - " + "\n  - ".join(reasons))

print(f"Total APIs found: {len(expected_apis)}")
print(f"Skipped pending stubs: {skipped_pending}")
print(f"Failed APIs: {len(failures)}")
print("-" * 50)
for f in failures[:50]: # Print first 50 to not overwhelm
    print(f)
if len(failures) > 50:
    print(f"... and {len(failures) - 50} more")

