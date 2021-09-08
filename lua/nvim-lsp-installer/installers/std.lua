local process = require "nvim-lsp-installer.process"
local path = require "nvim-lsp-installer.path"

local M = {}

function M.download_file(url, out_file)
    return function(server, callback, context)
        process.spawn("wget", {
            args = { "-nv", "-O", out_file, url },
            cwd = server.root_dir,
            stdio_sink = context.stdio_sink,
        }, callback)
    end
end

function M.unzip(file, dest)
    return function(server, callback, context)
        process.spawn("unzip", {
            args = { "-d", dest, file },
            cwd = server.root_dir,
            stdio_sink = context.stdio_sink,
        }, callback)
    end
end

function M.delete_file(file)
    return vim.schedule_wrap(function(server, callback, context)
        local abs_path = path.concat { server.root_dir, file }
        if vim.fn.delete(abs_path) ~= 0 then
            context.stdio_sink.stderr(("Unable to delete file %q"):format(abs_path))
            callback(false)
        else
            callback(true)
        end
    end)
end

function M.delete_dir(file)
    return vim.schedule_wrap(function(server, callback, context)
        local abs_path = path.concat { server.root_dir, file }
        if vim.fn.delete(abs_path, "rf") ~= 0 then
            context.stdio_sink.stderr(("Unable to delete directory %q"):format(abs_path))
            callback(false)
        else
            callback(true)
        end
    end)
end

function M.git_clone(repo_url)
    return function(server, callback, context)
        process.spawn("git", {
            args = { "clone", "--depth", "1", repo_url, "." },
            cwd = server.root_dir,
            stdio_sink = context.stdio_sink,
        }, callback)
    end
end

return M
