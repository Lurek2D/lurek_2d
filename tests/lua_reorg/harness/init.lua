-- Compatibility shim for Lua unit tests that require("tests.lua_reorg.harness").
-- The runtime test runner is implemented in Rust; this file exposes the legacy
-- assertion aliases and keeps the Lua-side require path resolvable.

require("tests/lua_reorg/init")

local harness = {}

harness.describe = describe
harness.it = it
harness.pending = pending
harness.test_summary = test_summary

harness.assert_equal = expect_equal
harness.assert_near = expect_near
harness.assert_true = expect_true
harness.assert_false = expect_false
harness.assert_nil = expect_nil
harness.assert_not_nil = expect_not_nil
harness.assert_error = expect_error
harness.assert_no_error = expect_no_error

_G.assert_equal = expect_equal
_G.assert_near = expect_near
_G.assert_true = expect_true
_G.assert_false = expect_false
_G.assert_nil = expect_nil
_G.assert_not_nil = expect_not_nil
_G.assert_error = expect_error
_G.assert_no_error = expect_no_error

_G.ASSERT_EQUAL = expect_equal
_G.ASSERT_NEAR = expect_near
_G.ASSERT_TRUE = expect_true
_G.ASSERT_FALSE = expect_false
_G.ASSERT_NIL = expect_nil
_G.ASSERT_NOT_NIL = expect_not_nil
_G.ASSERT_ERROR = expect_error
_G.ASSERT_NO_ERROR = expect_no_error

_G.IT = it
_G.EXPECT_EQUAL = expect_equal
_G.EXPECT_NEAR = expect_near
_G.EXPECT_TRUE = expect_true
_G.EXPECT_FALSE = expect_false
_G.EXPECT_NIL = expect_nil
_G.EXPECT_NOT_NIL = expect_not_nil
_G.EXPECT_ERROR = expect_error
_G.EXPECT_NO_ERROR = expect_no_error

return harness
