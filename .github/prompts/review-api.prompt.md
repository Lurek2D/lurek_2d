---
name: review-api
description: Review lua api coverage (if public rust methods are covered by lua api wrapper, if they have properly thin layer, have proper paramers, returns, description all setup in code in lua_api module), fix all the gaps.
---

# GOAL
- Audit the Lua API bridge for completeness, "thin wrapper" compliance, and correctness.

# INPUTS REQUIRED
- Target module
= User specifies the module to review
- Agent must collect Rust source public methods and their Lua API counterparts

# STEPS TO DO
1. Load skills: lua-api-design, lua-rust-bridge.
2. Execute `python tools/audit/lua_covers_lurek_api_audit.py`. Identify the percentage of missing API wrappers.
3. Execute `python tools/audit/thin_wrapper_audit.py`. Identify the number of wrappers flagged as 'too fat'.
4. Refactor `src/lua_api/<module>_api.rs` to move complex logic back to `src/<module>/` and expose missing methods.
5. Execute both audit tools again. If either script reports <100% coverage or >0 fat wrappers, repeat step 4.

# OUTPUTS PROVIDED
- Refactored `src/lua_api/<module>_api.rs` files
- Clean audit tool reports

# SUCCESS CRITERIA
- `python tools/audit/lua_covers_lurek_api_audit.py` reports exactly 100% API coverage.
- `python tools/audit/thin_wrapper_audit.py` reports exactly 0 fat wrapper violations.

# ANIT PATTERNS
- Implementing complex state logic inside `*_api.rs` files.
- Exposing unsafe Rust internals directly to Lua without safe abstractions.

# REFERENCES
- skills: lua-api-design, lua-rust-bridge
- tools: python tools/audit/lua_covers_lurek_api_audit.py, python tools/audit/thin_wrapper_audit.py
- agent: Lua-Designer
