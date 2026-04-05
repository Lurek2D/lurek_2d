---@meta
--- Auto-generated Luna2D API documentation for LuaCATS.

luna = {}

---@class luna.ai
luna.ai = {}

---@class AIWorld
local AIWorld = {}

--- Registers a new agent named `name` in this world and returns its handle.
---@param name string `string`: Unique identifier for the new agent.
---@return number
function AIWorld:addAgent(name) end

--- Looks up a registered agent by name.
---@param name string `string`: Name of the agent to retrieve.
---@return number
function AIWorld:getAgent(name) end

--- Returns the number of agents currently registered in this world.
---@return number
function AIWorld:getAgentCount() end

--- Returns a snapshot of the shared world-level blackboard.
---@return any
function AIWorld:getGlobalBlackboard() end

--- Removes and destroys the given agent from this world.
---@param agent any `Agent`: Handle of the agent to remove, obtained from `addAgent`.
function AIWorld:removeAgent(agent) end

--- Advances all agents in the world by `dt` seconds, integrating velocity into position.
---@param dt number `number`: Elapsed seconds since the last frame.
function AIWorld:update(dt) end

---@class Agent
local Agent = {}

--- Adds a string tag to this agent's tag set (idempotent).
---@param tag string `string`: Tag to add.
function Agent:addTag(tag) end

--- Returns this agent's private blackboard for reading or writing typed data.
---@return any
function Agent:getBlackboard() end

--- Returns the name of the agent's current decision model.
---@return string
function Agent:getDecisionModel() end

--- Returns the maximum steering force cap.
---@return number
function Agent:getMaxForce() end

--- Returns the maximum movement speed cap in world units/second.
---@return number
function Agent:getMaxSpeed() end

--- Returns the unique name this agent was registered under.
---@return string
function Agent:getName() end

--- Returns the agent's current world-space position.
---@return number
---@return number
function Agent:getPosition() end

--- Returns the agent's scheduling priority level.
---@return number
function Agent:getPriority() end

--- Returns the agent's current velocity vector.
---@return number
---@return number
function Agent:getVelocity() end

--- Returns `true` if this agent's tag set contains `tag`.
---@param tag string `string`: Tag to test.
---@return boolean
function Agent:hasTag(tag) end

--- Removes a string tag from this agent's tag set (no-op if absent).
---@param tag string `string`: Tag to remove.
function Agent:removeTag(tag) end

--- Switches the agent's active decision model at runtime. Valid values: `"fsm"`, `"bt"`, `"utility"`, `"goap"`.
---@param model string `string`: Decision model identifier.
function Agent:setDecisionModel(model) end

--- Sets the maximum steering force that can be applied per frame.
---@param v number `number`: New force cap.
function Agent:setMaxForce(v) end

--- Sets the maximum movement speed cap in world units/second.
---@param v number `number`: New speed limit (world units/sec).
function Agent:setMaxSpeed(v) end

--- Teleports the agent to world-space coordinates (`x`, `y`).
---@param x number `number`: Horizontal world-space position.
---@param y number `number`: Vertical world-space position.
function Agent:setPosition(x, y) end

--- Sets the scheduling priority; higher-priority agents are processed first during `update`.
---@param p number `integer`: Priority value, higher = earlier processing.
function Agent:setPriority(p) end

--- Sets the agent's velocity vector in world units per second.
---@param x number `number`: Horizontal component.
---@param y number `number`: Vertical component.
function Agent:setVelocity(x, y) end

---@class BTNode
local BTNode = {}

--- Adds child to the collection.
---@param child_ud any `userdata`.
function BTNode:addChild(child_ud) end

--- Returns the child count.
---@return any
function BTNode:getChildCount() end

--- Returns the count.
---@return any
function BTNode:getCount() end

--- Returns the node type.
---@return number
function BTNode:getNodeType() end

--- Resets state to initial values.
---@param child_ud any `userdata`.
function BTNode:reset(child_ud) end

--- Sets the child.
---@param child_ud any `userdata`.
function BTNode:setChild(child_ud) end

--- Sets the count.
---@param n number `integer`.
function BTNode:setCount(n) end

--- Sets the failure policy.
---@param policy string `string`.
function BTNode:setFailurePolicy(policy) end

--- Sets the success policy.
---@param policy string `string`.
function BTNode:setSuccessPolicy(policy) end

---@class BehaviorTree
local BehaviorTree = {}

--- Returns the last status.
---@return any
function BehaviorTree:getLastStatus() end

--- Sets the top-level root node of this behavior tree.
---@param node number `BTNode`: Root `BTNode` returned by one of the node constructors.
function BehaviorTree:setRoot(node) end

---@class Blackboard
local Blackboard = {}

--- Removes all entries from this blackboard.
function Blackboard:clear() end

--- Returns the keys.
---@return number
function Blackboard:getKeys() end

--- Returns the size.
---@return integer
function Blackboard:getSize() end

--- Returns `true` if a value is stored under `key` in this blackboard.
---@param key string `string`: Key to check.
---@return boolean
function Blackboard:has(key) end

--- Deletes the entry at `key` from this blackboard (no-op if absent).
---@param key string `string`: Key to delete.
function Blackboard:remove(key) end

--- Stores a boolean value under `key` on this blackboard.
---@param key string `string`: Key to write.
---@param value boolean `boolean`: Value to store.
function Blackboard:setBool(key, value) end

--- Stores a floating-point value under `key` on this blackboard.
---@param key string `string`: Key to write.
---@param value number `number`: Value to store.
function Blackboard:setNumber(key, value) end

--- Stores a string value under `key` on this blackboard.
---@param key string `string`: Key to write.
---@param value string `string`: Value to store.
function Blackboard:setString(key, value) end

---@class CommandQueue
local CommandQueue = {}

--- Cancel current on this CommandQueue.
---@return any
function CommandQueue:cancelCurrent() end

--- Discards all queued commands.
function CommandQueue:clear() end

--- Returns the count.
---@return integer
function CommandQueue:getCount() end

--- Returns the current target.
---@return any
function CommandQueue:getCurrentTarget() end

--- Returns the current type.
---@return number
function CommandQueue:getCurrentType() end

--- Returns `true` if there are no commands queued.
---@return boolean
function CommandQueue:isEmpty() end

---@class GOAPPlanner
local GOAPPlanner = {}

--- Returns the action count.
---@return integer
function GOAPPlanner:getActionCount() end

--- Returns the goal count.
---@return integer
function GOAPPlanner:getGoalCount() end

---@class InfluenceMap
local InfluenceMap = {}

--- Adds a named influence layer to this map.
---@param name string `string`: Layer identifier.
function InfluenceMap:addLayer(name) end

--- Clear all on this InfluenceMap.
---@param layer string `string`.
function InfluenceMap:clearAll(layer) end

--- Clear layer on this InfluenceMap.
---@param layer string `string`.
function InfluenceMap:clearLayer(layer) end

--- Decay on this InfluenceMap.
---@param layer string `string`.
---@param factor number `number`.
function InfluenceMap:decay(layer, factor) end

--- Returns the cell size.
---@return any
function InfluenceMap:getCellSize() end

--- Returns the height.
---@return number
function InfluenceMap:getHeight() end

--- Returns the max position.
---@param layer string `string`.
---@return number
function InfluenceMap:getMaxPosition(layer) end

--- Returns the min position.
---@param layer string `string`.
---@param wx number `number`.
---@param wy number `number`.
---@param ww number `number`.
---@param wh number `number`.
---@return any
function InfluenceMap:getMinPosition(layer, wx, wy, ww, wh) end

--- Returns the width.
---@return number
function InfluenceMap:getWidth() end

--- Returns `true` if a layer with `name` exists in this map.
---@param name string `string`: Layer identifier to test.
---@return boolean
function InfluenceMap:hasLayer(name) end

---@class QLearner
local QLearner = {}

--- Returns the action with the highest Q-value for `state`.
---@param state string `string`: State to query.
---@return string
function QLearner:bestAction(state) end

--- Choose action on this QLearner.
---@param state number `integer`.
---@return any
function QLearner:chooseAction(state) end

--- Populates this object from a serialized string.
---@param json string `string`.
function QLearner:deserialize(json) end

--- End episode on this QLearner.
---@return any
function QLearner:endEpisode() end

--- Returns the action count.
---@param v number `number`.
---@return any
function QLearner:getActionCount(v) end

--- Returns the best action.
---@param state number `integer`.
---@param action number `integer`.
---@param reward number `number`.
---@param next_state number `integer`.
---@return any
function QLearner:getBestAction(state, action, reward, next_state) end

--- Returns the discount factor.
---@param v number `number`.
---@return any
function QLearner:getDiscountFactor(v) end

--- Returns the episode count.
---@return any
function QLearner:getEpisodeCount() end

--- Returns the exploration decay.
---@return number
function QLearner:getExplorationDecay() end

--- Returns the exploration rate.
---@param v number `number`.
---@return number
function QLearner:getExplorationRate(v) end

--- Returns the learning rate.
---@param v number `number`.
---@return any
function QLearner:getLearningRate(v) end

--- Returns the q value.
---@param state number `integer`.
---@param action number `integer`.
---@return any
function QLearner:getQValue(state, action) end

--- Returns the state count.
---@return any
function QLearner:getStateCount() end

--- Serializes this object to a string representation.
---@param json string `string`.
---@return any
function QLearner:serialize(json) end

--- Sets the discount factor.
---@param v number `number`.
function QLearner:setDiscountFactor(v) end

--- Sets the exploration decay.
---@param v number `number`.
function QLearner:setExplorationDecay(v) end

--- Sets the exploration rate.
---@param v number `number`.
function QLearner:setExplorationRate(v) end

--- Sets the learning rate.
---@param v number `number`.
function QLearner:setLearningRate(v) end

---@class Squad
local Squad = {}

--- Adds an agent identified by `name` to this squad.
---@param name string `string`: Name of the agent to enlist.
function Squad:addMember(name) end

--- Returns the blackboard.
---@return any
function Squad:getBlackboard() end

--- Returns the formation.
---@return any
function Squad:getFormation() end

--- Returns the formation spacing.
---@param member_idx number `integer`.
---@param leader_x number `number`.
---@param leader_y number `number`.
---@return any
function Squad:getFormationSpacing(member_idx, leader_x, leader_y) end

--- Returns the leader.
---@param ftype string `string`.
---@param spacing? number `number` optional.
---@return any
function Squad:getLeader(ftype, spacing) end

--- Returns the number of agents currently in this squad.
---@return number
function Squad:getMemberCount() end

--- Returns the members.
---@return table
function Squad:getMembers() end

--- Returns the name.
---@param name string `string`.
---@return any
function Squad:getName(name) end

--- Removes the agent identified by `name` from this squad.
---@param name string `string`: Name of the agent to remove.
function Squad:removeMember(name) end

--- Sets the leader.
---@param name string `string`.
function Squad:setLeader(name) end

---@class StateMachine
local StateMachine = {}

--- Registers a new named state in this FSM.
---@param name string `string`: Unique name for the state.
function StateMachine:addState(name) end

--- Force state on this StateMachine.
---@param name string `string`.
function StateMachine:forceState(name) end

--- Returns the current state.
---@param name string `string`.
---@return any
function StateMachine:getCurrentState(name) end

--- Returns the time in state.
---@return any
function StateMachine:getTimeInState() end

--- Sets the initial state.
---@param name string `string`.
function StateMachine:setInitialState(name) end

---@class SteeringManager
local SteeringManager = {}

--- Returns the behavior count.
---@param mode string `string`.
---@return integer
function SteeringManager:getBehaviorCount(mode) end

--- Returns the combine mode.
---@return string
function SteeringManager:getCombineMode() end

--- Returns the last steering.
---@return any
function SteeringManager:getLastSteering() end

--- Sets the combine mode.
---@param mode string `string`.
function SteeringManager:setCombineMode(mode) end

---@class UtilityAI
local UtilityAI = {}

--- Evaluates all conditions and returns a decision.
---@return any
function UtilityAI:evaluate() end

--- Returns the action count.
---@return integer
function UtilityAI:getActionCount() end

--- Returns the last action.
---@return any
function UtilityAI:getLastAction() end

--- New action.
---@param callback any
---@return any
function luna.ai.newAction(callback) end

--- New behavior tree.
---@return any
function luna.ai.newBehaviorTree() end

--- New blackboard.
---@return any
function luna.ai.newBlackboard() end

--- New command queue.
---@return any
function luna.ai.newCommandQueue() end

--- New condition.
---@param callback any
---@return any
function luna.ai.newCondition(callback) end

--- New goap planner.
---@return any
function luna.ai.newGOAPPlanner() end

--- New influence map.
---@param w any
---@param h any
---@param cs any
---@return any
function luna.ai.newInfluenceMap(w, h, cs) end

--- New inverter.
---@return any
function luna.ai.newInverter() end

--- New parallel.
---@param sp? any (optional)
---@param fp? any (optional)
---@return any
function luna.ai.newParallel(sp, fp) end

--- New q learner.
---@param sc any
---@param ac any
---@return any
function luna.ai.newQLearner(sc, ac) end

--- New repeater.
---@param count? any (optional)
---@return any
function luna.ai.newRepeater(count) end

--- New selector.
---@return any
function luna.ai.newSelector() end

--- New sequence.
---@return any
function luna.ai.newSequence() end

--- New squad.
---@param name any
---@return any
function luna.ai.newSquad(name) end

--- New state machine.
---@return any
function luna.ai.newStateMachine() end

--- New steering manager.
---@return any
function luna.ai.newSteeringManager() end

--- New succeeder.
---@return any
function luna.ai.newSucceeder() end

--- New utility ai.
---@return any
function luna.ai.newUtilityAI() end

--- New world.
---@return any
function luna.ai.newWorld() end

---@class luna.animation
luna.animation = {}

--- Lua UserData wrapper for an [`Animation`] controller.
---@class Animation
local Animation = {}

--- Adds a single frame to the frame pool.
---@param x any
---@param y any
---@param w any
---@param h any
---@return number
function Animation:addFrame(x, y, w, h) end

--- Returns the name of the currently playing clip, or `nil`.
---@return string|nil
function Animation:getClip() end

--- Returns the total number of named clips.
---@return number
function Animation:getClipCount() end

--- Returns the total number of frames in the frame pool.
---@return number
function Animation:getFrameCount() end

--- Returns the source quad `{x, y, w, h}` for the current frame, or `nil`.
---@return table|nil
function Animation:getQuad() end

--- Returns the playback speed multiplier.
---@return number
function Animation:getSpeed() end

--- Returns `true` if a clip is currently playing.
---@return boolean
function Animation:isPlaying() end

--- Starts playback of the named clip. Returns `true` if the clip exists.
---@param name any
---@return boolean
function Animation:play(name) end

--- Drains and returns all pending animation events as a table.
---@return table
function Animation:pollEvents() end

--- Sets the playback speed multiplier.
---@param speed any
function Animation:setSpeed(speed) end

--- Stops playback and clears the current clip.
function Animation:stop() end

--- Advances the animation by `dt` seconds.
---@param dt any
function Animation:update(dt) end

--- Creates a new, empty [`Animation`] controller.
---@return Animation
function luna.animation.new() end

---@class luna.audio
luna.audio = {}

--- Lua UserData wrapper for an audio bus. Consult the module-level documentation for the broader usage context and preconditions.
---@class Bus
local Bus = {}

--- Returns the name of this audio bus.
---@return any
function Bus:getName() end

--- Returns the pitch multiplier of this bus.
---@return any
function Bus:getPitch() end

--- Returns the current volume scale of this audio mixer bus.
---@return number
function Bus:getVolume() end

--- Returns whether this bus is currently paused.
---@return any
function Bus:isPaused() end

--- Pauses all audio sources that are currently playing through this bus.
function Bus:pause() end

--- Resumes all paused sources on this bus.
function Bus:resume() end

--- Sets the pitch multiplier for all sources on this bus.
---@param pitch any
function Bus:setPitch(pitch) end

--- Sets the volume for all sources routed to this bus.
---@param vol any
function Bus:setVolume(vol) end

--- Lua UserData wrapper for a streaming audio `Decoder`.
---@class Decoder
local Decoder = {}

--- Decode the next chunk of audio samples.
---@return SoundData
function Decoder:decode() end

--- Return the bit depth.
---@return any
function Decoder:getBitDepth() end

--- Return the number of audio channels.
---@return any
function Decoder:getChannelCount() end

--- Return the total duration in seconds.
---@return any
function Decoder:getDuration() end

--- Return the sample rate in Hz.
---@return any
function Decoder:getSampleRate() end

--- Returns whether this decoder supports seeking.
---@return number
function Decoder:isSeekable() end

--- Release the decoder (no-op in the current model).
function Decoder:release() end

--- Rewind to the beginning.
function Decoder:rewind() end

--- Seek to a time offset in seconds.
---@param offset any `f64`.
function Decoder:seek(offset) end

--- Return the current playback position in seconds.
---@return any
function Decoder:tell() end

--- Lua UserData wrapper for the MIDI player.
---@class MidiPlayer
local MidiPlayer = {}

--- Returns the audio bus that this MIDI player's output is routed through.
---@return any
function MidiPlayer:getBus() end

--- Returns the number of MIDI channels present in the loaded sequence.
---@return number
function MidiPlayer:getChannelCount() end

--- Returns the General MIDI instrument index for the given MIDI channel.
---@param channel number 1-based MIDI channel number (1-16).
---@return number
function MidiPlayer:getChannelInstrument(channel) end

--- Returns the current volume scale applied to the given MIDI channel.
---@param channel number 1-based MIDI channel number (1-16).
---@return number
function MidiPlayer:getChannelVolume(channel) end

--- Returns the total duration of the audio source in seconds.
---@return any
function MidiPlayer:getDuration() end

--- Returns the file path of the MIDI file currently loaded into the player.
---@return string
function MidiPlayer:getFilePath() end

--- Returns the total number of note events in the loaded MIDI sequence.
---@return number
function MidiPlayer:getNoteCount() end

--- Returns the original tempo written in the MIDI file, in beats per minute.
---@return any
function MidiPlayer:getOriginalTempo() end

--- Returns the file path of the SoundFont (.sf2) currently loaded into the player.
---@return string
function MidiPlayer:getSoundFontPath() end

--- Returns the current playback tempo in beats per minute.
---@return number
function MidiPlayer:getTempo() end

--- Returns the current tempo scale factor applied on top of the original BPM.
---@return number
function MidiPlayer:getTempoScale() end

--- Returns the ticks-per-beat (PPQ) resolution defined in the MIDI file header.
---@return number
function MidiPlayer:getTicksPerBeat() end

--- Returns the total number of tracks in the loaded MIDI sequence.
---@return number
function MidiPlayer:getTrackCount() end

--- Returns the name string of the given MIDI track from the sequence metadata.
---@param track number 1-based track index.
---@return string
function MidiPlayer:getTrackName(track) end

--- Returns the current volume of the audio source.
---@return any
function MidiPlayer:getVolume() end

--- Returns whether the given MIDI channel is currently muted.
---@param channel number 1-based MIDI channel number (1-16).
---@return boolean
function MidiPlayer:isChannelMuted(channel) end

--- Returns whether a MIDI file or data string has been successfully loaded.
---@return number
function MidiPlayer:isLoaded() end

--- Returns whether the audio source is set to loop.
---@return any
function MidiPlayer:isLooping() end

--- Returns whether the audio source is currently paused.
---@return any
function MidiPlayer:isPaused() end

--- Returns whether the audio source is currently playing.
---@return any
function MidiPlayer:isPlaying() end

--- Returns whether the given track index is currently muted.
---@param track number 1-based track index.
---@return boolean
function MidiPlayer:isTrackMuted(track) end

--- Loads a MIDI file from the given path and prepares it for playback.
---@param path string File path to the .mid MIDI file.
---@return any
function MidiPlayer:load(path) end

--- Loads MIDI data from a Lua string directly into the player.
---@param data string Raw MIDI bytes as a Lua string.
---@return any
function MidiPlayer:loadData(data) end

--- Pauses the audio source at its current position.
function MidiPlayer:pause() end

--- Plays the audio source from the beginning.
function MidiPlayer:play() end

--- Seeks to the given time position (in seconds) in the source.
---@param secs any
function MidiPlayer:seek(secs) end

--- Routes the MIDI player's synthesizer output through the given audio bus.
---@param bus string Bus object or bus name string.
function MidiPlayer:setBus(bus) end

--- Mutes or unmutes the given MIDI channel for selective playback.
---@param channel number 1-based MIDI channel (1-16).
---@param muted boolean true to silence the channel, false to unmute.
function MidiPlayer:setChannelMuted(channel, muted) end

--- Sets the volume scale for the specified MIDI channel.
---@param channel number 1-based MIDI channel (1-16).
---@param volume number Volume scale in [0.0, 1.0].
function MidiPlayer:setChannelVolume(channel, volume) end

--- Enables or disables looping playback for the source.
---@param looping any
function MidiPlayer:setLooping(looping) end

--- Registers a callback invoked when the MIDI sequence finishes playing.
---@param callback number Function called with no arguments when playback ends.
function MidiPlayer:setOnEnd(callback) end

--- Registers a callback invoked for each MIDI note-off event during playback.
---@param callback number Function called as callback(channel, note, velocity).
function MidiPlayer:setOnNoteOff(callback) end

--- Registers a callback invoked for each MIDI note-on event during playback.
---@param callback number Function called as callback(channel, note, velocity).
function MidiPlayer:setOnNoteOn(callback) end

--- Loads a SoundFont (.sf2) file into this player for instrument rendering.
---@param path string File path to the .sf2 SoundFont file.
function MidiPlayer:setSoundFont(path) end

--- Sets the playback tempo in beats per minute.
---@param bpm any Tempo in beats per minute (e.g. 120).
function MidiPlayer:setTempo(bpm) end

--- Sets a multiplier applied to the original MIDI tempo during playback.
---@param scale number Tempo scale factor (1.0 = original speed, 2.0 = double speed).
function MidiPlayer:setTempoScale(scale) end

--- Mutes or unmutes a specific track by index for selective rendering.
---@param track number 1-based track index.
---@param muted boolean true to silence the track, false to enable it.
function MidiPlayer:setTrackMuted(track, muted) end

--- Sets the playback volume (0.0 - 1.0) of the source.
---@param vol any
function MidiPlayer:setVolume(vol) end

--- Solos the given MIDI channel so it is the only one producing sound.
---@param channel number 1-based MIDI channel (1-16).
---@param solo boolean true to solo, false to clear solo.
function MidiPlayer:soloChannel(channel, solo) end

--- Stops playback of the audio source.
function MidiPlayer:stop() end

--- Returns the current playback position in seconds.
---@return any
function MidiPlayer:tell() end

--- Clears the solo flag on every track so all tracks are audible.
function MidiPlayer:unsoloAll() end

--- Reverts the player to using the built-in default SoundFont for rendering.
function MidiPlayer:useDefaultSoundFont() end

--- Lua UserData wrapper for an audio source resource.
---@class Source
local Source = {}

--- Removes any active filter from the audio source.
function Source:clearFilter() end

--- Creates an independent copy of an audio source.
---@return any
function Source:clone() end

--- Fades the audio source in from silence over the given duration.
---@param duration_secs any
function Source:fadeIn(duration_secs) end

--- Returns the total duration of this audio source in seconds.
---@return number
function Source:getDuration() end

--- Returns the current fade-in duration.
---@return any
function Source:getFadeIn() end

--- Returns the current high-pass filter cutoff frequency.
---@return any
function Source:getHighpass() end

--- Returns the current low-pass filter cutoff frequency.
---@return any
function Source:getLowpass() end

--- Returns the current stereo panning of the source.
---@return any
function Source:getPan() end

--- Returns the current pitch multiplier.
---@return number
function Source:getPitch() end

--- Returns the type of this audio source: 'static', 'stream', or 'queue'.
---@return string
function Source:getType() end

--- Returns the current volume multiplier.
---@return number
function Source:getVolume() end

--- Returns `true` if this source is set to loop.
---@return boolean
function Source:isLooping() end

--- Returns `true` if playback is currently paused.
---@return boolean
function Source:isPaused() end

--- Returns `true` if this source is currently playing.
---@return boolean
function Source:isPlaying() end

--- Returns `true` if playback has stopped (either manually or after the audio ended).
---@return boolean
function Source:isStopped() end

--- Pauses playback. Call `play()` to resume.
function Source:pause() end

--- Starts or resumes playback from the current seek position.
function Source:play() end

--- Resumes playback of this audio source from its current paused position.
function Source:resume() end

--- Seeks playback to `offset` seconds from the start.
---@param offset number `number`: Target position in seconds.
function Source:seek(offset) end

--- Applies a high-pass filter to the audio source.
---@param cutoff_hz any
function Source:setHighpass(cutoff_hz) end

--- Enables or disables looping. When enabled, the source restarts automatically when it reaches the end.
---@param loop boolean `boolean`: `true` to enable looping.
function Source:setLooping(loop) end

--- Applies a low-pass filter to the audio source.
---@param cutoff_hz any
function Source:setLowpass(cutoff_hz) end

--- Sets the stereo panning (-1.0 left to 1.0 right) of the source.
---@param pan any
function Source:setPan(pan) end

--- Sets the playback pitch multiplier. `1.0` is normal pitch; `2.0` doubles frequency.
---@param pitch number `number`: Pitch multiplier.
function Source:setPitch(pitch) end

--- Sets playback volume. `1.0` is full volume; `0.0` is silent.
---@param volume number `number`: Volume multiplier (0–1).
function Source:setVolume(volume) end

--- Stops playback and resets the seek position to the beginning.
function Source:stop() end

--- Returns the current playback position in seconds.
---@return number
function Source:tell() end

---@param bus_name any
---@param effect_type_str any
---@param params? any (optional)
function luna.audio.add_effect(bus_name, effect_type_str, params) end

--- Removes any active filter from the audio source.
---@param id_val any
function luna.audio.clearFilter(id_val) end

--- Unloads the active SoundFont so the MIDI player falls back to built-in defaults.
function luna.audio.clearMidiSoundFont() end

--- Creates an independent copy of an audio source.
---@param id_val any
---@return any
function luna.audio.clone(id_val) end

---@param name any
---@param parent_name? any (optional)
function luna.audio.create_bus(name, parent_name) end

--- Fades the audio source in from silence over the given duration.
---@param id_val any
---@param dur any
function luna.audio.fadeIn(id_val, dur) end

--- Returns the number of currently playing audio sources.
---@return any
function luna.audio.getActiveSourceCount() end

--- Returns the current distance attenuation model name.
---@return any
function luna.audio.getDistanceModel() end

--- Returns the current global Doppler scale.
---@return any
function luna.audio.getDopplerScale() end

--- Returns the total duration of the audio source in seconds.
---@param id_val any
---@return any
function luna.audio.getDuration(id_val) end

--- Returns the current fade-in duration.
---@param id_val any
---@return any
function luna.audio.getFadeIn(id_val) end

--- Returns the number of free buffer slots remaining in a queueable source.
---@param qsource_id number integer returned by `newQueueableSource`.
---@return number
function luna.audio.getFreeBufferCount(qsource_id) end

--- Returns the current high-pass filter cutoff frequency.
---@param id_val any
---@return any
function luna.audio.getHighpass(id_val) end

--- Returns the 3D listener position.
---@return any
function luna.audio.getListener() end

--- Returns the current 2D listener position (x, y).
---@return any
function luna.audio.getListener2D() end

--- Returns the current low-pass filter cutoff frequency.
---@param id_val any
---@return any
function luna.audio.getLowpass(id_val) end

--- Returns the current master volume scale (0.0 - 1.0) applied to all audio output.
---@return number
function luna.audio.getMasterVolume() end

--- Returns the maximum number of simultaneous audio sources.
function luna.audio.getMaxSources() end

--- Returns the current peak level of the audio source.
---@return any
function luna.audio.getMeter() end

--- Returns the 6-component orientation of an audio source.
---@param id_val any
---@return any
function luna.audio.getOrientation(id_val) end

--- Returns the current stereo panning of the source.
---@param id_val any
---@return any
function luna.audio.getPan(id_val) end

--- Returns the current pitch multiplier of the source.
---@param id_val any
---@return any
function luna.audio.getPitch(id_val) end

--- Returns the name of the currently active audio output device.
---@return string
function luna.audio.getPlaybackDevice() end

--- Returns a table containing the names of all available audio output devices.
---@return string
function luna.audio.getPlaybackDevices() end

--- Returns the 3D position of an audio source.
---@param id_val any
---@return any
function luna.audio.getPosition(id_val) end

--- Returns the bus name the source is assigned to.
---@param id_val any
---@return any
function luna.audio.getSourceBus(id_val) end

--- Returns the number of currently registered audio sources.
---@return any
function luna.audio.getSourceCount() end

--- Returns the type string ('static' or 'stream') of the source.
---@param id_val any
---@return any
function luna.audio.getSourceType(id_val) end

--- Returns the velocity of an audio source.
---@param id_val any
---@return any
function luna.audio.getVelocity(id_val) end

--- Returns the current volume of the audio source.
---@param id_val any
---@return any
function luna.audio.getVolume(id_val) end

--- Returns whether a SoundFont is currently loaded for the MIDI synthesizer.
---@return number
function luna.audio.hasMidiSoundFont() end

--- Returns whether the audio source is set to loop.
---@param id_val any
---@return any
function luna.audio.isLooping(id_val) end

--- Returns whether the audio source is currently paused.
---@param id_val any
---@return any
function luna.audio.isPaused(id_val) end

--- Returns whether the audio source is currently playing.
---@param id_val any
---@return any
function luna.audio.isPlaying(id_val) end

--- Returns whether the audio source is stopped.
---@param id_val any
---@return any
function luna.audio.isStopped(id_val) end

--- Creates a named audio bus for grouping sources.
---@param name any
---@return any
function luna.audio.newBus(name) end

--- Creates a streaming audio decoder for chunked PCM reading.
---@param source string File path to the audio file.
---@param buffersize? number Optional number of samples per chunk (default 2048).
---@return string
function luna.audio.newDecoder(source, buffersize) end

--- Creates a software MIDI synthesizer player.
---@param path? any (optional)
---@return any
function luna.audio.newMidiPlayer(path) end

--- Creates a queueable audio source that accepts manually-pushed PCM buffers.
---@param sample_rate any `u32`. Sample rate in Hz (e.g. 44100).
---@param bit_depth any `u8`. Bit depth (8 or 16).
---@param channels any `u8`. Channel count (1 = mono, 2 = stereo).
---@param buffer_count number `usize?`. Max queued buffer slots (default 4).
---@return number
function luna.audio.newQueueableSource(sample_rate, bit_depth, channels, buffer_count) end

--- Creates a raw PCM audio buffer for building procedurally generated sound.
---@param samples number Total number of PCM samples to allocate.
---@param sampleRate any Sample rate in Hz (e.g. 44100).
---@param bitDepth any Bit depth per sample (8 or 16).
---@param channels number Number of channels (1 = mono, 2 = stereo).
---@return number
function luna.audio.newSoundData(samples, sampleRate, bitDepth, channels) end

--- Loads an audio file and returns a source handle.
---@param args any
---@return any
function luna.audio.newSource(args) end

--- Pauses the audio source at its current position.
---@param id_val any
function luna.audio.pause(id_val) end

--- Pauses all currently playing audio sources.
function luna.audio.pauseAll() end

--- Plays the audio source from the beginning.
---@param id_val any
---@param options? any (optional)
function luna.audio.play(id_val, options) end

--- Plays the audio source in a continuous loop.
---@param id_val any
function luna.audio.playLooping(id_val) end

--- Starts playback of a queueable source. PCM output is driven by queued buffers.
---@param qsource_id number integer returned by `newQueueableSource`.
function luna.audio.playQueueable(qsource_id) end

--- Pushes a SoundData buffer into a queueable source.
---@param qsource_id number integer returned by `newQueueableSource`.
---@param sounddata SoundData `SoundData` userdata with the PCM samples to enqueue.
function luna.audio.queueSource(qsource_id, sounddata) end

--- Releases the audio source and frees its memory.
---@param id_val any
---@return boolean
function luna.audio.release(id_val) end

---@param bus_name any
---@param effect_id any
function luna.audio.remove_effect(bus_name, effect_id) end

--- Resumes playback of a paused audio source from its current position.
---@param source number Audio source ID to resume.
function luna.audio.resume(source) end

--- Resumes playback on every audio source that is currently paused.
function luna.audio.resumeAll() end

--- Seeks to the given time position (in seconds) in the source.
---@param id_val any
---@param pos any
function luna.audio.seek(id_val, pos) end

--- Sets the distance attenuation model.
---@param model any
function luna.audio.setDistanceModel(model) end

--- Sets the global Doppler effect scale (1.0 = default).
---@param scale any
function luna.audio.setDopplerScale(scale) end

--- Applies a high-pass filter to the audio source.
---@param id_val any
---@param cutoff_hz any
function luna.audio.setHighpass(id_val, cutoff_hz) end

--- Sets the 3D listener position for spatial audio.
---@param x any
---@param y any
---@param z? any (optional)
function luna.audio.setListener(x, y, z) end

--- Sets the 2D listener position for spatial audio.
---@param x any
---@param y any
function luna.audio.setListener2D(x, y) end

--- Enables or disables looping playback for the source.
---@param id_val any
---@param looping any
function luna.audio.setLooping(id_val, looping) end

--- Applies a low-pass filter to the audio source.
---@param id_val any
---@param cutoff_hz any
function luna.audio.setLowpass(id_val, cutoff_hz) end

--- Sets the global master volume (0.0 - 1.0).
---@param vol any
function luna.audio.setMasterVolume(vol) end

--- Enables or disables peak metering on the audio source.
---@param scale any
function luna.audio.setMeter(scale) end

--- Sets the SoundFont (.sf2) file that the MIDI synthesizer uses for instrument samples.
---@param path string File path to the .sf2 SoundFont file.
function luna.audio.setMidiSoundFont(path) end

--- Sets the orientation of an audio source.
---@param id_val any
---@param fx any
---@param fy any
---@param fz any
---@param ux any
---@param uy any
---@param uz any
function luna.audio.setOrientation(id_val, fx, fy, fz, ux, uy, uz) end

--- Sets the stereo panning (-1.0 left to 1.0 right) of the source.
---@param id_val any
---@param pan any
function luna.audio.setPan(id_val, pan) end

--- Sets the pitch (playback speed) multiplier of the source.
---@param id_val any
---@param pitch any
function luna.audio.setPitch(id_val, pitch) end

--- Selects the audio output device by name.
---@param name string `string`. Device name to activate.
function luna.audio.setPlaybackDevice(name) end

--- Sets the 3D position of an audio source for spatial panning.
---@param id_val any
---@param x any
---@param y any
---@param z? any (optional)
function luna.audio.setPosition(id_val, x, y, z) end

--- Assigns the source to a named audio bus.
---@param id_val any
---@param bus_val any
function luna.audio.setSourceBus(id_val, bus_val) end

--- Sets the velocity of an audio source for Doppler calculation.
---@param id_val any
---@param x any
---@param y any
---@param z? any (optional)
function luna.audio.setVelocity(id_val, x, y, z) end

--- Sets the playback volume (0.0 - 1.0) of the source.
---@param id_val any
---@param vol any
function luna.audio.setVolume(id_val, vol) end

---@param name any
---@param volume any
function luna.audio.set_bus_volume(name, volume) end

---@param bus_name any
---@param effect_id any
---@param param_name any
---@param value any
function luna.audio.set_effect_param(bus_name, effect_id, param_name, value) end

--- Stops playback of the audio source.
---@param id_val any
function luna.audio.stop(id_val) end

--- Stops all currently playing audio sources.
function luna.audio.stopAll() end

--- Stops playback and drains all queued buffers in a queueable source.
---@param qsource_id number integer returned by `newQueueableSource`.
function luna.audio.stopQueueable(qsource_id) end

--- Returns the current playback position in seconds.
---@param id_val any
---@return any
function luna.audio.tell(id_val) end

---@class luna.automation
luna.automation = {}

function luna.automation.getCurrentScript() end

function luna.automation.getCurrentStep() end

function luna.automation.getElapsedTime() end

function luna.automation.getScripts() end

function luna.automation.getStepCount() end

---@param name any
function luna.automation.hasScript(name) end

function luna.automation.isComplete() end

function luna.automation.isPaused() end

function luna.automation.isRunning() end

---@param name any
---@param data any
function luna.automation.load(name, data) end

function luna.automation.pause() end

function luna.automation.resume() end

---@param name any
function luna.automation.start(name) end

function luna.automation.stop() end

---@param name any
function luna.automation.unload(name) end

---@param dt any
function luna.automation.update(dt) end

---@class luna.camera
luna.camera = {}

--- Lua UserData wrapper for a [`Camera2D`] instance.
---@class Camera2D
local Camera2D = {}

--- Clears the follow target (camera stops tracking).
function Camera2D:clearTarget() end

--- Returns the camera's world-space position as `x, y`.
---@return number
function Camera2D:getPosition() end

--- Returns the rotation in radians.
---@return number
function Camera2D:getRotation() end

--- Returns the current viewport as `x, y, w, h`.
---@return number
function Camera2D:getViewport() end

--- Returns the visible world area as `x, y, w, h`.
---@return number
function Camera2D:getVisibleArea() end

--- Returns the current zoom factor.
---@return number
function Camera2D:getZoom() end

--- Instantly moves the camera to look at `(x, y)`.
---@param x any
---@param y any
function Camera2D:lookAt(x, y) end

--- Translates the camera by `(dx, dy)` in world space.
---@param dx any
---@param dy any
function Camera2D:move(dx, dy) end

--- Removes previously set world-space bounds.
function Camera2D:removeBounds() end

--- Sets world-space bounds for camera clamping.
---@param x any
---@param y any
---@param w any
---@param h any
function Camera2D:setBounds(x, y, w, h) end

--- Sets the dead zone half-extents `(w, h)`. The camera does not move
---@param w any
---@param h any
function Camera2D:setDeadZone(w, h) end

--- Sets the follow smooth interpolation speed (`0.0` = instant snap).
---@param speed any
function Camera2D:setFollowSmooth(speed) end

--- Sets the look-ahead multiplier.
---@param mul any
function Camera2D:setLookAhead(mul) end

--- Sets the camera's world-space position.
---@param x any
---@param y any
function Camera2D:setPosition(x, y) end

--- Sets the rotation in radians.
---@param r any
function Camera2D:setRotation(r) end

--- Sets the follow target position.
---@param x any
---@param y any
function Camera2D:setTarget(x, y) end

--- Sets the viewport rectangle `(x, y, width, height)` in screen pixels.
---@param x any
---@param y any
---@param w any
---@param h any
function Camera2D:setViewport(x, y, w, h) end

--- Sets the uniform zoom factor (`1.0` = natural size).
---@param zoom any
function Camera2D:setZoom(zoom) end

--- Starts a screen-shake effect.
---@param intensity any
---@param duration any
function Camera2D:shake(intensity, duration) end

--- Converts world coordinates to screen coordinates.
---@param wx any
---@param wy any
---@return number
function Camera2D:toScreen(wx, wy) end

--- Converts screen coordinates to world coordinates.
---@param sx any
---@param sy any
---@return number
function Camera2D:toWorld(sx, sy) end

