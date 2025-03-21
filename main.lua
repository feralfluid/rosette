local Brush = require("brush")
local Frame = require("frame")

function love.load()
    -- editor configuration, from a serialized file eventually.
    settings = require("settings")

    -- apply editor config as needed
    if settings.nearest then
        love.graphics.setDefaultFilter("nearest", "nearest")
    end
    love.graphics.setFont(love.graphics.newFont("res/fira code.ttf", 14))
    love.keyboard.setKeyRepeat(settings.keyrepeat)

    -- animation file info, will be saved in project file someday
    anim = {
        title = "animation",
        frames = { Frame:new() },
        fps = 10,
    }

    -- editor state, could also be saved in project file someday, why not
    editor = {
        frame = 1,
        tick = 0,
        playing = false,
        drawing = false,
        onion = false,
        brush = Brush:new(settings.colors),
    }
end

function love.update(dt)
    if editor.playing then
        editor.tick = editor.tick + anim.fps * dt
        editor.frame = 1 + math.floor(editor.tick) % #anim.frames
    end
end

function love.draw()
    -- translate origin to center
    love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)

    if editor.drawing then
        -- draw to current frame canvas
        love.graphics.setCanvas(anim.frames[editor.frame]:current())

        -- set draw color and blend mode
        if editor.brush:getTool() == "draw" then
            love.graphics.setColor(editor.brush:getColor())
        elseif editor.brush:getTool() == "erase" then
            love.graphics.setBlendMode("replace")
            love.graphics.setColor(0, 0, 0, 0)
        end

        -- draw a circle at the cursor location
        -- i still need to figure out why this works lmao
        local mx, my = love.graphics.inverseTransformPoint(love.mouse.getX(), love.mouse.getY())
        love.graphics.circle("fill", mx / settings.scale - (love.graphics.getWidth() / 2) + 128, my / settings.scale - (love.graphics.getHeight() / 2) + 128, editor.brush:getSize())

        -- reset state
        love.graphics.setBlendMode("alpha")
        love.graphics.setCanvas()
    end

    -- draw interface
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("frame: "..editor.frame.."/"..#anim.frames.." / fps: "..anim.fps.." / onion: "..tostring(editor.onion), -250, -278)
    love.graphics.print(editor.playing and "PLAY" or "PAWS", 210, -278)
    love.graphics.print("tool: "..editor.brush:getTool().." / size:", -250, 262)
    love.graphics.circle("fill", -72, 271, editor.brush:getSize() * settings.scale)

    -- draw canvas background
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", -128 * settings.scale, -128 * settings.scale, 256 * settings.scale, 256 * settings.scale)

    -- draw previous frame, if onion skinning is enabled
    if editor.onion and editor.frame > 1 then
        love.graphics.setColor(1, 1, 1, 0.4)
        love.graphics.draw(anim.frames[editor.frame - 1]:current(), -128 * settings.scale, -128 * settings.scale, 0, settings.scale, settings.scale)
    end

    -- draw current frame
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(anim.frames[editor.frame]:current(), -128 * settings.scale, -128 * settings.scale, 0, settings.scale, settings.scale)

    -- draw next frame, if onion skinning is enabled
    if editor.onion and editor.frame < #anim.frames then
        love.graphics.setColor(1, 1, 1, 0.4)
        love.graphics.draw(anim.frames[editor.frame + 1]:current(), -128 * settings.scale, -128 * settings.scale, 0, settings.scale, settings.scale)
    end
end

function love.resize(w, h)
    print("window resized to "..w.."x"..h.." units.")
end

function love.keypressed(key, scancode, isrepeat)
    if key == "q" then
        love.event.quit() -- YEET
    end

    -- toggle fullscreen
    if key == "f" and not isrepeat then
        love.window.setFullscreen(not love.window.getFullscreen())
    end

    -- clear current frame
    if key == "return" then
        anim.frames[editor.frame]:insert()
    end

    -- delete current frame
    if key == "backspace" then
        if #anim.frames == 1 then
            anim.frames[editor.frame]:insert()
        else
            table.remove(anim.frames, editor.frame)
            if editor.frame == #anim.frames + 1 then
                editor.frame = editor.frame - 1
            end
        end
    end

    -- play/paws
    if key == "space" then
        editor.playing = not editor.playing
        if editor.playing then
            editor.onion = false
            tick = 0
        end
    end

    -- navigate and create frames
    if key == "right" then
        if editor.frame < #anim.frames then
            editor.frame = editor.frame + 1
        elseif not (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
            editor.frame = editor.frame + 1
            table.insert(anim.frames, editor.frame, Frame:new())
        end
    elseif key == "left" then
        if editor.frame > 1 then
            editor.frame = editor.frame - 1
        elseif not (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
            table.insert(anim.frames, 1, Frame:new())
        end
    end

    -- navigate to beginning/end of animation
    if key == "home" then
        editor.frame = 1
    elseif key == "end" then
        editor.frame = #anim.frames
    end

    -- insert frame
    if key == "i" then
        editor.frame = editor.frame + 1
        table.insert(anim.frames, editor.frame, Frame:new())
    end

    -- duplicate current frame
    if key == "d" then
        editor.frame = editor.frame + 1
        table.insert(anim.frames, editor.frame, Frame:from(anim.frames[editor.frame - 1]))
    end

    -- undo and redo
    if key == "z" and not (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
        anim.frames[editor.frame]:undo()
    elseif key == "z" and (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
        anim.frames[editor.frame]:redo()
    end

    -- adjust frame rate
    if key == "up" and anim.fps < 30 then
        anim.fps = anim.fps + 1
    elseif key == "down" and anim.fps > 1 then
        anim.fps = anim.fps - 1
    end

    -- enable eraser tool
    if key == "e" then
        editor.brush:setTool("erase")
    end

    -- enable draw tool
    if key == "b" then
        editor.brush:setTool("draw")
    end

    -- cycle colors, BROKEN
    if key == "c" then
        editor.brush:setTool("draw")
        editor.brush:cycleColor()
        love.graphics.setBackgroundColor(editor.brush:getColor())
    end

    -- toggle onion skinning
    if key == "o" then
        editor.onion = not editor.onion
    end

    -- export all frames
    if key == "s" and not isrepeat then
        for _, f in ipairs(anim.frames) do
            local c = love.graphics.newCanvas(512, 512)
            c:renderTo(function()
                love.graphics.origin()
                love.graphics.setColor(1, 1, 1)
                love.graphics.rectangle("fill", 0, 0, 512, 512)
                love.graphics.draw(f:current(), 0, 0, 0, 2)
            end)
        end
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    editor.drawing = true
    anim.frames[editor.frame]:step()
end

function love.mousereleased(x, y, button, istouch, presses)
    editor.drawing = false
end

function love.wheelmoved(x, y)
    -- brush size
    if y > 0 then
        editor.brush:increaseSize()
    elseif y < 0 then
        editor.brush:decreaseSize()
    end
end

-- adds a number of leading zeroes based on the length of the largest frame index and the current index
function leadingzero(len, f)
    local s = ""
    -- for each digit in the length
    for i = 1, math.log(len, 10) do
        -- if this digit is longer than current index
        if math.log(f, 10) < i then
            s = s.."0"
        end
    end
    return s
end
