import json
from pathlib import Path
p = Path('logs/data/module_docstring_audit_last.json')
d = json.loads(p.read_text(encoding='utf-16'))
print('violations', len(d))
for v in d[:20]:
    print(f"{v['file']} {v['loc']} {v['actual_doc_lines']}/{v['required_doc_lines']}")
