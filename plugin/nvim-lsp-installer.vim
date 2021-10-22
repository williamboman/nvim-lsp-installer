if exists('g:loaded_nvim_lsp_installer') | finish | endif
let g:loaded_nvim_lsp_installer = v:true

let s:save_cpo = &cpo
set cpo&vim

function! s:LspInstallCompletion(...) abort
    return join(sort(luaeval("require'nvim-lsp-installer.servers'.get_available_server_names()")), "\n")
endfunction

function! s:LspUninstallCompletion(...) abort
    return join(sort(luaeval("require'nvim-lsp-installer.servers'.get_installed_server_names()")), "\n")
endfunction

function! s:LspUninstallAllCompletion(...) abort
    return "--no-confirm"
endfunction

function! s:ParseArgs(args)
    let sync = a:args[0] == "--sync"
    let servers = sync ? a:args[1:] : a:args
    return { 'sync': sync, 'servers': servers }
endfunction

function! s:LspInstall(args) abort
    let parsed_args = s:ParseArgs(a:args)
    if parsed_args.sync
        call luaeval("require'nvim-lsp-installer'.install_sync(_A)", parsed_args.servers)
    else
        for server_name in l:parsed_args.servers
            call luaeval("require'nvim-lsp-installer'.install(_A)", server_name)
        endfor
    endif
endfunction

function! s:LspUninstall(args) abort
    let parsed_args = s:ParseArgs(a:args)
    if parsed_args.sync
        call luaeval("require'nvim-lsp-installer'.uninstall_sync(_A)", parsed_args.servers)
    else
        for server_name in l:parsed_args.servers
            call luaeval("require'nvim-lsp-installer'.uninstall(_A)", server_name)
        endfor
    endif
endfunction

function! s:LspUninstallAll(args) abort
    let no_confirm = get(a:args, 0, v:false)
    call luaeval("require'nvim-lsp-installer'.uninstall_all(_A)", no_confirm)
endfunction

function! s:LspPrintInstalled() abort
    echo s:MapServerName(luaeval("require'nvim-lsp-installer.servers'.get_installed_servers()"))
endfunction

function! s:LspInstallInfo() abort
    lua require'nvim-lsp-installer'.display()
endfunction

function! s:LspInstallLog() abort
    exe 'tabnew ' .. luaeval("require'nvim-lsp-installer.log'.outfile")
endfunction

command! -bar -nargs=+ -complete=custom,s:LspInstallCompletion      LspInstall call s:LspInstall([<f-args>])
command! -bar -nargs=+ -complete=custom,s:LspUninstallCompletion    LspUninstall call s:LspUninstall([<f-args>])
command! -bar -nargs=? -complete=custom,s:LspUninstallAllCompletion LspUninstallAll call s:LspUninstallAll([<f-args>])

command! LspPrintInstalled call s:LspPrintInstalled()
command! LspInstallInfo call s:LspInstallInfo()
command! LspInstallLog call s:LspInstallLog()

autocmd User LspAttachBuffers lua require"nvim-lsp-installer".lsp_attach_proxy()

let &cpo = s:save_cpo
unlet s:save_cpo



"""
""" Backward compat for deprecated g:lsp_installer* options. Remove by 2021-12-01-ish.
"""
if exists("g:lsp_installer_allow_federated_servers")
    " legacy global variable option
    call luaeval("require('nvim-lsp-installer').settings { allow_federated_servers = _A }", g:lsp_installer_allow_federated_servers)
    lua vim.notify("[Deprecation notice] Providing settings via global variables (g:lsp_installer_allow_federated_servers) is deprecated. Please refer to https://github.com/williamboman/nvim-lsp-installer#configuration.", vim.log.levels.WARN)
endif

if exists("g:lsp_installer_log_level")
    " legacy global variable option
    call luaeval("require('nvim-lsp-installer').settings { log_level = _A }", g:lsp_installer_log_level)
    lua vim.notify("[Deprecation notice] Providing settings via global variables (g:lsp_installer_log_level) is deprecated. Please refer to https://github.com/williamboman/nvim-lsp-installer#configuration.", vim.log.levels.WARN)
endif
