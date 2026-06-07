# Agent

## Summary

The agent module provides a complete artificial intelligence and language model capability layer for the Lurek2D engine runtime, enabling gameplay scripts to integrate smart behaviors and dynamic conversations. It establishes stateful and stateless interface models that allow game entities to interact with large language models, perform text prompt completions, execute structured JSON requests, and generate text embeddings directly within the live simulation framework.

To support long-term reasoning and context-aware interactions, the module supplies a robust, tiered agent memory system. Scripts can utilize bounded first-in-first-out working memory for immediate conversation contexts, append-only episodic memory to log and query timestamped game events, and unbounded semantic memory to retain key-value facts. These tiers can be unified into a cohesive memory bundle that supports saving and loading across sessions for persistent player-agent history.

For complex multi-agent simulation scenarios, the module exposes high-level orchestration architectures like multi-agent managers and intelligent AI systems. Developers can register several distinct agent profiles with specialized roles, supply explicit instructions, and define keyword-gated systems that automatically inject relevant skill prompts based on user input. This setup coordinates parallel execution flows and schedules background processing seamlessly.

Additionally, the module takes charge of local Ollama infrastructure management, providing complete control over server processes, model downloads, and operational status checks. By handling network transport details—such as request retries, time-out bounds, task cancellations, and frame-safe background polling—the runtime isolates gameplay loops from networking latency, ensuring deterministic frame updates and stable performance.

## Functions

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
    local reply = lurek.agent.complete("Hello, world!")
    print("Reply:", reply)
