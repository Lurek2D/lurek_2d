function lurek.init()
    local files = lurek.filesystem.listRecursive('content/layouts')
    local rendered = 0
    for _, rel in ipairs(files) do
        if rel:match('%.toml$') then
            local path = 'content/layouts/' .. rel
            local out = path:gsub('%.toml$', '.png')
            local text = lurek.filesystem.read(path)
            local parsed = lurek.binary.parseToml(text)
            local w, h = 1280, 720
            if parsed.resolution and #parsed.resolution >= 2 then
                w = math.max(1, math.floor(parsed.resolution[1]))
                h = math.max(1, math.floor(parsed.resolution[2]))
            elseif parsed.root then
                w = math.max(1, math.floor(parsed.root.w or w))
                h = math.max(1, math.floor(parsed.root.h or h))
            end
            lurek.ui.clear()
            lurek.ui.loadLayoutFile(path)
            lurek.ui.renderToImage(w, h, out)
            rendered = rendered + 1
            print('rendered: ' .. out)
        end
    end
    print('layout png regeneration done, total=' .. tostring(rendered))
    lurek.window.close()
end
