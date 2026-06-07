#!/usr/bin/env python3
"""Remove deprecated prompts and rename remaining create-oriented prompts."""

from pathlib import Path

PROMPTS = Path('.github/prompts')
ALLOWED_PREFIXES = (
    'create-',
    'add-',
    'author-',
    'design-',
    'doc-',
    'extend-',
    'flesh-',
    'generate-',
    'implement-',
)
RENAMES = {
    'author-ui-layout.prompt.md': 'create-ui-layout.prompt.md',
    'add-cag-artifact.prompt.md': 'create-cag-artifact.prompt.md',
    'add-visual-effect.prompt.md': 'create-visual-effect.prompt.md',
    'design-api-surface.prompt.md': 'create-api-surface.prompt.md',
    'design-game-ai.prompt.md': 'create-game-ai.prompt.md',
    'doc-api-reference.prompt.md': 'create-api-reference.prompt.md',
    'extend-vscode-extension.prompt.md': 'create-vscode-extension.prompt.md',
    'flesh-out-example.prompt.md': 'create-example-enhancement.prompt.md',
    'implement-lua-api-module.prompt.md': 'create-lua-api-module.prompt.md',
    'implement-roadmap-phase.prompt.md': 'create-roadmap-phase-implementation.prompt.md',
    'generate-roadmap-phase-from-description.prompt.md': 'create-roadmap-phase-from-description.prompt.md',
}

for path in sorted(PROMPTS.glob('*.prompt.md')):
    if path.name in RENAMES:
        new_path = PROMPTS / RENAMES[path.name]
        if new_path.exists():
            raise SystemExit(f'Collision: {new_path} already exists')
        path.rename(new_path)
        print('renamed', path.name, '->', new_path.name)
        path = new_path

    if not any(path.stem.startswith(prefix) for prefix in ALLOWED_PREFIXES):
        path.unlink()
        print('removed', path.name)
