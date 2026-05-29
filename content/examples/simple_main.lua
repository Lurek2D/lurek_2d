-- Simple Lurek2D example main script
-- This script demonstrates a minimal game loop with a moving sprite.

-- Global variables for the sprite and its position
local sprite
local x, y = 0, 0
local speed = 200 -- pixels per second

function lurek.init()
    -- Load a sprite texture (adjust the path to an existing image in your assets folder)
    sprite = lurek.image.loadImage('assets/textures/player.png')
    if not sprite then
        error('Failed to load sprite texture')
    end
    -- Starting position (center of the window)
    local w, h = lurek.window.getDimensions()
    x = w / 2
    y = h / 2
    print('Game initialized')
end

function lurek.update(dt)
    -- Move the sprite with arrow keys
    if lurek.input.keyboard.isDown('left') then
        x = x - speed * dt
    end
    if lurek.input.keyboard.isDown('right') then
        x = x + speed * dt
    end
    if lurek.input.keyboard.isDown('up') then
        y = y - speed * dt
    end
    if lurek.input.keyboard.isDown('down') then
        y = y + speed * dt
    end
end

function lurek.draw()
    -- Clear the screen (black)
    lurek.graphics.clear(0, 0, 0, 1)
    -- Draw the sprite at its current position
    if sprite then
        sprite:draw(x, y)
    end
end

function lurek.shutdown()
    print('Game shutdown')
end
