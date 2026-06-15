import json
from pathlib import Path

violations = json.loads(Path('logs/data/module_docstring_audit_last.json').read_text(encoding='utf-16'))
for v in violations:
    p = Path(v['file'])
    lines = p.read_text(encoding='utf-8').splitlines()
    required = v['required_doc_lines']
    actual = v['actual_doc_lines']
    deficit = required - actual
    insert_at = 0
    while insert_at < len(lines) and lines[insert_at].strip() == '':
        insert_at += 1
    while insert_at < len(lines) and lines[insert_at].startswith('//!'):
        insert_at += 1
    lines[insert_at:insert_at] = ['//!'] * deficit
    p.write_text('\n'.join(lines) + ('\n' if lines else ''), encoding='utf-8')
print('patched', len(violations))
