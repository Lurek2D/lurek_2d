local M = {}

local function normalize_path(path)
    path = tostring(path or ""):gsub("\\", "/")
    path = path:gsub("/+", "/")
    if #path > 1 and string.sub(path, -1) == "/" then
        path = string.sub(path, 1, -2)
    end
    return path
end

local function clone(value)
    if type(value) ~= "table" then
        return value
    end
    local copy = {}
    for key, nested in pairs(value) do
        copy[key] = clone(nested)
    end
    return copy
end

local function dirname(path)
    path = normalize_path(path)
    local parent = path:match("^(.*)/[^/]+$")
    return parent or ""
end

local function relative_to_root(path, root)
    path = normalize_path(path)
    root = normalize_path(root)
    if root ~= "" and string.sub(path, 1, #root) == root then
        local relative = string.sub(path, #root + 1)
        if string.sub(relative, 1, 1) == "/" then
            relative = string.sub(relative, 2)
        end
        if relative ~= "" then
            return relative
        end
    end
    return path
end

local function ensure_parent_directory(path)
    local parent = dirname(path)
    if parent ~= "" and not lurek.filesystem.exists(parent) then
        lurek.filesystem.createDirectory(parent)
    end
end

function M.create(registry)
    local self = {
        registry = registry,
        project_root = "",
        documents = {},
        order = {},
        active_path = nil,
    }

    function self:set_project_root(root)
        self.project_root = normalize_path(root)
    end

    function self:get(path)
        return self.documents[normalize_path(path)]
    end

    function self:get_active()
        if not self.active_path then
            return nil
        end
        return self.documents[self.active_path]
    end

    function self:find_by_editor(editor_id)
        for _, path in ipairs(self.order) do
            local document = self.documents[path]
            if document and document.editor_id == editor_id then
                return document
            end
        end
        return nil
    end

    function self:activate(path)
        path = normalize_path(path)
        if self.documents[path] then
            self.active_path = path
            return self.documents[path]
        end
        return nil
    end

    function self:_refresh(document)
        local editor = self.registry:get(document.editor_id)
        document.relative_path = relative_to_root(document.path, self.project_root)
        if editor.validate_document then
            local ok, result = pcall(editor.validate_document, document, self.project_root)
            document.problems = ok and (result or {}) or { tostring(result) }
        else
            document.problems = {}
        end
        if editor.serialize_document then
            local ok, result = pcall(editor.serialize_document, document, self.project_root)
            document.serialized = ok and tostring(result or "") or ""
        else
            document.serialized = document.saved_source or ""
        end
        document.dirty = document.serialized ~= (document.saved_source or "")
        document.revision = (document.revision or 0) + 1
        return document
    end

    function self:_build_document(path, editor)
        local source = lurek.filesystem.read(path)
        local ok, document = pcall(editor.create_document, path, source, self.project_root)
        if not ok then
            return nil, tostring(document)
        end
        if type(document) ~= "table" then
            return nil, "Workbench editor did not return a document table for " .. path
        end
        document.path = normalize_path(path)
        document.editor_id = editor.id
        document.saved_source = source
        document.saved_model = clone(document.model or {})
        document.revision = 0
        document = self:_refresh(document)
        document.saved_source = document.serialized or source
        document.saved_model = clone(document.model or {})
        document.dirty = false
        return document
    end

    function self:open(path)
        path = normalize_path(path)
        local existing = self.documents[path]
        if existing then
            self.active_path = path
            return self:_refresh(existing), nil
        end

        local editor = self.registry:match_path(path)
        if not editor or not editor.create_document then
            return nil, "No workbench editor can open " .. path
        end

        local document, error_message = self:_build_document(path, editor)
        if not document then
            return nil, error_message
        end

        self.documents[path] = document
        self.order[#self.order + 1] = path
        self.active_path = path
        return document, nil
    end

    function self:mutate_active(mutator)
        local document = self:get_active()
        if not document then
            return nil, "No active workbench document"
        end
        local ok, error_message = pcall(mutator, document)
        if not ok then
            return nil, tostring(error_message)
        end
        return self:_refresh(document), nil
    end

    function self:save_active()
        local document = self:get_active()
        if not document then
            return nil, "No active workbench document"
        end
        ensure_parent_directory(document.path)
        lurek.filesystem.write(document.path, document.serialized or "")
        document.saved_source = document.serialized or ""
        document.saved_model = clone(document.model or {})
        document.dirty = false
        return self:_refresh(document), nil
    end

    function self:reload_active()
        local document = self:get_active()
        if not document then
            return nil, "No active workbench document"
        end

        local editor = self.registry:get(document.editor_id)
        local replacement, error_message = self:_build_document(document.path, editor)
        if not replacement then
            return nil, error_message
        end
        self.documents[document.path] = replacement
        self.active_path = document.path
        return replacement, nil
    end

    function self:revert_active()
        local document = self:get_active()
        if not document then
            return nil, "No active workbench document"
        end
        document.model = clone(document.saved_model or {})
        return self:_refresh(document), nil
    end

    function self:export_active()
        local document = self:get_active()
        if not document then
            return nil, "No active workbench document"
        end

        local editor = self.registry:get(document.editor_id)
        if not editor.build_export then
            return nil, "Active workbench editor cannot export " .. tostring(document.path)
        end

        local ok, export_payload = pcall(editor.build_export, document, self.project_root)
        if not ok then
            return nil, tostring(export_payload)
        end
        if type(export_payload) ~= "table" or type(export_payload.path) ~= "string" then
            return nil, "Workbench export payload is missing a path"
        end

        ensure_parent_directory(export_payload.path)
        lurek.filesystem.write(export_payload.path, tostring(export_payload.text or ""))
        document.export_path = normalize_path(export_payload.path)
        document.export_preview = tostring(export_payload.text or "")
        return document, nil
    end

    return self
end

return M
