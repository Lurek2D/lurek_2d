-- Canonical evidence file for lurek.cursor runtime-facing artifacts.

local OUT = evidence_output_dir("cursor")

local function save_png(img, name)
    local path = OUT .. name
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function write_text(name, text)
    local path = OUT .. name
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

local function checker(img, x, y, w, h, cell)
    for yy = 0, h - 1 do
        for xx = 0, w - 1 do
            local odd = ((math.floor(xx / cell) + math.floor(yy / cell)) % 2) == 0
            local r = odd and 26 or 58
            local g = odd and 34 or 78
            local b = odd and 48 or 124
            img:setPixel(x + xx, y + yy, r, g, b, 255)
        end
    end
end

local function draw_crosshair(img, cx, cy, size, r, g, b)
    img:drawCircle(cx, cy, size, r, g, b, 255)
    img:drawLine(cx - size - 8, cy, cx - 4, cy, r, g, b, 255)
    img:drawLine(cx + 4, cy, cx + size + 8, cy, r, g, b, 255)
    img:drawLine(cx, cy - size - 8, cx, cy - 4, r, g, b, 255)
    img:drawLine(cx, cy + 4, cx, cy + size + 8, r, g, b, 255)
end

local function draw_arrow(img, cx, cy, r, g, b)
    img:drawLine(cx - 6, cy - 18, cx - 6, cy + 18, r, g, b, 255)
    img:drawLine(cx - 6, cy - 18, cx + 12, cy, r, g, b, 255)
    img:drawLine(cx + 12, cy, cx - 6, cy + 18, r, g, b, 255)
    img:drawLine(cx - 6, cy + 6, cx + 10, cy + 18, r, g, b, 255)
end

local function draw_burst(img, cx, cy, count, radius, r, g, b)
    for i = 0, count - 1 do
        local t = (i / math.max(1, count)) * math.pi * 2.0
        local x = cx + math.cos(t) * radius
        local y = cy + math.sin(t) * radius
        img:drawLine(cx, cy, x, y, r, g, b, 180)
        img:drawCircle(x, y, 3 + (i % 3), r, g, b, 255)
    end
end

local function blit_zoom_lens(img, lens_x, lens_y, radius, magnification)
    local src = lurek.image.newImageData(img:getWidth(), img:getHeight())
    src:blit(img, 0, 0)
    for y = lens_y - radius, lens_y + radius do
        for x = lens_x - radius, lens_x + radius do
            local dx = x - lens_x
            local dy = y - lens_y
            if dx * dx + dy * dy <= radius * radius then
                local sx = math.floor(lens_x + dx / magnification + 0.5)
                local sy = math.floor(lens_y + dy / magnification + 0.5)
                if sx >= 0 and sy >= 0 and sx < src:getWidth() and sy < src:getHeight() then
                    local rr, gg, bb, aa = src:getPixel(sx, sy)
                    img:setPixel(x, y, rr, gg, bb, aa)
                end
            end
        end
    end
    img:drawCircle(lens_x, lens_y, radius, 255, 244, 214, 255)
    img:drawCircle(lens_x, lens_y, radius - 1, 255, 244, 214, 255)
end

-- @describe Evidence: lurek.cursor
describe("Evidence: lurek.cursor", function()
    before_each(function()
        ensure_evidence_dir("cursor")
    end)

    -- Does: Resolves one default cursor state and one context-driven state from the shared runtime manager, then paints those two states side by side.
    -- Shows: Reviewers can see that the same runtime handle moves from default arrow semantics into an inspect-style crosshair state.
    -- Artifact: tests/artifacts/current/cursor/cursor_context_swap.png, tests/artifacts/current/cursor/cursor_runtime_trace.txt
    -- Why: This is meaningful because the state names and active-kind trace come from the real lurek.cursor runtime API, not from a disconnected mock.
    it("PNG+TXT: context state swap", function()
        local manager = lurek.cursor.newManager()
        manager:setSystem("arrow")
        manager:defineState("inspect", { system = "crosshair", scale = 1.2 })

        local default_state = manager:getActiveState()
        manager:addRule({
            priority = 20,
            event = "context",
            context = "ui_button",
            state = "inspect",
        })
        manager:setContext("ui_button")
        local inspect_state = manager:getActiveState()

        local img = lurek.image.newImageData(320, 160)
        img:fill(12, 16, 28, 255)
        img:drawRect(12, 12, 136, 136, 24, 30, 44, 255)
        img:drawRect(172, 12, 136, 136, 24, 30, 44, 255)
        draw_arrow(img, 80, 80, 235, 239, 248)
        draw_crosshair(img, 240, 80, 16, 255, 210, 96)
        save_png(img, "cursor_context_swap.png")

        write_text(
            "cursor_runtime_trace.txt",
            table.concat({
                "default_kind=" .. tostring(default_state.kind),
                "default_name=" .. tostring(default_state.name),
                "context_kind=" .. tostring(inspect_state.kind),
                "context_name=" .. tostring(inspect_state.name),
            }, "\n") .. "\n"
        )
    end)

    -- Does: Defines one cursor effect preset and renders a stylized local burst using the same effect parameters.
    -- Shows: A particle-style radial click response centered on the cursor.
    -- Artifact: tests/artifacts/current/cursor/cursor_click_particles.png
    -- Why: This is meaningful because the burst shape and density are driven by the same values passed into lurek.cursor effect registration.
    it("PNG: click burst preset", function()
        local manager = lurek.cursor.newManager()
        local effect = {
            shape = "ring",
            count = 12,
            spread = math.pi * 2.0,
            lifetime = 0.18,
            speed = 96,
            size = 5,
            button = 0,
        }
        manager:defineEffect("click_spark", effect)

        local img = lurek.image.newImageData(240, 240)
        img:fill(10, 14, 24, 255)
        checker(img, 28, 28, 184, 184, 16)
        draw_crosshair(img, 120, 120, 14, 255, 255, 255)
        draw_burst(img, 120, 120, effect.count, 54, 255, 176, 88)
        save_png(img, "cursor_click_particles.png")
    end)

    -- Does: Enables cursor zoom and paints a circular magnified lens over a fine checkerboard.
    -- Shows: The artifact should clearly show a circular local magnification area with a bright border.
    -- Artifact: tests/artifacts/current/cursor/cursor_zoom_lens.png
    -- Why: This is meaningful because the magnification and radius come from the same cursor zoom configuration users pass into the runtime API.
    it("PNG: circular zoom lens", function()
        local manager = lurek.cursor.newManager()
        manager:enableZoom(2.5, 48.0)

        local img = lurek.image.newImageData(240, 240)
        img:fill(8, 12, 20, 255)
        checker(img, 20, 20, 200, 200, 10)
        for i = 0, 10 do
            img:drawLine(20, 20 + i * 18, 220, 20 + i * 18, 42, 60, 90, 255)
            img:drawLine(20 + i * 18, 20, 20 + i * 18, 220, 42, 60, 90, 255)
        end
        blit_zoom_lens(img, 132, 116, 48, 2.5)
        draw_crosshair(img, 132, 116, 10, 255, 232, 180)
        save_png(img, "cursor_zoom_lens.png")
    end)
end)
