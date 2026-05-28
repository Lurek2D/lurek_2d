//! `lurek.dsp` - Digital signal processing: effects, offline batch processing, and audio visualization.
use super::SharedState;
use crate::audio::sound_data::SoundData;
use crate::dsp::analysis::{LevelDetector, SpectrumAnalyzer};
use crate::dsp::graph::{DspGraph, DspNode, NodeId};
use crate::dsp::{
    add_effect_to_shared_chain, remove_effect_from_shared_chain, set_shared_chain_effect_param,
    EffectType,
};
use crate::dsp::synthesis::{AdsrEnvelope, Synthesizer, Waveform};
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

#[derive(Clone)]
struct LuaLevelDetector {
    inner: Rc<RefCell<LevelDetector>>,
}

#[derive(Clone)]
struct LuaSpectrumAnalyzer {
    inner: Rc<RefCell<SpectrumAnalyzer>>,
}

#[derive(Clone)]
struct LuaWaveform {
    inner: Waveform,
}

#[derive(Clone)]
struct LuaAdsrEnvelope {
    inner: Rc<RefCell<AdsrEnvelope>>,
}

#[derive(Clone)]
struct LuaSynthesizer {
    inner: Rc<RefCell<Synthesizer>>,
}

#[derive(Clone)]
struct LuaDspNode {
    inner: Rc<RefCell<DspNode>>,
}

#[derive(Clone)]
struct LuaDspGraph {
    inner: Rc<RefCell<DspGraph>>,
}

fn helper_new_effect_params<'lua>(
    lua: &'lua Lua,
    (typ, p1, p2, p3): (String, f32, f32, f32),
) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    table.set("type", typ)?;
    table.set("p1", p1)?;
    table.set("p2", p2)?;
    table.set("p3", p3)?;
    Ok(table)
}

fn helper_resolve_output_paths(
    state: Rc<RefCell<SharedState>>,
    input: &str,
    output: &str,
) -> LuaResult<(String, String)> {
    if input.contains("..") || output.contains("..") {
        return Err(LuaError::external("path traversal not allowed"));
    }
    let game_dir = state.borrow().game_dir.clone();
    let input_path = game_dir.join(input).to_string_lossy().into_owned();
    let output_path = game_dir.join(output).to_string_lossy().into_owned();
    Ok((input_path, output_path))
}

fn helper_parse_offline_effect(table: &LuaTable) -> LuaResult<crate::dsp::OfflineEffect> {
    let typ_str: String = table.get("type").unwrap_or_default();
    let p1: f32 = table.get("p1").unwrap_or(1000.0);
    let p2: f32 = table.get("p2").unwrap_or(1.0);
    let p3: f32 = table.get("p3").unwrap_or(0.5);
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
    Ok(crate::dsp::OfflineEffect { typ, p1, p2, p3 })
}

fn helper_process_offline(
    state: Rc<RefCell<SharedState>>,
    (input, output, effects_tbl): (String, String, LuaTable),
) -> LuaResult<bool> {
    let (input_path, output_path) = helper_resolve_output_paths(state, &input, &output)?;
    let mut effects = Vec::new();
    for pair in effects_tbl.sequence_values::<LuaTable>() {
        let table = pair.map_err(LuaError::external)?;
        effects.push(helper_parse_offline_effect(&table)?);
    }
    crate::dsp::offline::process_offline(&input_path, &output_path, &effects)
        .map_err(LuaError::external)
        .map(|_| true)
}

fn helper_normalize_file(
    state: Rc<RefCell<SharedState>>,
    (input, output, target): (String, String, f32),
) -> LuaResult<bool> {
    let (input_path, output_path) = helper_resolve_output_paths(state, &input, &output)?;
    crate::dsp::offline::normalize_file(&input_path, &output_path, target)
        .map_err(LuaError::external)
        .map(|_| true)
}

fn helper_waveform_to_png(
    state: Rc<RefCell<SharedState>>,
    (input, output, width, height): (String, String, u32, u32),
) -> LuaResult<bool> {
    let (input_path, output_path) = helper_resolve_output_paths(state, &input, &output)?;
    crate::dsp::visualizer::waveform_to_png(&input_path, &output_path, width, height)
        .map_err(LuaError::external)
        .map(|_| true)
}

fn helper_spectrogram_to_png(
    state: Rc<RefCell<SharedState>>,
    (input, output, width, height): (String, String, u32, u32),
) -> LuaResult<bool> {
    let (input_path, output_path) = helper_resolve_output_paths(state, &input, &output)?;
    crate::dsp::visualizer::spectrogram_to_png(&input_path, &output_path, width, height)
        .map_err(LuaError::external)
        .map(|_| true)
}

fn helper_apply_lowpass((sd_ud, cutoff_hz): (LuaAnyUserData, f32)) -> LuaResult<()> {
    let mut sound_data = sd_ud.borrow_mut::<SoundData>().map_err(|_| {
        LuaError::RuntimeError("lurek.dsp.applyLowpass: argument must be LSoundData".into())
    })?;
    sound_data.apply_lowpass(cutoff_hz);
    Ok(())
}

