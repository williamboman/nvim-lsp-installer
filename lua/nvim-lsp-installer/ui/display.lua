local Ui = require "nvim-lsp-installer.ui"
local log = require "nvim-lsp-installer.log"
local state = require "nvim-lsp-installer.ui.state"

local M = {}

local redraw_by_winnr = {}

function _G.lsp_install_redraw(winnr)
    local fn = redraw_by_winnr[winnr]
    if fn then
        fn()
    end
end

local function debounced(debounced_fn)
    local queued = false
    local last_arg = nil
    return function(a)
        last_arg = a
        if queued then
            return
        end
        queued = true
        vim.schedule(function()
            debounced_fn(last_arg)
            queued = false
        end)
    end
end

local function get_styles(line, render_context)
    local indentation = 0

    for _, styles in ipairs(render_context.applied_block_styles) do
        for _, style in ipairs(styles) do
            if style == Ui.CascadingStyle.INDENT then
                indentation = indentation + 2
            elseif style == Ui.CascadingStyle.CENTERED then
                local padding = math.floor((render_context.context.win_width - #line) / 2)
                indentation = math.max(0, padding) -- CENTERED overrides any already applied indentation
            end
        end
    end

    return {
        indentation = indentation,
    }
end

local function render_node(context, node, _render_context, _output)
    local render_context = _render_context or {
        context = context,
        applied_block_styles = {},
    }
    local output = _output or {
        lines = {},
        virt_texts = {},
        highlights = {},
    }

    if node.type == Ui.NodeType.VIRTUAL_TEXT then
        table.insert(output.virt_texts, {
            line = #output.lines - 1,
            content = node.virt_text,
        })
    elseif node.type == Ui.NodeType.HL_TEXT then
        for _, line in ipairs(node.lines) do
            local line_highlights = {}
            local full_line = ""
            for _, span in ipairs(line) do
                local content, hl_group = span[1], span[2]
                local col_start = #full_line
                full_line = full_line .. content
                table.insert(line_highlights, {
                    hl_group = hl_group,
                    line = #output.lines,
                    col_start = col_start,
                    col_end = col_start + #content,
                })
            end

            local active_styles = get_styles(full_line, render_context)

            -- apply indentation
            full_line = (" "):rep(active_styles.indentation) .. full_line
            for _, highlight in ipairs(line_highlights) do
                highlight.col_start = highlight.col_start + active_styles.indentation
                highlight.col_end = highlight.col_end + active_styles.indentation
                table.insert(output.highlights, highlight)
            end

            table.insert(output.lines, full_line)
        end
    elseif node.type == Ui.NodeType.NODE or node.type == Ui.NodeType.STYLE_BLOCK then
        if node.type == Ui.NodeType.STYLE_BLOCK then
            table.insert(render_context.applied_block_styles, node.styles)
        end
        for _, child in ipairs(node.children) do
            render_node(context, child, render_context, output)
        end
        if node.type == Ui.NodeType.STYLE_BLOCK then
            table.remove(render_context.applied_block_styles, #render_context.applied_block_styles)
        end
    end

    return output
end

function M.new_view_only_win(name)
    local namespace = vim.api.nvim_create_namespace(("lsp_installer_%s"):format(name))
    local win, buf, renderer, mutate_state, get_state, unsubscribe
    local has_initiated = false

    local function open(opts)
        opts = opts or {}
        if opts.win_width then
            vim.cmd(("%dvnew"):format(opts.win_width))
        else
            vim.cmd [[vnew]]
        end

        win = vim.api.nvim_get_current_win()
        buf = vim.api.nvim_get_current_buf()

        vim.api.nvim_buf_set_option(buf, "modifiable", false)
        vim.api.nvim_buf_set_option(buf, "swapfile", false)
        vim.api.nvim_buf_set_option(buf, "textwidth", 0)
        vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
        vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
        vim.api.nvim_buf_set_option(buf, "buflisted", false)
        vim.api.nvim_buf_set_option(buf, "filetype", "lsp-installer")

        vim.api.nvim_win_set_option(win, "wrap", false)
        vim.api.nvim_win_set_option(win, "spell", false)
        vim.api.nvim_win_set_option(win, "number", false)
        vim.api.nvim_win_set_option(win, "relativenumber", false)
        vim.api.nvim_win_set_option(win, "foldenable", false)
        vim.api.nvim_win_set_option(win, "signcolumn", "no")
        vim.api.nvim_win_set_option(win, "colorcolumn", "")

        vim.cmd [[ syntax clear ]]

        for _, redraw_event in ipairs { "WinEnter", "WinLeave", "VimResized" } do
            vim.cmd(("autocmd %s <buffer> call v:lua.lsp_install_redraw(%d)"):format(redraw_event, win))
        end

        if opts.highlight_groups then
            for _, hl_group in ipairs(opts.highlight_groups) do
                vim.cmd(hl_group)
            end
        end
    end

    local draw = debounced(function(view)
        if not win or not vim.api.nvim_win_is_valid(win) then
            -- the window has been closed, e.g, by the user
            unsubscribe(true)
            return log.debug { "Window is no longer valid", name, win }
        end

        local win_width = vim.api.nvim_win_get_width(win)
        local context = {
            win_width = win_width,
        }
        local output = render_node(context, view)

        vim.api.nvim_buf_clear_namespace(0, namespace, 0, -1)
        vim.api.nvim_buf_set_option(buf, "modifiable", true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, true, output.lines)
        vim.api.nvim_buf_set_option(buf, "modifiable", false)
        for _, virt_text in ipairs(output.virt_texts) do
            vim.api.nvim_buf_set_extmark(buf, namespace, virt_text.line, 0, {
                virt_text = virt_text.content,
            })
        end
        for _, highlight in ipairs(output.highlights) do
            vim.api.nvim_buf_add_highlight(
                buf,
                namespace,
                highlight.hl_group,
                highlight.line,
                highlight.col_start,
                highlight.col_end
            )
        end
    end)

    return {
        view = function(x)
            renderer = x
        end,
        init = function(initial_state)
            assert(renderer ~= nil, "No view function has been registered. Call .view() before .init().")
            has_initiated = true

            mutate_state, get_state, unsubscribe = state.create_state_container(initial_state, function(new_state)
                draw(renderer(new_state))
            end)

            return mutate_state, get_state
        end,
        open = vim.schedule_wrap(function(opts)
            log.debug { "opening window" }
            assert(has_initiated, "Display has not been initiated, cannot open.")
            if win and vim.api.nvim_win_is_valid(win) then
                return
            end
            unsubscribe(false)
            open(opts)
            draw(renderer(get_state()))
            redraw_by_winnr[win] = function()
                draw(renderer(get_state()))
            end
        end),
        -- This is probably not needed.
        -- destroy = vim.schedule_wrap(function()
        --     assert(has_initiated, "Display has not been initiated, cannot destroy.")
        --     TODO: what happens with the state container, etc?
        --     unsubscribe(true)
        --     redraw_by_winnr[win] = nil
        --     if win then
        --         vim.api.nvim_win_close(win, true)
        --     end
        -- end),
    }
end

return M
