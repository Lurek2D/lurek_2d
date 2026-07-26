# First Game

This is a minimal moving-square script. Save it as `main.lua` in a game folder and run the folder with Lurek.

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

- `lurek.init` runs once after the Lua VM and `lurek.*` modules are ready.
- `lurek.process(dt)` runs every frame and updates state.
- `lurek.draw()` queues draw commands.
- `dt` is elapsed time in seconds, so movement is frame-rate independent.

## Next Steps

- Use [Project Structure](project-structure.md) when the folder grows.
- Browse [Module Guides](module-guides.md) for input, render, audio, physics, scene, tilemap, UI, and save.
- Open the [Full Lua API Reference](api/lurek.md) when you need exact signatures.
