local M = {}

function M.create()
    local self = {
        handlers = {},
    }

    function self:register(name, handler)
        assert(type(name) == "string" and name ~= "", "workbench command name is required")
        assert(type(handler) == "function", "workbench command handler must be a function")
        self.handlers[name] = handler
    end

    function self:dispatch(name, payload)
        local handler = self.handlers[name]
        if not handler then
            return false, "Unknown workbench command: " .. tostring(name)
        end
        local ok, result = pcall(handler, payload or {})
        if not ok then
            return false, tostring(result)
        end
        return true, result or {}
    end

    return self
end

return M
