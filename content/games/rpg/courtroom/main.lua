-- ============================================================================
-- Courtroom Drama — Ace Attorney-style courtroom debate game
-- Category: rpg
-- Engine:   Lurek2D
-- Controls: space(advance) o(objection) e(evidence) q(question)
--           1/2/3(choices) escape(quit)
-- States:   TITLE → CASE_INTRO → TESTIMONY → QUESTION → OBJECTION → VERDICT → GAME_OVER
-- ============================================================================

-- Action input mapping
local actions = {
    advance  = "space",
    objection = "o",
    evidence = "e",
    question = "q",
    choice1  = "1",
    choice2  = "2",
    choice3  = "3",
    quit     = "escape",
}

-- Game state
local state = "CASE_INTRO"
local current_case = 1
local credibility = 100
local jury_meter = 0
local jury_display = 0
local cred_display = 100
local show_evidence = false
local typewriter_text = ""
local typewriter_target = ""
local typewriter_timer = 0
local typewriter_speed = 1 / 25
local testimony_line = 1
local flash_alpha = 0
local flash_color = {1, 0.8, 0}
local objection_scale = 0
local objection_alpha = 0
local verdict_confetti = {}
local gavel_sparks = {}
local dialog_queue = {}
local dialog_index = 1
local question_mode = false
local objection_mode = false
local objection_result = ""
local objection_result_timer = 0
local case_won = false
local game_result = ""

-- Cases data
local cases = {
    {
        name = "The Missing Diamond",
        intro = {
            "Case 1: The Missing Diamond",
            "A priceless diamond vanished from the museum last night.",
            "The security guard claims he was at his post all evening.",
            "But something doesn't add up..."
        },
        witness = "Security Guard",
        testimony = {
            "I was stationed at the east wing entrance all night.",
            "I never left my post, not even for a minute.",
            "The security cameras were working fine the whole time.",
            "Nobody suspicious entered the building after 8 PM.",
            "I checked the diamond case at midnight — it was still there.",
        },
        contradiction_line = 3,
        correct_evidence = 1,
        evidence = {
            {name = "Security Footage", desc = "Camera logs show east wing camera offline 10:30-11:15 PM"},
            {name = "Visitor Log", desc = "Sign-in sheet with entries up to 9 PM"},
            {name = "Floor Plan", desc = "Museum layout showing all entrances"},
        },
        questions = {
            {text = "When exactly did you start your shift?", response = "I started at 6 PM sharp, as always."},
            {text = "Did anyone relieve you during the night?", response = "No, I was alone the entire shift."},
            {text = "Were there any power outages?", response = "N-no... everything was normal. I think."},
        },
        win_text = "The security footage proves the cameras WERE offline! The guard is lying!",
    },
    {
        name = "The Poisoned Cake",
        intro = {
            "Case 2: The Poisoned Cake",
            "A birthday cake at the Grand Hotel made three guests ill.",
            "The pastry chef insists every ingredient was fresh.",
            "Time to find the rotten truth..."
        },
        witness = "Pastry Chef",
        testimony = {
            "I prepared the cake myself using only the finest ingredients.",
            "I bought all supplies fresh from the market that morning.",
            "The recipe called for imported vanilla extract, which I used.",
            "I never left the kitchen while the cake was being prepared.",
            "The cake was served immediately after decoration.",
        },
        contradiction_line = 2,
        correct_evidence = 2,
        evidence = {
            {name = "Medical Report", desc = "Traces of expired almond extract found in patients"},
            {name = "Store Receipt", desc = "Receipt dated 3 days before the party, includes almond extract"},
            {name = "Kitchen Photo", desc = "Photo showing the kitchen workspace"},
        },
        questions = {
            {text = "What brand of vanilla did you use?", response = "It was... a common brand. I don't remember exactly."},
            {text = "Did you taste-test the cake?", response = "Of course! It tasted perfect to me."},
            {text = "Who else had access to the kitchen?", response = "Only my assistant, but she left at noon."},
        },
        win_text = "The receipt is dated THREE DAYS before the party! The ingredients were NOT fresh!",
    },
    {
        name = "Corporate Espionage",
        intro = {
            "Case 3: Corporate Espionage",
            "Classified blueprints were leaked to a rival company.",
            "The CEO claims he was in a board meeting during the breach.",
            "But the digital trail tells a different story..."
        },
        witness = "CEO",
        testimony = {
            "I was in the boardroom from 2 PM to 5 PM that day.",
            "The meeting was about quarterly projections, nothing unusual.",
            "I never accessed the classified server that afternoon.",
            "My assistant can confirm I was in the meeting the entire time.",
            "I only learned about the breach the following morning.",
        },
        contradiction_line = 3,
        correct_evidence = 3,
        evidence = {
            {name = "Meeting Minutes", desc = "Board meeting notes, signed by 4 attendees"},
            {name = "Badge Scan Log", desc = "CEO's keycard used at server room at 3:47 PM"},
            {name = "Email Logs", desc = "Email sent FROM CEO's account at 3:52 PM to rival company with attachment"},
        },
        questions = {
            {text = "Who else attended the meeting?", response = "The CFO, marketing director, and two board members."},
            {text = "Do you share your email credentials?", response = "Absolutely not! That would be a security violation."},
            {text = "When did you last visit the server room?", response = "Weeks ago! I rarely go there personally."},
        },
        win_text = "The email logs show a message sent FROM YOUR ACCOUNT at 3:52 PM — during the meeting you claim you never left!",
    },
}

