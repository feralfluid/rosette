-- frame interface
local Frame = {}

function Frame:new()
    local f = {
        history = {},
        position = 0
    }

    self.__index = self
    setmetatable(f, self)

    f:insert()

    return f
end

-- deep copy
function Frame:from(other)
    local f = self:new()
    for i, k in ipairs(other.history) do
        f.history[i] = k
    end
    f.position = other.position
    return f
end

-- copies a canvas onto current
function Frame:render(canvas)
    self.history[self.position]:renderTo(function()
        love.graphics.origin()
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(canvas)
    end)
end

function Frame:insert()
    self.position = self.position + 1
    table.insert(self.history, self.position, love.graphics.newCanvas(256, 256))
end

-- steps a frame forward in edit history
function Frame:step()
    -- delete any history items past the current position
    for _ = self.position + 1, #self.history do
        table.remove(self.history)
    end
    -- insert new canvas
    self:insert()
    -- since the position should be at the top now.
    self.position = #self.history
    -- render previous onto current canvas
    if self:prev() then
        self:render(self:prev())
    end
end

function Frame:prev()
    if self.position > 1 then
        return self.history[self.position - 1]
    end
end

function Frame:current()
    return self.history[self.position]
end

function Frame:next()
    if self.position < #self.history then
        return self.history[self.position + 1]
    end
end

function Frame:undo()
    if self.position > 1 then
        self.position = self.position - 1
    end
end

function Frame:redo()
    if self.position < #self.history then
        self.position = self.position + 1
    end
end

return Frame
