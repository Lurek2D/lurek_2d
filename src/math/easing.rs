//! Comprehensive easing function library supporting in/out/in-out variants across quadratic, cubic, quartic, sine, exponential, and elastic motion families.
//! Implements normalized [0,1] input parameter curves producing normalized output ranges enabling composition into tween and animation systems.
//! Handles edge clamping for exponential and elastic curves preventing invalid outputs at boundaries while supporting smooth S-curve acceleration patterns.
//! Provides linear identity passthrough and symmetric in-out variants enabling data-driven animation selection from configuration files.
//! Standardizes easing semantics across animation interpolation enabling consistent motion timing and response characteristics in gameplay animations.

use std::f32::consts::PI;

/// Return `t` unchanged (no-op easing).
pub fn linear(t: f32) -> f32 {
    t
}

/// Ease-in quadratic: accelerates from zero.
pub fn ease_in_quad(t: f32) -> f32 {
    t * t
}

/// Ease-out quadratic: decelerates to zero.
pub fn ease_out_quad(t: f32) -> f32 {
    t * (2.0 - t)
}

/// Ease-in-out quadratic: accelerates then decelerates.
pub fn ease_in_out_quad(t: f32) -> f32 {
    if t < 0.5 {
        2.0 * t * t
    } else {
        -1.0 + (4.0 - 2.0 * t) * t
    }
}

/// Ease-in cubic: accelerates steeply from zero.
pub fn ease_in_cubic(t: f32) -> f32 {
    t * t * t
}

/// Ease-out cubic: decelerates steeply to zero.
pub fn ease_out_cubic(t: f32) -> f32 {
    let u = t - 1.0;
    u * u * u + 1.0
}

/// Ease-in-out cubic: accelerates then decelerates with cubic curve.
pub fn ease_in_out_cubic(t: f32) -> f32 {
    if t < 0.5 {
        4.0 * t * t * t
    } else {
        let u = 2.0 * t - 2.0;
        0.5 * u * u * u + 1.0
    }
}

/// Ease-in quartic: very sharp acceleration from zero.
pub fn ease_in_quart(t: f32) -> f32 {
    t * t * t * t
}

/// Ease-out quartic: very sharp deceleration to zero.
pub fn ease_out_quart(t: f32) -> f32 {
    let u = t - 1.0;
    1.0 - u * u * u * u
}

/// Ease-in-out quartic: sharp acceleration then deceleration.
pub fn ease_in_out_quart(t: f32) -> f32 {
    if t < 0.5 {
        8.0 * t * t * t * t
    } else {
        let u = t - 1.0;
        1.0 - 8.0 * u * u * u * u
    }
}

/// Ease-in sine: gentle cosine-based acceleration.
pub fn ease_in_sine(t: f32) -> f32 {
    1.0 - (t * PI / 2.0).cos()
}

/// Ease-out sine: gentle cosine-based deceleration.
pub fn ease_out_sine(t: f32) -> f32 {
    (t * PI / 2.0).sin()
}

/// Ease-in-out sine: symmetric sine S-curve.
pub fn ease_in_out_sine(t: f32) -> f32 {
    0.5 * (1.0 - (PI * t).cos())
}

/// Ease-in exponential: near-zero until suddenly accelerating; clamped to 0 at t≤0.
pub fn ease_in_expo(t: f32) -> f32 {
    if t <= 0.0 {
        0.0
    } else {
        (2.0_f32).powf(10.0 * (t - 1.0))
    }
}

/// Ease-out exponential: rapid deceleration to 1; clamped to 1 at t≥1.
pub fn ease_out_expo(t: f32) -> f32 {
    if t >= 1.0 {
        1.0
    } else {
        1.0 - (2.0_f32).powf(-10.0 * t)
    }
}

/// Ease-in-out exponential: sharp S-curve; clamped at boundaries.
pub fn ease_in_out_expo(t: f32) -> f32 {
    if t <= 0.0 {
        return 0.0;
    }
    if t >= 1.0 {
        return 1.0;
    }
    if t < 0.5 {
        0.5 * (2.0_f32).powf(20.0 * t - 10.0)
    } else {
        1.0 - 0.5 * (2.0_f32).powf(-20.0 * t + 10.0)
    }
}