fn helper_apply_highpass((sd_ud, cutoff_hz): (LuaAnyUserData, f32)) -> LuaResult<()> {
    let mut sound_data = sd_ud.borrow_mut::<SoundData>().map_err(|_| {
        LuaError::RuntimeError("lurek.dsp.applyHighpass: argument must be LSoundData".into())
    })?;
    sound_data.apply_highpass(cutoff_hz);
    Ok(())
}

fn helper_apply_bandpass((sd_ud, low_hz, high_hz): (LuaAnyUserData, f32, f32)) -> LuaResult<()> {
    let mut sound_data = sd_ud.borrow_mut::<SoundData>().map_err(|_| {
        LuaError::RuntimeError("lurek.dsp.applyBandpass: argument must be LSoundData".into())
    })?;
    sound_data.apply_bandpass(low_hz, high_hz);
    Ok(())
}

fn helper_apply_gain((sd_ud, gain): (LuaAnyUserData, f32)) -> LuaResult<()> {
    let mut sound_data = sd_ud.borrow_mut::<SoundData>().map_err(|_| {
        LuaError::RuntimeError("lurek.dsp.applyGain: argument must be LSoundData".into())
    })?;
    sound_data.apply_gain(gain);
    Ok(())
}

fn helper_analyze_rms(sd_ud: LuaAnyUserData) -> LuaResult<f32> {
    let sound_data = sd_ud.borrow::<SoundData>().map_err(|_| {
        LuaError::RuntimeError("lurek.dsp.analyzeRms: argument must be LSoundData".into())
    })?;
    Ok(sound_data.analyze_rms())
}

fn helper_analyze_peak(sd_ud: LuaAnyUserData) -> LuaResult<f32> {
    let sound_data = sd_ud.borrow::<SoundData>().map_err(|_| {
        LuaError::RuntimeError("lurek.dsp.analyzePeak: argument must be LSoundData".into())
    })?;
    Ok(sound_data.analyze_peak())
}

fn helper_analyze_fft<'lua>(
    lua: &'lua Lua,
    (sd_ud, size): (LuaAnyUserData<'lua>, usize),
) -> LuaResult<LuaTable<'lua>> {
    let sound_data = sd_ud.borrow::<SoundData>().map_err(|_| {
        LuaError::RuntimeError("lurek.dsp.analyzeFft: argument must be LSoundData".into())
    })?;
    let bins = sound_data.analyze_dft(size);
    let result = lua.create_table()?;
    for (index, (frequency, magnitude)) in bins.into_iter().enumerate() {
        let entry = lua.create_table()?;
        entry.set("frequency", frequency)?;
        entry.set("magnitude", magnitude)?;
        result.set(index + 1, entry)?;
    }
    Ok(result)
}

fn helper_add_effect_to_bus(
    state: Rc<RefCell<SharedState>>,
    (bus_name, effect_type_str, params): (String, String, Option<LuaTable>),
) -> LuaResult<u32> {
    let st = state.borrow();
    let bus_key = st.mixer.get_bus_by_name(&bus_name).ok_or_else(|| {
        LuaError::external(format!(
            "lurek.dsp.addEffectToBus: bus not found: {}",
            bus_name
        ))
    })?;
    let bus = st.mixer.get_bus(bus_key).ok_or_else(|| {
        LuaError::external(format!(
            "lurek.dsp.addEffectToBus: bus not found: {}",
            bus_name
        ))
    })?;
    let p1_val = params
        .as_ref()
        .and_then(|table| table.get::<_, f32>("value").ok())
        .unwrap_or(1000.0);
    add_effect_to_shared_chain(&bus.effects, &effect_type_str, p1_val)
        .map_err(LuaError::RuntimeError)
}

fn helper_remove_effect_from_bus(
    state: Rc<RefCell<SharedState>>,
    (bus_name, effect_id): (String, u32),
) -> LuaResult<bool> {
    let st = state.borrow();
    let bus_key = st.mixer.get_bus_by_name(&bus_name).ok_or_else(|| {
        LuaError::external(format!(
            "lurek.dsp.removeEffectFromBus: bus not found: {}",
            bus_name
        ))
    })?;
    let bus = st.mixer.get_bus(bus_key).ok_or_else(|| {
        LuaError::external(format!(
            "lurek.dsp.removeEffectFromBus: bus not found: {}",
            bus_name
        ))
    })?;
    remove_effect_from_shared_chain(&bus.effects, effect_id)
        .map_err(LuaError::RuntimeError)
        .map(|_| true)
}

