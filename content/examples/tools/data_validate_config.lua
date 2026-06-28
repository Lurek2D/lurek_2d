-- content/examples/tools/data_validate_config.lua
-- Run by copying this file into a game folder as main.lua or through the examples smoke workflow.

--- Data schema validation vs static project/file validation.

--@api: lurek.serialize.validate
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

    local ok, err = lurek.serialize.validate(config, schema)
    lurek.log.info("config schema ok=" .. tostring(ok))
    lurek.log.info("config schema err=" .. tostring(err))
end

--@api: lurek.validator.validateFile
do
    local ok, report_or_err = pcall(lurek.validator.validateFile, "main.lua")

    if ok then
        local report = report_or_err
        lurek.log.info("main.lua static files_checked=" .. tostring(report.files_checked))
        lurek.log.info("main.lua static errors=" .. tostring(report.error_count))
    else
        lurek.log.info("main.lua static validation skipped=" .. tostring(report_or_err))
    end
end
