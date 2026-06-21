-- test_agent_evidence.lua
-- Canonical evidence file for lurek.agent context and memory artifacts.

local OUT = evidence_output_dir("agent")

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

local function read_text(path)
    if read_file then
        return read_file(path) or ""
    end
    return ""
end

local function append_lines(lines, prefix, rows)
    for _, row in ipairs(rows) do
        lines[#lines + 1] = prefix .. row
    end
end

-- @describe Evidence: lurek.agent showcase-derived artifacts
describe("Evidence: lurek.agent showcase-derived artifacts", function()
    before_each(function()
        ensure_evidence_dir("agent")
    end)

    -- Does: Rebuilds the useful non-network parts of the old agent pipeline demo into a deterministic memory and context artifact set.
    -- Shows: The artifacts should let a reviewer inspect template rendering, working or episodic or semantic memory state, AISystem context provenance, and persisted bundled memory without needing a live model server.
    -- Artifact: tests/artifacts/current/agent/agent_context_memory_report.txt, tests/artifacts/current/agent/agent_memory_bundle.json
    -- Why: This is meaningful because every line comes from lurek.agent template, memory, diagnostics, and system-context APIs rather than from handwritten fixture text.

    it("TXT+JSON: agent_context_memory_report -- pipeline context and persisted memory bundle", function()
        local bundle_path = OUT .. "agent_memory_bundle.json"
        local report_path = OUT .. "agent_context_memory_report.txt"

        local working = lurek.agent.newWorkingMemory(4)
        working:push("phase", "boot")
        working:push("model", "llama3")
        working:push("role", "planner")

        local episodic = lurek.agent.newEpisodicMemory()
        episodic:record(1, { event = "init", module = "agent_pipeline_demo" })
        episodic:record(2, { event = "dispatch", status = "prepared" })

        local semantic = lurek.agent.newSemanticMemory()
        semantic:learn("goal", { value = "show full agent pipeline", category = "demo" })
        semantic:learn("owner", { value = "planner", category = "agent" })

        local memory = lurek.agent.newAgentMemory({
            working_capacity = 6,
            persist_path = bundle_path,
        })
        memory:working():push("phase", "boot")
        memory:working():push("owner", "system")
        memory:working():push("scope", "evidence")
        memory:episodic():record(10, { event = "init", tag = "boot" })
        memory:episodic():record(20, { event = "dispatch", tag = "ready" })
        memory:semantic():learn("goal", { value = "show full agent pipeline", category = "demo" })
        memory:semantic():learn("screen", { value = "single panel", category = "ui" })

        expect_true(memory:save())
        expect_true(memory:load())
        expect_evidence_created(bundle_path)

        local template = lurek.agent.newTemplate("[TASK] {task} | [OWNER] {owner}")
        local rendered = template:render({
            task = "Prepare prompt sequence",
            owner = "system",
        })

        local planner = lurek.agent.new({
            url = "http://127.0.0.1:11434/api/generate",
            model = "llama3",
            format = "json",
        })
        planner:setName("planner")
        planner:setDescription("Breaks goals into clear implementation steps.")
        planner:addSkill("budget", "Keep scope under one screen and one scene.")

        local system = lurek.agent.newSystem({
            system_prompt = "You are a multi-agent game content coordinator.",
        })
        system:addAgent("planner", planner)
        system:addInstruction("output_shape", "Return concise structured JSON where possible.")
        system:addInstruction("demo_scope", "Focus on one small Lua demo scene.")
        system:addSkill("combat_skill", { "combat", "enemy", "damage", "boss" }, "Prefer deterministic and testable combat loops.")
        system:addSkill("ui_skill", { "ui", "hud", "menu", "panel" }, "Keep layout simple and readable at 960x540.")

        local report = system:buildContextReport(
            "Design combat HUD and enemy warning markers.",
            { agent = "planner", instructions = { "output_shape", "demo_scope" } }
        )
        local memory_diag = memory:getDiagnostics()
        local system_diag = system:getDiagnostics()
        local agent_diag = lurek.agent.getDiagnostics()

        local recent = working:getRecent(3)
        local sem_demo = semantic:query({ category = "demo" })
        local episodes = episodic:query({})
        local bundle_text = read_text(bundle_path)

        local lines = {
            "template=" .. rendered,
            string.format("system_counts agents=%d instructions=%d skills=%d", system:agentCount(), system:instructionCount(), system:skillCount()),
            string.format("context_len=%d provenance=%d", #report.text, #report.provenance),
            string.format("working_recent=%d episodic=%d semantic_demo=%d", #recent, #episodes, #sem_demo),
            string.format("bundle_bytes=%d", #bundle_text),
            string.format(
                "memory_diag working_entries=%s episodic_entries=%s semantic_entries=%s sandbox_root=%s",
                tostring(memory_diag.working_entries),
                tostring(memory_diag.episodic_entries),
                tostring(memory_diag.semantic_entries),
                tostring(memory_diag.sandbox_root)
            ),
            string.format(
                "system_diag in_flight=%s completed=%s avg_latency_ms=%s",
                tostring(system_diag.in_flight),
                tostring(system_diag.completed),
                tostring(system_diag.avg_latency_ms)
            ),
            string.format(
                "agent_diag in_flight=%s completed=%s avg_latency_ms=%s",
                tostring(agent_diag.in_flight),
                tostring(agent_diag.completed),
                tostring(agent_diag.avg_latency_ms)
            ),
            "working_recent_keys=" .. table.concat({
                recent[1] and recent[1].key or "",
                recent[2] and recent[2].key or "",
                recent[3] and recent[3].key or "",
            }, ","),
            "semantic_demo_goal=" .. tostring(sem_demo[1] and sem_demo[1].value and sem_demo[1].value.value),
            "episodic_last=" .. tostring(episodes[#episodes] and episodes[#episodes].data and episodes[#episodes].data.event),
            "context_preview_begin",
        }

        local preview = report.text:gsub("\r\n", "\n")
        local preview_lines = {}
        for line in preview:gmatch("[^\n]+") do
            preview_lines[#preview_lines + 1] = line
            if #preview_lines >= 8 then
                break
            end
        end
        append_lines(lines, "  ", preview_lines)
        lines[#lines + 1] = "context_preview_end"
        lines[#lines + 1] = "provenance_begin"
        for i, item in ipairs(report.provenance) do
            lines[#lines + 1] = string.format(
                "  %02d kind=%s key=%s name=%s",
                i,
                tostring(item.kind),
                tostring(item.key),
                tostring(item.name)
            )
        end
        lines[#lines + 1] = "provenance_end"

        write_text(report_path, table.concat(lines, "\n") .. "\n")
    end)
end)

test_summary()
