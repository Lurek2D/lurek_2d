//! `lurek.overlay` -- Lua bindings for the overlay system: weather, atmosphere, screen flash/shake/fade, transitions, and ambient controls.

use super::SharedState;
use crate::overlay::{Overlay, ScreenTransition, TransitionKind, WeatherType};
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

/// Lua-side handle for screen overlay, ambient, weather, and transition visual state.
pub struct LuaOverlay {
    /// Overlay state that builds renderer commands for full-screen effects.
    inner: Overlay,
    /// Shared runtime state used for renderer commands and light ambient synchronization.
    state: Rc<RefCell<SharedState>>,
}
/// Provides Lua methods for overlay animation, ambient, weather, fog, water, and render submission.
impl LuaUserData for LuaOverlay {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- update --
        /// Advances overlay timers and animated effect state.
        /// @param | dt | number | Delta time in seconds.
        methods.add_method_mut("update", |_, this, dt: f32| {
            this.inner.update(dt);
            Ok(())
        });
        // -- triggerFlash --
        /// Starts a screen flash with explicit RGBA color and duration.
        /// @param | r | number | Red channel.
        /// @param | g | number | Green channel.
        /// @param | b | number | Blue channel.
        /// @param | a | number | Alpha channel.
        /// @param | duration | number | Flash duration in seconds.
        methods.add_method_mut(
            "triggerFlash",
            |_, this, (r, g, b, a, duration): (f32, f32, f32, f32, f32)| {
                this.inner.trigger_flash(r, g, b, a, duration);
                Ok(())
            },
        );
        // -- triggerShake --
        /// Starts a screen shake effect. This method is available to Lua scripts.
        /// @param | intensity | number | Shake intensity.
        /// @param | duration | number | Shake duration in seconds.
        methods.add_method_mut(
            "triggerShake",
            |_, this, (intensity, duration): (f32, f32)| {
                this.inner.trigger_shake(intensity, duration);
                Ok(())
            },
        );
        // -- triggerFade --
        /// Starts a fade overlay toward a target alpha.
        /// @param | r | number | Red channel.
        /// @param | g | number | Green channel.
        /// @param | b | number | Blue channel.
        /// @param | target_alpha | number | Target alpha value.
        /// @param | duration | number | Fade duration in seconds.
        methods.add_method_mut(
            "triggerFade",
            |_, this, (r, g, b, target_alpha, duration): (f32, f32, f32, f32, f32)| {
                this.inner.trigger_fade(r, g, b, target_alpha, duration);
                Ok(())
            },
        );
        // -- triggerLightning --
        /// Starts a lightning flash using the overlay lightning state.
        methods.add_method_mut("triggerLightning", |_, this, ()| {
            this.inner.trigger_lightning();
            Ok(())
        });
        // -- getShakeOffset --
        /// Returns the current screen shake offset.
        /// @return | number | Current x offset.
        /// @return | number | Current y offset.
        methods.add_method("getShakeOffset", |_, this, ()| {
            Ok(this.inner.get_shake_offset())
        });
        // -- isActive --
        /// Returns whether any overlay effect is currently active.
        /// @return | boolean | True when overlay state should render.
        methods.add_method("isActive", |_, this, ()| Ok(this.inner.is_active()));
        // -- clear --
        /// Clears active overlay effects and resets transient state.
        methods.add_method_mut("clear", |_, this, ()| {
            this.inner.clear();
            Ok(())
        });
        // -- resize --
        /// Resizes the overlay target dimensions.
        /// @param | w | integer | New width in pixels.
        /// @param | h | integer | New height in pixels.
        methods.add_method_mut("resize", |_, this, (w, h): (u32, u32)| {
            this.inner.resize(w, h);
            Ok(())
        });
        // -- getWidth --
        /// Returns the overlay width. This method is available to Lua scripts.
        /// @return | integer | Overlay width in pixels.
        methods.add_method("getWidth", |_, this, ()| Ok(this.inner.get_width()));
        // -- getHeight --
        /// Returns the overlay height. This method is available to Lua scripts.
        /// @return | integer | Overlay height in pixels.
        methods.add_method("getHeight", |_, this, ()| Ok(this.inner.get_height()));
        // -- getDimensions --
        /// Returns the overlay dimensions. This method is available to Lua scripts.
        /// @return | integer | Overlay width in pixels.
        /// @return | integer | Overlay height in pixels.
        methods.add_method("getDimensions", |_, this, ()| {
            Ok(this.inner.get_dimensions())
        });
        // -- getFlashAlpha --
        /// Returns the current flash alpha. This method is available to Lua scripts.
        /// @return | number | Flash alpha value.
        methods.add_method("getFlashAlpha", |_, this, ()| {
            Ok(this.inner.get_flash_alpha())
        });
        // -- getLightningAlpha --
        /// Returns the current lightning alpha.
        /// @return | number | Lightning alpha value.
        methods.add_method("getLightningAlpha", |_, this, ()| {
            Ok(this.inner.get_lightning_alpha())
        });
        // -- setAmbientEnabled --
        /// Enables or disables overlay ambient color rendering.
        /// @param | v | boolean | New ambient enabled flag.
        methods.add_method_mut("setAmbientEnabled", |_, this, v: bool| {
            this.inner.ambient.enabled = v;
            Ok(())
        });
        // -- isAmbientEnabled --
        /// Returns whether overlay ambient color rendering is enabled.
        /// @return | boolean | True when ambient rendering is enabled.
        methods.add_method("isAmbientEnabled", |_, this, ()| {
            Ok(this.inner.ambient.enabled)
        });
        // -- setAmbientColor --
        /// Sets the overlay ambient color from RGBA channels.
        /// @param | r | number | Red channel.
        /// @param | g | number | Green channel.
        /// @param | b | number | Blue channel.
        /// @param | a | number? | Alpha channel, defaulting to 1.0.
        methods.add_method_mut(
            "setAmbientColor",
            |_, this, (r, g, b, a): (f32, f32, f32, Option<f32>)| {
                this.inner.ambient.color = [r, g, b, a.unwrap_or(1.0)];
                Ok(())
            },
        );
        // -- getAmbientColor --
        /// Returns overlay ambient RGBA color.
        /// @return | number | Red channel.
        /// @return | number | Green channel.
        /// @return | number | Blue channel.
        /// @return | number | Alpha channel.
        methods.add_method("getAmbientColor", |_, this, ()| {
            let c = this.inner.ambient.color;
            Ok((c[0], c[1], c[2], c[3]))
        });
        // -- pullAmbientFromLight --
        /// Copies ambient color from the shared light world into this overlay.
        methods.add_method_mut("pullAmbientFromLight", |_, this, ()| {
            let st = this.state.borrow();
            this.inner.pull_ambient_from_light(&st.light_world.ambient);
            Ok(())
        });
        // -- pushAmbientToLight --
        /// Copies this overlay ambient color into the shared light world.
        methods.add_method_mut("pushAmbientToLight", |_, this, ()| {
            let mut st = this.state.borrow_mut();
            this.inner.push_ambient_to_light(&mut st.light_world.ambient);
            Ok(())
        });
        // -- syncAmbientWithLight --
        /// Resolves overlay and light ambient colors using a named mode and writes both stores.
        /// @param | mode | string | One of `light`, `overlay`, `avg`, `max`, or `min`.
        methods.add_method_mut("syncAmbientWithLight", |_, this, mode: String| {
            let mut st = this.state.borrow_mut();
            this.inner
                .sync_ambient_with_light(&mut st.light_world.ambient, &mode)
                .map_err(LuaError::RuntimeError)
        });
        // -- setTimeOfDay --
        /// Sets the overlay time-of-day value used by ambient effects.
        /// @param | v | number | Time-of-day value stored on the overlay ambient state.
        methods.add_method_mut("setTimeOfDay", |_, this, v: f32| {
            this.inner.ambient.time_of_day = v;
            Ok(())
        });
        // -- getTimeOfDay --
        /// Returns the overlay time-of-day value.
        /// @return | number | Current time-of-day value.
        methods.add_method("getTimeOfDay", |_, this, ()| {
            Ok(this.inner.ambient.time_of_day)
        });
        // -- setFogEnabled --
        /// Enables or disables overlay fog rendering.
        /// @param | v | boolean | New fog enabled flag.
        methods.add_method_mut("setFogEnabled", |_, this, v: bool| {
            this.inner.fog.enabled = v;
            Ok(())
        });
        // -- isFogEnabled --
        /// Returns whether overlay fog rendering is enabled.
        /// @return | boolean | True when fog rendering is enabled.
        methods.add_method("isFogEnabled", |_, this, ()| Ok(this.inner.fog.enabled));
        // -- setFogDensity --
        /// Sets overlay fog density. This method is available to Lua scripts.
        /// @param | v | number | Fog density value.
        methods.add_method_mut("setFogDensity", |_, this, v: f32| {
            this.inner.fog.density = v;
            Ok(())
        });
        // -- getFogDensity --
        /// Returns overlay fog density. This method is available to Lua scripts.
        /// @return | number | Current fog density.
        methods.add_method("getFogDensity", |_, this, ()| Ok(this.inner.fog.density));
        // -- setFogColor --
        /// Sets the overlay fog color from RGBA channels.
        /// @param | r | number | Red channel.
        /// @param | g | number | Green channel.
        /// @param | b | number | Blue channel.
        /// @param | a | number? | Alpha channel, defaulting to 1.0.
        methods.add_method_mut(
            "setFogColor",
            |_, this, (r, g, b, a): (f32, f32, f32, Option<f32>)| {
                this.inner.fog.color = [r, g, b, a.unwrap_or(1.0)];
                Ok(())
            },
        );
        // -- getFogColor --
        /// Returns overlay fog RGBA color. This method is available to Lua scripts.
        /// @return | number | Red channel.
        /// @return | number | Green channel.
        /// @return | number | Blue channel.
        /// @return | number | Alpha channel.
        methods.add_method("getFogColor", |_, this, ()| {
            let c = this.inner.fog.color;
            Ok((c[0], c[1], c[2], c[3]))
        });
        // -- setHeatHazeEnabled --
        /// Enables or disables overlay heat haze rendering.
        /// @param | v | boolean | New heat haze enabled flag.
        methods.add_method_mut("setHeatHazeEnabled", |_, this, v: bool| {
            this.inner.heat_haze.enabled = v;
            Ok(())
        });
        // -- isHeatHazeEnabled --
        /// Returns whether overlay heat haze rendering is enabled.
        /// @return | boolean | True when heat haze rendering is enabled.
        methods.add_method("isHeatHazeEnabled", |_, this, ()| {
            Ok(this.inner.heat_haze.enabled)
        });
        // -- setHeatHazeIntensity --
        /// Sets overlay heat haze intensity. This method is available to Lua scripts.
        /// @param | v | number | Heat haze intensity value.
        methods.add_method_mut("setHeatHazeIntensity", |_, this, v: f32| {
            this.inner.heat_haze.intensity = v;
            Ok(())
        });
        // -- getHeatHazeIntensity --
        /// Returns overlay heat haze intensity.
        /// @return | number | Current heat haze intensity.
        methods.add_method("getHeatHazeIntensity", |_, this, ()| {
            Ok(this.inner.heat_haze.intensity)
        });
        // -- setVignetteEnabled --
        /// Enables or disables overlay vignette rendering.
        /// @param | v | boolean | New vignette enabled flag.
        methods.add_method_mut("setVignetteEnabled", |_, this, v: bool| {
            this.inner.vignette.enabled = v;
            Ok(())
        });
        // -- isVignetteEnabled --
        /// Returns whether overlay vignette rendering is enabled.
        /// @return | boolean | True when vignette rendering is enabled.
        methods.add_method("isVignetteEnabled", |_, this, ()| {
            Ok(this.inner.vignette.enabled)
        });
        // -- setVignetteStrength --
        /// Sets overlay vignette strength. This method is available to Lua scripts.
        /// @param | v | number | Vignette strength value.
        methods.add_method_mut("setVignetteStrength", |_, this, v: f32| {
            this.inner.vignette.strength = v;
            Ok(())
        });
        // -- getVignetteStrength --
        /// Returns overlay vignette strength.
        /// @return | number | Current vignette strength.
        methods.add_method("getVignetteStrength", |_, this, ()| {
            Ok(this.inner.vignette.strength)
        });
        // -- setFilmGrainEnabled --
        /// Enables or disables overlay film grain rendering.
        /// @param | v | boolean | New film grain enabled flag.
        methods.add_method_mut("setFilmGrainEnabled", |_, this, v: bool| {
            this.inner.film_grain.enabled = v;
            Ok(())
        });
        // -- isFilmGrainEnabled --
        /// Returns whether overlay film grain rendering is enabled.
        /// @return | boolean | True when film grain rendering is enabled.
        methods.add_method("isFilmGrainEnabled", |_, this, ()| {
            Ok(this.inner.film_grain.enabled)
        });
        // -- setFilmGrainIntensity --
        /// Sets overlay film grain intensity.
        /// @param | v | number | Film grain intensity value.
        methods.add_method_mut("setFilmGrainIntensity", |_, this, v: f32| {
            this.inner.film_grain.intensity = v;
            Ok(())
        });
        // -- getFilmGrainIntensity --
        /// Returns overlay film grain intensity.
        /// @return | number | Current film grain intensity.
        methods.add_method("getFilmGrainIntensity", |_, this, ()| {
            Ok(this.inner.film_grain.intensity)
        });
        // -- setCloudShadows --
        /// Enables or disables overlay cloud shadow rendering.
        /// @param | v | boolean | New cloud shadow enabled flag.
        methods.add_method_mut("setCloudShadows", |_, this, v: bool| {
            this.inner.clouds.enabled = v;
            Ok(())
        });
        // -- isCloudShadowsEnabled --
        /// Returns whether overlay cloud shadow rendering is enabled.
        /// @return | boolean | True when cloud shadow rendering is enabled.
        methods.add_method("isCloudShadowsEnabled", |_, this, ()| {
            Ok(this.inner.clouds.enabled)
        });
        // -- setCloudCount --
        /// Sets the overlay cloud shadow count.
        /// @param | v | integer | Cloud shadow count.
        methods.add_method_mut("setCloudCount", |_, this, v: u32| {
            this.inner.clouds.count = v;
            Ok(())
        });
        // -- getCloudCount --
        /// Returns the overlay cloud shadow count.
        /// @return | integer | Cloud shadow count.
        methods.add_method("getCloudCount", |_, this, ()| Ok(this.inner.clouds.count));
        // -- setCloudSpeed --
        /// Sets cloud shadow movement speed. This method is available to Lua scripts.
        /// @param | v | number | Cloud speed value.
        methods.add_method_mut("setCloudSpeed", |_, this, v: f32| {
            this.inner.clouds.speed = v;
            Ok(())
        });
        // -- getCloudSpeed --
        /// Returns cloud shadow movement speed.
        /// @return | number | Cloud speed value.
        methods.add_method("getCloudSpeed", |_, this, ()| Ok(this.inner.clouds.speed));
        // -- setCloudScale --
        /// Sets cloud shadow scale. This method is available to Lua scripts.
        /// @param | v | number | Cloud scale value.
        methods.add_method_mut("setCloudScale", |_, this, v: f32| {
            this.inner.clouds.scale = v;
            Ok(())
        });
        // -- getCloudScale --
        /// Returns cloud shadow scale. This method is available to Lua scripts.
        /// @return | number | Cloud scale value.
        methods.add_method("getCloudScale", |_, this, ()| Ok(this.inner.clouds.scale));
        // -- setCloudOpacity --
        /// Sets cloud shadow opacity. This method is available to Lua scripts.
        /// @param | v | number | Cloud opacity value.
        methods.add_method_mut("setCloudOpacity", |_, this, v: f32| {
            this.inner.clouds.opacity = v;
            Ok(())
        });
        // -- getCloudOpacity --
        /// Returns cloud shadow opacity. This method is available to Lua scripts.
        /// @return | number | Cloud opacity value.
        methods.add_method("getCloudOpacity", |_, this, ()| {
            Ok(this.inner.clouds.opacity)
        });
        // -- setWeatherEnabled --
        /// Enables or disables overlay weather rendering.
        /// @param | v | boolean | New weather enabled flag.
        methods.add_method_mut("setWeatherEnabled", |_, this, v: bool| {
            this.inner.weather.enabled = v;
            Ok(())
        });
        // -- isWeatherEnabled --
        /// Returns whether overlay weather rendering is enabled.
        /// @return | boolean | True when weather rendering is enabled.
        methods.add_method("isWeatherEnabled", |_, this, ()| {
            Ok(this.inner.weather.enabled)
        });
        // -- setWeather --
        /// Sets the overlay weather type by name.
        /// @param | name | string | Weather type name recognized by the engine.
        methods.add_method_mut("setWeather", |_, this, name: String| {
            this.inner.weather.weather_type = WeatherType::from_name(&name)
                .ok_or_else(|| LuaError::RuntimeError(format!("unknown weather type: {name}")))?;
            Ok(())
        });
        // -- getWeather --
        /// Returns the overlay weather type name.
        /// @return | string | Current weather type name.
        methods.add_method("getWeather", |_, this, ()| {
            Ok(this.inner.weather.weather_type.name().to_owned())
        });
        // -- setWeatherIntensity --
        /// Sets weather intensity for the current weather type.
        /// @param | v | number | Weather intensity value.
        methods.add_method_mut("setWeatherIntensity", |_, this, v: f32| {
            this.inner.weather.intensity = v;
            Ok(())
        });
        // -- getWeatherIntensity --
        /// Returns weather intensity for the current weather type.
        /// @return | number | Weather intensity value.
        methods.add_method("getWeatherIntensity", |_, this, ()| {
            Ok(this.inner.weather.intensity)
        });
        // -- setWindDirection --
        /// Sets the overlay weather wind direction.
        /// @param | v | number | Wind direction value.
        methods.add_method_mut("setWindDirection", |_, this, v: f32| {
            this.inner.weather.wind_direction = v;
            Ok(())
        });
        // -- getWindDirection --
        /// Returns the overlay weather wind direction.
        /// @return | number | Wind direction value.
        methods.add_method("getWindDirection", |_, this, ()| {
            Ok(this.inner.weather.wind_direction)
        });
        // -- setWindSpeed --
        /// Sets the overlay weather wind speed.
        /// @param | v | number | Wind speed value.
        methods.add_method_mut("setWindSpeed", |_, this, v: f32| {
            this.inner.weather.wind_speed = v;
            Ok(())
        });
        // -- getWindSpeed --
        /// Returns the overlay weather wind speed.
        /// @return | number | Wind speed value.
        methods.add_method("getWindSpeed", |_, this, ()| {
            Ok(this.inner.weather.wind_speed)
        });
        // -- setLightningColor --
        /// Sets overlay lightning RGBA color.
        /// @param | r | number | Red channel.
        /// @param | g | number | Green channel.
        /// @param | b | number | Blue channel.
        /// @param | a | number? | Alpha channel, defaulting to 1.0.
        methods.add_method_mut(
            "setLightningColor",
            |_, this, (r, g, b, a): (f32, f32, f32, Option<f32>)| {
                this.inner.lightning.color = [r, g, b, a.unwrap_or(1.0)];
                Ok(())
            },
        );
        // -- getLightningColor --
        /// Returns overlay lightning RGBA color.
        /// @return | number | Red channel.
        /// @return | number | Green channel.
        /// @return | number | Blue channel.
        /// @return | number | Alpha channel.
        methods.add_method("getLightningColor", |_, this, ()| {
            let c = this.inner.lightning.color;
            Ok((c[0], c[1], c[2], c[3]))
        });
        // -- flash --
        /// Starts a short flash overlay with optional alpha and duration.
        /// @param | r | number | Red channel.
        /// @param | g | number | Green channel.
        /// @param | b | number | Blue channel.
        /// @param | a | number? | Alpha channel, defaulting to 1.0.
        /// @param | dur | number? | Duration in seconds, defaulting to 0.2.
        methods.add_method_mut(
            "flash",
            |_, this, (r, g, b, a, dur): (f32, f32, f32, Option<f32>, Option<f32>)| {
                this.inner
                    .trigger_flash(r, g, b, a.unwrap_or(1.0), dur.unwrap_or(0.2));
                Ok(())
            },
        );
        // -- isFlashing --
        /// Returns whether the flash overlay is active.
        /// @return | boolean | True while the flash is active.
        methods.add_method("isFlashing", |_, this, ()| Ok(this.inner.flash.active));
        // -- shake --
        /// Starts a screen shake with optional duration.
        /// @param | intensity | number | Shake intensity.
        /// @param | dur | number? | Duration in seconds, defaulting to 0.5.
        methods.add_method_mut("shake", |_, this, (intensity, dur): (f32, Option<f32>)| {
            this.inner.trigger_shake(intensity, dur.unwrap_or(0.5));
            Ok(())
        });
        // -- isShaking --
        /// Returns whether the screen shake effect is active.
        /// @return | boolean | True while screen shake is active.
        methods.add_method("isShaking", |_, this, ()| Ok(this.inner.shake.active));
        // -- fade --
        /// Starts a fade overlay with optional alpha and duration.
        /// @param | r | number | Red channel.
        /// @param | g | number | Green channel.
        /// @param | b | number | Blue channel.
        /// @param | a | number? | Target alpha, defaulting to 1.0.
        /// @param | dur | number? | Duration in seconds, defaulting to 1.0.
        methods.add_method_mut(
            "fade",
            |_, this, (r, g, b, a, dur): (f32, f32, f32, Option<f32>, Option<f32>)| {
                this.inner
                    .trigger_fade(r, g, b, a.unwrap_or(1.0), dur.unwrap_or(1.0));
                Ok(())
            },
        );
        // -- isFading --
        /// Returns whether the fade overlay is active.
        /// @return | boolean | True while fade is active.
        methods.add_method("isFading", |_, this, ()| Ok(this.inner.fade.active));
        // -- render --
        /// Queues renderer commands for the overlay's current visual state.
        methods.add_method("render", |_, this, ()| {
            let cmds = this.inner.build_render_commands();
            this.state.borrow_mut().render_commands.extend(cmds);
            Ok(())
        });
        // -- drawToImage --
        /// Renders overlay state into an image object of the requested size.
        /// @param | w | integer | Target image width in pixels.
        /// @param | h | integer | Target image height in pixels.
        /// @return | Image | Image containing the overlay draw state.
        methods.add_method("drawToImage", |_, this, (w, h): (u32, u32)| {
            let img = this.inner.draw_state_to_image(w, h);
            Ok(img)
        });
        // -- setWater --
        /// Enables water distortion and sets wave amplitude, frequency, and speed.
        /// @param | amplitude | number | Water wave amplitude.
        /// @param | frequency | number | Water wave frequency.
        /// @param | speed | number | Water animation speed.
        methods.add_method_mut(
            "setWater",
            |_, this, (amplitude, frequency, speed): (f32, f32, f32)| {
                this.inner.water.amplitude = amplitude;
                this.inner.water.frequency = frequency;
                this.inner.water.speed = speed;
                this.inner.water.enabled = true;
                Ok(())
            },
        );
        // -- setWaterTint --
        /// Sets the water tint color and strength.
        /// @param | r | number | Red channel.
        /// @param | g | number | Green channel.
        /// @param | b | number | Blue channel.
        /// @param | strength | number | Tint strength.
        methods.add_method_mut(
            "setWaterTint",
            |_, this, (r, g, b, strength): (f32, f32, f32, f32)| {
                this.inner.water.tint_r = r;
                this.inner.water.tint_g = g;
                this.inner.water.tint_b = b;
                this.inner.water.tint_strength = strength;
                Ok(())
            },
        );
        // -- setCustomShader --
        /// Sets or clears the custom overlay shader name.
        /// @param | name | string? | Optional shader name; nil clears the custom shader.
        methods.add_method_mut("setCustomShader", |_, this, name: Option<String>| {
            this.inner.custom_shader = name;
            Ok(())
        });
        // -- getWater --
        /// Returns a table describing the current water effect settings.
        /// @return | table | Water state table with enabled, wave, tint, depth, and time fields.
        /// @field | enabled | boolean | Whether water effect is enabled.
        /// @field | amplitude | number | Wave amplitude.
        /// @field | frequency | number | Wave frequency.
        /// @field | speed | number | Wave speed.
        /// @field | tint_r | number | Tint red component.
        /// @field | tint_g | number | Tint green component.
        /// @field | tint_b | number | Tint blue component.
        /// @field | tint_strength | number | Tint strength.
        /// @field | depth_r | number | Depth red component.
        /// @field | depth_g | number | Depth green component.
        /// @field | depth_b | number | Depth blue component.
        /// @field | depth_strength | number | Depth strength.
        /// @field | time | number | Elapsed time.
        methods.add_method("getWater", |lua, this, ()| {
            let w = &this.inner.water;
            let t = lua.create_table()?;
            t.set("enabled", w.enabled)?;
            t.set("amplitude", w.amplitude)?;
            t.set("frequency", w.frequency)?;
            t.set("speed", w.speed)?;
            t.set("tint_r", w.tint_r)?;
            t.set("tint_g", w.tint_g)?;
            t.set("tint_b", w.tint_b)?;
            t.set("tint_strength", w.tint_strength)?;
            t.set("depth_r", w.depth_r)?;
            t.set("depth_g", w.depth_g)?;
            t.set("depth_b", w.depth_b)?;
            t.set("depth_strength", w.depth_strength)?;
            t.set("time", w.time)?;
            Ok(t)
        });
        // -- type --
        /// Returns the Lua-visible type name for this overlay handle.
        /// @return | string | The string `LOverlay`.
        methods.add_method("type", |_, _this, ()| Ok("LOverlay"));
        // -- typeOf --
        /// Returns whether this overlay handle matches a supported type name.
        /// @param | name | string | Type name to compare against `Overlay` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _this, name: String| {
            Ok(name == "LObject" || name == "LOverlay")
        });
    }
}
/// Lua-side handle for a timed screen transition effect.
pub struct LuaScreenTransition {
    /// Transition kind, timer, direction, and RGBA color.
    inner: ScreenTransition,
}
/// Provides Lua methods for playing and inspecting screen transitions.
impl mlua::UserData for LuaScreenTransition {
    fn add_methods<'lua, M: mlua::UserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- play --
        /// Starts this screen transition forward from its current state.
        methods.add_method_mut("play", |_, this, ()| {
            this.inner.play();
            Ok(())
        });
        // -- reverse --
        /// Starts this screen transition in reverse from its current state.
        methods.add_method_mut("reverse", |_, this, ()| {
            this.inner.reverse();
            Ok(())
        });
        // -- update --
        /// Advances this transition timer and returns whether it remains active.
        /// @param | dt | number | Delta time in seconds.
        /// @return | boolean | True when the transition is still active after the update.
        methods.add_method_mut("update", |_, this, dt: f32| Ok(this.inner.update(dt)));
        // -- progress --
        /// Returns normalized transition progress.
        /// @return | number | Progress value between the transition start and end.
        methods.add_method("progress", |_, this, ()| Ok(this.inner.progress()));
        // -- isActive --
        /// Returns whether the transition is currently active.
        /// @return | boolean | True when the transition is active.
        methods.add_method("isActive", |_, this, ()| Ok(this.inner.is_active()));
        // -- isDone --
        /// Returns whether the transition has finished.
        /// @return | boolean | True when the transition is complete.
        methods.add_method("isDone", |_, this, ()| Ok(this.inner.is_done()));
        // -- kind --
        /// Returns the transition kind name. This method is available to Lua scripts.
        /// @return | string | Transition kind name.
        methods.add_method("kind", |_, this, ()| Ok(this.inner.kind.name()));
        // -- color --
        /// Returns the transition RGBA color.
        /// @return | number | Red channel.
        /// @return | number | Green channel.
        /// @return | number | Blue channel.
        /// @return | number | Alpha channel.
        methods.add_method("color", |_, this, ()| {
            let c = this.inner.color;
            Ok((c[0], c[1], c[2], c[3]))
        });
        // -- setColor --
        /// Sets the transition RGBA color from a numeric array table.
        /// @param | color | table | Numeric color table using indices 1 through 4.
        methods.add_method_mut("setColor", |_, this, ct: mlua::Table| {
            this.inner.color = [
                ct.get::<_, f32>(1).unwrap_or(0.0),
                ct.get::<_, f32>(2).unwrap_or(0.0),
                ct.get::<_, f32>(3).unwrap_or(0.0),
                ct.get::<_, f32>(4).unwrap_or(1.0),
            ];
            Ok(())
        });
        // -- type --
        /// Returns the Lua-visible type name for this transition handle.
        /// @return | string | The string `LScreenTransition`.
        methods.add_method("type", |_, _, ()| Ok("LScreenTransition"));
        // -- typeOf --
        /// Returns whether this transition handle matches a supported type name.
        /// @param | name | string | Type name to compare against `ScreenTransition` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LScreenTransition" || name == "LObject")
        });
    }
}
/// Registers `lurek.overlay` constructors for overlay and transition objects.
pub fn register(lua: &Lua, lurek: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;
    let s = state.clone();
    // -- new --
    /// Creates an overlay controller for screen effects using optional dimensions.
    /// @param | w | integer? | Overlay width in pixels, defaulting to 800.
    /// @param | h | integer? | Overlay height in pixels, defaulting to 600.
    /// @return | LOverlay | New overlay handle.
    tbl.set(
        "new",
        lua.create_function(move |lua, (w, h): (Option<u32>, Option<u32>)| {
            let width = w.unwrap_or(800);
            let height = h.unwrap_or(600);
            lua.create_userdata(LuaOverlay {
                inner: Overlay::new(width, height),
                state: s.clone(),
            })
        })?,
    )?;
    // -- newTransition --
    /// Creates a timed screen transition with optional kind, duration, and color.
    /// @param | kind | string? | Transition kind name, defaulting to `fade`.
    /// @param | duration | number? | Duration in seconds, defaulting to 1.0.
    /// @param | color_tbl | table? | Numeric RGBA table using indices 1 through 4.
    /// @return | LScreenTransition | New screen transition handle.
    tbl.set(
        "newTransition",
        lua.create_function(
            move |lua, (kind, duration, color_tbl): (Option<String>, Option<f32>, Option<LuaTable>)| {
                let k = TransitionKind::from_str(kind.as_deref().unwrap_or("fade"));
                let dur = duration.unwrap_or(1.0);
                let color = if let Some(ct) = color_tbl {
                    [
                        ct.get::<_, f32>(1).unwrap_or(0.0),
                        ct.get::<_, f32>(2).unwrap_or(0.0),
                        ct.get::<_, f32>(3).unwrap_or(0.0),
                        ct.get::<_, f32>(4).unwrap_or(1.0),
                    ]
                } else {
                    [0.0, 0.0, 0.0, 1.0]
                };
                lua.create_userdata(LuaScreenTransition {
                    inner: ScreenTransition::new(k, dur, color),
                })
            },
        )?,
    )?;
    lurek.set("overlay", tbl)?;

    // Compatibility aliases: lurek.effect.newOverlay / lurek.effect.newTransition
    // overlay_api is registered after effect_api, so lurek.effect exists here.
    if let Ok(effect_tbl) = lurek.get::<_, mlua::Table>("effect") {
        let overlay_tbl: mlua::Table = lurek.get("overlay")?;
        effect_tbl.set("newOverlay", overlay_tbl.get::<_, mlua::Function>("new")?)?;
        effect_tbl.set(
            "newTransition",
            overlay_tbl.get::<_, mlua::Function>("newTransition")?,
        )?;
    }

    Ok(())
}
