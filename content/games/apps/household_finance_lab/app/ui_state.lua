local UIState = {}

local function clamp(value, min_value, max_value)
    if value < min_value then return min_value end
    if value > max_value then return max_value end
    return value
end

function UIState.new(C)
    return {
        active_tab = 1,
        start_year = C.YEAR_MIN,
        end_year = C.YEAR_MAX,
        member_index = 1,
        category_index = 1,
        use_cleaned = true,
        anomaly_threshold = 30,
        hover_id = nil,
        selected_transaction = 1,
        selected_anomaly = 1,
        table_scroll = 0,
        log_scroll = 0,
        needs_refresh = true,
        status = "Booting",
        last_action = "",
    }
end

function UIState.mark_dirty(state, label)
    state.needs_refresh = true
    state.last_action = label or state.last_action
end

function UIState.set_tab(C, state, index)
    state.active_tab = clamp(index, 1, #C.TABS)
    state.last_action = "tab " .. C.TABS[state.active_tab]
end

function UIState.bump_member(C, state, delta)
    state.member_index = ((state.member_index - 1 + delta) % #C.MEMBERS) + 1
    UIState.mark_dirty(state, "member " .. C.MEMBERS[state.member_index])
end

function UIState.bump_category(C, state, delta)
    state.category_index = ((state.category_index - 1 + delta) % #C.CATEGORIES) + 1
    UIState.mark_dirty(state, "category " .. C.CATEGORIES[state.category_index])
end

function UIState.bump_start_year(C, state, delta)
    state.start_year = clamp(state.start_year + delta, C.YEAR_MIN, state.end_year)
    UIState.mark_dirty(state, "start year")
end

function UIState.bump_end_year(C, state, delta)
    state.end_year = clamp(state.end_year + delta, state.start_year, C.YEAR_MAX)
    UIState.mark_dirty(state, "end year")
end

function UIState.toggle_cleaned(state)
    state.use_cleaned = not state.use_cleaned
    UIState.mark_dirty(state, state.use_cleaned and "cleaned" or "raw")
end

function UIState.bump_threshold(state, delta)
    state.anomaly_threshold = clamp(state.anomaly_threshold + delta, 0, 100)
    UIState.mark_dirty(state, "anomaly threshold")
end

function UIState.member(C, state)
    return C.MEMBERS[state.member_index] or "All"
end

function UIState.category(C, state)
    return C.CATEGORIES[state.category_index] or "All"
end

function UIState.snapshot(C, state)
    return {
        tab = C.TABS[state.active_tab] or "Widgets",
        start_year = state.start_year,
        end_year = state.end_year,
        member = UIState.member(C, state),
        category = UIState.category(C, state),
        use_cleaned = state.use_cleaned,
        anomaly_threshold = state.anomaly_threshold,
    }
end

return UIState