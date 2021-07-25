local extras = require'nvim-lsp-installer.extras.utils'

local M = {}

function M.apply_all_fixes(bufnr)
    bufnr = bufnr or 0

    extras.send_client_request(
        "eslintls",
        "workspace/executeCommand",
        {
            command = "eslint.applyAllFixes",
            arguments = {
                {
                    uri = vim.uri_from_fname(vim.api.nvim_buf_get_name(bufnr)),
                    version = vim.lsp.util.buf_versions[vim.api.nvim_buf_get_number(bufnr)]
                }
            }
        }
    )
end

-- Formatting and "apply all fixes" does the same thing in the ESLint LSP implementation, so for semantic reasons we only offer the "apply all fixes" method.
-- function M.format(bufnr)
--     bufnr = bufnr or 0
--     extras.send_client_request(
--         "eslintls",
--         "textDocument/formatting",
--         { textDocument = { uri = vim.uri_from_fname(vim.api.nvim_buf_get_name(bufnr)) } }
--     )
-- end

return M
