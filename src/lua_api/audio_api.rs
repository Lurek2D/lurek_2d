//! File: src/lua_api/audio_api.rs

use super::SharedState;
use crate::audio::sound_data::SoundData;
use crate::audio::{BeatClockOpts, Decoder, JudgementResult, JudgementWindows, SourceType};
use crate::log_msg;
use crate::midi::MidiPlayer;
use crate::runtime::log_messages::LA01_API_STUB;
use crate::runtime::resource_keys::{BusKey, QueueableKey, SoundKey};
use mlua::prelude::*;
use slotmap::Key;
use std::cell::RefCell;
use std::rc::Rc;
use std::sync::{Mutex, OnceLock};

static BEAT_CLOCK_WINDOWS: OnceLock<Mutex<JudgementWindows>> = OnceLock::new();

fn default_beat_windows() -> &'static Mutex<JudgementWindows> {
    BEAT_CLOCK_WINDOWS.get_or_init(|| Mutex::new(JudgementWindows::default()))
}
/// Resolves a Lua audio source handle or raw numeric identifier into the internal sound key.
fn sound_key_from_value(val: &LuaValue) -> LuaResult<SoundKey> {
    match val {
        LuaValue::UserData(ud) => {
            let src = ud.borrow::<LuaSource>()?;
            Ok(src.key)
        }
        LuaValue::Integer(id) => Ok(SoundKey::from(slotmap::KeyData::from_ffi(*id as u64))),
        LuaValue::Number(id) => Ok(SoundKey::from(slotmap::KeyData::from_ffi(*id as u64))),
        _ => Err(LuaError::RuntimeError(
            "Expected Source or source id".into(),
        )),
    }
}
/// Creates a consistent stale-handle runtime error for audio source methods.
fn invalid_source_handle(function_name: &str) -> LuaError {
    LuaError::RuntimeError(format!(
        "{}: invalid or already-released audio source handle",
        function_name
    ))
}
/// Verifies that a sound key still exists in the mixer before a Lua method uses it.
fn ensure_source_exists(
    mixer: &crate::audio::Mixer,
    key: SoundKey,
    function_name: &str,
) -> LuaResult<SoundKey> {
    if mixer.contains_source(key) {
        Ok(key)
    } else {
        Err(invalid_source_handle(function_name))
    }
}
/// Resolves a Lua value to a live sound key by combining handle parsing with mixer existence checks.
fn require_sound_key(
    state: &SharedState,
    val: &LuaValue,
    function_name: &str,
) -> LuaResult<SoundKey> {
    let key = sound_key_from_value(val)?;
    ensure_source_exists(&state.mixer, key, function_name)
}
/// Converts a raw FFI-stable integer handle into a queueable audio key.
fn queueable_key_from_u64(raw: u64) -> QueueableKey {
    QueueableKey::from(slotmap::KeyData::from_ffi(raw))
}
/// Parses `newSoundData` arguments into either a file path or generated buffer shape.
fn extract_sound_data_args(args: LuaMultiValue) -> LuaResult<(Option<String>, usize, u32, u16)> {
    let mut it = args.into_iter();
    let first = it
        .next()
        .ok_or_else(|| LuaError::RuntimeError("newSoundData: expected argument".into()))?;
    let (path, count) = match first {
        LuaValue::String(s) => (
            Some(
                s.to_str()
                    .map_err(|e| LuaError::RuntimeError(e.to_string()))?
                    .to_string(),
            ),
            0usize,
        ),
        LuaValue::Integer(n) => (None, n as usize),
        LuaValue::Number(n) => (None, n as usize),
        _ => {
            return Err(LuaError::RuntimeError(
                "newSoundData expects a filename or sample count".into(),
            ))
        }
    };
    let rate = match it.next() {
        Some(LuaValue::Integer(n)) => n as u32,
        Some(LuaValue::Number(n)) => n as u32,
        _ => {
            return Err(LuaError::RuntimeError(
                "newSoundData: sample rate must be a number (e.g. 44100, 48000)".into(),
            ))
        }
    };
    let channels = match it.next() {
        Some(LuaValue::Integer(n)) => n as u16,
        Some(LuaValue::Number(n)) => n as u16,
        _ => 1,
    };
    Ok((path, count, rate, channels))
}

fn parse_beat_clock_opts(opts: Option<LuaTable>) -> LuaResult<BeatClockOpts> {
    let mut parsed = BeatClockOpts::default();
    if let Some(table) = opts {
        if let Ok(subdivision) = table.get::<_, u32>("subdivision") {
            parsed.subdivision = subdivision.max(1);
        }
        if let Ok(swing) = table.get::<_, f64>("swing") {
            parsed.swing = swing;
        }
        if let Ok(latency_ms) = table.get::<_, f64>("latency_ms") {
            parsed.latency = (latency_ms.max(0.0)) / 1000.0;
        }
    }
    Ok(parsed)
}

fn parse_new_beat_clock_args(args: LuaMultiValue) -> LuaResult<(f64, u32, BeatClockOpts)> {
    let mut it = args.into_iter();
    let bpm = match it.next() {
        Some(LuaValue::Integer(v)) => v as f64,
        Some(LuaValue::Number(v)) => v,
        _ => {
            return Err(LuaError::RuntimeError(
                "newBeatClock: bpm must be a number".into(),
            ))
        }
    };

    let second = it.next();
    let third = it.next();

    let mut beats_per_bar = 4u32;
    let opts = match second {
        Some(LuaValue::Integer(v)) => {
            beats_per_bar = (v as u32).max(1);
            match third {
                Some(LuaValue::Table(t)) => parse_beat_clock_opts(Some(t))?,
                None => BeatClockOpts::default(),
                _ => {
                    return Err(LuaError::RuntimeError(
                        "newBeatClock: third argument must be an options table".into(),
                    ))
                }
            }
        }
        Some(LuaValue::Number(v)) => {
            beats_per_bar = (v as u32).max(1);
            match third {
                Some(LuaValue::Table(t)) => parse_beat_clock_opts(Some(t))?,
                None => BeatClockOpts::default(),
                _ => {
                    return Err(LuaError::RuntimeError(
                        "newBeatClock: third argument must be an options table".into(),
                    ))
                }
            }
        }
        Some(LuaValue::Table(t)) => {
            let mut parsed = parse_beat_clock_opts(Some(t))?;
            if let Some(LuaValue::Table(t3)) = third {
                let override_opts = parse_beat_clock_opts(Some(t3))?;
                parsed = override_opts;
            }
            parsed
        }
        None => BeatClockOpts::default(),
        _ => {
            return Err(LuaError::RuntimeError(
                "newBeatClock: second argument must be beats-per-bar or options table".into(),
            ))
        }
    };

    Ok((bpm, beats_per_bar, opts))
}

fn helper_new_source(s: Rc<RefCell<SharedState>>, args: LuaMultiValue) -> LuaResult<LuaSource> {
    let path: String = args
        .get(0)
        .and_then(|value| match value {
            LuaValue::String(lua_string) => Some(lua_string.to_str().ok()?.to_string()),
            _ => None,
        })
        .ok_or_else(|| LuaError::RuntimeError("lurek.audio.newSource: path required".into()))?;
    let source_type = args
        .get(1)
        .and_then(|value| match value {
            LuaValue::String(lua_string) => Some(lua_string.to_str().ok()?.to_string()),
            _ => None,
        })
        .map(|source_type| match source_type.as_str() {
            "static" => SourceType::Static,
            _ => SourceType::Stream,
        })
        .unwrap_or(SourceType::Stream);
    let mut state = s.borrow_mut();
    let key = state.mixer.load_source(&path, source_type);
    Ok(LuaSource {
        state: s.clone(),
        key,
    })
}

fn helper_play(
    s: Rc<RefCell<SharedState>>,
    id_val: LuaValue,
    options: Option<LuaTable>,
) -> LuaResult<u64> {
    let mut state = s.borrow_mut();
    let key = require_sound_key(&state, &id_val, "lurek.audio.play")?;
    if let Some(options) = options {
        if let Ok(bus_name) = options.get::<_, String>("bus") {
            if let Some(bus) = state.mixer.get_bus_by_name(&bus_name) {
                state.mixer.set_source_bus(key, Some(bus));
            } else {
                return Err(LuaError::external("bus not found"));
            }
        }
    }
    let game_dir = state.game_dir.clone();
    state.mixer.play(key, &game_dir);
    Ok(key.data().as_ffi())
}

fn helper_get_source_type(s: Rc<RefCell<SharedState>>, id_val: LuaValue) -> LuaResult<String> {
    let key = sound_key_from_value(&id_val)?;
    let state = s.borrow();
    match state.mixer.get_source_type(key) {
        Some(SourceType::Static) => Ok("static".to_string()),
        Some(SourceType::Stream) => Ok("stream".to_string()),
        None => Err(LuaError::RuntimeError(
            "lurek.audio.getSourceType: invalid source handle".into(),
        )),
    }
}

fn helper_clone(s: Rc<RefCell<SharedState>>, id_val: LuaValue) -> LuaResult<LuaSource> {
    let key = sound_key_from_value(&id_val)?;
    let mut state = s.borrow_mut();
    match state.mixer.clone_source(key) {
        Some(new_key) => Ok(LuaSource {
            state: s.clone(),
            key: new_key,
        }),
        None => Err(LuaError::RuntimeError(
            "lurek.audio.clone: invalid source handle".into(),
        )),
    }
}

fn helper_release(s: Rc<RefCell<SharedState>>, id_val: LuaValue) -> LuaResult<bool> {
    let key = sound_key_from_value(&id_val)?;
    let mut state = s.borrow_mut();
    if state.mixer.release(key) {
        Ok(true)
    } else {
        Err(LuaError::RuntimeError(
            "lurek.audio.release: invalid or already-released audio source handle".into(),
        ))
    }
}

fn helper_set_source_bus(
    s: Rc<RefCell<SharedState>>,
    id_val: LuaValue,
    bus_val: LuaValue,
) -> LuaResult<()> {
    let key = sound_key_from_value(&id_val)?;
    let bus_key = match &bus_val {
        LuaValue::UserData(userdata) => {
            let bus = userdata.borrow::<LuaBus>()?;
            Some(bus.key)
        }
        _ => {
            return Err(LuaError::RuntimeError(
                "lurek.audio.setSourceBus: expected Bus userdata".into(),
            ));
        }
    };
    s.borrow_mut().mixer.set_source_bus(key, bus_key);
    Ok(())
}

fn helper_get_source_bus(
    s: Rc<RefCell<SharedState>>,
    id_val: LuaValue,
) -> LuaResult<Option<LuaBus>> {
    let key = sound_key_from_value(&id_val)?;
    let state = s.borrow();
    match state.mixer.get_source_bus(key) {
        Some(bus_key) => Ok(Some(LuaBus {
            state: s.clone(),
            key: bus_key,
        })),
        None => Ok(None),
    }
}

fn helper_new_midi_player(
    s: Rc<RefCell<SharedState>>,
    path: Option<String>,
) -> LuaResult<LuaMidiPlayer> {
    let midi_player = MidiPlayer::new();
    let inner = Rc::new(RefCell::new(midi_player));
    let result = LuaMidiPlayer {
        inner: inner.clone(),
        state: s.clone(),
    };
    if let Some(path) = path {
        let state = s.borrow();
        let full_path = state.game_dir.join(&path);
        drop(state);
        inner.borrow_mut().load(&full_path);
    }
    Ok(result)
}

fn helper_get_playback_devices<'lua>(lua: &'lua Lua) -> LuaResult<LuaTable<'lua>> {
    let devices = crate::audio::get_playback_devices();
    let table = lua.create_table()?;
    for (index, name) in devices.into_iter().enumerate() {
        table.set(index + 1, name)?;
    }
    Ok(table)
}

fn helper_create_bus(
    s: Rc<RefCell<SharedState>>,
    (name, parent_name): (String, Option<String>),
) -> LuaResult<()> {
    if name.is_empty() {
        return Err(LuaError::external("invalid bus name"));
    }
    let mut state = s.borrow_mut();
    let _parent_key = parent_name.and_then(|parent| state.mixer.get_bus_by_name(&parent));
    let _bus_key = state.mixer.new_bus(&name);
    Ok(())
}

fn helper_set_bus_volume(
    s: Rc<RefCell<SharedState>>,
    (name, volume): (String, f32),
) -> LuaResult<()> {
    let mut state = s.borrow_mut();
    if let Some(bus_key) = state.mixer.get_bus_by_name(&name) {
        if let Some(bus) = state.mixer.get_bus_mut(bus_key) {
            bus.set_volume(volume);
            return Ok(());
        }
    }
    Err(LuaError::external("bus not found"))
}

fn helper_mix_into((dest_ud, src_ud): (LuaAnyUserData, LuaAnyUserData)) -> LuaResult<()> {
    let src_samples: Vec<f32> = {
        let source = src_ud
            .borrow::<SoundData>()
            .map_err(|_| LuaError::RuntimeError("src must be a SoundData".into()))?;
        source.samples().to_vec()
    };
    let src_data = {
        let source = src_ud
            .borrow::<SoundData>()
            .map_err(|_| LuaError::RuntimeError("src must be a SoundData".into()))?;
        SoundData::from_samples(src_samples, source.sample_rate(), source.channel_count())
    };
    let mut destination = dest_ud
        .borrow_mut::<SoundData>()
        .map_err(|_| LuaError::RuntimeError("dest must be a SoundData".into()))?;
    destination.mix_into(&src_data);
    Ok(())
}

fn helper_save_wav(
    s: Rc<RefCell<SharedState>>,
    (sd_ud, filename): (LuaAnyUserData, String),
) -> LuaResult<()> {
    let path = s.borrow().game_dir.join(&filename);
    let sound_data = sd_ud
        .borrow::<SoundData>()
        .map_err(|_| LuaError::RuntimeError("argument must be a SoundData".into()))?;
    let bytes = sound_data.encode_wav();
    if let Some(parent) = path.parent() {
        std::fs::create_dir_all(parent).map_err(LuaError::external)?;
    }
    std::fs::write(&path, &bytes).map_err(LuaError::external)
}

fn helper_crossfade(
    s: Rc<RefCell<SharedState>>,
    (from_ud, to_ud, duration): (LuaAnyUserData, LuaAnyUserData, f32),
) -> LuaResult<()> {
    let from_key = from_ud
        .borrow::<LuaSource>()
        .map_err(|_| LuaError::RuntimeError("from must be an AudioSource".into()))?
        .key;
    let to_key = to_ud
        .borrow::<LuaSource>()
        .map_err(|_| LuaError::RuntimeError("to must be an AudioSource".into()))?
        .key;
    let game_dir = s.borrow().game_dir.clone();
    s.borrow_mut()
        .mixer
        .crossfade(from_key, to_key, duration, &game_dir);
    Ok(())
}