fn helper_set_effect_param(
    state: Rc<RefCell<SharedState>>,
    (bus_name, effect_id, param_name, value): (String, u32, String, f32),
) -> LuaResult<bool> {
    let st = state.borrow();
    let bus_key = st.mixer.get_bus_by_name(&bus_name).ok_or_else(|| {
        LuaError::external(format!(
            "lurek.dsp.setEffectParam: bus not found: {}",
            bus_name
        ))
    })?;
    let bus = st.mixer.get_bus(bus_key).ok_or_else(|| {
        LuaError::external(format!(
            "lurek.dsp.setEffectParam: bus not found: {}",
            bus_name
        ))
    })?;
    set_shared_chain_effect_param(&bus.effects, effect_id, &param_name, value)
        .map_err(LuaError::RuntimeError)
        .map(|_| true)
}

fn helper_new_wave(kind: &str, freq: f32, duration: f32, sample_rate: u32, amplitude: f32) -> LuaResult<SoundData> {
    let waveform = Waveform::parse(kind).map_err(LuaError::RuntimeError)?;
    Ok(waveform.render(freq, duration, sample_rate, amplitude))
}

fn helper_new_synth_wave(
    (waveform, freq, duration, sample_rate, amplitude, adsr): (
        String,
        f32,
        f32,
        u32,
        f32,
        Option<LuaTable>,
    ),
) -> LuaResult<SoundData> {
    let waveform = Waveform::parse(&waveform).map_err(LuaError::RuntimeError)?;
    let mut synth = Synthesizer::new();
    synth.set_waveform(waveform);
    if let Some(envelope_table) = adsr {
        let attack: f32 = envelope_table.get("attack").unwrap_or(0.0);
        let decay: f32 = envelope_table.get("decay").unwrap_or(0.0);
        let sustain: f32 = envelope_table.get("sustain").unwrap_or(1.0);
        let release: f32 = envelope_table.get("release").unwrap_or(0.0);
        synth.set_envelope(AdsrEnvelope::new(attack, decay, sustain, release));
    }
    Ok(synth.generate(freq, duration, sample_rate, amplitude))
}

/// Lua-visible running detector that tracks RMS, peak, and clipping state for processed audio.
impl LuaUserData for LuaLevelDetector {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- process_sample --
        /// Processes one audio sample and updates detector statistics incrementally.
        /// @param | sample | number | Input sample value in the range [-1.0, 1.0].
        methods.add_method_mut("process_sample", |_, this, sample: f32| {
            this.inner.borrow_mut().process_sample(sample);
            Ok(())
        });
        // -- process --
        /// Processes all samples in a sound buffer and returns aggregate level statistics.
        /// @param | sound_data_ud | LSoundData | Sound buffer to analyze.
        /// @return | table | Table with `rms`, `peak`, and `clipping` fields.
        methods.add_method_mut("process", |lua, this, sound_data_ud: LuaAnyUserData| {
            let sound_data = sound_data_ud.borrow::<SoundData>().map_err(|_| {
                LuaError::RuntimeError("lurek.dsp.LLevelDetector:process: argument must be LSoundData".into())
            })?;
            let (rms, peak, clipping) = this.inner.borrow_mut().process_sound_data(&sound_data);
            let result = lua.create_table()?;
            result.set("rms", rms)?;
            result.set("peak", peak)?;
            result.set("clipping", clipping)?;
            Ok(result)
        });
        // -- get_rms --
        /// Returns the current RMS level accumulated by the detector.
        /// @return | number | RMS amplitude in linear scale.
        methods.add_method("get_rms", |_, this, ()| Ok(this.inner.borrow().get_rms()));
        // -- get_peak --
        /// Returns the current peak level accumulated by the detector.
        /// @return | number | Peak absolute amplitude in linear scale.
        methods.add_method("get_peak", |_, this, ()| Ok(this.inner.borrow().get_peak()));
        // -- to_db --
        /// Converts a linear amplitude value to decibels full scale.
        /// @param | value | number | Linear amplitude value to convert.
        /// @return | number | Converted dBFS value.
        methods.add_method("to_db", |_, _, value: f32| Ok(LevelDetector::to_db(value)));
        // -- reset --
        /// Resets detector state so a new measurement window can begin.
        methods.add_method_mut("reset", |_, this, ()| {
            this.inner.borrow_mut().reset();
            Ok(())
        });
    }
}

/// Lua-visible spectral analyzer that computes bounded frequency bins from sound buffers.
impl LuaUserData for LuaSpectrumAnalyzer {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- setSize --
        /// Sets the frequency-bin count used by subsequent spectrum analysis calls.
        /// @param | size | integer | Requested number of bins (bounded internally).
        methods.add_method_mut("setSize", |_, this, size: usize| {
            this.inner.borrow_mut().set_size(size);
            Ok(())
        });
        // -- analyze --
        /// Analyzes one sound buffer and returns `(frequency, magnitude)` rows.
        /// @param | sound_data_ud | LSoundData | Sound buffer to analyze.
        /// @return | table | Array with `frequency` and `magnitude` fields per bin.
        methods.add_method("analyze", |lua, this, sound_data_ud: LuaAnyUserData| {
            let sound_data = sound_data_ud.borrow::<SoundData>().map_err(|_| {
                LuaError::RuntimeError("lurek.dsp.LSpectrumAnalyzer:analyze: argument must be LSoundData".into())
            })?;
            let bins = this.inner.borrow().analyze(&sound_data);
            let result = lua.create_table()?;
            for (index, (frequency, magnitude)) in bins.into_iter().enumerate() {
                let row = lua.create_table()?;
                row.set("frequency", frequency)?;
                row.set("magnitude", magnitude)?;
                result.set(index + 1, row)?;
            }
            Ok(result)
        });
    }
}

