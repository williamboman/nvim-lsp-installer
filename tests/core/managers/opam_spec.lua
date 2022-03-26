local match = require "luassert.match"
local mock = require "luassert.mock"
local Optional = require "nvim-lsp-installer.core.optional"
local opam = require "nvim-lsp-installer.core.managers.opam"

describe("opam manager", function()
    ---@type InstallContext
    local ctx
    before_each(function()
        ctx = InstallContextGenerator {
            spawn = mock.new {
                opam = mockx.returns {},
            },
        }
    end)

    it(
        "should call opam install",
        async_test(function()
            ctx.requested_version = Optional.of "42.13.37"
            opam.packages { "main-package", "supporting-package", "supporting-package2" }(ctx)
            assert.spy(ctx.spawn.opam).was_called(1)
            assert.spy(ctx.spawn.opam).was_called_with(match.tbl_containing {
                "install",
                "--destdir=.",
                "--yes",
                "--verbose",
                match.tbl_containing {
                    "main-package.42.13.37",
                    "supporting-package",
                    "supporting-package2",
                },
            })
        end)
    )

    it(
        "should provide receipt information",
        async_test(function()
            ctx.requested_version = Optional.of "42.13.37"
            opam.packages { "main-package", "supporting-package", "supporting-package2" }(ctx)
            assert.equals(
                vim.inspect {
                    type = "opam",
                    package = "main-package",
                },
                vim.inspect(ctx.receipt.primary_source)
            )
            assert.equals(
                vim.inspect {
                    {
                        type = "opam",
                        package = "supporting-package",
                    },
                    {
                        type = "opam",
                        package = "supporting-package2",
                    },
                },
                vim.inspect(ctx.receipt.secondary_sources)
            )
        end)
    )
end)
