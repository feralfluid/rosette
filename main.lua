function love.load()
    love.graphics.setPointSize(5)
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- load from file?
    config = {
        scale = 1,
        nearest = true
    }

    anim = {
        drawing = false,
        playing = false,
        tick = 0,
        frame = 1,
        frames = { newframe() },
        drawcolor = { 1, 0, 0 },
    }

    settings = {
        speed = 10,
        onion = false,
    }
end

function love.update(dt)
    anim.drawing = love.mouse.isDown(1)

    if anim.playing then
        anim.tick = anim.tick + settings.speed * dt
        anim.frame = math.floor(anim.tick) % #anim.frames + 1
    end

    -- update mouse location on canvas???
end

function love.draw()
    if anim.drawing then
        -- draw to current frame canvas
        love.graphics.setCanvas(anim.frames[anim.frame])
        love.graphics.setColor(anim.drawcolor)
        love.graphics.circle("fill", 0,  0, 4)
        love.graphics.setCanvas()
    end

    -- translate origin to center
    love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)

    -- draw interface
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("frame: "..anim.frame.." / frames: "..#anim.frames, -200, -270)
    if anim.playing then
        love.graphics.print("PLAY", 128, -272)
    else
        love.graphics.print("PAWS", 128, -272)
    end

    -- draw canvas background
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, 512, 512)

    -- draw previous frame, if onion skinning is enabled
    if settings.onion and anim.frame > 1 then
        love.graphics.setColor(0.9, 0.9, 1, 0.5)
        love.graphics.draw(anim.frames[anim.frame - 1], 0, 0, 0, 2, 2)
    end

    -- draw next frame, if onion skinning is enabled
    if settings.onion and anim.frame < #anim.frames then
        love.graphics.setColor(1, 0.9, 0.9, 0.5)
        love.graphics.draw(anim.frames[anim.frame + 1], 0, 0, 0, 2, 2)
    end

    -- draw current frame
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(anim.frames[anim.frame], 0, 0, 0, 2, 2)
end

function love.resize(w, h)
    print("window resized to "..w.."x"..h.." units.")
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit() -- YEET
    end

    if key == "return" then
        anim.frames[anim.frame] = newframe()
    end

    if key == "backspace" then
        table.remove(anim.frames, anim.frame)
        if anim.frame > 1 then
            anim.frame = anim.frame - 1
        end
    end

    if key == "space" then
        anim.playing = not anim.playing
        if not anim.playing then anim.tick = 0 end
    end

    if key == "right" then
        anim.frame = anim.frame + 1
        if not anim.frames[anim.frame] then
            anim.frames[anim.frame] = newframe()
        end
    elseif key == "left" and anim.frame > 1 then
        anim.frame = anim.frame - 1
    end

    if key == "o" then
        settings.onion = not settings.onion
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
