//! File: tests/rust/unit/effect_contract_tests.rs

use lurek2d::effect::{
    PostFxDebugImageLimits, PostFxDuplicatePolicy, PostFxEffect, PostFxEffectType, PostFxLimits,
    PostFxStack, POSTFX_AUTO_UNIFORMS,
};
use lurek2d::render::renderer::RenderCommand;

#[test]
fn postfx_param_rejects_nan_unknown_and_out_of_range() {
    let mut blur = PostFxEffect::new(PostFxEffectType::Blur);
    assert!(blur.try_set_parameter("radius", f32::NAN).is_err());
    assert!(blur.try_set_parameter("bogus", 1.0).is_err());
    assert!(blur.try_set_parameter("radius", -1.0).is_err());

    let mut bloom = PostFxEffect::new(PostFxEffectType::Bloom);
    assert!(bloom.try_set_parameter("threshold", 2.0).is_err());

    let mut dither = PostFxEffect::new(PostFxEffectType::Dither);
    assert!(dither.try_set_parameter("palette_size", 1.0).is_err());

    let mut motion_blur = PostFxEffect::new(PostFxEffectType::MotionBlur);
    assert!(motion_blur.try_set_parameter("samples", -1.0).is_err());
    assert!(motion_blur.try_set_parameter("samples", 2.5).is_err());
}

#[test]
fn postfx_default_param_schema_matches_defaults() {
    for name in PostFxEffectType::built_in_names() {
        let effect_type = PostFxEffectType::from_name(name).expect("built-in name must parse");
        let defaults = effect_type.default_params();
        let schema = effect_type.param_schema();
        assert_eq!(
            defaults.len(),
            schema.len(),
            "schema/default count drift for {name}"
        );
        for entry in schema {
            assert_eq!(
                defaults.get(entry.name).copied(),
                Some(entry.default),
                "default drift for {name}.{}",
                entry.name
            );
        }
    }
}

#[test]
fn stack_validate_rejects_stale_effect_index() {
    let mut stack = PostFxStack::new(320, 180);
    stack.add(999);
    let diagnostics = stack.validate_against(3, &PostFxLimits::default());
    assert!(diagnostics.has_errors());
    assert!(diagnostics
        .iter()
        .any(|entry| entry.code == "stale_effect_index"));
}

#[test]
fn stack_try_new_rejects_zero_or_huge_dimensions() {
    let limits = PostFxLimits::default();
    assert!(PostFxStack::try_new(0, 10, &limits).is_err());
    assert!(PostFxStack::try_new(limits.max_stack_width + 1, 10, &limits).is_err());
    assert!(PostFxStack::try_new(limits.max_stack_width, limits.max_stack_height, &limits).is_ok());
}

#[test]
fn apply_command_includes_passes_or_reports_registry_contract() {
    let mut bloom = PostFxEffect::new(PostFxEffectType::Bloom);
    bloom.try_set_parameter("threshold", 0.4).unwrap();
    let blur = PostFxEffect::new(PostFxEffectType::Blur);
    let effects = vec![bloom, blur];

    let mut stack = PostFxStack::new(800, 600);
    stack.add(0);
    stack.add(1);

    let plan = stack.generate_render_commands(7, &effects, &PostFxLimits::default());
    assert!(!plan.diagnostics.has_errors());
    assert_eq!(plan.commands.len(), 3);

    match &plan.commands[2] {
        RenderCommand::ApplyPostFx {
            stack_id,
            passes,
            width,
            height,
        } => {
            assert_eq!(*stack_id, 7);
            assert_eq!((*width, *height), (800, 600));
            assert_eq!(passes.len(), 2);
            assert_eq!(passes[0].effect_name, "bloom");
            assert_eq!(passes[1].effect_name, "blur");
        }
        other => panic!("expected ApplyPostFx, got {other:?}"),
    }
}

#[test]
fn custom_shader_invalid_id_rejected() {
    assert!(PostFxEffect::new_custom_checked(99, |_| false).is_err());
    let custom = PostFxEffect::new_custom(99);
    assert!(custom.validate_custom_shader(|id| id == 1).is_err());
}

#[test]
fn auto_uniform_contract_snapshot() {
    assert_eq!(
        POSTFX_AUTO_UNIFORMS,
        &[
            "time",
            "resolution",
            "texel_size",
            "frame_index",
            "stack_index"
        ]
    );
}

#[test]
fn enabled_effects_iter_no_alloc() {
    let mut stack = PostFxStack::new(320, 180);
    stack.add(2);
    stack.add(5);
    stack.set_enabled(5, false);
    stack.add(8);
    assert_eq!(stack.enabled_effects_iter().collect::<Vec<_>>(), vec![2, 8]);
}

#[test]
fn debug_image_rejects_huge_dimensions() {
    let stack = PostFxStack::new(320, 180);
    let limits = PostFxDebugImageLimits::default();
    assert!(stack
        .try_draw_info_to_image(limits.max_width + 1, 64, &limits)
        .is_err());
    assert!(stack
        .try_draw_to_image(limits.max_width + 1, 64, &limits)
        .is_err());
}

#[test]
fn duplicate_effect_policy_warns_or_allows_explicitly() {
    let limits = PostFxLimits::default();
    let mut warn_stack = PostFxStack::new(320, 180);
    warn_stack.add(1);
    warn_stack.add(1);
    let warn_diagnostics = warn_stack.validate_against(4, &limits);
    assert!(!warn_diagnostics.has_errors());
    assert!(warn_diagnostics
        .iter()
        .any(|entry| entry.code == "duplicate_effect_index"));

    let mut allow_stack = warn_stack.clone();
    allow_stack.set_duplicate_policy(PostFxDuplicatePolicy::Allow);
    let allow_diagnostics = allow_stack.validate_against(4, &limits);
    assert!(allow_diagnostics.is_empty());

    let mut disallow_stack = warn_stack.clone();
    disallow_stack.set_duplicate_policy(PostFxDuplicatePolicy::Disallow);
    let disallow_diagnostics = disallow_stack.validate_against(4, &limits);
    assert!(disallow_diagnostics.has_errors());
}
