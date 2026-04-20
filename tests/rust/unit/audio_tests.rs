//! Tests for the audio module.

use lurek2d::audio::dsp::{AtomicParam, EffectParams, EffectType};
use lurek2d::audio::offline::OfflineEffect;
use lurek2d::audio::pool::SoundPool;
use lurek2d::audio::*;
use lurek2d::runtime::resource_keys::SoundKey;
use slotmap::SlotMap;

// ── bus tests ────────────────────────────────────────────────────────────────

mod bus_tests {
    use super::*;

    #[test]
    fn new_bus_defaults() {
        let bus = Bus::new("sfx");
        assert_eq!(bus.name(), "sfx");
        assert_eq!(bus.volume(), 1.0);
        assert_eq!(bus.pitch(), 1.0);
        assert!(!bus.is_paused());
        assert!(bus.duck_target.is_none());
    }

    #[test]
    fn set_volume_clamps_negative() {
        let mut bus = Bus::new("music");
        bus.set_volume(-0.5);
        assert_eq!(bus.volume(), 0.0);
    }

    #[test]
    fn set_volume_allows_positive() {
        let mut bus = Bus::new("music");
        bus.set_volume(0.75);
        assert_eq!(bus.volume(), 0.75);
    }

    #[test]
    fn set_pitch_clamps_negative() {
        let mut bus = Bus::new("sfx");
        bus.set_pitch(-1.0);
        assert_eq!(bus.pitch(), 0.0);
    }

    #[test]
    fn pause_and_resume() {
        let mut bus = Bus::new("sfx");
        assert!(!bus.is_paused());
        bus.pause();
        assert!(bus.is_paused());
        bus.resume();
        assert!(!bus.is_paused());
    }

    #[test]
    fn add_effect_valid_types() {
        let bus = Bus::new("fx");
        let id = bus.add_effect("lowpass", 1000.0);
        assert!(id.is_ok());
        assert_eq!(id.unwrap(), 1);

        let id2 = bus.add_effect("reverb", 0.8);
        assert!(id2.is_ok());
        assert_eq!(id2.unwrap(), 2);
    }

    #[test]
    fn add_effect_invalid_type() {
        let bus = Bus::new("fx");
        let result = bus.add_effect("nonexistent", 0.0);
        assert!(result.is_err());
    }

    #[test]
    fn remove_effect() {
        let bus = Bus::new("fx");
        let id = bus.add_effect("lowpass", 1000.0).unwrap();
        assert!(bus.remove_effect(id).is_ok());
        // Removing again should fail
        assert!(bus.remove_effect(id).is_err());
    }

    #[test]
    fn set_duck_target_clamps_volume() {
        let mut bus = Bus::new("dialogue");
        bus.set_duck_target("music", 1.5);
        let (name, vol) = bus.duck_target.as_ref().unwrap();
        assert_eq!(name, "music");
        assert_eq!(*vol, 1.0); // clamped to max 1.0
    }

    #[test]
    fn clear_duck_target() {
        let mut bus = Bus::new("dialogue");
        bus.set_duck_target("music", 0.3);
        assert!(bus.duck_target.is_some());
        bus.clear_duck_target();
        assert!(bus.duck_target.is_none());
    }
}

// ── dsp tests ────────────────────────────────────────────────────────────────

mod dsp_tests {
    use super::*;

    #[test]
    fn atomic_param_get_set() {
        let p = AtomicParam::new(3.14);
        assert!((p.get() - 3.14).abs() < 0.001);
        p.set(2.0);
        assert!((p.get() - 2.0).abs() < 0.001);
    }

    #[test]
    fn effect_params_set_param_lowpass() {
        let ep = EffectParams::new(1, EffectType::Lowpass);
        assert!(ep.set_param("cutoff", 1000.0).is_ok());
        assert!((ep.p1.get() - 1000.0).abs() < 0.001);
        assert!(ep.set_param("q", 0.707).is_ok());
        assert!((ep.p2.get() - 0.707).abs() < 0.001);
        assert!(ep.set_param("invalid", 0.0).is_err());
    }

    #[test]
    fn effect_params_set_param_reverb() {
        let ep = EffectParams::new(2, EffectType::Reverb);
        assert!(ep.set_param("room_size", 0.8).is_ok());
        assert!(ep.set_param("damping", 0.4).is_ok());
        assert!(ep.set_param("mix", 0.3).is_ok());
        assert!((ep.p3.get() - 0.3).abs() < 0.001);
    }

