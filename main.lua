function love.load()
    --love.graphics.setBackgroundColor(0.8, 0.8, 0.8)
    love.graphics.setPointSize(5)
    love.graphics.setDefaultFilter("nearest", "nearest")

    playing = false
    speed = 3
    tick = 0
    frame = 1
    frames = {}
    table.insert(frames, newframe())
end

function love.update(dt)
    drawing = love.mouse.isDown(1)

    if playing then
        tick = tick + speed * dt
        frame = math.floor(tick) % #frames + 1
    end
end

function love.draw()
    if drawing then
        -- draw to current frame
        love.graphics.setCanvas(frames[frame])
        love.graphics.setColor(0, 0, 0)
        love.graphics.points(love.mouse.getX() - love.graphics.getWidth() / 2 + 128, love.mouse.getY() - love.graphics.getHeight() / 2 + 128) -- draw a point to the mouse cursor location
        love.graphics.setCanvas()
    end

    -- draw current frame to screen
    love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("frame: "..frame, -128, -146)
    love.graphics.print("playing: "..tostring(playing), 45, -146)
    love.graphics.draw(frames[frame], -128, -128)
end

function love.resize(w, h)
    print("window resized to "..w.."x"..h.." units.")
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit() -- YEET
    end

    if key == "return" then
        frames[frame] = newframe()
    end

    if key == "backspace" then
        table.remove(frames, frame)
        frame = frame - 1
    end

    if key == "space" then
        playing = not playing
        if not playing then tick = 0 end
    end

    if key == "right" then
        frame = frame + 1
        if not frames[frame] then
            frames[frame] = newframe()
        end
    elseif key == "left" and frame > 1 then
        frame = frame - 1
    end
end

function newframe()
    local canvas = love.graphics.newCanvas(256, 256)
    love.graphics.setCanvas(canvas)
    love.graphics.clear(1, 1, 1)
    love.graphics.setCanvas()
    return canvas
end
