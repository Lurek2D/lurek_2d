"""Tests for tool-side Lua binding snapshot extraction and validation."""

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


class LuaBindingToolTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.tool = _load(
            "gen_lua_binding_reports_test",
            REPO / "tools" / "docs" / "gen_lua_binding_reports.py",
        )
        cls.code_snapshot = cls.tool.extract_binding_snapshot_from_code()
        cls.doc_snapshot = cls.tool.extract_binding_snapshot_from_docstrings()

    def test_code_snapshot_extracts_selected_entries_from_source_files(self) -> None:
        graph = self.code_snapshot.get_entry("lurek.graph.newGraph")
        self.assertIsNotNone(graph)
        self.assertEqual(graph.returns[0].lua_type, "LGraph")

        minimap = self.code_snapshot.get_entry("lurek.minimap.newMinimap")
        self.assertIsNotNone(minimap)
        self.assertEqual(len(minimap.parameters), 4)
        self.assertEqual(minimap.parameters[0].lua_type, "integer")
        self.assertTrue(minimap.parameters[2].optional)
        self.assertEqual(minimap.returns[0].lua_type, "LMinimap")

        nav_grid = self.code_snapshot.get_entry("lurek.pathfind.newNavGrid")
        self.assertIsNotNone(nav_grid)
        self.assertEqual(len(nav_grid.parameters), 2)
        self.assertEqual(nav_grid.parameters[0].lua_type, "integer")
        self.assertEqual(nav_grid.returns[0].lua_type, "LNavGrid")

        tween = self.code_snapshot.get_entry("lurek.tween.tween")
        self.assertIsNotNone(tween)
        self.assertEqual(len(tween.parameters), 4)
        self.assertEqual(tween.parameters[0].name, "duration")
        self.assertTrue(tween.parameters[3].optional)
        self.assertEqual(tween.returns[0].lua_type, "LTween")

        cancel = self.code_snapshot.get_entry("LTween:cancel")
        self.assertIsNotNone(cancel)
        self.assertEqual(cancel.parameters, [])
        self.assertEqual(cancel.returns[0].lua_type, "nil")

    def test_render_registration_children_merge_into_the_render_namespace(self) -> None:
        parser = _load("gen_lua_api_parser_test", REPO / "tools" / "docs" / "gen_lua_api.py")

        self.assertEqual(
            parser._determine_module_name(Path("render_resources_api.rs")), "render"
        )
        self.assertEqual(
            parser._determine_module_name(Path("render_primitives_api.rs")), "render"
        )
        self.assertEqual(parser._determine_module_name(Path("sprite_api.rs")), "sprite")

    def test_doc_snapshot_reads_selected_entries_from_source_files(self) -> None:
        graph = self.doc_snapshot.get_entry("lurek.graph.newGraph")
        self.assertIsNotNone(graph)
        self.assertIn("Creates an empty logistics graph", graph.summary)
        self.assertEqual(graph.returns[0].lua_type, "LGraph")

        minimap = self.doc_snapshot.get_entry("lurek.minimap.newMinimap")
        self.assertIsNotNone(minimap)
        self.assertEqual(minimap.parameters[0].name, "grid_w")
        self.assertEqual(minimap.parameters[0].lua_type, "integer")
        self.assertEqual(minimap.parameters[2].name, "display_w")
        self.assertEqual(minimap.returns[0].lua_type, "LMinimap")

        nav_grid = self.doc_snapshot.get_entry("lurek.pathfind.newNavGrid")
        self.assertIsNotNone(nav_grid)
        self.assertEqual(nav_grid.parameters[0].name, "width")
        self.assertEqual(nav_grid.returns[0].lua_type, "LNavGrid")

        tween = self.doc_snapshot.get_entry("lurek.tween.tween")
        self.assertIsNotNone(tween)
        self.assertEqual(tween.parameters[0].name, "duration")
        self.assertEqual(tween.parameters[3].lua_type, "string")
        self.assertTrue(tween.parameters[3].optional)

        cancel = self.doc_snapshot.get_entry("LTween:cancel")
        self.assertIsNotNone(cancel)
        self.assertEqual(cancel.parameters, [])

    def test_validation_reports_drift_categories(self) -> None:
        expected = self.tool.BindingSnapshot(
            source="code",
            source_dir="src/lua_api",
            entries=[
                self.tool.BindingEntry(
                    module="example",
                    namespace="lurek.example",
                    name="orderCase",
                    qualified_name="lurek.example.orderCase",
                    kind="function",
                    call_style=".",
                    owner="",
                    parameters=[
                        self.tool.BindingParam("x", "integer", "u32", False, False, True),
                        self.tool.BindingParam("y", "string", "String", True, False, True),
                    ],
                    returns=[self.tool.BindingReturn("LThing", "LuaThing", False, True)],
                    source_file="src/lua_api/example_api.rs",
                    line=1,
                ),
                self.tool.BindingEntry(
                    module="example",
                    namespace="lurek.example",
                    name="missingDoc",
                    qualified_name="lurek.example.missingDoc",
                    kind="function",
                    call_style=".",
                    owner="",
                    source_file="src/lua_api/example_api.rs",
                    line=2,
                ),
                self.tool.BindingEntry(
                    module="example",
                    namespace="lurek.example",
                    name="uncertainArgs",
                    qualified_name="lurek.example.uncertainArgs",
                    kind="function",
                    call_style=".",
                    owner="",
                    parameters=[
                        self.tool.BindingParam(
                            "...",
                            "any",
                            "LuaMultiValue",
                            False,
                            True,
                            True,
                            confidence=self.tool.CONFIDENCE_HEURISTIC,
                            diagnostics=[
                                self.tool.BindingDiagnostic(
                                    code="VARIADIC_LUA_MULTI_VALUE",
                                    classification=self.tool.CLASSIFICATION_EXTRACTION_UNCERTAIN,
                                    message="LuaMultiValue variadic arguments are extracted heuristically.",
                                    evidence="LuaMultiValue",
                                )
                            ],
                        )
                    ],
                    source_signature="|_, args: LuaMultiValue|",
                    source_file="src/lua_api/example_api.rs",
                    line=4,
                    confidence=self.tool.CONFIDENCE_HEURISTIC,
                ),
            ],
        )

        actual = self.tool.BindingSnapshot(
            source="docstrings",
            source_dir="src/lua_api",
            entries=[
                self.tool.BindingEntry(
                    module="example",
                    namespace="lurek.example",
                    name="orderCase",
                    qualified_name="lurek.example.orderCase",
                    kind="function",
                    call_style=".",
                    owner="",
                    parameters=[
                        self.tool.BindingParam("y", "integer", "integer", False, False, True),
                        self.tool.BindingParam("x", "number", "number", False, False, True),
                    ],
                    returns=[self.tool.BindingReturn("table", "table", True, True)],
                    source_file="src/lua_api/example_api.rs",
                    line=1,
                ),
                self.tool.BindingEntry(
                    module="example",
                    namespace="lurek.example",
                    name="phantomDoc",
                    qualified_name="lurek.example.phantomDoc",
                    kind="function",
                    call_style=".",
                    owner="",
                    source_file="src/lua_api/example_api.rs",
                    line=3,
                ),
                self.tool.BindingEntry(
                    module="example",
                    namespace="lurek.example",
                    name="uncertainArgs",
                    qualified_name="lurek.example.uncertainArgs",
                    kind="function",
                    call_style=".",
                    owner="",
                    parameters=[
                        self.tool.BindingParam("first", "string", "string", False, False, True),
                        self.tool.BindingParam("second", "integer", "integer", False, False, True),
                    ],
                    source_file="src/lua_api/example_api.rs",
                    line=4,
                ),
            ],
        )

        report = self.tool.validate_binding_snapshots(expected, actual)
        self.assertEqual(report.missing_doc_entries, ["lurek.example.missingDoc"])
        self.assertEqual(report.phantom_doc_entries, ["lurek.example.phantomDoc"])
        self.assertTrue(report.parameter_order_mismatches)
        self.assertTrue(report.parameter_name_mismatches)
        self.assertTrue(report.parameter_type_mismatches)
        self.assertTrue(report.parameter_optionality_mismatches)
        self.assertTrue(report.return_type_mismatches)
        self.assertTrue(report.return_optionality_mismatches)
        self.assertTrue(report.has_blocking_issues())

        # Some orderCase issues are CONFIRMED_DOC_BUG (type/optionality/return mismatches).
        # Parameter name mismatches are now EXTRACTION_UNCERTAIN per Rule 1.
        confirmed = [
            issue
            for issue in report.issues
            if issue.qualified_name == "lurek.example.orderCase"
            and issue.classification == self.tool.CLASSIFICATION_CONFIRMED_DOC_BUG
        ]
        self.assertTrue(confirmed)

        # Name mismatch issues for orderCase must be EXTRACTION_UNCERTAIN (Rule 1).
        name_mismatches = [
            issue
            for issue in report.issues
            if issue.qualified_name == "lurek.example.orderCase"
            and issue.kind == "parameter_name_mismatch"
        ]
        self.assertTrue(name_mismatches)
        self.assertTrue(
            all(
                issue.classification == self.tool.CLASSIFICATION_EXTRACTION_UNCERTAIN
                for issue in name_mismatches
            )
        )

        uncertain = [
            issue
            for issue in report.issues
            if issue.qualified_name == "lurek.example.uncertainArgs"
        ]
        self.assertTrue(uncertain)
        self.assertTrue(
            all(
                issue.classification == self.tool.CLASSIFICATION_EXTRACTION_UNCERTAIN
                for issue in uncertain
            )
        )
        self.assertTrue(all(not issue.blocking for issue in uncertain))
        self.assertGreater(report.summary.confirmed_doc_bug_count, 0)
        self.assertGreater(report.summary.extraction_uncertain_count, 0)
        self.assertEqual(report.summary.unsupported_pattern_count, 0)

    def test_validation_treats_lua_method_normalization_as_uncertain(self) -> None:
        expected = self.tool.BindingSnapshot(
            source="code",
            source_dir="src/lua_api",
            entries=[
                self.tool.BindingEntry(
                    module="ui",
                    namespace="LButton",
                    name="getText",
                    qualified_name="LButton:getText",
                    kind="method",
                    call_style=":",
                    owner="LButton",
                    parameters=[
                        self.tool.BindingParam("self", "any", "LuaValue", False, False, True),
                    ],
                    source_file="src/lua_api/ui_api.rs",
                    line=10,
                ),
                self.tool.BindingEntry(
                    module="mapblock",
                    namespace="LMapBlockGenerator",
                    name="setGrid",
                    qualified_name="LMapBlockGenerator:setGrid",
                    kind="method",
                    call_style=":",
                    owner="LMapBlockGenerator",
                    parameters=[
                        self.tool.BindingParam("grid", "userdata", "LuaAnyUserData", False, False, True),
                    ],
                    source_file="src/lua_api/mapblock_api.rs",
                    line=20,
                ),
                self.tool.BindingEntry(
                    module="learning",
                    namespace="LFrameStack",
                    name="push",
                    qualified_name="LFrameStack:push",
                    kind="method",
                    call_style=":",
                    owner="LFrameStack",
                    parameters=[
                        self.tool.BindingParam("frame", "table", "LuaTable", False, False, True),
                    ],
                    source_file="src/lua_api/learning_api.rs",
                    line=30,
                ),
                self.tool.BindingEntry(
                    module="dsp",
                    namespace="lurek.dsp",
                    name="analyzeFft",
                    qualified_name="lurek.dsp.analyzeFft",
                    kind="function",
                    call_style=".",
                    owner="",
                    returns=[
                        self.tool.BindingReturn("LResult<LuaTable<'lua>> {", "LuaResult<LuaTable>", False, True),
                    ],
                    source_file="src/lua_api/dsp_api.rs",
                    line=40,
                ),
                self.tool.BindingEntry(
                    module="serialize",
                    namespace="lurek.serialize",
                    name="encodeMsgPack",
                    qualified_name="lurek.serialize.encodeMsgPack",
                    kind="function",
                    call_style=".",
                    owner="",
                    parameters=[],
                    source_signature="fn encode_msgpack_value<'lua>(lua: &'lua Lua, value: LuaValue<'lua>) -> LuaResult<LuaString<'lua>> {",
                    source_file="src/lua_api/serialize_api.rs",
                    line=50,
                ),
                self.tool.BindingEntry(
                    module="raycaster",
                    namespace="LSpriteManager",
                    name="addDirectional",
                    qualified_name="LSpriteManager:addDirectional",
                    kind="method",
                    call_style=":",
                    owner="LSpriteManager",
                    parameters=[
                        self.tool.BindingParam(
                            "(x, y, front)",
                            "LDirectionalSpriteArgs<'_>",
                            "LuaDirectionalSpriteArgs<'_>",
                            False,
                            False,
                            True,
                        ),
                    ],
                    source_file="src/lua_api/raycaster_api.rs",
                    line=60,
                ),
            ],
        )
        actual = self.tool.BindingSnapshot(
            source="docstrings",
            source_dir="src/lua_api",
            entries=[
                self.tool.BindingEntry(
                    module="ui",
                    namespace="LButton",
                    name="getText",
                    qualified_name="LButton:getText",
                    kind="method",
                    call_style=":",
                    owner="LButton",
                    parameters=[],
                    source_file="src/lua_api/ui_api.rs",
                    line=10,
                ),
                self.tool.BindingEntry(
                    module="mapblock",
                    namespace="LMapBlockGenerator",
                    name="setGrid",
                    qualified_name="LMapBlockGenerator:setGrid",
                    kind="method",
                    call_style=":",
                    owner="LMapBlockGenerator",
                    parameters=[
                        self.tool.BindingParam("grid", "PlacementGrid", "PlacementGrid", False, False, True),
                    ],
                    source_file="src/lua_api/mapblock_api.rs",
                    line=20,
                ),
                self.tool.BindingEntry(
                    module="learning",
                    namespace="LFrameStack",
                    name="push",
                    qualified_name="LFrameStack:push",
                    kind="method",
                    call_style=":",
                    owner="LFrameStack",
                    parameters=[
                        self.tool.BindingParam("frame", "number[]", "number[]", False, False, True),
                    ],
                    source_file="src/lua_api/learning_api.rs",
                    line=30,
                ),
                self.tool.BindingEntry(
                    module="dsp",
                    namespace="lurek.dsp",
                    name="analyzeFft",
                    qualified_name="lurek.dsp.analyzeFft",
                    kind="function",
                    call_style=".",
                    owner="",
                    returns=[
                        self.tool.BindingReturn("table", "table", False, True),
                    ],
                    source_file="src/lua_api/dsp_api.rs",
                    line=40,
                ),
                self.tool.BindingEntry(
                    module="serialize",
                    namespace="lurek.serialize",
                    name="encodeMsgPack",
                    qualified_name="lurek.serialize.encodeMsgPack",
                    kind="function",
                    call_style=".",
                    owner="",
                    parameters=[
                        self.tool.BindingParam("value", "table", "table", False, False, True),
                    ],
                    source_file="src/lua_api/serialize_api.rs",
                    line=50,
                ),
                self.tool.BindingEntry(
                    module="raycaster",
                    namespace="LSpriteManager",
                    name="addDirectional",
                    qualified_name="LSpriteManager:addDirectional",
                    kind="method",
                    call_style=":",
                    owner="LSpriteManager",
                    parameters=[
                        self.tool.BindingParam("x", "number", "number", False, False, True),
                        self.tool.BindingParam("y", "number", "number", False, False, True),
                        self.tool.BindingParam("front", "any", "any", False, False, True),
                    ],
                    source_file="src/lua_api/raycaster_api.rs",
                    line=60,
                ),
            ],
        )

        report = self.tool.validate_binding_snapshots(expected, actual)
        self.assertFalse(report.has_blocking_issues())
        self.assertEqual(report.summary.confirmed_doc_bug_count, 0)
        self.assertGreaterEqual(report.summary.extraction_uncertain_count, 6)


if __name__ == "__main__":
    unittest.main()
