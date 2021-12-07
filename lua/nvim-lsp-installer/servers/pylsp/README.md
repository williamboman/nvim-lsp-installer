# Pylsp

## Installing pylsp plugins
Pylsp has [third party plugins](https://github.com/python-lsp/python-lsp-server#3rd-party-plugins) which are not installed by default.

If you want to install them using the same installation of pylsp as nvim-lsp-installer, you may run
```vim
:PylspInstall <list of python packages>
```

PS:
pylsp is installed in a python venv located in `stdpath('data')/lsp_servers/pylsp`
