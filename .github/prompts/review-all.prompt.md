---
name: review-all
description: Perform all below reviews one by one.
---

# GOAL
- Execute a comprehensive suite of review prompts sequentially to ensure full repository health.

# INPUTS REQUIRED
- Target module or entire repo scope
= User specifies the scope of the full review sweep
- Agent must collect the list of all review prompts

# STEPS TO DO
1. Load skills: quality-pipeline.
2. Trigger `review-docstrings` and ensure `docstring_audit.py` returns 0 gaps.
3. Trigger `review-api` and ensure `thin_wrapper_audit.py` returns 0 issues.
4. Trigger `review-examples` and `review-tests` ensuring coverage tools return 100%.
5. Trigger `review-specs` and `review-architecture` ensuring `cag_link_check.py` returns 0 broken links.
6. Trigger `review-performance` and `review-quality` ensuring `quality_report.py` returns 0 critical warnings. If any tool fails (exit code >0), halt the sweep, fix the issue, and restart the specific review.

# OUTPUTS PROVIDED
- A comprehensive review artifact detailing gaps across all areas
- Execution logs of all sub-reviews

# SUCCESS CRITERIA
- All 8 underlying audit and validation scripts exit with code 0.
- Test coverage and example coverage reports hit exactly 100%.

# ANIT PATTERNS
- Skipping a failing review stage instead of recording the failure.
- Generating an overwhelmingly large report without prioritizing critical issues.

# REFERENCES
- skills: quality-pipeline
- tools: All audit tools
- agent: Verifier