/// Lua-side wrapper around a loaded audio source (sound effect or music stream).
#[derive(Clone)]
pub struct LuaSource {
    pub(crate) state: Rc<RefCell<SharedState>>,
    pub(crate) key: SoundKey,
}
impl LuaUserData for LuaSource {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- play --
        /// Starts playback of this audio source from the current position.
        methods.add_method("play", |_, this, ()| {
            let mut st = this.state.borrow_mut();
            let key = ensure_source_exists(&st.mixer, this.key, "Source:play")?;
            let game_dir = st.game_dir.clone();
            st.mixer.play(key, &game_dir);
            Ok(())
        });
        // -- stop --
        /// Stops playback and resets the source position to the beginning.
        methods.add_method("stop", |_, this, ()| {
            let mut st = this.state.borrow_mut();
            let key = ensure_source_exists(&st.mixer, this.key, "Source:stop")?;
            st.mixer.stop(key);
            Ok(())
        });
        // -- pause --
        /// Pauses playback at the current position, allowing later resumption.
        methods.add_method("pause", |_, this, ()| {
            let mut st = this.state.borrow_mut();
            let key = ensure_source_exists(&st.mixer, this.key, "Source:pause")?;
            st.mixer.pause(key);
            Ok(())
        });
        // -- resume --
        /// Resumes playback from the position where the source was paused.
        methods.add_method("resume", |_, this, ()| {
            let mut st = this.state.borrow_mut();
            let key = ensure_source_exists(&st.mixer, this.key, "Source:resume")?;
            st.mixer.resume(key);
            Ok(())
        });
        // -- setVolume --
        /// Sets the volume level of this source where 0.0 is silent and 1.0 is full volume.
        /// @param | vol | number | Volume multiplier (0.0 = silent, 1.0 = normal, >1.0 = amplified).
        methods.add_method("setVolume", |_, this, vol: f32| {
            let mut st = this.state.borrow_mut();
            let key = ensure_source_exists(&st.mixer, this.key, "Source:setVolume")?;
            st.mixer.set_volume(key, vol);
            Ok(())
        });
        // -- getVolume --
        /// Returns the current volume level of this audio source.
        /// @return | number | Current volume multiplier.
        methods.add_method("getVolume", |_, this, ()| {
            let st = this.state.borrow();
            let key = ensure_source_exists(&st.mixer, this.key, "Source:getVolume")?;
            Ok(st.mixer.get_volume(key))
        });
        // -- setPitch --
        /// Sets the playback speed multiplier, affecting both pitch and duration.
        /// @param | pitch | number | Pitch multiplier (1.0 = normal, 2.0 = double speed/octave up).
        methods.add_method("setPitch", |_, this, pitch: f32| {
            let mut st = this.state.borrow_mut();
            let key = ensure_source_exists(&st.mixer, this.key, "Source:setPitch")?;
            st.mixer.set_pitch(key, pitch);
            Ok(())
        });
        // -- getPitch --
        /// Returns the current pitch multiplier of this audio source.
        /// @return | number | Current pitch multiplier.
        methods.add_method("getPitch", |_, this, ()| {
            let st = this.state.borrow();
            let key = ensure_source_exists(&st.mixer, this.key, "Source:getPitch")?;
            Ok(st.mixer.get_pitch(key))
        });
        // -- setLooping --
        /// Enables or disables looping so the source restarts automatically after finishing.
        /// @param | looping | boolean | True to loop continuously, false to play once.
        methods.add_method("setLooping", |_, this, looping: bool| {
            let mut st = this.state.borrow_mut();
            let key = ensure_source_exists(&st.mixer, this.key, "Source:setLooping")?;
            st.mixer.set_looping(key, looping);
            Ok(())
        });
        // -- isLooping --
        /// Returns whether this source is set to loop continuously.
        /// @return | boolean | True if looping is enabled.
        methods.add_method("isLooping", |_, this, ()| {
            let st = this.state.borrow();
            let key = ensure_source_exists(&st.mixer, this.key, "Source:isLooping")?;
            Ok(st.mixer.is_looping(key))
        });
        // -- isPlaying --
        /// Returns whether this source is currently playing audio.
        /// @return | boolean | True if the source is actively playing.
        methods.add_method("isPlaying", |_, this, ()| {
            let st = this.state.borrow();
            let key = ensure_source_exists(&st.mixer, this.key, "Source:isPlaying")?;
            Ok(st.mixer.is_playing(key))
        });
        // -- isPaused --
        /// Returns whether this source is currently paused.
        /// @return | boolean | True if the source is paused.
        methods.add_method("isPaused", |_, this, ()| {
            let st = this.state.borrow();
            let key = ensure_source_exists(&st.mixer, this.key, "Source:isPaused")?;
            Ok(st.mixer.is_paused(key))
        });
        // -- isStopped --
        /// Returns whether this source is currently stopped (not playing or paused).
        /// @return | boolean | True if the source is stopped.
        methods.add_method("isStopped", |_, this, ()| {
            let st = this.state.borrow();
            let key = ensure_source_exists(&st.mixer, this.key, "Source:isStopped")?;
            Ok(st.mixer.is_stopped(key))
        });
        // -- setPan --
        /// Sets the stereo panning position of this source.
        /// @param | pan | number | Pan value from -1.0 (full left) to 1.0 (full right), 0.0 is center.
        methods.add_method("setPan", |_, this, pan: f32| {
            let mut st = this.state.borrow_mut();
            let key = ensure_source_exists(&st.mixer, this.key, "Source:setPan")?;
            st.mixer.set_pan(key, pan);
            Ok(())
        });
        // -- getPan --
        /// Returns the current stereo panning position of this source.
        /// @return | number | Pan value from -1.0 (left) to 1.0 (right).
        methods.add_method("getPan", |_, this, ()| {
            let st = this.state.borrow();
            let key = ensure_source_exists(&st.mixer, this.key, "Source:getPan")?;
            Ok(st.mixer.get_pan(key))
        });
        // -- clone --
        /// Creates an independent copy of this source sharing the same audio data.
        /// @return | LSource | A new source instance with identical settings.
        methods.add_method("clone", |_, this, ()| {
            let mut st = this.state.borrow_mut();
            match st.mixer.clone_source(this.key) {
                Some(new_key) => Ok(LuaSource {
                    state: this.state.clone(),
                    key: new_key,
                }),
                None => Err(invalid_source_handle("Source:clone")),
            }
        });
        // -- getType --
        /// Returns whether this source was loaded as static (fully in memory) or streaming.
        /// @return | string | Either "static" or "stream".
        methods.add_method("getType", |_, this, ()| {
            let st = this.state.borrow();
            match st.mixer.get_source_type(this.key) {
                Some(SourceType::Static) => Ok("static"),
                Some(SourceType::Stream) => Ok("stream"),
                None => Err(invalid_source_handle("Source:getType")),
            }
        });
        // -- getDuration --
        /// Returns the total duration of this audio source in seconds.
        /// @return | number | Duration in seconds.
        methods.add_method("getDuration", |_, this, ()| {
            let st = this.state.borrow();
            let key = ensure_source_exists(&st.mixer, this.key, "Source:getDuration")?;
            Ok(st.mixer.get_duration(key))
        });
        // -- tell --
        /// Returns the current playback position of this source in seconds.
        /// @return | number | Current position in seconds from the start.
        methods.add_method("tell", |_, this, ()| {
            let st = this.state.borrow();
            let key = ensure_source_exists(&st.mixer, this.key, "Source:tell")?;
            Ok(st.mixer.get_tell(key))
        });
        // -- seek --
        /// Seeks to a specific position in seconds within this audio source.
        /// @param | pos | number | Target position in seconds.
        methods.add_method("seek", |_, this, pos: f32| {
            let mut st = this.state.borrow_mut();
            let key = ensure_source_exists(&st.mixer, this.key, "Source:seek")?;
            let game_dir = st.game_dir.clone();
            st.mixer.seek(key, pos, &game_dir);
            Ok(())
        });
        // -- setLowpass --
        /// Applies a lowpass filter that attenuates frequencies above the cutoff.
        /// @param | cutoff_hz | integer | Cutoff frequency in Hertz.
        methods.add_method("setLowpass", |_, this, cutoff_hz: u32| {
            let mut st = this.state.borrow_mut();
            let key = ensure_source_exists(&st.mixer, this.key, "Source:setLowpass")?;
            st.mixer.set_lowpass(key, cutoff_hz);
            Ok(())
        });
        // -- setHighpass --
        /// Applies a highpass filter that attenuates frequencies below the cutoff.
        /// @param | cutoff_hz | integer | Cutoff frequency in Hertz.
        methods.add_method("setHighpass", |_, this, cutoff_hz: u32| {
            let mut st = this.state.borrow_mut();
            let key = ensure_source_exists(&st.mixer, this.key, "Source:setHighpass")?;
            st.mixer.set_highpass(key, cutoff_hz);
            Ok(())
        });
        // -- getLowpass --
        /// Returns the current lowpass filter cutoff frequency in Hertz.
        /// @return | integer | Cutoff frequency in Hz, or 0 if no lowpass is set.
        methods.add_method("getLowpass", |_, this, ()| {
            let st = this.state.borrow();
            let key = ensure_source_exists(&st.mixer, this.key, "Source:getLowpass")?;
            Ok(st.mixer.get_lowpass(key))
        });
        // -- getHighpass --
        /// Returns the current highpass filter cutoff frequency in Hertz.
        /// @return | integer | Cutoff frequency in Hz, or 0 if no highpass is set.
        methods.add_method("getHighpass", |_, this, ()| {
            let st = this.state.borrow();
            let key = ensure_source_exists(&st.mixer, this.key, "Source:getHighpass")?;
            Ok(st.mixer.get_highpass(key))
        });
        // -- clearFilter --
        /// Removes all frequency filters (lowpass and highpass) from this source.
        methods.add_method("clearFilter", |_, this, ()| {
            let mut st = this.state.borrow_mut();
            let key = ensure_source_exists(&st.mixer, this.key, "Source:clearFilter")?;
            st.mixer.clear_filter(key);
            Ok(())
        });
        // -- fadeIn --
        /// Sets the fade-in duration so the source ramps from silence to full volume on play.
        /// @param | dur | number | Fade-in duration in seconds.
        methods.add_method("fadeIn", |_, this, dur: f32| {
            let mut st = this.state.borrow_mut();
            let key = ensure_source_exists(&st.mixer, this.key, "Source:fadeIn")?;
            st.mixer.set_fade_in(key, dur);
            Ok(())
        });
        // -- getFadeIn --
        /// Returns the configured fade-in duration for this source.
        /// @return | number | Fade-in duration in seconds.
        methods.add_method("getFadeIn", |_, this, ()| {
            let st = this.state.borrow();
            let key = ensure_source_exists(&st.mixer, this.key, "Source:getFadeIn")?;
            Ok(st.mixer.get_fade_in(key))
        });
        // -- type --
        /// Returns the type name of this object for runtime type-checking.
        /// @return | string | Always returns "LSource".
        methods.add_method("type", |_, _, ()| Ok("LSource"));
        // -- typeOf --
        /// Checks whether this object is of the given type name or a parent type.
        /// @param | name | string | Type name to check (e.g. "LSource" or "Object").
        /// @return | boolean | True if this object matches the given type.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LSource" || name == "LObject")
        });
    }
}
/// Lua-side wrapper around an audio mixing bus for grouped volume and effect control.
#[derive(Clone)]
pub struct LuaBus {
    pub(crate) state: Rc<RefCell<SharedState>>,
    pub(crate) key: BusKey,
}
impl LuaUserData for LuaBus {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getName --
        /// Returns the name of this audio bus. This method is available to Lua scripts.
        /// @return | string | Bus name as registered during creation.
        methods.add_method("getName", |_, this, ()| {
            let st = this.state.borrow();
            match st.mixer.get_bus(this.key) {
                Some(bus) => Ok(bus.name().to_string()),
                None => Err(LuaError::RuntimeError(
                    "Bus:getName(): invalid bus handle".into(),
                )),
            }
        });
        // -- setVolume --
        /// Sets the volume multiplier for all sources routed through this bus.
        /// @param | vol | number | Volume multiplier (0.0 = silent, 1.0 = normal).
        methods.add_method("setVolume", |_, this, vol: f32| {
            let mut st = this.state.borrow_mut();
            if let Some(bus) = st.mixer.get_bus_mut(this.key) {
                bus.set_volume(vol);
            }
            Ok(())
        });
        // -- getVolume --
        /// Returns the current volume multiplier of this bus.
        /// @return | number | Volume multiplier (defaults to 1.0).
        methods.add_method("getVolume", |_, this, ()| {
            let st = this.state.borrow();
            Ok(st.mixer.get_bus(this.key).map_or(1.0, |b| b.volume()))
        });
        // -- setPitch --
        /// Sets the pitch multiplier applied to all sources routed through this bus.
        /// @param | pitch | number | Pitch multiplier (1.0 = normal speed).
        methods.add_method("setPitch", |_, this, pitch: f32| {
            let mut st = this.state.borrow_mut();
            if let Some(bus) = st.mixer.get_bus_mut(this.key) {
                bus.set_pitch(pitch);
            }
            Ok(())
        });
        // -- getPitch --
        /// Returns the current pitch multiplier of this bus.
        /// @return | number | Current pitch multiplier (defaults to 1.0).
        methods.add_method("getPitch", |_, this, ()| {
            let st = this.state.borrow();
            Ok(st.mixer.get_bus(this.key).map_or(1.0, |b| b.pitch()))
        });
        // -- pause --
        /// Pauses all sources routed through this bus.
        methods.add_method("pause", |_, this, ()| {
            let mut st = this.state.borrow_mut();
            if let Some(bus) = st.mixer.get_bus_mut(this.key) {
                bus.pause();
            }
            Ok(())
        });
        // -- resume --
        /// Resumes all sources routed through this bus that were paused.
        methods.add_method("resume", |_, this, ()| {
            let mut st = this.state.borrow_mut();
            if let Some(bus) = st.mixer.get_bus_mut(this.key) {
                bus.resume();
            }
            Ok(())
        });
        // -- isPaused --
        /// Returns whether this bus is currently paused.
        /// @return | boolean | True if the bus is paused.
        methods.add_method("isPaused", |_, this, ()| {
            let st = this.state.borrow();
            Ok(st.mixer.get_bus(this.key).is_some_and(|b| b.is_paused()))
        });
        // -- type --
        /// Returns the type name of this object for runtime type-checking.
        /// @return | string | Always returns "LBus".
        methods.add_method("type", |_, _, ()| Ok("LBus"));
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to check (e.g. "LBus", "Bus", or "Object").
        /// @return | boolean | True if this object matches the given type.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LBus" || name == "LObject")
        });
        // -- setDuckTarget --
        /// Configures ducking so this bus lowers the volume of a target bus when active.
        /// @param | target_name | string | Name of the bus to duck.
        /// @param | duck_vol | number | Volume multiplier applied to the target when ducking (0.0-1.0).
        methods.add_method(
            "setDuckTarget",
            |_, this, (target_name, duck_vol): (String, f32)| {
                let mut st = this.state.borrow_mut();
                if let Some(bus) = st.mixer.get_bus_mut(this.key) {
                    bus.set_duck_target(&target_name, duck_vol);
                }
                Ok(())
            },
        );
        // -- clearDuck --
        /// Removes the ducking configuration from this bus.
        methods.add_method("clearDuck", |_, this, ()| {
            let mut st = this.state.borrow_mut();
            if let Some(bus) = st.mixer.get_bus_mut(this.key) {
                bus.clear_duck_target();
            }
            Ok(())
        });
        // -- getPeak --
        /// Returns the current peak amplitude level of this bus for VU-meter displays.
        /// @return | number | Peak level from 0.0 to 1.0.
        methods.add_method("getPeak", |_, this, ()| {
            let st = this.state.borrow();
            Ok(st.mixer.bus_peak(this.key))
        });
    }
}
/// Lua-side wrapper around a MIDI file player with per-channel control and tempo scaling.
#[derive(Clone)]
pub struct LuaMidiPlayer {
    pub(crate) inner: Rc<RefCell<MidiPlayer>>,
    pub(crate) state: Rc<RefCell<SharedState>>,
}
impl LuaUserData for LuaMidiPlayer {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- load --
        /// Loads a MIDI file from the given path relative to the game directory.
        /// @param | path | string | Relative path to the .mid file.
        /// @return | boolean | True if the file was loaded successfully.
        methods.add_method("load", |_, this, path: String| {
            let st = this.state.borrow();
            let full_path = st.game_dir.join(&path);
            Ok(this.inner.borrow_mut().load(&full_path))
        });
        // -- loadData --
        /// Loads MIDI data from a raw byte string in memory.
        /// @param | data | string | Raw MIDI binary data.
        /// @return | boolean | True if the data was parsed successfully.
        methods.add_method("loadData", |_, this, data: mlua::String| {
            let bytes = data.as_bytes().to_vec();
            Ok(this.inner.borrow_mut().load_data(bytes))
        });
        // -- isLoaded --
        /// Returns whether a MIDI file is currently loaded and ready to play.
        /// @return | boolean | True if a MIDI file is loaded.
        methods.add_method("isLoaded", |_, this, ()| {
            Ok(this.inner.borrow().is_loaded())
        });
        // -- getFilePath --
        /// Returns the file path of the currently loaded MIDI file.
        /// @return | string | File path string or nil if no file is loaded.
        methods.add_method("getFilePath", |_, this, ()| {
            Ok(this.inner.borrow().file_path().map(|s| s.to_string()))
        });
        // -- setSoundFont --
        /// Sets a custom SoundFont file for MIDI synthesis (stub, not yet implemented).
        /// @param | path | string | Relative path to the .sf2 file.
        methods.add_method("setSoundFont", |_, _this, _path: String| {
            log_msg!(debug, LA01_API_STUB, "MidiPlayer:setSoundFont");
            Ok(())
        });
        // -- getSoundFontPath --
        /// Returns the path of the currently set SoundFont (stub, not yet implemented).
        /// @return | string | SoundFont path or nil.
        methods.add_method("getSoundFontPath", |_, _this, ()| {
            log_msg!(debug, LA01_API_STUB, "MidiPlayer:getSoundFontPath");
            Ok(Option::<String>::None)
        });
        // -- useDefaultSoundFont --
        /// Reverts to the built-in default SoundFont (stub, not yet implemented).
        methods.add_method("useDefaultSoundFont", |_, _this, ()| {
            log_msg!(debug, LA01_API_STUB, "MidiPlayer:useDefaultSoundFont");
            Ok(())
        });
        // -- play --
        /// Starts MIDI playback from the current position using the audio output stream.
        methods.add_method("play", |_, this, ()| {
            let st = this.state.borrow();
            if let Some(handle) = st.mixer.stream_handle() {
                this.inner.borrow_mut().play(handle);
            }
            Ok(())
        });
        // -- pause --
        /// Pauses MIDI playback at the current position.
        methods.add_method("pause", |_, this, ()| {
            this.inner.borrow_mut().pause();
            Ok(())
        });
        // -- stop --
        /// Stops MIDI playback and resets position to the beginning.
        methods.add_method("stop", |_, this, ()| {
            this.inner.borrow_mut().stop();
            Ok(())
        });
        // -- isPlaying --
        /// Returns whether the MIDI player is currently playing.
        /// @return | boolean | True if playing.
        methods.add_method("isPlaying", |_, this, ()| {
            Ok(this.inner.borrow().is_playing())
        });
        // -- isPaused --
        /// Returns whether the MIDI player is currently paused.
        /// @return | boolean | True if paused.
        methods.add_method("isPaused", |_, this, ()| {
            Ok(this.inner.borrow().is_paused())
        });
        // -- seek --
        /// Seeks to a specific position in the MIDI file.
        /// @param | secs | number | Target position in seconds.
        methods.add_method("seek", |_, this, secs: f64| {
            this.inner.borrow_mut().seek(secs);
            Ok(())
        });
        // -- tell --
        /// Returns the current playback position of the MIDI player in seconds.
        /// @return | number | Current position in seconds.
        methods.add_method("tell", |_, this, ()| Ok(this.inner.borrow().tell()));
        // -- getDuration --
        /// Returns the total duration of the loaded MIDI file in seconds.
        /// @return | number | Duration in seconds.
        methods.add_method("getDuration", |_, this, ()| {
            Ok(this.inner.borrow().duration())
        });
        // -- setLooping --
        /// Enables or disables looping for MIDI playback.
        /// @param | looping | boolean | True to loop, false to play once.
        methods.add_method("setLooping", |_, this, looping: bool| {
            this.inner.borrow_mut().set_looping(looping);
            Ok(())
        });
        // -- isLooping --
        /// Returns whether MIDI looping is enabled.
        /// @return | boolean | True if looping.
        methods.add_method("isLooping", |_, this, ()| {
            Ok(this.inner.borrow().is_looping())
        });
        // -- setVolume --
        /// Sets the master volume for MIDI playback.
        /// @param | vol | number | Volume multiplier (0.0 = silent, 1.0 = normal).
        methods.add_method("setVolume", |_, this, vol: f32| {
            this.inner.borrow_mut().set_volume(vol);
            Ok(())
        });
        // -- getVolume --
        /// Returns the current master volume of the MIDI player.
        /// @return | number | Volume multiplier.
        methods.add_method("getVolume", |_, this, ()| Ok(this.inner.borrow().volume()));
        // -- setBus --
        /// Routes this MIDI player's output through the specified audio bus.
        /// @param | bus | LBus? | Bus to route through, or nil for direct output.
        methods.add_method("setBus", |_, this, bus_val: LuaValue| match &bus_val {
            LuaValue::UserData(ud) => {
                let bus = ud.borrow::<LuaBus>()?;
                this.inner.borrow_mut().set_bus_key(Some(bus.key));
                Ok(())
            }
            LuaValue::Nil => {
                this.inner.borrow_mut().set_bus_key(None);
                Ok(())
            }
            _ => Err(LuaError::RuntimeError(
                "MidiPlayer:setBus(): expected Bus or nil".into(),
            )),
        });
        // -- getBus --
        /// Returns the audio bus this MIDI player is routed through.
        /// @return | LBus | The assigned bus, or nil if using direct output.
        methods.add_method("getBus", |_, this, ()| {
            match this.inner.borrow().bus_key() {
                Some(key) => Ok(Some(LuaBus {
                    state: this.state.clone(),
                    key,
                })),
                None => Ok(None),
            }
        });
        // -- setTempo --
        /// Sets the playback tempo in beats per minute.
        /// @param | bpm | number | Desired tempo in BPM.
        methods.add_method("setTempo", |_, this, bpm: f64| {
            let original = this.inner.borrow().original_tempo();
            if original > 0.0 {
                this.inner
                    .borrow_mut()
                    .set_tempo_scale((bpm / original) as f32);
            }
            Ok(())
        });
        // -- getTempo --
        /// Returns the current effective tempo in beats per minute.
        /// @return | number | Current tempo in BPM.
        methods.add_method("getTempo", |_, this, ()| {
            let mp = this.inner.borrow();
            Ok(mp.original_tempo() * mp.tempo_scale() as f64)
        });
        // -- getOriginalTempo --
        /// Returns the original tempo of the MIDI file as authored.
        /// @return | number | Original tempo in BPM.
        methods.add_method("getOriginalTempo", |_, this, ()| {
            Ok(this.inner.borrow().original_tempo())
        });
        // -- setTempoScale --
        /// Sets a tempo multiplier relative to the original speed.
        /// @param | scale | number | Tempo scale (1.0 = original, 2.0 = double speed).
        methods.add_method("setTempoScale", |_, this, scale: f32| {
            this.inner.borrow_mut().set_tempo_scale(scale);
            Ok(())
        });
        // -- getTempoScale --
        /// Returns the current tempo scale multiplier.
        /// @return | number | Tempo scale factor.
        methods.add_method("getTempoScale", |_, this, ()| {
            Ok(this.inner.borrow().tempo_scale())
        });
        // -- getTicksPerBeat --
        /// Returns the MIDI file's resolution in ticks per beat (PPQN).
        /// @return | integer | Ticks per quarter note.
        methods.add_method("getTicksPerBeat", |_, this, ()| {
            Ok(this.inner.borrow().ticks_per_beat())
        });
        // -- setChannelVolume --
        /// Sets the volume for a specific MIDI channel (1-16).
        /// @param | ch | integer | Channel number (1-16).
        /// @param | vol | number | Volume multiplier (0.0-1.0).
        methods.add_method("setChannelVolume", |_, this, (ch, vol): (usize, f32)| {
            if (1..=16).contains(&ch) {
                this.inner.borrow_mut().set_channel_volume(ch - 1, vol);
            }
            Ok(())
        });
        // -- getChannelVolume --
        /// Returns the volume of a specific MIDI channel.
        /// @param | ch | integer | Channel number (1-16).
        /// @return | number | Channel volume (0.0-1.0).
        methods.add_method("getChannelVolume", |_, this, ch: usize| {
            if (1..=16).contains(&ch) {
                Ok(this.inner.borrow().channel_volume(ch - 1))
            } else {
                Ok(0.0)
            }
        });
        // -- setChannelMuted --
        /// Mutes or unmutes a specific MIDI channel.
        /// @param | ch | integer | Channel number (1-16).
        /// @param | muted | boolean | True to mute, false to unmute.
        methods.add_method("setChannelMuted", |_, this, (ch, muted): (usize, bool)| {
            if (1..=16).contains(&ch) {
                this.inner.borrow_mut().set_channel_muted(ch - 1, muted);
            }
            Ok(())
        });
        // -- isChannelMuted --
        /// Returns whether a specific MIDI channel is muted.
        /// @param | ch | integer | Channel number (1-16).
        /// @return | boolean | True if the channel is muted.
        methods.add_method("isChannelMuted", |_, this, ch: usize| {
            if (1..=16).contains(&ch) {
                Ok(this.inner.borrow().is_channel_muted(ch - 1))
            } else {
                Ok(false)
            }
        });
        // -- setChannelInstrument --
        /// Sets the General MIDI instrument program for a channel.
        /// @param | ch | integer | Channel number (1-16).
        /// @param | inst | integer | GM instrument program number (0-127).
        methods.add_method(
            "setChannelInstrument",
            |_, this, (ch, inst): (usize, u8)| {
                if (1..=16).contains(&ch) {
                    this.inner.borrow_mut().set_channel_instrument(ch - 1, inst);
                }
                Ok(())
            },
        );
        // -- getChannelInstrument --
        /// Returns the current GM instrument program for a channel.
        /// @param | ch | integer | Channel number (1-16).
        /// @return | integer | GM instrument program number (0-127).
        methods.add_method("getChannelInstrument", |_, this, ch: usize| {
            if (1..=16).contains(&ch) {
                Ok(this.inner.borrow().channel_instrument(ch - 1))
            } else {
                Ok(0u8)
            }
        });
        // -- getChannelCount --
        /// Returns the number of active MIDI channels in the loaded file.
        /// @return | integer | Number of active channels.
        methods.add_method("getChannelCount", |_, this, ()| {
            Ok(this.inner.borrow().channel_count())
        });
        // -- soloChannel --
        /// Solos a specific MIDI channel, muting all others.
        /// @param | ch | integer | Channel number (1-16) to solo.
        methods.add_method("soloChannel", |_, this, ch: usize| {
            if (1..=16).contains(&ch) {
                this.inner.borrow_mut().solo_channel(ch - 1);
            }
            Ok(())
        });
        // -- unsoloAll --
        /// Removes solo from all channels, restoring normal playback.
        methods.add_method("unsoloAll", |_, this, ()| {
            this.inner.borrow_mut().unsolo_all();
            Ok(())
        });
        // -- getTrackCount --
        /// Returns the number of tracks in the loaded MIDI file.
        /// @return | integer | Number of MIDI tracks.
        methods.add_method("getTrackCount", |_, this, ()| {
            Ok(this.inner.borrow().track_count())
        });
        // -- getTrackName --
        /// Returns the name of a MIDI track by 1-based index.
        /// @param | idx | integer | Track index (1-based).
        /// @return | string | Track name or nil if not available.
        methods.add_method("getTrackName", |_, this, idx: usize| {
            if idx >= 1 {
                Ok(this
                    .inner
                    .borrow()
                    .track_name(idx - 1)
                    .map(|s| s.to_string()))
            } else {
                Ok(None)
            }
        });
        // -- setTrackMuted --
        /// Mutes or unmutes a specific MIDI track.
        /// @param | idx | integer | Track index (1-based).
        /// @param | muted | boolean | True to mute, false to unmute.
        methods.add_method("setTrackMuted", |_, this, (idx, muted): (usize, bool)| {
            if idx >= 1 {
                this.inner.borrow_mut().set_track_muted(idx - 1, muted);
            }
            Ok(())
        });
        // -- isTrackMuted --
        /// Returns whether a specific MIDI track is muted.
        /// @param | idx | integer | Track index (1-based).
        /// @return | boolean | True if the track is muted.
        methods.add_method("isTrackMuted", |_, this, idx: usize| {
            if idx >= 1 {
                Ok(this.inner.borrow().is_track_muted(idx - 1))
            } else {
                Ok(false)
            }
        });
        // -- getNoteCount --
        /// Returns the total number of note events in the loaded MIDI file.
        /// @return | integer | Total note count.
        methods.add_method("getNoteCount", |_, this, ()| {
            Ok(this.inner.borrow().note_count())
        });
        // -- setOnNoteOn --
        /// Registers a callback for MIDI note-on events (stub, not yet implemented).
        /// @param | cb | function? | Callback function or nil to clear.
        methods.add_method("setOnNoteOn", |_, _this, _cb: LuaValue| {
            log_msg!(debug, LA01_API_STUB, "MidiPlayer:setOnNoteOn");
            Ok(())
        });
        // -- setOnNoteOff --
        /// Registers a callback for MIDI note-off events (stub, not yet implemented).
        /// @param | cb | function? | Callback function or nil to clear.
        methods.add_method("setOnNoteOff", |_, _this, _cb: LuaValue| {
            log_msg!(debug, LA01_API_STUB, "MidiPlayer:setOnNoteOff");
            Ok(())
        });
        // -- setOnEnd --
        /// Registers a callback invoked when MIDI playback finishes (stub, not yet implemented).
        /// @param | cb | function? | Callback function or nil to clear.
        methods.add_method("setOnEnd", |_, _this, _cb: LuaValue| {
            log_msg!(debug, LA01_API_STUB, "MidiPlayer:setOnEnd");
            Ok(())
        });
        // -- getSampleRate --
        /// Returns the output sample rate used for MIDI synthesis.
        /// @return | integer | Sample rate in Hz (e.g. 44100).
        methods.add_method("getSampleRate", |_, this, ()| {
            Ok(this.inner.borrow().get_output_sample_rate())
        });
        // -- setSampleRate --
        /// Sets the output sample rate for MIDI synthesis.
        /// @param | rate | integer | Sample rate in Hz (e.g. 44100, 48000).
        methods.add_method_mut("setSampleRate", |_, this, rate: u32| {
            this.inner.borrow_mut().set_output_sample_rate(rate);
            Ok(())
        });
        // -- getChannels --
        /// Returns the number of output audio channels for MIDI synthesis.
        /// @return | integer | Channel count (1 = mono, 2 = stereo).
        methods.add_method("getChannels", |_, this, ()| {
            Ok(this.inner.borrow().get_output_channels() as u32)
        });
        // -- setChannels --
        /// Sets the number of output audio channels for MIDI synthesis.
        /// @param | channels | integer | Channel count (1 = mono, 2 = stereo).
        methods.add_method_mut("setChannels", |_, this, channels: u32| {
            this.inner.borrow_mut().set_output_channels(channels as u16);
            Ok(())
        });
        // -- type --
        /// Returns the type name of this object for runtime type-checking.
        /// @return | string | Always returns "LMidiPlayer".
        methods.add_method("type", |_, _, ()| Ok("LMidiPlayer"));
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to check (e.g. "LMidiPlayer", "MidiPlayer", or "Object").
        /// @return | boolean | True if this object matches the given type.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LMidiPlayer" || name == "LObject")
        });
    }
}
/// Lua-side wrapper around a pre-allocated pool of identical sound voices for rapid fire effects.
pub(crate) struct LuaSoundPool {
    pub(crate) pool: crate::audio::pool::SoundPool,
    pub(crate) state: Rc<RefCell<SharedState>>,
}
impl LuaUserData for LuaSoundPool {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- play --
        /// Plays the next available voice from the pool in round-robin order.
        /// @return | integer | Numeric source ID of the voice that started playing.
        methods.add_method_mut("play", |_, this, ()| {
            let key = this.pool.next_voice();
            let game_dir = this.state.borrow().game_dir.clone();
            this.state.borrow_mut().mixer.play(key, &game_dir);
            Ok(slotmap::Key::data(&key).as_ffi() as i64)
        });
        // -- stopAll --
        /// Stops all voices in this sound pool immediately.
        methods.add_method_mut("stopAll", |_, this, ()| {
            let keys: Vec<_> = this.pool.all_keys().to_vec();
            let mut st = this.state.borrow_mut();
            for key in keys {
                st.mixer.stop(key);
            }
            Ok(())
        });
        // -- setVolume --
        /// Sets the volume for all voices in this pool.
        /// @param | vol | number | Volume multiplier (0.0 = silent, 1.0 = normal).
        methods.add_method_mut("setVolume", |_, this, vol: f32| {
            this.pool.set_volume(vol);
            let keys: Vec<_> = this.pool.all_keys().to_vec();
            let mut st = this.state.borrow_mut();
            for key in keys {
                st.mixer.set_volume(key, vol);
            }
            Ok(())
        });
        // -- setBus --
        /// Routes all voices in this pool through the named audio bus.
        /// @param | name | string | Name of the target bus.
        methods.add_method_mut("setBus", |_, this, name: String| {
            this.pool.set_bus(&name);
            let keys: Vec<_> = this.pool.all_keys().to_vec();
            let bus_key = this.state.borrow().mixer.get_bus_by_name(&name);
            let mut st = this.state.borrow_mut();
            for key in keys {
                st.mixer.set_source_bus(key, bus_key);
            }
            Ok(())
        });
        // -- release --
        /// Releases all voices and frees audio resources held by this pool.
        methods.add_method_mut("release", |_, this, ()| {
            let keys: Vec<_> = this.pool.all_keys().to_vec();
            let mut st = this.state.borrow_mut();
            for key in keys {
                st.mixer.release(key);
            }
            Ok(())
        });
        // -- getVoiceCount --
        /// Returns the number of pre-allocated voices in this pool.
        /// @return | integer | Voice count.
        methods.add_method("getVoiceCount", |_, this, ()| Ok(this.pool.voice_count()));
        // -- type --
        /// Returns the type name of this object for runtime type-checking.
        /// @return | string | Always returns "LSoundPool".
        methods.add_method("type", |_, _this, ()| Ok("LSoundPool"));
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to check (e.g. "LSoundPool" or "Object").
        /// @return | boolean | True if this object matches the given type.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LSoundPool" || name == "LObject")
        });
    }
}
/// Lua-side wrapper around a streaming audio decoder for incremental PCM extraction.
pub struct LuaDecoder {
    inner: Decoder,
}
impl LuaUserData for LuaDecoder {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- decode --
        /// Decodes the next chunk of audio data and returns it as a LSoundData object.
        /// @return | LSoundData | Decoded PCM data, or nil if end of stream reached.
        methods.add_method_mut("decode", |lua, this, ()| match this.inner.decode() {
            Some(pcm_i16) => {
                let samples: Vec<f32> = pcm_i16.iter().map(|&s| s as f32 / 32768.0).collect();
                let sd =
                    SoundData::from_samples(samples, this.inner.sample_rate, this.inner.channels);
                Ok(LuaValue::UserData(lua.create_userdata(sd)?))
            }
            None => Ok(LuaValue::Nil),
        });
        // -- getChannelCount --
        /// Returns the number of audio channels in the source file.
        /// @return | integer | Channel count (1 = mono, 2 = stereo).
        methods.add_method("getChannelCount", |_, this, ()| {
            Ok(this.inner.channels as u32)
        });
        // -- getBitDepth --
        /// Returns the bit depth of the source audio file.
        /// @return | integer | Bits per sample (e.g. 16, 24).
        methods.add_method("getBitDepth", |_, this, ()| Ok(this.inner.bit_depth as u32));
        // -- getSampleRate --
        /// Returns the sample rate of the source audio file.
        /// @return | integer | Sample rate in Hz.
        methods.add_method("getSampleRate", |_, this, ()| Ok(this.inner.sample_rate));
        // -- getDuration --
        /// Returns the total duration of the source audio file in seconds.
        /// @return | number | Duration in seconds.
        methods.add_method("getDuration", |_, this, ()| Ok(this.inner.get_duration()));
        // -- seek --
        /// Seeks to a specific position in the audio stream.
        /// @param | offset | number | Target position in seconds.
        methods.add_method_mut("seek", |_, this, offset: f64| {
            this.inner.seek(offset);
            Ok(())
        });
        // -- rewind --
        /// Rewinds the decoder back to the beginning of the audio stream.
        methods.add_method_mut("rewind", |_, this, ()| {
            this.inner.rewind();
            Ok(())
        });
        // -- tell --
        /// Returns the current read position in the audio stream in seconds.
        /// @return | number | Current position in seconds.
        methods.add_method("tell", |_, this, ()| Ok(this.inner.tell()));
        // -- isSeekable --
        /// Returns whether this decoder supports seeking.
        /// @return | boolean | True if seek operations are supported.
        methods.add_method("isSeekable", |_, this, ()| Ok(this.inner.is_seekable()));
        // -- release --
        /// Releases decoder resources (no-op, kept for API symmetry).
        methods.add_method("release", |_, _, ()| Ok(()));
        // -- type --
        /// Returns the type name of this object for runtime type-checking.
        /// @return | string | Always returns "LDecoder".
        methods.add_method("type", |_, _, ()| Ok("LDecoder"));
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to check (e.g. "LDecoder" or "Object").
        /// @return | boolean | True if this object matches the given type.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LDecoder" || name == "LObject")
        });
    }
}
/// Registers the `lurek.audio` Lua API table and userdata bindings.
pub fn register(lua: &Lua, lurek: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;
    // --- source lifecycle ----------------------------------------------------
    // -- newSource --
    /// Creates a new audio source from a file path, either fully loaded or streaming.
    /// @param | path | string | Relative path to the audio file (WAV, OGG, MP3, FLAC).
    /// @param | sourceType | string? | "static" to load fully into memory, or "stream" (default) for streaming.
    /// @return | LSource | A new audio source ready for playback.
    let s = state.clone();
    tbl.set(
        "newSource",
        lua.create_function(move |_, args| helper_new_source(s.clone(), args))?,
    )?;
    // -- play --
    /// Starts playback of a source by handle, optionally routing through a named bus.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    /// @param | options | table? | Optional table with "bus" field for bus routing.
    /// @return | integer | Numeric source ID of the playing source.
    let s = state.clone();
    tbl.set(
        "play",
        lua.create_function(move |_, (id_val, options)| helper_play(s.clone(), id_val, options))?,
    )?;
    // -- stop --
    /// Stops playback of a source and resets its position to the beginning.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    let s = state.clone();
    tbl.set(
        "stop",
        lua.create_function(move |_, id_val: LuaValue| {
            let mut st = s.borrow_mut();
            let key = require_sound_key(&st, &id_val, "lurek.audio.stop")?;
            st.mixer.stop(key);
            Ok(())
        })?,
    )?;
    // -- setVolume --
    /// Sets the volume of a source by handle.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    /// @param | vol | number | Volume multiplier (0.0 = silent, 1.0 = normal).
    let s = state.clone();
    tbl.set(
        "setVolume",
        lua.create_function(move |_, (id_val, vol): (LuaValue, f32)| {
            let mut st = s.borrow_mut();
            let key = require_sound_key(&st, &id_val, "lurek.audio.setVolume")?;
            st.mixer.set_volume(key, vol);
            Ok(())
        })?,
    )?;
    // -- getVolume --
    /// Returns the current volume of a source.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    /// @return | number | Current volume multiplier.
    let s = state.clone();
    tbl.set(
        "getVolume",
        lua.create_function(move |_, id_val: LuaValue| {
            let st = s.borrow();
            let key = require_sound_key(&st, &id_val, "lurek.audio.getVolume")?;
            Ok(st.mixer.get_volume(key))
        })?,
    )?;
    // -- pause --
    /// Pauses playback of a source at its current position.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    let s = state.clone();
    tbl.set(
        "pause",
        lua.create_function(move |_, id_val: LuaValue| {
            let mut st = s.borrow_mut();
            let key = require_sound_key(&st, &id_val, "lurek.audio.pause")?;
            st.mixer.pause(key);
            Ok(())
        })?,
    )?;
    // -- resume --
    /// Resumes playback of a paused source.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    let s = state.clone();
    tbl.set(
        "resume",
        lua.create_function(move |_, id_val: LuaValue| {
            let mut st = s.borrow_mut();
            let key = require_sound_key(&st, &id_val, "lurek.audio.resume")?;
            st.mixer.resume(key);
            Ok(())
        })?,
    )?;
    // -- setPitch --
    /// Sets the pitch multiplier of a source, affecting playback speed and tone.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    /// @param | pitch | number | Pitch multiplier (1.0 = normal, 2.0 = octave up).
    let s = state.clone();
    tbl.set(
        "setPitch",
        lua.create_function(move |_, (id_val, pitch): (LuaValue, f32)| {
            let mut st = s.borrow_mut();
            let key = require_sound_key(&st, &id_val, "lurek.audio.setPitch")?;
            st.mixer.set_pitch(key, pitch);
            Ok(())
        })?,
    )?;
    // -- getPitch --
    /// Returns the current pitch multiplier of a source.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    /// @return | number | Current pitch multiplier.
    let s = state.clone();
    tbl.set(
        "getPitch",
        lua.create_function(move |_, id_val: LuaValue| {
            let st = s.borrow();
            let key = require_sound_key(&st, &id_val, "lurek.audio.getPitch")?;
            Ok(st.mixer.get_pitch(key))
        })?,
    )?;
    // -- isPlaying --
    /// Returns whether a source is currently playing.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    /// @return | boolean | True if the source is playing.
    let s = state.clone();
    tbl.set(
        "isPlaying",
        lua.create_function(move |_, id_val: LuaValue| {
            let st = s.borrow();
            let key = require_sound_key(&st, &id_val, "lurek.audio.isPlaying")?;
            Ok(st.mixer.is_playing(key))
        })?,
    )?;
    // -- isPaused --
    /// Returns whether a source is currently paused.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    /// @return | boolean | True if the source is paused.
    let s = state.clone();
    tbl.set(
        "isPaused",
        lua.create_function(move |_, id_val: LuaValue| {
            let st = s.borrow();
            let key = require_sound_key(&st, &id_val, "lurek.audio.isPaused")?;
            Ok(st.mixer.is_paused(key))
        })?,
    )?;
    // -- isStopped --
    /// Returns whether a source is currently stopped.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    /// @return | boolean | True if the source is stopped.
    let s = state.clone();
    tbl.set(
        "isStopped",
        lua.create_function(move |_, id_val: LuaValue| {
            let st = s.borrow();
            let key = require_sound_key(&st, &id_val, "lurek.audio.isStopped")?;
            Ok(st.mixer.is_stopped(key))
        })?,
    )?;
    // -- setLooping --
    /// Enables or disables looping for a source.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    /// @param | looping | boolean | True to loop, false to play once.
    let s = state.clone();
    tbl.set(
        "setLooping",
        lua.create_function(move |_, (id_val, looping): (LuaValue, bool)| {
            let mut st = s.borrow_mut();
            let key = require_sound_key(&st, &id_val, "lurek.audio.setLooping")?;
            st.mixer.set_looping(key, looping);
            Ok(())
        })?,
    )?;
    // -- isLooping --
    /// Returns whether a source has looping enabled.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    /// @return | boolean | True if looping is enabled.
    let s = state.clone();
    tbl.set(
        "isLooping",
        lua.create_function(move |_, id_val: LuaValue| {
            let st = s.borrow();
            let key = require_sound_key(&st, &id_val, "lurek.audio.isLooping")?;
            Ok(st.mixer.is_looping(key))
        })?,
    )?;
    // -- playLooping --
    /// Starts playback of a source with looping enabled in one call.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    let s = state.clone();
    tbl.set(
        "playLooping",
        lua.create_function(move |_, id_val: LuaValue| {
            let mut st = s.borrow_mut();
            let key = require_sound_key(&st, &id_val, "lurek.audio.playLooping")?;
            let game_dir = st.game_dir.clone();
            st.mixer.play_looping(key, &game_dir);
            Ok(())
        })?,
    )?;
    // -- setPan --
    /// Sets the stereo panning of a source.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    /// @param | pan | number | Pan from -1.0 (left) to 1.0 (right), 0.0 is center.
    let s = state.clone();
    tbl.set(
        "setPan",
        lua.create_function(move |_, (id_val, pan): (LuaValue, f32)| {
            let mut st = s.borrow_mut();
            let key = require_sound_key(&st, &id_val, "lurek.audio.setPan")?;
            st.mixer.set_pan(key, pan);
            Ok(())
        })?,
    )?;
    // -- getPan --
    /// Returns the current stereo pan position of a source.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    /// @return | number | Pan value from -1.0 (left) to 1.0 (right).
    let s = state.clone();
    tbl.set(
        "getPan",
        lua.create_function(move |_, id_val: LuaValue| {
            let st = s.borrow();
            let key = require_sound_key(&st, &id_val, "lurek.audio.getPan")?;
            Ok(st.mixer.get_pan(key))
        })?,
    )?;
    // -- setMasterVolume --
    /// Sets the global master volume affecting all audio output.
    /// @param | vol | number | Master volume multiplier (0.0 = silent, 1.0 = normal).
    let s = state.clone();
    tbl.set(
        "setMasterVolume",
        lua.create_function(move |_, vol: f32| {
            s.borrow_mut().mixer.set_master_volume(vol);
            Ok(())
        })?,
    )?;
    // -- getMasterVolume --
    /// Returns the current global master volume level.
    /// @return | number | Master volume multiplier.
    let s = state.clone();
    tbl.set(
        "getMasterVolume",
        lua.create_function(move |_, ()| Ok(s.borrow().mixer.get_master_volume()))?,
    )?;
    // -- getActiveSourceCount --
    /// Returns the number of sources currently playing audio.
    /// @return | integer | Count of active (playing) sources.
    let s = state.clone();
    tbl.set(
        "getActiveSourceCount",
        lua.create_function(move |_, ()| Ok(s.borrow().mixer.get_active_source_count()))?,
    )?;
    // -- getSourceCount --
    /// Returns the total number of loaded audio sources (playing or idle).
    /// @return | integer | Total source count.
    let s = state.clone();
    tbl.set(
        "getSourceCount",
        lua.create_function(move |_, ()| Ok(s.borrow().mixer.get_source_count()))?,
    )?;
    // -- getSourceType --
    /// Returns whether a source is static or streaming.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    /// @return | string | Either "static" or "stream".
    let s = state.clone();
    tbl.set(
        "getSourceType",
        lua.create_function(move |_, id_val| helper_get_source_type(s.clone(), id_val))?,
    )?;
    // -- clone --
    /// Creates an independent copy of a source sharing the same audio data.
    /// @param | source | LSource|integer | Audio source or numeric source ID to clone.
    /// @return | LSource | A new source instance with identical settings.
    let s = state.clone();
    tbl.set(
        "clone",
        lua.create_function(move |_, id_val| helper_clone(s.clone(), id_val))?,
    )?;
    // -- pauseAll --
    /// Pauses all currently playing audio sources.
    let s = state.clone();
    tbl.set(
        "pauseAll",
        lua.create_function(move |_, ()| {
            s.borrow_mut().mixer.pause_all();
            Ok(())
        })?,
    )?;
    // -- stopAll --
    /// Stops all audio sources and resets their positions.
    let s = state.clone();
    tbl.set(
        "stopAll",
        lua.create_function(move |_, ()| {
            s.borrow_mut().mixer.stop_all();
            Ok(())
        })?,
    )?;
    // -- resumeAll --
    /// Resumes all paused audio sources. This function is exposed to Lua scripts.
    let s = state.clone();
    tbl.set(
        "resumeAll",
        lua.create_function(move |_, ()| {
            s.borrow_mut().mixer.resume_all();
            Ok(())
        })?,
    )?;
    // -- release --
    /// Releases an audio source, freeing its memory and stopping playback.
    /// @param | source | LSource|integer | Audio source or numeric source ID to release.
    /// @return | boolean | True if the source was successfully released.
    let s = state.clone();
    tbl.set(
        "release",
        lua.create_function(move |_, id_val| helper_release(s.clone(), id_val))?,
    )?;
    // -- newBus --
    /// Creates a new audio mixing bus for grouping and controlling sources.
    /// @param | name | string | Unique name for the bus (e.g. "music", "sfx").
    /// @return | LBus | The new audio bus handle.
    let s = state.clone();
    tbl.set(
        "newBus",
        lua.create_function(move |_, name: String| {
            let mut st = s.borrow_mut();
            let key = st.mixer.new_bus(&name);
            Ok(LuaBus {
                state: s.clone(),
                key,
            })
        })?,
    )?;
    // -- setSourceBus --
    /// Routes a source through a specific audio bus for grouped mixing.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    /// @param | bus | LBus | The bus to route through.
    let s = state.clone();
    tbl.set(
        "setSourceBus",
        lua.create_function(move |_, (id_val, bus_val)| {
            helper_set_source_bus(s.clone(), id_val, bus_val)
        })?,
    )?;
    // -- getSourceBus --
    /// Returns the bus a source is routed through.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    /// @return | LBus | The assigned bus, or nil if using direct output.
    let s = state.clone();
    tbl.set(
        "getSourceBus",
        lua.create_function(move |_, id_val| helper_get_source_bus(s.clone(), id_val))?,
    )?;
    // -- getMaxSources --
    /// Returns the maximum number of simultaneous audio sources supported.
    /// @return | integer | Maximum source count (64).
    tbl.set("getMaxSources", lua.create_function(|_, ()| Ok(64))?)?;
    // -- getDuration --
    /// Returns the total duration of a source in seconds.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    /// @return | number | Duration in seconds.
    let s = state.clone();
    tbl.set(
        "getDuration",
        lua.create_function(move |_, id_val: LuaValue| {
            let st = s.borrow();
            let key = require_sound_key(&st, &id_val, "lurek.audio.getDuration")?;
            Ok(st.mixer.get_duration(key))
        })?,
    )?;
    // -- tell --
    /// Returns the current playback position of a source in seconds.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    /// @return | number | Current position in seconds.
    let s = state.clone();
    tbl.set(
        "tell",
        lua.create_function(move |_, id_val: LuaValue| {
            let st = s.borrow();
            let key = require_sound_key(&st, &id_val, "lurek.audio.tell")?;
            Ok(st.mixer.get_tell(key))
        })?,
    )?;
    // -- seek --
    /// Seeks a source to a specific position in seconds.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    /// @param | pos | number | Target position in seconds.
    let s = state.clone();
    tbl.set(
        "seek",
        lua.create_function(move |_, (id_val, pos): (LuaValue, f32)| {
            let mut st = s.borrow_mut();
            let key = require_sound_key(&st, &id_val, "lurek.audio.seek")?;
            let game_dir = st.game_dir.clone();
            st.mixer.seek(key, pos, &game_dir);
            Ok(())
        })?,
    )?;
    // -- setLowpass --
    /// Applies a lowpass filter to a source, attenuating high frequencies.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    /// @param | cutoff_hz | integer | Cutoff frequency in Hertz.
    let s = state.clone();
    tbl.set(
        "setLowpass",
        lua.create_function(move |_, (id_val, cutoff_hz): (LuaValue, u32)| {
            let mut st = s.borrow_mut();
            let key = require_sound_key(&st, &id_val, "lurek.audio.setLowpass")?;
            st.mixer.set_lowpass(key, cutoff_hz);
            Ok(())
        })?,
    )?;
    // -- setHighpass --
    /// Applies a highpass filter to a source, attenuating low frequencies.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    /// @param | cutoff_hz | integer | Cutoff frequency in Hertz.
    let s = state.clone();
    tbl.set(
        "setHighpass",
        lua.create_function(move |_, (id_val, cutoff_hz): (LuaValue, u32)| {
            let mut st = s.borrow_mut();
            let key = require_sound_key(&st, &id_val, "lurek.audio.setHighpass")?;
            st.mixer.set_highpass(key, cutoff_hz);
            Ok(())
        })?,
    )?;
    // -- getLowpass --
    /// Returns the current lowpass filter cutoff of a source.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    /// @return | integer | Cutoff frequency in Hz, or 0 if not set.
    let s = state.clone();
    tbl.set(
        "getLowpass",
        lua.create_function(move |_, id_val: LuaValue| {
            let st = s.borrow();
            let key = require_sound_key(&st, &id_val, "lurek.audio.getLowpass")?;
            Ok(st.mixer.get_lowpass(key))
        })?,
    )?;
    // -- getHighpass --
    /// Returns the current highpass filter cutoff of a source.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    /// @return | integer | Cutoff frequency in Hz, or 0 if not set.
    let s = state.clone();
    tbl.set(
        "getHighpass",
        lua.create_function(move |_, id_val: LuaValue| {
            let st = s.borrow();
            let key = require_sound_key(&st, &id_val, "lurek.audio.getHighpass")?;
            Ok(st.mixer.get_highpass(key))
        })?,
    )?;
    // -- clearFilter --
    /// Removes all frequency filters from a source.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    let s = state.clone();
    tbl.set(
        "clearFilter",
        lua.create_function(move |_, id_val: LuaValue| {
            let mut st = s.borrow_mut();
            let key = require_sound_key(&st, &id_val, "lurek.audio.clearFilter")?;
            st.mixer.clear_filter(key);
            Ok(())
        })?,
    )?;
    // -- fadeIn --
    /// Sets the fade-in duration for a source so it ramps from silence on play.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    /// @param | dur | number | Fade-in duration in seconds.
    let s = state.clone();
    tbl.set(
        "fadeIn",
        lua.create_function(move |_, (id_val, dur): (LuaValue, f32)| {
            let mut st = s.borrow_mut();
            let key = require_sound_key(&st, &id_val, "lurek.audio.fadeIn")?;
            st.mixer.set_fade_in(key, dur);
            Ok(())
        })?,
    )?;
    // -- getFadeIn --
    /// Returns the configured fade-in duration of a source.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    /// @return | number | Fade-in duration in seconds.
    let s = state.clone();
    tbl.set(
        "getFadeIn",
        lua.create_function(move |_, id_val: LuaValue| {
            let st = s.borrow();
            let key = require_sound_key(&st, &id_val, "lurek.audio.getFadeIn")?;
            Ok(st.mixer.get_fade_in(key))
        })?,
    )?;
    // -- setListener2D --
    /// Sets the 2D listener position for spatial audio calculations.
    /// @param | x | number | Listener X position in world units.
    /// @param | y | number | Listener Y position in world units.
    let s = state.clone();
    tbl.set(
        "setListener2D",
        lua.create_function(move |_, (x, y): (f32, f32)| {
            s.borrow_mut().mixer.set_listener_position(x, y, 0.0);
            Ok(())
        })?,
    )?;
    // -- getListener2D --
    /// Returns the current 2D listener position.
    /// @return | number, number | X and Y position of the listener.
    let s = state.clone();
    tbl.set(
        "getListener2D",
        lua.create_function(move |_, ()| {
            let pos = s.borrow().mixer.get_listener_position();
            Ok((pos[0], pos[1]))
        })?,
    )?;
    // -- setListener --
    /// Sets the 3D listener position for spatial audio (Z defaults to 0 for 2D games).
    /// @param | x | number | Listener X position.
    /// @param | y | number | Listener Y position.
    /// @param | z | number? | Listener Z position (defaults to 0).
    let s = state.clone();
    tbl.set(
        "setListener",
        lua.create_function(move |_, (x, y, z): (f32, f32, Option<f32>)| {
            s.borrow_mut()
                .mixer
                .set_listener_position(x, y, z.unwrap_or(0.0));
            Ok(())
        })?,
    )?;
    // -- getListener --
    /// Returns the current 3D listener position.
    /// @return | number, number, number | X, Y, and Z position of the listener.
    let s = state.clone();
    tbl.set(
        "getListener",
        lua.create_function(move |_, ()| {
            let pos = s.borrow().mixer.get_listener_position();
            Ok((pos[0], pos[1], pos[2]))
        })?,
    )?;
    // -- setPosition --
    /// Sets the 3D position of a source for spatial audio panning and attenuation.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    /// @param | x | number | X position in world units.
    /// @param | y | number | Y position in world units.
    /// @param | z | number? | Z position (defaults to 0).
    let s = state.clone();
    tbl.set(
        "setPosition",
        lua.create_function(
            move |_, (id_val, x, y, z): (LuaValue, f32, f32, Option<f32>)| {
                let key = sound_key_from_value(&id_val)?;
                s.borrow_mut()
                    .mixer
                    .set_source_position(key, x, y, z.unwrap_or(0.0));
                Ok(())
            },
        )?,
    )?;
    // -- getPosition --
    /// Returns the 3D position of a source.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    /// @return | number, number, number | X, Y, and Z position.
    let s = state.clone();
    tbl.set(
        "getPosition",
        lua.create_function(move |_, id_val: LuaValue| {
            let key = sound_key_from_value(&id_val)?;
            let pos = s.borrow().mixer.get_source_position(key);
            Ok((pos[0], pos[1], pos[2]))
        })?,
    )?;
    // -- setVelocity --
    /// Sets the velocity of a source for Doppler effect calculations.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    /// @param | x | number | X velocity component.
    /// @param | y | number | Y velocity component.
    /// @param | z | number? | Z velocity component (defaults to 0).
    let s = state.clone();
    tbl.set(
        "setVelocity",
        lua.create_function(
            move |_, (id_val, x, y, z): (LuaValue, f32, f32, Option<f32>)| {
                let key = sound_key_from_value(&id_val)?;
                s.borrow_mut()
                    .mixer
                    .set_source_velocity(key, x, y, z.unwrap_or(0.0));
                Ok(())
            },
        )?,
    )?;
    // -- getVelocity --
    /// Returns the velocity vector of a source.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    /// @return | number, number, number | X, Y, and Z velocity components.
    let s = state.clone();
    tbl.set(
        "getVelocity",
        lua.create_function(move |_, id_val: LuaValue| {
            let key = sound_key_from_value(&id_val)?;
            let vel = s.borrow().mixer.get_source_velocity(key);
            Ok((vel[0], vel[1], vel[2]))
        })?,
    )?;
    // -- setOrientation --
    /// Sets the orientation of a source using forward and up vectors.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    /// @param | fx | number | Forward vector X.
    /// @param | fy | number | Forward vector Y.
    /// @param | fz | number | Forward vector Z.
    /// @param | ux | number | Up vector X.
    /// @param | uy | number | Up vector Y.
    /// @param | uz | number | Up vector Z.
    let s = state.clone();
    tbl.set(
        "setOrientation",
        lua.create_function(
            move |_, (id_val, fx, fy, fz, ux, uy, uz): (LuaValue, f32, f32, f32, f32, f32, f32)| {
                let key = sound_key_from_value(&id_val)?;
                s.borrow_mut()
                    .mixer
                    .set_source_orientation(key, fx, fy, fz, ux, uy, uz);
                Ok(())
            },
        )?,
    )?;
    // -- getOrientation --
    /// Returns the orientation vectors of a source.
    /// @param | source | LSource|integer | Audio source or numeric source ID.
    /// @return | number, number, number, number, number, number | Forward (fx,fy,fz) and up (ux,uy,uz) vectors.
    let s = state.clone();
    tbl.set(
        "getOrientation",
        lua.create_function(move |_, id_val: LuaValue| {
            let key = sound_key_from_value(&id_val)?;
            let o = s.borrow().mixer.get_source_orientation(key);
            Ok((o[0], o[1], o[2], o[3], o[4], o[5]))
        })?,
    )?;
    // -- setDopplerScale --
    /// Sets the global Doppler effect intensity multiplier.
    /// @param | scale | number | Doppler scale (0 = disabled, 1.0 = realistic).
    let s = state.clone();
    tbl.set(
        "setDopplerScale",
        lua.create_function(move |_, scale: f32| {
            s.borrow_mut().mixer.set_doppler_scale(scale);
            Ok(())
        })?,
    )?;
    // -- getDopplerScale --
    /// Returns the current global Doppler effect scale.
    /// @return | number | Doppler scale factor.
    let s = state.clone();
    tbl.set(
        "getDopplerScale",
        lua.create_function(move |_, ()| Ok(s.borrow().mixer.get_doppler_scale()))?,
    )?;
    // -- setDistanceModel --
    /// Sets the distance attenuation model for spatial audio.
    /// @param | model | string | Model name (e.g. "inverse", "linear", "exponent", "none").
    let s = state.clone();
    tbl.set(
        "setDistanceModel",
        lua.create_function(move |_, model: String| {
            s.borrow_mut().mixer.set_distance_model(&model);
            Ok(())
        })?,
    )?;
    // -- getDistanceModel --
    /// Returns the current distance attenuation model name.
    /// @return | string | Distance model name.
    let s = state.clone();
    tbl.set(
        "getDistanceModel",
        lua.create_function(move |_, ()| Ok(s.borrow().mixer.get_distance_model().to_string()))?,
    )?;
    // -- setMeter --
    /// Sets the master peak level for metering purposes.
    /// @param | level | number | Peak level clamped to 0.0-1.0.
    let s = state.clone();
    tbl.set(
        "setMeter",
        lua.create_function(move |_, level: f32| {
            s.borrow_mut().mixer.master_peak = level.clamp(0.0, 1.0);
            Ok(())
        })?,
    )?;
    // -- getMeter --
    /// Returns the current master peak level for VU-meter displays.
    /// @return | number | Peak level from 0.0 to 1.0.
    let s = state.clone();
    tbl.set(
        "getMeter",
        lua.create_function(move |_, ()| Ok(s.borrow().mixer.master_peak))?,
    )?;
    // -- newMidiPlayer --
    /// Creates a new MIDI player instance, optionally loading a file immediately.
    /// @param | path | string? | Optional relative path to a .mid file to load.
    /// @return | LMidiPlayer | A new MIDI player ready for playback.
    let s = state.clone();
    tbl.set(
        "newMidiPlayer",
        lua.create_function(move |_, path| helper_new_midi_player(s.clone(), path))?,
    )?;
    // -- newSoundData --
    /// Creates a new SoundData object from a file path or blank buffer for procedural audio.
    /// @param | pathOrCount | string|integer | File path to decode, or sample count for blank buffer.
    /// @param | sampleRate | integer | Sample rate in Hz (e.g. 44100, 48000).
    /// @param | channels | integer? | Channel count (1 = mono, 2 = stereo), defaults to 1.
    /// @return | LSoundData | Raw PCM sample data for manipulation or playback.
    let s = state.clone();
    tbl.set(
        "newSoundData",
        lua.create_function(move |lua, args: LuaMultiValue| {
            let (path_opt, count, rate, channels) = extract_sound_data_args(args)?;
            let full_path_buf = path_opt.as_ref().map(|p| s.borrow().game_dir.join(p));
            let full_path = full_path_buf.as_ref().and_then(|p| p.to_str());
            let sd = SoundData::from_lua_args(full_path, count, rate, channels)
                .map_err(LuaError::RuntimeError)?;
            lua.create_userdata(sd)
        })?,
    )?;
    let s = state.clone();
    /// Sets the SoundFont file used for MIDI synthesis.
    /// @param | path | string | Relative path to the .sf2 SoundFont file.
    tbl.set(
        "setMidiSoundFont",
        lua.create_function(move |_, path: String| {
            let mut st = s.borrow_mut();
            let full_path = st.game_dir.join(&path);
            let data = std::fs::read(&full_path).map_err(|e| {
                LuaError::RuntimeError(format!(
                    "Failed to read SoundFont '{}': {}",
                    full_path.display(),
                    e
                ))
            })?;
            st.midi_state
                .set_soundfont(data, Some(path))
                .map_err(LuaError::RuntimeError)
        })?,
    )?;
    let s = state.clone();
    /// Returns whether a SoundFont file has been loaded for MIDI synthesis.
    /// @return | boolean | True if a SoundFont is loaded.
    tbl.set(
        "hasMidiSoundFont",
        lua.create_function(move |_, ()| Ok(s.borrow().midi_state.has_soundfont()))?,
    )?;
    let s = state.clone();
    /// Clears the loaded SoundFont and reverts MIDI synthesis to default.
    tbl.set(
        "clearMidiSoundFont",
        lua.create_function(move |_, ()| {
            s.borrow_mut().midi_state.clear_soundfont();
            Ok(())
        })?,
    )?;
    let s = state.clone();
    /// Creates a streaming audio decoder for the given file. The file is opened relative to the game directory.
    /// @param | source | string | Relative path to the audio file (WAV, OGG, MP3, or FLAC).
    /// @param | buffersize | integer? | Number of samples per decode chunk; defaults to 2048.
    /// @return | LDecoder | A streaming decoder with `decode`, `seek`, `rewind`, and `getSampleRate` methods.
    tbl.set(
        "newDecoder",
        lua.create_function(move |_, (source, buffersize): (String, Option<usize>)| {
            let st = s.borrow();
            let path = st.game_dir.join(&source);
            let path_str = path
                .to_str()
                .ok_or_else(|| LuaError::RuntimeError("Invalid path".to_string()))?;
            let buf = buffersize.unwrap_or(2048);
            let decoder = Decoder::from_file(path_str, buf)
                .map_err(|e| LuaError::RuntimeError(e.to_string()))?;
            Ok(LuaDecoder { inner: decoder })
        })?,
    )?;
    let s = state.clone();
    /// Creates a new queueable audio source for streaming PCM data buffer by buffer.
    /// @param | sample_rate | integer | Sample rate in Hz (e.g. 44100).
    /// @param | bit_depth | integer | Bit depth per sample (8 or 16).
    /// @param | channels | integer | Channel count (1 = mono, 2 = stereo).
    /// @param | buffer_count | integer? | Number of internal buffers to pre-allocate; defaults to 4.
    /// @return | integer | An opaque integer handle for use with `queueSource`, `playQueueable`, and `stopQueueable`.
    tbl.set(
        "newQueueableSource",
        lua.create_function(
            move |_,
                  (sample_rate, bit_depth, channels, buffer_count): (
                u32,
                u8,
                u8,
                Option<usize>,
            )| {
                let buf = buffer_count.unwrap_or(4);
                let key = s
                    .borrow_mut()
                    .mixer
                    .new_queueable(sample_rate, bit_depth, channels, buf);
                Ok(slotmap::Key::data(&key).as_ffi())
            },
        )?,
    )?;
    let s = state.clone();
    /// Queues a decoded audio chunk for playback on a queueable source.
    /// @param | qsource_id | integer | Queueable source handle returned by `newQueueableSource`.
    /// @param | sd | LSoundData | Sound data chunk to enqueue for playback.
    tbl.set(
        "queueSource",
        lua.create_function(move |_, (qsource_id, sd): (u64, mlua::AnyUserData)| {
            let key = queueable_key_from_u64(qsource_id);
            let sd_ref = sd.borrow::<SoundData>()?;
            s.borrow_mut()
                .mixer
                .queue_buffer(key, sd_ref.samples())
                .map_err(|e| LuaError::RuntimeError(e.to_string()))
        })?,
    )?;
    let s = state.clone();
    /// Returns the number of free (available) buffer slots on a queueable source.
    /// @param | qsource_id | integer | Queueable source handle returned by `newQueueableSource`.
    /// @return | integer | Number of free buffer slots available for queuing.
    tbl.set(
        "getFreeBufferCount",
        lua.create_function(move |_, qsource_id: u64| {
            let key = queueable_key_from_u64(qsource_id);
            Ok(s.borrow().mixer.queueable_free_buffer_count(key) as u32)
        })?,
    )?;
    let s = state.clone();
    /// Starts playback of a queueable audio source.
    /// @param | qsource_id | integer | Queueable source handle returned by newQueueableSource.
    tbl.set(
        "playQueueable",
        lua.create_function(move |_, qsource_id: u64| {
            let key = queueable_key_from_u64(qsource_id);
            s.borrow_mut().mixer.play_queueable(key);
            Ok(())
        })?,
    )?;
    let s = state.clone();
    /// Stops playback of a queueable audio source.
    /// @param | qsource_id | integer | Queueable source handle returned by newQueueableSource.
    tbl.set(
        "stopQueueable",
        lua.create_function(move |_, qsource_id: u64| {
            let key = queueable_key_from_u64(qsource_id);
            s.borrow_mut().mixer.stop_queueable(key);
            Ok(())
        })?,
    )?;
    /// Returns a list of available audio playback device names.
    /// @return | string[] | Device name strings.
    tbl.set(
        "getPlaybackDevices",
        lua.create_function(|lua, ()| helper_get_playback_devices(lua))?,
    )?;
    /// Returns the name of the currently active audio playback device.
    /// @return | string | Current playback device name.
    tbl.set(
        "getPlaybackDevice",
        lua.create_function(|_, ()| Ok(crate::audio::get_playback_device()))?,
    )?;
    /// Sets the active audio playback device by name.
    /// @param | name | string | Name of the playback device to activate.
    tbl.set(
        "setPlaybackDevice",
        lua.create_function(|_, name: String| {
            crate::audio::set_playback_device(&name)
                .map_err(|e| LuaError::RuntimeError(e.to_string()))
        })?,
    )?;
    let s = state.clone();
    /// Creates a named audio bus, optionally parented to another bus.
    /// @param | name | string | Unique name for the new bus.
    /// @param | parent_name | string? | Name of the parent bus, or nil for a root bus.
    tbl.set(
        "create_bus",
        lua.create_function(move |_, args| helper_create_bus(s.clone(), args))?,
    )?;

    /// Sets the volume of a named audio bus.
    /// @param | name | string | Name of the audio bus.
    /// @param | volume | number | Volume level (0.0 = silent, 1.0 = full, >1.0 = boost).
    let s = state.clone();
    tbl.set(
        "set_bus_volume",
        lua.create_function(move |_, args| helper_set_bus_volume(s.clone(), args))?,
    )?;
    /// Mixes the samples of `src` into `dest` in-place (both must have the same format).
    /// @param | dest_ud | LSoundData | Destination sound data to mix into.
    /// @param | src_ud | LSoundData | Source sound data to mix from.
    tbl.set(
        "mixInto",
        lua.create_function(|_, args| helper_mix_into(args))?,
    )?;
    let s = state.clone();
    /// Encodes the sound data as a WAV file and saves it to the given path (relative to game dir).
    /// @param | sd_ud | LSoundData | The sound data to encode and save.
    /// @param | filename | string | Relative output path for the WAV file.
    tbl.set(
        "saveWAV",
        lua.create_function(move |_, args| helper_save_wav(s.clone(), args))?,
    )?;
    let s = state.clone();
    /// Sets the stereo width of an audio source (0.0 = mono, 1.0 = full stereo).
    /// @param | src_ud | LSource | The audio source to adjust.
    /// @param | width | number | Stereo width factor (0.0 = mono, 1.0 = full stereo).
    tbl.set(
        "setStereoWidth",
        lua.create_function(move |_, (src_ud, width): (LuaAnyUserData, f32)| {
            let key = src_ud
                .borrow::<LuaSource>()
                .map_err(|_| LuaError::RuntimeError("argument must be an AudioSource".into()))?
                .key;
            s.borrow_mut()
                .mixer
                .set_stereo_width(key, width)
                .map_err(LuaError::external)
        })?,
    )?;
    let s = state.clone();
    /// Returns the current stereo width factor of an audio source.
    /// @param | src_ud | LSource | The audio source to query.
    /// @return | number | Stereo width factor (0.0 = mono, 1.0 = full stereo).
    tbl.set(
        "getStereoWidth",
        lua.create_function(move |_, src_ud: LuaAnyUserData| {
            let key = src_ud
                .borrow::<LuaSource>()
                .map_err(|_| LuaError::RuntimeError("argument must be an AudioSource".into()))?
                .key;
            s.borrow()
                .mixer
                .get_stereo_width(key)
                .map_err(LuaError::external)
        })?,
    )?;
    let s = state.clone();
    /// Sets a random pitch range for a source; each play picks a random pitch between min and max.
    /// @param | src_ud | LSource | The audio source to configure.
    /// @param | min | number | Minimum pitch multiplier.
    /// @param | max | number | Maximum pitch multiplier.
    tbl.set(
        "setRandomPitch",
        lua.create_function(move |_, (src_ud, min, max): (LuaAnyUserData, f32, f32)| {
            let key = src_ud
                .borrow::<LuaSource>()
                .map_err(|_| LuaError::RuntimeError("argument must be an AudioSource".into()))?
                .key;
            s.borrow_mut()
                .mixer
                .set_random_pitch(key, min, max)
                .map_err(LuaError::external)
        })?,
    )?;
    let s = state.clone();
    /// Clears any random pitch range previously set on the source.
    /// @param | src_ud | LSource | The audio source to reset.
    tbl.set(
        "clearRandomPitch",
        lua.create_function(move |_, src_ud: LuaAnyUserData| {
            let key = src_ud
                .borrow::<LuaSource>()
                .map_err(|_| LuaError::RuntimeError("argument must be an AudioSource".into()))?
                .key;
            s.borrow_mut().mixer.clear_random_pitch(key);
            Ok(())
        })?,
    )?;
    let s = state.clone();
    /// Crossfades from one audio source to another over the given duration.
    /// @param | from_ud | LSource | The source to fade out.
    /// @param | to_ud | LSource | The source to fade in.
    /// @param | duration | number | Crossfade duration in seconds.
    tbl.set(
        "crossfade",
        lua.create_function(move |_, args| helper_crossfade(s.clone(), args))?,
    )?;
    let s = state.clone();
    /// Returns the peak amplitude of the named audio bus over the last processing frame.
    /// @param | bus_name | string | Name of the audio bus to query.
    /// @return | number | Peak amplitude in the range [0.0, 1.0+].
    tbl.set(
        "getBusPeak",
        lua.create_function(move |_, bus_name: String| {
            s.borrow()
                .mixer
                .get_bus_peak(&bus_name)
                .map_err(LuaError::external)
        })?,
    )?;
    let s = state.clone();
    /// Returns the RMS (root mean square) amplitude of the named audio bus over the last processing frame.
    /// @param | bus_name | string | Name of the audio bus to query.
    /// @return | number | RMS amplitude in the range [0.0, 1.0+].
    tbl.set(
        "getBusRms",
        lua.create_function(move |_, bus_name: String| {
            s.borrow()
                .mixer
                .get_bus_rms(&bus_name)
                .map_err(LuaError::external)
        })?,
    )?;
    let s = state.clone();
    /// Creates a polyphonic sound pool that allows the same audio file to play on multiple simultaneous voices.
    /// @param | file_path | string | Relative path to the audio file shared by all voices in the pool.
    /// @param | voice_count | integer | Number of concurrent voices to pre-allocate.
    /// @return | LSoundPool | A sound pool with `play`, `stopAll`, `setVolume`, `release`, and `getVoiceCount` methods.
    tbl.set(
        "newPool",
        lua.create_function(move |_, (file_path, voice_count): (String, usize)| {
            let pool = s
                .borrow_mut()
                .mixer
                .new_pool(&file_path, voice_count)
                .map_err(LuaError::external)?;
            Ok(LuaSoundPool {
                pool,
                state: s.clone(),
            })
        })?,
    )?;
    // -- newBeatClock --
    /// Creates a musical beat clock for rhythm-game timing, tap-tempo, and beat scheduling.
    /// @param | bpm | number | Initial beats-per-minute (minimum 1).
    /// @param | beats_per_bar_or_opts | any | Beats per bar (legacy) or options table.
    /// @param | opts | table? | Optional options table when second argument is numeric.
    /// @return | LBeatClock | New beat clock handle.
    let s = state.clone();
    tbl.set(
        "newBeatClock",
        lua.create_function(move |lua, args: LuaMultiValue| {
            let (bpm, beats_per_bar, opts) = parse_new_beat_clock_args(args)?;
            let mut inner = crate::audio::BeatClock::new_with_opts(bpm, beats_per_bar, opts);
            let windows = *default_beat_windows().lock().map_err(|_| {
                LuaError::RuntimeError("newBeatClock: windows lock poisoned".into())
            })?;
            inner.set_judgement_windows(windows);
            lua.create_userdata(LuaBeatClock {
                inner: std::cell::RefCell::new(inner),
                state: s.clone(),
                scheduler: std::cell::RefCell::new(BeatScheduler::default()),
            })
        })?,
    )?;
    let s = state.clone();
    // -- beatClockFromSource --
    /// Creates a new beat clock and synchronizes it to an audio source position.
    /// @param | source | LSource|integer | Source handle or numeric source id.
    /// @param | bpm | number | Initial BPM.
    /// @param | opts | table? | Optional beat clock options.
    /// @return | LBeatClock | New beat clock handle synced to source time.
    tbl.set(
        "beatClockFromSource",
        lua.create_function(
            move |lua, (source, bpm, opts): (LuaValue, f64, Option<LuaTable>)| {
                let mut inner =
                    crate::audio::BeatClock::new_with_opts(bpm, 4, parse_beat_clock_opts(opts)?);
                let windows = *default_beat_windows().lock().map_err(|_| {
                    LuaError::RuntimeError("beatClockFromSource: windows lock poisoned".into())
                })?;
                inner.set_judgement_windows(windows);

                let st = s.borrow();
                let key = require_sound_key(&st, &source, "lurek.audio.beatClockFromSource")?;
                let pos = st.mixer.get_tell(key);
                inner.sync_to_position(pos as f64);

                lua.create_userdata(LuaBeatClock {
                    inner: std::cell::RefCell::new(inner),
                    state: s.clone(),
                    scheduler: std::cell::RefCell::new(BeatScheduler::default()),
                })
            },
        )?,
    )?;
    // -- setJudgementWindows --
    /// Sets global default timing windows used by beat-clock judgement.
    /// @param | windows | table | Table with optional `perfect`, `great`, `good` in seconds.
    tbl.set(
        "setJudgementWindows",
        lua.create_function(|_, windows: LuaTable| {
            let mut guard = default_beat_windows().lock().map_err(|_| {
                LuaError::RuntimeError("setJudgementWindows: windows lock poisoned".into())
            })?;
            if let Ok(v) = windows.get::<_, f64>("perfect") {
                guard.perfect = v.max(0.0);
            }
            if let Ok(v) = windows.get::<_, f64>("great") {
                guard.great = v.max(guard.perfect);
            }
            if let Ok(v) = windows.get::<_, f64>("good") {
                guard.good = v.max(guard.great);
            }
            Ok(())
        })?,
    )?;
    // -- getJudgementWindows --
    /// Returns global default timing windows used by beat-clock judgement.
    /// @return | table | Table with `perfect`, `great`, `good` in seconds.
    tbl.set(
        "getJudgementWindows",
        lua.create_function(|lua, ()| {
            let windows = *default_beat_windows().lock().map_err(|_| {
                LuaError::RuntimeError("getJudgementWindows: windows lock poisoned".into())
            })?;
            let out = lua.create_table()?;
            out.set("perfect", windows.perfect)?;
            out.set("great", windows.great)?;
            out.set("good", windows.good)?;
            Ok(out)
        })?,
    )?;
    // -- judgeBeat --
    /// Judges timing against the nearest beat grid for a beat clock.
    /// @param | clock | LBeatClock | Beat clock handle.
    /// @param | division | integer? | Beat division (defaults to clock subdivision).
    /// @param | hit_offset | number? | Signed hit offset in seconds.
    /// @return | string | One of `perfect`, `great`, `good`, `miss`.
    /// @return | number | Signed timing error in seconds.
    tbl.set(
        "judgeBeat",
        lua.create_function(
            |_, (clock_ud, division, hit_offset): (LuaAnyUserData, Option<u32>, Option<f64>)| {
                let clock = clock_ud.borrow::<LuaBeatClock>()?;
                let inner = clock.inner.borrow();
                let div = division.unwrap_or(inner.subdivision());
                let result = inner.judge(div, hit_offset.unwrap_or(0.0));
                let (label, err) = match result {
                    JudgementResult::Perfect(v) => ("perfect", v),
                    JudgementResult::Great(v) => ("great", v),
                    JudgementResult::Good(v) => ("good", v),
                    JudgementResult::Miss(v) => ("miss", v),
                };
                Ok((label.to_string(), err))
            },
        )?,
    )?;
    // -- setMuted --
    /// Globally mutes all audio (pauses all sources without stopping them).
    /// @param | muted | boolean | True to mute, false to unmute all audio.
    let s = state.clone();
    tbl.set(
        "setMuted",
        lua.create_function(move |_, muted: bool| {
            let mut st = s.borrow_mut();
            if muted {
                st.mixer.pause_all();
            } else {
                st.mixer.resume_all();
            }
            Ok(())
        })?,
    )?;
    // -- isMuted --
    /// Returns whether global audio is currently muted.
    /// @return | boolean | True if muted (all sources paused).
    let s = state.clone();
    tbl.set(
        "isMuted",
        lua.create_function(move |_, ()| {
            let st = s.borrow();
            // Note: mixer doesn't track global mute state directly,
            // so we check if there are active sources and assume muted if none playing
            Ok(st.mixer.get_active_source_count() == 0)
        })?,
    )?;
    // -- stopMusic --
    /// Stops all music sources with optional fade-out.
    /// @param | fade_duration | number? | Fade-out duration in seconds (default: 0.0).
    let s = state.clone();
    tbl.set(
        "stopMusic",
        lua.create_function(move |_, fade_duration: Option<f32>| {
            let mut st = s.borrow_mut();
            let _duration = fade_duration.unwrap_or(0.0).max(0.0);
            // Stop all sources with "music" bus or all sources if no bus filtering
            st.mixer.stop_all();
            Ok(())
        })?,
    )?;
    // -- playSfx --
    /// Plays a one-shot sound effect from a file path with optional settings.
    /// @param | path | string | Path to audio file.
    /// @param | opts | table? | Optional: `bus` (string), `volume` (0.0-1.0), `loop` (bool).
    /// @return | LSource | The audio source handle for the playing effect.
    let s = state.clone();
    tbl.set(
        "playSfx",
        lua.create_function(move |_, (path, opts): (String, Option<LuaTable>)| {
            let mut st = s.borrow_mut();
            let key = st.mixer.load_source(&path, SourceType::Static);

            // Apply options if provided
            if let Some(options) = opts {
                if let Ok(volume) = options.get::<_, f32>("volume") {
                    st.mixer.set_volume(key, volume.clamp(0.0, 2.0));
                }
                if let Ok(looping) = options.get::<_, bool>("loop") {
                    st.mixer.set_looping(key, looping);
                }
                if let Ok(bus_name) = options.get::<_, String>("bus") {
                    if let Some(bus) = st.mixer.get_bus_by_name(&bus_name) {
                        st.mixer.set_source_bus(key, Some(bus));
                    }
                }
            }

            // Play immediately
            let game_dir = st.game_dir.clone();
            st.mixer.play(key, &game_dir);

            Ok(LuaSource {
                state: s.clone(),
                key,
            })
        })?,
    )?;

    // ——— lurek.audio.manager sub-table ——————————————————————————————————
    // Provides high-level music/SFX group controls as lurek.audio.manager.*
    let mgr = lua.create_table()?;
    // -- manager.playMusic(path, opts?) --
    /// Plays a music track, routing through a named group with optional fade-in.
    /// @param | path | string | Path to audio file.
    /// @param | opts | table? | Optional: `group` (string), `fadeIn` (number seconds).
    // NOTE: Broken playMusic implementation removed; use lurek.audio.play() with stream source type instead
    // mgr.set(
    //     "playMusic",
    //     lua.create_function(move |_, (path, opts): (String, Option<LuaTable>)| {
    //         // TODO: implement proper music playback with group/fadeIn support
    //         Ok(())
    //     })?,
    // )?;

    // NOTE: Broken setGroupVolume implementation removed; use lurek.audio.setBusVolume() instead
    // let s = state.clone();
    // mgr.set(
    //     "setGroupVolume",
    //     lua.create_function(move |_, (group, vol): (String, f32)| {
    //         // TODO: implement proper bus volume control
    //         Ok(())
    //     })?,
    // )?;
    // -- manager.pauseAll() --
    /// Pauses all active audio sources.
    let s = state.clone();
    mgr.set(
        "pauseAll",
        lua.create_function(move |_, ()| {
            s.borrow_mut().mixer.pause_all();
            Ok(())
        })?,
    )?;
    // -- manager.resumeAll() --
    /// Resumes all paused audio sources.
    let s = state.clone();
    mgr.set(
        "resumeAll",
        lua.create_function(move |_, ()| {
            s.borrow_mut().mixer.resume_all();
            Ok(())
        })?,
    )?;
    tbl.set("manager", mgr)?;

    lurek.set("audio", tbl)?;
    Ok(())
}

