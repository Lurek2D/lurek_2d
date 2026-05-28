use lurek2d::agent::AgentState;

#[test]
fn agent_state_formats_prompt_with_registered_skills() {
    let mut state = AgentState::new(
        "http://test:11434".to_string(),
        "test-model".to_string(),
        "You are an AI assistant.".to_string(),
        "json".to_string(),
        std::collections::HashMap::new(),
    );

    let prompt = state.build_system_block();
    assert_eq!(prompt, "You are an AI assistant.");

    state.add_skill("logger".to_string(), "Use lurek.log.info()".to_string());

    let prompt_with_skill = state.build_system_block();
    assert!(prompt_with_skill.contains("You are an AI assistant."));
    assert!(prompt_with_skill.contains("Skills (Additional Instructions):"));
    assert!(prompt_with_skill.contains("- [logger]: Use lurek.log.info()"));
}

#[test]
fn agent_state_add_skill_preserves_insertion_order() {
    let mut state = AgentState::new(
        "http://test:11434".to_string(),
        "test-model".to_string(),
        "Base prompt".to_string(),
        "json".to_string(),
        std::collections::HashMap::new(),
    );

    state.add_skill("first".to_string(), "one".to_string());
    state.add_skill("second".to_string(), "two".to_string());

    let prompt = state.build_system_block();
    let first = prompt.find("- [first]: one").expect("first skill should exist");
    let second = prompt.find("- [second]: two").expect("second skill should exist");
    assert!(first < second, "skills should remain in insertion order");
}
