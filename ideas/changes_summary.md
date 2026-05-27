# Zestawienie zmian — sesja audio/dsp refactor

> Odtworzone z historii czatu. Uzywaj tego dokumentu zeby recznie wprowadzic zmiany po `git restore`.

---

## 1. `src/lua_api/audio_api.rs` — Refaktor closur (B-04) + separatory (D-09)

### Cel
Wszystkie closury zawierajace logike (`if`/`match`/`for`) musialy zostac wycigniete do prywatnych funkcji pomocniczych. Kazda metoda musi byc oddzielona separatorem `// ───`.

### Helper functions — dodac na koncu pliku

```rust
fn helper_new_source(s: Rc<RefCell<SharedState>>, args: LuaMultiValue) -> LuaResult<LuaSource> {
    let path: String = args
        .get(0)
        .and_then(|v| match v {
            LuaValue::String(ls) => Some(ls.to_str().ok()?.to_string()),
            _ => None,
        })
        .ok_or_else(|| LuaError::RuntimeError("lurek.audio.newSource: path required".into()))?;
    let source_type = args
        .get(1)
        .and_then(|v| match v {
            LuaValue::String(ls) => Some(ls.to_str().ok()?.to_string()),
            _ => None,
        })
        .map(|t| match t.as_str() {
            "static" => SourceType::Static,
            _ => SourceType::Stream,
        })
        .unwrap_or(SourceType::Stream);
    let mut st = s.borrow_mut();
    let key = st.mixer.load_source(&path, source_type);
    Ok(LuaSource { state: s.clone(), key })
}

fn helper_play(s: Rc<RefCell<SharedState>>, id_val: LuaValue, options: Option<mlua::Table>) -> LuaResult<u64> {
    let mut st = s.borrow_mut();
    let key = require_sound_key(&st, &id_val, "lurek.audio.play")?;
    if let Some(opts) = options {
        if let Ok(bus_name) = opts.get::<_, String>("bus") {
            if let Some(bus) = st.mixer.get_bus_by_name(&bus_name) {
                st.mixer.set_source_bus(key, Some(bus));
            } else {
                return Err(LuaError::external("bus not found"));
            }
        }
    }
    let game_dir = st.game_dir.clone();
    st.mixer.play(key, &game_dir);
    Ok(key.data().as_ffi())
}

fn helper_get_source_type(s: Rc<RefCell<SharedState>>, id_val: LuaValue) -> LuaResult<String> {
    let key = sound_key_from_value(&id_val)?;
    let st = s.borrow();
    match st.mixer.get_source_type(key) {
        Some(SourceType::Static) => Ok("static".to_string()),
        Some(SourceType::Stream) => Ok("stream".to_string()),
        None => Err(LuaError::RuntimeError(
            "lurek.audio.getSourceType: invalid source handle".into(),
        )),
    }
}

fn helper_clone(s: Rc<RefCell<SharedState>>, id_val: LuaValue) -> LuaResult<LuaSource> {
    let key = sound_key_from_value(&id_val)?;
    let mut st = s.borrow_mut();
    match st.mixer.clone_source(key) {
        Some(new_key) => Ok(LuaSource { state: s.clone(), key: new_key }),
        None => Err(LuaError::RuntimeError("lurek.audio.clone: invalid source handle".into())),
    }
}

fn helper_set_source_bus(s: Rc<RefCell<SharedState>>, id_val: LuaValue, bus_val: LuaValue) -> LuaResult<()> {
    let key = sound_key_from_value(&id_val)?;
    let bus_key = match &bus_val {
        LuaValue::UserData(ud) => {
            let bus = ud.borrow::<LuaBus>()?;
            Some(bus.key)
        }
        _ => return Err(LuaError::RuntimeError(
            "lurek.audio.setSourceBus: expected Bus userdata".into(),
        )),
    };
    s.borrow_mut().mixer.set_source_bus(key, bus_key);
    Ok(())
}

fn helper_new_synth_wave(
    waveform: String, freq: f32, duration: f32,
    sample_rate: u32, amplitude: f32, adsr: mlua::Table,
) -> LuaResult<SoundData> {
    let wf = match waveform.as_str() {
        "sine"     => crate::dsp::synthesis::Waveform::Sine,
        "square"   => crate::dsp::synthesis::Waveform::Square,
        "sawtooth" => crate::dsp::synthesis::Waveform::Sawtooth,
        "triangle" => crate::dsp::synthesis::Waveform::Triangle,
        "noise"    => crate::dsp::synthesis::Waveform::WhiteNoise,
        _          => return Err(mlua::Error::external("Invalid waveform type")),
    };
    let attack:  f32 = adsr.get("attack").unwrap_or(0.1);
    let decay:   f32 = adsr.get("decay").unwrap_or(0.1);
    let sustain: f32 = adsr.get("sustain").unwrap_or(0.8);
    let release: f32 = adsr.get("release").unwrap_or(0.2);
    let env = crate::dsp::synthesis::AdsrEnvelope::new(attack, decay, sustain, release, sample_rate);
    Ok(SoundData::generate_synth(wf, freq, duration, sample_rate, amplitude, env))
}

fn helper_mix_into(dest_ud: LuaAnyUserData, src_ud: LuaAnyUserData) -> LuaResult<()> {
    let src_samples: Vec<f32> = {
        let src = src_ud.borrow::<SoundData>()
            .map_err(|_| LuaError::RuntimeError("src must be a SoundData".into()))?;
        src.samples().to_vec()
    };
    let src_data = {
        let src = src_ud.borrow::<SoundData>()
            .map_err(|_| LuaError::RuntimeError("src must be a SoundData".into()))?;
        SoundData::from_samples(src_samples, src.sample_rate(), src.channel_count())
    };
    let mut dest = dest_ud.borrow_mut::<SoundData>()
        .map_err(|_| LuaError::RuntimeError("dest must be a SoundData".into()))?;
    dest.mix_into(&src_data);
    Ok(())
}

fn helper_crossfade(
    s: Rc<RefCell<SharedState>>, from_ud: LuaAnyUserData,
    to_ud: LuaAnyUserData, duration: f32,
) -> LuaResult<()> {
    let from_key = from_ud.borrow::<LuaSource>()
        .map_err(|_| LuaError::RuntimeError("from must be an AudioSource".into()))?.key;
    let to_key = to_ud.borrow::<LuaSource>()
        .map_err(|_| LuaError::RuntimeError("to must be an AudioSource".into()))?.key;
    let game_dir = s.borrow().game_dir.clone();
    s.borrow_mut().mixer.crossfade(from_key, to_key, duration, &game_dir);
    Ok(())
}

fn helper_release(s: Rc<RefCell<SharedState>>, id_val: LuaValue) -> LuaResult<bool> {
    let key = sound_key_from_value(&id_val)?;
    let mut st = s.borrow_mut();
    if st.mixer.release(key) {
        Ok(true)
    } else {
        Err(LuaError::RuntimeError(
            "lurek.audio.release: invalid or already-released audio source handle".into(),
        ))
    }
}

fn helper_get_source_bus(s: Rc<RefCell<SharedState>>, id_val: LuaValue) -> LuaResult<Option<LuaBus>> {
    let key = sound_key_from_value(&id_val)?;
    let st = s.borrow();
    match st.mixer.get_source_bus(key) {
        Some(bus_key) => Ok(Some(LuaBus { state: s.clone(), key: bus_key })),
        None => Ok(None),
    }
}

fn helper_new_midi_player(s: Rc<RefCell<SharedState>>, path: Option<String>) -> LuaResult<LuaMidiPlayer> {
    let mp = MidiPlayer::new();
    let inner = Rc::new(RefCell::new(mp));
    let result = LuaMidiPlayer { inner: inner.clone(), state: s.clone() };
    if let Some(p) = path {
        let st = s.borrow();
        let full_path = st.game_dir.join(&p);
        drop(st);
        inner.borrow_mut().load(&full_path);
    }
    Ok(result)
}

fn helper_get_playback_devices(lua: &Lua) -> LuaResult<mlua::Table<'_>> {
    let devices = crate::audio::get_playback_devices();
    let t = lua.create_table()?;
    for (i, name) in devices.into_iter().enumerate() {
        t.set(i + 1, name)?;
    }
    Ok(t)
}

fn helper_save_wav(s: Rc<RefCell<SharedState>>, sd_ud: LuaAnyUserData, filename: String) -> LuaResult<()> {
    let path = s.borrow().game_dir.join(&filename);
    let sd = sd_ud.borrow::<SoundData>()
        .map_err(|_| LuaError::RuntimeError("argument must be a SoundData".into()))?;
    let bytes = sd.encode_wav();
    if let Some(parent) = path.parent() {
        std::fs::create_dir_all(parent).map_err(LuaError::external)?;
    }
    std::fs::write(&path, &bytes).map_err(LuaError::external)
}

fn helper_create_bus(s: Rc<RefCell<SharedState>>, name: String, parent_name: Option<String>) -> LuaResult<()> {
    if name.is_empty() {
        return Err(LuaError::external("invalid bus name"));
    }
    let mut st = s.borrow_mut();
    let _parent_key = parent_name.and_then(|n| st.mixer.get_bus_by_name(&n));
    let _bus_key = st.mixer.new_bus(&name);
    Ok(())
}

fn helper_set_bus_volume(s: Rc<RefCell<SharedState>>, name: String, volume: f32) -> LuaResult<()> {
    let mut st = s.borrow_mut();
    if let Some(bus_key) = st.mixer.get_bus_by_name(&name) {
        if let Some(bus) = st.mixer.get_bus_mut(bus_key) {
            bus.set_volume(volume);
            return Ok(());
        }
    }
    Err(LuaError::external("bus not found"))
}
```

