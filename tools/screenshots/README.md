# tools/screenshots/

Legacy location for demo-screenshot capture. New callers should prefer [`tools/demos/`](../demos/README.md).

## Scripts

- **`gen_demo_screenshots.py`** — Capture a `screen.png` for every Lurek2D demo by launching the release binary headlessly. Usage: `python tools/screenshots/gen_demo_screenshots.py [--demo NAME]`.

This script is a drop-in duplicate of `tools/demos/gen_demo_screenshots.py`; kept for backward compatibility with older docs and CI references.
