local Data = require "nvim-lsp-installer.data"
local M = {}

---@alias NodeType
---| '"NODE"'
---| '"CASCADING_STYLE"'
---| '"VIRTUAL_TEXT"'
---| '"HL_TEXT"'
---| '"KEYBIND_HANDLER"'

---@alias INode Node | HlTextNode | CascadingStyleNode | VirtualTextNode | KeybindHandlerNode

---@param children INode[]
function M.Node(children)
    ---@class Node
    local node = {
        type = "NODE",
        children = children,
    }
    return node
end

---@param lines_with_span_tuples string[][]|string[]
function M.HlTextNode(lines_with_span_tuples)
    if type(lines_with_span_tuples[1]) == "string" then
        -- this enables a convenience API for just rendering a single line (with just a single span)
        lines_with_span_tuples = { { lines_with_span_tuples } }
    end
    ---@class HlTextNode
    local node = {
        type = "HL_TEXT",
        lines = lines_with_span_tuples,
    }
    return node
end

---@param lines string[]
function M.Text(lines)
    return M.HlTextNode(Data.list_map(function(line)
        return { { line, "" } }
    end, lines))
end

---@alias CascadingStyle
---| '"INDENT"'
---| '"CENTERED"'

---@param styles CascadingStyle[]
---@param children INode[]
function M.CascadingStyleNode(styles, children)
    ---@class CascadingStyleNode
    local node = {
        type = "CASCADING_STYLE",
        styles = styles,
        children = children,
    }
    return node
end

---@param virt_text string[][] @List of (text, highlight) tuples.
function M.VirtualTextNode(virt_text)
    ---@class VirtualTextNode
    local node = {
        type = "VIRTUAL_TEXT",
        virt_text = virt_text,
    }
    return node
end

---@param condition boolean
---@param node INode | fun(): INode
---@param default_val any
function M.When(condition, node, default_val)
    if condition then
        if type(node) == "function" then
            return node()
        else
            return node
        end
    end
    return default_val or M.Node {}
end

---@param key string @The keymap to register to. Example: "<CR>".
---@param effect string @The effect to call when keymap is triggered by the user.
---@param payload any @The payload to pass to the effect handler when triggered.
---@param is_global boolean @Whether to register the keybind to apply on all lines in the buffer.
function M.Keybind(key, effect, payload, is_global)
    ---@class KeybindHandlerNode
    local node = {
        type = "KEYBIND_HANDLER",
        key = key,
        effect = effect,
        payload = payload,
        is_global = is_global or false,
    }
    return node
end

function M.EmptyLine()
    return M.Text { "" }
end

---@param rows string[][][] @A list of rows to include in the table. Each row consists of an array of (text, highlight) tuples (aka spans).
function M.Table(rows)
    local col_maxwidth = {}
    for i = 1, #rows do
        local row = rows[i]
        for j = 1, #row do
            local col = row[j]
            local content = col[1]
            col_maxwidth[j] = math.max(vim.api.nvim_strwidth(content), col_maxwidth[j] or 0)
        end
    end

    for i = 1, #rows do
        local row = rows[i]
        for j = 1, #row do
            local col = row[j]
            local content = col[1]
            col[1] = content .. string.rep(" ", col_maxwidth[j] - vim.api.nvim_strwidth(content) + 1) -- +1 for default minimum padding
        end
    end

    return M.HlTextNode(rows)
end

return M
