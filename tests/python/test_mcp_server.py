"""Protocol and safety regression tests for the Python MCP stdio server."""

from __future__ import annotations

import importlib.util
import sys
import unittest
from pathlib import Path


REPO = Path(__file__).resolve().parents[2]


def load_server():
    spec = importlib.util.spec_from_file_location("lurek_mcp_server_test", REPO / "tools" / "mcp" / "lurek_mcp_server.py")
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


class McpServerTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.server = load_server()

    def test_initialize_negotiates_supported_version(self) -> None:
        response = self.server._handle_request({
            "jsonrpc": "2.0", "id": 1, "method": "initialize",
            "params": {"protocolVersion": "2024-11-05", "capabilities": {}, "clientInfo": {}},
        })
        self.assertEqual("2024-11-05", response["result"]["protocolVersion"])

    def test_initialize_rejects_unsupported_version(self) -> None:
        response = self.server._handle_request({
            "jsonrpc": "2.0", "id": 1, "method": "initialize",
            "params": {"protocolVersion": "1999-01-01"},
        })
        self.assertEqual(-32602, response["error"]["code"])

    def test_tool_schema_rejects_unknown_argument(self) -> None:
        response = self.server._handle_request({
            "jsonrpc": "2.0", "id": 2, "method": "tools/call",
            "params": {"name": "rag_search", "arguments": {"query": "api", "unexpected": True}},
        })
        self.assertEqual(-32602, response["error"]["code"])

    def test_rebuild_paths_cannot_escape_repository(self) -> None:
        with self.assertRaises(ValueError):
            self.server._normalize_rag_targets({"targets": ["../outside"]})

    def test_cag_baseline_write_is_explicit_and_annotated(self) -> None:
        self.assertNotIn("write_baseline", self.server.TOOLS["cag_validate"].input_schema["properties"])
        annotations = self.server.TOOLS["cag_write_baseline"].annotations or {}
        self.assertTrue(annotations["destructiveHint"])


if __name__ == "__main__":
    unittest.main()
