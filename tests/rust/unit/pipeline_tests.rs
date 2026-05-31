//! File: tests/rust/unit/pipeline_tests.rs

use lurek2d::pipeline::dag::Pipeline;
use lurek2d::pipeline::scheduler::PipelineScheduler;
use lurek2d::pipeline::step::{PipelineStep, StepStatus};

mod task_graph_compat_tests {
    #[test]
    fn task_graph_path_exposes_pipeline_types() {
        let mut p = lurek2d::task_graph::Pipeline::new("compat");
        p.add_step(lurek2d::task_graph::PipelineStep::new("a"))
            .unwrap();
        assert_eq!(p.get_step_count(), 1);
    }

    #[test]
    fn task_graph_nested_modules_compile_and_work() {
        let mut p = lurek2d::task_graph::dag::Pipeline::new("compat_nested");
        let mut step = lurek2d::task_graph::step::PipelineStep::new("a");
        step.status = lurek2d::task_graph::step::StepStatus::Waiting;
        p.add_step(step).unwrap();

        let mut scheduler = lurek2d::task_graph::scheduler::PipelineScheduler::new();
        scheduler.start(&p);
        let ready = scheduler.update_ready_refs(0.0, &p);
        assert_eq!(ready, vec!["a"]);
    }
}

// â”€â”€ scheduler tests â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

mod scheduler_tests {
    use super::*;

    #[test]
    fn new_scheduler_is_stopped() {
        let s = PipelineScheduler::new();
        assert!(!s.is_running);
        assert!((s.elapsed).abs() < f32::EPSILON);
    }

    #[test]
    fn start_marks_running() {
        let mut s = PipelineScheduler::new();
        let p = Pipeline::new("test");
        s.start(&p);
        assert!(s.is_running);
    }

    #[test]
    fn update_advances_elapsed() {
        let mut s = PipelineScheduler::new();
        let p = Pipeline::new("test");
        s.start(&p);
        s.update(0.1, &p);
        assert!((s.elapsed - 0.1).abs() < 1e-5);
    }

    #[test]
    fn update_when_stopped_returns_empty() {
        let mut s = PipelineScheduler::new();
        let p = Pipeline::new("test");
        let ready = s.update(0.1, &p);
        assert!(ready.is_empty());
    }

    #[test]
    fn reset_clears_state() {
        let mut s = PipelineScheduler::new();
        let mut p = Pipeline::new("test");
        p.add_step(PipelineStep::new("a")).unwrap();
        s.start(&p);
        s.update(1.0, &p);
        s.reset();
        assert!(!s.is_running);
        assert!((s.elapsed).abs() < f32::EPSILON);
    }

    #[test]
    fn default_matches_new() {
        let a = PipelineScheduler::new();
        let b = PipelineScheduler::default();
        assert_eq!(a.is_running, b.is_running);
    }

    #[test]
    fn mark_step_waiting_inserts_delay() {
        let mut s = PipelineScheduler::new();
        let mut p = Pipeline::new("test");
        let mut step = PipelineStep::new("a");
        step.delay = 2.0;
        p.add_step(step).unwrap();
        s.start(&p);
        s.mark_step_waiting("a", &p);
        let ready = s.update(1.0, &p);
        assert!(ready.is_empty());
    }

    #[test]
    fn update_ready_refs_reports_waiting_step_without_owned_clones() {
        let mut s = PipelineScheduler::new();
        let mut p = Pipeline::new("test");
        let mut step = PipelineStep::new("a");
        step.status = StepStatus::Waiting;
        p.add_step(step).unwrap();
        s.start(&p);

        let ready = s.update_ready_refs(0.0, &p);
        assert_eq!(ready, vec!["a"]);
    }
}
