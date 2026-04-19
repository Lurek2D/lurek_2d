//! Tests for the debugbridge module.

// ── bridge ────────────────────────────────────────────────────────────────────

mod bridge_tests {
    use lurek2d::debugbridge::BridgeShared;

    #[test]
    fn new_bridge_has_empty_queues() {
        let b = BridgeShared::new();
        assert!(b.pending_requests.is_empty());
        assert!(b.pending_responses.is_empty());
        assert!(b.broadcast_queue.is_empty());
        assert!(b.print_history.is_empty());
        assert!(b.frame_times.is_empty());
        assert_eq!(b.client_count, 0);
        assert_eq!(b.port, 0);
        assert!(!b.screenshot_requested);
        assert_eq!(b.screenshot_scale, 1);
    }

    #[test]
    fn default_equals_new() {
        let a = BridgeShared::new();
        let b = BridgeShared::default();
        assert_eq!(a.max_print_history, b.max_print_history);
        assert_eq!(a.max_frame_times, b.max_frame_times);
    }

    #[test]
    fn elapsed_is_non_negative() {
        let b = BridgeShared::new();
        assert!(b.elapsed() >= 0.0);
    }

    #[test]
    fn push_print_appends_entry() {
        let mut b = BridgeShared::new();
        b.push_print("hello", "test.lua", 10);
        assert_eq!(b.print_history.len(), 1);
        assert_eq!(b.print_history[0].message, "hello");
        assert_eq!(b.print_history[0].source, "test.lua");
        assert_eq!(b.print_history[0].line, 10);
    }

    #[test]
    fn push_print_evicts_oldest_when_full() {
        let mut b = BridgeShared::new();
        b.max_print_history = 3;
        for i in 0..5 {
            b.push_print(&format!("msg{i}"), "src", 1);
        }
        assert_eq!(b.print_history.len(), 3);
        assert_eq!(b.print_history[0].message, "msg2");
    }

    #[test]
    fn record_frame_appends_and_evicts() {
        let mut b = BridgeShared::new();
        b.max_frame_times = 4;
        for i in 0..6 {
            b.record_frame(i as f64 * 0.016);
        }
        assert_eq!(b.frame_times.len(), 4);
        assert!((b.frame_times[0] - 0.032).abs() < 1e-9);
    }

    #[test]
    fn get_performance_empty_frames() {
        let b = BridgeShared::new();
        let p = b.get_performance();
        assert_eq!(p["fps"], 0.0);
        assert_eq!(p["dt"], 0.0);
    }

    #[test]
    fn get_performance_with_data() {
        let mut b = BridgeShared::new();
        b.record_frame(0.016);
        b.record_frame(0.016);
        let p = b.get_performance();
        assert!((p["avgDt"].as_f64().unwrap() - 0.016).abs() < 1e-9);
        assert!((p["minDt"].as_f64().unwrap() - 0.016).abs() < 1e-9);
        assert!((p["maxDt"].as_f64().unwrap() - 0.016).abs() < 1e-9);
    }

    #[test]
    fn set_max_print_history_clamps_and_trims() {
        let mut b = BridgeShared::new();
        for i in 0..10 {
            b.push_print(&format!("m{i}"), "s", 1);
        }
        b.set_max_print_history(5);
        assert_eq!(b.max_print_history, 5);
        assert_eq!(b.print_history.len(), 5);

        b.set_max_print_history(0);
        assert_eq!(b.max_print_history, 1);
    }

    #[test]
    fn capture_print_with_broadcast_queues_event() {
        let mut b = BridgeShared::new();
        b.capture_print_with_broadcast("test msg", "main.lua", 42);
        assert_eq!(b.print_history.len(), 1);
        assert_eq!(b.broadcast_queue.len(), 1);
        let event: serde_json::Value =
            serde_json::from_str(b.broadcast_queue.front().unwrap()).unwrap();
        assert_eq!(event["event"], "print");
        assert_eq!(event["data"]["message"], "test msg");
        assert_eq!(event["data"]["source"], "main.lua");
        assert_eq!(event["data"]["line"], 42);
    }
}

// ── server ────────────────────────────────────────────────────────────────────

mod server_tests {
    use lurek2d::debugbridge::{handle_client_message, BridgeShared};
    use std::sync::{Arc, Mutex};

    fn make_shared() -> Arc<Mutex<BridgeShared>> {
        Arc::new(Mutex::new(BridgeShared::new()))
    }