-- Spawn verdict confetti
local function spawn_confetti()
    for i = 1, 60 do
        table.insert(verdict_confetti, {
            x = math.random(50, 750),
            y = -math.random(10, 200),
            vy = math.random(80, 200),
            vx = math.random(-40, 40),
            size = math.random(3, 7),
            r = math.random() * 0.5 + 0.5,
            g = math.random() * 0.5 + 0.5,
            b = math.random() * 0.3,
        })
    end
end

-- Spawn gavel sparks
local function spawn_gavel_sparks()
    for i = 1, 20 do
        local angle = math.random() * math.pi * 2
        local speed = math.random(60, 180)
        table.insert(gavel_sparks, {
            x = 400, y = 100,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed,
            life = 0.5 + math.random() * 0.3,
            max_life = 0.8,
            size = math.random(2, 5),
        })
    end
end

-- Set typewriter target
local function set_typewriter(text)
    typewriter_target = text
    typewriter_text = ""
    typewriter_timer = 0
end

-- Start a case
local function start_case(n)
    current_case = n
    state = "CASE_INTRO"
    dialog_queue = cases[n].intro
    dialog_index = 1
    testimony_line = 1
    show_evidence = false
    question_mode = false
    objection_mode = false
    objection_result = ""
    set_typewriter(dialog_queue[1])
end

-- Start testimony phase
local function start_testimony()
    state = "TESTIMONY"
    testimony_line = 1
    set_typewriter(cases[current_case].testimony[1])
end

-- Process objection result
local function process_objection(evidence_index)
    local c = cases[current_case]
    objection_mode = false
    if evidence_index == c.correct_evidence and testimony_line == c.contradiction_line then
        objection_result = "CORRECT"
        jury_meter = math.min(100, jury_meter + 25)
        flash_color = {1, 0.9, 0.2}
        flash_alpha = 1
        objection_scale = 3
        objection_alpha = 1
        set_typewriter(c.win_text)
        objection_result_timer = 3
        spawn_gavel_sparks()
    else
        objection_result = "WRONG"
        credibility = math.max(0, credibility - 20)
        flash_color = {1, 0.2, 0.1}
        flash_alpha = 0.8
        objection_scale = 2
        objection_alpha = 1
        if credibility <= 0 then
            set_typewriter("Your credibility is shattered! Case dismissed!")
            objection_result_timer = 3
        else
            set_typewriter("OBJECTION OVERRULED! That evidence is irrelevant! (-20 credibility)")
            objection_result_timer = 2.5
        end
    end
end

-- Universal render helpers (handles all legacy and current call signatures)
local _gfx = lurek.render
local function _sc(c)
    if type(c) == "table" then
        local col = c.color or c
        if type(col) == "table" then
            _gfx.setColor(col[1] or 1, col[2] or 1, col[3] or 1, col[4] or 1)
        end
    end