    #[test]
    fn effect_params_set_param_compressor() {
        let ep = EffectParams::new(3, EffectType::Compressor);
        assert!(ep.set_param("threshold", -12.0).is_ok());
        assert!(ep.set_param("ratio", 4.0).is_ok());
        assert!(ep.set_param("makeup_gain", 6.0).is_ok());
        assert!(ep.set_param("unknown", 0.0).is_err());
    }

    #[test]
    fn effect_type_variants_distinct() {
        assert_ne!(EffectType::Lowpass, EffectType::Highpass);
        assert_eq!(EffectType::Lowpass, EffectType::Lowpass);
    }
}

// ── midi tests ───────────────────────────────────────────────────────────────

mod midi_tests {
    use super::*;

    fn make_fake_sf2(size: usize) -> Vec<u8> {
        let mut data = vec![0u8; size.max(12)];
        data[0..4].copy_from_slice(b"RIFF");
        data[8..12].copy_from_slice(b"sfbk");
        data
    }

    #[test]
    fn new_state_has_no_soundfont() {
        let state = MidiState::new();
        assert!(!state.has_soundfont());
        assert!(state.soundfont_path().is_none());
        assert!(state.soundfont_data().is_none());
    }

    #[test]
    fn set_and_check_soundfont() {
        let mut state = MidiState::new();
        let sf2 = make_fake_sf2(64);
        state
            .set_soundfont(sf2, Some("test.sf2".to_string()))
            .unwrap();
        assert!(state.has_soundfont());
        assert_eq!(state.soundfont_path(), Some("test.sf2"));
        assert!(state.soundfont_data().unwrap().len() >= 12);
    }

    #[test]
    fn clear_soundfont() {
        let mut state = MidiState::new();
        state.set_soundfont(make_fake_sf2(64), None).unwrap();
        assert!(state.has_soundfont());
        state.clear_soundfont();
        assert!(!state.has_soundfont());
        assert!(state.soundfont_path().is_none());
    }

    #[test]
    fn reject_too_small() {
        let mut state = MidiState::new();
        let result = state.set_soundfont(vec![0u8; 4], None);
        assert!(result.is_err());
        assert!(result.unwrap_err().contains("too small"));
    }

    #[test]
    fn reject_invalid_header() {
        let mut state = MidiState::new();
        let result = state.set_soundfont(vec![0u8; 16], None);
        assert!(result.is_err());
        assert!(result.unwrap_err().contains("RIFF"));
    }

    #[test]
    fn reject_non_sf2_riff() {
        let mut state = MidiState::new();
        let mut data = vec![0u8; 16];
        data[0..4].copy_from_slice(b"RIFF");
        data[8..12].copy_from_slice(b"WAVE"); // not sfbk
        let result = state.set_soundfont(data, None);
        assert!(result.is_err());
        assert!(result.unwrap_err().contains("sfbk"));
    }

    #[test]
    fn default_is_empty() {
        let state = MidiState::default();
        assert!(!state.has_soundfont());
    }
}

// ── midi_player tests ────────────────────────────────────────────────────────

mod midi_player_tests {
    use super::*;

    #[test]
    fn new_player_defaults() {
        let p = MidiPlayer::new();
        assert!(!p.is_loaded());
        assert!(!p.is_playing());
        assert!(!p.is_paused());
        assert_eq!(p.volume(), 1.0);
        assert!(!p.is_looping());
        assert_eq!(p.tempo_scale(), 1.0);
        assert_eq!(p.current_bpm(), 120.0);
        assert_eq!(p.tell(), 0.0);
        assert_eq!(p.duration(), 0.0);
        assert!(p.file_path().is_none());
        assert!(p.bus_key().is_none());
    }

    #[test]
    fn default_impl_matches_new() {
        let a = MidiPlayer::new();
        let b = MidiPlayer::default();
        assert_eq!(a.volume(), b.volume());
        assert_eq!(a.is_looping(), b.is_looping());
        assert_eq!(a.tempo_scale(), b.tempo_scale());
    }

    #[test]
    fn volume_set_get() {
        let mut p = MidiPlayer::new();
        p.set_volume(0.5);
        assert_eq!(p.volume(), 0.5);
        p.set_volume(-1.0);
        assert_eq!(p.volume(), 0.0); // clamped
    }

