import json
from pathlib import Path
raw=Path('logs/data/doc_audit_postfix.json').read_bytes()
if raw[:2] in (b'\xff\xfe', b'\xfe\xff'):
    d=json.loads(raw.decode('utf-16'))
else:
    d=json.loads(raw.decode('utf-8'))
info=d['rust']['by_module']['charts']
print(info.keys())
for x in info['missing'][:40]:
    print(x)
