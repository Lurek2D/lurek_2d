# Tools Contract

Adds local rules for `tools/`.

## Mission & Scope
- Own repo scripting tools, generators, formatting scripts, and release packaging logic.
- Keep workspace routines automated, repeatable, and self-contained.
- Maintain policy gates, link checks, and doc generators.

## Files
- `audit/`: Audit scripts for docstrings, examples, and links.
- `validate/`: Validation suites verifying file schemas and CAG constraints.
- `rag/`: Vector index and similarity query engine for workspace search.
- `gen_all_docs.py`: Umbrella documentation build script.

## Rules
- Avoid CI-only script setups; all build, packaging, and validation steps must be runnable locally on Windows.
- Keep tool dependencies minimal; pin third-party Python or shell packages explicitly in tool documentation.
- All code generation tools must output relative file paths inside the workspace directory.
- Run build and QA checks in speed order: light syntax and link checks before heavy cargo compiles.

## Workflow
- Start from the nearest nested tools contract or tool README before changing a tool family.
- Run only the generator, audit, or validator that matches the edited tool area before escalating to broader workspace checks.
- Run complete workspace checks with `tools/python.cmd tools/validate/cag_validate.py` when tool changes affect shared contracts, generators, or CAG metadata.

## References
- tools/validate/cag_validate.py
- tools/audit/cag_link_check.py
- tools/rag/

