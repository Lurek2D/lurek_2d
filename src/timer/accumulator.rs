//! `src/timer/accumulator.rs` owns the microsecond accumulation helper used to turn scaled frame deltas into stable totals.
//! It clamps negative inputs, carries fractional micros forward, and updates elapsed counters without drift.
//! Open this file when time-scaling math, drift behavior, or elapsed-microsecond accumulation rules need to change.

/// Advance `elapsed_micros` by `dt_seconds * scale`, accumulating fractional.
/// microseconds in `carry_micros` to avoid drift; clamps negative inputs to zero.
pub(crate) fn accumulate_scaled_micros(
    elapsed_micros: &mut u64,
    carry_micros: &mut f64,
    dt_seconds: f32,
    scale: f32,
) {
    let delta = (dt_seconds.max(0.0) as f64) * (scale.max(0.0) as f64) * 1_000_000.0;
    let total = *carry_micros + delta;
    let whole = total.floor();
    *carry_micros = total - whole;
    *elapsed_micros = elapsed_micros.saturating_add(whole as u64);
}