/// Ease-in elastic: oscillates before launching; clamped at boundaries.
pub fn ease_in_elastic(t: f32) -> f32 {
    if t <= 0.0 {
        return 0.0;
    }
    if t >= 1.0 {
        return 1.0;
    }
    let p = 0.3_f32;
    -(2.0_f32.powf(10.0 * (t - 1.0)) * ((t - 1.0 - p / 4.0) * 2.0 * PI / p).sin())
}

/// Ease-out elastic: overshoots then oscillates to rest; clamped at boundaries.
pub fn ease_out_elastic(t: f32) -> f32 {
    if t <= 0.0 {
        return 0.0;
    }
    if t >= 1.0 {
        return 1.0;
    }
    let p = 0.3_f32;
    2.0_f32.powf(-10.0 * t) * ((t - p / 4.0) * 2.0 * PI / p).sin() + 1.0
}

/// Ease-in-out elastic: oscillates on both ends; clamped at boundaries.
pub fn ease_in_out_elastic(t: f32) -> f32 {
    if t <= 0.0 {
        return 0.0;
    }
    if t >= 1.0 {
        return 1.0;
    }
    let p = 0.45_f32;
    let s = p / 4.0;
    if t < 0.5 {
        -0.5 * 2.0_f32.powf(20.0 * t - 10.0) * ((2.0 * t - 1.0 - s) * 2.0 * PI / p).sin()
    } else {
        0.5 * 2.0_f32.powf(-20.0 * t + 10.0) * ((2.0 * t - 1.0 - s) * 2.0 * PI / p).sin() + 1.0
    }
}

/// Ease-out bounce: 4-stage bounce settling at 1.
pub fn ease_out_bounce(t: f32) -> f32 {
    if t < 1.0 / 2.75 {
        7.5625 * t * t
    } else if t < 2.0 / 2.75 {
        let t = t - 1.5 / 2.75;
        7.5625 * t * t + 0.75
    } else if t < 2.5 / 2.75 {
        let t = t - 2.25 / 2.75;
        7.5625 * t * t + 0.9375
    } else {
        let t = t - 2.625 / 2.75;
        7.5625 * t * t + 0.984375
    }
}

/// Ease-in bounce: bounce before launching (mirrors ease_out_bounce).
pub fn ease_in_bounce(t: f32) -> f32 {
    1.0 - ease_out_bounce(1.0 - t)
}

/// Ease-in-out bounce: bounce on entry and at rest.
pub fn ease_in_out_bounce(t: f32) -> f32 {
    if t < 0.5 {
        0.5 * ease_in_bounce(2.0 * t)
    } else {
        0.5 * ease_out_bounce(2.0 * t - 1.0) + 0.5
    }
}

/// Ease-in back: slight overshoot behind 0 before moving forward.
pub fn ease_in_back(t: f32) -> f32 {
    let s = 1.70158_f32;
    t * t * ((s + 1.0) * t - s)
}

/// Ease-out back: overshoots past 1 then settles.
pub fn ease_out_back(t: f32) -> f32 {
    let s = 1.70158_f32;
    let u = t - 1.0;
    u * u * ((s + 1.0) * u + s) + 1.0
}

/// Ease-in-out back: overshoots on both ends.
pub fn ease_in_out_back(t: f32) -> f32 {
    let s = 1.70158_f32 * 1.525;
    if t < 0.5 {
        let t2 = 2.0 * t;
        0.5 * t2 * t2 * ((s + 1.0) * t2 - s)
    } else {
        let t2 = 2.0 * t - 2.0;
        0.5 * (t2 * t2 * ((s + 1.0) * t2 + s) + 2.0)
    }
}

/// Smooth-step interpolation: ease-in and ease-out S-curve (Hermite).
pub fn smooth_step(t: f32) -> f32 {
    let c = t.clamp(0.0, 1.0);
    c * c * (3.0 - 2.0 * c)
}

/// Apply the named easing function to `t`; returns None when `name` is unrecognised.
pub fn apply(name: &str, t: f32) -> Option<f32> {
    resolve_easing_fn(name).map(|f| f(t))
}

