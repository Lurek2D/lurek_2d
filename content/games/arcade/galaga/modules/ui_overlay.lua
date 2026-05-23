local M = {}
M.__index = M

function M.new(cfg)
    return setmetatable({
        cfg = cfg,
        refs = {},
    }, M)
end

local function find_by_id(root, id)
    if type(root) == "table" or type(root) == "userdata" then
        local finder = root["findById"]
        if type(finder) == "function" then
            local ok, node = pcall(function()
                return root:findById(id)
            end)
            if ok and node ~= nil then
                return node
            end
        end
    end

    if lurek.ui then
        local get_root = lurek.ui["getRoot"]
        if type(get_root) == "function" then
            local ui_root = get_root()
            if ui_root ~= nil then
                local finder = ui_root["findById"]
                if type(finder) == "function" then
                    local ok, node = pcall(function()
                        return ui_root:findById(id)
                    end)
                    if ok and node ~= nil then
                        return node
                    end
                end
            end
        end

        local get_by_id = lurek.ui["getElementById"]
        if type(get_by_id) == "function" then
            local node = get_by_id(id)
            if node ~= nil then
                return node
            end
        end
    end

    return nil
end

local function set_visible(node, value)
    if not node then
        return
    end
    local setter = node["setVisible"]
    if type(setter) == "function" then
        setter(node, value)
        return
    end
    node.visible = value
end

local function is_visible(node)
    if not node then
        return false
    end
    local getter = node["isVisible"]
    if type(getter) == "function" then
        local ok, visible = pcall(function()
            return getter(node)
        end)
        if ok then
            return visible == true
        end
    end
    return node.visible == true
end

local function set_text(node, text)
    if not node then
        return
    end
    local setter = node["setText"]
    if type(setter) == "function" then
        setter(node, text)
        return
    end
    node.text = text
end

function M:load(on_primary_action, on_quit_action)
    if lurek.ui and type(lurek.ui.clear) == "function" then
        lurek.ui.clear()
    end

    local ui_root = lurek.ui.loadLayoutFile(self.cfg.UI_LAYOUT_PATH)
    self.refs.title_screen = find_by_id(ui_root, "title_screen")
    self.refs.hud = find_by_id(ui_root, "hud")
    self.refs.game_over_screen = find_by_id(ui_root, "game_over_screen")
    self.refs.score_label = find_by_id(ui_root, "score_label")
    self.refs.hi_score_label = find_by_id(ui_root, "hi_score_label")
    self.refs.lives_label = find_by_id(ui_root, "lives_label")
    self.refs.wave_label = find_by_id(ui_root, "wave_label")
    self.refs.dual_fire = find_by_id(ui_root, "dual_fire")
    self.refs.challenge_msg1 = find_by_id(ui_root, "challenge_msg1")
    self.refs.challenge_msg2 = find_by_id(ui_root, "challenge_msg2")
    self.refs.fps_label = find_by_id(ui_root, "fps_label")
    self.refs.challenge_result = find_by_id(ui_root, "challenge_result")
    self.refs.press_enter = find_by_id(ui_root, "press_enter")
    self.refs.press_restart = find_by_id(ui_root, "press_restart")
    self.refs.press_quit = find_by_id(ui_root, "press_quit")
    self.refs.press_quit_over = find_by_id(ui_root, "press_quit_over")

    if self.refs.press_enter then
        self.refs.press_enter:setOnClick(on_primary_action)
    end
    if self.refs.press_restart then
        self.refs.press_restart:setOnClick(on_primary_action)
    end
    if on_quit_action and self.refs.press_quit then
        self.refs.press_quit:setOnClick(on_quit_action)
    end
    if on_quit_action and self.refs.press_quit_over then
        self.refs.press_quit_over:setOnClick(on_quit_action)
    end
end

function M:sync(s)
    local refs = self.refs
    set_visible(refs.title_screen, (s.current_state == s.STATE.TITLE))
    set_visible(refs.hud, (s.current_state == s.STATE.PLAYING or s.current_state == s.STATE.GAME_OVER))
    set_visible(refs.game_over_screen, (s.current_state == s.STATE.GAME_OVER))

    if refs.fps_label then
        set_text(refs.fps_label, "FPS: " .. tostring(math.floor(lurek.timer.getFPS())))
    end
    if refs.hi_score_label then
        set_text(refs.hi_score_label, "HI: " .. tostring(s.high_score))
    end

    if is_visible(refs.hud) then
        if refs.score_label then
            set_text(refs.score_label, "SCORE: " .. tostring(s.score))
        end
        if refs.lives_label then
            set_text(refs.lives_label, "LIVES: " .. tostring(s.lives))
        end
        if s.is_challenge then
            if refs.wave_label then
                set_text(refs.wave_label, "WAVE " .. tostring(s.wave) .. " (CHALLENGE)")
            end
        else
            if refs.wave_label then
                set_text(refs.wave_label, "WAVE " .. tostring(s.wave))
            end
        end
        set_visible(refs.dual_fire, s.dual_fire)
    end

    if s.current_state == s.STATE.PLAYING then
        if s.is_challenge and s.challenge_msg_timer > 0 then
            local a = s.challenge_msg_alpha
            refs.challenge_msg1.color = { 1, 1, 0, a }
            refs.challenge_msg2.color = { 0.8, 0.8, 0.8, a }
            set_visible(refs.challenge_msg1, true)
            set_visible(refs.challenge_msg2, true)
        else
            set_visible(refs.challenge_msg1, false)
            set_visible(refs.challenge_msg2, false)
        end
        set_visible(refs.challenge_result, false)
    elseif s.current_state == s.STATE.GAME_OVER then
        if s.is_challenge then
            if refs.challenge_result then
                set_text(refs.challenge_result, "CHALLENGE: " .. tostring(s.challenge_kills) .. "/" .. tostring(s.challenge_total))
            end
            set_visible(refs.challenge_result, true)
        else
            set_visible(refs.challenge_result, false)
        end
        set_visible(refs.challenge_msg1, false)
        set_visible(refs.challenge_msg2, false)
    else
        set_visible(refs.challenge_msg1, false)
        set_visible(refs.challenge_msg2, false)
        set_visible(refs.challenge_result, false)
    end
end

return M
