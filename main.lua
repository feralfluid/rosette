function love.load()
    -- editor configuration
    settings = require("settings")

    -- apply editor config as needed
    if settings.nearest then
        love.graphics.setDefaultFilter("nearest", "nearest")
    end
    love.graphics.setFont(love.graphics.newFont("res/fira code.ttf", 14))
    love.keyboard.setKeyRepeat(settings.keyrepeat)

    -- animation file info, will be saved in project file someday
    anim = {
        frames = {}, -- references to history[frame][historypos[frame]]
        history = { { newframe() } },
        historypos = { 1 },
        fps = 10,
    }
    anim.frames[1] = anim.history[1][anim.historypos[1]]

    -- editor state, could also be saved in project file someday
    editor = {
        tick = 0,
        frame = 1,
        playing = false,
        drawing = false,
        onion = false,
        tool = "brush",
        brushcolor = 1,
        brushsize = 4,
        brushsizename = "medium"
    }

    -- apply editor state as needed
    love.graphics.setPointSize(editor.brushsize)
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
        love.graphics.setCanvas(anim.frames[editor.frame]) -- this should be a reference to a frame in the table at anim.history[editor.frame]

        -- set draw color and blend mode
        if editor.tool == "brush" then
            love.graphics.setColor(settings.colors[editor.brushcolor])
        elseif editor.tool == "erase" then
            love.graphics.setBlendMode("replace")
            love.graphics.setColor(0, 0, 0, 0)
        end

        -- i still need to figure out why this works lmao
        local mx, my = love.graphics.inverseTransformPoint(love.mouse.getX(), love.mouse.getY())
        love.graphics.circle("fill", mx / settings.scale - (love.graphics.getWidth() / 2) + 128, my / settings.scale - (love.graphics.getHeight() / 2) + 128, editor.brushsize)

        -- reset state
        love.graphics.setBlendMode("alpha")
        love.graphics.setCanvas()
    end

    -- draw interface
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("frame: "..editor.frame.."/"..#anim.frames.." / fps: "..anim.fps.." / onion: "..tostring(editor.onion), -250, -275)
    if editor.playing then
        love.graphics.print("PLAY", 210, -275)
    else
        love.graphics.print("PAWS", 210, -275)
    end
    love.graphics.print("tool: "..editor.tool.." / brush size: "..editor.brushsizename, -250, 258)

    -- draw canvas background
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", -128 * settings.scale, -128 * settings.scale, 256 * settings.scale, 256 * settings.scale)

    -- draw previous frame, if onion skinning is enabled
    if editor.onion and editor.frame > 1 then
        love.graphics.setColor(1, 1, 1, 0.4)
        love.graphics.draw(anim.frames[editor.frame - 1], -128 * settings.scale, -128 * settings.scale, 0, 2, 2)
    end

    -- draw current frame
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(anim.frames[editor.frame], -128 * settings.scale, -128 * settings.scale, 0, 2, 2)

    -- draw next frame, if onion skinning is enabled
    if editor.onion and editor.frame < #anim.frames then
        love.graphics.setColor(1, 1, 1, 0.4)
        love.graphics.draw(anim.frames[editor.frame + 1], -128 * settings.scale, -128 * settings.scale, 0, 2, 2)
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
        table.insert(anim.history[editor.frame], newframe())
        anim.historypos[editor.frame] = anim.historypos[editor.frame] + 1
        anim.frames[editor.frame] = anim.history[editor.frame][anim.historypos[editor.frame]]
    end

    -- delete current frame; can't be undone!
    if key == "backspace" then
        if #anim.frames == 1 then
            table.insert(anim.history[editor.frame], newframe())
            anim.historypos[editor.frame] = anim.historypos[editor.frame] + 1
            anim.frames[editor.frame] = anim.history[editor.frame][anim.historypos[editor.frame]]
        else
            table.remove(anim.frames, editor.frame)
            table.remove(anim.history, editor.frame)
            table.remove(anim.historypos, editor.frame)
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
        else
            editor.tick = 0
        end
    end

    -- navigate and create frames
    if key == "right" then
        if editor.frame < #anim.frames then
            editor.frame = editor.frame + 1
        elseif not (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
            editor.frame = editor.frame + 1
            table.insert(anim.history, editor.frame, { newframe() })
            table.insert(anim.historypos, editor.frame, 1)
            table.insert(anim.frames, editor.frame, anim.history[editor.frame][1])
        end
    elseif key == "left" then
        if editor.frame > 1 then
            editor.frame = editor.frame - 1
        elseif not (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
            table.insert(anim.history, 1, { newframe() })
            table.insert(anim.historypos, 1, 1)
            table.insert(anim.frames, 1, anim.history[editor.frame][1])
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
        table.insert(anim.history, editor.frame, { newframe() })
        table.insert(anim.historypos, editor.frame, 1)
        table.insert(anim.frames, editor.frame, anim.history[editor.frame][1])
    end

    -- duplicate current frame
    if key == "d" then
        -- duplicate frame data
        local history = {}
        for i, k in ipairs(anim.history[editor.frame]) do
            history[i] = k
        end
        local historypos = anim.historypos[editor.frame]

        -- add new frame data
        editor.frame = editor.frame + 1
        table.insert(anim.history, editor.frame, history)
        table.insert(anim.historypos, editor.frame, historypos)
        table.insert(anim.frames, editor.frame, anim.history[editor.frame][historypos])
    end

    -- undo and redo
    if key == "z" and not (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) and anim.historypos[editor.frame] > 1 then
        anim.historypos[editor.frame] = anim.historypos[editor.frame] - 1
        anim.frames[editor.frame] = anim.history[editor.frame][anim.historypos[editor.frame]]

        -- debug
        -- print("frame "..editor.frame.." history position: "..anim.historypos[editor.frame].."/"..#anim.history[editor.frame])
    elseif key == "z" and (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) and anim.historypos[editor.frame] < #anim.history[editor.frame] then
        anim.historypos[editor.frame] = anim.historypos[editor.frame] + 1
        anim.frames[editor.frame] = anim.history[editor.frame][anim.historypos[editor.frame]]

        -- debug
        -- print("frame "..editor.frame.." history position: "..anim.historypos[editor.frame].."/"..#anim.history[editor.frame])
    end

    -- adjust frame rate
    if key == "up" and anim.fps < 30 then
        anim.fps = anim.fps + 1
    elseif key == "down" and anim.fps > 1 then
        anim.fps = anim.fps - 1
    end

    -- enable eraser tool
    if key == "e" then
        editor.tool = "erase"
    end

    -- enable draw tool
    if key == "b" then
        editor.tool = "brush"
    end

    -- cycle colors
    if key == "c" then
        editor.tool = "brush"
        editor.brushcolor = 1 + editor.brushcolor % #settings.colors
        love.graphics.setBackgroundColor(settings.colors[editor.brushcolor])
    end

    -- toggle onion skinning
    if key == "o" then
        editor.onion = not editor.onion
    end

    -- export all frames
    if key == "s" and not isrepeat then
        for i, frame in ipairs(anim.frames) do
            frame:newImageData():encode("png", string.format("%s%i.png", leadingzero(#anim.frames, i), i))
        end
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    -- should probably make sure mouse is on the canvas?
    if button == 2 then
        editor.lasttool = editor.tool -- save last tool for release
        editor.tool = "erase"
    end

    editor.drawing = true

    -- delete all history past the current history position
    for i = anim.historypos[editor.frame] + 1,#anim.history[editor.frame] do
        table.remove(anim.history[editor.frame], anim.historypos[editor.frame] + 1)
    end
    -- concat current frame to this frame's history
    table.insert(anim.history[editor.frame], newframe(anim.frames[editor.frame]))
    -- change history position
    anim.historypos[editor.frame] = anim.historypos[editor.frame] + 1
    -- switch to new frame
    anim.frames[editor.frame] = anim.history[editor.frame][anim.historypos[editor.frame]]

    -- debug
    -- print("frame "..editor.frame.." history position: "..anim.historypos[editor.frame].."/"..#anim.history[editor.frame])
end

function love.mousereleased(x, y, button, istouch, presses)
    -- this should only activate if mouse is released on the canvas, but it's ok for now
    if button == 2 then
        editor.tool = editor.lasttool
    end

    editor.drawing = false
end

-- naive brush size switching
function love.wheelmoved(x, y)
    if y > 0 then
        if editor.brushsizename == "small" then
            editor.brushsizename = "medium"
            editor.brushsize = 4
        elseif editor.brushsizename == "medium" then
            editor.brushsizename = "large"
            editor.brushsize = 7
        end
    elseif y < 0 then
        if editor.brushsizename == "large" then
            editor.brushsizename = "medium"
            editor.brushsize = 4
        elseif editor.brushsizename == "medium" then
            editor.brushsizename = "small"
            editor.brushsize = 2
        end
    end
end

function newframe(f)
    local canvas = love.graphics.newCanvas(256, 256)
    if f then
        canvas:renderTo(function()
            love.graphics.origin()
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(f)
        end)
    end
    return canvas
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
