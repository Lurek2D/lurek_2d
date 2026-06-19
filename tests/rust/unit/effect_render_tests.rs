//! File: tests/rust/unit/effect_render_tests.rs

// TODO(lua-first): public Rust API coverage in this file should live in tests/lua/unit/; keep only private/internal seams here.

use lurek2d::effect::{PostFxEffect, PostFxEffectType, PostFxLimits, PostFxStack};
use lurek2d::render::renderer::RenderCommand;

#[test]
fn empty_stack_produces_no_commands() {
    let stack = PostFxStack::new(800, 600);
    let plan = stack.generate_render_commands(1, &[], &PostFxLimits::default());
    assert!(plan.commands.is_empty());
}

#[test]
fn stack_with_disabled_effects_produces_no_commands() {
    let mut stack = PostFxStack::new(800, 600);
    stack.add(0);
    stack.set_enabled(0, false);
    let effects = vec![PostFxEffect::new(PostFxEffectType::Blur)];
    let plan = stack.generate_render_commands(1, &effects, &PostFxLimits::default());
    assert!(plan.commands.is_empty());
}

#[test]
fn stack_with_enabled_effects_produces_three_commands() {
    let mut stack = PostFxStack::new(800, 600);
    stack.add(0);
    stack.add(1);
    let effects = vec![
        PostFxEffect::new(PostFxEffectType::Bloom),
        PostFxEffect::new(PostFxEffectType::Blur),
    ];
    let plan = stack.generate_render_commands(1, &effects, &PostFxLimits::default());
    assert_eq!(plan.commands.len(), 3);
    assert!(matches!(
        plan.commands[0],
        RenderCommand::BeginPostFx { .. }
    ));
    assert!(matches!(plan.commands[1], RenderCommand::EndPostFx { .. }));
    assert!(matches!(
        plan.commands[2],
        RenderCommand::ApplyPostFx { .. }
    ));
}

#[test]
fn begin_capture_uses_stack_id() {
    let stack = PostFxStack::new(800, 600);
    let cmd = stack.begin_capture_command(42);
    if let RenderCommand::BeginPostFx { stack_id } = cmd {
        assert_eq!(stack_id, 42);
    } else {
        panic!("Expected BeginPostFx");
    }
}
