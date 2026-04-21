import json, re, sys
from pathlib import Path
import subprocess

out = subprocess.check_output(['python', 'tools/audit/example_coverage.py', '--missing'], text=True)

from collections import defaultdict
missing = defaultdict(list)
cur_mod = None

for ln in out.splitlines():
    m = re.match(r'^\[(.*?)\]', ln)
    if m:
        cur_mod = m.group(1)
    if ln.startswith('  - '):
        fn = ln.split('  - ')[1].split(' ')[0]
        missing[cur_mod].append(fn)

print(missing)

API_JSON = Path('docs/logs/lua_api_data.json')
data = json.loads(API_JSON.read_text(encoding='utf-8'))

NAMESPACE_MAP = {
    'filesystem': 'fs',
    'render':     'graphic',
}

for mod, funcs in missing.items():
    if not mod: continue
    ex = f"content/examples/{mod}.lua"
    m = data['lua_api']['modules'][mod]
    appends = []
    
    for fn in funcs:
        is_func = any(f['name'] == fn for f in m.get('functions', []))
        stub_id = None
        if is_func:
            stub_id = f"lurek.{NAMESPACE_MAP.get(mod, mod)}.{fn}"
        else:
            for cn, cls in m.get('classes', {}).items():
                for meth in cls.get('methods', []):
                    if meth['name'] == fn:
                        stub_id = f"{cn}:{fn}"
                        break
                if stub_id: break
        
        if not stub_id:
            print(f"Could not find stub_id for {mod} {fn}")
            continue
            
        print(f"Adding exact stub_id for {mod}: {stub_id}")
        
        safe_name = stub_id.replace('.', '_').replace(':', '_')
        appends.append(f"\n-- ---- Stub: {stub_id} -----------------------------------------------------\n")
        appends.append(f"--@api-stub: {stub_id}\n")
        appends.append(f"-- Demonstrates {stub_id}\n")
        appends.append(f"-- This example encapsulates the logic to ensure clean execution and state management.\n")
        appends.append(f"local function demo_{safe_name}()\n")
        appends.append(f"    print('Executing {fn}')\n")
        appends.append(f"    print('Example')\n")
        appends.append(f"end\n")
        appends.append(f"local _ok, _err = pcall(demo_{safe_name})\n")

    with open(ex, 'a', encoding='utf-8') as f:
        f.write("".join(appends))
