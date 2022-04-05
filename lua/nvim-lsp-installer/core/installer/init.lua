local log = require "nvim-lsp-installer.log"
local path = require "nvim-lsp-installer.path"
local fs = require "nvim-lsp-installer.core.fs"
local Result = require "nvim-lsp-installer.core.result"

local M = {}

---@async
---@param context InstallContext
local function write_receipt(context)
    if context.receipt.is_marked_invalid then
        return log.fmt_debug("Skipping writing receipt for %s because it is marked as invalid.", context.name)
    end
    context.receipt:with_name(context.name):with_schema_version("1.0a"):with_completion_time(vim.loop.gettimeofday())
    local receipt_success, install_receipt = pcall(context.receipt.build, context.receipt)
    if receipt_success then
        local receipt_path = path.concat { context.cwd:get(), "nvim-lsp-installer-receipt.json" }
        pcall(fs.write_file, receipt_path, vim.json.encode(install_receipt))
    else
        log.fmt_error("Failed to build receipt for installation=%s, error=%s", context.name, install_receipt)
    end
end

---@async
---@param context InstallContext
---@param installer async fun(ctx: InstallContext)
function M.execute(context, installer)
    log.fmt_debug("Executing installer for name=%s", context.name)
    local tmp_installation_dir = ("%s.tmp"):format(context.destination_dir)
    return Result.run_catching(function()
        -- 1. prepare installation dir
        context.receipt:with_start_time(vim.loop.gettimeofday())
        if fs.dir_exists(tmp_installation_dir) then
            fs.rmrf(tmp_installation_dir)
        end
        fs.mkdirp(tmp_installation_dir)
        context.cwd:set(tmp_installation_dir)

        -- 2. run installer
        installer(context)

        -- 3. finalize
        write_receipt(context)
        context:promote_cwd()
    end):on_failure(function(failure)
        context.stdio_sink.stderr(tostring(failure))
        context.stdio_sink.stderr "\n"
        log.fmt_error("Installation failed, name=%s, error=%s", context.name, failure)
        pcall(fs.rmrf, tmp_installation_dir)
        pcall(fs.rmrf, context.cwd:get())
    end)
end

---@param installers async fun(ctx: InstallContext)[]
function M.serial(installers)
    ---@async
    ---@param ctx InstallContext
    return function(ctx)
        for _, installer_step in pairs(installers) do
            installer_step(ctx)
        end
    end
end

return M
