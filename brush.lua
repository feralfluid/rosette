-- brush interface
local Brush = {}

function Brush:new(colors, sizes)
    local b = {
        colors = colors or {{0, 0, 0}},
        color = 1,
        sizes = sizes or {2, 4, 7},
        size = 2,
        tools = {"draw", "erase"},
        tool = 1
    }

    self.__index = self
    setmetatable(b, self)

    return b
end

function Brush:getSize()
    return self.sizes[self.size]
end

function Brush:increaseSize()
    if self.size < #self.sizes then
        self.size = self.size + 1
    end
end

function Brush:decreaseSize()
    if self.size > 1 then
        self.size = self.size - 1
    end
end

function Brush:getTool()
    return self.tools[self.tool]
end

function Brush:setTool(tool)
    for i, v in ipairs(self.tools) do
        if v == tool then
            self.tool = i
        end
    end
end

function Brush:getColor()
    return self.colors[self.color]
end

function Brush:cycleColor()
    self.color = 1 + self.color % #self.colors
end

return Brush
