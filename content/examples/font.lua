-- content/examples/font.lua
-- Run: cargo run -- content/examples/font.lua





--@api: lurek.font.getDefault
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.getDefault()
    local name = font:getName()
    local size = font:getSize()
    local line_height = font:lineHeight()
    local title_width = select(1, font:measure(ui_title(), 1.0))
    font_log("default ui font name=" .. tostring(name) .. " size=" .. tostring(size) .. " line_height=" .. tostring(line_height) .. " title_width=" .. tostring(title_width))
end

--@api: lurek.font.load
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.load(sample_font_path(), 14)
    local name = font:getName()
    local style = font:getStyle()
    local preview_width = select(1, font:measure("Campaign report", 1.0))
    local preview_height = select(2, font:measure("Campaign report", 1.0))
    font_log("loaded ttf for codex preview name=" .. tostring(name) .. " style=" .. tostring(style) .. " preview=" .. tostring(preview_width) .. "x" .. tostring(preview_height))
end

--@api: lurek.font.loadBitmap
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local atlas_path = "content/examples/assets/fonts/missing_bitmap_font.png"
    local cell_width = 8
    local cell_height = 8
    local ok, result = pcall(lurek.font.loadBitmap, atlas_path, cell_width, cell_height)
    local reason = ok and "loaded" or tostring(result)
    font_log("bitmap atlas import for retro hud path=" .. atlas_path .. " cell=" .. tostring(cell_width) .. "x" .. tostring(cell_height) .. " ok=" .. tostring(ok) .. " result=" .. reason)
end

