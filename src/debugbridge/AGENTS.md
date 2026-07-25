# Debugbridge Module Contract

## Mission & Scope
- Own live debug protocol, client sessions, print history, and hot-reload hooks.
- Keep remote control explicit and handshake-protected.

## Files
- `server.rs`: Protocol handling and request dispatch.
- `bridge.rs`: Shared bridge state, commands, and runtime handoff.

## Rules
- Require the session handshake before protected commands.
- Never let malformed JSON or unknown methods panic the server thread.
- Keep screenshot, eval, and hot-reload requests queued through runtime flags.

## Workflow
- Validate with `cargo test --test debugbridge_tests`.
