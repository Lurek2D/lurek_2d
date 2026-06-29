local M = {}

local editor_paths = {
    "editors/overview.lua",
    "editors/particle.lua",
    "editors/tilemap.lua",
    "editors/sprite_atlas.lua",
    "editors/ui_layout.lua",
}

function M.create(load_module)
    local self = {
        order = {},
        by_id = {},
    }

    for _, path in ipairs(editor_paths) do
        local editor = load_module(path)
        self.order[#self.order + 1] = editor
        self.by_id[editor.id] = editor
    end

    function self:list()
        return self.order
    end

    function self:get(id)
        return self.by_id[id] or self.order[1]
    end

    function self:match_path(path)
        for _, editor in ipairs(self.order) do
            if editor.matches_path and editor.matches_path(path) then
                return editor
            end
        end
        return nil
    end

    function self:index_of(id)
        for i, editor in ipairs(self.order) do
            if editor.id == id then return i end
        end
        return 1
    end

    return self
end

return M
