use lurek2d::agent::{
    AISystemState, AgentClient, AgentClientConfig, AgentError, AgentMemory, AgentRequest,
    AgentResponseFormat, AgentState, AgentTransport, OllamaManager, OllamaModelPolicy,
    OllamaProcessPolicy, WorkingMemory,
};
use lurek2d::runtime::config::Config;
use serde_json::json;
use std::collections::HashMap;
use std::path::PathBuf;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;
use std::time::Duration;

struct SlowSuccessTransport {
    calls: AtomicUsize,
    sleep_ms: u64,
}

impl SlowSuccessTransport {
    fn new(sleep_ms: u64) -> Self {
        Self {
            calls: AtomicUsize::new(0),
            sleep_ms,
        }
    }
}

impl AgentTransport for SlowSuccessTransport {
    fn execute(&self, _req: &AgentRequest) -> Result<String, AgentError> {
        self.calls.fetch_add(1, Ordering::Relaxed);
        std::thread::sleep(Duration::from_millis(self.sleep_ms));
        Ok("ok".to_string())
    }
}

#[test]
fn agent_module_is_disabled_without_network() {
    let mut config = Config::default();
    config.modules.network = false;
    config.modules.agent = true;

    config.modules.validate_and_fix();

    assert!(!config.modules.agent);
}

#[test]
fn agent_client_tracks_and_cancels_requests() {
    let client = AgentClient::new();
    let request = AgentRequest {
        url: "http://127.0.0.1:1/api/generate".to_string(),
        model: "missing".to_string(),
        prompt: "hello".to_string(),
        system: String::new(),
        format: AgentResponseFormat::Text,
        options: serde_json::Value::Null,
        callback_id: 7,
        max_retries: 0,
        timeout_secs: 1,
    };

    client.send_prompt(request).expect("request should queue");
    assert!(client.in_flight_count() <= 1);
    client.cancel(7);
}

#[test]
fn agent_client_rejects_queue_overflow() {
    let transport = Arc::new(SlowSuccessTransport::new(250));
    let client = AgentClient::with_transport(
        AgentClientConfig {
            max_in_flight: 1,
            max_queue_depth: 1,
            retry_backoff_ms: 1,
        },
        transport,
    );

    for callback_id in 1..=2 {
        client
            .send_prompt(AgentRequest {
                url: "http://127.0.0.1:11434/api/generate".to_string(),
                model: "llama3".to_string(),
                prompt: format!("prompt {}", callback_id),
                system: String::new(),
                format: AgentResponseFormat::Text,
                options: serde_json::Value::Null,
                callback_id,
                max_retries: 0,
                timeout_secs: 1,
            })
            .expect("first two requests should fit in bounded transport");
    }

    let error = client
        .send_prompt(AgentRequest {
            url: "http://127.0.0.1:11434/api/generate".to_string(),
            model: "llama3".to_string(),
            prompt: "overflow".to_string(),
            system: String::new(),
            format: AgentResponseFormat::Text,
            options: serde_json::Value::Null,
            callback_id: 3,
            max_retries: 0,
            timeout_secs: 1,
        })
        .expect_err("third request should be rejected by the bounded queue");

    assert!(matches!(error, AgentError::QueueFull(_)));
}

#[test]
fn agent_state_rejects_external_host_in_safe_mode() {
    let state = AgentState::new(
        "http://169.254.169.254/api/generate".to_string(),
        "llama3".to_string(),
        String::new(),
        "text".to_string(),
        HashMap::new(),
    );

    assert!(matches!(state, Err(AgentError::InvalidRequest(_))));
}

#[test]
fn agent_state_rejects_invalid_format() {
    let state = AgentState::new(
        "http://127.0.0.1:11434/api/generate".to_string(),
        "llama3".to_string(),
        String::new(),
        "yaml".to_string(),
        HashMap::new(),
    );

    assert!(matches!(state, Err(AgentError::InvalidRequest(_))));
}