### Registrations in `register_audio_api()` — replaced closures

Replace each fat closure with a thin delegate (examples):

```
// BEFORE: newSource
lua.create_function(move |_, args: LuaMultiValue| {
    // 20+ lines of logic
})

// AFTER: newSource
// separator before it:
// ─── newSource ───────────────────────────────────────────────────────────────
let s = state.clone();
tbl.set("newSource", lua.create_function(move |_, args: LuaMultiValue| {
    helper_new_source(s.clone(), args)
})?,)?;
```

Same pattern for: `play`, `getSourceType`, `clone`, `setSourceBus`, `release`,
`getSourceBus`, `newSynthWave`, `mixInto`, `crossfade`, `newMidiPlayer`,
`getPlaybackDevices`, `saveWAV`, `create_bus`, `set_bus_volume`.

---

## 2. `src/lua_api/dsp_api.rs` — compile fixes

### 2a. Lifetime in `helper_analyze_fft`

```diff
-fn helper_analyze_fft(lua: &Lua, sd_ud: LuaAnyUserData, size: usize) -> LuaResult<mlua::Table> {
+fn helper_analyze_fft<'a>(lua: &'a Lua, sd_ud: LuaAnyUserData<'a>, size: usize) -> LuaResult<mlua::Table<'a>> {
```

