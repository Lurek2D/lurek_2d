---
name: create-snippet
description: Create or update new snippet code for specific module with API.
---

# GOAL
- Author reusable code snippets for common tasks related to a specific module API.

# INPUTS REQUIRED
- Target module
- Common task description
= User must provide the specific use case requiring a snippet
- Agent must collect the most idiomatic API usage patterns

# STEPS TO DO
1. Load skills: documentation, lua-scripting.
2. Execute `python tools/audit/snippet_coverage.py` to identify missing snippets for highly-used public methods.
3. Write a fast, optimized VS Code-compatible snippet in the `tools/snippets/` folder. Ensure variables are correctly tokenized (e.g., `$1`, `$2`).
4. Execute `python tools/validate/validate_snippets.py`. If it returns exit code >0, fix the JSON structure of your snippet.
5. Execute `python tools/audit/snippet_coverage.py`. If the target API coverage is still <100%, return to step 3 to add missing methods.

# OUTPUTS PROVIDED
- Formatted code snippet file
- Snippet coverage validation

# SUCCESS CRITERIA
- `python tools/validate/validate_snippets.py` exits with code 0.
- `python tools/audit/snippet_coverage.py` reports exactly 100% coverage for the targeted snippet scope.

# ANIT PATTERNS
- Creating snippets that use deprecated APIs.
- Writing overly long snippets that should be full examples instead.

# REFERENCES
- skills: documentation, lua-scripting
- tools: python tools/audit/snippet_coverage.py, python tools/validate/validate_snippets.py
- agent: Doc-Writer