/// Returns a static slice of all built-in easing function names in canonical form.
pub fn easing_names() -> &'static [&'static str] {
    &[
        "linear",
        "easeInQuad",
        "easeOutQuad",
        "easeInOutQuad",
        "easeInCubic",
        "easeOutCubic",
        "easeInOutCubic",
        "easeInQuart",
        "easeOutQuart",
        "easeInOutQuart",
        "easeInQuint",
        "easeOutQuint",
        "easeInOutQuint",
        "easeInSine",
        "easeOutSine",
        "easeInOutSine",
        "easeInExpo",
        "easeOutExpo",
        "easeInOutExpo",
        "easeInCirc",
        "easeOutCirc",
        "easeInOutCirc",
        "easeInBounce",
        "easeOutBounce",
        "easeInOutBounce",
        "easeInElastic",
        "easeOutElastic",
        "easeInOutElastic",
        "easeInBack",
        "easeOutBack",
        "easeInOutBack",
    ]
}

/// Compute CSS cubic-bezier Y value for input `t` (0..1).
///
/// Control points: P0=(0,0), P1=(p1x,p1y), P2=(p2x,p2y), P3=(1,1).
/// Uses Newton's method to invert the X parametric equation, then evaluates Y.
pub fn cubic_bezier(p1x: f64, p1y: f64, p2x: f64, p2y: f64, t: f64) -> f64 {
    let cx = 3.0 * p1x;
    let bx = 3.0 * (p2x - p1x) - cx;
    let ax = 1.0 - cx - bx;

    let cy = 3.0 * p1y;
    let by_coef = 3.0 * (p2y - p1y) - cy;
    let ay = 1.0 - cy - by_coef;

    let sample_curve_x = |u: f64| ((ax * u + bx) * u + cx) * u;
    let sample_curve_dx = |u: f64| (3.0 * ax * u + 2.0 * bx) * u + cx;
    let sample_curve_y = |u: f64| ((ay * u + by_coef) * u + cy) * u;

    let mut u = t;
    for _ in 0..8 {
        let x = sample_curve_x(u) - t;
        if x.abs() < 1e-7 {
            break;
        }
        let dx = sample_curve_dx(u);
        if dx.abs() < 1e-6 {
            break;
        }
        u -= x / dx;
    }
    sample_curve_y(u)
}

/// Return the function pointer for a named easing function; returns None when unrecognised.
pub fn resolve_easing_fn(name: &str) -> Option<fn(f32) -> f32> {
    match name.to_lowercase().as_str() {
        "linear" => Some(linear),
        "smoothstep" | "smooth_step" => Some(smooth_step),
        "inquad" | "quadin" | "easeinquad" => Some(ease_in_quad),
        "outquad" | "quadout" | "easeoutquad" => Some(ease_out_quad),
        "inoutquad" | "quadinout" | "easeinoutquad" => Some(ease_in_out_quad),
        "incubic" | "cubicin" | "easeincubic" => Some(ease_in_cubic),
        "outcubic" | "cubicout" | "easeoutcubic" => Some(ease_out_cubic),
        "inoutcubic" | "cubicinout" | "easeinoutcubic" => Some(ease_in_out_cubic),
        "inquart" | "quartin" | "easeinquart" => Some(ease_in_quart),
        "outquart" | "quartout" | "easeoutquart" => Some(ease_out_quart),
        "inoutquart" | "quartinout" | "easeinoutquart" => Some(ease_in_out_quart),
        "insine" | "sinein" | "easeinsine" => Some(ease_in_sine),
        "outsine" | "sineout" | "easeoutsine" => Some(ease_out_sine),
        "inoutsine" | "sineinout" | "easeinoutsine" => Some(ease_in_out_sine),
        "inexpo" | "expoin" | "easeinexpo" => Some(ease_in_expo),
        "outexpo" | "expoout" | "easeoutexpo" => Some(ease_out_expo),
        "inoutexpo" | "expoinout" | "easeinoutexpo" => Some(ease_in_out_expo),
        "inelastic" | "elasticin" | "easeinelastic" => Some(ease_in_elastic),
        "outelastic" | "elasticout" | "easeoutelastic" => Some(ease_out_elastic),
        "inoutelastic" => Some(ease_in_out_elastic),
        "outbounce" | "bounceout" | "easeoutbounce" => Some(ease_out_bounce),
        "inbounce" | "bouncein" | "easeinbounce" => Some(ease_in_bounce),
        "inoutbounce" => Some(ease_in_out_bounce),
        "inback" | "backin" | "easeinback" => Some(ease_in_back),
        "outback" | "backout" | "easeoutback" => Some(ease_out_back),
        "inoutback" => Some(ease_in_out_back),
        _ => None,
    }
}
