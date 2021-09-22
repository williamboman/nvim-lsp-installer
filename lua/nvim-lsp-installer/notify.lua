local TITLE = "nvim-lsp-installer"

return function(msg, level)
    local has_notify_plugin = pcall(require, "notify")
    level = level or vim.log.levels.INFO
    if has_notify_plugin then
        vim.notify(msg, level, {
            title = TITLE,
        })
    else
        local vim_log_levels = vim.tbl_keys(vim.log.levels)
        local log_levels = vim.tbl_map(function(lv)
            return lv:lower()
        end, vim_log_levels)

        local Log = require "nvim-lsp-installer.log"
        Log[log_levels[level]](msg)
    end
end