/// Lua-visible procedural waveform descriptor used for repeated SoundData rendering.
impl LuaUserData for LuaWaveform {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- render --
        /// Renders this waveform to a new SoundData buffer.
        /// @param | freq | number | Frequency in Hertz.
        /// @param | duration | number | Duration in seconds.
        /// @param | sample_rate | integer | Sample rate in Hertz.
        /// @param | amplitude | number | Peak amplitude in the range [0.0, 1.0].
        /// @return | LSoundData | Generated mono sound buffer.
        methods.add_method("render", |_, this, (freq, duration, sample_rate, amplitude): (f32, f32, u32, f32)| {
            Ok(this.inner.render(freq, duration, sample_rate, amplitude))
        });
        // -- type --
        /// Returns the waveform identifier string.
        /// @return | string | One of `sine`, `square`, `sawtooth`, `triangle`, or `white_noise`.
        methods.add_method("type", |_, this, ()| Ok(this.inner.as_str()));
    }
}

/// Lua-visible ADSR envelope object for sample stepping and buffer shaping.
impl LuaUserData for LuaAdsrEnvelope {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- trigger_on --
        /// Starts the envelope attack phase for this ADSR object.
        methods.add_method_mut("trigger_on", |_, this, ()| {
            this.inner.borrow_mut().trigger_on();
            Ok(())
        });
        // -- trigger_off --
        /// Starts the envelope release phase.
        methods.add_method_mut("trigger_off", |_, this, ()| {
            this.inner.borrow_mut().trigger_off();
            Ok(())
        });
        // -- next_sample --
        /// Advances the envelope and returns the next gain sample.
        /// @return | number | Current envelope gain after stepping.
        methods.add_method_mut("next_sample", |_, this, ()| Ok(this.inner.borrow_mut().next_sample()));
        // -- is_idle --
        /// Returns whether the envelope has fully completed and is idle.
        /// @return | boolean | True when the envelope is idle.
        methods.add_method("is_idle", |_, this, ()| Ok(this.inner.borrow().is_idle()));
        // -- apply --
        /// Applies this ADSR envelope across an entire sound buffer in place.
        /// @param | sound_data_ud | LSoundData | Sound buffer to shape in-place.
        methods.add_method("apply", |_, this, sound_data_ud: LuaAnyUserData| {
            let mut sound_data = sound_data_ud.borrow_mut::<SoundData>().map_err(|_| {
                LuaError::RuntimeError("lurek.dsp.LAdsrEnvelope:apply: argument must be LSoundData".into())
            })?;
            this.inner.borrow().apply(&mut sound_data);
            Ok(())
        });
    }
}

/// Lua-visible synthesizer that combines waveform selection and optional ADSR shaping.
impl LuaUserData for LuaSynthesizer {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- setWaveform --
        /// Sets the oscillator waveform using a kind string or waveform object.
        /// @param | value | any | Waveform kind string or LWaveform instance.
        methods.add_method_mut("setWaveform", |_, this, value: LuaValue| {
            let waveform = match value {
                LuaValue::String(s) => {
                    let kind = s.to_str().map_err(LuaError::external)?;
                    Waveform::parse(kind).map_err(LuaError::RuntimeError)?
                }
                LuaValue::UserData(ud) => ud
                    .borrow::<LuaWaveform>()
                    .map_err(|_| LuaError::RuntimeError("setWaveform expects waveform string or LWaveform".into()))?
                    .inner,
                _ => {
                    return Err(LuaError::RuntimeError(
                        "setWaveform expects waveform string or LWaveform".into(),
                    ))
                }
            };
            this.inner.borrow_mut().set_waveform(waveform);
            Ok(())
        });
        // -- setEnvelope --
        /// Attaches an ADSR envelope used by future render calls.
        /// @param | envelope_ud | LAdsrEnvelope | Envelope object copied into the synthesizer.
        methods.add_method_mut("setEnvelope", |_, this, envelope_ud: LuaAnyUserData| {
            let envelope = envelope_ud
                .borrow::<LuaAdsrEnvelope>()
                .map_err(|_| LuaError::RuntimeError("setEnvelope expects LAdsrEnvelope".into()))?
                .inner
                .borrow()
                .clone();
            this.inner.borrow_mut().set_envelope(envelope);
            Ok(())
        });
        // -- render --
        /// Renders a SoundData buffer using current synthesizer settings.
        /// @param | freq | number | Frequency in Hertz.
        /// @param | duration | number | Duration in seconds.
        /// @param | sample_rate | integer | Sample rate in Hertz.
        /// @param | amplitude | number | Peak amplitude in the range [0.0, 1.0].
        /// @return | LSoundData | Generated sound buffer.
        methods.add_method("render", |_, this, (freq, duration, sample_rate, amplitude): (f32, f32, u32, f32)| {
            Ok(this.inner.borrow().generate(freq, duration, sample_rate, amplitude))
        });
        // -- generate --
        /// Generates a SoundData buffer; alias of `render` for compatibility.
        /// @param | freq | number | Frequency in Hertz.
        /// @param | duration | number | Duration in seconds.
        /// @param | sample_rate | integer | Sample rate in Hertz.
        /// @param | amplitude | number | Peak amplitude in the range [0.0, 1.0].
        /// @return | LSoundData | Generated sound buffer.
        methods.add_method("generate", |_, this, (freq, duration, sample_rate, amplitude): (f32, f32, u32, f32)| {
            Ok(this.inner.borrow().generate(freq, duration, sample_rate, amplitude))
        });
    }
}