    #[test]
    fn looping_toggle() {
        let mut p = MidiPlayer::new();
        assert!(!p.is_looping());
        p.set_looping(true);
        assert!(p.is_looping());
    }

    #[test]
    fn tempo_scale_clamps_low() {
        let mut p = MidiPlayer::new();
        p.set_tempo_scale(0.001);
        assert_eq!(p.tempo_scale(), 0.01);
    }

    #[test]
    fn channel_volume_and_mute() {
        let mut p = MidiPlayer::new();
        p.set_channel_volume(3, 0.5);
        assert_eq!(p.channel_volume(3), 0.5);
        assert_eq!(p.channel_volume(16), 0.0); // out of range

        p.set_channel_muted(3, true);
        assert!(p.is_channel_muted(3));
        assert!(!p.is_channel_muted(0));
    }

    #[test]
    fn solo_mutes_others() {
        let mut p = MidiPlayer::new();
        p.solo_channel(5);
        for i in 0..16 {
            if i == 5 {
                assert!(!p.is_channel_muted(i));
            } else {
                assert!(p.is_channel_muted(i));
            }
        }
        p.unsolo_all();
        assert!(!p.is_channel_muted(0));
    }

    #[test]
    fn channel_instrument() {
        let mut p = MidiPlayer::new();
        p.set_channel_instrument(0, 42);
        assert_eq!(p.channel_instrument(0), 42);
        assert_eq!(p.channel_instrument(16), 0); // out of range
    }

    #[test]
    fn output_sample_rate_clamps() {
        let mut p = MidiPlayer::new();
        assert_eq!(p.get_output_sample_rate(), 44100);
        p.set_output_sample_rate(100);
        assert_eq!(p.get_output_sample_rate(), 8000);
        p.set_output_sample_rate(500_000);
        assert_eq!(p.get_output_sample_rate(), 192_000);
    }

    #[test]
    fn output_channels_clamps() {
        let mut p = MidiPlayer::new();
        assert_eq!(p.get_output_channels(), 2);
        p.set_output_channels(0);
        assert_eq!(p.get_output_channels(), 1);
        p.set_output_channels(5);
        assert_eq!(p.get_output_channels(), 2);
    }

    #[test]
    fn seek_and_tell() {
        let mut p = MidiPlayer::new();
        p.seek(5.0);
        assert_eq!(p.tell(), 5.0);
        p.seek(-1.0);
        assert_eq!(p.tell(), 0.0); // clamped
    }

    #[test]
    fn load_data_disabled_returns_false() {
        let mut p = MidiPlayer::new();
        assert!(!p.load_data(vec![1, 2, 3]));
        assert!(!p.is_loaded());
    }

    #[test]
    fn stop_resets_state() {
        let mut p = MidiPlayer::new();
        p.seek(5.0);
        p.stop();
        assert_eq!(p.tell(), 0.0);
        assert_eq!(p.play_state(), PlayState::Stopped);
    }
}

// ── mixer tests ──────────────────────────────────────────────────────────────

mod mixer_tests {
    use super::*;

    #[test]
    fn mixer_new_defaults() {
        let m = Mixer::new();
        assert_eq!(m.get_master_volume(), 1.0);
        assert_eq!(m.get_source_count(), 0);
        assert_eq!(m.get_active_source_count(), 0);
    }

    #[test]
    fn load_source_returns_key() {
        let mut m = Mixer::new();
        let key = m.load_source("sfx/boom.ogg", SourceType::Static);
        assert!(m.contains_source(key));
        assert_eq!(m.get_source_count(), 1);
    }

    #[test]
    fn load_source_stream_type() {
        let mut m = Mixer::new();
        let key = m.load_source("music/bg.ogg", SourceType::Stream);
        assert_eq!(m.get_source_type(key), Some(SourceType::Stream));
    }

    #[test]
    fn release_source() {
        let mut m = Mixer::new();
        let key = m.load_source("sfx/a.ogg", SourceType::Static);
        assert!(m.release(key));
        assert!(!m.contains_source(key));
        assert!(!m.release(key)); // second release returns false
    }

    #[test]
    fn volume_clamp_and_get() {
        let mut m = Mixer::new();
        let key = m.load_source("sfx/a.ogg", SourceType::Static);
        m.set_volume(key, 1.5);
        assert_eq!(m.get_volume(key), 1.5);
        m.set_volume(key, 3.0); // clamped to 2.0
        assert_eq!(m.get_volume(key), 2.0);
        m.set_volume(key, -1.0); // clamped to 0.0
        assert_eq!(m.get_volume(key), 0.0);
    }

