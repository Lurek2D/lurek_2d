import json
from pathlib import Path
raw=Path('logs/data/doc_audit_postfix.json').read_bytes()
if raw[:2] in (b'\xff\xfe', b'\xfe\xff'):
    d=json.loads(raw.decode('utf-16'))
else:
    d=json.loads(raw.decode('utf-8'))

by=d['rust']['by_module']
for mod_name, info in by.items():
    miss=info.get('total',0)-info.get('documented',0)
    if miss:
        print(mod_name, miss)