--@api: lurek.font.list
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local before = lurek.font.list()
    local runtime_font = lurek.font.load(sample_font_path(), 16)
    local after = lurek.font.list()
    local first = after[1] or {}
    local grew = #after > #before
    font_log("font catalog refresh count_before=" .. tostring(#before) .. " count_after=" .. tostring(#after) .. " grew=" .. tostring(grew) .. " first_name=" .. tostring(first.name or runtime_font:getName()))
end

--@api: lurek.font.availableSizes
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local sizes = lurek.font.availableSizes()
    local smallest = sizes[1]
    local largest = sizes[#sizes]
    local requested = 14
    local fallback = largest and math.min(requested, largest) or requested
    font_log("built-in menu sizes count=" .. tostring(#sizes) .. " smallest=" .. tostring(smallest) .. " largest=" .. tostring(largest) .. " fallback_for_14=" .. tostring(fallback))
end

--@api: lurek.font.measure
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.getDefault()
    local title = ui_title()
    local width, height = lurek.font.measure(font, title, 1.0)
    local scale = 1.5
    local scaled_width = select(1, lurek.font.measure(font, title, scale))
    font_log("panel title measurement text=" .. title .. " width=" .. tostring(width) .. " height=" .. tostring(height) .. " scaled_width=" .. tostring(scaled_width))
end

--@api: lurek.font.measureLine
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.getDefault()
    local status_line = "Supply 120  Morale 78%"
    local width, height = lurek.font.measureLine(font, status_line, 1.0)
    local per_char = width / math.max(#status_line, 1)
    local line_height = lurek.font.lineHeight(font)
    font_log("status bar line text_width=" .. tostring(width) .. " height=" .. tostring(height) .. " avg_char=" .. tostring(per_char) .. " line_height=" .. tostring(line_height))
end

--@api: lurek.font.wrapText
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.getDefault()
    local briefing = ui_briefing()
    local max_width = 120
    local lines = lurek.font.wrapText(font, briefing, max_width, 1.0, "word")
    local first_line = lines[1] or ""
    font_log("briefing wrap width=" .. tostring(max_width) .. " lines=" .. tostring(#lines) .. " first_line=" .. tostring(first_line))
end

--@api: lurek.font.shapeText
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.getDefault()
    local banner = "Victory Forecast"
    local shaped = lurek.font.shapeText(font, banner, 180, 1.0, "center", "word")
    local first = shaped[1] or {}
    local offset = first.xOffset or 0
    local width = first.width or 0
    font_log("dialog banner shaping lines=" .. tostring(#shaped) .. " first_width=" .. tostring(width) .. " center_offset=" .. tostring(offset))
end

--@api: lurek.font.charAdvance
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.getDefault()
    local advance_w = lurek.font.charAdvance(font, "W", 1.0)
    local advance_space = lurek.font.charAdvance(font, " ", 1.0)
    local cursor_after = advance_w + advance_space + advance_w
    local initials = "W W"
    font_log("nameplate cursor advance text=" .. initials .. " first=" .. tostring(advance_w) .. " space=" .. tostring(advance_space) .. " cursor_after=" .. tostring(cursor_after))
end

--@api: lurek.font.lineHeight
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.getDefault()
    local line_height = lurek.font.lineHeight(font)
    local visible_rows = math.floor(160 / math.max(line_height, 1))
    local title_height = select(2, lurek.font.measure(font, ui_title(), 1.0))
    local spacing_budget = visible_rows * line_height
    font_log("quest log spacing line_height=" .. tostring(line_height) .. " rows_in_160px=" .. tostring(visible_rows) .. " title_height=" .. tostring(title_height) .. " budget=" .. tostring(spacing_budget))
end

--@api: LuaFont:getName
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.getDefault()
    local name = font:getName()
    local style = font:getStyle()
    local size = font:getSize()
    local label = name .. " " .. tostring(size)
    font_log("font picker label name=" .. tostring(name) .. " style=" .. tostring(style) .. " size=" .. tostring(size) .. " label=" .. label)
end

--@api: LuaFont:getSize
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.getDefault()
    local size = font:getSize()
    local line_height = font:lineHeight()
    local title_width = select(1, font:measure(ui_title(), 1.0))
    local size_bucket = size >= 14 and "body" or "caption"
    font_log("font size classification size=" .. tostring(size) .. " line_height=" .. tostring(line_height) .. " title_width=" .. tostring(title_width) .. " bucket=" .. size_bucket)
end

--@api: LuaFont:getStyle
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.getDefault()
    local style = font:getStyle()
    local is_bold = font:isBold()
    local emphasis = is_bold and "emphasis" or "regular_copy"
    local name = font:getName()
    font_log("font style decision name=" .. tostring(name) .. " style=" .. tostring(style) .. " bold=" .. tostring(is_bold) .. " usage=" .. emphasis)
end

--@api: LuaFont:isBold
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.getDefault()
    local is_bold = font:isBold()
    local style = font:getStyle()
    local title = is_bold and "Alert Banner" or "Province Ledger"
    local measured = select(1, font:measure(title, 1.0))
    font_log("bold check style=" .. tostring(style) .. " bold=" .. tostring(is_bold) .. " sample_title=" .. title .. " width=" .. tostring(measured))
end

--@api: LuaFont:lineHeight
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.getDefault()
    local method_height = font:lineHeight()
    local function_height = lurek.font.lineHeight(font)
    local rows = math.floor(200 / math.max(method_height, 1))
    local matches = math.abs(method_height - function_height) < 0.001
    font_log("method line height method=" .. tostring(method_height) .. " function=" .. tostring(function_height) .. " rows_in_200px=" .. tostring(rows) .. " matches=" .. tostring(matches))
end

--@api: LuaFont:measure
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.getDefault()
    local text = "Province alert"
    local width, height = font:measure(text, 1.0)
    local scaled_width = select(1, font:measure(text, 2.0))
    local aspect = width > 0 and height / width or 0
    font_log("method measure text=" .. text .. " width=" .. tostring(width) .. " height=" .. tostring(height) .. " scaled_width=" .. tostring(scaled_width) .. " aspect=" .. tostring(aspect))
end

--@api: LuaFont:wrapText
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.getDefault()
    local text = "Use the method form when a panel already owns its font handle."
    local width = 110
    local lines = font:wrapText(text, width, 1.0)
    local last_line = lines[#lines] or ""
    font_log("method wrap width=" .. tostring(width) .. " lines=" .. tostring(#lines) .. " last_line=" .. tostring(last_line))
end

--@api: LuaFont:containsGlyph
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.getDefault()
    local has_a = font:containsGlyph("A")
    local has_question = font:containsGlyph("?")
    local has_control = font:containsGlyph(string.char(1))
    local fallback_needed = not has_a or not has_question
    font_log("glyph coverage A=" .. tostring(has_a) .. " question=" .. tostring(has_question) .. " control=" .. tostring(has_control) .. " fallback_needed=" .. tostring(fallback_needed))
end

--@api: LFont:getName
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.load(sample_font_path(), 18)
    local name = font:getName()
    local size = font:getSize()
    local preview = select(1, font:measure("Council", 1.0))
    local summary = name .. "@" .. tostring(size)
    font_log("loaded handle name=" .. tostring(name) .. " size=" .. tostring(size) .. " preview_width=" .. tostring(preview) .. " summary=" .. summary)
end

--@api: LFont:getSize
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.load(sample_font_path(), 18)
    local size = font:getSize()
    local line_height = font:lineHeight()
    local style = font:getStyle()
    local rows = math.floor(220 / math.max(line_height, 1))
    font_log("loaded handle size=" .. tostring(size) .. " style=" .. tostring(style) .. " line_height=" .. tostring(line_height) .. " rows_in_220px=" .. tostring(rows))
end

--@api: LFont:getStyle
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.load(sample_font_path(), 18)
    local style = font:getStyle()
    local bold = font:isBold()
    local title_width = select(1, font:measure("Operations", 1.0))
    local usage = bold and "headline" or "body"
    font_log("loaded handle style=" .. tostring(style) .. " bold=" .. tostring(bold) .. " title_width=" .. tostring(title_width) .. " usage=" .. usage)
end

--@api: LFont:isBold
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.load(sample_font_path(), 18)
    local bold = font:isBold()
    local style = font:getStyle()
    local emphasis = bold and "warning_banner" or "ledger_body"
    local glyph_ok = font:containsGlyph("W")
    font_log("loaded handle bold=" .. tostring(bold) .. " style=" .. tostring(style) .. " emphasis=" .. emphasis .. " glyph_W=" .. tostring(glyph_ok))
end

--@api: LFont:lineHeight
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.load(sample_font_path(), 18)
    local line_height = font:lineHeight()
    local paragraph = font:wrapText(ui_briefing(), 160, 1.0)
    local paragraph_height = #paragraph * line_height
    local visible_rows = math.floor(240 / math.max(line_height, 1))
    font_log("loaded handle line height=" .. tostring(line_height) .. " paragraph_lines=" .. tostring(#paragraph) .. " paragraph_height=" .. tostring(paragraph_height) .. " rows_in_240px=" .. tostring(visible_rows))
end

--@api: LFont:measure
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.load(sample_font_path(), 18)
    local label = "Treasury Update"
    local width, height = font:measure(label, 1.0)
    local scaled_width = select(1, font:measure(label, 0.75))
    local shorter = scaled_width < width
    font_log("loaded handle measure label=" .. label .. " width=" .. tostring(width) .. " height=" .. tostring(height) .. " scaled_width=" .. tostring(scaled_width) .. " scaled_shorter=" .. tostring(shorter))
end

--@api: LFont:wrapText
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.load(sample_font_path(), 18)
    local width = 150
    local lines = font:wrapText("Reinforcements arrive tomorrow if the northern road stays open.", width, 1.0)
    local first = lines[1] or ""
    local last = lines[#lines] or ""
    font_log("loaded handle wrap width=" .. tostring(width) .. " lines=" .. tostring(#lines) .. " first=" .. tostring(first) .. " last=" .. tostring(last))
end

--@api: LFont:containsGlyph
do
    local function font_log(message)
        lurek.log.info("[font.example] " .. tostring(message))
    end
    local function ui_title()
        return "Province Ledger"
    end
    local function ui_briefing()
        return "Northern provinces need supply wagons before winter roads close."
    end
    local function sample_font_path()
        return "content/examples/assets/fonts/sample_font.ttf"
    end

    local font = lurek.font.load(sample_font_path(), 18)
    local has_r = font:containsGlyph("R")
    local has_dash = font:containsGlyph("-")
    local has_control = font:containsGlyph(string.char(1))
    local name = font:getName()
    font_log("loaded handle glyph scan name=" .. tostring(name) .. " R=" .. tostring(has_r) .. " dash=" .. tostring(has_dash) .. " control=" .. tostring(has_control))
end
