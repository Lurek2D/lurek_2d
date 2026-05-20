import os
import re
from pathlib import Path
root = Path.cwd()
ex_dir = root / "content" / "examples"
funcs = ["newImage", "newFont", "newSource", "newDecoder", "loadLayoutFile", "loadDocument", "mountZip", "setCookie", "setNormalMap", "loadObj", "loadModel", "setIcon", "watch", "toAbsolutePath"]
missing = []
if ex_dir.exists():
    for f in sorted(ex_dir.rglob("*.lua")):
        content = f.read_text("utf-8", "replace").splitlines()
        for i, l in enumerate(content, 1):
            if any(fn in l for fn in funcs):
