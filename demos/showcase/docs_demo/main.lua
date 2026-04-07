-- examples/docs_demo/main.lua
-- Demonstrates the luna.docs.* documentation management API

-- luna.docs is not yet implemented in this build
if not luna.docs then
    function luna.load()
        luna.render.setBackgroundColor(0.05, 0.05, 0.1)
    end
    function luna.draw()
        luna.render.setColor(1, 0.6, 0.2)
        luna.render.print("Docs API Demo", 20, 20)
        luna.render.setColor(0.7, 0.7, 0.7)
        luna.render.print("luna.docs is not available in this build.", 20, 60)
        luna.render.print("(API not yet implemented)", 20, 85)
    end
    return
end

function luna.load()
    -- Scan the entire luna namespace
    catalog = luna.docs.scan()
    modules = catalog:getModules()

    -- Compute coverage
    documented, total = luna.docs.coverage(catalog)

    -- Describe a few entries for quality demo
    luna.docs.resetCatalog()
    luna.docs.describe("luna.render.circle", "Draw a circle on screen")
    luna.docs.setParamInfo("luna.render.circle", {
        { name = "mode", type = "string", description = "Draw mode: 'fill' or 'line'" },
        { name = "x", type = "number", description = "Center X position" },
        { name = "y", type = "number", description = "Center Y position" },
        { name = "radius", type = "number", description = "Circle radius" },
    })
    luna.docs.setReturnInfo("luna.render.circle", {
        { type = "nil", description = "No return value" },
    })
    internalCat = luna.docs.getCatalog()
    qualityReport = luna.docs.quality(internalCat)

    -- Validate against live bindings
    validationReport = luna.docs.validate()

    -- Search for a function
    searchResults = catalog:search("circle")
end

function luna.draw()
    luna.render.setColor(1, 1, 1)
    luna.render.print("=== luna.docs Demo ===", 20, 20)

    local y = 60

    -- Module list
    luna.render.print("Discovered modules:", 20, y)
    y = y + 25
    local moduleList = table.concat(modules, ", ")
    luna.render.print("  " .. moduleList, 20, y)
    y = y + 40

    -- Entry count
    luna.render.print("Total API entries found: " .. catalog:entryCount(), 20, y)
    y = y + 25

    -- Coverage
    luna.render.print(string.format("Coverage: %d / %d (%.1f%%)", documented, total, (documented / math.max(total, 1)) * 100), 20, y)
    y = y + 40

    -- Quality report
    luna.render.setColor(0.5, 1, 0.5)
    luna.render.print("Quality Report (internal catalog):", 20, y)
    y = y + 25
    luna.render.setColor(1, 1, 1)
    luna.render.print(string.format("  Overall: %s (%.0f%%)", qualityReport:getGrade(), qualityReport:getOverallScore() * 100), 20, y)
    y = y + 40

    -- Validation summary
    luna.render.setColor(1, 0.5, 0.5)
    luna.render.print("Validation Report:", 20, y)
    y = y + 25
    luna.render.setColor(1, 1, 1)
    luna.render.print("  " .. validationReport:getSummary(), 20, y)
    y = y + 40

    -- Search results
    luna.render.setColor(0.5, 0.8, 1)
    luna.render.print("Search for 'circle':", 20, y)
    y = y + 25
    luna.render.setColor(1, 1, 1)
    for i = 1, math.min(#searchResults, 5) do
        luna.render.print("  " .. searchResults[i]:getQualifiedName(), 20, y)
        y = y + 20
    end
    y = y + 20

    luna.render.setColor(0.7, 0.7, 0.7)
    luna.render.print("Press ESC to exit", 20, y)
end

function luna.keypressed(key)
    if key == "escape" then
        luna.signal.quit()
    end
end