--- Advances the camera simulation by `dt` seconds.
---@param dt any
function Camera2D:update(dt) end

--- Creates a new [`Camera2D`] with the given viewport dimensions.
---@param vw any
---@param vh any
---@return Camera2D
function luna.camera.new(vw, vh) end

---@class luna.compute
luna.compute = {}

---@class mlua
local mlua = {}

--- Abs on this Object.
---@return any
function mlua:abs() end

--- All on this Object.
---@param axis? number `integer` optional.
---@return any
function mlua:all(axis) end

--- Any on this Object.
---@param axis? number `integer` optional.
---@return any
function mlua:any(axis) end

--- Argmax on this Object.
---@param axis? number `integer` optional.
---@return any
function mlua:argmax(axis) end

--- Argmin on this Object.
---@return any
function mlua:argmin() end

--- Bitwise and on this Object.
---@param other any `userdata`.
function mlua:bitwiseAnd(other) end

--- Bitwise l shift on this Object.
---@param amount number `integer`.
function mlua:bitwiseLShift(amount) end

--- Bitwise not on this Object.
---@param amount number `integer`.
function mlua:bitwiseNot(amount) end

--- Bitwise or on this Object.
---@param other any `userdata`.
function mlua:bitwiseOr(other) end

--- Bitwise r shift on this Object.
---@param amount number `integer`.
function mlua:bitwiseRShift(amount) end

--- Bitwise xor on this Object.
---@param other any `userdata`.
function mlua:bitwiseXor(other) end

--- Clamps the value within the allowed range.
---@param min number `number`.
---@param max number `number`.
function mlua:clamp(min, max) end

--- Returns a deep copy of this object.
---@param val number `number`.
function mlua:clone(val) end

--- Convolve2 d on this Object.
---@param kernel any `userdata`.
function mlua:convolve2D(kernel) end

--- Returns the number of non zero.
---@return number
function mlua:countNonZero() end

--- Dilate on this Object.
---@param radius number `integer`.
function mlua:dilate(radius) end

--- Dot on this Object.
---@param other any `userdata`.
function mlua:dot(other) end

--- Erode on this Object.
---@param row number `integer`.
---@param col number `integer`.
---@param val number `number`.
function mlua:erode(row, col, val) end

--- Fill on this Object.
---@param val number `number`.
function mlua:fill(val) end

--- Returns the current value.
---@param args any `LuaMultiValue`.
---@return any
function mlua:get(args) end

--- Returns the data type.
---@param args any `LuaMultiValue`.
---@return number
function mlua:getDataType(args) end

--- Returns the dimensions.
---@return any
function mlua:getDimensions() end

--- Returns the shape.
---@return any
function mlua:getShape() end

--- Returns the size.
---@return integer
function mlua:getSize() end

--- Returns `true` if on g p u.
---@param args any `LuaMultiValue`.
---@return boolean
function mlua:isOnGPU(args) end

--- Matmul on this Object.
---@param other any `userdata`.
function mlua:matmul(other) end

--- Max on this Object.
---@param axis? number `integer` optional.
---@return any
function mlua:max(axis) end

--- Mean on this Object.
---@param axis? number `integer` optional.
---@return any
function mlua:mean(axis) end

--- Min on this Object.
---@param axis? number `integer` optional.
---@return any
function mlua:min(axis) end

--- Neg on this Object.
---@param min number `number`.
---@param max number `number`.
function mlua:neg(min, max) end

--- Pow on this Object.
---@param exp number `number`.
function mlua:pow(exp) end

--- Reshape on this Object.
---@param shape number `any`.
function mlua:reshape(shape) end

--- Sets the value.
---@param args any `LuaMultiValue`.
function mlua:set(args) end

--- Sqrt on this Object.
---@return any
function mlua:sqrt() end

--- Sum on this Object.
---@param axis? number `integer` optional.
---@return any
function mlua:sum(axis) end

--- Threshold on this Object.
---@param mask any `userdata`.
---@param other any `userdata`.
function mlua:threshold(mask, other) end

--- To table on this Object.
---@return any
function mlua:toTable() end

--- Transpose on this Object.
---@param val number `number`.
function mlua:transpose(val) end

--- From table.
---@param tbl any
---@param shape? any (optional)
---@param dtype? any (optional)
function luna.compute.fromTable(tbl, shape, dtype) end

--- New array.
---@param shape any
---@param dtype? any (optional)
function luna.compute.newArray(shape, dtype) end

--- Ones.
---@param shape any
---@param dtype? any (optional)
function luna.compute.ones(shape, dtype) end

--- Range.
---@param start any
---@param stop any
---@param step? any (optional)
---@param dtype? any (optional)
function luna.compute.range(start, stop, step, dtype) end

--- Zeros.
---@param shape any
---@param dtype? any (optional)
function luna.compute.zeros(shape, dtype) end

---@class luna.data
luna.data = {}

---@class DataView
local DataView = {}

---@param offset any
function DataView:getDouble(offset) end

---@param offset any
function DataView:getFloat(offset) end

---@param offset any
function DataView:getInt16(offset) end

---@param offset any
function DataView:getInt32(offset) end

---@param offset any
function DataView:getInt8(offset) end

function DataView:getSize() end

---@param offset any
function DataView:getUInt16(offset) end

---@param offset any
function DataView:getUInt32(offset) end

---@param offset any
function DataView:getUInt8(offset) end

--- Compresses data using the given algorithm (''deflate'', ''gzip'', ''lz4'').
---@param format_str any
---@param raw_data any
---@param level? any (optional)
---@return any
function luna.data.compress(format_str, raw_data, level) end

--- Decodes encoded text back to binary using the given format (''base64'', ''hex'').
---@param format_str any
---@param encoded any
---@return any
function luna.data.decode(format_str, encoded) end

--- Decompresses data using the given algorithm (''deflate'', ''gzip'', ''lz4'').
---@param format_str any
---@param compressed_data any
---@return any
function luna.data.decompress(format_str, compressed_data) end

--- Encodes binary data using the given format (''base64'', ''hex'').
---@param format_str any
---@param raw_data any
---@return any
function luna.data.encode(format_str, raw_data) end

--- Encodes a Lua table as a TOML string.
---@param tbl any
---@return any
function luna.data.encodeToml(tbl) end

--- Returns the number of bytes the given format and values would occupy.
---@param fmt any
---@param vals any
---@return any
function luna.data.getPackedSize(fmt, vals) end

--- Returns the cryptographic hash (md5, sha1, sha256, sha512) of the input.
---@param algo_str any
---@param raw_data any
---@return any
function luna.data.hash(algo_str, raw_data) end

--- Creates a new mutable byte buffer of the given size or from a string.
---@param value any
function luna.data.newByteData(value) end

--- Creates a read-only windowed view into a byte string.
---@param raw any
---@param offset? any (optional)
---@param size? any (optional)
---@return any
function luna.data.newDataView(raw, offset, size) end

--- Packs values into a binary byte string using the LÖVE2D format string.
---@param fmt any
---@param vals any
---@return any
function luna.data.pack(fmt, vals) end

--- Parses a TOML string and returns a Lua table representation.
---@param toml_string any
---@return any
function luna.data.parseToml(toml_string) end

--- Reads values using the Luna2D Binary Pack Format.
---@param fmt any
---@param raw any
---@param offset? any (optional)
---@return any
function luna.data.read(fmt, raw, offset) end

--- Returns the byte size of a Luna2D Binary Pack Format string.
---@param fmt any
---@return integer
function luna.data.size(fmt) end

--- Unpacks values from a LÖVE2D-format binary byte string.
---@param fmt any
---@param raw any
---@param offset? any (optional)
---@return any
function luna.data.unpack(fmt, raw, offset) end

--- Writes values using the Luna2D Binary Pack Format (space-separated type tokens).
---@param fmt any
---@param vals any
---@return any
function luna.data.write(fmt, vals) end

---@class luna.dataframe
luna.dataframe = {}

---@class DataFrame
local DataFrame = {}

--- Adds row to the collection.
---@param row_tbl? table `table` optional.
---@return any
function DataFrame:addRow(row_tbl) end

--- Returns a deep copy of this object.
---@return any
function DataFrame:clone() end

--- Columns on this DataFrame.
---@return table
function DataFrame:columns() end

--- Returns the number of items.
---@param name string `string`.
---@param default? number `any` optional.
---@return number
function DataFrame:count(name, default) end

--- Returns the number of by.
---@param col number `any`.
---@return number
function DataFrame:countBy(col) end

--- Describe on this DataFrame.
---@param col number `any`.
---@return any
function DataFrame:describe(col) end

--- Drop nil on this DataFrame.
---@param n number `integer`.
---@param seed? number `integer` optional.
---@return any
function DataFrame:dropNil(n, seed) end

--- Fill nil on this DataFrame.
---@param col number `any`.
---@param val number `any`.
function DataFrame:fillNil(col, val) end

--- Returns the column.
---@param col number `any`.
---@return table
function DataFrame:getColumn(col) end

--- Returns the row.
---@param row number `integer`.
---@return table
function DataFrame:getRow(row) end

--- Returns the value.
---@param row number `integer`.
---@param col number `any`.
---@return any
function DataFrame:getValue(row, col) end

--- Group by on this DataFrame.
---@param col number `any`.
---@return table
function DataFrame:groupBy(col) end

--- Head on this DataFrame.
---@param n? number `integer` optional.
---@return any
function DataFrame:head(n) end

--- Max on this DataFrame.
---@param col number `any`.
function DataFrame:max(col) end

--- Mean on this DataFrame.
---@param col number `any`.
function DataFrame:mean(col) end

--- Median on this DataFrame.
---@param col number `any`.
function DataFrame:median(col) end

--- Merge on this DataFrame.
---@param other any `userdata`.
function DataFrame:merge(other) end

--- Min on this DataFrame.
---@param col number `any`.
function DataFrame:min(col) end

--- Ncols on this DataFrame.
---@return any
function DataFrame:ncols() end

--- Nrows on this DataFrame.
---@return any
function DataFrame:nrows() end

--- Runs a query and returns matching results.
---@param sql_str string `string`.
---@return any
function DataFrame:query(sql_str) end

--- Removes column from the collection.
---@param col number `any`.
function DataFrame:removeColumn(col) end

--- Removes row from the collection.
---@param row number `integer`.
function DataFrame:removeRow(row) end

--- Rename on this DataFrame.
---@param col number `any`.
---@param new_name string `string`.
function DataFrame:rename(col, new_name) end

--- Sample on this DataFrame.
---@param n number `integer`.
---@param seed? number `integer` optional.
---@return any
function DataFrame:sample(n, seed) end

--- Returns filtered rows or items matching the query.
---@param cols any `LuaMultiValue`.
---@return any
function DataFrame:select(cols) end

--- Slice on this DataFrame.
---@param start number `integer`.
---@param end number `integer`.
---@return any
function DataFrame:slice(start, end) end

--- Stddev on this DataFrame.
---@param col number `any`.
function DataFrame:stddev(col) end

--- Sum on this DataFrame.
---@param col number `any`.
function DataFrame:sum(col) end

--- Tail on this DataFrame.
---@param start number `integer`.
---@param end number `integer`.
---@return any
function DataFrame:tail(start, end) end

--- To binary on this DataFrame.
---@return any
function DataFrame:toBinary() end

--- To c s v on this DataFrame.
---@return any
function DataFrame:toCSV() end

--- To j s o n on this DataFrame.
---@return any
function DataFrame:toJSON() end

--- To string on this DataFrame.
---@param sql_str string `string`.
---@return any
function DataFrame:toString(sql_str) end

--- To table on this DataFrame.
---@return table
function DataFrame:toTable() end

--- Unique on this DataFrame.
---@param col number `any`.
---@return table
function DataFrame:unique(col) end

--- Variance on this DataFrame.
---@param col number `any`.
function DataFrame:variance(col) end

---@class Database
local Database = {}

--- Removes all entries.
---@param other any `userdata`.
function Database:clear(other) end

--- Returns the table.
---@param name string `string`.
---@return table
function Database:getTable(name) end

--- Returns `true` if table.
---@param name string `string`.
---@return boolean
function Database:hasTable(name) end

--- List tables on this Database.
---@return table
function Database:listTables() end

--- Merge on this Database.
---@param other any `userdata`.
function Database:merge(other) end

--- Runs a query and returns matching results.
---@param sql_str string `string`.
---@return any
function Database:query(sql_str) end

--- Removes table from the collection.
---@param name string `string`.
function Database:removeTable(name) end

--- Table count on this Database.
---@return any
function Database:tableCount() end

--- To j s o n on this Database.
---@return any
function Database:toJSON() end

--- From binary.
---@param s any
---@return any
function luna.dataframe.fromBinary(s) end

--- From csv.
---@param s any
---@return any
function luna.dataframe.fromCSV(s) end

--- From json.
---@param s any
---@return any
function luna.dataframe.fromJSON(s) end

--- From table.
---@param tbl any
---@return any
function luna.dataframe.fromTable(tbl) end

--- New data frame.
---@return any
function luna.dataframe.newDataFrame() end

--- New database.
---@return any
function luna.dataframe.newDatabase() end

--- Random.
---@param defs_tbl any
---@param n any
---@param seed? any (optional)
---@return any
function luna.dataframe.random(defs_tbl, n, seed) end

---@class luna.debug
luna.debug = {}

--- Clears all log history.
function luna.debug.clearLog() end

--- Clears all watched paths.
function luna.debug.clearWatches() end

--- Evaluates a Lua string and returns success flag plus results.
---@param code any
---@return any
function luna.debug.eval(code) end

--- Returns the Lua call stack as a table of stack frames.
---@param max_depth? any (optional)
---@return any
function luna.debug.getCallStack(max_depth) end

--- Returns the raw frame time history.
---@return table
function luna.debug.getFrameHistory() end

--- Returns the current frame history buffer size.
---@return boolean
function luna.debug.getFrameHistorySize() end

--- Returns computed frame statistics.
function luna.debug.getFrameStats() end

--- Returns whether console output is enabled.
function luna.debug.getLogConsole() end

--- Returns the current log file path.
---@return table
function luna.debug.getLogFile() end

--- Returns the last `count` log entries (default all).
---@param count? any (optional)
---@return table
function luna.debug.getLogHistory(count) end

--- Returns the current minimum log level.
function luna.debug.getLogLevel() end

--- Returns zone data for a specific frame (0 = most recent).
---@param frame? any (optional)
---@return table
function luna.debug.getProfileData(frame) end

--- Returns the number of retained profile frames.
---@return table
function luna.debug.getProfileFrameCount() end

--- Returns the current watch interval.
function luna.debug.getWatchInterval() end

--- Returns all watched file paths.
---@return table
function luna.debug.getWatchedPaths() end

--- Returns whether the console is considered open.
function luna.debug.isConsoleOpen() end

--- Returns whether the profiler is enabled.
function luna.debug.isProfilingEnabled() end

--- Log at any level with optional source/line info.
---@param level any
---@param message any
function luna.debug.log(level, message) end

--- Opens a console window (no-op on non-Windows).
---@return boolean
function luna.debug.openConsole() end

--- Seals the current frame of profiling data.
function luna.debug.profileFrame() end

--- Ends the most recent timing zone.
---@param name? any (optional)
function luna.debug.profilePop(name) end

--- Starts a named timing zone.
---@param name any
function luna.debug.profilePush(name) end

--- Records a frame time sample.
---@param dt_val any
function luna.debug.recordFrameTime(dt_val) end

--- Clears all profiling state.
function luna.debug.resetProfile() end

--- Scans watched files and returns paths whose modification time changed.
---@return table
function luna.debug.scan() end

--- Sets the maximum frame history buffer size (clamped 10–10000).
---@param size any
function luna.debug.setFrameHistorySize(size) end

--- Toggles stderr console output.
---@param enabled any
function luna.debug.setLogConsole(enabled) end

--- Sets the log file path. Empty string disables file logging.
---@param path any
function luna.debug.setLogFile(path) end

--- Sets the minimum log level to record.
---@param level any
function luna.debug.setLogLevel(level) end

--- Enables or disables the profiler.
---@param enabled any
function luna.debug.setProfilingEnabled(enabled) end

--- Sets the advisory watch interval in seconds.
---@param interval any
function luna.debug.setWatchInterval(interval) end

--- Removes a file from the watch list.
---@param path any
---@return boolean
function luna.debug.unwatch(path) end

--- Registers a file path for modification-time polling.
---@param path any
---@return boolean
function luna.debug.watch(path) end

---@class luna.debugbridge
luna.debugbridge = {}

--- Broadcasts a JSON event to all connected clients.
---@param event any
---@param json_data any
function luna.debugbridge.broadcast(event, json_data) end

--- Captures a print message and broadcasts it to connected clients.
---@param msg any
---@param source? any (optional)
---@param line? any (optional)
function luna.debugbridge.capturePrint(msg, source, line) end

--- Clears the print history.
function luna.debugbridge.clearPrintHistory() end

--- Returns the number of connected TCP clients.
---@return any
function luna.debugbridge.getClientCount() end

--- Returns performance statistics.
---@return table
function luna.debugbridge.getPerformance() end

--- Returns the server port (0 if not running).
---@return any
function luna.debugbridge.getPort() end

--- Returns the print history.
---@param count? any (optional)
---@return table
function luna.debugbridge.getPrintHistory(count) end

--- Returns whether the server is currently running.
---@return any
function luna.debugbridge.isRunning() end

--- Returns whether a screenshot is currently requested.
---@return any
function luna.debugbridge.isScreenshotRequested() end

--- Poll for pending Lua-dependent requests from TCP clients.
---@return any
function luna.debugbridge.poll() end

--- Records a frame time sample.
---@param dt any
function luna.debugbridge.recordFrame(dt) end

--- Flags a screenshot request for the next frame.
---@param scale? any (optional)
function luna.debugbridge.requestScreenshot(scale) end

--- Sets the maximum print history size.
---@param max any
function luna.debugbridge.setMaxPrintHistory(max) end

--- Start the TCP debug server on 127.0.0.1:port.
---@param port? any (optional)
---@return boolean
function luna.debugbridge.start(port) end

--- Stop the TCP debug server and close all connections.
function luna.debugbridge.stop() end

---@class luna.docs
luna.docs = {}

---@class ApiCatalog
local ApiCatalog = {}

--- Entry count on this Object.
---@param module? string `string` optional.
---@return any
function ApiCatalog:entryCount(module) end

--- Returns a filtered subset.
---@param predicate function `function`.
---@return any
function ApiCatalog:filter(predicate) end

--- Returns the entries.
---@param module? string `string` optional.
---@return table
function ApiCatalog:getEntries(module) end

--- Returns the entry.
---@param qualified_name string `string`.
---@return number
function ApiCatalog:getEntry(qualified_name) end

--- Returns the modules.
---@return table
function ApiCatalog:getModules() end

--- Returns the type methods.
---@param qualified_name string `string`.
---@return number
function ApiCatalog:getTypeMethods(qualified_name) end

--- Returns the types.
---@param module_name string `string`.
---@return number
function ApiCatalog:getTypes(module_name) end

--- Merge on this Object.
---@param other any `userdata`.
---@return any
function ApiCatalog:merge(other) end

--- Search on this Object.
---@param query string `string`.
---@return table
function ApiCatalog:search(query) end

--- To j s o n on this Object.
---@return any
function ApiCatalog:toJSON() end

--- To table on this Object.
---@return table
function ApiCatalog:toTable() end

---@class DocEntry
local DocEntry = {}

--- Returns the deprecated.
---@return any
function DocEntry:getDeprecated() end

--- Returns the description.
---@return any
function DocEntry:getDescription() end

--- Returns the example.
---@return number
function DocEntry:getExample() end

--- Returns the kind.
---@return any
function DocEntry:getKind() end

--- Returns the module.
---@return any
function DocEntry:getModule() end

--- Returns the name.
---@return any
function DocEntry:getName() end

--- Returns the parameters.
---@return table
function DocEntry:getParameters() end

--- Returns the qualified name.
---@return any
function DocEntry:getQualifiedName() end

--- Returns the returns.
---@return table
function DocEntry:getReturns() end

--- Returns the score.
---@return any
function DocEntry:getScore() end

--- Returns the since.
---@return any
function DocEntry:getSince() end

--- Returns `true` if description.
---@return boolean
function DocEntry:hasDescription() end

--- Returns `true` if example.
---@return boolean
function DocEntry:hasExample() end

--- Returns `true` if parameters.
---@return boolean
function DocEntry:hasParameters() end

--- Returns `true` if return type.
---@return boolean
function DocEntry:hasReturnType() end

---@class QualityReport
local QualityReport = {}

--- Returns the best.
---@param count? number `integer` optional.
---@return table
function QualityReport:getBest(count) end

--- Returns the by grade.
---@param grade string `string`.
---@return number
function QualityReport:getByGrade(grade) end

--- Returns the grade.
---@return any
function QualityReport:getGrade() end

--- Returns the module scores.
---@param count? number `integer` optional.
---@return table
function QualityReport:getModuleScores(count) end

--- Returns the overall score.
---@return any
function QualityReport:getOverallScore() end

--- Returns the summary.
---@return number
function QualityReport:getSummary() end

--- Returns the worst.
---@param count? number `integer` optional.
---@return table
function QualityReport:getWorst(count) end

--- To j s o n on this Object.
---@return any
function QualityReport:toJSON() end

--- To table on this Object.
---@return table
function QualityReport:toTable() end

---@class ValidationReport
local ValidationReport = {}

--- Returns the incomplete.
---@return table
function ValidationReport:getIncomplete() end

--- Returns the missing.
---@return table
function ValidationReport:getMissing() end

--- Returns the phantom.
---@return table
function ValidationReport:getPhantom() end

--- Returns the summary.
---@return number
function ValidationReport:getSummary() end

--- Incomplete count on this Object.
---@return integer
function ValidationReport:incompleteCount() end

--- Returns `true` if valid.
---@return boolean
function ValidationReport:isValid() end

--- Missing count on this Object.
---@return integer
function ValidationReport:missingCount() end

--- Phantom count on this Object.
---@return integer
function ValidationReport:phantomCount() end

--- To j s o n on this Object.
---@return any
function ValidationReport:toJSON() end

--- To table on this Object.
---@return table
function ValidationReport:toTable() end

--- Compare catalog timestamps against source files.
---@param catalog_ud any
---@param source_dir any
---@return table
function luna.docs.checkStaleness(catalog_ud, source_dir) end

--- Coverage: (documented, total).
---@param catalog_ud? any (optional)
---@return any
function luna.docs.coverage(catalog_ud) end

--- Module-level coverage.
---@param module_name any
---@param catalog_ud? any (optional)
---@return any
function luna.docs.coverageModule(module_name, catalog_ud) end

--- Inject a description for an API entry.
---@param qualified_name any
---@param description any
function luna.docs.describe(qualified_name, description) end

--- Export all three files to a directory.
---@param catalog_ud any
---@param output_dir any
function luna.docs.exportAll(catalog_ud, output_dir) end

--- Export one-line-per-function cheatsheet.
---@param catalog_ud any
---@param path any
function luna.docs.exportCheatsheet(catalog_ud, path) end

--- Export completions JSON for VS Code IntelliSense.
---@param catalog_ud any
---@param path any
function luna.docs.exportCompletions(catalog_ud, path) end

--- Export hover JSON.
---@param catalog_ud any
---@param path any
function luna.docs.exportHover(catalog_ud, path) end

--- Export markdown API reference.
---@param catalog_ud any
---@param path any
function luna.docs.exportMarkdown(catalog_ud, path) end

--- Export signatures JSON.
---@param catalog_ud any
---@param path any
function luna.docs.exportSignatures(catalog_ud, path) end

--- Get the current internal catalog.
function luna.docs.getCatalog() end

--- Load all .toml files in a directory and merge.
---@param directory any
---@return any
function luna.docs.loadAll(directory) end

--- Load a TOML doc file into an ApiCatalog.
---@param path any
---@return any
function luna.docs.loadToml(path) end

--- Calculate quality metrics for a catalog.
---@param catalog_ud? any (optional)
---@return any
function luna.docs.quality(catalog_ud) end

--- Quality for a single module.
---@param module_name any
---@param catalog_ud? any (optional)
---@return any
function luna.docs.qualityModule(module_name, catalog_ud) end

--- Reset the internal catalog.
function luna.docs.resetCatalog() end

--- Scan the luna.* namespace to build an API catalog from live bindings.
---@param opts? any (optional)
---@return any
function luna.docs.scan(opts) end

--- Scan a single module's bindings.
---@param module_name any
---@return any
function luna.docs.scanModule(module_name) end

--- Set parameter info for an entry.
---@param qualified_name any
---@param params any
function luna.docs.setParamInfo(qualified_name, params) end

--- Set return type info for an entry.
---@param qualified_name any
---@param returns any
function luna.docs.setReturnInfo(qualified_name, returns) end

--- Validate catalog completeness against live bindings.
---@param catalog_ud? any (optional)
---@return any
function luna.docs.validate(catalog_ud) end

--- Validate a single module.
---@param module_name any
---@param catalog_ud? any (optional)
---@return any
function luna.docs.validateModule(module_name, catalog_ud) end

---@class luna.entity
luna.entity = {}

---@class Universe
local Universe = {}

--- Adds system to the collection.
---@param system table `table`.
function Universe:addSystem(system) end

--- Attaches a string tag to the entity, enabling fast tag-based group queries.
---@param id number `integer`: Entity ID.
---@param tag string `string`: Tag label to add.
function Universe:addTag(id, tag) end

--- Bitmap tag on this Universe.
---@param id number `integer`.
---@param name string `string`.
function Universe:bitmapTag(id, name) end

--- Bitmap untag on this Universe.
---@param id number `integer`.
---@param name string `string`.
function Universe:bitmapUntag(id, name) end

--- Removes all entries.
---@return any
function Universe:clear() end

--- Define tag on this Universe.
---@param id number `integer`.
---@param name string `string`.
function Universe:defineTag(id, name) end

--- Draws to the current render target.
---@return any
function Universe:draw() end

--- Emits an event.
---@param args any `LuaMultiValue`.
function Universe:emit(args) end

--- Returns the current value.
---@param id number `integer`.
---@param name string `string`.
---@return any
function Universe:get(id, name) end

--- Returns the bitmap tag bit.
---@param name string `string`.
---@return any
function Universe:getBitmapTagBit(name) end

--- Returns the blueprint components.
---@param name string `string`.
---@return number
function Universe:getBlueprintComponents(name) end

--- Returns an array of packed entity IDs for all direct children.
---@param parent_id any
---@return table
function Universe:getChildren(parent_id) end

--- Returns the components.
---@param id number `integer`.
---@return any
function Universe:getComponents(id) end

--- Returns the entities.
---@return any
function Universe:getEntities() end

--- Returns the entities by layer.
---@param layer number `integer`.
---@return number
function Universe:getEntitiesByLayer(layer) end

--- Returns the entities by tag.
---@param id number `integer`.
---@param layer number `integer`.
---@return number
function Universe:getEntitiesByTag(id, layer) end

--- Returns the entities sorted.
---@param name string `string`.
---@return any
function Universe:getEntitiesSorted(name) end

--- Returns the entity count.
---@param system table `table`.
---@return number
function Universe:getEntityCount(system) end

--- Returns the layer.
---@param id number `integer`.
---@return number
function Universe:getLayer(id) end

--- Returns the packed entity ID of the parent, or nil if the entity has no parent.
---@param child_id any
---@return integer|nil
function Universe:getParent(child_id) end

--- Returns the system count.
---@return number
function Universe:getSystemCount() end

--- Returns the tags.
---@param id number `integer`.
---@return any
function Universe:getTags(id) end

--- Returns `true` if the condition is met.
---@param id number `integer`.
---@param name string `string`.
---@return boolean
function Universe:has(id, name) end

--- Returns `true` if bitmap tag.
---@param id number `integer`.
---@param name string `string`.
---@return boolean
function Universe:hasBitmapTag(id, name) end

--- Returns `true` if blueprint.
---@param name string `string`.
---@return boolean
function Universe:hasBlueprint(name) end

--- Returns `true` if the entity carries the given tag.
---@param id number `integer`: Entity ID.
---@param tag string `string`: Tag to test.
---@return boolean
function Universe:hasTag(id, tag) end

--- Returns `true` if the entity `id` is currently active in the universe.
---@param id number `integer`: Entity ID to test.
---@return boolean
function Universe:isAlive(id) end

--- Destroys the entity with the given `id`, freeing its slot for reuse.
---@param id number `integer`: Entity ID returned by `spawn`.
function Universe:kill(id) end

--- Kills an entity and all its descendants recursively (post-order).
---@param id any
function Universe:killRecursive(id) end

--- List blueprints on this Universe.
---@param name string `string`.
function Universe:listBlueprints(name) end

--- Runs a query and returns matching results.
---@param args any `LuaMultiValue`.
function Universe:query(args) end

--- Query bitmap all on this Universe.
---@param names table `table`.
---@return any
function Universe:queryBitmapAll(names) end

--- Query bitmap any on this Universe.
---@param names table `table`.
---@return any
function Universe:queryBitmapAny(names) end

--- Query bitmap tag on this Universe.
---@param name string `string`.
---@return any
function Universe:queryBitmapTag(name) end

--- Releases the underlying resource handle.
---@param id number `integer`.
---@param tag string `string`.
function Universe:release(id, tag) end

--- Removes the entry from the collection.
---@param id number `integer`.
---@param name string `string`.
function Universe:remove(id, name) end

--- Removes blueprint from the collection.
---@param name string `string`.
function Universe:removeBlueprint(name) end

--- Removes system from the collection.
---@param system table `table`.
function Universe:removeSystem(system) end

--- Removes a string tag from the entity.
---@param id number `integer`: Entity ID.
---@param tag string `string`: Tag to remove.
function Universe:removeTag(id, tag) end

--- Sets the layer.
---@param id number `integer`.
---@param layer number `integer`.
function Universe:setLayer(id, layer) end

--- Creates a new entity in this universe and returns its numeric ID.
---@return number
function Universe:spawn() end

--- Advances the simulation by `dt` seconds.
---@param dt number `number`.
function Universe:update(dt) end

--- New universe.
---@return any
function luna.entity.newUniverse() end

---@class luna.event
luna.event = {}

---@class Signal
local Signal = {}

--- Removes all callbacks for the named event.
---@param name any
---@return any
function Signal:clear(name) end

--- Removes all callbacks across all events.
---@return any
function Signal:clearAll() end

--- Emits the named event, calling all registered callbacks in order.
---@param args any
function Signal:emit(args) end

--- Returns the callback count for the named event.
---@param name any
---@return any
function Signal:getCount(name) end

--- Returns the total callback count across all events.
---@return any
function Signal:getTotalCount() end

--- Removes a subscription by handle ID.
---@param handle any
---@return any
function Signal:remove(handle) end

--- Discards all pending events in the queue.
function luna.event.clear() end

--- Event.
---@return any
function luna.event.newSignal() end

--- Polls and returns the next event from the queue, or nil if empty.
---@return any
function luna.event.poll() end

--- Syncs OS-level events into the queue. In Luna2D this is a no-op (push model).
function luna.event.pump() end

--- Pushes a custom event onto the event queue.
---@param args any
function luna.event.push(args) end

--- Pushes a quit event onto the event queue, requesting the engine to stop.
---@param exitcode? number Optional integer exit code (default 0).
function luna.event.quit(exitcode) end

--- Requests that the engine restart at the beginning of the next frame.
---@return any
function luna.event.restart() end

--- Blocks until the next event arrives or the optional timeout elapses.
---@param timeout? number `number?`. Timeout in seconds (optional; omit to wait indefinitely).
---@return any
function luna.event.wait(timeout) end

---@class luna.filesystem
luna.filesystem = {}

---@class FileData
local FileData = {}

--- Returns the virtual path this data was loaded from.
function FileData:getFilename() end

--- Returns the file size in bytes.
function FileData:getSize() end

--- Returns the file content as a Lua string.
function FileData:getString() end

---@class FileHandle
local FileHandle = {}

--- Flushes any pending writes and closes the file handle.
---@return string
function FileHandle:close() end

--- Flushes all buffered writes to disk without closing the handle.
---@return string
function FileHandle:flush() end

--- Returns the access mode the file was opened with.
---@return any
function FileHandle:getMode() end

--- Returns the size of the open file in bytes.
---@return number
function FileHandle:getSize() end

--- Returns whether the read cursor has reached the end of the file.
---@return boolean
function FileHandle:isEOF() end

--- Reads a text file and returns its contents as a string.
---@param count? any (optional)
---@return any
function FileHandle:read(count) end

--- Reads the next line of text from the file and returns it as a string.
---@return string
function FileHandle:readLine() end

--- Seeks the file position to the given byte offset from the start.
---@param offset number Byte position to seek to (0-based).
---@return string
function FileHandle:seek(offset) end

--- Returns the current read/write byte offset from the start of the file.
---@return number
function FileHandle:tell() end

--- Writes a string to a file, creating it if needed.
---@param data any
---@return any
function FileHandle:write(data) end

--- Opens the file in append mode and writes the given string at the end.
---@param path string Relative file path inside the save directory.
---@param data string String to append.
---@return string
function luna.filesystem.append(path, data) end

--- Creates a directory and any missing parent directories.
---@param path any
function luna.filesystem.createDirectory(path) end

--- Returns whether the given file or directory exists.
---@param path any
---@return any
function luna.filesystem.exists(path) end

--- Returns a table containing the names of every file and subdirectory in the given path.
---@param path string Directory path to list.
---@return string
function luna.filesystem.getDirectoryItems(path) end

--- Returns the identity string used to locate the game's sandboxed save directory.
---@return string
function luna.filesystem.getIdentity() end

--- Returns a table of metadata (size, modtime, kind) for a path.
---@param path any
---@return any
function luna.filesystem.getInfo(path) end

--- Returns the sandboxed save data directory path.
---@return any
function luna.filesystem.getSaveDirectory() end

--- Returns the absolute path of the directory or archive the game was loaded from.
---@return string
function luna.filesystem.getSource() end

--- Returns the current user's home directory path.
---@return any
function luna.filesystem.getUserDirectory() end

--- Returns the current working directory path.
function luna.filesystem.getWorkingDirectory() end

--- Returns whether the given path is a directory.
---@param path any
---@return any
function luna.filesystem.isDirectory(path) end

--- Returns whether the given path is a regular file.
---@param path any
---@return any
function luna.filesystem.isFile(path) end

--- Returns an iterator over lines in a text file.
---@param path any
---@return any
function luna.filesystem.lines(path) end

--- Loads and compiles a Lua file from the VFS, returning it as a callable function.
---@param path any
function luna.filesystem.load(path) end

--- Mounts a directory at a virtual path. Returns true on success.
---@param src any
---@param mp any
function luna.filesystem.mount(src, mp) end

--- Loads a file from the VFS into a FileData buffer.
---@param path any
function luna.filesystem.newFileData(path) end

--- Opens a file and returns a readable/writable file handle.
---@param path any
---@param mode_str any
---@return any
function luna.filesystem.openFile(path, mode_str) end

--- Poll an async load handle. Returns status, data-or-nil.
---@param handle_id any
---@return any
function luna.filesystem.pollAsync(handle_id) end

--- Reads a text file and returns its contents as a string.
---@param path any
---@return any
function luna.filesystem.read(path) end

--- Start loading a file in the background. Returns a numeric handle.
---@param path any
---@return any
function luna.filesystem.readAsync(path) end

--- Permanently deletes the file at the given path from the save directory.
---@param path string Relative path to the file to delete.
---@return string
function luna.filesystem.remove(path) end

--- Sets the identity string that names the game's sandboxed save-data directory.
---@param name string Application identity string (e.g. 'mygame').
function luna.filesystem.setIdentity(name) end

--- Removes a virtual mount layer.
---@param mp any
function luna.filesystem.unmount(mp) end

--- Writes a string to a file, creating it if needed.
---@param path any
---@param data any
function luna.filesystem.write(path, data) end

---@class luna.font
luna.font = {}

---@class GlyphData
local GlyphData = {}

--- Returns the horizontal advance width in pixels.
---@return number
function GlyphData:getAdvance() end

--- Returns the horizontal bearing (cursor-to-glyph-edge offset).
---@return number
function GlyphData:getBearingX() end

--- Returns the vertical bearing (baseline-to-glyph-top offset).
---@return number
function GlyphData:getBearingY() end

--- Returns the Unicode code point as an integer.
---@return number
function GlyphData:getGlyph() end

--- Returns the glyph character as a UTF-8 string.
---@return string
function GlyphData:getGlyphString() end

--- Returns the pixel height of the glyph bitmap.
---@return number
function GlyphData:getHeight() end

--- Returns the pixel width of the glyph bitmap.
---@return number
function GlyphData:getWidth() end

--- Stub: BMFont rasterization is not yet supported.
---@param image_file any
---@param glyph_hints any
function luna.font.newBMFontRasterizer(image_file, glyph_hints) end

--- Returns glyph metrics for a given Unicode code point within the font.
---@param font_val any
---@param codepoint any
function luna.font.newGlyphData(font_val, codepoint) end

--- Loads a TTF/OTF font file and returns a font userdata object.
---@param path any
---@param size? any (optional)
function luna.font.newRasterizer(path, size) end

--- Loads a TTF/OTF font with an optional hinting hint (currently ignored).
---@param path any
---@param size? any (optional)
---@param hinting? any (optional)
function luna.font.newTrueTypeRasterizer(path, size, hinting) end

---@class luna.graph
luna.graph = {}

---@class Graph
local Graph = {}

--- Adds edge to the collection.
---@param from_ud any `userdata`.
---@param to_ud any `userdata`.
---@param edge_type? string `string` optional.
---@return any
function Graph:addEdge(from_ud, to_ud, edge_type) end

--- Find path for item on this Graph.
---@param item_ud any `userdata`.
---@param from_ud any `userdata`.
---@param to_ud any `userdata`.
---@return any
function Graph:findPathForItem(item_ud, from_ud, to_ud) end

--- Returns the components.
---@return any
function Graph:getComponents() end

--- Returns the edge count.
---@param from_ud any `userdata`.
---@param to_ud any `userdata`.
---@return any
function Graph:getEdgeCount(from_ud, to_ud) end

--- Returns the edges.
---@return any
function Graph:getEdges() end

--- Returns the item count.
---@param item_ud any `userdata`.
---@param edge_ud any `userdata`.
---@return any
function Graph:getItemCount(item_ud, edge_ud) end

--- Returns the items.
---@return any
function Graph:getItems() end

--- Returns the neighbors.
---@param node_ud any `userdata`.
---@return any
function Graph:getNeighbors(node_ud) end

--- Returns the node count.
---@param from_ud any `userdata`.
---@param to_ud any `userdata`.
---@param edge_type? string `string` optional.
---@return any
function Graph:getNodeCount(from_ud, to_ud, edge_type) end

--- Returns the nodes.
---@return any
function Graph:getNodes() end

--- Returns the stats.
---@return any
function Graph:getStats() end

--- Returns `true` if cycle.
---@return boolean
function Graph:hasCycle() end

--- Returns `true` if edge.
---@param edge_ud any `userdata`.
---@return boolean
function Graph:hasEdge(edge_ud) end

