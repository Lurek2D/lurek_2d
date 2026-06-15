import json
from pathlib import Path

d=json.loads(Path('logs/data/module_docstring_audit_last.json').read_text(encoding='utf-16'))
print('count',len(d))
for v in d:
    print(v['file'], v['actual_doc_lines'], '/', v['required_doc_lines'])
