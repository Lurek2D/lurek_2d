# Changelog

## Unreleased

- refactor(games): split `apps/household_finance_lab` into app-local Lua modules, SQL query files, binary dataframe cache tables, render-driven hitbox controls, a Widgets tab, and colocated Lua tests.
- feat(games): added the `apps/household_finance_lab` business/data-science demo with deterministic household finance CSV generation, dataframe/database analytics, binary cache output, UI charts/tables, logs, and anomaly detection.
- content(games): added `lurek.automation.update(...)` to all 132 game process callbacks, created packaged `automation_smoke.toml` replays for `cannon_fodder`, `settlers_rise`, `sensible_soccer`, `star_voyage`, `worms_artillery`, `boulder_dash`, `giana_sisters`, and `alchemy`, and refreshed `content/zips` so every `.lurek` archive includes the latest game-side automation assets.
- content(games): fixed dead input paths in `cannon_fodder`, `settlers_rise`, `sensible_soccer`, `star_voyage`, `worms_artillery`, `boulder_dash`, `giana_sisters`, and `alchemy` by restoring `lurek.process(dt)` adapters or proper action bindings, and documented that all 132 games still need a shared `lurek.automation.update(dt)` hook for mass replay validation.
- chore(examples): added a canonical sequential `lurek2d` sweep flow for `content/examples/*.lua` via `tools/demos/smoke_sweep.py`, exposed it as VS Code tasks, and documented the difference between real engine example runs and test harnesses.
- chore(build): restored the missing `crates/lurek_schema` path dependency so Cargo commands work again, moved the `cargo-nextest` config to `.cargo/nextest.toml`, and documented which Rust/build config files must remain in their fixed toolchain locations.
- content(examples): normalized every `--@api-stub` teaching comment to a single long-form usage line, added missing coverage for `lurek.physics.attachShape`, and reduced the most overgrown `scene`, `window`, and `physics` blocks to smaller one-API examples.
- docs(api): renamed Lureksome to Lureksome, moved generated library API outputs to `docs/api/lureksome.{md,lua}`, removed the legacy library-doc output directory, and updated docs/wiki/tooling references.
- chore(tools): removed one-off migration and single-batch cleanup scripts from `tools/`, kept the reusable long-term generators, validators, audits, and fixers, rewrote `tools/README.md` as the canonical single-file tool registry, and synced `tools/fix/README.md` with the retained fixer set.
