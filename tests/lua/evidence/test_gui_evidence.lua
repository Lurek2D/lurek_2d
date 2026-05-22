-- Evidence tests: gui module
-- Produces PNG artifacts from content/layouts/*.toml via engine UI rendering.

local function layout_output_name(layout_path)
    return layout_path:gsub("^content/layouts/", ""):gsub("[\\/]", "__"):gsub("%.toml$", ".png")
end

local function layout_size(layout_path)
    local parsed = lurek.data.parseToml(lurek.filesystem.read(layout_path))
    if parsed.resolution and #parsed.resolution >= 2 then
        return parsed.resolution[1], parsed.resolution[2]
    end

    local root = parsed.root or {}
    return math.max(1, math.floor(root.w or 1280)), math.max(1, math.floor(root.h or 720))
end

-- @describe evidence: gui
describe("evidence: gui", function()
    before_each(function()
        ensure_evidence_dir("gui")
        lurek.ui.clear()
    end)

    -- @evidence file
    it("renders TOML layouts from content/layouts with engine default UI", function()
        local dir = evidence_output_dir("gui")
        local layout_paths = lurek.filesystem.listRecursive("content/layouts")
        local rendered = 0

        for _, rel_path in ipairs(layout_paths) do
            if rel_path:match("%.toml$") then
                local layout_path = "content/layouts/" .. rel_path
                local width, height = layout_size(layout_path)
                local output_path = dir .. layout_output_name(layout_path)

                lurek.ui.clear()
                lurek.ui.loadLayoutFile(layout_path)
                lurek.ui.renderToImage(width, height, output_path)
                expect_evidence_created(output_path)
                rendered = rendered + 1
            end
        end

        expect_true(rendered > 0, "should render at least one TOML layout from content/layouts")
    end)
end)

test_summary()