--- Returns `true` if item.
---@param item_ud any `userdata`.
---@return boolean
function Graph:hasItem(item_ud) end

--- Returns `true` if node.
---@param node_ud any `userdata`.
---@return boolean
function Graph:hasNode(node_ud) end

--- Process demand on this Graph.
---@return any
function Graph:processDemand() end

--- Removes edge from the collection.
---@param edge_ud any `userdata`.
---@return any
function Graph:removeEdge(edge_ud) end

--- Removes item from the collection.
---@param item_ud any `userdata`.
---@return any
function Graph:removeItem(item_ud) end

--- Removes node from the collection.
---@param node_ud any `userdata`.
---@return any
function Graph:removeNode(node_ud) end

--- Advances the simulation by one physics step.
---@return any
function Graph:step() end

--- Topological sort on this Graph.
---@return any
function Graph:topologicalSort() end

--- Advances the simulation by `dt` seconds.
---@param dt number `number`.
function Graph:update(dt) end

---@class GraphEdge
local GraphEdge = {}

--- Adds allowed type to the collection.
---@param t string `string`.
function GraphEdge:addAllowedType(t) end

--- Clear allowed types on this Edge.
---@param t string `string`.
function GraphEdge:clearAllowedTypes(t) end

--- Returns the capacity.
---@param c number `integer`.
---@return number
function GraphEdge:getCapacity(c) end

--- Returns the cooldown.
---@param c number `number`.
---@return any
function GraphEdge:getCooldown(c) end

--- Returns the from.
---@return any
function GraphEdge:getFrom() end

--- Returns the items in transit.
---@return any
function GraphEdge:getItemsInTransit() end

--- Returns the speed modifier.
---@param m number `number`.
---@return any
function GraphEdge:getSpeedModifier(m) end

--- Returns the throughput.
---@param t number `number`.
---@return any
function GraphEdge:getThroughput(t) end

--- Returns the to.
---@return any
function GraphEdge:getTo() end

--- Returns the travel time.
---@param t number `number`.
---@return any
function GraphEdge:getTravelTime(t) end

--- Returns the type.
---@param t string `string`.
---@return number
function GraphEdge:getType(t) end

--- Returns the weight.
---@param w number `number`.
---@return any
function GraphEdge:getWeight(w) end

--- Returns `true` if active.
---@param a boolean `boolean`.
---@return boolean
function GraphEdge:isActive(a) end

--- Returns `true` if bidirectional.
---@param b boolean `boolean`.
---@return boolean
function GraphEdge:isBidirectional(b) end

--- Returns `true` if item type allowed.
---@param t string `string`.
---@return boolean
function GraphEdge:isItemTypeAllowed(t) end

--- Returns `true` if on cooldown.
---@param b boolean `boolean`.
---@return boolean
function GraphEdge:isOnCooldown(b) end

--- Removes allowed type from the collection.
---@param t string `string`.
---@return any
function GraphEdge:removeAllowedType(t) end

--- Sets the active.
---@param a boolean `boolean`.
function GraphEdge:setActive(a) end

--- Sets the bidirectional.
---@param b boolean `boolean`.
function GraphEdge:setBidirectional(b) end

--- Sets the capacity.
---@param c number `integer`.
function GraphEdge:setCapacity(c) end

--- Sets the cooldown.
---@param c number `number`.
function GraphEdge:setCooldown(c) end

--- Sets the speed modifier.
---@param m number `number`.
function GraphEdge:setSpeedModifier(m) end

--- Sets the throughput.
---@param t number `number`.
function GraphEdge:setThroughput(t) end

--- Sets the travel time.
---@param t number `number`.
function GraphEdge:setTravelTime(t) end

--- Sets the type.
---@param t string `string`.
function GraphEdge:setType(t) end

--- Sets the weight.
---@param w number `number`.
function GraphEdge:setWeight(w) end

---@class GraphItem
local GraphItem = {}

--- Returns the decay time.
---@param t number `number`.
---@return number
function GraphItem:getDecayTime(t) end

--- Returns the position.
---@return any
function GraphItem:getPosition() end

--- Returns the priority.
---@param p number `integer`.
---@return number
function GraphItem:getPriority(p) end

--- Returns the remaining life.
---@return any
function GraphItem:getRemainingLife() end

--- Returns the type.
---@param t string `string`.
---@return number
function GraphItem:getType(t) end

--- Returns `true` if alive.
---@return boolean
function GraphItem:isAlive() end

--- Kill on this GraphItem.
---@return any
function GraphItem:kill() end

--- Sets the decay time.
---@param t number `number`.
function GraphItem:setDecayTime(t) end

--- Sets the priority.
---@param p number `integer`.
function GraphItem:setPriority(p) end

--- Sets the type.
---@param t string `string`.
function GraphItem:setType(t) end

---@class GraphNode
local GraphNode = {}

--- Adds tag to the collection.
---@param tag string `string`.
function GraphNode:addTag(tag) end

--- Clear all conversions on this Node.
---@return any
function GraphNode:clearAllConversions() end

--- Clear conversion on this Node.
---@param in_type string `string`.
---@return any
function GraphNode:clearConversion(in_type) end

--- Clear demands on this Node.
---@return any
function GraphNode:clearDemands() end

--- Clear supplies on this Node.
---@return any
function GraphNode:clearSupplies() end

--- Clear tags on this Node.
---@return any
function GraphNode:clearTags() end

--- Dequeue on this Node.
---@return any
function GraphNode:dequeue() end

--- Enqueue on this Node.
---@param item_ud any `userdata`.
---@return any
function GraphNode:enqueue(item_ud) end

--- Returns the capacity.
---@param c number `integer`.
---@return number
function GraphNode:getCapacity(c) end

--- Returns the edges.
---@param dir? string `string` optional.
---@return any
function GraphNode:getEdges(dir) end

--- Returns the flow mode.
---@param m string `string`.
---@return string
function GraphNode:getFlowMode(m) end

--- Returns the item count.
---@return any
function GraphNode:getItemCount() end

--- Returns the items.
---@return any
function GraphNode:getItems() end

--- Returns the overflow policy.
---@param p string `string`.
---@return number
function GraphNode:getOverflowPolicy(p) end

--- Returns the process time.
---@param t number `number`.
---@return any
function GraphNode:getProcessTime(t) end

--- Returns the pull filter.
---@param f? string `string` optional.
---@return any
function GraphNode:getPullFilter(f) end

--- Returns the pull rate.
---@param r number `number`.
---@return any
function GraphNode:getPullRate(r) end

--- Returns the push filter.
---@param f? string `string` optional.
---@return any
function GraphNode:getPushFilter(f) end

--- Returns the push rate.
---@param r number `number`.
---@return any
function GraphNode:getPushRate(r) end

--- Returns the queue capacity.
---@param c number `integer`.
---@return number
function GraphNode:getQueueCapacity(c) end

--- Returns the queue size.
---@return integer
function GraphNode:getQueueSize() end

--- Returns the tags.
---@return any
function GraphNode:getTags() end

--- Returns the type.
---@param t string `string`.
---@return number
function GraphNode:getType(t) end

--- Returns `true` if tag.
---@param tag string `string`.
---@return boolean
function GraphNode:hasTag(tag) end

--- Returns `true` if active.
---@param a boolean `boolean`.
---@return boolean
function GraphNode:isActive(a) end

--- Returns `true` if full.
---@param a boolean `boolean`.
---@return boolean
function GraphNode:isFull(a) end

--- Returns `true` if queue enabled.
---@param e boolean `boolean`.
---@return boolean
function GraphNode:isQueueEnabled(e) end

--- Removes demand from the collection.
---@param item_type string `string`.
---@return any
function GraphNode:removeDemand(item_type) end

--- Removes supply from the collection.
---@param item_type string `string`.
---@return any
function GraphNode:removeSupply(item_type) end

--- Removes tag from the collection.
---@param tag string `string`.
---@return any
function GraphNode:removeTag(tag) end

--- Sets the active.
---@param a boolean `boolean`.
function GraphNode:setActive(a) end

--- Sets the capacity.
---@param c number `integer`.
function GraphNode:setCapacity(c) end

--- Sets the flow mode.
---@param m string `string`.
function GraphNode:setFlowMode(m) end

--- Sets the overflow policy.
---@param p string `string`.
function GraphNode:setOverflowPolicy(p) end

--- Sets the process time.
---@param t number `number`.
function GraphNode:setProcessTime(t) end

--- Sets the pull filter.
---@param f? string `string` optional.
function GraphNode:setPullFilter(f) end

--- Sets the pull rate.
---@param r number `number`.
function GraphNode:setPullRate(r) end

--- Sets the push filter.
---@param f? string `string` optional.
function GraphNode:setPushFilter(f) end

--- Sets the push rate.
---@param r number `number`.
function GraphNode:setPushRate(r) end

--- Sets the queue capacity.
---@param c number `integer`.
function GraphNode:setQueueCapacity(c) end

--- Sets the queue enabled.
---@param e boolean `boolean`.
function GraphNode:setQueueEnabled(e) end

--- Sets the type.
---@param t string `string`.
function GraphNode:setType(t) end

--- Creates a new empty directed graph for item flow simulation.
---@return any
function luna.graph.newGraph() end

---@class luna.graphics
luna.graphics = {}

--- Lua UserData wrapper for an off-screen canvas resource.
---@class Canvas
local Canvas = {}

--- Returns the canvas width and height in pixels.
---@return number
---@return number
function Canvas:getDimensions() end

--- Returns the canvas height in pixels.
---@return number
function Canvas:getHeight() end

--- Returns the canvas width in pixels.
---@return number
function Canvas:getWidth() end

--- Lua UserData wrapper for a loaded font resource.
---@class Font
local Font = {}

--- Returns the ascent (distance from baseline to the top of the tallest glyph) in pixels.
---@return number
function Font:getAscent() end

--- Returns the descent (distance below the baseline for descenders) in pixels.
---@return number
function Font:getDescent() end

--- Returns the line height of this font at its loaded size, in pixels.
---@return number
function Font:getHeight() end

--- Returns the line height in pixels used when advancing to the next line of text.
---@return number
function Font:getLineHeight() end

--- Measures the rendered width of `text` using this font's current size.
---@param text string `string`: The string to measure.
---@return number
function Font:getWidth(text) end

--- Sets the line height multiplier used when laying out multi-line text.
---@param height number Line height factor (1.0 = normal, >1.0 = extra spacing).
function Font:setLineHeight(height) end

--- Lua UserData wrapper for a loaded texture resource.
---@class Image
local Image = {}

--- Returns image width and height in pixels.
---@return number
---@return number
function Image:getDimensions() end

--- Returns the current min and mag texture filters.
---@return string
---@return string
function Image:getFilter() end

--- Returns the image height in pixels.
---@return number
function Image:getHeight() end

--- Returns the image width in pixels.
---@return number
function Image:getWidth() end

--- Returns the current texture wrap mode for the horizontal and vertical axes.
---@return string
---@return string
function Image:getWrap() end

--- Lua UserData wrapper for a nine-slice (9-patch) image definition.
---@class NineSlice
local NineSlice = {}

--- Draws to the current render target.
---@param x number `number`.
---@param y number `number`.
---@param w number `number`.
---@param h number `number`.
function NineSlice:draw(x, y, w, h) end

--- Returns the insets.
---@return any
function NineSlice:getInsets() end

--- Returns the texture size.
---@param x number `number`.
---@param y number `number`.
---@param w number `number`.
---@param h number `number`.
---@return number
function NineSlice:getTextureSize(x, y, w, h) end

---@class Shape
local Shape = {}

--- Appends a circle to this shape.
---@param mode any â€” `'fill'` or `'line'`.
---@param x number â€” Centre X in object space.
---@param y number â€” Centre Y in object space.
---@param r number â€” Radius in pixels.
function Shape:circle(mode, x, y, r) end

--- Clears all commands from this shape and resets color and line-width state.
function Shape:clear() end

--- Returns the number of draw commands currently queued in this shape.
---@return number
function Shape:getCommandCount() end

--- Appends a single line segment to this shape.
---@param x1 number â€” Start X in object space.
---@param y1 number â€” Start Y in object space.
---@param x2 number â€” End X in object space.
---@param y2 number â€” End Y in object space.
function Shape:line(x1, y1, x2, y2) end

--- Appends a polygon to this shape from a flat vararg vertex list.
---@param mode any â€” `'fill'` or `'line'`.
---@param x1_y1_x2_y2_ number â€” Flat list of vertex coordinates (at least 6 numbers / 3 vertices).
function Shape:polygon(mode, x1_y1_x2_y2_) end

--- Appends a polyline to this shape from a flat vararg point list.
---@param x1_y1_x2_y2_ number â€” Flat list of point coordinates (at least 4 numbers / 2 points).
function Shape:polyline(x1_y1_x2_y2_) end

--- Sets the active draw color for subsequent commands in this shape.
---@param r any â€” Red component in [0, 1].
---@param g any â€” Green component in [0, 1].
---@param b any â€” Blue component in [0, 1].
---@param a? any â€” Optional alpha component (default 1.0).
function Shape:setColor(r, g, b, a) end

--- Sets the stroke width for outlined primitives that follow in this shape.
---@param w number â€” Line width in pixels (must be > 0).
function Shape:setLineWidth(w) end

--- Lua UserData wrapper for a sprite batch resource.
---@class SpriteBatch
local SpriteBatch = {}

--- Removes all sprites from this batch and resets the sprite count to zero.
function SpriteBatch:clear() end

--- Returns the maximum number of sprites this batch was allocated to hold.
---@return number
function SpriteBatch:getBufferSize() end

--- Returns the number of sprites currently added to this batch.
---@return number
function SpriteBatch:getCount() end

--- Applies the given Transform object to the current transform stack.
function luna.graphics.applyTransform() end

--- Draws a filled or outlined arc segment centered at (x, y) with the given radius.
---@param mode string Draw mode: 'fill' or 'line'.
---@param x number Center X coordinate in pixels.
---@param y number Center Y coordinate in pixels.
---@param radius number Arc radius in pixels.
---@param angle1 number Start angle in radians.
---@param angle2 number End angle in radians.
---@param segments? number Optional number of line segments for smoothness.
function luna.graphics.arc(mode, x, y, radius, angle1, angle2, segments) end

--- Captures the current frame as an `ImageData` and passes it to `callback`.
---@param callback function â€” `function`. Called with one `ImageData` argument.
---@return any
function luna.graphics.captureScreenshot(callback) end

--- Draws a filled or outlined circle centered at (x, y) with the given radius.
---@param mode string Draw mode: 'fill' or 'line'.
---@param x number Center X coordinate in pixels.
---@param y number Center Y coordinate in pixels.
---@param radius number Circle radius in pixels.
---@param segments? number Optional number of line segments (default auto).
function luna.graphics.circle(mode, x, y, radius, segments) end

--- Clears the screen with the current background color.
---@param r? any (optional)
---@param g? any (optional)
---@param b? any (optional)
function luna.graphics.clear(r, g, b) end

--- Resets the stencil mode to the default (keep / always / 0).
function luna.graphics.clearStencil() end

--- Queues draw commands for all live particles.
---@param drawable number â€” `Drawable`. An Image, Canvas, SpriteBatch userdata, or integer image ID.
---@param x number â€” `f32`. Destination X position (default 0).
---@param y number â€” `f32`. Destination Y position (default 0).
---@param r any â€” `f32`. Rotation in radians (default 0).
---@param sx number â€” `f32`. X scale (default 1).
---@param sy number â€” `f32`. Y scale (default 1).
---@param ox number â€” `f32`. X origin offset (default 0).
---@param oy number â€” `f32`. Y origin offset (default 0).
---@return any
function luna.graphics.draw(drawable, x, y, r, sx, sy, ox, oy) end

--- Draws all sprites in a SpriteBatch using a single efficient GPU draw call.
---@param batch number SpriteBatch ID returned by newSpriteBatch.
---@param x? number Optional X offset in pixels.
---@param y? number Optional Y offset in pixels.
function luna.graphics.drawBatch(batch, x, y) end

--- Draws an off-screen canvas to the current render target.
function luna.graphics.drawCanvas() end

--- Draws any drawable object with a full affine transform.
---@param drawable number â€” `Drawable`. An Image, Canvas, SpriteBatch userdata or integer image ID.
---@param x number â€” `f32`. Destination X position.
---@param y number â€” `f32`. Destination Y position.
---@param r any â€” `f32`. Rotation in radians (default 0).
---@param sx number â€” `f32`. X scale (default 1).
---@param sy number â€” `f32`. Y scale (default sx).
---@param ox number â€” `f32`. X origin offset (default 0).
---@param oy number â€” `f32`. Y origin offset (default 0).
---@return any
function luna.graphics.drawEx(drawable, x, y, r, sx, sy, ox, oy) end

--- Draws the given custom Mesh geometry with the current transform and color.
---@param mesh number Mesh ID returned by newMesh.
---@param x? number Optional X position offset in pixels.
---@param y? number Optional Y position offset in pixels.
function luna.graphics.drawMesh(mesh, x, y) end

--- Draws a nine-slice image stretched to fill the given rectangle.
---@param nineslice number NineSlice UserData returned by newNineSlice.
---@param x number Destination X position.
---@param y number Destination Y position.
---@param w number Destination width.
---@param h number Destination height.
function luna.graphics.drawNineSlice(nineslice, x, y, w, h) end

--- Draws a quad region of an image with an affine transform.
function luna.graphics.drawQuad() end

--- Draws a filled or outlined ellipse centered at (x, y) with given horizontal and vertical radii.
---@param mode string Draw mode: 'fill' or 'line'.
---@param x number Center X coordinate in pixels.
---@param y number Center Y coordinate in pixels.
---@param rx number Horizontal radius in pixels.
---@param ry number Vertical radius in pixels.
---@param segments? any Optional segment count for smoothness.
function luna.graphics.ellipse(mode, x, y, rx, ry, segments) end

--- Returns the current background color.
function luna.graphics.getBackgroundColor() end

--- Returns the name of the currently active blend mode.
---@return string
function luna.graphics.getBlendMode() end

--- Returns the current world-space camera translate offset (cx, cy).
---@return number
---@return number
function luna.graphics.getCameraPosition() end

--- Returns the current camera rotation angle in radians.
---@return function
function luna.graphics.getCameraRotation() end

--- Returns the current camera zoom (scale) factor applied to the world.
---@return number
function luna.graphics.getCameraZoom() end

--- Returns the ID of the currently active render canvas, or nil.
function luna.graphics.getCanvas() end

--- Returns the dimensions (w, h) of the current canvas.
---@param id_val any
function luna.graphics.getCanvasSize(id_val) end

--- Returns the current drawing color (r, g, b, a).
function luna.graphics.getColor() end

--- Returns the active color channel write mask.
function luna.graphics.getColorMask() end

--- Returns the default texture filter mode.
function luna.graphics.getDefaultFilter() end

--- Returns the current depth mode string and write-enable flag.
function luna.graphics.getDepthMode() end

--- Returns the window dimensions (width, height).
function luna.graphics.getDimensions() end

--- Returns the currently active font ID.
function luna.graphics.getFont() end

--- Returns the active font's ascent Ă”Ă‡Ă¶ distance in pixels from baseline to the top of capital letters.
---@param id_val any
---@return number
function luna.graphics.getFontAscent(id_val) end

--- Returns the active font's descent Ă”Ă‡Ă¶ distance in pixels from the baseline to the bottom of descenders.
---@param id_val any
---@return number
function luna.graphics.getFontDescent(id_val) end

--- Returns the height of text in the active font.
---@param id_val any
function luna.graphics.getFontHeight(id_val) end

--- Returns the line height in pixels of the currently active font.
---@param id_val any
---@return number
function luna.graphics.getFontLineHeight(id_val) end

--- Returns the width of text in the active font.
---@param id_val any
---@param text any
function luna.graphics.getFontWidth(id_val, text) end

--- Returns the wrap mode of the active font.
---@param text any
---@param limit any
function luna.graphics.getFontWrap(text, limit) end

--- Returns the window height in pixels.
function luna.graphics.getHeight() end

--- Returns the current line width in pixels used for 'line' mode drawing.
---@return number
function luna.graphics.getLineWidth() end

--- Returns the texture ID currently bound to the given mesh for rendering.
---@param mesh number Mesh ID to query.
---@return number
function luna.graphics.getMeshTexture(mesh) end

--- Returns position and UV data for a vertex in a Mesh.
---@param id any
---@param index any
function luna.graphics.getMeshVertex(id, index) end

--- Returns the total number of vertices in a Mesh.
---@param id any
function luna.graphics.getMeshVertexCount(id) end

--- Returns the current point-sprite size.
function luna.graphics.getPointSize() end

--- Returns the active scissor rectangle (x, y, w, h), or nil.
function luna.graphics.getScissor() end

--- Returns the currently active Shader ID, or nil.
function luna.graphics.getShader() end

--- Returns the current depth of the transform stack.
function luna.graphics.getStackDepth() end

--- Returns a table of renderer statistics (draw calls, triangles, etc.).
function luna.graphics.getStats() end

--- Returns the current stencil mode as three values: action string, compare string, value.
function luna.graphics.getStencilMode() end

--- Returns the window width in pixels.
function luna.graphics.getWidth() end

--- Returns whether the current shader has a uniform with the given name.
---@param id any
---@param name any
function luna.graphics.hasShaderUniform(id, name) end

--- Intersects the current scissor rectangle with the given rectangle.
---@param x any
---@param y any
---@param w any
---@param h any
function luna.graphics.intersectScissor(x, y, w, h) end

--- Returns whether wireframe rendering mode is active.
function luna.graphics.isWireframe() end

--- Draws a straight line from (x1, y1) to (x2, y2) using the current color.
---@param x1 number Start X in pixels.
---@param y1 number Start Y in pixels.
---@param x2 number End X in pixels.
---@param y2 number End Y in pixels.
function luna.graphics.line(x1, y1, x2, y2) end

--- Creates an off-screen render canvas and returns its ID.
---@param width any
---@param height any
function luna.graphics.newCanvas(width, height) end

--- Loads a TTF/OTF font file and returns its ID.
---@param path any
---@param size? any (optional)
function luna.graphics.newFont(path, size) end

--- Loads an image file and returns its ID.
---@param arg any
function luna.graphics.newImage(arg) end

--- Creates a custom Mesh from vertex data and returns its ID.
---@param verts any
---@param mode? any (optional)
function luna.graphics.newMesh(verts, mode) end

--- Creates a nine-slice definition from an image and border insets.
---@param image number Image UserData (LuaImage) or numeric image ID.
---@param top number Pixel inset from the top edge.
---@param right number Pixel inset from the right edge.
---@param bottom number Pixel inset from the bottom edge.
---@param left number Pixel inset from the left edge.
---@return any
function luna.graphics.newNineSlice(image, top, right, bottom, left) end

--- Defines a sub-rectangle of a texture (a quad).
---@param x any
---@param y any
---@param w any
---@param h any
---@param sw any
---@param sh any
function luna.graphics.newQuad(x, y, w, h, sw, sh) end

--- Compiles a custom WGSL shader program and returns its ID.
---@param code any
function luna.graphics.newShader(code) end

function luna.graphics.newShape() end

--- Creates a new SpriteBatch for efficiently drawing many sprites sharing one texture.
---@param texture number Texture ID that all sprites in this batch must share.
---@param maxSprites number Maximum number of sprites the batch can hold.
---@return number
function luna.graphics.newSpriteBatch(texture, maxSprites) end

--- Resets the transform to the identity (no translation, rotation, or scale).
function luna.graphics.origin() end

--- Draws a list of (x, y) points using the current point size and color.
---@param ... number Alternating x, y coordinate pairs, or a flat numeric table.
function luna.graphics.points(...) end

--- Draws a filled or outlined polygon from a flat list of (x, y) vertex coordinates.
---@param mode string Draw mode: 'fill' or 'line'.
---@param vertices number Flat table of numbers in (x, y, x, y, ...) order.
function luna.graphics.polygon(mode, vertices) end

--- Draws an open multi-segment polyline.
---@param args any
function luna.graphics.polyline(args) end

--- Pops the top transform matrix from the stack.
function luna.graphics.pop() end

--- Draws the given text string at (x, y) using the active font and foreground color.
---@param text string String to draw.
---@param x number Left edge X coordinate in pixels.
---@param y number Top edge Y coordinate in pixels.
---@param angle? number Optional rotation angle in radians.
---@param sx? number Optional scale factors.
---@param sy? number Optional scale factors.
---@param ox? any Optional origin offsets.
---@param oy? any Optional origin offsets.
function luna.graphics.print(text, x, y, angle, sx, sy, ox, oy) end

--- Draws word-wrapped text within a given width.
---@param text any
---@param x any
---@param y any
---@param limit any
---@param align? any (optional)
function luna.graphics.printf(text, x, y, limit, align) end

--- Pushes the current transform matrix onto the transform stack.
function luna.graphics.push() end

--- Draws a filled or outlined rectangle at (x, y) with given width and height.
---@param mode string Draw mode: 'fill' or 'line'.
---@param x number Top-left X coordinate in pixels.
---@param y number Top-left Y coordinate in pixels.
---@param width number Rectangle width in pixels.
---@param height number Rectangle height in pixels.
---@param rx? number Optional horizontal corner radius for rounded rectangles.
---@param ry? number Optional vertical corner radius for rounded rectangles.
function luna.graphics.rectangle(mode, x, y, width, height, rx, ry) end

--- Releases a GPU resource handle and returns its memory to the pool early.
---@param handle number Resource ID to release (texture, canvas, shader, etc.).
function luna.graphics.release(handle) end

--- Releases the sprite batch resource and frees its GPU instance buffer.
---@param batch number SpriteBatch ID returned by newSpriteBatch.
function luna.graphics.releaseBatch(batch) end

--- Releases the canvas render target and frees its GPU framebuffer memory.
---@param canvas number Canvas ID returned by newCanvas.
function luna.graphics.releaseCanvas(canvas) end

--- Releases the font resource for the given ID and frees its GPU atlas memory.
---@param font number Font ID returned by newFont.
function luna.graphics.releaseFont(font) end

--- Releases the custom mesh resource and frees the GPU vertex buffer.
---@param mesh number Mesh ID returned by newMesh.
function luna.graphics.releaseMesh(mesh) end

--- Releases the compiled shader program and frees its GPU pipeline object.
---@param shader number Shader ID returned by newShader.
function luna.graphics.releaseShader(shader) end

function luna.graphics.releaseShape() end

--- Resets all graphics state to defaults: transform, color (1,1,1,1), shader, and scissor.
function luna.graphics.reset() end

--- Resets the camera transform to identity Ă”Ă‡Ă¶ no translation, rotation, or zoom.
function luna.graphics.resetCamera() end

--- Rotates the current transform by the given angle in radians.
---@param angle any
function luna.graphics.rotate(angle) end

--- Queues a PNG export of the actual rendered frame to a file under `save/`.
---@param path string `string`. Relative output path inside `save/`, for example `"save/frame.png"`.
---@return any
function luna.graphics.saveScreenshot(path) end

--- Concatenates a scale factor onto the current transform matrix.
---@param sx number Horizontal scale factor.
---@param sy number Vertical scale factor (defaults to sx if omitted).
function luna.graphics.scale(sx, sy) end

--- Sends a named uniform variable value to the currently active shader program.
---@param name Shader Uniform variable name as defined in the WGSL shader.
---@param value number Value to send (number, table of numbers, or boolean).
function luna.graphics.sendShader(name, value) end

--- Sets the RGBA color used to clear the framebuffer at the start of each draw frame.
---@param r any Red component in [0, 1].
---@param g any Green component in [0, 1].
---@param b any Blue component in [0, 1].
---@param a? any Optional alpha component (default 1.0).
function luna.graphics.setBackgroundColor(r, g, b, a) end

--- Sets the blend equation used when drawing new pixels over the existing framebuffer.
---@param mode string Blend mode string: 'alpha', 'additive', 'multiply', 'none', etc.
function luna.graphics.setBlendMode(mode) end

--- Sets the camera transform: position, rotation, and zoom applied to all draw calls.
---@param x number Camera center X in world units.
---@param y number Camera center Y in world units.
---@param angle? number Optional camera rotation angle in radians.
---@param zoom? number Optional zoom scale (1.0 = no zoom).
function luna.graphics.setCamera(x, y, angle, zoom) end

--- Redirects all drawing to the given canvas (or screen if nil).
---@param args any
function luna.graphics.setCanvas(args) end

--- Sets the current drawing color for all subsequent draw commands.
---@param r any
---@param g any
---@param b any
---@param a? any (optional)
function luna.graphics.setColor(r, g, b, a) end

--- Sets which RGBA channels are written to the render target for subsequent draw calls.
---@param r boolean Write to the red channel (boolean).
---@param g any Write to the green channel.
---@param b any Write to the blue channel.
---@param a any Write to the alpha channel.
function luna.graphics.setColorMask(r, g, b, a) end

--- Sets the default texture filter mode ('linear' or 'nearest').
---@param min any
---@param mag any
---@param anisotropy? any (optional)
function luna.graphics.setDefaultFilter(min, mag, anisotropy) end

--- Sets the depth test comparison mode and optional write flag.
---@param mode_s any
---@param write? any (optional)
function luna.graphics.setDepthMode(mode_s, write) end

--- Sets the active font for subsequent print calls.
---@param id_val any
function luna.graphics.setFont(id_val) end

--- Sets the line height multiplier for the active font used in multi-line text rendering.
---@param height number Line height factor (1.0 = default spacing).
function luna.graphics.setFontLineHeight(height) end

--- Sets the line width for outline drawing.
---@param w any
function luna.graphics.setLineWidth(w) end

--- Sets the vertex topology mode used when drawing a mesh ('triangles', 'fan', 'strip', 'points').
---@param mesh number Mesh ID returned by newMesh.
---@param mode string Topology string: 'triangles', 'fan', 'strip', or 'points'.
function luna.graphics.setMeshDrawMode(mesh, mode) end

--- Binds a texture to the given mesh so it is sampled during rendering.
---@param mesh number Mesh ID returned by newMesh.
---@param texture number Texture ID to bind, or nil to clear.
function luna.graphics.setMeshTexture(mesh, texture) end

--- Updates position and UV data for a single vertex in a Mesh.
---@param id any
---@param index any
---@param data any
function luna.graphics.setMeshVertex(id, index, data) end

--- Sets an index array defining the vertex drawing order for a custom mesh.
---@param mesh number Mesh ID returned by newMesh.
---@param map number Table of 1-based vertex indices specifying the draw order.
function luna.graphics.setMeshVertexMap(mesh, map) end

--- Uploads a new flat vertex array to replace the mesh's current geometry.
---@param mesh number Mesh ID returned by newMesh.
---@param vertices number Table of vertex attribute tables or a flat number array.
function luna.graphics.setMeshVertices(mesh, vertices) end

--- Sets the diameter in pixels used when drawing point primitives.
---@param size number Point diameter in pixels.
function luna.graphics.setPointSize(size) end

--- Restricts drawing to the given rectangle; clears scissor if no args.
function luna.graphics.setScissor() end

--- Activates a custom WGSL shader for subsequent draw calls.
---@param id? any (optional)
function luna.graphics.setShader(id) end

--- Sets the persistent stencil mode stored in SharedState.
---@param action_s any
---@param compare_s? any (optional)
---@param value? any (optional)
function luna.graphics.setStencilMode(action_s, compare_s, value) end

--- Configures the stencil test for subsequent draw calls.
function luna.graphics.setStencilTest() end

--- Enables or disables wireframe rendering mode.
---@param enabled any
function luna.graphics.setWireframe(enabled) end

--- Applies a shear transform to the current matrix.
---@param kx any
---@param ky any
function luna.graphics.shear(kx, ky) end

--- Appends a new sprite to the batch with the given position and transform properties.
---@param batch number SpriteBatch ID.
---@param x number Sprite X position in pixels.
---@param y number Sprite Y position in pixels.
---@param angle? any Optional rotation in radians.
---@param sx? number Optional scale factors.
---@param sy? number Optional scale factors.
---@param ox? any Optional origin offsets.
---@param oy? any Optional origin offsets.
---@return number
---@return number
function luna.graphics.spriteBatchAdd(batch, x, y, angle, sx, sy, ox, oy) end

--- Removes all sprites from the batch, resetting its count to zero.
---@param batch number SpriteBatch ID to clear.
function luna.graphics.spriteBatchClear(batch) end

--- Draws to the stencil buffer using the given Lua draw function.
function luna.graphics.stencil() end

--- Translates (moves) the current transform.
---@param x any
---@param y any
function luna.graphics.translate(x, y) end

--- Draws a filled or outlined triangle with three (x, y) vertex coordinates.
---@param mode string Draw mode: 'fill' or 'line'.
---@param x1 number First vertex.
---@param y1 number First vertex.
---@param x2 number Second vertex.
---@param y2 number Second vertex.
---@param x3 number Third vertex.
---@param y3 number Third vertex.
function luna.graphics.triangle(mode, x1, y1, x2, y2, x3, y3) end

---@class luna.gui
luna.gui = {}

---@class Accordion
local Accordion = {}

--- /// Returns a value for addSection (auto-generated).
---@param title any
---@param content_idx? any (optional)
function Accordion:addSection(title, content_idx) end

--- /// Returns a value for getSectionCount (auto-generated).
function Accordion:getSectionCount() end

--- /// Returns a value for getSectionTitle (auto-generated).
---@param section_idx any
function Accordion:getSectionTitle(section_idx) end

--- /// Returns a value for isExclusive (auto-generated).
function Accordion:isExclusive() end

--- /// Returns a value for isSectionExpanded (auto-generated).
---@param section_idx any
function Accordion:isSectionExpanded(section_idx) end

--- /// Returns a value for setExclusive (auto-generated).
---@param v any
function Accordion:setExclusive(v) end

--- /// Returns a value for toggleSection (auto-generated).
---@param section_idx any
function Accordion:toggleSection(section_idx) end

---@class Button
local Button = {}

--- /// Returns a value for getText (auto-generated).
function Button:getText() end

--- /// Returns a value for setText (auto-generated).
---@param text any
function Button:setText(text) end

---@class Checkbox
local Checkbox = {}

--- /// Returns a value for getText (auto-generated).
function Checkbox:getText() end

--- /// Returns a value for isChecked (auto-generated).
function Checkbox:isChecked() end

--- /// Returns a value for setChecked (auto-generated).
---@param checked any
function Checkbox:setChecked(checked) end

--- /// Returns a value for setText (auto-generated).
---@param text any
function Checkbox:setText(text) end

---@class Color_Picker
local Color_Picker = {}

--- /// Returns a value for getColor (auto-generated).
function Color_Picker:getColor() end

--- /// Returns a value for getColorMode (auto-generated).
function Color_Picker:getColorMode() end

--- /// Returns a value for getShowAlpha (auto-generated).
function Color_Picker:getShowAlpha() end

--- /// Returns a value for setColor (auto-generated).
---@param r any
---@param green any
---@param b any
---@param a? any (optional)
function Color_Picker:setColor(r, green, b, a) end

--- /// Returns a value for setColorMode (auto-generated).
---@param mode any
function Color_Picker:setColorMode(mode) end

--- /// Returns a value for setOnChange (auto-generated).
---@param f any
function Color_Picker:setOnChange(f) end

--- /// Returns a value for setShowAlpha (auto-generated).
---@param v any
function Color_Picker:setShowAlpha(v) end

---@class Combo_Box
local Combo_Box = {}

--- /// Returns a value for addItem (auto-generated).
---@param text any
function Combo_Box:addItem(text) end

--- /// Returns a value for clearItems (auto-generated).
function Combo_Box:clearItems() end

--- /// Returns a value for getItem (auto-generated).
---@param index any
function Combo_Box:getItem(index) end

--- /// Returns a value for getItemCount (auto-generated).
function Combo_Box:getItemCount() end

--- /// Returns a value for getSelectedIndex (auto-generated).
function Combo_Box:getSelectedIndex() end

--- /// Returns a value for getSelectedItem (auto-generated).
function Combo_Box:getSelectedItem() end

--- /// Returns a value for removeItem (auto-generated).
---@param index any
function Combo_Box:removeItem(index) end

--- /// Returns a value for setSelectedIndex (auto-generated).
---@param index any
function Combo_Box:setSelectedIndex(index) end

---@class Dialog
local Dialog = {}

--- /// Returns a value for addButton (auto-generated).
---@param text any
---@param cb? any (optional)
function Dialog:addButton(text, cb) end

--- /// Returns a value for close (auto-generated).
function Dialog:close() end

--- /// Returns a value for getContent (auto-generated).
function Dialog:getContent() end

--- /// Returns a value for getTitle (auto-generated).
function Dialog:getTitle() end

--- /// Returns a value for isModal (auto-generated).
function Dialog:isModal() end

--- /// Returns a value for isOpen (auto-generated).
function Dialog:isOpen() end

--- /// Returns a value for open (auto-generated).
function Dialog:open() end

--- /// Returns a value for setContent (auto-generated).
---@param content_idx? any (optional)
function Dialog:setContent(content_idx) end

--- /// Returns a value for setModal (auto-generated).
---@param v any
function Dialog:setModal(v) end

--- /// Returns a value for setOnClose (auto-generated).
---@param f any
function Dialog:setOnClose(f) end

--- /// Returns a value for setTitle (auto-generated).
---@param title any
function Dialog:setTitle(title) end

---@class Dock_Panel
local Dock_Panel = {}

--- /// Returns a value for dock (auto-generated).
---@param child_idx any
---@param side any
function Dock_Panel:dock(child_idx, side) end

--- /// Returns a value for getDockedCount (auto-generated).
function Dock_Panel:getDockedCount() end

--- /// Returns a value for getSplitSize (auto-generated).
---@param side any
function Dock_Panel:getSplitSize(side) end

--- /// Returns a value for setSplitSize (auto-generated).
---@param side any
---@param size any
function Dock_Panel:setSplitSize(side, size) end

--- /// Returns a value for undock (auto-generated).
---@param child_idx any
function Dock_Panel:undock(child_idx) end

---@class Gui_Table
local Gui_Table = {}

--- /// Returns a value for addColumn (auto-generated).
---@param header any
---@param width? any (optional)
function Gui_Table:addColumn(header, width) end

--- /// Returns a value for addRow (auto-generated).
---@param cells any
function Gui_Table:addRow(cells) end

--- /// Returns a value for getCell (auto-generated).
---@param row any
---@param col any
function Gui_Table:getCell(row, col) end

--- /// Returns a value for getColumnCount (auto-generated).
function Gui_Table:getColumnCount() end

--- /// Returns a value for getRowCount (auto-generated).
function Gui_Table:getRowCount() end

--- /// Returns a value for getSelectedRow (auto-generated).
function Gui_Table:getSelectedRow() end

--- /// Returns a value for isSortable (auto-generated).
function Gui_Table:isSortable() end

--- /// Returns a value for setCell (auto-generated).
---@param row any
---@param col any
---@param text any
function Gui_Table:setCell(row, col, text) end

--- /// Returns a value for setOnSelect (auto-generated).
---@param f any
function Gui_Table:setOnSelect(f) end

--- /// Returns a value for setSelectedRow (auto-generated).
---@param row? any (optional)
function Gui_Table:setSelectedRow(row) end

--- /// Returns a value for setSortable (auto-generated).
---@param v any
function Gui_Table:setSortable(v) end