end
local function rect(a, b, c, d, e, f, g, h)
    if type(a) == "string" then
        _gfx.rectangle(a, b, c, d, e)
    elseif type(e) == "table" then
        _sc(e); _gfx.rectangle(e.mode or "fill", a, b, c, d)
    elseif type(e) == "number" then
        _gfx.setColor(e or 1, f or 1, g or 1, h or 1); _gfx.rectangle("fill", a, b, c, d)
    else
        _gfx.rectangle("fill", a, b, c, d)
    end
end
local function circ(a, b, c, d, e, f, g, h)
    if type(a) == "string" then
        if type(e) == "table" then _sc(e)
        elseif type(e) == "number" then _gfx.setColor(e or 1, f or 1, g or 1, h or 1) end
        _gfx.circle(a, b, c, d)
    elseif type(d) == "table" then
        _sc(d); _gfx.circle("fill", a, b, c)
    elseif type(d) == "number" then
        _gfx.setColor(d or 1, e or 1, f or 1, g or 1); _gfx.circle("fill", a, b, c)
    else
        _gfx.circle("fill", a, b, c)
    end
end
local function text_(a, b, c, d, e, f, g, h)
    if type(d) == "table" then
        _sc(d)
    elseif type(d) == "number" and type(e) == "number" then
        _gfx.setColor(e or 1, f or 1, g or 1, h or 1)
    end
    _gfx.print(tostring(a), b, c)
end
local function ln(x1, y1, x2, y2, c)
    if type(c) == "table" then _sc(c) end
    _gfx.line(x1, y1, x2, y2)
end

function lurek.init()
    lurek.window.setTitle("Courtroom Drama — Lurek2D")
    lurek.render.setBackgroundColor(0.15, 0.1, 0.08)
    
    lurek.ui.loadLayoutFile("content/games/rpg/courtroom/ui.toml")
    local ui_root = lurek.ui.getRoot()
    app_ui = {}
    app_ui.title_screen = ui_root:findById("title_screen")
    app_ui.title_start = ui_root:findById("title_start")
    
    app_ui.game_over_screen = ui_root:findById("game_over_screen")
    app_ui.go_title = ui_root:findById("go_title")
    app_ui.go_desc = ui_root:findById("go_desc")
    app_ui.go_hint = ui_root:findById("go_hint")
    
    app_ui.hud = ui_root:findById("hud")
    app_ui.case_info_text = ui_root:findById("case_info_text")
    app_ui.jury_fill = ui_root:findById("jury_fill")
    app_ui.jury_text = ui_root:findById("jury_text")
    app_ui.cred_fill = ui_root:findById("cred_fill")
    app_ui.cred_text = ui_root:findById("cred_text")
    app_ui.stmt_text = ui_root:findById("stmt_text")
    
    app_ui.speaker_text = ui_root:findById("speaker_text")
    app_ui.typewriter_text = ui_root:findById("typewriter_text")
    app_ui.advance_prompt = ui_root:findById("advance_prompt")
    app_ui.controls_hint = ui_root:findById("controls_hint")
    
    app_ui.question_panel = ui_root:findById("question_panel")
    app_ui.qp_opts = {}
    for i=1, 3 do app_ui.qp_opts[i] = ui_root:findById("qp_opt_" .. i) end
    
    app_ui.objection_panel = ui_root:findById("objection_panel")
    app_ui.op_ev_n = {}
    app_ui.op_ev_d = {}
    for i=1, 3 do 
        app_ui.op_ev_n[i] = ui_root:findById("op_ev_n_" .. i)
        app_ui.op_ev_d[i] = ui_root:findById("op_ev_d_" .. i)
    end
    
    app_ui.evidence_panel = ui_root:findById("evidence_panel")
    app_ui.ep_ev_n = {}
    app_ui.ep_ev_d = {}
    for i=1, 3 do 
        app_ui.ep_ev_n[i] = ui_root:findById("ep_ev_n_" .. i)
        app_ui.ep_ev_d[i] = ui_root:findById("ep_ev_d_" .. i)
    end
    
    app_ui.verdict_text = ui_root:findById("verdict_text")
