from pathlib import Path

base = Path('tests/lua/integration')
files = sorted(base.glob('*.lua'))
updated = []
for p in files:
    data = p.read_bytes()
    try:
        text = data.decode('utf-8')
        decoded = False
    except UnicodeDecodeError:
        text = data.decode('cp1252')
        p.write_text(text, encoding='utf-8')
        updated.append(f"{p} redecoded cp1252")
        decoded = True

    lines = text.splitlines()
    out = []
    changed = decoded
    for line in lines:
        new_line = line.replace('-- @covers', '-- @integration')
        if new_line != line:
            changed = True
        if new_line.startswith('-- @describe ') and out and out[-1] == new_line:
            changed = True
            continue
        out.append(new_line)

    if changed:
        p.write_text('\n'.join(out) + ('\n' if text.endswith('\n') else ''), encoding='utf-8')
        if not decoded:
            updated.append(f"{p} normalized markers")

print('updated', len(updated))
for item in updated[:400]:
    print(item)
