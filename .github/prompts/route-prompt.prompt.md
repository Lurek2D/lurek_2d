---
name: route-prompt
description: Find the best prompt for the current work context.
---

# GOAL
- Identify the single most appropriate prompt for a user's request so the user can invoke it immediately.

# INPUTS REQUIRED
- User's request description (natural language)
- Optional: known agent name or domain constraint
= User provides the work objective
- Agent must collect available prompts in `.github/prompts2/`

# STEPS TO DO
1. Load skills: cag-routing, docs-general.
2. Read the user's natural language request. Categorize it to a primary domain (e.g., Rust engine, Lua API, testing).
3. Identify the owning agent from the CAG architecture rules that is responsible for that domain.
4. Scan `.github/prompts2/` to find the prompt whose `description` or `goal` directly solves the user's request.
5. Print the single best-matching prompt, detailing its agent, required skills, and provide a filled-out example invocation command. Do not guess or invent files.

# OUTPUTS PROVIDED
- Recommendation output block with prompt details
- Filled-in example invocation line

# SUCCESS CRITERIA
- Output lists exactly 1 prompt matching the request's domain.
- The printed invocation command contains 0 generic placeholders and 100% real values from the user's context.

# ANIT PATTERNS
- Nominating multiple prompts without a clear recommendation.
- Inventing prompt filenames that don't exist.

# REFERENCES
- skills: cag-routing, docs-general
- tools: file system read over `.github/prompts2/`
- agent: Manager
