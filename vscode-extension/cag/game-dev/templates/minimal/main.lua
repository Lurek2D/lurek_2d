function luna.load()
    -- Load resources here
end

function luna.update(dt)
    -- Game logic here
end

function luna.draw()
    luna.render.clear(0.1, 0.1, 0.15)
    luna.render.print("Hello, Luna2D!", 320, 280)
end

function luna.keypressed(key)
    if key == "escape" then
        luna.signal.quit()
    end
end
