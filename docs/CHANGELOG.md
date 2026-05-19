# Changelog

## Unreleased

- docs(api): renamed Lureksome to Lureksome, moved generated library API outputs to `docs/api/lureksome.{md,lua}`, removed the legacy library-doc output directory, and updated docs/wiki/tooling references.
- chore(tools): removed one-off migration and single-batch cleanup scripts from `tools/`, kept the reusable long-term generators, validators, audits, and fixers, rewrote `tools/README.md` as the canonical single-file tool registry, and synced `tools/fix/README.md` with the retained fixer set.