---@class Gui_Window
local Gui_Window = {}

--- /// Returns a value for addChild (auto-generated).
---@param child_idx any
function Gui_Window:addChild(child_idx) end

--- /// Returns a value for getChildren (auto-generated).
function Gui_Window:getChildren() end

--- /// Returns a value for getTitle (auto-generated).
function Gui_Window:getTitle() end

--- /// Returns a value for isCloseable (auto-generated).
function Gui_Window:isCloseable() end

--- /// Returns a value for isDraggable (auto-generated).
function Gui_Window:isDraggable() end

--- /// Returns a value for isResizable (auto-generated).
function Gui_Window:isResizable() end

--- /// Returns a value for removeChild (auto-generated).
---@param child_idx any
function Gui_Window:removeChild(child_idx) end

--- /// Returns a value for setCloseable (auto-generated).
---@param v any
function Gui_Window:setCloseable(v) end

--- /// Returns a value for setDraggable (auto-generated).
---@param v any
function Gui_Window:setDraggable(v) end

--- /// Returns a value for setOnClose (auto-generated).
---@param f any
function Gui_Window:setOnClose(f) end

--- /// Returns a value for setResizable (auto-generated).
---@param v any
function Gui_Window:setResizable(v) end

--- /// Returns a value for setTitle (auto-generated).
---@param title any
function Gui_Window:setTitle(title) end

---@class Image_Widget
local Image_Widget = {}

--- /// Returns a value for addToast (auto-generated).
---@param toast_table any
function Image_Widget:addToast(toast_table) end

--- /// Returns a value for clearFocus (auto-generated).
function Image_Widget:clearFocus() end

--- /// Returns a value for draw (auto-generated).
function Image_Widget:draw() end

--- /// Returns a value for focusNext (auto-generated).
function Image_Widget:focusNext() end

--- /// Returns a value for focusPrev (auto-generated).
function Image_Widget:focusPrev() end

--- /// Returns a value for getFocus (auto-generated).
function Image_Widget:getFocus() end

--- /// Returns a value for getRoot (auto-generated).
function Image_Widget:getRoot() end

--- /// Returns a value for getScaleMode (auto-generated).
function Image_Widget:getScaleMode() end

--- /// Returns a value for getTheme (auto-generated).
function Image_Widget:getTheme() end

--- /// Returns a value for getTint (auto-generated).
function Image_Widget:getTint() end

--- /// Returns a value for getToastCount (auto-generated).
function Image_Widget:getToastCount() end

--- /// Returns a value for getWidgetCount (auto-generated).
function Image_Widget:getWidgetCount() end

--- /// Returns a value for keypressed (auto-generated).
---@param key any
function Image_Widget:keypressed(key) end

--- /// Returns a value for mousemoved (auto-generated).
---@param x any
---@param y any
---@param dx? any (optional)
---@param dy? any (optional)
function Image_Widget:mousemoved(x, y, dx, dy) end

--- /// Returns a value for mousepressed (auto-generated).
---@param x any
---@param y any
---@param btn? any (optional)
function Image_Widget:mousepressed(x, y, btn) end

--- /// Returns a value for mousereleased (auto-generated).
---@param x any
---@param y any
---@param btn? any (optional)
function Image_Widget:mousereleased(x, y, btn) end

--- /// Returns a value for newAccordion (auto-generated).
function Image_Widget:newAccordion() end

--- /// Returns a value for newButton (auto-generated).
---@param text? any (optional)
function Image_Widget:newButton(text) end

--- /// Returns a value for newCheckbox (auto-generated).
---@param text? any (optional)
function Image_Widget:newCheckbox(text) end

--- /// Returns a value for newColorPicker (auto-generated).
function Image_Widget:newColorPicker() end

--- /// Returns a value for newComboBox (auto-generated).
function Image_Widget:newComboBox() end

--- /// Returns a value for newDialog (auto-generated).
---@param title? any (optional)
function Image_Widget:newDialog(title) end

--- /// Returns a value for newDockPanel (auto-generated).
function Image_Widget:newDockPanel() end

--- /// Returns a value for newImageWidget (auto-generated).
function Image_Widget:newImageWidget() end

--- /// Returns a value for newLabel (auto-generated).
---@param text? any (optional)
function Image_Widget:newLabel(text) end

--- /// Returns a value for newLayout (auto-generated).
---@param direction? any (optional)
function Image_Widget:newLayout(direction) end

--- /// Returns a value for newList (auto-generated).
function Image_Widget:newList() end

--- /// Returns a value for newMenuBar (auto-generated).
function Image_Widget:newMenuBar() end

--- /// Returns a value for newMenuItem (auto-generated).
---@param text? any (optional)
function Image_Widget:newMenuItem(text) end

--- /// Returns a value for newNinePatch (auto-generated).
function Image_Widget:newNinePatch() end

--- /// Returns a value for newPanel (auto-generated).
function Image_Widget:newPanel() end

--- /// Returns a value for newProgressBar (auto-generated).
---@param min? any (optional)
---@param max? any (optional)
function Image_Widget:newProgressBar(min, max) end

--- /// Returns a value for newRadioButton (auto-generated).
---@param text? any (optional)
---@param group? any (optional)
function Image_Widget:newRadioButton(text, group) end

--- /// Returns a value for newScrollBar (auto-generated).
---@param vertical? any (optional)
function Image_Widget:newScrollBar(vertical) end

--- /// Returns a value for newScrollPanel (auto-generated).
function Image_Widget:newScrollPanel() end

--- /// Returns a value for newSeparator (auto-generated).
---@param vertical? any (optional)
function Image_Widget:newSeparator(vertical) end

--- /// Returns a value for newSlider (auto-generated).
---@param min? any (optional)
---@param max? any (optional)
function Image_Widget:newSlider(min, max) end

--- /// Returns a value for newSpacer (auto-generated).
---@param w? any (optional)
---@param h? any (optional)
function Image_Widget:newSpacer(w, h) end

--- /// Returns a value for newSplitPanel (auto-generated).
---@param orientation? any (optional)
function Image_Widget:newSplitPanel(orientation) end

--- /// Returns a value for newStatusBar (auto-generated).
function Image_Widget:newStatusBar() end

--- /// Returns a value for newTabBar (auto-generated).
function Image_Widget:newTabBar() end

--- /// Returns a value for newTable (auto-generated).
function Image_Widget:newTable() end

--- /// Returns a value for newTextInput (auto-generated).
function Image_Widget:newTextInput() end

--- /// Returns a value for newTheme (auto-generated).
function Image_Widget:newTheme() end

--- /// Returns a value for newToast (auto-generated).
---@param message? any (optional)
---@param duration? any (optional)
function Image_Widget:newToast(message, duration) end

--- /// Returns a value for newToolbar (auto-generated).
---@param orientation? any (optional)
function Image_Widget:newToolbar(orientation) end

--- /// Returns a value for newTooltipPanel (auto-generated).
---@param text? any (optional)
function Image_Widget:newTooltipPanel(text) end

--- /// Returns a value for newTreeView (auto-generated).
function Image_Widget:newTreeView() end

--- /// Returns a value for newWindow (auto-generated).
---@param title? any (optional)
function Image_Widget:newWindow(title) end

--- /// Returns a value for setFocus (auto-generated).
---@param widget? any (optional)
function Image_Widget:setFocus(widget) end

--- /// Returns a value for setScaleMode (auto-generated).
---@param mode any
function Image_Widget:setScaleMode(mode) end

--- /// Returns a value for setStyle (auto-generated).
---@param widget_type any
---@param state any
---@param style_table any
function Image_Widget:setStyle(widget_type, state, style_table) end

--- /// Returns a value for setTheme (auto-generated).
---@param theme_table any
function Image_Widget:setTheme(theme_table) end

--- /// Returns a value for setTint (auto-generated).
---@param r any
---@param green any
---@param b any
---@param a? any (optional)
function Image_Widget:setTint(r, green, b, a) end

--- /// Returns a value for textinput (auto-generated).
---@param text any
function Image_Widget:textinput(text) end

--- /// Returns a value for update (auto-generated).
---@param dt any
function Image_Widget:update(dt) end

--- /// Returns a value for wheelmoved (auto-generated).
---@param x any
---@param y any
function Image_Widget:wheelmoved(x, y) end

---@class Label
local Label = {}

--- /// Returns a value for getText (auto-generated).
function Label:getText() end

--- /// Returns a value for setText (auto-generated).
---@param text any
function Label:setText(text) end

---@class Layout
local Layout = {}

--- /// Returns a value for getAlign (auto-generated).
function Layout:getAlign() end

--- /// Returns a value for getDirection (auto-generated).
function Layout:getDirection() end

--- /// Returns a value for getJustify (auto-generated).
function Layout:getJustify() end

--- /// Returns a value for getSpacing (auto-generated).
function Layout:getSpacing() end

--- /// Returns a value for getWrap (auto-generated).
function Layout:getWrap() end

--- /// Returns a value for setAlign (auto-generated).
---@param align any
function Layout:setAlign(align) end

--- /// Returns a value for setColumns (auto-generated).
---@param n any
function Layout:setColumns(n) end

--- /// Returns a value for setDirection (auto-generated).
---@param dir any
function Layout:setDirection(dir) end

--- /// Returns a value for setJustify (auto-generated).
---@param justify any
function Layout:setJustify(justify) end

--- /// Returns a value for setSpacing (auto-generated).
---@param spacing any
function Layout:setSpacing(spacing) end

--- /// Returns a value for setWrap (auto-generated).
---@param wrap any
function Layout:setWrap(wrap) end

---@class List_Box
local List_Box = {}

--- /// Returns a value for addItem (auto-generated).
---@param text any
function List_Box:addItem(text) end

--- /// Returns a value for clearItems (auto-generated).
function List_Box:clearItems() end

--- /// Returns a value for getItem (auto-generated).
---@param index any
function List_Box:getItem(index) end

--- /// Returns a value for getItemCount (auto-generated).
function List_Box:getItemCount() end

--- /// Returns a value for getSelectedIndex (auto-generated).
function List_Box:getSelectedIndex() end

--- /// Returns a value for removeItem (auto-generated).
---@param index any
function List_Box:removeItem(index) end

--- /// Returns a value for setItemHeight (auto-generated).
---@param h any
function List_Box:setItemHeight(h) end

--- /// Returns a value for setSelectedIndex (auto-generated).
---@param index any
function List_Box:setSelectedIndex(index) end

---@class Menu_Bar
local Menu_Bar = {}

--- /// Returns a value for addMenu (auto-generated).
---@param menu_idx any
function Menu_Bar:addMenu(menu_idx) end

--- /// Returns a value for getMenuCount (auto-generated).
function Menu_Bar:getMenuCount() end

--- /// Returns a value for getMenus (auto-generated).
function Menu_Bar:getMenus() end

--- /// Returns a value for removeMenu (auto-generated).
---@param menu_idx any
function Menu_Bar:removeMenu(menu_idx) end

---@class Menu_Item
local Menu_Item = {}

--- /// Returns a value for addSubItem (auto-generated).
---@param child_idx any
function Menu_Item:addSubItem(child_idx) end

--- /// Returns a value for getShortcut (auto-generated).
function Menu_Item:getShortcut() end

--- /// Returns a value for getSubItems (auto-generated).
function Menu_Item:getSubItems() end

--- /// Returns a value for getText (auto-generated).
function Menu_Item:getText() end

--- /// Returns a value for isChecked (auto-generated).
function Menu_Item:isChecked() end

--- /// Returns a value for setChecked (auto-generated).
---@param v any
function Menu_Item:setChecked(v) end

--- /// Returns a value for setOnClick (auto-generated).
---@param f any
function Menu_Item:setOnClick(f) end

--- /// Returns a value for setShortcut (auto-generated).
---@param shortcut any
function Menu_Item:setShortcut(shortcut) end

--- /// Returns a value for setText (auto-generated).
---@param text any
function Menu_Item:setText(text) end

---@class Nine_Patch
local Nine_Patch = {}

--- /// Returns a value for getImageDimensions (auto-generated).
function Nine_Patch:getImageDimensions() end

--- /// Returns a value for getInsets (auto-generated).
function Nine_Patch:getInsets() end

--- /// Returns a value for getSlices (auto-generated).
function Nine_Patch:getSlices() end

--- /// Returns a value for setImageDimensions (auto-generated).
---@param w any
---@param h any
function Nine_Patch:setImageDimensions(w, h) end

--- /// Returns a value for setInsets (auto-generated).
---@param left any
---@param top any
---@param right any
---@param bottom any
function Nine_Patch:setInsets(left, top, right, bottom) end

---@class Panel
local Panel = {}

--- /// Returns a value for getTitle (auto-generated).
function Panel:getTitle() end

--- /// Returns a value for setScrollable (auto-generated).
---@param scrollable any
function Panel:setScrollable(scrollable) end

--- /// Returns a value for setTitle (auto-generated).
---@param title any
function Panel:setTitle(title) end

---@class Progress_Bar
local Progress_Bar = {}

--- /// Returns a value for getMax (auto-generated).
function Progress_Bar:getMax() end

--- /// Returns a value for getMin (auto-generated).
function Progress_Bar:getMin() end

--- /// Returns a value for getProgress (auto-generated).
function Progress_Bar:getProgress() end

--- /// Returns a value for getValue (auto-generated).
function Progress_Bar:getValue() end

--- /// Returns a value for setRange (auto-generated).
---@param min any
---@param max any
function Progress_Bar:setRange(min, max) end

--- /// Returns a value for setValue (auto-generated).
---@param v any
function Progress_Bar:setValue(v) end

---@class Radio_Button
local Radio_Button = {}

--- /// Returns a value for getGroup (auto-generated).
function Radio_Button:getGroup() end

--- /// Returns a value for getText (auto-generated).
function Radio_Button:getText() end

--- /// Returns a value for isSelected (auto-generated).
function Radio_Button:isSelected() end

--- /// Returns a value for setGroup (auto-generated).
---@param group any
function Radio_Button:setGroup(group) end

--- /// Returns a value for setOnChange (auto-generated).
---@param f any
function Radio_Button:setOnChange(f) end

--- /// Returns a value for setSelected (auto-generated).
---@param v any
function Radio_Button:setSelected(v) end

--- /// Returns a value for setText (auto-generated).
---@param text any
function Radio_Button:setText(text) end

---@class Scroll_Bar
local Scroll_Bar = {}

--- /// Returns a value for getContentSize (auto-generated).
function Scroll_Bar:getContentSize() end

--- /// Returns a value for getScrollPosition (auto-generated).
function Scroll_Bar:getScrollPosition() end

--- /// Returns a value for getViewSize (auto-generated).
function Scroll_Bar:getViewSize() end

--- /// Returns a value for isVertical (auto-generated).
function Scroll_Bar:isVertical() end

--- /// Returns a value for setContentSize (auto-generated).
---@param v any
function Scroll_Bar:setContentSize(v) end

--- /// Returns a value for setOnChange (auto-generated).
---@param f any
function Scroll_Bar:setOnChange(f) end

--- /// Returns a value for setScrollPosition (auto-generated).
---@param v any
function Scroll_Bar:setScrollPosition(v) end

--- /// Returns a value for setViewSize (auto-generated).
---@param v any
function Scroll_Bar:setViewSize(v) end

---@class Scroll_Panel
local Scroll_Panel = {}

--- /// Returns a value for getContentSize (auto-generated).
function Scroll_Panel:getContentSize() end

--- /// Returns a value for getMaxScroll (auto-generated).
function Scroll_Panel:getMaxScroll() end

--- /// Returns a value for getScrollPosition (auto-generated).
function Scroll_Panel:getScrollPosition() end

--- /// Returns a value for getScrollSpeed (auto-generated).
function Scroll_Panel:getScrollSpeed() end

--- /// Returns a value for setContentSize (auto-generated).
---@param w any
---@param h any
function Scroll_Panel:setContentSize(w, h) end

--- /// Returns a value for setScrollPosition (auto-generated).
---@param x any
---@param y any
function Scroll_Panel:setScrollPosition(x, y) end

--- /// Returns a value for setScrollSpeed (auto-generated).
---@param speed any
function Scroll_Panel:setScrollSpeed(speed) end

---@class Separator
local Separator = {}

--- /// Returns a value for getThickness (auto-generated).
function Separator:getThickness() end

--- /// Returns a value for isVertical (auto-generated).
function Separator:isVertical() end

--- /// Returns a value for setThickness (auto-generated).
---@param thickness any
function Separator:setThickness(thickness) end

--- /// Returns a value for setVertical (auto-generated).
---@param v any
function Separator:setVertical(v) end

---@class Slider
local Slider = {}

--- /// Returns a value for getMax (auto-generated).
function Slider:getMax() end

--- /// Returns a value for getMin (auto-generated).
function Slider:getMin() end

--- /// Returns a value for getValue (auto-generated).
function Slider:getValue() end

--- /// Returns a value for setRange (auto-generated).
---@param min any
---@param max any
function Slider:setRange(min, max) end

--- /// Returns a value for setStep (auto-generated).
---@param step any
function Slider:setStep(step) end

--- /// Returns a value for setValue (auto-generated).
---@param v any
function Slider:setValue(v) end

---@class Split_Panel
local Split_Panel = {}

--- /// Returns a value for getFirstChild (auto-generated).
function Split_Panel:getFirstChild() end

--- /// Returns a value for getMinPanelSize (auto-generated).
function Split_Panel:getMinPanelSize() end

--- /// Returns a value for getOrientation (auto-generated).
function Split_Panel:getOrientation() end

--- /// Returns a value for getSecondChild (auto-generated).
function Split_Panel:getSecondChild() end

--- /// Returns a value for getSplitPosition (auto-generated).
function Split_Panel:getSplitPosition() end

--- /// Returns a value for setFirstChild (auto-generated).
---@param child_idx any
function Split_Panel:setFirstChild(child_idx) end

--- /// Returns a value for setMinPanelSize (auto-generated).
---@param v any
function Split_Panel:setMinPanelSize(v) end

--- /// Returns a value for setOrientation (auto-generated).
---@param v any
function Split_Panel:setOrientation(v) end

--- /// Returns a value for setSecondChild (auto-generated).
---@param child_idx any
function Split_Panel:setSecondChild(child_idx) end

--- /// Returns a value for setSplitPosition (auto-generated).
---@param v any
function Split_Panel:setSplitPosition(v) end

---@class Status_Bar
local Status_Bar = {}

--- /// Returns a value for addSection (auto-generated).
---@param text any
---@param width? any (optional)
function Status_Bar:addSection(text, width) end

--- /// Returns a value for getSectionCount (auto-generated).
function Status_Bar:getSectionCount() end

--- /// Returns a value for getSectionText (auto-generated).
---@param section_idx any
function Status_Bar:getSectionText(section_idx) end

--- /// Returns a value for setSectionCount (auto-generated).
---@param n any
function Status_Bar:setSectionCount(n) end

--- /// Returns a value for setSectionText (auto-generated).
---@param section_idx any
---@param text any
function Status_Bar:setSectionText(section_idx, text) end

--- /// Returns a value for setSectionWidget (auto-generated).
---@param sidx any
---@param widx any
function Status_Bar:setSectionWidget(sidx, widx) end

---@class Tab_Bar
local Tab_Bar = {}

--- /// Returns a value for addTab (auto-generated).
---@param label any
function Tab_Bar:addTab(label) end

--- /// Returns a value for getActiveTab (auto-generated).
function Tab_Bar:getActiveTab() end

--- /// Returns a value for getTab (auto-generated).
---@param index any
function Tab_Bar:getTab(index) end

--- /// Returns a value for getTabCount (auto-generated).
function Tab_Bar:getTabCount() end

--- /// Returns a value for removeTab (auto-generated).
---@param index any
function Tab_Bar:removeTab(index) end

--- /// Returns a value for setActiveTab (auto-generated).
---@param index any
function Tab_Bar:setActiveTab(index) end

---@class Text_Input
local Text_Input = {}

--- /// Returns a value for getCursorPosition (auto-generated).
function Text_Input:getCursorPosition() end

--- /// Returns a value for getPlaceholder (auto-generated).
function Text_Input:getPlaceholder() end

--- /// Returns a value for getText (auto-generated).
function Text_Input:getText() end

--- /// Returns a value for isFocused (auto-generated).
function Text_Input:isFocused() end

--- /// Returns a value for setMaxLength (auto-generated).
---@param n any
function Text_Input:setMaxLength(n) end

--- /// Returns a value for setPlaceholder (auto-generated).
---@param text any
function Text_Input:setPlaceholder(text) end

--- /// Returns a value for setText (auto-generated).
---@param text any
function Text_Input:setText(text) end

---@class Toast
local Toast = {}

--- /// Returns a value for getDuration (auto-generated).
function Toast:getDuration() end

--- /// Returns a value for getMessage (auto-generated).
function Toast:getMessage() end

--- /// Returns a value for getProgress (auto-generated).
function Toast:getProgress() end

--- /// Returns a value for isExpired (auto-generated).
function Toast:isExpired() end

--- /// Returns a value for setDuration (auto-generated).
---@param d any
function Toast:setDuration(d) end

--- /// Returns a value for setMessage (auto-generated).
---@param msg any
function Toast:setMessage(msg) end

---@class Toolbar
local Toolbar = {}

--- /// Returns a value for addButton (auto-generated).
---@param id any
---@param tooltip? any (optional)
function Toolbar:addButton(id, tooltip) end

--- /// Returns a value for addChild (auto-generated).
---@param child_idx any
function Toolbar:addChild(child_idx) end

--- /// Returns a value for addSeparator (auto-generated).
function Toolbar:addSeparator() end

--- /// Returns a value for addSpacer (auto-generated).
---@param width? any (optional)
function Toolbar:addSpacer(width) end

--- /// Returns a value for getButton (auto-generated).
---@param id any
function Toolbar:getButton(id) end

--- /// Returns a value for getChildren (auto-generated).
function Toolbar:getChildren() end

--- /// Returns a value for getOrientation (auto-generated).
function Toolbar:getOrientation() end

--- /// Returns a value for isButtonToggled (auto-generated).
---@param id any
function Toolbar:isButtonToggled(id) end

--- /// Returns a value for removeChild (auto-generated).
---@param child_idx any
function Toolbar:removeChild(child_idx) end

--- /// Returns a value for setButtonEnabled (auto-generated).
---@param id any
---@param enabled any
function Toolbar:setButtonEnabled(id, enabled) end

--- /// Returns a value for setButtonToggled (auto-generated).
---@param id any
---@param toggled any
function Toolbar:setButtonToggled(id, toggled) end

--- /// Returns a value for setOrientation (auto-generated).
---@param v any
function Toolbar:setOrientation(v) end

---@class Tooltip_Panel
local Tooltip_Panel = {}

--- /// Returns a value for getDelay (auto-generated).
function Tooltip_Panel:getDelay() end

--- /// Returns a value for getTarget (auto-generated).
function Tooltip_Panel:getTarget() end

--- /// Returns a value for getText (auto-generated).
function Tooltip_Panel:getText() end

--- /// Returns a value for setDelay (auto-generated).
---@param v any
function Tooltip_Panel:setDelay(v) end

--- /// Returns a value for setTarget (auto-generated).
---@param target? any (optional)
function Tooltip_Panel:setTarget(target) end

--- /// Returns a value for setText (auto-generated).
---@param text any
function Tooltip_Panel:setText(text) end

---@class Tree_View
local Tree_View = {}

--- /// Returns a value for addNode (auto-generated).
---@param text any
---@param parent_index? any (optional)
function Tree_View:addNode(text, parent_index) end

--- /// Returns a value for clearNodes (auto-generated).
function Tree_View:clearNodes() end

--- /// Returns a value for collapseAll (auto-generated).
function Tree_View:collapseAll() end

--- /// Returns a value for collapseNode (auto-generated).
---@param index any
function Tree_View:collapseNode(index) end

--- /// Returns a value for expandAll (auto-generated).
function Tree_View:expandAll() end

--- /// Returns a value for expandNode (auto-generated).
---@param index any
function Tree_View:expandNode(index) end

--- /// Returns a value for getChildNodes (auto-generated).
---@param index any
function Tree_View:getChildNodes(index) end

--- /// Returns a value for getNodeCount (auto-generated).
function Tree_View:getNodeCount() end

--- /// Returns a value for getNodeDepth (auto-generated).
---@param index any
function Tree_View:getNodeDepth(index) end

--- /// Returns a value for getNodeText (auto-generated).
---@param index any
function Tree_View:getNodeText(index) end

--- /// Returns a value for getParentNode (auto-generated).
---@param index any
function Tree_View:getParentNode(index) end

--- /// Returns a value for getSelectedNode (auto-generated).
function Tree_View:getSelectedNode() end

--- /// Returns a value for isExpanded (auto-generated).
---@param index any
function Tree_View:isExpanded(index) end

--- /// Returns a value for isNodeExpanded (auto-generated).
---@param index any
function Tree_View:isNodeExpanded(index) end

--- /// Returns a value for removeNode (auto-generated).
---@param index any
function Tree_View:removeNode(index) end

--- /// Returns a value for setNodeIcon (auto-generated).
---@param index any
---@param icon any
function Tree_View:setNodeIcon(index, icon) end

--- /// Returns a value for setNodeText (auto-generated).
---@param index any
---@param text any
function Tree_View:setNodeText(index, text) end

--- /// Returns a value for setSelectedNode (auto-generated).
---@param index any
function Tree_View:setSelectedNode(index) end

--- /// Returns a value for toggleNode (auto-generated).
---@param index any
function Tree_View:toggleNode(index) end

---@param child any
function luna.gui.addChild(child) end

function luna.gui.clearAnchor() end

---@param x any
---@param y any
function luna.gui.containsPoint(x, y) end

---@param id any
function luna.gui.findById(id) end

function luna.gui.getChildCount() end

function luna.gui.getFlexGrow() end

function luna.gui.getFlexShrink() end

function luna.gui.getId() end

function luna.gui.getMargin() end

function luna.gui.getMaxSize() end

function luna.gui.getMinSize() end

function luna.gui.getPadding() end

function luna.gui.getPosition() end

function luna.gui.getSize() end

function luna.gui.getState() end

function luna.gui.getTooltip() end

function luna.gui.getZOrder() end

function luna.gui.isEnabled() end

function luna.gui.isVisible() end

---@param child any
function luna.gui.removeChild(child) end

function luna.gui.setAnchor() end

---@param cx? any (optional)
---@param cy? any (optional)
function luna.gui.setAnchorCenter(cx, cy) end

---@param v any
function luna.gui.setEnabled(v) end

---@param grow any
function luna.gui.setFlexGrow(grow) end

---@param shrink any
function luna.gui.setFlexShrink(shrink) end

---@param id any
function luna.gui.setId(id) end

function luna.gui.setMargin() end

---@param w any
---@param h any
function luna.gui.setMaxSize(w, h) end

---@param w any
---@param h any
function luna.gui.setMinSize(w, h) end

---@param f any
function luna.gui.setOnChange(f) end

---@param f any
function luna.gui.setOnClick(f) end

---@param f any
function luna.gui.setOnDraw(f) end

function luna.gui.setPadding() end

---@param x any
---@param y any
function luna.gui.setPosition(x, y) end

---@param w any
---@param h any
function luna.gui.setSize(w, h) end

---@param text any
function luna.gui.setTooltip(text) end

---@param v any
function luna.gui.setVisible(v) end

---@param z any
function luna.gui.setZOrder(z) end

---@class luna.image
luna.image = {}

---@class CompressedImageData
local CompressedImageData = {}

--- Return `(width, height)` of the base mip level.
function CompressedImageData:getDimensions() end

--- Return the compressed format name string (e.g. `"dxt1"`, `"bc7"`).
function CompressedImageData:getFormat() end

--- Return the height of the base mip level in pixels.
---@return number
function CompressedImageData:getHeight() end

--- Return the number of mipmap levels stored in this compressed image.
function CompressedImageData:getMipmapCount() end

--- Return the width of the base mip level in pixels.
---@return number
function CompressedImageData:getWidth() end

---@param filename any
function luna.image.isCompressed(filename) end

---@param filename any
function luna.image.newCompressedData(filename) end

--- Creates a new blank RGBA8 ImageData buffer of the given size.
---@param args any
function luna.image.newImageData(args) end

---@class luna.input
luna.input = {}

---@class Cursor
local Cursor = {}

function Cursor:getType() end

function Cursor:release() end

--- Returns the current value (-1 to 1) of a gamepad analog axis.
---@param id any
---@param axis any
---@return any
function luna.input.getAxis(id, axis) end

--- Returns the total number of analog axes on the gamepad.
---@param id any
---@return any
function luna.input.getAxisCount(id) end

--- Returns whether background gamepad events are enabled.
---@return table
function luna.input.getBackgroundEvents() end

--- Returns the total number of buttons on the gamepad.
---@param id any
---@return any
function luna.input.getButtonCount(id) end

--- Returns the number of connected gamepads.
---@return table
function luna.input.getCount() end

--- Returns the currently active cursor ID.
---@return any
function luna.input.getCursor() end

--- Returns the hardware GUID string of the gamepad.
---@param id any
---@return any
function luna.input.getGUID(id) end

--- Returns the stored mapping string for the gamepad with the given GUID, or nil.
---@param guid any
---@return string?
function luna.input.getGamepadMappingString(guid) end

--- Returns the direction (string) of a hat switch on the gamepad.
---@param id any
---@param hat any
---@return any
function luna.input.getHat(id, hat) end

--- Returns the number of tracked gamepad slots.
---@return table
function luna.input.getJoystickCount() end

--- Returns a list of connected gamepad IDs.
---@return table
function luna.input.getJoysticks() end

--- Returns the key name for the given hardware scancode.
---@param scancode any
---@return any
function luna.input.getKeyFromScancode(scancode) end

--- Returns the human-readable name of a gamepad.
---@param id any
---@return any
function luna.input.getName(id) end

--- Returns the current position (x, y).
---@return any
function luna.input.getPosition() end

--- Returns the current position (x, y).
---@param id any
---@return any
function luna.input.getPosition(id) end

--- Returns the pressure (0-1) of the touch with the given ID.
---@param id any
---@return any
function luna.input.getPressure(id) end

--- Returns whether relative mouse mode is active.
function luna.input.getRelativeMode() end

--- Returns the hardware scancode for the given key name.
---@param key any
---@return any
function luna.input.getScancodeFromKey(key) end

--- Returns a system cursor object for the named cursor shape.
---@param name any
function luna.input.getSystemCursor(name) end

--- Returns the number of currently active touch points.
function luna.input.getTouchCount() end

--- Returns a table of active touch points (id, x, y, pressure).
---@return table
function luna.input.getTouches() end

--- Returns the mouse scroll wheel delta (dx, dy) since last frame.
---@return any
function luna.input.getWheelDelta() end

--- Returns the current mouse X position in window coordinates.
---@return any
function luna.input.getX() end

--- Returns the current mouse Y position in window coordinates.
---@return any
function luna.input.getY() end

--- Returns whether key-repeat is currently enabled.
function luna.input.hasKeyRepeat() end

--- Returns whether text input mode is currently active.
---@return any
function luna.input.hasTextInput() end

--- Returns whether the gamepad with the given ID is connected.
---@param id any
---@return any
function luna.input.isConnected(id) end

--- Returns whether cursor customisation is supported on this platform.
function luna.input.isCursorSupported() end

--- Returns whether the given key is currently held down.
---@param args any
---@return boolean
function luna.input.isDown(args) end

--- Returns whether the given key is currently held down.
---@param button any
---@return any
function luna.input.isDown(button) end

--- Returns whether the given key is currently held down.
---@param id any
---@param button any
---@return any
function luna.input.isDown(id, button) end

--- Returns whether the joystick at the given slot is a recognized gamepad.
---@param id any
---@return any
function luna.input.isGamepad(id) end

--- Returns whether the mouse cursor is locked to the window.
function luna.input.isGrabbed() end

--- Returns whether the named modifier key (shift/ctrl/alt/meta/super) is currently held.
---@param modifier any
---@return boolean
function luna.input.isModifierActive(modifier) end

--- Returns whether the key with the given scancode is held.
---@param scancode any
---@return any
function luna.input.isScancodeDown(scancode) end

--- Returns whether the gamepad supports haptic vibration.
---@param id any
---@return boolean
function luna.input.isVibrationSupported(id) end

--- Returns whether the mouse cursor is currently visible.
function luna.input.isVisible() end

--- Loads SDL2 GameControllerDB-format mappings from a file.
---@param path any
---@return integer
function luna.input.loadGamepadMappings(path) end

--- Creates a custom mouse cursor from RGBA pixel data.
---@param pixels any
---@param width any
---@param height any
---@param hotx? any (optional)
---@param hoty? any (optional)
function luna.input.newCursor(pixels, width, height, hotx, hoty) end

--- Saves all stored gamepad mappings to a plain-text file, one entry per line.
---@param path any
function luna.input.saveGamepadMappings(path) end

--- Enable or disable receiving gamepad events when the window is not focused.
---@param enable any
function luna.input.setBackgroundEvents(enable) end

--- Sets the currently visible mouse cursor to the given hardware cursor handle.
---@param cursor number Cursor ID returned by newCursor or getSystemCursor, or nil to reset.
function luna.input.setCursor(cursor) end

--- Stores or replaces the SDL2 GameControllerDB mapping string for the given GUID.
---@param guid any
---@param mapping any
function luna.input.setGamepadMapping(guid, mapping) end

--- Locks or unlocks the mouse cursor to the window.
---@param grabbed any
function luna.input.setGrabbed(grabbed) end

--- Enables or disables key-repeat events.
---@param enabled any
function luna.input.setKeyRepeat(enabled) end

--- Moves the mouse cursor to the given window-space position.
---@param x any
---@param y any
function luna.input.setPosition(x, y) end

--- Enables or disables raw relative mouse motion mode.
---@param relative any
function luna.input.setRelativeMode(relative) end

--- Enables or disables Unicode text input mode.
---@param enabled any
function luna.input.setTextInput(enabled) end

--- Triggers haptic rumble with the given left/right motor strengths.
---@param args any
---@return boolean
function luna.input.setVibration(args) end

--- Shows or hides the operating-system mouse cursor over the game window.
---@param visible number true to show the cursor, false to hide it.
function luna.input.setVisible(visible) end

---@class luna.light
luna.light = {}

--- Lua UserData wrapper for a light resource.
---@class Light
local Light = {}

function Light:getAttenuation() end

function Light:getBlendMode() end

function Light:getColor() end

function Light:getDirection() end

function Light:getEnergy() end

function Light:getFalloff() end

function Light:getFlicker() end

function Light:getGroupId() end

function Light:getInnerAngle() end

function Light:getIntensity() end

function Light:getLightMask() end

function Light:getLightType() end

function Light:getOuterAngle() end

function Light:getPosition() end

function Light:getRadius() end

function Light:getShadowColor() end

function Light:getShadowFilter() end

function Light:getShadowMask() end

function Light:getShadowSmooth() end

function Light:isEnabled() end

function Light:isFlickerEnabled() end

function Light:isShadowEnabled() end

function Light:isValid() end

function Light:isVolumetric() end

function Light:remove() end

---@param c any
---@param l any
---@param q any
function Light:setAttenuation(c, l, q) end

---@param mode any
function Light:setBlendMode(mode) end

---@param dir any
function Light:setDirection(dir) end

---@param b any
function Light:setEnabled(b) end

---@param e any
function Light:setEnergy(e) end

---@param mode any
function Light:setFalloff(mode) end

---@param speed any
---@param strength any
function Light:setFlicker(speed, strength) end

---@param b any
function Light:setFlickerEnabled(b) end

---@param id any
function Light:setGroupId(id) end

---@param a any
function Light:setInnerAngle(a) end

---@param i any
function Light:setIntensity(i) end

---@param mask any
function Light:setLightMask(mask) end

---@param t any
function Light:setLightType(t) end

---@param a any
function Light:setOuterAngle(a) end

---@param x any
---@param y any
function Light:setPosition(x, y) end

---@param r any
function Light:setRadius(r) end

---@param b any
function Light:setShadowEnabled(b) end

---@param filter any
function Light:setShadowFilter(filter) end

---@param mask any
function Light:setShadowMask(mask) end

---@param s any
function Light:setShadowSmooth(s) end

---@param b any
function Light:setVolumetric(b) end

--- Lua UserData wrapper for an occluder resource.
---@class Occluder
local Occluder = {}

function Occluder:getLightMask() end

function Occluder:getOpacity() end

function Occluder:getPosition() end

function Occluder:getVertices() end

function Occluder:isEnabled() end

function Occluder:isValid() end

function Occluder:remove() end

---@param b any
function Occluder:setEnabled(b) end

---@param mask any
function Occluder:setLightMask(mask) end

---@param o any
function Occluder:setOpacity(o) end

---@param x any
---@param y any
function Occluder:setPosition(x, y) end

---@param tbl any
function Occluder:setVertices(tbl) end

---@param dt any
function luna.light.advanceFlickers(dt) end

function luna.light.clear() end

function luna.light.getAmbient() end

---@param group_id any
function luna.light.getGroupCount(group_id) end

function luna.light.getLightCount() end

function luna.light.getMaxLights() end

function luna.light.getOccluderCount() end

function luna.light.isEnabled() end

---@param x any
---@param y any
---@param radius any
---@param opts? any (optional)
function luna.light.newLight(x, y, radius, opts) end

---@param tbl any
---@param opts? any (optional)
function luna.light.newOccluder(tbl, opts) end

---@param r any
---@param g any
---@param b any
---@param a? any (optional)
function luna.light.setAmbient(r, g, b, a) end

---@param enabled any
function luna.light.setEnabled(enabled) end

---@param group_id any
---@param r any
---@param g any
---@param b any
---@param a? any (optional)
function luna.light.setGroupColor(group_id, r, g, b, a) end

---@param group_id any
---@param enabled any
function luna.light.setGroupEnabled(group_id, enabled) end

---@param group_id any
---@param intensity any
function luna.light.setGroupIntensity(group_id, intensity) end

---@param n any
function luna.light.setMaxLights(n) end

---@class luna.localization
luna.localization = {}

--- Returns the available languages.
---@return any
function luna.localization.getAvailableLanguages() end

--- Returns the base.
---@return any
function luna.localization.getBase() end

--- Returns the language.
---@return any
function luna.localization.getLanguage() end

--- Returns true if language.
---@param lang any
---@return any
function luna.localization.hasLanguage(lang) end

--- Load table.
---@param lang any
---@param table any
function luna.localization.loadTable(lang, table) end

--- Off change.
---@param callback any
function luna.localization.offChange(callback) end

--- On change.
---@param callback any
function luna.localization.onChange(callback) end

--- Sets the base.
---@param lang any
function luna.localization.setBase(lang) end

--- Sets the language.
---@param lang any
function luna.localization.setLanguage(lang) end

--- T.
---@param key any
---@param vars? any (optional)
---@return any
function luna.localization.t(key, vars) end

---@class luna.log
luna.log = {}

--- Emit a debug-severity log message from Lua.
---@param message string The message string to log.
function luna.log.debug(message) end

--- Emit an error-severity log message from Lua.
---@param message string The message string to log.
function luna.log.error(message) end

--- Return the name of the currently active minimum log level.
---@return any
function luna.log.getLevel() end

