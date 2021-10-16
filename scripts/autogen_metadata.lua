local uv = vim.loop
local Path = require "nvim-lsp-installer.path"

package.loaded["nvim-lsp-installer.servers"] = nil
package.loaded["nvim-lsp-installer.fs"] = nil
local servers = require "nvim-lsp-installer.servers"

local _generted_dir = Path.concat { vim.fn.getcwd(), "lua", "nvim-lsp-installer", "_generated" }
local metadata_file = Path.concat { _generted_dir, "metadata.json" }
-- the metadata_table can be either a json or lua table
local metadata_file_lua = Path.concat { _generted_dir, "metadata.lua" }

vim.fn.mkdir(_generted_dir, "p")

for _, file in ipairs(vim.fn.glob(_generted_dir .. "*", 1, 1)) do
    vim.fn.delete(file)
end

local function write_file(path, txt, flag)
    uv.fs_open(path, flag, 438, function(open_err, fd)
        assert(not open_err, open_err)
        uv.fs_write(fd, txt, -1, function(write_err)
            assert(not write_err, write_err)
            uv.fs_close(fd, function(close_err)
                assert(not close_err, close_err)
            end)
        end)
    end)
end

local function read_file(path)
    local fd = assert(vim.loop.fs_open(path, "r", 438))
    local stat = assert(vim.loop.fs_fstat(fd))
    local data = assert(vim.loop.fs_read(fd, stat.size, 0))
    assert(vim.loop.fs_close(fd))
    return data
end
local function get_supported_filetypes(server_name)
    -- print("got filetypes query request for: " .. server_name)
    local configs = require "lspconfig/configs"
    pcall(require, ("lspconfig/" .. server_name))
    for _, config in pairs(configs) do
        if config.name == server_name then
            return config.document_config.default_config.filetypes
        end
    end
    -- it's probably still not safe to do this in runtime, but just in case
    package.loaded["lspconfig/configs"] = nil
end

local function generate_metadata_table()
    local json_table = read_file(metadata_file)
    local metadata = vim.json.decode(json_table) or {}

    local function create_metatada_entry(server)
        return { filetyes = get_supported_filetypes(server.name), homepage = server.homepage or "" }
    end

    local available_servers = servers.get_available_servers()
    for _, server in pairs(available_servers) do
        -- metadata[server.name] = create_metatada_entry(server)
        metadata[server.name].filetyes = get_supported_filetypes(server.name)
    end
    print(string.format("found [%s] configurations", #vim.tbl_keys(metadata)))

    return metadata
end

local mt = generate_metadata_table()

write_file(metadata_file, vim.json.encode(mt), "w")
write_file(metadata_file_lua, "return " .. vim.inspect(mt), "w")