    #[test]
    fn pitch_clamp() {
        let mut m = Mixer::new();
        let key = m.load_source("sfx/a.ogg", SourceType::Static);
        m.set_pitch(key, 2.0);
        assert_eq!(m.get_pitch(key), 2.0);
        m.set_pitch(key, 0.01); // below min
        assert_eq!(m.get_pitch(key), 0.1);
        m.set_pitch(key, 10.0); // above max
        assert_eq!(m.get_pitch(key), 4.0);
    }

    #[test]
    fn pan_clamp() {
        let mut m = Mixer::new();
        let key = m.load_source("sfx/a.ogg", SourceType::Static);
        m.set_pan(key, -2.0);
        assert_eq!(m.get_pan(key), -1.0);
        m.set_pan(key, 2.0);
        assert_eq!(m.get_pan(key), 1.0);
    }

    #[test]
    fn looping_flag() {
        let mut m = Mixer::new();
        let key = m.load_source("sfx/a.ogg", SourceType::Static);
        assert!(!m.is_looping(key));
        m.set_looping(key, true);
        assert!(m.is_looping(key));
    }

    #[test]
    fn master_volume_clamp() {
        let mut m = Mixer::new();
        m.set_master_volume(0.5);
        assert_eq!(m.get_master_volume(), 0.5);
        m.set_master_volume(-0.1);
        assert_eq!(m.get_master_volume(), 0.0);
        m.set_master_volume(2.0);
        assert_eq!(m.get_master_volume(), 1.0);
    }

    #[test]
    fn bus_create_and_lookup() {
        let mut m = Mixer::new();
        let bk = m.new_bus("music");
        assert!(m.get_bus(bk).is_some());
        assert_eq!(m.get_bus(bk).unwrap().name(), "music");
        assert_eq!(m.get_bus_by_name("music"), Some(bk));
        assert!(m.get_bus_by_name("nonexistent").is_none());
    }

    #[test]
    fn source_bus_assignment() {
        let mut m = Mixer::new();
        let bk = m.new_bus("sfx");
        let key = m.load_source("sfx/a.ogg", SourceType::Static);
        assert!(m.get_source_bus(key).is_none());
        m.set_source_bus(key, Some(bk));
        assert_eq!(m.get_source_bus(key), Some(bk));
        m.set_source_bus(key, None);
        assert!(m.get_source_bus(key).is_none());
    }

    #[test]
    fn clone_source_shares_properties() {
        let mut m = Mixer::new();
        let key = m.load_source("sfx/a.ogg", SourceType::Static);
        m.set_volume(key, 0.7);
        m.set_looping(key, true);
        let cloned = m.clone_source(key).unwrap();
        assert_ne!(key, cloned);
        assert_eq!(m.get_volume(cloned), 0.7);
        assert!(m.is_looping(cloned));
        // Clone starts stopped
        assert!(m.is_stopped(cloned));
    }

    #[test]
    fn filter_get_set() {
        let mut m = Mixer::new();
        let key = m.load_source("sfx/a.ogg", SourceType::Static);
        assert!(m.get_lowpass(key).is_none());
        m.set_lowpass(key, 4000);
        assert_eq!(m.get_lowpass(key), Some(4000));
        m.set_highpass(key, 200);
        assert_eq!(m.get_highpass(key), Some(200));
        m.clear_filter(key);
        assert!(m.get_lowpass(key).is_none());
        assert!(m.get_highpass(key).is_none());
    }

    #[test]
    fn fade_in_get_set() {
        let mut m = Mixer::new();
        let key = m.load_source("sfx/a.ogg", SourceType::Static);
        assert!(m.get_fade_in(key).is_none());
        m.set_fade_in(key, 0.5);
        assert_eq!(m.get_fade_in(key), Some(0.5));
        m.clear_fade_in(key);
        assert!(m.get_fade_in(key).is_none());
    }

    #[test]
    fn peak_set_get() {
        let mut m = Mixer::new();
        let key = m.load_source("sfx/a.ogg", SourceType::Static);
        assert_eq!(m.get_peak(key), 0.0);
        m.set_peak(key, 0.8);
        assert_eq!(m.get_peak(key), 0.8);
        m.set_peak(key, 2.0); // clamped
        assert_eq!(m.get_peak(key), 1.0);
    }

