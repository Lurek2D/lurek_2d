"""Regression tests for the UI documentation contract audit."""
from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location("ui_docs_contract", ROOT / "tools/audit/ui_docs_contract.py")
assert SPEC and SPEC.loader
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class UiDocsContractTests(unittest.TestCase):
    def test_current_ui_contract_is_source_backed(self) -> None:
        self.assertEqual([], MODULE.failures())


if __name__ == "__main__":
    unittest.main()
