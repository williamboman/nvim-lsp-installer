local M = {}

function M.is_win()
    return vim.fn.has "win32" == 1
end

return M
