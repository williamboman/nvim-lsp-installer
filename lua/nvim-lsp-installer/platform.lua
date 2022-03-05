
local M = {}

local uname = vim.loop.os_uname()

---@alias Platform
---| '"win"'
---| '"unix"'
---| '"linux"'
---| '"mac"'

local arch_aliases = {
    ["x86_64"] = "x64",
    ["i386"] = "x86",
    ["i686"] = "x86", -- x86 compat
    ["aarch64"] = "arm64",
    ["aarch64_be"] = "arm64",
    ["armv8b"] = "arm64", -- arm64 compat
    ["armv8l"] = "arm64", -- arm64 compat
}

M.arch = arch_aliases[uname.machine] or uname.machine

M.is_win = vim.fn.has "win32" == 1
M.is_unix = vim.fn.has "unix" == 1
M.is_mac = vim.fn.has "mac" == 1
M.is_linux = not M.is_mac and M.is_unix
M.libc = "glibc"

if (M.is_linux) then
    local found_musl = os.execute("ldd --version 2>&1 | grep -q musl")
    if (found_musl) then
        M.libc = "musl"
    end
end

-- PATH separator
M.path_sep = M.is_win and ";" or ":"

M.is_headless = #vim.api.nvim_list_uis() == 0

return M