enum BeatScheduleKind {
    At { beat: f64, fired: bool },
    Every { division: u32 },
    Pattern { slots: Vec<bool> },
}

struct BeatScheduleEntry {
    id: u64,
    callback: LuaRegistryKey,
    kind: BeatScheduleKind,
    cancelled: bool,
}

enum BeatScheduleCall {
    Beat { id: u64, beat: f64 },
    Step { id: u64, step_index: i64 },
}

#[derive(Default)]
struct BeatScheduler {
    next_id: u64,
    entries: Vec<BeatScheduleEntry>,
}

impl BeatScheduler {
    fn alloc_id(&mut self) -> u64 {
        self.next_id = self.next_id.saturating_add(1);
        self.next_id
    }

    fn add_at(&mut self, beat: f64, callback: LuaRegistryKey) -> u64 {
        let id = self.alloc_id();
        self.entries.push(BeatScheduleEntry {
            id,
            callback,
            kind: BeatScheduleKind::At { beat, fired: false },
            cancelled: false,
        });
        id
    }

    fn add_every(&mut self, division: u32, callback: LuaRegistryKey) -> u64 {
        let id = self.alloc_id();
        self.entries.push(BeatScheduleEntry {
            id,
            callback,
            kind: BeatScheduleKind::Every {
                division: division.max(1),
            },
            cancelled: false,
        });
        id
    }

