function love.load()
    -- editor configuration
    settings = require("settings")

    -- apply editor config as needed
    if settings.nearest then
        love.graphics.setDefaultFilter("nearest", "nearest")
    end
    love.graphics.setBackgroundColor(settings.bg)
    love.graphics.setFont(love.graphics.newFont("res/font.ttf", 14))

    -- animation file info, will be saved in project file
    anim = {
        frames = { newframe() },
        fps = 10,
    }

    -- editor state, could also be saved in project file
    editor = {
        tick = 0,
        frame = 1,
        playing = false,
        drawing = false,
        onion = false,
        drawcolor = { 0, 0, 0 },
        drawsize = 5
    }

    -- apply editor state as needed
    love.graphics.setPointSize(editor.drawsize)
end

function love.update(dt)
    -- this only really makes sense if the mouse is over the canvas
    editor.drawing = love.mouse.isDown(1)

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
        love.graphics.setCanvas(anim.frames[editor.frame])
        love.graphics.setColor(editor.drawcolor)

        -- i still need to figure out why this works
        local mx, my = love.graphics.inverseTransformPoint(love.mouse.getX(), love.mouse.getY())
        love.graphics.circle("fill", mx / settings.scale - (love.graphics.getWidth() / 2) + 128, my / settings.scale - (love.graphics.getHeight() / 2) + 128, 4)

        love.graphics.setCanvas()
    end

    -- draw interface
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("frame: "..editor.frame.." / frames: "..#anim.frames.." / onion: "..tostring(editor.onion), -250, -275)
    if editor.playing then
        love.graphics.print("PLAY", 210, -275)
    else
        love.graphics.print("PAWS", 210, -275)
    end

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

function love.keypressed(key)
    if key == "escape" then
        love.event.quit() -- YEET
    end

    if key == "return" then
        anim.frames[editor.frame] = newframe()
    end

    if key == "backspace" then
        if #anim.frames == 1 then
            anim.frames[editor.frame] = newframe()
            return
        end
        table.remove(anim.frames, editor.frame)
        if editor.frame > 1 then
            editor.frame = editor.frame - 1
        end
    end

    if key == "space" then
        editor.onion = false
        editor.playing = not editor.playing
        if not editor.playing then editor.tick = 0 end
    end

    if key == "right" then
        editor.frame = editor.frame + 1
        if not anim.frames[editor.frame] then
            anim.frames[editor.frame] = newframe()
        end
    elseif key == "left" then
        if editor.frame > 1 then
            editor.frame = editor.frame - 1
        else
            table.insert(anim.frames, 1, newframe())
        end
    end

    if key == "o" then
        editor.onion = not editor.onion
    end

    if key == "s" then
        for i, frame in ipairs(anim.frames) do
            frame:newImageData():encode("png", string.format("%i.png", i))
        end
    end
end

function newframe()
    local canvas = love.graphics.newCanvas(256, 256)
    love.graphics.setCanvas(canvas)
    love.graphics.translate(128, 128)
    love.graphics.clear(1, 1, 1, 0)
    love.graphics.setCanvas()
    return canvas
end
