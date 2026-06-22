# debugbridge manual spec overlay

## TL;DR

- Connects the game runtime to external editor panels.

## Summary

- The `debugbridge` module is the remote inspection channel between a running game and external development tools such as the VS Code extension or MCP-style clients.
- It owns the bridge state, network protocol, queued requests and responses, print-history streaming, and guarded remote operations such as screenshots or hot reload requests.
- Read it as the integration boundary for external observability: gameplay systems do not need to know editor protocols, because `debugbridge` translates between runtime state and tool clients.

This module is mostly self-contained inside the Edge/Integration group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