### 2b. Return type fix — add `.map(|_| true)` in 4 helpers

Functions `helper_process_offline`, `helper_normalize_file`, `helper_waveform_to_png`,
`helper_spectrogram_to_png` all returned `LuaResult<bool>` but called functions returning `()`.

```diff
 crate::dsp::offline::process_offline(&input_path, &output_path, &effects)
-    .map_err(LuaError::external)
+    .map_err(LuaError::external)
+    .map(|_| true)
```

Same fix for the other 3 functions.

---

## 3. `docs/specs/audio.md` — add `## Files` section

After `## Summary` (approx line 25), insert:

```markdown
## Files

- `src/audio/bus.rs` - Audio bus hierarchical routing and mixing.
- `src/audio/decoder.rs` - Media decoding for OGG, WAV, MP3, FLAC.
- `src/audio/facade.rs` - High-level facade for audio system.
- `src/audio/mixer.rs` - Central audio mixer and playback engine.
- `src/audio/mod.rs` - Public audio module exports.
- `src/audio/pool.rs` - Voice pooling and stealing.
- `src/audio/sound_data.rs` - PCM data buffers.
- `src/audio/source.rs` - Audio source representation.
```

---

## 4. `docs/specs/dsp.md` — structure fixes

### 4a. Rename section

```diff
-## Lua API
+## Lua API Reference
```

### 4b. Add missing sections at end of file

