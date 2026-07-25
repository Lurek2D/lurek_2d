"""Self-tests for the local RAG index, reading, and recall evaluation tools."""

from __future__ import annotations

import importlib.util
import json
import sys
import tempfile
import unittest
from unittest.mock import patch
from pathlib import Path
import duckdb


REPO = Path(__file__).resolve().parents[2]
RAG_DIR = REPO / "tools" / "rag"
sys.path.insert(0, str(RAG_DIR))


def _load(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    mod = importlib.util.module_from_spec(spec)
    sys.modules[name] = mod
    spec.loader.exec_module(mod)
    return mod


build_index = _load("test_rag_build_index", RAG_DIR / "build_index.py")
query = _load("test_rag_query", RAG_DIR / "query.py")
eval_tool = _load("test_rag_eval", RAG_DIR / "eval.py")
context_tool = _load("test_rag_context", RAG_DIR / "context.py")
insights_tool = _load("test_rag_insights", RAG_DIR / "insights.py")


class RagToolTests(unittest.TestCase):
    def build_fixture_index(self, db_path: Path) -> None:
        build_index.build_index(
            [
                "AGENTS.md",
                ".codex/AGENTS.md",
                ".codex/skills/create-rag-artifact/SKILL.md",
                "tools/AGENTS.md",
                "tools/rag/AGENTS.md",
                "tools/rag/build_index.py",
                "tools/rag/context.py",
                "tools/rag/insights.py",
                "tools/rag/query.py",
                "tools/rag/rag.toml",
                "tools/mcp/lurek_mcp_server.py",
                "content/examples/AGENTS.md",
                "content/examples/window.lua",
            ],
            db_path,
        )

    def test_search_can_return_readable_content_and_line_ranges(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            db_path = Path(tmp) / "rag.db"
            self.build_fixture_index(db_path)
            report = query.search_index(
                "RAG rag.toml build_index query",
                profile="engine",
                limit=5,
                db_path_override=db_path,
                include_content=True,
            )

        self.assertNotIn("error", report)
        self.assertTrue(report["results"])
        top = report["results"][0]
        self.assertIn("content", top)
        self.assertGreaterEqual(top["line_start"], 1)
        self.assertGreaterEqual(top["line_end"], top["line_start"])

    def test_search_limits_are_capped_by_contract(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            db_path = Path(tmp) / "rag.db"
            self.build_fixture_index(db_path)
            report = query.search_index(
                "RAG rag.toml build_index query",
                profile="engine",
                limit=0,
                db_path_override=db_path,
            )

        self.assertIn("error", report)

    def test_search_rejects_excessive_limit(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            db_path = Path(tmp) / "rag.db"
            self.build_fixture_index(db_path)
            report = query.search_index(
                "RAG rag.toml build_index query",
                profile="engine",
                limit=99,
                db_path_override=db_path,
            )

        self.assertIn("error", report)

    def test_read_chunk_returns_neighbors(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            db_path = Path(tmp) / "rag.db"
            self.build_fixture_index(db_path)
            report = query.search_index("create rag artifact workflow", "engine", 5, db_path)
            chunk_id = report["results"][0]["id"]
            read_report = query.read_chunk(chunk_id, db_path, neighbors=1)

        self.assertIn("chunk", read_report)
        self.assertEqual(read_report["chunk"]["id"], chunk_id)
        self.assertIn("content", read_report["chunk"])
        self.assertIn("neighbors", read_report["chunk"])

    def test_recall_eval_uses_prompt_baseline(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            tmp_path = Path(tmp)
            db_path = tmp_path / "rag.db"
            baseline_path = tmp_path / "baseline.json"
            self.build_fixture_index(db_path)
            baseline_path.write_text(
                json.dumps(
                    [
                        {
                            "query": "RAG rag.toml build_index query",
                            "profile": "engine",
                            "must_match_any": ["tools/rag/query.py", "tools/rag/AGENTS.md"],
                        },
                        {
                            "query": "create rag artifact skill workflow",
                            "profile": "engine",
                            "must_match_any": [".codex/skills/create-rag-artifact/SKILL.md"],
                        },
                        {
                            "query": "AGENTS rules workflow",
                            "profile": "engine",
                            "must_match_any": [".codex/AGENTS.md", "AGENTS.md", "tools/rag/AGENTS.md"],
                        },
                        {
                            "query": "Codex AGENTS skills agents",
                            "profile": "engine",
                            "must_match_any": [".codex/skills/create-rag-artifact/SKILL.md", "AGENTS.md"],
                        },
                        {
                            "query": "window fullscreen title dpi example",
                            "runner": "context",
                            "profile": "game",
                            "must_match_any": ["content/examples/window.lua"],
                        },
                        {
                            "query": "which mcp tool should I run for example coverage validation",
                            "runner": "context",
                            "profile": "engine",
                            "must_match_any": ["tools/mcp/lurek_mcp_server.py"],
                            "must_tool_any": ["lua_example_coverage"],
                        },
                    ]
                ),
                encoding="utf-8",
            )
            report = eval_tool.evaluate(baseline_path, limit=5, db_path=db_path)

        self.assertTrue(report["ok"], report)
        self.assertEqual(report["passed"], report["total"])

    def test_stats_reports_chunk_counts(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            db_path = Path(tmp) / "rag.db"
            self.build_fixture_index(db_path)
            report = query.stats(db_path)

        self.assertIn("total_chunks", report)
        self.assertGreater(report["total_chunks"], 0)
        self.assertTrue(report["by_kind"])

    def test_build_creates_code_insights_table(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            db_path = Path(tmp) / "rag.duckdb"
            self.build_fixture_index(db_path)
            conn = duckdb.connect(str(db_path), read_only=True)
            count = conn.execute("SELECT count(*) FROM code_insights").fetchone()[0]
            conn.close()

        self.assertGreater(count, 0)

    def test_build_creates_symbol_edges_table(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            db_path = Path(tmp) / "rag.duckdb"
            self.build_fixture_index(db_path)
            conn = duckdb.connect(str(db_path), read_only=True)
            count = conn.execute("SELECT count(*) FROM symbol_edges").fetchone()[0]
            conn.close()

        self.assertGreater(count, 0)

    def test_insights_overview_returns_rows(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            db_path = Path(tmp) / "rag.duckdb"
            self.build_fixture_index(db_path)
            report = insights_tool.run_report("overview", limit=5, db_path=db_path)

        self.assertEqual(report["report"], "overview")
        self.assertTrue(report["rows"])
        self.assertIn("type", report["rows"][0])

    def test_insights_edge_summary_returns_rows(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            db_path = Path(tmp) / "rag.duckdb"
            self.build_fixture_index(db_path)
            report = insights_tool.run_report("edge-summary", limit=5, db_path=db_path)

        self.assertEqual(report["report"], "edge-summary")
        self.assertTrue(report["rows"])
        self.assertIn("edge_kind", report["rows"][0])

    def test_insights_api_example_coverage_report_executes(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            db_path = Path(tmp) / "rag.duckdb"
            self.build_fixture_index(db_path)
            report = insights_tool.run_report("api-example-coverage", limit=5, db_path=db_path)

        self.assertEqual(report["report"], "api-example-coverage")
        self.assertIn("rows", report)
        if report["rows"]:
            self.assertIn("module_name", report["rows"][0])
            self.assertIn("expected_example_file", report["rows"][0])

    def test_insights_dead_imports_report_executes(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            db_path = Path(tmp) / "rag.duckdb"
            self.build_fixture_index(db_path)
            report = insights_tool.run_report("dead-imports", limit=5, db_path=db_path)

        self.assertEqual(report["report"], "dead-imports")
        self.assertIn("rows", report)

    def test_insights_guidance_noise_returns_rows(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            db_path = Path(tmp) / "rag.duckdb"
            self.build_fixture_index(db_path)
            report = insights_tool.run_report("guidance-noise", limit=5, db_path=db_path)

        self.assertEqual(report["report"], "guidance-noise")
        self.assertTrue(report["rows"])

    def test_context_bundle_returns_deduplicated_chunks(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            db_path = Path(tmp) / "rag.db"
            self.build_fixture_index(db_path)
            report = context_tool.build_context_bundle(
                "create rag artifact workflow",
                profile="engine",
                limit=4,
                neighbors=1,
                content_chars=1200,
                db_path=db_path,
            )

        self.assertEqual(report["prompt"], "create rag artifact workflow")
        self.assertGreaterEqual(len(report["results"]), 1)
        ids = [item["id"] for item in report["results"]]
        self.assertEqual(len(ids), len(set(ids)))
        self.assertIn("governing_contracts", report)
        self.assertTrue(report["governing_contracts"])
        self.assertIn("related_chunks", report)
        self.assertIn("context_items", report)
        self.assertGreaterEqual(len(report["context_items"]), len(report["results"]))

    def test_context_bundle_can_pull_related_chunks_for_code_queries(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            db_path = Path(tmp) / "rag.duckdb"
            self.build_fixture_index(db_path)
            report = context_tool.build_context_bundle(
                "query.py duckdb search_index",
                profile="engine",
                limit=4,
                neighbors=1,
                content_chars=1200,
                db_path=db_path,
            )

        self.assertIn("related_chunks", report)
        self.assertTrue(report["related_chunks"])

    def test_context_bundle_can_pull_api_usage_chunks_from_examples(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            db_path = Path(tmp) / "rag.duckdb"
            self.build_fixture_index(db_path)
            report = context_tool.build_context_bundle(
                "lurek.window.getDimensions",
                profile="engine",
                limit=4,
                neighbors=1,
                content_chars=1200,
                db_path=db_path,
            )

        self.assertIn("api_usage_chunks", report)
        self.assertTrue(report["api_usage_chunks"])
        self.assertTrue(
            any(item["path"] == "content/examples/window.lua" for item in report["api_usage_chunks"])
        )

    def test_context_bundle_can_recommend_tool_candidates(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            db_path = Path(tmp) / "rag.duckdb"
            self.build_fixture_index(db_path)
            report = context_tool.build_context_bundle(
                "which mcp tool should I run for example coverage validation",
                profile="engine",
                limit=4,
                neighbors=1,
                content_chars=1200,
                db_path=db_path,
            )

        self.assertIn("tool_candidates", report)
        self.assertTrue(report["tool_candidates"])
        self.assertTrue(
            any(item["tool_name"] == "lua_example_coverage" for item in report["tool_candidates"])
        )

    def test_context_bundle_can_pull_navigation_chunks_for_skill_queries(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            db_path = Path(tmp) / "rag.duckdb"
            self.build_fixture_index(db_path)
            report = context_tool.build_context_bundle(
                "AGENTS skill workflow mcp tool",
                profile="engine",
                limit=4,
                neighbors=1,
                content_chars=1200,
                db_path=db_path,
            )

        self.assertIn("navigation_chunks", report)
        self.assertTrue(report["navigation_chunks"])

    def test_context_bundle_can_pull_module_usage_chunks_for_gameplay_queries(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            db_path = Path(tmp) / "rag.duckdb"
            self.build_fixture_index(db_path)
            report = context_tool.build_context_bundle(
                "window fullscreen title dpi example",
                profile="game",
                limit=4,
                neighbors=1,
                content_chars=1200,
                db_path=db_path,
            )

        self.assertEqual(report["intent"], "gameplay")
        self.assertIn("module_usage_chunks", report)
        self.assertTrue(report["module_usage_chunks"])
        self.assertTrue(
            any(item["path"] == "content/examples/window.lua" for item in report["module_usage_chunks"])
        )

    def test_or_fallback_keeps_results_for_loose_queries(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            db_path = Path(tmp) / "rag.db"
            self.build_fixture_index(db_path)
            report = query.search_index(
                "Codex AGENTS skills agents",
                profile="engine",
                limit=5,
                db_path_override=db_path,
            )

        self.assertIn(report["mode"], {"and", "and+or", "or"})
        self.assertTrue(report["results"])

    def test_workflow_queries_prefer_contract_or_skill_over_tests(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            db_path = Path(tmp) / "rag.db"
            self.build_fixture_index(db_path)
            report = query.search_index(
                "create rag artifact workflow",
                profile="engine",
                limit=3,
                db_path_override=db_path,
            )

        self.assertTrue(report["results"])
        top = report["results"][0]
        self.assertIn(top["source_kind"], {"contract", "skill"})

    def test_profile_filter_limits_engine_results(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            db_path = Path(tmp) / "rag.db"
            self.build_fixture_index(db_path)
            report = query.search_index(
                "create rag artifact workflow",
                profile="engine",
                limit=5,
                db_path_override=db_path,
            )

        self.assertTrue(report["results"])
        for item in report["results"]:
            self.assertTrue(
                item["path"].startswith(("AGENTS.md", ".codex/", "tools/", "tests/")),
                item["path"],
            )

    def test_rules_queries_prefer_contracts(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            db_path = Path(tmp) / "rag.duckdb"
            self.build_fixture_index(db_path)
            report = query.search_index(
                "AGENTS rules workflow",
                profile="engine",
                limit=3,
                db_path_override=db_path,
            )

        self.assertTrue(report["results"])
        top = report["results"][0]
        self.assertEqual(top["source_kind"], "contract")

    def test_search_context_highlights_matching_terms(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            db_path = Path(tmp) / "rag.duckdb"
            self.build_fixture_index(db_path)
            report = query.search_index(
                "create rag artifact workflow",
                profile="engine",
                limit=3,
                db_path_override=db_path,
            )

        self.assertTrue(report["results"])
        self.assertIn("[[", report["results"][0]["context"])

    def test_missing_chunk_returns_error(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            db_path = Path(tmp) / "rag.db"
            self.build_fixture_index(db_path)
            report = query.read_chunk("missing#0", db_path)

        self.assertIn("error", report)

    def test_hits_include_governing_contract_metadata(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            db_path = Path(tmp) / "rag.db"
            self.build_fixture_index(db_path)
            report = query.search_index(
                "query.py duckdb search_index",
                profile="engine",
                limit=5,
                db_path_override=db_path,
            )

        self.assertTrue(report["results"])
        query_hit = next((item for item in report["results"] if item["path"] == "tools/rag/query.py"), None)
        self.assertIsNotNone(query_hit)
        self.assertEqual(query_hit["governs_path"], "tools/rag/AGENTS.md")

    def test_search_missing_index_returns_error(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            db_path = Path(tmp) / "missing.db"
            report = query.search_index(
                "RAG build index",
                profile="engine",
                limit=5,
                db_path_override=db_path,
            )

        self.assertIn("error", report)

    def test_unicode_tokenization_preserves_polish_and_expands_aliases(self) -> None:
        tokens = query.sanitize_fts_query("dźwięk przykład lurek.audio.playMusic")

        self.assertIn("dźwięk", tokens)
        self.assertIn("dzwiek", tokens)
        self.assertIn("audio", tokens)
        self.assertIn("example", tokens)
        self.assertIn("lurek.audio.playmusic", tokens)

    def test_search_repairs_an_unambiguous_near_miss_only_after_and_miss(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            db_path = Path(tmp) / "rag.db"
            self.build_fixture_index(db_path)
            report = query.search_index("widnow fullscreen", profile="game", limit=5, db_path_override=db_path)

        self.assertIn("widnow", report["query_expansions"]["near_miss"])
        self.assertEqual(report["query_expansions"]["near_miss"]["widnow"], "window")
        self.assertTrue(any(item["path"] == "content/examples/window.lua" for item in report["results"]))

    def test_context_limit_25_never_hides_a_search_error(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            db_path = Path(tmp) / "rag.db"
            self.build_fixture_index(db_path)
            report = context_tool.build_context_bundle(
                "RAG build index", profile="engine", limit=25, content_chars=1200, db_path=db_path
            )

        self.assertNotIn("error", report)
        self.assertTrue(report["searches"])
        self.assertTrue(all(not item.get("error") for item in report["searches"]))

    def test_build_rejects_target_traversal_before_writing(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            with self.assertRaises(ValueError):
                build_index.build_index(["../outside"], Path(tmp) / "rag.db")

    def test_snapshot_publish_keeps_previous_generation_available(self) -> None:
        import state

        with tempfile.TemporaryDirectory() as tmp:
            rag_dir = Path(tmp)
            with patch.object(state, "RAG_DIR", rag_dir), \
                 patch.object(state, "MANIFEST_PATH", rag_dir / "rag_index.manifest.json"), \
                 patch.object(state, "LEGACY_DB_PATH", rag_dir / "rag_index.duckdb"):
                first = build_index.build_index(["AGENTS.md"])
                first_manifest = json.loads((rag_dir / "rag_index.manifest.json").read_text(encoding="utf-8"))
                first_snapshot = rag_dir / first_manifest["active"]
                second = build_index.build_index(["AGENTS.md"])

                self.assertEqual(first["index_state"], "published")
                self.assertEqual(second["index_state"], "published")
                self.assertTrue(first_snapshot.exists())
                self.assertNotEqual(first["generation"], second["generation"])


if __name__ == "__main__":
    unittest.main()
