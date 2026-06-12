-- Canonical evidence file for lurek.ai data outputs.

local OUT = evidence_output_dir("ai")

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

-- @describe Evidence: lurek.ai data outputs
describe("Evidence: lurek.ai data outputs", function()
    before_each(function()
        ensure_evidence_dir("ai")
    end)

    -- @evidence lurek.ai.newStateMachine
    -- @evidence lurek.filesystem.write
    it("writes ai_state_machine_transitions.txt", function()
        local fsm = lurek.ai.newStateMachine()
        fsm:addState("idle", {})
        fsm:addState("patrol", {})
        fsm:addState("chase", {})
        fsm:setInitialState("idle")
        fsm:forceState("patrol")
        fsm:forceState("chase")
        local text = "fsm_states=idle,patrol,chase\ndefault_state=idle"
        write_text(OUT .. "ai_state_machine_transitions.txt", text)
    end)
end)
test_summary()
