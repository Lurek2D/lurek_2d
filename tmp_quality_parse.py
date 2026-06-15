import json
from pathlib import Path
p=Path('logs/data/quality_report_postfix.json')
text=p.read_bytes()
# detect utf-16 with BOM
text_start=text[:2]
if text_start==b'\xff\xfe' or text_start==b'\xfe\xff':
    data=json.loads(text.decode('utf-16'))
else:
    data=json.loads(text.decode('utf-8'))
print('modules', len(data.get('modules',[])))
print('docs', isinstance(data.get('docs-general',{}),dict))
print('test keys', data.get('test_coverage',{}).keys())
print('modules summary fails', sum(1 for m in data['modules'] if m.get('result')=='FAIL'))