    #[test]
    fn ping_responds_immediately() {
        let shared = make_shared();
        handle_client_message(r#"{"id":1,"method":"ping"}"#, 0, &shared);
        let sh = shared.lock().unwrap();
        assert_eq!(sh.pending_responses.len(), 1);
        let resp = &sh.pending_responses[0];
        assert_eq!(resp.id, 1);
        assert_eq!(resp.client_idx, 0);
        assert_eq!(resp.result["pong"], true);
    }

    #[test]
    fn get_performance_responds() {
        let shared = make_shared();
        handle_client_message(r#"{"id":2,"method":"getPerformance"}"#, 0, &shared);
        let sh = shared.lock().unwrap();
        assert_eq!(sh.pending_responses.len(), 1);
        assert_eq!(sh.pending_responses[0].id, 2);
        assert!(sh.pending_responses[0].result.get("fps").is_some());
    }

    #[test]
    fn get_client_count_responds() {
        let shared = make_shared();
        handle_client_message(r#"{"id":3,"method":"getClientCount"}"#, 0, &shared);
        let sh = shared.lock().unwrap();
        assert_eq!(sh.pending_responses[0].result["count"], 0);
    }

    #[test]
    fn get_status_responds() {
        let shared = make_shared();
        handle_client_message(r#"{"id":4,"method":"getStatus"}"#, 0, &shared);
        let sh = shared.lock().unwrap();
        assert_eq!(sh.pending_responses[0].result["running"], true);
    }

    #[test]
    fn clear_print_history_clears() {
        let shared = make_shared();
        {
            let mut sh = shared.lock().unwrap();
            sh.push_print("msg", "s", 1);
        }
        handle_client_message(r#"{"id":5,"method":"clearPrintHistory"}"#, 0, &shared);
        let sh = shared.lock().unwrap();
        assert!(sh.print_history.is_empty());
        assert_eq!(sh.pending_responses[0].result["cleared"], true);
    }

    #[test]
    fn get_print_history_returns_all() {
        let shared = make_shared();
        {
            let mut sh = shared.lock().unwrap();
            sh.push_print("a", "s", 1);
            sh.push_print("b", "s", 2);
        }
        handle_client_message(r#"{"id":6,"method":"getPrintHistory"}"#, 0, &shared);
        let sh = shared.lock().unwrap();
        let result = &sh.pending_responses[0].result;
        assert_eq!(result.as_array().unwrap().len(), 2);
    }

    #[test]
    fn get_print_history_with_count() {
        let shared = make_shared();
        {
            let mut sh = shared.lock().unwrap();
            for i in 0..5 {
                sh.push_print(&format!("m{i}"), "s", 1);
            }
        }
        handle_client_message(
            r#"{"id":7,"method":"getPrintHistory","params":{"count":2}}"#,
            0,
            &shared,
        );
        let sh = shared.lock().unwrap();
        let result = &sh.pending_responses[0].result;
        assert_eq!(result.as_array().unwrap().len(), 2);
    }

    #[test]
    fn request_screenshot_sets_flag() {
        let shared = make_shared();
        handle_client_message(
            r#"{"id":8,"method":"requestScreenshot","params":{"scale":4}}"#,
            0,
            &shared,
        );
        let sh = shared.lock().unwrap();
        assert!(sh.screenshot_requested);
        assert_eq!(sh.screenshot_scale, 4);
        assert_eq!(sh.pending_responses[0].result["requested"], true);
    }

    #[test]
    fn eval_queued_as_pending_request() {
        let shared = make_shared();
        handle_client_message(
            r#"{"id":9,"method":"eval","params":{"code":"print(1)"}}"#,
            0,
            &shared,
        );
        let sh = shared.lock().unwrap();
        assert!(sh.pending_responses.is_empty());
        assert_eq!(sh.pending_requests.len(), 1);
        assert_eq!(sh.pending_requests[0].method, "eval");
        assert_eq!(sh.pending_requests[0].id, 9);
    }

    #[test]
    fn unknown_method_returns_error() {
        let shared = make_shared();
        handle_client_message(r#"{"id":10,"method":"foobar"}"#, 0, &shared);
        let sh = shared.lock().unwrap();
        assert!(sh.pending_responses[0].result["error"]
            .as_str()
            .unwrap()
            .contains("unknown method"));
    }

    #[test]
    fn invalid_json_ignored() {
        let shared = make_shared();
        handle_client_message("not json at all", 0, &shared);
        let sh = shared.lock().unwrap();
        assert!(sh.pending_responses.is_empty());
        assert!(sh.pending_requests.is_empty());
    }
}
