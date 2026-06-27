# Agent

## Purpose

Orchestrates multi-agent AI completions and stateful conversations.

## When To Use

- It turns raw model calls into an engine feature by combining direct chat, structured outputs, embeddings, background request transport, and named agent configuration in one subsystem.
- Working, episodic, and semantic memory are central because the module is designed for repeated interaction, not only for one-shot completions.
- That memory model matters because a useful assistant usually needs continuity: it should keep recent context, retain important facts, and support longer-lived agent identities instead of acting like a stateless prompt box.

## Minimal Example

Example block: `lurek.agent.new`

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local agent = lurek.agent.new({
        url          = "http://127.0.0.1:9/api/generate",
        model        = "offline-test-model",
        timeout      = 1,
        max_retries  = 0,
        system_prompt = "You are a helpful game AI.",
        format       = "json",
        name         = "helper",
        description  = "Provides general assistance to the player.",
        options      = {
            num_ctx     = 4096,
            temperature = 0.7,
            seed        = 42,
        },
    })
    example_print_log("Agent created:", agent)
end
```

## Common Patterns

- Start with `lurek.agent.cancel` when exploring this module.
- Start with `lurek.agent.complete` when exploring this module.
- Start with `lurek.agent.completeAsync` when exploring this module.
- Start with `lurek.agent.completeJson` when exploring this module.
- Start with `lurek.agent.configure` when exploring this module.

## API Reference

- This page is the generated API reference for this module.

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

## Functions

### `lurek.agent.cancel`

Cancels a module-level asynchronous completion by callback ID.

```lua
lurek.agent.cancel(callback_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback_id` | number | ID returned by `completeAsync`. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pending_before = lurek.agent.pendingCount()
    lurek.agent.cancel(999999)
    local pending_after = lurek.agent.pendingCount()
    lurek.log.info("cancel issued for unknown callback id")
    lurek.log.info("pending before cancel=" .. tostring(pending_before))
    lurek.log.info("pending after cancel=" .. tostring(pending_after))
end
```

---

### `lurek.agent.complete`

Sends a single prompt to the global LLM and returns the response text.

```lua
lurek.agent.complete(prompt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `prompt` | string | Prompt text. |

**Returns**

| Type | Description |
|------|-------------|
| string | Response text, or raises an error on failure. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ok, reply = pcall(function()
        return lurek.agent.complete("Hello, world!")
    end)
    example_print_log("complete ok:", ok)
    example_print_log("Reply:", reply)
end
```

---

### `lurek.agent.completeAsync`

Queues a prompt on the module-level bounded worker pool; calls `callback(text, err)` on completion.

```lua
lurek.agent.completeAsync(prompt, callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `prompt` | string | Prompt text. |
| `callback` | function | Called with `(text, err)` on completion (`err` is `nil` on success). |

**Returns**

| Type | Description |
|------|-------------|
| number | Callback ID used to cancel or track the request. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ok, err = pcall(function()
        local id = lurek.agent.completeAsync("What is Lua?", function(text, async_err)
            if async_err then
                example_print_log("Error:", async_err)
            else
                example_print_log("Async reply:", text)
            end
        end)
        example_print_log("completeAsync id:", id)
        lurek.agent.update()
    end)
    example_print_log("completeAsync ok:", ok)
    if not ok then example_print_log("completeAsync error:", err) end
end
```

---

### `lurek.agent.completeJson`

Sends a prompt requesting a JSON-format response and returns a parsed Lua table.

```lua
lurek.agent.completeJson(prompt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `prompt` | string | Prompt text. |

**Returns**

| Type | Description |
|------|-------------|
| table | Parsed JSON response as a Lua table, or raises an error on failure. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ok, result = pcall(function()
        return lurek.agent.completeJson("List three colors as JSON.")
    end)
    example_print_log("completeJson ok:", ok)
    example_print_log("JSON result:", result)
end
```

---

### `lurek.agent.configure`

Configures the global LLM provider settings used by module-level functions.

```lua
lurek.agent.configure(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config` | table | Config with `provider`, `base_url`, `model`, `timeout_ms`, `api_key`, and optional `allow_external_hosts`. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.agent.configure({
        provider = "ollama",
        base_url = "http://127.0.0.1:9",
        model = "offline-test-model",
        timeout_ms = 1000,
        api_key = nil,
    })
end
```

---

### `lurek.agent.embed`

Returns an embedding vector for `text` from the global LLM.

```lua
lurek.agent.embed(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | Text to embed. |

**Returns**

| Type | Description |
|------|-------------|
| table | Number array of float embedding values, or raises an error on failure. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ok, vec = pcall(function()
        return lurek.agent.embed("Semantic embedding test.")
    end)
    example_print_log("embed ok:", ok)
    example_print_log("Embedding dimensions:", ok and #vec or 0)
end
```

---

### `lurek.agent.getDiagnostics`

Returns module-level async transport diagnostics for `completeAsync`.

```lua
lurek.agent.getDiagnostics()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Diagnostics with queue, latency, and failure counters. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local diagnostics = lurek.agent.getDiagnostics()
    lurek.log.info("module in_flight=" .. tostring(diagnostics.in_flight))
    lurek.log.info("module queued=" .. tostring(diagnostics.queued))
    lurek.log.info("module timeout_failures=" .. tostring(diagnostics.timeout_failures))
    lurek.log.info("module backend_failures=" .. tostring(diagnostics.backend_failures))
end
```

---

### `lurek.agent.isAvailable`

Returns `true` if the configured LLM server responds within 5 seconds.

```lua
lurek.agent.isAvailable()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the server is reachable. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local available = lurek.agent.isAvailable()
    local pending = lurek.agent.pendingCount()
    lurek.agent.update()
    lurek.log.info("llm available=" .. tostring(available))
    lurek.log.info("pending async completions=" .. tostring(pending))
    lurek.log.info("availability probe finished")
end
```

---

### `lurek.agent.listModels`

Returns a list of available model names from the configured LLM server.

```lua
lurek.agent.listModels()
```

**Returns**

| Type | Description |
|------|-------------|
| table | String array of model names; empty if the server is unreachable. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local models = lurek.agent.listModels()
    local first_model = models[1] or "none"
    local model_count = #models
    lurek.log.info("available model count=" .. tostring(model_count))
    lurek.log.info("first model=" .. tostring(first_model))
end
```

---

### `lurek.agent.new`

Creates a new configurable LLM Agent runtime instance.

```lua
lurek.agent.new(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config` | table | Config with `url`, `model`, `system_prompt`, `format`, `name`, `description`, `max_retries`, `timeout`, and `options` sub-table. |

**Returns**

| Type | Description |
|------|-------------|
| [LAgent](#lagent) | A new agent object. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local agent = lurek.agent.new({
        url          = "http://127.0.0.1:9/api/generate",
        model        = "offline-test-model",
        timeout      = 1,
        max_retries  = 0,
        system_prompt = "You are a helpful game AI.",
        format       = "json",
        name         = "helper",
        description  = "Provides general assistance to the player.",
        options      = {
            num_ctx     = 4096,
            temperature = 0.7,
            seed        = 42,
        },
    })
    example_print_log("Agent created:", agent)
end
```

---

### `lurek.agent.newAgentMemory`

Creates a bundled working+episodic+semantic memory with optional disk persistence.

```lua
lurek.agent.newAgentMemory(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | table | Config with `working_capacity` (integer) and `persist_path` (string?) fields. |

**Returns**

| Type | Description |
|------|-------------|
| [LAgentMemory](#lagentmemory) | A new agent memory object. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mem = lurek.agent.newAgentMemory({ working_capacity = 32, persist_path = nil })
    local working = mem:working()
    local episodic = mem:episodic()
    local semantic = mem:semantic()
    lurek.log.info("working capacity=" .. tostring(working:capacity()))
    lurek.log.info("episodic entries=" .. tostring(episodic:len()))
    lurek.log.info("semantic facts=" .. tostring(semantic:len()))
end
```

---

### `lurek.agent.newChat`

Creates a new stateful chat session using the global LLM config.

```lua
lurek.agent.newChat()
```

**Returns**

| Type | Description |
|------|-------------|
| [LAgentChat](#lagentchat) | A new chat session object. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local chat = lurek.agent.newChat()
    chat:setSystemPrompt("You are a quest hint assistant.")
    chat:addMessage("user", "Summarise the current quest in one sentence.")
    local history = chat:getHistory()
    lurek.log.info("chat history count=" .. tostring(#history))
    lurek.log.info("chat first role=" .. tostring(history[1] and history[1].role or "nil"))
    lurek.log.info("chat first content=" .. tostring(history[1] and history[1].content or "nil"))
end
```

---

### `lurek.agent.newEpisodicMemory`

Creates a new episodic memory for recording time-stamped events.

```lua
lurek.agent.newEpisodicMemory()
```

**Returns**

| Type | Description |
|------|-------------|
| [LEpisodicMemory](#lepisodicmemory) | A new episodic memory object. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local em = lurek.agent.newEpisodicMemory()
    em:record(1, { event = "spawn", zone = "village" })
    local results = em:query({ event = "spawn" })
    local size = em:len()
    lurek.log.info("episodic memory entries=" .. tostring(size))
    lurek.log.info("spawn matches=" .. tostring(#results))
    lurek.log.info("episodic memory ready for event playback")
end
```

---

### `lurek.agent.newManager`

Creates a new Agent Manager for batching multiple LLM agents over a shared client.

```lua
lurek.agent.newManager()
```

**Returns**

| Type | Description |
|------|-------------|
| [LAgentManager](#lagentmanager) | A new agent manager object. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local manager = lurek.agent.newManager()
    local writer = lurek.agent.new({ name = "writer" })
    local designer = lurek.agent.new({ name = "designer" })
    manager:update()
    lurek.log.info("shared manager ready for agents=" .. tostring(writer:getName()) .. "," .. tostring(designer:getName()))
    lurek.log.info("manager poll ran before any batch dispatch")
end
```

---

### `lurek.agent.newOllama`

Creates an Ollama infrastructure manager for server lifecycle and model management.

```lua
lurek.agent.newOllama(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config?` | table | Optional config with `url`, `binary_path`, `trusted_path`, `allowed_prefixes`, `protected_models`, `max_concurrent_pulls`, and `max_queued_pulls`. |

**Returns**

| Type | Description |
|------|-------------|
| [LOllamaManager](#lollamamanager) | A new Ollama manager object. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ollama = lurek.agent.newOllama({
        url = "http://127.0.0.1:9",
        healthcheck_timeout_ms = 100,
        healthcheck_poll_ms = 25,
    })
    local base_url = ollama:baseUrl()
    local pending = ollama:pendingCount()
    lurek.log.info("ollama base url=" .. tostring(base_url))
    lurek.log.info("pull jobs pending=" .. tostring(pending))
end
```

---

### `lurek.agent.newSemanticMemory`

Creates a new semantic memory for storing named facts.

```lua
lurek.agent.newSemanticMemory()
```

**Returns**

| Type | Description |
|------|-------------|
| [LSemanticMemory](#lsemanticmemory) | A new semantic memory object. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sm = lurek.agent.newSemanticMemory()
    sm:learn("capital_of_france", { value = "Paris" })
    local fact = sm:recall("capital_of_france")
    local count = sm:len()
    lurek.log.info("semantic memory facts=" .. tostring(count))
    lurek.log.info("capital_of_france=" .. tostring(fact and fact.value or "nil"))
    lurek.log.info("semantic memory ready for durable lore facts")
end
```

---

### `lurek.agent.newSystem`

Creates a new AISystem orchestrator that holds agents, instructions, and keyword-gated skills.

```lua
lurek.agent.newSystem(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config` | table | Config with `system_prompt` for the shared system context. |

**Returns**

| Type | Description |
|------|-------------|
| [LAISystem](#laisystem) | A new AI system object. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local system = lurek.agent.newSystem({
        system_prompt = "You are a multi-agent game orchestrator. Respond concisely.",
    })
    system:addInstruction("tone", "Keep every response short and actionable.")
    system:addSkill("sprite_rules", { "sprite", "tile", "palette" }, "Sprites use at most 16 colours.")
    local instructionCount = system:instructionCount()
    local skillCount = system:skillCount()
    lurek.log.info("ai system instructions=" .. tostring(instructionCount))
    lurek.log.info("ai system skills=" .. tostring(skillCount))
end
```

---

### `lurek.agent.newTemplate`

Creates a new `{key}` placeholder prompt template.

```lua
lurek.agent.newTemplate(pattern)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pattern` | string | Template string with `{key}` placeholders. |

**Returns**

| Type | Description |
|------|-------------|
| [LAgentTemplate](#lagenttemplate) | A new template object. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tmpl = lurek.agent.newTemplate("Hello, {name}!")
    local rendered = tmpl:render({ name = "Rhea" })
    local rendered_again = tmpl:render({ name = "Milo" })
    lurek.log.info("template rendered once=" .. tostring(rendered))
    lurek.log.info("template rendered twice=" .. tostring(rendered_again))
    lurek.log.info("template swaps placeholders for NPC names")
end
```

---

### `lurek.agent.newWorkingMemory`

Creates a new bounded FIFO working memory with the given capacity.

```lua
lurek.agent.newWorkingMemory(capacity)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `capacity` | number | Maximum number of key-value slots (0 = unlimited). |

**Returns**

| Type | Description |
|------|-------------|
| [LWorkingMemory](#lworkingmemory) | A new working memory object. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local wm = lurek.agent.newWorkingMemory(16)
    wm:push("quest", "Find the moon shard")
    local capacity = wm:capacity()
    local size = wm:len()
    lurek.log.info("working memory capacity=" .. tostring(capacity))
    lurek.log.info("working memory size=" .. tostring(size))
    lurek.log.info("quest memory=" .. tostring(wm:get("quest")))
end
```

---

### `lurek.agent.pendingCount`

Returns the number of module-level asynchronous completions still in flight.

```lua
lurek.agent.pendingCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Number of pending requests. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pending = lurek.agent.pendingCount()
    lurek.agent.update()
    local pending_after_update = lurek.agent.pendingCount()
    lurek.log.info("module pending count=" .. tostring(pending))
    lurek.log.info("pending after poll=" .. tostring(pending_after_update))
    lurek.log.info("queue idle=" .. tostring(pending_after_update == 0))
end
```

---

### `lurek.agent.update`

Polls module-level asynchronous completions and dispatches callbacks.

```lua
lurek.agent.update()
```

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pending_before = lurek.agent.pendingCount()
    lurek.agent.update()
    local pending_after = lurek.agent.pendingCount()
    lurek.log.info("module update polled background agent work")
    lurek.log.info("pending before=" .. tostring(pending_before))
    lurek.log.info("pending after=" .. tostring(pending_after))
end
```

---

## Module Fields

*No module-level fields documented.*

## Callback Parameters

- `lurek.agent.completeAsync` param `callback` (`function`): Called with `(text, err)` on completion (`err` is `nil` on success).

## Enums

*No module-specific enums documented.*

## Types

- [LAISystem](#laisystem)
- [LAgent](#lagent)
- [LAgentChat](#lagentchat)
- [LAgentManager](#lagentmanager)
- [LAgentMemory](#lagentmemory)
- [LAgentTemplate](#lagenttemplate)
- [LEpisodicMemory](#lepisodicmemory)
- [LOllamaManager](#lollamamanager)
- [LSemanticMemory](#lsemanticmemory)
- [LWorkingMemory](#lworkingmemory)

## LAISystem

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LAISystem:addAgent`

Registers a named agent in the system.

```lua
LAISystem:addAgent(name, agent)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Unique agent name used for routing. |
| `agent` | [LAgent](#lagent) | The agent instance to register. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local system = lurek.agent.newSystem({ system_prompt = "You are a game design AI." })

    local npc = lurek.agent.new({ url = "http://127.0.0.1:9/api/generate", model = "offline-test-model", timeout = 1, max_retries = 0, format = "json" })
    npc:setDescription("Writes NPC dialogue with emotional depth and regional accents.")

    system:addAgent("npc_writer", npc)
    example_print_log("Agent 'npc_writer' added to system.")
end
```

---

#### `LAISystem:addInstruction`

Adds a named instruction block the user can explicitly include per prompt.

```lua
LAISystem:addInstruction(key, text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Unique instruction identifier. |
| `text` | string | Instruction text injected into the system block. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local system = lurek.agent.newSystem({})
    system:addInstruction("art_style", "Use a 16-bit pixel art visual style. Palettes are limited to 16 colours per sprite.")
    system:addInstruction("tone",      "Keep all responses concise and in present tense.")
    local count = system:instructionCount()
    local hasTone = system:hasInstruction("tone")
    lurek.log.info("system instruction count=" .. tostring(count))
    lurek.log.info("tone instruction present=" .. tostring(hasTone))
end
```

---

#### `LAISystem:addSkill`

Adds a keyword-gated system skill that Lurek auto-injects when the prompt overlaps with its keywords.

```lua
LAISystem:addSkill(name, keywords, prompt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Skill identifier shown in the injected context. |
| `keywords` | table | String array of trigger keywords (case-insensitive match). |
| `prompt` | string | Instruction text appended when a keyword matches. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local system = lurek.agent.newSystem({})
    -- Lurek auto-injects this skill when the user prompt contains any listed keyword.
    system:addSkill(
        "pixel_art_rules",
        { "pixel art", "sprite", "texture", "tileset", "palette" },
        "Pixel art must use orthographic projection and a maximum of 16 colours per tile."
    )
    system:addSkill(
        "combat_rules",
        { "combat", "attack", "damage", "enemy", "boss" },
        "Combat uses turn-based resolution with action points (AP) per entity."
    )
    example_print_log("System skills added.")
end
```

---

#### `LAISystem:agentCount`

Returns the number of registered agents.

```lua
LAISystem:agentCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Agent count. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local system = lurek.agent.newSystem({})
    local agent  = lurek.agent.new({})
    system:addAgent("a1", agent)
    system:addAgent("a2", agent)
    example_print_log("Agent count:", system:agentCount())
end
```

---

#### `LAISystem:buildContext`

Builds and returns the full context string that would be sent for a given prompt.

```lua
LAISystem:buildContext(instruction, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `instruction` | string | The prompt text used for keyword matching. |
| `opts?` | table | Optional table with `agent` (string) and `instructions` (table) keys. |

**Returns**

| Type | Description |
|------|-------------|
| string | The assembled system context block. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local system = lurek.agent.newSystem({ system_prompt = "You are a game AI." })
    system:addInstruction("art_style", "Use pixel art, 16 colours max.")
    system:addSkill("combat_rules", { "combat", "attack" }, "Turn-based combat with AP.")

    local npc = lurek.agent.new({})
    npc:setDescription("NPC dialogue specialist.")
    system:addAgent("npc_writer", npc)

    -- Preview the full context that would be sent for this instruction.
    local ctx = system:buildContext(
        "Design an attack animation for the boss.",
        { agent = "npc_writer", instructions = { "art_style" } }
    )
    example_print_log("Context preview:\n", ctx)
end
```

---

#### `LAISystem:buildContextReport`

Builds context and returns both the rendered text and provenance list.

```lua
LAISystem:buildContextReport(instruction, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `instruction` | string | User instruction used to build the context report. |
| `opts?` | table | Optional table containing instruction filters and agent selection. |

**Returns**

| Type | Description |
|------|-------------|
| table | `{ text = string, provenance = { ... } }`. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local system = lurek.agent.newSystem({ system_prompt = "base context" })
    system:addInstruction("safety", "be safe")
    system:addSkill("math", { "matrix" }, "help with math")
    local report = system:buildContextReport("solve matrix problem", {
        instructions = { "safety" },
    })
    lurek.log.info("context report text length=" .. tostring(#report.text))
    lurek.log.info("context provenance count=" .. tostring(#report.provenance))
    lurek.log.info("first provenance kind=" .. tostring(report.provenance[1] and report.provenance[1].kind))
end
```

---

#### `LAISystem:getDiagnostics`

Returns transport diagnostics for the AI system runtime.

```lua
LAISystem:getDiagnostics()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Diagnostics with queue, latency, and failure counters. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local system = lurek.agent.newSystem({})
    local diagnostics = system:getDiagnostics()
    lurek.log.info("system in_flight=" .. tostring(diagnostics.in_flight))
    lurek.log.info("system queued=" .. tostring(diagnostics.queued))
    lurek.log.info("system network_failures=" .. tostring(diagnostics.network_failures))
end
```

---

#### `LAISystem:hasAgent`

Returns `true` if an agent with `name` is registered.

```lua
LAISystem:hasAgent(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Agent name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the agent exists. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local system = lurek.agent.newSystem({})
    local agent  = lurek.agent.new({})
    system:addAgent("planner", agent)
    example_print_log("Has 'planner':", system:hasAgent("planner"))
    example_print_log("Has 'ghost':",   system:hasAgent("ghost"))
end
```

---

#### `LAISystem:hasInstruction`

Returns `true` if an instruction with `key` is registered.

```lua
LAISystem:hasInstruction(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Instruction key to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the instruction exists. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local system = lurek.agent.newSystem({})
    system:addInstruction("tone", "Be concise.")
    system:addInstruction("art_style", "Use pixel art silhouettes.")
    local hasTone = system:hasInstruction("tone")
    local hasMissing = system:hasInstruction("missing")
    lurek.log.info("tone instruction present=" .. tostring(hasTone))
    lurek.log.info("missing instruction present=" .. tostring(hasMissing))
end
```

---

#### `LAISystem:hasSkill`

Returns `true` if a system skill with `name` is registered.

```lua
LAISystem:hasSkill(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Skill name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the skill exists. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local system = lurek.agent.newSystem({})
    system:addSkill("combat_rules", { "combat", "attack" }, "Turn-based combat.")
    system:addSkill("stealth_rules", { "stealth", "noise" }, "Noise raises patrol suspicion.")
    local hasCombatRules = system:hasSkill("combat_rules")
    local hasMissing = system:hasSkill("no_such_skill")
    lurek.log.info("combat rules present=" .. tostring(hasCombatRules))
    lurek.log.info("missing rules present=" .. tostring(hasMissing))
end
```

---

#### `LAISystem:instructionCount`

Returns the number of registered instruction blocks.

```lua
LAISystem:instructionCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Instruction count. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local system = lurek.agent.newSystem({})
    system:addInstruction("tone",      "Be concise.")
    system:addInstruction("art_style", "Use pixel art.")
    local count = system:instructionCount()
    local hasArtStyle = system:hasInstruction("art_style")
    lurek.log.info("instruction count=" .. tostring(count))
    lurek.log.info("art_style instruction present=" .. tostring(hasArtStyle))
end
```

---

#### `LAISystem:listAgents`

Returns a sorted list of all registered agent names.

```lua
LAISystem:listAgents()
```

**Returns**

| Type | Description |
|------|-------------|
| table | String array of agent names. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local system = lurek.agent.newSystem({})
    local a = lurek.agent.new({})
    system:addAgent("writer",   a)
    system:addAgent("designer", a)
    local names = system:listAgents()
    for _, name in ipairs(names) do
        example_print_log("Registered agent:", name)
    end
end
```

---

#### `LAISystem:listInstructions`

Returns a list of registered instruction keys in insertion order.

```lua
LAISystem:listInstructions()
```

**Returns**

| Type | Description |
|------|-------------|
| table | String array of instruction keys. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local system = lurek.agent.newSystem({})
    system:addInstruction("tone",      "Be concise.")
    system:addInstruction("art_style", "Use pixel art.")
    local keys = system:listInstructions()
    for _, key in ipairs(keys) do
        example_print_log("Instruction key:", key)
    end
end
```

---

#### `LAISystem:prompt`

Sends a prompt to a named agent through the system, auto-injecting matching context.

```lua
LAISystem:prompt(agent_name, instruction, callback, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `agent_name` | string | Name of the agent to query. |
| `instruction` | string | The task instruction for the agent. |
| `callback` | function | Function called with `(success, data, err_info)` when complete. |
| `opts` | table | Optional: `{ instructions = {"key1", ...} }` to include manually. |

**Returns**

| Type | Description |
|------|-------------|
| number | Callback ID. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local system = lurek.agent.newSystem({ system_prompt = "You are a game design AI." })
    system:addInstruction("art_style", "Use 16-bit pixel art.")
    system:addSkill("pixel_art_rules", { "sprite", "texture" }, "Max 16 colours per tile.")

    local designer = lurek.agent.new({
        url    = "http://127.0.0.1:9/api/generate",
        model  = "offline-test-model",
        timeout = 1,
        max_retries = 0,
        format = "json",
    })
    designer:setDescription("Visual design specialist focusing on sprites and environments.")
    system:addAgent("designer", designer)

    -- Keyword "sprite" triggers auto-injection of "pixel_art_rules".
    -- "art_style" is explicitly included via opts.instructions.
    local id = system:prompt(
        "designer",
        "Design a player sprite for the main character.",
        function(success, data, err_info)
            if success then
                example_print_log("Design:", data.description)
            else
                example_print_log("Error:", err_info.message)
            end
        end,
        { instructions = { "art_style" } }
    )
    example_print_log("System prompt dispatched, id =", id)
end
```

---

#### `LAISystem:removeAgent`

Removes a registered agent by name.

```lua
LAISystem:removeAgent(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Agent name to remove. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the agent was found and removed. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local system = lurek.agent.newSystem({})
    local agent  = lurek.agent.new({})
    system:addAgent("temp_agent", agent)
    local removed = system:removeAgent("temp_agent")
    example_print_log("Agent removed:", removed)
end
```

---

#### `LAISystem:removeInstruction`

Removes an instruction block by key.

```lua
LAISystem:removeInstruction(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Instruction key to remove. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the instruction was found and removed. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local system = lurek.agent.newSystem({})
    system:addInstruction("debug_hint", "Temporary debug context.")
    local removed = system:removeInstruction("debug_hint")
    local stillPresent = system:hasInstruction("debug_hint")
    local count = system:instructionCount()
    lurek.log.info("instruction removed=" .. tostring(removed))
    lurek.log.info("debug hint still present=" .. tostring(stillPresent) .. " count=" .. tostring(count))
end
```

---

#### `LAISystem:removeSkill`

Removes a registered system skill by exact name.

```lua
LAISystem:removeSkill(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Skill name to remove. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the skill was found and removed. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local system = lurek.agent.newSystem({})
    system:addSkill("temp_skill", { "test" }, "Temporary.")
    local removed = system:removeSkill("temp_skill")
    local stillPresent = system:hasSkill("temp_skill")
    local count = system:skillCount()
    lurek.log.info("system skill removed=" .. tostring(removed))
    lurek.log.info("temp skill still present=" .. tostring(stillPresent) .. " count=" .. tostring(count))
end
```

---

#### `LAISystem:runAll`

Dispatches multiple named-agent tasks in parallel through the system.

```lua
LAISystem:runAll(tasks, callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tasks` | table | List of `{ agent = string, instruction = string, instructions = table? }`. |
| `callback` | function | Function called with a results table when all tasks complete. |

**Returns**

| Type | Description |
|------|-------------|
| number | Batch callback ID. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local system = lurek.agent.newSystem({ system_prompt = "You are a game AI team." })
    system:addInstruction("art_style", "16-bit pixel art.")

    local writer   = lurek.agent.new({ url = "http://127.0.0.1:9/api/generate", model = "offline-test-model", timeout = 1, max_retries = 0, format = "json" })
    local designer = lurek.agent.new({ url = "http://127.0.0.1:9/api/generate", model = "offline-test-model", timeout = 1, max_retries = 0, format = "json" })
    writer:setDescription("Writes story and NPC dialogue.")
    designer:setDescription("Designs levels and visual assets.")

    system:addAgent("writer",   writer)
    system:addAgent("designer", designer)

    -- Each task specifies which agent to route to and which instructions to include.
    local id = system:runAll({
        { agent = "writer",   instruction = "Write boss intro text.", instructions = {} },
        { agent = "designer", instruction = "Design the boss arena.", instructions = { "art_style" } },
    }, function(results)
        for i, res in ipairs(results) do
            example_print_log("Task " .. i, res.success and tostring(res.data) or res.error.message)
        end
    end)
    example_print_log("System runAll dispatched, id =", id)
end
```

---

#### `LAISystem:skillCount`

Returns the number of registered system skills.

```lua
LAISystem:skillCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Skill count. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local system = lurek.agent.newSystem({})
    system:addSkill("combat_rules",   { "combat" },        "Turn-based combat.")
    system:addSkill("pixel_art_rules", { "sprite", "tile" }, "16 colours max.")
    local count = system:skillCount()
    local hasPixelArt = system:hasSkill("pixel_art_rules")
    lurek.log.info("system skill count=" .. tostring(count))
    lurek.log.info("pixel art rules present=" .. tostring(hasPixelArt))
end
```

---

#### `LAISystem:update`

Polls the system's background client for completed requests and dispatches callbacks.

```lua
LAISystem:update()
```

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local system = lurek.agent.newSystem({})
    system:addInstruction("combat", "Prioritise concise combat advice.")
    system:addSkill("boss_phase", { "boss", "phase" }, "Mention boss phase changes explicitly.")
    local instruction_count = system:instructionCount()
    local skill_count = system:skillCount()
    system:update()
    lurek.log.info("system update polled background requests")
    lurek.log.info("system instructions=" .. tostring(instruction_count))
    lurek.log.info("system skills=" .. tostring(skill_count))
end
```

---

## LAgent

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LAgent:addSkill`

Appends a named skill prompt to the agent's context block.

```lua
LAgent:addSkill(name, prompt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Unique skill identifier shown in the injected context. |
| `prompt` | string | Instruction text appended to the system block. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local agent = lurek.agent.new({})
    agent:addSkill("location", "The player is currently in the Darkwood forest.")
    agent:addSkill("time",     "It is midnight in the game world.")
    local count = agent:skillCount()
    local hasTime = agent:hasSkill("time")
    lurek.log.info("context skills added=" .. tostring(count))
    lurek.log.info("time skill present=" .. tostring(hasTime))
end
```

---

#### `LAgent:cancel`

Cancels an in-flight or pending request by callback ID.

```lua
LAgent:cancel(callback_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback_id` | number | ID returned by `prompt` or `promptBatch`. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local agent = lurek.agent.new({
        url = "http://127.0.0.1:9/api/generate",
        model = "offline-test-model",
        timeout = 1,
        max_retries = 0,
    })
    local pending_before = agent:pendingCount()
    local id = agent:prompt("Long-running request.", function() end)
    agent:cancel(id)
    local pending_after = agent:pendingCount()
    example_print_log("Pending before cancel:", pending_before)
    example_print_log("Request cancelled, id =", id)
    example_print_log("Pending after cancel:", pending_after)
end
```

---

#### `LAgent:clearSkills`

Removes all registered skills from the agent's context.

```lua
LAgent:clearSkills()
```

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local agent = lurek.agent.new({})
    agent:addSkill("temp", "Some context.")
    local before = agent:skillCount()
    agent:clearSkills()
    local after = agent:skillCount()
    local stillHasTemp = agent:hasSkill("temp")
    lurek.log.info("skills before clear=" .. tostring(before))
    lurek.log.info("skills after clear=" .. tostring(after) .. " temp present=" .. tostring(stillHasTemp))
end
```

---

#### `LAgent:evalCode`

Evaluates a Lua code string inside the active VM.

```lua
LAgent:evalCode(code)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `code` | string | The Lua code to execute. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` on success, raises an error on failure. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local agent = lurek.agent.new({})
    local ok = agent:evalCode("local hp = 12 + 8; _G.agent_eval_hp = hp")
    local queueDepth = agent:pendingCount()
    local format = agent:getFormat()
    lurek.log.info("evalCode success=" .. tostring(ok))
    lurek.log.info("queue depth=" .. tostring(queueDepth) .. " format=" .. tostring(format))
end
```

---

#### `LAgent:getDescription`

Returns the agent's role description.

```lua
LAgent:getDescription()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Role description, or `""` if not set. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local agent = lurek.agent.new({})
    agent:setDescription("Plans tasks.")
    local desc = agent:getDescription()
    agent:setName("task_router")
    local name = agent:getName()
    lurek.log.info("task router name=" .. tostring(name))
    lurek.log.info("task router description=" .. tostring(desc))
end
```

---

#### `LAgent:getDiagnostics`

Returns transport diagnostics for the agent runtime.

```lua
LAgent:getDiagnostics()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Diagnostics with queue, latency, and failure counters. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local agent = lurek.agent.new({})
    local diagnostics = agent:getDiagnostics()
    lurek.log.info("agent in_flight=" .. tostring(diagnostics.in_flight))
    lurek.log.info("agent queued=" .. tostring(diagnostics.queued))
    lurek.log.info("agent backend_failures=" .. tostring(diagnostics.backend_failures))
end
```

---

#### `LAgent:getFormat`

Returns the current response format string.

```lua
LAgent:getFormat()
```

**Returns**

| Type | Description |
|------|-------------|
| string | One of `"json"`, `"csv"`, or `"text"`. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local agent = lurek.agent.new({ format = "json" })
    agent:setName("schema_writer")
    local format = agent:getFormat()
    local name = agent:getName()
    lurek.log.info("schema writer=" .. tostring(name))
    lurek.log.info("schema writer format=" .. tostring(format))
end
```

---

#### `LAgent:getModel`

Returns the current model identifier.

```lua
LAgent:getModel()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Model name. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local agent = lurek.agent.new({ model = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M" })
    agent:setFormat("json")
    local model = agent:getModel()
    local format = agent:getFormat()
    lurek.log.info("quest model=" .. tostring(model))
    lurek.log.info("quest format=" .. tostring(format))
end
```

---

#### `LAgent:getName`

Returns the agent's name identifier.

```lua
LAgent:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Agent name, or `""` if not set. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local agent = lurek.agent.new({})
    agent:setName("planner")
    local name = agent:getName()
    agent:setDescription("Plans quest steps from player goals.")
    local description = agent:getDescription()
    lurek.log.info("planner agent name=" .. tostring(name))
    lurek.log.info("planner brief=" .. tostring(description))
end
```

---

#### `LAgent:getUrl`

Returns the current LLM endpoint URL.

```lua
LAgent:getUrl()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Endpoint URL. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local agent = lurek.agent.new({
        url = "http://127.0.0.1:9/api/generate",
        model = "offline-test-model",
        timeout = 1,
        max_retries = 0,
    })
    agent:setName("local_preview")
    local url = agent:getUrl()
    local name = agent:getName()
    lurek.log.info("preview agent name=" .. tostring(name))
    lurek.log.info("preview agent url=" .. tostring(url))
end
```

---

#### `LAgent:hasSkill`

Returns `true` if a skill with `name` is registered.

```lua
LAgent:hasSkill(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Skill name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the skill exists. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local agent = lurek.agent.new({})
    agent:addSkill("location", "The player is in the Darkwood forest.")
    agent:addSkill("weather", "Rain muffles footsteps and darkens the trail.")
    local hasLocation = agent:hasSkill("location")
    local hasWeather = agent:hasSkill("weather")
    lurek.log.info("location skill present=" .. tostring(hasLocation))
    lurek.log.info("weather skill present=" .. tostring(hasWeather))
end
```

---

#### `LAgent:listSkills`

Returns a list of registered skill names in insertion order.

```lua
LAgent:listSkills()
```

**Returns**

| Type | Description |
|------|-------------|
| table | String array of skill names. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local agent = lurek.agent.new({})
    agent:addSkill("combat",    "Turn-based combat.")
    agent:addSkill("inventory", "Inventory management.")
    local names = agent:listSkills()
    for _, name in ipairs(names) do
        example_print_log("Skill:", name)
    end
end
```

---

#### `LAgent:pendingCount`

Returns the number of in-flight requests that have not yet completed.

```lua
LAgent:pendingCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Number of pending requests. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local agent = lurek.agent.new({})
    agent:setName("quest_writer")
    local beforeUpdate = agent:pendingCount()
    agent:update()
    local afterUpdate = agent:pendingCount()
    lurek.log.info("pending prompts before poll=" .. tostring(beforeUpdate))
    lurek.log.info("pending prompts after poll=" .. tostring(afterUpdate))
end
```

---

#### `LAgent:prompt`

Sends an instructional prompt to the LLM asynchronously.

```lua
LAgent:prompt(instruction, callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `instruction` | string | The specific task instruction for the agent. |
| `callback` | function | Function called with `(success, data, err_info)` when complete. |

**Returns**

| Type | Description |
|------|-------------|
| number | Callback ID used to cancel the request. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local agent = lurek.agent.new({
        url    = "http://127.0.0.1:9/api/generate",
        model  = "offline-test-model",
        timeout = 1,
        max_retries = 0,
        format = "json",
    })

    -- Async — must call agent:update() in the game loop to receive callbacks.
    local id = agent:prompt("Describe what the player sees when entering the forest.", function(success, data, err_info)
        if success then
            example_print_log("Response:", data.description or data.response)
        else
            example_print_log("Error [" .. err_info.code .. "]:", err_info.message)
        end
    end)
    example_print_log("Prompt dispatched, id =", id)
end
```

---

#### `LAgent:promptBatch`

Sends a batch of prompts to the LLM asynchronously.

```lua
LAgent:promptBatch(instructions, callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `instructions` | table | Ordered list of instruction strings. |
| `callback` | function | Function called with a results table when all complete. |

**Returns**

| Type | Description |
|------|-------------|
| number | Batch callback ID. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local agent = lurek.agent.new({
        url    = "http://127.0.0.1:9/api/generate",
        model  = "offline-test-model",
        timeout = 1,
        max_retries = 0,
        format = "json",
    })

    local id = agent:promptBatch({
        "Describe the bridge.",
        "Describe the engine room.",
        "Describe the dungeon entrance.",
    }, function(results)
        for i, res in ipairs(results) do
            if res.success then
                example_print_log("Result " .. i .. ":", res.data.description)
            else
                example_print_log("Task " .. i .. " failed [" .. res.error.code .. "]:", res.error.message)
            end
        end
    end)
    example_print_log("Batch dispatched, id =", id)
end
```

---

#### `LAgent:setContextSize`

Sets the token context window size forwarded to the LLM backend.

```lua
LAgent:setContextSize(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | number | Context size in tokens (e.g. 4096). |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local agent = lurek.agent.new({})
    agent:setContextSize(8192)
    agent:setName("lore_keeper")
    agent:addSkill("history", "Keeps settlement, faction, and boss lore in context.")
    local name = agent:getName()
    local skillCount = agent:skillCount()
    lurek.log.info("context window expanded for=" .. tostring(name))
    lurek.log.info("lore keeper skill count=" .. tostring(skillCount))
end
```

---

#### `LAgent:setDescription`

Sets the agent's role description injected after the system prompt when routed through an AISystem.

```lua
LAgent:setDescription(description)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `description` | string | Role description text. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local agent = lurek.agent.new({})
    agent:setDescription("Specialises in writing NPC dialogue with emotional depth.")
    agent:setName("dialogue_director")
    local name = agent:getName()
    local description = agent:getDescription()
    lurek.log.info("dialogue agent=" .. tostring(name))
    lurek.log.info("dialogue brief=" .. tostring(description))
end
```

---

#### `LAgent:setFormat`

Changes the response format for future prompts.

```lua
LAgent:setFormat(format)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `format` | string | One of `"json"`, `"csv"`, or `"text"`. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local agent = lurek.agent.new({})
    agent:setFormat("text")
    agent:setName("narration_writer")
    local format = agent:getFormat()
    local name = agent:getName()
    lurek.log.info("narration writer=" .. tostring(name))
    lurek.log.info("narration format=" .. tostring(format))
end
```

---

#### `LAgent:setMaxRetries`

Sets the maximum retry count on transient network or timeout errors.

```lua
LAgent:setMaxRetries(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | number | Number of retries (0 disables retry). |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local agent = lurek.agent.new({})
    agent:setMaxRetries(3)
    agent:setName("resilient_writer")
    agent:setTimeout(45)
    local name = agent:getName()
    local url = agent:getUrl()
    lurek.log.info("retry policy updated for=" .. tostring(name))
    lurek.log.info("writer endpoint=" .. tostring(url))
end
```

---

#### `LAgent:setModel`

Changes the model identifier for future prompts.

```lua
LAgent:setModel(model)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `model` | string | Model name (e.g. `"llama3"`, `"mistral"`). |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local agent = lurek.agent.new({ model = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M" })
    agent:setModel("SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M")
    agent:setFormat("json")
    local model = agent:getModel()
    local format = agent:getFormat()
    lurek.log.info("agent model=" .. tostring(model))
    lurek.log.info("agent output format=" .. tostring(format))
end
```

---

#### `LAgent:setName`

Sets the agent's name identifier used when added to an AISystem.

```lua
LAgent:setName(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Agent name. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local agent = lurek.agent.new({})
    agent:setName("npc_writer")
    agent:setDescription("Writes short ambient barks for townsfolk.")
    local name = agent:getName()
    local description = agent:getDescription()
    lurek.log.info("agent name=" .. tostring(name))
    lurek.log.info("agent role=" .. tostring(description))
end
```

---

#### `LAgent:setOption`

Sets a single model option forwarded to the LLM backend.

```lua
LAgent:setOption(key, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Option name (e.g. `"temperature"`, `"seed"`, `"num_ctx"`). |
| `value` | any | Option value forwarded as JSON. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local agent = lurek.agent.new({})
    agent:setOption("temperature", 0.4)
    agent:setOption("seed", 1234)
    agent:setName("deterministic_writer")
    local name = agent:getName()
    local format = agent:getFormat()
    lurek.log.info("custom options set for=" .. tostring(name))
    lurek.log.info("current response format=" .. tostring(format))
end
```

---

#### `LAgent:setTemperature`

Sets the sampling temperature forwarded to the LLM backend.

```lua
LAgent:setTemperature(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Temperature value (e.g. 0.7). Higher = more random. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local agent = lurek.agent.new({})
    agent:setTemperature(0.9)
    agent:setName("bark_writer")
    agent:setFormat("text")
    local name = agent:getName()
    local format = agent:getFormat()
    lurek.log.info("creative temperature set for=" .. tostring(name))
    lurek.log.info("creative output format=" .. tostring(format))
end
```

---

#### `LAgent:setTimeout`

Sets the per-request timeout in seconds (0 uses the default 60 s).

```lua
LAgent:setTimeout(secs)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `secs` | number | Timeout in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local agent = lurek.agent.new({})
    agent:setTimeout(90)
    agent:setName("long_form_writer")
    agent:setDescription("Drafts long quest logs without timing out early.")
    local name = agent:getName()
    local description = agent:getDescription()
    lurek.log.info("timeout tuned for agent=" .. tostring(name))
    lurek.log.info("timeout use case=" .. tostring(description))
end
```

---

#### `LAgent:setUrl`

Changes the LLM endpoint URL for future prompts after safe-mode validation.

```lua
LAgent:setUrl(url)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | string | Full endpoint URL (typically local, e.g. `"http://127.0.0.1:11434/api/generate"`). |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local agent = lurek.agent.new({})
    agent:setUrl("http://127.0.0.1:9/api/generate")
    agent:setName("remote_writer")
    local url = agent:getUrl()
    local name = agent:getName()
    lurek.log.info("remote agent name=" .. tostring(name))
    lurek.log.info("remote agent url=" .. tostring(url))
end
```

---

#### `LAgent:skillCount`

Returns the number of registered skills.

```lua
LAgent:skillCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Skill count. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local agent = lurek.agent.new({})
    agent:addSkill("s1", "Context A.")
    agent:addSkill("s2", "Context B.")
    local count = agent:skillCount()
    local hasFirst = agent:hasSkill("s1")
    lurek.log.info("agent skill count=" .. tostring(count))
    lurek.log.info("first context skill present=" .. tostring(hasFirst))
end
```

---

#### `LAgent:update`

Polls the background client for completed LLM requests and dispatches callbacks.

```lua
LAgent:update()
```

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local agent = lurek.agent.new({})
    agent:setName("ambient_writer")
    local before = agent:pendingCount()
    agent:update()
    local after = agent:pendingCount()
    lurek.log.info("ambient writer pending before update=" .. tostring(before))
    lurek.log.info("ambient writer pending after update=" .. tostring(after))
end
```

---

## LAgentChat

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LAgentChat:addMessage`

Appends a message to the chat history without sending a completion.

```lua
LAgentChat:addMessage(role, content)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `role` | string | Role identifier: `"user"`, `"assistant"`, or `"system"`. |
| `content` | string | Message content. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local chat = lurek.agent.newChat()
    chat:addMessage("user", "Tell me a joke.")
    chat:addMessage("assistant", "Parries are no laughing matter.")
    local history = chat:getHistory()
    lurek.log.info("chat history count=" .. tostring(#history))
    lurek.log.info("first role=" .. tostring(history[1] and history[1].role or "nil"))
    lurek.log.info("last role=" .. tostring(history[#history] and history[#history].role or "nil"))
end
```

---

#### `LAgentChat:clear`

Clears all stored chat history messages.

```lua
LAgentChat:clear()
```

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local chat = lurek.agent.newChat()
    chat:addMessage("user", "Hello")
    chat:addMessage("assistant", "Hi there.")
    local before = #chat:getHistory()
    chat:clear()
    local after = #chat:getHistory()
    lurek.log.info("chat messages before clear=" .. tostring(before))
    lurek.log.info("chat messages after clear=" .. tostring(after))
    lurek.log.info("chat cleared=" .. tostring(after == 0))
end
```

---

#### `LAgentChat:complete`

Sends the current history to the LLM and returns the assistant reply.

```lua
LAgentChat:complete()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Assistant reply text, or raises an error on failure. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local chat = lurek.agent.newChat()
    chat:addMessage("user", "Hi!")
    local ok, reply = pcall(function()
        return chat:complete()
    end)
    example_print_log("chat complete ok:", ok)
    example_print_log("Chat reply:", reply)
end
```

---

#### `LAgentChat:getHistory`

Returns the chat history as an array of `{role, content}` tables.

```lua
LAgentChat:getHistory()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of `{ role = string, content = string }` tables. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local chat = lurek.agent.newChat()
    chat:addMessage("system", "You are a merchant helper.")
    chat:addMessage("user", "What does this potion do?")
    local history = chat:getHistory()
    local first_role = history[1] and history[1].role or "nil"
    local last_role = history[#history] and history[#history].role or "nil"
    lurek.log.info("history entries=" .. tostring(#history))
    lurek.log.info("first role=" .. tostring(first_role))
    lurek.log.info("last role=" .. tostring(last_role))
end
```

---

#### `LAgentChat:setSystemPrompt`

Sets the system prompt used for all completions in this session.

```lua
LAgentChat:setSystemPrompt(prompt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `prompt` | string | System prompt text. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local chat = lurek.agent.newChat()
    chat:setSystemPrompt("You are a helpful assistant.")
    chat:addMessage("user", "Explain the stamina system.")
    local history = chat:getHistory()
    local last_role = history[#history] and history[#history].role or "nil"
    lurek.log.info("chat system prompt configured")
    lurek.log.info("chat history count=" .. tostring(#history))
    lurek.log.info("chat last role=" .. tostring(last_role))
end
```

---

## LAgentManager

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LAgentManager:runAll`

Runs multiple agent tasks in parallel and calls a single callback when all finish.

```lua
LAgentManager:runAll(tasks, callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tasks` | table | List of `{ agent = [LAgent](#lagent), instruction = string }` tables. |
| `callback` | function | Function called with a results table when all tasks complete. |

**Returns**

| Type | Description |
|------|-------------|
| number | Batch callback ID. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local manager = lurek.agent.newManager()

    local writer   = lurek.agent.new({ url = "http://127.0.0.1:9/api/generate", model = "offline-test-model", timeout = 1, max_retries = 0, format = "json" })
    local designer = lurek.agent.new({ url = "http://127.0.0.1:9/api/generate", model = "offline-test-model", timeout = 1, max_retries = 0, format = "json" })

    local id = manager:runAll({
        { agent = writer,   instruction = "Write a boss intro monologue." },
        { agent = designer, instruction = "Design the boss arena layout."  },
    }, function(results)
        for i, res in ipairs(results) do
            example_print_log("Task " .. i, res.success and tostring(res.data) or res.error.message)
        end
    end)
    example_print_log("Manager batch dispatched, id =", id)
end
```

---

#### `LAgentManager:update`

Polls the manager's background client for completed tasks and dispatches callbacks.

```lua
LAgentManager:update()
```

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local manager = lurek.agent.newManager()
    local writer = lurek.agent.new({ name = "writer" })
    local critic = lurek.agent.new({ name = "critic" })
    manager:update()
    lurek.log.info("manager polled shared queue for=" .. tostring(writer:getName()))
    lurek.log.info("manager also tracks=" .. tostring(critic:getName()))
end
```

---

## LAgentMemory

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LAgentMemory:episodic`

Returns the episodic memory component.

```lua
LAgentMemory:episodic()
```

**Returns**

| Type | Description |
|------|-------------|
| [LEpisodicMemory](#lepisodicmemory) | Episodic memory handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mem = lurek.agent.newAgentMemory({ working_capacity = 8 })
    local em = mem:episodic()
    em:record(10, { event = "quest_started" })
    local matches = em:query({ event = "quest_started" })
    local size = em:len()
    lurek.log.info("episodic bundle entries=" .. tostring(size))
    lurek.log.info("quest_started matches=" .. tostring(#matches))
    lurek.log.info("episodic bundle ready=" .. tostring(size > 0))
end
```

---

#### `LAgentMemory:getDiagnostics`

Returns diagnostics for the bundled memory state and persistence policy.

```lua
LAgentMemory:getDiagnostics()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Counts, approximate bytes, and storage-policy information. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mem = lurek.agent.newAgentMemory({ working_capacity = 6 })
    local diagnostics = mem:getDiagnostics()
    lurek.log.info("memory working_entries=" .. tostring(diagnostics.working_entries))
    lurek.log.info("memory max_bytes=" .. tostring(diagnostics.max_bytes))
    lurek.log.info("memory sandbox_root=" .. tostring(diagnostics.sandbox_root))
end
```

---

#### `LAgentMemory:load`

Deserialises memory state from the configured persist_path.

```lua
LAgentMemory:load()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` on success, raises an error on failure. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local source = lurek.agent.newAgentMemory({ persist_path = "work/agent_mem_example.json" })
    source:working():push("checkpoint", "harbor_gate")
    source:semantic():learn("region", { name = "Salt Coast" })
    source:save()
    local mem = lurek.agent.newAgentMemory({ persist_path = "work/agent_mem_example.json" })
    local loaded = mem:load()
    local checkpoint = mem:working():get("checkpoint")
    lurek.log.info("memory loaded=" .. tostring(loaded))
    lurek.log.info("loaded checkpoint=" .. tostring(checkpoint))
    lurek.log.info("loaded semantic facts=" .. tostring(mem:semantic():len()))
end
```

---

#### `LAgentMemory:save`

Serialises all memory banks to the configured persist_path.

```lua
LAgentMemory:save()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` on success, raises an error on failure. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mem = lurek.agent.newAgentMemory({ persist_path = "work/agent_mem_example.json" })
    mem:working():push("checkpoint", "harbor_gate")
    mem:semantic():learn("region", { name = "Salt Coast" })
    local saved = mem:save()
    local working_size = mem:working():len()
    lurek.log.info("memory saved=" .. tostring(saved))
    lurek.log.info("working entries persisted=" .. tostring(working_size))
    lurek.log.info("semantic facts persisted=" .. tostring(mem:semantic():len()))
end
```

---

#### `LAgentMemory:semantic`

Returns the semantic memory component.

```lua
LAgentMemory:semantic()
```

**Returns**

| Type | Description |
|------|-------------|
| [LSemanticMemory](#lsemanticmemory) | Semantic memory handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mem = lurek.agent.newAgentMemory({ working_capacity = 8 })
    local sm = mem:semantic()
    sm:learn("faction", { name = "Wardens" })
    local fact = sm:recall("faction")
    local count = sm:len()
    lurek.log.info("semantic bundle facts=" .. tostring(count))
    lurek.log.info("faction name=" .. tostring(fact and fact.name or "nil"))
    lurek.log.info("semantic bundle ready for lore lookups")
end
```

---

#### `LAgentMemory:working`

Returns the working memory component.

```lua
LAgentMemory:working()
```

**Returns**

| Type | Description |
|------|-------------|
| [LWorkingMemory](#lworkingmemory) | Working memory handle. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mem = lurek.agent.newAgentMemory({ working_capacity = 8 })
    local wm = mem:working()
    wm:push("stance", "defensive")
    local stance = wm:get("stance")
    local size = wm:len()
    lurek.log.info("working stance=" .. tostring(stance))
    lurek.log.info("working entries=" .. tostring(size))
    lurek.log.info("working capacity=" .. tostring(wm:capacity()))
end
```

---

## LAgentTemplate

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LAgentTemplate:render`

Renders the template by substituting `{key}` placeholders from `values`.

```lua
LAgentTemplate:render(values)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `values` | table | Map of key Ă˘â€ â€™ string substitutions. |

**Returns**

| Type | Description |
|------|-------------|
| string | Rendered string, or raises an error if a key is missing. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local tmpl = lurek.agent.newTemplate("Hello, {name}! You are {age} years old.")
    local first = tmpl:render({ name = "Alice", age = "30" })
    local second = tmpl:render({ name = "Borin", age = "52" })
    local has_alice = first:find("Alice", 1, true) ~= nil
    lurek.log.info("first render=" .. tostring(first))
    lurek.log.info("second render=" .. tostring(second))
    lurek.log.info("alice placeholder resolved=" .. tostring(has_alice))
end
```

---

## LEpisodicMemory

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LEpisodicMemory:forgetBefore`

Removes all episodes with tick < `cutoff`.

```lua
LEpisodicMemory:forgetBefore(cutoff)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cutoff` | number | Tick threshold; episodes older than this are removed. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local em = lurek.agent.newEpisodicMemory()
    em:record(10, { note = "old" })
    em:record(200, { note = "new" })
    em:forgetBefore(100)
    example_print_log("Episodes after prune:", em:len())
end
```

---

#### `LEpisodicMemory:len`

Returns the number of stored episodes.

```lua
LEpisodicMemory:len()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Episode count. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local em = lurek.agent.newEpisodicMemory()
    em:record(1, { x = 1 })
    em:record(2, { x = 2 })
    local length = em:len()
    local recent = em:query({ x = 2 })
    lurek.log.info("episode count=" .. tostring(length))
    lurek.log.info("query for x=2=" .. tostring(#recent))
    lurek.log.info("episodic memory stores ordered snapshots")
end
```

---

#### `LEpisodicMemory:query`

Returns all episodes whose data matches every key-value pair in `filter`.

```lua
LEpisodicMemory:query(filter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `filter` | table | Key-value filter table (empty = return all). |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of `{ tick = integer, data = table }` episode tables. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local em = lurek.agent.newEpisodicMemory()
    em:record(1, { type = "kill" })
    em:record(2, { type = "kill" })
    em:record(3, { type = "loot" })
    local results = em:query({ type = "kill" })
    local total = em:len()
    local loot_results = em:query({ type = "loot" })
    lurek.log.info("kill events=" .. tostring(#results))
    lurek.log.info("loot events=" .. tostring(#loot_results))
    lurek.log.info("episodic total=" .. tostring(total))
end
```

---

#### `LEpisodicMemory:record`

Records a new episode at `tick` with `data`.

```lua
LEpisodicMemory:record(tick, data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tick` | number | Logical tick or frame counter for this episode. |
| `data` | table | Key-value payload stored with the episode. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local em = lurek.agent.newEpisodicMemory()
    em:record(100, { event = "player_hit", damage = 10 })
    em:record(140, { event = "player_heal", amount = 6 })
    local hit_events = em:query({ event = "player_hit" })
    local total = em:len()
    lurek.log.info("episodic entries=" .. tostring(total))
    lurek.log.info("player_hit matches=" .. tostring(#hit_events))
    lurek.log.info("latest combat memory recorded")
end
```

---

## LOllamaManager

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LOllamaManager:baseUrl`

Returns the base URL this manager was created with.

```lua
LOllamaManager:baseUrl()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Base URL (e.g. `"http://127.0.0.1:11434"`). |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ollama = lurek.agent.newOllama({
        url = "http://127.0.0.1:9",
        healthcheck_timeout_ms = 100,
        healthcheck_poll_ms = 25,
    })
    local url = ollama:baseUrl()
    local pending = ollama:pendingCount()
    lurek.log.info("ollama base url=" .. tostring(url))
    lurek.log.info("ollama pull queue=" .. tostring(pending))
end
```

---

#### `LOllamaManager:cancelPull`

Marks a queued or in-flight pull as cancelled so its result is ignored on completion.

```lua
LOllamaManager:cancelPull(callback_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback_id` | number | ID returned by `pullModel`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` when the callback ID was marked as cancelled. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ollama = lurek.agent.newOllama({
        url = "http://127.0.0.1:9",
        healthcheck_timeout_ms = 100,
        healthcheck_poll_ms = 25,
    })
    local id = ollama:pullModel("llama3", function(success, err_msg)
        example_print_log("cancelPull callback", tostring(success), tostring(err_msg))
    end)
    local ok = ollama:cancelPull(id)
    lurek.log.info("cancel pull id=" .. tostring(id))
    lurek.log.info("cancel pull accepted=" .. tostring(ok))
end
```

---

#### `LOllamaManager:deleteModel`

Sends `DELETE /api/delete` to remove a model from local Ollama storage.

```lua
LOllamaManager:deleteModel(name, confirm_token)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Model name to delete (e.g. `"llama3:latest"`). |
| `confirm_token?` | string | Required when deleting a model protected by policy. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the request succeeded. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ollama = lurek.agent.newOllama({
        url = "http://127.0.0.1:9",
        healthcheck_timeout_ms = 100,
        healthcheck_poll_ms = 25,
    })
    local target_model = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M"
    local ok, deleted = pcall(function()
        return ollama:deleteModel(target_model)
    end)
    local pending = ollama:pendingCount()
    lurek.log.info("delete request ok=" .. tostring(ok))
    lurek.log.info("delete request accepted=" .. tostring(deleted))
    lurek.log.info("pending pull jobs=" .. tostring(pending))
end
```

---

#### `LOllamaManager:getDiagnostics`

Returns operational diagnostics for the Ollama manager.

```lua
LOllamaManager:getDiagnostics()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Diagnostics with pull queue state and last error information. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ollama = lurek.agent.newOllama({
        url = "http://127.0.0.1:9",
        healthcheck_timeout_ms = 100,
        healthcheck_poll_ms = 25,
    })
    local diagnostics = ollama:getDiagnostics()
    lurek.log.info("ollama in_flight_pulls=" .. tostring(diagnostics.in_flight_pulls))
    lurek.log.info("ollama queued_pulls=" .. tostring(diagnostics.queued_pulls))
    lurek.log.info("ollama last_error=" .. tostring(diagnostics.last_error))
end
```

---

#### `LOllamaManager:hasModel`

Returns `true` if a model with the given name (or name prefix) is available locally.

```lua
LOllamaManager:hasModel(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Model name to check (e.g. `"llama3"` or `"llama3:latest"`). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if found locally. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ollama = lurek.agent.newOllama({
        url = "http://127.0.0.1:9",
        healthcheck_timeout_ms = 100,
        healthcheck_poll_ms = 25,
    })
    local target_model = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M"
    local found = ollama:hasModel(target_model)
    lurek.log.info("model available=" .. tostring(found))
    lurek.log.info("model probe target=" .. target_model)
end
```

---

#### `LOllamaManager:isRunning`

Returns `true` if the Ollama HTTP server responds within 5 seconds.

```lua
LOllamaManager:isRunning()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if Ollama is reachable. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ollama  = lurek.agent.newOllama({
        url = "http://127.0.0.1:9",
        healthcheck_timeout_ms = 100,
        healthcheck_poll_ms = 25,
    })
    local running = ollama:isRunning()
    local base_url = ollama:baseUrl()
    lurek.log.info("ollama running=" .. tostring(running))
    lurek.log.info("ollama base url=" .. tostring(base_url))
end
```

---

#### `LOllamaManager:listModels`

Returns a table of locally available models, each with `name` and `size_gb` fields.

```lua
LOllamaManager:listModels()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of `{ name = string, size_gb = number }` tables. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ollama = lurek.agent.newOllama({
        url = "http://127.0.0.1:9",
        healthcheck_timeout_ms = 100,
        healthcheck_poll_ms = 25,
    })
    local models = ollama:listModels()
    for _, m in ipairs(models) do
        example_print_log(m.name, string.format("%.1f GB", m.size_gb))
    end
end
```

---

#### `LOllamaManager:modelNames`

Returns a string array of locally available model names; empty if Ollama is not running.

```lua
LOllamaManager:modelNames()
```

**Returns**

| Type | Description |
|------|-------------|
| table | String array of model names. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ollama = lurek.agent.newOllama({
        url = "http://127.0.0.1:9",
        healthcheck_timeout_ms = 100,
        healthcheck_poll_ms = 25,
    })
    local names  = ollama:modelNames()
    for _, name in ipairs(names) do
        example_print_log("Available model:", name)
    end
end
```

---

#### `LOllamaManager:pendingCount`

Returns the number of in-flight model pull operations.

```lua
LOllamaManager:pendingCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Number of pending pulls. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ollama = lurek.agent.newOllama({
        url = "http://127.0.0.1:9",
        healthcheck_timeout_ms = 100,
        healthcheck_poll_ms = 25,
    })
    local pending = ollama:pendingCount()
    local base_url = ollama:baseUrl()
    local running = ollama:isRunning()
    lurek.log.info("in-flight pulls=" .. tostring(pending))
    lurek.log.info("ollama base url=" .. tostring(base_url))
    lurek.log.info("ollama running=" .. tostring(running))
end
```

---

#### `LOllamaManager:pullModel`

Dispatches an async model download; calls `callback(success, err_msg)` on completion.

```lua
LOllamaManager:pullModel(name, callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Model name to download (e.g. `"llama3"`). |
| `callback` | function | Called with `(success, err_msg)` on completion. |

**Returns**

| Type | Description |
|------|-------------|
| number | Callback ID used with `update()`. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ollama = lurek.agent.newOllama({
        url = "http://127.0.0.1:9",
        healthcheck_timeout_ms = 100,
        healthcheck_poll_ms = 25,
    })
    local id     = ollama:pullModel("SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M", function(success, err_msg)
        if success then
            example_print_log("Model downloaded successfully.")
        else
            example_print_log("Pull failed:", err_msg)
        end
    end)
    example_print_log("Pull started, callback id =", id)
end
```

---

#### `LOllamaManager:restart`

Stops then restarts the managed Ollama process. Returns `true` on success.

```lua
LOllamaManager:restart()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the restart succeeded. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ollama = lurek.agent.newOllama({
        url = "http://127.0.0.1:9",
        healthcheck_timeout_ms = 100,
        healthcheck_poll_ms = 25,
    })
    local ok, restarted = pcall(function()
        return ollama:restart()
    end)
    lurek.log.info("ollama restart ok=" .. tostring(ok))
    lurek.log.info("ollama restart result=" .. tostring(restarted))
end
```

---

#### `LOllamaManager:start`

Spawns `ollama serve` as a managed child process. Returns `true` on success.

```lua
LOllamaManager:start()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the process started. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ollama = lurek.agent.newOllama({
        url = "http://127.0.0.1:9",
        healthcheck_timeout_ms = 100,
        healthcheck_poll_ms = 25,
    })
    local ok, started = pcall(function()
        return ollama:start()
    end)
    lurek.log.info("ollama start ok=" .. tostring(ok))
    lurek.log.info("ollama start result=" .. tostring(started))
end
```

---

#### `LOllamaManager:stop`

Kills the Ollama process started by this manager. Returns `true` if it was running.

```lua
LOllamaManager:stop()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the process was running under this manager. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ollama = lurek.agent.newOllama({
        url = "http://127.0.0.1:9",
        healthcheck_timeout_ms = 100,
        healthcheck_poll_ms = 25,
    })
    local base_url = ollama:baseUrl()
    local stopped = ollama:stop()
    local pending = ollama:pendingCount()
    lurek.log.info("ollama stop requested=" .. tostring(stopped))
    lurek.log.info("ollama base url=" .. tostring(base_url))
    lurek.log.info("ollama pending pulls=" .. tostring(pending))
end
```

---

#### `LOllamaManager:update`

Polls completed pull operations and dispatches registered callbacks.

```lua
LOllamaManager:update()
```

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ollama = lurek.agent.newOllama({
        url = "http://127.0.0.1:9",
        healthcheck_timeout_ms = 100,
        healthcheck_poll_ms = 25,
    })
    local pending_before = ollama:pendingCount()
    ollama:update()
    local pending_after = ollama:pendingCount()
    lurek.log.info("ollama update flushed callbacks")
    lurek.log.info("pending before update=" .. tostring(pending_before))
    lurek.log.info("pending after update=" .. tostring(pending_after))
end
```

---

#### `LOllamaManager:version`

Returns the Ollama version string, or an empty string if not running.

```lua
LOllamaManager:version()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Ollama version or `""`. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ollama = lurek.agent.newOllama({
        url = "http://127.0.0.1:9",
        healthcheck_timeout_ms = 100,
        healthcheck_poll_ms = 25,
    })
    local version = ollama:version()
    local base_url = ollama:baseUrl()
    local pending = ollama:pendingCount()
    lurek.log.info("ollama version=" .. tostring(version))
    lurek.log.info("ollama base url=" .. tostring(base_url))
    lurek.log.info("ollama pending pulls=" .. tostring(pending))
end
```

---

## LSemanticMemory

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSemanticMemory:forget`

Removes the fact at `key`.  Returns `true` if it existed.

```lua
LSemanticMemory:forget(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Fact key. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the fact was removed. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sm = lurek.agent.newSemanticMemory()
    sm:learn("temp_fact", { value = 42 })
    sm:learn("keep_fact", { value = 7 })
    local removed = sm:forget("temp_fact")
    local remaining = sm:recall("keep_fact")
    local count = sm:len()
    lurek.log.info("temp fact removed=" .. tostring(removed))
    lurek.log.info("remaining fact=" .. tostring(remaining and remaining.value or "nil"))
    lurek.log.info("semantic fact count=" .. tostring(count))
end
```

---

#### `LSemanticMemory:learn`

Inserts or replaces a fact at `key`.

```lua
LSemanticMemory:learn(key, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Fact key. |
| `value` | any | Fact value. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sm = lurek.agent.newSemanticMemory()
    sm:learn("capital_of_france", { value = "Paris" })
    sm:learn("capital_of_poland", { value = "Warsaw" })
    local france = sm:recall("capital_of_france")
    local poland = sm:recall("capital_of_poland")
    local count = sm:len()
    lurek.log.info("france capital=" .. tostring(france and france.value or "nil"))
    lurek.log.info("poland capital=" .. tostring(poland and poland.value or "nil"))
    lurek.log.info("semantic fact count=" .. tostring(count))
end
```

---

#### `LSemanticMemory:len`

Returns the number of stored facts.

```lua
LSemanticMemory:len()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Fact count. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sm = lurek.agent.newSemanticMemory()
    sm:learn("k", { v = 1 })
    sm:learn("m", { v = 2 })
    local count = sm:len()
    local matches = sm:query({ v = 2 })
    lurek.log.info("semantic fact count=" .. tostring(count))
    lurek.log.info("facts matching v=2=" .. tostring(#matches))
    lurek.log.info("semantic memory can be queried by fields")
end
```

---

#### `LSemanticMemory:query`

Returns all facts whose value matches every key-value pair in `filter`.

```lua
LSemanticMemory:query(filter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `filter` | table | Key-value filter applied to each fact's value object (empty = return all). |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of `{ key = string, value = any }` tables. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sm = lurek.agent.newSemanticMemory()
    sm:learn("fact_a", { category = "geo" })
    sm:learn("fact_b", { category = "geo" })
    local geo_facts = sm:query({ category = "geo" })
    example_print_log("Geo facts:", #geo_facts)
end
```

---

#### `LSemanticMemory:recall`

Returns the fact for `key`, or `nil` if not found.

```lua
LSemanticMemory:recall(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Fact key. |

**Returns**

| Type | Description |
|------|-------------|
| table | Stored fact converted from JSON when present; returns nil when missing. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local sm = lurek.agent.newSemanticMemory()
    sm:learn("color", { hex = "#FF0000" })
    local fact = sm:recall("color")
    local missing = sm:recall("missing")
    local count = sm:len()
    lurek.log.info("recalled color hex=" .. tostring(fact and fact.hex or "nil"))
    lurek.log.info("missing fact=" .. tostring(missing))
    lurek.log.info("semantic fact count=" .. tostring(count))
end
```

---

## LWorkingMemory

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LWorkingMemory:capacity`

Returns the configured capacity (0 = unlimited).

```lua
LWorkingMemory:capacity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Capacity. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local wm = lurek.agent.newWorkingMemory(32)
    wm:push("objective", "Escort the caravan")
    local capacity = wm:capacity()
    local size = wm:len()
    lurek.log.info("working memory capacity=" .. tostring(capacity))
    lurek.log.info("working memory size=" .. tostring(size))
    lurek.log.info("objective=" .. tostring(wm:get("objective")))
end
```

---

#### `LWorkingMemory:forget`

Removes the entry with `key`.  Returns `true` if it existed.

```lua
LWorkingMemory:forget(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Entry key. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the entry was removed. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local wm = lurek.agent.newWorkingMemory(8)
    wm:push("temp", "value")
    wm:push("stable", "keep")
    local before = wm:len()
    local removed = wm:forget("temp")
    local after = wm:len()
    local stable = wm:get("stable")
    lurek.log.info("removed temp entry=" .. tostring(removed))
    lurek.log.info("size before forget=" .. tostring(before))
    lurek.log.info("size after forget=" .. tostring(after) .. " stable=" .. tostring(stable))
end
```

---

#### `LWorkingMemory:get`

Returns the value for `key`, or `nil` if not found.

```lua
LWorkingMemory:get(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Entry key. |

**Returns**

| Type | Description |
|------|-------------|
| table | Stored value converted from JSON when present; returns nil when missing. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local wm = lurek.agent.newWorkingMemory(8)
    wm:push("hp", 100)
    wm:push("mana", 35)
    local hp = wm:get("hp")
    local mana = wm:get("mana")
    local size = wm:len()
    lurek.log.info("hp=" .. tostring(hp))
    lurek.log.info("mana=" .. tostring(mana))
    lurek.log.info("working memory size=" .. tostring(size))
end
```

---

#### `LWorkingMemory:getRecent`

Returns the `n` most recently inserted entries as an array of `{key, value}` tables.

```lua
LWorkingMemory:getRecent(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | number | Maximum number of entries to return. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of `{ key = string, value = any }` tables. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local wm = lurek.agent.newWorkingMemory(8)
    wm:push("a", 1)
    wm:push("b", 2)
    local recent = wm:getRecent(2)
    example_print_log("Recent entries:", #recent)
end
```

---

#### `LWorkingMemory:len`

Returns the current number of entries.

```lua
LWorkingMemory:len()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Entry count. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local wm = lurek.agent.newWorkingMemory(8)
    wm:push("x", 42)
    wm:push("y", 84)
    local size = wm:len()
    local recent = wm:getRecent(2)
    lurek.log.info("working memory size=" .. tostring(size))
    lurek.log.info("recent entries=" .. tostring(#recent))
    lurek.log.info("latest key=" .. tostring(recent[1] and recent[1].key or "nil"))
end
```

---

#### `LWorkingMemory:push`

Inserts or updates a key-value entry; evicts the oldest entry if capacity is exceeded.

```lua
LWorkingMemory:push(key, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Entry key. |
| `value` | any | Entry value (any serialisable Lua value). |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local wm = lurek.agent.newWorkingMemory(8)
    wm:push("last_action", "jump")
    wm:push("last_room", "tower_top")
    local action = wm:get("last_action")
    local size = wm:len()
    lurek.log.info("last action=" .. tostring(action))
    lurek.log.info("working memory size=" .. tostring(size))
    lurek.log.info("last room=" .. tostring(wm:get("last_room")))
end
```

---
