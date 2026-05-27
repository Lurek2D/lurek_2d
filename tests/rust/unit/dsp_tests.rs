//! Rust-only tests for DSP internals that are not directly asserted through `lurek.dsp.*`.

use lurek2d::dsp::{
    ActiveEffect, AtomicParam, EffectParams, EffectType, OfflineEffect,
};
use std::sync::Arc;

#[test]
fn atomic_param_get_set() {
    let param = AtomicParam::new(3.0);
    assert!((param.get() - 3.0).abs() < 0.001);
    param.set(2.0);
    assert!((param.get() - 2.0).abs() < 0.001);
}

#[test]
fn effect_params_set_param_lowpass() {
    let params = EffectParams::new(1, EffectType::Lowpass);
    assert!(params.set_param("cutoff", 1000.0).is_ok());
    assert!((params.p1.get() - 1000.0).abs() < 0.001);
    assert!(params.set_param("q", 0.707).is_ok());
    assert!((params.p2.get() - 0.707).abs() < 0.001);
    assert!(params.set_param("invalid", 0.0).is_err());
}

#[test]
fn effect_params_set_param_reverb() {
    let params = EffectParams::new(2, EffectType::Reverb);
    assert!(params.set_param("room_size", 0.8).is_ok());
    assert!(params.set_param("damping", 0.4).is_ok());
    assert!(params.set_param("mix", 0.3).is_ok());
    assert!((params.p3.get() - 0.3).abs() < 0.001);
}

#[test]
fn effect_params_set_param_compressor() {
    let params = EffectParams::new(3, EffectType::Compressor);
    assert!(params.set_param("threshold", -12.0).is_ok());
    assert!(params.set_param("ratio", 4.0).is_ok());
    assert!(params.set_param("makeup_gain", 6.0).is_ok());
    assert!(params.set_param("unknown", 0.0).is_err());
}

#[test]
fn effect_type_variants_distinct() {
    assert_ne!(EffectType::Lowpass, EffectType::Highpass);
    assert_eq!(EffectType::Lowpass, EffectType::Lowpass);
}

#[test]
fn active_effect_processes_finite_sample() {
    let params = Arc::new(EffectParams::new(4, EffectType::Lowpass));
    params.set_param("cutoff", 1000.0).unwrap();
    let mut effect = ActiveEffect::new(params, 44100, 1);
    let output = effect.process(0.5, 0, 44100);
    assert!(output.is_finite());
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
    assert!((effect.p1 - 1000.0).abs() < 0.001);
}