#[test]
fn context_builder_reports_skill_provenance() {
    let mut state = AISystemState::new("system".to_string());
    state.add_instruction("safety".to_string(), "be safe".to_string());
    state.add_system_skill(
        "math".to_string(),
        vec!["matrix".to_string(), "algebra".to_string()],
        "help with math".to_string(),
    );

    let report = state
        .build_context_report("solve matrix problem", &["safety".to_string()])
        .expect("context report should build");

    assert!(report.text.contains("Instruction safety"));
    assert_eq!(2, report.provenance.len());
    assert_eq!("instruction", report.provenance[0].kind);
    assert_eq!("system_skill", report.provenance[1].kind);
    assert!(report.provenance[1].reason.contains("matrix"));
}

#[test]
fn working_memory_zero_capacity_maps_to_safe_default() {
    let memory = WorkingMemory::new(0);
    assert_eq!(64, memory.capacity());
}

#[test]
fn memory_save_rejects_path_traversal() {
    let memory = AgentMemory::new(8, Some("..\\escape.json".to_string()));
    let error = memory
        .save()
        .expect_err("path traversal should be rejected");
    assert!(error.contains("outside sandbox root"));
}

#[test]
fn memory_load_rejects_huge_file() {
    let root = PathBuf::from("work").join("agent_tests");
    std::fs::create_dir_all(&root).expect("test workspace should exist");
    let path = root.join("huge_memory.json");
    let huge_payload = format!(
        "{{\"version\":1,\"working_capacity\":64,\"working\":[],\"episodic\":[],\"semantic\":{{\"blob\":\"{}\"}}}}",
        "x".repeat(4096)
    );
    std::fs::write(&path, huge_payload).expect("test file should be written");

    let mut memory = AgentMemory::new(8, Some(path.to_string_lossy().to_string()));
    memory.storage_policy.max_bytes = 128;
    let error = memory
        .load()
        .expect_err("oversized file should be rejected");
    assert!(error.contains("exceeds max_bytes"));
}

#[test]
fn memory_diagnostics_report_counts_and_limits() {
    let mut memory = AgentMemory::new(3, None);
    memory.working.push("a".to_string(), json!(1));
    memory.episodic.record(1, HashMap::new());
    memory.semantic.learn("fact".to_string(), json!({"x": 1}));

    let diagnostics = memory.diagnostics_snapshot();
    assert_eq!(1, diagnostics.working_entries);
    assert_eq!(1, diagnostics.episodic_entries);
    assert_eq!(1, diagnostics.semantic_entries);
    assert!(diagnostics.max_bytes >= diagnostics.approx_bytes);
}

#[test]
fn ollama_pull_rejects_disallowed_model() {
    let mut manager = OllamaManager::with_policies(
        "http://127.0.0.1:11434".to_string(),
        OllamaProcessPolicy::default(),
        OllamaModelPolicy {
            allowed_prefixes: vec!["llama".to_string()],
            ..OllamaModelPolicy::default()
        },
    );

    let error = manager
        .pull_model("mistral:latest".to_string())
        .expect_err("disallowed prefix should be rejected");
    assert!(error.contains("allowed prefix"));
}

#[test]
fn delete_model_requires_policy_confirmation() {
    let manager = OllamaManager::with_policies(
        "http://127.0.0.1:11434".to_string(),
        OllamaProcessPolicy::default(),
        OllamaModelPolicy {
            protected_models: vec!["llama3:latest".to_string()],
            ..OllamaModelPolicy::default()
        },
    );

    let error = manager
        .delete_model("llama3:latest", None)
        .expect_err("protected models should require confirmation");
    assert!(error.contains("confirm token"));
}

#[test]
fn ollama_cancel_pull_marks_request_as_cancelled() {
    let mut manager = OllamaManager::with_policies(
        "http://127.0.0.1:11434".to_string(),
        OllamaProcessPolicy::default(),
        OllamaModelPolicy::default(),
    );
    let callback_id = manager
        .pull_model("llama3".to_string())
        .expect("valid model name should queue");
    assert!(manager.cancel_pull(callback_id));
}

#[test]
fn agent_options_reject_unknown_passthrough_by_default() {
    let mut options = HashMap::new();
    options.insert("custom_unsafe".to_string(), json!(true));
    let state = AgentState::new(
        "http://127.0.0.1:11434/api/generate".to_string(),
        "llama3".to_string(),
        String::new(),
        "text".to_string(),
        options,
    );

    assert!(matches!(state, Err(AgentError::InvalidRequest(_))));
}