    #[test]
    fn bus_peak_average() {
        let mut m = Mixer::new();
        let bk = m.new_bus("sfx");
        let k1 = m.load_source("a.ogg", SourceType::Static);
        let k2 = m.load_source("b.ogg", SourceType::Static);
        m.set_source_bus(k1, Some(bk));
        m.set_source_bus(k2, Some(bk));
        m.set_peak(k1, 0.4);
        m.set_peak(k2, 0.6);
        assert!((m.bus_peak(bk) - 0.5).abs() < 0.001);
    }

    #[test]
    fn stereo_width_set_get() {
        let mut m = Mixer::new();
        let key = m.load_source("sfx/a.ogg", SourceType::Static);
        assert_eq!(m.get_stereo_width(key).unwrap(), 1.0);
        m.set_stereo_width(key, 0.5).unwrap();
        assert_eq!(m.get_stereo_width(key).unwrap(), 0.5);
    }

    #[test]
    fn random_pitch_set_clear() {
        let mut m = Mixer::new();
        let key = m.load_source("sfx/a.ogg", SourceType::Static);
        assert!(m.set_random_pitch(key, 0.9, 1.1).is_ok());
        assert!(m.set_random_pitch(key, 1.5, 0.5).is_err()); // min > max
        m.clear_random_pitch(key);
    }

    #[test]
    fn listener_position() {
        let mut m = Mixer::new();
        m.set_listener_position(10.0, 20.0, 0.0);
        assert_eq!(m.get_listener_position(), [10.0, 20.0, 0.0]);
    }

    #[test]
    fn doppler_scale() {
        let mut m = Mixer::new();
        m.set_doppler_scale(2.0);
        assert_eq!(m.get_doppler_scale(), 2.0);
        m.set_doppler_scale(-1.0);
        assert_eq!(m.get_doppler_scale(), 0.0);
    }

    #[test]
    fn distance_model() {
        let mut m = Mixer::new();
        assert_eq!(m.get_distance_model(), "inverse_clamped");
        m.set_distance_model("linear");
        assert_eq!(m.get_distance_model(), "linear");
    }

    #[test]
    fn source_position_and_pan() {
        let mut m = Mixer::new();
        let key = m.load_source("sfx/a.ogg", SourceType::Static);
        m.set_source_position(key, 100.0, 0.0, 0.0);
        let pos = m.get_source_position(key);
        assert_eq!(pos, [100.0, 0.0, 0.0]);
        // Pan should be computed from dx / 200: (100 - 0) / 200 = 0.5
        assert_eq!(m.get_pan(key), 0.5);
    }

    #[test]
    fn new_pool_creates_voices() {
        let mut m = Mixer::new();
        let pool = m.new_pool("sfx/hit.ogg", 4).unwrap();
        assert_eq!(pool.voice_count(), 4);
        assert_eq!(m.get_source_count(), 4);
    }

    #[test]
    fn new_pool_zero_voices_errors() {
        let mut m = Mixer::new();
        assert!(m.new_pool("sfx/hit.ogg", 0).is_err());
    }

    #[test]
    fn queueable_lifecycle() {
        let mut m = Mixer::new();
        let qk = m.new_queueable(44100, 16, 2, 4);
        assert_eq!(m.queueable_free_buffer_count(qk), 4);
        m.queue_buffer(qk, &[0.0, 0.1, 0.2]).unwrap();
        assert_eq!(m.queueable_free_buffer_count(qk), 3);
        m.stop_queueable(qk);
        assert_eq!(m.queueable_free_buffer_count(qk), 4);
        assert!(m.release_queueable(qk));
    }

    #[test]
    fn stop_all_clears_state() {
        let mut m = Mixer::new();
        let k1 = m.load_source("a.ogg", SourceType::Static);
        let k2 = m.load_source("b.ogg", SourceType::Static);
        m.stop_all();
        assert!(m.is_stopped(k1));
        assert!(m.is_stopped(k2));
    }
}

// ── mod (top-level) tests ────────────────────────────────────────────────────

mod mod_tests {
    use super::*;

    #[test]
    fn audio_source_new_stores_path() {
        let src = AudioSource::new(1, "assets/test.ogg");
        assert_eq!(src.file_path, "assets/test.ogg");
    }

