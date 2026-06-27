# agent manual spec overlay

## TL;DR

- Orchestrates multi-agent AI completions and stateful conversations.
- Supports tiered, persistent working, episodic, and semantic memory.
- Manages local Ollama lifecycles and background request polling over local plain HTTP.

## Summary

- The `agent` module is the engine's AI-assistant surface for users who want LLM-backed behavior inside the runtime without building transport, memory, and orchestration infrastructure from scratch.
- It turns raw model calls into an engine feature by combining direct chat, structured outputs, embeddings, background request transport, and named agent configuration in one subsystem.
- Working, episodic, and semantic memory are central because the module is designed for repeated interaction, not only for one-shot completions.
- That memory model matters because a useful assistant usually needs continuity: it should keep recent context, retain important facts, and support longer-lived agent identities instead of acting like a stateless prompt box.
- Polling, retries, and background lifecycle handling matter because real agent workflows are often slow, asynchronous, or multi-stage.
- Runtime HTTP transport is intentionally narrow: local `http://host:port/path` only, intended for Ollama endpoints such as `http://127.0.0.1:11434/api/generate`.
- HTTPS, TLS, redirects, gzip, and streaming/chunked responses are not part of the runtime agent transport. Attempts to use HTTPS are rejected with `Ollama agent runtime supports local plain HTTP only`.
- Structured responses broaden the feature beyond conversational prose into tool-friendly outputs that other systems can consume reliably.
- Embeddings support is equally important because retrieval, similarity search, and grounding workflows often matter as much as text generation itself.
- This makes the module useful not only for chat-like helpers, but also for assistants that classify, retrieve, summarize, or fill structured records as part of larger tool or content workflows.
- Orchestration support matters because several named agents may need different prompts, memory scopes, and response rules while still living under one runtime surface.
- The module is useful for tool copilots, content helpers, QA utilities, retrieval-backed assistants, and other workflows where model access should feel native to the engine.
- `agent` owns prompts, memory, agent identity, structured responses, and request orchestration semantics.
- Read `agent` as the place where assistants become first-class runtime capabilities rather than thin HTTP wrappers.

This module owns its small local Ollama HTTP client rather than depending on `network`. Its responsibility should stay inside the `Feature Systems` group rather than absorb behavior owned by those neighbors.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
