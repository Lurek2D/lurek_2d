//! `lurek.dsp` - Digital signal processing: effects, offline batch processing, and audio visualization.
use super::SharedState;
use crate::audio::sound_data::SoundData;
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;
/// Registers the `lurek.dsp` Lua API table.
pub fn register(lua: &Lua, lurek: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;
    // -- newEffectParams --
    /// Creates an effect parameter descriptor table for use with offline processing.
    /// @param | effectType | string | Effect type name (e.g. "lowpass", "reverb", "compressor").
    /// @param | p1 | number | Primary parameter value.
    /// @param | p2 | number | Secondary parameter value.
    /// @param | p3 | number | Tertiary parameter value.
    /// @return | table | Effect parameter descriptor table.
    tbl.set(
        "newEffectParams",
        lua.create_function(|lua, (typ, p1, p2, p3): (String, f32, f32, f32)| {
            let t = lua.create_table()?;
            t.set("type", typ)?;
            t.set("p1", p1)?;
            t.set("p2", p2)?;
            t.set("p3", p3)?;
            Ok(t)
        })?,
    )?;
    let s = state.clone();
    /// Processes an audio file offline through a chain of effects and writes the result to an output file.
    /// @param | input | string | Relative path to the input audio file.
    /// @param | output | string | Relative path for the output WAV file.
    /// @param | effects | table | Array of effect tables; each has `type` (string) and optional `p1`, `p2`, `p3` (number) fields.
    tbl.set(
        "processOffline",
        lua.create_function(
            move |_, (input, output, effects_tbl): (String, String, mlua::Table)| {
                if input.contains("..") || output.contains("..") {
                    return Err(LuaError::external("path traversal not allowed"));
                }
                let game_dir = s.borrow().game_dir.clone();
                let input_path = game_dir.join(&input).to_string_lossy().into_owned();
                let output_path = game_dir.join(&output).to_string_lossy().into_owned();
                let mut effects = Vec::new();
                for pair in effects_tbl.sequence_values::<mlua::Table>() {
                    let t = pair.map_err(LuaError::external)?;
                    let typ_str: String = t.get("type").unwrap_or_default();
                    let p1: f32 = t.get("p1").unwrap_or(1000.0);
                    let p2: f32 = t.get("p2").unwrap_or(1.0);
                    let p3: f32 = t.get("p3").unwrap_or(0.5);
                    use crate::dsp::EffectType;
                    let typ = match typ_str.as_str() {
                        "lowpass" => EffectType::Lowpass,
                        "highpass" => EffectType::Highpass,
                        "bandpass" => EffectType::Bandpass,
                        "reverb" => EffectType::Reverb,
                        "chorus" => EffectType::Chorus,
                        "notch" => EffectType::Notch,
                        "lowshelf" => EffectType::LowShelf,
                        "highshelf" => EffectType::HighShelf,
                        "bell_eq" => EffectType::BellEq,
                        "reverb2" => EffectType::Reverb2,
                        "flanger" => EffectType::Flanger,
                        "phaser" => EffectType::Phaser,
                        "distortion" => EffectType::Distortion,
                        "limiter" => EffectType::Limiter,
                        "compressor" => EffectType::Compressor,
                        other => {
                            return Err(LuaError::external(format!(
                                "unknown effect type: {}",
                                other
                            )))
                        }
                    };
                    effects.push(crate::dsp::OfflineEffect { typ, p1, p2, p3 });
                }
                crate::dsp::offline::process_offline(&input_path, &output_path, &effects)
                    .map_err(LuaError::external)
            },
        )?,
    )?;
    let s = state.clone();
    /// Normalizes an audio file to a target peak amplitude and saves the result.
    /// @param | input | string | Relative path to the input audio file.
    /// @param | output | string | Relative path for the output WAV file.
    /// @param | target | number | Target peak amplitude (e.g. 0.9 for headroom).
    tbl.set(
        "normalize",
        lua.create_function(move |_, (input, output, target): (String, String, f32)| {
            if input.contains("..") || output.contains("..") {
                return Err(LuaError::external("path traversal not allowed"));
            }
            let game_dir = s.borrow().game_dir.clone();
            let input_path = game_dir.join(&input).to_string_lossy().into_owned();
            let output_path = game_dir.join(&output).to_string_lossy().into_owned();
            crate::dsp::offline::normalize_file(&input_path, &output_path, target)
                .map_err(LuaError::external)
        })?,
    )?;
    let s = state.clone();
    /// Renders a waveform visualization of an audio file and saves it as a PNG image.
    /// @param | input | string | Relative path to the input audio file.
    /// @param | output | string | Relative path for the output PNG file.
    /// @param | width | integer | Image width in pixels.
    /// @param | height | integer | Image height in pixels.
    tbl.set(
        "waveformToPng",
        lua.create_function(
            move |_, (input, output, width, height): (String, String, u32, u32)| {
                if input.contains("..") || output.contains("..") {
                    return Err(LuaError::external("path traversal not allowed"));
                }
                let game_dir = s.borrow().game_dir.clone();
                let input_path = game_dir.join(&input).to_string_lossy().into_owned();
                let output_path = game_dir.join(&output).to_string_lossy().into_owned();
                crate::dsp::visualizer::waveform_to_png(&input_path, &output_path, width, height)
                    .map_err(LuaError::external)
            },
        )?,
    )?;
    let s = state.clone();
    /// Renders a spectrogram visualization of an audio file and saves it as a PNG image.
    /// @param | input | string | Relative path to the input audio file.
    /// @param | output | string | Relative path for the output PNG file.
    /// @param | width | integer | Image width in pixels.
    /// @param | height | integer | Image height in pixels.
    tbl.set(
        "spectrogramToPng",
        lua.create_function(
            move |_, (input, output, width, height): (String, String, u32, u32)| {
                if input.contains("..") || output.contains("..") {
                    return Err(LuaError::external("path traversal not allowed"));
                }
                let game_dir = s.borrow().game_dir.clone();
                let input_path = game_dir.join(&input).to_string_lossy().into_owned();
                let output_path = game_dir.join(&output).to_string_lossy().into_owned();
                crate::dsp::visualizer::spectrogram_to_png(
                    &input_path,
                    &output_path,
                    width,
                    height,
                )
                .map_err(LuaError::external)
            },
        )?,
    )?;
    // -- applyLowpass --
    /// Applies a lowpass filter in-place to the sound data.
    /// @param | sd_ud | LSoundData | The sound data to process.
    /// @param | cutoff_hz | number | Lowpass cutoff frequency in Hz.
    tbl.set(
        "applyLowpass",
        lua.create_function(|_, (sd_ud, cutoff_hz): (LuaAnyUserData, f32)| {
            let mut sd = sd_ud
                .borrow_mut::<SoundData>()
                .map_err(|_| LuaError::RuntimeError("lurek.dsp.applyLowpass: argument must be LSoundData".into()))?;
            sd.apply_lowpass(cutoff_hz);
            Ok(())
        })?,
    )?;
    // -- applyHighpass --
    /// Applies a highpass filter in-place to the sound data.
    /// @param | sd_ud | LSoundData | The sound data to process.
    /// @param | cutoff_hz | number | Highpass cutoff frequency in Hz.
    tbl.set(
        "applyHighpass",
        lua.create_function(|_, (sd_ud, cutoff_hz): (LuaAnyUserData, f32)| {
            let mut sd = sd_ud
                .borrow_mut::<SoundData>()
                .map_err(|_| LuaError::RuntimeError("lurek.dsp.applyHighpass: argument must be LSoundData".into()))?;
            sd.apply_highpass(cutoff_hz);
            Ok(())
        })?,
    )?;
    // -- applyBandpass --
    /// Applies a bandpass filter in-place to the sound data.
    /// @param | sd_ud | LSoundData | The sound data to process.
    /// @param | low_hz | number | Lower cutoff frequency in Hz.
    /// @param | high_hz | number | Upper cutoff frequency in Hz.
    tbl.set(
        "applyBandpass",
        lua.create_function(|_, (sd_ud, low_hz, high_hz): (LuaAnyUserData, f32, f32)| {
            let mut sd = sd_ud
                .borrow_mut::<SoundData>()
                .map_err(|_| LuaError::RuntimeError("lurek.dsp.applyBandpass: argument must be LSoundData".into()))?;
            sd.apply_bandpass(low_hz, high_hz);
            Ok(())
        })?,
    )?;
    // -- applyGain --
    /// Applies a gain multiplier in-place to the sound data.
    /// @param | sd_ud | LSoundData | The sound data to process.
    /// @param | gain | number | Gain multiplier (1.0 = unity, >1.0 = louder, <1.0 = quieter).
    tbl.set(
        "applyGain",
        lua.create_function(|_, (sd_ud, gain): (LuaAnyUserData, f32)| {
            let mut sd = sd_ud
                .borrow_mut::<SoundData>()
                .map_err(|_| LuaError::RuntimeError("lurek.dsp.applyGain: argument must be LSoundData".into()))?;
            sd.apply_gain(gain);
            Ok(())
        })?,
    )?;
    // -- analyzeRms --
    /// Analyzes the RMS volume of a `SoundData` buffer.
    /// @param | sd | LSoundData | The sound data to analyze.
    /// @return | number | RMS amplitude in the range [0.0, 1.0].
    tbl.set(
        "analyzeRms",
        lua.create_function(|_, sd_ud: LuaAnyUserData| {
            let sd = sd_ud
                .borrow::<SoundData>()
                .map_err(|_| LuaError::RuntimeError("lurek.dsp.analyzeRms: argument must be LSoundData".into()))?;
            Ok(sd.analyze_rms())
        })?,
    )?;
    // -- analyzePeak --
    /// Analyzes the Peak volume of a `SoundData` buffer.
    /// @param | sd | LSoundData | The sound data to analyze.
    /// @return | number | Peak amplitude in the range [0.0, 1.0].
    tbl.set(
        "analyzePeak",
        lua.create_function(|_, sd_ud: LuaAnyUserData| {
            let sd = sd_ud
                .borrow::<SoundData>()
                .map_err(|_| LuaError::RuntimeError("lurek.dsp.analyzePeak: argument must be LSoundData".into()))?;
            Ok(sd.analyze_peak())
        })?,
    )?;
    // -- analyzeFft --
    /// Performs FFT analysis on a `SoundData` buffer and returns frequency bin magnitudes.
    /// Uses a bounded DFT; at most 4096 samples and 512 bins are processed.
    /// @param | sd | LSoundData | The sound data to analyze.
    /// @param | size | integer | Number of frequency bins to compute (capped at 512).
    /// @return | table | Array of tables, each with `frequency` (number, Hz) and `magnitude` (number) fields.
    tbl.set(
        "analyzeFft",
        lua.create_function(|lua, (sd_ud, size): (LuaAnyUserData, usize)| {
            let sd = sd_ud
                .borrow::<SoundData>()
                .map_err(|_| LuaError::RuntimeError("lurek.dsp.analyzeFft: argument must be LSoundData".into()))?;
            let bins = sd.analyze_dft(size);
            let result = lua.create_table()?;
            for (i, (freq, mag)) in bins.into_iter().enumerate() {
                let entry = lua.create_table()?;
                entry.set("frequency", freq)?;
                entry.set("magnitude", mag)?;
                result.set(i + 1, entry)?;
            }
            Ok(result)
        })?,
    )?;
    let s = state.clone();
    // -- addEffectToBus --
    /// Adds an effect to a named audio bus and returns its effect ID.
    /// @param | bus_name | string | Name of the audio bus.
    /// @param | effect_type_str | string | Effect type identifier (e.g. `"lowpass"`, `"highpass"`, `"reverb"`).
    /// @param | params | table? | Optional parameters table; may include a `value` field.
    /// @return | integer | Numeric effect ID handle for use with `removeEffectFromBus` and `setEffectParam`.
    tbl.set(
        "addEffectToBus",
        lua.create_function(
            move |_, (bus_name, effect_type_str, params): (String, String, Option<mlua::Table>)| {
                let st = s.borrow();
                let bus_key = st
                    .mixer
                    .get_bus_by_name(&bus_name)
                    .ok_or_else(|| LuaError::external(format!("lurek.dsp.addEffectToBus: bus not found: {}", bus_name)))?;
                let bus = st
                    .mixer
                    .get_bus(bus_key)
                    .ok_or_else(|| LuaError::external(format!("lurek.dsp.addEffectToBus: bus not found: {}", bus_name)))?;
                let p1_val = params
                    .as_ref()
                    .and_then(|t| t.get::<_, f32>("value").ok())
                    .unwrap_or(1000.0);
                let eid = bus
                    .add_effect(&effect_type_str, p1_val)
                    .map_err(LuaError::RuntimeError)?;
                Ok(eid)
            },
        )?,
    )?;
    let s = state.clone();
    // -- removeEffectFromBus --
    /// Removes an effect from a named audio bus by effect ID.
    /// @param | bus_name | string | Name of the audio bus.
    /// @param | effect_id | integer | Effect ID returned by `addEffectToBus`.
    /// @return | boolean | `true` if the effect was successfully removed.
    tbl.set(
        "removeEffectFromBus",
        lua.create_function(move |_, (bus_name, effect_id): (String, u32)| {
            let st = s.borrow();
            let bus_key = st
                .mixer
                .get_bus_by_name(&bus_name)
                .ok_or_else(|| LuaError::external(format!("lurek.dsp.removeEffectFromBus: bus not found: {}", bus_name)))?;
            let bus = st
                .mixer
                .get_bus(bus_key)
                .ok_or_else(|| LuaError::external(format!("lurek.dsp.removeEffectFromBus: bus not found: {}", bus_name)))?;
            bus.remove_effect(effect_id)
                .map_err(LuaError::RuntimeError)
                .map(|_| true)
        })?,
    )?;
    let s = state.clone();
    // -- setEffectParam --
    /// Sets a parameter value on an effect attached to a named audio bus.
    /// @param | bus_name | string | Name of the audio bus.
    /// @param | effect_id | integer | Effect ID returned by `addEffectToBus`.
    /// @param | param_name | string | Name of the effect parameter to set.
    /// @param | value | number | New value for the parameter.
    /// @return | boolean | `true` if the parameter was set successfully.
    tbl.set(
        "setEffectParam",
        lua.create_function(
            move |_, (bus_name, effect_id, param_name, value): (String, u32, String, f32)| {
                let st = s.borrow();
                let bus_key = st
                    .mixer
                    .get_bus_by_name(&bus_name)
                    .ok_or_else(|| LuaError::external(format!("lurek.dsp.setEffectParam: bus not found: {}", bus_name)))?;
                let bus = st
                    .mixer
                    .get_bus(bus_key)
                    .ok_or_else(|| LuaError::external(format!("lurek.dsp.setEffectParam: bus not found: {}", bus_name)))?;
                let fx_list = bus.effects.read().unwrap();
                let fx = fx_list
                    .iter()
                    .find(|fx| fx.id == effect_id)
                    .ok_or_else(|| {
                        LuaError::external(format!("lurek.dsp.setEffectParam: effect not found: {}", effect_id))
                    })?;
                fx.set_param(&param_name, value)
                    .map_err(LuaError::RuntimeError)
                    .map(|_| true)
            },
        )?,
    )?;
    lurek.set("dsp", tbl)?;
    Ok(())
}
