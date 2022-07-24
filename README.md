<p align="center">
  <img src="https://user-images.githubusercontent.com/6705160/118490159-f064bb00-b71d-11eb-883e-4affbd020074.png" alt="nvim-lsp-installer" width="50%" />
</p>

-   [ℹ️ Project status](#ℹ%EF%B8%8F-project-status)
-   [About](#about)
-   [Screenshots](#screenshots)
-   [Requirements](#requirements)
    -   [Minimum requirements](#minimum-requirements)
    -   [Additional requirements](#additional-requirements)
-   [Installation](#installation)
-   [Usage](#usage)
    -   [Setup](#setup)
    -   [Commands](#commands)
    -   [Configuration](#configuration)
-   [Available LSPs](#available-lsps)
-   [Logo](#logo)
-   [Default configuration](#default-configuration)

## ℹ️ Project status

> This is an excerpt from the [announcement here](https://github.com/williamboman/nvim-lsp-installer/discussions/876).

_`nvim-lsp-installer` will no longer be actively maintained, meaning I won't be doing things like porting new mason.nvim
packages to nvim-lsp-installer, monitoring lspconfig for changes that require updates, or put much effort into user
support or bug issues (the recommendation for the latter will be to migrate to mason.nvim)._

[`mason.nvim`](https://github.com/williamboman/mason.nvim) is the next generation version of `nvim-lsp-installer`. It
builds on top of the very same foundation as `nvim-lsp-installer`, but with a majority of internals refactored to
improve extensibility and testability.

More importantly, the scope of `mason.nvim` has also been widened to target more than just LSP servers. `mason.nvim`
supports DAP servers, linters, formatters, and more. As of writing, `mason.nvim` provides 150+ packages for 100+
languages. It can be thought of as a general-purpose package manager, native to Neovim, that runs everywhere Neovim runs
(Windows, macOS, Linux, etc.).

Another big change with `mason.nvim` is that executables are now linked to a single, shared, location, allowing seamless
access from Neovim builtins (shell, terminal, etc.) as well as other 3rd party plugins.

There have also been other improvements such as broader test coverage, more documentation, and a revamped UI!

## About

Neovim plugin that allow you to manage LSP servers (servers are installed inside `:echo stdpath("data")` by default).
It works in tandem with [`lspconfig`](https://github.com/neovim/nvim-lspconfig)<sup>1</sup> by registering a hook that
enhances the `PATH` environment variable, allowing neovim's LSP client to locate the server executable installed by
nvim-lsp-installer.<sup>2</sup>

On top of just providing commands for installing & uninstalling LSP servers, it:

-   provides a graphical UI
-   provides the ability to check for, and upgrade to, new server versions through a single interface
-   supports installing custom versions of LSP servers (for example `:LspInstall rust_analyzer@nightly`)
-   relaxes the minimum requirements by attempting multiple different utilities (for example, only one of `wget`, `curl`, or `Invoke-WebRequest` is required for HTTP requests)
-   hosts [a suite of system tests](https://github.com/williamboman/nvim-lspconfig-test) for all supported servers
-   has full support for Windows <img src="https://user-images.githubusercontent.com/6705160/131256603-cacf7f66-dfa9-4515-8ae4-0e42d08cfc6a.png" height="20">

<sup>1 - while lspconfig is the main target, this plugin may also be used for other use cases</sup>
<br>
<sup>2 - some servers don't provide an executable, in which case the full command to spawn the server is provided instead</sup>

## Screenshots

|                                                                                                                    |                                                                                                                    |                                                                                                                    |
| :----------------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------: |
| <img src="https://user-images.githubusercontent.com/6705160/150685720-782e33ba-172c-44b6-8558-fb4e98495294.png" /> | <img src="https://user-images.githubusercontent.com/6705160/150685404-2cd34b25-166e-4c84-b9dd-1d5580dc2bdd.png" /> | <img src="https://user-images.githubusercontent.com/6705160/150685322-a537f021-5850-4bbc-8be2-1ece5678d205.png" /> |
| <img src="https://user-images.githubusercontent.com/6705160/150685324-1310ae7d-67bf-4053-872c-d27e8a4c4b80.png" /> | <img src="https://user-images.githubusercontent.com/6705160/150686052-fd5c4d54-b4da-4cb3-bb82-a094526ee5b5.png" /> | <img src="https://user-images.githubusercontent.com/6705160/150686059-f1be8131-1274-4f62-9aa8-345599cbd8bc.png" /> |

## Requirements

Requires neovim `>= 0.7.0` and [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig).

### Minimum requirements

The minimum recommended requirements are:

-   For Unix systems: git(1), curl(1) or wget(1), unzip(1), tar(1), gzip(1)
-   For Windows systems: powershell, git, tar, and [7zip][7zip] or [peazip][peazip] or [archiver][archiver] or [winzip][winzip] or [WinRAR][winrar]

### Additional requirements

Additional requirements to install & run all servers are (depending on usage):

-   Node.js (LTS) & npm
-   Python3 & pip3
-   go >= 1.17
-   cargo
-   Ruby & gem
-   PHP & Composer
-   JDK
-   Julia
-   dotnet
-   ghcup
-   luarocks
-   meson
-   ninja
-   pwsh
-   rebar3
-   valac

[7zip]: https://www.7-zip.org/
[archiver]: https://github.com/mholt/archiver
[peazip]: https://peazip.github.io/
[winzip]: https://www.winzip.com/
[winrar]: https://www.win-rar.com/

## Installation

### [Packer](https://github.com/wbthomason/packer.nvim)

```lua
use {
    "williamboman/nvim-lsp-installer",
    "neovim/nvim-lspconfig",
}
```

### vim-plug

```vim
Plug 'williamboman/nvim-lsp-installer'
Plug 'neovim/nvim-lspconfig'
```

## Usage

nvim-lsp-installer will only make sure that Neovim can find your installed servers, it does not set up any servers for
you automatically. You will have to set up your servers yourself (for example via
[lspconfig](https://github.com/neovim/nvim-lspconfig)).

### Setup

In order for nvim-lsp-installer to register the necessary hooks at the right moment, **make sure you call the
`require("nvim-lsp-installer").setup()` function before you set up any servers**!

```lua
require("nvim-lsp-installer").setup {}
```

Refer to the [Configuration](#configuration) section for information about which settings are available.

### Commands

-   `:LspInstallInfo` - opens a graphical overview of your language servers
-   `:LspInstall [--sync] [server] ...` - installs/reinstalls language servers. Runs in a blocking fashion if the `--sync` argument is passed (only recommended for scripting purposes).
-   `:LspUninstall [--sync] <server> ...` - uninstalls language servers. Runs in a blocking fashion if the `--sync` argument is passed (only recommended for scripting purposes).
-   `:LspUninstallAll [--no-confirm]` - uninstalls all language servers
-   `:LspInstallLog` - opens the log file in a new tab window
-   `:LspPrintInstalled` - prints all installed language servers

### Configuration

You may optionally configure certain behavior of nvim-lsp-installer when calling the `.setup()` function.

Refer to the [default configuration](#default-configuration) for all available settings.

Example:

```lua
require("nvim-lsp-installer").setup({
    automatic_installation = true, -- automatically detect which servers to install (based on which servers are set up via lspconfig)
    ui = {
        icons = {
            server_installed = "✓",
            server_pending = "➜",
            server_uninstalled = "✗"
        }
    }
})
```

## Available LSPs

| Language                            | Server name                |
| ----------------------------------- | -------------------------- |
| AWK                                 | `awk_ls`                   |
| Angular                             | `angularls`                |
| Ansible                             | `ansiblels`                |
| Apex                                | `apex_ls`                  |
| Arduino [(docs!!!)][arduino]        | `arduino_language_server`  |
| Assembly (GAS/NASM, GO)             | `asm_lsp`                  |
| Astro                               | `astro`                    |
| Bash                                | `bashls`                   |
| Beancount                           | `beancount`                |
| Bicep                               | `bicep`                    |
| C                                   | `ccls`                     |
| C                                   | `clangd`                   |
| C#                                  | `csharp_ls`                |
| C# [(docs)][omnisharp]              | `omnisharp`                |
| C++                                 | `ccls`                     |
| C++                                 | `clangd`                   |
| CMake                               | `cmake`                    |
| CSS                                 | `cssls`                    |
| CSS                                 | `cssmodules_ls`            |
| Clarity                             | `clarity_lsp`              |
| Clojure                             | `clojure_lsp`              |
| CodeQL                              | `codeqlls`                 |
| Crystal                             | `crystalline`              |
| Crystal                             | `scry`                     |
| Cucumber                            | `cucumber_language_server` |
| Dart                                | `dartls`                   |
| Deno                                | `denols`                   |
| Dhall                               | `dhall_lsp_server`         |
| Diagnostic (general purpose server) | `diagnosticls`             |
| Dlang                               | `serve_d`                  |
| Docker                              | `dockerls`                 |
| Dot                                 | `dotls`                    |
| EFM (general purpose server)        | `efm`                      |
| ESLint [(docs)][eslint]             | `eslint`                   |
| Elixir                              | `elixirls`                 |
| Elm                                 | `elmls`                    |
| Ember                               | `ember`                    |
| Emmet                               | `emmet_ls`                 |
| Erlang                              | `erlangls`                 |
| F#                                  | `fsautocomplete`           |
| Flux                                | `flux_lsp`                 |
| Foam (OpenFOAM)                     | `foam_ls`                  |
| Fortran                             | `fortls`                   |
| Go                                  | `golangci_lint_ls`         |
| Go                                  | `gopls`                    |
| Grammarly                           | `grammarly`                |
| GraphQL                             | `graphql`                  |
| Groovy                              | `groovyls`                 |
| HTML                                | `html`                     |
| Haskell                             | `hls`                      |
| Haxe                                | `haxe_language_server`     |
| Hoon                                | `hoon_ls`                  |
| JSON                                | `jsonls`                   |
| Java [(docs)][jdtls]                | `jdtls`                    |
| JavaScript                          | `quick_lint_js`            |
| JavaScript                          | `tsserver`                 |
| Jsonnet                             | `jsonnet_ls`               |
| Julia [(docs)][julials]             | `julials`                  |
| Kotlin                              | `kotlin_language_server`   |
| LaTeX                               | `ltex`                     |
| LaTeX                               | `texlab`                   |
| Lelwel                              | `lelwel_ls`                |
| Lua                                 | `sumneko_lua`              |
| Markdown                            | `marksman`                 |
| Markdown                            | `prosemd_lsp`              |
| Markdown                            | `remark_ls`                |
| Markdown                            | `zk`                       |
| Metamath Zero                       | `mm0_ls`                   |
| Nickel                              | `nickel_ls`                |
| Nim                                 | `nimls`                    |
| Nix                                 | `rnix`                     |
| OCaml                               | `ocamlls`                  |
| OCaml                               | `ocamllsp`                 |
| Objective C                         | `ccls`                     |
| OneScript, 1C:Enterprise            | `bsl_ls`                   |
| OpenCL                              | `opencl_ls`                |
| PHP                                 | `intelephense`             |
| PHP                                 | `phpactor`                 |
| PHP                                 | `psalm`                    |
| Perl                                | `perlnavigator`            |
| Powershell                          | `powershell_es`            |
| Prisma                              | `prismals`                 |
| Puppet                              | `puppet`                   |
| PureScript                          | `purescriptls`             |
| Python                              | `jedi_language_server`     |
| Python                              | `pyright`                  |
| Python                              | `sourcery`                 |
| Python [(docs)][pylsp]              | `pylsp`                    |
| R                                   | `r_language_server`        |
| ReScript                            | `rescriptls`               |
| Reason                              | `reason_ls`                |
| Robot Framework                     | `robotframework_ls`        |
| Rome                                | `rome`                     |
| Ruby                                | `solargraph`               |
| Rust                                | `rust_analyzer`            |
| SQL                                 | `sqlls`                    |
| SQL                                 | `sqls`                     |
| Salt                                | `salt_ls`                  |
| Shopify Theme Check                 | `theme_check`              |
| Slint                               | `slint_lsp`                |
| Solidity                            | `solang`                   |
| Solidity                            | `solc`                     |
| Solidity (VSCode)                   | `solidity_ls`              |
| Sorbet                              | `sorbet`                   |
| Sphinx                              | `esbonio`                  |
| Stylelint                           | `stylelint_lsp`            |
| Svelte                              | `svelte`                   |
| Swift                               | `sourcekit`                |
| SystemVerilog                       | `svlangserver`             |
| SystemVerilog                       | `svls`                     |
| SystemVerilog                       | `verible`                  |
| TOML                                | `taplo`                    |
| Tailwind CSS                        | `tailwindcss`              |
| Teal                                | `teal_ls`                  |
| Terraform                           | `terraformls`              |
| Terraform [(docs)][tflint]          | `tflint`                   |
| TypeScript                          | `tsserver`                 |
| V                                   | `vls`                      |
| Vala                                | `vala_ls`                  |
| VimL                                | `vimls`                    |
| Visualforce                         | `visualforce`              |
| Vue                                 | `volar`                    |
| Vue                                 | `vuels`                    |
| XML                                 | `lemminx`                  |
| YAML                                | `yamlls`                   |
| Zig                                 | `zls`                      |

[arduino]: ./lua/nvim-lsp-installer/servers/arduino_language_server/README.md
[eslint]: ./lua/nvim-lsp-installer/servers/eslint/README.md
[jdtls]: ./lua/nvim-lsp-installer/servers/jdtls/README.md
[julials]: ./lua/nvim-lsp-installer/servers/julials/README.md
[omnisharp]: ./lua/nvim-lsp-installer/servers/omnisharp/README.md
[pylsp]: ./lua/nvim-lsp-installer/servers/pylsp/README.md
[tflint]: ./lua/nvim-lsp-installer/servers/tflint/README.md

## Logo

Illustrations in the logo are derived from [@Kaligule](https://schauderbasis.de/)'s "Robots" collection.

## Default configuration

```lua
local DEFAULT_SETTINGS = {
    -- A list of servers to automatically install if they're not already installed. Example: { "rust_analyzer", "sumneko_lua" }
    -- This setting has no relation with the `automatic_installation` setting.
    ensure_installed = {},

    -- Whether servers that are set up (via lspconfig) should be automatically installed if they're not already installed.
    -- This setting has no relation with the `ensure_installed` setting.
    -- Can either be:
    --   - false: Servers are not automatically installed.
    --   - true: All servers set up via lspconfig are automatically installed.
    --   - { exclude: string[] }: All servers set up via lspconfig, except the ones provided in the list, are automatically installed.
    --       Example: automatic_installation = { exclude = { "rust_analyzer", "solargraph" } }
    automatic_installation = false,

    ui = {
        -- Whether to automatically check for outdated servers when opening the UI window.
        check_outdated_servers_on_open = true,

        -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
        border = "none",

        icons = {
            -- The list icon to use for installed servers.
            server_installed = "◍",
            -- The list icon to use for servers that are pending installation.
            server_pending = "◍",
            -- The list icon to use for servers that are not installed.
            server_uninstalled = "◍",
        },
        keymaps = {
            -- Keymap to expand a server in the UI
            toggle_server_expand = "<CR>",
            -- Keymap to install the server under the current cursor position
            install_server = "i",
            -- Keymap to reinstall/update the server under the current cursor position
            update_server = "u",
            -- Keymap to check for new version for the server under the current cursor position
            check_server_version = "c",
            -- Keymap to update all installed servers
            update_all_servers = "U",
            -- Keymap to check which installed servers are outdated
            check_outdated_servers = "C",
            -- Keymap to uninstall a server
            uninstall_server = "X",
        },
    },

    -- The directory in which to install all servers.
    install_root_dir = path.concat { vim.fn.stdpath "data", "lsp_servers" },

    pip = {
        -- These args will be added to `pip install` calls. Note that setting extra args might impact intended behavior
        -- and is not recommended.
        --
        -- Example: { "--proxy", "https://proxyserver" }
        install_args = {},
    },

    -- Controls to which degree logs are written to the log file. It's useful to set this to vim.log.levels.DEBUG when
    -- debugging issues with server installations.
    log_level = vim.log.levels.INFO,

    -- Limit for the maximum amount of servers to be installed at the same time. Once this limit is reached, any further
    -- servers that are requested to be installed will be put in a queue.
    max_concurrent_installers = 4,

    github = {
        -- The template URL to use when downloading assets from GitHub.
        -- The placeholders are the following (in order):
        -- 1. The repository (e.g. "rust-lang/rust-analyzer")
        -- 2. The release version (e.g. "v0.3.0")
        -- 3. The asset name (e.g. "rust-analyzer-v0.3.0-x86_64-unknown-linux-gnu.tar.gz")
        download_url_template = "https://github.com/%s/releases/download/%s/%s",
    },
}
```
