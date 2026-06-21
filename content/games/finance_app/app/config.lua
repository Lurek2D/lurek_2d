local Config = {}

local function value(tbl, key, fallback)
    if tbl and tbl[key] ~= nil then return tbl[key] end
    return fallback
end

local function strings(tbl)
    local out = {}
    for index, item in ipairs(tbl or {}) do
        out[index] = tostring(item)
    end
    return out
end

local function sql_files(parsed)
    local out = {}
    local files = (parsed.sql and parsed.sql.files) or {}
    local tables = (parsed.sql and parsed.sql.tables) or {}
    for index, file_name in ipairs(files) do
        out[#out + 1] = {
            file = tostring(file_name),
            table = tostring(tables[index] or file_name),
        }
    end
    return out
end

function Config.load(path)
    local parsed = lurek.binary.parseToml(lurek.filesystem.read(path or "app/config.toml"))
    local paths = parsed.paths or {}
    local years = parsed.years or {}
    local window = parsed.window or {}

    local C = {
        RAW = parsed,
        WIDTH = tonumber(value(window, "width", 1200)) or 1200,
        HEIGHT = tonumber(value(window, "height", 800)) or 800,
        FONT_SIZE = tonumber(value(window, "font_size", 10)) or 10,
        TITLE_FONT_SIZE = tonumber(value(window, "title_font_size", 12)) or 12,
        SAVE_DIR = tostring(value(paths, "save_dir", "save/household_finance_lab")),
        CACHE_DIR = tostring(value(paths, "cache_dir", "save/household_finance_lab/cache")),
        CSV_PATH = tostring(value(paths, "csv_path", "save/household_finance_lab/transactions_2021_2025.csv")),
        LOG_PATH = tostring(value(paths, "log_path", "save/household_finance_lab/app.log")),
        SCREENSHOT_PATH = tostring(value(paths, "screenshot_path", "save/household_finance_lab/dashboard.png")),
        SCREEN_PATH = tostring(value(paths, "screen_path", "save/household_finance_lab/screen.png")),
        TEST_REPORT_PATH = tostring(value(paths, "test_report_path", "save/household_finance_lab/test_report.json")),
        CACHE_MANIFEST = tostring(value(paths, "cache_manifest", "save/household_finance_lab/cache/manifest.json")),
        DATABASE_JSON_PATH = tostring(value(paths, "database_json_path", "save/household_finance_lab/cache/database.json")),
        SAVE_SLOT = tostring(value(paths, "save_slot", "household_finance_lab_ui")),
        CACHE_VERSION = tostring(value(paths, "cache_version", "household_finance_lab_cache_v3")),
        YEAR_MIN = tonumber(value(years, "min", 2021)) or 2021,
        YEAR_MAX = tonumber(value(years, "max", 2025)) or 2025,
        TABS = strings(parsed.tabs and parsed.tabs.names),
        MEMBERS = strings(parsed.members and parsed.members.names),
        CATEGORIES = strings(parsed.categories and parsed.categories.names),
        COLUMNS = strings(parsed.columns and parsed.columns.names),
        CATEGORY_ALIASES = parsed.category_aliases or {},
        COLORS = parsed.colors or {},
        CATEGORY_COLORS = parsed.category_colors or {},
        SQL_FILES = sql_files(parsed),
        AGG = parsed.agg or {},
        PROFILE = parsed.data_profile or {},
    }

    return C
end

return Config
