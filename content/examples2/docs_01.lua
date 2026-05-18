--- Docs Module Part 2: LApiCatalog, LValidationReport, LQualityReport

--@api-stub: LApiCatalog:getModules
-- Returns the list of module names in this catalog.
do
    local cat = lurek.docs.scan()
    local modules = cat:getModules()
    print("modules = " .. #modules)
end

--@api-stub: LApiCatalog:getEntries
-- Returns all doc entries, optionally filtered by module.
do
    local cat = lurek.docs.scan()
    local all = cat:getEntries()
    local math_entries = cat:getEntries("math")
    print("all=" .. #all .. " math=" .. #math_entries)
end

--@api-stub: LApiCatalog:getEntry
-- Returns a specific entry by qualified name, or nil.
do
    local cat = lurek.docs.scan()
    local entry = cat:getEntry("lurek.math.lerp")
    if entry then
        print("found entry")
    end
end

--@api-stub: LApiCatalog:getTypes
-- Returns the user-defined type names in a module.
do
    local cat = lurek.docs.scan()
    local types = cat:getTypes("math")
    print("math types = " .. #types)
end

--@api-stub: LApiCatalog:getTypeMethods
-- Returns the doc entries for a type's methods.
do
    local cat = lurek.docs.scan()
    local methods = cat:getTypeMethods("LVec2")
    print("LVec2 methods = " .. #methods)
end

--@api-stub: LApiCatalog:entryCount
-- Returns the total or per-module entry count.
do
    local cat = lurek.docs.scan()
    local total = cat:entryCount()
    local math_count = cat:entryCount("math")
    print("total=" .. total .. " math=" .. math_count)
end

--@api-stub: LApiCatalog:merge
-- Merges another catalog into this one, returning a combined catalog.
do
    local a = lurek.docs.scanModule("math")
    local b = lurek.docs.scanModule("timer")
    local merged = a:merge(b)
    print("merged = " .. merged:entryCount())
end

--@api-stub: LApiCatalog:filter
-- Returns a new catalog containing entries where predicate is truthy.
do
    local cat = lurek.docs.scan()
    local fns = cat:filter(function(entry)
        return entry:getKind() == "function"
    end)
    print("functions = " .. fns:entryCount())
end

--@api-stub: LApiCatalog:search
-- Fuzzy-searches entries by name and returns matches.
do
    local cat = lurek.docs.scan()
    local results = cat:search("lerp")
    print("search results = " .. #results)
end

--@api-stub: LApiCatalog:toTable
-- Converts the catalog to a plain Lua array of row tables.
do
    local cat = lurek.docs.scanModule("math")
    local rows = cat:toTable()
    if #rows > 0 then
        print("first row name = " .. rows[1].name)
    end
end

--@api-stub: LApiCatalog:toJSON
-- Serializes the catalog to a JSON string.
do
    local cat = lurek.docs.scanModule("timer")
    local json = cat:toJSON()
    print("json length = " .. #json)
end

--@api-stub: LApiCatalog:type
-- Returns the type name ("LApiCatalog").
do
    local cat = lurek.docs.scan()
    print("type = " .. cat:type())
end

--@api-stub: LApiCatalog:typeOf
-- Returns whether this handle matches a type name.
do
    local cat = lurek.docs.scan()
    print("is LApiCatalog = " .. tostring(cat:typeOf("LApiCatalog")))
end

--@api-stub: LValidationReport:isValid
-- Returns true when there are no missing or phantom entries.
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    print("valid = " .. tostring(report:isValid()))
end

--@api-stub: LValidationReport:getMissing
-- Returns names that are live but not documented.
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    local missing = report:getMissing()
    print("missing = " .. #missing)
end

--@api-stub: LValidationReport:getPhantom
-- Returns names documented but not live.
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    local phantom = report:getPhantom()
    print("phantom = " .. #phantom)
end

--@api-stub: LValidationReport:getIncomplete
-- Returns names with incomplete documentation.
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    local incomplete = report:getIncomplete()
    print("incomplete = " .. #incomplete)
end

--@api-stub: LValidationReport:missingCount
-- Returns the count of missing entries.
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    print("missing count = " .. report:missingCount())
end

--@api-stub: LValidationReport:phantomCount
-- Returns the count of phantom entries.
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    print("phantom count = " .. report:phantomCount())
end

--@api-stub: LValidationReport:incompleteCount
-- Returns the count of incomplete entries.
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    print("incomplete count = " .. report:incompleteCount())
end

--@api-stub: LValidationReport:getSummary
-- Returns a human-readable summary string.
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    print("summary = " .. report:getSummary())
end

--@api-stub: LValidationReport:toTable
-- Converts the report to a plain Lua table.
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    local t = report:toTable()
    print("table keys: missing=" .. #t.missing .. " phantom=" .. #t.phantom)
end

--@api-stub: LValidationReport:toJSON
-- Serializes the report to a JSON string.
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    local json = report:toJSON()
    print("json length = " .. #json)
end

--@api-stub: LValidationReport:type
-- Returns the type name ("LValidationReport").
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    print("type = " .. report:type())
end

--@api-stub: LValidationReport:typeOf
-- Returns whether this handle matches a type name.
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    print("is report = " .. tostring(report:typeOf("LValidationReport")))
end

--@api-stub: LQualityReport:getOverallScore
-- Returns the overall documentation quality score (0-100).
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    print("score = " .. qr:getOverallScore())
end

--@api-stub: LQualityReport:getGrade
-- Returns the letter grade (A-F).
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    print("grade = " .. qr:getGrade())
end

--@api-stub: LQualityReport:getModuleScores
-- Returns a table mapping module names to scores.
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    local scores = qr:getModuleScores()
    print("module scores type = " .. type(scores))
end

--@api-stub: LQualityReport:getWorst
-- Returns the worst-scoring entries.
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    local worst = qr:getWorst(5)
    print("worst 5 = " .. #worst)
end

--@api-stub: LQualityReport:getBest
-- Returns the best-scoring entries.
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    local best = qr:getBest(5)
    print("best 5 = " .. #best)
end

--@api-stub: LQualityReport:getByGrade
-- Returns entries that match a given letter grade.
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    local a_entries = qr:getByGrade("A")
    print("grade A entries = " .. #a_entries)
end

--@api-stub: LQualityReport:getSummary
-- Returns a human-readable quality summary.
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    print("summary = " .. qr:getSummary())
end

--@api-stub: LQualityReport:toTable
-- Converts the quality report to a plain Lua table.
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    local t = qr:toTable()
    print("overall = " .. t.overallScore .. " grade = " .. t.grade)
end

--@api-stub: LQualityReport:toJSON
-- Serializes the quality report to a JSON string.
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    local json = qr:toJSON()
    print("json length = " .. #json)
end

--@api-stub: LQualityReport:type
-- Returns the type name ("LQualityReport").
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    print("type = " .. qr:type())
end

--@api-stub: LQualityReport:typeOf
-- Returns whether this handle matches a type name.
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    print("is report = " .. tostring(qr:typeOf("LQualityReport")))
end

print("docs_01.lua")
