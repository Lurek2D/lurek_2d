---
name: review-quality
description: Review overall code quality using tools/audit/quality_report.py.
---

# GOAL
- Perform a holistic quality review of the codebase using comprehensive reporting tools.

# INPUTS REQUIRED
- Target module or full codebase
= User triggers the general quality audit
- Agent must collect output from `quality_report.py`

# STEPS TO DO
1. Load skills: quality-pipeline, rust-coding.
2. Execute `python tools/audit/quality_report.py`. Capture the number of critical warnings and code smells.
3. Execute `cargo clippy -- -D warnings`. Note any linting violations.
4. Refactor the codebase to address the identified warnings and complex blocks.
5. Execute both tools again. If `quality_report.py` returns >0 warnings or `cargo clippy` exits with >0, repeat step 4.

# OUTPUTS PROVIDED
- Code quality fixes (Rust/Lua changes)
- Cleaned quality report output

# SUCCESS CRITERIA
- [ ] `python tools/audit/quality_report.py` reports exactly 0 critical warnings.
- [ ] `cargo clippy -- -D warnings` exits with code 0 (exactly 0 warnings).

# ANTI-PATTERNS
- Suppressing lints or warnings instead of fixing the underlying issue.
- Conducting mass refactors that break existing stable APIs.

# EXAMPLE INVOCATION
- User: "request for this prompt"
- Agent: Runs this prompt workflow with provided constraints and reports changed files plus validation evidence.

# REFERENCES
- skills: quality-pipeline, rust-coding
- tools: python tools/audit/quality_report.py, cargo clippy
- agent: Verifier