end
```

---

### `lurek.agent.completeAsync`

Sends a prompt asynchronously using a background thread; calls `callback(text, err)` on completion.

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
| nil | No value is returned. |

**Example**

```lua
do
    lurek.agent.completeAsync("What is Lua?", function(text, err)
        if err then
            print("Error:", err)
        else
            print("Async reply:", text)
        end
    end)
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
    local result = lurek.agent.completeJson("List three colors as JSON.")
    print("JSON result:", result)
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
| `config` | table | Config with `provider`, `base_url`, `model`, `timeout_ms`, and `api_key` fields. |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    lurek.agent.configure({
        provider    = "ollama",
        base_url    = "http://127.0.0.1:11434",
        model       = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M",
        timeout_ms  = 30000,
        api_key     = nil,
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
    local vec = lurek.agent.embed("Semantic embedding test.")
    print("Embedding dimensions:", #vec)
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
    local ok = lurek.agent.isAvailable()
    print("LLM available:", ok)
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
    local models = lurek.agent.listModels()
    print("Available models:", #models)
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
    local agent = lurek.agent.new({
        url          = "http://localhost:11434/api/generate",
        model        = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M",
        system_prompt = "You are a helpful game AI.",
        format       = "json",
        name         = "helper",
        description  = "Provides general assistance to the player.",
        max_retries  = 2,
        timeout      = 30,
        options      = {
            num_ctx     = 4096,
            temperature = 0.7,
            seed        = 42,
        },
    })
    print("Agent created:", agent)
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
    ---@type LAgentMemory
    local mem = lurek.agent.newAgentMemory({ working_capacity = 32, persist_path = nil })
    print("Agent memory created:", mem)
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
    ---@type LAgentChat
    local chat = lurek.agent.newChat()
    print("Chat created:", chat)
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
    ---@type LEpisodicMemory
    local em = lurek.agent.newEpisodicMemory()
    print("Episodic memory created:", em)
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
    local manager = lurek.agent.newManager()
    print("Manager created:", manager)
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
| `config?` | table | Optional config with `url` (default `"http://127.0.0.1:11434"`). |

**Returns**

| Type | Description |
|------|-------------|
| [LOllamaManager](#lollamamanager) | A new Ollama manager object. |

**Example**

```lua
do
    local ollama = lurek.agent.newOllama()
    print("OllamaManager created, default URL http://127.0.0.1:11434")
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
    ---@type LSemanticMemory
    local sm = lurek.agent.newSemanticMemory()
    print("Semantic memory created:", sm)
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
    local system = lurek.agent.newSystem({
        system_prompt = "You are a multi-agent game orchestrator. Respond concisely.",
    })
    print("AISystem created:", system)
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
    ---@type LAgentTemplate
    local tmpl = lurek.agent.newTemplate("Hello, {name}!")
    print("Template created:", tmpl)
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
    ---@type LWorkingMemory
    local wm = lurek.agent.newWorkingMemory(16)
    print("Working memory capacity:", wm:capacity())
end
```

---

## Module Fields

*No module-level fields documented.*

## Callbacks

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
    local system = lurek.agent.newSystem({ system_prompt = "You are a game design AI." })

    local npc = lurek.agent.new({ url = "http://localhost:11434/api/generate", model = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M", format = "json" })
    npc:setDescription("Writes NPC dialogue with emotional depth and regional accents.")

    system:addAgent("npc_writer", npc)
    print("Agent 'npc_writer' added to system.")
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
    local system = lurek.agent.newSystem({})
    system:addInstruction("art_style", "Use a 16-bit pixel art visual style. Palettes are limited to 16 colours per sprite.")
    system:addInstruction("tone",      "Keep all responses concise and in present tense.")
    print("Instructions added to system.")
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
    print("System skills added.")
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
    local system = lurek.agent.newSystem({})
    local agent  = lurek.agent.new({})
    system:addAgent("a1", agent)
    system:addAgent("a2", agent)
    print("Agent count:", system:agentCount())
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
    print("Context preview:\n", ctx)
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
    local system = lurek.agent.newSystem({})
    local agent  = lurek.agent.new({})
    system:addAgent("planner", agent)
    print("Has 'planner':", system:hasAgent("planner"))
    print("Has 'ghost':",   system:hasAgent("ghost"))
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
    local system = lurek.agent.newSystem({})
    system:addInstruction("tone", "Be concise.")
    print("Has 'tone':",    system:hasInstruction("tone"))
    print("Has 'missing':", system:hasInstruction("missing"))
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
    local system = lurek.agent.newSystem({})
    system:addSkill("combat_rules", { "combat", "attack" }, "Turn-based combat.")
    print("Has 'combat_rules':",  system:hasSkill("combat_rules"))
    print("Has 'no_such_skill':", system:hasSkill("no_such_skill"))
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
    local system = lurek.agent.newSystem({})
    system:addInstruction("tone",      "Be concise.")
    system:addInstruction("art_style", "Use pixel art.")
    print("Instruction count:", system:instructionCount())
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
    local system = lurek.agent.newSystem({})
    local a = lurek.agent.new({})
    system:addAgent("writer",   a)
    system:addAgent("designer", a)
    local names = system:listAgents()
    for _, name in ipairs(names) do
        print("Registered agent:", name)
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
    local system = lurek.agent.newSystem({})
    system:addInstruction("tone",      "Be concise.")
    system:addInstruction("art_style", "Use pixel art.")
    local keys = system:listInstructions()
    for _, key in ipairs(keys) do
        print("Instruction key:", key)
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
    local system = lurek.agent.newSystem({ system_prompt = "You are a game design AI." })
    system:addInstruction("art_style", "Use 16-bit pixel art.")
    system:addSkill("pixel_art_rules", { "sprite", "texture" }, "Max 16 colours per tile.")

    local designer = lurek.agent.new({
        url    = "http://localhost:11434/api/generate",
        model  = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M",
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
                print("Design:", data.description)
            else
                print("Error:", err_info.message)
            end
        end,
        { instructions = { "art_style" } }
    )
    print("System prompt dispatched, id =", id)
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
    local system = lurek.agent.newSystem({})
    local agent  = lurek.agent.new({})
    system:addAgent("temp_agent", agent)
    local removed = system:removeAgent("temp_agent")
    print("Agent removed:", removed)
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
    local system = lurek.agent.newSystem({})
    system:addInstruction("debug_hint", "Temporary debug context.")
    local removed = system:removeInstruction("debug_hint")
    print("Instruction removed:", removed)
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
    local system = lurek.agent.newSystem({})
    system:addSkill("temp_skill", { "test" }, "Temporary.")
    local removed = system:removeSkill("temp_skill")
    print("Skill removed:", removed)
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
    local system = lurek.agent.newSystem({ system_prompt = "You are a game AI team." })
    system:addInstruction("art_style", "16-bit pixel art.")

    local writer   = lurek.agent.new({ url = "http://localhost:11434/api/generate", model = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M", format = "json" })
    local designer = lurek.agent.new({ url = "http://localhost:11434/api/generate", model = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M", format = "json" })
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
            print("Task " .. i, res.success and tostring(res.data) or res.error.message)
        end
    end)
    print("System runAll dispatched, id =", id)
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
    local system = lurek.agent.newSystem({})
    system:addSkill("combat_rules",   { "combat" },        "Turn-based combat.")
    system:addSkill("pixel_art_rules", { "sprite", "tile" }, "16 colours max.")
    print("Skill count:", system:skillCount())
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
    local system = lurek.agent.newSystem({})
    -- Called every frame in the game loop.
    system:update()
    print("AISystem polled for responses.")
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
    local agent = lurek.agent.new({})
    agent:addSkill("location", "The player is currently in the Darkwood forest.")
    agent:addSkill("time",     "It is midnight in the game world.")
    print("Skills added to agent context.")
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
    local agent = lurek.agent.new({
        url = "http://localhost:11434/api/generate",
        model = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M",
    })
    local id = agent:prompt("Long-running request.", function() end)
    agent:cancel(id)
    print("Request cancelled, id =", id)
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
    local agent = lurek.agent.new({})
    agent:addSkill("temp", "Some context.")
    agent:clearSkills()
    print("Agent skills cleared.")
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
    local agent = lurek.agent.new({})
    local ok = agent:evalCode("local x = 1 + 1; print('eval result:', x)")
    print("evalCode ok:", ok)
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
    local agent = lurek.agent.new({})
    agent:setDescription("Plans tasks.")
    local desc = agent:getDescription()
    print("Agent description:", desc)
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
    local agent = lurek.agent.new({ format = "json" })
    local fmt   = agent:getFormat()
    print("Agent format:", fmt)
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
    local agent = lurek.agent.new({ model = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M" })
    local m     = agent:getModel()
    print("Agent model:", m)
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
    local agent = lurek.agent.new({})
    agent:setName("planner")
    local name = agent:getName()
    print("Agent name:", name)
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
    local agent = lurek.agent.new({ url = "http://127.0.0.1:11434/api/generate" })
    local url   = agent:getUrl()
    print("Agent URL:", url)
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
    local agent = lurek.agent.new({})
    agent:addSkill("location", "The player is in the Darkwood forest.")
    print("Has 'location' skill:", agent:hasSkill("location"))
    print("Has 'weather' skill:", agent:hasSkill("weather"))
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
    local agent = lurek.agent.new({})
    agent:addSkill("combat",    "Turn-based combat.")
    agent:addSkill("inventory", "Inventory management.")
    local names = agent:listSkills()
    for _, name in ipairs(names) do
        print("Skill:", name)
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
    local agent = lurek.agent.new({})
    local n = agent:pendingCount()
    print("Pending in-flight requests:", n)
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
    local agent = lurek.agent.new({
        url    = "http://localhost:11434/api/generate",
        model  = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M",
        format = "json",
    })

    -- Async — must call agent:update() in the game loop to receive callbacks.
    local id = agent:prompt("Describe what the player sees when entering the forest.", function(success, data, err_info)
        if success then
            print("Response:", data.description or data.response)
        else
            print("Error [" .. err_info.code .. "]:", err_info.message)
        end
    end)
    print("Prompt dispatched, id =", id)
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
    local agent = lurek.agent.new({
        url    = "http://localhost:11434/api/generate",
        model  = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M",
        format = "json",
    })

    local id = agent:promptBatch({
        "Describe the bridge.",
        "Describe the engine room.",
        "Describe the dungeon entrance.",
    }, function(results)
        for i, res in ipairs(results) do
            if res.success then
                print("Result " .. i .. ":", res.data.description)
            else
                print("Task " .. i .. " failed [" .. res.error.code .. "]:", res.error.message)
            end
        end
    end)
    print("Batch dispatched, id =", id)
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
    local agent = lurek.agent.new({})
    agent:setContextSize(8192)
    print("Agent context window set to 8192 tokens.")
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
    local agent = lurek.agent.new({})
    agent:setDescription("Specialises in writing NPC dialogue with emotional depth.")
    print("Agent description set.")
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
    local agent = lurek.agent.new({})
    agent:setFormat("text")
    print("Agent format changed to text.")
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
    local agent = lurek.agent.new({})
    agent:setMaxRetries(3)
    print("Agent max retries set to 3.")
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
    local agent = lurek.agent.new({ model = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M" })
    agent:setModel("SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M")
    print("Agent model changed to SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M.")
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
    local agent = lurek.agent.new({})
    agent:setName("npc_writer")
    print("Agent name set.")
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
    local agent = lurek.agent.new({})
    agent:setOption("temperature", 0.4)
    agent:setOption("seed", 1234)
    print("Agent options set.")
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
    local agent = lurek.agent.new({})
    agent:setTemperature(0.9)
    print("Agent temperature set to 0.9.")
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
    local agent = lurek.agent.new({})
    agent:setTimeout(90)
    print("Agent timeout set to 90 s.")
end
```

---

#### `LAgent:setUrl`

Changes the LLM endpoint URL for future prompts.

```lua
LAgent:setUrl(url)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `url` | string | Full endpoint URL (e.g. `"http://127.0.0.1:11434/api/generate"`). |

**Returns**

| Type | Description |
|------|-------------|
| nil | No value is returned. |

**Example**

```lua
do
    local agent = lurek.agent.new({})
    agent:setUrl("http://10.0.0.5:11434/api/generate")
    print("Agent URL updated.")
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
    local agent = lurek.agent.new({})
    agent:addSkill("s1", "Context A.")
    agent:addSkill("s2", "Context B.")
    print("Skill count:", agent:skillCount())
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
    local agent = lurek.agent.new({})
    -- Called every frame in the game loop to deliver completed LLM responses.
    agent:update()
    print("Agent polled for responses.")
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
    local chat = lurek.agent.newChat()
    chat:addMessage("user", "Tell me a joke.")
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
    local chat = lurek.agent.newChat()
    chat:addMessage("user", "Hello")
    chat:clear()
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
    local chat = lurek.agent.newChat()
    chat:addMessage("user", "Hi!")
    local reply = chat:complete()
    print("Chat reply:", reply)
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
    local chat = lurek.agent.newChat()
    local history = chat:getHistory()
    print("History entries:", #history)
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
    local chat = lurek.agent.newChat()
    chat:setSystemPrompt("You are a helpful assistant.")
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
    local manager = lurek.agent.newManager()

    local writer   = lurek.agent.new({ url = "http://localhost:11434/api/generate", model = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M", format = "json" })
    local designer = lurek.agent.new({ url = "http://localhost:11434/api/generate", model = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M", format = "json" })

    local id = manager:runAll({
        { agent = writer,   instruction = "Write a boss intro monologue." },
        { agent = designer, instruction = "Design the boss arena layout."  },
    }, function(results)
        for i, res in ipairs(results) do
            print("Task " .. i, res.success and tostring(res.data) or res.error.message)
        end
    end)
    print("Manager batch dispatched, id =", id)
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
    local manager = lurek.agent.newManager()
    -- Called every frame in the game loop.
    manager:update()
    print("Manager polled for batch responses.")
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
    local mem = lurek.agent.newAgentMemory({ working_capacity = 8 })
    local em = mem:episodic()
    print("Episodic memory from bundle:", em)
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
    local mem = lurek.agent.newAgentMemory({ persist_path = "save/agent_mem.json" })
    local ok  = mem:load()
    print("Memory loaded:", ok)
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
    local mem = lurek.agent.newAgentMemory({ persist_path = "save/agent_mem.json" })
    local ok  = mem:save()
    print("Memory saved:", ok)
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
    local mem = lurek.agent.newAgentMemory({ working_capacity = 8 })
    local sm = mem:semantic()
    print("Semantic memory from bundle:", sm)
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
    local mem = lurek.agent.newAgentMemory({ working_capacity = 8 })
    local wm = mem:working()
    print("Working memory from bundle:", wm)
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
    local tmpl = lurek.agent.newTemplate("Hello, {name}! You are {age} years old.")
    local out  = tmpl:render({ name = "Alice", age = "30" })
    print("Rendered:", out)
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
    local em = lurek.agent.newEpisodicMemory()
    em:record(10, { note = "old" })
    em:record(200, { note = "new" })
    em:forgetBefore(100)
    print("Episodes after prune:", em:len())
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
    local em = lurek.agent.newEpisodicMemory()
    em:record(1, { x = 1 })
    print("Episode count:", em:len())
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
    local em = lurek.agent.newEpisodicMemory()
    em:record(1, { type = "kill" })
    local results = em:query({ type = "kill" })
    print("Kill events:", #results)
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
    local em = lurek.agent.newEpisodicMemory()
    em:record(100, { event = "player_hit", damage = 10 })
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
    local ollama = lurek.agent.newOllama({ url = "http://127.0.0.1:11434" })
    local url    = ollama:baseUrl()
    print("Ollama base URL:", url)
end
```

---

#### `LOllamaManager:deleteModel`

Sends `DELETE /api/delete` to remove a model from local Ollama storage.

```lua
LOllamaManager:deleteModel(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Model name to delete (e.g. `"llama3:latest"`). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` if the request succeeded. |

**Example**

```lua
do
    local ollama = lurek.agent.newOllama()
    local ok     = ollama:deleteModel("SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M")
    print("Model deleted:", ok)
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
    local ollama = lurek.agent.newOllama()
    local found  = ollama:hasModel("SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M")
    print("SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M available:", found)
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
    local ollama  = lurek.agent.newOllama()
    local running = ollama:isRunning()
    print("Ollama running:", running)
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
    local ollama = lurek.agent.newOllama()
    local models = ollama:listModels()
    for _, m in ipairs(models) do
        print(m.name, string.format("%.1f GB", m.size_gb))
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
    local ollama = lurek.agent.newOllama()
    local names  = ollama:modelNames()
    for _, name in ipairs(names) do
        print("Available model:", name)
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
    local ollama = lurek.agent.newOllama()
    local n      = ollama:pendingCount()
    print("In-flight pulls:", n)
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
    local ollama = lurek.agent.newOllama()
    local id     = ollama:pullModel("SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M", function(success, err_msg)
        if success then
            print("Model downloaded successfully.")
        else
            print("Pull failed:", err_msg)
        end
    end)
    print("Pull started, callback id =", id)
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
    local ollama = lurek.agent.newOllama()
    local ok     = ollama:restart()
    print("Ollama restarted:", ok)
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
    local ollama = lurek.agent.newOllama()
    local ok     = ollama:start()
    print("Ollama started:", ok)
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
    local ollama  = lurek.agent.newOllama()
    local stopped = ollama:stop()
    print("Ollama stopped:", stopped)
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
    local ollama = lurek.agent.newOllama()
    -- Dispatch pull callbacks that completed since the last frame.
    ollama:update()
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
    local ollama = lurek.agent.newOllama()
    local v      = ollama:version()
    print("Ollama version:", v)
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
    local sm = lurek.agent.newSemanticMemory()
    sm:learn("temp_fact", { value = 42 })
    local removed = sm:forget("temp_fact")
    print("Removed:", removed)
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
    local sm = lurek.agent.newSemanticMemory()
    sm:learn("capital_of_france", { value = "Paris" })
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
    local sm = lurek.agent.newSemanticMemory()
    sm:learn("k", { v = 1 })
    print("Facts:", sm:len())
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
    local sm = lurek.agent.newSemanticMemory()
    sm:learn("fact_a", { category = "geo" })
    sm:learn("fact_b", { category = "geo" })
    local geo_facts = sm:query({ category = "geo" })
    print("Geo facts:", #geo_facts)
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
    local sm = lurek.agent.newSemanticMemory()
    sm:learn("color", { hex = "#FF0000" })
    local fact = sm:recall("color")
    print("Recalled:", fact)
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
    local wm = lurek.agent.newWorkingMemory(32)
    print("WM capacity:", wm:capacity())
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
    local wm = lurek.agent.newWorkingMemory(8)
    wm:push("temp", "value")
    local removed = wm:forget("temp")
    print("Removed:", removed)
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
    local wm = lurek.agent.newWorkingMemory(8)
    wm:push("hp", 100)
    local hp = wm:get("hp")
    print("HP:", hp)
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
    local wm = lurek.agent.newWorkingMemory(8)
    wm:push("a", 1)
    wm:push("b", 2)
    local recent = wm:getRecent(2)
    print("Recent entries:", #recent)
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
    local wm = lurek.agent.newWorkingMemory(8)
    wm:push("x", 42)
    print("WM size:", wm:len())
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
    local wm = lurek.agent.newWorkingMemory(8)
    wm:push("last_action", "jump")
end
```

---
