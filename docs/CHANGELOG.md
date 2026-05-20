# Changelog

## Unreleased

- docs(wiki): refreshed the repository wiki from the current generated API and example corpus, synced module pages with the latest `content/examples/*.lua` snippets, standardized generated API entries to the new `Definition` / `Description` / `Example` layout, removed useless LuaCATS pseudo-definitions from `Module Types`, added module source-file sections from `docs/specs/*.md`, grouped method navigation by object instead of listing every method in the table of contents, and aligned `tools/audit/wiki_coverage.py` with the generated `Module-*.md` page layout and Lua API module aliases.
- chore(examples): added a canonical sequential `lurek2d` sweep flow for `content/examples/*.lua` via `tools/demos/smoke_sweep.py`, exposed it as VS Code tasks, and documented the difference between real engine example runs and test harnesses.
- chore(build): restored the missing `crates/lurek_schema` path dependency so Cargo commands work again, moved the `cargo-nextest` config to `.cargo/nextest.toml`, and documented which Rust/build config files must remain in their fixed toolchain locations.
- content(examples): normalized every `--@api-stub` teaching comment to a single long-form usage line, added missing coverage for `lurek.physics.attachShape`, and reduced the most overgrown `scene`, `window`, and `physics` blocks to smaller one-API examples.
- docs(api): renamed Lureksome to Lureksome, moved generated library API outputs to `docs/api/lureksome.{md,lua}`, removed the legacy library-doc output directory, and updated docs/wiki/tooling references.
- chore(tools): removed one-off migration and single-batch cleanup scripts from `tools/`, kept the reusable long-term generators, validators, audits, and fixers, rewrote `tools/README.md` as the canonical single-file tool registry, and synced `tools/fix/README.md` with the retained fixer set.
