-- Legacy compatibility module: keep old require paths working.
local ok, chunk = pcall(lurek.filesystem.load, "app/ui_controls_toml.lua")
if not ok then
	chunk = lurek.filesystem.load("content/games/apps/household_finance_lab/app/ui_controls_toml.lua")
end
return chunk()
