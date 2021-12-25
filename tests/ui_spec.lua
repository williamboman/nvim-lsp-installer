local display = require "nvim-lsp-installer.ui.display"
local Ui = require "nvim-lsp-installer.ui"

describe("ui", function()
    it("produces a correct tree", function()
        local function renderer(state)
            return Ui.CascadingStyleNode({ "INDENT" }, {
                Ui.When(not state.is_active, function()
                    return Ui.Text {
                        "I'm not active",
                        "Another line",
                    }
                end),
                Ui.When(state.is_active, function()
                    return Ui.Text {
                        "I'm active",
                        "Yet another line",
                    }
                end),
            })
        end

        assert.equal(
            vim.inspect {
                children = {
                    {
                        type = "HL_TEXT",
                        lines = {
                            { { "I'm not active", "" } },
                            { { "Another line", "" } },
                        },
                    },
                    {
                        type = "NODE",
                        children = {},
                    },
                },
                styles = { "INDENT" },
                type = "CASCADING_STYLE",
            },
            vim.inspect(renderer { is_active = false })
        )

        assert.equal(
            vim.inspect {
                children = {
                    {
                        type = "NODE",
                        children = {},
                    },
                    {
                        type = "HL_TEXT",
                        lines = {
                            { { "I'm active", "" } },
                            { { "Yet another line", "" } },
                        },
                    },
                },
                styles = { "INDENT" },
                type = "CASCADING_STYLE",
            },
            vim.inspect(renderer { is_active = true })
        )
    end)

    it("renders a tree correctly", function()
        local render_output = display._render_node(
            {
                win_width = 120,
            },
            Ui.CascadingStyleNode({ "INDENT" }, {
                Ui.Keybind("i", "INSTALL_SERVER", { "sumneko_lua" }, true),
                Ui.HlTextNode {
                    {
                        { "Hello World!", "MyHighlightGroup" },
                    },
                    {
                        { "Another Line", "Comment" },
                    },
                },
                Ui.HlTextNode {
                    {
                        { "Install something idk", "Stuff" },
                    },
                },
                Ui.Keybind("<CR>", "INSTALL_SERVER", { "tsserver" }, false),
            })
        )

        assert.equal(
            vim.inspect {
                highlights = {
                    {
                        col_start = 2,
                        col_end = 14,
                        line = 0,
                        hl_group = "MyHighlightGroup",
                    },
                    {
                        col_start = 2,
                        col_end = 14,
                        line = 1,
                        hl_group = "Comment",
                    },
                    {
                        col_start = 2,
                        col_end = 23,
                        line = 2,
                        hl_group = "Stuff",
                    },
                },
                lines = { "  Hello World!", "  Another Line", "  Install something idk" },
                virt_texts = {},
                keybinds = {
                    {
                        effect = "INSTALL_SERVER",
                        key = "i",
                        line = -1,
                        payload = { "sumneko_lua" },
                    },
                    {
                        effect = "INSTALL_SERVER",
                        key = "<CR>",
                        line = 3,
                        payload = { "tsserver" },
                    },
                },
            },
            vim.inspect(render_output)
        )
    end)
end)
