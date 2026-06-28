//! Owns user-facing shader parsing, validation, and uniform bookkeeping for custom WGSL-driven render effects.
//! Wraps incoming WGSL source into renderer-ready templates so fragment entry points match engine expectations.
//! Inspects fragment inputs and uniform declarations to reject unsupported bindings before runtime use.
//! Represents uniform values in typed forms that later upload code can preserve in stable buffer order.
//! Keeps wrapper generation and ordered-uniform logic local instead of scattering shader policy through backends.
//! Acts as the custom-shader boundary between authored WGSL text and engine-managed pipeline integration.
//! Open this file when shader source validation, wrapper rewriting, or uniform ordering behaves incorrectly.

use crate::log_msg;
use crate::runtime::log_messages::SH01_SHADER_OK;
use std::collections::HashMap;
use std::fmt;
use std::str::FromStr;
use wgpu::naga::{Binding, ScalarKind, TypeInner, VectorSize};

const MAX_SHADER_UNIFORM_NAME_LEN: usize = 64;

const RESERVED_SHADER_UNIFORM_NAMES: &[&str] = &[
    "lurek",
    "t_diffuse",
    "s_diffuse",
    "sampled",
    "viewport",
    "in",
    "out",
    "fn",
    "let",
    "var",
    "const",
    "override",
    "struct",
    "return",
    "if",
    "else",
    "for",
    "loop",
    "while",
    "break",
    "continue",
    "discard",
    "true",
    "false",
    "alias",
    "bitcast",
    "case",
    "continuing",
    "default",
    "diagnostic",
    "enable",
    "requires",
    "switch",
];
/// Runtime shader pipeline family requested by user code.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum ShaderTarget {
    /// Draw-command shader used by `lurek.render.setShader`.
    Draw,
    /// Full-screen post-processing shader.
    PostFx,
    /// Off-screen image-processing shader.
    Image,
    /// Screen overlay shader.
    Overlay,
    /// Particle-rendering shader.
    Particle,
    /// Light-contribution shader.
    Light,
}

impl ShaderTarget {
    /// Returns the stable Lua-facing target name.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Draw => "draw",
            Self::PostFx => "postfx",
            Self::Image => "image",
            Self::Overlay => "overlay",
            Self::Particle => "particle",
            Self::Light => "light",
        }
    }
}

impl fmt::Display for ShaderTarget {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.as_str())
    }
}

impl FromStr for ShaderTarget {
    type Err = String;

    fn from_str(value: &str) -> Result<Self, Self::Err> {
        match value.trim().to_ascii_lowercase().as_str() {
            "draw" | "render" => Ok(Self::Draw),
            "postfx" | "effect" => Ok(Self::PostFx),
            "image" => Ok(Self::Image),
            "overlay" => Ok(Self::Overlay),
            "particle" | "particles" => Ok(Self::Particle),
            "light" => Ok(Self::Light),
            other => Err(format!(
                "unknown shader target '{other}', expected draw, postfx, image, overlay, particle, or light"
            )),
        }
    }
}

