-- content/examples/tools/data_validate_config.lua
-- Run by copying this file into a game folder as main.lua or through the examples smoke workflow.

--- Data schema validation vs static project/file validation.

local function example_print_log(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring(select(i, ...))
    end
    lurek.log.info(table.concat(parts, " "))
end

--@api: lurek.serial.validate
do
    local config = {
        title = "Household Finance Lab",
        autosave = true,
        month_limit = 12,
    }

    local schema = {
        type = "table",
        fields = {
            title = { type = "string", required = true, minlen = 1 },
            autosave = { type = "boolean", required = true },
            month_limit = { type = "number", required = true, min = 1, max = 24 },
        },
    }

    local ok, err = lurek.serial.validate(config, schema)
    example_print_log("config schema ok=" .. tostring(ok))
    example_print_log("config schema err=" .. tostring(err))
end

--@api: lurek.validator.validateFile
do
    local ok, report_or_err = pcall(lurek.validator.validateFile, "main.lua")

    if ok then
        local report = report_or_err
        example_print_log("main.lua static files_checked=" .. tostring(report.files_checked))
        example_print_log("main.lua static errors=" .. tostring(report.error_count))
    else
        example_print_log("main.lua static validation skipped=" .. tostring(report_or_err))
    end
end
