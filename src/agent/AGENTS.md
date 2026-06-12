# Agent Module Contract

## Mission & Scope
- Own LLM request state, async transport, retries, and callback payloads.
- Keep provider/network failure modes explicit and Lua-safe.

## Files
- `state.rs`: Request shaping and skill/instruction context.
- `client.rs`, `types.rs`: Transport execution and shared payload contracts.

## Rules
- Never block the frame loop on model I/O; use request IDs and polling.
- Preserve stable error codes and transient retry semantics.
- Keep prompts/options serializable without leaking backend-specific structs.

## Workflow
- Validate with `cargo test --test agent_tests`.