--- Emit an info-severity log message from Lua.
---@param message string The message string to log.
function luna.log.info(message) end

--- Emit a log message from Lua at the specified severity level.
---@param level string Severity level string.
---@param message string The message string to log.
function luna.log.print(level, message) end

--- Set the minimum severity level for runtime log messages.
---@param level any One of `"off"`, `"error"`, `"warn"`, `"info"`, `"debug"`, `"trace"`.
function luna.log.setLevel(level) end

--- Emit a warn-severity log message from Lua.
---@param message string The message string to log.
function luna.log.warn(message) end

---@class luna.math
luna.math = {}

---@class BezierCurve
local BezierCurve = {}

--- Evaluates the curve at parameter t in [0, 1] and returns the world point.
---@param t any â€” Curve parameter in the range [0, 1].
---@return number
---@return number
function BezierCurve:evaluate(t) end

--- Returns the position of the control point at the given index.
---@param i number â€” 1-based index of the control point.
---@return number
---@return number
function BezierCurve:getControlPoint(i) end

--- Returns the total number of control points in the curve.
---@return number
function BezierCurve:getControlPointCount() end

--- Returns a new BezierCurve that is the derivative (degree reduced) of this curve.
---@return any
function BezierCurve:getDerivative() end

--- Removes the control point at the given index from the curve.
---@param i number â€” 1-based index of the control point to remove.
function BezierCurve:removeControlPoint(i) end

--- Subdivides the curve to the given depth and returns the sample points.
---@param depth number â€” Subdivision depth; higher values yield smoother output.
---@return number
---@return number
function BezierCurve:render(depth) end

--- Shifts every control point by the given (dx, dy) offset in place.
---@param dx number â€” Horizontal offset in pixels.
---@param dy number â€” Vertical offset in pixels.
function BezierCurve:translate(dx, dy) end

---@class Grid
local Grid = {}

--- Build flow field on this Grid.
---@param gx number â€” `integer`.
---@param gy number â€” `integer`.
function Grid:buildFlowField(gx, gy) end

--- Returns the cost.
---@param x number â€” `integer`.
---@param y number â€” `integer`.
---@return any
function Grid:getCost(x, y) end

--- Returns the dimensions.
---@param x number â€” `integer`.
---@param y number â€” `integer`.
---@param w boolean â€” `boolean`.
---@return any
function Grid:getDimensions(x, y, w) end

--- Returns the height.
---@param x number â€” `integer`.
---@param y number â€” `integer`.
---@param w boolean â€” `boolean`.
---@return number
function Grid:getHeight(x, y, w) end

--- Returns the width.
---@param x number â€” `integer`.
---@param y number â€” `integer`.
---@param w boolean â€” `boolean`.
---@return number
function Grid:getWidth(x, y, w) end

--- Returns `true` if walkable.
---@param x number â€” `integer`.
---@param y number â€” `integer`.
---@return boolean
function Grid:isWalkable(x, y) end

--- Sets the cost.
---@param x number â€” `integer`.
---@param y number â€” `integer`.
---@param cost number â€” `number`.
function Grid:setCost(x, y, cost) end

--- Sets the walkable.
---@param x number â€” `integer`.
---@param y number â€” `integer`.
---@param w boolean â€” `boolean`.
function Grid:setWalkable(x, y, w) end

---@class NoiseGenerator
local NoiseGenerator = {}

--- Returns the seed.
---@param args any â€” `LuaMultiValue`.
---@return any
function NoiseGenerator:getSeed(args) end

--- Perlin noise on this NoiseGenerator.
---@param args any â€” `LuaMultiValue`.
function NoiseGenerator:perlinNoise(args) end

--- Sets the seed.
---@param seed number â€” `integer`.
function NoiseGenerator:setSeed(seed) end

--- Simplex noise on this NoiseGenerator.
---@param args any â€” `LuaMultiValue`.
function NoiseGenerator:simplexNoise(args) end

---@class RandomGenerator
local RandomGenerator = {}

--- Returns the current random seed value.
function RandomGenerator:getSeed() end

--- Returns the full PRNG state as a string for later restoration.
function RandomGenerator:getState() end

--- Seeds this random generator with the given integer, resetting its sequence.
---@param seed number â€” Integer seed value. Use 0 to seed from system time.
function RandomGenerator:setSeed(seed) end

--- Restores the PRNG state from a string returned by getState.
---@param state any
function RandomGenerator:setState(state) end

---@class Raycaster2D
local Raycaster2D = {}

--- Returns the cell.
---@param x number â€” `integer`.
---@param y number â€” `integer`.
---@return any
function Raycaster2D:getCell(x, y) end

--- Returns the dimensions.
---@param x number â€” `integer`.
---@param y number â€” `integer`.
---@param val number â€” `integer`.
---@return any
function Raycaster2D:getDimensions(x, y, val) end

--- Returns the height.
---@param x number â€” `integer`.
---@param y number â€” `integer`.
---@param val number â€” `integer`.
---@return number
function Raycaster2D:getHeight(x, y, val) end

--- Returns the width.
---@param x number â€” `integer`.
---@param y number â€” `integer`.
---@param val number â€” `integer`.
---@return number
function Raycaster2D:getWidth(x, y, val) end

--- Returns `true` if blocked.
---@param x number â€” `integer`.
---@param y number â€” `integer`.
---@return boolean
function Raycaster2D:isBlocked(x, y) end

--- Sets the cell.
---@param x number â€” `integer`.
---@param y number â€” `integer`.
---@param val number â€” `integer`.
function Raycaster2D:setCell(x, y, val) end

--- Sets the cells.
---@param data table â€” `table`.
function Raycaster2D:setCells(data) end

---@class SpatialHash
local SpatialHash = {}

--- Removes all entries.
---@param x number â€” `number`.
---@param y number â€” `number`.
---@param w number â€” `number`.
---@param h number â€” `number`.
function SpatialHash:clear(x, y, w, h) end

--- Returns the cell size.
---@param id number â€” `any`.
---@param x number â€” `number`.
---@param y number â€” `number`.
---@param w number â€” `number`.
---@param h number â€” `number`.
---@return any
function SpatialHash:getCellSize(id, x, y, w, h) end

--- Returns the item count.
---@return any
function SpatialHash:getItemCount() end

--- Query circle on this SpatialHash.
---@param cx number â€” `number`.
---@param cy number â€” `number`.
---@param r number â€” `number`.
function SpatialHash:queryCircle(cx, cy, r) end

--- Removes the entry from the collection.
---@param id number â€” `any`.
---@param x number â€” `number`.
---@param y number â€” `number`.
---@param w number â€” `number`.
---@param h number â€” `number`.
function SpatialHash:remove(id, x, y, w, h) end

---@class TileWalker
local TileWalker = {}

--- Begin move on this TileWalker.
---@param t number â€” `number`.
function TileWalker:beginMove(t) end

--- Returns `true` if move backward.
---@return boolean
function TileWalker:canMoveBackward() end

--- Returns `true` if move forward.
---@return boolean
function TileWalker:canMoveForward() end

--- Returns `true` if strafe left.
---@return boolean
function TileWalker:canStrafeLeft() end

--- Returns `true` if strafe right.
---@param t number â€” `number`.
---@return boolean
function TileWalker:canStrafeRight(t) end

--- Returns the facing.
---@param facing string â€” `string`.
---@return any
function TileWalker:getFacing(facing) end

--- Returns the facing angle.
---@return number
function TileWalker:getFacingAngle() end

--- Returns the facing direction.
---@return any
function TileWalker:getFacingDirection() end

--- Returns the interpolated angle.
---@param tx number â€” `integer`.
---@param ty number â€” `integer`.
---@return number
function TileWalker:getInterpolatedAngle(tx, ty) end

--- Returns the interpolated position.
---@param t number â€” `number`.
---@return number
function TileWalker:getInterpolatedPosition(t) end

--- Returns the position.
---@param x number â€” `integer`.
---@param y number â€” `integer`.
---@return any
function TileWalker:getPosition(x, y) end

--- Returns the relative facing.
---@param tx number â€” `integer`.
---@param ty number â€” `integer`.
---@return any
function TileWalker:getRelativeFacing(tx, ty) end

--- Move backward on this TileWalker.
---@return any
function TileWalker:moveBackward() end

--- Move forward on this TileWalker.
---@return any
function TileWalker:moveForward() end

--- Sets the facing.
---@param facing string â€” `string`.
function TileWalker:setFacing(facing) end

--- Sets the position.
---@param x number â€” `integer`.
---@param y number â€” `integer`.
function TileWalker:setPosition(x, y) end

--- Strafe left on this TileWalker.
---@return any
function TileWalker:strafeLeft() end

--- Strafe right on this TileWalker.
---@return any
function TileWalker:strafeRight() end

--- Turn around on this TileWalker.
---@param rc_ud any â€” `userdata`.
function TileWalker:turnAround(rc_ud) end

--- Turn left on this TileWalker.
---@return any
function TileWalker:turnLeft() end

--- Turn right on this TileWalker.
---@return any
function TileWalker:turnRight() end

---@class Transform
local Transform = {}

--- Returns an independent deep copy of this transform object.
---@return number
function Transform:clone() end

--- Returns the 16 matrix elements of the 4x4 transform in column-major order.
---@return number
function Transform:getMatrix() end

--- Returns a new Transform that is the mathematical inverse of this one.
---@return number
function Transform:inverse() end

--- Applies the inverse of this transform to the given point.
---@param x number â€” Input X coordinate.
---@param y number â€” Input Y coordinate.
---@return number
---@return number
function Transform:inverseTransformPoint(x, y) end

--- Resets the internal matrix to the identity (no transform applied).
function Transform:reset() end

--- Applies a rotation by the given angle to the internal matrix.
---@param angle number â€” Rotation angle in radians.
function Transform:rotate(angle) end

--- Applies a scale factor to the transform's internal matrix.
---@param sx number â€” Horizontal scale factor.
---@param sy number â€” Vertical scale factor (defaults to sx if omitted).
function Transform:scale(sx, sy) end

--- Applies a shear (skew) transformation to the internal matrix.
---@param kx any â€” Horizontal shear factor.
---@param ky any â€” Vertical shear factor.
function Transform:shear(kx, ky) end

--- Transforms a point (x, y) by this matrix and returns the result.
---@param x number â€” Input X coordinate.
---@param y number â€” Input Y coordinate.
---@return number
---@return number
function Transform:transformPoint(x, y) end

--- Applies a translation offset to the internal matrix.
---@param dx number â€” Horizontal offset in pixels.
---@param dy number â€” Vertical offset in pixels.
function Transform:translate(dx, dy) end

---@class Tween
local Tween = {}

--- Adds value to the collection.
---@param start number â€” `number`.
---@param target number â€” `number`.
function Tween:addValue(start, target) end

--- Returns the clock.
---@return any
function Tween:getClock() end

--- Returns the duration.
---@return any
function Tween:getDuration() end

--- Returns the value.
---@param index? number â€” `integer` optional.
---@return any
function Tween:getValue(index) end

--- Returns the value count.
---@param time number â€” `number`.
---@return any
function Tween:getValueCount(time) end

--- Returns `true` if complete.
---@return boolean
function Tween:isComplete() end

--- Resets state to initial values.
---@param time number â€” `number`.
function Tween:reset(time) end

--- Sets the value.
---@param time number â€” `number`.
function Tween:set(time) end

--- Advances the simulation by `dt` seconds.
---@param dt number â€” `number`.
function Tween:update(dt) end

---@class Vec2
local Vec2 = {}

--- Returns a deep copy of this object.
---@param other any â€” `userdata`.
function Vec2:clone(other) end

--- Cross on this Vec2.
---@param other any â€” `userdata`.
function Vec2:cross(other) end

--- Dot on this Vec2.
---@param other any â€” `userdata`.
function Vec2:dot(other) end

--- Returns the current value.
---@param x number â€” `number`.
---@param y number â€” `number`.
---@return any
function Vec2:get(x, y) end

--- Returns the angle.
---@param other any â€” `userdata`.
---@return number
function Vec2:getAngle(other) end

--- Returns the distance.
---@param other any â€” `userdata`.
---@return any
function Vec2:getDistance(other) end

--- Returns the length.
---@param other any â€” `userdata`.
---@return any
function Vec2:getLength(other) end

--- Returns the length squared.
---@param other any â€” `userdata`.
---@return any
function Vec2:getLengthSquared(other) end

--- Returns the normalized.
---@param angle number â€” `number`.
---@return any
function Vec2:getNormalized(angle) end

--- Returns the perpendicular.
---@param other any â€” `userdata`.
---@param t number â€” `number`.
---@return any
function Vec2:getPerpendicular(other, t) end

--- Returns the rotated.
---@param angle number â€” `number`.
---@return any
function Vec2:getRotated(angle) end

--- Returns the x.
---@param x number â€” `number`.
---@return number
function Vec2:getX(x) end

--- Returns the y.
---@param x number â€” `number`.
---@return number
function Vec2:getY(x) end

--- Interpolates between start and target values.
---@param other any â€” `userdata`.
---@param t number â€” `number`.
function Vec2:lerp(other, t) end

--- Sets the value.
---@param x number â€” `number`.
---@param y number â€” `number`.
function Vec2:set(x, y) end

--- Sets the x.
---@param x number â€” `number`.
function Vec2:setX(x) end

--- Sets the y.
---@param y number â€” `number`.
function Vec2:setY(y) end

--- Returns the absolute (non-negative) value of x.
---@param x number â€” Input number.
---@return number
function luna.math.abs(x) end

--- luna.math.angleBetween(x1, y1, x2, y2)
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
function luna.math.angleBetween(x1, y1, x2, y2) end

--- Returns the angle in radians between the positive x-axis and (y, x).
---@param y number â€” Y component.
---@param x number â€” X component.
---@return number
function luna.math.atan2(y, x) end

--- luna.math.bresenham(x1, y1, x2, y2)
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
function luna.math.bresenham(x1, y1, x2, y2) end

--- luna.math.castRay2D(ox, oy, dx, dy, maxDist, segments)
---@param ox any
---@param oy any
---@param dx any
---@param dy any
---@param max_dist any
---@param segs_tbl any
function luna.math.castRay2D(ox, oy, dx, dy, max_dist, segs_tbl) end

--- Returns the smallest integer greater than or equal to x (rounds up).
---@param x number â€” Input number.
---@return number
function luna.math.ceil(x) end

--- luna.math.cellularAutomata(width, height, opts)
---@param w any
---@param h any
---@param opts_tbl? any (optional)
function luna.math.cellularAutomata(w, h, opts_tbl) end

--- luna.math.circleContainsPoint(cx, cy, r, px, py)
---@param cx any
---@param cy any
---@param r any
---@param px any
---@param py any
function luna.math.circleContainsPoint(cx, cy, r, px, py) end

--- luna.math.circleIntersectsCircle(x1, y1, r1, x2, y2, r2)
---@param x1 any
---@param y1 any
---@param r1 any
---@param x2 any
---@param y2 any
---@param r2 any
function luna.math.circleIntersectsCircle(x1, y1, r1, x2, y2, r2) end

--- luna.math.circleIntersectsLine(cx, cy, r, lx1, ly1, lx2, ly2)
---@param cx any
---@param cy any
---@param r any
---@param lx1 any
---@param ly1 any
---@param lx2 any
---@param ly2 any
function luna.math.circleIntersectsLine(cx, cy, r, lx1, ly1, lx2, ly2) end

--- luna.math.circleIntersectsSegment(cx, cy, r, sx1, sy1, sx2, sy2)
---@param cx any
---@param cy any
---@param r any
---@param sx1 any
---@param sy1 any
---@param sx2 any
---@param sy2 any
function luna.math.circleIntersectsSegment(cx, cy, r, sx1, sy1, sx2, sy2) end

--- Clamps a value between min and max.
---@param x any
---@param lo any
---@param hi any
function luna.math.clamp(x, lo, hi) end

--- luna.math.closestPointOnSegment(px, py, x1, y1, x2, y2)
---@param px any
---@param py any
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
function luna.math.closestPointOnSegment(px, py, x1, y1, x2, y2) end

--- Computes and returns the convex hull of a set of 2D points as an ordered vertex list.
---@param points number â€” Table of {x, y} point tables or flat coordinate array.
---@return number
---@return number
function luna.math.convexHull(points) end

--- Returns the cosine of the given angle in radians.
---@param angle number â€” Angle in radians.
---@return any
function luna.math.cos(angle) end

--- luna.math.delaunayTriangulate(points)
---@param tbl any
function luna.math.delaunayTriangulate(tbl) end

--- Returns the Euclidean distance between two points.
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
function luna.math.distance(x1, y1, x2, y2) end

--- luna.math.distanceShade(distance, maxDistance)
---@param distance any
---@param max_dist any
function luna.math.distanceShade(distance, max_dist) end

--- Applies an easing function to t in [0,1].
---@param name any
---@param t any
function luna.math.ease(name, t) end

--- luna.math.fieldOfView(ox, oy, segments, radius)
---@param ox any
---@param oy any
---@param segs_tbl any
---@param radius any
function luna.math.fieldOfView(ox, oy, segs_tbl, radius) end

--- luna.math.floodFill(data, width, height, sx, sy, threshold, mode)
function luna.math.floodFill() end

--- Returns the largest integer less than or equal to x (rounds down).
---@param x number â€” Input number.
---@return number
function luna.math.floor(x) end

--- Converts a sRGB gamma-encoded channel value to linear light intensity.
---@param c any â€” Gamma-encoded channel value in [0, 1].
---@return any
function luna.math.gammaToLinear(c) end

--- Returns the current seed of the engine global random number generator.
---@return number
function luna.math.getRandomSeed() end

--- Returns whether a polygon described by points is convex.
---@param args any
function luna.math.isConvex(args) end

--- Linearly interpolates between a and b by t.
---@param a any
---@param b any
---@param t any
function luna.math.lerp(a, b, t) end

--- luna.math.lineIntersect(x1, y1, x2, y2, x3, y3, x4, y4)
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
---@param x3 any
---@param y3 any
---@param x4 any
---@param y4 any
function luna.math.lineIntersect(x1, y1, x2, y2, x3, y3, x4, y4) end

--- Converts a linear-light channel value to sRGB gamma-encoded space.
---@param c any â€” Linear-light value in [0, 1].
---@return any
function luna.math.linearToGamma(c) end

--- Returns the largest value from the given list of numbers.
---@param ... any â€” One or more numeric arguments.
---@return number
function luna.math.max(...) end

--- Returns the smallest value from the given list of numbers.
---@param ... any â€” One or more numeric arguments.
---@return any
function luna.math.min(...) end

--- Creates a new Bezier curve from the given control points.
---@param args any
function luna.math.newBezierCurve(args) end

--- luna.math.newGrid(width, height, defaultCost)
---@param w any
---@param h any
---@param cost? any (optional)
function luna.math.newGrid(w, h, cost) end

--- Creates a reusable Perlin/simplex noise generator with a given seed.
---@param seed number â€” Integer seed for the noise generator.
---@return any
function luna.math.newNoiseGenerator(seed) end

--- Creates an independent random generator with its own seed.
---@param seed? any (optional)
function luna.math.newRandomGenerator(seed) end

--- luna.math.newRaycaster2D(width, height)
---@param w any
---@param h any
function luna.math.newRaycaster2D(w, h) end

--- Creates a spatial hash grid for fast broad-phase proximity and overlap queries.
---@param cellSize number â€” Width and height of each hash cell in world units.
---@return any
function luna.math.newSpatialHash(cellSize) end

--- luna.math.newTileWalker(x, y, facing)
---@param x any
---@param y any
---@param facing? any (optional)
function luna.math.newTileWalker(x, y, facing) end

--- Creates a new affine Transform object.
function luna.math.newTransform() end

--- luna.math.newTween(duration, easing)
---@param duration any
---@param easing? any (optional)
function luna.math.newTween(duration, easing) end

--- Creates a new 2-component vector object with x and y fields.
---@param x number â€” X component (default 0).
---@param y number â€” Y component (default 0).
---@return any
function luna.math.newVec2(x, y) end

--- Returns a smooth noise value (1D, 2D, or 3D).
---@param x any
---@param y? any (optional)
---@param z? any (optional)
---@param w? any (optional)
function luna.math.noise(x, y, z, w) end

--- Normalizes an angle in radians into the canonical range [-pi, pi].
---@param angle number â€” Angle in radians.
---@return number
function luna.math.normalize(angle) end

--- luna.math.perlinNoisePeriodic(x, y, px, py)
---@param x any
---@param y any
---@param px any
---@param py any
function luna.math.perlinNoisePeriodic(x, y, px, py) end

--- luna.math.pointInPolygon(vertices, px, py)
---@param tbl any
---@param px any
---@param py any
function luna.math.pointInPolygon(tbl, px, py) end

--- luna.math.poissonDisk(width, height, minDist, maxAttempts, seed)
---@param w any
---@param h any
---@param min_dist any
---@param max_attempts? any (optional)
---@param seed? any (optional)
function luna.math.poissonDisk(w, h, min_dist, max_attempts, seed) end

--- Returns the signed area of a simple polygon described by its vertex list.
---@param vertices number â€” Table of {x, y} tables or flat coordinate array.
---@return number
function luna.math.polygonArea(vertices) end

--- luna.math.polygonCentroid(vertices)
---@param tbl any
function luna.math.polygonCentroid(tbl) end

--- luna.math.projectColumn(distance, fov, screenHeight)
---@param distance any
---@param fov any
---@param screen_h any
function luna.math.projectColumn(distance, fov, screen_h) end

--- Returns a pseudo-random number. No args: [0,1). One arg max: [1,max]. Two args min,max: [min,max].
---@param min? any (optional)
---@param max? any (optional)
function luna.math.random(min, max) end

--- Returns a normally distributed random number.
---@param stddev? any (optional)
---@param mean? any (optional)
function luna.math.randomNormal(stddev, mean) end

--- luna.math.segmentIntersectsSegment(x1, y1, x2, y2, x3, y3, x4, y4)
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
---@param x3 any
---@param y3 any
---@param x4 any
---@param y4 any
function luna.math.segmentIntersectsSegment(x1, y1, x2, y2, x3, y3, x4, y4) end

--- Seeds the engine global random number generator with the given integer.
---@param seed number â€” Integer seed value; use 0 to seed from system time.
function luna.math.setRandomSeed(seed) end

--- Standalone simplex noise: returns a value in approximately `[-1, 1]` for 1â€“3 coordinates.
---@param x number â€” X coordinate.
---@param y? number â€” Y coordinate (optional, defaults to 0).
---@param z? string â€” Z coordinate (optional; enables 3-D mode).
---@return number
function luna.math.simplexNoise(x, y, z) end

--- Returns the sine of the given angle in radians.
---@param angle number â€” Angle in radians.
---@return any
function luna.math.sin(angle) end

--- Returns the positive square root of x.
---@param x number â€” Non-negative input number.
---@return number
function luna.math.sqrt(x) end

--- Returns the tangent of the given angle in radians.
---@param angle number â€” Angle in radians.
---@return any
function luna.math.tan(angle) end

--- Triangulates a simple polygon and returns index triples.
---@param args any
function luna.math.triangulate(args) end

--- luna.math.voronoiDiagram(width, height, points, opts)
---@param w any
---@param h any
---@param pts_tbl any
---@param opts_tbl? any (optional)
function luna.math.voronoiDiagram(w, h, pts_tbl, opts_tbl) end

---@class luna.minimap
luna.minimap = {}

---@class Minimap
local Minimap = {}

function Minimap:addMarker() end

--- Adds ping to the collection.
---@return any
function Minimap:addPing() end

--- Clear objects on this Minimap.
---@return any
function Minimap:clearObjects() end

--- Clear viewport rect on this Minimap.
---@return any
function Minimap:clearViewportRect() end

--- Returns the center.
---@return any
function Minimap:getCenter() end

--- Returns the center X coordinate.
---@return number
function Minimap:getCenterX() end

--- Returns the center Y coordinate.
---@return number
function Minimap:getCenterY() end

--- Returns the color mode.
---@return string
function Minimap:getColorMode() end

--- Returns the display height.
---@return number
function Minimap:getDisplayHeight() end

--- Returns the display size.
---@param w number `integer`.
---@param h number `integer`.
---@return number
function Minimap:getDisplaySize(w, h) end

--- Returns the display width.
---@return number
function Minimap:getDisplayWidth() end

--- Returns the fog color.
---@param data table `table`.
---@return any
function Minimap:getFogColor(data) end

--- Returns the fog level.
---@param x number `integer`.
---@param y number `integer`.
---@return any
function Minimap:getFogLevel(x, y) end

--- Returns the grid height.
---@return number
function Minimap:getGridHeight() end

--- Returns the grid size.
---@return number
function Minimap:getGridSize() end

--- Returns the grid width.
---@return number
function Minimap:getGridWidth() end

--- Returns the marker count.
---@param enabled boolean `boolean`.
---@return any
function Minimap:getMarkerCount(enabled) end

--- Returns the marker description.
---@param id number `integer`.
---@return any
function Minimap:getMarkerDescription(id) end

--- Returns the object count.
---@return any
function Minimap:getObjectCount() end

--- Returns the object type count.
---@return number
function Minimap:getObjectTypeCount() end

--- Returns the owner color.
---@param owner number `integer`.
---@return any
function Minimap:getOwnerColor(owner) end

--- Returns the ping count.
---@return any
function Minimap:getPingCount() end

--- Returns the terrain.
---@param x number `integer`.
---@param y number `integer`.
---@return any
function Minimap:getTerrain(x, y) end

--- Returns the terrain color.
---@param terrain_type number `integer`.
---@return any
function Minimap:getTerrainColor(terrain_type) end

--- Get the hover tooltip string for a terrain type ID, or nil if not set.
---@param type_id number `integer`.
---@return string
function Minimap:getTileDescription(type_id) end

--- Returns the viewport color.
---@return any
function Minimap:getViewportColor() end

--- Returns the viewport rect.
---@return any
function Minimap:getViewportRect() end

--- Returns the zoom.
---@param x number `number`.
---@param y number `number`.
---@return any
function Minimap:getZoom(x, y) end

--- Returns `true` if marker.
---@param id number `integer`.
---@return boolean
function Minimap:hasMarker(id) end

--- Returns `true` if anti alias.
---@return boolean
function Minimap:isAntiAlias() end

--- Returns whether this minimap responds to click hit-testing.
---@return boolean
function Minimap:isClickable() end

--- Returns `true` if fog enabled.
---@param x number `integer`.
---@param y number `integer`.
---@param level number `integer`.
---@return boolean
function Minimap:isFogEnabled(x, y, level) end

--- Returns `true` if object type visible.
---@param type_idx number `integer`.
---@return boolean
function Minimap:isObjectTypeVisible(type_idx) end

--- Returns `true` if viewport visible.
---@param r number `number`.
---@param g number `number`.
---@param b number `number`.
---@param a? number `number` optional.
---@return boolean
function Minimap:isViewportVisible(r, g, b, a) end

--- Removes marker from the collection.
---@param id number `integer`.
---@return any
function Minimap:removeMarker(id) end

--- Removes object from the collection.
---@param id number `integer`.
---@return any
function Minimap:removeObject(id) end

--- Sets the anti alias.
---@param enabled boolean `boolean`.
function Minimap:setAntiAlias(enabled) end

--- Sets the center.
---@param x number `number`.
---@param y number `number`.
function Minimap:setCenter(x, y) end

--- Set whether this minimap responds to click hit-testing.
---@param enabled boolean `boolean`.
function Minimap:setClickable(enabled) end

--- Sets the color mode.
---@param mode string `string`.
function Minimap:setColorMode(mode) end

--- Sets the display size.
---@param w number `integer`.
---@param h number `integer`.
function Minimap:setDisplaySize(w, h) end

--- Sets the fog data.
---@param data table `table`.
function Minimap:setFogData(data) end

--- Sets the fog enabled.
---@param enabled boolean `boolean`.
function Minimap:setFogEnabled(enabled) end

---@param x any
---@param y any
---@param level any
function Minimap:setFogLevel(x, y, level) end

--- Sets the terrain data from a flat 1-based Lua table of integers (row-major).
---@param data table `table`.
function Minimap:setTerrainData(data) end

--- Sets the viewport visible.
---@param visible boolean `boolean`.
function Minimap:setViewportVisible(visible) end

--- Sets the zoom.
---@param zoom number `number`.
function Minimap:setZoom(zoom) end

--- Advances the simulation by `dt` seconds.
---@param dt number `number`.
function Minimap:update(dt) end

--- New minimap.
---@param grid_w any
---@param grid_h any
---@param display_w? any (optional)
---@param display_h? any (optional)
---@return any
function luna.minimap.newMinimap(grid_w, grid_h, display_w, display_h) end

---@class luna.modding
luna.modding = {}

---@class mlua
local mlua = {}

--- Clear load order on this ModManager.
---@return any
function mlua:clearLoadOrder() end

--- Clear reload queue on this ModManager.
---@return any
function mlua:clearReloadQueue() end

--- Returns the all mods.
---@return any
function mlua:getAllMods() end

--- Returns the author.
---@return any
function mlua:getAuthor() end

--- Returns the config.
---@return any
function mlua:getConfig() end

--- Returns the dependencies.
---@return any
function mlua:getDependencies() end

--- Returns the description.
---@return any
function mlua:getDescription() end

--- Returns the hook.
---@param name string `string`.
---@return any
function mlua:getHook(name) end

--- Returns the hook names.
---@return any
function mlua:getHookNames() end

--- Returns the id.
---@return number
function mlua:getId() end

--- Returns the load order.
---@return any
function mlua:getLoadOrder() end

--- Returns the mod count.
---@return any
function mlua:getModCount() end

--- Returns the mod path.
---@param mod_id string `string`.
---@return string
function mlua:getModPath(mod_id) end

--- Returns the name.
---@return any
function mlua:getName() end

--- Returns the priority.
---@param enabled boolean `boolean`.
---@return number
function mlua:getPriority(enabled) end

--- Returns the reload queue.
---@return any
function mlua:getReloadQueue() end

--- Returns the version.
---@return any
function mlua:getVersion() end

--- Returns `true` if circular dependencies.
---@param order_table table `table`.
---@return boolean
function mlua:hasCircularDependencies(order_table) end

--- Returns `true` if hook.
---@param name string `string`.
---@return boolean
function mlua:hasHook(name) end

--- Returns `true` if mod.
---@param mod_id string `string`.
---@return boolean
function mlua:hasMod(mod_id) end

--- Returns `true` if enabled.
---@param enabled boolean `boolean`.
---@return boolean
function mlua:isEnabled(enabled) end

--- Returns `true` if loaded.
---@param name string `string`.
---@param func function `function`.
---@return boolean
function mlua:isLoaded(name, func) end

--- Mark for reload on this ModManager.
---@param mod_id string `string`.
---@return any
function mlua:markForReload(mod_id) end

--- Adds mod to the collection.
---@param ud any `userdata`.
function mlua:registerMod(ud) end

--- Release refs on this Mod.
---@return any
function mlua:releaseRefs() end

--- Scan folder on this ModManager.
---@param path string `string`.
---@return any
function mlua:scanFolder(path) end

--- Sets the config.
---@param value number `any`.
function mlua:setConfig(value) end

--- Sets the enabled.
---@param enabled boolean `boolean`.
function mlua:setEnabled(enabled) end

--- Sets the load order.
---@param order_table table `table`.
function mlua:setLoadOrder(order_table) end

--- Removes mod from the collection.
---@param mod_id string `string`.
function mlua:unregisterMod(mod_id) end

--- Validate dependencies on this ModManager.
---@return any
function mlua:validateDependencies() end

--- New mod.
---@param info any
---@return any
function luna.modding.newMod(info) end

--- New mod manager.
function luna.modding.newModManager() end

---@class luna.network
luna.network = {}

--- Lua UserData wrapper for a [`NetworkHost`].
---@class NetworkHost
local NetworkHost = {}

--- Gracefully disconnects a peer. The disconnect event arrives on the next `service()`.
---@param peer_id_raw any
---@param data? any (optional)
function NetworkHost:disconnect(peer_id_raw, data) end

--- Flushes pending sends immediately.
function NetworkHost:flush() end

--- Returns the local address of this host as `"ip:port"`.
---@return string
function NetworkHost:getAddress() end

--- Polls the network for one event. Returns an event table or `nil`.
---@return table|nil
function NetworkHost:service() end

--- Creates a new [`NetworkHost`] bound to the given address.
---@param opts any
---@return NetworkHost
function luna.network.newHost(opts) end

---@class luna.overlay
luna.overlay = {}

---@class Overlay
local Overlay = {}

--- Resets all overlay subsystems to their inactive defaults.
function Overlay:clear() end

--- Placeholder for draw â€” actual rendering handled by the game loop.
function Overlay:draw() end

--- Returns the current ambient tint colour as `(r, g, b, a)`.
---@return number
function Overlay:getAmbientColor() end

--- Returns the current cloud shadow blob count.
---@return number
function Overlay:getCloudCount() end

--- Returns the cloud shadow opacity (0.0â€“1.0).
---@return number
function Overlay:getCloudOpacity() end

--- Returns the cloud shadow blob size scale.
---@return number
function Overlay:getCloudScale() end

--- Returns the cloud shadow scroll speed in pixels per second.
---@return number
function Overlay:getCloudSpeed() end

--- Returns both canvas dimensions as `(width, height)`.
---@return number
function Overlay:getDimensions() end

--- Returns the current film grain noise amplitude (0.0â€“1.0).
---@return number
function Overlay:getFilmGrainIntensity() end

--- Returns the current fog colour as `(r, g, b, a)`.
---@return number
function Overlay:getFogColor() end

--- Returns the current fog density (0.0â€“1.0).
---@return number
function Overlay:getFogDensity() end

--- Returns the heat haze distortion intensity.
---@return number
function Overlay:getHeatHazeIntensity() end

--- Returns the overlay canvas height in pixels.
---@return number
function Overlay:getHeight() end

--- Returns the current lightning flash colour as `(r, g, b, a)`.
---@return number
function Overlay:getLightningColor() end

--- Returns the current camera-shake pixel offset as `(x, y)`.
---@return number
function Overlay:getShakeOffset() end

--- Returns the current time-of-day value (0.0â€“24.0).
---@return number
function Overlay:getTimeOfDay() end

--- Returns the current vignette darkening strength (0.0â€“1.0).
---@return number
function Overlay:getVignetteStrength() end

--- Returns the current weather type as a lowercase string name.
---@return string
function Overlay:getWeather() end

--- Returns the weather particle density (0.0â€“1.0).
---@return number
function Overlay:getWeatherIntensity() end

--- Returns the overlay canvas width in pixels.
---@return number
function Overlay:getWidth() end

--- Returns the wind direction in radians.
---@return number
function Overlay:getWindDirection() end

--- Returns the wind speed in pixels per second.
---@return number
function Overlay:getWindSpeed() end

--- Returns `true` if any overlay subsystem is currently active.
---@return boolean
function Overlay:isActive() end

--- Returns `true` if automatic ambient colour cycling is enabled.
---@return boolean
function Overlay:isAmbientEnabled() end

--- Returns `true` if the cloud shadow overlay is enabled.
---@return boolean
function Overlay:isCloudShadowsEnabled() end

--- Returns `true` while a fade transition is in progress.
---@return boolean
function Overlay:isFading() end

--- Returns `true` if film grain noise is enabled.
---@return boolean
function Overlay:isFilmGrainEnabled() end

--- Returns `true` while a flash is fading out.
---@return boolean
function Overlay:isFlashing() end

--- Returns `true` if the atmospheric fog overlay is enabled.
---@return boolean
function Overlay:isFogEnabled() end

--- Returns `true` if heat haze distortion is enabled.
---@return boolean
function Overlay:isHeatHazeEnabled() end

--- Returns `true` while a camera shake is in progress.
---@return boolean
function Overlay:isShaking() end

--- Returns `true` if the vignette overlay is enabled.
---@return boolean
function Overlay:isVignetteEnabled() end

--- Returns `true` if the weather particle spawner is enabled.
---@return boolean
function Overlay:isWeatherEnabled() end

--- Updates the internal canvas dimensions on window resize.
---@param w any
---@param h any
function Overlay:resize(w, h) end

--- Enables or disables automatic time-of-day ambient colour cycling.
---@param enabled any
function Overlay:setAmbientEnabled(enabled) end

--- Sets the number of cloud shadow blobs rendered each frame.
---@param count any
function Overlay:setCloudCount(count) end

--- Sets the cloud shadow overlay opacity (0.0 = invisible, 1.0 = fully dark).
---@param opacity any
function Overlay:setCloudOpacity(opacity) end

--- Sets the relative size scale of each cloud shadow blob.
---@param scale any
function Overlay:setCloudScale(scale) end

--- Enables or disables the scrolling cloud shadow overlay.
---@param enabled any
function Overlay:setCloudShadows(enabled) end

--- Sets the horizontal scroll speed of cloud shadows in pixels per second.
---@param speed any
function Overlay:setCloudSpeed(speed) end

--- Enables or disables per-frame random film grain noise.
---@param enabled any
function Overlay:setFilmGrainEnabled(enabled) end

--- Sets the film grain noise amplitude (0.0â€“1.0).
---@param intensity any
function Overlay:setFilmGrainIntensity(intensity) end

--- Sets the fog density (0.0 = invisible, 1.0 = fully opaque).
---@param density any
function Overlay:setFogDensity(density) end

--- Enables or disables atmospheric fog.
---@param enabled any
function Overlay:setFogEnabled(enabled) end

--- Enables or disables UV-distortion heat shimmer.
---@param enabled any
function Overlay:setHeatHazeEnabled(enabled) end

--- Sets the heat haze distortion intensity.
---@param intensity any
function Overlay:setHeatHazeIntensity(intensity) end

--- Sets the time-of-day value that drives ambient colour cycling.
---@param hour any
function Overlay:setTimeOfDay(hour) end

--- Enables or disables screen-edge darkening (vignette).
---@param enabled any
function Overlay:setVignetteEnabled(enabled) end

--- Sets the vignette darkening strength (0.0â€“1.0).
---@param strength any
function Overlay:setVignetteStrength(strength) end

--- Sets the active weather type by name.
---@param name any
function Overlay:setWeather(name) end

--- Enables or disables the weather particle spawner.
---@param enabled any
function Overlay:setWeatherEnabled(enabled) end

--- Sets the weather particle density.
---@param intensity any
function Overlay:setWeatherIntensity(intensity) end

--- Sets the wind direction as an angle in radians.
---@param angle any
function Overlay:setWindDirection(angle) end

--- Sets the wind speed in pixels per second.
---@param speed any
function Overlay:setWindSpeed(speed) end

--- Triggers a one-shot lightning flash.
function Overlay:triggerLightning() end

--- Advances all active overlay subsystems by `dt` seconds.
---@param dt any
function Overlay:update(dt) end

---@param width? any (optional)
---@param height? any (optional)
function luna.overlay.newOverlay(width, height) end

---@class luna.particle
luna.particle = {}

--- Lua UserData wrapper for a particle system resource.
---@class ParticleSystem
local ParticleSystem = {}

--- Returns a deep copy of this object.
---@return any
function ParticleSystem:clone() end