/// Fragment input location slot decoded from a user shader entry point.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ShaderFragmentInput {
    /// `@location(0) vec4<f32>` RGBA color input.
    Color,
    /// `@location(1) vec2<f32>` UV coordinate input.
    Uv,
    /// `@location(2) vec2<f32>` pixel or local-space position input.
    PixelOrLocal,
    /// `@location(3) vec2<f32>` resolution or world-space position input.
    ResolutionOrWorld,
    /// `@location(4) vec2<f32>` texel size or velocity input.
    TexelOrVelocity,
    /// `@location(5) f32` normalized age, distance, or target-specific scalar input.
    Scalar0,
    /// `@location(6) f32` lifetime, radius, or target-specific scalar input.
    Scalar1,
    /// `@location(7) f32` random seed, intensity, or target-specific scalar input.
    Scalar2,
    /// `@location(8) f32` shadow factor or target-specific scalar input.
    Scalar3,
    /// `@location(8) vec4<f32>` sampled particle texture color.
    SampledTextureColor,
    /// `@location(9) vec4<f32>` ambient color or target-specific color input.
    AmbientColor,
    /// `@location(10) vec4<f32>` light direction and spot-angle input.
    LightDirection,
}
/// Rewritten fragment source and its entry name, ready for injection into the wrapper pipeline.
#[derive(Debug, Clone)]
struct PreparedFragmentSource {
    /// WGSL source with `@fragment` attribute stripped for helper-function wrapping.
    source: String,
    /// Original fragment function name preserved for wrapper call.
    entry_name: String,
    /// Ordered list of input slots actually used by this entry.
    inputs: Vec<ShaderFragmentInput>,
}
/// Name and input slots extracted from a validated fragment entry point.
#[derive(Debug, Clone)]
struct FragmentEntrySignature {
    /// Entry function name from the parsed `naga::Module`.
    name: String,
    /// Ordered input slots determined from `@location` bindings.
    inputs: Vec<ShaderFragmentInput>,
}
/// A compiled and validated user WGSL shader with its rewritten source and uniform map.
#[derive(Debug, Clone)]
pub struct Shader {
    /// Original WGSL source as supplied by the game.
    pub source: String,
    /// Target pipeline family this shader was validated for.
    pub target: ShaderTarget,
    /// Rewritten source with `@fragment` stripped for pipeline wrapper injection.
    pub wrapper_source: String,
    /// Name of the fragment entry function in the rewritten source.
    pub fragment_entry_name: String,
    /// Ordered list of input slots the fragment function accepts.
    pub fragment_inputs: Vec<ShaderFragmentInput>,
    /// Named uniform values set by `send()`; forwarded to the GPU each frame.
    pub uniforms: HashMap<String, UniformValue>,
    /// Non-fatal validation notes and target-contract details exposed to Lua.
    pub diagnostics: Vec<String>,
}
/// A typed uniform value sent to a `Shader` via `send()`.
#[derive(Debug, Clone)]
pub enum UniformValue {
    /// 32-bit float scalar.
    Float(f32),
    /// Two-component float vector.
    Vec2([f32; 2]),
    /// Three-component float vector.
    Vec3([f32; 3]),
    /// Four-component float vector.
    Vec4([f32; 4]),
    /// 32-bit signed integer.
    Int(i32),
    /// Boolean.
    Bool(bool),
}
impl Shader {
    /// Parse, validate, and prepare `source`; return error string on WGSL validation failure.
    pub fn new(source: String) -> Result<Self, String> {
        Self::new_for_target(source, ShaderTarget::Draw)
    }
    /// Parse, validate, and prepare `source` for a specific shader target.
    pub fn new_for_target(source: String, target: ShaderTarget) -> Result<Self, String> {
        validate_wgsl(&source, target)?;
        let prepared = prepare_fragment_source_for_wrapper(&source, target)?;
        log_msg!(info, SH01_SHADER_OK);
        Ok(Self {
            source,
            target,
            wrapper_source: prepared.source,
            fragment_entry_name: prepared.entry_name,
            fragment_inputs: prepared.inputs,
            uniforms: HashMap::new(),
            diagnostics: vec![format!("validated for {} shader target", target.as_str())],
        })
    }
    /// Set or replace the named uniform value used on subsequent frames.
    pub fn send(&mut self, name: String, value: UniformValue) -> Result<(), String> {
        validate_uniform_name(&name)?;
        self.uniforms.insert(name, value);
        Ok(())
    }
    /// Return `true` when a uniform with `name` has been set.
    pub fn has_uniform(&self, name: &str) -> bool {
        self.uniforms.contains_key(name)
    }
    /// Returns this shader's target pipeline family.
    pub fn target(&self) -> ShaderTarget {
        self.target
    }
    /// Returns non-fatal diagnostics collected during validation.
    pub fn diagnostics(&self) -> &[String] {
        &self.diagnostics
    }
    /// Return all set uniforms sorted alphabetically by name for deterministic GPU upload order.
    pub(crate) fn ordered_uniforms(&self) -> Vec<(&str, &UniformValue)> {
        let mut uniforms: Vec<_> = self
            .uniforms
            .iter()
            .map(|(name, value)| (name.as_str(), value))
            .collect();
        uniforms.sort_by(|(left, _), (right, _)| left.cmp(right));
        uniforms
    }
    /// Return the rewritten wrapper source for injection into the GPU pipeline.
    pub(crate) fn wrapper_source(&self) -> &str {
        &self.wrapper_source
    }
    /// Return the fragment helper function name within `wrapper_source`.
    pub(crate) fn fragment_entry_name(&self) -> &str {
        &self.fragment_entry_name
    }
    /// Return the ordered input slots accepted by the fragment entry.
    pub(crate) fn fragment_inputs(&self) -> &[ShaderFragmentInput] {
        &self.fragment_inputs
    }
    /// Build a full post-processing fragment module from this shader's target wrapper.
    pub fn fullscreen_postfx_source(&self) -> String {
        let fragment_call_args = fullscreen_fragment_call_args(self.fragment_inputs());
        let user_entry = "lurek_user_fragment";
        let user_source = self.wrapper_source().replacen(
            &format!("fn {}", self.fragment_entry_name()),
            &format!("fn {user_entry}"),
            1,
        );
        format!(
            r#"
struct PostFxParams {{ p: array<vec4<f32>, 4>, }}
@group(0) @binding(0) var t_src: texture_2d<f32>;
@group(0) @binding(1) var s_src: sampler;
@group(0) @binding(2) var<uniform> params: PostFxParams;
{user_source}
@fragment
fn fs_main(@location(0) uv: vec2<f32>) -> @location(0) vec4<f32> {{
    let source = textureSample(t_src, s_src, uv);
    let resolution = vec2<f32>(textureDimensions(t_src));
    let pixel = uv * resolution;
    let texel = 1.0 / max(resolution, vec2<f32>(1.0, 1.0));
    return {user_entry}({fragment_call_args});
}}
"#,
            user_source = user_source,
            user_entry = user_entry,
            fragment_call_args = fragment_call_args,
        )
    }
}

