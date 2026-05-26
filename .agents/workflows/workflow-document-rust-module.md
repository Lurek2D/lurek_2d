---
trigger: manual
description: "Audit and complete Rust docs in src/<module>/ by following rust-coding skill rules as the single source of truth, then verify with quality checks."
expected_agent: "Manager"
---

# Workflow: Document Rust Module

## Goal
- Every `.rs` file in `src/<module>/` (including `mod.rs`) has complete docs per `rust-coding` skill rules.
- Apply a strict loop: read file → add missing docs per skill → save → next file.
- All `#[cfg(test)]` blocks are moved out to `tests/rust/unit/<module>_<file>_tests.rs`.
- **Do not run build or task commands during comment-only edits unless the user explicitly asks.**

> All doc formatting rules live in `../rules/skill_rust-coding.md`. Do not restate them here.

## Inputs
- `module` — the module directory to process (e.g. `physics`, `render`, `audio`).

## Documentation Rules
Single source of truth: `../rules/skill_rust-coding.md`. All formatting rules are there.
If this prompt and the skill disagree on style, the skill wins.

## Required Non-style Rules
For every file in `src/<module>/` that has inline tests:
1. Extract the full `mod tests { ... }` block.
2. Create `tests/rust/unit/<module>_<file>_tests.rs`.
3. Adjust imports: replace `use super::*;` with explicit imports from the crate root using `use lurek2d::<module>::...;`.
4. Delete the extracted block from the source file.
5. If the repo has a unit-test registry module, add `pub mod <module>_<file>_tests;` there.

For every `mod.rs` in scope:
- Keep only `pub mod`, `pub use`, attributes, and module docs.
- Move any definitions to sibling files and re-export from `mod.rs`.

## Steps

1. Load [skill: rust-coding](../rules/skill_rust-coding.md) and [skill: documentation](../rules/skill_documentation.md) before acting.

2. **Fix tests first** — Extract all `#[cfg(test)]` blocks from source files, create the corresponding `tests/rust/unit/` files, and update `mod.rs` registration.

3. **Strict file loop** — For every `.rs` file in `src/<module>/` (including `mod.rs`):
   - Read current file.
   - Add or fix missing comments exactly per `rust-coding` skill.
   - Save file.
   - Continue to next file.

4. **Verify (only when user asks)** — Run `cargo check` and `cargo clippy -- -D warnings` only if the user explicitly requests validation.

5. **Report** — Return a table:
   `File | Skill-doc status | Tests moved | Issues remaining`
   Any remaining issue must be listed with the exact file, line, and reason it could not be fixed.

## Success Criteria
- [ ] Every `.rs` file in `src/<module>/` including `mod.rs` follows current `rust-coding` skill doc rules.
- [ ] Zero `#[cfg(test)]` blocks remain in `src/<module>/`.
- No build or task command is run unless the user explicitly requests it.

## Anti-patterns
- Skipping the read → add docs → save loop for any file.
- Leaving `#[cfg(test)]` in place instead of moving it.
- Inventing doc content that contradicts the implementation.
- Adding `// TODO`, `// FIXME`, or `// HACK` markers — those belong in a separate issue.
- Touching files outside `src/<module>/` or `tests/rust/unit/`.
- Running build/task/validation commands without explicit user request.

## Example Invocation
- `/workflow-document-rust-module module=physics`
- `/workflow-document-rust-module module=render`
- `/workflow-document-rust-module module=audio`

## CAG Metadata
Mode: agent
Loads skills: rust-coding, documentation
Inputs required: Target module directory name (e.g. physics, render, audio).
