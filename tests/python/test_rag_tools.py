"""Self-tests for the local RAG index, reading, and recall evaluation tools."""

from __future__ import annotations

import importlib.util
import json
import sys
import tempfile
import unittest
from pathlib import Path


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


class RagToolTests(unittest.TestCase):
    def build_fixture_index(self, db_path: Path) -> None:
        build_index.build_index(
            [
                "AGENTS.md",
                ".codex/skills/create-rag-artifact/SKILL.md",
                "tools/rag/AGENTS.md",
                "tools/rag/query.py",
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
                item["path"].startswith(("AGENTS.md", ".codex/", ".github/", "tools/", "tests/")),
                item["path"],
            )

    def test_missing_chunk_returns_error(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            db_path = Path(tmp) / "rag.db"
            self.build_fixture_index(db_path)
            report = query.read_chunk("missing#0", db_path)

        self.assertIn("error", report)

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


if __name__ == "__main__":
    unittest.main()