fn fullscreen_fragment_call_args(inputs: &[ShaderFragmentInput]) -> String {
    inputs
        .iter()
        .map(|input| match input {
            ShaderFragmentInput::Color => "source",
            ShaderFragmentInput::Uv => "uv",
            ShaderFragmentInput::PixelOrLocal => "pixel",
            ShaderFragmentInput::ResolutionOrWorld => "resolution",
            ShaderFragmentInput::TexelOrVelocity => "texel",
            ShaderFragmentInput::Scalar0 => "params.p[3].x",
            ShaderFragmentInput::Scalar1 => "params.p[3].y",
            ShaderFragmentInput::Scalar2 => "params.p[3].z",
            ShaderFragmentInput::Scalar3 => "params.p[3].w",
            ShaderFragmentInput::SampledTextureColor => "source",
            ShaderFragmentInput::AmbientColor => "vec4<f32>(0.0, 0.0, 0.0, 1.0)",
            ShaderFragmentInput::LightDirection => "vec4<f32>(0.0, 0.0, 0.0, 0.0)",
        })
        .collect::<Vec<_>>()
        .join(", ")
}
/// Validate a user-supplied shader uniform name before it is interpolated into WGSL.
pub fn validate_uniform_name(name: &str) -> Result<(), String> {
    if name.is_empty() {
        return Err("shader uniform name must not be empty".to_string());
    }
    if name.len() > MAX_SHADER_UNIFORM_NAME_LEN {
        return Err(format!(
            "shader uniform name '{}' exceeds {} bytes",
            name, MAX_SHADER_UNIFORM_NAME_LEN
        ));
    }
    let mut chars = name.chars();
    let Some(first) = chars.next() else {
        return Err("shader uniform name must not be empty".to_string());
    };
    if !(first == '_' || first.is_ascii_alphabetic()) {
        return Err(format!(
            "shader uniform name '{}' must start with ASCII letter or underscore",
            name
        ));
    }
    if !chars.all(|ch| ch == '_' || ch.is_ascii_alphanumeric()) {
        return Err(format!(
            "shader uniform name '{}' may only contain ASCII letters, digits, and underscores",
            name
        ));
    }
    if RESERVED_SHADER_UNIFORM_NAMES.contains(&name) {
        return Err(format!(
            "shader uniform name '{}' is reserved by WGSL or Lurek2D",
            name
        ));
    }
    Ok(())
}
/// Parse `source` and confirm it contains a valid fragment entry point; return error on failure.
fn validate_wgsl(source: &str, target: ShaderTarget) -> Result<(), String> {
    let module = wgpu::naga::front::wgsl::parse_str(source).map_err(|err| err.to_string())?;
    fragment_entry_signature(&module, target)?;
    Ok(())
}
/// Parse `source`, extract the fragment signature, and rewrite it as a helper function.
fn prepare_fragment_source_for_wrapper(
    source: &str,
    target: ShaderTarget,
) -> Result<PreparedFragmentSource, String> {
    let module = wgpu::naga::front::wgsl::parse_str(source).map_err(|err| err.to_string())?;
    let signature = fragment_entry_signature(&module, target)?;
    let rewritten = rewrite_fragment_entry_as_helper(source, &signature.name)?;
    Ok(PreparedFragmentSource {
        source: rewritten,
        entry_name: signature.name,
        inputs: signature.inputs,
    })
}
/// Locate the `@fragment` entry in `module` and return its name and input slots.
fn fragment_entry_signature(
    module: &wgpu::naga::Module,
    target: ShaderTarget,
) -> Result<FragmentEntrySignature, String> {
    let entry = module
        .entry_points
        .iter()
        .find(|entry| entry.stage == wgpu::naga::ShaderStage::Fragment)
        .ok_or_else(|| "shader source must define a fragment entry point".to_string())?;
    let inputs = entry
        .function
        .arguments
        .iter()
        .map(|argument| match argument.binding {
            Some(Binding::Location { location, .. }) => {
                validate_target_input(module, target, location, argument.ty)
            }
            _ => Err(
                "shader fragment entry point inputs must use supported @location bindings"
                    .to_string(),
            ),
        })
        .collect::<Result<Vec<_>, _>>()?;
    let result = entry.function.result.as_ref().ok_or_else(|| {
        "shader fragment entry point must return @location(0) vec4<f32>".to_string()
    })?;
    match result.binding {
        Some(Binding::Location { location: 0, .. }) => validate_vec4_f32(module, result.ty)?,
        _ => {
            return Err(
                "shader fragment entry point must return @location(0) vec4<f32>".to_string(),
            )
        }
    }
    Ok(FragmentEntrySignature {
        name: entry.name.clone(),
        inputs,
    })
}
fn validate_target_input(
    module: &wgpu::naga::Module,
    target: ShaderTarget,
    location: u32,
    ty: wgpu::naga::Handle<wgpu::naga::Type>,
) -> Result<ShaderFragmentInput, String> {
    let input = match target {
        ShaderTarget::Draw => match location {
            0 => {
                validate_vec4_f32(module, ty)?;
                ShaderFragmentInput::Color
            }
            1 => {
                validate_vec2_f32(module, ty)?;
                ShaderFragmentInput::Uv
            }
            _ => {
                return Err(format!(
                    "draw shader uses unsupported input @location({location}); expected color at 0 and uv at 1"
                ))
            }
        },
        ShaderTarget::PostFx | ShaderTarget::Image | ShaderTarget::Overlay => match location {
            0 => {
                validate_vec4_f32(module, ty)?;
                ShaderFragmentInput::Color
            }
            1 => {
                validate_vec2_f32(module, ty)?;
                ShaderFragmentInput::Uv
            }
            2 => {
                validate_vec2_f32(module, ty)?;
                ShaderFragmentInput::PixelOrLocal
            }
            3 => {
                validate_vec2_f32(module, ty)?;
                ShaderFragmentInput::ResolutionOrWorld
            }
            4 => {
                validate_vec2_f32(module, ty)?;
                ShaderFragmentInput::TexelOrVelocity
            }
            _ => {
                return Err(format!(
                    "{} shader uses unsupported input @location({location}); expected color, uv, pixel, resolution, or texel size",
                    target.as_str()
                ))
            }
        },
        ShaderTarget::Particle => match location {
            0 => {
                validate_vec4_f32(module, ty)?;
                ShaderFragmentInput::Color
            }
            1 => {
                validate_vec2_f32(module, ty)?;
                ShaderFragmentInput::Uv
            }
            2 => {
                validate_vec2_f32(module, ty)?;
                ShaderFragmentInput::PixelOrLocal
            }
            3 => {
                validate_vec2_f32(module, ty)?;
                ShaderFragmentInput::ResolutionOrWorld
            }
            4 => {
                validate_vec2_f32(module, ty)?;
                ShaderFragmentInput::TexelOrVelocity
            }
            5 => {
                validate_f32(module, ty)?;
                ShaderFragmentInput::Scalar0
            }
            6 => {
                validate_f32(module, ty)?;
                ShaderFragmentInput::Scalar1
            }
            7 => {
                validate_f32(module, ty)?;
                ShaderFragmentInput::Scalar2
            }
            8 => {
                validate_vec4_f32(module, ty)?;
                ShaderFragmentInput::SampledTextureColor
            }
            _ => {
                return Err(format!(
                    "particle shader uses unsupported input @location({location})"
                ))
            }
        },
        ShaderTarget::Light => match location {
            0 => {
                validate_vec4_f32(module, ty)?;
                ShaderFragmentInput::Color
            }
            1 => {
                validate_vec2_f32(module, ty)?;
                ShaderFragmentInput::Uv
            }
            2 => {
                validate_vec2_f32(module, ty)?;
                ShaderFragmentInput::PixelOrLocal
            }
            3 => {
                validate_vec2_f32(module, ty)?;
                ShaderFragmentInput::ResolutionOrWorld
            }
            4 => {
                validate_vec2_f32(module, ty)?;
                ShaderFragmentInput::TexelOrVelocity
            }
            5 => {
                validate_f32(module, ty)?;
                ShaderFragmentInput::Scalar0
            }
            6 => {
                validate_f32(module, ty)?;
                ShaderFragmentInput::Scalar1
            }
            7 => {
                validate_f32(module, ty)?;
                ShaderFragmentInput::Scalar2
            }
            8 => {
                validate_f32(module, ty)?;
                ShaderFragmentInput::Scalar3
            }
            9 => {
                validate_vec4_f32(module, ty)?;
                ShaderFragmentInput::AmbientColor
            }
            10 => {
                validate_vec4_f32(module, ty)?;
                ShaderFragmentInput::LightDirection
            }
            _ => return Err(format!("light shader uses unsupported input @location({location})")),
        },
    };
    Ok(input)
}
/// Assert that `ty` resolves to `vec2<f32>` in `module`.
fn validate_vec2_f32(
    module: &wgpu::naga::Module,
    ty: wgpu::naga::Handle<wgpu::naga::Type>,
) -> Result<(), String> {
    validate_vector_type(module, ty, VectorSize::Bi, "vec2<f32>")
}
/// Assert that `ty` resolves to `vec4<f32>` in `module`.
fn validate_vec4_f32(
    module: &wgpu::naga::Module,
    ty: wgpu::naga::Handle<wgpu::naga::Type>,
) -> Result<(), String> {
    validate_vector_type(module, ty, VectorSize::Quad, "vec4<f32>")
}
/// Assert that `ty` resolves to `f32`.
fn validate_f32(
    module: &wgpu::naga::Module,
    ty: wgpu::naga::Handle<wgpu::naga::Type>,
) -> Result<(), String> {
    let actual = &module.types[ty].inner;
    match actual {
        TypeInner::Scalar(scalar) if scalar.kind == ScalarKind::Float && scalar.width == 4 => {
            Ok(())
        }
        _ => Err("expected f32".to_string()),
    }
}
/// Assert that `ty` resolves to a float vector of `size` in `module`.
fn validate_vector_type(
    module: &wgpu::naga::Module,
    ty: wgpu::naga::Handle<wgpu::naga::Type>,
    size: VectorSize,
    expected: &str,
) -> Result<(), String> {
    match &module.types[ty].inner {
        TypeInner::Vector { size: actual_size, scalar }
            if *actual_size == size && scalar.kind == ScalarKind::Float && scalar.width == 4 =>
        {
            Ok(())
        }
        _ => Err(format!(
            "shader fragment entry point must use {expected} values for its color, uv, and return types"
        )),
    }
}
/// Strip `@fragment` from the entry function header and rename it to a plain helper.
fn rewrite_fragment_entry_as_helper(source: &str, entry_name: &str) -> Result<String, String> {
    let fn_marker = format!("fn {entry_name}");
    let fn_start = source.find(&fn_marker).ok_or_else(|| {
        format!("shader fragment entry point '{entry_name}' could not be located in source")
    })?;
    let fragment_attr_start = find_fragment_attribute_start(source, fn_start).ok_or_else(|| {
        format!("shader fragment entry point '{entry_name}' is missing @fragment")
    })?;
    let fragment_attr_end = fragment_attr_start + "@fragment".len();
    let body_start = find_function_body_start(source, fn_start)?;
    let header = &source[fn_start..body_start];
    let rewritten_header = rewrite_entry_point_header(header, entry_name)?;
    Ok(format!(
        "{}{}{}{}",
        &source[..fragment_attr_start],
        &source[fragment_attr_end..fn_start],
        rewritten_header,
        &source[body_start..],
    ))
}
/// Search backwards from `fn_start` for the nearest `@fragment` attribute with only whitespace between.
fn find_fragment_attribute_start(source: &str, fn_start: usize) -> Option<usize> {
    let prefix = &source[..fn_start];
    prefix.rmatch_indices("@fragment").find_map(|(index, _)| {
        let attr_end = index + "@fragment".len();
        source[attr_end..fn_start]
            .chars()
            .all(char::is_whitespace)
            .then_some(index)
    })
}
/// Return the byte offset of the `{` that opens the function body.
fn find_function_body_start(source: &str, fn_start: usize) -> Result<usize, String> {
    source[fn_start..]
        .char_indices()
        .find_map(|(offset, ch)| (ch == '{').then_some(fn_start + offset))
        .ok_or_else(|| "shader fragment entry point is missing a function body".to_string())
}
/// Rewrite an entry-point function header by stripping `@location` attributes from params and return.
fn rewrite_entry_point_header(header: &str, entry_name: &str) -> Result<String, String> {
    let paren_start = header.find('(').ok_or_else(|| {
        format!("shader fragment entry point '{entry_name}' is missing parameters")
    })?;
    let paren_end = find_matching_paren(header, paren_start)?;
    let params = &header[paren_start + 1..paren_end];
    let params = split_top_level_commas(params)
        .into_iter()
        .map(strip_leading_attributes)
        .filter(|param| !param.is_empty())
        .collect::<Vec<_>>();
    let return_clause = header[paren_end + 1..].trim();
    let return_clause = if let Some(rest) = return_clause.strip_prefix("->") {
        let ty = strip_leading_attributes(rest);
        format!(" -> {ty}")
    } else {
        String::new()
    };
    if params.is_empty() {
        Ok(format!("fn {entry_name}(){return_clause} "))
    } else {
        Ok(format!(
            "fn {entry_name}(\n    {}\n){return_clause} ",
            params.join(",\n    ")
        ))
    }
}
/// Return the index of the `)` matching the `(` at `open_index`.
fn find_matching_paren(text: &str, open_index: usize) -> Result<usize, String> {
    let mut depth = 0usize;
    for (offset, ch) in text[open_index..].char_indices() {
        match ch {
            '(' => depth += 1,
            ')' => {
                depth -= 1;
                if depth == 0 {
                    return Ok(open_index + offset);
                }
            }
            _ => {}
        }
    }
    Err("shader fragment entry point has an unclosed parameter list".to_string())
}
/// Split `text` on top-level commas, ignoring commas inside `()`, `<>`, and `[]`.
fn split_top_level_commas(text: &str) -> Vec<&str> {
    let mut parts = Vec::new();
    let mut start = 0usize;
    let mut paren_depth = 0usize;
    let mut angle_depth = 0usize;
    let mut bracket_depth = 0usize;
    for (index, ch) in text.char_indices() {
        match ch {
            '(' => paren_depth += 1,
            ')' => paren_depth = paren_depth.saturating_sub(1),
            '<' => angle_depth += 1,
            '>' => angle_depth = angle_depth.saturating_sub(1),
            '[' => bracket_depth += 1,
            ']' => bracket_depth = bracket_depth.saturating_sub(1),
            ',' if paren_depth == 0 && angle_depth == 0 && bracket_depth == 0 => {
                parts.push(text[start..index].trim());
                start = index + ch.len_utf8();
            }
            _ => {}
        }
    }
    parts.push(text[start..].trim());
    parts
}
/// Strip all leading WGSL `@attribute` and `@attribute(...)` tokens from `text`.
fn strip_leading_attributes(text: &str) -> String {
    let mut remainder = text.trim();
    while remainder.starts_with('@') {
        remainder = consume_attribute(remainder).trim_start();
    }
    remainder.trim().to_string()
}
/// Consume one WGSL `@attr` or `@attr(...)` token at the start of `text` and return the remainder.
fn consume_attribute(text: &str) -> &str {
    let bytes = text.as_bytes();
    let mut index = 1usize;
    while index < bytes.len() {
        let ch = bytes[index] as char;
        if ch.is_ascii_alphanumeric() || ch == '_' {
            index += 1;
            continue;
        }
        if ch == '(' {
            let mut depth = 1usize;
            index += 1;
            while index < bytes.len() && depth > 0 {
                match bytes[index] as char {
                    '(' => depth += 1,
                    ')' => depth -= 1,
                    _ => {}
                }
                index += 1;
            }
        }
        break;
    }
    &text[index..]
}
