import unittest
import subprocess
import json
import tempfile
import os
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent.parent

class TestRAGSystem(unittest.TestCase):
    
    @classmethod
    def setUpClass(cls):
        # Create a temporary DB file for tests
        cls.temp_dir = tempfile.TemporaryDirectory()
        cls.db_path = Path(cls.temp_dir.name) / "test_rag.db"
        
        # Build the index before running tests (only indexing content and docs)
        print("Building RAG index for tests...")
        subprocess.run(
            ["python", "tools/rag/build_index.py", "content", "docs", "--db", str(cls.db_path)], 
            cwd=WORKSPACE_ROOT,
            check=True
        )

    @classmethod
    def tearDownClass(cls):
        cls.temp_dir.cleanup()

    def run_query(self, query, profile="all"):
        result = subprocess.run(
            ["python", "tools/rag/query.py", query, "--profile", profile, "--db", str(self.db_path)],
            cwd=WORKSPACE_ROOT,
            capture_output=True,
            text=True,
            check=True
        )
        return json.loads(result.stdout)

    def test_api_extraction(self):
        """Test if exact API definitions from lua_api_data.json are prioritized."""
        res = self.run_query("lurek.render.rectangle")
        self.assertIn("results", res)
        self.assertTrue(len(res["results"]) > 0, "No results returned for API query")
        
        found_api = any(r["type"] == "api" and "API:" in r["title"] for r in res["results"])
        self.assertTrue(found_api, "Did not find structured API entry in top results")

    def test_game_profile_filtering(self):
        """Test if the game profile successfully filters out src/ and tests/."""
        res = self.run_query("render", profile="game")
        for r in res["results"]:
            path = r["path"]
            self.assertTrue(
                path == "API" or path.startswith("content/") or path.startswith("docs/") or path.startswith("library/"),
                f"Game profile returned out-of-scope path: {path}"
            )

    def test_engine_profile_filtering(self):
        """Test if the engine profile successfully filters out content/ and docs/."""
        # Index src and tests into the test DB
        subprocess.run(
            ["python", "tools/rag/build_index.py", "tests", "src", "--db", str(self.db_path)], 
            cwd=WORKSPACE_ROOT, 
            check=True
        )
        
        res = self.run_query("render", profile="engine")
        for r in res["results"]:
            path = r["path"]
            self.assertTrue(
                path.startswith("src/") or path.startswith("tests/") or path.startswith(".github/") or path.startswith("tools/"),
                f"Engine profile returned out-of-scope path: {path}"
            )

    def test_single_file_update(self):
        """Test that updating a single file does not corrupt the index or duplicate chunks."""
        # Update a single file (e.g. content/examples/render.lua)
        target_file = "content/examples/render.lua"
        
        # Get count of chunks for this file before
        conn = __import__('sqlite3').connect(self.db_path)
        before_count = conn.execute("SELECT count(*) FROM documents WHERE path = ?", (target_file,)).fetchone()[0]
        
        # Run auto-index
        subprocess.run(
            ["python", "tools/rag/build_index.py", target_file, "--db", str(self.db_path)], 
            cwd=WORKSPACE_ROOT, 
            check=True
        )
        
        # Get count after
        after_count = conn.execute("SELECT count(*) FROM documents WHERE path = ?", (target_file,)).fetchone()[0]
        conn.close()
        
        self.assertTrue(after_count > 0, "Single file update resulted in 0 chunks")
        self.assertEqual(before_count, after_count, "Single file update duplicated or lost chunks")

    def test_missing_index_handling(self):
        """Test that query gracefully handles a missing index."""
        bad_db = Path(self.temp_dir.name) / "does_not_exist.db"
        result = subprocess.run(
            ["python", "tools/rag/query.py", "test", "--db", str(bad_db)],
            cwd=WORKSPACE_ROOT,
            capture_output=True,
            text=True,
            check=True
        )
        res = json.loads(result.stdout)
        self.assertIn("error", res)

if __name__ == "__main__":
    unittest.main()
