# IDEA — docs

| Field  | Value            |
| ------ | ---------------- |
| Module | `docs`           |
| Path   | `src/docs/`      |
| Date   | 2026-04-18       |
| Tier   | Edge/Integration |

## Mission

Provide Lurek2D's in-engine API documentation catalog and runtime data-validation schema system: structured `DocEntry` metadata for every `lurek.*` API item, a queryable `Catalog` with search/filter, quality scoring and grading, VS Code IntelliSense export (completions/hover/signatures JSON), and a `Schema` validator for game config, save-data, and mod manifests — all accessible from Lua via `lurek.docs.*`.

## Strengths

- **Dual-purpose module** — documentation catalog and schema validation share the same infrastructure but serve distinct needs (IntelliSense vs runtime data contracts).
- **Quality scoring pipeline** — `quality_score()` / `quality_grade()` / `QualityReport` quantify documentation completeness per entry and per module, enabling automated doc audits.
- **Editor integration** — `export.rs` directly outputs VS Code `CompletionItem`, hover, and signature-help JSON formats, bridging engine metadata to IDE tooling.

## Gaps

- Tests were moved out of `src/docs/*` into `tests/rust/unit/docs_tests.rs` (policy-compliant, no `#[cfg(test)]` in `src/`).
- `export.rs` now uses shared JSON builders and buffered writes.
- `Schema::validate_pairs` now accepts non-static `&str` lifetimes.

## Features — Competitor Comparison

| Feature                        | Lurek2D (docs)                 | LÖVE2D                 | Godot 4                                  |
| ------------------------------ | ------------------------------ | ---------------------- | ---------------------------------------- |
| In-engine API catalog          | ✅ Structured DocEntry + search | ❌ External wiki only   | ✅ ClassDB, but not queryable from script |
| Schema validation for configs  | ✅ FieldRule with enum/bounds   | ❌ No built-in schema   | ❌ Manual GDScript validation             |
| IDE export (completions/hover) | ✅ JSON export for VS Code      | ❌ Community extensions | ✅ Built-in LSP                           |

## Performance / Quality

- `Catalog` is a flat `Vec<DocEntry>` with linear scan for search/filter — fine for API sizes <5000 entries; would need indexing for larger catalogs.
- `quality_score` allocates no heap memory per call (simple counter arithmetic).
- `Schema::validate_pairs` iterates rules and fields independently — O(rules + fields) per validation.

## Test Gaps

- Added targeted coverage in `tests/rust/unit/docs_tests.rs` for:
	- `ParamInfo` and `ReturnInfo` edge cases,
	- `export_all` compact hover variant,
	- `Schema` string length bounds,
	- `QualityReport::compute` with mixed modules,
	- `Catalog::merge` and `Schema::from_toml`.

## TODO(dedup)

- [x] `export_all` duplicates the completions/hover JSON building logic from `export_completions`/`export_hover` — extract a shared builder.

## TODO(helper)

- [x] Relax `validate_pairs` type parameter from `&'static str` to `&str` for flexibility.
- [x] Add `Catalog::merge(other: &Catalog)` to combine catalogs from multiple sources (e.g. plugin doc entries).
- [x] Add `Schema::from_toml(s: &str)` to load schema rules from TOML files (per binding constraint B-05).

## TODO(plugin)

- [ ] Not a plugin candidate — `docs` is Edge/Integration tier and serves engine infrastructure.
- [ ] However, the schema validator could be extracted as a lightweight standalone crate usable by mod authors.

## References

- `docs/specs/docs.md` — module spec
- `src/lua_api/docs_api.rs` — Lua bridge
- `tests/lua/unit/test_docs.lua` — Lua test suite
- `extensions/vscode/` — VS Code extension consuming export JSON
