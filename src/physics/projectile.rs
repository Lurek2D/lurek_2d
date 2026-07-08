//! Small projectile-oriented math helpers shared by physics queries and Lua bindings.
//! This file stays stateless: live projectile ownership belongs to Lua scripts or `World`.

use super::error::PhysicsError;
use super::limits::validate_finite;

/// Reflect velocity `(vx, vy)` around normal `(nx, ny)` and apply a speed coefficient.
pub fn reflect_velocity(
    vx: f32,
    vy: f32,
    nx: f32,
    ny: f32,
    coefficient: f32,
) -> Result<(f32, f32), PhysicsError> {
    validate_finite("vx", f64::from(vx))?;
    validate_finite("vy", f64::from(vy))?;
    validate_finite("nx", f64::from(nx))?;
    validate_finite("ny", f64::from(ny))?;
    validate_finite("coefficient", f64::from(coefficient))?;
    if !(0.0..=1.0).contains(&coefficient) {
        return Err(PhysicsError::ValueOutOfRange {
            field: "coefficient",
            min: 0.0,
            max: 1.0,
            value: f64::from(coefficient),
        });
    }
    let normal_len_sq = nx * nx + ny * ny;
    if normal_len_sq <= 1e-12 {
        return Err(PhysicsError::DegenerateGeometry {
            context: "projectile reflection",
            detail: "normal must be non-zero",
        });
    }
    let inv_len = normal_len_sq.sqrt().recip();
    let ux = nx * inv_len;
    let uy = ny * inv_len;
    let dot = vx * ux + vy * uy;
    Ok((
        (vx - 2.0 * dot * ux) * coefficient,
        (vy - 2.0 * dot * uy) * coefficient,
    ))
}