--- Emits an event.
---@param count number ÔÇö `integer`.
function ParticleSystem:emit(count) end

--- Returns the alphas.
---@return any
function ParticleSystem:getAlphas() end

--- Returns the count.
---@return any
function ParticleSystem:getCount() end

--- Returns the emission shape.
---@return any
function ParticleSystem:getEmissionShape() end

--- Returns the gravity.
---@return number
function ParticleSystem:getGravity() end

--- Returns the position.
---@return any
function ParticleSystem:getPosition() end

--- Returns the relative mode.
---@return string
function ParticleSystem:getRelativeMode() end

--- Returns the particle render shape name.
---@return string
function ParticleSystem:getShape() end

--- Returns `true` if active.
---@return boolean
function ParticleSystem:isActive() end

--- Returns `true` if paused.
---@return boolean
function ParticleSystem:isPaused() end

--- Returns `true` if stopped.
---@return boolean
function ParticleSystem:isStopped() end

--- Pauses playback.
---@return any
function ParticleSystem:pause() end

--- Resets state to initial values.
---@return any
function ParticleSystem:reset() end

--- Sets the alphas.
---@param args any ÔÇö `LuaMultiValue`.
function ParticleSystem:setAlphas(args) end

--- Sets the emission rate.
---@param rate number ÔÇö `number`.
function ParticleSystem:setEmissionRate(rate) end

--- Sets the gravity.
---@param gx number ÔÇö `number`.
---@param gy number ÔÇö `number`.
function ParticleSystem:setGravity(gx, gy) end

--- Sets the position.
---@param x number ÔÇö `number`.
---@param y number ÔÇö `number`.
function ParticleSystem:setPosition(x, y) end

--- Sets the relative mode.
---@param mode string ÔÇö `string`.
function ParticleSystem:setRelativeMode(mode) end

--- Sets the particle render shape.
---@param shape_str string `string` — one of `"square"`, `"circle"`, `"triangle"`, `"spark"`, `"diamond"`.
function ParticleSystem:setShape(shape_str) end

--- Begins execution.
---@return any
function ParticleSystem:start() end

--- Stops playback.
---@return any
function ParticleSystem:stop() end

--- Advances the simulation by `dt` seconds.
---@param dt number ÔÇö `number`.
function ParticleSystem:update(dt) end

---@param id_val any
function luna.particle.clone(id_val) end

---@param id_val any
---@param x? any (optional)
---@param y? any (optional)
function luna.particle.draw(id_val, x, y) end

---@param id_val any
---@param count any
function luna.particle.emit(id_val, count) end

---@param id_val any
function luna.particle.getAlphas(id_val) end

---@param id_val any
function luna.particle.getBufferSize(id_val) end

---@param id_val any
function luna.particle.getColors(id_val) end

---@param id_val any
function luna.particle.getCount(id_val) end

---@param id_val any
function luna.particle.getDirection(id_val) end

---@param id_val any
function luna.particle.getEmissionArea(id_val) end

---@param id_val any
function luna.particle.getEmissionRate(id_val) end

---@param id_val any
function luna.particle.getEmissionShape(id_val) end

---@param id_val any
function luna.particle.getEmitterLifetime(id_val) end

---@param id_val any
function luna.particle.getGravity(id_val) end

---@param id_val any
function luna.particle.getInsertMode(id_val) end

---@param id_val any
function luna.particle.getLinearAcceleration(id_val) end

---@param id_val any
function luna.particle.getLinearDamping(id_val) end

---@param id_val any
function luna.particle.getOffset(id_val) end

---@param id_val any
function luna.particle.getParticleLifetime(id_val) end

---@param id_val any
function luna.particle.getPosition(id_val) end

---@param id_val any
function luna.particle.getRadialAcceleration(id_val) end

---@param id_val any
function luna.particle.getRelativeMode(id_val) end

---@param id_val any
function luna.particle.getRotation(id_val) end

---@param id_val any
function luna.particle.getSizeVariation(id_val) end

---@param id_val any
function luna.particle.getSizes(id_val) end

---@param id_val any
function luna.particle.getSpeed(id_val) end

---@param id_val any
function luna.particle.getSpin(id_val) end

---@param id_val any
function luna.particle.getSpinVariation(id_val) end

---@param id_val any
function luna.particle.getSpread(id_val) end

---@param id_val any
function luna.particle.getTangentialAcceleration(id_val) end

---@param id_val any
function luna.particle.getTexture(id_val) end

---@param id_val any
function luna.particle.hasRelativeRotation(id_val) end

---@param id_val any
function luna.particle.isActive(id_val) end

---@param id_val any
function luna.particle.isEmpty(id_val) end

---@param id_val any
function luna.particle.isFull(id_val) end

---@param id_val any
function luna.particle.isPaused(id_val) end

---@param id_val any
function luna.particle.isStopped(id_val) end

---@param id_val any
---@param x any
---@param y any
function luna.particle.moveTo(id_val, x, y) end

---@param config? any (optional)
function luna.particle.newSystem(config) end

---@param id_val any
function luna.particle.pause(id_val) end

---@param id_val any
function luna.particle.release(id_val) end

---@param id_val any
function luna.particle.reset(id_val) end

---@param args any
function luna.particle.setAlphas(args) end

---@param id_val any
---@param size any
function luna.particle.setBufferSize(id_val, size) end

---@param args any
function luna.particle.setColors(args) end

---@param id_val any
---@param dir any
function luna.particle.setDirection(id_val, dir) end

function luna.particle.setEmissionArea() end

---@param id_val any
---@param rate any
function luna.particle.setEmissionRate(id_val, rate) end

---@param id_val any
---@param shape any
---@param args? any (optional)
function luna.particle.setEmissionShape(id_val, shape, args) end

---@param id_val any
---@param lifetime any
function luna.particle.setEmitterLifetime(id_val, lifetime) end

---@param id_val any
---@param gx any
---@param gy any
function luna.particle.setGravity(id_val, gx, gy) end

---@param id_val any
---@param mode any
function luna.particle.setInsertMode(id_val, mode) end

---@param id_val any
---@param xmin any
---@param ymin any
---@param xmax any
---@param ymax any
function luna.particle.setLinearAcceleration(id_val, xmin, ymin, xmax, ymax) end

---@param id_val any
---@param min any
---@param max any
function luna.particle.setLinearDamping(id_val, min, max) end

---@param id_val any
---@param ox any
---@param oy any
function luna.particle.setOffset(id_val, ox, oy) end

---@param id_val any
---@param min any
---@param max any
function luna.particle.setParticleLifetime(id_val, min, max) end

---@param id_val any
---@param x any
---@param y any
function luna.particle.setPosition(id_val, x, y) end

---@param id_val any
---@param quads_table any
function luna.particle.setQuads(id_val, quads_table) end

---@param id_val any
---@param min any
---@param max any
function luna.particle.setRadialAcceleration(id_val, min, max) end

---@param id_val any
---@param mode any
function luna.particle.setRelativeMode(id_val, mode) end

---@param id_val any
---@param enable any
function luna.particle.setRelativeRotation(id_val, enable) end

---@param id_val any
---@param min any
---@param max any
function luna.particle.setRotation(id_val, min, max) end

---@param id_val any
---@param v any
function luna.particle.setSizeVariation(id_val, v) end

---@param args any
function luna.particle.setSizes(args) end

---@param id_val any
---@param min any
---@param max any
function luna.particle.setSpeed(id_val, min, max) end

---@param id_val any
---@param min any
---@param max any
function luna.particle.setSpin(id_val, min, max) end

---@param id_val any
---@param v any
function luna.particle.setSpinVariation(id_val, v) end

---@param id_val any
---@param spread any
function luna.particle.setSpread(id_val, spread) end

---@param id_val any
---@param min any
---@param max any
function luna.particle.setTangentialAcceleration(id_val, min, max) end

---@param id_val any
---@param tex_id any
function luna.particle.setTexture(id_val, tex_id) end

---@param id_val any
function luna.particle.start(id_val) end

---@param id_val any
function luna.particle.stop(id_val) end

---@param id_val any
---@param dt any
function luna.particle.update(id_val, dt) end

---@class luna.pathfinding
luna.pathfinding = {}

---@class FlowField
local FlowField = {}

--- Returns the cost to target.
---@param x number `integer`.
---@param y number `integer`.
---@return any
function FlowField:getCostToTarget(x, y) end

--- Returns the direction.
---@param x number `integer`.
---@param y number `integer`.
---@return any
function FlowField:getDirection(x, y) end

---@param x any
---@param y any
function FlowField:getDirection(x, y) end

--- Returns the direction angle.
---@param x number `integer`.
---@param y number `integer`.
---@return number
function FlowField:getDirectionAngle(x, y) end

---@param x any
---@param y any
function FlowField:getDistance(x, y) end

function FlowField:getGoal() end

function FlowField:getHeight() end

--- Returns the targets.
---@return table
function FlowField:getTargets() end

function FlowField:getWidth() end

function FlowField:hasGoal() end

--- Returns `true` if calculated.
---@return boolean
function FlowField:isCalculated() end

---@param x any
---@param y any
function FlowField:setGoal(x, y) end

---@class NavGrid
local NavGrid = {}

--- Clear dirty on this NavGrid.
---@param mode string `string`.
function NavGrid:clearDirty(mode) end

--- Fill on this NavGrid.
---@param cost number `integer`.
function NavGrid:fill(cost) end

--- Returns the chunk size.
---@return any
function NavGrid:getChunkSize() end

--- Returns the cost.
---@param x number `integer`.
---@param y number `integer`.
---@return any
function NavGrid:getCost(x, y) end

--- Returns the diagonal mode.
---@return string
function NavGrid:getDiagonalMode() end

--- Returns the dimensions.
---@param x number `integer`.
---@param y number `integer`.
---@param cost number `integer`.
---@return any
function NavGrid:getDimensions(x, y, cost) end

--- Returns the height.
---@return number
function NavGrid:getHeight() end

--- Returns the width.
---@return number
function NavGrid:getWidth() end

--- Returns `true` if blocked.
---@param x number `integer`.
---@param y number `integer`.
---@return boolean
function NavGrid:isBlocked(x, y) end

--- Load from string on this NavGrid.
---@param data string `string`.
function NavGrid:loadFromString(data) end

--- Rebuild abstract on this NavGrid.
---@return any
function NavGrid:rebuildAbstract() end

--- Save to string on this NavGrid.
---@param size number `integer`.
function NavGrid:saveToString(size) end

--- Sets the chunk size.
---@param size number `integer`.
function NavGrid:setChunkSize(size) end

--- Sets the cost.
---@param x number `integer`.
---@param y number `integer`.
---@param cost number `integer`.
function NavGrid:setCost(x, y, cost) end

--- Sets the diagonal mode.
---@param mode string `string`.
function NavGrid:setDiagonalMode(mode) end

--- Sets the dirty.
---@param x number `integer`.
---@param y number `integer`.
---@param w number `integer`.
---@param h number `integer`.
function NavGrid:setDirty(x, y, w, h) end

---@class PathGrid
local PathGrid = {}

function PathGrid:getCellSize() end

---@param x any
---@param y any
function PathGrid:getCost(x, y) end

function PathGrid:getHeight() end

function PathGrid:getWidth() end

---@param x any
---@param y any
function PathGrid:isWalkable(x, y) end

---@param x any
---@param y any
---@param cost any
function PathGrid:setCost(x, y, cost) end

---@param x any
---@param y any
---@param w any
function PathGrid:setWalkable(x, y, w) end

---@class UnitPathfinder
local UnitPathfinder = {}

--- Clear cache on this UnitPathfinder.
---@return any
function UnitPathfinder:clearCache() end

--- Returns the cache size.
---@param n number `integer`.
---@return any
function UnitPathfinder:getCacheSize(n) end

--- Returns the path cost.
---@param path table `table`.
---@return string
function UnitPathfinder:getPathCost(path) end

--- Returns the path length.
---@param path table `table`.
---@return string
function UnitPathfinder:getPathLength(path) end

--- Returns `true` if cache enabled.
---@return boolean
function UnitPathfinder:isCacheEnabled() end

--- Sets the cache enabled.
---@param enabled boolean `boolean`.
function UnitPathfinder:setCacheEnabled(enabled) end

--- Sets the cache max size.
---@param n number `integer`.
function UnitPathfinder:setCacheMaxSize(n) end

--- Returns the thread count.
---@return any
function luna.pathfinding.getThreadCount() end

--- New flow field.
---@param grid_ud any
---@return any
function luna.pathfinding.newFlowField(grid_ud) end

--- New nav grid.
---@param width any
---@param height any
---@return any
function luna.pathfinding.newNavGrid(width, height) end

--- New nav grid from tile map.
---@param tilemap_ud any
---@param layer any
---@param blocked any
---@return any
function luna.pathfinding.newNavGridFromTileMap(tilemap_ud, layer, blocked) end

--- New PathGrid-based BFS flow field.
---@param grid_ud any
---@return any
function luna.pathfinding.newPathFlowField(grid_ud) end

--- Pathfinding on this FlowField.
---@param w any
---@param h any
---@param cell_size any
---@return string
function luna.pathfinding.newPathGrid(w, h, cell_size) end

--- New pathfinder.
---@param grid_ud any
---@return any
function luna.pathfinding.newPathfinder(grid_ud) end

--- Sets the thread count.
---@param count any
function luna.pathfinding.setThreadCount(count) end

---@class luna.patterns
luna.patterns = {}

---@class CommandStack
local CommandStack = {}

--- Returns `true` if redo.
---@return boolean
function CommandStack:canRedo() end

--- Returns `true` if undo.
---@return boolean
function CommandStack:canUndo() end

--- Clear all on this CommandStack.
---@return any
function CommandStack:clearAll() end

--- Execute on this CommandStack.
---@param name string `string`.
---@param exec_fn function `function`.
---@param undo_fn? function `function` optional.
function CommandStack:execute(name, exec_fn, undo_fn) end

--- Returns the current name.
---@return any
function CommandStack:getCurrentName() end

--- Returns the history size.
---@return number
function CommandStack:getHistorySize() end

--- Redo on this CommandStack.
---@return boolean
function CommandStack:redo() end

--- Undo on this CommandStack.
---@return boolean
function CommandStack:undo() end

---@class EventBus
local EventBus = {}

--- Removes all entries.
---@param event string `string`.
function EventBus:clear(event) end

--- Clear all on this EventBus.
---@return any
function EventBus:clearAll() end

--- Emits an event.
---@param args any `LuaMultiValue`.
function EventBus:emit(args) end

--- Returns the events.
---@return any
function EventBus:getEvents() end

--- Returns the listener count.
---@param event string `string`.
---@return any
function EventBus:getListenerCount(event) end

--- Removes a previously registered event listener.
---@param id number `integer`.
function EventBus:off(id) end

--- Registers an event listener callback.
---@param event string `string`.
---@param callback function `function`.
---@param priority? number `integer` optional.
---@return any
function EventBus:on(event, callback, priority) end

---@class Factory
local Factory = {}

--- Clear all on this Factory.
---@return any
function Factory:clearAll() end

--- Creates a new Factory instance.
---@param args any `LuaMultiValue`.
function Factory:create(args) end

--- Returns the types.
---@return number
function Factory:getTypes() end

--- Returns `true` if the condition is met.
---@param type_name string `string`.
---@return boolean
function Factory:has(type_name) end

--- Adds an entry to the collection.
---@param type_name string `string`.
---@param ctor function `function`.
function Factory:register(type_name, ctor) end

--- Removes the entry from the collection.
---@param type_name string `string`.
function Factory:remove(type_name) end

---@class ObjectPool
local ObjectPool = {}

--- Acquire on this ObjectPool.
---@return any
function ObjectPool:acquire() end

--- Adds an entry to the collection.
---@param value number `any`.
function ObjectPool:add(value) end

--- Clear all on this ObjectPool.
---@return any
function ObjectPool:clearAll() end

--- Returns the active count.
---@return any
function ObjectPool:getActiveCount() end

--- Returns the available count.
---@return integer
function ObjectPool:getAvailableCount() end

--- Returns the total count.
---@return integer
function ObjectPool:getTotalCount() end

--- Releases the underlying resource handle.
---@param value number `any`.
function ObjectPool:release(value) end

---@class ServiceLocator
local ServiceLocator = {}

--- Clear all on this ServiceLocator.
---@return any
function ServiceLocator:clearAll() end

--- Returns the services.
---@return any
function ServiceLocator:getServices() end

--- Returns `true` if the condition is met.
---@param name string `string`.
---@return boolean
function ServiceLocator:has(name) end

--- Locate on this ServiceLocator.
---@param name string `string`.
---@return any
function ServiceLocator:locate(name) end

--- Provide on this ServiceLocator.
---@param name string `string`.
---@param value number `any`.
function ServiceLocator:provide(name, value) end

--- Removes the entry from the collection.
---@param name string `string`.
function ServiceLocator:remove(name) end

---@class SimpleState
local SimpleState = {}

--- Adds state to the collection.
---@param name string `string`.
---@param callbacks? table `table` optional.
function SimpleState:addState(name, callbacks) end

--- Clear all on this SimpleState.
---@return any
function SimpleState:clearAll() end

--- Returns the current.
---@param name string `string`.
---@return any
function SimpleState:getCurrent(name) end

--- Returns the states.
---@return any
function SimpleState:getStates() end

--- Returns `true` if state.
---@param name string `string`.
---@return boolean
function SimpleState:hasState(name) end

--- Transition to on this SimpleState.
---@param name string `string`.
---@return boolean
function SimpleState:transitionTo(name) end

--- Advances the simulation by `dt` seconds.
---@param dt number `number`.
function SimpleState:update(dt) end

--- New command stack.
---@return any
function luna.patterns.newCommandStack() end

--- New event bus.
---@return any
function luna.patterns.newEventBus() end

--- New factory.
---@return any
function luna.patterns.newFactory() end

--- New object pool.
---@return any
function luna.patterns.newObjectPool() end

--- New service locator.
---@return any
function luna.patterns.newServiceLocator() end

--- New simple state.
---@return any
function luna.patterns.newSimpleState() end

---@class luna.physics
luna.physics = {}

--- Lua UserData wrapper for a physics body.
---@class Body
local Body = {}

--- Adds a collision fixture to the body using the given shape definition table.
---@param def number ÔÇö Table describing the fixture: shape, density, friction, restitution.
---@return number
function Body:addFixture(def) end

--- Applies a continuous force (accumulates until the next physics step) to the body's centre of mass.
---@param fx number ÔÇö `number`: Horizontal force component.
---@param fy number ÔÇö `number`: Vertical force component.
function Body:applyForce(fx, fy) end

--- Applies an instantaneous impulse directly to the body's centre of mass.
---@param ix number ÔÇö `number`: Horizontal impulse.
---@param iy number ÔÇö `number`: Vertical impulse.
function Body:applyImpulse(ix, iy) end

--- Destroys the body and removes it from its parent physics world immediately.
function Body:destroy() end

--- Returns the body's current rotation angle in radians.
---@return number
function Body:getAngle() end

--- Returns the type string of the given body.
function Body:getBodyType() end

--- Returns the number of collision fixtures currently attached to the body.
---@return number
function Body:getFixtureCount() end

--- Returns the total simulated mass of the body in physics units.
---@return number
function Body:getMass() end

--- Returns the body's current world-space position.
---@return number
---@return number
function Body:getPosition() end

--- Returns the current linear velocity vector of the body.
---@return number
function Body:getVelocity() end

--- Sets the body's rotation to `angle` radians (bypasses physics).
---@param angle number ÔÇö `number`: Target angle in radians.
function Body:setAngle(angle) end

--- Teleports the body to the given world-space position (bypasses collision detection).
---@param x number ÔÇö `number`: Target X position.
---@param y number ÔÇö `number`: Target Y position.
function Body:setPosition(x, y) end

--- Resizes the body's primary collision shape to the given width and height.
---@param width number ÔÇö New shape width in world units.
---@param height number ÔÇö New shape height in world units.
function Body:setSize(width, height) end

--- Sets the body's linear velocity to the given (vx, vy) world-space vector.
---@param vx number ÔÇö Velocity along the X axis in world units per second.
---@param vy number ÔÇö Velocity along the Y axis in world units per second.
function Body:setVelocity(vx, vy) end

--- Lua UserData wrapper for a standalone physics shape.
---@class Shape
local Shape = {}

--- Destroys the shape. No-op — Lua GC handles cleanup automatically.
function Shape:destroy() end

--- Returns the axis-aligned bounding box of this shape in local coordinates.
---@return number
function Shape:getBoundingBox() end

--- Returns the radius of a circle shape.
---@return number
function Shape:getRadius() end

--- Returns the shape type string: `"circle"`, `"rectangle"`, `"polygon"`, `"edge"`, or `"chain"`.
---@return string
function Shape:getType() end

--- Sets the density for when this shape is attached to a body.
---@param density number `number`. Mass per unit area.
function Shape:setDensity(density) end

--- Sets the friction coefficient for when this shape is attached to a body.
---@param friction number `number`. Surface friction (0 = frictionless, 1 = high friction).
function Shape:setFriction(friction) end

--- Sets the restitution (bounciness) for when this shape is attached to a body.
---@param restitution number `number`. 0 = inelastic, 1 = fully elastic.
function Shape:setRestitution(restitution) end

--- Sets whether this shape acts as a sensor (detects overlaps, no forces).
---@param sensor boolean `boolean`.
function Shape:setSensor(sensor) end

--- Lua UserData wrapper for a physics world.
---@class World
local World = {}

--- Returns the number of bodies in the world.
function World:getBodyCount() end

--- Returns a table of all currently active collision pairs in this physics world.
---@return number
function World:getCollisions() end

--- Returns the current world gravity vector.
---@return number
---@return number
function World:getGravity() end

--- Returns whether bodies in this world are allowed to enter a sleep state.
---@param body_id any
---@return number
function World:isSleepingAllowed(body_id) end

--- Registers collision begin/end callback functions for this physics world.
---@param beginContact number ÔÇö Called with (body1, body2) when two bodies start touching.
---@param endContact number ÔÇö Called with (body1, body2) when they separate.
function World:setCallbacks(beginContact, endContact) end

--- Sets world gravity. Default is `(0, 9.81)` (downward).
---@param x number ÔÇö `number`: Horizontal gravity component.
---@param y number ÔÇö `number`: Vertical gravity component.
function World:setGravity(x, y) end

--- Advances the physics simulation by `dt` seconds, resolving collisions and integrating forces.
---@param dt number ÔÇö `number`: Elapsed simulation time in seconds.
function World:step(dt) end

--- Adds a distance joint that maintains a fixed separation between two body anchor points.
---@param world number ÔÇö World ID.
---@param body1 number ÔÇö First body ID.
---@param body2 number ÔÇö Second body ID.
---@param x1 number ÔÇö Anchor on body1 in local coordinates.
---@param y1 number ÔÇö Anchor on body1 in local coordinates.
---@param x2 number ÔÇö Anchor on body2 in local coordinates.
---@param y2 number ÔÇö Anchor on body2 in local coordinates.
---@return number
function luna.physics.addDistanceJoint(world, body1, body2, x1, y1, x2, y2) end

--- Adds a friction joint that resists relative movement and rotation between two bodies.
---@param world number ÔÇö World ID.
---@param body1 number ÔÇö First body ID.
---@param body2 number ÔÇö Second body ID.
---@param ax number ÔÇö World-space anchor point.
---@param ay number ÔÇö World-space anchor point.
---@return number
function luna.physics.addFrictionJoint(world, body1, body2, ax, ay) end

--- Adds a gear joint that couples two revolute or prismatic joints so they move in sync.
---@param world number ÔÇö World ID.
---@param joint1 number ÔÇö First revolute or prismatic joint ID.
---@param joint2 number ÔÇö Second revolute or prismatic joint ID.
---@param ratio number ÔÇö Gear ratio between the two joints.
---@return number
function luna.physics.addGearJoint(world, joint1, joint2, ratio) end

--- Adds a motor joint that drives one body toward a target position relative to another.
---@param world number ÔÇö World ID.
---@param body1 number ÔÇö First body ID (reference).
---@param body2 number ÔÇö Second body ID (driven).
---@return number
function luna.physics.addMotorJoint(world, body1, body2) end

--- Adds a mouse joint that applies a spring force pulling a body toward a target point.
---@param world number ÔÇö World ID.
---@param body number ÔÇö Body ID to control.
---@param x any ÔÇö Initial target position in world coordinates.
---@param y any ÔÇö Initial target position in world coordinates.
---@return number
function luna.physics.addMouseJoint(world, body, x, y) end

--- Adds a prismatic joint that constrains two bodies to slide along a single axis.
---@param world number ÔÇö World ID.
---@param body1 number ÔÇö First body ID.
---@param body2 number ÔÇö Second body ID.
---@param ax number ÔÇö World-space anchor point.
---@param ay number ÔÇö World-space anchor point.
---@param axisX number ÔÇö Slide axis direction (unit vector).
---@param axisY number ÔÇö Slide axis direction (unit vector).
---@return number
function luna.physics.addPrismaticJoint(world, body1, body2, ax, ay, axisX, axisY) end

--- Adds a pulley joint linking two bodies through a rope of fixed total length.
---@param world number ÔÇö World ID.
---@param body1 number ÔÇö First body ID.
---@param body2 number ÔÇö Second body ID.
---@param gx1 number ÔÇö Ground anchor for body1 in world coordinates.
---@param gy1 number ÔÇö Ground anchor for body1 in world coordinates.
---@param gx2 number ÔÇö Ground anchor for body2 in world coordinates.
---@param gy2 number ÔÇö Ground anchor for body2 in world coordinates.
---@param ax1 number ÔÇö Body1 attachment point in local coordinates.
---@param ay1 number ÔÇö Body1 attachment point in local coordinates.
---@param ax2 number ÔÇö Body2 attachment point in local coordinates.
---@param ay2 number ÔÇö Body2 attachment point in local coordinates.
---@param ratio number ÔÇö Pulley ratio (1.0 = symmetric).
---@return number
function luna.physics.addPulleyJoint(world, body1, body2, gx1, gy1, gx2, gy2, ax1, ay1, ax2, ay2, ratio) end

--- Adds a revolute joint that constrains two bodies to rotate around a shared anchor point.
---@param world number ÔÇö World ID.
---@param body1 number ÔÇö First body ID.
---@param body2 number ÔÇö Second body ID.
---@param ax number ÔÇö World-space anchor point to revolve around.
---@param ay number ÔÇö World-space anchor point to revolve around.
---@return number
function luna.physics.addRevoluteJoint(world, body1, body2, ax, ay) end

--- Adds a rope joint that enforces a maximum distance between two body anchor points.
---@param world number ÔÇö World ID.
---@param body1 number ÔÇö First body ID.
---@param body2 number ÔÇö Second body ID.
---@param x1 number ÔÇö Anchor on body1 in local coordinates.
---@param y1 number ÔÇö Anchor on body1 in local coordinates.
---@param x2 number ÔÇö Anchor on body2 in local coordinates.
---@param y2 number ÔÇö Anchor on body2 in local coordinates.
---@param maxLength number ÔÇö Maximum allowed distance in world units.
---@return number
function luna.physics.addRopeJoint(world, body1, body2, x1, y1, x2, y2, maxLength) end

--- Adds a weld joint that rigidly fixes the relative position and angle of two bodies.
---@param world number ÔÇö World ID.
---@param body1 number ÔÇö First body ID.
---@param body2 number ÔÇö Second body ID.
---@param ax number ÔÇö World-space anchor point for the weld.
---@param ay number ÔÇö World-space anchor point for the weld.
---@return number
function luna.physics.addWeldJoint(world, body1, body2, ax, ay) end

--- Adds a wheel joint combining a revolute motor and a prismatic spring for vehicle suspension.
---@param world number ÔÇö World ID.
---@param body1 number ÔÇö Chassis body ID.
---@param body2 number ÔÇö Wheel body ID.
---@param ax number ÔÇö World-space anchor point.
---@param ay number ÔÇö World-space anchor point.
---@param axisX number ÔÇö Suspension axis direction.
---@param axisY number ÔÇö Suspension axis direction.
---@return number
function luna.physics.addWheelJoint(world, body1, body2, ax, ay, axisX, axisY) end

--- Applies an instantaneous angular impulse to the body, changing its spin velocity.
---@param world number ÔÇö World ID.
---@param body number ÔÇö Target body ID.
---@param impulse any ÔÇö Angular impulse magnitude in N┬Ěm┬Ěs.
function luna.physics.applyAngularImpulse(world, body, impulse) end

--- Applies a force vector to a body at its center of mass.
---@param world_id_val any
---@param body_id_val any
---@param fx any
---@param fy any
function luna.physics.applyForce(world_id_val, body_id_val, fx, fy) end

--- Applies a world-space force at a given point on the body, potentially adding torque.
---@param world number ÔÇö World ID.
---@param body number ÔÇö Target body ID.
---@param fx any ÔÇö Force vector in Newtons.
---@param fy any ÔÇö Force vector in Newtons.
---@param px number ÔÇö World-space point of application.
---@param py number ÔÇö World-space point of application.
function luna.physics.applyForceAtPoint(world, body, fx, fy, px, py) end

--- Applies an instantaneous impulse to a body.
---@param world_id_val any
---@param body_id_val any
---@param ix any
---@param iy any
function luna.physics.applyImpulse(world_id_val, body_id_val, ix, iy) end

--- Applies a rotational torque to a body.
---@param world_id_val any
---@param body_id_val any
---@param torque any
function luna.physics.applyTorque(world_id_val, body_id_val, torque) end

--- Attaches a standalone shape to a body as a new collider fixture.
---@param body number `Body` userdata returned by `newBody`.
---@param shape number `Shape` userdata returned by `newCircleShape` etc.
---@return number
function luna.physics.attachShape(body, shape) end

--- Removes a body from the physics world.
---@param world_id_val any
---@param body_id_val any
function luna.physics.destroyBody(world_id_val, body_id_val) end

--- Removes the given joint from the world and frees its resources.
---@param world number ÔÇö World ID that owns the joint.
---@param joint number ÔÇö Joint ID to destroy.
function luna.physics.destroyJoint(world, joint) end

--- Destroys a physics world and frees all associated resources.
---@param world_id_val any
function luna.physics.destroyWorld(world_id_val) end

--- Returns the angular damping coefficient of the body that slows its rotation over time.
---@param world number ÔÇö World ID.
---@param body number ÔÇö Body ID.
---@return number
function luna.physics.getAngularDamping(world, body) end

--- Returns the current angular velocity of the body in radians per second.
---@param world number ÔÇö World ID.
---@param body number ÔÇö Body ID.
---@return number
function luna.physics.getAngularVelocity(world, body) end

--- Returns a table of all body IDs currently registered in the physics world.
---@param world number ÔÇö World ID to query.
---@return number
function luna.physics.getBodies(world) end

--- Returns the body object table for the given body ID within the world.
---@param world number ÔÇö World ID.
---@param body number ÔÇö Body ID to look up.
---@return number
function luna.physics.getBody(world, body) end

--- Returns the current rotation angle (radians) of a physics body.
---@param world_id_val any
---@param body_id_val any
function luna.physics.getBodyAngle(world_id_val, body_id_val) end

--- Returns the first body whose collider contains the given world-space point.
---@param world number World ID or World userdata.
---@param x number World-space X coordinate.
---@param y number World-space Y coordinate.
---@return number
function luna.physics.getBodyAtPoint(world, x, y) end

--- Returns all active contact manifolds where this body touches another body.
---@param world number ÔÇö World ID.
---@param body number ÔÇö Body ID to query.
---@return number
function luna.physics.getBodyContacts(world, body) end

--- Returns the number of bodies in the world.
---@param world_id_val any
function luna.physics.getBodyCount(world_id_val) end

--- Returns the mass of a physics body.
---@param world_id_val any
---@param body_id_val any
function luna.physics.getBodyMass(world_id_val, body_id_val) end

--- Returns the type string of the given body.
---@param world_id_val any
---@param body_id_val any
function luna.physics.getBodyType(world_id_val, body_id_val) end

--- Returns all collision pairs currently overlapping in the physics world.
---@param world number ÔÇö World ID.
---@return number
function luna.physics.getCollisions(world) end

--- Returns a table of all currently active collision contact manifolds in the world.
---@param world number ÔÇö World ID.
---@return number
function luna.physics.getContacts(world) end

--- Returns the global gravity vector (gx, gy).
---@param world_id_val any
function luna.physics.getGravity(world_id_val) end

--- Returns the per-body gravity scale factor applied to the world gravity vector.
---@param world number ÔÇö World ID.
---@param body number ÔÇö Body ID.
---@return number
function luna.physics.getGravityScale(world, body) end

--- Returns the two body IDs connected by the given joint.
---@param world number ÔÇö World ID.
---@param joint number ÔÇö Joint ID to query.
---@return number
function luna.physics.getJointBodies(world, joint) end

--- Returns the total number of joints currently active in the physics world.
---@param world number ÔÇö World ID.
---@return number
function luna.physics.getJointCount(world) end

--- Returns the lower and upper angular or linear limits set on the joint.
---@param world number ÔÇö World ID.
---@param joint number ÔÇö Joint ID.
---@return any
function luna.physics.getJointLimits(world, joint) end

--- Returns the target motor speed of a revolute or prismatic joint.
---@param world number ÔÇö World ID.
---@param joint number ÔÇö Joint ID.
---@return any
function luna.physics.getJointMotorSpeed(world, joint) end

--- Returns a string describing the type of the given joint.
---@param world number ÔÇö World ID.
---@param joint number ÔÇö Joint ID.
---@return string
function luna.physics.getJointType(world, joint) end

--- Returns a table of all joint IDs currently active in the physics world.
---@param world number ÔÇö World ID to query.
---@return number
function luna.physics.getJoints(world) end

--- Returns the linear damping coefficient that gradually slows the body's movement.
---@param world number ÔÇö World ID.
---@param body number ÔÇö Body ID.
---@return number
function luna.physics.getLinearDamping(world, body) end

--- Returns the current pixels-per-meter scale set on the physics world.
---@param world number ÔÇö World ID to query.
---@return number
function luna.physics.getMeter(world) end

--- Returns whether continuous collision detection (CCD) is enabled on the body.
---@param world number ÔÇö World ID.
---@param body number ÔÇö Body ID.
---@return boolean
function luna.physics.isBullet(world, body) end

--- Returns whether the body's rotation is locked and prevented from changing.
---@param world number ÔÇö World ID.
---@param body number ÔÇö Body ID.
---@return number
function luna.physics.isFixedRotation(world, body) end

--- Returns whether the body is allowed to enter a sleep state when inactive.
---@param world number ÔÇö World ID.
---@param body number ÔÇö Body ID.
---@return number
function luna.physics.isSleepingAllowed(world, body) end

--- Creates a rigid body in the given world.
---@param world_id_val any
---@param x any
---@param y any
---@param btype any
function luna.physics.newBody(world_id_val, x, y, btype) end

--- Creates a static chain body from a list of connected edge segments.
---@param world number ÔÇö World ID.
---@param vertices number ÔÇö Flat or nested table of (x, y) chain vertices.
---@param closed? number ÔÇö Optional boolean; true to close the chain into a loop.
---@return number
function luna.physics.newChainBody(world, vertices, closed) end

--- Creates a standalone chain shape from a closed/open flag followed by flat vertex coordinates.
---@param closed boolean `boolean`. True to close the loop.
---@param x1_y1_x2_y2_ number At least 2 vertex pairs (4 numbers).
---@return any
function luna.physics.newChainShape(closed, x1_y1_x2_y2_) end

--- Creates a circle-shaped physics body at the given world position.
---@param world number ÔÇö World ID.
---@param type number ÔÇö Body type: 'static', 'dynamic', or 'kinematic'.
---@param x number ÔÇö Center X in world units.
---@param y number ÔÇö Center Y in world units.
---@param radius number ÔÇö Circle radius in world units.
---@return number
function luna.physics.newCircleBody(world, type, x, y, radius) end

--- Creates a standalone circle shape.
---@param radius number `number`. Circle radius in world units.
---@return any
function luna.physics.newCircleShape(radius) end

--- Creates a single-segment edge body connecting two points in world space.
---@param world number ÔÇö World ID.
---@param x1 number ÔÇö Start point in world units.
---@param y1 number ÔÇö Start point in world units.
---@param x2 number ÔÇö End point in world units.
---@param y2 number ÔÇö End point in world units.
---@return number
function luna.physics.newEdgeBody(world, x1, y1, x2, y2) end

--- Creates a standalone line-segment shape.
---@param x1 number `number`. Start X.
---@param y1 number `number`. Start Y.
---@param x2 number `number`. End X.
---@param y2 number `number`. End Y.
---@return any
function luna.physics.newEdgeShape(x1, y1, x2, y2) end

--- Creates a convex polygon body defined by a list of local-space vertices.
---@param world number ÔÇö World ID.
---@param type number ÔÇö Body type: 'static', 'dynamic', or 'kinematic'.
---@param x number ÔÇö World X position for the body's origin.
---@param y number ÔÇö World Y position for the body's origin.
---@param vertices number ÔÇö Flat or nested table of (x, y) polygon vertices in local space.
---@return number
function luna.physics.newPolygonBody(world, type, x, y, vertices) end

--- Creates a standalone convex polygon shape from flat vertex coordinates.
---@param x1_y1_x2_y2_ number At least 3 vertex pairs (6 numbers).
---@return any
function luna.physics.newPolygonShape(x1_y1_x2_y2_) end

--- Creates a standalone rectangle shape from half-extents.
---@param hx number `number`. Half-width.
---@param hy number `number`. Half-height.
---@return any
function luna.physics.newRectangleShape(hx, hy) end

--- Creates a new regular polygon body.
function luna.physics.newRegularPolygonBody() end

--- Creates a new physics simulation world.
---@param gx any
---@param gy any
function luna.physics.newWorld(gx, gy) end

--- Returns all bodies whose axis-aligned bounding boxes overlap the given query rectangle.
---@param world number ÔÇö World ID.
---@param x1 number ÔÇö Left edge of the query box in world units.
---@param y1 number ÔÇö Top edge of the query box in world units.
---@param x2 any ÔÇö Right edge in world units.
---@param y2 any ÔÇö Bottom edge in world units.
---@return number
function luna.physics.queryBoundingBox(world, x1, y1, x2, y2) end

--- Casts a ray from the origin in the given direction and returns the first body hit.
---@param world number ÔÇö World ID to cast in.
---@param x1 number ÔÇö Ray origin X in world units.
---@param y1 number ÔÇö Ray origin Y in world units.
---@param x2 number ÔÇö Ray end X in world units.
---@param y2 number ÔÇö Ray end Y in world units.
---@return number
function luna.physics.raycast(world, x1, y1, x2, y2) end

--- Casts a ray and returns every body it intersects, sorted by distance.
---@param world number ÔÇö World ID to cast in.
---@param x1 number ÔÇö Ray origin X in world units.
---@param y1 number ÔÇö Ray origin Y in world units.
---@param x2 number ÔÇö Ray end X in world units.
---@param y2 number ÔÇö Ray end Y in world units.
---@return number
---@return number
function luna.physics.raycastAll(world, x1, y1, x2, y2) end

