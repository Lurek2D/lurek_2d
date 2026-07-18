local M = {}

function M.start_budget(content)
    return tonumber(content.game.battle_budget) or 200
end

function M.score_for_kill(content)
    return tonumber(content.economy.kill_score) or 5
end

function M.finish(content_or_campaign, campaign_or_win, win)
    local content, campaign
    if content_or_campaign and content_or_campaign.game then
        content, campaign = content_or_campaign, campaign_or_win
    else
        campaign, win = content_or_campaign, campaign_or_win
    end
    local economy = content and content.economy or {}
    campaign.level = (campaign.level or 1) + (win and (tonumber(economy.win_level_gain) or 1) or 0)
    campaign.stars = (campaign.stars or 0) + (win and (tonumber(economy.win_star_gain) or 3) or (tonumber(economy.loss_star_gain) or 1))
    if win then campaign.wins = (campaign.wins or 0) + 1 else campaign.losses = (campaign.losses or 0) + 1 end
    return campaign
end

return M
