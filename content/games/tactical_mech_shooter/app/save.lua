local M = {}
local RELATIVE_PATH = "save/tactical_mech_shooter/campaign.toml"

function M.load(root)
    local PATH = (root or "") .. RELATIVE_PATH
    if not lurek.filesystem.exists(PATH) then
        return { level = 1, stars = 0, wins = 0, losses = 0 }
    end
    local ok, value = pcall(lurek.serialize.fromToml, lurek.filesystem.read(PATH))
    if ok and value and value.campaign then return value.campaign end
    return { level = 1, stars = 0, wins = 0, losses = 0 }
end

function M.save(campaign, root)
    local directory = (root or "") .. "save/tactical_mech_shooter"
    local path = (root or "") .. RELATIVE_PATH
    if not lurek.filesystem.exists(directory) then
        lurek.filesystem.createDirectory(directory)
    end
    lurek.filesystem.write(path, lurek.serialize.toToml({ campaign = campaign }))
end

return M
