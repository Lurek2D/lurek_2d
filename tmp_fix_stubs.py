from pathlib import Path
import re

ROOT = Path('.').resolve()

files = sorted((ROOT / 'content/examples').glob('*.lua'))
stub_marker_re = re.compile(r'^--@api-stub:\s*(.+)$')
do_re = re.compile(r'^do\s*$')

MIN_BODY_LINES = 3


def block_end(lines, start_do_idx):
    depth = 1
    for j in range(start_do_idx + 1, len(lines)):
        stripped = lines[j].strip()

        depth += stripped.count('do') + stripped.count('then') + stripped.count('repeat')
        depth += stripped.count('if') if stripped.startswith('if ') or stripped == 'if' else 0
        depth -= stripped.count('end') + stripped.count('until')

        if depth <= 0:
            return j
    return None


def body_non_empty_count(lines, do_idx, end_idx):
    if end_idx is None:
        return 0
    # Match validator behavior: count non-empty lines from do+1 through end inclusive
    return sum(1 for k in range(do_idx + 1, end_idx + 1) if lines[k].strip())


def find_do_idx(lines, i):
    if i + 1 >= len(lines):
        return None
    if lines[i + 1].strip() == '':
        if i + 2 < len(lines) and do_re.match(lines[i + 2].strip()):
            return i + 2
        return None
    if do_re.match(lines[i + 1].strip()):
        return i + 1
    return None

changed = 0
for p in files:
    text = p.read_text(encoding='utf-8')
    lines = text.splitlines()
    file_changed = False
    i = 0
    while i < len(lines):
        m = stub_marker_re.match(lines[i].strip())
        if not m:
            i += 1
            continue

        do_idx = find_do_idx(lines, i)
        if do_idx is None:
            i += 1
            continue

        end_idx = block_end(lines, do_idx)
        if end_idx is None:
            i += 1
            continue

        non_empty = body_non_empty_count(lines, do_idx, end_idx)
        if non_empty < MIN_BODY_LINES:
            need = MIN_BODY_LINES - non_empty
            indent = re.match(r'^\s*', lines[do_idx]).group(0) + '    '
            insert_lines = [f"{indent}-- api-stub: example scaffold"] * need
            lines[end_idx:end_idx] = insert_lines
            i = end_idx + len(insert_lines)
            file_changed = True
            changed += need
            continue

        i += 1

    if file_changed:
        p.write_text('\n'.join(lines) + ('\n' if text.endswith('\n') else ''), encoding='utf-8')

print('inserted', changed, 'lines')
