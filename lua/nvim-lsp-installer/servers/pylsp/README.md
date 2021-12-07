# Pylsp

## Installing pylsp plugins
pylsp is installed in a virtual environment. If you want to install additional
python packages and make them available to pylsp, you have to install them in
the virtual environment.

To find the installation of pylsp:
```vim
:lua print(vim.fn.stdpath('data') .. '/lsp_servers/pylsp')
```
cd into this directory and source the virtual env:
```sh
source venv/bin/activate
```

then you can install plugins as you would globally.
ex of `pylsp_mypy`:
```sh
pip install pylsp_mypy
```