    #[test]
    fn get_playback_devices_returns_default() {
        let devs = get_playback_devices();
        assert!(!devs.is_empty());
        assert!(devs.contains(&"Default".to_string()));
    }

    #[test]
    fn get_playback_device_returns_default() {
        assert_eq!(get_playback_device(), "Default");
    }

    #[test]
    fn set_playback_device_valid() {
        assert!(set_playback_device("Default").is_ok());
    }

    #[test]
    fn set_playback_device_invalid() {
        let result = set_playback_device("Nonexistent Device XYZ");
        assert!(result.is_err());
    }
}

// ── offline tests ────────────────────────────────────────────────────────────

mod offline_tests {
    use super::*;

    #[test]
    fn normalize_rejects_zero_target() {
        let result = lurek2d::audio::offline::normalize_file("dummy.wav", "out.wav", 0.0);
        assert!(result.is_err());
        assert!(result.unwrap_err().contains("(0.0, 1.0]"));
    }

    #[test]
    fn normalize_rejects_above_one() {
        let result = lurek2d::audio::offline::normalize_file("dummy.wav", "out.wav", 1.5);
        assert!(result.is_err());
    }

    #[test]
    fn offline_effect_struct_fields() {
        let effect = OfflineEffect {
            typ: EffectType::Lowpass,
            p1: 1000.0,
            p2: 0.707,
            p3: 0.5,
        };
        assert_eq!(effect.typ, EffectType::Lowpass);
        assert_eq!(effect.p1, 1000.0);
    }
}

// ── pool tests ───────────────────────────────────────────────────────────────

mod pool_tests {
    use super::*;

    fn make_keys(n: usize) -> Vec<SoundKey> {
        let mut sm: SlotMap<SoundKey, ()> = SlotMap::with_key();
        (0..n).map(|_| sm.insert(())).collect()
    }

    #[test]
    fn new_pool_basics() {
        let keys = make_keys(4);
        let pool = SoundPool::new(keys.clone(), "sfx/hit.ogg".into());
        assert_eq!(pool.voice_count(), 4);
        assert_eq!(pool.file_path(), "sfx/hit.ogg");
        assert!(pool.is_valid());
        assert_eq!(pool.volume(), 1.0);
        assert!(pool.bus_name().is_none());
    }

    #[test]
    fn next_voice_cycles() {
        let keys = make_keys(3);
        let mut pool = SoundPool::new(keys.clone(), "sfx/hit.ogg".into());
        let v0 = pool.next_voice();
        let v1 = pool.next_voice();
        let v2 = pool.next_voice();
        let v3 = pool.next_voice(); // wraps around
        assert_eq!(v0, keys[0]);
        assert_eq!(v1, keys[1]);
        assert_eq!(v2, keys[2]);
        assert_eq!(v3, keys[0]);
    }

    #[test]
    fn volume_and_bus() {
        let keys = make_keys(2);
        let mut pool = SoundPool::new(keys, "sfx.ogg".into());
        pool.set_volume(0.5);
        assert_eq!(pool.volume(), 0.5);
        pool.set_bus("music");
        assert_eq!(pool.bus_name(), Some("music"));
        pool.clear_bus();
        assert!(pool.bus_name().is_none());
    }

    #[test]
    fn empty_pool_invalid() {
        let pool = SoundPool::new(vec![], "x.ogg".into());
        assert!(!pool.is_valid());
        assert_eq!(pool.voice_count(), 0);
    }
}

// ── source tests ─────────────────────────────────────────────────────────────

mod source_tests {
    use super::*;

    #[test]
    fn audio_source_defaults() {
        let src = AudioSource::new(42, "sfx/boom.ogg");
        assert_eq!(src.id, 42);
        assert_eq!(src.file_path, "sfx/boom.ogg");
        assert_eq!(src.volume, 1.0);
        assert!(!src.looping);
    }

    #[test]
    fn spatial_state_default() {
        let s = SpatialState::default();
        assert_eq!(s.position, [0.0, 0.0, 0.0]);
        assert_eq!(s.velocity, [0.0, 0.0, 0.0]);
        // Default orientation: forward = (0,0,-1), up = (0,1,0)
        assert_eq!(s.orientation[2], -1.0);
        assert_eq!(s.orientation[4], 1.0);
    }
}

// ── sound_data tests ─────────────────────────────────────────────────────────

mod sound_data_tests {
    use super::*;

