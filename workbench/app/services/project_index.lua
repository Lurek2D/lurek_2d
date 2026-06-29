local M = {}

local function normalize_path(path)
    path = tostring(path or ""):gsub("\\", "/")
    path = path:gsub("/+", "/")
    if #path > 1 and string.sub(path, -1) == "/" then
        path = string.sub(path, 1, -2)
    end
    return path
end

local function basename(path)
    return (normalize_path(path):match("([^/]+)$")) or normalize_path(path)
end

local function join_path(root, path)
    path = normalize_path(path)
    if path == "" then
        return normalize_path(root)
    end
    if path:match("^[A-Za-z]:/") or string.sub(path, 1, 1) == "/" then
        return path
    end
    return normalize_path(root .. "/" .. path)
end

local function bucket_for(relative_path)
    if relative_path:match("%.particle%.toml$") then
        return "Particles"
    end
    if relative_path:match("%.ltm$") then
        return "Maps"
    end
    if relative_path:match("layouts/") or relative_path:match("%.layout%.toml$") then
        return "Layouts"
    end
    if relative_path:match("%.png$") or relative_path:match("%.jpg$") or relative_path:match("%.ogg$") or relative_path:match("%.wav$") then
        return "Assets"
    end
    return "Other"
end

function M.create()
    local self = {
        root = "",
        entries = {},
        buckets = {
            Particles = {},
            Maps = {},
            Layouts = {},
            Assets = {},
            Other = {},
        },
        node_map = {},
        file_count = 0,
    }

    function self:scan(root)
        root = normalize_path(root)
        local entries = {}
        local buckets = {
            Particles = {},
            Maps = {},
            Layouts = {},
            Assets = {},
            Other = {},
        }
        local file_count = 0
        local raw_items = lurek.filesystem.listRecursive(root) or {}
        table.sort(raw_items)

        for _, raw_path in ipairs(raw_items) do
            local normalized = normalize_path(raw_path)
            local path = normalized
            if normalized ~= root and string.sub(normalized, 1, #root) ~= root then
                path = join_path(root, normalized)
            end
            if path ~= root then
                local relative = path
                if string.sub(path, 1, #root) == root then
                    relative = string.sub(path, #root + 1)
                    if string.sub(relative, 1, 1) == "/" then
                        relative = string.sub(relative, 2)
                    end
                end
                if relative ~= "" then
                    local is_dir = lurek.filesystem.isDirectory(path)
                    local entry = {
                        path = path,
                        relative = relative,
                        kind = is_dir and "directory" or "file",
                        bucket = is_dir and "Other" or bucket_for(relative),
                    }
                    entries[#entries + 1] = entry
                    if not is_dir then
                        file_count = file_count + 1
                        buckets[entry.bucket][#buckets[entry.bucket] + 1] = entry
                    end
                end
            end
        end

        self.root = root
        self.entries = entries
        self.buckets = buckets
        self.file_count = file_count
        self.node_map = {}
        return entries
    end

    function self:get_particle_paths()
        local paths = {}
        for _, entry in ipairs(self.buckets.Particles or {}) do
            paths[#paths + 1] = entry.path
        end
        return paths
    end

    function self:populate_tree(tree)
        tree:clearNodes()
        self.node_map = {}

        local root_node = tree:addNode(basename(self.root))
        local order = { "Particles", "Maps", "Layouts", "Assets", "Other" }
        for _, bucket_name in ipairs(order) do
            local bucket = self.buckets[bucket_name] or {}
            if #bucket > 0 then
                local group_node = tree:addNode(bucket_name .. " (" .. tostring(#bucket) .. ")", root_node)
                for _, entry in ipairs(bucket) do
                    local leaf_node = tree:addNode(entry.relative, group_node)
                    self.node_map[leaf_node] = entry
                end
            end
        end
        tree:expandAll()
    end

    function self:selected_entry(node_index)
        return self.node_map[node_index]
    end

    return self
end

return M
