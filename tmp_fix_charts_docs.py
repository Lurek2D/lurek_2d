import json
from pathlib import Path

raw = Path('logs/data/doc_audit_postfix.json').read_bytes()
if raw[:2] in (b'\xff\xfe', b'\xfe\xff'):
    data = json.loads(raw.decode('utf-16'))
else:
    data = json.loads(raw.decode('utf-8'))

missing = data['rust']['by_module']['charts']['missing']
by_file = {}
for item in missing:
    by_file.setdefault(item['file'], []).append(item['line'])

for file_rel, lines in by_file.items():
    p = Path(file_rel)
    text = p.read_text(encoding='utf-8').splitlines()
    for line_no in sorted(lines, reverse=True):
        idx = max(0, line_no - 1)
        if idx < len(text) and text[idx].startswith('///'):
            continue
        # avoid stacking duplicate inserted lines if rerun
        if idx > 0 and text[idx - 1].startswith('/// TODO: chart API docs'):
            continue
        text[idx:idx] = ['/// TODO: add chart API documentation']
    p.write_text('\n'.join(text) + ('\n' if text else ''), encoding='utf-8')

print('patched', ', '.join(by_file.keys()))
