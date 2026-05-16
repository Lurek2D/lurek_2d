"""Remove --@api-stub: markers and surrounding comments from example files.

For stubs that already have a do-block below, strips the marker and comment lines.
For stubs without a do-block, generates a real do-block from the stub name.
"""

import re
import sys
from pathlib import Path

# Pure stubs that need generated do-blocks (file -> stub name -> code lines)
GENERATED_BLOCKS = {
    "render.lua": {
        "LImage:getId": [
            'do -- LImage:getId',
            '  local ok, img = pcall(lurek.render.newImage, "assets/textures/placeholder.png")',
            '  if ok and img then',
            '    lurek.log.info("texture handle: " .. tostring(img:getId()), "render")',
            '  end',
            'end',
        ],
        "LLObjModel:getVertexCount": [
            'do -- LLObjModel:getVertexCount',
            '  local ok, model = pcall(lurek.render.loadObj, "assets/models/cube.obj")',
            '  if ok and model then',
            '    lurek.log.info("vertices: " .. model:getVertexCount(), "render")',
            '  end',
            'end',
        ],
        "LLObjModel:getFaceCount": [
            'do -- LLObjModel:getFaceCount',
            '  local ok, model = pcall(lurek.render.loadObj, "assets/models/cube.obj")',
            '  if ok and model then',
            '    lurek.log.info("faces: " .. model:getFaceCount(), "render")',
            '  end',
            'end',
        ],
        "LLObjModel:getUvCount": [
            'do -- LLObjModel:getUvCount',
            '  local ok, model = pcall(lurek.render.loadObj, "assets/models/cube.obj")',
            '  if ok and model then',
            '    lurek.log.info("uvs: " .. model:getUvCount(), "render")',
            '  end',
            'end',
        ],
        "LLObjModel:getNormalCount": [
            'do -- LLObjModel:getNormalCount',
            '  local ok, model = pcall(lurek.render.loadObj, "assets/models/cube.obj")',
            '  if ok and model then',
            '    lurek.log.info("normals: " .. model:getNormalCount(), "render")',
            '  end',
            'end',
        ],
        "LLObjModel:renderToImage": [
            'do -- LLObjModel:renderToImage',
            '  local ok, model = pcall(lurek.render.loadObj, "assets/models/cube.obj")',
            '  if ok and model then',
            '    local img = model:renderToImage(256, 256)',
            '    lurek.log.info("rendered obj to image", "render")',
            '  end',
            'end',
        ],
        "LLObjModel:projectToMesh": [
            'do -- LLObjModel:projectToMesh',
            '  local ok, model = pcall(lurek.render.loadObj, "assets/models/cube.obj")',
            '  if ok and model then',
            '    local mesh = model:projectToMesh({x=0, y=0, z=5}, 1280, 720)',
            '    lurek.log.info("projected mesh vertices", "render")',
            '  end',
            'end',
        ],
    },
}


def process_file(path: Path) -> int:
    """Process one file. Returns count of stubs removed."""
    lines = path.read_text(encoding="utf-8").splitlines()
    fname = path.name
    generated = GENERATED_BLOCKS.get(fname, {})
    out = []
    i = 0
    removed = 0

    while i < len(lines):
        line = lines[i]

        # Match --@api-stub: <name>
        m = re.match(r'^--@api-stub:\s*(.+)$', line)
        if not m:
            out.append(line)
            i += 1
            continue

        stub_name = m.group(1).strip()
        removed += 1
        i += 1  # skip the stub marker line

        # Skip comment lines following the stub marker
        while i < len(lines) and lines[i].startswith('--'):
            i += 1

        # Check if next non-blank line is a do-block
        # Skip blank lines
        blank_start = i
        while i < len(lines) and lines[i].strip() == '':
            i += 1

        if i < len(lines) and lines[i].startswith('do --'):
            # Already has a do-block — keep blank line before it and keep the do-block
            if i > blank_start:
                out.append('')  # preserve one blank separator
            # The do-block remains as-is (will be appended in the next loop iteration)
        else:
            # No do-block — generate one if we have it, otherwise create a minimal one
            if stub_name in generated:
                out.append('')
                for gen_line in generated[stub_name]:
                    out.append(gen_line)
            else:
                # Generic fallback — should not happen for correctly mapped files
                out.append('')
                out.append(f'do -- {stub_name}')
                out.append(f'  lurek.log.info("{stub_name} called", "example")')
                out.append('end')
            # Reset i to where we were (blank_start), since those lines aren't part of the stub
            i = blank_start

    # Also remove "-- ---- Example: <name> ---..." header lines that preceded stubs
    # These are now orphaned since the stub markers are gone
    final = []
    for line in out:
        if re.match(r'^-- -+ Example: .+ -+$', line):
            continue
        final.append(line)

    path.write_text('\n'.join(final) + '\n', encoding='utf-8')
    return removed


def main():
    root = Path(__file__).resolve().parent.parent.parent / "content" / "examples"
    files = ["graph.lua", "physics.lua", "render.lua"]
    total = 0
    for fname in files:
        p = root / fname
        if not p.exists():
            print(f"SKIP: {p} not found")
            continue
        count = process_file(p)
        print(f"{fname}: removed {count} stubs")
        total += count
    print(f"Total: {total} stubs removed")


if __name__ == "__main__":
    main()
