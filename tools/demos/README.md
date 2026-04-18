# tools/demos/

Demo-folder maintenance for `content/demos/`: structural fixes and screenshot regeneration.

## Scripts

- **`organize_demos.py`** — Three-in-one demos maintenance tool (rename/sort/normalise structure). Usage: `python tools/demos/organize_demos.py [--dry-run]`.
- **`gen_demo_screenshots.py`** — Capture a `screen.png` for every Lurek2D demo by launching the release binary headlessly. Usage: `python tools/demos/gen_demo_screenshots.py [--demo NAME]`.

> Note: a second copy of `gen_demo_screenshots.py` lives under `tools/screenshots/` for historical reasons; both are kept until callers migrate. Prefer this one.