--- Sets the angular damping coefficient that gradually reduces the body's spin.
---@param world number ÔÇö World ID.
---@param body number ÔÇö Body ID.
---@param damping any ÔÇö Non-negative damping coefficient.
function luna.physics.setAngularDamping(world, body, damping) end

--- Sets the angular velocity of the body to the given value in radians per second.
---@param world number ÔÇö World ID.
---@param body number ÔÇö Body ID.
---@param omega number ÔÇö Angular velocity in radians per second.
function luna.physics.setAngularVelocity(world, body, omega) end

--- Sets the rotation angle (radians) of a physics body.
---@param world_id_val any
---@param body_id_val any
---@param angle any
function luna.physics.setBodyAngle(world_id_val, body_id_val, angle) end

--- Overrides the simulated mass of the body with the given value.
---@param world number ÔÇö World ID.
---@param body number ÔÇö Body ID.
---@param mass number ÔÇö New mass in physics units.
function luna.physics.setBodyMass(world, body, mass) end

--- Sets the position of a physics body.
---@param world_id_val any
---@param body_id_val any
---@param x any
---@param y any
function luna.physics.setBodyPosition(world_id_val, body_id_val, x, y) end

--- Sets the width and height dimensions of the body's collision shape.
---@param world number ÔÇö World ID.
---@param body number ÔÇö Body ID to resize.
---@param width number ÔÇö New shape width in world units.
---@param height number ÔÇö New shape height in world units.
function luna.physics.setBodySize(world, body, width, height) end

--- Sets the body type: 'dynamic', 'static', or 'kinematic'.
---@param world_id_val any
---@param body_id_val any
---@param btype any
function luna.physics.setBodyType(world_id_val, body_id_val, btype) end

--- Sets the linear velocity of a physics body.
---@param world_id_val any
---@param body_id_val any
---@param vx any
---@param vy any
function luna.physics.setBodyVelocity(world_id_val, body_id_val, vx, vy) end

--- Enables continuous collision detection (CCD) on a body to prevent tunneling at high speeds.
---@param world number ÔÇö World ID.
---@param body number ÔÇö Body ID to configure.
---@param enable boolean ÔÇö true to enable CCD, false to disable.
function luna.physics.setBullet(world, body, enable) end

--- Locks or unlocks the body's rotation axis so it cannot spin in the simulation.
---@param world number ÔÇö World ID.
---@param body number ÔÇö Body ID.
---@param fixed boolean ÔÇö true to prevent rotation, false to allow it.
function luna.physics.setFixedRotation(world, body, fixed) end

--- Sets the global gravity vector for the world.
---@param world_id_val any
---@param gx any
---@param gy any
function luna.physics.setGravity(world_id_val, gx, gy) end

--- Sets a per-body multiplier applied to the world gravity vector for this body.
---@param world number ÔÇö World ID.
---@param body number ÔÇö Body ID.
---@param scale number ÔÇö Gravity scale (1.0 = full gravity, 0.0 = weightless).
function luna.physics.setGravityScale(world, body, scale) end

--- Sets the lower and upper angular or linear limits on a constrained joint.
---@param world number ÔÇö World ID.
---@param joint number ÔÇö Joint ID.
---@param lower number ÔÇö Lower limit value (angle in radians or distance).
---@param upper any ÔÇö Upper limit value.
function luna.physics.setJointLimits(world, joint, lower, upper) end

--- Enables or disables the angular/linear limit constraints on a joint.
---@param world number ÔÇö World ID.
---@param joint number ÔÇö Joint ID.
---@param enabled boolean ÔÇö true to enforce limits, false to disable them.
function luna.physics.setJointLimitsEnabled(world, joint, enabled) end

--- Sets the target motor speed for a motorized revolute or prismatic joint.
---@param world number ÔÇö World ID.
---@param joint number ÔÇö Joint ID.
---@param speed any ÔÇö Target speed in rad/s (revolute) or m/s (prismatic).
function luna.physics.setJointMotorSpeed(world, joint, speed) end

--- Sets the linear damping coefficient that gradually slows the body's movement.
---@param world number ÔÇö World ID.
---@param body number ÔÇö Body ID.
---@param damping any ÔÇö Non-negative damping coefficient.
function luna.physics.setLinearDamping(world, body, damping) end

--- Sets the pixels-per-meter ratio used to convert physics world units to screen pixels.
---@param meter number ÔÇö Number of pixels that represent one physics meter.
function luna.physics.setMeter(meter) end

--- Updates the target world-space point that the mouse joint pulls the body toward.
---@param world number ÔÇö World ID.
---@param joint number ÔÇö Mouse joint ID.
---@param x number ÔÇö New target X in world units.
---@param y number ÔÇö New target Y in world units.
function luna.physics.setMouseJointTarget(world, joint, x, y) end

--- Sets whether the body is allowed to enter a sleep state when it comes to rest.
---@param world number ÔÇö World ID.
---@param body number ÔÇö Body ID.
---@param allowed number ÔÇö true to allow sleeping, false to keep the body always awake.
function luna.physics.setSleepingAllowed(world, body, allowed) end

--- Advances the physics simulation by the given timestep in seconds.
---@param world_id_val any
---@param dt any
function luna.physics.step(world_id_val, dt) end

---@class luna.pipeline
luna.pipeline = {}

---@class Pipeline
local Pipeline = {}

--- Adds a step to the pipeline. Returns self for chaining.
---@param step any `PipelineStep`.
---@return any
function Pipeline:addStep(step) end

--- Cancels all pending and waiting steps.
function Pipeline:cancel() end

--- Clears all steps from the pipeline.
function Pipeline:clear() end

--- Returns the stored async context table, or nil if not in an async run.
---@return table
function Pipeline:getContext() end

--- Returns the current error mode as a string (`"abort"` or `"continue"`).
---@return string
function Pipeline:getErrorMode() end

--- Returns the topological execution order as an array of step names.
---@return string
function Pipeline:getExecutionOrder() end

--- Returns the pipeline's name.
---@return string
function Pipeline:getName() end

--- Returns parallel execution groups as a nested array. Returns `(nil, error_string)` on cycle.
---@return string
function Pipeline:getParallelGroups() end

--- Returns the current result table built from step states, or nil if nothing has run.
---@return table
function Pipeline:getResult() end

--- Returns the LuaStep wrapper for the named step, or nil.
---@param name string `String`.
---@return any
function Pipeline:getStep(name) end

--- Returns the total number of steps.
---@return any
function Pipeline:getStepCount() end

--- Returns a Lua array of all step wrappers in the pipeline.
---@return table
function Pipeline:getSteps() end

--- Returns a Lua array of all steps whose tag matches the given string.
---@param tag string `String`.
---@return table
function Pipeline:getStepsByTag(tag) end

--- Returns `true` if all steps have reached a terminal state.
---@return boolean
function Pipeline:isComplete() end

--- Returns `true` if the pipeline is currently running asynchronously.
---@return boolean
function Pipeline:isRunning() end

--- Removes a step from the pipeline by name.
---@param name string `String`.
function Pipeline:removeStep(name) end

--- Resets all step states and clears the async context.
function Pipeline:reset() end

--- Executes the pipeline synchronously in topological order.
---@param context table `table?`.
---@return table
function Pipeline:run(context) end

--- Starts an async pipeline run. Steps are executed one-per-frame via `update(dt)`.
---@param context table `table?`.
function Pipeline:runAsync(context) end

--- Sets the pipeline error mode: `"abort"` or `"continue"`.
---@param mode string `String`.
function Pipeline:setErrorMode(mode) end

--- Sets the pipeline's name.
---@param name string `String`.
function Pipeline:setName(name) end

--- Sets the callback to invoke when the pipeline completes.
---@param fn function `function | nil`.
function Pipeline:setOnComplete(fn) end

--- Sets the callback to invoke each time a step fails.
---@param fn function `function | nil`.
function Pipeline:setOnStepError(fn) end

--- Serialises the pipeline definition to a Lua table (no callbacks).
---@return table
function Pipeline:toTable() end

--- Advances the async pipeline by one tick. Returns `true` when all steps are done.
---@param dt any `f32`.
---@return boolean
function Pipeline:update(dt) end

--- Validates the pipeline DAG. Returns `(ok, error_array)`.
---@return boolean
function Pipeline:validate() end

---@class PipelineStep
local PipelineStep = {}

--- Adds a dependency on another step. Returns self for chaining.
---@param dep string `PipelineStep | String`.
---@return any
function PipelineStep:dependsOn(dep) end

--- Returns the number of execution attempts so far.
---@return any
function PipelineStep:getAttempt() end

--- Retrieves a metadata value by key, returning nil if not found.
---@param key string `String`.
---@return string
function PipelineStep:getData(key) end

--- Returns the configured delay in seconds.
---@return any
function PipelineStep:getDelay() end

--- Returns the list of dependency step names.
---@return table
function PipelineStep:getDependencies() end

--- Returns the number of declared dependencies.
---@return any
function PipelineStep:getDependencyCount() end

--- Returns total seconds spent executing this step.
---@return any
function PipelineStep:getDuration() end

--- Returns the error message from the last failed attempt, or nil.
---@return string
function PipelineStep:getError() end

--- Returns the unique name of this step.
---@return string
function PipelineStep:getName() end

--- Returns the configured retry count.
---@return any
function PipelineStep:getRetryCount() end

--- Returns the current execution status as a string.
---@return string
function PipelineStep:getStatus() end

--- Returns the tag on this step, or nil if unset.
---@return string
function PipelineStep:getTag() end

--- Returns the timeout stored in metadata, or 0.0 if unset.
---@return any
function PipelineStep:getTimeout() end

--- Returns whether this step is marked as optional.
---@return boolean
function PipelineStep:isOptional() end

--- Stores a Lua function as the execute callback for this step.
---@param fn function `function`.
function PipelineStep:setCallback(fn) end

--- Stores a Lua function (or nil) as the run-condition for this step.
---@param fn function `function | nil`.
function PipelineStep:setCondition(fn) end

--- Stores an arbitrary string value under the given key in step metadata.
---@param key string `String`.
---@param value string `String`.
function PipelineStep:setData(key, value) end

--- Sets the delay (in seconds) to wait after dependencies finish.
---@param seconds any `f32`.
function PipelineStep:setDelay(seconds) end

--- Stores a Lua function (or nil) to call if this step fails.
---@param fn function `function | nil`.
function PipelineStep:setOnError(fn) end

--- Marks whether this step is optional (downstream steps continue on failure).
---@param optional boolean `bool`.
function PipelineStep:setOptional(optional) end

--- Sets the maximum number of retry attempts on failure.
---@param count any `u32`.
function PipelineStep:setRetryCount(count) end

--- Sets the delay (in seconds) between retry attempts.
---@param seconds any `f32`.
function PipelineStep:setRetryDelay(seconds) end

--- Sets the tag on this step for grouping and filtering.
---@param tag string `String`.
function PipelineStep:setTag(tag) end

--- Stores a timeout (in seconds) in the step's metadata.
---@param seconds any `f32`.
function PipelineStep:setTimeout(seconds) end

---@param def any
function luna.pipeline.fromTable(def) end

---@param name? any (optional)
function luna.pipeline.newPipeline(name) end

---@param name any
---@param callback? any (optional)
function luna.pipeline.newStep(name, callback) end

---@class luna.postfx
luna.postfx = {}

---@class ImageEffect
local ImageEffect = {}

--- Appends a new effect pass by name to the end of this effect chain.
---@param name string â€” `string` â€” Effect type name (e.g. `"blur"`, `"sepia"`).
---@return number
function ImageEffect:addEffect(name) end

--- Removes all effects from this chain.
function ImageEffect:clearEffects() end

--- Returns a deep clone of this `ImageEffect`.
---@return Image
function ImageEffect:clone() end

--- Returns the number of effects in this chain.
---@return number
function ImageEffect:effectCount() end

--- Returns the effect at the given 1-based index or by name, or `nil`.
---@param key string ? `integer | string` ? 1-based index or effect type name.
---@return number
function ImageEffect:getEffect(key) end

--- Removes an effect by 1-based index or by type name.
---@param key string ? `integer | string` ? 1-based index or effect type name.
---@return boolean
function ImageEffect:removeEffect(key) end

--- Serialises this effect chain to a TOML file at the given path.
---@param path string ? `string` ? Destination file path.
---@return any
function ImageEffect:save(path) end

---@class PostFxEffect
local PostFxEffect = {}

--- Returns the string name of this effect's type.
---@return string
function PostFxEffect:getEffectType() end

--- Returns a sorted list of all parameter names currently set on this effect.
---@return string
function PostFxEffect:getParameterNames() end

--- Returns the string name of this effect's type.
---@return string
function PostFxEffect:getType() end

--- Returns `true` if the named parameter exists on this effect.
---@param name string â€” `string` â€” Parameter key to test.
---@return number
function PostFxEffect:hasParameter(name) end

--- Returns `true` if this is a built-in effect (not a custom shader pass).
---@return boolean
function PostFxEffect:isBuiltIn() end

--- Returns `true` if this effect is currently enabled.
---@return boolean
function PostFxEffect:isEnabled() end

--- Sets the colour grading brightness multiplier.
---@param value number â€” `number` â€” Brightness multiplier (default 1.0).
function PostFxEffect:setBrightness(value) end

--- Sets the colour grading contrast.
---@param value number â€” `number` â€” Contrast multiplier (default 1.0).
function PostFxEffect:setContrast(value) end

--- Enables or disables this effect within its parent stack.
---@param enabled boolean â€” `boolean` â€” `true` to activate, `false` to skip.
function PostFxEffect:setEnabled(enabled) end

--- Sets the intensity for bloom or godrays effects.
---@param value number â€” `number` â€” Intensity multiplier (typically 0.0â€“2.0).
function PostFxEffect:setIntensity(value) end

--- Sets the chromatic aberration pixel offset.
---@param value number â€” `number` â€” Pixel offset for channel separation.
function PostFxEffect:setOffset(value) end

--- Sets a named float parameter on the effect.
---@param name string â€” `string` â€” Parameter key.
---@param value number â€” `number` â€” New float value.
function PostFxEffect:setParameter(name, value) end

--- Sets the Gaussian blur radius.
---@param value number â€” `number` â€” Blur radius in pixels.
function PostFxEffect:setRadius(value) end

--- Sets the colour grading saturation.
---@param value number â€” `number` â€” Saturation multiplier (0.0â€“2.0, default 1.0).
function PostFxEffect:setSaturation(value) end

--- Sets the CRT scanline strength.
---@param value number â€” `number` â€” Scanline opacity (0.0â€“1.0).
function PostFxEffect:setScanlineStrength(value) end

--- Sets the vignette or blur strength.
---@param value number â€” `number` â€” Strength factor (0.0â€“1.0).
function PostFxEffect:setStrength(value) end

--- Sets the bloom bright-pass threshold.
---@param value number â€” `number` â€” Threshold luminance (0.0â€“1.0).
function PostFxEffect:setThreshold(value) end

---@class PostFxStack
local PostFxStack = {}

--- Appends a `PostFxEffect` to the end of the stack.
---@param effect number â€” `PostFxEffect` userdata â€” The effect to append.
function PostFxStack:add(effect) end

--- Applies all enabled effects in the stack.
function PostFxStack:apply() end

--- Starts a post-processing capture pass.
function PostFxStack:beginCapture() end

--- Ends a post-processing capture pass.
function PostFxStack:endCapture() end

--- Returns both canvas dimensions as `(width, height)`.
---@return number
function PostFxStack:getDimensions() end

--- Returns the effect at a 1-based position in the chain, or `nil`.
---@param index number â€” `integer` â€” 1-based position in the chain.
---@return number
function PostFxStack:getEffect(index) end

--- Returns the number of effects currently in the chain (enabled and disabled).
---@return number
function PostFxStack:getEffectCount() end

--- Returns a Lua table of all currently enabled effects in application order.
---@return number
function PostFxStack:getEnabledEffects() end

--- Returns the canvas height in pixels.
---@return number
function PostFxStack:getHeight() end

--- Returns the canvas width in pixels.
---@return number
function PostFxStack:getWidth() end

--- Returns `true` while the stack is between `beginCapture` and `endCapture`.
---@return boolean
function PostFxStack:isCapturing() end

--- Returns `true` if the given effect is enabled within this stack.
---@param effect number â€” `PostFxEffect` userdata â€” The effect to query.
---@return boolean
function PostFxStack:isEffectEnabled(effect) end

--- Removes a `PostFxEffect` from the stack chain.
---@param effect number â€” `PostFxEffect` userdata â€” The effect to remove.
---@return boolean
function PostFxStack:remove(effect) end

--- Resizes the internal canvas dimensions.
---@param w number â€” `integer` â€” New canvas width in pixels.
---@param h number â€” `integer` â€” New canvas height in pixels.
function PostFxStack:resize(w, h) end

--- Returns a Lua table listing all valid built-in effect type names.
---@return table<string>
function luna.postfx.getEffectTypes() end

--- Loads a per-image effect chain from a TOML preset file saved by `ImageEffect:save`.
---@param path any
---@return ImageEffect
function luna.postfx.loadImageEffect(path) end

--- Creates a built-in post-processing effect by name.
---@param name any
---@return PostFxEffect
function luna.postfx.newEffect(name) end

--- Creates a per-image effect chain.
---@param args any
---@return ImageEffect
function luna.postfx.newImageEffect(args) end

--- Creates a custom shader pass effect.
---@param shader_id any
---@return PostFxEffect
function luna.postfx.newPass(shader_id) end

---@param w? any (optional)
---@param h? any (optional)
function luna.postfx.newStack(w, h) end

---@class luna.procgen
luna.procgen = {}

--- Generates a cave-like map using cellular automata.
---@param w any
---@param h any
---@param opts? any (optional)
---@return table
function luna.procgen.cellularAutomata(w, h, opts) end

--- BFS flood fill on a flat grid of bytes.
---@return table
function luna.procgen.floodFill() end

--- Evaluates a single periodic Perlin noise value at `(x, y)`.
---@param x any
---@param y any
---@param px any
---@param py any
---@return number
function luna.procgen.perlinNoise(x, y, px, py) end

--- Generates Poisson disk sample points using Bridson's algorithm.
---@param w any
---@param h any
---@param min_dist any
---@param max_attempts? any (optional)
---@param seed? any (optional)
---@return table
function luna.procgen.poissonDisk(w, h, min_dist, max_attempts, seed) end

--- Generates a Voronoi diagram for a set of seed points.
---@param w any
---@param h any
---@param pts_tbl any
---@param opts_tbl? any (optional)
---@return table
function luna.procgen.voronoi(w, h, pts_tbl, opts_tbl) end

---@class luna.raycaster
luna.raycaster = {}

--- Lua UserData wrapper for a [`Raycaster2D`] grid.
---@class Raycaster
local Raycaster = {}

--- Returns the cell value at `(x, y)`.
---@param x any
---@param y any
---@return number
function Raycaster:getCell(x, y) end

--- Returns the grid height in cells.
---@return number
function Raycaster:height() end

--- Returns `true` when the cell at `(x, y)` is a wall (value > 0).
---@param x any
---@param y any
---@return boolean
function Raycaster:isBlocked(x, y) end

--- Sets the cell value at grid position `(x, y)`.
---@param x any
---@param y any
---@param val any
function Raycaster:setCell(x, y, val) end

--- Replaces all grid cells from a flat Lua table of numbers.
---@param cells_tbl any
function Raycaster:setCells(cells_tbl) end

--- Returns the grid width in cells.
---@return number
function Raycaster:width() end

--- Creates a new [`Raycaster2D`] grid of the given dimensions.
---@param w any
---@param h any
---@return Raycaster
function luna.raycaster.new(w, h) end

---@class luna.savegame
luna.savegame = {}

---@class mlua
local mlua = {}

function mlua:collect() end

---@param slot any
function mlua:delete(slot) end

function mlua:disableAutoSave() end

---@param slot any
function mlua:exists(slot) end

function mlua:getSchemaVersion() end

---@param slot any
function mlua:getSlotInfo(slot) end

function mlua:getSlots() end

function mlua:getSummary() end

function mlua:isDirty() end

---@param slot any
function mlua:load(slot) end

function mlua:markDirty() end

function mlua:reset() end

function mlua:restore() end

---@param slot any
function mlua:save(slot) end

---@param version any
function mlua:setSchemaVersion(version) end

---@param summary any
function mlua:setSummary(summary) end

---@param name any
function mlua:unregister(name) end

---@param dt any
function mlua:update(dt) end

function luna.savegame.newSaveManager() end

---@class luna.scene
luna.scene = {}

---@class DepthSorter
local DepthSorter = {}

--- Registers a draw callback at the given depth layer. Higher `depth` values draw in front.
---@param callback number `function`: Draw callback `function()` called when flushing this layer.
---@param depth number `number`: Depth value determining draw order (lower = drawn first).
function DepthSorter:add(callback, depth) end

--- Registers a table object with a `draw` method at the given depth.
---@param obj number `table`: Object with a `draw()` method. Uses `obj.depth` if no explicit depth is provided.
function DepthSorter:addObject(obj) end

--- Removes all registered callbacks and objects without calling them.
function DepthSorter:clear() end

--- Calls all registered draw callbacks and object `draw()` methods in sorted depth order, then clears the list.
function DepthSorter:flush() end

--- Returns the number of callbacks and objects currently registered.
---@return number
function DepthSorter:getCount() end

--- Sorts all registered callbacks and objects by their depth values (ascending).
function DepthSorter:sort() end

--- Clears the state.
function luna.scene.clear() end

--- Draw.
function luna.scene.draw() end

--- Returns the current.
---@return any
function luna.scene.getCurrent() end

--- Returns the data.
---@param key any
---@return any
function luna.scene.getData(key) end

--- Returns the registered.
---@param name any
---@return any
function luna.scene.getRegistered(name) end

--- Returns the registered names.
---@return any
function luna.scene.getRegisteredNames() end

--- Returns the stack size.
---@return any
function luna.scene.getStackSize() end

--- Returns the transition progress.
---@return any
function luna.scene.getTransitionProgress() end

--- Returns true if data.
---@param key any
---@return any
function luna.scene.hasData(key) end

--- Returns true if registered.
---@param name any
---@return any
function luna.scene.hasRegistered(name) end

--- Returns true if empty.
---@return boolean
function luna.scene.isEmpty() end

--- Returns true if transitioning.
---@return any
function luna.scene.isTransitioning() end

--- New depth sorter.
---@return any
function luna.scene.newDepthSorter() end

--- Removes an item.
---@param transition? any (optional)
---@param duration? any (optional)
function luna.scene.pop(transition, duration) end

--- Removes to.
---@param name any
---@return boolean
function luna.scene.popTo(name) end

--- Pushes a scene onto the stack.
---@param scene table
---@param transition? string? (optional)
---@param duration? number? (optional)
---@param params? any? (optional)
function luna.scene.push(scene, transition, duration, params) end

--- Register scene.
---@param name any
---@param scene any
function luna.scene.registerScene(name, scene) end

--- Removes data.
---@param key any
function luna.scene.removeData(key) end

--- Sets the data.
---@param key any
---@param value any
function luna.scene.setData(key, value) end

--- Replaces the top scene with a new one.
---@param scene table
---@param transition? string? (optional)
---@param duration? number? (optional)
---@param params? any? (optional)
function luna.scene.switchTo(scene, transition, duration, params) end

--- Unregister scene.
---@param name any
function luna.scene.unregisterScene(name) end

--- Update.
---@param dt any
function luna.scene.update(dt) end

---@class luna.serial
luna.serial = {}

--- Parses a CSV string and returns a Lua table (sequence of row tables).
---@param s any
---@param delim? any (optional)
---@param headers? any (optional)
function luna.serial.fromCsv(s, delim, headers) end

--- Parses a JSON string and returns a Lua table.
---@param s any
function luna.serial.fromJson(s) end

--- Parses a TOML string and returns a Lua table.
---@param s any
function luna.serial.fromToml(s) end

--- Serializes a Lua table (sequence of row tables) to a CSV string.
---@param table any
---@param delim? any (optional)
---@param headers? any (optional)
function luna.serial.toCsv(table, delim, headers) end

--- Serializes a Lua table to a JSON string.
---@param table any
---@param pretty? any (optional)
function luna.serial.toJson(table, pretty) end

--- Serializes a Lua table to a TOML string.
---@param table any
function luna.serial.toToml(table) end

---@class luna.spine
luna.spine = {}

--- Lua UserData wrapper for a [`Skeleton`].
---@class Skeleton
local Skeleton = {}

--- Adds a root bone (no parent) and returns its index.
---@param name any
---@param opts? any (optional)
---@return number
function Skeleton:addBone(name, opts) end

--- Returns the total number of bones.
---@return number
function Skeleton:boneCount() end

--- Returns the index of the named bone, or `nil` if not found.
---@param name any
---@return number|nil
function Skeleton:findBone(name) end

--- Returns the index of the named slot, or `nil` if not found.
---@param name any
---@return number|nil
function Skeleton:findSlot(name) end

--- Returns world-space transform of bone at `idx` as a table.
---@param idx any
---@return table|nil
function Skeleton:getBoneWorld(idx) end

--- Sets the local position of the root offset (bone 0 world position seed).
---@param x any
---@param y any
function Skeleton:setPosition(x, y) end

--- Returns the total number of slots.
---@return number
function Skeleton:slotCount() end

--- Propagates all local transforms down the bone hierarchy to compute
function Skeleton:updateWorldTransforms() end

--- Creates a new, empty [`Skeleton`] with the given name.
---@param name any
---@return Skeleton
function luna.spine.newSkeleton(name) end

---@class luna.sprite
luna.sprite = {}

---@class Animation
local Animation = {}

--- Adds frame to the collection.
---@param x number `number`.
---@param y number `number`.
---@param w number `number`.
---@param h number `number`.
---@return any
function Animation:addFrame(x, y, w, h) end

--- Returns the clip count.
---@param index number `integer`.
---@return any
function Animation:getClipCount(index) end

--- Returns the current clip.
---@return any
function Animation:getCurrentClip() end

--- Returns the current frame.
---@return any
function Animation:getCurrentFrame() end

--- Returns the current quad.
---@return Quad
function Animation:getCurrentQuad() end

--- Returns the frame count.
---@param index number `integer`.
---@return any
function Animation:getFrameCount(index) end

--- Returns the speed.
---@return any
function Animation:getSpeed() end

--- Returns `true` if looping.
---@param f number `number`.
---@return boolean
function Animation:isLooping(f) end

--- Returns `true` if playing.
---@param f number `number`.
---@return boolean
function Animation:isPlaying(f) end

--- Pauses playback.
---@return any
function Animation:pause() end

--- Starts playback.
---@param name string `string`.
---@return any
function Animation:play(name) end

--- Resumes paused playback.
---@param dt number `number`.
function Animation:resume(dt) end

--- Sets the frame.
---@param index number `integer`.
function Animation:setFrame(index) end

--- Sets the speed.
---@param f number `number`.
function Animation:setSpeed(f) end

--- Stops playback.
---@return any
function Animation:stop() end

--- Advances the simulation by `dt` seconds.
---@param dt number `number`.
function Animation:update(dt) end

---@class Camera2D
local Camera2D = {}

--- Returns the bounds.
---@return any
function Camera2D:getBounds() end

--- Returns the dead zone.
---@return any
function Camera2D:getDeadZone() end

--- Returns the follow smooth.
---@param intensity number `number`.
---@param duration number `number`.
---@return any
function Camera2D:getFollowSmooth(intensity, duration) end

--- Returns the look ahead.
---@param dt number `number`.
---@return any
function Camera2D:getLookAhead(dt) end

--- Returns the position.
---@param z number `number`.
---@return any
function Camera2D:getPosition(z) end

--- Returns the rotation.
---@param x number `number`.
---@param y number `number`.
---@param w number `number`.
---@param h number `number`.
---@return any
function Camera2D:getRotation(x, y, w, h) end

--- Returns the target.
---@return any
function Camera2D:getTarget() end

--- Returns the viewport.
---@param x number `number`.
---@param y number `number`.
---@param w number `number`.
---@param h number `number`.
---@return any
function Camera2D:getViewport(x, y, w, h) end

--- Returns the visible area.
---@param w number `number`.
---@param h number `number`.
---@return any
function Camera2D:getVisibleArea(w, h) end

--- Returns the zoom.
---@param r number `number`.
---@return any
function Camera2D:getZoom(r) end

--- Returns `true` if bounds.
---@param dx number `number`.
---@param dy number `number`.
---@return boolean
function Camera2D:hasBounds(dx, dy) end

--- Look at on this Camera2D.
---@param x number `number`.
---@param y number `number`.
function Camera2D:lookAt(x, y) end

--- Move on this Camera2D.
---@param dx number `number`.
---@param dy number `number`.
function Camera2D:move(dx, dy) end

--- Removes bounds from the collection.
---@param dx number `number`.
---@param dy number `number`.
function Camera2D:removeBounds(dx, dy) end

--- Sets the dead zone.
---@param w number `number`.
---@param h number `number`.
function Camera2D:setDeadZone(w, h) end

--- Sets the follow smooth.
---@param intensity number `number`.
---@param duration number `number`.
function Camera2D:setFollowSmooth(intensity, duration) end

--- Sets the look ahead.
---@param mul number `number`.
function Camera2D:setLookAhead(mul) end

--- Sets the position.
---@param x number `number`.
---@param y number `number`.
function Camera2D:setPosition(x, y) end

--- Sets the rotation.
---@param r number `number`.
function Camera2D:setRotation(r) end

--- Sets the target.
---@param x number `number`.
---@param y number `number`.
function Camera2D:setTarget(x, y) end

--- Sets the zoom.
---@param z number `number`.
function Camera2D:setZoom(z) end

--- Shake on this Camera2D.
---@param intensity number `number`.
---@param duration number `number`.
function Camera2D:shake(intensity, duration) end

--- To screen coords on this Camera2D.
---@param wx number `number`.
---@param wy number `number`.
---@return any
function Camera2D:toScreenCoords(wx, wy) end

--- To world coords on this Camera2D.
---@param sx number `number`.
---@param sy number `number`.
---@return any
function Camera2D:toWorldCoords(sx, sy) end

--- Advances the simulation by `dt` seconds.
---@param dt number `number`.
function Camera2D:update(dt) end

---@class ColumnBatch
local ColumnBatch = {}

--- Returns the column count.
---@return any
function ColumnBatch:getColumnCount() end

--- Returns the depth at.
---@param col number `integer`.
---@return any
function ColumnBatch:getDepthAt(col) end

--- Returns the depth buffer.
---@return table
function ColumnBatch:getDepthBuffer() end

--- Returns the screen height.
---@return number
function ColumnBatch:getScreenHeight() end

--- Returns the screen width.
---@return number
function ColumnBatch:getScreenWidth() end

--- Lua UserData wrapper for DecalSurface (internal — no factory).
---@class DecalSurface
local DecalSurface = {}

--- Returns the dimensions.
---@return any
function DecalSurface:getDimensions() end

--- Returns the height.
---@return number
function DecalSurface:getHeight() end

--- Returns the width.
---@return number
function DecalSurface:getWidth() end

---@class DrawLayer
local DrawLayer = {}

--- Removes all entries.
---@return any
function DrawLayer:clear() end

--- Flushes pending data.
---@return any
function DrawLayer:flush() end

--- Returns the count.
---@return integer
function DrawLayer:getCount() end

--- Queue on this DrawLayer.
---@param z number `number`.
---@param func function `function`.
function DrawLayer:queue(z, func) end

---@class GraphRenderer
local GraphRenderer = {}

--- Auto range on this GraphRenderer.
---@param name string `string`.
---@param pts table `table`.
---@param color? table `table` optional.
function GraphRenderer:autoRange(name, pts, color) end

--- Clear series on this GraphRenderer.
---@param b boolean `boolean`.
function GraphRenderer:clearSeries(b) end

--- Returns the cursor value.
---@return any
function GraphRenderer:getCursorValue() end

--- Returns the range.
---@return any
function GraphRenderer:getRange() end

--- Returns the viewport.
---@param xmin number `number`.
---@param xmax number `number`.
---@param ymin number `number`.
---@param ymax number `number`.
---@return any
function GraphRenderer:getViewport(xmin, xmax, ymin, ymax) end

--- Removes series from the collection.
---@param name string `string`.
function GraphRenderer:removeSeries(name) end

--- Sets the cursor position.
---@param x number `number`.
---@param y number `number`.
function GraphRenderer:setCursorPosition(x, y) end

--- Sets the show axes.
---@param b boolean `boolean`.
function GraphRenderer:setShowAxes(b) end

--- Sets the show grid.
---@param b boolean `boolean`.
function GraphRenderer:setShowGrid(b) end

--- Sets the show labels.
---@param r number `number`.
---@param g number `number`.
---@param b number `number`.
---@param a? number `number` optional.
function GraphRenderer:setShowLabels(r, g, b, a) end

--- Sets the title.
---@param x_label string `string`.
---@param y_label string `string`.
function GraphRenderer:setTitle(x_label, y_label) end

---@class LargeMapRenderer
local LargeMapRenderer = {}

--- Returns the chunk size.
---@param x number `number`.
---@param y number `number`.
---@param zoom number `number`.
---@return any
function LargeMapRenderer:getChunkSize(x, y, zoom) end

--- Returns the map size.
---@param s number `integer`.
---@return any
function LargeMapRenderer:getMapSize(s) end

--- Returns the tile.
---@param x number `integer`.
---@param y number `integer`.
---@return any
function LargeMapRenderer:getTile(x, y) end

--- Returns the tileset columns.
---@return any
function LargeMapRenderer:getTilesetColumns() end

--- Returns the total chunks.
---@param cols number `integer`.
---@return any
function LargeMapRenderer:getTotalChunks(cols) end

--- Returns the visible chunks.
---@param cols number `integer`.
---@return any
function LargeMapRenderer:getVisibleChunks(cols) end

--- Invalidate all on this LargeMapRenderer.
---@return any
function LargeMapRenderer:invalidateAll() end

--- Invalidate chunk on this LargeMapRenderer.
---@param cx number `integer`.
---@param cy number `integer`.
function LargeMapRenderer:invalidateChunk(cx, cy) end

--- Returns `true` if l o d enabled.
---@param levels table `table`.
---@return boolean
function LargeMapRenderer:isLODEnabled(levels) end

--- Sets the camera.
---@param x number `number`.
---@param y number `number`.
---@param zoom number `number`.
function LargeMapRenderer:setCamera(x, y, zoom) end

--- Sets the chunk size.
---@param x number `number`.
---@param y number `number`.
---@param zoom number `number`.
function LargeMapRenderer:setChunkSize(x, y, zoom) end

--- Sets the l o d enabled.
---@param b boolean `boolean`.
function LargeMapRenderer:setLODEnabled(b) end

--- Sets the l o d thresholds.
---@param cx number `integer`.
---@param cy number `integer`.
function LargeMapRenderer:setLODThresholds(cx, cy) end

--- Sets the tile.
---@param x number `integer`.
---@param y number `integer`.
---@param tile_id number `integer`.
function LargeMapRenderer:setTile(x, y, tile_id) end

--- Sets the tileset columns.
---@param cols number `integer`.
function LargeMapRenderer:setTilesetColumns(cols) end

--- Sets the viewport.
---@param w number `number`.
---@param h number `number`.
function LargeMapRenderer:setViewport(w, h) end

---@class Light2D
local Light2D = {}

--- Returns the current light color.
---@return number
function Light2D:getColor() end

--- Returns the intensity.
---@param b boolean `boolean`.
---@return number
function Light2D:getIntensity(b) end

--- Returns the light position in world space.
---@return number
---@return number
function Light2D:getPosition() end

--- Returns the current light radius in world units.
---@return number
function Light2D:getRadius() end

--- Returns `true` if this light is currently enabled.
---@return boolean
function Light2D:isEnabled() end

--- Enables or disables this light. Disabled lights contribute no illumination.
---@param enabled boolean `boolean`: `true` to enable.
function Light2D:setEnabled(enabled) end

--- Sets the intensity.
---@param i number `number`.
function Light2D:setIntensity(i) end

--- Sets the light source position in world space.
---@param x number `number`: World X coordinate.
---@param y number `number`: World Y coordinate.
function Light2D:setPosition(x, y) end

--- Sets the falloff radius of this light. Pixels beyond the radius receive no illumination.
---@param radius number `number`: Radius in world units.
function Light2D:setRadius(radius) end

--- Lua UserData wrapper for PaletteLUT (internal — no factory).
---@class PaletteLUT
local PaletteLUT = {}

--- Removes all entries.
---@return any
function PaletteLUT:clear() end

--- Returns the color count.
---@return any
function PaletteLUT:getColorCount() end

--- Returns the from color.
---@param index number `integer`.
---@return any
function PaletteLUT:getFromColor(index) end

--- Returns the to color.
---@param index number `integer`.
---@return any
function PaletteLUT:getToColor(index) end

---@class PolygonMap
local PolygonMap = {}

--- Removes all entries.
---@return any
function PolygonMap:clear() end

--- Clear highlight on this PolygonMap.
---@return any
function PolygonMap:clearHighlight() end

--- Returns the bounding box.
---@return number
function PolygonMap:getBoundingBox() end

--- Returns the region at.
---@param x number `number`.
---@param y number `number`.
---@return any
function PolygonMap:getRegionAt(x, y) end

--- Returns the region center.
---@param name string `string`.
---@return any
function PolygonMap:getRegionCenter(name) end

--- Returns the region color.
---@param name string `string`.
---@return any
function PolygonMap:getRegionColor(name) end

--- Returns the region names.
---@return table
function PolygonMap:getRegionNames() end

--- Returns the region vertices.
---@param name string `string`.
---@return any
function PolygonMap:getRegionVertices(name) end

--- Highlight on this PolygonMap.
---@param name string `string`.
function PolygonMap:highlight(name) end

--- Removes region from the collection.
---@param name string `string`.
---@param r number `number`.
---@param g number `number`.
---@param b number `number`.
---@param a? number `number` optional.
function PolygonMap:removeRegion(name, r, g, b, a) end

--- Sets the outline width.
---@param r number `number`.
---@param g number `number`.
---@param b number `number`.
---@param a? number `number` optional.
function PolygonMap:setOutlineWidth(r, g, b, a) end

---@class SpriteSheet
local SpriteSheet = {}

--- Returns the column.
---@param start number `integer`.
---@param count number `integer`.
---@return any
function SpriteSheet:getColumn(start, count) end

--- Returns the direction frames.
---@param direction number `integer`.
---@return any
function SpriteSheet:getDirectionFrames(direction) end

--- Returns the frame.
---@param index number `integer`.
---@return any
function SpriteSheet:getFrame(index) end

--- Returns the total number of frames in this sprite sheet.
---@return number
function SpriteSheet:getFrameCount() end

--- Returns the frame size.
---@param row number `integer`.
---@return any
function SpriteSheet:getFrameSize(row) end

--- Returns the grid size.
---@param row number `integer`.
---@return number
function SpriteSheet:getGridSize(row) end

--- Returns the group.
---@param name string `string`.
---@return any
function SpriteSheet:getGroup(name) end

--- Returns the group names.
---@return table
function SpriteSheet:getGroupNames() end

--- Returns the range.
---@param start number `integer`.
---@param count number `integer`.
---@return any
function SpriteSheet:getRange(start, count) end