end

local function _ready_setup() end

function lurek.process(dt)
    if lurek.automation then lurek.automation.update(dt) end
    local fps = lurek.timer.getFPS()
    lurek.window.setTitle(string.format("Courtroom Drama — Lurek2D | FPS: %d", fps))

    -- Quit
    if lurek.input.keyboard.isDown(actions.quit) then
        lurek.event.push("quit")
        return
    end

    -- Typewriter update
    if #typewriter_text < #typewriter_target then
        typewriter_timer = typewriter_timer + dt
        while typewriter_timer >= typewriter_speed and #typewriter_text < #typewriter_target do
            typewriter_timer = typewriter_timer - typewriter_speed
            typewriter_text = typewriter_target:sub(1, #typewriter_text + 1)
        end
    end

    -- Flash decay
    if flash_alpha > 0 then
        flash_alpha = math.max(0, flash_alpha - dt * 3)
    end

    -- Objection text tween
    if objection_alpha > 0 then
        objection_scale = math.max(1, objection_scale - dt * 6)
        if objection_scale <= 1 then
            objection_alpha = math.max(0, objection_alpha - dt * 1.5)
        end
    end

    -- Jury meter smooth tween
    if jury_display < jury_meter then
        jury_display = math.min(jury_meter, jury_display + dt * 60)
    elseif jury_display > jury_meter then
        jury_display = math.max(jury_meter, jury_display - dt * 60)
    end

    -- Credibility smooth tween
    if cred_display > credibility then
        cred_display = math.max(credibility, cred_display - dt * 40)
    elseif cred_display < credibility then
        cred_display = math.min(credibility, cred_display + dt * 40)
    end

    -- Confetti update
    for i = #verdict_confetti, 1, -1 do
        local p = verdict_confetti[i]
        p.y = p.y + p.vy * dt
        p.x = p.x + p.vx * dt
        if p.y > 650 then table.remove(verdict_confetti, i) end
    end

    -- Gavel sparks update
    for i = #gavel_sparks, 1, -1 do
        local s = gavel_sparks[i]
        s.x = s.x + s.vx * dt
        s.y = s.y + s.vy * dt
        s.vy = s.vy + 300 * dt
        s.life = s.life - dt
        if s.life <= 0 then table.remove(gavel_sparks, i) end
    end

    -- Objection result timer
    if objection_result_timer > 0 then
        objection_result_timer = objection_result_timer - dt
        if objection_result_timer <= 0 then
            if credibility <= 0 then
                state = "VERDICT"
                case_won = false
                set_typewriter("GUILTY! The defense has lost all credibility.")
                spawn_gavel_sparks()
            elseif objection_result == "CORRECT" then
                if jury_meter >= 100 then
                    state = "VERDICT"
                    case_won = true
                    set_typewriter("NOT GUILTY! The defense has proven the witness unreliable!")
                    spawn_confetti()
                    spawn_gavel_sparks()
                else
                    set_typewriter(cases[current_case].testimony[testimony_line])
                end
            else
                set_typewriter(cases[current_case].testimony[testimony_line])
            end
            objection_result = ""
        end
        return
    end

    -- State machine input
    if state == "TITLE" then
        if lurek.input.keyboard.isDown(actions.advance) then
            credibility = 100
            cred_display = 100
            jury_meter = 0
            jury_display = 0
            current_case = 1
            start_case(1)
        end

    elseif state == "CASE_INTRO" then
        if lurek.input.keyboard.isDown(actions.advance) and #typewriter_text >= #typewriter_target then
            dialog_index = dialog_index + 1
            if dialog_index > #dialog_queue then
                start_testimony()
            else
                set_typewriter(dialog_queue[dialog_index])
            end
        end

    elseif state == "TESTIMONY" then
        if objection_mode then
            -- Selecting evidence for objection
            for idx = 1, 3 do
                local key = actions["choice" .. idx]
                if lurek.input.keyboard.isDown(key) then
                    process_objection(idx)
                end
            end
            if lurek.input.keyboard.isDown(actions.evidence) then
                objection_mode = false
                set_typewriter(cases[current_case].testimony[testimony_line])
            end
        elseif question_mode then
            -- Choosing question
            for idx = 1, 3 do
                local key = actions["choice" .. idx]
                if lurek.input.keyboard.isDown(key) then
                    question_mode = false
                    local q = cases[current_case].questions[idx]
                    if q then
                        set_typewriter(q.response)
                    end
                end
            end
            if lurek.input.keyboard.isDown(actions.question) then
                question_mode = false
                set_typewriter(cases[current_case].testimony[testimony_line])
            end
        else
            -- Normal testimony navigation
            if lurek.input.keyboard.isDown(actions.advance) and #typewriter_text >= #typewriter_target then
                testimony_line = testimony_line + 1
                local c = cases[current_case]
                if testimony_line > #c.testimony then
                    testimony_line = 1
                end
                set_typewriter(c.testimony[testimony_line])
            end

            if lurek.input.keyboard.isDown(actions.objection) then
                objection_mode = true
                flash_color = {1, 0.6, 0}
                flash_alpha = 0.6
                objection_scale = 3
                objection_alpha = 1
                set_typewriter("Select evidence (1/2/3) or press E to cancel:")
            end

            if lurek.input.keyboard.isDown(actions.question) then
                question_mode = true
                set_typewriter("Choose a question (1/2/3) or press Q to cancel:")
            end

            if lurek.input.keyboard.isDown(actions.evidence) then
                show_evidence = not show_evidence
            end
        end

    elseif state == "VERDICT" then
        if lurek.input.keyboard.isDown(actions.advance) and #typewriter_text >= #typewriter_target then
            if case_won then
                if current_case < 3 then
                    start_case(current_case + 1)
                else
                    state = "GAME_OVER"
                    game_result = "WIN"
                    set_typewriter("All cases won! You are the greatest attorney!")
                    spawn_confetti()
                end
            else
                state = "GAME_OVER"
                game_result = "LOSE"
                set_typewriter("Justice was not served today... Try again?")
            end
        end

    elseif state == "GAME_OVER" then
        -- state transitions handled by UI click callbacks
    end
    
    -- UI Sync
    if app_ui then
        app_ui.title_screen.visible = (state == "TITLE")
        if app_ui.title_screen.visible then
            app_ui.title_start.color = {0.6, 0.5, 0.3, 0.6 + math.sin(lurek.timer.getTime() * 3) * 0.4}
        end
        
        app_ui.game_over_screen.visible = (state == "GAME_OVER")
        if app_ui.game_over_screen.visible then
            if game_result == "WIN" then
                app_ui.go_title.text = "CASE CLOSED!"
                app_ui.go_title.color = {1, 0.85, 0.2, 1}
                app_ui.go_title.x = 270
            else
                app_ui.go_title.text = "CASE LOST"
                app_ui.go_title.color = {0.8, 0.2, 0.15, 1}
                app_ui.go_title.x = 290
            end
            app_ui.go_desc.text = typewriter_text
            app_ui.go_hint.color = {0.6, 0.5, 0.3, 0.6 + math.sin(lurek.timer.getTime() * 3) * 0.4}
        end
        
        app_ui.hud.visible = (state ~= "TITLE" and state ~= "GAME_OVER")
        if app_ui.hud.visible then
            app_ui.case_info_text.text = "Case " .. current_case .. ": " .. cases[current_case].name
            
            local jury_w = 180
            local fill_w = (jury_display / 100) * jury_w
            app_ui.jury_fill.width = fill_w
            local jr = 0.2 + 0.6 * (1 - jury_display / 100)
            local jg = 0.3 + 0.7 * (jury_display / 100)
            app_ui.jury_fill.background = {jr, jg, 0.2, 1}
            app_ui.jury_text.text = "Jury: " .. math.floor(jury_display) .. "%"
            
            local cr_w = 95
            local cr_fill = (cred_display / 100) * cr_w
            app_ui.cred_fill.width = cr_fill
            local cr_r = 0.2 + 0.8 * (1 - cred_display / 100)
            local cr_g = 0.8 * (cred_display / 100)
            app_ui.cred_fill.background = {cr_r, cr_g, 0.15, 1}
            app_ui.cred_text.text = "Cred:" .. math.floor(cred_display)
            
            app_ui.stmt_text.visible = (state == "TESTIMONY")
            if app_ui.stmt_text.visible then
                app_ui.stmt_text.text = "Statement " .. testimony_line .. "/" .. #cases[current_case].testimony
            end
            
            if state == "TESTIMONY" and not question_mode and not objection_mode and objection_result == "" then
                app_ui.speaker_text.text = cases[current_case].witness .. ":"
                app_ui.speaker_text.color = {1, 0.85, 0.3, 1}
            elseif state == "CASE_INTRO" then
                app_ui.speaker_text.text = "Judge:"
                app_ui.speaker_text.color = {0.8, 0.6, 0.2, 1}
            else
                app_ui.speaker_text.text = ""
            end
            
            app_ui.typewriter_text.text = typewriter_text
            
            app_ui.advance_prompt.visible = (#typewriter_text >= #typewriter_target and not question_mode and not objection_mode and objection_result == "")
            if app_ui.advance_prompt.visible then
                app_ui.advance_prompt.color = {0.5, 0.4, 0.3, 0.5 + math.sin(lurek.timer.getTime() * 4) * 0.3}
            end
            
            app_ui.controls_hint.visible = (state == "TESTIMONY" and not question_mode and not objection_mode and objection_result == "")
            
            app_ui.question_panel.visible = question_mode
            if question_mode then
                local questions = cases[current_case].questions
                for i=1, 3 do
                    if questions[i] then
                        app_ui.qp_opts[i].text = i .. ". " .. questions[i].text
                        app_ui.qp_opts[i].visible = true
                    else
                        app_ui.qp_opts[i].visible = false
                    end
                end
            end
            
            app_ui.objection_panel.visible = objection_mode
            if objection_mode then
                local ev = cases[current_case].evidence
                for i=1, 3 do
                    if ev[i] then
                        app_ui.op_ev_n[i].text = i .. ". " .. ev[i].name
                        app_ui.op_ev_d[i].text = "   " .. ev[i].desc
                        app_ui.op_ev_n[i].visible = true
                        app_ui.op_ev_d[i].visible = true
                    else
                        app_ui.op_ev_n[i].visible = false
                        app_ui.op_ev_d[i].visible = false
                    end
                end
            end
            
            app_ui.evidence_panel.visible = (show_evidence and not objection_mode)
            if app_ui.evidence_panel.visible then
                local ev = cases[current_case].evidence
                for i=1, 3 do
                    if ev[i] then
                        app_ui.ep_ev_n[i].text = i .. ". " .. ev[i].name
                        app_ui.ep_ev_d[i].text = ev[i].desc
                        app_ui.ep_ev_n[i].visible = true
                        app_ui.ep_ev_d[i].visible = true
                    else
                        app_ui.ep_ev_n[i].visible = false
                        app_ui.ep_ev_d[i].visible = false
                    end
                end
            end
            
            app_ui.verdict_text.visible = (state == "VERDICT")
            if app_ui.verdict_text.visible then
                if case_won then
                    app_ui.verdict_text.text = "NOT GUILTY"
                    app_ui.verdict_text.color = {0.2, 0.8, 0.3, 1}
                    app_ui.verdict_text.x = 270
                else
                    app_ui.verdict_text.text = "GUILTY"
                    app_ui.verdict_text.color = {0.9, 0.2, 0.15, 1}
                    app_ui.verdict_text.x = 310
                end
            end
        end
    end
end

-- Draw courtroom scene elements
function lurek.draw()
    -- Courtroom background walls
    lurek.render.setColor(0.25, 0.18, 0.12, 1)
    rect("fill", 0, 0, 800, 600)

    -- Wood paneling
    lurek.render.setColor(0.35, 0.22, 0.12, 1)
    rect("fill", 0, 400, 800, 200)

    -- Judge's bench (top center)
    lurek.render.setColor(0.4, 0.25, 0.1, 1)
    rect("fill", 280, 40, 240, 80)
    lurek.render.setColor(0.5, 0.32, 0.15, 1)
    rect("fill", 290, 45, 220, 70)
    -- Judge silhouette
    lurek.render.setColor(0.15, 0.1, 0.08, 1)
    circ("fill", 400, 55, 18)
    rect("fill", 385, 73, 30, 35)
    -- Gavel
    lurek.render.setColor(0.55, 0.35, 0.15, 1)
    rect("fill", 440, 75, 25, 8)
    rect("fill", 450, 65, 8, 20)

    -- Witness stand (right)
    lurek.render.setColor(0.38, 0.24, 0.12, 1)
    rect("fill", 580, 150, 160, 120)
    lurek.render.setColor(0.45, 0.3, 0.15, 1)
    rect("fill", 590, 155, 140, 50)
    -- Witness silhouette
    if state == "TESTIMONY" or state == "QUESTION" then
        lurek.render.setColor(0.2, 0.15, 0.1, 1)
        circ("fill", 660, 155, 20)
        rect("fill", 645, 175, 30, 40)
    end

    -- Defense desk (left)
    lurek.render.setColor(0.38, 0.24, 0.12, 1)
    rect("fill", 40, 280, 200, 80)
    lurek.render.setColor(0.45, 0.3, 0.15, 1)
    rect("fill", 50, 285, 180, 35)
    -- Defense attorney silhouette
    lurek.render.setColor(0.1, 0.15, 0.3, 1)
    circ("fill", 140, 275, 18)
    rect("fill", 125, 293, 30, 40)

    -- Prosecution desk (right lower)
    lurek.render.setColor(0.38, 0.24, 0.12, 1)
    rect("fill", 540, 280, 200, 80)
    lurek.render.setColor(0.45, 0.3, 0.15, 1)
    rect("fill", 550, 285, 180, 35)
    -- Prosecutor silhouette
    lurek.render.setColor(0.3, 0.1, 0.1, 1)
    circ("fill", 640, 275, 18)
    rect("fill", 625, 293, 30, 40)

    -- Gallery railing
    lurek.render.setColor(0.5, 0.33, 0.18, 1)
    rect("fill", 0, 395, 800, 8)

    -- Gallery audience silhouettes
    lurek.render.setColor(0.18, 0.13, 0.1, 0.7)
    for i = 0, 9 do
        local gx = 40 + i * 75
        circ("fill", gx, 430, 12)
        rect("fill", gx - 10, 442, 20, 25)
    end

    -- Gavel sparks (particles)
    for _, s in ipairs(gavel_sparks) do
        local a = s.life / s.max_life
        lurek.render.setColor(1, 0.8, 0.2, a)
        rect("fill", s.x - s.size/2, s.y - s.size/2, s.size, s.size)
    end

    -- Flash effect overlay
    if flash_alpha > 0 then
        lurek.render.setColor(flash_color[1], flash_color[2], flash_color[3], flash_alpha * 0.4)
        rect("fill", 0, 0, 800, 600)
    end
end

-- Draw UI elements
function lurek.draw_ui()
    -- Emptied: UI layout TOML and lurek.process handles rendering now.
    -- We still need to draw the particles and dynamic text that are drawn over UI in draw_ui.
    if state == "GAME_OVER" then
        -- Confetti (particles)
        for _, c in ipairs(verdict_confetti) do
            lurek.render.setColor(c.r, c.g, c.b, 0.9)
            rect("fill", c.x, c.y, c.size, c.size)
        end
    end
    
    if state == "VERDICT" then
        -- Confetti (particles)
        for _, c in ipairs(verdict_confetti) do
            lurek.render.setColor(c.r, c.g, c.b, 0.9)
            rect("fill", c.x, c.y, c.size, c.size)
        end
    end

    -- OBJECTION! text overlay (tweened)
    if objection_alpha > 0 then
        lurek.render.setColor(1, 0.3, 0.05, objection_alpha)
        local os_x = 400 - 80 * objection_scale
        local os_y = 200 - 15 * objection_scale
        text_("OBJECTION!", os_x, os_y, 0, objection_scale * 1.5, objection_scale * 1.5)
    end
end