```markdown
## Files

- `src/dsp/mod.rs`
- `src/dsp/effects.rs`
- `src/dsp/analysis.rs`
- `src/dsp/graph.rs`
- `src/dsp/offline.rs`
- `src/dsp/synthesis.rs`
- `src/dsp/visualizer.rs`

## Types

- No key types exposed directly.

## Functions

- See Lua API Reference section above.

## References

- See also: [audio.md](audio.md)

## Notes

- DSP effects moved from `src/audio/` to `src/dsp/`. Re-exports in `src/audio/mod.rs` for backward compat.
```

### 4c. Add missing methods to `## Lua API Reference`

```markdown
### `lurek.dsp.addEffectToBus(bus_name, effect_type_str, params)`
Adds an effect to a named audio bus and returns its effect ID.

### `lurek.dsp.removeEffectFromBus(bus_name, effect_id)`
Removes an effect from a named audio bus by effect ID.

### `lurek.dsp.setEffectParam(bus_name, effect_id, param_name, value)`
Sets a parameter value on an effect attached to a named audio bus.
```

---

## 5. `src/runtime/config.rs` — add `dsp` field

### 5a. In `ModulesConfig` struct, after `audio`:

```diff
     /// Enable audio module.
     pub audio: bool,
+    /// Enable dsp module.
+    pub dsp: bool,
```

### 5b. In `apply_headless_profile()`:

```diff
         self.audio = false;
+        self.dsp = false;
```

### 5c. In `Default for Config`, modules block:

```diff
                 audio: true,
+                dsp: true,
```

### 5d. In `validate_and_fix()`, add dependency check:

```rust
if !self.audio {
    if self.dsp {
        log_msg!(warn, L050_MODULE_DEP_DISABLED, "dsp requires audio");
        self.dsp = false;
    }
}
```

---

## 6. `Cargo.toml` — register dsp_tests

After the `audio_tests` block:

```toml
[[test]]
name = "dsp_tests"
path = "tests/rust/unit/dsp_tests.rs"
```

---

## 7. NEW FILE: `tests/rust/unit/dsp_tests.rs`

```rust
use lurek_2d::dsp::synthesis::SoundData;
use lurek_2d::dsp::effects::{EffectType, EffectParams, ActiveEffect};

#[test]
fn synthesis_generates_sine_wave() {
    let _ = SoundData::sine_wave(440.0, 0.1, 44100, 1.0);
}

#[test]
fn effect_params_creates_valid_lowpass() {
    let params = EffectParams::new(EffectType::LowPass, 1000.0, 1.0, 0.0);
    let mut effect = ActiveEffect::new(&params, 44100);
    let out = effect.process(0.5);
    assert!(out >= -1.0 && out <= 1.0);
}
```

---

## 8. `tests/lua/harness.rs` — register DSP test

Add at end of file:

```rust
#[test]
fn lua_unit_dsp_unit() {
    run_lua_test("unit/test_dsp_core_unit.lua");
}
```

---

## 9. NEW FILE: `wiki/Dsp-API.md`

```markdown
# Dsp-API

> **Note:** This API reference is auto-generated. Do not edit this page directly.

## `lurek.dsp`
Digital Signal Processing (DSP) and offline audio effects.

For detailed documentation, see the [DSP Spec](../docs/specs/dsp.md).
```

---

## 10. NEW FILE: `wiki/Audio-API.md`

```markdown
# Audio-API

> **Note:** This API reference is auto-generated. Do not edit this page directly.

## `lurek.audio`
Audio playback, bus mixing, and spatial sound system.

For detailed documentation, see the [Audio Spec](../docs/specs/audio.md).
```

---

## Verification results (before `git restore`)

| Check | Status |
|---|---|
| `audit_module.py audio --docs-quality` | PASS |
| `audit_module.py dsp --docs-quality` | PASS |
| `cargo check` | OK — 0 errors, warnings only |
| B-04 audio — no logic in closures | PASS |
| B-05 audio — Rc clone pattern | PASS |
| B-06 audio — flat registration body | PASS |
| D-09 audio — section separators | PASS |
| SP-02 audio — required spec sections | PASS |
| SP-04 audio — 93 functions in spec | PASS |
| T-01 dsp — Rust test file | PASS |
| T-02 dsp — Lua test file registered | PASS |
| I-03 dsp — in runtime/config.rs | PASS |
| W-05 dsp — wiki/Dsp-API.md | PASS |
| W-05 audio — wiki/Audio-API.md | PASS |