--- Returns the row.
---@param row number `integer`.
---@return any
function SpriteSheet:getRow(row) end

---@class TextureAtlas
local TextureAtlas = {}

--- Removes all entries.
---@return any
function TextureAtlas:clear() end

--- Returns the dimensions.
---@return any
function TextureAtlas:getDimensions() end

--- Returns the pixel bounds of the named region.
---@param name string `string`: Region name.
---@return number
function TextureAtlas:getRegion(name) end

--- Returns the region count.
---@return any
function TextureAtlas:getRegionCount() end

--- Returns the regions.
---@return table
function TextureAtlas:getRegions() end

--- Pack on this TextureAtlas.
---@param name string `string`.
---@param w number `integer`.
---@param h number `integer`.
---@return any
function TextureAtlas:pack(name, w, h) end

--- Lua UserData wrapper for Trail (internal — no factory).
---@class Trail
local Trail = {}

--- Removes all entries.
---@return any
function Trail:clear() end

--- Returns the lifetime.
---@param d number `number`.
---@return any
function Trail:getLifetime(d) end

--- Returns the point count.
---@return number
function Trail:getPointCount() end

--- Returns the width.
---@param r number `number`.
---@param g number `number`.
---@param b number `number`.
---@param a? number `number` optional.
---@return number
function Trail:getWidth(r, g, b, a) end

--- Adds point to the collection.
---@param x number `number`.
---@param y number `number`.
function Trail:pushPoint(x, y) end

--- Sets the lifetime.
---@param lt number `number`.
function Trail:setLifetime(lt) end

--- Sets the min distance.
---@param d number `number`.
function Trail:setMinDistance(d) end

--- Sets the width.
---@param start number `number`.
---@param end? number `number` optional.
function Trail:setWidth(start, end) end

--- Advances the simulation by `dt` seconds.
---@param start number `number`.
---@param end? number `number` optional.
function Trail:update(start, end) end

---@class Viewport
local Viewport = {}

--- Returns the game dimensions.
---@param mode string `string`.
---@return any
function Viewport:getGameDimensions(mode) end

--- Returns the current viewport scroll offset.
---@return number
---@return number
function Viewport:getOffset() end

--- Returns the current content scale factor.
---@return number
function Viewport:getScale() end

--- Returns the scale mode.
---@param mode string `string`.
---@return string
function Viewport:getScaleMode(mode) end

--- Resize on this Viewport.
---@param w number `number`.
---@param h number `number`.
function Viewport:resize(w, h) end

--- Sets the scale mode.
---@param sx number `number`.
---@param sy number `number`.
function Viewport:setScaleMode(sx, sy) end

--- To game on this Viewport.
---@param sx number `number`.
---@param sy number `number`.
---@return any
function Viewport:toGame(sx, sy) end

--- Converts world-space coordinates to screen-space pixel coordinates.
---@param wx number `number`: World X.
---@param wy number `number`: World Y.
---@return number
---@return number
function Viewport:toScreen(wx, wy) end

---@class ViewportScale
local ViewportScale = {}

--- Returns the game dimensions.
---@return any
function ViewportScale:getGameDimensions() end

--- Returns the mode.
---@param sx number `number`.
---@param sy number `number`.
---@return string
function ViewportScale:getMode(sx, sy) end

--- Returns the offset.
---@return any
function ViewportScale:getOffset() end

--- Returns the scale.
---@param sx number `number`.
---@param sy number `number`.
---@return number
function ViewportScale:getScale(sx, sy) end

--- Returns the scaled dimensions.
---@return number
function ViewportScale:getScaledDimensions() end

--- Resize on this ViewportScale.
---@param w number `number`.
---@param h number `number`.
function ViewportScale:resize(w, h) end

--- To game coords on this ViewportScale.
---@param sx number `number`.
---@param sy number `number`.
---@return any
function ViewportScale:toGameCoords(sx, sy) end

--- To screen coords on this ViewportScale.
---@param gx number `number`.
---@param gy number `number`.
---@return any
function ViewportScale:toScreenCoords(gx, gy) end

--- New animation.
---@return any
function luna.sprite.newAnimation() end

--- New camera2d.
---@param w? any (optional)
---@param h? any (optional)
---@return any
function luna.sprite.newCamera2D(w, h) end

--- New column batch.
---@param col_count any
---@param screen_w any
---@param screen_h any
---@return any
function luna.sprite.newColumnBatch(col_count, screen_w, screen_h) end

--- New draw layer.
---@return any
function luna.sprite.newDrawLayer() end

--- New graph renderer.
---@return any
function luna.sprite.newGraphRenderer() end

--- New large map renderer.
---@param tile_w any
---@param tile_h any
---@return any
function luna.sprite.newLargeMapRenderer(tile_w, tile_h) end

--- New light2d.
---@param x any
---@param y any
---@param radius any
---@return any
function luna.sprite.newLight2D(x, y, radius) end

--- New polygon map.
---@return any
function luna.sprite.newPolygonMap() end

--- New sprite sheet.
---@param tex_w any
---@param tex_h any
---@param frame_w any
---@param frame_h any
---@return any
function luna.sprite.newSpriteSheet(tex_w, tex_h, frame_w, frame_h) end

--- New texture atlas.
---@param w any
---@param h any
---@param padding? any (optional)
---@return any
function luna.sprite.newTextureAtlas(w, h, padding) end

--- New viewport.
---@param w any
---@param h any
---@param mode? any (optional)
---@return any
function luna.sprite.newViewport(w, h, mode) end

--- New viewport scale.
---@param w any
---@param h any
---@param mode? any (optional)
---@return any
function luna.sprite.newViewportScale(w, h, mode) end

---@class luna.system
luna.system = {}

--- Returns the CPU architecture string for the current machine.
---@return number
function luna.system.getArch() end

--- Returns the command-line arguments as a table.
---@return table
function luna.system.getArgs() end

--- Returns the output table from the most recently completed runBatch call.
---@param handle number Batch handle returned by runBatch.
---@return string
function luna.system.getBatchResults(handle) end

--- Returns the current contents of the system clipboard.
---@return any
function luna.system.getClipboardText() end

--- Returns whether the debug overlay is currently visible.
function luna.system.getDebugOverlay() end

--- Returns the value of the named OS environment variable, or nil if not set.
---@param name number Environment variable name (case-sensitive on Linux/macOS).
---@return string
function luna.system.getEnv(name) end

--- Returns a table of system information including OS name, CPU model, and installed RAM.
---@return table
function luna.system.getInfo() end

--- Returns the last unhandled error message, or nil.
---@return any
function luna.system.getLastError() end

--- Returns the name of the current minimum log level for runtime messages.
---@return any
function luna.system.getLogLevel() end

--- Returns the total amount of installed system RAM in megabytes.
---@return number
function luna.system.getMemorySize() end

--- Returns the host operating system name ('Windows', 'Linux', 'macOS').
---@return any
function luna.system.getOS() end

--- Returns battery state, percentage charged, and estimated time remaining.
---@return number
function luna.system.getPowerInfo() end

--- Returns an ordered list of the user's preferred locale strings (e.g. 'en-US').
---@return string
function luna.system.getPreferredLocales() end

--- Returns the number of logical CPU cores available.
---@return any
function luna.system.getProcessorCount() end

--- Returns the Luna2D engine version string.
---@return any
function luna.system.getVersion() end

--- Emit a log message from Lua at the specified level.
---@param level any
---@param message any
function luna.system.log(level, message) end

--- Opens a URL in the system's default browser.
---@param url any
---@return any
function luna.system.openURL(url) end

--- Parses a command-line argument string and returns a structured key/value table.
---@param args string Argument string or table (e.g. '--flag=value --bool').
---@return boolean
function luna.system.parseArgs(args) end

--- Runs a list of shell commands in parallel and returns immediately without blocking.
---@param commands string Table of command strings to execute concurrently.
---@return number
function luna.system.runBatch(commands) end

--- Replaces the system clipboard contents with the given string.
---@param text any
function luna.system.setClipboardText(text) end

--- Shows or hides the FPS/draw-call debug overlay.
---@param enabled any
function luna.system.setDebugOverlay(enabled) end

--- Sets the minimum severity level for runtime log messages.
---@param level any One of 'debug', 'info', 'warn', or 'error'.
function luna.system.setLogLevel(level) end

---@class luna.terminal
luna.terminal = {}

---@class Terminal
local Terminal = {}

---@param widget_ud any
function Terminal:addWidget(widget_ud) end

function Terminal:clear() end

function Terminal:clearWidgets() end

---@param x? any (optional)
---@param y? any (optional)
function Terminal:draw(x, y) end

---@param col any
---@param row any
function Terminal:get(col, row) end

function Terminal:getCellSize() end

function Terminal:getDimensions() end

function Terminal:getFocused() end

function Terminal:getWidgetCount() end

---@param key any
function Terminal:keypressed(key) end

---@param widget_ud any
function Terminal:removeWidget(widget_ud) end

---@param args any
function Terminal:set(args) end

---@param value any
function Terminal:setFocus(value) end

---@param text any
function Terminal:textinput(text) end

---@class Widget
local Widget = {}

---@param child_ud any
function Widget:addChild(child_ud) end

---@param item any
function Widget:addItem(item) end

function Widget:clearChildren() end

function Widget:clearItems() end

---@param index any
function Widget:getChild(index) end

function Widget:getChildCount() end

function Widget:getColor() end

---@param index any
function Widget:getItem(index) end

function Widget:getItemCount() end

function Widget:getMaxLength() end

function Widget:getPosition() end

function Widget:getSelected() end

function Widget:getSize() end

function Widget:getStyle() end

function Widget:getTag() end

function Widget:getText() end

function Widget:getTitle() end

function Widget:isEnabled() end

function Widget:isVisible() end

---@param child_ud any
function Widget:removeChild(child_ud) end

---@param index any
function Widget:removeItem(index) end

---@param enabled any
function Widget:setEnabled(enabled) end

---@param max_length any
function Widget:setMaxLength(max_length) end

---@param callback? any (optional)
function Widget:setOnChange(callback) end

---@param callback? any (optional)
function Widget:setOnClick(callback) end

---@param callback? any (optional)
function Widget:setOnSelect(callback) end

---@param col any
---@param row any
function Widget:setPosition(col, row) end

---@param index? any (optional)
function Widget:setSelected(index) end

---@param width any
---@param height any
function Widget:setSize(width, height) end

---@param style_name any
function Widget:setStyle(style_name) end

---@param tag any
function Widget:setTag(tag) end

---@param text any
function Widget:setText(text) end

---@param title any
function Widget:setTitle(title) end

---@param visible any
function Widget:setVisible(visible) end

---@param col any
---@param row any
---@param width any
---@param height any
function luna.terminal.newBorder(col, row, width, height) end

function luna.terminal.newButton() end

---@param col any
---@param row any
---@param text? any (optional)
function luna.terminal.newLabel(col, row, text) end

---@param col any
---@param row any
---@param width any
---@param height any
function luna.terminal.newList(col, row, width, height) end

---@param col any
---@param row any
---@param width? any (optional)
---@param height? any (optional)
function luna.terminal.newPanel(col, row, width, height) end

---@param cols? any (optional)
---@param rows? any (optional)
function luna.terminal.newTerminal(cols, rows) end

---@param col any
---@param row any
---@param width any
function luna.terminal.newTextBox(col, row, width) end

---@class luna.thread
luna.thread = {}

---@class Thread
local Thread = {}

--- Returns the error message if the thread terminated with a Lua error, or `nil` if it completed normally.
---@return string
function Thread:getError() end

--- Returns `true` if the thread is currently executing.
---@return boolean
function Thread:isRunning() end

--- Launches the background thread, passing optional arguments to the Lua script via `...`.
---@param ... number `any`: Optional arguments forwarded to the thread script as Lua values.
function Thread:start(...) end

--- Blocks the calling coroutine until this thread finishes execution.
function Thread:wait() end

--- Get or create a named global channel (singleton, shared across threads).
---@param name any
---@return any
function luna.thread.getChannel(name) end

--- Create an unnamed thread-safe channel for inter-thread communication.
---@return any
function luna.thread.newChannel() end

--- Create a new background thread from a Lua code string.
---@param code any
---@return any
function luna.thread.newThread(code) end

---@class luna.tilemap
luna.tilemap = {}

---@class AutoTileSheet
local AutoTileSheet = {}

--- luna.tilemap.AutoTileSheet:getBitmaskForTile(index)
---@param index any
function AutoTileSheet:getBitmaskForTile(index) end

--- luna.tilemap.AutoTileSheet:getComposite48GridQuad(index) -> {x,y,width,height}
---@param index any
function AutoTileSheet:getComposite48GridQuad(index) end

--- luna.tilemap.AutoTileSheet:getGridQuad(index, cols) -> {x,y,width,height}
---@param index any
---@param cols any
function AutoTileSheet:getGridQuad(index, cols) end

--- luna.tilemap.AutoTileSheet:getLayout()
function AutoTileSheet:getLayout() end

--- luna.tilemap.AutoTileSheet:getQuad(index)
---@param index any
function AutoTileSheet:getQuad(index) end

--- luna.tilemap.AutoTileSheet:getQuarterDstRects(x, y) -> {[1],...[4]}
---@param x any
---@param y any
function AutoTileSheet:getQuarterDstRects(x, y) end

--- luna.tilemap.AutoTileSheet:getQuarterRects(bitmask) -> {[1]={x,y,w,h},...[4]=...}
---@param bitmask any
function AutoTileSheet:getQuarterRects(bitmask) end

--- luna.tilemap.AutoTileSheet:getTileCount()
function AutoTileSheet:getTileCount() end

--- luna.tilemap.AutoTileSheet:getTileForBitmask(bitmask)
---@param bitmask any
function AutoTileSheet:getTileForBitmask(bitmask) end

--- luna.tilemap.AutoTileSheet:getTileHeight()
function AutoTileSheet:getTileHeight() end

--- luna.tilemap.AutoTileSheet:getTileWidth()
function AutoTileSheet:getTileWidth() end

---@class ChunkMap
local ChunkMap = {}

--- luna.tilemap.ChunkMap:chunkTileRange(cx, cy) -> x0,y0,x1,y1
---@param cx any
---@param cy any
function ChunkMap:chunkTileRange(cx, cy) end

--- luna.tilemap.ChunkMap:clearTile(x, y)
---@param x any
---@param y any
function ChunkMap:clearTile(x, y) end

--- luna.tilemap.ChunkMap:getChunkSize()
function ChunkMap:getChunkSize() end

--- luna.tilemap.ChunkMap:getLoadedChunks() -> [{cx,cy}, ...]
function ChunkMap:getLoadedChunks() end

--- luna.tilemap.ChunkMap:getTile(x, y) -- 0-based tile coords
---@param x any
---@param y any
function ChunkMap:getTile(x, y) end

--- luna.tilemap.ChunkMap:loadChunk(cx, cy)
---@param cx any
---@param cy any
function ChunkMap:loadChunk(cx, cy) end

--- luna.tilemap.ChunkMap:setTile(x, y, gid) -- 0-based tile coords
---@param x any
---@param y any
---@param gid any
function ChunkMap:setTile(x, y, gid) end

--- luna.tilemap.ChunkMap:unloadChunk(cx, cy)
---@param cx any
---@param cy any
function ChunkMap:unloadChunk(cx, cy) end

---@class IsoMap
local IsoMap = {}

--- Adds an elevation level layer to the isometric map for multi-height rendering.
---@param level number ÔÇö Level definition table or level index integer.
function IsoMap:addLevel(level) end

--- Returns the height of the isometric map in tile rows.
---@return number
function IsoMap:getHeight() end

--- luna.tilemap.IsoMap:getLevelCount()
function IsoMap:getLevelCount() end

--- luna.tilemap.IsoMap:getLevelHeight()
function IsoMap:getLevelHeight() end

--- luna.tilemap.IsoMap:getTileHeight()
function IsoMap:getTileHeight() end

--- Returns the width in pixels of a single isometric tile.
---@return number
function IsoMap:getTileWidth() end

--- Returns the width of the isometric map in tile columns.
---@return number
function IsoMap:getWidth() end

--- luna.tilemap.IsoMap:isLevelVisible(levelIdx)
---@param idx any
function IsoMap:isLevelVisible(idx) end

--- luna.tilemap.IsoMap:screenToTile(sx, sy)
---@param sx any
---@param sy any
function IsoMap:screenToTile(sx, sy) end

--- luna.tilemap.IsoMap:setOrigin(x, y)
---@param x any
---@param y any
function IsoMap:setOrigin(x, y) end

--- luna.tilemap.IsoMap:tileToScreen(tx, ty, tz)
---@param tx any
---@param ty any
---@param tz any
function IsoMap:tileToScreen(tx, ty, tz) end

---@class MapBlock
local MapBlock = {}

--- luna.tilemap.MapBlock:getDimensions()
function MapBlock:getDimensions() end

--- Returns the height of this map block section in tile coordinates.
---@return number
function MapBlock:getHeight() end

--- luna.tilemap.MapBlock:getHeightInSegments()
function MapBlock:getHeightInSegments() end

--- luna.tilemap.MapBlock:getLayerCount()
function MapBlock:getLayerCount() end

--- Returns the name string assigned to this map block in the tile editor.
---@return string
function MapBlock:getName() end

--- luna.tilemap.MapBlock:getSegmentCount(edge)
---@param edge_str any
function MapBlock:getSegmentCount(edge_str) end

--- luna.tilemap.MapBlock:getSegmentSize()
function MapBlock:getSegmentSize() end

--- luna.tilemap.MapBlock:getSide(edge, segment)
---@param edge_str any
---@param segment any
function MapBlock:getSide(edge_str, segment) end

--- luna.tilemap.MapBlock:getTile(layer, x, y)
---@param layer any
---@param x any
---@param y any
function MapBlock:getTile(layer, x, y) end

--- Returns the numeric weight used by procedural generators when placing this block.
---@return number
function MapBlock:getWeight() end

--- Returns the width of this map block section in tile coordinates.
---@return number
function MapBlock:getWidth() end

--- luna.tilemap.MapBlock:getWidthInSegments()
function MapBlock:getWidthInSegments() end

--- luna.tilemap.MapBlock:setName(name)
---@param name any
function MapBlock:setName(name) end

--- luna.tilemap.MapBlock:setWeight(weight)
---@param weight any
function MapBlock:setWeight(weight) end

---@class MapGen
local MapGen = {}

--- Removes all zone definitions from this map generator's zone list.
function MapGen:clearZones() end

--- luna.tilemap.MapGen:getGridDimensions()
function MapGen:getGridDimensions() end

--- luna.tilemap.MapGen:getGridHeight()
function MapGen:getGridHeight() end

--- Returns the width of the generation grid in block-sized units.
---@return number
function MapGen:getGridWidth() end

--- Returns the layer stacking mode used by this generator.
---@return string
function MapGen:getLayerMode() end

--- luna.tilemap.MapGen:getOrientation()
function MapGen:getOrientation() end

--- luna.tilemap.MapGen:getPlacementCount()
function MapGen:getPlacementCount() end

--- luna.tilemap.MapGen:getSegmentSize()
function MapGen:getSegmentSize() end

--- luna.tilemap.MapGen:getTilePixelHeight()
function MapGen:getTilePixelHeight() end

--- luna.tilemap.MapGen:getTilePixelWidth()
function MapGen:getTilePixelWidth() end

--- Returns the zone definition table at the given 1-based index.
---@param index number ÔÇö 1-based index into the zone list.
---@return table
function MapGen:getZone(index) end

--- Returns the total number of zone definitions registered in this generator.
---@return number
function MapGen:getZoneCount() end

--- luna.tilemap.MapGen:setLayerMode(mode)
---@param mode any
function MapGen:setLayerMode(mode) end

--- luna.tilemap.MapGen:setOrientation(orientation)
---@param orientation any
function MapGen:setOrientation(orientation) end

--- luna.tilemap.MapGen:setTileSize(w, h)
---@param w any
---@param h any
function MapGen:setTileSize(w, h) end

---@class MapGroup
local MapGroup = {}

--- luna.tilemap.MapGroup:addBlock(block)
---@param block_ud any
function MapGroup:addBlock(block_ud) end

--- luna.tilemap.MapGroup:addScript(script)
---@param script_ud any
function MapGroup:addScript(script_ud) end

--- luna.tilemap.MapGroup:getBlock(index)
---@param index any
function MapGroup:getBlock(index) end

--- luna.tilemap.MapGroup:getBlockCount()
function MapGroup:getBlockCount() end

--- Returns the display name string of this map group layer.
---@return string
function MapGroup:getName() end

--- luna.tilemap.MapGroup:getScript(index)
---@param index any
function MapGroup:getScript(index) end

--- luna.tilemap.MapGroup:getScriptCount()
function MapGroup:getScriptCount() end

--- luna.tilemap.MapGroup:removeBlock(index)
---@param index any
function MapGroup:removeBlock(index) end

--- luna.tilemap.MapGroup:setName(name)
---@param name any
function MapGroup:setName(name) end

---@class MapScript
local MapScript = {}

--- luna.tilemap.MapScript:addStep(stepTable)
---@param step_table any
function MapScript:addStep(step_table) end

--- luna.tilemap.MapScript:clearSteps()
function MapScript:clearSteps() end

--- Returns the identifier name assigned to this map script component.
---@return string
function MapScript:getName() end

--- luna.tilemap.MapScript:getStep(index)
---@param index any
function MapScript:getStep(index) end

--- luna.tilemap.MapScript:getStepCount()
function MapScript:getStepCount() end

--- luna.tilemap.MapScript:removeStep(index)
---@param index any
function MapScript:removeStep(index) end

--- luna.tilemap.MapScript:setName(name)
---@param name any
function MapScript:setName(name) end

---@class TileMap
local TileMap = {}

--- luna.tilemap.TileMap:addTileSet(tileset)
---@param ts_ud any
function TileMap:addTileSet(ts_ud) end

--- luna.tilemap.TileMap:clearTile(layerIdx, x, y)
---@param layer any
---@param x any
---@param y any
function TileMap:clearTile(layer, x, y) end

--- luna.tilemap.TileMap:drawLayer(layerIdx)
---@param idx any
function TileMap:drawLayer(idx) end

--- luna.tilemap.TileMap:fill(layerIdx, gid)
---@param layer any
---@param gid any
function TileMap:fill(layer, gid) end

--- luna.tilemap.TileMap:getChunkSize()
function TileMap:getChunkSize() end

--- luna.tilemap.TileMap:getLayerColor(layerIdx)
---@param idx any
function TileMap:getLayerColor(idx) end

--- luna.tilemap.TileMap:getLayerCount()
function TileMap:getLayerCount() end

--- luna.tilemap.TileMap:getLayerName(layerIdx)
---@param idx any
function TileMap:getLayerName(idx) end

--- luna.tilemap.TileMap:getLayerOffset(layerIdx)
---@param idx any
function TileMap:getLayerOffset(idx) end

--- luna.tilemap.TileMap:getLayerParallax(layerIdx)
---@param idx any
function TileMap:getLayerParallax(idx) end

--- luna.tilemap.TileMap:getLayerVisible(layerIdx)
---@param idx any
function TileMap:getLayerVisible(idx) end

--- luna.tilemap.TileMap:getOrientation() -> "topdown"|"sideview"
function TileMap:getOrientation() end

--- luna.tilemap.TileMap:getTile(layerIdx, x, y)
---@param layer any
---@param x any
---@param y any
function TileMap:getTile(layer, x, y) end

--- luna.tilemap.TileMap:getTileDimensions()
function TileMap:getTileDimensions() end

--- Returns the height of a single tile in pixels.
---@return number
function TileMap:getTileHeight() end

--- luna.tilemap.TileMap:getTileSet(index)
---@param index any
function TileMap:getTileSet(index) end

--- luna.tilemap.TileMap:getTileSetCount()
function TileMap:getTileSetCount() end

--- Returns the width of a single tile in pixels.
---@return number
function TileMap:getTileWidth() end

--- Returns the visible tile range as x, y, width, height in tile coordinates.
---@return number
---@return number
function TileMap:getViewport() end

--- luna.tilemap.TileMap:isSolid(layerIdx, tx, ty)
---@param layer any
---@param tx any
---@param ty any
function TileMap:isSolid(layer, tx, ty) end

--- luna.tilemap.TileMap:setOrientation(mode)
---@param mode any
function TileMap:setOrientation(mode) end

--- luna.tilemap.TileMap:tileToWorld(tx, ty)
---@param tx any
---@param ty any
function TileMap:tileToWorld(tx, ty) end

--- Advances the map's animation timers and any attached script callbacks.
---@param dt any ÔÇö Delta time in seconds since the last update.
function TileMap:update(dt) end

--- luna.tilemap.TileMap:worldToTile(wx, wy)
---@param wx any
---@param wy any
function TileMap:worldToTile(wx, wy) end

---@class TileSet
local TileSet = {}

--- luna.tilemap.TileSet:getAnimation(tileId)
---@param tile_id any
function TileSet:getAnimation(tile_id) end

--- Returns the number of tile columns in this tileset's source image.
---@return number
function TileSet:getColumns() end

--- Returns the global tile ID (GID) assigned to the first tile in this tileset.
---@return number
function TileSet:getFirstGid() end

--- Returns the pixel margin around the outside edge of the tileset image.
---@return number
function TileSet:getMargin() end

--- luna.tilemap.TileSet:getQuad(tileId)
---@param tile_id any
function TileSet:getQuad(tile_id) end

--- Returns the pixel gap between adjacent tiles in the tileset source image.
---@return number
function TileSet:getSpacing() end

--- luna.tilemap.TileSet:getTileCount()
function TileSet:getTileCount() end

--- luna.tilemap.TileSet:getTileDimensions()
function TileSet:getTileDimensions() end

--- luna.tilemap.TileSet:getTileHeight()
function TileSet:getTileHeight() end

--- luna.tilemap.TileSet:getTileWidth()
function TileSet:getTileWidth() end

--- luna.tilemap.TileSet:isSolid(tileId)
---@param tile_id any
function TileSet:isSolid(tile_id) end

--- luna.tilemap.TileSet:setSolid(tileId, solid)
---@param tile_id any
---@param solid any
function TileSet:setSolid(tile_id, solid) end

--- luna.tilemap.fromScreenHex(sx, sy, size)
---@param sx any
---@param sy any
---@param size any
function luna.tilemap.fromScreenHex(sx, sy, size) end

--- luna.tilemap.fromScreenIso(sx, sy, tileW, tileH)
---@param sx any
---@param sy any
---@param tile_w any
---@param tile_h any
function luna.tilemap.fromScreenIso(sx, sy, tile_w, tile_h) end

--- Returns all hex cell coordinates within a given radius of center (q, r).
---@param q any ÔÇö Center q coordinate.
---@param r any ÔÇö Center r coordinate.
---@param radius number ÔÇö Radius in hex steps (1 = immediate ring, 2 = two rings, etc.).
---@return number
function luna.tilemap.hexArea(q, r, radius) end

--- luna.tilemap.hexDistance(q1, r1, q2, r2)
---@param q1 any
---@param r1 any
---@param q2 any
---@param r2 any
function luna.tilemap.hexDistance(q1, r1, q2, r2) end

--- luna.tilemap.hexLine(q1, r1, q2, r2)
---@param q1 any
---@param r1 any
---@param q2 any
---@param r2 any
function luna.tilemap.hexLine(q1, r1, q2, r2) end

--- Returns the six hex grid coordinates adjacent to the cell at (q, r).
---@param q number ÔÇö Integer q (column) coordinate of the center cell.
---@param r number ÔÇö Integer r (row) coordinate of the center cell.
---@return number
function luna.tilemap.hexNeighbors(q, r) end

--- luna.tilemap.hexReflect(q, r, centerQ, centerR, axis)
---@param q any
---@param r any
---@param center_q any
---@param center_r any
---@param axis any
function luna.tilemap.hexReflect(q, r, center_q, center_r, axis) end

--- Returns all hex cell coordinates forming the ring at exactly the given radius from (q, r).
---@param q any ÔÇö Center q coordinate.
---@param r any ÔÇö Center r coordinate.
---@param radius number ÔÇö Ring distance in hex steps.
---@return table
function luna.tilemap.hexRing(q, r, radius) end

--- luna.tilemap.hexRotate(q, r, centerQ, centerR, steps)
---@param q any
---@param r any
---@param center_q any
---@param center_r any
---@param steps any
function luna.tilemap.hexRotate(q, r, center_q, center_r, steps) end

--- Rounds fractional hex coordinates (q, r) to the nearest integer hex cell center.
---@param q any ÔÇö Fractional q (column) coordinate.
---@param r any ÔÇö Fractional r (row) coordinate.
---@return number
function luna.tilemap.hexRound(q, r) end

--- luna.tilemap.hexSpiral(q, r, radius)
---@param q any
---@param r any
---@param radius any
function luna.tilemap.hexSpiral(q, r, radius) end

--- luna.tilemap.isoDirectionFromAngle(angle)
---@param angle any
function luna.tilemap.isoDirectionFromAngle(angle) end

--- luna.tilemap.isoDirectionName(direction)
---@param direction any
function luna.tilemap.isoDirectionName(direction) end

--- luna.tilemap.isoRotate(direction, steps)
---@param direction any
---@param steps any
function luna.tilemap.isoRotate(direction, steps) end

--- luna.tilemap.loadTMX(xmlString) -> table with TmxMap fields, or nil+err
---@param xml any
function luna.tilemap.loadTMX(xml) end

--- luna.tilemap.newAutoTileSheet(tileW, tileH, layout)
---@param tile_w any
---@param tile_h any
---@param layout_str any
function luna.tilemap.newAutoTileSheet(tile_w, tile_h, layout_str) end

--- luna.tilemap.newChunkMap(chunkSize) -> ChunkMap
---@param chunk_size? any (optional)
function luna.tilemap.newChunkMap(chunk_size) end

--- luna.tilemap.newIsoMap(width, height, tileW, tileH, levelHeight)
---@param width any
---@param height any
---@param tile_w any
---@param tile_h any
---@param level_height any
function luna.tilemap.newIsoMap(width, height, tile_w, tile_h, level_height) end

--- luna.tilemap.newMapBlock(width, height, layers, segmentSize)
---@param width any
---@param height any
---@param layers any
---@param segment_size any
function luna.tilemap.newMapBlock(width, height, layers, segment_size) end

--- luna.tilemap.newMapGen(group, sizeOrW, hOrSegSize, segSize)
function luna.tilemap.newMapGen() end

--- Creates a named group layer for organizing child layers inside a tile map.
---@param name number ÔÇö Display name for the group layer.
---@return number
function luna.tilemap.newMapGroup(name) end

--- Creates a script object attached to a tile map layer for custom logic.
---@param name number ÔÇö Identifier name for the script component.
---@return any
function luna.tilemap.newMapScript(name) end

--- luna.tilemap.newTileMap(tileW, tileH, chunkSize)
---@param tile_w any
---@param tile_h any
---@param chunk_size? any (optional)
function luna.tilemap.newTileMap(tile_w, tile_h, chunk_size) end

--- luna.tilemap.newTileSet(firstGid, tileCount, columns, tileW, tileH, spacing, margin)
function luna.tilemap.newTileSet() end

--- luna.tilemap.toScreenHex(q, r, size)
---@param q any
---@param r any
---@param size any
function luna.tilemap.toScreenHex(q, r, size) end

--- luna.tilemap.toScreenIso(tx, ty, tileW, tileH)
---@param tx any
---@param ty any
---@param tile_w any
---@param tile_h any
function luna.tilemap.toScreenIso(tx, ty, tile_w, tile_h) end

---@class luna.timer
luna.timer = {}

---@class mlua
local mlua = {}

--- Calls a Lua function after the given delay in seconds.
---@param delay any
---@param func any
---@return any
function mlua:after(delay, func) end

--- Cancels a scheduled timer callback.
---@param id any
---@return any
function mlua:cancel(id) end

--- Cancels and removes every pending timer entry from this scheduler.
---@return any
function mlua:cancelAll() end

--- Cancels a specific named timer that was scheduled on this scheduler.
---@param name string Name string used when the timer was created.
---@return boolean
function mlua:cancelNamed(name) end

--- Returns the number of active timer entries currently in the scheduler.
---@return number
function mlua:getCount() end

--- Returns the repeat interval of the given timer entry in seconds.
---@param id number Timer ID returned when the timer was created.
---@return number
function mlua:getInterval(id) end

--- Returns the time remaining before the next invocation of the given timer.
---@param id number Timer ID returned when the timer was created.
---@return any
function mlua:getRemaining(id) end

--- Returns how many times the given timer has fired since it was created.
---@param id number Timer ID.
---@return number
function mlua:getRepeatCount(id) end

--- Returns the current time-scale factor applied to all timers in this scheduler.
---@return number
function mlua:getTimeScale() end

--- Returns whether the scheduler has no active timer entries.
---@return number
function mlua:isEmpty() end

--- Returns whether the scheduler is currently paused and not advancing timers.
---@param id any
---@return boolean
function mlua:isPaused(id) end

--- Pauses the scheduler so no pending callbacks fire until resumed.
---@param id any
---@return any
function mlua:pause(id) end

--- Resets the elapsed time of the given timer so it fires again after its full interval.
---@param id number Timer ID to reset.
---@return any
function mlua:resetEvent(id) end

--- Resumes a paused scheduler, allowing its callbacks to fire again.
---@param id any
---@return any
function mlua:resume(id) end

--- Changes the repeat interval of an existing timer without recreating it.
---@param id number Timer ID.
---@param interval number New interval in seconds.
---@return any
function mlua:setInterval(id, interval) end

--- Sets a time-scale factor that speeds up or slows down all timers in the scheduler.
---@param scale any Time multiplier (1.0 = real time, 2.0 = double speed).
function mlua:setTimeScale(scale) end

--- Advances all pending timers by dt seconds.
---@param dt any
---@return any
function mlua:update(dt) end

--- Returns the rolling-average frame delta time in seconds.
---@return any
function luna.timer.getAverageDelta() end

--- Returns the delta time (seconds) for the current frame.
---@return any
function luna.timer.getDelta() end

--- Returns the measured frames-per-second for the current frame.
---@return any
function luna.timer.getFPS() end

--- Returns the high-resolution monotonic timer value in microseconds.
---@return number
function luna.timer.getMicroTime() end

--- Returns the total elapsed time in seconds since engine start.
---@return any
function luna.timer.getTime() end

--- Creates an independent timer scheduler for managing a set of callbacks.
---@return number
function luna.timer.newScheduler() end

--- Suspends execution for the given number of seconds.
---@param seconds any
function luna.timer.sleep(seconds) end

--- Advances the timer by one step (called automatically each frame).
---@return any
function luna.timer.step() end

---@class luna.window
luna.window = {}

--- Requests the application to close the window.
function luna.window.close() end

--- Requests the window manager to bring the window to the foreground.
function luna.window.focus() end

--- Converts physical pixels to device-independent coordinates.
---@param value any
---@return any
function luna.window.fromPixels(value) end

--- Returns the DPI scaling factor for the window.
---@return any
function luna.window.getDPIScale() end

--- Returns the desktop resolution (width, height) for the given display.
---@return any
function luna.window.getDesktopDimensions() end

--- Returns the window dimensions (width, height).
---@return any
function luna.window.getDimensions() end

--- Returns the number of connected displays.
---@return any
function luna.window.getDisplayCount() end

--- Returns the name of the given display.
---@param display? any (optional)
---@return any
function luna.window.getDisplayName(display) end

--- Returns the current display orientation as a string.
---@return string
function luna.window.getDisplayOrientation() end

--- Returns the current fullscreen type string, or nil if windowed.
---@return any
function luna.window.getFullscreen() end

--- Returns all available fullscreen video modes.
---@return any
function luna.window.getFullscreenModes() end

--- Returns the game's logical height in virtual pixels.
---@return number
function luna.window.getGameHeight() end

--- Returns the game's logical width in virtual pixels.
---@return number
function luna.window.getGameWidth() end

--- Returns the window height in pixels.
---@return any
function luna.window.getHeight() end

--- Returns the current window mode settings as a table.
---@return any
function luna.window.getMode() end

--- Returns the display's native DPI scale factor.
---@return number
function luna.window.getNativeDPIScale() end

--- Returns the window dimensions in physical pixels (for HiDPI).
---@return any
function luna.window.getPixelDimensions() end

--- Returns the window position (x, y) on the desktop.
---@return any
function luna.window.getPosition() end

--- Returns the safe display area in logical pixels as `x, y, w, h`.
---@return number
function luna.window.getSafeArea() end

--- Returns the current viewport scale and offset information as a table.
---@return number
function luna.window.getScaleInfo() end

--- Returns the current viewport scale mode string.
---@return string
function luna.window.getScaleMode() end

--- Returns the operating-system color theme preference.
---@return string
function luna.window.getSystemTheme() end

--- Returns the current text displayed in the operating-system window title bar.
---@return string
function luna.window.getTitle() end

--- Returns the current VSync mode value.
function luna.window.getVSync() end

--- Returns the window width in pixels.
---@return any
function luna.window.getWidth() end

--- Returns whether the window has keyboard input focus.
function luna.window.hasFocus() end

--- Returns whether the mouse cursor is inside the window.
function luna.window.hasMouseFocus() end

--- Returns whether the window is currently in fullscreen mode.
---@return boolean
function luna.window.isFullscreen() end

--- Returns whether high-DPI rendering is allowed for this window.
---@return boolean
function luna.window.isHighDPIAllowed() end

--- Returns whether the window is maximized.
function luna.window.isMaximized() end

--- Returns whether the window is minimized.
function luna.window.isMinimized() end

--- Returns whether the window has been created and is not yet closed.
---@return boolean
function luna.window.isOpen() end

--- Returns whether the window can be resized by the user.
---@return boolean
function luna.window.isResizable() end

--- Returns whether the window is currently visible.
function luna.window.isVisible() end

--- Maximizes the window so it fills all available desktop space.
function luna.window.maximize() end

--- Minimizes the window to the OS taskbar or dock.
function luna.window.minimize() end

--- Flashes the window in the taskbar to request user attention.
function luna.window.requestAttention() end

--- Restores the window from maximized or minimized state.
function luna.window.restore() end

--- Enables or disables fullscreen mode.
---@param enabled any
---@param fstype? any (optional)
function luna.window.setFullscreen(enabled, fstype) end

--- Sets the window icon from a pixel buffer.
---@param path any
function luna.window.setIcon(path) end

--- Resizes the window and optionally changes fullscreen mode.
---@param w any
---@param h any
---@param flags? any (optional)
function luna.window.setMode(w, h, flags) end

--- Moves the window to the given desktop position.
---@param x any
---@param y any
function luna.window.setPosition(x, y) end

--- Sets the viewport scale mode.
---@param mode string Scale mode: `"none"`, `"letterbox"`, `"stretch"`, or `"pixel"`.
function luna.window.setScaleMode(mode) end

--- Sets the text displayed in the window's title bar.
---@param title string New title string to display.
function luna.window.setTitle(title) end

--- Enables or disables vertical synchronization.
---@param mode any
function luna.window.setVSync(mode) end

--- Shows a platform native message box dialog.
---@return string
function luna.window.showMessageBox() end

--- Converts a device-independent coordinate to physical pixels.
---@param value any
---@return any
function luna.window.toPixels(value) end
