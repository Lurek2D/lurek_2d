import sys, re, glob
type_map = {}
for f in glob.glob('src/lua_api/*.rs'):
    data = open(f, encoding='utf-8').read()
    lines = data.splitlines()
    for i, line in enumerate(lines):
        if 'impl' in line and 'LunaType for' in line:
            parts = line.split('for')
            name = parts[1].strip().strip('{').split()[0]
            for j in range(i, min(i+15, len(lines))):
                if 'const TYPE_NAME' in lines[j]:
                    m = re.search(r'\"([^\"]+)\"', lines[j])
                    if m:
                        type_map[name] = m.group(1)
                        break
print(type_map)
