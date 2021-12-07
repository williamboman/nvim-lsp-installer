# Pylsp

## Installing pylsp plugins
Pylsp has [third party plugins](https://github.com/python-lsp/python-lsp-server#3rd-party-plugins) which are not installed by default.

In order for these plugins to work with the `pylsp` server managed by this plugin, they need to be installed in the same [virtual environment](https://docs.python.org/3/library/venv.html) as `pylsp`. For these reasons, there's a convenient `:PylspInstall <packages>` command that does this for you, for example:
```vim
:PylspInstall pyls-flake8 pylsp-mypy pyls-isort
```
