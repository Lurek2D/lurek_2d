--- @module library.audio_manager
--- @status full
--- High-level audio manager: music crossfade, SFX pools, volume groups,
--- master volume, mute/unmute, pause/resume. Wraps lurek.audio.* for
--- convenient game-level sound control.
--- @see lurek.audio

local M = {}

--- Optional debug logging via lurek.log when running inside the engine.
--- Falls back to a no-op when lurek is unavailable.
-- @see lurek.log
local _log_debug = function() end
local _has_lurek = rawget(_G, 'lurek') ~= nil
if _has_lurek then
    local ok, _ = pcall(function()
        if lurek.log and type(lurek.log.debug) == 'function' then
            _log_debug = function(msg) lurek.log.debug('[audio_manager] ' .. msg) end
        end
    end)
    if not ok then _log_debug = function() end end
end

-- ── Internal: audio backend abstraction ──────────────────────────────────────

local _audio = {}

if _has_lurek and lurek.audio then
    _audio.play      = lurek.audio.play
    _audio.stop      = lurek.audio.stop
    _audio.setVolume = lurek.audio.setVolume
    _audio.pause     = lurek.audio.pause
    _audio.resume    = lurek.audio.resume
else
    -- Stubs for headless / test environments
    local _next_handle = 0
    _audio.play = function(path, opts)
        _next_handle = _next_handle + 1
        return _next_handle
    end
    _audio.stop      = function(handle) end
    _audio.setVolume = function(handle, vol) end
    _audio.pause     = function(handle) end
    _audio.resume    = function(handle) end
end

-- ── AudioManager class ───────────────────────────────────────────────────────

local AudioManager = {}
AudioManager.__index = AudioManager

--- Creates a new AudioManager instance.
--- @tparam table opts Configuration table
--- @tparam[opt={}] table opts.groups Volume group definitions, keyed by name.
---   Each value is a table with a `volume` field (0.0–1.0).
--- @treturn AudioManager New audio manager instance.
function M.new(opts)
    opts = opts or {}
    local self = setmetatable({}, AudioManager)

    self._master_volume = 1.0
    self._master_muted  = false

    -- Volume groups: { name = { volume=number, muted=bool } }
    self._groups = {}
    if opts.groups then
        for name, cfg in pairs(opts.groups) do
            self._groups[name] = {
                volume = cfg.volume or 1.0,
                muted  = false,
            }
        end
    end

    -- Current music state
    self._music_handle = nil
    self._music_path   = nil
    self._music_group  = nil

    -- Crossfade state
    self._crossfade = nil  -- { old_handle, new_handle, new_path, new_group, duration, elapsed }

    -- Fade-in state for playMusic
    self._fade_in = nil  -- { handle, target_vol, duration, elapsed }

    -- Fade-out state for stopMusic
    self._fade_out = nil -- { handle, start_vol, duration, elapsed }

    -- Active SFX: { [handle] = { path=str, group=str } }
    self._active_sfx = {}

    -- SFX instance counts: { [path] = count }
    self._sfx_counts = {}

    -- SFX pool tracking: { [path] = { handle1, handle2, ... } } (ordered oldest first)
    self._sfx_pool = {}

    -- All active handles for pause/resume
    self._all_handles = {}  -- { [handle] = true }

    self._paused = false

    _log_debug('created with ' .. self:_countGroups() .. ' group(s)')
    return self
end

function AudioManager:_countGroups()
    local n = 0
    for _ in pairs(self._groups) do n = n + 1 end
    return n
end

--- Computes effective volume for a group (group volume * master volume).
--- @tparam string group_name Group name.
--- @treturn number Effective volume (0.0–1.0).
function AudioManager:_effectiveVolume(group_name)
    if self._master_muted then return 0.0 end
    local grp = self._groups[group_name]
    if not grp then return self._master_volume end
    if grp.muted then return 0.0 end
    return grp.volume * self._master_volume
end

--- Applies current effective volume to a handle.
--- @tparam any handle Audio handle.
--- @tparam string group_name Group name.
function AudioManager:_applyVolume(handle, group_name)
    if handle then
        _audio.setVolume(handle, self:_effectiveVolume(group_name))
    end
end

--- Refreshes volume on all active handles in a group.
--- @tparam string group_name Group name.
function AudioManager:_refreshGroup(group_name)
    -- Music
    if self._music_group == group_name and self._music_handle then
        self:_applyVolume(self._music_handle, group_name)
    end
    -- SFX
    for handle, info in pairs(self._active_sfx) do
        if info.group == group_name then
            self:_applyVolume(handle, group_name)
        end
    end
end

--- Refreshes volume on all active handles.
function AudioManager:_refreshAll()
    if self._music_handle then
        self:_applyVolume(self._music_handle, self._music_group)
    end
    for handle, info in pairs(self._active_sfx) do
        self:_applyVolume(handle, info.group)
    end
end

-- ── Music ────────────────────────────────────────────────────────────────────

