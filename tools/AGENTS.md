# Tools Contract

Covers work under `tools/`.

## Mission & Scope
- Own the repository's scripting tools, code generator pipelines, code formatting and styling scripts, and release packaging logic.
- Keep workspace development routines automated, repeatable, and fully self-contained.
- Enforce policy gates, static link checks, and documentation generation scripts.

## Files
- `audit/`: Auditing scripts verifying doc strings, examples, and link structures.
- `validate/`: Validation suites verifying file schemas and CAG constraints.
- `rag/`: Vector embedding and similarity query engine used for workspace search.
- `gen_all_docs.py`: Umbrella documentation build script.

## Rules
- Avoid CI-only script setups; all build, packaging, and validation steps must be runnable locally on Windows.
- Keep tool dependencies minimal; pin third-party Python or shell packages explicitly in tool documentation.
- All code generation tools must output relative file paths inside the workspace directory.
- Keep build/quality assurance checks ordered by speed, running lightweight syntax and link checkers before executing heavy cargo compiles.

## Workflow
- Start from the nearest nested tools contract or tool README before changing a specific tool family.
- Run only the generator, audit, or validator that matches the edited tool area before escalating to broader workspace checks.
- Run complete workspace checks with `python tools/validate/cag_validate.py` when tool changes affect shared contracts, generators, or CAG metadata.

## References
- tools/validate/cag_validate.py
- tools/audit/cag_link_check.py
- tools/rag/
