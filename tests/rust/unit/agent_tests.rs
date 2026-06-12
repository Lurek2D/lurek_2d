use lurek2d::agent::{AgentClient, AgentRequest};
use lurek2d::runtime::config::Config;

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
        format: "text".to_string(),
        options: serde_json::Value::Null,
        callback_id: 7,
        max_retries: 0,
        timeout_secs: 1,
    };

    client.send_prompt(request).expect("request should queue");
    assert!(client.in_flight_count() <= 1);
    client.cancel(7);
}