/// Lua-visible DSP graph node carrying type and simple numeric parameters.
impl LuaUserData for LuaDspNode {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- setParam --
        /// Sets one named numeric parameter on the node.
        /// @param | name | string | Parameter name such as `cutoff`, `low`, `high`, or `gain`.
        /// @param | value | number | New parameter value.
        methods.add_method_mut("setParam", |_, this, (name, value): (String, f32)| {
            this.inner
                .borrow_mut()
                .set_param(&name, value)
                .map_err(LuaError::RuntimeError)
        });
        // -- getParam --
        /// Returns one named numeric parameter from the node.
        /// @param | name | string | Parameter name to fetch.
        /// @return | number | Current parameter value.
        methods.add_method("getParam", |_, this, name: String| {
            this.inner
                .borrow()
                .get_param(&name)
                .ok_or_else(|| LuaError::RuntimeError(format!("unknown parameter: {}", name)))
        });
        // -- type --
        /// Returns the node type string used by this node.
        /// @return | string | Node kind used by this DSP node.
        methods.add_method("type", |_, this, ()| Ok(this.inner.borrow().node_type().as_str()));
    }
}

/// Lua-visible DSP graph that stores nodes, edges, and offline processing order.
impl LuaUserData for LuaDspGraph {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addNode --
        /// Adds a DSP node object to the graph and returns its stable node ID.
        /// @param | node_ud | LDspNode | Node object to add to this graph.
        /// @return | integer | Stable node identifier for connect and disconnect calls.
        methods.add_method_mut("addNode", |_, this, node_ud: LuaAnyUserData| {
            let node = node_ud
                .borrow::<LuaDspNode>()
                .map_err(|_| LuaError::RuntimeError("addNode expects LDspNode".into()))?
                .inner
                .borrow()
                .clone();
            Ok(this.inner.borrow_mut().add_node(node))
        });
        // -- connect --
        /// Connects two node IDs in this graph object.
        /// @param | from | integer | Source node ID.
        /// @param | to | integer | Destination node ID.
        /// @param | options | table? | Reserved connection options for future graph routing.
        /// @return | boolean | True when the connection is valid and stored.
        methods.add_method_mut("connect", |_, this, (from, to, _options): (NodeId, NodeId, Option<LuaTable>)| {
            Ok(this.inner.borrow_mut().connect(from, to))
        });
        // -- disconnect --
        /// Removes a connection between two node IDs.
        /// @param | from | integer | Source node ID.
        /// @param | to | integer | Destination node ID.
        /// @return | boolean | True when an existing connection was removed.
        methods.add_method_mut("disconnect", |_, this, (from, to): (NodeId, NodeId)| {
            Ok(this.inner.borrow_mut().disconnect(from, to))
        });
        // -- process --
        /// Processes a sound buffer through the graph and returns transformed data.
        /// @param | sound_data_ud | LSoundData | Input sound buffer.
        /// @return | LSoundData | Processed sound buffer output.
        methods.add_method("process", |_, this, sound_data_ud: LuaAnyUserData| {
            let sound_data = sound_data_ud.borrow::<SoundData>().map_err(|_| {
                LuaError::RuntimeError("LDspGraph:process expects LSoundData".into())
            })?;
            Ok(this.inner.borrow().process(&sound_data))
        });
        // -- clear --
        /// Clears all graph nodes and edges from this graph.
        methods.add_method_mut("clear", |_, this, ()| {
            this.inner.borrow_mut().clear();
            Ok(())
        });
    }
}

