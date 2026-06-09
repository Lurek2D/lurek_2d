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
- Run code generation tasks via `python tools/gen_all_docs.py` before committing changes to source headers.
- Run complete workspace checks with `python tools/validate/cag_validate.py`.

## References
- tools/validate/cag_validate.py
- tools/audit/cag_link_check.py
- tools/rag/