    fn add_pattern(&mut self, slots: Vec<bool>, callback: LuaRegistryKey) -> u64 {
        let id = self.alloc_id();
        self.entries.push(BeatScheduleEntry {
            id,
            callback,
            kind: BeatScheduleKind::Pattern { slots },
            cancelled: false,
        });
        id
    }

    fn cancel(&mut self, id: u64) -> bool {
        if let Some(entry) = self.entries.iter_mut().find(|entry| entry.id == id) {
            entry.cancelled = true;
            return true;
        }
        false
    }

    fn cancel_all(&mut self) {
        for entry in &mut self.entries {
            entry.cancelled = true;
        }
    }

    fn collect_pending(&mut self, before: f64, after: f64) -> Vec<BeatScheduleCall> {
        if after <= before {
            return Vec::new();
        }

        let mut calls = Vec::new();
        for entry in &mut self.entries {
            if entry.cancelled {
                continue;
            }
            match &mut entry.kind {
                BeatScheduleKind::At { beat, fired } => {
                    if !*fired && *beat > before && *beat <= after {
                        *fired = true;
                        entry.cancelled = true;
                        calls.push(BeatScheduleCall::Beat {
                            id: entry.id,
                            beat: *beat,
                        });
                    }
                }
                BeatScheduleKind::Every { division } => {
                    let steps = crate::audio::BeatClock::crossed_steps(before, after, *division);
                    for step in steps {
                        calls.push(BeatScheduleCall::Step {
                            id: entry.id,
                            step_index: step,
                        });
                    }
                }
                BeatScheduleKind::Pattern { slots } => {
                    let len = slots.len() as i64;
                    if len <= 0 {
                        continue;
                    }
                    let steps = crate::audio::BeatClock::crossed_steps(before, after, len as u32);
                    for step in steps {
                        let slot_index = (step - 1).rem_euclid(len) as usize;
                        if slots.get(slot_index).copied().unwrap_or(false) {
                            calls.push(BeatScheduleCall::Step {
                                id: entry.id,
                                step_index: slot_index as i64 + 1,
                            });
                        }
                    }
                }
            }
        }

        calls
    }

