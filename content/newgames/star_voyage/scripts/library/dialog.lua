local M = {}

local Sequencer = {}
Sequencer.__index = Sequencer

function Sequencer:setSpeed(speed)
    self.speed = speed
end

function Sequencer:on(event, fn)
    self.handlers[event] = fn
end

function Sequencer:load(nodes)
    self.nodes = nodes or {}
    self.index = 1
    self.choice = nil
end

function Sequencer:start()
    return self:advance()
end

function Sequencer:update(dt)
end

function Sequencer:advance()
    while self.index <= #self.nodes do
        local node = self.nodes[self.index]
        self.index = self.index + 1
        if node.node == "line" then
            if self.handlers.line then self.handlers.line(node.speaker or "", node.text or "") end
            return true
        elseif node.node == "choice" then
            if self.handlers.choice then self.handlers.choice(node.options or {}) end
            return true
        elseif node.node == "call" then
            local produced = node.fn and node.fn(self.choice or 1) or {}
            for i = #produced, 1, -1 do
                table.insert(self.nodes, self.index, produced[i])
            end
            self.choice = nil
        end
    end
    return false
end

function Sequencer:choose(index)
    self.choice = index
    return self:advance()
end

function M.newSequencer()
    return setmetatable({ speed = 28, handlers = {}, nodes = {}, index = 1 }, Sequencer)
end

return M