--- Plays a music track, optionally fading in.
--- Stops any currently playing music immediately (or use crossfade instead).
--- @tparam string path Path to the audio file.
--- @tparam[opt={}] table opts Options table.
--- @tparam[opt="music"] string opts.group Volume group name.
--- @tparam[opt=0] number opts.fadeIn Fade-in duration in seconds.
--- @treturn any Audio handle for the new music.
function AudioManager:playMusic(path, opts)
    opts = opts or {}
    local group = opts.group or "music"
    local fade_in = opts.fadeIn or 0

    -- Stop old music immediately
    if self._music_handle then
        _audio.stop(self._music_handle)
        self._all_handles[self._music_handle] = nil
    end

    -- Cancel any active crossfade
    self._crossfade = nil
    self._fade_out = nil

    local eff_vol = self:_effectiveVolume(group)
    local start_vol = fade_in > 0 and 0.0 or eff_vol

    local handle = _audio.play(path, { volume = start_vol, loop = true })
    self._music_handle = handle
    self._music_path   = path
    self._music_group  = group
    self._all_handles[handle] = true

    if fade_in > 0 then
        self._fade_in = {
            handle     = handle,
            target_vol = eff_vol,
            duration   = fade_in,
            elapsed    = 0,
        }
    end

    _log_debug('playMusic: ' .. path)
    return handle
end

--- Stops the current music, optionally fading out.
--- @tparam[opt={}] table opts Options table.
--- @tparam[opt=0] number opts.fadeOut Fade-out duration in seconds.
function AudioManager:stopMusic(opts)
    opts = opts or {}
    local fade_out = opts.fadeOut or 0

    if not self._music_handle then return end

    if fade_out > 0 then
        self._fade_out = {
            handle    = self._music_handle,
            start_vol = self:_effectiveVolume(self._music_group),
            duration  = fade_out,
            elapsed   = 0,
        }
        -- Clear music reference so new playMusic doesn't conflict
        self._music_handle = nil
        self._music_path   = nil
        self._music_group  = nil
    else
        _audio.stop(self._music_handle)
        self._all_handles[self._music_handle] = nil
        self._music_handle = nil
        self._music_path   = nil
        self._music_group  = nil
    end

    self._fade_in = nil
    _log_debug('stopMusic')
end

--- Crossfades from current music to a new track.
--- @tparam string path Path to the new audio file.
--- @tparam[opt={}] table opts Options table.
--- @tparam[opt=1.0] number opts.duration Crossfade duration in seconds.
--- @tparam[opt="music"] string opts.group Volume group for the new track.
function AudioManager:crossfade(path, opts)
    opts = opts or {}
    local duration = opts.duration or 1.0
    local group = opts.group or "music"

    local old_handle = self._music_handle

    -- Start new track at zero volume
    local new_handle = _audio.play(path, { volume = 0.0, loop = true })
    self._all_handles[new_handle] = true

    self._crossfade = {
        old_handle = old_handle,
        old_group  = self._music_group,
        new_handle = new_handle,
        new_path   = path,
        new_group  = group,
        duration   = duration,
        elapsed    = 0,
    }

    -- The new track becomes the current music when crossfade completes
    self._music_handle = new_handle
    self._music_path   = path
    self._music_group  = group
    self._fade_in = nil
    self._fade_out = nil

    _log_debug('crossfade -> ' .. path .. ' (' .. duration .. 's)')
end

-- ── SFX ──────────────────────────────────────────────────────────────────────

--- Plays a sound effect with optional pooling.
--- @tparam string path Path to the audio file.
--- @tparam[opt={}] table opts Options table.
--- @tparam[opt="sfx"] string opts.group Volume group name.
--- @tparam[opt=nil] number opts.maxInstances Maximum concurrent instances of this sound.
--- @treturn any|nil Audio handle, or nil if maxInstances reached and oldest was replaced.
function AudioManager:playSfx(path, opts)
    opts = opts or {}
    local group = opts.group or "sfx"
    local max_inst = opts.maxInstances

    -- Pool management
    if max_inst then
        local count = self._sfx_counts[path] or 0
        if count >= max_inst then
            -- Replace oldest instance
            local pool = self._sfx_pool[path]
            if pool and #pool > 0 then
                local oldest = table.remove(pool, 1)
                _audio.stop(oldest)
                self._active_sfx[oldest] = nil
                self._all_handles[oldest] = nil
                self._sfx_counts[path] = count - 1
            end
        end
    end

    local eff_vol = self:_effectiveVolume(group)
    local handle = _audio.play(path, { volume = eff_vol })
    self._active_sfx[handle] = { path = path, group = group }
    self._all_handles[handle] = true

    -- Update counts and pool
    self._sfx_counts[path] = (self._sfx_counts[path] or 0) + 1
    if not self._sfx_pool[path] then self._sfx_pool[path] = {} end
    table.insert(self._sfx_pool[path], handle)

    _log_debug('playSfx: ' .. path)
    return handle
end

