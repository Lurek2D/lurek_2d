//! `lurek.dsp` - Digital signal processing: effects, offline batch processing, and audio visualization.
use super::SharedState;
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
    lurek.set("dsp", tbl)?;
    Ok(())
}
