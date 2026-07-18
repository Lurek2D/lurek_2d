local M = {}

function M.new(content)
    local signal = lurek.event.newSignal()
    local scenes = {}
    if lurek.scene then
        for _, name in ipairs({"title", "hangar", "battle", "pause", "results"}) do
            local ok, scene = pcall(lurek.scene.new, {name = name})
            if ok and scene then
                scenes[name] = scene
                pcall(lurek.scene.registerScene, name, scene)
            end
        end
    end
    return {
        content = content,
        signal = signal,
        scenes = scenes,
        phase = "hangar",
        campaign = { level = 1, stars = 0, wins = 0, losses = 0 },
        battle = nil,
        selected_map_id = content.selected_map_id,
        ui = { message = "Choose F1-F12, M for map, and deploy" },
    }
end

return M
