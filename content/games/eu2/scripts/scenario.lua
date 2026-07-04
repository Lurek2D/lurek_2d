local M = {}

local function color(r, g, b)
    return { r / 255, g / 255, b / 255, 1.0 }
end

local function lower(v)
    return tostring(v or ""):lower()
end

local function has_any(text, needles)
    text = lower(text)
    for _, needle in ipairs(needles) do
        if text:find(needle, 1, true) then
            return true
        end
    end
    return false
end

local function terrain_is_water(terrain)
    terrain = lower(terrain)
    return terrain == "sea" or terrain == "river" or terrain == "ocean"
end

local countries = {
    POL = { tag = "POL", name = "Kingdom of Poland", ruler = "King Wladyslaw II Jagiello", ai = false, color = color(191, 106, 116), treasury = 120, manpower = 22000, stability = 1 },
    LIT = { tag = "LIT", name = "Grand Duchy of Lithuania", ruler = "Grand Duke Vytautas", ai = true, color = color(173, 134, 165), treasury = 90, manpower = 26000, stability = 0 },
    TEU = { tag = "TEU", name = "Teutonic Order", ruler = "Grand Master Heinrich von Plauen", ai = true, color = color(208, 201, 186), treasury = 80, manpower = 12000, stability = 1 },
    MOS = { tag = "MOS", name = "Grand Duchy of Moscow", ruler = "Grand Prince Vasili I", ai = true, color = color(180, 107, 101), treasury = 100, manpower = 30000, stability = 0 },
    OTT = { tag = "OTT", name = "Ottoman Empire", ruler = "Sultan Mehmed I", ai = true, color = color(136, 179, 130), treasury = 160, manpower = 38000, stability = 1 },
    FRA = { tag = "FRA", name = "Kingdom of France", ruler = "King Charles VI", ai = true, color = color(113, 132, 191), treasury = 170, manpower = 36000, stability = 1 },
    ENG = { tag = "ENG", name = "Kingdom of England", ruler = "King Henry IV", ai = true, color = color(214, 154, 96), treasury = 150, manpower = 26000, stability = 0 },
    CAS = { tag = "CAS", name = "Crown of Castile", ruler = "King Henry III", ai = true, color = color(210, 186, 98), treasury = 145, manpower = 28000, stability = 1 },
    NEU = { tag = "NEU", name = "Neutral Lands", ruler = "", ai = true, color = color(194, 190, 177), treasury = 0, manpower = 0, stability = 0 },
    SEA = { tag = "SEA", name = "Sea", ruler = "", ai = true, color = color(143, 184, 207), treasury = 0, manpower = 0, stability = 0 },
}

local rules = {
    { tag = "POL", needles = { "poland", "mazovia", "silesia", "krak", "wielkopolska", "malopolska", "podolia", "galicia" } },
    { tag = "LIT", needles = { "lithuania", "belarus", "ruthenia", "smolensk", "minsk", "volhynia", "ukraine" } },
    { tag = "TEU", needles = { "prussia", "livonia", "latvia", "estonia", "kurland", "baltic" } },
    { tag = "MOS", needles = { "muscovy", "moscow", "russia", "novgorod", "tver", "vladimir", "ryazan" } },
    { tag = "OTT", needles = { "ottoman", "anatolia", "turkey", "thrace", "rumelia", "balkans", "greece", "bulgaria" } },
    { tag = "FRA", needles = { "france", "paris", "normandy", "bourgogne", "loire", "provence", "guyenne", "picardie" } },
    { tag = "ENG", needles = { "england", "britain", "wales", "scotland", "ireland", "london", "york", "kent" } },
    { tag = "CAS", needles = { "castile", "spain", "iberia", "andalusia", "aragon", "leon", "toledo", "valencia" } },
}

local function assign_owner(attrs)
    attrs = attrs or {}
    local terrain = attrs.terrain
    if terrain_is_water(terrain) then
        return "SEA"
    end
    local blob = table.concat({
        lower(attrs.name),
        lower(attrs.continent),
        lower(attrs.region),
        lower(attrs.area),
        lower(attrs.culture),
        lower(attrs.religion),
    }, " ")
    if blob:find("terra", 1, true) and blob:find("incognita", 1, true) then
        return "NEU"
    end
    for _, rule in ipairs(rules) do
        if has_any(blob, rule.needles) then
            return rule.tag
        end
    end
    if has_any(blob, { "europe" }) then
        return "NEU"
    end
    return "NEU"
end

function M.build(reg)
    return {
        start_date = { year = 1419, month = 1, day = 1 },
        player_tag = "POL",
        countries = countries,
        ownership_rules = rules,
        assign_owner = assign_owner,
        starting_armies = {
            { tag = "POL", name = "Crown Army", size = 14000, province_keywords = { "krak", "mazovia", "poland" } },
            { tag = "LIT", name = "Ruthenian Host", size = 16000, province_keywords = { "lithuania", "minsk", "smolensk" } },
            { tag = "TEU", name = "Order Banner", size = 9000, province_keywords = { "prussia", "livonia" } },
            { tag = "MOS", name = "Moscow Host", size = 18000, province_keywords = { "moscow", "muscovy", "russia" } },
            { tag = "OTT", name = "Janissary Corps", size = 22000, province_keywords = { "thrace", "anatolia", "ottoman" } },
            { tag = "FRA", name = "Royal Army", size = 18000, province_keywords = { "paris", "france" } },
            { tag = "ENG", name = "Expeditionary Army", size = 13000, province_keywords = { "london", "england", "kent" } },
            { tag = "CAS", name = "Castilian Army", size = 15000, province_keywords = { "toledo", "castile", "spain" } },
        },
    }
end

return M
