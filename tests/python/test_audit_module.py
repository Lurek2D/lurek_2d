"""Self-tests for audit_module source-line heuristics."""

from __future__ import annotations

import importlib.util
import sys
import unittest
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]


def _load(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    mod = importlib.util.module_from_spec(spec)
    sys.modules[name] = mod
    spec.loader.exec_module(mod)
    return mod


audit_module = _load(
    "test_audit_module_impl",
    REPO / "tools" / "audit" / "audit_module.py",
)


class AuditModuleUnsafeDetectionTests(unittest.TestCase):
    def test_detects_real_unsafe_block(self) -> None:
        self.assertTrue(audit_module._contains_unsafe_construct("let result = unsafe {"))

    def test_ignores_identifier_containing_unsafe(self) -> None:
        self.assertFalse(
            audit_module._contains_unsafe_construct(
                "other if allow_unsafe_passthrough_options => {"
            )
        )

    def test_ignores_pascal_case_variant_name(self) -> None:
        self.assertFalse(
            audit_module._contains_unsafe_construct(
                "Self::UnsafeResourcePath { path, reason } => {"
            )
        )
