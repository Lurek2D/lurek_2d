local FILES = {
    "household_finance_lab_tab_01_widgets_api.layout.toml",
    "household_finance_lab_tab_02_cashflow.layout.toml",
    "household_finance_lab_tab_03_categories.layout.toml",
    "household_finance_lab_tab_04_members.layout.toml",
    "household_finance_lab_tab_05_payments.layout.toml",
    "household_finance_lab_tab_06_anomalies.layout.toml",
    "household_finance_lab_tab_07_transactions.layout.toml",
    "household_finance_lab_tab_08_logs.layout.toml",
}

local function export_layout(file_name)
    lurek.ui.clear()
    local load_layout_game_file = lurek.ui["loadLayoutGameFile"]
    if not load_layout_game_file then
        error("loadLayoutGameFile unavailable")
    end
    load_layout_game_file("layouts/" .. file_name)
    local out_name = string.gsub(file_name, "%.toml$", ".png")
    local out_path = lurek.filesystem.toAbsolutePath("save/layout_toml_renderer/" .. out_name)
    lurek.ui.renderToImage(out_path, 1200, 800)
end

function lurek.init()
    lurek.ui.setDefaultTheme()
    lurek.filesystem.createDirectory("save/layout_toml_renderer")
    for _, file_name in ipairs(FILES) do
        export_layout(file_name)
    end
    lurek.window.close()
end

function lurek.process(dt)
    lurek.ui.update(dt or 0)
end

function lurek.draw()
    lurek.render.clear(0.08, 0.09, 0.12)
end
