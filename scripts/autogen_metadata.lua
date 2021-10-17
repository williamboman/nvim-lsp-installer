local uv = vim.loop
local Path = require "nvim-lsp-installer.path"

package.loaded["nvim-lsp-installer.servers"] = nil
package.loaded["nvim-lsp-installer.fs"] = nil
local servers = require "nvim-lsp-installer.servers"

local generated_dir = Path.concat { vim.fn.getcwd(), "lua", "nvim-lsp-installer", "_generated" }

print("Creating directory" .. generated_dir)
vim.fn.mkdir(generated_dir, "p")

for _, file in ipairs(vim.fn.glob(generated_dir .. "*", 1, 1)) do
    print("Deleting " .. file)
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
    local metadata = {}

    local function create_metatada_entry(server)
        return { filetypes = get_supported_filetypes(server.name) }
    end

    local available_servers = servers.get_available_servers()
    for _, server in pairs(available_servers) do
        metadata[server.name] = create_metatada_entry(server)
    end
    print(string.format("found [%s] configurations", #vim.tbl_keys(metadata)))

    return metadata
end

local mt = generate_metadata_table()

-- We don't have any use for JSON file (yet) - skip generating to save bytes
-- local metadata_json_file = Path.concat { generated_dir, "metadata.json" }
-- write_file(metadata_json_file, vim.json.encode(mt), "w")
local metadata_file_lua = Path.concat { generated_dir, "metadata.lua" }
write_file(metadata_file_lua, "return " .. vim.inspect(mt), "w")
