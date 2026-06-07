import re

path = r'c:\Users\tombl\Documents\lurek_2D\src\render\gpu_renderer.rs'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

lines = text.split('\n')

doc_comments = []
use_statements = []
other_lines = []

in_use_block = False

for line in lines:
    if line.startswith('//!'):
        doc_comments.append(line)
    elif line.startswith('use ') or (in_use_block and line.strip() != '' and not line.startswith('///') and not line.startswith('pub ') and not line.startswith('impl ')):
        # Very simple heuristic for multi-line use statements
        use_statements.append(line)
        if not line.endswith(';'):
            in_use_block = True
        else:
            in_use_block = False
    elif in_use_block and line.strip() == '':
        use_statements.append(line)
    else:
        in_use_block = False
        other_lines.append(line)

new_content = '\n'.join(doc_comments) + '\n\n' + '\n'.join(use_statements) + '\n\n' + '\n'.join(other_lines)

# Also, since I am completely reorganizing, let me make sure we don't have duplicate use statements
# Wait, let's just make sure all use statements are at the top.

# Need to add `use crate::render::gpu_types::*;` as well.
if 'use crate::render::gpu_types::*;' not in new_content:
    new_content = new_content.replace('\n\n', '\nuse crate::render::gpu_types::*;\n\n', 1)

with open(path, 'w', encoding='utf-8') as f:
    f.write(new_content)

print('Rearranged gpu_renderer.rs')