    fn sweep_cancelled(&mut self) {
        self.entries.retain(|entry| !entry.cancelled);
    }
}

fn beat_schedule_handle_id(handle: LuaValue) -> LuaResult<u64> {
    match handle {
        LuaValue::Integer(id) if id > 0 => Ok(id as u64),
        LuaValue::Number(id) if id > 0.0 => Ok(id as u64),
        LuaValue::Table(tbl) => {
            let id: u64 = tbl.get("id")?;
            if id == 0 {
                Err(LuaError::RuntimeError(
                    "LBeatClock:cancel expects handle.id > 0".into(),
                ))
            } else {
                Ok(id)
            }
        }
        _ => Err(LuaError::RuntimeError(
            "LBeatClock:cancel expects a scheduling handle or numeric id".into(),
        )),
    }
}

fn beat_pattern_slots(pattern: &str) -> LuaResult<Vec<bool>> {
    let slots = pattern
        .chars()
        .filter_map(|ch| match ch {
            'x' | 'X' | '1' | '*' => Some(true),
            '.' | '_' | '-' | '0' => Some(false),
            _ if ch.is_whitespace() => None,
            _ => None,
        })
        .collect::<Vec<bool>>();

    if slots.is_empty() {
        Err(LuaError::RuntimeError(
            "LBeatClock:pattern expects a non-empty pattern like 'x.x.'".into(),
        ))
    } else {
        Ok(slots)
    }
}

