from pathlib import Path
import json
p = Path('logs/quality_report.json')
b = p.read_bytes()
enc = 'utf-16' if b.startswith(b'\xff\xfe') or b.startswith(b'\xfe\xff') else 'utf-8'
if enc == 'utf-16':
    text = b.decode(enc)
else:
    text = b.decode('utf-8', errors='replace')
obj = json.loads(text)
mods = obj.get('modules', [])
from collections import Counter
counts = {'PASS':0,'FAIL':0,'WARN':0,'MANUAL':0}
bad_by_code=Counter()
fail_mods=[]
for m in mods:
    r=m['result']
    counts[r]=counts.get(r,0)+1
    bad=[c for c in m['checks'] if c['verdict'] in ('FAIL','WARNING')]
    if bad:
        if r=='FAIL':
            fail_mods.append((m['module'], bad))
        for c in bad:
            bad_by_code[(c['code'], c['name'])]+=1
print('module_count',len(mods))
print('result_counts',counts)
print('fail_modules',len(fail_mods))
for name,bad in fail_mods[:40]:
    print(name, len(bad))
    for c in bad[:4]:
        print(' ',c['code'],c['verdict'],c['name'])
    if len(bad)>4:
        print('  ...',len(bad)-4,'more')
print('Top checks:')
for (code,name),cnt in bad_by_code.most_common(40):
    print(f'{code:4} {cnt:3} {name}')
