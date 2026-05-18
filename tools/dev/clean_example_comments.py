"""
Remove all comments outside do-end blocks except:
  - lines 1-3 (file header)
  - --@api-stub: lines
  - 1-2 description lines immediately after --@api-stub:

Bug fix: tracks ALL Lua block openers (do/function/if/for/while/repeat),
not just 'do', so inner function/if/for endings don't prematurely drop depth.
"""
import re
import sys
import glob
import os

BLOCK_OPEN = re.compile(r'\b(do|function|if)\b')
BLOCK_CLOSE = re.compile(r'\bend\b')


def clean_file(path):
    with open(path, encoding='utf-8') as f:
        lines = f.readlines()

    result = []
    depth = 0
    i = 0
    HEADER_LINES = 3

    while i < len(lines):
        raw = lines[i]
        stripped = raw.rstrip()
        sc = stripped.lstrip()

        if i < HEADER_LINES:
            result.append(raw)
            i += 1
            continue

        is_comment_only = sc.startswith('--') or sc == ''
        is_api_stub = sc.startswith('--@api-stub:')

        if depth > 0:
            result.append(raw)
            if not sc.startswith('--'):
                opens = len(BLOCK_OPEN.findall(stripped))
                closes = len(BLOCK_CLOSE.findall(stripped))
                depth += opens - closes
                if depth < 0:
                    depth = 0
            i += 1
            continue

        if is_api_stub:
            result.append(raw)
            i += 1
            kept = 0
            while i < len(lines) and kept < 2:
                nr = lines[i]
                ns = nr.lstrip().rstrip()
                if ns.startswith('--') and not ns.startswith('--@api-stub:'):
                    result.append(nr)
                    kept += 1
                    i += 1
                else:
                    break
            continue

        if is_comment_only:
            i += 1
            continue

        result.append(raw)
        if not sc.startswith('--'):
            opens = len(BLOCK_OPEN.findall(stripped))
            closes = len(BLOCK_CLOSE.findall(stripped))
            depth += opens - closes
            if depth < 0:
                depth = 0
        i += 1

    return lines, result


if __name__ == '__main__':
    patterns = sys.argv[1:] or ['content/examples/*.lua']
    for pattern in patterns:
        for path in sorted(glob.glob(pattern)):
            original, cleaned = clean_file(path)
            with open(path, 'w', encoding='utf-8') as f:
                f.writelines(cleaned)
            diff = len(original) - len(cleaned)
            print(f'{os.path.basename(path)}: {len(original)} -> {len(cleaned)} lines (-{diff})')
