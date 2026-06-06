# agent

## General Info

- Module group: `Feature Systems`
- Source path: `src/agent/`
- Binding: `src/lua_api/agent_api.rs`
- Namespace: `lurek.agent`
- Lua API surface: `17` functions, `10` types, `85` methods
- Rust test path(s): tests/rust/unit/agent_tests.rs
- Lua test path(s): tests/lua/unit/test_agent_core_unit.lua

## Summary

The agent module provides a complete artificial intelligence and language model capability layer for the Lurek2D engine runtime, enabling gameplay scripts to integrate smart behaviors and dynamic conversations. It establishes stateful and stateless interface models that allow game entities to interact with large language models, perform text prompt completions, execute structured JSON requests, and generate text embeddings directly within the live simulation framework.

To support long-term reasoning and context-aware interactions, the module supplies a robust, tiered agent memory system. Scripts can utilize bounded first-in-first-out working memory for immediate conversation contexts, append-only episodic memory to log and query timestamped game events, and unbounded semantic memory to retain key-value facts. These tiers can be unified into a cohesive memory bundle that supports saving and loading across sessions for persistent player-agent history.

For complex multi-agent simulation scenarios, the module exposes high-level orchestration architectures like multi-agent managers and intelligent AI systems. Developers can register several distinct agent profiles with specialized roles, supply explicit instructions, and define keyword-gated systems that automatically inject relevant skill prompts based on user input. This setup coordinates parallel execution flows and schedules background processing seamlessly.

Additionally, the module takes charge of local Ollama infrastructure management, providing complete control over server processes, model downloads, and operational status checks. By handling network transport details—such as request retries, time-out bounds, task cancellations, and frame-safe background polling—the runtime isolates gameplay loops from networking latency, ensuring deterministic frame updates and stable performance.

## Files

### [chat.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/agent/chat.rs)

- Implements the direct synchronous conversation surface for immediate model-backed agent interactions.
- Builds deterministic request envelopes for plain text, structured JSON, and embedding-oriented calls.
- Preserves reusable global provider configuration so repeated invocations share one operational baseline.
- Maintains multi-turn message history for session continuity and contextual follow-up reasoning.
- Applies lightweight prompt templating to inject runtime variables without changing call contracts.
- Normalizes backend responses into stable Lua-facing shapes with predictable field semantics.

### [client.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/agent/client.rs)

- Provides asynchronous prompt transport that moves network latency off the main update path.
- Tracks in-flight requests and pending completions so polling remains deterministic and frame-safe.
- Supports callback-scoped cancellation to discard stale results after gameplay state has changed.
- Retries transient transport failures with bounded backoff to improve completion reliability.
- Bridges worker-thread execution and runtime polling with consistent response delivery semantics.

### [memory.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/agent/memory.rs)

- Implements layered agent memory with short-term context, episodic recall, and durable semantic knowledge.
- Applies distinct retention strategies so each memory tier fits a different reasoning horizon.
- Supports bounded working slots for prompt context while preserving ordered recency behavior.
- Records timestamped episodes for searchable event history and narrative continuity.
- Stores semantic facts as named durable entries that survive immediate conversational churn.
- Provides aggregate save and load flows for cross-session continuity of memory state.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/agent/mod.rs)

- Defines the `agent` domain module boundary for LLM-backed behavior.
- Contains transport, state, memory, orchestration logic, and Ollama lifecycle components.
- Keeps Lua binding/runtime details out of this layer so `src/lua_api/` stays the integration boundary.

### [ollama.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/agent/ollama.rs)

- Provides backend infrastructure control for local Ollama service lifecycle and operational health checks.
- Handles start, stop, restart, and version discovery to keep runtime integration state observable.
- Exposes model inventory queries and availability checks for capability-aware script decisions.
- Supports model deletion and asynchronous pull workflows with pollable completion tracking.
- Isolates backend process management from prompt orchestration to keep runtime layering clean.
- Normalizes infrastructure outcomes into stable results consumed by higher agent control surfaces.

### [orchestration.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/agent/orchestration.rs)

- Agent orchestration logic extracted from Lua runtime glue.
- Owns batch-task data contracts, callback ID packing, and system-context assembly.
- This module is runtime-agnostic and intentionally free of `mlua` types.

### [state.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/agent/state.rs)

- Defines runtime state contracts that shape outbound agent requests from script-facing configuration.
- Aggregates endpoint, model, prompt policy, timeout, and retry controls into deterministic payload inputs.
- Builds direct and system-routed request variants with consistent field and option mapping.
- Composes AI-system context from instructions and skill fragments matched to prompt intent signals.
- Keeps mutable control state separate from transport execution to preserve predictable behavior boundaries.
- Bridges Lua runtime controls to transport-ready request structures without duplicating orchestration logic.

### [types.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/agent/types.rs)

- Defines shared data contracts for agent requests, responses, and cross-layer failure representation.
- Aligns state construction, async transport, and callback dispatch on one stable payload vocabulary.
- Encodes retry semantics and error categories so runtime behavior is consistent across entry points.
- Serves as the canonical contract layer that keeps agent submodules interoperable and predictable.
