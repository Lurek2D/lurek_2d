# First Game

This minimal script moves a square with the keyboard. Save it as `main.lua` inside a game folder, then run that folder with Lurek2D.

```lua
local player = {
    x = 120,
    y = 220,
    speed = 180,
}

function lurek.init()
    lurek.window.setTitle("First Lurek game")
    lurek.render.setBackgroundColor(0.05, 0.07, 0.10)
end

function lurek.process(dt)
    if lurek.input.keyboard.isDown("left") then
        player.x = player.x - player.speed * dt
    end
    if lurek.input.keyboard.isDown("right") then
        player.x = player.x + player.speed * dt
    end
end

function lurek.draw()
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.rectangle("fill", player.x, player.y, 48, 48)
end
```

## What Is Happening

- `lurek.init()` runs once after the Lua VM and `lurek.*` modules are ready.
- `lurek.process(dt)` runs every frame and updates game state.
- `lurek.draw()` queues draw commands for the current frame.
- `dt` is elapsed time in seconds, so movement stays frame-rate independent.

## Where To Go Next

- Use [Project Structure](project-structure.md) when the folder grows beyond one script.
- Browse [Module Guides](../module-guides.md) for input, render, audio, physics, scene, tilemap, UI, save, and other systems.
- Open the [Full Lua API Reference](../api/lurek.md) when you need exact signatures.