/// Registers the `lurek.dsp` Lua API table.
pub fn register(lua: &Lua, lurek: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;

    // --- constructors and offline processing --------------------------------

    /// Creates an effect parameter descriptor table for use with offline processing.
    /// @param | effectType | string | Effect type name (e.g. "lowpass", "reverb", "compressor").
    /// @param | p1 | number | Primary parameter value.
    /// @param | p2 | number | Secondary parameter value.
    /// @param | p3 | number | Tertiary parameter value.
    /// @return | table | Effect parameter descriptor table.
    tbl.set(
        "newEffectParams",
        lua.create_function(helper_new_effect_params)?,
    )?;
    let s = state.clone();
    /// Processes an audio file offline through a chain of effects and writes the result to an output file.
    /// @param | input | string | Relative path to the input audio file.
    /// @param | output | string | Relative path for the output WAV file.
    /// @param | effects | table | Array of effect tables; each has `type` (string) and optional `p1`, `p2`, `p3` (number) fields.
    /// @return | boolean | True when the output file was written successfully.
    tbl.set(
        "processOffline",
        lua.create_function(move |_, args| helper_process_offline(s.clone(), args))?,
    )?;
    let s = state.clone();
    /// Normalizes an audio file to a target peak amplitude and saves the result.
    /// @param | input | string | Relative path to the input audio file.
    /// @param | output | string | Relative path for the output WAV file.
    /// @param | target | number | Target peak amplitude (e.g. 0.9 for headroom).
    /// @return | boolean | True when the output file was written successfully.
    tbl.set(
        "normalize",
        lua.create_function(move |_, args| helper_normalize_file(s.clone(), args))?,
    )?;
    let s = state.clone();
    /// Renders a waveform visualization of an audio file and saves it as a PNG image.
    /// @param | input | string | Relative path to the input audio file.
    /// @param | output | string | Relative path for the output PNG file.
    /// @param | width | integer | Image width in pixels.
    /// @param | height | integer | Image height in pixels.
    /// @return | boolean | True when the output image was written successfully.
    tbl.set(
        "waveformToPng",
        lua.create_function(move |_, args| helper_waveform_to_png(s.clone(), args))?,
    )?;
    let s = state.clone();
    /// Renders a spectrogram visualization of an audio file and saves it as a PNG image.
    /// @param | input | string | Relative path to the input audio file.
    /// @param | output | string | Relative path for the output PNG file.
    /// @param | width | integer | Image width in pixels.
    /// @param | height | integer | Image height in pixels.
    /// @return | boolean | True when the output image was written successfully.
    tbl.set(
        "spectrogramToPng",
        lua.create_function(move |_, args| helper_spectrogram_to_png(s.clone(), args))?,
    )?;

    // --- SoundData transforms and analysis ----------------------------------

    /// Applies a lowpass filter in-place to the sound data.
    /// @param | sd_ud | LSoundData | The sound data to process.
    /// @param | cutoff_hz | number | Lowpass cutoff frequency in Hz.
    tbl.set(
        "applyLowpass",
        lua.create_function(|_, args| helper_apply_lowpass(args))?,
    )?;
    /// Applies a highpass filter in-place to the sound data.
    /// @param | sd_ud | LSoundData | The sound data to process.
    /// @param | cutoff_hz | number | Highpass cutoff frequency in Hz.
    tbl.set(
        "applyHighpass",
        lua.create_function(|_, args| helper_apply_highpass(args))?,
    )?;
    /// Applies a bandpass filter in-place to the sound data.
    /// @param | sd_ud | LSoundData | The sound data to process.
    /// @param | low_hz | number | Lower cutoff frequency in Hz.
    /// @param | high_hz | number | Upper cutoff frequency in Hz.
    tbl.set(
        "applyBandpass",
        lua.create_function(|_, args| helper_apply_bandpass(args))?,
    )?;
    /// Applies a gain multiplier in-place to the sound data.
    /// @param | sd_ud | LSoundData | The sound data to process.
    /// @param | gain | number | Gain multiplier (1.0 = unity, >1.0 = louder, <1.0 = quieter).
    tbl.set(
        "applyGain",
        lua.create_function(|_, args| helper_apply_gain(args))?,
    )?;
    /// Analyzes the RMS volume of a `SoundData` buffer.
    /// @param | sd | LSoundData | The sound data to analyze.
    /// @return | number | RMS amplitude in the range [0.0, 1.0].
    tbl.set(
        "analyzeRms",
        lua.create_function(|_, sd_ud| helper_analyze_rms(sd_ud))?,
    )?;
    /// Analyzes the Peak volume of a `SoundData` buffer.
    /// @param | sd | LSoundData | The sound data to analyze.
    /// @return | number | Peak amplitude in the range [0.0, 1.0].
    tbl.set(
        "analyzePeak",
        lua.create_function(|_, sd_ud| helper_analyze_peak(sd_ud))?,
    )?;
    // -- analyzeFft --
    /// Performs FFT analysis on a `SoundData` buffer and returns frequency bin magnitudes.
    /// Uses a bounded DFT; at most 4096 samples and 512 bins are processed.
    /// @param | sd | LSoundData | The sound data to analyze.
    /// @param | size | integer | Number of frequency bins to compute (capped at 512).
    /// @return | table | Array of tables, each with `frequency` (number, Hz) and `magnitude` (number) fields.
    tbl.set("analyzeFft", lua.create_function(helper_analyze_fft)?)?;

    // --- bus effects ---------------------------------------------------------

    let s = state.clone();
    /// Adds an effect to a named audio bus and returns its effect ID.
    /// @param | bus_name | string | Name of the audio bus.
    /// @param | effect_type_str | string | Effect type identifier (e.g. `"lowpass"`, `"highpass"`, `"reverb"`).
    /// @param | params | table? | Optional parameters table; may include a `value` field.
    /// @return | integer | Numeric effect ID handle for use with `removeEffectFromBus` and `setEffectParam`.
    tbl.set(
        "addEffectToBus",
        lua.create_function(move |_, args| helper_add_effect_to_bus(s.clone(), args))?,
    )?;
    let s = state.clone();
    /// Removes an effect from a named audio bus by effect ID.
    /// @param | bus_name | string | Name of the audio bus.
    /// @param | effect_id | integer | Effect ID returned by `addEffectToBus`.
    /// @return | boolean | `true` if the effect was successfully removed.
    tbl.set(
        "removeEffectFromBus",
        lua.create_function(move |_, args| helper_remove_effect_from_bus(s.clone(), args))?,
    )?;
    let s = state.clone();
    /// Sets a parameter value on an effect attached to a named audio bus.
    /// @param | bus_name | string | Name of the audio bus.
    /// @param | effect_id | integer | Effect ID returned by `addEffectToBus`.
    /// @param | param_name | string | Name of the effect parameter to set.
    /// @param | value | number | New value for the parameter.
    /// @return | boolean | `true` if the parameter was set successfully.
    tbl.set(
        "setEffectParam",
        lua.create_function(move |_, args| helper_set_effect_param(s.clone(), args))?,
    )?;

    /// Generates a sine wave as a `SoundData` buffer.
    /// @param | freq | number | Frequency in Hz.
    /// @param | duration | number | Duration in seconds.
    /// @param | sample_rate | integer | Sample rate in Hz.
    /// @param | amplitude | number | Peak amplitude in [0, 1].
    /// @return | LSoundData | Generated audio buffer.
    tbl.set(
        "newSineWave",
        lua.create_function(|_, (freq, duration, sample_rate, amplitude): (f32, f32, u32, f32)| {
            helper_new_wave("sine", freq, duration, sample_rate, amplitude)
        })?,
    )?;
    /// Generates a square wave as a `SoundData` buffer.
    /// @param | freq | number | Frequency in Hz.
    /// @param | duration | number | Duration in seconds.
    /// @param | sample_rate | integer | Sample rate in Hz.
    /// @param | amplitude | number | Peak amplitude in [0, 1].
    /// @return | LSoundData | Generated audio buffer.
    tbl.set(
        "newSquareWave",
        lua.create_function(|_, (freq, duration, sample_rate, amplitude): (f32, f32, u32, f32)| {
            helper_new_wave("square", freq, duration, sample_rate, amplitude)
        })?,
    )?;
    /// Generates a sawtooth wave as a `SoundData` buffer.
    /// @param | freq | number | Frequency in Hz.
    /// @param | duration | number | Duration in seconds.
    /// @param | sample_rate | integer | Sample rate in Hz.
    /// @param | amplitude | number | Peak amplitude in [0, 1].
    /// @return | LSoundData | Generated audio buffer.
    tbl.set(
        "newSawtoothWave",
        lua.create_function(|_, (freq, duration, sample_rate, amplitude): (f32, f32, u32, f32)| {
            helper_new_wave("sawtooth", freq, duration, sample_rate, amplitude)
        })?,
    )?;
    /// Generates a triangle wave as a `SoundData` buffer.
    /// @param | freq | number | Frequency in Hz.
    /// @param | duration | number | Duration in seconds.
    /// @param | sample_rate | integer | Sample rate in Hz.
    /// @param | amplitude | number | Peak amplitude in [0, 1].
    /// @return | LSoundData | Generated audio buffer.
    tbl.set(
        "newTriangleWave",
        lua.create_function(|_, (freq, duration, sample_rate, amplitude): (f32, f32, u32, f32)| {
            helper_new_wave("triangle", freq, duration, sample_rate, amplitude)
        })?,
    )?;
    /// Generates deterministic white noise as a `SoundData` buffer.
    /// @param | duration | number | Duration in seconds.
    /// @param | sample_rate | integer | Sample rate in Hz.
    /// @param | amplitude | number | Peak amplitude in [0, 1].
    /// @param | seed | integer | Deterministic seed for the noise source.
    /// @return | LSoundData | Generated noise buffer.
    tbl.set(
        "newWhiteNoise",
        lua.create_function(|_, (duration, sample_rate, amplitude, seed): (f32, u32, f32, u32)| {
            Ok(SoundData::white_noise(duration, sample_rate, amplitude, seed))
        })?,
    )?;
    /// Generates a synthesized waveform with optional ADSR.
    /// @param | waveform | string | Waveform kind: `sine`, `square`, `sawtooth`, or `triangle`.
    /// @param | freq | number | Frequency in Hz.
    /// @param | duration | number | Duration in seconds.
    /// @param | sample_rate | integer | Sample rate in Hz.
    /// @param | amplitude | number | Peak amplitude in [0, 1].
    /// @param | adsr | table? | Optional ADSR table with `attack`, `decay`, `sustain`, and `release`.
    /// @return | LSoundData | Generated synthesized sound buffer.
    tbl.set(
        "newSynthWave",
        lua.create_function(|_, args| helper_new_synth_wave(args))?,
    )?;

    /// Creates a level detector object that tracks RMS, peak, and clipping state over samples.
    /// @param | options | table? | Optional table with `clipThreshold` numeric field.
    /// @return | LLevelDetector | New level detector instance.
    tbl.set(
        "newLevelDetector",
        lua.create_function(|_, options: Option<LuaTable>| {
            let threshold = options
                .as_ref()
                .and_then(|table| table.get::<_, f32>("clipThreshold").ok())
                .unwrap_or(0.99);
            Ok(LuaLevelDetector {
                inner: Rc::new(RefCell::new(LevelDetector::new(threshold))),
            })
        })?,
    )?;
    /// Creates a spectrum analyzer object for bounded frequency-bin analysis on SoundData.
    /// @param | options | table? | Optional table with integer `size` field for bin count.
    /// @return | LSpectrumAnalyzer | New spectrum analyzer instance.
    tbl.set(
        "newSpectrumAnalyzer",
        lua.create_function(|_, options: Option<LuaTable>| {
            let size = options
                .as_ref()
                .and_then(|table| table.get::<_, usize>("size").ok())
                .unwrap_or(512);
            Ok(LuaSpectrumAnalyzer {
                inner: Rc::new(RefCell::new(SpectrumAnalyzer::new(size))),
            })
        })?,
    )?;
    /// Creates a waveform descriptor object that can render repeated procedural tones.
    /// @param | kind | string | Waveform kind name.
    /// @param | options | table? | Reserved options table for future waveform behavior.
    /// @return | LWaveform | New waveform descriptor instance.
    tbl.set(
        "newWaveform",
        lua.create_function(|_, (kind, _options): (String, Option<LuaTable>)| {
            let waveform = Waveform::parse(&kind).map_err(LuaError::RuntimeError)?;
            Ok(LuaWaveform { inner: waveform })
        })?,
    )?;
    /// Creates an ADSR envelope object for procedural synthesis and buffer shaping workflows.
    /// @param | attack | number | Attack time in seconds.
    /// @param | decay | number | Decay time in seconds.
    /// @param | sustain | number | Sustain gain in [0, 1].
    /// @param | release | number | Release time in seconds.
    /// @return | LAdsrEnvelope | New ADSR envelope instance.
    tbl.set(
        "newAdsrEnvelope",
        lua.create_function(|_, (attack, decay, sustain, release): (f32, f32, f32, f32)| {
            Ok(LuaAdsrEnvelope {
                inner: Rc::new(RefCell::new(AdsrEnvelope::new(attack, decay, sustain, release))),
            })
        })?,
    )?;
    /// Creates a synthesizer object that combines waveform selection and optional ADSR shaping.
    /// @param | options | table? | Reserved options table for future synthesizer defaults.
    /// @return | LSynthesizer | New synthesizer instance.
    tbl.set(
        "newSynthesizer",
        lua.create_function(|_, _options: Option<LuaTable>| {
            Ok(LuaSynthesizer {
                inner: Rc::new(RefCell::new(Synthesizer::new())),
            })
        })?,
    )?;
    /// Creates a DSP graph node object with a node kind and optional initial options.
    /// @param | kind | string | Node kind such as `lowpass`, `highpass`, `bandpass`, or `gain`.
    /// @param | options | table? | Reserved options table for future node configuration.
    /// @return | LDspNode | New graph node instance.
    tbl.set(
        "newNode",
        lua.create_function(|_, (kind, _options): (String, Option<LuaTable>)| {
            Ok(LuaDspNode {
                inner: Rc::new(RefCell::new(DspNode::new(&kind))),
            })
        })?,
    )?;
    /// Creates an empty DSP graph object for connecting nodes and processing SoundData buffers.
    /// @return | LDspGraph | New DSP graph instance.
    tbl.set(
        "newGraph",
        lua.create_function(|_, ()| {
            Ok(LuaDspGraph {
                inner: Rc::new(RefCell::new(DspGraph::new())),
            })
        })?,
    )?;
    lurek.set("dsp", tbl)?;
    Ok(())
}
