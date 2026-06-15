from pathlib import Path
import json
p=Path('logs/data/test_analytics.json')
obj=json.loads(p.read_text(encoding='utf-8'))
mods=obj.get('modules',{})
if isinstance(mods, list):
    mods=mods
elif isinstance(mods, dict):
    mods=list(mods.values())
print('module_count',len(mods))
mods=[m for m in mods if isinstance(m,dict)]
for k in sorted(mods, key=lambda m: float(m.get('score',0.0))):
    pass
# print bottom 20
items=sorted(mods,key=lambda m: float(m.get('score',0.0)) )[:25]
for m in items:
    print(f"{m.get('module')} has_stress={m.get('has_stress')} score={m.get('score')} tests={m.get('tests')} stress={m.get('stress')}")