--- Stops a specific SFX handle.
--- @tparam any handle The audio handle to stop.
function AudioManager:stopSfx(handle)
    local info = self._active_sfx[handle]
    if not info then return end

    _audio.stop(handle)
    self._active_sfx[handle] = nil
    self._all_handles[handle] = nil

    -- Update pool tracking
    local path = info.path
    self._sfx_counts[path] = math.max(0, (self._sfx_counts[path] or 1) - 1)
    local pool = self._sfx_pool[path]
    if pool then
        for i, h in ipairs(pool) do
            if h == handle then
                table.remove(pool, i)
                break
            end
        end
    end
end

-- ── Volume Control ───────────────────────────────────────────────────────────

--- Sets the volume for a named group.
--- @tparam string group_name Group name.
--- @tparam number volume Volume level (0.0–1.0).
function AudioManager:setGroupVolume(group_name, volume)
    local grp = self._groups[group_name]
    if not grp then
        self._groups[group_name] = { volume = volume, muted = false }
    else
        grp.volume = volume
    end
    self:_refreshGroup(group_name)
end

--- Gets the volume for a named group.
--- @tparam string group_name Group name.
--- @treturn number Volume level (0.0–1.0).
function AudioManager:getGroupVolume(group_name)
    local grp = self._groups[group_name]
    if not grp then return 1.0 end
    return grp.volume
end

--- Sets the master volume (multiplied with group volumes).
--- @tparam number volume Master volume (0.0–1.0).
function AudioManager:setMasterVolume(volume)
    self._master_volume = volume
    self:_refreshAll()
end

--- Gets the master volume.
--- @treturn number Master volume (0.0–1.0).
function AudioManager:getMasterVolume()
    return self._master_volume
end

-- ── Mute / Unmute ────────────────────────────────────────────────────────────

--- Mutes a specific volume group.
--- @tparam string group_name Group name to mute.
function AudioManager:mute(group_name)
    local grp = self._groups[group_name]
    if not grp then
        self._groups[group_name] = { volume = 1.0, muted = true }
    else
        grp.muted = true
    end
    self:_refreshGroup(group_name)
end

--- Unmutes a specific volume group.
--- @tparam string group_name Group name to unmute.
function AudioManager:unmute(group_name)
    local grp = self._groups[group_name]
    if grp then
        grp.muted = false
        self:_refreshGroup(group_name)
    end
end

--- Mutes all audio (master mute).
function AudioManager:muteAll()
    self._master_muted = true
    self:_refreshAll()
end

--- Unmutes all audio (restores master).
function AudioManager:unmuteAll()
    self._master_muted = false
    self:_refreshAll()
end

-- ── Pause / Resume ───────────────────────────────────────────────────────────

--- Pauses all active audio handles.
function AudioManager:pauseAll()
    self._paused = true
    for handle in pairs(self._all_handles) do
        _audio.pause(handle)
    end
    _log_debug('pauseAll')
end

--- Resumes all paused audio handles.
function AudioManager:resumeAll()
    self._paused = false
    for handle in pairs(self._all_handles) do
        _audio.resume(handle)
    end
    _log_debug('resumeAll')
end

-- ── Update ───────────────────────────────────────────────────────────────────

--- Updates fade states. Call once per frame.
--- @tparam number dt Delta time in seconds since last frame.
function AudioManager:update(dt)
    -- Crossfade update
    if self._crossfade then
        local cf = self._crossfade
        cf.elapsed = cf.elapsed + dt
        local t = math.min(cf.elapsed / cf.duration, 1.0)

        -- Fade out old
        if cf.old_handle then
            local old_eff = self:_effectiveVolume(cf.old_group or "music")
            _audio.setVolume(cf.old_handle, old_eff * (1.0 - t))
        end

        -- Fade in new
        local new_eff = self:_effectiveVolume(cf.new_group)
        _audio.setVolume(cf.new_handle, new_eff * t)

        if t >= 1.0 then
            -- Crossfade complete: stop old track
            if cf.old_handle then
                _audio.stop(cf.old_handle)
                self._all_handles[cf.old_handle] = nil
            end
            self._crossfade = nil
        end
    end

    -- Fade-in update (playMusic with fadeIn)
    if self._fade_in then
        local fi = self._fade_in
        fi.elapsed = fi.elapsed + dt
        local t = math.min(fi.elapsed / fi.duration, 1.0)
        _audio.setVolume(fi.handle, fi.target_vol * t)
        if t >= 1.0 then
            self._fade_in = nil
        end
    end

    -- Fade-out update (stopMusic with fadeOut)
    if self._fade_out then
        local fo = self._fade_out
        fo.elapsed = fo.elapsed + dt
        local t = math.min(fo.elapsed / fo.duration, 1.0)
        _audio.setVolume(fo.handle, fo.start_vol * (1.0 - t))
        if t >= 1.0 then
            _audio.stop(fo.handle)
            self._all_handles[fo.handle] = nil
            self._fade_out = nil
        end
    end
end

return M
