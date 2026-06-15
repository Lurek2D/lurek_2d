import json
from collections import Counter, OrderedDict
from pathlib import Path
p=Path('logs/data/doc_audit_postfix.json')
raw=p.read_bytes()
if raw[:2] in (b'\xff\xfe', b'\xfe\xff'):
    d=json.loads(raw.decode('utf-16'))
else:
    d=json.loads(raw.decode('utf-8'))

missing=[m for m in d['rust']['by_module'] if False]
# get all items
items=d['rust'].get('modules',{})
print('keys',d['rust'].keys())
print('has by_module', 'by_module' in d['rust'])
print('top', len(d['rust'].get('by_module',{})))
