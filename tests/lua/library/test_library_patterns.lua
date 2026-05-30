--- BDD tests for library.patterns

require("tests/lua/init")

-- @describe library: patterns
describe("library: patterns", function()
	-- @library lurek.library_patterns
	it("bootstraps library test environment", function()
		expect_type("table", lurek)
	end)
end)
test_summary()