    #[test]
    fn new_silent_buffer() {
        let sd = SoundData::new(100, 44100, 1);
        assert_eq!(sd.sample_count(), 100);
        assert_eq!(sd.sample_rate(), 44100);
        assert_eq!(sd.channel_count(), 1);
        assert!(sd.samples().iter().all(|&s| s == 0.0));
    }

    #[test]
    fn get_and_set_sample() {
        let mut sd = SoundData::new(10, 44100, 1);
        assert_eq!(sd.get_sample(0), Some(0.0));
        assert!(sd.set_sample(0, 0.5));
        assert_eq!(sd.get_sample(0), Some(0.5));
    }

    #[test]
    fn set_sample_clamps() {
        let mut sd = SoundData::new(10, 44100, 1);
        sd.set_sample(0, 5.0);
        assert_eq!(sd.get_sample(0), Some(1.0));
        sd.set_sample(0, -5.0);
        assert_eq!(sd.get_sample(0), Some(-1.0));
    }

    #[test]
    fn set_sample_out_of_range() {
        let mut sd = SoundData::new(10, 44100, 1);
        assert!(!sd.set_sample(100, 0.5));
    }

    #[test]
    fn duration_calculation() {
        let sd = SoundData::new(44100, 44100, 1);
        assert!((sd.duration() - 1.0).abs() < 0.001);
    }

    #[test]
    fn from_samples_stores_data() {
        let samples = vec![0.1, 0.2, 0.3, 0.4];
        let sd = SoundData::from_samples(samples.clone(), 22050, 2);
        assert_eq!(sd.sample_count(), 2); // 4 interleaved samples / 2 channels
        assert_eq!(sd.channel_count(), 2);
        assert_eq!(sd.samples(), &samples[..]);
    }

    #[test]
    fn sine_wave_generates_correct_length() {
        let sd = SoundData::sine_wave(440.0, 1.0, 44100, 0.5);
        assert_eq!(sd.sample_count(), 44100);
        assert_eq!(sd.channel_count(), 1);
        // First sample should be near 0 (sin(0) = 0)
        assert!(sd.get_sample(0).unwrap().abs() < 0.01);
    }

    #[test]
    fn square_wave_alternates() {
        let sd = SoundData::square_wave(1.0, 1.0, 100, 1.0);
        // First half of period should be positive, second half negative
        assert!(sd.get_sample(0).unwrap() > 0.0);
        assert!(sd.get_sample(75).unwrap() < 0.0);
    }

    #[test]
    fn encode_wav_produces_valid_header() {
        let sd = SoundData::new(10, 44100, 1);
        let wav = sd.encode_wav();
        assert_eq!(&wav[0..4], b"RIFF");
        assert_eq!(&wav[8..12], b"WAVE");
        assert_eq!(&wav[12..16], b"fmt ");
    }

    #[test]
    fn apply_gain() {
        let mut sd = SoundData::from_samples(vec![0.5, -0.5], 44100, 1);
        sd.apply_gain(0.5);
        assert!((sd.get_sample(0).unwrap() - 0.25).abs() < 0.001);
        assert!((sd.get_sample(1).unwrap() + 0.25).abs() < 0.001);
    }

    #[test]
    fn mix_into_blends() {
        let mut sd1 = SoundData::from_samples(vec![0.3, 0.3], 44100, 1);
        let sd2 = SoundData::from_samples(vec![0.2, -0.1], 44100, 1);
        sd1.mix_into(&sd2);
        assert!((sd1.get_sample(0).unwrap() - 0.5).abs() < 0.001);
        assert!((sd1.get_sample(1).unwrap() - 0.2).abs() < 0.001);
    }

    #[test]
    fn from_lua_args_silent_buffer() {
        let sd = SoundData::from_lua_args(None, 100, 44100, 1).unwrap();
        assert_eq!(sd.sample_count(), 100);
    }
}

// ── visualizer tests ─────────────────────────────────────────────────────────

mod visualizer_tests {
    use lurek2d::audio::visualizer::{spectrogram_to_png, waveform_to_png};

    #[test]
    fn waveform_to_png_missing_file() {
        let result = waveform_to_png("/nonexistent.wav", "/tmp/out.png", 100, 50);
        assert!(result.is_err());
    }

    #[test]
    fn spectrogram_to_png_missing_file() {
        let result = spectrogram_to_png("/nonexistent.wav", "/tmp/out.png", 100, 50);
        assert!(result.is_err());
    }
}
