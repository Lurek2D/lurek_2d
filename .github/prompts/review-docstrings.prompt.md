---
name: review-docstrings
description: Review docstrings for specific module, on rust level evreything on methods, classes, objects, file level, ensure this follows practices and is being collected by scripts / tools.
---

# GOAL
- Audit Rust docstrings to ensure comprehensive docs-general that tooling can extract.

# INPUTS REQUIRED
- Target module
= User must provide the module to inspect
- Agent must collect Rust docstring standards and generator expectations

# STEPS TO DO
1. Load skills: docs-general, rust-coding.
2. Execute `python tools/audit/docstring_audit.py --module <module>`. Note the total count of undocumented items.
3. Open the flagged `.rs` files and write accurate `///` docstrings. Include rust-doc examples for public APIs.
4. Execute `cargo test --doc`. If any doc test fails (exit code >0), fix the rust-doc examples and repeat step 4.
5. Execute `python tools/audit/docstring_audit.py` again. If undocumented count is >0, return to step 3.

# OUTPUTS PROVIDED
- Updated `.rs` files with complete docstrings
- Clean `docstring_audit.py` report

# SUCCESS CRITERIA
- `python tools/audit/docstring_audit.py` reports exactly 0 missing docstrings.
- `cargo test --doc` exits with code 0 (100% doc test pass rate).

# ANIT PATTERNS
- Writing "dummy" docstrings just to pass the tool check.
- Documenting private items extensively while neglecting public APIs.

# REFERENCES
- skills: rust-coding, docs-general
- tools: python tools/audit/docstring_audit.py, cargo test
- agent: Doc-Writer
