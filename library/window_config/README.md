# window_config

A fluent builder for window configuration. Chains calls to set title, size, minimum size, resizability, vsync, fullscreen mode, and window icon, then applies them all at once via `lurek.window` setters. Also ships three presets: `retro` (320×240), `hd` (1280×720), `fullhd` (1920×1080).

## Usage

```lua
local window_config = require("library/window_config")

-- Fluent builder
window_config.WindowConfig.new()
    :title("My Game")
    :size(1280, 720)
    :minSize(640, 360)
    :resizable(true)
    :vsync(true)
    :apply()

-- Presets
window_config.presets.hd():apply()
window_config.presets.retro():title("Pixel Quest"):apply()
```

## Dependencies

- `lurek.window` setters (optional — applies silently when running headlessly)