fn beat_schedule_handle(lua: &Lua, id: u64) -> LuaResult<LuaTable<'_>> {
    let handle = lua.create_table()?;
    handle.set("id", id)?;
    Ok(handle)
}

/// Lua-side wrapper for a musical beat clock.
pub struct LuaBeatClock {
    /// Owned beat clock state.
    inner: std::cell::RefCell<crate::audio::BeatClock>,
    /// Shared runtime state for optional source syncing.
    state: Rc<RefCell<SharedState>>,
    /// Callback scheduler for `every`, `at`, and `pattern` helpers.
    scheduler: std::cell::RefCell<BeatScheduler>,
}

/// Provides Lua methods for beat-based timing.
impl LuaUserData for LuaBeatClock {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- start --
        /// Starts beat-clock playback so scheduled beat callbacks can begin firing.
        methods.add_method("start", |_, this, ()| {
            this.inner.borrow_mut().start();
            Ok(())
        });
        // -- stop --
        /// Stops beat-clock playback while preserving the current musical position.
        methods.add_method("stop", |_, this, ()| {
            this.inner.borrow_mut().stop();
            Ok(())
        });
        // -- reset --
        /// Resets elapsed time to zero without changing running state.
        methods.add_method("reset", |_, this, ()| {
            this.inner.borrow_mut().reset();
            Ok(())
        });
        // -- tick --
        /// Advances the clock by `dt` seconds. Returns an array of whole-beat crossings.
        /// @param | dt | number | Delta time in seconds.
        /// @return | table | Array of beat numbers crossed during this tick.
        methods.add_method("tick", |lua, this, dt: f64| {
            let crossings = this.inner.borrow_mut().tick(dt);
            let out = lua.create_table()?;
            for (i, b) in crossings.into_iter().enumerate() {
                out.set(i + 1, b)?;
            }
            Ok(out)
        });
        // -- update --
        /// Advances the clock by `dt` seconds and returns beat/bar transitions.
        /// @param | dt | number | Delta time in seconds.
        /// @return | table | Table with optional `beat` and `bar` integer fields.
        methods.add_method("update", |lua, this, dt: f64| {
            let (events, before_beat, after_beat) = {
                let mut inner = this.inner.borrow_mut();
                let before = inner.get_beat();
                let events = inner.update(dt);
                let after = inner.get_beat();
                (events, before, after)
            };

            let pending = this
                .scheduler
                .borrow_mut()
                .collect_pending(before_beat, after_beat);
            for call in pending {
                match call {
                    BeatScheduleCall::Beat { id, beat } => {
                        let callback = {
                            let scheduler = this.scheduler.borrow();
                            scheduler
                                .entries
                                .iter()
                                .find(|entry| entry.id == id)
                                .map(|entry| lua.registry_value::<LuaFunction>(&entry.callback))
                        };
                        if let Some(callback) = callback {
                            callback?.call::<_, ()>(beat)?;
                        }
                    }
                    BeatScheduleCall::Step { id, step_index } => {
                        let callback = {
                            let scheduler = this.scheduler.borrow();
                            scheduler
                                .entries
                                .iter()
                                .find(|entry| entry.id == id)
                                .map(|entry| lua.registry_value::<LuaFunction>(&entry.callback))
                        };
                        if let Some(callback) = callback {
                            callback?.call::<_, ()>(step_index)?;
                        }
                    }
                }
            }

            this.scheduler.borrow_mut().sweep_cancelled();

            let out = lua.create_table()?;
            if let Some(beat) = events.new_beat {
                out.set("beat", beat)?;
            }
            if let Some(bar) = events.new_bar {
                out.set("bar", bar)?;
            }
            Ok(out)
        });
        // -- position --
        /// Returns the current beat position.
        /// @return | table | Table with `beat`, `bar`, `beat_in_bar`, `phase` fields.
        methods.add_method("position", |lua, this, ()| {
            let pos = this.inner.borrow().position();
            let t = lua.create_table()?;
            t.set("beat", pos.beat)?;
            t.set("bar", pos.bar)?;
            t.set("beat_in_bar", pos.beat_in_bar)?;
            t.set("phase", pos.phase)?;
            Ok(t)
        });
        // -- bpm --
        /// Returns the current tempo as beats-per-minute for this clock.
        /// @return | number | Beats-per-minute.
        methods.add_method("bpm", |_, this, ()| Ok(this.inner.borrow().bpm()));
        // -- getBpm --
        /// Returns the current tempo as beats-per-minute for this clock.
        /// @return | number | Beats-per-minute.
        methods.add_method("getBpm", |_, this, ()| Ok(this.inner.borrow().bpm()));
        // -- setBpm --
        /// Sets a new BPM. Elapsed time is preserved.
        /// @param | bpm | number | New BPM (clamped to â‰Ą1).
        methods.add_method("setBpm", |_, this, bpm: f64| {
            this.inner.borrow_mut().set_bpm(bpm);
            Ok(())
        });
        // -- rampBpm --
        /// Ramps BPM linearly to a target value over time.
        /// @param | target | number | Target BPM.
        /// @param | seconds | number | Ramp duration in seconds.
        methods.add_method("rampBpm", |_, this, (target, seconds): (f64, f64)| {
            this.inner.borrow_mut().ramp_bpm(target, seconds);
            Ok(())
        });
        // -- setSwing --
        /// Sets rhythmic swing amount in `[0.0, 0.5]` for off-beat timing feel.
        /// @param | amount | number | Swing amount.
        methods.add_method("setSwing", |_, this, amount: f64| {
            this.inner.borrow_mut().set_swing(amount);
            Ok(())
        });
        // -- beatsPerBar --
        /// Returns the number of beats per bar.
        /// @return | integer | Beats per bar.
        methods.add_method("beatsPerBar", |_, this, ()| {
            Ok(this.inner.borrow().beats_per_bar())
        });
        // -- setBeatsPerBar --
        /// Changes the time-signature beats-per-bar.
        /// @param | beats | integer | New beats per bar (clamped to â‰Ą1).
        methods.add_method("setBeatsPerBar", |_, this, beats: u32| {
            this.inner.borrow_mut().set_beats_per_bar(beats);
            Ok(())
        });
        // -- getBeat --
        /// Returns fractional beat position.
        /// @return | number | Fractional beat.
        methods.add_method("getBeat", |_, this, ()| Ok(this.inner.borrow().get_beat()));
        // -- getBar --
        /// Returns the current fractional bar position across elapsed musical time.
        /// @return | number | Fractional bar.
        methods.add_method("getBar", |_, this, ()| Ok(this.inner.borrow().get_bar()));
        // -- getPhase --
        /// Returns phase within the current division in [0, 1).
        /// @param | division | integer? | Beat division.
        /// @return | number | Phase value.
        methods.add_method("getPhase", |_, this, division: Option<u32>| {
            let inner = this.inner.borrow();
            Ok(inner.get_phase(division.unwrap_or(inner.subdivision())))
        });
        // -- beatTimeRemaining --
        /// Returns seconds until the next division boundary.
        /// @param | division | integer? | Beat division.
        /// @return | number | Seconds remaining.
        methods.add_method("beatTimeRemaining", |_, this, division: Option<u32>| {
            let inner = this.inner.borrow();
            Ok(inner.beat_time_remaining(division.unwrap_or(inner.subdivision())))
        });
        // -- isOnBeat --
        /// Returns true when the clock is near a beat boundary.
        /// @param | division | integer? | Beat division.
        /// @param | tolerance | number? | Tolerance in seconds (default 0.05).
        /// @return | boolean | True when within tolerance.
        methods.add_method(
            "isOnBeat",
            |_, this, (division, tolerance): (Option<u32>, Option<f64>)| {
                let inner = this.inner.borrow();
                Ok(inner.is_on_beat(
                    division.unwrap_or(inner.subdivision()),
                    tolerance.unwrap_or(0.05),
                ))
            },
        );
        // -- nearestBeat --
        /// Returns nearest beat and signed timing error in seconds.
        /// @param | division | integer? | Beat division.
        /// @return | number, number | Nearest beat and signed error in seconds.
        methods.add_method("nearestBeat", |_, this, division: Option<u32>| {
            let inner = this.inner.borrow();
            Ok(inner.nearest_beat(division.unwrap_or(inner.subdivision())))
        });
        // -- tap --
        /// Records a tap-tempo tap at `wall_time_secs`. Returns the estimated BPM (0.0 when fewer than 2 taps).
        /// @param | wall_time_secs | number | Current real-world time in seconds.
        /// @return | number | Estimated BPM, or 0.0 when not enough taps.
        methods.add_method("tap", |_, this, t: f64| Ok(this.inner.borrow_mut().tap(t)));
        // -- every --
        /// Registers a callback fired on each crossed step of `division`.
        /// @param | division | integer | Beat division grid (e.g. 4 for quarter-beat steps).
        /// @param | fn | function | Callback receiving `step_index`.
        /// @return | table | Handle table usable with `cancel`.
        methods.add_method(
            "every",
            |lua, this, (division, callback): (u32, LuaFunction)| {
                let key = lua.create_registry_value(callback)?;
                let id = this.scheduler.borrow_mut().add_every(division, key);
                beat_schedule_handle(lua, id)
            },
        );
        // -- at --
        /// Registers a one-shot callback fired when `beat` is crossed.
        /// @param | beat | number | Beat value threshold.
        /// @param | fn | function | Callback receiving the scheduled beat.
        /// @return | table | Handle table usable with `cancel`.
        methods.add_method("at", |lua, this, (beat, callback): (f64, LuaFunction)| {
            let key = lua.create_registry_value(callback)?;
            let id = this.scheduler.borrow_mut().add_at(beat, key);
            beat_schedule_handle(lua, id)
        });
        // -- pattern --
        /// Registers a repeating pattern callback where `x` triggers and `.` skips.
        /// @param | pattern | string | Pattern string like `x.x.`.
        /// @param | fn | function | Callback receiving 1-based pattern step index.
        /// @return | table | Handle table usable with `cancel`.
        methods.add_method(
            "pattern",
            |lua, this, (pattern, callback): (String, LuaFunction)| {
                let slots = beat_pattern_slots(&pattern)?;
                let key = lua.create_registry_value(callback)?;
                let id = this.scheduler.borrow_mut().add_pattern(slots, key);
                beat_schedule_handle(lua, id)
            },
        );
        // -- cancel --
        /// Cancels a scheduled callback handle.
        /// @param | handle | any | Handle table returned by `every`/`at`/`pattern` or numeric id.
        /// @return | boolean | True when a schedule was cancelled.
        methods.add_method("cancel", |_, this, handle: LuaValue| {
            let id = beat_schedule_handle_id(handle)?;
            Ok(this.scheduler.borrow_mut().cancel(id))
        });
        // -- cancelAll --
        /// Cancels all scheduled callback handles registered on this clock.
        /// @return | boolean | Always true.
        methods.add_method("cancelAll", |_, this, ()| {
            this.scheduler.borrow_mut().cancel_all();
            Ok(true)
        });
        // -- scheduleAt --
        /// Schedules a one-shot event at `beat`. Returns true when the beat is in the future.
        /// @param | beat | number | Beat number to schedule.
        /// @return | boolean | True when scheduled.
        methods.add_method("scheduleAt", |_, this, beat: f64| {
            Ok(this.inner.borrow_mut().schedule_at(beat))
        });
        // -- drainFired --
        /// Returns and removes all scheduled beats that have now passed.
        /// @return | table | Array of fired beat numbers.
        methods.add_method("drainFired", |lua, this, ()| {
            let fired = this.inner.borrow_mut().drain_fired();
            let out = lua.create_table()?;
            for (i, b) in fired.into_iter().enumerate() {
                out.set(i + 1, b)?;
            }
            Ok(out)
        });
        // -- secondsPerBeat --
        /// Returns seconds-per-beat at the current BPM.
        /// @return | number | Seconds per beat.
        methods.add_method("secondsPerBeat", |_, this, ()| {
            Ok(this.inner.borrow().seconds_per_beat())
        });
        // -- secondsToNextBeat --
        /// Returns seconds until the next whole beat boundary.
        /// @return | number | Seconds until next beat.
        methods.add_method("secondsToNextBeat", |_, this, ()| {
            Ok(this.inner.borrow().seconds_to_next_beat())
        });
        // -- isRunning --
        /// Returns true when the clock is running.
        /// @return | boolean | Running state.
        methods.add_method("isRunning", |_, this, ()| {
            Ok(this.inner.borrow().is_running())
        });
        // -- syncToSource --
        /// Synchronizes beat position to an audio source playback position.
        /// @param | source | LSource|integer | Source handle or source id.
        methods.add_method("syncToSource", |_, this, source: LuaValue| {
            let st = this.state.borrow();
            let key = require_sound_key(&st, &source, "LBeatClock:syncToSource")?;
            let pos = st.mixer.get_tell(key);
            this.inner.borrow_mut().sync_to_position(pos as f64);
            Ok(())
        });
        // -- dump --
        /// Returns a snapshot of clock state for debug and HUDs.
        /// @return | table | Table with bpm, beat, bar, phase, and running.
        methods.add_method("dump", |lua, this, ()| {
            let inner = this.inner.borrow();
            let out = lua.create_table()?;
            out.set("bpm", inner.bpm())?;
            out.set("beat", inner.get_beat())?;
            out.set("bar", inner.get_bar())?;
            out.set("phase", inner.get_phase(inner.subdivision()))?;
            out.set("running", inner.is_running())?;
            Ok(out)
        });
        // -- quantise --
        /// Quantises `beat` to the nearest `grid` beat grid (static utility).
        /// @param | beat | number | Beat value to quantise.
        /// @param | grid | number | Grid size (e.g. 0.25 for 16th notes).
        /// @return | number | Quantised beat value.
        methods.add_method("quantise", |_, _, (beat, grid): (f64, f64)| {
            Ok(crate::audio::BeatClock::quantise(beat, grid))
        });
        // -- type --
        /// Returns the Lua-visible type name.
        /// @return | string | The string `LBeatClock`.
        methods.add_method("type", |_, _, ()| Ok("LBeatClock"));
        // -- typeOf --
        /// Returns whether this handle matches the given type name.
        /// @param | name | string | Type name to check.
        /// @return | boolean | True when matched.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LBeatClock" || name == "LObject")
        });
    }
}
/// Represents the Lua-visible LSoundData object exposed by this module.
impl mlua::UserData for SoundData {
    fn add_methods<'lua, M: mlua::UserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getSampleCount --
        /// Returns the total number of samples stored in this sound buffer.
        /// @return | integer | Total sample count.
        methods.add_method("getSampleCount", |_, this, ()| Ok(this.sample_count()));
        // -- getSampleRate --
        /// Returns the playback sample rate of this sound buffer.
        /// @return | integer | Sample rate in Hz.
        methods.add_method("getSampleRate", |_, this, ()| Ok(this.sample_rate()));
        // -- getChannelCount --
        /// Returns the number of audio channels stored in this sound buffer.
        /// @return | integer | Channel count.
        methods.add_method("getChannelCount", |_, this, ()| Ok(this.channel_count()));
        // -- getDuration --
        /// Returns the approximate playback duration of this sound buffer.
        /// @return | number | Duration in seconds.
        methods.add_method("getDuration", |_, this, ()| Ok(this.duration()));
        // -- getBitDepth --
        /// Returns the sample bit depth of this sound buffer.
        /// @return | integer | Bit depth per sample.
        methods.add_method("getBitDepth", |_, this, ()| Ok(this.bit_depth()));
        // -- getSample --
        /// Returns the sample value at the given zero-based sample index.
        /// @param | index | integer | Zero-based sample index.
        /// @return | number | Sample value at the requested index.
        methods.add_method("getSample", |_, this, index: usize| {
            this.get_sample(index).ok_or_else(|| {
                LuaError::RuntimeError(format!("Sample index {} out of bounds", index))
            })
        });

        // -- drawWaveform --
        /// Draws this sound buffer as a waveform into an image buffer.
        /// @param | target | LImageData | Target image to draw into.
        /// @param | x | integer | Left pixel coordinate.
        /// @param | y | integer | Top pixel coordinate.
        /// @param | w | integer | Waveform width in pixels.
        /// @param | h | integer | Waveform height in pixels.
        /// @param | r | integer | Red channel from 0 to 255.
        /// @param | g | integer | Green channel from 0 to 255.
        /// @param | b | integer | Blue channel from 0 to 255.
        /// @param | a | integer | Alpha channel from 0 to 255.
        methods.add_method(
            "drawWaveform",
            |_,
             this,
             (target, x, y, w, h, r, g, b, a): (
                mlua::AnyUserData,
                i32,
                i32,
                u32,
                u32,
                u8,
                u8,
                u8,
                u8,
            )| {
                let mut img = target.borrow_mut::<crate::image::ImageData>()?;
                this.draw_waveform(&mut img, x, y, w, h, r, g, b, a);
                Ok(())
            },
        );
        // -- setSample --
        /// Overwrites the sample value at the given zero-based sample index.
        /// @param | index | integer | Zero-based sample index.
        /// @param | value | number | New sample value.
        methods.add_method_mut("setSample", |_, this, (index, value): (usize, f32)| {
            if this.set_sample(index, value) {
                Ok(())
            } else {
                Err(LuaError::RuntimeError(format!(
                    "Sample index {} out of bounds",
                    index
                )))
            }
        });
        // -- type --
        /// Returns the type name of this object for runtime type-checking.
        /// @return | string | Always returns "LSoundData".
        methods.add_method("type", |_, _, ()| Ok("LSoundData"));
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to check (e.g. "LSoundData" or "Object").
        /// @return | boolean | True if this object matches the given type.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LSoundData" || name == "LObject")
        });
    }
}
